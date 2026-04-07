import SwiftUI
import Kingfisher

struct ContinueWritingSessionView: View {
    @Bindable var viewModel: ContinueStoryViewModel
    @FocusState private var isEditorFocused: Bool
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                photoSection(
                    height: keyboardHeight > 0
                        ? geometry.size.height * 0.12
                        : geometry.size.height * 0.25
                )

                timerBar

                editorSection

                bottomBar
            }
        }
        .background(Color.backgroundPrimary)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation(.easeOut(duration: 0.25)) { keyboardHeight = frame.height }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeOut(duration: 0.25)) { keyboardHeight = 0 }
        }
        .onAppear { isEditorFocused = true }
    }

    @ViewBuilder
    private func photoSection(height: CGFloat) -> some View {
        if let photo = viewModel.story?.photo, let url = photo.publicURL {
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
                }
        }
    }

    private var timerBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle().fill(Color.backgroundSecondary)
                Rectangle()
                    .fill(viewModel.isInFinal30Seconds ? Color.orange : Color.accentWarm)
                    .frame(width: geo.size.width * viewModel.timerProgress)
            }
        }
        .frame(height: 4)
    }

    private var editorSection: some View {
        TextEditor(text: $viewModel.storyText)
            .font(.mono())
            .scrollContentBackground(.hidden)
            .padding(.horizontal, Spacing.standardMargin)
            .padding(.top, Spacing.compactMargin)
            .focused($isEditorFocused)
    }

    private var bottomBar: some View {
        HStack {
            Text("\(viewModel.wordCount) words")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Spacer()

            if viewModel.canMarkAsEnding {
                Toggle(isOn: $viewModel.markAsEnding) {
                    Label("End Story", systemImage: "flag.checkered")
                        .font(.caption)
                }
                .toggleStyle(.button)
                .controlSize(.small)
                .tint(viewModel.markAsEnding ? .orange : .secondary)
            }

            Button("Submit") {
                viewModel.submitChapter()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(.horizontal, Spacing.standardMargin)
        .padding(.vertical, Spacing.compactMargin)
        .background(.bar)
    }
}
