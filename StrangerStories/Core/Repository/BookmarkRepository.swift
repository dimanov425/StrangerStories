import Foundation
import Supabase

actor BookmarkRepository {
    private let supabase = SupabaseClientManager.shared.client

    func fetchBookmarks(userId: UUID) async throws -> [Bookmark] {
        try await supabase
            .from("bookmarks")
            .select("*, stories(*, users(*), photos(*))")
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func isBookmarked(storyId: UUID, userId: UUID) async throws -> Bool {
        let bookmarks: [Bookmark] = try await supabase
            .from("bookmarks")
            .select("id")
            .eq("story_id", value: storyId)
            .eq("user_id", value: userId)
            .limit(1)
            .execute()
            .value
        return !bookmarks.isEmpty
    }

    func toggleBookmark(storyId: UUID, userId: UUID) async throws -> Bool {
        let existing = try await isBookmarked(storyId: storyId, userId: userId)
        if existing {
            try await supabase
                .from("bookmarks")
                .delete()
                .eq("story_id", value: storyId)
                .eq("user_id", value: userId)
                .execute()
            return false
        } else {
            struct NewBookmark: Encodable {
                let user_id: UUID
                let story_id: UUID
            }
            try await supabase
                .from("bookmarks")
                .insert(NewBookmark(user_id: userId, story_id: storyId))
                .execute()
            return true
        }
    }
}
