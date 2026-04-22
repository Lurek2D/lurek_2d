-- content/examples/minimap.lua
-- love2d-style usage snippets for the lurek.minimap API (56 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/minimap.lua

-- ── lurek.minimap.* functions ──

--@api-stub: lurek.minimap.newMinimap
-- Creates a new grid-based minimap.
-- Build once at startup; reuse across frames.
local minimap = lurek.minimap.newMinimap(grid_w, grid_h, display_w, display_h)
print("created", minimap)
return minimap

-- ── Minimap methods ──

--@api-stub: Minimap:getGridWidth
-- Returns the grid width in cells.
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getGridWidth()
print("Minimap:getGridWidth ->", value)

--@api-stub: Minimap:getGridHeight
-- Returns the grid height in cells.
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getGridHeight()
print("Minimap:getGridHeight ->", value)

--@api-stub: Minimap:getGridSize
-- Returns the grid width and height as two values.
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getGridSize()
print("Minimap:getGridSize ->", value)

--@api-stub: Minimap:getDisplayWidth
-- Returns the display width in pixels.
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getDisplayWidth()
print("Minimap:getDisplayWidth ->", value)

--@api-stub: Minimap:getDisplayHeight
-- Returns the display height in pixels.
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getDisplayHeight()
print("Minimap:getDisplayHeight ->", value)

--@api-stub: Minimap:getDisplaySize
-- Returns the display width and height as two values.
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getDisplaySize()
print("Minimap:getDisplaySize ->", value)

--@api-stub: Minimap:setDisplaySize
-- Sets the display size in pixels.
-- Apply at startup or in response to user input.
local minimap = lurek.minimap.newMinimap()
minimap:setDisplaySize(64, 64)
print("Minimap:setDisplaySize applied")

--@api-stub: Minimap:getTerrain
-- Returns the terrain type at a 1-based grid position.
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getTerrain(100, 100)
print("Minimap:getTerrain ->", value)

--@api-stub: Minimap:setTerrainData
-- Sets terrain types from a flat 1-based Lua table of integers (row-major).
-- Apply at startup or in response to user input.
local minimap = lurek.minimap.newMinimap()
minimap:setTerrainData({ x = 0, y = 0 })
print("Minimap:setTerrainData applied")

--@api-stub: Minimap:getTerrainColor
-- Returns the display color for a terrain type as r, g, b, a.
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getTerrainColor(terrain_type)
print("Minimap:getTerrainColor ->", value)

--@api-stub: Minimap:getTileDescription
-- Returns the hover tooltip string for a terrain type ID, or nil.
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getTileDescription(1)
print("Minimap:getTileDescription ->", value)

--@api-stub: Minimap:setFogEnabled
-- Enables or disables fog of war.
-- Apply at startup or in response to user input.
local minimap = lurek.minimap.newMinimap()
minimap:setFogEnabled(enabled)
print("Minimap:setFogEnabled applied")

--@api-stub: Minimap:isFogEnabled
-- Returns whether fog of war is enabled.
-- Use as a guard inside lurek.update or event handlers.
local minimap = lurek.minimap.newMinimap()
if minimap:isFogEnabled() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Minimap:setFogLevel
-- Sets the fog level at a 1-based grid position (0=hidden, 1=explored, 2=visible).
-- Apply at startup or in response to user input.
local minimap = lurek.minimap.newMinimap()
minimap:setFogLevel(100, 100, level)
print("Minimap:setFogLevel applied")

--@api-stub: Minimap:getFogLevel
-- Returns the fog level at a 1-based grid position (0=hidden, 1=explored, 2=visible).
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getFogLevel(100, 100)
print("Minimap:getFogLevel ->", value)

--@api-stub: Minimap:getFogColor
-- Returns the fog overlay color as r, g, b, a.
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getFogColor()
print("Minimap:getFogColor ->", value)

--@api-stub: Minimap:setFogData
-- Sets the entire fog grid from a flat 1-based table (0=hidden, 1=explored, 2=visible).
-- Apply at startup or in response to user input.
local minimap = lurek.minimap.newMinimap()
minimap:setFogData({ x = 0, y = 0 })
print("Minimap:setFogData applied")

--@api-stub: Minimap:isObjectTypeVisible
-- Returns whether an object type (1-based index) is visible.
-- Use as a guard inside lurek.update or event handlers.
local minimap = lurek.minimap.newMinimap()
if minimap:isObjectTypeVisible(1) then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Minimap:getObjectTypeCount
-- Returns the number of registered object types.
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getObjectTypeCount()
print("Minimap:getObjectTypeCount ->", value)

--@api-stub: Minimap:removeObject
-- Removes a tracked object by ID.
-- Pair with the matching constructor to free resources.
local minimap = lurek.minimap.newMinimap()
minimap:removeObject(1)
-- minimap is now released
print("ok")

--@api-stub: Minimap:clearObjects
-- Removes all tracked objects.
-- Pair with the matching constructor to free resources.
local minimap = lurek.minimap.newMinimap()
minimap:clearObjects()
-- minimap is now released
print("ok")

--@api-stub: Minimap:getObjectCount
-- Returns the number of tracked objects.
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getObjectCount()
print("Minimap:getObjectCount ->", value)

--@api-stub: Minimap:getOwnerColor
-- Returns the display color for an owner/faction as r, g, b, a.
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getOwnerColor(owner)
print("Minimap:getOwnerColor ->", value)

--@api-stub: Minimap:setColorMode
-- Sets the color mode ("terrain" or "political").
-- Apply at startup or in response to user input.
local minimap = lurek.minimap.newMinimap()
minimap:setColorMode(mode)
print("Minimap:setColorMode applied")

--@api-stub: Minimap:getColorMode
-- Returns the current color mode as a string.
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getColorMode()
print("Minimap:getColorMode ->", value)

--@api-stub: Minimap:setZoom
-- Sets the zoom level (minimum 0.1).
-- Apply at startup or in response to user input.
local minimap = lurek.minimap.newMinimap()
minimap:setZoom(zoom)
print("Minimap:setZoom applied")

--@api-stub: Minimap:getZoom
-- Returns the current zoom level.
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getZoom()
print("Minimap:getZoom ->", value)

--@api-stub: Minimap:setCenter
-- Sets the center of the minimap view in grid coordinates.
-- Apply at startup or in response to user input.
local minimap = lurek.minimap.newMinimap()
minimap:setCenter(100, 100)
print("Minimap:setCenter applied")

--@api-stub: Minimap:getCenter
-- Returns the center coordinates as x, y.
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getCenter()
print("Minimap:getCenter ->", value)

--@api-stub: Minimap:getCenterX
-- Returns the center X coordinate.
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getCenterX()
print("Minimap:getCenterX ->", value)

--@api-stub: Minimap:getCenterY
-- Returns the center Y coordinate.
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getCenterY()
print("Minimap:getCenterY ->", value)

--@api-stub: Minimap:clearViewportRect
-- Clears the viewport rectangle overlay.
-- Pair with the matching constructor to free resources.
local minimap = lurek.minimap.newMinimap()
minimap:clearViewportRect()
-- minimap is now released
print("ok")

--@api-stub: Minimap:getViewportRect
-- Returns the viewport rectangle as x, y, w, h or nil if not set.
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getViewportRect()
print("Minimap:getViewportRect ->", value)

--@api-stub: Minimap:setViewportVisible
-- Sets whether the viewport rectangle is visible.
-- Apply at startup or in response to user input.
local minimap = lurek.minimap.newMinimap()
minimap:setViewportVisible(visible)
print("Minimap:setViewportVisible applied")

--@api-stub: Minimap:isViewportVisible
-- Returns whether the viewport rectangle is visible.
-- Use as a guard inside lurek.update or event handlers.
local minimap = lurek.minimap.newMinimap()
if minimap:isViewportVisible() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Minimap:getViewportColor
-- Returns the viewport rectangle color as r, g, b, a.
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getViewportColor()
print("Minimap:getViewportColor ->", value)

--@api-stub: Minimap:getPingCount
-- Returns the number of active pings.
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getPingCount()
print("Minimap:getPingCount ->", value)

--@api-stub: Minimap:removeMarker
-- Removes the minimap marker with the given integer ID, if present.
-- Pair with the matching constructor to free resources.
local minimap = lurek.minimap.newMinimap()
minimap:removeMarker(1)
-- minimap is now released
print("ok")

--@api-stub: Minimap:hasMarker
-- Returns whether a marker with the given ID exists.
-- Use as a guard inside lurek.update or event handlers.
local minimap = lurek.minimap.newMinimap()
if minimap:hasMarker(1) then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Minimap:getMarkerDescription
-- Returns the description of a marker, or nil.
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getMarkerDescription(1)
print("Minimap:getMarkerDescription ->", value)

--@api-stub: Minimap:getMarkerCount
-- Returns the number of markers.
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getMarkerCount()
print("Minimap:getMarkerCount ->", value)

--@api-stub: Minimap:clearMarkerAnimation
-- Removes the animation from a marker, reverting it to static.
-- Pair with the matching constructor to free resources.
local minimap = lurek.minimap.newMinimap()
minimap:clearMarkerAnimation(1)
-- minimap is now released
print("ok")

--@api-stub: Minimap:clearOverlay
-- Removes all custom geometry from the minimap overlay.
-- Pair with the matching constructor to free resources.
local minimap = lurek.minimap.newMinimap()
minimap:clearOverlay()
-- minimap is now released
print("ok")

--@api-stub: Minimap:clearPath
-- Removes a displayed path.
-- Pair with the matching constructor to free resources.
local minimap = lurek.minimap.newMinimap()
minimap:clearPath(1)
-- minimap is now released
print("ok")

--@api-stub: Minimap:setLayer
-- Switches the minimap's active render layer (0-based index).
-- Apply at startup or in response to user input.
local minimap = lurek.minimap.newMinimap()
minimap:setLayer(layer)
print("Minimap:setLayer applied")

--@api-stub: Minimap:getLayer
-- Returns the index of the currently active render layer.
-- Cheap to call; safe inside callbacks.
local minimap = lurek.minimap.newMinimap()  -- or your existing handle
local value = minimap:getLayer()
print("Minimap:getLayer ->", value)

--@api-stub: Minimap:setAntiAlias
-- Sets whether anti-aliasing is enabled.
-- Apply at startup or in response to user input.
local minimap = lurek.minimap.newMinimap()
minimap:setAntiAlias(enabled)
print("Minimap:setAntiAlias applied")

--@api-stub: Minimap:isAntiAlias
-- Returns whether anti-aliasing is enabled.
-- Use as a guard inside lurek.update or event handlers.
local minimap = lurek.minimap.newMinimap()
if minimap:isAntiAlias() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Minimap:setClickable
-- Sets whether this minimap responds to click hit-testing.
-- Apply at startup or in response to user input.
local minimap = lurek.minimap.newMinimap()
minimap:setClickable(enabled)
print("Minimap:setClickable applied")

--@api-stub: Minimap:isClickable
-- Returns whether this minimap responds to click hit-testing.
-- Use as a guard inside lurek.update or event handlers.
local minimap = lurek.minimap.newMinimap()
if minimap:isClickable() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Minimap:update
-- Advances time-based effects by dt seconds (expires pings).
-- Apply at startup or in response to user input.
local minimap = lurek.minimap.newMinimap()
minimap:update(dt)
print("Minimap:update applied")

--@api-stub: Minimap:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local minimap = lurek.minimap.newMinimap()
minimap:type()
print("Minimap:type done")

--@api-stub: Minimap:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local minimap = lurek.minimap.newMinimap()
minimap:typeOf("main")
print("Minimap:typeOf done")

--@api-stub: Minimap:render
-- Renders the minimap to the screen at the given position.
-- See the module spec for detailed semantics.
local minimap = lurek.minimap.newMinimap()
minimap:render(100, 100)
print("Minimap:render done")

--@api-stub: Minimap:drawToImage
-- Renders the minimap grid to a CPU ImageData.
-- Place inside `function lurek.render() ... end`.
local minimap = lurek.minimap.newMinimap()
minimap:drawToImage(pixel_size)
print("Minimap:drawToImage done")

