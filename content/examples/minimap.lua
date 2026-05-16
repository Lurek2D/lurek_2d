-- content/examples/minimap.lua
-- lurek.minimap API examples.
-- Run: cargo run -- content/examples/minimap.lua

--@api-stub: lurek.minimap.newMinimap -- Creates a minimap with grid dimensions and optional display size
do -- lurek.minimap.newMinimap
  local mm = lurek.minimap.newMinimap(64, 48, 256, 192)
  mm:setTerrain(1, 1, 1)
  lurek.log.info("minimap grid " .. mm:getGridWidth() .. "x" .. mm:getGridHeight(), "minimap")
end

-- â”€â”€ Minimap methods â”€â”€

--@api-stub: Minimap:getGridWidth
do -- Minimap:getGridWidth
  local mm = lurek.minimap.newMinimap(80, 60)
  local w = mm:getGridWidth()
  for x = 1, w do mm:setTerrain(x, 1, 2) end
end

--@api-stub: Minimap:getGridHeight
do -- Minimap:getGridHeight
  local mm = lurek.minimap.newMinimap(80, 60)
  local h = mm:getGridHeight()
  for y = 1, h do mm:setTerrain(1, y, 3) end
end

--@api-stub: Minimap:getGridSize
do -- Minimap:getGridSize
  local mm = lurek.minimap.newMinimap(48, 32)
  local gw, gh = mm:getGridSize()
  lurek.log.info("grid cells: " .. (gw * gh), "minimap")
end

--@api-stub: Minimap:getDisplayWidth
do -- Minimap:getDisplayWidth
  local mm = lurek.minimap.newMinimap(32, 32, 240, 180)
  local px = mm:getDisplayWidth()
  local hud_x = 16 + px + 8
  lurek.log.info("hud x=" .. hud_x, "ui")
end

--@api-stub: Minimap:getDisplayHeight
do -- Minimap:getDisplayHeight
  local mm = lurek.minimap.newMinimap(32, 32, 240, 180)
  local py = mm:getDisplayHeight()
  lurek.log.info("minimap occupies " .. py .. " px tall", "ui")
end

--@api-stub: Minimap:getDisplaySize
do -- Minimap:getDisplaySize
  local mm = lurek.minimap.newMinimap(40, 30, 200, 150)
  local dw, dh = mm:getDisplaySize()
  local cx, cy = dw * 0.5, dh * 0.5
  lurek.log.info("center px " .. cx .. "," .. cy, "minimap")
end

--@api-stub: Minimap:setDisplaySize
do -- Minimap:setDisplaySize
  local mm = lurek.minimap.newMinimap(64, 64)
  mm:setDisplaySize(320, 240)
  local w, h = mm:getDisplaySize()
  lurek.log.info("resized minimap to " .. w .. "x" .. h, "ui")
end

--@api-stub: Minimap:getTerrain
do -- Minimap:getTerrain
  local mm = lurek.minimap.newMinimap(16, 16)
  mm:setTerrain(4, 4, 7)
  local t = mm:getTerrain(4, 4)
  if t == 7 then lurek.log.info("forest tile at 4,4", "minimap") end
end

--@api-stub: Minimap:setTerrainData
do -- Minimap:setTerrainData
  local mm = lurek.minimap.newMinimap(4, 3)
  local data = { 1,1,2,2, 1,3,3,2, 0,3,3,0 }
  mm:setTerrainData(data)
  lurek.log.info("seeded " .. #data .. " cells", "minimap")
end

--@api-stub: Minimap:getTerrainColor
do -- Minimap:getTerrainColor
  local mm = lurek.minimap.newMinimap(8, 8)
  mm:setTerrainColor(2, 0.2, 0.6, 0.1, 1.0)
  local r, g, b, a = mm:getTerrainColor(2)
  lurek.log.info("forest swatch " .. r .. "," .. g .. "," .. b .. "," .. a, "ui")
end

--@api-stub: Minimap:getTileDescription
do -- Minimap:getTileDescription
  local mm = lurek.minimap.newMinimap(8, 8)
  mm:setTileDescription(3, "Dense forest, slows movement")
  local desc = mm:getTileDescription(3)
  if desc then lurek.log.info("tooltip: " .. desc, "ui") end
end

--@api-stub: Minimap:setFogEnabled
do -- Minimap:setFogEnabled
  local mm = lurek.minimap.newMinimap(32, 32)
  mm:setFogEnabled(true)
  if mm:isFogEnabled() then lurek.log.info("fog on", "minimap") end
end

--@api-stub: Minimap:isFogEnabled
do -- Minimap:isFogEnabled
  local mm = lurek.minimap.newMinimap(32, 32)
  mm:setFogEnabled(false)
  if not mm:isFogEnabled() then mm:setTerrain(1, 1, 9) end
end

--@api-stub: Minimap:setFogLevel
do -- Minimap:setFogLevel
  local mm = lurek.minimap.newMinimap(20, 20)
  mm:setFogEnabled(true)
  for x = 4, 8 do mm:setFogLevel(x, 5, 2) end
  mm:setFogLevel(6, 5, 1)
end

--@api-stub: Minimap:getFogLevel
do -- Minimap:getFogLevel
  local mm = lurek.minimap.newMinimap(16, 16)
  mm:setFogEnabled(true)
  mm:setFogLevel(8, 8, 2)
  if mm:getFogLevel(8, 8) == 2 then lurek.log.info("cell visible", "fog") end
end

--@api-stub: Minimap:getFogColor
do -- Minimap:getFogColor
  local mm = lurek.minimap.newMinimap(16, 16)
  mm:setFogColor(0.05, 0.05, 0.1, 0.85)
  local r, g, b, a = mm:getFogColor()
  lurek.log.info("fog rgba " .. r .. "," .. g .. "," .. b .. "," .. a, "fog")
end

--@api-stub: Minimap:setFogData
do -- Minimap:setFogData
  local mm = lurek.minimap.newMinimap(4, 3)
  mm:setFogEnabled(true)
  local fog = { 2,2,1,0, 2,2,1,0, 1,1,1,0 }
  mm:setFogData(fog)
end

--@api-stub: Minimap:isObjectTypeVisible
do -- Minimap:isObjectTypeVisible
  local mm = lurek.minimap.newMinimap(20, 20)
  local enemy = mm:addObjectType("enemy", 1, 0.1, 0.1, 1)
  if mm:isObjectTypeVisible(enemy) then lurek.log.info("enemies shown", "minimap") end
end

--@api-stub: Minimap:getObjectTypeCount
do -- Minimap:getObjectTypeCount
  local mm = lurek.minimap.newMinimap(20, 20)
  mm:addObjectType("ally", 0.2, 0.6, 1, 1)
  mm:addObjectType("enemy", 1, 0.2, 0.2, 1)
  lurek.log.info("registered types: " .. mm:getObjectTypeCount(), "minimap")
end

--@api-stub: Minimap:removeObject
do -- Minimap:removeObject
  local mm = lurek.minimap.newMinimap(20, 20)
  local t = mm:addObjectType("loot", 1, 1, 0, 1)
  mm:setObject(101, 5, 5, t)
  if mm:removeObject(101) then lurek.log.info("loot 101 picked up", "minimap") end
end

--@api-stub: Minimap:clearObjects
do -- Minimap:clearObjects
  local mm = lurek.minimap.newMinimap(20, 20)
  local t = mm:addObjectType("npc", 0, 1, 0, 1)
  mm:setObject(1, 4, 4, t); mm:setObject(2, 9, 9, t)
  mm:clearObjects()
  lurek.log.info("objects after clear: " .. mm:getObjectCount(), "minimap")
end

--@api-stub: Minimap:getObjectCount
do -- Minimap:getObjectCount
  local mm = lurek.minimap.newMinimap(16, 16)
  local t = mm:addObjectType("rat", 0.6, 0.4, 0.2, 1)
  for i = 1, 5 do mm:setObject(i, i, i, t) end
  lurek.log.info("tracked: " .. mm:getObjectCount(), "minimap")
end

--@api-stub: Minimap:getOwnerColor
do -- Minimap:getOwnerColor
  local mm = lurek.minimap.newMinimap(16, 16)
  mm:setOwnerColor(2, 0.1, 0.4, 0.9, 1)
  local r, g, b, a = mm:getOwnerColor(2)
  lurek.log.info("team 2 colour " .. r .. "," .. g .. "," .. b .. "," .. a, "team")
end

--@api-stub: Minimap:setColorMode
do -- Minimap:setColorMode
  local mm = lurek.minimap.newMinimap(20, 20)
  mm:setColorMode("political")
  lurek.log.info("mode now " .. mm:getColorMode(), "minimap")
end

--@api-stub: Minimap:getColorMode
do -- Minimap:getColorMode
  local mm = lurek.minimap.newMinimap(16, 16)
  mm:setColorMode("terrain")
  if mm:getColorMode() == "terrain" then mm:setTerrainColor(1, 0.3, 0.5, 0.2, 1) end
end

--@api-stub: Minimap:setZoom
do -- Minimap:setZoom
  local mm = lurek.minimap.newMinimap(64, 64)
  mm:setZoom(2.5)
  lurek.log.info("zoom " .. mm:getZoom(), "minimap")
end

--@api-stub: Minimap:getZoom
do -- Minimap:getZoom
  local mm = lurek.minimap.newMinimap(48, 48, 240, 240)
  mm:setZoom(1.5)
  local cell_px = (mm:getDisplayWidth() / mm:getGridWidth()) * mm:getZoom()
  lurek.log.info("cell size " .. cell_px .. " px", "minimap")
end

--@api-stub: Minimap:setCenter
do -- Minimap:setCenter
  local mm = lurek.minimap.newMinimap(128, 128, 200, 200)
  local player = { x = 64, y = 32 }
  mm:setCenter(player.x, player.y)
end

--@api-stub: Minimap:getCenter
do -- Minimap:getCenter
  local mm = lurek.minimap.newMinimap(64, 64)
  mm:setCenter(20.5, 35.0)
  local cx, cy = mm:getCenter()
  lurek.log.info("centered at " .. cx .. "," .. cy, "minimap")
end

--@api-stub: Minimap:getCenterX
do -- Minimap:getCenterX
  local mm = lurek.minimap.newMinimap(64, 64)
  mm:setCenter(40, 20)
  if mm:getCenterX() > 32 then mm:setCenter(32, mm:getCenterY()) end
end

--@api-stub: Minimap:getCenterY
do -- Minimap:getCenterY
  local mm = lurek.minimap.newMinimap(64, 48)
  mm:setCenter(10, 50)
  local cy = math.min(mm:getCenterY(), 40)
  mm:setCenter(mm:getCenterX(), cy)
end

--@api-stub: Minimap:clearViewportRect
do -- Minimap:clearViewportRect
  local mm = lurek.minimap.newMinimap(80, 60)
  mm:setViewportRect(10, 10, 20, 15)
  mm:clearViewportRect()
  local x = mm:getViewportRect()
  if x == nil then lurek.log.info("viewport hidden", "minimap") end
end

--@api-stub: Minimap:getViewportRect
do -- Minimap:getViewportRect
  local mm = lurek.minimap.newMinimap(80, 60)
  mm:setViewportRect(5, 8, 16, 12)
  local x, y, w, h = mm:getViewportRect()
  if x then lurek.log.info("viewport " .. x .. "," .. y .. " " .. w .. "x" .. h, "minimap") end
end

--@api-stub: Minimap:setViewportVisible
do -- Minimap:setViewportVisible
  local mm = lurek.minimap.newMinimap(80, 60)
  mm:setViewportRect(0, 0, 24, 18)
  mm:setViewportVisible(false)
end

--@api-stub: Minimap:isViewportVisible
do -- Minimap:isViewportVisible
  local mm = lurek.minimap.newMinimap(80, 60)
  mm:setViewportRect(0, 0, 16, 12)
  if mm:isViewportVisible() then lurek.log.info("viewport overlay on", "minimap") end
end

--@api-stub: Minimap:getViewportColor
do -- Minimap:getViewportColor
  local mm = lurek.minimap.newMinimap(40, 30)
  mm:setViewportColor(1, 1, 1, 0.6)
  local r, g, b, a = mm:getViewportColor()
  lurek.log.info("viewport rgba " .. r .. "," .. g .. "," .. b .. "," .. a, "ui")
end

--@api-stub: Minimap:getPingCount
do -- Minimap:getPingCount
  local mm = lurek.minimap.newMinimap(40, 30)
  mm:addPing(10, 10, 1.5)
  mm:addPing(20, 15, 1.5, 0.2, 1, 0.4, 1)
  lurek.log.info("pings active: " .. mm:getPingCount(), "minimap")
end

--@api-stub: Minimap:removeMarker
do -- Minimap:removeMarker
  local mm = lurek.minimap.newMinimap(40, 30)
  local id = mm:addMarker(5, 5, "Quest goal")
  if mm:removeMarker(id) then lurek.log.info("marker " .. id .. " cleared", "minimap") end
end

--@api-stub: Minimap:hasMarker
do -- Minimap:hasMarker
  local mm = lurek.minimap.newMinimap(40, 30)
  local id = mm:addMarker(8, 6, "Ally HQ")
  if mm:hasMarker(id) then mm:setMarkerAnimation(id, "pulse", 1.5) end
end

--@api-stub: Minimap:getMarkerDescription
do -- Minimap:getMarkerDescription
  local mm = lurek.minimap.newMinimap(40, 30)
  local id = mm:addMarker(12, 9, "Hidden cache")
  local desc = mm:getMarkerDescription(id)
  if desc then lurek.log.info("marker " .. id .. ": " .. desc, "minimap") end
end

--@api-stub: Minimap:getMarkerCount
do -- Minimap:getMarkerCount
  local mm = lurek.minimap.newMinimap(32, 32)
  mm:addMarker(2, 2, "A"); mm:addMarker(8, 4, "B"); mm:addMarker(14, 7, "C")
  lurek.log.info("markers placed: " .. mm:getMarkerCount(), "minimap")
end

--@api-stub: Minimap:clearMarkerAnimation
do -- Minimap:clearMarkerAnimation
  local mm = lurek.minimap.newMinimap(32, 32)
  local id = mm:addMarker(4, 4, "Boss")
  mm:setMarkerAnimation(id, "blink", 4.0)
  mm:clearMarkerAnimation(id)
end

--@api-stub: Minimap:clearOverlay
do -- Minimap:clearOverlay
  local mm = lurek.minimap.newMinimap(40, 30)
  mm:drawLine(0, 0, 40, 30, { 255, 255, 0, 255 })
  mm:drawRect(5, 5, 10, 8, { 0, 200, 255, 180 })
  mm:clearOverlay()
end

--@api-stub: Minimap:clearPath
do -- Minimap:clearPath
  local mm = lurek.minimap.newMinimap(40, 30)
  local id = mm:showPath({ {2,2}, {6,4}, {10,8} }, { 0, 255, 0, 200 })
  mm:clearPath(id)
end

--@api-stub: Minimap:setLayer
do -- Minimap:setLayer
  local mm = lurek.minimap.newMinimap(8, 4)
  mm:setLayerData(1, { 1,1,2,2,1,1,2,2, 0,1,1,2,0,1,1,2, 0,0,1,1,0,0,1,1, 0,0,0,1,0,0,0,1 })
  mm:setLayer(1)
end

--@api-stub: Minimap:getLayer
do -- Minimap:getLayer
  local mm = lurek.minimap.newMinimap(16, 16)
  mm:setLayer(2)
  lurek.log.info("active layer: " .. mm:getLayer(), "minimap")
end

--@api-stub: Minimap:setAntiAlias
do -- Minimap:setAntiAlias
  local mm = lurek.minimap.newMinimap(32, 32)
  mm:setAntiAlias(false)
  if not mm:isAntiAlias() then lurek.log.info("pixel-perfect minimap", "render") end
end

--@api-stub: Minimap:isAntiAlias
do -- Minimap:isAntiAlias
  local mm = lurek.minimap.newMinimap(32, 32)
  mm:setAntiAlias(true)
  local opts = { aa = mm:isAntiAlias() }
  lurek.log.info("graphics.aa=" .. tostring(opts.aa), "settings")
end

--@api-stub: Minimap:setClickable
do -- Minimap:setClickable
  local mm = lurek.minimap.newMinimap(40, 30)
  mm:setClickable(false)
  if not mm:isClickable() then lurek.log.info("minimap input disabled", "ui") end
end

--@api-stub: Minimap:isClickable
do -- Minimap:isClickable
  local mm = lurek.minimap.newMinimap(40, 30)
  mm:setClickable(true)
  if mm:isClickable() then mm:addMarker(20, 15, "click target") end
end

--@api-stub: Minimap:update
do -- Minimap:update
  local mm = lurek.minimap.newMinimap(32, 32)
  mm:addPing(8, 8, 0.5)
  function lurek.process(dt) mm:update(dt) end
end

--@api-stub: Minimap:type
do -- Minimap:type
  local mm = lurek.minimap.newMinimap(16, 16)
  if mm:type() == "Minimap" then lurek.log.info("widget is a minimap", "ui") end
end

--@api-stub: Minimap:typeOf
do -- Minimap:typeOf
  local mm = lurek.minimap.newMinimap(16, 16)
  if mm:typeOf("Object") then lurek.log.info("widget responds to Object api", "ui") end
end

--@api-stub: Minimap:render
do -- Minimap:render
  local mm
  function lurek.init() mm = lurek.minimap.newMinimap(48, 32, 200, 140) end
  function lurek.draw() mm:render(20, 20) end
end

--@api-stub: Minimap:drawToImage
do -- Minimap:drawToImage
  local mm = lurek.minimap.newMinimap(16, 16)
  mm:setTerrain(1, 1, 1)
  local img = mm:drawToImage(8)
  lurek.log.info("snapshot: " .. img:getWidth() .. "x" .. img:getHeight(), "minimap")
end

--@api-stub: Minimap:addMarker
do -- Minimap:addMarker
  local mm = lurek.minimap.newMinimap(64, 64, 4)
  local id = mm:addMarker(20, 30, "quest_marker", 1, 1, 0, 1)
  lurek.log.info("marker id: " .. id, "minimap")
end

--@api-stub: Minimap:addObjectType
do -- Minimap:addObjectType
  local mm = lurek.minimap.newMinimap(32, 32, 4)
  local enemy_idx = mm:addObjectType("enemy", 1, 0, 0, 1)
  local ally_idx = mm:addObjectType("ally",  0, 0.5, 1, 1)
  lurek.log.info("object types: " .. mm:getObjectTypeCount(), "minimap")
end

--@api-stub: Minimap:addPing
do -- Minimap:addPing
  local mm = lurek.minimap.newMinimap(64, 64, 4)
  mm:addPing(32, 32, 2.0, 0, 1, 1, 1)
  lurek.log.info("ping added; count: " .. mm:getPingCount(), "minimap")
end

--@api-stub: Minimap:drawLine
do -- Minimap:drawLine
  local mm = lurek.minimap.newMinimap(32, 32, 4)
  mm:drawLine(0, 0, 31, 31, {1, 1, 0, 1})
  lurek.log.info("overlay line drawn", "minimap")
end

--@api-stub: Minimap:drawRect
do -- Minimap:drawRect
  local mm = lurek.minimap.newMinimap(32, 32, 4)
  mm:drawRect(5, 5, 20, 20, {0, 1, 0, 0.5})
  lurek.log.info("overlay rect drawn", "minimap")
end

--@api-stub: Minimap:getHoverInfo
do -- Minimap:getHoverInfo
  local mm = lurek.minimap.newMinimap(64, 64, 4)
  mm:setTerrain(10, 10, 1)
  local info = mm:getHoverInfo(40, 40, 0, 0)
  lurek.log.info("hover info: " .. tostring(info), "minimap")
end

--@api-stub: Minimap:gridToScreen
do -- Minimap:gridToScreen
  local mm = lurek.minimap.newMinimap(32, 32, 4)
  local sx, sy = mm:gridToScreen(16, 16, 0, 0)
  lurek.log.info("grid 16,16 -> screen " .. sx .. "," .. sy, "minimap")
end

--@api-stub: Minimap:screenToGrid
do -- Minimap:screenToGrid
  local mm = lurek.minimap.newMinimap(32, 32, 4)
  local gx, gy = mm:screenToGrid(64, 64, 0, 0)
  lurek.log.info("screen -> grid: " .. gx .. "," .. gy, "minimap")
end

--@api-stub: Minimap:setFogColor
do -- Minimap:setFogColor
  local mm = lurek.minimap.newMinimap(64, 64, 4)
  mm:setFogEnabled(true)
  mm:setFogColor(0.0, 0.0, 0.1, 0.7)
  lurek.log.info("fog colour set", "minimap")
end

--@api-stub: Minimap:setLayerData
do -- Minimap:setLayerData
  local mm = lurek.minimap.newMinimap(8, 8, 8)
  local data = {}
  for i = 1, 64 do data[i] = (i % 2 == 0) and 1 or 0 end
  mm:setLayerData(0, data)
  lurek.log.info("layer data set", "minimap")
end

--@api-stub: Minimap:setMarkerAnimation
do -- Minimap:setMarkerAnimation
  local mm = lurek.minimap.newMinimap(32, 32, 4)
  local marker_id = mm:addMarker(16, 16, "quest_marker", 1, 1, 0, 1)
  mm:setMarkerAnimation(marker_id, "pulse", 4)
  lurek.log.info("marker animation set", "minimap")
end

--@api-stub: Minimap:setObject
do -- Minimap:setObject
  local mm = lurek.minimap.newMinimap(32, 32, 4)
  local unit_idx = mm:addObjectType("unit", 0, 0.7, 1, 1)
  mm:setObject(1, 16, 16, unit_idx)
  lurek.log.info("object count: " .. mm:getObjectCount(), "minimap")
end

--@api-stub: Minimap:setObjectTypeVisible
do -- Minimap:setObjectTypeVisible
  local mm = lurek.minimap.newMinimap(32, 32, 4)
  local enemy_idx = mm:addObjectType("enemy", 1, 0, 0, 1)
  mm:setObjectTypeVisible(enemy_idx, false)
  lurek.log.info("enemy visible: " .. tostring(mm:isObjectTypeVisible(enemy_idx)), "minimap")
end

--@api-stub: Minimap:setOwnerColor
do -- Minimap:setOwnerColor
  local mm = lurek.minimap.newMinimap(32, 32, 4)
  mm:setOwnerColor(1, 0.9, 0.1, 0.1, 1)
  mm:setOwnerColor(2, 0.1, 0.2, 0.9, 1)
  lurek.log.info("owner colours set", "minimap")
end

--@api-stub: Minimap:setTerrain
do -- Minimap:setTerrain
  local mm = lurek.minimap.newMinimap(32, 32, 4)
  mm:setTerrainColor(1, 0.2, 0.4, 0.9, 1)
  mm:setTerrain(5, 10, 1)
  lurek.log.info("terrain set", "minimap")
end

--@api-stub: Minimap:setTerrainColor
do -- Minimap:setTerrainColor
  local mm = lurek.minimap.newMinimap(32, 32, 4)
  mm:setTerrainColor(1, 0.1, 0.6, 0.1, 1)
  mm:setTerrainColor(2, 0.9, 0.8, 0.4, 1)
  lurek.log.info("terrain colours registered", "minimap")
end

--@api-stub: Minimap:setTileDescription
do -- Minimap:setTileDescription
  local mm = lurek.minimap.newMinimap(32, 32, 4)
  mm:setTerrainColor(1, 0.5, 0.5, 0.5, 1)
  mm:setTileDescription(1, "Impassable rock face")
  lurek.log.info("tile description set", "minimap")
end

--@api-stub: Minimap:setViewportColor
do -- Minimap:setViewportColor
  local mm = lurek.minimap.newMinimap(64, 64, 4)
  mm:setViewportColor(1, 1, 0, 0.8)
  lurek.log.info("viewport colour set", "minimap")
end

--@api-stub: Minimap:setViewportRect
do -- Minimap:setViewportRect
  local mm = lurek.minimap.newMinimap(64, 64, 4)
  mm:setViewportRect(100, 100, 800, 600)
  lurek.log.info("viewport rect set", "minimap")
end

--@api-stub: Minimap:showPath
do -- Minimap:showPath
  local mm = lurek.minimap.newMinimap(32, 32, 4)
  local path = {{5,5},{10,10},{20,15}}
  mm:showPath(path, {1, 0.5, 0, 1})
  lurek.log.info("path shown", "minimap")
end

--@api-stub: Minimap:getCellCount
do -- Minimap:getCellCount
  local mm = lurek.minimap.newMinimap(40, 30)
  lurek.log.info("cell count: " .. mm:getCellCount(), "minimap")
end

--@api-stub: Minimap:trackCamera
do -- Minimap:trackCamera
  local mm = lurek.minimap.newMinimap(64, 64, 200, 200)
  local cam = lurek.camera.new(20, 10)
  cam:setPosition(12, 18)
  cam:setZoom(2)
  mm:trackCamera(cam)
  local x, y, w, h = mm:getViewportRect()
  lurek.log.info("camera rect " .. tostring(x) .. "," .. tostring(y) .. "," .. tostring(w) .. "," .. tostring(h), "minimap")
end

--@api-stub: Minimap:revealRadius
do -- Minimap:revealRadius
  local mm = lurek.minimap.newMinimap(16, 16)
  mm:setFogEnabled(true)
  mm:revealRadius(8, 8, 3)
  lurek.log.info("fog center level: " .. mm:getFogLevel(8, 8), "minimap")
end

--@api-stub: Minimap:setObjectTypeTexture
do -- Minimap:setObjectTypeTexture
  local mm = lurek.minimap.newMinimap(32, 32)
  local tex = lurek.render.newImage("assets/icon.png")
  local idx = mm:addObjectType("unit", 1, 1, 1, 1)
  mm:setObjectTypeTexture(idx, tex, 12, 12)
end

--@api-stub: Minimap:clearObjectTypeTexture
do -- Minimap:clearObjectTypeTexture
  local mm = lurek.minimap.newMinimap(32, 32)
  local tex = lurek.render.newImage("assets/icon.png")
  local idx = mm:addObjectType("unit", 1, 1, 1, 1)
  mm:setObjectTypeTexture(idx, tex, 12, 12)
  mm:clearObjectTypeTexture(idx)
end

--@api-stub: Minimap:setMarkerTexture
do -- Minimap:setMarkerTexture
  local mm = lurek.minimap.newMinimap(32, 32)
  local tex = lurek.render.newImage("assets/icon.png")
  local id = mm:addMarker(10, 12, "poi")
  mm:setMarkerTexture(id, tex, 10, 10)
end

--@api-stub: Minimap:clearMarkerTexture
do -- Minimap:clearMarkerTexture
  local mm = lurek.minimap.newMinimap(32, 32)
  local tex = lurek.render.newImage("assets/icon.png")
  local id = mm:addMarker(10, 12, "poi")
  mm:setMarkerTexture(id, tex, 10, 10)
  mm:clearMarkerTexture(id)
end

--@api-stub: Minimap:getOverlayShapeCount
do -- Minimap:getOverlayShapeCount
  local mm = lurek.minimap.newMinimap(32, 32)
  mm:drawLine(0, 0, 8, 8, {255, 0, 0, 255})
  mm:drawRect(4, 4, 6, 6, {0, 255, 0, 180})
  lurek.log.info("overlay shapes: " .. mm:getOverlayShapeCount(), "minimap")
end

--@api-stub: Minimap:getPathCount
do -- Minimap:getPathCount
  local mm = lurek.minimap.newMinimap(32, 32)
  mm:showPath({ {2,2}, {3,4}, {5,6} }, {255, 200, 0, 255})
  lurek.log.info("path count: " .. mm:getPathCount(), "minimap")
end

--@api-stub: Minimap:getLayerCount
do -- Minimap:getLayerCount
  local mm = lurek.minimap.newMinimap(4, 4)
  mm:setLayerData(1, {0,1,0,1, 1,0,1,0, 0,1,0,1, 1,0,1,0})
  lurek.log.info("layer count: " .. mm:getLayerCount(), "minimap")
end

--@api-stub: Minimap:getLayerData
do -- Minimap:getLayerData
  local mm = lurek.minimap.newMinimap(4, 4)
  mm:setLayerData(0, {1,2,3,4, 4,3,2,1, 1,2,3,4, 4,3,2,1})
  local data = mm:getLayerData(0)
  lurek.log.info("layer data len: " .. tostring(data and #data or 0), "minimap")
end

