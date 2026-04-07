import SwiftUI
import AuthenticationServices
import Supabase

@Observable
final class AuthViewModel {
    var isLoading = false
    var errorMessage: String?

    private let supabase = SupabaseClientManager.shared.client

    @MainActor
    func signInWithApple(credential: ASAuthorizationAppleIDCredential, appState: AppState) async {
        isLoading = true
        errorMessage = nil

        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            errorMessage = String(localized: "Failed to get Apple ID token")
            isLoading = false
            return
        }

        do {
            let session = try await supabase.auth.signInWithIdToken(
                credentials: .init(
                    provider: .apple,
                    idToken: tokenString
                )
            )

            if let fullName = credential.fullName {
                let name = [fullName.givenName, fullName.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")

                if !name.isEmpty {
                    try? await supabase
                        .from("users")
                        .update(["display_name": name, "updated_at": ISO8601DateFormatter().string(from: Date())])
                        .eq("id", value: session.user.id)
                        .execute()
                }
            }

            await appState.loadUser(id: session.user.id)
            appState.hasCompletedOnboarding = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    @MainActor
    func signInWithEmail(email: String, password: String, appState: AppState) async {
        isLoading = true
        errorMessage = nil

        do {
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            await appState.loadUser(id: session.user.id)
            appState.hasCompletedOnboarding = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    @MainActor
    func signUpWithEmail(email: String, password: String, appState: AppState) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password
            )
            if let session = response.session {
                await appState.loadUser(id: session.user.id)
                appState.hasCompletedOnboarding = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    @MainActor
    func continueAsGuest(appState: AppState) async {
        isLoading = true
        do {
            let session = try await supabase.auth.signInAnonymously()
            await appState.loadUser(id: session.user.id)
            appState.hasCompletedOnboarding = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// Skip nickname during sign-in from profile (already has one)
    @MainActor
    func signInFromProfile(email: String, password: String, appState: AppState) async {
        await signInWithEmail(email: email, password: password, appState: appState)
    }
}
