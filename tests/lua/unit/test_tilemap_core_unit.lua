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

local function new_mapblock()
    return lurek.tilemap.newMapBlock(4, 4, 1, 4)
end

local function new_mapgroup()
    return lurek.tilemap.newMapGroup("world")
end

local function new_mapscript()
    return lurek.tilemap.newMapScript()
end

local function new_large_map_renderer()
    return lurek.tilemap.newLargeMapRenderer(16, 16)
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

-- @describe lurek.tilemap module
describe("lurek.tilemap module", function()
    -- @covers lurek.tilemap.newTileSet
    it("newTileSet constructs a tileset", function()
        expect_equal("LTileSet", new_tileset():type())
    end)

    -- @covers lurek.tilemap.newTileMap
    it("newTileMap constructs a tile map", function()
        expect_equal("LTileMap", new_tilemap():type())
    end)

    -- @covers lurek.tilemap.newAutoTileSheet
    it("newAutoTileSheet constructs an autotile sheet", function()
        expect_equal("LAutoTileSheet", new_autotile_sheet():type())
    end)

    -- @covers lurek.tilemap.newChunkMap
    it("newChunkMap constructs a chunk map", function()
        expect_equal("LChunkMap", new_chunkmap():type())
    end)

    -- @covers lurek.tilemap.newIsoMap
    it("newIsoMap constructs an isometric map", function()
        expect_equal("LIsoMap", new_isomap():type())
    end)

    -- @covers lurek.tilemap.newMapBlock
    it("newMapBlock constructs a map block", function()
        expect_equal("LMapBlock", new_mapblock():type())
    end)

    -- @covers lurek.tilemap.newMapGroup
    it("newMapGroup constructs a map group", function()
        expect_equal("LMapGroup", new_mapgroup():type())
    end)

    -- @covers lurek.tilemap.newMapScript
    it("newMapScript constructs a map script", function()
        expect_equal("LMapScript", new_mapscript():type())
    end)

    -- @covers lurek.tilemap.newMapGen
    it("newMapGen constructs a generator from a group", function()
        local gen = lurek.tilemap.newMapGen(new_mapgroup(), "small", 4)
        expect_equal("LMapGen", gen:type())
    end)

    -- @covers lurek.tilemap.loadTMX
    it("loadTMX parses a minimal TMX document", function()
        local result, err = lurek.tilemap.loadTMX(MINIMAL_TMX)
        expect_not_nil(result)
        expect_nil(err)
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

    -- @covers lurek.tilemap.isoRotate
    it("isoRotate wraps around four directions", function()
        expect_equal(1, lurek.tilemap.isoRotate(4, 1))
    end)

    -- @covers lurek.tilemap.isoDirectionName
    it("isoDirectionName returns a direction label", function()
        expect_equal("north", lurek.tilemap.isoDirectionName(3))
    end)

    -- @covers lurek.tilemap.isoDirectionFromAngle
    it("isoDirectionFromAngle snaps to a valid direction", function()
        local dir = lurek.tilemap.isoDirectionFromAngle(0)
        expect_in_range(dir, 1, 4)
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

    -- @covers lurek.tilemap.hexDistance
    it("hexDistance is zero for the same cell", function()
        expect_equal(0, lurek.tilemap.hexDistance(2, 3, 2, 3))
    end)

    -- @covers lurek.tilemap.hexNeighbors
    it("hexNeighbors returns six neighbors", function()
        expect_equal(6, #lurek.tilemap.hexNeighbors(0, 0))
    end)

    -- @covers lurek.tilemap.hexLine
    it("hexLine includes both endpoints", function()
        expect_equal(3, #lurek.tilemap.hexLine(0, 0, 2, 0))
    end)

    -- @covers lurek.tilemap.hexRing
    it("hexRing of radius two has twelve cells", function()
        expect_equal(12, #lurek.tilemap.hexRing(0, 0, 2))
    end)

    -- @covers lurek.tilemap.hexSpiral
    it("hexSpiral at radius zero returns the center cell", function()
        expect_equal(1, #lurek.tilemap.hexSpiral(0, 0, 0))
    end)
end)

-- @describe LTileSet methods
describe("LTileSet methods", function()
    -- @covers LTileSet:getTileCount
    it("getTileCount returns the configured tile count", function()
        expect_equal(16, new_tileset():getTileCount())
    end)

    -- @covers LTileSet:getTileDimensions
    it("getTileDimensions returns width and height", function()
        local w, h = new_tileset():getTileDimensions()
        expect_equal(32, w)
        expect_equal(32, h)
    end)

    -- @covers LTileSet:setSolid
    it("setSolid marks a tile as solid", function()
        local ts = new_tileset()
        ts:setSolid(3, true)
        expect_true(ts:isSolid(3))
    end)

    -- @covers LTileSet:getAnimation
    it("getAnimation returns frames set by setAnimation", function()
        local ts = new_tileset()
        ts:setAnimation(2, {
            { tileid = 1, duration = 100 },
            { tileid = 2, duration = 200 },
        })
        local anim = ts:getAnimation(2)
        expect_not_nil(anim)
    end)

    -- @covers LTileSet:setAutoTileRule
    it("setAutoTileRule affects getAutoTileId", function()
        local ts = new_tileset()
        ts:setAutoTileRule("grass", 15, 3)
        expect_equal(3, ts:getAutoTileId("grass", 15))
    end)

    -- @covers LTileSet:typeOf
    it("typeOf recognizes LTileSet", function()
        local ts = new_tileset()
        expect_true(ts:typeOf("LTileSet"))
        expect_true(ts:typeOf("LObject"))
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

    -- @covers LTileMap:setLayerVisible
    it("setLayerVisible toggles layer visibility", function()
        local tm = new_tilemap()
        tm:addLayer("ground", 10, 10)
        tm:setLayerVisible(1, false)
        expect_false(tm:getLayerVisible(1))
    end)

    -- @covers LTileMap:setTile
    it("setTile writes a gid to a cell", function()
        local tm = new_tilemap()
        tm:addLayer("ground", 10, 10)
        tm:setTile(1, 2, 3, 7)
        expect_equal(7, tm:getTile(1, 2, 3))
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

    -- @covers LTileMap:setOrientation
    it("setOrientation updates map orientation", function()
        local tm = new_tilemap()
        tm:setOrientation("isometric")
        expect_equal("isometric", tm:getOrientation())
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

    -- @covers LTileMap:onTileStep
    it("onTileStep accepts a callback", function()
        local tm = new_tilemap()
        expect_no_error(function()
            tm:onTileStep(5, function() end)
        end)
    end)

    -- @covers LTileMap:fireTileStep
    it("fireTileStep invokes the registered callback", function()
        local tm = new_tilemap()
        local fired = false
        tm:onTileStep(5, function() fired = true end)
        tm:fireTileStep(5, { id = 1 }, 2, 3)
        expect_true(fired)
    end)
end)

-- @describe LAutoTileSheet methods
describe("LAutoTileSheet methods", function()
    -- @covers LAutoTileSheet:getLayout
    it("getLayout returns the chosen layout name", function()
        expect_equal("minimal16", new_autotile_sheet():getLayout())
    end)

    -- @covers LAutoTileSheet:getTileCount
    it("getTileCount reports at least one tile", function()
        expect_true(new_autotile_sheet():getTileCount() >= 1)
    end)

    -- @covers LAutoTileSheet:getTileForBitmask
    it("getTileForBitmask resolves a tile id", function()
        expect_true(new_autotile_sheet():getTileForBitmask(0) >= 1)
    end)

    -- @covers LAutoTileSheet:applyToTileSet
    it("applyToTileSet attaches rules to a tileset", function()
        local ts = new_tileset()
        new_autotile_sheet():applyToTileSet(ts, "terrain")
        expect_true(ts:getAutoTileId("terrain", 0) ~= nil)
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

    -- @covers LIsoMap:setTilePart
    it("setTilePart stores a tile part value", function()
        local iso = new_isomap()
        iso:addLevel()
        iso:setTilePart(1, 2, 3, lurek.tilemap.FLOOR, 11)
        expect_equal(11, iso:getTilePart(1, 2, 3, lurek.tilemap.FLOOR))
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

    -- @covers LIsoMap:tileToScreen
    it("tileToScreen returns numeric coordinates", function()
        local sx, sy = new_isomap():tileToScreen(2, 3, 0)
        expect_type("number", sx)
        expect_type("number", sy)
    end)
end)

-- @describe map generation helpers
describe("map generation helpers", function()
    -- @covers LMapBlock:setTile
    it("LMapBlock:setTile writes a gid into a block", function()
        local block = new_mapblock()
        block:setTile(1, 2, 2, 7)
        expect_equal(7, block:getTile(1, 2, 2))
    end)

    -- @covers LMapGroup:addBlock
    it("LMapGroup:addBlock increments the block count", function()
        local group = new_mapgroup()
        group:addBlock(new_mapblock())
        expect_equal(1, group:getBlockCount())
    end)

    -- @covers LMapScript:addStep
    it("LMapScript:addStep records a generation step", function()
        local script = new_mapscript()
        script:addStep({ type = "fillRect", layer = 1, x = 1, y = 1, w = 2, h = 2, gid = 1 })
        expect_equal(1, script:getStepCount())
    end)

    -- @covers LMapGen:generate
    it("LMapGen:generate returns a tilemap", function()
        local group = new_mapgroup()
        local block = new_mapblock()
        for y = 1, 4 do
            for x = 1, 4 do
                block:setTile(1, x, y, 1)
            end
        end
        group:addBlock(block)
        local gen = lurek.tilemap.newMapGen(group, "small", 4)
        local tm = gen:generate(nil, 42)
        expect_type("userdata", tm)
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

    -- @covers LLargeMapRenderer:setChunkSize
    it("setChunkSize updates chunk size", function()
        local lmr = new_large_map_renderer()
        lmr:setChunkSize(8)
        expect_equal(8, lmr:getChunkSize())
    end)

    -- @covers LLargeMapRenderer:setViewport
    it("setViewport accepts viewport dimensions", function()
        local lmr = new_large_map_renderer()
        expect_no_error(function() lmr:setViewport(640, 480) end)
    end)
end)

test_summary()
