import Foundation

struct AutoSave: Codable, Identifiable, Sendable {
    let id: UUID
    var userId: UUID
    var photoId: UUID
    var content: String
    var savedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case photoId = "photo_id"
        case content
        case savedAt = "saved_at"
    }
}
