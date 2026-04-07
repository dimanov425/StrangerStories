import Foundation
import Supabase

actor RatingRepository {
    private let supabase = SupabaseClientManager.shared.client

    func submitRating(storyId: UUID, userId: UUID, score: Int) async throws {
        struct NewRating: Encodable {
            let story_id: UUID
            let user_id: UUID
            let score: Int
        }
        try await supabase
            .from("ratings")
            .insert(NewRating(story_id: storyId, user_id: userId, score: score))
            .execute()
    }

    func fetchUserRating(storyId: UUID, userId: UUID) async throws -> Rating? {
        let ratings: [Rating] = try await supabase
            .from("ratings")
            .select()
            .eq("story_id", value: storyId)
            .eq("user_id", value: userId)
            .limit(1)
            .execute()
            .value
        return ratings.first
    }

    func fetchUnratedStories(userId: UUID, limit: Int = 2) async throws -> [Story] {
        struct UnratedParams: Encodable {
            let p_user_id: String
            let p_limit: Int
        }
        return try await supabase
            .rpc("get_unrated_stories", params: UnratedParams(
                p_user_id: userId.uuidString,
                p_limit: limit
            ))
            .execute()
            .value
    }
}
