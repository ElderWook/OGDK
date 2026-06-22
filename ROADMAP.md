# OGDK Roadmap — from "built" to "finished"

"Finished" for a dev kit doesn't mean feature-complete; it means **boring**: you can
scaffold a project, work in it for weeks, and never think about the kit except when
deliberately flowing an improvement back. The base is done when it stops generating
its own work.

## Status (2026-06-22): structurally finished; validation + use is what's left

The base is built and then some. Since the 2026-06-13 audit the kit has added: the
**gitwalk** git-lifecycle (no-skip C0-C6 checkpoints + native/mount execution modes +
`safe-agent-push`), the **SCALING** three-tier model (LESSONS working buffer -> archive;
study provenance via `study-repo/STUDY-INDEX.md`), **fleet** auto-tracking
(`track-projects` / `fleet-status` / `fleet-work`), the behavioral **twin-parity** check,
a **wip-exempt pre-commit** integrity gate, and a **beginner on-ramp** (START-BUILDING,
bootstrap, rescue, report-snag, explain-mode/project-retro, the `-Features` scaffolder).
The session-start AND session-end skills are now mode-aware and kit-aware. The whole fleet
(kit + 7 projects) is clean and leveled. What remains is **not new construction** - it is
proving and using:

- the hostile-environment pass on a real fresh Windows box (Phase 3, still open) - the new
  `.ps1` tools are pwsh-parse-verified but not yet run on real PowerShell 5.1 hardware;
- a real first-timer running the beginner track end to end (WS4, still open) - the persona
  the on-ramp was built for has not met it yet.

The anti-goals below are the tiebreaker: the surest sign the kit is finished is to **stop
adding to it and ship a real project.** Kit time is now polishing, allowed only against a
concrete need (rule of two).

## Phase 1 — Anchor (do before any real project work)

Everything currently lives on one machine. One disk failure erases the LLC.

- [x] Private GitHub repos pushed: the kit + all three project repos — 2026-06-10
- [x] LFS verified on GitHub UI ("Stored with Git LFS") — 2026-06-10
- [x] Clone test PASSED 2026-06-11: a virgin project clone ran its full gate green;
      the game repo's clone pulled LFS content ("Filtering content") — the repo is
      the whole truth, the kit travels
- [x] Push-at-session-end in session-end skill + interruption protocol — 2026-06-10

**Exit criteria:** a fresh `git clone` on a second machine yields a working project.

## Phase 2 — Prove the game track (in the game proving-ground repo)

The app track is proven (origin app project). The game track is sound-on-paper only.
Use validates; docs don't.

- [x] OASISCORE-PLAN → OasisCore plugin compiled + load-verified on the engine fork — 2026-06-11
- [x] GF_Sample GameFeature with subsystem smoke test (log-line gate passed) — 2026-06-11
      (formal automation spec arrives with the first real gameplay system)
- [ ] Milestone scene + first perf baseline (blocked on first real content — unblocks
      when game design starts)
- [x] Engine-fork pin recorded in the game repo's AGENTS.md §Engine — DONE
      2026-06-12 (version + CompatibleChangelist from Build.version; provenance
      noted as zip-sourced: updates = new sibling folder + pin update, no local
      engine git history to diff)
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
- [x] App track CI: the origin app's `.github/workflows/ci.yml` already existed
      (Node 22, installs + tests + builds on push) — verified 2026-06-11
- [x] Game track: gate stays local by design (UE build-freshness proxy in the game
      repo's gate; CI deferred until it hurts — rule of two for infra)
- [x] Propagate tool additions to existing projects — DONE 2026-06-12 via
      `propagate-tools -All` (TARGETS.list fleet propagation; all three project
      repos stamped with KIT-VERSION; the origin app adopted the reference tier
      and cleared its 10-page backlog same day).
- [ ] **Final kit smoke test — hostile-environment pass:** validated cross-platform
      locally (Arch gate green 2026-06-11), but "works on my machines" isn't the bar.
      Test as if on someone ELSE's box: fresh Windows clone, stock PowerShell 5.1,
      no personal git config/globals, spaces-in-path user dir, OneDrive-synced
      folder hazard, missing optional deps (lfs, node) — every .ps1 twin actually
      executed, not just its .sh sibling. Exit: a stranger scaffolds + gates green
      with only README instructions.
- [x] Sandboxed .sh smoke pass — 2026-06-11 (Cowork/Linux, faithful copy): kit gate
      green; App+Game scaffolds green after fixing two real finds, same day:
      CRLF-intolerant .sh list parsers (blocked scaffold on Windows checkouts) and
      the grep -c zero-count error spam (LESSONS 2026-06-11 entries).
      **Still missing from the stack, surfaced by that pass:**
      - [x] verify-file-integrity.{ps1,sh}: silently vacuous outside a git repo
            (empty `git ls-files` → PASS over zero files) — add a "0 files
            checked" WARN or a `find` fallback
      - [x] Synced-mount verification protocol (AI-PARITY §4 extension): mount
            READS can serve stale/truncated views; in-sandbox gate runs must use
            file-tool-sourced copies — write the rule down
      - [x] .ps1 twins still never executed by an agent pass — stays with the
            hostile-environment item above
      - [x] After re-propagation: fleet repos carry the fixed
            check-reference-coverage.sh (it's in PROPAGATE.list)

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
- [x] MCP integration policy — DONE 2026-06-12: `docs-template/workflow/MCP.md`
      (sensitivity tiers per repo; host-shell escape hatch superseding the
      ask-the-human rule; config map; secrets-as-env-vars; declines recorded),
      `templates/mcp.json.template`, AI-PARITY §1+§4 wiring; propagated to all
      projects with the hardware project marked `restricted` (pre-filing IP
      freeze: local-only servers). Actually CONNECTING GitHub MCP per tool is
      a per-operator action — policy and config template are ready for it.

## Sprint workstreams (2026-06-12 — pre-hiatus push; plan of record)

Declared during the founder's gung-ho window. Order matters: WS1 blocks adding any
collaborator; WS2/WS3 are share-readiness depth.

### WS1 — Privacy & IP boundary (BLOCKS collaborator invite)

Goal: personal/private-project data fully stripped from the kit and mechanically
prevented from returning — in BOTH directions (founder's data out; collaborators'
project IP never in).

- [x] **Sweep the kit** for private context — DONE 2026-06-12: personal paths
      genericized in LESSONS; project names abstracted kit-wide ("the hardware
      project", "the game proving-ground", "the origin app"); no emails/usernames
      outside necessary clone URLs
- [x] **user-notes split** — DONE 2026-06-12: tracked `user-notes.md` is the
      generic operator crib; personal repo map/machine setup/project commands live
      in gitignored `user-notes.local.md`; GETTING-STARTED instructs every operator
      to create their own
- [x] **Mechanical guard — check-kit-docs check 8** — DONE 2026-06-12: scans
      tracked kit files against gitignored `tools/PRIVATE-MARKERS.list` (one
      marker/line, # comments); FAIL on hit, reports marker INDEX only (output
      stays shareable); WARN when list absent. Twin rule applied. Maiden scan
      caught + fixed three real leaks (tool comments, engine-fork name).
- [x] **Inbound protection — `BOUNDARY.md`** — DONE 2026-06-12: inbound
      allowed (generic process, scrubbed lessons, anonymized repo-study
      findings) vs never (project code, project names without consent,
      collaborator IP, personal data); referenced from GETTING-STARTED Stage 5
      + kit AGENTS rule 8 + tools/README + user-notes.
- [x] **History audit — DECIDED 2026-06-12** (recorded in BOUNDARY.md):
      pre-sweep history accepted while the kit stays private with trusted
      collaborators; `git filter-repo` against an ask-first list REQUIRED
      before any flip to public — the BOUNDARY.md history note is the tripwire.

**WS1 COMPLETE — collaborator invite unblocked.**

### WS2 — Feature-driven app skeletons (open the track beyond the proven combo)

Goal: a user states the features their app needs; the stack guides the leanest
correct skeleton — the proven Tauri+Svelte+SQLite+relay shape becomes ONE preset,
not the only path.

- [x] `app/APP-ARCHITECT.md` — DONE 2026-06-12: feature questions → module catalog
      → five presets (proven combo = Preset A) → composable mermaid; boundary law
      unified with the game track's one-way rule
- [x] README app mermaid expanded to the composable view — DONE 2026-06-12
- [x] **CODE-CONVENTIONS + the generation policy** — DONE 2026-06-12: language
      skeletons are GENERATED per conventions, never stored (stored boilerplate
      rots; agents emit fresh annotated skeletons; rule of two can graduate hot
      presets to templates). Annotation standard: @intent/@flow/@boundary/
      @invariant/@risk/@todo
- [x] **Annotated exemplar shipped** — DONE 2026-06-12: `app/exemplar/` (~120-line
      pure-Python tab ledger: pure core + atomic-write adapter + composition root
      + mirrored tests, 8/8 green) — the quality bar every generated skeleton
      must match, in any language
- [ ] Scaffolder follow-up (later, not sprint): `-Features` flag mapping answers
      to skeleton generation — design only for now
- [x] Invariants vs choices explicit — DONE 2026-06-12 (APP-ARCHITECT §4)

### WS3 — Engine portability for the game track

Goal: a future engine port (Godot/Unity/custom) is a guided re-implementation,
not archaeology. Honest framing: UE code does NOT port; architecture, data, and
design DO — maximize the share that ports.

- [x] `game/conventions/engine-portability.md` — DONE 2026-06-12: three-layer
      model (design ports 100% / data ~100% via neutral-sources rule / code ports
      as SHAPE); engine-abstraction wrapper layer explicitly DECLINED (recorded —
      costs every feature daily to maybe save a hypothetical port)
- [x] Engine boundary rule — DONE 2026-06-12: game/STACK.md module rule 8; every
      game component's reference page carries an **Engine surface** section; the
      sections collectively ARE the port checklist. Propagated to the game repo
      (conventions + gamefeature-pattern reference updated)
- [x] GDD discipline made explicit — DONE 2026-06-12 (design layer of the
      three-layer model: mechanics in design terms, never engine terms)

### WS4 — Beginner on-ramp + audit hardening (2026-06-13)

External audit against a new goal: the kit should be giftable to someone with ideas and
little coding experience, who learns how software works *by building*. Outcome: the
beginner layer now exists, and the kit's cross-platform discipline got five real drift
fixes the twin rule had not been catching.

- [x] Twin-drift fixes: sync-repo.ps1 synced-mount guard; verify-file-integrity.sh
      python probe; check-reference-coverage parity; launch-claude-clean.ps1 health gate;
      check-kit-docs.sh marker scan. Gate green; all `.ps1` pwsh-parse-clean.
- [x] Two front doors (README) + `START-BUILDING.md` (the six-word loop, maintainer
      machinery hidden behind progressive disclosure)
- [x] `bootstrap.{ps1,sh}` (one-command setup) + `rescue.{ps1,sh}` (checkpoint's
      opposite - the undo-the-mess button) + `report-snag.{ps1,sh}` (frictionless
      LESSONS capture)
- [x] `explain-mode` + `project-retro` skills (agent-as-tutor while building + the
      learner's capstone recap - the "understand how code works" payoff)
- [x] `new-project -Features/-Preset` wizard + annotated module placeholders (language
      code stays agent-generated per CODE-CONVENTIONS - no stored boilerplate)
- [x] Propagate `rescue` + `report-snag` to existing project repos (`propagate-tools --all`) — DONE 2026-06-14
- [ ] Behavioral twin-parity check - the twin rule verifies the pair EXISTS, not that
      both halves behave the same (five silent drifts proved the gap); model on test-sync-repo
- [ ] Decide the wip-exempt cheap pre-commit gate (new option; does NOT reopen the
      declined full-gate hook)
- [ ] **Validate with an ACTUAL first-timer** - the on-ramp is unproven until someone new
      scaffolds, builds a small real thing with the agent, gates green, and can explain it

**Exit criteria:** a non-programmer goes from clone to a running, gate-green project and
can describe what each part does - without ever opening a maintainer doc.

## Future tracks (recorded intent — NOT started; rule of two governs)

Tracks the kit will likely grow, logged here so the intent survives sessions.
Each activates only when its first real project starts (and extracts to a kit
track when a second one exists):

- **`embedded/` — firmware & low-level.** Seeded by the hardware project's bench
  phase (toolchain pinning, flash/RAM size budgets as the embedded twin of perf
  budgets, flashing-script twins, HIL test protocol, binary artifact policy,
  bootloader/OTA concerns). Activation trigger: that project's bench phase or any
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
