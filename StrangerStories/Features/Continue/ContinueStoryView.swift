import SwiftUI
import Kingfisher
import Combine

struct ContinueStoryView: View {
    let story: Story
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ContinueStoryViewModel()

    var body: some View {
        Group {
            switch viewModel.phase {
            case .context:
                contextScreen
            case .writing:
                writingScreen
            case .submitted:
                submittedScreen
            }
        }
        .background(Color.backgroundPrimary)
        .task {
            viewModel.story = story
            viewModel.currentUserId = appState.currentUser?.id
            await viewModel.loadChapters()
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { dismiss() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Context Screen

    private var contextScreen: some View {
        VStack(spacing: 0) {
            // Photo hero
            if let photo = story.photo, let url = photo.publicURL {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Chain info header
                    HStack {
                        Label(
                            "\(viewModel.chapters.count) of \(story.maxChapters ?? 7) chapters",
                            systemImage: "book.pages"
                        )
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.accentWarm)

                        Spacer()

                        Text("Your turn!")
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.accentWarm.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)

                    // Previous chapters
                    ForEach(viewModel.chapters) { chapter in
                        ChapterCardView(chapter: chapter)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, 100)
            }

            // Start writing button
            VStack(spacing: 0) {
                Divider()
                Button {
                    viewModel.beginWriting()
                } label: {
                    Text("Start Writing")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.accentWarm)
                .padding()
            }
            .background(.bar)
        }
        .navigationTitle("Continue Story")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
            }
        }
    }

    // MARK: - Writing Screen

    private var writingScreen: some View {
        ContinueWritingSessionView(viewModel: viewModel)
    }

    // MARK: - Submitted Screen

    private var submittedScreen: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: viewModel.markAsEnding ? "flag.checkered" : "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.accentWarm)

            Text(viewModel.markAsEnding ? "Story Complete!" : "Chapter Submitted!")
                .font(.title.bold())

            Text(viewModel.markAsEnding
                 ? "You've written the final chapter. This story is now complete."
                 : "Chapter \(viewModel.nextChapterNumber) has been added to the chain.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text("\(viewModel.wordCount) words")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Spacer()

            Button("Done") { dismiss() }
                .buttonStyle(.borderedProminent)
                .tint(Color.accentWarm)
                .padding(.horizontal, 40)
        }
        .padding()
    }
}

// MARK: - Chapter Card

struct ChapterCardView: View {
    let chapter: Chapter

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Chapter \(chapter.chapterNumber)")
                    .font(.caption.bold())
                    .foregroundStyle(Color.accentWarm)

                if let author = chapter.author {
                    Text("by \(author.displayName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(chapter.createdAt, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Text(chapter.content)
                .font(.subheadline)
                .lineSpacing(4)

            if !chapter.keywords.isEmpty {
                HStack(spacing: 6) {
                    ForEach(chapter.keywords, id: \.self) { keyword in
                        Text(keyword)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.backgroundSecondary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .background(Color.backgroundSecondary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
