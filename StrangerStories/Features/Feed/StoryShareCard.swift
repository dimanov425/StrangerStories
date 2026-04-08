import SwiftUI
import Kingfisher

/// Branded card rendered as an image for sharing stories externally.
struct StoryShareCard: View {
    let story: Story

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Photo banner
            if let photo = story.photo, let url = photo.publicURL {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.backgroundSecondary)
                    .frame(height: 200)
            }

            // Story excerpt
            VStack(alignment: .leading, spacing: 12) {
                Text(story.content)
                    .font(.body)
                    .lineLimit(6)
                    .lineSpacing(4)

                Divider()

                HStack {
                    if let author = story.author {
                        Text("by \(author.displayName)")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("Stranger Stories")
                        .font(.caption.bold())
                        .foregroundStyle(Color.accentWarm)
                }
            }
            .padding(16)
        }
        .frame(width: 360)
        .background(Color.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.divider, lineWidth: 0.5)
        )
    }

    @MainActor
    static func renderImage(for story: Story) -> UIImage? {
        let card = StoryShareCard(story: story)
            .environment(\.colorScheme, .dark)

        let renderer = ImageRenderer(content: card)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
}

/// Transferable wrapper so ShareLink can share a UIImage.
struct ShareableStoryImage: Transferable {
    let image: UIImage
    let caption: String

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { item in
            guard let data = item.image.pngData() else {
                throw CocoaError(.fileWriteUnknown)
            }
            return data
        }
    }
}
