import SwiftUI
import Kingfisher

struct PhotoRevealView: View {
    @Bindable var viewModel: WriteViewModel
    @State private var isRevealed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let photo = viewModel.photo, let url = photo.publicURL {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                    .opacity(isRevealed ? 1 : 0)
                    .accessibilityLabel(photo.altText)
            }

            // Bottom overlay
            VStack {
                Spacer()

                VStack(spacing: 20) {
                    Button {
                        viewModel.beginWriting()
                    } label: {
                        Text("Begin Writing")
                            .font(.headline)
                            .frame(maxWidth: 280)
                            .frame(height: Spacing.minTapTarget)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentWarm)
                    .opacity(isRevealed ? 1 : 0)

                    if let photo = viewModel.photo {
                        Text("Photo by \(photo.photographer)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(Spacing.standardMargin)
                .padding(.bottom, 20)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, Spacing.standardMargin)
                .padding(.bottom, 40)
            }

            // Skip button (top-right)
            if !viewModel.hasSkipped {
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            Task { await viewModel.skipPhoto() }
                        } label: {
                            Label("Skip", systemImage: "arrow.forward")
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.ultraThinMaterial, in: Capsule())
                        }
                        .padding(.trailing, Spacing.standardMargin)
                        .padding(.top, 60)
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            withAnimation(reduceMotion ? .none : .easeIn(duration: 2)) {
                isRevealed = true
            }
        }
    }
}
