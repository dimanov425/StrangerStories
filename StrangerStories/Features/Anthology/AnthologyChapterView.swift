import SwiftUI
import Kingfisher

struct AnthologyChapterView: View {
    let photoId: UUID
    @State private var viewModel = AnthologyChapterViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Photo hero
                if let photo = viewModel.photo, let url = photo.publicURL {
                    ZStack(alignment: .bottomLeading) {
                        KFImage(url)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxHeight: 300)
                            .clipped()

                        Text("\(photo.storyCount) strangers wrote about this place")
                            .font(.subheadline)
                            .padding(12)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .padding(Spacing.standardMargin)
                    }
                    .accessibilityLabel(photo.altText)
                }

                // Stories
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else {
                    LazyVStack(alignment: .leading, spacing: Spacing.sectionSpacing) {
                        ForEach(viewModel.stories) { story in
                            NavigationLink(value: story.id) {
                                chapterStoryRow(story)
                            }
                            .buttonStyle(.plain)

                            Divider()
                        }
                    }
                    .padding(.horizontal, Spacing.standardMargin)
                    .padding(.top, Spacing.sectionSpacing)
                }
            }
        }
        .background(Color.backgroundPrimary)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadChapter(photoId: photoId)
        }
        .navigationDestination(for: UUID.self) { storyId in
            StoryDetailView(storyId: storyId)
        }
    }

    @ViewBuilder
    private func chapterStoryRow(_ story: Story) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(story.content)
                .font(.storyBody())
                .lineSpacing(Typography.storyReadingLineSpacing)
                .readableWidth()
                .foregroundStyle(.primary)

            HStack {
                if let author = story.author {
                    Text(author.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let avg = story.avgRating {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(Color.accentWarm)
                        Text(String(format: "%.1f", avg))
                    }
                    .font(.caption)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
