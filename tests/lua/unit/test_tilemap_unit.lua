-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_tilemap_core_unit.lua
do
-- Lurek2D tilemap API owner tests.

local function new_tileset()
    return lurek.tilemap.newTileSet(1, 16, 4, 32, 32)
end

local function new_tilemap()
    return lurek.tilemap.newTileMap(32, 32, 8)
end

local function new_autotile_sheet()
    return lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")
end

local function new_chunkmap()
    return lurek.tilemap.newChunkMap(16)
end

local function new_isomap()
    return lurek.tilemap.newIsoMap(5, 5, 64, 32, 24)
end

local function new_large_map_renderer()
    return lurek.tilemap.newLargeMapRenderer(16, 16)
end

local function new_ready_tilemap()
    local tm = new_tilemap()
    tm:addLayer("ground", 10, 10)
    return tm
end

local function tilemap_shader()
    return lurek.render.newShader([[
@fragment
fn fs_main(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + uv.xyx * 0.0, color.a);
}
]], { target = "tilemap" })
end

local function new_ready_tileset()
    local ts = new_tileset()
    ts:setProfile(1, "blocked")
    ts:setProfile(2, "open")
    return ts
end

local LDTK_JSON = [[{
    "levels": [{
        "identifier": "Level_0",
        "pxWid": 64,
        "pxHei": 64,
        "layerInstances": [{
            "__type": "Tiles",
            "__identifier": "Ground",
            "__gridSize": 16,
            "gridTiles": [
                {"px":[0,0], "t":1},
                {"px":[16,0], "t":1},
                {"px":[32,0], "t":0},
                {"px":[48,0], "t":0}
            ]
        }]
    }]
}]]

local MINIMAL_TMX = [[<?xml version="1.0" encoding="UTF-8"?>
<map version="1.10" tiledversion="1.10.0" orientation="orthogonal"
     renderorder="right-down" width="2" height="2"
     tilewidth="32" tileheight="32" infinite="0" nextlayerid="2" nextobjectid="1">
 <tileset firstgid="1" name="ts" tilewidth="32" tileheight="32" tilecount="1" columns="1">
 </tileset>
 <layer id="1" name="Ground" width="2" height="2">
  <data encoding="csv">1,1,1,1</data>
 </layer>
</map>]]

local SHORT_LAYER_TMX = [[<?xml version="1.0" encoding="UTF-8"?>
<map version="1.10" tiledversion="1.10.0" orientation="orthogonal"
     renderorder="right-down" width="2" height="2"
     tilewidth="32" tileheight="32" infinite="0" nextlayerid="2" nextobjectid="1">
 <tileset firstgid="1" name="ts" tilewidth="32" tileheight="32" tilecount="1" columns="1">
 </tileset>
 <layer id="1" name="Ground" width="2" height="2">
  <data encoding="csv">1,1,1</data>
 </layer>
</map>]]

local LONG_LAYER_TMX = [[<?xml version="1.0" encoding="UTF-8"?>
<map version="1.10" tiledversion="1.10.0" orientation="orthogonal"
     renderorder="right-down" width="2" height="2"
     tilewidth="32" tileheight="32" infinite="0" nextlayerid="2" nextobjectid="1">
 <tileset firstgid="1" name="ts" tilewidth="32" tileheight="32" tilecount="1" columns="1">
 </tileset>
 <layer id="1" name="Ground" width="2" height="2">
  <data encoding="csv">1,1,1,1,1</data>
 </layer>
</map>]]

local EXTERNAL_TSX_TMX = [[<?xml version="1.0" encoding="UTF-8"?>
<map version="1.10" tiledversion="1.10.0" orientation="orthogonal"
     renderorder="right-down" width="2" height="2"
     tilewidth="32" tileheight="32" infinite="0" nextlayerid="2" nextobjectid="1">
 <tileset firstgid="1" source="terrain.tsx"/>
 <layer id="1" name="Ground" width="2" height="2">
  <data encoding="csv">1,1,1,1</data>
 </layer>
</map>]]

-- @describe lurek.tilemap module
describe("lurek.tilemap module", function()
    -- @covers lurek.tilemap.newTileSet
    it("newTileSet constructs a tileset", function()
        expect_equal("LTileSet", new_tileset():type())
    end)

    -- @covers lurek.tilemap.newTileMap
    it("newTileMap constructs a tile map and rejects zero tile dimensions", function()
        expect_equal("LTileMap", new_tilemap():type())
        local ok, err = pcall(function()
            return lurek.tilemap.newTileMap(0, 32, 8)
        end)
        expect_false(ok)
        expect_true(string.find(tostring(err), "tilemap tile size", 1, true) ~= nil)
    end)

    -- @covers lurek.tilemap.fromProvider
    it("fromProvider imports tile layers from provider data", function()
        local tm = lurek.tilemap.fromProvider({
            tileWidth = 16,
            tileHeight = 16,
            layers = {
                { name = "ground", width = 2, height = 2, tiles = { 1, 2, 3, 4 } },
            },
        })
        expect_equal("LTileMap", tm:type())
        expect_equal(1, tm:getLayerCount())
        expect_equal(3, tm:getTile(1, 1, 2))
    end)

    -- @covers lurek.tilemap.newAutoTileSheet
    it("newAutoTileSheet constructs an autotile sheet", function()
        expect_equal("LAutoTileSheet", new_autotile_sheet():type())
    end)

    -- @covers lurek.tilemap.getAutoTileFormats
    it("getAutoTileFormats lists supported autotile layouts", function()
        local formats = lurek.tilemap.getAutoTileFormats()
        local found_rpgmaker = false
        local found_minimal = false
        for _, format in ipairs(formats) do
            if format.name == "rpgmaker48" then
                found_rpgmaker = format.tileCount == 48 and format.mode == "matchCornersAndSides"
            end
            if format.name == "minimal16" then
                found_minimal = format.tileCount == 16 and format.mode == "matchSides"
            end
        end
        expect_true(found_rpgmaker)
        expect_true(found_minimal)
    end)

    -- @covers lurek.tilemap.newChunkMap
    it("newChunkMap constructs a chunk map and rejects zero chunk size", function()
        expect_equal("LChunkMap", new_chunkmap():type())
        local ok, err = pcall(function()
            return lurek.tilemap.newChunkMap(0)
        end)
        expect_false(ok)
        expect_true(string.find(tostring(err), "tilemap chunk size", 1, true) ~= nil)
    end)

    -- @covers lurek.tilemap.newIsoMap
    it("newIsoMap constructs an isometric map", function()
        expect_equal("LIsoMap", new_isomap():type())
    end)

    -- @covers lurek.tilemap.loadTMX
    it("loadTMX parses valid TMX and reports strict or policy failures", function()
        local result, err = lurek.tilemap.loadTMX(MINIMAL_TMX)
        expect_not_nil(result)
        expect_nil(err)

        local result, err = lurek.tilemap.loadTMX(SHORT_LAYER_TMX, { strictLayerSize = true })
        expect_nil(result)
        expect_equal("tmx_invalid_content", err.code)
        expect_contains(err.message, "length mismatch")

        result, err = lurek.tilemap.loadTMX(LONG_LAYER_TMX, { strictLayerSize = true })
        expect_nil(result)
        expect_equal("tmx_invalid_content", err.code)
        expect_contains(err.message, "length mismatch")

        local result, err = lurek.tilemap.loadTMX(EXTERNAL_TSX_TMX)
        expect_nil(result)
        expect_equal("tmx_invalid_content", err.code)
        expect_contains(err.message, "external TSX")
    end)

    -- @covers lurek.tilemap.fromLDtk
    it("fromLDtk builds a tilemap from valid JSON", function()
        local tm, err = lurek.tilemap.fromLDtk(LDTK_JSON)
        expect_type("userdata", tm)
        expect_nil(err)
    end)

    -- @covers lurek.tilemap.newLargeMapRenderer
    it("newLargeMapRenderer constructs a renderer", function()
        expect_not_nil(new_large_map_renderer())
    end)

end)

-- @describe tilemap coordinate helpers
describe("tilemap coordinate helpers", function()
    -- @covers lurek.tilemap.toScreenIso
    it("toScreenIso returns numeric screen coordinates", function()
        local sx, sy = lurek.tilemap.toScreenIso(1, 1, 32, 16)
        expect_type("number", sx)
        expect_type("number", sy)
    end)

    -- @covers lurek.tilemap.fromScreenIso
    it("fromScreenIso round-trips tile coordinates", function()
        local sx, sy = lurek.tilemap.toScreenIso(3, 5, 32, 16)
        local tx, ty = lurek.tilemap.fromScreenIso(sx, sy, 32, 16)
        expect_near(3, tx, 0.01)
        expect_near(5, ty, 0.01)
    end)




    -- @covers lurek.tilemap.toScreenHex
    it("toScreenHex returns numeric coordinates", function()
        local sx, sy = lurek.tilemap.toScreenHex(2, 3, 16)
        expect_type("number", sx)
        expect_type("number", sy)
    end)

    -- @covers lurek.tilemap.fromScreenHex
    it("fromScreenHex round-trips approximately", function()
        local sx, sy = lurek.tilemap.toScreenHex(2, 3, 16)
        local q, r = lurek.tilemap.fromScreenHex(sx, sy, 16)
        expect_near(2, q, 0.5)
        expect_near(3, r, 0.5)
    end)









end)

-- @describe LTileMap methods
describe("LTileMap methods", function()
    -- @covers LTileMap:addTileSet
    it("addTileSet increments the tileset count", function()
        local tm = new_tilemap()
        tm:addTileSet(new_tileset())
        expect_equal(1, tm:getTileSetCount())
    end)

    -- @covers LTileMap:getTileSetCount
    it("getTileSetCount returns how many tilesets are attached", function()
        local tm = new_tilemap()
        tm:addTileSet(new_tileset())
        tm:addTileSet(new_tileset())
        expect_equal(2, tm:getTileSetCount())
    end)

    -- @covers LTileMap:getTileSet
    it("getTileSet returns a previously added tileset", function()
        local tm = new_tilemap()
        local ts = new_tileset()
        tm:addTileSet(ts)
        expect_not_nil(tm:getTileSet(1))
    end)

    -- @covers LTileMap:addLayer
    it("addLayer increases the layer count", function()
        local tm = new_tilemap()
        tm:addLayer("ground", 10, 10)
        expect_equal(1, tm:getLayerCount())
    end)

    -- @covers LTileMap:tryAddLayer
    it("tryAddLayer returns an error instead of throwing when limits reject a layer", function()
        local tm = lurek.tilemap.newTileMap(32, 32, 8, { maxLayers = 1 })
        local idx, err = tm:tryAddLayer("ground", 2, 2)
        expect_equal(1, idx)
        expect_nil(err)

        idx, err = tm:tryAddLayer("props", 2, 2)
        expect_nil(idx)
        expect_contains(err, "exceeding limit")
    end)

    -- @covers LTileMap:getLayerCount
    it("getLayerCount returns the number of tile layers", function()
        local tm = new_tilemap()
        tm:addLayer("ground", 10, 10)
        tm:addLayer("props", 10, 10)
        expect_equal(2, tm:getLayerCount())
    end)

    -- @covers LTileMap:getLayerName
    it("getLayerName returns the configured layer name", function()
        local tm = new_tilemap()
        tm:addLayer("ground", 10, 10)
        expect_equal("ground", tm:getLayerName(1))
    end)

    -- @covers LTileMap:setLayerVisible
    it("setLayerVisible toggles layer visibility", function()
        local tm = new_tilemap()
        tm:addLayer("ground", 10, 10)
        tm:setLayerVisible(1, false)
        expect_false(tm:getLayerVisible(1))
    end)

    -- @covers LTileMap:getLayerVisible
    it("getLayerVisible reports whether a layer is visible", function()
        local tm = new_tilemap()
        tm:addLayer("ground", 10, 10)
        tm:setLayerVisible(1, false)
        expect_false(tm:getLayerVisible(1))
    end)

    -- @covers LTileMap:setLayerColor
    it("setLayerColor stores a layer tint", function()
        local tm = new_tilemap()
        tm:addLayer("ground", 10, 10)
        tm:setLayerColor(1, 0.8, 0.5, 0.5, 0.9)
        local r, g, b, a = tm:getLayerColor(1)
        expect_near(0.8, r, 1e-6)
        expect_near(0.9, a, 1e-6)
    end)

    -- @covers LTileMap:getLayerColor
    it("getLayerColor returns the stored layer tint", function()
        local tm = new_tilemap()
        tm:addLayer("ground", 10, 10)
        tm:setLayerColor(1, 0.8, 0.5, 0.5, 0.9)
        local r, g, b, a = tm:getLayerColor(1)
        expect_near(0.5, g, 1e-6)
        expect_near(0.5, b, 1e-6)
    end)

    -- @covers LTileMap:setLayerOffset
    it("setLayerOffset stores a per-layer draw offset", function()
        local tm = new_tilemap()
        tm:addLayer("ground", 10, 10)
        tm:setLayerOffset(1, 16, 8)
        local ox, oy = tm:getLayerOffset(1)
        expect_equal(16, ox)
        expect_equal(8, oy)
    end)

    -- @covers LTileMap:getLayerOffset
    it("getLayerOffset returns the configured layer offset", function()
        local tm = new_tilemap()
        tm:addLayer("ground", 10, 10)
        tm:setLayerOffset(1, 16, 8)
        local ox, oy = tm:getLayerOffset(1)
        expect_equal(16, ox)
        expect_equal(8, oy)
    end)

    -- @covers LTileMap:setLayerParallax
    it("setLayerParallax stores a parallax factor", function()
        local tm = new_tilemap()
        tm:addLayer("ground", 10, 10)
        tm:setLayerParallax(1, 0.5, 0.75)
        local px, py = tm:getLayerParallax(1)
        expect_near(0.5, px, 1e-6)
        expect_near(0.75, py, 1e-6)
    end)

    -- @covers LTileMap:getLayerParallax
    it("getLayerParallax returns the configured parallax factor", function()
        local tm = new_tilemap()
        tm:addLayer("ground", 10, 10)
        tm:setLayerParallax(1, 0.5, 0.75)
        local px, py = tm:getLayerParallax(1)
        expect_near(0.5, px, 1e-6)
        expect_near(0.75, py, 1e-6)
    end)

    -- @covers LTileMap:setTile
    it("setTile writes a gid to a cell", function()
        local tm = new_tilemap()
        tm:addLayer("ground", 10, 10)
        tm:setTile(1, 2, 3, 7)
        expect_equal(7, tm:getTile(1, 2, 3))
    end)

    -- @covers LTileMap:getTile
    it("getTile returns the gid stored at a cell", function()
        local tm = new_ready_tilemap()
        tm:setTile(1, 3, 4, 7)
        expect_equal(7, tm:getTile(1, 3, 4))
    end)

    -- @covers LTileMap:trySetTile
    it("trySetTile returns false and an error string for invalid coordinates", function()
        local tm = new_ready_tilemap()
        local ok, err = tm:trySetTile(1, 11, 1, 7)
        expect_false(ok)
        expect_contains(err, "out of bounds")
    end)

    -- @covers LTileMap:tryGetTile
    it("tryGetTile returns nil and an error string for invalid layers", function()
        local tm = new_ready_tilemap()
        local gid, err = tm:tryGetTile(2, 1, 1)
        expect_nil(gid)
        expect_contains(err, "out of range")
    end)

    -- @covers LTileMap:getDiagnostics
    it("getDiagnostics reports invalid coordinate and layer counters", function()
        local tm = new_ready_tilemap()
        tm:trySetTile(1, 11, 1, 7)
        tm:tryGetTile(2, 1, 1)
        local diagnostics = tm:getDiagnostics()
        expect_true(diagnostics.invalidCoord >= 1)
        expect_true(diagnostics.invalidLayer >= 1)
    end)

    -- @covers LTileMap:clearTile
    it("clearTile removes a gid from a cell", function()
        local tm = new_tilemap()
        tm:addLayer("ground", 10, 10)
        tm:setTile(1, 2, 3, 7)
        tm:clearTile(1, 2, 3)
        expect_equal(0, tm:getTile(1, 2, 3))
    end)

    -- @covers LTileMap:fill
    it("fill assigns one gid across a region", function()
        local tm = new_tilemap()
        tm:addLayer("ground", 5, 5)
        tm:fill(1, 9)
        expect_equal(9, tm:getTile(1, 2, 2))
    end)

    -- @covers LTileMap:setViewport
    it("setViewport updates viewport bounds", function()
        local tm = new_tilemap()
        tm:setViewport(10, 20, 320, 240)
        local x, y, w, h = tm:getViewport()
        expect_equal(10, x)
        expect_equal(240, h)
    end)

    -- @covers LTileMap:getViewport
    it("getViewport returns the configured viewport rectangle", function()
        local tm = new_tilemap()
        tm:setViewport(10, 20, 320, 240)
        local x, y, w, h = tm:getViewport()
        expect_equal(10, x)
        expect_equal(20, y)
        expect_equal(320, w)
        expect_equal(240, h)
    end)

    -- @covers LTileMap:update
    it("update advances tilemap animations without error", function()
        local tm = new_tilemap()
        expect_no_error(function()
            tm:update(1.0 / 60.0)
            tm:update(1.0 / 60.0)
        end)
    end)

    -- @covers LTileMap:tileToWorld
    it("tileToWorld converts tile coordinates to world space", function()
        local x, y = new_tilemap():tileToWorld(2, 3)
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers LTileMap:worldToTile
    it("worldToTile reverses tileToWorld", function()
        local tm = new_tilemap()
        local x, y = tm:tileToWorld(2, 3)
        local tx, ty = tm:worldToTile(x, y)
        expect_equal(2, tx)
        expect_equal(3, ty)
    end)

    -- @covers LTileMap:tryWorldToTile
    it("tryWorldToTile returns nil for negative coordinates", function()
        local tx, ty = new_tilemap():tryWorldToTile(-1, 0)
        expect_nil(tx)
        expect_nil(ty)
    end)

    -- @covers LTileMap:setOrientation
    it("setOrientation updates map orientation", function()
        local tm = new_tilemap()
        tm:setOrientation("isometric")
        expect_equal("isometric", tm:getOrientation())
    end)

    -- @covers LTileMap:getTileWidth
    it("getTileWidth returns the configured map tile width", function()
        expect_equal(32, new_tilemap():getTileWidth())
    end)

    -- @covers LTileMap:getTileHeight
    it("getTileHeight returns the configured map tile height", function()
        expect_equal(32, new_tilemap():getTileHeight())
    end)

    -- @covers LTileMap:getTileDimensions
    it("getTileDimensions returns the configured map tile size", function()
        local w, h = new_tilemap():getTileDimensions()
        expect_equal(32, w)
        expect_equal(32, h)
    end)

    -- @covers LTileMap:getChunkSize
    it("getChunkSize returns the configured storage chunk size", function()
        expect_equal(8, new_tilemap():getChunkSize())
    end)

    -- @covers LTileMap:applyAutoTile
    it("applyAutoTile does not error with a configured tileset", function()
        local tm = new_tilemap()
        local ts = new_tileset()
        ts:setAutoTileRule("grass", 15, 3)
        tm:addTileSet(ts)
        tm:addLayer("ground", 10, 10)
        expect_no_error(function() tm:applyAutoTile(1, "grass") end)
    end)

    -- @covers LTileMap:applyAutoTileAt
    it("applyAutoTileAt updates one autotile neighborhood without error", function()
        local tm = new_ready_tilemap()
        local ts = new_tileset()
        ts:setAutoTileRule("dirt", 0, 3)
        tm:addTileSet(ts)
        expect_no_error(function() tm:applyAutoTileAt(1, 5, 5, "dirt") end)
    end)

    -- @covers LTileMap:applyAutoTile8
    it("applyAutoTile8 applies 8-bit autotile rules without error", function()
        local tm = new_ready_tilemap()
        local ts = new_tileset()
        for i = 0, 255 do
            ts:setAutoTileRule8("wall", i, 1)
        end
        tm:addTileSet(ts)
        expect_no_error(function() tm:applyAutoTile8(1, "wall") end)
    end)

    -- @covers LTileMap:applyAutoTile8At
    it("applyAutoTile8At updates one 8-bit autotile neighborhood without error", function()
        local tm = new_ready_tilemap()
        local ts = new_tileset()
        for i = 0, 255 do
            ts:setAutoTileRule8("wall", i, 1)
        end
        tm:addTileSet(ts)
        expect_no_error(function() tm:applyAutoTile8At(1, 3, 3, "wall") end)
    end)

    -- @covers LTileMap:applyAutoTileMode
    it("applyAutoTileMode uses the tileset matching mode", function()
        local tm = new_ready_tilemap()
        local ts = new_tileset()
        ts:setAutoTileMode("stone", "matchCornersAndSides")
        ts:setAutoTileRule8("stone", 255, 8)
        tm:addTileSet(ts)
        for y = 4, 6 do
            for x = 4, 6 do
                tm:setTile(1, x, y, 1)
            end
        end
        tm:applyAutoTileMode(1, "stone")
        expect_equal(8, tm:getTile(1, 5, 5))
    end)

    -- @covers LTileMap:applyAutoTileModeAt
    it("applyAutoTileModeAt supports corner-only matching", function()
        local tm = new_ready_tilemap()
        local ts = new_tileset()
        ts:setAutoTileMode("corner", "matchCorners")
        ts:setAutoTileRule("corner", 15, 4)
        tm:addTileSet(ts)
        tm:setTile(1, 5, 5, 1)
        tm:setTile(1, 4, 4, 1)
        tm:setTile(1, 6, 4, 1)
        tm:setTile(1, 4, 6, 1)
        tm:setTile(1, 6, 6, 1)
        tm:applyAutoTileModeAt(1, 5, 5, "corner")
        expect_equal(4, tm:getTile(1, 5, 5))
    end)

    -- @covers LTileMap:tileTypeIndex
    it("tileTypeIndex groups layer positions by gid", function()
        local tm = new_ready_tilemap()
        tm:fill(1, 7)
        local index = tm:tileTypeIndex(1)
        expect_equal(100, #index[7])
        expect_equal(0, index[7][1].x)
    end)

    -- @covers LTileMap:findTilesByGid
    it("findTilesByGid returns every matching tile position and lazily rebuilds the reverse index", function()
        local tm = new_ready_tilemap()
        tm:fill(1, 7)
        local before = tm:getDiagnostics()
        local positions = tm:findTilesByGid(1, 7)
        local after = tm:getDiagnostics()
        expect_equal(100, #positions)
        expect_equal(0, positions[1].x)
        expect_true(after.lazyIndexRebuilds >= before.lazyIndexRebuilds + 1)
    end)

    -- @covers LTileMap:getOrientation
    it("getOrientation returns the current map orientation", function()
        local tm = new_tilemap()
        tm:setOrientation("hexagonal")
        expect_equal("hexagonal", tm:getOrientation())
    end)

    -- @covers LTileMap:setTileTint
    it("setTileTint accepts a per-cell tint override", function()
        local tm = new_ready_tilemap()
        expect_no_error(function()
            tm:setTileTint(1, 1, 1, 1.0, 0.0, 0.0, 1.0)
        end)
    end)

    -- @covers LTileMap:trySetTileTint
    it("trySetTileTint returns false and an error string for invalid cells", function()
        local tm = new_ready_tilemap()
        local ok, err = tm:trySetTileTint(1, 99, 99, 1.0, 0.0, 0.0, 1.0)
        expect_equal(false, ok)
        expect_type("string", err)
    end)

    -- @covers LTileMap:setShader
    it("setShader binds tilemap shaders and rejects wrong targets", function()
        local tm = new_ready_tilemap()
        local shader = tilemap_shader()
        tm:setShader(shader)
        expect_equal("tilemap", tm:getShader():getTarget())
        tm:setShader(nil)
        expect_equal(nil, tm:getShader())
        expect_error(function()
            tm:setShader(lurek.render.newShader([[
@fragment
fn fs_main(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> {
    return color;
}
]], { target = "draw" }))
        end)
    end)

    -- @covers LTileMap:getShader
    it("getShader returns the tilemap shader handle", function()
        local tm = new_ready_tilemap()
        local shader = tilemap_shader()
        tm:setShader(shader)
        expect_equal(shader:getId(), tm:getShader():getId())
    end)

    -- @covers LTileMap:setLayerShader
    it("setLayerShader binds and clears one layer shader override", function()
        local tm = new_ready_tilemap()
        local shader = tilemap_shader()
        tm:setLayerShader(1, shader)
        expect_equal("tilemap", tm:getLayerShader(1):getTarget())
        tm:setLayerShader(1, nil)
        expect_equal(nil, tm:getLayerShader(1))
        expect_error(function()
            tm:setLayerShader(99, shader)
        end)
    end)

    -- @covers LTileMap:getLayerShader
    it("getLayerShader rejects invalid one-based layer indices", function()
        local tm = new_ready_tilemap()
        expect_error(function()
            tm:getLayerShader(0)
        end)
    end)

    -- @covers LTileMap:renderFieldCatalogSlot
    it("renders typed tilefield refs through a tileset catalog", function()
        local field = lurek.tilefield.new({ width = 2, height = 2 })
        field:setRef(1, 1, 1, "object", { tileset = "objects", object = "crate" })
        local tileset = lurek.tileset.fromProvider({
            tileCount = 2,
            columns = 1,
            tileWidth = 16,
            tileHeight = 16,
            objects = {
                crate = {
                    slot = "object",
                    visual = { order = 3 },
                },
            },
        })
        local catalog = lurek.tileset.newCatalog({ objects = tileset })
        local tm = new_tilemap()
        expect_no_error(function()
            tm:renderFieldCatalogSlot(field, catalog, { slot = "object", z = 1 })
        end)
    end)

    -- @covers LTileMap:renderFieldSlot
    it("renders tilefield refs through a tileset", function()
        local field = lurek.tilefield.new({ width = 2, height = 2 })
        field:setRef(1, 1, 1, "object", 1)
        local tileset = lurek.tileset.fromProvider({
            firstGid = 1,
            tileCount = 2,
            columns = 1,
            tileWidth = 16,
            tileHeight = 16,
            objects = {
                crate = {
                    slot = "object",
                    tileId = 1,
                    visual = { order = 3 },
                },
            },
            tileObjects = { [1] = "crate" },
        })
        local tm = new_tilemap()
        expect_no_error(function()
            tm:renderFieldSlot(field, tileset, { slot = "object", z = 1, refIsGid = true })
        end)
    end)

    -- @covers LTileMap:type
    it("type returns LTileMap", function()
        expect_equal("LTileMap", new_tilemap():type())
    end)

    -- @covers LTileMap:typeOf
    it("typeOf recognizes LTileMap", function()
        local tm = new_tilemap()
        expect_true(tm:typeOf("LTileMap"))
        expect_true(tm:typeOf("LObject"))
    end)
end)

-- @describe LAutoTileSheet methods
describe("LAutoTileSheet methods", function()
    -- @covers LAutoTileSheet:getLayout
    it("getLayout returns the chosen layout name", function()
        expect_equal("minimal16", new_autotile_sheet():getLayout())
        expect_equal("rpgmaker48", lurek.tilemap.newAutoTileSheet(16, 16, "rpgmaker48"):getLayout())
    end)

    -- @covers LAutoTileSheet:getDefaultMode
    it("getDefaultMode reports the layout matching mode", function()
        expect_equal("matchSides", new_autotile_sheet():getDefaultMode())
        expect_equal(
            "matchCornersAndSides",
            lurek.tilemap.newAutoTileSheet(16, 16, "rpgmaker48"):getDefaultMode()
        )
    end)

    -- @covers LAutoTileSheet:getTileCount
    it("getTileCount reports at least one tile", function()
        expect_true(new_autotile_sheet():getTileCount() >= 1)
    end)

    -- @covers LAutoTileSheet:getTileWidth
    it("getTileWidth returns the configured autotile width", function()
        expect_equal(16, new_autotile_sheet():getTileWidth())
    end)

    -- @covers LAutoTileSheet:getTileHeight
    it("getTileHeight returns the configured autotile height", function()
        expect_equal(16, new_autotile_sheet():getTileHeight())
    end)

    -- @covers LAutoTileSheet:getBitmaskForTile
    it("getBitmaskForTile resolves a bitmask for a known tile", function()
        expect_not_nil(new_autotile_sheet():getBitmaskForTile(1))
    end)

    -- @covers LAutoTileSheet:getTileForBitmask
    it("getTileForBitmask resolves a tile id", function()
        expect_true(new_autotile_sheet():getTileForBitmask(0) >= 1)
    end)

    -- @covers LAutoTileSheet:getQuad
    it("getQuad returns the autotile source rectangle", function()
        local x, y, w, h = new_autotile_sheet():getQuad(1)
        expect_equal(16, w)
        expect_equal(16, h)
    end)

    -- @covers LAutoTileSheet:applyToTileSet
    it("applyToTileSet attaches rules to a tileset", function()
        local ts = new_tileset()
        new_autotile_sheet():applyToTileSet(ts, "terrain")
        expect_true(ts:getAutoTileId("terrain", 0) ~= nil)
    end)

    -- @covers LAutoTileSheet:type
    it("type returns LAutoTileSheet", function()
        expect_equal("LAutoTileSheet", new_autotile_sheet():type())
    end)

    -- @covers LAutoTileSheet:typeOf
    it("typeOf recognizes LAutoTileSheet", function()
        local sheet = new_autotile_sheet()
        expect_true(sheet:typeOf("LAutoTileSheet"))
        expect_true(sheet:typeOf("LObject"))
    end)
end)

-- @describe LChunkMap methods
describe("LChunkMap methods", function()
    -- @covers LChunkMap:getChunkSize
    it("getChunkSize returns the configured chunk size", function()
        expect_equal(16, new_chunkmap():getChunkSize())
    end)

    -- @covers LChunkMap:setTile
    it("setTile writes a tile value", function()
        local cm = new_chunkmap()
        cm:setTile(2, 3, 9)
        expect_equal(9, cm:getTile(2, 3))
    end)

    -- @covers LChunkMap:getTile
    it("getTile returns a previously written tile value", function()
        local cm = new_chunkmap()
        cm:setTile(10, 20, 9)
        expect_equal(9, cm:getTile(10, 20))
    end)

    -- @covers LChunkMap:fillRect
    it("fillRect writes across a rectangle", function()
        local cm = new_chunkmap()
        cm:fillRect(0, 0, 2, 2, 5)
        expect_equal(5, cm:getTile(1, 1))
    end)

    -- @covers LChunkMap:clearTile
    it("clearTile resets one cell", function()
        local cm = new_chunkmap()
        cm:setTile(1, 1, 7)
        cm:clearTile(1, 1)
        expect_equal(0, cm:getTile(1, 1))
    end)

    -- @covers LChunkMap:loadChunk
    it("loadChunk adds a chunk to the loaded set", function()
        local cm = new_chunkmap()
        cm:loadChunk(0, 0)
        expect_equal(1, #cm:getLoadedChunks())
    end)

    -- @covers LChunkMap:unloadChunk
    it("unloadChunk removes a chunk from the loaded set", function()
        local cm = new_chunkmap()
        cm:loadChunk(0, 0)
        cm:unloadChunk(0, 0)
        expect_equal(0, #cm:getLoadedChunks())
    end)

    -- @covers LChunkMap:getLoadedChunks
    it("getLoadedChunks returns loaded chunk coordinates", function()
        local cm = new_chunkmap()
        cm:loadChunk(0, 0)
        local chunks = cm:getLoadedChunks()
        expect_equal(1, #chunks)
        expect_equal(0, chunks[1].cx)
        expect_equal(0, chunks[1].cy)
    end)

    -- @covers LChunkMap:getChunksInView
    it("getChunksInView returns chunks covering a viewport", function()
        local cm = new_chunkmap()
        local chunks = cm:getChunksInView(0, 0, 64, 64, 16, 16)
        expect_true(#chunks >= 1)
    end)

    -- @covers LChunkMap:chunkTileRange
    it("chunkTileRange returns the covered tile span for a chunk", function()
        local cm = new_chunkmap()
        local x0, y0, x1, y1 = cm:chunkTileRange(0, 0)
        expect_equal(0, x0)
        expect_equal(0, y0)
        expect_equal(16, x1)
        expect_equal(16, y1)
    end)

    -- @covers LChunkMap:setTiles
    -- @covers LChunkMap:getDirtyChunks
    it("setTiles applies a batch and reports dirty chunks", function()
        local cm = lurek.tilemap.newChunkMap(4)
        local dirty = cm:setTiles({
            { x = 0, y = 0, gid = 2 },
            { 4, 0, 3 },
            { -1, -1, 4 },
        })

        expect_equal(2, cm:getTile(0, 0))
        expect_equal(3, cm:getTile(4, 0))
        expect_equal(4, cm:getTile(-1, -1))
        expect_equal(3, #dirty)
        expect_equal(3, #cm:getDirtyChunks())
    end)

    -- @covers LChunkMap:drainDirtyChunks
    -- @covers LChunkMap:clearDirtyChunks
    it("drainDirtyChunks and clearDirtyChunks manage pending chunks", function()
        local cm = lurek.tilemap.newChunkMap(4)
        cm:setTile(0, 0, 1)
        expect_equal(1, #cm:drainDirtyChunks())
        expect_equal(0, #cm:getDirtyChunks())
        cm:setTile(5, 0, 2)
        cm:clearDirtyChunks()
        expect_equal(0, #cm:getDirtyChunks())
    end)

    -- @covers LChunkMap:chunkToBytes
    -- @covers LChunkMap:loadChunkFromBytes
    it("chunk bytes roundtrip one chunk", function()
        local cm = lurek.tilemap.newChunkMap(4)
        cm:setTile(1, 2, 9)
        local bytes = cm:chunkToBytes(0, 0)
        expect_type("string", bytes)

        local clone = lurek.tilemap.newChunkMap(4)
        clone:loadChunkFromBytes(2, -1, bytes)
        expect_equal(9, clone:getTile(9, -2))
        expect_equal(1, #clone:getDirtyChunks())
    end)

    -- @covers LChunkMap:type
    it("type returns LChunkMap", function()
        expect_equal("LChunkMap", new_chunkmap():type())
    end)

    -- @covers LChunkMap:typeOf
    it("typeOf recognizes LChunkMap", function()
        local cm = new_chunkmap()
        expect_true(cm:typeOf("LChunkMap"))
        expect_true(cm:typeOf("LObject"))
    end)
end)

-- @describe LIsoMap methods
describe("LIsoMap methods", function()
    -- @covers LIsoMap:addLevel
    it("addLevel increments the level count", function()
        local iso = new_isomap()
        local before = iso:getLevelCount()
        iso:addLevel()
        expect_equal(before + 1, iso:getLevelCount())
    end)

    -- @covers LIsoMap:getLevelCount
    it("getLevelCount returns the number of levels", function()
        local iso = new_isomap()
        iso:addLevel()
        expect_equal(1, iso:getLevelCount())
    end)

    -- @covers LIsoMap:setTilePart
    it("setTilePart stores a tile part value", function()
        local iso = new_isomap()
        iso:addLevel()
        local floor_part = 1
        iso:setTilePart(1, 2, 3, floor_part, 11)
        expect_equal(11, iso:getTilePart(1, 2, 3, floor_part))
    end)

    -- @covers LIsoMap:getTilePart
    it("getTilePart returns the stored tile part gid", function()
        local iso = new_isomap()
        iso:addLevel()
        iso:setTilePart(1, 3, 4, 1, 12)
        expect_equal(12, iso:getTilePart(1, 3, 4, 1))
    end)

    -- @covers LIsoMap:fillLevel
    it("fillLevel writes one gid across a whole level part", function()
        local iso = new_isomap()
        iso:addLevel()
        local floor_part = 1
        iso:fillLevel(1, floor_part, 9)
        expect_equal(9, iso:getTilePart(1, 2, 2, floor_part))
    end)

    -- @covers LIsoMap:setLevelVisible
    it("setLevelVisible toggles per-level visibility", function()
        local iso = new_isomap()
        iso:addLevel()
        iso:setLevelVisible(1, false)
        expect_false(iso:isLevelVisible(1))
    end)

    -- @covers LIsoMap:isLevelVisible
    it("isLevelVisible reports whether a level is visible", function()
        local iso = new_isomap()
        iso:addLevel()
        iso:setLevelVisible(1, false)
        expect_false(iso:isLevelVisible(1))
    end)

    -- @covers LIsoMap:getPartCount
    it("getPartCount returns the configured part count", function()
        expect_true(new_isomap():getPartCount() >= 4)
    end)

    -- @covers LIsoMap:setPartOrder
    it("setPartOrder updates part ordering", function()
        local iso = new_isomap()
        iso:setPartOrder({3, 2, 1, 0})
        local order = iso:getPartOrder()
        expect_equal(3, order[1])
    end)

    -- @covers LIsoMap:setOrigin
    it("setOrigin changes the screen-space anchor used by projections", function()
        local iso = new_isomap()
        local sx1, sy1 = iso:tileToScreen(2, 3, 0)
        iso:setOrigin(50, 25)
        local sx2, sy2 = iso:tileToScreen(2, 3, 0)
        expect_true(sx2 ~= sx1 or sy2 ~= sy1)
    end)

    -- @covers LIsoMap:tileToScreen
    it("tileToScreen returns numeric coordinates", function()
        local sx, sy = new_isomap():tileToScreen(2, 3, 0)
        expect_type("number", sx)
        expect_type("number", sy)
    end)

    -- @covers LIsoMap:getWidth
    it("getWidth returns the configured map width", function()
        expect_equal(5, new_isomap():getWidth())
    end)

    -- @covers LIsoMap:getHeight
    it("getHeight returns the configured map height", function()
        expect_equal(5, new_isomap():getHeight())
    end)

    -- @covers LIsoMap:getTileWidth
    it("getTileWidth returns the configured isometric tile width", function()
        expect_equal(64, new_isomap():getTileWidth())
    end)

    -- @covers LIsoMap:getTileHeight
    it("getTileHeight returns the configured isometric tile height", function()
        expect_equal(32, new_isomap():getTileHeight())
    end)

    -- @covers LIsoMap:getLevelHeight
    it("getLevelHeight returns the configured per-level vertical offset", function()
        expect_equal(24, new_isomap():getLevelHeight())
    end)

    -- @covers LIsoMap:screenToTile
    it("screenToTile approximately reverses tileToScreen", function()
        local iso = new_isomap()
        local sx, sy = iso:tileToScreen(2, 3, 0)
        local tx, ty = iso:screenToTile(sx, sy)
        expect_near(2, tx, 0.5)
        expect_near(3, ty, 0.5)
    end)

    -- @covers LIsoMap:getPartOrder
    it("getPartOrder returns the current draw order of tile parts", function()
        local iso = new_isomap()
        local order = iso:getPartOrder()
        expect_true(#order >= 4)
    end)

    -- @covers LIsoMap:type
    it("type returns LIsoMap", function()
        expect_equal("LIsoMap", new_isomap():type())
    end)

    -- @covers LIsoMap:typeOf
    it("typeOf recognizes LIsoMap", function()
        local iso = new_isomap()
        expect_true(iso:typeOf("LIsoMap"))
        expect_true(iso:typeOf("LObject"))
    end)
end)

-- @describe LLargeMapRenderer methods
describe("LLargeMapRenderer methods", function()
    -- @covers LLargeMapRenderer:setMapData
    it("setMapData stores width and height", function()
        local lmr = new_large_map_renderer()
        lmr:setMapData({0, 1, 0, 1}, 2, 2)
        local w, h = lmr:getMapSize()
        expect_equal(2, w)
        expect_equal(2, h)
    end)

    -- @covers LLargeMapRenderer:setTile
    it("setTile updates a tile in the renderer map", function()
        local lmr = new_large_map_renderer()
        lmr:setMapData({0, 0, 0, 0}, 2, 2)
        lmr:setTile(0, 0, 42)
        expect_equal(42, lmr:getTile(0, 0))
    end)

    -- @covers LLargeMapRenderer:getTile
    it("getTile returns a stored renderer tile value", function()
        local lmr = new_large_map_renderer()
        lmr:setMapData({7, 0, 0, 0}, 2, 2)
        expect_equal(7, lmr:getTile(0, 0))
    end)

    -- @covers LLargeMapRenderer:getMapSize
    it("getMapSize returns the configured renderer dimensions", function()
        local lmr = new_large_map_renderer()
        lmr:setMapData({0, 1, 0, 1}, 2, 2)
        local w, h = lmr:getMapSize()
        expect_equal(2, w)
        expect_equal(2, h)
    end)

    -- @covers LLargeMapRenderer:setChunkSize
    it("setChunkSize updates chunk size", function()
        local lmr = new_large_map_renderer()
        lmr:setChunkSize(8)
        expect_equal(8, lmr:getChunkSize())
    end)

    -- @covers LLargeMapRenderer:getChunkSize
    it("getChunkSize returns the renderer chunk size", function()
        local lmr = new_large_map_renderer()
        lmr:setChunkSize(8)
        expect_equal(8, lmr:getChunkSize())
    end)

    -- @covers LLargeMapRenderer:invalidateChunk
    it("invalidateChunk accepts a chunk coordinate without error", function()
        local lmr = new_large_map_renderer()
        expect_no_error(function() lmr:invalidateChunk(0, 0) end)
    end)

    -- @covers LLargeMapRenderer:invalidateAll
    it("invalidateAll accepts a full renderer invalidation without error", function()
        local lmr = new_large_map_renderer()
        expect_no_error(function() lmr:invalidateAll() end)
    end)

    -- @covers LLargeMapRenderer:setViewport
    it("setViewport accepts viewport dimensions", function()
        local lmr = new_large_map_renderer()
        expect_no_error(function() lmr:setViewport(640, 480) end)
    end)

    -- @covers LLargeMapRenderer:getVisibleChunks
    it("getVisibleChunks returns a numeric count after viewport setup", function()
        local lmr = new_large_map_renderer()
        lmr:setMapData({0, 0, 0, 0}, 2, 2)
        lmr:setViewport(640, 480)
        lmr:setCamera(0, 0, 1.0)
        expect_type("number", lmr:getVisibleChunks())
    end)

    -- @covers LLargeMapRenderer:getTotalChunks
    it("getTotalChunks returns a positive chunk count for loaded data", function()
        local lmr = new_large_map_renderer()
        lmr:setMapData({0, 0, 0, 0}, 2, 2)
        expect_equal(1, lmr:getTotalChunks())
    end)

    -- @covers LLargeMapRenderer:setCamera
    it("setCamera accepts a camera transform without error", function()
        local lmr = new_large_map_renderer()
        expect_no_error(function() lmr:setCamera(32, 32, 1.0) end)
    end)

    -- @covers LLargeMapRenderer:setLodEnabled
    it("setLodEnabled toggles the lod flag", function()
        local lmr = new_large_map_renderer()
        lmr:setLodEnabled(false)
        expect_false(lmr:isLodEnabled())
    end)

    -- @covers LLargeMapRenderer:isLodEnabled
    it("isLodEnabled reports the current lod flag", function()
        local lmr = new_large_map_renderer()
        lmr:setLodEnabled(false)
        expect_false(lmr:isLodEnabled())
    end)

    -- @covers LLargeMapRenderer:setLodThresholds
    it("setLodThresholds accepts threshold arrays without error", function()
        local lmr = new_large_map_renderer()
        expect_no_error(function() lmr:setLodThresholds({0.5, 1.0, 2.0}) end)
    end)

    -- @covers LLargeMapRenderer:setTilesetColumns
    it("setTilesetColumns stores the atlas column count", function()
        local lmr = new_large_map_renderer()
        lmr:setTilesetColumns(16)
        expect_equal(16, lmr:getTilesetColumns())
    end)

    -- @covers LLargeMapRenderer:getTilesetColumns
    it("getTilesetColumns returns the configured atlas column count", function()
        local lmr = new_large_map_renderer()
        lmr:setTilesetColumns(16)
        expect_equal(16, lmr:getTilesetColumns())
    end)

    -- @covers LLargeMapRenderer:type
    it("type returns LLargeMapRenderer", function()
        expect_equal("LLargeMapRenderer", new_large_map_renderer():type())
    end)

    -- @covers LLargeMapRenderer:typeOf
    it("typeOf recognizes LLargeMapRenderer", function()
        local lmr = new_large_map_renderer()
        expect_true(lmr:typeOf("LLargeMapRenderer"))
        expect_true(lmr:typeOf("LObject"))
    end)
end)

end
-- END test_tilemap_core_unit.lua

test_summary()
