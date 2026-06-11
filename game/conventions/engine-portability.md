# Engine portability — what ports, what doesn't, and how to keep the ratio high

**The honest framing first:** engine code does not port. UE C++ against UE APIs will
never compile in Godot or Unity, and pretending otherwise produces abstraction
layers that cost more than a rewrite. A future engine port is a **guided
re-implementation** — and the goal of these conventions is to make the guide so
complete, and the portable share so large, that the re-implementation is mechanical
rather than archaeological.

## 1. The three layers (know which one you're writing)

| Layer | Ports? | Examples | Rule |
|-------|--------|----------|------|
| **Design** | 100% | GDDs, plans, mechanics specs, balance values, the GF_ decomposition itself | already engine-neutral by GDD discipline — mechanics are specified in design terms ("escalation triggers when..."), never engine terms ("the GAS effect applies...") |
| **Data** | ~100% | tuning tables, item/stat definitions, tag taxonomies, dialogue, level metrics | keep authoring sources engine-neutral (§2) |
| **Code** | ~0% as text, ~80% as *shape* | modules, systems, gameplay logic | the architecture pattern IS the portable artifact (§3) |

## 2. Data rule: engine-neutral sources, engine-native imports

Tuning and definition data is AUTHORED in engine-neutral formats (CSV/JSON tables
in the repo) and IMPORTED into engine assets (DataTables/DataAssets) — never
authored exclusively inside the engine's binary assets.

- The neutral source is the truth; the engine asset is a build artifact of it.
- Tag taxonomies (`Oasis.Damage.Fire`) are strings in a neutral registry first,
  engine GameplayTags second — a tag taxonomy ports to any engine for free.
- Cost check: this is nearly free at authoring time and priceless at port time
  (and it also makes data diffs reviewable in PRs TODAY — the convention pays
  before any port exists).
- Exception: pure-presentation assets (meshes, materials, animation) are
  engine/DCC-pipeline territory; their SOURCE files (.blend, trim sheets,
  Substance) already live outside the engine and port wherever.

## 3. Code rule: the shape is the asset

The kit's architecture pattern is engine-agnostic even though its implementation
is not: one-way dependencies (Game → Features → Core → Engine), one feature = one
module, data-driven tuning, tag-based identity, event/interface communication,
no-tick-by-default. Godot (autoloads + signals + scenes-as-features) and Unity
(asmdefs + ScriptableObjects + events) both express this shape natively.

Therefore: porting = re-implementing each feature module's CONTRACT in the new
engine's idiom. The contract must be written down — which is §4.

## 4. The engine-surface section (reference pages = the port checklist)

Every game component's reference page (`docs/reference/`) includes an
**Engine surface** section listing exactly which engine APIs the component
touches: subsystem types, framework classes, engine plugins, editor-only
machinery. Rules:

- Small surface = cheap port; the section makes the cost VISIBLE at review time —
  an engine-surface section that grows without cause fails review like a perf
  regression.
- Everything NOT in the engine surface must be expressible as plain logic + data
  (and is therefore portable as design).
- At port time, the collected Engine-surface sections of all components ARE the
  work order: re-implement these contracts, import the neutral data, follow the
  GDD. No archaeology.

## 5. What we deliberately do NOT do

- **No engine-abstraction wrapper layer.** Writing a "portable engine interface"
  over UE costs every feature every day to maybe save a port that may never
  happen. Declined on the same grounds as the pre-commit hook — recorded here so
  it stays declined. (If a port becomes CONCRETE, an interface layer can be a
  port-phase tactic; it is never a day-one architecture.)
- **No lowest-common-denominator features.** Use the engine fully (vendor lighting
  branches, GAS, GameFeatures) — the portability budget is spent on data discipline and
  surface documentation, not on avoiding engine strengths.

## 6. Checklist (per feature, enforced at graduation)

- [ ] Mechanics specified engine-neutrally in the GDD/plan (design layer clean)
- [ ] Tuning/definitions authored in neutral sources, imported to assets (§2)
- [ ] Reference page has an Engine surface section, reviewed for size (§4)
- [ ] Cross-feature communication via tags/interfaces only (already the law)
