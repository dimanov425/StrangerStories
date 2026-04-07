import Foundation
import Supabase

actor ChapterRepository {
    private let supabase = SupabaseClientManager.shared.client

    func fetchChapters(storyId: UUID) async throws -> [Chapter] {
        try await supabase
            .from("chapters")
            .select("*, users!inner(*)")
            .eq("story_id", value: storyId)
            .order("chapter_number", ascending: true)
            .execute()
            .value
    }

    func submitChapter(
        storyId: UUID,
        userId: UUID,
        chapterNumber: Int,
        content: String,
        keywords: [String],
        isEnding: Bool,
        startedAt: Date,
        submittedAt: Date
    ) async throws -> Chapter {
        struct NewChapter: Encodable {
            let story_id: UUID
            let user_id: UUID
            let chapter_number: Int
            let content: String
            let word_count: Int
            let keywords: [String]
            let is_ending: Bool
            let started_at: String
            let submitted_at: String
        }

        let formatter = ISO8601DateFormatter()
        let chapter: Chapter = try await supabase
            .from("chapters")
            .insert(NewChapter(
                story_id: storyId,
                user_id: userId,
                chapter_number: chapterNumber,
                content: content,
                word_count: content.split(separator: " ").count,
                keywords: keywords,
                is_ending: isEnding,
                started_at: formatter.string(from: startedAt),
                submitted_at: formatter.string(from: submittedAt)
            ))
            .select()
            .single()
            .execute()
            .value

        return chapter
    }

    func hasUserContributed(storyId: UUID, userId: UUID) async throws -> Bool {
        let chapters: [Chapter] = try await supabase
            .from("chapters")
            .select("id")
            .eq("story_id", value: storyId)
            .eq("user_id", value: userId)
            .limit(1)
            .execute()
            .value
        return !chapters.isEmpty
    }
}
