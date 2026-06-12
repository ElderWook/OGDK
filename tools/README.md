# tools/ — cross-platform parity policy

Every script ships as a **twin pair**: `.ps1` (Windows PowerShell 5.1+) and `.sh`
(bash, Linux with GNU userland). Same name, same behavior, same exit semantics.
macOS is NOT supported: the `.sh` scripts use GNU `sed -i` and `grep -P`, which break
on BSD tools. If a Mac ever joins the fleet, that's a deliberate porting task.

| Pair | Purpose |
|------|---------|
| `verify-path-health.{ps1,sh}` | session-start environment gate. Windows: MSYS2/WSL PATH poisoning, malformed PATH, cloud-sync overlays. Linux: NTFS-mount hazard, git identity, LFS, autocrlf. Also prints `tools/KIT-VERSION` (which kit commit this repo's tools came from — stamped by the scaffolder/propagate; staleness is visible every session). |
| `verify-file-integrity.{ps1,sh}` | pre-commit corruption gate: NUL bytes in tracked text files (zero-fill signature), .py compile check (truncation), script-syntax parse (.ps1 via PowerShell parser on Windows / .sh via `bash -n` on Linux — documented platform difference), **EOF sentinel** (every tools script must end with `exit ...` or `# EOF` — truncation can hide inside a comment and pass syntax checks), trailing-newline smell test, `git fsck`. Run after heavy agent writes, before committing. |
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
   Read text files with `-Encoding UTF8` explicitly.
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
