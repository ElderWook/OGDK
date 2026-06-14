# tools/ — cross-platform parity policy

Every script ships as a **twin pair**: `.ps1` (Windows PowerShell 5.1+) and `.sh`
(bash, Linux with GNU userland). Same name, same behavior, same exit semantics.
macOS is **experimental**: the `.sh` scripts assume GNU userland (`sed -i`, `grep -P`),
so install it first (`brew install coreutils gnu-sed grep`) and expect rough edges -
`bootstrap` prints this reminder when it detects a Mac. First-class macOS support is a
deliberate porting task (rule of two: it lands when a second Mac actually needs it).

| Pair | Purpose |
|------|---------|
| `bootstrap.{ps1,sh}` | (kit only) one-command first-run setup for a newcomer: checks git + identity, runs `verify-path-health` then the full `gate`, arms the privacy hooks, and prints the exact next command. Collapses GETTING-STARTED Stages 2-4 into one friendly run; read-only (never commits, never sets your identity). Not propagated - projects are already wired by the scaffolder. |
| `verify-path-health.{ps1,sh}` | session-start environment gate. Windows: MSYS2/WSL PATH poisoning, malformed PATH, cloud-sync overlays. Linux: NTFS-mount hazard, git identity, LFS, autocrlf. Also prints `tools/KIT-VERSION` (which kit commit this repo's tools came from — stamped by the scaffolder/propagate; staleness is visible every session). |
| `sync-repo.{ps1,sh}` | **safe arrival** — run at session start, right after path-health. Fetches, then classifies: in-sync / behind (auto fast-forward — the only conflict-impossible action) / ahead / dirty / DIVERGED / merge-in-progress, each with plain-language next steps. NEVER auto-merges; exists so a multi-machine operator can never stumble into a conflict screen. Carries the kit-files rule: conflicts in propagated `tools/*` are not real merges — take either side, re-propagate. Exit 0 = safe to work; 2 = act first. |
| `checkpoint.{ps1,sh}` + `checkpoint.bat` | **panic save** — one command (or one double-click on Windows: the `.bat` shim) when a session must end NOW: stages everything, commits `wip: checkpoint <stamp> [- message]`, pushes. A failed push still reports success — the local commit IS the save; sync-repo untangles it next session. Safe to mash; never force-pushes, never merges. The `.bat` has no `.sh` twin by design (double-click is a Windows behavior; documented exception to the twin rule). |
| `rescue.{ps1,sh}` | **get back to safe** - the symmetric twin of checkpoint (checkpoint SAVES, rescue RESTORES). One command when things feel tangled: cancels a half-finished merge/rebase (back to the last commit), or safely shelves uncommitted changes via `git stash --include-untracked` so the tree returns to HEAD with nothing lost (`git stash pop` brings it back). Never resets `--hard`, never force-pushes, never deletes commits. The beginner's "undo the mess" button. |
| `report-snag.{ps1,sh}` | **file a LESSONS entry in 10 seconds.** Takes a one-line description, captures harmless environment context (OS, git version, branch, last commit, KIT-VERSION), and prints a ready-to-paste `LESSONS.md` entry to stdout (writes nothing - redirect or copy it). Makes the learning loop's input frictionless so a newcomer actually captures friction instead of skipping it. |
| `verify-file-integrity.{ps1,sh}` | pre-commit corruption gate: NUL bytes in tracked text files (zero-fill signature), .py compile check (truncation), script-syntax parse (.ps1 via PowerShell parser on Windows / .sh via `bash -n` on Linux — documented platform difference), **EOF sentinel** (every tools script must end with `exit ...` or `# EOF` — truncation can hide inside a comment and pass syntax checks), trailing-newline smell test, `git fsck`. Run after heavy agent writes, before committing. |
| `check-git-identity.{ps1,sh}` | pre-commit identity-leak gate: scans author + committer name/email across **all commit objects in history** against your gitignored `PRIVATE-MARKERS.list` and FAILs on any match. Content scans (check-kit-docs 8) only see tracked file text; author/committer metadata rides in every commit and is otherwise invisible (the "personal email leaked via commit author identity" lesson). Output reports marker index only; skips gracefully when git or the list is absent. Chained into `gate`. |
| `test-hostile-env.{ps1,sh}` | hostile-environment smoke test suite: validates path health checks, kit gate, scaffolding, and scaffolded project gate under adverse path/git/sync-overlay conditions. |
| `test-sync-repo.{ps1,sh}` | smoke test for the `sync-repo` classifier: drives a throwaway local bare remote through in-sync / behind (fast-forward) / ahead / dirty+behind / diverged / merge-in-progress and asserts each documented exit code (0 = safe, 2 = act). Run after touching `sync-repo`. |
| `install-hooks.{ps1,sh}` | point this clone's `core.hooksPath` at the tracked `tools/hooks/` so two guards fire automatically: **pre-commit** (`tools/hooks/pre-commit` — blocks a commit whose staged content or authoring git identity matches a `PRIVATE-MARKERS.list` entry; the leak block every environment reaches, since a sandboxed agent commits but never pushes) and **pre-push** (`tools/hooks/pre-push` runs `check-git-identity` to rescan commit-history identity before it leaves the machine). Both are lean privacy-only scans, not the full gate, so `wip:` checkpoints are never blocked for hygiene reasons. Per-clone, idempotent; undo with `git config --unset core.hooksPath`. The hooks are single LF-pinned sh scripts (git runs hooks through its own sh on both OSes); they read only git metadata + the markers file, so no NTFS-write hazard. |
| `check-reference-coverage.{ps1,sh}` | documentation gate: parses `docs/reference/COVERAGE.md`, fails on pages that don't exist, warns on STALE pages (source committed after page) and MISSING backlog. Also nudges the learning loop (counts OPEN entries in `docs/LESSONS.md`; WARNs at 5 — the kit-retro trigger, mechanical) and handoff freshness (WARNs if `docs/STATUS.md` trails HEAD by >3 days). Run at session end. |
| `check-kit-docs.{ps1,sh}` | (kit only, not propagated) self-check: twin rule, user-notes.md + this README mention every script, no ghost references to deleted scripts, .ps1 hygiene, no hardcoded user paths, links resolve, and **no private markers** — check 8 scans tracked files against your gitignored `PRIVATE-MARKERS.list` in this folder (one marker per line, `#` comments; output reports marker index only, never text; policy in [BOUNDARY.md](../BOUNDARY.md)). Run before any kit commit. |
| `gate.{ps1,sh}` | THE GATE — one command per repo: integrity → coverage → project tests/builds, exit 0 or no commit. Kit ships `gate.template.{ps1,sh}` via the scaffolder; each project fills its §project checks. The kit's own gate runs kit-docs + integrity. |
| `launch-claude-clean.{ps1,sh}` | run the health gate, then launch Claude Code |
| `new-project.{ps1,sh}` | scaffold a new App/Game project from the kit (tool copy-list lives in `PROPAGATE.list`) |
| `propagate-tools.{ps1,sh}` | (kit only) push kit tools (and `-Skills`/`--skills`: skills) into an EXISTING project per `PROPAGATE.list`, or into EVERY project with `-All`/`--all` (targets in your gitignored `tools/TARGETS.list`, one project root per line — paths are personal). Verifies copies byte-identical (truncated-propagation lesson) and stamps `tools/KIT-VERSION` in each target (`v<semver> <commit> <date>` — semver from the kit's root `VERSION` file, bumped in the same commit as each release tag). Never runs git in targets — gate + commit in each target yourself. |
| `new-reference-page.{ps1,sh}` | scaffold `docs/reference/<slug>.md` from COMPONENT-TEMPLATE.md AND append its COVERAGE.md row in one command — the graduation rule, mechanical. Run from a project root; fill the page before committing (page + manifest + component in the same commit). |
| `release-notes.{ps1,sh}` | draft tag-to-tag release notes from `git log` to stdout (redirect to a file, then edit). Groups `type:`-prefixed subjects, lumps the rest under "Other changes" — no commit-message discipline required. Drafts only; never writes files; history stays in git. |

## The banner

Tools print a small OGDK ASCII banner at startup unless the `OGDK_BANNER`
environment variable is set. The gates set it (and the .ps1 gates clear it on
exit), so a gate run shows ONE banner, not one per chained tool. Exceptions:
`release-notes` (stdout is the deliverable you redirect to a file) and
`launch-claude-clean` (its banner arrives via the path-health check it runs).

## Rules

1. **Twin rule:** any change to a script updates its twin in the SAME commit
   (enforced in OGDK AGENTS.md and by `check-kit-docs`). If behavior must differ per
   platform (the hazards really are different), the difference is commented at the
   top of both files.
2. **.ps1 constraints:** Windows PowerShell 5.1 compatible — ASCII only, no
   here-strings (they break with LF line endings), CRLF-agnostic constructs only.
   Read text files with `-Encoding UTF8` explicitly. PowerShell tests that assert on
   tool output must use `*>&1` (rather than `2>&1`) to redirect and capture the
   `Write-Host` info stream (stream 6).
3. **.sh constraints:** bash, `set -u` minimum, POSIX-leaning; `chmod +x` after
   fresh checkout on Linux if the executable bit was lost
   (`chmod +x tools/*.sh`).
4. Line-ending policy lives in `.gitattributes` (`*.sh` forced LF, `*.ps1` CRLF-safe),
   never in per-machine git config.

## The dual-boot hazard map (why the gates differ per OS)

- **Windows:** MSYS2/Git Bash/WSL shells poison PATH → POSIX writes against NTFS →
  silent file corruption. Gate: no emulation paths before Windows tools.
- **Linux (dual-boot):** the mirror image — writing to the shared NTFS partition from
  Linux (ntfs3/fuse) is unsafe for rapid agent writes. Gate: repo must be on a native
  filesystem; sync between OSes happens via git push/pull through the remote, never by
  mounting the other OS's partition.
- **Sync layers (Cowork mounts, cloud-synced folders):** eventually-consistent views —
  agents must never run git through them (even `git status` can rewrite the index from
  stale data) and must never append/partially modify files via the mount shell (writes
  land at stale offsets and corrupt the real file). Whole-file writes via the session's
  direct file tools only. See docs-template/workflow/AI-PARITY.md §4.
