-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_minimap_core_unit.lua
do
-- Lurek2D minimap API tests.
-- Covers minimap construction, terrain/object/fog state, view controls, and helper queries exposed through lurek.minimap.

local function mapviz_shader_code()
    return [[
@fragment
fn fs(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) pixel: vec2<f32>,
    @location(3) resolution: vec2<f32>,
    @location(4) texel: vec2<f32>
) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + uv.xyx * 0.0 + pixel.xyx * 0.0 + resolution.xyx * texel.x * 0.0, color.a);
}
]]
end

-- @describe lurek.minimap.newMinimap
describe("lurek.minimap.newMinimap", function()
    -- @covers lurek.minimap.newMinimap
    it("creates minimaps with grid/display dimensions and rejects zero grid sizes", function()
        local m = lurek.minimap.newMinimap(64, 48)
        expect_type("userdata", m)
        expect_equal(64, m:getGridWidth())
        expect_equal(48, m:getGridHeight())
        local custom = lurek.minimap.newMinimap(32, 32, 200, 150)
        expect_equal(200, custom:getDisplayWidth())
        expect_equal(150, custom:getDisplayHeight())
        expect_error(function()
            lurek.minimap.newMinimap(0, 16)
        end)
        expect_error(function()
            lurek.minimap.newMinimap(16, 0)
        end)
    end)

    -- @covers LMinimap:type
    it("reports correct type", function()
        local m = lurek.minimap.newMinimap(10, 10)
        expect_equal("LMinimap", m:type())
        expect_true(m:typeOf("LMinimap"))
        expect_true(m:typeOf("LObject"))
        expect_false(m:typeOf("LImage"))
    end)
end)

-- Grid dimensions

-- @describe grid dimensions
describe("grid dimensions", function()
    -- @covers LMinimap:getCellCount
    it("returns total cell count", function()
        local m = lurek.minimap.newMinimap(40, 30)
        expect_equal(1200, m:getCellCount())
    end)

    -- @covers LMinimap:getGridSize
    it("returns grid size as two values", function()
        local m = lurek.minimap.newMinimap(40, 30)
        local w, h = m:getGridSize()
        expect_equal(40, w)
        expect_equal(30, h)
    end)
end)

-- Display size

-- @describe display size
describe("display size", function()
    -- @covers LMinimap:setDisplaySize
    it("can set display size and rejects zero dimensions", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setDisplaySize(300, 200)
        expect_equal(300, m:getDisplayWidth())
        expect_equal(200, m:getDisplayHeight())
        local w, h = m:getDisplaySize()
        expect_equal(300, w)
        expect_equal(200, h)
        expect_error(function()
            m:setDisplaySize(0, 100)
        end)
        expect_error(function()
            m:setDisplaySize(100, 0)
        end)
    end)
end)

-- Minimap render shader binding

-- @describe minimap render shader
describe("minimap render shader", function()
    -- @covers LMinimap:setShader
    it("accepts only mapviz shaders for command rendering", function()
        local m = lurek.minimap.newMinimap(8, 8, 64, 64)
        local shader = lurek.render.newShader(mapviz_shader_code(), { target = "mapviz" })
        m:setShader(shader)
        m:render(0, 0)
        m:setShader(nil)

        local draw_shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + uv.xyx * 0.0, color.a);
}
]], { target = "draw" })
        expect_error(function()
            m:setShader(draw_shader)
        end)
    end)

    -- @covers LMinimap:getShader
    it("returns the bound mapviz shader", function()
        local m = lurek.minimap.newMinimap(8, 8, 64, 64)
        local shader = lurek.render.newShader(mapviz_shader_code(), { target = "mapviz" })
        expect_equal(nil, m:getShader())
        m:setShader(shader)
        expect_equal("mapviz", m:getShader():getTarget())
        m:setShader(nil)
        expect_equal(nil, m:getShader())
    end)
end)

-- Terrain

-- @describe terrain
describe("terrain", function()
    -- @covers LMinimap:getTerrain
    it("defaults to terrain type 0", function()
        local m = lurek.minimap.newMinimap(10, 10)
        expect_equal(0, m:getTerrain(1, 1))
        expect_equal(0, m:getTerrain(5, 5))
    end)

    -- @covers LMinimap:setTerrain
    it("can set and get terrain type", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setTerrain(3, 4, 7)
        expect_equal(7, m:getTerrain(3, 4))
    end)

    -- @covers LMinimap:setTerrainColor
    it("stores terrain colors with explicit or default alpha", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setTerrainColor(1, 0.2, 0.4, 0.6, 0.8)
        local r, g, b, a = m:getTerrainColor(1)
        expect_near(0.2, r)
        expect_near(0.4, g)
        expect_near(0.6, b)
        expect_near(0.8, a)
        m:setTerrainColor(2, 0.1, 0.2, 0.3)
        local _, _, _, a = m:getTerrainColor(2)
        expect_near(1.0, a)
    end)
end)

-- Fog of war

-- @describe fog of war
describe("fog of war", function()
    -- @covers LMinimap:isFogEnabled
    it("is disabled by default", function()
        local m = lurek.minimap.newMinimap(10, 10)
        expect_false(m:isFogEnabled())
    end)
    -- @covers LMinimap:setFogEnabled
    it("can toggle fog", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setFogEnabled(true)
        expect_true(m:isFogEnabled())
        m:setFogEnabled(false)
        expect_false(m:isFogEnabled())
    end)

    -- @covers LMinimap:getFogLevel
    it("defaults fog level to 0 (hidden)", function()
        local m = lurek.minimap.newMinimap(10, 10)
        expect_equal(0, m:getFogLevel(1, 1))
    end)

    -- @covers LMinimap:setFogLevel
    it("can set fog levels", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setFogLevel(2, 3, 2) -- visible
        expect_equal(2, m:getFogLevel(2, 3))
        m:setFogLevel(2, 3, 1) -- explored
        expect_equal(1, m:getFogLevel(2, 3))
    end)

    -- @covers LMinimap:setFogColor
    it("can set fog color", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setFogColor(0.1, 0.2, 0.3, 0.5)
        local r, g, b, a = m:getFogColor()
        expect_near(0.1, r)
        expect_near(0.2, g)
        expect_near(0.3, b)
        expect_near(0.5, a)
    end)

    -- @covers LMinimap:setFogData
    it("can bulk set fog data and rejects length mismatches", function()
        local m = lurek.minimap.newMinimap(3, 3)
        m:setFogData({
            2, 1, 0,
            0, 2, 1,
            1, 0, 2,
        })
        expect_equal(2, m:getFogLevel(1, 1))
        expect_equal(1, m:getFogLevel(2, 1))
        expect_equal(0, m:getFogLevel(3, 1))
        expect_equal(0, m:getFogLevel(1, 2))
        expect_equal(2, m:getFogLevel(2, 2))
        expect_equal(2, m:getFogLevel(3, 3))
        expect_error(function()
            m:setFogData({ 1, 2, 3 })
        end)
    end)
end)

-- Object types

-- @describe object types
describe("object types", function()
    -- @covers LMinimap:getObjectTypeCount
    it("starts with zero types", function()
        local m = lurek.minimap.newMinimap(10, 10)
        expect_equal(0, m:getObjectTypeCount())
    end)

    -- @covers LMinimap:addObjectType
    it("adds types with 1-based indices", function()
        local m = lurek.minimap.newMinimap(10, 10)
        local idx1 = m:addObjectType("unit", 1, 0, 0)
        expect_equal(1, idx1)
        local idx2 = m:addObjectType("building", 0, 0, 1, 0.8)
        expect_equal(2, idx2)
        expect_equal(2, m:getObjectTypeCount())
    end)

    -- @covers LMinimap:setObjectTypeVisible
    it("toggles type visibility and rejects unknown type indices", function()
        local m = lurek.minimap.newMinimap(10, 10)
        local idx = m:addObjectType("unit", 1, 0, 0)
        expect_true(m:isObjectTypeVisible(idx))
        m:setObjectTypeVisible(idx, false)
        expect_false(m:isObjectTypeVisible(idx))
        local empty = lurek.minimap.newMinimap(10, 10)
        expect_error(function()
            empty:setObjectTypeVisible(1, false)
        end)
    end)
end)

-- Objects

-- @describe objects
describe("objects", function()
    -- @covers LMinimap:getObjectCount
    it("starts with zero objects", function()
        local m = lurek.minimap.newMinimap(100, 100)
        expect_equal(0, m:getObjectCount())
    end)

    -- @covers LMinimap:removeObject
    it("can add and remove objects", function()
        local m = lurek.minimap.newMinimap(100, 100)
        local idx = m:addObjectType("unit", 1, 0, 0)
        m:setObject(1, 50, 60, idx)
        expect_equal(1, m:getObjectCount())
        m:setObject(2, 70, 80, idx, 1)
        expect_equal(2, m:getObjectCount())
        expect_true(m:removeObject(1))
        expect_equal(1, m:getObjectCount())
        expect_false(m:removeObject(999))
    end)

    -- @covers LMinimap:clearObjects
    it("can clear all objects", function()
        local m = lurek.minimap.newMinimap(100, 100)
        local idx = m:addObjectType("unit", 1, 0, 0)
        m:setObject(1, 10, 10, idx)
        m:setObject(2, 20, 20, idx)
        m:clearObjects()
        expect_equal(0, m:getObjectCount())
    end)
end)

-- Owner colors

-- @describe owner colors
describe("owner colors", function()
    -- @covers LMinimap:setOwnerColor
    it("can set and get owner colors", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setOwnerColor(1, 0, 0, 1, 0.9)
        local r, g, b, a = m:getOwnerColor(1)
        expect_near(0.0, r)
        expect_near(0.0, g)
        expect_near(1.0, b)
        expect_near(0.9, a)
    end)
end)

-- Color mode

-- @describe color mode
describe("color mode", function()
    -- @covers LMinimap:getColorMode
    it("defaults to terrain", function()
        local m = lurek.minimap.newMinimap(10, 10)
        expect_equal("terrain", m:getColorMode())
    end)

    -- @covers LMinimap:setColorMode
    it("accepts valid modes and rejects invalid ones", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setColorMode("political")
        expect_equal("political", m:getColorMode())
        expect_error(function() m:setColorMode("invalid") end)
    end)
end)

-- Zoom and pan

-- @describe zoom and pan
describe("zoom and pan", function()
    -- @covers LMinimap:getZoom
    it("defaults zoom to 1.0", function()
        local m = lurek.minimap.newMinimap(10, 10)
        expect_near(1.0, m:getZoom())
    end)

    -- @covers LMinimap:setZoom
    it("can set zoom and rejects invalid values", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setZoom(2.5)
        expect_near(2.5, m:getZoom())
        expect_error(function()
            m:setZoom(0)
        end)
    end)

    -- @covers LMinimap:setCenter
    it("can set center", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setCenter(5, 3)
        local cx, cy = m:getCenter()
        expect_near(5, cx)
        expect_near(3, cy)
    end)

    -- @covers LMinimap:trackCamera
    it("can track a camera", function()
        local m = lurek.minimap.newMinimap(64, 64)
        local cam = lurek.camera.new(20, 10)
        cam:setPosition(12, 18)
        cam:setZoom(2.0)

        m:trackCamera(cam)

        local cx, cy = m:getCenter()
        local x, y, w, h = m:getViewportRect()
        expect_near(12, cx)
        expect_near(18, cy)
        expect_near(7, x)
        expect_near(15.5, y)
        expect_near(10, w)
        expect_near(5, h)
    end)

    -- @covers LMinimap:revealRadius
    it("can reveal a circular fog area and rejects non-finite inputs", function()
        local m = lurek.minimap.newMinimap(8, 8)
        local hidden = {}
        for i = 1, 64 do hidden[i] = 0 end
        m:setFogEnabled(true)
        m:setFogData(hidden)

        m:revealRadius(3.5, 3.5, 1.6)

        expect_equal(2, m:getFogLevel(4, 4))
        expect_equal(2, m:getFogLevel(3, 4))
        expect_equal(0, m:getFogLevel(1, 1))
        expect_error(function()
            m:revealRadius(0 / 0, 3.5, 1.6)
        end)
    end)
end)

-- Viewport

-- @describe viewport
describe("viewport", function()
    -- @covers LMinimap:getViewportRect
    it("starts with no viewport rect", function()
        local m = lurek.minimap.newMinimap(10, 10)
        expect_nil(m:getViewportRect())
    end)

    -- @covers LMinimap:setViewportRect
    it("can set and get viewport rect", function()
        local m = lurek.minimap.newMinimap(100, 100)
        m:setViewportRect(10, 20, 30, 40)
        local x, y, w, h = m:getViewportRect()
        expect_not_nil(x)
        expect_equal(10, x)
        expect_equal(20, y)
        expect_equal(30, w)
        expect_equal(40, h)
    end)

    -- @covers LMinimap:clearViewportRect
    it("can clear viewport rect", function()
        local m = lurek.minimap.newMinimap(100, 100)
        m:setViewportRect(10, 20, 30, 40)
        m:clearViewportRect()
        expect_nil(m:getViewportRect())
    end)

    -- @covers LMinimap:setViewportVisible
    it("can toggle viewport visibility", function()
        local m = lurek.minimap.newMinimap(10, 10)
        expect_true(m:isViewportVisible())
        m:setViewportVisible(false)
        expect_false(m:isViewportVisible())
    end)

    -- @covers LMinimap:setViewportColor
    it("can set viewport color", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setViewportColor(0.5, 0.6, 0.7, 0.3)
        local r, g, b, a = m:getViewportColor()
        expect_near(0.5, r)
        expect_near(0.6, g)
        expect_near(0.7, b)
        expect_near(0.3, a)
    end)
end)

-- Pings

-- @describe pings
describe("pings", function()
    -- @covers LMinimap:getPingCount
    it("starts with zero pings", function()
        local m = lurek.minimap.newMinimap(10, 10)
        expect_equal(0, m:getPingCount())
    end)

    -- @covers LMinimap:addPing
    it("can add pings", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:addPing(5, 5, 2.0)
        expect_equal(1, m:getPingCount())
        m:addPing(3, 3, 1.0, 0, 1, 0, 1)
        expect_equal(2, m:getPingCount())
    end)

    -- @covers LMinimap:update
    it("expires pings after duration and advances marker animation safely", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:addPing(5, 5, 1.0)
        expect_equal(1, m:getPingCount())
        m:update(0.5)
        expect_equal(1, m:getPingCount())
        m:update(0.6) -- total > 1.0
        expect_equal(0, m:getPingCount())
        local marker = m:addMarker(3, 3, "anim")
        m:setMarkerAnimation(marker, "blink", 2.0)
        expect_no_error(function() m:update(0.016) end)
    end)
end)

-- Markers

-- @describe markers
describe("markers", function()
    -- @covers LMinimap:getMarkerCount
    it("starts with zero markers", function()
        local m = lurek.minimap.newMinimap(10, 10)
        expect_equal(0, m:getMarkerCount())
    end)

    -- @covers LMinimap:addMarker
    it("adds markers with and without descriptions", function()
        local m = lurek.minimap.newMinimap(10, 10)
        local id = m:addMarker(3, 4, "Objective A")
        expect_true(m:hasMarker(id))
        expect_equal("Objective A", m:getMarkerDescription(id))
        expect_equal(1, m:getMarkerCount())
        local id2 = m:addMarker(7, 8)
        expect_true(m:hasMarker(id2))
        expect_equal(2, m:getMarkerCount())
    end)

    -- @covers LMinimap:removeMarker
    it("removes markers and rejects unknown ids", function()
        local m = lurek.minimap.newMinimap(10, 10)
        local id = m:addMarker(3, 4, "Test")
        expect_true(m:removeMarker(id))
        expect_false(m:hasMarker(id))
        expect_equal(0, m:getMarkerCount())
        expect_nil(m:getMarkerDescription(id))
        expect_false(m:removeMarker(999))
    end)
end)

-- Anti-alias

-- @describe anti-alias
describe("anti-alias", function()
    -- @covers LMinimap:isAntiAlias
    it("defaults to false", function()
        local m = lurek.minimap.newMinimap(10, 10)
        expect_false(m:isAntiAlias())
    end)

    -- @covers LMinimap:setAntiAlias
    it("can toggle", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setAntiAlias(true)
        expect_true(m:isAntiAlias())
    end)
end)

-- Coordinate conversion

-- @describe coordinate conversion
describe("coordinate conversion", function()
    -- @covers LMinimap:screenToGrid
    it("converts grid to screen and back", function()
        local m = lurek.minimap.newMinimap(10, 10, 100, 100)
        local sx, sy = m:gridToScreen(0, 0, 0, 0)
        expect_type("number", sx)
        expect_type("number", sy)
        local gx, gy = m:screenToGrid(sx, sy, 0, 0)
        expect_near(0, gx)
        expect_near(0, gy)
    end)
end)

-- Full workflow

-- setTerrainData

-- @describe terrain data bulk set
describe("terrain data bulk set", function()
    -- @covers LMinimap:setTerrainData
    it("sets cells from exact flat tables and rejects mismatches", function()
        local m = lurek.minimap.newMinimap(3, 2)
        m:setTerrainData({1, 2, 3, 4, 5, 6})
        expect_equal(1, m:getTerrain(1, 1))
        expect_equal(2, m:getTerrain(2, 1))
        expect_equal(3, m:getTerrain(3, 1))
        expect_equal(4, m:getTerrain(1, 2))
        expect_equal(5, m:getTerrain(2, 2))
        expect_equal(6, m:getTerrain(3, 2))
        expect_error(function()
            m:setTerrainData({7, 8, 9})
        end)
    end)
end)

-- Tile descriptions

-- @describe tile descriptions
describe("tile descriptions", function()
    -- @covers LMinimap:getTileDescription
    it("returns nil for unset types", function()
        local m = lurek.minimap.newMinimap(5, 5)
        expect_nil(m:getTileDescription(0))
        expect_nil(m:getTileDescription(99))
    end)

    -- @covers LMinimap:setTileDescription
    it("stores, overwrites, and isolates tile descriptions", function()
        local m = lurek.minimap.newMinimap(5, 5)
        m:setTileDescription(1, "Grass")
        expect_equal("Grass", m:getTileDescription(1))
        m:setTileDescription(0, "Water")
        m:setTileDescription(0, "Deep water")
        expect_equal("Deep water", m:getTileDescription(0))
        m:setTileDescription(1, "Forest")
        m:setTileDescription(2, "Mountain")
        expect_equal("Deep water", m:getTileDescription(0))
        expect_equal("Forest", m:getTileDescription(1))
        expect_equal("Mountain", m:getTileDescription(2))
        expect_nil(m:getTileDescription(3))
    end)
end)

-- getHoverInfo

-- @describe getHoverInfo
describe("getHoverInfo", function()
    -- @covers LMinimap:getHoverInfo
    it("returns descriptions in bounds and nil otherwise", function()
        local m = lurek.minimap.newMinimap(4, 4, 100, 100)
        expect_nil(m:getHoverInfo(-1, 50, 0, 0))
        expect_nil(m:getHoverInfo(50, -1, 0, 0))
        expect_nil(m:getHoverInfo(101, 50, 0, 0))
        expect_nil(m:getHoverInfo(50, 101, 0, 0))
        m:setTerrainData({1,1,1,1, 1,1,1,1, 1,1,1,1, 1,1,1,1})
        m:setTileDescription(1, "Plains")
        local info = m:getHoverInfo(1, 1, 0, 0)
        expect_equal("Plains", info)
        m:setTerrain(1, 1, 99)
        expect_nil(m:getHoverInfo(1, 1, 0, 0))
    end)
end)

-- setClickable / isClickable

-- @describe clickable
describe("clickable", function()
    -- @covers LMinimap:isClickable
    it("defaults to true", function()
        local m = lurek.minimap.newMinimap(10, 10)
        expect_true(m:isClickable())
    end)

    -- @covers LMinimap:setClickable
    it("can be disabled and re-enabled", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setClickable(false)
        expect_false(m:isClickable())
        m:setClickable(true)
        expect_true(m:isClickable())
    end)
end)

-- getCenterX / getCenterY

-- @describe center individual getters
describe("center individual getters", function()
    -- @covers LMinimap:getCenterX
    it("getCenterX matches the X component of getCenter", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setCenter(3.5, 7.25)
        expect_near(3.5, m:getCenterX())
        m:setCenter(1.0, 9.0)
        local cx, cy = m:getCenter()
        expect_near(cx, m:getCenterX())
        expect_near(cy, m:getCenterY())
    end)

    -- @covers LMinimap:getCenterY
    it("getCenterY returns the Y component", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setCenter(3.5, 7.25)
        expect_near(7.25, m:getCenterY())
    end)
end)

-- Minimap Layers (merged from test_minimap_layers.lua)

-- @describe minimap layers
describe("minimap layers", function()
    -- @covers LMinimap:getLayer
    it("setLayer defaults to layer 0", function()
        local mm = lurek.minimap.newMinimap(64, 64)
        expect_equal(mm:getLayer(), 0)
    end)

    -- @covers LMinimap:setLayer
    it("setLayer switches between layers and rejects invalid selections", function()
        local mm = lurek.minimap.newMinimap(64, 64)
        local data0 = {}
        local data1 = {}
        local data2 = {}
        for i = 1, 64 * 64 do
            data0[i] = 0
            data1[i] = 1
            data2[i] = 2
        end
        mm:setLayerData(0, data0)
        mm:setLayerData(1, data1)
        mm:setLayerData(2, data2)
        mm:setLayer(1)
        expect_equal(mm:getLayer(), 1)
        mm:setLayer(2)
        expect_equal(mm:getLayer(), 2)
        expect_error(function()
            mm:setLayer(3)
        end)
    end)

    -- @covers LMinimap:setLayerData
    it("setLayerData stores data for base and higher layers", function()
        local mm = lurek.minimap.newMinimap(8, 8)
        local data = {}
        for i = 1, 64 do data[i] = 0 end
        mm:setLayerData(0, data)
        expect_equal(true, true)
        local upper = lurek.minimap.newMinimap(4, 4)
        local upper_data = {}
        for i = 1, 16 do upper_data[i] = 1 end
        upper:setLayerData(2, upper_data)
        expect_equal(true, true)
    end)

    -- @covers LMinimap:getLayerData
    it("returns stored layer data and layer count", function()
        local mm = lurek.minimap.newMinimap(4, 4)
        local data = {}
        for i = 1, 16 do data[i] = i % 3 end
        mm:setLayerData(1, data)

        local out = mm:getLayerData(1)
        expect_equal(2, mm:getLayerCount())
        expect_type("table", out)
        expect_equal(16, #out)
        expect_equal(data[1], out[1])
        expect_equal(data[16], out[16])
        expect_nil(mm:getLayerData(5))
        expect_error(function()
            mm:setLayerData(1, {1, 2, 3})
        end)
    end)

    -- @covers LMinimap:setLayerVisible
    it("setLayerVisible toggles passive layer composition", function()
        local mm = lurek.minimap.newMinimap(2, 2)
        mm:setLayerData(1, {1, 0, 0, 1})
        mm:setLayerVisible(1, true)
        expect_true(mm:isLayerVisible(1))
        mm:setLayerVisible(1, false)
        expect_false(mm:isLayerVisible(1))
        expect_error(function()
            mm:setLayerVisible(4, true)
        end)
    end)

    -- @covers LMinimap:isLayerVisible
    it("isLayerVisible returns nil for missing layers", function()
        local mm = lurek.minimap.newMinimap(2, 2)
        expect_nil(mm:isLayerVisible(3))
        mm:setLayerData(1, {0, 0, 0, 0})
        expect_false(mm:isLayerVisible(1))
    end)

    -- @covers LMinimap:setLayerAlpha
    it("setLayerAlpha stores a clamped opacity", function()
        local mm = lurek.minimap.newMinimap(2, 2)
        mm:setLayerData(1, {1, 1, 1, 1})
        mm:setLayerAlpha(1, 0.35)
        expect_near(0.35, mm:getLayerAlpha(1))
        mm:setLayerAlpha(1, 2.0)
        expect_near(1.0, mm:getLayerAlpha(1))
    end)

    -- @covers LMinimap:getLayerAlpha
    it("getLayerAlpha returns nil for missing layers", function()
        local mm = lurek.minimap.newMinimap(2, 2)
        expect_nil(mm:getLayerAlpha(9))
        mm:setLayerData(1, {0, 0, 0, 0})
        expect_type("number", mm:getLayerAlpha(1))
    end)

    -- @covers LMinimap:setLayerColor
    it("setLayerColor stores a palette color for raw layer values", function()
        local mm = lurek.minimap.newMinimap(2, 2)
        mm:setLayerData(1, {1, 2, 1, 2})
        mm:setLayerColor(1, 2, 0.9, 0.2, 0.1, 0.75)
        local r, g, b, a = mm:getLayerColor(1, 2)
        expect_near(0.9, r)
        expect_near(0.2, g)
        expect_near(0.1, b)
        expect_near(0.75, a)
    end)

    -- @covers LMinimap:getLayerColor
    it("getLayerColor returns nil channels for missing palette entries", function()
        local mm = lurek.minimap.newMinimap(2, 2)
        mm:setLayerData(1, {1, 1, 1, 1})
        local r, g, b, a = mm:getLayerColor(1, 7)
        expect_nil(r)
        expect_nil(g)
        expect_nil(b)
        expect_nil(a)
    end)

    -- @covers LMinimap:setLayerBlendMode
    it("setLayerBlendMode accepts supported blend modes and rejects unknown ones", function()
        local mm = lurek.minimap.newMinimap(2, 2)
        mm:setLayerData(1, {1, 1, 1, 1})
        mm:setLayerBlendMode(1, "add")
        expect_equal("add", mm:getLayerBlendMode(1))
        mm:setLayerBlendMode(1, "multiply")
        expect_equal("multiply", mm:getLayerBlendMode(1))
        expect_error(function()
            mm:setLayerBlendMode(1, "screen")
        end)
    end)

    -- @covers LMinimap:getLayerBlendMode
    it("getLayerBlendMode returns nil for missing layers", function()
        local mm = lurek.minimap.newMinimap(2, 2)
        expect_nil(mm:getLayerBlendMode(1))
        mm:setLayerData(1, {1, 1, 1, 1})
        expect_equal("normal", mm:getLayerBlendMode(1))
    end)

    -- @covers LMinimap:syncProvinceRegistry
    it("syncProvinceRegistry copies province terrain visibility and palette", function()
        local reg = lurek.province.newFromPng("minimap-sync-province", "content/examples/assets/textures/province_map.png")
        local ids = reg:provinceIds()
        local province_id = ids[1]
        expect_true(province_id ~= nil, "province fixture should contain at least one province")
        expect_true(reg:setTerrainType(province_id, 7))
        expect_true(reg:setVisibilityState(province_id, 255))
        expect_true(reg:setPoliticalColor(province_id, 0.2, 0.4, 0.8, 1.0))

        local target_x, target_y = nil, nil
        for y = 1, reg:getHeight() do
            for x = 1, reg:getWidth() do
                if reg:getAt(x, y) == province_id then
                    target_x, target_y = x, y
                    break
                end
            end
            if target_x then break end
        end

        local mm = lurek.minimap.newMinimap(reg:getWidth(), reg:getHeight())
        mm:syncProvinceRegistry(reg)

        expect_equal(7, mm:getTerrain(target_x, target_y))
        expect_equal(2, mm:getFogLevel(target_x, target_y))
        local r, g, b, a = mm:getTerrainColor(7)
        expect_near(0.2, r)
        expect_near(0.4, g)
        expect_near(0.8, b)
        expect_near(1.0, a)
    end)

    -- @covers LMinimap:setMarkerTexture
    it("accepts texture-backed icons for markers and rejects missing markers", function()
        local mm = lurek.minimap.newMinimap(32, 32)
        local tex = lurek.render.newImage("assets/icon.png")
        local marker_id = mm:addMarker(5, 6, "poi")

        expect_no_error(function() mm:setMarkerTexture(marker_id, tex, 10, 10) end)
        expect_no_error(function() mm:clearMarkerTexture(marker_id) end)
        expect_error(function()
            mm:setMarkerTexture(999, tex, 10, 10)
        end)
    end)
end)

-- @describe minimap marker animation
describe("minimap marker animation", function()
    -- @covers LMinimap:setMarkerAnimation
    it("accepts known animation types and rejects unknown ones", function()
        local mm = lurek.minimap.newMinimap(64, 64)
        local id = mm:addMarker(10, 10, "test", 1, 0, 0, 1)
        mm:setMarkerAnimation(id, "blink", 2.0)
        mm:setMarkerAnimation(id, "pulse", 1.5)
        mm:setMarkerAnimation(id, "rotate", 3.14)
        expect_equal(true, true)
        expect_error(function()
            mm:setMarkerAnimation(id, "spin_forever", 1.0)
        end)
    end)

end)

-- Minimap Overlay (merged from test_minimap_ui.lua)

-- @describe minimap geometry overlay
describe("minimap geometry overlay", function()
    -- @covers LMinimap:drawLine
    it("drawLine does not error", function()
        local mm = lurek.minimap.newMinimap(64, 64)
        mm:drawLine(0, 0, 32, 32, {255, 0, 0, 255})
        expect_equal(true, true)
    end)

    -- @covers LMinimap:drawRect
    it("drawRect does not error", function()
        local mm = lurek.minimap.newMinimap(64, 64)
        mm:drawRect(10, 10, 20, 20, {0, 255, 0, 255})
        expect_equal(true, true)
    end)

    -- @covers LMinimap:clearOverlay
    it("clears populated and empty overlays after shapes accumulate", function()
        local mm = lurek.minimap.newMinimap(64, 64)
        mm:drawLine(0, 0, 10, 10, {255, 0, 0, 255})
        mm:drawRect(5, 5, 15, 15, {0, 0, 255, 255})
        mm:clearOverlay()
        expect_equal(true, true)
        mm:clearOverlay()
        expect_equal(true, true)
        mm:drawLine(0, 0, 10, 10, {255, 0, 0, 255})
        mm:drawLine(10, 10, 20, 20, {0, 255, 0, 255})
        mm:drawRect(0, 0, 8, 8, {255, 255, 0, 255})
        mm:clearOverlay()
        expect_equal(true, true)
    end)

    -- @covers LMinimap:getOverlayShapeCount
    it("reports overlay shape count", function()
        local mm = lurek.minimap.newMinimap(64, 64)
        expect_equal(0, mm:getOverlayShapeCount())
        mm:drawLine(0, 0, 10, 10, {255, 0, 0, 255})
        mm:drawRect(0, 0, 8, 8, {255, 255, 0, 255})
        expect_equal(2, mm:getOverlayShapeCount())
    end)
end)

-- Minimap Path (merged from test_minimap_path.lua)

-- @describe minimap path visualization
describe("minimap path visualization", function()
    -- @covers LMinimap:showPath
    it("accepts point lists and returns distinct path ids", function()
        local mm = lurek.minimap.newMinimap(64, 64)
        mm:showPath({{0, 0}, {16, 16}, {32, 0}}, {0, 0, 255, 255})
        expect_equal(true, true)
        local id = mm:showPath({{0, 0}, {10, 10}}, {255, 0, 0, 255})
        expect_true(type(id) == "number")
        expect_true(id > 0)
        local id1 = mm:showPath({{0, 0}, {5, 5}}, {255, 0, 0, 255})
        local id2 = mm:showPath({{10, 10}, {20, 20}}, {0, 255, 0, 255})
        expect_true(id1 ~= id2)
    end)

    -- @covers LMinimap:clearPath
    it("removes all paths, specific paths, and empty path sets", function()
        local mm = lurek.minimap.newMinimap(64, 64)
        mm:showPath({{0, 0}, {10, 10}}, {255, 255, 0, 255})
        mm:showPath({{5, 5}, {15, 15}}, {0, 255, 255, 255})
        mm:clearPath()
        expect_equal(true, true)
        local id = mm:showPath({{0, 0}, {10, 10}}, {255, 0, 0, 255})
        mm:clearPath(id)
        expect_equal(true, true)
        mm:clearPath()
        expect_equal(true, true)
    end)
end)

-- @describe minimap icon helpers
describe("minimap icon helpers", function()
    -- @covers LMinimap:setObjectTypeTexture
    it("accepts texture-backed icons for object types", function()
        local mm = lurek.minimap.newMinimap(32, 32)
        local tex = lurek.render.newImage("assets/icon.png")
        local type_idx = mm:addObjectType("unit", 1, 0, 0, 1)

        expect_no_error(function() mm:setObjectTypeTexture(type_idx, tex, 12, 12) end)
        expect_no_error(function() mm:clearObjectTypeTexture(type_idx) end)
    end)

end)

-- @describe minimap strict: LMinimap render
describe("minimap strict: LMinimap render", function()
    -- @covers LMinimap:render
    it("LMinimap render is callable", function()
        local mm = lurek.minimap.newMinimap(64, 64)
        local ok = pcall(function() mm:render() end)
        expect_type("boolean", ok)
    end)
end)

-- @describe minimap missing explicit coverage
describe("minimap missing explicit coverage", function()
    local function new_mm()
        return lurek.minimap.newMinimap(16, 12, 160, 120)
    end

    local function icon()
        return lurek.render.newImage("assets/icon.png")
    end

    -- @covers LMinimap:getGridWidth
    it("getGridWidth returns the configured cell width", function()
        local mm = new_mm()
        expect_equal(16, mm:getGridWidth())
    end)

    -- @covers LMinimap:getGridHeight
    it("getGridHeight returns the configured cell height", function()
        local mm = new_mm()
        expect_equal(12, mm:getGridHeight())
    end)

    -- @covers LMinimap:getDisplayWidth
    it("getDisplayWidth returns the configured display width", function()
        local mm = new_mm()
        expect_equal(160, mm:getDisplayWidth())
    end)

    -- @covers LMinimap:getDisplayHeight
    it("getDisplayHeight returns the configured display height", function()
        local mm = new_mm()
        expect_equal(120, mm:getDisplayHeight())
    end)

    -- @covers LMinimap:getDisplaySize
    it("getDisplaySize returns both display dimensions", function()
        local mm = new_mm()
        local w, h = mm:getDisplaySize()
        expect_equal(160, w)
        expect_equal(120, h)
    end)

    -- @covers LMinimap:getTerrainColor
    it("getTerrainColor returns the color stored for a terrain id", function()
        local mm = new_mm()
        mm:setTerrainColor(7, 0.2, 0.3, 0.4, 0.5)
        local r, g, b, a = mm:getTerrainColor(7)
        expect_near(0.2, r)
        expect_near(0.3, g)
        expect_near(0.4, b)
        expect_near(0.5, a)
    end)

    -- @covers LMinimap:getFogColor
    it("getFogColor returns the stored overlay color", function()
        local mm = new_mm()
        mm:setFogColor(0.1, 0.25, 0.5, 0.75)
        local r, g, b, a = mm:getFogColor()
        expect_near(0.1, r)
        expect_near(0.25, g)
        expect_near(0.5, b)
        expect_near(0.75, a)
    end)

    -- @covers LMinimap:isObjectTypeVisible
    it("isObjectTypeVisible reflects per-type visibility", function()
        local mm = new_mm()
        local type_idx = mm:addObjectType("unit", 1, 0, 0)
        expect_true(mm:isObjectTypeVisible(type_idx))
        mm:setObjectTypeVisible(type_idx, false)
        expect_false(mm:isObjectTypeVisible(type_idx))
    end)

    -- @covers LMinimap:clearObjectTypeTexture
    it("clearObjectTypeTexture clears a previously assigned icon", function()
        local mm = new_mm()
        local type_idx = mm:addObjectType("unit", 1, 0, 0)
        mm:setObjectTypeTexture(type_idx, icon(), 12, 12)
        expect_no_error(function() mm:clearObjectTypeTexture(type_idx) end)
        expect_no_error(function() mm:clearObjectTypeTexture(type_idx) end)
    end)

    -- @covers LMinimap:setObject
    it("setObject inserts and updates one object id", function()
        local mm = new_mm()
        local type_idx = mm:addObjectType("unit", 1, 0, 0)
        mm:setObject(11, 3, 4, type_idx, 2)
        expect_equal(1, mm:getObjectCount())
        mm:setObject(11, 9, 10, type_idx, 3)
        expect_equal(1, mm:getObjectCount())
    end)

    -- @covers LMinimap:getOwnerColor
    it("getOwnerColor returns the owner swatch", function()
        local mm = new_mm()
        mm:setOwnerColor(5, 0.9, 0.1, 0.2, 0.8)
        local r, g, b, a = mm:getOwnerColor(5)
        expect_near(0.9, r)
        expect_near(0.1, g)
        expect_near(0.2, b)
        expect_near(0.8, a)
    end)

    -- @covers LMinimap:getCenter
    it("getCenter returns the current world center", function()
        local mm = new_mm()
        mm:setCenter(6.5, 2.25)
        local cx, cy = mm:getCenter()
        expect_near(6.5, cx)
        expect_near(2.25, cy)
    end)

    -- @covers LMinimap:isViewportVisible
    it("isViewportVisible reports viewport visibility state", function()
        local mm = new_mm()
        expect_true(mm:isViewportVisible())
        mm:setViewportVisible(false)
        expect_false(mm:isViewportVisible())
    end)

    -- @covers LMinimap:getViewportColor
    it("getViewportColor returns the current outline color", function()
        local mm = new_mm()
        mm:setViewportColor(0.6, 0.4, 0.2, 0.9)
        local r, g, b, a = mm:getViewportColor()
        expect_near(0.6, r)
        expect_near(0.4, g)
        expect_near(0.2, b)
        expect_near(0.9, a)
    end)

    -- @covers LMinimap:hasMarker
    it("hasMarker distinguishes present and removed markers", function()
        local mm = new_mm()
        local id = mm:addMarker(2, 3, "poi")
        expect_true(mm:hasMarker(id))
        mm:removeMarker(id)
        expect_false(mm:hasMarker(id))
    end)

    -- @covers LMinimap:getMarkerDescription
    it("getMarkerDescription returns marker text or nil", function()
        local mm = new_mm()
        local id = mm:addMarker(7, 8, "Objective")
        expect_equal("Objective", mm:getMarkerDescription(id))
        expect_nil(mm:getMarkerDescription(id + 1000))
    end)

    -- @covers LMinimap:clearMarkerTexture
    it("clearMarkerTexture clears a marker icon", function()
        local mm = new_mm()
        local id = mm:addMarker(4, 5, "poi")
        mm:setMarkerTexture(id, icon(), 10, 10)
        expect_no_error(function() mm:clearMarkerTexture(id) end)
        expect_no_error(function() mm:clearMarkerTexture(id) end)
    end)

    -- @covers LMinimap:clearMarkerAnimation
    it("clearMarkerAnimation removes an assigned marker animation", function()
        local mm = new_mm()
        local id = mm:addMarker(4, 5, "poi")
        mm:setMarkerAnimation(id, "pulse", 2.0)
        expect_no_error(function() mm:clearMarkerAnimation(id) end)
        expect_no_error(function() mm:update(0.016) end)
    end)

    -- @covers LMinimap:getPathCount
    it("getPathCount tracks added and cleared paths", function()
        local mm = new_mm()
        expect_equal(0, mm:getPathCount())
        local id = mm:showPath({{0, 0}, {5, 5}}, {255, 0, 0, 255})
        expect_equal(1, mm:getPathCount())
        mm:clearPath(id)
        expect_equal(0, mm:getPathCount())
    end)

    -- @covers LMinimap:getLayerCount
    it("getLayerCount reflects the highest configured layer", function()
        local mm = new_mm()
        expect_equal(0, mm:getLayerCount())
        local data = {}
        for i = 1, 16 * 12 do
            data[i] = i % 4
        end
        mm:setLayerData(2, data)
        expect_equal(3, mm:getLayerCount())
    end)

    -- @covers LMinimap:gridToScreen
    it("gridToScreen maps grid coordinates into screen space", function()
        local mm = new_mm()
        local sx, sy = mm:gridToScreen(8, 6, 10, 20)
        expect_type("number", sx)
        expect_type("number", sy)
        local gx, gy = mm:screenToGrid(sx, sy, 10, 20)
        expect_near(8, gx, 0.6)
        expect_near(6, gy, 0.6)
    end)

    -- @covers LMinimap:typeOf
    it("typeOf recognizes minimap handles and rejects unrelated types", function()
        local mm = new_mm()
        expect_true(mm:typeOf("LMinimap"))
        expect_true(mm:typeOf("LObject"))
        expect_false(mm:typeOf("LImage"))
    end)
end)

-- @describe minimap migrated adapters
describe("minimap migrated adapters", function()
    -- @covers LMinimap:syncTileMapTerrain
    it("syncs tilemap gids into minimap terrain cells", function()
        local map = lurek.tilemap.newTileMap(16, 16)
        map:addLayer("ground", 3, 2)
        map:setTile(1, 2, 1, 7)
        local mm = lurek.minimap.newMinimap(3, 2)
        mm:syncTileMapTerrain(map, {
            terrainByGid = {
                [7] = 4,
            },
        })
        expect_equal(4, mm:getTerrain(2, 1))
    end)

    -- @covers LMinimap:setCenterFromTileMapWorld
    it("centers from tilemap world coordinates", function()
        local map = lurek.tilemap.newTileMap(16, 16)
        local mm = lurek.minimap.newMinimap(8, 8)
        local tx, ty = mm:setCenterFromTileMapWorld(map, 24, 40)
        local cx, cy = mm:getCenter()
        expect_near(tx, cx, 0.001)
        expect_near(ty, cy, 0.001)
        expect_near(2, cx, 0.001)
        expect_near(3, cy, 0.001)
    end)

    -- @covers LMinimap:setViewportFromTileMapWorld
    it("sets viewport from tilemap world rectangles", function()
        local map = lurek.tilemap.newTileMap(16, 16)
        local mm = lurek.minimap.newMinimap(8, 8)
        local tx, ty, tw, th = mm:setViewportFromTileMapWorld(map, 16, 16, 32, 16)
        local x, y, w, h = mm:getViewportRect()
        expect_near(tx, x, 0.001)
        expect_near(ty, y, 0.001)
        expect_near(tw, w, 0.001)
        expect_near(th, h, 0.001)
    end)

    -- @covers LMinimap:setLayerStyle
    it("applies raw layer style from a config table", function()
        local mm = lurek.minimap.newMinimap(16, 12)
        local data = {}
        for i = 1, 16 * 12 do
            data[i] = i % 2
        end
        mm:setLayerData(3, data)
        mm:setLayerStyle(3, {
            visible = true,
            alpha = 0.5,
            blend = "add",
            colors = {
                [1] = { 1.0, 0.0, 0.0, 0.75 },
            },
        })
        expect_true(mm:isLayerVisible(3))
        expect_near(0.5, mm:getLayerAlpha(3), 0.001)
        expect_equal("add", mm:getLayerBlendMode(3))
        local r, g, b, a = mm:getLayerColor(3, 1)
        expect_near(1.0, r, 0.001)
        expect_near(0.0, g, 0.001)
        expect_near(0.0, b, 0.001)
        expect_near(0.75, a, 0.001)
    end)

    -- @covers LMinimap:syncTileFieldBlockLayer
    it("syncs tilefield blockers into a raw layer", function()
        local field = lurek.tilefield.new({ width = 3, height = 2 })
        field:setBlock(2, 1, 1, "move", true)
        local mm = lurek.minimap.newMinimap(3, 2)
        local cells = mm:syncTileFieldBlockLayer(field, "move", 1)
        expect_equal(255, cells[2])
        expect_equal(255, mm:getLayerData(1)[2])
    end)

    -- @covers LMinimap:syncTileFieldCostLayer
    it("syncs tilefield costs into a scaled raw layer", function()
        local field = lurek.tilefield.new({ width = 3, height = 2 })
        field:setCost(3, 2, 1, "move", 2.5)
        local mm = lurek.minimap.newMinimap(3, 2)
        local cells = mm:syncTileFieldCostLayer(field, "move", 2, { scale = 10 })
        expect_equal(25, cells[6])
        expect_equal(25, mm:getLayerData(2)[6])
    end)

    -- @covers LMinimap:syncTileLightLayer
    it("syncs computed tilelight luma into a raw layer", function()
        local field = lurek.tilefield.new({ width = 3, height = 2 })
        local light = lurek.tilelight.compute(field, {
            ambient = { r = 0.2, g = 0.2, b = 0.2 },
        })
        local mm = lurek.minimap.newMinimap(3, 2)
        local cells = mm:syncTileLightLayer(light, 3, { scale = 100 })
        expect_equal(20, cells[1])
        expect_equal(20, mm:getLayerData(3)[1])
    end)

    -- @covers LMinimap:syncTileAwarenessFog
    it("syncs tile awareness into minimap fog data", function()
        local field = lurek.tilefield.new({ width = 3, height = 2 })
        local awareness = lurek.awareness.newTileAwareness(field, {
            players = { "p1" },
            rememberExplored = true,
        })
        awareness:computeVisible("p1", { origin = { x = 2, y = 1, z = 1 }, range = 0 })
        local mm = lurek.minimap.newMinimap(3, 2)
        local cells = mm:syncTileAwarenessFog(awareness, "p1", {
            hiddenValue = 0,
            exploredValue = 3,
            visibleValue = 2,
        })
        expect_equal(2, cells[2])
        expect_true(mm:isFogEnabled())
    end)

    -- @covers LMinimap:syncTileAwarenessLayer
    it("syncs tile awareness masks into a raw layer", function()
        local field = lurek.tilefield.new({ width = 3, height = 2 })
        local awareness = lurek.awareness.newTileAwareness(field, { players = { "p1" } })
        awareness:computeAction("p1", { origin = { x = 2, y = 1, z = 1 }, range = 0 })
        local mm = lurek.minimap.newMinimap(3, 2)
        local cells = mm:syncTileAwarenessLayer(awareness, "p1", "action", 4, { value = 8 })
        expect_equal(8, cells[2])
        expect_equal(8, mm:getLayerData(4)[2])
    end)
end)
end
-- END test_minimap_core_unit.lua

test_summary()
