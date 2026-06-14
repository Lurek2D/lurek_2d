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

--@api-stub: LRaycaster:setHalfWallCell
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(3, 3, 1)
    map:setHalfWallCell(3, 3, 0.5)
    local feature = map:getWallFeatureCell(3, 3)

    print("kind = " .. feature.kind)
    print("height = " .. string.format("%.2f", feature.height))
end

--@api-stub: LRaycaster:setWindowCell
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(3, 3, 1)
    map:setWindowCell(3, 3, 0.3, 0.75, 0.4)
    local feature = map:getWallFeatureCell(3, 3)

    print("kind = " .. feature.kind)
    print("los = " .. tostring(map:lineOfSight(1.5, 3.5, 6.5, 3.5)))
    print("alpha = " .. string.format("%.2f", feature.alpha))
end

--@api-stub: LRaycaster:setDoorCell
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(3, 3, 1)
    map:setDoorCell(3, 3, "horizontal", 1.0)
    local feature = map:getWallFeatureCell(3, 3)

    print("kind = " .. feature.kind)
    print("direction = " .. feature.direction)
    print("blocked = " .. tostring(map:isBlocked(3, 3)))
end

--@api-stub: LRaycaster:applyDoorManager
do
    local map = lurek.raycaster.new(8, 8)
    local doors = lurek.raycaster.newDoorManager()
    map:setCell(3, 3, 2)

    local id = doors:addDoor(3, 3, "vertical", 1.0)
    map:applyDoorManager(doors)
    print("closed blocked = " .. tostring(map:isBlocked(3, 3)))

    doors:openDoor(id)
    doors:update(1.0)
    map:applyDoorManager(doors, 0.8)

    local feature = map:getWallFeatureCell(3, 3)
    print("kind = " .. feature.kind)
    print("blocked after open = " .. tostring(map:isBlocked(3, 3)))
    print("open amount = " .. string.format("%.2f", feature.open_amount))
end

--@api-stub: LRaycaster:clearWallFeatureCell
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(3, 3, 1)
    map:setWindowCell(3, 3, 0.25, 0.75, 0.35)
    map:clearWallFeatureCell(3, 3)
    print("feature cleared = " .. tostring(map:getWallFeatureCell(3, 3) == nil))
end

--@api-stub: LRaycaster:getWallFeatureCell
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    map:setCell(7, 5, 1)
    map:setHalfWallCell(7, 5, 0.5)
    map:setCell(7, 7, 1)
    map:setWindowCell(7, 7, 0.25, 0.78, 0.35)
    map:setCell(7, 9, 1)
    map:setDoorCell(7, 9, "vertical", 1.0)

    local params = {
        px = 2.5,
        py = 7.5,
        angle = 0.0,
        fov = math.pi / 3,
        rays = 64,
        max_dist = 20.0,
        screen_w = 320,
        screen_h = 200,
    }
    local picked = map:pickScreen(160, 100, params)
    local hit = map:castRay(2.5, 9.5, 0.0, 20.0)
    local solid = lurek.raycaster.new(8, 3)
    solid:setCell(4, 1, 1)
    local solid_r = select(1, solid:computeTileLight(2, 1, 0.0, {
        { x = 5.5, y = 1.5, radius = 8.0, intensity = 8.0, color = { 1.0, 0.8, 0.6 } },
    }))
    local through_window = lurek.raycaster.new(8, 3)
    through_window:setCell(4, 1, 1)
    through_window:setWindowCell(4, 1, 0.25, 0.8, 0.35)
    local window_r = select(1, through_window:computeTileLight(2, 1, 0.0, {
        { x = 5.5, y = 1.5, radius = 8.0, intensity = 8.0, color = { 1.0, 0.8, 0.6 } },
    }))

    print("window los = " .. tostring(map:lineOfSight(2.5, 7.5, 12.5, 7.5)))
    print("half wall blocked = " .. tostring(map:isBlocked(7, 5)))
    print("open door hit cell = " .. tostring(hit and hit.cell_value or "nil"))
    print("solid light r = " .. string.format("%.3f", solid_r))
    print("window light r = " .. string.format("%.3f", window_r))
    if picked then
        print("pick surface = " .. picked.surface)
        print("pick tile = " .. picked.x .. "," .. picked.y)
    end
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

--@api-stub: lurek.raycaster.applyLitShade
do
    local r, g, b = lurek.raycaster.applyLitShade(0.5, 1.0, 0.8, 0.6)
    print("lit shade = " .. r .. "," .. g .. "," .. b)
    print("red positive = " .. tostring(r > 0))
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
    local torch = lurek.raycaster.newPointLight(5.5, 3.5, 1.0, 0.8, 0.4, 4.0, 1.5, 1)
    local r, g, b = torch:color()

    print("pos = " .. torch:x() .. "," .. torch:y())
    print("color = " .. r .. "," .. g .. "," .. b)
    print("radius = " .. torch:radius() .. " intensity = " .. torch:intensity())
    print("level = " .. tostring(torch:level()))
end

--@api-stub: LPointLight:set
do
    local light = lurek.raycaster.newPointLight(2, 2, 1, 1, 1, 3, 1.0)
    light:set(8, 8, 0, 0, 1, 6, 2.0, 2)
    local r, g, b = light:color()

    print("pos = " .. light:x() .. "," .. light:y())
    print("color = " .. r .. "," .. g .. "," .. b)
    print("radius = " .. light:radius() .. " intensity = " .. light:intensity())
    print("level = " .. tostring(light:level()))
end

--@api-stub: LPointLight:level
do
    local light = lurek.raycaster.newPointLight(1, 1, 1, 1, 1, 2, 0.5, 3)
    print("light level = " .. tostring(light:level()))
end

--@api-stub: LPointLight:setLevel
do
    local light = lurek.raycaster.newPointLight(1, 1, 1, 1, 1, 2, 0.5)
    light:setLevel(1)
    print("light level after set = " .. tostring(light:level()))
    light:setLevel(nil)
    print("light level after clear = " .. tostring(light:level()))
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
    local torch = sprites:add(8.5, 2.5, "content/examples/assets/images/sample_texture.png", 0.5, 1)
    local enemy = sprites:add(10.5, 7.5, "content/examples/assets/images/sample_texture.png", 1.2)

    sprites:setPosition(enemy, 11, 8)
    sprites:setVisible(torch, false)
    sprites:remove(barrel)

    print("torch id = " .. torch)
    print("enemy id = " .. enemy)
end

--@api-stub: lurek.raycaster.newSceneAdapter
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(5.0, 4.0, "dynamic")
    body:setAngle(math.pi / 2)

    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:bindBodySprite(
        body,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        { id = 7, size = 1.3, level = 1, offset_x = 0.5 }
    )
    adapter:bindBodyLight(body, 4.0, {
        intensity = 1.2,
        color = { 1.0, 0.85, 0.5 },
        level = 1,
        offset_y = 0.4,
    })
    adapter:bindBodyModel(
        body,
        lurek.render.loadModel("content/examples/assets/models/sample_tank.obj"),
        { id = 8, level = 1, yaw_offset = 0.2, z = 0.15, scale = 0.22 }
    )

    body:setPosition(6.0, 4.5)
    local inputs = adapter:sceneInputs()
    local demo_map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        demo_map:setCell(i, 0, 1)
        demo_map:setCell(i, 15, 1)
        demo_map:setCell(0, i, 1)
        demo_map:setCell(15, i, 1)
    end
    local params = {
        px = 4.5,
        py = 4.5,
        angle = 0.0,
        fov = math.pi / 3,
        rays = 32,
        max_dist = 16.0,
        screen_w = 160,
        screen_h = 100,
    }
    local quad_count = demo_map:buildSceneFromAdapter(params, adapter, {})
    local pick = demo_map:pickScreenFromAdapter(80, 50, params, adapter)
    print("scene adapter sprites = " .. #inputs.sprites)
    print("scene adapter lights = " .. #inputs.lights)
    print("scene adapter models = " .. #inputs.models)
    print("sprite pos = " .. string.format("%.2f,%.2f", inputs.sprites[1].x, inputs.sprites[1].y))
    print("adapter buildScene quads = " .. quad_count)
    print("adapter pick = " .. tostring(pick and pick.surface or "nil"))
    if pick then
        print("adapter pick hit = " .. string.format("%.2f,%.2f", pick.hit_x, pick.hit_y))
        print("adapter pick angle = " .. tostring(pick.ray_angle))
    end
end

--@api-stub: LSceneAdapter:sceneInputs
do
    local adapter = lurek.raycaster.newSceneAdapter()
    local tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    adapter:addSprite(4.5, 3.5, tex, { id = 31, level = 1, size = 1.2 })
    adapter:addLight(5.0, 3.5, 4.0, {
        intensity = 1.1,
        color = { 1.0, 0.7, 0.4 },
        level = 1,
    })
    local inputs = adapter:sceneInputs()
    print("sceneInputs sprites = " .. #inputs.sprites)
    print("sceneInputs lights = " .. #inputs.lights)
end

--@api-stub: LSceneAdapter:addSprite
do
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addSprite(
        4.5,
        3.5,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        { id = 31, level = 1, size = 1.2 }
    )
    local sprite = adapter:sceneInputs().sprites[1]
    print("static sprite id = " .. sprite.id)
    print("static sprite pos = " .. string.format("%.2f,%.2f", sprite.x, sprite.y))
end

--@api-stub: LSceneAdapter:addDirectionalSprite
do
    local adapter = lurek.raycaster.newSceneAdapter()
    local tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    adapter:addDirectionalSprite(6.0, 3.5, tex, tex, tex, tex, {
        id = 32,
        level = 1,
        size = 1.0,
        angle = math.pi / 4,
    })
    local sprite = adapter:sceneInputs().sprites[1]
    print("directional front tex = " .. tostring(sprite.front_texture))
    print("directional angle = " .. string.format("%.3f", sprite.angle))
end

--@api-stub: LSceneAdapter:addLight
do
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addLight(5.0, 3.5, 4.0, {
        intensity = 1.1,
        color = { 1.0, 0.7, 0.4 },
        level = 1,
    })
    local light = adapter:sceneInputs().lights[1]
    print("static light radius = " .. light.radius)
    print("static light intensity = " .. light.intensity)
end

--@api-stub: LSceneAdapter:addModel
do
    local adapter = lurek.raycaster.newSceneAdapter()
    local tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    adapter:addModel(
        lurek.render.loadModel("content/examples/assets/models/sample_tank.obj"),
        7.0,
        3.5,
        { id = 33, level = 1, yaw = 0.3, z = 0.1, scale = 0.2 }
    )
    local model = adapter:sceneInputs().models[1]
    print("static model id = " .. model.id)
    print("static model yaw = " .. string.format("%.2f", model.yaw))
end

--@api-stub: LSceneAdapter:bindBodyDirectionalSprite
do
    local tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(3.0, 3.0, "dynamic")
    body:setAngle(math.pi / 2)

    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:bindBodyDirectionalSprite(body, tex, tex, tex, tex, {
        id = 34,
        offset_y = 0.5,
        angle_offset = 0.25,
    })

    local sprite = adapter:sceneInputs().sprites[1]
    print("body directional id = " .. sprite.id)
    print("body directional pos = " .. string.format("%.2f,%.2f", sprite.x, sprite.y))
    print("body directional angle = " .. string.format("%.3f", sprite.angle))
end

--@api-stub: LSceneAdapter:bindBodySprite
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(2.0, 2.0, "dynamic")
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:bindBodySprite(
        body,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        { id = 36, offset_x = 0.5 }
    )
    body:setPosition(3.0, 2.0)
    local sprite = adapter:sceneInputs().sprites[1]
    print("body sprite pos = " .. string.format("%.2f,%.2f", sprite.x, sprite.y))
end

--@api-stub: LSceneAdapter:bindBodyLight
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(2.0, 2.0, "dynamic")
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:bindBodyLight(body, 3.0, { intensity = 0.8, offset_y = 0.25 })
    body:setPosition(3.0, 2.0)
    local light = adapter:sceneInputs().lights[1]
    print("body light pos = " .. string.format("%.2f,%.2f", light.x, light.y))
end

--@api-stub: LSceneAdapter:bindBodyModel
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(2.0, 2.0, "dynamic")
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:bindBodyModel(
        body,
        lurek.render.loadModel("content/examples/assets/models/sample_tank.obj"),
        { id = 37, offset_x = 0.5, yaw_offset = 0.2, scale = 0.25 }
    )
    body:setPosition(3.0, 2.0)
    local model = adapter:sceneInputs().models[1]
    print("body model yaw = " .. string.format("%.2f", model.yaw))
end

--@api-stub: LRaycaster:buildSceneFromAdapter
do
    local map = lurek.raycaster.new(8, 8)
    for i = 0, 7 do
        map:setCell(i, 0, 1)
        map:setCell(i, 7, 1)
        map:setCell(0, i, 1)
        map:setCell(7, i, 1)
    end
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addSprite(
        4.5,
        4.0,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        { id = 38, size = 1.0 }
    )
    local count = map:buildSceneFromAdapter({
        px = 2.5,
        py = 4.0,
        angle = 0.0,
        fov = math.pi / 3,
        rays = 32,
        max_dist = 12.0,
        screen_w = 160,
        screen_h = 100,
    }, adapter, {})
    print("adapter scene quads = " .. count)
end

--@api-stub: LRaycaster:pickScreenFromAdapter
do
    local map = lurek.raycaster.new(8, 8)
    for i = 0, 7 do
        map:setCell(i, 0, 1)
        map:setCell(i, 7, 1)
        map:setCell(0, i, 1)
        map:setCell(7, i, 1)
    end
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addSprite(
        4.5,
        4.0,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        { id = 39, size = 1.0 }
    )
    local hit = map:pickScreenFromAdapter(80, 50, {
        px = 2.5,
        py = 4.0,
        angle = 0.0,
        fov = math.pi / 3,
        rays = 32,
        max_dist = 12.0,
        screen_w = 160,
        screen_h = 100,
    }, adapter)
    if hit then
        print("adapter pick id = " .. tostring(hit.id))
        print("adapter pick point = " .. string.format("%.2f,%.2f", hit.hit_x, hit.hit_y))
    end
end

--@api-stub: LSceneAdapter:clear
do
    local adapter = lurek.raycaster.newSceneAdapter()
    local tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    adapter:addSprite(1.0, 1.0, tex)
    adapter:addLight(1.0, 1.0, 2.0)
    adapter:addModel(lurek.render.loadModel("content/examples/assets/models/sample_tank.obj"), 1.0, 1.0)
    adapter:clear()
    print("adapter cleared sprites = " .. #adapter:sceneInputs().sprites)
end

--@api-stub: LSceneAdapter:clearSprites
do
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addSprite(
        1.0,
        1.0,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    )
    adapter:clearSprites()
    print("adapter sprite count = " .. #adapter:sceneInputs().sprites)
end

--@api-stub: LSceneAdapter:clearLights
do
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addLight(1.0, 1.0, 2.0)
    adapter:clearLights()
    print("adapter light count = " .. #adapter:sceneInputs().lights)
end

--@api-stub: LSceneAdapter:clearModels
do
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addModel(lurek.render.loadModel("content/examples/assets/models/sample_tank.obj"), 1.0, 1.0)
    adapter:clearModels()
    print("adapter model count = " .. #adapter:sceneInputs().models)
end

--@api-stub: LSceneAdapter:type
do
    local adapter = lurek.raycaster.newSceneAdapter()
    print("adapter type = " .. adapter:type())
end

--@api-stub: LSceneAdapter:typeOf
do
    local adapter = lurek.raycaster.newSceneAdapter()
    print("adapter is scene adapter = " .. tostring(adapter:typeOf("LSceneAdapter")))
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

--@api-stub: LSpriteManager:addDirectional
do
    local sprites = lurek.raycaster.newSpriteManager()
    local id = sprites:addDirectional(
        2.0,
        0.0,
        "front.png",
        "right.png",
        "back.png",
        "left.png",
        math.pi,
        1.0
    )
    local order = sprites:sortAndProject(0, 0, 0)

    print("sprite id = " .. id)
    print("texture = " .. order[1].texture)
    print("variant = " .. tostring(order[1].variant))
end

--@api-stub: LSpriteManager:setFacing
do
    local sprites = lurek.raycaster.newSpriteManager()
    local id = sprites:addDirectional(2.0, 0.0, "front.png", "right.png", "back.png", "left.png", math.pi, 1.0)
    sprites:setFacing(id, 0.0)
    local order = sprites:sortAndProject(0, 0, 0)

    print("texture = " .. order[1].texture)
    print("variant = " .. tostring(order[1].variant))
end

--@api-stub: LSpriteManager:setDirectionalTextures
do
    local sprites = lurek.raycaster.newSpriteManager()
    local id = sprites:add(2.0, 0.0, "old.png", 1.0)
    sprites:setDirectionalTextures(id, "front2.png", "right2.png", "back2.png", "left2.png", math.pi)
    local order = sprites:sortAndProject(0, 0, 0)

    print("texture = " .. order[1].texture)
    print("variant = " .. tostring(order[1].variant))
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
        sun_r = 0.75,
        sun_g = 0.8,
        sun_b = 1.0,
        sun_intensity = 0.85,
        sun_angle = 0.0,
        roof_darkness = 0.35,
    }
    local lights = {
        { x = 8, y = 8, r = 1.0, g = 0.9, b = 0.8, radius = 4.0, intensity = 1.5 },
    }
    local sprites = {
        {
            x = 10.5,
            y = 8.0,
            size = 1.0,
            angle = math.pi,
            front_texture = sprite_tex,
            right_texture = sprite_tex,
            back_texture = sprite_tex,
            left_texture = sprite_tex,
        },
    }
    local wall_textures = {
        [1] = wall_tex,
    }
    local quad_count = map:buildScene(params, lights, sprites, wall_textures)
    local managed = lurek.raycaster.newSpriteManager()
    managed:addDirectional(10.5, 8.0, sprite_tex, sprite_tex, sprite_tex, sprite_tex, math.pi, 1.0)
    local managed_quad_count = map:buildScene(params, lights, managed, wall_textures)

    print("quad count = " .. quad_count)
    print("managed quad count = " .. managed_quad_count)
    print("directional sprite count = " .. #sprites)
end

--@api-stub: lurek.raycaster.getLastBuildStats
do
    local map = lurek.raycaster.new(8, 8)
    local wall_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    for i = 0, 7 do
        map:setCell(i, 0, 1)
        map:setCell(i, 7, 1)
        map:setCell(0, i, 1)
        map:setCell(7, i, 1)
    end
    for y = 1, 6 do
        for x = 1, 6 do
            map:setCeilingTextureCell(x, y, wall_tex)
        end
    end

    map:buildScene({
        px = 4,
        py = 4,
        angle = 0,
        fov = math.pi / 3,
        rays = 64,
        max_dist = 10,
        screen_w = 320,
        screen_h = 200,
    }, {
        lurek.raycaster.newPointLight(4.0, 4.0, 1.0, 0.9, 0.8, 4.0, 1.25),
    }, {}, {
        [1] = wall_tex,
    })

    local stats = lurek.raycaster.getLastBuildStats()
    if stats then
        print("lighting samples = " .. stats.lightingSamples)
        print("lighting cache hits = " .. stats.lightingCacheHits)
        print("lighting cache misses = " .. stats.lightingCacheMisses)
    end
end

--@api-stub: lurek.raycaster.buildMultiLevelScene
do
    local wall_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local floor_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local ceil_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local pit_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local quad_count = lurek.raycaster.buildMultiLevelScene(
        {
            px = 0.5,
            py = 1.5,
            angle = 0,
            fov = math.pi / 3,
            rays = 64,
            max_dist = 12,
            screen_w = 320,
            screen_h = 200,
            active_level = 1,
            sun_r = 0.9,
            sun_g = 0.95,
            sun_b = 1.0,
            sun_intensity = 0.8,
            sun_angle = 0.0,
        },
        {
            {
                width = 4,
                height = 4,
                cells = {
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                },
                floor_offset = 0,
                ceiling_height = 1,
            },
            {
                width = 4,
                height = 4,
                cells = {
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                },
                floor_offset = 1,
                ceiling_height = 2,
                floor_holes = {
                    false, false, false, false,
                    false, false, false, false,
                    false, false, false, false,
                    false, false, false, false,
                },
                floor_texture = wall_tex,
                floor_cell_textures = {
                    { x = 0, y = 0, texture = floor_tex },
                },
                ceiling_cell_textures = {
                    { x = 0, y = 0, texture = ceil_tex },
                },
                lowered_floor_cells = {
                    {
                        x = 0,
                        y = 0,
                        texture = pit_tex,
                        depth = 0.35,
                        r = 0.8,
                        g = 0.7,
                        b = 0.6,
                        blocked = true,
                    },
                },
                wall_features = {
                    {
                        x = 1,
                        y = 0,
                        kind = "window",
                        sill_height = 0.25,
                        lintel_height = 0.8,
                        alpha = 0.4,
                    },
                },
            },
        },
        {},
        {},
        {},
        {
            { model = model, x = 2.5, y = 1.5, level = 1, yaw = math.pi / 6, z = 0.2, scale = 0.22 },
        }
    )

    print("stacked quad count = " .. quad_count)
end

--@api-stub: lurek.raycaster.buildMultiLevelSceneFromAdapter
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(2.5, 1.5, "dynamic")
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:bindBodySprite(
        body,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        { id = 21, level = 1, size = 1.0 }
    )
    adapter:bindBodyLight(body, 4.0, {
        level = 1,
        intensity = 1.0,
        color = { 1.0, 0.85, 0.6 },
    })
    local quad_count = lurek.raycaster.buildMultiLevelSceneFromAdapter(
        {
            px = 0.5,
            py = 1.5,
            angle = 0,
            fov = math.pi / 3,
            rays = 64,
            max_dist = 12,
            screen_w = 320,
            screen_h = 200,
            active_level = 1,
        },
        {
            {
                width = 4,
                height = 4,
                cells = {
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                },
                floor_offset = 0,
                ceiling_height = 1,
            },
            {
                width = 4,
                height = 4,
                cells = {
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                },
                floor_offset = 1,
                ceiling_height = 2,
            },
        },
        adapter,
        {}
    )

    print("stacked adapter quad count = " .. quad_count)
end

--@api-stub: lurek.raycaster.newMultiLevelGrid
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        {
            width = 2,
            height = 2,
            cells = { 0, 0, 0, 0 },
        },
    })
    print("persistent grid levels = " .. grid:levelCount())
end

--@api-stub: LMultiLevelGrid:addLevel
do
    local grid = lurek.raycaster.newMultiLevelGrid()
    local index = grid:addLevel({
        width = 2,
        height = 2,
        cells = { 0, 0, 0, 0 },
    })
    print("added level = " .. index)
end

--@api-stub: LMultiLevelGrid:levelCount
do
    local grid = lurek.raycaster.newMultiLevelGrid()
    grid:addLevel({
        width = 2,
        height = 2,
        cells = { 0, 0, 0, 0 },
    })
    print("level count = " .. grid:levelCount())
end

--@api-stub: LMultiLevelGrid:setActiveLevel
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 1, ceiling_height = 2 },
    })
    grid:setActiveLevel(1)
    print("active after set = " .. grid:activeLevel())
end

--@api-stub: LMultiLevelGrid:activeLevel
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 1, ceiling_height = 2 },
    })
    grid:setActiveLevel(1)
    print("active level = " .. grid:activeLevel())
end

--@api-stub: LMultiLevelGrid:getFloorOffset
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 1.25, ceiling_height = 2.5 },
    })
    grid:setActiveLevel(1)
    print("floor offset = " .. grid:getFloorOffset())
end

--@api-stub: LMultiLevelGrid:setFloorOffset
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 0, ceiling_height = 1 },
    })
    grid:setFloorOffset(0.75)
    print("updated floor offset = " .. grid:getFloorOffset())
end

--@api-stub: LMultiLevelGrid:getCeilingHeight
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 0.5, ceiling_height = 2.25 },
    })
    print("ceiling height = " .. grid:getCeilingHeight())
end

--@api-stub: LMultiLevelGrid:setCeilingHeight
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 0.5, ceiling_height = 1.5 },
    })
    grid:setCeilingHeight(0.55)
    print("clamped ceiling height = " .. grid:getCeilingHeight())
end

--@api-stub: LMultiLevelGrid:setCell
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setActiveLevel(1)
    grid:setCell(1, 0, 7)
    print("active cell after set = " .. grid:getCell(1, 0))
end

--@api-stub: LMultiLevelGrid:getCell
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 5, 0, 0 } },
    })
    grid:setActiveLevel(1)
    print("active cell = " .. grid:getCell(1, 0))
end

--@api-stub: LMultiLevelGrid:setHalfWallCell
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
    })
    grid:setHalfWallCell(0, 0, 0.5)
    print("half feature kind = " .. grid:getWallFeatureCell(0, 0).kind)
end

--@api-stub: LMultiLevelGrid:setWindowCell
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
    })
    grid:setWindowCell(0, 0, 0.25, 0.8, 0.4)
    print("window sill = " .. grid:getWallFeatureCell(0, 0).sill_height)
end

--@api-stub: LMultiLevelGrid:setDoorCell
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
    })
    grid:setDoorCell(0, 0, "vertical", 0.6, 0.9)
    print("door open amount = " .. grid:getWallFeatureCell(0, 0).open_amount)
end

--@api-stub: LMultiLevelGrid:clearWallFeatureCell
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
    })
    grid:setWindowCell(0, 0, 0.25, 0.8, 0.4)
    grid:clearWallFeatureCell(0, 0)
    print("feature cleared = " .. tostring(grid:getWallFeatureCell(0, 0) == nil))
end

--@api-stub: LMultiLevelGrid:getWallFeatureCell
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
    })
    print("feature absent = " .. tostring(grid:getWallFeatureCell(1, 1) == nil))
end

--@api-stub: LMultiLevelGrid:setFloorTexture
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    local floor_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    grid:setFloorTexture(floor_tex)
    print("default floor texture = " .. tostring(grid:getFloorTexture()))
    grid:setFloorTexture(nil)
    print("default floor cleared = " .. tostring(grid:getFloorTexture() == nil))
end

--@api-stub: LMultiLevelGrid:getFloorTexture
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setFloorTexture(lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    print("floor texture id = " .. tostring(grid:getFloorTexture()))
end

--@api-stub: LMultiLevelGrid:setFloorTextureCell
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setFloorTextureCell(1, 1, lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    print("floor cell texture = " .. tostring(grid:getFloorTextureCell(1, 1)))
    grid:setFloorTextureCell(1, 1, nil)
    print("floor cell cleared = " .. tostring(grid:getFloorTextureCell(1, 1) == nil))
end

--@api-stub: LMultiLevelGrid:getFloorTextureCell
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setFloorTextureCell(1, 0, lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    print("floor(1,0) texture id = " .. tostring(grid:getFloorTextureCell(1, 0)))
end

--@api-stub: LMultiLevelGrid:setCeilingTexture
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    local ceil_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    grid:setCeilingTexture(ceil_tex)
    print("default ceiling texture = " .. tostring(grid:getCeilingTexture()))
    grid:setCeilingTexture(nil)
    print("default ceiling cleared = " .. tostring(grid:getCeilingTexture() == nil))
end

--@api-stub: LMultiLevelGrid:getCeilingTexture
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setCeilingTexture(lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    print("ceiling texture id = " .. tostring(grid:getCeilingTexture()))
end

--@api-stub: LMultiLevelGrid:setCeilingTextureCell
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setCeilingTextureCell(0, 1, lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    print("ceiling cell texture = " .. tostring(grid:getCeilingTextureCell(0, 1)))
    grid:setCeilingTextureCell(0, 1, nil)
    print("ceiling cell cleared = " .. tostring(grid:getCeilingTextureCell(0, 1) == nil))
end

--@api-stub: LMultiLevelGrid:getCeilingTextureCell
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setCeilingTextureCell(0, 0, lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    print("ceiling(0,0) texture id = " .. tostring(grid:getCeilingTextureCell(0, 0)))
end

--@api-stub: LMultiLevelGrid:setLoweredFloorCell
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 4, height = 4, cells = {
            0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0,
        } },
    })
    grid:setLoweredFloorCell(2, 2, {
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        depth = 0.3,
        r = 0.8,
        g = 0.7,
        b = 0.6,
        blocked = false,
    })
    local pit = grid:getLoweredFloorCell(2, 2)
    print("pit depth = " .. pit.depth)
    grid:setLoweredFloorCell(2, 2, nil)
    print("pit cleared = " .. tostring(grid:getLoweredFloorCell(2, 2) == nil))
end

--@api-stub: LMultiLevelGrid:getLoweredFloorCell
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 4, height = 4, cells = {
            0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0,
        } },
    })
    grid:setLoweredFloorCell(1, 1, {
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        depth = 0.25,
        blocked = true,
    })
    local pit = grid:getLoweredFloorCell(1, 1)
    print("pit blocked = " .. tostring(pit.blocked))
end

--@api-stub: LMultiLevelGrid:setFloorHole
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setActiveLevel(1)
    grid:setFloorHole(1, 0, true)
    print("floor hole after set = " .. tostring(grid:isFloorHole(1, 0)))
end

--@api-stub: LMultiLevelGrid:isFloorHole
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_holes = { false, true, false, false } },
    })
    grid:setActiveLevel(1)
    print("imported floor hole = " .. tostring(grid:isFloorHole(1, 0)))
end

--@api-stub: LMultiLevelGrid:setCeilingHole
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setActiveLevel(1)
    grid:setCeilingHole(1, 1, true)
    print("ceiling hole after set = " .. tostring(grid:isCeilingHole(1, 1)))
end

--@api-stub: LMultiLevelGrid:isCeilingHole
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, ceiling_holes = { false, false, false, true } },
    })
    grid:setActiveLevel(1)
    print("imported ceiling hole = " .. tostring(grid:isCeilingHole(1, 1)))
end

--@api-stub: LMultiLevelGrid:buildScene
do
    local wall_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        {
            width = 2,
            height = 2,
            cells = { 0, 1, 0, 0 },
            floor_offset = 1,
            ceiling_height = 2,
            floor_texture = wall_tex,
        },
    })
    grid:setActiveLevel(1)
    local count = grid:buildScene(
        {
            px = 0.5,
            py = 0.5,
            angle = 0,
            fov = math.pi / 3,
            rays = 64,
            max_dist = 12,
            screen_w = 320,
            screen_h = 200,
            camera_height = 0.5,
        },
        {},
        {},
        { [1] = wall_tex }
    )
    print("persistent scene quads = " .. count)
end

--@api-stub: LMultiLevelGrid:pickScreen
do
    local wall_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local grid = lurek.raycaster.newMultiLevelGrid({
        {
            width = 8,
            height = 8,
            cells = {
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
            },
        },
        {
            width = 8,
            height = 8,
            cells = {
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 1, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
            },
            floor_offset = 1,
            ceiling_height = 2,
        },
    })
    grid:setActiveLevel(1)
    local hit = grid:pickScreen(
        160,
        100,
        {
            px = 1.5,
            py = 2.5,
            angle = 0,
            fov = math.pi / 3,
            rays = 64,
            max_dist = 12,
            screen_w = 320,
            screen_h = 200,
            camera_height = 0.5,
        },
        { [1] = wall_tex }
    )
    if hit then
        print("persistent pick = " .. hit.surface .. " @ level " .. hit.level)
    end
end

--@api-stub: LMultiLevelGrid:buildSceneFromAdapter
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        {
            width = 4,
            height = 4,
            cells = {
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
            },
            floor_offset = 0,
            ceiling_height = 1,
        },
        {
            width = 4,
            height = 4,
            cells = {
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
            },
            floor_offset = 1,
            ceiling_height = 2,
        },
    })
    grid:setActiveLevel(1)

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(2.5, 1.5, "dynamic")
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:bindBodySprite(
        body,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        { id = 35, level = 1, size = 1.0 }
    )
    local quad_count = grid:buildSceneFromAdapter({
        px = 0.5,
        py = 1.5,
        angle = 0,
        fov = math.pi / 3,
        rays = 32,
        max_dist = 8,
        screen_w = 160,
        screen_h = 100,
        active_level = 1,
    }, adapter, {})
    print("persistent adapter quads = " .. quad_count)
end

--@api-stub: LMultiLevelGrid:pickScreenFromAdapter
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        {
            width = 4,
            height = 4,
            cells = {
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
            },
            floor_offset = 0,
            ceiling_height = 1,
        },
        {
            width = 4,
            height = 4,
            cells = {
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
            },
            floor_offset = 1,
            ceiling_height = 2,
        },
    })
    grid:setActiveLevel(1)

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(2.5, 1.5, "dynamic")
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:bindBodySprite(
        body,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        { id = 35, level = 1, size = 1.0 }
    )
    adapter:bindBodyLight(body, 4.0, {
        level = 1,
        intensity = 1.0,
        color = { 1.0, 0.8, 0.6 },
    })

    local params = {
        px = 0.5,
        py = 1.5,
        angle = 0,
        fov = math.pi / 3,
        rays = 32,
        max_dist = 8,
        screen_w = 160,
        screen_h = 100,
        active_level = 1,
    }
    local hit = grid:pickScreenFromAdapter(80, 50, params, {}, adapter)
    if hit then
        print("persistent adapter hit = " .. hit.surface .. " #" .. tostring(hit.id))
        print("persistent adapter hit point = " .. string.format("%.2f,%.2f", hit.hit_x, hit.hit_y))
    end
end

--@api-stub: LMultiLevelGrid:type
do
    local grid = lurek.raycaster.newMultiLevelGrid()
    print("persistent type = " .. grid:type())
end

--@api-stub: LMultiLevelGrid:typeOf
do
    local grid = lurek.raycaster.newMultiLevelGrid()
    print("persistent typeOf = " .. tostring(grid:typeOf("LMultiLevelGrid")))
end

--@api-stub: lurek.raycaster.pickScreenMultiLevel
do
    local wall_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local hit = lurek.raycaster.pickScreenMultiLevel(
        160,
        190,
        {
            px = 1.5,
            py = 1.5,
            angle = 0,
            fov = math.pi / 3,
            rays = 64,
            max_dist = 12,
            screen_w = 320,
            screen_h = 200,
            active_level = 1,
            camera_height = 0.5,
        },
        {
            {
                width = 8,
                height = 8,
                cells = {
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                },
                floor_offset = 0,
                ceiling_height = 1,
                ceiling_holes = {
                    false, false, false, false, false, false, false, false,
                    false, false, false, true, false, false, false, false,
                    false, false, false, false, false, false, false, false,
                    false, false, false, false, false, false, false, false,
                    false, false, false, false, false, false, false, false,
                    false, false, false, false, false, false, false, false,
                    false, false, false, false, false, false, false, false,
                    false, false, false, false, false, false, false, false,
                },
            },
            {
                width = 8,
                height = 8,
                cells = {
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                },
                floor_offset = 1,
                ceiling_height = 2,
                floor_holes = {
                    false, false, false, false, false, false, false, false,
                    false, false, false, true, false, false, false, false,
                    false, false, false, false, false, false, false, false,
                    false, false, false, false, false, false, false, false,
                    false, false, false, false, false, false, false, false,
                    false, false, false, false, false, false, false, false,
                    false, false, false, false, false, false, false, false,
                    false, false, false, false, false, false, false, false,
                },
                floor_texture = wall_tex,
            },
        },
        {}
    )

    if hit then
        print("stacked pick level = " .. hit.level)
        print("stacked pick surface = " .. hit.surface)
        print("stacked pick cell = " .. hit.x .. "," .. hit.y)
    end
end

--@api-stub: lurek.raycaster.pickScreenMultiLevelFromAdapter
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(2.5, 1.5, "dynamic")
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:bindBodySprite(
        body,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        { id = 22, level = 1, size = 1.0 }
    )
    local hit = lurek.raycaster.pickScreenMultiLevelFromAdapter(
        160,
        100,
        {
            px = 0.5,
            py = 1.5,
            angle = 0,
            fov = math.pi / 3,
            rays = 64,
            max_dist = 12,
            screen_w = 320,
            screen_h = 200,
            active_level = 1,
        },
        {
            {
                width = 4,
                height = 4,
                cells = {
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                },
                floor_offset = 0,
                ceiling_height = 1,
            },
            {
                width = 4,
                height = 4,
                cells = {
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                },
                floor_offset = 1,
                ceiling_height = 2,
            },
        },
        {},
        adapter
    )

    if hit then
        print("adapter stacked pick = " .. hit.surface .. " @ level " .. hit.level)
    end
end

--@api-stub: LRaycaster:pickScreen
do
    local map = lurek.raycaster.new(16, 16)
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
    local hit = map:pickScreen(160, 100, params)
    local sprite_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local sprite_hit = map:pickScreen(160, 100, params, {
        { id = 7, x = 10.5, y = 8.0, texture = sprite_tex, size = 1.0 },
    })
    local model_hit = map:pickScreen(160, 120, params, nil, {
        { id = 8, model = model, x = 10.5, y = 8.0, yaw = math.pi / 4, z = 0.15, scale = 0.22 },
    })
    local half_map = lurek.raycaster.new(12, 10)
    for i = 0, 11 do
        half_map:setCell(i, 0, 1)
        half_map:setCell(i, 9, 1)
    end
    for i = 0, 9 do
        half_map:setCell(0, i, 1)
        half_map:setCell(11, i, 1)
    end
    half_map:setCell(7, 5, 1)
    half_map:setHalfWallCell(7, 5, 0.5)
    local feature_hit = half_map:pickScreen(160, 100, {
        px = 2.5,
        py = 5.5,
        angle = 0,
        fov = math.pi / 3,
        rays = 64,
        max_dist = 20,
        screen_w = 320,
        screen_h = 200,
    })

    if hit then
        print("surface = " .. hit.surface)
        print("cell = " .. hit.x .. "," .. hit.y)
        print("distance = " .. string.format("%.2f", hit.distance))
        print("hit = " .. string.format("%.2f", hit.hit_x) .. "," .. string.format("%.2f", hit.hit_y))
        print("ray angle = " .. string.format("%.3f", hit.ray_angle))
        print("uv = " .. string.format("%.2f", hit.u) .. "," .. string.format("%.2f", hit.v))
    end
    if sprite_hit then
        print("sprite surface = " .. sprite_hit.surface)
        print("sprite id = " .. tostring(sprite_hit.id))
        print("sprite distance = " .. string.format("%.2f", sprite_hit.distance))
        print("sprite uv = " .. string.format("%.2f", sprite_hit.u) .. "," .. string.format("%.2f", sprite_hit.v))
    end
    if model_hit then
        print("model surface = " .. model_hit.surface)
        print("model id = " .. tostring(model_hit.id))
        print("model distance = " .. string.format("%.2f", model_hit.distance))
        print("model uv = " .. string.format("%.2f", model_hit.u) .. "," .. string.format("%.2f", model_hit.v))
    end
    if feature_hit and feature_hit.feature then
        print("feature kind = " .. feature_hit.feature.kind)
        print("feature section = " .. feature_hit.feature.section)
        print("feature wall height = " .. string.format("%.2f", feature_hit.wall_height))
    end
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

--@api-stub: LRaycaster:extractMinimap
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(0, 0, 1)
    map:setCell(1, 0, 1)
    map:setCell(0, 1, 1)
    local image = map:extractMinimap(4.0, 4.0, 0.0, 3, 4)
    print("minimap type = " .. image:type())
    print("minimap width = " .. image:getWidth())
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
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local params = {
        px = 8,
        py = 8,
        angle = 0,
        fov = math.pi / 3,
        rays = 40,
        max_dist = 20,
        screen_w = 160,
        screen_h = 100,
    }
    local baseline = rc:buildScene(params)
    local count = rc:buildSceneWithModels(params, nil, nil, nil, {
        { model = model, x = 10.5, y = 8.0, yaw = math.pi / 4, z = 0.15, scale = 0.22 },
    })
    local model_pick = rc:pickScreen(80, 60, params, nil, {
        { id = 42, model = model, x = 10.5, y = 8.0, yaw = math.pi / 4, z = 0.15, scale = 0.22 },
    })

    print("quad count without model = " .. baseline)
    print("quad count with model = " .. count)
    if model_pick then
        print("model pick surface = " .. model_pick.surface)
        print("model pick id = " .. tostring(model_pick.id))
        print("model pick distance = " .. string.format("%.2f", model_pick.distance))
        print("model pick uv = " .. string.format("%.2f", model_pick.u) .. "," .. string.format("%.2f", model_pick.v))
    end
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

--@api-stub: LSpriteManager:setLevel
do
    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    sm:setLevel(id, 2)

    local projected = sm:sortAndProject(0, 0, 0)

    print("level = " .. tostring(projected[1].level))
end

--@api-stub: LSpriteManager:setVisible
do
    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    sm:setVisible(id, false)

    local projected = sm:sortAndProject(0, 0, 0)

    print("projected count = " .. #projected)
end
