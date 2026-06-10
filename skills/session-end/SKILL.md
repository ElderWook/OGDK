---
name: session-end
description: Run the OGDK session-end protocol — verification gate, docs-with-code check, STATUS.md handoff update, plan archival. Use when ending a dev session, before a final commit, or when asked to "wrap up", "hand off", or "close out".
---

# Session end

1. **Verification gate:** run the exact commands in `AGENTS.md §Verification gate`.
   All must pass. If anything fails, fix or record it as an open hazard — never hand
   off silently broken state.
2. **Docs-with-code check:** for every code change this session, confirm the relevant
   doc (`docs/core|presentation|adapters|workflow`) was updated in the same commit.
3. **Plan lifecycle:** if a plan was completed, graduate its content into `docs/core/`
   and move the plan to `docs/plans/archive/`.
4. **Update `docs/STATUS.md`** (the handoff — most important step):
   - Last updated date, branch, version
   - What landed this session (with commit hashes)
   - New/resolved hazards
   - "Next up" for the next session
   Keep it to one screen; move stale content out.
5. **Commit** docs updates with the work (one concern per commit).
6. Report to the user: gate results, what landed, what the next session should do first.
