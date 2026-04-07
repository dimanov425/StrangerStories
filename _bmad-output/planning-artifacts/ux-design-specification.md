---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
inputDocuments:
  - prd.md
  - product-brief-StrangerStories.md
workflowType: 'ux-design'
status: complete
platform: 'ios-native'
designLanguage: 'Apple Human Interface Guidelines'
---

# UX Design Specification — Stranger Stories (iOS)

**Author:** Dimai
**Date:** 2026-03-29
**Platform:** Native iOS (SwiftUI, iOS 17+)
**Design Language:** Apple Human Interface Guidelines

---

## 1. Executive Summary

### Project Vision
Stranger Stories is a native iOS creative game where atmospheric photography meets time-pressured writing. The app follows Apple Human Interface Guidelines to deliver a experience that feels like it belongs on the platform — leveraging SF Pro typography, system materials, haptic feedback, Live Activities, and native navigation patterns. The design balances Apple's principles of **Clarity**, **Deference**, and **Depth** with the app's literary, atmospheric mood.

### Target Users
1. **Curious Creatives (18-35)** — iPhone-first, want novel experiences, not "writers" by identity
2. **Hobbyist Writers (25-45)** — iPhone and iPad, value the creative constraint, want feedback and progress tracking
3. **Readers (all ages)** — Browsing-focused, discovery-oriented, share content via Messages/social

### Key Design Challenges
- The writing session must feel immersive — the timer is a creative catalyst, not an exam clock
- On-screen keyboard writing in 3 minutes yields ~120-150 words; the UX must make this feel sufficient
- Transitioning from "writing mode" (focused, solo) to "community mode" (browsing, rating) requires a mood shift
- The anthology must feel like a curated book, not a database — using Apple's reading conventions

### Design Opportunities
- **Live Activity** on Lock Screen and Dynamic Island shows the countdown timer — writing becomes ambient
- **Haptic feedback** creates physical rhythm during the writing session — taps mark key moments
- **SF Symbols** provide a consistent, scalable icon language across all UI states
- **Materials and vibrancy** let the atmospheric photos bleed through UI layers naturally
- **Dynamic Type** makes the app accessible to all readers without custom scaling logic

---

## 2. Core User Experience

### 2.1 Defining Experience
A full-screen photograph of a dimly lit corridor fades in. The user pauses, absorbs it. They tap "Begin Writing" — a light haptic confirms the start. The timer appears as a thin progress bar with the remaining time in SF Mono on the Dynamic Island. For 3 minutes, the keyboard is up and nothing else exists. When the timer ends, a success haptic fires, and the story appears with a gentle spring animation. Their words join hundreds of others — strangers who saw the same corridor and imagined completely different worlds.

### 2.2 Mental Model
Users should think of Stranger Stories as:
- **A daily creative ritual** — like Wordle, but for imagination
- **A gallery walk** — each photo is a piece of art; each story is a response to it
- **A campfire** — strangers sharing stories inspired by the same place

### 2.3 Experience Principles (Mapped to Apple HIG)

| Principle | Apple HIG Alignment | Implementation |
|-----------|-------------------|----------------|
| **Atmosphere First** | Deference — content over chrome | Photos fill the screen; UI recedes using materials and vibrancy |
| **Gentle Pressure** | Clarity — clear, non-alarming feedback | Timer as thin progress bar, haptic pulse at 30s, Live Activity on lock screen |
| **Imperfection Welcome** | Consistency — familiar, friendly language | System-standard copy patterns, warm tone in localized strings |
| **Discovery Over Feed** | Depth — visual layering and navigation hierarchy | NavigationStack with drill-down, not infinite scroll |
| **Solitude to Community** | Consistency — predictable mode transitions | Full-screen cover for writing, tab bar returns for community |

### 2.4 Novel UX Patterns (iOS-Native)
- **Atmosphere Reveal** — Photo fades in with a 2-second `asymmetric` animation; user absorbs it before writing
- **Haptic Heartbeat** — `UIImpactFeedbackGenerator(.light)` pulses subtly during the final 30 seconds, quickening pace
- **Live Activity Timer** — Countdown appears on Lock Screen and Dynamic Island via ActivityKit
- **Story Reveal** — After submission, story text appears with `.spring(response: 0.5, dampingFraction: 0.8)` animation
- **Strangers Count** — Every photo shows "N strangers wrote about this place" with `.secondaryLabel` color

---

## 3. Design System Foundation — Apple HIG

### Typography

All text uses the iOS system type scale with Dynamic Type support. Custom literary font (New York) used only for story reading.

| Role | Font | Text Style | Scales With |
|------|------|------------|-------------|
| Large titles (screen headers) | SF Pro Display | `.largeTitle` | Dynamic Type |
| Section headers | SF Pro Display | `.title2` | Dynamic Type |
| Body text (UI, descriptions) | SF Pro Text | `.body` | Dynamic Type |
| Story reading | New York (serif) | `.body` | Dynamic Type via `UIFontMetrics` |
| Captions, metadata | SF Pro Text | `.caption` | Dynamic Type |
| Buttons, labels | SF Pro Text | `.headline` / `.subheadline` | Dynamic Type |
| Timer display | SF Mono | `.title` (custom size 48pt) | Fixed (does not scale) |
| Writing editor | SF Mono | `.body` | Dynamic Type |

**Rules:**
- All text MUST support Dynamic Type (xSmall through AX5) except the timer countdown display
- Story reading uses Apple's New York serif font for literary quality — loaded via `UIFont.preferredFont(forTextStyle:)` with `.withDesign(.serif)`
- Bold Text accessibility preference is respected via system font weight adaptation

### Colors

The app uses iOS semantic colors as its foundation, with a custom warm amber accent color. The app defaults to dark appearance to match the atmospheric mood, but fully supports light mode.

| Token | iOS Semantic Color | Usage |
|-------|-------------------|-------|
| Background | `Color(.systemBackground)` | Primary background |
| Surface | `Color(.secondarySystemBackground)` | Cards, grouped list backgrounds |
| Elevated | `Color(.tertiarySystemBackground)` | Sheets, modals |
| Text Primary | `Color(.label)` | Main body text |
| Text Secondary | `Color(.secondaryLabel)` | Supporting text, metadata |
| Text Tertiary | `Color(.tertiaryLabel)` | Timestamps, placeholder text |
| Separator | `Color(.separator)` | Dividers between list rows |
| Accent (Tint) | Custom `Color("AccentWarm")` = `#c4956a` | CTAs, timer, highlights, tab bar tint |
| Accent Hover | Custom `Color("AccentWarmLight")` = `#d4a57a` | Pressed/highlighted accent states |
| Success | `Color.green` (system) | Completion states, auto-save indicator |
| Error | `Color.red` (system) | Error states, content flags |
| Warning | `Color.orange` (system) | Warning states |

**Rules:**
- The custom accent color is set as the app's global `accentColor` in `Assets.xcassets`
- All other colors use iOS semantic colors — they automatically adapt to light/dark mode and accessibility settings (Increase Contrast, etc.)
- Never hardcode hex values in SwiftUI views — always reference semantic colors or named asset colors
- The app's `Info.plist` sets `UIUserInterfaceStyle = Dark` as default, but users can override in Settings

### Icons — SF Symbols

All icons use SF Symbols. No custom icon assets except the app icon.

| Context | Symbol | Variant |
|---------|--------|---------|
| Write tab | `pencil.line` | `.fill` when selected |
| Feed tab | `square.grid.2x2` | `.fill` when selected |
| Anthology tab | `book` | `.fill` when selected |
| Profile tab | `person.circle` | `.fill` when selected |
| Timer | `timer` | — |
| Star rating (empty) | `star` | — |
| Star rating (filled) | `star.fill` | — |
| Bookmark | `bookmark` / `bookmark.fill` | Toggle |
| Share | `square.and.arrow.up` | — |
| Report/Flag | `flag` | — |
| Skip photo | `arrow.forward` | — |
| Streak flame | `flame` | `.fill` when active |
| Achievement | `trophy` | `.fill` when unlocked |
| Settings | `gearshape` | — |
| Auto-save | `checkmark.circle.fill` | Tinted green |
| Close/Dismiss | `xmark.circle.fill` | — |

**Rules:**
- Use `.symbolRenderingMode(.hierarchical)` for multi-color symbols
- Use `.symbolEffect(.bounce)` for achievement unlock animations
- Tab bar icons: outlined when unselected, `.fill` when selected (standard iOS pattern)

### Spacing & Layout

| Constant | Value | Usage |
|----------|-------|-------|
| Standard margin | 16pt | Leading/trailing content margins |
| Compact margin | 8pt | Inner padding within cards |
| Section spacing | 24pt | Between major content sections |
| Minimum tap target | 44pt x 44pt | All interactive elements |
| Safe area | System-provided | Respected on all screens via `.safeAreaInset` |
| List row height | 44pt minimum | Standard iOS list row |
| Card corner radius | 12pt (`RoundedRectangle(cornerRadius: 12, style: .continuous)`) | Story cards, photo cards |
| Sheet corner radius | System default | Sheets use system presentation |

**Rules:**
- Always use `.continuous` corner curve style (Apple's squircle, not circular arcs)
- Respect safe areas everywhere — never clip content behind the Dynamic Island or home indicator
- Use `LazyVStack(spacing: 12)` or `List` with standard padding — not custom grid systems
- iPad uses readable content width (`.frame(maxWidth: 680)`) for story text

### Materials & Vibrancy

| Context | Material | Usage |
|---------|----------|-------|
| Timer bar over photo | `.ultraThinMaterial` | Timer overlay during writing session |
| Photo credit overlay | `.thinMaterial` | Photographer attribution over photo |
| Tab bar | System default (`.bar` material) | Standard iOS tab bar material |
| Navigation bar | System default | Large title navigation bar |
| Bottom sheet background | `.regularMaterial` | Rating prompt, share sheet |

**Rules:**
- Materials let the photo atmosphere bleed through UI layers — this IS the atmospheric design
- Use `.background(.ultraThinMaterial)` not opaque backgrounds over photos
- Text over materials uses vibrancy via `Color(.label)` — automatically adapts

---

## 4. Screen Inventory & Layout

### S1: Onboarding / First Launch
**SwiftUI:** `TabView` with page-style for onboarding slides
**Layout:** 3-4 onboarding pages explaining the concept, ending with Sign in with Apple button
**Key Elements:**
- Full-screen atmospheric photos as backgrounds
- Large title text: "Write a story in 3 minutes"
- `.signInWithAppleButton` at standard size
- Skip option for guest flow

### S2: Write Tab — Photo Reveal
**SwiftUI:** Full-screen cover (`.fullScreenCover`)
**Layout:** Photo fills viewport using `.ignoresSafeArea()`. Material overlay at bottom with "Begin Writing" button.
**Key Elements:**
- `AsyncImage` loads the photo with a placeholder shimmer
- Photo fills screen edge-to-edge; slight dark gradient at bottom via `LinearGradient`
- "Begin Writing" button: `.borderedProminent` style with accent tint, large size
- Photographer credit in `.caption` style over `.ultraThinMaterial` at bottom-left
- "Skip this photo" as `.plain` button with `arrow.forward` symbol at top-right
- 2-second fade-in animation: `.transition(.opacity).animation(.easeIn(duration: 2))`

### S3: Write Tab — Active Writing Session
**SwiftUI:** Custom view within the full-screen cover
**Layout:** Photo pinned at top (resizes with keyboard), TextEditor below, timer overlay
**Key Elements:**
- Photo at top: 40% of screen height, shrinks to ~20% when keyboard appears (via `GeometryReader` + keyboard observation)
- `TextEditor` with SF Mono font, `.body` text style, plain background
- Timer: thin `ProgressView(.linear)` spanning full width below photo, over `.ultraThinMaterial`
- Time remaining: SF Mono `.title` in top-trailing corner
- Auto-save indicator: small `checkmark.circle.fill` with `.symbolEffect(.pulse)` tinted green
- "Submit Early" as `.bordered` button in bottom-trailing corner
- Word count: `.caption` style in bottom-leading corner
- All navigation hidden — no tab bar, no navigation bar
- **Live Activity** starts when timer begins — shows countdown on Lock Screen / Dynamic Island
- **Haptic:** `UIImpactFeedbackGenerator(.light)` at timer start; `.rigid` pulses every 10s in final 30s

### S4: Write Tab — Submission Confirmation
**SwiftUI:** `.sheet` presentation with `.presentationDetents([.large])`
**Layout:** Story displayed in reading format with photo thumbnail
**Key Elements:**
- Photo thumbnail (rounded, 80pt) with story text below in New York serif font
- "Your raw story" label in `.headline` style — celebrating imperfection
- Stats row: word count, time taken, in `.caption` with `clock` and `textformat.size` symbols
- Primary CTA: "Read & Rate Others" as `.borderedProminent` button
- Secondary CTA: "Write Another" as `.bordered` button
- "N strangers also wrote about this place" in `.secondaryLabel`
- **Haptic:** `UINotificationFeedbackGenerator(.success)` on submission

### S5: Feed Tab — Story Feed
**SwiftUI:** `NavigationStack` + `List` or `LazyVGrid`
**Layout:** Standard iOS list with story cards, segmented control for sorting
**Key Elements:**
- `NavigationStack` with `.navigationTitle("Stories")` and `.navigationBarTitleDisplayMode(.large)`
- `Picker` with `.pickerStyle(.segmented)` for sorting: Recent | Top Rated | This Week
- Story cards as `List` rows or `LazyVGrid` items:
  - Photo thumbnail (60pt, rounded) leading
  - Story excerpt (2 lines, `.lineLimit(2)`)
  - Author name in `.caption`, rating stars in `.caption2`, time ago in `.tertiaryLabel`
- `.refreshable { }` for pull-to-refresh
- `.searchable(text:)` for search within stories
- `.contextMenu` on long-press: Share, Bookmark, Report
- Toolbar button: `pencil.line` symbol to start a new writing session

### S6: Feed Tab — Story Detail
**SwiftUI:** Pushed via `NavigationLink` within the `NavigationStack`
**Layout:** ScrollView with photo hero, story text, rating interface, related stories
**Key Elements:**
- Photo displayed large at top (aspect ratio preserved, edge-to-edge)
- Story text in New York serif, `.body` text style, max readable width (680pt on iPad)
- Author info row: avatar (32pt circle), display name, "N stories written"
- Rating interface: `HStack` of 5 `star`/`star.fill` SF Symbols, tappable with haptic feedback
- "More stories about this place" as horizontal `ScrollView` of `StoryCard` views
- Toolbar items: `ShareLink`, `bookmark` toggle button
- `.toolbar { ToolbarItem(.secondaryAction) { reportButton } }`
- **Haptic:** `UIImpactFeedbackGenerator(.medium)` when star rating is tapped

### S7: Anthology Tab — Cover & Table of Contents
**SwiftUI:** `NavigationStack` with `List` sections
**Layout:** Cover header followed by sectioned list of photo chapters
**Key Elements:**
- `.navigationTitle("Anthology")` with `.large` display mode
- Header: collage of top photos with "The Stranger Stories Anthology" in `.largeTitle`
- `List` with `.listStyle(.insetGrouped)`:
  - Each row = one photo chapter: photo thumbnail (80pt), "N stories" count, top mood tags
  - Rows sorted by story count descending
  - `NavigationLink` to chapter detail
- Section headers by mood tag grouping (optional)

### S8: Anthology Tab — Chapter View
**SwiftUI:** Pushed via `NavigationLink`
**Layout:** Photo hero + list of stories ranked by Wilson score
**Key Elements:**
- Photo displayed large at top with `.ignoresSafeArea(edges: .top)`
- "N strangers wrote about this place" overlay on `.ultraThinMaterial`
- Stories listed below in New York serif font, each as an expandable `DisclosureGroup` or tappable row
- Author name and rating shown for each story
- Clean, generous whitespace — book-like feel via proper line spacing and margins

### S9: Profile Tab
**SwiftUI:** `NavigationStack` with `List` sections
**Layout:** Standard iOS profile — header with avatar/stats, sectioned list of content
**Key Elements:**
- `.navigationTitle("Profile")` with `.large` display mode
- Header section: avatar (80pt circle), display name, bio
- Stats row: `HStack` of labeled values (stories written, avg rating, streak with `flame` symbol, total words)
- Sections:
  - "My Stories" — `NavigationLink` rows with photo thumbnail, rating, date
  - "Bookmarks" — same format, bookmarked stories
  - "Achievements" — `LazyVGrid` of badge circles (locked/unlocked)
  - "Settings" — Edit Profile, Account Deletion, App Info
- "Edit Profile" pushes a `Form` view with `TextField` and `TextEditor`

### S10: Admin (Web Dashboard — Not iOS)
Admin functionality (photo management, moderation queue) is handled via a lightweight web dashboard (Supabase Studio or minimal web admin), not in the iOS app. This is intentional — admin UI is better served by a web interface with table views and bulk actions.

---

## 5. User Journey Flows (iOS-Native)

### Flow 1: First Writing Session

```
App Launch → Onboarding (3 pages)
  └─> [Tap "Sign in with Apple" or "Continue as Guest"]
      └─> Tab Bar appears (Write tab selected)
          └─> Photo Reveal (fullScreenCover, 2s fade-in)
              └─> [Tap "Begin Writing"]
                  └─> Active Writing (3:00 timer + Live Activity starts)
                      ├─> [Timer expires] → Auto-submit + haptic
                      └─> [Tap "Submit Early"] → Submit + haptic
                          └─> Submission Confirmation (.sheet)
                              └─> [Tap "Read & Rate Others"]
                                  └─> Feed tab with rating prompt
```

### Flow 2: Returning User Session

```
App Launch → Feed tab (home for authenticated users)
  └─> [Tap Write tab or pencil toolbar button]
      └─> Photo Reveal (fullScreenCover)
          ├─> [Tap "Skip"] → New Photo Reveal
          └─> [Tap "Begin Writing"]
              └─> Active Writing → Submit → Confirmation sheet
                  └─> Dismiss sheet → Feed tab
```

### Flow 3: Reading & Rating

```
Feed tab → [Tap story row]
  └─> Story Detail (pushed in NavigationStack)
      ├─> [Tap stars] → Rating saved + haptic
      ├─> [Tap "More stories about this place"]
      │   └─> Anthology Chapter (pushed)
      ├─> [Tap ShareLink] → System share sheet
      └─> [Long-press or toolbar] → Report via confirmationDialog
```

### Flow 4: Anthology Browsing

```
Anthology tab → Cover & Table of Contents
  └─> [Tap a photo chapter row]
      └─> Chapter View (photo + ranked stories)
          └─> [Tap a story]
              └─> Story Detail (pushed)
```

---

## 6. Component Strategy (SwiftUI)

### Core Components

| Component | SwiftUI Implementation | States |
|-----------|----------------------|--------|
| `PhotoRevealView` | `AsyncImage` + `.fullScreenCover` + fade animation | loading, revealing, revealed |
| `WritingEditorView` | `TextEditor` with SF Mono, keyboard observation | idle, active, saving, submitted |
| `CountdownTimerView` | `Timer.publish` + `ProgressView(.linear)` + Live Activity | ready, running, warning (< 30s), expired |
| `StoryCardView` | `HStack` with photo thumbnail, excerpt, metadata | default, contextMenu active |
| `StoryReaderView` | `ScrollView` with New York serif text | loading, loaded, error |
| `RatingStarsView` | `HStack` of `Image(systemName:)` with tap gesture + haptics | unrated, hovering, rated, disabled |
| `AnthologyChapterView` | `List` with photo hero and story sections | loading, loaded, empty |
| `UserStatsView` | `HStack` of labeled value pairs | loading, loaded |
| `AchievementBadgeView` | `Circle` with SF Symbol + `.symbolEffect(.bounce)` | locked, unlocked, new |
| `StreakIndicatorView` | `flame` SF Symbol + count label | active, broken, recovering |

### Shared Patterns

- **Loading:** Use `.redacted(reason: .placeholder)` modifier for skeleton-style loading on any view
- **Empty States:** `ContentUnavailableView` (iOS 17) with SF Symbol, title, description, and action button
- **Error States:** `ContentUnavailableView` with retry button; never show raw error text to users
- **Transitions:** `.transition(.opacity.combined(with: .move(edge: .bottom)))` for appearing content
- **Animations:** Prefer `.spring(response: 0.35, dampingFraction: 0.7)` for interactive elements; `.easeInOut(duration: 0.2)` for state changes
- **Reduce Motion:** Wrap all animations in `withAnimation` and check `UIAccessibility.isReduceMotionEnabled` — substitute with instant transitions

### Haptic Feedback Map

| Moment | Generator | Style |
|--------|-----------|-------|
| Timer starts | `UIImpactFeedbackGenerator` | `.light` |
| Auto-save confirmation | `UIImpactFeedbackGenerator` | `.soft` |
| 30-second warning | `UIImpactFeedbackGenerator` | `.rigid` (repeating) |
| Story submitted | `UINotificationFeedbackGenerator` | `.success` |
| Star rating tapped | `UIImpactFeedbackGenerator` | `.medium` |
| Achievement unlocked | `UINotificationFeedbackGenerator` | `.success` |
| Bookmark toggled | `UIImpactFeedbackGenerator` | `.light` |
| Error / failed action | `UINotificationFeedbackGenerator` | `.error` |

---

## 7. iOS-Specific Features

### Live Activity (ActivityKit)

The writing timer appears as a Live Activity on the Lock Screen and in the Dynamic Island for iPhone 14 Pro+ devices.

**Content:**
- Lock Screen: photo thumbnail (small), remaining time (large SF Mono), progress bar
- Dynamic Island (compact): timer countdown + pencil symbol
- Dynamic Island (expanded): photo thumbnail + remaining time + word count

**Lifecycle:**
- Starts when user taps "Begin Writing"
- Updates every second with remaining time
- Ends when story is submitted or timer expires
- Dismisses automatically 5 seconds after completion

### Widgets (WidgetKit)

**Daily Challenge Widget:**
- Small size: today's challenge photo with "Tap to write" label
- Medium size: photo + "Today's Challenge" title + story count so far
- Tapping opens the app directly to the Daily Challenge writing session via deep link

### App Intents

- "Write a Stranger Story" — Siri Shortcut that opens the app to a new writing session
- "Show my writing streak" — returns current streak count via Siri response

### Context Menus

Long-press on story cards in the feed reveals:
- **Share** — generates a share card via `ShareLink`
- **Bookmark** — toggles bookmark with haptic confirmation
- **Report** — opens `.confirmationDialog` with report reasons

---

## 8. Responsive Design (iPhone + iPad)

### iPhone Layout
- Single column throughout
- Tab bar at bottom (standard `TabView`)
- Full-screen writing mode hides tab bar
- Photos scale to screen width
- Story text at full readable width

### iPad Layout
- Two-column `NavigationSplitView` on Feed and Anthology tabs:
  - Sidebar: story list / chapter list
  - Detail: story reader / chapter view
- Writing mode: centered content with comfortable max width (680pt)
- Tab bar at bottom or sidebar navigation (adaptive)
- Multitasking: supports Split View and Slide Over
- Photos displayed at comfortable size with padding, not stretched edge-to-edge

### Shared Rules
- `@Environment(\.horizontalSizeClass)` to detect compact vs regular layout
- Story text always constrained to max readable width: `.frame(maxWidth: 680)`
- Tab bar uses SF Symbols that scale cleanly at all sizes
- All layout respects safe areas including Dynamic Island

---

## 9. Accessibility

### VoiceOver
- All images have `accessibilityLabel` describing the mood: "A dimly lit corridor with peeling wallpaper"
- Timer announces remaining time at 2 minutes, 1 minute, and 30 seconds via `AccessibilityNotification.Announcement`
- Star rating uses `accessibilityValue` ("3 out of 5 stars") and `accessibilityAdjustableAction` for increment/decrement
- Story cards have combined `accessibilityElement(children: .combine)` for a single swipe target
- Writing editor has `accessibilityLabel("Story editor")` and `accessibilityHint("Write your story here")`

### Dynamic Type
- All text scales from xSmall to AX5 (Accessibility Extra Extra Extra Extra Extra Large)
- Layout adapts: horizontal stat rows stack vertically at largest accessibility sizes
- Timer countdown is fixed size (legibility at a glance matters more than scaling)
- Story cards show fewer lines of excerpt at larger sizes to prevent overflow

### Reduce Motion
- Photo fade-in becomes instant appear
- Timer progress bar does not pulse
- Story reveal appears instantly without spring animation
- Tab bar transitions are instant
- All `withAnimation` blocks check `UIAccessibility.isReduceMotionEnabled`

### Other
- Bold Text preference: text weights shift up one level when enabled (system handles automatically with SF Pro)
- Increase Contrast: semantic colors automatically adapt
- Switch Control / Voice Control: all interactive elements have proper accessibility traits

---

## 10. UX Consistency Patterns

### Micro-Copy Voice
- Warm, literary, slightly mysterious — consistent across all localized strings
- Celebrate imperfection: "Your raw story" not "Your submission"
- Encourage: "47 strangers wrote about this place. What do you see?"
- Use Apple-standard patterns for system actions: "Delete", "Cancel", "Done"

### Feedback Patterns
- **Success:** Haptic + brief inline confirmation (no alert for routine success)
- **Error:** `.alert` with clear message and retry action
- **Loading:** `.redacted(reason: .placeholder)` shimmer on content views
- **Empty:** `ContentUnavailableView` with relevant SF Symbol and call to action
- **Destructive:** `.confirmationDialog` with destructive button style (red text)

### Navigation Model
- **TabView** with 4 tabs: Write, Feed, Anthology, Profile
- Each tab has its own `NavigationStack` — navigation state is preserved per tab
- Writing session: `.fullScreenCover` — completely modal, no tab bar
- Sheets: used for submission confirmation, rating prompts, and settings forms
- Back navigation: system back button (chevron.left), swipe-from-left-edge gesture (standard iOS)

### Interaction Patterns
- Tap as primary interaction; long-press for context menus on story cards
- Swipe-to-dismiss on all sheets (standard iOS behavior)
- Pull-to-refresh on feed and anthology via `.refreshable`
- No custom gestures that conflict with system gestures (swipe-from-edge = back)
- Destructive actions always require `.confirmationDialog` (not just a button)
- No custom alert presentations — always use system `.alert` and `.confirmationDialog`
