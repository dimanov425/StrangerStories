import SwiftUI
import Kingfisher

struct SwipeCardView: View {
    let story: Story
    let isTop: Bool
    let onSwipe: (Bool) -> Void

    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0

    private let swipeThreshold: CGFloat = 120

    var body: some View {
        VStack(spacing: 0) {
            // Photo
            if let photo = story.photo, let url = photo.publicURL {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 280)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.backgroundSecondary)
                    .frame(height: 280)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(.tertiary)
                    }
            }

            // Content preview
            VStack(alignment: .leading, spacing: 10) {
                Text(story.content)
                    .font(.subheadline)
                    .lineLimit(4)
                    .lineSpacing(3)

                Divider()

                HStack {
                    if let author = story.author {
                        Label(author.displayName, systemImage: "person.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Label("\(story.chapterCount ?? 1) chapters", systemImage: "book.pages")
                        .font(.caption)
                        .foregroundStyle(Color.accentWarm)
                }
            }
            .padding()
        }
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        .overlay {
            // Swipe indicator overlays
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.green, lineWidth: 4)
                    .opacity(max(0, Double(offset.width) / Double(swipeThreshold)))

                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.red, lineWidth: 4)
                    .opacity(max(0, Double(-offset.width) / Double(swipeThreshold)))

                // Like/skip labels
                if offset.width > 40 {
                    Text("WRITE!")
                        .font(.title.bold())
                        .foregroundStyle(.green)
                        .rotationEffect(.degrees(-15))
                        .padding(.leading, 30)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(min(1, Double(offset.width) / Double(swipeThreshold)))
                }
                if offset.width < -40 {
                    Text("SKIP")
                        .font(.title.bold())
                        .foregroundStyle(.red)
                        .rotationEffect(.degrees(15))
                        .padding(.trailing, 30)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .opacity(min(1, Double(-offset.width) / Double(swipeThreshold)))
                }
            }
        }
        .offset(offset)
        .rotationEffect(.degrees(rotation))
        .gesture(isTop ? dragGesture : nil)
        .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.7), value: offset)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = value.translation
                rotation = Double(value.translation.width) / 20
            }
            .onEnded { value in
                if value.translation.width > swipeThreshold {
                    withAnimation(.easeOut(duration: 0.3)) {
                        offset = CGSize(width: 500, height: 0)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onSwipe(true)
                    }
                } else if value.translation.width < -swipeThreshold {
                    withAnimation(.easeOut(duration: 0.3)) {
                        offset = CGSize(width: -500, height: 0)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onSwipe(false)
                    }
                } else {
                    offset = .zero
                    rotation = 0
                }
            }
    }
}
