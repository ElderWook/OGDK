# Naming & content conventions

Follow Epic's standard prefixes so every dev and every AI agent can read the project
cold. Enforce with a linter (e.g. an editor validator or CI check) once content volume grows.

## Assets (prefix_Name_Suffix)

| Type | Prefix | Example |
|------|--------|---------|
| Blueprint (actor) | `BP_` | `BP_DoorSliding` |
| Blueprint (component) | `BPC_` | `BPC_HealthRegen` |
| Widget | `WBP_` | `WBP_MainMenu` |
| Static / Skeletal mesh | `SM_` / `SK_` | `SM_RockLarge_01` |
| Material / Instance / Function | `M_` / `MI_` / `MF_` | `MI_RockMossy` |
| Texture | `T_` + suffix `_D/_N/_ORM` | `T_RockLarge_N` |
| Data asset / table | `DA_` / `DT_` | `DA_WeaponRifle` |
| Sound cue / wave / class | `SC_` / `SW_` | |
| Niagara system | `NS_` | |
| Level | `L_` | `L_Oasis_Hub` |
| Animation BP / montage / sequence | `ABP_` / `AM_` / `AS_` | |

## C++

- Modules: `Oasis<Domain>` (OasisCore, OasisUI) or `GF_<System>` runtime module names.
- Classes: standard UE prefixes (`A` actor, `U` object, `F` struct, `E` enum, `I` interface),
  then `Oasis` for core code: `UOasisSaveSubsystem`, `FOasisItemRow`.
- GameplayTags: dot hierarchy, lowercase after root — `Oasis.Damage.Fire`,
  `GF.Inventory.Slot.Weapon`. Tags are registered in INI/DataTable, never ad-hoc strings.

## Folders

- Feature content lives in its plugin. Game `Content/` is organized by type within
  domain: `Content/<Domain>/{Meshes,Materials,Textures,Audio,…}`.
- No spaces, no special characters, no `NewFolder1`. `Developers/<name>/` for personal
  scratch — never referenced by shipping content.
