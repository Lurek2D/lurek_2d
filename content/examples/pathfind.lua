-- content/examples/pathfind.lua
-- Auto-generated from content/examples2/pathfind_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/pathfind.lua

--- Pathfinding Module Part 1: grid pathfinding basics (LPathGrid, LNavGrid)


--@api-stub: lurek.pathfind.newPathGrid
-- Basic cell-size path grid creation and walkability. Focus: newPathGrid.
do
    ---@type LPathGrid
    local grid = lurek.pathfind.newPathGrid(20, 15, 32)
    print("width = " .. grid:getWidth() .. " height = " .. grid:getHeight())
    print("cell size = " .. grid:getCellSize())
    grid:setWalkable(5, 5, false)
    print("(5,5) walkable = " .. tostring(grid:isWalkable(5, 5)))
    print("(1,1) walkable = " .. tostring(grid:isWalkable(1, 1)))
end

--@api-stub: LPathGrid:setWalkable
-- Basic cell-size path grid creation and walkability. Focus: setWalkable.
do
    ---@type LPathGrid
    local grid = lurek.pathfind.newPathGrid(20, 15, 32)
    print("width = " .. grid:getWidth() .. " height = " .. grid:getHeight())
    print("cell size = " .. grid:getCellSize())
    grid:setWalkable(5, 5, false)
    print("(5,5) walkable = " .. tostring(grid:isWalkable(5, 5)))
    print("(1,1) walkable = " .. tostring(grid:isWalkable(1, 1)))
end

--@api-stub: LPathGrid:isWalkable
-- Basic cell-size path grid creation and walkability. Focus: isWalkable.
do
    ---@type LPathGrid
    local grid = lurek.pathfind.newPathGrid(20, 15, 32)
    print("width = " .. grid:getWidth() .. " height = " .. grid:getHeight())
    print("cell size = " .. grid:getCellSize())
    grid:setWalkable(5, 5, false)
    print("(5,5) walkable = " .. tostring(grid:isWalkable(5, 5)))
    print("(1,1) walkable = " .. tostring(grid:isWalkable(1, 1)))
end

--@api-stub: LPathGrid:setCost
-- Movement cost per cell. Focus: setCost.
do
    ---@type LPathGrid
    local grid = lurek.pathfind.newPathGrid(10, 10, 16)
    grid:setCost(3, 3, 5)
    grid:setCost(4, 3, 10)
    print("cost at (3,3) = " .. grid:getCost(3, 3))
    print("cost at (4,3) = " .. grid:getCost(4, 3))
    print("default cost = " .. grid:getCost(1, 1))
end

--@api-stub: LPathGrid:getCost
-- Movement cost per cell. Focus: getCost.
do
    ---@type LPathGrid
    local grid = lurek.pathfind.newPathGrid(10, 10, 16)
    grid:setCost(3, 3, 5)
    grid:setCost(4, 3, 10)
    print("cost at (3,3) = " .. grid:getCost(3, 3))
    print("cost at (4,3) = " .. grid:getCost(4, 3))
    print("default cost = " .. grid:getCost(1, 1))
end

--@api-stub: LPathGrid:findPath
-- A* pathfinding on the grid.
do
    ---@type LPathGrid
    local grid = lurek.pathfind.newPathGrid(10, 10, 32)
    for y = 1, 10 do
        grid:setWalkable(5, y, false)
    end
    grid:setWalkable(5, 8, true)
    local path = grid:findPath(1, 1, 10, 10)
    if path then
        print("path length = " .. #path)
        for i, pt in ipairs(path) do
            print("  step " .. i .. ": " .. pt.x .. "," .. pt.y)
        end
    else
        print("no path found")
    end
end

--@api-stub: LPathGrid:findPathSmoothed
-- Smoothed path removes redundant waypoints.
do
    ---@type LPathGrid
    local grid = lurek.pathfind.newPathGrid(20, 20, 16)
    grid:setWalkable(10, 5, false)
    grid:setWalkable(10, 6, false)
    grid:setWalkable(10, 7, false)
    local path = grid:findPathSmoothed(1, 5, 20, 5)
    if path then
        print("smoothed path points = " .. #path)
        print("first = " .. path[1].x .. "," .. path[1].y)
        print("last = " .. path[#path].x .. "," .. path[#path].y)
    end
end

--@api-stub: LPathGrid:type
-- Type checking. Focus: type.
do
    ---@type LPathGrid
    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    print("type = " .. grid:type())
    print("is LPathGrid = " .. tostring(grid:typeOf("LPathGrid")))
    print("is Object = " .. tostring(grid:typeOf("Object")))
end

--@api-stub: LPathGrid:typeOf
-- Type checking. Focus: typeOf.
do
    ---@type LPathGrid
    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    print("type = " .. grid:type())
    print("is LPathGrid = " .. tostring(grid:typeOf("LPathGrid")))
    print("is Object = " .. tostring(grid:typeOf("Object")))
end

--@api-stub: lurek.pathfind.newNavGrid
-- Navigation grid creation with cost-based cells.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(50, 50)
    local w, h = nav:getDimensions()
    print("dimensions = " .. w .. "x" .. h)
    print("width = " .. nav:getWidth() .. " height = " .. nav:getHeight())
end

--@api-stub: LNavGrid:setBlocked
-- Blocking and movement cost. Focus: setBlocked.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(30, 30)
    nav:setBlocked(10, 10, true)
    nav:setBlocked(11, 10, true)
    print("(10,10) blocked = " .. tostring(nav:isBlocked(10, 10)))
    print("(1,1) blocked = " .. tostring(nav:isBlocked(1, 1)))
    nav:setCost(5, 5, 200)
    print("cost at (5,5) = " .. nav:getCost(5, 5))
end

--@api-stub: LNavGrid:isBlocked
-- Blocking and movement cost. Focus: isBlocked.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(30, 30)
    nav:setBlocked(10, 10, true)
    nav:setBlocked(11, 10, true)
    print("(10,10) blocked = " .. tostring(nav:isBlocked(10, 10)))
    print("(1,1) blocked = " .. tostring(nav:isBlocked(1, 1)))
    nav:setCost(5, 5, 200)
    print("cost at (5,5) = " .. nav:getCost(5, 5))
end

--@api-stub: LNavGrid:setCost
-- Blocking and movement cost. Focus: setCost.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(30, 30)
    nav:setBlocked(10, 10, true)
    nav:setBlocked(11, 10, true)
    print("(10,10) blocked = " .. tostring(nav:isBlocked(10, 10)))
    print("(1,1) blocked = " .. tostring(nav:isBlocked(1, 1)))
    nav:setCost(5, 5, 200)
    print("cost at (5,5) = " .. nav:getCost(5, 5))
end

--@api-stub: LNavGrid:getCost
-- Blocking and movement cost. Focus: getCost.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(30, 30)
    nav:setBlocked(10, 10, true)
    nav:setBlocked(11, 10, true)
    print("(10,10) blocked = " .. tostring(nav:isBlocked(10, 10)))
    print("(1,1) blocked = " .. tostring(nav:isBlocked(1, 1)))
    nav:setCost(5, 5, 200)
    print("cost at (5,5) = " .. nav:getCost(5, 5))
end

--@api-stub: LNavGrid:isWalkable
-- Walkability checks and bulk fill operations. Focus: isWalkable.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:fill(1)
    nav:fillRect(5, 5, 5, 5, 255)
    print("(1,1) walkable = " .. tostring(nav:isWalkable(1, 1)))
    print("(7,7) walkable size 1 = " .. tostring(nav:isWalkable(7, 7)))
    print("(7,7) walkable size 3 = " .. tostring(nav:isWalkable(7, 7, 3)))
end

--@api-stub: LNavGrid:fill
-- Walkability checks and bulk fill operations. Focus: fill.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:fill(1)
    nav:fillRect(5, 5, 5, 5, 255)
    print("(1,1) walkable = " .. tostring(nav:isWalkable(1, 1)))
    print("(7,7) walkable size 1 = " .. tostring(nav:isWalkable(7, 7)))
    print("(7,7) walkable size 3 = " .. tostring(nav:isWalkable(7, 7, 3)))
end

--@api-stub: LNavGrid:fillRect
-- Walkability checks and bulk fill operations. Focus: fillRect.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:fill(1)
    nav:fillRect(5, 5, 5, 5, 255)
    print("(1,1) walkable = " .. tostring(nav:isWalkable(1, 1)))
    print("(7,7) walkable size 1 = " .. tostring(nav:isWalkable(7, 7)))
    print("(7,7) walkable size 3 = " .. tostring(nav:isWalkable(7, 7, 3)))
end

--@api-stub: LNavGrid:setDiagonalMode
-- Diagonal movement modes. Focus: setDiagonalMode.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(10, 10)
    nav:setDiagonalMode("always")
    print("diag mode = " .. nav:getDiagonalMode())
    nav:setDiagonalMode("nocornercut")
    print("diag mode = " .. nav:getDiagonalMode())
    nav:setDiagonalMode("none")
    print("diag mode = " .. nav:getDiagonalMode())
end

--@api-stub: LNavGrid:getDiagonalMode
-- Diagonal movement modes. Focus: getDiagonalMode.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(10, 10)
    nav:setDiagonalMode("always")
    print("diag mode = " .. nav:getDiagonalMode())
    nav:setDiagonalMode("nocornercut")
    print("diag mode = " .. nav:getDiagonalMode())
    nav:setDiagonalMode("none")
    print("diag mode = " .. nav:getDiagonalMode())
end

--@api-stub: LNavGrid:setChunkSize
-- Hierarchical abstract graph for large grids. Focus: setChunkSize.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(100, 100)
    nav:setChunkSize(16)
    print("chunk size = " .. nav:getChunkSize())
    nav:rebuildAbstract()
    print("abstract graph rebuilt")
end

--@api-stub: LNavGrid:getChunkSize
-- Hierarchical abstract graph for large grids. Focus: getChunkSize.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(100, 100)
    nav:setChunkSize(16)
    print("chunk size = " .. nav:getChunkSize())
    nav:rebuildAbstract()
    print("abstract graph rebuilt")
end

--@api-stub: LNavGrid:rebuildAbstract
-- Hierarchical abstract graph for large grids. Focus: rebuildAbstract.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(100, 100)
    nav:setChunkSize(16)
    print("chunk size = " .. nav:getChunkSize())
    nav:rebuildAbstract()
    print("abstract graph rebuilt")
end

--@api-stub: LNavGrid:setDirty
-- Incremental dirty regions. Focus: setDirty.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(50, 50)
    nav:setChunkSize(10)
    nav:rebuildAbstract()
    nav:setBlocked(25, 25, true)
    nav:setDirty(20, 20, 10, 10)
    nav:rebuildAbstract()
    nav:clearDirty()
    print("dirty region handled")
end

--@api-stub: LNavGrid:clearDirty
-- Incremental dirty regions. Focus: clearDirty.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(50, 50)
    nav:setChunkSize(10)
    nav:rebuildAbstract()
    nav:setBlocked(25, 25, true)
    nav:setDirty(20, 20, 10, 10)
    nav:rebuildAbstract()
    nav:clearDirty()
    print("dirty region handled")
end

--@api-stub: LNavGrid:saveToString
-- Serialization. Focus: saveToString.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(10, 10)
    nav:setBlocked(5, 5, true)
    nav:setCost(3, 3, 100)
    local data = nav:saveToString()
    print("serialized bytes = " .. #data)
    ---@type LNavGrid
    local nav2 = lurek.pathfind.newNavGrid(10, 10)
    nav2:loadFromString(data)
    print("loaded (5,5) blocked = " .. tostring(nav2:isBlocked(5, 5)))
    print("loaded (3,3) cost = " .. nav2:getCost(3, 3))
end

--@api-stub: LNavGrid:loadFromString
-- Serialization. Focus: loadFromString.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(10, 10)
    nav:setBlocked(5, 5, true)
    nav:setCost(3, 3, 100)
    local data = nav:saveToString()
    print("serialized bytes = " .. #data)
    ---@type LNavGrid
    local nav2 = lurek.pathfind.newNavGrid(10, 10)
    nav2:loadFromString(data)
    print("loaded (5,5) blocked = " .. tostring(nav2:isBlocked(5, 5)))
    print("loaded (3,3) cost = " .. nav2:getCost(3, 3))
end

--@api-stub: LNavGrid:type
-- Type checking. Focus: type.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(5, 5)
    print("type = " .. nav:type())
    print("is LNavGrid = " .. tostring(nav:typeOf("LNavGrid")))
end

--@api-stub: LNavGrid:typeOf
-- Type checking. Focus: typeOf.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(5, 5)
    print("type = " .. nav:type())
    print("is LNavGrid = " .. tostring(nav:typeOf("LNavGrid")))
end

--- Pathfinding Module Part 2: navmesh, hex grid, JPS grid


--@api-stub: lurek.pathfind.newNavMesh
-- Navigation mesh creation and polygon registration. Focus: newNavMesh.
do
    ---@type LNavMesh
    local mesh = lurek.pathfind.newNavMesh()
    local id1 = mesh:addPolygon({{x = 0, y = 0}, {x = 100, y = 0}, {x = 50, y = 80}})
    local id2 = mesh:addPolygon({{x = 50, y = 80}, {x = 100, y = 0}, {x = 150, y = 80}})
    local id3 = mesh:addPolygon({{x = 100, y = 0}, {x = 200, y = 0}, {x = 150, y = 80}})
    print("polygons = " .. mesh:getPolygonCount())
    print("ids = " .. id1 .. ", " .. id2 .. ", " .. id3)
end

--@api-stub: LNavMesh:addPolygon
-- Navigation mesh creation and polygon registration. Focus: addPolygon.
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

--@api-stub: LNavMesh:type
-- Type checking. Focus: type.
do
    ---@type LNavMesh
    local mesh = lurek.pathfind.newNavMesh()
    print("type = " .. mesh:type())
    print("is LNavMesh = " .. tostring(mesh:typeOf("LNavMesh")))
end

--@api-stub: LNavMesh:typeOf
-- Type checking. Focus: typeOf.
do
    ---@type LNavMesh
    local mesh = lurek.pathfind.newNavMesh()
    print("type = " .. mesh:type())
    print("is LNavMesh = " .. tostring(mesh:typeOf("LNavMesh")))
end

--@api-stub: lurek.pathfind.newHexGrid
-- Hex grid creation and blocking. Focus: newHexGrid.
do
    ---@type LHexGrid
    local hex = lurek.pathfind.newHexGrid(12, 10, "flat")
    hex:setBlocked(5, 5, true)
    hex:setBlocked(6, 5, true)
    print("(5,5) blocked = " .. tostring(hex:isBlocked(5, 5)))
    print("(1,1) blocked = " .. tostring(hex:isBlocked(1, 1)))
end

--@api-stub: LHexGrid:setBlocked
-- Hex grid creation and blocking. Focus: setBlocked.
do
    ---@type LHexGrid
    local hex = lurek.pathfind.newHexGrid(12, 10, "flat")
    hex:setBlocked(5, 5, true)
    hex:setBlocked(6, 5, true)
    print("(5,5) blocked = " .. tostring(hex:isBlocked(5, 5)))
    print("(1,1) blocked = " .. tostring(hex:isBlocked(1, 1)))
end

--@api-stub: LHexGrid:isBlocked
-- Hex grid creation and blocking. Focus: isBlocked.
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

--@api-stub: LHexGrid:type
-- Type checking. Focus: type.
do
    ---@type LHexGrid
    local hex = lurek.pathfind.newHexGrid(5, 5, "pointy")
    print("type = " .. hex:type())
    print("is LHexGrid = " .. tostring(hex:typeOf("LHexGrid")))
end

--@api-stub: LHexGrid:typeOf
-- Type checking. Focus: typeOf.
do
    ---@type LHexGrid
    local hex = lurek.pathfind.newHexGrid(5, 5, "pointy")
    print("type = " .. hex:type())
    print("is LHexGrid = " .. tostring(hex:typeOf("LHexGrid")))
end

--@api-stub: lurek.pathfind.newJpsGrid
-- Jump Point Search grid. Focus: newJpsGrid.
do
    ---@type LJpsGrid
    local jps = lurek.pathfind.newJpsGrid(30, 30)
    jps:setBlocked(15, 10, true)
    jps:setBlocked(15, 11, true)
    jps:setBlocked(15, 12, true)
    print("(15,10) blocked = " .. tostring(jps:isBlocked(15, 10)))
    print("(1,1) blocked = " .. tostring(jps:isBlocked(1, 1)))
end

--@api-stub: LJpsGrid:setBlocked
-- Jump Point Search grid. Focus: setBlocked.
do
    ---@type LJpsGrid
    local jps = lurek.pathfind.newJpsGrid(30, 30)
    jps:setBlocked(15, 10, true)
    jps:setBlocked(15, 11, true)
    jps:setBlocked(15, 12, true)
    print("(15,10) blocked = " .. tostring(jps:isBlocked(15, 10)))
    print("(1,1) blocked = " .. tostring(jps:isBlocked(1, 1)))
end

--@api-stub: LJpsGrid:isBlocked
-- Jump Point Search grid. Focus: isBlocked.
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

--@api-stub: LJpsGrid:type
-- Type checking. Focus: type.
do
    ---@type LJpsGrid
    local jps = lurek.pathfind.newJpsGrid(5, 5)
    print("type = " .. jps:type())
    print("is LJpsGrid = " .. tostring(jps:typeOf("LJpsGrid")))
end

--@api-stub: LJpsGrid:typeOf
-- Type checking. Focus: typeOf.
do
    ---@type LJpsGrid
    local jps = lurek.pathfind.newJpsGrid(5, 5)
    print("type = " .. jps:type())
    print("is LJpsGrid = " .. tostring(jps:typeOf("LJpsGrid")))
end

--- Pathfinding Module Part 3: flow fields, AI flow fields, unit pathfinder


--@api-stub: lurek.pathfind.newFlowField
-- Flow field creation and single-target calculation. Focus: newFlowField.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:fill(1)
    nav:setBlocked(10, 5, true)
    nav:setBlocked(10, 6, true)
    nav:setBlocked(10, 7, true)
    ---@type LFlowField
    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(20, 10)
    print("calculated = " .. tostring(ff:isCalculated()))
end

--@api-stub: LFlowField:calculate
-- Flow field creation and single-target calculation. Focus: calculate.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:fill(1)
    nav:setBlocked(10, 5, true)
    nav:setBlocked(10, 6, true)
    nav:setBlocked(10, 7, true)
    ---@type LFlowField
    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(20, 10)
    print("calculated = " .. tostring(ff:isCalculated()))
end

--@api-stub: LFlowField:getDirection
-- Flow field queries. Focus: getDirection.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(10, 10)
    nav:fill(1)
    ---@type LFlowField
    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)
    local dx, dy = ff:getDirection(1, 1)
    print("direction at (1,1) = " .. dx .. "," .. dy)
    local angle = ff:getDirectionAngle(1, 1)
    print("angle at (1,1) = " .. angle)
    local cost = ff:getCostToTarget(1, 1)
    print("cost to target from (1,1) = " .. cost)
end

--@api-stub: LFlowField:getDirectionAngle
-- Flow field queries. Focus: getDirectionAngle.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(10, 10)
    nav:fill(1)
    ---@type LFlowField
    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)
    local dx, dy = ff:getDirection(1, 1)
    print("direction at (1,1) = " .. dx .. "," .. dy)
    local angle = ff:getDirectionAngle(1, 1)
    print("angle at (1,1) = " .. angle)
    local cost = ff:getCostToTarget(1, 1)
    print("cost to target from (1,1) = " .. cost)
end

--@api-stub: LFlowField:getCostToTarget
-- Flow field queries. Focus: getCostToTarget.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(10, 10)
    nav:fill(1)
    ---@type LFlowField
    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)
    local dx, dy = ff:getDirection(1, 1)
    print("direction at (1,1) = " .. dx .. "," .. dy)
    local angle = ff:getDirectionAngle(1, 1)
    print("angle at (1,1) = " .. angle)
    local cost = ff:getCostToTarget(1, 1)
    print("cost to target from (1,1) = " .. cost)
end

--@api-stub: LFlowField:calculateMulti
-- Multi-target flow field. Focus: calculateMulti.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(15, 15)
    nav:fill(1)
    ---@type LFlowField
    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculateMulti({{x = 5, y = 5}, {x = 10, y = 10}})
    local targets = ff:getTargets()
    print("targets = " .. #targets)
    for i, t in ipairs(targets) do
        print("  target " .. i .. ": " .. t.x .. "," .. t.y)
    end
end

--@api-stub: LFlowField:getTargets
-- Multi-target flow field. Focus: getTargets.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(15, 15)
    nav:fill(1)
    ---@type LFlowField
    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculateMulti({{x = 5, y = 5}, {x = 10, y = 10}})
    local targets = ff:getTargets()
    print("targets = " .. #targets)
    for i, t in ipairs(targets) do
        print("  target " .. i .. ": " .. t.x .. "," .. t.y)
    end
end

--@api-stub: LFlowField:steer
-- Steering a unit toward the goal using the flow field.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(10, 10)
    nav:fill(1)
    ---@type LFlowField
    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)
    local vx, vy = ff:steer(50, 50, 100, 32, 32)
    print("steer velocity = " .. vx .. "," .. vy)
end

--@api-stub: LFlowField:type
-- Type checking. Focus: type.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(5, 5)
    ---@type LFlowField
    local ff = lurek.pathfind.newFlowField(nav)
    print("type = " .. ff:type())
    print("is LFlowField = " .. tostring(ff:typeOf("LFlowField")))
end

--@api-stub: LFlowField:typeOf
-- Type checking. Focus: typeOf.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(5, 5)
    ---@type LFlowField
    local ff = lurek.pathfind.newFlowField(nav)
    print("type = " .. ff:type())
    print("is LFlowField = " .. tostring(ff:typeOf("LFlowField")))
end

--@api-stub: lurek.pathfind.newPathFlowField
-- AI flow field from a path grid. Focus: newPathFlowField.
do
    ---@type LPathGrid
    local grid = lurek.pathfind.newPathGrid(15, 15, 32)
    ---@type LAIFlowField
    local aiff = lurek.pathfind.newPathFlowField(grid)
    print("width = " .. aiff:getWidth() .. " height = " .. aiff:getHeight())
    print("has goal = " .. tostring(aiff:hasGoal()))
    aiff:setGoal(10, 10)
    print("has goal = " .. tostring(aiff:hasGoal()))
    local gx, gy = aiff:getGoal()
    print("goal = " .. gx .. "," .. gy)
end

--@api-stub: LAIFlowField:setGoal
-- AI flow field from a path grid. Focus: setGoal.
do
    ---@type LPathGrid
    local grid = lurek.pathfind.newPathGrid(15, 15, 32)
    ---@type LAIFlowField
    local aiff = lurek.pathfind.newPathFlowField(grid)
    print("width = " .. aiff:getWidth() .. " height = " .. aiff:getHeight())
    print("has goal = " .. tostring(aiff:hasGoal()))
    aiff:setGoal(10, 10)
    print("has goal = " .. tostring(aiff:hasGoal()))
    local gx, gy = aiff:getGoal()
    print("goal = " .. gx .. "," .. gy)
end

--@api-stub: LAIFlowField:getGoal
-- AI flow field from a path grid. Focus: getGoal.
do
    ---@type LPathGrid
    local grid = lurek.pathfind.newPathGrid(15, 15, 32)
    ---@type LAIFlowField
    local aiff = lurek.pathfind.newPathFlowField(grid)
    print("width = " .. aiff:getWidth() .. " height = " .. aiff:getHeight())
    print("has goal = " .. tostring(aiff:hasGoal()))
    aiff:setGoal(10, 10)
    print("has goal = " .. tostring(aiff:hasGoal()))
    local gx, gy = aiff:getGoal()
    print("goal = " .. gx .. "," .. gy)
end

--@api-stub: LAIFlowField:getDirection
-- AI flow field direction and distance queries. Focus: getDirection.
do
    ---@type LPathGrid
    local grid = lurek.pathfind.newPathGrid(10, 10, 16)
    ---@type LAIFlowField
    local aiff = lurek.pathfind.newPathFlowField(grid)
    aiff:setGoal(10, 10)
    local dx, dy = aiff:getDirection(1, 1)
    print("direction = " .. dx .. "," .. dy)
    local dist = aiff:getDistance(1, 1)
    print("distance to goal = " .. dist)
end

--@api-stub: LAIFlowField:getDistance
-- AI flow field direction and distance queries. Focus: getDistance.
do
    ---@type LPathGrid
    local grid = lurek.pathfind.newPathGrid(10, 10, 16)
    ---@type LAIFlowField
    local aiff = lurek.pathfind.newPathFlowField(grid)
    aiff:setGoal(10, 10)
    local dx, dy = aiff:getDirection(1, 1)
    print("direction = " .. dx .. "," .. dy)
    local dist = aiff:getDistance(1, 1)
    print("distance to goal = " .. dist)
end

--@api-stub: LAIFlowField:type
-- Type checking. Focus: type.
do
    ---@type LPathGrid
    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    ---@type LAIFlowField
    local aiff = lurek.pathfind.newPathFlowField(grid)
    print("type = " .. aiff:type())
    print("is LAIFlowField = " .. tostring(aiff:typeOf("LAIFlowField")))
end

--@api-stub: LAIFlowField:typeOf
-- Type checking. Focus: typeOf.
do
    ---@type LPathGrid
    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    ---@type LAIFlowField
    local aiff = lurek.pathfind.newPathFlowField(grid)
    print("type = " .. aiff:type())
    print("is LAIFlowField = " .. tostring(aiff:typeOf("LAIFlowField")))
end

--@api-stub: lurek.pathfind.newPathfinder
-- Unit pathfinder creation and basic pathfinding. Focus: newPathfinder.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(30, 30)
    nav:fill(1)
    nav:setBlocked(15, 10, true)
    nav:setBlocked(15, 11, true)
    nav:setBlocked(15, 12, true)
    nav:setBlocked(15, 13, true)
    ---@type LUnitPathfinder
    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPath(1, 12, 30, 12)
    if path then
        print("path steps = " .. #path)
        print("first = " .. path[1].x .. "," .. path[1].y)
        print("last = " .. path[#path].x .. "," .. path[#path].y)
    end
end

--@api-stub: LUnitPathfinder:findPath
-- Unit pathfinder creation and basic pathfinding. Focus: findPath.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(30, 30)
    nav:fill(1)
    nav:setBlocked(15, 10, true)
    nav:setBlocked(15, 11, true)
    nav:setBlocked(15, 12, true)
    nav:setBlocked(15, 13, true)
    ---@type LUnitPathfinder
    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPath(1, 12, 30, 12)
    if path then
        print("path steps = " .. #path)
        print("first = " .. path[1].x .. "," .. path[1].y)
        print("last = " .. path[#path].x .. "," .. path[#path].y)
    end
end

--@api-stub: LUnitPathfinder:findPathSmooth
-- Smoothed path variant.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:fill(1)
    ---@type LUnitPathfinder
    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPathSmooth(1, 1, 20, 20)
    if path then
        print("smooth path points = " .. #path)
    end
end

--@api-stub: LUnitPathfinder:findPathBidirectional
-- Bidirectional A* with completion status.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(40, 40)
    nav:fill(1)
    ---@type LUnitPathfinder
    local pf = lurek.pathfind.newPathfinder(nav)
    local path, complete = pf:findPathBidirectional(1, 1, 40, 40, 1, 500)
    if path then
        print("bidir path = " .. #path .. " complete = " .. tostring(complete))
    end
end

--@api-stub: LUnitPathfinder:findPartialPath
-- Incremental pathfinding with node budget.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(100, 100)
    nav:fill(1)
    ---@type LUnitPathfinder
    local pf = lurek.pathfind.newPathfinder(nav)
    local path, reached = pf:findPartialPath(1, 1, 100, 100, 50)
    if path then
        print("partial path = " .. #path .. " reached goal = " .. tostring(reached))
    end
end

--@api-stub: LUnitPathfinder:isReachable
-- Reachability and visibility checks. Focus: isReachable.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:fill(1)
    nav:setBlocked(10, 10, true)
    ---@type LUnitPathfinder
    local pf = lurek.pathfind.newPathfinder(nav)
    print("reachable = " .. tostring(pf:isReachable(1, 1, 20, 20)))
    print("LoS clear = " .. tostring(pf:lineOfSight(1, 1, 20, 20)))
    print("LoS blocked = " .. tostring(pf:lineOfSight(1, 10, 20, 10)))
    print("heuristic = " .. pf:heuristicDistance(1, 1, 20, 20))
end

--@api-stub: LUnitPathfinder:lineOfSight
-- Reachability and visibility checks. Focus: lineOfSight.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:fill(1)
    nav:setBlocked(10, 10, true)
    ---@type LUnitPathfinder
    local pf = lurek.pathfind.newPathfinder(nav)
    print("reachable = " .. tostring(pf:isReachable(1, 1, 20, 20)))
    print("LoS clear = " .. tostring(pf:lineOfSight(1, 1, 20, 20)))
    print("LoS blocked = " .. tostring(pf:lineOfSight(1, 10, 20, 10)))
    print("heuristic = " .. pf:heuristicDistance(1, 1, 20, 20))
end

--@api-stub: LUnitPathfinder:heuristicDistance
-- Reachability and visibility checks. Focus: heuristicDistance.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:fill(1)
    nav:setBlocked(10, 10, true)
    ---@type LUnitPathfinder
    local pf = lurek.pathfind.newPathfinder(nav)
    print("reachable = " .. tostring(pf:isReachable(1, 1, 20, 20)))
    print("LoS clear = " .. tostring(pf:lineOfSight(1, 1, 20, 20)))
    print("LoS blocked = " .. tostring(pf:lineOfSight(1, 10, 20, 10)))
    print("heuristic = " .. pf:heuristicDistance(1, 1, 20, 20))
end

--@api-stub: LUnitPathfinder:findNearestWalkable
-- Finding nearest walkable cell for stuck units.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:fill(1)
    nav:setBlocked(10, 10, true)
    nav:setBlocked(11, 10, true)
    nav:setBlocked(10, 11, true)
    nav:setBlocked(11, 11, true)
    ---@type LUnitPathfinder
    local pf = lurek.pathfind.newPathfinder(nav)
    local nx, ny = pf:findNearestWalkable(10, 10, 5)
    print("nearest walkable = " .. nx .. "," .. ny)
end

--@api-stub: LUnitPathfinder:getPathCost
-- Path cost and length utilities. Focus: getPathCost.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(10, 10)
    nav:fill(1)
    ---@type LUnitPathfinder
    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPath(1, 1, 10, 10)
    if path then
        print("cost = " .. pf:getPathCost(path))
        print("length = " .. pf:getPathLength(path))
    end
end

--@api-stub: LUnitPathfinder:getPathLength
-- Path cost and length utilities. Focus: getPathLength.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(10, 10)
    nav:fill(1)
    ---@type LUnitPathfinder
    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPath(1, 1, 10, 10)
    if path then
        print("cost = " .. pf:getPathCost(path))
        print("length = " .. pf:getPathLength(path))
    end
end

--@api-stub: LUnitPathfinder:setCacheEnabled
-- Path cache management. Focus: setCacheEnabled.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:fill(1)
    ---@type LUnitPathfinder
    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    print("cache enabled = " .. tostring(pf:isCacheEnabled()))
    pf:setCacheMaxSize(100)
    pf:findPath(1, 1, 20, 20)
    pf:findPath(5, 5, 15, 15)
    print("cache size = " .. pf:getCacheSize())
    pf:clearCache()
    print("after clear = " .. pf:getCacheSize())
end

--@api-stub: LUnitPathfinder:isCacheEnabled
-- Path cache management. Focus: isCacheEnabled.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:fill(1)
    ---@type LUnitPathfinder
    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    print("cache enabled = " .. tostring(pf:isCacheEnabled()))
    pf:setCacheMaxSize(100)
    pf:findPath(1, 1, 20, 20)
    pf:findPath(5, 5, 15, 15)
    print("cache size = " .. pf:getCacheSize())
    pf:clearCache()
    print("after clear = " .. pf:getCacheSize())
end

--@api-stub: LUnitPathfinder:setCacheMaxSize
-- Path cache management. Focus: setCacheMaxSize.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:fill(1)
    ---@type LUnitPathfinder
    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    print("cache enabled = " .. tostring(pf:isCacheEnabled()))
    pf:setCacheMaxSize(100)
    pf:findPath(1, 1, 20, 20)
    pf:findPath(5, 5, 15, 15)
    print("cache size = " .. pf:getCacheSize())
    pf:clearCache()
    print("after clear = " .. pf:getCacheSize())
end

--@api-stub: LUnitPathfinder:getCacheSize
-- Path cache management. Focus: getCacheSize.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:fill(1)
    ---@type LUnitPathfinder
    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    print("cache enabled = " .. tostring(pf:isCacheEnabled()))
    pf:setCacheMaxSize(100)
    pf:findPath(1, 1, 20, 20)
    pf:findPath(5, 5, 15, 15)
    print("cache size = " .. pf:getCacheSize())
    pf:clearCache()
    print("after clear = " .. pf:getCacheSize())
end

--@api-stub: LUnitPathfinder:clearCache
-- Path cache management. Focus: clearCache.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:fill(1)
    ---@type LUnitPathfinder
    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    print("cache enabled = " .. tostring(pf:isCacheEnabled()))
    pf:setCacheMaxSize(100)
    pf:findPath(1, 1, 20, 20)
    pf:findPath(5, 5, 15, 15)
    print("cache size = " .. pf:getCacheSize())
    pf:clearCache()
    print("after clear = " .. pf:getCacheSize())
end

--@api-stub: LUnitPathfinder:type
-- Type checking. Focus: type.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(5, 5)
    ---@type LUnitPathfinder
    local pf = lurek.pathfind.newPathfinder(nav)
    print("type = " .. pf:type())
    print("is LUnitPathfinder = " .. tostring(pf:typeOf("LUnitPathfinder")))
end

--@api-stub: LUnitPathfinder:typeOf
-- Type checking. Focus: typeOf.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(5, 5)
    ---@type LUnitPathfinder
    local pf = lurek.pathfind.newPathfinder(nav)
    print("type = " .. pf:type())
    print("is LUnitPathfinder = " .. tostring(pf:typeOf("LUnitPathfinder")))
end

--@api-stub: lurek.pathfind.rangeMap
-- Range map computation from options table.
do
    local result = lurek.pathfind.rangeMap({
        width = 10,
        height = 10,
        origin_x = 5,
        origin_y = 5,
        budget = 4,
        diagonal = true
    })
    print("range map width = " .. result.width .. " height = " .. result.height)
    print("cells count = " .. #result.cells)
end

--@api-stub: lurek.pathfind.getThreadCount
-- Thread count (placeholder API).
do
    local tc = lurek.pathfind.getThreadCount()
    print("thread count = " .. tc)
    lurek.pathfind.setThreadCount(4)
end

--- Pathfind Module Part 3: AI flow field, flow field calculated flag, nav grid dims, nav mesh polygon count, path grid dims, newNavGridFromTileMap, setThreadCount


--@api-stub: LAIFlowField:getHeight
-- AI flow field dimensions and goal state. Focus: getHeight.
do
    local pg = lurek.pathfind.newPathGrid(32, 32, 1)
    local ff = lurek.pathfind.newPathFlowField(pg)
    print("ff_w=" .. ff:getWidth())
    print("ff_h=" .. ff:getHeight())
    print("has_goal=" .. tostring(ff:hasGoal()))
    ff:setGoal(16, 16)
    print("has_goal_after=" .. tostring(ff:hasGoal()))
end

--@api-stub: LAIFlowField:getWidth
-- AI flow field dimensions and goal state. Focus: getWidth.
do
    local pg = lurek.pathfind.newPathGrid(32, 32, 1)
    local ff = lurek.pathfind.newPathFlowField(pg)
    print("ff_w=" .. ff:getWidth())
    print("ff_h=" .. ff:getHeight())
    print("has_goal=" .. tostring(ff:hasGoal()))
    ff:setGoal(16, 16)
    print("has_goal_after=" .. tostring(ff:hasGoal()))
end

--@api-stub: LAIFlowField:hasGoal
-- AI flow field dimensions and goal state. Focus: hasGoal.
do
    local pg = lurek.pathfind.newPathGrid(32, 32, 1)
    local ff = lurek.pathfind.newPathFlowField(pg)
    print("ff_w=" .. ff:getWidth())
    print("ff_h=" .. ff:getHeight())
    print("has_goal=" .. tostring(ff:hasGoal()))
    ff:setGoal(16, 16)
    print("has_goal_after=" .. tostring(ff:hasGoal()))
end

--@api-stub: LFlowField:isCalculated
-- Flow field calculation state.
do
    local grid = lurek.pathfind.newNavGrid(16, 16)
    local ff = lurek.pathfind.newFlowField(grid)
    print("is_calc=" .. tostring(ff:isCalculated()))
    ff:calculate(8, 8, 1)
    print("is_calc_after=" .. tostring(ff:isCalculated()))
end

--@api-stub: LNavGrid:getDimensions
-- Nav grid dimension queries. Focus: getDimensions.
do
    local ng = lurek.pathfind.newNavGrid(20, 15)
    local w, h = ng:getDimensions()
    print("dims=" .. w .. "x" .. h)
    print("w=" .. ng:getWidth())
    print("h=" .. ng:getHeight())
end

--@api-stub: LNavGrid:getHeight
-- Nav grid dimension queries. Focus: getHeight.
do
    local ng = lurek.pathfind.newNavGrid(20, 15)
    local w, h = ng:getDimensions()
    print("dims=" .. w .. "x" .. h)
    print("w=" .. ng:getWidth())
    print("h=" .. ng:getHeight())
end

--@api-stub: LNavGrid:getWidth
-- Nav grid dimension queries. Focus: getWidth.
do
    local ng = lurek.pathfind.newNavGrid(20, 15)
    local w, h = ng:getDimensions()
    print("dims=" .. w .. "x" .. h)
    print("w=" .. ng:getWidth())
    print("h=" .. ng:getHeight())
end

--@api-stub: LNavMesh:getPolygonCount
-- Nav mesh polygon count.
do
    local ng = lurek.pathfind.newNavGrid(8, 8)
    local mesh = lurek.pathfind.newNavMesh()
    print("poly_count=" .. mesh:getPolygonCount())
end

--@api-stub: LPathGrid:getCellSize
-- Path grid dimension and cell size queries. Focus: getCellSize.
do
    local pg = lurek.pathfind.newPathGrid(10, 10, 32)
    print("cell=" .. pg:getCellSize())
    print("w=" .. pg:getWidth())
    print("h=" .. pg:getHeight())
end

--@api-stub: LPathGrid:getHeight
-- Path grid dimension and cell size queries. Focus: getHeight.
do
    local pg = lurek.pathfind.newPathGrid(10, 10, 32)
    print("cell=" .. pg:getCellSize())
    print("w=" .. pg:getWidth())
    print("h=" .. pg:getHeight())
end

--@api-stub: LPathGrid:getWidth
-- Path grid dimension and cell size queries. Focus: getWidth.
do
    local pg = lurek.pathfind.newPathGrid(10, 10, 32)
    print("cell=" .. pg:getCellSize())
    print("w=" .. pg:getWidth())
    print("h=" .. pg:getHeight())
end

--@api-stub: lurek.pathfind.newNavGridFromTileMap
-- Create nav grid from tilemap layer.
do
    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local layer = tm:addLayer("ground", 8, 8)
    local ng = lurek.pathfind.newNavGridFromTileMap(tm, layer, { 1, 2 })
    print("ng_from_tm=" .. ng:getWidth() .. "x" .. ng:getHeight())
end

--@api-stub: lurek.pathfind.setThreadCount
-- Configure pathfinding thread pool size.
do
    lurek.pathfind.setThreadCount(2)
    print("thread count set")
end

print("content/examples/pathfind.lua")
