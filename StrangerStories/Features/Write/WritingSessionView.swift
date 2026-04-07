import SwiftUI
import Kingfisher

struct WritingSessionView: View {
    @Bindable var viewModel: WriteViewModel
    @FocusState private var isEditorFocused: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Photo section — shrinks when keyboard appears
                photoSection(
                    height: keyboardHeight > 0
                        ? geometry.size.height * 0.15
                        : geometry.size.height * 0.35
                )

                // Timer bar
                timerBar

                // Editor
                editorSection

                // Bottom bar (word count + submit)
                bottomBar
            }
        }
        .background(Color.backgroundPrimary)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation(.easeOut(duration: 0.25)) {
                    keyboardHeight = frame.height
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeOut(duration: 0.25)) {
                keyboardHeight = 0
            }
        }
        .onAppear {
            isEditorFocused = true
        }
    }

    @ViewBuilder
    private func photoSection(height: CGFloat) -> some View {
        if let photo = viewModel.photo, let url = photo.publicURL {
            KFImage(url)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: height)
                .clipped()
                .overlay(alignment: .topTrailing) {
                    Text(viewModel.formattedTime)
                        .font(.timerDisplay)
                        .foregroundStyle(.white)
                        .shadow(radius: 4)
                        .padding(Spacing.standardMargin)
                        .accessibilityLabel("\(Int(viewModel.timeRemaining)) seconds remaining")
                }
                .accessibilityLabel(photo.altText)
        }
    }

    private var timerBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.backgroundSecondary)

                Rectangle()
                    .fill(viewModel.isInFinal30Seconds ? Color.orange : Color.accentWarm)
                    .frame(width: geo.size.width * viewModel.timerProgress)
            }
        }
        .frame(height: 4)
        .background(.ultraThinMaterial)
    }

    private var editorSection: some View {
        TextEditor(text: $viewModel.storyText)
            .font(.mono())
            .scrollContentBackground(.hidden)
            .padding(.horizontal, Spacing.standardMargin)
            .padding(.top, Spacing.compactMargin)
            .focused($isEditorFocused)
            .accessibilityLabel(String(localized: "Story editor"))
            .accessibilityHint(String(localized: "Write your story here"))
    }

    private var bottomBar: some View {
        HStack {
            Text("\(viewModel.wordCount) words")
                .font(.caption)
                .foregroundStyle(.tertiary)

            if viewModel.isSaving {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
                    .symbolEffect(.pulse)
            }

            Spacer()

            Button("Submit Early") {
                viewModel.submitStory()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(.horizontal, Spacing.standardMargin)
        .padding(.vertical, Spacing.compactMargin)
        .background(.bar)
    }
}
