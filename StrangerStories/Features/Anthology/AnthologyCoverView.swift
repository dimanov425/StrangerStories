import SwiftUI
import Kingfisher

struct AnthologyCoverView: View {
    @State private var viewModel = AnthologyViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.chapters.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.chapters.isEmpty {
                ContentUnavailableView(
                    "No stories yet",
                    systemImage: "book",
                    description: Text("The anthology grows as strangers write stories.")
                )
            } else {
                chapterList
            }
        }
        .navigationTitle("Anthology")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadChapters()
        }
        .refreshable {
            await viewModel.loadChapters()
        }
        .navigationDestination(for: Photo.ID.self) { photoId in
            AnthologyChapterView(photoId: photoId)
        }
    }

    private var chapterList: some View {
        List {
            // Cover header
            Section {
                VStack(spacing: 12) {
                    Text("The Stranger Stories\nAnthology")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)

                    Text("\(viewModel.chapters.reduce(0) { $0 + $1.storyCount }) stories by strangers")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sectionSpacing)
                .listRowBackground(Color.clear)
            }

            // Chapters
            Section("Chapters") {
                ForEach(viewModel.chapters) { photo in
                    NavigationLink(value: photo.id) {
                        chapterRow(photo)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    private func chapterRow(_ photo: Photo) -> some View {
        HStack(spacing: 12) {
            if let url = photo.publicURL {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: Spacing.photoChapterThumbnail, height: Spacing.photoChapterThumbnail)
                    .cardShape()
                    .accessibilityLabel(photo.altText)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(photo.storyCount) stories")
                    .font(.body)

                HStack(spacing: 4) {
                    ForEach(photo.moodTags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.backgroundTertiary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
