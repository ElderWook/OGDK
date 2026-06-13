# OGDK — Agent Rules (for working on the kit itself)

This repo is the **Oasis Games Dev Kit** — the foundation every Oasis project is
stamped from. Changes here multiply into every future project, so the bar is higher
than in a project repo.

## ⚠️ Launch environment
Same as every Oasis repo: never launch agents from MSYS2 / Git Bash / WSL.
Run `.\tools\verify-path-health.ps1` before any file writes.

## Working here as an AI agent

These rules bind any AI agent (Claude Code, Cowork, agy, ...) working in this repo, on
top of the rules below. The session lifecycle they hook into is in
[GETTING-STARTED.md](./GETTING-STARTED.md) §4.1.

1. **Start every session read-first.** Run `verify-path-health`, then `sync-repo`,
   before any file write. If path-health FAILs (NTFS mount, unset/public identity,
   hooks not installed), surface it and stay read-only until it's resolved — never
   write or commit through a flagged environment.
2. **Never run git through a Cowork mount or cloud-synced folder.** Even `git status`
   can rewrite the index from stale data, and partial writes via the mount shell land
   at stale offsets and corrupt files. Make whole-file edits with your direct file
   tools only, and let the human run git on a native clone. (Hazard map:
   [tools/README.md](./tools/README.md).)
3. **Never push, force-push, or auto-merge from a sandbox or non-interactive session.**
   No `git push`, no `git merge`, no history rewrite, no `--no-verify`. `sync-repo`
   stops on divergence by design — if it says STOP, hand back to the human rather than
   untangle it yourself.
4. **Identity is private.** Commits must be authored by a GitHub noreply email; verify
   it with `verify-path-health`. Never set or edit the human's global git config for
   them, and never commit with an unset or personal identity.
5. **Route personal data to `user-notes.local.md`** (gitignored), never into tracked
   files — repo paths, usernames, machine specifics, project codenames, collaborator
   names. The membrane is [BOUNDARY.md](./BOUNDARY.md).
6. **Trust the mechanical backstop.** `install-hooks` arms a `pre-commit` guard (blocks
   a commit whose staged content or authoring identity matches a private marker) and a
   `pre-push` guard (rescans commit-history identity). Both read your gitignored
   `tools/PRIVATE-MARKERS.list` and skip cleanly when it's absent — so seed it first.
   Run `gate` before any commit for the full check.

## Rules of the kit (non-negotiable)

1. **Process + proven patterns only.** No app/game domain logic ever lives here.
2. **Rule of two.** Code modules enter `app/packages/` or game plugins only when a
   second project needs them — never extracted speculatively.
3. **Everything in `docs-template/`, `skills/`, and `*.template.md` must work for a
   reader with ZERO context** — any model, any account, cold start. If a change
   assumes knowledge of any origin project or a specific game, it's wrong.
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
8. **The boundary holds in both directions.** What may enter the kit (generic
   process, scrubbed lessons) and what never does (project code, project names,
   collaborator IP, personal data) is defined in [BOUNDARY.md](./BOUNDARY.md).
   Mechanical backstop: `check-kit-docs` check 8 scans tracked files against each
   owner's gitignored `tools/PRIVATE-MARKERS.list`.

## Verification gate (before every commit)

- `.\tools\gate.ps1` (Linux: `./tools/gate.sh`) passes — it chains the kit-docs
  self-check (twin rule + user-notes.md and tools/README.md current) and the file
  integrity check. Adding/renaming/removing a script or build command updates
  user-notes.md + tools/README.md in the SAME commit.
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
