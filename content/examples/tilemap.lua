-- content/examples/tilemap.lua
-- Auto-generated from content/examples2/tilemap_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/tilemap.lua

--- Tilemap Module Part 1: map creation, layers, tiles, tilesets, solids, viewport

--@api-stub: lurek.tilemap.newTileMap
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    print("type = " .. map:type())
    local tw, th = map:getTileDimensions()
    print("tile size = " .. tw .. "x" .. th)
end

--@api-stub: LTileMap:addLayer
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    local ground = map:addLayer("ground", 50, 50)
    print("ground layer idx = " .. ground)
end

--@api-stub: LTileMap:getLayerName
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("terrain", 40, 30)
    print("layer 1 = " .. map:getLayerName(1))
end

--@api-stub: LTileMap:getLayerCount
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("terrain", 40, 30)
    print("layer count = " .. map:getLayerCount())
end

--@api-stub: LTileMap:setTile
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)
    map:setTile(layer, 3, 4, 5)
    local gid = map:getTile(layer, 3, 4)
    print("tile at 3,4 = " .. gid)
end

--@api-stub: LTileMap:getTile
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)
    map:setTile(layer, 3, 4, 5)
    local gid = map:getTile(layer, 3, 4)
    print("tile at 3,4 = " .. gid)
end

--@api-stub: LTileMap:clearTile
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)
    map:setTile(layer, 3, 4, 5)
    map:clearTile(layer, 3, 4)
    local gid = map:getTile(layer, 3, 4)
    print("after clear = " .. gid)
end

--@api-stub: LTileMap:fill
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("ground", 20, 20)
    map:fill(layer, 3)
    print("fill complete, sample = " .. map:getTile(layer, 10, 10))
    print("corner = " .. map:getTile(layer, 1, 1))
end

--@api-stub: LTileMap:findTilesByGid
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)

    map:setTile(layer, 2, 3, 7)
    map:setTile(layer, 5, 1, 7)
    map:setTile(layer, 8, 9, 7)
    map:setTile(layer, 4, 4, 2)

    local positions = map:findTilesByGid(layer, 7)
    print("found gid=7 count = " .. #positions)
    for _, pos in ipairs(positions) do
        print("  x=" .. pos.x .. " y=" .. pos.y)
    end
end

--@api-stub: lurek.tilemap.newTileSet
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 64, 8, 32, 32)
    print("type = " .. ts:type())
    print("first gid = " .. ts:getFirstGid())
    print("tile count = " .. ts:getTileCount())
end

--@api-stub: LTileSet:isSolid
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 32, 32)
    ts:setSolid(1, true)
    print("tile 1 solid = " .. tostring(ts:isSolid(1)))
    print("tile 2 solid = " .. tostring(ts:isSolid(2)))
end

--@api-stub: LTileSet:setSolid
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 32, 32)
    ts:setSolid(1, true)
    print("tile 1 solid = " .. tostring(ts:isSolid(1)))
end

--@api-stub: LTileSet:getQuad
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 32, 32)
    local q1 = ts:getQuad(1)
    print("tile 1: x=" .. q1.x .. " y=" .. q1.y .. " w=" .. q1.width .. " h=" .. q1.height)
    local q5 = ts:getQuad(5)
    print("tile 5: x=" .. q5.x .. " y=" .. q5.y .. " w=" .. q5.width .. " h=" .. q5.height)
end

--@api-stub: LTileSet:setAnimation
do
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    ts:setAnimation(1, {
        { tileid = 1, duration = 200 },
        { tileid = 2, duration = 200 },
        { tileid = 3, duration = 200 },
        { tileid = 4, duration = 200 },
    })

    local anim = ts:getAnimation(1)
    print("animation frames = " .. #anim)
    for i, frame in ipairs(anim) do
        print("  frame " .. i .. ": tile=" .. frame.tileid .. " dur=" .. frame.duration)
    end
    local noAnim = ts:getAnimation(10)
    print("tile 10 anim = " .. tostring(noAnim))
end

--@api-stub: LTileSet:getAnimation
do
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    ts:setAnimation(1, {
        { tileid = 1, duration = 200 },
        { tileid = 2, duration = 200 },
        { tileid = 3, duration = 200 },
        { tileid = 4, duration = 200 },
    })

    local anim = ts:getAnimation(1)
    print("animation frames = " .. #anim)
    for i, frame in ipairs(anim) do
        print("  frame " .. i .. ": tile=" .. frame.tileid .. " dur=" .. frame.duration)
    end
    local noAnim = ts:getAnimation(10)
    print("tile 10 anim = " .. tostring(noAnim))
end

--@api-stub: LTileMap:addTileSet
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local terrain = lurek.tilemap.newTileSet(1, 64, 8, 32, 32)
    local objects = lurek.tilemap.newTileSet(65, 32, 8, 32, 32)

    map:addTileSet(terrain)
    map:addTileSet(objects)
    print("tileset count = " .. map:getTileSetCount())
end

--@api-stub: LTileMap:getTileSet
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local terrain = lurek.tilemap.newTileSet(1, 64, 8, 32, 32)
    local objects = lurek.tilemap.newTileSet(65, 32, 8, 32, 32)

    map:addTileSet(terrain)
    map:addTileSet(objects)
    local ts1 = map:getTileSet(1)
    print("tileset 1 first gid = " .. ts1:getFirstGid())
end

--@api-stub: LTileMap:getTileSetCount
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local terrain = lurek.tilemap.newTileSet(1, 64, 8, 32, 32)
    local objects = lurek.tilemap.newTileSet(65, 32, 8, 32, 32)

    map:addTileSet(terrain)
    map:addTileSet(objects)
    print("tileset count = " .. map:getTileSetCount())
end

--@api-stub: LTileMap:isSolid
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 32, 32)
    ts:setSolid(1, true)
    map:addTileSet(ts)

    local layer = map:addLayer("collision", 10, 10)
    map:setTile(layer, 3, 3, 1)
    map:setTile(layer, 4, 3, 1)

    print("3,3 solid = " .. tostring(map:isSolid(layer, 3, 3)))
    print("5,5 solid = " .. tostring(map:isSolid(layer, 5, 5)))
end

--@api-stub: LTileMap:rectOverlapsSolid
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 32, 32)
    ts:setSolid(1, true)
    map:addTileSet(ts)

    local layer = map:addLayer("collision", 10, 10)
    map:setTile(layer, 3, 3, 1)
    map:setTile(layer, 4, 3, 1)

    local overlap = map:rectOverlapsSolid(layer, 80, 80, 40, 40)
    print("rect overlaps solid = " .. tostring(overlap))
end

--@api-stub: LTileMap:setViewport
do
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("ground", 100, 100)
    map:setViewport(0, 0, 800, 600)
    local vx, vy, vw, vh = map:getViewport()
    print("viewport = " .. vx .. "," .. vy .. " " .. vw .. "x" .. vh)
end

--@api-stub: LTileMap:getViewport
do
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("ground", 100, 100)
    map:setViewport(0, 0, 800, 600)
    local vx, vy, vw, vh = map:getViewport()
    print("viewport = " .. vx .. "," .. vy .. " " .. vw .. "x" .. vh)
end

--@api-stub: LTileMap:render
do
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("ground", 100, 100)
    map:setViewport(0, 0, 800, 600)

    map:render()
    print("rendered at origin")
    map:render(10, 10)
    print("rendered with offset")
end

--@api-stub: LTileMap:worldToTile
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 20, 20)
    local tx, ty = map:worldToTile(100, 80)
    print("world(100,80) -> tile(" .. tx .. "," .. ty .. ")")
end

--@api-stub: LTileMap:tileToWorld
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 20, 20)
    local wx, wy = map:tileToWorld(5, 3)
    print("tile(5,3) -> world(" .. wx .. "," .. wy .. ")")
end

--@api-stub: LTileMap:setLayerVisible
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("background", 20, 20)
    map:setLayerVisible(1, false)
    print("after hide = " .. tostring(map:getLayerVisible(1)))
end

--@api-stub: LTileMap:getLayerVisible
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("background", 20, 20)
    print("layer 1 visible = " .. tostring(map:getLayerVisible(1)))
end

--@api-stub: LTileMap:setLayerColor
do
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("tinted", 10, 10)
    map:setLayerColor(1, 0.8, 0.5, 0.5, 0.9)
    local r, g, b, a = map:getLayerColor(1)
    print("layer color = " .. r .. ", " .. g .. ", " .. b .. ", " .. a)
end

--@api-stub: LTileMap:getLayerColor
do
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("tinted", 10, 10)
    map:setLayerColor(1, 0.8, 0.5, 0.5, 0.9)
    local r, g, b, a = map:getLayerColor(1)
    print("layer color = " .. r .. ", " .. g .. ", " .. b .. ", " .. a)
end

--@api-stub: LTileMap:setLayerOffset
do
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("shifted", 10, 10)
    map:setLayerOffset(1, 16, 8)
    local ox, oy = map:getLayerOffset(1)
    print("offset = " .. ox .. ", " .. oy)
end

--@api-stub: LTileMap:getLayerOffset
do
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("shifted", 10, 10)
    map:setLayerOffset(1, 16, 8)
    local ox, oy = map:getLayerOffset(1)
    print("offset = " .. ox .. ", " .. oy)
end

--@api-stub: LTileMap:setLayerParallax
do
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("background", 40, 30)
    map:setLayerParallax(1, 0.5, 0.5)
    local px, py = map:getLayerParallax(1)
    print("bg parallax = " .. px .. ", " .. py)
end

--@api-stub: LTileMap:getLayerParallax
do
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("background", 40, 30)
    map:setLayerParallax(1, 0.5, 0.5)
    local px, py = map:getLayerParallax(1)
    print("bg parallax = " .. px .. ", " .. py)
end

--- Tilemap Module Part 2: auto-tiling, collision sweep, tile callbacks, navigation

--@api-stub: LTileSet:setAutoTileRule
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    ts:setAutoTileRule("grass", 0, 1)
    local id = ts:getAutoTileId("grass", 0)
    print("bitmask 0 -> tile " .. id)
end

--@api-stub: LTileSet:getAutoTileId
do
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    ts:setAutoTileRule("grass", 0, 1)
    ts:setAutoTileRule("grass", 15, 16)
    local id = ts:getAutoTileId("grass", 15)
    print("bitmask 15 -> tile " .. id)
end

--@api-stub: LTileSet:setAutoTileRule8
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 256, 16, 16, 16)
    ts:setAutoTileRule8("wall", 0, 1)
    local id = ts:getAutoTileId8("wall", 0)
    print("8-bit bitmask 0 -> tile " .. id)
end

--@api-stub: LTileSet:getAutoTileId8
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 256, 16, 16, 16)
    ts:setAutoTileRule8("wall", 255, 48)
    local id = ts:getAutoTileId8("wall", 255)
    print("8-bit bitmask 255 -> tile " .. id)
end

--@api-stub: lurek.tilemap.newAutoTileSheet
do
    local blob = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    print("blob47 layout = " .. blob:getLayout())
    print("blob47 tile count = " .. blob:getTileCount())
    print("blob47 tile size = " .. blob:getTileWidth() .. "x" .. blob:getTileHeight())
    local minimal = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")
    print("minimal16 tile count = " .. minimal:getTileCount())
end

--@api-stub: LAutoTileSheet:applyToTileSet
do
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    local ts = lurek.tilemap.newTileSet(1, 64, 8, 16, 16)

    sheet:applyToTileSet(ts, "terrain")
    local id = ts:getAutoTileId("terrain", 5)
    print("after apply, bitmask 5 -> tile " .. tostring(id))

    sheet:applyToTileSet(ts, "water", 17)
    id = ts:getAutoTileId("water", 0)
    print("water bitmask 0 -> tile " .. tostring(id))
end

--@api-stub: LAutoTileSheet:getBitmaskForTile
do
    ---@type LAutoTileSheet
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")
    local bitmask = sheet:getBitmaskForTile(3)
    print("tile 3 has bitmask = " .. bitmask)
end

--@api-stub: LAutoTileSheet:getTileForBitmask
do
    ---@type LAutoTileSheet
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")
    local tile = sheet:getTileForBitmask(7)
    print("bitmask 7 -> tile " .. tile)
end

--@api-stub: LAutoTileSheet:getQuad
do
    ---@type LAutoTileSheet
    local sheet = lurek.tilemap.newAutoTileSheet(32, 32, "composite48")
    print("composite48 count = " .. sheet:getTileCount())
    local x, y, w, h = sheet:getQuad(1)
    print("quad 1: x=" .. x .. " y=" .. y .. " w=" .. w .. " h=" .. h)
end

--@api-stub: LTileMap:applyAutoTile
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
    print("4-bit auto-tile applied")
    print("center tile after auto = " .. gid)
end

--@api-stub: LTileMap:applyAutoTile8
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

    print("8-bit auto-tile applied")
end

--@api-stub: LTileMap:applyAutoTileAt
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")

    sheet:applyToTileSet(ts, "dirt")
    map:addTileSet(ts)

    local layer = map:addLayer("ground", 10, 10)
    map:fill(layer, 1)
    map:applyAutoTileAt(layer, 5, 5, "dirt")
    print("single cell auto-tiled at 5,5")
end

--@api-stub: LTileMap:applyAutoTile8At
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")

    sheet:applyToTileSet(ts, "dirt")
    map:addTileSet(ts)

    local layer = map:addLayer("ground", 10, 10)
    map:fill(layer, 1)
    map:applyAutoTile8At(layer, 3, 3, "dirt")
    print("single cell 8-bit auto-tiled at 3,3")
end

--@api-stub: LTileMap:sweepRect
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 32, 32)
    ts:setSolid(1, true)
    map:addTileSet(ts)

    local layer = map:addLayer("collision", 20, 20)
    map:setTile(layer, 5, 5, 1)
    map:setTile(layer, 6, 5, 1)

    local cx, cy, nx, ny, tx, ty = map:sweepRect(layer, 64, 64, 16, 16, 200, 0)
    print("contact pos = " .. cx .. ", " .. cy)
    print("normal = " .. nx .. ", " .. ny)
    print("tile hit = " .. tx .. ", " .. ty)
end

--@api-stub: LTileMap:onTileEnter
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("triggers", 10, 10)
    map:setTile(layer, 3, 3, 5)
    map:onTileEnter(5, function(entity, tx, ty) print("entity entered trigger tile at " .. tx .. "," .. ty) end)
    print("enter callback registered for gid=5")
end

--@api-stub: LTileMap:onTileExit
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("triggers", 10, 10)
    map:setTile(layer, 3, 3, 5)
    map:onTileExit(5, function(entity, tx, ty) print("entity left trigger tile at " .. tx .. "," .. ty) end)
    print("exit callback registered for gid=5")
end

--@api-stub: LTileMap:onTileStep
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("triggers", 10, 10)
    map:setTile(layer, 3, 3, 5)
    map:onTileStep(5, function(entity, tx, ty) print("entity stepping on trigger at " .. tx .. "," .. ty) end)
    print("step callback registered for gid=5")
end

--@api-stub: LTileMap:checkEntities
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("events", 10, 10)
    map:setTile(layer, 2, 2, 3)
    map:onTileEnter(3, function(entity, tx, ty) print("entered at " .. tx .. "," .. ty) end)
    local entities = {
        { x = 64, y = 64 },
        { x = 128, y = 128 },
    }

    map:checkEntities(layer, entities)
    print("entities checked against tile events")
end

--@api-stub: LTileMap:fireTileExit
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("events", 10, 10)
    map:setTile(layer, 2, 2, 3)
    map:onTileEnter(3, function(entity, tx, ty) print("entered at " .. tx .. "," .. ty) end)
    local entities = {
        { x = 64, y = 64 },
        { x = 128, y = 128 },
    }

    map:fireTileExit(3, entities[1], 2, 2)
    print("tile exit fired")
end

--@api-stub: LTileMap:fireTileStep
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("events", 10, 10)
    map:setTile(layer, 2, 2, 3)
    map:onTileEnter(3, function(entity, tx, ty) print("entered at " .. tx .. "," .. ty) end)
    local entities = {
        { x = 64, y = 64 },
        { x = 128, y = 128 },
    }

    map:fireTileStep(3, entities[1], 2, 2)
    print("tile step fired")
end

--@api-stub: LTileMap:tileTypeIndex
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("terrain", 5, 5)

    map:setTile(layer, 1, 1, 1)
    map:setTile(layer, 2, 1, 1)
    map:setTile(layer, 3, 1, 2)
    map:setTile(layer, 4, 1, 3)

    local index = map:tileTypeIndex(layer)
    print("tile type index built")
    for gid, positions in pairs(index) do
        print("  gid " .. gid .. " has " .. #positions .. " tiles")
    end
end

--@api-stub: LTileMap:toNavGrid
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
    print("nav grid rows = " .. #grid)
    print("cell 1,1 walkable = " .. tostring(grid[1][1]))
end

--@api-stub: LTileMap:setTileTint
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("tinted", 10, 10)

    map:setTile(layer, 1, 1, 1)
    map:setTile(layer, 2, 1, 1)
    map:setTile(layer, 3, 1, 1)
    map:setTileTint(layer, 1, 1, 1.0, 0.0, 0.0, 1.0)
    map:setTileTint(layer, 2, 1, 0.0, 1.0, 0.0, 1.0)
    map:setTileTint(layer, 3, 1, 0.0, 0.0, 1.0, 1.0)
    print("RGB tints applied to 3 tiles")
end

--@api-stub: LTileMap:setOrientation
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 10, 10)
    map:setOrientation("isometric")
    print("set to " .. map:getOrientation())
end

--@api-stub: LTileMap:getOrientation
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 10, 10)
    print("default orientation = " .. map:getOrientation())
end

--@api-stub: LTileMap:drawToImage
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local layer = map:addLayer("simple", 8, 8)
    map:fill(layer, 1)
    local img = map:drawToImage(16)
    print("image type = " .. img:type())
    print("drawn to image at tile size 16")
end

--@api-stub: LTileMap:update
do
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("animated", 10, 10)

    local dt = 1 / 60
    map:update(dt)
    map:update(dt)
    map:update(dt)
    print("updated 3 frames at 60fps")
end

--- Tilemap Module Part 3: hex utilities, iso helpers, coordinate conversion, TMX/LDtk loading

--@api-stub: lurek.tilemap.toScreenHex
do
    local sx, sy = lurek.tilemap.toScreenHex(2, 3, 32)
    print("hex(2,3) -> screen(" .. sx .. ", " .. sy .. ")")
end

--@api-stub: lurek.tilemap.hexDistance
do
    local d = lurek.tilemap.hexDistance(0, 0, 3, 2)
    print("hex distance (0,0) to (3,2) = " .. d)
    d = lurek.tilemap.hexDistance(1, 1, 1, 1)
    print("same cell distance = " .. d)
    d = lurek.tilemap.hexDistance(-2, 1, 2, -1)
    print("across-origin distance = " .. d)
end

--@api-stub: lurek.tilemap.hexNeighbors
do
    local neighbors = lurek.tilemap.hexNeighbors(3, 4)
    print("neighbors of (3,4): " .. #neighbors .. " cells")
    for i, n in ipairs(neighbors) do
        print("  " .. i .. ": q=" .. n.q .. " r=" .. n.r)
    end
end

--@api-stub: lurek.tilemap.hexRing
do
    local ring = lurek.tilemap.hexRing(0, 0, 2)
    print("ring at radius 2: " .. #ring .. " cells")
    for _, cell in ipairs(ring) do
        print("  q=" .. cell.q .. " r=" .. cell.r)
    end
end

--@api-stub: lurek.tilemap.hexArea
do
    local area = lurek.tilemap.hexArea(0, 0, 1)
    print("area radius 1: " .. #area .. " cells")
    local bigArea = lurek.tilemap.hexArea(5, 5, 3)
    print("area radius 3 around (5,5): " .. #bigArea .. " cells")
end

--@api-stub: lurek.tilemap.hexSpiral
do
    local spiral = lurek.tilemap.hexSpiral(0, 0, 2)
    print("spiral radius 2: " .. #spiral .. " cells")
    print("center = q=" .. spiral[1].q .. " r=" .. spiral[1].r)
end

--@api-stub: lurek.tilemap.hexLine
do
    local line = lurek.tilemap.hexLine(0, 0, 4, 2)
    print("line (0,0) to (4,2): " .. #line .. " cells")
    for i, cell in ipairs(line) do
        print("  step " .. i .. ": q=" .. cell.q .. " r=" .. cell.r)
    end
end

--@api-stub: lurek.tilemap.hexRound
do
    local q, r = lurek.tilemap.hexRound(2.3, 1.7)
    print("round(2.3, 1.7) = " .. q .. ", " .. r)
    q, r = lurek.tilemap.hexRound(-0.4, 0.6)
    print("round(-0.4, 0.6) = " .. q .. ", " .. r)
end

--@api-stub: lurek.tilemap.hexRotate
do
    local q, r = lurek.tilemap.hexRotate(2, 0, 0, 0, 1)
    print("(2,0) rotated 60deg CW around origin = " .. q .. ", " .. r)
    q, r = lurek.tilemap.hexRotate(2, 0, 0, 0, 3)
    print("(2,0) rotated 180deg = " .. q .. ", " .. r)
end

--@api-stub: lurek.tilemap.hexReflect
do
    local q, r = lurek.tilemap.hexReflect(3, 1, 0, 0, "q")
    print("reflect (3,1) across q axis = " .. q .. ", " .. r)
    q, r = lurek.tilemap.hexReflect(2, -1, 0, 0, "r")
    print("reflect (2,-1) across r axis = " .. q .. ", " .. r)
end

--@api-stub: lurek.tilemap.toScreenIso
do
    local sx, sy = lurek.tilemap.toScreenIso(3, 5, 64, 32)
    print("tile(3,5) -> screen(" .. sx .. ", " .. sy .. ")")
end

--@api-stub: lurek.tilemap.isoDirectionFromAngle
do
    local dir = lurek.tilemap.isoDirectionFromAngle(45)
    print("45 degrees -> direction " .. dir)
end

--@api-stub: lurek.tilemap.loadTMX
do
    local tmxData = [[<?xml version="1.0" encoding="UTF-8"?> <map version="1.10" orientation="orthogonal" width="4" height="4" tilewidth="32" tileheight="32"> <layer name="ground" width="4" height="4"> <data encoding="csv">1,1,1,1,1,2,2,1,1,2,2,1,1,1,1,1</data> </layer> </map>]]
    local result = lurek.tilemap.loadTMX(tmxData)
    print("TMX width = " .. result.width)
    print("TMX height = " .. result.height)
    print("TMX tile size = " .. result.tileWidth .. "x" .. result.tileHeight)
    print("TMX orientation = " .. result.orientation)
    print("TMX layers = " .. #result.layers)
end

--@api-stub: lurek.tilemap.fromLDtk
do
    local ldtkJson = '{"levels":[{"identifier":"Level_0","layerInstances":[]}]}'
    local map = lurek.tilemap.fromLDtk(ldtkJson)
    print("LDtk map type = " .. map:type())
    local named = lurek.tilemap.fromLDtk(ldtkJson, "Level_0")
    print("named level loaded")
end

--@api-stub: lurek.tilemap.FLOOR
do
    print("FLOOR = " .. lurek.tilemap.FLOOR)
    print("FLOOR type = " .. type(lurek.tilemap.FLOOR))
end

--@api-stub: lurek.tilemap.NORTH_WALL
do
    print("NORTH_WALL = " .. lurek.tilemap.NORTH_WALL)
    print("NORTH_WALL ~= FLOOR: " .. tostring(lurek.tilemap.NORTH_WALL ~= lurek.tilemap.FLOOR))
end

--@api-stub: lurek.tilemap.WEST_WALL
do
    print("WEST_WALL = " .. lurek.tilemap.WEST_WALL)
    print("WEST_WALL ~= NORTH_WALL: " .. tostring(lurek.tilemap.WEST_WALL ~= lurek.tilemap.NORTH_WALL))
end

--@api-stub: lurek.tilemap.OBJECT
do
    print("OBJECT = " .. lurek.tilemap.OBJECT)
    print("OBJECT ~= FLOOR: " .. tostring(lurek.tilemap.OBJECT ~= lurek.tilemap.FLOOR))
end

--- Tilemap Module Part 4: ChunkMap, IsoMap, LargeMapRenderer, MapBlock, MapGroup, MapScript, MapGen

--@api-stub: lurek.tilemap.newChunkMap
do
    ---@type LChunkMap
    local cm = lurek.tilemap.newChunkMap(16)
    print("type = " .. cm:type())
    print("chunk size = " .. cm:getChunkSize())
end

--@api-stub: LChunkMap:setTile
do
    ---@type LChunkMap
    local cm = lurek.tilemap.newChunkMap(16)
    cm:setTile(10, 20, 5)
    local gid = cm:getTile(10, 20)
    print("tile at 10,20 = " .. gid)
end

--@api-stub: LChunkMap:getTile
do
    ---@type LChunkMap
    local cm = lurek.tilemap.newChunkMap(16)
    cm:setTile(10, 20, 5)
    local gid = cm:getTile(10, 20)
    print("tile at 10,20 = " .. gid)
end

--@api-stub: LChunkMap:clearTile
do
    local cm = lurek.tilemap.newChunkMap(16)
    cm:setTile(10, 20, 5)
    cm:clearTile(10, 20)
    local gid = cm:getTile(10, 20)
    print("after clear = " .. gid)
end

--@api-stub: LChunkMap:fillRect
do
    local cm = lurek.tilemap.newChunkMap(16)
    cm:fillRect(0, 0, 10, 10, 3)
    print("filled 11x11 area with gid=3")
    print("sample (5,5) = " .. cm:getTile(5, 5))
    print("sample (11,11) = " .. cm:getTile(11, 11))
end

--@api-stub: LChunkMap:loadChunk
do
    local cm = lurek.tilemap.newChunkMap(16)
    cm:loadChunk(0, 0)
    local loaded = cm:getLoadedChunks()
    print("loaded chunks = " .. #loaded)
    for _, c in ipairs(loaded) do print("  chunk (" .. c.cx .. ", " .. c.cy .. ")") end
end

--@api-stub: LChunkMap:unloadChunk
do
    local cm = lurek.tilemap.newChunkMap(16) ; cm:loadChunk(0, 0)
    cm:loadChunk(1, 0)
    cm:unloadChunk(1, 0)
    local loaded = cm:getLoadedChunks()
    print("after unload = " .. #loaded .. " chunks")
end

--@api-stub: LChunkMap:getLoadedChunks
do
    local cm = lurek.tilemap.newChunkMap(16) ; cm:loadChunk(0, 0)
    cm:loadChunk(1, 0) ; cm:loadChunk(0, 1)
    local loaded = cm:getLoadedChunks()
    print("loaded chunks = " .. #loaded)
    for _, c in ipairs(loaded) do print("  chunk (" .. c.cx .. ", " .. c.cy .. ")") end
end

--@api-stub: LChunkMap:chunkTileRange
do
    local cm = lurek.tilemap.newChunkMap(16)
    local minX, minY, maxX, maxY = cm:chunkTileRange(2, 3)
    print("chunk (2,3) covers tiles:")
    print("  min = " .. minX .. ", " .. minY)
    print("  max = " .. maxX .. ", " .. maxY)
end

--@api-stub: LChunkMap:getChunksInView
do
    local cm = lurek.tilemap.newChunkMap(16)
    local visible = cm:getChunksInView(0, 0, 800, 600, 32, 32)
    print("visible chunks in 800x600 viewport: " .. #visible)
    for i = 1, math.min(3, #visible) do print("  chunk (" .. visible[i].cx .. ", " .. visible[i].cy .. ")") end
end

--@api-stub: lurek.tilemap.newIsoMap
do
    local iso = lurek.tilemap.newIsoMap(20, 20, 64, 32, 16)
    print("type = " .. iso:type())
    print("size = " .. iso:getWidth() .. "x" .. iso:getHeight())
    print("tile size = " .. iso:getTileWidth() .. "x" .. iso:getTileHeight())
    print("level height = " .. iso:getLevelHeight())
end

--@api-stub: LIsoMap:addLevel
do
    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local lvl = iso:addLevel()
    print("added level, count = " .. iso:getLevelCount())
end

--@api-stub: LIsoMap:getLevelCount
do
    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local lvl = iso:addLevel()
    print("added level, count = " .. iso:getLevelCount())
end

--@api-stub: LIsoMap:setTilePart
do
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    iso:addLevel()
    iso:setTilePart(1, 3, 4, 1, 5)
    local gid = iso:getTilePart(1, 3, 4, 1)
    print("tile part at (1,3,4,part=1) = " .. gid)
end

--@api-stub: LIsoMap:getTilePart
do
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    iso:addLevel()
    iso:setTilePart(1, 3, 4, 1, 5)
    local gid = iso:getTilePart(1, 3, 4, 1)
    print("tile part at (1,3,4,part=1) = " .. gid)
end

--@api-stub: LIsoMap:fillLevel
do
    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(8, 8, 64, 32, 16)
    iso:addLevel()
    iso:fillLevel(1, 1, 3)
    print("filled level 1, part 1 with gid=3")
end

--@api-stub: LIsoMap:isLevelVisible
do
    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(8, 8, 64, 32, 16)
    iso:addLevel()
    print("level 1 visible = " .. tostring(iso:isLevelVisible(1)))
end

--@api-stub: LIsoMap:setLevelVisible
do
    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(8, 8, 64, 32, 16)
    iso:addLevel()
    iso:setLevelVisible(1, false)
    print("after hide = " .. tostring(iso:isLevelVisible(1)))
end

--@api-stub: LIsoMap:screenToTile
do
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16)
    iso:setOrigin(400, 100)
    local sx, sy = iso:tileToScreen(3, 2, 1)
    local tx, ty = iso:screenToTile(sx, sy)
    print("screen -> tile(" .. tx .. ", " .. ty .. ")")
end

--@api-stub: LIsoMap:tileToScreen
do
    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16)
    iso:setOrigin(400, 100)
    local sx, sy = iso:tileToScreen(3, 2, 1)
    print("tile(3,2,z=1) -> screen(" .. sx .. ", " .. sy .. ")")
end

--@api-stub: LIsoMap:setOrigin
do
    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16)
    iso:setOrigin(400, 100)
    print("origin set")
end

--@api-stub: LIsoMap:setPartOrder
do
    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(5, 5, 64, 32, 16, 4)
    iso:setPartOrder({ 4, 3, 2, 1 })
    local order = iso:getPartOrder()
    print("reversed order[1] = " .. order[1])
end

--@api-stub: LIsoMap:getPartOrder
do
    local iso = lurek.tilemap.newIsoMap(5, 5, 64, 32, 16, 4) ; local order = iso:getPartOrder()
    print("default part order: " .. #order .. " entries")
    iso:setPartOrder({ 4, 3, 2, 1 })
    order = iso:getPartOrder()
    print("reversed order[1] = " .. order[1])
end

--@api-stub: lurek.tilemap.newLargeMapRenderer
do
    ---@type LLargeMapRenderer
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    print("type = " .. lmr:type())
    print("chunk size = " .. lmr:getChunkSize())
end

--@api-stub: LLargeMapRenderer:setMapData
do
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; local data = {}
    for i = 1, 100 * 100 do data[i] = (i % 4) + 1 end ; lmr:setMapData(data, 100, 100)
    local w, h = lmr:getMapSize() ; print("map size = " .. w .. "x" .. h)
    print("tile at (50,50) = " .. lmr:getTile(50, 50)) ; lmr:setTile(50, 50, 99)
    print("after set = " .. lmr:getTile(50, 50))
end

--@api-stub: LLargeMapRenderer:getMapSize
do
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; local data = {}
    for i = 1, 100 * 100 do data[i] = (i % 4) + 1 end ; lmr:setMapData(data, 100, 100)
    local w, h = lmr:getMapSize() ; print("map size = " .. w .. "x" .. h)
    print("tile at (50,50) = " .. lmr:getTile(50, 50)) ; lmr:setTile(50, 50, 99)
    print("after set = " .. lmr:getTile(50, 50))
end

--@api-stub: LLargeMapRenderer:getTile
do
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; local data = {}
    for i = 1, 100 * 100 do data[i] = (i % 4) + 1 end ; lmr:setMapData(data, 100, 100)
    local w, h = lmr:getMapSize() ; print("map size = " .. w .. "x" .. h)
    print("tile at (50,50) = " .. lmr:getTile(50, 50)) ; lmr:setTile(50, 50, 99)
    print("after set = " .. lmr:getTile(50, 50))
end

--@api-stub: LLargeMapRenderer:setTile
do
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; local data = {}
    for i = 1, 100 * 100 do data[i] = (i % 4) + 1 end ; lmr:setMapData(data, 100, 100)
    local w, h = lmr:getMapSize() ; print("map size = " .. w .. "x" .. h)
    print("tile at (50,50) = " .. lmr:getTile(50, 50)) ; lmr:setTile(50, 50, 99)
    print("after set = " .. lmr:getTile(50, 50))
end

--@api-stub: LLargeMapRenderer:setCamera
do
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; local data = {}
    for i = 1, 200 * 200 do data[i] = 1 end ; lmr:setMapData(data, 200, 200)
    lmr:setViewport(800, 600) ; lmr:setCamera(3200, 3200, 1.0)
    print("total chunks = " .. lmr:getTotalChunks())
    print("visible chunks = " .. lmr:getVisibleChunks())
end

--@api-stub: LLargeMapRenderer:setViewport
do
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; local data = {}
    for i = 1, 200 * 200 do data[i] = 1 end ; lmr:setMapData(data, 200, 200)
    lmr:setViewport(800, 600) ; lmr:setCamera(3200, 3200, 1.0)
    print("total chunks = " .. lmr:getTotalChunks())
    print("visible chunks = " .. lmr:getVisibleChunks())
end

--@api-stub: LLargeMapRenderer:getVisibleChunks
do
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; local data = {}
    for i = 1, 200 * 200 do data[i] = 1 end ; lmr:setMapData(data, 200, 200)
    lmr:setViewport(800, 600) ; lmr:setCamera(3200, 3200, 1.0)
    print("total chunks = " .. lmr:getTotalChunks())
    print("visible chunks = " .. lmr:getVisibleChunks())
end

--@api-stub: LLargeMapRenderer:getTotalChunks
do
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; local data = {}
    for i = 1, 200 * 200 do data[i] = 1 end ; lmr:setMapData(data, 200, 200)
    lmr:setViewport(800, 600) ; lmr:setCamera(3200, 3200, 1.0)
    print("total chunks = " .. lmr:getTotalChunks())
    print("visible chunks = " .. lmr:getVisibleChunks())
end

--@api-stub: LLargeMapRenderer:setLodEnabled
do
    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16) ; print("LOD enabled = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodEnabled(true)
    print("after enable = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodThresholds({ 0.5, 0.25, 0.1 })
    print("LOD thresholds set")
end

--@api-stub: LLargeMapRenderer:isLodEnabled
do
    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16) ; print("LOD enabled = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodEnabled(true)
    print("after enable = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodThresholds({ 0.5, 0.25, 0.1 })
    print("LOD thresholds set")
end

--@api-stub: LLargeMapRenderer:setLodThresholds
do
    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16) ; print("LOD enabled = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodEnabled(true)
    print("after enable = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodThresholds({ 0.5, 0.25, 0.1 })
    print("LOD thresholds set")
end

--@api-stub: LLargeMapRenderer:invalidateAll
do
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; lmr:setChunkSize(32)
    print("chunk size = " .. lmr:getChunkSize()) ; lmr:setTilesetColumns(16)
    print("tileset columns = " .. lmr:getTilesetColumns()) ; lmr:invalidateChunk(0, 0)
    lmr:invalidateAll()
    print("all chunks invalidated")
end

--@api-stub: LLargeMapRenderer:invalidateChunk
do
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; lmr:setChunkSize(32)
    print("chunk size = " .. lmr:getChunkSize()) ; lmr:setTilesetColumns(16)
    print("tileset columns = " .. lmr:getTilesetColumns()) ; lmr:invalidateChunk(0, 0)
    lmr:invalidateAll()
    print("all chunks invalidated")
end

--@api-stub: LLargeMapRenderer:setChunkSize
do
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; lmr:setChunkSize(32)
    print("chunk size = " .. lmr:getChunkSize()) ; lmr:setTilesetColumns(16)
    print("tileset columns = " .. lmr:getTilesetColumns()) ; lmr:invalidateChunk(0, 0)
    lmr:invalidateAll()
    print("all chunks invalidated")
end

--@api-stub: LLargeMapRenderer:setTilesetColumns
do
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; lmr:setChunkSize(32)
    print("chunk size = " .. lmr:getChunkSize()) ; lmr:setTilesetColumns(16)
    print("tileset columns = " .. lmr:getTilesetColumns()) ; lmr:invalidateChunk(0, 0)
    lmr:invalidateAll()
    print("all chunks invalidated")
end

--@api-stub: lurek.tilemap.newMapBlock
do
    local block = lurek.tilemap.newMapBlock(8, 8, 2, 2) ; print("type = " .. block:type())
    local w, h = block:getDimensions() ; print("dimensions = " .. w .. "x" .. h)
    print("layers = " .. block:getLayerCount()) ; print("segment size = " .. block:getSegmentSize())
    print("width in segments = " .. block:getWidthInSegments())
    print("height in segments = " .. block:getHeightInSegments())
end

-- Duplicate coverage lives in content/examples/mapblock.lua.
do
    local block = lurek.tilemap.newMapBlock(4, 4)
    block:setTile(1, 1, 1, 5)
    block:setTile(1, 2, 2, 8)
    print("tile (1,1,1) = " .. tostring(block:getTile(1, 1, 1)))
    print("tile (1,2,2) = " .. tostring(block:getTile(1, 2, 2)))
end

-- Duplicate coverage lives in content/examples/mapblock.lua.
do
    local block = lurek.tilemap.newMapBlock(4, 4)
    block:setName("room_corner")
    print("name = " .. tostring(block:getName()))
end

-- Duplicate coverage lives in content/examples/mapblock.lua.
do
    local block = lurek.tilemap.newMapBlock(4, 4)
    block:setWeight(3.0)
    print("weight = " .. tostring(block:getWeight()))
end

-- Duplicate coverage lives in content/examples/mapblock.lua.
do
    local block = lurek.tilemap.newMapBlock(3, 3)
    block:setName("entry")
    print("getName = " .. tostring(block:getName()))
end

-- Duplicate coverage lives in content/examples/mapblock.lua.
do
    local block = lurek.tilemap.newMapBlock(3, 3)
    block:setTile(1, 2, 2, 9)
    print("getTile = " .. tostring(block:getTile(1, 2, 2)))
end

--@api-stub: LMapBlock:getWeight
do
    local block = lurek.tilemap.newMapBlock(2, 2)
    block:setWeight(2.5)
    print("getWeight = " .. tostring(block:getWeight()))
end

--@api-stub: LMapBlock:setSide
do
    local block = lurek.tilemap.newMapBlock(4, 4, 1, 2) ; block:setSide("north", 1, 10)
    block:setSide("north", 2, 20) ; block:setSide("south", 1, 10)
    block:setSide("east", 1, 30) ; print("north seg 1 = " .. block:getSide("north", 1))
    print("north seg 2 = " .. block:getSide("north", 2))
    print("east seg 1 = " .. block:getSide("east", 1))
end

--@api-stub: LMapBlock:getSide
do
    local block = lurek.tilemap.newMapBlock(4, 4, 1, 2) ; block:setSide("north", 1, 10)
    block:setSide("north", 2, 20) ; block:setSide("south", 1, 10)
    block:setSide("east", 1, 30) ; print("north seg 1 = " .. block:getSide("north", 1))
    print("north seg 2 = " .. block:getSide("north", 2))
    print("east seg 1 = " .. block:getSide("east", 1))
end

--@api-stub: lurek.tilemap.newMapGroup
do
    local group = lurek.tilemap.newMapGroup("dungeon") ; print("type = " .. group:type()) ; print("name = " .. group:getName())
    local b1 = lurek.tilemap.newMapBlock(4, 4) ; b1:setName("corridor") ; local b2 = lurek.tilemap.newMapBlock(4, 4)
    b2:setName("room") ; group:addBlock(b1)
    group:addBlock(b2) ; print("block count = " .. group:getBlockCount())
    group:removeBlock(1) ; print("after remove = " .. group:getBlockCount())
end

--@api-stub: lurek.tilemap.newMapScript
do
    local script = lurek.tilemap.newMapScript() ; print("type = " .. script:type())
    script:addStep({ type = "fill", gid = 1 })
    script:addStep({ type = "scatter", gid = 5, chance = 0.1 })
    script:addStep({ type = "border", gid = 2 })
    print("step count = " .. script:getStepCount())
end

--@api-stub: lurek.tilemap.newMapGen
do
    local group = lurek.tilemap.newMapGroup("caves") ; local block = lurek.tilemap.newMapBlock(4, 4) ; block:setName("open")
    block:setTile(1, 1, 1, 1) ; block:setTile(1, 2, 2, 1) ; group:addBlock(block)
    local script = lurek.tilemap.newMapScript() ; script:addStep({ type = "fill", gid = 1 }) ; group:addScript(script)
    local gen = lurek.tilemap.newMapGen(group, "small", 1) ; print("type = " .. gen:type())
    local result = gen:generate(1, 42, "terrain") ; print("generated map type = " .. result:type())
end

--@api-stub: LMapGen:generate
do
    local group = lurek.tilemap.newMapGroup("caves") ; local block = lurek.tilemap.newMapBlock(4, 4) ; block:setName("open")
    block:setTile(1, 1, 1, 1) ; block:setTile(1, 2, 2, 1) ; group:addBlock(block)
    local script = lurek.tilemap.newMapScript() ; script:addStep({ type = "fill", gid = 1 })
    group:addScript(script) ; local gen = lurek.tilemap.newMapGen(group, "small", 1)
    local result = gen:generate(1, 42, "terrain") ; print("generated map type = " .. result:type())
end

--- TileMap Part 4: getChunkSize, getTileDimensions, getTileHeight, getTileWidth, type, typeOf, iso/hex helpers

--@api-stub: LTileMap:getChunkSize
do
    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local cs = tm:getChunkSize()
    print("chunk_size=" .. cs)
end

--@api-stub: LTileMap:getTileDimensions
do
    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local tw, th = tm:getTileDimensions()
    print("tile_w=" .. tw .. " tile_h=" .. th)
end

--@api-stub: LTileMap:getTileHeight
do
    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local th2 = tm:getTileHeight()
    print("tile_height=" .. th2)
end

--@api-stub: LTileMap:getTileWidth
do
    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local tw2 = tm:getTileWidth()
    print("tile_width=" .. tw2)
end

--@api-stub: LTileMap:type
do
    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    print("type=" .. tm:type())
end

--@api-stub: LTileMap:typeOf
do
    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    print("typeOf=" .. tostring(tm:typeOf("LTileMap")))
end

--@api-stub: lurek.tilemap.fromScreenHex
do
    local hx, hy = lurek.tilemap.fromScreenHex(80, 40, 32)
    print("hex_x=" .. hx .. " hex_y=" .. hy)
end

--@api-stub: lurek.tilemap.fromScreenIso
do
    local ix, iy = lurek.tilemap.fromScreenIso(128, 64, 32, 16)
    print("iso_x=" .. ix .. " iso_y=" .. iy)
end

--@api-stub: lurek.tilemap.isoDirectionName
do
    local name = lurek.tilemap.isoDirectionName(1)
    print("iso_dir=" .. name)
end

--@api-stub: lurek.tilemap.isoRotate
do
    local rotated = lurek.tilemap.isoRotate(1, 2)
    print("iso_rotated=" .. rotated)
end

--- TileMap Part 5: LTileSet full coverage

--@api-stub: LTileSet:getColumns
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    print("columns=" .. ts:getColumns())
end

--@api-stub: LTileSet:getFirstGid
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    print("firstGid=" .. ts:getFirstGid())
end

--@api-stub: LTileSet:getMargin
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    print("margin=" .. ts:getMargin())
end

--@api-stub: LTileSet:getSpacing
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    print("spacing=" .. ts:getSpacing())
end

--@api-stub: LTileSet:getTileCount
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    print("tileCount=" .. ts:getTileCount())
end

--@api-stub: LTileSet:getTileDimensions
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local tw, th = ts:getTileDimensions()
    print("tile_w=" .. tw .. " tile_h=" .. th)
end

--@api-stub: LTileSet:getTileHeight
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    print("tileHeight=" .. ts:getTileHeight())
end

--@api-stub: LTileSet:getTileWidth
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    print("tileWidth=" .. ts:getTileWidth())
end

--@api-stub: LTileSet:type
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    print("type=" .. ts:type())
end

--@api-stub: LTileSet:typeOf
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    print("typeOf=" .. tostring(ts:typeOf("LTileSet")))
end

--@api-stub: LAutoTileSheet:getLayout
do
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    local layout = sheet:getLayout()
    print("layout:", layout)
end

--@api-stub: LAutoTileSheet:getTileCount
do
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    local count = sheet:getTileCount()
    print("tileCount:", count)
end

--@api-stub: LAutoTileSheet:getTileHeight
do
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    local h = sheet:getTileHeight()
    print("tileHeight:", h)
end

--@api-stub: LAutoTileSheet:getTileWidth
do
    local sheet = lurek.tilemap.newAutoTileSheet(32, 32, "minimal16")
    local w = sheet:getTileWidth()
    print("tileWidth:", w)
end

--@api-stub: LAutoTileSheet:type
do
    local sheet = lurek.tilemap.newAutoTileSheet(32, 32, "minimal16")
    local t = sheet:type()
    print("type:", t)
end

--@api-stub: LAutoTileSheet:typeOf
do
    local sheet = lurek.tilemap.newAutoTileSheet(32, 32, "minimal16")
    local ok = sheet:typeOf("LAutoTileSheet")
    print("typeOf:", ok)
end

--@api-stub: LChunkMap:getChunkSize
do
    local cm = lurek.tilemap.newChunkMap(32)
    local sz = cm:getChunkSize()
    print("chunkSize:", sz)
end

--@api-stub: LChunkMap:type
do
    local cm = lurek.tilemap.newChunkMap(32)
    local t = cm:type()
    print("type:", t)
end

--@api-stub: LChunkMap:typeOf
do
    local cm = lurek.tilemap.newChunkMap(32)
    local ok = cm:typeOf("LChunkMap")
    print("typeOf:", ok)
end

--@api-stub: LIsoMap:getHeight
do
    local iso = lurek.tilemap.newIsoMap(20, 15, 64, 32, 16, 4)
    local h = iso:getHeight()
    print("isomap height:", h)
end

--@api-stub: LIsoMap:getLevelHeight
do
    local iso = lurek.tilemap.newIsoMap(20, 15, 64, 32, 16, 4)
    local lh = iso:getLevelHeight()
    print("levelHeight:", lh)
end

--@api-stub: LIsoMap:getPartCount
do
    local iso = lurek.tilemap.newIsoMap(20, 15, 64, 32, 16, 4)
    local pc = iso:getPartCount()
    print("partCount:", pc)
end

--@api-stub: LIsoMap:getTileHeight
do
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local th = iso:getTileHeight()
    print("tileHeight:", th)
end

--@api-stub: LIsoMap:getTileWidth
do
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local tw = iso:getTileWidth()
    print("tileWidth:", tw)
end

--@api-stub: LIsoMap:getWidth
do
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local w = iso:getWidth()
    print("width:", w)
end

--@api-stub: LIsoMap:type
do
    local iso = lurek.tilemap.newIsoMap(8, 8, 32, 16, 8, 2)
    local t = iso:type()
    print("type:", t)
end

--@api-stub: LIsoMap:typeOf
do
    local iso = lurek.tilemap.newIsoMap(8, 8, 32, 16, 8, 2)
    local ok = iso:typeOf("LIsoMap")
    print("typeOf:", ok)
end

--@api-stub: LLargeMapRenderer:getChunkSize
do
    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
    local cs = lmr:getChunkSize()
    print("chunkSize:", cs)
end

--@api-stub: LLargeMapRenderer:getTilesetColumns
do
    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
    local cols = lmr:getTilesetColumns()
    print("tilesetColumns:", cols)
end

--@api-stub: LLargeMapRenderer:type
do
    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
    local t = lmr:type()
    print("type:", t)
end

--@api-stub: LLargeMapRenderer:typeOf
do
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local ok = lmr:typeOf("LLargeMapRenderer")
    print("typeOf:", ok)
end

--@api-stub: LMapBlock:getDimensions
do
    local mb = lurek.tilemap.newMapBlock(10, 8, 2, 4)
    local w, h = mb:getDimensions()
    print("getDimensions:", w, h)
end

-- Duplicate coverage lives in content/examples/mapblock.lua.
do
    local mb = lurek.tilemap.newMapBlock(10, 8, 2, 4)
    local height = mb:getHeight()
    print("getHeight:", height)
end

--@api-stub: LMapBlock:getHeightInSegments
do
    local mb = lurek.tilemap.newMapBlock(12, 8, 3, 4)
    local hs = mb:getHeightInSegments()
    print("heightInSegments:", hs)
end

-- Duplicate coverage lives in content/examples/mapblock.lua.
do
    local mb = lurek.tilemap.newMapBlock(12, 8, 3, 4)
    local lc = mb:getLayerCount()
    print("layerCount:", lc)
end

--@api-stub: LMapBlock:getSegmentSize
do
    local mb = lurek.tilemap.newMapBlock(12, 8, 3, 4)
    local ss = mb:getSegmentSize()
    print("segmentSize:", ss)
end

-- Duplicate coverage lives in content/examples/mapblock.lua.
do
    local mb = lurek.tilemap.newMapBlock(16, 12, 1, 4)
    local w = mb:getWidth()
    print("width:", w)
end

--@api-stub: LMapBlock:getWidthInSegments
do
    local mb = lurek.tilemap.newMapBlock(16, 12, 1, 4)
    local ws = mb:getWidthInSegments()
    print("widthInSegments:", ws)
end

--@api-stub: LMapBlock:type
do
    local mb = lurek.tilemap.newMapBlock(16, 12, 1, 4)
    local t = mb:type()
    print("type:", t)
end

--@api-stub: LMapBlock:typeOf
do
    local mb = lurek.tilemap.newMapBlock(8, 8, 1, 2)
    local ok = mb:typeOf("LMapBlock")
    local notOk = mb:typeOf("LIsoMap")
    print("typeOf LMapBlock:", ok, "typeOf LIsoMap:", notOk)
end

--@api-stub: LMapGen:type
do
    local group = lurek.tilemap.newMapGroup("dungeon") ; local mb = lurek.tilemap.newMapBlock(8, 8, 1, 2)
    group:addBlock(mb)
    local gen = lurek.tilemap.newMapGen(group, "small", 4)
    local t = gen:type()
    print("LMapGen type:", t)
end

--@api-stub: LMapGen:typeOf
do
    local group = lurek.tilemap.newMapGroup("dungeon") ; local mb = lurek.tilemap.newMapBlock(8, 8, 1, 2)
    group:addBlock(mb)
    local gen = lurek.tilemap.newMapGen(group, "small", 4)
    local ok = gen:typeOf("LMapGen")
    print("LMapGen typeOf:", ok)
end

-- Duplicate coverage lives in content/examples/mapblock.lua.
do
    local group = lurek.tilemap.newMapGroup("dungeon")
    local block = lurek.tilemap.newMapBlock(8, 8, 1, 2)
    group:addBlock(block)
    print("block count = " .. tostring(group:getBlockCount()))
end

-- Duplicate coverage lives in content/examples/mapblock.lua.
do
    local group = lurek.tilemap.newMapGroup("forest")
    local script = lurek.tilemap.newMapScript()
    script:addStep({ type = "fill", gid = 1 })
    group:addScript(script)
    print("script count = " .. tostring(group:getScriptCount()))
end

-- Duplicate coverage lives in content/examples/mapblock.lua.
do
    local group = lurek.tilemap.newMapGroup("rooms")
    group:addBlock(lurek.tilemap.newMapBlock(4, 4))
    group:addBlock(lurek.tilemap.newMapBlock(6, 6))
    print("getBlockCount = " .. tostring(group:getBlockCount()))
end

-- Duplicate coverage lives in content/examples/mapblock.lua.
do
    local group = lurek.tilemap.newMapGroup("boss_rooms")
    print("getName = " .. tostring(group:getName()))
end

--@api-stub: LMapGroup:getScriptCount
do
    local group = lurek.tilemap.newMapGroup("forest") ; local script1 = lurek.tilemap.newMapScript()
    local script2 = lurek.tilemap.newMapScript()
    group:addScript(script1)
    group:addScript(script2)
    print("scriptCount:", group:getScriptCount())
end

--@api-stub: LMapGroup:removeBlock
do
    local group = lurek.tilemap.newMapGroup("plains") ; local mb1 = lurek.tilemap.newMapBlock(4, 4, 1, 2)
    local mb2 = lurek.tilemap.newMapBlock(4, 4, 1, 2) ; group:addBlock(mb1)
    group:addBlock(mb2)
    group:removeBlock(1)
    print("removeBlock ok, blockCount:", group:getBlockCount())
end

--@api-stub: LMapGroup:type
do
    local group = lurek.tilemap.newMapGroup("plains") ; local mb1 = lurek.tilemap.newMapBlock(4, 4, 1, 2)
    local mb2 = lurek.tilemap.newMapBlock(4, 4, 1, 2) ; group:addBlock(mb1)
    group:addBlock(mb2)
    local t = group:type()
    print("type:", t)
end

--@api-stub: LMapGroup:typeOf
do
    local group = lurek.tilemap.newMapGroup("cave")
    local ok = group:typeOf("LMapGroup")
    print("LMapGroup typeOf:", ok)
end

-- Duplicate coverage lives in content/examples/mapblock.lua.
do
    local script = lurek.tilemap.newMapScript()
    script:addStep({type = "fill", gid = 1})
    script:addStep({type = "rect", x = 1, y = 1, w = 4, h = 4, gid = 2})
    print("stepCount:", script:getStepCount())
end

--@api-stub: LMapScript:getStepCount.2
do
    local script = lurek.tilemap.newMapScript()
    script:addStep({type = "fill", gid = 1})
    script:addStep({type = "rect", x = 1, y = 1, w = 4, h = 4, gid = 2})
    local cnt = script:getStepCount()
    print("stepCount:", cnt)
end

--@api-stub: LMapScript:type
do
    local script = lurek.tilemap.newMapScript()
    local t = script:type()
    print("LMapScript type:", t)
end

--@api-stub: LMapScript:typeOf
do
    local script = lurek.tilemap.newMapScript()
    local ok = script:typeOf("LMapScript")
    print("LMapScript typeOf:", ok)
end

-- Duplicate coverage lives in content/examples/mapblock.lua.
do
    local script = lurek.tilemap.newMapScript()
    script:addStep({ type = "fill", gid = 1 })
    script:addStep({ type = "rect", x = 1, y = 1, w = 2, h = 2, gid = 2 })
    print("getStepCount = " .. tostring(script:getStepCount()))
end
