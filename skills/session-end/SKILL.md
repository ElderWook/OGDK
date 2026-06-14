---
name: session-end
description: Run the OGDK session-end protocol — verification gate, docs-with-code check, STATUS.md handoff update, plan archival. Use when ending a dev session, before a final commit, or when asked to "wrap up", "hand off", or "close out".
---

# Session end

This is **C5 DEPART** in gitwalk (`docs/workflow/GIT-LIFECYCLE.md`); the emergency handoff below
is **C4 HANDOFF**. For a sandboxed / synced-mount agent: narrate each git command and WAIT for the
human's pasted result before the next step — nothing is assumed done, nothing crosses uncommitted.

> **Emergency handoff (low usage / time pressure):** if there isn't capacity for the
> full protocol, do ONLY this, immediately: add `## In-flight` to docs/STATUS.md
> (what's half-done, which files, exact next step), then run
> `.\tools\checkpoint.ps1 "<what was in flight>"` (Linux: `./tools/checkpoint.sh`;
> humans can double-click `tools\checkpoint.bat`) — it stages, wip-commits, and
> pushes in one shot, and a failed push still leaves the work safe locally.
> Everything else can wait; stranded context cannot be recovered.
> sync-repo detects the wip: checkpoint at next session start automatically.

1. **THE GATE:** run `.\tools\gate.ps1` (Linux: `./tools/gate.sh`). One command — it
   chains file integrity, reference coverage, and the project's tests/builds. Exit 0
   or no commit. STALE coverage warnings mean a touched component's reference page
   wasn't updated — fix now or record why in STATUS.md. If anything fails, fix or
   record it as an open hazard — never hand off silently broken state.
2. **Docs-with-code check:** for every code change this session, confirm the relevant
   doc (`docs/core|presentation|adapters|workflow`) was updated in the same commit.
3. **Plan lifecycle:** if a plan was completed, graduate its content into `docs/core/`,
   **create/update the `docs/reference/` page for every component it shipped**
   (its §Documentation impact list; template in `docs/reference/COMPONENT-TEMPLATE.md`),
   and only then move the plan to `docs/plans/archive/`. No reference page, no archive.
4. **Log lessons (the learning loop):** if this session hit friction the system
   didn't prevent — unclear rule, wrong script output, repeated mistake, manual step
   that should be mechanical — append an entry to `docs/LESSONS.md` (format inside).
   30 seconds now; the kit-retro skill turns it into a permanent upgrade later.
5. **Update `docs/STATUS.md`** (the handoff — most important step):
   - Last updated date, branch, version
   - What landed this session (with commit hashes)
   - New/resolved hazards
   - "Next up" for the next session
   Keep it to one screen; move stale content out.
6. **Commit** docs updates with the work (one concern per commit), then **push**.
7. Report to the user: gate results, what landed, what the next session should do first.
