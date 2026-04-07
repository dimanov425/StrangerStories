import Foundation
import Supabase

actor SwipeRepository {
    private let supabase = SupabaseClientManager.shared.client

    func fetchSwipeableStories(userId: UUID, limit: Int = 7) async throws -> [Story] {
        struct Params: Encodable {
            let p_user_id: UUID
            let p_limit: Int
        }
        let stories: [Story] = try await supabase
            .rpc("fetch_swipeable_stories", params: Params(p_user_id: userId, p_limit: limit))
            .execute()
            .value
        return stories
    }

    func recordSwipe(userId: UUID, storyId: UUID, liked: Bool) async throws {
        struct NewSwipe: Encodable {
            let user_id: UUID
            let story_id: UUID
            let liked: Bool
        }
        try await supabase
            .from("story_swipes")
            .insert(NewSwipe(user_id: userId, story_id: storyId, liked: liked))
            .execute()
    }
}
