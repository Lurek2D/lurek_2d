-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_province_core_unit.lua
do
-- Lurek2D province API tests.

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

-- @describe lurek.province.newFromPng
describe("lurek.province.newFromPng", function()
    -- @covers LProvinceRegistry:getName
    it("creates registry from EU2 provinces png", function()
        local reg = lurek.province.newFromPng("test-province", "content/games/eu2/map.png")
        expect_type("userdata", reg)
        expect_equal("test-province", reg:getName())
    end)
end)

-- @describe registry queries
describe("registry queries", function()
    -- @covers LProvinceRegistry:getWidth
    it("reports the map width from the imported province atlas", function()
        local reg = lurek.province.newFromPng("test-province-q", "content/games/eu2/map.png")
        expect_equal(2000, reg:getWidth())
    end)

    -- @covers LProvinceRegistry:getHeight
    it("reports the map height from the imported province atlas", function()
        local reg = lurek.province.newFromPng("test-province-h", "content/games/eu2/map.png")
        expect_equal(900, reg:getHeight())
    end)

    -- @covers LProvinceRegistry:getRevision
    it("starts with revision zero on a fresh registry", function()
        local reg = lurek.province.newFromPng("test-province-r", "content/games/eu2/map.png")
        expect_equal(0, reg:getRevision())
    end)

    -- @covers LProvinceRegistry:getChangesSince
    it("tracks incremental changes", function()
        local reg = lurek.province.newFromPng("test-province-chg", "content/games/eu2/map.png")
        local rev0 = reg:getRevision()
        local ok = reg:setPoliticalColor(1, 1.0, 0.0, 0.0, 1.0)
        expect_true(ok)
        local rev1 = reg:getRevision()
        expect_true(rev1 > rev0)
        local changes = reg:getChangesSince(rev0)
        expect_true(#changes >= 1)
    end)
end)

-- @describe province camera/view helpers
describe("province camera/view helpers", function()
    -- @covers LProvinceRegistry:fitCamera
    it("computes a fit transform with a positive zoom", function()
        local reg = lurek.province.newFromPng("test-province-view", "content/games/eu2/map.png")
        local cam_x, cam_y, zoom = reg:fitCamera(1000, 500, 1.0)
        expect_true(zoom > 0)
        expect_type("number", cam_x)
        expect_type("number", cam_y)
    end)

    -- @covers LProvinceRegistry:screenToMap
    it("maps screen center back into map space", function()
        local reg = lurek.province.newFromPng("test-province-map", "content/games/eu2/map.png")
        local cam_x, cam_y, zoom = reg:fitCamera(1000, 500, 1.0)
        local center_x = 1000 * 0.5
        local center_y = 500 * 0.5
        local map_x, map_y = reg:screenToMap(center_x, center_y, cam_x, cam_y, zoom, 1.0)
        expect_true(map_x >= 0 and map_x <= reg:getWidth())
        expect_true(map_y >= 0 and map_y <= reg:getHeight())
    end)

    -- @covers LProvinceRegistry:screenToProvince
    it("returns nil when picking outside map bounds", function()
        local reg = lurek.province.newFromPng("test-province-pick", "content/games/eu2/map.png")
        local id = reg:screenToProvince(-100, -100, 0, 0, 1.0, 1.0)
        expect_equal(nil, id)
    end)

    -- @covers LProvinceRegistry:viewportRect
    it("computes a map-space viewport rectangle for minimap overlays", function()
        local reg = lurek.province.newFromPng("test-province-viewport-rect", "content/games/eu2/map.png")
        local rect = reg:viewportRect({
            x = -20,
            y = -10,
            zoom = 2.0,
            pixel_size = 1.0,
            screen_w = 200,
            screen_h = 100,
        })
        expect_type("table", rect)
        expect_near(10.0, rect.x, 0.001)
        expect_near(5.0, rect.y, 0.001)
        expect_near(100.0, rect.w, 0.001)
        expect_near(50.0, rect.h, 0.001)
        expect_equal(reg:getWidth(), rect.map_w)
        expect_equal(reg:getHeight(), rect.map_h)
    end)

end)

-- @describe province registry extended coverage
describe("province registry extended coverage", function()
    -- @covers LProvinceRegistry:provinceIds
    it("returns ids and geometry tables", function()
        local reg = lurek.province.newFromPng("test-province-geom", "content/games/eu2/map.png")
        local ids = reg:provinceIds()
        local spans = reg:provinceSpans()
        local segs = reg:borderSegments()
        expect_type("table", ids)
        expect_type("table", spans)
        expect_type("table", segs)
        expect_true(#ids > 0)
    end)

    -- @covers LProvinceRegistry:registerBorderType
    it("registers and applies border types", function()
        local reg = lurek.province.newFromPng("test-province-borders", "content/games/eu2/map.png")
        reg:registerBorderType(0, { name = "land", color = {100,80,60,255}, thickness = 1.0 })
        reg:registerBorderType(1, { name = "coast", color = {60,120,180,255}, thickness = 2.0 })
        reg:setBorderType(1, 2, 1)
        local bt = reg:getBorderType(1, 2)
        expect_equal(1, bt)
    end)

    -- @covers LProvinceRegistry:setBorderClass
    it("backward-compat aliases getBorderClass/setBorderClass", function()
        local reg = lurek.province.newFromPng("test-province-borders-compat", "content/games/eu2/map.png")
        reg:setBorderClass(1, 2, 1)
        local bt = reg:getBorderClass(1, 2)
        expect_equal(1, bt)
    end)

    -- @covers LProvinceRegistry:setTerrainType
    it("applies style and metadata mutators", function()
        local reg = lurek.province.newFromPng("test-province-mutate", "content/games/eu2/map.png")
        expect_true(reg:setTerrainType(1, 3))
        expect_true(reg:setBorderStyle(1, 2))
        expect_true(reg:setFogState(1, 1))
        expect_true(reg:setVisibilityState(1, 255))
        expect_true(reg:setCapital(1, 10.0, 12.0))
        expect_true(reg:setLabelLine(1, 2.0, 3.0, 5.0, 7.0))
    end)
end)

-- @describe province metadata import pipeline
describe("province metadata import pipeline", function()
    -- @covers LProvinceRegistry:importMetadataFromFiles
    it("sanitizes marked png and imports metadata in one engine-side pass", function()
        local out_path = "save/test_province_core_unit/sanitized_map.png"
        local summary = lurek.province.sanitizeMarkedPng(
            "content/games/eu2/map.png",
            out_path
        )
        expect_type("table", summary)
        expect_true((summary.replaced_pixels or 0) > 0)

        local reg = lurek.province.newFromPng("test-province-import", out_path)
        local imported = reg:importMetadataFromFiles({
            color_map_png = out_path,
            marker_png = "content/games/eu2/map.png",
            color_csv = "content/games/eu2/prov_cols.csv",
            province_toml = "content/games/eu2/province.toml",
        })

        expect_type("table", imported)
        expect_true((imported.mapped_provinces or 0) > 0)
        expect_true((imported.capitals_set or 0) > 0)
        expect_true((imported.label_lines_set or 0) > 0)

        local snap = reg:getProvince(1)
        expect_type("table", snap)
        expect_type("table", snap.capital)
        expect_type("table", snap.attrs)
    end)
end)

-- @describe province strict uncovered symbols
describe("province strict uncovered symbols", function()
    -- @covers LProvinceRegistry:getAt
    it("province registry query methods are callable", function()
        local reg = lurek.province.newFromPng("test-province-strict", "content/games/eu2/map.png")

        expect_type("number", reg:getAt(0, 0))
        expect_type("table", reg:adjacencies())
        expect_type("table", reg:getNeighbors(1))
    end)

    -- @covers LProvinceRegistry:setAttr
    it("province registry metadata mutators are callable", function()
        local reg = lurek.province.newFromPng("test-province-strict-meta", "content/games/eu2/map.png")
        expect_type("boolean", reg:setAttr(1, "owner", "blue"))
        expect_type("boolean", reg:setLabelText(1, "Capital"))
    end)

    -- @covers LProvinceRegistry:render
    it("province registry render accepts render-time tints", function()
        local reg = lurek.province.newFromPng("test-province-strict-render", "content/games/eu2/map.png")
        local ids = reg:provinceIds()
        local province_id = ids[1]
        reg:setVisualState(province_id, {
            climate = "temperate",
            weather = "rain",
            weather_strength = 0.5,
            effect_flags = { "waves", "fog_noise" },
            seed = 77,
        })
        local before = reg:getRevision()

        local ok_render = pcall(function()
            reg:render({
                backend = "gpu",
                tint = { 0.85, 0.9, 1.0, 1.0 },
                province_tints = {
                    [province_id] = { 0.2, 0.6, 0.95, 1.0 },
                },
                edge_gradient_radius = 6.0,
                edge_gradient_strength = 0.25,
                edge_gradient_softness = 0.5,
                edge_gradient_color = { 0.0, 0.0, 0.0, 1.0 },
                border_palette = {
                    province_color = { 64 / 255, 64 / 255, 60 / 255, 1.0 },
                    coast_color = { 224 / 255, 196 / 255, 128 / 255, 1.0 },
                    country_color = { 230 / 255, 46 / 255, 42 / 255, 1.0 },
                    sea_darken = 0.15,
                },
                terrain_texture_strength = 0.05,
                terrain_texture_scale = 8.0,
                visual_effects = {
                    enabled = true,
                    border_noise = {
                        enabled = true,
                        frequency = 0.07,
                        amplitude_px = 1.4,
                        softness_px = 0.8,
                        seed = 42,
                    },
                    water = {
                        enabled = true,
                        strength = 0.3,
                        speed = 0.08,
                        scale = 48.0,
                    },
                    weather = {
                        enabled = true,
                        global_strength = 1.0,
                        direction = { 0.7, 1.0 },
                        speed = 1.0,
                    },
                    fog = {
                        enabled = true,
                        discovered_desaturation = 0.65,
                        hidden_color = { 0.02, 0.02, 0.02, 1.0 },
                        noise_strength = 0.08,
                    },
                    climate = {
                        enabled = true,
                        tint_strength = 0.35,
                        season_phase = 0.25,
                        season_strength = 0.1,
                    },
                },
                draw_borders = false,
                draw_capitals = false,
            })
        end)
        expect_true(ok_render)
        expect_equal(before, reg:getRevision())

        local bad_ok = pcall(function()
            reg:render({ province_tints = { [province_id] = "blue" } })
        end)
        expect_false(bad_ok)

        local bad_effects = pcall(function()
            reg:render({
                backend = "gpu",
                visual_effects = {
                    enabled = true,
                    fog = { hidden_color = { 0.1, 0.2 } },
                },
            })
        end)
        expect_false(bad_effects)
    end)

    -- @covers LProvinceRegistry:setShader
    it("province registry accepts only mapviz render shaders", function()
        local reg = lurek.province.newFromPng("test-province-mapviz-shader", "content/games/eu2/map.png")
        local shader = lurek.render.newShader(mapviz_shader_code(), { target = "mapviz" })
        reg:setShader(shader)
        reg:render({ backend = "commands", draw_labels = false, draw_capitals = false })
        reg:setShader(nil)

        local draw_shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + uv.xyx * 0.0, color.a);
}
]], { target = "draw" })
        expect_error(function()
            reg:setShader(draw_shader)
        end)
    end)

    -- @covers LProvinceRegistry:getShader
    it("province registry returns the bound mapviz shader", function()
        local reg = lurek.province.newFromPng("test-province-mapviz-get-shader", "content/games/eu2/map.png")
        local shader = lurek.render.newShader(mapviz_shader_code(), { target = "mapviz" })
        expect_equal(nil, reg:getShader())
        reg:setShader(shader)
        expect_equal("mapviz", reg:getShader():getTarget())
        reg:setShader(nil)
        expect_equal(nil, reg:getShader())
    end)

    -- @covers LProvinceRegistry:type
    it("province registry type methods are callable", function()
        local reg = lurek.province.newFromPng("test-province-strict-type", "content/games/eu2/map.png")
        expect_type("string", reg:type())
        expect_type("boolean", reg:typeOf("LProvinceRegistry"))
    end)
end)

-- @describe province border pair style and zoom render options
describe("province border pair style and zoom render options", function()
    -- @covers LProvinceRegistry:setBorderPairStyle
    it("stores pair style and accepts tactical render options", function()
        local reg = lurek.province.newFromPng("test-province-border-pair", "content/games/eu2/map.png")

        local ok = reg:setBorderPairStyle(1, 2, {
            color = { 1.0, 0.0, 0.0, 1.0 },
            thickness = 3.0,
            flags = { "country" },
        })
        expect_true(ok)

        local style = reg:getBorderPairStyle(1, 2)
        expect_type("table", style)
        expect_equal(3.0, style.thickness)
        expect_type("table", style.flags)

        local render_ok = pcall(function()
            reg:render({
                zoom_mode = "tactical",
                tactical_zoom_threshold = 3.0,
                draw_roads = true,
                draw_borders = true,
                draw_capitals = true,
            })
        end)
        expect_true(render_ok)
    end)
end)

-- @describe map mode system
describe("map mode system", function()
    -- @covers LProvinceRegistry:registerMapMode
    it("registers and switches map modes", function()
        local reg = lurek.province.newFromPng("test-map-modes", "content/games/eu2/map.png")
        reg:registerMapMode("political", {
            show_labels = true,
            show_borders = true,
            show_roads = true,
            show_capitals = true,
            color_property = "owner_color",
            border_filter = {0, 1, 2}
        })
        reg:registerMapMode("religion", {
            show_labels = false,
            show_borders = true,
            show_capitals = false,
            color_property = "religion_color",
            fog_intensity = 0.5,
            border_filter = {1}
        })

        expect_true(reg:setMapMode("religion"))
        expect_equal("religion", reg:getMapMode())
        expect_true(reg:setMapMode("political"))
        expect_equal("political", reg:getMapMode())
    end)

    -- @covers LProvinceRegistry:setMapMode
    it("returns false for unregistered mode", function()
        local reg = lurek.province.newFromPng("test-map-modes-fail", "content/games/eu2/map.png")
        expect_false(reg:setMapMode("nonexistent"))
    end)
end)
end
-- END test_province_core_unit.lua

-- BEGIN test_province_routing_unit.lua
do
-- tests/lua/unit/test_province_routing_unit.lua
-- lurek.province routing helper unit tests (TST-06)

-- @describe province routing helpers
describe("province routing helpers", function()
    -- @covers LProvinceRegistry:findRoute
    it("findRoute returns trivial missing and weighted routes", function()
        local reg = lurek.province.newFromPng("test-province-routing-basic", "content/games/eu2/map.png")
        local route = reg:findRoute(1, 1)
        expect_type("table", route)
        expect_not_nil(route)
        expect_equal(1, #route)
        expect_equal(1, route[1])

        local missing = reg:findRoute(999999, 999998)
        expect_equal(nil, missing)

        local weighted = reg:findRoute(1, 2, function(from_id, to_id)
            if from_id == to_id then
                return 0.1
            end
            return 1.0
        end)
        if weighted ~= nil then
            expect_type("table", weighted)
            expect_true(#weighted >= 1)
        end
    end)

    -- @covers LProvinceRegistry:isConnected
    it("isConnected reports connectivity for the same province", function()
        local reg = lurek.province.newFromPng("test-province-routing-connected", "content/games/eu2/map.png")
        expect_true(reg:isConnected(1, 1))
    end)

    -- @covers LProvinceRegistry:findRoutes
    it("returns one entry per pair in batch mode", function()
        local reg = lurek.province.newFromPng("test-province-routing-batch", "content/games/eu2/map.png")
        local routes = reg:findRoutes({
            { from = 1, to = 1 },
            { from = 1, to = 2 },
            { from = 999999, to = 2 },
        })
        expect_type("table", routes)
        expect_type("table", routes[1])
        expect_true(routes[2] ~= nil or routes[3] == nil)
    end)

    -- @covers LProvinceRegistry:getConnectedComponents
    it("returns graph components", function()
        local reg = lurek.province.newFromPng("test-province-routing-components", "content/games/eu2/map.png")
        local components = reg:getConnectedComponents()
        expect_type("table", components)
        expect_true(#components >= 1)
        expect_type("table", components[1])
        expect_true(#components[1] >= 1)
    end)

    -- @covers LProvinceRegistry:findIsolatedProvinces
    it("findIsolatedProvinces returns a table", function()
        local reg = lurek.province.newFromPng("test-province-routing-owner", "content/games/eu2/map.png")
        reg:setAttr(1, "faction", "player")
        reg:setAttr(2, "faction", "enemy")
        reg:setAttr(3, "faction", "player")

        local isolated = reg:findIsolatedProvinces("faction")
        expect_type("table", isolated)
    end)

    -- @covers LProvinceRegistry:totalAttrForOwner
    it("totalAttrForOwner sums numeric owner attributes", function()
        local reg = lurek.province.newFromPng("test-province-routing-owner-total", "content/games/eu2/map.png")
        reg:setAttr(1, "faction", "player")
        reg:setAttr(2, "faction", "enemy")
        reg:setAttr(3, "faction", "player")
        reg:setAttr(1, "iron", "10")
        reg:setAttr(2, "iron", "7")
        reg:setAttr(3, "iron", "2.5")
        local total_player = reg:totalAttrForOwner("faction", "player", "iron")
        expect_type("number", total_player)
        expect_true(total_player >= 12.5)
    end)
end)
end
-- END test_province_routing_unit.lua

-- BEGIN test_province_properties_unit.lua
do
-- tests/lua/unit/test_province_properties_unit.lua
-- Unit tests for the province generic property system (setProperty, getProperty, setAttr, getAttr, setFlag, hasFlag, clearProperties).

-- @describe Province generic properties system
describe("lurek.province properties", function()
    -- @covers lurek.province.setProperty
    it("sets and gets numeric property", function()
        lurek.province.setProperty(1, "population", 1500.0)
        local val = lurek.province.getProperty(1, "population")
        expect_near(1500.0, val, 0.001)
    end)

    -- @covers lurek.province.getProperty
    it("returns nil for unset property", function()
        local val = lurek.province.getProperty(999, "nonexistent")
        expect_nil(val)
    end)

    -- @covers lurek.province.setAttr
    it("sets and gets string attribute", function()
        lurek.province.setAttr(1, "culture", "germanic")
        expect_equal("germanic", lurek.province.getAttr(1, "culture"))
    end)

    -- @covers lurek.province.getAttr
    it("returns nil for unset attribute", function()
        expect_nil(lurek.province.getAttr(888, "missing"))
    end)

    -- @covers lurek.province.setFlag
    it("sets and checks flag bits", function()
        lurek.province.setFlag(3, 0, true)
        lurek.province.setFlag(3, 5, true)
        expect_true(lurek.province.hasFlag(3, 0))
        expect_true(lurek.province.hasFlag(3, 5))
        expect_false(lurek.province.hasFlag(3, 1))
    end)

    -- @covers lurek.province.hasFlag
    it("can clear a flag bit", function()
        lurek.province.setFlag(4, 2, true)
        expect_true(lurek.province.hasFlag(4, 2))
        lurek.province.setFlag(4, 2, false)
        expect_false(lurek.province.hasFlag(4, 2))
    end)


    -- @covers lurek.province.clearProperties
    it("clears one province without affecting another", function()
        lurek.province.setProperty(10, "pop", 500.0)
        lurek.province.setAttr(10, "name", "test")
        lurek.province.setFlag(10, 0, true)
        lurek.province.setProperty(11, "pop", 750.0)
        lurek.province.clearProperties(10)
        expect_nil(lurek.province.getProperty(10, "pop"))
        expect_nil(lurek.province.getAttr(10, "name"))
        expect_false(lurek.province.hasFlag(10, 0))
        expect_near(750.0, lurek.province.getProperty(11, "pop"), 0.001)
    end)

end)
end
-- END test_province_properties_unit.lua

do
local function province_registry(stem, path)
    return lurek.province.newFromPng(
        "prov_" .. stem .. "_" .. tostring(math.floor(os.clock() * 1000000)),
        path or "content/examples/assets/textures/province_map.png"
    )
end

local function first_border_pair(reg)
    local pairs = reg:adjacencies()
    expect_true(#pairs > 0)
    return pairs[1].province_a, pairs[1].province_b
end

-- @describe province explicit owner coverage
describe("province explicit owner coverage", function()
    -- @covers lurek.province.newFromPng
    it("creates a registry from a province atlas", function()
        local reg = province_registry("new_from_png")
        expect_type("userdata", reg)
        expect_true(reg:getWidth() > 0)
        expect_true(reg:getHeight() > 0)
    end)

    -- @covers lurek.province.sanitizeMarkedPng
    it("sanitizes a marked png into an output file", function()
        local out_path = "save/test_province_core_unit/sanitized_explicit.png"
        local summary = lurek.province.sanitizeMarkedPng(
            "content/games/eu2/map.png",
            out_path
        )
        expect_type("table", summary)
        expect_true((summary.replaced_pixels or 0) > 0)
        expect_true(lurek.filesystem.exists(out_path))
    end)

    -- @covers lurek.province.get
    it("returns a registry by its name", function()
        local reg = province_registry("get")
        local fetched = lurek.province.get(reg:getName())
        expect_not_nil(fetched)
        expect_equal(reg:getName(), fetched:getName())
    end)

    -- @covers lurek.province.exists
    it("reports whether a named registry exists", function()
        local reg = province_registry("exists")
        expect_true(lurek.province.exists(reg:getName()))
        expect_false(lurek.province.exists("__missing_province_registry__"))
    end)

    -- @covers lurek.province.remove
    it("removes a registry and clears its existence", function()
        local reg = province_registry("remove")
        expect_true(lurek.province.remove(reg:getName()))
        expect_false(lurek.province.exists(reg:getName()))
    end)

    -- @covers lurek.province.setActive
    it("sets the active registry by name", function()
        local reg = province_registry("set_active")
        expect_true(lurek.province.setActive(reg:getName()))
        expect_equal(reg:getName(), lurek.province.getActive():getName())
    end)

    -- @covers lurek.province.getActive
    it("returns the current active registry", function()
        local reg = province_registry("get_active")
        lurek.province.setActive(reg:getName())
        local active = lurek.province.getActive()
        expect_not_nil(active)
        expect_equal(reg:getName(), active:getName())
    end)

    -- @covers lurek.province.zoomCameraAt
    it("keeps the anchor point stable while changing zoom", function()
        local cam_x, cam_y = lurek.province.zoomCameraAt(400, 300, 10, 20, 1.0, 2.0)
        expect_type("number", cam_x)
        expect_type("number", cam_y)
        expect_true(cam_x ~= 10 or cam_y ~= 20)
    end)

    -- @covers LProvinceRegistry:provinceCount
    it("reports the same count as the province id list", function()
        local reg = province_registry("province_count")
        expect_equal(#reg:provinceIds(), reg:provinceCount())
    end)

    -- @covers LProvinceRegistry:adjacencies
    it("returns adjacency pairs with province identifiers", function()
        local reg = province_registry("adjacencies")
        local pairs = reg:adjacencies()
        expect_true(#pairs > 0)
        expect_type("number", pairs[1].province_a)
        expect_type("number", pairs[1].province_b)
    end)

    -- @covers LProvinceRegistry:provinceSpans
    it("returns span rows with province and coordinate fields", function()
        local reg = province_registry("province_spans")
        local spans = reg:provinceSpans()
        expect_true(#spans > 0)
        expect_type("number", spans[1].province_id)
        expect_type("number", spans[1].x0)
        expect_type("number", spans[1].x1)
        expect_type("number", spans[1].y)
    end)

    -- @covers LProvinceRegistry:borderSegments
    it("returns border segment geometry between neighboring provinces", function()
        local reg = province_registry("border_segments")
        local segments = reg:borderSegments()
        expect_true(#segments > 0)
        expect_type("number", segments[1].province_a)
        expect_type("number", segments[1].province_b)
        expect_type("number", segments[1].x0)
        expect_type("number", segments[1].y0)
    end)

    -- @covers LProvinceRegistry:getProvince
    it("returns a province snapshot table for a valid id", function()
        local reg = province_registry("get_province")
        local id = reg:provinceIds()[1]
        local snap = reg:getProvince(id)
        expect_not_nil(snap)
        expect_equal(id, snap.province_id)
        expect_type("table", snap.style)
        expect_type("table", snap.attrs)
    end)

    -- @covers LProvinceRegistry:getNeighbors
    it("returns neighbors for a valid province id", function()
        local reg = province_registry("get_neighbors")
        local id = reg:provinceIds()[1]
        local neighbors = reg:getNeighbors(id)
        expect_type("table", neighbors)
        expect_true(#neighbors >= 1)
    end)

    -- @covers LProvinceRegistry:getBorderType
    it("returns a border type id for a configured adjacency pair", function()
        local reg = province_registry("get_border_type")
        local a, b = first_border_pair(reg)
        reg:setBorderType(a, b, 3)
        expect_equal(3, reg:getBorderType(a, b))
    end)

    -- @covers LProvinceRegistry:setBorderType
    it("stores a border type for an adjacency pair", function()
        local reg = province_registry("set_border_type")
        local a, b = first_border_pair(reg)
        reg:setBorderType(a, b, 2)
        expect_equal(2, reg:getBorderType(a, b))
    end)

    -- @covers LProvinceRegistry:getBorderClass
    it("reads the backward-compatible border class alias", function()
        local reg = province_registry("get_border_class")
        local a, b = first_border_pair(reg)
        reg:setBorderClass(a, b, 4)
        expect_equal(4, reg:getBorderClass(a, b))
    end)

    -- @covers LProvinceRegistry:getBorderPairStyle
    it("returns the stored border pair style table", function()
        local reg = province_registry("get_border_pair_style")
        local a, b = first_border_pair(reg)
        reg:setBorderPairStyle(a, b, {
            color = { 0.2, 0.4, 0.6, 1.0 },
            thickness = 5.0,
            flags = { "country" },
        })
        local style = reg:getBorderPairStyle(a, b)
        expect_type("table", style)
        expect_equal(5.0, style.thickness)
        expect_equal("country", style.flags[1])
    end)

    -- @covers LProvinceRegistry:setPoliticalColor
    it("updates a province political color in the snapshot style", function()
        local reg = province_registry("set_political_color")
        local id = reg:provinceIds()[1]
        expect_true(reg:setPoliticalColor(id, 0.2, 0.4, 0.6, 0.8))
        local color = reg:getProvince(id).style.political_color
        expect_near(0.2, color[1], 0.001)
        expect_near(0.4, color[2], 0.001)
        expect_near(0.6, color[3], 0.001)
        expect_near(0.8, color[4], 0.001)
    end)

    -- @covers LProvinceRegistry:setBorderStyle
    it("updates border style on a province snapshot", function()
        local reg = province_registry("set_border_style")
        local id = reg:provinceIds()[1]
        expect_true(reg:setBorderStyle(id, 7))
        expect_equal(7, reg:getProvince(id).style.border_style)
    end)

    -- @covers LProvinceRegistry:setFogState
    it("updates fog state on a province snapshot", function()
        local reg = province_registry("set_fog_state")
        local id = reg:provinceIds()[1]
        expect_true(reg:setFogState(id, 9))
        expect_equal(9, reg:getProvince(id).style.fog_state)
    end)

    -- @covers LProvinceRegistry:setVisibilityState
    it("updates visibility state on a province snapshot", function()
        local reg = province_registry("set_visibility_state")
        local id = reg:provinceIds()[1]
        expect_true(reg:setVisibilityState(id, 2))
        expect_equal(2, reg:getProvince(id).style.visibility_state)
    end)

    -- @covers LProvinceRegistry:setVisualState
    it("stores compact climate and weather metadata on a province snapshot", function()
        local reg = province_registry("set_visual_state", "content/games/eu2/map.png")
        local id = 1
        expect_true(reg:setVisualState(id, {
            climate = "arid",
            weather = "sandstorm",
            weather_strength = 0.8,
            effect_flags = { "waves", "heat_haze" },
            seed = 12345,
        }))
        local snap = reg:getProvince(id)
        expect_equal("number", type(snap.style.visual_state.climate_type))
        expect_equal("number", type(snap.style.visual_state.weather_type))
        expect_near(0.8, snap.style.visual_state.weather_strength, 0.0001)
        expect_true(snap.style.visual_state.effect_flags > 0)
        expect_equal(12345, snap.style.visual_state.seed)
    end)

    -- @covers LProvinceRegistry:setCapital
    it("accepts a capital marker update on a known province id", function()
        local reg = province_registry("set_capital", "content/games/eu2/map.png")
        local id = 1
        expect_type("boolean", reg:setCapital(id, 12.0, 18.0))
    end)

    -- @covers LProvinceRegistry:drawCapitalPath
    it("queues a capital route path from existing province capitals", function()
        local reg = province_registry("draw_capital_path")
        local a, b = first_border_pair(reg)
        expect_true(reg:setCapital(a, 4.0, 5.0))
        expect_true(reg:setCapital(b, 12.0, 6.0))
        local queued = reg:drawCapitalPath({ a, b }, {
            mode = "bezier",
            color = { 1.0, 0.8, 0.2, 0.9 },
            width = 3.0,
            curve_offset = 6.0,
            segments = 8,
        })
        expect_equal(1, queued)
    end)

    -- @covers LProvinceRegistry:setLabelLine
    it("accepts a label line update on a known province id", function()
        local reg = province_registry("set_label_line", "content/games/eu2/map.png")
        local id = 1
        expect_type("boolean", reg:setLabelLine(id, 1.0, 2.0, 3.0, 4.0))
    end)

    -- @covers LProvinceRegistry:setLabelText
    it("accepts a label text update on a known province id", function()
        local reg = province_registry("set_label_text", "content/games/eu2/map.png")
        local id = 1
        expect_type("boolean", reg:setLabelText(id, "Nordland"))
    end)

    -- @covers LProvinceRegistry:getMapMode
    it("returns the active map mode name", function()
        local reg = province_registry("get_map_mode")
        reg:registerMapMode("political", {
            show_labels = true,
            show_borders = true,
            color_property = "owner_color",
        })
        expect_true(reg:setMapMode("political"))
        expect_equal("political", reg:getMapMode())
    end)

    -- @covers LProvinceRegistry:typeOf
    it("matches the province registry type name", function()
        local reg = province_registry("typeof")
        expect_true(reg:typeOf("LProvinceRegistry"))
        expect_false(reg:typeOf("LCamera"))
    end)
end)
end

test_summary()
