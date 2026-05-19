-- content/examples/tilemap.lua
-- Auto-generated from content/examples2/tilemap_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/tilemap.lua

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

-- Customizing internal chunk size.
--@api-stub: lurek.tilemap.newTileMap
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

--@api-stub: LTileMap:getLayerName
--@api-stub: LTileMap:getLayerCount
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

--@api-stub: LTileMap:setTile
--@api-stub: LTileMap:getTile
--@api-stub: LTileMap:clearTile
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

-- Tileset with pixel spacing between tiles.
--@api-stub: lurek.tilemap.newTileSet
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 100, 10, 16, 16, 2, 1)
    print("spacing = " .. ts:getSpacing())
    print("margin = " .. ts:getMargin())
    print("tile count = " .. ts:getTileCount())
end

--@api-stub: LTileSet:isSolid
--@api-stub: LTileSet:setSolid
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

--@api-stub: LTileSet:setAnimation
--@api-stub: LTileSet:getAnimation
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

--@api-stub: LTileMap:addTileSet
--@api-stub: LTileMap:getTileSet
--@api-stub: LTileMap:getTileSetCount
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

--@api-stub: LTileMap:isSolid
--@api-stub: LTileMap:rectOverlapsSolid
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

--@api-stub: LTileMap:setViewport
--@api-stub: LTileMap:getViewport
--@api-stub: LTileMap:render
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

--@api-stub: LTileMap:worldToTile
--@api-stub: LTileMap:tileToWorld
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

--@api-stub: LTileMap:setLayerVisible
--@api-stub: LTileMap:getLayerVisible
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

--@api-stub: LTileMap:setLayerColor
--@api-stub: LTileMap:getLayerColor
-- Layer tinting.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("tinted", 10, 10)
    map:setLayerColor(1, 0.8, 0.5, 0.5, 0.9)
    local r, g, b, a = map:getLayerColor(1)
    print("layer color = " .. r .. ", " .. g .. ", " .. b .. ", " .. a)
end

--@api-stub: LTileMap:setLayerOffset
--@api-stub: LTileMap:getLayerOffset
-- Layer pixel offset.
do
    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("shifted", 10, 10)
    map:setLayerOffset(1, 16, 8)
    local ox, oy = map:getLayerOffset(1)
    print("offset = " .. ox .. ", " .. oy)
end

--@api-stub: LTileMap:setLayerParallax
--@api-stub: LTileMap:getLayerParallax
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

--- Tilemap Module Part 3: hex utilities, iso helpers, coordinate conversion, TMX/LDtk loading

--@api-stub: lurek.tilemap.toScreenHex
-- Converting between hex axial and screen coordinates.
do
    local sx, sy = lurek.tilemap.toScreenHex(2, 3, 32)
    print("hex(2,3) -> screen(" .. sx .. ", " .. sy .. ")")
    local q, r = lurek.tilemap.fromScreenHex(sx, sy, 32)
    print("screen -> hex(" .. q .. ", " .. r .. ")")
end

--@api-stub: lurek.tilemap.hexDistance
-- Computing distance between two hex cells.
do
    local d = lurek.tilemap.hexDistance(0, 0, 3, 2)
    print("hex distance (0,0) to (3,2) = " .. d)
    d = lurek.tilemap.hexDistance(1, 1, 1, 1)
    print("same cell distance = " .. d)
    d = lurek.tilemap.hexDistance(-2, 1, 2, -1)
    print("across-origin distance = " .. d)
end

--@api-stub: lurek.tilemap.hexNeighbors
-- Getting the six neighbors of a hex cell.
do
    local neighbors = lurek.tilemap.hexNeighbors(3, 4)
    print("neighbors of (3,4): " .. #neighbors .. " cells")
    for i, n in ipairs(neighbors) do
        print("  " .. i .. ": q=" .. n.q .. " r=" .. n.r)
    end
end

--@api-stub: lurek.tilemap.hexRing
-- Cells forming a ring at radius.
do
    local ring = lurek.tilemap.hexRing(0, 0, 2)
    print("ring at radius 2: " .. #ring .. " cells")
    for _, cell in ipairs(ring) do
        print("  q=" .. cell.q .. " r=" .. cell.r)
    end
end

--@api-stub: lurek.tilemap.hexArea
-- All cells within a filled hex area.
do
    local area = lurek.tilemap.hexArea(0, 0, 1)
    print("area radius 1: " .. #area .. " cells")
    local bigArea = lurek.tilemap.hexArea(5, 5, 3)
    print("area radius 3 around (5,5): " .. #bigArea .. " cells")
end

--@api-stub: lurek.tilemap.hexSpiral
-- Spiral traversal of hex cells.
do
    local spiral = lurek.tilemap.hexSpiral(0, 0, 2)
    print("spiral radius 2: " .. #spiral .. " cells")
    print("center = q=" .. spiral[1].q .. " r=" .. spiral[1].r)
end

--@api-stub: lurek.tilemap.hexLine
-- Line of cells between two hex positions.
do
    local line = lurek.tilemap.hexLine(0, 0, 4, 2)
    print("line (0,0) to (4,2): " .. #line .. " cells")
    for i, cell in ipairs(line) do
        print("  step " .. i .. ": q=" .. cell.q .. " r=" .. cell.r)
    end
end

--@api-stub: lurek.tilemap.hexRound
-- Rounding fractional hex coordinates.
do
    local q, r = lurek.tilemap.hexRound(2.3, 1.7)
    print("round(2.3, 1.7) = " .. q .. ", " .. r)
    q, r = lurek.tilemap.hexRound(-0.4, 0.6)
    print("round(-0.4, 0.6) = " .. q .. ", " .. r)
end

--@api-stub: lurek.tilemap.hexRotate
-- Rotating a hex cell around a pivot.
do
    local q, r = lurek.tilemap.hexRotate(2, 0, 0, 0, 1)
    print("(2,0) rotated 60deg CW around origin = " .. q .. ", " .. r)
    q, r = lurek.tilemap.hexRotate(2, 0, 0, 0, 3)
    print("(2,0) rotated 180deg = " .. q .. ", " .. r)
end

--@api-stub: lurek.tilemap.hexReflect
-- Reflecting a hex cell across an axis.
do
    local q, r = lurek.tilemap.hexReflect(3, 1, 0, 0, "q")
    print("reflect (3,1) across q axis = " .. q .. ", " .. r)
    q, r = lurek.tilemap.hexReflect(2, -1, 0, 0, "r")
    print("reflect (2,-1) across r axis = " .. q .. ", " .. r)
end

--@api-stub: lurek.tilemap.toScreenIso
-- Isometric coordinate conversion.
do
    local sx, sy = lurek.tilemap.toScreenIso(3, 5, 64, 32)
    print("tile(3,5) -> screen(" .. sx .. ", " .. sy .. ")")
    local tx, ty = lurek.tilemap.fromScreenIso(sx, sy, 64, 32)
    print("screen -> tile(" .. tx .. ", " .. ty .. ")")
end

--@api-stub: lurek.tilemap.isoDirectionFromAngle
-- Isometric direction utilities.
do
    local dir = lurek.tilemap.isoDirectionFromAngle(45)
    print("45 degrees -> direction " .. dir)
    local name = lurek.tilemap.isoDirectionName(dir)
    print("direction name = " .. name)
    local rotated = lurek.tilemap.isoRotate(dir, 1)
    print("rotated +90 = " .. lurek.tilemap.isoDirectionName(rotated))
    rotated = lurek.tilemap.isoRotate(dir, 2)
    print("rotated +180 = " .. lurek.tilemap.isoDirectionName(rotated))
end

--@api-stub: lurek.tilemap.loadTMX
-- Parsing a TMX (Tiled) map file.
do
    local tmxData = [[<?xml version="1.0" encoding="UTF-8"?>
<map version="1.10" orientation="orthogonal" width="4" height="4" tilewidth="32" tileheight="32">
 <layer name="ground" width="4" height="4">
  <data encoding="csv">1,1,1,1,1,2,2,1,1,2,2,1,1,1,1,1</data>
 </layer>
</map>]]
    local result = lurek.tilemap.loadTMX(tmxData)
    print("TMX width = " .. result.width)
    print("TMX height = " .. result.height)
    print("TMX tile size = " .. result.tileWidth .. "x" .. result.tileHeight)
    print("TMX orientation = " .. result.orientation)
    print("TMX layers = " .. #result.layers)
end

--@api-stub: lurek.tilemap.fromLDtk
-- Loading a map from LDtk JSON.
do
    local ldtkJson = '{"levels":[{"identifier":"Level_0","layerInstances":[]}]}'
    ---@type LTileMap
    local map = lurek.tilemap.fromLDtk(ldtkJson)
    print("LDtk map type = " .. map:type())
    -- With specific level name:
    ---@type LTileMap
    local named = lurek.tilemap.fromLDtk(ldtkJson, "Level_0")
    print("named level loaded")
end

-- Tilemap layer type constants.
--@api-stub: lurek.tilemap.FLOOR
--@api-stub: lurek.tilemap.NORTH_WALL
--@api-stub: lurek.tilemap.WEST_WALL
--@api-stub: lurek.tilemap.OBJECT
do
    print("FLOOR = " .. lurek.tilemap.FLOOR)
    print("NORTH_WALL = " .. lurek.tilemap.NORTH_WALL)
    print("WEST_WALL = " .. lurek.tilemap.WEST_WALL)
    print("OBJECT = " .. lurek.tilemap.OBJECT)
end

--- Tilemap Module Part 4: ChunkMap, IsoMap, LargeMapRenderer, MapBlock, MapGroup, MapScript, MapGen

--@api-stub: lurek.tilemap.newChunkMap
-- Creating an infinite chunk-based tilemap.
do
    ---@type LChunkMap
    local cm = lurek.tilemap.newChunkMap(16)
    print("type = " .. cm:type())
    print("chunk size = " .. cm:getChunkSize())
end

--@api-stub: LChunkMap:setTile
--@api-stub: LChunkMap:getTile
--@api-stub: LChunkMap:clearTile
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

--@api-stub: LChunkMap:loadChunk
--@api-stub: LChunkMap:unloadChunk
--@api-stub: LChunkMap:getLoadedChunks
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

--@api-stub: LIsoMap:addLevel
--@api-stub: LIsoMap:getLevelCount
--@api-stub: LIsoMap:setTilePart
--@api-stub: LIsoMap:getTilePart
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

--@api-stub: LIsoMap:fillLevel
--@api-stub: LIsoMap:isLevelVisible
--@api-stub: LIsoMap:setLevelVisible
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

--@api-stub: LIsoMap:screenToTile
--@api-stub: LIsoMap:tileToScreen
--@api-stub: LIsoMap:setOrigin
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

--@api-stub: LIsoMap:setPartOrder
--@api-stub: LIsoMap:getPartOrder
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

--@api-stub: LLargeMapRenderer:setMapData
--@api-stub: LLargeMapRenderer:getMapSize
--@api-stub: LLargeMapRenderer:getTile
--@api-stub: LLargeMapRenderer:setTile
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

--@api-stub: LLargeMapRenderer:setCamera
--@api-stub: LLargeMapRenderer:setViewport
--@api-stub: LLargeMapRenderer:getVisibleChunks
--@api-stub: LLargeMapRenderer:getTotalChunks
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

--@api-stub: LLargeMapRenderer:setLodEnabled
--@api-stub: LLargeMapRenderer:isLodEnabled
--@api-stub: LLargeMapRenderer:setLodThresholds
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

--@api-stub: LLargeMapRenderer:invalidateAll
--@api-stub: LLargeMapRenderer:invalidateChunk
--@api-stub: LLargeMapRenderer:setChunkSize
--@api-stub: LLargeMapRenderer:setTilesetColumns
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

--@api-stub: LMapBlock:setTile
--@api-stub: LMapBlock:getTile
--@api-stub: LMapBlock:setName
--@api-stub: LMapBlock:getName
--@api-stub: LMapBlock:setWeight
--@api-stub: LMapBlock:getWeight
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

--@api-stub: LMapBlock:setSide
--@api-stub: LMapBlock:getSide
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

--@api-stub: lurek.tilemap.newMapGroup
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

--@api-stub: lurek.tilemap.newMapScript
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

--@api-stub: lurek.tilemap.newMapGen
--@api-stub: LMapGen:generate
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

-- Map generation using explicit width and height.
--@api-stub: lurek.tilemap.newMapGroup
--@api-stub: lurek.tilemap.newMapBlock
--@api-stub: lurek.tilemap.newMapGen
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

--- TileMap Part 4: getChunkSize, getTileDimensions, getTileHeight, getTileWidth, type, typeOf, iso/hex helpers

--@api-stub: LTileMap:getChunkSize
--@api-stub: LTileMap:getTileDimensions
--@api-stub: LTileMap:getTileHeight
--@api-stub: LTileMap:getTileWidth
--@api-stub: LTileMap:type
--@api-stub: LTileMap:typeOf
-- TileMap introspection: tile dimensions, chunk size, and type queries.
do
    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local cs = tm:getChunkSize()
    print("chunk_size=" .. cs)
    local tw, th = tm:getTileDimensions()
    print("tile_w=" .. tw .. " tile_h=" .. th)
    local tw2 = tm:getTileWidth()
    local th2 = tm:getTileHeight()
    print("tw2=" .. tw2 .. " th2=" .. th2)
    print("type=" .. tm:type())
    print("typeOf=" .. tostring(tm:typeOf("LTileMap")))
end

--@api-stub: lurek.tilemap.fromScreenHex
--@api-stub: lurek.tilemap.fromScreenIso
--@api-stub: lurek.tilemap.isoDirectionName
--@api-stub: lurek.tilemap.isoRotate
-- Hex and isometric coordinate helpers.
do
    local hx, hy = lurek.tilemap.fromScreenHex(80, 40, 32)
    print("hex_x=" .. hx .. " hex_y=" .. hy)
    local ix, iy = lurek.tilemap.fromScreenIso(128, 64, 32, 16)
    print("iso_x=" .. ix .. " iso_y=" .. iy)
    local name = lurek.tilemap.isoDirectionName(1)
    print("iso_dir=" .. name)
    local rotated = lurek.tilemap.isoRotate(1, 2)
    print("iso_rotated=" .. rotated)
end

--- TileMap Part 5: LTileSet full coverage

--@api-stub: LTileSet:getColumns
--@api-stub: LTileSet:getFirstGid
--@api-stub: LTileSet:getMargin
--@api-stub: LTileSet:getSpacing
--@api-stub: LTileSet:getTileCount
--@api-stub: LTileSet:getTileDimensions
--@api-stub: LTileSet:getTileHeight
--@api-stub: LTileSet:getTileWidth
--@api-stub: LTileSet:type
--@api-stub: LTileSet:typeOf
-- LTileSet introspection: dimensions, gid, columns, spacing, type.
do
    -- firstGid, tileCount, columns, tileWidth, tileHeight, spacing, margin
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    print("columns=" .. ts:getColumns())
    print("firstGid=" .. ts:getFirstGid())
    print("margin=" .. ts:getMargin())
    print("spacing=" .. ts:getSpacing())
    print("tileCount=" .. ts:getTileCount())
    local tw, th = ts:getTileDimensions()
    print("tile_w=" .. tw .. " tile_h=" .. th)
    print("tileWidth=" .. ts:getTileWidth())
    print("tileHeight=" .. ts:getTileHeight())
    print("type=" .. ts:type())
    print("typeOf=" .. tostring(ts:typeOf("LTileSet")))
end

--@api-stub: LAutoTileSheet:getLayout
--@api-stub: LAutoTileSheet:getTileCount
--@api-stub: LAutoTileSheet:getTileHeight
-- LAutoTileSheet dimension and layout queries.
do
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    local layout = sheet:getLayout()
    local count = sheet:getTileCount()
    local h = sheet:getTileHeight()
    print("layout:", layout, "tileCount:", count, "tileHeight:", h)
end

--@api-stub: LAutoTileSheet:getTileWidth
--@api-stub: LAutoTileSheet:type
--@api-stub: LAutoTileSheet:typeOf
-- LAutoTileSheet tile width and type identity.
do
    local sheet = lurek.tilemap.newAutoTileSheet(32, 32, "minimal16")
    local w = sheet:getTileWidth()
    local t = sheet:type()
    local ok = sheet:typeOf("LAutoTileSheet")
    print("tileWidth:", w, "type:", t, "typeOf:", ok)
end

--@api-stub: LChunkMap:getChunkSize
--@api-stub: LChunkMap:type
--@api-stub: LChunkMap:typeOf
-- LChunkMap size and type identity.
do
    local cm = lurek.tilemap.newChunkMap(32)
    local sz = cm:getChunkSize()
    local t = cm:type()
    local ok = cm:typeOf("LChunkMap")
    print("chunkSize:", sz, "type:", t, "typeOf:", ok)
end

--@api-stub: LIsoMap:getHeight
--@api-stub: LIsoMap:getLevelHeight
--@api-stub: LIsoMap:getPartCount
-- LIsoMap dimension and level geometry queries.
do
    local iso = lurek.tilemap.newIsoMap(20, 15, 64, 32, 16, 4)
    local h = iso:getHeight()
    local lh = iso:getLevelHeight()
    local pc = iso:getPartCount()
    print("isomap height:", h, "levelHeight:", lh, "partCount:", pc)
end

--@api-stub: LIsoMap:getTileHeight
--@api-stub: LIsoMap:getTileWidth
--@api-stub: LIsoMap:getWidth
-- LIsoMap tile size and width.
do
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local tw = iso:getTileWidth()
    local th = iso:getTileHeight()
    local w = iso:getWidth()
    print("tileWidth:", tw, "tileHeight:", th, "width:", w)
end

--@api-stub: LIsoMap:type
--@api-stub: LIsoMap:typeOf
-- LIsoMap type identity.
do
    local iso = lurek.tilemap.newIsoMap(8, 8, 32, 16, 8, 2)
    local t = iso:type()
    local ok = iso:typeOf("LIsoMap")
    local notOk = iso:typeOf("LTileMap")
    print("type:", t, "typeOf:", ok, "typeOf LTileMap:", notOk)
end

--@api-stub: LLargeMapRenderer:getChunkSize
--@api-stub: LLargeMapRenderer:getTilesetColumns
--@api-stub: LLargeMapRenderer:type
-- LLargeMapRenderer chunk size, tileset columns, and type.
do
    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
    local cs = lmr:getChunkSize()
    local cols = lmr:getTilesetColumns()
    local t = lmr:type()
    print("chunkSize:", cs, "tilesetColumns:", cols, "type:", t)
end

--@api-stub: LLargeMapRenderer:typeOf
--@api-stub: LMapBlock:getDimensions
--@api-stub: LMapBlock:getHeight
-- LLargeMapRenderer typeOf and LMapBlock dimension queries.
do
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local ok = lmr:typeOf("LLargeMapRenderer")
    local mb = lurek.tilemap.newMapBlock(10, 8, 2, 4)
    local w, h = mb:getDimensions()
    local height = mb:getHeight()
    print("typeOf:", ok, "getDimensions:", w, h, "getHeight:", height)
end

--@api-stub: LMapBlock:getHeightInSegments
--@api-stub: LMapBlock:getLayerCount
--@api-stub: LMapBlock:getSegmentSize
-- LMapBlock segment and layer metadata.
do
    local mb = lurek.tilemap.newMapBlock(12, 8, 3, 4)
    local hs = mb:getHeightInSegments()
    local lc = mb:getLayerCount()
    local ss = mb:getSegmentSize()
    print("heightInSegments:", hs, "layerCount:", lc, "segmentSize:", ss)
end

--@api-stub: LMapBlock:getWidth
--@api-stub: LMapBlock:getWidthInSegments
--@api-stub: LMapBlock:type
-- LMapBlock width and type.
do
    local mb = lurek.tilemap.newMapBlock(16, 12, 1, 4)
    local w = mb:getWidth()
    local ws = mb:getWidthInSegments()
    local t = mb:type()
    print("width:", w, "widthInSegments:", ws, "type:", t)
end

--@api-stub: LMapBlock:typeOf
-- LMapBlock typeOf.
do
    local mb = lurek.tilemap.newMapBlock(8, 8, 1, 2)
    local ok = mb:typeOf("LMapBlock")
    local notOk = mb:typeOf("LIsoMap")
    print("typeOf LMapBlock:", ok, "typeOf LIsoMap:", notOk)
end

--@api-stub: LMapGen:type
--@api-stub: LMapGen:typeOf
--@api-stub: LMapGroup:addBlock
-- LMapGen type checks and LMapGroup addBlock.
do
    local group = lurek.tilemap.newMapGroup("dungeon")
    local mb = lurek.tilemap.newMapBlock(8, 8, 1, 2)
    group:addBlock(mb)
    local gen = lurek.tilemap.newMapGen(group, "small", 4)
    local t = gen:type()
    local ok = gen:typeOf("LMapGen")
    print("addBlock ok, LMapGen type:", t, "typeOf:", ok)
end

--@api-stub: LMapGroup:addScript
--@api-stub: LMapGroup:getBlockCount
--@api-stub: LMapGroup:getName
-- LMapGroup script and block queries.
do
    local group = lurek.tilemap.newMapGroup("forest")
    local mb = lurek.tilemap.newMapBlock(6, 6, 1, 2)
    group:addBlock(mb)
    local script = lurek.tilemap.newMapScript()
    group:addScript(script)
    local bc = group:getBlockCount()
    local sc = group:getScriptCount()
    local name = group:getName()
    print("blockCount:", bc, "scriptCount:", sc, "name:", name)
end

--@api-stub: LMapGroup:getScriptCount
--@api-stub: LMapGroup:removeBlock
--@api-stub: LMapGroup:type
-- LMapGroup remove block and type.
do
    local group = lurek.tilemap.newMapGroup("plains")
    local mb1 = lurek.tilemap.newMapBlock(4, 4, 1, 2)
    local mb2 = lurek.tilemap.newMapBlock(4, 4, 1, 2)
    group:addBlock(mb1)
    group:addBlock(mb2)
    group:removeBlock(1)
    local t = group:type()
    print("removeBlock ok, blockCount:", group:getBlockCount(), "type:", t)
end

--@api-stub: LMapGroup:typeOf
--@api-stub: LMapScript:addStep
--@api-stub: LMapScript:getStepCount
-- LMapGroup typeOf and LMapScript step management.
do
    local group = lurek.tilemap.newMapGroup("cave")
    local ok = group:typeOf("LMapGroup")
    local script = lurek.tilemap.newMapScript()
    script:addStep({type = "fill", gid = 1})
    script:addStep({type = "rect", x = 1, y = 1, w = 4, h = 4, gid = 2})
    local cnt = script:getStepCount()
    print("LMapGroup typeOf:", ok, "stepCount:", cnt)
end

--@api-stub: LMapScript:type
--@api-stub: LMapScript:typeOf
-- LMapScript type identity.
do
    local script = lurek.tilemap.newMapScript()
    local t = script:type()
    local ok = script:typeOf("LMapScript")
    local notOk = script:typeOf("LMapBlock")
    print("LMapScript type:", t, "typeOf:", ok, "typeOf LMapBlock:", notOk)
end

print("content/examples/tilemap.lua")
