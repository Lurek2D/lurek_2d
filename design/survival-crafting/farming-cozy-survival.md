# Farming Cozy Survival

**Category:** Survival crafting  
**Reference games:** Stardew Valley, Moonlighter as loop reference, Graveyard Keeper, Spiritfarer  
**Document type:** Technical game design and architecture

## Design target

A gentler survival/crafting game where farming, gathering, decorating, light crafting, relationships, and seasonal goals drive play. The challenge is pacing and routine rather than constant threat.

## Market positioning

Use the reference set (Stardew Valley, Moonlighter as loop reference, Graveyard Keeper, Spiritfarer) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with a small biome, clear resource pressure, and a memorable crafting hook. Target Steam with persistence, progression gates, world generation or authored zones, difficulty options, and enough content to sustain multi-hour survival arcs. For farming cozy survival, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Farm/town maps | `lurek.tilemap`, `lurek.scene`, `lurek.camera` |
| Crops/items/crafting | `lurek.ecs`, Lureksome crafting/inventory/economy libraries |
| Calendar/weather | `lurek.time`, `lurek.signal`, `lurek.save` |
| NPCs | `lurek.dialog`, `lurek.ai`, `lurek.pathfind` |
| Cozy feedback | `lurek.audio`, `lurek.particle`, `lurek.tween`, `lurek.ui` |

## Runtime architecture

The calendar is the primary simulation driver. Each day resolves crop growth, shop inventory, NPC schedule changes, relationship events, mail, weather, and crafting timers. Moment-to-moment gameplay uses simple action intents: till, water, plant, harvest, chop, mine, talk, gift, craft, decorate.

Farm plots are durable tile facts. Crops store species, planted day, growth stage, watered state, fertilizer, quality, and harvest count. Decorations and buildings are placed entities with grid footprint, collision, visual variant, and save ID.

NPC schedules should be data-driven and condition-aware. Relationship state controls dialogue pools and events, but current position can be reconstructed from date/time when loading.

## Suggested project structure

```text
my_cozy_survival/
  data/crops.toml
  data/recipes.toml
  data/npcs.toml
  data/calendar.toml
  data/decorations.toml
  scripts/state/calendar.lua
  scripts/systems/farm_tiles.lua
  scripts/systems/crafting_timers.lua
  scripts/systems/npc_schedules.lua
  scripts/systems/relationships.lua
  scripts/ui/toolbelt.lua
```

## Data and content model

- Author biomes, resources, recipes, stations, enemies, weather, needs, and world objects as data, not hidden script constants.
- Author player inventory, base state, discovered recipes, day/night schedule, and danger escalation as data, not hidden script constants.
- Author save chunks, event history, crafting queues, audio ambience, and difficulty settings as data, not hidden script constants.
- Keep farming cozy survival content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use `lurek.tilefield` for terrain, collision, resource nodes, light blockers, and path costs.
- Use `lurek.ecs` for player, creatures, projectiles, dropped items, stations, and world objects.
- Use `lurek.audio`, `lurek.light`, `lurek.particle`, and `lurek.camera` to make day/night, danger, crafting, and combat legible.
- Use `lurek.save` for world chunks, player inventory, base state, recipes, time, and event history.

## Vertical slice acceptance

One vertical slice should support one farm map, one town map, two crops, one crafting station, three NPCs, gift reaction, day-end save, shop purchase, and seasonal day rollover.

## Risks

The risk is routine without feedback. Every daily action should produce clear audio, animation, UI confirmation, and long-term progression so repetition feels intentional.
