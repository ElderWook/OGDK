# {{PROJECT_NAME}} — Developer Guide

> Role guide for **building/fixing** (see 00-START-HERE §chain). Create this once the
> codebase has shape: rename to `DEVELOPER-GUIDE.md`, fill the marked sections, and
> delete this banner. Until then this template's existence is NOT a coverage debt —
> the `.template` suffix means "not yet active".

**Since:** {{DATE}} · **Owner section of:** docs/ (same-commit rule applies)

## Orientation (fill: the 5-minute codebase tour)

Where the entry points are, how a change typically flows through the layers, and the
two or three directories where 90% of work happens. Link the architecture spec in
`core/` rather than duplicating it.

## Environment & first build (fill)

Exact commands from fresh clone to green build/tests on each supported OS. If it is
not copy-paste runnable, it is not done. Include the gate:
`./tools/gate.sh` / `.\tools\gate.ps1` must pass before any commit.

## Day-to-day workflow (fill)

How to run the thing, run one test, run all tests, and where logs/artifacts land.
Note anything surprising (ports, env vars, fixtures, slow first runs).

## Where things go (fill)

The decision table a contributor needs: "new X goes in Y" for this project's layout —
modules, tests, docs (reference page per shipped component: see
`reference/README.md`), assets. Cite AGENTS.md invariants that constrain placement.

## Debugging & gotchas (fill, grows over time)

The mistakes a reasonable person will make here, with fixes. Promote hard-won
incidents from LESSONS.md when they become permanent advice.

## Pointers

- Rules: ../AGENTS.md · Status: STATUS.md · Process: 00-START-HERE.md
- Specs: core/ · Reference (SDK tier): reference/ · Ops: workflow/
