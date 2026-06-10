# New project checklist

Run `.\tools\new-project.ps1 -Name "X" -Type App|Game` first, then:

## Both tracks
- [ ] Fill in `AGENTS.md`: architecture rules, invariants, verification gate
      (start from the track's STACK.md invariant set; delete what doesn't apply, add domain rules)
- [ ] `docs/STATUS.md`: set version, write first "Next up"
- [ ] Create GitHub repo (private), push
- [ ] First plan in `docs/plans/` before first feature code
- [ ] Verify the session chain works: open a fresh AI session, point it at
      `docs/00-START-HERE.md`, confirm it summarizes state correctly

## App track
- [ ] Scaffold per `docs/core/app-architecture.md`: `src/shared/` + platform apps + `$platform` bridges
- [ ] Wire test runner; add the first parity/unit test before the first sync/data feature
- [ ] Decide data authority model (which node owns which records) — write it into AGENTS.md

## Game track
- [ ] Create .uproject; keep `Source/<Game>` thin per `docs/core/game-architecture.md`
- [ ] `git lfs install` done by scaffolder — verify `.gitattributes` is active before the
      first .uasset commit (a binary committed without LFS is permanent repo weight)
- [ ] Add OasisCore as submodule (or create it on first extraction — rule of two)
- [ ] Enable GameFeatures; create first `GF_` plugin with a smoke test
- [ ] Set perf budgets in AGENTS.md (per platform/target fps); create the milestone scene
- [ ] Decide networking model day one; record in AGENTS.md
