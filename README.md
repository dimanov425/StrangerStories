# Stranger Stories

A native iOS app where atmospheric photography meets time-pressured creative writing. You receive a random photo of a place, write a short story in 3 minutes, and your words join a collective anthology from the community.

## Architecture

- **Client:** SwiftUI (iOS 17+), MVVM with `@Observable`
- **Backend:** Supabase (Postgres, Auth, Storage, Edge Functions, Realtime)
- **Auth:** Sign in with Apple + email/password
- **Images:** Supabase Storage + Kingfisher caching
- **Moderation:** OpenAI Moderation API via Supabase Edge Function

## Project Structure

```
StrangerStories/
├── StrangerStories/          # Main iOS app
│   ├── App/                  # Entry point, AppState, ContentView, AppIntents
│   ├── Features/             # Feature modules (Auth, Write, Feed, etc.)
│   ├── Core/                 # Models, Repositories, Networking, DesignSystem
│   └── Resources/            # Assets, Localization
├── StrangerStoriesWidgets/   # WidgetKit daily challenge widget
├── StrangerStoriesLiveActivity/  # ActivityKit writing timer
├── Supabase/
│   ├── migrations/           # Database schema SQL
│   └── functions/            # Edge Functions (moderation, account deletion, daily challenge)
├── project.yml               # XcodeGen project specification
└── _bmad-output/             # BMAD Method planning artifacts
```

## Setup

### Prerequisites

- Xcode 16+
- iOS 17+ device or simulator
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)
- A Supabase project ([supabase.com](https://supabase.com))

### Steps

1. **Generate Xcode project:**
   ```bash
   cd StrangerStories
   xcodegen generate
   ```

2. **Configure Supabase:**
   - Create a Supabase project
   - Run `Supabase/migrations/001_initial_schema.sql` in the SQL editor
   - Deploy Edge Functions: `supabase functions deploy moderate-story`
   - Enable Apple OAuth in Supabase Auth settings
   - Update `SupabaseClient.swift` with your project URL and anon key

3. **Configure Xcode:**
   - Open `StrangerStories.xcodeproj`
   - Set your Development Team
   - Enable capabilities: Sign in with Apple, Push Notifications, App Groups

4. **Run:**
   - Build and run on iOS 17+ simulator or device

## BMAD Planning

All planning artifacts are in `_bmad-output/planning-artifacts/`:
- Product Brief, PRD, UX Design Spec, Architecture, Epics, Readiness Report

Built using the [BMAD Method](https://github.com/bmad-code-org/BMAD-METHOD).
