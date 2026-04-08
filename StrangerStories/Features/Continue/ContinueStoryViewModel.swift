import SwiftUI
import Combine

@MainActor @Observable
final class ContinueStoryViewModel {
    var story: Story?
    var chapters: [Chapter] = []
    var storyText = ""
    var phase: ContinuePhase = .context
    var currentUserId: UUID?
    var markAsEnding = false
    var errorMessage: String?

    // Timer
    var timeRemaining: TimeInterval = 180
    var timerProgress: Double = 1.0
    var isTimerRunning = false

    // UI
    var isSaving = false
    var lastSaveTime: Date?

    private let chapterRepo = ChapterRepository()
    private var timerCancellable: AnyCancellable?
    private var sessionStartedAt: Date?
    private let totalTime: TimeInterval = 180

    var wordCount: Int { storyText.split(separator: " ").count }

    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var isInFinal30Seconds: Bool { timeRemaining <= 30 && timeRemaining > 0 }

    var nextChapterNumber: Int { (chapters.last?.chapterNumber ?? 0) + 1 }

    var canMarkAsEnding: Bool {
        guard let story else { return false }
        return (story.chapterCount ?? 1) >= 1
    }

    func loadChapters() async {
        guard let story else { return }
        do {
            chapters = try await chapterRepo.fetchChapters(storyId: story.id)
        } catch {
            errorMessage = "Could not load chapters"
        }
    }

    func beginWriting() {
        sessionStartedAt = Date()
        timeRemaining = totalTime
        timerProgress = 1.0
        phase = .writing
        isTimerRunning = true
        HapticManager.shared.timerStart()

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.timerTick() }
    }

    private func timerTick() {
        guard isTimerRunning, let sessionStartedAt else { return }
        let elapsed = Date().timeIntervalSince(sessionStartedAt)
        timeRemaining = max(0, totalTime - elapsed)
        timerProgress = timeRemaining / totalTime
        if timeRemaining <= 30 && Int(timeRemaining) % 10 == 0 && timeRemaining > 0 {
            HapticManager.shared.timerWarningPulse()
        }
        if timeRemaining <= 0 {
            timerProgress = 0
            submitChapter()
        }
    }

    func submitChapter() {
        guard isTimerRunning else { return }
        isTimerRunning = false
        timerCancellable?.cancel()
        HapticManager.shared.storySubmitted()

        Task {
            guard let story, let userId = currentUserId else { return }
            let keywords = extractKeywords(from: storyText)
            do {
                _ = try await chapterRepo.submitChapter(
                    storyId: story.id,
                    userId: userId,
                    chapterNumber: nextChapterNumber,
                    content: storyText,
                    keywords: keywords,
                    isEnding: markAsEnding,
                    startedAt: sessionStartedAt ?? Date(),
                    submittedAt: Date()
                )
                phase = .submitted
            } catch {
                errorMessage = "Failed to submit chapter: \(error.localizedDescription)"
            }
        }
    }

    private func extractKeywords(from text: String) -> [String] {
        let words = text.lowercased()
            .components(separatedBy: .alphanumerics.inverted)
            .filter { $0.count > 4 }
        let stopWords: Set<String> = [
            "about", "after", "again", "being", "could", "every", "first",
            "found", "going", "house", "would", "which", "their", "there",
            "these", "those", "three", "under", "where", "while", "still",
            "never", "other", "should", "before", "through", "because"
        ]
        var seen = Set<String>()
        var keywords: [String] = []
        for word in words where !stopWords.contains(word) && seen.insert(word).inserted {
            keywords.append(word)
            if keywords.count >= 5 { break }
        }
        return keywords
    }
}

enum ContinuePhase {
    case context, writing, submitted
}
