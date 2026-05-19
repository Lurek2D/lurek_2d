-- content/examples/province.lua
-- Auto-generated from content/examples2/province_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/province.lua

--- Province Module: province maps from PNG, spatial queries, styles, rendering, change tracking


--@api-stub: lurek.province.newFromPng
-- Create a province registry from a color-coded PNG map.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("world", "assets/textures/province_map.png")
    print("registry name = " .. reg:getName())
    print("exists = " .. tostring(lurek.province.exists("world")))
    ---@type LProvinceRegistry
    local found = lurek.province.get("world")
    print("found = " .. found:getName())
end

--@api-stub: LProvinceRegistry:getWidth
-- Read the province-map width in cells.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("info_width", "assets/textures/province_map.png")
    print("width = " .. reg:getWidth())
end

--@api-stub: LProvinceRegistry:getHeight
-- Read the province-map height in cells.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("info_height", "assets/textures/province_map.png")
    print("height = " .. reg:getHeight())
end

--@api-stub: LProvinceRegistry:provinceCount
-- Read how many provinces exist in the registry.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("info_count", "assets/textures/province_map.png")
    print("provinces = " .. reg:provinceCount())
end

--@api-stub: LProvinceRegistry:provinceIds
-- Read the province id list from the registry.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("info_ids", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    print("id count = " .. #ids)
    if #ids > 0 then
        print("first id = " .. ids[1])
    end
end

--@api-stub: LProvinceRegistry:getAt
-- Spatial query: which province owns a cell.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("spatial", "assets/textures/province_map.png")
    local id = reg:getAt(50, 50)
    print("province at 50,50 = " .. id)
    local id2 = reg:getAt(0, 0)
    print("province at 0,0 = " .. id2)
end

--@api-stub: LProvinceRegistry:getNeighbors
-- Adjacency queries.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("adj", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    if #ids > 0 then
        local neighbors = reg:getNeighbors(ids[1])
        print("province " .. ids[1] .. " neighbors = " .. #neighbors)
        for _, n in ipairs(neighbors) do
            print("  " .. n)
        end
    end
end

--@api-stub: LProvinceRegistry:adjacencies
-- All adjacency pairs.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("pairs", "assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    print("adjacency pairs = " .. #pairs)
    for i = 1, math.min(3, #pairs) do
        local p = pairs[i]
        print("  " .. p.province_a .. " <-> " .. p.province_b)
    end
end

--@api-stub: LProvinceRegistry:getProvince
-- Get a full province snapshot.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("snap", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    if #ids > 0 then
        local snap = reg:getProvince(ids[1])
        if snap then
            print("province_id = " .. snap.province_id)
            print("revision = " .. snap.revision)
        end
    end
end

--@api-stub: LProvinceRegistry:setPoliticalColor
-- Set political colors for provinces.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("colors", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    if #ids >= 3 then
        reg:setPoliticalColor(ids[1], 0.8, 0.2, 0.2)
        reg:setPoliticalColor(ids[2], 0.2, 0.8, 0.2)
        reg:setPoliticalColor(ids[3], 0.2, 0.2, 0.8, 0.5)
        print("colors set for 3 provinces")
    end
end

--@api-stub: LProvinceRegistry:setTerrainType
-- Set a terrain type for one province.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("style_terrain", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    if #ids >= 1 then
        reg:setTerrainType(ids[1], 1)
        print("terrain type set")
    end
end

--@api-stub: LProvinceRegistry:setFogState
-- Set the fog state for one province.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("style_fog", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    if #ids >= 1 then
        reg:setFogState(ids[1], 0)
        print("fog state set")
    end
end

--@api-stub: LProvinceRegistry:setVisibilityState
-- Set the visibility state for one province.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("style_visibility", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    if #ids >= 1 then
        reg:setVisibilityState(ids[1], 1)
        print("visibility state set")
    end
end

--@api-stub: LProvinceRegistry:setBorderStyle
-- Set the border style for one province.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("style_border", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    if #ids >= 1 then
        reg:setBorderStyle(ids[1], 2)
        print("border style set")
    end
end

--@api-stub: LProvinceRegistry:setLabelText
-- Set the display label text for a province.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("labels_text", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    if #ids >= 1 then
        reg:setLabelText(ids[1], "Nordland")
        print("label text set")
    end
end

--@api-stub: LProvinceRegistry:setLabelLine
-- Set the label guide line for a province.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("labels_line", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    if #ids >= 1 then
        reg:setLabelLine(ids[1], 10, 20, 50, 20)
        print("label line set")
    end
end

--@api-stub: LProvinceRegistry:setCapital
-- Set the capital marker position for a province.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("labels_capital", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    if #ids >= 1 then
        reg:setCapital(ids[1], 30, 25)
        print("capital set")
    end
end

--@api-stub: LProvinceRegistry:setAttr
-- Custom attributes.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("attrs", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    if #ids >= 1 then
        reg:setAttr(ids[1], "owner", "player1")
        reg:setAttr(ids[1], "population", "5000")
        reg:setAttr(ids[1], "resource", "iron")
        print("attributes set")
        local snap = reg:getProvince(ids[1])
        if snap then
            print("attrs = " .. tostring(snap.attrs))
        end
    end
end

--@api-stub: LProvinceRegistry:setBorderClass
-- Assign a custom class to one border edge.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("borders_set", "assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    if #pairs >= 1 then
        local p = pairs[1]
        reg:setBorderClass(p.province_a, p.province_b, "coast")
        print("border class assigned")
    end
end

--@api-stub: LProvinceRegistry:getBorderClass
-- Read a custom class from one border edge.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("borders_get", "assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    if #pairs >= 1 then
        local p = pairs[1]
        reg:setBorderClass(p.province_a, p.province_b, "coast")
        local cls = reg:getBorderClass(p.province_a, p.province_b)
        print("border class = " .. tostring(cls))
    end
end

--@api-stub: LProvinceRegistry:getRevision
-- Read the current province-registry revision.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("changes_revision", "assets/textures/province_map.png")
    print("revision = " .. reg:getRevision())
end

--@api-stub: LProvinceRegistry:getChangesSince
-- Read incremental changes since an older revision.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("changes_since", "assets/textures/province_map.png")
    local rev0 = reg:getRevision()
    local ids = reg:provinceIds()
    if #ids >= 1 then
        reg:setPoliticalColor(ids[1], 1.0, 0.0, 0.0)
        reg:setTerrainType(ids[1], 5)
    end
    local changes = reg:getChangesSince(rev0)
    print("changes since rev0 = " .. #changes)
end

--@api-stub: LProvinceRegistry:borderSegments
-- Read border line segments for custom rendering.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("geo_segments", "assets/textures/province_map.png")
    local segments = reg:borderSegments()
    print("border segments = " .. #segments)
end

--@api-stub: LProvinceRegistry:provinceSpans
-- Read horizontal spans for each province.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("geo_spans", "assets/textures/province_map.png")
    local spans = reg:provinceSpans()
    print("total spans = " .. #spans)
end

--@api-stub: LProvinceRegistry:fitCamera
-- Fit a camera to the province map bounds.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("cam_fit", "assets/textures/province_map.png")
    local cx, cy, zoom = reg:fitCamera(800, 600, 1.0)
    print("camera = " .. cx .. ", " .. cy .. " zoom=" .. zoom)
end

--@api-stub: LProvinceRegistry:screenToMap
-- Convert a screen position into map coordinates.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("cam_map", "assets/textures/province_map.png")
    local cx, cy, zoom = reg:fitCamera(800, 600, 1.0)
    local mx, my = reg:screenToMap(400, 300, cx, cy, zoom, 1.0)
    print("map coords = " .. mx .. ", " .. my)
end

--@api-stub: LProvinceRegistry:screenToProvince
-- Convert a screen position into a province id.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("cam_province", "assets/textures/province_map.png")
    local cx, cy, zoom = reg:fitCamera(800, 600, 1.0)
    local pid = reg:screenToProvince(400, 300, cx, cy, zoom, 1.0)
    print("province at center = " .. tostring(pid))
end

--@api-stub: lurek.province.zoomCameraAt
-- Zoom camera anchored at a screen point.
do
    local camX, camY = 100, 80
    local oldZoom = 1.0
    local newZoom = 2.0
    local newCx, newCy = lurek.province.zoomCameraAt(400, 300, camX, camY, oldZoom, newZoom)
    print("new camera = " .. newCx .. ", " .. newCy)
end

--@api-stub: lurek.province.setActive
-- Active registry management.
do
    lurek.province.newFromPng("map_a", "assets/textures/province_map.png")
    lurek.province.newFromPng("map_b", "assets/textures/province_map.png")
    lurek.province.setActive("map_a")
    ---@type LProvinceRegistry
    local active = lurek.province.getActive()
    print("active = " .. active:getName())
    lurek.province.setActive("map_b")
    active = lurek.province.getActive()
    print("active = " .. active:getName())
    lurek.province.remove("map_a")
    print("map_a exists = " .. tostring(lurek.province.exists("map_a")))
end

--@api-stub: LProvinceRegistry:render
-- Rendering the province map.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("render", "assets/textures/province_map.png")
    local cx, cy, zoom = reg:fitCamera(800, 600, 1.0)
    reg:render({
        map_mode = "political",
        x = cx,
        y = cy,
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
        selected_id = 0
    })
    print("map rendered")
end

--@api-stub: LProvinceRegistry:type
-- Read the province-registry type name.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("typed_name", "assets/textures/province_map.png")
    print("type = " .. reg:type())
end

--@api-stub: LProvinceRegistry:typeOf
-- Check the province-registry type identity.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("typed_check", "assets/textures/province_map.png")
    print("is LProvinceRegistry = " .. tostring(reg:typeOf("LProvinceRegistry")))
end

--- Province Module Part 1: registry queries, module-level functions


--@api-stub: LProvinceRegistry:getName
-- Province registry name and metadata import. Focus: getName.
do
    local reg = lurek.province.newFromPng("test_reg", "content/games/strategy/eu2/map.png")
    print("name=" .. reg:getName())
    reg:importMetadataFromFiles({
        color_map_png = "content/games/strategy/eu2/map.png",
        marker_png = "content/games/strategy/eu2/map.png",
        color_csv = "content/games/strategy/eu2/prov_cols.csv",
        province_toml = "content/games/strategy/eu2/province.toml",
    })
    print("metadata imported")
end

--@api-stub: LProvinceRegistry:importMetadataFromFiles
-- Province registry name and metadata import. Focus: importMetadataFromFiles.
do
    local reg = lurek.province.newFromPng("test_reg", "content/games/strategy/eu2/map.png")
    print("name=" .. reg:getName())
    reg:importMetadataFromFiles({
        color_map_png = "content/games/strategy/eu2/map.png",
        marker_png = "content/games/strategy/eu2/map.png",
        color_csv = "content/games/strategy/eu2/prov_cols.csv",
        province_toml = "content/games/strategy/eu2/province.toml",
    })
    print("metadata imported")
end

--@api-stub: lurek.province.exists
-- Province module-level lifecycle functions. Focus: exists.
do
    local reg = lurek.province.newFromPng("check_reg", "assets/textures/province_map.png")
    print("exists=" .. tostring(lurek.province.exists("check_reg")))
    local got = lurek.province.get("check_reg")
    print("got=" .. tostring(got ~= nil))
    lurek.province.setActive("check_reg")
    local active = lurek.province.getActive()
    print("active=" .. tostring(active ~= nil))
    lurek.province.remove("check_reg")
    print("exists_after=" .. tostring(lurek.province.exists("check_reg")))
end

--@api-stub: lurek.province.get
-- Province module-level lifecycle functions. Focus: get.
do
    local reg = lurek.province.newFromPng("check_reg", "assets/textures/province_map.png")
    print("exists=" .. tostring(lurek.province.exists("check_reg")))
    local got = lurek.province.get("check_reg")
    print("got=" .. tostring(got ~= nil))
    lurek.province.setActive("check_reg")
    local active = lurek.province.getActive()
    print("active=" .. tostring(active ~= nil))
    lurek.province.remove("check_reg")
    print("exists_after=" .. tostring(lurek.province.exists("check_reg")))
end

--@api-stub: lurek.province.getActive
-- Province module-level lifecycle functions. Focus: getActive.
do
    local reg = lurek.province.newFromPng("check_reg", "assets/textures/province_map.png")
    print("exists=" .. tostring(lurek.province.exists("check_reg")))
    local got = lurek.province.get("check_reg")
    print("got=" .. tostring(got ~= nil))
    lurek.province.setActive("check_reg")
    local active = lurek.province.getActive()
    print("active=" .. tostring(active ~= nil))
    lurek.province.remove("check_reg")
    print("exists_after=" .. tostring(lurek.province.exists("check_reg")))
end

--@api-stub: lurek.province.remove
-- Province module-level lifecycle functions. Focus: remove.
do
    local reg = lurek.province.newFromPng("check_reg", "assets/textures/province_map.png")
    print("exists=" .. tostring(lurek.province.exists("check_reg")))
    local got = lurek.province.get("check_reg")
    print("got=" .. tostring(got ~= nil))
    lurek.province.setActive("check_reg")
    local active = lurek.province.getActive()
    print("active=" .. tostring(active ~= nil))
    lurek.province.remove("check_reg")
    print("exists_after=" .. tostring(lurek.province.exists("check_reg")))
end

--@api-stub: lurek.province.sanitizeMarkedPng
-- Sanitize a marked PNG for province loading.
do
    lurek.province.sanitizeMarkedPng(
        "assets/textures/ray_water.png",
        "save/province_sanitized.png",
        {}
    )
    print("sanitize ok")
end

print("content/examples/province.lua")
