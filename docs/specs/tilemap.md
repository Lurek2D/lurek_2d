<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/tilemap.md or source docstrings instead. -->

# tilemap

## TL;DR

- Supports orthogonal, isometric, and hex grids with sparse culling, LOD, and standard map imports.
- Owns runtime tilemap storage, layers, chunks, tile ids, coordinate conversion, autotiling, and render-command payload generation.
- Provides hex/grid coordinate helpers and polygon/region utilities without owning gameplay legality.
- Safe constructors, bounded importers, and bounded tile operations reject oversized input before allocation-heavy work.
- Tile blockers, movement costs, visibility, fog, action legality, and tile lighting belong to `tilefield`, `pathfind`, `awareness`, and `tilelight`.

## General Info

- Module group: `Feature Systems`
- Source path: `src/tilemap`
- Binding: `src/lua_api/tilemap_api.rs`
- Namespace: `lurek.tilemap`
- Lua API surface: `14` functions, `11` types, `111` methods
- User-facing: `true`
- Plugin tier: `core_keep`

## Summary

- The `tilemap` module is the engine's runtime tile-grid storage and presentation bridge for users who want tile-based spaces to be authored, generated, imported, indexed, and submitted to rendering through one reusable storage model.
- Its value begins with representation. The module gives projects a stable way to describe tile space itself, including orthogonal, isometric, hex-based, layered, large, and chunked interpretations, so different grid styles can still live inside one conceptual family.
- That multi-model support matters because grid worlds are not all alike. A tactics map, an isometric action world, a hex strategy board, and a layered platforming scene all have different adjacency, transform, and draw-order assumptions, yet they still need shared tooling.
- Storage and indexing are only the foundation. Practical tile worlds also require import pipelines, coordinate conversion, tile queries, rendering rules, overlays, and metadata, while traversal semantics live in systems that consume shared data.
- Import support for formats such as TMX or LDtk makes the module useful in authored-content workflows, while generation helpers and block-based assembly support keep it relevant for procedural or hybrid worlds built at runtime.
- Autotiling is also a major user-facing capability because it lets projects derive coherent visual transitions from simpler authored data instead of manually placing every terrain variant.
- Coordinate helpers are central because tile worlds constantly move between grid cells, world positions, screen projections, isometric transforms, hex neighbors, and chunk-local indices, and those conversions must stay consistent.
- Movement blockers, line-of-sight blockers, tile-light blockers, ranges, action masks, and fog are not inferred by `tilemap`; projects materialize those semantics into `tilefield` and run `pathfind`, `awareness`, and `tilelight` independently.
- Isometric and hex support deserve special emphasis because those spaces bring their own neighbor rules, movement assumptions, vertical ordering concerns, and projection logic that should not feel bolted onto a rectangular grid core.
- Large-map and chunk-aware rendering support keep the system practical at scale, where naive whole-map processing would be too expensive or too inflexible.
- Polygon overlays, named regions, and related metadata helpers describe authored areas over the same map, but trigger/event policy stays in Lua or specialized gameplay systems.
- The module is also a bridge between authored content and runtime systems. Maps loaded from external tools, generated chunks, and script-applied overlays can all resolve into one consistent tile-space authority.
- That consistency matters because neighboring modules frequently depend on the exact same tile coordinates for different reasons: `render` needs projection payloads, `pathfind` needs traversability from `tilefield`, and gameplay logic may need regions or author refs.
- It also gives projects a stable place to express tile ids, tile metadata links, adjacency helpers, and region structure without mixing in per-system gameplay state.
- Chunk-aware storage matters beyond performance, because streaming, tooling, and large-world editing all depend on a shared notion of how the map is partitioned.
- That makes `tilemap` useful for drawing terrain and organizing visual tile space, while shared gameplay interpretation is stored in `tilefield`.
- The feature therefore serves as storage and presentation integration: it holds tile IDs and tile-space metadata well enough for the rest of the engine to build on top of it.
- That authority lets authored maps, generated chunks, and runtime overlays remain compatible.
- `pathfind`, `tilelight`, `awareness`, minimap helpers, physics scripts, raycaster, and `render` all consume tile-space in specialized ways, but `tilemap` owns the visual tile grid and coordinate model.
- Read `tilemap` as the engine's authority for visual tilemap storage and tile-world coordinate structure.

This module primarily collaborates with `color`, `image`, `math`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/tilemap`
- Owning tier: `Feature Systems`
- Plugin tier: `core_keep`
- Lua binding owner: `src/lua_api/tilemap_api.rs`
- Referenced engine modules: `math`, `render`, `runtime`, `tilefield`, `tileset`

## Imports

- `math`: Imports or references `src/math/`. Cross-group dependency from `Feature Systems` into `Foundations`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Feature Systems` into `Core Runtime`.
- `tilefield`: Imports or references `src/tilefield/`. Dependency stays inside `Feature Systems` and should remain acyclic.
- `tileset`: Imports or references `src/tileset/`. Dependency stays inside `Feature Systems` and should remain acyclic.

## Source Files

### autotile_sheet.rs

- Defines the autotile sheet model that turns neighborhood bitmasks into final atlas tile selections.
- Owns supported autotile layouts and the shared contract used by different terrain or border art styles.
- Centralizes bitmask interpretation so terrain seam logic stays in one graphics-selection owner.
- Resolves corner and edge relationships carefully so transitions remain visually clean across map joins.
- Supports quarter-tile composition for layouts that assemble one final tile from smaller atlas regions.
- Bridges tileset geometry with adjacency rules instead of mixing autotile policy into general map storage.
- Open this file when terrain transitions, mask lookup, or autotile atlas mapping behaves incorrectly.

### chunk.rs

- Owns the chunk owner for the tilemap subsystem and keeps its rules local to this file while keeping call sites explicit.
- Centers the implementation around ChunkMap, DEFAULT_GID, new, with helpers kept close to their invariants.
- Defines how chunk data is validated, transformed, or stored before neighboring systems use it.
- Owns tilemap behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on chunk behavior while Lua registration stays elsewhere.
- Documents the boundary where tilemap code accepts inputs, reports errors, or updates state.

### coords.rs

- This file owns coords behavior inside the tilemap subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate coords state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.

### error.rs

- This file owns error behavior inside the tilemap subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate error state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
- Public functions in this file are the stable entry points other modules should use for error work.
- Serialization, indexing, and boundary checks stay here when they depend on error internals.

### isomap.rs

- Defines a multi-level isometric map model where each tile can carry separate floor, wall, and object parts.
- Maps tile coordinates into diamond-projected screen placement so isometric draw order stays coherent.
- Iterates diagonal draw order to make elevation layering and overlap read correctly during presentation.
- Lets each level be shown or hidden, which supports staged reveals and editor-style focused inspection.
- Keeps part ordering configurable so floor, wall, and object composition can vary by project needs.
- Acts as the isometric-map boundary instead of forcing the general orthogonal TileMap owner to absorb it.
- Open this file when iso level stacking, tile part ordering, or projected draw ordering looks incorrect.

### large_map_renderer.rs

- Owns chunk-oriented rendering support for tilemaps that are too large for one monolithic redraw strategy.
- Partitions the full grid into fixed chunks with dirty tracking so small edits trigger only local refresh work.
- Uses camera and viewport state to cull at chunk granularity before generating tile-oriented draw output.
- Supports per-tile mutation with automatic invalidation so edits stay localized across large-world scenes.
- Optionally reduces detail with zoom-aware logic to keep massive maps responsive during interactive viewing.
- Open this file when chunk invalidation, visible-chunk culling, or large-map redraw performance is wrong.

### ldtk.rs

- Loads LDtk JSON content into the engine tilemap model while rebuilding the geometry and layer data it needs.
- Parses levels and tile layers, then converts pixel placements into stable grid-cell coordinates for runtime use.
- Keeps external LDtk import rules separate from TMX and procedural paths so format-specific failures stay local.
- Acts as the LDtk boundary between authored project files and the engine layered tilemap representation.
- Open this file when LDtk levels, layer placement, or imported tileset reconstruction behaves incorrectly.

### limits.rs

- This file owns limits behavior inside the tilemap subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate limits state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
- Public functions in this file are the stable entry points other modules should use for limits work.

### mod.rs

- This module index owns the public shape of the tilemap subsystem and its source navigation map.
- It declares which sibling files participate in tilemap behavior and which names are reexported outward.
- Reexports here are intentionally narrow so callers do not depend on private implementation modules.
- Agents should start here to understand subsystem boundaries before opening deeper implementation files.
- New submodules belong here only when they add durable behavior rather than temporary test scaffolding.
- Keep this index synchronized with specs, examples, and Lua bindings whenever public ownership changes.
- The ordering groups core data, helpers, and rendering-facing pieces so code search stays predictable.
- This file should explain where to navigate next, not repeat details owned by the implementation files.

### orientation.rs

- This file owns orientation behavior inside the tilemap subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate orientation state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.

### render.rs

- This file owns render behavior inside the tilemap subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate render state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
- Public functions in this file are the stable entry points other modules should use for render work.
- Serialization, indexing, and boundary checks stay here when they depend on render internals.
- Renderer, API, and test layers should call through these helpers rather than duplicate private rules.
- Open this file when render ownership changes, but keep unrelated subsystem policy in sibling modules.
- The code favors small data transformations so examples, specs, and tests can assert behavior directly.

### tilemap.rs

- This file owns tilemap behavior inside the tilemap subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate tilemap state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
- Public functions in this file are the stable entry points other modules should use for tilemap work.
- Serialization, indexing, and boundary checks stay here when they depend on tilemap internals.
- Renderer, API, and test layers should call through these helpers rather than duplicate private rules.
- Open this file when tilemap ownership changes, but keep unrelated subsystem policy in sibling modules.
- The code favors small data transformations so examples, specs, and tests can assert behavior directly.
- Stateful changes are kept deterministic here so generated docs and smoke tests remain reproducible.
- Cross-module dependencies are intentionally narrow, with shared types imported only at this boundary.
- This module documents where tilemap data becomes behavior and where surrounding systems take over.

### tilemap_index.rs

- This file owns the reverse-index maintenance helper that maps tile GIDs back to their grid positions.
- The function removes one coordinate from a GID bucket and deletes empty buckets to keep index state compact.
- Open this file when tile lookup bookkeeping changes; map storage and generation logic belong to siblings.

### tmx.rs

- Owns the tmx owner for the tilemap subsystem and keeps its rules local to this file while keeping call sites explicit.
- Keeps tilemap data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how tmx data is validated, transformed, or stored before neighboring systems use it.
- Owns tilemap behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on tmx behavior while Lua registration stays elsewhere.
- Documents the boundary where tilemap code accepts inputs, reports errors, or updates state.
- Use this file when changing tmx defaults, lifecycle handling, validation, or data ownership.
- Keeps failure paths and edge cases near the tilemap state that can explain them while keeping call sites explicit.
- Preserves deterministic behavior by keeping tmx calculations explicit at their owner boundary.



## Lua API Ref

### Functions

- `lurek.tilemap.fromLDtk(jsonStr, levelName?, opts?) -> LTileMap`: Loads a tilemap from an LDtk JSON string, optionally targeting a specific level.
- `lurek.tilemap.fromProvider(provider, opts?) -> LTileMap`: Builds a native tilemap from a Lua provider table with tileWidth, tileHeight, layers, optional tilesets, and optional getTile(layer,x,y).
- `lurek.tilemap.fromScreenHex(sx, sy, size) -> integer`: Converts screen-space pixel coordinates to axial hex coordinates.
- `lurek.tilemap.fromScreenIso(sx, sy, tw, th) -> number`: Converts screen-space coordinates back to tile coordinates for isometric projection.
- `lurek.tilemap.getAutoTileFormats() -> table`: Returns the supported auto-tile sheet layouts and their default matching modes.
- `lurek.tilemap.loadTMX(xml, opts?) -> table`: Parses a TMX (Tiled XML) string and returns a table describing the map structure.
- `lurek.tilemap.newAutoTileSheet(tileW, tileH, layout) -> LAutoTileSheet`: Creates an auto-tile sheet with a given tile size and layout.
- `lurek.tilemap.newChunkMap(chunkSize?, opts?) -> LChunkMap`: Creates a new infinite chunk-based tile map.
- `lurek.tilemap.newIsoMap(width, height, tileW, tileH, levelHeight, partCount?) -> LIsoMap`: Creates a new isometric map with the given dimensions and tile geometry.
- `lurek.tilemap.newLargeMapRenderer(tileW, tileH) -> LLargeMapRenderer`: Creates a chunk-based large-map renderer for efficient rendering of very large maps.
- `lurek.tilemap.newTileMap(tileWidth, tileHeight, chunkSize?, opts?) -> LTileMap`: Creates a new empty tilemap with the given tile dimensions.
- `lurek.tilemap.newTileSet() -> nil`: Compatibility alias for `lurek.tileset.newTileSet`.
- `lurek.tilemap.toScreenHex(q, r, size) -> number`: Converts axial hex coordinates to screen-space pixel position.
- `lurek.tilemap.toScreenIso(tx, ty, tw, th) -> number`: Converts tile coordinates to screen-space position for isometric projection.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LAutoTileSheet Type

- Lua-side handle wrapping an `AutoTileSheet` that maps bitmasks to tile quads for auto-tiling.

##### Fields

- No documented fields.

##### Methods

- `LAutoTileSheet:applyToTileSet(tileSet, typeName, startGid?) -> nil`: Writes the auto-tile bitmask-to-tile rules from this sheet into a tileset.
- `LAutoTileSheet:getBitmaskForTile(tileId) -> integer`: Returns the bitmask associated with a tile in this auto-tile sheet.
- `LAutoTileSheet:getDefaultMode() -> string`: Returns the default neighbor matching mode for this auto-tile sheet layout.
- `LAutoTileSheet:getLayout() -> string`: Returns the auto-tile layout type as a string.
- `LAutoTileSheet:getQuad(tileId) -> integer`: Returns the source rectangle for a tile in the auto-tile sheet.
- `LAutoTileSheet:getTileCount() -> integer`: Returns the total number of tiles in this auto-tile sheet.
- `LAutoTileSheet:getTileForBitmask(bitmask) -> integer`: Looks up which tile corresponds to a given bitmask value.
- `LAutoTileSheet:getTileHeight() -> integer`: Returns the height of each tile in the auto-tile sheet, in pixels.
- `LAutoTileSheet:getTileWidth() -> integer`: Returns the width of each tile in the auto-tile sheet, in pixels.
- `LAutoTileSheet:type() -> string`: Returns the type name of this userdata.
- `LAutoTileSheet:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LChunkMap Type

- Lua-side handle wrapping a `ChunkMap` for infinite or very large tile grids stored in dynamically loaded chunks.

##### Fields

- No documented fields.

##### Methods

- `LChunkMap:chunkTileRange(cx, cy) -> integer`: Returns the tile-coordinate range covered by a specific chunk.
- `LChunkMap:clearTile(x, y) -> nil`: Removes the tile at the given world-tile coordinate.
- `LChunkMap:fillRect(x0, y0, x1, y1, gid) -> nil`: Fills a rectangular region of tiles with a given GID.
- `LChunkMap:getChunkSize() -> integer`: Returns the size of each chunk in tiles per side.
- `LChunkMap:getChunksInView(vx, vy, vw, vh, tw, th) -> table`: Returns chunk coordinates that overlap a viewport region, given tile dimensions.
- `LChunkMap:getLoadedChunks() -> table`: Returns a list of all currently loaded chunk coordinates.
- `LChunkMap:getTile(x, y) -> integer`: Returns the tile GID at the given world-tile coordinate.
- `LChunkMap:loadChunk(cx, cy) -> nil`: Loads a chunk into memory at the given chunk coordinates.
- `LChunkMap:setTile(x, y, gid) -> nil`: Sets the tile GID at the given world-tile coordinate.
- `LChunkMap:type() -> string`: Returns the type name of this userdata.
- `LChunkMap:typeOf(name) -> boolean`: Checks whether this object matches the given type name.
- `LChunkMap:unloadChunk(cx, cy) -> nil`: Unloads a chunk from memory at the given chunk coordinates.

#### LChunkMapGetChunksInViewResult Type

- Generated result shape from @field tags.

##### Fields

- `cx` (`integer`): Cx.
- `cy` (`integer`): Cy.

##### Methods

- No documented methods.

#### LChunkMapGetLoadedChunksResult Type

- Generated result shape from @field tags.

##### Fields

- `cx` (`integer`): Cx.
- `cy` (`integer`): Cy.

##### Methods

- No documented methods.

#### LIsoMap Type

- Lua-side handle wrapping an `IsoMap` for isometric tile rendering with multi-level support and configurable part ordering.

##### Fields

- No documented fields.

##### Methods

- `LIsoMap:addLevel() -> integer`: Adds a new vertical level to the isometric map and returns its index.
- `LIsoMap:fillLevel(z, part, gid) -> nil`: Fills all tiles on a level for a given part with a single GID.
- `LIsoMap:getHeight() -> integer`: Returns the map height in tiles. This method is available to Lua scripts.
- `LIsoMap:getLevelCount() -> integer`: Returns the number of vertical levels in the isometric map.
- `LIsoMap:getLevelHeight() -> integer`: Returns the vertical pixel offset between levels.
- `LIsoMap:getPartCount() -> integer`: Returns the number of tile parts per cell.
- `LIsoMap:getPartOrder() -> integer[]`: Returns the rendering order of tile parts as an array of part indices.
- `LIsoMap:getTileHeight() -> integer`: Returns the height of an isometric tile in pixels.
- `LIsoMap:getTilePart(z, x, y, part) -> integer`: Returns the GID for a specific part of a tile at a given position and level.
- `LIsoMap:getTileWidth() -> integer`: Returns the width of an isometric tile in pixels.
- `LIsoMap:getWidth() -> integer`: Returns the map width in tiles. This method is available to Lua scripts.
- `LIsoMap:isLevelVisible(z) -> boolean`: Returns whether a vertical level is currently visible.
- `LIsoMap:screenToTile(sx, sy) -> number`: Converts screen-space pixel coordinates to tile-grid coordinates (ignoring Z).
- `LIsoMap:setLevelVisible(z, visible) -> nil`: Sets whether a vertical level is drawn during rendering.
- `LIsoMap:setOrigin(x, y) -> nil`: Sets the screen-space origin (top-left anchor) for isometric rendering.
- `LIsoMap:setPartOrder(order) -> nil`: Overrides the rendering order of tile parts.
- `LIsoMap:setTilePart(z, x, y, part, gid) -> nil`: Sets the GID for a specific part of a tile at a given position and level.
- `LIsoMap:tileToScreen(tx, ty, tz) -> number`: Converts tile-grid coordinates to screen-space pixel position.
- `LIsoMap:type() -> string`: Returns the type name of this userdata.
- `LIsoMap:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LLargeMapRenderer Type

- Lua-side handle wrapping a `LargeMapRenderer` for chunk-based rendering of very large tile maps with LOD support.

##### Fields

- No documented fields.

##### Methods

- `LLargeMapRenderer:getChunkSize() -> integer`: Returns the current chunk size. This method is available to Lua scripts.
- `LLargeMapRenderer:getMapSize() -> integer`: Returns the map dimensions in tiles.
- `LLargeMapRenderer:getTile(x, y) -> integer`: Returns the tile GID at a given position.
- `LLargeMapRenderer:getTilesetColumns() -> integer`: Returns the tileset column count used for UV calculation.
- `LLargeMapRenderer:getTotalChunks() -> integer`: Returns the total number of chunks in the map.
- `LLargeMapRenderer:getVisibleChunks() -> integer`: Returns the number of chunks currently visible in the viewport.
- `LLargeMapRenderer:invalidateAll() -> nil`: Marks all chunks as dirty, forcing a full rebuild on the next render.
- `LLargeMapRenderer:invalidateChunk(cx, cy) -> nil`: Marks a specific chunk as dirty so it will be rebuilt on the next render.
- `LLargeMapRenderer:isLodEnabled() -> boolean`: Returns whether LOD rendering is currently enabled.
- `LLargeMapRenderer:setCamera(x, y, zoom) -> nil`: Sets the camera position and zoom level for determining visible chunks.
- `LLargeMapRenderer:setChunkSize(size) -> nil`: Sets the chunk size used for rendering subdivision.
- `LLargeMapRenderer:setLodEnabled(enabled) -> nil`: Enables or disables level-of-detail rendering for distant chunks.
- `LLargeMapRenderer:setLodThresholds(levels) -> nil`: Sets the zoom thresholds at which LOD levels change.
- `LLargeMapRenderer:setMapData(data, width, height) -> nil`: Replaces all tile data with a flat array of GIDs for the given dimensions.
- `LLargeMapRenderer:setTile(x, y, tileId) -> nil`: Sets a single tile GID at a given position.
- `LLargeMapRenderer:setTilesetColumns(cols) -> nil`: Sets the column count of the associated tileset atlas for UV calculation.
- `LLargeMapRenderer:setViewport(w, h) -> nil`: Sets the viewport rectangle used for render-command culling.
- `LLargeMapRenderer:type() -> string`: Returns the type name of this userdata.
- `LLargeMapRenderer:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LTileMap Type

- Lua-side handle wrapping a `TileMap` with layers, tile data, viewports, auto-tiling, and render command output.

##### Fields

- No documented fields.

##### Methods

- `LTileMap:addLayer(name, w, h) -> integer`: Creates a new tile layer with the given name and dimensions.
- `LTileMap:addTileSet(tileSet) -> nil`: Attaches a tileset to this map for tile rendering.
- `LTileMap:applyAutoTile(layer, typeName) -> nil`: Runs 4-bit auto-tiling on an entire layer, replacing tiles according to registered rules.
- `LTileMap:applyAutoTile8(layer, typeName) -> nil`: Runs 8-bit auto-tiling on an entire layer, considering diagonal neighbors.
- `LTileMap:applyAutoTile8At(layer, x, y, typeName) -> nil`: Runs 8-bit auto-tiling at a single tile position and updates it and its neighbors.
- `LTileMap:applyAutoTileAt(layer, x, y, typeName) -> nil`: Runs 4-bit auto-tiling at a single tile position and updates it and its neighbors.
- `LTileMap:applyAutoTileMode(layer, typeName) -> nil`: Runs auto-tiling on an entire layer using the mode configured on the matching tileset.
- `LTileMap:applyAutoTileModeAt(layer, x, y, typeName) -> nil`: Runs configured-mode auto-tiling at a single tile position and updates it and its neighbors.
- `LTileMap:clearTile(layer, x, y) -> nil`: Removes the tile at a specific grid position, setting it to empty (GID 0).
- `LTileMap:fill(layer, gid) -> nil`: Fills every cell of a layer with the given GID.
- `LTileMap:findTilesByGid(layer, gid) -> table`: Returns all positions on a layer that contain a specific GID.
- `LTileMap:getChunkSize() -> integer`: Returns the chunk size used for internal tile storage.
- `LTileMap:getDiagnostics() -> nil`: Returns tilemap diagnostics counters for invalid calls, unknown gids, and lazy index rebuilds.
- `LTileMap:getLayerColor(idx) -> number`: Returns the tint color of a layer as four RGBA components.
- `LTileMap:getLayerCount() -> integer`: Returns the total number of layers in this map.
- `LTileMap:getLayerName(idx) -> string`: Returns the name of a layer by index.
- `LTileMap:getLayerOffset(idx) -> number`: Returns the pixel offset of a layer.
- `LTileMap:getLayerParallax(idx) -> number`: Returns the parallax scroll factor of a layer.
- `LTileMap:getLayerVisible(idx) -> boolean`: Returns whether a layer is currently visible.
- `LTileMap:getOrientation() -> string`: Returns the current map orientation as a string.
- `LTileMap:getTile(layer, x, y) -> integer`: Returns the tile GID at a specific grid position on a layer.
- `LTileMap:getTileDimensions() -> integer`: Returns both tile width and height in pixels.
- `LTileMap:getTileHeight() -> integer`: Returns the height of a single tile in pixels for this map.
- `LTileMap:getTileSet(idx) -> LTileSet`: Returns the tileset at the given index.
- `LTileMap:getTileSetCount() -> integer`: Returns how many tilesets are attached to this map.
- `LTileMap:getTileWidth() -> integer`: Returns the width of a single tile in pixels for this map.
- `LTileMap:getViewport() -> number`: Returns the current viewport rectangle, or nils if none is set.
- `LTileMap:render(ox?, oy?) -> nil`: Submits render commands for all visible tiles, optionally offset by a scroll position.
- `LTileMap:renderFieldCatalogSlot(field, catalog, opts) -> nil`: Renders typed refs from a tilefield slot through a tileset catalog.
- `LTileMap:renderFieldSlot(field, tileset, opts) -> nil`: Renders objects referenced from a tilefield slot using tileset object visuals.
- `LTileMap:setLayerColor(idx, r, g, b, a) -> nil`: Sets the tint color for an entire layer.
- `LTileMap:setLayerOffset(idx, ox, oy) -> nil`: Sets the pixel offset for a layer, shifting all tiles during rendering.
- `LTileMap:setLayerParallax(idx, px, py) -> nil`: Sets the parallax scroll factor for a layer. Values less than 1 scroll slower than the camera.
- `LTileMap:setLayerVisible(idx, visible) -> nil`: Sets whether a layer is drawn during rendering.
- `LTileMap:setOrientation(orientation) -> nil`: Sets the map orientation, affecting coordinate transforms and rendering.
- `LTileMap:setTile(layer, x, y, gid) -> nil`: Sets the tile GID at a specific grid position on a layer.
- `LTileMap:setTileTint(layer, x, y, r, g, b, a) -> nil`: Overrides the color tint for a single tile at a given position.
- `LTileMap:setViewport(x, y, w, h) -> nil`: Sets the visible area of the map for culling during rendering.
- `LTileMap:tileToWorld(tx, ty) -> number`: Converts tile-grid coordinates to world-space pixel coordinates (top-left corner of the tile).
- `LTileMap:tileTypeIndex(layer) -> table`: Builds an index mapping each GID present on a layer to an array of `{x, y}` positions.
- `LTileMap:tryAddLayer(name, w, h) -> integer`: Creates a new tile layer and returns `nil, error` instead of throwing on invalid dimensions or layer limits.
- `LTileMap:tryGetTile(layer, x, y) -> integer`: Returns the tile GID at a specific grid position, or `nil, error` when the layer or coord is invalid.
- `LTileMap:trySetTile(layer, x, y, gid) -> boolean`: Sets a tile and returns `false, error` instead of throwing on invalid layer or coordinate input.
- `LTileMap:trySetTileTint(layer, x, y, r, g, b, a) -> boolean`: Sets a per-cell tint override and returns `false, error` instead of throwing on invalid input.
- `LTileMap:tryWorldToTile(wx, wy) -> integer`: Converts world-space pixel coordinates to tile-grid coordinates, returning nils for negative or non-finite input.
- `LTileMap:type() -> string`: Returns the type name of this userdata.
- `LTileMap:typeOf(name) -> boolean`: Checks whether this object matches the given type name.
- `LTileMap:update(dt) -> nil`: Advances tile animations by the given delta time.
- `LTileMap:worldToTile(wx, wy) -> integer`: Converts world-space pixel coordinates to tile-grid coordinates.

#### LTileMapFindTilesByGidResult Type

- Generated result shape from @field tags.

##### Fields

- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LTileMapTileTypeIndexResult Type

- Generated result shape from @field tags.

##### Fields

- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LTilemapFromLDtkResult Type

- Generated result shape from @field tags.

##### Fields

- `code` (`string`): Stable machine-readable error code.
- `column` (`integer?`): Always nil for LDtk parser errors.
- `format` (`string`): Source format identifier (`"ldtk"`).
- `line` (`integer?`): Always nil for LDtk parser errors.
- `message` (`string`): Human-readable parser message.

##### Methods

- No documented methods.

#### LTilemapLoadTMXResult Type

- Generated result shape from @field tags.

##### Fields

- `code` (`string`): Stable machine-readable error code.
- `column` (`integer?`): 1-based source column when available.
- `format` (`string`): Source format identifier (`"tmx"`).
- `height` (`number`): Height.
- `layers` (`table`): Layers array.
- `line` (`integer?`): 1-based source line when available.
- `message` (`string`): Human-readable parser message.
- `orientation` (`string`): Map orientation.
- `tileHeight` (`integer`): Tile height in pixels.
- `tileWidth` (`integer`): Tile width in pixels.
- `width` (`number`): Width.

##### Methods

- No documented methods.

## Examples

- `content/examples/tilemap.lua` (present)

## Tests

- Lua unit: `tests/lua/unit/test_tilemap_unit.lua` (present)
- Rust: `src/tilemap/tilemap_index.rs`
- Rust: `tests/rust/unit/tilemap_tests.rs`

## Evidence / Golden

| Kind | Path |
|---|---|
| Evidence test | `tests/lua/evidence/test_tilemap_evidence.lua` |
| Golden test | `tests/lua/golden/test_tilemap_golden.lua` |
| Current artifact | `tests/artifacts/current/tilemap/tilemap_autotile.png` |
| Current artifact | `tests/artifacts/current/tilemap/tilemap_autotile_format_showcase.png` |
| Current artifact | `tests/artifacts/current/tilemap/tilemap_autotile_format_showcase.txt` |
| Current artifact | `tests/artifacts/current/tilemap/tilemap_chunk_streaming_window.png` |
| Current artifact | `tests/artifacts/current/tilemap/tilemap_collision.png` |
| Current artifact | `tests/artifacts/current/tilemap/tilemap_draw_to_image_ground.png` |
| Current artifact | `tests/artifacts/current/tilemap/tilemap_draw_to_image_objects.png` |
| Current artifact | `tests/artifacts/current/tilemap/tilemap_hex_biomes_area.png` |
| Current artifact | `tests/artifacts/current/tilemap/tilemap_hex_neighbors.png` |
| Current artifact | `tests/artifacts/current/tilemap/tilemap_hex_operations_frontier.png` |
| Current artifact | `tests/artifacts/current/tilemap/tilemap_hex_route.png` |
| Current artifact | `tests/artifacts/current/tilemap/tilemap_isometric.png` |
| Current artifact | `tests/artifacts/current/tilemap/tilemap_isometric_stacked_settlement.png` |
| Current artifact | `tests/artifacts/current/tilemap/tilemap_layers.png` |
| Current artifact | `tests/artifacts/current/tilemap/tilemap_viewport.png` |
| Baseline artifact | `tests/artifacts/baselines/tilemap/tilemap_autotile.png` |
| Baseline artifact | `tests/artifacts/baselines/tilemap/tilemap_autotile_format_showcase.png` |
| Baseline artifact | `tests/artifacts/baselines/tilemap/tilemap_autotile_format_showcase.txt` |
| Baseline artifact | `tests/artifacts/baselines/tilemap/tilemap_chunk_streaming_window.png` |
| Baseline artifact | `tests/artifacts/baselines/tilemap/tilemap_collision.png` |
| Baseline artifact | `tests/artifacts/baselines/tilemap/tilemap_draw_to_image_ground.png` |
| Baseline artifact | `tests/artifacts/baselines/tilemap/tilemap_draw_to_image_objects.png` |
| Baseline artifact | `tests/artifacts/baselines/tilemap/tilemap_hex_biomes_area.png` |
| Baseline artifact | `tests/artifacts/baselines/tilemap/tilemap_hex_neighbors.png` |
| Baseline artifact | `tests/artifacts/baselines/tilemap/tilemap_hex_operations_frontier.png` |
| Baseline artifact | `tests/artifacts/baselines/tilemap/tilemap_hex_route.png` |
| Baseline artifact | `tests/artifacts/baselines/tilemap/tilemap_isometric.png` |
| Baseline artifact | `tests/artifacts/baselines/tilemap/tilemap_isometric_stacked_settlement.png` |
| Baseline artifact | `tests/artifacts/baselines/tilemap/tilemap_layers.png` |
| Baseline artifact | `tests/artifacts/baselines/tilemap/tilemap_viewport.png` |

## Architecture Links

- Intentionally empty.

## Notes

- `tilemap` owns map storage, layers, chunks, tile ids, orientation/projection metadata, imports/exports, draw helpers, and tile-coordinate utilities.
- Tile gameplay semantics such as movement blockers, vision/action blockers, and tile-light blockers belong in `tilefield` when a project needs one shared source of truth.
- `LTileSet` owns atlas-local tile metadata: visual source rectangles, animation, autotile rules, optional profile names, optional physics-shape names, and arbitrary author properties. Sprite atlases own image regions; tileset metadata explains what a tile id means.
- Tileset profile names are lightweight links into `tilefield` profiles. They do not make `tilemap` depend on `tilefield`, and they do not duplicate full movement, vision, action, or light costs inside the atlas object.
- `lurek.tilefield.fromTileMap(tilemap, opts)` copies tilemap state into a field snapshot. It only applies movement blockers from explicit `solidGids`; it does not infer solidity from the tileset. Later tilemap edits are not automatically synchronized unless the adapter is called again.
- `lurek.tilemap.newTileMap(...)` and `lurek.tilemap.newChunkMap(...)` accept an optional limits table with ceilings such as `maxLayers`, `maxTiles`, `maxImportBytes`, `maxDecodedBytes`, `maxChunkCells`, `maxChunks`, and `maxTileOperationCells`.
- `lurek.tilemap.loadTMX(xml, opts)` supports strict/bounded import policy through `strictLayerSize`, `allowExternalTilesets`, `safePaths`, `assetRoot`, and the same byte/size limits used by safe constructors.
- `LTileMap:worldToTile(...)` preserves legacy clamping semantics, while `LTileMap:tryWorldToTile(...)` returns `nil` for negative or non-finite world coordinates and should be preferred for picking front-ends.
- Reverse tile-position indexing is lazy after large writes such as `fill(...)`; callers that need dense reverse lookups should use `tileTypeIndex(...)` or `findTilesByGid(...)` and can inspect `getDiagnostics().lazyIndexRebuilds`.
- Diagnostics counters are part of the public debugging contract: invalid layer access, invalid coordinates, invalid coordinate queries, unknown gids, and lazy reverse-index rebuilds are observable through `LTileMap:getDiagnostics()`.
