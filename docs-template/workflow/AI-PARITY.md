# AI model parity — working across models, accounts, and tools

This project is built by rotating sessions: different AI models (Claude, GPT, Gemini,
…), different accounts, different humans. Parity means **any session can pick up where
any other left off with zero verbal handoff.** These are the mechanics.

## 1. One source of truth, per-tool pointers

`AGENTS.md` at the repo root is the only rules file. Tool-specific files are
**pointers only** — never put rules in them:

| Tool | Entry file | Notes |
|------|-----------|-------|
| Claude Code / Cowork | `CLAUDE.md` | scaffolded by OGDK; points to AGENTS.md |
| OpenAI Codex CLI | `AGENTS.md` | reads it natively — nothing to add |
| Cursor | `.cursor/rules/` or AGENTS.md support | if used, add one rule file: "Read AGENTS.md in full; follow docs/00-START-HERE.md" |
| Gemini CLI | `GEMINI.md` | if used, copy CLAUDE.md's content, same pointer |
| Any other agent | paste at session start | "Read AGENTS.md, then docs/00-START-HERE.md, follow the chain" |

If a rule needs to exist, it goes in AGENTS.md. If a pointer file grows past ~10 lines,
something is in the wrong place.

**Rule precedence (the invisible-config problem).** Agent tools also carry global,
user-level configuration (~/.claude, ~/.gemini, agy profiles, IDE rules) that the repo
cannot see. Declared order, binding on every agent in this repo:

1. **This repo's AGENTS.md and session chain win on any process conflict.** Global
   config may set personal preferences (tone, editor, model choice) — never process
   (logging schemes, write behavior, alternative session protocols).
2. An agent whose global config instructs actions this repo forbids (e.g., writing
   session logs into or about the repo, auto-running scripts) must follow the repo
   and SAY SO, so the human can fix the global.
3. Any global-vs-repo conflict that actually fires gets a LESSONS.md entry — globals
   are invisible to other sessions, so the conflict must be made visible in the repo.

Confirmed in practice 2026-06-11: a cross-vendor parity test (read-only by explicit
instruction) still executed a global agy "unified session" script — the agent obeyed
config neither the repo nor the prompt could see.

## 2. The contract every session signs

**On start** — follow `docs/00-START-HERE.md`: PATH health (Windows) → AGENTS.md →
STATUS.md → active plan. No edits before the chain is read.

**On end** — verification gate → docs updated with code → **STATUS.md updated**.
STATUS.md is the entire inter-model memory. A session that ends without updating it
has stranded its context in a transcript no other model can see.

**The golden rule:** *if it isn't in the repo, the next session doesn't know it.*
Decisions made in chat must land in a plan, a core doc, or STATUS.md before the
session ends.

## 3. Why this matters (failure modes this prevents)

- **Invariant drift** — model B "improves" something model A built within constraints
  it can't see → constraints live in AGENTS.md, read every session.
- **Collision** — two sessions touch the same in-flight work → STATUS.md names active
  plans and their state.
- **Re-litigation** — model C re-debates a settled design → plans record options
  *rejected and why*; the decision stays settled.
- **Context hoarding** — one account's chat history becomes load-bearing → forbidden
  by the golden rule; the repo is the only memory.

## 4. Sandboxed / synced-mount agents (Cowork, remote agents, cloud-synced folders)

Agents that see the repo through a sync layer (mounted folder, cloud drive) get
**eventually-consistent** file views: reads can be stale or truncated, and git's
index can be silently wrong from their side.

- **Never run `git` against the repo through a sync layer** — not even `git status`
  (it can rewrite `.git/index` based on stale stat data). Git truth comes from a
  native local shell only; the agent asks the human (or a local agent) to run git
  commands and report output.
- **Never append to or partially modify files through the mount's shell** — a write
  positioned against a stale file length lands at the wrong offset and corrupts the
  real file (one byte overwritten mid-file). Whole-file writes via the session's
  direct file tools are the ONLY safe mutation; shell-side file mutation is banned.
- Shell-side *reads* may lag too — when shell view and direct file tools disagree,
  the direct file tools win.
- Confirmed in practice 2026-06-10/11: stale mount produced truncated reads, false
  git status, AND offset-corrupted appends. All three, one day.

## 5. Trust calibration

- Treat any claim in STATUS.md as true-as-of-its-date; verify before relying on
  anything older than the last few commits (`git log --oneline -10` is cheap).
- A model that finds the docs wrong **fixes the docs in the same commit** as the code
  — parity decays one stale doc at a time.
- Plans are immutable once active; disagreement = a new plan that supersedes, not an
  in-place edit (see DOCUMENTATION-VERSIONING-GUIDE.md).
