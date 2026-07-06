# Isometric World RPG

**Category:** Role-playing games  
**Reference games:** Fallout 1/2, Arcanum, ATOM RPG, Shadowrun Returns presentation layer  
**Document type:** Technical game design and architecture

## Design target

A one-level isometric RPG area model with authored towns, interiors, ruins, walls, doors, containers, NPC spawns, props, roof/cutaway groups, shadows, and click/hover interaction. This design is about world presentation and scene management, not character stats, combat rules, quest logic, dialogue trees, or party mechanics.

The player should read a dense 2D isometric space as a coherent place: floor tiles establish walkable ground, wall faces and tall props occlude correctly, objects can be selected and interacted with, shadows support depth, and Tiled-authored map data can become runtime scene data without hand-written one-off loaders per area.

## Market positioning

Use the reference set (Fallout 1/2, Arcanum, ATOM RPG, Shadowrun Returns presentation layer) to define player expectations around readable isometric places, object density, mouse-driven exploration, and environmental storytelling, not to copy mechanics directly. Target itch.io with a compact town/interior slice that proves map authoring, depth sorting, and interactions. Target Steam with a reliable Tiled pipeline, save-stable map objects, inspectable debug overlays, readable cutaway behavior, and enough authored locations to make the isometric presentation feel intentional.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Isometric terrain and wall tiles | `lurek.tilemap`, `LIsoMap`, `lurek.camera` |
| Gameplay cell facts | `lurek.tilefield` with `iso_square`, cell refs, and blocker channels |
| Actors, props, and stable object identity | `lurek.ecs`, `lurek.scene`, `lurek.save` |
| Click-to-move navigation | `lurek.pathfind.newIsoGridFromField`, `lurek.input` |
| Doors, containers, triggers, and interaction zones | `lurek.physics` sensors/queries, `lurek.signal`, `lurek.ui` |
| Scene lights, shadows, and tile-level light blockers | `lurek.light`, `lurek.tilelight`, `lurek.render` |
| Tiled-authored areas | `lurek.tilemap.loadTMX`, future `library.iso_world` import helpers |

## Runtime architecture

Use an `IsoAreaState` as the loaded-area owner. It keeps the visual tilemap, gameplay tilefield, object registry, navigation grid, render queue inputs, cutaway groups, lights, and validation diagnostics together. Area state is loaded when entering a location and discarded or serialized when leaving.

Represent every interactive map item as an `IsoObject` with a stable ID, class, anchor, footprint, height, draw band, blocker profile, interaction profile, optional collider, optional light/occluder profile, and arbitrary authored properties. The same object definition should be able to update visual state, tilefield blockers, physics sensors, and save data when a door opens, a container is looted, or a prop is destroyed.

Build an `IsoRenderQueue` each frame from terrain tiles, decals, wall faces, tall props, actors, VFX, roof/canopy layers, debug overlays, and UI markers. Sort using isometric anchor depth, draw-band bias, optional z/height offsets, and a stable tie-breaker so equal-depth objects do not flicker. Authored override constraints should be rare but supported for tall objects that span multiple cells.

Treat cutaways as data, not special-case code. A roof group, wall group, or foreground object can fade, hide, silhouette hidden actors, or reveal interaction outlines when the player enters a room volume, when the camera crosses a threshold, or when the mouse hovers a hidden object.

## Suggested project structure

```text
my_iso_rpg/
  data/areas/*.tmx
  data/tilesets/*.tsx
  data/tiled_classes.toml
  data/objects.toml
  data/interactions.toml
  scripts/state/area_state.lua
  scripts/systems/iso_world.lua
  scripts/systems/iso_render_queue.lua
  scripts/systems/iso_interactions.lua
  scripts/systems/iso_cutaways.lua
  scripts/systems/iso_navigation.lua
  scripts/ui/inspect_panel.lua
  assets/tilesets/
  assets/objects/
  assets/lights/
```

## Data and content model

- Author floor, wall-face, decal, roof, shadow, trigger, and object layers in Tiled with stable layer names and classes.
- Author doors, containers, exits, lights, occluders, NPC spawns, and interaction hotspots as Tiled objects with stable IDs and typed custom properties.
- Store object runtime state separately from the static map: opened doors, disabled traps, looted containers, moved NPCs, and changed blockers belong in save data.
- Keep visual tile IDs in `lurek.tilemap`; keep movement, sight, action, and light blockers in `lurek.tilefield`.
- Give every object an explicit anchor and footprint. Sprite bounds, interaction bounds, collision bounds, and blocker footprint are related but not the same thing.
- Keep map validation strict in development. Missing stable IDs, invalid object classes, unknown scripts, unsupported shapes, or unmapped blockers should become loud diagnostics.

## Technical design notes

- Use `LIsoMap` and `lurek.tilemap` for projection and tile presentation, but route object-dense scenes through an isometric render queue instead of relying only on raw layer order.
- Use `lurek.tilefield` as the shared source of truth for gameplay cell facts. Doors and dynamic props should update tilefield blockers before pathfinding, awareness, or lighting systems read them.
- Use `lurek.pathfind.newIsoGridFromField` for click-to-move and NPC routes. Do not pathfind in projected screen pixels.
- Use `lurek.physics` primarily for object sensors, interaction ranges, trigger volumes, collision helper queries, and debug visualization. This is still a 2D world, not full 3D physics.
- Use `lurek.light` for render-facing lights and occluders, and `lurek.tilelight` for tile-level environment lighting or gameplay light maps.
- Track the missing generic runtime layer in issue #50: richer Tiled metadata import, an `iso_world` runtime, an isometric picker, stable render-depth helpers, tilefield/physics adapters, and validation tooling.

## Vertical slice acceptance

The slice should include one Tiled isometric area with an exterior and one interior, floor/decal/wall/roof layers, three tall props, one working door, one container, one NPC spawn, one exit trigger, one point light, at least one wall/light occluder, click-to-move over an `iso_square` tilefield, hover/click interaction selection, roof or wall cutaway behavior, save/reload of object state, and debug overlays for anchors, depth keys, blockers, colliders, lights, and interaction bounds.

## Risks

The largest risk is visual ambiguity from unstable draw order. Centralize depth-key generation and make debug labels visible before adding many authored props. The second risk is Tiled metadata drift. Keep a versioned Tiled class/profile schema and validate maps at load time so content mistakes fail early instead of becoming invisible runtime bugs.
