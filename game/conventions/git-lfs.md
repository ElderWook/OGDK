# Git LFS — setup and daily use

LFS stores binary content (.uasset, .umap, textures, audio) outside normal git
history; the repo holds small pointer files. Without it, every edit to a binary
bloats the repo forever — **and a binary committed without LFS is permanent weight
even after you start tracking.** Hence: LFS before the first .uasset, always.

## One-time per machine

```powershell
git lfs version          # Git for Windows usually bundles it; if missing: winget install GitHub.GitLFS
git lfs install          # installs the global hooks — once per machine
```
Arch: `sudo pacman -S git-lfs && git lfs install`

## Per repo — already done by the OGDK scaffolder

`.gitattributes` defines what LFS tracks (uasset/umap/fbx/png/wav/…). Rules:
- `.gitattributes` must be committed **before** any file matching its patterns.
- Track new binary types with `git lfs track "*.ext"` (which edits .gitattributes —
  commit that change first).

## Daily use

Nothing changes. `git add` / `commit` / `push` as normal — the hooks intercept
tracked patterns automatically. Clones and pulls fetch LFS content transparently.

## Verify it's working (do this after your first .uasset commit)

```bash
git lfs ls-files     # must list every binary you just committed
git lfs track        # shows active patterns
```
If a binary you committed is NOT in `ls-files`, it went in as a normal git object —
fix immediately, before pushing:
```bash
git lfs migrate import --include="*.uasset,*.umap" --everything
```
(rewrites history; trivial pre-push, painful after others have pulled).

## Hosting quotas

GitHub LFS has storage/bandwidth quotas on free plans (historically ~1 GB each;
check current limits — they change). A solo UE project eats that fast. Options:
buy data packs, host LFS elsewhere, or self-host. Decide when the repo approaches
the quota, not after pushes start failing.

## Gotchas

- **Locking:** binary files can't merge. For solo dev this doesn't bite; the moment a
  second dev joins, enable file locking (`git lfs lock`) for .uasset/.umap, or move
  to Perforce. Don't preempt — just know the trigger.
- CI/build machines need `git lfs install` too, or they check out pointer files and
  the build fails with corrupt-asset errors.
