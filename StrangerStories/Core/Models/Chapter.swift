import Foundation

struct Chapter: Codable, Identifiable, Sendable {
    let id: UUID
    var storyId: UUID
    var userId: UUID
    var chapterNumber: Int
    var content: String
    var wordCount: Int
    var keywords: [String]
    var isEnding: Bool
    var startedAt: Date
    var submittedAt: Date
    let createdAt: Date

    var author: AppUser?

    enum CodingKeys: String, CodingKey {
        case id
        case storyId = "story_id"
        case userId = "user_id"
        case chapterNumber = "chapter_number"
        case content
        case wordCount = "word_count"
        case keywords
        case isEnding = "is_ending"
        case startedAt = "started_at"
        case submittedAt = "submitted_at"
        case createdAt = "created_at"
        case author = "users"
    }
}
