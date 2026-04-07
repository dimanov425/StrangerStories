import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab: Tab = .feed

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                WriteTabView()
            }
            .tabItem {
                Label(
                    String(localized: "Write"),
                    systemImage: selectedTab == .write ? "pencil.line" : "pencil.line"
                )
            }
            .tag(Tab.write)

            NavigationStack {
                StoryFeedView()
            }
            .tabItem {
                Label(
                    String(localized: "Feed"),
                    systemImage: selectedTab == .feed ? "square.grid.2x2.fill" : "square.grid.2x2"
                )
            }
            .tag(Tab.feed)

            NavigationStack {
                AnthologyCoverView()
            }
            .tabItem {
                Label(
                    String(localized: "Anthology"),
                    systemImage: selectedTab == .anthology ? "book.fill" : "book"
                )
            }
            .tag(Tab.anthology)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label(
                    String(localized: "Profile"),
                    systemImage: selectedTab == .profile ? "person.circle.fill" : "person.circle"
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
