import SwiftUI

struct AchievementCelebrationView: View {
    let achievement: Achievement
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 20) {
                Image(systemName: achievement.type.symbolName)
                    .font(.system(size: 56))
                    .foregroundStyle(Color.accentWarm)
                    .symbolRenderingMode(.hierarchical)
                    .scaleEffect(isVisible ? 1 : 0.3)

                Text("Achievement Unlocked!")
                    .font(.title3.bold())

                Text(achievement.type.displayName)
                    .font(.headline)
                    .foregroundStyle(Color.accentWarm)

                Text(achievement.type.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("Continue") { dismiss() }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentWarm)
                    .padding(.top, 8)
            }
            .padding(32)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 40)
            .scaleEffect(isVisible ? 1 : 0.8)
            .opacity(isVisible ? 1 : 0)
        }
        .onAppear {
            HapticManager.shared.achievementUnlocked()
            withAnimation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.7)) {
                isVisible = true
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onDismiss()
        }
    }
}
