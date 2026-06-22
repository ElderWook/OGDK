---
name: session-end
description: Run the OGDK session-end protocol — gitwalk C5 DEPART. Gate, then save the handoff (project: docs/STATUS.md + plan lifecycle; kit: git log + ROADMAP/LESSONS), commit, push. Use when ending a dev session, before a final commit, or when asked to "wrap up", "hand off", or "close out".
---

# Session end — gitwalk C5 DEPART

This is **C5 DEPART**; the emergency handoff below is **C4 HANDOFF**. The GIT-LIFECYCLE
doc is the single source of truth for the git sequence (`docs/workflow/GIT-LIFECYCLE.md`
in a project; `docs-template/workflow/GIT-LIFECYCLE.md` in the kit).

**Execution mode (same rule as session-start):**
- **Native** — you can run git AND are not on a mount: run each step yourself; do SAVE+push
  via `tools/safe-agent-push`; hand back to the human on any STOP, do not auto-resolve.
- **Mount / sandbox:** narrate each git command and WAIT for the human's pasted result —
  never run git through the mount; nothing is assumed done, nothing crosses uncommitted.

> **Emergency handoff (low usage / time pressure):** if there isn't capacity for the full
> protocol, do ONLY this: in a project, add `## In-flight` to `docs/STATUS.md` (what's
> half-done, which files, the exact next step); then run `checkpoint`
> (`.\tools\checkpoint.ps1` / `./tools/checkpoint.sh`; humans can double-click
> `tools\checkpoint.bat`) — it stages, wip-commits, and pushes in one shot, and a failed
> push still saves locally. `sync-repo` flags the `wip:` at next arrival. Stranded context
> cannot be recovered — do this before anything else.

1. **THE GATE:** run `gate` (`.\tools\gate.ps1` / `./tools/gate.sh`). Exit 0 or no commit.
   STALE coverage warnings mean a touched component's reference page wasn't updated — fix
   now or record why. Never hand off silently broken state.
2. **Docs-with-code check:**
   - **Project:** for every code change, confirm the matching doc
     (`docs/core|presentation|adapters|workflow`) changed in the same commit.
   - **Kit:** if `tools/` or `skills/` changed, confirm the twin rule holds and
     `tools/README.md` + `user-notes.md` are current in the same commit (check-kit-docs
     enforces this mechanically).
3. **Plan lifecycle (project only):** if a plan completed, graduate its content to
   `docs/core/`, write/update the `docs/reference/` page for every component it shipped,
   then move the plan to `docs/plans/archive/`. No reference page, no archive. (The kit has
   no `docs/plans/` — kit improvements are codified directly into AGENTS.md / skills/ / tools/.)
4. **Log lessons (the learning loop):** if this session hit friction the system didn't
   prevent — unclear rule, wrong script output, repeated mistake, a manual step that should
   be mechanical — append an entry. **Project:** `docs/LESSONS.md`. **Kit:** root `LESSONS.md`
   (the short OPEN buffer; codified entries graduate to `LESSONS-ARCHIVE.md` per
   `docs-template/workflow/SCALING.md`). The kit-retro skill turns it into a permanent fix.
5. **Update the handoff (the most important step):**
   - **Project:** `docs/STATUS.md` — date, branch, version, what landed (with commit
     hashes), new/resolved hazards, "next up". Keep it to one screen; move stale content out.
   - **Kit:** there is no STATUS.md — the handoff IS `git log` + `ROADMAP.md`. Write the
     commit message accordingly (why, not what), and update `ROADMAP.md` if a phase moved.
6. **Commit** docs with the work (one concern per commit), then **push** (native agent:
   `safe-agent-push`).
7. **Report** to the user: gate result, what landed, and what the next session should do first.
