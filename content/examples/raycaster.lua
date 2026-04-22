-- content/examples/raycaster.lua
-- love2d-style usage snippets for the lurek.raycaster API (42 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/raycaster.lua

-- ── lurek.raycaster.* functions ──

--@api-stub: lurek.raycaster.new
-- Creates a new raycaster grid of the given dimensions.
-- Build once at startup; reuse across frames.
local obj = lurek.raycaster.new(64, 64)
print("created", obj)
return obj

--@api-stub: lurek.raycaster.newMap
-- Alias for `new`.
-- Build once at startup; reuse across frames.
local map = lurek.raycaster.newMap(64, 64)
print("created", map)
return map

--@api-stub: lurek.raycaster.projectColumn
-- Projects a wall distance to screen-space drawing parameters.
-- See the module spec for detailed semantics.
local result = lurek.raycaster.projectColumn(distance, fov, screen_height)
print("projectColumn:", result)
return result

--@api-stub: lurek.raycaster.distanceShade
-- Returns distance-based brightness in [0, 1].
-- See the module spec for detailed semantics.
local result = lurek.raycaster.distanceShade(distance, max_distance)
print("distanceShade:", result)
return result

--@api-stub: lurek.raycaster.newDoorManager
-- Creates a new empty door manager.
-- Build once at startup; reuse across frames.
local doormanager = lurek.raycaster.newDoorManager()
print("created", doormanager)
return doormanager

--@api-stub: lurek.raycaster.newHeightMap
-- Creates a new height map with default floor (0.0) and ceiling (1.0) values.
-- Build once at startup; reuse across frames.
local heightmap = lurek.raycaster.newHeightMap(64, 64)
print("created", heightmap)
return heightmap

--@api-stub: lurek.raycaster.newPointLight
-- Creates a point light for use in raycaster scene lighting.
-- Build once at startup; reuse across frames.
local pointlight = lurek.raycaster.newPointLight(100, 100, 1, 0.5, 0, radius, intensity)
print("created", pointlight)
return pointlight

--@api-stub: lurek.raycaster.newSpriteManager
-- Creates a new empty batch sprite manager for depth-sorted projection.
-- Build once at startup; reuse across frames.
local spritemanager = lurek.raycaster.newSpriteManager()
print("created", spritemanager)
return spritemanager

-- ── DoorManager methods ──

--@api-stub: DoorManager:openDoor
-- Begins opening the door at the given index.
-- Build once at startup; reuse across frames.
local doorManager = lurek.raycaster.newDoorManager()
doorManager:openDoor(1)
print("DoorManager:openDoor done")

--@api-stub: DoorManager:closeDoor
-- Begins closing the door at the given index.
-- See the module spec for detailed semantics.
local doorManager = lurek.raycaster.newDoorManager()
doorManager:closeDoor(1)
print("DoorManager:closeDoor done")

--@api-stub: DoorManager:update
-- Advances all door animations by dt seconds.
-- Apply at startup or in response to user input.
local doorManager = lurek.raycaster.newDoorManager()
doorManager:update(dt)
print("DoorManager:update applied")

--@api-stub: DoorManager:getDoor
-- Returns the state table for door at index, or nil if out of range.
-- Cheap to call; safe inside callbacks.
local doorManager = lurek.raycaster.newDoorManager()  -- or your existing handle
local value = doorManager:getDoor(1)
print("DoorManager:getDoor ->", value)

--@api-stub: DoorManager:count
-- Returns the number of registered doors.
-- Cheap to call; safe inside callbacks.
local doorManager = lurek.raycaster.newDoorManager()  -- or your existing handle
local value = doorManager:count()
print("DoorManager:count ->", value)

--@api-stub: DoorManager:type
-- Returns the type string "DoorManager".
-- See the module spec for detailed semantics.
local doorManager = lurek.raycaster.newDoorManager()
doorManager:type()
print("DoorManager:type done")

--@api-stub: DoorManager:typeOf
-- Returns the type string "DoorManager".
-- See the module spec for detailed semantics.
local doorManager = lurek.raycaster.newDoorManager()
doorManager:typeOf()
print("DoorManager:typeOf done")

-- ── HeightMap methods ──

--@api-stub: HeightMap:setFloor
-- Sets the floor height at (x, y).
-- Apply at startup or in response to user input.
local heightMap = lurek.raycaster.newHeightMap()
heightMap:setFloor(100, 100, 64)
print("HeightMap:setFloor applied")

--@api-stub: HeightMap:setCeiling
-- Sets the ceiling height at (x, y).
-- Apply at startup or in response to user input.
local heightMap = lurek.raycaster.newHeightMap()
heightMap:setCeiling(100, 100, 64)
print("HeightMap:setCeiling applied")

--@api-stub: HeightMap:floorAt
-- Returns the floor height at (x, y).
-- See the module spec for detailed semantics.
local heightMap = lurek.raycaster.newHeightMap()
heightMap:floorAt(100, 100)
print("HeightMap:floorAt done")

--@api-stub: HeightMap:ceilingAt
-- Returns the ceiling height at (x, y).
-- See the module spec for detailed semantics.
local heightMap = lurek.raycaster.newHeightMap()
heightMap:ceilingAt(100, 100)
print("HeightMap:ceilingAt done")

--@api-stub: HeightMap:type
-- Returns the type string "HeightMap".
-- See the module spec for detailed semantics.
local heightMap = lurek.raycaster.newHeightMap()
heightMap:type()
print("HeightMap:type done")

--@api-stub: HeightMap:typeOf
-- Returns the type string "HeightMap".
-- See the module spec for detailed semantics.
local heightMap = lurek.raycaster.newHeightMap()
heightMap:typeOf()
print("HeightMap:typeOf done")

-- ── PointLight methods ──

--@api-stub: PointLight:x
-- Returns the world-space X position.
-- See the module spec for detailed semantics.
local pointLight = lurek.raycaster.newPointLight()
pointLight:x()
print("PointLight:x done")

--@api-stub: PointLight:y
-- Returns the world-space Y position.
-- See the module spec for detailed semantics.
local pointLight = lurek.raycaster.newPointLight()
pointLight:y()
print("PointLight:y done")

--@api-stub: PointLight:radius
-- Returns the illumination radius.
-- See the module spec for detailed semantics.
local pointLight = lurek.raycaster.newPointLight()
pointLight:radius()
print("PointLight:radius done")

--@api-stub: PointLight:intensity
-- Returns the intensity multiplier.
-- See the module spec for detailed semantics.
local pointLight = lurek.raycaster.newPointLight()
pointLight:intensity()
print("PointLight:intensity done")

--@api-stub: PointLight:color
-- Returns the RGB color as three separate values.
-- See the module spec for detailed semantics.
local pointLight = lurek.raycaster.newPointLight()
pointLight:color()
print("PointLight:color done")

--@api-stub: PointLight:type
-- Returns the type string "PointLight".
-- See the module spec for detailed semantics.
local pointLight = lurek.raycaster.newPointLight()
pointLight:type()
print("PointLight:type done")

--@api-stub: PointLight:typeOf
-- Returns the type string "PointLight".
-- See the module spec for detailed semantics.
local pointLight = lurek.raycaster.newPointLight()
pointLight:typeOf()
print("PointLight:typeOf done")

-- ── Raycaster methods ──

--@api-stub: Raycaster:setCell
-- Sets the cell value at grid position (x, y).
-- Apply at startup or in response to user input.
local raycaster = lurek.raycaster.newRaycaster()
raycaster:setCell(100, 100, val)
print("Raycaster:setCell applied")

--@api-stub: Raycaster:getCell
-- Returns the cell value at (x, y).
-- Cheap to call; safe inside callbacks.
local raycaster = lurek.raycaster.newRaycaster()  -- or your existing handle
local value = raycaster:getCell(100, 100)
print("Raycaster:getCell ->", value)

--@api-stub: Raycaster:setCells
-- Replaces all grid cells from a flat array of values in row-major order.
-- Apply at startup or in response to user input.
local raycaster = lurek.raycaster.newRaycaster()
raycaster:setCells(cells_tbl)
print("Raycaster:setCells applied")

--@api-stub: Raycaster:isBlocked
-- Returns true when the cell at (x, y) is a wall (value > 0).
-- Use as a guard inside lurek.update or event handlers.
local raycaster = lurek.raycaster.newRaycaster()
if raycaster:isBlocked(100, 100) then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Raycaster:width
-- Returns the grid width in cells.
-- See the module spec for detailed semantics.
local raycaster = lurek.raycaster.newRaycaster()
raycaster:width()
print("Raycaster:width done")

--@api-stub: Raycaster:height
-- Returns the grid height in cells.
-- See the module spec for detailed semantics.
local raycaster = lurek.raycaster.newRaycaster()
raycaster:height()
print("Raycaster:height done")

--@api-stub: Raycaster:setWallAlpha
-- Sets the opacity for a wall tile type.
-- Apply at startup or in response to user input.
local raycaster = lurek.raycaster.newRaycaster()
raycaster:setWallAlpha(tile_type, 1)
print("Raycaster:setWallAlpha applied")

--@api-stub: Raycaster:getWallAlpha
-- Returns the opacity for a wall tile type.
-- Cheap to call; safe inside callbacks.
local raycaster = lurek.raycaster.newRaycaster()  -- or your existing handle
local value = raycaster:getWallAlpha(tile_type)
print("Raycaster:getWallAlpha ->", value)

-- ── SpriteManager methods ──

--@api-stub: SpriteManager:remove
-- Removes the sprite with the given id.
-- Pair with the matching constructor to free resources.
local spriteManager = lurek.raycaster.newSpriteManager()
spriteManager:remove(1)
-- spriteManager is now released
print("ok")

--@api-stub: SpriteManager:setPosition
-- Moves the sprite with the given id to world (x, y).
-- Apply at startup or in response to user input.
local spriteManager = lurek.raycaster.newSpriteManager()
spriteManager:setPosition(1, 100, 100)
print("SpriteManager:setPosition applied")

--@api-stub: SpriteManager:setVisible
-- Shows or hides the sprite with the given id.
-- Apply at startup or in response to user input.
local spriteManager = lurek.raycaster.newSpriteManager()
spriteManager:setVisible(1, visible)
print("SpriteManager:setVisible applied")

--@api-stub: SpriteManager:clear
-- Removes all sprites from the manager.
-- Pair with the matching constructor to free resources.
local spriteManager = lurek.raycaster.newSpriteManager()
spriteManager:clear()
-- spriteManager is now released
print("ok")

--@api-stub: SpriteManager:type
-- Returns the type string "SpriteManager".
-- See the module spec for detailed semantics.
local spriteManager = lurek.raycaster.newSpriteManager()
spriteManager:type()
print("SpriteManager:type done")

--@api-stub: SpriteManager:typeOf
-- Returns the type string "SpriteManager".
-- See the module spec for detailed semantics.
local spriteManager = lurek.raycaster.newSpriteManager()
spriteManager:typeOf()
print("SpriteManager:typeOf done")

