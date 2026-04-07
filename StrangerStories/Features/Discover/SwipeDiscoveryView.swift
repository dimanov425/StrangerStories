import SwiftUI

struct SwipeDiscoveryView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = SwipeViewModel()
    @State private var showContinueFlow = false

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Finding stories...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.isEmpty {
                emptyState
            } else {
                cardStack
            }
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Discover")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Back") { dismiss() }
            }
            if !viewModel.isEmpty && !viewModel.stories.isEmpty {
                ToolbarItem(placement: .principal) {
                    Text(viewModel.progress)
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
            }
        }
        .fullScreenCover(isPresented: $showContinueFlow) {
            if let story = viewModel.matchedStory {
                NavigationStack {
                    ContinueStoryView(story: story)
                }
                .onDisappear {
                    viewModel.clearMatch()
                }
            }
        }
        .task {
            guard let userId = appState.currentUser?.id else { return }
            await viewModel.loadStories(userId: userId)
        }
    }

    // MARK: - Card Stack

    private var cardStack: some View {
        VStack {
            Spacer()

            ZStack {
                ForEach(visibleIndices, id: \.self) { index in
                    let offset = index - viewModel.currentIndex
                    if offset >= 0 && offset < 3 {
                        SwipeCardView(
                            story: viewModel.stories[index],
                            isTop: offset == 0
                        ) { liked in
                            guard let userId = appState.currentUser?.id else { return }
                            viewModel.swipe(liked: liked, userId: userId)
                            if liked { showContinueFlow = true }
                        }
                        .zIndex(Double(3 - offset))
                        .scaleEffect(1.0 - Double(offset) * 0.05)
                        .offset(y: CGFloat(offset) * 8)
                        .allowsHitTesting(offset == 0)
                    }
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            // Action buttons
            if viewModel.currentStory != nil {
                actionButtons
                    .padding(.bottom, 20)
            }
        }
    }

    private var visibleIndices: Range<Int> {
        let start = viewModel.currentIndex
        let end = min(viewModel.currentIndex + 3, viewModel.stories.count)
        return start..<end
    }

    private var actionButtons: some View {
        HStack(spacing: 40) {
            Button {
                guard let userId = appState.currentUser?.id else { return }
                viewModel.swipe(liked: false, userId: userId)
            } label: {
                Image(systemName: "xmark")
                    .font(.title2.bold())
                    .foregroundStyle(.red)
                    .frame(width: 60, height: 60)
                    .background(Color.backgroundSecondary)
                    .clipShape(Circle())
            }

            Button {
                guard let userId = appState.currentUser?.id else { return }
                viewModel.swipe(liked: true, userId: userId)
                showContinueFlow = true
            } label: {
                Image(systemName: "heart.fill")
                    .font(.title2.bold())
                    .foregroundStyle(Color.accentWarm)
                    .frame(width: 60, height: 60)
                    .background(Color.backgroundSecondary)
                    .clipShape(Circle())
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No more stories", systemImage: "tray")
        } description: {
            Text("You've seen all available stories.\nCheck back later for new ones!")
        } actions: {
            Button("Refresh") {
                guard let userId = appState.currentUser?.id else { return }
                viewModel.isEmpty = false
                viewModel.currentIndex = 0
                Task { await viewModel.loadStories(userId: userId) }
            }
            .buttonStyle(.bordered)
        }
    }
}
