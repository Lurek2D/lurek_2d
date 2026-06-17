# minimap

## TL;DR

- Runs grid-based HUD minimaps with fog-of-war, custom markers, raycaster overlays, and camera tracking.

## General Info

- Module group: `Feature Systems`
- Source path: `src/minimap/`
- Binding: `src/lua_api/minimap_api.rs`
- Namespace: `lurek.minimap`
- Lua API surface: `1` functions, `1` types, `86` methods
- Rust test path(s): tests/rust/game/minimap_tests.rs
- Lua test path(s): tests/lua/unit/test_minimap.lua, tests/lua/evidence/test_evidence_minimap.lua

## Summary

- This module gives users a tactical minimap system for HUD-level world awareness and navigation support.
- Grid layers allow multiple map views such as terrain, ownership, and special tactical overlays.
- Marker, ping, and path features provide live event cues and route visualization.
- Object-type controls support per-category visibility and styling behavior.
- Fog-of-war handling tracks explored versus hidden cells for information-driven gameplay.
- Radius reveal helpers support scouting, sensor, and exploration mechanics.
- Viewport overlays show active camera framing relative to map content.
- Camera tracking keeps minimap focus aligned with moving targets.
- Grid/screen conversion APIs support clickable minimaps and hover tooltips.
- Raycaster overlay support enables visibility-aware minimaps for tile raycast games.
- Image export paths make minimap state reusable in tooling and test evidence.
- For users, this module centralizes map awareness UI in one scriptable system.
- It reduces custom HUD glue and keeps tactical overlays consistent.
- Overall, it turns minimaps into interactive gameplay surfaces rather than static decorations.

This module primarily collaborates with `camera`, `image`, `province`, `raycaster`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Imports

- `camera`: Imports or references `src/camera/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `image`: Imports or references `image` from `src/image/`.
- `province`: Imports or references `src/province/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `raycaster`: Imports or references `src/raycaster/`. Dependency stays inside `Feature Systems` and should remain acyclic.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### minimap.rs

- Grid-based minimap model with configurable terrain colors and fog-of-war. `minimap/minimap` delivers the minimap implementation for the minimap subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Tracks world cells, visible state, and overlay layers in one structure. The file owns or coordinates data contracts including `MinimapIcon`, `Minimap`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Stores object markers, pings, and path shapes for live HUD feedback. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `grid_width`, `grid_height`, `grid_size`, `display_width`, `display_height`, and 86 more stays attached to the local data model and invariants.
- Supports terrain and political color modes for strategic presentation. Runtime integration reaches sibling engine areas through crate modules `camera`, `log_msg`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Manages zoom, pan, camera tracking, and viewport framing. External integration uses `super`, `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Projects screen and grid coordinates in both directions for interaction. The file boundary separates minimap implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### mod.rs

- Minimap subsystem for terrain layers, fog, markers, overlays, and export rendering. `minimap/mod` is the minimap module index, declaring `minimap`, `province_adapter`, `raycaster_overlay`, `render`, `types` so agents can identify which files own each feature slice before opening implementation code.
- Connects the grid model with renderer output, province data, and raycaster-specific views. `src/minimap/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `minimap::Minimap`, `raycaster_overlay::{ build_minimap_tile_window, compute_tile_light, draw_player_arrow, extract_minimap, reveal_cells_from_rays, MinimapTileSample, }`, `types::{ ColorMode, FogLevel, LayerData, MarkerAnimation, MinimapMarker, MinimapObject, MinimapObjectType, MinimapPing, OverlayPath, OverlayShape, }` centralized for the minimap subsystem.

### province_adapter.rs

- Bridge between province world data and the minimap grid. `minimap/province_adapter` delivers the province adapter implementation for the minimap subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Copies terrain, fog, and palette state into a minimap representation. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Clips to the smaller grid so size mismatches stay safe. Public callable behavior is centered on `apply_terrain`, `apply_visibility`, `apply_terrain_palette`, while method-level behavior such as no named public items stays attached to the local data model and invariants.

### raycaster_overlay.rs

- Raycaster-specific minimap overlay renderer for tile-based visibility views. `minimap/raycaster_overlay` delivers the raycaster overlay implementation for the minimap subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Builds a pixel-grid minimap from wall, floor, and lighting information. The file owns or coordinates data contracts including `MinimapTileSample`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Uses line-of-sight and Bresenham traversal to reveal reachable cells. Public callable behavior is centered on `compute_tile_light`, `build_minimap_tile_window`, `reveal_cells_from_rays`, `extract_minimap`, `draw_player_arrow`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Fills raw RGBA buffers for fast image output and preview rendering. Runtime integration reaches sibling engine areas through crate modules `raycaster`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Draws the player indicator as a compact orientation cue on top of the map. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### render.rs

- Converts minimap state into an ordered render command stream. `minimap/render` delivers the rendering adapter and draw-command integration for the minimap subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Draws terrain, fog, overlays, objects, pings, markers, and viewport guides. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Projects grid coordinates through the minimap transform into screen space. Public callable behavior is centered on no named public items, while method-level behavior such as `generate_render_commands` stays attached to the local data model and invariants.
- Keeps the drawing order stable so HUD elements stack predictably. Runtime integration reaches sibling engine areas through crate modules `render`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Supports zoom-dependent and animated presentation without mutating the world model. External integration uses `super`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### types.rs

- Shared minimap data types for colors, fog, overlays, and live markers. `minimap/types` delivers the shared type definitions and data contracts for the minimap subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Defines the small enums and structs that other minimap files reuse. The file owns or coordinates data contracts including `ColorMode`, `FogLevel`, `MinimapObjectType`, `MinimapObject`, `MinimapPing`, and 5 more, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Carries per-object and per-path state for animated overlays. Public callable behavior is centered on no named public items, while method-level behavior such as `parse_mode`, `as_str`, `from_u8` stays attached to the local data model and invariants.
- Separates raw layer bytes from higher-level minimap behavior. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.



## Lua API Ref

### Functions

- `lurek.minimap.newMinimap(grid_w, grid_h, display_w?, display_h?) -> LMinimap`: Creates a minimap with grid dimensions and optional display size.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LMinimap Type

- Lua-side wrapper for a minimap instance and access to render command state.

##### Fields

- No documented fields.

##### Methods

- `LMinimap:addMarker(x, y, desc?, r?, g?, b?, a?) -> integer`: Adds a world-space marker and returns its unique id.
- `LMinimap:addObjectType(name, r, g, b, a?) -> integer`: Adds an object type and returns its one-based index.
- `LMinimap:addPing(x, y, duration, r?, g?, b?, a?) -> nil`: Adds a timed ping effect at a minimap world position.
- `LMinimap:clearMarkerAnimation(id) -> nil`: Clears the animation assigned to a marker by id.
- `LMinimap:clearMarkerTexture(id) -> nil`: Clears image texture from a marker.
- `LMinimap:clearObjectTypeTexture(type_idx) -> nil`: Clears image texture for an object type.
- `LMinimap:clearObjects() -> nil`: Clears all objects from the minimap.
- `LMinimap:clearOverlay() -> nil`: Clears all minimap overlay shapes.
- `LMinimap:clearPath(id?) -> nil`: Clears one path by id or all paths when no id is provided.
- `LMinimap:clearViewportRect() -> nil`: Clears the minimap viewport rectangle overlay.
- `LMinimap:drawLine(x1, y1, x2, y2, color_tbl) -> nil`: Adds an overlay line between two world-space points.
- `LMinimap:drawRect(x, y, w, h, color_tbl) -> nil`: Adds an overlay rectangle at a world-space position.
- `LMinimap:drawToImage(pixel_size) -> LImageData`: Draws the minimap into image data at a pixel size.
- `LMinimap:getCellCount() -> integer`: Returns the total number of grid cells.
- `LMinimap:getCenter() -> number`: Returns the current minimap world-space center position.
- `LMinimap:getCenterX() -> number`: Returns minimap world center x coordinate.
- `LMinimap:getCenterY() -> number`: Returns minimap world center y coordinate.
- `LMinimap:getColorMode() -> string`: Returns the current minimap color mode.
- `LMinimap:getDisplayHeight() -> integer`: Returns the minimap display height.
- `LMinimap:getDisplaySize() -> integer`: Returns the minimap display width and height in pixels.
- `LMinimap:getDisplayWidth() -> integer`: Returns the minimap display width.
- `LMinimap:getFogColor() -> number`: Returns the current RGBA fog overlay color.
- `LMinimap:getFogLevel(x, y) -> integer`: Returns fog level for a one-based grid cell.
- `LMinimap:getGridHeight() -> integer`: Returns the height of the minimap grid in cells.
- `LMinimap:getGridSize() -> integer`: Returns the minimap grid width and height in cells.
- `LMinimap:getGridWidth() -> integer`: Returns the width of the minimap grid in cells.
- `LMinimap:getHoverInfo(sx, sy, mx, my) -> string`: Returns hover text for a screen position when available.
- `LMinimap:getLayer() -> integer`: Returns the active minimap display layer index.
- `LMinimap:getLayerCount() -> integer`: Returns the number of minimap layers.
- `LMinimap:getLayerData(layer) -> integer[]`: Returns raw cell data for a minimap layer.
- `LMinimap:getMarkerCount() -> integer`: Returns the total number of minimap markers.
- `LMinimap:getMarkerDescription(id) -> string`: Returns a marker description by id.
- `LMinimap:getObjectCount() -> integer`: Returns the number of objects on the minimap.
- `LMinimap:getObjectTypeCount() -> integer`: Returns the number of object types.
- `LMinimap:getOverlayShapeCount() -> integer`: Returns the number of overlay shapes.
- `LMinimap:getOwnerColor(owner) -> number`: Returns the current RGBA color for an owner id.
- `LMinimap:getPathCount() -> integer`: Returns the number of active path overlays.
- `LMinimap:getPingCount() -> integer`: Returns the number of active pings.
- `LMinimap:getTerrain(x, y) -> integer`: Returns terrain type for a one-based grid cell.
- `LMinimap:getTerrainColor(terrain_type) -> number`: Returns RGBA color for a terrain type.
- `LMinimap:getTileDescription(type_id) -> string`: Returns text description for a tile type.
- `LMinimap:getViewportColor() -> number`: Returns the viewport rectangle color.
- `LMinimap:getViewportRect() -> number`: Returns the viewport rectangle when one is set.
- `LMinimap:getZoom() -> number`: Returns the current minimap zoom magnification level.
- `LMinimap:gridToScreen(gx, gy, mx, my) -> number`: Converts grid coordinates to screen coordinates.
- `LMinimap:hasMarker(id) -> boolean`: Returns whether a marker id exists.
- `LMinimap:isAntiAlias() -> boolean`: Returns whether anti-aliasing is enabled.
- `LMinimap:isClickable() -> boolean`: Returns whether minimap click handling is enabled.
- `LMinimap:isFogEnabled() -> boolean`: Returns whether fog display is enabled.
- `LMinimap:isObjectTypeVisible(type_idx) -> boolean`: Returns visibility for an object type by one-based index.
- `LMinimap:isViewportVisible() -> boolean`: Returns whether the viewport rectangle is visible.
- `LMinimap:removeMarker(id) -> boolean`: Removes a minimap marker by its unique id.
- `LMinimap:removeObject(id) -> boolean`: Removes a minimap object by its unique id.
- `LMinimap:render(x?, y?) -> nil`: Enqueues minimap render commands at an optional screen position.
- `LMinimap:revealRadius(cx, cy, radius) -> nil`: Reveals fog inside a world-space radius.
- `LMinimap:screenToGrid(sx, sy, mx, my) -> number`: Converts a screen position to grid coordinates.
- `LMinimap:setAntiAlias(enabled) -> nil`: Enables or disables minimap anti-aliasing.
- `LMinimap:setCenter(x, y) -> nil`: Sets the minimap world-space center position.
- `LMinimap:setClickable(enabled) -> nil`: Enables or disables minimap click handling.
- `LMinimap:setColorMode(mode) -> nil`: Sets the minimap color mode to terrain or political.
- `LMinimap:setDisplaySize(w, h) -> nil`: Sets the minimap display width and height in pixels.
- `LMinimap:setFogColor(r, g, b, a?) -> nil`: Sets the RGBA fog overlay color for covered cells.
- `LMinimap:setFogData(data) -> nil`: Replaces fog data from a flat array table.
- `LMinimap:setFogEnabled(enabled) -> nil`: Enables or disables the minimap fog display.
- `LMinimap:setFogLevel(x, y, level) -> nil`: Sets fog level for a one-based grid cell.
- `LMinimap:setLayer(layer) -> nil`: Sets the active minimap display layer index.
- `LMinimap:setLayerData(layer, data_tbl) -> nil`: Sets raw cell data for a minimap layer.
- `LMinimap:setMarkerAnimation(id, anim_type, speed) -> nil`: Sets marker animation by type name.
- `LMinimap:setMarkerTexture(id, image_ud, width?, height?) -> nil`: Assigns an image texture to a marker.
- `LMinimap:setObject(id, x, y, type_idx, owner?) -> nil`: Adds or updates an object on the minimap.
- `LMinimap:setObjectTypeTexture(type_idx, image_ud, width?, height?) -> nil`: Assigns an image texture to an object type.
- `LMinimap:setObjectTypeVisible(type_idx, visible) -> nil`: Sets visibility for an object type by one-based index.
- `LMinimap:setOwnerColor(owner, r, g, b, a?) -> nil`: Sets the RGBA display color for an owner id.
- `LMinimap:setTerrain(x, y, terrain_type) -> nil`: Sets terrain type for a one-based grid cell.
- `LMinimap:setTerrainColor(terrain_type, r, g, b, a?) -> nil`: Sets the RGBA display color for a terrain type.
- `LMinimap:setTerrainData(data) -> nil`: Replaces terrain data from a flat array table.
- `LMinimap:setTileDescription(type_id, desc) -> nil`: Sets text description for a tile type.
- `LMinimap:setViewportColor(r, g, b, a?) -> nil`: Sets the viewport rectangle color.
- `LMinimap:setViewportRect(x, y, w, h) -> nil`: Sets the visible viewport rectangle shown on the minimap.
- `LMinimap:setViewportVisible(visible) -> nil`: Sets whether the viewport rectangle is visible.
- `LMinimap:setZoom(zoom) -> nil`: Sets the minimap zoom magnification level.
- `LMinimap:showPath(points_tbl, color_tbl) -> integer`: Adds a colored path overlay and returns its id.
- `LMinimap:trackCamera(camera_ud) -> nil`: Centers the minimap and viewport rectangle from a camera handle.
- `LMinimap:type() -> string`: Returns the Lua-visible type name for this minimap handle.
- `LMinimap:typeOf(name) -> boolean`: Returns whether this minimap handle matches a supported type name.
- `LMinimap:update(dt) -> nil`: Advances minimap animations and timers.

## References

- `camera`: Imports or references `src/camera/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `image`: Imports or references `image` from `src/image/`.
- `province`: Imports or references `src/province/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `raycaster`: Imports or references `src/raycaster/`. Dependency stays inside `Feature Systems` and should remain acyclic.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- No additional module-specific notes.
