---
name: live-charting-ux
description: UX rules and interaction patterns for the live match charting view (MatchChartingView) in the TennisChartingApp. Use this skill whenever the user is modifying MatchChartingView or NoteEntryView, adding a new button or action to the charting screen, changing how points are recorded, adding undo functionality, modifying the score display, asking about the note entry flow, or designing any feature that will appear during an active live match. Also use when evaluating whether a proposed interaction pattern is appropriate for courtside one-handed use. Also use when the user asks about what to show in MatchScoreSheetView or the Stats drill-down that appears during a live match.
---

# Live Charting UX

## The Context

The user is charting a live tennis match. They're courtside or in the stands, watching the match, phone in one hand. A point happens every 15–30 seconds. They need to tap quickly and accurately without looking away from the court for more than a moment.

This context is the filter for every decision about `MatchChartingView`. If a proposed interaction requires two taps, a confirmation, or reading a modal — it's wrong for this screen.

---

## Current Layout (preserve this structure)

```
┌─────────────────────────────┐
│  [End Match]  SET 1  [Stats]│  ← topBar: non-scoring actions
├─────────────────────────────┤
│                             │
│      PLAYER A BLOCK         │  ← full-width tap area, 32pt v-padding
│    (tap to score point)     │
│                             │
├─────────────────────────────┤
│       GAME SCORE            │  ← scoreCard: always visible center
│        40  -  30            │
├─────────────────────────────┤
│                             │
│      PLAYER B BLOCK         │  ← full-width tap area, 32pt v-padding
│    (tap to score point)     │
│                             │
├─────────────────────────────┤
│  [Note - A]    [Note - B]   │  ← notesBar: secondary actions
└─────────────────────────────┘
```

The score display is always centered and never obscured. The two player blocks are the dominant interactive elements. The notes bar is secondary and disabled until the first point.

---

## Tap Target Rules

- Scoring buttons (playerABlock, playerBBlock): full-width, minimum 32pt vertical padding. The current implementation uses `.frame(maxWidth: .infinity).padding(.vertical, 32)` — this is the floor.
- Note buttons: 12pt vertical padding — acceptable for secondary actions
- Never shrink scoring targets to add new UI. Add new controls to the top bar or a separate view instead.

---

## Interaction Rules for the Scoring Path

**Point award (the most frequent action):**
- Single tap → immediate state update → no confirmation, no animation gate
- The point must register on the first tap. No `.disabled` state while the score updates.
- `scorePoint()` is synchronous (it mutates `@State var match` directly). Keep it that way.

**End of game / end of set:**
- Automatic transition — the next game/set is created immediately in `scoreRegularPoint()`
- No modal, no pause, no "Set won!" interstitial. The score updates and play continues.
- The score number updating IS the visual feedback. Do not add animation overlays, banner notifications, or sounds for game/set transitions.

**Note entry:**
- Use `fullScreenCover` — this is established and intentional. The full screen is taken over so the charting UI is not accidentally tapped through.
- `.interactiveDismissDisabled(true)` is set — keep it. The user must explicitly finish/cancel.
- Do not change note entry to `.sheet` — the half-sheet leaves the scoring buttons exposed.
- Notes are optional and asynchronous to scoring — they attach to the last recorded point.

**End match:**
- The only action in the charting view that warrants a confirmation (`.alert`) — because ending the match is irreversible and outside the fast-action scoring flow.
- This is the exception that proves the rule. Do not add similar confirmations to anything on the scoring path.

---

## Undo

Undo is the right safety valve for mis-taps. The correct implementation:

```swift
@State private var undoStack: [Match] = []

private func scorePoint(for player: PlayerSide) {
    undoStack.append(match)   // snapshot before mutating
    // ... existing scoring logic
}

private func undoLastPoint() {
    guard let previous = undoStack.popLast() else { return }
    match = previous
    MatchStore.shared.updateMatch(match)
}
```

- Use a full `Match` snapshot stack — not a point log. A point log cannot undo game or set transitions.
- Place an "Undo" button in the `topBar`, to the left of the SET indicator. No confirmation needed.
- Cap the stack at ~20 entries to avoid unbounded memory growth.
- Do not use swipe-to-undo — too easy to trigger accidentally on a phone held courtside.

---

## What to Avoid

| Pattern | Why it's wrong here |
|---------|---------------------|
| `.alert` on the scoring path | Blocks tap area, requires two taps to dismiss |
| `.sheet` for note entry | Leaves scoring buttons visible and accidentally tappable |
| Swipe gestures for scoring | Fires on incidental phone movement |
| Confirmation before point is recorded | Slows down charting; points happen faster than confirmations |
| Spinner / loading state during point award | `scorePoint()` is synchronous — there is no async work |
| New overlapping UI on the score display | Score must always be readable at a glance |
| Multi-step sequences on the scoring path | One tap = one point, always |

---

## Adding New Features to the Charting View

If a proposed feature would appear during active charting:

1. **Can it be secondary?** The `topBar` already has three items (End Match | SET indicator | Stats). One more icon-only button fits; more than that requires a submenu or overflow menu. Don't push the centered SET indicator off-axis. Alternatively, drill down from the existing "Stats" button. Don't put new controls between the player blocks.
2. **Does it need immediate input?** Use `fullScreenCover`. Don't use `.sheet` (partial coverage) or `.alert` (blocks everything).
3. **Does it touch the scoring path?** It must remain a single tap with no confirmation.
4. **Will it be needed mid-point?** If no, it can live in a post-game or post-set flow triggered automatically. Don't interrupt active charting.

Features that are genuinely non-urgent (match notes, player tags, surface type) belong in `MatchSetupView` (before) or `MatchDetailView` / `MatchScoreSheetView` (after), not in `MatchChartingView`.
