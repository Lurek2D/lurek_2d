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

## Imports

- `camera`: Imports or references `src/camera/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `image`: Imports or references `image` from `src/image/`.
- `province`: Imports or references `src/province/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `raycaster`: Imports or references `src/raycaster/`. Dependency stays inside `Feature Systems` and should remain acyclic.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### minimap.rs

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

### mod.rs

- Minimap subsystem for terrain layers, fog, markers, overlays, and export rendering.
- Connects the grid model with renderer output, province data, and raycaster-specific views.
- Keeps all minimap-facing state under one runtime namespace.

### province_adapter.rs

- Bridge between province world data and the minimap grid.
- Copies terrain, fog, and palette state into a minimap representation.
- Clips to the smaller grid so size mismatches stay safe.
- Lets world-region data feed the minimap without custom glue code.

### raycaster_overlay.rs

- Raycaster-specific minimap overlay renderer for tile-based visibility views.
- Builds a pixel-grid minimap from wall, floor, and lighting information.
- Uses line-of-sight and Bresenham traversal to reveal reachable cells.
- Fills raw RGBA buffers for fast image output and preview rendering.
- Draws the player indicator as a compact orientation cue on top of the map.
- Serves as the specialised bridge between raycasting state and minimap output.

### render.rs

- Converts minimap state into an ordered render command stream.
- Draws terrain, fog, overlays, objects, pings, markers, and viewport guides.
- Projects grid coordinates through the minimap transform into screen space.
- Keeps the drawing order stable so HUD elements stack predictably.
- Supports zoom-dependent and animated presentation without mutating the world model.
- Acts as the generic renderer path for the minimap subsystem.

### types.rs

- Shared minimap data types for colors, fog, overlays, and live markers.
- Defines the small enums and structs that other minimap files reuse.
- Carries per-object and per-path state for animated overlays.
- Separates raw layer bytes from higher-level minimap behavior.
- Provides the data vocabulary for the whole minimap subsystem.

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
