# 00 — START HERE (every session, every model, every dev)

Single entry point for any work session — human or AI, any model, any account.
Follow the chain in order. Do not skip steps.

## The chain

```
1. AGENTS.md (repo root)           ← non-negotiable rules: launch env, architecture, invariants, gates
2. docs/STATUS.md                  ← what is in flight RIGHT NOW + the active plan
3. The active plan (docs/plans/…)  ← the spec for the current iteration
4. Role guide, as needed:
     building/fixing  → docs/DEVELOPER-GUIDE.md (create once the codebase has shape)
     releasing        → docs/workflow/
     deep-dive        → docs/core/ · docs/presentation/ · docs/adapters/
```

Working across models/accounts? The parity contract is [workflow/AI-PARITY.md](./workflow/AI-PARITY.md) —
the short version: **if it isn't in the repo, the next session doesn't know it.**

As plans / studies / lessons pile up, [workflow/SCALING.md](./workflow/SCALING.md) is the
growth contract — working buffer → generated manifest → cold archive, so nothing rots.

## Session protocol

**Start of session** — all git follows **gitwalk**: [workflow/GIT-LIFECYCLE.md](./workflow/GIT-LIFECYCLE.md)
is the single source of truth for the git sequence. A native-git agent walks the checkpoints
itself (SAVE+push via `tools/safe-agent-push`); a mount/sandbox agent narrates each and waits for
the human's pasted output. Never run git through a mount.
1. Read `AGENTS.md` in full, then run `verify-path-health` before any file write.
2. **Arrive (gitwalk C0):** run `sync-repo` (`.\tools\sync-repo.ps1` / `./tools/sync-repo.sh`); it
   must end **"SAFE TO WORK"** before you touch a file. Exit 2 = follow its resolve sub-flow first.
3. Read `docs/STATUS.md` — it names the active plan and any open hazards. (A low-churn repo with no
   STATUS.md uses `git log` + `LESSONS.md`/`ROADMAP.md` as its handoff instead.)
4. Read the active plan before touching code it covers.
5. **Interrupted-session recovery:** if the working tree is dirty, the last commit is `wip:`, or
   STATUS.md has an `## In-flight` section — the previous session died mid-task. Do NOT start new
   work: reconstruct from the `sync-repo` / `git status` output and the wip commit against the
   active plan, record what you found in STATUS.md, then deliberately finish or revert it first.

**During**
- Plans are written before implementation (`docs/plans/`); specs live in
  `docs/core|presentation|adapters`; operations in `docs/workflow`.
  Lifecycle: `DOCUMENTATION-VERSIONING-GUIDE.md`.
- Docs change in the SAME commit as the code they describe.
- **Checkpoint protocol — assume any session can die mid-task (usage limits, crash):**
  commit at every green subtask; never leave more than ~30 minutes of work
  uncommitted. If limits are approaching, do an EMERGENCY HANDOFF before anything
  else: add an `## In-flight` note to `docs/STATUS.md` (what's half-done, which
  files, exact next step), then commit everything as `wip: <plan> — <state>` and
  push. A WIP commit beats stranded context every time; it is cleaned up by the
  next session, never left as the final state of a plan.

**End of session**
1. Run the gate: `.\tools\gate.ps1` (Linux: `./tools/gate.sh`) — integrity →
   reference coverage → project tests/builds. Exit 0 or no commit.
2. Update `docs/STATUS.md` — what moved, what's next, new hazards. This is the handoff;
   if it's not in STATUS.md, the next agent doesn't know it.
3. Completed plans graduate: content into `core/`, a polished page per shipped
   component into `reference/` (the SDK tier — see `reference/README.md`), THEN the
   plan moves to `docs/plans/archive/`. No reference page, no archive.

## Why this exists
Work rotates across models, accounts, and people. Context does not carry over — this
chain IS the context (~5 min to read). It prevents the two expensive failure modes:
violating an invariant (AGENTS.md) and colliding with in-flight work (STATUS.md).
