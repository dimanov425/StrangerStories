import SwiftUI
import Kingfisher

struct StoryDetailView: View {
    let storyId: UUID
    @Environment(AppState.self) private var appState
    @State private var viewModel = StoryDetailViewModel()
    @State private var selectedReportReason: ReportReason?
    @State private var showReportConfirmation = false
    @State private var showFullScreenPhoto = false
    @State private var showContinueFlow = false

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 300)
            } else if let story = viewModel.story {
                storyContent(story)
            }
        }
        .background(Color.backgroundPrimary)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if let story = viewModel.story {
                    ShareLink(
                        item: story.content,
                        subject: Text("A Stranger Story"),
                        message: Text("Read this story on Stranger Stories")
                    ) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    guard let userId = appState.currentUser?.id else { return }
                    Task { await viewModel.toggleBookmark(userId: userId) }
                } label: {
                    Image(systemName: viewModel.isBookmarked ? "bookmark.fill" : "bookmark")
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                Button(role: .destructive) {
                    showReportConfirmation = true
                } label: {
                    Label("Report", systemImage: "flag")
                }
            }
        }
        .confirmationDialog("Report this story", isPresented: $showReportConfirmation) {
            ForEach(ReportReason.allCases, id: \.rawValue) { reason in
                Button(reason.displayName) {
                    guard let userId = appState.currentUser?.id else { return }
                    Task { await viewModel.reportStory(reason: reason.rawValue, userId: userId) }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .task {
            await viewModel.loadStory(id: storyId, currentUserId: appState.currentUser?.id)
        }
    }

    @ViewBuilder
    private func storyContent(_ story: Story) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Photo hero — tap for full screen
            if let photo = story.photo, let url = photo.publicURL {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxHeight: 300)
                    .clipped()
                    .accessibilityLabel(photo.altText)
                    .onTapGesture { showFullScreenPhoto = true }
                    .fullScreenCover(isPresented: $showFullScreenPhoto) {
                        fullScreenPhotoView(url: url, altText: photo.altText)
                    }
            }

            // Chain status bar
            chainStatusBar(story)

            // Chapters list
            VStack(alignment: .leading, spacing: 16) {
                if viewModel.chapters.isEmpty {
                    // Fallback: show the story content directly
                    singleStoryContent(story)
                } else {
                    ForEach(viewModel.chapters) { chapter in
                        ChapterCardView(chapter: chapter)
                    }
                }
            }
            .padding(.horizontal, Spacing.standardMargin)
            .padding(.top, 12)

            // Continue button
            if viewModel.canContinue {
                Button {
                    showContinueFlow = true
                } label: {
                    Label("Continue this Story", systemImage: "pencil.line")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.accentWarm)
                .padding(.horizontal, Spacing.standardMargin)
                .padding(.top, 16)
            }

            // Rating
            VStack(alignment: .leading, spacing: 8) {
                let isOwn = story.userId == appState.currentUser?.id
                RatingStarsView(
                    currentRating: viewModel.userRating,
                    isOwnStory: isOwn
                ) { score in
                    guard let userId = appState.currentUser?.id else { return }
                    Task { await viewModel.submitRating(score, userId: userId) }
                }

                if let avg = story.avgRating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(Color.accentWarm)
                        Text(String(format: "%.1f", avg))
                        Text("(\(story.ratingCount))")
                            .foregroundStyle(.secondary)
                    }
                    .font(.caption)
                }
            }
            .padding(.horizontal, Spacing.standardMargin)
            .padding(.top, 16)

            // Related stories
            if !viewModel.relatedStories.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("More stories about this place")
                        .font(.headline)
                        .padding(.horizontal, Spacing.standardMargin)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.relatedStories) { related in
                                NavigationLink(value: related.id) {
                                    relatedStoryCard(related)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, Spacing.standardMargin)
                    }
                }
                .padding(.top, 16)
            }
        }
        .padding(.bottom, Spacing.sectionSpacing)
        .fullScreenCover(isPresented: $showContinueFlow) {
            if let story = viewModel.story {
                NavigationStack {
                    ContinueStoryView(story: story)
                }
            }
        }
    }

    @ViewBuilder
    private func chainStatusBar(_ story: Story) -> some View {
        HStack {
            Label(
                "\(story.chapterCount ?? 1) of \(story.maxChapters ?? 7) chapters",
                systemImage: "book.pages"
            )
            .font(.caption.bold())

            Spacer()

            Text(story.isOpen ? "Open" : "Completed")
                .font(.caption.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(story.isOpen ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                .foregroundStyle(story.isOpen ? .green : .orange)
                .clipShape(Capsule())
        }
        .padding(.horizontal, Spacing.standardMargin)
        .padding(.vertical, 10)
        .background(Color.backgroundSecondary.opacity(0.5))
    }

    @ViewBuilder
    private func singleStoryContent(_ story: Story) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let author = story.author {
                HStack(spacing: 8) {
                    Text("Chapter 1")
                        .font(.caption.bold())
                        .foregroundStyle(Color.accentWarm)
                    Text("by \(author.displayName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Text(story.content)
                .font(.storyBody())
                .lineSpacing(Typography.storyReadingLineSpacing)
        }
    }

    @ViewBuilder
    private func fullScreenPhotoView(url: URL, altText: String) -> some View {
        ZStack {
            Color.black.ignoresSafeArea()

            KFImage(url)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .accessibilityLabel(altText)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                showFullScreenPhoto = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding()
            }
        }
    }

    @ViewBuilder
    private func relatedStoryCard(_ story: Story) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(story.content)
                .font(.caption)
                .lineLimit(4)
                .foregroundStyle(.primary)

            if let author = story.author {
                Text(author.displayName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 160)
        .padding(12)
        .background(Color.backgroundSecondary)
        .cardShape()
    }
}
