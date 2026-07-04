# Top-Down Adventure

**Category:** Action adventure  
**Reference games:** The Legend of Zelda: A Link to the Past, Hyper Light Drifter, CrossCode, Anodyne  
**Document type:** Technical game design and architecture

## Design target

A room-and-overworld 2D adventure with exploration, combat, items, puzzles, NPCs, secrets, and progression gates. The architecture should support handcrafted content and predictable player-state transitions.

## Market positioning

Use the reference set (The Legend of Zelda: A Link to the Past, Hyper Light Drifter, CrossCode, Anodyne) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with a compact exploration hook, readable screenshots, and a short demo that proves movement, discovery, and combat feel. Target Steam with durable progression, authored content density, controller support, achievements, and a polished save/resume loop. For top-down adventure, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Rooms and overworld | `lurek.tilemap`, `lurek.scene`, `lurek.camera` |
| Player/enemies/items | `lurek.ecs`, `lurek.animation`, `lurek.physics` |
| Combat and interactions | `lurek.input`, `lurek.signal`, `lurek.audio`, `lurek.particle` |
| Navigation and enemy AI | `lurek.pathfind`, `lurek.ai` |
| Dialogue and quests | `lurek.dialog`, `lurek.ui`, Lureksome quest/inventory libraries |
| Persistence | `lurek.save` for inventory, flags, map state, checkpoints |

## Runtime architecture

Treat each room as a content unit with tile layers, collision data, spawn points, interactables, exits, puzzle flags, and music. A world-state service owns global flags such as item acquired, boss defeated, door opened, NPC moved, and shortcut unlocked.

The player controller should be separate from the player entity. Input maps to intents: move, attack, use item, interact, dash. Systems convert intents into movement, hitboxes, invulnerability, animation state, and sound. Enemies use small behavior trees or FSMs with clear telegraphs.

Progression gates should be data-driven. Doors, barriers, and secrets reference required flags or item capabilities. Save files store durable flags and current checkpoint, not every transient animation detail.

## Suggested project structure

```text
my_adventure/
  data/rooms/*.ldtk
  data/items.toml
  data/dialogue/*.toml
  scripts/state/world_flags.lua
  scripts/systems/player_controller.lua
  scripts/systems/interactions.lua
  scripts/systems/combat.lua
  scripts/systems/room_loader.lua
  scripts/ai/enemy_brains.lua
  scripts/ui/hud.lua
  assets/rooms/
  assets/characters/
```

## Data and content model

- Author world zones, doors, locks, traversal flags, encounter groups, interactables as data, not hidden script constants.
- Author actors, hitboxes, inventory items, quests, dialogue nodes, collectibles as data, not hidden script constants.
- Author camera volumes, checkpoints, music regions, and map annotation state as data, not hidden script constants.
- Keep top-down adventure content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use `lurek.scene` to separate title, world, pause, inventory, dialogue, and transition states.
- Keep collision facts in `lurek.tilefield` while `lurek.tilemap` owns visual tile layers.
- Use `lurek.input` action names for move, interact, attack, dodge, menu, and map so keyboard/gamepad bindings are data-driven.
- Use `lurek.save` for traversal flags, inventory, quest state, and checkpoint resume.

## Vertical slice acceptance

One slice should include three rooms, one weapon, one key item, two enemy types, one puzzle door, one NPC dialogue, one secret, room transition, HUD hearts/resources, and checkpoint save/load.

## Risks

The risk is blending room content with global state. Use authored room data for layout and spawn definitions, but keep durable progression in a separate world-state service.
