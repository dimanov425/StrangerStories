import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var currentPage = 0

    private let pages: [(symbol: String, title: LocalizedStringKey, subtitle: LocalizedStringKey)] = [
        ("photo.on.rectangle.angled", "A photo appears", "An atmospheric place — a corridor, a window, a station. The mood is yours to interpret."),
        ("timer", "3 minutes to write", "No edits, no pressure to be perfect. Just raw imagination under gentle time pressure."),
        ("book.fill", "Stories by strangers", "Your words join hundreds of others. The same place, seen through different eyes."),
    ]

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    onboardingPage(
                        symbol: pages[index].symbol,
                        title: pages[index].title,
                        subtitle: pages[index].subtitle
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            VStack(spacing: 16) {
                if currentPage == pages.count - 1 {
                    SignInView()
                } else {
                    Button {
                        withAnimation { currentPage = pages.count - 1 }
                    } label: {
                        Text("Skip")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .background(Color.backgroundPrimary)
    }

    @ViewBuilder
    private func onboardingPage(
        symbol: String,
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey
    ) -> some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: symbol)
                .font(.system(size: 80))
                .foregroundStyle(Color.accentWarm)
                .symbolRenderingMode(.hierarchical)

            Text(title)
                .font(.title.bold())
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
    }
}
