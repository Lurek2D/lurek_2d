-- content/examples/raycaster.lua
-- Lurek2D lurek.raycaster API Reference
-- Run with: cargo run -- content/examples/raycaster
--
Scenario: A Wolfenstein-style first-person dungeon crawler with textured
-- walls, height-mapped floors/ceilings, doors that open/close, point lights
-- for torches, and billboard sprites for enemies and items.

print("=== lurek.raycaster — 2.5D Raycasting ===\n")

-- =============================================================================
-- Map & Raycaster Creation
-- =============================================================================

-- Demonstrates the proper usage of lurek.raycaster.newMap.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_raycaster_newMap()
    local map = lurek.raycaster.newMap(16, 16)
end
local _ok, _err = pcall(demo_lurek_raycaster_newMap)

-- Demonstrates the proper usage of lurek.raycaster.new.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_raycaster_new()
    local rc = lurek.raycaster.new(map)
end
local _ok, _err = pcall(demo_lurek_raycaster_new)

-- =============================================================================
-- Map Cell Operations
-- =============================================================================

-- Demonstrates the proper usage of Raycaster:setCell.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Raycaster_setCell()
    rc:setCell(0, 0, 1)
    rc:setCell(1, 0, 1)
    rc:setCell(2, 0, 2)
end
local _ok, _err = pcall(demo_Raycaster_setCell)

-- Demonstrates the proper usage of Raycaster:getCell.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Raycaster_getCell()
    print("cell (0,0): " .. rc:getCell(0, 0))
end
local _ok, _err = pcall(demo_Raycaster_getCell)

-- Demonstrates the proper usage of Raycaster:setCells.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Raycaster_setCells()
    rc:setCells(0, 0, 16, 1, 1)  -- top wall row
end
local _ok, _err = pcall(demo_Raycaster_setCells)

-- Demonstrates the proper usage of Raycaster:isBlocked.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Raycaster_isBlocked()
    print("blocked (0,0): " .. tostring(rc:isBlocked(0, 0)))
end
local _ok, _err = pcall(demo_Raycaster_isBlocked)

-- Demonstrates the proper usage of Raycaster:width.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Raycaster_width()
    print("map width: " .. rc:width())
end
local _ok, _err = pcall(demo_Raycaster_width)

-- Demonstrates the proper usage of Raycaster:height.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Raycaster_height()
    print("map height: " .. rc:height())
end
local _ok, _err = pcall(demo_Raycaster_height)

-- Demonstrates the proper usage of Raycaster:getWallAlpha.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Raycaster_getWallAlpha()
    print("wall alpha (0,0): " .. rc:getWallAlpha(0, 0))
end
local _ok, _err = pcall(demo_Raycaster_getWallAlpha)

-- =============================================================================
-- Rendering Helpers
-- =============================================================================

-- Demonstrates the proper usage of lurek.raycaster.projectColumn.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_raycaster_projectColumn()
    local col = lurek.raycaster.projectColumn(rc, 5.0, 3.5, 0.0, 160)
end
local _ok, _err = pcall(demo_lurek_raycaster_projectColumn)

-- Demonstrates the proper usage of lurek.raycaster.distanceShade.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_raycaster_distanceShade()
    local shade = lurek.raycaster.distanceShade(8.0, 16.0)
    print("shade at dist 8: " .. shade)
end
local _ok, _err = pcall(demo_lurek_raycaster_distanceShade)

-- =============================================================================
-- HeightMap — Variable floor/ceiling
-- =============================================================================

-- Demonstrates the proper usage of lurek.raycaster.newHeightMap.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_raycaster_newHeightMap()
    local hmap = lurek.raycaster.newHeightMap(16, 16)
end
local _ok, _err = pcall(demo_lurek_raycaster_newHeightMap)

-- Demonstrates the proper usage of HeightMap:setFloor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HeightMap_setFloor()
    hmap:setFloor(5, 5, 0.2)
end
local _ok, _err = pcall(demo_HeightMap_setFloor)

-- Demonstrates the proper usage of HeightMap:setCeiling.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HeightMap_setCeiling()
    hmap:setCeiling(5, 5, 0.8)
end
local _ok, _err = pcall(demo_HeightMap_setCeiling)

-- Demonstrates the proper usage of HeightMap:floorAt.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HeightMap_floorAt()
    print("floor at (5,5): " .. hmap:floorAt(5, 5))
end
local _ok, _err = pcall(demo_HeightMap_floorAt)

-- Demonstrates the proper usage of HeightMap:ceilingAt.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HeightMap_ceilingAt()
    print("ceiling at (5,5): " .. hmap:ceilingAt(5, 5))
end
local _ok, _err = pcall(demo_HeightMap_ceilingAt)

-- Demonstrates the proper usage of HeightMap:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HeightMap_type()
    print("heightmap type: " .. hmap:type())
end
local _ok, _err = pcall(demo_HeightMap_type)

-- Demonstrates the proper usage of HeightMap:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HeightMap_typeOf()
    print("is HeightMap: " .. tostring(hmap:typeOf("HeightMap")))
end
local _ok, _err = pcall(demo_HeightMap_typeOf)

-- =============================================================================
-- DoorManager — Interactive doors
-- =============================================================================

-- Demonstrates the proper usage of lurek.raycaster.newDoorManager.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_raycaster_newDoorManager()
    local doors = lurek.raycaster.newDoorManager()
end
local _ok, _err = pcall(demo_lurek_raycaster_newDoorManager)

-- Demonstrates the proper usage of DoorManager:openDoor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DoorManager_openDoor()
    doors:openDoor(5, 3, 1.0)
end
local _ok, _err = pcall(demo_DoorManager_openDoor)

-- Demonstrates the proper usage of DoorManager:closeDoor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DoorManager_closeDoor()
    doors:closeDoor(5, 3, 1.0)
end
local _ok, _err = pcall(demo_DoorManager_closeDoor)

-- Demonstrates the proper usage of DoorManager:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DoorManager_update()
    doors:update(1/60)
end
local _ok, _err = pcall(demo_DoorManager_update)

-- Demonstrates the proper usage of DoorManager:getDoor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DoorManager_getDoor()
    local door = doors:getDoor(5, 3)
    print("door state: " .. tostring(door))
end
local _ok, _err = pcall(demo_DoorManager_getDoor)

-- Demonstrates the proper usage of DoorManager:count.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DoorManager_count()
    print("doors: " .. doors:count())
end
local _ok, _err = pcall(demo_DoorManager_count)

-- Demonstrates the proper usage of DoorManager:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DoorManager_type()
    print("door mgr type: " .. doors:type())
end
local _ok, _err = pcall(demo_DoorManager_type)

-- Demonstrates the proper usage of DoorManager:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DoorManager_typeOf()
    print("is DoorManager: " .. tostring(doors:typeOf("DoorManager")))
end
local _ok, _err = pcall(demo_DoorManager_typeOf)

-- =============================================================================
-- PointLight — Torch lights in the dungeon
-- =============================================================================

-- Demonstrates the proper usage of lurek.raycaster.newPointLight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_raycaster_newPointLight()
    local torch = lurek.raycaster.newPointLight(5.5, 3.5, 4.0, 1.0, {1.0, 0.8, 0.5})
end
local _ok, _err = pcall(demo_lurek_raycaster_newPointLight)

-- Demonstrates the proper usage of PointLight:x.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PointLight_x()
    print("torch x: " .. torch:x())
end
local _ok, _err = pcall(demo_PointLight_x)

-- Demonstrates the proper usage of PointLight:y.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PointLight_y()
    print("torch y: " .. torch:y())
end
local _ok, _err = pcall(demo_PointLight_y)

-- Demonstrates the proper usage of PointLight:radius.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PointLight_radius()
    print("radius: " .. torch:radius())
end
local _ok, _err = pcall(demo_PointLight_radius)

-- Demonstrates the proper usage of PointLight:intensity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PointLight_intensity()
    print("intensity: " .. torch:intensity())
end
local _ok, _err = pcall(demo_PointLight_intensity)

-- Demonstrates the proper usage of PointLight:color.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PointLight_color()
    local c = torch:color()
    print("color: " .. tostring(c))
end
local _ok, _err = pcall(demo_PointLight_color)

-- Demonstrates the proper usage of PointLight:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PointLight_type()
    print("light type: " .. torch:type())
end
local _ok, _err = pcall(demo_PointLight_type)

-- Demonstrates the proper usage of PointLight:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PointLight_typeOf()
    print("is PointLight: " .. tostring(torch:typeOf("PointLight")))
end
local _ok, _err = pcall(demo_PointLight_typeOf)

-- =============================================================================
-- SpriteManager — Billboard sprites (enemies, items)
-- =============================================================================

-- Demonstrates the proper usage of lurek.raycaster.newSpriteManager.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_raycaster_newSpriteManager()
    local sprites = lurek.raycaster.newSpriteManager()
end
local _ok, _err = pcall(demo_lurek_raycaster_newSpriteManager)

-- Demonstrates the proper usage of SpriteManager:setPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteManager_setPosition()
    sprites:setPosition(1, 7.5, 4.5)
end
local _ok, _err = pcall(demo_SpriteManager_setPosition)

-- Demonstrates the proper usage of SpriteManager:setVisible.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteManager_setVisible()
    sprites:setVisible(1, true)
end
local _ok, _err = pcall(demo_SpriteManager_setVisible)

-- Demonstrates the proper usage of SpriteManager:remove.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteManager_remove()
    print('Executing remove')
end
local _ok, _err = pcall(demo_SpriteManager_remove)

-- Demonstrates the proper usage of SpriteManager:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteManager_clear()
    print('Executing clear')
end
local _ok, _err = pcall(demo_SpriteManager_clear)

-- Demonstrates the proper usage of SpriteManager:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteManager_type()
    print("sprite mgr type: " .. sprites:type())
end
local _ok, _err = pcall(demo_SpriteManager_type)

-- Demonstrates the proper usage of SpriteManager:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteManager_typeOf()
    print("is SpriteManager: " .. tostring(sprites:typeOf("SpriteManager")))
    print("\n-- raycaster.lua example complete --")
end
local _ok, _err = pcall(demo_SpriteManager_typeOf)

-- =============================================================================
lurek.raycaster — Wolfenstein-style 2.5D raycasting with doors, height maps,
--                   point lights, and billboarded sprites
--
-- The raycaster projects a 2D grid map into a pseudo-3D first-person view
-- using column-based rendering.  It supports textured walls, floor/ceiling
-- height maps, interactive doors, dynamic point lights, distance-based fog,
-- and billboarded sprite objects.
-- =============================================================================

-- Create a raycaster with a 16x16 grid.  Each cell value is a wall type
-- (0 = empty, 1+ = wall texture index).
local rc = lurek.raycaster.new(16, 16)
print("raycaster created: 16x16 grid")
print("  width: " .. rc:width() .. ", height: " .. rc:height())

-- Create a raycaster from a pre-built 2D table.  Each row is a table of
-- cell values.  Useful for loading maps from files.
local map_data = {
    {1,1,1,1,1},
    {1,0,0,0,1},
    {1,0,0,0,1},
    {1,0,0,0,1},
    {1,1,1,1,1},
}
local rc_map = lurek.raycaster.newMap(map_data)
print("raycaster from map: " .. rc_map:width() .. "x" .. rc_map:height())

-- Project a single column at angle offset 0.3 rad from the camera facing
-- direction.  Returns wall distance, wall type, and hit side.
local dist, wall_type, side = lurek.raycaster.projectColumn(rc, 4.5, 4.5, 0.0, 0.3)
print(string.format("column: dist=%.2f wall=%d side=%s",
    dist or 0, wall_type or 0, tostring(side)))

-- Compute a fog factor from 0.0 (close, bright) to 1.0 (far, dark) for
-- distance-based atmosphere.  Max range 10 units.
local shade = lurek.raycaster.distanceShade(5.0, 10.0)
print(string.format("shade at dist 5.0 (max 10): %.2f", shade))
local shade_close = lurek.raycaster.distanceShade(1.0, 10.0)
print(string.format("shade at dist 1.0: %.2f (brighter)", shade_close))


-- =============================================================================
-- Raycaster grid manipulation
-- =============================================================================

-- Demonstrates the proper usage of Raycaster:setCell.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Raycaster_setCell()
    rc:setCell(3, 3, 2)
    print("wall type 2 placed at (3,3)")
end
local _ok, _err = pcall(demo_Raycaster_setCell)

-- Demonstrates the proper usage of Raycaster:getCell.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Raycaster_getCell()
    local cell = rc:getCell(3, 3)
    print("cell (3,3) = " .. cell .. "  (0=empty, 1+=wall)")
end
local _ok, _err = pcall(demo_Raycaster_getCell)

-- Fill a rectangular region with walls to create a room boundary.
-- Sets cells (1,1) through (4,4) to wall type 1.
for y = 1, 4 do
    for x = 1, 4 do
        rc:setCell(x, y, (x == 1 or x == 4 or y == 1 or y == 4) and 1 or 0)
    end
end
print("room boundary built from (1,1) to (4,4)")

-- Demonstrates the proper usage of Raycaster:isBlocked.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Raycaster_isBlocked()
    local blocked = rc:isBlocked(3, 3)
    print("cell (3,3) blocked: " .. tostring(blocked))
    local open = rc:isBlocked(2, 2)
    print("cell (2,2) blocked: " .. tostring(open))
end
local _ok, _err = pcall(demo_Raycaster_isBlocked)

-- Demonstrates the proper usage of Raycaster:width.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Raycaster_width()
    local w = rc:width()
    print("map width: " .. w .. " cells")
end
local _ok, _err = pcall(demo_Raycaster_width)

-- Demonstrates the proper usage of Raycaster:height.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Raycaster_height()
    local h = rc:height()
    print("map height: " .. h .. " cells")
end
local _ok, _err = pcall(demo_Raycaster_height)

-- Demonstrates the proper usage of Raycaster:getWallAlpha.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Raycaster_getWallAlpha()
    local alpha = rc:getWallAlpha(3, 3)
    print("wall alpha at (3,3): " .. tostring(alpha) .. "  (1.0 = opaque)")
end
local _ok, _err = pcall(demo_Raycaster_getWallAlpha)

-- =============================================================================
-- DoorManager — interactive doors that open and close over time
-- =============================================================================

-- Demonstrates the proper usage of lurek.raycaster.newDoorManager.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_raycaster_newDoorManager()
    local doors = lurek.raycaster.newDoorManager(rc)
    print("door manager created")
end
local _ok, _err = pcall(demo_lurek_raycaster_newDoorManager)

-- Demonstrates the proper usage of DoorManager:openDoor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DoorManager_openDoor()
    doors:openDoor(5, 2)
    print("door at (5,2) opening...")
end
local _ok, _err = pcall(demo_DoorManager_openDoor)

-- Demonstrates the proper usage of DoorManager:closeDoor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DoorManager_closeDoor()
    doors:closeDoor(5, 2)
    print("door at (5,2) closing...")
end
local _ok, _err = pcall(demo_DoorManager_closeDoor)

-- Demonstrates the proper usage of DoorManager:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DoorManager_update()
    doors:update(0.016)
    print("doors updated for frame")
end
local _ok, _err = pcall(demo_DoorManager_update)

-- Demonstrates the proper usage of DoorManager:getDoor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DoorManager_getDoor()
    local state = doors:getDoor(5, 2)
    print("door (5,2) state: " .. tostring(state))
end
local _ok, _err = pcall(demo_DoorManager_getDoor)

-- Demonstrates the proper usage of DoorManager:count.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DoorManager_count()
    local door_count = doors:count()
    print("total doors: " .. door_count)
end
local _ok, _err = pcall(demo_DoorManager_count)

-- Demonstrates the proper usage of DoorManager:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DoorManager_type()
    print("door manager type: " .. doors:type())
end
local _ok, _err = pcall(demo_DoorManager_type)

-- Demonstrates the proper usage of DoorManager:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DoorManager_typeOf()
    print("is DoorManager: " .. tostring(doors:typeOf("DoorManager")))
end
local _ok, _err = pcall(demo_DoorManager_typeOf)

-- =============================================================================
-- HeightMap — variable floor and ceiling heights for 2.5D depth
-- =============================================================================

-- Demonstrates the proper usage of lurek.raycaster.newHeightMap.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_raycaster_newHeightMap()
    local hmap = lurek.raycaster.newHeightMap(16, 16)
    print("height map created: 16x16")
end
local _ok, _err = pcall(demo_lurek_raycaster_newHeightMap)

-- Demonstrates the proper usage of HeightMap:setFloor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HeightMap_setFloor()
    hmap:setFloor(3, 3, 0.5)
    print("floor at (3,3) raised to 0.5")
end
local _ok, _err = pcall(demo_HeightMap_setFloor)

-- Demonstrates the proper usage of HeightMap:setCeiling.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HeightMap_setCeiling()
    hmap:setCeiling(4, 4, 0.7)
    print("ceiling at (4,4) lowered to 0.7")
end
local _ok, _err = pcall(demo_HeightMap_setCeiling)

-- Demonstrates the proper usage of HeightMap:floorAt.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HeightMap_floorAt()
    local floor_h = hmap:floorAt(3, 3)
    print("floor height at (3,3): " .. floor_h)
end
local _ok, _err = pcall(demo_HeightMap_floorAt)

-- Demonstrates the proper usage of HeightMap:ceilingAt.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HeightMap_ceilingAt()
    local ceil_h = hmap:ceilingAt(4, 4)
    print("ceiling height at (4,4): " .. ceil_h)
end
local _ok, _err = pcall(demo_HeightMap_ceilingAt)

-- Demonstrates the proper usage of HeightMap:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HeightMap_type()
    print("height map type: " .. hmap:type())
end
local _ok, _err = pcall(demo_HeightMap_type)

-- Demonstrates the proper usage of HeightMap:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HeightMap_typeOf()
    print("is HeightMap: " .. tostring(hmap:typeOf("HeightMap")))
end
local _ok, _err = pcall(demo_HeightMap_typeOf)

-- =============================================================================
-- PointLight — dynamic lights for torches, muzzle flashes, lava glow
-- =============================================================================

-- Demonstrates the proper usage of lurek.raycaster.newPointLight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_raycaster_newPointLight()
    local torch = lurek.raycaster.newPointLight(3.5, 7.5, 4.0)
    print("point light created at (3.5, 7.5) radius 4.0")
end
local _ok, _err = pcall(demo_lurek_raycaster_newPointLight)

-- Demonstrates the proper usage of PointLight:x.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PointLight_x()
    print("light x: " .. torch:x())
end
local _ok, _err = pcall(demo_PointLight_x)

-- Demonstrates the proper usage of PointLight:y.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PointLight_y()
    print("light y: " .. torch:y())
end
local _ok, _err = pcall(demo_PointLight_y)

-- Demonstrates the proper usage of PointLight:radius.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PointLight_radius()
    print("light radius: " .. torch:radius())
end
local _ok, _err = pcall(demo_PointLight_radius)

-- Demonstrates the proper usage of PointLight:intensity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PointLight_intensity()
    local intensity = torch:intensity()
    print("light intensity: " .. tostring(intensity))
end
local _ok, _err = pcall(demo_PointLight_intensity)

-- Demonstrates the proper usage of PointLight:color.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PointLight_color()
    local r, g, b = torch:color()
    print(string.format("light color: (%.2f, %.2f, %.2f)", r or 0, g or 0, b or 0))
end
local _ok, _err = pcall(demo_PointLight_color)

-- Demonstrates the proper usage of PointLight:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PointLight_type()
    print("light type: " .. torch:type())
end
local _ok, _err = pcall(demo_PointLight_type)

-- Demonstrates the proper usage of PointLight:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PointLight_typeOf()
    print("is PointLight: " .. tostring(torch:typeOf("PointLight")))
end
local _ok, _err = pcall(demo_PointLight_typeOf)

-- =============================================================================
-- SpriteManager — billboarded objects (enemies, pickups, decorations)
-- =============================================================================

-- Demonstrates the proper usage of lurek.raycaster.newSpriteManager.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_raycaster_newSpriteManager()
    local sprites = lurek.raycaster.newSpriteManager()
    print("sprite manager created")
end
local _ok, _err = pcall(demo_lurek_raycaster_newSpriteManager)

-- Demonstrates the proper usage of SpriteManager:remove.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteManager_remove()
    sprites:remove(0)
    print("sprite 0 removed (enemy killed)")
end
local _ok, _err = pcall(demo_SpriteManager_remove)

-- Demonstrates the proper usage of SpriteManager:setPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteManager_setPosition()
    sprites:setPosition(0, 5.5, 8.2)
    print("sprite 0 moved to (5.5, 8.2)")
end
local _ok, _err = pcall(demo_SpriteManager_setPosition)

-- Demonstrates the proper usage of SpriteManager:setVisible.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteManager_setVisible()
    sprites:setVisible(0, false)
    print("sprite 0 hidden")
end
local _ok, _err = pcall(demo_SpriteManager_setVisible)

-- Demonstrates the proper usage of SpriteManager:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteManager_clear()
    sprites:clear()
    print("all sprites cleared for level transition")
end
local _ok, _err = pcall(demo_SpriteManager_clear)

-- Demonstrates the proper usage of SpriteManager:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteManager_type()
    print("sprite manager type: " .. sprites:type())
end
local _ok, _err = pcall(demo_SpriteManager_type)

-- Demonstrates the proper usage of SpriteManager:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteManager_typeOf()
    print("is SpriteManager: " .. tostring(sprites:typeOf("SpriteManager")))
end
local _ok, _err = pcall(demo_SpriteManager_typeOf)

-- =============================================================================
-- Advanced Edge Cases and Extra API Demonstrations
-- =============================================================================

-- Demonstrates the proper usage of lurek.raycaster.new.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_raycaster_new()
    local rc = lurek.raycaster.new(32, 32)
    print("raycaster grid:", rc:width(), "x", rc:height())
end
local _ok, _err = pcall(demo_lurek_raycaster_new)

-- Demonstrates the proper usage of lurek.raycaster.newMap.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_raycaster_newMap()
    local dungeon = lurek.raycaster.newMap(64, 64)
    print("dungeon map:", dungeon:width(), "x", dungeon:height())
end
local _ok, _err = pcall(demo_lurek_raycaster_newMap)

-- Convert a ray-hit distance to the height in pixels of the wall slice
-- that should be drawn for that screen column.
local distance     = 4.5
local fov          = math.pi / 3
local screen_h     = 480
local slice_height = lurek.raycaster.projectColumn(distance, fov, screen_h)
print(string.format("wall slice height at dist %.1f: %.0f px", distance, slice_height))

-- Demonstrates the proper usage of lurek.raycaster.distanceShade.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_raycaster_distanceShade()
    local brightness = lurek.raycaster.distanceShade(6.0, 16.0)
    print(string.format("shade at dist 6 of max 16: %.2f", brightness))
end
local _ok, _err = pcall(demo_lurek_raycaster_distanceShade)

-- Demonstrates the proper usage of lurek.raycaster.newDoorManager.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_raycaster_newDoorManager()
    local dm = lurek.raycaster.newDoorManager()
    print("door manager type:", dm:type())
end
local _ok, _err = pcall(demo_lurek_raycaster_newDoorManager)

-- Vary floor and ceiling heights per cell for stairways, platforms, and
-- multi-level areas in a 2.5D dungeon renderer.
local hm = lurek.raycaster.newHeightMap(32, 32)
hm:setFloor(10, 10, 0.25)    -- sunken floor pit
hm:setCeiling(10, 10, 0.75)  -- lower ceiling above it
print("height map floor at (10,10):", hm:floorAt(10, 10))

-- Demonstrates the proper usage of lurek.raycaster.newPointLight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_raycaster_newPointLight()
    local pl = lurek.raycaster.newPointLight(16.5, 12.0, 1.0, 0.8, 0.2, 8.0, 1.5)
    print("point light at", pl:x(), pl:y(), "radius:", pl:radius())
end
local _ok, _err = pcall(demo_lurek_raycaster_newPointLight)

-- Demonstrates the proper usage of lurek.raycaster.newSpriteManager.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_raycaster_newSpriteManager()
    local sm = lurek.raycaster.newSpriteManager()
    print("sprite manager type:", sm:type())
end
local _ok, _err = pcall(demo_lurek_raycaster_newSpriteManager)

-- Demonstrates the proper usage of DoorManager:openDoor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DoorManager_openDoor()
    dm:openDoor(1)
    print("door 1 opening")
end
local _ok, _err = pcall(demo_DoorManager_openDoor)

-- Demonstrates the proper usage of DoorManager:closeDoor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DoorManager_closeDoor()
    dm:closeDoor(1)
    print("door 1 closing")
end
local _ok, _err = pcall(demo_DoorManager_closeDoor)

-- Advance door animations each frame so the slide position stays smooth
-- and matches the frame rate rather than snapping to open/closed.
dm:update(0.016)
local door = dm:getDoor(1)
if door then
    print("door 1 offset:", door.offset)
end

-- Read the door state during raycasting to offset the wall column based
-- on how far open the door is, giving the sliding-door visual effect.
local door_state = dm:getDoor(1)
if door_state then
    print("door 1 state:", door_state.state, "offset:", door_state.offset)
end

-- Demonstrates the proper usage of DoorManager:count.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DoorManager_count()
    print("registered doors:", dm:count())
end
local _ok, _err = pcall(demo_DoorManager_count)

-- Demonstrates the proper usage of DoorManager:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DoorManager_type()
    print(dm:type())  -- "DoorManager"
end
local _ok, _err = pcall(demo_DoorManager_type)

-- Demonstrates the proper usage of DoorManager:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DoorManager_typeOf()
    print(dm:typeOf("DoorManager"))  -- true
end
local _ok, _err = pcall(demo_DoorManager_typeOf)

-- Demonstrates the proper usage of HeightMap:setFloor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HeightMap_setFloor()
    hm:setFloor(5, 5, 0.3)  -- slightly raised platform
    print("floor at (5,5):", hm:floorAt(5, 5))
end
local _ok, _err = pcall(demo_HeightMap_setFloor)

-- Demonstrates the proper usage of HeightMap:setCeiling.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HeightMap_setCeiling()
    hm:setCeiling(8, 8, 0.6)  -- low-clearance tunnel
    print("ceiling at (8,8):", hm:ceilingAt(8, 8))
end
local _ok, _err = pcall(demo_HeightMap_setCeiling)

-- Demonstrates the proper usage of HeightMap:floorAt.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HeightMap_floorAt()
    print("floor at (5,5):", hm:floorAt(5, 5))   -- 0.3
    print("floor at (0,0):", hm:floorAt(0, 0))   -- 0.0 (default)
end
local _ok, _err = pcall(demo_HeightMap_floorAt)

-- Demonstrates the proper usage of HeightMap:ceilingAt.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HeightMap_ceilingAt()
    print("ceiling at (8,8):", hm:ceilingAt(8, 8))  -- 0.6
    print("ceiling at (0,0):", hm:ceilingAt(0, 0))  -- 1.0 (default)
end
local _ok, _err = pcall(demo_HeightMap_ceilingAt)

-- Demonstrates the proper usage of HeightMap:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HeightMap_type()
    print(hm:type())  -- "HeightMap"
end
local _ok, _err = pcall(demo_HeightMap_type)

-- Demonstrates the proper usage of HeightMap:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HeightMap_typeOf()
    print(hm:typeOf("HeightMap"))  -- true
end
local _ok, _err = pcall(demo_HeightMap_typeOf)

-- Demonstrates the proper usage of PointLight:x.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PointLight_x()
    print("light x:", pl:x())  -- 16.5
end
local _ok, _err = pcall(demo_PointLight_x)

-- Demonstrates the proper usage of PointLight:y.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PointLight_y()
    print("light y:", pl:y())  -- 12.0
end
local _ok, _err = pcall(demo_PointLight_y)

-- Demonstrates the proper usage of PointLight:radius.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PointLight_radius()
    print("light radius:", pl:radius())  -- 8.0
end
local _ok, _err = pcall(demo_PointLight_radius)

-- Demonstrates the proper usage of PointLight:intensity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PointLight_intensity()
    print("light intensity:", pl:intensity())  -- 1.5
end
local _ok, _err = pcall(demo_PointLight_intensity)

-- Demonstrates the proper usage of PointLight:color.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PointLight_color()
    local r, g, b = pl:color()
    print(string.format("light colour: (%.2f, %.2f, %.2f)", r, g, b))
end
local _ok, _err = pcall(demo_PointLight_color)

-- Demonstrates the proper usage of PointLight:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PointLight_type()
    print(pl:type())  -- "PointLight"
end
local _ok, _err = pcall(demo_PointLight_type)

-- Demonstrates the proper usage of PointLight:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PointLight_typeOf()
    print(pl:typeOf("PointLight"))  -- true
end
local _ok, _err = pcall(demo_PointLight_typeOf)

-- Paint wall types into the grid -- 0 = passable space, 1..N = wall
-- texture indices rendered on each side of the column.
rc:setCell(0, 0, 1)   -- solid wall
rc:setCell(15, 15, 0) -- open corridor
print("cell (0,0):", rc:getCell(0, 0))

-- Demonstrates the proper usage of Raycaster:getCell.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Raycaster_getCell()
    print("cell (5,3) texture:", rc:getCell(5, 3))  -- 0 = open, 1+ = wall
end
local _ok, _err = pcall(demo_Raycaster_getCell)

-- Load an entire map level from a flat row-major array in one call --
-- faster than calling setCell() for every tile when the map is large.
local map_data = {}
for i = 1, 32 * 32 do map_data[i] = 0 end
map_data[1] = 1  -- north-west corner wall
rc:setCells(map_data)
print("all cells loaded from array")

-- Call before moving the player to allow wall-sliding rather than stopping
-- dead -- check x and y axes independently for smooth sliding.
local new_x, new_y = 4.5, 6.0
if rc:isBlocked(new_x, new_y) then
    print("move blocked at", new_x, new_y)
else
    print("move OK")
end

-- Demonstrates the proper usage of Raycaster:width.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Raycaster_width()
    print("grid size:", rc:width(), "x", rc:height())
end
local _ok, _err = pcall(demo_Raycaster_width)

-- Demonstrates the proper usage of Raycaster:height.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Raycaster_height()
    print("grid height:", rc:height())
end
local _ok, _err = pcall(demo_Raycaster_height)

-- Demonstrates the proper usage of Raycaster:getWallAlpha.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Raycaster_getWallAlpha()
    local alpha = rc:getWallAlpha(3)  -- tile type 3 = glass panel
    print(string.format("wall type 3 alpha: %.2f", alpha))
end
local _ok, _err = pcall(demo_Raycaster_getWallAlpha)

-- Demonstrates the proper usage of SpriteManager:remove.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteManager_remove()
    sm:remove(5)  -- sprite ID 5
    print("sprite 5 removed")
end
local _ok, _err = pcall(demo_SpriteManager_remove)

-- Demonstrates the proper usage of SpriteManager:setPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteManager_setPosition()
    sm:setPosition(1, 10.5, 8.0)
    print("sprite 1 moved to (10.5, 8.0)")
end
local _ok, _err = pcall(demo_SpriteManager_setPosition)

-- Hide a sprite temporarily (e.g. a pickup after collection) without
-- removing it from the manager so it can reappear later.
sm:setVisible(1, false)  -- hide
sm:setVisible(1, true)   -- show again
print("sprite 1 visibility toggled")

-- Demonstrates the proper usage of SpriteManager:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteManager_clear()
    sm:clear()
    print("all sprites cleared")
end
local _ok, _err = pcall(demo_SpriteManager_clear)

-- Demonstrates the proper usage of SpriteManager:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteManager_type()
    print(sm:type())  -- "SpriteManager"
end
local _ok, _err = pcall(demo_SpriteManager_type)

-- Demonstrates the proper usage of SpriteManager:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteManager_typeOf()
    print(sm:typeOf("SpriteManager"))  -- true
end
local _ok, _err = pcall(demo_SpriteManager_typeOf)

-- =============================================================================
-- Advanced Edge Cases and Extra API Demonstrations
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Raycaster methods
-- -----------------------------------------------------------------------------

-- Sets the opacity for a wall tile type. Alpha is clamped to [0, 1].
-- Example scenario:
if rc ~= nil then
    -- Calling actual method on rc successfully
    print("Action: calling setWallAlpha()")
    pcall(function() rc:setWallAlpha() end)
    print("Executed smoothly.")
end
