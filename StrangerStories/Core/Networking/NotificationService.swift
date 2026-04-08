import UserNotifications
import UIKit
import Supabase

final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()

    private let supabase = SupabaseClientManager.shared.client

    private override init() {
        super.init()
    }

    // MARK: - Registration

    func requestPermissionAndRegister() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func registerDeviceToken(_ tokenData: Data) {
        let token = tokenData.map { String(format: "%02.2hhx", $0) }.joined()

        Task {
            guard let userId = try? await supabase.auth.session.user.id else { return }
            try? await saveToken(token, userId: userId)
        }
    }

    private func saveToken(_ token: String, userId: UUID) async throws {
        struct DeviceToken: Encodable {
            let user_id: UUID
            let token: String
            let platform: String
        }
        try await supabase
            .from("device_tokens")
            .upsert(DeviceToken(user_id: userId, token: token, platform: "ios"))
            .execute()
    }

    // MARK: - Categories

    func registerCategories() {
        let center = UNUserNotificationCenter.current()

        let dailyCategory = UNNotificationCategory(
            identifier: "daily_challenge",
            actions: [
                UNNotificationAction(identifier: "write", title: "Write Now", options: .foreground)
            ],
            intentIdentifiers: []
        )

        let streakCategory = UNNotificationCategory(
            identifier: "streak_at_risk",
            actions: [
                UNNotificationAction(identifier: "write", title: "Write Now", options: .foreground)
            ],
            intentIdentifiers: []
        )

        let ratingCategory = UNNotificationCategory(
            identifier: "rating_received",
            actions: [
                UNNotificationAction(identifier: "view", title: "View Story", options: .foreground)
            ],
            intentIdentifiers: []
        )

        center.setNotificationCategories([dailyCategory, streakCategory, ratingCategory])
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        // Deep-link handling can be extended here
    }
}
