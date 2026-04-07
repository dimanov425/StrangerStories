import Foundation

struct Achievement: Codable, Identifiable, Sendable {
    let id: UUID
    var userId: UUID
    var type: AchievementType
    let earnedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case type
        case earnedAt = "earned_at"
    }
}

enum AchievementType: String, Codable, Sendable, CaseIterable {
    case firstWords = "first_words"
    case storyteller
    case prolific
    case weekWarrior = "week_warrior"
    case monthMaster = "month_master"
    case crowdFavorite = "crowd_favorite"
    case communityVoice = "community_voice"

    var displayName: String {
        switch self {
        case .firstWords: String(localized: "First Words")
        case .storyteller: String(localized: "Storyteller")
        case .prolific: String(localized: "Prolific")
        case .weekWarrior: String(localized: "Week Warrior")
        case .monthMaster: String(localized: "Month Master")
        case .crowdFavorite: String(localized: "Crowd Favorite")
        case .communityVoice: String(localized: "Community Voice")
        }
    }

    var symbolName: String {
        switch self {
        case .firstWords: "text.cursor"
        case .storyteller: "book.closed"
        case .prolific: "books.vertical"
        case .weekWarrior: "flame"
        case .monthMaster: "flame.fill"
        case .crowdFavorite: "star.circle"
        case .communityVoice: "hand.thumbsup"
        }
    }

    var description: String {
        switch self {
        case .firstWords: String(localized: "Wrote your first story")
        case .storyteller: String(localized: "Wrote 10 stories")
        case .prolific: String(localized: "Wrote 50 stories")
        case .weekWarrior: String(localized: "7-day writing streak")
        case .monthMaster: String(localized: "30-day writing streak")
        case .crowdFavorite: String(localized: "A story in the top 10%")
        case .communityVoice: String(localized: "Rated 50 stories")
        }
    }
}
