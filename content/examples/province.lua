-- content/examples/province.lua
-- Auto-generated from content/examples2/province_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/province.lua



--@api: lurek.province.newFromPng
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = province_registry("new_from_png")
    local width = reg:getWidth()
    local height = reg:getHeight()
    local ids = reg:provinceIds()
    local first_id = ids[1]
    local first_neighbors = first_id and #reg:getNeighbors(first_id) or 0
    province_log("campaign map loaded name=" .. reg:getName() .. " size=" .. tostring(width) .. "x" .. tostring(height) .. " provinces=" .. tostring(#ids) .. " frontier_neighbors=" .. tostring(first_neighbors))
end

--@api: LProvinceRegistry:getWidth
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = province_registry("get_width")
    local width = reg:getWidth()
    local height = reg:getHeight()
    local pixel_area = width * height
    local provinces = reg:provinceCount()
    local density = provinces > 0 and pixel_area / provinces or 0
    province_log("atlas width for campaign layout width=" .. tostring(width) .. " height=" .. tostring(height) .. " avg_pixels_per_province=" .. tostring(density))
end

--@api: LProvinceRegistry:getHeight
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = province_registry("get_height")
    local height = reg:getHeight()
    local width = reg:getWidth()
    local screen_h = 600
    local row_scale = height > 0 and screen_h / height or 0
    local ids = reg:provinceIds()
    province_log("atlas height for viewport height=" .. tostring(height) .. " width=" .. tostring(width) .. " provinces=" .. tostring(#ids) .. " screen_rows_per_map_row=" .. tostring(row_scale))
end

--@api: LProvinceRegistry:provinceCount
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = province_registry("province_count")
    local ids = reg:provinceIds()
    local count = reg:provinceCount()
    local first_id = ids[1]
    local first_neighbors = first_id and reg:getNeighbors(first_id) or {}
    local matches_id_list = count == #ids
    province_log("campaign summary provinces=" .. tostring(count) .. " ids_listed=" .. tostring(#ids) .. " first_frontier_size=" .. tostring(#first_neighbors) .. " counts_match=" .. tostring(matches_id_list))
end

--@api: LProvinceRegistry:provinceIds
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("info_ids", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()

    province_log("id count = " .. tostring(#ids))
    province_log("first id = " .. tostring(ids[1]))
    province_log("last id = " .. tostring(ids[#ids]))
end

--@api: LProvinceRegistry:getAt
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = province_registry("get_at")
    local scout_x = 50
    local scout_y = 50
    local hovered_id = reg:getAt(scout_x, scout_y)
    local coast_id = reg:getAt(0, 0)
    local hovered_snap = hovered_id and hovered_id ~= 0 and reg:getProvince(hovered_id) or nil
    province_log("cell probe scout_x=" .. tostring(scout_x) .. " scout_y=" .. tostring(scout_y) .. " hovered_id=" .. tostring(hovered_id) .. " hovered_revision=" .. tostring(hovered_snap and hovered_snap.revision) .. " origin_id=" .. tostring(coast_id))
end

--@api: LProvinceRegistry:getNeighbors
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("adj", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local neighbors = province_id and reg:getNeighbors(province_id) or {}

    province_log("province id = " .. tostring(province_id))
    province_log("neighbor count = " .. tostring(#neighbors))
end

--@api: LProvinceRegistry:adjacencies
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("pairs", "content/examples/assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]

    province_log("adjacency pairs = " .. tostring(#pairs))
    province_log("first pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
end

--@api: LProvinceRegistry:getProvince
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("snap", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local snap = province_id and reg:getProvince(province_id) or nil

    province_log("province_id = " .. tostring(snap and snap.province_id))
    province_log("revision = " .. tostring(snap and snap.revision))
    province_log("terrain type = " .. tostring(snap and snap.style and snap.style.terrain_type))
end

--@api: LProvinceRegistry:setPoliticalColor
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("colors", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setPoliticalColor(province_id, 0.8, 0.2, 0.2, 1.0)
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("applied = " .. tostring(ok))
end

--@api: LProvinceRegistry:setTerrainType
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("style_terrain", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setTerrainType(province_id, 1)
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("applied = " .. tostring(ok))
end

--@api: LProvinceRegistry:setFogState
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("style_fog", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setFogState(province_id, 1)
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("applied = " .. tostring(ok))
end

--@api: LProvinceRegistry:setVisibilityState
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("style_visibility", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setVisibilityState(province_id, 2)
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("applied = " .. tostring(ok))
end

--@api: LProvinceRegistry:setBorderStyle
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("style_border", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setBorderStyle(province_id, 2)
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("applied = " .. tostring(ok))
end

--@api: LProvinceRegistry:setLabelText
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("labels_text", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setLabelText(province_id, "Nordland")
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("applied = " .. tostring(ok))
end

--@api: LProvinceRegistry:setLabelLine
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("labels_line", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setLabelLine(province_id, 10, 20, 50, 20)
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("applied = " .. tostring(ok))
end

--@api: LProvinceRegistry:setCapital
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("labels_capital", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setCapital(province_id, 30, 25)
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("applied = " .. tostring(ok))
end

--@api: LProvinceRegistry:setAttr
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("attrs", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setAttr(province_id, "owner", "player1")
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("applied = " .. tostring(ok))
end

--@api: LProvinceRegistry:setBorderType
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("borders_set", "content/examples/assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]

    reg:registerBorderType(1, { name = "coast", color = { 60, 120, 180, 255 }, thickness = 2.0 })
    if pair then
        reg:setBorderType(pair.province_a, pair.province_b, 1)
    end

    province_log("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    province_log("border type = " .. tostring(pair and reg:getBorderType(pair.province_a, pair.province_b)))
end

--@api: LProvinceRegistry:getBorderType
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("borders_get", "content/examples/assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]

    reg:registerBorderType(2, { name = "river", color = { 50, 140, 220, 255 }, thickness = 1.5 })
    if pair then
        reg:setBorderType(pair.province_a, pair.province_b, 2)
    end

    province_log("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    province_log("border type = " .. tostring(pair and reg:getBorderType(pair.province_a, pair.province_b)))
end

--@api: LProvinceRegistry:getRevision
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("changes_revision", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local before = reg:getRevision()

    if province_id then
        reg:setPoliticalColor(province_id, 1.0, 0.0, 0.0, 1.0)
    end

    province_log("revision before = " .. tostring(before))
    province_log("revision after = " .. tostring(reg:getRevision()))
end

--@api: LProvinceRegistry:getChangesSince
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("changes_since", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local revision = reg:getRevision()

    if province_id then
        reg:setPoliticalColor(province_id, 1.0, 0.0, 0.0, 1.0)
    end

    local changes = reg:getChangesSince(revision)
    local first_change = changes[1]

    province_log("change count = " .. tostring(#changes))
    province_log("first kind = " .. tostring(first_change and first_change.kind))
end

--@api: LProvinceRegistry:borderSegments
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("geo_segments", "content/examples/assets/textures/province_map.png")
    local segments = reg:borderSegments()
    local first = segments[1]

    province_log("segment count = " .. tostring(#segments))
    province_log("first pair = " .. tostring(first and first.province_a) .. ", " .. tostring(first and first.province_b))
end

--@api: LProvinceRegistry:provinceSpans
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("geo_spans", "content/examples/assets/textures/province_map.png")
    local spans = reg:provinceSpans()
    local first = spans[1]

    province_log("span count = " .. tostring(#spans))
    province_log("first span province = " .. tostring(first and first.province_id))
end

--@api: LProvinceRegistry:fitCamera
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("cam_fit", "content/examples/assets/textures/province_map.png")
    local cam_x, cam_y, zoom = reg:fitCamera(800, 600, 1.0)

    province_log("camera x = " .. tostring(cam_x))
    province_log("camera y = " .. tostring(cam_y))
    province_log("zoom = " .. tostring(zoom))
end

--@api: LProvinceRegistry:screenToMap
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("cam_map", "content/examples/assets/textures/province_map.png")
    local cam_x, cam_y, zoom = reg:fitCamera(800, 600, 1.0)
    local map_x, map_y = reg:screenToMap(400, 300, cam_x, cam_y, zoom, 1.0)

    province_log("map x = " .. tostring(map_x))
    province_log("map y = " .. tostring(map_y))
end

--@api: LProvinceRegistry:screenToProvince
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = province_registry("screen_to_province")
    local cam_x, cam_y, zoom = reg:fitCamera(800, 600, 1.0)
    local map_x, map_y = reg:screenToMap(400, 300, cam_x, cam_y, zoom, 1.0)
    local province_id = reg:screenToProvince(400, 300, cam_x, cam_y, zoom, 1.0)
    local province = province_id and reg:getProvince(province_id) or nil
    province_log("screen pick center province=" .. tostring(province_id) .. " map_x=" .. tostring(map_x) .. " map_y=" .. tostring(map_y) .. " visible_terrain=" .. tostring(province and province.style and province.style.terrain_type))
end

--@api: lurek.province.zoomCameraAt
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local cam_x = 100
    local cam_y = 80
    local new_cam_x, new_cam_y = lurek.province.zoomCameraAt(400, 300, cam_x, cam_y, 1.0, 2.0)

    province_log("old camera = " .. tostring(cam_x) .. ", " .. tostring(cam_y))
    province_log("new camera = " .. tostring(new_cam_x) .. ", " .. tostring(new_cam_y))
end

--@api: lurek.province.setActive
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    lurek.province.newFromPng("map_a", "content/examples/assets/textures/province_map.png")
    lurek.province.newFromPng("map_b", "content/examples/assets/textures/province_map.png")

    local set_a = lurek.province.setActive("map_a")
    local active_a = lurek.province.getActive()
    local set_b = lurek.province.setActive("map_b")
    local active_b = lurek.province.getActive()

    province_log("set map_a = " .. tostring(set_a) .. " -> " .. tostring(active_a and active_a:getName()))
    province_log("set map_b = " .. tostring(set_b) .. " -> " .. tostring(active_b and active_b:getName()))
end

--@api: LProvinceRegistry:render
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("render", "content/examples/assets/textures/province_map.png")
    local cam_x, cam_y, zoom = reg:fitCamera(800, 600, 1.0)
    local ids = reg:provinceIds()
    local tints = {}
    if ids[1] then
        tints[ids[1]] = { 0.2, 0.6, 1.0, 1.0 }
    end
    if ids[2] then
        tints[ids[2]] = { 0.9, 0.35, 0.2, 1.0 }
    end

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
        tint = { 0.92, 0.95, 1.0, 1.0 },
        province_tints = tints,
        border_width = 1.5,
        hovered_id = 0,
        selected_id = 0,
    })

    province_log("rendered registry = " .. reg:getName())
    province_log("zoom = " .. tostring(zoom))
end

--@api: LProvinceRegistry:type
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = province_registry("type")
    local type_name = reg:type()
    local matches_registry = reg:typeOf("LProvinceRegistry")
    local name = reg:getName()
    local provinces = reg:provinceCount()
    province_log("registry type inspection type=" .. tostring(type_name) .. " matches_registry=" .. tostring(matches_registry) .. " name=" .. tostring(name) .. " provinces=" .. tostring(provinces))
end

--@api: LProvinceRegistry:typeOf
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = province_registry("type_of")
    local is_registry = reg:typeOf("LProvinceRegistry")
    local is_object = reg:typeOf("Object")
    local is_camera = reg:typeOf("LCamera")
    local width = reg:getWidth()
    province_log("type guard registry=" .. tostring(is_registry) .. " object=" .. tostring(is_object) .. " camera=" .. tostring(is_camera) .. " width=" .. tostring(width))
end

--@api: LProvinceRegistry:getName
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = province_registry("get_name")
    local name = reg:getName()
    local set_active = lurek.province.setActive(name)
    local active = lurek.province.getActive()
    local provinces = reg:provinceCount()
    province_log("registry naming active_set=" .. tostring(set_active) .. " name=" .. tostring(name) .. " active_name=" .. tostring(active and active:getName()) .. " provinces=" .. tostring(provinces))
end

--@api: LProvinceRegistry:importMetadataFromFiles
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("meta_import", "content/examples/assets/province/map.png")
    local summary = reg:importMetadataFromFiles({
        color_map_png = "content/examples/assets/province/map.png",
        marker_png = "content/examples/assets/province/map.png",
        color_csv = "content/examples/assets/province/prov_cols.csv",
        province_toml = "content/examples/assets/province/province.toml",
    })

    province_log("mapped provinces = " .. tostring(summary.mapped_provinces))
    province_log("capitals set = " .. tostring(summary.capitals_set))
    province_log("labels set = " .. tostring(summary.labels_set))
end

--@api: lurek.province.exists
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = province_registry("exists")
    local name = reg:getName()
    local exists_now = lurek.province.exists(name)
    local fetched = lurek.province.get(name)
    local missing = lurek.province.exists(name .. "_missing")
    province_log("registry lookup exists=" .. tostring(exists_now) .. " fetched=" .. tostring(fetched ~= nil) .. " missing_variant=" .. tostring(missing) .. " name=" .. tostring(name))
end

--@api: lurek.province.get
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local created = province_registry("get")
    local name = created:getName()
    local reg = lurek.province.get(name)
    local province_total = reg and reg:provinceCount() or 0
    local width = reg and reg:getWidth() or 0
    province_log("registry fetch by name found=" .. tostring(reg ~= nil) .. " requested=" .. tostring(name) .. " fetched_name=" .. tostring(reg and reg:getName()) .. " provinces=" .. tostring(province_total) .. " width=" .. tostring(width))
end

--@api: lurek.province.getActive
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    lurek.province.newFromPng("check_reg_active", "content/examples/assets/textures/province_map.png")
    lurek.province.setActive("check_reg_active")

    local reg = lurek.province.getActive()

    province_log("active exists = " .. tostring(reg ~= nil))
    province_log("active name = " .. tostring(reg and reg:getName()))
end

--@api: lurek.province.remove
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = province_registry("remove")
    local name = reg:getName()
    local existed_before = lurek.province.exists(name)
    local removed = lurek.province.remove(name)
    local exists_after = lurek.province.exists(name)
    province_log("registry teardown existed_before=" .. tostring(existed_before) .. " removed=" .. tostring(removed) .. " exists_after=" .. tostring(exists_after) .. " name=" .. tostring(name))
end

--@api: lurek.province.sanitizeMarkedPng
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local summary = lurek.province.sanitizeMarkedPng(
        "content/examples/assets/images/sample_texture.png",
        "save/province_sanitized.png",
        {}
    )

    province_log("replaced pixels = " .. tostring(summary.replaced_pixels))
    province_log("unresolved pixels = " .. tostring(summary.unresolved_pixels))
end

--@api: lurek.province.setProperty
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("prop_set", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setProperty(province_id, "tax_rate", 0.15)
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("tax_rate = " .. tostring(province_id and lurek.province.getProperty(province_id, "tax_rate")))
end

--@api: lurek.province.getProperty
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("prop_get", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setProperty(province_id, "population", 50000)
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("population = " .. tostring(province_id and lurek.province.getProperty(province_id, "population")))
end

--@api: lurek.province.setAttr
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("attr_set", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setAttr(province_id, "terrain", "forest")
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("terrain = " .. tostring(province_id and lurek.province.getAttr(province_id, "terrain")))
end

--@api: lurek.province.getAttr
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("attr_get", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setAttr(province_id, "climate", "temperate")
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("climate = " .. tostring(province_id and lurek.province.getAttr(province_id, "climate")))
end

--@api: lurek.province.setFlag
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("flag_set", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setFlag(province_id, 1, true)
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("flag 1 = " .. tostring(province_id and lurek.province.hasFlag(province_id, 1)))
end

--@api: lurek.province.hasFlag
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("flag_get", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setFlag(province_id, 2, true)
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("flag 2 = " .. tostring(province_id and lurek.province.hasFlag(province_id, 2)))
end

--@api: lurek.province.clearProperties
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("prop_clear", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setProperty(province_id, "temp_val", 42)
        lurek.province.clearProperties(province_id)
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("temp_val = " .. tostring(province_id and lurek.province.getProperty(province_id, "temp_val")))
end

--@api: LProvinceRegistry:getBorderClass
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("border_class_get", "content/examples/assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]

    reg:registerBorderType(3, { name = "sea", color = { 30, 80, 180, 255 }, thickness = 2.0 })
    if pair then
        reg:setBorderClass(pair.province_a, pair.province_b, 3)
    end

    province_log("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    province_log("border class = " .. tostring(pair and reg:getBorderClass(pair.province_a, pair.province_b)))
end

--@api: LProvinceRegistry:setBorderClass
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("border_class_set", "content/examples/assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]
    local ok = false

    reg:registerBorderType(4, { name = "contested", color = { 220, 90, 60, 255 }, thickness = 2.5 })
    if pair then
        reg:setBorderClass(pair.province_a, pair.province_b, 4)
        ok = true
    end

    province_log("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    province_log("applied = " .. tostring(ok))
end

--@api: LProvinceRegistry:registerBorderType
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("border_type_register", "content/examples/assets/textures/province_map.png")
    local pairs = reg:adjacencies()

    reg:registerBorderType(5, { name = "river", color = { 40, 120, 210, 255 }, thickness = 2.0, draw_priority = 1 })

    province_log("registered type = 5")
    province_log("adjacency pairs = " .. tostring(#pairs))
end

--@api: LProvinceRegistry:setBorderPairStyle
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

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

    province_log("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    province_log("applied = " .. tostring(ok))
end

--@api: LProvinceRegistry:getBorderPairStyle
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

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

    province_log("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    province_log("thickness = " .. tostring(style and style.thickness))
    province_log("flag count = " .. tostring(style and style.flags and #style.flags or 0))
end

--@api: LProvinceRegistry:registerMapMode
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

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

    province_log("registered mode = economy")
    province_log("current mode = " .. reg:getMapMode())
end

--@api: LProvinceRegistry:setMapMode
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("map_mode_set", "content/examples/assets/textures/province_map.png")

    reg:registerMapMode("terrain_view", {
        show_labels = true,
        show_borders = true,
        show_roads = false,
        show_capitals = true,
        fog_intensity = 0.4,
    })

    local ok = reg:setMapMode("terrain_view")

    province_log("applied = " .. tostring(ok))
    province_log("mode = " .. reg:getMapMode())
end

--@api: LProvinceRegistry:getMapMode
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = lurek.province.newFromPng("map_mode_get", "content/examples/assets/textures/province_map.png")

    reg:registerMapMode("political_plus", {
        show_labels = true,
        show_borders = true,
        show_roads = true,
        show_capitals = true,
    })
    reg:setMapMode("political_plus")

    province_log("mode = " .. reg:getMapMode())
end

--@api: LProvinceRegistry:findRoute
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = province_registry("find_route", "content/examples/assets/province/map.png")
    local ids = reg:provinceIds()
    local from_id = ids[1]
    local to_id = ids[#ids] or from_id
    local route = (from_id and to_id) and reg:findRoute(from_id, to_id, function(a, b) return a == b and 0.5 or 1.0 end) or nil
    local hop_count = route and #route or 0
    province_log("supply route search from=" .. tostring(from_id) .. " to=" .. tostring(to_id) .. " hops=" .. tostring(hop_count) .. " reachable=" .. tostring(route ~= nil))
end

--@api: LProvinceRegistry:findRoutes
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = province_registry("find_routes", "content/examples/assets/province/map.png")
    local ids = reg:provinceIds()
    local pairs = { { from = ids[1], to = ids[2] or ids[1] }, { from = ids[1], to = ids[#ids] or ids[1] } }
    local routes = reg:findRoutes(pairs, function(a, b) return a == b and 0.5 or 1.0 end)
    local first_route = routes and routes[1] or nil
    province_log("batch route plan requests=" .. tostring(#pairs) .. " result_rows=" .. tostring(routes and #routes or 0) .. " first_hops=" .. tostring(first_route and #first_route or 0))
end

--@api: LProvinceRegistry:getConnectedComponents
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = province_registry("components", "content/examples/assets/province/map.png")
    local components = reg:getConnectedComponents()
    local first_component = components[1] or {}
    local province_total = reg:provinceCount()
    local first_size = #first_component
    local covers_all = first_size <= province_total
    province_log("graph components groups=" .. tostring(#components) .. " first_group_size=" .. tostring(first_size) .. " province_total=" .. tostring(province_total) .. " sane=" .. tostring(covers_all))
end

--@api: LProvinceRegistry:findIsolatedProvinces
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = province_registry("isolated", "content/examples/assets/province/map.png")
    local ids = reg:provinceIds()
    local a = ids[1]
    local b = ids[2] or a
    local c = ids[3] or b
    if a then reg:setAttr(a, "faction", "player") end
    if b then reg:setAttr(b, "faction", "enemy") end
    if c then reg:setAttr(c, "faction", "player") end
    local isolated = reg:findIsolatedProvinces("faction")
    province_log("faction isolation isolated=" .. tostring(isolated and #isolated or 0) .. " seeded_ids=" .. tostring(a) .. "," .. tostring(b) .. "," .. tostring(c))
end

--@api: LProvinceRegistry:isConnected
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = province_registry("is_connected", "content/examples/assets/province/map.png")
    local ids = reg:provinceIds()
    local from_id = ids[1]
    local to_id = ids[2] or from_id
    local connected = (from_id and to_id) and reg:isConnected(from_id, to_id) or false
    local route = connected and reg:findRoute(from_id, to_id) or nil
    province_log("frontline connectivity from=" .. tostring(from_id) .. " to=" .. tostring(to_id) .. " connected=" .. tostring(connected) .. " route_hops=" .. tostring(route and #route or 0))
end

--@api: LProvinceRegistry:totalAttrForOwner
do
    local function province_log(message)
        lurek.log.info("[province.example] " .. tostring(message))
    end
    local function province_registry(stem, path)
        return lurek.province.newFromPng(
            "province_example_" .. stem,
            path or "content/examples/assets/textures/province_map.png"
        )
    end

    local reg = province_registry("total_attr", "content/examples/assets/province/map.png")
    local ids = reg:provinceIds()
    local a = ids[1]
    local b = ids[2] or a
    local c = ids[3] or b
    if a then reg:setAttr(a, "faction", "player") reg:setAttr(a, "iron", "10") end
    if b then reg:setAttr(b, "faction", "enemy") reg:setAttr(b, "iron", "7") end
    if c then reg:setAttr(c, "faction", "player") reg:setAttr(c, "iron", "2.5") end
    local total = reg:totalAttrForOwner("faction", "player", "iron")
    province_log("owner resource total owner=player iron=" .. tostring(total) .. " seeded_ids=" .. tostring(a) .. "," .. tostring(b) .. "," .. tostring(c))
end
