import SwiftUI

@MainActor @Observable
final class WriteTabViewModel {
    var challenge: DailyChallenge?
    var isLoading = false
    var streakDays: Int = 0

    private let challengeRepo = DailyChallengeRepository()

    var challengePhotoURL: URL? {
        challenge?.photo?.publicURL
    }

    var storyCount: Int {
        challenge?.photo?.storyCount ?? 0
    }

    var timeUntilMidnight: Date {
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: .now) ?? .now)
        return tomorrow
    }

    func load(streakDays: Int) async {
        self.streakDays = streakDays
        isLoading = true
        do {
            challenge = try await challengeRepo.fetchTodaysChallenge()
            if let challenge {
                SharedDefaults.writeDailyChallenge(
                    photoURL: challenge.photo?.publicURL,
                    storyCount: challenge.photo?.storyCount ?? 0,
                    date: challenge.date
                )
            }
        } catch {
            // Non-critical — fall back to random-photo mode
        }
        isLoading = false
    }
}
