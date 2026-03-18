# CLAUDE.md — Tennis Charting App

This file provides guidance to Claude Code when working with code in this repository.

## Build Commands

```bash
# Build from command line
xcodebuild -project TennisChartingApp/TennisChartingApp.xcodeproj \
  -scheme TennisChartingApp -sdk iphonesimulator build

# Run tests (when test targets are added)
xcodebuild -project TennisChartingApp/TennisChartingApp.xcodeproj \
  -scheme TennisChartingApp -sdk iphonesimulator test
```

Or open `TennisChartingApp/TennisChartingApp.xcodeproj` in Xcode and use Cmd+B / Cmd+R.

## Project Structure

```
TennisChartingApp/
├── TennisChartingApp.xcodeproj
└── TennisChartingApp/
    ├── TennisChartingAppApp.swift      # @main entry point; injects service singletons via .environment(). Add new services here.
    ├── ContentView.swift               # Root navigation (Group-based conditional routing)
    ├── Assets.xcassets/
    ├── Models/
    │   └── Models.swift                # ALL data types — single source of truth
    ├── Services/
    │   ├── AuthManager.swift           # User auth, UserDefaults-backed
    │   └── MatchStore.swift            # Match CRUD + persistence
    └── Views/
        ├── Auth/                       # WelcomeView, OpeningView, LoginView, SignUpView
        ├── Home/                       # HomeView, MatchDetailView
        ├── Match/                      # MatchChartingView (core), MatchSetupView,
        │                               # NoteEntryView, MatchScoreSheetView
        ├── Stats/                      # StatsView, MatchStatsDetailView
        ├── Profile/                    # ProfileView
        └── Components/                 # TennisBallLogo
```

## Architecture Rules

**State management — use `@Observable` exclusively:**
- Service classes: `@Observable @MainActor class` (AuthManager, MatchStore are singletons)
- Inject services into views via `@Environment(ServiceType.self)`
- Local view state: `@State`
- Pass mutable state down: `@Binding`
- Do NOT use: `ObservableObject`, `@Published`, `@StateObject`, `@ObservedObject`
- Do NOT introduce: Combine, SwiftData, CoreData, or any external packages

**Concurrency:**
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` — views and services are implicitly MainActor
- Do not add `Task { }` wrappers for state mutations. The app has no async operations — all persistence (UserDefaults) and scoring are synchronous.
- Storage is UserDefaults only (via MatchStore and AuthManager)

**Navigation:**
- ContentView uses `Group`-based conditional routing — keep this pattern
- Do not introduce `NavigationStack` path-based navigation — this would require restructuring every view's init signature and the ContentView routing logic. Only refactor navigation if explicitly requested.

## Tennis Scoring Rules

This app implements standard tennis scoring. Before modifying any scoring code, know these rules:

**Game scoring** (`GameScore` enum, `Game.winner` in Models.swift):
- Points: 0 → 15 → 30 → 40 → Game (win at 4+ points with 2-point lead)
- Deuce: both players at 3+ points and tied → displayed as "40-40"
- Advantage: one player leads after deuce → displayed as "Ad"
- Win from advantage: score again; lose from advantage: back to deuce (both back to 3 pts equal)

**Set scoring** (`MatchSet.winner`, `MatchSet.isAtTiebreak` in Models.swift):
- Win: first to 6 games with a 2-game lead (6-0 through 6-4), or 7-5
- Tiebreak: triggered at exactly 6-6 games (`isAtTiebreak`)

**Tiebreak scoring** (`TiebreakScore.winner` in Models.swift):
- Win: first to 7 points with a 2-point lead (keeps going at 6-6, 7-7, etc.)
- No nested tiebreak — just keep scoring

**Match scoring** (`Match.winner`, `MatchFormat.setsToWin`):
- Best of 1: 1 set to win
- Best of 3: 2 sets to win
- Best of 5: 3 sets to win

**Note on `Match` fields:** `firstServer: PlayerSide` is who serves first in the match. `startingPlayer: PlayerSide` is who the app treats as "Player A" positionally (top of screen). These are separate. `determineServer()` uses `firstServer`, not `startingPlayer`.

**Server alternation** (`determineServer()` in MatchChartingView.swift):
- Alternates every game within a set based on `firstServer` and `set.games.count % 2`
- Note: server tracking resets to `firstServer` logic at each new set — be aware if extending this

**Key implementation note — don't rewrite the scoring engine:**
All scoring lives in `scorePoint()`, `scoreRegularPoint()`, `scoreTiebreakPoint()` in `MatchChartingView.swift`. Extend these methods; do not add a separate scoring engine class. A separate engine would require synchronizing its state with `@State var match` on the view — an unnecessary complication for this architecture.

## Live Charting UX Constraints

`MatchChartingView` is the entire reason this app exists. The user is courtside, one hand on phone, watching a live match. Points happen every 15–30 seconds.

**Non-negotiable rules:**
- Tap targets: scoring buttons must be large (current: full-width, 32pt vertical padding). Never shrink them.
- No confirmations on the scoring path. A point tap must register immediately.
- `fullScreenCover` for note entry (`NoteEntryView`) — do not change to `.sheet`. The score UI must not be visible/interactive underneath.
- End-of-game and end-of-set transitions are automatic — no modal interruption.
- If undo is needed, implement it as a `[Match]` snapshot stack — see the live-charting-ux skill. It does not exist yet.

**Avoid:**
- `.alert` for scoring decisions during play
- Swipe gestures for scoring (too easy to misfire)
- Multi-step taps on the critical scoring path
- Any loading state or async wait visible during point award

**Pattern to preserve:**
- Score display (scoreCard) always visible in the center
- Player tap blocks above and below
- Notes bar at the bottom, disabled until first point is recorded

## Key Configuration

- Bundle ID: `com.hassan.TennisChartingApp`
- Minimum iOS: 26.2
- Swift strict concurrency with `MainActor` default isolation
- Supports all orientations on iPad, portrait + landscape on iPhone
