# {{PROJECT_NAME}} — Agent Rules

> **Session chain:** this file → [docs/STATUS.md](./docs/STATUS.md) → active plan.
> Full protocol: [docs/00-START-HERE.md](./docs/00-START-HERE.md). Update STATUS.md before ending a session.

## ⚠️ Launch environment (read before every session)
- **NEVER launch Claude Code, or any AI coding agent, from an MSYS2, Git Bash, or WSL
  terminal.** Those shells prepend POSIX-emulation binaries to the process PATH; agent
  file writes then go through the Linux file API against NTFS, producing zero-filled
  tails, truncation, and SHA-256 mismatches.
- **Always launch from plain PowerShell or cmd.**
  Use: `.\tools\launch-claude-clean.ps1` · Verify: `.\tools\verify-path-health.ps1`
- If `verify-path-health.ps1` reports any FAIL, **stop and fix the PATH before proceeding.**
- **Linux (dual-boot):** the mirror hazard — never run agent writes against a shared
  NTFS partition; work on a native-filesystem clone and sync via git. Gate:
  `./tools/verify-path-health.sh` must pass.
- **Sandboxed/synced-mount agents: never run `git` and never write files through the
  mount shell** — file tools only; git truth comes from a local shell only
  (docs/workflow/AI-PARITY.md §4).

## Architecture
<!-- FILL IN: the 3–6 structural rules that must never be violated.
     App track: see OGDK/app/STACK.md §Invariants for the proven starting set.
     Game track: see OGDK/game/STACK.md §Module rules. -->
- _(fill in)_

## Invariants
<!-- FILL IN: domain invariants — data correctness rules, ordering guarantees,
     precision rules (e.g. "money is integer cents end-to-end"). -->
- _(fill in)_

## Verification gate (run before every commit)
- **`.\tools\gate.ps1`** (Linux: `./tools/gate.sh`) — one command, exit 0 or no commit.
  It chains: file integrity → reference coverage → this project's tests/builds.
  <!-- FILL IN tools/gate.{ps1,sh} §project checks with this project's commands.
       App: npm test + builds · Game: UE build-freshness proxy · Python: unittest -->

## Process
- Update docs in the SAME commit as code (docs/DOCUMENTATION-VERSIONING-GUIDE.md).
- Plans before implementation (`docs/plans/`); completed plans graduate to `core/`,
  reference pages, then archive.
- Never commit secrets. One concern per commit.
