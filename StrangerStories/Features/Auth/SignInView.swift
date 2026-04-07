import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var showEmailForm = false

    var body: some View {
        VStack(spacing: Spacing.sectionSpacing) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "book.and.wreath.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.accentWarm)

                Text("Stranger Stories")
                    .font(.largeTitle.bold())

                Text("Write stories inspired by places.\n3 minutes. No edits. Raw imagination.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 16) {
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.email, .fullName]
                } onCompletion: { result in
                    handleAppleSignIn(result)
                }
                .signInWithAppleButtonStyle(.white)
                .frame(height: Spacing.minTapTarget)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                if showEmailForm {
                    emailFormSection
                } else {
                    Button {
                        withAnimation { showEmailForm = true }
                    } label: {
                        Text("Sign in with Email")
                            .frame(maxWidth: .infinity)
                            .frame(height: Spacing.minTapTarget)
                    }
                    .buttonStyle(.bordered)
                }

                Button {
                    Task { await viewModel.continueAsGuest(appState: appState) }
                } label: {
                    Text("Continue as Guest")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, Spacing.standardMargin)

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }
        }
        .padding(.bottom, 40)
        .background(Color.backgroundPrimary)
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .tint(.white)
            }
        }
    }

    @ViewBuilder
    private var emailFormSection: some View {
        VStack(spacing: 12) {
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textContentType(isSignUp ? .newPassword : .password)
                .textFieldStyle(.roundedBorder)

            Button {
                Task {
                    if isSignUp {
                        await viewModel.signUpWithEmail(email: email, password: password, appState: appState)
                    } else {
                        await viewModel.signInWithEmail(email: email, password: password, appState: appState)
                    }
                }
            } label: {
                Text(isSignUp ? "Create Account" : "Sign In")
                    .frame(maxWidth: .infinity)
                    .frame(height: Spacing.minTapTarget)
            }
            .buttonStyle(.borderedProminent)
            .disabled(email.isEmpty || password.count < 6)

            Button(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up") {
                isSignUp.toggle()
            }
            .font(.caption)
        }
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                Task {
                    await viewModel.signInWithApple(credential: credential, appState: appState)
                }
            }
        case .failure(let error):
            viewModel.errorMessage = error.localizedDescription
        }
    }
}
