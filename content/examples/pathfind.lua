-- content/examples/pathfind.lua
-- Auto-generated from content/examples2/pathfind_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/pathfind.lua

--- Pathfinding Module Part 1: grid pathfinding basics (LPathGrid, LNavGrid)

--@api-stub: lurek.pathfind.newPathGrid
do
    local grid = lurek.pathfind.newPathGrid(20, 15, 32)

    print("grid = " .. grid:getWidth() .. "x" .. grid:getHeight())
    print("cell_size = " .. grid:getCellSize())
end

--@api-stub: LPathGrid:setWalkable
do
    local grid = lurek.pathfind.newPathGrid(20, 15, 32)

    grid:setWalkable(5, 5, false)

    print("walkable_5_5 = " .. tostring(grid:isWalkable(5, 5)))
    print("walkable_5_6 = " .. tostring(grid:isWalkable(5, 6)))
end

--@api-stub: LPathGrid:isWalkable
do
    local grid = lurek.pathfind.newPathGrid(20, 15, 32)

    grid:setWalkable(4, 4, false)

    print("walkable_4_4 = " .. tostring(grid:isWalkable(4, 4)))
    print("walkable_4_5 = " .. tostring(grid:isWalkable(4, 5)))
end

--@api-stub: LPathGrid:setCost
do
    local grid = lurek.pathfind.newPathGrid(10, 10, 16)

    grid:setCost(3, 3, 5)

    print("cost_3_3 = " .. grid:getCost(3, 3))
    print("cost_3_4 = " .. grid:getCost(3, 4))
end

--@api-stub: LPathGrid:getCost
do
    local grid = lurek.pathfind.newPathGrid(10, 10, 16)

    grid:setCost(6, 2, 2.5)

    print("cost_6_2 = " .. grid:getCost(6, 2))
    print("cost_1_1 = " .. grid:getCost(1, 1))
end

--@api-stub: LPathGrid:findPath
do
    local grid = lurek.pathfind.newPathGrid(10, 10, 32)

    for y = 1, 10 do
        grid:setWalkable(5, y, false)
    end
    grid:setWalkable(5, 8, true)

    local path = grid:findPath(1, 1, 10, 10)
    if path then
        print("steps = " .. #path)
        print("first = " .. path[1].x .. "," .. path[1].y)
        print("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        print("steps = 0")
    end
end

--@api-stub: LPathGrid:findPathSmoothed
do
    local grid = lurek.pathfind.newPathGrid(20, 20, 16)

    grid:setWalkable(10, 5, false)
    grid:setWalkable(10, 6, false)
    grid:setWalkable(10, 7, false)

    local path = grid:findPathSmoothed(1, 5, 20, 5)
    if path then
        print("points = " .. #path)
        print("first = " .. path[1].x .. "," .. path[1].y)
        print("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        print("points = 0")
    end
end

--@api-stub: LPathGrid:type
do
    local grid = lurek.pathfind.newPathGrid(5, 5, 32)

    print("type = " .. grid:type())
end

--@api-stub: LPathGrid:typeOf
do
    local grid = lurek.pathfind.newPathGrid(5, 5, 32)

    print("is_path_grid = " .. tostring(grid:typeOf("LPathGrid")))
    print("is_object = " .. tostring(grid:typeOf("LObject")))
end

--@api-stub: lurek.pathfind.newNavGrid
do
    local nav = lurek.pathfind.newNavGrid(50, 50)
    local w, h = nav:getDimensions()

    print("dims = " .. w .. "x" .. h)
    print("chunk = " .. nav:getChunkSize())
end

--@api-stub: LNavGrid:setBlocked
do
    local nav = lurek.pathfind.newNavGrid(30, 30)

    nav:setBlocked(10, 10, true)

    print("blocked_10_10 = " .. tostring(nav:isBlocked(10, 10)))
    print("cost_10_10 = " .. nav:getCost(10, 10))
end

--@api-stub: LNavGrid:isBlocked
do
    local nav = lurek.pathfind.newNavGrid(30, 30)

    nav:setBlocked(12, 12, true)

    print("blocked_12_12 = " .. tostring(nav:isBlocked(12, 12)))
    print("blocked_12_13 = " .. tostring(nav:isBlocked(12, 13)))
end

--@api-stub: LNavGrid:setCost
do
    local nav = lurek.pathfind.newNavGrid(30, 30)

    nav:setCost(5, 5, 200)

    print("cost_5_5 = " .. nav:getCost(5, 5))
    print("blocked_5_5 = " .. tostring(nav:isBlocked(5, 5)))
end

--@api-stub: LNavGrid:getCost
do
    local nav = lurek.pathfind.newNavGrid(30, 30)

    nav:setCost(7, 8, 4)

    print("cost_7_8 = " .. nav:getCost(7, 8))
    print("cost_1_1 = " .. nav:getCost(1, 1))
end

--@api-stub: LNavGrid:isWalkable
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)
    nav:setBlocked(6, 6, true)

    print("walkable_1x1 = " .. tostring(nav:isWalkable(5, 5)))
    print("walkable_blocked = " .. tostring(nav:isWalkable(6, 6)))
    print("walkable_2x2 = " .. tostring(nav:isWalkable(5, 5, 2)))
end

--@api-stub: LNavGrid:fill
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(3)

    print("cost_1_1 = " .. nav:getCost(1, 1))
    print("cost_20_20 = " .. nav:getCost(20, 20))
end

--@api-stub: LNavGrid:fillRect
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fillRect(5, 5, 5, 5, 0)

    print("blocked_5_5 = " .. tostring(nav:isBlocked(5, 5)))
    print("blocked_10_10 = " .. tostring(nav:isBlocked(10, 10)))
    print("blocked_11_11 = " .. tostring(nav:isBlocked(11, 11)))
end

--@api-stub: LNavGrid:setDiagonalMode
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:setDiagonalMode("always")

    print("mode = " .. nav:getDiagonalMode())
end

--@api-stub: LNavGrid:getDiagonalMode
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:setDiagonalMode("nocornercut")

    print("mode = " .. nav:getDiagonalMode())
end

--@api-stub: LNavGrid:setChunkSize
do
    local nav = lurek.pathfind.newNavGrid(100, 100)

    nav:setChunkSize(16)
    nav:rebuildAbstract()

    print("chunk = " .. nav:getChunkSize())
end

--@api-stub: LNavGrid:getChunkSize
do
    local nav = lurek.pathfind.newNavGrid(100, 100)

    nav:setChunkSize(12)

    print("chunk = " .. nav:getChunkSize())
end

--@api-stub: LNavGrid:rebuildAbstract
do
    local nav = lurek.pathfind.newNavGrid(64, 64)

    nav:setChunkSize(8)
    nav:rebuildAbstract()

    print("chunk = " .. nav:getChunkSize())
    print("blocked_1_1 = " .. tostring(nav:isBlocked(1, 1)))
end

--@api-stub: LNavGrid:setDirty
do
    local nav = lurek.pathfind.newNavGrid(50, 50)

    nav:setChunkSize(10)
    nav:rebuildAbstract()
    nav:setBlocked(25, 25, true)
    nav:setDirty(20, 20, 10, 10)
    nav:rebuildAbstract()

    print("blocked_25_25 = " .. tostring(nav:isBlocked(25, 25)))
    print("chunk = " .. nav:getChunkSize())
end

--@api-stub: LNavGrid:clearDirty
do
    local nav = lurek.pathfind.newNavGrid(50, 50)

    nav:setChunkSize(10)
    nav:setDirty(20, 20, 10, 10)
    nav:clearDirty()
    nav:rebuildAbstract()

    print("chunk = " .. nav:getChunkSize())
end

--@api-stub: LNavGrid:saveToString
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:setBlocked(5, 5, true)
    nav:setCost(3, 3, 9)

    local data = nav:saveToString()

    print("bytes = " .. #data)
    print("blocked_5_5 = " .. tostring(nav:isBlocked(5, 5)))
end

--@api-stub: LNavGrid:loadFromString
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:setBlocked(5, 5, true)
    nav:setCost(3, 3, 9)

    local data = nav:saveToString()
    local nav2 = lurek.pathfind.newNavGrid(10, 10)
    nav2:loadFromString(data)

    print("blocked_5_5 = " .. tostring(nav2:isBlocked(5, 5)))
    print("cost_3_3 = " .. nav2:getCost(3, 3))
end

--@api-stub: LNavGrid:type
do
    local nav = lurek.pathfind.newNavGrid(5, 5)

    print("type = " .. nav:type())
end

--@api-stub: LNavGrid:typeOf
do
    local nav = lurek.pathfind.newNavGrid(5, 5)

    print("is_nav_grid = " .. tostring(nav:typeOf("LNavGrid")))
    print("is_object = " .. tostring(nav:typeOf("LObject")))
end

--- Pathfinding Module Part 2: navmesh, hex grid, JPS grid

--@api-stub: lurek.pathfind.newNavMesh
do
    local mesh = lurek.pathfind.newNavMesh()
    local id1 = mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 100, y = 0 },
        { x = 50, y = 80 },
    })
    local id2 = mesh:addPolygon({
        { x = 50, y = 80 },
        { x = 100, y = 0 },
        { x = 150, y = 80 },
    })

    print("polygons = " .. mesh:getPolygonCount())
    print("ids = " .. id1 .. "," .. id2)
end

--@api-stub: LNavMesh:addPolygon
do
    local mesh = lurek.pathfind.newNavMesh()
    local id = mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 60, y = 0 },
        { x = 30, y = 45 },
    })

    print("polygon_id = " .. id)
    print("polygon_count = " .. mesh:getPolygonCount())
end

--@api-stub: LNavMesh:connectPolygons
do
    local mesh = lurek.pathfind.newNavMesh()
    local a = mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 50, y = 0 },
        { x = 25, y = 40 },
    })
    local b = mesh:addPolygon({
        { x = 50, y = 0 },
        { x = 100, y = 0 },
        { x = 75, y = 40 },
    })
    local c = mesh:addPolygon({
        { x = 25, y = 40 },
        { x = 75, y = 40 },
        { x = 50, y = 80 },
    })
    local ab = mesh:connectPolygons(a, b, true)
    local bc = mesh:connectPolygons(b, c, false)

    print("connected_ab = " .. tostring(ab))
    print("connected_bc = " .. tostring(bc))
    print("polygon_count = " .. mesh:getPolygonCount())
end

--@api-stub: LNavMesh:findPath
do
    local mesh = lurek.pathfind.newNavMesh()
    local p1 = mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 100, y = 0 },
        { x = 100, y = 100 },
        { x = 0, y = 100 },
    })
    local p2 = mesh:addPolygon({
        { x = 100, y = 0 },
        { x = 200, y = 0 },
        { x = 200, y = 100 },
        { x = 100, y = 100 },
    })
    local p3 = mesh:addPolygon({
        { x = 200, y = 0 },
        { x = 300, y = 0 },
        { x = 300, y = 100 },
        { x = 200, y = 100 },
    })

    mesh:connectPolygons(p1, p2, true)
    mesh:connectPolygons(p2, p3, true)

    local path = mesh:findPath(10, 50, 290, 50)
    if path then
        print("waypoints = " .. #path)
        print("first = " .. path[1].x .. "," .. path[1].y)
        print("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        print("waypoints = 0")
    end
end

--@api-stub: LNavMesh:type
do
    local mesh = lurek.pathfind.newNavMesh()

    print("type = " .. mesh:type())
end

--@api-stub: LNavMesh:typeOf
do
    local mesh = lurek.pathfind.newNavMesh()

    print("is_nav_mesh = " .. tostring(mesh:typeOf("LNavMesh")))
    print("is_object = " .. tostring(mesh:typeOf("LObject")))
end

--@api-stub: lurek.pathfind.newHexGrid
do
    local hex = lurek.pathfind.newHexGrid(12, 10, "flat")

    hex:setBlocked(5, 5, true)
    hex:setBlocked(6, 5, true)

    print("blocked_5_5 = " .. tostring(hex:isBlocked(5, 5)))
    print("blocked_1_1 = " .. tostring(hex:isBlocked(1, 1)))
end

--@api-stub: LHexGrid:setBlocked
do
    local hex = lurek.pathfind.newHexGrid(12, 10, "flat")

    hex:setBlocked(5, 5, true)
    hex:setBlocked(6, 5, true)

    print("blocked_5_5 = " .. tostring(hex:isBlocked(5, 5)))
    print("blocked_6_5 = " .. tostring(hex:isBlocked(6, 5)))
end

--@api-stub: LHexGrid:isBlocked
do
    local hex = lurek.pathfind.newHexGrid(12, 10, "flat")

    hex:setBlocked(4, 4, true)

    print("blocked_4_4 = " .. tostring(hex:isBlocked(4, 4)))
    print("blocked_4_5 = " .. tostring(hex:isBlocked(4, 5)))
end

--@api-stub: LHexGrid:setCost
do
    local hex = lurek.pathfind.newHexGrid(8, 8)

    hex:setCost(4, 4, 4)
    hex:setCost(5, 4, 4)

    local reachable = hex:rangeOfMovement(4, 4, 4)
    print("reachable = " .. #reachable)
    if #reachable > 0 then
        print("first = " .. reachable[1].col .. "," .. reachable[1].row)
    end
end

--@api-stub: LHexGrid:findPath
do
    local hex = lurek.pathfind.newHexGrid(10, 10)

    hex:setBlocked(5, 3, true)
    hex:setBlocked(5, 4, true)
    hex:setBlocked(5, 5, true)

    local path = hex:findPath(1, 5, 10, 5)
    if path then
        print("steps = " .. #path)
        print("first = " .. path[1].col .. "," .. path[1].row)
        print("last = " .. path[#path].col .. "," .. path[#path].row)
    else
        print("steps = 0")
    end
end

--@api-stub: LHexGrid:distance
do
    local hex = lurek.pathfind.newHexGrid(10, 10)

    print("dist_1_1_to_5_5 = " .. hex:distance(1, 1, 5, 5))
    print("dist_1_1_to_1_1 = " .. hex:distance(1, 1, 1, 1))
end

--@api-stub: LHexGrid:lineOfSight
do
    local hex = lurek.pathfind.newHexGrid(10, 10)

    local clear = hex:lineOfSight(1, 1, 10, 10)
    hex:setBlocked(5, 5, true)
    local blocked = hex:lineOfSight(1, 1, 10, 10)

    print("clear = " .. tostring(clear))
    print("blocked = " .. tostring(blocked))
end

--@api-stub: LHexGrid:fieldOfView
do
    local hex = lurek.pathfind.newHexGrid(15, 15)

    hex:setBlocked(8, 8, true)

    local visible = hex:fieldOfView(7, 7, 3)
    print("visible = " .. #visible)
    if #visible > 0 then
        print("first = " .. visible[1].col .. "," .. visible[1].row)
    end
end

--@api-stub: LHexGrid:rangeOfMovement
do
    local hex = lurek.pathfind.newHexGrid(12, 12)

    hex:setCost(6, 6, 3)

    local reachable = hex:rangeOfMovement(6, 6, 4)
    print("reachable = " .. #reachable)
    if #reachable > 0 then
        print("first = " .. reachable[1].col .. "," .. reachable[1].row)
    end
end

--@api-stub: LHexGrid:type
do
    local hex = lurek.pathfind.newHexGrid(5, 5, "pointy")

    print("type = " .. hex:type())
end

--@api-stub: LHexGrid:typeOf
do
    local hex = lurek.pathfind.newHexGrid(5, 5, "pointy")

    print("is_hex_grid = " .. tostring(hex:typeOf("LHexGrid")))
    print("is_object = " .. tostring(hex:typeOf("LObject")))
end

--@api-stub: lurek.pathfind.newJpsGrid
do
    local jps = lurek.pathfind.newJpsGrid(30, 30)

    jps:setBlocked(15, 10, true)
    jps:setBlocked(15, 11, true)
    jps:setBlocked(15, 12, true)

    print("blocked_15_10 = " .. tostring(jps:isBlocked(15, 10)))
    print("blocked_1_1 = " .. tostring(jps:isBlocked(1, 1)))
end

--@api-stub: LJpsGrid:setBlocked
do
    local jps = lurek.pathfind.newJpsGrid(30, 30)

    jps:setBlocked(15, 10, true)
    jps:setBlocked(15, 11, true)
    jps:setBlocked(15, 12, true)

    print("blocked_15_10 = " .. tostring(jps:isBlocked(15, 10)))
    print("blocked_15_12 = " .. tostring(jps:isBlocked(15, 12)))
end

--@api-stub: LJpsGrid:isBlocked
do
    local jps = lurek.pathfind.newJpsGrid(30, 30)

    jps:setBlocked(9, 9, true)

    print("blocked_9_9 = " .. tostring(jps:isBlocked(9, 9)))
    print("blocked_9_10 = " .. tostring(jps:isBlocked(9, 10)))
end

--@api-stub: LJpsGrid:findPath
do
    local jps = lurek.pathfind.newJpsGrid(50, 50)

    for y = 10, 40 do
        jps:setBlocked(25, y, true)
    end
    jps:setBlocked(25, 30, false)

    local path = jps:findPath(1, 25, 50, 25)
    if path then
        print("points = " .. #path)
        print("first = " .. path[1].x .. "," .. path[1].y)
        print("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        print("points = 0")
    end
end

--@api-stub: LJpsGrid:type
do
    local jps = lurek.pathfind.newJpsGrid(5, 5)

    print("type = " .. jps:type())
end

--@api-stub: LJpsGrid:typeOf
do
    local jps = lurek.pathfind.newJpsGrid(5, 5)

    print("is_jps_grid = " .. tostring(jps:typeOf("LJpsGrid")))
    print("is_object = " .. tostring(jps:typeOf("LObject")))
end

--- Pathfinding Module Part 3: flow fields, AI flow fields, unit pathfinder

--@api-stub: lurek.pathfind.newFlowField
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)
    nav:setBlocked(10, 5, true)
    nav:setBlocked(10, 6, true)
    nav:setBlocked(10, 7, true)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(20, 10)

    print("calculated = " .. tostring(ff:isCalculated()))
    print("targets = " .. #ff:getTargets())
end

--@api-stub: LFlowField:calculate
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(20, 10)

    print("calculated = " .. tostring(ff:isCalculated()))
    print("targets = " .. #ff:getTargets())
end

--@api-stub: LFlowField:getDirection
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)

    local dx, dy = ff:getDirection(1, 1)
    print("dir = " .. dx .. "," .. dy)
    print("angle = " .. ff:getDirectionAngle(1, 1))
    print("cost = " .. ff:getCostToTarget(1, 1))
end

--@api-stub: LFlowField:getDirectionAngle
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)

    print("angle = " .. ff:getDirectionAngle(1, 1))
    print("cost = " .. ff:getCostToTarget(1, 1))
end

--@api-stub: LFlowField:getCostToTarget
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)

    local dx, dy = ff:getDirection(1, 1)
    print("dir = " .. dx .. "," .. dy)
    print("cost = " .. ff:getCostToTarget(1, 1))
end

--@api-stub: LFlowField:calculateMulti
do
    local nav = lurek.pathfind.newNavGrid(15, 15)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculateMulti({
        { x = 5, y = 5 },
        { x = 10, y = 10 },
    })

    local targets = ff:getTargets()
    print("targets = " .. #targets)
    print("first = " .. targets[1].x .. "," .. targets[1].y)
    print("last = " .. targets[#targets].x .. "," .. targets[#targets].y)
end

--@api-stub: LFlowField:getTargets
do
    local nav = lurek.pathfind.newNavGrid(15, 15)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculateMulti({
        { x = 4, y = 4 },
        { x = 12, y = 12 },
    })

    local targets = ff:getTargets()
    print("targets = " .. #targets)
    print("first = " .. targets[1].x .. "," .. targets[1].y)
end

--@api-stub: LFlowField:steer
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)

    local vx, vy = ff:steer(50, 50, 100, 32, 32)
    print("velocity = " .. vx .. "," .. vy)
end

--@api-stub: LFlowField:type
do
    local nav = lurek.pathfind.newNavGrid(5, 5)
    local ff = lurek.pathfind.newFlowField(nav)

    print("type = " .. ff:type())
end

--@api-stub: LFlowField:typeOf
do
    local nav = lurek.pathfind.newNavGrid(5, 5)
    local ff = lurek.pathfind.newFlowField(nav)

    print("is_flow_field = " .. tostring(ff:typeOf("LFlowField")))
    print("is_object = " .. tostring(ff:typeOf("LObject")))
end

--@api-stub: lurek.pathfind.newPathFlowField
do
    local grid = lurek.pathfind.newPathGrid(15, 15, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local gx, gy = aiff:getGoal()
    print("dims = " .. aiff:getWidth() .. "x" .. aiff:getHeight())
    print("has_goal = " .. tostring(aiff:hasGoal()))
    print("goal = " .. gx .. "," .. gy)
end

--@api-stub: LAIFlowField:setGoal
do
    local grid = lurek.pathfind.newPathGrid(15, 15, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local gx, gy = aiff:getGoal()
    print("has_goal = " .. tostring(aiff:hasGoal()))
    print("goal = " .. gx .. "," .. gy)
end

--@api-stub: LAIFlowField:getGoal
do
    local grid = lurek.pathfind.newPathGrid(15, 15, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local gx, gy = aiff:getGoal()
    print("goal = " .. gx .. "," .. gy)
    print("has_goal = " .. tostring(aiff:hasGoal()))
end

--@api-stub: LAIFlowField:getDirection
do
    local grid = lurek.pathfind.newPathGrid(10, 10, 16)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local dx, dy = aiff:getDirection(1, 1)
    print("dir = " .. dx .. "," .. dy)
    print("distance = " .. aiff:getDistance(1, 1))
end

--@api-stub: LAIFlowField:getDistance
do
    local grid = lurek.pathfind.newPathGrid(10, 10, 16)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local dx, dy = aiff:getDirection(1, 1)
    print("dir = " .. dx .. "," .. dy)
    print("distance = " .. aiff:getDistance(1, 1))
end

--@api-stub: LAIFlowField:type
do
    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    print("type = " .. aiff:type())
end

--@api-stub: LAIFlowField:typeOf
do
    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    print("is_ai_flow_field = " .. tostring(aiff:typeOf("LAIFlowField")))
    print("is_object = " .. tostring(aiff:typeOf("LObject")))
end

--@api-stub: lurek.pathfind.newPathfinder
do
    local nav = lurek.pathfind.newNavGrid(30, 30)

    nav:fill(1)
    nav:setBlocked(15, 10, true)
    nav:setBlocked(15, 11, true)
    nav:setBlocked(15, 12, true)
    nav:setBlocked(15, 13, true)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPath(1, 12, 30, 12)
    if path then
        print("steps = " .. #path)
        print("first = " .. path[1].x .. "," .. path[1].y)
        print("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        print("steps = 0")
    end
end

--@api-stub: LUnitPathfinder:findPath
do
    local nav = lurek.pathfind.newNavGrid(30, 30)

    nav:fill(1)
    nav:setBlocked(15, 10, true)
    nav:setBlocked(15, 11, true)
    nav:setBlocked(15, 12, true)
    nav:setBlocked(15, 13, true)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPath(1, 12, 30, 12)
    if path then
        print("steps = " .. #path)
        print("first = " .. path[1].x .. "," .. path[1].y)
        print("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        print("steps = 0")
    end
end

--@api-stub: LUnitPathfinder:findPathSmooth
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPathSmooth(1, 1, 20, 20)
    if path then
        print("points = " .. #path)
        print("first = " .. path[1].x .. "," .. path[1].y)
        print("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        print("points = 0")
    end
end

--@api-stub: LUnitPathfinder:findPathBidirectional
do
    local nav = lurek.pathfind.newNavGrid(40, 40)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path, complete = pf:findPathBidirectional(1, 1, 40, 40, 1, 500)
    if path then
        print("points = " .. #path)
        print("complete = " .. tostring(complete))
        print("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        print("complete = " .. tostring(complete))
    end
end

--@api-stub: LUnitPathfinder:findPartialPath
do
    local nav = lurek.pathfind.newNavGrid(100, 100)

    nav:fill(1)
    nav:fillRect(40, 1, 1, 100, 0)
    nav:fillRect(40, 50, 1, 1, 1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path, reached = pf:findPartialPath(1, 1, 100, 100, 50)

    print("points = " .. #path)
    print("reached = " .. tostring(reached))
    print("last = " .. path[#path].x .. "," .. path[#path].y)
end

--@api-stub: LUnitPathfinder:isReachable
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)
    nav:fillRect(10, 1, 1, 20, 0)

    local pf = lurek.pathfind.newPathfinder(nav)

    print("reachable_left = " .. tostring(pf:isReachable(1, 1, 9, 9)))
    print("reachable_right = " .. tostring(pf:isReachable(1, 1, 20, 20)))
end

--@api-stub: LUnitPathfinder:lineOfSight
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local clear = pf:lineOfSight(1, 1, 20, 20)
    nav:setBlocked(10, 10, true)
    local blocked = pf:lineOfSight(1, 1, 20, 20)

    print("clear = " .. tostring(clear))
    print("blocked = " .. tostring(blocked))
end

--@api-stub: LUnitPathfinder:heuristicDistance
do
    local nav = lurek.pathfind.newNavGrid(20, 20)
    local pf = lurek.pathfind.newPathfinder(nav)

    print("dist_1_1_to_20_20 = " .. pf:heuristicDistance(1, 1, 20, 20))
    print("dist_5_5_to_5_5 = " .. pf:heuristicDistance(5, 5, 5, 5))
end

--@api-stub: LUnitPathfinder:findNearestWalkable
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)
    nav:setBlocked(10, 10, true)
    nav:setBlocked(11, 10, true)
    nav:setBlocked(10, 11, true)
    nav:setBlocked(11, 11, true)

    local pf = lurek.pathfind.newPathfinder(nav)
    local nx, ny = pf:findNearestWalkable(10, 10, 5)

    print("nearest = " .. nx .. "," .. ny)
end

--@api-stub: LUnitPathfinder:getPathCost
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)
    nav:setCost(5, 5, 4)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPath(1, 1, 10, 10)
    if path then
        print("cost = " .. pf:getPathCost(path))
        print("length = " .. pf:getPathLength(path))
    else
        print("cost = 0")
    end
end

--@api-stub: LUnitPathfinder:getPathLength
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPath(1, 1, 10, 10)
    if path then
        print("length = " .. pf:getPathLength(path))
        print("cost = " .. pf:getPathCost(path))
    else
        print("length = 0")
    end
end

--@api-stub: LUnitPathfinder:setCacheEnabled
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    pf:setCacheMaxSize(100)
    pf:findPath(1, 1, 20, 20)
    pf:findPath(5, 5, 15, 15)

    print("enabled = " .. tostring(pf:isCacheEnabled()))
    print("cache_size = " .. pf:getCacheSize())
    pf:clearCache()
    print("cache_after_clear = " .. pf:getCacheSize())
end

--@api-stub: LUnitPathfinder:isCacheEnabled
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    local enabled = pf:isCacheEnabled()
    pf:setCacheEnabled(false)

    print("enabled_before_disable = " .. tostring(enabled))
    print("enabled_after_disable = " .. tostring(pf:isCacheEnabled()))
end

--@api-stub: LUnitPathfinder:setCacheMaxSize
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    pf:setCacheMaxSize(2)
    pf:findPath(1, 1, 20, 20)
    pf:findPath(2, 2, 19, 19)
    pf:findPath(3, 3, 18, 18)

    print("cache_size = " .. pf:getCacheSize())
end

--@api-stub: LUnitPathfinder:getCacheSize
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    pf:findPath(1, 1, 20, 20)
    pf:findPath(5, 5, 15, 15)

    print("cache_size = " .. pf:getCacheSize())
end

--@api-stub: LUnitPathfinder:clearCache
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    pf:findPath(1, 1, 20, 20)

    print("cache_before_clear = " .. pf:getCacheSize())
    pf:clearCache()
    print("cache_after_clear = " .. pf:getCacheSize())
end

--@api-stub: LUnitPathfinder:type
do
    local nav = lurek.pathfind.newNavGrid(5, 5)
    local pf = lurek.pathfind.newPathfinder(nav)

    print("type = " .. pf:type())
end

--@api-stub: LUnitPathfinder:typeOf
do
    local nav = lurek.pathfind.newNavGrid(5, 5)
    local pf = lurek.pathfind.newPathfinder(nav)

    print("is_pathfinder = " .. tostring(pf:typeOf("LUnitPathfinder")))
    print("is_object = " .. tostring(pf:typeOf("LObject")))
end

--@api-stub: lurek.pathfind.rangeMap
do
    local result = lurek.pathfind.rangeMap({
        width = 10,
        height = 10,
        origin_x = 5,
        origin_y = 5,
        budget = 4,
        diagonal = true,
    })

    print("dims = " .. result.width .. "x" .. result.height)
    print("cells = " .. #result.cells)
    if #result.cells > 0 then
        print("first = " .. result.cells[1].x .. "," .. result.cells[1].y .. "," .. result.cells[1].cost)
    end
end

--@api-stub: lurek.pathfind.getThreadCount
do
    local tc = lurek.pathfind.getThreadCount()

    print("thread_count = " .. tc)
end

--- Pathfind Module Part 4: AI flow field state, nav dimensions, tilemap nav grids, thread count

--@api-stub: LAIFlowField:getHeight
do
    local pg = lurek.pathfind.newPathGrid(32, 32, 1)
    local ff = lurek.pathfind.newPathFlowField(pg)

    ff:setGoal(16, 16)

    print("dims = " .. ff:getWidth() .. "x" .. ff:getHeight())
    print("has_goal = " .. tostring(ff:hasGoal()))
end

--@api-stub: LAIFlowField:getWidth
do
    local pg = lurek.pathfind.newPathGrid(32, 32, 1)
    local ff = lurek.pathfind.newPathFlowField(pg)

    ff:setGoal(16, 16)

    print("dims = " .. ff:getWidth() .. "x" .. ff:getHeight())
    print("has_goal = " .. tostring(ff:hasGoal()))
end

--@api-stub: LAIFlowField:hasGoal
do
    local pg = lurek.pathfind.newPathGrid(32, 32, 1)
    local ff = lurek.pathfind.newPathFlowField(pg)

    print("has_goal_before = " .. tostring(ff:hasGoal()))
    ff:setGoal(16, 16)
    print("has_goal_after = " .. tostring(ff:hasGoal()))
end

--@api-stub: LFlowField:isCalculated
do
    local grid = lurek.pathfind.newNavGrid(16, 16)
    local ff = lurek.pathfind.newFlowField(grid)

    print("calculated_before = " .. tostring(ff:isCalculated()))
    ff:calculate(8, 8, 1)
    print("calculated_after = " .. tostring(ff:isCalculated()))
end

--@api-stub: LNavGrid:getDimensions
do
    local ng = lurek.pathfind.newNavGrid(20, 15)
    local w, h = ng:getDimensions()

    print("dims = " .. w .. "x" .. h)
    print("width = " .. ng:getWidth())
end

--@api-stub: LNavGrid:getHeight
do
    local ng = lurek.pathfind.newNavGrid(20, 15)
    local w, h = ng:getDimensions()

    print("dims = " .. w .. "x" .. h)
    print("height = " .. h)
end

--@api-stub: LNavGrid:getWidth
do
    local ng = lurek.pathfind.newNavGrid(20, 15)
    local w, h = ng:getDimensions()

    print("dims = " .. w .. "x" .. h)
    print("width = " .. w)
end

--@api-stub: LNavMesh:getPolygonCount
do
    local mesh = lurek.pathfind.newNavMesh()
    local id = mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 64, y = 0 },
        { x = 32, y = 48 },
    })

    print("polygon_count = " .. mesh:getPolygonCount())
    print("first_id = " .. id)
end

--@api-stub: LPathGrid:getCellSize
do
    local pg = lurek.pathfind.newPathGrid(10, 10, 32)

    print("cell_size = " .. pg:getCellSize())
    print("dims = " .. pg:getWidth() .. "x" .. pg:getHeight())
end

--@api-stub: LPathGrid:getHeight
do
    local pg = lurek.pathfind.newPathGrid(10, 10, 32)

    print("height = " .. pg:getHeight())
    print("cell_size = " .. pg:getCellSize())
end

--@api-stub: LPathGrid:getWidth
do
    local pg = lurek.pathfind.newPathGrid(10, 10, 32)

    print("width = " .. pg:getWidth())
    print("cell_size = " .. pg:getCellSize())
end

--@api-stub: lurek.pathfind.newNavGridFromTileMap
do
    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local layer_index = tm:addLayer("ground", 8, 8)

    tm:setTile(layer_index, 3, 3, 2)
    tm:setTile(layer_index, 4, 3, 1)

    local ng = lurek.pathfind.newNavGridFromTileMap(tm, layer_index, { 2 })

    print("dims = " .. ng:getWidth() .. "x" .. ng:getHeight())
    print("blocked_3_3 = " .. tostring(ng:isBlocked(3, 3)))
    print("blocked_4_3 = " .. tostring(ng:isBlocked(4, 3)))
end

--@api-stub: lurek.pathfind.setThreadCount
do
    lurek.pathfind.setThreadCount(2)

    print("thread_count = " .. lurek.pathfind.getThreadCount())
end
