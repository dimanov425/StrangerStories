import SwiftUI

@main
struct StrangerStoriesApp: App {
    @State private var appState = AppState()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isInitialized {
                    if appState.hasCompletedOnboarding {
                        if appState.needsNickname {
                            NicknamePickerView()
                        } else {
                            ContentView()
                        }
                    } else {
                        OnboardingView()
                    }
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.backgroundPrimary)
                }
            }
            .environment(appState)
            .preferredColorScheme(.dark)
            .onChange(of: appState.hasCompletedOnboarding) { _, completed in
                if completed {
                    NotificationService.shared.registerCategories()
                    NotificationService.shared.requestPermissionAndRegister()
                }
            }
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        NotificationService.shared.registerDeviceToken(deviceToken)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        // Push registration failed — non-critical
    }
}
