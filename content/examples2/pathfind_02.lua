--- Pathfinding Module Part 3: flow fields, AI flow fields, unit pathfinder

--@api-stub: lurek.pathfind.newFlowField
--@api-stub: LFlowField:calculate
-- Flow field creation and single-target calculation.
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
--@api-stub: LFlowField:getDirectionAngle
--@api-stub: LFlowField:getCostToTarget
-- Flow field queries.
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
--@api-stub: LFlowField:getTargets
-- Multi-target flow field.
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
--@api-stub: LFlowField:typeOf
-- Type checking.
do
    ---@type LNavGrid
    local nav = lurek.pathfind.newNavGrid(5, 5)
    ---@type LFlowField
    local ff = lurek.pathfind.newFlowField(nav)
    print("type = " .. ff:type())
    print("is LFlowField = " .. tostring(ff:typeOf("LFlowField")))
end

--@api-stub: lurek.pathfind.newPathFlowField
--@api-stub: LAIFlowField:setGoal
--@api-stub: LAIFlowField:getGoal
-- AI flow field from a path grid.
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
--@api-stub: LAIFlowField:getDistance
-- AI flow field direction and distance queries.
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
--@api-stub: LAIFlowField:typeOf
-- Type checking.
do
    ---@type LPathGrid
    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    ---@type LAIFlowField
    local aiff = lurek.pathfind.newPathFlowField(grid)
    print("type = " .. aiff:type())
    print("is LAIFlowField = " .. tostring(aiff:typeOf("LAIFlowField")))
end

--@api-stub: lurek.pathfind.newPathfinder
--@api-stub: LUnitPathfinder:findPath
-- Unit pathfinder creation and basic pathfinding.
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
--@api-stub: LUnitPathfinder:lineOfSight
--@api-stub: LUnitPathfinder:heuristicDistance
-- Reachability and visibility checks.
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
--@api-stub: LUnitPathfinder:getPathLength
-- Path cost and length utilities.
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
--@api-stub: LUnitPathfinder:isCacheEnabled
--@api-stub: LUnitPathfinder:setCacheMaxSize
--@api-stub: LUnitPathfinder:getCacheSize
--@api-stub: LUnitPathfinder:clearCache
-- Path cache management.
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
--@api-stub: LUnitPathfinder:typeOf
-- Type checking.
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
--@api-stub: lurek.setThreadCount
-- Thread count (placeholder API).
do
    local tc = lurek.pathfind.getThreadCount()
    print("thread count = " .. tc)
    lurek.pathfind.setThreadCount(4)
end

print("pathfind_02.lua")
