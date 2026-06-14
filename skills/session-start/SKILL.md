---
name: session-start
description: Run the OGDK session-start protocol — verify environment safety, read the session chain (AGENTS.md, STATUS.md, active plan), and summarize current state before any edits. Use at the start of every dev session, or when asked to "start a session", "get up to speed", or "load context".
---

# Session start

Follow in order. Do not edit any file until step 6. All git this session follows **gitwalk** —
the no-skip checkpoints in `docs/workflow/GIT-LIFECYCLE.md` (C0 ARRIVE is steps 1–2 here; C2
SAVE / C4 HANDOFF / C5 DEPART come during and after work). For a sandboxed / synced-mount agent:
present each checkpoint's exact command and WAIT for the human's pasted output before proceeding —
never run git through the mount.

1. **Environment:** run `.\tools\verify-path-health.ps1` (Linux: `bash ./tools/verify-path-health.sh`). If any FAIL, stop — report it and do not write files until the PATH is fixed. Also run `.\tools\install-hooks.ps1` (Linux: `bash ./tools/install-hooks.sh`) to ensure the pre-push guard is active.
2. **Sync — C0 ARRIVE:** run `.\tools\sync-repo.ps1` (Linux: `./tools/sync-repo.sh`); it must
   end "SAFE TO WORK" (exit 0). Exit 2 = STOP and follow the matching resolve sub-flow in
   `docs/workflow/GIT-LIFECYCLE.md` (S1–S6) before ANY edit — diverged/dirty/mid-merge are
   never worked over. Touching several repos this session, or about to propagate kit tools?
   run `.\tools\fleet-status.ps1` (`./tools/fleet-status.sh`) first and clear every `*` repo.
   Sandboxed sessions: git needs a NATIVE shell — narrate the command and wait for the human's
   pasted result; never run git through the mount (`docs/workflow/AI-PARITY.md` §4).
3. **Rules:** read `AGENTS.md` (repo root) in full. These are non-negotiable.
4. **State:** read `docs/STATUS.md` — note active plans, hazards, and "next up".
5. **Plan:** read the active plan(s) named in STATUS.md before touching code they cover.
6. **Interrupted-session check** (sync-repo flags these mechanically — wip: commits
   and unexpected dirty trees): if the working tree is dirty, the last commit message
   starts with `wip:`, or STATUS.md contains an `## In-flight` section, the previous
   session died mid-task (usage limit, crash, checkpoint.bat). Do NOT start new work.
   Reconstruct the in-flight state from `git status`/`git diff` + the wip commit + the
   active plan, record what you found in STATUS.md, and ask the user whether to finish
   or revert it.
7. **Summarize** to the user in a few sentences: current branch/version, what's in
   flight, open hazards, and what you understand the session goal to be. Ask if the
   goal differs from STATUS.md's "next up".

Only then begin work. If `docs/00-START-HERE.md` exists, it is authoritative over this
skill where they differ.
