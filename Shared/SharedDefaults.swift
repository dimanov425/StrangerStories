import Foundation
import WidgetKit

/// Shared UserDefaults wrapper for App Group data exchange between the main app and widgets.
enum SharedDefaults {
    static let suiteName = "group.com.strangerstories.shared"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    // MARK: - Keys

    private enum Key {
        static let challengePhotoURL = "challenge_photo_url"
        static let challengeStoryCount = "challenge_story_count"
        static let challengeDate = "challenge_date"
    }

    // MARK: - Write (called from main app)

    static func writeDailyChallenge(photoURL: URL?, storyCount: Int, date: String) {
        let store = defaults
        store?.set(photoURL?.absoluteString, forKey: Key.challengePhotoURL)
        store?.set(storyCount, forKey: Key.challengeStoryCount)
        store?.set(date, forKey: Key.challengeDate)

        WidgetCenter.shared.reloadTimelines(ofKind: "DailyChallengeWidget")
    }

    // MARK: - Read (called from widget)

    static var challengePhotoURL: URL? {
        guard let urlString = defaults?.string(forKey: Key.challengePhotoURL) else { return nil }
        return URL(string: urlString)
    }

    static var challengeStoryCount: Int {
        defaults?.integer(forKey: Key.challengeStoryCount) ?? 0
    }

    static var challengeDate: String? {
        defaults?.string(forKey: Key.challengeDate)
    }
}
