import UIKit

final class HapticManager {
    static let shared = HapticManager()

    private init() {}

    func timerStart() {
        impact(.light)
    }

    func autoSaveConfirm() {
        impact(.soft)
    }

    func timerWarningPulse() {
        impact(.rigid)
    }

    func storySubmitted() {
        notification(.success)
    }

    func starRatingTapped() {
        impact(.medium)
    }

    func achievementUnlocked() {
        notification(.success)
    }

    func bookmarkToggled() {
        impact(.light)
    }

    func errorOccurred() {
        notification(.error)
    }

    func destructiveWarning() {
        notification(.warning)
    }

    private func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    private func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
