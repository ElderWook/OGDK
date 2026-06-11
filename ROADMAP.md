# OGDK Roadmap — from "built" to "finished"

"Finished" for a dev kit doesn't mean feature-complete; it means **boring**: you can
scaffold a project, work in it for weeks, and never think about the kit except when
deliberately flowing an improvement back. The base is done when it stops generating
its own work.

## Phase 1 — Anchor (do before any real project work)

Everything currently lives on one machine. One disk failure erases the LLC.

- [x] Private GitHub repos pushed: `OGDK`, `DevSandbox`, `DevKitGhost` (+ the origin app on
      its pre-existing remote) — 2026-06-10
- [x] LFS verified on GitHub UI ("Stored with Git LFS") — 2026-06-10
- [x] Clone test PASSED 2026-06-11: virgin DevKitGhost clone ran its full gate green;
      DevSandbox clone pulled LFS content ("Filtering content") — the repo is the
      whole truth, the kit travels
- [x] Push-at-session-end in session-end skill + interruption protocol — 2026-06-10

**Exit criteria:** a fresh `git clone` on a second machine yields a working project.

## Phase 2 — Prove the game track (in DevSandbox)

The app track is proven (the origin app). The game track is sound-on-paper only. Use
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
- [x] App track CI: the origin app `.github/workflows/ci.yml` already existed (Node 22,
      installs + tests + builds on push) — verified 2026-06-11
- [x] Game track: gate stays local by design (UE build-freshness proxy in
      DevSandbox's gate; CI deferred until it hurts — rule of two for infra)
- [ ] Propagate 2026-06-11 tool additions (`new-reference-page.{ps1,sh}`,
      `release-notes.{ps1,sh}`) to existing projects — DevKitGhost + DevSandbox
      (+ the origin app if it adopts the reference tier). One implementation plan, both
      repos knocked out together; scaffolder already covers all future projects.
- [ ] **Final kit smoke test — hostile-environment pass:** validated cross-platform
      locally (Arch gate green 2026-06-11), but "works on my machines" isn't the bar.
      Test as if on someone ELSE's box: fresh Windows clone, stock PowerShell 5.1,
      no personal git config/globals, spaces-in-path user dir, OneDrive-synced
      folder hazard, missing optional deps (lfs, node) — every .ps1 twin actually
      executed, not just its .sh sibling. Exit: a stranger scaffolds + gates green
      with only README instructions.

**Exit criteria:** "did I break it?" is one command, same on both OSes.

## Phase 4 — The learning loop (continuous; formalized 2026-06-11)

The kit actively learns: sessions CAPTURE friction (`docs/LESSONS.md`, session-end
step 4) → the `kit-retro` skill CODIFIES open lessons into skills/rules/scripts/
reference pages (human-approved — skills never self-modify silently) → the gates
VERIFY. Seeded with six real lessons from the build itself.

**Input valve (added 2026-06-12): the `repo-study` skill ("Student mode")** — study
excellent external repos in an isolated workspace (never cloned into kit repos;
license-disciplined; read-only) and convert their practices into LESSONS entries
via ADOPT/ADAPT/DECLINE/CONFIRMS verdicts. Ideas flow in; foreign code does not;
findings merge through the normal lessons→retro pipeline, not git branches.

- [ ] Use the skills in real Claude Code sessions; log every chafe to LESSONS.md
- [ ] Run `kit-retro` at milestones or when a LESSONS.md hits 5+ OPEN entries
- [ ] Connect GitHub MCP/connector for chat-side PR + issue work once available

## Sprint workstreams (2026-06-12 — pre-hiatus push; plan of record)

Declared during the founder's gung-ho window. Order matters: WS1 blocks adding any
collaborator; WS2/WS3 are share-readiness depth.

### WS1 — Privacy & IP boundary (BLOCKS collaborator invite)

Goal: personal/private-project data fully stripped from the kit and mechanically
prevented from returning — in BOTH directions (founder's data out; collaborators'
project IP never in).

- [ ] **Sweep the kit** for private context: kit ROADMAP currently names DevKitGhost
      phases/PPA and the game slate (move specifics to project repos; kit speaks
      abstractly: "hardware project", "first game title"); kit LESSONS entries
      containing `C:\Users\<name>` paths and machine specifics (genericize);
      user-notes repo map + Arch checklist username; any email/handle scans
- [ ] **user-notes disposition decision:** it's per-OWNER by nature. Proposal:
      keep the file (check-kit-docs depends on it) but make it the generic
      "operator's crib sheet" — personal repo maps and project pointers move to a
      gitignored `user-notes.local.md` companion. DECIDE before sweep.
- [ ] **Mechanical guard — check-kit-docs check 8:** scan tracked kit files
      against a `PRIVATE-MARKERS.list` (gitignored, per-owner: usernames, emails,
      project codenames, home paths). FAIL on hit. Twin rule applies.
- [ ] **Inbound protection — `BOUNDARY.md` policy:** what may enter the kit
      (generic process, genericized lessons, anonymized findings) vs never
      (project code, project names without consent, anything from a
      collaborator's repos; kit-level LESSONS must be scrubbed of project
      specifics — project LESSONS stay in project repos). Referenced from
      GETTING-STARTED Stage 5 + kit AGENTS rules.
- [ ] **History audit:** private context already in git history (kit ROADMAP
      revisions etc.). Decide: acceptable for trusted private collab now +
      history rewrite ONLY if/when going public (filter-repo; ask-first list).

### WS2 — Feature-driven app skeletons (open the track beyond the proven combo)

Goal: a user states the features their app needs; the stack guides the leanest
correct skeleton — the proven Tauri+Svelte+SQLite+relay shape becomes ONE preset,
not the only path.

- [ ] `app/APP-ARCHITECT.md`: feature→module decision guide (needs offline? →
      local-first store pattern · multi-device? → sync+authority model · mobile? →
      $platform bridge · heavy docs/PDF? → render module · none of the above? →
      delete that module). Composable: every module optional except the core
      invariants (exact math, durable writes, integrity)
- [ ] Expand the README app mermaid into the composable view: modules drawn as
      optional blocks with their "include when..." conditions
- [ ] Scaffolder follow-up (later, not sprint): `-Features` flag or interactive
      prompt mapping answers to skeleton dirs — design only for now
- [ ] Invariants vs choices made explicit in app/STACK.md: what is LAW regardless
      of combination vs what was merely the origin app's choice

### WS3 — Engine portability for the game track

Goal: a future engine port (Godot/Unity/custom) is a guided re-implementation,
not archaeology. Honest framing: UE code does NOT port; architecture, data, and
design DO — maximize the share that ports.

- [ ] `game/conventions/engine-portability.md`: the portable core (one-way
      dependency pattern, feature-module decomposition, data-driven tuning,
      tag-based identity) vs the engine-bound shell (UE APIs, BP, GAS specifics);
      rule: gameplay DESIGN data lives in engine-neutral sources where cheap
      (tables/JSON imported into engine assets, not authored only inside them)
- [ ] "Engine boundary" rule in game/STACK.md: every GF_ plugin's reference page
      documents its engine-API surface — that section IS the port checklist
- [ ] GDD discipline already helps (mechanics specified engine-neutrally in
      GDDs/plans); make that an explicit convention line

## Future tracks (recorded intent — NOT started; rule of two governs)

Tracks the kit will likely grow, logged here so the intent survives sessions.
Each activates only when its first real project starts (and extracts to a kit
track when a second one exists):

- **`embedded/` — firmware & low-level.** Seeded by DevKitGhost's bench phase
  (toolchain pinning, flash/RAM size budgets as the embedded twin of perf
  budgets, flashing-script twins, HIL test protocol, binary artifact policy,
  bootloader/OTA concerns). Activation trigger: DevKitGhost Phase H1 or any
  second embedded project.
- **`retro/` — Xbox 360 console development. ❤️ Founder's origin story.**
  Homebrew/hardware-research development for the console that got the founder
  into tech. The user holds substantial existing material (community knowledge,
  hardware notes — RGH/JTAG-era ecosystem) ready to be structured into the
  track when it activates: toolchain + SDK conventions, hardware reference
  pages, the same chain/gates/lessons process as every track. This one is
  allowed to be a labor of love rather than a revenue line — the kit should
  serve joy too. Activation trigger: the founder says "now."

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
