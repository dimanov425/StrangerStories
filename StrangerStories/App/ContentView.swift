import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState

        TabView(selection: $state.selectedTab) {
            NavigationStack {
                WriteTabView()
            }
            .tabItem {
                Label(
                    String(localized: "Write"),
                    systemImage: appState.selectedTab == .write ? "pencil.line" : "pencil.line"
                )
            }
            .tag(Tab.write)

            NavigationStack {
                StoryFeedView()
            }
            .tabItem {
                Label(
                    String(localized: "Feed"),
                    systemImage: appState.selectedTab == .feed ? "square.grid.2x2.fill" : "square.grid.2x2"
                )
            }
            .tag(Tab.feed)

            NavigationStack {
                AnthologyCoverView()
            }
            .tabItem {
                Label(
                    String(localized: "Anthology"),
                    systemImage: appState.selectedTab == .anthology ? "book.fill" : "book"
                )
            }
            .tag(Tab.anthology)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label(
                    String(localized: "Profile"),
                    systemImage: appState.selectedTab == .profile ? "person.circle.fill" : "person.circle"
                )
            }
            .tag(Tab.profile)
        }
        .tint(.accentWarm)
    }
}

enum Tab: Hashable {
    case write, feed, anthology, profile
}
