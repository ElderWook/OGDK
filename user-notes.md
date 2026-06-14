# user-notes.md — operator's quick reference (generic)

> **For AI models:** this is the kit operator's shared crib sheet. Use it to answer
> "what was that command" questions directly instead of re-deriving from the codebase.
> It is NOT the rules file — AGENTS.md and the session chain still govern work.
> If you add/change/remove a script or a build command anywhere in the stack, update
> this file in the same session — `check-kit-docs` catches missing script rows
> mechanically; build commands are on the honor system, so be the honor.
>
> **Personal/machine/project specifics do NOT belong in this file.** Each operator
> has their own `user-notes.local.md` beside this one — auto-created by
> verify-path-health on first run, gitignored, never committed, never propagated.
> Repo maps, usernames, machine paths, private project commands: all go there.
> Models: route personal content to the .local file.

---

## 1. The pipeline (every dev session)

```
START:  git pull                              # another machine may have pushed
        .\tools\verify-path-health.ps1        # must say ALL CHECKS PASSED (Linux: .sh)
        read: AGENTS.md → docs\STATUS.md → active plan
        (AI session? open with: "run session-start" or
         "read AGENTS.md, then docs/00-START-HERE.md, follow the chain")
WORK:   plans before code · docs change in the same commit as code
END:    .\tools\gate.ps1                      # THE GATE — exit 0 or no commit
        update docs\STATUS.md  →  git add -A → commit → push
```

Golden rule: **if it isn't in the repo, the next session doesn't know it.**

## 2. Your repos & locations

Keep your personal repo map in `user-notes.local.md` (gitignored — see header).

New project: `.\tools\new-project.ps1 -Name "X" -Type App|Game`
(Linux: `./tools/new-project.sh -n X -t App|Game`)

## 3. Git — daily driver

```powershell
git status                    # ALWAYS first and after every command. Red=unstaged, green=staged
git add -A                    # stage everything (undoable: git restore --staged <file>)
git commit -m "type: message" # save point. types: feat / fix / docs / chore / refactor
git log --oneline             # history, newest on top
git push                      # upload to remote (after setup: git push -u origin main once)
git pull                      # download newest (start of session on another machine/OS)
git diff                      # what exactly changed (q to quit the pager)
git diff --staged             # what's about to be committed
```

Reading status: "working tree clean" = nothing to do · "not staged" = edits exist,
not queued · "to be committed" = queued · "untracked" = new files git never saw.

**If a model dies mid-task (usage limit):** its job was to leave a `wip:` commit +
`## In-flight` note in STATUS.md. Next session: the session-start skill detects this
and recovers. Your only move: don't panic, don't clean anything — start a fresh session
and point it at docs/00-START-HERE.md. A dirty tree + dead chat is recoverable;
deleted files are not.

## 4. Git — fixing poopsies (in increasing severity)

```powershell
git restore <file>            # throw away uncommitted edits to a file (gone forever — be sure)
git restore --staged <file>   # un-stage (keeps the edits, just unqueues)
git commit --amend -m "msg"   # fix the message/contents of the LAST commit (only if not pushed)
git revert <hash>             # undo a pushed commit safely (makes a new opposite commit)
git stash                     # shelve uncommitted work; git stash pop brings it back
git reflog                    # the "even commits I lost" log — almost anything is recoverable
```

**ASK-FIRST LIST** — never run without checking with a model/human:
`reset --hard` · `push --force` · `clean -fd` · `rebase` · `filter-branch` / `lfs migrate` on pushed history.

## 5. Git LFS (game repos)

Already wired by the scaffolder. The only things to remember:

```powershell
git lfs ls-files                       # which binaries are in LFS (run after first commit of new assets)
git check-attr filter <file>           # says "lfs" = will be stored correctly
git lfs track "*.newext"               # start tracking a NEW binary type — commit .gitattributes FIRST
git lfs migrate import --include="*.x" --everything   # rescue a binary committed without LFS (BEFORE pushing; ask first)
```

Machine setup (once per machine): `git lfs install` · Arch: `sudo pacman -S git-lfs && git lfs install`

## 6. Remotes / GitHub

One-time per repo (create empty private repo on github.com first — NO readme/license,
the repo must be empty):

```powershell
git remote add origin https://github.com/<you>/<repo>.git
git push -u origin main        # -u links the branch; afterwards plain `git push` works
git remote -v                  # show what's connected
git remote set-url origin <url>  # fix a wrong bookmark
```

Dual-boot rule: each OS keeps its OWN clone on a native filesystem; they sync
**only** through the remote (push on one, pull on the other). Never cross-mount.
Your SSH/GPG/auth specifics: `user-notes.local.md`.

## 7. Scripts (tools\ in every project — .ps1 Windows / .sh Linux twins)

| Script | What |
|--------|------|
| `bootstrap.ps1/.sh` | (OGDK only) one-command first-run setup: checks git + identity, runs path-health + the gate, arms hooks, prints your next command. Run once on a fresh clone before anything else |
| `gate.ps1/.sh` | **THE GATE — the only pre-commit command to remember.** Chains integrity + coverage + that repo's tests/builds. Exit 0 = commit. (gate.template.* = scaffolder source) |
| `verify-path-health.ps1/.sh` | session-start env gate (MSYS2 poison / NTFS mount / identity / LFS); prints tools/KIT-VERSION provenance in project repos |
| `sync-repo.ps1/.sh` | **safe arrival** — session start, after path-health: fetch + classify (ff-only auto; DIVERGED/dirty/merging = STOP with instructions; never auto-merges). Exit 0 = work, 2 = act first |
| `safe-agent-push.ps1/.sh` | **safe agent push** — automated, gate-verified git commit & push wrapper. Runs path-health + sync + gate; commits and pushes to origin if all checks pass. Aborts immediately on any error or divergence |
| `checkpoint.ps1/.sh` (+`checkpoint.bat` double-click) | **panic save** — stage + `wip:` commit + push, zero questions; failed push still = saved (local commit). Optional arg: what you were doing |
| `rescue.ps1/.sh` | **get back to safe** — checkpoint's opposite: cancels a half-finished merge/rebase, or shelves uncommitted changes (`git stash`, fully recoverable) so the tree returns to your last save. Never resets `--hard`/force-pushes. The "undo the mess" button |
| `verify-file-integrity.ps1/.sh` | pre-commit corruption gate (NUL-fill, truncation, .py compile, script-syntax parse, EOF sentinel on tools scripts, git fsck) — run after heavy AI writes |
| `check-git-identity.ps1/.sh` | pre-commit identity-leak gate: scans author+committer name/email across ALL history vs your gitignored `PRIVATE-MARKERS.list`, FAILs on a match (the leak content scans can't see — metadata rides in every commit). Marker-index output only; skips if git/list absent. Chained into gate |
| `test-hostile-env.ps1/.sh` | hostile-environment smoke test suite (simulates space-in-path, clean git config setup, and verifies health/gate/scaffolding) |
| `test-sync-repo.ps1/.sh` | smoke test for `sync-repo`: drives a throwaway bare remote through in-sync / behind-ff / ahead / dirty+behind / diverged / merge-in-progress, asserts each exit code (0 safe, 2 act). Run after touching `sync-repo` |
| `test-twin-parity.ps1/.sh` | (OGDK only) parity check for `.ps1`/`.sh` twins: parses every twin in BOTH languages, then runs safety-critical tools (`verify-file-integrity`, `check-git-identity`) through identical fixtures in BOTH shells and asserts their exit codes agree — catches silent behavioral drift the twin-rule *existence* check can't see. Needs pwsh+bash; skips what it can't run. Run after touching any twin |
| `install-hooks.ps1/.sh` | install this clone's git hooks (sets `core.hooksPath=tools/hooks`): arms **pre-commit** (private-marker scan + a cheap staged-file integrity gate — NUL bytes / EOF sentinel, panic-exempt via `OGDK_SKIP_INTEGRITY`) and **pre-push** (identity-history guard via `tools/hooks/pre-push`). Per-clone; undo: `git config --unset core.hooksPath` |
| `check-reference-coverage.ps1/.sh` | docs gate: every component tracked to a reference page; flags STALE/MISSING; nudges on OPEN lessons (kit-retro at 5) and stale STATUS.md handoff |
| `report-snag.ps1/.sh` | turn a snag into a ready-to-paste `LESSONS.md` entry: `report-snag "what broke"` prints a formatted draft + environment context to stdout (writes nothing). Makes capturing friction a 10-second job |
| `check-kit-docs.ps1/.sh` | (OGDK only) keeps THIS file honest: twin rule + every script documented here and in tools/README; flags ghost refs; check 8 scans tracked files for your private markers (gitignored `tools/PRIVATE-MARKERS.list` — seed yours; policy: BOUNDARY.md) |
| `launch-claude-clean.ps1/.sh` | health gate, then launch Claude Code |
| `new-project.ps1/.sh` | (OGDK only) scaffold App/Game project |
| `new-reference-page.ps1/.sh` | scaffold a reference page + its COVERAGE.md row in one shot: `-n slug -c "Title" -s "source/path"` from project root. Fill the page, commit with the component |
| `propagate-tools.ps1/.sh` | (OGDK only) update EXISTING project tools from the kit: `-Target <project-root>` or `-All` (your gitignored `tools/TARGETS.list`), `[-Skills]`. What travels: `tools/PROPAGATE.list`; stamps `tools/KIT-VERSION` in targets |
| `release-notes.ps1/.sh` | draft release notes from git log (latest tag → HEAD, or pass tags). Prints markdown — redirect to file, edit, ship |

Linux: `chmod +x tools/*.sh` once after fresh clone if scripts won't run.

## 8. Build & run commands

Per-project commands belong in YOUR `user-notes.local.md` (they name your projects
and machine layout). The universal pattern:

- **Game track (UE):** build via the IDE's per-project build (never whole-solution
  on a source engine); smoke-test via the project's documented log line; perf via
  `stat unit` / Insights on the milestone scene.
- **App track (Node):** `npm install` per package once, `npm test` before commit,
  `npm run build` per target.
- **Python projects:** `python -m unittest discover tests`.

**The gate wraps all of these:** `.\tools\gate.ps1` in any repo runs that repo's
checks + tests/builds in one shot — you rarely need the raw commands.

## 9. UE project layout rules (30-second refresher)

- `Source\<YourGame>` stays THIN — gameplay code goes in `Plugins\`
- One GameFeature plugin per system (`GF_<System>` …); features talk via tags/interfaces, never directly
- Shared-across-games code → the shared core plugin (only when a 2nd game needs it — rule of two)
- Tick off by default · soft references for heavy assets · tuning in DataAssets, not code
- Asset names: `BP_` `WBP_` `SM_` `M_`/`MI_` `T_..._D/_N` `DA_` `L_` (full table: docs\core\conventions\naming.md)

## 10. Where answers live (instead of re-explaining the codebase)

| Question | Read |
|----------|------|
| what are the rules here? | `AGENTS.md` (repo root) |
| what's in flight right now? | `docs\STATUS.md` |
| what has the system learned / what should it? | `docs\LESSONS.md` (capture) + kit-retro skill (codify) |
| why was X designed this way? | `docs\plans\` (incl. rejected options) |
| how do I USE a shipped component? | `docs\reference\` (SDK tier; COVERAGE.md = index of everything) |
| how do the modules/perf/naming work? | `docs\core\conventions\` |
| how does multi-model work stay sane? | `docs\workflow\AI-PARITY.md` |
| LFS details | `docs\core\conventions\git-lfs.md` |
| kit roadmap / what's left | the kit's `ROADMAP.md` |
| my personal repo map / machine setup | `user-notes.local.md` (gitignored) |

## 11. Hard-won hazards (do not relearn these the fun way)

- Never launch AI agents from MSYS2 / Git Bash / WSL on Windows → silent NTFS file corruption
- Never let agents run `git` OR shell-write files through a synced mount —
  stale offsets corrupt real files; git truth = your local shell; agents use file
  tools only
- Never work on a shared NTFS partition from Linux — separate clones, sync via the remote
- Binary committed without LFS = permanent repo weight — `git check-attr filter` before new types
- `.ps1` scripts: ASCII only, no here-strings (PS 5.1 + LF endings = parse bombs)

## 12. Recommended Developer/Agent Extensions (optional)

- **`opensrc` (Vercel Labs):** Gives AI agents deep implementation context of third-party libraries on-demand. Resolves packages (npm, PyPI, crates.io, GitHub repos) to their source repositories, shallow-clones the exact version tag, and caches them at `~/.opensrc/` for search (`rg`) and reading (`cat`).
  - Install: `npm install -g opensrc`
  - Agent query pattern: `rg "parse" $(opensrc path zod)` or `find $(opensrc path requests)`

