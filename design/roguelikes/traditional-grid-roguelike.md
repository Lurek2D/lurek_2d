# Traditional Grid Roguelike

**Category:** Roguelikes  
**Reference games:** Rogue, NetHack, Brogue, Caves of Qud  
**Document type:** Technical game design and architecture

## Design target

A turn-based, grid-based dungeon game with procedural levels, item identification, monsters, field-of-view, permadeath or ironman saves, and high systemic interaction. The player and monsters act in discrete turns.

## Market positioning

Use the reference set (Rogue, NetHack, Brogue, Caves of Qud) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with a short run loop, strong item identity, and readable failure feedback. Target Steam with meta progression, seeded runs, daily/challenge modes, balance telemetry, and enough encounter variety for replay-focused players. For traditional grid roguelike, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Dungeon generation | `lurek.procgen`, `lurek.tilemap`, `lurek.tilefield` |
| Entities and inventory | `lurek.ecs`, Lureksome inventory/item libraries |
| Monster AI | `lurek.ai`, `lurek.pathfind`, `lurek.awareness` |
| UI log and panels | `lurek.ui`, `lurek.render`, `lurek.terminal` |
| Saves and seeds | `lurek.save`, `lurek.serialize`, `lurek.filesystem` |

## Runtime architecture

The authoritative clock is an action scheduler. Player input creates one action. Monsters then consume energy or initiative until the scheduler returns to the player. Rendering and animation are cosmetic; no gameplay should happen outside the action transaction.

Dungeon generation should output terrain, rooms, corridors, stairs, tags, spawn tables, and feature hooks. Field-of-view stores visible, explored, and remembered tile state. Monster perception reads visibility and sound events rather than global omniscience unless the design explicitly allows it.

Items should be data records with identity, stack rules, use action, equipment slot, rarity, curse/identify state, and serialization key. Combat and magic produce event records for the message log.

## Suggested project structure

```text
my_roguelike/
  data/items.toml
  data/monsters.toml
  data/generation.toml
  scripts/state/run_state.lua
  scripts/systems/action_scheduler.lua
  scripts/systems/fov.lua
  scripts/systems/combat.lua
  scripts/systems/items.lua
  scripts/ai/monster_ai.lua
  scripts/ui/message_log.lua
```

## Data and content model

- Author run seed, map chunks, rooms, enemies, loot tables, events, and encounter budgets as data, not hidden script constants.
- Author player build, inventory, status effects, cooldowns, meta unlocks, and death history as data, not hidden script constants.
- Author difficulty curves, procedural constraints, challenge modifiers, and balance telemetry as data, not hidden script constants.
- Keep traditional grid roguelike content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use `lurek.math.newRandomGenerator` or explicit deterministic seed ownership, and store seeds in save data and run reports.
- Use `lurek.ecs` when actors, items, effects, and projectiles share update/render/component needs.
- Use `lurek.pathfind`, `lurek.ai`, and `lurek.tilefield` to keep navigation and monster decisions inspectable.
- Use `lurek.save` for meta progression and optional run suspend, not for hiding non-deterministic state.

## Vertical slice acceptance

The slice should include generated dungeon floor, player movement, FOV, three monsters, five items, melee combat, stairs, death screen, message log, and seed-stable restart.

## Risks

The risk is accidental real-time leakage. Keep every rule behind action resolution and verify that the same seed plus action list produces the same outcome.
