import Foundation
import Supabase

actor StoryRepository {
    private let supabase = SupabaseClientManager.shared.client

    // MARK: - Session Management

    func startSession(photoId: UUID) async throws -> Date {
        let now = Date()
        // Record server-side timestamp via RPC for validation
        try await supabase.rpc("record_session_start", params: [
            "p_photo_id": photoId.uuidString,
            "p_started_at": ISO8601DateFormatter().string(from: now),
        ]).execute()
        return now
    }

    func submitStory(
        userId: UUID,
        photoId: UUID,
        content: String,
        startedAt: Date,
        submittedAt: Date
    ) async throws -> Story {
        let wordCount = content.split(separator: " ").count

        struct NewStory: Encodable {
            let user_id: UUID
            let photo_id: UUID
            let content: String
            let word_count: Int
            let started_at: String
            let submitted_at: String
        }

        let formatter = ISO8601DateFormatter()
        let story: Story = try await supabase
            .from("stories")
            .insert(NewStory(
                user_id: userId,
                photo_id: photoId,
                content: content,
                word_count: wordCount,
                started_at: formatter.string(from: startedAt),
                submitted_at: formatter.string(from: submittedAt)
            ))
            .select()
            .single()
            .execute()
            .value

        // Also create chapter 1
        struct NewChapter: Encodable {
            let story_id: UUID
            let user_id: UUID
            let chapter_number: Int
            let content: String
            let word_count: Int
            let started_at: String
            let submitted_at: String
        }
        try await supabase
            .from("chapters")
            .insert(NewChapter(
                story_id: story.id,
                user_id: userId,
                chapter_number: 1,
                content: content,
                word_count: wordCount,
                started_at: formatter.string(from: startedAt),
                submitted_at: formatter.string(from: submittedAt)
            ))
            .execute()

        return story
    }

    // MARK: - Feed Queries

    func fetchFeed(sort: FeedSort, offset: Int = 0, limit: Int = 20) async throws -> [Story] {
        let base = supabase
            .from("stories")
            .select("*, users!inner(*), photos!inner(*)")
            .eq("is_published", value: true)

        switch sort {
        case .recent:
            return try await base
                .order("created_at", ascending: false)
                .range(from: offset, to: offset + limit - 1)
                .execute()
                .value
        case .topRated:
            return try await base
                .order("wilson_score", ascending: false)
                .range(from: offset, to: offset + limit - 1)
                .execute()
                .value
        case .thisWeek:
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            return try await base
                .gte("created_at", value: ISO8601DateFormatter().string(from: weekAgo))
                .order("wilson_score", ascending: false)
                .range(from: offset, to: offset + limit - 1)
                .execute()
                .value
        }
    }

    func fetchStory(id: UUID) async throws -> Story {
        try await supabase
            .from("stories")
            .select("*, users!inner(*), photos!inner(*)")
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }

    func fetchStoriesByPhoto(photoId: UUID, limit: Int = 50) async throws -> [Story] {
        try await supabase
            .from("stories")
            .select("*, users!inner(*)")
            .eq("photo_id", value: photoId)
            .eq("is_published", value: true)
            .order("wilson_score", ascending: false)
            .limit(limit)
            .execute()
            .value
    }

    func fetchUserStories(userId: UUID) async throws -> [Story] {
        try await supabase
            .from("stories")
            .select("*, photos!inner(*)")
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func searchStories(query: String, limit: Int = 20) async throws -> [Story] {
        try await supabase
            .from("stories")
            .select("*, users!inner(*), photos!inner(*)")
            .eq("is_published", value: true)
            .ilike("content", pattern: "%\(query)%")
            .order("wilson_score", ascending: false)
            .limit(limit)
            .execute()
            .value
    }

    // MARK: - Reporting

    func reportStory(storyId: UUID, reporterId: UUID, reason: String) async throws {
        struct NewReport: Encodable {
            let story_id: UUID
            let reporter_id: UUID
            let reason: String
        }
        try await supabase
            .from("reports")
            .insert(NewReport(story_id: storyId, reporter_id: reporterId, reason: reason))
            .execute()
    }

    // MARK: - Auto-save

    func autoSave(userId: UUID, photoId: UUID, content: String) async throws {
        struct SavePayload: Encodable {
            let user_id: UUID
            let photo_id: UUID
            let content: String
            let saved_at: String
        }
        try await supabase
            .from("auto_saves")
            .upsert(SavePayload(
                user_id: userId,
                photo_id: photoId,
                content: content,
                saved_at: ISO8601DateFormatter().string(from: Date())
            ))
            .execute()
    }

    func fetchAutoSave(userId: UUID) async throws -> AutoSave? {
        let saves: [AutoSave] = try await supabase
            .from("auto_saves")
            .select()
            .eq("user_id", value: userId)
            .order("saved_at", ascending: false)
            .limit(1)
            .execute()
            .value
        return saves.first
    }

    func deleteAutoSaves(userId: UUID) async throws {
        try await supabase
            .from("auto_saves")
            .delete()
            .eq("user_id", value: userId)
            .execute()
    }
}

enum FeedSort: String, CaseIterable {
    case recent = "Recent"
    case topRated = "Top Rated"
    case thisWeek = "This Week"
}
