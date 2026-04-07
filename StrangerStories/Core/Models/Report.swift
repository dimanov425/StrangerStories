import Foundation

struct Report: Codable, Identifiable, Sendable {
    let id: UUID
    var storyId: UUID
    var reporterId: UUID
    var reason: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case storyId = "story_id"
        case reporterId = "reporter_id"
        case reason
        case createdAt = "created_at"
    }
}

enum ReportReason: String, CaseIterable {
    case hateSpeech = "hate_speech"
    case violence
    case sexualContent = "sexual_content"
    case personalInformation = "personal_information"
    case spam
    case other

    var displayName: String {
        switch self {
        case .hateSpeech: String(localized: "Hate Speech")
        case .violence: String(localized: "Violence")
        case .sexualContent: String(localized: "Sexual Content")
        case .personalInformation: String(localized: "Personal Information")
        case .spam: String(localized: "Spam")
        case .other: String(localized: "Other")
        }
    }
}
