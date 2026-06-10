# Performance — budgets and workflow

Performance is a feature built in from day one, not an optimization pass.

## Budgets (set per project at kickoff; defaults below for 60 fps target)

| Budget | Default | Notes |
|--------|---------|-------|
| Frame time | 16.6 ms (60 fps) | set per project/platform; mobile may target 33.3 ms |
| Game thread | ≤ 8 ms | gameplay, AI, BP |
| Render thread + GPU | within frame budget on min-spec device | |
| Per-feature tick cost | ~0 — features are event-driven | any steady tick cost is justified in writing |
| Load time (cold boot → interactive) | set at kickoff | streaming budget per level |
| Memory | min-spec platform ceiling minus 20% headroom | |

Budgets live in the game's AGENTS.md once set. The verification gate checks them on a
designated **milestone scene** — a representative worst-case level kept current.

## Workflow

- **Measure first**: Unreal Insights traces on the milestone scene; `stat unit`,
  `stat game`, `stat gpu` for quick reads; `memreport -full` for memory.
- Profile on **min-spec hardware**, not the dev machine.
- Every plan in `docs/plans/` for a gameplay system includes a perf note: expected
  steady-state cost and worst case.

## Standing rules

- Tick disabled by default everywhere (actors, components). Timers/events instead.
- Async/soft loading for anything heavy; no synchronous loads in gameplay code.
- Object pooling for anything spawned in bursts (projectiles, VFX actors, pickups).
- Significance/distance culling for ticking systems that must tick (LOD the logic, not
  just the mesh).
- Watch the **asset reference graph** (Reference Viewer) — hard-reference chains are
  the #1 cause of memory/load-time blowouts. Audit at every milestone.
- Shader/PSO precaching configured before first external build goes out (hitches are
  reputation damage you can't patch back).
