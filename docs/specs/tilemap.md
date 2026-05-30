# tilemap

## TL;DR

- The `tilemap` module is an expansive Feature Systems tier component that provides comprehensive support for multi-layer 2D tilemaps.

## General Info

- Module group: `Feature Systems`
- Source path: `src/tilemap/`
- Lua API path(s): `src/lua_api/tilemap_api.rs`
- Primary Lua namespace: `lurek.tilemap`
- Rust test path(s): tests/rust/unit/tilemap_tests.rs
- Lua test path(s): tests/lua/unit/test_tilemap.lua, tests/lua/stress/test_tilemap_stress.lua, tests/lua/integration/test_tilemap_physics.lua, tests/lua/integration/test_tilemap_pathfind.lua, tests/lua/integration/test_tilemap_camera.lua, tests/lua/integration/test_save_tilemap.lua, tests/lua/integration/test_procgen_tilemap.lua, tests/lua/golden/test_tilemap_golden.lua, tests/lua/evidence/test_evidence_tilemap.lua

## Summary

Central to this module is the `TileMap` struct, which stores stacked `TileLayer` grids, managing per-cell tile IDs (GIDs), flip flags, collision data, and layer-specific properties like tint and parallax scroll factors. Maps can be populated dynamically or imported from standard industry formats; the module includes robust parsers for both TMX (Tiled) and LDtk map files, seamlessly transforming their XML or JSON data into engine-native structures while supporting orthogonal, staggered, hexagonal, and isometric orientations.

To support massive, open-world environments, the module implements a sophisticated `ChunkMap` system alongside a `LargeMapRenderer`. These tools partition infinite sparse tile grids into fixed-size square chunks, facilitating on-demand loading, unloading, and view-frustum culling, which drastically reduces memory usage and GPU load for oversized maps. For complex terrain, the `AutoTileSheet` simplifies level design by using bitmask-based neighbor rules to automatically select the correct tile index for seamless terrain transitions (supporting 4-bit and 8-bit matching). Additionally, specialized components like `IsoMap` provide dedicated handling for multi-level isometric projection, ensuring proper depth sorting (painter's algorithm) across intricate 3D-like structures.

The module also goes far beyond simple rendering. It features a robust procedural generation engine (`MapGen`) that constructs maps deterministically from reusable `MapBlock` prefabs and scripted operations (fill, scatter, path). For physics and gameplay logic, the map supports continuous AABB sweep-cast collision detection directly against solid tiles. `PolygonMap` enables the definition and spatial querying of named convex/concave regions (useful for zones or provinces), while `TileWalker` provides utilities for grid-based discrete movement and facing logic. Supported by the extensive `lurek.tilemap.*` Lua API, this module is a foundational pillar for building complex, optimized, and interactive 2D worlds.

## Files

### autotile_sheet.rs

- This file provides the autotile sheet model that turns neighborhood context into final tile picks.
- It keeps multiple atlas layouts coherent so different terrain styles share one usage contract.
- It centralizes bitmask interpretation and rule matching in a single graphics selection layer.
- It resolves corner relationships carefully so terrain seams stay clean across transitions.
- It supports quarter-tile composition when rendering needs sub-tile assembly for smooth blends.
- It connects sheet logic to tileset data so runtime autotiling remains deterministic.
- It forms a stable foundation for roads, biomes, and organic borders in grid-based worlds.

### chunk.rs

- This file provides sparse chunk storage for very large tile worlds that load data on demand.
- It decouples tile access from raw memory layout so map scale can grow without full allocation.
- It keeps world-to-chunk and local cell transforms precise for predictable addressing.
- It exposes range operations and visible-chunk selection to drive rendering and streaming paths.
- It stabilizes spatial boundaries so culling and update logic stay consistent under scale.

### coords.rs

- This file provides coordinate transforms for isometric and hex grids used across map systems.
- It keeps one geometric language between screen space, tile space, and movement direction logic.
- It offers orientation, rotation, and side classification helpers for grid navigation flows.
- It supports hex metrics and neighborhoods so pathing and range tools share a stable base.
- It delivers line, ring, and spiral traversals for tactical gameplay and map UI overlays.

### isomap.rs

- This file provides a multi-level isometric map model with separate parts per tile cell.
- It maps tile coordinates to diamond-projected screen space for coherent scene placement.
- It iterates draw order by diagonal progression so elevation layering reads correctly.
- It lets each elevation level be shown or hidden to support staged world presentation.
- It keeps part ordering configurable so floor, wall, and object composition remains flexible.
- It supports both bulk writes and precise per-slot updates for runtime editing workflows.
- It anchors isometric world structure in a form that is predictable for rendering and tools.

### large_map_renderer.rs

- This file provides chunk-oriented rendering support for tilemaps that exceed single-pass scale.
- It partitions the full grid into fixed blocks with dirty tracking for incremental refresh.
- It uses camera and viewport state to cull work at chunk granularity before draw emission.
- It supports per-tile mutation with automatic invalidation so updates stay localized.
- It applies optional zoom-aware detail reduction to keep large-world rendering responsive.
- It preserves tileset atlas geometry inputs needed by backend UV mapping logic.

### ldtk.rs

- This file provides LDtk JSON import into the engine-native tilemap representation.
- It parses levels and tile layers while rebuilding tileset geometry needed by runtime maps.
- It converts pixel-based LDtk placements into stable grid-cell coordinates for simulation.
- It keeps external level content aligned with the engine's layered tile data model.
- It enables deterministic content ingestion from LDtk authoring workflows.

### mapgen.rs

- This file provides scripted procedural generation for tile worlds built from reusable block pieces.
- It models block edges and matching rules so assembled regions connect with coherent boundaries.
- It groups reusable content and scripts into named generation palettes for targeted world styles.
- It defines step-driven operations for fill, placement, scatter, flood spread, and path carving.
- It orchestrates generation with seeded randomness so outputs are repeatable and testable.
- It supports both single-map and multi-region production with independent deterministic seeds.
- It applies zone and orientation metadata so generated content matches downstream render expectations.
- It controls how layers receive writes, enabling unified or split composition strategies.
- It gives runtime and tools one procedural contract that scales from prototypes to full maps.
- It keeps generation intent explicit so scripts remain readable and maintainable over time.
- It enables data-driven map variety without requiring hand-authored full layouts for every scene.
- It anchors procedural authoring in predictable structures that can be debugged and replayed.

### mod.rs

- This module delivers the high-level tile world stack for storage, generation, import, and rendering.
- It unifies layered map data for orthogonal and isometric play spaces under one runtime contract.
- It connects authored formats, procedural tools, autotiling, and region geometry into one pipeline.
- It provides the structural backbone for large interactive 2D worlds in Lurek2D.

### polygon_map.rs

- This file provides named polygon regions for zone semantics layered over tile-based worlds.
- It supports convex and concave shapes with fill styling and optional in-region text labels.
- It answers point-in-region queries for selection, triggers, and gameplay ownership checks.
- It maintains shared outline and highlight styling to keep region feedback visually consistent.
- It includes region lifecycle operations so zones can be created, updated, and removed at runtime.
- It computes bounds and centroids to support layout decisions, framing, and camera behaviors.

### render.rs

- This file provides tilemap render-command emission with camera-aware culling across map layers.
- It maps tile IDs to debug colors so rendering can proceed even without atlas texture sampling.
- It applies per-layer visibility and tint state when composing command output for the renderer.
- It keeps draw generation predictable so map visualization remains stable during updates.
- It provides a stable debug visualization path when textured rendering is unavailable.

### tile_walker.rs

- This file provides a discrete grid walker model with stable cardinal facing semantics.
- It supports forward, backward, and strafe movement as first-class motion primitives.
- It tracks previous state snapshots so interpolation can smooth visual motion between ticks.
- It classifies neighboring cells relative to facing for directional interaction logic.
- It separates passability queries from concrete collision backends for flexible integration.
- It keeps movement intent readable for gameplay, AI steering, and tactical controls.

### tilemap.rs

- This file provides the core layered tilemap data model used by simulation and rendering paths.
- It stores per-cell tile IDs, per-layer state, tint metadata, and parallax movement factors.
- It resolves global IDs through attached tilesets so tile ownership stays deterministic.
- It computes autotile neighborhood masks and substitution outputs for terrain continuity.
- It performs swept collision checks against solid tiles for top-down and platform movement.
- It advances tile animation timelines from tileset frame data during runtime updates.
- It converts world and tile coordinates in both directions using map geometry settings.
- It emits culled draw commands for viewport-scoped visualization and debug rendering.
- It exports walkability structures so pathfinding systems can consume map topology directly.
- It maintains reverse lookup caches from tile IDs to positions for fast spatial queries.
- It supports image-based debug outputs for inspection, tooling, and regression validation.
- It anchors gameplay-critical map behavior in one consistent and testable runtime surface.

### tileset.rs

- This file provides tileset geometry and metadata that define how tile IDs map to atlas pixels.
- It computes source rectangles from local IDs so render code can sample the correct sprite area.
- It stores solidity metadata per tile to support collision and gameplay filtering decisions.
- It tracks frame-based tile animations so animated map cells advance with deterministic timing.
- It holds autotile rule tables that translate neighborhood masks into terrain transition IDs.

### tmx.rs

- This file provides TMX import that converts Tiled XML maps into engine-native map structures.
- It supports major TMX orientation modes so authored content can target varied 2D projections.
- It decodes tile data from csv, xml, and compressed base64 payloads into stable gid streams.
- It ingests tileset geometry and metadata needed for atlas lookup and collision interpretation.
- It parses object layers to retain placement, sizing, and semantic type annotations.
- It strips flip flags from raw gids so stored tile identity stays clean and comparable.
- It infers solid tiles from embedded markers and custom properties used by authoring tools.
- It reports parse failures with contextual messages to speed debugging of malformed assets.
- It reads TMX color encodings so visual defaults are preserved during map import.
- It delivers a predictable bridge between external level authoring and runtime world assembly.

## Lua API Ref

- Binding: `src/lua_api/tilemap_api.rs`
- Namespace: `lurek.tilemap`

### Functions

- `lurek.tilemap.fromLDtk`: Loads a tilemap from an LDtk JSON string, optionally targeting a specific level.
- `lurek.tilemap.fromScreenHex`: Converts screen-space pixel coordinates to axial hex coordinates.
- `lurek.tilemap.fromScreenIso`: Converts screen-space coordinates back to tile coordinates for isometric projection.
- `lurek.tilemap.hexArea`: Returns all hex cells within a filled area of a given radius.
- `lurek.tilemap.hexDistance`: Computes the hex grid distance between two axial coordinates.
- `lurek.tilemap.hexLine`: Returns all hex cells along a line between two axial coordinates.
- `lurek.tilemap.hexNeighbors`: Returns the six neighboring hex cells of a given axial coordinate.
- `lurek.tilemap.hexReflect`: Reflects a hex cell across an axis through a center point.
- `lurek.tilemap.hexRing`: Returns all hex cells forming a ring at a given radius around a center.
- `lurek.tilemap.hexRotate`: Rotates a hex cell around a center point by a number of 60-degree steps.
- `lurek.tilemap.hexRound`: Rounds fractional axial hex coordinates to the nearest integer hex cell.
- `lurek.tilemap.hexSpiral`: Returns all hex cells in a spiral pattern out to a given radius.
- `lurek.tilemap.isoDirectionFromAngle`: Converts an angle in degrees to the nearest isometric direction index.
- `lurek.tilemap.isoDirectionName`: Returns a human-readable name for an isometric direction index.
- `lurek.tilemap.isoRotate`: Rotates an isometric direction index by a number of 90-degree steps.
- `lurek.tilemap.loadTMX`: Parses a TMX (Tiled XML) string and returns a table describing the map structure.
- `lurek.tilemap.newAutoTileSheet`: Creates an auto-tile sheet with a given tile size and layout.
- `lurek.tilemap.newChunkMap`: Creates a new infinite chunk-based tile map.
- `lurek.tilemap.newIsoMap`: Creates a new isometric map with the given dimensions and tile geometry.
- `lurek.tilemap.newLargeMapRenderer`: Creates a chunk-based large-map renderer for efficient rendering of very large maps.
- `lurek.tilemap.newMapBlock`: Creates a new procedural map block with the given dimensions.
- `lurek.tilemap.newMapGen`: Creates a procedural map generator from a group and either a size preset or explicit dimensions.
- `lurek.tilemap.newMapGroup`: Creates a new map group to hold blocks and generation scripts.
- `lurek.tilemap.newMapScript`: Creates a new empty map-generation script.
- `lurek.tilemap.newTileMap`: Creates a new empty tilemap with the given tile dimensions.
- `lurek.tilemap.newTileSet`: Creates a new tileset from atlas parameters.
- `lurek.tilemap.toScreenHex`: Converts axial hex coordinates to screen-space pixel position.
- `lurek.tilemap.toScreenIso`: Converts tile coordinates to screen-space position for isometric projection.

### Enums

- No documented module-level enums/constants.

### Types

#### LAutoTileSheet Type

- Lua-side handle wrapping an `AutoTileSheet` that maps bitmasks to tile quads for auto-tiling.

##### Fields

- No documented fields.

##### Methods

- `LAutoTileSheet:applyToTileSet`: Writes the auto-tile bitmask-to-tile rules from this sheet into a tileset.
- `LAutoTileSheet:getBitmaskForTile`: Returns the bitmask associated with a tile in this auto-tile sheet.
- `LAutoTileSheet:getLayout`: Returns the auto-tile layout type as a string.
- `LAutoTileSheet:getQuad`: Returns the source rectangle for a tile in the auto-tile sheet.
- `LAutoTileSheet:getTileCount`: Returns the total number of tiles in this auto-tile sheet.
- `LAutoTileSheet:getTileForBitmask`: Looks up which tile corresponds to a given bitmask value.
- `LAutoTileSheet:getTileHeight`: Returns the height of each tile in the auto-tile sheet, in pixels.
- `LAutoTileSheet:getTileWidth`: Returns the width of each tile in the auto-tile sheet, in pixels.
- `LAutoTileSheet:type`: Returns the type name of this userdata.
- `LAutoTileSheet:typeOf`: Checks whether this object matches the given type name.

#### LChunkMap Type

- Lua-side handle wrapping a `ChunkMap` for infinite or very large tile grids stored in dynamically loaded chunks.

##### Fields

- No documented fields.

##### Methods

- `LChunkMap:chunkTileRange`: Returns the tile-coordinate range covered by a specific chunk.
- `LChunkMap:clearTile`: Removes the tile at the given world-tile coordinate.
- `LChunkMap:fillRect`: Fills a rectangular region of tiles with a given GID.
- `LChunkMap:getChunkSize`: Returns the size of each chunk in tiles per side.
- `LChunkMap:getChunksInView`: Returns chunk coordinates that overlap a viewport region, given tile dimensions.
- `LChunkMap:getLoadedChunks`: Returns a list of all currently loaded chunk coordinates.
- `LChunkMap:getTile`: Returns the tile GID at the given world-tile coordinate.
- `LChunkMap:loadChunk`: Loads a chunk into memory at the given chunk coordinates.
- `LChunkMap:setTile`: Sets the tile GID at the given world-tile coordinate.
- `LChunkMap:type`: Returns the type name of this userdata.
- `LChunkMap:typeOf`: Checks whether this object matches the given type name.
- `LChunkMap:unloadChunk`: Unloads a chunk from memory at the given chunk coordinates.

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

- `LIsoMap:addLevel`: Adds a new vertical level to the isometric map and returns its index.
- `LIsoMap:fillLevel`: Fills all tiles on a level for a given part with a single GID.
- `LIsoMap:getHeight`: Returns the map height in tiles. This method is available to Lua scripts.
- `LIsoMap:getLevelCount`: Returns the number of vertical levels in the isometric map.
- `LIsoMap:getLevelHeight`: Returns the vertical pixel offset between levels.
- `LIsoMap:getPartCount`: Returns the number of tile parts per cell.
- `LIsoMap:getPartOrder`: Returns the rendering order of tile parts as an array of part indices.
- `LIsoMap:getTileHeight`: Returns the height of an isometric tile in pixels.
- `LIsoMap:getTilePart`: Returns the GID for a specific part of a tile at a given position and level.
- `LIsoMap:getTileWidth`: Returns the width of an isometric tile in pixels.
- `LIsoMap:getWidth`: Returns the map width in tiles. This method is available to Lua scripts.
- `LIsoMap:isLevelVisible`: Returns whether a vertical level is currently visible.
- `LIsoMap:screenToTile`: Converts screen-space pixel coordinates to tile-grid coordinates (ignoring Z).
- `LIsoMap:setLevelVisible`: Sets whether a vertical level is drawn during rendering.
- `LIsoMap:setOrigin`: Sets the screen-space origin (top-left anchor) for isometric rendering.
- `LIsoMap:setPartOrder`: Overrides the rendering order of tile parts.
- `LIsoMap:setTilePart`: Sets the GID for a specific part of a tile at a given position and level.
- `LIsoMap:tileToScreen`: Converts tile-grid coordinates to screen-space pixel position.
- `LIsoMap:type`: Returns the type name of this userdata.
- `LIsoMap:typeOf`: Checks whether this object matches the given type name.

#### LLargeMapRenderer Type

- Lua-side handle wrapping a `LargeMapRenderer` for chunk-based rendering of very large tile maps with LOD support.

##### Fields

- No documented fields.

##### Methods

- `LLargeMapRenderer:getChunkSize`: Returns the current chunk size. This method is available to Lua scripts.
- `LLargeMapRenderer:getMapSize`: Returns the map dimensions in tiles.
- `LLargeMapRenderer:getTile`: Returns the tile GID at a given position.
- `LLargeMapRenderer:getTilesetColumns`: Returns the tileset column count used for UV calculation.
- `LLargeMapRenderer:getTotalChunks`: Returns the total number of chunks in the map.
- `LLargeMapRenderer:getVisibleChunks`: Returns the number of chunks currently visible in the viewport.
- `LLargeMapRenderer:invalidateAll`: Marks all chunks as dirty, forcing a full rebuild on the next render.
- `LLargeMapRenderer:invalidateChunk`: Marks a specific chunk as dirty so it will be rebuilt on the next render.
- `LLargeMapRenderer:isLodEnabled`: Returns whether LOD rendering is currently enabled.
- `LLargeMapRenderer:setCamera`: Sets the camera position and zoom level for determining visible chunks.
- `LLargeMapRenderer:setChunkSize`: Sets the chunk size used for rendering subdivision.
- `LLargeMapRenderer:setLodEnabled`: Enables or disables level-of-detail rendering for distant chunks.
- `LLargeMapRenderer:setLodThresholds`: Sets the zoom thresholds at which LOD levels change.
- `LLargeMapRenderer:setMapData`: Replaces all tile data with a flat array of GIDs for the given dimensions.
- `LLargeMapRenderer:setTile`: Sets a single tile GID at a given position.
- `LLargeMapRenderer:setTilesetColumns`: Sets the column count of the associated tileset atlas for UV calculation.
- `LLargeMapRenderer:setViewport`: Sets the viewport dimensions for visibility calculations.
- `LLargeMapRenderer:type`: Returns the type name of this userdata.
- `LLargeMapRenderer:typeOf`: Checks whether this object matches the given type name.

#### LMapBlock Type

- Lua-side handle wrapping a `MapBlock` used for procedural map generation. A block is a tile grid with edge-matching sides.

##### Fields

- No documented fields.

##### Methods

- `LMapBlock:getDimensions`: Returns both width and height of the block in tiles.
- `LMapBlock:getHeight`: Returns the block height in tiles. This method is available to Lua scripts.
- `LMapBlock:getHeightInSegments`: Returns the block height measured in segments.
- `LMapBlock:getLayerCount`: Returns the number of tile layers in this block.
- `LMapBlock:getName`: Returns the block's name. This method is available to Lua scripts.
- `LMapBlock:getSegmentSize`: Returns the segment size used for edge matching.
- `LMapBlock:getSide`: Returns the side ID for an edge segment.
- `LMapBlock:getTile`: Returns the tile GID at a position within the block.
- `LMapBlock:getWeight`: Returns the current selection weight.
- `LMapBlock:getWidth`: Returns the block width in tiles. This method is available to Lua scripts.
- `LMapBlock:getWidthInSegments`: Returns the block width measured in segments.
- `LMapBlock:setName`: Sets the block's name for identification during map generation.
- `LMapBlock:setSide`: Sets the side ID for an edge segment, used for edge matching in map generation.
- `LMapBlock:setTile`: Sets a tile GID at a position within the block.
- `LMapBlock:setWeight`: Sets the selection weight for this block during random placement.
- `LMapBlock:type`: Returns the type name of this userdata.
- `LMapBlock:typeOf`: Checks whether this object matches the given type name.

#### LMapGen Type

- Lua-side handle wrapping a `MapGen` procedural map generator that assembles blocks into a tilemap.

##### Fields

- No documented fields.

##### Methods

- `LMapGen:generate`: Runs the map generator, optionally using a specific script, seed, and layer name, returning a new tilemap.
- `LMapGen:type`: Returns the type name of this userdata.
- `LMapGen:typeOf`: Checks whether this object matches the given type name.

#### LMapGroup Type

- Lua-side handle wrapping a `MapGroup` that holds a collection of map blocks and generation scripts.

##### Fields

- No documented fields.

##### Methods

- `LMapGroup:addBlock`: Adds a map block to this group for use in generation.
- `LMapGroup:addScript`: Attaches a map-generation script to this group.
- `LMapGroup:getBlockCount`: Returns how many blocks are in this group.
- `LMapGroup:getName`: Returns the group name. This method is available to Lua scripts.
- `LMapGroup:getScriptCount`: Returns how many scripts are attached to this group.
- `LMapGroup:removeBlock`: Removes a block from the group by index.
- `LMapGroup:type`: Returns the type name of this userdata.
- `LMapGroup:typeOf`: Checks whether this object matches the given type name.

#### LMapScript Type

- Lua-side handle wrapping a `MapScript` that defines a sequence of procedural generation steps.

##### Fields

- No documented fields.

##### Methods

- `LMapScript:addStep`: Appends a generation step. The step table must have a `type` field and optional parameters.
- `LMapScript:getStepCount`: Returns the number of generation steps in this script.
- `LMapScript:type`: Returns the type name of this userdata.
- `LMapScript:typeOf`: Checks whether this object matches the given type name.

#### LTileMap Type

- Lua-side handle wrapping a `TileMap` with layers, tile data, collision, viewports, auto-tiling, and tile callbacks.

##### Fields

- No documented fields.

##### Methods

- `LTileMap:addLayer`: Creates a new tile layer with the given name and dimensions.
- `LTileMap:addTileSet`: Attaches a tileset to this map for tile rendering.
- `LTileMap:applyAutoTile`: Runs 4-bit auto-tiling on an entire layer, replacing tiles according to registered rules.
- `LTileMap:applyAutoTile8`: Runs 8-bit auto-tiling on an entire layer, considering diagonal neighbors.
- `LTileMap:applyAutoTile8At`: Runs 8-bit auto-tiling at a single tile position and updates it and its neighbors.
- `LTileMap:applyAutoTileAt`: Runs 4-bit auto-tiling at a single tile position and updates it and its neighbors.
- `LTileMap:checkEntities`: Checks a list of entities against registered tile-enter callbacks on a layer.
- `LTileMap:clearTile`: Removes the tile at a specific grid position, setting it to empty (GID 0).
- `LTileMap:drawToImage`: Rasterizes the map into an image using the given tile size, returning an image handle.
- `LTileMap:fill`: Fills every cell of a layer with the given GID.
- `LTileMap:findTilesByGid`: Returns all positions on a layer that contain a specific GID.
- `LTileMap:fireTileExit`: Manually fires the tile-exit callback for a specific GID and entity at a tile position.
- `LTileMap:fireTileStep`: Manually fires the tile-step callback for a specific GID and entity at a tile position.
- `LTileMap:getChunkSize`: Returns the chunk size used for internal tile storage.
- `LTileMap:getLayerColor`: Returns the tint color of a layer as four RGBA components.
- `LTileMap:getLayerCount`: Returns the total number of layers in this map.
- `LTileMap:getLayerName`: Returns the name of a layer by index.
- `LTileMap:getLayerOffset`: Returns the pixel offset of a layer.
- `LTileMap:getLayerParallax`: Returns the parallax scroll factor of a layer.
- `LTileMap:getLayerVisible`: Returns whether a layer is currently visible.
- `LTileMap:getOrientation`: Returns the current map orientation as a string.
- `LTileMap:getTile`: Returns the tile GID at a specific grid position on a layer.
- `LTileMap:getTileDimensions`: Returns both tile width and height in pixels.
- `LTileMap:getTileHeight`: Returns the height of a single tile in pixels for this map.
- `LTileMap:getTileSet`: Returns the tileset at the given index.
- `LTileMap:getTileSetCount`: Returns how many tilesets are attached to this map.
- `LTileMap:getTileWidth`: Returns the width of a single tile in pixels for this map.
- `LTileMap:getViewport`: Returns the current viewport rectangle, or nils if none is set.
- `LTileMap:isSolid`: Checks whether the tile at a given position on a layer is solid.
- `LTileMap:onTileEnter`: Registers a callback invoked when an entity enters a tile with the given GID.
- `LTileMap:onTileExit`: Registers a callback invoked when an entity leaves a tile with the given GID.
- `LTileMap:onTileStep`: Registers a callback invoked each frame an entity remains on a tile with the given GID.
- `LTileMap:rectOverlapsSolid`: Tests whether a world-space rectangle overlaps any solid tile on a layer.
- `LTileMap:render`: Submits render commands for all visible tiles, optionally offset by a scroll position.
- `LTileMap:setLayerColor`: Sets the tint color for an entire layer.
- `LTileMap:setLayerOffset`: Sets the pixel offset for a layer, shifting all tiles during rendering.
- `LTileMap:setLayerParallax`: Sets the parallax scroll factor for a layer. Values less than 1 scroll slower than the camera.
- `LTileMap:setLayerVisible`: Sets whether a layer is drawn during rendering.
- `LTileMap:setOrientation`: Sets the map orientation, affecting coordinate transforms and rendering.
- `LTileMap:setTile`: Sets the tile GID at a specific grid position on a layer.
- `LTileMap:setTileTint`: Overrides the color tint for a single tile at a given position.
- `LTileMap:setViewport`: Sets the visible area of the map for culling during rendering.
- `LTileMap:sweepRect`: Performs a swept AABB collision test against solid tiles on a layer, returning the contact point and normal.
- `LTileMap:tileToWorld`: Converts tile-grid coordinates to world-space pixel coordinates (top-left corner of the tile).
- `LTileMap:tileTypeIndex`: Builds an index mapping each GID present on a layer to an array of `{x, y}` positions.
- `LTileMap:toNavGrid`: Converts a layer into a 2D boolean grid for pathfinding. Tiles with GIDs in the given list are marked walkable.
- `LTileMap:type`: Returns the type name of this userdata.
- `LTileMap:typeOf`: Checks whether this object matches the given type name.
- `LTileMap:update`: Advances tile animations by the given delta time.
- `LTileMap:worldToTile`: Converts world-space pixel coordinates to tile-grid coordinates.

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

- `LTileSet:getAnimation`: Returns the animation frames for a tile, or nil if none are set.
- `LTileSet:getAutoTileId`: Looks up the tile ID for a 4-bit auto-tile bitmask and type name.
- `LTileSet:getAutoTileId8`: Looks up the tile ID for an 8-bit auto-tile bitmask and type name.
- `LTileSet:getColumns`: Returns the number of columns in the tileset atlas image.
- `LTileSet:getFirstGid`: Returns the first global tile ID (GID) of this tileset.
- `LTileSet:getMargin`: Returns the margin around the edge of the atlas image, in pixels.
- `LTileSet:getQuad`: Returns the source rectangle (UV quad) for a tile in the atlas.
- `LTileSet:getSpacing`: Returns the spacing between tiles in the atlas image, in pixels.
- `LTileSet:getTileCount`: Returns the total number of tiles defined in this tileset.
- `LTileSet:getTileDimensions`: Returns both tile width and height in pixels.
- `LTileSet:getTileHeight`: Returns the height of a single tile in pixels.
- `LTileSet:getTileWidth`: Returns the width of a single tile in pixels.
- `LTileSet:isSolid`: Checks whether a tile is marked as solid.
- `LTileSet:setAnimation`: Assigns an animation sequence to a tile. Each frame references another tile ID and a duration.
- `LTileSet:setAutoTileRule`: Registers a 4-bit auto-tile rule mapping a bitmask to a tile ID for a named tile type.
- `LTileSet:setAutoTileRule8`: Registers an 8-bit auto-tile rule mapping a bitmask to a tile ID for a named tile type.
- `LTileSet:setSolid`: Marks a tile as solid or non-solid for collision queries.
- `LTileSet:type`: Returns the type name of this userdata.
- `LTileSet:typeOf`: Checks whether this object matches the given type name.

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

- `height` (`number`): Height.
- `layers` (`table`): Layers array.
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
