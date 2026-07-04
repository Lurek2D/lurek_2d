# Base Defense Survival

**Category:** Survival crafting  
**Reference games:** They Are Billions as design reference, Kingdom: Two Crowns, Mindustry, Dungeon Defenders as structure reference  
**Document type:** Technical game design and architecture

## Design target

A 2D survival defense game where the player gathers resources, builds defenses, upgrades production, and withstands escalating waves. The architecture should support clear wave pressure and base-layout readability.

## Market positioning

Use the reference set (They Are Billions as design reference, Kingdom: Two Crowns, Mindustry, Dungeon Defenders as structure reference) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with a small biome, clear resource pressure, and a memorable crafting hook. Target Steam with persistence, progression gates, world generation or authored zones, difficulty options, and enough content to sustain multi-hour survival arcs. For base defense survival, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

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

## Data and content model

- Author biomes, resources, recipes, stations, enemies, weather, needs, and world objects as data, not hidden script constants.
- Author player inventory, base state, discovered recipes, day/night schedule, and danger escalation as data, not hidden script constants.
- Author save chunks, event history, crafting queues, audio ambience, and difficulty settings as data, not hidden script constants.
- Keep base defense survival content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use `lurek.tilefield` for terrain, collision, resource nodes, light blockers, and path costs.
- Use `lurek.ecs` for player, creatures, projectiles, dropped items, stations, and world objects.
- Use `lurek.audio`, `lurek.light`, `lurek.particle`, and `lurek.camera` to make day/night, danger, crafting, and combat legible.
- Use `lurek.save` for world chunks, player inventory, base state, recipes, time, and event history.

## Vertical slice acceptance

The slice should include one map, two resource types, three structures, three enemy types, five waves, repair, upgrade, route preview, defeat condition, and save/load between waves.

## Risks

The risk is path exploit ambiguity. Decide early whether maze-building is a feature. The path system and UI must explain blocked routes, breach choices, and enemy priorities.
