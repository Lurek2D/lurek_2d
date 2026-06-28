<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/minimap.md or source docstrings instead. -->

# minimap

## TL;DR

- Runs grid-based HUD minimaps with fog-of-war inputs, custom markers, passive render snapshots, and camera tracking.

## General Info

- Module group: `Feature Systems`
- Source path: `src/minimap`
- Binding: `src/lua_api/minimap_api.rs`
- Namespace: `lurek.minimap`
- Lua API surface: `1` functions, `1` types, `97` methods
- User-facing: `true`
- Plugin tier: `tier_2_plugin`

## Summary

- The `minimap` module is the HUD-scale map surface for users who want world state, fog, markers, and view tracking to become a compact readable overlay.
- Core minimap state, render helpers, and adapters from province, tilefield, awareness, tilelight, or render snapshot data work together so the same module can represent several kinds of world information in one small map display.
- Fog, owner colors, overlays, tracked objects, and camera-aware view markers matter because a minimap is not only a tiny texture: it is a summarized navigation and awareness tool for the player.
- The module is useful wherever a project needs strategic orientation, local awareness, or debug-style map inspection without switching to a full map screen.
- Marker and layer support are especially important because a minimap often needs to combine several categories of information at once: player position, objectives, faction territory, danger, or discovered landmarks.
- In tool and strategy-heavy contexts, the minimap can also become a compact interaction surface or diagnostic lens rather than only a passive HUD element, which is why adapters and styling control matter.
- Rotation, zoom, clipping, and icon policy matter too, because a compact map has to stay legible while world state and camera framing keep changing.
- A minimap is therefore not only a tiny render, but a compact policy layer for world awareness.
- Read it as the owner of compact map presentation.

This module primarily collaborates with `camera`, `image`, `province`, `raycaster`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

The broader integration map is split by role:

- Direct data producers: `tilefield`, `awareness`, `tilelight`, `tilemap`, `province`, `globe`, `procgen`, `pathfind`, and `raycaster` provide terrain ids, fog masks, light/heat layers, route overlays, region ownership, biome colors, camera/FOV hints, or marker/object snapshots.
- Presentation collaborators: `camera`, `render`, `image`, `light`, `overlay`, `ui`, `layout`, `window`, `input`, `math`, and `effect` provide viewport transforms, HUD placement, offscreen image/export behavior, interaction coordinates, shader/effect policy, and rendering primitives.
- Pattern references: `animation`, `sprite`, `spine`, `particle`, `parallax`, `charts`/radar, `physics`, `ecs`, and `scene` contain useful precedents for preview images, debug overlays, layer ordering, entity/object snapshots, and visual evidence, but should not become minimap dependencies unless a concrete adapter requires it.

## Ownership

- Canonical source: `src/minimap`
- Owning tier: `Feature Systems`
- Plugin tier: `tier_2_plugin`
- Lua binding owner: `src/lua_api/minimap_api.rs`
- Referenced engine modules: `camera`, `image`, `province`, `render`, `runtime`

## Imports

- `camera`: Imports or references `src/camera/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `image`: Imports or references `src/image/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `province`: Imports or references `src/province/`. Dependency stays inside `Feature Systems` and should remain acyclic.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Feature Systems` into `Core Runtime`.

## Source Files

### minimap.rs

- Owns the minimap runtime state, including world bounds, layers, fog, markers, objects, pings, and icon cache.
- Validates dimensions, zoom, marker counts, layer counts, and geometry inputs before they reach rendering helpers.
- Tracks dirty state and rebuild decisions so Lua callers can mutate minimap data without duplicating cache rules.
- Converts camera and world coordinates into minimap draw space while keeping camera ownership outside this file.
- Maintains overlays, paths, blend modes, color modes, and fog styles as minimap concepts, not renderer concepts.
- Integrates texture keys for icons by reference while asset cataloging and GPU upload remain in other modules.
- Produces render data and image output that downstream render paths can consume without owning minimap state.
- Keeps error reporting, limits, defaults, and deterministic calculations close to the minimap data owner.
- Provides crate-local helpers for Lua bindings while userdata registration and table conversion stay elsewhere.
- Update this file when minimap lifecycle, validation, draw planning, fog, marker, or object semantics change.
- Leave tilemap storage, camera control, renderer submission, and asset parsing in their owning subsystems.
- This boundary keeps the minimap composable for dashboards, games, debug tools, and generated evidence tests.
- Tests should assert state transitions here and use Lua integration when proving renderer or asset composition.

### mod.rs

- Indexes the passive minimap subsystem, naming the model, renderer, province adapter, and type owners.
- Reexports `Minimap` plus layer, marker, fog, ping, overlay, error, and validation data contracts.
- Keeps minimap ownership scoped to visualization of supplied terrain, fog, light, and overlay inputs only.
- Declares no runtime state here; concrete storage, render buffers, and import adapters live in sibling files.
- Guides agents toward the correct owner before changing ingestion, rendering, validation, or overlay behavior.
- Changes here affect module reachability and public symbol routing, not gameplay LOS, lighting, or movement.

### province_adapter.rs

- `src/minimap/province_adapter.rs` maps province registry snapshots into minimap terrain colors and fog visibility grids.
- It owns the translation layer between `ProvinceRegistry` data and `Minimap`, while clipping writes to shared bounds.
- Terrain ids, visibility states, and political colors are copied here so province rules stay out of minimap core.
- Read this file when province snapshots, fog mapping, or terrain palette import behavior for minimaps needs to change.

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
- `LMinimap:getLayerAlpha(layer) -> number`: Returns the opacity multiplier for a minimap data layer.
- `LMinimap:getLayerBlendMode(layer) -> string`: Returns how a minimap data layer is blended over the base terrain.
- `LMinimap:getLayerColor(layer, value) -> number`: Returns the palette color for one raw value in a minimap data layer.
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
- `LMinimap:getShader() -> LShader?`: Returns the currently bound command-render minimap shader, or nil.
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
- `LMinimap:isLayerVisible(layer) -> boolean`: Returns whether a minimap data layer is drawn when it is not active.
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
- `LMinimap:setLayerAlpha(layer, alpha) -> nil`: Sets the opacity multiplier for a minimap data layer.
- `LMinimap:setLayerBlendMode(layer, mode) -> nil`: Sets how a minimap data layer is blended over the base terrain.
- `LMinimap:setLayerColor(layer, value, r, g, b, a?) -> nil`: Sets a palette color for one raw value in a minimap data layer.
- `LMinimap:setLayerData(layer, data_tbl) -> nil`: Sets raw cell data for a minimap layer.
- `LMinimap:setLayerVisible(layer, visible) -> nil`: Sets whether a minimap data layer is drawn even when it is not the active layer.
- `LMinimap:setMarkerAnimation(id, anim_type, speed) -> nil`: Sets marker animation by type name.
- `LMinimap:setMarkerTexture(id, image_ud, width?, height?) -> nil`: Assigns an image texture to a marker.
- `LMinimap:setObject(id, x, y, type_idx, owner?) -> nil`: Adds or updates an object on the minimap.
- `LMinimap:setObjectTypeTexture(type_idx, image_ud, width?, height?) -> nil`: Assigns an image texture to an object type.
- `LMinimap:setObjectTypeVisible(type_idx, visible) -> nil`: Sets visibility for an object type by one-based index.
- `LMinimap:setOwnerColor(owner, r, g, b, a?) -> nil`: Sets the RGBA display color for an owner id.
- `LMinimap:setShader(shader?) -> nil`: Binds or clears a `mapviz` shader for command-rendered minimap visualization.
- `LMinimap:setTerrain(x, y, terrain_type) -> nil`: Sets terrain type for a one-based grid cell.
- `LMinimap:setTerrainColor(terrain_type, r, g, b, a?) -> nil`: Sets the RGBA display color for a terrain type.
- `LMinimap:setTerrainData(data) -> nil`: Replaces terrain data from a flat array table.
- `LMinimap:setTileDescription(type_id, desc) -> nil`: Sets text description for a tile type.
- `LMinimap:setViewportColor(r, g, b, a?) -> nil`: Sets the viewport rectangle color.
- `LMinimap:setViewportRect(x, y, w, h) -> nil`: Sets the visible viewport rectangle shown on the minimap.
- `LMinimap:setViewportVisible(visible) -> nil`: Sets whether the viewport rectangle is visible.
- `LMinimap:setZoom(zoom) -> nil`: Sets the minimap zoom magnification level.
- `LMinimap:showPath(points_tbl, color_tbl) -> integer`: Adds a colored path overlay and returns its id.
- `LMinimap:syncProvinceRegistry(registry, opts?) -> nil`: Copies province registry terrain, visibility, and palette data into this minimap.
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
| Current artifact | `tests/artifacts/current/minimap/minimap_fog_states.png` |
| Current artifact | `tests/artifacts/current/minimap/minimap_layer_blend_modes.png` |
| Current artifact | `tests/artifacts/current/minimap/minimap_layer_visibility_toggle.png` |
| Current artifact | `tests/artifacts/current/minimap/minimap_markers_objects_pings.png` |
| Current artifact | `tests/artifacts/current/minimap/minimap_paths_and_overlay_shapes.png` |
| Current artifact | `tests/artifacts/current/minimap/minimap_province_registry_compact.png` |
| Current artifact | `tests/artifacts/current/minimap/minimap_shader_binding_contract.txt` |
| Current artifact | `tests/artifacts/current/minimap/minimap_shader_visual_01_ownership_heat.png` |
| Current artifact | `tests/artifacts/current/minimap/minimap_shader_visual_02_fog_of_war.png` |
| Current artifact | `tests/artifacts/current/minimap/minimap_shader_visual_03_radar_scan.png` |
| Current artifact | `tests/artifacts/current/minimap/minimap_terrain_palette_grid.png` |
| Current artifact | `tests/artifacts/current/minimap/minimap_tilefield_layers.png` |
| Current artifact | `tests/artifacts/current/minimap/minimap_viewport_rect.png` |
| Current artifact | `tests/artifacts/current/minimap/minimap_visibility_fog_action.png` |
| Baseline artifact | `tests/artifacts/baselines/minimap/minimap_fog_states.png` |
| Baseline artifact | `tests/artifacts/baselines/minimap/minimap_layer_blend_modes.png` |
| Baseline artifact | `tests/artifacts/baselines/minimap/minimap_layer_visibility_toggle.png` |
| Baseline artifact | `tests/artifacts/baselines/minimap/minimap_markers_objects_pings.png` |
| Baseline artifact | `tests/artifacts/baselines/minimap/minimap_paths_and_overlay_shapes.png` |
| Baseline artifact | `tests/artifacts/baselines/minimap/minimap_province_registry_compact.png` |
| Baseline artifact | `tests/artifacts/baselines/minimap/minimap_terrain_palette_grid.png` |
| Baseline artifact | `tests/artifacts/baselines/minimap/minimap_tilefield_layers.png` |
| Baseline artifact | `tests/artifacts/baselines/minimap/minimap_viewport_rect.png` |
| Baseline artifact | `tests/artifacts/baselines/minimap/minimap_visibility_fog_action.png` |

## Architecture Links

- Intentionally empty.

## Notes

- `minimap` is a passive compact visualization layer. It should not compute movement, line-of-sight, line-of-action, or tile lighting.
- For tilefield-driven games, feed minimap terrain/fog/overlay data from `LTileField:exportProfileLayer`, `LTileField:exportBlockLayer`, `LTileField:exportRefLayer`, `LTileLightMap:exportLayer`, and `LTileAwareness:*` outputs.
- Existing raycaster or tilemap helpers are passive adapters; they should not become gameplay authorities for blockers, visibility, or lighting.
- Construction is strict: zero grid dimensions, zero display dimensions, overflowed cell counts, and oversized display buffers are rejected before the minimap is created.
- Bulk terrain and fog loads use exact-length validation on the Lua-facing API so stale cells are not silently mixed with fresh data.
- Grid/display transforms require finite coordinates, a finite positive zoom, and positive display dimensions; invalid transform state returns nils for `screenToGrid` and `gridToScreen` instead of leaking NaN or Inf into callers.
- Layer payloads are grid-shaped contracts: `width` and `height` must match the minimap grid, cell payload length must match `width * height`, and active-layer switches are only valid for populated layers.
- Layer presentation belongs to `minimap`: raw layer values can be recolored, alpha-blended, hidden, shown, and composed through explicit blend modes without forcing producer modules to duplicate minimap rendering policy.
- `library.tilefield_minimap` is the reference adapter for tilefield and tilelight exports: it copies blocker, cost, ref, and computed-light layers into minimap raw data layers while keeping producers independent from minimap and leaving visual policy on `LMinimap`.
- `library.awareness_minimap` is the reference adapter for `LTileAwareness`: it copies visible/explored masks into minimap fog data and actionable or visible masks into styled raw layers without making minimap compute line-of-sight.
- `drawToImage(pixel_size)` now honors `pixel_size` when provided, falls back to the configured display size when `pixel_size == 0`, and covers the full output image even when display pixels do not divide evenly by grid size.
- Render-command generation batches adjacent same-color cells into horizontal runs and exposes debug stats through `Minimap::render_stats(screen_x, screen_y)` for tooling and regression tests.
- `LMinimap:setShader(shaderOrNil)` accepts only `mapviz` shaders created by `lurek.render.newShader`. The minimap stores only the shader handle and wraps command-rendered output in render-owned shader state. `drawToImage` remains deterministic CPU export and does not execute the shader; callers that need offline GPU bitmap processing should apply an `image` shader to the returned `ImageData`.
- Raycaster minimap extraction uses checked arithmetic for radius, cell size, pixel count, and byte count, and player-arrow drawing validates both width and height against the supplied RGBA buffer length.
- Marker/object/ping/icon setters reject missing ids, invalid type indices, non-finite coordinates, and invalid icon size overrides on the strict Lua path instead of silently no-oping.
