# LESSONS — the learning loop's capture buffer (OGDK kit-level)

> **Working tier — OPEN process-friction only.** Append-only. Every session that hits
> **friction the system didn't prevent** logs it here before ending (session-end skill,
> step 4). Entries are raw material for the `kit-retro` skill, which converts them into
> permanent upgrades (skills, AGENTS rules, gate scripts, reference docs), marks them
> CODIFIED, and periodically moves the codified ones to `LESSONS-ARCHIVE.md` so this
> buffer stays short and the OPEN count stays meaningful (`check-reference-coverage`
> WARNs at 5 OPEN).
>
> **This is NOT a study log.** Study findings go to the target repo's `docs/LESSONS.md`
> (with a `Source-License:` line); study license/provenance is the generated
> `study-repo/STUDY-INDEX.md` manifest. See `docs-template/workflow/SCALING.md`.
>
> **Cold storage:** codified process lessons + the 2026-06-14 study-sweep records →
> [`LESSONS-ARCHIVE.md`](./LESSONS-ARCHIVE.md).

Format: see docs-template/LESSONS.md.

---

_Buffer reset 2026-06-15: codified lessons + the 2026-06-14 study-sweep records migrated to
`LESSONS-ARCHIVE.md`; study provenance is the generated `study-repo/STUDY-INDEX.md`._

## 2026-06-15 The codified grep -c "two-zeros" bug recurred in a brand-new tool
**What happened:** `fleet-work.sh` (new this session) reintroduced the exact `grep -c ... || echo 0` two-zeros idiom already **CODIFIED 2026-06-11** (which fixed check-kit-docs.sh + check-reference-coverage.sh). It stayed invisible until OGDK's OPEN count hit **0** for the first time — right after this LESSONS-ARCHIVE migration — at which point `grep -c` printed `0` AND exited 1, the `|| echo 0` appended a second `0`, and `total=$((total + o))` died with "arithmetic syntax error". The `.ps1` twin was immune (`@(Select-String).Count` yields a clean 0), so the twins silently diverged in robustness.
**Root cause:** the 2026-06-11 fix patched the two scripts that *had* the bug but added no GUARD against the pattern reappearing; a new author re-typed the idiom from muscle memory. `check-kit-docs` has no lint for it, and the zero-count path is rarely exercised, so it escaped first-run testing of a brand-new tool.
**Proposed fix:** `open_count()` rewritten to yield a single integer (done, verified at 0 OPEN). Systemic candidate: a `check-kit-docs` lint that flags `grep -c` piped to `|| echo`/`|| true` in `tools/*.sh` (or a shared `count_matches` helper both twins call), so the codified lesson is mechanically enforced rather than discipline-only — the recurring "rule existed as prose faster than a check existed as a script" pattern.
**Status:** OPEN (bug fixed; the preventive lint is the kit-retro candidate).
