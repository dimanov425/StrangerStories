# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Stranger Stories is a native iOS app (Swift/SwiftUI) where users receive a random atmospheric photo and write a short story in 3 minutes. Stories join a community feed ranked by Wilson score and form a collective anthology.

## Build & Run

```bash
# Prerequisites: brew install xcodegen, Xcode 16+

xcodegen generate                    # Generate .xcodeproj from project.yml
open StrangerStories.xcodeproj       # Open in Xcode, then Build & Run (Cmd+R)
```

Before running: update `StrangerStories/Core/Networking/SupabaseClient.swift` with your Supabase project URL and anon key.

## Testing

```bash
# In Xcode: Cmd+U
# Or CLI:
xcodebuild test -scheme StrangerStories -destination 'platform=iOS Simulator,name=iPhone 16'
```

Unit tests are in `StrangerStoriesTests/`. UI tests in `StrangerStoriesUITests/`.

## Backend (Supabase)

- **Schema:** `Supabase/migrations/001_initial_schema.sql` — 10 tables with RLS, triggers, PL/pgSQL functions
- **Edge Functions** (Deno/TypeScript) in `Supabase/functions/`:
  - `moderate-story` — OpenAI Moderation API, shadowban logic (3+ rejections)
  - `daily-challenge` — Cron: picks daily photo prompt at midnight UTC
  - `delete-account` — GDPR deletion: anonymizes stories, cascading deletes

Deploy with: `supabase functions deploy <function-name>`

## Architecture

**MVVM with @Observable** (iOS 17+, Swift 5.9):

```
App/AppState          → Root state (auth, user session, onboarding)
App/ContentView       → Tab navigation (Write, Feed, Anthology, Profile)
Features/<Name>/      → Feature modules, each with ViewModel + Views
Core/Models/          → Codable structs (snake_case CodingKeys for Supabase)
Core/Repository/      → Swift actors wrapping Supabase queries (thread-safe)
Core/Networking/      → Supabase client singleton
Core/DesignSystem/    → Typography, spacing, haptics, theme colors
```

**Key data flow:** Views bind to `@Observable` ViewModels → ViewModels call `actor` Repositories → Repositories query Supabase.

**Extensions:**
- `StrangerStoriesWidgets/` — WidgetKit daily challenge widget (App Groups for shared data)
- `StrangerStoriesLiveActivity/` — ActivityKit 3-minute writing timer on lock screen

## Key Domain Logic

- **Photo selection:** `PhotoRepository.fetchRandomPhoto()` picks from the 20 least-used active photos for balanced exposure
- **Wilson score ranking:** Postgres function `calculate_wilson_score()` computes lower confidence bound for feed sorting. Recalculated on every rating change via trigger
- **Moderation pipeline:** Story insert → DB trigger → Edge Function → OpenAI check → status update (approved/flagged/pending). 3+ reports auto-hide a story
- **Feed sorts:** recent (newest), topRated (Wilson score), thisWeek (top-rated last 7 days)
- **Auto-save:** Drafts saved every 10 seconds during writing sessions

## Dependencies

Managed via Swift Package Manager (defined in `project.yml`):
- **Supabase 2.0+** — Auth, database, storage, edge functions, realtime
- **Kingfisher 8.0+** — Async image loading and caching

## Project Generation

The Xcode project is generated from `project.yml` via XcodeGen. Edit `project.yml` (not the .xcodeproj) for target config, capabilities, or dependency changes. Always re-run `xcodegen generate` after changes.
