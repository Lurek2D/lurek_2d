--- Raycaster Module Part 2: buildSceneWithModels, width/height, DoorManager, HeightMap, PointLight, SpriteManager

--@api-stub: LRaycaster:buildSceneWithModels
-- Full scene build with model meshes alongside sprites.
do
    local rc = lurek.raycaster.new(80, 60)
    local map = lurek.raycaster.newMap(16, 16)
        local scene = rc:buildSceneWithModels(
        { px = 8, py = 8, angle = 0 },
        {},
        {},
        { "assets/textures/ray_water.png" },
        {}
    )
    print("scene=" .. tostring(scene ~= nil))
end

--@api-stub: LRaycaster:height
--@api-stub: LRaycaster:width
-- Raycaster viewport dimensions.
do
    local rc = lurek.raycaster.new(160, 120)
    print("w=" .. rc:width())
    print("h=" .. rc:height())
end

--@api-stub: LDoorManager:addDoor
--@api-stub: LDoorManager:closeDoor
--@api-stub: LDoorManager:count
--@api-stub: LDoorManager:openDoor
--@api-stub: LDoorManager:update
-- Door manager lifecycle and operations.
do
    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    print("count=" .. dm:count())
    dm:openDoor(id)
    dm:update(0.1)
    local door = dm:getDoor(id)
    print("door=" .. tostring(door ~= nil))
    dm:closeDoor(id)
    print("type=" .. dm:type())
    print("typeOf=" .. tostring(dm:typeOf("LDoorManager")))
end

--@api-stub: LHeightMap:ceilingAt
--@api-stub: LHeightMap:floorAt
--@api-stub: LHeightMap:setCeiling
--@api-stub: LHeightMap:setFloor
-- Height map floor/ceiling queries and mutation.
do
    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(3, 3, 0.2)
    hm:setCeiling(3, 3, 0.9)
    print("floor=" .. hm:floorAt(3, 3))
    print("ceiling=" .. hm:ceilingAt(3, 3))
    print("type=" .. hm:type())
    print("typeOf=" .. tostring(hm:typeOf("LHeightMap")))
end

--@api-stub: LPointLight:color
--@api-stub: LPointLight:intensity
--@api-stub: LPointLight:radius
--@api-stub: LPointLight:x
--@api-stub: LPointLight:y
-- Point light queries, mutation, and type introspection.
do
    local pl = lurek.raycaster.newPointLight(8, 8, 1, 1, 0.8, 5.0, 2.0)
    print("x=" .. pl:x())
    print("y=" .. pl:y())
    print("radius=" .. pl:radius())
    print("intensity=" .. pl:intensity())
    local r, g, b = pl:color()
    print("color=" .. r .. "," .. g .. "," .. b)
    pl:set(10, 10, 1, 0.8, 0.6, 6.0, 3.0)
    print("type=" .. pl:type())
    print("typeOf=" .. tostring(pl:typeOf("LPointLight")))
end

--@api-stub: LSpriteManager:add
--@api-stub: LSpriteManager:remove
--@api-stub: LSpriteManager:setPosition
--@api-stub: LSpriteManager:setVisible
-- Sprite manager operations and type introspection.
do
    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "assets/textures/ray_water.png", 1.0)
    sm:setPosition(id, 6, 6)
    sm:setVisible(id, true)
    sm:sortAndProject(8, 8, 0.0)
    sm:remove(id)
    sm:clear()
    print("type=" .. sm:type())
    print("typeOf=" .. tostring(sm:typeOf("LSpriteManager")))
end

print("raycaster_02.lua")
