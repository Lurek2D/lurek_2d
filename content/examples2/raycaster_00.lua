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

--@api-stub: practical — building a dungeon map
-- Practical: procedurally fill a raycaster map.
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

print("raycaster_00.lua")
