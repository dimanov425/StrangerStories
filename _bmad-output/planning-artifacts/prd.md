---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
inputDocuments:
  - product-brief-StrangerStories.md
  - brainstorming-report.md
workflowType: 'prd'
classification:
  projectType: 'ios-application'
  domain: 'creative-community-platform'
  complexity: 'moderate'
  projectContext: 'greenfield'
status: complete
---

# Product Requirements Document — Stranger Stories

**Author:** Dimai
**Date:** 2026-03-29

---

## Executive Summary

Stranger Stories is a native iOS creative writing application that combines visual prompts, time-pressure writing, community rating, and collective anthology into a single creative game loop. Users receive a random photograph of an atmospheric place and write a short story about it in 3 minutes. Stories are rated by the community, and the best stories are compiled into a living, evolving collective storybook.

### What Makes This Special

- **Creative game, not a writing tool** — The 3-minute constraint and random photo prompt create a game-like experience that makes creative writing accessible to non-writers
- **Collective literary artifact** — The anthology of stories by strangers about the same places is a new form of collaborative literature
- **Zero-barrier entry** — No blank page, no perfectionism, no commitment required
- **Visual-first prompts** — Atmospheric photographs create emotional starting points that text prompts cannot match

### Project Classification

- **Type:** Native iOS Application (iPhone + iPad, iOS 17+)
- **Domain:** Creative Community Platform
- **Complexity:** Moderate (real-time timer, content moderation, community features, image pipeline)
- **Context:** Greenfield — new product, no legacy constraints

---

## Success Criteria

### Launch Metrics (Month 1-3)
- SC-1: 1,000+ stories written
- SC-2: 500+ registered users
- SC-3: Story completion rate > 70% (started timer → submitted story)
- SC-4: Average session duration > 5 minutes
- SC-5: Content moderation false-positive rate < 5%

### Growth Metrics (Month 3-6)
- SC-6: 10,000+ stories written
- SC-7: 30% 7-day user retention
- SC-8: First weekly anthology published
- SC-9: Average rating participation > 2 ratings per story
- SC-10: Community photo submissions pipeline operational

### Scale Metrics (Month 6-12)
- SC-11: 100,000+ stories written
- SC-12: Daily active writers > 500
- SC-13: Anthology export (PDF/ePub) available
- SC-14: Multi-language UI support (DE, EN + 2)

---

## Product Scope

### MVP Scope
- User registration and authentication
- Curated photo pool management (200+ launch photos)
- Random photo assignment with "skip once" option
- 3-minute countdown writing session with auto-save
- Story submission and display
- Community rating system (star-based)
- Story feed with sorting/filtering
- Basic anthology view (top-rated, recent, by photo)
- AI content moderation (pre-publish)
- Native iOS app (iPhone + iPad, iOS 17+)

### Growth Scope
- Daily Challenge (same photo for all users)
- Writing streaks and achievement badges
- Author profiles with story archive
- Themed anthology collections
- Community photo submission pipeline
- Social sharing (story cards with image + excerpt)
- "Rate 2 before you write" engagement mechanic

### Vision Scope
- Weekly curated anthology releases
- Printed book partnership
- Private groups for education
- Audio anthology (TTS narration)
- Interactive map of photo locations
- Multi-language content support
- Real-time collaborative events

---

## User Journeys

### Journey 1: First-Time Writer (New User)

1. User lands on homepage, sees the value proposition and example stories
2. User taps "Write a Story" — prompted to create account (or continue as guest)
3. A random atmospheric photo appears full-screen with a brief moment to absorb it
4. Timer starts (3:00) — user writes in an editor below the photo
5. Auto-save runs every 10 seconds; progress bar shows time remaining
6. Timer reaches 0:00 — story auto-submits with a gentle "Your story was saved" message
7. User sees their completed story alongside the photo
8. User is invited to rate 2 other stories written about different photos
9. User receives a notification when their story gets its first rating

### Journey 2: Returning Writer (Engaged User)

1. User opens app, sees daily streak status and "New photo waiting" prompt
2. Taps to start a new writing session
3. Photo appears — user can "skip once" if the photo doesn't inspire
4. Writes story, submits
5. Browses the story feed, rates several stories
6. Checks profile: sees stats (stories written, average rating, streak)
7. Explores the anthology — reads themed collections

### Journey 3: Reader (Non-Writer)

1. User discovers the anthology through a shared story link
2. Browses stories by photo, by theme, or by top-rated
3. Rates stories they read
4. Bookmarks favorite stories and follows favorite authors
5. Shares a story externally via social card

### Journey 4: Daily Challenge Participant

1. User receives push notification: "Today's Challenge photo is live"
2. Opens app, sees the Daily Challenge photo (same for all users)
3. Writes a story under the same 3-minute constraint
4. After submitting, can immediately read other users' stories about the same photo
5. End of day: sees how their story ranked on the daily leaderboard

### Journey Requirements Summary

| Journey | Key Requirements |
|---------|-----------------|
| J1: First-Time Writer | Guest access, smooth onboarding, auto-save, gentle timer UX |
| J2: Returning Writer | Streaks, skip option, profile/stats, anthology browsing |
| J3: Reader | Browsable feed, rating interface, bookmarks, social sharing |
| J4: Daily Challenge | Shared prompt, leaderboard, post-submit story reveal |

---

## Functional Requirements

### FR-AUTH: Authentication & User Management

- **FR-AUTH-1:** Users can register with Sign in with Apple (required per App Store guidelines) or email/password
- **FR-AUTH-2:** Users can participate as guests for their first story (account creation prompted after)
- **FR-AUTH-3:** Users can view and edit their profile (display name, bio, avatar)
- **FR-AUTH-4:** Users can view their writing history, ratings received, and statistics
- **FR-AUTH-5:** Users can delete their account and all associated data (GDPR compliance)

### FR-PHOTO: Photo Management

- **FR-PHOTO-1:** System maintains a curated pool of atmospheric place photographs (200+ at launch)
- **FR-PHOTO-2:** System assigns a random photo to a user when they start a writing session
- **FR-PHOTO-3:** Users can skip the assigned photo once per session and receive a different one
- **FR-PHOTO-4:** Photos include metadata: photographer credit, source, mood tags, location (optional)
- **FR-PHOTO-5:** System tracks how many stories have been written per photo
- **FR-PHOTO-6:** Administrators can add, remove, and tag photos in the pool
- **FR-PHOTO-7:** Photos are served in optimized formats (HEIF/JPEG, resolution-appropriate) for fast loading

### FR-WRITE: Writing Session

- **FR-WRITE-1:** Users can start a new writing session which displays the assigned photo and a text editor
- **FR-WRITE-2:** A 3-minute countdown timer starts when the user begins writing (first keystroke or explicit "start" action)
- **FR-WRITE-3:** The editor auto-saves the story every 10 seconds during the session
- **FR-WRITE-4:** When the timer reaches zero, the story is automatically submitted
- **FR-WRITE-5:** Users can submit early before the timer expires
- **FR-WRITE-6:** Users see a confirmation screen after submission showing their story and the photo
- **FR-WRITE-7:** Users cannot edit a story after submission (preserves the time-pressure authenticity)
- **FR-WRITE-8:** The editor supports basic text input only (no formatting, no rich text) to keep focus on writing
- **FR-WRITE-9:** Timer accuracy is maintained client-side with server-side validation of submission timestamps
- **FR-WRITE-10:** Users can only have one active writing session at a time

### FR-RATE: Rating System

- **FR-RATE-1:** Users can rate stories on a 1-5 star scale
- **FR-RATE-2:** Users can only rate each story once
- **FR-RATE-3:** Users cannot rate their own stories
- **FR-RATE-4:** Story scores are calculated using Wilson score interval to prevent early-rater bias
- **FR-RATE-5:** Users are prompted to rate at least 2 stories after submitting their own
- **FR-RATE-6:** Rating interface is swipe-friendly for mobile use
- **FR-RATE-7:** Ratings are anonymous — authors see aggregate scores, not individual raters

### FR-FEED: Story Feed & Discovery

- **FR-FEED-1:** Users can browse a feed of published stories
- **FR-FEED-2:** Feed supports sorting by: newest, top-rated (all time), top-rated (this week), most-discussed
- **FR-FEED-3:** Feed supports filtering by: photo, mood tag, language
- **FR-FEED-4:** Each story card in the feed shows: photo thumbnail, story excerpt (first 2 lines), author name, rating, time since published
- **FR-FEED-5:** Users can tap a story card to read the full story with the photo displayed prominently
- **FR-FEED-6:** Users can bookmark/favorite stories for later reading

### FR-ANTH: Anthology (Collective Storybook)

- **FR-ANTH-1:** System compiles stories into an anthology view organized by photo
- **FR-ANTH-2:** Users can browse the anthology by photo, by theme/mood, or by top-rated
- **FR-ANTH-3:** Each anthology "page" shows the photo and all stories written about it, ranked by rating
- **FR-ANTH-4:** The anthology has a "book-like" reading experience with clean typography
- **FR-ANTH-5:** Users can share anthology pages externally via social sharing card (photo + story excerpt + link)

### FR-MOD: Content Moderation

- **FR-MOD-1:** All stories are screened by AI content moderation before publishing
- **FR-MOD-2:** Stories flagged by AI are held for review and not displayed publicly
- **FR-MOD-3:** Users can report stories as inappropriate
- **FR-MOD-4:** Stories with 3+ community reports are automatically hidden pending review
- **FR-MOD-5:** Administrators can review flagged/reported content and approve, reject, or ban the author
- **FR-MOD-6:** Content policy prohibits: hate speech, graphic violence, personally identifiable information, sexually explicit content
- **FR-MOD-7:** Repeat offenders are automatically rate-limited or shadowbanned

### FR-DAILY: Daily Challenge (Growth Feature)

- **FR-DAILY-1:** System selects one photo per day as the Daily Challenge
- **FR-DAILY-2:** All users who participate in the Daily Challenge write about the same photo
- **FR-DAILY-3:** After submitting a Daily Challenge story, users can read all other submissions
- **FR-DAILY-4:** A Daily Challenge leaderboard shows top-rated stories for the current day
- **FR-DAILY-5:** Daily Challenge results are archived and browsable

### FR-STREAK: Engagement & Gamification (Growth Feature)

- **FR-STREAK-1:** System tracks writing streaks (consecutive days with at least one story)
- **FR-STREAK-2:** Users earn achievement badges for milestones (first story, 10 stories, 7-day streak, top 10%)
- **FR-STREAK-3:** Users can view their achievements on their profile
- **FR-STREAK-4:** Streak recovery: missing one day allows recovery by writing 2 stories the next day

---

## Non-Functional Requirements

### NFR-PERF: Performance

- **NFR-PERF-1:** App launch to interactive < 2 seconds (cold start)
- **NFR-PERF-2:** Timer accuracy within 100ms (on-device, no visible drift)
- **NFR-PERF-3:** Auto-save latency < 500ms (non-blocking, background operation)
- **NFR-PERF-4:** Photo loading < 1 second (cached locally, CDN-served)
- **NFR-PERF-5:** Story feed loads first 20 stories within 1 second
- **NFR-PERF-6:** Smooth 60fps scrolling on story feed and anthology views
- **NFR-PERF-7:** App binary size < 30MB (excluding cached photos)

### NFR-SCALE: Scalability

- **NFR-SCALE-1:** System supports 1,000 concurrent writing sessions
- **NFR-SCALE-2:** System supports 10,000 concurrent readers
- **NFR-SCALE-3:** Database handles 100,000+ stories without query degradation
- **NFR-SCALE-4:** Image storage scales independently of application logic

### NFR-SEC: Security

- **NFR-SEC-1:** All data transmitted over HTTPS/TLS
- **NFR-SEC-2:** User passwords hashed with bcrypt or equivalent (server-side)
- **NFR-SEC-3:** API rate limiting: max 10 story submissions per user per hour
- **NFR-SEC-4:** Authentication tokens stored in iOS Keychain (not UserDefaults)
- **NFR-SEC-5:** Input sanitization on all user-submitted text (server-side)
- **NFR-SEC-6:** No user data exposed in API responses beyond what the requesting user owns
- **NFR-SEC-7:** Row Level Security (RLS) on all database tables

### NFR-ACCESS: Accessibility

- **NFR-ACCESS-1:** Full VoiceOver support on all screens with meaningful labels and hints
- **NFR-ACCESS-2:** Dynamic Type support across all text — UI scales from xSmall to AX5
- **NFR-ACCESS-3:** Reduce Motion support — disable all non-essential animations when enabled
- **NFR-ACCESS-4:** Sufficient color contrast ratios (4.5:1 minimum for text)
- **NFR-ACCESS-5:** Switch Control and Voice Control compatible navigation
- **NFR-ACCESS-6:** Bold Text preference respected throughout the app

### NFR-IOS: iOS Platform Requirements

- **NFR-IOS-1:** Minimum deployment target iOS 17.0
- **NFR-IOS-2:** Universal app supporting iPhone and iPad (adaptive layout)
- **NFR-IOS-3:** Writing experience optimized for on-screen keyboards with keyboard avoidance
- **NFR-IOS-4:** 44pt minimum tap targets on all interactive elements per Apple HIG
- **NFR-IOS-5:** App Store Review Guidelines compliance (content ratings, Sign in with Apple, privacy nutrition labels)
- **NFR-IOS-6:** Support for Light and Dark appearance modes
- **NFR-IOS-7:** Live Activity support for the writing timer (iOS 16.1+ devices)

### NFR-I18N: Internationalization

- **NFR-I18N-1:** UI supports German and English at launch via Xcode String Catalogs (`.xcstrings`)
- **NFR-I18N-2:** Stories can be written in any language (no language restriction on content)
- **NFR-I18N-3:** Date, time, and number formatting follows device locale via Foundation formatters

### NFR-DATA: Data & Privacy

- **NFR-DATA-1:** GDPR compliant: data export and deletion on request
- **NFR-DATA-2:** No third-party tracking SDKs; analytics via privacy-friendly first-party solution or Apple App Analytics
- **NFR-DATA-3:** User data retained only as long as account is active
- **NFR-DATA-4:** Story data is owned by the author; clear terms of service for anthology inclusion

### NFR-LEGAL: Legal & Licensing

- **NFR-LEGAL-1:** All photos in the pool must have verified licensing (CC0, licensed, or user-submitted with rights transfer)
- **NFR-LEGAL-2:** Photo attribution displayed alongside stories where required by license
- **NFR-LEGAL-3:** Terms of service clearly state that submitted stories may appear in the collective anthology
- **NFR-LEGAL-4:** AI-generated content detection disclosed in terms of service

---

## Project Scoping & Phased Development

### Phase 1: MVP (Weeks 1-8)
Core writing loop, basic community features, content moderation.

**Included:** FR-AUTH (1-4), FR-PHOTO (1-7), FR-WRITE (1-10), FR-RATE (1-7), FR-FEED (1-6), FR-ANTH (1-3), FR-MOD (1-6)

**Excluded from MVP:** FR-DAILY, FR-STREAK, FR-ANTH-4/5, FR-AUTH-5, FR-MOD-7

### Phase 2: Growth (Weeks 9-16)
Daily Challenge, gamification, social features, enhanced anthology.

**Added:** FR-DAILY (1-5), FR-STREAK (1-4), FR-ANTH-4/5, FR-AUTH-5, FR-MOD-7

### Phase 3: Scale (Weeks 17+)
Multi-language, export, education features, community photo pipeline.

**Added:** PDF/ePub export, community photo submissions, private groups, audio anthology
