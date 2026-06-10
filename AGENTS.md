# OGDK — Agent Rules (for working on the kit itself)

This repo is the **Oasis Games Dev Kit** — the foundation every Oasis project is
stamped from. Changes here multiply into every future project, so the bar is higher
than in a project repo.

## ⚠️ Launch environment
Same as every Oasis repo: never launch agents from MSYS2 / Git Bash / WSL.
Run `.\tools\verify-path-health.ps1` before any file writes.

## Rules of the kit (non-negotiable)

1. **Process + proven patterns only.** No app/game domain logic ever lives here.
2. **Rule of two.** Code modules enter `app/packages/` or game plugins only when a
   second project needs them — never extracted speculatively.
3. **Everything in `docs-template/`, `skills/`, and `*.template.md` must work for a
   reader with ZERO context** — any model, any account, cold start. If a change
   assumes knowledge of OpenBook or a specific game, it's wrong.
4. **Templates use `{{TOKEN}}` placeholders** only for values `tools/new-project.ps1`
   replaces (`{{PROJECT_NAME}}`, `{{DATE}}`). Adding a token means updating the script
   in the same commit.
5. **Two tracks, one process.** Track-specific content goes in `app/` or `game/`;
   anything both tracks need goes in `docs-template/`, `tools/`, `skills/`,
   or `checklists/`. Never duplicate across tracks.
6. **Twin rule (cross-platform).** Every `tools/` script ships as a `.ps1`/`.sh` pair
   with identical behavior; changing one updates the other in the SAME commit.
   `.ps1` files: Windows PowerShell 5.1-safe — ASCII only, NO here-strings (they break
   with LF endings). See `tools/README.md`.
7. **Improvements flow back.** When a project improves a script or skill, the fix is
   copied back here in its own commit. Templates, by contrast, are starting points —
   projects may diverge from them freely and those divergences do NOT flow back.

## Verification gate (before every commit)

- Link check: every relative `](…)` link in non-template `.md` files resolves
  (template links resolve post-scaffold — verify by eye against `tools/new-project.ps1`).
- If `new-project.ps1` or any template changed: scaffold a throwaway
  (`.\tools\new-project.ps1 -Name ZZTest -Type App -Dest $env:TEMP`) and confirm it
  completes, tokens are replaced, and the chain reads correctly. Delete it after.
- Skills changed → re-read each SKILL.md as if cold: is it executable without context?

## Process
- This repo is small and low-churn: **no docs/STATUS.md here** — git log is the
  handoff. Write commit messages accordingly (why, not what).
- One concern per commit. Never commit a scaffolded test project.
