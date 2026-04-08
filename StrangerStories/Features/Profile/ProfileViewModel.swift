import SwiftUI
import PhotosUI
import Supabase

@MainActor @Observable
final class ProfileViewModel {
    var user: AppUser?
    var stories: [Story] = []
    var bookmarks: [Bookmark] = []
    var achievements: [Achievement] = []
    var isLoading = false

    // Edit state
    var editDisplayName = ""
    var editBio = ""
    var selectedPhoto: PhotosPickerItem?
    var showDeleteConfirmation = false

    // Name uniqueness state
    var nameAvailable: Bool?
    var nameError: String?
    var isCheckingName = false
    var isSaving = false

    private let userRepo = UserRepository()
    private let storyRepo = StoryRepository()
    private let bookmarkRepo = BookmarkRepository()
    private let supabase = SupabaseClientManager.shared.client

    func loadProfile(userId: UUID) async {
        isLoading = true
        do {
            user = try await userRepo.fetchUser(id: userId)
            stories = try await storyRepo.fetchUserStories(userId: userId)
            bookmarks = try await bookmarkRepo.fetchBookmarks(userId: userId)
            achievements = try await userRepo.fetchAchievements(userId: userId)

            editDisplayName = user?.displayName ?? ""
            editBio = user?.bio ?? ""
        } catch {
            // handled silently
        }
        isLoading = false
    }

    func checkNameAvailability() async {
        guard editDisplayName.count >= 3 else { return }
        isCheckingName = true
        defer { isCheckingName = false }

        do {
            let available: Bool = try await supabase
                .rpc("is_display_name_available", params: ["desired_name": editDisplayName])
                .execute().value
            nameAvailable = available
        } catch {
            nameError = "Could not check availability"
        }
    }

    func saveProfileWithUniqueName(userId: UUID) async {
        isSaving = true
        defer { isSaving = false }

        let nameChanged = editDisplayName != user?.displayName
        if nameChanged {
            do {
                let success: Bool = try await supabase
                    .rpc("claim_display_name", params: ["desired_name": editDisplayName])
                    .execute().value
                if !success {
                    nameAvailable = false
                    return
                }
            } catch {
                if "\(error)".contains("unique") {
                    nameAvailable = false
                } else {
                    nameError = "Failed to update name"
                }
                return
            }
        }

        do {
            try await userRepo.updateProfile(
                userId: userId,
                displayName: editDisplayName,
                bio: editBio.isEmpty ? nil : editBio
            )
            user?.displayName = editDisplayName
            user?.bio = editBio.isEmpty ? nil : editBio
        } catch {
            nameError = "Failed to save profile"
        }
    }

    func deleteAccount(userId: UUID, appState: AppState) async {
        HapticManager.shared.destructiveWarning()
        do {
            try await userRepo.deleteAccount(userId: userId)
            await appState.signOut()
        } catch {
            // show error
        }
    }

    var totalWords: Int {
        stories.reduce(0) { $0 + $1.wordCount }
    }
}
