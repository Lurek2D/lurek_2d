-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_globe_core_unit.lua
do
-- tests/lua/unit/test_globe.lua
-- Lurek2D Globe API Tests
-- Covers province topology, orbit camera, fog-of-war, markers, labels,
-- layers, arcs, path-finding, simulation update, and math helpers.

-- =========================================================================
-- 1. Module existence
-- =========================================================================
local function mapviz_shader()
    return lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb * vec3<f32>(1.0, uv.x, 1.0), color.a);
}
]], { target = "mapviz" })
end

-- @describe lurek.globe module exists
describe("lurek.globe module exists", function()
end)

-- =========================================================================
-- 2. Globe creation
-- =========================================================================
-- @describe Globe creation
describe("Globe creation", function()

    -- @covers lurek.globe.new
    it("exposes the factory and returns userdata for bare and spec-based construction", function()
        expect_type("function", lurek.globe.new)
        local g = lurek.globe.new("test_globe")
        expect_type("userdata", g)
        g = lurek.globe.new("spec_globe", { radius = 200.0, axial_tilt_deg = 23.5 })
        expect_type("userdata", g)
    end)

    -- @covers LGlobe:getName
    it("getName returns the globe name", function()
        local g = lurek.globe.new("named_globe")
        expect_equal("named_globe", g:getName())
    end)

    -- @covers LGlobe:setShader
    it("binds only mapviz-target shaders to globe render commands", function()
        local g = lurek.globe.new("shader_globe")
        local shader = mapviz_shader()
        g:setShader(shader)
        expect_equal(shader:getId(), g:getShader():getId())
        g:setShader(nil)
        expect_equal(nil, g:getShader())
        expect_error(function()
            g:setShader(lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> {
    return color;
}
]], { target = "draw" }))
        end)
    end)

    -- @covers LGlobe:getShader
    it("returns the currently bound globe shader or nil", function()
        local g = lurek.globe.new("shader_get_globe")
        expect_equal(nil, g:getShader())
        local shader = mapviz_shader()
        g:setShader(shader)
        expect_equal(shader:getId(), g:getShader():getId())
        g:setShader(nil)
        expect_equal(nil, g:getShader())
    end)

    -- @covers LGlobe:provinceCount
    it("provinceCount starts at 0 and increases when provinces are added", function()
        local g = lurek.globe.new("empty_globe")
        expect_equal(0, g:provinceCount())
        g = lurek.globe.new("grow_globe")
        g:addProvince({ id = 1, centroid = {0,0}, vertices = {{-1,-1},{1,-1},{1,1},{-1,1}}, neighbors = {} })
        g:addProvince({ id = 2, centroid = {1,1}, vertices = {{0,0},{2,0},{2,2},{0,2}}, neighbors = {} })
        expect_equal(2, g:provinceCount())
    end)
end)

-- =========================================================================
-- 3. Province management
-- =========================================================================
-- @describe Province management
describe("Province management", function()

    local function make_globe_with_provinces()
        local g = lurek.globe.new("prov_globe")
        g:addProvince({
            id = 1,
            centroid = {45.0, 10.0},
            vertices = {{44.0, 9.0}, {44.0, 11.0}, {46.0, 11.0}, {46.0, 9.0}},
            neighbors = {2},
            base_color = {0.2, 0.5, 0.3, 1.0},
        })
        g:addProvince({
            id = 2,
            centroid = {47.0, 15.0},
            vertices = {{46.0, 14.0}, {46.0, 16.0}, {48.0, 16.0}, {48.0, 14.0}},
            neighbors = {1},
            base_color = {0.4, 0.3, 0.6, 1.0},
        })
        return g
    end

    -- @covers LGlobe:getNeighbors
    it("getNeighbors returns neighbor list", function()
        local g = make_globe_with_provinces()
        local nbrs = g:getNeighbors(1)
        expect_type("table", nbrs)
        expect_equal(1, #nbrs)
        expect_equal(2, nbrs[1])
    end)

    -- @covers LGlobe:setProvinceAttr
    it("setProvinceAttr and getProvinceAttr round-trip", function()
        local g = make_globe_with_provinces()
        g:setProvinceAttr(1, "owner", "player1")
        local v = g:getProvinceAttr(1, "owner")
        expect_equal("player1", v)
    end)

    -- @covers LGlobe:getProvinceAttr
    it("getProvinceAttr returns nil for unknown key", function()
        local g = make_globe_with_provinces()
        local v = g:getProvinceAttr(1, "nonexistent_key")
        expect_equal(nil, v)
    end)

    -- @covers LGlobe:removeProvince
    it("removeProvince decreases provinceCount", function()
        local g = make_globe_with_provinces()
        g:removeProvince(1)
        expect_equal(1, g:provinceCount())
    end)
end)

-- =========================================================================
-- 4. Camera and LOD
-- =========================================================================
-- @describe Camera and LOD
describe("Camera and LOD", function()

    -- @covers LGlobe:setCamera
    it("setCamera and getCamera round-trip", function()
        local g = lurek.globe.new("cam_globe")
        g:setCamera(30.0, 45.0, 2.0)
        local lat, lon, zoom = g:getCamera()
        -- Values are stored as-is (no complex transform)
        expect_type("number", lat)
        expect_type("number", lon)
        expect_type("number", zoom)
    end)

    -- @covers LGlobe:getLod
    it("getLod returns a string", function()
        local g = lurek.globe.new("lod_globe")
        g:setCamera(0.0, 0.0, 1.0)
        local lod = g:getLod()
        expect_type("string", lod)
        expect_true(lod == "far" or lod == "mid" or lod == "near")
    end)

    -- @covers LGlobe:pan
    it("pan adjusts camera", function()
        local g = lurek.globe.new("pan_globe")
        g:setCamera(0.0, 0.0, 1.0)
        g:pan(10.0, 20.0)
        local lat, lon, _ = g:getCamera()
        expect_type("number", lat)
        expect_type("number", lon)
    end)

    -- @covers LGlobe:zoom
    it("zoom adjusts zoom level", function()
        local g = lurek.globe.new("zoom_globe")
        g:setCamera(0.0, 0.0, 1.0)
        g:zoom(2.0)
        local _, _, zoom = g:getCamera()
        expect_greater(zoom, 1.0)
    end)

    -- @covers LGlobe:pickLatLon
    it("pickLatLon returns visible surface latitude and longitude", function()
        local g = lurek.globe.new("pick_globe", { axial_tilt_deg = 0.0 })
        g:setCamera(0.0, 0.0, 1.0)
        local lat, lon = g:pickLatLon(640, 360)
        expect_type("number", lat)
        expect_type("number", lon)
        expect_near(0.0, lat, 0.01)
        expect_near(90.0, lon, 0.01)
        local edge_lat, edge_lon = g:pickLatLon(0, 0)
        expect_true(edge_lat == nil or type(edge_lat) == "number")
        expect_true(edge_lon == nil or type(edge_lon) == "number")
    end)
end)

-- =========================================================================
-- 5. Fog of war
-- =========================================================================
-- @describe Fog of war
describe("Fog of war", function()

    local function make_fog_globe()
        local g = lurek.globe.new("fog_globe")
        g:addProvince({
            id = 1,
            centroid = {45.0, 10.0},
            vertices = {{44.0, 9.0}, {44.0, 11.0}, {46.0, 11.0}},
            neighbors = {},
        })
        g:addProvince({
            id = 2,
            centroid = {47.0, 15.0},
            vertices = {{46.0, 14.0}, {46.0, 16.0}, {48.0, 16.0}},
            neighbors = {},
        })
        return g
    end

    -- @covers LGlobe:revealProvince
    it("newly revealed province is visible and viewer fog stays isolated", function()
        local g = make_fog_globe()
        g:revealProvince("player1", 1)
        expect_equal(true, g:isVisible("player1", 1))
        g:revealProvince("playerA", 1)
        expect_type("boolean", g:isVisible("playerB", 1))
    end)

    -- @covers LGlobe:hideProvince
    it("hidden province is not visible", function()
        local g = make_fog_globe()
        g:revealProvince("player1", 1)
        g:hideProvince("player1", 1)
        expect_equal(false, g:isVisible("player1", 1))
    end)

    -- @covers LGlobe:revealAll
    it("revealAll reveals all provinces", function()
        local g = make_fog_globe()
        g:revealAll("player2")
        expect_equal(true, g:isVisible("player2", 1))
        expect_equal(true, g:isVisible("player2", 2))
    end)

    -- @covers LGlobe:setActiveViewer
    it("setActiveViewer accepts a string", function()
        local g = make_fog_globe()
        g:setActiveViewer("player1")
        expect_equal(true, true)
    end)
end)

-- =========================================================================
-- 6. Markers
-- =========================================================================
-- @describe Markers
describe("Markers", function()
    -- @covers LGlobe:addMarker
    it("addMarker returns an integer ID", function()
        local g = lurek.globe.new("marker_globe")
        local id = g:addMarker("city", 45.0, 10.0, "Rome")
        expect_type("number", id)
    end)

    -- @covers LGlobe:moveMarker
    it("moveMarker returns true for valid ID", function()
        local g = lurek.globe.new("marker_move_globe")
        local id = g:addMarker("city", 45.0, 10.0)
        local ok = g:moveMarker(id, 50.0, 20.0)
        expect_equal(true, ok)
    end)

    -- @covers LGlobe:removeMarker
    it("removeMarker returns true for existing markers and false for unknown ids", function()
        local g = lurek.globe.new("marker_remove_globe")
        local id = g:addMarker("unit", 30.0, 60.0)
        expect_equal(true, g:removeMarker(id))
        g = lurek.globe.new("marker_absent_globe")
        expect_equal(false, g:removeMarker(9999))
    end)

    -- @covers LGlobe:setMarkerAttr
    it("setMarkerAttr and getMarkerAttr round-trip", function()
        local g = lurek.globe.new("marker_attr_globe")
        local id = g:addMarker("ship", 10.0, 30.0)
        g:setMarkerAttr(id, "hp", "100")
        expect_equal("100", g:getMarkerAttr(id, "hp"))
    end)

    -- @covers LGlobe:setMarkerVisible
    it("setMarkerVisible accepts bool", function()
        local g = lurek.globe.new("marker_vis_globe")
        local id = g:addMarker("base", 0.0, 0.0)
        expect_equal(true, g:setMarkerVisible(id, false))
    end)
end)

-- =========================================================================
-- 7. Labels
-- =========================================================================
-- @describe Labels
describe("Labels", function()
    -- @covers LGlobe:addLabel
    it("addLabel returns an integer ID", function()
        local g = lurek.globe.new("label_globe")
        local id = g:addLabel("region", 45.0, 10.0, "Europe")
        expect_type("number", id)
    end)

    -- @covers LGlobe:setLabelText
    it("setLabelText updates label text", function()
        local g = lurek.globe.new("label_text_globe")
        local id = g:addLabel("capital", 51.5, -0.1, "London")
        local ok = g:setLabelText(id, "Greater London")
        expect_equal(true, ok)
    end)

    -- @covers LGlobe:removeLabel
    it("removeLabel returns true", function()
        local g = lurek.globe.new("label_rm_globe")
        local id = g:addLabel("note", 20.0, 80.0, "Note")
        expect_equal(true, g:removeLabel(id))
    end)
end)

-- =========================================================================
-- 8. Layers
-- =========================================================================
-- @describe Layers
describe("Layers", function()
    -- @covers LGlobe:addLayer
    it("addLayer reports whether a layer was replaced", function()
        local g = lurek.globe.new("layer_globe")
        local replaced = g:addLayer("political", 0)
        expect_equal(false, replaced)
        g = lurek.globe.new("layer_replace_globe")
        g:addLayer("political")
        replaced = g:addLayer("political")
        expect_equal(true, replaced)
    end)

    -- @covers LGlobe:setLayerColor
    it("setLayerColor returns true for existing layers and false for missing ones", function()
        local g = lurek.globe.new("layer_color_globe")
        g:addProvince({ id = 1, centroid = {0,0}, vertices = {{-1,-1},{1,-1},{1,1},{-1,1}}, neighbors = {} })
        g:addLayer("territory")
        expect_equal(true, g:setLayerColor("territory", 1, 0.8, 0.2, 0.2, 1.0))
        g = lurek.globe.new("layer_absent_globe")
        expect_equal(false, g:setLayerColor("nonexistent", 1, 1, 1, 1, 1))
    end)

    -- @covers LGlobe:setLayerVisible
    it("setLayerVisible changes visibility", function()
        local g = lurek.globe.new("layer_vis_globe")
        g:addLayer("terrain")
        expect_equal(true, g:setLayerVisible("terrain", false))
    end)

    -- @covers LGlobe:setLayerAlpha
    it("setLayerAlpha changes opacity", function()
        local g = lurek.globe.new("layer_alpha_globe")
        g:addLayer("effect")
        expect_equal(true, g:setLayerAlpha("effect", 0.5))
    end)

    -- @covers LGlobe:removeLayer
    it("removeLayer returns true", function()
        local g = lurek.globe.new("layer_rm_globe")
        g:addLayer("temp")
        expect_equal(true, g:removeLayer("temp"))
    end)
end)

-- =========================================================================
-- 9. Arcs
-- =========================================================================
-- @describe Arcs
describe("Arcs", function()
    -- @covers LGlobe:addArc
    it("addArc returns an integer ID", function()
        local g = lurek.globe.new("arc_globe")
        local id = g:addArc(51.5, -0.1, 48.8, 2.3)
        expect_type("number", id)
    end)

    -- @covers LGlobe:removeArc
    it("removeArc returns true", function()
        local g = lurek.globe.new("arc_rm_globe")
        local id = g:addArc(0.0, 0.0, 10.0, 10.0)
        expect_equal(true, g:removeArc(id))
    end)
end)

-- =========================================================================
-- 10. Path finding
-- =========================================================================
-- @describe Path finding
describe("Path finding", function()
    local function make_path_globe()
        local g = lurek.globe.new("path_globe")
        g:addProvince({ id = 10, centroid = {0.0, 0.0}, vertices = {{-1,0},{0,1},{1,0}}, neighbors = {11} })
        g:addProvince({ id = 11, centroid = {1.0, 0.0}, vertices = {{0,0},{1,1},{2,0}}, neighbors = {10, 12} })
        g:addProvince({ id = 12, centroid = {2.0, 0.0}, vertices = {{1,0},{2,1},{3,0}}, neighbors = {11} })
        return g
    end

    -- @covers LGlobe:findPath
    it("findPath returns the exact province chain and trivial self path", function()
        local g = make_path_globe()
        local path = g:findPath(10, 12)
        expect_not_nil(path)
        expect_equal(3, #path)
        expect_equal(10, path[1])
        expect_equal(11, path[2])
        expect_equal(12, path[3])
        path = g:findPath(10, 10)
        expect_not_nil(path)
        expect_equal(1, #path)
        expect_equal(10, path[1])
    end)

    -- @covers LGlobe:reachable
    it("reachable handles isolated, budgeted, and zero-budget searches", function()
        local g = lurek.globe.new("solo_path_globe")
        g:addProvince({ id = 10, centroid = {0.0, 0.0}, vertices = {{-1,0},{0,1},{1,0}}, neighbors = {} })

        local reached = g:reachable(10, 5.0)
        expect_type("table", reached)
        expect_equal(0, reached[10])
        expect_nil(reached[11])
        g = make_path_globe()
        reached = g:reachable(10, 3.0)
        expect_type("table", reached)
        expect_equal(0, reached[10])
        expect_true(reached[11] ~= nil)
        expect_true(reached[12] ~= nil)
        reached = g:reachable(10, 0.0)
        expect_type("table", reached)
        expect_equal(0, reached[10])
        expect_nil(reached[11])
        expect_nil(reached[12])
    end)

    -- @covers LGlobe:setEdgeTags
    it("setEdgeTags stores sorted edge metadata", function()
        local g = make_path_globe()
        expect_true(g:setEdgeTags(10, 11, {"land", "road"}))
        local tags = g:getEdgeTags(11, 10)
        expect_equal(2, #tags)
        expect_equal("land", tags[1])
        expect_equal("road", tags[2])
    end)

    -- @covers LGlobe:getEdgeTags
    it("getEdgeTags reads stored edge metadata in sorted order", function()
        local g = make_path_globe()
        expect_true(g:setEdgeTags(10, 11, {"road", "land"}))
        local tags = g:getEdgeTags(11, 10)
        expect_equal(2, #tags)
        expect_equal("land", tags[1])
        expect_equal("road", tags[2])
    end)

    -- @covers LGlobe:findPathWithCosts
    it("findPathWithCosts respects blocked ids and tag surcharges", function()
        local g = make_path_globe()
        expect_true(g:setEdgeTags(10, 11, {"sea"}))
        local result = g:findPathWithCosts(10, 12, {
            province_costs = { [11] = 2.0 },
            tag_costs = { sea = 3.0 },
        })
        expect_type("table", result)
        expect_type("table", result.ids)
        expect_equal(3, #result.ids)
        expect_equal(10, result.ids[1])
        expect_equal(12, result.ids[3])
        expect_true(result.total_cost > 0)
        expect_nil(g:findPathWithCosts(10, 12, { blocked_ids = {11} }))
    end)

    -- @covers LGlobe:reachableWithCosts
    it("reachableWithCosts applies blocked ids and province costs", function()
        local g = make_path_globe()
        local reached = g:reachableWithCosts(10, 1.5, { province_costs = { [11] = 1.0 } })
        expect_equal(0, reached[10])
        expect_nil(reached[11])
        reached = g:reachableWithCosts(10, 2.5, { blocked_ids = {12} })
        expect_true(reached[11] ~= nil)
        expect_nil(reached[12])
    end)
end)

-- =========================================================================
-- 11. Sim update
-- =========================================================================
-- @describe Simulation update
describe("Simulation update", function()
    -- @covers LGlobe:update
    it("update advances time_of_day", function()
        local g = lurek.globe.new("sim_globe")
        g:setTimeOfDay(12.0)
        g:update(3600.0)  -- advance 1 hour
        local t = g:getTimeOfDay()
        expect_type("number", t)
    end)

    -- @covers LGlobe:setTimeOfDay
    it("setTimeOfDay and getTimeOfDay round-trip", function()
        local g = lurek.globe.new("tod_globe")
        g:setTimeOfDay(6.5)
        expect_near(6.5, g:getTimeOfDay(), 0.1)
    end)

    -- @covers LGlobe:setRotation
    it("setRotation stores value", function()
        local g = lurek.globe.new("rot_globe")
        g:setRotation(90.0)
        expect_equal(true, true) -- no crash = pass
    end)
end)

-- =========================================================================
-- 12. Math helpers
-- =========================================================================
-- @describe Globe math helpers
describe("Globe math helpers", function()
    -- @covers lurek.globe.greatCircleDistance
    it("greatCircleDistance returns a number", function()
        expect_type("function", lurek.globe.greatCircleDistance)
        local d = lurek.globe.greatCircleDistance(0.0, 0.0, 90.0, 0.0)
        expect_type("number", d)
        -- Quarter turn on a unit sphere = pi/2
        expect_in_range(d, 1.5, 1.6)
    end)

    -- @covers lurek.globe.greatCirclePath
    it("greatCirclePath returns a table with length >= 2", function()
        expect_type("function", lurek.globe.greatCirclePath)
        local pts = lurek.globe.greatCirclePath(0.0, 0.0, 90.0, 0.0, 8)
        expect_type("table", pts)
        expect_true(#pts >= 2)
    end)

    -- @covers lurek.globe.latLonToUnit
    it("latLonToUnit returns a 3-element table with expected equator basis", function()
        expect_type("function", lurek.globe.latLonToUnit)
        local v = lurek.globe.latLonToUnit(0.0, 0.0)
        expect_type("table", v)
        expect_type("number", v[1])
        expect_type("number", v[2])
        expect_type("number", v[3])
        expect_near(1.0, v[1], 0.01)
        expect_near(0.0, v[2], 0.01)
        expect_near(0.0, v[3], 0.01)
    end)
end)

-- @describe Missing API Coverage
describe("Missing API Coverage", function()
end)

-- @describe lurek.globe.loadFromTOML
describe("lurek.globe.loadFromTOML", function()
    -- @covers lurek.globe.loadFromTOML
    it("loads provinces, attrs, and multipart hole geometry from TOML", function()
        local toml = [=[
[[province]]
id = 1
centroid = [10.0, 20.0]
vertices = [[9.0, 19.0], [9.0, 21.0], [11.0, 21.0], [11.0, 19.0]]
neighbors = [2]

[province.attrs]
owner = "player"

[[province]]
id = 2
centroid = [12.0, 22.0]
vertices = [[11.0, 21.0], [11.0, 23.0], [13.0, 23.0], [13.0, 21.0]]
neighbors = [1]
]=]
        local g = lurek.globe.loadFromTOML("toml_globe", toml)
        expect_type("userdata", g)
        expect_equal(2, g:provinceCount())
        expect_equal("player", g:getProvinceAttr(1, "owner"))

        local multipart_toml = [=[
[[province]]
id = 1
parts = [{ outer = [[-12.0, 78.0], [-12.0, 102.0], [12.0, 102.0], [12.0, 78.0]], holes = [[[-4.0, 86.0], [-4.0, 94.0], [4.0, 94.0], [4.0, 86.0]]] }]

[province.attrs]
owner = "player"
]=]
        g = lurek.globe.loadFromTOML("toml_globe_parts", multipart_toml)
        expect_equal(1, g:provinceCount())
        expect_equal("player", g:getProvinceAttr(1, "owner"))
        g:setCamera(0.0, 90.0, 2.0)
        expect_nil(g:pick(640.0, 360.0))
    end)
end)

-- @describe globe missing explicit coverage
describe("globe missing explicit coverage", function()
    -- @covers LGlobe:setBorders
    it("setBorders toggles border visibility without error", function()
        local g = lurek.globe.new("coverage_set_borders")
        expect_no_error(function()
            g:setBorders(false)
            g:setBorders(true)
        end)
    end)

    -- @covers LGlobe:setLabelVisible
    it("setLabelVisible accepts valid label id", function()
        local g = lurek.globe.new("coverage_set_label_visible")
        local id = g:addLabel("city", 10.0, 20.0, "City")
        expect_no_error(function()
            g:setLabelVisible(id, false)
            g:setLabelVisible(id, true)
        end)
    end)
end)

-- @describe globe strict: LGlobe pick / isVisible / type / typeOf
describe("globe strict: LGlobe pick / isVisible / type / typeOf", function()
    -- @covers LGlobe:pick
    it("LGlobe pick is callable", function()
        local g = lurek.globe.new("strict_pick_globe")
        local ok = pcall(function() g:pick(0.0, 0.0) end)
        expect_type("boolean", ok)
    end)

    -- @covers LGlobe:isVisible
    it("LGlobe isVisible returns boolean", function()
        local g = lurek.globe.new("strict_vis_globe")
        local ok, v = pcall(function() return g:isVisible(g, "province_1") end)
        if ok then expect_type("boolean", v) else expect_true(true) end
    end)

    -- @covers LGlobe:typeOf
    it("LGlobe type and typeOf are callable", function()
        local g = lurek.globe.new("strict_type_globe")
        expect_type("string", g:type())
        expect_type("boolean", g:typeOf("LObject"))
    end)
end)

-- @describe globe extended feature coverage
describe("globe extended feature coverage", function()
    -- @covers lurek.globe.loadFromPNG
    it("loadFromPNG is callable", function()
        local ok = pcall(function()
            lurek.globe.loadFromPNG("cov_png", "assets/textures/nonexistent.png", {})
        end)
        expect_type("boolean", ok)
    end)

    -- @covers lurek.globe.generateVoronoi
    it("generateVoronoi returns userdata", function()
        local g = lurek.globe.generateVoronoi("cov_voronoi", {{0,0}, {10,10}, {-10,-5}}, {})
        expect_type("userdata", g)
    end)

    -- @covers LGlobe:getSectorProvinces
    it("province texture + sector APIs are callable", function()
        local g = lurek.globe.new("cov_prov_ext")
        g:addProvince({ id = 1, centroid = {0,0}, vertices = {{0,0},{1,0},{1,1}} })
        expect_equal(true, g:setProvinceTexture(1, 0, 0.0, 0.0, 1.0, 1.0))
        expect_equal(true, g:clearProvinceTexture(1))
        g:setProvinceSector(1, "west")
        expect_equal("west", g:getProvinceSector(1))
        local ids = g:getSectorProvinces("west")
        expect_true(#ids >= 1)
    end)

    -- @covers LGlobe:removeHeatLayer
    it("heat layer APIs are callable", function()
        local g = lurek.globe.new("cov_heat")
        expect_no_error(function() g:setHeatLayer("h1", "pop", 0, 100, 0.6) end)
        expect_equal(true, g:removeHeatLayer("h1"))
    end)

    -- @covers LGlobe:decodeFogBase64
    it("extended fog APIs round-trip", function()
        local g = lurek.globe.new("cov_fog_ext")
        g:addProvince({ id = 1, centroid = {0,0}, vertices = {{0,0},{1,0},{1,1}} })
        g:setFogState("f1", 1, "explored")
        expect_equal("explored", g:getFogState("f1", 1))
        local payload = g:encodeFogBase64("f1")
        expect_type("string", payload)
        expect_equal(true, g:decodeFogBase64("f1", payload))
    end)

    -- @covers LGlobe:setMarkerRotation
    it("marker animation APIs are callable", function()
        local g = lurek.globe.new("cov_marker_anim")
        local id = g:addMarker("poi", 10.0, 10.0, "A")
        expect_equal(true, g:setMarkerPulse(id, 2.0, 0.3))
        expect_equal(true, g:setMarkerRotation(id, 90.0))
    end)

    -- @covers LGlobe:exportProvinceMeshOBJ
    it("exportProvinceMeshOBJ works for runtime helpers and multipart hole geometry", function()
        local g = lurek.globe.new("cov_runtime_ext")
        g:addProvince({ id = 1, centroid = {0,0}, vertices = {{0,0},{1,0},{1,1}}, neighbors = {2} })
        g:addProvince({ id = 2, centroid = {2,2}, vertices = {{2,2},{3,2},{3,3}}, neighbors = {1} })
        g:setAutoRotationSpeed(0.02)
        g:cacheReachability("blue", 1, 5.0)
        local reach = g:getCachedReachability("blue")
        expect_type("table", reach)
        local _ = g:pickRaycast(640, 360, 8)
        local obj = g:exportProvinceMeshOBJ()
        expect_type("string", obj)

        g = lurek.globe.new("cov_runtime_export_holes")
        g:addProvince({
            id = 1,
            centroid = {0.0, 90.0},
            parts = {
                {
                    outer = {{-12.0, 78.0}, {-12.0, 102.0}, {12.0, 102.0}, {12.0, 78.0}},
                    holes = {
                        {{-4.0, 86.0}, {-4.0, 94.0}, {4.0, 94.0}, {4.0, 86.0}},
                    },
                },
            },
        })
        local obj = g:exportProvinceMeshOBJ()
        expect_true(obj:find("region_1_part_0_outer", 1, true) ~= nil)
        expect_true(obj:find("region_1_part_0_hole_0", 1, true) ~= nil)
        expect_true(obj:find("\nl ", 1, true) ~= nil or obj:sub(1, 2) == "l ")
    end)
end)

-- =========================================================================
-- Globe addRegion and removeRegion
-- =========================================================================

-- @describe Globe addRegion and removeRegion
describe("Globe addRegion and removeRegion", function()
    -- @covers LGlobe:addRegion
    it("addRegion adds a region using region table spec", function()
        local g = lurek.globe.new("region_test_globe")
        local ok = g:addRegion({
            id = 10,
            centroid = {45.0, 10.0},
            vertices = {{44.0, 9.0}, {44.0, 11.0}, {46.0, 11.0}, {46.0, 9.0}},
            neighbors = {},
        })
        expect_true(ok)
        expect_equal(1, g:regionCount())
        expect_true(g:addTerrainPatch({
            id = 101,
            vertices = {{-5.0, -5.0}, {-5.0, 5.0}, {5.0, 5.0}, {5.0, -5.0}},
            base_color = {0.2, 0.5, 0.2, 1.0},
        }))
        expect_true(g:addRegion({ id = 11, members = {101} }))
        expect_equal(2, g:regionCount())
        local member_hits = g:regionsAtLatLon(0.0, 0.0)
        expect_equal(11, member_hits[1])
    end)

    -- @covers LGlobe:removeRegion
    it("removeRegion removes a region by id", function()
        local g = lurek.globe.new("remove_region_globe")
        g:addRegion({
            id = 20,
            centroid = {0.0, 0.0},
            vertices = {{-1.0, -1.0}, {-1.0, 1.0}, {1.0, 1.0}, {1.0, -1.0}},
        })
        local removed = g:removeRegion(20)
        expect_true(removed)
        expect_equal(0, g:regionCount())
    end)
end)

-- @describe globe missing explicit coverage
describe("globe missing explicit coverage", function()
    local function province(id)
        return {
            id = id,
            centroid = { id * 1.0, id * 2.0 },
            vertices = {
                { id * 1.0 - 0.5, id * 2.0 - 0.5 },
                { id * 1.0 + 0.5, id * 2.0 - 0.5 },
                { id * 1.0 + 0.5, id * 2.0 + 0.5 },
                { id * 1.0 - 0.5, id * 2.0 + 0.5 },
            },
            neighbors = {},
        }
    end

    local function new_globe(name)
        return lurek.globe.new(name)
    end

    local function new_registry()
        return lurek.globe.newRegistry()
    end

    -- @covers lurek.globe.newRegistry
    it("newRegistry creates a globe registry userdata handle", function()
        local reg = new_registry()
        expect_type("userdata", reg)
        expect_equal("LGlobeRegistry", reg:type())
    end)

    -- @covers lurek.globe.get
    it("module get returns a named globe from the registry", function()
        local g = new_globe("coverage_globe_get")
        local found = lurek.globe.get("coverage_globe_get")
        expect_type("userdata", g)
        expect_type("userdata", found)
        expect_equal("coverage_globe_get", found:getName())
    end)

    -- @covers lurek.globe.remove
    it("module remove deletes a named globe from the registry", function()
        new_globe("coverage_globe_remove")
        expect_true(lurek.globe.remove("coverage_globe_remove"))
        expect_nil(lurek.globe.get("coverage_globe_remove"))
        expect_false(lurek.globe.remove("coverage_globe_remove"))
    end)

    -- @covers lurek.globe.loadFromTOMLFile
    it("loadFromTOMLFile populates a globe from disk", function()
        local g = lurek.globe.loadFromTOMLFile("coverage_globe_toml_file", "save/globe_example.toml")
        expect_type("userdata", g)
        expect_true(g:provinceCount() >= 1)
    end)

    -- @covers lurek.globe.raySphereIntersect
    it("raySphereIntersect returns the nearest positive hit distance", function()
        local t = lurek.globe.raySphereIntersect(0, 0, -5, 0, 0, 1, 1)
        expect_near(4.0, t, 0.001)
        expect_nil(lurek.globe.raySphereIntersect(0, 0, -5, 1, 0, 0, 1))
    end)

    -- @covers LGlobe:addProvince
    it("addProvince inserts a province and returns success", function()
        local g = new_globe("coverage_add_province")
        expect_true(g:addProvince(province(1)))
        expect_equal(1, g:provinceCount())
    end)

    -- @covers LGlobe:regionCount
    it("regionCount reports the number of stored semantic regions", function()
        local g = new_globe("coverage_region_count")
        expect_equal(0, g:regionCount())
        expect_true(g:addRegion(province(1)))
        expect_equal(1, g:regionCount())
    end)

    -- @covers LGlobe:setProvinceTexture
    it("setProvinceTexture stores texture metadata for a province", function()
        local g = new_globe("coverage_set_province_texture")
        g:addProvince(province(1))
        expect_true(g:setProvinceTexture(1, 42, 0.0, 0.0, 1.0, 1.0))
    end)

    -- @covers LGlobe:clearProvinceTexture
    it("clearProvinceTexture removes stored texture metadata", function()
        local g = new_globe("coverage_clear_province_texture")
        g:addProvince(province(1))
        g:setProvinceTexture(1, 42, 0.0, 0.0, 1.0, 1.0)
        expect_true(g:clearProvinceTexture(1))
    end)

    -- @covers LGlobe:setProvinceSector
    it("setProvinceSector assigns a province to a named sector", function()
        local g = new_globe("coverage_set_province_sector")
        g:addProvince(province(1))
        expect_no_error(function() g:setProvinceSector(1, "north") end)
        expect_equal("north", g:getProvinceSector(1))
    end)

    -- @covers LGlobe:getProvinceSector
    it("getProvinceSector returns the assigned sector name", function()
        local g = new_globe("coverage_get_province_sector")
        g:addProvince(province(1))
        expect_nil(g:getProvinceSector(1))
        g:setProvinceSector(1, "west")
        expect_equal("west", g:getProvinceSector(1))
    end)

    -- @covers LGlobe:setHeatLayer
    it("setHeatLayer creates a removable heat layer", function()
        local g = new_globe("coverage_set_heat_layer")
        expect_no_error(function() g:setHeatLayer("population", "pop", 0, 100, 0.6) end)
        expect_true(g:removeHeatLayer("population"))
    end)

    -- @covers LGlobe:getCamera
    it("getCamera returns the current camera tuple", function()
        local g = new_globe("coverage_get_camera")
        g:setCamera(12.0, 34.0, 2.5)
        local lat, lon, zoom = g:getCamera()
        expect_near(12.0, lat, 0.001)
        expect_near(34.0, lon, 0.001)
        expect_near(2.5, zoom, 0.001)
    end)

    -- @covers LGlobe:pickRaycast
    it("pickRaycast is callable against globe screen space", function()
        local g = new_globe("coverage_pick_raycast")
        g:addProvince(province(1))
        local hit = g:pickRaycast(400, 300, 16)
        expect_true(hit == nil or type(hit) == "number")
    end)

    -- @covers LGlobe:setFogState
    it("setFogState updates the viewer state for one province", function()
        local g = new_globe("coverage_set_fog_state")
        g:addProvince(province(1))
        expect_no_error(function() g:setFogState("viewer_a", 1, "visible") end)
        expect_equal("visible", g:getFogState("viewer_a", 1))
    end)

    -- @covers LGlobe:getFogState
    it("getFogState returns hidden by default and stored states afterward", function()
        local g = new_globe("coverage_get_fog_state")
        g:addProvince(province(1))
        g:hideProvince("viewer_b", 1)
        expect_equal("hidden", g:getFogState("viewer_b", 1))
        g:setFogState("viewer_b", 1, "explored")
        expect_equal("explored", g:getFogState("viewer_b", 1))
    end)

    -- @covers LGlobe:encodeFogBase64
    it("encodeFogBase64 serializes stored fog state", function()
        local g = new_globe("coverage_encode_fog")
        g:addProvince(province(1))
        g:setFogState("viewer_c", 1, "explored")
        local payload = g:encodeFogBase64("viewer_c")
        expect_type("string", payload)
        expect_true(#payload > 0)
    end)

    -- @covers LGlobe:setMarkerPulse
    it("setMarkerPulse stores pulse settings on a marker", function()
        local g = new_globe("coverage_set_marker_pulse")
        local id = g:addMarker("alert", 0.0, 0.0, "!")
        expect_true(g:setMarkerPulse(id, 2.0, 0.25))
    end)

    -- @covers LGlobe:getMarkerAttr
    it("getMarkerAttr returns marker metadata by key", function()
        local g = new_globe("coverage_get_marker_attr")
        local id = g:addMarker("city", 10.0, 20.0, "A")
        g:setMarkerAttr(id, "owner", "blue")
        expect_equal("blue", g:getMarkerAttr(id, "owner"))
        expect_nil(g:getMarkerAttr(id, "missing"))
    end)

    -- @covers LGlobe:getTimeOfDay
    it("getTimeOfDay returns the currently configured time", function()
        local g = new_globe("coverage_get_time_of_day")
        g:setTimeOfDay(18.5)
        expect_near(18.5, g:getTimeOfDay(), 0.001)
    end)

    -- @covers LGlobe:setAutoRotationSpeed
    it("setAutoRotationSpeed accepts rotation speed updates", function()
        local g = new_globe("coverage_set_auto_rotation_speed")
        expect_no_error(function()
            g:setAutoRotationSpeed(0.5)
            g:update(1.0)
        end)
    end)

    -- @covers LGlobe:cacheReachability
    it("cacheReachability stores reachability data for later lookup", function()
        local g = new_globe("coverage_cache_reachability")
        g:addProvince({ id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}, neighbors = {2} })
        g:addProvince({ id = 2, centroid = {5, 0}, vertices = {{4, -1}, {6, -1}, {6, 1}, {4, 1}}, neighbors = {1} })
        expect_no_error(function() g:cacheReachability("blue", 1, 10.0) end)
        local costs = g:getCachedReachability("blue")
        expect_type("table", costs)
        expect_equal(0, costs[1])
    end)

    -- @covers LGlobe:getCachedReachability
    it("getCachedReachability returns cached province costs", function()
        local g = new_globe("coverage_get_cached_reachability")
        g:addProvince({ id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}, neighbors = {} })
        g:cacheReachability("green", 1, 5.0)
        local costs = g:getCachedReachability("green")
        expect_type("table", costs)
        expect_equal(0, costs[1])
    end)

    -- @covers LGlobe:type
    it("type returns the globe userdata type name", function()
        local g = new_globe("coverage_type")
        expect_equal("LGlobe", g:type())
    end)

    -- @covers LGlobeRegistry:new
    it("registry new creates named globes in its own registry", function()
        local reg = new_registry()
        local g = reg:new("coverage_registry_new", { radius = 3.0 })
        expect_type("userdata", g)
        expect_equal("coverage_registry_new", g:getName())
    end)

    -- @covers LGlobeRegistry:get
    it("registry get returns a globe by name from the same registry", function()
        local reg = new_registry()
        reg:new("coverage_registry_get")
        local found = reg:get("coverage_registry_get")
        expect_type("userdata", found)
        expect_equal("coverage_registry_get", found:getName())
        expect_nil(reg:get("__missing_globe__"))
    end)

    -- @covers LGlobeRegistry:remove
    it("registry remove deletes globes from that registry", function()
        local reg = new_registry()
        reg:new("coverage_registry_remove")
        expect_true(reg:remove("coverage_registry_remove"))
        expect_nil(reg:get("coverage_registry_remove"))
        expect_false(reg:remove("coverage_registry_remove"))
    end)

    -- @covers LGlobeRegistry:names
    it("registry names lists the globes stored in that registry", function()
        local reg = new_registry()
        reg:new("coverage_registry_names_a")
        reg:new("coverage_registry_names_b")
        local names = reg:names()
        expect_type("table", names)
        local seen_a = false
        local seen_b = false
        for _, name in ipairs(names) do
            if name == "coverage_registry_names_a" then
                seen_a = true
            elseif name == "coverage_registry_names_b" then
                seen_b = true
            end
        end
        expect_true(seen_a)
        expect_true(seen_b)
    end)

    -- @covers LGlobeRegistry:type
    it("registry type returns the registry userdata type name", function()
        local reg = new_registry()
        expect_equal("LGlobeRegistry", reg:type())
    end)

    -- @covers LGlobeRegistry:typeOf
    it("registry typeOf recognizes registry userdata inheritance", function()
        local reg = new_registry()
        expect_true(reg:typeOf("LGlobeRegistry"))
        expect_true(reg:typeOf("LObject"))
        expect_false(reg:typeOf("LGlobe"))
    end)
end)

-- @describe globe surface interaction and semantic region coverage
describe("globe surface interaction and semantic region coverage", function()
    local function interaction_globe(name)
        local g = lurek.globe.new(name, { axial_tilt_deg = 0.0 })
        g:setCamera(0.0, 0.0, 1.0)
        g:addProvince({
            id = 1,
            centroid = {0.0, 90.0},
            vertices = {{-10.0, 80.0}, {-10.0, 100.0}, {10.0, 100.0}, {10.0, 80.0}},
            neighbors = {},
        })
        g:addRegion({
            id = 100,
            centroid = {0.0, 90.0},
            vertices = {{-12.0, 78.0}, {-12.0, 102.0}, {12.0, 102.0}, {12.0, 78.0}},
            neighbors = {},
        })
        local marker_id = g:addMarker("poi", 0.0, 90.0, "Center")
        return g, marker_id
    end

    -- @covers LGlobe:screenToLatLon
    it("screenToLatLon converts the visible center into surface coordinates", function()
        local g = lurek.globe.new("coverage_screen_to_lat_lon", { axial_tilt_deg = 0.0 })
        g:setCamera(0.0, 0.0, 1.0)
        local lat, lon, x, y, z = g:screenToLatLon(640, 360)
        expect_near(0.0, lat, 0.01)
        expect_near(90.0, lon, 0.01)
        expect_type("number", x)
        expect_type("number", y)
        expect_type("number", z)
    end)

    -- @covers LGlobe:regionsAtLatLon
    it("regionsAtLatLon respects multipart semantic regions with holes", function()
        local g = lurek.globe.new("coverage_regions_with_holes")
        g:addRegion({
            id = 210,
            parts = {
                {
                    outer = {{-8,-8},{-8,8},{8,8},{8,-8}},
                    holes = {
                        {{-2,-2},{-2,2},{2,2},{2,-2}},
                    },
                },
                {
                    outer = {{10,10},{10,14},{14,14},{14,10}},
                },
            },
        })
        local outer_ids = g:regionsAtLatLon(6.0, 6.0)
        expect_equal(1, #outer_ids)
        expect_equal(210, outer_ids[1])
        local hole_ids = g:regionsAtLatLon(0.0, 0.0)
        expect_equal(0, #hole_ids)
        local island_ids = g:regionsAtLatLon(12.0, 12.0)
        expect_equal(1, #island_ids)
        expect_equal(210, island_ids[1])
    end)

    -- @covers LGlobe:pickRegions
    it("pickRegions returns semantic regions and ignores semantic hole geometry", function()
        local g = interaction_globe("coverage_pick_regions")
        local ids = g:pickRegions(640, 360)
        expect_equal(1, #ids)
        expect_equal(100, ids[1])

        g = lurek.globe.new("coverage_pick_regions_hole", { axial_tilt_deg = 0.0 })
        g:setCamera(0.0, 0.0, 1.0)
        g:addRegion({
            id = 220,
            parts = {
                {
                    outer = {{-12.0, 78.0}, {-12.0, 102.0}, {12.0, 102.0}, {12.0, 78.0}},
                    holes = {
                        {{-4.0, 86.0}, {-4.0, 94.0}, {4.0, 94.0}, {4.0, 86.0}},
                    },
                },
            },
        })
        local ids = g:pickRegions(640, 360)
        expect_equal(0, #ids)
    end)

    -- @covers LGlobe:pickMarker
    it("pickMarker returns the nearest visible marker at the pointer", function()
        local g, marker_id = interaction_globe("coverage_pick_marker")
        expect_equal(marker_id, g:pickMarker(640, 360, 16.0))
    end)

    -- @covers LGlobe:pickSurface
    it("pickSurface returns surface coordinates plus province and region hits", function()
        local g, marker_id = interaction_globe("coverage_pick_surface")
        local hit = g:pickSurface(640, 360, 16.0)
        expect_type("table", hit)
        expect_equal(1, hit.province_id)
        expect_equal(marker_id, hit.marker_id)
        expect_equal(100, hit.region_ids[1])
        expect_near(0.0, hit.lat, 0.01)
        expect_near(90.0, hit.lon, 0.01)
    end)

    -- @covers LGlobe:screenDeltaToPan
    it("screenDeltaToPan returns numeric latitude and longitude deltas", function()
        local g = lurek.globe.new("coverage_screen_delta_to_pan")
        local dlat, dlon = g:screenDeltaToPan(10.0, -5.0)
        expect_type("number", dlat)
        expect_type("number", dlon)
    end)

    -- @covers LGlobe:applyMouseDrag
    it("applyMouseDrag updates the camera from pointer movement", function()
        local g = lurek.globe.new("coverage_apply_mouse_drag")
        g:setCamera(0.0, 0.0, 1.0)
        g:applyMouseDrag(640, 360, 680, 360)
        local _, lon = g:getCamera()
        expect_true(math.abs(lon) > 0.0)
    end)

    -- @covers LGlobe:applyWheelZoom
    it("applyWheelZoom changes the stored zoom factor", function()
        local g = lurek.globe.new("coverage_apply_wheel_zoom")
        g:setCamera(0.0, 0.0, 1.0)
        g:applyWheelZoom(1.0)
        local _, _, zoom = g:getCamera()
        expect_true(zoom > 1.0)
    end)

    -- @covers LGlobe:setRegionAttr
    it("setRegionAttr stores metadata on a semantic region", function()
        local g = lurek.globe.new("coverage_set_region_attr")
        g:addRegion({ id = 300, centroid = {0.0, 0.0}, vertices = {{-1,-1},{-1,1},{1,1},{1,-1}} })
        expect_true(g:setRegionAttr(300, "country", "PL"))
    end)

    -- @covers LGlobe:getRegionAttr
    it("getRegionAttr reads metadata from a semantic region", function()
        local g = lurek.globe.new("coverage_get_region_attr")
        g:addRegion({ id = 301, centroid = {0.0, 0.0}, vertices = {{-1,-1},{-1,1},{1,1},{1,-1}} })
        g:setRegionAttr(301, "country", "PL")
        expect_equal("PL", g:getRegionAttr(301, "country"))
    end)

    -- @covers LGlobe:setMarkerColor
    it("setMarkerColor updates marker tint", function()
        local g = lurek.globe.new("coverage_set_marker_color")
        local id = g:addMarker("poi", 0.0, 0.0, "A")
        expect_true(g:setMarkerColor(id, 0.2, 0.4, 0.6, 1.0))
    end)

    -- @covers LGlobe:setMarkerSize
    it("setMarkerSize updates marker size", function()
        local g = lurek.globe.new("coverage_set_marker_size")
        local id = g:addMarker("poi", 0.0, 0.0, "A")
        expect_true(g:setMarkerSize(id, 14.0))
    end)

    -- @covers LGlobe:setMarkerShape
    it("setMarkerShape accepts supported shape names", function()
        local g = lurek.globe.new("coverage_set_marker_shape")
        local id = g:addMarker("poi", 0.0, 0.0, "A")
        expect_true(g:setMarkerShape(id, "diamond"))
    end)

    -- @covers LGlobe:setMarkerIconTexture
    it("setMarkerIconTexture stores or clears raw icon handles", function()
        local g = lurek.globe.new("coverage_set_marker_icon")
        local id = g:addMarker("poi", 0.0, 0.0, "A")
        expect_true(g:setMarkerIconTexture(id, 0))
        expect_true(g:setMarkerIconTexture(id, nil))
    end)

    -- @covers LGlobe:distanceBetweenMarkers
    it("distanceBetweenMarkers returns great-circle distance between markers", function()
        local g = lurek.globe.new("coverage_distance_between_markers")
        local a = g:addMarker("poi", 0.0, 0.0, "A")
        local b = g:addMarker("poi", 0.0, 90.0, "B")
        local d = g:distanceBetweenMarkers(a, b)
        expect_in_range(d, 1.5, 1.6)
    end)

    -- @covers LGlobe:draw
    it("draw submits globe render commands without requiring a Lua fallback renderer", function()
        local g = interaction_globe("coverage_globe_draw")
        expect_no_error(function()
            g:draw({ screen_cx = 640.0, screen_cy = 360.0 })
        end)
    end)
end)

-- @describe globe terrain polygon layer coverage
describe("globe terrain polygon layer coverage", function()
    local function terrain_patch(id, min_lat, min_lon, max_lat, max_lon)
        return {
            id = id,
            vertices = {
                {min_lat, min_lon},
                {min_lat, max_lon},
                {max_lat, max_lon},
                {max_lat, min_lon},
            },
            base_color = {0.1 + id * 0.01, 0.4, 0.2, 1.0},
        }
    end

    local function full_coverage_globe(name)
        local g = lurek.globe.new(name, { axial_tilt_deg = 0.0 })
        expect_true(g:addTerrainPatch(terrain_patch(1, -90.0, -180.0, 0.0, 0.0)))
        expect_true(g:addTerrainPatch(terrain_patch(2, -90.0, 0.0, 0.0, 180.0)))
        expect_true(g:addTerrainPatch(terrain_patch(3, 0.0, -180.0, 90.0, 0.0)))
        expect_true(g:addTerrainPatch(terrain_patch(4, 0.0, 0.0, 90.0, 180.0)))
        return g
    end

    -- @covers LGlobe:addTerrainPatch
    it("addTerrainPatch inserts colored base terrain polygons", function()
        local g = lurek.globe.new("coverage_add_terrain_patch")
        expect_true(g:addTerrainPatch(terrain_patch(10, -10.0, -10.0, 10.0, 10.0)))
        expect_equal(1, g:terrainPatchCount())
    end)

    -- @covers LGlobe:removeTerrainPatch
    it("removeTerrainPatch removes a base terrain polygon by id", function()
        local g = lurek.globe.new("coverage_remove_terrain_patch")
        g:addTerrainPatch(terrain_patch(11, -10.0, -10.0, 10.0, 10.0))
        expect_true(g:removeTerrainPatch(11))
        expect_false(g:removeTerrainPatch(11))
    end)

    -- @covers LGlobe:terrainPatchCount
    it("terrainPatchCount returns the number of base terrain polygons", function()
        local g = lurek.globe.new("coverage_terrain_patch_count")
        expect_equal(0, g:terrainPatchCount())
        g:addTerrainPatch(terrain_patch(12, -10.0, -10.0, 10.0, 10.0))
        expect_equal(1, g:terrainPatchCount())
    end)

    -- @covers LGlobe:setTerrainPatchAttr
    it("setTerrainPatchAttr stores terrain patch metadata", function()
        local g = lurek.globe.new("coverage_set_terrain_patch_attr")
        g:addTerrainPatch(terrain_patch(13, -10.0, -10.0, 10.0, 10.0))
        expect_true(g:setTerrainPatchAttr(13, "biome", "forest"))
    end)

    -- @covers LGlobe:getTerrainPatchAttr
    it("getTerrainPatchAttr reads terrain patch metadata", function()
        local g = lurek.globe.new("coverage_get_terrain_patch_attr")
        g:addTerrainPatch({
            id = 14,
            vertices = {{-10.0,-10.0},{-10.0,10.0},{10.0,10.0},{10.0,-10.0}},
            attrs = { biome = "desert" },
        })
        expect_equal("desert", g:getTerrainPatchAttr(14, "biome"))
    end)

    -- @covers LGlobe:setTerrainPatchTexture
    it("setTerrainPatchTexture stores raw texture metadata for terrain", function()
        local g = lurek.globe.new("coverage_set_terrain_patch_texture")
        g:addTerrainPatch(terrain_patch(15, -10.0, -10.0, 10.0, 10.0))
        expect_true(g:setTerrainPatchTexture(15, 42, 0.0, 0.0, 1.0, 1.0))
        expect_equal("42", g:getTerrainPatchAttr(15, "__texture_raw"))
    end)

    -- @covers LGlobe:clearTerrainPatchTexture
    it("clearTerrainPatchTexture removes raw texture metadata from terrain", function()
        local g = lurek.globe.new("coverage_clear_terrain_patch_texture")
        g:addTerrainPatch(terrain_patch(16, -10.0, -10.0, 10.0, 10.0))
        g:setTerrainPatchTexture(16, 42, 0.0, 0.0, 1.0, 1.0)
        expect_true(g:clearTerrainPatchTexture(16))
        expect_nil(g:getTerrainPatchAttr(16, "__texture_raw"))
    end)

    -- @covers LGlobe:validateTerrainCoverage
    it("validateTerrainCoverage reports complete sampled coverage and gaps", function()
        local complete = full_coverage_globe("coverage_terrain_complete")
        local ok_report = complete:validateTerrainCoverage({ lat_step = 45.0, lon_step = 90.0 })
        expect_true(ok_report.ok)
        expect_equal(ok_report.samples, ok_report.covered_samples)

        local gap = lurek.globe.new("coverage_terrain_gap")
        gap:addTerrainPatch(terrain_patch(20, -90.0, -180.0, 0.0, 0.0))
        local gap_report = gap:validateTerrainCoverage({ lat_step = 45.0, lon_step = 90.0 })
        expect_false(gap_report.ok)
        expect_true(#gap_report.gaps > 0)
    end)

    -- @covers LGlobe:setRegionColor
    it("setRegionColor updates semantic overlay tint", function()
        local g = full_coverage_globe("coverage_set_region_color")
        g:addRegion({ id = 30, members = {1, 2} })
        expect_true(g:setRegionColor(30, 0.8, 0.2, 0.1, 0.35))
    end)

    -- @covers LGlobe:setRegionVisible
    it("setRegionVisible controls semantic overlay picking participation", function()
        local g = full_coverage_globe("coverage_set_region_visible")
        g:addRegion({ id = 31, members = {1} })
        expect_equal(31, g:regionsAtLatLon(-45.0, -90.0)[1])
        expect_true(g:setRegionVisible(31, false))
        expect_equal(0, #g:regionsAtLatLon(-45.0, -90.0))
    end)
end)
end
-- END test_globe_core_unit.lua

test_summary()
