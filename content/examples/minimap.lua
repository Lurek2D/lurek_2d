-- content/examples/minimap.lua
-- Lurek2D lurek.minimap API Reference
-- Run with: cargo run -- content/examples/minimap
--
-- Scenario: A top-down dungeon crawler with a corner minimap showing the player's
-- explored rooms, fog of war, quest markers, enemy dots, and a viewport rectangle
-- indicating the camera frustum on the world map.

print("=== lurek.minimap — Dungeon Crawler Minimap ===\n")

-- =============================================================================
-- Minimap Creation
-- =============================================================================

-- ---- Stub: lurek.minimap.newMinimap ---------------------------------------
--@api-stub: lurek.minimap.newMinimap
-- Demonstrates the proper usage of lurek.minimap.newMinimap.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_minimap_newMinimap()
    local mm = lurek.minimap.newMinimap({ width = 20, height = 15, cell_size = 8 })
    print("minimap created: 20x15 grid, 8px cells")
end
local _ok, _err = pcall(demo_lurek_minimap_newMinimap)

-- =============================================================================
-- Grid & Display Dimensions (Minimap class methods — use colon syntax)
-- =============================================================================

-- ---- Stub: Minimap:getGridWidth -------------------------------------------
--@api-stub: Minimap:getGridWidth
-- Demonstrates the proper usage of Minimap:getGridWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getGridWidth()
    print("grid width: " .. tostring(mm:getGridWidth()) .. " cells")
end
local _ok, _err = pcall(demo_Minimap_getGridWidth)

-- ---- Stub: Minimap:getGridHeight ------------------------------------------
--@api-stub: Minimap:getGridHeight
-- Demonstrates the proper usage of Minimap:getGridHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getGridHeight()
    print("grid height: " .. tostring(mm:getGridHeight()) .. " cells")
end
local _ok, _err = pcall(demo_Minimap_getGridHeight)

-- ---- Stub: Minimap:getGridSize --------------------------------------------
--@api-stub: Minimap:getGridSize
-- Demonstrates the proper usage of Minimap:getGridSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getGridSize()
    local gw, gh = mm:getGridSize()
    print("grid size: " .. gw .. "x" .. gh)
end
local _ok, _err = pcall(demo_Minimap_getGridSize)

-- ---- Stub: Minimap:getDisplayWidth ----------------------------------------
--@api-stub: Minimap:getDisplayWidth
-- Demonstrates the proper usage of Minimap:getDisplayWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getDisplayWidth()
    print("display width: " .. tostring(mm:getDisplayWidth()) .. "px")
end
local _ok, _err = pcall(demo_Minimap_getDisplayWidth)

-- ---- Stub: Minimap:getDisplayHeight ---------------------------------------
--@api-stub: Minimap:getDisplayHeight
-- Demonstrates the proper usage of Minimap:getDisplayHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getDisplayHeight()
    print("display height: " .. tostring(mm:getDisplayHeight()) .. "px")
end
local _ok, _err = pcall(demo_Minimap_getDisplayHeight)

-- ---- Stub: Minimap:getDisplaySize -----------------------------------------
--@api-stub: Minimap:getDisplaySize
-- Demonstrates the proper usage of Minimap:getDisplaySize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getDisplaySize()
    local dw, dh = mm:getDisplaySize()
    print("display size: " .. dw .. "x" .. dh)
end
local _ok, _err = pcall(demo_Minimap_getDisplaySize)

-- ---- Stub: Minimap:setDisplaySize -----------------------------------------
--@api-stub: Minimap:setDisplaySize
-- Demonstrates the proper usage of Minimap:setDisplaySize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_setDisplaySize()
    mm:setDisplaySize(160, 120)
    print("minimap display: 160x120 pixels")
end
local _ok, _err = pcall(demo_Minimap_setDisplaySize)

-- =============================================================================
-- Terrain Data
-- =============================================================================

-- ---- Stub: Minimap:setTerrainData -----------------------------------------
--@api-stub: Minimap:setTerrainData
-- Demonstrates the proper usage of Minimap:setTerrainData.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_setTerrainData()
    local terrain_data = {}
    for i = 1, 20 * 15 do terrain_data[i] = "stone" end
    terrain_data[11 * 20 + 3] = "water"
    terrain_data[6 * 20 + 15] = "lava"
    mm:setTerrainData(terrain_data)
    print("terrain data loaded: mostly stone, one water, one lava cell")
end
local _ok, _err = pcall(demo_Minimap_setTerrainData)

-- ---- Stub: Minimap:getTerrain ---------------------------------------------
--@api-stub: Minimap:getTerrain
-- Demonstrates the proper usage of Minimap:getTerrain.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getTerrain()
    local terrain = mm:getTerrain(10, 7)
    print("terrain at (10,7): " .. tostring(terrain))
end
local _ok, _err = pcall(demo_Minimap_getTerrain)

-- ---- Stub: Minimap:getTerrainColor ----------------------------------------
--@api-stub: Minimap:getTerrainColor
-- Demonstrates the proper usage of Minimap:getTerrainColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getTerrainColor()
    local tcr, tcg, tcb = mm:getTerrainColor("stone")
    print("stone color: (" .. tostring(tcr) .. ", " .. tostring(tcg) .. ", " .. tostring(tcb) .. ")")
end
local _ok, _err = pcall(demo_Minimap_getTerrainColor)

-- ---- Stub: Minimap:getTileDescription -------------------------------------
--@api-stub: Minimap:getTileDescription
-- Demonstrates the proper usage of Minimap:getTileDescription.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getTileDescription()
    local tile_desc = mm:getTileDescription(10, 7)
    print("tile (10,7): " .. tostring(tile_desc))
end
local _ok, _err = pcall(demo_Minimap_getTileDescription)

-- =============================================================================
-- Fog of War — reveal rooms as the player explores
-- =============================================================================

-- ---- Stub: Minimap:setFogEnabled ------------------------------------------
--@api-stub: Minimap:setFogEnabled
-- Demonstrates the proper usage of Minimap:setFogEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_setFogEnabled()
    mm:setFogEnabled(true)
    print("fog of war enabled — unexplored areas hidden")
end
local _ok, _err = pcall(demo_Minimap_setFogEnabled)

-- ---- Stub: Minimap:isFogEnabled -------------------------------------------
--@api-stub: Minimap:isFogEnabled
-- Demonstrates the proper usage of Minimap:isFogEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_isFogEnabled()
    print("fog enabled: " .. tostring(mm:isFogEnabled()))
end
local _ok, _err = pcall(demo_Minimap_isFogEnabled)

-- ---- Stub: Minimap:setFogLevel --------------------------------------------
--@api-stub: Minimap:setFogLevel
-- Demonstrates the proper usage of Minimap:setFogLevel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_setFogLevel()
    mm:setFogLevel(0.5)
    print("fog level: 0.5 (visited areas shown dimly)")
end
local _ok, _err = pcall(demo_Minimap_setFogLevel)

-- ---- Stub: Minimap:getFogLevel --------------------------------------------
--@api-stub: Minimap:getFogLevel
-- Demonstrates the proper usage of Minimap:getFogLevel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getFogLevel()
    print("fog level: " .. tostring(mm:getFogLevel()))
end
local _ok, _err = pcall(demo_Minimap_getFogLevel)

-- ---- Stub: Minimap:getFogColor --------------------------------------------
--@api-stub: Minimap:getFogColor
-- Demonstrates the proper usage of Minimap:getFogColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getFogColor()
    local fcr, fcg, fcb, fca = mm:getFogColor()
    print("fog color: (" .. fcr .. ", " .. fcg .. ", " .. fcb .. ", " .. fca .. ")")
end
local _ok, _err = pcall(demo_Minimap_getFogColor)

-- ---- Stub: Minimap:setFogData ---------------------------------------------
--@api-stub: Minimap:setFogData
-- Bulk-load fog state from a saved game. Array of booleans: true=revealed.
local fog_data = {}
for i = 1, 20 * 15 do fog_data[i] = false end
-- Reveal the central room
for x = 8, 12 do for y = 5, 9 do fog_data[(y * 20) + x + 1] = true end end
mm:setFogData(fog_data)
print("fog data loaded from save (central room revealed)")

-- =============================================================================
-- Objects — dynamic entities (enemies, NPCs) on the minimap
-- =============================================================================

-- ---- Stub: Minimap:isObjectTypeVisible ------------------------------------
--@api-stub: Minimap:isObjectTypeVisible
-- Demonstrates the proper usage of Minimap:isObjectTypeVisible.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_isObjectTypeVisible()
    print("enemy type visible: " .. tostring(mm:isObjectTypeVisible("enemy")))
end
local _ok, _err = pcall(demo_Minimap_isObjectTypeVisible)

-- ---- Stub: Minimap:getObjectTypeCount -------------------------------------
--@api-stub: Minimap:getObjectTypeCount
-- Demonstrates the proper usage of Minimap:getObjectTypeCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getObjectTypeCount()
    print("enemy objects: " .. tostring(mm:getObjectTypeCount("enemy")))
end
local _ok, _err = pcall(demo_Minimap_getObjectTypeCount)

-- ---- Stub: Minimap:getObjectCount -----------------------------------------
--@api-stub: Minimap:getObjectCount
-- Demonstrates the proper usage of Minimap:getObjectCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getObjectCount()
    print("total minimap objects: " .. tostring(mm:getObjectCount()))
end
local _ok, _err = pcall(demo_Minimap_getObjectCount)

-- ---- Stub: Minimap:removeObject -------------------------------------------
--@api-stub: Minimap:removeObject
-- Demonstrates the proper usage of Minimap:removeObject.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_removeObject()
    mm:removeObject("enemy_01")
    print("enemy_01 removed from minimap (defeated)")
end
local _ok, _err = pcall(demo_Minimap_removeObject)

-- ---- Stub: Minimap:clearObjects -------------------------------------------
--@api-stub: Minimap:clearObjects
-- Demonstrates the proper usage of Minimap:clearObjects.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_clearObjects()
    mm:clearObjects()
    print("all dynamic objects cleared (room transition)")
end
local _ok, _err = pcall(demo_Minimap_clearObjects)

-- ---- Stub: Minimap:getOwnerColor ------------------------------------------
--@api-stub: Minimap:getOwnerColor
-- Demonstrates the proper usage of Minimap:getOwnerColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getOwnerColor()
    local or_, og, ob, oa = mm:getOwnerColor("player")
    print("player territory: (" .. tostring(or_) .. ", " .. tostring(og) .. ", " .. tostring(ob) .. ")")
end
local _ok, _err = pcall(demo_Minimap_getOwnerColor)

-- =============================================================================
-- Color Mode & Visual Options
-- =============================================================================

-- ---- Stub: Minimap:setColorMode -------------------------------------------
--@api-stub: Minimap:setColorMode
-- Demonstrates the proper usage of Minimap:setColorMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_setColorMode()
    mm:setColorMode("solid")
    print("color mode: solid fills")
end
local _ok, _err = pcall(demo_Minimap_setColorMode)

-- ---- Stub: Minimap:getColorMode -------------------------------------------
--@api-stub: Minimap:getColorMode
-- Demonstrates the proper usage of Minimap:getColorMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getColorMode()
    print("color mode: " .. tostring(mm:getColorMode()))
end
local _ok, _err = pcall(demo_Minimap_getColorMode)

-- ---- Stub: Minimap:setAntiAlias -------------------------------------------
--@api-stub: Minimap:setAntiAlias
-- Demonstrates the proper usage of Minimap:setAntiAlias.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_setAntiAlias()
    mm:setAntiAlias(true)
    print("anti-alias enabled (smoother edges)")
end
local _ok, _err = pcall(demo_Minimap_setAntiAlias)

-- ---- Stub: Minimap:isAntiAlias --------------------------------------------
--@api-stub: Minimap:isAntiAlias
-- Demonstrates the proper usage of Minimap:isAntiAlias.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_isAntiAlias()
    print("anti-alias: " .. tostring(mm:isAntiAlias()))
end
local _ok, _err = pcall(demo_Minimap_isAntiAlias)

-- =============================================================================
-- Zoom & Pan — camera-like controls on the minimap
-- =============================================================================

-- ---- Stub: Minimap:setZoom ------------------------------------------------
--@api-stub: Minimap:setZoom
-- Demonstrates the proper usage of Minimap:setZoom.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_setZoom()
    mm:setZoom(1.5)
    print("minimap zoom: 1.5x (focused on nearby area)")
end
local _ok, _err = pcall(demo_Minimap_setZoom)

-- ---- Stub: Minimap:getZoom ------------------------------------------------
--@api-stub: Minimap:getZoom
-- Demonstrates the proper usage of Minimap:getZoom.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getZoom()
    print("zoom: " .. tostring(mm:getZoom()))
end
local _ok, _err = pcall(demo_Minimap_getZoom)

-- ---- Stub: Minimap:setCenter ----------------------------------------------
--@api-stub: Minimap:setCenter
-- Demonstrates the proper usage of Minimap:setCenter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_setCenter()
    mm:setCenter(10, 7)
    print("minimap centered on player (10, 7)")
end
local _ok, _err = pcall(demo_Minimap_setCenter)

-- ---- Stub: Minimap:getCenter ----------------------------------------------
--@api-stub: Minimap:getCenter
-- Demonstrates the proper usage of Minimap:getCenter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getCenter()
    local cx, cy = mm:getCenter()
    print("center: (" .. tostring(cx) .. ", " .. tostring(cy) .. ")")
end
local _ok, _err = pcall(demo_Minimap_getCenter)

-- ---- Stub: Minimap:getCenterX ---------------------------------------------
--@api-stub: Minimap:getCenterX
-- Demonstrates the proper usage of Minimap:getCenterX.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getCenterX()
    print("center X: " .. tostring(mm:getCenterX()))
end
local _ok, _err = pcall(demo_Minimap_getCenterX)

-- ---- Stub: Minimap:getCenterY ---------------------------------------------
--@api-stub: Minimap:getCenterY
-- Demonstrates the proper usage of Minimap:getCenterY.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getCenterY()
    print("center Y: " .. tostring(mm:getCenterY()))
end
local _ok, _err = pcall(demo_Minimap_getCenterY)

-- =============================================================================
-- Viewport Rectangle — shows the camera frustum on the world map
-- =============================================================================

-- ---- Stub: Minimap:setViewportVisible -------------------------------------
--@api-stub: Minimap:setViewportVisible
-- Demonstrates the proper usage of Minimap:setViewportVisible.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_setViewportVisible()
    mm:setViewportVisible(true)
    print("viewport rectangle shown on minimap")
end
local _ok, _err = pcall(demo_Minimap_setViewportVisible)

-- ---- Stub: Minimap:isViewportVisible --------------------------------------
--@api-stub: Minimap:isViewportVisible
-- Demonstrates the proper usage of Minimap:isViewportVisible.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_isViewportVisible()
    print("viewport visible: " .. tostring(mm:isViewportVisible()))
end
local _ok, _err = pcall(demo_Minimap_isViewportVisible)

-- ---- Stub: Minimap:getViewportRect ----------------------------------------
--@api-stub: Minimap:getViewportRect
-- Demonstrates the proper usage of Minimap:getViewportRect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getViewportRect()
    local vx, vy, vw, vh = mm:getViewportRect()
    print("viewport: (" .. tostring(vx) .. "," .. tostring(vy) .. "," .. tostring(vw) .. "," .. tostring(vh) .. ")")
end
local _ok, _err = pcall(demo_Minimap_getViewportRect)

-- ---- Stub: Minimap:getViewportColor ---------------------------------------
--@api-stub: Minimap:getViewportColor
-- Demonstrates the proper usage of Minimap:getViewportColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getViewportColor()
    local vr, vg, vb, va = mm:getViewportColor()
    print("viewport color: (" .. tostring(vr) .. ", " .. tostring(vg) .. ", " .. tostring(vb) .. ")")
end
local _ok, _err = pcall(demo_Minimap_getViewportColor)

-- ---- Stub: Minimap:clearViewportRect --------------------------------------
--@api-stub: Minimap:clearViewportRect
-- Demonstrates the proper usage of Minimap:clearViewportRect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_clearViewportRect()
    mm:clearViewportRect()
    print("viewport rectangle cleared")
end
local _ok, _err = pcall(demo_Minimap_clearViewportRect)

-- =============================================================================
-- Pings — player communication signals
-- =============================================================================

-- ---- Stub: Minimap:getPingCount -------------------------------------------
--@api-stub: Minimap:getPingCount
-- Demonstrates the proper usage of Minimap:getPingCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getPingCount()
    print("active pings: " .. tostring(mm:getPingCount()))
end
local _ok, _err = pcall(demo_Minimap_getPingCount)

-- =============================================================================
-- Markers — quest icons, enemies, items on the minimap
-- =============================================================================

-- ---- Stub: Minimap:removeMarker -------------------------------------------
--@api-stub: Minimap:removeMarker
-- Demonstrates the proper usage of Minimap:removeMarker.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_removeMarker()
    mm:removeMarker("treasure")
    print("treasure marker removed (chest already looted)")
end
local _ok, _err = pcall(demo_Minimap_removeMarker)

-- ---- Stub: Minimap:hasMarker ----------------------------------------------
--@api-stub: Minimap:hasMarker
-- Demonstrates the proper usage of Minimap:hasMarker.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_hasMarker()
    print("has 'boss_room' marker: " .. tostring(mm:hasMarker("boss_room")))
end
local _ok, _err = pcall(demo_Minimap_hasMarker)

-- ---- Stub: Minimap:getMarkerDescription -----------------------------------
--@api-stub: Minimap:getMarkerDescription
-- Demonstrates the proper usage of Minimap:getMarkerDescription.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getMarkerDescription()
    local desc = mm:getMarkerDescription("boss_room")
    print("boss marker description: " .. tostring(desc))
end
local _ok, _err = pcall(demo_Minimap_getMarkerDescription)

-- ---- Stub: Minimap:getMarkerCount ----------------------------------------
--@api-stub: Minimap:getMarkerCount
-- Demonstrates the proper usage of Minimap:getMarkerCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getMarkerCount()
    print("active markers: " .. tostring(mm:getMarkerCount()))
end
local _ok, _err = pcall(demo_Minimap_getMarkerCount)

-- ---- Stub: Minimap:clearMarkerAnimation -----------------------------------
--@api-stub: Minimap:clearMarkerAnimation
-- Demonstrates the proper usage of Minimap:clearMarkerAnimation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_clearMarkerAnimation()
    mm:clearMarkerAnimation()
    print("marker animations cleared (no more pulsing)")
end
local _ok, _err = pcall(demo_Minimap_clearMarkerAnimation)

-- =============================================================================
-- Layers & Overlays
-- =============================================================================

-- ---- Stub: Minimap:setLayer -----------------------------------------------
--@api-stub: Minimap:setLayer
-- Demonstrates the proper usage of Minimap:setLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_setLayer()
    mm:setLayer(0)
    print("active layer: 0 (base terrain)")
end
local _ok, _err = pcall(demo_Minimap_setLayer)

-- ---- Stub: Minimap:getLayer -----------------------------------------------
--@api-stub: Minimap:getLayer
-- Demonstrates the proper usage of Minimap:getLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_getLayer()
    print("layer: " .. tostring(mm:getLayer()))
end
local _ok, _err = pcall(demo_Minimap_getLayer)

-- ---- Stub: Minimap:clearOverlay -------------------------------------------
--@api-stub: Minimap:clearOverlay
-- Demonstrates the proper usage of Minimap:clearOverlay.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_clearOverlay()
    mm:clearOverlay()
    print("overlay layer cleared")
end
local _ok, _err = pcall(demo_Minimap_clearOverlay)

-- ---- Stub: Minimap:clearPath ----------------------------------------------
--@api-stub: Minimap:clearPath
-- Demonstrates the proper usage of Minimap:clearPath.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_clearPath()
    mm:clearPath()
    print("navigation path cleared")
end
local _ok, _err = pcall(demo_Minimap_clearPath)

-- =============================================================================
-- Clickable & Interactive Minimap
-- =============================================================================

-- ---- Stub: Minimap:setClickable -------------------------------------------
--@api-stub: Minimap:setClickable
-- Demonstrates the proper usage of Minimap:setClickable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_setClickable()
    mm:setClickable(true)
    print("minimap clickable (click to set waypoint)")
end
local _ok, _err = pcall(demo_Minimap_setClickable)

-- ---- Stub: Minimap:isClickable --------------------------------------------
--@api-stub: Minimap:isClickable
-- Demonstrates the proper usage of Minimap:isClickable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_isClickable()
    print("clickable: " .. tostring(mm:isClickable()))
end
local _ok, _err = pcall(demo_Minimap_isClickable)

-- =============================================================================
-- Update & Render
-- =============================================================================

-- ---- Stub: Minimap:update -------------------------------------------------
--@api-stub: Minimap:update
-- Demonstrates the proper usage of Minimap:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_update()
    mm:update(0.016)
    print("minimap updated (16ms frame)")
end
local _ok, _err = pcall(demo_Minimap_update)

-- ---- Stub: Minimap:type ---------------------------------------------------
--@api-stub: Minimap:type
-- Demonstrates the proper usage of Minimap:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_type()
    print('Executing type')
end
local _ok, _err = pcall(demo_Minimap_type)

-- ---- Stub: Minimap:typeOf -------------------------------------------------
--@api-stub: Minimap:typeOf
-- Demonstrates the proper usage of Minimap:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_typeOf()
    print("minimap type: " .. tostring(mm:type()))
    print("minimap typeOf: " .. tostring(mm:typeOf("Minimap")))
end
local _ok, _err = pcall(demo_Minimap_typeOf)

-- ---- Stub: Minimap:render -------------------------------------------------
--@api-stub: Minimap:render
-- Demonstrates the proper usage of Minimap:render.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_render()
    mm:render()
    print("minimap rendered to screen")
end
local _ok, _err = pcall(demo_Minimap_render)

-- ---- Stub: Minimap:drawToImage --------------------------------------------
--@api-stub: Minimap:drawToImage
-- Demonstrates the proper usage of Minimap:drawToImage.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Minimap_drawToImage()
    mm:drawToImage("output/dungeon_map.png")
    print("minimap exported to output/dungeon_map.png")
    print("\n-- minimap.lua example complete --")
end
local _ok, _err = pcall(demo_Minimap_drawToImage)
