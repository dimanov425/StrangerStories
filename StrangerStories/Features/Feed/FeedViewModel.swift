import SwiftUI

@Observable
final class FeedViewModel {
    var stories: [Story] = []
    var sort: FeedSort = .recent
    var searchQuery = ""
    var isLoading = false
    var errorMessage: String?
    var bookmarkedStoryIds: Set<UUID> = []
    private var offset = 0
    private let pageSize = 20

    private let storyRepo = StoryRepository()
    private let bookmarkRepo = BookmarkRepository()

    @MainActor
    func loadStories(refresh: Bool = false) async {
        if refresh { offset = 0 }
        isLoading = stories.isEmpty
        do {
            let fetched = try await storyRepo.fetchFeed(sort: sort, offset: offset, limit: pageSize)
            if refresh {
                stories = fetched
            } else {
                stories.append(contentsOf: fetched)
            }
            offset = stories.count
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    func search() async {
        guard !searchQuery.isEmpty else {
            await loadStories(refresh: true)
            return
        }
        isLoading = true
        do {
            stories = try await storyRepo.searchStories(query: searchQuery)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    func toggleBookmark(storyId: UUID, userId: UUID) async {
        do {
            let isNowBookmarked = try await bookmarkRepo.toggleBookmark(storyId: storyId, userId: userId)
            if isNowBookmarked {
                bookmarkedStoryIds.insert(storyId)
            } else {
                bookmarkedStoryIds.remove(storyId)
            }
            HapticManager.shared.bookmarkToggled()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func isBookmarked(_ storyId: UUID) -> Bool {
        bookmarkedStoryIds.contains(storyId)
    }
}
