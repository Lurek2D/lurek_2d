-- content/examples/minimap.lua
-- Auto-generated from content/examples2/minimap_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/minimap.lua

--- Minimap Module Part 1: creation, terrain, fog, display, layers


--@api-stub: lurek.minimap.newMinimap
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(64, 64, 200, 200)
    print("minimap created = " .. tostring(mm ~= nil))
end

--@api-stub: LMinimap:setTerrain
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTerrain(1, 1, 1)
    print("terrain(1,1) = " .. mm:getTerrain(1, 1))
end

--@api-stub: LMinimap:getTerrain
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTerrain(1, 1, 1)
    print("terrain(1,1) = " .. mm:getTerrain(1, 1))
end

--@api-stub: LMinimap:setTerrainColor
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTerrainColor(1, 0.2, 0.6, 0.1)
    local r, g, b, a = mm:getTerrainColor(1)
    print("terrain 1 color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:getTerrainColor
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTerrainColor(1, 0.2, 0.6, 0.1)
    local r, g, b, a = mm:getTerrainColor(1)
    print("terrain 1 color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:setTerrainData
do
    local mm = lurek.minimap.newMinimap(4, 4)
    local data = {}
    for i = 1, 16 do data[i] = (i % 3) + 1 end
    mm:setTerrainData(data)
    print("cell(2,2) = " .. mm:getTerrain(2, 2))
end

--@api-stub: LMinimap:setFogEnabled
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setFogEnabled(true)
    print("fog enabled = " .. tostring(mm:isFogEnabled()))
end

--@api-stub: LMinimap:isFogEnabled
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setFogEnabled(true)
    print("fog enabled = " .. tostring(mm:isFogEnabled()))
end

--@api-stub: LMinimap:setFogLevel
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setFogEnabled(true)
    mm:setFogLevel(1, 1, 255)
    print("fog(1,1) = " .. mm:getFogLevel(1, 1))
end

--@api-stub: LMinimap:getFogLevel
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setFogEnabled(true)
    mm:setFogLevel(1, 1, 255)
    print("fog(1,1) = " .. mm:getFogLevel(1, 1))
end

--@api-stub: LMinimap:setFogColor
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setFogColor(0.0, 0.0, 0.0, 0.7)
    local r, g, b, a = mm:getFogColor()
    print("fog color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:getFogColor
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setFogColor(0.0, 0.0, 0.0, 0.7)
    local r, g, b, a = mm:getFogColor()
    print("fog color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:setFogData
do
    local mm = lurek.minimap.newMinimap(4, 4)
    mm:setFogEnabled(true); local fog = {}
    for i = 1, 16 do fog[i] = 200 end
    mm:setFogData(fog)
    print("fog after setData = " .. mm:getFogLevel(1, 1))
end

--@api-stub: LMinimap:revealRadius
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setFogEnabled(true); local fog = {}
    for i = 1, 32 * 32 do fog[i] = 255 end
    mm:setFogData(fog); mm:revealRadius(16, 16, 5)
    print("center fog after reveal = " .. mm:getFogLevel(16, 16))
end

--@api-stub: LMinimap:setColorMode
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setColorMode("political")
    print("mode = " .. mm:getColorMode())
end

--@api-stub: LMinimap:getColorMode
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setColorMode("political")
    print("mode = " .. mm:getColorMode())
end

--@api-stub: LMinimap:setLayer
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(4, 4)
    mm:setLayer(1)
    print("layer = " .. mm:getLayer())
end

--@api-stub: LMinimap:getLayer
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(4, 4)
    mm:setLayer(1)
    print("layer = " .. mm:getLayer())
end

--@api-stub: LMinimap:getLayerCount
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(4, 4)
    mm:setLayer(1)
    print("count = " .. mm:getLayerCount())
end

--@api-stub: LMinimap:setLayerData
do
    local mm = lurek.minimap.newMinimap(4, 4)
    local data = {}
    for i = 1, 16 do data[i] = i end
    mm:setLayerData(1, data)
    print("layer data set")
end

--@api-stub: LMinimap:getLayerData
do
    local mm = lurek.minimap.newMinimap(4, 4)
    local data = {}
    for i = 1, 16 do data[i] = i end
    mm:setLayerData(1, data); local out = mm:getLayerData(1)
    print("layer data len = " .. #(out or {}))
end

--@api-stub: LMinimap:setDisplaySize
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16, 100, 100)
    mm:setDisplaySize(300, 250)
    print("display = " .. mm:getDisplayWidth() .. "x" .. mm:getDisplayHeight())
end

--@api-stub: LMinimap:getDisplayWidth
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16, 100, 100)
    mm:setDisplaySize(300, 250)
    print("display = " .. mm:getDisplayWidth() .. "x" .. mm:getDisplayHeight())
end

--@api-stub: LMinimap:getDisplayHeight
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16, 100, 100)
    mm:setDisplaySize(300, 250)
    print("display = " .. mm:getDisplayWidth() .. "x" .. mm:getDisplayHeight())
end

--@api-stub: LMinimap:setCenter
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setCenter(16, 16)
    local cx, cy = mm:getCenter()
    print("center = " .. cx .. "," .. cy .. " x=" .. mm:getCenterX() .. " y=" .. mm:getCenterY())
end

--@api-stub: LMinimap:getCenter
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setCenter(16, 16)
    local cx, cy = mm:getCenter()
    print("center = " .. cx .. "," .. cy .. " x=" .. mm:getCenterX() .. " y=" .. mm:getCenterY())
end

--@api-stub: LMinimap:getCenterX
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setCenter(16, 16)
    local cx, cy = mm:getCenter()
    print("center = " .. cx .. "," .. cy .. " x=" .. mm:getCenterX() .. " y=" .. mm:getCenterY())
end

--@api-stub: LMinimap:getCenterY
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setCenter(16, 16)
    local cx, cy = mm:getCenter()
    print("center = " .. cx .. "," .. cy .. " x=" .. mm:getCenterX() .. " y=" .. mm:getCenterY())
end

--@api-stub: LMinimap:setZoom
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setZoom(2.0)
    print("zoom = " .. mm:getZoom())
end

--@api-stub: LMinimap:getZoom
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setZoom(2.0)
    print("zoom = " .. mm:getZoom())
end

--@api-stub: LMinimap:setAntiAlias
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setAntiAlias(true)
    print("aa = " .. tostring(mm:isAntiAlias()))
end

--@api-stub: LMinimap:isAntiAlias
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setAntiAlias(true)
    print("aa = " .. tostring(mm:isAntiAlias()))
end

--@api-stub: LMinimap:getCellCount
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(10, 20)
    print("cells = " .. mm:getCellCount())
    print("w=" .. mm:getGridWidth() .. " h=" .. mm:getGridHeight())
end

--@api-stub: LMinimap:getGridWidth
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(10, 20)
    print("cells = " .. mm:getCellCount())
    print("w=" .. mm:getGridWidth() .. " h=" .. mm:getGridHeight())
end

--@api-stub: LMinimap:getGridHeight
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(10, 20)
    print("cells = " .. mm:getCellCount())
    print("w=" .. mm:getGridWidth() .. " h=" .. mm:getGridHeight())
end

--@api-stub: LMinimap:setTileDescription
do
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setTileDescription(1, "Grass"); mm:setTileDescription(2, "Water")
    print("tile 1 = " .. mm:getTileDescription(1) .. " tile 2 = " .. mm:getTileDescription(2))
end

--@api-stub: LMinimap:getTileDescription
do
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setTileDescription(1, "Grass"); mm:setTileDescription(2, "Water")
    print("tile 1 = " .. mm:getTileDescription(1) .. " tile 2 = " .. mm:getTileDescription(2))
end

--@api-stub: LMinimap:update
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:update(0.016)
    print("updated")
end

--@api-stub: LMinimap:render
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:render(10, 10)
    print("rendered")
end

--- Minimap Module Part 2: markers, objects, paths, overlays, viewport, coordinate mapping


--@api-stub: LMinimap:addMarker
do
    local mm = lurek.minimap.newMinimap(32, 32)
    local id1 = mm:addMarker(10, 10, "Base", 0, 1, 0, 1); mm:addMarker(20, 5, "Enemy", 1, 0, 0)
    print("markers = " .. mm:getMarkerCount() .. " has id1 = " .. tostring(mm:hasMarker(id1)) .. " desc = " .. mm:getMarkerDescription(id1))
end

--@api-stub: LMinimap:hasMarker
do
    local mm = lurek.minimap.newMinimap(32, 32)
    local id1 = mm:addMarker(10, 10, "Base", 0, 1, 0, 1); mm:addMarker(20, 5, "Enemy", 1, 0, 0)
    print("markers = " .. mm:getMarkerCount() .. " has id1 = " .. tostring(mm:hasMarker(id1)) .. " desc = " .. mm:getMarkerDescription(id1))
end

--@api-stub: LMinimap:getMarkerCount
do
    local mm = lurek.minimap.newMinimap(32, 32)
    local id1 = mm:addMarker(10, 10, "Base", 0, 1, 0, 1); mm:addMarker(20, 5, "Enemy", 1, 0, 0)
    print("markers = " .. mm:getMarkerCount() .. " has id1 = " .. tostring(mm:hasMarker(id1)) .. " desc = " .. mm:getMarkerDescription(id1))
end

--@api-stub: LMinimap:getMarkerDescription
do
    local mm = lurek.minimap.newMinimap(32, 32)
    local id1 = mm:addMarker(10, 10, "Base", 0, 1, 0, 1); mm:addMarker(20, 5, "Enemy", 1, 0, 0)
    print("markers = " .. mm:getMarkerCount() .. " has id1 = " .. tostring(mm:hasMarker(id1)) .. " desc = " .. mm:getMarkerDescription(id1))
end

--@api-stub: LMinimap:removeMarker
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local id = mm:addMarker(5, 5, "Temp")
    print("before = " .. mm:getMarkerCount())
    mm:removeMarker(id)
    print("after = " .. mm:getMarkerCount())
end

--@api-stub: LMinimap:setMarkerAnimation
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local id = mm:addMarker(8, 8, "Pulse")
    mm:setMarkerAnimation(id, "pulse", 2.0); mm:update(0.5); mm:clearMarkerAnimation(id)
    print("animation cleared")
end

--@api-stub: LMinimap:clearMarkerAnimation
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local id = mm:addMarker(8, 8, "Pulse")
    mm:setMarkerAnimation(id, "pulse", 2.0); mm:update(0.5); mm:clearMarkerAnimation(id)
    print("animation cleared")
end

--@api-stub: LMinimap:addObjectType
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local idx1 = mm:addObjectType("unit", 0, 0, 1)
    local idx2 = mm:addObjectType("building", 1, 1, 0, 0.8)
    print("types = " .. mm:getObjectTypeCount())
    print("unit idx = " .. idx1 .. " building idx = " .. idx2)
end

--@api-stub: LMinimap:getObjectTypeCount
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local idx1 = mm:addObjectType("unit", 0, 0, 1)
    local idx2 = mm:addObjectType("building", 1, 1, 0, 0.8)
    print("types = " .. mm:getObjectTypeCount())
    print("unit idx = " .. idx1 .. " building idx = " .. idx2)
end

--@api-stub: LMinimap:setObject
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local t = mm:addObjectType("npc", 0, 1, 0)
    mm:setObject(1, 4, 4, t, 0)
    print("objects = " .. mm:getObjectCount())
end

--@api-stub: LMinimap:getObjectCount
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local t = mm:addObjectType("npc", 0, 1, 0)
    mm:setObject(1, 4, 4, t, 0); mm:setObject(2, 8, 8, t, 1)
    print("objects = " .. mm:getObjectCount())
end

--@api-stub: LMinimap:removeObject
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local t = mm:addObjectType("npc", 0, 1, 0)
    mm:setObject(1, 4, 4, t, 0); mm:setObject(2, 8, 8, t, 1)
    mm:removeObject(2)
    print("after remove = " .. mm:getObjectCount())
end

--@api-stub: LMinimap:clearObjects
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local t = mm:addObjectType("npc", 0, 1, 0)
    mm:setObject(1, 4, 4, t, 0); mm:setObject(2, 8, 8, t, 1)
    mm:clearObjects()
    print("after clear = " .. mm:getObjectCount())
end

--@api-stub: LMinimap:setObjectTypeVisible
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local t = mm:addObjectType("hidden", 1, 0, 0)
    mm:setObjectTypeVisible(t, false); local hidden = mm:isObjectTypeVisible(t); mm:setObjectTypeVisible(t, true)
    print("hidden = " .. tostring(hidden) .. " visible = " .. tostring(mm:isObjectTypeVisible(t)))
end

--@api-stub: LMinimap:isObjectTypeVisible
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local t = mm:addObjectType("hidden", 1, 0, 0)
    mm:setObjectTypeVisible(t, false); local hidden = mm:isObjectTypeVisible(t); mm:setObjectTypeVisible(t, true)
    print("hidden = " .. tostring(hidden) .. " visible = " .. tostring(mm:isObjectTypeVisible(t)))
end

--@api-stub: LMinimap:setOwnerColor
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setOwnerColor(1, 0, 0, 1, 1); mm:setOwnerColor(2, 1, 0, 0, 1)
    local r, g, b, a = mm:getOwnerColor(1)
    print("owner 1 = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:getOwnerColor
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setOwnerColor(1, 0, 0, 1, 1); mm:setOwnerColor(2, 1, 0, 0, 1)
    local r, g, b, a = mm:getOwnerColor(1)
    print("owner 1 = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:showPath
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local pts = {{2, 2}, {4, 4}, {6, 2}, {8, 4}}; local color = {255, 0, 0, 255}
    local pid = mm:showPath(pts, color)
    print("paths = " .. mm:getPathCount() .. " id = " .. pid)
end

--@api-stub: LMinimap:getPathCount
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local pts = {{2, 2}, {4, 4}, {6, 2}, {8, 4}}; local color = {255, 0, 0, 255}
    local pid = mm:showPath(pts, color)
    print("paths = " .. mm:getPathCount() .. " id = " .. pid)
end

--@api-stub: LMinimap:clearPath
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local pts = {{2, 2}, {4, 4}, {6, 2}, {8, 4}}; local color = {255, 0, 0, 255}
    local pid = mm:showPath(pts, color)
    mm:clearPath(pid)
    print("after clear = " .. mm:getPathCount())
end

--@api-stub: LMinimap:addPing
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:addPing(8, 8, 2.0, 1, 1, 0); mm:addPing(4, 4, 1.0)
    print("pings = " .. mm:getPingCount())
    mm:update(2.5)
    print("pings after time = " .. mm:getPingCount())
end

--@api-stub: LMinimap:getPingCount
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:addPing(8, 8, 2.0, 1, 1, 0); mm:addPing(4, 4, 1.0)
    print("pings = " .. mm:getPingCount())
    mm:update(2.5)
    print("pings after time = " .. mm:getPingCount())
end

--@api-stub: LMinimap:drawLine
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:drawLine(0, 0, 15, 15, {255, 255, 255, 255}); mm:drawRect(2, 2, 4, 4, {0, 255, 0, 200})
    print("shapes = " .. mm:getOverlayShapeCount())
    mm:clearOverlay()
    print("after clear = " .. mm:getOverlayShapeCount())
end

--@api-stub: LMinimap:drawRect
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:drawLine(0, 0, 15, 15, {255, 255, 255, 255}); mm:drawRect(2, 2, 4, 4, {0, 255, 0, 200})
    print("shapes = " .. mm:getOverlayShapeCount())
    mm:clearOverlay()
    print("after clear = " .. mm:getOverlayShapeCount())
end

--@api-stub: LMinimap:clearOverlay
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:drawLine(0, 0, 15, 15, {255, 255, 255, 255}); mm:drawRect(2, 2, 4, 4, {0, 255, 0, 200})
    print("shapes = " .. mm:getOverlayShapeCount())
    mm:clearOverlay()
    print("after clear = " .. mm:getOverlayShapeCount())
end

--@api-stub: LMinimap:getOverlayShapeCount
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:drawLine(0, 0, 15, 15, {255, 255, 255, 255}); mm:drawRect(2, 2, 4, 4, {0, 255, 0, 200})
    print("shapes = " .. mm:getOverlayShapeCount())
    mm:clearOverlay(); print("after clear = " .. mm:getOverlayShapeCount())
end

--@api-stub: LMinimap:setViewportRect
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setViewportRect(4, 4, 12, 12)
    local x, y, w, h = mm:getViewportRect()
    print("viewport = " .. x .. "," .. y .. " " .. w .. "x" .. h)
end

--@api-stub: LMinimap:getViewportRect
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setViewportRect(4, 4, 12, 12)
    local x, y, w, h = mm:getViewportRect()
    print("viewport = " .. x .. "," .. y .. " " .. w .. "x" .. h)
end

--@api-stub: LMinimap:clearViewportRect
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setViewportRect(4, 4, 12, 12)
    mm:clearViewportRect()
    print("viewport cleared")
end

--@api-stub: LMinimap:setViewportColor
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setViewportColor(1, 1, 0, 0.5)
    local r, g, b, a = mm:getViewportColor()
    print("vp color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:getViewportColor
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setViewportColor(1, 1, 0, 0.5)
    local r, g, b, a = mm:getViewportColor()
    print("vp color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:setViewportVisible
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setViewportVisible(true)
    print("vp visible = " .. tostring(mm:isViewportVisible()))
end

--@api-stub: LMinimap:isViewportVisible
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setViewportVisible(true)
    print("vp visible = " .. tostring(mm:isViewportVisible()))
end

--@api-stub: LMinimap:setClickable
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setClickable(true)
    print("clickable = " .. tostring(mm:isClickable()))
end

--@api-stub: LMinimap:isClickable
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setClickable(true)
    print("clickable = " .. tostring(mm:isClickable()))
end

--@api-stub: LMinimap:gridToScreen
do
    local mm = lurek.minimap.newMinimap(16, 16, 160, 160)
    local sx, sy = mm:gridToScreen(8, 8, 0, 0)
    local gx, gy = mm:screenToGrid(sx, sy, 0, 0)
    print("grid(8,8) â†’ screen = " .. sx .. "," .. sy .. " screen â†’ grid = " .. gx .. "," .. gy)
end

--@api-stub: LMinimap:screenToGrid
do
    local mm = lurek.minimap.newMinimap(16, 16, 160, 160)
    local sx, sy = mm:gridToScreen(8, 8, 0, 0)
    local gx, gy = mm:screenToGrid(sx, sy, 0, 0)
    print("grid(8,8) â†’ screen = " .. sx .. "," .. sy .. " screen â†’ grid = " .. gx .. "," .. gy)
end

--@api-stub: LMinimap:getHoverInfo
do
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setTileDescription(1, "Plains"); mm:setTerrain(1, 1, 1)
    local info = mm:getHoverInfo(5, 5, 0, 0)
    print("hover = " .. tostring(info))
end

--@api-stub: LMinimap:drawToImage
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setTerrainColor(0, 0.5, 0.5, 0.5)
    local img = mm:drawToImage(2)
    print("image type = " .. img:type())
end

--- Minimap Module Part 3: textures, display size, grid size, camera tracking, type


--@api-stub: LMinimap:getDisplaySize
do
    local mm = lurek.minimap.newMinimap(32, 32, 200, 200)
    local dw, dh = mm:getDisplaySize()
    local gw, gh = mm:getGridSize()
    print("display=" .. dw .. "x" .. dh .. " grid=" .. gw .. "x" .. gh)
end

--@api-stub: LMinimap:getGridSize
do
    local mm = lurek.minimap.newMinimap(32, 32, 200, 200)
    local dw, dh = mm:getDisplaySize()
    local gw, gh = mm:getGridSize()
    print("display=" .. dw .. "x" .. dh .. " grid=" .. gw .. "x" .. gh)
end

--@api-stub: LMinimap:setMarkerTexture
do
    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    mm:addMarker(16, 16, "Hero")
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    mm:setMarkerTexture(1, img, 32, 32); mm:clearMarkerTexture(1)
    print("marker texture cleared")
end

--@api-stub: LMinimap:clearMarkerTexture
do
    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    mm:addMarker(16, 16, "Hero")
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    mm:setMarkerTexture(1, img, 32, 32); mm:clearMarkerTexture(1)
    print("marker texture cleared")
end

--@api-stub: LMinimap:setObjectTypeTexture
do
    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    mm:addObjectType("unit", 0, 1, 0, 1)
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    mm:setObjectTypeTexture(1, img, 16, 16); mm:clearObjectTypeTexture(1)
    print("object type texture cleared")
end

--@api-stub: LMinimap:clearObjectTypeTexture
do
    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    mm:addObjectType("unit", 0, 1, 0, 1)
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    mm:setObjectTypeTexture(1, img, 16, 16); mm:clearObjectTypeTexture(1)
    print("object type texture cleared")
end

--@api-stub: LMinimap:trackCamera
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    local cam = lurek.camera.newCamera()
    mm:trackCamera(cam)
    print("camera tracked")
end

--@api-stub: LMinimap:type
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    print(mm:type())
    print(mm:typeOf("LMinimap"))
    print(mm:typeOf("Object"))
end

--@api-stub: LMinimap:typeOf
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    print(mm:type())
    print(mm:typeOf("LMinimap"))
    print(mm:typeOf("Object"))
end

print("content/examples/minimap.lua")

