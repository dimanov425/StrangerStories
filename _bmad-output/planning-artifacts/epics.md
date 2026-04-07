---
stepsCompleted: [1, 2, 3, 4]
inputDocuments:
  - prd.md
  - architecture.md
  - ux-design-specification.md
status: complete
platform: 'ios-native'
---

# Stranger Stories — Epic Breakdown (iOS)

## Overview

This document provides the complete epic and story breakdown for Stranger Stories as a native iOS application (SwiftUI, iOS 17+). Each story is self-contained and can be developed independently within its epic. Admin features (photo management, moderation queue) remain as a lightweight web dashboard — not part of the iOS app.

## Requirements Inventory

### Functional Requirements

- FR-AUTH-1 through FR-AUTH-5: Authentication & User Management
- FR-PHOTO-1 through FR-PHOTO-7: Photo Management
- FR-WRITE-1 through FR-WRITE-10: Writing Session
- FR-RATE-1 through FR-RATE-7: Rating System
- FR-FEED-1 through FR-FEED-6: Story Feed & Discovery
- FR-ANTH-1 through FR-ANTH-5: Anthology
- FR-MOD-1 through FR-MOD-7: Content Moderation
- FR-DAILY-1 through FR-DAILY-5: Daily Challenge (Growth)
- FR-STREAK-1 through FR-STREAK-4: Engagement & Gamification (Growth)

### Non-Functional Requirements

- NFR-PERF-1 through NFR-PERF-7: Performance
- NFR-SCALE-1 through NFR-SCALE-4: Scalability
- NFR-SEC-1 through NFR-SEC-7: Security
- NFR-ACCESS-1 through NFR-ACCESS-6: Accessibility
- NFR-IOS-1 through NFR-IOS-7: iOS Platform Requirements
- NFR-I18N-1 through NFR-I18N-3: Internationalization
- NFR-DATA-1 through NFR-DATA-4: Data & Privacy
- NFR-LEGAL-1 through NFR-LEGAL-4: Legal & Licensing

### UX Design Requirements (Apple HIG)

- UX-DR1: Design system foundation — SF Pro, semantic colors, Materials, SF Symbols
- UX-DR2: Atmosphere Reveal — photo fade-in animation with `.easeIn(duration: 2)`
- UX-DR3: Haptic Heartbeat — `UIImpactFeedbackGenerator` pulses during final 30 seconds
- UX-DR4: Story Reveal — spring animation on submission confirmation
- UX-DR5: Strangers Count — "N strangers wrote about this place" in `.secondaryLabel`
- UX-DR6: Book-like anthology — New York serif font, generous whitespace
- UX-DR7: TabView with 4 tabs, NavigationStack per tab, `.fullScreenCover` for writing
- UX-DR8: Loading states via `.redacted(reason: .placeholder)`, empty states via `ContentUnavailableView`
- UX-DR9: Warm, literary micro-copy voice in localized strings
- UX-DR10: Immersive writing mode — full-screen cover, no tab bar, Live Activity timer

### FR Coverage Map

| FR | Epic | Story |
|----|------|-------|
| FR-AUTH-1 | E1 | 1.2 |
| FR-AUTH-2 | E1 | 1.3 |
| FR-AUTH-3 | E6 | 6.2 |
| FR-AUTH-4 | E6 | 6.1 |
| FR-AUTH-5 | E6 | 6.3 |
| FR-PHOTO-1 | E2 | 2.1 |
| FR-PHOTO-2 | E3 | 3.1 |
| FR-PHOTO-3 | E3 | 3.1 |
| FR-PHOTO-4 | E2 | 2.2 |
| FR-PHOTO-5 | E2 | 2.3 |
| FR-PHOTO-6 | E2 | 2.4 (web admin) |
| FR-PHOTO-7 | E2 | 2.1 |
| FR-WRITE-1 through 10 | E3 | 3.1-3.5 |
| FR-RATE-1 through 7 | E4 | 4.1-4.3 |
| FR-FEED-1 through 6 | E5 | 5.1-5.3 |
| FR-ANTH-1 through 3 | E5 | 5.4-5.5 |
| FR-ANTH-4, 5 | E5 | 5.5, 5.6 |
| FR-MOD-1 through 6 | E7 | 7.1-7.4 |
| FR-MOD-7 | E7 | 7.4 |
| FR-DAILY-1 through 5 | E8 | 8.1-8.2 |
| FR-STREAK-1 through 4 | E8 | 8.3-8.4 |
| UX-DR1 | E1 | 1.1 |
| UX-DR2 | E3 | 3.1 |
| UX-DR3 | E3 | 3.3 |
| UX-DR4 | E3 | 3.5 |
| UX-DR5 | E5 | 5.4 |
| UX-DR6 | E5 | 5.5 |
| UX-DR7 | E1 | 1.1 |
| UX-DR8 | E5 | 5.1 |
| UX-DR9 | E3, E5 | throughout |
| UX-DR10 | E3 | 3.2 |

## Epic List

| Epic | Title | Stories | Phase |
|------|-------|---------|-------|
| E1 | Project Foundation & Authentication | 4 | MVP |
| E2 | Photo Management Pipeline | 4 | MVP |
| E3 | Writing Session Experience | 5 | MVP |
| E4 | Rating System | 3 | MVP |
| E5 | Story Feed, Discovery & Anthology | 6 | MVP |
| E6 | User Profiles & Account Management | 3 | MVP |
| E7 | Content Moderation | 4 | MVP |
| E8 | Daily Challenge, Gamification & iOS Extensions | 5 | Growth |

---

## Epic 1: Project Foundation & Authentication

Set up the Xcode project, Supabase backend, design system Swift extensions, authentication, and core TabView shell.

### Story 1.1: Xcode Project Scaffolding & Design System Setup

As a developer,
I want the Xcode project initialized with SwiftUI, the design system extensions, and the TabView shell,
So that all subsequent stories have a consistent foundation to build on.

**Acceptance Criteria:**

**Given** a new Xcode project
**When** the scaffolding is complete
**Then** the project targets iOS 17+ with SwiftUI lifecycle (`@main` App struct)
**And** the project structure follows the architecture: `App/`, `Features/`, `Core/`, `Resources/`
**And** `Assets.xcassets` contains the custom accent color (`#c4956a` amber) as `AccentColor`
**And** `Color+Theme.swift` extends `Color` with semantic helpers (e.g., `Color.accentWarm`)
**And** `Font+Theme.swift` defines the story reading font (New York serif via `.serif` design)
**And** `Typography.swift` and `Spacing.swift` define the design system constants
**And** `HapticManager.swift` provides a centralized haptic feedback API
**And** `ContentView.swift` contains a `TabView` with 4 tabs: Write (`pencil.line`), Feed (`square.grid.2x2`), Anthology (`book`), Profile (`person.circle`)
**And** each tab has its own `NavigationStack`
**And** `Localizable.xcstrings` is set up with German and English locales
**And** the app builds and runs on iOS 17 simulator without errors

### Story 1.2: Authentication with Sign in with Apple + Supabase

As a user,
I want to sign in with my Apple ID,
So that my stories and ratings are associated with my account.

**Acceptance Criteria:**

**Given** the Supabase project is configured with Apple OAuth provider
**When** a user taps Sign in with Apple on the sign-in screen
**Then** the native `SignInWithAppleButton` is presented (full-width, `.signIn` style, `.black` or `.white` matching appearance mode)
**And** the Apple ID credential is exchanged for a Supabase auth session via `supabase-swift`
**And** the auth session token is stored in iOS Keychain (default `supabase-swift` behavior)
**And** a user record is created/updated in the `users` table via a Supabase database trigger on `auth.users`
**And** the email/password option is available as a secondary sign-in method below the Apple button
**And** `AuthViewModel` manages auth state as `@Observable`
**And** `AppState` reflects authenticated/unauthenticated state, and the UI updates accordingly

### Story 1.3: Guest-to-Authenticated User Flow

As a first-time user,
I want to write one story without creating an account,
So that I can experience the app before committing to registration.

**Acceptance Criteria:**

**Given** a user has not signed in
**When** they navigate to the Write tab
**Then** they are allowed to complete one writing session as a guest (anonymous Supabase session)
**And** after submitting their story, a `.sheet` prompts them to Sign in with Apple to save their story permanently
**And** if they sign in, the guest story is re-associated with their new authenticated account
**And** if they dismiss the prompt, the story is saved as anonymous (linked to the anonymous session, not deletable)
**And** guest users cannot access the rating interface, profile tab, or bookmarks
**And** a subtle "Sign in to unlock all features" banner appears on the Feed tab for guests

### Story 1.4: Supabase Database Schema & Configuration

As a developer,
I want the Supabase database schema created with RLS policies,
So that the data model supports all features with proper access control.

**Acceptance Criteria:**

**Given** a Supabase project is created
**When** the database migrations are applied
**Then** all tables exist: `users`, `photos`, `stories`, `ratings`, `reports`, `bookmarks`, `achievements`, `auto_saves`, `daily_challenges`
**And** RLS is enabled on all tables with policies as defined in the architecture document
**And** the `users` table includes: `id`, `apple_id`, `email`, `display_name`, `bio`, `avatar_url`, `stories_count`, `avg_rating`, `streak_days`, `created_at`, `updated_at`
**And** a database trigger on `auth.users` creates a corresponding `users` row on sign-up
**And** the Wilson score function `calculate_wilson_score` is created as a Postgres function
**And** a trigger on `ratings` recalculates `stories.wilson_score` on insert
**And** indexes are created per the architecture document (story feed, user stories, moderation queue, unique constraints)
**And** `SupabaseClient.swift` is configured with the project URL and anon key
**And** App Groups capability is enabled for sharing Supabase credentials with Widget and Live Activity extensions

---

## Epic 2: Photo Management Pipeline

Build the photo storage, caching, and admin management system.

### Story 2.1: Photo Storage & Caching with Kingfisher

As a developer,
I want photos stored in Supabase Storage and cached on-device via Kingfisher,
So that atmospheric photos load fast and work offline for previously viewed photos.

**Acceptance Criteria:**

**Given** Supabase Storage is configured with a `photos` bucket (public)
**When** a photo is stored in the bucket
**Then** it can be served via its public CDN URL
**And** `PhotoRepository.swift` resolves `storage_path` to a full CDN URL via `supabase.storage.from("photos").getPublicURL(path:)`
**And** Kingfisher is integrated via SPM with a disk cache limit of 200MB
**And** All photo views use `KFImage(url)` with `.placeholder { RoundedRectangle(...).redacted(reason: .placeholder) }` for loading state
**And** the `photos` table schema is defined: `id`, `storage_path`, `alt_text`, `photographer`, `license`, `mood_tags[]`, `location`, `story_count`, `is_active`, `created_at`
**And** photos are prefetched when the user opens the Write tab (next likely photo)

### Story 2.2: Photo Metadata & Tagging

As an administrator,
I want each photo to have metadata (mood tags, photographer credit, location),
So that photos can be categorized and properly attributed.

**Acceptance Criteria:**

**Given** a photo exists in Supabase Storage
**When** an admin views the photo details (via web admin dashboard)
**Then** they can see and edit: photographer name, license type, mood tags (array), location (optional text), alt text
**And** mood tags are selectable from a predefined set: mysterious, abandoned, warm, cold, urban, nature, night, dawn, industrial, residential
**And** alt text is required and describes the mood/scene for VoiceOver
**And** the iOS app reads metadata via the `photos` table — it does not manage photos

### Story 2.3: Photo Story Count Tracking

As a system,
I want to track how many stories have been written per photo,
So that the "N strangers wrote about this place" count is accurate.

**Acceptance Criteria:**

**Given** a story is submitted for a photo
**When** the story is published (moderation passes)
**Then** a database trigger increments `photos.story_count`
**And** the iOS app displays the count on photo cards and anthology chapter headers
**And** the count updates via Supabase Realtime subscription (live update, no manual refresh needed)

### Story 2.4: Admin Photo Management (Web Dashboard)

As an administrator,
I want to upload, edit, and manage photos via a web dashboard,
So that the curated collection stays fresh and properly licensed.

**Acceptance Criteria:**

**Given** an authenticated admin user on the web dashboard
**When** they access the photo management page
**Then** they can upload new photos (uploaded to Supabase Storage `photos` bucket)
**And** they can edit photo metadata (tags, credit, license, alt text, location)
**And** they can toggle a photo's `is_active` status (retired photos excluded from random assignment)
**And** they can see each photo's story count
**And** the admin dashboard is a separate web project (Supabase Studio or minimal web app) — NOT part of the iOS app

---

## Epic 3: Writing Session Experience

Build the core creative experience — photo reveal, timed editor with haptics, auto-save, Live Activity, and submission.

### Story 3.1: Photo Assignment & Atmosphere Reveal

As a user,
I want to receive a random atmospheric photo with a dramatic reveal,
So that I feel inspired and immersed before writing begins.

**Acceptance Criteria:**

**Given** a user taps the Write tab or starts a new session
**When** a `.fullScreenCover` is presented
**Then** a random active photo is assigned via Supabase RPC (weighted toward photos with fewer stories)
**And** the photo fills the screen using `.ignoresSafeArea()` with a 2-second fade-in animation
**And** photographer credit is displayed in `.caption` style at bottom-left over `.ultraThinMaterial`
**And** a "Skip this photo" button with `arrow.forward` SF Symbol is at the top-right (one skip per session)
**And** tapping skip fetches a different random photo with the same fade-in animation
**And** a "Begin Writing" button in `.borderedProminent` style appears centered at bottom after the reveal
**And** the server records `session_started_at` via Supabase RPC when the photo is assigned
**And** `accessibilityLabel` on the photo uses the `alt_text` from metadata
**And** with Reduce Motion enabled, the photo appears instantly (no fade)

### Story 3.2: Writing Editor with Immersive Mode

As a user,
I want a distraction-free text editor below the photo,
So that I can focus entirely on writing my story.

**Acceptance Criteria:**

**Given** the user taps "Begin Writing"
**When** the editor appears within the `.fullScreenCover`
**Then** the photo shrinks to ~40% of screen height, reducing to ~20% when the keyboard appears (via keyboard observation with `GeometryReader`)
**And** a `TextEditor` appears below the photo with SF Mono `.body` text style
**And** the editor has a plain background matching `Color(.systemBackground)`
**And** the tab bar is not visible (the view is in a `.fullScreenCover`)
**And** the editor receives focus automatically (keyboard appears)
**And** a word count is displayed in `.caption` style at the bottom-leading corner
**And** the user can only have one active writing session at a time (enforced via `WriteViewModel` state)
**And** `accessibilityLabel("Story editor")` and `accessibilityHint("Write your story here")` are set on the TextEditor

### Story 3.3: Countdown Timer with Haptic Heartbeat + Live Activity

As a user,
I want a countdown timer with haptic feedback and a Lock Screen Live Activity,
So that the time pressure feels like creative energy and I can glance at remaining time.

**Acceptance Criteria:**

**Given** the user has begun writing (tapped "Begin Writing")
**When** the timer starts (3:00)
**Then** a thin `ProgressView(.linear)` spans the full width below the photo over `.ultraThinMaterial`
**And** the remaining time is displayed in SF Mono `.title` style in the top-trailing corner
**And** the timer is driven by `Timer.publish(every: 1, on: .main, in: .common)`
**And** `UIImpactFeedbackGenerator(.light)` fires at timer start
**And** during the final 30 seconds, `UIImpactFeedbackGenerator(.rigid)` pulses every 10 seconds (quickening pace)
**And** timer drift is < 100ms over the 3-minute duration
**And** a Live Activity (`WritingTimerActivity`) starts via ActivityKit showing the countdown on Lock Screen and Dynamic Island
**And** the Live Activity compact view shows timer + `pencil.line` symbol; expanded view adds photo thumbnail and word count
**And** the Live Activity ends when the story is submitted or timer expires
**And** if the device doesn't support Live Activities (< iOS 16.1), the timer works without it (graceful degradation)
**And** with Reduce Motion, the progress bar does not pulse — only solid progress

### Story 3.4: Auto-Save During Writing

As a user,
I want my story auto-saved every 10 seconds,
So that I don't lose my work if the app crashes or I switch away.

**Acceptance Criteria:**

**Given** the user is writing
**When** 10 seconds pass since the last save
**Then** the current story content is saved via a background Supabase upsert to the `auto_saves` table
**And** a small `checkmark.circle.fill` SF Symbol with `.symbolEffect(.pulse)` tinted green confirms the save
**And** the save operation is non-blocking — performed on a background task, does not freeze the editor or timer
**And** if the save fails (network error), the next save attempt includes the latest content
**And** `UIImpactFeedbackGenerator(.soft)` fires on successful save
**And** auto-save records are deleted after successful story submission
**And** if the app is relaunched and an auto-save exists, the user is prompted to resume their session

### Story 3.5: Story Submission & Story Reveal

As a user,
I want my story submitted when the timer ends (or when I submit early) with a celebration,
So that I feel pride in what I created under pressure.

**Acceptance Criteria:**

**Given** the timer reaches 0:00 or the user taps "Submit Early" (`.bordered` button at bottom-trailing)
**When** the story is submitted
**Then** the story content is sent to Supabase via `StoryRepository.submitStory()`
**And** the server validates: `submitted_at - session_started_at <= 200 seconds` (grace period)
**And** a new record is created in `stories` with `user_id`, `photo_id`, `content`, `word_count`, `started_at`, `submitted_at`
**And** `UINotificationFeedbackGenerator(.success)` fires on submission
**And** the Live Activity is ended
**And** a `.sheet` presents the `SubmissionConfirmView`:
  - Photo thumbnail (rounded, 80pt) with story text below in New York serif font
  - "Your raw story" label in `.headline` style
  - Stats: word count (`textformat.size` symbol) and time taken (`clock` symbol) in `.caption`
  - "N strangers also wrote about this place" in `.secondaryLabel`
  - Primary CTA: "Read & Rate Others" as `.borderedProminent` with accent tint
  - Secondary CTA: "Write Another" as `.bordered` button
**And** the story text appears with `.spring(response: 0.5, dampingFraction: 0.8)` animation
**And** the user cannot edit the story after submission
**And** auto-save records for this session are deleted
**And** with Reduce Motion, story text appears instantly (no spring animation)

---

## Epic 4: Rating System

Build the community rating system with haptic feedback.

### Story 4.1: Star Rating Interface (SwiftUI)

As a user,
I want to rate stories on a 1-5 star scale with satisfying haptic feedback,
So that I can express my appreciation and help surface the best stories.

**Acceptance Criteria:**

**Given** a user is viewing a published story they did not write
**When** they interact with the `RatingStarsView` component
**Then** 5 stars are displayed as `star`/`star.fill` SF Symbols in an `HStack`
**And** tapping a star submits the rating via `RatingRepository.submitRating()`
**And** `UIImpactFeedbackGenerator(.medium)` fires when a star is tapped
**And** the rating is saved to the `ratings` table with `story_id`, `user_id`, `score`
**And** the unique constraint `(story_id, user_id)` prevents duplicate ratings
**And** if the user has already rated, the stars show their previous rating as filled (non-editable, dimmed)
**And** users cannot rate their own stories — the rating component shows "Your story" in `.secondaryLabel` instead
**And** VoiceOver announces: `accessibilityValue("3 out of 5 stars")` and supports `accessibilityAdjustableAction` (increment/decrement)

### Story 4.2: Wilson Score Calculation

As a system,
I want story rankings calculated using Wilson score interval,
So that stories with more ratings are ranked more fairly.

**Acceptance Criteria:**

**Given** a story receives a new rating
**When** the rating is saved
**Then** a database trigger calls `calculate_wilson_score()` to update `stories.avg_rating`, `stories.rating_count`, and `stories.wilson_score`
**And** the Wilson score normalizes 1-5 stars to 0-1 range: `p = (avg - 1) / 4`
**And** the Wilson lower bound is calculated with 95% confidence (`z = 1.96`)
**And** feed queries use `ORDER BY wilson_score DESC` for "Top Rated" sort

### Story 4.3: Post-Submission Rating Prompt

As a system,
I want to prompt users to rate 2 stories after submitting their own,
So that every writer also contributes as a reader/rater.

**Acceptance Criteria:**

**Given** a user has just submitted a story and taps "Read & Rate Others"
**When** the Feed tab is selected
**Then** a rating prompt overlay shows 2 random published stories (not their own, not already rated)
**And** each story is displayed with photo, full text, and `RatingStarsView`
**And** after rating both (or dismissing), the user sees the normal story feed
**And** if fewer than 2 unrated stories exist, show whatever is available
**And** the prompt is a `NavigationStack` pushed view or `.sheet`, not a blocking alert

---

## Epic 5: Story Feed, Discovery & Anthology

Build the reading experience — browsing, discovery, and the collective storybook.

### Story 5.1: Story Feed with Sorting

As a user,
I want to browse stories in a feed with sorting options,
So that I can discover stories that interest me.

**Acceptance Criteria:**

**Given** a user navigates to the Feed tab
**When** the view loads
**Then** `.navigationTitle("Stories")` with `.large` display mode is shown
**And** a `Picker` with `.segmented` style provides sorting: Recent | Top Rated | This Week
**And** stories are displayed in a `List` with `.listStyle(.plain)`:
  - Each row: photo thumbnail (60pt, rounded, leading) + story excerpt (`.lineLimit(2)`) + author name (`.caption`) + star rating (`.caption2`) + time ago (`.tertiaryLabel`)
**And** `.refreshable { }` enables pull-to-refresh
**And** `.searchable(text:)` allows searching within story content
**And** pagination loads 20 stories per page with loading indicator
**And** stories with `is_published = false` or `is_flagged = true` are excluded
**And** loading state uses `.redacted(reason: .placeholder)` on story card rows
**And** empty state uses `ContentUnavailableView` with `pencil.line` symbol and "No stories yet" message
**And** toolbar button with `pencil.line` symbol starts a new writing session (presents `.fullScreenCover`)

### Story 5.2: Story Detail View

As a user,
I want to read a full story with the photo and rate it,
So that I can appreciate the writing and contribute my rating.

**Acceptance Criteria:**

**Given** a user taps a story row in the feed
**When** the `StoryDetailView` is pushed via `NavigationLink`
**Then** the photo is displayed large at the top (aspect ratio preserved, edge-to-edge on iPhone, padded on iPad)
**And** story text is rendered in New York serif font, `.body` text style, max readable width (`.frame(maxWidth: 680)` on iPad)
**And** author info row: avatar circle (32pt), display name, "N stories written"
**And** `RatingStarsView` is displayed if the user is authenticated and it's not their own story
**And** "More stories about this place" shown as a horizontal `ScrollView` of `StoryCardView` thumbnails
**And** toolbar items: `ShareLink` and `bookmark` toggle button
**And** `.toolbar { ToolbarItem(.secondaryAction) { reportButton } }` for reporting
**And** `.contextMenu` is available on the story text for Copy
**And** VoiceOver reads the story text as a single accessibility element

### Story 5.3: Bookmarks

As a user,
I want to bookmark stories I enjoy,
So that I can find them again later.

**Acceptance Criteria:**

**Given** a user is reading a story (StoryDetailView)
**When** they tap the `bookmark` / `bookmark.fill` toolbar button
**Then** the bookmark is toggled via `BookmarkRepository.toggle()`
**And** the icon switches between `bookmark` and `bookmark.fill`
**And** `UIImpactFeedbackGenerator(.light)` fires on toggle
**And** bookmarked stories appear in the Profile tab's "Bookmarks" section
**And** the bookmark state is stored in the `bookmarks` table with unique constraint `(user_id, story_id)`

### Story 5.4: Anthology Cover & Table of Contents

As a user,
I want to browse a collective storybook organized by photo,
So that I can experience the "strangers wrote about this place" concept.

**Acceptance Criteria:**

**Given** a user navigates to the Anthology tab
**When** the view loads
**Then** `.navigationTitle("Anthology")` with `.large` display mode is shown
**And** a header area shows a collage of top photos with "The Stranger Stories Anthology" in `.largeTitle` style
**And** below the header, a `List` with `.listStyle(.insetGrouped)` shows photo chapters:
  - Each row: photo thumbnail (80pt, rounded), "N stories" count in `.body`, top mood tags as colored capsules in `.caption`
  - Rows sorted by `story_count` descending
  - `NavigationLink` to `AnthologyChapterView`
**And** "N strangers wrote about this place" text uses `.secondaryLabel` color

### Story 5.5: Anthology Chapter View

As a user,
I want to read all stories written about a specific photo in a book-like layout,
So that I can experience the diversity of imaginations inspired by one place.

**Acceptance Criteria:**

**Given** a user taps a chapter row in the anthology
**When** the `AnthologyChapterView` is pushed via `NavigationLink`
**Then** the photo is displayed large at the top with `.ignoresSafeArea(edges: .top)`
**And** "N strangers wrote about this place" overlays the photo on `.ultraThinMaterial`
**And** stories are listed below, ranked by Wilson score (highest first)
**And** each story displays text in New York serif font with generous line spacing
**And** author name and star rating shown for each story
**And** the layout uses comfortable whitespace — book-like feel
**And** each story is tappable to navigate to `StoryDetailView`
**And** on iPad, uses readable content width (`.frame(maxWidth: 680)`)

### Story 5.6: Social Sharing

As a user,
I want to share a story externally,
So that I can show interesting stories to friends.

**Acceptance Criteria:**

**Given** a user is reading a story
**When** they tap the `ShareLink` toolbar item
**Then** the system share sheet presents with: story excerpt text + deep link URL
**And** the deep link opens the app to the specific story (via URL scheme or Universal Link)
**And** if the app is not installed, the link could fallback to a web preview (future enhancement)
**And** `.contextMenu` on story cards in the feed also offers Share via `ShareLink`

---

## Epic 6: User Profiles & Account Management

Build the personal space where users see their stats, stories, and manage their account.

### Story 6.1: User Profile View

As a user,
I want to view my profile with stats and story history,
So that I can track my creative journey.

**Acceptance Criteria:**

**Given** an authenticated user navigates to the Profile tab
**When** `ProfileView` loads
**Then** `.navigationTitle("Profile")` with `.large` display mode
**And** a header section shows: avatar (80pt circle), display name, bio
**And** a stats `HStack` shows: stories written, average rating (with `star.fill`), current streak (with `flame` symbol), total words
**And** a `List` with sections:
  - "My Stories" — `NavigationLink` rows with photo thumbnail, rating, date
  - "Bookmarks" — bookmarked stories in the same format
  - "Achievements" — `LazyVGrid` of achievement badge circles (locked dimmed, unlocked with color)
  - "Settings" — Edit Profile, Account Deletion, App Info
**And** stories sorted by newest first
**And** loading state uses `.redacted(reason: .placeholder)`
**And** stats row stacks vertically at large Dynamic Type sizes (checked via `@Environment(\.dynamicTypeSize)`)

### Story 6.2: Profile Editing

As a user,
I want to edit my display name, bio, and avatar,
So that I can personalize my author presence.

**Acceptance Criteria:**

**Given** an authenticated user taps "Edit Profile" in the Settings section
**When** a `Form` view is pushed via `NavigationLink`
**Then** they can edit display name (`TextField`, max 50 characters)
**And** they can edit bio (`TextEditor`, max 200 characters, with character count)
**And** they can update their avatar via `PhotosPicker` (import from Photo Library) or camera
**And** avatar is uploaded to Supabase Storage and URL saved to `users.avatar_url`
**And** changes are saved via `UserRepository.updateProfile()` with a "Save" toolbar button
**And** validation errors shown inline (e.g., display name too short)
**And** `.confirmationDialog` warns about unsaved changes on dismiss

### Story 6.3: Account Deletion (GDPR)

As a user,
I want to delete my account and all my data,
So that I can exercise my right to be forgotten.

**Acceptance Criteria:**

**Given** an authenticated user taps "Delete Account" in Settings
**When** a `.confirmationDialog` warns that this action is irreversible
**Then** upon confirmation, a Supabase Edge Function deletes: all user stories, ratings, bookmarks, achievements, profile, and the Supabase Auth user record
**And** stories by deleted users show "Anonymous" as the author (stories remain in the anthology)
**And** the user is signed out and the app returns to the sign-in view
**And** `UINotificationFeedbackGenerator(.warning)` fires before the final confirmation
**And** the destructive button uses `.destructive` role (red text, per HIG)

---

## Epic 7: Content Moderation

Build the safety system — AI screening, community reporting, and admin review (admin UI is web-only).

### Story 7.1: AI Content Moderation (Pre-Publish)

As a system,
I want every story screened by AI before publishing,
So that harmful content is caught before it reaches the community.

**Acceptance Criteria:**

**Given** a user submits a story
**When** the story is inserted into the `stories` table
**Then** a Supabase database webhook triggers a Supabase Edge Function
**And** the Edge Function sends the story content to the OpenAI Moderation API
**And** if clean: `is_published = true`, `mod_status = 'approved'`
**And** if flagged: `is_published = false`, `is_flagged = true`, `mod_status = 'flagged'`
**And** the iOS app shows the story on the confirmation screen regardless, with a subtle note if under review
**And** if the OpenAI API is unreachable, `mod_status = 'pending'` (held for manual review)
**And** Edge Function execution time < 3 seconds

### Story 7.2: Community Reporting

As a user,
I want to report a story that contains inappropriate content,
So that the community can help keep the platform safe.

**Acceptance Criteria:**

**Given** a user is viewing a story in `StoryDetailView`
**When** they tap the Report button (via toolbar secondary action or context menu)
**Then** a `.confirmationDialog` presents report reasons: hate speech, violence, sexual content, personal information, spam, other
**And** the report is saved via `StoryRepository.reportStory()` to the `reports` table
**And** each user can only report a story once (unique constraint)
**And** a toast-style confirmation appears: "Thanks for helping keep Stranger Stories safe"
**And** when a story reaches 3+ reports, a database trigger sets `is_published = false`, `is_flagged = true`
**And** `UINotificationFeedbackGenerator(.success)` fires on report submission

### Story 7.3: Admin Moderation Queue (Web Dashboard)

As an administrator,
I want to review flagged and reported stories via a web dashboard,
So that I can make final decisions on content disputes.

**Acceptance Criteria:**

**Given** an admin accesses the web moderation dashboard
**When** the queue loads
**Then** it shows stories where `is_flagged = true` or `mod_status = 'pending'`
**And** each item shows: story text, the photo, AI confidence score, report count, report reasons
**And** admin can: Approve (publish), Reject (permanently remove), Ban Author (remove all stories, disable account)
**And** actions are logged to an `admin_actions` table
**And** this is a web dashboard — NOT part of the iOS app

### Story 7.4: Rate Limiting & Shadowban

As a system,
I want repeat policy violators automatically restricted,
So that the platform remains safe without constant admin intervention.

**Acceptance Criteria:**

**Given** a user has had 3+ stories rejected by moderation
**When** they submit a new story
**Then** the Edge Function automatically routes their stories to `mod_status = 'pending'` (manual review)
**And** they are not notified of this change (shadowban)
**And** rate limiting enforces max 10 story submissions per user per hour (checked in Edge Function)
**And** rate limit violations return an error that the iOS app displays as: "You're writing fast! Take a break and come back soon."

---

## Epic 8: Daily Challenge, Gamification & iOS Extensions (Growth)

Build engagement features and iOS-native extensions: daily challenge, streaks, achievements, WidgetKit, and App Intents.

### Story 8.1: Daily Challenge Photo Selection

As a system,
I want one photo selected per day as the Daily Challenge,
So that all users can write about the same place and compare.

**Acceptance Criteria:**

**Given** a new day begins (UTC midnight)
**When** no `daily_challenges` record exists for the current date
**Then** a Supabase scheduled Edge Function selects a photo (preferring fewer stories, not recently used as a challenge)
**And** a `daily_challenges` record is created with `photo_id` and `date`
**And** the Daily Challenge is featured prominently at the top of the Feed tab with a highlighted card

### Story 8.2: Daily Challenge Writing & Leaderboard

As a user,
I want to participate in the Daily Challenge and see how my story ranks,
So that I feel motivated by friendly competition.

**Acceptance Criteria:**

**Given** a user taps the Daily Challenge card in the Feed tab
**When** they complete the writing session
**Then** their story is tagged as a Daily Challenge entry (linked to `daily_challenges.id`)
**And** after submitting, they can browse all other Daily Challenge stories for today
**And** a leaderboard view shows today's top-rated Daily Challenge stories ranked by Wilson score
**And** previous days' challenges are archived and browsable from a "Past Challenges" section

### Story 8.3: Writing Streaks

As a user,
I want my consecutive writing days tracked as a streak,
So that I feel motivated to write daily.

**Acceptance Criteria:**

**Given** a user writes at least one story on a given day
**When** they have written on consecutive days
**Then** `users.streak_days` increments (via database trigger on story insert)
**And** the current streak is displayed on the Profile tab with a `flame` SF Symbol + count
**And** `StreakIndicatorView` appears in the Feed tab's navigation bar when streak > 0
**And** missing a day resets the streak to 0
**And** streak recovery: missing one day and writing 2 stories the next day preserves the streak (one recovery per streak, tracked via a `streak_recovery_used` flag)
**And** `UINotificationFeedbackGenerator(.success)` fires when a streak milestone is reached (7, 30, 100)

### Story 8.4: Achievement Badges

As a user,
I want to earn badges for creative milestones,
So that I feel recognized for my contributions.

**Acceptance Criteria:**

**Given** a user reaches a milestone
**When** the milestone is achieved (checked via database triggers or Edge Functions)
**Then** an `achievements` record is created with `user_id`, `type`, `earned_at`
**And** the iOS app shows a notification banner: "You earned: [Badge Name]!" with `.symbolEffect(.bounce)` on the trophy icon
**And** earned badges are displayed in the Profile tab's Achievements section as a `LazyVGrid` of circles
**And** locked badges appear dimmed; unlocked badges appear with color and the `trophy.fill` symbol
**And** badge types:
  - "First Words" — wrote first story
  - "Storyteller" — wrote 10 stories
  - "Prolific" — wrote 50 stories
  - "Week Warrior" — 7-day writing streak
  - "Month Master" — 30-day writing streak
  - "Crowd Favorite" — any story in top 10% by Wilson score
  - "Community Voice" — rated 50 stories
**And** `UINotificationFeedbackGenerator(.success)` fires on achievement unlock

### Story 8.5: WidgetKit Daily Challenge Widget & App Intents

As a user,
I want a home screen widget showing today's challenge photo and a Siri Shortcut to start writing,
So that I can engage with Stranger Stories without opening the app.

**Acceptance Criteria:**

**Given** the WidgetKit extension is configured with App Groups sharing
**When** a user adds the Stranger Stories widget to their home screen
**Then** a **small** widget shows: today's challenge photo filling the widget area with "Tap to write" overlay
**And** a **medium** widget shows: photo + "Today's Challenge" title + story count so far
**And** tapping the widget opens the app directly to the Daily Challenge writing session via deep link
**And** the widget refreshes via `TimelineProvider` (timeline entries at midnight + every 4 hours)
**And** an App Intent "Write a Stranger Story" is registered as a Siri Shortcut
**And** invoking the shortcut opens the app to a new writing session
**And** the widget uses the shared App Group container to read Supabase credentials and cache the daily photo
