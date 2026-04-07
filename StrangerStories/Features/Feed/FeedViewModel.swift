import SwiftUI

@Observable
final class FeedViewModel {
    var stories: [Story] = []
    var sort: FeedSort = .recent
    var searchQuery = ""
    var isLoading = false
    var errorMessage: String?
    private var offset = 0
    private let pageSize = 20

    private let storyRepo = StoryRepository()

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
}
