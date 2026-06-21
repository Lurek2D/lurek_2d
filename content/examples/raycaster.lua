-- content/examples/raycaster.lua
-- Auto-generated from content/examples2/raycaster_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/raycaster.lua

local function ray_log(message)
    lurek.log.info("[raycaster.example] " .. tostring(message))
end

local function build_walled_ray_map(width, height)
    local map = lurek.raycaster.new(width, height)
    for x = 0, width - 1 do
        map:setCell(x, 0, 1)
        map:setCell(x, height - 1, 1)
    end
    for y = 0, height - 1 do
        map:setCell(0, y, 1)
        map:setCell(width - 1, y, 1)
    end
    return map
end

local function example_print_log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    lurek.log.info(table.concat(parts, " "))
end

--@api: lurek.raycaster.new
do
    local map = lurek.raycaster.new(16, 16)
    map:setCell(1, 1, 2)
    ray_log("new width=" .. map:width())
    ray_log("new height=" .. map:height())
    ray_log("spawn cell=" .. map:getCell(1, 1))
    ray_log("spawn blocked=" .. tostring(map:isBlocked(1, 1)))
end

--@api: lurek.raycaster.newMap
do
    local map = lurek.raycaster.newMap(32, 32)
    map:setCell(4, 4, 3)
    ray_log("newMap width=" .. map:width())
    ray_log("newMap height=" .. map:height())
    ray_log("editor cell=" .. map:getCell(4, 4))
    ray_log("empty corridor=" .. tostring(map:isBlocked(5, 5)))
end

--@api: LRaycaster:setCell
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(0, 0, 1)
    map:setCell(1, 0, 2)
    ray_log("cell(0,0)=" .. map:getCell(0, 0))
    ray_log("cell(1,0)=" .. map:getCell(1, 0))
    ray_log("blocked corner=" .. tostring(map:isBlocked(0, 0)))
    ray_log("blocked neighbor=" .. tostring(map:isBlocked(1, 0)))
end

--@api: LRaycaster:getCell
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(0, 0, 1)
    local value = map:getCell(0, 0)
    local empty = map:getCell(7, 7)

    example_print_log("cell(0,0) = " .. value)
    example_print_log("cell(7,7) = " .. empty)
end

--@api: LRaycaster:setHalfWallCell
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(3, 3, 1)
    map:setHalfWallCell(3, 3, 0.5)
    local feature = map:getWallFeatureCell(3, 3)

    example_print_log("kind = " .. feature.kind)
    example_print_log("height = " .. string.format("%.2f", feature.height))
end

--@api: LRaycaster:setWindowCell
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(3, 3, 1)
    map:setWindowCell(3, 3, 0.3, 0.75, 0.4)
    local feature = map:getWallFeatureCell(3, 3)

    example_print_log("kind = " .. feature.kind)
    example_print_log("los = " .. tostring(map:lineOfSight(1.5, 3.5, 6.5, 3.5)))
    example_print_log("alpha = " .. string.format("%.2f", feature.alpha))
end

--@api: LRaycaster:setDoorCell
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(3, 3, 1)
    map:setDoorCell(3, 3, "horizontal", 1.0)
    local feature = map:getWallFeatureCell(3, 3)

    example_print_log("kind = " .. feature.kind)
    example_print_log("direction = " .. feature.direction)
    example_print_log("blocked = " .. tostring(map:isBlocked(3, 3)))
end

--@api: LRaycaster:applyDoorManager
do
    local map = lurek.raycaster.new(8, 8)
    local doors = lurek.raycaster.newDoorManager()
    map:setCell(3, 3, 2)

    local id = doors:addDoor(3, 3, "vertical", 1.0)
    map:applyDoorManager(doors)
    example_print_log("closed blocked = " .. tostring(map:isBlocked(3, 3)))

    doors:openDoor(id)
    doors:update(1.0)
    map:applyDoorManager(doors, 0.8)

    local feature = map:getWallFeatureCell(3, 3)
    example_print_log("kind = " .. feature.kind)
    example_print_log("blocked after open = " .. tostring(map:isBlocked(3, 3)))
    example_print_log("open amount = " .. string.format("%.2f", feature.open_amount))
end

--@api: LRaycaster:clearWallFeatureCell
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(3, 3, 1)
    map:setWindowCell(3, 3, 0.25, 0.75, 0.35)
    map:clearWallFeatureCell(3, 3)
    example_print_log("feature cleared = " .. tostring(map:getWallFeatureCell(3, 3) == nil))
end

--@api: LRaycaster:getWallFeatureCell
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
    local feature = map:getWallFeatureCell(7, 7)
    example_print_log("feature kind = " .. tostring(feature and feature.kind))

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

    example_print_log("window los = " .. tostring(map:lineOfSight(2.5, 7.5, 12.5, 7.5)))
    example_print_log("half wall blocked = " .. tostring(map:isBlocked(7, 5)))
    example_print_log("open door hit cell = " .. tostring(hit and hit.cell_value or "nil"))
    example_print_log("solid light r = " .. string.format("%.3f", solid_r))
    example_print_log("window light r = " .. string.format("%.3f", window_r))
    if picked then
        example_print_log("pick surface = " .. picked.surface)
        example_print_log("pick tile = " .. picked.x .. "," .. picked.y)
    end
end

--@api: LRaycaster:setCells
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
    example_print_log("cell(0,0) = " .. map:getCell(0, 0))
    example_print_log("cell(0,1) = " .. map:getCell(0, 1))
end

--@api: LRaycaster:isBlocked
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(3, 3, 1)
    map:setCell(4, 3, 2)
    ray_log("cell(3,3) blocked=" .. tostring(map:isBlocked(3, 3)))
    ray_log("cell(4,3) blocked=" .. tostring(map:isBlocked(4, 3)))
    ray_log("cell(2,2) blocked=" .. tostring(map:isBlocked(2, 2)))
    ray_log("line of sight across wall=" .. tostring(map:lineOfSight(1.5, 3.5, 6.5, 3.5)))
end

--@api: LRaycaster:isWalkBlocked
do
    local map = lurek.raycaster.new(8, 8)
    local pit_texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setLoweredFloorCell(3, 3, {
        texture = pit_texture,
        depth = 0.3,
        blocked = true,
    })

    example_print_log("cell(3,3) walk blocked = " .. tostring(map:isWalkBlocked(3, 3)))
    example_print_log("cell(2,2) walk blocked = " .. tostring(map:isWalkBlocked(2, 2)))
end

--@api: LRaycaster:castRay
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
        example_print_log("distance = " .. string.format("%.2f", hit.distance))
        example_print_log("cell = " .. hit.cell_value .. " side = " .. hit.side)
    end
end

--@api: LRaycaster:castRays
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local hits = map:castRays(8, 8, 0, math.pi / 3, 10, 20)

    example_print_log("ray count = " .. #hits)
    if hits[1] then
        example_print_log("first distance = " .. string.format("%.2f", hits[1].distance))
    end
end

--@api: LRaycaster:castRaysFlat
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local flat = map:castRaysFlat(8, 8, 0, math.pi / 3, 6, 20)

    example_print_log("flat value count = " .. #flat)
    example_print_log("first ray distance = " .. string.format("%.2f", flat[1] or 0))
    example_print_log("first ray cell = " .. tostring(flat[2]))
end

--@api: LRaycaster:castRayMulti
do
    local map = lurek.raycaster.new(16, 16)
    map:setCell(5, 8, 2)
    map:setCell(10, 8, 1)
    map:setWallAlpha(2, 0.5)

    local hits = map:castRayMulti(2, 8.5, 0, 20, 4)

    example_print_log("hit count = " .. #hits)
    if hits[1] then
        example_print_log("first distance = " .. string.format("%.2f", hits[1].distance))
        example_print_log("first cell = " .. hits[1].cell_value)
    end
end

--@api: LRaycaster:setWallAlpha
do
    local map = lurek.raycaster.new(8, 8)
    map:setWallAlpha(2, 0.5)
    map:setCell(3, 3, 2)
    local alpha = map:getWallAlpha(2)
    ray_log("setWallAlpha tile=2")
    ray_log("alpha(2)=" .. tostring(alpha))
    ray_log("cell(3,3)=" .. map:getCell(3, 3))
    ray_log("tile remains blocked=" .. tostring(map:isBlocked(3, 3)))
end

--@api: LRaycaster:getWallAlpha
do
    local map = lurek.raycaster.new(8, 8)
    map:setWallAlpha(2, 0.5)
    map:setWallAlpha(3, 0.25)
    ray_log("alpha(2)=" .. tostring(map:getWallAlpha(2)))
    ray_log("alpha(3)=" .. tostring(map:getWallAlpha(3)))
    ray_log("alpha(9)=" .. tostring(map:getWallAlpha(9)))
    ray_log("alpha map supports multiple tile ids")
end

--@api: LRaycaster:tryMove
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

    example_print_log("free move = " .. tostring(moved) .. " -> " .. nx .. "," .. ny)
    example_print_log("wall move = " .. tostring(blocked) .. " -> " .. wx .. "," .. wy)
end

--@api: LRaycaster:gridMove
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

    example_print_log("forward = " .. tostring(moved) .. " -> " .. nx .. "," .. ny)
    example_print_log("left = " .. tostring(strafe) .. " -> " .. sx .. "," .. sy)
end

--@api: LRaycaster:lineOfSight
do
    local map = lurek.raycaster.new(16, 16)
    map:setCell(8, 8, 1)

    local clear = map:lineOfSight(4, 4, 12, 4)
    local blocked = map:lineOfSight(4, 8, 12, 8)

    example_print_log("clear = " .. tostring(clear))
    example_print_log("blocked = " .. tostring(blocked))
end

--@api: LRaycaster:revealCellsFromRays
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

    example_print_log("revealed count = " .. #revealed)
    if revealed[1] then
        example_print_log("first cell = " .. revealed[1].x .. "," .. revealed[1].y)
    end
end

--@api: LRaycaster:drawView
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local img = map:drawView(8, 8, 0, math.pi / 3, 320, 200, 16)

    example_print_log("width = " .. img:getWidth())
    example_print_log("height = " .. img:getHeight())
end

--@api: LRaycaster:drawTopDown
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

    example_print_log("width = " .. img:getWidth())
    example_print_log("height = " .. img:getHeight())
end

--@api: LRaycaster:drawDepthMap
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local depth = map:drawDepthMap(8, 8, 0, math.pi / 3, 160, 160, 100, 16)

    example_print_log("width = " .. depth:getWidth())
    example_print_log("height = " .. depth:getHeight())
end

--@api: lurek.raycaster.distanceShade
do
    local near = lurek.raycaster.distanceShade(0, 10)
    local mid = lurek.raycaster.distanceShade(5, 10)
    local far = lurek.raycaster.distanceShade(9, 10)

    example_print_log("near = " .. string.format("%.2f", near))
    example_print_log("mid = " .. string.format("%.2f", mid))
    example_print_log("far = " .. string.format("%.2f", far))
end

--@api: lurek.raycaster.applyLitShade
do
    local near_r, near_g, near_b = lurek.raycaster.applyLitShade(0.9, 1.0, 0.8, 0.6)
    local far_r, far_g, far_b = lurek.raycaster.applyLitShade(0.2, 1.0, 0.8, 0.6)
    ray_log("near lit shade=" .. near_r .. "," .. near_g .. "," .. near_b)
    ray_log("far lit shade=" .. far_r .. "," .. far_g .. "," .. far_b)
    ray_log("near brighter than far=" .. tostring(near_r > far_r))
    ray_log("blue channel preserved=" .. tostring(near_b > 0 and far_b > 0))
end

--@api: lurek.raycaster.projectColumn
do
    local near_height, near_top, near_bottom = lurek.raycaster.projectColumn(3.0, math.pi / 3, 200)
    local far_height = select(1, lurek.raycaster.projectColumn(8.0, math.pi / 3, 200))
    ray_log("near column height=" .. string.format("%.1f", near_height))
    ray_log("near top=" .. string.format("%.1f", near_top))
    ray_log("near bottom=" .. string.format("%.1f", near_bottom))
    ray_log("near taller than far=" .. tostring(near_height > far_height))
end

--@api: LRaycaster:type
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(1, 1, 1)
    local type_name = map:type()
    ray_log("type=" .. type_name)
    ray_log("width=" .. map:width())
    ray_log("height=" .. map:height())
    ray_log("sample cell=" .. map:getCell(1, 1))
end

--@api: LRaycaster:typeOf
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(2, 2, 1)
    ray_log("LRaycaster=" .. tostring(map:typeOf("LRaycaster")))
    ray_log("LObject=" .. tostring(map:typeOf("LObject")))
    ray_log("LSceneAdapter=" .. tostring(map:typeOf("LSceneAdapter")))
    ray_log("sample cell=" .. map:getCell(2, 2))
end

--- Raycaster Module Part 2: doors, height maps, lights, sprites, floor/ceiling, scene building, minimap

--@api: lurek.raycaster.newDoorManager
do
    local doors = lurek.raycaster.newDoorManager()
    local first = doors:addDoor(5, 3, "horizontal", 2.0)
    local second = doors:addDoor(8, 6, "vertical", 1.5)

    example_print_log("first id = " .. first)
    example_print_log("second id = " .. second)
    example_print_log("count = " .. doors:count())
end

--@api: LDoorManager:getDoor
do
    local doors = lurek.raycaster.newDoorManager()
    local idx = doors:addDoor(3, 3, "vertical", 4.0)

    doors:openDoor(idx)
    for _ = 1, 10 do
        doors:update(0.1)
    end

    local door = doors:getDoor(idx)

    example_print_log("state = " .. door.state)
    example_print_log("open = " .. string.format("%.2f", door.openAmount))
end

--@api: LDoorManager:type
do
    local doors = lurek.raycaster.newDoorManager()
    local id = doors:addDoor(2, 2, "horizontal", 0.5)
    local type_name = doors:type()
    ray_log("door manager type=" .. type_name)
    ray_log("door count=" .. doors:count())
    ray_log("tracked door state=" .. doors:getDoor(id).state)
    ray_log("door id=" .. tostring(id))
end

--@api: LDoorManager:typeOf
do
    local doors = lurek.raycaster.newDoorManager()
    local id = doors:addDoor(3, 3, "vertical", 0.75)
    local door = doors:getDoor(id)
    ray_log("LDoorManager=" .. tostring(doors:typeOf("LDoorManager")))
    ray_log("LObject=" .. tostring(doors:typeOf("LObject")))
    ray_log("LRaycaster=" .. tostring(doors:typeOf("LRaycaster")))
    ray_log("door cell=" .. tostring(door.x) .. "," .. tostring(door.y))
end

--@api: lurek.raycaster.newHeightMap
do
    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(5, 5, -0.3)
    hm:setCeiling(5, 5, 0.8)
    hm:setFloor(10, 10, 0.2)
    hm:setCeiling(10, 10, 1.5)

    example_print_log("floor(5,5) = " .. hm:floorAt(5, 5))
    example_print_log("ceiling(10,10) = " .. hm:ceilingAt(10, 10))
end

--@api: LHeightMap:type
do
    local hm = lurek.raycaster.newHeightMap(4, 4)
    hm:setFloor(1, 1, -0.25)
    local type_name = hm:type()
    ray_log("heightmap type=" .. type_name)
    ray_log("floor sample=" .. hm:floorAt(1, 1))
    ray_log("ceiling default=" .. hm:ceilingAt(1, 1))
    ray_log("type tracks authored cells")
end

--@api: LHeightMap:typeOf
do
    local hm = lurek.raycaster.newHeightMap(4, 4)
    hm:setCeiling(2, 2, 1.4)
    ray_log("LHeightMap=" .. tostring(hm:typeOf("LHeightMap")))
    ray_log("LObject=" .. tostring(hm:typeOf("LObject")))
    ray_log("LPointLight=" .. tostring(hm:typeOf("LPointLight")))
    ray_log("ceiling sample=" .. hm:ceilingAt(2, 2))
end

--@api: lurek.raycaster.newPointLight
do
    local torch = lurek.raycaster.newPointLight(5.5, 3.5, 1.0, 0.8, 0.4, 4.0, 1.5, 1)
    local r, g, b = torch:color()

    example_print_log("pos = " .. torch:x() .. "," .. torch:y())
    example_print_log("color = " .. r .. "," .. g .. "," .. b)
    example_print_log("radius = " .. torch:radius() .. " intensity = " .. torch:intensity())
    example_print_log("level = " .. tostring(torch:level()))
end

--@api: LPointLight:set
do
    local light = lurek.raycaster.newPointLight(2, 2, 1, 1, 1, 3, 1.0)
    light:set(8, 8, 0, 0, 1, 6, 2.0, 2)
    local r, g, b = light:color()

    example_print_log("pos = " .. light:x() .. "," .. light:y())
    example_print_log("color = " .. r .. "," .. g .. "," .. b)
    example_print_log("radius = " .. light:radius() .. " intensity = " .. light:intensity())
    example_print_log("level = " .. tostring(light:level()))
end

--@api: LPointLight:level
do
    local light = lurek.raycaster.newPointLight(1, 1, 1, 1, 1, 2, 0.5, 3)
    local r, g, b = light:color()
    ray_log("light level=" .. tostring(light:level()))
    ray_log("light color=" .. r .. "," .. g .. "," .. b)
    ray_log("light radius=" .. light:radius())
    ray_log("light intensity=" .. light:intensity())
end

--@api: LPointLight:setLevel
do
    local light = lurek.raycaster.newPointLight(1, 1, 1, 1, 1, 2, 0.5)
    light:setLevel(1)
    example_print_log("light level after set = " .. tostring(light:level()))
    light:setLevel(nil)
    example_print_log("light level after clear = " .. tostring(light:level()))
end

--@api: LPointLight:type
do
    local light = lurek.raycaster.newPointLight(0, 0, 1, 1, 1, 1, 1)
    local type_name = light:type()
    ray_log("light type=" .. type_name)
    ray_log("x=" .. light:x())
    ray_log("y=" .. light:y())
    ray_log("radius=" .. light:radius())
end

--@api: LPointLight:typeOf
do
    local light = lurek.raycaster.newPointLight(0, 0, 1, 1, 1, 1, 1)
    light:setLevel(2)
    ray_log("LPointLight=" .. tostring(light:typeOf("LPointLight")))
    ray_log("LObject=" .. tostring(light:typeOf("LObject")))
    ray_log("LHeightMap=" .. tostring(light:typeOf("LHeightMap")))
    ray_log("level=" .. tostring(light:level()))
end

--@api: lurek.raycaster.newSpriteManager
do
    local sprites = lurek.raycaster.newSpriteManager()
    local barrel = sprites:add(5.5, 3.5, "content/examples/assets/images/sample_texture.png", 1.0)
    local torch = sprites:add(8.5, 2.5, "content/examples/assets/images/sample_texture.png", 0.5, 1)
    local enemy = sprites:add(10.5, 7.5, "content/examples/assets/images/sample_texture.png", 1.2)

    sprites:setPosition(enemy, 11, 8)
    sprites:setVisible(torch, false)
    sprites:remove(barrel)

    example_print_log("torch id = " .. torch)
    example_print_log("enemy id = " .. enemy)
end

--@api: lurek.raycaster.newSceneAdapter
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
    example_print_log("scene adapter sprites = " .. #inputs.sprites)
    example_print_log("scene adapter lights = " .. #inputs.lights)
    example_print_log("scene adapter models = " .. #inputs.models)
    example_print_log("sprite pos = " .. string.format("%.2f,%.2f", inputs.sprites[1].x, inputs.sprites[1].y))
    example_print_log("adapter buildScene quads = " .. quad_count)
    example_print_log("adapter pick = " .. tostring(pick and pick.surface or "nil"))
    if pick then
        example_print_log("adapter pick hit = " .. string.format("%.2f,%.2f", pick.hit_x, pick.hit_y))
        example_print_log("adapter pick angle = " .. tostring(pick.ray_angle))
    end
end

--@api: LSceneAdapter:sceneInputs
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
    example_print_log("sceneInputs sprites = " .. #inputs.sprites)
    example_print_log("sceneInputs lights = " .. #inputs.lights)
end

--@api: LSceneAdapter:addSprite
do
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addSprite(
        4.5,
        3.5,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        { id = 31, level = 1, size = 1.2 }
    )
    local sprite = adapter:sceneInputs().sprites[1]
    example_print_log("static sprite id = " .. sprite.id)
    example_print_log("static sprite pos = " .. string.format("%.2f,%.2f", sprite.x, sprite.y))
end

--@api: LSceneAdapter:addDirectionalSprite
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
    example_print_log("directional front tex = " .. tostring(sprite.front_texture))
    example_print_log("directional angle = " .. string.format("%.3f", sprite.angle))
end

--@api: LSceneAdapter:addLight
do
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addLight(5.0, 3.5, 4.0, {
        intensity = 1.1,
        color = { 1.0, 0.7, 0.4 },
        level = 1,
    })
    local light = adapter:sceneInputs().lights[1]
    example_print_log("static light radius = " .. light.radius)
    example_print_log("static light intensity = " .. light.intensity)
end

--@api: LSceneAdapter:addModel
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
    example_print_log("static model id = " .. model.id)
    example_print_log("static model yaw = " .. string.format("%.2f", model.yaw))
end

--@api: LSceneAdapter:bindBodyDirectionalSprite
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
    example_print_log("body directional id = " .. sprite.id)
    example_print_log("body directional pos = " .. string.format("%.2f,%.2f", sprite.x, sprite.y))
    example_print_log("body directional angle = " .. string.format("%.3f", sprite.angle))
end

--@api: LSceneAdapter:bindBodySprite
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
    example_print_log("body sprite pos = " .. string.format("%.2f,%.2f", sprite.x, sprite.y))
end

--@api: LSceneAdapter:bindBodyLight
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(2.0, 2.0, "dynamic")
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:bindBodyLight(body, 3.0, { intensity = 0.8, offset_y = 0.25 })
    body:setPosition(3.0, 2.0)
    local light = adapter:sceneInputs().lights[1]
    example_print_log("body light pos = " .. string.format("%.2f,%.2f", light.x, light.y))
end

--@api: LSceneAdapter:bindBodyModel
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
    example_print_log("body model yaw = " .. string.format("%.2f", model.yaw))
end

--@api: LRaycaster:buildSceneFromAdapter
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
    example_print_log("adapter scene quads = " .. count)
end

--@api: LRaycaster:pickScreenFromAdapter
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
        example_print_log("adapter pick id = " .. tostring(hit.id))
        example_print_log("adapter pick point = " .. string.format("%.2f,%.2f", hit.hit_x, hit.hit_y))
    end
end

--@api: LSceneAdapter:clear
do
    local adapter = lurek.raycaster.newSceneAdapter()
    local tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    adapter:addSprite(1.0, 1.0, tex)
    adapter:addLight(1.0, 1.0, 2.0)
    adapter:addModel(lurek.render.loadModel("content/examples/assets/models/sample_tank.obj"), 1.0, 1.0)
    adapter:clear()
    example_print_log("adapter cleared sprites = " .. #adapter:sceneInputs().sprites)
end

--@api: LSceneAdapter:clearSprites
do
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addSprite(
        1.0,
        1.0,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    )
    adapter:clearSprites()
    example_print_log("adapter sprite count = " .. #adapter:sceneInputs().sprites)
end

--@api: LSceneAdapter:clearLights
do
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addLight(1.0, 1.0, 2.0)
    adapter:addLight(2.5, 1.0, 3.0, { intensity = 0.6, color = { 0.8, 0.9, 1.0 } })
    adapter:clearLights()
    local inputs = adapter:sceneInputs()
    ray_log("clearLights light count=" .. #inputs.lights)
    ray_log("clearLights sprite count=" .. #inputs.sprites)
    ray_log("clearLights model count=" .. #inputs.models)
end

--@api: LSceneAdapter:clearModels
do
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addModel(lurek.render.loadModel("content/examples/assets/models/sample_tank.obj"), 1.0, 1.0)
    adapter:addModel(lurek.render.loadModel("content/examples/assets/models/sample_tank.obj"), 2.0, 1.0, { id = 90 })
    adapter:clearModels()
    local inputs = adapter:sceneInputs()
    ray_log("clearModels model count=" .. #inputs.models)
    ray_log("clearModels sprite count=" .. #inputs.sprites)
    ray_log("clearModels light count=" .. #inputs.lights)
end

--@api: LSceneAdapter:type
do
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addSprite(1.5, 2.5, lurek.render.newImage("content/examples/assets/images/sample_texture.png"), { id = 41 })
    ray_log("adapter type=" .. adapter:type())
    ray_log("adapter has sprites=" .. #adapter:sceneInputs().sprites)
    ray_log("adapter is scene adapter=" .. tostring(adapter:typeOf("LSceneAdapter")))
    ray_log("adapter models=" .. #adapter:sceneInputs().models)
end

--@api: LSceneAdapter:typeOf
do
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addLight(4.0, 4.0, 3.0, { intensity = 1.0, color = { 1.0, 0.7, 0.4 } })
    ray_log("LSceneAdapter=" .. tostring(adapter:typeOf("LSceneAdapter")))
    ray_log("LObject=" .. tostring(adapter:typeOf("LObject")))
    ray_log("LSpriteManager=" .. tostring(adapter:typeOf("LSpriteManager")))
    ray_log("light snapshot=" .. #adapter:sceneInputs().lights)
end

--@api: LSpriteManager:sortAndProject
do
    local sprites = lurek.raycaster.newSpriteManager()
    sprites:add(3, 3, "content/examples/assets/images/sample_texture.png")
    sprites:add(6, 6, "content/examples/assets/images/sample_texture.png")
    sprites:add(9, 9, "content/examples/assets/images/sample_texture.png")

    local order = sprites:sortAndProject(5, 5, 0)

    example_print_log("projected count = " .. #order)
    if order[1] then
        example_print_log("first id = " .. order[1].id)
        example_print_log("first distance = " .. string.format("%.2f", order[1].distance))
    end
end

--@api: LSpriteManager:addDirectional
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

    example_print_log("sprite id = " .. id)
    example_print_log("texture = " .. order[1].texture)
    example_print_log("variant = " .. tostring(order[1].variant))
end

--@api: LSpriteManager:setFacing
do
    local sprites = lurek.raycaster.newSpriteManager()
    local id = sprites:addDirectional(2.0, 0.0, "front.png", "right.png", "back.png", "left.png", math.pi, 1.0)
    sprites:setFacing(id, 0.0)
    local order = sprites:sortAndProject(0, 0, 0)

    example_print_log("texture = " .. order[1].texture)
    example_print_log("variant = " .. tostring(order[1].variant))
end

--@api: LSpriteManager:setDirectionalTextures
do
    local sprites = lurek.raycaster.newSpriteManager()
    local id = sprites:add(2.0, 0.0, "old.png", 1.0)
    sprites:setDirectionalTextures(id, "front2.png", "right2.png", "back2.png", "left2.png", math.pi)
    local order = sprites:sortAndProject(0, 0, 0)

    example_print_log("texture = " .. order[1].texture)
    example_print_log("variant = " .. tostring(order[1].variant))
end

--@api: LSpriteManager:clear
do
    local sprites = lurek.raycaster.newSpriteManager()
    sprites:add(1, 1, "content/examples/assets/images/sample_texture.png")
    sprites:add(2, 2, "content/examples/assets/images/sample_texture.png")
    sprites:clear()

    local order = sprites:sortAndProject(0, 0, 0)

    example_print_log("projected count = " .. #order)
end

--@api: LSpriteManager:type
do
    local sprites = lurek.raycaster.newSpriteManager()
    local id = sprites:add(3.5, 2.5, "content/examples/assets/images/sample_texture.png", 1.0)
    ray_log("sprite manager type=" .. sprites:type())
    ray_log("projected count=" .. #sprites:sortAndProject(0, 0, 0))
    ray_log("typeOf sprite manager=" .. tostring(sprites:typeOf("LSpriteManager")))
    ray_log("first sprite id=" .. tostring(id))
end

--@api: LSpriteManager:typeOf
do
    local sprites = lurek.raycaster.newSpriteManager()
    local id = sprites:add(4.0, 1.0, "content/examples/assets/images/sample_texture.png", 0.75, 1)
    ray_log("LSpriteManager=" .. tostring(sprites:typeOf("LSpriteManager")))
    ray_log("LObject=" .. tostring(sprites:typeOf("LObject")))
    ray_log("LSceneAdapter=" .. tostring(sprites:typeOf("LSceneAdapter")))
    ray_log("visible sprite id=" .. tostring(id))
end

--@api: LRaycaster:setFloorTextureCell
do
    local map = lurek.raycaster.new(8, 8)
    local floor_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    map:setFloorTextureCell(3, 3, floor_tex)
    map:setFloorTextureCell(4, 3, floor_tex)
    ray_log("setFloorTextureCell raw id=" .. tostring(map:getFloorTextureCell(3, 3)))
    ray_log("neighbor raw id=" .. tostring(map:getFloorTextureCell(4, 3)))
    ray_log("empty raw id=" .. tostring(map:getFloorTextureCell(0, 0)))
    ray_log("floor texture cells assigned for corridor")
end

--@api: LRaycaster:getFloorTextureCell
do
    local map = lurek.raycaster.new(8, 8)
    local floor_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setFloorTextureCell(3, 3, floor_tex)

    example_print_log("floor(3,3) = " .. tostring(map:getFloorTextureCell(3, 3)))
    example_print_log("floor(0,0) = " .. tostring(map:getFloorTextureCell(0, 0)))
end

--@api: LRaycaster:setCeilingTextureCell
do
    local map = lurek.raycaster.new(8, 8)
    local ceil_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    map:setCeilingTextureCell(2, 2, ceil_tex)
    map:setCeilingTextureCell(2, 3, ceil_tex)
    ray_log("setCeilingTextureCell raw id=" .. tostring(map:getCeilingTextureCell(2, 2)))
    ray_log("neighbor raw id=" .. tostring(map:getCeilingTextureCell(2, 3)))
    ray_log("empty raw id=" .. tostring(map:getCeilingTextureCell(0, 0)))
    ray_log("ceiling texture cells assigned for room")
end

--@api: LRaycaster:getCeilingTextureCell
do
    local map = lurek.raycaster.new(8, 8)
    local ceil_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setCeilingTextureCell(2, 2, ceil_tex)

    example_print_log("ceiling(2,2) = " .. tostring(map:getCeilingTextureCell(2, 2)))
    example_print_log("ceiling(0,0) = " .. tostring(map:getCeilingTextureCell(0, 0)))
end

--@api: LRaycaster:setLoweredFloorCell
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

    example_print_log("depth = " .. cell.depth)
    example_print_log("blocked = " .. tostring(cell.blocked))
end

--@api: LRaycaster:getLoweredFloorCell
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
        example_print_log("texture = " .. tostring(cell.texture))
        example_print_log("depth = " .. cell.depth)
        example_print_log("blocked = " .. tostring(cell.blocked))
    end
end

--@api: LRaycaster:computeTileLight
do
    local map = lurek.raycaster.new(16, 16)
    local lights = {
        { x = 8, y = 8, r = 1.0, g = 0.9, b = 0.7, radius = 5.0, intensity = 2.0 },
        { x = 3, y = 3, r = 0.2, g = 0.5, b = 1.0, radius = 3.0, intensity = 1.0 },
    }
    local r, g, b, luma = map:computeTileLight(7, 8, 0.1, lights)

    example_print_log("r = " .. string.format("%.2f", r))
    example_print_log("g = " .. string.format("%.2f", g))
    example_print_log("luma = " .. string.format("%.2f", luma))
end

--@api: LRaycaster:buildScene
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

    example_print_log("quad count = " .. quad_count)
    example_print_log("managed quad count = " .. managed_quad_count)
    example_print_log("directional sprite count = " .. #sprites)
end

--@api: lurek.raycaster.getLastBuildStats
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
        example_print_log("lighting samples = " .. stats.lightingSamples)
        example_print_log("lighting cache hits = " .. stats.lightingCacheHits)
        example_print_log("lighting cache misses = " .. stats.lightingCacheMisses)
    end
end

--@api: lurek.raycaster.buildMultiLevelScene
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

    example_print_log("stacked quad count = " .. quad_count)
end

--@api: lurek.raycaster.buildMultiLevelSceneFromAdapter
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

    example_print_log("stacked adapter quad count = " .. quad_count)
end

--@api: lurek.raycaster.newMultiLevelGrid
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        {
            width = 2,
            height = 2,
            cells = { 0, 0, 0, 0 },
        },
    })
    example_print_log("persistent grid levels = " .. grid:levelCount())
end

--@api: LMultiLevelGrid:addLevel
do
    local grid = lurek.raycaster.newMultiLevelGrid()
    local index = grid:addLevel({
        width = 2,
        height = 2,
        cells = { 0, 0, 0, 0 },
    })
    example_print_log("added level = " .. index)
end

--@api: LMultiLevelGrid:levelCount
do
    local grid = lurek.raycaster.newMultiLevelGrid()
    grid:addLevel({
        width = 2,
        height = 2,
        cells = { 0, 0, 0, 0 },
    })
    example_print_log("level count = " .. grid:levelCount())
end

--@api: LMultiLevelGrid:setActiveLevel
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 1, ceiling_height = 2 },
    })
    grid:setActiveLevel(1)
    example_print_log("active after set = " .. grid:activeLevel())
end

--@api: LMultiLevelGrid:activeLevel
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 1, ceiling_height = 2 },
    })
    grid:setActiveLevel(1)
    example_print_log("active level = " .. grid:activeLevel())
end

--@api: LMultiLevelGrid:getFloorOffset
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 1.25, ceiling_height = 2.5 },
    })
    grid:setActiveLevel(1)
    example_print_log("floor offset = " .. grid:getFloorOffset())
end

--@api: LMultiLevelGrid:setFloorOffset
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 0, ceiling_height = 1 },
    })
    grid:setFloorOffset(0.75)
    example_print_log("updated floor offset = " .. grid:getFloorOffset())
end

--@api: LMultiLevelGrid:getCeilingHeight
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 0.5, ceiling_height = 2.25 },
    })
    grid:setFloorOffset(0.75)
    ray_log("ceiling height=" .. grid:getCeilingHeight())
    ray_log("floor offset=" .. grid:getFloorOffset())
    ray_log("active level=" .. grid:activeLevel())
    ray_log("type=" .. grid:type())
end

--@api: LMultiLevelGrid:setCeilingHeight
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 0.5, ceiling_height = 1.5 },
    })
    grid:setCeilingHeight(0.55)
    example_print_log("clamped ceiling height = " .. grid:getCeilingHeight())
end

--@api: LMultiLevelGrid:setCell
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setActiveLevel(1)
    grid:setCell(1, 0, 7)
    example_print_log("active cell after set = " .. grid:getCell(1, 0))
end

--@api: LMultiLevelGrid:getCell
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 5, 0, 0 } },
    })
    grid:setActiveLevel(1)
    example_print_log("active cell = " .. grid:getCell(1, 0))
end

--@api: LMultiLevelGrid:setHalfWallCell
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
    })
    grid:setHalfWallCell(0, 0, 0.5)
    example_print_log("half feature kind = " .. grid:getWallFeatureCell(0, 0).kind)
end

--@api: LMultiLevelGrid:setWindowCell
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
    })
    grid:setWindowCell(0, 0, 0.25, 0.8, 0.4)
    example_print_log("window sill = " .. grid:getWallFeatureCell(0, 0).sill_height)
end

--@api: LMultiLevelGrid:setDoorCell
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
    })
    grid:setDoorCell(0, 0, "vertical", 0.6, 0.9)
    example_print_log("door open amount = " .. grid:getWallFeatureCell(0, 0).open_amount)
end

--@api: LMultiLevelGrid:clearWallFeatureCell
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
    })
    grid:setWindowCell(0, 0, 0.25, 0.8, 0.4)
    grid:clearWallFeatureCell(0, 0)
    example_print_log("feature cleared = " .. tostring(grid:getWallFeatureCell(0, 0) == nil))
end

--@api: LMultiLevelGrid:getWallFeatureCell
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
    })
    grid:setWindowCell(0, 0, 0.25, 0.8, 0.4)
    local feature = grid:getWallFeatureCell(0, 0)
    ray_log("feature kind=" .. tostring(feature and feature.kind))
    ray_log("feature alpha=" .. tostring(feature and feature.alpha))
    ray_log("empty cell absent=" .. tostring(grid:getWallFeatureCell(1, 1) == nil))
    ray_log("window sill=" .. tostring(feature and feature.sill_height))
end

--@api: LMultiLevelGrid:setFloorTexture
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    local floor_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    grid:setFloorTexture(floor_tex)
    example_print_log("default floor texture = " .. tostring(grid:getFloorTexture()))
    grid:setFloorTexture(nil)
    example_print_log("default floor cleared = " .. tostring(grid:getFloorTexture() == nil))
end

--@api: LMultiLevelGrid:getFloorTexture
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setFloorTexture(lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    example_print_log("floor texture id = " .. tostring(grid:getFloorTexture()))
end

--@api: LMultiLevelGrid:setFloorTextureCell
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setFloorTextureCell(1, 1, lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    example_print_log("floor cell texture = " .. tostring(grid:getFloorTextureCell(1, 1)))
    grid:setFloorTextureCell(1, 1, nil)
    example_print_log("floor cell cleared = " .. tostring(grid:getFloorTextureCell(1, 1) == nil))
end

--@api: LMultiLevelGrid:getFloorTextureCell
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setFloorTextureCell(1, 0, lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    example_print_log("floor(1,0) texture id = " .. tostring(grid:getFloorTextureCell(1, 0)))
end

--@api: LMultiLevelGrid:setCeilingTexture
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    local ceil_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    grid:setCeilingTexture(ceil_tex)
    example_print_log("default ceiling texture = " .. tostring(grid:getCeilingTexture()))
    grid:setCeilingTexture(nil)
    example_print_log("default ceiling cleared = " .. tostring(grid:getCeilingTexture() == nil))
end

--@api: LMultiLevelGrid:getCeilingTexture
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setCeilingTexture(lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    example_print_log("ceiling texture id = " .. tostring(grid:getCeilingTexture()))
end

--@api: LMultiLevelGrid:setCeilingTextureCell
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setCeilingTextureCell(0, 1, lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    example_print_log("ceiling cell texture = " .. tostring(grid:getCeilingTextureCell(0, 1)))
    grid:setCeilingTextureCell(0, 1, nil)
    example_print_log("ceiling cell cleared = " .. tostring(grid:getCeilingTextureCell(0, 1) == nil))
end

--@api: LMultiLevelGrid:getCeilingTextureCell
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setCeilingTextureCell(0, 0, lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    example_print_log("ceiling(0,0) texture id = " .. tostring(grid:getCeilingTextureCell(0, 0)))
end

--@api: LMultiLevelGrid:setLoweredFloorCell
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
    example_print_log("pit depth = " .. pit.depth)
    grid:setLoweredFloorCell(2, 2, nil)
    example_print_log("pit cleared = " .. tostring(grid:getLoweredFloorCell(2, 2) == nil))
end

--@api: LMultiLevelGrid:getLoweredFloorCell
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
    example_print_log("pit blocked = " .. tostring(pit.blocked))
end

--@api: LMultiLevelGrid:setFloorHole
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setActiveLevel(1)
    grid:setFloorHole(1, 0, true)
    example_print_log("floor hole after set = " .. tostring(grid:isFloorHole(1, 0)))
end

--@api: LMultiLevelGrid:isFloorHole
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_holes = { false, true, false, false } },
    })
    grid:setActiveLevel(1)
    example_print_log("imported floor hole = " .. tostring(grid:isFloorHole(1, 0)))
end

--@api: LMultiLevelGrid:setCeilingHole
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setActiveLevel(1)
    grid:setCeilingHole(1, 1, true)
    example_print_log("ceiling hole after set = " .. tostring(grid:isCeilingHole(1, 1)))
end

--@api: LMultiLevelGrid:isCeilingHole
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, ceiling_holes = { false, false, false, true } },
    })
    grid:setActiveLevel(1)
    example_print_log("imported ceiling hole = " .. tostring(grid:isCeilingHole(1, 1)))
end

--@api: LMultiLevelGrid:buildScene
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
    example_print_log("persistent scene quads = " .. count)
end

--@api: LMultiLevelGrid:pickScreen
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
        example_print_log("persistent pick = " .. hit.surface .. " @ level " .. hit.level)
    end
end

--@api: LMultiLevelGrid:buildSceneFromAdapter
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
    example_print_log("persistent adapter quads = " .. quad_count)
end

--@api: LMultiLevelGrid:pickScreenFromAdapter
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
        example_print_log("persistent adapter hit = " .. hit.surface .. " #" .. tostring(hit.id))
        example_print_log("persistent adapter hit point = " .. string.format("%.2f,%.2f", hit.hit_x, hit.hit_y))
    end
end

--@api: LMultiLevelGrid:type
do
    local grid = lurek.raycaster.newMultiLevelGrid()
    grid:addLevel({ width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 0, ceiling_height = 1.5 })
    grid:setActiveLevel(0)
    ray_log("persistent type=" .. grid:type())
    ray_log("level count=" .. grid:levelCount())
    ray_log("active level=" .. grid:activeLevel())
    ray_log("typeOf grid=" .. tostring(grid:typeOf("LMultiLevelGrid")))
end

--@api: LMultiLevelGrid:typeOf
do
    local grid = lurek.raycaster.newMultiLevelGrid()
    grid:addLevel({ width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 1, ceiling_height = 2 })
    ray_log("LMultiLevelGrid=" .. tostring(grid:typeOf("LMultiLevelGrid")))
    ray_log("LObject=" .. tostring(grid:typeOf("LObject")))
    ray_log("LRaycaster=" .. tostring(grid:typeOf("LRaycaster")))
    ray_log("level count=" .. grid:levelCount())
end

--@api: lurek.raycaster.pickScreenMultiLevel
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
        example_print_log("stacked pick level = " .. hit.level)
        example_print_log("stacked pick surface = " .. hit.surface)
        example_print_log("stacked pick cell = " .. hit.x .. "," .. hit.y)
    end
end

--@api: lurek.raycaster.pickScreenMultiLevelFromAdapter
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
        example_print_log("adapter stacked pick = " .. hit.surface .. " @ level " .. hit.level)
    end
end

--@api: LRaycaster:pickScreen
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
        example_print_log("surface = " .. hit.surface)
        example_print_log("cell = " .. hit.x .. "," .. hit.y)
        example_print_log("distance = " .. string.format("%.2f", hit.distance))
        example_print_log("hit = " .. string.format("%.2f", hit.hit_x) .. "," .. string.format("%.2f", hit.hit_y))
        example_print_log("ray angle = " .. string.format("%.3f", hit.ray_angle))
        example_print_log("uv = " .. string.format("%.2f", hit.u) .. "," .. string.format("%.2f", hit.v))
    end
    if sprite_hit then
        example_print_log("sprite surface = " .. sprite_hit.surface)
        example_print_log("sprite id = " .. tostring(sprite_hit.id))
        example_print_log("sprite distance = " .. string.format("%.2f", sprite_hit.distance))
        example_print_log("sprite uv = " .. string.format("%.2f", sprite_hit.u) .. "," .. string.format("%.2f", sprite_hit.v))
    end
    if model_hit then
        example_print_log("model surface = " .. model_hit.surface)
        example_print_log("model id = " .. tostring(model_hit.id))
        example_print_log("model distance = " .. string.format("%.2f", model_hit.distance))
        example_print_log("model uv = " .. string.format("%.2f", model_hit.u) .. "," .. string.format("%.2f", model_hit.v))
    end
    if feature_hit and feature_hit.feature then
        example_print_log("feature kind = " .. feature_hit.feature.kind)
        example_print_log("feature section = " .. feature_hit.feature.section)
        example_print_log("feature wall height = " .. string.format("%.2f", feature_hit.wall_height))
    end
end

--@api: LRaycaster:buildMinimapWindow
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

    example_print_log("sample count = " .. #cells)
    if cells[1] then
        example_print_log("first cell = " .. cells[1].x .. "," .. cells[1].y)
        example_print_log("first luma = " .. string.format("%.2f", cells[1].luma))
    end
end

--@api: LRaycaster:extractMinimap
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(0, 0, 1)
    map:setCell(1, 0, 1)
    map:setCell(0, 1, 1)
    local image = map:extractMinimap(4.0, 4.0, 0.0, 3, 4)
    example_print_log("minimap type = " .. image:type())
    example_print_log("minimap width = " .. image:getWidth())
end

--@api: LRaycaster:projectSprite
do
    local map = lurek.raycaster.new(16, 16)
    local proj = map:projectSprite(10, 8, 8, 8, 0, math.pi / 3, 320)

    example_print_log("screen_x = " .. proj.screen_x)
    example_print_log("scale = " .. string.format("%.2f", proj.scale))
    example_print_log("visible = " .. tostring(proj.visible))
end

--@api: LRaycaster:drawLineOfSight
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(4, 4, 1)

    local img = map:drawLineOfSight(1, 1, 7, 7, 16)

    example_print_log("width = " .. img:getWidth())
    example_print_log("height = " .. img:getHeight())
end

--@api: LRaycaster:drawCameraSweep
do
    local map = lurek.raycaster.new(8, 8)
    for i = 0, 7 do
        map:setCell(i, 0, 1)
        map:setCell(i, 7, 1)
        map:setCell(0, i, 1)
        map:setCell(7, i, 1)
    end

    local strip = map:drawCameraSweep(4, 4, math.pi / 3, 8, 8, 160, 100)

    example_print_log("width = " .. strip:getWidth())
    example_print_log("height = " .. strip:getHeight())
end

--@api: LRaycaster:castFloorRow
do
    local map = lurek.raycaster.new(16, 16)
    local uvs = map:castFloorRow(8, 8, 1, 0, 0, 0.66, 150)

    example_print_log("uv count = " .. #uvs)
    if uvs[1] then
        example_print_log("first uv = " .. string.format("%.2f", uvs[1].u) .. "," .. string.format("%.2f", uvs[1].v))
    end
end

--- Raycaster Module Part 2: buildSceneWithModels, width/height, DoorManager, HeightMap, PointLight, SpriteManager

--@api: LRaycaster:buildSceneWithModels
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

    example_print_log("quad count without model = " .. baseline)
    example_print_log("quad count with model = " .. count)
    if model_pick then
        example_print_log("model pick surface = " .. model_pick.surface)
        example_print_log("model pick id = " .. tostring(model_pick.id))
        example_print_log("model pick distance = " .. string.format("%.2f", model_pick.distance))
        example_print_log("model pick uv = " .. string.format("%.2f", model_pick.u) .. "," .. string.format("%.2f", model_pick.v))
    end
end

--@api: LRaycaster:height
do
    local rc = lurek.raycaster.new(160, 120)
    rc:setCell(10, 10, 1)
    ray_log("height=" .. rc:height())
    ray_log("width=" .. rc:width())
    ray_log("sample cell=" .. rc:getCell(10, 10))
    ray_log("sample blocked=" .. tostring(rc:isBlocked(10, 10)))
end

--@api: LRaycaster:width
do
    local rc = lurek.raycaster.new(160, 120)
    rc:setCell(12, 12, 2)
    ray_log("width=" .. rc:width())
    ray_log("height=" .. rc:height())
    ray_log("sample cell=" .. rc:getCell(12, 12))
    ray_log("sample blocked=" .. tostring(rc:isBlocked(12, 12)))
end

--@api: LDoorManager:addDoor
do
    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    local door = dm:getDoor(id)

    example_print_log("count = " .. dm:count())
    example_print_log("state = " .. door.state)
end

--@api: LDoorManager:closeDoor
do
    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    dm:openDoor(id)
    dm:update(0.5)
    dm:closeDoor(id)
    dm:update(0.25)

    local door = dm:getDoor(id)

    example_print_log("state = " .. door.state)
    example_print_log("open = " .. string.format("%.2f", door.openAmount))
end

--@api: LDoorManager:count
do
    local dm = lurek.raycaster.newDoorManager()
    local first = dm:addDoor(5, 5, "horizontal", 0.5)
    local second = dm:addDoor(6, 5, "vertical", 0.25)
    ray_log("count=" .. dm:count())
    ray_log("first state=" .. dm:getDoor(first).state)
    ray_log("second openAmount=" .. tostring(dm:getDoor(second).openAmount))
    ray_log("ids differ=" .. tostring(first ~= second))
end

--@api: LDoorManager:openDoor
do
    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    dm:openDoor(id)
    dm:update(0.1)

    local door = dm:getDoor(id)

    example_print_log("state = " .. door.state)
    example_print_log("open = " .. string.format("%.2f", door.openAmount))
end

--@api: LDoorManager:update
do
    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    dm:openDoor(id)
    dm:update(0.1)

    local door = dm:getDoor(id)

    example_print_log("state = " .. door.state)
    example_print_log("open = " .. string.format("%.2f", door.openAmount))
end

--@api: LHeightMap:ceilingAt
do
    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(3, 3, 0.2)
    hm:setCeiling(3, 3, 0.9)
    hm:setCeiling(4, 3, 1.1)
    ray_log("ceiling(3,3)=" .. hm:ceilingAt(3, 3))
    ray_log("ceiling(4,3)=" .. hm:ceilingAt(4, 3))
    ray_log("floor(3,3)=" .. hm:floorAt(3, 3))
    ray_log("ceiling authoring supports neighboring tiles")
end

--@api: LHeightMap:floorAt
do
    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(3, 3, 0.2)
    hm:setCeiling(3, 3, 0.9)
    hm:setFloor(4, 3, -0.1)
    ray_log("floor(3,3)=" .. hm:floorAt(3, 3))
    ray_log("floor(4,3)=" .. hm:floorAt(4, 3))
    ray_log("ceiling(3,3)=" .. hm:ceilingAt(3, 3))
    ray_log("floor authoring supports neighboring tiles")
end

--@api: LHeightMap:setCeiling
do
    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setCeiling(3, 3, 0.9)
    hm:setCeiling(3, 4, 1.3)
    ray_log("ceiling(3,3)=" .. hm:ceilingAt(3, 3))
    ray_log("ceiling(3,4)=" .. hm:ceilingAt(3, 4))
    ray_log("floor(3,3)=" .. hm:floorAt(3, 3))
    ray_log("setCeiling updates targeted cells only")
end

--@api: LHeightMap:setFloor
do
    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(3, 3, 0.2)
    hm:setFloor(4, 3, -0.2)
    ray_log("floor(3,3)=" .. hm:floorAt(3, 3))
    ray_log("floor(4,3)=" .. hm:floorAt(4, 3))
    ray_log("ceiling(3,3)=" .. hm:ceilingAt(3, 3))
    ray_log("setFloor updates targeted cells only")
end

--@api: LPointLight:color
do
    local pl = lurek.raycaster.newPointLight(8, 8, 1, 1, 0.8, 5.0, 2.0)
    local r, g, b = pl:color()
    ray_log("color=" .. r .. "," .. g .. "," .. b)
    ray_log("intensity=" .. pl:intensity())
    ray_log("radius=" .. pl:radius())
    ray_log("level=" .. tostring(pl:level()))
end

--@api: LPointLight:intensity
do
    local pl = lurek.raycaster.newPointLight(8, 8, 1, 1, 0.8, 5.0, 2.0)
    local r, g, b = pl:color()
    ray_log("intensity=" .. pl:intensity())
    ray_log("radius=" .. pl:radius())
    ray_log("position=" .. pl:x() .. "," .. pl:y())
    ray_log("color=" .. r .. "," .. g .. "," .. b)
end

--@api: LPointLight:radius
do
    local pl = lurek.raycaster.newPointLight(8, 8, 1, 1, 0.8, 5.0, 2.0)
    local r, g, b = pl:color()
    ray_log("radius=" .. pl:radius())
    ray_log("intensity=" .. pl:intensity())
    ray_log("position=" .. pl:x() .. "," .. pl:y())
    ray_log("color=" .. r .. "," .. g .. "," .. b)
end

--@api: LPointLight:x
do
    local pl = lurek.raycaster.newPointLight(8, 8, 1, 1, 0.8, 5.0, 2.0)
    ray_log("x=" .. pl:x())
    ray_log("y=" .. pl:y())
    ray_log("radius=" .. pl:radius())
    ray_log("intensity=" .. pl:intensity())
end

--@api: LPointLight:y
do
    local pl = lurek.raycaster.newPointLight(8, 8, 1, 1, 0.8, 5.0, 2.0)
    ray_log("y=" .. pl:y())
    ray_log("x=" .. pl:x())
    ray_log("radius=" .. pl:radius())
    ray_log("intensity=" .. pl:intensity())
end

--@api: LSpriteManager:add
do
    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    local projected = sm:sortAndProject(0, 0, 0)
    ray_log("sprite id=" .. id)
    ray_log("projected count=" .. #projected)
    ray_log("first x=" .. tostring(projected[1] and projected[1].x))
    ray_log("first y=" .. tostring(projected[1] and projected[1].y))
end

--@api: LSpriteManager:remove
do
    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    sm:remove(id)

    local projected = sm:sortAndProject(0, 0, 0)

    example_print_log("remaining projected = " .. #projected)
end

--@api: LSpriteManager:setPosition
do
    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    sm:setPosition(id, 6, 6)

    local projected = sm:sortAndProject(0, 0, 0)

    example_print_log("first x = " .. projected[1].x)
    example_print_log("first y = " .. projected[1].y)
end

--@api: LSpriteManager:setLevel
do
    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    sm:setLevel(id, 2)

    local projected = sm:sortAndProject(0, 0, 0)

    example_print_log("level = " .. tostring(projected[1].level))
end

--@api: LSpriteManager:setVisible
do
    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    sm:setVisible(id, false)

    local projected = sm:sortAndProject(0, 0, 0)

    example_print_log("projected count = " .. #projected)
end
