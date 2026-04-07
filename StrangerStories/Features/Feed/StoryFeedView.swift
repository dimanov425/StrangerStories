import SwiftUI

struct StoryFeedView: View {
    @State private var viewModel = FeedViewModel()
    @State private var showWritingSession = false
    @State private var showDiscovery = false

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.stories.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.stories.isEmpty {
                ContentUnavailableView(
                    "No stories yet",
                    systemImage: "pencil.line",
                    description: Text("Be the first to write a story!")
                )
            } else {
                storyList
            }
        }
        .navigationTitle("Stories")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $viewModel.searchQuery)
        .onSubmit(of: .search) {
            Task { await viewModel.search() }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showWritingSession = true
                } label: {
                    Image(systemName: "pencil.line")
                }
            }
        }
        .fullScreenCover(isPresented: $showWritingSession) {
            WritingSessionCoordinator()
        }
        .fullScreenCover(isPresented: $showDiscovery) {
            NavigationStack {
                SwipeDiscoveryView()
            }
        }
        .task {
            await viewModel.loadStories(refresh: true)
        }
        .navigationDestination(for: UUID.self) { storyId in
            StoryDetailView(storyId: storyId)
        }
    }

    private var storyList: some View {
        List {
            // Discover Stories card
            discoverCard
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 8, trailing: 16))

            sortPicker

            ForEach(viewModel.stories) { story in
                NavigationLink(value: story.id) {
                    StoryCardView(story: story)
                }
                .contextMenu {
                    ShareLink(item: story.content) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    Button {
                        // bookmark toggle handled in detail view
                    } label: {
                        Label("Bookmark", systemImage: "bookmark")
                    }
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.loadStories(refresh: true)
        }
    }

    private var discoverCard: some View {
        Button {
            showDiscovery = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "sparkles.rectangle.stack")
                    .font(.title2)
                    .foregroundStyle(Color.accentWarm)
                    .frame(width: 44, height: 44)
                    .background(Color.accentWarm.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Discover Stories")
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                    Text("Swipe to find your next chapter")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(.tertiary)
            }
            .padding(12)
            .background(Color.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var sortPicker: some View {
        Picker("Sort", selection: $viewModel.sort) {
            ForEach(FeedSort.allCases, id: \.self) { sort in
                Text(sort.rawValue).tag(sort)
            }
        }
        .pickerStyle(.segmented)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .onChange(of: viewModel.sort) {
            Task { await viewModel.loadStories(refresh: true) }
        }
    }
}
