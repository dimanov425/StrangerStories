import SwiftUI
import Kingfisher

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = ProfileViewModel()
    @State private var showEditProfile = false

    @State private var showSignIn = false

    var body: some View {
        Group {
            if appState.isGuest {
                guestView
            } else if viewModel.isLoading && viewModel.user == nil {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let user = viewModel.user {
                profileContent(user)
            } else {
                loggedInButNoProfile
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .task {
            if let userId = appState.currentUser?.id {
                await viewModel.loadProfile(userId: userId)
            }
        }
        .fullScreenCover(isPresented: $showSignIn) {
            NavigationStack {
                SignInView()
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cancel") { showSignIn = false }
                        }
                    }
            }
        }
    }

    private var guestView: some View {
        ContentUnavailableView {
            Label("Sign in to see your profile", systemImage: "person.circle")
        } description: {
            Text("Your stories, stats, and achievements appear here.")
        } actions: {
            Button("Sign In") {
                showSignIn = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentWarm)
        }
    }

    private var loggedInButNoProfile: some View {
        VStack(spacing: 20) {
            ContentUnavailableView {
                Label("Profile not loaded", systemImage: "person.crop.circle.badge.exclamationmark")
            } description: {
                Text("We couldn't load your profile. You can try again or sign out.")
            }

            Button("Retry") {
                if let userId = appState.currentUser?.id {
                    Task { await viewModel.loadProfile(userId: userId) }
                }
            }
            .buttonStyle(.bordered)

            Button("Sign Out", role: .destructive) {
                Task { await appState.signOut() }
            }
        }
    }

    @ViewBuilder
    private func profileContent(_ user: AppUser) -> some View {
        List {
            // Header section
            Section {
                VStack(spacing: 12) {
                    Circle()
                        .fill(Color.backgroundTertiary)
                        .frame(width: Spacing.avatarLarge, height: Spacing.avatarLarge)
                        .overlay {
                            Text(String(user.displayName.prefix(1)).uppercased())
                                .font(.title.bold())
                        }

                    Text(user.displayName)
                        .font(.title2.bold())

                    if let bio = user.bio, !bio.isEmpty {
                        Text(bio)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }

            // Stats
            Section {
                statsRow(user)
                    .listRowBackground(Color.clear)
            }

            // My Stories
            Section("My Stories") {
                if viewModel.stories.isEmpty {
                    Text("No stories yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.stories) { story in
                        NavigationLink(value: story.id) {
                            StoryCardView(story: story)
                        }
                    }
                }
            }

            // Bookmarks
            Section("Bookmarks") {
                if viewModel.bookmarks.isEmpty {
                    Text("No bookmarks yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.bookmarks) { bookmark in
                        if let story = bookmark.story {
                            NavigationLink(value: story.id) {
                                StoryCardView(story: story)
                            }
                        }
                    }
                }
            }

            // Achievements
            if !viewModel.achievements.isEmpty {
                Section("Achievements") {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 70))
                    ], spacing: 16) {
                        ForEach(viewModel.achievements) { achievement in
                            achievementBadge(achievement)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }

            // Settings
            Section("Settings") {
                NavigationLink("Edit Profile") {
                    editProfileView
                }

                Button("Sign Out") {
                    Task { await appState.signOut() }
                }

                Button("Delete Account", role: .destructive) {
                    viewModel.showDeleteConfirmation = true
                }
            }
        }
        .listStyle(.insetGrouped)
        .confirmationDialog(
            "Delete your account?",
            isPresented: $viewModel.showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Everything", role: .destructive) {
                guard let userId = appState.currentUser?.id else { return }
                Task { await viewModel.deleteAccount(userId: userId, appState: appState) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all your stories, ratings, and profile data. This cannot be undone.")
        }
        .navigationDestination(for: UUID.self) { storyId in
            StoryDetailView(storyId: storyId)
        }
    }

    @ViewBuilder
    private func statsRow(_ user: AppUser) -> some View {
        HStack(spacing: 0) {
            statItem(value: "\(user.storiesCount)", label: "Stories", symbol: "pencil.line")
            Divider().frame(height: 30)
            statItem(
                value: user.avgRating.map { String(format: "%.1f", $0) } ?? "—",
                label: "Avg Rating",
                symbol: "star.fill"
            )
            Divider().frame(height: 30)
            statItem(value: "\(user.streakDays)", label: "Streak", symbol: "flame")
            Divider().frame(height: 30)
            statItem(value: "\(viewModel.totalWords)", label: "Words", symbol: "textformat.size")
        }
    }

    @ViewBuilder
    private func statItem(value: String, label: String, symbol: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.caption)
                    .foregroundStyle(Color.accentWarm)
                Text(value)
                    .font(.headline)
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func achievementBadge(_ achievement: Achievement) -> some View {
        VStack(spacing: 4) {
            Image(systemName: achievement.type.symbolName)
                .font(.title2)
                .foregroundStyle(Color.accentWarm)
                .frame(width: 50, height: 50)
                .background(Color.backgroundSecondary)
                .clipShape(Circle())

            Text(achievement.type.displayName)
                .font(.caption2)
                .lineLimit(1)
        }
    }

    private var editProfileView: some View {
        Form {
            Section("Display Name") {
                HStack {
                    TextField("Display Name", text: $viewModel.editDisplayName)
                        .textContentType(.name)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onChange(of: viewModel.editDisplayName) { _, _ in
                            viewModel.nameAvailable = nil
                            viewModel.nameError = nil
                        }

                    if viewModel.isCheckingName {
                        ProgressView().controlSize(.small)
                    } else if let ok = viewModel.nameAvailable {
                        Image(systemName: ok ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(ok ? .green : .red)
                    }
                }

                if let err = viewModel.nameError {
                    Text(err).font(.caption).foregroundStyle(.red)
                } else if viewModel.nameAvailable == false {
                    Text("Already taken").font(.caption).foregroundStyle(.red)
                }

                Button("Check availability") {
                    Task { await viewModel.checkNameAvailability() }
                }
                .font(.caption)
                .disabled(viewModel.editDisplayName.count < 3 || viewModel.isCheckingName)
            }

            Section("Bio") {
                TextEditor(text: $viewModel.editBio)
                    .frame(minHeight: 80)
                Text("\(viewModel.editBio.count)/200")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    guard let userId = appState.currentUser?.id else { return }
                    Task {
                        await viewModel.saveProfileWithUniqueName(userId: userId)
                        if let user = viewModel.user {
                            appState.currentUser = user
                        }
                    }
                }
                .disabled(viewModel.editDisplayName.count < 3 || viewModel.editBio.count > 200 || viewModel.isSaving)
            }
        }
    }
}
