-- content/examples/pathfind.lua
-- Auto-generated from content/examples2/pathfind_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/pathfind.lua

--- Pathfinding Module Part 1: grid pathfinding basics (LPathGrid, LNavGrid)


--@api-stub: lurek.pathfind.newPathGrid
do
    ---@type LPathGrid
    local grid = lurek.pathfind.newPathGrid(20, 15, 32)
    print("width = " .. grid:getWidth() .. " height = " .. grid:getHeight())
end

--@api-stub: LPathGrid:setWalkable
do
    ---@type LPathGrid
    local grid = lurek.pathfind.newPathGrid(20, 15, 32)
    grid:setWalkable(5, 5, false)
    print("(5,5) walkable = " .. tostring(grid:isWalkable(5, 5)))
end

--@api-stub: LPathGrid:isWalkable
do
    ---@type LPathGrid
    local grid = lurek.pathfind.newPathGrid(20, 15, 32)
    grid:setWalkable(5, 5, false)
    print("(5,5) walkable = " .. tostring(grid:isWalkable(5, 5)))
end

--@api-stub: LPathGrid:setCost
do
    ---@type LPathGrid
    local grid = lurek.pathfind.newPathGrid(10, 10, 16)
    grid:setCost(3, 3, 5)
    print("cost at (3,3) = " .. grid:getCost(3, 3))
end

--@api-stub: LPathGrid:getCost
do
    ---@type LPathGrid
    local grid = lurek.pathfind.newPathGrid(10, 10, 16)
    grid:setCost(3, 3, 5)
    print("cost at (3,3) = " .. grid:getCost(3, 3))
end

--@api-stub: LPathGrid:findPath
do
    local grid = lurek.pathfind.newPathGrid(10, 10, 32)
    for y = 1, 10 do grid:setWalkable(5, y, false) end
    grid:setWalkable(5, 8, true)
    local path = grid:findPath(1, 1, 10, 10)
    if path then print("path length = " .. #path) for i, pt in ipairs(path) do print("  step " .. i .. ": " .. pt.x .. "," .. pt.y) end else print("no path found") end
end

--@api-stub: LPathGrid:findPathSmoothed
do
    local grid = lurek.pathfind.newPathGrid(20, 20, 16) ; grid:setWalkable(10, 5, false)
    grid:setWalkable(10, 6, false)
    grid:setWalkable(10, 7, false)
    local path = grid:findPathSmoothed(1, 5, 20, 5)
    if path then print("smoothed path points = " .. #path) print("first = " .. path[1].x .. "," .. path[1].y) print("last = " .. path[#path].x .. "," .. path[#path].y) end
end

--@api-stub: LPathGrid:type
do
    ---@type LPathGrid
    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    print("type = " .. grid:type())
end

--@api-stub: LPathGrid:typeOf
do
    ---@type LPathGrid
    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    print("is LPathGrid = " .. tostring(grid:typeOf("LPathGrid")))
end

--@api-stub: lurek.pathfind.newNavGrid
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(50, 50)
    local w, h = nav:getDimensions()
    print("dimensions = " .. w .. "x" .. h)
    print("width = " .. nav:getWidth() .. " height = " .. nav:getHeight())
end

--@api-stub: LNavGrid:setBlocked
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(30, 30)
    nav:setBlocked(10, 10, true)
    print("(10,10) blocked = " .. tostring(nav:isBlocked(10, 10)))
end

--@api-stub: LNavGrid:isBlocked
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(30, 30)
    nav:setBlocked(10, 10, true)
    print("(10,10) blocked = " .. tostring(nav:isBlocked(10, 10)))
end

--@api-stub: LNavGrid:setCost
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(30, 30)
    nav:setCost(5, 5, 200)
    print("cost at (5,5) = " .. nav:getCost(5, 5))
end

--@api-stub: LNavGrid:getCost
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(30, 30)
    nav:setCost(5, 5, 200)
    print("cost at (5,5) = " .. nav:getCost(5, 5))
end

--@api-stub: LNavGrid:isWalkable
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:fill(1)
    print("(1,1) walkable = " .. tostring(nav:isWalkable(1, 1)))
end

--@api-stub: LNavGrid:fill
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:fill(1)
    print("fill applied")
end

--@api-stub: LNavGrid:fillRect
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:fillRect(5, 5, 5, 5, 255)
    print("fillRect applied")
end

--@api-stub: LNavGrid:setDiagonalMode
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(10, 10)
    nav:setDiagonalMode("always")
    print("diag mode = " .. nav:getDiagonalMode())
end

--@api-stub: LNavGrid:getDiagonalMode
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(10, 10)
    nav:setDiagonalMode("always")
    print("diag mode = " .. nav:getDiagonalMode())
end

--@api-stub: LNavGrid:setChunkSize
do
    local nav = lurek.pathfind.newNavGrid(100, 100)
    nav:setChunkSize(16)
    print("chunk size = " .. nav:getChunkSize())
    nav:rebuildAbstract()
    print("abstract graph rebuilt")
end

--@api-stub: LNavGrid:getChunkSize
do
    local nav = lurek.pathfind.newNavGrid(100, 100)
    nav:setChunkSize(16)
    print("chunk size = " .. nav:getChunkSize())
    nav:rebuildAbstract()
    print("abstract graph rebuilt")
end

--@api-stub: LNavGrid:rebuildAbstract
do
    local nav = lurek.pathfind.newNavGrid(100, 100)
    nav:setChunkSize(16)
    print("chunk size = " .. nav:getChunkSize())
    nav:rebuildAbstract()
    print("abstract graph rebuilt")
end

--@api-stub: LNavGrid:setDirty
do
    local nav = lurek.pathfind.newNavGrid(50, 50) ; nav:setChunkSize(10)
    nav:rebuildAbstract() ; nav:setBlocked(25, 25, true)
    nav:setDirty(20, 20, 10, 10) ; nav:rebuildAbstract()
    nav:clearDirty()
    print("dirty region handled")
end

--@api-stub: LNavGrid:clearDirty
do
    local nav = lurek.pathfind.newNavGrid(50, 50) ; nav:setChunkSize(10)
    nav:rebuildAbstract() ; nav:setBlocked(25, 25, true)
    nav:setDirty(20, 20, 10, 10) ; nav:rebuildAbstract()
    nav:clearDirty()
    print("dirty region handled")
end

--@api-stub: LNavGrid:saveToString
do
    local nav = lurek.pathfind.newNavGrid(10, 10) ; nav:setBlocked(5, 5, true)
    nav:setCost(3, 3, 100) ; local data = nav:saveToString()
    print("serialized bytes = " .. #data) ; local nav2 = lurek.pathfind.newNavGrid(10, 10)
    nav2:loadFromString(data) ; print("loaded (5,5) blocked = " .. tostring(nav2:isBlocked(5, 5)))
    print("loaded (3,3) cost = " .. nav2:getCost(3, 3))
end

--@api-stub: LNavGrid:loadFromString
do
    local nav = lurek.pathfind.newNavGrid(10, 10) ; nav:setBlocked(5, 5, true)
    nav:setCost(3, 3, 100) ; local data = nav:saveToString()
    print("serialized bytes = " .. #data) ; local nav2 = lurek.pathfind.newNavGrid(10, 10)
    nav2:loadFromString(data) ; print("loaded (5,5) blocked = " .. tostring(nav2:isBlocked(5, 5)))
    print("loaded (3,3) cost = " .. nav2:getCost(3, 3))
end

--@api-stub: LNavGrid:type
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(5, 5)
    print("type = " .. nav:type())
    print("is LNavGrid = " .. tostring(nav:typeOf("LNavGrid")))
end

--@api-stub: LNavGrid:typeOf
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(5, 5)
    print("type = " .. nav:type())
    print("is LNavGrid = " .. tostring(nav:typeOf("LNavGrid")))
end

--- Pathfinding Module Part 2: navmesh, hex grid, JPS grid


--@api-stub: lurek.pathfind.newNavMesh
do
    local mesh = lurek.pathfind.newNavMesh() ; local id1 = mesh:addPolygon({{x = 0, y = 0}, {x = 100, y = 0}, {x = 50, y = 80}})
    local id2 = mesh:addPolygon({{x = 50, y = 80}, {x = 100, y = 0}, {x = 150, y = 80}})
    local id3 = mesh:addPolygon({{x = 100, y = 0}, {x = 200, y = 0}, {x = 150, y = 80}})
    print("polygons = " .. mesh:getPolygonCount())
    print("ids = " .. id1 .. ", " .. id2 .. ", " .. id3)
end

--@api-stub: LNavMesh:addPolygon
do
    local mesh = lurek.pathfind.newNavMesh() ; local id1 = mesh:addPolygon({{x = 0, y = 0}, {x = 100, y = 0}, {x = 50, y = 80}})
    local id2 = mesh:addPolygon({{x = 50, y = 80}, {x = 100, y = 0}, {x = 150, y = 80}})
    local id3 = mesh:addPolygon({{x = 100, y = 0}, {x = 200, y = 0}, {x = 150, y = 80}})
    print("polygons = " .. mesh:getPolygonCount())
    print("ids = " .. id1 .. ", " .. id2 .. ", " .. id3)
end

--@api-stub: LNavMesh:connectPolygons
do
    local mesh = lurek.pathfind.newNavMesh() ; local a = mesh:addPolygon({{x = 0, y = 0}, {x = 50, y = 0}, {x = 25, y = 40}})
    local b = mesh:addPolygon({{x = 50, y = 0}, {x = 100, y = 0}, {x = 75, y = 40}}) ; local c = mesh:addPolygon({{x = 25, y = 40}, {x = 75, y = 40}, {x = 50, y = 80}})
    local ok1 = mesh:connectPolygons(a, b, true) ; local ok2 = mesh:connectPolygons(b, c, false)
    print("a-b connected = " .. tostring(ok1))
    print("b-c one-way = " .. tostring(ok2))
end

--@api-stub: LNavMesh:findPath
do
    local mesh = lurek.pathfind.newNavMesh() ; local p1 = mesh:addPolygon({{x = 0, y = 0}, {x = 100, y = 0}, {x = 100, y = 100}, {x = 0, y = 100}})
    local p2 = mesh:addPolygon({{x = 100, y = 0}, {x = 200, y = 0}, {x = 200, y = 100}, {x = 100, y = 100}}) ; local p3 = mesh:addPolygon({{x = 200, y = 0}, {x = 300, y = 0}, {x = 300, y = 100}, {x = 200, y = 100}})
    mesh:connectPolygons(p1, p2, true) ; mesh:connectPolygons(p2, p3, true)
    local path = mesh:findPath(10, 50, 290, 50)
    if path then print("navmesh path waypoints = " .. #path) for i, pt in ipairs(path) do print("  " .. i .. ": " .. pt.x .. "," .. pt.y) end else print("no navmesh path") end
end

--@api-stub: LNavMesh:type
do
    ---@type LNavMesh
    local mesh = lurek.pathfind.newNavMesh()
    print("type = " .. mesh:type())
    print("is LNavMesh = " .. tostring(mesh:typeOf("LNavMesh")))
end

--@api-stub: LNavMesh:typeOf
do
    ---@type LNavMesh
    local mesh = lurek.pathfind.newNavMesh()
    print("type = " .. mesh:type())
    print("is LNavMesh = " .. tostring(mesh:typeOf("LNavMesh")))
end

--@api-stub: lurek.pathfind.newHexGrid
do
    local hex = lurek.pathfind.newHexGrid(12, 10, "flat")
    hex:setBlocked(5, 5, true)
    hex:setBlocked(6, 5, true)
    print("(5,5) blocked = " .. tostring(hex:isBlocked(5, 5)))
    print("(1,1) blocked = " .. tostring(hex:isBlocked(1, 1)))
end

--@api-stub: LHexGrid:setBlocked
do
    local hex = lurek.pathfind.newHexGrid(12, 10, "flat")
    hex:setBlocked(5, 5, true)
    hex:setBlocked(6, 5, true)
    print("(5,5) blocked = " .. tostring(hex:isBlocked(5, 5)))
    print("(1,1) blocked = " .. tostring(hex:isBlocked(1, 1)))
end

--@api-stub: LHexGrid:isBlocked
do
    local hex = lurek.pathfind.newHexGrid(12, 10, "flat")
    hex:setBlocked(5, 5, true)
    hex:setBlocked(6, 5, true)
    print("(5,5) blocked = " .. tostring(hex:isBlocked(5, 5)))
    print("(1,1) blocked = " .. tostring(hex:isBlocked(1, 1)))
end

--@api-stub: LHexGrid:setCost
do
    ---@type LHexGrid
    local hex = lurek.pathfind.newHexGrid(8, 8)
    hex:setCost(3, 3, 5)
    hex:setCost(4, 4, 10)
    print("costs set for hex terrain")
end

--@api-stub: LHexGrid:findPath
do
    local hex = lurek.pathfind.newHexGrid(10, 10) ; hex:setBlocked(5, 3, true)
    hex:setBlocked(5, 4, true)
    hex:setBlocked(5, 5, true)
    local path = hex:findPath(1, 5, 10, 5)
    if path then print("hex path steps = " .. #path) for i, cell in ipairs(path) do print("  " .. i .. ": col=" .. cell.col .. " row=" .. cell.row) end else print("no hex path") end
end

--@api-stub: LHexGrid:distance
do
    local hex = lurek.pathfind.newHexGrid(10, 10)
    local d = hex:distance(1, 1, 5, 5)
    print("hex distance (1,1)â†’(5,5) = " .. d)
    local d2 = hex:distance(1, 1, 1, 1)
    print("hex distance (1,1)â†’(1,1) = " .. d2)
end

--@api-stub: LHexGrid:lineOfSight
do
    ---@type LHexGrid
    local hex = lurek.pathfind.newHexGrid(10, 10)
    print("clear LoS = " .. tostring(hex:lineOfSight(1, 1, 10, 10)))
    hex:setBlocked(5, 5, true)
    print("blocked LoS = " .. tostring(hex:lineOfSight(1, 1, 10, 10)))
end

--@api-stub: LHexGrid:fieldOfView
do
    local hex = lurek.pathfind.newHexGrid(15, 15)
    hex:setBlocked(8, 8, true)
    local visible = hex:fieldOfView(7, 7, 3)
    print("visible cells = " .. #visible)
    if #visible > 0 then print("first = col=" .. visible[1].col .. " row=" .. visible[1].row) end
end

--@api-stub: LHexGrid:rangeOfMovement
do
    local hex = lurek.pathfind.newHexGrid(12, 12)
    hex:setCost(6, 6, 3)
    local reachable = hex:rangeOfMovement(6, 6, 4)
    print("reachable cells = " .. #reachable)
    for i = 1, math.min(3, #reachable) do print("  " .. reachable[i].col .. "," .. reachable[i].row) end
end

--@api-stub: LHexGrid:type
do
    ---@type LHexGrid
    local hex = lurek.pathfind.newHexGrid(5, 5, "pointy")
    print("type = " .. hex:type())
    print("is LHexGrid = " .. tostring(hex:typeOf("LHexGrid")))
end

--@api-stub: LHexGrid:typeOf
do
    ---@type LHexGrid
    local hex = lurek.pathfind.newHexGrid(5, 5, "pointy")
    print("type = " .. hex:type())
    print("is LHexGrid = " .. tostring(hex:typeOf("LHexGrid")))
end

--@api-stub: lurek.pathfind.newJpsGrid
do
    local jps = lurek.pathfind.newJpsGrid(30, 30) ; jps:setBlocked(15, 10, true)
    jps:setBlocked(15, 11, true)
    jps:setBlocked(15, 12, true)
    print("(15,10) blocked = " .. tostring(jps:isBlocked(15, 10)))
    print("(1,1) blocked = " .. tostring(jps:isBlocked(1, 1)))
end

--@api-stub: LJpsGrid:setBlocked
do
    local jps = lurek.pathfind.newJpsGrid(30, 30) ; jps:setBlocked(15, 10, true)
    jps:setBlocked(15, 11, true)
    jps:setBlocked(15, 12, true)
    print("(15,10) blocked = " .. tostring(jps:isBlocked(15, 10)))
    print("(1,1) blocked = " .. tostring(jps:isBlocked(1, 1)))
end

--@api-stub: LJpsGrid:isBlocked
do
    local jps = lurek.pathfind.newJpsGrid(30, 30) ; jps:setBlocked(15, 10, true)
    jps:setBlocked(15, 11, true)
    jps:setBlocked(15, 12, true)
    print("(15,10) blocked = " .. tostring(jps:isBlocked(15, 10)))
    print("(1,1) blocked = " .. tostring(jps:isBlocked(1, 1)))
end

--@api-stub: LJpsGrid:findPath
do
    local jps = lurek.pathfind.newJpsGrid(50, 50)
    for y = 10, 40 do jps:setBlocked(25, y, true) end
    jps:setBlocked(25, 30, false)
    local path = jps:findPath(1, 25, 50, 25)
    if path then print("JPS path points = " .. #path) print("first = " .. path[1].x .. "," .. path[1].y) print("last = " .. path[#path].x .. "," .. path[#path].y) else print("no JPS path") end
end

--@api-stub: LJpsGrid:type
do
    ---@type LJpsGrid
    local jps = lurek.pathfind.newJpsGrid(5, 5)
    print("type = " .. jps:type())
    print("is LJpsGrid = " .. tostring(jps:typeOf("LJpsGrid")))
end

--@api-stub: LJpsGrid:typeOf
do
    ---@type LJpsGrid
    local jps = lurek.pathfind.newJpsGrid(5, 5)
    print("type = " .. jps:type())
    print("is LJpsGrid = " .. tostring(jps:typeOf("LJpsGrid")))
end

--- Pathfinding Module Part 3: flow fields, AI flow fields, unit pathfinder


--@api-stub: lurek.pathfind.newFlowField
do
    local nav = lurek.pathfind.newNavGrid(20, 20) ; nav:fill(1)
    nav:setBlocked(10, 5, true) ; nav:setBlocked(10, 6, true)
    nav:setBlocked(10, 7, true) ; local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(20, 10)
    print("calculated = " .. tostring(ff:isCalculated()))
end

--@api-stub: LFlowField:calculate
do
    local nav = lurek.pathfind.newNavGrid(20, 20) ; nav:fill(1)
    nav:setBlocked(10, 5, true) ; nav:setBlocked(10, 6, true)
    nav:setBlocked(10, 7, true) ; local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(20, 10)
    print("calculated = " .. tostring(ff:isCalculated()))
end

--@api-stub: LFlowField:getDirection
do
    local nav = lurek.pathfind.newNavGrid(10, 10) ; nav:fill(1)
    local ff = lurek.pathfind.newFlowField(nav) ; ff:calculate(10, 10)
    local dx, dy = ff:getDirection(1, 1) ; print("direction at (1,1) = " .. dx .. "," .. dy)
    local angle = ff:getDirectionAngle(1, 1) ; print("angle at (1,1) = " .. angle)
    local cost = ff:getCostToTarget(1, 1) ; print("cost to target from (1,1) = " .. cost)
end

--@api-stub: LFlowField:getDirectionAngle
do
    local nav = lurek.pathfind.newNavGrid(10, 10) ; nav:fill(1)
    local ff = lurek.pathfind.newFlowField(nav) ; ff:calculate(10, 10)
    local dx, dy = ff:getDirection(1, 1) ; print("direction at (1,1) = " .. dx .. "," .. dy)
    local angle = ff:getDirectionAngle(1, 1) ; print("angle at (1,1) = " .. angle)
    local cost = ff:getCostToTarget(1, 1) ; print("cost to target from (1,1) = " .. cost)
end

--@api-stub: LFlowField:getCostToTarget
do
    local nav = lurek.pathfind.newNavGrid(10, 10) ; nav:fill(1)
    local ff = lurek.pathfind.newFlowField(nav) ; ff:calculate(10, 10)
    local dx, dy = ff:getDirection(1, 1) ; print("direction at (1,1) = " .. dx .. "," .. dy)
    local angle = ff:getDirectionAngle(1, 1) ; print("angle at (1,1) = " .. angle)
    local cost = ff:getCostToTarget(1, 1) ; print("cost to target from (1,1) = " .. cost)
end

--@api-stub: LFlowField:calculateMulti
do
    local nav = lurek.pathfind.newNavGrid(15, 15) ; nav:fill(1)
    local ff = lurek.pathfind.newFlowField(nav) ; ff:calculateMulti({{x = 5, y = 5}, {x = 10, y = 10}})
    local targets = ff:getTargets()
    print("targets = " .. #targets)
    for i, t in ipairs(targets) do print("  target " .. i .. ": " .. t.x .. "," .. t.y) end
end

--@api-stub: LFlowField:getTargets
do
    local nav = lurek.pathfind.newNavGrid(15, 15) ; nav:fill(1)
    local ff = lurek.pathfind.newFlowField(nav) ; ff:calculateMulti({{x = 5, y = 5}, {x = 10, y = 10}})
    local targets = ff:getTargets()
    print("targets = " .. #targets)
    for i, t in ipairs(targets) do print("  target " .. i .. ": " .. t.x .. "," .. t.y) end
end

--@api-stub: LFlowField:steer
do
    local nav = lurek.pathfind.newNavGrid(10, 10) ; nav:fill(1)
    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)
    local vx, vy = ff:steer(50, 50, 100, 32, 32)
    print("steer velocity = " .. vx .. "," .. vy)
end

--@api-stub: LFlowField:type
do
    local nav = lurek.pathfind.newNavGrid(5, 5)
    local ff = lurek.pathfind.newFlowField(nav)
    print("type = " .. ff:type())
    print("is LFlowField = " .. tostring(ff:typeOf("LFlowField")))
end

--@api-stub: LFlowField:typeOf
do
    local nav = lurek.pathfind.newNavGrid(5, 5)
    local ff = lurek.pathfind.newFlowField(nav)
    print("type = " .. ff:type())
    print("is LFlowField = " .. tostring(ff:typeOf("LFlowField")))
end

--@api-stub: lurek.pathfind.newPathFlowField
do
    local grid = lurek.pathfind.newPathGrid(15, 15, 32) ; local aiff = lurek.pathfind.newPathFlowField(grid)
    print("width = " .. aiff:getWidth() .. " height = " .. aiff:getHeight()) ; print("has goal = " .. tostring(aiff:hasGoal()))
    aiff:setGoal(10, 10) ; print("has goal = " .. tostring(aiff:hasGoal()))
    local gx, gy = aiff:getGoal()
    print("goal = " .. gx .. "," .. gy)
end

--@api-stub: LAIFlowField:setGoal
do
    local grid = lurek.pathfind.newPathGrid(15, 15, 32) ; local aiff = lurek.pathfind.newPathFlowField(grid)
    print("width = " .. aiff:getWidth() .. " height = " .. aiff:getHeight()) ; print("has goal = " .. tostring(aiff:hasGoal()))
    aiff:setGoal(10, 10) ; print("has goal = " .. tostring(aiff:hasGoal()))
    local gx, gy = aiff:getGoal()
    print("goal = " .. gx .. "," .. gy)
end

--@api-stub: LAIFlowField:getGoal
do
    local grid = lurek.pathfind.newPathGrid(15, 15, 32) ; local aiff = lurek.pathfind.newPathFlowField(grid)
    print("width = " .. aiff:getWidth() .. " height = " .. aiff:getHeight()) ; print("has goal = " .. tostring(aiff:hasGoal()))
    aiff:setGoal(10, 10) ; print("has goal = " .. tostring(aiff:hasGoal()))
    local gx, gy = aiff:getGoal()
    print("goal = " .. gx .. "," .. gy)
end

--@api-stub: LAIFlowField:getDirection
do
    local grid = lurek.pathfind.newPathGrid(10, 10, 16) ; local aiff = lurek.pathfind.newPathFlowField(grid)
    aiff:setGoal(10, 10) ; local dx, dy = aiff:getDirection(1, 1)
    print("direction = " .. dx .. "," .. dy)
    local dist = aiff:getDistance(1, 1)
    print("distance to goal = " .. dist)
end

--@api-stub: LAIFlowField:getDistance
do
    local grid = lurek.pathfind.newPathGrid(10, 10, 16) ; local aiff = lurek.pathfind.newPathFlowField(grid)
    aiff:setGoal(10, 10) ; local dx, dy = aiff:getDirection(1, 1)
    print("direction = " .. dx .. "," .. dy)
    local dist = aiff:getDistance(1, 1)
    print("distance to goal = " .. dist)
end

--@api-stub: LAIFlowField:type
do
    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)
    print("type = " .. aiff:type())
    print("is LAIFlowField = " .. tostring(aiff:typeOf("LAIFlowField")))
end

--@api-stub: LAIFlowField:typeOf
do
    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)
    print("type = " .. aiff:type())
    print("is LAIFlowField = " .. tostring(aiff:typeOf("LAIFlowField")))
end

--@api-stub: lurek.pathfind.newPathfinder
do
    local nav = lurek.pathfind.newNavGrid(30, 30) ; nav:fill(1)
    nav:setBlocked(15, 10, true) ; nav:setBlocked(15, 11, true)
    nav:setBlocked(15, 12, true) ; nav:setBlocked(15, 13, true)
    local pf = lurek.pathfind.newPathfinder(nav) ; local path = pf:findPath(1, 12, 30, 12)
    if path then print("path steps = " .. #path) print("first = " .. path[1].x .. "," .. path[1].y) print("last = " .. path[#path].x .. "," .. path[#path].y) end
end

--@api-stub: LUnitPathfinder:findPath
do
    local nav = lurek.pathfind.newNavGrid(30, 30) ; nav:fill(1)
    nav:setBlocked(15, 10, true) ; nav:setBlocked(15, 11, true)
    nav:setBlocked(15, 12, true) ; nav:setBlocked(15, 13, true)
    local pf = lurek.pathfind.newPathfinder(nav) ; local path = pf:findPath(1, 12, 30, 12)
    if path then print("path steps = " .. #path) print("first = " .. path[1].x .. "," .. path[1].y) print("last = " .. path[#path].x .. "," .. path[#path].y) end
end

--@api-stub: LUnitPathfinder:findPathSmooth
do
    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:fill(1)
    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPathSmooth(1, 1, 20, 20)
    if path then print("smooth path points = " .. #path) end
end

--@api-stub: LUnitPathfinder:findPathBidirectional
do
    local nav = lurek.pathfind.newNavGrid(40, 40)
    nav:fill(1)
    local pf = lurek.pathfind.newPathfinder(nav)
    local path, complete = pf:findPathBidirectional(1, 1, 40, 40, 1, 500)
    if path then print("bidir path = " .. #path .. " complete = " .. tostring(complete)) end
end

--@api-stub: LUnitPathfinder:findPartialPath
do
    local nav = lurek.pathfind.newNavGrid(100, 100)
    nav:fill(1)
    local pf = lurek.pathfind.newPathfinder(nav)
    local path, reached = pf:findPartialPath(1, 1, 100, 100, 50)
    if path then print("partial path = " .. #path .. " reached goal = " .. tostring(reached)) end
end

--@api-stub: LUnitPathfinder:isReachable
do
    local nav = lurek.pathfind.newNavGrid(20, 20) ; nav:fill(1)
    nav:setBlocked(10, 10, true) ; local pf = lurek.pathfind.newPathfinder(nav)
    print("reachable = " .. tostring(pf:isReachable(1, 1, 20, 20))) ; print("LoS clear = " .. tostring(pf:lineOfSight(1, 1, 20, 20)))
    print("LoS blocked = " .. tostring(pf:lineOfSight(1, 10, 20, 10)))
    print("heuristic = " .. pf:heuristicDistance(1, 1, 20, 20))
end

--@api-stub: LUnitPathfinder:lineOfSight
do
    local nav = lurek.pathfind.newNavGrid(20, 20) ; nav:fill(1)
    nav:setBlocked(10, 10, true) ; local pf = lurek.pathfind.newPathfinder(nav)
    print("reachable = " .. tostring(pf:isReachable(1, 1, 20, 20))) ; print("LoS clear = " .. tostring(pf:lineOfSight(1, 1, 20, 20)))
    print("LoS blocked = " .. tostring(pf:lineOfSight(1, 10, 20, 10)))
    print("heuristic = " .. pf:heuristicDistance(1, 1, 20, 20))
end

--@api-stub: LUnitPathfinder:heuristicDistance
do
    local nav = lurek.pathfind.newNavGrid(20, 20) ; nav:fill(1)
    nav:setBlocked(10, 10, true) ; local pf = lurek.pathfind.newPathfinder(nav)
    print("reachable = " .. tostring(pf:isReachable(1, 1, 20, 20))) ; print("LoS clear = " .. tostring(pf:lineOfSight(1, 1, 20, 20)))
    print("LoS blocked = " .. tostring(pf:lineOfSight(1, 10, 20, 10)))
    print("heuristic = " .. pf:heuristicDistance(1, 1, 20, 20))
end

--@api-stub: LUnitPathfinder:findNearestWalkable
do
    local nav = lurek.pathfind.newNavGrid(20, 20) ; nav:fill(1)
    nav:setBlocked(10, 10, true) ; nav:setBlocked(11, 10, true)
    nav:setBlocked(10, 11, true) ; nav:setBlocked(11, 11, true)
    local pf = lurek.pathfind.newPathfinder(nav) ; local nx, ny = pf:findNearestWalkable(10, 10, 5)
    print("nearest walkable = " .. nx .. "," .. ny)
end

--@api-stub: LUnitPathfinder:getPathCost
do
    local nav = lurek.pathfind.newNavGrid(10, 10)
    nav:fill(1)
    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPath(1, 1, 10, 10)
    if path then print("cost = " .. pf:getPathCost(path)) print("length = " .. pf:getPathLength(path)) end
end

--@api-stub: LUnitPathfinder:getPathLength
do
    local nav = lurek.pathfind.newNavGrid(10, 10)
    nav:fill(1)
    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPath(1, 1, 10, 10)
    if path then print("cost = " .. pf:getPathCost(path)) print("length = " .. pf:getPathLength(path)) end
end

--@api-stub: LUnitPathfinder:setCacheEnabled
do
    local nav = lurek.pathfind.newNavGrid(20, 20) ; nav:fill(1) ; local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true) ; print("cache enabled = " .. tostring(pf:isCacheEnabled()))
    pf:setCacheMaxSize(100) ; pf:findPath(1, 1, 20, 20)
    pf:findPath(5, 5, 15, 15) ; print("cache size = " .. pf:getCacheSize())
    pf:clearCache() ; print("after clear = " .. pf:getCacheSize())
end

--@api-stub: LUnitPathfinder:isCacheEnabled
do
    local nav = lurek.pathfind.newNavGrid(20, 20) ; nav:fill(1) ; local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true) ; print("cache enabled = " .. tostring(pf:isCacheEnabled()))
    pf:setCacheMaxSize(100) ; pf:findPath(1, 1, 20, 20)
    pf:findPath(5, 5, 15, 15) ; print("cache size = " .. pf:getCacheSize())
    pf:clearCache() ; print("after clear = " .. pf:getCacheSize())
end

--@api-stub: LUnitPathfinder:setCacheMaxSize
do
    local nav = lurek.pathfind.newNavGrid(20, 20) ; nav:fill(1) ; local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true) ; print("cache enabled = " .. tostring(pf:isCacheEnabled()))
    pf:setCacheMaxSize(100) ; pf:findPath(1, 1, 20, 20)
    pf:findPath(5, 5, 15, 15) ; print("cache size = " .. pf:getCacheSize())
    pf:clearCache() ; print("after clear = " .. pf:getCacheSize())
end

--@api-stub: LUnitPathfinder:getCacheSize
do
    local nav = lurek.pathfind.newNavGrid(20, 20) ; nav:fill(1) ; local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true) ; print("cache enabled = " .. tostring(pf:isCacheEnabled()))
    pf:setCacheMaxSize(100) ; pf:findPath(1, 1, 20, 20)
    pf:findPath(5, 5, 15, 15) ; print("cache size = " .. pf:getCacheSize())
    pf:clearCache() ; print("after clear = " .. pf:getCacheSize())
end

--@api-stub: LUnitPathfinder:clearCache
do
    local nav = lurek.pathfind.newNavGrid(20, 20) ; nav:fill(1) ; local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true) ; print("cache enabled = " .. tostring(pf:isCacheEnabled()))
    pf:setCacheMaxSize(100) ; pf:findPath(1, 1, 20, 20)
    pf:findPath(5, 5, 15, 15) ; print("cache size = " .. pf:getCacheSize())
    pf:clearCache() ; print("after clear = " .. pf:getCacheSize())
end

--@api-stub: LUnitPathfinder:type
do
    local nav = lurek.pathfind.newNavGrid(5, 5)
    local pf = lurek.pathfind.newPathfinder(nav)
    print("type = " .. pf:type())
    print("is LUnitPathfinder = " .. tostring(pf:typeOf("LUnitPathfinder")))
end

--@api-stub: LUnitPathfinder:typeOf
do
    local nav = lurek.pathfind.newNavGrid(5, 5)
    local pf = lurek.pathfind.newPathfinder(nav)
    print("type = " .. pf:type())
    print("is LUnitPathfinder = " .. tostring(pf:typeOf("LUnitPathfinder")))
end

--@api-stub: lurek.pathfind.rangeMap
do
    local result = lurek.pathfind.rangeMap({ width = 10, height = 10, origin_x = 5, origin_y = 5, budget = 4, diagonal = true }) print("range map width = " .. result.width .. " height = " .. result.height)
    print("cells count = " .. #result.cells)
end

--@api-stub: lurek.pathfind.getThreadCount
do
    local tc = lurek.pathfind.getThreadCount()
    print("thread count = " .. tc)
    lurek.pathfind.setThreadCount(4)
end

--- Pathfind Module Part 3: AI flow field, flow field calculated flag, nav grid dims, nav mesh polygon count, path grid dims, newNavGridFromTileMap, setThreadCount


--@api-stub: LAIFlowField:getHeight
do
    local pg = lurek.pathfind.newPathGrid(32, 32, 1) ; local ff = lurek.pathfind.newPathFlowField(pg)
    print("ff_w=" .. ff:getWidth()) ; print("ff_h=" .. ff:getHeight())
    print("has_goal=" .. tostring(ff:hasGoal()))
    ff:setGoal(16, 16)
    print("has_goal_after=" .. tostring(ff:hasGoal()))
end

--@api-stub: LAIFlowField:getWidth
do
    local pg = lurek.pathfind.newPathGrid(32, 32, 1) ; local ff = lurek.pathfind.newPathFlowField(pg)
    print("ff_w=" .. ff:getWidth()) ; print("ff_h=" .. ff:getHeight())
    print("has_goal=" .. tostring(ff:hasGoal()))
    ff:setGoal(16, 16)
    print("has_goal_after=" .. tostring(ff:hasGoal()))
end

--@api-stub: LAIFlowField:hasGoal
do
    local pg = lurek.pathfind.newPathGrid(32, 32, 1) ; local ff = lurek.pathfind.newPathFlowField(pg)
    print("ff_w=" .. ff:getWidth()) ; print("ff_h=" .. ff:getHeight())
    print("has_goal=" .. tostring(ff:hasGoal()))
    ff:setGoal(16, 16)
    print("has_goal_after=" .. tostring(ff:hasGoal()))
end

--@api-stub: LFlowField:isCalculated
do
    local grid = lurek.pathfind.newNavGrid(16, 16)
    local ff = lurek.pathfind.newFlowField(grid)
    print("is_calc=" .. tostring(ff:isCalculated()))
    ff:calculate(8, 8, 1)
    print("is_calc_after=" .. tostring(ff:isCalculated()))
end

--@api-stub: LNavGrid:getDimensions
do
    local ng = lurek.pathfind.newNavGrid(20, 15)
    local w, h = ng:getDimensions()
    print("dims=" .. w .. "x" .. h)
    print("w=" .. ng:getWidth())
    print("h=" .. ng:getHeight())
end

--@api-stub: LNavGrid:getHeight
do
    local ng = lurek.pathfind.newNavGrid(20, 15)
    local w, h = ng:getDimensions()
    print("dims=" .. w .. "x" .. h)
    print("w=" .. ng:getWidth())
    print("h=" .. ng:getHeight())
end

--@api-stub: LNavGrid:getWidth
do
    local ng = lurek.pathfind.newNavGrid(20, 15)
    local w, h = ng:getDimensions()
    print("dims=" .. w .. "x" .. h)
    print("w=" .. ng:getWidth())
    print("h=" .. ng:getHeight())
end

--@api-stub: LNavMesh:getPolygonCount
do
    local ng = lurek.pathfind.newNavGrid(8, 8)
    local mesh = lurek.pathfind.newNavMesh()
    print("poly_count=" .. mesh:getPolygonCount())
end

--@api-stub: LPathGrid:getCellSize
do
    local pg = lurek.pathfind.newPathGrid(10, 10, 32)
    print("cell=" .. pg:getCellSize())
    print("w=" .. pg:getWidth())
    print("h=" .. pg:getHeight())
end

--@api-stub: LPathGrid:getHeight
do
    local pg = lurek.pathfind.newPathGrid(10, 10, 32)
    print("cell=" .. pg:getCellSize())
    print("w=" .. pg:getWidth())
    print("h=" .. pg:getHeight())
end

--@api-stub: LPathGrid:getWidth
do
    local pg = lurek.pathfind.newPathGrid(10, 10, 32)
    print("cell=" .. pg:getCellSize())
    print("w=" .. pg:getWidth())
    print("h=" .. pg:getHeight())
end

--@api-stub: lurek.pathfind.newNavGridFromTileMap
do
    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local layer = tm:addLayer("ground", 8, 8)
    local ng = lurek.pathfind.newNavGridFromTileMap(tm, layer, { 1, 2 })
    print("ng_from_tm=" .. ng:getWidth() .. "x" .. ng:getHeight())
end

--@api-stub: lurek.pathfind.setThreadCount
do
    lurek.pathfind.setThreadCount(2)
    print("thread count set")
end

print("content/examples/pathfind.lua")
