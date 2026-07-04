# Base Defense Survival

**Category:** Survival crafting  
**Reference games:** They Are Billions as design reference, Kingdom: Two Crowns, Mindustry, Dungeon Defenders as structure reference  
**Document type:** Technical game design and architecture

## Design target

A 2D survival defense game where the player gathers resources, builds defenses, upgrades production, and withstands escalating waves. The architecture should support clear wave pressure and base-layout readability.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Buildable map | `lurek.tilemap`, `lurek.tilefield`, `lurek.camera` |
| Structures and enemies | `lurek.ecs`, `lurek.physics`, `lurek.animation` |
| Enemy routing | `lurek.pathfind`, influence maps, flow fields |
| Wave director | `lurek.ai` director, `lurek.time`, `lurek.signal` |
| Feedback/UI | `lurek.ui`, `lurek.render`, `lurek.audio`, `lurek.particle` |
| Persistence | `lurek.save` for base, wave, resources, upgrades |

## Runtime architecture

Base defense needs two clocks: preparation and attack. During preparation, the player places structures, repairs, upgrades, and assigns workers. During attack, waves spawn and the base simulation resolves targeting, damage, path blockers, wall breach, and reward payout.

Structures have footprint, health, build cost, power or upkeep, attack profile, repair policy, and path-blocking tags. Enemies have spawn group, route target, movement type, armor, attack, priority target, and wave budget value.

Pathfinding should be recalculated when buildable blockers change, not every frame. If the design allows maze-building, validate that enemies always have at least one legal route or define explicit breach behavior.

## Suggested project structure

```text
my_base_defense/
  data/structures.toml
  data/enemies.toml
  data/waves.toml
  data/maps/*.ldtk
  scripts/state/base.lua
  scripts/systems/build_mode.lua
  scripts/systems/wave_director.lua
  scripts/systems/towers.lua
  scripts/systems/repair.lua
  scripts/ai/wave_ai.lua
  scripts/ui/build_panel.lua
```

## Vertical slice acceptance

The slice should include one map, two resource types, three structures, three enemy types, five waves, repair, upgrade, route preview, defeat condition, and save/load between waves.

## Risks

The risk is path exploit ambiguity. Decide early whether maze-building is a feature. The path system and UI must explain blocked routes, breach choices, and enemy priorities.
