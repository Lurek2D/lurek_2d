-- content/examples/tilemap.lua
-- Auto-generated from content/examples2/tilemap_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/tilemap.lua




--- Tilemap Module Part 1: map creation, layers, tiles, tilesets, solids, viewport


--@api: lurek.tilemap.newTileMap
do

    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    lurek.log.info("type = " .. map:type())
    local tw, th = map:getTileDimensions()
    local chunk_size = map:getChunkSize()
    lurek.log.info("tile size = " .. tw .. "x" .. th)
    lurek.log.info("chunk size = " .. chunk_size)
end

--@api: LTileMap:addLayer
do

    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    local ground = map:addLayer("ground", 50, 50)
    local decor = map:addLayer("decor", 50, 50)
    local count = map:getLayerCount()
    lurek.log.info("ground layer idx = " .. ground)
    lurek.log.info("decor layer idx = " .. decor)
    lurek.log.info("layer count = " .. count)
end

--@api: LTileMap:tryAddLayer
do

    local map = lurek.tilemap.newTileMap(32, 32, 8, { maxLayers = 1 })
    local first, first_err = map:tryAddLayer("ground", 2, 2)
    local second, second_err = map:tryAddLayer("props", 2, 2)
    lurek.log.info("tryAddLayer first = " .. tostring(first) .. " err = " .. tostring(first_err))
    lurek.log.info("tryAddLayer second = " .. tostring(second) .. " err = " .. tostring(second_err))
end

--@api: LTileMap:getLayerName
do

    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("terrain", 40, 30)
    map:addLayer("props", 40, 30)
    local second_name = map:getLayerName(2)
    lurek.log.info("layer 1 = " .. map:getLayerName(1))
    lurek.log.info("layer 2 = " .. second_name)
end

--@api: LTileMap:getLayerCount
do

    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("terrain", 40, 30)
    map:addLayer("props", 40, 30)
    local second = map:getLayerName(2)
    lurek.log.info("layer count = " .. map:getLayerCount())
    lurek.log.info("second layer = " .. second)
end

--@api: LTileMap:setTile
do

    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)
    map:setTile(layer, 3, 4, 5)
    local gid = map:getTile(layer, 3, 4)
    lurek.log.info("tile at 3,4 = " .. gid)
end

--@api: LTileMap:trySetTile
do

    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)
    local ok, err = map:trySetTile(layer, 11, 1, 7)
    lurek.log.info("trySetTile ok = " .. tostring(ok))
    lurek.log.info("trySetTile err = " .. tostring(err))
end

--@api: LTileMap:getTile
do

    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)
    map:setTile(layer, 3, 4, 5)
    local gid = map:getTile(layer, 3, 4)
    lurek.log.info("tile at 3,4 = " .. gid)
end

--@api: LTileMap:tryGetTile
do

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 10, 10)
    local gid, err = map:tryGetTile(2, 1, 1)
    lurek.log.info("tryGetTile gid = " .. tostring(gid))
    lurek.log.info("tryGetTile err = " .. tostring(err))
end

--@api: LTileMap:getDiagnostics
do

    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)
    map:trySetTile(layer, 11, 1, 7)
    map:tryGetTile(2, 1, 1)
    local diagnostics = map:getDiagnostics()
    lurek.log.info("invalid layer = " .. tostring(diagnostics.invalidLayer))
    lurek.log.info("invalid coord = " .. tostring(diagnostics.invalidCoord))
end

--@api: LTileMap:clearTile
do

    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)
    map:setTile(layer, 3, 4, 5)
    map:clearTile(layer, 3, 4)
    local gid = map:getTile(layer, 3, 4)
    lurek.log.info("after clear = " .. gid)
end

--@api: LTileMap:fill
do

    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("ground", 20, 20)
    map:fill(layer, 3)
    lurek.log.info("fill complete, sample = " .. map:getTile(layer, 10, 10))
    lurek.log.info("corner = " .. map:getTile(layer, 1, 1))
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
    lurek.log.info("found gid=7 count = " .. #positions)
    for _, pos in ipairs(positions) do
        lurek.log.info("  x=" .. pos.x .. " y=" .. pos.y)
    end
end

--@api: lurek.tilemap.newTileSet
do

    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 64, 8, 32, 32)
    lurek.log.info("type = " .. ts:type())
    lurek.log.info("first gid = " .. ts:getFirstGid())
    lurek.log.info("tile count = " .. ts:getTileCount())
    lurek.log.info("columns = " .. ts:getColumns())
end

--@api: lurek.tilemap.newTileSet.2
do

    local ts = lurek.tilemap.newTileSet(1, 32, 8, 32, 32)
    ts:setProfile(1, "stone_floor")
    ts:setPhysicsShape(1, "rect")
    lurek.log.info("profile=" .. tostring(ts:getProfile(1)))
    lurek.log.info("shape=" .. tostring(ts:getPhysicsShape(1)))
end

--@api: lurek.tilemap.newTileSet.3
do

    local ts = lurek.tilemap.newTileSet(1, 16, 4, 32, 32)
    local q1 = ts:getQuad(1)
    lurek.log.info("tile 1: x=" .. q1.x .. " y=" .. q1.y .. " w=" .. q1.width .. " h=" .. q1.height)
    local q5 = ts:getQuad(5)
    lurek.log.info("tile 5: x=" .. q5.x .. " y=" .. q5.y .. " w=" .. q5.width .. " h=" .. q5.height)
end

--@api: lurek.tilemap.newTileSet.4
do

    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    ts:setAnimation(1, {
        { tileid = 1, duration = 200 },
        { tileid = 2, duration = 200 },
        { tileid = 3, duration = 200 },
        { tileid = 4, duration = 200 },
    })

    local anim = ts:getAnimation(1)
    lurek.log.info("animation frames = " .. #anim)
    for i, frame in ipairs(anim) do
        lurek.log.info("  frame " .. i .. ": tile=" .. frame.tileid .. " dur=" .. frame.duration)
    end
    local noAnim = ts:getAnimation(10)
    lurek.log.info("tile 10 anim = " .. tostring(noAnim))
end

--@api: lurek.tilemap.newTileSet.5
do

    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    ts:setAnimation(1, {
        { tileid = 1, duration = 200 },
        { tileid = 2, duration = 200 },
        { tileid = 3, duration = 200 },
        { tileid = 4, duration = 200 },
    })

    local anim = ts:getAnimation(1)
    lurek.log.info("animation frames = " .. #anim)
    for i, frame in ipairs(anim) do
        lurek.log.info("  frame " .. i .. ": tile=" .. frame.tileid .. " dur=" .. frame.duration)
    end
    local noAnim = ts:getAnimation(10)
    lurek.log.info("tile 10 anim = " .. tostring(noAnim))
end

--@api: LTileMap:addTileSet
do

    local map = lurek.tilemap.newTileMap(32, 32)
    local terrain = lurek.tilemap.newTileSet(1, 64, 8, 32, 32)
    local objects = lurek.tilemap.newTileSet(65, 32, 8, 32, 32)

    map:addTileSet(terrain)
    map:addTileSet(objects)
    lurek.log.info("tileset count = " .. map:getTileSetCount())
end

--@api: LTileMap:getTileSet
do

    local map = lurek.tilemap.newTileMap(32, 32)
    local terrain = lurek.tilemap.newTileSet(1, 64, 8, 32, 32)
    local objects = lurek.tilemap.newTileSet(65, 32, 8, 32, 32)

    map:addTileSet(terrain)
    map:addTileSet(objects)
    local ts1 = map:getTileSet(1)
    lurek.log.info("tileset 1 first gid = " .. ts1:getFirstGid())
end

--@api: LTileMap:getTileSetCount
do

    local map = lurek.tilemap.newTileMap(32, 32)
    local terrain = lurek.tilemap.newTileSet(1, 64, 8, 32, 32)
    local objects = lurek.tilemap.newTileSet(65, 32, 8, 32, 32)

    map:addTileSet(terrain)
    map:addTileSet(objects)
    lurek.log.info("tileset count = " .. map:getTileSetCount())
end

--@api: LTileMap:setViewport
do

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("ground", 100, 100)
    map:setViewport(0, 0, 800, 600)
    local vx, vy, vw, vh = map:getViewport()
    lurek.log.info("viewport = " .. vx .. "," .. vy .. " " .. vw .. "x" .. vh)
end

--@api: LTileMap:getViewport
do

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("ground", 100, 100)
    map:setViewport(0, 0, 800, 600)
    local vx, vy, vw, vh = map:getViewport()
    lurek.log.info("viewport = " .. vx .. "," .. vy .. " " .. vw .. "x" .. vh)
end

--@api: LTileMap:render
do

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("ground", 100, 100)
    map:setViewport(0, 0, 800, 600)

    map:render()
    lurek.log.info("rendered at origin")
    map:render(10, 10)
    lurek.log.info("rendered with offset")
end

--@api: LTileMap:setShader
do

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
    lurek.log.info("tilemap shader target = " .. map:getShader():getTarget())
end

--@api: LTileMap:getShader
do

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
    lurek.log.info("bound tilemap shader id = " .. tostring(bound:getId()))
end

--@api: LTileMap:setLayerShader
do

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
    lurek.log.info("layer shader target = " .. map:getLayerShader(2):getTarget())
end

--@api: LTileMap:getLayerShader
do

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
    lurek.log.info("layer shader id = " .. tostring(layer_shader:getId()))
end

--@api: LTileMap:worldToTile
do

    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 20, 20)
    local tx, ty = map:worldToTile(100, 80)
    local wx, wy = map:tileToWorld(tx, ty)
    lurek.log.info("world(100,80) -> tile(" .. tx .. "," .. ty .. ")")
    lurek.log.info("tile(" .. tx .. "," .. ty .. ") -> world(" .. wx .. "," .. wy .. ")")
end

--@api: LTileMap:tryWorldToTile
do

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 20, 20)
    local tx, ty = map:tryWorldToTile(64, 32)
    local bad_tx, bad_ty = map:tryWorldToTile(-1, 0)
    lurek.log.info("tryWorldToTile valid = " .. tostring(tx) .. "," .. tostring(ty))
    lurek.log.info("tryWorldToTile invalid = " .. tostring(bad_tx) .. "," .. tostring(bad_ty))
end

--@api: LTileMap:tileToWorld
do

    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 20, 20)
    local wx, wy = map:tileToWorld(5, 3)
    local tx, ty = map:worldToTile(wx, wy)
    lurek.log.info("tile(5,3) -> world(" .. wx .. "," .. wy .. ")")
    lurek.log.info("round trip -> tile(" .. tx .. "," .. ty .. ")")
end

--@api: LTileMap:setLayerVisible
do

    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("background", 20, 20)
    map:setLayerVisible(1, false)
    local hidden = map:getLayerVisible(1)
    lurek.log.info("after hide = " .. tostring(map:getLayerVisible(1)))
    map:setLayerVisible(1, true)
    lurek.log.info("hidden flag = " .. tostring(hidden))
    lurek.log.info("after show = " .. tostring(map:getLayerVisible(1)))
end

--@api: LTileMap:getLayerVisible
do

    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("background", 20, 20)
    local before = map:getLayerVisible(1)
    map:setLayerVisible(1, false)
    lurek.log.info("layer 1 visible = " .. tostring(map:getLayerVisible(1)))
    lurek.log.info("default visible = " .. tostring(before))
    lurek.log.info("after hide = " .. tostring(map:getLayerVisible(1)))
end

--@api: LTileMap:setLayerColor
do

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("tinted", 10, 10)
    map:setLayerColor(1, 0.8, 0.5, 0.5, 0.9)
    local r, g, b, a = map:getLayerColor(1)
    lurek.log.info("layer color = " .. r .. ", " .. g .. ", " .. b .. ", " .. a)
end

--@api: LTileMap:getLayerColor
do

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("tinted", 10, 10)
    map:setLayerColor(1, 0.8, 0.5, 0.5, 0.9)
    local r, g, b, a = map:getLayerColor(1)
    lurek.log.info("layer color = " .. r .. ", " .. g .. ", " .. b .. ", " .. a)
end

--@api: LTileMap:setLayerOffset
do

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("shifted", 10, 10)
    map:setLayerOffset(1, 16, 8)
    local ox, oy = map:getLayerOffset(1)
    lurek.log.info("offset = " .. ox .. ", " .. oy)
end

--@api: LTileMap:getLayerOffset
do

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("shifted", 10, 10)
    map:setLayerOffset(1, 16, 8)
    local ox, oy = map:getLayerOffset(1)
    lurek.log.info("offset = " .. ox .. ", " .. oy)
end

--@api: LTileMap:setLayerParallax
do

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("background", 40, 30)
    map:setLayerParallax(1, 0.5, 0.5)
    local px, py = map:getLayerParallax(1)
    lurek.log.info("bg parallax = " .. px .. ", " .. py)
end

--@api: LTileMap:getLayerParallax
do

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("background", 40, 30)
    map:setLayerParallax(1, 0.5, 0.5)
    local px, py = map:getLayerParallax(1)
    lurek.log.info("bg parallax = " .. px .. ", " .. py)
end

--- Tilemap Module Part 2: auto-tiling, collision sweep, tile callbacks, navigation

--@api: lurek.tilemap.newTileSet.6
do

    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    ts:setAutoTileRule("grass", 0, 1)
    ts:setAutoTileRule("grass", 15, 16)
    local id = ts:getAutoTileId("grass", 0)
    lurek.log.info("bitmask 0 -> tile " .. id)
    lurek.log.info("bitmask 15 -> tile " .. ts:getAutoTileId("grass", 15))
end

--@api: lurek.tilemap.newTileSet.7
do

    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    ts:setAutoTileRule("grass", 0, 1)
    ts:setAutoTileRule("grass", 15, 16)
    local id = ts:getAutoTileId("grass", 15)
    lurek.log.info("bitmask 15 -> tile " .. id)
end

--@api: lurek.tilemap.newTileSet.8
do

    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 256, 16, 16, 16)
    ts:setAutoTileRule8("wall", 0, 1)
    ts:setAutoTileRule8("wall", 255, 48)
    local id = ts:getAutoTileId8("wall", 0)
    lurek.log.info("8-bit bitmask 0 -> tile " .. id)
    lurek.log.info("8-bit bitmask 255 -> tile " .. ts:getAutoTileId8("wall", 255))
end

--@api: lurek.tilemap.newTileSet.9
do

    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 256, 16, 16, 16)
    ts:setAutoTileRule8("wall", 255, 48)
    local id = ts:getAutoTileId8("wall", 255)
    ts:setAutoTileRule8("wall", 0, 1)
    local edge = ts:getAutoTileId8("wall", 0)
    lurek.log.info("8-bit bitmask 255 -> tile " .. id)
    lurek.log.info("8-bit bitmask 0 -> tile " .. edge)
end

--@api: lurek.tilemap.newTileSet.10
do

    local ts = lurek.tilemap.newTileSet(1, 64, 8, 16, 16)
    ts:setAutoTileRule8("shore", 255, 8)
    ts:setAutoTileMode("shore", "matchCornersAndSides")
    local mode = ts:getAutoTileMode("shore")
    lurek.log.info("shore mode = " .. mode)
end

--@api: lurek.tilemap.newTileSet.11
do

    local ts = lurek.tilemap.newTileSet(1, 64, 8, 16, 16)
    local default_mode = ts:getAutoTileMode("grass")
    ts:setAutoTileMode("grass", "matchSides")
    local configured_mode = ts:getAutoTileMode("grass")
    lurek.log.info("grass default mode = " .. default_mode)
    lurek.log.info("grass configured mode = " .. configured_mode)
end

--@api: lurek.tilemap.getAutoTileFormats
do

    local formats = lurek.tilemap.getAutoTileFormats()
    for _, format in ipairs(formats) do
        if format.name == "rpgmaker48" or format.name == "minimal16" then
            lurek.log.info(format.name .. " tiles=" .. format.tileCount .. " mode=" .. format.mode)
        end
    end
end

--@api: lurek.tilemap.newAutoTileSheet
do

    local blob = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    lurek.log.info("blob47 layout = " .. blob:getLayout())
    lurek.log.info("blob47 tile count = " .. blob:getTileCount())
    lurek.log.info("blob47 tile size = " .. blob:getTileWidth() .. "x" .. blob:getTileHeight())
    local minimal = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")
    lurek.log.info("minimal16 tile count = " .. minimal:getTileCount())
    local rpg = lurek.tilemap.newAutoTileSheet(16, 16, "rpgmaker48")
    lurek.log.info("rpgmaker48 mode = " .. rpg:getDefaultMode())
end

--@api: LAutoTileSheet:applyToTileSet
do

    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    local ts = lurek.tilemap.newTileSet(1, 64, 8, 16, 16)

    sheet:applyToTileSet(ts, "terrain")
    local id = ts:getAutoTileId("terrain", 5)
    lurek.log.info("after apply, bitmask 5 -> tile " .. tostring(id))

    sheet:applyToTileSet(ts, "water", 17)
    id = ts:getAutoTileId("water", 0)
    lurek.log.info("water bitmask 0 -> tile " .. tostring(id))
end

--@api: LAutoTileSheet:getBitmaskForTile
do

    ---@type LAutoTileSheet
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")
    local bitmask = sheet:getBitmaskForTile(3)
    local tile = sheet:getTileForBitmask(bitmask)
    lurek.log.info("tile 3 has bitmask = " .. bitmask)
    lurek.log.info("bitmask " .. bitmask .. " resolves to tile " .. tile)
end

--@api: LAutoTileSheet:getTileForBitmask
do

    ---@type LAutoTileSheet
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")
    local tile = sheet:getTileForBitmask(7)
    local bitmask = sheet:getBitmaskForTile(tile)
    lurek.log.info("bitmask 7 -> tile " .. tile)
    lurek.log.info("tile " .. tile .. " back to bitmask " .. bitmask)
end

--@api: LAutoTileSheet:getQuad
do

    ---@type LAutoTileSheet
    local sheet = lurek.tilemap.newAutoTileSheet(32, 32, "composite48")
    lurek.log.info("composite48 count = " .. sheet:getTileCount())
    lurek.log.info("composite48 layout = " .. sheet:getLayout())
    local x, y, w, h = sheet:getQuad(1)
    lurek.log.info("quad 1: x=" .. x .. " y=" .. y .. " w=" .. w .. " h=" .. h)
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
    lurek.log.info("4-bit auto-tile applied")
    lurek.log.info("center tile after auto = " .. gid)
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

    lurek.log.info("8-bit auto-tile applied")
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
    lurek.log.info("single cell auto-tiled at 5,5")
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
    lurek.log.info("single cell 8-bit auto-tiled at 3,3")
end

--@api: LTileMap:applyAutoTileMode
do

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
    lurek.log.info("configured-mode center tile = " .. map:getTile(layer, 4, 4))
end

--@api: LTileMap:applyAutoTileModeAt
do

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
    lurek.log.info("corner-mode center tile = " .. map:getTile(layer, 4, 4))
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
    lurek.log.info("tile type index built")
    for gid, positions in pairs(index) do
        lurek.log.info("  gid " .. gid .. " has " .. #positions .. " tiles")
    end
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
    lurek.log.info("RGB tints applied to 3 tiles")
end

--@api: LTileMap:trySetTileTint
do

    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("tinted", 10, 10)
    map:setTile(layer, 1, 1, 1)
    local ok, err = map:trySetTileTint(layer, 1, 1, 1.0, 0.0, 0.0, 1.0)
    lurek.log.info("trySetTileTint ok = " .. tostring(ok))
    lurek.log.info("trySetTileTint err = " .. tostring(err))
end

--@api: LTileMap:setOrientation
do

    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 10, 10)
    map:setOrientation("isometric")
    local wx, wy = map:tileToWorld(3, 2)
    lurek.log.info("set to " .. map:getOrientation())
    lurek.log.info("tile(3,2) projects near world(" .. wx .. "," .. wy .. ")")
end

--@api: LTileMap:getOrientation
do

    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 10, 10)
    local before = map:getOrientation()
    map:setOrientation("hexagonal")
    lurek.log.info("default orientation = " .. map:getOrientation())
    lurek.log.info("initial orientation = " .. before)
    lurek.log.info("hex orientation = " .. map:getOrientation())
end


--@api: LTileMap:update
do

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("animated", 10, 10)

    local dt = 1 / 60
    map:update(dt)
    map:update(dt)
    map:update(dt)
    lurek.log.info("updated 3 frames at 60fps")
end

--- Tilemap Module Part 3: hex utilities, iso helpers, coordinate conversion, TMX/LDtk loading

--@api: lurek.tilemap.toScreenHex
do

    local tile_size = 32
    local sx, sy = lurek.tilemap.toScreenHex(2, 3, tile_size)
    local q, r = lurek.tilemap.fromScreenHex(sx, sy, tile_size)
    lurek.log.info("hex(2,3) -> screen(" .. sx .. ", " .. sy .. ")")
    lurek.log.info("round trip -> hex(" .. q .. "," .. r .. ")")
end










--@api: lurek.tilemap.toScreenIso
do

    local tile_w, tile_h = 64, 32
    local sx, sy = lurek.tilemap.toScreenIso(3, 5, tile_w, tile_h)
    local tx, ty = lurek.tilemap.fromScreenIso(sx, sy, tile_w, tile_h)
    lurek.log.info("tile(3,5) -> screen(" .. sx .. ", " .. sy .. ")")
    lurek.log.info("round trip -> tile(" .. tx .. "," .. ty .. ")")
end


--@api: lurek.tilemap.loadTMX
do

    local tmxData = [[<?xml version="1.0" encoding="UTF-8"?> <map version="1.10" orientation="orthogonal" width="4" height="4" tilewidth="32" tileheight="32"> <layer name="ground" width="4" height="4"> <data encoding="csv">1,1,1,1,1,2,2,1,1,2,2,1,1,1,1,1</data> </layer> </map>]]
    local result, err = lurek.tilemap.loadTMX(tmxData)
    if result then
        lurek.log.info("TMX width = " .. result.width)
        lurek.log.info("TMX height = " .. result.height)
        lurek.log.info("TMX tile size = " .. result.tileWidth .. "x" .. result.tileHeight)
        lurek.log.info("TMX orientation = " .. result.orientation)
        lurek.log.info("TMX layers = " .. #result.layers)
    else
        local err_tbl = err or {}
        local code = err_tbl["code"] or "unknown"
        local message = err_tbl["message"] or "unknown"
        lurek.log.info("TMX import error: " .. code .. " - " .. message)
    end
end

--@api: lurek.tilemap.fromLDtk
do

    local ldtkJson = '{"levels":[{"identifier":"Level_0","layerInstances":[]}]}'
    local map, err = lurek.tilemap.fromLDtk(ldtkJson)
    if map then
        lurek.log.info("LDtk map type = " .. map:type())
    else
        local err_tbl = err or {}
        local code = err_tbl["code"] or "unknown"
        local message = err_tbl["message"] or "unknown"
        lurek.log.info("LDtk import error: " .. code .. " - " .. message)
    end
    local named, named_err = lurek.tilemap.fromLDtk(ldtkJson, "Level_0")
    if named then
        lurek.log.info("named level loaded")
    else
        local err_tbl = named_err or {}
        local code = err_tbl["code"] or "unknown"
        lurek.log.info("named level import error: " .. code)
    end
end





--- Tilemap Module Part 4: ChunkMap, IsoMap, LargeMapRenderer, MapBlock, MapGroup, MapScript, MapGen

--@api: lurek.tilemap.newChunkMap
do

    ---@type LChunkMap
    local cm = lurek.tilemap.newChunkMap(16)
    lurek.log.info("type = " .. cm:type())
    lurek.log.info("chunk size = " .. cm:getChunkSize())
    lurek.log.info("loaded chunks = " .. #cm:getLoadedChunks())
    lurek.log.info("typeOf chunk map = " .. tostring(cm:typeOf("LChunkMap")))
end

--@api: LChunkMap:setTile
do

    ---@type LChunkMap
    local cm = lurek.tilemap.newChunkMap(16)
    cm:setTile(10, 20, 5)
    local gid = cm:getTile(10, 20)
    local loaded = cm:getLoadedChunks()
    lurek.log.info("tile at 10,20 = " .. gid)
    lurek.log.info("loaded chunks after write = " .. #loaded)
end

--@api: LChunkMap:getTile
do

    ---@type LChunkMap
    local cm = lurek.tilemap.newChunkMap(16)
    cm:setTile(10, 20, 5)
    local gid = cm:getTile(10, 20)
    local x0, y0, x1, y1 = cm:chunkTileRange(0, 1)
    lurek.log.info("tile at 10,20 = " .. gid)
    lurek.log.info("chunk range = (" .. x0 .. "," .. y0 .. ")-(" .. x1 .. "," .. y1 .. ")")
end

--@api: LChunkMap:clearTile
do

    local cm = lurek.tilemap.newChunkMap(16)
    cm:setTile(10, 20, 5)
    cm:clearTile(10, 20)
    local gid = cm:getTile(10, 20)
    lurek.log.info("after clear = " .. gid)
end

--@api: LChunkMap:fillRect
do

    local cm = lurek.tilemap.newChunkMap(16)
    cm:fillRect(0, 0, 10, 10, 3)
    lurek.log.info("filled 11x11 area with gid=3")
    lurek.log.info("sample (5,5) = " .. cm:getTile(5, 5))
    lurek.log.info("sample (11,11) = " .. cm:getTile(11, 11))
end

--@api: LChunkMap:loadChunk
do


    local cm = lurek.tilemap.newChunkMap(16)
    cm:loadChunk(0, 0)
    local loaded = cm:getLoadedChunks()
    lurek.log.info("loaded chunks = " .. #loaded)
    for _, c in ipairs(loaded) do
        local cx, cy = c.cx or c[1], c.cy or c[2]
        lurek.log.info("  chunk (" .. cx .. ", " .. cy .. ")")
    end
end

--@api: LChunkMap:unloadChunk
do

    local cm = lurek.tilemap.newChunkMap(16) ; cm:loadChunk(0, 0)
    cm:loadChunk(1, 0)
    cm:unloadChunk(1, 0)
    local loaded = cm:getLoadedChunks()
    lurek.log.info("after unload = " .. #loaded .. " chunks")
end

--@api: LChunkMap:getLoadedChunks
do


    local cm = lurek.tilemap.newChunkMap(16) ; cm:loadChunk(0, 0)
    cm:loadChunk(1, 0) ; cm:loadChunk(0, 1)
    local loaded = cm:getLoadedChunks()
    lurek.log.info("loaded chunks = " .. #loaded)
    for _, c in ipairs(loaded) do
        local cx, cy = c.cx or c[1], c.cy or c[2]
        lurek.log.info("  chunk (" .. cx .. ", " .. cy .. ")")
    end
end

--@api: LChunkMap:chunkTileRange
do

    local cm = lurek.tilemap.newChunkMap(16)
    local minX, minY, maxX, maxY = cm:chunkTileRange(2, 3)
    lurek.log.info("chunk (2,3) covers tiles:")
    lurek.log.info("  min = " .. minX .. ", " .. minY)
    lurek.log.info("  max = " .. maxX .. ", " .. maxY)
end

--@api: LChunkMap:getChunksInView
do


    local cm = lurek.tilemap.newChunkMap(16)
    local visible = cm:getChunksInView(0, 0, 800, 600, 32, 32)
    lurek.log.info("visible chunks in 800x600 viewport: " .. #visible)
    for i = 1, math.min(3, #visible) do
        local cell = visible[i]
        local cx, cy = cell.cx or cell[1], cell.cy or cell[2]
        lurek.log.info("  chunk (" .. cx .. ", " .. cy .. ")")
    end
end

--@api: LChunkMap:setTiles
do
    local cm = lurek.tilemap.newChunkMap(8)
    local dirty = cm:setTiles({ { x = 0, y = 0, gid = 2 }, { x = 8, y = 0, gid = 3 }, { -1, -1, 4 } })
    local left = cm:getTile(-1, -1)
    local right = cm:getTile(8, 0)
    lurek.log.info("batch dirty chunks=" .. tostring(#dirty))
    lurek.log.info("batch samples=" .. tostring(left) .. "," .. tostring(right))
end

--@api: LChunkMap:getDirtyChunks
do
    local cm = lurek.tilemap.newChunkMap(8)
    cm:setTile(0, 0, 1)
    cm:setTile(8, 0, 2)
    local dirty = cm:getDirtyChunks()
    local first = dirty[1] or { cx = -1, cy = -1 }
    lurek.log.info("dirty chunks=" .. tostring(#dirty))
    lurek.log.info("first dirty=" .. tostring(first.cx) .. "," .. tostring(first.cy))
end

--@api: LChunkMap:drainDirtyChunks
do
    local cm = lurek.tilemap.newChunkMap(8)
    cm:setTile(0, 0, 1)
    cm:setTile(9, 0, 2)
    local drained = cm:drainDirtyChunks()
    local remaining = cm:getDirtyChunks()
    lurek.log.info("drained chunks=" .. tostring(#drained))
    lurek.log.info("remaining chunks=" .. tostring(#remaining))
end

--@api: LChunkMap:clearDirtyChunks
do
    local cm = lurek.tilemap.newChunkMap(8)
    cm:setTile(0, 0, 1)
    local before = #cm:getDirtyChunks()
    cm:clearDirtyChunks()
    local after = #cm:getDirtyChunks()
    lurek.log.info("clear dirty before=" .. tostring(before))
    lurek.log.info("clear dirty after=" .. tostring(after))
end

--@api: LChunkMap:chunkToBytes
do
    local cm = lurek.tilemap.newChunkMap(8)
    cm:setTile(2, 3, 7)
    local bytes = cm:chunkToBytes(0, 0)
    local size = bytes and #bytes or 0
    local gid = cm:getTile(2, 3)
    lurek.log.info("chunk bytes=" .. tostring(size))
    lurek.log.info("chunk sample=" .. tostring(gid))
end

--@api: LChunkMap:loadChunkFromBytes
do
    local source = lurek.tilemap.newChunkMap(8)
    source:setTile(2, 3, 7)
    local bytes = source:chunkToBytes(0, 0)
    local clone = lurek.tilemap.newChunkMap(8)
    clone:loadChunkFromBytes(1, 0, bytes)
    lurek.log.info("loaded chunk sample=" .. tostring(clone:getTile(10, 3)))
    lurek.log.info("loaded chunk dirty=" .. tostring(#clone:getDirtyChunks()))
end

--@api: lurek.tilemap.newIsoMap
do

    local iso = lurek.tilemap.newIsoMap(20, 20, 64, 32, 16)
    lurek.log.info("type = " .. iso:type())
    lurek.log.info("size = " .. iso:getWidth() .. "x" .. iso:getHeight())
    lurek.log.info("tile size = " .. iso:getTileWidth() .. "x" .. iso:getTileHeight())
    lurek.log.info("level height = " .. iso:getLevelHeight())
end

--@api: LIsoMap:addLevel
do

    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local lvl = iso:addLevel()
    local second = iso:addLevel()
    lurek.log.info("added level, count = " .. iso:getLevelCount())
    lurek.log.info("first level index = " .. lvl)
    lurek.log.info("second level index = " .. second)
end

--@api: LIsoMap:getLevelCount
do

    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local lvl = iso:addLevel()
    iso:addLevel()
    lurek.log.info("added level, count = " .. iso:getLevelCount())
    lurek.log.info("first level index = " .. lvl)
end

--@api: LIsoMap:setTilePart
do

    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    iso:addLevel()
    iso:setTilePart(1, 3, 4, 1, 5)
    local gid = iso:getTilePart(1, 3, 4, 1)
    lurek.log.info("tile part at (1,3,4,part=1) = " .. gid)
end

--@api: LIsoMap:getTilePart
do

    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    iso:addLevel()
    iso:setTilePart(1, 3, 4, 1, 5)
    local gid = iso:getTilePart(1, 3, 4, 1)
    lurek.log.info("tile part at (1,3,4,part=1) = " .. gid)
end

--@api: LIsoMap:fillLevel
do

    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(8, 8, 64, 32, 16)
    iso:addLevel()
    iso:fillLevel(1, 1, 3)
    local gid = iso:getTilePart(1, 2, 2, 1)
    lurek.log.info("filled level 1, part 1 with gid=3")
    lurek.log.info("sample tile part = " .. gid)
end

--@api: LIsoMap:isLevelVisible
do

    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(8, 8, 64, 32, 16)
    iso:addLevel()
    local before = iso:isLevelVisible(1)
    iso:setLevelVisible(1, false)
    lurek.log.info("level 1 visible = " .. tostring(iso:isLevelVisible(1)))
    lurek.log.info("default visible = " .. tostring(before))
    lurek.log.info("after hide = " .. tostring(iso:isLevelVisible(1)))
end

--@api: LIsoMap:setLevelVisible
do

    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(8, 8, 64, 32, 16)
    iso:addLevel()
    iso:setLevelVisible(1, false)
    local hidden = iso:isLevelVisible(1)
    lurek.log.info("after hide = " .. tostring(iso:isLevelVisible(1)))
    iso:setLevelVisible(1, true)
    lurek.log.info("hidden flag = " .. tostring(hidden))
    lurek.log.info("after show = " .. tostring(iso:isLevelVisible(1)))
end

--@api: LIsoMap:screenToTile
do

    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16)
    iso:setOrigin(400, 100)
    local sx, sy = iso:tileToScreen(3, 2, 1)
    local tx, ty = iso:screenToTile(sx, sy)
    lurek.log.info("screen -> tile(" .. tx .. ", " .. ty .. ")")
end

--@api: LIsoMap:tileToScreen
do

    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16)
    iso:setOrigin(400, 100)
    local sx, sy = iso:tileToScreen(3, 2, 1)
    local tx, ty = iso:screenToTile(sx, sy)
    lurek.log.info("tile(3,2,z=1) -> screen(" .. sx .. ", " .. sy .. ")")
    lurek.log.info("round trip -> tile(" .. tx .. "," .. ty .. ")")
end

--@api: LIsoMap:setOrigin
do

    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16)
    iso:setOrigin(400, 100)
    local sx, sy = iso:tileToScreen(1, 1, 1)
    lurek.log.info("origin set")
    lurek.log.info("tile(1,1,1) screen anchor = " .. sx .. "," .. sy)
end

--@api: LIsoMap:setPartOrder
do

    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(5, 5, 64, 32, 16, 4)
    iso:setPartOrder({ 3, 2, 1, 0 })
    local order = iso:getPartOrder()
    local parts = iso:getPartCount()
    lurek.log.info("reversed order[1] = " .. order[1])
    lurek.log.info("part count = " .. parts)
end

--@api: LIsoMap:getPartOrder
do

    local iso = lurek.tilemap.newIsoMap(5, 5, 64, 32, 16, 4) ; local order = iso:getPartOrder()
    lurek.log.info("default part order: " .. #order .. " entries")
    iso:setPartOrder({ 3, 2, 1, 0 })
    order = iso:getPartOrder()
    lurek.log.info("reversed order[1] = " .. order[1])
end

--@api: lurek.tilemap.newLargeMapRenderer
do

    ---@type LLargeMapRenderer
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    lurek.log.info("type = " .. lmr:type())
    lurek.log.info("chunk size = " .. lmr:getChunkSize())
    lurek.log.info("tileset columns = " .. lmr:getTilesetColumns())
    lurek.log.info("typeOf renderer = " .. tostring(lmr:typeOf("LLargeMapRenderer")))
end

--@api: LLargeMapRenderer:setMapData
do


    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local width, height = 24, 24
    local data = {}
    for y = 1, height do
        for x = 1, width do
            data[#data + 1] = ((x + y) % 4) + 1
        end
    end
    lmr:setMapData(data, width, height)
    local w, h = lmr:getMapSize() ; lurek.log.info("map size = " .. w .. "x" .. h)
    lurek.log.info("tile at (12,12) = " .. lmr:getTile(12, 12)) ; lmr:setTile(12, 12, 99)
    lurek.log.info("after set = " .. lmr:getTile(12, 12))
end

--@api: LLargeMapRenderer:getMapSize
do


    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local width, height = 24, 24
    local data = {}
    for y = 1, height do
        for x = 1, width do
            data[#data + 1] = ((x + y) % 4) + 1
        end
    end
    lmr:setMapData(data, width, height)
    local w, h = lmr:getMapSize() ; lurek.log.info("map size = " .. w .. "x" .. h)
    lurek.log.info("tile at (12,12) = " .. lmr:getTile(12, 12)) ; lmr:setTile(12, 12, 99)
    lurek.log.info("after set = " .. lmr:getTile(12, 12))
end

--@api: LLargeMapRenderer:getTile
do


    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local width, height = 24, 24
    local data = {}
    for y = 1, height do
        for x = 1, width do
            data[#data + 1] = ((x + y) % 4) + 1
        end
    end
    lmr:setMapData(data, width, height)
    local w, h = lmr:getMapSize() ; lurek.log.info("map size = " .. w .. "x" .. h)
    lurek.log.info("tile at (12,12) = " .. lmr:getTile(12, 12)) ; lmr:setTile(12, 12, 99)
    lurek.log.info("after set = " .. lmr:getTile(12, 12))
end

--@api: LLargeMapRenderer:setTile
do


    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local width, height = 24, 24
    local data = {}
    for y = 1, height do
        for x = 1, width do
            data[#data + 1] = ((x + y) % 4) + 1
        end
    end
    lmr:setMapData(data, width, height)
    local w, h = lmr:getMapSize() ; lurek.log.info("map size = " .. w .. "x" .. h)
    lurek.log.info("tile at (12,12) = " .. lmr:getTile(12, 12)) ; lmr:setTile(12, 12, 99)
    lurek.log.info("after set = " .. lmr:getTile(12, 12))
end

--@api: LLargeMapRenderer:setCamera
do


    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local width, height = 40, 40
    local data = {}
    for y = 1, height do
        for x = 1, width do
            data[#data + 1] = ((x + y) % 1) + 1
        end
    end
    lmr:setMapData(data, width, height)
    lmr:setViewport(800, 600) ; lmr:setCamera(640, 640, 1.0)
    lurek.log.info("total chunks = " .. lmr:getTotalChunks())
    lurek.log.info("visible chunks = " .. lmr:getVisibleChunks())
end

--@api: LLargeMapRenderer:setViewport
do


    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local width, height = 40, 40
    local data = {}
    for y = 1, height do
        for x = 1, width do
            data[#data + 1] = ((x + y) % 1) + 1
        end
    end
    lmr:setMapData(data, width, height)
    lmr:setViewport(800, 600) ; lmr:setCamera(640, 640, 1.0)
    lurek.log.info("total chunks = " .. lmr:getTotalChunks())
    lurek.log.info("visible chunks = " .. lmr:getVisibleChunks())
end

--@api: LLargeMapRenderer:getVisibleChunks
do


    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local width, height = 40, 40
    local data = {}
    for y = 1, height do
        for x = 1, width do
            data[#data + 1] = ((x + y) % 1) + 1
        end
    end
    lmr:setMapData(data, width, height)
    lmr:setViewport(800, 600) ; lmr:setCamera(640, 640, 1.0)
    lurek.log.info("total chunks = " .. lmr:getTotalChunks())
    lurek.log.info("visible chunks = " .. lmr:getVisibleChunks())
end

--@api: LLargeMapRenderer:getTotalChunks
do


    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local width, height = 40, 40
    local data = {}
    for y = 1, height do
        for x = 1, width do
            data[#data + 1] = ((x + y) % 1) + 1
        end
    end
    lmr:setMapData(data, width, height)
    lmr:setViewport(800, 600) ; lmr:setCamera(640, 640, 1.0)
    lurek.log.info("total chunks = " .. lmr:getTotalChunks())
    lurek.log.info("visible chunks = " .. lmr:getVisibleChunks())
end

--@api: LLargeMapRenderer:setLodEnabled
do

    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16) ; lurek.log.info("LOD enabled = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodEnabled(true)
    lurek.log.info("after enable = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodThresholds({ 0.5, 0.25, 0.1 })
    lurek.log.info("LOD thresholds set")
end

--@api: LLargeMapRenderer:isLodEnabled
do

    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16) ; lurek.log.info("LOD enabled = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodEnabled(true)
    lurek.log.info("after enable = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodThresholds({ 0.5, 0.25, 0.1 })
    lurek.log.info("LOD thresholds set")
end

--@api: LLargeMapRenderer:setLodThresholds
do

    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16) ; lurek.log.info("LOD enabled = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodEnabled(true)
    lurek.log.info("after enable = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodThresholds({ 0.5, 0.25, 0.1 })
    lurek.log.info("LOD thresholds set")
end

--@api: LLargeMapRenderer:invalidateAll
do

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; lmr:setChunkSize(32)
    lurek.log.info("chunk size = " .. lmr:getChunkSize()) ; lmr:setTilesetColumns(16)
    lurek.log.info("tileset columns = " .. lmr:getTilesetColumns()) ; lmr:invalidateChunk(0, 0)
    lmr:invalidateAll()
    lurek.log.info("all chunks invalidated")
end

--@api: LLargeMapRenderer:invalidateChunk
do

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; lmr:setChunkSize(32)
    lurek.log.info("chunk size = " .. lmr:getChunkSize()) ; lmr:setTilesetColumns(16)
    lurek.log.info("tileset columns = " .. lmr:getTilesetColumns()) ; lmr:invalidateChunk(0, 0)
    lmr:invalidateAll()
    lurek.log.info("all chunks invalidated")
end

--@api: LLargeMapRenderer:setChunkSize
do

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; lmr:setChunkSize(32)
    lurek.log.info("chunk size = " .. lmr:getChunkSize()) ; lmr:setTilesetColumns(16)
    lurek.log.info("tileset columns = " .. lmr:getTilesetColumns()) ; lmr:invalidateChunk(0, 0)
    lmr:invalidateAll()
    lurek.log.info("all chunks invalidated")
end

--@api: LLargeMapRenderer:setTilesetColumns
do

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; lmr:setChunkSize(32)
    lurek.log.info("chunk size = " .. lmr:getChunkSize()) ; lmr:setTilesetColumns(16)
    lurek.log.info("tileset columns = " .. lmr:getTilesetColumns()) ; lmr:invalidateChunk(0, 0)
    lmr:invalidateAll()
    lurek.log.info("all chunks invalidated")
end

--- TileMap Part 4: getChunkSize, getTileDimensions, getTileHeight, getTileWidth, type, typeOf, iso/hex helpers

--@api: LTileMap:getChunkSize
do

    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local cs = tm:getChunkSize()
    local tw, th = tm:getTileDimensions()
    lurek.log.info("chunk_size=" .. cs)
    lurek.log.info("tile_dims=" .. tw .. "x" .. th)
end

--@api: LTileMap:getTileDimensions
do

    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local tw, th = tm:getTileDimensions()
    local chunk = tm:getChunkSize()
    lurek.log.info("tile_w=" .. tw .. " tile_h=" .. th)
    lurek.log.info("chunk_size=" .. chunk)
end

--@api: LTileMap:getTileHeight
do

    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local th2 = tm:getTileHeight()
    local tw2 = tm:getTileWidth()
    lurek.log.info("tile_height=" .. th2)
    lurek.log.info("tile_width=" .. tw2)
end

--@api: LTileMap:getTileWidth
do

    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local tw2 = tm:getTileWidth()
    local th2 = tm:getTileHeight()
    lurek.log.info("tile_width=" .. tw2)
    lurek.log.info("tile_height=" .. th2)
end

--@api: LTileMap:type
do

    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local tw, th = tm:getTileDimensions()
    lurek.log.info("type=" .. tm:type())
    lurek.log.info("tile_dims=" .. tw .. "x" .. th)
    lurek.log.info("chunk_size=" .. tm:getChunkSize())
end

--@api: LTileMap:typeOf
do

    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local is_map = tm:typeOf("LTileMap")
    local is_object = tm:typeOf("LObject")
    lurek.log.info("typeOf=" .. tostring(tm:typeOf("LTileMap")))
    lurek.log.info("as_map=" .. tostring(is_map))
    lurek.log.info("as_object=" .. tostring(is_object))
end

--@api: lurek.tilemap.fromScreenHex
do

    local tile_size = 32
    local hx, hy = lurek.tilemap.fromScreenHex(80, 40, tile_size)
    local sx, sy = lurek.tilemap.toScreenHex(hx, hy, tile_size)
    lurek.log.info("hex_x=" .. hx .. " hex_y=" .. hy)
    lurek.log.info("back_to_screen=" .. sx .. "," .. sy)
end

--@api: lurek.tilemap.fromScreenIso
do

    local tile_w, tile_h = 32, 16
    local ix, iy = lurek.tilemap.fromScreenIso(128, 64, tile_w, tile_h)
    local sx, sy = lurek.tilemap.toScreenIso(ix, iy, tile_w, tile_h)
    lurek.log.info("iso_x=" .. ix .. " iso_y=" .. iy)
    lurek.log.info("back_to_screen=" .. sx .. "," .. sy)
end



--- TileMap Part 5: LTileSet full coverage

--@api: lurek.tilemap.newTileSet.12
do

    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local count = ts:getTileCount()
    lurek.log.info("columns=" .. ts:getColumns())
    lurek.log.info("tileCount=" .. count)
    lurek.log.info("tileWidth=" .. ts:getTileWidth())
end

--@api: lurek.tilemap.newTileSet.13
do

    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local columns = ts:getColumns()
    lurek.log.info("firstGid=" .. ts:getFirstGid())
    lurek.log.info("columns=" .. columns)
    lurek.log.info("tileHeight=" .. ts:getTileHeight())
end

--@api: lurek.tilemap.newTileSet.14
do

    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local spacing = ts:getSpacing()
    local width = ts:getTileWidth()
    lurek.log.info("margin=" .. ts:getMargin())
    lurek.log.info("spacing=" .. spacing)
    lurek.log.info("tileWidth=" .. width)
end

--@api: lurek.tilemap.newTileSet.15
do

    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local margin = ts:getMargin()
    local height = ts:getTileHeight()
    lurek.log.info("spacing=" .. ts:getSpacing())
    lurek.log.info("margin=" .. margin)
    lurek.log.info("tileHeight=" .. height)
end

--@api: lurek.tilemap.newTileSet.16
do

    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local columns = ts:getColumns()
    local first_gid = ts:getFirstGid()
    lurek.log.info("tileCount=" .. ts:getTileCount())
    lurek.log.info("columns=" .. columns)
    lurek.log.info("firstGid=" .. first_gid)
end

--@api: lurek.tilemap.newTileSet.17
do

    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local tw, th = ts:getTileDimensions()
    local quad = ts:getQuad(1)
    lurek.log.info("tile_w=" .. tw .. " tile_h=" .. th)
    lurek.log.info("quad_w=" .. quad.width .. " quad_h=" .. quad.height)
end

--@api: lurek.tilemap.newTileSet.18
do

    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local tw = ts:getTileWidth()
    local count = ts:getTileCount()
    lurek.log.info("tileHeight=" .. ts:getTileHeight())
    lurek.log.info("tileWidth=" .. tw)
    lurek.log.info("tileCount=" .. count)
end

--@api: lurek.tilemap.newTileSet.19
do

    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local th = ts:getTileHeight()
    local count = ts:getTileCount()
    lurek.log.info("tileWidth=" .. ts:getTileWidth())
    lurek.log.info("tileHeight=" .. th)
    lurek.log.info("tileCount=" .. count)
end

--@api: lurek.tilemap.newTileSet.20
do

    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local count = ts:getTileCount()
    local columns = ts:getColumns()
    lurek.log.info("type=" .. ts:type())
    lurek.log.info("tileCount=" .. count)
    lurek.log.info("columns=" .. columns)
end

--@api: lurek.tilemap.newTileSet.21
do

    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local is_tileset = ts:typeOf("LTileSet")
    local is_object = ts:typeOf("LObject")
    lurek.log.info("typeOf=" .. tostring(ts:typeOf("LTileSet")))
    lurek.log.info("as_tileset=" .. tostring(is_tileset))
    lurek.log.info("as_object=" .. tostring(is_object))
end

--@api: LAutoTileSheet:getLayout
do

    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    local layout = sheet:getLayout()
    local count = sheet:getTileCount()
    lurek.log.info("layout:=" .. tostring(layout))
    lurek.log.info("tileCount:=" .. tostring(count))
    lurek.log.info("tileWidth:=" .. tostring(sheet:getTileWidth()))
end

--@api: LAutoTileSheet:getDefaultMode
do

    local sides = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")
    local rpg = lurek.tilemap.newAutoTileSheet(16, 16, "rpgmaker48")
    local sides_mode = sides:getDefaultMode()
    local rpg_mode = rpg:getDefaultMode()
    lurek.log.info("minimal16 mode:=" .. tostring(sides_mode))
    lurek.log.info("rpgmaker48 mode:=" .. tostring(rpg_mode))
end

--@api: LAutoTileSheet:getTileCount
do

    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    local count = sheet:getTileCount()
    local layout = sheet:getLayout()
    lurek.log.info("tileCount:=" .. tostring(count))
    lurek.log.info("layout:=" .. tostring(layout))
    lurek.log.info("tileHeight:=" .. tostring(sheet:getTileHeight()))
end

--@api: LAutoTileSheet:getTileHeight
do

    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    local h = sheet:getTileHeight()
    local w = sheet:getTileWidth()
    lurek.log.info("tileHeight:=" .. tostring(h))
    lurek.log.info("tileWidth:=" .. tostring(w))
    lurek.log.info("layout:=" .. tostring(sheet:getLayout()))
end

--@api: LAutoTileSheet:getTileWidth
do

    local sheet = lurek.tilemap.newAutoTileSheet(32, 32, "minimal16")
    local w = sheet:getTileWidth()
    local h = sheet:getTileHeight()
    lurek.log.info("tileWidth:=" .. tostring(w))
    lurek.log.info("tileHeight:=" .. tostring(h))
    lurek.log.info("tileCount:=" .. tostring(sheet:getTileCount()))
end

--@api: LAutoTileSheet:type
do

    local sheet = lurek.tilemap.newAutoTileSheet(32, 32, "minimal16")
    local t = sheet:type()
    local layout = sheet:getLayout()
    lurek.log.info("type:=" .. tostring(t))
    lurek.log.info("layout:=" .. tostring(layout))
    lurek.log.info("tileCount:=" .. tostring(sheet:getTileCount()))
end

--@api: LAutoTileSheet:typeOf
do

    local sheet = lurek.tilemap.newAutoTileSheet(32, 32, "minimal16")
    local ok = sheet:typeOf("LAutoTileSheet")
    local as_object = sheet:typeOf("LObject")
    lurek.log.info("typeOf=" .. tostring(ok))
    lurek.log.info("typeOfObject=" .. tostring(as_object))
    lurek.log.info("layout=" .. tostring(sheet:getLayout()))
end

--@api: LChunkMap:getChunkSize
do

    local cm = lurek.tilemap.newChunkMap(32)
    local sz = cm:getChunkSize()
    local loaded = cm:getLoadedChunks()
    lurek.log.info("chunkSize:=" .. tostring(sz))
    lurek.log.info("loadedChunks:=" .. tostring(#loaded))
end

--@api: LChunkMap:type
do

    local cm = lurek.tilemap.newChunkMap(32)
    local t = cm:type()
    local sz = cm:getChunkSize()
    lurek.log.info("type:=" .. tostring(t))
    lurek.log.info("chunkSize:=" .. tostring(sz))
    lurek.log.info("loadedChunks:=" .. tostring(#cm:getLoadedChunks()))
end

--@api: LChunkMap:typeOf
do

    local cm = lurek.tilemap.newChunkMap(32)
    local ok = cm:typeOf("LChunkMap")
    local as_object = cm:typeOf("LObject")
    lurek.log.info("typeOf=" .. tostring(ok))
    lurek.log.info("typeOfObject=" .. tostring(as_object))
    lurek.log.info("chunkSize=" .. tostring(cm:getChunkSize()))
end

--@api: LIsoMap:getHeight
do

    local iso = lurek.tilemap.newIsoMap(20, 15, 64, 32, 16, 4)
    local h = iso:getHeight()
    local w = iso:getWidth()
    lurek.log.info("isomap height:=" .. tostring(h))
    lurek.log.info("isomap width:=" .. tostring(w))
end

--@api: LIsoMap:getLevelHeight
do

    local iso = lurek.tilemap.newIsoMap(20, 15, 64, 32, 16, 4)
    local lh = iso:getLevelHeight()
    local parts = iso:getPartCount()
    lurek.log.info("levelHeight:=" .. tostring(lh))
    lurek.log.info("partCount:=" .. tostring(parts))
end

--@api: LIsoMap:getPartCount
do

    local iso = lurek.tilemap.newIsoMap(20, 15, 64, 32, 16, 4)
    local pc = iso:getPartCount()
    local lh = iso:getLevelHeight()
    lurek.log.info("partCount:=" .. tostring(pc))
    lurek.log.info("levelHeight:=" .. tostring(lh))
end

--@api: LIsoMap:getTileHeight
do

    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local th = iso:getTileHeight()
    local tw = iso:getTileWidth()
    lurek.log.info("tileHeight:=" .. tostring(th))
    lurek.log.info("tileWidth:=" .. tostring(tw))
end

--@api: LIsoMap:getTileWidth
do

    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local tw = iso:getTileWidth()
    local th = iso:getTileHeight()
    lurek.log.info("tileWidth:=" .. tostring(tw))
    lurek.log.info("tileHeight:=" .. tostring(th))
end

--@api: LIsoMap:getWidth
do

    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local w = iso:getWidth()
    local h = iso:getHeight()
    lurek.log.info("width:=" .. tostring(w))
    lurek.log.info("height:=" .. tostring(h))
end

--@api: LIsoMap:type
do

    local iso = lurek.tilemap.newIsoMap(8, 8, 32, 16, 8, 2)
    local t = iso:type()
    local w = iso:getWidth()
    lurek.log.info("type:=" .. tostring(t))
    lurek.log.info("width:=" .. tostring(w))
    lurek.log.info("parts:=" .. tostring(iso:getPartCount()))
end

--@api: LIsoMap:typeOf
do

    local iso = lurek.tilemap.newIsoMap(8, 8, 32, 16, 8, 2)
    local ok = iso:typeOf("LIsoMap")
    local as_object = iso:typeOf("LObject")
    lurek.log.info("typeOf=" .. tostring(ok))
    lurek.log.info("typeOfObject=" .. tostring(as_object))
    lurek.log.info("width=" .. tostring(iso:getWidth()))
end

--@api: LLargeMapRenderer:getChunkSize
do

    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
    local cs = lmr:getChunkSize()
    local cols = lmr:getTilesetColumns()
    lurek.log.info("chunkSize:=" .. tostring(cs))
    lurek.log.info("tilesetColumns:=" .. tostring(cols))
end

--@api: LLargeMapRenderer:getTilesetColumns
do

    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
    local cols = lmr:getTilesetColumns()
    local chunk = lmr:getChunkSize()
    lurek.log.info("tilesetColumns:=" .. tostring(cols))
    lurek.log.info("chunkSize:=" .. tostring(chunk))
end

--@api: LLargeMapRenderer:type
do

    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
    local t = lmr:type()
    local chunk = lmr:getChunkSize()
    lurek.log.info("type:=" .. tostring(t))
    lurek.log.info("chunkSize:=" .. tostring(chunk))
    lurek.log.info("tilesetColumns:=" .. tostring(lmr:getTilesetColumns()))
end

--@api: LLargeMapRenderer:typeOf
do

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local ok = lmr:typeOf("LLargeMapRenderer")
    local as_object = lmr:typeOf("LObject")
    lurek.log.info("typeOf:=" .. tostring(ok))
    lurek.log.info("typeOfObject:=" .. tostring(as_object))
    lurek.log.info("chunkSize:=" .. tostring(lmr:getChunkSize()))
end

--- Added coverage examples for newer API owners.

--@api: lurek.tilemap.fromProvider
do
    local provider = { tileWidth = 16, tileHeight = 16, layers = { { name = "ground", width = 2, height = 2, tiles = { 1, 2, 3, 4 } } } }
    local ok, value = pcall(function()
        local tm = lurek.tilemap.fromProvider(provider)
        return tm:getLayerCount()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileMap:renderFieldSlot
do
    local field = lurek.tilefield.new({ width = 2, height = 2 })
    field:setRef(1, 1, 1, "terrain", 1)
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    local tm = lurek.tilemap.newTileMap(16, 16)
    local ok, value = pcall(function()
        return tm:renderFieldSlot(field, tileset, { slot = "terrain", z = 1, refIsGid = true })
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileMap:renderFieldCatalogSlot
do
    local field = lurek.tilefield.new({ width = 2, height = 2 })
    field:setRef(1, 1, 1, "terrain", { tileset = "terrain", object = "grass" })
    local catalog = lurek.tileset.newCatalog({ terrain = lurek.tileset.newTileSet(1, 4, 2, 16, 16) })
    local tm = lurek.tilemap.newTileMap(16, 16)
    local ok, value = pcall(function()
        return tm:renderFieldCatalogSlot(field, catalog, { slot = "terrain", z = 1 })
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
