-- content/examples/minimap.lua
-- Auto-generated from content/examples2/minimap_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/minimap.lua

--- Minimap Module Part 1: creation, terrain, fog, display, layers


--@api-stub: lurek.minimap.newMinimap
-- Creates a minimap with grid and display dimensions.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(64, 64, 200, 200)
    print("minimap created = " .. tostring(mm ~= nil))
end

--@api-stub: LMinimap:setTerrain
-- Sets and reads terrain type for grid cells. Focus: setTerrain.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTerrain(1, 1, 1)
    print("terrain(1,1) = " .. mm:getTerrain(1, 1))
end

--@api-stub: LMinimap:getTerrain
-- Sets and reads terrain type for grid cells. Focus: getTerrain.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTerrain(1, 1, 1)
    print("terrain(1,1) = " .. mm:getTerrain(1, 1))
end

--@api-stub: LMinimap:setTerrainColor
-- Assigns RGBA color to terrain type ids. Focus: setTerrainColor.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTerrainColor(1, 0.2, 0.6, 0.1)
    local r, g, b, a = mm:getTerrainColor(1)
    print("terrain 1 color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:getTerrainColor
-- Assigns RGBA color to terrain type ids. Focus: getTerrainColor.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTerrainColor(1, 0.2, 0.6, 0.1)
    local r, g, b, a = mm:getTerrainColor(1)
    print("terrain 1 color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:setTerrainData
-- Replaces all terrain data at once.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(4, 4)
    local data = {}
    for i = 1, 16 do data[i] = (i % 3) + 1 end
    mm:setTerrainData(data)
    print("cell(2,2) = " .. mm:getTerrain(2, 2))
end

--@api-stub: LMinimap:setFogEnabled
-- Toggles fog overlay display. Focus: setFogEnabled.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setFogEnabled(true)
    print("fog enabled = " .. tostring(mm:isFogEnabled()))
end

--@api-stub: LMinimap:isFogEnabled
-- Toggles fog overlay display. Focus: isFogEnabled.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setFogEnabled(true)
    print("fog enabled = " .. tostring(mm:isFogEnabled()))
end

--@api-stub: LMinimap:setFogLevel
-- Sets fog density per cell. Focus: setFogLevel.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setFogEnabled(true)
    mm:setFogLevel(1, 1, 255)
    print("fog(1,1) = " .. mm:getFogLevel(1, 1))
end

--@api-stub: LMinimap:getFogLevel
-- Sets fog density per cell. Focus: getFogLevel.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setFogEnabled(true)
    mm:setFogLevel(1, 1, 255)
    print("fog(1,1) = " .. mm:getFogLevel(1, 1))
end

--@api-stub: LMinimap:setFogColor
-- Sets the fog overlay color. Focus: setFogColor.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setFogColor(0.0, 0.0, 0.0, 0.7)
    local r, g, b, a = mm:getFogColor()
    print("fog color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:getFogColor
-- Sets the fog overlay color. Focus: getFogColor.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setFogColor(0.0, 0.0, 0.0, 0.7)
    local r, g, b, a = mm:getFogColor()
    print("fog color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:setFogData
-- Replaces all fog data at once.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(4, 4)
    mm:setFogEnabled(true)
    local fog = {}
    for i = 1, 16 do fog[i] = 200 end
    mm:setFogData(fog)
    print("fog after setData = " .. mm:getFogLevel(1, 1))
end

--@api-stub: LMinimap:revealRadius
-- Reveals fog inside a radius.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setFogEnabled(true)
    local fog = {}
    for i = 1, 32 * 32 do fog[i] = 255 end
    mm:setFogData(fog)
    mm:revealRadius(16, 16, 5)
    print("center fog after reveal = " .. mm:getFogLevel(16, 16))
end

--@api-stub: LMinimap:setColorMode
-- Switches between terrain and political color modes. Focus: setColorMode.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setColorMode("political")
    print("mode = " .. mm:getColorMode())
end

--@api-stub: LMinimap:getColorMode
-- Switches between terrain and political color modes. Focus: getColorMode.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setColorMode("political")
    print("mode = " .. mm:getColorMode())
end

--@api-stub: LMinimap:setLayer
-- Multi-layer support. Focus: setLayer.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(4, 4)
    mm:setLayer(1)
    print("layer = " .. mm:getLayer())
end

--@api-stub: LMinimap:getLayer
-- Multi-layer support. Focus: getLayer.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(4, 4)
    mm:setLayer(1)
    print("layer = " .. mm:getLayer())
end

--@api-stub: LMinimap:getLayerCount
-- Multi-layer support. Focus: getLayerCount.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(4, 4)
    mm:setLayer(1)
    print("count = " .. mm:getLayerCount())
end

--@api-stub: LMinimap:setLayerData
-- Multi-layer support. Focus: setLayerData.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(4, 4)
    local data = {}
    for i = 1, 16 do data[i] = i end
    mm:setLayerData(1, data)
    print("layer data set")
end

--@api-stub: LMinimap:getLayerData
-- Multi-layer support. Focus: getLayerData.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(4, 4)
    local data = {}
    for i = 1, 16 do data[i] = i end
    mm:setLayerData(1, data)
    local out = mm:getLayerData(1)
    if out then
        print("layer data len = " .. #out)
    end
end

--@api-stub: LMinimap:setDisplaySize
-- Resizes the minimap display. Focus: setDisplaySize.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16, 100, 100)
    mm:setDisplaySize(300, 250)
    print("display = " .. mm:getDisplayWidth() .. "x" .. mm:getDisplayHeight())
end

--@api-stub: LMinimap:getDisplayWidth
-- Resizes the minimap display. Focus: getDisplayWidth.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16, 100, 100)
    mm:setDisplaySize(300, 250)
    print("display = " .. mm:getDisplayWidth() .. "x" .. mm:getDisplayHeight())
end

--@api-stub: LMinimap:getDisplayHeight
-- Resizes the minimap display. Focus: getDisplayHeight.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16, 100, 100)
    mm:setDisplaySize(300, 250)
    print("display = " .. mm:getDisplayWidth() .. "x" .. mm:getDisplayHeight())
end

--@api-stub: LMinimap:setCenter
-- Camera centering. Focus: setCenter.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setCenter(16, 16)
    local cx, cy = mm:getCenter()
    print("center = " .. cx .. "," .. cy)
    print("x=" .. mm:getCenterX() .. " y=" .. mm:getCenterY())
end

--@api-stub: LMinimap:getCenter
-- Camera centering. Focus: getCenter.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setCenter(16, 16)
    local cx, cy = mm:getCenter()
    print("center = " .. cx .. "," .. cy)
    print("x=" .. mm:getCenterX() .. " y=" .. mm:getCenterY())
end

--@api-stub: LMinimap:getCenterX
-- Camera centering. Focus: getCenterX.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setCenter(16, 16)
    local cx, cy = mm:getCenter()
    print("center = " .. cx .. "," .. cy)
    print("x=" .. mm:getCenterX() .. " y=" .. mm:getCenterY())
end

--@api-stub: LMinimap:getCenterY
-- Camera centering. Focus: getCenterY.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setCenter(16, 16)
    local cx, cy = mm:getCenter()
    print("center = " .. cx .. "," .. cy)
    print("x=" .. mm:getCenterX() .. " y=" .. mm:getCenterY())
end

--@api-stub: LMinimap:setZoom
-- Zoom control. Focus: setZoom.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setZoom(2.0)
    print("zoom = " .. mm:getZoom())
end

--@api-stub: LMinimap:getZoom
-- Zoom control. Focus: getZoom.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setZoom(2.0)
    print("zoom = " .. mm:getZoom())
end

--@api-stub: LMinimap:setAntiAlias
-- Anti-aliasing toggle. Focus: setAntiAlias.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setAntiAlias(true)
    print("aa = " .. tostring(mm:isAntiAlias()))
end

--@api-stub: LMinimap:isAntiAlias
-- Anti-aliasing toggle. Focus: isAntiAlias.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setAntiAlias(true)
    print("aa = " .. tostring(mm:isAntiAlias()))
end

--@api-stub: LMinimap:getCellCount
-- Grid dimension queries. Focus: getCellCount.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(10, 20)
    print("cells = " .. mm:getCellCount())
    print("w=" .. mm:getGridWidth() .. " h=" .. mm:getGridHeight())
end

--@api-stub: LMinimap:getGridWidth
-- Grid dimension queries. Focus: getGridWidth.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(10, 20)
    print("cells = " .. mm:getCellCount())
    print("w=" .. mm:getGridWidth() .. " h=" .. mm:getGridHeight())
end

--@api-stub: LMinimap:getGridHeight
-- Grid dimension queries. Focus: getGridHeight.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(10, 20)
    print("cells = " .. mm:getCellCount())
    print("w=" .. mm:getGridWidth() .. " h=" .. mm:getGridHeight())
end

--@api-stub: LMinimap:setTileDescription
-- Tile type descriptions. Focus: setTileDescription.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setTileDescription(1, "Grass")
    mm:setTileDescription(2, "Water")
    print("tile 1 = " .. mm:getTileDescription(1))
    print("tile 2 = " .. mm:getTileDescription(2))
end

--@api-stub: LMinimap:getTileDescription
-- Tile type descriptions. Focus: getTileDescription.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setTileDescription(1, "Grass")
    mm:setTileDescription(2, "Water")
    print("tile 1 = " .. mm:getTileDescription(1))
    print("tile 2 = " .. mm:getTileDescription(2))
end

--@api-stub: LMinimap:update
-- Advances animations and timers.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:update(0.016)
    print("updated")
end

--@api-stub: LMinimap:render
-- Renders the minimap.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:render(10, 10)
    print("rendered")
end

--- Minimap Module Part 2: markers, objects, paths, overlays, viewport, coordinate mapping


--@api-stub: LMinimap:addMarker
-- Adds and queries markers. Focus: addMarker.
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

--@api-stub: LMinimap:hasMarker
-- Adds and queries markers. Focus: hasMarker.
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

--@api-stub: LMinimap:getMarkerCount
-- Adds and queries markers. Focus: getMarkerCount.
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

--@api-stub: LMinimap:getMarkerDescription
-- Adds and queries markers. Focus: getMarkerDescription.
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

--@api-stub: LMinimap:setMarkerAnimation
-- Animates markers. Focus: setMarkerAnimation.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    local id = mm:addMarker(8, 8, "Pulse")
    mm:setMarkerAnimation(id, "pulse", 2.0)
    mm:update(0.5)
    mm:clearMarkerAnimation(id)
    print("animation cleared")
end

--@api-stub: LMinimap:clearMarkerAnimation
-- Animates markers. Focus: clearMarkerAnimation.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    local id = mm:addMarker(8, 8, "Pulse")
    mm:setMarkerAnimation(id, "pulse", 2.0)
    mm:update(0.5)
    mm:clearMarkerAnimation(id)
    print("animation cleared")
end

--@api-stub: LMinimap:addObjectType
-- Registers object types with colors. Focus: addObjectType.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    local idx1 = mm:addObjectType("unit", 0, 0, 1)
    local idx2 = mm:addObjectType("building", 1, 1, 0, 0.8)
    print("types = " .. mm:getObjectTypeCount())
    print("unit idx = " .. idx1 .. " building idx = " .. idx2)
end

--@api-stub: LMinimap:getObjectTypeCount
-- Registers object types with colors. Focus: getObjectTypeCount.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    local idx1 = mm:addObjectType("unit", 0, 0, 1)
    local idx2 = mm:addObjectType("building", 1, 1, 0, 0.8)
    print("types = " .. mm:getObjectTypeCount())
    print("unit idx = " .. idx1 .. " building idx = " .. idx2)
end

--@api-stub: LMinimap:setObject
-- Manages objects on the minimap. Focus: setObject.
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

--@api-stub: LMinimap:getObjectCount
-- Manages objects on the minimap. Focus: getObjectCount.
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

--@api-stub: LMinimap:removeObject
-- Manages objects on the minimap. Focus: removeObject.
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

--@api-stub: LMinimap:clearObjects
-- Manages objects on the minimap. Focus: clearObjects.
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

--@api-stub: LMinimap:setObjectTypeVisible
-- Toggles object type visibility. Focus: setObjectTypeVisible.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    local t = mm:addObjectType("hidden", 1, 0, 0)
    mm:setObjectTypeVisible(t, false)
    print("visible = " .. tostring(mm:isObjectTypeVisible(t)))
    mm:setObjectTypeVisible(t, true)
    print("visible = " .. tostring(mm:isObjectTypeVisible(t)))
end

--@api-stub: LMinimap:isObjectTypeVisible
-- Toggles object type visibility. Focus: isObjectTypeVisible.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    local t = mm:addObjectType("hidden", 1, 0, 0)
    mm:setObjectTypeVisible(t, false)
    print("visible = " .. tostring(mm:isObjectTypeVisible(t)))
    mm:setObjectTypeVisible(t, true)
    print("visible = " .. tostring(mm:isObjectTypeVisible(t)))
end

--@api-stub: LMinimap:setOwnerColor
-- Owner color mapping for political mode. Focus: setOwnerColor.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setOwnerColor(1, 0, 0, 1, 1)
    mm:setOwnerColor(2, 1, 0, 0, 1)
    local r, g, b, a = mm:getOwnerColor(1)
    print("owner 1 = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:getOwnerColor
-- Owner color mapping for political mode. Focus: getOwnerColor.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setOwnerColor(1, 0, 0, 1, 1)
    mm:setOwnerColor(2, 1, 0, 0, 1)
    local r, g, b, a = mm:getOwnerColor(1)
    print("owner 1 = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:showPath
-- Path overlays. Focus: showPath.
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

--@api-stub: LMinimap:getPathCount
-- Path overlays. Focus: getPathCount.
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

--@api-stub: LMinimap:clearPath
-- Path overlays. Focus: clearPath.
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

--@api-stub: LMinimap:addPing
-- Timed ping effects. Focus: addPing.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:addPing(8, 8, 2.0, 1, 1, 0)
    mm:addPing(4, 4, 1.0)
    print("pings = " .. mm:getPingCount())
    mm:update(2.5)
    print("pings after time = " .. mm:getPingCount())
end

--@api-stub: LMinimap:getPingCount
-- Timed ping effects. Focus: getPingCount.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:addPing(8, 8, 2.0, 1, 1, 0)
    mm:addPing(4, 4, 1.0)
    print("pings = " .. mm:getPingCount())
    mm:update(2.5)
    print("pings after time = " .. mm:getPingCount())
end

--@api-stub: LMinimap:drawLine
-- Overlay shapes. Focus: drawLine.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:drawLine(0, 0, 15, 15, {255, 255, 255, 255})
    mm:drawRect(2, 2, 4, 4, {0, 255, 0, 200})
    print("shapes = " .. mm:getOverlayShapeCount())
    mm:clearOverlay()
    print("after clear = " .. mm:getOverlayShapeCount())
end

--@api-stub: LMinimap:drawRect
-- Overlay shapes. Focus: drawRect.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:drawLine(0, 0, 15, 15, {255, 255, 255, 255})
    mm:drawRect(2, 2, 4, 4, {0, 255, 0, 200})
    print("shapes = " .. mm:getOverlayShapeCount())
    mm:clearOverlay()
    print("after clear = " .. mm:getOverlayShapeCount())
end

--@api-stub: LMinimap:clearOverlay
-- Overlay shapes. Focus: clearOverlay.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:drawLine(0, 0, 15, 15, {255, 255, 255, 255})
    mm:drawRect(2, 2, 4, 4, {0, 255, 0, 200})
    print("shapes = " .. mm:getOverlayShapeCount())
    mm:clearOverlay()
    print("after clear = " .. mm:getOverlayShapeCount())
end

--@api-stub: LMinimap:getOverlayShapeCount
-- Overlay shapes. Focus: getOverlayShapeCount.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:drawLine(0, 0, 15, 15, {255, 255, 255, 255})
    mm:drawRect(2, 2, 4, 4, {0, 255, 0, 200})
    print("shapes = " .. mm:getOverlayShapeCount())
    mm:clearOverlay()
    print("after clear = " .. mm:getOverlayShapeCount())
end

--@api-stub: LMinimap:setViewportRect
-- Viewport rectangle overlay. Focus: setViewportRect.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setViewportRect(4, 4, 12, 12)
    local x, y, w, h = mm:getViewportRect()
    print("viewport = " .. x .. "," .. y .. " " .. w .. "x" .. h)
    mm:clearViewportRect()
end

--@api-stub: LMinimap:getViewportRect
-- Viewport rectangle overlay. Focus: getViewportRect.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setViewportRect(4, 4, 12, 12)
    local x, y, w, h = mm:getViewportRect()
    print("viewport = " .. x .. "," .. y .. " " .. w .. "x" .. h)
    mm:clearViewportRect()
end

--@api-stub: LMinimap:clearViewportRect
-- Viewport rectangle overlay. Focus: clearViewportRect.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setViewportRect(4, 4, 12, 12)
    local x, y, w, h = mm:getViewportRect()
    print("viewport = " .. x .. "," .. y .. " " .. w .. "x" .. h)
    mm:clearViewportRect()
end

--@api-stub: LMinimap:setViewportColor
-- Viewport rectangle color. Focus: setViewportColor.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setViewportColor(1, 1, 0, 0.5)
    local r, g, b, a = mm:getViewportColor()
    print("vp color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:getViewportColor
-- Viewport rectangle color. Focus: getViewportColor.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setViewportColor(1, 1, 0, 0.5)
    local r, g, b, a = mm:getViewportColor()
    print("vp color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMinimap:setViewportVisible
-- Viewport rectangle visibility toggle. Focus: setViewportVisible.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setViewportVisible(true)
    print("vp visible = " .. tostring(mm:isViewportVisible()))
end

--@api-stub: LMinimap:isViewportVisible
-- Viewport rectangle visibility toggle. Focus: isViewportVisible.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setViewportVisible(true)
    print("vp visible = " .. tostring(mm:isViewportVisible()))
end

--@api-stub: LMinimap:setClickable
-- Clickable toggle. Focus: setClickable.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setClickable(true)
    print("clickable = " .. tostring(mm:isClickable()))
end

--@api-stub: LMinimap:isClickable
-- Clickable toggle. Focus: isClickable.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setClickable(true)
    print("clickable = " .. tostring(mm:isClickable()))
end

--@api-stub: LMinimap:gridToScreen
-- Coordinate mapping. Focus: gridToScreen.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16, 160, 160)
    local sx, sy = mm:gridToScreen(8, 8, 0, 0)
    print("grid(8,8) → screen = " .. sx .. "," .. sy)
    local gx, gy = mm:screenToGrid(sx, sy, 0, 0)
    print("screen → grid = " .. gx .. "," .. gy)
end

--@api-stub: LMinimap:screenToGrid
-- Coordinate mapping. Focus: screenToGrid.
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

--- Minimap Module Part 3: textures, display size, grid size, camera tracking, type


--@api-stub: LMinimap:getDisplaySize
-- Display and grid dimension queries. Focus: getDisplaySize.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32, 200, 200)
    local dw, dh = mm:getDisplaySize()
    local gw, gh = mm:getGridSize()
    print("display=" .. dw .. "x" .. dh)
    print("grid=" .. gw .. "x" .. gh)
end

--@api-stub: LMinimap:getGridSize
-- Display and grid dimension queries. Focus: getGridSize.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32, 200, 200)
    local dw, dh = mm:getDisplaySize()
    local gw, gh = mm:getGridSize()
    print("display=" .. dw .. "x" .. dh)
    print("grid=" .. gw .. "x" .. gh)
end

--@api-stub: LMinimap:setMarkerTexture
-- Assign and clear a texture for a named marker. Focus: setMarkerTexture.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    mm:addMarker(16, 16, "Hero")
    local img = lurek.render.newImage("assets/textures/ray_water.png")
    mm:setMarkerTexture(1, img, 32, 32)
    mm:clearMarkerTexture(1)
    print("marker texture cleared")
end

--@api-stub: LMinimap:clearMarkerTexture
-- Assign and clear a texture for a named marker. Focus: clearMarkerTexture.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    mm:addMarker(16, 16, "Hero")
    local img = lurek.render.newImage("assets/textures/ray_water.png")
    mm:setMarkerTexture(1, img, 32, 32)
    mm:clearMarkerTexture(1)
    print("marker texture cleared")
end

--@api-stub: LMinimap:setObjectTypeTexture
-- Assign and clear a texture for an object type. Focus: setObjectTypeTexture.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    mm:addObjectType("unit", 0, 1, 0, 1)
    local img = lurek.render.newImage("assets/textures/ray_water.png")
    mm:setObjectTypeTexture(1, img, 16, 16)
    mm:clearObjectTypeTexture(1)
    print("object type texture cleared")
end

--@api-stub: LMinimap:clearObjectTypeTexture
-- Assign and clear a texture for an object type. Focus: clearObjectTypeTexture.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    mm:addObjectType("unit", 0, 1, 0, 1)
    local img = lurek.render.newImage("assets/textures/ray_water.png")
    mm:setObjectTypeTexture(1, img, 16, 16)
    mm:clearObjectTypeTexture(1)
    print("object type texture cleared")
end

--@api-stub: LMinimap:trackCamera
-- Automatically center the minimap on a camera.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    local cam = lurek.camera.newCamera()
    mm:trackCamera(cam)
    print("camera tracked")
end

--@api-stub: LMinimap:type
-- Type introspection on LMinimap. Focus: type.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    print(mm:type())
    print(mm:typeOf("LMinimap"))
    print(mm:typeOf("Object"))
end

--@api-stub: LMinimap:typeOf
-- Type introspection on LMinimap. Focus: typeOf.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    print(mm:type())
    print(mm:typeOf("LMinimap"))
    print(mm:typeOf("Object"))
end

print("content/examples/minimap.lua")
