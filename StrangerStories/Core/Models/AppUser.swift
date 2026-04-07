import Foundation

struct AppUser: Codable, Identifiable, Sendable {
    let id: UUID
    var appleId: String?
    var email: String?
    var displayName: String
    var bio: String?
    var avatarUrl: String?
    var storiesCount: Int
    var avgRating: Double?
    var streakDays: Int
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case appleId = "apple_id"
        case email
        case displayName = "display_name"
        case bio
        case avatarUrl = "avatar_url"
        case storiesCount = "stories_count"
        case avgRating = "avg_rating"
        case streakDays = "streak_days"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
