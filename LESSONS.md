# LESSONS.md

## Architecture
- Use `@Observable` services with `@Environment(ServiceType.self)`; do not introduce `ObservableObject`, `@Published`, `@StateObject`, or `@ObservedObject`.
- Keep persistence in `UserDefaults` via existing services unless explicitly asked to change storage architecture.
- Do not introduce Combine, SwiftData, CoreData, or external packages unless explicitly approved.

## Navigation
- Preserve `ContentView` Group-based conditional routing.
- Do not introduce `NavigationStack` path-based navigation unless explicitly requested.

## Scoring
- Extend existing scoring methods in `MatchChartingView.swift`; do not create a separate scoring engine.
- Be careful with server logic, tiebreak logic, and set win conditions before changing scoring behavior.

## Live Charting UX
- Do not shrink scoring buttons or add friction to the scoring path.
- No confirmation modals, alerts, or multi-step interactions during point entry.
- Keep note entry as `fullScreenCover`, not `.sheet`.

## Filters / State
- Filter state uses `Optional` as the "all" sentinel (`nil` = no filter active). Do not introduce a dedicated `FilterModel` struct or an `.all` enum case — the `if let` predicate pattern is sufficient and already established.

## Working Style
- Before editing, identify the smallest viable set of files to touch.
- Prefer minimal, targeted changes over broad refactors.
- Do not change stable architecture while implementing a feature unless the user explicitly asks.
