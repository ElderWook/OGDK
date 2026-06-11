# user-notes.md — core-maintainer's quick reference

> **For AI models:** this is the user's personal crib sheet. Use it to answer "what
> was that command" questions directly instead of re-deriving from the codebase.
> It is NOT the rules file — AGENTS.md and the session chain still govern work.
> If you add/change/remove a script or a build command anywhere in the stack, update
> this file in the same session — `check-kit-docs` catches missing script rows
> mechanically; build commands are on the honor system, so be the honor.
> **For me:** skim the section header, copy the command, move on.

---

## 1. The pipeline (every dev session)

```
START:  .\tools\verify-path-health.ps1        # must say ALL CHECKS PASSED
        read: AGENTS.md → docs\STATUS.md → active plan
WORK:   plans before code · docs change in the same commit as code
END:    .\tools\gate.ps1                      # THE GATE — exit 0 or no commit
        update docs\STATUS.md  →  git add -A → commit → push
```

Golden rule: **if it isn't in the repo, the next session doesn't know it.**

## 2. My repos & locations

| Repo | Path | What |
|------|------|------|
| OGDK | `C:\OGDK` | the kit — process, templates, scaffolder |
| DevSandbox | `C:\DevSandbox` | game proving ground (DevKitRTX UE fork, module `DevKitRTX_57`) |
| DevKitGhost | `C:\DevKitGhost` | DevKitPanel — circuit-mapping hardware (PRIVATE until PPA) |
| the origin app | `C:\the origin app_Release` | bookkeeping app (Tauri+Svelte), app-track origin |

New project: `C:\OGDK\tools\new-project.ps1 -Name "X" -Type App|Game`
(Linux: `./tools/new-project.sh -n X -t App|Game`)

## 3. Git — daily driver

```powershell
git status                    # ALWAYS first and after every command. Red=unstaged, green=staged
git add -A                    # stage everything (undoable: git restore --staged <file>)
git commit -m "type: message" # save point. types I use: feat / fix / docs / chore / refactor
git log --oneline             # history, newest on top
git push                      # upload to GitHub (after remote setup: git push -u origin main once)
git pull                      # download newest (start of session on the OTHER machine/OS)
git diff                      # what exactly changed (q to quit the pager)
git diff --staged             # what's about to be committed
```

Reading status: "working tree clean" = nothing to do · "not staged" = edits exist,
not queued · "to be committed" = queued · "untracked" = new files git never saw.

**If a model dies mid-task (usage limit):** its job was to leave a `wip:` commit +
`## In-flight` note in STATUS.md. Next session: the session-start skill detects this
and recovers. My only move: don't panic, don't clean anything — start a fresh session
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
git remote add origin https://github.com/<me>/<repo>.git
git push -u origin main        # -u links the branch; afterwards plain `git push` works
git remote -v                  # show what's connected
git remote set-url origin <url>  # fix a wrong bookmark
```

Dual-boot rule: Windows and Arch each keep their OWN clone on native filesystem;
they sync **only** through GitHub (push on one, pull on the other). Never cross-mount.

## 7. Scripts (tools\ in every project — .ps1 Windows / .sh Linux twins)

| Script | What |
|--------|------|
| `gate.ps1/.sh` | **THE GATE — the only pre-commit command I need to remember.** Chains integrity + coverage + that repo's tests/builds. Exit 0 = commit. (gate.template.* = scaffolder source) |
| `verify-path-health.ps1/.sh` | session-start env gate (MSYS2 poison / NTFS mount / identity / LFS) |
| `verify-file-integrity.ps1/.sh` | pre-commit corruption gate (NUL-fill, truncation, git fsck) — run after heavy AI writes |
| `check-reference-coverage.ps1/.sh` | docs gate: every component tracked to a reference page; flags STALE/MISSING |
| `check-kit-docs.ps1/.sh` | (OGDK only) keeps THIS file honest: twin rule + every script documented here and in tools/README; flags ghost refs |
| `launch-claude-clean.ps1/.sh` | health gate, then launch Claude Code |
| `new-project.ps1/.sh` | (OGDK only) scaffold App/Game project |

Linux: `chmod +x tools/*.sh` once after fresh clone if scripts won't run.

## 8. Build & run commands

**Game (DevSandbox / UE):**
- Regenerate VS files: right-click `DevKitRTX_57.uproject` → *Generate Visual Studio project files*
- Build: VS Solution Explorer → Games folder → right-click `DevKitRTX_57` → Build
  (config **Development Editor | Win64**; avoid Build Solution — can rebuild the engine)
- Smoke test: launch editor → Output Log → filter `OasisCore` → "OasisCore module up"
- Quick perf reads in editor console: `stat unit` · `stat game` · `stat gpu` · `memreport -full`
- Deep profiling: Unreal Insights (record on the milestone scene)

**App (the origin app pattern):**
```powershell
npm install                                # once per clone (root, then each sub-app)
node the origin app-relay/server.js              # relay :5180  (or start-relay.bat)
npm run dev                                # desktop :5173
npm run dev --prefix the origin app-mobile       # mobile :5174
npm test                                   # full suite — must be green before commit
npm run build ; npm run build --prefix the origin app-mobile
```

**DevKitGhost (Python phase):**
```powershell
python -m unittest discover tests          # unit tests
python simulations\sim_detection.py        # Monte Carlo (writes results md)
```

**The gate wraps all of these:** `.\tools\gate.ps1` in any repo runs that repo's
checks + tests/builds in one shot.

## 9. UE project layout rules (30-second refresher)

- `Source\DevKitRTX_57` stays THIN — gameplay code goes in `Plugins\`
- One GameFeature plugin per system (`GF_Combat` …); features talk via tags/interfaces, never directly
- Shared-across-games code → OasisCore plugin (only when a 2nd game needs it — rule of two)
- Tick off by default · soft references for heavy assets · tuning in DataAssets, not code
- Asset names: `BP_` `WBP_` `SM_` `M_`/`MI_` `T_..._D/_N` `DA_` `L_` (full table: docs\core\conventions\naming.md)

## 10. Where answers live (instead of re-explaining the codebase)

| Question | Read |
|----------|------|
| what are the rules here? | `AGENTS.md` (repo root) |
| what's in flight right now? | `docs\STATUS.md` |
| why was X designed this way? | `docs\plans\` (incl. rejected options) |
| how do I USE a shipped component? | `docs\reference\` (SDK tier; COVERAGE.md = index of everything) |
| how do the modules/perf/naming work? | `docs\core\conventions\` |
| how does multi-model work stay sane? | `docs\workflow\AI-PARITY.md` |
| LFS details | `docs\core\conventions\git-lfs.md` |
| kit roadmap / what's left | `C:\OGDK\ROADMAP.md` |

## 11. Hard-won hazards (do not relearn these the fun way)

- Never launch AI agents from MSYS2 / Git Bash / WSL on Windows → silent NTFS file corruption
- Never let agents run `git` OR shell-write files through a synced mount (Cowork) —
  stale offsets corrupt real files; git truth = my local PowerShell; agents use file
  tools only
- Never work on the shared NTFS partition from Arch — separate clones, sync via GitHub
- Binary committed without LFS = permanent repo weight — `git check-attr filter` before new types
- `.ps1` scripts: ASCII only, no here-strings (PS 5.1 + LF endings = parse bombs)
