# tilemap

## TL;DR

- Supports orthogonal, isometric, and hex grids with sparse culling, LOD, and standard map imports.
- Features autotiling, procedural generation, swept rect collisions, and pathfind navgrids.
- Provides hex rings, polygon trigger zones, and event callbacks for entity transitions.
- Safe constructors, bounded importers, and checked collision queries reject oversized or invalid inputs before allocation-heavy work.
- Treats `rectOverlapsSolid`/`sweepRect` as tile-grid collision queries; physics bodies still require their own `lurek.physics` colliders and sync flow.

## General Info

- Module group: `Feature Systems`
- Source path: `src/tilemap/`
- Binding: `src/lua_api/tilemap_api.rs`
- Namespace: `lurek.physics`
- Lua API surface: `30` functions, `23` types, `173` methods
- Rust test path(s): tests/rust/unit/tilemap_tests.rs
- Lua test path(s): tests/lua/unit/test_tilemap_core_unit.lua, tests/lua/stress/test_tilemap_stress.lua, tests/lua/integration/test_tilemap_physics.lua, tests/lua/integration/test_tilemap_pathfind.lua, tests/lua/integration/test_tilemap_camera.lua, tests/lua/integration/test_save_tilemap.lua, tests/lua/integration/test_procgen_tilemap.lua, tests/lua/golden/test_tilemap_golden.lua, tests/lua/evidence/test_evidence_tilemap.lua

## Summary

- The `tilemap` module is the engine's full grid-world framework for users who want tile-based spaces to be authored, generated, rendered, queried, and traversed through one reusable system rather than through several disconnected helpers.
- Its value begins with representation. The module gives projects a stable way to describe tile space itself, including orthogonal, isometric, hex-based, layered, large, and chunked interpretations, so different grid styles can still live inside one conceptual family.
- That multi-model support matters because grid worlds are not all alike. A tactics map, an isometric action world, a hex strategy board, and a layered platforming scene all have different adjacency, transform, and draw-order assumptions, yet they still need shared tooling.
- Storage and indexing are only the foundation. Practical tile worlds also require import pipelines, coordinate conversion, tile queries, collision helpers, rendering rules, overlays, metadata, and traversal semantics, and this module keeps those concerns together.
- Import support for formats such as TMX or LDtk makes the module useful in authored-content workflows, while generation helpers and block-based assembly support keep it relevant for procedural or hybrid worlds built at runtime.
- Autotiling is also a major user-facing capability because it lets projects derive coherent visual transitions from simpler authored data instead of manually placing every terrain variant.
- Coordinate helpers are central because tile worlds constantly move between grid cells, world positions, screen projections, isometric transforms, hex neighbors, and chunk-local indices, and those conversions must stay consistent.
- Collision and sweep-style queries are a major practical feature. A tile world should be directly searchable for blocked cells, traversable neighbors, hits, ranges, or occupancy questions without escalating every problem into full rigid-body simulation.
- Isometric and hex support deserve special emphasis because those spaces bring their own neighbor rules, movement assumptions, vertical ordering concerns, and projection logic that should not feel bolted onto a rectangular grid core.
- Large-map and chunk-aware rendering support keep the system practical at scale, where naive whole-map processing would be too expensive or too inflexible.
- Polygon overlays, named regions, and related metadata helpers extend the feature from geometry into gameplay space by letting designers describe areas, triggers, provinces, and semantic regions layered over the same map.
- The module is also a bridge between authored content and runtime systems. Maps loaded from external tools, generated chunks, and script-applied overlays can all resolve into one consistent tile-space authority.
- That consistency matters because neighboring modules frequently depend on the exact same tile coordinates for different reasons: pathfinding needs traversability, render needs projection, and gameplay logic needs regions, triggers, or occupancy.
- It also gives projects a stable place to express tile metadata, adjacency, and region semantics without scattering that meaning across several helper layers.
- Chunk-aware storage matters beyond performance, because streaming, tooling, and large-world editing all depend on a shared notion of how the map is partitioned.
- That makes `tilemap` useful not only for drawing terrain, but also for organizing the world model that several other modules stand on.
- The feature therefore serves as both storage and interpretation: it does not merely hold tile IDs, it defines what tile-space means well enough for the rest of the engine to build on top of it.
- That authority lets authored maps, generated chunks, and runtime overlays remain compatible.
- `pathfind`, `physics`, `raycaster`, and `render` all consume tile-space in specialized ways, but `tilemap` owns what the grid world fundamentally is.
- Read `tilemap` as the engine's main authority for tile space and tile-world structure.

This module primarily collaborates with `color`, `image`, `math`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Imports

- `color`: Imports or references `src/color/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `math` from `src/math/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### autotile_sheet.rs

- Defines the autotile sheet model that turns neighborhood bitmasks into final atlas tile selections.
- Owns supported autotile layouts and the shared contract used by different terrain or border art styles.
- Centralizes bitmask interpretation so terrain seam logic stays in one graphics-selection owner.
- Resolves corner and edge relationships carefully so transitions remain visually clean across map joins.
- Supports quarter-tile composition for layouts that assemble one final tile from smaller atlas regions.
- Bridges tileset geometry with adjacency rules instead of mixing autotile policy into general map storage.
- Open this file when terrain transitions, mask lookup, or autotile atlas mapping behaves incorrectly.

### chunk.rs

- Implements sparse chunk storage for very large tile worlds that should not allocate one full dense grid.
- Keeps world-to-chunk and local-cell transforms precise so reads, writes, and clears hit stable addresses.
- Provides visible-chunk queries and range updates used by streaming, culling, and large-map maintenance paths.
- Acts as the storage boundary between raw world tile access and higher-level render or generation systems.
- Open this file when chunk loading, addressing, fill ranges, or visible-region selection behaves incorrectly.

### coords.rs

- Provides coordinate transforms for isometric and hex grids shared by map rendering, pathing, and range tools.
- Converts between screen space, grid space, and directional labels so systems use one geometric language.
- Supplies rotation, neighbor, line, ring, and spiral helpers needed by hex navigation and selection logic.
- Keeps orientation-specific math out of map storage owners so projection changes stay locally auditable.
- Open this file when iso or hex coordinate conversion, direction naming, or grid metric math is wrong.

### error.rs

- Owns typed validation and safety errors shared by tilemap constructors, queries, and import helpers.
- It keeps failure reasons explicit so safe `try_*` APIs can reject invalid dimensions, limits, and paths consistently.
- Open this file when tilemap callers need clearer diagnostics or when a new tilemap owner joins the shared safety contract.

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

- Owns shared tilemap sizing and validation limits used by safe constructors, importers, and bounded queries.
- It centralizes checked arithmetic and default safety ceilings so tilemap owners share one resource policy.
- Open this file when tilemap budgets or query guards change across storage, rendering, and importer code.

### mapgen.rs

- Implements scripted procedural tilemap generation built from reusable blocks, groups, and step sequences.
- Models block edges and matching rules so assembled regions connect with coherent boundaries and orientations.
- Groups reusable content into named palettes that let projects target distinct world styles with one runtime.
- Defines fill, place, scatter, flood, carve, and related generation steps under one deterministic script owner.
- Uses seeded randomness so outputs remain repeatable for tests, content iteration, and offline batch generation.
- Supports both single-map and multi-region production with independent seeds and layered write strategies.
- Applies zone, side, and orientation metadata so downstream rendering and gameplay read generated maps correctly.
- Controls how writes land on layers, allowing unified or split composition without duplicating generation logic.
- Acts as the procedural-authoring boundary instead of pushing rule assembly into the base map storage type.
- Open this file when generation scripts, edge matching, seeded outputs, or layered placement behave incorrectly.

### mapgen_model.rs

- Defines the core map-generation model types, especially cardinal edges used by block matching and adjacency rules.
- Provides string conversion for edge values so config parsing and persistence share one canonical representation.
- Open this file when procedural edge semantics or serialized edge naming stops matching generator expectations.

### mod.rs

- Exports the tilemap subsystem surface that combines storage, import, generation, geometry, and render helpers.
- Acts as the ownership index for tile worlds so callers can see where chunks, tilesets, maps, and importers live.
- Centralizes module visibility and re-exports instead of storing live map data or running generation itself.
- Connects authored formats, autotiling, region maps, large-map helpers, and base tile storage into one stack.
- Provides the first navigation point when tracing whether a tile concern belongs to import, storage, or rendering.
- Keeps the public tilemap surface coherent while allowing specialized owners like isomap or TMX to stay narrow.
- Open this file first when adding a tilemap owner or changing re-export policy for shared tilemap APIs.
- Use it to map a tile feature to its concrete Rust owner before editing storage, import, or render behavior.

### polygon_map.rs

- Owns named polygon regions that overlay tile worlds for provinces, triggers, capture zones, or selection areas.
- Stores vertex lists, fill colors, labels, and shared outline styling so region presentation stays consistent.
- Implements point-in-polygon queries used for selection, ownership checks, and trigger evaluation at runtime.
- Computes centers and bounding boxes so cameras, UI, and spatial systems can reason about named regions.
- Supports add, remove, and update flows so regions can change at runtime without reloading the whole tile map.
- Open this file when region lookup, labeling, coloring, or polygon geometry behavior is incorrect.

### render.rs

- Generates tilemap render commands with camera-aware culling across layers and supported map orientations.
- Maps tile ids to fallback debug colors so maps can still visualize without relying on atlas sampling.
- Applies per-layer visibility and tint while composing deterministic draw output for the shared renderer.
- Handles orthogonal, isometric, and hex layouts so debug and runtime visualization match map geometry.
- Acts as the tilemap-to-render boundary rather than mixing draw emission into the base TileMap owner.
- Open this file when tile draw order, culling, tint, or orientation-specific render output is incorrect.

### tile_walker.rs

- Defines a discrete grid walker with stable facing semantics for tile-based movement and interaction logic.
- Supports forward, backward, and strafe motion as first-class primitives over one consistent facing model.
- Tracks previous state so interpolation can smooth visual movement between simulation ticks or input steps.
- Classifies neighboring cells relative to facing, which supports directional interaction and sensing flows.
- Keeps movement and facing logic separate from collision backends so pathing integrations stay flexible.
- Open this file when walker facing, step logic, interpolation, or directional neighbor math behaves incorrectly.

### tilemap.rs

- Defines the core layered tilemap data model used by simulation, collision, generation, and rendering paths.
- Stores per-cell gids, per-layer visibility, tint, parallax, and geometry settings under one coherent runtime.
- Resolves global ids through attached tilesets so tile ownership and atlas lookup stay deterministic.
- Computes autotile neighborhood masks and substitution results that preserve terrain continuity across edits.
- Performs swept collision checks against solid tiles for movement systems that need stable tile-based blocking.
- Advances animated tile timelines from tileset frame data so visual state updates stay tied to map content.
- Converts between world and tile coordinates using the active map geometry instead of hardcoded projection math.
- Emits culled draw commands for viewport-scoped debug or runtime visualization without duplicating map scans.
- Acts as the operational boundary for layered tile storage rather than external import or large-map chunk policy.
- Open this file when layered map state, autotiling, collisions, or coordinate conversion behaves incorrectly.

### tilemap_collision.rs

- Implements narrow-phase tilemap collision using swept AABB tests so moving rectangles detect continuous impact.
- Computes time of impact, contact point, tile coordinates, and hit normal for sliding and obstacle responses.
- Keeps collision math separate from general map storage so movement fixes stay local and auditable.
- Open this file when tile collision timing, normals, or contact metadata behaves incorrectly in movement code.

### tilemap_index.rs

- This file owns the reverse-index maintenance helper that maps tile GIDs back to their grid positions.
- The function removes one coordinate from a GID bucket and deletes empty buckets to keep index state compact.
- Open this file when tile lookup bookkeeping changes; map storage and generation logic belong to siblings.

### tileset.rs

- Defines tileset geometry and metadata that map gids onto atlas rectangles, solidity, and animation sequences.
- Computes source quads from local ids so renderer code can sample the correct sprite region deterministically.
- Stores per-tile solidity and animation data used by collision, filtering, and animated map presentation.
- Acts as the atlas-metadata boundary between raw tilesheet images and higher-level map storage owners.
- Open this file when tile quad lookup, solid flags, or animated tileset frame data behaves incorrectly.

### tmx.rs

- Loads Tiled TMX maps into engine tile structures while preserving orientation, layers, objects, and tilesets.
- Supports TMX orientation modes so authored content can target orthogonal, isometric, and hex-style layouts.
- Decodes csv, xml, and compressed base64 tile payloads into stable gid streams used by runtime map storage.
- Parses tileset geometry and metadata required for atlas lookup, collision filtering, and tile animation.
- Ingests object layers so placement, sizing, and semantic type annotations survive the import boundary.
- Strips flip flags from raw gids so stored tile identity remains clean, comparable, and easy to post-process.
- Keeps TMX-specific error handling local instead of mixing format policy into procedural or LDtk importers.
- Open this file when TMX import, gid decoding, orientation handling, or object-layer parsing is incorrect.



## Lua API Ref

### Functions

- `lurek.tilemap.fromLDtk(jsonStr, levelName?, opts?) -> LTileMap`: Loads a tilemap from an LDtk JSON string, optionally targeting a specific level.
- `lurek.tilemap.fromScreenHex(sx, sy, size) -> integer`: Converts screen-space pixel coordinates to axial hex coordinates.
- `lurek.tilemap.fromScreenIso(sx, sy, tw, th) -> number`: Converts screen-space coordinates back to tile coordinates for isometric projection.
- `lurek.tilemap.getAutoTileFormats() -> table`: Returns the supported auto-tile sheet layouts and their default matching modes.
- `lurek.tilemap.hexArea(q, r, radius) -> table`: Returns all hex cells within a filled area of a given radius.
- `lurek.tilemap.hexDistance(q1, r1, q2, r2) -> integer`: Computes the hex grid distance between two axial coordinates.
- `lurek.tilemap.hexLine(q1, r1, q2, r2) -> table`: Returns all hex cells along a line between two axial coordinates.
- `lurek.tilemap.hexNeighbors(q, r) -> table`: Returns the six neighboring hex cells of a given axial coordinate.
- `lurek.tilemap.hexReflect(q, r, centerQ, centerR, axis) -> integer`: Reflects a hex cell across an axis through a center point.
- `lurek.tilemap.hexRing(q, r, radius) -> table`: Returns all hex cells forming a ring at a given radius around a center.
- `lurek.tilemap.hexRotate(q, r, centerQ, centerR, steps) -> integer`: Rotates a hex cell around a center point by a number of 60-degree steps.
- `lurek.tilemap.hexRound(q, r) -> integer`: Rounds fractional axial hex coordinates to the nearest integer hex cell.
- `lurek.tilemap.hexSpiral(q, r, radius) -> table`: Returns all hex cells in a spiral pattern out to a given radius.
- `lurek.tilemap.isoDirectionFromAngle(angle) -> integer`: Converts an angle in degrees to the nearest isometric direction index.
- `lurek.tilemap.isoDirectionName(direction) -> string`: Returns a human-readable name for an isometric direction index.
- `lurek.tilemap.isoRotate(direction, steps) -> integer`: Rotates an isometric direction index by a number of 90-degree steps.
- `lurek.tilemap.loadTMX(xml, opts?) -> table`: Parses a TMX (Tiled XML) string and returns a table describing the map structure.
- `lurek.tilemap.newAutoTileSheet(tileW, tileH, layout) -> LAutoTileSheet`: Creates an auto-tile sheet with a given tile size and layout.
- `lurek.tilemap.newChunkMap(chunkSize?, opts?) -> LChunkMap`: Creates a new infinite chunk-based tile map.
- `lurek.tilemap.newIsoMap(width, height, tileW, tileH, levelHeight, partCount?) -> LIsoMap`: Creates a new isometric map with the given dimensions and tile geometry.
- `lurek.tilemap.newLargeMapRenderer(tileW, tileH) -> LLargeMapRenderer`: Creates a chunk-based large-map renderer for efficient rendering of very large maps.
- `lurek.tilemap.newMapBlock(width, height, layers?, segmentSize?) -> LMapBlock`: Creates a new procedural map block with the given dimensions.
- `lurek.tilemap.newMapGen(group, presetOrWidth, segmentSizeOrHeight, segmentSize?) -> LMapGen`: Creates a procedural map generator from a group and either a size preset or explicit dimensions.
- `lurek.tilemap.newMapGroup(name) -> LMapGroup`: Creates a new map group to hold blocks and generation scripts.
- `lurek.tilemap.newMapScript() -> LMapScript`: Creates a new empty map-generation script.
- `lurek.tilemap.newTileMap(tileWidth, tileHeight, chunkSize?, opts?) -> LTileMap`: Creates a new empty tilemap with the given tile dimensions.
- `lurek.tilemap.newTileSet(firstGid, tileCount, columns, tileWidth, tileHeight, spacing?, margin?) -> LTileSet`: Creates a new tileset from atlas parameters.
- `lurek.tilemap.syncMinimap(map, layer, minimap, opts?) -> nil`: Synchronizes a tilemap layer's solid tiles into a minimap's terrain grid.
- `lurek.tilemap.toScreenHex(q, r, size) -> number`: Converts axial hex coordinates to screen-space pixel position.
- `lurek.tilemap.toScreenIso(tx, ty, tw, th) -> number`: Converts tile coordinates to screen-space position for isometric projection.

### Callbacks

- `LTileMap:onTileEnter` param `func` (`function`): Callback receiving `(wx, wy, tx, ty)`.
- `LTileMap:onTileExit` param `func` (`function`): Callback receiving `(entity, tx, ty)`.
- `LTileMap:onTileStep` param `func` (`function`): Callback receiving `(entity, tx, ty)`.

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
- `LLargeMapRenderer:setViewport(w, h) -> nil`: Sets the viewport dimensions for visibility calculations.
- `LLargeMapRenderer:type() -> string`: Returns the type name of this userdata.
- `LLargeMapRenderer:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LMapBlock Type

- Lua-side handle wrapping a `MapBlock` used for procedural map generation. A block is a tile grid with edge-matching sides.

##### Fields

- No documented fields.

##### Methods

- `LMapBlock:getDimensions() -> integer`: Returns both width and height of the block in tiles.
- `LMapBlock:getHeight() -> integer`: Returns the block height in tiles. This method is available to Lua scripts.
- `LMapBlock:getHeightInSegments() -> integer`: Returns the block height measured in segments.
- `LMapBlock:getLayerCount() -> integer`: Returns the number of tile layers in this block.
- `LMapBlock:getName() -> string`: Returns the block's name. This method is available to Lua scripts.
- `LMapBlock:getSegmentSize() -> integer`: Returns the segment size used for edge matching.
- `LMapBlock:getSide(edge, segment) -> integer`: Returns the side ID for an edge segment.
- `LMapBlock:getTile(layer, x, y) -> integer`: Returns the tile GID at a position within the block.
- `LMapBlock:getWeight() -> number`: Returns the current selection weight.
- `LMapBlock:getWidth() -> integer`: Returns the block width in tiles. This method is available to Lua scripts.
- `LMapBlock:getWidthInSegments() -> integer`: Returns the block width measured in segments.
- `LMapBlock:setName(name) -> nil`: Sets the block's name for identification during map generation.
- `LMapBlock:setSide(edge, segment, sideId) -> nil`: Sets the side ID for an edge segment, used for edge matching in map generation.
- `LMapBlock:setTile(layer, x, y, gid) -> nil`: Sets a tile GID at a position within the block.
- `LMapBlock:setWeight(weight) -> nil`: Sets the selection weight for this block during random placement.
- `LMapBlock:type() -> string`: Returns the type name of this userdata.
- `LMapBlock:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LMapGen Type

- Lua-side handle wrapping a `MapGen` procedural map generator that assembles blocks into a tilemap.

##### Fields

- No documented fields.

##### Methods

- `LMapGen:generate(scriptIdx?, seed?, layerName?) -> LTileMap`: Runs the map generator, optionally using a specific script, seed, and layer name, returning a new tilemap.
- `LMapGen:type() -> string`: Returns the type name of this userdata.
- `LMapGen:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LMapGroup Type

- Lua-side handle wrapping a `MapGroup` that holds a collection of map blocks and generation scripts.

##### Fields

- No documented fields.

##### Methods

- `LMapGroup:addBlock(block) -> nil`: Adds a map block to this group for use in generation.
- `LMapGroup:addScript(script) -> nil`: Attaches a map-generation script to this group.
- `LMapGroup:getBlockCount() -> integer`: Returns how many blocks are in this group.
- `LMapGroup:getName() -> string`: Returns the group name. This method is available to Lua scripts.
- `LMapGroup:getScriptCount() -> integer`: Returns how many scripts are attached to this group.
- `LMapGroup:removeBlock(idx) -> nil`: Removes a block from the group by index.
- `LMapGroup:type() -> string`: Returns the type name of this userdata.
- `LMapGroup:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LMapScript Type

- Lua-side handle wrapping a `MapScript` that defines a sequence of procedural generation steps.

##### Fields

- No documented fields.

##### Methods

- `LMapScript:addStep(stepDef) -> nil`: Appends a generation step. The step table must have a `type` field and optional parameters.
- `LMapScript:getStepCount() -> integer`: Returns the number of generation steps in this script.
- `LMapScript:type() -> string`: Returns the type name of this userdata.
- `LMapScript:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LTileMap Type

- Lua-side handle wrapping a `TileMap` with layers, tile data, collision, viewports, auto-tiling, and tile callbacks.

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
- `LTileMap:checkEntities(layer, entities) -> nil`: Checks a list of entities against registered tile-enter callbacks on a layer.
- `LTileMap:clearTile(layer, x, y) -> nil`: Removes the tile at a specific grid position, setting it to empty (GID 0).
- `LTileMap:drawToImage(tileSize) -> LImage`: Rasterizes the map into an image using the given tile size, returning an image handle.
- `LTileMap:fill(layer, gid) -> nil`: Fills every cell of a layer with the given GID.
- `LTileMap:findTilesByGid(layer, gid) -> table`: Returns all positions on a layer that contain a specific GID.
- `LTileMap:fireTileExit(gid, entity, tx, ty) -> nil`: Manually fires the tile-exit callback for a specific GID and entity at a tile position.
- `LTileMap:fireTileStep(gid, entity, tx, ty) -> nil`: Manually fires the tile-step callback for a specific GID and entity at a tile position.
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
- `LTileMap:isSolid(layer, x, y) -> boolean`: Checks whether the tile at a given position on a layer is solid.
- `LTileMap:onTileEnter(gid, func) -> nil`: Registers a callback invoked when an entity enters a tile with the given GID.
- `LTileMap:onTileExit(gid, func) -> nil`: Registers a callback invoked when an entity leaves a tile with the given GID.
- `LTileMap:onTileStep(gid, func) -> nil`: Registers a callback invoked each frame an entity remains on a tile with the given GID.
- `LTileMap:rectOverlapsSolid(layer, x, y, w, h) -> boolean`: Tests whether a world-space rectangle overlaps any solid tile on a layer.
- `LTileMap:render(ox?, oy?) -> nil`: Submits render commands for all visible tiles, optionally offset by a scroll position.
- `LTileMap:setLayerColor(idx, r, g, b, a) -> nil`: Sets the tint color for an entire layer.
- `LTileMap:setLayerOffset(idx, ox, oy) -> nil`: Sets the pixel offset for a layer, shifting all tiles during rendering.
- `LTileMap:setLayerParallax(idx, px, py) -> nil`: Sets the parallax scroll factor for a layer. Values less than 1 scroll slower than the camera.
- `LTileMap:setLayerVisible(idx, visible) -> nil`: Sets whether a layer is drawn during rendering.
- `LTileMap:setOrientation(orientation) -> nil`: Sets the map orientation, affecting coordinate transforms and rendering.
- `LTileMap:setTile(layer, x, y, gid) -> nil`: Sets the tile GID at a specific grid position on a layer.
- `LTileMap:setTileTint(layer, x, y, r, g, b, a) -> nil`: Overrides the color tint for a single tile at a given position.
- `LTileMap:setViewport(x, y, w, h) -> nil`: Sets the visible area of the map for culling during rendering.
- `LTileMap:sweepRect(layer, x, y, w, h, dx, dy) -> number`: Performs a swept AABB collision test against solid tiles on a layer, returning the contact point and normal.
- `LTileMap:tileToWorld(tx, ty) -> number`: Converts tile-grid coordinates to world-space pixel coordinates (top-left corner of the tile).
- `LTileMap:tileTypeIndex(layer) -> table`: Builds an index mapping each GID present on a layer to an array of `{x, y}` positions.
- `LTileMap:toNavGrid(layer, gids) -> boolean[]`: Converts a layer into a 2D boolean grid for pathfinding. Tiles with GIDs in the given list are marked walkable.
- `LTileMap:tryAddLayer(name, w, h) -> integer?`: Creates a new tile layer and returns `nil, error` instead of throwing on invalid dimensions or layer limits.
- `LTileMap:tryGetTile(layer, x, y) -> integer?`: Returns the tile GID at a specific grid position, or `nil, error` when the layer or coord is invalid.
- `LTileMap:trySetTile(layer, x, y, gid) -> boolean`: Sets a tile and returns `false, error` instead of throwing on invalid layer or coordinate input.
- `LTileMap:trySetTileTint(layer, x, y, r, g, b, a) -> nil`: Sets a per-cell tint override and returns `false, error` instead of throwing on invalid input.
- `LTileMap:tryWorldToTile(wx, wy) -> integer?`: Converts world-space pixel coordinates to tile-grid coordinates, returning nils for negative or non-finite input.
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

#### LTileSet Type

- Lua-side handle wrapping a `TileSet` for defining tile atlases, animations, solidity, and auto-tile rules.

##### Fields

- No documented fields.

##### Methods

- `LTileSet:getAnimation(tileId) -> table`: Returns the animation frames for a tile, or nil if none are set.
- `LTileSet:getAutoTileId(typeName, bitmask) -> integer`: Looks up the tile ID for a 4-bit auto-tile bitmask and type name.
- `LTileSet:getAutoTileId8(typeName, bitmask) -> integer`: Looks up the tile ID for an 8-bit auto-tile bitmask and type name.
- `LTileSet:getAutoTileMode(typeName) -> string`: Returns the neighbor matching mode for a named auto-tile type.
- `LTileSet:getColumns() -> integer`: Returns the number of columns in the tileset atlas image.
- `LTileSet:getFirstGid() -> integer`: Returns the first global tile ID (GID) of this tileset.
- `LTileSet:getMargin() -> integer`: Returns the margin around the edge of the atlas image, in pixels.
- `LTileSet:getQuad(tileId) -> table`: Returns the source rectangle (UV quad) for a tile in the atlas.
- `LTileSet:getSpacing() -> integer`: Returns the spacing between tiles in the atlas image, in pixels.
- `LTileSet:getTileCount() -> integer`: Returns the total number of tiles defined in this tileset.
- `LTileSet:getTileDimensions() -> integer`: Returns both tile width and height in pixels.
- `LTileSet:getTileHeight() -> integer`: Returns the height of a single tile in pixels.
- `LTileSet:getTileWidth() -> integer`: Returns the width of a single tile in pixels.
- `LTileSet:isSolid(tileId) -> boolean`: Checks whether a tile is marked as solid.
- `LTileSet:setAnimation(tileId, frames) -> nil`: Assigns an animation sequence to a tile. Each frame references another tile ID and a duration.
- `LTileSet:setAutoTileMode(typeName, mode) -> nil`: Sets the neighbor matching mode for a named auto-tile type.
- `LTileSet:setAutoTileRule(typeName, bitmask, tileId) -> nil`: Registers a 4-bit auto-tile rule mapping a bitmask to a tile ID for a named tile type.
- `LTileSet:setAutoTileRule8(typeName, bitmask, tileId) -> nil`: Registers an 8-bit auto-tile rule mapping a bitmask to a tile ID for a named tile type.
- `LTileSet:setSolid(tileId, solid) -> nil`: Marks a tile as solid or non-solid for collision queries.
- `LTileSet:type() -> string`: Returns the type name of this userdata.
- `LTileSet:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LTileSetGetAnimationResult Type

- Generated result shape from @field tags.

##### Fields

- `duration` (`number`): Duration.
- `tileid` (`integer`): Tileid.

##### Methods

- No documented methods.

#### LTileSetGetQuadResult Type

- Generated result shape from @field tags.

##### Fields

- `height` (`number`): Height.
- `width` (`number`): Width.
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

#### LTilemapHexAreaResult Type

- Generated result shape from @field tags.

##### Fields

- `q` (`integer`): Q.
- `r` (`number`): R.

##### Methods

- No documented methods.

#### LTilemapHexLineResult Type

- Generated result shape from @field tags.

##### Fields

- `q` (`integer`): Q.
- `r` (`number`): R.

##### Methods

- No documented methods.

#### LTilemapHexNeighborsResult Type

- Generated result shape from @field tags.

##### Fields

- `q` (`integer`): Q.
- `r` (`number`): R.

##### Methods

- No documented methods.

#### LTilemapHexRingResult Type

- Generated result shape from @field tags.

##### Fields

- `q` (`integer`): Q.
- `r` (`number`): R.

##### Methods

- No documented methods.

#### LTilemapHexSpiralResult Type

- Generated result shape from @field tags.

##### Fields

- `q` (`integer`): Q.
- `r` (`number`): R.

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

## References

- `color`: Imports or references `src/color/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `math` from `src/math/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- `lurek.tilemap.newTileMap(...)` and `lurek.tilemap.newChunkMap(...)` accept an optional limits table with ceilings such as `maxLayers`, `maxTiles`, `maxImagePixels`, `maxImportBytes`, `maxDecodedBytes`, `maxChunkCells`, `maxChunks`, and `maxCollisionTileChecks`.
- `lurek.tilemap.loadTMX(xml, opts)` supports strict/bounded import policy through `strictLayerSize`, `allowExternalTilesets`, `safePaths`, `assetRoot`, and the same byte/size limits used by safe constructors.
- `LTileMap:worldToTile(...)` preserves legacy clamping semantics, while `LTileMap:tryWorldToTile(...)` returns `nil` for negative or non-finite world coordinates and should be preferred for picking/collision front-ends.
- `LTileMap:rectOverlapsSolid(...)` and `LTileMap:sweepRect(...)` validate finite coordinates, positive rectangle size, and tile-check budgets before scanning the map.
- Reverse tile-position indexing is lazy after large writes such as `fill(...)`; callers that need dense reverse lookups should use `tileTypeIndex(...)` or `findTilesByGid(...)` and can inspect `getDiagnostics().lazyIndexRebuilds`.
- Diagnostics counters are part of the public debugging contract: invalid layer access, invalid coordinates, invalid collision queries, unknown gids, and lazy reverse-index rebuilds are observable through `LTileMap:getDiagnostics()`.
