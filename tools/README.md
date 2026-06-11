# tools/ — cross-platform parity policy

Every script ships as a **twin pair**: `.ps1` (Windows PowerShell 5.1+) and `.sh`
(bash, Linux/macOS). Same name, same behavior, same exit semantics.

| Pair | Purpose |
|------|---------|
| `verify-path-health.{ps1,sh}` | session-start environment gate. Windows: MSYS2/WSL PATH poisoning, malformed PATH, cloud-sync overlays. Linux: NTFS-mount hazard, git identity, LFS, autocrlf. |
| `verify-file-integrity.{ps1,sh}` | pre-commit corruption gate: NUL bytes in tracked text files (zero-fill signature), .py compile check (truncation), trailing-newline smell test, `git fsck`. Run after heavy agent writes, before committing. |
| `check-reference-coverage.{ps1,sh}` | documentation gate: parses `docs/reference/COVERAGE.md`, fails on pages that don't exist, warns on STALE pages (source committed after page) and MISSING backlog. Run at session end. |
| `check-kit-docs.{ps1,sh}` | (kit only, not propagated) self-check: twin rule, user-notes.md + this README mention every script, no ghost references to deleted scripts. Run before any kit commit. |
| `launch-claude-clean.{ps1,sh}` | run the health gate, then launch Claude Code |
| `new-project.{ps1,sh}` | scaffold a new App/Game project from the kit |

## Rules

1. **Twin rule:** any change to a script updates its twin in the SAME commit
   (enforced in OGDK AGENTS.md). If behavior must differ per platform (the hazards
   really are different), the difference is commented at the top of both files.
2. **.ps1 constraints:** Windows PowerShell 5.1 compatible — ASCII only, no
   here-strings (they break with LF line endings), CRLF-agnostic constructs only.
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
  stale data). Git runs in a native local shell only. See docs-template/workflow/AI-PARITY.md §4.
