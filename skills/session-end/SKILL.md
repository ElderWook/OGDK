---
name: session-end
description: Run the OGDK session-end protocol — verification gate, docs-with-code check, STATUS.md handoff update, plan archival. Use when ending a dev session, before a final commit, or when asked to "wrap up", "hand off", or "close out".
---

# Session end

> **Emergency handoff (low usage / time pressure):** if there isn't capacity for the
> full protocol, do ONLY this, immediately: add `## In-flight` to docs/STATUS.md
> (what's half-done, which files, exact next step), `git add -A`,
> `git commit -m "wip: <plan> — <state>"`, push. Everything else can wait; stranded
> context cannot be recovered.

1. **Integrity gate:** run `.\tools\verify-file-integrity.ps1` (Linux: `.sh`). Any FAIL
   means possible file corruption (NUL-fill, truncation) — fix before committing anything.
1b. **Coverage gate:** run `.\tools\check-reference-coverage.ps1` (Linux: `.sh`). FAILs
   block archiving; STALE warnings mean a touched component's reference page wasn't
   updated — fix it now or record why in STATUS.md.
2. **Verification gate:** run the exact commands in `AGENTS.md §Verification gate`.
   All must pass. If anything fails, fix or record it as an open hazard — never hand
   off silently broken state.
2. **Docs-with-code check:** for every code change this session, confirm the relevant
   doc (`docs/core|presentation|adapters|workflow`) was updated in the same commit.
3. **Plan lifecycle:** if a plan was completed, graduate its content into `docs/core/`,
   **create/update the `docs/reference/` page for every component it shipped**
   (its §Documentation impact list; template in `docs/reference/COMPONENT-TEMPLATE.md`),
   and only then move the plan to `docs/plans/archive/`. No reference page, no archive.
4. **Update `docs/STATUS.md`** (the handoff — most important step):
   - Last updated date, branch, version
   - What landed this session (with commit hashes)
   - New/resolved hazards
   - "Next up" for the next session
   Keep it to one screen; move stale content out.
5. **Commit** docs updates with the work (one concern per commit).
6. Report to the user: gate results, what landed, what the next session should do first.
