# Top-Down Survival Crafting

**Category:** Survival crafting  
**Reference games:** Don't Starve, Project Zomboid as systems reference, Terraria as 2D survival reference, Core Keeper  
**Document type:** Technical game design and architecture

## Design target

A top-down 2D survival game where the player gathers resources, crafts tools, manages hunger/temperature/health, explores biomes, builds shelter, and survives hostile events. Lurek2D is a strong fit when the simulation is local, tile or region based, and not MMO-scale.

## Market positioning

Use the reference set (Don't Starve, Project Zomboid as systems reference, Terraria as 2D survival reference, Core Keeper) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with a small biome, clear resource pressure, and a memorable crafting hook. Target Steam with persistence, progression gates, world generation or authored zones, difficulty options, and enough content to sustain multi-hour survival arcs. For top-down survival crafting, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| World map and biomes | `lurek.tilemap`, `lurek.tilefield`, `lurek.procgen` |
| Player/items/entities | `lurek.ecs`, Lureksome inventory/item/crafting libraries |
| Wildlife/enemies | `lurek.ai`, `lurek.pathfind`, `lurek.awareness` |
| Environment systems | `lurek.time`, `lurek.light`, `lurek.audio`, `lurek.particle` |
| UI and persistence | `lurek.ui`, `lurek.save`, `lurek.serialize` |

## Runtime architecture

Use a world state with seed, discovered chunks, biome map, resources, placed structures, player vitals, inventory, day/night clock, weather, and event pressure. Chunks can be generated on demand but must serialize stable resource depletion and player-built changes.

Crafting should be a recipe resolver, not a UI-only feature. Recipes define inputs, output, station requirement, skill requirement, time, durability, and unlock condition. Inventory items need stack rules, durability, spoilage, tags, and use actions.

AI should react to environment and player stimuli: hunger, fear, aggression, shelter, sound, light, fire, and group behavior. Avoid full ecological simulation at first; use spawn directors and local rules.

## Suggested project structure

```text
my_survival/
  data/biomes.toml
  data/items.toml
  data/recipes.toml
  data/creatures.toml
  scripts/state/world.lua
  scripts/systems/chunks.lua
  scripts/systems/vitals.lua
  scripts/systems/crafting.lua
  scripts/systems/building.lua
  scripts/ai/creatures.lua
  scripts/ui/inventory.lua
```

## Data and content model

- Author biomes, resources, recipes, stations, enemies, weather, needs, and world objects as data, not hidden script constants.
- Author player inventory, base state, discovered recipes, day/night schedule, and danger escalation as data, not hidden script constants.
- Author save chunks, event history, crafting queues, audio ambience, and difficulty settings as data, not hidden script constants.
- Keep top-down survival crafting content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use `lurek.tilefield` for terrain, collision, resource nodes, light blockers, and path costs.
- Use `lurek.ecs` for player, creatures, projectiles, dropped items, stations, and world objects.
- Use `lurek.audio`, `lurek.light`, `lurek.particle`, and `lurek.camera` to make day/night, danger, crafting, and combat legible.
- Use `lurek.save` for world chunks, player inventory, base state, recipes, time, and event history.

## Vertical slice acceptance

The slice should include generated biome area, gatherable resources, hunger and health, tool crafting, campfire placement, day/night, one hostile creature, inventory UI, death/restart, and save/load.

## Risks

The risk is infinite-world ambition. Build a small persistent chunk model first and validate save size, chunk regeneration, and authored progression before expanding world scale.
