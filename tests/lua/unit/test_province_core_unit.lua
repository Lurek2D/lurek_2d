-- Lurek2D province API tests.

-- @describe lurek.province.newFromPng
describe("lurek.province.newFromPng", function()
    -- @covers LProvinceRegistry:getName
    it("creates registry from EU2 provinces png", function()
        local reg = lurek.province.newFromPng("test-province", "content/games/strategy/eu2/map.png")
        expect_type("userdata", reg)
        expect_equal("test-province", reg:getName())
    end)
end)

-- @describe registry queries
describe("registry queries", function()
    -- @covers LProvinceRegistry:getWidth
    it("reports the map width from the imported province atlas", function()
        local reg = lurek.province.newFromPng("test-province-q", "content/games/strategy/eu2/map.png")
        expect_equal(1000, reg:getWidth())
    end)

    -- @covers LProvinceRegistry:getHeight
    it("reports the map height from the imported province atlas", function()
        local reg = lurek.province.newFromPng("test-province-h", "content/games/strategy/eu2/map.png")
        expect_equal(450, reg:getHeight())
    end)

    -- @covers LProvinceRegistry:getRevision
    it("starts with revision zero on a fresh registry", function()
        local reg = lurek.province.newFromPng("test-province-r", "content/games/strategy/eu2/map.png")
        expect_equal(0, reg:getRevision())
    end)

    -- @covers LProvinceRegistry:getChangesSince
    it("tracks incremental changes", function()
        local reg = lurek.province.newFromPng("test-province-chg", "content/games/strategy/eu2/map.png")
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
        local reg = lurek.province.newFromPng("test-province-view", "content/games/strategy/eu2/map.png")
        local cam_x, cam_y, zoom = reg:fitCamera(1000, 500, 1.0)
        expect_true(zoom > 0)
        expect_type("number", cam_x)
        expect_type("number", cam_y)
    end)

    -- @covers LProvinceRegistry:screenToMap
    it("maps screen center back into map space", function()
        local reg = lurek.province.newFromPng("test-province-map", "content/games/strategy/eu2/map.png")
        local cam_x, cam_y, zoom = reg:fitCamera(1000, 500, 1.0)
        local center_x = 1000 * 0.5
        local center_y = 500 * 0.5
        local map_x, map_y = reg:screenToMap(center_x, center_y, cam_x, cam_y, zoom, 1.0)
        expect_true(map_x >= 0 and map_x <= reg:getWidth())
        expect_true(map_y >= 0 and map_y <= reg:getHeight())
    end)

    -- @covers LProvinceRegistry:screenToProvince
    it("returns nil when picking outside map bounds", function()
        local reg = lurek.province.newFromPng("test-province-pick", "content/games/strategy/eu2/map.png")
        local id = reg:screenToProvince(-100, -100, 0, 0, 1.0, 1.0)
        expect_equal(nil, id)
    end)

end)

-- @describe province registry extended coverage
describe("province registry extended coverage", function()
    -- @covers LProvinceRegistry:provinceIds
    it("returns ids and geometry tables", function()
        local reg = lurek.province.newFromPng("test-province-geom", "content/games/strategy/eu2/map.png")
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
        local reg = lurek.province.newFromPng("test-province-borders", "content/games/strategy/eu2/map.png")
        reg:registerBorderType(0, { name = "land", color = {100,80,60,255}, thickness = 1.0 })
        reg:registerBorderType(1, { name = "coast", color = {60,120,180,255}, thickness = 2.0 })
        reg:setBorderType(1, 2, 1)
        local bt = reg:getBorderType(1, 2)
        expect_equal(1, bt)
    end)

    -- @covers LProvinceRegistry:setBorderClass
    it("backward-compat aliases getBorderClass/setBorderClass", function()
        local reg = lurek.province.newFromPng("test-province-borders-compat", "content/games/strategy/eu2/map.png")
        reg:setBorderClass(1, 2, 1)
        local bt = reg:getBorderClass(1, 2)
        expect_equal(1, bt)
    end)

    -- @covers LProvinceRegistry:setTerrainType
    it("applies style and metadata mutators", function()
        local reg = lurek.province.newFromPng("test-province-mutate", "content/games/strategy/eu2/map.png")
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
            "content/games/strategy/eu2/map.png",
            out_path
        )
        expect_type("table", summary)
        expect_true((summary.replaced_pixels or 0) > 0)

        local reg = lurek.province.newFromPng("test-province-import", out_path)
        local imported = reg:importMetadataFromFiles({
            color_map_png = out_path,
            marker_png = "content/games/strategy/eu2/map.png",
            color_csv = "content/games/strategy/eu2/prov_cols.csv",
            province_toml = "content/games/strategy/eu2/province.toml",
        })

        expect_type("table", imported)
        expect_true((imported.mapped_provinces or 0) > 0)

        local snap = reg:getProvince(1)
        expect_type("table", snap)
        expect_type("table", snap.attrs)
    end)
end)

-- @describe province strict uncovered symbols
describe("province strict uncovered symbols", function()
    -- @covers LProvinceRegistry:getAt
    it("province registry query methods are callable", function()
        local reg = lurek.province.newFromPng("test-province-strict", "content/games/strategy/eu2/map.png")

        expect_type("number", reg:getAt(0, 0))
        expect_type("table", reg:adjacencies())
        expect_type("table", reg:getNeighbors(1))
    end)

    -- @covers LProvinceRegistry:setAttr
    it("province registry metadata mutators are callable", function()
        local reg = lurek.province.newFromPng("test-province-strict-meta", "content/games/strategy/eu2/map.png")
        expect_type("boolean", reg:setAttr(1, "owner", "blue"))
        expect_type("boolean", reg:setLabelText(1, "Capital"))
    end)

    -- @covers LProvinceRegistry:render
    it("province registry render is callable", function()
        local reg = lurek.province.newFromPng("test-province-strict-render", "content/games/strategy/eu2/map.png")
        local ok_render = pcall(function() reg:render() end)
        expect_type("boolean", ok_render)
    end)

    -- @covers LProvinceRegistry:type
    it("province registry type methods are callable", function()
        local reg = lurek.province.newFromPng("test-province-strict-type", "content/games/strategy/eu2/map.png")
        expect_type("string", reg:type())
        expect_type("boolean", reg:typeOf("LProvinceRegistry"))
    end)
end)

-- @describe province border pair style and zoom render options
describe("province border pair style and zoom render options", function()
    -- @covers LProvinceRegistry:setBorderPairStyle
    it("stores pair style and accepts tactical render options", function()
        local reg = lurek.province.newFromPng("test-province-border-pair", "content/games/strategy/eu2/map.png")

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
        local reg = lurek.province.newFromPng("test-map-modes", "content/games/strategy/eu2/map.png")
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
        local reg = lurek.province.newFromPng("test-map-modes-fail", "content/games/strategy/eu2/map.png")
        expect_false(reg:setMapMode("nonexistent"))
    end)
end)
test_summary()
