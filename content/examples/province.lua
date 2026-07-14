-- content/examples/province.lua
-- Auto-generated from content/examples2/province_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/province.lua



--@api: lurek.province.newFromPng
do
    if not lurek.province.__example_cache_installed then
        local original_new_from_png = lurek.province.newFromPng
        local shared_by_path = {
            ["content/examples/assets/textures/province_map.png"] = "province_example_cached_texture",
            ["content/examples/assets/province/map.png"] = "province_example_cached_meta",
        }
        local bypass_cache = {
            province_example_new_from_png = true,
            map_a = true,
            map_b = true,
            province_example_get_name = true,
            province_example_exists = true,
            province_example_get = true,
            check_reg_active = true,
            province_example_remove = true,
        }
        lurek.province.newFromPng = function(name, path)
            local shared_name = shared_by_path[path]
            if shared_name and not bypass_cache[name] then
                local cached = lurek.province.get(shared_name)
                if cached then
                    return cached
                end
                return original_new_from_png(shared_name, path)
            end
            return original_new_from_png(name, path)
        end
        lurek.province.__example_cache_installed = true
    end

    local reg = lurek.province.newFromPng("province_example_new_from_png", "content/examples/assets/textures/province_map.png")
    local width = reg:getWidth()
    local height = reg:getHeight()
    local ids = reg:provinceIds()
    local first_id = ids[1]
    local first_neighbors = first_id and #reg:getNeighbors(first_id) or 0
    lurek.log.info("campaign map loaded name=" .. reg:getName() .. " size=" .. tostring(width) .. "x" .. tostring(height) .. " provinces=" .. tostring(#ids) .. " frontier_neighbors=" .. tostring(first_neighbors))
end

--@api: LProvinceRegistry:getWidth
do

    local reg = lurek.province.newFromPng("province_example_get_width", "content/examples/assets/textures/province_map.png")
    local width = reg:getWidth()
    local height = reg:getHeight()
    local pixel_area = width * height
    local provinces = reg:provinceCount()
    local density = provinces > 0 and pixel_area / provinces or 0
    lurek.log.info("atlas width for campaign layout width=" .. tostring(width) .. " height=" .. tostring(height) .. " avg_pixels_per_province=" .. tostring(density))
end

--@api: LProvinceRegistry:getHeight
do

    local reg = lurek.province.newFromPng("province_example_get_height", "content/examples/assets/textures/province_map.png")
    local height = reg:getHeight()
    local width = reg:getWidth()
    local screen_h = 600
    local row_scale = height > 0 and screen_h / height or 0
    local ids = reg:provinceIds()
    lurek.log.info("atlas height for viewport height=" .. tostring(height) .. " width=" .. tostring(width) .. " provinces=" .. tostring(#ids) .. " screen_rows_per_map_row=" .. tostring(row_scale))
end

--@api: LProvinceRegistry:provinceCount
do

    local reg = lurek.province.newFromPng("province_example_province_count", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local count = reg:provinceCount()
    local first_id = ids[1]
    local first_neighbors = first_id and reg:getNeighbors(first_id) or {}
    local matches_id_list = count == #ids
    lurek.log.info("campaign summary provinces=" .. tostring(count) .. " ids_listed=" .. tostring(#ids) .. " first_frontier_size=" .. tostring(#first_neighbors) .. " counts_match=" .. tostring(matches_id_list))
end

--@api: LProvinceRegistry:provinceIds
do

    local reg = lurek.province.newFromPng("info_ids", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()

    lurek.log.info("id count = " .. tostring(#ids))
    lurek.log.info("first id = " .. tostring(ids[1]))
    lurek.log.info("last id = " .. tostring(ids[#ids]))
end

--@api: LProvinceRegistry:getAt
do

    local reg = lurek.province.newFromPng("province_example_get_at", "content/examples/assets/textures/province_map.png")
    local scout_x = 50
    local scout_y = 50
    local hovered_id = reg:getAt(scout_x, scout_y)
    local coast_id = reg:getAt(0, 0)
    local hovered_snap = hovered_id and hovered_id ~= 0 and reg:getProvince(hovered_id) or nil
    lurek.log.info("cell probe scout_x=" .. tostring(scout_x) .. " scout_y=" .. tostring(scout_y) .. " hovered_id=" .. tostring(hovered_id) .. " hovered_revision=" .. tostring(hovered_snap and hovered_snap.revision) .. " origin_id=" .. tostring(coast_id))
end

--@api: LProvinceRegistry:getNeighbors
do

    local reg = lurek.province.newFromPng("adj", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local neighbors = province_id and reg:getNeighbors(province_id) or {}

    lurek.log.info("province id = " .. tostring(province_id))
    lurek.log.info("neighbor count = " .. tostring(#neighbors))
end

--@api: LProvinceRegistry:adjacencies
do

    local reg = lurek.province.newFromPng("pairs", "content/examples/assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]

    lurek.log.info("adjacency pairs = " .. tostring(#pairs))
    lurek.log.info("first pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
end

--@api: LProvinceRegistry:getProvince
do

    local reg = lurek.province.newFromPng("snap", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local snap = province_id and reg:getProvince(province_id) or nil

    lurek.log.info("province_id = " .. tostring(snap and snap.province_id))
    lurek.log.info("revision = " .. tostring(snap and snap.revision))
    lurek.log.info("terrain type = " .. tostring(snap and snap.style and snap.style.terrain_type))
end

--@api: LProvinceRegistry:setPoliticalColor
do

    local reg = lurek.province.newFromPng("colors", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setPoliticalColor(province_id, 0.8, 0.2, 0.2, 1.0)
    end

    lurek.log.info("province_id = " .. tostring(province_id))
    lurek.log.info("applied = " .. tostring(ok))
end

--@api: LProvinceRegistry:setTerrainType
do

    local reg = lurek.province.newFromPng("style_terrain", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setTerrainType(province_id, 1)
    end

    lurek.log.info("province_id = " .. tostring(province_id))
    lurek.log.info("applied = " .. tostring(ok))
end

--@api: LProvinceRegistry:setFogState
do

    local reg = lurek.province.newFromPng("style_fog", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setFogState(province_id, 1)
    end

    lurek.log.info("province_id = " .. tostring(province_id))
    lurek.log.info("applied = " .. tostring(ok))
end

--@api: LProvinceRegistry:setVisibilityState
do

    local reg = lurek.province.newFromPng("style_visibility", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setVisibilityState(province_id, 2)
    end

    lurek.log.info("province_id = " .. tostring(province_id))
    lurek.log.info("applied = " .. tostring(ok))
end

--@api: LProvinceRegistry:setVisualState
do

    local reg = lurek.province.newFromPng("style_visual", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setVisualState(province_id, {
            climate = "temperate",
            weather = "rain",
            weather_strength = 0.55,
            effect_flags = { "waves", "fog_noise" },
            seed = 4242,
        })
    end

    lurek.log.info("province_id = " .. tostring(province_id))
    lurek.log.info("applied = " .. tostring(ok))
end

--@api: LProvinceRegistry:setBorderStyle
do

    local reg = lurek.province.newFromPng("style_border", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setBorderStyle(province_id, 2)
    end

    lurek.log.info("province_id = " .. tostring(province_id))
    lurek.log.info("applied = " .. tostring(ok))
end

--@api: LProvinceRegistry:setLabelText
do

    local reg = lurek.province.newFromPng("labels_text", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setLabelText(province_id, "Nordland")
    end

    lurek.log.info("province_id = " .. tostring(province_id))
    lurek.log.info("applied = " .. tostring(ok))
end

--@api: LProvinceRegistry:setLabelLine
do

    local reg = lurek.province.newFromPng("labels_line", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setLabelLine(province_id, 10, 20, 50, 20)
    end

    lurek.log.info("province_id = " .. tostring(province_id))
    lurek.log.info("applied = " .. tostring(ok))
end

--@api: LProvinceRegistry:setCapital
do

    local reg = lurek.province.newFromPng("labels_capital", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setCapital(province_id, 30, 25)
    end

    lurek.log.info("province_id = " .. tostring(province_id))
    lurek.log.info("applied = " .. tostring(ok))
end

--@api: LProvinceRegistry:setAttr
do

    local reg = lurek.province.newFromPng("attrs", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setAttr(province_id, "owner", "player1")
    end

    lurek.log.info("province_id = " .. tostring(province_id))
    lurek.log.info("applied = " .. tostring(ok))
end

--@api: LProvinceRegistry:setBorderType
do

    local reg = lurek.province.newFromPng("borders_set", "content/examples/assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]

    reg:registerBorderType(1, { name = "coast", color = { 60, 120, 180, 255 }, thickness = 2.0 })
    if pair then
        reg:setBorderType(pair.province_a, pair.province_b, 1)
    end

    lurek.log.info("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    lurek.log.info("border type = " .. tostring(pair and reg:getBorderType(pair.province_a, pair.province_b)))
end

--@api: LProvinceRegistry:getBorderType
do

    local reg = lurek.province.newFromPng("borders_get", "content/examples/assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]

    reg:registerBorderType(2, { name = "river", color = { 50, 140, 220, 255 }, thickness = 1.5 })
    if pair then
        reg:setBorderType(pair.province_a, pair.province_b, 2)
    end

    lurek.log.info("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    lurek.log.info("border type = " .. tostring(pair and reg:getBorderType(pair.province_a, pair.province_b)))
end

--@api: LProvinceRegistry:getRevision
do

    local reg = lurek.province.newFromPng("changes_revision", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local before = reg:getRevision()

    if province_id then
        reg:setPoliticalColor(province_id, 1.0, 0.0, 0.0, 1.0)
    end

    lurek.log.info("revision before = " .. tostring(before))
    lurek.log.info("revision after = " .. tostring(reg:getRevision()))
end

--@api: LProvinceRegistry:getChangesSince
do

    local reg = lurek.province.newFromPng("changes_since", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local revision = reg:getRevision()

    if province_id then
        reg:setPoliticalColor(province_id, 1.0, 0.0, 0.0, 1.0)
    end

    local changes = reg:getChangesSince(revision)
    local first_change = changes[1]

    lurek.log.info("change count = " .. tostring(#changes))
    lurek.log.info("first kind = " .. tostring(first_change and first_change.kind))
end

--@api: LProvinceRegistry:borderSegments
do

    local reg = lurek.province.newFromPng("geo_segments", "content/examples/assets/textures/province_map.png")
    local segments = reg:borderSegments()
    local first = segments[1]

    lurek.log.info("segment count = " .. tostring(#segments))
    lurek.log.info("first pair = " .. tostring(first and first.province_a) .. ", " .. tostring(first and first.province_b))
end

--@api: LProvinceRegistry:provinceSpans
do

    local reg = lurek.province.newFromPng("geo_spans", "content/examples/assets/textures/province_map.png")
    local spans = reg:provinceSpans()
    local first = spans[1]

    lurek.log.info("span count = " .. tostring(#spans))
    lurek.log.info("first span province = " .. tostring(first and first.province_id))
end

--@api: LProvinceRegistry:fitCamera
do

    local reg = lurek.province.newFromPng("cam_fit", "content/examples/assets/textures/province_map.png")
    local cam_x, cam_y, zoom = reg:fitCamera(800, 600, 1.0)

    lurek.log.info("camera x = " .. tostring(cam_x))
    lurek.log.info("camera y = " .. tostring(cam_y))
    lurek.log.info("zoom = " .. tostring(zoom))
end

--@api: LProvinceRegistry:screenToMap
do

    local reg = lurek.province.newFromPng("cam_map", "content/examples/assets/textures/province_map.png")
    local cam_x, cam_y, zoom = reg:fitCamera(800, 600, 1.0)
    local map_x, map_y = reg:screenToMap(400, 300, cam_x, cam_y, zoom, 1.0)

    lurek.log.info("map x = " .. tostring(map_x))
    lurek.log.info("map y = " .. tostring(map_y))
end

--@api: LProvinceRegistry:screenToProvince
do

    local reg = lurek.province.newFromPng("province_example_screen_to_province", "content/examples/assets/textures/province_map.png")
    local cam_x, cam_y, zoom = reg:fitCamera(800, 600, 1.0)
    local map_x, map_y = reg:screenToMap(400, 300, cam_x, cam_y, zoom, 1.0)
    local province_id = reg:screenToProvince(400, 300, cam_x, cam_y, zoom, 1.0)
    local province = province_id and reg:getProvince(province_id) or nil
    lurek.log.info("screen pick center province=" .. tostring(province_id) .. " map_x=" .. tostring(map_x) .. " map_y=" .. tostring(map_y) .. " visible_terrain=" .. tostring(province and province.style and province.style.terrain_type))
end

--@api: LProvinceRegistry:viewportRect
do

    local reg = lurek.province.newFromPng("province_example_viewport_rect", "content/examples/assets/textures/province_map.png")
    local rect = reg:viewportRect({
        x = -24,
        y = -16,
        zoom = 2.0,
        pixel_size = 1.0,
        screen_w = 320,
        screen_h = 180,
    })
    lurek.log.info("viewport rect = " .. tostring(rect.x) .. "," .. tostring(rect.y) .. " size=" .. tostring(rect.w) .. "x" .. tostring(rect.h))
end

--@api: lurek.province.zoomCameraAt
do

    local cam_x = 100
    local cam_y = 80
    local new_cam_x, new_cam_y = lurek.province.zoomCameraAt(400, 300, cam_x, cam_y, 1.0, 2.0)

    lurek.log.info("old camera = " .. tostring(cam_x) .. ", " .. tostring(cam_y))
    lurek.log.info("new camera = " .. tostring(new_cam_x) .. ", " .. tostring(new_cam_y))
end

--@api: lurek.province.setActive
do

    lurek.province.newFromPng("map_a", "content/examples/assets/textures/province_map.png")
    lurek.province.newFromPng("map_b", "content/examples/assets/textures/province_map.png")

    local set_a = lurek.province.setActive("map_a")
    local active_a = lurek.province.getActive()
    local set_b = lurek.province.setActive("map_b")
    local active_b = lurek.province.getActive()

    lurek.log.info("set map_a = " .. tostring(set_a) .. " -> " .. tostring(active_a and active_a:getName()))
    lurek.log.info("set map_b = " .. tostring(set_b) .. " -> " .. tostring(active_b and active_b:getName()))
end

--@api: LProvinceRegistry:render
do

    local reg = lurek.province.newFromPng("render", "content/examples/assets/textures/province_map.png")
    local cam_x, cam_y, zoom = reg:fitCamera(320, 180, 1.0)
    local ids = reg:provinceIds()
    local tints = {}
    if ids[1] then
        tints[ids[1]] = { 0.2, 0.6, 1.0, 1.0 }
    end
    if ids[2] then
        tints[ids[2]] = { 0.9, 0.35, 0.2, 1.0 }
    end

    reg:render({
        backend = "commands",
        map_mode = "political",
        x = cam_x,
        y = cam_y,
        zoom = zoom,
        pixel_size = 1.0,
        screen_w = 320,
        screen_h = 180,
        draw_fills = true,
        draw_borders = true,
        draw_labels = false,
        draw_capitals = false,
        province_tints = tints,
        border_width = 1.0,
        hovered_id = 0,
        selected_id = 0,
    })

    lurek.log.info("rendered registry = " .. reg:getName())
    lurek.log.info("zoom = " .. tostring(zoom))
end

--@api: LProvinceRegistry:type
do

    local reg = lurek.province.newFromPng("province_example_type", "content/examples/assets/textures/province_map.png")
    local type_name = reg:type()
    local matches_registry = reg:typeOf("LProvinceRegistry")
    local name = reg:getName()
    local provinces = reg:provinceCount()
    lurek.log.info("registry type inspection type=" .. tostring(type_name) .. " matches_registry=" .. tostring(matches_registry) .. " name=" .. tostring(name) .. " provinces=" .. tostring(provinces))
end

--@api: LProvinceRegistry:typeOf
do

    local reg = lurek.province.newFromPng("province_example_type_of", "content/examples/assets/textures/province_map.png")
    local is_registry = reg:typeOf("LProvinceRegistry")
    local is_object = reg:typeOf("Object")
    local is_camera = reg:typeOf("LCamera")
    local width = reg:getWidth()
    lurek.log.info("type guard registry=" .. tostring(is_registry) .. " object=" .. tostring(is_object) .. " camera=" .. tostring(is_camera) .. " width=" .. tostring(width))
end

--@api: LProvinceRegistry:getName
do

    local reg = lurek.province.newFromPng("province_example_get_name", "content/examples/assets/textures/province_map.png")
    local name = reg:getName()
    local set_active = lurek.province.setActive(name)
    local active = lurek.province.getActive()
    local provinces = reg:provinceCount()
    lurek.log.info("registry naming active_set=" .. tostring(set_active) .. " name=" .. tostring(name) .. " active_name=" .. tostring(active and active:getName()) .. " provinces=" .. tostring(provinces))
end

--@api: LProvinceRegistry:importMetadataFromFiles
do

    local reg = lurek.province.newFromPng("meta_import", "content/examples/assets/province/map.png")
    local summary = reg:importMetadataFromFiles({
        color_map_png = "content/examples/assets/province/map.png",
        color_csv = "content/examples/assets/province/prov_cols.csv",
    })

    lurek.log.info("mapped provinces = " .. tostring(summary.mapped_provinces))
    lurek.log.info("capitals set = " .. tostring(summary.capitals_set))
    lurek.log.info("labels set = " .. tostring(summary.labels_set))
end

--@api: lurek.province.exists
do

    local reg = lurek.province.newFromPng("province_example_exists", "content/examples/assets/textures/province_map.png")
    local name = reg:getName()
    local exists_now = lurek.province.exists(name)
    local fetched = lurek.province.get(name)
    local missing = lurek.province.exists(name .. "_missing")
    lurek.log.info("registry lookup exists=" .. tostring(exists_now) .. " fetched=" .. tostring(fetched ~= nil) .. " missing_variant=" .. tostring(missing) .. " name=" .. tostring(name))
end

--@api: lurek.province.get
do

    local created = lurek.province.newFromPng("province_example_get", "content/examples/assets/textures/province_map.png")
    local name = created:getName()
    local reg = lurek.province.get(name)
    local province_total = reg and reg:provinceCount() or 0
    local width = reg and reg:getWidth() or 0
    lurek.log.info("registry fetch by name found=" .. tostring(reg ~= nil) .. " requested=" .. tostring(name) .. " fetched_name=" .. tostring(reg and reg:getName()) .. " provinces=" .. tostring(province_total) .. " width=" .. tostring(width))
end

--@api: lurek.province.getActive
do

    lurek.province.newFromPng("check_reg_active", "content/examples/assets/textures/province_map.png")
    lurek.province.setActive("check_reg_active")

    local reg = lurek.province.getActive()

    lurek.log.info("active exists = " .. tostring(reg ~= nil))
    lurek.log.info("active name = " .. tostring(reg and reg:getName()))
end

--@api: lurek.province.remove
do

    local reg = lurek.province.newFromPng("province_example_remove", "content/examples/assets/textures/province_map.png")
    local name = reg:getName()
    local existed_before = lurek.province.exists(name)
    local removed = lurek.province.remove(name)
    local exists_after = lurek.province.exists(name)
    lurek.log.info("registry teardown existed_before=" .. tostring(existed_before) .. " removed=" .. tostring(removed) .. " exists_after=" .. tostring(exists_after) .. " name=" .. tostring(name))
end

--@api: lurek.province.sanitizeMarkedPng
do

    local summary = lurek.province.sanitizeMarkedPng(
        "content/examples/assets/images/sample_texture.png",
        "save/province_sanitized.png",
        {}
    )

    lurek.log.info("replaced pixels = " .. tostring(summary.replaced_pixels))
    lurek.log.info("unresolved pixels = " .. tostring(summary.unresolved_pixels))
end

--@api: lurek.province.setProperty
do

    local reg = lurek.province.newFromPng("prop_set", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setProperty(province_id, "tax_rate", 0.15)
    end

    lurek.log.info("province_id = " .. tostring(province_id))
    lurek.log.info("tax_rate = " .. tostring(province_id and lurek.province.getProperty(province_id, "tax_rate")))
end

--@api: lurek.province.getProperty
do

    local reg = lurek.province.newFromPng("prop_get", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setProperty(province_id, "population", 50000)
    end

    lurek.log.info("province_id = " .. tostring(province_id))
    lurek.log.info("population = " .. tostring(province_id and lurek.province.getProperty(province_id, "population")))
end

--@api: lurek.province.setAttr
do

    local reg = lurek.province.newFromPng("attr_set", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setAttr(province_id, "terrain", "forest")
    end

    lurek.log.info("province_id = " .. tostring(province_id))
    lurek.log.info("terrain = " .. tostring(province_id and lurek.province.getAttr(province_id, "terrain")))
end

--@api: lurek.province.getAttr
do

    local reg = lurek.province.newFromPng("attr_get", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setAttr(province_id, "climate", "temperate")
    end

    lurek.log.info("province_id = " .. tostring(province_id))
    lurek.log.info("climate = " .. tostring(province_id and lurek.province.getAttr(province_id, "climate")))
end

--@api: lurek.province.setFlag
do

    local reg = lurek.province.newFromPng("flag_set", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setFlag(province_id, 1, true)
    end

    lurek.log.info("province_id = " .. tostring(province_id))
    lurek.log.info("flag 1 = " .. tostring(province_id and lurek.province.hasFlag(province_id, 1)))
end

--@api: lurek.province.hasFlag
do

    local reg = lurek.province.newFromPng("flag_get", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setFlag(province_id, 2, true)
    end

    lurek.log.info("province_id = " .. tostring(province_id))
    lurek.log.info("flag 2 = " .. tostring(province_id and lurek.province.hasFlag(province_id, 2)))
end

--@api: lurek.province.clearProperties
do

    local reg = lurek.province.newFromPng("prop_clear", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setProperty(province_id, "temp_val", 42)
        lurek.province.clearProperties(province_id)
    end

    lurek.log.info("province_id = " .. tostring(province_id))
    lurek.log.info("temp_val = " .. tostring(province_id and lurek.province.getProperty(province_id, "temp_val")))
end

--@api: LProvinceRegistry:getBorderClass
do

    local reg = lurek.province.newFromPng("border_class_get", "content/examples/assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]

    reg:registerBorderType(3, { name = "sea", color = { 30, 80, 180, 255 }, thickness = 2.0 })
    if pair then
        reg:setBorderClass(pair.province_a, pair.province_b, 3)
    end

    lurek.log.info("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    lurek.log.info("border class = " .. tostring(pair and reg:getBorderClass(pair.province_a, pair.province_b)))
end

--@api: LProvinceRegistry:setBorderClass
do

    local reg = lurek.province.newFromPng("border_class_set", "content/examples/assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]
    local ok = false

    reg:registerBorderType(4, { name = "contested", color = { 220, 90, 60, 255 }, thickness = 2.5 })
    if pair then
        reg:setBorderClass(pair.province_a, pair.province_b, 4)
        ok = true
    end

    lurek.log.info("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    lurek.log.info("applied = " .. tostring(ok))
end

--@api: LProvinceRegistry:registerBorderType
do

    local reg = lurek.province.newFromPng("border_type_register", "content/examples/assets/textures/province_map.png")
    local pairs = reg:adjacencies()

    reg:registerBorderType(5, { name = "river", color = { 40, 120, 210, 255 }, thickness = 2.0, draw_priority = 1 })

    lurek.log.info("registered type = 5")
    lurek.log.info("adjacency pairs = " .. tostring(#pairs))
end

--@api: LProvinceRegistry:setBorderPairStyle
do

    local reg = lurek.province.newFromPng("border_pair_set", "content/examples/assets/textures/province_map.png")
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

    lurek.log.info("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    lurek.log.info("applied = " .. tostring(ok))
end

--@api: LProvinceRegistry:getBorderPairStyle
do

    local reg = lurek.province.newFromPng("border_pair_get", "content/examples/assets/textures/province_map.png")
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

    lurek.log.info("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    lurek.log.info("thickness = " .. tostring(style and style.thickness))
    lurek.log.info("flag count = " .. tostring(style and style.flags and #style.flags or 0))
end

--@api: LProvinceRegistry:registerMapMode
do

    local reg = lurek.province.newFromPng("map_mode_register", "content/examples/assets/textures/province_map.png")

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

    lurek.log.info("registered mode = economy")
    lurek.log.info("current mode = " .. reg:getMapMode())
end

--@api: LProvinceRegistry:setMapMode
do

    local reg = lurek.province.newFromPng("map_mode_set", "content/examples/assets/textures/province_map.png")

    reg:registerMapMode("terrain_view", {
        show_labels = true,
        show_borders = true,
        show_roads = false,
        show_capitals = true,
        fog_intensity = 0.4,
    })

    local ok = reg:setMapMode("terrain_view")

    lurek.log.info("applied = " .. tostring(ok))
    lurek.log.info("mode = " .. reg:getMapMode())
end

--@api: LProvinceRegistry:getMapMode
do

    local reg = lurek.province.newFromPng("map_mode_get", "content/examples/assets/textures/province_map.png")

    reg:registerMapMode("political_plus", {
        show_labels = true,
        show_borders = true,
        show_roads = true,
        show_capitals = true,
    })
    reg:setMapMode("political_plus")

    lurek.log.info("mode = " .. reg:getMapMode())
end

--@api: LProvinceRegistry:findRoute
do

    local reg = lurek.province.newFromPng("province_example_find_route", "content/examples/assets/province/map.png")
    local ids = reg:provinceIds()
    local from_id = ids[1]
    local to_id = ids[#ids] or from_id
    local route = (from_id and to_id) and reg:findRoute(from_id, to_id, function(a, b) return a == b and 0.5 or 1.0 end) or nil
    local hop_count = route and #route or 0
    lurek.log.info("province route adapter from=" .. tostring(from_id) .. " to=" .. tostring(to_id) .. " hops=" .. tostring(hop_count) .. " reachable=" .. tostring(route ~= nil))
end

--@api: LProvinceRegistry:drawCapitalPath
do

    local reg = lurek.province.newFromPng("province_example_draw_capital_path", "content/examples/assets/province/map.png")
    local ids = reg:provinceIds()
    local route = (#ids >= 2) and reg:findRoute(ids[1], ids[#ids]) or nil
    local queued = route and reg:drawCapitalPath(route, {
        mode = "bezier",
        color = { 1.0, 0.86, 0.28, 0.95 },
        width = 3.0,
        curve_offset = 10.0,
        segments = 16,
    }) or 0
    lurek.log.info("capital path queued primitives = " .. tostring(queued))
end

--@api: LProvinceRegistry:findRoutes
do

    local reg = lurek.province.newFromPng("province_example_find_routes", "content/examples/assets/province/map.png")
    local ids = reg:provinceIds()
    local pairs = { { from = ids[1], to = ids[2] or ids[1] }, { from = ids[1], to = ids[#ids] or ids[1] } }
    local routes = reg:findRoutes(pairs, function(a, b) return a == b and 0.5 or 1.0 end)
    local first_route = routes and routes[1] or nil
    lurek.log.info("batch route adapter requests=" .. tostring(#pairs) .. " result_rows=" .. tostring(routes and #routes or 0) .. " first_hops=" .. tostring(first_route and #first_route or 0))
end

--@api: LProvinceRegistry:getConnectedComponents
do

    local reg = lurek.province.newFromPng("province_example_components", "content/examples/assets/province/map.png")
    local components = reg:getConnectedComponents()
    local first_component = components[1] or {}
    local province_total = reg:provinceCount()
    local first_size = #first_component
    local covers_all = first_size <= province_total
    lurek.log.info("province topology components groups=" .. tostring(#components) .. " first_group_size=" .. tostring(first_size) .. " province_total=" .. tostring(province_total) .. " sane=" .. tostring(covers_all))
end

--@api: LProvinceRegistry:findIsolatedProvinces
do

    local reg = lurek.province.newFromPng("province_example_isolated", "content/examples/assets/province/map.png")
    local ids = reg:provinceIds()
    local a = ids[1]
    local b = ids[2] or a
    local c = ids[3] or b
    if a then reg:setAttr(a, "faction", "player") end
    if b then reg:setAttr(b, "faction", "enemy") end
    if c then reg:setAttr(c, "faction", "player") end
    local isolated = reg:findIsolatedProvinces("faction")
    lurek.log.info("faction isolation isolated=" .. tostring(isolated and #isolated or 0) .. " seeded_ids=" .. tostring(a) .. "," .. tostring(b) .. "," .. tostring(c))
end

--@api: LProvinceRegistry:isConnected
do

    local reg = lurek.province.newFromPng("province_example_is_connected", "content/examples/assets/province/map.png")
    local ids = reg:provinceIds()
    local from_id = ids[1]
    local to_id = ids[2] or from_id
    local connected = (from_id and to_id) and reg:isConnected(from_id, to_id) or false
    local route = connected and reg:findRoute(from_id, to_id) or nil
    lurek.log.info("frontline connectivity adapter from=" .. tostring(from_id) .. " to=" .. tostring(to_id) .. " connected=" .. tostring(connected) .. " route_hops=" .. tostring(route and #route or 0))
end

--@api: LProvinceRegistry:totalAttrForOwner
do

    local reg = lurek.province.newFromPng("province_example_total_attr", "content/examples/assets/province/map.png")
    local ids = reg:provinceIds()
    local a = ids[1]
    local b = ids[2] or a
    local c = ids[3] or b
    if a then reg:setAttr(a, "faction", "player") reg:setAttr(a, "iron", "10") end
    if b then reg:setAttr(b, "faction", "enemy") reg:setAttr(b, "iron", "7") end
    if c then reg:setAttr(c, "faction", "player") reg:setAttr(c, "iron", "2.5") end
    local total = reg:totalAttrForOwner("faction", "player", "iron")
    lurek.log.info("owner resource total owner=player iron=" .. tostring(total) .. " seeded_ids=" .. tostring(a) .. "," .. tostring(b) .. "," .. tostring(c))
end

--@api: LProvinceRegistry:setShader
do

    local reg = lurek.province.newFromPng("province_example_set_shader", "content/examples/assets/province/map.png")
    local shader = lurek.render.newShader([[
@fragment
fn fs(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) pixel: vec2<f32>,
    @location(3) resolution: vec2<f32>,
    @location(4) texel: vec2<f32>
) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb * vec3<f32>(0.8, 1.0, 1.1) + uv.xyx * 0.0 + pixel.xyx * 0.0 + resolution.xyx * texel.x * 0.0, color.a);
}
]], { target = "mapviz" })
    reg:setShader(shader)
    reg:render({ backend = "commands", draw_labels = false })
    lurek.log.info("province mapviz shader target=" .. reg:getShader():getTarget())
end

--@api: LProvinceRegistry:getShader
do

    local reg = lurek.province.newFromPng("province_example_get_shader", "content/examples/assets/province/map.png")
    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + uv.xyx * 0.0, color.a);
}
]], { target = "mapviz" })
    reg:setShader(shader)
    local active = reg:getShader()
    lurek.log.info("active province mapviz shader=" .. tostring(active and active:getTarget() or "nil"))
end

--@api: LProvinceRegistry:resolveMapModeColors
do

    local reg = lurek.province.newFromPng("province_example_resolve_colors", "content/examples/assets/province/map.png")
    local ids = reg:provinceIds()
    local first = ids[1]
    if first then reg:setPoliticalColor(first, 0.3, 0.6, 0.9, 1.0) end
    local colors = reg:resolveMapModeColors(nil, { ids = { first } })
    lurek.log.info("resolved province colors = " .. tostring(colors and #colors or 0))
end

--@api: LProvinceRegistry:borderSegmentsWhere
do

    local reg = lurek.province.newFromPng("province_example_border_filter", "content/examples/assets/province/map.png")
    local ids = reg:provinceIds()
    local first = ids[1]
    local segments = reg:borderSegmentsWhere({ province = first })
    local all_segments = reg:borderSegments()
    lurek.log.info("filtered border segments = " .. tostring(#segments))
    lurek.log.info("all border segments = " .. tostring(#all_segments))
end
