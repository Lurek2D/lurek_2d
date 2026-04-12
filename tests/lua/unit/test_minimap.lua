-- Lurek2D minimap API tests.
-- Covers minimap construction, terrain/object/fog state, view controls, and helper queries exposed through lurek.minimap.

-- @description Covers suite: lurek.minimap.newMinimap.
describe("lurek.minimap.newMinimap", function()
    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.getGridWidth
    -- @covers Minimap.getGridHeight
    -- @description Creates a minimap with grid dimensions and verifies the grid width and height accessors.
    it("creates a minimap with grid dimensions", function()
        local m = lurek.minimap.newMinimap(64, 48)
        expect_type("userdata", m)
        expect_equal(64, m:getGridWidth())
        expect_equal(48, m:getGridHeight())
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.getDisplayWidth
    -- @covers Minimap.getDisplayHeight
    -- @description Creates a minimap with an explicit display size and checks the stored display dimensions.
    it("creates a minimap with custom display size", function()
        local m = lurek.minimap.newMinimap(32, 32, 200, 150)
        expect_equal(200, m:getDisplayWidth())
        expect_equal(150, m:getDisplayHeight())
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.type
    -- @covers Minimap.typeOf
    -- @description Verifies the minimap userdata reports the correct type and type hierarchy.
    it("reports correct type", function()
        local m = lurek.minimap.newMinimap(10, 10)
        expect_equal("Minimap", m:type())
        assert(m:typeOf("Minimap"))
        assert(m:typeOf("Object"))
        assert(not m:typeOf("Image"))
    end)
end)

-- â”€â”€ Grid dimensions â”€â”€

-- @description Covers suite: grid dimensions.
describe("grid dimensions", function()
    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.getGridSize
    -- @description Confirms getGridSize returns the grid width and height that were used at construction.
    it("returns grid size as two values", function()
        local m = lurek.minimap.newMinimap(40, 30)
        local w, h = m:getGridSize()
        expect_equal(40, w)
        expect_equal(30, h)
    end)
end)

-- â”€â”€ Display size â”€â”€

-- @description Covers suite: display size.
describe("display size", function()
    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setDisplaySize
    -- @covers Minimap.getDisplayWidth
    -- @covers Minimap.getDisplayHeight
    -- @covers Minimap.getDisplaySize
    -- @description Updates the minimap display size and verifies both scalar and tuple getters reflect the new values.
    it("can set and get display size", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setDisplaySize(300, 200)
        expect_equal(300, m:getDisplayWidth())
        expect_equal(200, m:getDisplayHeight())
        local w, h = m:getDisplaySize()
        expect_equal(300, w)
        expect_equal(200, h)
    end)
end)

-- â”€â”€ Terrain â”€â”€

-- @description Covers suite: terrain.
describe("terrain", function()
    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.getTerrain
    -- @description Verifies uninitialized terrain cells default to terrain type 0.
    it("defaults to terrain type 0", function()
        local m = lurek.minimap.newMinimap(10, 10)
        expect_equal(0, m:getTerrain(1, 1))
        expect_equal(0, m:getTerrain(5, 5))
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setTerrain
    -- @covers Minimap.getTerrain
    -- @description Writes a terrain type into one cell and reads it back from the same coordinates.
    it("can set and get terrain type", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setTerrain(3, 4, 7)
        expect_equal(7, m:getTerrain(3, 4))
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setTerrainColor
    -- @covers Minimap.getTerrainColor
    -- @description Stores a terrain color with alpha and verifies all four returned channels.
    it("can set and get terrain colors with alpha", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setTerrainColor(1, 0.2, 0.4, 0.6, 0.8)
        local r, g, b, a = m:getTerrainColor(1)
        expect_near(0.2, r)
        expect_near(0.4, g)
        expect_near(0.6, b)
        expect_near(0.8, a)
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setTerrainColor
    -- @covers Minimap.getTerrainColor
    -- @description Verifies setTerrainColor applies the default alpha value of 1.0 when alpha is omitted.
    it("defaults alpha to 1.0", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setTerrainColor(2, 0.1, 0.2, 0.3)
        local _, _, _, a = m:getTerrainColor(2)
        expect_near(1.0, a)
    end)
end)

-- â”€â”€ Fog of war â”€â”€

-- @description Covers suite: fog of war.
describe("fog of war", function()
    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.isFogEnabled
    -- @description Confirms fog of war is disabled when a minimap is first created.
    it("is disabled by default", function()
        local m = lurek.minimap.newMinimap(10, 10)
        assert(not m:isFogEnabled())
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setFogEnabled
    -- @covers Minimap.isFogEnabled
    -- @description Toggles fog of war on and off and checks the enabled flag after each change.
    it("can toggle fog", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setFogEnabled(true)
        assert(m:isFogEnabled())
        m:setFogEnabled(false)
        assert(not m:isFogEnabled())
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.getFogLevel
    -- @description Verifies unexplored tiles default to fog level 0.
    it("defaults fog level to 0 (hidden)", function()
        local m = lurek.minimap.newMinimap(10, 10)
        expect_equal(0, m:getFogLevel(1, 1))
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setFogLevel
    -- @covers Minimap.getFogLevel
    -- @description Writes visible and explored fog states to a tile and verifies the stored levels.
    it("can set fog levels", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setFogLevel(2, 3, 2) -- visible
        expect_equal(2, m:getFogLevel(2, 3))
        m:setFogLevel(2, 3, 1) -- explored
        expect_equal(1, m:getFogLevel(2, 3))
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setFogColor
    -- @covers Minimap.getFogColor
    -- @description Sets a fog tint with alpha and checks that the returned RGBA values match.
    it("can set fog color", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setFogColor(0.1, 0.2, 0.3, 0.5)
        local r, g, b, a = m:getFogColor()
        expect_near(0.1, r)
        expect_near(0.2, g)
        expect_near(0.3, b)
        expect_near(0.5, a)
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setFogData
    -- @covers Minimap.getFogLevel
    -- @description Bulk-loads fog data into the grid and verifies representative cells across the map.
    it("can bulk set fog data", function()
        local m = lurek.minimap.newMinimap(3, 3)
        m:setFogData({
            2, 1, 0,
            0, 2, 1,
            1, 0, 2,
        })
        expect_equal(2, m:getFogLevel(1, 1))
        expect_equal(1, m:getFogLevel(2, 1))
        expect_equal(0, m:getFogLevel(3, 1))
        expect_equal(0, m:getFogLevel(1, 2))
        expect_equal(2, m:getFogLevel(2, 2))
        expect_equal(2, m:getFogLevel(3, 3))
    end)
end)

-- â”€â”€ Object types â”€â”€

-- @description Covers suite: object types.
describe("object types", function()
    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.getObjectTypeCount
    -- @description Verifies a new minimap starts with no registered object types.
    it("starts with zero types", function()
        local m = lurek.minimap.newMinimap(10, 10)
        expect_equal(0, m:getObjectTypeCount())
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.addObjectType
    -- @covers Minimap.getObjectTypeCount
    -- @description Adds multiple object types and verifies they receive 1-based indices and increment the type count.
    it("adds types with 1-based indices", function()
        local m = lurek.minimap.newMinimap(10, 10)
        local idx1 = m:addObjectType("unit", 1, 0, 0)
        expect_equal(1, idx1)
        local idx2 = m:addObjectType("building", 0, 0, 1, 0.8)
        expect_equal(2, idx2)
        expect_equal(2, m:getObjectTypeCount())
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.addObjectType
    -- @covers Minimap.isObjectTypeVisible
    -- @covers Minimap.setObjectTypeVisible
    -- @description Toggles the visibility flag for an object type and verifies the updated state.
    it("toggles type visibility", function()
        local m = lurek.minimap.newMinimap(10, 10)
        local idx = m:addObjectType("unit", 1, 0, 0)
        assert(m:isObjectTypeVisible(idx))
        m:setObjectTypeVisible(idx, false)
        assert(not m:isObjectTypeVisible(idx))
    end)
end)

-- â”€â”€ Objects â”€â”€

-- @description Covers suite: objects.
describe("objects", function()
    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.getObjectCount
    -- @description Confirms a new minimap has no placed objects.
    it("starts with zero objects", function()
        local m = lurek.minimap.newMinimap(100, 100)
        expect_equal(0, m:getObjectCount())
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.addObjectType
    -- @covers Minimap.setObject
    -- @covers Minimap.getObjectCount
    -- @covers Minimap.removeObject
    -- @description Adds objects of a registered type, removes them by id, and verifies the object count updates correctly.
    it("can add and remove objects", function()
        local m = lurek.minimap.newMinimap(100, 100)
        local idx = m:addObjectType("unit", 1, 0, 0)
        m:setObject(1, 50, 60, idx)
        expect_equal(1, m:getObjectCount())
        m:setObject(2, 70, 80, idx, 1)
        expect_equal(2, m:getObjectCount())
        assert(m:removeObject(1))
        expect_equal(1, m:getObjectCount())
        assert(not m:removeObject(999))
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.addObjectType
    -- @covers Minimap.setObject
    -- @covers Minimap.clearObjects
    -- @covers Minimap.getObjectCount
    -- @description Clears all placed objects and verifies the minimap reports an empty object list.
    it("can clear all objects", function()
        local m = lurek.minimap.newMinimap(100, 100)
        local idx = m:addObjectType("unit", 1, 0, 0)
        m:setObject(1, 10, 10, idx)
        m:setObject(2, 20, 20, idx)
        m:clearObjects()
        expect_equal(0, m:getObjectCount())
    end)
end)

-- â”€â”€ Owner colors â”€â”€

-- @description Covers suite: owner colors.
describe("owner colors", function()
    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setOwnerColor
    -- @covers Minimap.getOwnerColor
    -- @description Stores an owner color with alpha and verifies the returned RGBA channels.
    it("can set and get owner colors", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setOwnerColor(1, 0, 0, 1, 0.9)
        local r, g, b, a = m:getOwnerColor(1)
        expect_near(0.0, r)
        expect_near(0.0, g)
        expect_near(1.0, b)
        expect_near(0.9, a)
    end)
end)

-- â”€â”€ Color mode â”€â”€

-- @description Covers suite: color mode.
describe("color mode", function()
    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.getColorMode
    -- @description Verifies the default minimap color mode is terrain-based.
    it("defaults to terrain", function()
        local m = lurek.minimap.newMinimap(10, 10)
        expect_equal("terrain", m:getColorMode())
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setColorMode
    -- @covers Minimap.getColorMode
    -- @description Switches the color mode to political and confirms the new mode is reported.
    it("can switch to political", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setColorMode("political")
        expect_equal("political", m:getColorMode())
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setColorMode
    -- @description Ensures setColorMode rejects an unsupported mode string.
    it("errors on invalid mode", function()
        local m = lurek.minimap.newMinimap(10, 10)
        expect_error(function() m:setColorMode("invalid") end)
    end)
end)

-- â”€â”€ Zoom and pan â”€â”€

-- @description Covers suite: zoom and pan.
describe("zoom and pan", function()
    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.getZoom
    -- @description Confirms the initial zoom factor is 1.0.
    it("defaults zoom to 1.0", function()
        local m = lurek.minimap.newMinimap(10, 10)
        expect_near(1.0, m:getZoom())
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setZoom
    -- @covers Minimap.getZoom
    -- @description Updates the zoom factor and verifies the new zoom value is returned.
    it("can set zoom", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setZoom(2.5)
        expect_near(2.5, m:getZoom())
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setCenter
    -- @covers Minimap.getCenter
    -- @description Re-centers the minimap and verifies the new center coordinates.
    it("can set center", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setCenter(5, 3)
        local cx, cy = m:getCenter()
        expect_near(5, cx)
        expect_near(3, cy)
    end)
end)

-- â”€â”€ Viewport â”€â”€

-- @description Covers suite: viewport.
describe("viewport", function()
    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.getViewportRect
    -- @description Verifies the viewport rectangle is unset on a new minimap.
    it("starts with no viewport rect", function()
        local m = lurek.minimap.newMinimap(10, 10)
        assert(m:getViewportRect() == nil)
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setViewportRect
    -- @covers Minimap.getViewportRect
    -- @description Sets a viewport rectangle and verifies each returned field matches the assigned bounds.
    it("can set and get viewport rect", function()
        local m = lurek.minimap.newMinimap(100, 100)
        m:setViewportRect(10, 20, 30, 40)
        local vp = m:getViewportRect()
        assert(vp ~= nil)
        expect_equal(10, vp.x)
        expect_equal(20, vp.y)
        expect_equal(30, vp.w)
        expect_equal(40, vp.h)
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setViewportRect
    -- @covers Minimap.clearViewportRect
    -- @covers Minimap.getViewportRect
    -- @description Clears a previously assigned viewport rectangle and confirms it becomes nil again.
    it("can clear viewport rect", function()
        local m = lurek.minimap.newMinimap(100, 100)
        m:setViewportRect(10, 20, 30, 40)
        m:clearViewportRect()
        assert(m:getViewportRect() == nil)
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.isViewportVisible
    -- @covers Minimap.setViewportVisible
    -- @description Toggles viewport rendering visibility and verifies the visible flag changes accordingly.
    it("can toggle viewport visibility", function()
        local m = lurek.minimap.newMinimap(10, 10)
        assert(m:isViewportVisible())
        m:setViewportVisible(false)
        assert(not m:isViewportVisible())
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setViewportColor
    -- @covers Minimap.getViewportColor
    -- @description Sets the viewport highlight color and verifies all returned color channels.
    it("can set viewport color", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setViewportColor(0.5, 0.6, 0.7, 0.3)
        local r, g, b, a = m:getViewportColor()
        expect_near(0.5, r)
        expect_near(0.6, g)
        expect_near(0.7, b)
        expect_near(0.3, a)
    end)
end)

-- â”€â”€ Pings â”€â”€

-- @description Covers suite: pings.
describe("pings", function()
    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.getPingCount
    -- @description Confirms a new minimap starts with no active pings.
    it("starts with zero pings", function()
        local m = lurek.minimap.newMinimap(10, 10)
        expect_equal(0, m:getPingCount())
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.addPing
    -- @covers Minimap.getPingCount
    -- @description Adds pings with default and explicit color parameters and verifies the ping count increases.
    it("can add pings", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:addPing(5, 5, 2.0)
        expect_equal(1, m:getPingCount())
        m:addPing(3, 3, 1.0, 0, 1, 0, 1)
        expect_equal(2, m:getPingCount())
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.addPing
    -- @covers Minimap.update
    -- @covers Minimap.getPingCount
    -- @description Advances the minimap update loop past a ping duration and confirms the ping expires.
    it("expires pings after duration", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:addPing(5, 5, 1.0)
        expect_equal(1, m:getPingCount())
        m:update(0.5)
        expect_equal(1, m:getPingCount())
        m:update(0.6) -- total > 1.0
        expect_equal(0, m:getPingCount())
    end)
end)

-- â”€â”€ Markers â”€â”€

-- @description Covers suite: markers.
describe("markers", function()
    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.getMarkerCount
    -- @description Confirms a new minimap starts with no markers.
    it("starts with zero markers", function()
        local m = lurek.minimap.newMinimap(10, 10)
        expect_equal(0, m:getMarkerCount())
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.addMarker
    -- @covers Minimap.hasMarker
    -- @covers Minimap.getMarkerDescription
    -- @covers Minimap.getMarkerCount
    -- @description Adds a marker with a description and verifies it can be queried by id.
    it("can add and query markers", function()
        local m = lurek.minimap.newMinimap(10, 10)
        local id = m:addMarker(3, 4, "Objective A")
        assert(m:hasMarker(id))
        expect_equal("Objective A", m:getMarkerDescription(id))
        expect_equal(1, m:getMarkerCount())
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.addMarker
    -- @covers Minimap.removeMarker
    -- @covers Minimap.hasMarker
    -- @covers Minimap.getMarkerCount
    -- @covers Minimap.getMarkerDescription
    -- @description Removes a marker and verifies its presence, count, and description are cleared.
    it("can remove markers", function()
        local m = lurek.minimap.newMinimap(10, 10)
        local id = m:addMarker(3, 4, "Test")
        assert(m:removeMarker(id))
        assert(not m:hasMarker(id))
        expect_equal(0, m:getMarkerCount())
        assert(m:getMarkerDescription(id) == nil)
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.addMarker
    -- @covers Minimap.hasMarker
    -- @covers Minimap.getMarkerCount
    -- @description Adds a marker without a description and verifies it is still tracked correctly.
    it("can add markers without description", function()
        local m = lurek.minimap.newMinimap(10, 10)
        local id = m:addMarker(7, 8)
        assert(m:hasMarker(id))
        expect_equal(1, m:getMarkerCount())
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.removeMarker
    -- @description Verifies removeMarker returns false for an id that does not exist.
    it("returns false for non-existent marker removal", function()
        local m = lurek.minimap.newMinimap(10, 10)
        assert(not m:removeMarker(999))
    end)
end)

-- â”€â”€ Anti-alias â”€â”€

-- @description Covers suite: anti-alias.
describe("anti-alias", function()
    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.isAntiAlias
    -- @description Confirms anti-aliasing is disabled by default.
    it("defaults to false", function()
        local m = lurek.minimap.newMinimap(10, 10)
        assert(not m:isAntiAlias())
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setAntiAlias
    -- @covers Minimap.isAntiAlias
    -- @description Enables anti-aliasing and verifies the flag becomes true.
    it("can toggle", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setAntiAlias(true)
        assert(m:isAntiAlias())
    end)
end)

-- â”€â”€ Coordinate conversion â”€â”€

-- @description Covers suite: coordinate conversion.
describe("coordinate conversion", function()
    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.gridToScreen
    -- @covers Minimap.screenToGrid
    -- @description Converts a grid coordinate to screen space and back to verify the mapping round-trips.
    it("converts grid to screen and back", function()
        local m = lurek.minimap.newMinimap(10, 10, 100, 100)
        local sx, sy = m:gridToScreen(0, 0, 0, 0)
        expect_type("number", sx)
        expect_type("number", sy)
        local gx, gy = m:screenToGrid(sx, sy, 0, 0)
        expect_near(0, gx)
        expect_near(0, gy)
    end)
end)

-- â”€â”€ Update â”€â”€

-- @description Covers suite: update.
describe("update", function()
    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.update
    -- @description Verifies update accepts typical frame deltas without raising an error.
    it("does not crash", function()
        local m = lurek.minimap.newMinimap(10, 10)
        expect_no_error(function() m:update(0.016) end)
        expect_no_error(function() m:update(0.033) end)
    end)
end)

-- â”€â”€ Full workflow â”€â”€

-- @description Covers suite: full workflow.
describe("full workflow", function()
    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setTerrain
    -- @covers Minimap.setFogEnabled
    -- @covers Minimap.addObjectType
    -- @covers Minimap.setViewportRect
    -- @covers Minimap.addPing
    -- @covers Minimap.addMarker
    -- @covers Minimap.setZoom
    -- @covers Minimap.update
    -- @description Exercises a representative minimap setup flow with terrain, fog, objects, viewport, pings, markers, zoom, and update handling.
    it("runs a complete minimap setup", function()
        local m = lurek.minimap.newMinimap(32, 32, 200, 200)

        -- Terrain
        for x = 1, 32 do
            for y = 1, 32 do
                m:setTerrain(x, y, (x + y) % 4)
            end
        end
        m:setTerrainColor(0, 0, 0.5, 0)
        m:setTerrainColor(1, 0.3, 0.3, 0.3)

        -- Fog
        m:setFogEnabled(true)
        for x = 1, 10 do
            for y = 1, 10 do
                m:setFogLevel(x, y, 2)
            end
        end

        -- Objects
        local unitType = m:addObjectType("unit", 0, 1, 0)
        m:setObject(1, 5, 5, unitType, 0)
        m:setOwnerColor(0, 0, 1, 0)

        -- Viewport
        m:setViewportRect(0, 0, 16, 12)

        -- Pings and markers
        m:addPing(15, 15, 3, 1, 0, 0)
        m:addMarker(20, 20, "Base", 0, 0, 1)

        -- Zoom
        m:setZoom(1.5)
        m:setCenter(16, 16)

        -- Verify
        expect_equal(1, m:getObjectCount())
        expect_equal(1, m:getPingCount())
        expect_equal(1, m:getMarkerCount())
        assert(m:isFogEnabled())
        expect_near(1.5, m:getZoom())

        m:update(0.016)
        expect_equal(1, m:getPingCount())
    end)
end)

-- â”€â”€ setTerrainData â”€â”€

-- @description Covers suite: terrain data bulk set.
describe("terrain data bulk set", function()
    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setTerrainData
    -- @covers Minimap.getTerrain
    -- @description Loads a flat terrain array into the grid and verifies each cell is populated in row-major order.
    it("sets all cells from a flat table", function()
        local m = lurek.minimap.newMinimap(3, 2)
        m:setTerrainData({1, 2, 3, 4, 5, 6})
        expect_equal(1, m:getTerrain(1, 1))
        expect_equal(2, m:getTerrain(2, 1))
        expect_equal(3, m:getTerrain(3, 1))
        expect_equal(4, m:getTerrain(1, 2))
        expect_equal(5, m:getTerrain(2, 2))
        expect_equal(6, m:getTerrain(3, 2))
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setTerrainData
    -- @covers Minimap.getTerrain
    -- @description Verifies setTerrainData ignores extra entries that exceed the minimap grid size.
    it("ignores excess values beyond grid size", function()
        local m = lurek.minimap.newMinimap(2, 2)
        m:setTerrainData({7, 8, 9, 10, 11, 12, 13})
        expect_equal(7, m:getTerrain(1, 1))
        expect_equal(10, m:getTerrain(2, 2))
        -- grid is 2x2 so only first 4 values should apply
    end)
end)

-- â”€â”€ Tile descriptions â”€â”€

-- @description Covers suite: tile descriptions.
describe("tile descriptions", function()
    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.getTileDescription
    -- @description Confirms querying an unset tile description returns nil.
    it("returns nil for unset types", function()
        local m = lurek.minimap.newMinimap(5, 5)
        assert(m:getTileDescription(0) == nil)
        assert(m:getTileDescription(99) == nil)
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setTileDescription
    -- @covers Minimap.getTileDescription
    -- @description Stores a tile description string and verifies it can be retrieved by terrain type.
    it("sets and retrieves a description", function()
        local m = lurek.minimap.newMinimap(5, 5)
        m:setTileDescription(1, "Grass")
        expect_equal("Grass", m:getTileDescription(1))
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setTileDescription
    -- @covers Minimap.getTileDescription
    -- @description Replaces an existing tile description and verifies the later value wins.
    it("overwrites existing description", function()
        local m = lurek.minimap.newMinimap(5, 5)
        m:setTileDescription(0, "Water")
        m:setTileDescription(0, "Deep water")
        expect_equal("Deep water", m:getTileDescription(0))
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setTileDescription
    -- @covers Minimap.getTileDescription
    -- @description Verifies tile descriptions are stored independently for multiple terrain types.
    it("handles multiple types independently", function()
        local m = lurek.minimap.newMinimap(5, 5)
        m:setTileDescription(0, "Water")
        m:setTileDescription(1, "Forest")
        m:setTileDescription(2, "Mountain")
        expect_equal("Water",    m:getTileDescription(0))
        expect_equal("Forest",   m:getTileDescription(1))
        expect_equal("Mountain", m:getTileDescription(2))
        assert(m:getTileDescription(3) == nil)
    end)
end)

-- â”€â”€ getHoverInfo â”€â”€

-- @description Covers suite: getHoverInfo.
describe("getHoverInfo", function()
    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.getHoverInfo
    -- @description Verifies hover queries outside the minimap display bounds return nil.
    it("returns nil outside minimap bounds", function()
        local m = lurek.minimap.newMinimap(4, 4, 100, 100)
        assert(m:getHoverInfo(-1, 50, 0, 0) == nil)
        assert(m:getHoverInfo(50, -1, 0, 0) == nil)
        assert(m:getHoverInfo(101, 50, 0, 0) == nil)
        assert(m:getHoverInfo(50, 101, 0, 0) == nil)
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setTerrainData
    -- @covers Minimap.setTileDescription
    -- @covers Minimap.getHoverInfo
    -- @description Resolves a hovered tile to its configured terrain description.
    it("returns tile description for hovered cell", function()
        local m = lurek.minimap.newMinimap(4, 4, 100, 100)
        m:setTerrainData({1,1,1,1, 1,1,1,1, 1,1,1,1, 1,1,1,1})
        m:setTileDescription(1, "Plains")
        local info = m:getHoverInfo(1, 1, 0, 0)
        expect_equal("Plains", info)
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setTerrain
    -- @covers Minimap.getHoverInfo
    -- @description Verifies hover info returns nil when the hovered terrain type has no description.
    it("returns nil when terrain has no description", function()
        local m = lurek.minimap.newMinimap(4, 4, 100, 100)
        m:setTerrain(1, 1, 99)
        assert(m:getHoverInfo(1, 1, 0, 0) == nil)
    end)
end)

-- â”€â”€ setClickable / isClickable â”€â”€

-- @description Covers suite: clickable.
describe("clickable", function()
    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.isClickable
    -- @description Confirms minimaps are clickable by default.
    it("defaults to true", function()
        local m = lurek.minimap.newMinimap(10, 10)
        assert(m:isClickable())
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setClickable
    -- @covers Minimap.isClickable
    -- @description Disables minimap click handling and verifies the clickable flag turns off.
    it("can be disabled", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setClickable(false)
        assert(not m:isClickable())
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setClickable
    -- @covers Minimap.isClickable
    -- @description Re-enables click handling after disabling it and verifies the flag returns to true.
    it("can be re-enabled", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setClickable(false)
        m:setClickable(true)
        assert(m:isClickable())
    end)
end)

-- â”€â”€ getCenterX / getCenterY â”€â”€

-- @description Covers suite: center individual getters.
describe("center individual getters", function()
    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setCenter
    -- @covers Minimap.getCenterX
    -- @description Sets the minimap center and verifies getCenterX returns the X component.
    it("getCenterX returns the X component", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setCenter(3.5, 7.25)
        expect_near(3.5, m:getCenterX())
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setCenter
    -- @covers Minimap.getCenterY
    -- @description Sets the minimap center and verifies getCenterY returns the Y component.
    it("getCenterY returns the Y component", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setCenter(3.5, 7.25)
        expect_near(7.25, m:getCenterY())
    end)

    -- @covers lurek.minimap.newMinimap
    -- @covers Minimap.setCenter
    -- @covers Minimap.getCenter
    -- @covers Minimap.getCenterX
    -- @covers Minimap.getCenterY
    -- @description Verifies the individual center getters stay in sync with the tuple returned by getCenter.
    it("getCenterX and getCenterY match getCenter", function()
        local m = lurek.minimap.newMinimap(10, 10)
        m:setCenter(1.0, 9.0)
        local cx, cy = m:getCenter()
        expect_near(cx, m:getCenterX())
        expect_near(cy, m:getCenterY())
    end)
end)
test_summary()
