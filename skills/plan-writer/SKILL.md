---
name: plan-writer
description: Write an implementation plan in docs/plans/ following the OGDK documentation lifecycle. Use when asked to "write a plan", "plan a feature", "design X before building", or before implementing any non-trivial feature or refactor.
---

# Plan writer

Plans are written BEFORE implementation and are immutable snapshots of the design
decision (see `docs/DOCUMENTATION-VERSIONING-GUIDE.md`).

1. Read `AGENTS.md` and `docs/STATUS.md` first — a plan that violates an invariant or
   collides with an active plan is wasted work.
2. Create `docs/plans/<FEATURE>-PLAN.md` with this structure:

```markdown
# <Feature> — Plan
**Status:** Proposed · <date>

## 1. Current state assessment
What exists today; what's wrong/missing. Reference code paths and docs.

## 2. Goals / non-goals

## 3. Design
The chosen approach. Options considered and REJECTED, with reasons (this is the
section future sessions will thank you for).

## 4. Phases
Numbered, independently shippable phases, each with concrete tasks.

## 5. Test protocol
How each phase is verified. Game track: include the perf note
(expected steady-state + worst-case cost, per game/conventions/performance.md).

## 6. Risks & mitigations

## 7. Documentation impact
MANDATORY discovery step: open `docs/reference/COVERAGE.md` and check every source
path this plan touches against the manifest. Any touched path that maps to an
existing page -> that page is listed here as UPDATE (you do not get to not know).
New components -> CREATE entries here AND a new COVERAGE.md row in the same commit.
The plan cannot be archived until every entry exists/is updated — the graduation
rule (docs/reference/README.md), checked by tools/check-reference-coverage.
```

3. Register the plan in `docs/STATUS.md §Active plans` with status "Proposed".
4. On approval, status → "Active". On completion: graduate content to `docs/core/`,
   **write/update every reference page named in §7 (same commit)**, then move the
   plan to `docs/plans/archive/`. No reference page, no archive.
