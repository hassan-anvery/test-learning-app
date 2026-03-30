# PRIMER.md

## Current Project
Tennis Charting App — iOS app for live tennis match charting with fast, courtside-friendly scoring UX.

## Current Objective
Phase 1 feature completion: filters on history are done; next candidate is better onboarding (player name pre-fill) or a match count indicator in the filter sheet.

## Completed
- Session tagging on match setup and history
- Post-match reflection triggered after match completion
- Editing reflection from match details
- Match detail / summary screen UI polish
- Home screen bottom controls: Filters (left), New Match (center), Reflect (right)
- Reflections view accessible from Reflect button
- Filters V1: session type, result (Win/Loss/In Progress), reflection presence — chip UI, active dot badge, Clear All

## In Progress
- Nothing actively in progress

## Current Branch
- `ui/match-detail-light`

## Next Files to Touch
- `Views/Home/FilterSheetView.swift` — optional: add match count label at sheet bottom
- `Views/Auth/` — onboarding: name-entry screen so playerAName is pre-filled on new matches
- `Views/Home/HomeView.swift` — decide final destination for Reflect button

## Next Steps
1. **`Views/Home/FilterSheetView.swift`** — add a match count label ("3 matches") at the bottom so the user sees result count before dismissing
2. **`Views/Auth/`** — build onboarding: simple name-entry screen before `HomeView` so `playerAName` is pre-filled on new matches
3. **`Views/Home/HomeView.swift`** — decide whether Reflect button stays as reflections list or becomes a different post-session entry point

## Blockers
- Phase 1 feature order after onboarding is not finalized
- Long-term destination for the Reflect button is undecided
