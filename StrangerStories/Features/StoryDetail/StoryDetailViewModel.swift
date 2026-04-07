import SwiftUI

@Observable
final class StoryDetailViewModel {
    var story: Story?
    var chapters: [Chapter] = []
    var relatedStories: [Story] = []
    var userRating: Int?
    var isBookmarked = false
    var hasContributed = false
    var isLoading = false
    var showReportDialog = false
    var errorMessage: String?

    private let storyRepo = StoryRepository()
    private let chapterRepo = ChapterRepository()
    private let ratingRepo = RatingRepository()
    private let bookmarkRepo = BookmarkRepository()

    var canContinue: Bool {
        guard let story else { return false }
        return story.isOpen && !hasContributed
    }

    @MainActor
    func loadStory(id: UUID, currentUserId: UUID?) async {
        isLoading = true
        do {
            story = try await storyRepo.fetchStory(id: id)
            chapters = try await chapterRepo.fetchChapters(storyId: id)

            if let story, let userId = currentUserId {
                let existingRating = try? await ratingRepo.fetchUserRating(storyId: story.id, userId: userId)
                userRating = existingRating?.score

                isBookmarked = (try? await bookmarkRepo.isBookmarked(storyId: story.id, userId: userId)) ?? false

                hasContributed = (try? await chapterRepo.hasUserContributed(storyId: story.id, userId: userId)) ?? false

                relatedStories = try await storyRepo.fetchStoriesByPhoto(photoId: story.photoId, limit: 10)
                    .filter { $0.id != story.id }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    func submitRating(_ score: Int, userId: UUID) async {
        guard let story else { return }
        do {
            try await ratingRepo.submitRating(storyId: story.id, userId: userId, score: score)
            userRating = score
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    func toggleBookmark(userId: UUID) async {
        guard let story else { return }
        do {
            isBookmarked = try await bookmarkRepo.toggleBookmark(storyId: story.id, userId: userId)
            HapticManager.shared.bookmarkToggled()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    func reportStory(reason: String, userId: UUID) async {
        guard let story else { return }
        do {
            try await storyRepo.reportStory(storyId: story.id, reporterId: userId, reason: reason)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
