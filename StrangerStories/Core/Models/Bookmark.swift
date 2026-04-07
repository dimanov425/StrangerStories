import Foundation

struct Bookmark: Codable, Identifiable, Sendable {
    let id: UUID
    var userId: UUID
    var storyId: UUID
    let createdAt: Date

    var story: Story?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case storyId = "story_id"
        case createdAt = "created_at"
        case story = "stories"
    }
}
