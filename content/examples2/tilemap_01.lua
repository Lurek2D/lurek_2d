--- Tilemap Module Part 2: auto-tiling, collision sweep, tile callbacks, navigation

--@api-stub: LTileSet:setAutoTileRule
--@api-stub: LTileSet:getAutoTileId
-- 4-bit auto-tile rules.
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    ts:setAutoTileRule("grass", 0, 1)
    ts:setAutoTileRule("grass", 1, 2)
    ts:setAutoTileRule("grass", 2, 3)
    ts:setAutoTileRule("grass", 3, 4)
    ts:setAutoTileRule("grass", 15, 16)
    local id = ts:getAutoTileId("grass", 0)
    print("bitmask 0 -> tile " .. id)
    id = ts:getAutoTileId("grass", 15)
    print("bitmask 15 -> tile " .. id)
end

--@api-stub: LTileSet:setAutoTileRule8
--@api-stub: LTileSet:getAutoTileId8
-- 8-bit auto-tile rules for smoother transitions.
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 256, 16, 16, 16)
    ts:setAutoTileRule8("wall", 0, 1)
    ts:setAutoTileRule8("wall", 255, 48)
    ts:setAutoTileRule8("wall", 127, 32)
    local id = ts:getAutoTileId8("wall", 255)
    print("8-bit bitmask 255 -> tile " .. id)
    id = ts:getAutoTileId8("wall", 0)
    print("8-bit bitmask 0 -> tile " .. id)
end

--@api-stub: lurek.tilemap.newAutoTileSheet
-- Auto-tile sheet creation with different layouts.
do
    ---@type LAutoTileSheet
    local blob = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    print("blob47 layout = " .. blob:getLayout())
    print("blob47 tile count = " .. blob:getTileCount())
    print("blob47 tile size = " .. blob:getTileWidth() .. "x" .. blob:getTileHeight())

    ---@type LAutoTileSheet
    local minimal = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")
    print("minimal16 tile count = " .. minimal:getTileCount())
end

--@api-stub: LAutoTileSheet:applyToTileSet
-- Applying an auto-tile sheet to a tileset.
do
    ---@type LAutoTileSheet
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 64, 8, 16, 16)
    sheet:applyToTileSet(ts, "terrain")
    local id = ts:getAutoTileId("terrain", 5)
    print("after apply, bitmask 5 -> tile " .. id)
    sheet:applyToTileSet(ts, "water", 17)
    id = ts:getAutoTileId("water", 0)
    print("water bitmask 0 -> tile " .. id)
end

--@api-stub: LAutoTileSheet:getBitmaskForTile
--@api-stub: LAutoTileSheet:getTileForBitmask
-- Bitmask <-> tile lookups.
do
    ---@type LAutoTileSheet
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")
    local bitmask = sheet:getBitmaskForTile(3)
    print("tile 3 has bitmask = " .. bitmask)
    local tile = sheet:getTileForBitmask(7)
    print("bitmask 7 -> tile " .. tile)
end

--@api-stub: LAutoTileSheet:getQuad
-- Getting source quad from auto-tile sheet.
do
    ---@type LAutoTileSheet
    local sheet = lurek.tilemap.newAutoTileSheet(32, 32, "composite48")
    print("composite48 count = " .. sheet:getTileCount())
    local x, y, w, h = sheet:getQuad(1)
    print("quad 1: x=" .. x .. " y=" .. y .. " w=" .. w .. " h=" .. h)
end

--@api-stub: LTileMap:applyAutoTile
-- Applying 4-bit auto-tiling to an entire layer.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(16, 16)
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    ---@type LAutoTileSheet
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")
    sheet:applyToTileSet(ts, "grass")
    map:addTileSet(ts)
    local layer = map:addLayer("terrain", 10, 10)
    map:fill(layer, 1)
    map:applyAutoTile(layer, "grass")
    print("4-bit auto-tile applied")
    local gid = map:getTile(layer, 5, 5)
    print("center tile after auto = " .. gid)
end

--@api-stub: LTileMap:applyAutoTile8
-- 8-bit auto-tiling for smoother corners.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(16, 16)
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 256, 16, 16, 16)
    for i = 0, 255 do
        ts:setAutoTileRule8("wall", i, i + 1)
    end
    map:addTileSet(ts)
    local layer = map:addLayer("walls", 8, 8)
    map:setTile(layer, 3, 3, 1)
    map:setTile(layer, 4, 3, 1)
    map:setTile(layer, 3, 4, 1)
    map:applyAutoTile8(layer, "wall")
    print("8-bit auto-tile applied")
end

--@api-stub: LTileMap:applyAutoTileAt
--@api-stub: LTileMap:applyAutoTile8At
-- Auto-tiling a single cell without recalculating the whole layer.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(16, 16)
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    ---@type LAutoTileSheet
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")
    sheet:applyToTileSet(ts, "dirt")
    map:addTileSet(ts)
    local layer = map:addLayer("ground", 10, 10)
    map:fill(layer, 1)
    map:applyAutoTileAt(layer, 5, 5, "dirt")
    print("single cell auto-tiled at 5,5")
    map:applyAutoTile8At(layer, 3, 3, "dirt")
    print("single cell 8-bit auto-tiled at 3,3")
end

--@api-stub: LTileMap:sweepRect
-- Swept collision resolution for moving entities.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 32, 32)
    ts:setSolid(1, true)
    map:addTileSet(ts)
    local layer = map:addLayer("collision", 20, 20)
    map:setTile(layer, 5, 5, 1)
    map:setTile(layer, 6, 5, 1)
    -- Sweep a 16x16 rect from (64,64) moving right by 200px
    local cx, cy, nx, ny, tx, ty = map:sweepRect(layer, 64, 64, 16, 16, 200, 0)
    print("contact pos = " .. cx .. ", " .. cy)
    print("normal = " .. nx .. ", " .. ny)
    print("time = " .. tx .. ", " .. ty)
end

--@api-stub: LTileMap:onTileEnter
--@api-stub: LTileMap:onTileExit
--@api-stub: LTileMap:onTileStep
-- Tile-based event callbacks.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("triggers", 10, 10)
    map:setTile(layer, 3, 3, 5)
    map:setTile(layer, 7, 2, 5)
    map:onTileEnter(5, function(entity, tx, ty)
        print("entity entered trigger tile at " .. tx .. "," .. ty)
    end)
    map:onTileExit(5, function(entity, tx, ty)
        print("entity left trigger tile at " .. tx .. "," .. ty)
    end)
    map:onTileStep(5, function(entity, tx, ty)
        print("entity stepping on trigger at " .. tx .. "," .. ty)
    end)
    print("3 callbacks registered for gid=5")
end

--@api-stub: LTileMap:checkEntities
--@api-stub: LTileMap:fireTileExit
--@api-stub: LTileMap:fireTileStep
-- Driving tile callbacks from entity positions.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("events", 10, 10)
    map:setTile(layer, 2, 2, 3)
    map:onTileEnter(3, function(entity, tx, ty)
        print("entered at " .. tx .. "," .. ty)
    end)
    -- entities table has x,y fields for world-space positions
    local entities = {
        { x = 64, y = 64 },
        { x = 128, y = 128 },
    }
    map:checkEntities(layer, entities)
    print("entities checked against tile events")
    map:fireTileExit(3, entities[1], 2, 2)
    map:fireTileStep(3, entities[1], 2, 2)
end

--@api-stub: LTileMap:tileTypeIndex
-- Getting tile type distribution for a layer.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("terrain", 5, 5)
    map:setTile(layer, 0, 0, 1)
    map:setTile(layer, 1, 0, 1)
    map:setTile(layer, 2, 0, 2)
    map:setTile(layer, 3, 0, 3)
    local index = map:tileTypeIndex(layer)
    print("tile type index built")
    for gid, positions in pairs(index) do
        print("  gid " .. gid .. " has " .. #positions .. " tiles")
    end
end

--@api-stub: LTileMap:toNavGrid
-- Converting tilemap to navigation boolean grid.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 8, 4, 32, 32)
    ts:setSolid(1, true)
    ts:setSolid(2, true)
    map:addTileSet(ts)
    local layer = map:addLayer("nav", 5, 5)
    map:setTile(layer, 2, 2, 1)
    map:setTile(layer, 3, 2, 2)
    local grid = map:toNavGrid(layer, { 1, 2 })
    print("nav grid built with " .. #grid .. " cells")
    -- grid[i] = true means passable, false means blocked
end

--@api-stub: LTileMap:setTileTint
-- Per-tile color tinting.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("tinted", 10, 10)
    map:setTile(layer, 0, 0, 1)
    map:setTile(layer, 1, 0, 1)
    map:setTile(layer, 2, 0, 1)
    map:setTileTint(layer, 0, 0, 1.0, 0.0, 0.0, 1.0)
    map:setTileTint(layer, 1, 0, 0.0, 1.0, 0.0, 1.0)
    map:setTileTint(layer, 2, 0, 0.0, 0.0, 1.0, 1.0)
    print("RGB tints applied to 3 tiles")
end

--@api-stub: LTileMap:setOrientation
--@api-stub: LTileMap:getOrientation
-- Map orientation setting.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 10, 10)
    print("default orientation = " .. map:getOrientation())
    map:setOrientation("isometric")
    print("set to " .. map:getOrientation())
    map:setOrientation("hexagonal")
    print("set to " .. map:getOrientation())
    map:setOrientation("topdown")
    print("back to " .. map:getOrientation())
end

--@api-stub: LTileMap:drawToImage
-- Rasterizing the map to an image for caching.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(16, 16)
    local layer = map:addLayer("simple", 8, 8)
    map:fill(layer, 1)
    ---@type LImage
    local img = map:drawToImage(16)
    print("image type = " .. img:type())
    print("drawn to image at tile size 16")
end

--@api-stub: LTileMap:update
-- Updating animated tiles each frame.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("animated", 10, 10)
    -- In a game loop:
    local dt = 1 / 60
    map:update(dt)
    map:update(dt)
    map:update(dt)
    print("updated 3 frames at 60fps")
end

print("tilemap_01.lua")
