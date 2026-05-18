--- Tilemap Module Part 4: ChunkMap, IsoMap, LargeMapRenderer, MapBlock, MapGroup, MapScript, MapGen

--@api-stub: lurek.tilemap.newChunkMap
-- Creating an infinite chunk-based tilemap.
do
    ---@type LChunkMap
    local cm = lurek.tilemap.newChunkMap(16)
    print("type = " .. cm:type())
    print("chunk size = " .. cm:getChunkSize())
end

--@api-stub: LChunkMap:setTile / getTile / clearTile
-- Placing and reading tiles in a chunk map.
do
    ---@type LChunkMap
    local cm = lurek.tilemap.newChunkMap(16)
    cm:setTile(10, 20, 5)
    cm:setTile(-5, 3, 8)
    cm:setTile(100, 200, 12)
    local gid = cm:getTile(10, 20)
    print("tile at 10,20 = " .. gid)
    cm:clearTile(10, 20)
    gid = cm:getTile(10, 20)
    print("after clear = " .. gid)
end

--@api-stub: LChunkMap:fillRect
-- Filling a rectangular area with tiles.
do
    ---@type LChunkMap
    local cm = lurek.tilemap.newChunkMap(16)
    cm:fillRect(0, 0, 10, 10, 3)
    print("filled 11x11 area with gid=3")
    print("sample (5,5) = " .. cm:getTile(5, 5))
    print("sample (11,11) = " .. cm:getTile(11, 11))
end

--@api-stub: LChunkMap:loadChunk / unloadChunk / getLoadedChunks
-- Manual chunk loading and unloading.
do
    ---@type LChunkMap
    local cm = lurek.tilemap.newChunkMap(16)
    cm:loadChunk(0, 0)
    cm:loadChunk(1, 0)
    cm:loadChunk(0, 1)
    local loaded = cm:getLoadedChunks()
    print("loaded chunks = " .. #loaded)
    for _, c in ipairs(loaded) do
        print("  chunk (" .. c.cx .. ", " .. c.cy .. ")")
    end
    cm:unloadChunk(1, 0)
    loaded = cm:getLoadedChunks()
    print("after unload = " .. #loaded .. " chunks")
end

--@api-stub: LChunkMap:chunkTileRange
-- Getting the tile coordinate range for a chunk.
do
    ---@type LChunkMap
    local cm = lurek.tilemap.newChunkMap(16)
    local minX, minY, maxX, maxY = cm:chunkTileRange(2, 3)
    print("chunk (2,3) covers tiles:")
    print("  min = " .. minX .. ", " .. minY)
    print("  max = " .. maxX .. ", " .. maxY)
end

--@api-stub: LChunkMap:getChunksInView
-- Finding chunks visible in a viewport.
do
    ---@type LChunkMap
    local cm = lurek.tilemap.newChunkMap(16)
    local visible = cm:getChunksInView(0, 0, 800, 600, 32, 32)
    print("visible chunks in 800x600 viewport: " .. #visible)
    for i = 1, math.min(3, #visible) do
        print("  chunk (" .. visible[i].cx .. ", " .. visible[i].cy .. ")")
    end
end

--@api-stub: lurek.tilemap.newIsoMap
-- Creating an isometric map.
do
    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(20, 20, 64, 32, 16)
    print("type = " .. iso:type())
    print("size = " .. iso:getWidth() .. "x" .. iso:getHeight())
    print("tile size = " .. iso:getTileWidth() .. "x" .. iso:getTileHeight())
    print("level height = " .. iso:getLevelHeight())
end

--@api-stub: LIsoMap:addLevel / getLevelCount / setTilePart / getTilePart
-- Managing iso map levels and tile parts.
do
    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    print("part count = " .. iso:getPartCount())
    local lvl = iso:addLevel()
    print("added level, count = " .. iso:getLevelCount())
    iso:setTilePart(1, 3, 4, 1, 5)
    local gid = iso:getTilePart(1, 3, 4, 1)
    print("tile part at (1,3,4,part=1) = " .. gid)
end

--@api-stub: LIsoMap:fillLevel / isLevelVisible / setLevelVisible
-- Filling and toggling iso levels.
do
    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(8, 8, 64, 32, 16)
    iso:addLevel()
    iso:fillLevel(1, 1, 3)
    print("filled level 1, part 1 with gid=3")
    print("level 1 visible = " .. tostring(iso:isLevelVisible(1)))
    iso:setLevelVisible(1, false)
    print("after hide = " .. tostring(iso:isLevelVisible(1)))
end

--@api-stub: LIsoMap:screenToTile / tileToScreen / setOrigin
-- Isometric coordinate transforms.
do
    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16)
    iso:setOrigin(400, 100)
    local sx, sy = iso:tileToScreen(3, 2, 1)
    print("tile(3,2,z=1) -> screen(" .. sx .. ", " .. sy .. ")")
    local tx, ty = iso:screenToTile(sx, sy)
    print("screen -> tile(" .. tx .. ", " .. ty .. ")")
end

--@api-stub: LIsoMap:setPartOrder / getPartOrder
-- Changing the draw order of tile parts.
do
    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(5, 5, 64, 32, 16, 4)
    local order = iso:getPartOrder()
    print("default part order: " .. #order .. " entries")
    iso:setPartOrder({ 4, 3, 2, 1 })
    order = iso:getPartOrder()
    print("reversed order[1] = " .. order[1])
end

--@api-stub: lurek.tilemap.newLargeMapRenderer
-- Creating a large-map renderer for very big worlds.
do
    ---@type LLargeMapRenderer
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    print("type = " .. lmr:type())
    print("chunk size = " .. lmr:getChunkSize())
end

--@api-stub: LLargeMapRenderer:setMapData / getMapSize / getTile / setTile
-- Loading tile data into the large-map renderer.
do
    ---@type LLargeMapRenderer
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local data = {}
    for i = 1, 100 * 100 do
        data[i] = (i % 4) + 1
    end
    lmr:setMapData(data, 100, 100)
    local w, h = lmr:getMapSize()
    print("map size = " .. w .. "x" .. h)
    print("tile at (50,50) = " .. lmr:getTile(50, 50))
    lmr:setTile(50, 50, 99)
    print("after set = " .. lmr:getTile(50, 50))
end

--@api-stub: LLargeMapRenderer:setCamera / setViewport / getVisibleChunks / getTotalChunks
-- Camera and viewport setup.
do
    ---@type LLargeMapRenderer
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local data = {}
    for i = 1, 200 * 200 do data[i] = 1 end
    lmr:setMapData(data, 200, 200)
    lmr:setViewport(800, 600)
    lmr:setCamera(3200, 3200, 1.0)
    print("total chunks = " .. lmr:getTotalChunks())
    print("visible chunks = " .. lmr:getVisibleChunks())
end

--@api-stub: LLargeMapRenderer:setLodEnabled / isLodEnabled / setLodThresholds
-- Level-of-detail configuration.
do
    ---@type LLargeMapRenderer
    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
    print("LOD enabled = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodEnabled(true)
    print("after enable = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodThresholds({ 0.5, 0.25, 0.1 })
    print("LOD thresholds set")
end

--@api-stub: LLargeMapRenderer:invalidateAll / invalidateChunk / setChunkSize / setTilesetColumns
-- Chunk invalidation and configuration.
do
    ---@type LLargeMapRenderer
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    lmr:setChunkSize(32)
    print("chunk size = " .. lmr:getChunkSize())
    lmr:setTilesetColumns(16)
    print("tileset columns = " .. lmr:getTilesetColumns())
    lmr:invalidateChunk(0, 0)
    lmr:invalidateAll()
    print("all chunks invalidated")
end

--@api-stub: lurek.tilemap.newMapBlock
-- Creating a procedural map block.
do
    ---@type LMapBlock
    local block = lurek.tilemap.newMapBlock(8, 8, 2, 2)
    print("type = " .. block:type())
    local w, h = block:getDimensions()
    print("dimensions = " .. w .. "x" .. h)
    print("layers = " .. block:getLayerCount())
    print("segment size = " .. block:getSegmentSize())
    print("width in segments = " .. block:getWidthInSegments())
    print("height in segments = " .. block:getHeightInSegments())
end

--@api-stub: LMapBlock:setTile / getTile / setName / getName / setWeight / getWeight
-- Editing map block content and metadata.
do
    ---@type LMapBlock
    local block = lurek.tilemap.newMapBlock(4, 4)
    block:setName("room_corner")
    print("name = " .. block:getName())
    block:setWeight(3.0)
    print("weight = " .. block:getWeight())
    block:setTile(1, 1, 1, 5)
    block:setTile(1, 2, 2, 8)
    print("tile (1,1,1) = " .. block:getTile(1, 1, 1))
    print("tile (1,2,2) = " .. block:getTile(1, 2, 2))
end

--@api-stub: LMapBlock:setSide / getSide
-- Edge matching for procedural generation.
do
    ---@type LMapBlock
    local block = lurek.tilemap.newMapBlock(4, 4, 1, 2)
    block:setSide("north", 1, 10)
    block:setSide("north", 2, 20)
    block:setSide("south", 1, 10)
    block:setSide("east", 1, 30)
    print("north seg 1 = " .. block:getSide("north", 1))
    print("north seg 2 = " .. block:getSide("north", 2))
    print("east seg 1 = " .. block:getSide("east", 1))
end

--@api-stub: lurek.tilemap.newMapGroup / LMapGroup
-- Creating a map group and adding blocks.
do
    ---@type LMapGroup
    local group = lurek.tilemap.newMapGroup("dungeon")
    print("type = " .. group:type())
    print("name = " .. group:getName())
    ---@type LMapBlock
    local b1 = lurek.tilemap.newMapBlock(4, 4)
    b1:setName("corridor")
    ---@type LMapBlock
    local b2 = lurek.tilemap.newMapBlock(4, 4)
    b2:setName("room")
    group:addBlock(b1)
    group:addBlock(b2)
    print("block count = " .. group:getBlockCount())
    group:removeBlock(1)
    print("after remove = " .. group:getBlockCount())
end

--@api-stub: lurek.tilemap.newMapScript / LMapScript
-- Creating a map generation script with steps.
do
    ---@type LMapScript
    local script = lurek.tilemap.newMapScript()
    print("type = " .. script:type())
    script:addStep({ type = "fill", gid = 1 })
    script:addStep({ type = "scatter", gid = 5, chance = 0.1 })
    script:addStep({ type = "border", gid = 2 })
    print("step count = " .. script:getStepCount())
end

--@api-stub: lurek.tilemap.newMapGen / LMapGen:generate
-- Procedural map generation.
do
    ---@type LMapGroup
    local group = lurek.tilemap.newMapGroup("caves")
    ---@type LMapBlock
    local block = lurek.tilemap.newMapBlock(4, 4)
    block:setName("open")
    block:setTile(1, 1, 1, 1)
    block:setTile(1, 2, 2, 1)
    group:addBlock(block)
    ---@type LMapScript
    local script = lurek.tilemap.newMapScript()
    script:addStep({ type = "fill", gid = 1 })
    group:addScript(script)
    ---@type LMapGen
    local gen = lurek.tilemap.newMapGen(group, "small", 1)
    print("type = " .. gen:type())
    ---@type LTileMap
    local result = gen:generate(1, 42, "terrain")
    print("generated map type = " .. result:type())
end

--@api-stub: lurek.tilemap.newMapGen with explicit dimensions
-- Map generation using explicit width and height.
do
    ---@type LMapGroup
    local group = lurek.tilemap.newMapGroup("plains")
    ---@type LMapBlock
    local block = lurek.tilemap.newMapBlock(4, 4, 1, 1)
    block:setName("grass")
    group:addBlock(block)
    ---@type LMapGen
    local gen = lurek.tilemap.newMapGen(group, 20, 15, 2)
    ---@type LTileMap
    local result = gen:generate()
    print("generated 20x15 map, type = " .. result:type())
end

print("tilemap_03.lua")
