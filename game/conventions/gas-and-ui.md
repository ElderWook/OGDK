# GAS + UI conventions (game track)

> Conventions for Gameplay Ability System usage and UI loading in UE-based game
> projects. Pairs with [engine-portability.md](./engine-portability.md) (design ports,
> code doesn't) and [performance.md](./performance.md).
> Distilled from external study (tranek/GASDocumentation, filliperomero/InterfaceHero,
> Hazelight AngelScript) — 2026-06-14.

## Gameplay Ability System (GAS)

- **ASC ownership = two topologies, decided per actor type:**
  - **Hero** (player-controlled, must survive respawn): put the AbilitySystemComponent
    on the **PlayerState**; initialize via `PossessedBy` (server) and
    `OnRep_PlayerState` (client). Attributes persist across pawn death.
  - **Minion** (transient NPCs/props): ASC on the **Actor** itself — simpler, dies with
    the actor.
  Choosing the wrong one is the usual cause of "attributes reset on respawn."
- **AttributeSet boilerplate is scaffolded, not hand-written:** use the standard
  `ATTRIBUTE_ACCESSORS` macro and the `DOREPLIFETIME_CONDITION_NOTIFY` + `OnRep_`
  pattern in every replicated AttributeSet. Bake it into the scaffold so new attributes
  are a one-liner, not a copy-paste hazard.

## UI loading (CommonUI)

- Load widgets through **soft references** (`TSoftClassPtr`) + async streamable loads,
  not hard class refs — hard refs force synchronous loads and frame hitches at open.
- Use the **activatable widget stack** for menus/HUD layering and input routing.

## Declined (recorded so it isn't re-litigated)

- **A text-scripting layer** (AngelScript / Lua) for gameplay — **declined for now.**
  C++ for systems + Blueprint at the edges is sufficient; a scripting runtime adds
  build/debug surface a small team doesn't need. Revisit only if BP/C++ iteration
  friction is *demonstrated*, not assumed.
