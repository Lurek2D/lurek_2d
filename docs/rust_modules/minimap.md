# minimap

## General Info

- Module group: `Feature Systems`
- Source path: `src/minimap/`
- Binding: `src/lua_api/minimap_api.rs`
- Namespace: `lurek.minimap`
- Lua API surface: `1` functions, `1` types, `86` methods
- Rust test path(s): tests/rust/game/minimap_tests.rs
- Lua test path(s): tests/lua/unit/test_minimap.lua, tests/lua/evidence/test_evidence_minimap.lua

## Summary

This module provides a grid-based tactical minimap subsystem for HUD views. It maintains a map model tracking cells, terrain types, and display layers. These layers can be stacked to combine different map representations (like terrain and political views) or show varied vertical elevations, offering highly customizable tactical HUD feedback.

To represent gameplay, the module displays dynamic indicators on the map. It supports pins, markers, and colored path overlays. Markers are managed by type and can carry custom textures or timed animations, while temporary pings alert players to events. Viewport rectangles show camera bounds, keeping overlay rendering highly organized.

Visibility is managed via fog-of-war systems, tracking explored cells and revealing sections inside a radius. A specialized raycaster overlay builds visibility grids from wall, floor, and light layouts, using Bresenham line traversal to compute line-of-sight profiles and render player indicators in real-time.

For user interfaces, the system tracks active cameras, keeping the minimap centered on targets. Grid-to-screen and screen-to-grid coordinate conversions support pointer hover checks and click targeting. Finally, completed map states can be rendered as HUD overlays or exported directly into CPU image buffers.

## Files

### [minimap.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/minimap/minimap.rs)

- Grid-based minimap model with configurable terrain colors and fog-of-war.
- Tracks world cells, visible state, and overlay layers in one structure.
- Stores object markers, pings, and path shapes for live HUD feedback.
- Supports terrain and political color modes for strategic presentation.
- Manages zoom, pan, camera tracking, and viewport framing.
- Projects screen and grid coordinates in both directions for interaction.
- Renders CPU-side image buffers for export and preview use cases.
- Includes timed animation behaviors for pings and persistent markers.
- Separates layer data so the minimap can stack multiple map representations.
- Keeps hover and hit information available for UI and debug tools.
- Balances compact runtime state with flexible overlay composition.
- Provides the main data source for both generic and raycaster-style minimaps.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/minimap/mod.rs)

- Minimap subsystem for terrain layers, fog, markers, overlays, and export rendering.
- Connects the grid model with renderer output, province data, and raycaster-specific views.
- Keeps all minimap-facing state under one runtime namespace.

### [province_adapter.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/minimap/province_adapter.rs)

- Bridge between province world data and the minimap grid.
- Copies terrain, fog, and palette state into a minimap representation.
- Clips to the smaller grid so size mismatches stay safe.
- Lets world-region data feed the minimap without custom glue code.

### [raycaster_overlay.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/minimap/raycaster_overlay.rs)

- Raycaster-specific minimap overlay renderer for tile-based visibility views.
- Builds a pixel-grid minimap from wall, floor, and lighting information.
- Uses line-of-sight and Bresenham traversal to reveal reachable cells.
- Fills raw RGBA buffers for fast image output and preview rendering.
- Draws the player indicator as a compact orientation cue on top of the map.
- Serves as the specialised bridge between raycasting state and minimap output.

### [render.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/minimap/render.rs)

- Converts minimap state into an ordered render command stream.
- Draws terrain, fog, overlays, objects, pings, markers, and viewport guides.
- Projects grid coordinates through the minimap transform into screen space.
- Keeps the drawing order stable so HUD elements stack predictably.
- Supports zoom-dependent and animated presentation without mutating the world model.
- Acts as the generic renderer path for the minimap subsystem.

### [types.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/minimap/types.rs)

- Shared minimap data types for colors, fog, overlays, and live markers.
- Defines the small enums and structs that other minimap files reuse.
- Carries per-object and per-path state for animated overlays.
- Separates raw layer bytes from higher-level minimap behavior.
- Provides the data vocabulary for the whole minimap subsystem.
