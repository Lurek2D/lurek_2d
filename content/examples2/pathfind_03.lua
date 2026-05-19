--- Pathfind Module Part 3: AI flow field, flow field calculated flag, nav grid dims, nav mesh polygon count, path grid dims, newNavGridFromTileMap, setThreadCount

--@api-stub: LAIFlowField:getHeight
--@api-stub: LAIFlowField:getWidth
--@api-stub: LAIFlowField:hasGoal
-- AI flow field dimensions and goal state.
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
--@api-stub: LNavGrid:getHeight
--@api-stub: LNavGrid:getWidth
-- Nav grid dimension queries.
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
--@api-stub: LPathGrid:getHeight
--@api-stub: LPathGrid:getWidth
-- Path grid dimension and cell size queries.
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
    local ng = lurek.pathfind.newNavGridFromTileMap(tm, 1, { 1, 2 })
    print("ng_from_tm=" .. ng:getWidth() .. "x" .. ng:getHeight())
end

--@api-stub: lurek.pathfind.setThreadCount
-- Configure pathfinding thread pool size.
do
    lurek.pathfind.setThreadCount(2)
    print("thread count set")
end

print("pathfind_03.lua")
