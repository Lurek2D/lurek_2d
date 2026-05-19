-- content/examples/raycaster.lua
-- Auto-generated from content/examples2/raycaster_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/raycaster.lua

--- Raycaster Module Part 1: map creation, cells, ray casting, movement, line of sight, rendering

--@api-stub: lurek.raycaster.new
--@api-stub: lurek.raycaster.newMap
-- Create a raycaster map grid.
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(16, 16)
    print("size = " .. map:width() .. "x" .. map:height())
    ---@type LRaycaster
    local map2 = lurek.raycaster.newMap(32, 32)
    print("alias size = " .. map2:width() .. "x" .. map2:height())
end

--@api-stub: LRaycaster:setCell
--@api-stub: LRaycaster:getCell
--@api-stub: LRaycaster:setCells
-- Setting and reading cell values.
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(8, 8)
    map:setCell(0, 0, 1)
    map:setCell(7, 0, 2)
    map:setCell(0, 7, 3)
    map:setCell(7, 7, 1)
    print("cell 0,0 = " .. map:getCell(0, 0))
    print("cell 4,4 = " .. map:getCell(4, 4))
    local cells = {}
    for i = 1, 64 do cells[i] = 0 end
    for i = 1, 8 do cells[i] = 1 end
    for i = 57, 64 do cells[i] = 1 end
    map:setCells(cells)
    print("after setCells: 0,0 = " .. map:getCell(0, 0))
end

--@api-stub: LRaycaster:isBlocked
--@api-stub: LRaycaster:isWalkBlocked
-- Checking solid cells.
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(8, 8)
    map:setCell(3, 3, 1)
    map:setCell(5, 5, 0)
    print("3,3 blocked = " .. tostring(map:isBlocked(3, 3)))
    print("5,5 blocked = " .. tostring(map:isBlocked(5, 5)))
    print("3,3 walk blocked = " .. tostring(map:isWalkBlocked(3, 3)))
end

--@api-stub: LRaycaster:castRay
-- Cast a single ray and inspect the hit result.
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
    local hit = map:castRay(8, 8, 0, 20)
    if hit then
        print("distance = " .. hit.distance)
        print("cell_value = " .. hit.cell_value)
        print("side = " .. hit.side)
        print("tex_u = " .. hit.tex_u)
        print("hit pos = " .. hit.hit_x .. ", " .. hit.hit_y)
        print("did hit = " .. tostring(hit.hit))
    end
end

--@api-stub: LRaycaster:castRays
-- Cast multiple rays across a field of view.
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
    local hits = map:castRays(8, 8, 0, math.pi / 3, 10, 20)
    print("rays cast = " .. #hits)
    for i, h in ipairs(hits) do
        if h.hit then
            print("  ray " .. i .. ": dist=" .. string.format("%.2f", h.distance))
        end
    end
end

--@api-stub: LRaycaster:castRaysFlat
-- Cast rays and get only distances (faster for depth buffers).
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
    local distances = map:castRaysFlat(8, 8, 0, math.pi / 3, 320, 20)
    print("distance array = " .. #distances)
    print("center dist = " .. string.format("%.2f", distances[160]))
end

--@api-stub: LRaycaster:castRayMulti
-- Cast a ray that penetrates transparent walls.
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(16, 16)
    map:setCell(5, 8, 2)
    map:setCell(10, 8, 1)
    map:setWallAlpha(2, 0.5)
    local hits = map:castRayMulti(2, 8.5, 0, 20, 4)
    print("multi hits = " .. #hits)
    for i, h in ipairs(hits) do
        print("  hit " .. i .. ": dist=" .. string.format("%.2f", h.distance) ..
            " cell=" .. h.cell_value)
    end
end

--@api-stub: LRaycaster:setWallAlpha
--@api-stub: LRaycaster:getWallAlpha
-- Transparent walls.
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(8, 8)
    map:setWallAlpha(1, 1.0)
    map:setWallAlpha(2, 0.5)
    map:setWallAlpha(3, 0.25)
    print("type 1 alpha = " .. map:getWallAlpha(1))
    print("type 2 alpha = " .. map:getWallAlpha(2))
    print("type 3 alpha = " .. map:getWallAlpha(3))
end

--@api-stub: LRaycaster:tryMove
-- Smooth movement with wall-slide collision.
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
    local px, py = 4.5, 4.5
    local nx, ny, moved = map:tryMove(px, py, 0.1, 0)
    print("moved = " .. tostring(moved))
    print("new pos = " .. nx .. ", " .. ny)
    local wx, wy, wmoved = map:tryMove(0.5, 0.5, -1, 0)
    print("wall slide: moved=" .. tostring(wmoved) .. " pos=" .. wx .. "," .. wy)
end

--@api-stub: LRaycaster:gridMove
-- Discrete grid-step movement (dungeon crawler style).
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
    local px, py = 4.5, 4.5
    local dir = 1
    local nx, ny, ok = map:gridMove(px, py, dir, "forward", 1.0)
    print("forward: " .. nx .. "," .. ny .. " ok=" .. tostring(ok))
    nx, ny, ok = map:gridMove(nx, ny, dir, "left", 1.0)
    print("strafe left: " .. nx .. "," .. ny .. " ok=" .. tostring(ok))
end

--@api-stub: LRaycaster:lineOfSight
-- Line-of-sight check between two points.
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(16, 16)
    map:setCell(8, 8, 1)
    local clear = map:lineOfSight(4, 4, 12, 4)
    print("clear path = " .. tostring(clear))
    local blocked = map:lineOfSight(4, 8, 12, 8)
    print("blocked path = " .. tostring(blocked))
end

--@api-stub: LRaycaster:revealCellsFromRays
-- Fog-of-war: reveal visible cells.
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
    map:setCell(6, 8, 1)
    local revealed = map:revealCellsFromRays(8, 8, 0, math.pi * 2, 64, 10)
    print("revealed cells = " .. #revealed)
    if #revealed > 0 then
        print("first: " .. revealed[1].x .. "," .. revealed[1].y)
    end
end

--@api-stub: LRaycaster:drawView
-- Render a flat-shaded first-person view.
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
    ---@type LImageData
    local img = map:drawView(8, 8, 0, math.pi / 3, 320, 200, 16)
    print("view image created")
end

--@api-stub: LRaycaster:drawTopDown
-- Render a top-down debug view.
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
    map:setCell(3, 3, 1)
    ---@type LImageData
    local img = map:drawTopDown(4.5, 4.5, 0, 16)
    print("top-down image created")
end

--@api-stub: LRaycaster:drawDepthMap
-- Render a grayscale depth map.
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
    ---@type LImageData
    local depth = map:drawDepthMap(8, 8, 0, math.pi / 3, 160, 160, 100, 16)
    print("depth map created")
end

--@api-stub: lurek.raycaster.distanceShade
-- Distance-based fog shading factor.
do
    local bright = lurek.raycaster.distanceShade(0, 10)
    local mid = lurek.raycaster.distanceShade(5, 10)
    local dark = lurek.raycaster.distanceShade(9, 10)
    print("dist 0: " .. string.format("%.2f", bright))
    print("dist 5: " .. string.format("%.2f", mid))
    print("dist 9: " .. string.format("%.2f", dark))
end

--@api-stub: lurek.raycaster.projectColumn
-- Compute projected wall height from distance.
do
    local h1 = lurek.raycaster.projectColumn(1.0, math.pi / 3, 200)
    local h2 = lurek.raycaster.projectColumn(5.0, math.pi / 3, 200)
    local h3 = lurek.raycaster.projectColumn(10.0, math.pi / 3, 200)
    print("dist 1 height = " .. string.format("%.1f", h1))
    print("dist 5 height = " .. string.format("%.1f", h2))
    print("dist 10 height = " .. string.format("%.1f", h3))
end

--@api-stub: LRaycaster:type
--@api-stub: LRaycaster:typeOf
-- Type checking.
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(8, 8)
    print("type = " .. map:type())
    print("is LRaycaster = " .. tostring(map:typeOf("LRaycaster")))
    print("is Object = " .. tostring(map:typeOf("Object")))
end

-- Practical: procedurally fill a raycaster map.
--@api-stub: lurek.raycaster.new
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(32, 32)
    for x = 0, 31 do
        for y = 0, 31 do
            if x == 0 or x == 31 or y == 0 or y == 31 then
                map:setCell(x, y, 1)
            end
        end
    end
    for i = 1, 10 do
        local wx = math.random(2, 29)
        local wy = math.random(2, 29)
        map:setCell(wx, wy, 2)
    end
    print("dungeon map: " .. map:width() .. "x" .. map:height())
    local hit = map:castRay(16, 16, math.pi / 4, 30)
    if hit then
        print("ray hit at dist " .. string.format("%.2f", hit.distance))
    end
end

--- Raycaster Module Part 2: doors, height maps, lights, sprites, floor/ceiling, scene building, minimap

--@api-stub: lurek.raycaster.newDoorManager
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

-- Creating stepped terrain (staircase).
--@api-stub: lurek.raycaster.newHeightMap
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

print("content/examples/raycaster.lua")
