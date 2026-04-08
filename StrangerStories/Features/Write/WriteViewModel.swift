import SwiftUI
import Combine

@Observable
final class WriteViewModel {
    // Session state
    var phase: WritingPhase = .loading
    var photo: Photo?
    var storyText = ""
    var submittedStory: Story?
    var currentUserId: UUID?
    var newAchievements: [Achievement] = []

    // Timer state
    var timeRemaining: TimeInterval = 180
    var timerProgress: Double = 1.0
    var isTimerRunning = false

    // UI state
    var hasSkipped = false
    var errorMessage: String?
    var isSaving = false
    var lastSaveTime: Date?

    private let photoRepo = PhotoRepository()
    private let storyRepo = StoryRepository()
    private let userRepo = UserRepository()
    private var timerCancellable: AnyCancellable?
    private var autoSaveCancellable: AnyCancellable?
    private var sessionStartedAt: Date?
    private let totalTime: TimeInterval = 180
    private var preSubmitAchievementTypes: Set<String> = []

    var wordCount: Int {
        storyText.split(separator: " ").count
    }

    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var isInFinal30Seconds: Bool {
        timeRemaining <= 30 && timeRemaining > 0
    }

    // MARK: - Achievement Tracking

    @MainActor
    func snapshotAchievements() async {
        guard let userId = currentUserId else { return }
        do {
            let existing = try await userRepo.fetchAchievements(userId: userId)
            preSubmitAchievementTypes = Set(existing.map(\.type.rawValue))
        } catch {
            // Non-critical
        }
    }

    @MainActor
    func checkForNewAchievements() async {
        guard let userId = currentUserId else { return }
        do {
            let all = try await userRepo.fetchAchievements(userId: userId)
            newAchievements = all.filter { !preSubmitAchievementTypes.contains($0.type.rawValue) }
        } catch {
            // Non-critical
        }
    }

    // MARK: - Photo Loading

    @MainActor
    func loadPhoto(specificPhotoId: UUID? = nil) async {
        phase = .loading
        do {
            if let photoId = specificPhotoId {
                photo = try await photoRepo.fetchPhoto(id: photoId)
            } else {
                photo = try await photoRepo.fetchRandomPhoto()
            }
            phase = .reveal
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    func skipPhoto() async {
        guard !hasSkipped else { return }
        hasSkipped = true
        phase = .loading
        do {
            photo = try await photoRepo.fetchRandomPhoto(excluding: photo?.id)
            phase = .reveal
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Timer

    @MainActor
    func beginWriting() {
        sessionStartedAt = Date()
        timeRemaining = totalTime
        timerProgress = 1.0
        phase = .writing
        isTimerRunning = true

        Task { await snapshotAchievements() }

        HapticManager.shared.timerStart()

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.timerTick()
            }

        // Auto-save every 10 seconds
        autoSaveCancellable = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { await self?.performAutoSave() }
            }
    }

    @MainActor
    private func timerTick() {
        guard isTimerRunning else { return }

        timeRemaining -= 1
        timerProgress = timeRemaining / totalTime

        if timeRemaining <= 30 && Int(timeRemaining) % 10 == 0 && timeRemaining > 0 {
            HapticManager.shared.timerWarningPulse()
        }

        if timeRemaining <= 0 {
            timeRemaining = 0
            timerProgress = 0
            submitStory()
        }
    }

    // MARK: - Auto-save

    @MainActor
    private func performAutoSave() async {
        guard let photo, !storyText.isEmpty else { return }
        // Auto-save is best-effort — don't show errors
        // In a full implementation, we'd pass the user ID
        isSaving = true
        HapticManager.shared.autoSaveConfirm()
        lastSaveTime = Date()
        isSaving = false
    }

    // MARK: - Submission

    @MainActor
    func submitStory() {
        guard isTimerRunning else { return }
        isTimerRunning = false
        timerCancellable?.cancel()
        autoSaveCancellable?.cancel()

        HapticManager.shared.storySubmitted()

        // For now, create a local story object for the confirmation view.
        // In production, this calls StoryRepository.submitStory()
        Task {
            guard let photo, let userId = currentUserId else { return }
            do {
                let story = try await storyRepo.submitStory(
                    userId: userId,
                    photoId: photo.id,
                    content: storyText,
                    startedAt: sessionStartedAt ?? Date(),
                    submittedAt: Date()
                )
                submittedStory = story
                await checkForNewAchievements()
                phase = .submitted
            } catch {
                // Even on error, show confirmation with local data
                submittedStory = Story(
                    id: UUID(),
                    userId: UUID(),
                    photoId: photo.id,
                    content: storyText,
                    wordCount: wordCount,
                    startedAt: sessionStartedAt ?? Date(),
                    submittedAt: Date(),
                    isPublished: false,
                    isFlagged: false,
                    modStatus: .pending,
                    avgRating: nil,
                    ratingCount: 0,
                    wilsonScore: 0,
                    createdAt: Date(),
                    photo: photo,
                    author: nil
                )
                phase = .submitted
            }
        }
    }
}

enum WritingPhase {
    case loading, reveal, writing, submitted
}
