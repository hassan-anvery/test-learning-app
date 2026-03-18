---
name: tennis-scoring-logic
description: Tennis scoring rules, edge cases, and implementation guidance for the TennisChartingApp. Use this skill whenever the user is modifying scoring logic, adding a new match format, touching tiebreak behavior, changing server alternation, asking about scoring edge cases, or debugging unexpected score states. Also use when the user asks why a score looks wrong, or wants to add no-ad scoring, advantage sets, or a match tiebreak format.
---

# Tennis Scoring Logic

This skill covers the complete scoring rules for the app and how they map to the existing Swift implementation. Always read this before modifying any scoring-related code.

## The Implementation to Extend

All scoring lives in `MatchChartingView.swift`. The three entry points are:

- `scorePoint(for:)` — dispatches to regular or tiebreak scoring; creates initial set/game if needed
- `scoreRegularPoint(for:setIndex:)` — handles point, game, and set transitions
- `scoreTiebreakPoint(for:setIndex:)` — handles tiebreak point and tiebreak win

The data model lives in `Models/Models.swift`:

| Type | Role |
|------|------|
| `Match` | Root container; tracks sets, format, server (`firstServer`), completion. Note: `startingPlayer` is positional (who appears on top), not who serves first. |
| `MatchSet` | Tracks games + tiebreak state (`isTiebreak`, `tiebreakScore`) |
| `TiebreakScore` | Two Int counters + `winner` computed property |
| `Game` | Tracks points + server + `winner` computed property |
| `GameScore` | Enum: `.love / .fifteen / .thirty / .forty / .advantage` |
| `Point` | One point: winner + optional notes |

**Rule: extend, don't rewrite.** Don't add a separate scoring engine class. The logic belongs in the methods above.

---

## Complete Scoring Rules

### Game (4+ points, 2-point lead)

```
0 → 15 → 30 → 40 → Game
```

At 40-40 (both players at 3+ points, tied): **Deuce**
- One player wins a point → **Advantage** for that player
- Advantage player wins → **Game**
- Advantage player loses → back to **Deuce** (still at 3 pts each, tied)

**In the code:** `Game.winner` fires when `points >= 4 && points - opponentPoints >= 2`.
`GameScore.from(points:opponentPoints:)` returns `.forty` for both deuce and the trailing player at 40+, and `.advantage` for the leading player. The display "40" therefore covers both the normal 40 and the "deuce" state — this is intentional. There is no `.deuce` case and none should be added. If a distinct "Deuce" display is needed, add a computed property to the view (e.g., `var isDeuceDisplay: Bool`) rather than a new enum case — the enum is `Codable` and adding a case is a breaking change for persisted data.

### Set (first to 6 with 2-game lead, or tiebreak)

Win conditions (checked by `MatchSet.winner`):
- 6-0, 6-1, 6-2, 6-3, 6-4 → winner
- 7-5 → winner (the trailing player won 5 but the leader went to 7)
- At 6-6: tiebreak is played → tiebreak winner takes the set 7-6

`MatchSet.isAtTiebreak` returns `true` when both game counts equal 6. `scorePoint()` checks this and initializes `tiebreakScore` at that moment.

### Tiebreak (first to 7 with 2-point lead)

Win condition (checked by `TiebreakScore.winner`):
- `points >= 7 && points - opponentPoints >= 2`
- At 6-6 in the tiebreak, keep going (7-7, 8-6 wins, etc.)

No nested tiebreak. No cap.

### Match Format (`MatchFormat.setsToWin`)

| Format | Sets to win |
|--------|-------------|
| Best of 1 | 1 |
| Best of 3 | 2 |
| Best of 5 | 3 |

`Match.winner` returns the first player to reach `setsToWin` sets.

### Server Alternation

`determineServer(for set: MatchSet)` in `MatchChartingView.swift`:
- Alternates based on `set.games.count % 2` and `match.firstServer`
- Even number of completed games → `firstServer` serves
- Odd number → other player serves
- **Important:** This logic resets at each new set — `set.games.count` restarts at 0. This means the server at the start of each new set is always `firstServer` alternating from 0, not carried over from the previous set's last game. If you add cross-set server tracking, you'll need to thread the last server through `Match` or compute it from the full game history.

---

## Edge Cases to Handle Correctly

**Advantage after deuce:** When both players reach 3 points each (equal), `GameScore` returns `.forty` (displays "40"). The next point gives `.advantage` to the winner. The subsequent point either wins the game or returns both to 3 points each (deuce again). `Game.winner` handles this correctly — it only fires at 4+ points with a 2-point spread.

**Tiebreak at 6-6 in tiebreak:** `TiebreakScore.winner` correctly requires `>= 7` with a 2-point lead — it won't fire at 6-6. Don't add a cap or a "sudden death" check here.

**Set at 7-5:** `MatchSet.winner` checks `aGames >= 6 && aGames - bGames >= 2`. At 7-5, `7 >= 6` and `7 - 5 = 2` → correct. No special case needed.

**New set initialization:** `scoreRegularPoint` appends a new `MatchSet` with the first game already included — look for the block inside `if let setWinner = match.sets[setIndex].winner` that calls `newSet.games.append(newGame)` before `match.sets.append(newSet)`. Don't create a bare `MatchSet()` without adding an initial `Game` — the current game computed properties depend on `games.last`.

**Match completion:** `checkMatchCompletion()` fires after every point — it sets `match.isCompleted = true` when `match.winner != nil`. The `onChange(of: match.isCompleted)` in the view body then saves and dismisses. Don't bypass this by setting `isCompleted` directly elsewhere.

---

## Formats Not Yet Implemented (If Adding)

**No-ad scoring:** At deuce (3-3), the very next point wins. To implement: add `noAdScoring: Bool` to `Match`. In `Game.winner`, add a check *before* the existing conditions: `if noAdScoring && a == 4 && b == 3 { return .playerA }` and vice versa. This fires as soon as one player reaches 4 points from 3-3, bypassing the normal 2-point lead requirement. The existing `a >= 4 && a - b >= 2` logic remains unchanged for all other score states.

**Advantage sets:** No tiebreak at 6-6; keep playing until 2-game lead. To implement: add a `setFormat: SetFormat` enum to `Match`, and change `MatchSet.isAtTiebreak` to return `false` when format is `.advantage`.

**Match tiebreak (10-point super-tiebreak):** Used as a deciding set (3rd in best-of-3) instead of a full set. To implement: detect "deciding set" in `scorePoint()`, start a `TiebreakScore` immediately at set start, and change `TiebreakScore.winner` to require `>= 10` with 2-point lead for that set. Don't change the 7-point tiebreak logic — add a separate `isSuperTiebreak` flag.
