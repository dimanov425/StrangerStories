import SwiftUI

/// Manages the full writing session flow: photo reveal → writing → submission
struct WritingSessionCoordinator: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = WriteViewModel()

    var body: some View {
        Group {
            switch viewModel.phase {
            case .loading:
                ProgressView("Finding your photo...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.backgroundPrimary)

            case .reveal:
                PhotoRevealView(viewModel: viewModel)

            case .writing:
                WritingSessionView(viewModel: viewModel)

            case .submitted:
                SubmissionConfirmView(viewModel: viewModel) {
                    dismiss()
                }
            }
        }
        .task {
            viewModel.currentUserId = appState.currentUser?.id
            await viewModel.loadPhoto()
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
}
