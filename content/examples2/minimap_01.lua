--- Minimap Module Part 2: markers, objects, paths, overlays, viewport, coordinate mapping

--@api-stub: LMinimap:addMarker / hasMarker / getMarkerCount / getMarkerDescription
-- Adds and queries markers.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32)
    local id1 = mm:addMarker(10, 10, "Base", 0, 1, 0, 1)
    local id2 = mm:addMarker(20, 5, "Enemy", 1, 0, 0)
    print("markers = " .. mm:getMarkerCount())
    print("has id1 = " .. tostring(mm:hasMarker(id1)))
    print("desc = " .. mm:getMarkerDescription(id1))
    _ = id2
end

--@api-stub: LMinimap:removeMarker
-- Removes a marker by id.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    local id = mm:addMarker(5, 5, "Temp")
    print("before = " .. mm:getMarkerCount())
    mm:removeMarker(id)
    print("after = " .. mm:getMarkerCount())
end

--@api-stub: LMinimap:setMarkerAnimation / clearMarkerAnimation
-- Animates markers.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    local id = mm:addMarker(8, 8, "Pulse")
    mm:setMarkerAnimation(id, "pulse", 2.0)
    mm:update(0.5)
    mm:clearMarkerAnimation(id)
    print("animation cleared")
end

--@api-stub: LMinimap:addObjectType / getObjectTypeCount
-- Registers object types with colors.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    local idx1 = mm:addObjectType("unit", 0, 0, 1)
    local idx2 = mm:addObjectType("building", 1, 1, 0, 0.8)
    print("types = " .. mm:getObjectTypeCount())
    print("unit idx = " .. idx1 .. " building idx = " .. idx2)
end

--@api-stub: LMinimap:setObject / getObjectCount / removeObject / clearObjects
-- Manages objects on the minimap.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    local t = mm:addObjectType("npc", 0, 1, 0)
    mm:setObject(1, 4, 4, t, 0)
    mm:setObject(2, 8, 8, t, 1)
    mm:setObject(3, 12, 12, t, 0)
    print("objects = " .. mm:getObjectCount())
    mm:removeObject(2)
    print("after remove = " .. mm:getObjectCount())
    mm:clearObjects()
    print("after clear = " .. mm:getObjectCount())
end

--@api-stub: LMinimap:setObjectTypeVisible / isObjectTypeVisible
-- Toggles object type visibility.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    local t = mm:addObjectType("hidden", 1, 0, 0)
    mm:setObjectTypeVisible(t, false)
    print("visible = " .. tostring(mm:isObjectTypeVisible(t)))
    mm:setObjectTypeVisible(t, true)
    print("visible = " .. tostring(mm:isObjectTypeVisible(t)))
end

--@api-stub: LMinimap:setOwnerColor / getOwnerColor
-- Owner color mapping for political mode.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setOwnerColor(1, 0, 0, 1, 1)
    mm:setOwnerColor(2, 1, 0, 0, 1)
    local r, g, b, a = mm:getOwnerColor(1)
    print("owner 1 = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:showPath / getPathCount / clearPath
-- Path overlays.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    local pts = {{2, 2}, {4, 4}, {6, 2}, {8, 4}}
    local color = {255, 0, 0, 255}
    local pid = mm:showPath(pts, color)
    print("paths = " .. mm:getPathCount() .. " id = " .. pid)
    mm:clearPath(pid)
    print("after clear = " .. mm:getPathCount())
end

--@api-stub: LMinimap:addPing / getPingCount
-- Timed ping effects.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:addPing(8, 8, 2.0, 1, 1, 0)
    mm:addPing(4, 4, 1.0)
    print("pings = " .. mm:getPingCount())
    mm:update(2.5)
    print("pings after time = " .. mm:getPingCount())
end

--@api-stub: LMinimap:drawLine / drawRect / clearOverlay / getOverlayShapeCount
-- Overlay shapes.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:drawLine(0, 0, 15, 15, {255, 255, 255, 255})
    mm:drawRect(2, 2, 4, 4, {0, 255, 0, 200})
    print("shapes = " .. mm:getOverlayShapeCount())
    mm:clearOverlay()
    print("after clear = " .. mm:getOverlayShapeCount())
end

--@api-stub: LMinimap:setViewportRect / getViewportRect / clearViewportRect
-- Viewport rectangle overlay.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setViewportRect(4, 4, 12, 12)
    local x, y, w, h = mm:getViewportRect()
    print("viewport = " .. x .. "," .. y .. " " .. w .. "x" .. h)
    mm:clearViewportRect()
end

--@api-stub: LMinimap:setViewportColor / getViewportColor
-- Viewport rectangle color.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setViewportColor(1, 1, 0, 0.5)
    local r, g, b, a = mm:getViewportColor()
    print("vp color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:setViewportVisible / isViewportVisible
-- Viewport rectangle visibility toggle.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setViewportVisible(true)
    print("vp visible = " .. tostring(mm:isViewportVisible()))
end

--@api-stub: LMinimap:setClickable / isClickable
-- Clickable toggle.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setClickable(true)
    print("clickable = " .. tostring(mm:isClickable()))
end

--@api-stub: LMinimap:gridToScreen / screenToGrid
-- Coordinate mapping.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16, 160, 160)
    local sx, sy = mm:gridToScreen(8, 8, 0, 0)
    print("grid(8,8) → screen = " .. sx .. "," .. sy)
    local gx, gy = mm:screenToGrid(sx, sy, 0, 0)
    print("screen → grid = " .. gx .. "," .. gy)
end

--@api-stub: LMinimap:getHoverInfo
-- Tooltip info at screen position.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setTileDescription(1, "Plains")
    mm:setTerrain(1, 1, 1)
    local info = mm:getHoverInfo(5, 5, 0, 0)
    print("hover = " .. tostring(info))
end

--@api-stub: LMinimap:drawToImage
-- Renders minimap to image data.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setTerrainColor(0, 0.5, 0.5, 0.5)
    local img = mm:drawToImage(2)
    print("image type = " .. img:type())
end

print("minimap_01.lua")
