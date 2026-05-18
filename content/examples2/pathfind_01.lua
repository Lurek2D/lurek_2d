--- Pathfinding Module Part 2: navmesh, hex grid, JPS grid

--@api-stub: lurek.pathfind.newNavMesh / LNavMesh:addPolygon
-- Navigation mesh creation and polygon registration.
do
    ---@type LNavMesh
    local mesh = lurek.pathfind.newNavMesh()
    local id1 = mesh:addPolygon({{x = 0, y = 0}, {x = 100, y = 0}, {x = 50, y = 80}})
    local id2 = mesh:addPolygon({{x = 50, y = 80}, {x = 100, y = 0}, {x = 150, y = 80}})
    local id3 = mesh:addPolygon({{x = 100, y = 0}, {x = 200, y = 0}, {x = 150, y = 80}})
    print("polygons = " .. mesh:getPolygonCount())
    print("ids = " .. id1 .. ", " .. id2 .. ", " .. id3)
end

--@api-stub: LNavMesh:connectPolygons
-- Connecting polygons for traversal.
do
    ---@type LNavMesh
    local mesh = lurek.pathfind.newNavMesh()
    local a = mesh:addPolygon({{x = 0, y = 0}, {x = 50, y = 0}, {x = 25, y = 40}})
    local b = mesh:addPolygon({{x = 50, y = 0}, {x = 100, y = 0}, {x = 75, y = 40}})
    local c = mesh:addPolygon({{x = 25, y = 40}, {x = 75, y = 40}, {x = 50, y = 80}})
    local ok1 = mesh:connectPolygons(a, b, true)
    local ok2 = mesh:connectPolygons(b, c, false)
    print("a-b connected = " .. tostring(ok1))
    print("b-c one-way = " .. tostring(ok2))
end

--@api-stub: LNavMesh:findPath
-- Pathfinding through navmesh polygons.
do
    ---@type LNavMesh
    local mesh = lurek.pathfind.newNavMesh()
    local p1 = mesh:addPolygon({{x = 0, y = 0}, {x = 100, y = 0}, {x = 100, y = 100}, {x = 0, y = 100}})
    local p2 = mesh:addPolygon({{x = 100, y = 0}, {x = 200, y = 0}, {x = 200, y = 100}, {x = 100, y = 100}})
    local p3 = mesh:addPolygon({{x = 200, y = 0}, {x = 300, y = 0}, {x = 300, y = 100}, {x = 200, y = 100}})
    mesh:connectPolygons(p1, p2, true)
    mesh:connectPolygons(p2, p3, true)
    local path = mesh:findPath(10, 50, 290, 50)
    if path then
        print("navmesh path waypoints = " .. #path)
        for i, pt in ipairs(path) do
            print("  " .. i .. ": " .. pt.x .. "," .. pt.y)
        end
    else
        print("no navmesh path")
    end
end

--@api-stub: LNavMesh:type / typeOf
-- Type checking.
do
    ---@type LNavMesh
    local mesh = lurek.pathfind.newNavMesh()
    print("type = " .. mesh:type())
    print("is LNavMesh = " .. tostring(mesh:typeOf("LNavMesh")))
end

--@api-stub: lurek.pathfind.newHexGrid / LHexGrid:setBlocked / isBlocked
-- Hex grid creation and blocking.
do
    ---@type LHexGrid
    local hex = lurek.pathfind.newHexGrid(12, 10, "flat")
    hex:setBlocked(5, 5, true)
    hex:setBlocked(6, 5, true)
    print("(5,5) blocked = " .. tostring(hex:isBlocked(5, 5)))
    print("(1,1) blocked = " .. tostring(hex:isBlocked(1, 1)))
end

--@api-stub: LHexGrid:setCost
-- Movement cost on hex cells.
do
    ---@type LHexGrid
    local hex = lurek.pathfind.newHexGrid(8, 8)
    hex:setCost(3, 3, 5)
    hex:setCost(4, 4, 10)
    print("costs set for hex terrain")
end

--@api-stub: LHexGrid:findPath
-- Hex pathfinding between cells.
do
    ---@type LHexGrid
    local hex = lurek.pathfind.newHexGrid(10, 10)
    hex:setBlocked(5, 3, true)
    hex:setBlocked(5, 4, true)
    hex:setBlocked(5, 5, true)
    local path = hex:findPath(1, 5, 10, 5)
    if path then
        print("hex path steps = " .. #path)
        for i, cell in ipairs(path) do
            print("  " .. i .. ": col=" .. cell.col .. " row=" .. cell.row)
        end
    else
        print("no hex path")
    end
end

--@api-stub: LHexGrid:distance
-- Hex distance calculation.
do
    ---@type LHexGrid
    local hex = lurek.pathfind.newHexGrid(10, 10)
    local d = hex:distance(1, 1, 5, 5)
    print("hex distance (1,1)→(5,5) = " .. d)
    local d2 = hex:distance(1, 1, 1, 1)
    print("hex distance (1,1)→(1,1) = " .. d2)
end

--@api-stub: LHexGrid:lineOfSight
-- Line of sight between hex cells.
do
    ---@type LHexGrid
    local hex = lurek.pathfind.newHexGrid(10, 10)
    print("clear LoS = " .. tostring(hex:lineOfSight(1, 1, 10, 10)))
    hex:setBlocked(5, 5, true)
    print("blocked LoS = " .. tostring(hex:lineOfSight(1, 1, 10, 10)))
end

--@api-stub: LHexGrid:fieldOfView
-- Field of view from a hex cell.
do
    ---@type LHexGrid
    local hex = lurek.pathfind.newHexGrid(15, 15)
    hex:setBlocked(8, 8, true)
    local visible = hex:fieldOfView(7, 7, 3)
    print("visible cells = " .. #visible)
    if #visible > 0 then
        print("first = col=" .. visible[1].col .. " row=" .. visible[1].row)
    end
end

--@api-stub: LHexGrid:rangeOfMovement
-- Movement range from a hex cell with a budget.
do
    ---@type LHexGrid
    local hex = lurek.pathfind.newHexGrid(12, 12)
    hex:setCost(6, 6, 3)
    local reachable = hex:rangeOfMovement(6, 6, 4)
    print("reachable cells = " .. #reachable)
    for i = 1, math.min(3, #reachable) do
        print("  " .. reachable[i].col .. "," .. reachable[i].row)
    end
end

--@api-stub: LHexGrid:type / typeOf
-- Type checking.
do
    ---@type LHexGrid
    local hex = lurek.pathfind.newHexGrid(5, 5, "pointy")
    print("type = " .. hex:type())
    print("is LHexGrid = " .. tostring(hex:typeOf("LHexGrid")))
end

--@api-stub: lurek.pathfind.newJpsGrid / LJpsGrid:setBlocked / isBlocked
-- Jump Point Search grid.
do
    ---@type LJpsGrid
    local jps = lurek.pathfind.newJpsGrid(30, 30)
    jps:setBlocked(15, 10, true)
    jps:setBlocked(15, 11, true)
    jps:setBlocked(15, 12, true)
    print("(15,10) blocked = " .. tostring(jps:isBlocked(15, 10)))
    print("(1,1) blocked = " .. tostring(jps:isBlocked(1, 1)))
end

--@api-stub: LJpsGrid:findPath
-- JPS pathfinding (faster than A* on uniform-cost grids).
do
    ---@type LJpsGrid
    local jps = lurek.pathfind.newJpsGrid(50, 50)
    for y = 10, 40 do
        jps:setBlocked(25, y, true)
    end
    jps:setBlocked(25, 30, false)
    local path = jps:findPath(1, 25, 50, 25)
    if path then
        print("JPS path points = " .. #path)
        print("first = " .. path[1].x .. "," .. path[1].y)
        print("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        print("no JPS path")
    end
end

--@api-stub: LJpsGrid:type / typeOf
-- Type checking.
do
    ---@type LJpsGrid
    local jps = lurek.pathfind.newJpsGrid(5, 5)
    print("type = " .. jps:type())
    print("is LJpsGrid = " .. tostring(jps:typeOf("LJpsGrid")))
end

print("pathfind_01.lua")
