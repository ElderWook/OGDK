# OGDK Stack Audit — 2026-06-13

Static audit of the `tools/` stack and the hostile-environment smoke test, run as the
"microscope" pass that accompanied closing the commit-author-identity lesson.

## Method & caveat

This is a **static** review: the agent's Linux sandbox failed to start this session, so
**nothing here was executed by the agent**. Every mechanical claim below is either read
from source or marked as *needs a run*. The operator runs `gate.ps1` and
`test-hostile-env.ps1` on the native machine to confirm (see the checklist at the end).
The kit's own gate (`check-kit-docs` + `verify-file-integrity`) already passed earlier
this session, so twin-rule, ASCII/here-string hygiene, EOF sentinels, link resolution,
and `git fsck` were green as of HEAD `9e92b08`.

## 1. Author-identity guard (delivered this session)

The lesson was marked CODIFIED on 2026-06-12, but that codification was **interim**: a
soft `[WARN]` in `verify-path-health` when `git config user.email` lacks `noreply`. Two
holes remained, and the second is the one that actually caused the leak:

1. A non-noreply email only warned — a novice prepping a public repo could sail past it.
2. **Nothing scanned history.** `verify-path-health` reads *today's config*; the original
   leak was five commit *objects* carrying a personal email, found only by auditing a
   fresh clone's `git log`. Author/committer metadata rides in every commit and is
   invisible to every content scan in the kit.

**Fix shipped:** `tools/check-git-identity.{ps1,sh}` — a twin that scans author + committer
name/email across `git log --all` against the gitignored `tools/PRIVATE-MARKERS.list`
(the same per-owner marker infrastructure `check-kit-docs` check 8 uses for file
content), FAILs on any match, and is chained into `gate.{ps1,sh}` as a third stage.
Output reports marker index only — never the marker text — so a failing run stays
shareable. It skips gracefully (exit 0) when git or the markers list is absent, so fresh
clones and non-owner contributors are never blocked by a check they can't run.

**Residual gaps (by design or deferred):**

- **Honor-system, like the rest of the gate.** Nothing *mechanically* stops an ungated
  push. The kit consciously declined a pre-*commit* hook (it would block fast `wip:`
  checkpoint commits — see LESSONS 2026-06-11). Identity leak is different: it only
  matters at **push** time, so a **pre-*push* hook** calling `check-git-identity` would
  close the loop *without* the speed problem that got hooks declined. This is the single
  highest-value follow-up (see §4).
- **Kit-only.** Scaffolded projects don't inherit the guard. Public-bound *projects* have
  the same exposure. Follow-up: add to `gate.template.{ps1,sh}` + `PROPAGATE.list`.
- **Commit messages are still unscanned.** The guard covers identity fields, not the
  commit *message* body — which also travels in history and can carry a codename. No kit
  check reads commit messages today. Low frequency, but it's the same class of leak.

## 2. Hostile-env smoke test — coverage microscope

Current assertions in `test-hostile-env.{ps1,sh}`:

| # | Asserts | Verdict |
|---|---------|---------|
| 1 | `verify-path-health` FAILs when git identity unset | good — a true negative test |
| 2 | `verify-path-health` PASSes once identity set | good |
| 3 | kit `gate` passes inside a spaces-in-path dir | good |
| 4 | `new-project` scaffolds into a spaces-in-path dir | good |
| 5 | scaffolded project's `gate` passes | good |
| 6 | (**new**) `check-git-identity` FAILs on a leaked author, PASSes when clean | good — both directions |

The pattern is sound: cases 1 and 6 are *negative* tests (assert a guard fires). But the
coverage stops at the two oldest tools plus the new one. The gaps, ranked by risk:

- **`sync-repo` classifier has zero coverage.** This is the newest and most logic-dense
  tool (committed 2026-06-12) — the entire multi-machine safety net (behind / ahead /
  diverged / dirty / merge-in-progress, ff-only auto). None of its branches are tested.
  A regression here silently reintroduces the exact novice-merge-conflict the kit exists
  to prevent. **Highest-value test to add.**
- **`checkpoint` (panic save) is untested.** It stages + `wip:` commits + pushes with a
  failed-push-still-succeeds contract. A bug here strikes at the worst moment (session
  dying). At minimum: assert a dirty tree becomes a single `wip:` commit and exit 0.
- **Integrity checker has no negative test.** Tests 3/5 prove `gate` passes on a *clean*
  repo, but nothing asserts `verify-file-integrity` *catches* a planted defect — a NUL
  byte, a truncated `.py`, a script missing its EOF sentinel. A guard you never watch
  fail is a guard you don't know works. Add a "plant corruption → expect FAIL" case.
- **`check-kit-docs` has no negative test.** Same logic: plant a private marker in a
  scratch tracked file, or drop a twin, and assert the checker FAILs.
- **CRLF list-parser regression untested.** `.gitattributes` correctly pins
  `*.list text eol=lf` (the 2026-06-11 lesson), but nothing *asserts* the `.sh` list
  parsers strip `\r`. If the attribute is ever lost, only a live Windows checkout would
  catch it. A cheap test: feed a CRLF `*.list` to `new-project.sh`'s parser path.
- **No cleanup-on-failure.** Both twins `rm -rf` the sandbox only on the success path. If
  an assertion aborts mid-run (`set -euo pipefail` / a PS throw), the `sandbox hostile
  spaces dir` and the mock `GIT_CONFIG_GLOBAL` pointer leak into the next run. Add a
  `trap`/`finally` cleanup.

## 3. Stack-level observations

- The dual-OS hazard model (`tools/README.md`) and the LESSONS buffer are unusually
  rigorous — most findings here are *coverage* gaps (missing tests), not *defects*. The
  rules exist; the mechanical proof that they hold lags them, which is precisely the
  pattern the kit's own 2026-06-11 "rules-as-prose-faster-than-checks" lesson named.
- The gate chain is now three stages (kit-docs → integrity → identity). Keep the
  ordering is fine, but if a pre-push hook is added, point it at `check-git-identity`
  specifically, not the whole gate, to keep pushes fast.

## 4. Recommendations (prioritized)

1. **Pre-push hook → `check-git-identity`.** Closes the identity loop mechanically
   without touching checkpoint speed (pre-push, not pre-commit). Re-opens a narrow,
   well-scoped version of the previously-declined hook question — worth a LESSONS note
   either way.
2. **`sync-repo` classifier smoke tests.** Highest-risk untested logic in the stack.
3. **Propagate `check-git-identity` to projects** (`gate.template` + `PROPAGATE.list`).
4. **Negative tests for `verify-file-integrity` and `check-kit-docs`** (plant-defect →
   expect FAIL).
5. **`checkpoint` smoke test** + **`trap`-based cleanup** in the hostile-env harness.

Items 2–5 are naturally ROADMAP.md entries; item 1 deserves a LESSONS decision record so
it's never silently re-litigated (mirroring the 2026-06-11 pre-commit-hook entry).

## 5. Operator verification checklist

Run on the native Windows machine, in order:

```powershell
cd C:\OGDK
.\tools\gate.ps1            # now includes "=== GATE: git identity ===" - expect GATE PASSED
```

If the identity stage FAILs, that is **not** a false alarm — it found a commit whose
author/committer metadata matches one of your private markers (a residual leak the
earlier rebase missed). It prints the offending short hashes (marker text withheld);
inspect with `git show <hash> --format=fuller -s`, then rewrite history before any push.

```powershell
git add tools\check-git-identity.ps1 tools\check-git-identity.sh `
        tools\gate.ps1 tools\gate.sh tools\README.md user-notes.md `
        LESSONS.md tools\test-hostile-env.ps1 tools\test-hostile-env.sh
git commit -m "feat(tools): check-git-identity history-scan guard - close author-identity lesson"
.\tools\test-hostile-env.ps1   # run AFTER commit - the sandbox clones tracked files only
```

The smoke test must run *after* the commit: its sandbox is a fresh `git clone`, which
only carries committed files, so the new guard has to be in history for case 6 to find
it. (The `STACK-AUDIT-*.md` report itself is a session artifact — keep it untracked or
commit it separately; it's deliberately not part of the guard commit.)
