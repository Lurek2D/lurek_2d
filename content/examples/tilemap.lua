-- content/examples/tilemap.lua
-- love2d-style usage snippets for the lurek.tilemap API (134 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/tilemap.lua

-- ── lurek.tilemap.* functions ──

--@api-stub: lurek.tilemap.newTileSet
-- Creates a new TileSet with the given atlas layout parameters.
-- Build once at startup; reuse across frames.
local tileset = lurek.tilemap.newTileSet()
print("created", tileset)
return tileset

--@api-stub: lurek.tilemap.newTileMap
-- Creates a new TileMap with the given tile size and chunk size.
-- Build once at startup; reuse across frames.
local tilemap = lurek.tilemap.newTileMap(tile_width, tile_height, chunk_size)
print("created", tilemap)
return tilemap

--@api-stub: lurek.tilemap.newAutoTileSheet
-- Creates a new AutoTileSheet with the given tile dimensions and layout.
-- Build once at startup; reuse across frames.
local autotilesheet = lurek.tilemap.newAutoTileSheet(tile_w, tile_h, "hello")
print("created", autotilesheet)
return autotilesheet

--@api-stub: lurek.tilemap.newChunkMap
-- Creates a new ChunkMap with the given chunk size.
-- Build once at startup; reuse across frames.
local chunkmap = lurek.tilemap.newChunkMap(chunk_size)
print("created", chunkmap)
return chunkmap

--@api-stub: lurek.tilemap.newIsoMap
-- Creates a new IsoMap with no levels.
-- Build once at startup; reuse across frames.
local isomap = lurek.tilemap.newIsoMap()
print("created", isomap)
return isomap

--@api-stub: lurek.tilemap.newMapBlock
-- Creates a new MapBlock with the given dimensions.
-- Build once at startup; reuse across frames.
local mapblock = lurek.tilemap.newMapBlock(64, 64, layers, segment_size)
print("created", mapblock)
return mapblock

--@api-stub: lurek.tilemap.newMapGroup
-- Creates a new empty MapGroup with the given name.
-- Build once at startup; reuse across frames.
local mapgroup = lurek.tilemap.newMapGroup("main")
print("created", mapgroup)
return mapgroup

--@api-stub: lurek.tilemap.toScreenIso
-- Converts tile coordinates to screen position using diamond isometric projection.
-- See the module spec for detailed semantics.
local result = lurek.tilemap.toScreenIso(tx, ty, tw, th)
print("toScreenIso:", result)
return result

--@api-stub: lurek.tilemap.fromScreenIso
-- Converts screen position back to tile coordinates for diamond isometric projection.
-- Build once at startup; reuse across frames.
local fromscreeniso = lurek.tilemap.fromScreenIso(sx, sy, tw, th)
print("created", fromscreeniso)
return fromscreeniso

--@api-stub: lurek.tilemap.toScreenHex
-- Converts axial hex coordinates to screen position (pointy-top layout).
-- See the module spec for detailed semantics.
local result = lurek.tilemap.toScreenHex(q, 1, 10)
print("toScreenHex:", result)
return result

--@api-stub: lurek.tilemap.fromScreenHex
-- Converts screen position back to axial hex coordinates (pointy-top layout).
-- Build once at startup; reuse across frames.
local fromscreenhex = lurek.tilemap.fromScreenHex(sx, sy, 10)
print("created", fromscreenhex)
return fromscreenhex

--@api-stub: lurek.tilemap.hexNeighbors
-- Returns the six axial neighbor coordinates as a table of {q, r} pairs.
-- See the module spec for detailed semantics.
local result = lurek.tilemap.hexNeighbors(q, 1)
print("hexNeighbors:", result)
return result

--@api-stub: lurek.tilemap.hexDistance
-- Returns the hex distance between two axial coordinates.
-- See the module spec for detailed semantics.
local result = lurek.tilemap.hexDistance(q1, r1, q2, r2)
print("hexDistance:", result)
return result

--@api-stub: lurek.tilemap.hexRound
-- Rounds fractional axial coordinates to the nearest hex cell.
-- See the module spec for detailed semantics.
local result = lurek.tilemap.hexRound(q, 1)
print("hexRound:", result)
return result

--@api-stub: lurek.tilemap.hexLine
-- Returns all hex cells along a line between two axial coordinates as a table.
-- See the module spec for detailed semantics.
local result = lurek.tilemap.hexLine(q1, r1, q2, r2)
print("hexLine:", result)
return result

--@api-stub: lurek.tilemap.hexRing
-- Returns all cells at exactly radius distance from (q, r) as a table.
-- See the module spec for detailed semantics.
local result = lurek.tilemap.hexRing(q, 1, radius)
print("hexRing:", result)
return result

--@api-stub: lurek.tilemap.hexSpiral
-- Returns all hex cells from center outward to radius, ring by ring, as a table.
-- See the module spec for detailed semantics.
local result = lurek.tilemap.hexSpiral(q, 1, radius)
print("hexSpiral:", result)
return result

--@api-stub: lurek.tilemap.hexArea
-- Returns all hex cells within radius distance (filled hex circle) as a table.
-- See the module spec for detailed semantics.
local result = lurek.tilemap.hexArea(q, 1, radius)
print("hexArea:", result)
return result

--@api-stub: lurek.tilemap.hexRotate
-- Rotates hex coordinates around a center by steps x 60 degrees clockwise.
-- See the module spec for detailed semantics.
local result = lurek.tilemap.hexRotate(q, 1, center_q, center_r, steps)
print("hexRotate:", result)
return result

--@api-stub: lurek.tilemap.hexReflect
-- Reflects hex coordinates across an axis through the center.
-- See the module spec for detailed semantics.
local result = lurek.tilemap.hexReflect(q, 1, center_q, center_r, axis)
print("hexReflect:", result)
return result

--@api-stub: lurek.tilemap.isoRotate
-- Rotates an isometric direction (1-4) clockwise by steps.
-- See the module spec for detailed semantics.
local result = lurek.tilemap.isoRotate("data/file.txt", steps)
print("isoRotate:", result)
return result

--@api-stub: lurek.tilemap.isoDirectionName
-- Returns the name of an isometric direction (1-4).
-- See the module spec for detailed semantics.
local result = lurek.tilemap.isoDirectionName("data/file.txt")
print("isoDirectionName:", result)
return result

--@api-stub: lurek.tilemap.isoDirectionFromAngle
-- Snaps an angle (in radians) to the nearest isometric direction (1-4).
-- See the module spec for detailed semantics.
local result = lurek.tilemap.isoDirectionFromAngle(0)
print("isoDirectionFromAngle:", result)
return result

--@api-stub: lurek.tilemap.newMapScript
-- Creates a new empty MapScript procedural generation script.
-- Build once at startup; reuse across frames.
local mapscript = lurek.tilemap.newMapScript()
print("created", mapscript)
return mapscript

--@api-stub: lurek.tilemap.newMapGen
-- Creates a MapGen from a MapGroup, a preset name or dimensions, and a segment size.
-- Build once at startup; reuse across frames.
local mapgen = lurek.tilemap.newMapGen()
print("created", mapgen)
return mapgen

--@api-stub: lurek.tilemap.loadTMX
-- Parses a TMX XML string and returns a table with map metadata and layers.
-- May block — call from a worker thread for large payloads.
local result = lurek.tilemap.loadTMX(xml)
-- may block; consider lurek.thread for large payloads
print("loadTMX:", result)
print("ok")

--@api-stub: lurek.tilemap.fromLDtk
-- Parses an LDtk JSON export string and returns a TileMap.
-- Build once at startup; reuse across frames.
local fromldtk = lurek.tilemap.fromLDtk("hello", "main")
print("created", fromldtk)
return fromldtk

--@api-stub: lurek.tilemap.newLargeMapRenderer
-- Creates a LargeMapRenderer for chunk-level occlusion culling on maps > 200Ă—200 tiles.
-- Build once at startup; reuse across frames.
local largemaprenderer = lurek.tilemap.newLargeMapRenderer(tile_w, tile_h)
print("created", largemaprenderer)
return largemaprenderer

-- ── TileSet methods ──

--@api-stub: TileSet:getFirstGid
-- Returns the first global ID assigned to this tileset.
-- Cheap to call; safe inside callbacks.
local tileSet = lurek.tilemap.newTileSet()  -- or your existing handle
local value = tileSet:getFirstGid()
print("TileSet:getFirstGid ->", value)

--@api-stub: TileSet:getTileCount
-- Returns the total number of tiles in this tileset.
-- Cheap to call; safe inside callbacks.
local tileSet = lurek.tilemap.newTileSet()  -- or your existing handle
local value = tileSet:getTileCount()
print("TileSet:getTileCount ->", value)

--@api-stub: TileSet:getColumns
-- Returns the number of tile columns in the atlas texture.
-- Cheap to call; safe inside callbacks.
local tileSet = lurek.tilemap.newTileSet()  -- or your existing handle
local value = tileSet:getColumns()
print("TileSet:getColumns ->", value)

--@api-stub: TileSet:getTileWidth
-- Returns the width of a single tile in pixels.
-- Cheap to call; safe inside callbacks.
local tileSet = lurek.tilemap.newTileSet()  -- or your existing handle
local value = tileSet:getTileWidth()
print("TileSet:getTileWidth ->", value)

--@api-stub: TileSet:getTileHeight
-- Returns the height of a single tile in pixels.
-- Cheap to call; safe inside callbacks.
local tileSet = lurek.tilemap.newTileSet()  -- or your existing handle
local value = tileSet:getTileHeight()
print("TileSet:getTileHeight ->", value)

--@api-stub: TileSet:getTileDimensions
-- Returns the tile dimensions as (width, height).
-- Cheap to call; safe inside callbacks.
local tileSet = lurek.tilemap.newTileSet()  -- or your existing handle
local value = tileSet:getTileDimensions()
print("TileSet:getTileDimensions ->", value)

--@api-stub: TileSet:getSpacing
-- Returns the spacing in pixels between tiles in the atlas.
-- Cheap to call; safe inside callbacks.
local tileSet = lurek.tilemap.newTileSet()  -- or your existing handle
local value = tileSet:getSpacing()
print("TileSet:getSpacing ->", value)

--@api-stub: TileSet:getMargin
-- Returns the margin in pixels around the edges of the atlas.
-- Cheap to call; safe inside callbacks.
local tileSet = lurek.tilemap.newTileSet()  -- or your existing handle
local value = tileSet:getMargin()
print("TileSet:getMargin ->", value)

--@api-stub: TileSet:getQuad
-- Computes the atlas source rectangle for a 1-based local tile ID.
-- Cheap to call; safe inside callbacks.
local tileSet = lurek.tilemap.newTileSet()  -- or your existing handle
local value = tileSet:getQuad(1)
print("TileSet:getQuad ->", value)

--@api-stub: TileSet:getAnimation
-- Returns the animation frames for a 1-based local tile ID as a table of {tileid, duration}, or nil.
-- Cheap to call; safe inside callbacks.
local tileSet = lurek.tilemap.newTileSet()  -- or your existing handle
local value = tileSet:getAnimation(1)
print("TileSet:getAnimation ->", value)

--@api-stub: TileSet:setSolid
-- Sets whether a 1-based local tile ID is solid for collision purposes.
-- Apply at startup or in response to user input.
local tileSet = lurek.tilemap.newTileSet()
tileSet:setSolid(1, 1)
print("TileSet:setSolid applied")

--@api-stub: TileSet:isSolid
-- Returns whether a 1-based local tile ID is solid.
-- Use as a guard inside lurek.update or event handlers.
local tileSet = lurek.tilemap.newTileSet()
if tileSet:isSolid(1) then print("yes") end
-- swap the constructor for your real handle
print("ok")

-- ── TileMap methods ──

--@api-stub: TileMap:addTileSet
-- Adds a tileset to this map.
-- Side-effecting; safe to call any time after init.
local tileMap = lurek.tilemap.newTileMap()
tileMap:addTileSet(ts_ud)
print("TileMap:addTileSet done")

--@api-stub: TileMap:getTileSetCount
-- Returns the number of tilesets attached to this map.
-- Cheap to call; safe inside callbacks.
local tileMap = lurek.tilemap.newTileMap()  -- or your existing handle
local value = tileMap:getTileSetCount()
print("TileMap:getTileSetCount ->", value)

--@api-stub: TileMap:getTileSet
-- Returns a tileset by 1-based index, or nil if out of range.
-- Cheap to call; safe inside callbacks.
local tileMap = lurek.tilemap.newTileMap()  -- or your existing handle
local value = tileMap:getTileSet(1)
print("TileMap:getTileSet ->", value)

--@api-stub: TileMap:addLayer
-- Adds a new empty layer and returns its 1-based index.
-- Side-effecting; safe to call any time after init.
local tileMap = lurek.tilemap.newTileMap()
tileMap:addLayer("main", 64, 64)
print("TileMap:addLayer done")

--@api-stub: TileMap:getLayerCount
-- Returns the number of layers.
-- Cheap to call; safe inside callbacks.
local tileMap = lurek.tilemap.newTileMap()  -- or your existing handle
local value = tileMap:getLayerCount()
print("TileMap:getLayerCount ->", value)

--@api-stub: TileMap:getLayerName
-- Returns the name of a layer by 1-based index.
-- Cheap to call; safe inside callbacks.
local tileMap = lurek.tilemap.newTileMap()  -- or your existing handle
local value = tileMap:getLayerName(1)
print("TileMap:getLayerName ->", value)

--@api-stub: TileMap:getLayerVisible
-- Returns layer visibility.
-- Cheap to call; safe inside callbacks.
local tileMap = lurek.tilemap.newTileMap()  -- or your existing handle
local value = tileMap:getLayerVisible(1)
print("TileMap:getLayerVisible ->", value)

--@api-stub: TileMap:getLayerColor
-- Returns the RGBA tint color of a layer.
-- Cheap to call; safe inside callbacks.
local tileMap = lurek.tilemap.newTileMap()  -- or your existing handle
local value = tileMap:getLayerColor(1)
print("TileMap:getLayerColor ->", value)

--@api-stub: TileMap:getLayerOffset
-- Returns the pixel offset of a layer.
-- Cheap to call; safe inside callbacks.
local tileMap = lurek.tilemap.newTileMap()  -- or your existing handle
local value = tileMap:getLayerOffset(1)
print("TileMap:getLayerOffset ->", value)

--@api-stub: TileMap:getLayerParallax
-- Returns the parallax factor of a layer.
-- Cheap to call; safe inside callbacks.
local tileMap = lurek.tilemap.newTileMap()  -- or your existing handle
local value = tileMap:getLayerParallax(1)
print("TileMap:getLayerParallax ->", value)

--@api-stub: TileMap:getTile
-- Returns the GID at (x, y) on the given layer (1-based).
-- Cheap to call; safe inside callbacks.
local tileMap = lurek.tilemap.newTileMap()  -- or your existing handle
local value = tileMap:getTile(layer, 100, 100)
print("TileMap:getTile ->", value)

--@api-stub: TileMap:clearTile
-- Clears a tile (sets GID to 0) at (x, y) on the given layer (1-based).
-- Pair with the matching constructor to free resources.
local tileMap = lurek.tilemap.newTileMap()
tileMap:clearTile(layer, 100, 100)
-- tileMap is now released
print("ok")

--@api-stub: TileMap:fill
-- Fills an entire layer with the given GID (1-based layer).
-- See the module spec for detailed semantics.
local tileMap = lurek.tilemap.newTileMap()
tileMap:fill(layer, 1)
print("TileMap:fill done")

--@api-stub: TileMap:getViewport
-- Returns the viewport as (x, y, w, h) or nil if not set.
-- Cheap to call; safe inside callbacks.
local tileMap = lurek.tilemap.newTileMap()  -- or your existing handle
local value = tileMap:getViewport()
print("TileMap:getViewport ->", value)

--@api-stub: TileMap:update
-- Advances tile animation timers by dt seconds.
-- Apply at startup or in response to user input.
local tileMap = lurek.tilemap.newTileMap()
tileMap:update(dt)
print("TileMap:update applied")

--@api-stub: TileMap:worldToTile
-- Converts world pixel coordinates to tile coordinates.
-- See the module spec for detailed semantics.
local tileMap = lurek.tilemap.newTileMap()
tileMap:worldToTile(wx, wy)
print("TileMap:worldToTile done")

--@api-stub: TileMap:tileToWorld
-- Converts tile coordinates to world pixel coordinates (1-based input).
-- See the module spec for detailed semantics.
local tileMap = lurek.tilemap.newTileMap()
tileMap:tileToWorld(tx, ty)
print("TileMap:tileToWorld done")

--@api-stub: TileMap:getTileWidth
-- Returns the tile width in pixels.
-- Cheap to call; safe inside callbacks.
local tileMap = lurek.tilemap.newTileMap()  -- or your existing handle
local value = tileMap:getTileWidth()
print("TileMap:getTileWidth ->", value)

--@api-stub: TileMap:getTileHeight
-- Returns the tile height in pixels.
-- Cheap to call; safe inside callbacks.
local tileMap = lurek.tilemap.newTileMap()  -- or your existing handle
local value = tileMap:getTileHeight()
print("TileMap:getTileHeight ->", value)

--@api-stub: TileMap:getTileDimensions
-- Returns tile dimensions as (width, height).
-- Cheap to call; safe inside callbacks.
local tileMap = lurek.tilemap.newTileMap()  -- or your existing handle
local value = tileMap:getTileDimensions()
print("TileMap:getTileDimensions ->", value)

--@api-stub: TileMap:getChunkSize
-- Returns the chunk size used for spatial partitioning.
-- Cheap to call; safe inside callbacks.
local tileMap = lurek.tilemap.newTileMap()  -- or your existing handle
local value = tileMap:getChunkSize()
print("TileMap:getChunkSize ->", value)

--@api-stub: TileMap:isSolid
-- Returns true if the tile at (x, y) on layer is solid (1-based).
-- Use as a guard inside lurek.update or event handlers.
local tileMap = lurek.tilemap.newTileMap()
if tileMap:isSolid(layer, 100, 100) then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: TileMap:getOrientation
-- Returns the map orientation as a string ("topdown", "sideview", "isometric", or "hexagonal").
-- Cheap to call; safe inside callbacks.
local tileMap = lurek.tilemap.newTileMap()  -- or your existing handle
local value = tileMap:getOrientation()
print("TileMap:getOrientation ->", value)

--@api-stub: TileMap:setOrientation
-- Sets the map orientation from a string ("topdown", "sideview", "isometric", or "hexagonal").
-- Apply at startup or in response to user input.
local tileMap = lurek.tilemap.newTileMap()
tileMap:setOrientation(orientation)
print("TileMap:setOrientation applied")

--@api-stub: TileMap:render
-- Renders the tile map to the screen at the given offset.
-- See the module spec for detailed semantics.
local tileMap = lurek.tilemap.newTileMap()
tileMap:render(ox, oy)
print("TileMap:render done")

--@api-stub: TileMap:drawToImage
-- Renders the tile map to a CPU ImageData using the given tile pixel size.
-- Place inside `function lurek.render() ... end`.
local tileMap = lurek.tilemap.newTileMap()
tileMap:drawToImage(tile_size)
print("TileMap:drawToImage done")

-- ── AutoTileSheet methods ──

--@api-stub: AutoTileSheet:getLayout
-- Returns the layout variant as a string.
-- Cheap to call; safe inside callbacks.
local autoTileSheet = lurek.tilemap.newAutoTileSheet()  -- or your existing handle
local value = autoTileSheet:getLayout()
print("AutoTileSheet:getLayout ->", value)

--@api-stub: AutoTileSheet:getTileCount
-- Returns the number of tiles in this sheet.
-- Cheap to call; safe inside callbacks.
local autoTileSheet = lurek.tilemap.newAutoTileSheet()  -- or your existing handle
local value = autoTileSheet:getTileCount()
print("AutoTileSheet:getTileCount ->", value)

--@api-stub: AutoTileSheet:getTileWidth
-- Returns the tile width in pixels.
-- Cheap to call; safe inside callbacks.
local autoTileSheet = lurek.tilemap.newAutoTileSheet()  -- or your existing handle
local value = autoTileSheet:getTileWidth()
print("AutoTileSheet:getTileWidth ->", value)

--@api-stub: AutoTileSheet:getTileHeight
-- Returns the tile height in pixels.
-- Cheap to call; safe inside callbacks.
local autoTileSheet = lurek.tilemap.newAutoTileSheet()  -- or your existing handle
local value = autoTileSheet:getTileHeight()
print("AutoTileSheet:getTileHeight ->", value)

--@api-stub: AutoTileSheet:getBitmaskForTile
-- Returns the bitmask value associated with a 1-based local tile ID.
-- Cheap to call; safe inside callbacks.
local autoTileSheet = lurek.tilemap.newAutoTileSheet()  -- or your existing handle
local value = autoTileSheet:getBitmaskForTile(1)
print("AutoTileSheet:getBitmaskForTile ->", value)

--@api-stub: AutoTileSheet:getTileForBitmask
-- Returns the 1-based tile ID for a given bitmask, or nil.
-- Cheap to call; safe inside callbacks.
local autoTileSheet = lurek.tilemap.newAutoTileSheet()  -- or your existing handle
local value = autoTileSheet:getTileForBitmask(bitmask)
print("AutoTileSheet:getTileForBitmask ->", value)

--@api-stub: AutoTileSheet:getQuad
-- Returns the atlas region rectangle for the 1-based tile ID.
-- Cheap to call; safe inside callbacks.
local autoTileSheet = lurek.tilemap.newAutoTileSheet()  -- or your existing handle
local value = autoTileSheet:getQuad(1)
print("AutoTileSheet:getQuad ->", value)

-- ── ChunkMap methods ──

--@api-stub: ChunkMap:getTile
-- Returns the GID at tile coordinate (x, y).
-- Cheap to call; safe inside callbacks.
local chunkMap = lurek.tilemap.newChunkMap()  -- or your existing handle
local value = chunkMap:getTile(100, 100)
print("ChunkMap:getTile ->", value)

--@api-stub: ChunkMap:setTile
-- Sets the GID at tile coordinate (x, y).
-- Apply at startup or in response to user input.
local chunkMap = lurek.tilemap.newChunkMap()
chunkMap:setTile(100, 100, 1)
print("ChunkMap:setTile applied")

--@api-stub: ChunkMap:clearTile
-- Clears the tile at (x, y) by setting its GID to 0.
-- Pair with the matching constructor to free resources.
local chunkMap = lurek.tilemap.newChunkMap()
chunkMap:clearTile(100, 100)
-- chunkMap is now released
print("ok")

--@api-stub: ChunkMap:loadChunk
-- Pre-allocates the chunk at chunk coordinates (cx, cy).
-- May block — call from a worker thread for large payloads.
local chunkMap = lurek.tilemap.newChunkMap()
chunkMap:loadChunk(cx, cy)
print("ChunkMap:loadChunk done")

--@api-stub: ChunkMap:unloadChunk
-- Removes the chunk at chunk coordinates (cx, cy) from memory.
-- See the module spec for detailed semantics.
local chunkMap = lurek.tilemap.newChunkMap()
chunkMap:unloadChunk(cx, cy)
print("ChunkMap:unloadChunk done")

--@api-stub: ChunkMap:getChunkSize
-- Returns the chunk size (tiles per side).
-- Cheap to call; safe inside callbacks.
local chunkMap = lurek.tilemap.newChunkMap()  -- or your existing handle
local value = chunkMap:getChunkSize()
print("ChunkMap:getChunkSize ->", value)

--@api-stub: ChunkMap:getLoadedChunks
-- Returns a table of all currently loaded chunk coordinates as {{cx, cy}, ...}.
-- Cheap to call; safe inside callbacks.
local chunkMap = lurek.tilemap.newChunkMap()  -- or your existing handle
local value = chunkMap:getLoadedChunks()
print("ChunkMap:getLoadedChunks ->", value)

--@api-stub: ChunkMap:chunkTileRange
-- Returns the tile coordinate range for chunk (cx, cy) as (x0, y0, x1, y1).
-- See the module spec for detailed semantics.
local chunkMap = lurek.tilemap.newChunkMap()
chunkMap:chunkTileRange(cx, cy)
print("ChunkMap:chunkTileRange done")

-- ── LargeMapRenderer methods ──

--@api-stub: LargeMapRenderer:setTile
-- Sets a single tile ID at (x, y).
-- Apply at startup or in response to user input.
local largeMapRenderer = lurek.tilemap.newLargeMapRenderer()
largeMapRenderer:setTile(100, 100, 1)
print("LargeMapRenderer:setTile applied")

--@api-stub: LargeMapRenderer:getTile
-- Returns the tile ID at (x, y), or nil if out of bounds.
-- Cheap to call; safe inside callbacks.
local largeMapRenderer = lurek.tilemap.newLargeMapRenderer()  -- or your existing handle
local value = largeMapRenderer:getTile(100, 100)
print("LargeMapRenderer:getTile ->", value)

--@api-stub: LargeMapRenderer:getMapSize
-- Returns the map dimensions as (width, height) in tiles.
-- Cheap to call; safe inside callbacks.
local largeMapRenderer = lurek.tilemap.newLargeMapRenderer()  -- or your existing handle
local value = largeMapRenderer:getMapSize()
print("LargeMapRenderer:getMapSize ->", value)

--@api-stub: LargeMapRenderer:setChunkSize
-- Sets the chunk size used for culling (default 16).
-- Apply at startup or in response to user input.
local largeMapRenderer = lurek.tilemap.newLargeMapRenderer()
largeMapRenderer:setChunkSize(10)
print("LargeMapRenderer:setChunkSize applied")

--@api-stub: LargeMapRenderer:getChunkSize
-- Returns the current chunk size.
-- Cheap to call; safe inside callbacks.
local largeMapRenderer = lurek.tilemap.newLargeMapRenderer()  -- or your existing handle
local value = largeMapRenderer:getChunkSize()
print("LargeMapRenderer:getChunkSize ->", value)

--@api-stub: LargeMapRenderer:invalidateChunk
-- Marks a chunk at chunk-grid coordinates (cx, cy) as dirty,.
-- See the module spec for detailed semantics.
local largeMapRenderer = lurek.tilemap.newLargeMapRenderer()
largeMapRenderer:invalidateChunk(cx, cy)
print("LargeMapRenderer:invalidateChunk done")

--@api-stub: LargeMapRenderer:invalidateAll
-- Marks every chunk as dirty.
-- See the module spec for detailed semantics.
local largeMapRenderer = lurek.tilemap.newLargeMapRenderer()
largeMapRenderer:invalidateAll()
print("LargeMapRenderer:invalidateAll done")

--@api-stub: LargeMapRenderer:getVisibleChunks
-- Returns the number of chunks currently within the camera viewport.
-- Cheap to call; safe inside callbacks.
local largeMapRenderer = lurek.tilemap.newLargeMapRenderer()  -- or your existing handle
local value = largeMapRenderer:getVisibleChunks()
print("LargeMapRenderer:getVisibleChunks ->", value)

--@api-stub: LargeMapRenderer:getTotalChunks
-- Returns the total number of chunks that cover the loaded map.
-- Cheap to call; safe inside callbacks.
local largeMapRenderer = lurek.tilemap.newLargeMapRenderer()  -- or your existing handle
local value = largeMapRenderer:getTotalChunks()
print("LargeMapRenderer:getTotalChunks ->", value)

--@api-stub: LargeMapRenderer:setCamera
-- Updates the camera position and zoom used for visibility culling.
-- Apply at startup or in response to user input.
local largeMapRenderer = lurek.tilemap.newLargeMapRenderer()
largeMapRenderer:setCamera(100, 100, zoom)
print("LargeMapRenderer:setCamera applied")

--@api-stub: LargeMapRenderer:setViewport
-- Sets the viewport dimensions in pixels used for visibility culling.
-- Apply at startup or in response to user input.
local largeMapRenderer = lurek.tilemap.newLargeMapRenderer()
largeMapRenderer:setViewport(64, 64)
print("LargeMapRenderer:setViewport applied")

--@api-stub: LargeMapRenderer:setLodEnabled
-- Enables or disables level-of-detail rendering for distant chunks.
-- Apply at startup or in response to user input.
local largeMapRenderer = lurek.tilemap.newLargeMapRenderer()
largeMapRenderer:setLodEnabled(enabled)
print("LargeMapRenderer:setLodEnabled applied")

--@api-stub: LargeMapRenderer:isLodEnabled
-- Returns whether LOD rendering is currently enabled.
-- Use as a guard inside lurek.update or event handlers.
local largeMapRenderer = lurek.tilemap.newLargeMapRenderer()
if largeMapRenderer:isLodEnabled() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: LargeMapRenderer:setLodThresholds
-- Sets the distance thresholds (in tile units) at which each LOD level activates.
-- Apply at startup or in response to user input.
local largeMapRenderer = lurek.tilemap.newLargeMapRenderer()
largeMapRenderer:setLodThresholds(levels)
print("LargeMapRenderer:setLodThresholds applied")

--@api-stub: LargeMapRenderer:setTilesetColumns
-- Sets the number of tile columns in the atlas texture used for UV calculation.
-- Apply at startup or in response to user input.
local largeMapRenderer = lurek.tilemap.newLargeMapRenderer()
largeMapRenderer:setTilesetColumns(10)
print("LargeMapRenderer:setTilesetColumns applied")

--@api-stub: LargeMapRenderer:getTilesetColumns
-- Returns the number of tileset atlas columns.
-- Cheap to call; safe inside callbacks.
local largeMapRenderer = lurek.tilemap.newLargeMapRenderer()  -- or your existing handle
local value = largeMapRenderer:getTilesetColumns()
print("LargeMapRenderer:getTilesetColumns ->", value)

-- ── IsoMap methods ──

--@api-stub: IsoMap:addLevel
-- Appends a new empty Z-level and returns its 1-based index.
-- Side-effecting; safe to call any time after init.
local isoMap = lurek.tilemap.newIsoMap()
isoMap:addLevel()
print("IsoMap:addLevel done")

--@api-stub: IsoMap:getLevelCount
-- Returns the number of Z-levels currently in the map.
-- Cheap to call; safe inside callbacks.
local isoMap = lurek.tilemap.newIsoMap()  -- or your existing handle
local value = isoMap:getLevelCount()
print("IsoMap:getLevelCount ->", value)

--@api-stub: IsoMap:setLevelVisible
-- Sets the visibility of a level (1-based z).
-- Apply at startup or in response to user input.
local isoMap = lurek.tilemap.newIsoMap()
isoMap:setLevelVisible(0, visible)
print("IsoMap:setLevelVisible applied")

--@api-stub: IsoMap:isLevelVisible
-- Returns the visibility of a level (1-based z).
-- Use as a guard inside lurek.update or event handlers.
local isoMap = lurek.tilemap.newIsoMap()
if isoMap:isLevelVisible(0) then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: IsoMap:fillLevel
-- Fills every cell in level z with gid for the given part (1-based z; 0-based part).
-- See the module spec for detailed semantics.
local isoMap = lurek.tilemap.newIsoMap()
isoMap:fillLevel(0, part, 1)
print("IsoMap:fillLevel done")

--@api-stub: IsoMap:setOrigin
-- Sets the screen pixel origin.
-- Apply at startup or in response to user input.
local isoMap = lurek.tilemap.newIsoMap()
isoMap:setOrigin(100, 100)
print("IsoMap:setOrigin applied")

--@api-stub: IsoMap:getWidth
-- Returns the map width in tiles.
-- Cheap to call; safe inside callbacks.
local isoMap = lurek.tilemap.newIsoMap()  -- or your existing handle
local value = isoMap:getWidth()
print("IsoMap:getWidth ->", value)

--@api-stub: IsoMap:getHeight
-- Returns the map height in tiles.
-- Cheap to call; safe inside callbacks.
local isoMap = lurek.tilemap.newIsoMap()  -- or your existing handle
local value = isoMap:getHeight()
print("IsoMap:getHeight ->", value)

--@api-stub: IsoMap:getTileWidth
-- Returns the tile footprint width in pixels.
-- Cheap to call; safe inside callbacks.
local isoMap = lurek.tilemap.newIsoMap()  -- or your existing handle
local value = isoMap:getTileWidth()
print("IsoMap:getTileWidth ->", value)

--@api-stub: IsoMap:getTileHeight
-- Returns the tile footprint height in pixels.
-- Cheap to call; safe inside callbacks.
local isoMap = lurek.tilemap.newIsoMap()  -- or your existing handle
local value = isoMap:getTileHeight()
print("IsoMap:getTileHeight ->", value)

--@api-stub: IsoMap:getLevelHeight
-- Returns the vertical pixel offset between consecutive Z-levels.
-- Cheap to call; safe inside callbacks.
local isoMap = lurek.tilemap.newIsoMap()  -- or your existing handle
local value = isoMap:getLevelHeight()
print("IsoMap:getLevelHeight ->", value)

--@api-stub: IsoMap:tileToScreen
-- Projects isometric tile coordinates (tx, ty, tz) to screen pixels.
-- See the module spec for detailed semantics.
local isoMap = lurek.tilemap.newIsoMap()
isoMap:tileToScreen(tx, ty, tz)
print("IsoMap:tileToScreen done")

--@api-stub: IsoMap:screenToTile
-- Converts screen pixel coordinates to isometric tile coordinates at Z-level 0.
-- See the module spec for detailed semantics.
local isoMap = lurek.tilemap.newIsoMap()
isoMap:screenToTile(sx, sy)
print("IsoMap:screenToTile done")

--@api-stub: IsoMap:getPartCount
-- Returns the number of GID slots per tile.
-- Cheap to call; safe inside callbacks.
local isoMap = lurek.tilemap.newIsoMap()  -- or your existing handle
local value = isoMap:getPartCount()
print("IsoMap:getPartCount ->", value)

--@api-stub: IsoMap:getPartOrder
-- Returns the current draw-order array (0-based part slot indices).
-- Cheap to call; safe inside callbacks.
local isoMap = lurek.tilemap.newIsoMap()  -- or your existing handle
local value = isoMap:getPartOrder()
print("IsoMap:getPartOrder ->", value)

--@api-stub: IsoMap:setPartOrder
-- Overrides the draw order for this IsoMap.
-- Apply at startup or in response to user input.
local isoMap = lurek.tilemap.newIsoMap()
isoMap:setPartOrder(order)
print("IsoMap:setPartOrder applied")

-- ── MapBlock methods ──

--@api-stub: MapBlock:getTile
-- Returns the GID of the tile at (x, y) on the given layer (1-based).
-- Cheap to call; safe inside callbacks.
local mapBlock = lurek.tilemap.newMapBlock()  -- or your existing handle
local value = mapBlock:getTile(layer, 100, 100)
print("MapBlock:getTile ->", value)

--@api-stub: MapBlock:getSide
-- Returns the side connection ID for a segment on a given edge.
-- Cheap to call; safe inside callbacks.
local mapBlock = lurek.tilemap.newMapBlock()  -- or your existing handle
local value = mapBlock:getSide("hello", segment)
print("MapBlock:getSide ->", value)

--@api-stub: MapBlock:getWidth
-- Returns the block width in tiles.
-- Cheap to call; safe inside callbacks.
local mapBlock = lurek.tilemap.newMapBlock()  -- or your existing handle
local value = mapBlock:getWidth()
print("MapBlock:getWidth ->", value)

--@api-stub: MapBlock:getHeight
-- Returns the block height in tiles.
-- Cheap to call; safe inside callbacks.
local mapBlock = lurek.tilemap.newMapBlock()  -- or your existing handle
local value = mapBlock:getHeight()
print("MapBlock:getHeight ->", value)

--@api-stub: MapBlock:getDimensions
-- Returns the block dimensions as (width, height) in tiles.
-- Cheap to call; safe inside callbacks.
local mapBlock = lurek.tilemap.newMapBlock()  -- or your existing handle
local value = mapBlock:getDimensions()
print("MapBlock:getDimensions ->", value)

--@api-stub: MapBlock:getLayerCount
-- Returns the number of layers in this block.
-- Cheap to call; safe inside callbacks.
local mapBlock = lurek.tilemap.newMapBlock()  -- or your existing handle
local value = mapBlock:getLayerCount()
print("MapBlock:getLayerCount ->", value)

--@api-stub: MapBlock:getSegmentSize
-- Returns the segment size in tiles.
-- Cheap to call; safe inside callbacks.
local mapBlock = lurek.tilemap.newMapBlock()  -- or your existing handle
local value = mapBlock:getSegmentSize()
print("MapBlock:getSegmentSize ->", value)

--@api-stub: MapBlock:getWidthInSegments
-- Returns the number of segments along the width.
-- Cheap to call; safe inside callbacks.
local mapBlock = lurek.tilemap.newMapBlock()  -- or your existing handle
local value = mapBlock:getWidthInSegments()
print("MapBlock:getWidthInSegments ->", value)

--@api-stub: MapBlock:getHeightInSegments
-- Returns the number of segments along the height.
-- Cheap to call; safe inside callbacks.
local mapBlock = lurek.tilemap.newMapBlock()  -- or your existing handle
local value = mapBlock:getHeightInSegments()
print("MapBlock:getHeightInSegments ->", value)

--@api-stub: MapBlock:setName
-- Sets the human-readable name of this block.
-- Apply at startup or in response to user input.
local mapBlock = lurek.tilemap.newMapBlock()
mapBlock:setName("main")
print("MapBlock:setName applied")

--@api-stub: MapBlock:getName
-- Returns the name of this block.
-- Cheap to call; safe inside callbacks.
local mapBlock = lurek.tilemap.newMapBlock()  -- or your existing handle
local value = mapBlock:getName()
print("MapBlock:getName ->", value)

--@api-stub: MapBlock:setWeight
-- Sets the placement weight.
-- Apply at startup or in response to user input.
local mapBlock = lurek.tilemap.newMapBlock()
mapBlock:setWeight(weight)
print("MapBlock:setWeight applied")

--@api-stub: MapBlock:getWeight
-- Returns the placement weight.
-- Cheap to call; safe inside callbacks.
local mapBlock = lurek.tilemap.newMapBlock()  -- or your existing handle
local value = mapBlock:getWeight()
print("MapBlock:getWeight ->", value)

-- ── MapGroup methods ──

--@api-stub: MapGroup:addBlock
-- Adds a block to this group.
-- Side-effecting; safe to call any time after init.
local mapGroup = lurek.tilemap.newMapGroup()
mapGroup:addBlock(block_ud)
print("MapGroup:addBlock done")

--@api-stub: MapGroup:getBlockCount
-- Returns the number of blocks in this group.
-- Cheap to call; safe inside callbacks.
local mapGroup = lurek.tilemap.newMapGroup()  -- or your existing handle
local value = mapGroup:getBlockCount()
print("MapGroup:getBlockCount ->", value)

--@api-stub: MapGroup:removeBlock
-- Removes a block by 1-based index.
-- Pair with the matching constructor to free resources.
local mapGroup = lurek.tilemap.newMapGroup()
mapGroup:removeBlock(1)
-- mapGroup is now released
print("ok")

--@api-stub: MapGroup:getName
-- Returns the name of this group.
-- Cheap to call; safe inside callbacks.
local mapGroup = lurek.tilemap.newMapGroup()  -- or your existing handle
local value = mapGroup:getName()
print("MapGroup:getName ->", value)

--@api-stub: MapGroup:addScript
-- Adds a MapScript to this group.
-- Side-effecting; safe to call any time after init.
local mapGroup = lurek.tilemap.newMapGroup()
mapGroup:addScript(script_ud)
print("MapGroup:addScript done")

--@api-stub: MapGroup:getScriptCount
-- Returns the number of scripts in this group.
-- Cheap to call; safe inside callbacks.
local mapGroup = lurek.tilemap.newMapGroup()  -- or your existing handle
local value = mapGroup:getScriptCount()
print("MapGroup:getScriptCount ->", value)

-- ── MapScript methods ──

--@api-stub: MapScript:getStepCount
-- Returns the number of steps in this script.
-- Cheap to call; safe inside callbacks.
local mapScript = lurek.tilemap.newMapScript()  -- or your existing handle
local value = mapScript:getStepCount()
print("MapScript:getStepCount ->", value)

--@api-stub: MapScript:addStep
-- Appends a generation step from a step-definition table.
-- Side-effecting; safe to call any time after init.
local mapScript = lurek.tilemap.newMapScript()
mapScript:addStep(step_def)
print("MapScript:addStep done")

