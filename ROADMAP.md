# OGDK Roadmap — from "built" to "finished"

"Finished" for a dev kit doesn't mean feature-complete; it means **boring**: you can
scaffold a project, work in it for weeks, and never think about the kit except when
deliberately flowing an improvement back. The base is done when it stops generating
its own work.

## Phase 1 — Anchor (do before any real project work)

Everything currently lives on one machine. One disk failure erases the LLC.

- [ ] Private GitHub repos: `OGDK`, `DevSandbox`, `OpenBook` — push all three
- [ ] Confirm LFS objects actually uploaded (`git lfs ls-files` after push; clone to a
      temp dir and open the project as the real test)
- [ ] Habit: push at every session end (add to session-end skill expectations)

**Exit criteria:** a fresh `git clone` on a second machine yields a working project.

## Phase 2 — Prove the game track (in DevSandbox)

The app track is proven (OpenBook). The game track is sound-on-paper only. Use
validates; docs don't.

- [ ] `docs/plans/OASISCORE-PLAN.md` → OasisCore plugin skeleton (empty but compiling:
      .uplugin, Build.cs, module classes)
- [ ] First GameFeature plugin (`GF_Sample`) with one automation smoke test
- [ ] Milestone scene + first perf baseline (Insights trace; record numbers in STATUS)
- [ ] Pin the DevKitRTX branch/commit in AGENTS.md §Engine
- [ ] Flow every friction point back into `game/` docs (expect several — that's the point)

**Exit criteria:** a session can add a small gameplay system entirely inside a GF_
plugin, gate passes, and no kit doc needed correcting along the way.

## Phase 3 — Make the gates mechanical

A gate that relies on remembering is a suggestion. Promote AGENTS.md gates from
prose to a runnable command per project.

- [ ] `tools/gate.ps1` + `tools/gate.sh` twin in each project: runs that project's
      full verification gate, exit code 0/1 (kit ships the template; AGENTS.md
      §Verification gate becomes "run `.\tools\gate.ps1`")
- [ ] App track: GitHub Actions CI running tests + builds on push (free, catches
      cross-machine breakage)
- [ ] Game track: gate stays local (UE CI needs heavy self-hosted runners — defer
      until it hurts; rule of two applies to infrastructure too)

**Exit criteria:** "did I break it?" is one command, same on both OSes.

## Phase 4 — Session ergonomics (continuous, low priority)

- [ ] Use session-start/session-end/plan-writer skills in real Claude Code sessions;
      edit them where they chafe; copy improvements back to the kit
- [ ] Kit retro at every project milestone (~30 min): what did the kit fail to
      prevent? One commit of fixes, no more
- [ ] Connect GitHub MCP/connector for chat-side PR + issue work once repos are remote

## Anti-goals (the traps that would un-finish the kit)

- **No speculative extraction.** Nothing enters `app/packages/` or OasisCore without
  a second concrete consumer. An empty-but-compiling OasisCore is Phase 2's only
  exception (it's structure, not logic).
- **No kit polishing as procrastination.** Tooling work feels productive and ships
  nothing. After Phase 3, kit time is capped at milestone retros.
- **No new doc types.** The chain is START-HERE → AGENTS → STATUS → plan → core. If
  information doesn't fit, the answer is almost always "put it in an existing doc",
  not a new category.

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
