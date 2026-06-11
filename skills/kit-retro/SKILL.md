---
name: kit-retro
description: Run the OGDK learning loop — harvest LESSONS.md entries from all Oasis projects, propose concrete upgrades to skills, AGENTS rules, gate scripts, and reference docs, apply approved changes to the kit, and mark lessons codified. Use at project milestones, after a rough session, or when asked to "run a retro", "harvest lessons", or "make the kit learn".
---

# Kit retro — the active-learning loop

The kit improves the same way it works: evidence first, then codification, then a
gate. This skill is the codification step. Time-box it (~30 min); the anti-goals in
ROADMAP.md apply — one commit of improvements, not a remodeling spree.

## 1. Harvest

Read `docs/LESSONS.md` in every project repo (OGDK's own, plus all projects listed in
user-notes.md §2). Collect every entry with **Status: OPEN**. Also skim each
project's STATUS.md "Open hazards" for items that have stopped being news and started
being patterns.

## 2. Classify each open lesson

| Pattern | Codify as |
|---------|-----------|
| A model needed knowledge it didn't have | edit the relevant SKILL.md or AGENTS template |
| A manual check was forgotten or done late | extend a gate/checker script (twin rule applies) |
| A rule existed but was violated anyway | make it mechanical (script) or move it earlier in the chain |
| A component was misused | fix its reference page (Gotchas section) |
| Same friction in 2+ projects | kit-level fix (template/skill); 1 project only → project-level fix |
| Hardware/env quirk on the user's machines | user-notes.md §11 hard-won hazards |

## 3. Propose, then apply

Present the user a short list: lesson → exact file → one-line description of the
edit. **Wait for approval — skills and rules steer every future session; they are
never self-modified silently.** Apply approved edits:
- Kit files: edit in OGDK, then propagate to project copies (.claude/skills, tools/)
  per the propagation rules in AI-PARITY.md §4 (file tools / whole-file writes only).
- Run the kit gate (`tools/gate.ps1|.sh`) — check-kit-docs will catch doc drift.

## 4. Close the loop

- Mark each handled entry `**Status:** CODIFIED <date>, <where>` in its LESSONS.md.
- One commit per repo: `chore(retro): codify lessons — <topics>`.
- If a lesson was rejected ("cost > benefit"), mark it
  `**Status:** CODIFIED <date>, declined — <reason>` so it is never re-litigated.

## Cadence

Milestone retros are the floor, not the ceiling: any session may run this skill when
LESSONS entries accumulate. If a project's LESSONS.md has 5+ OPEN entries, the
session-start summary should mention it.
