---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
inputDocuments:
  - prd.md
  - ux-design-specification.md
  - product-brief-StrangerStories.md
workflowType: 'architecture'
project_name: StrangerStories
user_name: Dimai
date: 2026-03-29
lastStep: 8
status: complete
completedAt: 2026-03-29
platform: 'ios-native'
---

# Architecture Decision Document — Stranger Stories (iOS)

This document captures all architectural decisions for the Stranger Stories native iOS application, providing a comprehensive technical blueprint for implementation.

---

## 1. Project Context Analysis

### Requirements Summary
- **Native iOS application** — iPhone + iPad, iOS 17+ minimum deployment target
- **Core loop:** random photo → 3-min timed writing → community rating → collective anthology
- **Scale targets:** 1K concurrent writers, 10K concurrent readers, 100K+ stories
- **Content moderation:** AI pre-screening + community reporting
- **Image pipeline:** 200+ curated photos at launch, cached on-device
- **i18n:** German + English UI via String Catalogs, multilingual story content
- **Apple HIG:** SF Pro typography, semantic colors, materials, haptics, Live Activity, WidgetKit

### Technical Constraints
- Solo/small team — minimize operational complexity; prefer unified backend
- Budget-conscious — managed backend-as-a-service preferred over custom server infrastructure
- iOS-first — must support Dynamic Type, VoiceOver, Reduce Motion
- Timer accuracy — on-device timer with server-side validation
- Content safety — must moderate text before public display
- App Store compliance — Sign in with Apple mandatory, privacy nutrition labels required

### Key Technical Challenges
1. Timer synchronization (on-device timer with server validation of submission timestamps)
2. Auto-save during writing sessions (frequent writes without overwhelming the backend)
3. Wilson score calculation for fair rating (server-side SQL function)
4. Image caching and progressive loading (local cache + CDN fallback)
5. AI content moderation integration (low latency, called from backend)
6. Live Activity lifecycle management (ActivityKit integration)

---

## 2. Core Architectural Decisions

### ADR-1: Client Framework — SwiftUI (iOS 17+)

**Decision:** Build the iOS app with SwiftUI targeting iOS 17 as the minimum deployment target.

**Rationale:**
- SwiftUI provides declarative UI that maps naturally to the screen inventory in the UX spec
- iOS 17 provides `@Observable` macro (replaces `ObservableObject`/`@Published`), `ContentUnavailableView`, improved `NavigationStack`, and `SwiftData` (if needed later)
- `TextEditor` is mature enough for the plain-text writing editor
- `AsyncImage` with custom caching handles the photo pipeline
- ActivityKit for Live Activities, WidgetKit for home screen widgets
- Full support for Dynamic Type, VoiceOver, and all HIG accessibility patterns
- Universal app (iPhone + iPad) with adaptive layouts via `horizontalSizeClass`

**Alternatives Considered:**
- UIKit — more mature but verbose; SwiftUI's declarative model is faster for a small team
- React Native — cross-platform but can't deliver native HIG feel (materials, haptics, Live Activities)
- Flutter — same cross-platform limitations; no native ActivityKit/WidgetKit integration

### ADR-2: Backend — Supabase (Unified BaaS)

**Decision:** Use Supabase as the unified backend: Postgres database, Auth, Storage, Edge Functions, and Realtime.

**Rationale:**
- Replaces 3 separate services from the web architecture (Neon, Clerk, Vercel Blob) with one
- Postgres database with PostgREST auto-generated API — type-safe queries via `supabase-swift`
- Row Level Security (RLS) provides per-user data isolation at the database level
- Free tier covers MVP scale (50K MAU, 500MB database, 1GB storage)
- Edge Functions (Deno) for server-side logic (moderation, score calculation)
- Realtime subscriptions for live story count updates and rating notifications
- `supabase-swift` is the official Swift SDK — actively maintained, supports async/await

**Alternatives Considered:**
- Firebase — good for mobile but Firestore's document model is a poor fit for relational data (stories, ratings, scores)
- Custom Vapor server + Neon — more control but dramatically more infrastructure to build and maintain
- CloudKit — Apple-native but limited query capabilities, no server-side functions, vendor lock-in

### ADR-3: Authentication — Supabase Auth + Sign in with Apple

**Decision:** Use Supabase Auth with Sign in with Apple as the primary authentication method.

**Rationale:**
- Sign in with Apple is mandatory per App Store Review Guidelines when offering third-party login
- Supabase Auth has built-in Apple OAuth support — handles token exchange, session management, refresh
- Email/password as a secondary option for users who prefer it
- Guest mode: create an anonymous Supabase session; upgrade to authenticated when user signs in
- Auth tokens stored securely in iOS Keychain via `supabase-swift` defaults
- JWT tokens used for all API requests; RLS policies enforce per-user access

**Alternatives Considered:**
- Firebase Auth — good Apple Sign-In support but would couple auth to a different backend than the database
- Custom JWT with Vapor — too much infrastructure for a small team
- AuthenticationServices only (no backend auth) — would leave no way to validate sessions server-side

### ADR-4: Image Storage & Caching — Supabase Storage + Kingfisher

**Decision:** Store photos in Supabase Storage; cache and display on-device via Kingfisher.

**Rationale:**
- Supabase Storage provides S3-compatible file hosting with CDN via their edge network
- Kingfisher is the de-facto standard for iOS image caching — progressive loading, disk/memory cache, image processing
- Photos are uploaded by admins via a web dashboard; served to the iOS app via public Storage URLs
- Kingfisher handles: placeholder shimmers, progressive JPEG/HEIF, automatic cache expiry, prefetching
- On-device cache means photos load instantly on repeat views — critical for the anthology browsing experience

**Alternatives Considered:**
- `AsyncImage` (built-in) — no disk caching, no prefetching, limited control over loading states
- Nuke — excellent but Kingfisher has broader community adoption and simpler API
- CloudKit Assets — limited to iCloud users, no CDN, poor cross-user sharing

### ADR-5: Content Moderation — Supabase Edge Function + OpenAI Moderation API

**Decision:** Content moderation runs as a Supabase Edge Function triggered on story submission, calling the OpenAI Moderation API.

**Rationale:**
- Same moderation logic as the web architecture, different hosting (Edge Function instead of Next.js Server Action)
- OpenAI Moderation API is free to use, low latency (~200ms)
- Edge Function receives the story text, calls OpenAI, and updates the story's `mod_status` and `is_published` fields
- Called via Supabase database trigger (on `INSERT` into `stories`) or via RPC from the iOS app
- Community reports (3+ auto-hides) as a second layer — implemented via database trigger
- If moderation API is unreachable, story is held with `mod_status = 'pending'` for manual review

**Alternatives Considered:**
- On-device moderation (Core ML) — Apple's NaturalLanguage framework can detect sentiment but lacks comprehensive toxicity detection
- Perspective API — good but requires separate API key management
- Manual-only moderation — doesn't scale

### ADR-6: Timer Architecture — On-Device Timer + Live Activity + Server Validation

**Decision:** Timer runs on-device using `Timer.publish`; displayed as a Live Activity via ActivityKit; server validates submission timestamps.

**Rationale:**
- On-device timer provides accurate, smooth UX with no network latency
- `Timer.publish(every: 1, on: .main, in: .common)` drives the countdown UI
- ActivityKit Live Activity shows the timer on Lock Screen and Dynamic Island
- Server records `session_started_at` via RPC when photo is assigned; validates `submitted_at - session_started_at <= 200 seconds`
- Haptic feedback via `UIImpactFeedbackGenerator` at key moments (start, 30s warning, completion)
- Auto-save uses periodic background Supabase upserts (every 10s) — non-blocking

**Alternatives Considered:**
- Server-driven timer via Realtime — adds latency, unnecessary complexity for a 3-minute countdown
- Background task for timer — not needed; the timer only runs while the app is in the foreground during writing
- No Live Activity — would work but misses a delightful iOS-native opportunity

### ADR-7: Rating Algorithm — Wilson Score (Postgres Function)

**Decision:** Wilson score lower bound calculated as a Postgres function, invoked via database trigger on rating changes.

**Rationale:**
- Same algorithm as the web architecture — proven, fair ranking
- Implemented as `calculate_wilson_score(avg_rating NUMERIC, rating_count INTEGER) RETURNS NUMERIC`
- Database trigger recalculates `stories.wilson_score` on every rating insert/update
- Feed queries: `SELECT * FROM stories WHERE is_published = true ORDER BY wilson_score DESC`
- Supabase RPC can call the function directly if needed for specific calculations

**Formula:**
```
wilson_lower_bound = (p + z²/(2n) - z * sqrt((p*(1-p) + z²/(4n)) / n)) / (1 + z²/n)
where p = (avg_rating - 1) / 4  (normalize 1-5 to 0-1)
      n = total_ratings
      z = 1.96 (95% confidence)
```

### ADR-8: App Architecture Pattern — MVVM with @Observable

**Decision:** Use MVVM (Model-View-ViewModel) with Swift 5.9's `@Observable` macro and a Repository pattern for data access.

**Rationale:**
- MVVM is the natural fit for SwiftUI — Views observe ViewModels, ViewModels coordinate Repositories
- `@Observable` (Observation framework) replaces `ObservableObject`/`@Published` — less boilerplate, fine-grained observation
- Repository pattern abstracts Supabase SDK calls — ViewModels never import `Supabase` directly
- Dependency injection via `@Environment` for testability
- Each feature module (Write, Feed, Anthology, Profile) has its own ViewModel
- Shared state (auth, user profile) managed via a global `AppState` observable

**Layer responsibilities:**
```
View (SwiftUI)     → Renders UI, handles gestures, binds to ViewModel
ViewModel          → Business logic, state management, coordinates Repositories
Repository         → Data access abstraction (Supabase queries, caching)
Supabase SDK       → Network calls, auth, storage, realtime
```

---

## 3. Data Model

### Entity Relationship Diagram

The data model is identical to the web architecture — same Postgres schema hosted on Supabase.

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│    users      │     │    photos     │     │    stories    │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ id (PK, UUID)│     │ id (PK, UUID)│     │ id (PK, UUID)│
│ apple_id     │     │ storage_path │     │ user_id (FK) │
│ email        │     │ alt_text     │     │ photo_id (FK)│
│ display_name │     │ photographer │     │ content      │
│ bio          │     │ license      │     │ word_count   │
│ avatar_url   │     │ mood_tags[]  │     │ started_at   │
│ stories_count│     │ location     │     │ submitted_at │
│ avg_rating   │     │ story_count  │     │ is_published │
│ streak_days  │     │ is_active    │     │ is_flagged   │
│ created_at   │     │ created_at   │     │ mod_status   │
│ updated_at   │     └──────────────┘     │ avg_rating   │
└──────────────┘            │              │ rating_count │
       │                    │              │ wilson_score │
       │              ┌─────┘              │ created_at   │
       │              │                    └──────────────┘
       ▼              ▼                           │
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   ratings     │     │ daily_       │     │   reports     │
├──────────────┤     │ challenges   │     ├──────────────┤
│ id (PK)      │     ├──────────────┤     │ id (PK)      │
│ story_id (FK)│     │ id (PK)      │     │ story_id (FK)│
│ user_id (FK) │     │ photo_id (FK)│     │ reporter_id  │
│ score (1-5)  │     │ date (unique)│     │ reason       │
│ created_at   │     │ created_at   │     │ created_at   │
└──────────────┘     └──────────────┘     └──────────────┘

┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  bookmarks    │     │ achievements │     │  auto_saves   │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ id (PK)      │     │ id (PK)      │     │ id (PK)      │
│ user_id (FK) │     │ user_id (FK) │     │ user_id (FK) │
│ story_id (FK)│     │ type         │     │ photo_id (FK)│
│ created_at   │     │ earned_at    │     │ content      │
└──────────────┘     └──────────────┘     │ saved_at     │
                                           └──────────────┘
```

### Key Differences from Web Architecture
- `users.clerk_id` → `users.apple_id` (Sign in with Apple identifier)
- `photos.blob_url` → `photos.storage_path` (Supabase Storage path, resolved to CDN URL at runtime)
- All tables have RLS policies — users can only read/write their own data where appropriate

### Row Level Security Policies

| Table | SELECT | INSERT | UPDATE | DELETE |
|-------|--------|--------|--------|--------|
| `users` | Own row only | Via auth trigger | Own row only | Own row only |
| `photos` | All active photos | Admin only | Admin only | Admin only |
| `stories` | Published stories + own unpublished | Authenticated users | Own stories only | Not allowed |
| `ratings` | Own ratings | Authenticated (not own story) | Not allowed | Not allowed |
| `reports` | Admin only | Authenticated users | Not allowed | Not allowed |
| `bookmarks` | Own bookmarks | Authenticated users | Not allowed | Own bookmarks |
| `achievements` | Own achievements | Via database trigger | Not allowed | Not allowed |
| `auto_saves` | Own saves | Authenticated users | Own saves | Own saves |
| `daily_challenges` | All | Database cron only | Not allowed | Not allowed |

### Key Indexes
- `stories(photo_id, wilson_score DESC)` — anthology chapter queries
- `stories(user_id, created_at DESC)` — user profile stories
- `stories(wilson_score DESC) WHERE is_published = true` — top-rated feed (partial index)
- `stories(created_at DESC) WHERE is_published = true` — recent feed (partial index)
- `stories(is_flagged, mod_status)` — moderation queue
- `ratings(story_id, user_id) UNIQUE` — one rating per user per story
- `bookmarks(user_id, story_id) UNIQUE` — one bookmark per user per story
- `daily_challenges(date) UNIQUE` — one challenge per day

---

## 4. Implementation Patterns & Consistency Rules

### Swift Project Structure

```
StrangerStories/
├── StrangerStories/
│   ├── App/
│   │   ├── StrangerStoriesApp.swift       # @main entry, Supabase init, TabView
│   │   ├── AppState.swift                 # Global observable state (auth, user)
│   │   └── ContentView.swift              # TabView root with 4 tabs
│   ├── Features/
│   │   ├── Auth/
│   │   │   ├── AuthViewModel.swift
│   │   │   ├── SignInView.swift
│   │   │   └── OnboardingView.swift
│   │   ├── Write/
│   │   │   ├── WriteViewModel.swift
│   │   │   ├── PhotoRevealView.swift
│   │   │   ├── WritingSessionView.swift
│   │   │   ├── CountdownTimerView.swift
│   │   │   └── SubmissionConfirmView.swift
│   │   ├── Feed/
│   │   │   ├── FeedViewModel.swift
│   │   │   ├── StoryFeedView.swift
│   │   │   └── StoryCardView.swift
│   │   ├── StoryDetail/
│   │   │   ├── StoryDetailViewModel.swift
│   │   │   ├── StoryDetailView.swift
│   │   │   └── RatingStarsView.swift
│   │   ├── Anthology/
│   │   │   ├── AnthologyViewModel.swift
│   │   │   ├── AnthologyCoverView.swift
│   │   │   └── AnthologyChapterView.swift
│   │   └── Profile/
│   │       ├── ProfileViewModel.swift
│   │       └── ProfileView.swift
│   ├── Core/
│   │   ├── Models/
│   │   │   ├── User.swift
│   │   │   ├── Photo.swift
│   │   │   ├── Story.swift
│   │   │   ├── Rating.swift
│   │   │   └── Achievement.swift
│   │   ├── Repository/
│   │   │   ├── StoryRepository.swift
│   │   │   ├── PhotoRepository.swift
│   │   │   ├── RatingRepository.swift
│   │   │   ├── UserRepository.swift
│   │   │   └── BookmarkRepository.swift
│   │   ├── Networking/
│   │   │   └── SupabaseClient.swift       # Singleton Supabase client config
│   │   ├── Extensions/
│   │   │   ├── Color+Theme.swift
│   │   │   ├── Font+Theme.swift
│   │   │   └── View+Haptics.swift
│   │   └── DesignSystem/
│   │       ├── Typography.swift           # Text style constants
│   │       ├── Spacing.swift              # Spacing/margin constants
│   │       └── HapticManager.swift        # Centralized haptic feedback
│   └── Resources/
│       ├── Assets.xcassets/
│       │   ├── AccentColor.colorset/      # Custom amber accent
│       │   ├── AppIcon.appiconset/
│       │   └── Colors/                    # Any custom named colors
│       └── Localizable.xcstrings          # String Catalog (DE + EN)
├── StrangerStoriesWidgets/
│   ├── DailyChallengeWidget.swift
│   └── Assets.xcassets/
├── StrangerStoriesLiveActivity/
│   └── WritingTimerActivity.swift
├── StrangerStoriesTests/
│   └── ...
└── StrangerStoriesUITests/
    └── ...
```

### Coding Patterns

1. **Views are thin.** SwiftUI Views contain only layout and binding logic. Business logic lives in ViewModels.
2. **ViewModels use `@Observable`.** All ViewModels use the `@Observable` macro (Swift 5.9 Observation framework), not `ObservableObject`.
3. **Repository pattern for data access.** ViewModels call Repository methods; Repositories call `supabase-swift`. Never import `Supabase` in a ViewModel.
4. **Dependency injection via `@Environment`.** Repositories are injected into the SwiftUI environment for testability.
5. **Async/await everywhere.** All network calls use Swift concurrency. No completion handlers or Combine publishers for new code.
6. **Error handling via `Result` or `throws`.** Errors propagate to ViewModels which set error state; Views display errors via `.alert`.
7. **Haptics centralized in `HapticManager`.** All haptic feedback calls go through a single manager that respects system settings.
8. **Animations respect Reduce Motion.** All `withAnimation` blocks check `UIAccessibility.isReduceMotionEnabled`.
9. **String Catalogs for localization.** All user-facing strings use `String(localized:)` or `LocalizedStringKey`. No hardcoded strings.
10. **Preview-friendly.** All Views and ViewModels support SwiftUI Previews with mock data.

### Environment Variables / Configuration

| Variable | Location | Purpose |
|----------|----------|---------|
| `SUPABASE_URL` | `SupabaseClient.swift` (compiled) | Supabase project URL |
| `SUPABASE_ANON_KEY` | `SupabaseClient.swift` (compiled) | Supabase anonymous/public key |
| Apple Sign-In | Xcode capability | Sign in with Apple entitlement |
| Push Notifications | Xcode capability | APNs for rating notifications |
| App Groups | Xcode capability | Share data between app and widget/Live Activity |

**Note:** `SUPABASE_URL` and `SUPABASE_ANON_KEY` are public values (safe to embed in the app binary). All data protection is via RLS policies, not API key secrecy.

---

## 5. External Service Architecture

```
┌──────────────────────────────────────────────┐
│              iOS Device                       │
│  ┌────────────┐  ┌───────────┐  ┌─────────┐ │
│  │ SwiftUI    │  │ Live      │  │ Widget  │ │
│  │ App        │  │ Activity  │  │ (Kit)   │ │
│  └─────┬──────┘  └───────────┘  └─────────┘ │
│        │                                      │
└────────┼──────────────────────────────────────┘
         │ HTTPS
    ┌────┼──────────────────────────────┐
    │    ▼         Supabase             │
    │  ┌──────────────────────────────┐ │
    │  │ Auth (Sign in with Apple)    │ │
    │  ├──────────────────────────────┤ │
    │  │ Postgres (Data + RLS)        │ │
    │  ├──────────────────────────────┤ │
    │  │ Storage (Photos CDN)         │ │
    │  ├──────────────────────────────┤ │
    │  │ Edge Functions (Moderation)  │ │
    │  ├──────────────────────────────┤ │
    │  │ Realtime (Live Updates)      │ │
    │  └──────────────────────────────┘ │
    │         │            │            │
    └─────────┼────────────┼────────────┘
              │            │
     ┌────────▼──┐  ┌──────▼──────┐
     │ OpenAI    │  │ APNs        │
     │ Moderation│  │ (Push)      │
     └───────────┘  └─────────────┘
```

### Performance Budget
- **Cold launch:** < 2 seconds to interactive
- **Scrolling:** 60fps on all list/grid views
- **Photo loading:** < 1 second (cached), < 3 seconds (first load from CDN)
- **Auto-save roundtrip:** < 500ms (background, non-blocking)
- **App binary:** < 30MB (excluding cached content)
- **Memory:** < 150MB during writing session (including photo)

### Security Boundaries
- Supabase RLS enforces per-user data access at the database level
- Auth tokens stored in iOS Keychain (not UserDefaults)
- No user data logged to console in release builds
- Input sanitization on server-side Edge Functions (not client-side)
- Rate limiting: 10 story submissions per user per hour (enforced via Edge Function)
- All network traffic over HTTPS/TLS

---

## 6. Architecture Validation

### PRD Coverage Check

| Requirement Group | Architecture Coverage |
|-------------------|----------------------|
| FR-AUTH | Supabase Auth + Sign in with Apple, anonymous sessions for guests |
| FR-PHOTO | Supabase Storage + Kingfisher caching, admin management via web dashboard |
| FR-WRITE | On-device `Timer.publish`, auto-save via Supabase upserts, server timestamp validation |
| FR-RATE | Wilson score Postgres function, ratings table with unique constraint |
| FR-FEED | Indexed queries via PostgREST, `List`/`LazyVGrid` with `.refreshable` |
| FR-ANTH | Photo-grouped queries, `NavigationStack` drill-down, book-like typography |
| FR-MOD | Supabase Edge Function → OpenAI Moderation API, reports table, web admin |
| FR-DAILY | `daily_challenges` table, Supabase cron for daily photo selection, WidgetKit |
| FR-STREAK | User streak tracking, achievements table, database triggers |
| NFR-PERF | Kingfisher caching, Supabase CDN, partial indexes, async/await |
| NFR-SCALE | Supabase auto-scaling Postgres, CDN for images, connection pooling |
| NFR-SEC | RLS policies, Keychain storage, server-side validation, rate limiting |
| NFR-ACCESS | VoiceOver labels, Dynamic Type, Reduce Motion, SF Pro system fonts |
| NFR-IOS | iOS 17+ target, iPhone + iPad, Live Activity, WidgetKit, App Store compliance |
| NFR-I18N | String Catalogs (DE/EN), Foundation formatters for locale |
| NFR-DATA | Supabase data export API, account deletion Edge Function, Apple privacy labels |

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Supabase free tier limits hit | Medium | Medium | Monitor usage; upgrade to Pro ($25/mo) at ~5K MAU |
| OpenAI Moderation API downtime | Low | High | Edge Function fallback: hold stories for manual review |
| App Store rejection (content) | Medium | High | Conservative age rating (17+), robust moderation, clear content policy |
| Sign in with Apple token refresh issues | Low | Medium | `supabase-swift` handles refresh; fallback to re-auth prompt |
| Kingfisher cache size on device | Low | Low | Set disk cache limit (200MB); Kingfisher auto-evicts LRU |
| Live Activity limitations (iOS 16.1+ only) | Low | Low | Graceful degradation — timer works without Live Activity on older devices |
