import SwiftUI
import Kingfisher

struct WriteTabView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = WriteTabViewModel()
    @State private var showWritingSession = false
    @State private var challengePhotoId: UUID?

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sectionSpacing) {
                Spacer(minLength: 20)

                if viewModel.streakDays > 0 {
                    streakBanner
                }

                if viewModel.isLoading {
                    ProgressView()
                        .frame(height: 200)
                } else if let challenge = viewModel.challenge {
                    dailyChallengeCard(challenge)
                } else {
                    randomPhotoFallback
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, Spacing.standardMargin)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Write")
        .fullScreenCover(isPresented: $showWritingSession) {
            WritingSessionCoordinator(challengePhotoId: challengePhotoId)
        }
        .task {
            let streak = appState.currentUser?.streakDays ?? 0
            await viewModel.load(streakDays: streak)
        }
    }

    // MARK: - Streak Banner

    private var streakBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .foregroundStyle(.orange)
            Text("\(viewModel.streakDays)-day streak")
                .font(.subheadline.bold())
            Spacer()
            if appState.currentUser?.hasStreakFreeze == true {
                HStack(spacing: 4) {
                    Image(systemName: "snowflake")
                        .font(.caption2)
                        .foregroundStyle(.cyan)
                    Text("Freeze ready")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Keep it going!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(Color.orange.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: Spacing.cardCornerRadius, style: .continuous))
    }

    // MARK: - Daily Challenge Card

    @ViewBuilder
    private func dailyChallengeCard(_ challenge: DailyChallenge) -> some View {
        VStack(spacing: 20) {
            // Teaser photo
            if let url = viewModel.challengePhotoURL {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 220)
                    .overlay {
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.6)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                    }
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Today's Challenge")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text("\(viewModel.storyCount) strangers wrote so far")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .padding(Spacing.standardMargin)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: Spacing.cardCornerRadius, style: .continuous))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: Spacing.cardCornerRadius, style: .continuous)
                        .fill(Color.backgroundSecondary)
                        .frame(height: 180)
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("Today's Challenge")
                            .font(.headline)
                    }
                }
            }

            // Countdown
            HStack {
                Image(systemName: "clock")
                    .foregroundStyle(Color.accentWarm)
                Text("Ends in")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(viewModel.timeUntilMidnight, style: .timer)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            // CTAs
            VStack(spacing: 12) {
                Button {
                    challengePhotoId = challenge.photoId
                    showWritingSession = true
                } label: {
                    Label("Write Today's Challenge", systemImage: "pencil.line")
                        .font(.headline)
                        .frame(maxWidth: 280)
                        .frame(height: Spacing.minTapTarget)
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentWarm)

                Button {
                    challengePhotoId = nil
                    showWritingSession = true
                } label: {
                    Text("Random Photo Instead")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Fallback (no daily challenge)

    private var randomPhotoFallback: some View {
        VStack(spacing: Spacing.sectionSpacing) {
            Image(systemName: "pencil.line")
                .font(.system(size: 72))
                .foregroundStyle(Color.accentWarm)
                .symbolRenderingMode(.hierarchical)

            Text("Ready to write?")
                .font(.title.bold())

            Text("A random photo will appear.\nYou have 3 minutes to write a story.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                challengePhotoId = nil
                showWritingSession = true
            } label: {
                Label("Start Writing", systemImage: "pencil.line")
                    .font(.headline)
                    .frame(maxWidth: 280)
                    .frame(height: Spacing.minTapTarget)
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentWarm)
        }
    }
}
