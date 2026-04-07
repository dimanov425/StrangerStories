import AppIntents

struct WriteStoryIntent: AppIntent {
    static var title: LocalizedStringResource = "Write a Stranger Story"
    static var description = IntentDescription("Open Stranger Stories and start a new writing session")

    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        // The app handles deep linking via URL scheme
        return .result()
    }
}

struct WriteStoryShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: WriteStoryIntent(),
            phrases: [
                "Write a story in \(.applicationName)",
                "Start writing in \(.applicationName)",
                "Open \(.applicationName) to write",
            ],
            shortTitle: "Write a Story",
            systemImageName: "pencil.line"
        )
    }
}
