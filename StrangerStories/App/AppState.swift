import SwiftUI
import Supabase

@MainActor @Observable
final class AppState {
    var isInitialized = false
    var hasCompletedOnboarding = false
    var needsNickname = false
    var currentUser: AppUser?
    var selectedTab: Tab = .feed
    var isAuthenticated: Bool { currentUser != nil }
    var isGuest: Bool { currentUser?.displayName == nil || currentUser?.email == nil }

    private let supabase = SupabaseClientManager.shared.client

    init() {
        Task { await initialize() }
    }

    func initialize() async {
        let session = try? await supabase.auth.session
        if let session {
            await loadUser(id: session.user.id)
            hasCompletedOnboarding = true
            checkNickname()
        }
        isInitialized = true
    }

    func loadUser(id: UUID) async {
        do {
            let user: AppUser = try await supabase
                .from("users")
                .select()
                .eq("id", value: id)
                .single()
                .execute()
                .value
            currentUser = user
            checkNickname()
        } catch {
            currentUser = nil
        }
    }

    func signOut() async {
        try? await supabase.auth.signOut()
        currentUser = nil
        hasCompletedOnboarding = false
        needsNickname = false
    }

    private func checkNickname() {
        guard let name = currentUser?.displayName else { return }
        // Only trigger for auto-generated names: "Stranger" exact or "Stranger_xxxx"
        let lower = name.lowercased()
        needsNickname = lower == "stranger"
            || (lower.hasPrefix("stranger_") && name.count <= 13)
    }
}
