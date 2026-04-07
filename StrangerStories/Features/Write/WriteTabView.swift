import SwiftUI

struct WriteTabView: View {
    @Environment(AppState.self) private var appState
    @State private var showWritingSession = false

    var body: some View {
        VStack(spacing: Spacing.sectionSpacing) {
            Spacer()

            Image(systemName: "pencil.line")
                .font(.system(size: 72))
                .foregroundStyle(Color.accentWarm)
                .symbolRenderingMode(.hierarchical)

            Text("Ready to write?")
                .font(.title.bold())

            Text("A random photo will appear.\nYou have 3 minutes to write a story.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showWritingSession = true
            } label: {
                Label("Start Writing", systemImage: "pencil.line")
                    .font(.headline)
                    .frame(maxWidth: 280)
                    .frame(height: Spacing.minTapTarget)
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentWarm)

            Spacer()
        }
        .padding(.horizontal, Spacing.standardMargin)
        .navigationTitle("Write")
        .fullScreenCover(isPresented: $showWritingSession) {
            WritingSessionCoordinator()
        }
    }
}
