-- content/examples/minimap.lua
-- Auto-generated from content/examples2/minimap_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/minimap.lua

--- Minimap Module Part 1: creation, terrain, fog, display, layers

--@api-stub: lurek.minimap.newMinimap
do
    local mm = lurek.minimap.newMinimap(64, 64, 200, 200)
    local dw, dh = mm:getDisplaySize()
    print("grid = " .. mm:getGridWidth() .. "x" .. mm:getGridHeight())
    print("display = " .. dw .. "x" .. dh)
end

--@api-stub: LMinimap:setTerrain
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTerrain(1, 1, 2)
    print("terrain(1,1) = " .. mm:getTerrain(1, 1))
end

--@api-stub: LMinimap:getTerrain
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTerrain(2, 3, 7)
    print("terrain(2,3) = " .. mm:getTerrain(2, 3))
end

--@api-stub: LMinimap:setTerrainColor
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTerrainColor(1, 0.2, 0.6, 0.1, 0.9)
    local r, g, b, a = mm:getTerrainColor(1)
    print("terrain 1 color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:getTerrainColor
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTerrainColor(3, 0.7, 0.4, 0.2, 1.0)
    local r, g, b, a = mm:getTerrainColor(3)
    print("terrain 3 color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:setTerrainData
do
    local mm = lurek.minimap.newMinimap(4, 4)
    local data = {}

    for i = 1, 16 do
        data[i] = ((i - 1) % 3) + 1
    end

    mm:setTerrainData(data)
    print("terrain(1,1) = " .. mm:getTerrain(1, 1))
    print("terrain(4,4) = " .. mm:getTerrain(4, 4))
end

--@api-stub: LMinimap:setFogEnabled
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setFogEnabled(true)
    print("fog enabled = " .. tostring(mm:isFogEnabled()))
end

--@api-stub: LMinimap:isFogEnabled
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setFogEnabled(false)
    print("fog enabled = " .. tostring(mm:isFogEnabled()))
end

--@api-stub: LMinimap:setFogLevel
do
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setFogEnabled(true)
    mm:setFogLevel(1, 1, 2)
    print("fog(1,1) = " .. mm:getFogLevel(1, 1))
end

--@api-stub: LMinimap:getFogLevel
do
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setFogEnabled(true)
    mm:setFogLevel(2, 2, 1)
    print("fog(2,2) = " .. mm:getFogLevel(2, 2))
end

--@api-stub: LMinimap:setFogColor
do
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setFogColor(0.0, 0.0, 0.0, 0.7)
    local r, g, b, a = mm:getFogColor()
    print("fog color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:getFogColor
do
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setFogColor(0.1, 0.2, 0.3, 0.6)
    local r, g, b, a = mm:getFogColor()
    print("fog color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:setFogData
do
    local mm = lurek.minimap.newMinimap(4, 4)
    local fog = {}

    mm:setFogEnabled(true)

    for i = 1, 16 do
        fog[i] = (i - 1) % 3
    end

    mm:setFogData(fog)
    print("fog(1,1) = " .. mm:getFogLevel(1, 1))
    print("fog(4,4) = " .. mm:getFogLevel(4, 4))
end

--@api-stub: LMinimap:revealRadius
do
    local mm = lurek.minimap.newMinimap(32, 32)
    local fog = {}

    mm:setFogEnabled(true)

    for i = 1, 32 * 32 do
        fog[i] = 0
    end

    mm:setFogData(fog)
    mm:revealRadius(16, 16, 5)
    print("center fog = " .. mm:getFogLevel(16, 16))
    print("corner fog = " .. mm:getFogLevel(1, 1))
end

--@api-stub: LMinimap:setColorMode
do
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setColorMode("political")
    print("mode = " .. mm:getColorMode())
end

--@api-stub: LMinimap:getColorMode
do
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setColorMode("terrain")
    print("mode = " .. mm:getColorMode())
end

--@api-stub: LMinimap:setLayer
do
    local mm = lurek.minimap.newMinimap(4, 4)
    mm:setLayer(2)
    print("layer = " .. mm:getLayer())
end

--@api-stub: LMinimap:getLayer
do
    local mm = lurek.minimap.newMinimap(4, 4)
    mm:setLayer(1)
    print("layer = " .. mm:getLayer())
end

--@api-stub: LMinimap:getLayerCount
do
    local mm = lurek.minimap.newMinimap(4, 4)
    local data = {}

    for i = 1, 16 do
        data[i] = i % 4
    end

    mm:setLayerData(1, data)
    print("layer count = " .. mm:getLayerCount())
end

--@api-stub: LMinimap:setLayerData
do
    local mm = lurek.minimap.newMinimap(4, 4)
    local data = {}

    for i = 1, 16 do
        data[i] = i
    end

    mm:setLayerData(0, data)
    local out = mm:getLayerData(0)
    print("layer 0 size = " .. #(out or {}))
    print("layer 0 first = " .. (out and out[1] or -1))
end

--@api-stub: LMinimap:getLayerData
do
    local mm = lurek.minimap.newMinimap(4, 4)
    local data = {}

    for i = 1, 16 do
        data[i] = i % 5
    end

    mm:setLayerData(1, data)
    local out = mm:getLayerData(1)
    print("layer 1 size = " .. #(out or {}))
    print("layer 1 last = " .. (out and out[#out] or -1))
end

--@api-stub: LMinimap:setDisplaySize
do
    local mm = lurek.minimap.newMinimap(16, 16, 100, 100)
    mm:setDisplaySize(300, 250)
    print("display = " .. mm:getDisplayWidth() .. "x" .. mm:getDisplayHeight())
end

--@api-stub: LMinimap:getDisplayWidth
do
    local mm = lurek.minimap.newMinimap(16, 16, 100, 100)
    mm:setDisplaySize(300, 250)
    print("display width = " .. mm:getDisplayWidth())
end

--@api-stub: LMinimap:getDisplayHeight
do
    local mm = lurek.minimap.newMinimap(16, 16, 100, 100)
    mm:setDisplaySize(300, 250)
    print("display height = " .. mm:getDisplayHeight())
end

--@api-stub: LMinimap:setCenter
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setCenter(16, 12)
    local cx, cy = mm:getCenter()
    print("center = " .. cx .. "," .. cy)
end

--@api-stub: LMinimap:getCenter
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setCenter(10, 20)
    local cx, cy = mm:getCenter()
    print("center = " .. cx .. "," .. cy)
end

--@api-stub: LMinimap:getCenterX
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setCenter(14, 9)
    print("center x = " .. mm:getCenterX())
end

--@api-stub: LMinimap:getCenterY
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setCenter(14, 9)
    print("center y = " .. mm:getCenterY())
end

--@api-stub: LMinimap:setZoom
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setZoom(2.0)
    print("zoom = " .. mm:getZoom())
end

--@api-stub: LMinimap:getZoom
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setZoom(1.5)
    print("zoom = " .. mm:getZoom())
end

--@api-stub: LMinimap:setAntiAlias
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setAntiAlias(true)
    print("anti alias = " .. tostring(mm:isAntiAlias()))
end

--@api-stub: LMinimap:isAntiAlias
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setAntiAlias(false)
    print("anti alias = " .. tostring(mm:isAntiAlias()))
end

--@api-stub: LMinimap:getCellCount
do
    local mm = lurek.minimap.newMinimap(10, 20)
    print("cell count = " .. mm:getCellCount())
end

--@api-stub: LMinimap:getGridWidth
do
    local mm = lurek.minimap.newMinimap(10, 20)
    print("grid width = " .. mm:getGridWidth())
end

--@api-stub: LMinimap:getGridHeight
do
    local mm = lurek.minimap.newMinimap(10, 20)
    print("grid height = " .. mm:getGridHeight())
end

--@api-stub: LMinimap:setTileDescription
do
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setTileDescription(1, "Grass")
    mm:setTileDescription(2, "Water")
    print("tile 1 = " .. tostring(mm:getTileDescription(1)))
    print("tile 2 = " .. tostring(mm:getTileDescription(2)))
end

--@api-stub: LMinimap:getTileDescription
do
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setTileDescription(3, "Mountain")
    print("tile 3 = " .. tostring(mm:getTileDescription(3)))
end

--@api-stub: LMinimap:update
do
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:addPing(4, 4, 0.25)
    print("pings before = " .. mm:getPingCount())
    mm:update(0.5)
    print("pings after = " .. mm:getPingCount())
end

--@api-stub: LMinimap:render
do
    local mm = lurek.minimap.newMinimap(8, 8, 96, 96)
    mm:setTerrain(1, 1, 1)
    mm:render(10, 10)
    print("render queued at = 10,10")
    print("type = " .. mm:type())
end

--- Minimap Module Part 2: markers, objects, paths, overlays, viewport, coordinate mapping

--@api-stub: LMinimap:addMarker
do
    local mm = lurek.minimap.newMinimap(32, 32)
    local id1 = mm:addMarker(10, 10, "Base", 0, 1, 0, 1)

    mm:addMarker(20, 5, "Enemy", 1, 0, 0, 1)
    print("marker id = " .. id1)
    print("marker count = " .. mm:getMarkerCount())
end

--@api-stub: LMinimap:hasMarker
do
    local mm = lurek.minimap.newMinimap(32, 32)
    local id = mm:addMarker(10, 10, "Outpost")

    print("has marker = " .. tostring(mm:hasMarker(id)))
end

--@api-stub: LMinimap:getMarkerCount
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:addMarker(10, 10, "Base")
    mm:addMarker(20, 5, "Enemy")
    print("marker count = " .. mm:getMarkerCount())
end

--@api-stub: LMinimap:getMarkerDescription
do
    local mm = lurek.minimap.newMinimap(32, 32)
    local id = mm:addMarker(10, 10, "Quest")

    print("marker desc = " .. tostring(mm:getMarkerDescription(id)))
end

--@api-stub: LMinimap:removeMarker
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local id = mm:addMarker(5, 5, "Temp")

    print("before = " .. mm:getMarkerCount())
    print("removed = " .. tostring(mm:removeMarker(id)))
    print("after = " .. mm:getMarkerCount())
end

--@api-stub: LMinimap:setMarkerAnimation
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local id = mm:addMarker(8, 8, "Pulse")

    mm:setMarkerAnimation(id, "pulse", 2.0)
    mm:update(0.5)
    print("marker exists = " .. tostring(mm:hasMarker(id)))
    print("marker count = " .. mm:getMarkerCount())
end

--@api-stub: LMinimap:clearMarkerAnimation
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local id = mm:addMarker(8, 8, "Blink")

    mm:setMarkerAnimation(id, "blink", 4.0)
    mm:clearMarkerAnimation(id)
    mm:update(0.25)
    print("marker exists = " .. tostring(mm:hasMarker(id)))
end

--@api-stub: LMinimap:addObjectType
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local unit = mm:addObjectType("unit", 0, 0, 1, 1)
    local building = mm:addObjectType("building", 1, 1, 0, 0.8)

    print("types = " .. mm:getObjectTypeCount())
    print("unit = " .. unit .. " building = " .. building)
end

--@api-stub: LMinimap:getObjectTypeCount
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:addObjectType("unit", 0, 0, 1, 1)
    mm:addObjectType("building", 1, 1, 0, 0.8)
    print("object type count = " .. mm:getObjectTypeCount())
end

--@api-stub: LMinimap:setObject
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local npc = mm:addObjectType("npc", 0, 1, 0, 1)

    mm:setObject(1, 4, 4, npc, 2)
    print("object count = " .. mm:getObjectCount())
end

--@api-stub: LMinimap:getObjectCount
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local npc = mm:addObjectType("npc", 0, 1, 0, 1)

    mm:setObject(1, 4, 4, npc, 0)
    mm:setObject(2, 8, 8, npc, 1)
    print("object count = " .. mm:getObjectCount())
end

--@api-stub: LMinimap:removeObject
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local npc = mm:addObjectType("npc", 0, 1, 0, 1)

    mm:setObject(1, 4, 4, npc, 0)
    mm:setObject(2, 8, 8, npc, 1)
    print("before = " .. mm:getObjectCount())
    print("removed = " .. tostring(mm:removeObject(2)))
    print("after = " .. mm:getObjectCount())
end

--@api-stub: LMinimap:clearObjects
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local npc = mm:addObjectType("npc", 0, 1, 0, 1)

    mm:setObject(1, 4, 4, npc, 0)
    mm:setObject(2, 8, 8, npc, 1)
    print("before = " .. mm:getObjectCount())
    mm:clearObjects()
    print("after = " .. mm:getObjectCount())
end

--@api-stub: LMinimap:setObjectTypeVisible
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local t = mm:addObjectType("hidden", 1, 0, 0, 1)

    mm:setObjectTypeVisible(t, false)
    print("visible = " .. tostring(mm:isObjectTypeVisible(t)))
end

--@api-stub: LMinimap:isObjectTypeVisible
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local t = mm:addObjectType("scout", 0, 1, 1, 1)

    mm:setObjectTypeVisible(t, true)
    print("visible = " .. tostring(mm:isObjectTypeVisible(t)))
end

--@api-stub: LMinimap:setOwnerColor
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setOwnerColor(1, 0, 0, 1, 1)
    local r, g, b, a = mm:getOwnerColor(1)
    print("owner 1 = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:getOwnerColor
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setOwnerColor(2, 1, 0, 0, 1)
    local r, g, b, a = mm:getOwnerColor(2)
    print("owner 2 = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:showPath
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local pts = {
        { 2, 2 },
        { 4, 4 },
        { 6, 2 },
        { 8, 4 },
    }
    local pid = mm:showPath(pts, { 255, 0, 0, 255 })

    print("path id = " .. pid)
    print("path count = " .. mm:getPathCount())
end

--@api-stub: LMinimap:getPathCount
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local pts = {
        { 1, 1 },
        { 3, 3 },
        { 5, 2 },
    }

    mm:showPath(pts, { 0, 255, 0, 255 })
    print("path count = " .. mm:getPathCount())
end

--@api-stub: LMinimap:clearPath
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local pts = {
        { 2, 2 },
        { 4, 4 },
        { 6, 2 },
    }
    local pid = mm:showPath(pts, { 255, 255, 255, 255 })

    print("before = " .. mm:getPathCount())
    mm:clearPath(pid)
    print("after = " .. mm:getPathCount())
end

--@api-stub: LMinimap:addPing
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:addPing(8, 8, 2.0, 1, 1, 0, 1)
    mm:addPing(4, 4, 1.0)
    print("pings before = " .. mm:getPingCount())
    mm:update(2.5)
    print("pings after = " .. mm:getPingCount())
end

--@api-stub: LMinimap:getPingCount
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:addPing(8, 8, 2.0)
    mm:addPing(4, 4, 1.0)
    print("ping count = " .. mm:getPingCount())
end

--@api-stub: LMinimap:drawLine
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:drawLine(0, 0, 15, 15, { 255, 255, 255, 255 })
    print("overlay shapes = " .. mm:getOverlayShapeCount())
end

--@api-stub: LMinimap:drawRect
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:drawRect(2, 2, 4, 4, { 0, 255, 0, 200 })
    print("overlay shapes = " .. mm:getOverlayShapeCount())
end

--@api-stub: LMinimap:clearOverlay
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:drawLine(0, 0, 15, 15, { 255, 255, 255, 255 })
    mm:drawRect(2, 2, 4, 4, { 0, 255, 0, 200 })
    print("before = " .. mm:getOverlayShapeCount())
    mm:clearOverlay()
    print("after = " .. mm:getOverlayShapeCount())
end

--@api-stub: LMinimap:getOverlayShapeCount
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:drawLine(0, 0, 15, 15, { 255, 255, 255, 255 })
    mm:drawRect(2, 2, 4, 4, { 0, 255, 0, 200 })
    print("overlay shape count = " .. mm:getOverlayShapeCount())
end

--@api-stub: LMinimap:setViewportRect
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setViewportRect(4, 4, 12, 12)
    local x, y, w, h = mm:getViewportRect()
    print("viewport = " .. tostring(x) .. "," .. tostring(y) .. " " .. tostring(w) .. "x" .. tostring(h))
end

--@api-stub: LMinimap:getViewportRect
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setViewportRect(6, 8, 10, 14)
    local x, y, w, h = mm:getViewportRect()
    print("viewport = " .. tostring(x) .. "," .. tostring(y) .. " " .. tostring(w) .. "x" .. tostring(h))
end

--@api-stub: LMinimap:clearViewportRect
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setViewportRect(4, 4, 12, 12)
    mm:clearViewportRect()
    local x = select(1, mm:getViewportRect())
    print("viewport cleared = " .. tostring(x == nil))
end

--@api-stub: LMinimap:setViewportColor
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setViewportColor(1, 1, 0, 0.5)
    local r, g, b, a = mm:getViewportColor()
    print("viewport color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:getViewportColor
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setViewportColor(0.2, 0.4, 1.0, 0.75)
    local r, g, b, a = mm:getViewportColor()
    print("viewport color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:setViewportVisible
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setViewportVisible(true)
    print("viewport visible = " .. tostring(mm:isViewportVisible()))
end

--@api-stub: LMinimap:isViewportVisible
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setViewportVisible(false)
    print("viewport visible = " .. tostring(mm:isViewportVisible()))
end

--@api-stub: LMinimap:setClickable
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setClickable(false)
    print("clickable = " .. tostring(mm:isClickable()))
end

--@api-stub: LMinimap:isClickable
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setClickable(true)
    print("clickable = " .. tostring(mm:isClickable()))
end

--@api-stub: LMinimap:gridToScreen
do
    local mm = lurek.minimap.newMinimap(16, 16, 160, 160)
    local sx, sy = mm:gridToScreen(8, 8, 0, 0)

    print("screen = " .. sx .. "," .. sy)
end

--@api-stub: LMinimap:screenToGrid
do
    local mm = lurek.minimap.newMinimap(16, 16, 160, 160)
    local sx, sy = mm:gridToScreen(8, 8, 0, 0)
    local gx, gy = mm:screenToGrid(sx, sy, 0, 0)

    print("grid = " .. gx .. "," .. gy)
end

--@api-stub: LMinimap:getHoverInfo
do
    local mm = lurek.minimap.newMinimap(8, 8, 80, 80)
    mm:setTileDescription(1, "Plains")
    mm:setTerrain(1, 1, 1)
    print("hover = " .. tostring(mm:getHoverInfo(1, 1, 0, 0)))
end

--@api-stub: LMinimap:drawToImage
do
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setTerrainColor(0, 0.5, 0.5, 0.5, 1.0)
    local img = mm:drawToImage(2)

    print("image type = " .. img:type())
    print("image size = " .. img:getWidth() .. "x" .. img:getHeight())
end

--- Minimap Module Part 3: textures, display size, grid size, camera tracking, type

--@api-stub: LMinimap:getDisplaySize
do
    local mm = lurek.minimap.newMinimap(32, 32, 200, 200)
    local dw, dh = mm:getDisplaySize()

    print("display = " .. dw .. "x" .. dh)
end

--@api-stub: LMinimap:getGridSize
do
    local mm = lurek.minimap.newMinimap(32, 32, 200, 200)
    local gw, gh = mm:getGridSize()

    print("grid = " .. gw .. "x" .. gh)
end

--@api-stub: LMinimap:setMarkerTexture
do
    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    local id = mm:addMarker(16, 16, "Hero")
    local img = lurek.render.newImage("content/examples/assets/images/sample_icon.png")

    mm:setMarkerTexture(id, img, 24, 24)
    print("marker count = " .. mm:getMarkerCount())
end

--@api-stub: LMinimap:clearMarkerTexture
do
    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    local id = mm:addMarker(16, 16, "Hero")
    local img = lurek.render.newImage("content/examples/assets/images/sample_icon.png")

    mm:setMarkerTexture(id, img, 24, 24)
    mm:clearMarkerTexture(id)
    print("marker exists = " .. tostring(mm:hasMarker(id)))
end

--@api-stub: LMinimap:setObjectTypeTexture
do
    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    local type_idx = mm:addObjectType("unit", 0, 1, 0, 1)
    local img = lurek.render.newImage("content/examples/assets/images/sample_icon.png")

    mm:setObjectTypeTexture(type_idx, img, 16, 16)
    print("object types = " .. mm:getObjectTypeCount())
end

--@api-stub: LMinimap:clearObjectTypeTexture
do
    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    local type_idx = mm:addObjectType("unit", 0, 1, 0, 1)
    local img = lurek.render.newImage("content/examples/assets/images/sample_icon.png")

    mm:setObjectTypeTexture(type_idx, img, 16, 16)
    mm:clearObjectTypeTexture(type_idx)
    print("object types = " .. mm:getObjectTypeCount())
end

--@api-stub: LMinimap:trackCamera
do
    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    local cam = lurek.camera.newCamera(1280, 720)

    cam:setPosition(320, 240)
    mm:trackCamera(cam)

    local cx, cy = mm:getCenter()
    local _, _, vw, vh = mm:getViewportRect()
    print("center = " .. cx .. "," .. cy)
    print("viewport size = " .. tostring(vw) .. "x" .. tostring(vh))
end

--@api-stub: LMinimap:type
do
    local mm = lurek.minimap.newMinimap(16, 16)
    print("type = " .. mm:type())
end

--@api-stub: LMinimap:typeOf
do
    local mm = lurek.minimap.newMinimap(16, 16)
    print("is LMinimap = " .. tostring(mm:typeOf("LMinimap")))
    print("is LObject = " .. tostring(mm:typeOf("LObject")))
end
