# Top-Down Survival Crafting

**Category:** Survival crafting  
**Reference games:** Don't Starve, Project Zomboid as systems reference, Terraria as 2D survival reference, Core Keeper  
**Document type:** Technical game design and architecture

## Design target

A top-down 2D survival game where the player gathers resources, crafts tools, manages hunger/temperature/health, explores biomes, builds shelter, and survives hostile events. Lurek2D is a strong fit when the simulation is local, tile or region based, and not MMO-scale.

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

## Vertical slice acceptance

The slice should include generated biome area, gatherable resources, hunger and health, tool crafting, campfire placement, day/night, one hostile creature, inventory UI, death/restart, and save/load.

## Risks

The risk is infinite-world ambition. Build a small persistent chunk model first and validate save size, chunk regeneration, and authored progression before expanding world scale.
