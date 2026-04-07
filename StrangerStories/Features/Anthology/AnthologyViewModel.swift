import SwiftUI

@Observable
final class AnthologyViewModel {
    var chapters: [Photo] = []
    var isLoading = false
    var errorMessage: String?

    private let photoRepo = PhotoRepository()

    @MainActor
    func loadChapters() async {
        isLoading = chapters.isEmpty
        do {
            chapters = try await photoRepo.fetchPhotosWithStories()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

@Observable
final class AnthologyChapterViewModel {
    var photo: Photo?
    var stories: [Story] = []
    var isLoading = false

    private let photoRepo = PhotoRepository()
    private let storyRepo = StoryRepository()

    @MainActor
    func loadChapter(photoId: UUID) async {
        isLoading = true
        do {
            photo = try await photoRepo.fetchPhoto(id: photoId)
            stories = try await storyRepo.fetchStoriesByPhoto(photoId: photoId)
        } catch {
            // handled silently
        }
        isLoading = false
    }
}
