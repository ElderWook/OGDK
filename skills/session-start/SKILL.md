---
name: session-start
description: Run the OGDK session-start protocol — verify environment safety, read the session chain (AGENTS.md, STATUS.md, active plan), and summarize current state before any edits. Use at the start of every dev session, or when asked to "start a session", "get up to speed", or "load context".
---

# Session start

Follow in order. Do not edit any file until step 5.

1. **Environment (Windows):** run `.\tools\verify-path-health.ps1`. If any FAIL, stop —
   report it and do not write files until the PATH is fixed.
2. **Rules:** read `AGENTS.md` (repo root) in full. These are non-negotiable.
3. **State:** read `docs/STATUS.md` — note active plans, hazards, and "next up".
4. **Plan:** read the active plan(s) named in STATUS.md before touching code they cover.
5. **Summarize** to the user in a few sentences: current branch/version, what's in
   flight, open hazards, and what you understand the session goal to be. Ask if the
   goal differs from STATUS.md's "next up".

Only then begin work. If `docs/00-START-HERE.md` exists, it is authoritative over this
skill where they differ.
