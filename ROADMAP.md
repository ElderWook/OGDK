# OGDK Roadmap — from "built" to "finished"

"Finished" for a dev kit doesn't mean feature-complete; it means **boring**: you can
scaffold a project, work in it for weeks, and never think about the kit except when
deliberately flowing an improvement back. The base is done when it stops generating
its own work.

## Phase 1 — Anchor (do before any real project work)

Everything currently lives on one machine. One disk failure erases the LLC.

- [x] Private GitHub repos pushed: `OGDK`, `DevSandbox`, `DevKitGhost` (+ OpenBook on
      its pre-existing remote) — 2026-06-10
- [x] LFS verified on GitHub UI ("Stored with Git LFS") — 2026-06-10
- [x] Clone test PASSED 2026-06-11: virgin DevKitGhost clone ran its full gate green;
      DevSandbox clone pulled LFS content ("Filtering content") — the repo is the
      whole truth, the kit travels
- [x] Push-at-session-end in session-end skill + interruption protocol — 2026-06-10

**Exit criteria:** a fresh `git clone` on a second machine yields a working project.

## Phase 2 — Prove the game track (in DevSandbox)

The app track is proven (OpenBook). The game track is sound-on-paper only. Use
validates; docs don't.

- [x] OASISCORE-PLAN → OasisCore plugin compiled + load-verified on DevKitRTX — 2026-06-11
- [x] GF_Sample GameFeature with subsystem smoke test (log-line gate passed) — 2026-06-11
      (formal automation spec arrives with the first real gameplay system)
- [ ] Milestone scene + first perf baseline (blocked on first real content — unblocks
      when game design starts)
- [ ] Pin the DevKitRTX branch/commit in AGENTS.md §Engine (user knows the answer; 2-min task)
- [x] Friction flowed back: reference pages (oasiscore-plugin, gamefeature-pattern)
      capture the pattern learnings — 2026-06-11

**Exit criteria:** a session can add a small gameplay system entirely inside a GF_
plugin, gate passes, and no kit doc needed correcting along the way.

## Phase 3 — Make the gates mechanical

A gate that relies on remembering is a suggestion. Promote AGENTS.md gates from
prose to a runnable command per project.

- [x] `tools/gate.{ps1,sh}` in every repo + kit template via scaffolder; all AGENTS.md
      gates now say "run gate" — 2026-06-11 (bash twins tested in sandbox; user
      smoke-tests .ps1 per repo)
- [x] App track CI: OpenBook `.github/workflows/ci.yml` already existed (Node 22,
      installs + tests + builds on push) — verified 2026-06-11
- [x] Game track: gate stays local by design (UE build-freshness proxy in
      DevSandbox's gate; CI deferred until it hurts — rule of two for infra)

**Exit criteria:** "did I break it?" is one command, same on both OSes.

## Phase 4 — The learning loop (continuous; formalized 2026-06-11)

The kit actively learns: sessions CAPTURE friction (`docs/LESSONS.md`, session-end
step 4) → the `kit-retro` skill CODIFIES open lessons into skills/rules/scripts/
reference pages (human-approved — skills never self-modify silently) → the gates
VERIFY. Seeded with six real lessons from the build itself.

- [ ] Use the skills in real Claude Code sessions; log every chafe to LESSONS.md
- [ ] Run `kit-retro` at milestones or when a LESSONS.md hits 5+ OPEN entries
- [ ] Connect GitHub MCP/connector for chat-side PR + issue work once available

## Anti-goals (the traps that would un-finish the kit)

- **No speculative extraction.** Nothing enters `app/packages/` or OasisCore without
  a second concrete consumer. An empty-but-compiling OasisCore is Phase 2's only
  exception (it's structure, not logic).
- **No kit polishing as procrastination.** Tooling work feels productive and ships
  nothing. After Phase 3, kit time is capped at milestone retros.
- **No new doc types.** The chain is START-HERE → AGENTS → STATUS → plan → core →
  reference. If information doesn't fit, the answer is almost always "put it in an
  existing doc", not a new category.

## The reference tier (added 2026-06-11)

Every project carries `docs/reference/` — SDK-grade, one polished page per shipped
component, written for consumers with zero session context (finish-line model:
official platform SDK docs). Enforced by the graduation rule: **a plan cannot be
archived until its reference pages exist** (plan-writer §7 names them up front;
session-end checks them). This is how the "perfect docs of every component" goal
survives contact with shipping pressure — it's a gate, not an aspiration.

## The steady-state loop (what life looks like after Phase 3)

```
idea
 └─ new-project.ps1 → fill AGENTS.md (15 min) → first plan         [day 0]
     └─ session loop:
          session-start skill → work the active plan → gate.ps1
          → session-end skill (STATUS.md + push)                   [repeat]
     └─ milestone: perf check (game) / release pipeline (app)
          → kit retro → flow improvements back to OGDK             [per milestone]
```

At that point the stack's job is done: every hour goes into the art — the game, the
app — and the process runs itself in the margins.
