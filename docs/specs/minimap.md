<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/minimap.md or source docstrings instead. -->

# minimap

## TL;DR

- Runs grid-based HUD minimaps with fog-of-war, custom markers, raycaster overlays, and camera tracking.

## General Info

- Module group: `Feature Systems`
- Source path: `src/minimap`
- Binding: `src/lua_api/minimap_api.rs`
- Namespace: `lurek.minimap`
- Lua API surface: `1` functions, `1` types, `86` methods
- User-facing: `true`
- Plugin tier: `tier_2_plugin`

## Summary

- The `minimap` module is the HUD-scale map surface for users who want world state, fog, markers, and view tracking to become a compact readable overlay.
- Core minimap state, render helpers, and adapters from province or raycaster data work together so the same module can represent several kinds of world information in one small map display.
- Fog, owner colors, overlays, tracked objects, and camera-aware view markers matter because a minimap is not only a tiny texture: it is a summarized navigation and awareness tool for the player.
- The module is useful wherever a project needs strategic orientation, local awareness, or debug-style map inspection without switching to a full map screen.
- Marker and layer support are especially important because a minimap often needs to combine several categories of information at once: player position, objectives, faction territory, danger, or discovered landmarks.
- In tool and strategy-heavy contexts, the minimap can also become a compact interaction surface or diagnostic lens rather than only a passive HUD element, which is why adapters and styling control matter.
- Rotation, zoom, clipping, and icon policy matter too, because a compact map has to stay legible while world state and camera framing keep changing.
- A minimap is therefore not only a tiny render, but a compact policy layer for world awareness.
- Read it as the owner of compact map presentation.

This module primarily collaborates with `camera`, `image`, `province`, `raycaster`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/minimap`
- Owning tier: `Feature Systems`
- Plugin tier: `tier_2_plugin`
- Lua binding owner: `src/lua_api/minimap_api.rs`
- Referenced engine modules: `camera`, `image`, `province`, `raycaster`, `render`, `runtime`

## Imports

- `camera`: Imports or references `src/camera/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `image`: Imports or references `src/image/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `province`: Imports or references `src/province/`. Dependency stays inside `Feature Systems` and should remain acyclic.
- `raycaster`: Imports or references `src/raycaster/`. Dependency stays inside `Feature Systems` and should remain acyclic.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Feature Systems` into `Core Runtime`.

## Source Files

### minimap.rs

- Owns minimap behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps minimap data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how minimap data is validated, transformed, or stored before neighboring systems use it.
- Owns minimap behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on minimap behavior while Lua registration stays elsewhere.
- Documents the boundary where minimap code accepts inputs, reports errors, or updates state.
- Use this file when changing minimap defaults, lifecycle handling, validation, or data ownership.
- Keeps failure paths and edge cases near the minimap state that can explain them while keeping call sites explicit.
- Preserves deterministic behavior by keeping minimap calculations explicit at their owner boundary.
- Provides the local adaptation layer that lets callers avoid duplicating minimap rules while keeping call sites explicit.
- Maintains small helper surfaces so broader engine modules can compose minimap behavior safely.
- Protects subsystem contracts by keeping resource, cache, or state mutations visible in one place.

### mod.rs

- `src/minimap/mod.rs` is the module index for the minimap subsystem, covering state, render helpers, types, and adapters.
- It declares the core `minimap` model, province adapter, renderer bridge, and raycaster overlay as separate files.
- This file also reexports `Minimap`, overlay sampling helpers, and shared minimap types so callers avoid deep paths.
- No runtime minimap state lives here; its job is to define the public boundary and keep subsystem ownership visible.
- Read this index first when tracing minimap features, because it shows where data, rendering, and map import split.
- Changes here affect module reachability and public surface, not minimap behavior, storage, or per-frame update rules.

### province_adapter.rs

- `src/minimap/province_adapter.rs` maps province registry snapshots into minimap terrain colors and fog visibility grids.
- It owns the translation layer between `ProvinceRegistry` data and `Minimap`, while clipping writes to shared bounds.
- Terrain ids, visibility states, and political colors are copied here so province rules stay out of minimap core.
- Read this file when province snapshots, fog mapping, or terrain palette import behavior for minimaps needs to change.

### raycaster_overlay.rs

- Owns the raycaster overlay owner for the minimap subsystem and keeps its rules local to this file.
- Keeps minimap data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how raycaster overlay data is validated, transformed, or stored before neighboring systems use it.
- Owns minimap behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on raycaster overlay behavior while Lua registration stays elsewhere.
- Documents the boundary where minimap code accepts inputs, reports errors, or updates state.
- Use this file when changing raycaster overlay defaults, lifecycle handling, validation, or data ownership.

### render.rs

- Owns minimap behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps minimap data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how render data is validated, transformed, or stored before neighboring systems use it.
- Owns minimap behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on render behavior while Lua registration stays elsewhere.
- Documents the boundary where minimap code accepts inputs, reports errors, or updates state.
- Use this file when changing render defaults, lifecycle handling, validation, or data ownership.

### types.rs

- Owns the shared type model for the minimap subsystem and keeps its rules local to this file.
- Centers the implementation around ColorMode, parse_mode, as_str, with helpers kept close to their invariants.
- Defines how types data is validated, transformed, or stored before neighboring systems use it.
- Owns minimap behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on types behavior while Lua registration stays elsewhere.
- Documents the boundary where minimap code accepts inputs, reports errors, or updates state.
- Use this file when changing types defaults, lifecycle handling, validation, or data ownership.



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

## Examples

- `content/examples/minimap.lua` (present)

## Tests

- Lua unit: `tests/lua/unit/test_minimap_unit.lua` (present)
- Rust: `tests/rust/unit/minimap_tests.rs`

## Evidence / Golden

| Kind | Path |
|---|---|
| Evidence test | `tests/lua/evidence/test_minimap_evidence.lua` |
| Golden test | `tests/lua/golden/test_minimap_golden.lua` |
| Current artifact | `tests/artifacts/current/minimap/minimap_blips.png` |
| Current artifact | `tests/artifacts/current/minimap/minimap_circular_border.png` |
| Current artifact | `tests/artifacts/current/minimap/minimap_command_overlay_route.png` |
| Current artifact | `tests/artifacts/current/minimap/minimap_floor_level0.png` |
| Current artifact | `tests/artifacts/current/minimap/minimap_floor_level1_active.png` |
| Current artifact | `tests/artifacts/current/minimap/minimap_floor_level2.png` |
| Current artifact | `tests/artifacts/current/minimap/minimap_fog.png` |
| Current artifact | `tests/artifacts/current/minimap/minimap_radar_sweep.png` |
| Current artifact | `tests/artifacts/current/minimap/minimap_terrain.png` |
| Current artifact | `tests/artifacts/current/minimap/minimap_unexplored_mask.png` |
| Current artifact | `tests/artifacts/current/minimap/minimap_viewport_bounds.png` |
| Current artifact | `tests/artifacts/current/minimap/minimap_waypoints.png` |
| Current artifact | `tests/artifacts/current/minimap/minimap_zoomed_sector.png` |
| Baseline artifact | `tests/artifacts/baselines/minimap/minimap_blips.png` |
| Baseline artifact | `tests/artifacts/baselines/minimap/minimap_circular_border.png` |
| Baseline artifact | `tests/artifacts/baselines/minimap/minimap_floor_level0.png` |
| Baseline artifact | `tests/artifacts/baselines/minimap/minimap_floor_level1_active.png` |
| Baseline artifact | `tests/artifacts/baselines/minimap/minimap_floor_level2.png` |
| Baseline artifact | `tests/artifacts/baselines/minimap/minimap_fog.png` |
| Baseline artifact | `tests/artifacts/baselines/minimap/minimap_radar_sweep.png` |
| Baseline artifact | `tests/artifacts/baselines/minimap/minimap_terrain.png` |
| Baseline artifact | `tests/artifacts/baselines/minimap/minimap_unexplored_mask.png` |
| Baseline artifact | `tests/artifacts/baselines/minimap/minimap_viewport_bounds.png` |
| Baseline artifact | `tests/artifacts/baselines/minimap/minimap_waypoints.png` |
| Baseline artifact | `tests/artifacts/baselines/minimap/minimap_zoomed_sector.png` |

## Architecture Links

- Intentionally empty.

## Notes

- Construction is strict: zero grid dimensions, zero display dimensions, overflowed cell counts, and oversized display buffers are rejected before the minimap is created.
- Bulk terrain and fog loads use exact-length validation on the Lua-facing API so stale cells are not silently mixed with fresh data.
- Grid/display transforms require finite coordinates, a finite positive zoom, and positive display dimensions; invalid transform state returns nils for `screenToGrid` and `gridToScreen` instead of leaking NaN or Inf into callers.
- Layer payloads are grid-shaped contracts: `width` and `height` must match the minimap grid, cell payload length must match `width * height`, and active-layer switches are only valid for populated layers.
- `drawToImage(pixel_size)` now honors `pixel_size` when provided, falls back to the configured display size when `pixel_size == 0`, and covers the full output image even when display pixels do not divide evenly by grid size.
- Render-command generation batches adjacent same-color cells into horizontal runs and exposes debug stats through `Minimap::render_stats(screen_x, screen_y)` for tooling and regression tests.
- Raycaster minimap extraction uses checked arithmetic for radius, cell size, pixel count, and byte count, and player-arrow drawing validates both width and height against the supplied RGBA buffer length.
- Marker/object/ping/icon setters reject missing ids, invalid type indices, non-finite coordinates, and invalid icon size overrides on the strict Lua path instead of silently no-oping.
