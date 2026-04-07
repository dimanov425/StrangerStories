import SwiftUI
import Supabase

struct NicknamePickerView: View {
    @Environment(AppState.self) private var appState
    @State private var nickname = ""
    @State private var isChecking = false
    @State private var isAvailable: Bool?
    @State private var isClaiming = false
    @State private var errorMessage: String?
    @FocusState private var isFocused: Bool

    private let supabase = SupabaseClientManager.shared.client
    private let minLength = 3
    private let maxLength = 20

    private var isValid: Bool {
        nickname.count >= minLength && nickname.count <= maxLength
            && nickname.range(of: #"^[A-Za-z0-9_]+$"#, options: .regularExpression) != nil
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "person.text.rectangle")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.accentWarm)

                Text("Choose your name")
                    .font(.title.bold())

                Text("This is how other writers will see you.\nIt must be unique.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 8) {
                HStack {
                    TextField("e.g. NightOwlWriter", text: $nickname)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($isFocused)
                        .onChange(of: nickname) { _, newValue in
                            nickname = String(newValue.prefix(maxLength))
                            isAvailable = nil
                            errorMessage = nil
                        }

                    if isChecking {
                        ProgressView()
                            .controlSize(.small)
                    } else if let available = isAvailable {
                        Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(available ? .green : .red)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                HStack {
                    Text("\(nickname.count)/\(maxLength)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    if let available = isAvailable, !available {
                        Text("Already taken")
                            .font(.caption)
                            .foregroundStyle(.red)
                    } else if !nickname.isEmpty && !isValid {
                        Text("Letters, numbers, underscores only")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                .padding(.horizontal, 4)
            }

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Button {
                Task { await claimName() }
            } label: {
                HStack {
                    if isClaiming {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                    }
                    Text("Continue")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.accentWarm)
            .disabled(!isValid || isAvailable == false || isClaiming)

            Button("Check availability") {
                Task { await checkAvailability() }
            }
            .disabled(!isValid || isChecking)
            .font(.subheadline)

            Spacer()
        }
        .padding(.horizontal, 32)
        .background(Color.backgroundPrimary)
        .onAppear { isFocused = true }
    }

    private func checkAvailability() async {
        guard isValid else { return }
        isChecking = true
        defer { isChecking = false }

        do {
            let available: Bool = try await supabase.rpc("is_display_name_available", params: ["desired_name": nickname]).execute().value
            isAvailable = available
        } catch {
            errorMessage = "Could not check availability"
        }
    }

    private func claimName() async {
        guard isValid else { return }
        isClaiming = true
        defer { isClaiming = false }

        do {
            let success: Bool = try await supabase.rpc("claim_display_name", params: ["desired_name": nickname]).execute().value
            if success {
                if let userId = appState.currentUser?.id {
                    await appState.loadUser(id: userId)
                }
                appState.needsNickname = false
            } else {
                isAvailable = false
            }
        } catch {
            if "\(error)".contains("unique") {
                isAvailable = false
            } else {
                errorMessage = "Something went wrong. Try again."
            }
        }
    }
}
