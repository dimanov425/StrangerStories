import Foundation

struct Rating: Codable, Identifiable, Sendable {
    let id: UUID
    var storyId: UUID
    var userId: UUID
    var score: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case storyId = "story_id"
        case userId = "user_id"
        case score
        case createdAt = "created_at"
    }
}
