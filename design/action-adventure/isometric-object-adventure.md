# Isometric Object Adventure

**Category:** Action adventure  
**Reference games:** Little Big Adventure, Sanitarium, The Immortal, Disco Elysium presentation layer  
**Document type:** Technical game design and architecture

## Design target

A single-character isometric exploration adventure built around object-dense rooms, readable mouse or controller interaction, environmental puzzles, doors, props, NPCs, scene transitions, shadows, and clear hotspot feedback. This design focuses on scene authoring, interaction, and presentation rather than RPG progression, stats, loot, party systems, or tactical combat.

The core promise is that an authored isometric location behaves like an inspectable diorama. The player can move through the scene, understand what blocks movement or sight, see what is clickable, trigger object state changes, and navigate between rooms while the engine maintains stable rendering, picking, lighting, and save state.

## Market positioning

Use the reference set (Little Big Adventure, Sanitarium, The Immortal, Disco Elysium presentation layer) to define expectations around room readability, object interaction, scene mood, and strong authored composition, not to copy mechanics directly. Target itch.io with a polished room-and-puzzle slice that proves hover feedback, cutaways, and click movement. Target Steam with robust save/resume, controller/mouse input parity, localization-ready interaction text, debug-friendly authoring, and enough rooms to support a complete adventure loop.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Isometric rooms and props | `lurek.tilemap`, `LIsoMap`, `lurek.camera` |
| Room collision and visibility facts | `lurek.tilefield` with `iso_square`, movement/sight/action/light channels |
| Scene objects and hotspots | `lurek.ecs`, `lurek.scene`, `lurek.signal` |
| Cursor, hover, and selection flow | `lurek.input`, `lurek.ui`, `lurek.render` |
| Click-to-move and local navigation | `lurek.pathfind.newIsoGridFromField` |
| Trigger zones and interaction bounds | `lurek.physics` sensors, overlap checks, raycasts |
| Dialogue, inspect text, and prompts | `lurek.dialog`, `lurek.ui`, `lurek.i18n` |
| Atmosphere and shadows | `lurek.light`, `lurek.tilelight`, render shaders |
| Persistent room state | `lurek.save`, `lurek.serialize` |

## Runtime architecture

Treat each room or outdoor screen as an `IsoScene`. It owns the visual tile layers, gameplay tilefield, object registry, interaction index, local navigation grid, lighting setup, camera bounds, and transition exits. A higher-level world state owns durable flags such as puzzle solved, object collected, door unlocked, NPC moved, and cutscene played.

Objects should be data-driven. A `Door`, `Container`, `Hotspot`, `Exit`, `Trigger`, `Light`, `Occluder`, or `CameraRegion` class provides default behavior, but the Tiled object supplies stable ID, label key, anchor, footprint, interaction shape, script hook, and local properties. Object state changes should update the sprite, hover prompt, blockers, colliders, lights, and save data through one command path.

Picking priority should be explicit: modal UI first, then active cutscene overlays, then object hotspots by render-depth priority, then actors, then ground tile. Interaction bounds are not sprite bounds. A small prop can have a generous hover shape, while a tall wall can be visible but not clickable except through authored hotspots.

Scene presentation should support cutaway groups. When the player steps behind a roof or tall wall, the group can fade, hide, show an outline, or reveal interaction markers. The policy should be authored per room and inspectable through debug overlays.

## Suggested project structure

```text
my_iso_adventure/
  data/rooms/*.tmx
  data/tiled_classes.toml
  data/interactions.toml
  data/dialogue/*.toml
  data/puzzles.toml
  scripts/state/world_flags.lua
  scripts/systems/iso_scene_loader.lua
  scripts/systems/interaction_router.lua
  scripts/systems/cutaway_controller.lua
  scripts/systems/puzzle_state.lua
  scripts/systems/click_movement.lua
  scripts/ui/hover_prompt.lua
  scripts/ui/inventory_bar.lua
  assets/tilesets/
  assets/props/
  assets/characters/
```

## Data and content model

- Author room layout, object placement, cutaway groups, trigger volumes, exits, camera regions, lights, and occluders in Tiled.
- Give every interactive object a stable ID, class, localized label key, interaction verb, optional script hook, and save-state policy.
- Store puzzle state as data commands: set flag, enable object, disable object, swap visual state, update blocker, emit dialogue, play sound, move actor, or transition room.
- Keep object definitions separate from object instances. A `locked_door` class can define default blocker and prompt behavior, while a specific door instance defines stable ID, lock flag, room exit, and key requirement.
- Store collision and interaction shapes separately. Footprints feed `tilefield`; sensors and overlaps feed `physics`; hover/pick shapes feed the interaction index.
- Save durable room changes, not transient render queue entries, temporary paths, or UI widget state.

## Technical design notes

- Build the scene from Tiled into three outputs: visual tilemap/objects, gameplay tilefield, and interaction/physics indexes.
- Use isometric projection helpers for picking ground tiles, then resolve object hits using object shapes and sorted depth priority.
- Use `lurek.pathfind.newIsoGridFromField` for click movement and local NPC movement. Rebuild or patch the grid when doors and blockers change.
- Use `lurek.physics` as a pragmatic helper for trigger volumes, interaction sensors, and debug shapes; do not make rigid-body physics the source of truth for isometric tile legality.
- Use `lurek.light` for visible scene lights and occluders. Use `lurek.tilelight` when puzzles or stealth-like readability need cell-level light values.
- Keep all interaction text localization-ready through keys, not hard-coded strings in map objects.
- Track the missing generic runtime layer in issue #50: richer Tiled object metadata, object-shape import, isometric picker, render-depth queue, cutaway policies, and area validation.

## Vertical slice acceptance

The slice should include three connected isometric rooms, click-to-move, one NPC, one locked door, one key or puzzle item, one container, one inspect-only hotspot, one room transition, one trigger volume, one cutaway roof or foreground wall, one point light with an occluder, hover prompts, object state changes saved across reload, and debug overlays for tile coordinates, hotspots, colliders, blockers, cutaway triggers, and depth order.

## Risks

The biggest risk is mixing interaction logic into map art. Keep art layers, blocker facts, physics sensors, and interaction scripts separate but linked by stable object IDs. The second risk is poor picking priority in dense scenes. Make the picker deterministic, debug-visible, and configurable before adding large numbers of props and hotspots.
