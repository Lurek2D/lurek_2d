-- content/examples/province.lua
-- Auto-generated from content/examples2/province_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/province.lua

--- Province Module: province maps from PNG, spatial queries, styles, rendering, change tracking


--@api-stub: lurek.province.newFromPng
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("world", "assets/textures/province_map.png")
    print("registry name = " .. reg:getName())
end

--@api-stub: LProvinceRegistry:getWidth
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("info_width", "assets/textures/province_map.png")
    print("width = " .. reg:getWidth())
end

--@api-stub: LProvinceRegistry:getHeight
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("info_height", "assets/textures/province_map.png")
    print("height = " .. reg:getHeight())
end

--@api-stub: LProvinceRegistry:provinceCount
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("info_count", "assets/textures/province_map.png")
    print("provinces = " .. reg:provinceCount())
end

--@api-stub: LProvinceRegistry:provinceIds
do
    local reg = lurek.province.newFromPng("info_ids", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    print("id count = " .. #ids)
    print("first id = " .. tostring(ids[1]))
end

--@api-stub: LProvinceRegistry:getAt
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("spatial", "assets/textures/province_map.png")
    local id = reg:getAt(50, 50)
    print("province at 50,50 = " .. id)
end

--@api-stub: LProvinceRegistry:getNeighbors
do
    local reg = lurek.province.newFromPng("adj", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local neighbors = reg:getNeighbors(ids[1])
    print("province " .. tostring(ids[1]) .. " neighbors = " .. #neighbors)
end

--@api-stub: LProvinceRegistry:adjacencies
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("pairs", "assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    print("adjacency pairs = " .. #pairs)
end

--@api-stub: LProvinceRegistry:getProvince
do
    local reg = lurek.province.newFromPng("snap", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local snap = reg:getProvince(ids[1])
    print("province_id = " .. tostring(snap and snap.province_id))
    print("revision = " .. tostring(snap and snap.revision))
end

--@api-stub: LProvinceRegistry:setPoliticalColor
do
    local reg = lurek.province.newFromPng("colors", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    reg:setPoliticalColor(ids[1], 0.8, 0.2, 0.2)
    print("color set for province " .. tostring(ids[1]))
end

--@api-stub: LProvinceRegistry:setTerrainType
do
    local reg = lurek.province.newFromPng("style_terrain", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    reg:setTerrainType(ids[1], 1)
    print("terrain type set")
end

--@api-stub: LProvinceRegistry:setFogState
do
    local reg = lurek.province.newFromPng("style_fog", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    reg:setFogState(ids[1], 0)
    print("fog state set")
end

--@api-stub: LProvinceRegistry:setVisibilityState
do
    local reg = lurek.province.newFromPng("style_visibility", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    reg:setVisibilityState(ids[1], 1)
    print("visibility state set")
end

--@api-stub: LProvinceRegistry:setBorderStyle
do
    local reg = lurek.province.newFromPng("style_border", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    reg:setBorderStyle(ids[1], 2)
    print("border style set")
end

--@api-stub: LProvinceRegistry:setLabelText
do
    local reg = lurek.province.newFromPng("labels_text", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    reg:setLabelText(ids[1], "Nordland")
    print("label text set")
end

--@api-stub: LProvinceRegistry:setLabelLine
do
    local reg = lurek.province.newFromPng("labels_line", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    reg:setLabelLine(ids[1], 10, 20, 50, 20)
    print("label line set")
end

--@api-stub: LProvinceRegistry:setCapital
do
    local reg = lurek.province.newFromPng("labels_capital", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    reg:setCapital(ids[1], 30, 25)
    print("capital set")
end

--@api-stub: LProvinceRegistry:setAttr
do
    local reg = lurek.province.newFromPng("attrs", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    reg:setAttr(ids[1], "owner", "player1")
    print("attributes set for " .. tostring(ids[1]))
end

--@api-stub: LProvinceRegistry:setBorderClass
do
    local reg = lurek.province.newFromPng("borders_set", "assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local p = pairs[1]
    reg:setBorderClass(p.province_a, p.province_b, "coast")
    print("border class assigned")
end

--@api-stub: LProvinceRegistry:getBorderClass
do
    local reg = lurek.province.newFromPng("borders_get", "assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local p = pairs[1]
    reg:setBorderClass(p.province_a, p.province_b, "coast")
    print("border class = " .. tostring(reg:getBorderClass(p.province_a, p.province_b)))
end

--@api-stub: LProvinceRegistry:getRevision
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("changes_revision", "assets/textures/province_map.png")
    print("revision = " .. reg:getRevision())
end

--@api-stub: LProvinceRegistry:getChangesSince
do
    local reg = lurek.province.newFromPng("changes_since", "assets/textures/province_map.png")
    local rev0 = reg:getRevision()
    local ids = reg:provinceIds()
    reg:setPoliticalColor(ids[1], 1.0, 0.0, 0.0)
    print("changes since rev0 = " .. #reg:getChangesSince(rev0))
end

--@api-stub: LProvinceRegistry:borderSegments
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("geo_segments", "assets/textures/province_map.png")
    local segments = reg:borderSegments()
    print("border segments = " .. #segments)
end

--@api-stub: LProvinceRegistry:provinceSpans
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("geo_spans", "assets/textures/province_map.png")
    local spans = reg:provinceSpans()
    print("total spans = " .. #spans)
end

--@api-stub: LProvinceRegistry:fitCamera
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("cam_fit", "assets/textures/province_map.png")
    local cx, cy, zoom = reg:fitCamera(800, 600, 1.0)
    print("camera = " .. cx .. ", " .. cy .. " zoom=" .. zoom)
end

--@api-stub: LProvinceRegistry:screenToMap
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("cam_map", "assets/textures/province_map.png")
    local cx, cy, zoom = reg:fitCamera(800, 600, 1.0)
    local mx, my = reg:screenToMap(400, 300, cx, cy, zoom, 1.0)
    print("map coords = " .. mx .. ", " .. my)
end

--@api-stub: LProvinceRegistry:screenToProvince
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("cam_province", "assets/textures/province_map.png")
    local cx, cy, zoom = reg:fitCamera(800, 600, 1.0)
    local pid = reg:screenToProvince(400, 300, cx, cy, zoom, 1.0)
    print("province at center = " .. tostring(pid))
end

--@api-stub: lurek.province.zoomCameraAt
do
    local camX, camY = 100, 80
    local oldZoom = 1.0
    local newZoom = 2.0
    local newCx, newCy = lurek.province.zoomCameraAt(400, 300, camX, camY, oldZoom, newZoom)
    print("new camera = " .. newCx .. ", " .. newCy)
end

--@api-stub: lurek.province.setActive
do
    lurek.province.newFromPng("map_a", "assets/textures/province_map.png"); lurek.province.newFromPng("map_b", "assets/textures/province_map.png")
    lurek.province.setActive("map_a")
    print("active = " .. lurek.province.getActive():getName())
    lurek.province.setActive("map_b")
    print("active = " .. lurek.province.getActive():getName())
end

--@api-stub: LProvinceRegistry:render
do
    local reg = lurek.province.newFromPng("render", "assets/textures/province_map.png")
    local cx, cy, zoom = reg:fitCamera(800, 600, 1.0)
    reg:render({ map_mode = "political", x = cx, y = cy, zoom = zoom, pixel_size = 1.0, screen_w = 800, screen_h = 600, draw_fills = true, draw_borders = true, draw_labels = true, draw_capitals = true, border_width = 1.5, hovered_id = 0, selected_id = 0 })
    print("map rendered")
end

--@api-stub: LProvinceRegistry:type
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("typed_name", "assets/textures/province_map.png")
    print("type = " .. reg:type())
end

--@api-stub: LProvinceRegistry:typeOf
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("typed_check", "assets/textures/province_map.png")
    print("is LProvinceRegistry = " .. tostring(reg:typeOf("LProvinceRegistry")))
end

--- Province Module Part 1: registry queries, module-level functions


--@api-stub: LProvinceRegistry:getName
do
    local reg = lurek.province.newFromPng("test_reg", "content/games/strategy/eu2/map.png")
    print("name=" .. reg:getName())
end

--@api-stub: LProvinceRegistry:importMetadataFromFiles
do
    local reg = lurek.province.newFromPng("test_reg", "content/games/strategy/eu2/map.png")
    reg:importMetadataFromFiles({ color_map_png = "content/games/strategy/eu2/map.png", marker_png = "content/games/strategy/eu2/map.png", color_csv = "content/games/strategy/eu2/prov_cols.csv", province_toml = "content/games/strategy/eu2/province.toml" })
    print("metadata imported")
end

--@api-stub: lurek.province.exists
do
    lurek.province.newFromPng("check_reg", "assets/textures/province_map.png")
    print("exists=" .. tostring(lurek.province.exists("check_reg")))
end

--@api-stub: lurek.province.get
do
    lurek.province.newFromPng("check_reg", "assets/textures/province_map.png")
    print("got=" .. tostring(lurek.province.get("check_reg") ~= nil))
end

--@api-stub: lurek.province.getActive
do
    lurek.province.newFromPng("check_reg", "assets/textures/province_map.png")
    lurek.province.setActive("check_reg")
    print("active=" .. tostring(lurek.province.getActive() ~= nil))
end

--@api-stub: lurek.province.remove
do
    lurek.province.newFromPng("check_reg", "assets/textures/province_map.png")
    lurek.province.remove("check_reg")
    print("exists_after=" .. tostring(lurek.province.exists("check_reg")))
end

--@api-stub: lurek.province.sanitizeMarkedPng
do
    lurek.province.sanitizeMarkedPng("content/examples/assets/images/sample_texture.png", "save/province_sanitized.png", {})
    print("sanitize ok")
end

print("content/examples/province.lua")

