# Game track — Unreal Engine, modular & performance-first

Goal: every Oasis game starts as a **thin game project + reusable plugins**, so new
games are content/art work on a stable frame, not engine plumbing.

## The shape

```
MyGame/
├── MyGame.uproject
├── Source/MyGame/            # THIN. Game target + module wiring only. No gameplay logic.
├── Plugins/
│   ├── OasisCore/            # shared LLC-wide plugin (grows across games, rule of two)
│   │   └── Source/
│   │       ├── OasisCore/        # foundation: types, utils, save, settings
│   │       └── OasisUI/          # shared UI framework (CommonUI-based)
│   ├── GameFeatures/         # GameFeature plugins — one per gameplay system/content pack
│   │   ├── GF_Combat/
│   │   ├── GF_Inventory/
│   │   └── GF_<System>/      # each independently loadable/unloadable
│   └── <GameName>Core/       # game-specific code that isn't a feature
├── Content/                  # game-specific art/content only
└── docs/                     # OGDK session chain, same as app projects
```

This is the Lyra-style modular pattern: ship-tested by Epic, designed exactly for
"many games on one foundation."

## Module rules (the invariants — put these in every game's AGENTS.md)

1. **Dependencies point one way:** Game → GameFeatures → OasisCore → Engine.
   OasisCore never references a game or a feature. A GameFeature never references
   another GameFeature directly (communicate via interfaces/events/GameplayTags).
2. **Source/<Game> stays thin** — target rules and module registration only. If you're
   writing gameplay in it, it belongs in a plugin.
3. **C++ for systems, Blueprint at the edges.** Core loops, managers, and anything
   per-frame in C++; BP for content glue, tuning, one-off scripting. Every BP-exposed
   system gets a C++ base class.
4. **Data-driven everything.** Tuning in DataAssets/DataTables, identity via
   GameplayTags — never hardcoded names or magic numbers in code.
5. **Soft references for content.** Hard references from code/core assets to heavy
   content are forbidden — they drag the asset graph into memory. Use
   TSoftObjectPtr + async load.
6. **No unnecessary Tick.** Default every actor/component to Tick disabled; use
   timers, delegates, and events. Per-frame work must justify itself in a comment.
7. **Networking decided day one** — single-player, listen, or dedicated. Replication
   strategy is architecture, not a retrofit.
8. **Engine boundary documented.** Tuning data is authored in engine-neutral sources
   and imported (never authored only inside binary assets), and every game
   component's reference page carries an **Engine surface** section listing exactly
   which engine APIs it touches — those sections collectively ARE the future port
   checklist. Full policy: [conventions/engine-portability.md](./conventions/engine-portability.md).

See [conventions/modules.md](./conventions/modules.md), [conventions/performance.md](./conventions/performance.md), [conventions/naming.md](./conventions/naming.md), [conventions/git-lfs.md](./conventions/git-lfs.md), [conventions/engine-portability.md](./conventions/engine-portability.md), [conventions/gas-and-ui.md](./conventions/gas-and-ui.md).

## Verification gate (game projects)

- All targets compile: Editor + Game (Development), Shipping at milestone boundaries
- Automation/functional tests green (each GameFeature ships with at least a smoke test)
- Perf budgets respected (conventions/performance.md) — checked with Unreal Insights
  on the milestone scene
- `git status` clean of `Binaries/`, `Intermediate/`, `DerivedDataCache/`, `Saved/`
  (template .gitignore in `templates/`)

## Version control

Git + **Git LFS** for `.uasset`/`.umap` and all binary content from day one.
One game = one repo. OasisCore lives in its own repo and is consumed as a git
submodule (or Perforce later if team/asset scale demands it — don't preempt).

## What OasisCore should accumulate (rule of two, same as app track)

Save/load framework · settings & input config · UI framework (CommonUI widgets,
menus, HUD scaffolding) · audio bus setup · loading/streaming helpers ·
debug console & cheats · platform abstraction. Each enters OasisCore only when a
second game needs it.
