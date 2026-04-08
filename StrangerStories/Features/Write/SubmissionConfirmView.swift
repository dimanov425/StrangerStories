import SwiftUI
import Kingfisher

struct SubmissionConfirmView: View {
    let viewModel: WriteViewModel
    let onDismiss: () -> Void

    @Environment(AppState.self) private var appState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isTextRevealed = false
    @State private var celebratingAchievement: Achievement?
    @State private var showWriteAnother = false

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

                    // Streak callout
                    if let streakDays = appState.currentUser?.streakDays, streakDays > 0 {
                        HStack(spacing: 8) {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(.orange)
                            Text("\(streakDays)-day streak!")
                                .font(.subheadline.bold())
                        }
                        .padding(10)
                        .background(Color.orange.opacity(0.12))
                        .clipShape(Capsule())
                    }

                    // Achievement badges earned this session
                    if !viewModel.newAchievements.isEmpty {
                        newAchievementsRow
                    }

                    // Action buttons
                    VStack(spacing: 12) {
                        Button {
                            appState.selectedTab = .feed
                            onDismiss()
                        } label: {
                            Text("Read & Rate Others")
                                .frame(maxWidth: 280)
                                .frame(height: Spacing.minTapTarget)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.accentWarm)

                        Button("Write Another") {
                            showWriteAnother = true
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
            .overlay {
                if let achievement = celebratingAchievement {
                    AchievementCelebrationView(achievement: achievement) {
                        celebratingAchievement = nil
                    }
                }
            }
            .fullScreenCover(isPresented: $showWriteAnother) {
                WritingSessionCoordinator()
            }
        }
        .onAppear {
            withAnimation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.8)) {
                isTextRevealed = true
            }
            if let first = viewModel.newAchievements.first {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    celebratingAchievement = first
                }
            }
        }
    }

    private var newAchievementsRow: some View {
        VStack(spacing: 8) {
            Text("New Achievements")
                .font(.caption.bold())
                .foregroundStyle(Color.accentWarm)

            HStack(spacing: 16) {
                ForEach(viewModel.newAchievements) { achievement in
                    VStack(spacing: 4) {
                        Image(systemName: achievement.type.symbolName)
                            .font(.title3)
                            .foregroundStyle(Color.accentWarm)
                            .frame(width: 44, height: 44)
                            .background(Color.accentWarm.opacity(0.15))
                            .clipShape(Circle())

                        Text(achievement.type.displayName)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: Spacing.cardCornerRadius, style: .continuous))
    }

    private var timeTaken: String {
        let elapsed = 180 - Int(viewModel.timeRemaining)
        let minutes = elapsed / 60
        let seconds = elapsed % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}
