-- content/examples/province.lua
-- Auto-generated from content/examples2/province_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/province.lua

--@api-stub: lurek.province.newFromPng
do
    local reg = lurek.province.newFromPng("world", "assets/textures/province_map.png")
    local ids = reg:provinceIds()

    print("registry = " .. reg:getName())
    print("province count = " .. tostring(#ids))
end

--@api-stub: LProvinceRegistry:getWidth
do
    local reg = lurek.province.newFromPng("info_width", "assets/textures/province_map.png")
    local width = reg:getWidth()

    print("width = " .. tostring(width))
    print("name = " .. reg:getName())
end

--@api-stub: LProvinceRegistry:getHeight
do
    local reg = lurek.province.newFromPng("info_height", "assets/textures/province_map.png")
    local height = reg:getHeight()

    print("height = " .. tostring(height))
    print("name = " .. reg:getName())
end

--@api-stub: LProvinceRegistry:provinceCount
do
    local reg = lurek.province.newFromPng("info_count", "assets/textures/province_map.png")
    local count = reg:provinceCount()

    print("province count = " .. tostring(count))
end

--@api-stub: LProvinceRegistry:provinceIds
do
    local reg = lurek.province.newFromPng("info_ids", "assets/textures/province_map.png")
    local ids = reg:provinceIds()

    print("id count = " .. tostring(#ids))
    print("first id = " .. tostring(ids[1]))
    print("last id = " .. tostring(ids[#ids]))
end

--@api-stub: LProvinceRegistry:getAt
do
    local reg = lurek.province.newFromPng("spatial", "assets/textures/province_map.png")
    local province_id = reg:getAt(50, 50)

    print("province at 50,50 = " .. tostring(province_id))
    print("province at 0,0 = " .. tostring(reg:getAt(0, 0)))
end

--@api-stub: LProvinceRegistry:getNeighbors
do
    local reg = lurek.province.newFromPng("adj", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local neighbors = province_id and reg:getNeighbors(province_id) or {}

    print("province id = " .. tostring(province_id))
    print("neighbor count = " .. tostring(#neighbors))
end

--@api-stub: LProvinceRegistry:adjacencies
do
    local reg = lurek.province.newFromPng("pairs", "assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]

    print("adjacency pairs = " .. tostring(#pairs))
    print("first pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
end

--@api-stub: LProvinceRegistry:getProvince
do
    local reg = lurek.province.newFromPng("snap", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local snap = province_id and reg:getProvince(province_id) or nil

    print("province_id = " .. tostring(snap and snap.province_id))
    print("revision = " .. tostring(snap and snap.revision))
    print("terrain type = " .. tostring(snap and snap.style and snap.style.terrain_type))
end

--@api-stub: LProvinceRegistry:setPoliticalColor
do
    local reg = lurek.province.newFromPng("colors", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setPoliticalColor(province_id, 0.8, 0.2, 0.2, 1.0)
    end

    print("province_id = " .. tostring(province_id))
    print("applied = " .. tostring(ok))
end

--@api-stub: LProvinceRegistry:setTerrainType
do
    local reg = lurek.province.newFromPng("style_terrain", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setTerrainType(province_id, 1)
    end

    print("province_id = " .. tostring(province_id))
    print("applied = " .. tostring(ok))
end

--@api-stub: LProvinceRegistry:setFogState
do
    local reg = lurek.province.newFromPng("style_fog", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setFogState(province_id, 1)
    end

    print("province_id = " .. tostring(province_id))
    print("applied = " .. tostring(ok))
end

--@api-stub: LProvinceRegistry:setVisibilityState
do
    local reg = lurek.province.newFromPng("style_visibility", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setVisibilityState(province_id, 2)
    end

    print("province_id = " .. tostring(province_id))
    print("applied = " .. tostring(ok))
end

--@api-stub: LProvinceRegistry:setBorderStyle
do
    local reg = lurek.province.newFromPng("style_border", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setBorderStyle(province_id, 2)
    end

    print("province_id = " .. tostring(province_id))
    print("applied = " .. tostring(ok))
end

--@api-stub: LProvinceRegistry:setLabelText
do
    local reg = lurek.province.newFromPng("labels_text", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setLabelText(province_id, "Nordland")
    end

    print("province_id = " .. tostring(province_id))
    print("applied = " .. tostring(ok))
end

--@api-stub: LProvinceRegistry:setLabelLine
do
    local reg = lurek.province.newFromPng("labels_line", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setLabelLine(province_id, 10, 20, 50, 20)
    end

    print("province_id = " .. tostring(province_id))
    print("applied = " .. tostring(ok))
end

--@api-stub: LProvinceRegistry:setCapital
do
    local reg = lurek.province.newFromPng("labels_capital", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setCapital(province_id, 30, 25)
    end

    print("province_id = " .. tostring(province_id))
    print("applied = " .. tostring(ok))
end

--@api-stub: LProvinceRegistry:setAttr
do
    local reg = lurek.province.newFromPng("attrs", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setAttr(province_id, "owner", "player1")
    end

    print("province_id = " .. tostring(province_id))
    print("applied = " .. tostring(ok))
end

--@api-stub: LProvinceRegistry:setBorderType
do
    local reg = lurek.province.newFromPng("borders_set", "assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]

    reg:registerBorderType(1, { name = "coast", color = { 60, 120, 180, 255 }, thickness = 2.0 })
    if pair then
        reg:setBorderType(pair.province_a, pair.province_b, 1)
    end

    print("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    print("border type = " .. tostring(pair and reg:getBorderType(pair.province_a, pair.province_b)))
end

--@api-stub: LProvinceRegistry:getBorderType
do
    local reg = lurek.province.newFromPng("borders_get", "assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]

    reg:registerBorderType(2, { name = "river", color = { 50, 140, 220, 255 }, thickness = 1.5 })
    if pair then
        reg:setBorderType(pair.province_a, pair.province_b, 2)
    end

    print("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    print("border type = " .. tostring(pair and reg:getBorderType(pair.province_a, pair.province_b)))
end

--@api-stub: LProvinceRegistry:getRevision
do
    local reg = lurek.province.newFromPng("changes_revision", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local before = reg:getRevision()

    if province_id then
        reg:setPoliticalColor(province_id, 1.0, 0.0, 0.0, 1.0)
    end

    print("revision before = " .. tostring(before))
    print("revision after = " .. tostring(reg:getRevision()))
end

--@api-stub: LProvinceRegistry:getChangesSince
do
    local reg = lurek.province.newFromPng("changes_since", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local revision = reg:getRevision()

    if province_id then
        reg:setPoliticalColor(province_id, 1.0, 0.0, 0.0, 1.0)
    end

    local changes = reg:getChangesSince(revision)
    local first_change = changes[1]

    print("change count = " .. tostring(#changes))
    print("first kind = " .. tostring(first_change and first_change.kind))
end

--@api-stub: LProvinceRegistry:borderSegments
do
    local reg = lurek.province.newFromPng("geo_segments", "assets/textures/province_map.png")
    local segments = reg:borderSegments()
    local first = segments[1]

    print("segment count = " .. tostring(#segments))
    print("first pair = " .. tostring(first and first.province_a) .. ", " .. tostring(first and first.province_b))
end

--@api-stub: LProvinceRegistry:provinceSpans
do
    local reg = lurek.province.newFromPng("geo_spans", "assets/textures/province_map.png")
    local spans = reg:provinceSpans()
    local first = spans[1]

    print("span count = " .. tostring(#spans))
    print("first span province = " .. tostring(first and first.province_id))
end

--@api-stub: LProvinceRegistry:fitCamera
do
    local reg = lurek.province.newFromPng("cam_fit", "assets/textures/province_map.png")
    local cam_x, cam_y, zoom = reg:fitCamera(800, 600, 1.0)

    print("camera x = " .. tostring(cam_x))
    print("camera y = " .. tostring(cam_y))
    print("zoom = " .. tostring(zoom))
end

--@api-stub: LProvinceRegistry:screenToMap
do
    local reg = lurek.province.newFromPng("cam_map", "assets/textures/province_map.png")
    local cam_x, cam_y, zoom = reg:fitCamera(800, 600, 1.0)
    local map_x, map_y = reg:screenToMap(400, 300, cam_x, cam_y, zoom, 1.0)

    print("map x = " .. tostring(map_x))
    print("map y = " .. tostring(map_y))
end

--@api-stub: LProvinceRegistry:screenToProvince
do
    local reg = lurek.province.newFromPng("cam_province", "assets/textures/province_map.png")
    local cam_x, cam_y, zoom = reg:fitCamera(800, 600, 1.0)
    local province_id = reg:screenToProvince(400, 300, cam_x, cam_y, zoom, 1.0)

    print("province at center = " .. tostring(province_id))
end

--@api-stub: lurek.province.zoomCameraAt
do
    local cam_x = 100
    local cam_y = 80
    local new_cam_x, new_cam_y = lurek.province.zoomCameraAt(400, 300, cam_x, cam_y, 1.0, 2.0)

    print("old camera = " .. tostring(cam_x) .. ", " .. tostring(cam_y))
    print("new camera = " .. tostring(new_cam_x) .. ", " .. tostring(new_cam_y))
end

--@api-stub: lurek.province.setActive
do
    lurek.province.newFromPng("map_a", "assets/textures/province_map.png")
    lurek.province.newFromPng("map_b", "assets/textures/province_map.png")

    local set_a = lurek.province.setActive("map_a")
    local active_a = lurek.province.getActive()
    local set_b = lurek.province.setActive("map_b")
    local active_b = lurek.province.getActive()

    print("set map_a = " .. tostring(set_a) .. " -> " .. tostring(active_a and active_a:getName()))
    print("set map_b = " .. tostring(set_b) .. " -> " .. tostring(active_b and active_b:getName()))
end

--@api-stub: LProvinceRegistry:render
do
    local reg = lurek.province.newFromPng("render", "assets/textures/province_map.png")
    local cam_x, cam_y, zoom = reg:fitCamera(800, 600, 1.0)

    reg:render({
        map_mode = "political",
        x = cam_x,
        y = cam_y,
        zoom = zoom,
        pixel_size = 1.0,
        screen_w = 800,
        screen_h = 600,
        draw_fills = true,
        draw_borders = true,
        draw_labels = true,
        draw_capitals = true,
        border_width = 1.5,
        hovered_id = 0,
        selected_id = 0,
    })

    print("rendered registry = " .. reg:getName())
    print("zoom = " .. tostring(zoom))
end

--@api-stub: LProvinceRegistry:type
do
    local reg = lurek.province.newFromPng("typed_name", "assets/textures/province_map.png")

    print("type = " .. reg:type())
end

--@api-stub: LProvinceRegistry:typeOf
do
    local reg = lurek.province.newFromPng("typed_check", "assets/textures/province_map.png")

    print("is registry = " .. tostring(reg:typeOf("LProvinceRegistry")))
    print("is object = " .. tostring(reg:typeOf("LObject")))
end

--@api-stub: LProvinceRegistry:getName
do
    local reg = lurek.province.newFromPng("test_reg", "assets/textures/province_map.png")

    print("name = " .. reg:getName())
end

--@api-stub: LProvinceRegistry:importMetadataFromFiles
do
    local reg = lurek.province.newFromPng("meta_import", "content/games/strategy/eu2/map.png")
    local summary = reg:importMetadataFromFiles({
        color_map_png = "content/games/strategy/eu2/map.png",
        marker_png = "content/games/strategy/eu2/map.png",
        color_csv = "content/games/strategy/eu2/prov_cols.csv",
        province_toml = "content/games/strategy/eu2/province.toml",
    })

    print("mapped provinces = " .. tostring(summary.mapped_provinces))
    print("capitals set = " .. tostring(summary.capitals_set))
    print("labels set = " .. tostring(summary.labels_set))
end

--@api-stub: lurek.province.exists
do
    lurek.province.newFromPng("check_reg_exists", "assets/textures/province_map.png")

    print("exists = " .. tostring(lurek.province.exists("check_reg_exists")))
end

--@api-stub: lurek.province.get
do
    lurek.province.newFromPng("check_reg_get", "assets/textures/province_map.png")
    local reg = lurek.province.get("check_reg_get")

    print("found = " .. tostring(reg ~= nil))
    print("name = " .. tostring(reg and reg:getName()))
end

--@api-stub: lurek.province.getActive
do
    lurek.province.newFromPng("check_reg_active", "assets/textures/province_map.png")
    lurek.province.setActive("check_reg_active")

    local reg = lurek.province.getActive()

    print("active exists = " .. tostring(reg ~= nil))
    print("active name = " .. tostring(reg and reg:getName()))
end

--@api-stub: lurek.province.remove
do
    lurek.province.newFromPng("check_reg_remove", "assets/textures/province_map.png")
    local removed = lurek.province.remove("check_reg_remove")

    print("removed = " .. tostring(removed))
    print("exists after = " .. tostring(lurek.province.exists("check_reg_remove")))
end

--@api-stub: lurek.province.sanitizeMarkedPng
do
    local summary = lurek.province.sanitizeMarkedPng(
        "content/examples/assets/images/sample_texture.png",
        "save/province_sanitized.png",
        {}
    )

    print("replaced pixels = " .. tostring(summary.replaced_pixels))
    print("unresolved pixels = " .. tostring(summary.unresolved_pixels))
end

--@api-stub: lurek.province.setProperty
do
    local reg = lurek.province.newFromPng("prop_set", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setProperty(province_id, "tax_rate", 0.15)
    end

    print("province_id = " .. tostring(province_id))
    print("tax_rate = " .. tostring(province_id and lurek.province.getProperty(province_id, "tax_rate")))
end

--@api-stub: lurek.province.getProperty
do
    local reg = lurek.province.newFromPng("prop_get", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setProperty(province_id, "population", 50000)
    end

    print("province_id = " .. tostring(province_id))
    print("population = " .. tostring(province_id and lurek.province.getProperty(province_id, "population")))
end

--@api-stub: lurek.province.setAttr
do
    local reg = lurek.province.newFromPng("attr_set", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setAttr(province_id, "terrain", "forest")
    end

    print("province_id = " .. tostring(province_id))
    print("terrain = " .. tostring(province_id and lurek.province.getAttr(province_id, "terrain")))
end

--@api-stub: lurek.province.getAttr
do
    local reg = lurek.province.newFromPng("attr_get", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setAttr(province_id, "climate", "temperate")
    end

    print("province_id = " .. tostring(province_id))
    print("climate = " .. tostring(province_id and lurek.province.getAttr(province_id, "climate")))
end

--@api-stub: lurek.province.setFlag
do
    local reg = lurek.province.newFromPng("flag_set", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setFlag(province_id, 1, true)
    end

    print("province_id = " .. tostring(province_id))
    print("flag 1 = " .. tostring(province_id and lurek.province.hasFlag(province_id, 1)))
end

--@api-stub: lurek.province.hasFlag
do
    local reg = lurek.province.newFromPng("flag_get", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setFlag(province_id, 2, true)
    end

    print("province_id = " .. tostring(province_id))
    print("flag 2 = " .. tostring(province_id and lurek.province.hasFlag(province_id, 2)))
end

--@api-stub: lurek.province.clearProperties
do
    local reg = lurek.province.newFromPng("prop_clear", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setProperty(province_id, "temp_val", 42)
        lurek.province.clearProperties(province_id)
    end

    print("province_id = " .. tostring(province_id))
    print("temp_val = " .. tostring(province_id and lurek.province.getProperty(province_id, "temp_val")))
end

--@api-stub: LProvinceRegistry:getBorderClass
do
    local reg = lurek.province.newFromPng("border_class_get", "assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]

    reg:registerBorderType(3, { name = "sea", color = { 30, 80, 180, 255 }, thickness = 2.0 })
    if pair then
        reg:setBorderClass(pair.province_a, pair.province_b, 3)
    end

    print("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    print("border class = " .. tostring(pair and reg:getBorderClass(pair.province_a, pair.province_b)))
end

--@api-stub: LProvinceRegistry:setBorderClass
do
    local reg = lurek.province.newFromPng("border_class_set", "assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]
    local ok = false

    reg:registerBorderType(4, { name = "contested", color = { 220, 90, 60, 255 }, thickness = 2.5 })
    if pair then
        reg:setBorderClass(pair.province_a, pair.province_b, 4)
        ok = true
    end

    print("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    print("applied = " .. tostring(ok))
end

--@api-stub: LProvinceRegistry:registerBorderType
do
    local reg = lurek.province.newFromPng("border_type_register", "assets/textures/province_map.png")
    local pairs = reg:adjacencies()

    reg:registerBorderType(5, { name = "river", color = { 40, 120, 210, 255 }, thickness = 2.0, draw_priority = 1 })

    print("registered type = 5")
    print("adjacency pairs = " .. tostring(#pairs))
end

--@api-stub: LProvinceRegistry:setBorderPairStyle
do
    local reg = lurek.province.newFromPng("border_pair_set", "assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]
    local ok = false

    if pair then
        ok = reg:setBorderPairStyle(pair.province_a, pair.province_b, {
            color = { 1.0, 0.2, 0.2, 1.0 },
            thickness = 3.0,
            flags = { "war", "country" },
        })
    end

    print("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    print("applied = " .. tostring(ok))
end

--@api-stub: LProvinceRegistry:getBorderPairStyle
do
    local reg = lurek.province.newFromPng("border_pair_get", "assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]
    local style = nil

    if pair then
        reg:setBorderPairStyle(pair.province_a, pair.province_b, {
            color = { 0.2, 0.8, 0.4, 1.0 },
            thickness = 2.5,
            flags = { "alliance" },
        })
        style = reg:getBorderPairStyle(pair.province_a, pair.province_b)
    end

    print("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    print("thickness = " .. tostring(style and style.thickness))
    print("flag count = " .. tostring(style and style.flags and #style.flags or 0))
end

--@api-stub: LProvinceRegistry:registerMapMode
do
    local reg = lurek.province.newFromPng("map_mode_register", "assets/textures/province_map.png")

    reg:registerMapMode("economy", {
        show_labels = true,
        show_borders = true,
        show_roads = false,
        show_capitals = true,
        show_values = true,
        value_property = "income",
        color_property = "income_color",
        fog_intensity = 0.25,
        border_filter = { 1, 2 },
    })

    print("registered mode = economy")
    print("current mode = " .. reg:getMapMode())
end

--@api-stub: LProvinceRegistry:setMapMode
do
    local reg = lurek.province.newFromPng("map_mode_set", "assets/textures/province_map.png")

    reg:registerMapMode("terrain_view", {
        show_labels = true,
        show_borders = true,
        show_roads = false,
        show_capitals = true,
        fog_intensity = 0.4,
    })

    local ok = reg:setMapMode("terrain_view")

    print("applied = " .. tostring(ok))
    print("mode = " .. reg:getMapMode())
end

--@api-stub: LProvinceRegistry:getMapMode
do
    local reg = lurek.province.newFromPng("map_mode_get", "assets/textures/province_map.png")

    reg:registerMapMode("political_plus", {
        show_labels = true,
        show_borders = true,
        show_roads = true,
        show_capitals = true,
    })
    reg:setMapMode("political_plus")

    print("mode = " .. reg:getMapMode())
end
