import SwiftUI

struct RatingStarsView: View {
    let currentRating: Int?
    let isOwnStory: Bool
    let onRate: ((Int) -> Void)?

    @State private var hoverRating: Int = 0

    var body: some View {
        if isOwnStory {
            Text("Your story")
                .font(.caption)
                .foregroundStyle(.secondary)
        } else if let rating = currentRating {
            starRow(filled: rating, interactive: false)
                .accessibilityElement()
                .accessibilityLabel("\(rating) out of 5 stars")
        } else {
            starRow(filled: hoverRating, interactive: true)
                .accessibilityElement()
                .accessibilityLabel("Rate this story")
                .accessibilityValue(hoverRating > 0 ? "\(hoverRating) out of 5 stars" : "Not rated")
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment:
                        let newRating = min(5, (hoverRating == 0 ? 1 : hoverRating + 1))
                        confirmRating(newRating)
                    case .decrement:
                        let newRating = max(1, hoverRating - 1)
                        confirmRating(newRating)
                    @unknown default:
                        break
                    }
                }
        }
    }

    @ViewBuilder
    private func starRow(filled: Int, interactive: Bool) -> some View {
        HStack(spacing: 8) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= filled ? "star.fill" : "star")
                    .font(.title2)
                    .foregroundStyle(index <= filled ? Color.accentWarm : Color.textTertiary)
                    .onTapGesture {
                        guard interactive else { return }
                        confirmRating(index)
                    }
            }
        }
    }

    private func confirmRating(_ rating: Int) {
        hoverRating = rating
        HapticManager.shared.starRatingTapped()
        onRate?(rating)
    }
}
