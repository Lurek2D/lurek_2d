-- content/examples/raycaster.lua
-- Auto-generated from content/examples2/raycaster_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/raycaster.lua

--@api-stub: lurek.raycaster.new
do
    local map = lurek.raycaster.new(16, 16)
    print("width = " .. map:width())
    print("height = " .. map:height())
end

--@api-stub: lurek.raycaster.newMap
do
    local map = lurek.raycaster.newMap(32, 32)
    print("width = " .. map:width())
    print("height = " .. map:height())
end

--@api-stub: LRaycaster:setCell
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(0, 0, 1)
    print("cell(0,0) = " .. map:getCell(0, 0))
    print("blocked = " .. tostring(map:isBlocked(0, 0)))
end

--@api-stub: LRaycaster:getCell
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(0, 0, 1)
    local value = map:getCell(0, 0)
    local empty = map:getCell(7, 7)

    print("cell(0,0) = " .. value)
    print("cell(7,7) = " .. empty)
end

--@api-stub: LRaycaster:setCells
do
    local map = lurek.raycaster.new(8, 8)
    local cells = {}

    for i = 1, 64 do
        cells[i] = 0
    end

    for i = 1, 8 do
        cells[i] = 1
    end

    map:setCells(cells)
    print("cell(0,0) = " .. map:getCell(0, 0))
    print("cell(0,1) = " .. map:getCell(0, 1))
end

--@api-stub: LRaycaster:isBlocked
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(3, 3, 1)

    print("cell(3,3) blocked = " .. tostring(map:isBlocked(3, 3)))
    print("cell(2,2) blocked = " .. tostring(map:isBlocked(2, 2)))
end

--@api-stub: LRaycaster:isWalkBlocked
do
    local map = lurek.raycaster.new(8, 8)
    local pit_texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setLoweredFloorCell(3, 3, {
        texture = pit_texture,
        depth = 0.3,
        blocked = true,
    })

    print("cell(3,3) walk blocked = " .. tostring(map:isWalkBlocked(3, 3)))
    print("cell(2,2) walk blocked = " .. tostring(map:isWalkBlocked(2, 2)))
end

--@api-stub: LRaycaster:castRay
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local hit = map:castRay(8, 8, 0, 20)

    if hit then
        print("distance = " .. string.format("%.2f", hit.distance))
        print("cell = " .. hit.cell_value .. " side = " .. hit.side)
    end
end

--@api-stub: LRaycaster:castRays
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local hits = map:castRays(8, 8, 0, math.pi / 3, 10, 20)

    print("ray count = " .. #hits)
    if hits[1] then
        print("first distance = " .. string.format("%.2f", hits[1].distance))
    end
end

--@api-stub: LRaycaster:castRaysFlat
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local flat = map:castRaysFlat(8, 8, 0, math.pi / 3, 6, 20)

    print("flat value count = " .. #flat)
    print("first ray distance = " .. string.format("%.2f", flat[1] or 0))
    print("first ray cell = " .. tostring(flat[2]))
end

--@api-stub: LRaycaster:castRayMulti
do
    local map = lurek.raycaster.new(16, 16)
    map:setCell(5, 8, 2)
    map:setCell(10, 8, 1)
    map:setWallAlpha(2, 0.5)

    local hits = map:castRayMulti(2, 8.5, 0, 20, 4)

    print("hit count = " .. #hits)
    if hits[1] then
        print("first distance = " .. string.format("%.2f", hits[1].distance))
        print("first cell = " .. hits[1].cell_value)
    end
end

--@api-stub: LRaycaster:setWallAlpha
do
    local map = lurek.raycaster.new(8, 8)
    map:setWallAlpha(2, 0.5)

    print("alpha(2) = " .. map:getWallAlpha(2))
end

--@api-stub: LRaycaster:getWallAlpha
do
    local map = lurek.raycaster.new(8, 8)
    map:setWallAlpha(2, 0.5)

    print("alpha(2) = " .. map:getWallAlpha(2))
    print("alpha(9) = " .. map:getWallAlpha(9))
end

--@api-stub: LRaycaster:tryMove
do
    local map = lurek.raycaster.new(8, 8)
    for i = 0, 7 do
        map:setCell(i, 0, 1)
        map:setCell(i, 7, 1)
        map:setCell(0, i, 1)
        map:setCell(7, i, 1)
    end

    local nx, ny, moved = map:tryMove(4.5, 4.5, 0.25, 0)
    local wx, wy, blocked = map:tryMove(0.5, 0.5, -1, 0)

    print("free move = " .. tostring(moved) .. " -> " .. nx .. "," .. ny)
    print("wall move = " .. tostring(blocked) .. " -> " .. wx .. "," .. wy)
end

--@api-stub: LRaycaster:gridMove
do
    local map = lurek.raycaster.new(8, 8)
    for i = 0, 7 do
        map:setCell(i, 0, 1)
        map:setCell(i, 7, 1)
        map:setCell(0, i, 1)
        map:setCell(7, i, 1)
    end

    local nx, ny, moved = map:gridMove(4.5, 4.5, 2, "forward", 1.0)
    local sx, sy, strafe = map:gridMove(nx, ny, 2, "left", 1.0)

    print("forward = " .. tostring(moved) .. " -> " .. nx .. "," .. ny)
    print("left = " .. tostring(strafe) .. " -> " .. sx .. "," .. sy)
end

--@api-stub: LRaycaster:lineOfSight
do
    local map = lurek.raycaster.new(16, 16)
    map:setCell(8, 8, 1)

    local clear = map:lineOfSight(4, 4, 12, 4)
    local blocked = map:lineOfSight(4, 8, 12, 8)

    print("clear = " .. tostring(clear))
    print("blocked = " .. tostring(blocked))
end

--@api-stub: LRaycaster:revealCellsFromRays
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    map:setCell(6, 8, 1)
    local revealed = map:revealCellsFromRays(8, 8, 0, math.pi * 2, 64, 10)

    print("revealed count = " .. #revealed)
    if revealed[1] then
        print("first cell = " .. revealed[1].x .. "," .. revealed[1].y)
    end
end

--@api-stub: LRaycaster:drawView
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local img = map:drawView(8, 8, 0, math.pi / 3, 320, 200, 16)

    print("width = " .. img:getWidth())
    print("height = " .. img:getHeight())
end

--@api-stub: LRaycaster:drawTopDown
do
    local map = lurek.raycaster.new(8, 8)
    for i = 0, 7 do
        map:setCell(i, 0, 1)
        map:setCell(i, 7, 1)
        map:setCell(0, i, 1)
        map:setCell(7, i, 1)
    end

    map:setCell(3, 3, 1)

    local img = map:drawTopDown(4.5, 4.5, 0, 16)

    print("width = " .. img:getWidth())
    print("height = " .. img:getHeight())
end

--@api-stub: LRaycaster:drawDepthMap
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local depth = map:drawDepthMap(8, 8, 0, math.pi / 3, 160, 160, 100, 16)

    print("width = " .. depth:getWidth())
    print("height = " .. depth:getHeight())
end

--@api-stub: lurek.raycaster.distanceShade
do
    local near = lurek.raycaster.distanceShade(0, 10)
    local mid = lurek.raycaster.distanceShade(5, 10)
    local far = lurek.raycaster.distanceShade(9, 10)

    print("near = " .. string.format("%.2f", near))
    print("mid = " .. string.format("%.2f", mid))
    print("far = " .. string.format("%.2f", far))
end

--@api-stub: lurek.raycaster.projectColumn
do
    local height, top, bottom = lurek.raycaster.projectColumn(5.0, math.pi / 3, 200)

    print("height = " .. string.format("%.1f", height))
    print("top = " .. string.format("%.1f", top))
    print("bottom = " .. string.format("%.1f", bottom))
end

--@api-stub: LRaycaster:type
do
    local map = lurek.raycaster.new(8, 8)
    print("type = " .. map:type())
end

--@api-stub: LRaycaster:typeOf
do
    local map = lurek.raycaster.new(8, 8)
    print("LRaycaster = " .. tostring(map:typeOf("LRaycaster")))
    print("LObject = " .. tostring(map:typeOf("LObject")))
end

--- Raycaster Module Part 2: doors, height maps, lights, sprites, floor/ceiling, scene building, minimap

--@api-stub: lurek.raycaster.newDoorManager
do
    local doors = lurek.raycaster.newDoorManager()
    local first = doors:addDoor(5, 3, "horizontal", 2.0)
    local second = doors:addDoor(8, 6, "vertical", 1.5)

    print("first id = " .. first)
    print("second id = " .. second)
    print("count = " .. doors:count())
end

--@api-stub: LDoorManager:getDoor
do
    local doors = lurek.raycaster.newDoorManager()
    local idx = doors:addDoor(3, 3, "vertical", 4.0)

    doors:openDoor(idx)
    for _ = 1, 10 do
        doors:update(0.1)
    end

    local door = doors:getDoor(idx)

    print("state = " .. door.state)
    print("open = " .. string.format("%.2f", door.openAmount))
end

--@api-stub: LDoorManager:type
do
    local doors = lurek.raycaster.newDoorManager()
    print("type = " .. doors:type())
end

--@api-stub: LDoorManager:typeOf
do
    local doors = lurek.raycaster.newDoorManager()
    print("LDoorManager = " .. tostring(doors:typeOf("LDoorManager")))
    print("LObject = " .. tostring(doors:typeOf("LObject")))
end

--@api-stub: lurek.raycaster.newHeightMap
do
    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(5, 5, -0.3)
    hm:setCeiling(5, 5, 0.8)
    hm:setFloor(10, 10, 0.2)
    hm:setCeiling(10, 10, 1.5)

    print("floor(5,5) = " .. hm:floorAt(5, 5))
    print("ceiling(10,10) = " .. hm:ceilingAt(10, 10))
end

--@api-stub: LHeightMap:type
do
    local hm = lurek.raycaster.newHeightMap(4, 4)
    print("type = " .. hm:type())
end

--@api-stub: LHeightMap:typeOf
do
    local hm = lurek.raycaster.newHeightMap(4, 4)
    print("LHeightMap = " .. tostring(hm:typeOf("LHeightMap")))
    print("LObject = " .. tostring(hm:typeOf("LObject")))
end

--@api-stub: lurek.raycaster.newPointLight
do
    local torch = lurek.raycaster.newPointLight(5.5, 3.5, 1.0, 0.8, 0.4, 4.0, 1.5)
    local r, g, b = torch:color()

    print("pos = " .. torch:x() .. "," .. torch:y())
    print("color = " .. r .. "," .. g .. "," .. b)
    print("radius = " .. torch:radius() .. " intensity = " .. torch:intensity())
end

--@api-stub: LPointLight:set
do
    local light = lurek.raycaster.newPointLight(2, 2, 1, 1, 1, 3, 1.0)
    light:set(8, 8, 0, 0, 1, 6, 2.0)
    local r, g, b = light:color()

    print("pos = " .. light:x() .. "," .. light:y())
    print("color = " .. r .. "," .. g .. "," .. b)
    print("radius = " .. light:radius() .. " intensity = " .. light:intensity())
end

--@api-stub: LPointLight:type
do
    local light = lurek.raycaster.newPointLight(0, 0, 1, 1, 1, 1, 1)
    print("type = " .. light:type())
end

--@api-stub: LPointLight:typeOf
do
    local light = lurek.raycaster.newPointLight(0, 0, 1, 1, 1, 1, 1)
    print("LPointLight = " .. tostring(light:typeOf("LPointLight")))
    print("LObject = " .. tostring(light:typeOf("LObject")))
end

--@api-stub: lurek.raycaster.newSpriteManager
do
    local sprites = lurek.raycaster.newSpriteManager()
    local barrel = sprites:add(5.5, 3.5, "content/examples/assets/images/sample_texture.png", 1.0)
    local torch = sprites:add(8.5, 2.5, "content/examples/assets/images/sample_texture.png", 0.5)
    local enemy = sprites:add(10.5, 7.5, "content/examples/assets/images/sample_texture.png", 1.2)

    sprites:setPosition(enemy, 11, 8)
    sprites:setVisible(torch, false)
    sprites:remove(barrel)

    print("torch id = " .. torch)
    print("enemy id = " .. enemy)
end

--@api-stub: LSpriteManager:sortAndProject
do
    local sprites = lurek.raycaster.newSpriteManager()
    sprites:add(3, 3, "content/examples/assets/images/sample_texture.png")
    sprites:add(6, 6, "content/examples/assets/images/sample_texture.png")
    sprites:add(9, 9, "content/examples/assets/images/sample_texture.png")

    local order = sprites:sortAndProject(5, 5, 0)

    print("projected count = " .. #order)
    if order[1] then
        print("first id = " .. order[1].id)
        print("first distance = " .. string.format("%.2f", order[1].distance))
    end
end

--@api-stub: LSpriteManager:clear
do
    local sprites = lurek.raycaster.newSpriteManager()
    sprites:add(1, 1, "content/examples/assets/images/sample_texture.png")
    sprites:add(2, 2, "content/examples/assets/images/sample_texture.png")
    sprites:clear()

    local order = sprites:sortAndProject(0, 0, 0)

    print("projected count = " .. #order)
end

--@api-stub: LSpriteManager:type
do
    local sprites = lurek.raycaster.newSpriteManager()
    print("type = " .. sprites:type())
end

--@api-stub: LSpriteManager:typeOf
do
    local sprites = lurek.raycaster.newSpriteManager()
    print("LSpriteManager = " .. tostring(sprites:typeOf("LSpriteManager")))
    print("LObject = " .. tostring(sprites:typeOf("LObject")))
end

--@api-stub: LRaycaster:setFloorTextureCell
do
    local map = lurek.raycaster.new(8, 8)
    local floor_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setFloorTextureCell(3, 3, floor_tex)

    print("raw id = " .. tostring(map:getFloorTextureCell(3, 3)))
end

--@api-stub: LRaycaster:getFloorTextureCell
do
    local map = lurek.raycaster.new(8, 8)
    local floor_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setFloorTextureCell(3, 3, floor_tex)

    print("floor(3,3) = " .. tostring(map:getFloorTextureCell(3, 3)))
    print("floor(0,0) = " .. tostring(map:getFloorTextureCell(0, 0)))
end

--@api-stub: LRaycaster:setCeilingTextureCell
do
    local map = lurek.raycaster.new(8, 8)
    local ceil_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setCeilingTextureCell(2, 2, ceil_tex)

    print("raw id = " .. tostring(map:getCeilingTextureCell(2, 2)))
end

--@api-stub: LRaycaster:getCeilingTextureCell
do
    local map = lurek.raycaster.new(8, 8)
    local ceil_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setCeilingTextureCell(2, 2, ceil_tex)

    print("ceiling(2,2) = " .. tostring(map:getCeilingTextureCell(2, 2)))
    print("ceiling(0,0) = " .. tostring(map:getCeilingTextureCell(0, 0)))
end

--@api-stub: LRaycaster:setLoweredFloorCell
do
    local map = lurek.raycaster.new(8, 8)
    local pit_texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setLoweredFloorCell(4, 4, {
        texture = pit_texture,
        depth = 0.3,
        r = 0.1,
        g = 0.4,
        b = 0.8,
        blocked = false,
    })

    local cell = map:getLoweredFloorCell(4, 4)

    print("depth = " .. cell.depth)
    print("blocked = " .. tostring(cell.blocked))
end

--@api-stub: LRaycaster:getLoweredFloorCell
do
    local map = lurek.raycaster.new(8, 8)
    local pit_texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setLoweredFloorCell(4, 4, {
        texture = pit_texture,
        depth = 0.3,
        r = 0.1,
        g = 0.4,
        b = 0.8,
        blocked = false,
    })

    local cell = map:getLoweredFloorCell(4, 4)

    if cell then
        print("texture = " .. tostring(cell.texture))
        print("depth = " .. cell.depth)
        print("blocked = " .. tostring(cell.blocked))
    end
end

--@api-stub: LRaycaster:computeTileLight
do
    local map = lurek.raycaster.new(16, 16)
    local lights = {
        { x = 8, y = 8, r = 1.0, g = 0.9, b = 0.7, radius = 5.0, intensity = 2.0 },
        { x = 3, y = 3, r = 0.2, g = 0.5, b = 1.0, radius = 3.0, intensity = 1.0 },
    }
    local r, g, b, luma = map:computeTileLight(7, 8, 0.1, lights)

    print("r = " .. string.format("%.2f", r))
    print("g = " .. string.format("%.2f", g))
    print("luma = " .. string.format("%.2f", luma))
end

--@api-stub: LRaycaster:buildScene
do
    local map = lurek.raycaster.new(16, 16)
    local wall_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local sprite_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local params = {
        px = 8,
        py = 8,
        angle = 0,
        fov = math.pi / 3,
        rays = 64,
        max_dist = 16,
        screen_w = 320,
        screen_h = 200,
    }
    local lights = {
        { x = 8, y = 8, r = 1.0, g = 0.9, b = 0.8, radius = 4.0, intensity = 1.5 },
    }
    local sprites = {
        { x = 10.5, y = 8.0, texture = sprite_tex, size = 1.0 },
    }
    local wall_textures = {
        [1] = wall_tex,
    }
    local quad_count = map:buildScene(params, lights, sprites, wall_textures)

    print("quad count = " .. quad_count)
end

--@api-stub: LRaycaster:buildMinimapWindow
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    map:setCell(5, 8, 1)
    local lights = {
        { x = 8, y = 8, r = 1.0, g = 1.0, b = 0.8, radius = 5.0, intensity = 1.0 },
    }
    local cells = map:buildMinimapWindow(8, 8, 5, 0.2, lights)

    print("sample count = " .. #cells)
    if cells[1] then
        print("first cell = " .. cells[1].x .. "," .. cells[1].y)
        print("first luma = " .. string.format("%.2f", cells[1].luma))
    end
end

--@api-stub: LRaycaster:projectSprite
do
    local map = lurek.raycaster.new(16, 16)
    local proj = map:projectSprite(10, 8, 8, 8, 0, math.pi / 3, 320)

    print("screen_x = " .. proj.screen_x)
    print("scale = " .. string.format("%.2f", proj.scale))
    print("visible = " .. tostring(proj.visible))
end

--@api-stub: LRaycaster:drawLineOfSight
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(4, 4, 1)

    local img = map:drawLineOfSight(1, 1, 7, 7, 16)

    print("width = " .. img:getWidth())
    print("height = " .. img:getHeight())
end

--@api-stub: LRaycaster:drawCameraSweep
do
    local map = lurek.raycaster.new(8, 8)
    for i = 0, 7 do
        map:setCell(i, 0, 1)
        map:setCell(i, 7, 1)
        map:setCell(0, i, 1)
        map:setCell(7, i, 1)
    end

    local strip = map:drawCameraSweep(4, 4, math.pi / 3, 8, 8, 160, 100)

    print("width = " .. strip:getWidth())
    print("height = " .. strip:getHeight())
end

--@api-stub: LRaycaster:castFloorRow
do
    local map = lurek.raycaster.new(16, 16)
    local uvs = map:castFloorRow(8, 8, 1, 0, 0, 0.66, 150)

    print("uv count = " .. #uvs)
    if uvs[1] then
        print("first uv = " .. string.format("%.2f", uvs[1].u) .. "," .. string.format("%.2f", uvs[1].v))
    end
end

--- Raycaster Module Part 2: buildSceneWithModels, width/height, DoorManager, HeightMap, PointLight, SpriteManager

--@api-stub: LRaycaster:buildSceneWithModels
do
    local rc = lurek.raycaster.new(80, 60)
    local params = {
        px = 8,
        py = 8,
        angle = 0,
        fov = math.pi / 3,
        rays = 40,
        max_dist = 20,
        screen_w = 160,
        screen_h = 90,
    }
    local count = rc:buildSceneWithModels(params, nil, nil, nil, nil)

    print("quad count = " .. count)
end

--@api-stub: LRaycaster:height
do
    local rc = lurek.raycaster.new(160, 120)

    print("height = " .. rc:height())
    print("width = " .. rc:width())
end

--@api-stub: LRaycaster:width
do
    local rc = lurek.raycaster.new(160, 120)

    print("width = " .. rc:width())
    print("height = " .. rc:height())
end

--@api-stub: LDoorManager:addDoor
do
    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    local door = dm:getDoor(id)

    print("count = " .. dm:count())
    print("state = " .. door.state)
end

--@api-stub: LDoorManager:closeDoor
do
    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    dm:openDoor(id)
    dm:update(0.5)
    dm:closeDoor(id)
    dm:update(0.25)

    local door = dm:getDoor(id)

    print("state = " .. door.state)
    print("open = " .. string.format("%.2f", door.openAmount))
end

--@api-stub: LDoorManager:count
do
    local dm = lurek.raycaster.newDoorManager()
    dm:addDoor(5, 5, "horizontal", 0.5)
    dm:addDoor(6, 5, "vertical", 0.25)

    print("count = " .. dm:count())
end

--@api-stub: LDoorManager:openDoor
do
    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    dm:openDoor(id)
    dm:update(0.1)

    local door = dm:getDoor(id)

    print("state = " .. door.state)
    print("open = " .. string.format("%.2f", door.openAmount))
end

--@api-stub: LDoorManager:update
do
    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    dm:openDoor(id)
    dm:update(0.1)

    local door = dm:getDoor(id)

    print("state = " .. door.state)
    print("open = " .. string.format("%.2f", door.openAmount))
end

--@api-stub: LHeightMap:ceilingAt
do
    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(3, 3, 0.2)
    hm:setCeiling(3, 3, 0.9)

    print("ceiling = " .. hm:ceilingAt(3, 3))
end

--@api-stub: LHeightMap:floorAt
do
    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(3, 3, 0.2)
    hm:setCeiling(3, 3, 0.9)

    print("floor = " .. hm:floorAt(3, 3))
end

--@api-stub: LHeightMap:setCeiling
do
    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setCeiling(3, 3, 0.9)

    print("ceiling = " .. hm:ceilingAt(3, 3))
end

--@api-stub: LHeightMap:setFloor
do
    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(3, 3, 0.2)

    print("floor = " .. hm:floorAt(3, 3))
end

--@api-stub: LPointLight:color
do
    local pl = lurek.raycaster.newPointLight(8, 8, 1, 1, 0.8, 5.0, 2.0)
    local r, g, b = pl:color()

    print("color = " .. r .. "," .. g .. "," .. b)
end

--@api-stub: LPointLight:intensity
do
    local pl = lurek.raycaster.newPointLight(8, 8, 1, 1, 0.8, 5.0, 2.0)

    print("intensity = " .. pl:intensity())
end

--@api-stub: LPointLight:radius
do
    local pl = lurek.raycaster.newPointLight(8, 8, 1, 1, 0.8, 5.0, 2.0)

    print("radius = " .. pl:radius())
end

--@api-stub: LPointLight:x
do
    local pl = lurek.raycaster.newPointLight(8, 8, 1, 1, 0.8, 5.0, 2.0)

    print("x = " .. pl:x())
end

--@api-stub: LPointLight:y
do
    local pl = lurek.raycaster.newPointLight(8, 8, 1, 1, 0.8, 5.0, 2.0)

    print("y = " .. pl:y())
end

--@api-stub: LSpriteManager:add
do
    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)

    print("sprite id = " .. id)
end

--@api-stub: LSpriteManager:remove
do
    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    sm:remove(id)

    local projected = sm:sortAndProject(0, 0, 0)

    print("remaining projected = " .. #projected)
end

--@api-stub: LSpriteManager:setPosition
do
    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    sm:setPosition(id, 6, 6)

    local projected = sm:sortAndProject(0, 0, 0)

    print("first x = " .. projected[1].x)
    print("first y = " .. projected[1].y)
end

--@api-stub: LSpriteManager:setVisible
do
    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    sm:setVisible(id, false)

    local projected = sm:sortAndProject(0, 0, 0)

    print("projected count = " .. #projected)
end
