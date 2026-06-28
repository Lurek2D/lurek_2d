-- content/examples/tilemap.lua
-- Auto-generated from content/examples2/tilemap_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/tilemap.lua




--- Tilemap Module Part 1: map creation, layers, tiles, tilesets, solids, viewport


--@api: lurek.tilemap.newTileMap
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    local ground = map:addLayer("ground", 50, 50)
    local decor = map:addLayer("decor", 50, 50)
    local count = map:getLayerCount()
    example_print_log("ground layer idx = " .. ground)
    example_print_log("decor layer idx = " .. decor)
    example_print_log("layer count = " .. count)
end

--@api: LTileMap:tryAddLayer
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32, 8, { maxLayers = 1 })
    local first, first_err = map:tryAddLayer("ground", 2, 2)
    local second, second_err = map:tryAddLayer("props", 2, 2)
    example_print_log("tryAddLayer first = " .. tostring(first) .. " err = " .. tostring(first_err))
    example_print_log("tryAddLayer second = " .. tostring(second) .. " err = " .. tostring(second_err))
end

--@api: LTileMap:getLayerName
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)
    map:setTile(layer, 3, 4, 5)
    local gid = map:getTile(layer, 3, 4)
    example_print_log("tile at 3,4 = " .. gid)
end

--@api: LTileMap:trySetTile
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)
    local ok, err = map:trySetTile(layer, 11, 1, 7)
    example_print_log("trySetTile ok = " .. tostring(ok))
    example_print_log("trySetTile err = " .. tostring(err))
end

--@api: LTileMap:getTile
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)
    map:setTile(layer, 3, 4, 5)
    local gid = map:getTile(layer, 3, 4)
    example_print_log("tile at 3,4 = " .. gid)
end

--@api: LTileMap:tryGetTile
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 10, 10)
    local gid, err = map:tryGetTile(2, 1, 1)
    example_print_log("tryGetTile gid = " .. tostring(gid))
    example_print_log("tryGetTile err = " .. tostring(err))
end

--@api: LTileMap:getDiagnostics
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)
    map:trySetTile(layer, 11, 1, 7)
    map:tryGetTile(2, 1, 1)
    local diagnostics = map:getDiagnostics()
    example_print_log("invalid layer = " .. tostring(diagnostics.invalidLayer))
    example_print_log("invalid coord = " .. tostring(diagnostics.invalidCoord))
end

--@api: LTileMap:clearTile
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)
    map:setTile(layer, 3, 4, 5)
    map:clearTile(layer, 3, 4)
    local gid = map:getTile(layer, 3, 4)
    example_print_log("after clear = " .. gid)
end

--@api: LTileMap:fill
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("ground", 20, 20)
    map:fill(layer, 3)
    example_print_log("fill complete, sample = " .. map:getTile(layer, 10, 10))
    example_print_log("corner = " .. map:getTile(layer, 1, 1))
end

--@api: LTileMap:findTilesByGid
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 64, 8, 32, 32)
    example_print_log("type = " .. ts:type())
    example_print_log("first gid = " .. ts:getFirstGid())
    example_print_log("tile count = " .. ts:getTileCount())
    example_print_log("columns = " .. ts:getColumns())
end

--@api: lurek.tilemap.newTileSet.2
do
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

    local ts = lurek.tilemap.newTileSet(1, 32, 8, 32, 32)
    ts:setProfile(1, "stone_floor")
    ts:setPhysicsShape(1, "rect")
    example_print_log("profile=" .. tostring(ts:getProfile(1)))
    example_print_log("shape=" .. tostring(ts:getPhysicsShape(1)))
end

--@api: lurek.tilemap.newTileSet.3
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ts = lurek.tilemap.newTileSet(1, 16, 4, 32, 32)
    local q1 = ts:getQuad(1)
    example_print_log("tile 1: x=" .. q1.x .. " y=" .. q1.y .. " w=" .. q1.width .. " h=" .. q1.height)
    local q5 = ts:getQuad(5)
    example_print_log("tile 5: x=" .. q5.x .. " y=" .. q5.y .. " w=" .. q5.width .. " h=" .. q5.height)
end

--@api: lurek.tilemap.newTileSet.4
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: lurek.tilemap.newTileSet.5
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    local terrain = lurek.tilemap.newTileSet(1, 64, 8, 32, 32)
    local objects = lurek.tilemap.newTileSet(65, 32, 8, 32, 32)

    map:addTileSet(terrain)
    map:addTileSet(objects)
    example_print_log("tileset count = " .. map:getTileSetCount())
end

--@api: LTileMap:getTileSet
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    local terrain = lurek.tilemap.newTileSet(1, 64, 8, 32, 32)
    local objects = lurek.tilemap.newTileSet(65, 32, 8, 32, 32)

    map:addTileSet(terrain)
    map:addTileSet(objects)
    example_print_log("tileset count = " .. map:getTileSetCount())
end

--@api: LTileMap:setViewport
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("ground", 100, 100)
    map:setViewport(0, 0, 800, 600)
    local vx, vy, vw, vh = map:getViewport()
    example_print_log("viewport = " .. vx .. "," .. vy .. " " .. vw .. "x" .. vh)
end

--@api: LTileMap:getViewport
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("ground", 100, 100)
    map:setViewport(0, 0, 800, 600)
    local vx, vy, vw, vh = map:getViewport()
    example_print_log("viewport = " .. vx .. "," .. vy .. " " .. vw .. "x" .. vh)
end

--@api: LTileMap:render
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("ground", 100, 100)
    map:setViewport(0, 0, 800, 600)

    map:render()
    example_print_log("rendered at origin")
    map:render(10, 10)
    example_print_log("rendered with offset")
end

--@api: LTileMap:setShader
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end

    local code = [[
@fragment
fn fs_main(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(mix(color.rgb, vec3<f32>(uv.x, 0.45, 0.2), 0.25), color.a);
}
]]
    local shader = lurek.render.newShader(code, { target = "tilemap" })
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("ground", 4, 4)
    map:setTile(1, 1, 1, 1)
    map:setShader(shader)
    map:render()
    example_print_log("tilemap shader target = " .. map:getShader():getTarget())
end

--@api: LTileMap:getShader
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end

    local shader = lurek.render.newShader([[
@fragment
fn fs_main(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb * vec3<f32>(1.0, 0.9, 0.75), color.a);
}
]], { target = "tilemap" })
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("ground", 2, 2)
    map:setShader(shader)
    local bound = map:getShader()
    example_print_log("bound tilemap shader id = " .. tostring(bound:getId()))
end

--@api: LTileMap:setLayerShader
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end

    local shader = lurek.render.newShader([[
@fragment
fn fs_main(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rg, max(color.b, uv.x), color.a);
}
]], { target = "tilemap" })
    local map = lurek.tilemap.newTileMap(16, 16)
    map:addLayer("base", 3, 3)
    map:addLayer("water", 3, 3)
    map:setLayerShader(2, shader)
    map:render()
    example_print_log("layer shader target = " .. map:getLayerShader(2):getTarget())
end

--@api: LTileMap:getLayerShader
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end

    local shader = lurek.render.newShader([[
@fragment
fn fs_main(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb * 1.1, color.a);
}
]], { target = "tilemap" })
    local map = lurek.tilemap.newTileMap(16, 16)
    map:addLayer("highlight", 2, 2)
    map:setLayerShader(1, shader)
    local layer_shader = map:getLayerShader(1)
    example_print_log("layer shader id = " .. tostring(layer_shader:getId()))
end

--@api: LTileMap:worldToTile
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 20, 20)
    local tx, ty = map:worldToTile(100, 80)
    local wx, wy = map:tileToWorld(tx, ty)
    example_print_log("world(100,80) -> tile(" .. tx .. "," .. ty .. ")")
    example_print_log("tile(" .. tx .. "," .. ty .. ") -> world(" .. wx .. "," .. wy .. ")")
end

--@api: LTileMap:tryWorldToTile
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 20, 20)
    local tx, ty = map:tryWorldToTile(64, 32)
    local bad_tx, bad_ty = map:tryWorldToTile(-1, 0)
    example_print_log("tryWorldToTile valid = " .. tostring(tx) .. "," .. tostring(ty))
    example_print_log("tryWorldToTile invalid = " .. tostring(bad_tx) .. "," .. tostring(bad_ty))
end

--@api: LTileMap:tileToWorld
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("tinted", 10, 10)
    map:setLayerColor(1, 0.8, 0.5, 0.5, 0.9)
    local r, g, b, a = map:getLayerColor(1)
    example_print_log("layer color = " .. r .. ", " .. g .. ", " .. b .. ", " .. a)
end

--@api: LTileMap:getLayerColor
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("tinted", 10, 10)
    map:setLayerColor(1, 0.8, 0.5, 0.5, 0.9)
    local r, g, b, a = map:getLayerColor(1)
    example_print_log("layer color = " .. r .. ", " .. g .. ", " .. b .. ", " .. a)
end

--@api: LTileMap:setLayerOffset
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("shifted", 10, 10)
    map:setLayerOffset(1, 16, 8)
    local ox, oy = map:getLayerOffset(1)
    example_print_log("offset = " .. ox .. ", " .. oy)
end

--@api: LTileMap:getLayerOffset
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("shifted", 10, 10)
    map:setLayerOffset(1, 16, 8)
    local ox, oy = map:getLayerOffset(1)
    example_print_log("offset = " .. ox .. ", " .. oy)
end

--@api: LTileMap:setLayerParallax
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("background", 40, 30)
    map:setLayerParallax(1, 0.5, 0.5)
    local px, py = map:getLayerParallax(1)
    example_print_log("bg parallax = " .. px .. ", " .. py)
end

--@api: LTileMap:getLayerParallax
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("background", 40, 30)
    map:setLayerParallax(1, 0.5, 0.5)
    local px, py = map:getLayerParallax(1)
    example_print_log("bg parallax = " .. px .. ", " .. py)
end

--- Tilemap Module Part 2: auto-tiling, collision sweep, tile callbacks, navigation

--@api: lurek.tilemap.newTileSet.6
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    ts:setAutoTileRule("grass", 0, 1)
    ts:setAutoTileRule("grass", 15, 16)
    local id = ts:getAutoTileId("grass", 0)
    example_print_log("bitmask 0 -> tile " .. id)
    example_print_log("bitmask 15 -> tile " .. ts:getAutoTileId("grass", 15))
end

--@api: lurek.tilemap.newTileSet.7
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    ts:setAutoTileRule("grass", 0, 1)
    ts:setAutoTileRule("grass", 15, 16)
    local id = ts:getAutoTileId("grass", 15)
    example_print_log("bitmask 15 -> tile " .. id)
end

--@api: lurek.tilemap.newTileSet.8
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 256, 16, 16, 16)
    ts:setAutoTileRule8("wall", 0, 1)
    ts:setAutoTileRule8("wall", 255, 48)
    local id = ts:getAutoTileId8("wall", 0)
    example_print_log("8-bit bitmask 0 -> tile " .. id)
    example_print_log("8-bit bitmask 255 -> tile " .. ts:getAutoTileId8("wall", 255))
end

--@api: lurek.tilemap.newTileSet.9
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 256, 16, 16, 16)
    ts:setAutoTileRule8("wall", 255, 48)
    local id = ts:getAutoTileId8("wall", 255)
    ts:setAutoTileRule8("wall", 0, 1)
    local edge = ts:getAutoTileId8("wall", 0)
    example_print_log("8-bit bitmask 255 -> tile " .. id)
    example_print_log("8-bit bitmask 0 -> tile " .. edge)
end

--@api: lurek.tilemap.newTileSet.10
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ts = lurek.tilemap.newTileSet(1, 64, 8, 16, 16)
    ts:setAutoTileRule8("shore", 255, 8)
    ts:setAutoTileMode("shore", "matchCornersAndSides")
    local mode = ts:getAutoTileMode("shore")
    example_print_log("shore mode = " .. mode)
end

--@api: lurek.tilemap.newTileSet.11
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ts = lurek.tilemap.newTileSet(1, 64, 8, 16, 16)
    local default_mode = ts:getAutoTileMode("grass")
    ts:setAutoTileMode("grass", "matchSides")
    local configured_mode = ts:getAutoTileMode("grass")
    example_print_log("grass default mode = " .. default_mode)
    example_print_log("grass configured mode = " .. configured_mode)
end

--@api: lurek.tilemap.getAutoTileFormats
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local formats = lurek.tilemap.getAutoTileFormats()
    for _, format in ipairs(formats) do
        if format.name == "rpgmaker48" or format.name == "minimal16" then
            example_print_log(format.name .. " tiles=" .. format.tileCount .. " mode=" .. format.mode)
        end
    end
end

--@api: lurek.tilemap.newAutoTileSheet
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local blob = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    example_print_log("blob47 layout = " .. blob:getLayout())
    example_print_log("blob47 tile count = " .. blob:getTileCount())
    example_print_log("blob47 tile size = " .. blob:getTileWidth() .. "x" .. blob:getTileHeight())
    local minimal = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")
    example_print_log("minimal16 tile count = " .. minimal:getTileCount())
    local rpg = lurek.tilemap.newAutoTileSheet(16, 16, "rpgmaker48")
    example_print_log("rpgmaker48 mode = " .. rpg:getDefaultMode())
end

--@api: LAutoTileSheet:applyToTileSet
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LAutoTileSheet
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")
    local bitmask = sheet:getBitmaskForTile(3)
    local tile = sheet:getTileForBitmask(bitmask)
    example_print_log("tile 3 has bitmask = " .. bitmask)
    example_print_log("bitmask " .. bitmask .. " resolves to tile " .. tile)
end

--@api: LAutoTileSheet:getTileForBitmask
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LAutoTileSheet
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")
    local tile = sheet:getTileForBitmask(7)
    local bitmask = sheet:getBitmaskForTile(tile)
    example_print_log("bitmask 7 -> tile " .. tile)
    example_print_log("tile " .. tile .. " back to bitmask " .. bitmask)
end

--@api: LAutoTileSheet:getQuad
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LAutoTileSheet
    local sheet = lurek.tilemap.newAutoTileSheet(32, 32, "composite48")
    example_print_log("composite48 count = " .. sheet:getTileCount())
    example_print_log("composite48 layout = " .. sheet:getLayout())
    local x, y, w, h = sheet:getQuad(1)
    example_print_log("quad 1: x=" .. x .. " y=" .. y .. " w=" .. w .. " h=" .. h)
end

--@api: LTileMap:applyAutoTile
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LTileMap:applyAutoTileMode
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(16, 16)
    local ts = lurek.tilemap.newTileSet(1, 64, 8, 16, 16)
    ts:setAutoTileMode("shore", "matchCornersAndSides")
    ts:setAutoTileRule8("shore", 255, 8)
    map:addTileSet(ts)
    local layer = map:addLayer("shore", 8, 8)
    for y = 3, 5 do
        for x = 3, 5 do
            map:setTile(layer, x, y, 1)
        end
    end
    map:applyAutoTileMode(layer, "shore")
    example_print_log("configured-mode center tile = " .. map:getTile(layer, 4, 4))
end

--@api: LTileMap:applyAutoTileModeAt
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(16, 16)
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    ts:setAutoTileMode("corner", "matchCorners")
    ts:setAutoTileRule("corner", 15, 4)
    map:addTileSet(ts)
    local layer = map:addLayer("corner", 8, 8)
    map:setTile(layer, 4, 4, 1)
    map:setTile(layer, 3, 3, 1)
    map:setTile(layer, 5, 3, 1)
    map:setTile(layer, 3, 5, 1)
    map:setTile(layer, 5, 5, 1)
    map:applyAutoTileModeAt(layer, 4, 4, "corner")
    example_print_log("corner-mode center tile = " .. map:getTile(layer, 4, 4))
end

--@api: LTileMap:tileTypeIndex
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LTileMap:setTileTint
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LTileMap:trySetTileTint
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("tinted", 10, 10)
    map:setTile(layer, 1, 1, 1)
    local ok, err = map:trySetTileTint(layer, 1, 1, 1.0, 0.0, 0.0, 1.0)
    example_print_log("trySetTileTint ok = " .. tostring(ok))
    example_print_log("trySetTileTint err = " .. tostring(err))
end

--@api: LTileMap:setOrientation
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 10, 10)
    local before = map:getOrientation()
    map:setOrientation("hexagonal")
    example_print_log("default orientation = " .. map:getOrientation())
    example_print_log("initial orientation = " .. before)
    example_print_log("hex orientation = " .. map:getOrientation())
end


--@api: LTileMap:update
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sx, sy = lurek.tilemap.toScreenHex(2, 3, 32)
    local q, r = lurek.tilemap.fromScreenHex(sx, sy, 32)
    example_print_log("hex(2,3) -> screen(" .. sx .. ", " .. sy .. ")")
    example_print_log("round trip -> hex(" .. q .. "," .. r .. ")")
end










--@api: lurek.tilemap.toScreenIso
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sx, sy = lurek.tilemap.toScreenIso(3, 5, 64, 32)
    local tx, ty = lurek.tilemap.fromScreenIso(sx, sy, 64, 32)
    example_print_log("tile(3,5) -> screen(" .. sx .. ", " .. sy .. ")")
    example_print_log("round trip -> tile(" .. tx .. "," .. ty .. ")")
end


--@api: lurek.tilemap.loadTMX
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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





--- Tilemap Module Part 4: ChunkMap, IsoMap, LargeMapRenderer, MapBlock, MapGroup, MapScript, MapGen

--@api: lurek.tilemap.newChunkMap
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LChunkMap
    local cm = lurek.tilemap.newChunkMap(16)
    example_print_log("type = " .. cm:type())
    example_print_log("chunk size = " .. cm:getChunkSize())
    example_print_log("loaded chunks = " .. #cm:getLoadedChunks())
    example_print_log("typeOf chunk map = " .. tostring(cm:typeOf("LChunkMap")))
end

--@api: LChunkMap:setTile
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cm = lurek.tilemap.newChunkMap(16)
    cm:setTile(10, 20, 5)
    cm:clearTile(10, 20)
    local gid = cm:getTile(10, 20)
    example_print_log("after clear = " .. gid)
end

--@api: LChunkMap:fillRect
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cm = lurek.tilemap.newChunkMap(16)
    cm:fillRect(0, 0, 10, 10, 3)
    example_print_log("filled 11x11 area with gid=3")
    example_print_log("sample (5,5) = " .. cm:getTile(5, 5))
    example_print_log("sample (11,11) = " .. cm:getTile(11, 11))
end

--@api: LChunkMap:loadChunk
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cm = lurek.tilemap.newChunkMap(16) ; cm:loadChunk(0, 0)
    cm:loadChunk(1, 0)
    cm:unloadChunk(1, 0)
    local loaded = cm:getLoadedChunks()
    example_print_log("after unload = " .. #loaded .. " chunks")
end

--@api: LChunkMap:getLoadedChunks
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cm = lurek.tilemap.newChunkMap(16)
    local minX, minY, maxX, maxY = cm:chunkTileRange(2, 3)
    example_print_log("chunk (2,3) covers tiles:")
    example_print_log("  min = " .. minX .. ", " .. minY)
    example_print_log("  max = " .. maxX .. ", " .. maxY)
end

--@api: LChunkMap:getChunksInView
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(20, 20, 64, 32, 16)
    example_print_log("type = " .. iso:type())
    example_print_log("size = " .. iso:getWidth() .. "x" .. iso:getHeight())
    example_print_log("tile size = " .. iso:getTileWidth() .. "x" .. iso:getTileHeight())
    example_print_log("level height = " .. iso:getLevelHeight())
end

--@api: LIsoMap:addLevel
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local lvl = iso:addLevel()
    iso:addLevel()
    example_print_log("added level, count = " .. iso:getLevelCount())
    example_print_log("first level index = " .. lvl)
end

--@api: LIsoMap:setTilePart
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    iso:addLevel()
    iso:setTilePart(1, 3, 4, 1, 5)
    local gid = iso:getTilePart(1, 3, 4, 1)
    example_print_log("tile part at (1,3,4,part=1) = " .. gid)
end

--@api: LIsoMap:getTilePart
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    iso:addLevel()
    iso:setTilePart(1, 3, 4, 1, 5)
    local gid = iso:getTilePart(1, 3, 4, 1)
    example_print_log("tile part at (1,3,4,part=1) = " .. gid)
end

--@api: LIsoMap:fillLevel
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16)
    iso:setOrigin(400, 100)
    local sx, sy = iso:tileToScreen(3, 2, 1)
    local tx, ty = iso:screenToTile(sx, sy)
    example_print_log("screen -> tile(" .. tx .. ", " .. ty .. ")")
end

--@api: LIsoMap:tileToScreen
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16)
    iso:setOrigin(400, 100)
    local sx, sy = iso:tileToScreen(1, 1, 1)
    example_print_log("origin set")
    example_print_log("tile(1,1,1) screen anchor = " .. sx .. "," .. sy)
end

--@api: LIsoMap:setPartOrder
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(5, 5, 64, 32, 16, 4) ; local order = iso:getPartOrder()
    example_print_log("default part order: " .. #order .. " entries")
    iso:setPartOrder({ 3, 2, 1, 0 })
    order = iso:getPartOrder()
    example_print_log("reversed order[1] = " .. order[1])
end

--@api: lurek.tilemap.newLargeMapRenderer
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LLargeMapRenderer
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    example_print_log("type = " .. lmr:type())
    example_print_log("chunk size = " .. lmr:getChunkSize())
    example_print_log("tileset columns = " .. lmr:getTilesetColumns())
    example_print_log("typeOf renderer = " .. tostring(lmr:typeOf("LLargeMapRenderer")))
end

--@api: LLargeMapRenderer:setMapData
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16) ; example_print_log("LOD enabled = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodEnabled(true)
    example_print_log("after enable = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodThresholds({ 0.5, 0.25, 0.1 })
    example_print_log("LOD thresholds set")
end

--@api: LLargeMapRenderer:isLodEnabled
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16) ; example_print_log("LOD enabled = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodEnabled(true)
    example_print_log("after enable = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodThresholds({ 0.5, 0.25, 0.1 })
    example_print_log("LOD thresholds set")
end

--@api: LLargeMapRenderer:setLodThresholds
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16) ; example_print_log("LOD enabled = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodEnabled(true)
    example_print_log("after enable = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodThresholds({ 0.5, 0.25, 0.1 })
    example_print_log("LOD thresholds set")
end

--@api: LLargeMapRenderer:invalidateAll
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; lmr:setChunkSize(32)
    example_print_log("chunk size = " .. lmr:getChunkSize()) ; lmr:setTilesetColumns(16)
    example_print_log("tileset columns = " .. lmr:getTilesetColumns()) ; lmr:invalidateChunk(0, 0)
    lmr:invalidateAll()
    example_print_log("all chunks invalidated")
end

--@api: LLargeMapRenderer:invalidateChunk
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; lmr:setChunkSize(32)
    example_print_log("chunk size = " .. lmr:getChunkSize()) ; lmr:setTilesetColumns(16)
    example_print_log("tileset columns = " .. lmr:getTilesetColumns()) ; lmr:invalidateChunk(0, 0)
    lmr:invalidateAll()
    example_print_log("all chunks invalidated")
end

--@api: LLargeMapRenderer:setChunkSize
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; lmr:setChunkSize(32)
    example_print_log("chunk size = " .. lmr:getChunkSize()) ; lmr:setTilesetColumns(16)
    example_print_log("tileset columns = " .. lmr:getTilesetColumns()) ; lmr:invalidateChunk(0, 0)
    lmr:invalidateAll()
    example_print_log("all chunks invalidated")
end

--@api: LLargeMapRenderer:setTilesetColumns
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; lmr:setChunkSize(32)
    example_print_log("chunk size = " .. lmr:getChunkSize()) ; lmr:setTilesetColumns(16)
    example_print_log("tileset columns = " .. lmr:getTilesetColumns()) ; lmr:invalidateChunk(0, 0)
    lmr:invalidateAll()
    example_print_log("all chunks invalidated")
end

--- TileMap Part 4: getChunkSize, getTileDimensions, getTileHeight, getTileWidth, type, typeOf, iso/hex helpers

--@api: LTileMap:getChunkSize
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local cs = tm:getChunkSize()
    local tw, th = tm:getTileDimensions()
    example_print_log("chunk_size=" .. cs)
    example_print_log("tile_dims=" .. tw .. "x" .. th)
end

--@api: LTileMap:getTileDimensions
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local tw, th = tm:getTileDimensions()
    local chunk = tm:getChunkSize()
    example_print_log("tile_w=" .. tw .. " tile_h=" .. th)
    example_print_log("chunk_size=" .. chunk)
end

--@api: LTileMap:getTileHeight
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local th2 = tm:getTileHeight()
    local tw2 = tm:getTileWidth()
    example_print_log("tile_height=" .. th2)
    example_print_log("tile_width=" .. tw2)
end

--@api: LTileMap:getTileWidth
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local tw2 = tm:getTileWidth()
    local th2 = tm:getTileHeight()
    example_print_log("tile_width=" .. tw2)
    example_print_log("tile_height=" .. th2)
end

--@api: LTileMap:type
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local tw, th = tm:getTileDimensions()
    example_print_log("type=" .. tm:type())
    example_print_log("tile_dims=" .. tw .. "x" .. th)
    example_print_log("chunk_size=" .. tm:getChunkSize())
end

--@api: LTileMap:typeOf
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local is_map = tm:typeOf("LTileMap")
    local is_object = tm:typeOf("LObject")
    example_print_log("typeOf=" .. tostring(tm:typeOf("LTileMap")))
    example_print_log("as_map=" .. tostring(is_map))
    example_print_log("as_object=" .. tostring(is_object))
end

--@api: lurek.tilemap.fromScreenHex
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hx, hy = lurek.tilemap.fromScreenHex(80, 40, 32)
    local sx, sy = lurek.tilemap.toScreenHex(hx, hy, 32)
    example_print_log("hex_x=" .. hx .. " hex_y=" .. hy)
    example_print_log("back_to_screen=" .. sx .. "," .. sy)
end

--@api: lurek.tilemap.fromScreenIso
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ix, iy = lurek.tilemap.fromScreenIso(128, 64, 32, 16)
    local sx, sy = lurek.tilemap.toScreenIso(ix, iy, 32, 16)
    example_print_log("iso_x=" .. ix .. " iso_y=" .. iy)
    example_print_log("back_to_screen=" .. sx .. "," .. sy)
end



--- TileMap Part 5: LTileSet full coverage

--@api: lurek.tilemap.newTileSet.12
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local count = ts:getTileCount()
    example_print_log("columns=" .. ts:getColumns())
    example_print_log("tileCount=" .. count)
    example_print_log("tileWidth=" .. ts:getTileWidth())
end

--@api: lurek.tilemap.newTileSet.13
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local columns = ts:getColumns()
    example_print_log("firstGid=" .. ts:getFirstGid())
    example_print_log("columns=" .. columns)
    example_print_log("tileHeight=" .. ts:getTileHeight())
end

--@api: lurek.tilemap.newTileSet.14
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local spacing = ts:getSpacing()
    local width = ts:getTileWidth()
    example_print_log("margin=" .. ts:getMargin())
    example_print_log("spacing=" .. spacing)
    example_print_log("tileWidth=" .. width)
end

--@api: lurek.tilemap.newTileSet.15
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local margin = ts:getMargin()
    local height = ts:getTileHeight()
    example_print_log("spacing=" .. ts:getSpacing())
    example_print_log("margin=" .. margin)
    example_print_log("tileHeight=" .. height)
end

--@api: lurek.tilemap.newTileSet.16
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local columns = ts:getColumns()
    local first_gid = ts:getFirstGid()
    example_print_log("tileCount=" .. ts:getTileCount())
    example_print_log("columns=" .. columns)
    example_print_log("firstGid=" .. first_gid)
end

--@api: lurek.tilemap.newTileSet.17
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local tw, th = ts:getTileDimensions()
    local quad = ts:getQuad(1)
    example_print_log("tile_w=" .. tw .. " tile_h=" .. th)
    example_print_log("quad_w=" .. quad.width .. " quad_h=" .. quad.height)
end

--@api: lurek.tilemap.newTileSet.18
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local tw = ts:getTileWidth()
    local count = ts:getTileCount()
    example_print_log("tileHeight=" .. ts:getTileHeight())
    example_print_log("tileWidth=" .. tw)
    example_print_log("tileCount=" .. count)
end

--@api: lurek.tilemap.newTileSet.19
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local th = ts:getTileHeight()
    local count = ts:getTileCount()
    example_print_log("tileWidth=" .. ts:getTileWidth())
    example_print_log("tileHeight=" .. th)
    example_print_log("tileCount=" .. count)
end

--@api: lurek.tilemap.newTileSet.20
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local count = ts:getTileCount()
    local columns = ts:getColumns()
    example_print_log("type=" .. ts:type())
    example_print_log("tileCount=" .. count)
    example_print_log("columns=" .. columns)
end

--@api: lurek.tilemap.newTileSet.21
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local is_tileset = ts:typeOf("LTileSet")
    local is_object = ts:typeOf("LObject")
    example_print_log("typeOf=" .. tostring(ts:typeOf("LTileSet")))
    example_print_log("as_tileset=" .. tostring(is_tileset))
    example_print_log("as_object=" .. tostring(is_object))
end

--@api: LAutoTileSheet:getLayout
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    local layout = sheet:getLayout()
    local count = sheet:getTileCount()
    example_print_log("layout:", layout)
    example_print_log("tileCount:", count)
    example_print_log("tileWidth:", sheet:getTileWidth())
end

--@api: LAutoTileSheet:getDefaultMode
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sides = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")
    local rpg = lurek.tilemap.newAutoTileSheet(16, 16, "rpgmaker48")
    local sides_mode = sides:getDefaultMode()
    local rpg_mode = rpg:getDefaultMode()
    example_print_log("minimal16 mode:", sides_mode)
    example_print_log("rpgmaker48 mode:", rpg_mode)
end

--@api: LAutoTileSheet:getTileCount
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    local count = sheet:getTileCount()
    local layout = sheet:getLayout()
    example_print_log("tileCount:", count)
    example_print_log("layout:", layout)
    example_print_log("tileHeight:", sheet:getTileHeight())
end

--@api: LAutoTileSheet:getTileHeight
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    local h = sheet:getTileHeight()
    local w = sheet:getTileWidth()
    example_print_log("tileHeight:", h)
    example_print_log("tileWidth:", w)
    example_print_log("layout:", sheet:getLayout())
end

--@api: LAutoTileSheet:getTileWidth
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sheet = lurek.tilemap.newAutoTileSheet(32, 32, "minimal16")
    local w = sheet:getTileWidth()
    local h = sheet:getTileHeight()
    example_print_log("tileWidth:", w)
    example_print_log("tileHeight:", h)
    example_print_log("tileCount:", sheet:getTileCount())
end

--@api: LAutoTileSheet:type
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sheet = lurek.tilemap.newAutoTileSheet(32, 32, "minimal16")
    local t = sheet:type()
    local layout = sheet:getLayout()
    example_print_log("type:", t)
    example_print_log("layout:", layout)
    example_print_log("tileCount:", sheet:getTileCount())
end

--@api: LAutoTileSheet:typeOf
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sheet = lurek.tilemap.newAutoTileSheet(32, 32, "minimal16")
    local ok = sheet:typeOf("LAutoTileSheet")
    local as_object = sheet:typeOf("LObject")
    example_print_log("typeOf:", ok)
    example_print_log("typeOfObject:", as_object)
    example_print_log("layout:", sheet:getLayout())
end

--@api: LChunkMap:getChunkSize
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cm = lurek.tilemap.newChunkMap(32)
    local sz = cm:getChunkSize()
    local loaded = cm:getLoadedChunks()
    example_print_log("chunkSize:", sz)
    example_print_log("loadedChunks:", #loaded)
end

--@api: LChunkMap:type
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cm = lurek.tilemap.newChunkMap(32)
    local t = cm:type()
    local sz = cm:getChunkSize()
    example_print_log("type:", t)
    example_print_log("chunkSize:", sz)
    example_print_log("loadedChunks:", #cm:getLoadedChunks())
end

--@api: LChunkMap:typeOf
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cm = lurek.tilemap.newChunkMap(32)
    local ok = cm:typeOf("LChunkMap")
    local as_object = cm:typeOf("LObject")
    example_print_log("typeOf:", ok)
    example_print_log("typeOfObject:", as_object)
    example_print_log("chunkSize:", cm:getChunkSize())
end

--@api: LIsoMap:getHeight
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(20, 15, 64, 32, 16, 4)
    local h = iso:getHeight()
    local w = iso:getWidth()
    example_print_log("isomap height:", h)
    example_print_log("isomap width:", w)
end

--@api: LIsoMap:getLevelHeight
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(20, 15, 64, 32, 16, 4)
    local lh = iso:getLevelHeight()
    local parts = iso:getPartCount()
    example_print_log("levelHeight:", lh)
    example_print_log("partCount:", parts)
end

--@api: LIsoMap:getPartCount
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(20, 15, 64, 32, 16, 4)
    local pc = iso:getPartCount()
    local lh = iso:getLevelHeight()
    example_print_log("partCount:", pc)
    example_print_log("levelHeight:", lh)
end

--@api: LIsoMap:getTileHeight
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local th = iso:getTileHeight()
    local tw = iso:getTileWidth()
    example_print_log("tileHeight:", th)
    example_print_log("tileWidth:", tw)
end

--@api: LIsoMap:getTileWidth
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local tw = iso:getTileWidth()
    local th = iso:getTileHeight()
    example_print_log("tileWidth:", tw)
    example_print_log("tileHeight:", th)
end

--@api: LIsoMap:getWidth
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local w = iso:getWidth()
    local h = iso:getHeight()
    example_print_log("width:", w)
    example_print_log("height:", h)
end

--@api: LIsoMap:type
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(8, 8, 32, 16, 8, 2)
    local t = iso:type()
    local w = iso:getWidth()
    example_print_log("type:", t)
    example_print_log("width:", w)
    example_print_log("parts:", iso:getPartCount())
end

--@api: LIsoMap:typeOf
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(8, 8, 32, 16, 8, 2)
    local ok = iso:typeOf("LIsoMap")
    local as_object = iso:typeOf("LObject")
    example_print_log("typeOf:", ok)
    example_print_log("typeOfObject:", as_object)
    example_print_log("width:", iso:getWidth())
end

--@api: LLargeMapRenderer:getChunkSize
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
    local cs = lmr:getChunkSize()
    local cols = lmr:getTilesetColumns()
    example_print_log("chunkSize:", cs)
    example_print_log("tilesetColumns:", cols)
end

--@api: LLargeMapRenderer:getTilesetColumns
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
    local cols = lmr:getTilesetColumns()
    local chunk = lmr:getChunkSize()
    example_print_log("tilesetColumns:", cols)
    example_print_log("chunkSize:", chunk)
end

--@api: LLargeMapRenderer:type
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
    local t = lmr:type()
    local chunk = lmr:getChunkSize()
    example_print_log("type:", t)
    example_print_log("chunkSize:", chunk)
    example_print_log("tilesetColumns:", lmr:getTilesetColumns())
end

--@api: LLargeMapRenderer:typeOf
do
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local ok = lmr:typeOf("LLargeMapRenderer")
    local as_object = lmr:typeOf("LObject")
    example_print_log("typeOf:", ok)
    example_print_log("typeOfObject:", as_object)
    example_print_log("chunkSize:", lmr:getChunkSize())
end

--- Added coverage examples for newer API owners.

--@api: lurek.tilemap.fromProvider
do
    local function example_log(message)
        lurek.log.info("[tilemap.example] " .. tostring(message))
    end
    local provider = { tileWidth = 16, tileHeight = 16, layers = { { name = "ground", width = 2, height = 2, tiles = { 1, 2, 3, 4 } } } }
    local ok, value = pcall(function()
        local tm = lurek.tilemap.fromProvider(provider)
        return tm:getLayerCount()
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end

--@api: LTileMap:renderFieldSlot
do
    local function example_log(message)
        lurek.log.info("[tilemap.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 2, height = 2 })
    field:setRef(1, 1, 1, "terrain", 1)
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    local tm = lurek.tilemap.newTileMap(16, 16)
    local ok, value = pcall(function()
        return tm:renderFieldSlot(field, tileset, { slot = "terrain", z = 1, refIsGid = true })
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end

--@api: LTileMap:renderFieldCatalogSlot
do
    local function example_log(message)
        lurek.log.info("[tilemap.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 2, height = 2 })
    field:setRef(1, 1, 1, "terrain", { tileset = "terrain", object = "grass" })
    local catalog = lurek.tileset.newCatalog({ terrain = lurek.tileset.newTileSet(1, 4, 2, 16, 16) })
    local tm = lurek.tilemap.newTileMap(16, 16)
    local ok, value = pcall(function()
        return tm:renderFieldCatalogSlot(field, catalog, { slot = "terrain", z = 1 })
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
