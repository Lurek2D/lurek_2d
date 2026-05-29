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

- Autotile sprite-sheet abstraction: blob-47, composite-48, and minimal-16 layouts.
- Bitmask table generation and reverse lookup from neighbor mask to tile index.
- 8-bit diagonal collapse for correct cardinal-gated corner resolution.
- Quarter-tile compositing helpers for sub-tile source and destination rects.
- Sheet-to-tileset rule registration for runtime autotile placement.

### chunk.rs

- Infinite sparse tile grid partitioned into fixed-size square chunks.
- On-demand chunk allocation and explicit load/unload lifecycle.
- Tile read/write by world coordinates with automatic chunk decomposition.
- Rectangular fill, chunk enumeration, and view-frustum culling helpers.
- World-space geometry queries for chunk bounds and overlap testing.

### coords.rs

- Isometric tile-to-screen and screen-to-tile coordinate conversions.
- Cardinal direction rotation, naming, and angle snapping for iso grids.
- Hex axial coordinate conversions between screen and grid space.
- Hex neighbor lookup, distance, and rounding for fractional coordinates.
- Line drawing, ring enumeration, spiral traversal, and area fill on hex grids.
- Hex rotation and reflection transforms around arbitrary center cells.

### isomap.rs

- Multi-level isometric tile map with per-tile draw-layer parts (floor, walls, objects).
- Diamond-projection coordinate conversion between tile space and screen space.
- Painter-sorted draw iteration via diagonal-strip traversal across elevation levels.
- Per-level visibility toggling and configurable part draw order.
- Bulk fill and individual GID get/set for each tile-part slot.

### large_map_renderer.rs

- Chunk-based large-map renderer for tilemaps that exceed single-pass draw limits.
- Splits the full tile grid into fixed-size square chunks with dirty-flag tracking.
- Camera and viewport state drive visibility culling at chunk granularity.
- Supports per-tile mutation with automatic chunk invalidation.
- Optional LOD down-sampling controlled by configurable zoom thresholds.
- Tileset column count stored for atlas UV computation by the draw backend.

### ldtk.rs

- Import LDtk project JSON into the engine tilemap representation.
- Parse levels, tile layers, and auto-layers with tileset geometry reconstruction.
- Map LDtk pixel-based tile coordinates to grid-cell indices.

### mapgen.rs

- Procedural tile-map generation driven by reusable block stamps and scripted steps.
- `MapBlock` stores rectangular tile grids with edge side-IDs for neighbour matching.
- `MapGroup` collects blocks and `MapScript`s into named generation palettes.
- `ScriptStep` parameterises operations: fill, place, scatter, flood-fill, path drawing.
- `MapGen` orchestrates generation using seeded LCG RNG, zones, orientation, and layer modes.
- Supports single-region and multi-region world tiling with independent seeds per region.
- Deterministic output: same seed + script always produces the same map.
- Grid presets (`MapSize`) and horizontal zone bands constrain placement areas.
- Orientation tags (top-down, side-view, isometric, hexagonal) stored for downstream renderers.
- Layer modes control whether blocks share a unified layer or write independently.

### mod.rs

- Tile map storage, rendering, and chunk streaming for large worlds.
- Supports orthogonal and isometric layouts with layered tiles.
- Imports LDtk and Tiled TMX formats; procedural generation via MapGen.
- Autotile rules, tile-space coordinates, and polygon-region maps.

### polygon_map.rs

- Named convex/concave polygon regions with fill color and optional text labels.
- Spatial query via ray-casting point-in-polygon test for hit detection.
- Global outline and highlight styling shared across all regions.
- Region management: add, remove, recolor, label, and enumerate.
- Bounding-box and centroid computation for layout and camera framing.

### render.rs

- Camera-culled render-command generation for tile-map layers.
- GID-to-color debug palette for fallback colored tile rendering.
- Per-layer visibility and tint applied during command emission.

### tile_walker.rs

- Cardinal facing direction with angle, delta, and rotation helpers.
- Discrete grid walker with forward, backward, and strafe movement.
- Previous-state snapshot for smooth frame interpolation of position and heading.
- Relative-facing query to classify adjacent tiles as front, back, left, or right.
- Passability checks decoupled from actual collision data.

### tilemap.rs

- Multi-layer tile map with per-tile GID storage, tint overrides, and parallax scroll factors.
- Tileset attachment and GID resolution across multiple tileset ranges.
- 4-neighbour and 8-neighbour autotile bitmask computation and GID substitution.
- Continuous AABB sweep-cast collision against solid tiles for platformer and top-down physics.
- Per-GID animation timer advancement using tileset frame data.
- World-to-tile and tile-to-world coordinate conversion respecting tile dimensions.
- Viewport-aware culled render-command generation for debug colour-coded output.
- Debug image rendering: full-map, per-layer side-by-side, and highlight-overlay modes.
- Boolean walkability grid export for pathfinding integration.
- GID-to-position reverse index cache for fast spatial queries by tile type.

### tileset.rs

- Tileset geometry: tile dimensions, spacing, margin, column count, and GID range ownership.
- Source-rect lookup: compute pixel `Rect` for any local tile ID within the sprite-sheet.
- Collision metadata: per-tile solid flag storage and query.
- Animation sequences: frame-based tile animations keyed by local ID.
- Autotile rules: 4-bit and 8-bit bitmask-to-tile mappings for terrain transitions.

### tmx.rs

- Parse the Tiled TMX XML map format into engine-native structs for tile and object layers.
- Support orthogonal, isometric, staggered, and hexagonal map orientations.
- Decode tile GID arrays from CSV, raw XML, and base64 encodings with zlib/gzip decompression.
- Extract tileset metadata including image paths, spacing, margins, and solid-tile markers.
- Parse object layers with position, size, type, and optional tile-GID references.
- Mask Tiled flip flags (horizontal, vertical, diagonal) from raw GID values before storage.
- Detect solid tiles via embedded objectgroups or `solid=true` custom properties.
- Propagate parse failures as descriptive error strings with element and attribute context.
- Parse Tiled hex color strings (`#RRGGBB` / `#AARRGGBB`) for map background color.

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


#### LIsoMap Type


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


##### Fields

- No documented fields.

##### Methods

- `LMapGen:generate`: Runs the map generator, optionally using a specific script, seed, and layer name, returning a new tilemap.
- `LMapGen:type`: Returns the type name of this userdata.
- `LMapGen:typeOf`: Checks whether this object matches the given type name.


#### LMapGroup Type


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


##### Fields

- No documented fields.

##### Methods

- `LMapScript:addStep`: Appends a generation step. The step table must have a `type` field and optional parameters.
- `LMapScript:getStepCount`: Returns the number of generation steps in this script.
- `LMapScript:type`: Returns the type name of this userdata.
- `LMapScript:typeOf`: Checks whether this object matches the given type name.


#### LTileMap Type


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


#### LTileSet Type


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

## References

- `color`: Imports or references `src/color/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `math` from `src/math/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
