import SwiftUI

@main
struct StrangerStoriesApp: App {
    @State private var appState = AppState()

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
        }
    }
}
