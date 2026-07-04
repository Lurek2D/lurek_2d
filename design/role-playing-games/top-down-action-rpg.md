# Top-Down Action RPG

**Category:** Role-playing games  
**Reference games:** Diablo, Secret of Mana, Ys, Bastion  
**Document type:** Technical game design and architecture

## Design target

A top-down real-time RPG with zones, enemies, loot, stats, skills, quests, NPCs, and persistent character progression. The architecture should keep combat, loot, and progression data-driven.

## Market positioning

Use the reference set (Diablo, Secret of Mana, Ys, Bastion) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with a focused slice of combat, progression, and narrative tone. Target Steam with durable save data, readable stats, quest/state tooling, content pipelines, and enough authored encounters to support a commercial RPG loop. For top-down action rpg, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Zones and dungeons | `lurek.tilemap`, `lurek.scene`, `lurek.camera` |
| Characters and items | `lurek.ecs`, Lureksome inventory/item/stats libraries |
| Combat | `lurek.physics`, `lurek.animation`, `lurek.particle`, `lurek.audio` |
| Enemy AI | `lurek.ai`, `lurek.pathfind` |
| Quests and dialogue | `lurek.dialog`, `lurek.signal`, Lureksome quest library |
| Saves | `lurek.save` with character, world, inventory, quest sections |

## Runtime architecture

Use a persistent character profile and zone-local runtime state. Character profile stores level, stats, skills, equipment, inventory, quest flags, and discovered waypoints. Zone state stores enemies, destructibles, local events, loot drops, and transition triggers.

Skills should be data-driven actions with cost, cooldown, target shape, hit policy, animation, and effect list. Loot should be generated from item definitions, rarity tables, affix pools, and level ranges. Keep item instances serializable and stable.

Enemy AI can use behavior trees with clear phases: idle, patrol, aggro, pursue, attack, retreat, special, dead. Pathfinding should be budgeted for groups and cached when possible.

## Suggested project structure

```text
my_action_rpg/
  data/zones/*.ldtk
  data/items.toml
  data/skills.toml
  data/enemies.toml
  data/quests.toml
  scripts/state/character.lua
  scripts/systems/combat.lua
  scripts/systems/loot.lua
  scripts/systems/skills.lua
  scripts/ai/enemy_brains.lua
  scripts/ui/inventory.lua
```

## Data and content model

- Author actors, classes, abilities, items, quests, factions, dialogue, and encounter tables as data, not hidden script constants.
- Author party state, inventory, quest flags, reputation, combat logs, and save migrations as data, not hidden script constants.
- Author world regions, shops, loot rules, progression curves, and localization keys as data, not hidden script constants.
- Keep top-down action rpg content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use `lurek.scene` to isolate exploration, combat, dialogue, inventory, shops, and menu-heavy flows.
- Use `lurek.dialog`, `lurek.ui`, and `lurek.save` as first-class RPG systems, not as presentation afterthoughts.
- Use `lurek.dataframe` for large tables such as items, abilities, enemies, shops, and progression curves.
- Use `lurek.ecs` for actors and world objects when many systems need shared identity and component data.

## Vertical slice acceptance

One slice should include town, dungeon zone, two skills, five item drops, two enemies, one boss, quest start/complete, inventory equipment, level-up, and save/load.

## Risks

The risk is stat formula opacity. Centralize formulas, show derived stats in UI, and log combat events with source, target, modifiers, and final result.
