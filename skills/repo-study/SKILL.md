---
name: repo-study
description: Study an external repository and metabolize its best practices into the OGDK learning loop — comparative analysis of docs, process, CI, tooling, and conventions against the kit, producing LESSONS.md entries and adoption proposals. Use when asked to "study a repo", "compare our stack against X", "learn from this codebase", or "run student mode".
---

# Repo study — the learning loop's input valve ("Student mode")

The kit normally learns from its own friction. This skill lets it learn from other
people's excellence: pick a respected external repository, compare its practices
against the kit's, and convert the deltas into LESSONS entries and adoption
proposals. **Ideas and patterns flow in; foreign code does not.**

## Ground rules (non-negotiable)

1. **Study workspace is OUTSIDE all kit-governed repos** — e.g. `C:\Dev\study\<name>`
   (Linux: `~/dev/study/<name>`). Never clone external repos inside OGDK or any
   project repo: no nested git, no gate scanning foreign files, no license
   contamination of Oasis IP.
2. **Read-only.** The external clone is never modified, never committed anywhere,
   and can be deleted after the study.
3. **License discipline:** learning patterns, structures, and ideas is always fine.
   COPYING code or substantial text requires license compatibility + attribution and
   is almost never the goal — when tempted to copy, write the kit's own version of
   the idea instead. Note the studied repo's license in the findings.
4. The kit's own rules still apply to YOU during the study (no git through mounts,
   file tools for writes, etc.).

## Protocol

1. **Frame the question first.** "Study X" is too vague; pick 1-3 lenses, e.g.:
   onboarding quality, CI/gate design, docs architecture, contributor experience,
   release process, testing strategy, repo layout, agent/automation conventions.
   Best subjects: repos famous for the lens (not necessarily famous repos).
2. **Clone to the study workspace** (user runs the clone, or agent fetches via
   normal read paths). Skim breadth-first: README → contributing docs → CI config →
   directory layout → a few representative source files. Depth only where the lens
   points.
3. **Comparative table — the core artifact.** For each lens:
   | Their practice | Kit equivalent | Delta | Verdict |
   Verdicts: **ADOPT** (clear win, propose codification) · **ADAPT** (good idea,
   needs kit-shaped rework) · **DECLINE** (doesn't fit — record WHY so it's never
   re-litigated) · **CONFIRMS** (kit already does this as well or better — also
   worth recording; calibration is learning too).
4. **Output, in the kit's own currency:**
   - One LESSONS.md entry per ADOPT/ADAPT finding (source repo named in the entry)
   - DECLINEs logged in the same entries as "declined — <reason>"
   - Big ADOPTs (new scripts, structural changes) get a `docs/plans/` plan instead
     of direct edits — study findings are evidence, not authority
5. **Codify via the normal loop:** kit-retro (or this same session, if small)
   turns entries into rules/scripts/skills WITH USER APPROVAL — study findings
   never self-apply, exactly like every other lesson.
6. **Clean up:** delete the study clone or keep it in the study workspace; either
   way it never enters a kit repo.

## Cadence & scope guard

One repo per study session; 1-3 lenses; time-boxed like a retro (~30-60 min).
The anti-goals apply double here — studying great repos is the most seductive form
of kit-polishing-as-procrastination ever invented. After a study, the next session
ships product.
