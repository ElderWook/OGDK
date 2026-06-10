# Modules & plugins — how code is organized

## Decision tree: where does new code go?

```
Is it reusable across Oasis games?          → OasisCore plugin (rule of two: second game triggers extraction)
Is it a self-contained gameplay system?     → its own GameFeature plugin (GF_<System>)
Is it game-specific but not a feature?      → <GameName>Core plugin
Is it target/module wiring?                 → Source/<Game> (the ONLY thing allowed there)
```

## GameFeature plugins

- One plugin per system: combat, inventory, dialogue, quests, a DLC content pack.
- Each must be **independently loadable**: enabling/disabling it in the editor must not
  break compile or other features.
- Cross-feature communication: GameplayTags, gameplay events/messages, or interfaces
  defined in OasisCore — never a direct module dependency on another GF_*.
- Each feature owns its content: `Plugins/GameFeatures/GF_Combat/Content/…`, not the
  game's `Content/` folder.
- Each ships with a smoke test (automation spec or functional test map).

## Module hygiene

- Public headers expose the minimum; everything else in `Private/`.
- IWYU: include what you use; forward-declare in headers wherever possible.
  This is what keeps full-rebuild times sane as the codebase grows.
- `*.Build.cs` dependency lists are reviewed in PR — adding a module dependency is an
  architectural decision, not a convenience.
- Subsystems (GameInstance/World/LocalPlayer subsystems) over singleton actors for
  managers — lifecycle handled by engine, no level-placement fragility.

## Blueprint/C++ boundary

- C++ base class (`UCLASS(Blueprintable)`) defines data + behavior contract;
  BP subclass binds assets and tunes values.
- BP graphs deeper than ~20 nodes or called per-frame → move to C++.
- No BP-to-BP casting across features (creates hidden hard references) — go through
  an interface or tag-based lookup.
