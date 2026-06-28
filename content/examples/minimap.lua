-- content/examples/minimap.lua
-- Auto-generated from content/examples2/minimap_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/minimap.lua
-- Tilefield-driven games should feed minimap terrain/fog/layer data from
-- lurek.tilefield exports and lurek.awareness masks. The minimap remains a
-- passive visualization surface and does not compute LOS, action range, or light.


--- Minimap Module Part 1: creation, terrain, fog, display, layers


--@api: lurek.minimap.newMinimap
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(64, 64, 200, 200)
    mm:setCenter(32, 24)
    mm:setZoom(1.25)
    local dw, dh = mm:getDisplaySize()
    minimap_log("command view " .. mm:getGridWidth() .. "x" .. mm:getGridHeight() .. " -> " .. dw .. "x" .. dh)
end

--@api: LMinimap:setTerrain
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTileDescription(2, "Forest")
    mm:setTerrain(6, 5, 2)
    local terrain = mm:getTerrain(6, 5)
    local desc = mm:getTileDescription(terrain)
    minimap_log("sector 6,5 became " .. tostring(desc))
end

--@api: LMinimap:getTerrain
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTileDescription(7, "Mountain")
    mm:setTerrain(2, 3, 7)
    local terrain = mm:getTerrain(2, 3)
    local desc = mm:getTileDescription(terrain)
    minimap_log("scouted tile 2,3 = " .. tostring(desc))
end

--@api: LMinimap:setTerrainColor
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTerrain(4, 4, 1)
    mm:setTerrainColor(1, 0.2, 0.6, 0.1, 0.9)
    local r, g, b, a = mm:getTerrainColor(1)
    local terrain = mm:getTerrain(4, 4)
    minimap_log("terrain " .. terrain .. " palette = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LMinimap:getTerrainColor
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTerrain(8, 2, 3)
    mm:setTerrainColor(3, 0.7, 0.4, 0.2, 1.0)
    local r, g, b, a = mm:getTerrainColor(3)
    local terrain = mm:getTerrain(8, 2)
    minimap_log("desert terrain " .. terrain .. " uses " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LMinimap:setTerrainData
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(4, 4)
    local data = {}

    for i = 1, 16 do
        data[i] = ((i - 1) % 3) + 1
    end

    mm:setTerrainData(data)
    example_print_log("terrain(1,1) = " .. mm:getTerrain(1, 1))
    example_print_log("terrain(4,4) = " .. mm:getTerrain(4, 4))
end

--@api: LMinimap:setFogEnabled
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setFogColor(0.0, 0.0, 0.0, 0.75)
    mm:setFogEnabled(true)
    mm:setFogLevel(8, 8, 0)
    local enabled = mm:isFogEnabled()
    minimap_log("fog toggle for unexplored map = " .. tostring(enabled))
end

--@api: LMinimap:isFogEnabled
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setFogLevel(4, 4, 2)
    mm:setFogEnabled(false)
    local enabled = mm:isFogEnabled()
    local fog = mm:getFogLevel(4, 4)
    minimap_log("fog visible? " .. tostring(enabled) .. " while cell keeps state " .. fog)
end

--@api: LMinimap:setFogLevel
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setFogEnabled(true)
    mm:setFogColor(0.0, 0.0, 0.0, 0.6)
    mm:setFogLevel(1, 1, 2)
    local fog = mm:getFogLevel(1, 1)
    minimap_log("spawn tile fog level now " .. fog)
end

--@api: LMinimap:getFogLevel
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setFogEnabled(true)
    mm:setTerrain(2, 2, 1)
    mm:setFogLevel(2, 2, 1)
    local fog = mm:getFogLevel(2, 2)
    local terrain = mm:getTerrain(2, 2)
    minimap_log("tile 2,2 terrain " .. terrain .. " has fog " .. fog)
end

--@api: LMinimap:setFogColor
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setFogEnabled(true)
    mm:setFogColor(0.0, 0.0, 0.0, 0.7)
    local r, g, b, a = mm:getFogColor()
    mm:setFogLevel(3, 3, 2)
    minimap_log("night raid fog color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LMinimap:getFogColor
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setFogEnabled(true)
    mm:setFogColor(0.1, 0.2, 0.3, 0.6)
    local r, g, b, a = mm:getFogColor()
    mm:setFogLevel(5, 5, 1)
    minimap_log("exploration fog tint = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LMinimap:setFogData
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(4, 4)
    local fog = {}

    mm:setFogEnabled(true)

    for i = 1, 16 do
        fog[i] = (i - 1) % 3
    end

    mm:setFogData(fog)
    example_print_log("fog(1,1) = " .. mm:getFogLevel(1, 1))
    example_print_log("fog(4,4) = " .. mm:getFogLevel(4, 4))
end

--@api: LMinimap:revealRadius
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(32, 32)
    local fog = {}

    mm:setFogEnabled(true)

    for i = 1, 32 * 32 do
        fog[i] = 0
    end

    mm:setFogData(fog)
    mm:revealRadius(16, 16, 5)
    example_print_log("center fog = " .. mm:getFogLevel(16, 16))
    example_print_log("corner fog = " .. mm:getFogLevel(1, 1))
end

--@api: LMinimap:setColorMode
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setOwnerColor(1, 0.9, 0.2, 0.2, 1.0)
    mm:setTerrain(4, 4, 1)
    mm:setColorMode("political")
    local mode = mm:getColorMode()
    minimap_log("campaign view mode = " .. mode)
end

--@api: LMinimap:getColorMode
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setTerrainColor(1, 0.1, 0.5, 0.1, 1.0)
    mm:setColorMode("terrain")
    local mode = mm:getColorMode()
    local cells = mm:getCellCount()
    minimap_log("terrain palette active across " .. cells .. " cells: " .. mode)
end

--@api: LMinimap:setLayer
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(4, 4)
    mm:setLayerData(1, { 1, 1, 1, 1, 0, 0, 0, 0, 2, 2, 2, 2, 3, 3, 3, 3 })
    mm:setLayer(1)
    local layer = mm:getLayer()
    local layer_cells = mm:getLayerData(layer)
    minimap_log("switched to layer " .. layer .. " with " .. #(layer_cells or {}) .. " cells")
end

--@api: LMinimap:getLayer
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(4, 4)
    mm:setLayerData(2, { 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0, 3, 3, 3, 3 })
    mm:setLayer(2)
    local layer_data = mm:getLayerData(2)
    local layer = mm:getLayer()
    minimap_log("active terrain layer " .. layer .. " sample " .. tostring(layer_data and layer_data[1]))
end

--@api: LMinimap:getLayerCount
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(4, 4)
    local data = {}

    for i = 1, 16 do
        data[i] = i % 4
    end

    mm:setLayerData(1, data)
    example_print_log("layer count = " .. mm:getLayerCount())
end

--@api: LMinimap:setLayerData
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(4, 4)
    local data = {}

    for i = 1, 16 do
        data[i] = i
    end

    mm:setLayerData(0, data)
    local out = mm:getLayerData(0)
    example_print_log("layer 0 size = " .. #(out or {}))
    example_print_log("layer 0 first = " .. (out and out[1] or -1))
end

--@api: LMinimap:getLayerData
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(4, 4)
    local data = {}

    for i = 1, 16 do
        data[i] = i % 5
    end

    mm:setLayerData(1, data)
    local out = mm:getLayerData(1)
    example_print_log("layer 1 size = " .. #(out or {}))
    example_print_log("layer 1 last = " .. (out and out[#out] or -1))
end

--@api: LMinimap:setDisplaySize
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16, 100, 100)
    mm:setCenter(8, 8)
    mm:setDisplaySize(300, 250)
    local dw, dh = mm:getDisplaySize()
    local zoom = mm:getZoom()
    minimap_log("resized hud panel to " .. dw .. "x" .. dh .. " at zoom " .. zoom)
end

--@api: LMinimap:getDisplayWidth
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16, 100, 100)
    mm:setDisplaySize(300, 250)
    mm:setViewportRect(2, 2, 6, 6)
    local width = mm:getDisplayWidth()
    local viewport_w = select(3, mm:getViewportRect())
    minimap_log("display width " .. width .. " tracks viewport width " .. tostring(viewport_w))
end

--@api: LMinimap:getDisplayHeight
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16, 100, 100)
    mm:setDisplaySize(300, 250)
    mm:setViewportRect(2, 2, 6, 6)
    local height = mm:getDisplayHeight()
    local viewport_h = select(4, mm:getViewportRect())
    minimap_log("display height " .. height .. " tracks viewport height " .. tostring(viewport_h))
end

--@api: LMinimap:setCenter
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setZoom(1.5)
    mm:setCenter(16, 12)
    local cx, cy = mm:getCenter()
    local sx, sy = mm:gridToScreen(cx, cy, 0, 0)
    minimap_log("camera focus moved to " .. cx .. "," .. cy .. " => " .. sx .. "," .. sy)
end

--@api: LMinimap:getCenter
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setViewportRect(6, 14, 8, 8)
    mm:setCenter(10, 20)
    local cx, cy = mm:getCenter()
    local vw, vh = select(3, mm:getViewportRect()), select(4, mm:getViewportRect())
    minimap_log("tracked center " .. cx .. "," .. cy .. " with viewport " .. tostring(vw) .. "x" .. tostring(vh))
end

--@api: LMinimap:getCenterX
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setCenter(14, 9)
    mm:setZoom(2.0)
    local cx = mm:getCenterX()
    local sx = select(1, mm:gridToScreen(cx, mm:getCenterY(), 0, 0))
    minimap_log("center x " .. cx .. " projects to " .. sx)
end

--@api: LMinimap:getCenterY
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setCenter(14, 9)
    mm:setZoom(2.0)
    local cy = mm:getCenterY()
    local sy = select(2, mm:gridToScreen(mm:getCenterX(), cy, 0, 0))
    minimap_log("center y " .. cy .. " projects to " .. sy)
end

--@api: LMinimap:setZoom
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setCenter(16, 16)
    mm:setZoom(2.0)
    local zoom = mm:getZoom()
    local sx, sy = mm:gridToScreen(20, 20, 0, 0)
    minimap_log("zoom " .. zoom .. " pushes scout ping to " .. sx .. "," .. sy)
end

--@api: LMinimap:getZoom
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setCenter(8, 8)
    mm:setZoom(1.5)
    local zoom = mm:getZoom()
    local gx, gy = mm:screenToGrid(100, 100, 0, 0)
    minimap_log("zoom readback " .. zoom .. " around screen sample " .. tostring(gx) .. "," .. tostring(gy))
end

--@api: LMinimap:setAntiAlias
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setDisplaySize(128, 128)
    mm:setAntiAlias(true)
    local enabled = mm:isAntiAlias()
    local dw, dh = mm:getDisplaySize()
    minimap_log("anti alias " .. tostring(enabled) .. " on " .. dw .. "x" .. dh)
end

--@api: LMinimap:isAntiAlias
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setDisplaySize(96, 96)
    mm:setAntiAlias(false)
    local enabled = mm:isAntiAlias()
    local cells = mm:getCellCount()
    minimap_log("anti alias " .. tostring(enabled) .. " for " .. cells .. " tactical cells")
end

--@api: LMinimap:getCellCount
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(10, 20)
    mm:setDisplaySize(200, 120)
    mm:setCenter(5, 10)
    local cells = mm:getCellCount()
    local gw, gh = mm:getGridSize()
    minimap_log("grid " .. gw .. "x" .. gh .. " exposes " .. cells .. " cells")
end

--@api: LMinimap:getGridWidth
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(10, 20)
    mm:setDisplaySize(160, 160)
    mm:setCenter(5, 10)
    local width = mm:getGridWidth()
    local cells = mm:getCellCount()
    minimap_log("grid width " .. width .. " within " .. cells .. " total cells")
end

--@api: LMinimap:getGridHeight
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(10, 20)
    mm:setDisplaySize(160, 160)
    mm:setCenter(5, 10)
    local height = mm:getGridHeight()
    local cells = mm:getCellCount()
    minimap_log("grid height " .. height .. " within " .. cells .. " total cells")
end

--@api: LMinimap:setTileDescription
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setTileDescription(1, "Grass")
    mm:setTileDescription(2, "Water")
    example_print_log("tile 1 = " .. tostring(mm:getTileDescription(1)))
    example_print_log("tile 2 = " .. tostring(mm:getTileDescription(2)))
end

--@api: LMinimap:getTileDescription
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setTerrain(3, 4, 3)
    mm:setTileDescription(3, "Mountain")
    local terrain = mm:getTerrain(3, 4)
    local desc = mm:getTileDescription(terrain)
    minimap_log("hover label for ridge tile = " .. tostring(desc))
end

--@api: LMinimap:update
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(8, 8)
    mm:addPing(4, 4, 0.25)
    example_print_log("pings before = " .. mm:getPingCount())
    mm:update(0.5)
    example_print_log("pings after = " .. mm:getPingCount())
end

--@api: LMinimap:render
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(8, 8, 96, 96)
    mm:setTerrain(1, 1, 1)
    mm:render(10, 10)
    example_print_log("render queued at = 10,10")
    example_print_log("type = " .. mm:type())
end

--- Minimap Module Part 2: markers, objects, paths, overlays, viewport, coordinate mapping

--@api: LMinimap:addMarker
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(32, 32)
    local id1 = mm:addMarker(10, 10, "Base", 0, 1, 0, 1)

    mm:addMarker(20, 5, "Enemy", 1, 0, 0, 1)
    example_print_log("marker id = " .. id1)
    example_print_log("marker count = " .. mm:getMarkerCount())
end

--@api: LMinimap:hasMarker
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(32, 32)
    local id = mm:addMarker(10, 10, "Outpost")
    mm:setCenter(10, 10)
    local present = mm:hasMarker(id)
    local count = mm:getMarkerCount()
    minimap_log("outpost marker present = " .. tostring(present) .. " count " .. count)
end

--@api: LMinimap:getMarkerCount
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(32, 32)
    mm:addMarker(10, 10, "Base")
    local enemy_id = mm:addMarker(20, 5, "Enemy")
    local count = mm:getMarkerCount()
    local enemy = mm:getMarkerDescription(enemy_id)
    minimap_log("markers tracked = " .. count .. " including " .. tostring(enemy))
end

--@api: LMinimap:getMarkerDescription
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(32, 32)
    local id = mm:addMarker(10, 10, "Quest")
    mm:setMarkerAnimation(id, "pulse", 1.5)
    local desc = mm:getMarkerDescription(id)
    local count = mm:getMarkerCount()
    minimap_log("marker " .. id .. " => " .. tostring(desc) .. " of " .. count)
end

--@api: LMinimap:removeMarker
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    local id = mm:addMarker(5, 5, "Temp")

    example_print_log("before = " .. mm:getMarkerCount())
    example_print_log("removed = " .. tostring(mm:removeMarker(id)))
    example_print_log("after = " .. mm:getMarkerCount())
end

--@api: LMinimap:setMarkerAnimation
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    local id = mm:addMarker(8, 8, "Pulse")

    mm:setMarkerAnimation(id, "pulse", 2.0)
    mm:update(0.5)
    example_print_log("marker exists = " .. tostring(mm:hasMarker(id)))
    example_print_log("marker count = " .. mm:getMarkerCount())
end

--@api: LMinimap:clearMarkerAnimation
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    local id = mm:addMarker(8, 8, "Blink")

    mm:setMarkerAnimation(id, "blink", 4.0)
    mm:clearMarkerAnimation(id)
    mm:update(0.25)
    example_print_log("marker exists = " .. tostring(mm:hasMarker(id)))
end

--@api: LMinimap:addObjectType
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    local unit = mm:addObjectType("unit", 0, 0, 1, 1)
    local building = mm:addObjectType("building", 1, 1, 0, 0.8)

    example_print_log("types = " .. mm:getObjectTypeCount())
    example_print_log("unit = " .. unit .. " building = " .. building)
end

--@api: LMinimap:getObjectTypeCount
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    local scout = mm:addObjectType("unit", 0, 0, 1, 1)
    local base = mm:addObjectType("building", 1, 1, 0, 0.8)
    mm:setObject(1, 5, 5, scout, 1)
    local count = mm:getObjectTypeCount()
    minimap_log("registered types " .. scout .. "," .. base .. " => " .. count)
end

--@api: LMinimap:setObject
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    local npc = mm:addObjectType("npc", 0, 1, 0, 1)
    mm:setOwnerColor(2, 0.9, 0.8, 0.2, 1.0)
    mm:setObject(1, 4, 4, npc, 2)
    local count = mm:getObjectCount()
    local owner_r = select(1, mm:getOwnerColor(2))
    minimap_log("placed object count " .. count .. " with owner tint " .. tostring(owner_r))
end

--@api: LMinimap:getObjectCount
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    local npc = mm:addObjectType("npc", 0, 1, 0, 1)

    mm:setObject(1, 4, 4, npc, 0)
    mm:setObject(2, 8, 8, npc, 1)
    example_print_log("object count = " .. mm:getObjectCount())
end

--@api: LMinimap:removeObject
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    local npc = mm:addObjectType("npc", 0, 1, 0, 1)

    mm:setObject(1, 4, 4, npc, 0)
    mm:setObject(2, 8, 8, npc, 1)
    example_print_log("before = " .. mm:getObjectCount())
    example_print_log("removed = " .. tostring(mm:removeObject(2)))
    example_print_log("after = " .. mm:getObjectCount())
end

--@api: LMinimap:clearObjects
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    local npc = mm:addObjectType("npc", 0, 1, 0, 1)

    mm:setObject(1, 4, 4, npc, 0)
    mm:setObject(2, 8, 8, npc, 1)
    example_print_log("before = " .. mm:getObjectCount())
    mm:clearObjects()
    example_print_log("after = " .. mm:getObjectCount())
end

--@api: LMinimap:setObjectTypeVisible
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    local t = mm:addObjectType("hidden", 1, 0, 0, 1)
    mm:setObject(1, 6, 6, t, 0)
    mm:setObjectTypeVisible(t, false)
    local visible = mm:isObjectTypeVisible(t)
    local count = mm:getObjectCount()
    minimap_log("ambush icon visible = " .. tostring(visible) .. " across " .. count .. " objects")
end

--@api: LMinimap:isObjectTypeVisible
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    local t = mm:addObjectType("scout", 0, 1, 1, 1)
    mm:setObject(7, 9, 3, t, 1)
    mm:setObjectTypeVisible(t, true)
    local visible = mm:isObjectTypeVisible(t)
    local types = mm:getObjectTypeCount()
    minimap_log("scout visibility = " .. tostring(visible) .. " for " .. types .. " type(s)")
end

--@api: LMinimap:setOwnerColor
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    local scout = mm:addObjectType("scout", 0.1, 0.9, 0.2, 1.0)
    mm:setOwnerColor(1, 0, 0, 1, 1)
    mm:setObject(1, 8, 8, scout, 1)
    local r, g, b, a = mm:getOwnerColor(1)
    minimap_log("owner 1 faction tint = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LMinimap:getOwnerColor
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    local base = mm:addObjectType("base", 0.6, 0.6, 0.6, 1.0)
    mm:setOwnerColor(2, 1, 0, 0, 1)
    mm:setObject(2, 12, 4, base, 2)
    local r, g, b, a = mm:getOwnerColor(2)
    minimap_log("enemy owner tint = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LMinimap:showPath
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    local pts = {
        { 2, 2 },
        { 4, 4 },
        { 6, 2 },
        { 8, 4 },
    }
    local pid = mm:showPath(pts, { 255, 0, 0, 255 })

    example_print_log("path id = " .. pid)
    example_print_log("path count = " .. mm:getPathCount())
end

--@api: LMinimap:getPathCount
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    local pts = {
        { 1, 1 },
        { 3, 3 },
        { 5, 2 },
    }

    mm:showPath(pts, { 0, 255, 0, 255 })
    example_print_log("path count = " .. mm:getPathCount())
end

--@api: LMinimap:clearPath
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    local pts = {
        { 2, 2 },
        { 4, 4 },
        { 6, 2 },
    }
    local pid = mm:showPath(pts, { 255, 255, 255, 255 })

    example_print_log("before = " .. mm:getPathCount())
    mm:clearPath(pid)
    example_print_log("after = " .. mm:getPathCount())
end

--@api: LMinimap:addPing
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    mm:addPing(8, 8, 2.0, 1, 1, 0, 1)
    mm:addPing(4, 4, 1.0)
    example_print_log("pings before = " .. mm:getPingCount())
    mm:update(2.5)
    example_print_log("pings after = " .. mm:getPingCount())
end

--@api: LMinimap:getPingCount
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    mm:addPing(8, 8, 2.0)
    mm:update(0.25)
    mm:addPing(4, 4, 1.0)
    local count = mm:getPingCount()
    minimap_log("active alert pings = " .. count)
end

--@api: LMinimap:drawLine
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setCenter(8, 8)
    mm:drawLine(0, 0, 15, 15, { 255, 255, 255, 255 })
    local shapes = mm:getOverlayShapeCount()
    local sx, sy = mm:gridToScreen(15, 15, 0, 0)
    minimap_log("retreat route overlay count " .. shapes .. " ends near " .. sx .. "," .. sy)
end

--@api: LMinimap:drawRect
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setCenter(8, 8)
    mm:drawRect(2, 2, 4, 4, { 0, 255, 0, 200 })
    local shapes = mm:getOverlayShapeCount()
    local hover = mm:getHoverInfo(20, 20, 0, 0)
    minimap_log("safe zone overlay count " .. shapes .. " hover " .. tostring(hover))
end

--@api: LMinimap:clearOverlay
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    mm:drawLine(0, 0, 15, 15, { 255, 255, 255, 255 })
    mm:drawRect(2, 2, 4, 4, { 0, 255, 0, 200 })
    example_print_log("before = " .. mm:getOverlayShapeCount())
    mm:clearOverlay()
    example_print_log("after = " .. mm:getOverlayShapeCount())
end

--@api: LMinimap:getOverlayShapeCount
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    mm:drawLine(0, 0, 15, 15, { 255, 255, 255, 255 })
    mm:drawRect(2, 2, 4, 4, { 0, 255, 0, 200 })
    local shapes = mm:getOverlayShapeCount()
    local dw, dh = mm:getDisplaySize()
    minimap_log("overlay shapes = " .. shapes .. " on " .. dw .. "x" .. dh)
end

--@api: LMinimap:setViewportRect
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setCenter(16, 16)
    mm:setViewportRect(4, 4, 12, 12)
    local x, y, w, h = mm:getViewportRect()
    minimap_log("camera frame = " .. tostring(x) .. "," .. tostring(y) .. " " .. tostring(w) .. "x" .. tostring(h))
end

--@api: LMinimap:getViewportRect
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setViewportVisible(true)
    mm:setViewportRect(6, 8, 10, 14)
    local x, y, w, h = mm:getViewportRect()
    local visible = mm:isViewportVisible()
    minimap_log("viewport " .. tostring(visible) .. " => " .. tostring(x) .. "," .. tostring(y) .. " " .. tostring(w) .. "x" .. tostring(h))
end

--@api: LMinimap:clearViewportRect
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setViewportRect(4, 4, 12, 12)
    mm:clearViewportRect()
    local x = select(1, mm:getViewportRect())
    example_print_log("viewport cleared = " .. tostring(x == nil))
end

--@api: LMinimap:setViewportColor
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setViewportRect(2, 2, 6, 6)
    mm:setViewportColor(1, 1, 0, 0.5)
    local r, g, b, a = mm:getViewportColor()
    mm:setViewportVisible(true)
    minimap_log("viewport tint = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LMinimap:getViewportColor
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setViewportRect(3, 3, 5, 5)
    mm:setViewportColor(0.2, 0.4, 1.0, 0.75)
    local r, g, b, a = mm:getViewportColor()
    local rect_w = select(3, mm:getViewportRect())
    minimap_log("viewport width " .. tostring(rect_w) .. " uses tint " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LMinimap:setViewportVisible
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setViewportRect(1, 1, 6, 6)
    mm:setViewportVisible(true)
    local visible = mm:isViewportVisible()
    local rect_w = select(3, mm:getViewportRect())
    minimap_log("viewport visibility = " .. tostring(visible) .. " width " .. tostring(rect_w))
end

--@api: LMinimap:isViewportVisible
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setViewportRect(1, 1, 6, 6)
    mm:setViewportVisible(false)
    local visible = mm:isViewportVisible()
    local rect_h = select(4, mm:getViewportRect())
    minimap_log("viewport visibility = " .. tostring(visible) .. " height " .. tostring(rect_h))
end

--@api: LMinimap:setClickable
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setDisplaySize(160, 160)
    mm:setClickable(false)
    local clickable = mm:isClickable()
    local dw = mm:getDisplayWidth()
    minimap_log("map clicking = " .. tostring(clickable) .. " on width " .. dw)
end

--@api: LMinimap:isClickable
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setDisplaySize(160, 160)
    mm:setClickable(true)
    local clickable = mm:isClickable()
    local dh = mm:getDisplayHeight()
    minimap_log("map clicking = " .. tostring(clickable) .. " on height " .. dh)
end

--@api: LMinimap:gridToScreen
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16, 160, 160)
    mm:setCenter(8, 8)
    mm:setZoom(2.0)
    local sx, sy = mm:gridToScreen(8, 8, 0, 0)
    local gx, gy = mm:screenToGrid(sx, sy, 0, 0)
    minimap_log("grid 8,8 => screen " .. sx .. "," .. sy .. " => " .. tostring(gx) .. "," .. tostring(gy))
end

--@api: LMinimap:screenToGrid
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16, 160, 160)
    mm:setCenter(8, 8)
    local sx, sy = mm:gridToScreen(8, 8, 0, 0)
    local gx, gy = mm:screenToGrid(sx, sy, 0, 0)
    local hover = mm:getHoverInfo(sx, sy, 0, 0)
    minimap_log("screen " .. sx .. "," .. sy .. " resolves to " .. gx .. "," .. gy .. " hover " .. tostring(hover))
end

--@api: LMinimap:getHoverInfo
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(8, 8, 80, 80)
    mm:setTileDescription(1, "Plains")
    mm:setTerrain(1, 1, 1)
    local sx, sy = mm:gridToScreen(1, 1, 0, 0)
    local hover = mm:getHoverInfo(sx, sy, 0, 0)
    minimap_log("hover at " .. sx .. "," .. sy .. " => " .. tostring(hover))
end

--@api: LMinimap:drawToImage
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setTerrainColor(0, 0.5, 0.5, 0.5, 1.0)
    local img = mm:drawToImage(2)

    example_print_log("image type = " .. img:type())
    example_print_log("image size = " .. img:getWidth() .. "x" .. img:getHeight())
end

--- Minimap Module Part 3: textures, display size, grid size, camera tracking, type

--@api: LMinimap:getDisplaySize
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(32, 32, 200, 200)
    mm:setDisplaySize(240, 180)
    mm:setViewportRect(4, 4, 10, 10)
    local dw, dh = mm:getDisplaySize()
    local visible = mm:isViewportVisible()
    minimap_log("display size = " .. dw .. "x" .. dh .. " viewport visible " .. tostring(visible))
end

--@api: LMinimap:getGridSize
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(32, 32, 200, 200)
    mm:setCenter(16, 16)
    mm:setZoom(1.1)
    local gw, gh = mm:getGridSize()
    local cells = mm:getCellCount()
    minimap_log("grid size = " .. gw .. "x" .. gh .. " cells " .. cells)
end

--@api: LMinimap:setMarkerTexture
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    local id = mm:addMarker(16, 16, "Hero")
    local img = lurek.render.newImage("content/examples/assets/images/sample_icon.png")

    mm:setMarkerTexture(id, img, 24, 24)
    example_print_log("marker count = " .. mm:getMarkerCount())
end

--@api: LMinimap:clearMarkerTexture
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    local id = mm:addMarker(16, 16, "Hero")
    local img = lurek.render.newImage("content/examples/assets/images/sample_icon.png")

    mm:setMarkerTexture(id, img, 24, 24)
    mm:clearMarkerTexture(id)
    example_print_log("marker exists = " .. tostring(mm:hasMarker(id)))
end

--@api: LMinimap:setObjectTypeTexture
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    local type_idx = mm:addObjectType("unit", 0, 1, 0, 1)
    local img = lurek.render.newImage("content/examples/assets/images/sample_icon.png")

    mm:setObjectTypeTexture(type_idx, img, 16, 16)
    example_print_log("object types = " .. mm:getObjectTypeCount())
end

--@api: LMinimap:clearObjectTypeTexture
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    local type_idx = mm:addObjectType("unit", 0, 1, 0, 1)
    local img = lurek.render.newImage("content/examples/assets/images/sample_icon.png")

    mm:setObjectTypeTexture(type_idx, img, 16, 16)
    mm:clearObjectTypeTexture(type_idx)
    example_print_log("object types = " .. mm:getObjectTypeCount())
end

--@api: LMinimap:trackCamera
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    local cam = lurek.camera.newCamera(1280, 720)

    cam:setPosition(320, 240)
    mm:trackCamera(cam)

    local cx, cy = mm:getCenter()
    local _, _, vw, vh = mm:getViewportRect()
    example_print_log("center = " .. cx .. "," .. cy)
    example_print_log("viewport size = " .. tostring(vw) .. "x" .. tostring(vh))
end

--@api: LMinimap:type
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTerrain(8, 8, 1)
    mm:setCenter(8, 8)
    local type_name = mm:type()
    local cells = mm:getCellCount()
    minimap_log("handle type " .. type_name .. " owns " .. cells .. " cells")
end

--@api: LMinimap:typeOf
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTerrain(4, 4, 2)
    local is_minimap = mm:typeOf("LMinimap")
    local is_object = mm:typeOf("LObject")
    local type_name = mm:type()
    minimap_log(type_name .. " -> LMinimap=" .. tostring(is_minimap) .. " LObject=" .. tostring(is_object))
end

--@api: LMinimap:setLayerVisible
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end

    local mm = lurek.minimap.newMinimap(4, 4)
    local heat = {}
    for i = 1, 16 do heat[i] = i % 4 end
    mm:setLayerData(1, heat)
    mm:setLayerColor(1, 3, 1.0, 0.2, 0.1, 0.75)
    mm:setLayerVisible(1, true)
    minimap_log("heat layer visible = " .. tostring(mm:isLayerVisible(1)))
end

--@api: LMinimap:isLayerVisible
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end

    local mm = lurek.minimap.newMinimap(4, 4)
    local danger = {}
    for i = 1, 16 do danger[i] = i % 2 end
    mm:setLayerData(1, danger)
    local before = mm:isLayerVisible(1)
    mm:setLayerVisible(1, true)
    local after = mm:isLayerVisible(1)
    minimap_log("danger layer visible " .. tostring(before) .. " -> " .. tostring(after))
end

--@api: LMinimap:setLayerAlpha
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end

    local mm = lurek.minimap.newMinimap(4, 4)
    local light = {}
    for i = 1, 16 do light[i] = math.min(9, i) end
    mm:setLayerData(1, light)
    mm:setLayerAlpha(1, 0.35)
    mm:setLayerVisible(1, true)
    minimap_log("light layer alpha = " .. tostring(mm:getLayerAlpha(1)))
end

--@api: LMinimap:getLayerAlpha
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end

    local mm = lurek.minimap.newMinimap(4, 4)
    local data = {}
    for i = 1, 16 do data[i] = 1 end
    mm:setLayerData(1, data)
    mm:setLayerAlpha(1, 0.8)
    local alpha = mm:getLayerAlpha(1)
    minimap_log("stored overlay alpha = " .. tostring(alpha))
end

--@api: LMinimap:setLayerColor
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end

    local mm = lurek.minimap.newMinimap(4, 4)
    local control = {}
    for i = 1, 16 do control[i] = i % 3 end
    mm:setLayerData(1, control)
    mm:setLayerColor(1, 2, 0.1, 0.6, 1.0, 0.9)
    mm:setLayerVisible(1, true)
    local r = select(1, mm:getLayerColor(1, 2))
    minimap_log("control layer color red = " .. tostring(r))
end

--@api: LMinimap:getLayerColor
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end

    local mm = lurek.minimap.newMinimap(4, 4)
    local influence = {}
    for i = 1, 16 do influence[i] = i % 2 end
    mm:setLayerData(1, influence)
    mm:setLayerColor(1, 1, 0.9, 0.8, 0.2, 1.0)
    local r, g, b, a = mm:getLayerColor(1, 1)
    minimap_log("influence color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LMinimap:setLayerBlendMode
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end

    local mm = lurek.minimap.newMinimap(4, 4)
    local light = {}
    for i = 1, 16 do light[i] = i % 10 end
    mm:setLayerData(1, light)
    mm:setLayerBlendMode(1, "add")
    mm:setLayerVisible(1, true)
    minimap_log("light layer blend = " .. tostring(mm:getLayerBlendMode(1)))
end

--@api: LMinimap:getLayerBlendMode
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end

    local mm = lurek.minimap.newMinimap(4, 4)
    local fog_hint = {}
    for i = 1, 16 do fog_hint[i] = i % 2 end
    mm:setLayerData(1, fog_hint)
    local before = mm:getLayerBlendMode(1)
    mm:setLayerBlendMode(1, "multiply")
    local after = mm:getLayerBlendMode(1)
    minimap_log("fog hint blend " .. tostring(before) .. " -> " .. tostring(after))
end

--@api: LMinimap:syncProvinceRegistry
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end

    local reg = lurek.province.newFromPng("minimap_sync_example", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    reg:setTerrainType(province_id, 6)
    reg:setVisibilityState(province_id, 255)
    reg:setPoliticalColor(province_id, 0.2, 0.5, 0.9, 1.0)

    local mm = lurek.minimap.newMinimap(reg:getWidth(), reg:getHeight())
    mm:syncProvinceRegistry(reg)
    minimap_log("province minimap terrain color blue = " .. tostring(select(3, mm:getTerrainColor(6))))
end

--@api: LMinimap:setShader
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end

    local mm = lurek.minimap.newMinimap(16, 16, 128, 128)
    local shader = lurek.render.newShader([[
@fragment
fn fs(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) pixel: vec2<f32>,
    @location(3) resolution: vec2<f32>,
    @location(4) texel: vec2<f32>
) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb * vec3<f32>(1.1, 0.95, 0.8) + uv.xyx * 0.0 + pixel.xyx * 0.0 + resolution.xyx * texel.x * 0.0, color.a);
}
]], { target = "mapviz" })
    mm:setShader(shader)
    mm:render(12, 12)
    minimap_log("minimap mapviz shader target=" .. mm:getShader():getTarget())
end

--@api: LMinimap:getShader
do
    local function minimap_log(message)
        lurek.log.info("[minimap.example] " .. tostring(message))
    end

    local mm = lurek.minimap.newMinimap(16, 16, 128, 128)
    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + uv.xyx * 0.0, color.a);
}
]], { target = "mapviz" })
    mm:setShader(shader)
    local active = mm:getShader()
    minimap_log("active minimap mapviz shader=" .. tostring(active and active:getTarget() or "nil"))
end
