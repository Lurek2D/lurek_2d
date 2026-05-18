--- Minimap Module Part 1: creation, terrain, fog, display, layers

--@api-stub: lurek.minimap.newMinimap
-- Creates a minimap with grid and display dimensions.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(64, 64, 200, 200)
    local gw, gh = mm:getGridSize()
    local dw, dh = mm:getDisplaySize()
    print("grid=" .. gw .. "x" .. gh .. " display=" .. dw .. "x" .. dh)
end

--@api-stub: LMinimap:setTerrain / getTerrain
-- Sets and reads terrain type for grid cells.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTerrain(1, 1, 1)
    mm:setTerrain(2, 1, 2)
    mm:setTerrain(3, 1, 3)
    print("terrain(1,1) = " .. mm:getTerrain(1, 1))
    print("terrain(2,1) = " .. mm:getTerrain(2, 1))
end

--@api-stub: LMinimap:setTerrainColor / getTerrainColor
-- Assigns RGBA color to terrain type ids.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTerrainColor(1, 0.2, 0.6, 0.1)
    mm:setTerrainColor(2, 0.1, 0.3, 0.8)
    mm:setTerrainColor(3, 0.8, 0.8, 0.2, 0.9)
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

--@api-stub: LMinimap:setFogEnabled / isFogEnabled
-- Toggles fog overlay display.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setFogEnabled(true)
    print("fog enabled = " .. tostring(mm:isFogEnabled()))
end

--@api-stub: LMinimap:setFogLevel / getFogLevel
-- Sets fog density per cell.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setFogEnabled(true)
    mm:setFogLevel(1, 1, 255)
    mm:setFogLevel(4, 4, 128)
    print("fog(1,1) = " .. mm:getFogLevel(1, 1))
    print("fog(4,4) = " .. mm:getFogLevel(4, 4))
end

--@api-stub: LMinimap:setFogColor / getFogColor
-- Sets the fog overlay color.
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

--@api-stub: LMinimap:setColorMode / getColorMode
-- Switches between terrain and political color modes.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setColorMode("political")
    print("mode = " .. mm:getColorMode())
    mm:setColorMode("terrain")
    print("mode = " .. mm:getColorMode())
end

--@api-stub: LMinimap:setLayer / getLayer / getLayerCount / setLayerData / getLayerData
-- Multi-layer support.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(4, 4)
    mm:setLayer(1)
    print("layer = " .. mm:getLayer() .. " count = " .. mm:getLayerCount())
    local data = {}
    for i = 1, 16 do data[i] = i end
    mm:setLayerData(1, data)
    local out = mm:getLayerData(1)
    if out then
        print("layer data len = " .. #out)
    end
end

--@api-stub: LMinimap:setDisplaySize / getDisplayWidth / getDisplayHeight
-- Resizes the minimap display.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16, 100, 100)
    mm:setDisplaySize(300, 250)
    print("display = " .. mm:getDisplayWidth() .. "x" .. mm:getDisplayHeight())
end

--@api-stub: LMinimap:setCenter / getCenter / getCenterX / getCenterY
-- Camera centering.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setCenter(16, 16)
    local cx, cy = mm:getCenter()
    print("center = " .. cx .. "," .. cy)
    print("x=" .. mm:getCenterX() .. " y=" .. mm:getCenterY())
end

--@api-stub: LMinimap:setZoom / getZoom
-- Zoom control.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setZoom(2.0)
    print("zoom = " .. mm:getZoom())
end

--@api-stub: LMinimap:setAntiAlias / isAntiAlias
-- Anti-aliasing toggle.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setAntiAlias(true)
    print("aa = " .. tostring(mm:isAntiAlias()))
end

--@api-stub: LMinimap:getCellCount / getGridWidth / getGridHeight
-- Grid dimension queries.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(10, 20)
    print("cells = " .. mm:getCellCount())
    print("w=" .. mm:getGridWidth() .. " h=" .. mm:getGridHeight())
end

--@api-stub: LMinimap:setTileDescription / getTileDescription
-- Tile type descriptions.
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

print("minimap_00.lua")
