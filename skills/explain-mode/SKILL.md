---
name: explain-mode
description: Teach while you build — narrate the architecture in plain language as you generate or change code, turning the kit's annotation standard into a running lesson for a learner. Use when the operator is new to programming, says "explain mode", "teach me as you go", "I'm learning", or asks why the code is shaped the way it is.
---

# Explain mode — the agent as tutor

The kit's whole premise for a newcomer is that a first project should *teach* how
software is built. The annotation standard (`@intent / @flow / @boundary / @invariant /
@risk`) and the conventions (pure core, effectful shell, one-way dependencies, a test
per module) already ARE that curriculum. This skill surfaces it as teaching instead of
leaving it as silent metadata. Turn it on when the operator is learning; turn it off
(or go terse) once they ask you to.

## The rule

Whenever you create or meaningfully change a module, **say in plain language, before or
just after the code:**

1. **What this is** — the module's job in one sentence a non-programmer understands.
   ("`store` is the only part allowed to touch the saved file — so a crash can never
   leave half-written data.")
2. **Why it lives here** — which architectural rule put it in this folder. Tie it to the
   universal idea, not just this project: pure core vs. effectful shell; the one-way
   dependency rule (everything points toward `core`, never away); one composition root.
3. **Why it's shaped this way** — name the convention you're honoring and the failure it
   prevents. ("Money is whole cents, never a decimal, so rounding can't quietly lose a
   penny." "This has its own test because untested code can't be trusted to still work
   after the next change.")

Keep each explanation to 1-3 sentences. You're leaving a trail of *why*, not writing a
textbook. Prefer a concrete consequence ("...so X can never happen") over abstract terms.

## How to pace it

- **First time a concept appears, explain it. After that, name it and move on.** The
  goal is recognition, not repetition — by the third module the learner should be
  predicting where things go.
- Tie each new file to one of the kit's words: *core, store, sync, bridge, render, jobs,
  identity, adapters, api, app*. Use the same vocabulary every time so it sticks.
- At each green checkpoint, offer a one-line "what just happened and why it's safe to
  save" (this is also where `gate` fits — explain that GATE PASSED means the project is
  healthy).
- Invite questions, then keep momentum. Building is the lesson; don't stall it.

## What NOT to do

- Don't lecture before the learner has context — explain a thing *as you build it*, when
  it's concrete, not in a wall of theory up front.
- Don't let the narration block shipping. If the operator says "just build it", drop to
  terse mode and leave the annotations in the code to carry the why.
- Don't invent rationale. If a choice is a free preference (a library, a name), say so —
  honesty about what's *law* vs. what's *taste* is part of the lesson.

## The payoff

When the project runs, the operator should be able to point at any file and say what it
does and why it's there. That is the "zoom out and understand how programming works"
moment the kit is built to deliver. Close a learning-heavy project by running the
`project-retro` skill — it gathers these threads into one explicit recap.
