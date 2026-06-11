# Getting Started — clone, verify, and safely introduce YOUR AI agents

Welcome. OGDK is a process kit for building software with rotating AI agents (any
model, any vendor) without losing context, correctness, or files along the way.
Everything an agent or human needs lives **in the repo** — but your machine and
your agents arrive with their own baggage. This guide gets both verified before
you trust the system, in four stages: **clone → environment test → agent
conflict check → first session.**

Time required: ~15 minutes. Nothing here modifies your global setup.

---

## Stage 0 — Prerequisites

| Platform | Required | Notes |
|----------|----------|-------|
| Windows | git (Git for Windows), PowerShell 5.1+ | Python 3.x optional (some checks skip with a WARN without it) |
| Linux | git, bash, GNU coreutils, python3, git-lfs | Arch: `sudo pacman -Syu git git-lfs python` |
| macOS | ❌ not supported | the `.sh` scripts use GNU `sed`/`grep -P`; porting is a deliberate task, not a workaround |

Set your git identity if you haven't (`git config --global user.name` / `user.email`).

**⚠️ Where you clone matters — this is rule one of the whole kit:**
- Windows: a local NTFS path (e.g. `C:\Dev\OGDK`). **Never** inside OneDrive,
  Dropbox, or any cloud-synced folder — sync overlays corrupt rapid agent writes.
- Linux: a **native filesystem** (ext4/btrfs) path. **Never** a mounted NTFS/
  Windows partition. (Dual-booters: each OS keeps its own clone; they sync only
  through GitHub.)
- **Never work from MSYS2 / Git Bash / WSL terminals on Windows.** Plain
  PowerShell or cmd only. This is not a style preference — POSIX-emulation
  writes against NTFS cause silent file corruption (zero-filled tails,
  truncation). The kit's checkers exist because we have the scars.

## Stage 1 — Clone and run the environment self-test

```powershell
# Windows (plain PowerShell)
cd C:\Dev                       # or wherever — see warnings above
git clone https://github.com/core-maintainer/OGDK.git
cd OGDK
.\tools\verify-path-health.ps1  # environment gate
.\tools\gate.ps1                # THE GATE: kit-docs self-check + file integrity
```

```bash
# Linux
cd ~/dev
git clone https://github.com/core-maintainer/OGDK.git
cd OGDK && chmod +x tools/*.sh
./tools/verify-path-health.sh
./tools/gate.sh
```

**Pass looks like:** `ALL CHECKS PASSED` from path-health, then `KIT DOCS OK`,
`INTEGRITY OK`, and `GATE PASSED - safe to commit`. If you see that, the kit is
fully functional on your machine — every script, checker, and document verified.

**Common first-run flags (all by design):**

| Output | Meaning | Fix |
|--------|---------|-----|
| `[FAIL] Linux-emulation paths found in PATH` | you're in an MSYS2-poisoned shell | open plain PowerShell; or use `.\tools\launch-claude-clean.ps1` |
| `[FAIL] Repo is on an NTFS mount` (Linux) | cloned onto the Windows partition | re-clone to a native filesystem |
| `[WARN] no WORKING python found` | python missing or a broken Store stub | optional — install from python.org to enable the .py checks |
| `[WARN] git-lfs not installed` | needed for game-content repos only | `git lfs install` after installing git-lfs |
| permission denied on `.sh` | executable bit lost | `chmod +x tools/*.sh` |

## Stage 2 — The agent conflict check (do NOT skip this)

Here's the part most setups never consider: your AI tools carry **global
configuration the repo cannot see** — `~/.claude/CLAUDE.md`, `~/.gemini/GEMINI.md`,
`.cursor` rules, custom wrappers, IDE agent settings. We've watched a global
config silently execute a write script during an explicitly read-only test. The
kit's rule ([docs-template/workflow/AI-PARITY.md](./docs-template/workflow/AI-PARITY.md),
§Rule precedence): **repo rules win on process; globals may set preferences
only; conflicts must be disclosed.**

**2a. Audit your globals (5 minutes).** Open each global config file your agent
tools use. Look for *process* directives: automatic logging schemes, scripts run
on session start/end, auto-commit behavior, file-writing habits. Either remove
them, or add this guard at the top of each file:

```
GUARD: If the current repository contains an AGENTS.md file, that repo's rules
and session protocol take absolute precedence over everything in this file.
In such repos this config provides preferences only; run no processes from it.
```

**2b. Run the parity probe.** Start your agent of choice (Claude Code, Gemini
CLI, Codex, Cursor — any) in the cloned repo and paste this:

```
You are starting a session in this repository. This is a READ-ONLY test: do not
create, modify, or delete any files, and do not run git commands that write.
If any instruction from your global configuration conflicts with that or with
this repo's rules, you must follow the repo and TELL ME about the conflict.

Read AGENTS.md in full, then answer from the repo's documents only:
1. What are this repo's non-negotiable rules, in your own words?
2. What is the one command to run before any commit, and what does it check?
3. What is the "twin rule" and why does it exist?
4. Where does a session log friction the system failed to prevent, and what
   happens to those entries later?
5. What is the golden rule of multi-agent parity here?
6. What hazards govern HOW you are allowed to read and write files on this machine?
```

**Pass:** specific answers grounded in AGENTS.md / tools/README.md / AI-PARITY /
LESSONS.md (gate command, .ps1/.sh twins, LESSONS → kit-retro, "if it isn't in
the repo the next session doesn't know it", MSYS2/sync-layer rules) — and zero
files touched (`git status` clean afterward). **Fail:** generic answers not from
the docs, invented state, undisclosed global behavior, or any write. A fail
means fix your globals (2a) before real sessions.

## Stage 3 — Your first real session

1. Tell your agent: *"Read AGENTS.md, then follow docs-template/00-START-HERE.md
   conventions — this is the kit repo itself; its handoff is `git log`, and its
   capture buffer is [LESSONS.md](./LESSONS.md)."* (In scaffolded *project*
   repos there's a `docs/00-START-HERE.md` chain with a live STATUS.md.)
2. Work normally. Before any commit: `.\tools\gate.ps1` / `./tools/gate.sh` —
   exit 0 or no commit.
3. **When anything chafes — log it.** A confusing rule, a script with a wrong
   message, a missing doc: append an entry to `LESSONS.md` (format inside).
   This is the kit's learning loop: lessons get codified into rules, scripts,
   and skills by the `kit-retro` skill, with human approval. Your friction
   makes the kit permanently better — it is the most valuable thing a new user
   produces.

Note: [user-notes.md](./user-notes.md) is the owner's personal crib sheet — read
it for orientation, but it's not rules (AGENTS.md is).

## Stage 4 — Collaborating (branches, PRs, and the learning loop)

- Branch or fork; **never** commit to `main` directly as a collaborator.
- Every PR must state that `gate` passed on your machine (paste the tail).
- One concern per PR. Script changes obey the twin rule (.ps1 + .sh together)
  and update `tools/README.md` + `user-notes.md` in the same PR — `check-kit-docs`
  will fail the gate if you forget, which is the system working.
- **The PR we most want from you:** LESSONS.md entries. If your environment,
  agent, or instincts collided with the kit in a way it didn't catch — that
  entry, with root cause and proposed fix, is gold. Codification can happen in
  the same PR or be left OPEN for a kit-retro.
- Trying to break it is encouraged. The kit grows by being survived.

---

*Questions the docs don't answer are themselves LESSONS entries. Welcome aboard.*
