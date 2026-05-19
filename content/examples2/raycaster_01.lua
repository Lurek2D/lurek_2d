--- Raycaster Module Part 2: doors, height maps, lights, sprites, floor/ceiling, scene building, minimap

--@api-stub: lurek.raycaster.newDoorManager
--@api-stub: lurek.addDoor
--@api-stub: lurek.openDoor
--@api-stub: lurek.closeDoor
-- Door management for raycaster maps.
do
    ---@type LDoorManager
    local doors = lurek.raycaster.newDoorManager()
    local idx1 = doors:addDoor(5, 3, "north", 2.0)
    local idx2 = doors:addDoor(8, 6, "east", 1.5)
    print("door 1 idx = " .. idx1)
    print("door 2 idx = " .. idx2)
    print("total doors = " .. doors:count())
    doors:openDoor(idx1)
    doors:update(0.5)
    local d = doors:getDoor(idx1)
    print("door 1: state=" .. d.state .. " open=" .. d.openAmount)
    doors:closeDoor(idx1)
    doors:update(1.0)
    d = doors:getDoor(idx1)
    print("after close: state=" .. d.state)
end

--@api-stub: LDoorManager:getDoor
--@api-stub: LDoorManager:update cycle
-- Full door open/close animation cycle.
do
    ---@type LDoorManager
    local doors = lurek.raycaster.newDoorManager()
    local idx = doors:addDoor(3, 3, "south", 4.0)
    doors:openDoor(idx)
    for i = 1, 10 do
        doors:update(0.1)
    end
    local d = doors:getDoor(idx)
    print("after 1s: open=" .. string.format("%.2f", d.openAmount))
    doors:closeDoor(idx)
    for i = 1, 10 do
        doors:update(0.1)
    end
    d = doors:getDoor(idx)
    print("after close 1s: open=" .. string.format("%.2f", d.openAmount))
end

--@api-stub: LDoorManager:type
--@api-stub: LDoorManager:typeOf
-- Door manager type.
do
    ---@type LDoorManager
    local doors = lurek.raycaster.newDoorManager()
    print("type = " .. doors:type())
    print("is LDoorManager = " .. tostring(doors:typeOf("LDoorManager")))
end

--@api-stub: lurek.raycaster.newHeightMap
--@api-stub: lurek.setFloor
--@api-stub: lurek.setCeiling
--@api-stub: lurek.floorAt
--@api-stub: lurek.ceilingAt
-- Height map for variable floor/ceiling heights.
do
    ---@type LHeightMap
    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(5, 5, -0.3)
    hm:setCeiling(5, 5, 0.8)
    hm:setFloor(10, 10, 0.2)
    hm:setCeiling(10, 10, 1.5)
    print("floor at 5,5 = " .. hm:floorAt(5, 5))
    print("ceiling at 5,5 = " .. hm:ceilingAt(5, 5))
    print("floor at 0,0 = " .. hm:floorAt(0, 0))
    print("ceiling at 0,0 = " .. hm:ceilingAt(0, 0))
end

--@api-stub: LHeightMap stepped terrain
-- Creating stepped terrain (staircase).
do
    ---@type LHeightMap
    local hm = lurek.raycaster.newHeightMap(8, 8)
    for x = 0, 7 do
        local height = x * 0.1
        for y = 0, 7 do
            hm:setFloor(x, y, height)
            hm:setCeiling(x, y, 1.0 + height)
        end
    end
    print("stair start floor = " .. hm:floorAt(0, 0))
    print("stair end floor = " .. hm:floorAt(7, 0))
end

--@api-stub: LHeightMap:type
--@api-stub: LHeightMap:typeOf
-- Height map type.
do
    ---@type LHeightMap
    local hm = lurek.raycaster.newHeightMap(4, 4)
    print("type = " .. hm:type())
    print("is LHeightMap = " .. tostring(hm:typeOf("LHeightMap")))
end

--@api-stub: lurek.raycaster.newPointLight
-- Point lights for dynamic lighting.
do
    ---@type LPointLight
    local torch = lurek.raycaster.newPointLight(5.5, 3.5, 1.0, 0.8, 0.4, 4.0, 1.5)
    print("pos = " .. torch:x() .. ", " .. torch:y())
    local r, g, b = torch:color()
    print("color = " .. r .. "," .. g .. "," .. b)
    print("radius = " .. torch:radius())
    print("intensity = " .. torch:intensity())
end

--@api-stub: LPointLight:set
-- Updating a light dynamically.
do
    ---@type LPointLight
    local light = lurek.raycaster.newPointLight(2, 2, 1, 1, 1, 3, 1.0)
    light:set(8, 8, 0, 0, 1, 6, 2.0)
    print("moved to " .. light:x() .. "," .. light:y())
    print("new radius = " .. light:radius())
    print("new intensity = " .. light:intensity())
end

--@api-stub: LPointLight:type
--@api-stub: LPointLight:typeOf
-- Point light type.
do
    ---@type LPointLight
    local light = lurek.raycaster.newPointLight(0, 0, 1, 1, 1, 1, 1)
    print("type = " .. light:type())
    print("is LPointLight = " .. tostring(light:typeOf("LPointLight")))
end

--@api-stub: lurek.raycaster.newSpriteManager
--@api-stub: lurek.add
--@api-stub: lurek.setPosition
-- Sprite management for billboard objects in the raycaster.
do
    ---@type LSpriteManager
    local sprites = lurek.raycaster.newSpriteManager()
    local barrel = sprites:add(5.5, 3.5, "barrel", 1.0)
    local torch = sprites:add(8.5, 2.5, "torch", 0.5)
    local enemy = sprites:add(10.5, 7.5, "enemy", 1.2)
    print("barrel id = " .. barrel)
    print("torch id = " .. torch)
    sprites:setPosition(enemy, 11, 8)
    sprites:setVisible(torch, false)
    sprites:remove(barrel)
    print("sprite manager ready")
end

--@api-stub: LSpriteManager:sortAndProject
-- Sort and project sprites for rendering order.
do
    ---@type LSpriteManager
    local sprites = lurek.raycaster.newSpriteManager()
    sprites:add(3, 3, "crate")
    sprites:add(6, 6, "pillar")
    sprites:add(9, 9, "lamp")
    local order = sprites:sortAndProject(5, 5, 0)
    print("render order = " .. #order .. " sprites")
    for i, id in ipairs(order) do
        print("  draw " .. i .. ": sprite " .. id)
    end
end

--@api-stub: LSpriteManager:clear
--@api-stub: LSpriteManager:type
--@api-stub: LSpriteManager:typeOf
-- Sprite manager lifecycle.
do
    ---@type LSpriteManager
    local sprites = lurek.raycaster.newSpriteManager()
    sprites:add(1, 1, "item")
    sprites:add(2, 2, "item")
    sprites:clear()
    print("type = " .. sprites:type())
    print("is LSpriteManager = " .. tostring(sprites:typeOf("LSpriteManager")))
end

--@api-stub: LRaycaster:setFloorTextureCell
--@api-stub: LRaycaster:getFloorTextureCell
-- Per-cell floor textures (expects LImage or nil).
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(8, 8)
    ---@type LImage
    local floorTex = lurek.graphics.newImage("assets/textures/ray_water.png")
    map:setFloorTextureCell(3, 3, floorTex)
    map:setFloorTextureCell(4, 4, floorTex)
    print("floor at 3,3 = " .. tostring(map:getFloorTextureCell(3, 3)))
    print("floor at 0,0 = " .. tostring(map:getFloorTextureCell(0, 0)))
end

--@api-stub: LRaycaster:setCeilingTextureCell
--@api-stub: LRaycaster:getCeilingTextureCell
-- Per-cell ceiling textures (expects LImage or nil to clear).
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(8, 8)
    ---@type LImage
    local ceilTex = lurek.graphics.newImage("assets/textures/ray_water.png")
    map:setCeilingTextureCell(2, 2, ceilTex)
    map:setCeilingTextureCell(5, 5, ceilTex)
    print("ceiling at 2,2 = " .. tostring(map:getCeilingTextureCell(2, 2)))
    print("ceiling at 5,5 = " .. tostring(map:getCeilingTextureCell(5, 5)))
    map:setCeilingTextureCell(2, 2, nil)
    print("cleared ceiling at 2,2 = " .. tostring(map:getCeilingTextureCell(2, 2)))
end

--@api-stub: LRaycaster:setLoweredFloorCell
--@api-stub: LRaycaster:getLoweredFloorCell
-- Lowered floor cells (pits, water).
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(8, 8)
    map:setLoweredFloorCell(4, 4, {
        texture = 2,
        depth = 0.3,
        r = 0,
        g = 100,
        b = 200,
        blocked = false
    })
    local cell = map:getLoweredFloorCell(4, 4)
    if cell then
        print("lowered: texture=" .. cell.texture .. " depth=" .. cell.depth)
        print("color = " .. cell.r .. "," .. cell.g .. "," .. cell.b)
        print("blocked = " .. tostring(cell.blocked))
    end
    local empty = map:getLoweredFloorCell(0, 0)
    print("no lowered at 0,0 = " .. tostring(empty))
end

--@api-stub: LRaycaster:computeTileLight
-- Compute lighting for a specific tile.
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(16, 16)
    ---@type LPointLight
    local light1 = lurek.raycaster.newPointLight(8, 8, 1.0, 0.9, 0.7, 5.0, 2.0)
    ---@type LPointLight
    local light2 = lurek.raycaster.newPointLight(3, 3, 0.2, 0.5, 1.0, 3.0, 1.0)
    local r, g, b, luma = map:computeTileLight(7, 8, 0.1, { light1, light2 })
    print("tile light: r=" .. string.format("%.2f", r) ..
        " g=" .. string.format("%.2f", g) ..
        " b=" .. string.format("%.2f", b) ..
        " luma=" .. string.format("%.2f", luma))
end

--@api-stub: LRaycaster:buildScene
-- Build a renderable scene from the map.
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(16, 16)
    for x = 0, 15 do
        map:setCell(x, 0, 1)
        map:setCell(x, 15, 1)
    end
    for y = 0, 15 do
        map:setCell(0, y, 1)
        map:setCell(15, y, 1)
    end
    local params = {
        cam_x = 8,
        cam_y = 8,
        cam_angle = 0,
        fov = math.pi / 3,
        screen_w = 320,
        screen_h = 200,
        max_dist = 16
    }
    local numQuads = map:buildScene(params)
    print("scene quads = " .. numQuads)
end

--@api-stub: LRaycaster:buildMinimapWindow
-- Build a circular minimap around the player.
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(16, 16)
    for x = 0, 15 do
        map:setCell(x, 0, 1)
        map:setCell(x, 15, 1)
    end
    for y = 0, 15 do
        map:setCell(0, y, 1)
        map:setCell(15, y, 1)
    end
    map:setCell(5, 8, 1)
    local cells = map:buildMinimapWindow(8, 8, 5, 0.2)
    print("minimap cells = " .. #cells)
    for i = 1, math.min(3, #cells) do
        local c = cells[i]
        print("  " .. c.x .. "," .. c.y ..
            " blocked=" .. tostring(c.blocked) ..
            " visible=" .. tostring(c.visible) ..
            " luma=" .. string.format("%.2f", c.luma))
    end
end

--@api-stub: LRaycaster:projectSprite
-- Project a sprite position to screen coordinates.
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(16, 16)
    local proj = map:projectSprite(10, 8, 8, 8, 0, math.pi / 3, 320)
    print("screen_x = " .. proj.screen_x)
    print("scale = " .. string.format("%.2f", proj.scale))
    print("distance = " .. string.format("%.2f", proj.distance))
    print("visible = " .. tostring(proj.visible))
end

--@api-stub: LRaycaster:drawLineOfSight
-- Visualize line-of-sight between two points.
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(8, 8)
    map:setCell(4, 4, 1)
    ---@type LImageData
    local img = map:drawLineOfSight(1, 1, 7, 7, 16)
    print("LOS image created")
end

--@api-stub: LRaycaster:drawCameraSweep
-- Generate an animated camera sweep.
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(8, 8)
    for x = 0, 7 do
        map:setCell(x, 0, 1)
        map:setCell(x, 7, 1)
    end
    for y = 0, 7 do
        map:setCell(0, y, 1)
        map:setCell(7, y, 1)
    end
    ---@type LImageData
    local strip = map:drawCameraSweep(4, 4, math.pi / 3, 8, 8, 160, 100)
    print("camera sweep strip created")
end

--@api-stub: LRaycaster:castFloorRow
-- Cast a single floor row for textured floor rendering.
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(16, 16)
    local dirX = math.cos(0)
    local dirY = math.sin(0)
    local planeX = -dirY * 0.66
    local planeY = dirX * 0.66
    local uvs = map:castFloorRow(8, 8, dirX, dirY, planeX, planeY, 150)
    print("floor UVs = " .. #uvs)
    if #uvs > 0 then
        print("first UV: u=" .. string.format("%.2f", uvs[1].u) ..
            " v=" .. string.format("%.2f", uvs[1].v))
    end
end

print("raycaster_01.lua")
