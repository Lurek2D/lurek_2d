--- Minimap Module Part 3: textures, display size, grid size, camera tracking, type

--@api-stub: LMinimap:getDisplaySize
--@api-stub: LMinimap:getGridSize
-- Display and grid dimension queries.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(32, 32, 200, 200)
    local dw, dh = mm:getDisplaySize()
    local gw, gh = mm:getGridSize()
    print("display=" .. dw .. "x" .. dh)
    print("grid=" .. gw .. "x" .. gh)
end

--@api-stub: LMinimap:setMarkerTexture
--@api-stub: LMinimap:clearMarkerTexture
-- Assign and clear a texture for a named marker.
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
--@api-stub: LMinimap:clearObjectTypeTexture
-- Assign and clear a texture for an object type.
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
--@api-stub: LMinimap:typeOf
-- Type introspection on LMinimap.
do
    ---@type LMinimap
    local mm = lurek.minimap.newMinimap(16, 16)
    print(mm:type())
    print(mm:typeOf("LMinimap"))
    print(mm:typeOf("Object"))
end

print("minimap_02.lua")
