import Foundation
import Supabase

struct Photo: Codable, Identifiable, Sendable {
    let id: UUID
    var storagePath: String
    var altText: String
    var photographer: String
    var license: String
    var moodTags: [String]
    var location: String?
    var storyCount: Int
    var isActive: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case storagePath = "storage_path"
        case altText = "alt_text"
        case photographer
        case license
        case moodTags = "mood_tags"
        case location
        case storyCount = "story_count"
        case isActive = "is_active"
        case createdAt = "created_at"
    }

    /// Resolve the storage path to a full CDN URL
    var publicURL: URL? {
        let client = SupabaseClientManager.shared.client
        return try? client.storage.from("photos").getPublicURL(path: storagePath)
    }
}
