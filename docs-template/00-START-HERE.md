# 00 — START HERE (every session, every model, every dev)

Single entry point for any work session — human or AI, any model, any account.
Follow the chain in order. Do not skip steps.

## The chain

```
1. AGENTS.md (repo root)           ← non-negotiable rules: launch env, architecture, invariants, gates
2. docs/STATUS.md                  ← what is in flight RIGHT NOW + the active plan
3. The active plan (docs/plans/…)  ← the spec for the current iteration
4. Role guide, as needed:
     building/fixing  → docs/DEVELOPER-GUIDE.md (create once the codebase has shape)
     releasing        → docs/workflow/
     deep-dive        → docs/core/ · docs/presentation/ · docs/adapters/
```

Working across models/accounts? The parity contract is [workflow/AI-PARITY.md](./workflow/AI-PARITY.md) —
the short version: **if it isn't in the repo, the next session doesn't know it.**

## Session protocol

**Start of session**
1. Read `AGENTS.md` in full. On Windows, run `.\tools\verify-path-health.ps1` before any file writes.
2. Read `docs/STATUS.md` — it names the active plan and any open hazards.
3. Read the active plan before touching code it covers.

**During**
- Plans are written before implementation (`docs/plans/`); specs live in
  `docs/core|presentation|adapters`; operations in `docs/workflow`.
  Lifecycle: `DOCUMENTATION-VERSIONING-GUIDE.md`.
- Docs change in the SAME commit as the code they describe.

**End of session**
1. Run the verification gate (AGENTS.md).
2. Update `docs/STATUS.md` — what moved, what's next, new hazards. This is the handoff;
   if it's not in STATUS.md, the next agent doesn't know it.
3. Completed plans move to `docs/plans/archive/`; their content graduates into `core/`.

## Why this exists
Work rotates across models, accounts, and people. Context does not carry over — this
chain IS the context (~5 min to read). It prevents the two expensive failure modes:
violating an invariant (AGENTS.md) and colliding with in-flight work (STATUS.md).
