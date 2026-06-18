-- content/examples/tilemap.lua
-- Auto-generated from content/examples2/tilemap_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/tilemap.lua

local function tilemap_log(message)
    lurek.log.info("[tilemap] " .. message)
end

local tilemap_log_count = 0
local tilemap_log_limit = 96

local function example_print_log(...)
    tilemap_log_count = tilemap_log_count + 1
    if tilemap_log_count > tilemap_log_limit then
        return
    end
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    tilemap_log(table.concat(parts, " "))
end

--- Tilemap Module Part 1: map creation, layers, tiles, tilesets, solids, viewport

local function example_print_log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    lurek.log.info(table.concat(parts, " "))
end

--@api: lurek.tilemap.newTileMap
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    example_print_log("type = " .. map:type())
    local tw, th = map:getTileDimensions()
    local chunk_size = map:getChunkSize()
    example_print_log("tile size = " .. tw .. "x" .. th)
    example_print_log("chunk size = " .. chunk_size)
end

--@api: LTileMap:addLayer
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    local ground = map:addLayer("ground", 50, 50)
    local decor = map:addLayer("decor", 50, 50)
    local count = map:getLayerCount()
    example_print_log("ground layer idx = " .. ground)
    example_print_log("decor layer idx = " .. decor)
    example_print_log("layer count = " .. count)
end

--@api: LTileMap:getLayerName
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("terrain", 40, 30)
    map:addLayer("props", 40, 30)
    local second_name = map:getLayerName(2)
    example_print_log("layer 1 = " .. map:getLayerName(1))
    example_print_log("layer 2 = " .. second_name)
end

--@api: LTileMap:getLayerCount
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("terrain", 40, 30)
    map:addLayer("props", 40, 30)
    local second = map:getLayerName(2)
    example_print_log("layer count = " .. map:getLayerCount())
    example_print_log("second layer = " .. second)
end

--@api: LTileMap:setTile
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)
    map:setTile(layer, 3, 4, 5)
    local gid = map:getTile(layer, 3, 4)
    example_print_log("tile at 3,4 = " .. gid)
end

--@api: LTileMap:getTile
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)
    map:setTile(layer, 3, 4, 5)
    local gid = map:getTile(layer, 3, 4)
    example_print_log("tile at 3,4 = " .. gid)
end

--@api: LTileMap:clearTile
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)
    map:setTile(layer, 3, 4, 5)
    map:clearTile(layer, 3, 4)
    local gid = map:getTile(layer, 3, 4)
    example_print_log("after clear = " .. gid)
end

--@api: LTileMap:fill
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("ground", 20, 20)
    map:fill(layer, 3)
    example_print_log("fill complete, sample = " .. map:getTile(layer, 10, 10))
    example_print_log("corner = " .. map:getTile(layer, 1, 1))
end

--@api: LTileMap:findTilesByGid
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)

    map:setTile(layer, 2, 3, 7)
    map:setTile(layer, 5, 1, 7)
    map:setTile(layer, 8, 9, 7)
    map:setTile(layer, 4, 4, 2)

    local positions = map:findTilesByGid(layer, 7)
    example_print_log("found gid=7 count = " .. #positions)
    for _, pos in ipairs(positions) do
        example_print_log("  x=" .. pos.x .. " y=" .. pos.y)
    end
end

--@api: lurek.tilemap.newTileSet
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 64, 8, 32, 32)
    example_print_log("type = " .. ts:type())
    example_print_log("first gid = " .. ts:getFirstGid())
    example_print_log("tile count = " .. ts:getTileCount())
    example_print_log("columns = " .. ts:getColumns())
end

--@api: LTileSet:isSolid
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 32, 32)
    ts:setSolid(1, true)
    ts:setSolid(2, false)
    example_print_log("tile 1 solid = " .. tostring(ts:isSolid(1)))
    example_print_log("tile 2 solid = " .. tostring(ts:isSolid(2)))
end

--@api: LTileSet:setSolid
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 32, 32)
    ts:setSolid(1, true)
    ts:setSolid(2, false)
    local wall = ts:isSolid(1)
    example_print_log("tile 1 solid = " .. tostring(ts:isSolid(1)))
    example_print_log("tile 2 solid = " .. tostring(ts:isSolid(2)))
    example_print_log("wall collision flag = " .. tostring(wall))
end

--@api: LTileSet:getQuad
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 32, 32)
    local q1 = ts:getQuad(1)
    example_print_log("tile 1: x=" .. q1.x .. " y=" .. q1.y .. " w=" .. q1.width .. " h=" .. q1.height)
    local q5 = ts:getQuad(5)
    example_print_log("tile 5: x=" .. q5.x .. " y=" .. q5.y .. " w=" .. q5.width .. " h=" .. q5.height)
end

--@api: LTileSet:setAnimation
do
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    ts:setAnimation(1, {
        { tileid = 1, duration = 200 },
        { tileid = 2, duration = 200 },
        { tileid = 3, duration = 200 },
        { tileid = 4, duration = 200 },
    })

    local anim = ts:getAnimation(1)
    example_print_log("animation frames = " .. #anim)
    for i, frame in ipairs(anim) do
        example_print_log("  frame " .. i .. ": tile=" .. frame.tileid .. " dur=" .. frame.duration)
    end
    local noAnim = ts:getAnimation(10)
    example_print_log("tile 10 anim = " .. tostring(noAnim))
end

--@api: LTileSet:getAnimation
do
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    ts:setAnimation(1, {
        { tileid = 1, duration = 200 },
        { tileid = 2, duration = 200 },
        { tileid = 3, duration = 200 },
        { tileid = 4, duration = 200 },
    })

    local anim = ts:getAnimation(1)
    example_print_log("animation frames = " .. #anim)
    for i, frame in ipairs(anim) do
        example_print_log("  frame " .. i .. ": tile=" .. frame.tileid .. " dur=" .. frame.duration)
    end
    local noAnim = ts:getAnimation(10)
    example_print_log("tile 10 anim = " .. tostring(noAnim))
end

--@api: LTileMap:addTileSet
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local terrain = lurek.tilemap.newTileSet(1, 64, 8, 32, 32)
    local objects = lurek.tilemap.newTileSet(65, 32, 8, 32, 32)

    map:addTileSet(terrain)
    map:addTileSet(objects)
    example_print_log("tileset count = " .. map:getTileSetCount())
end

--@api: LTileMap:getTileSet
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local terrain = lurek.tilemap.newTileSet(1, 64, 8, 32, 32)
    local objects = lurek.tilemap.newTileSet(65, 32, 8, 32, 32)

    map:addTileSet(terrain)
    map:addTileSet(objects)
    local ts1 = map:getTileSet(1)
    example_print_log("tileset 1 first gid = " .. ts1:getFirstGid())
end

--@api: LTileMap:getTileSetCount
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local terrain = lurek.tilemap.newTileSet(1, 64, 8, 32, 32)
    local objects = lurek.tilemap.newTileSet(65, 32, 8, 32, 32)

    map:addTileSet(terrain)
    map:addTileSet(objects)
    example_print_log("tileset count = " .. map:getTileSetCount())
end

--@api: LTileMap:isSolid
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 32, 32)
    ts:setSolid(1, true)
    map:addTileSet(ts)

    local layer = map:addLayer("collision", 10, 10)
    map:setTile(layer, 3, 3, 1)
    map:setTile(layer, 4, 3, 1)

    example_print_log("3,3 solid = " .. tostring(map:isSolid(layer, 3, 3)))
    example_print_log("5,5 solid = " .. tostring(map:isSolid(layer, 5, 5)))
end

--@api: LTileMap:rectOverlapsSolid
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 32, 32)
    ts:setSolid(1, true)
    map:addTileSet(ts)

    local layer = map:addLayer("collision", 10, 10)
    map:setTile(layer, 3, 3, 1)
    map:setTile(layer, 4, 3, 1)

    local overlap = map:rectOverlapsSolid(layer, 80, 80, 40, 40)
    example_print_log("rect overlaps solid = " .. tostring(overlap))
    example_print_log("note: rectOverlapsSolid is a tile query pre-check; physics bodies need explicit lurek.physics colliders")
end

--@api: LTileMap:setViewport
do
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("ground", 100, 100)
    map:setViewport(0, 0, 800, 600)
    local vx, vy, vw, vh = map:getViewport()
    example_print_log("viewport = " .. vx .. "," .. vy .. " " .. vw .. "x" .. vh)
end

--@api: LTileMap:getViewport
do
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("ground", 100, 100)
    map:setViewport(0, 0, 800, 600)
    local vx, vy, vw, vh = map:getViewport()
    example_print_log("viewport = " .. vx .. "," .. vy .. " " .. vw .. "x" .. vh)
end

--@api: LTileMap:render
do
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("ground", 100, 100)
    map:setViewport(0, 0, 800, 600)

    map:render()
    example_print_log("rendered at origin")
    map:render(10, 10)
    example_print_log("rendered with offset")
end

--@api: LTileMap:worldToTile
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 20, 20)
    local tx, ty = map:worldToTile(100, 80)
    local wx, wy = map:tileToWorld(tx, ty)
    example_print_log("world(100,80) -> tile(" .. tx .. "," .. ty .. ")")
    example_print_log("tile(" .. tx .. "," .. ty .. ") -> world(" .. wx .. "," .. wy .. ")")
end

--@api: LTileMap:tileToWorld
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 20, 20)
    local wx, wy = map:tileToWorld(5, 3)
    local tx, ty = map:worldToTile(wx, wy)
    example_print_log("tile(5,3) -> world(" .. wx .. "," .. wy .. ")")
    example_print_log("round trip -> tile(" .. tx .. "," .. ty .. ")")
end

--@api: LTileMap:setLayerVisible
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("background", 20, 20)
    map:setLayerVisible(1, false)
    local hidden = map:getLayerVisible(1)
    example_print_log("after hide = " .. tostring(map:getLayerVisible(1)))
    map:setLayerVisible(1, true)
    example_print_log("hidden flag = " .. tostring(hidden))
    example_print_log("after show = " .. tostring(map:getLayerVisible(1)))
end

--@api: LTileMap:getLayerVisible
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("background", 20, 20)
    local before = map:getLayerVisible(1)
    map:setLayerVisible(1, false)
    example_print_log("layer 1 visible = " .. tostring(map:getLayerVisible(1)))
    example_print_log("default visible = " .. tostring(before))
    example_print_log("after hide = " .. tostring(map:getLayerVisible(1)))
end

--@api: LTileMap:setLayerColor
do
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("tinted", 10, 10)
    map:setLayerColor(1, 0.8, 0.5, 0.5, 0.9)
    local r, g, b, a = map:getLayerColor(1)
    example_print_log("layer color = " .. r .. ", " .. g .. ", " .. b .. ", " .. a)
end

--@api: LTileMap:getLayerColor
do
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("tinted", 10, 10)
    map:setLayerColor(1, 0.8, 0.5, 0.5, 0.9)
    local r, g, b, a = map:getLayerColor(1)
    example_print_log("layer color = " .. r .. ", " .. g .. ", " .. b .. ", " .. a)
end

--@api: LTileMap:setLayerOffset
do
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("shifted", 10, 10)
    map:setLayerOffset(1, 16, 8)
    local ox, oy = map:getLayerOffset(1)
    example_print_log("offset = " .. ox .. ", " .. oy)
end

--@api: LTileMap:getLayerOffset
do
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("shifted", 10, 10)
    map:setLayerOffset(1, 16, 8)
    local ox, oy = map:getLayerOffset(1)
    example_print_log("offset = " .. ox .. ", " .. oy)
end

--@api: LTileMap:setLayerParallax
do
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("background", 40, 30)
    map:setLayerParallax(1, 0.5, 0.5)
    local px, py = map:getLayerParallax(1)
    example_print_log("bg parallax = " .. px .. ", " .. py)
end

--@api: LTileMap:getLayerParallax
do
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("background", 40, 30)
    map:setLayerParallax(1, 0.5, 0.5)
    local px, py = map:getLayerParallax(1)
    example_print_log("bg parallax = " .. px .. ", " .. py)
end

--- Tilemap Module Part 2: auto-tiling, collision sweep, tile callbacks, navigation

--@api: LTileSet:setAutoTileRule
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    ts:setAutoTileRule("grass", 0, 1)
    ts:setAutoTileRule("grass", 15, 16)
    local id = ts:getAutoTileId("grass", 0)
    example_print_log("bitmask 0 -> tile " .. id)
    example_print_log("bitmask 15 -> tile " .. ts:getAutoTileId("grass", 15))
end

--@api: LTileSet:getAutoTileId
do
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    ts:setAutoTileRule("grass", 0, 1)
    ts:setAutoTileRule("grass", 15, 16)
    local id = ts:getAutoTileId("grass", 15)
    example_print_log("bitmask 15 -> tile " .. id)
end

--@api: LTileSet:setAutoTileRule8
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 256, 16, 16, 16)
    ts:setAutoTileRule8("wall", 0, 1)
    ts:setAutoTileRule8("wall", 255, 48)
    local id = ts:getAutoTileId8("wall", 0)
    example_print_log("8-bit bitmask 0 -> tile " .. id)
    example_print_log("8-bit bitmask 255 -> tile " .. ts:getAutoTileId8("wall", 255))
end

--@api: LTileSet:getAutoTileId8
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 256, 16, 16, 16)
    ts:setAutoTileRule8("wall", 255, 48)
    local id = ts:getAutoTileId8("wall", 255)
    ts:setAutoTileRule8("wall", 0, 1)
    local edge = ts:getAutoTileId8("wall", 0)
    example_print_log("8-bit bitmask 255 -> tile " .. id)
    example_print_log("8-bit bitmask 0 -> tile " .. edge)
end

--@api: lurek.tilemap.newAutoTileSheet
do
    local blob = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    example_print_log("blob47 layout = " .. blob:getLayout())
    example_print_log("blob47 tile count = " .. blob:getTileCount())
    example_print_log("blob47 tile size = " .. blob:getTileWidth() .. "x" .. blob:getTileHeight())
    local minimal = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")
    example_print_log("minimal16 tile count = " .. minimal:getTileCount())
end

--@api: LAutoTileSheet:applyToTileSet
do
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    local ts = lurek.tilemap.newTileSet(1, 64, 8, 16, 16)

    sheet:applyToTileSet(ts, "terrain")
    local id = ts:getAutoTileId("terrain", 5)
    example_print_log("after apply, bitmask 5 -> tile " .. tostring(id))

    sheet:applyToTileSet(ts, "water", 17)
    id = ts:getAutoTileId("water", 0)
    example_print_log("water bitmask 0 -> tile " .. tostring(id))
end

--@api: LAutoTileSheet:getBitmaskForTile
do
    ---@type LAutoTileSheet
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")
    local bitmask = sheet:getBitmaskForTile(3)
    local tile = sheet:getTileForBitmask(bitmask)
    example_print_log("tile 3 has bitmask = " .. bitmask)
    example_print_log("bitmask " .. bitmask .. " resolves to tile " .. tile)
end

--@api: LAutoTileSheet:getTileForBitmask
do
    ---@type LAutoTileSheet
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")
    local tile = sheet:getTileForBitmask(7)
    local bitmask = sheet:getBitmaskForTile(tile)
    example_print_log("bitmask 7 -> tile " .. tile)
    example_print_log("tile " .. tile .. " back to bitmask " .. bitmask)
end

--@api: LAutoTileSheet:getQuad
do
    ---@type LAutoTileSheet
    local sheet = lurek.tilemap.newAutoTileSheet(32, 32, "composite48")
    example_print_log("composite48 count = " .. sheet:getTileCount())
    example_print_log("composite48 layout = " .. sheet:getLayout())
    local x, y, w, h = sheet:getQuad(1)
    example_print_log("quad 1: x=" .. x .. " y=" .. y .. " w=" .. w .. " h=" .. h)
end

--@api: LTileMap:applyAutoTile
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")

    sheet:applyToTileSet(ts, "grass")
    map:addTileSet(ts)

    local layer = map:addLayer("terrain", 10, 10)
    map:fill(layer, 1)
    map:applyAutoTile(layer, "grass")

    local gid = map:getTile(layer, 5, 5)
    example_print_log("4-bit auto-tile applied")
    example_print_log("center tile after auto = " .. gid)
end

--@api: LTileMap:applyAutoTile8
do
    local map = lurek.tilemap.newTileMap(16, 16)
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

    example_print_log("8-bit auto-tile applied")
end

--@api: LTileMap:applyAutoTileAt
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")

    sheet:applyToTileSet(ts, "dirt")
    map:addTileSet(ts)

    local layer = map:addLayer("ground", 10, 10)
    map:fill(layer, 1)
    map:applyAutoTileAt(layer, 5, 5, "dirt")
    example_print_log("single cell auto-tiled at 5,5")
end

--@api: LTileMap:applyAutoTile8At
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")

    sheet:applyToTileSet(ts, "dirt")
    map:addTileSet(ts)

    local layer = map:addLayer("ground", 10, 10)
    map:fill(layer, 1)
    map:applyAutoTile8At(layer, 3, 3, "dirt")
    example_print_log("single cell 8-bit auto-tiled at 3,3")
end

--@api: LTileMap:sweepRect
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 32, 32)
    ts:setSolid(1, true)
    map:addTileSet(ts)

    local layer = map:addLayer("collision", 20, 20)
    map:setTile(layer, 5, 5, 1)
    map:setTile(layer, 6, 5, 1)

    local cx, cy, nx, ny, tx, ty = map:sweepRect(layer, 64, 64, 16, 16, 200, 0)
    example_print_log("contact pos = " .. cx .. ", " .. cy)
    example_print_log("normal = " .. nx .. ", " .. ny)
    example_print_log("tile hit = " .. tx .. ", " .. ty)
end

--@api: LTileMap:onTileEnter
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("triggers", 10, 10)
    map:setTile(layer, 3, 3, 5)
    map:onTileEnter(5, function(entity, tx, ty) example_print_log("entity entered trigger tile at " .. tx .. "," .. ty) end)
    example_print_log("enter callback registered for gid=5")
end

--@api: LTileMap:onTileExit
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("triggers", 10, 10)
    map:setTile(layer, 3, 3, 5)
    map:onTileExit(5, function(entity, tx, ty) example_print_log("entity left trigger tile at " .. tx .. "," .. ty) end)
    example_print_log("exit callback registered for gid=5")
end

--@api: LTileMap:onTileStep
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("triggers", 10, 10)
    map:setTile(layer, 3, 3, 5)
    map:onTileStep(5, function(entity, tx, ty) example_print_log("entity stepping on trigger at " .. tx .. "," .. ty) end)
    example_print_log("step callback registered for gid=5")
end

--@api: LTileMap:checkEntities
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("events", 10, 10)
    map:setTile(layer, 2, 2, 3)
    map:onTileEnter(3, function(entity, tx, ty) example_print_log("entered at " .. tx .. "," .. ty) end)
    local entities = {
        { x = 64, y = 64 },
        { x = 128, y = 128 },
    }

    map:checkEntities(layer, entities)
    example_print_log("entities checked against tile events")
end

--@api: LTileMap:fireTileExit
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("events", 10, 10)
    map:setTile(layer, 2, 2, 3)
    map:onTileEnter(3, function(entity, tx, ty) example_print_log("entered at " .. tx .. "," .. ty) end)
    local entities = {
        { x = 64, y = 64 },
        { x = 128, y = 128 },
    }

    map:fireTileExit(3, entities[1], 2, 2)
    example_print_log("tile exit fired")
end

--@api: LTileMap:fireTileStep
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("events", 10, 10)
    map:setTile(layer, 2, 2, 3)
    map:onTileEnter(3, function(entity, tx, ty) example_print_log("entered at " .. tx .. "," .. ty) end)
    local entities = {
        { x = 64, y = 64 },
        { x = 128, y = 128 },
    }

    map:fireTileStep(3, entities[1], 2, 2)
    example_print_log("tile step fired")
end

--@api: LTileMap:tileTypeIndex
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("terrain", 5, 5)

    map:setTile(layer, 1, 1, 1)
    map:setTile(layer, 2, 1, 1)
    map:setTile(layer, 3, 1, 2)
    map:setTile(layer, 4, 1, 3)

    local index = map:tileTypeIndex(layer)
    example_print_log("tile type index built")
    for gid, positions in pairs(index) do
        example_print_log("  gid " .. gid .. " has " .. #positions .. " tiles")
    end
end

--@api: LTileMap:toNavGrid
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local ts = lurek.tilemap.newTileSet(1, 8, 4, 32, 32)
    ts:setSolid(1, true)
    ts:setSolid(2, true)
    map:addTileSet(ts)

    local layer = map:addLayer("nav", 5, 5)
    map:setTile(layer, 2, 2, 1)
    map:setTile(layer, 3, 2, 2)

    local grid = map:toNavGrid(layer, { 1, 2 })
    example_print_log("nav grid rows = " .. #grid)
    example_print_log("cell 1,1 walkable = " .. tostring(grid[1] and grid[1][1]))
end

--@api: LTileMap:setTileTint
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("tinted", 10, 10)

    map:setTile(layer, 1, 1, 1)
    map:setTile(layer, 2, 1, 1)
    map:setTile(layer, 3, 1, 1)
    map:setTileTint(layer, 1, 1, 1.0, 0.0, 0.0, 1.0)
    map:setTileTint(layer, 2, 1, 0.0, 1.0, 0.0, 1.0)
    map:setTileTint(layer, 3, 1, 0.0, 0.0, 1.0, 1.0)
    example_print_log("RGB tints applied to 3 tiles")
end

--@api: LTileMap:setOrientation
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 10, 10)
    map:setOrientation("isometric")
    local wx, wy = map:tileToWorld(3, 2)
    example_print_log("set to " .. map:getOrientation())
    example_print_log("tile(3,2) projects near world(" .. wx .. "," .. wy .. ")")
end

--@api: LTileMap:getOrientation
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 10, 10)
    local before = map:getOrientation()
    map:setOrientation("hexagonal")
    example_print_log("default orientation = " .. map:getOrientation())
    example_print_log("initial orientation = " .. before)
    example_print_log("hex orientation = " .. map:getOrientation())
end

--@api: LTileMap:drawToImage
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local layer = map:addLayer("simple", 8, 8)
    map:fill(layer, 1)
    local img = map:drawToImage(16)
    example_print_log("image type = " .. img:type())
    example_print_log("drawn to image at tile size 16")
end

--@api: LTileMap:update
do
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("animated", 10, 10)

    local dt = 1 / 60
    map:update(dt)
    map:update(dt)
    map:update(dt)
    example_print_log("updated 3 frames at 60fps")
end

--- Tilemap Module Part 3: hex utilities, iso helpers, coordinate conversion, TMX/LDtk loading

--@api: lurek.tilemap.toScreenHex
do
    local sx, sy = lurek.tilemap.toScreenHex(2, 3, 32)
    local q, r = lurek.tilemap.fromScreenHex(sx, sy, 32)
    local distance = lurek.tilemap.hexDistance(2, 3, q, r)
    example_print_log("hex(2,3) -> screen(" .. sx .. ", " .. sy .. ")")
    example_print_log("round trip -> hex(" .. q .. "," .. r .. ")")
    example_print_log("round trip distance = " .. distance)
end

--@api: lurek.tilemap.hexDistance
do
    local d = lurek.tilemap.hexDistance(0, 0, 3, 2)
    example_print_log("hex distance (0,0) to (3,2) = " .. d)
    d = lurek.tilemap.hexDistance(1, 1, 1, 1)
    example_print_log("same cell distance = " .. d)
    d = lurek.tilemap.hexDistance(-2, 1, 2, -1)
    example_print_log("across-origin distance = " .. d)
end

--@api: lurek.tilemap.hexNeighbors
do
    local function hexCoords(cell)
        return cell.q or cell[1], cell.r or cell[2]
    end

    local neighbors = lurek.tilemap.hexNeighbors(3, 4)
    example_print_log("neighbors of (3,4): " .. #neighbors .. " cells")
    for i, n in ipairs(neighbors) do
        local q, r = hexCoords(n)
        example_print_log("  " .. i .. ": q=" .. q .. " r=" .. r)
    end
end

--@api: lurek.tilemap.hexRing
do
    local function hexCoords(cell)
        return cell.q or cell[1], cell.r or cell[2]
    end

    local ring = lurek.tilemap.hexRing(0, 0, 2)
    example_print_log("ring at radius 2: " .. #ring .. " cells")
    for _, cell in ipairs(ring) do
        local q, r = hexCoords(cell)
        example_print_log("  q=" .. q .. " r=" .. r)
    end
end

--@api: lurek.tilemap.hexArea
do
    local area = lurek.tilemap.hexArea(0, 0, 1)
    example_print_log("area radius 1: " .. #area .. " cells")
    local bigArea = lurek.tilemap.hexArea(5, 5, 3)
    local ring = lurek.tilemap.hexRing(5, 5, 3)
    example_print_log("area radius 3 around (5,5): " .. #bigArea .. " cells")
    example_print_log("matching outer ring cells = " .. #ring)
end

--@api: lurek.tilemap.hexSpiral
do
    local function hexCoords(cell)
        return cell.q or cell[1], cell.r or cell[2]
    end

    local spiral = lurek.tilemap.hexSpiral(0, 0, 2)
    example_print_log("spiral radius 2: " .. #spiral .. " cells")
    local q, r = hexCoords(spiral[1])
    example_print_log("center = q=" .. q .. " r=" .. r)
end

--@api: lurek.tilemap.hexLine
do
    local function hexCoords(cell)
        return cell.q or cell[1], cell.r or cell[2]
    end

    local line = lurek.tilemap.hexLine(0, 0, 4, 2)
    example_print_log("line (0,0) to (4,2): " .. #line .. " cells")
    for i, cell in ipairs(line) do
        local q, r = hexCoords(cell)
        example_print_log("  step " .. i .. ": q=" .. q .. " r=" .. r)
    end
end

--@api: lurek.tilemap.hexRound
do
    local q, r = lurek.tilemap.hexRound(2.3, 1.7)
    example_print_log("round(2.3, 1.7) = " .. q .. ", " .. r)
    q, r = lurek.tilemap.hexRound(-0.4, 0.6)
    local dist = lurek.tilemap.hexDistance(0, 0, q, r)
    example_print_log("round(-0.4, 0.6) = " .. q .. ", " .. r)
    example_print_log("rounded cell distance from origin = " .. dist)
end

--@api: lurek.tilemap.hexRotate
do
    local q, r = lurek.tilemap.hexRotate(2, 0, 0, 0, 1)
    example_print_log("(2,0) rotated 60deg CW around origin = " .. q .. ", " .. r)
    q, r = lurek.tilemap.hexRotate(2, 0, 0, 0, 3)
    local dist = lurek.tilemap.hexDistance(0, 0, q, r)
    example_print_log("(2,0) rotated 180deg = " .. q .. ", " .. r)
    example_print_log("rotated point distance from origin = " .. dist)
end

--@api: lurek.tilemap.hexReflect
do
    local q, r = lurek.tilemap.hexReflect(3, 1, 0, 0, "q")
    example_print_log("reflect (3,1) across q axis = " .. q .. ", " .. r)
    q, r = lurek.tilemap.hexReflect(2, -1, 0, 0, "r")
    local dist = lurek.tilemap.hexDistance(0, 0, q, r)
    example_print_log("reflect (2,-1) across r axis = " .. q .. ", " .. r)
    example_print_log("reflected point distance from origin = " .. dist)
end

--@api: lurek.tilemap.toScreenIso
do
    local sx, sy = lurek.tilemap.toScreenIso(3, 5, 64, 32)
    local tx, ty = lurek.tilemap.fromScreenIso(sx, sy, 64, 32)
    local direction = lurek.tilemap.isoDirectionName(lurek.tilemap.isoDirectionFromAngle(45))
    example_print_log("tile(3,5) -> screen(" .. sx .. ", " .. sy .. ")")
    example_print_log("round trip -> tile(" .. tx .. "," .. ty .. ")")
    example_print_log("camera heading label = " .. direction)
end

--@api: lurek.tilemap.isoDirectionFromAngle
do
    local dir = lurek.tilemap.isoDirectionFromAngle(45)
    local name = lurek.tilemap.isoDirectionName(dir)
    local rotated = lurek.tilemap.isoRotate(dir, 1)
    example_print_log("45 degrees -> direction " .. dir)
    example_print_log("direction name = " .. name)
    example_print_log("one step clockwise = " .. rotated)
end

--@api: lurek.tilemap.loadTMX
do
    local tmxData = [[<?xml version="1.0" encoding="UTF-8"?> <map version="1.10" orientation="orthogonal" width="4" height="4" tilewidth="32" tileheight="32"> <layer name="ground" width="4" height="4"> <data encoding="csv">1,1,1,1,1,2,2,1,1,2,2,1,1,1,1,1</data> </layer> </map>]]
    local result, err = lurek.tilemap.loadTMX(tmxData)
    if result then
        example_print_log("TMX width = " .. result.width)
        example_print_log("TMX height = " .. result.height)
        example_print_log("TMX tile size = " .. result.tileWidth .. "x" .. result.tileHeight)
        example_print_log("TMX orientation = " .. result.orientation)
        example_print_log("TMX layers = " .. #result.layers)
    else
        local err_tbl = err or {}
        local code = err_tbl["code"] or "unknown"
        local message = err_tbl["message"] or "unknown"
        example_print_log("TMX import error: " .. code .. " - " .. message)
    end
end

--@api: lurek.tilemap.fromLDtk
do
    local ldtkJson = '{"levels":[{"identifier":"Level_0","layerInstances":[]}]}'
    local map, err = lurek.tilemap.fromLDtk(ldtkJson)
    if map then
        example_print_log("LDtk map type = " .. map:type())
    else
        local err_tbl = err or {}
        local code = err_tbl["code"] or "unknown"
        local message = err_tbl["message"] or "unknown"
        example_print_log("LDtk import error: " .. code .. " - " .. message)
    end
    local named, named_err = lurek.tilemap.fromLDtk(ldtkJson, "Level_0")
    if named then
        example_print_log("named level loaded")
    else
        local err_tbl = named_err or {}
        local code = err_tbl["code"] or "unknown"
        example_print_log("named level import error: " .. code)
    end
end

--@api: lurek.tilemap.FLOOR
do
    local part_count = lurek.tilemap.OBJECT - lurek.tilemap.FLOOR + 1
    local object_offset = lurek.tilemap.OBJECT - lurek.tilemap.FLOOR
    example_print_log("FLOOR = " .. lurek.tilemap.FLOOR)
    example_print_log("FLOOR type = " .. type(lurek.tilemap.FLOOR))
    example_print_log("iso part enum span = " .. part_count)
    example_print_log("object offset = " .. object_offset)
end

--@api: lurek.tilemap.NORTH_WALL
do
    local wall_dir = lurek.tilemap.isoDirectionName(lurek.tilemap.isoRotate(1, 0))
    local north_part = lurek.tilemap.NORTH_WALL
    example_print_log("NORTH_WALL = " .. lurek.tilemap.NORTH_WALL)
    example_print_log("NORTH_WALL ~= FLOOR: " .. tostring(lurek.tilemap.NORTH_WALL ~= lurek.tilemap.FLOOR))
    example_print_log("north-facing label = " .. wall_dir)
    example_print_log("north part id = " .. north_part)
end

--@api: lurek.tilemap.WEST_WALL
do
    local west_dir = lurek.tilemap.isoDirectionName(lurek.tilemap.isoRotate(1, 3))
    local west_part = lurek.tilemap.WEST_WALL
    example_print_log("WEST_WALL = " .. lurek.tilemap.WEST_WALL)
    example_print_log("WEST_WALL ~= NORTH_WALL: " .. tostring(lurek.tilemap.WEST_WALL ~= lurek.tilemap.NORTH_WALL))
    example_print_log("west-facing label = " .. west_dir)
    example_print_log("west part id = " .. west_part)
end

--@api: lurek.tilemap.OBJECT
do
    local object_part = lurek.tilemap.OBJECT
    local floor_part = lurek.tilemap.FLOOR
    example_print_log("OBJECT = " .. lurek.tilemap.OBJECT)
    example_print_log("OBJECT ~= FLOOR: " .. tostring(lurek.tilemap.OBJECT ~= lurek.tilemap.FLOOR))
    example_print_log("object part offset from floor = " .. (object_part - floor_part))
end

--- Tilemap Module Part 4: ChunkMap, IsoMap, LargeMapRenderer, MapBlock, MapGroup, MapScript, MapGen

--@api: lurek.tilemap.newChunkMap
do
    ---@type LChunkMap
    local cm = lurek.tilemap.newChunkMap(16)
    example_print_log("type = " .. cm:type())
    example_print_log("chunk size = " .. cm:getChunkSize())
    example_print_log("loaded chunks = " .. #cm:getLoadedChunks())
    example_print_log("typeOf chunk map = " .. tostring(cm:typeOf("LChunkMap")))
end

--@api: LChunkMap:setTile
do
    ---@type LChunkMap
    local cm = lurek.tilemap.newChunkMap(16)
    cm:setTile(10, 20, 5)
    local gid = cm:getTile(10, 20)
    local loaded = cm:getLoadedChunks()
    example_print_log("tile at 10,20 = " .. gid)
    example_print_log("loaded chunks after write = " .. #loaded)
end

--@api: LChunkMap:getTile
do
    ---@type LChunkMap
    local cm = lurek.tilemap.newChunkMap(16)
    cm:setTile(10, 20, 5)
    local gid = cm:getTile(10, 20)
    local x0, y0, x1, y1 = cm:chunkTileRange(0, 1)
    example_print_log("tile at 10,20 = " .. gid)
    example_print_log("chunk range = (" .. x0 .. "," .. y0 .. ")-(" .. x1 .. "," .. y1 .. ")")
end

--@api: LChunkMap:clearTile
do
    local cm = lurek.tilemap.newChunkMap(16)
    cm:setTile(10, 20, 5)
    cm:clearTile(10, 20)
    local gid = cm:getTile(10, 20)
    example_print_log("after clear = " .. gid)
end

--@api: LChunkMap:fillRect
do
    local cm = lurek.tilemap.newChunkMap(16)
    cm:fillRect(0, 0, 10, 10, 3)
    example_print_log("filled 11x11 area with gid=3")
    example_print_log("sample (5,5) = " .. cm:getTile(5, 5))
    example_print_log("sample (11,11) = " .. cm:getTile(11, 11))
end

--@api: LChunkMap:loadChunk
do
    local function chunkCoords(cell)
        return cell.cx or cell[1], cell.cy or cell[2]
    end

    local cm = lurek.tilemap.newChunkMap(16)
    cm:loadChunk(0, 0)
    local loaded = cm:getLoadedChunks()
    example_print_log("loaded chunks = " .. #loaded)
    for _, c in ipairs(loaded) do
        local cx, cy = chunkCoords(c)
        example_print_log("  chunk (" .. cx .. ", " .. cy .. ")")
    end
end

--@api: LChunkMap:unloadChunk
do
    local cm = lurek.tilemap.newChunkMap(16) ; cm:loadChunk(0, 0)
    cm:loadChunk(1, 0)
    cm:unloadChunk(1, 0)
    local loaded = cm:getLoadedChunks()
    example_print_log("after unload = " .. #loaded .. " chunks")
end

--@api: LChunkMap:getLoadedChunks
do
    local function chunkCoords(cell)
        return cell.cx or cell[1], cell.cy or cell[2]
    end

    local cm = lurek.tilemap.newChunkMap(16) ; cm:loadChunk(0, 0)
    cm:loadChunk(1, 0) ; cm:loadChunk(0, 1)
    local loaded = cm:getLoadedChunks()
    example_print_log("loaded chunks = " .. #loaded)
    for _, c in ipairs(loaded) do
        local cx, cy = chunkCoords(c)
        example_print_log("  chunk (" .. cx .. ", " .. cy .. ")")
    end
end

--@api: LChunkMap:chunkTileRange
do
    local cm = lurek.tilemap.newChunkMap(16)
    local minX, minY, maxX, maxY = cm:chunkTileRange(2, 3)
    example_print_log("chunk (2,3) covers tiles:")
    example_print_log("  min = " .. minX .. ", " .. minY)
    example_print_log("  max = " .. maxX .. ", " .. maxY)
end

--@api: LChunkMap:getChunksInView
do
    local function chunkCoords(cell)
        return cell.cx or cell[1], cell.cy or cell[2]
    end

    local cm = lurek.tilemap.newChunkMap(16)
    local visible = cm:getChunksInView(0, 0, 800, 600, 32, 32)
    example_print_log("visible chunks in 800x600 viewport: " .. #visible)
    for i = 1, math.min(3, #visible) do
        local cx, cy = chunkCoords(visible[i])
        example_print_log("  chunk (" .. cx .. ", " .. cy .. ")")
    end
end

--@api: lurek.tilemap.newIsoMap
do
    local iso = lurek.tilemap.newIsoMap(20, 20, 64, 32, 16)
    example_print_log("type = " .. iso:type())
    example_print_log("size = " .. iso:getWidth() .. "x" .. iso:getHeight())
    example_print_log("tile size = " .. iso:getTileWidth() .. "x" .. iso:getTileHeight())
    example_print_log("level height = " .. iso:getLevelHeight())
end

--@api: LIsoMap:addLevel
do
    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local lvl = iso:addLevel()
    local second = iso:addLevel()
    example_print_log("added level, count = " .. iso:getLevelCount())
    example_print_log("first level index = " .. lvl)
    example_print_log("second level index = " .. second)
end

--@api: LIsoMap:getLevelCount
do
    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local lvl = iso:addLevel()
    iso:addLevel()
    example_print_log("added level, count = " .. iso:getLevelCount())
    example_print_log("first level index = " .. lvl)
end

--@api: LIsoMap:setTilePart
do
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    iso:addLevel()
    iso:setTilePart(1, 3, 4, 1, 5)
    local gid = iso:getTilePart(1, 3, 4, 1)
    example_print_log("tile part at (1,3,4,part=1) = " .. gid)
end

--@api: LIsoMap:getTilePart
do
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    iso:addLevel()
    iso:setTilePart(1, 3, 4, 1, 5)
    local gid = iso:getTilePart(1, 3, 4, 1)
    example_print_log("tile part at (1,3,4,part=1) = " .. gid)
end

--@api: LIsoMap:fillLevel
do
    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(8, 8, 64, 32, 16)
    iso:addLevel()
    iso:fillLevel(1, 1, 3)
    local gid = iso:getTilePart(1, 2, 2, 1)
    example_print_log("filled level 1, part 1 with gid=3")
    example_print_log("sample tile part = " .. gid)
end

--@api: LIsoMap:isLevelVisible
do
    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(8, 8, 64, 32, 16)
    iso:addLevel()
    local before = iso:isLevelVisible(1)
    iso:setLevelVisible(1, false)
    example_print_log("level 1 visible = " .. tostring(iso:isLevelVisible(1)))
    example_print_log("default visible = " .. tostring(before))
    example_print_log("after hide = " .. tostring(iso:isLevelVisible(1)))
end

--@api: LIsoMap:setLevelVisible
do
    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(8, 8, 64, 32, 16)
    iso:addLevel()
    iso:setLevelVisible(1, false)
    local hidden = iso:isLevelVisible(1)
    example_print_log("after hide = " .. tostring(iso:isLevelVisible(1)))
    iso:setLevelVisible(1, true)
    example_print_log("hidden flag = " .. tostring(hidden))
    example_print_log("after show = " .. tostring(iso:isLevelVisible(1)))
end

--@api: LIsoMap:screenToTile
do
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16)
    iso:setOrigin(400, 100)
    local sx, sy = iso:tileToScreen(3, 2, 1)
    local tx, ty = iso:screenToTile(sx, sy)
    example_print_log("screen -> tile(" .. tx .. ", " .. ty .. ")")
end

--@api: LIsoMap:tileToScreen
do
    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16)
    iso:setOrigin(400, 100)
    local sx, sy = iso:tileToScreen(3, 2, 1)
    local tx, ty = iso:screenToTile(sx, sy)
    example_print_log("tile(3,2,z=1) -> screen(" .. sx .. ", " .. sy .. ")")
    example_print_log("round trip -> tile(" .. tx .. "," .. ty .. ")")
end

--@api: LIsoMap:setOrigin
do
    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16)
    iso:setOrigin(400, 100)
    local sx, sy = iso:tileToScreen(1, 1, 1)
    example_print_log("origin set")
    example_print_log("tile(1,1,1) screen anchor = " .. sx .. "," .. sy)
end

--@api: LIsoMap:setPartOrder
do
    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(5, 5, 64, 32, 16, 4)
    iso:setPartOrder({ 3, 2, 1, 0 })
    local order = iso:getPartOrder()
    local parts = iso:getPartCount()
    example_print_log("reversed order[1] = " .. order[1])
    example_print_log("part count = " .. parts)
end

--@api: LIsoMap:getPartOrder
do
    local iso = lurek.tilemap.newIsoMap(5, 5, 64, 32, 16, 4) ; local order = iso:getPartOrder()
    example_print_log("default part order: " .. #order .. " entries")
    iso:setPartOrder({ 3, 2, 1, 0 })
    order = iso:getPartOrder()
    example_print_log("reversed order[1] = " .. order[1])
end

--@api: lurek.tilemap.newLargeMapRenderer
do
    ---@type LLargeMapRenderer
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    example_print_log("type = " .. lmr:type())
    example_print_log("chunk size = " .. lmr:getChunkSize())
    example_print_log("tileset columns = " .. lmr:getTilesetColumns())
    example_print_log("typeOf renderer = " .. tostring(lmr:typeOf("LLargeMapRenderer")))
end

--@api: LLargeMapRenderer:setMapData
do
    local function buildLargeMapData(width, height, value_mod)
        local data = {}
        for y = 1, height do
            for x = 1, width do
                data[#data + 1] = ((x + y) % value_mod) + 1
            end
        end
        return data
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local width, height = 24, 24
    lmr:setMapData(buildLargeMapData(width, height, 4), width, height)
    local w, h = lmr:getMapSize() ; example_print_log("map size = " .. w .. "x" .. h)
    example_print_log("tile at (12,12) = " .. lmr:getTile(12, 12)) ; lmr:setTile(12, 12, 99)
    example_print_log("after set = " .. lmr:getTile(12, 12))
end

--@api: LLargeMapRenderer:getMapSize
do
    local function buildLargeMapData(width, height, value_mod)
        local data = {}
        for y = 1, height do
            for x = 1, width do
                data[#data + 1] = ((x + y) % value_mod) + 1
            end
        end
        return data
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local width, height = 24, 24
    lmr:setMapData(buildLargeMapData(width, height, 4), width, height)
    local w, h = lmr:getMapSize() ; example_print_log("map size = " .. w .. "x" .. h)
    example_print_log("tile at (12,12) = " .. lmr:getTile(12, 12)) ; lmr:setTile(12, 12, 99)
    example_print_log("after set = " .. lmr:getTile(12, 12))
end

--@api: LLargeMapRenderer:getTile
do
    local function buildLargeMapData(width, height, value_mod)
        local data = {}
        for y = 1, height do
            for x = 1, width do
                data[#data + 1] = ((x + y) % value_mod) + 1
            end
        end
        return data
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local width, height = 24, 24
    lmr:setMapData(buildLargeMapData(width, height, 4), width, height)
    local w, h = lmr:getMapSize() ; example_print_log("map size = " .. w .. "x" .. h)
    example_print_log("tile at (12,12) = " .. lmr:getTile(12, 12)) ; lmr:setTile(12, 12, 99)
    example_print_log("after set = " .. lmr:getTile(12, 12))
end

--@api: LLargeMapRenderer:setTile
do
    local function buildLargeMapData(width, height, value_mod)
        local data = {}
        for y = 1, height do
            for x = 1, width do
                data[#data + 1] = ((x + y) % value_mod) + 1
            end
        end
        return data
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local width, height = 24, 24
    lmr:setMapData(buildLargeMapData(width, height, 4), width, height)
    local w, h = lmr:getMapSize() ; example_print_log("map size = " .. w .. "x" .. h)
    example_print_log("tile at (12,12) = " .. lmr:getTile(12, 12)) ; lmr:setTile(12, 12, 99)
    example_print_log("after set = " .. lmr:getTile(12, 12))
end

--@api: LLargeMapRenderer:setCamera
do
    local function buildLargeMapData(width, height, value_mod)
        local data = {}
        for y = 1, height do
            for x = 1, width do
                data[#data + 1] = ((x + y) % value_mod) + 1
            end
        end
        return data
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local width, height = 40, 40
    lmr:setMapData(buildLargeMapData(width, height, 1), width, height)
    lmr:setViewport(800, 600) ; lmr:setCamera(640, 640, 1.0)
    example_print_log("total chunks = " .. lmr:getTotalChunks())
    example_print_log("visible chunks = " .. lmr:getVisibleChunks())
end

--@api: LLargeMapRenderer:setViewport
do
    local function buildLargeMapData(width, height, value_mod)
        local data = {}
        for y = 1, height do
            for x = 1, width do
                data[#data + 1] = ((x + y) % value_mod) + 1
            end
        end
        return data
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local width, height = 40, 40
    lmr:setMapData(buildLargeMapData(width, height, 1), width, height)
    lmr:setViewport(800, 600) ; lmr:setCamera(640, 640, 1.0)
    example_print_log("total chunks = " .. lmr:getTotalChunks())
    example_print_log("visible chunks = " .. lmr:getVisibleChunks())
end

--@api: LLargeMapRenderer:getVisibleChunks
do
    local function buildLargeMapData(width, height, value_mod)
        local data = {}
        for y = 1, height do
            for x = 1, width do
                data[#data + 1] = ((x + y) % value_mod) + 1
            end
        end
        return data
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local width, height = 40, 40
    lmr:setMapData(buildLargeMapData(width, height, 1), width, height)
    lmr:setViewport(800, 600) ; lmr:setCamera(640, 640, 1.0)
    example_print_log("total chunks = " .. lmr:getTotalChunks())
    example_print_log("visible chunks = " .. lmr:getVisibleChunks())
end

--@api: LLargeMapRenderer:getTotalChunks
do
    local function buildLargeMapData(width, height, value_mod)
        local data = {}
        for y = 1, height do
            for x = 1, width do
                data[#data + 1] = ((x + y) % value_mod) + 1
            end
        end
        return data
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local width, height = 40, 40
    lmr:setMapData(buildLargeMapData(width, height, 1), width, height)
    lmr:setViewport(800, 600) ; lmr:setCamera(640, 640, 1.0)
    example_print_log("total chunks = " .. lmr:getTotalChunks())
    example_print_log("visible chunks = " .. lmr:getVisibleChunks())
end

--@api: LLargeMapRenderer:setLodEnabled
do
    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16) ; example_print_log("LOD enabled = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodEnabled(true)
    example_print_log("after enable = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodThresholds({ 0.5, 0.25, 0.1 })
    example_print_log("LOD thresholds set")
end

--@api: LLargeMapRenderer:isLodEnabled
do
    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16) ; example_print_log("LOD enabled = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodEnabled(true)
    example_print_log("after enable = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodThresholds({ 0.5, 0.25, 0.1 })
    example_print_log("LOD thresholds set")
end

--@api: LLargeMapRenderer:setLodThresholds
do
    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16) ; example_print_log("LOD enabled = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodEnabled(true)
    example_print_log("after enable = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodThresholds({ 0.5, 0.25, 0.1 })
    example_print_log("LOD thresholds set")
end

--@api: LLargeMapRenderer:invalidateAll
do
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; lmr:setChunkSize(32)
    example_print_log("chunk size = " .. lmr:getChunkSize()) ; lmr:setTilesetColumns(16)
    example_print_log("tileset columns = " .. lmr:getTilesetColumns()) ; lmr:invalidateChunk(0, 0)
    lmr:invalidateAll()
    example_print_log("all chunks invalidated")
end

--@api: LLargeMapRenderer:invalidateChunk
do
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; lmr:setChunkSize(32)
    example_print_log("chunk size = " .. lmr:getChunkSize()) ; lmr:setTilesetColumns(16)
    example_print_log("tileset columns = " .. lmr:getTilesetColumns()) ; lmr:invalidateChunk(0, 0)
    lmr:invalidateAll()
    example_print_log("all chunks invalidated")
end

--@api: LLargeMapRenderer:setChunkSize
do
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; lmr:setChunkSize(32)
    example_print_log("chunk size = " .. lmr:getChunkSize()) ; lmr:setTilesetColumns(16)
    example_print_log("tileset columns = " .. lmr:getTilesetColumns()) ; lmr:invalidateChunk(0, 0)
    lmr:invalidateAll()
    example_print_log("all chunks invalidated")
end

--@api: LLargeMapRenderer:setTilesetColumns
do
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; lmr:setChunkSize(32)
    example_print_log("chunk size = " .. lmr:getChunkSize()) ; lmr:setTilesetColumns(16)
    example_print_log("tileset columns = " .. lmr:getTilesetColumns()) ; lmr:invalidateChunk(0, 0)
    lmr:invalidateAll()
    example_print_log("all chunks invalidated")
end

--@api: lurek.tilemap.newMapBlock
do
    local block = lurek.tilemap.newMapBlock(8, 8, 2, 2) ; example_print_log("type = " .. block:type())
    local w, h = block:getDimensions() ; example_print_log("dimensions = " .. w .. "x" .. h)
    example_print_log("layers = " .. block:getLayerCount()) ; example_print_log("segment size = " .. block:getSegmentSize())
    example_print_log("width in segments = " .. block:getWidthInSegments())
    example_print_log("height in segments = " .. block:getHeightInSegments())
end

--@api: lurek.tilemap.newMapGroup
do
    local group = lurek.tilemap.newMapGroup("dungeon") ; example_print_log("type = " .. group:type()) ; example_print_log("name = " .. group:getName())
    local b1 = lurek.tilemap.newMapBlock(4, 4) ; b1:setName("corridor") ; local b2 = lurek.tilemap.newMapBlock(4, 4)
    b2:setName("room") ; group:addBlock(b1)
    group:addBlock(b2) ; example_print_log("block count = " .. group:getBlockCount())
    group:removeBlock(1) ; example_print_log("after remove = " .. group:getBlockCount())
end

--@api: lurek.tilemap.newMapScript
do
    local script = lurek.tilemap.newMapScript() ; example_print_log("type = " .. script:type())
    script:addStep({ type = "fillArea", gid = 1, x = 0, y = 0, w = 4, h = 4 })
    script:addStep({ type = "placeRandom", gid = 5, count = 2 })
    script:addStep({ type = "fillRect", gid = 2, x = 0, y = 0, w = 5, h = 1 })
    example_print_log("step count = " .. script:getStepCount())
end

--@api: lurek.tilemap.newMapGen
do
    local group = lurek.tilemap.newMapGroup("caves") ; local block = lurek.tilemap.newMapBlock(4, 4) ; block:setName("open")
    block:setTile(1, 1, 1, 1) ; block:setTile(1, 2, 2, 1) ; group:addBlock(block)
    local script = lurek.tilemap.newMapScript() ; script:addStep({ type = "fillArea", gid = 1, x = 0, y = 0, w = 4, h = 4 }) ; group:addScript(script)
    local gen = lurek.tilemap.newMapGen(group, "small", 1) ; example_print_log("type = " .. gen:type())
    local result = gen:generate(1, 42, "terrain") ; example_print_log("generated map type = " .. result:type())
end

--@api: LMapGen:generate
do
    local group = lurek.tilemap.newMapGroup("caves") ; local block = lurek.tilemap.newMapBlock(4, 4) ; block:setName("open")
    block:setTile(1, 1, 1, 1) ; block:setTile(1, 2, 2, 1) ; group:addBlock(block)
    local script = lurek.tilemap.newMapScript() ; script:addStep({ type = "fillArea", gid = 1, x = 0, y = 0, w = 4, h = 4 })
    group:addScript(script) ; local gen = lurek.tilemap.newMapGen(group, "small", 1)
    local result = gen:generate(1, 42, "terrain") ; example_print_log("generated map type = " .. result:type())
end

--- TileMap Part 4: getChunkSize, getTileDimensions, getTileHeight, getTileWidth, type, typeOf, iso/hex helpers

--@api: LTileMap:getChunkSize
do
    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local cs = tm:getChunkSize()
    local tw, th = tm:getTileDimensions()
    example_print_log("chunk_size=" .. cs)
    example_print_log("tile_dims=" .. tw .. "x" .. th)
end

--@api: LTileMap:getTileDimensions
do
    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local tw, th = tm:getTileDimensions()
    local chunk = tm:getChunkSize()
    example_print_log("tile_w=" .. tw .. " tile_h=" .. th)
    example_print_log("chunk_size=" .. chunk)
end

--@api: LTileMap:getTileHeight
do
    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local th2 = tm:getTileHeight()
    local tw2 = tm:getTileWidth()
    example_print_log("tile_height=" .. th2)
    example_print_log("tile_width=" .. tw2)
end

--@api: LTileMap:getTileWidth
do
    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local tw2 = tm:getTileWidth()
    local th2 = tm:getTileHeight()
    example_print_log("tile_width=" .. tw2)
    example_print_log("tile_height=" .. th2)
end

--@api: LTileMap:type
do
    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local tw, th = tm:getTileDimensions()
    example_print_log("type=" .. tm:type())
    example_print_log("tile_dims=" .. tw .. "x" .. th)
    example_print_log("chunk_size=" .. tm:getChunkSize())
end

--@api: LTileMap:typeOf
do
    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local is_map = tm:typeOf("LTileMap")
    local is_object = tm:typeOf("LObject")
    example_print_log("typeOf=" .. tostring(tm:typeOf("LTileMap")))
    example_print_log("as_map=" .. tostring(is_map))
    example_print_log("as_object=" .. tostring(is_object))
end

--@api: lurek.tilemap.fromScreenHex
do
    local hx, hy = lurek.tilemap.fromScreenHex(80, 40, 32)
    local sx, sy = lurek.tilemap.toScreenHex(hx, hy, 32)
    local dist = lurek.tilemap.hexDistance(hx, hy, hx, hy)
    example_print_log("hex_x=" .. hx .. " hex_y=" .. hy)
    example_print_log("back_to_screen=" .. sx .. "," .. sy)
    example_print_log("self_distance=" .. dist)
end

--@api: lurek.tilemap.fromScreenIso
do
    local ix, iy = lurek.tilemap.fromScreenIso(128, 64, 32, 16)
    local sx, sy = lurek.tilemap.toScreenIso(ix, iy, 32, 16)
    local dir = lurek.tilemap.isoDirectionFromAngle(0)
    example_print_log("iso_x=" .. ix .. " iso_y=" .. iy)
    example_print_log("back_to_screen=" .. sx .. "," .. sy)
    example_print_log("default_dir=" .. dir)
end

--@api: lurek.tilemap.isoDirectionName
do
    local name = lurek.tilemap.isoDirectionName(1)
    local rotated = lurek.tilemap.isoRotate(1, 1)
    local rotated_name = lurek.tilemap.isoDirectionName(rotated)
    example_print_log("iso_dir=" .. name)
    example_print_log("rotated_dir=" .. rotated)
    example_print_log("rotated_name=" .. rotated_name)
end

--@api: lurek.tilemap.isoRotate
do
    local rotated = lurek.tilemap.isoRotate(1, 2)
    local label = lurek.tilemap.isoDirectionName(rotated)
    local reset = lurek.tilemap.isoRotate(rotated, 2)
    example_print_log("iso_rotated=" .. rotated)
    example_print_log("iso_rotated_name=" .. label)
    example_print_log("iso_reset=" .. reset)
end

--- TileMap Part 5: LTileSet full coverage

--@api: LTileSet:getColumns
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local count = ts:getTileCount()
    example_print_log("columns=" .. ts:getColumns())
    example_print_log("tileCount=" .. count)
    example_print_log("tileWidth=" .. ts:getTileWidth())
end

--@api: LTileSet:getFirstGid
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local columns = ts:getColumns()
    example_print_log("firstGid=" .. ts:getFirstGid())
    example_print_log("columns=" .. columns)
    example_print_log("tileHeight=" .. ts:getTileHeight())
end

--@api: LTileSet:getMargin
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local spacing = ts:getSpacing()
    local width = ts:getTileWidth()
    example_print_log("margin=" .. ts:getMargin())
    example_print_log("spacing=" .. spacing)
    example_print_log("tileWidth=" .. width)
end

--@api: LTileSet:getSpacing
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local margin = ts:getMargin()
    local height = ts:getTileHeight()
    example_print_log("spacing=" .. ts:getSpacing())
    example_print_log("margin=" .. margin)
    example_print_log("tileHeight=" .. height)
end

--@api: LTileSet:getTileCount
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local columns = ts:getColumns()
    local first_gid = ts:getFirstGid()
    example_print_log("tileCount=" .. ts:getTileCount())
    example_print_log("columns=" .. columns)
    example_print_log("firstGid=" .. first_gid)
end

--@api: LTileSet:getTileDimensions
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local tw, th = ts:getTileDimensions()
    local quad = ts:getQuad(1)
    example_print_log("tile_w=" .. tw .. " tile_h=" .. th)
    example_print_log("quad_w=" .. quad.width .. " quad_h=" .. quad.height)
end

--@api: LTileSet:getTileHeight
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local tw = ts:getTileWidth()
    local count = ts:getTileCount()
    example_print_log("tileHeight=" .. ts:getTileHeight())
    example_print_log("tileWidth=" .. tw)
    example_print_log("tileCount=" .. count)
end

--@api: LTileSet:getTileWidth
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local th = ts:getTileHeight()
    local count = ts:getTileCount()
    example_print_log("tileWidth=" .. ts:getTileWidth())
    example_print_log("tileHeight=" .. th)
    example_print_log("tileCount=" .. count)
end

--@api: LTileSet:type
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local count = ts:getTileCount()
    local columns = ts:getColumns()
    example_print_log("type=" .. ts:type())
    example_print_log("tileCount=" .. count)
    example_print_log("columns=" .. columns)
end

--@api: LTileSet:typeOf
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local is_tileset = ts:typeOf("LTileSet")
    local is_object = ts:typeOf("LObject")
    example_print_log("typeOf=" .. tostring(ts:typeOf("LTileSet")))
    example_print_log("as_tileset=" .. tostring(is_tileset))
    example_print_log("as_object=" .. tostring(is_object))
end

--@api: LAutoTileSheet:getLayout
do
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    local layout = sheet:getLayout()
    local count = sheet:getTileCount()
    example_print_log("layout:", layout)
    example_print_log("tileCount:", count)
    example_print_log("tileWidth:", sheet:getTileWidth())
end

--@api: LAutoTileSheet:getTileCount
do
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    local count = sheet:getTileCount()
    local layout = sheet:getLayout()
    example_print_log("tileCount:", count)
    example_print_log("layout:", layout)
    example_print_log("tileHeight:", sheet:getTileHeight())
end

--@api: LAutoTileSheet:getTileHeight
do
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    local h = sheet:getTileHeight()
    local w = sheet:getTileWidth()
    example_print_log("tileHeight:", h)
    example_print_log("tileWidth:", w)
    example_print_log("layout:", sheet:getLayout())
end

--@api: LAutoTileSheet:getTileWidth
do
    local sheet = lurek.tilemap.newAutoTileSheet(32, 32, "minimal16")
    local w = sheet:getTileWidth()
    local h = sheet:getTileHeight()
    example_print_log("tileWidth:", w)
    example_print_log("tileHeight:", h)
    example_print_log("tileCount:", sheet:getTileCount())
end

--@api: LAutoTileSheet:type
do
    local sheet = lurek.tilemap.newAutoTileSheet(32, 32, "minimal16")
    local t = sheet:type()
    local layout = sheet:getLayout()
    example_print_log("type:", t)
    example_print_log("layout:", layout)
    example_print_log("tileCount:", sheet:getTileCount())
end

--@api: LAutoTileSheet:typeOf
do
    local sheet = lurek.tilemap.newAutoTileSheet(32, 32, "minimal16")
    local ok = sheet:typeOf("LAutoTileSheet")
    local as_object = sheet:typeOf("LObject")
    example_print_log("typeOf:", ok)
    example_print_log("typeOfObject:", as_object)
    example_print_log("layout:", sheet:getLayout())
end

--@api: LChunkMap:getChunkSize
do
    local cm = lurek.tilemap.newChunkMap(32)
    local sz = cm:getChunkSize()
    local loaded = cm:getLoadedChunks()
    example_print_log("chunkSize:", sz)
    example_print_log("loadedChunks:", #loaded)
end

--@api: LChunkMap:type
do
    local cm = lurek.tilemap.newChunkMap(32)
    local t = cm:type()
    local sz = cm:getChunkSize()
    example_print_log("type:", t)
    example_print_log("chunkSize:", sz)
    example_print_log("loadedChunks:", #cm:getLoadedChunks())
end

--@api: LChunkMap:typeOf
do
    local cm = lurek.tilemap.newChunkMap(32)
    local ok = cm:typeOf("LChunkMap")
    local as_object = cm:typeOf("LObject")
    example_print_log("typeOf:", ok)
    example_print_log("typeOfObject:", as_object)
    example_print_log("chunkSize:", cm:getChunkSize())
end

--@api: LIsoMap:getHeight
do
    local iso = lurek.tilemap.newIsoMap(20, 15, 64, 32, 16, 4)
    local h = iso:getHeight()
    local w = iso:getWidth()
    example_print_log("isomap height:", h)
    example_print_log("isomap width:", w)
end

--@api: LIsoMap:getLevelHeight
do
    local iso = lurek.tilemap.newIsoMap(20, 15, 64, 32, 16, 4)
    local lh = iso:getLevelHeight()
    local parts = iso:getPartCount()
    example_print_log("levelHeight:", lh)
    example_print_log("partCount:", parts)
end

--@api: LIsoMap:getPartCount
do
    local iso = lurek.tilemap.newIsoMap(20, 15, 64, 32, 16, 4)
    local pc = iso:getPartCount()
    local lh = iso:getLevelHeight()
    example_print_log("partCount:", pc)
    example_print_log("levelHeight:", lh)
end

--@api: LIsoMap:getTileHeight
do
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local th = iso:getTileHeight()
    local tw = iso:getTileWidth()
    example_print_log("tileHeight:", th)
    example_print_log("tileWidth:", tw)
end

--@api: LIsoMap:getTileWidth
do
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local tw = iso:getTileWidth()
    local th = iso:getTileHeight()
    example_print_log("tileWidth:", tw)
    example_print_log("tileHeight:", th)
end

--@api: LIsoMap:getWidth
do
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local w = iso:getWidth()
    local h = iso:getHeight()
    example_print_log("width:", w)
    example_print_log("height:", h)
end

--@api: LIsoMap:type
do
    local iso = lurek.tilemap.newIsoMap(8, 8, 32, 16, 8, 2)
    local t = iso:type()
    local w = iso:getWidth()
    example_print_log("type:", t)
    example_print_log("width:", w)
    example_print_log("parts:", iso:getPartCount())
end

--@api: LIsoMap:typeOf
do
    local iso = lurek.tilemap.newIsoMap(8, 8, 32, 16, 8, 2)
    local ok = iso:typeOf("LIsoMap")
    local as_object = iso:typeOf("LObject")
    example_print_log("typeOf:", ok)
    example_print_log("typeOfObject:", as_object)
    example_print_log("width:", iso:getWidth())
end

--@api: LLargeMapRenderer:getChunkSize
do
    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
    local cs = lmr:getChunkSize()
    local cols = lmr:getTilesetColumns()
    example_print_log("chunkSize:", cs)
    example_print_log("tilesetColumns:", cols)
end

--@api: LLargeMapRenderer:getTilesetColumns
do
    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
    local cols = lmr:getTilesetColumns()
    local chunk = lmr:getChunkSize()
    example_print_log("tilesetColumns:", cols)
    example_print_log("chunkSize:", chunk)
end

--@api: LLargeMapRenderer:type
do
    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
    local t = lmr:type()
    local chunk = lmr:getChunkSize()
    example_print_log("type:", t)
    example_print_log("chunkSize:", chunk)
    example_print_log("tilesetColumns:", lmr:getTilesetColumns())
end

--@api: LLargeMapRenderer:typeOf
do
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local ok = lmr:typeOf("LLargeMapRenderer")
    local as_object = lmr:typeOf("LObject")
    example_print_log("typeOf:", ok)
    example_print_log("typeOfObject:", as_object)
    example_print_log("chunkSize:", lmr:getChunkSize())
end

--@api: LMapGen:type
do
    local group = lurek.tilemap.newMapGroup("dungeon") ; local mb = lurek.tilemap.newMapBlock(8, 8, 1, 2)
    group:addBlock(mb)
    local gen = lurek.tilemap.newMapGen(group, "small", 4)
    local t = gen:type()
    example_print_log("LMapGen type:", t)
end

--@api: LMapGen:typeOf
do
    local group = lurek.tilemap.newMapGroup("dungeon") ; local mb = lurek.tilemap.newMapBlock(8, 8, 1, 2)
    group:addBlock(mb)
    local gen = lurek.tilemap.newMapGen(group, "small", 4)
    local ok = gen:typeOf("LMapGen")
    example_print_log("LMapGen typeOf:", ok)
end

--@api: LMapScript:getStepCount.2
do
    local script = lurek.tilemap.newMapScript()
    script:addStep({type = "fillArea", gid = 1, x = 0, y = 0, w = 8, h = 8})
    script:addStep({type = "fillRect", x = 1, y = 1, w = 4, h = 4, gid = 2})
    local cnt = script:getStepCount()
    example_print_log("stepCount:", cnt)
end


--@api: lurek.tilemap.syncMinimap
do
    local tilemap = lurek.tilemap.newTileMap(16, 16, 32)
    local minimap = lurek.minimap.newMinimap(16, 16)

    -- Sync the tilemap's collision layer to minimap terrain with options
    lurek.tilemap.syncMinimap(tilemap, 1, minimap, {
        solid_terrain = 2,
        empty_terrain = 1
    })
    example_print_log("minimap synced from tilemap with options")

    -- Also show sync with default terrain values
    local tilemap2 = lurek.tilemap.newTileMap(10, 10, 32)
    local minimap2 = lurek.minimap.newMinimap(10, 10)
    lurek.tilemap.syncMinimap(tilemap2, 1, minimap2)
    example_print_log("minimap synced with defaults")
end
