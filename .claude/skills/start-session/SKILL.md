---
name: start-session
description: Session startup for the tennis charting app — reads project docs and produces an actionable session brief
type: process
---

# Start Session

You are starting a new coding session on this tennis charting iOS app. Before doing anything else — before answering questions, before exploring code, before making any suggestions — read these three files in order:

1. `CLAUDE.md` — architecture rules, build commands, project structure, constraints
2. `PRIMER.md` — current project state and the most recent handoff
3. `LESSONS.md` — recurring patterns and preferences from past sessions

Read all three fully. Then produce the session brief below. Do not skip sections or combine them.

---

## Session Brief Format

### 1. Project State
What exists and works today. One short paragraph. Be specific — name real features, not generalities.

### 2. Recently Completed
Bullet list of what was completed in recent sessions, drawn directly from PRIMER.md. Do not infer or add.

### 3. Current Objective
The single active goal for this session, as stated in PRIMER.md. One sentence.

### 4. Constraints / Do Not Touch
Bullet list of architectural rules and no-go zones from CLAUDE.md and LESSONS.md that apply to the current objective. Only include items relevant to the likely work ahead.

### 5. Most Likely Files to Touch
Named Swift files (e.g. `HomeView.swift`, `Models.swift`) based on PRIMER.md's next steps and CLAUDE.md's project structure. Be specific — no generic answers like "views and models".

### 6. Recommended First Step
One concrete, specific action to take right now. Reference a real file and a real task (e.g. "Open `HomeView.swift` and add a bottom toolbar with three buttons: Filters, New Match, Review").

---

After producing the brief, stop and wait for the user's direction. Do not start implementing anything yet.
