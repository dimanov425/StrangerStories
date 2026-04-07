import Foundation

struct DailyChallenge: Codable, Identifiable, Sendable {
    let id: UUID
    var photoId: UUID
    var date: String
    let createdAt: Date

    var photo: Photo?

    enum CodingKeys: String, CodingKey {
        case id
        case photoId = "photo_id"
        case date
        case createdAt = "created_at"
        case photo = "photos"
    }
}
