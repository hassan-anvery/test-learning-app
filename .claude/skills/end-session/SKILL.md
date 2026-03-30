---
name: end-session
description: Session close for the tennis charting app — summarizes work, rewrites PRIMER.md as a clean handoff, and conditionally updates LESSONS.md
type: process
---

# End Session

You are closing a coding session on this tennis charting iOS app. Do the following steps in order.

---

## Step 1: Session Summary

Produce a summary with these four sections:

### Completed This Session
Bullet list of what was actually implemented or changed during this session. Be specific — name files and features. Do not include things that were only discussed.

### Blockers / Open Questions
Bullet list of anything unresolved, deferred, or unclear. If nothing is blocked, write "None."

### Files Touched
List every Swift file (and any config/doc file) modified this session.

### Next 3 Concrete Steps
Three ordered, specific actions for the next session. Each should name a file and a task (e.g. "1. Build `FiltersView.swift` — sheet with toggle filters for surface, format, opponent"). No vague items like "continue work on X".

---

## Step 2: Rewrite PRIMER.md

Rewrite `PRIMER.md` from scratch as a clean handoff document. This is not an append — replace the entire file. Write it as if handing the project to a fresh Claude instance that has never seen it.

Include:
- **Objective** — the current active goal (updated to reflect session outcome)
- **Completed** — cumulative list of shipped features (merge in prior completed + this session's completed)
- **In Progress** — anything started but not finished
- **Current Branch** — the git branch being worked on
- **Next Files to Touch** — specific file names
- **Next Steps** — the same 3 steps from the summary above
- **Blockers** — same as summary, or "None"

Do not include session dates, session numbers, or historical narrative. Write in present tense. Keep it under 60 lines.

---

## Step 3: Update LESSONS.md (conditional)

Only update `LESSONS.md` if a **new** recurring lesson or pattern emerged this session — something that would genuinely help a future session avoid a mistake or follow a preference that isn't already captured.

Ask yourself: "Would a future Claude instance benefit from knowing this?" If yes, append it. If no, leave LESSONS.md unchanged.

When adding a lesson:
- Add it under the most relevant existing section, or create a new section if needed
- Keep it to 1–2 lines
- Be specific — not "be careful with navigation" but "never add NavigationStack; the app uses Group-based conditional routing and refactoring it was explicitly rejected"

Do not add lessons that restate what's already there. Do not add lessons just because you made changes — only if a pattern worth preserving emerged.
