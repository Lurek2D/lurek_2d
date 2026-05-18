--- Tilemap Module Part 1: map creation, layers, tiles, tilesets, solids, viewport

--@api-stub: lurek.tilemap.newTileMap
-- Creating an empty tilemap.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    print("type = " .. map:type())
    print("is LTileMap = " .. tostring(map:typeOf("LTileMap")))
    local tw, th = map:getTileDimensions()
    print("tile size = " .. tw .. "x" .. th)
end

--@api-stub: lurek.tilemap.newTileMap with chunk size
-- Customizing internal chunk size.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(16, 16, 32)
    print("tile width = " .. map:getTileWidth())
    print("tile height = " .. map:getTileHeight())
    print("chunk size = " .. map:getChunkSize())
end

--@api-stub: LTileMap:addLayer
-- Adding named tile layers.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    local ground = map:addLayer("ground", 50, 50)
    print("ground layer idx = " .. ground)
    local objects = map:addLayer("objects", 50, 50)
    print("objects layer idx = " .. objects)
    local overlay = map:addLayer("overlay", 50, 50)
    print("overlay layer idx = " .. overlay)
    print("layer count = " .. map:getLayerCount())
end

--@api-stub: LTileMap:getLayerName / getLayerCount
-- Querying layer metadata.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("terrain", 40, 30)
    map:addLayer("decoration", 40, 30)
    map:addLayer("collision", 40, 30)
    for i = 1, map:getLayerCount() do
        print("layer " .. i .. " = " .. map:getLayerName(i))
    end
end

--@api-stub: LTileMap:setTile / getTile / clearTile
-- Placing and reading tiles.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)
    map:setTile(layer, 3, 4, 5)
    map:setTile(layer, 5, 5, 12)
    map:setTile(layer, 0, 0, 1)
    local gid = map:getTile(layer, 3, 4)
    print("tile at 3,4 = " .. gid)
    map:clearTile(layer, 3, 4)
    gid = map:getTile(layer, 3, 4)
    print("after clear = " .. gid)
end

--@api-stub: LTileMap:fill
-- Filling an entire layer with one tile ID.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("ground", 20, 20)
    map:fill(layer, 3)
    print("fill complete, sample = " .. map:getTile(layer, 10, 10))
    print("corner = " .. map:getTile(layer, 0, 0))
end

--@api-stub: LTileMap:findTilesByGid
-- Searching for all positions of a specific tile.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)
    map:setTile(layer, 2, 3, 7)
    map:setTile(layer, 5, 1, 7)
    map:setTile(layer, 8, 9, 7)
    map:setTile(layer, 4, 4, 2)
    local positions = map:findTilesByGid(layer, 7)
    print("found gid=7 at " .. #positions .. " positions:")
    for _, pos in ipairs(positions) do
        print("  x=" .. pos.x .. " y=" .. pos.y)
    end
end

--@api-stub: lurek.tilemap.newTileSet
-- Creating a tileset from atlas parameters.
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 64, 8, 32, 32)
    print("type = " .. ts:type())
    print("is LTileSet = " .. tostring(ts:typeOf("LTileSet")))
    print("first gid = " .. ts:getFirstGid())
    print("tile count = " .. ts:getTileCount())
    print("columns = " .. ts:getColumns())
    local tw, th = ts:getTileDimensions()
    print("tile dims = " .. tw .. "x" .. th)
end

--@api-stub: lurek.tilemap.newTileSet with spacing and margin
-- Tileset with pixel spacing between tiles.
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 100, 10, 16, 16, 2, 1)
    print("spacing = " .. ts:getSpacing())
    print("margin = " .. ts:getMargin())
    print("tile count = " .. ts:getTileCount())
end

--@api-stub: LTileSet:isSolid / setSolid
-- Marking tiles as solid for collision.
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 32, 32)
    ts:setSolid(1, true)
    ts:setSolid(5, true)
    ts:setSolid(10, true)
    print("tile 1 solid = " .. tostring(ts:isSolid(1)))
    print("tile 2 solid = " .. tostring(ts:isSolid(2)))
    print("tile 5 solid = " .. tostring(ts:isSolid(5)))
    ts:setSolid(5, false)
    print("tile 5 after clear = " .. tostring(ts:isSolid(5)))
end

--@api-stub: LTileSet:getQuad
-- Getting source rectangle for atlas rendering.
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 32, 32)
    local q1 = ts:getQuad(1)
    print("tile 1: x=" .. q1.x .. " y=" .. q1.y .. " w=" .. q1.width .. " h=" .. q1.height)
    local q5 = ts:getQuad(5)
    print("tile 5: x=" .. q5.x .. " y=" .. q5.y .. " w=" .. q5.width .. " h=" .. q5.height)
end

--@api-stub: LTileSet:setAnimation / getAnimation
-- Animated tiles.
do
    ---@type LTileSet
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

--@api-stub: LTileMap:addTileSet / getTileSet / getTileSetCount
-- Attaching tilesets to a map.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    ---@type LTileSet
    local terrain = lurek.tilemap.newTileSet(1, 64, 8, 32, 32)
    ---@type LTileSet
    local objects = lurek.tilemap.newTileSet(65, 32, 8, 32, 32)
    map:addTileSet(terrain)
    map:addTileSet(objects)
    print("tileset count = " .. map:getTileSetCount())
    ---@type LTileSet
    local ts1 = map:getTileSet(1)
    print("tileset 1 first gid = " .. ts1:getFirstGid())
end

--@api-stub: LTileMap:isSolid / rectOverlapsSolid
-- Collision queries.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 32, 32)
    ts:setSolid(1, true)
    map:addTileSet(ts)
    local layer = map:addLayer("collision", 10, 10)
    map:setTile(layer, 3, 3, 1)
    map:setTile(layer, 4, 3, 1)
    print("3,3 solid = " .. tostring(map:isSolid(layer, 3, 3)))
    print("5,5 solid = " .. tostring(map:isSolid(layer, 5, 5)))
    local overlap = map:rectOverlapsSolid(layer, 80, 80, 40, 40)
    print("rect overlaps solid = " .. tostring(overlap))
end

--@api-stub: LTileMap:setViewport / getViewport / render
-- Viewport and rendering.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("ground", 100, 100)
    map:setViewport(0, 0, 800, 600)
    local vx, vy, vw, vh = map:getViewport()
    print("viewport = " .. vx .. "," .. vy .. " " .. vw .. "x" .. vh)
    map:setViewport(64, 32, 800, 600)
    vx, vy, vw, vh = map:getViewport()
    print("scrolled viewport = " .. vx .. "," .. vy)
    map:render()
    print("rendered at origin")
    map:render(10, 10)
    print("rendered with offset")
end

--@api-stub: LTileMap:worldToTile / tileToWorld
-- Coordinate conversion.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 20, 20)
    local tx, ty = map:worldToTile(100, 80)
    print("world(100,80) -> tile(" .. tx .. "," .. ty .. ")")
    local wx, wy = map:tileToWorld(5, 3)
    print("tile(5,3) -> world(" .. wx .. "," .. wy .. ")")
    local tx2, ty2 = map:worldToTile(0, 0)
    print("world(0,0) -> tile(" .. tx2 .. "," .. ty2 .. ")")
end

--@api-stub: LTileMap:setLayerVisible / getLayerVisible
-- Layer visibility toggle.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("background", 20, 20)
    map:addLayer("foreground", 20, 20)
    print("layer 1 visible = " .. tostring(map:getLayerVisible(1)))
    map:setLayerVisible(1, false)
    print("after hide = " .. tostring(map:getLayerVisible(1)))
    map:setLayerVisible(1, true)
end

--@api-stub: LTileMap:setLayerColor / getLayerColor
-- Layer tinting.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("tinted", 10, 10)
    map:setLayerColor(1, 0.8, 0.5, 0.5, 0.9)
    local r, g, b, a = map:getLayerColor(1)
    print("layer color = " .. r .. ", " .. g .. ", " .. b .. ", " .. a)
end

--@api-stub: LTileMap:setLayerOffset / getLayerOffset
-- Layer pixel offset.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("shifted", 10, 10)
    map:setLayerOffset(1, 16, 8)
    local ox, oy = map:getLayerOffset(1)
    print("offset = " .. ox .. ", " .. oy)
end

--@api-stub: LTileMap:setLayerParallax / getLayerParallax
-- Layer parallax scrolling factors.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("background", 40, 30)
    map:addLayer("midground", 40, 30)
    map:setLayerParallax(1, 0.5, 0.5)
    map:setLayerParallax(2, 0.8, 0.8)
    local px, py = map:getLayerParallax(1)
    print("bg parallax = " .. px .. ", " .. py)
    px, py = map:getLayerParallax(2)
    print("mid parallax = " .. px .. ", " .. py)
end

print("tilemap_00.lua")
