---
name: project-retro
description: The learner's capstone — at the end of a first project or a milestone, generate a plain-language recap that maps what the person actually built onto the universal concepts of software, so the insight becomes explicit. Use when a project reaches a runnable milestone, the operator is a learner, or someone asks to "wrap up what I learned", "do a project retro", or "what did I just build".
---

# Project retro — make the lesson explicit

`explain-mode` teaches concept-by-concept while building. This skill is the capstone: it
zooms out at the end and connects what the operator built to how software is built in
general. The goal is the payoff the kit promises a newcomer — finishing a first project
and genuinely understanding the shape of programming, not just having a working app.

Run this at a real, runnable milestone (the gate passes, the thing does something), not
mid-build. Keep it to one screen. Warm, concrete, specific to THEIR project.

## 1. Gather (read, don't guess)

- Skim the project's `src/` modules and their annotated headers (`@intent / @boundary`).
- Read `docs/STATUS.md` (what shipped) and any archived plan in `docs/plans/`.
- Note which kit modules exist here: *core, store, sync, bridge, render, jobs, identity,
  adapters, api, app* — each present one is a concept the operator has now used for real.

## 2. Write the recap

Produce a short note (offer to save it as `docs/WHAT-I-LEARNED.md`) with these parts:

- **What you built** — one honest paragraph in their own domain terms.
- **The ideas you used without realizing it** — map each to a file they can open. Cover
  the ones that apply:
  - *Separating thinking from doing* — pure `core` logic vs. effectful shell (`store`,
    `adapters`). Point at the exact files.
  - *One-way dependencies* — everything points toward `core`; nothing points back. Why
    that keeps a project from turning into spaghetti.
  - *Durable, honest data* — atomic writes, exact math where it matters.
  - *Tests as a safety net* — why each module has one, and what it buys when you change
    things later.
  - *Small, checkable saves* — commits + the gate; how "GATE PASSED" is your proof.
- **What you'd reach for next time** — the presets/modules they didn't use yet and when
  each becomes the right call (sync for multi-device, api for serving others, etc.).
- **One thing that bit you** — if a snag came up, name it and the fix. (If it was real
  friction the kit should have prevented, capture it with `report-snag` so it graduates
  into a permanent improvement.)

## 3. Hand off the momentum

End by pointing forward, concretely: the next feature to add, or the next shape to try
(`app/APP-ARCHITECT.md` presets). The retro should leave the operator feeling that they
now *get it* — and that the second project will be faster because the concepts are theirs
now, not the kit's.

## Boundaries

- Describe and teach; do not refactor during a retro. Improvements go through a plan.
- Praise honestly and point at evidence in their code. Don't inflate — a learner can
  tell, and accuracy is what makes the insight trustworthy.
