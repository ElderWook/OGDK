# tools/ — cross-platform parity policy

Every script ships as a **twin pair**: `.ps1` (Windows PowerShell 5.1+) and `.sh`
(bash, Linux with GNU userland). Same name, same behavior, same exit semantics.
macOS is NOT supported: the `.sh` scripts use GNU `sed -i` and `grep -P`, which break
on BSD tools. If a Mac ever joins the fleet, that's a deliberate porting task.

| Pair | Purpose |
|------|---------|
| `verify-path-health.{ps1,sh}` | session-start environment gate. Windows: MSYS2/WSL PATH poisoning, malformed PATH, cloud-sync overlays. Linux: NTFS-mount hazard, git identity, LFS, autocrlf. |
| `verify-file-integrity.{ps1,sh}` | pre-commit corruption gate: NUL bytes in tracked text files (zero-fill signature), .py compile check (truncation), trailing-newline smell test, `git fsck`. Run after heavy agent writes, before committing. |
| `check-reference-coverage.{ps1,sh}` | documentation gate: parses `docs/reference/COVERAGE.md`, fails on pages that don't exist, warns on STALE pages (source committed after page) and MISSING backlog. Run at session end. |
| `check-kit-docs.{ps1,sh}` | (kit only, not propagated) self-check: twin rule, user-notes.md + this README mention every script, no ghost references to deleted scripts. Run before any kit commit. |
| `gate.{ps1,sh}` | THE GATE — one command per repo: integrity → coverage → project tests/builds, exit 0 or no commit. Kit ships `gate.template.{ps1,sh}` via the scaffolder; each project fills its §project checks. The kit's own gate runs kit-docs + integrity. |
| `launch-claude-clean.{ps1,sh}` | run the health gate, then launch Claude Code |
| `new-project.{ps1,sh}` | scaffold a new App/Game project from the kit (tool copy-list lives in `PROPAGATE.list`) |
| `propagate-tools.{ps1,sh}` | (kit only) push kit tools (and `-Skills`/`--skills`: skills) into an EXISTING project per `PROPAGATE.list`; verifies copies byte-identical (truncated-propagation lesson). Never runs git — gate + commit in the target repo yourself. |
| `new-reference-page.{ps1,sh}` | scaffold `docs/reference/<slug>.md` from COMPONENT-TEMPLATE.md AND append its COVERAGE.md row in one command — the graduation rule, mechanical. Run from a project root; fill the page before committing (page + manifest + component in the same commit). |
| `release-notes.{ps1,sh}` | draft tag-to-tag release notes from `git log` to stdout (redirect to a file, then edit). Groups `type:`-prefixed subjects, lumps the rest under "Other changes" — no commit-message discipline required. Drafts only; never writes files; history stays in git. |

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
