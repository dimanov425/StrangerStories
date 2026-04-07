import SwiftUI
import Kingfisher

struct StoryCardView: View {
    let story: Story

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Photo thumbnail
            if let photo = story.photo, let url = photo.publicURL {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: Spacing.photoThumbnail, height: Spacing.photoThumbnail)
                    .cardShape()
                    .accessibilityLabel(photo.altText)
            } else {
                RoundedRectangle(cornerRadius: Spacing.cardCornerRadius, style: .continuous)
                    .fill(Color.backgroundSecondary)
                    .frame(width: Spacing.photoThumbnail, height: Spacing.photoThumbnail)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(story.content)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                HStack(spacing: 6) {
                    if let author = story.author {
                        Text(author.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    // Chapter count
                    let chapters = story.chapterCount ?? 1
                    if chapters > 1 {
                        Label("\(chapters) ch", systemImage: "book.pages")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    if let avg = story.avgRating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(Color.accentWarm)
                            Text(String(format: "%.1f", avg))
                                .font(.caption2)
                        }
                    }

                    Spacer()

                    // Chain status badge
                    if story.chainStatus == .completed {
                        Text("Done")
                            .font(.caption2.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundStyle(.orange)
                            .clipShape(Capsule())
                    } else if (story.chapterCount ?? 1) > 0 {
                        Text("Open")
                            .font(.caption2.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .foregroundStyle(.green)
                            .clipShape(Capsule())
                    }

                    Text(story.createdAt, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}
