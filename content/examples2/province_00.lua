--- Province Module: province maps from PNG, spatial queries, styles, rendering, change tracking

--@api-stub: lurek.province.newFromPng / get / exists
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

--@api-stub: LProvinceRegistry:getWidth / getHeight / provinceCount / provinceIds
-- Basic registry info.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("info", "assets/textures/province_map.png")
    print("grid = " .. reg:getWidth() .. "x" .. reg:getHeight())
    print("provinces = " .. reg:provinceCount())
    local ids = reg:provinceIds()
    print("first 5 ids:")
    for i = 1, math.min(5, #ids) do
        print("  " .. ids[i])
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

--@api-stub: LProvinceRegistry:setTerrainType / setFogState / setVisibilityState / setBorderStyle
-- Style mutations.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("style", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    if #ids >= 2 then
        reg:setTerrainType(ids[1], 1)
        reg:setFogState(ids[1], 0)
        reg:setVisibilityState(ids[1], 1)
        reg:setBorderStyle(ids[1], 2)
        reg:setTerrainType(ids[2], 3)
        reg:setFogState(ids[2], 1)
        print("styles applied")
    end
end

--@api-stub: LProvinceRegistry:setLabelText / setLabelLine / setCapital
-- Labels and capitals.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("labels", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    if #ids >= 1 then
        reg:setLabelText(ids[1], "Nordland")
        reg:setLabelLine(ids[1], 10, 20, 50, 20)
        reg:setCapital(ids[1], 30, 25)
        print("label and capital set")
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

--@api-stub: LProvinceRegistry:setBorderClass / getBorderClass
-- Border classification.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("borders", "assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    if #pairs >= 1 then
        local p = pairs[1]
        reg:setBorderClass(p.province_a, p.province_b, "river")
        local cls = reg:getBorderClass(p.province_a, p.province_b)
        print("border class = " .. tostring(cls))
    end
end

--@api-stub: LProvinceRegistry:getRevision / getChangesSince
-- Change tracking for incremental updates.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("changes", "assets/textures/province_map.png")
    local rev0 = reg:getRevision()
    print("initial revision = " .. rev0)
    local ids = reg:provinceIds()
    if #ids >= 1 then
        reg:setPoliticalColor(ids[1], 1.0, 0.0, 0.0)
        reg:setTerrainType(ids[1], 5)
    end
    local rev1 = reg:getRevision()
    print("after changes = " .. rev1)
    local changes = reg:getChangesSince(rev0)
    print("changes since rev0 = " .. #changes)
    for _, c in ipairs(changes) do
        print("  rev=" .. c.revision .. " kind=" .. c.kind)
    end
end

--@api-stub: LProvinceRegistry:borderSegments / provinceSpans
-- Geometry data for custom rendering.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("geo", "assets/textures/province_map.png")
    local segments = reg:borderSegments()
    print("border segments = " .. #segments)
    if #segments > 0 then
        local s = segments[1]
        print("  " .. s.province_a .. "/" .. s.province_b ..
            ": (" .. s.x0 .. "," .. s.y0 .. ")->(" .. s.x1 .. "," .. s.y1 .. ")")
    end
    local spans = reg:provinceSpans()
    print("total spans = " .. #spans)
end

--@api-stub: LProvinceRegistry:fitCamera / screenToMap / screenToProvince
-- Camera and coordinate transforms.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("cam", "assets/textures/province_map.png")
    local cx, cy, zoom = reg:fitCamera(800, 600, 1.0)
    print("camera = " .. cx .. ", " .. cy .. " zoom=" .. zoom)
    local mx, my = reg:screenToMap(400, 300, cx, cy, zoom, 1.0)
    print("map coords = " .. mx .. ", " .. my)
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

--@api-stub: lurek.province.setActive / getActive / remove
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

--@api-stub: LProvinceRegistry:type / typeOf
-- Type checking.
do
    ---@type LProvinceRegistry
    local reg = lurek.province.newFromPng("typed", "assets/textures/province_map.png")
    print("type = " .. reg:type())
    print("is LProvinceRegistry = " .. tostring(reg:typeOf("LProvinceRegistry")))
end

print("province_00.lua")
