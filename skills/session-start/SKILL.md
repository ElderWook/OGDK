---
name: session-start
description: Run the OGDK session-start protocol — pick your git execution mode (native vs mount), arrive safely (gitwalk C0), read the session chain, and summarize state before any edits. Use at the start of every dev session, or when asked to "start a session", "get up to speed", or "load context".
---

# Session start

Read-first. Do not edit a file until the chain is read and arrival is clear.

## 0. Pick your execution mode (it decides how you do git this session)

All git follows **gitwalk** — the no-skip checkpoints in the GIT-LIFECYCLE doc
(`docs/workflow/GIT-LIFECYCLE.md` in a project; `docs-template/workflow/GIT-LIFECYCLE.md`
in the kit). That doc is the single source of truth for the git sequence; this skill only
tells you when to walk it. Two modes:

- **Native** — you can run shell commands that execute git AND this repo is NOT on a
  synced/mount path (`/sessions/*/mnt/*`, `/mnt/<drive>/*`, a UNC `\\` path, or a
  OneDrive/Dropbox/Google Drive folder). You RUN each checkpoint yourself. For SAVE+push,
  use `tools/safe-agent-push` (path-health -> sync -> gate -> add -> commit -> push); it
  aborts, never forces. On ANY stop/abort (divergence, dirty, mid-merge, gate-fail), hand
  the matching GIT-LIFECYCLE sub-flow back to the human — do not auto-resolve. (safe-agent-push
  refuses on a mount, so if you misjudged the mode, it fails safe.)
- **Mount / sandbox** — the repo is on a mount path, or you cannot run git. NARRATE each
  checkpoint's exact command, then STOP and wait for the human's pasted output before
  proceeding. Never run git through the mount; make file edits with your direct file tools only.

When in doubt, narrate — it is the safe default.

## 1. Environment

`verify-path-health` only means anything on the machine that will actually do the work, so
treat it like the git steps: **native mode runs it; mount mode narrates it** (a sandbox would
otherwise health-check its own throwaway environment — e.g. report a false "git identity not
set" that is NOT your clone's). A genuine FAIL on the native machine (NTFS mount, unset or
public identity) means stop and fix before any write.

```
.\tools\verify-path-health.ps1            (bash ./tools/verify-path-health.sh)
```

## 2. Arrive — gitwalk C0

```
.\tools\sync-repo.ps1                      (./tools/sync-repo.sh)
```

Good: ends **"SAFE TO WORK"** (exit 0). Exit 2 = STOP — follow the matching resolve sub-flow
(S1-S6) in GIT-LIFECYCLE before ANY edit; diverged/dirty/mid-merge are never worked over.
Touching several repos this session, or about to propagate kit tools? run `fleet-status`
first and clear every flagged repo.

## 3. Rules

Read `AGENTS.md` (repo root) in full. These are non-negotiable.

## 4. State — the handoff

- **Project repo (has `docs/STATUS.md`):** read it — active plans, open hazards, "next up" —
  then read the active plan(s) it names before touching code they cover.
- **Kit, or any low-churn repo with NO `docs/STATUS.md`:** the handoff is `git log` plus
  `LESSONS.md` and `ROADMAP.md`. There is no STATUS.md or active plan to read — skip steps that
  assume one.

## 5. Interrupted-session check

The signal is mechanical and already in your `sync-repo` output: a `wip:` last commit, or an
unexpected dirty tree (and, in a project, an `## In-flight` block in STATUS.md). If any are
present, the previous session died mid-task — do NOT start new work. Reconstruct from the
`sync-repo` / `git status` output + the wip commit (+ the active plan, in a project), confirm
what you found, and ask the human whether to finish or revert before anything else.

## 6. Summarize

Tell the human in a few sentences: your execution mode, current branch, what is in flight, open
hazards, and the session goal as you understand it. Ask if it differs from the handoff's "next up".

Only then begin work.
