--- Pathfinding Module Part 1: grid pathfinding basics (LPathGrid, LNavGrid)

--@api-stub: lurek.pathfind.newPathGrid
--@api-stub: LPathGrid:setWalkable
--@api-stub: LPathGrid:isWalkable
-- Basic cell-size path grid creation and walkability.
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
--@api-stub: LPathGrid:getCost
-- Movement cost per cell.
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
--@api-stub: LPathGrid:typeOf
-- Type checking.
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
--@api-stub: LNavGrid:isBlocked
--@api-stub: LNavGrid:setCost
--@api-stub: LNavGrid:getCost
-- Blocking and movement cost.
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
--@api-stub: LNavGrid:fill
--@api-stub: LNavGrid:fillRect
-- Walkability checks and bulk fill operations.
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
--@api-stub: LNavGrid:getDiagonalMode
-- Diagonal movement modes.
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
--@api-stub: LNavGrid:getChunkSize
--@api-stub: LNavGrid:rebuildAbstract
-- Hierarchical abstract graph for large grids.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(100, 100)
    nav:setChunkSize(16)
    print("chunk size = " .. nav:getChunkSize())
    nav:rebuildAbstract()
    print("abstract graph rebuilt")
end

--@api-stub: LNavGrid:setDirty
--@api-stub: LNavGrid:clearDirty
-- Incremental dirty regions.
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
--@api-stub: LNavGrid:loadFromString
-- Serialization.
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
--@api-stub: LNavGrid:typeOf
-- Type checking.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(5, 5)
    print("type = " .. nav:type())
    print("is LNavGrid = " .. tostring(nav:typeOf("LNavGrid")))
end

print("pathfind_00.lua")
