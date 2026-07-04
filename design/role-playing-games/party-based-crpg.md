# Party-Based CRPG

**Category:** Role-playing games  
**Reference games:** Baldur's Gate as structural reference, Ultima VII, Fallout 1/2, Planescape: Torment  
**Document type:** Technical game design and architecture

## Design target

A 2D party RPG with exploration maps, dialogue choices, quests, inventory, party members, tactical or paused combat, and branching consequences. The core is stateful narrative plus systemic character rules.

## Market positioning

Use the reference set (Baldur's Gate as structural reference, Ultima VII, Fallout 1/2, Planescape: Torment) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with a focused slice of combat, progression, and narrative tone. Target Steam with durable save data, readable stats, quest/state tooling, content pipelines, and enough authored encounters to support a commercial RPG loop. For party-based crpg, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Exploration maps | `lurek.tilemap`, `lurek.camera`, `lurek.scene` |
| Party and NPCs | `lurek.ecs`, `lurek.pathfind`, `lurek.ai` |
| Dialogue and quests | `lurek.dialog`, `lurek.signal`, Lureksome quest/dialog libraries |
| Inventory/stats | Lureksome inventory/item/stats libraries, `lurek.serialize` |
| UI-heavy screens | `lurek.ui`, `lurek.render`, `lurek.i18n` |
| Persistence | `lurek.save` for world flags, party, quests, maps |

## Runtime architecture

Separate world state, area state, party state, and conversation state. World state owns flags and long-term consequences. Area state owns current map, NPC positions, doors, containers, and local triggers. Party state owns members, inventory, formation, reputation, and combat resources.

Dialogue should be data-driven with conditions, effects, skill checks, speaker metadata, and localization keys. Dialogue effects emit commands: set flag, start quest, add item, change faction, move NPC, open shop, or start combat.

Combat can be turn-based or real-time-with-pause, but should reuse character stats, abilities, inventory, and AI intent. Do not duplicate combat-only versions of actors unless the translation boundary is explicit.

## Suggested project structure

```text
my_crpg/
  data/areas/*.ldtk
  data/dialogue/*.toml
  data/quests.toml
  data/items.toml
  data/characters.toml
  scripts/state/world_flags.lua
  scripts/state/party.lua
  scripts/systems/dialogue_effects.lua
  scripts/systems/quest_log.lua
  scripts/systems/combat_mode.lua
  scripts/ui/character_sheet.lua
```

## Data and content model

- Author actors, classes, abilities, items, quests, factions, dialogue, and encounter tables as data, not hidden script constants.
- Author party state, inventory, quest flags, reputation, combat logs, and save migrations as data, not hidden script constants.
- Author world regions, shops, loot rules, progression curves, and localization keys as data, not hidden script constants.
- Keep party-based crpg content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use `lurek.scene` to isolate exploration, combat, dialogue, inventory, shops, and menu-heavy flows.
- Use `lurek.dialog`, `lurek.ui`, and `lurek.save` as first-class RPG systems, not as presentation afterthoughts.
- Use `lurek.dataframe` for large tables such as items, abilities, enemies, shops, and progression curves.
- Use `lurek.ecs` for actors and world objects when many systems need shared identity and component data.

## Vertical slice acceptance

The slice should include one town area, one dungeon room, two companions, branching dialogue, one quest with two outcomes, inventory equip flow, one combat encounter, and consequence saved across reload.

## Risks

The largest risk is narrative flag sprawl. Use named flags, event logs, and validation that every dialogue condition references an existing state key.
