import SwiftUI
import Kingfisher

struct SubmissionConfirmView: View {
    let viewModel: WriteViewModel
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isTextRevealed = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.sectionSpacing) {
                    // Photo thumbnail
                    if let photo = viewModel.photo, let url = photo.publicURL {
                        KFImage(url)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: Spacing.avatarLarge, height: Spacing.avatarLarge)
                            .cardShape()
                    }

                    Text("Your raw story")
                        .font(.headline)

                    // Story text with reveal animation
                    Text(viewModel.storyText)
                        .font(.storyBody())
                        .lineSpacing(Typography.storyReadingLineSpacing)
                        .readableWidth()
                        .opacity(isTextRevealed ? 1 : 0)
                        .offset(y: isTextRevealed ? 0 : 20)

                    // Stats
                    HStack(spacing: 24) {
                        Label("\(viewModel.wordCount) words", systemImage: "textformat.size")
                        Label(timeTaken, systemImage: "clock")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    if let photo = viewModel.photo {
                        Text("\(photo.storyCount) strangers also wrote about this place")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 12) {
                        Button {
                            onDismiss()
                        } label: {
                            Text("Read & Rate Others")
                                .frame(maxWidth: 280)
                                .frame(height: Spacing.minTapTarget)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.accentWarm)

                        Button("Write Another") {
                            onDismiss()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(Spacing.standardMargin)
            }
            .background(Color.backgroundPrimary)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.8)) {
                isTextRevealed = true
            }
        }
    }

    private var timeTaken: String {
        let elapsed = 180 - Int(viewModel.timeRemaining)
        let minutes = elapsed / 60
        let seconds = elapsed % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}
