import SwiftUI

@MainActor @Observable
final class SwipeViewModel {
    var stories: [Story] = []
    var currentIndex = 0
    var isLoading = false
    var errorMessage: String?
    var matchedStory: Story?
    var isEmpty = false

    private let swipeRepo = SwipeRepository()
    private let storyRepo = StoryRepository()

    var currentStory: Story? {
        guard currentIndex < stories.count else { return nil }
        return stories[currentIndex]
    }

    var remainingCount: Int { max(0, stories.count - currentIndex) }
    var progress: String { "\(currentIndex + 1) of \(stories.count)" }

    func loadStories(userId: UUID) async {
        isLoading = true
        do {
            stories = try await swipeRepo.fetchSwipeableStories(userId: userId)
            // Fetch photos for each story since RPC doesn't join
            var enriched: [Story] = []
            for var story in stories {
                if let full = try? await storyRepo.fetchStory(id: story.id) {
                    enriched.append(full)
                } else {
                    enriched.append(story)
                }
            }
            stories = enriched
            isEmpty = stories.isEmpty
        } catch {
            errorMessage = "Could not load stories"
        }
        isLoading = false
    }

    func swipe(liked: Bool, userId: UUID) {
        guard let story = currentStory else { return }

        Task {
            try? await swipeRepo.recordSwipe(userId: userId, storyId: story.id, liked: liked)
        }

        if liked {
            matchedStory = story
            HapticManager.shared.storySubmitted()
        } else {
            HapticManager.shared.autoSaveConfirm()
            advance()
        }
    }

    func advance() {
        currentIndex += 1
        if currentIndex >= stories.count {
            isEmpty = true
        }
    }

    func clearMatch() {
        matchedStory = nil
        advance()
    }
}
