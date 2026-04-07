import Foundation

struct Story: Codable, Identifiable, Sendable {
    let id: UUID
    var userId: UUID
    var photoId: UUID
    var content: String
    var wordCount: Int
    var startedAt: Date
    var submittedAt: Date
    var isPublished: Bool
    var isFlagged: Bool
    var modStatus: ModerationStatus
    var avgRating: Double?
    var ratingCount: Int
    var wilsonScore: Double
    let createdAt: Date

    // Chain fields
    var chainStatus: ChainStatus?
    var chapterCount: Int?
    var maxChapters: Int?
    var completedAt: Date?

    // Joined relations (optional, populated by specific queries)
    var photo: Photo?
    var author: AppUser?

    var isOpen: Bool { chainStatus == .open || chainStatus == nil }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case photoId = "photo_id"
        case content
        case wordCount = "word_count"
        case startedAt = "started_at"
        case submittedAt = "submitted_at"
        case isPublished = "is_published"
        case isFlagged = "is_flagged"
        case modStatus = "mod_status"
        case avgRating = "avg_rating"
        case ratingCount = "rating_count"
        case wilsonScore = "wilson_score"
        case createdAt = "created_at"
        case chainStatus = "chain_status"
        case chapterCount = "chapter_count"
        case maxChapters = "max_chapters"
        case completedAt = "completed_at"
        case photo = "photos"
        case author = "users"
    }
}

enum ChainStatus: String, Codable, Sendable {
    case open
    case completed
}

enum ModerationStatus: String, Codable, Sendable {
    case pending
    case approved
    case flagged
    case rejected
}
