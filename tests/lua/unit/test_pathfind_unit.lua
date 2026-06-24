-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_pathfind_core_unit.lua
do
-- Canonical unit coverage for lurek.pathfind.

local function new_nav_grid(width, height)
    return lurek.pathfind.newNavGrid(width or 12, height or 12)
end

local function new_world_agent(name)
    local world = lurek.ai.newWorld()
    local agent = world:addAgent(name or "agent")
    return world, agent
end

local function new_pathfinder()
    local grid = new_nav_grid()
    return grid, lurek.pathfind.newPathfinder(grid)
end

local function new_flow_field()
    local grid = new_nav_grid()
    return grid, lurek.pathfind.newFlowField(grid)
end

local function new_path_grid()
    return lurek.pathfind.newPathGrid(12, 12, 16)
end

local function new_ai_flow_field()
    local grid = new_path_grid()
    return grid, lurek.pathfind.newPathFlowField(grid)
end

local function new_hex_grid()
    return lurek.pathfind.newHexGrid(8, 8)
end

local function new_jps_grid()
    return lurek.pathfind.newJpsGrid(8, 8)
end

local function new_nav_mesh()
    return lurek.pathfind.newNavMesh()
end

local function new_goal_map()
    return lurek.pathfind.newGoalMap(20, 20)
end

local function new_influence_map()
    return lurek.pathfind.newInfluenceMap(4, 3, 2)
end

local function poll_async_until(predicate, max_steps)
    local steps = max_steps or 64
    local seen = {}
    for _ = 1, steps do
        local events = lurek.pathfind.pollAsyncPaths()
        for i = 1, #events do
            seen[#seen + 1] = events[i]
        end
        if predicate(seen) then
            return seen
        end
        lurek.timer.sleep(0.001)
    end
    return seen
end

local function connect_test_mesh(mesh)
    local left = mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 10, y = 0 },
        { x = 10, y = 10 },
        { x = 0, y = 10 },
    })
    local right = mesh:addPolygon({
        { x = 10, y = 0 },
        { x = 20, y = 0 },
        { x = 20, y = 10 },
        { x = 10, y = 10 },
    })
    return left, right
end

-- @describe module functions
describe("pathfind module functions", function()
    -- @covers lurek.pathfind.newNavGrid
    it("newNavGrid creates userdata", function()
        expect_type("userdata", new_nav_grid())
    end)

    -- @covers lurek.pathfind.newPathfinder
    it("newPathfinder creates userdata", function()
        local _, pathfinder = new_pathfinder()
        expect_type("userdata", pathfinder)
    end)

    -- @covers lurek.pathfind.newFlowField
    it("newFlowField creates userdata", function()
        local _, flow = new_flow_field()
        expect_type("userdata", flow)
    end)

    -- @covers lurek.pathfind.newPathGrid
    it("newPathGrid creates userdata and rejects a non-positive cell size", function()
        expect_type("userdata", new_path_grid())
        expect_error(function()
            lurek.pathfind.newPathGrid(4, 4, 0)
        end)
    end)

    -- @covers lurek.pathfind.newPathFlowField
    it("newPathFlowField creates userdata", function()
        local _, flow = new_ai_flow_field()
        expect_type("userdata", flow)
    end)

    -- @covers lurek.pathfind.setThreadCount
    it("setThreadCount accepts a positive integer", function()
        expect_no_error(function()
            lurek.pathfind.setThreadCount(1)
        end)
    end)

    -- @covers lurek.pathfind.getThreadCount
    it("getThreadCount returns a number", function()
        expect_type("number", lurek.pathfind.getThreadCount())
    end)

    -- @covers lurek.pathfind.submitAsyncPath
    it("submitAsyncPath returns ids and supersedes older owner versions", function()
        lurek.pathfind.clearAsyncPaths()
        local grid = new_nav_grid(24, 24)
        local request_id = lurek.pathfind.submitAsyncPath(grid, {
            start_x = 1,
            start_y = 1,
            goal_x = 24,
            goal_y = 24,
            stream_budget = 4,
        })
        expect_type("number", request_id)
        lurek.pathfind.setThreadCount(1)
        lurek.pathfind.clearAsyncPaths()
        local grid = new_nav_grid(512, 512)
        local first_id = lurek.pathfind.submitAsyncPath(grid, {
            start_x = 1,
            start_y = 1,
            goal_x = 512,
            goal_y = 512,
            owner_id = 9001,
            version = 1,
            stream_budget = 1,
        })
        local second_id = lurek.pathfind.submitAsyncPath(grid, {
            start_x = 1,
            start_y = 1,
            goal_x = 512,
            goal_y = 512,
            owner_id = 9001,
            version = 2,
            priority = 1,
            stream_budget = 1,
        })
        local events = poll_async_until(function(seen)
            local first_done = false
            local second_done = false
            for i = 1, #seen do
                if seen[i].id == first_id and seen[i].status == "superseded" and seen[i].final then
                    first_done = true
                end
                if seen[i].id == second_id and seen[i].status == "complete" and seen[i].final then
                    second_done = true
                end
            end
            return first_done and second_done
        end, 1024)

        local first_done = false
        local second_done = false
        for i = 1, #events do
            if events[i].id == first_id and events[i].status == "superseded" and events[i].final then
                first_done = true
            end
            if events[i].id == second_id and events[i].status == "complete" and events[i].final then
                second_done = true
            end
        end
        expect_true(first_done)
        expect_true(second_done)
    end)

    -- @covers lurek.pathfind.pollAsyncPaths
    it("pollAsyncPaths yields partial and final events for streamed searches", function()
        lurek.pathfind.clearAsyncPaths()
        local grid = new_nav_grid(24, 24)
        local request_id = lurek.pathfind.submitAsyncPath(grid, {
            start_x = 1,
            start_y = 1,
            goal_x = 24,
            goal_y = 24,
            stream_budget = 4,
        })
        local events = poll_async_until(function(seen)
            local partial = false
            local complete = false
            for i = 1, #seen do
                if seen[i].id == request_id and seen[i].status == "partial" then
                    partial = true
                end
                if seen[i].id == request_id and seen[i].status == "complete" and seen[i].final then
                    complete = true
                end
            end
            return partial and complete
        end)

        local partial = false
        local complete = false
        for i = 1, #events do
            if events[i].id == request_id and events[i].status == "partial" then
                partial = true
            end
            if events[i].id == request_id and events[i].status == "complete" and events[i].final then
                complete = true
            end
        end
        expect_true(partial)
        expect_true(complete)
    end)

    -- @covers lurek.pathfind.cancelAsyncPath
    it("cancelAsyncPath produces a terminal cancelled event", function()
        local previous_threads = lurek.pathfind.getThreadCount()
        lurek.pathfind.setThreadCount(1)
        lurek.pathfind.clearAsyncPaths()
        local grid = new_nav_grid(48, 48)
        lurek.pathfind.submitAsyncPath(grid, {
            start_x = 1,
            start_y = 1,
            goal_x = 48,
            goal_y = 48,
            stream_budget = 1,
            priority = 10,
        })
        local request_id = lurek.pathfind.submitAsyncPath(grid, {
            start_x = 1,
            start_y = 1,
            goal_x = 48,
            goal_y = 48,
            stream_budget = 4,
            priority = 0,
        })
        expect_true(lurek.pathfind.cancelAsyncPath(request_id))
        local events = poll_async_until(function(seen)
            for i = 1, #seen do
                if seen[i].id == request_id and seen[i].status == "cancelled" and seen[i].final then
                    return true
                end
            end
            return false
        end)

        local cancelled = false
        for i = 1, #events do
            if events[i].id == request_id and events[i].status == "cancelled" and events[i].final then
                cancelled = true
            end
        end
        lurek.pathfind.clearAsyncPaths()
        lurek.pathfind.setThreadCount(previous_threads)
        expect_true(cancelled)
    end)

    -- @covers lurek.pathfind.getAsyncPendingCount
    it("getAsyncPendingCount returns a number", function()
        lurek.pathfind.clearAsyncPaths()
        expect_type("number", lurek.pathfind.getAsyncPendingCount())
    end)

    -- @covers lurek.pathfind.clearAsyncPaths
    it("clearAsyncPaths resets queued async work", function()
        lurek.pathfind.clearAsyncPaths()
        local grid = new_nav_grid(20, 20)
        lurek.pathfind.submitAsyncPath(grid, {
            start_x = 1,
            start_y = 1,
            goal_x = 20,
            goal_y = 20,
            stream_budget = 4,
        })
        lurek.pathfind.clearAsyncPaths()
        expect_equal(0, lurek.pathfind.getAsyncPendingCount())
    end)

    -- @covers lurek.pathfind.newNavGridFromTileMap
    it("newNavGridFromTileMap is exposed as a function", function()
        expect_type("function", lurek.pathfind.newNavGridFromTileMap)
    end)

    -- @covers lurek.pathfind.newHexGrid
    it("newHexGrid creates userdata", function()
        expect_type("userdata", new_hex_grid())
    end)

    -- @covers lurek.pathfind.newJpsGrid
    it("newJpsGrid creates userdata", function()
        expect_type("userdata", new_jps_grid())
    end)

    -- @covers lurek.pathfind.newNavMesh
    it("newNavMesh creates userdata", function()
        expect_type("userdata", new_nav_mesh())
    end)

    -- @covers lurek.pathfind.rangeMap
    it("rangeMap returns width height and reachable cells", function()
        local result = lurek.pathfind.rangeMap({
            width = 8,
            height = 8,
            origin_x = 4,
            origin_y = 4,
            budget = 3.0,
        })
        expect_equal(8, result.width)
        expect_equal(8, result.height)
        expect_type("table", result.cells)
        expect_true(#result.cells > 0)
    end)

    -- @covers lurek.pathfind.newGoalMap
    it("newGoalMap creates userdata", function()
        expect_type("userdata", new_goal_map())
    end)
end)

-- @describe nav grid
describe("nav grid", function()
    -- @covers LNavGrid:getWidth
    it("getWidth returns the configured width", function()
        expect_equal(7, new_nav_grid(7, 9):getWidth())
    end)

    -- @covers LNavGrid:getHeight
    it("getHeight returns the configured height", function()
        expect_equal(9, new_nav_grid(7, 9):getHeight())
    end)

    -- @covers LNavGrid:getDimensions
    it("getDimensions returns width and height", function()
        local width, height = new_nav_grid(5, 6):getDimensions()
        expect_equal(5, width)
        expect_equal(6, height)
    end)

    -- @covers LNavGrid:setCost
    it("setCost updates the cell traversal cost and rejects zero-based coordinates", function()
        local grid = new_nav_grid()
        grid:setCost(3, 3, 7)
        expect_equal(7, grid:getCost(3, 3))
        expect_error(function()
            grid:setCost(0, 1, 7)
        end)
    end)

    -- @covers LNavGrid:getCost
    it("getCost defaults to one", function()
        expect_equal(1, new_nav_grid():getCost(1, 1))
    end)

    -- @covers LNavGrid:setBlocked
    it("setBlocked marks a cell as blocked", function()
        local grid = new_nav_grid()
        grid:setBlocked(2, 2, true)
        expect_true(grid:isBlocked(2, 2))
    end)

    -- @covers LNavGrid:isBlocked
    it("isBlocked is false for a fresh cell", function()
        expect_false(new_nav_grid():isBlocked(2, 2))
    end)

    -- @covers LNavGrid:isWalkable
    it("isWalkable rejects blocked footprints", function()
        local grid = new_nav_grid(5, 5)
        grid:setBlocked(2, 1, true)
        expect_false(grid:isWalkable(1, 1, 2))
    end)

    -- @covers LNavGrid:fill
    it("fill applies a cost to all cells", function()
        local grid = new_nav_grid(4, 4)
        grid:fill(3)
        expect_equal(3, grid:getCost(4, 4))
    end)

    -- @covers LNavGrid:fillRect
    it("fillRect blocks a rectangular region when cost is zero", function()
        local grid = new_nav_grid(6, 6)
        grid:fillRect(2, 2, 2, 2, 0)
        expect_true(grid:isBlocked(2, 2))
        expect_true(grid:isBlocked(3, 3))
    end)

    -- @covers LNavGrid:loadFromString
    it("loadFromString restores serialized blocked cells", function()
        local original = new_nav_grid(6, 6)
        original:setBlocked(3, 4, true)
        local restored = new_nav_grid(6, 6)
        restored:loadFromString(original:saveToString())
        expect_true(restored:isBlocked(3, 4))
    end)

    -- @covers LNavGrid:saveToString
    it("saveToString returns a non-empty string", function()
        local blob = new_nav_grid():saveToString()
        expect_type("string", blob)
        expect_greater(#blob, 0)
    end)

    -- @covers LNavGrid:setChunkSize
    it("setChunkSize stores the chunk size", function()
        local grid = new_nav_grid(16, 16)
        grid:setChunkSize(8)
        expect_equal(8, grid:getChunkSize())
    end)

    -- @covers LNavGrid:getChunkSize
    it("getChunkSize returns the stored value", function()
        local grid = new_nav_grid(16, 16)
        grid:setChunkSize(4)
        expect_equal(4, grid:getChunkSize())
    end)

    -- @covers LNavGrid:rebuildAbstract
    it("rebuildAbstract is callable after dirtying a region", function()
        local grid = new_nav_grid(16, 16)
        expect_no_error(function()
            grid:setDirty(1, 1, 4, 4)
            grid:rebuildAbstract()
        end)
    end)

    -- @covers LNavGrid:findHpaPath
    it("findHpaPath returns a path table", function()
        local path = new_nav_grid(20, 20):findHpaPath(1, 1, 10, 10)
        expect_type("table", path)
    end)

    -- @covers LNavGrid:setDirty
    it("setDirty accepts a rectangular region", function()
        expect_no_error(function()
            new_nav_grid(16, 16):setDirty(1, 1, 4, 4)
        end)
    end)

    -- @covers LNavGrid:clearDirty
    it("clearDirty is callable after setDirty", function()
        local grid = new_nav_grid(16, 16)
        grid:setDirty(1, 1, 4, 4)
        expect_no_error(function()
            grid:clearDirty()
        end)
    end)

    -- @covers LNavGrid:setDiagonalMode
    it("setDiagonalMode stores the requested mode", function()
        local grid = new_nav_grid()
        grid:setDiagonalMode("always")
        expect_equal("always", grid:getDiagonalMode())
    end)

    -- @covers LNavGrid:getDiagonalMode
    it("getDiagonalMode returns the current mode", function()
        local grid = new_nav_grid()
        grid:setDiagonalMode("none")
        expect_equal("none", grid:getDiagonalMode())
    end)

    -- @covers LNavGrid:type
    it("type returns LNavGrid", function()
        expect_equal("LNavGrid", new_nav_grid():type())
    end)

    -- @covers LNavGrid:typeOf
    it("typeOf recognizes the nav-grid type", function()
        expect_true(new_nav_grid():typeOf("LNavGrid"))
    end)
end)

-- @describe unit pathfinder
describe("unit pathfinder", function()
    -- @covers LUnitPathfinder:findPath
    it("findPath returns a route on an open grid", function()
        local _, pathfinder = new_pathfinder()
        local path = pathfinder:findPath(1, 1, 8, 8)
        expect_type("table", path)
        expect_true(#path > 0)
    end)

    -- @covers LUnitPathfinder:findPathSmooth
    it("findPathSmooth returns a smoothed route", function()
        local _, pathfinder = new_pathfinder()
        local path = pathfinder:findPathSmooth(1, 1, 8, 8)
        expect_type("table", path)
    end)

    -- @covers LUnitPathfinder:findPathBidirectional
    it("findPathBidirectional returns path and completion flag", function()
        local _, pathfinder = new_pathfinder()
        local path, complete = pathfinder:findPathBidirectional(1, 1, 8, 8)
        expect_type("table", path)
        expect_type("boolean", complete)
    end)

    -- @covers LUnitPathfinder:getPathLength
    it("getPathLength returns a non-negative number", function()
        local _, pathfinder = new_pathfinder()
        local path = pathfinder:findPath(1, 1, 8, 8)
        expect_type("number", pathfinder:getPathLength(path))
    end)

    -- @covers LUnitPathfinder:getPathCost
    it("getPathCost returns a non-negative number", function()
        local _, pathfinder = new_pathfinder()
        local path = pathfinder:findPath(1, 1, 8, 8)
        expect_type("number", pathfinder:getPathCost(path))
    end)

    -- @covers LUnitPathfinder:findPartialPath
    it("findPartialPath returns a path and completion flag", function()
        local _, pathfinder = new_pathfinder()
        local path, complete = pathfinder:findPartialPath(1, 1, 12, 12, 12)
        expect_type("table", path)
        expect_type("boolean", complete)
    end)

    -- @covers LUnitPathfinder:findNearestWalkable
    it("findNearestWalkable returns substitute coordinates", function()
        local grid, pathfinder = new_pathfinder()
        grid:setBlocked(5, 5, true)
        local x, y = pathfinder:findNearestWalkable(5, 5, 4)
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers LUnitPathfinder:isReachable
    it("isReachable is true on an open grid", function()
        local _, pathfinder = new_pathfinder()
        expect_true(pathfinder:isReachable(1, 1, 12, 12))
    end)

    -- @covers LUnitPathfinder:heuristicDistance
    it("heuristicDistance returns a positive estimate", function()
        local _, pathfinder = new_pathfinder()
        expect_greater(pathfinder:heuristicDistance(1, 1, 4, 5), 0)
    end)


    -- @covers LUnitPathfinder:setCacheEnabled
    it("setCacheEnabled toggles cache usage", function()
        local _, pathfinder = new_pathfinder()
        pathfinder:setCacheEnabled(false)
        expect_false(pathfinder:isCacheEnabled())
    end)

    -- @covers LUnitPathfinder:isCacheEnabled
    it("isCacheEnabled is true by default", function()
        local _, pathfinder = new_pathfinder()
        expect_true(pathfinder:isCacheEnabled())
    end)

    -- @covers LUnitPathfinder:clearCache
    it("clearCache empties the path cache", function()
        local _, pathfinder = new_pathfinder()
        pathfinder:findPath(1, 1, 8, 8)
        pathfinder:clearCache()
        expect_equal(0, pathfinder:getCacheSize())
    end)

    -- @covers LUnitPathfinder:getCacheSize
    it("getCacheSize returns a number", function()
        local _, pathfinder = new_pathfinder()
        expect_type("number", pathfinder:getCacheSize())
    end)

    -- @covers LUnitPathfinder:setCacheMaxSize
    it("setCacheMaxSize is callable", function()
        local _, pathfinder = new_pathfinder()
        expect_no_error(function()
            pathfinder:setCacheMaxSize(128)
        end)
    end)

    -- @covers LUnitPathfinder:type
    it("type returns LUnitPathfinder", function()
        local _, pathfinder = new_pathfinder()
        expect_equal("LUnitPathfinder", pathfinder:type())
    end)

    -- @covers LUnitPathfinder:typeOf
    it("typeOf recognizes the pathfinder type", function()
        local _, pathfinder = new_pathfinder()
        expect_true(pathfinder:typeOf("LUnitPathfinder"))
    end)
end)

-- @describe flow field
describe("flow field", function()
    -- @covers LFlowField:calculate
    it("calculate marks the field as ready", function()
        local _, flow = new_flow_field()
        flow:calculate(6, 6)
        expect_true(flow:isCalculated())
    end)

    -- @covers LFlowField:calculateMulti
    it("calculateMulti accepts multiple targets", function()
        local _, flow = new_flow_field()
        flow:calculateMulti({ { x = 4, y = 4 }, { x = 8, y = 8 } })
        expect_true(flow:isCalculated())
    end)

    -- @covers LFlowField:getDirection
    it("getDirection returns vector components", function()
        local _, flow = new_flow_field()
        flow:calculate(6, 6)
        local dx, dy = flow:getDirection(1, 1)
        expect_type("number", dx)
        expect_type("number", dy)
    end)

    -- @covers LFlowField:getDirectionAngle
    it("getDirectionAngle returns a number", function()
        local _, flow = new_flow_field()
        flow:calculateMulti({ { x = 4, y = 4 }, { x = 8, y = 8 } })
        expect_type("number", flow:getDirectionAngle(1, 1))
    end)

    -- @covers LFlowField:getCostToTarget
    it("getCostToTarget is zero at the target cell", function()
        local _, flow = new_flow_field()
        flow:calculate(3, 3)
        expect_near(0.0, flow:getCostToTarget(3, 3), 0.01)
    end)

    -- @covers LFlowField:isCalculated
    it("isCalculated is false before calculation", function()
        local _, flow = new_flow_field()
        expect_false(flow:isCalculated())
    end)

    -- @covers LFlowField:getTargets
    it("getTargets lists the active target cells", function()
        local _, flow = new_flow_field()
        flow:calculate(2, 2)
        expect_equal(1, #flow:getTargets())
    end)

    -- @covers LFlowField:steer
    it("steer returns velocity components", function()
        local _, flow = new_flow_field()
        flow:calculate(6, 6)
        local vx, vy = flow:steer(0, 0, 32, 1, 1)
        expect_type("number", vx)
        expect_type("number", vy)
    end)

    -- @covers LFlowField:type
    it("type returns LFlowField", function()
        local _, flow = new_flow_field()
        expect_equal("LFlowField", flow:type())
    end)

    -- @covers LFlowField:typeOf
    it("typeOf recognizes the flow-field type", function()
        local _, flow = new_flow_field()
        expect_true(flow:typeOf("LFlowField"))
    end)
end)

-- @describe path grid
describe("path grid", function()
    -- @covers LPathGrid:getWidth
    it("getWidth returns the configured width", function()
        expect_equal(12, new_path_grid():getWidth())
    end)

    -- @covers LPathGrid:getHeight
    it("getHeight returns the configured height", function()
        expect_equal(12, new_path_grid():getHeight())
    end)

    -- @covers LPathGrid:getCellSize
    it("getCellSize returns the configured cell size", function()
        expect_equal(16, new_path_grid():getCellSize())
    end)

    -- @covers LPathGrid:setWalkable
    it("setWalkable flips walkability and rejects zero-based coordinates", function()
        local grid = new_path_grid()
        grid:setWalkable(2, 2, false)
        expect_false(grid:isWalkable(2, 2))
        expect_error(function()
            grid:setWalkable(0, 2, false)
        end)
    end)

    -- @covers LPathGrid:isWalkable
    it("isWalkable is true by default", function()
        expect_true(new_path_grid():isWalkable(1, 1))
    end)

    -- @covers LPathGrid:setCost
    it("setCost updates traversal cost", function()
        local grid = new_path_grid()
        grid:setCost(3, 3, 5)
        expect_equal(5, grid:getCost(3, 3))
    end)

    -- @covers LPathGrid:getCost
    it("getCost returns the stored traversal cost", function()
        local grid = new_path_grid()
        grid:setCost(4, 4, 9)
        expect_equal(9, grid:getCost(4, 4))
    end)

    -- @covers LPathGrid:findPath
    it("findPath returns a route on an open grid", function()
        local path = new_path_grid():findPath(1, 1, 8, 8)
        expect_type("table", path)
        expect_true(#path > 0)
    end)

    -- @covers LPathGrid:findPathSmoothed
    it("findPathSmoothed returns a route on an open grid", function()
        local path = new_path_grid():findPathSmoothed(1, 1, 8, 8)
        expect_type("table", path)
    end)

    -- @covers LPathGrid:type
    it("type returns LPathGrid", function()
        expect_equal("LPathGrid", new_path_grid():type())
    end)

    -- @covers LPathGrid:typeOf
    it("typeOf recognizes the path-grid type", function()
        expect_true(new_path_grid():typeOf("LPathGrid"))
    end)
end)

-- @describe ai flow field
describe("ai flow field", function()
    -- @covers LAIFlowField:getWidth
    it("getWidth returns the grid width", function()
        local _, flow = new_ai_flow_field()
        expect_equal(12, flow:getWidth())
    end)

    -- @covers LAIFlowField:getHeight
    it("getHeight returns the grid height", function()
        local _, flow = new_ai_flow_field()
        expect_equal(12, flow:getHeight())
    end)

    -- @covers LAIFlowField:hasGoal
    it("hasGoal is false before setting a goal", function()
        local _, flow = new_ai_flow_field()
        expect_false(flow:hasGoal())
    end)

    -- @covers LAIFlowField:setGoal
    it("setGoal stores a target cell", function()
        local _, flow = new_ai_flow_field()
        flow:setGoal(3, 4)
        local x, y = flow:getGoal()
        expect_equal(3, x)
        expect_equal(4, y)
    end)

    -- @covers LAIFlowField:getGoal
    it("getGoal returns nils when no goal is configured", function()
        local _, flow = new_ai_flow_field()
        local x, y = flow:getGoal()
        expect_nil(x)
        expect_nil(y)
    end)

    -- @covers LAIFlowField:getDirection
    it("getDirection returns vector components", function()
        local _, flow = new_ai_flow_field()
        flow:setGoal(3, 4)
        local dx, dy = flow:getDirection(1, 1)
        expect_type("number", dx)
        expect_type("number", dy)
    end)

    -- @covers LAIFlowField:getDistance
    it("getDistance returns a numeric distance field value", function()
        local _, flow = new_ai_flow_field()
        flow:setGoal(3, 4)
        expect_type("number", flow:getDistance(1, 1))
    end)

    -- @covers LAIFlowField:type
    it("type returns LAIFlowField", function()
        local _, flow = new_ai_flow_field()
        expect_equal("LAIFlowField", flow:type())
    end)

    -- @covers LAIFlowField:typeOf
    it("typeOf recognizes the ai-flow-field type", function()
        local _, flow = new_ai_flow_field()
        expect_true(flow:typeOf("LAIFlowField"))
    end)
end)

-- @describe hex grid
describe("hex grid", function()
    -- @covers LHexGrid:setBlocked
    it("setBlocked marks a hex cell as blocked", function()
        local grid = new_hex_grid()
        grid:setBlocked(2, 2, true)
        expect_true(grid:isBlocked(2, 2))
    end)

    -- @covers LHexGrid:setCost
    it("setCost is callable", function()
        expect_no_error(function()
            new_hex_grid():setCost(3, 3, 2.0)
        end)
    end)

    -- @covers LHexGrid:isBlocked
    it("isBlocked is false for a fresh hex cell", function()
        expect_false(new_hex_grid():isBlocked(1, 1))
    end)

    -- @covers LHexGrid:findPath
    it("findPath returns a route on an open hex grid", function()
        local path = new_hex_grid():findPath(1, 1, 4, 4)
        expect_type("table", path)
        expect_true(#path > 0)
    end)


    -- @covers LHexGrid:fieldOfView
    it("fieldOfView returns visible cells", function()
        local cells = new_hex_grid():fieldOfView(4, 4, 2)
        expect_type("table", cells)
        expect_true(#cells > 0)
    end)

    -- @covers LHexGrid:rangeOfMovement
    it("rangeOfMovement returns reachable cells", function()
        local cells = new_hex_grid():rangeOfMovement(4, 4, 3.0)
        expect_type("table", cells)
        expect_true(#cells > 0)
    end)

    -- @covers LHexGrid:distance
    it("distance returns a numeric hex distance", function()
        expect_equal(1, new_hex_grid():distance(3, 3, 4, 3))
    end)

    -- @covers LHexGrid:type
    it("type returns LHexGrid", function()
        expect_equal("LHexGrid", new_hex_grid():type())
    end)

    -- @covers LHexGrid:typeOf
    it("typeOf recognizes the hex-grid type", function()
        expect_true(new_hex_grid():typeOf("LHexGrid"))
    end)
end)

-- @describe jps grid
describe("jps grid", function()
    -- @covers LJpsGrid:setBlocked
    it("setBlocked marks a cell as blocked", function()
        local grid = new_jps_grid()
        grid:setBlocked(2, 2, true)
        expect_true(grid:isBlocked(2, 2))
    end)

    -- @covers LJpsGrid:isBlocked
    it("isBlocked is false for a fresh jps cell", function()
        expect_false(new_jps_grid():isBlocked(1, 1))
    end)

    -- @covers LJpsGrid:findPath
    it("findPath returns a route on an open grid", function()
        local path = new_jps_grid():findPath(1, 1, 5, 5)
        expect_type("table", path)
        expect_true(#path > 0)
    end)

    -- @covers LJpsGrid:type
    it("type returns LJpsGrid", function()
        expect_equal("LJpsGrid", new_jps_grid():type())
    end)

    -- @covers LJpsGrid:typeOf
    it("typeOf recognizes the jps-grid type", function()
        expect_true(new_jps_grid():typeOf("LJpsGrid"))
    end)
end)

-- @describe nav mesh
describe("nav mesh", function()
    -- @covers LNavMesh:addPolygon
    it("addPolygon returns the inserted polygon id", function()
        local mesh = new_nav_mesh()
        expect_equal(1, mesh:addPolygon({
            { x = 0, y = 0 },
            { x = 10, y = 0 },
            { x = 10, y = 10 },
            { x = 0, y = 10 },
        }))
    end)

    -- @covers LNavMesh:connectPolygons
    it("connectPolygons links adjacent polygons", function()
        local mesh = new_nav_mesh()
        local left, right = connect_test_mesh(mesh)
        expect_true(mesh:connectPolygons(left, right, true))
    end)

    -- @covers LNavMesh:findPath
    it("findPath returns waypoints across connected polygons", function()
        local mesh = new_nav_mesh()
        local left, right = connect_test_mesh(mesh)
        mesh:connectPolygons(left, right, true)
        local path = mesh:findPath(2, 2, 18, 8)
        expect_type("table", path)
        expect_true(#path >= 2)
    end)

    -- @covers LNavMesh:getPolygonCount
    it("getPolygonCount returns the polygon count", function()
        local mesh = new_nav_mesh()
        connect_test_mesh(mesh)
        expect_equal(2, mesh:getPolygonCount())
    end)

    -- @covers LNavMesh:type
    it("type returns LNavMesh", function()
        expect_equal("LNavMesh", new_nav_mesh():type())
    end)

    -- @covers LNavMesh:typeOf
    it("typeOf recognizes the nav-mesh type", function()
        expect_true(new_nav_mesh():typeOf("LNavMesh"))
    end)
end)

-- @describe goal map
describe("goal map", function()
    -- @covers LGoalMap:addSource
    it("addSource accepts a new origin cell", function()
        expect_no_error(function()
            new_goal_map():addSource(5, 5)
        end)
    end)

    -- @covers LGoalMap:setSources
    it("setSources replaces the entire source list", function()
        expect_no_error(function()
            new_goal_map():setSources({ { x = 5, y = 5 }, { x = 8, y = 8 } })
        end)
    end)

    -- @covers LGoalMap:clearSources
    it("clearSources removes registered origins", function()
        local goal_map = new_goal_map()
        goal_map:addSource(5, 5)
        expect_no_error(function()
            goal_map:clearSources()
        end)
    end)

    -- @covers LGoalMap:setBlocker
    it("setBlocker accepts a blocking callback", function()
        local goal_map = new_goal_map()
        expect_no_error(function()
            goal_map:setBlocker(function(x, y)
                return x == 6 and y == 5
            end)
        end)
    end)

    -- @covers LGoalMap:bake
    it("bake computes the distance field", function()
        local goal_map = new_goal_map()
        goal_map:addSource(5, 5)
        goal_map:bake()
        expect_true(goal_map:isReady())
    end)

    -- @covers LGoalMap:isReady
    it("isReady is false before baking", function()
        expect_false(new_goal_map():isReady())
    end)

    -- @covers LGoalMap:distanceAt
    it("distanceAt returns numeric distances", function()
        local goal_map = new_goal_map()
        goal_map:addSource(5, 5)
        goal_map:bake()
        expect_type("number", goal_map:distanceAt(6, 5))
    end)

    -- @covers LGoalMap:gradientAt
    it("gradientAt returns vector components", function()
        local goal_map = new_goal_map()
        goal_map:addSource(5, 5)
        goal_map:bake()
        local gx, gy = goal_map:gradientAt(6, 5)
        expect_type("number", gx)
        expect_type("number", gy)
    end)

    -- @covers LGoalMap:flee
    it("flee returns a direction away from the field", function()
        local goal_map = new_goal_map()
        goal_map:addSource(5, 5)
        goal_map:bake()
        local dx, dy = goal_map:flee(6, 5, 1.0)
        expect_type("number", dx)
        expect_type("number", dy)
    end)

    -- @covers LGoalMap:floodFill
    it("floodFill returns reachable cells around an origin", function()
        local goal_map = new_goal_map()
        goal_map:addSource(5, 5)
        goal_map:bake()
        local cells = goal_map:floodFill(5, 5, 2)
        expect_type("table", cells)
        expect_true(#cells > 0)
    end)

    -- @covers LGoalMap:save
    it("save serializes the baked field", function()
        local goal_map = new_goal_map()
        goal_map:addSource(5, 5)
        goal_map:bake()
        expect_type("string", goal_map:save())
    end)

    -- @covers LGoalMap:restore
    it("restore reconstructs saved distance data", function()
        local original = new_goal_map()
        original:addSource(5, 5)
        original:bake()
        local restored = new_goal_map()
        restored:restore(original:save())
        expect_equal(original:distanceAt(6, 5), restored:distanceAt(6, 5))
    end)

    -- @covers LGoalMap:type
    it("type returns LGoalMap", function()
        expect_equal("LGoalMap", new_goal_map():type())
    end)

    -- @covers LGoalMap:typeOf
    it("typeOf recognizes the goal-map type", function()
        expect_true(new_goal_map():typeOf("LGoalMap"))
    end)
end)

-- @describe pathfind tilefield adapters
describe("pathfind tilefield adapters", function()
    -- @covers lurek.pathfind.newNavGridFromField
    it("creates navgrid from tilefield move channel", function()
        local field = lurek.tilefield.new({ width = 4, height = 4 })
        field:setBlock(2, 2, 1, "move", true)
        local nav = lurek.pathfind.newNavGridFromField(field, { level = 1, channel = "move" })
        expect_equal(4, nav:getWidth())
        expect_true(nav:isBlocked(2, 2))
    end)

    -- @covers lurek.pathfind.rangeMapFromField
    it("computes movement range from tilefield", function()
        local field = lurek.tilefield.new({ width = 5, height = 5 })
        field:setBlock(3, 3, 1, "move", true)
        local range = lurek.pathfind.rangeMapFromField(field, {
            origin = { x = 1, y = 1, z = 1 },
            budget = 3,
            channel = "move",
        })
        expect_equal(5, range.width)
        expect_true(#range.cells > 1)
    end)

    -- @covers lurek.pathfind.newNavGridFromProvider
    it("creates navgrid from provider data", function()
        local nav = lurek.pathfind.newNavGridFromProvider({
            width = 3,
            height = 2,
            blocked = { false, true, false, false, false, false },
            costs = { 1, 1, 4, 1, 1, 1 },
        })
        expect_equal(3, nav:getWidth())
        expect_true(nav:isBlocked(2, 1))
        expect_equal(4, nav:getCost(3, 1))
    end)

    -- @covers lurek.pathfind.newPathGridFromProvider
    it("creates path grid from provider data", function()
        local grid = lurek.pathfind.newPathGridFromProvider({
            width = 3,
            height = 2,
            cellSize = 16,
            walkable = { true, false, true, true, true, true },
        })
        expect_equal(3, grid:getWidth())
        expect_equal(16, grid:getCellSize())
        expect_true(not grid:isWalkable(2, 1))
    end)
end)
-- @describe pathfind movement and tactical APIs
describe("pathfind movement and tactical APIs", function()
    -- @covers lurek.pathfind.newSteeringManager
    it("newSteeringManager creates userdata", function()
        expect_type("userdata", lurek.pathfind.newSteeringManager())
    end)
    -- @covers lurek.pathfind.newInfluenceMap
    it("newInfluenceMap creates userdata", function()
        expect_type("userdata", new_influence_map())
    end)
    -- @covers lurek.pathfind.newContextSteering
    it("newContextSteering creates userdata", function()
        expect_type("userdata", lurek.pathfind.newContextSteering(8))
    end)
    -- @covers lurek.pathfind.newORCASolver
    it("newORCASolver creates userdata", function()
        expect_type("userdata", lurek.pathfind.newORCASolver(1.5))
    end)
    -- @covers LSteeringManager:addSeek
    it("addSeek increases behavior count", function()
        local sm = lurek.pathfind.newSteeringManager()
        sm:addSeek(100, 200)
        expect_equal(1, sm:getBehaviorCount())
    end)
    -- @covers LSteeringManager:addFlee
    it("addFlee increases behavior count", function()
        local sm = lurek.pathfind.newSteeringManager()
        sm:addFlee(0, 0)
        expect_equal(1, sm:getBehaviorCount())
    end)
    -- @covers LSteeringManager:addArrive
    it("addArrive increases behavior count", function()
        local sm = lurek.pathfind.newSteeringManager()
        sm:addArrive(50, 50)
        expect_equal(1, sm:getBehaviorCount())
    end)
    -- @covers LSteeringManager:addWander
    it("addWander increases behavior count", function()
        local sm = lurek.pathfind.newSteeringManager()
        sm:addWander()
        expect_equal(1, sm:getBehaviorCount())
    end)
    -- @covers LSteeringManager:addPursue
    it("addPursue steers toward a stored target entity", function()
        local sm = lurek.pathfind.newSteeringManager()
        sm:setEntity("target", 10, 0, 2, 0)
        sm:addPursue("target")
        local fx, fy = sm:calculate(0, 0, 0, 0, 100, 200, 1 / 60)
        expect_equal(1, sm:getBehaviorCount())
        expect_true(fx > 0, "pursue should steer toward target")
        expect_near(0, fy, 0.01)
    end)
    -- @covers LSteeringManager:addEvade
    it("addEvade steers away from a stored threat entity", function()
        local sm = lurek.pathfind.newSteeringManager()
        sm:setEntity("threat", 10, 0, 0, 0)
        sm:addEvade("threat")
        local fx, fy = sm:calculate(0, 0, 0, 0, 100, 200, 1 / 60)
        expect_equal(1, sm:getBehaviorCount())
        expect_true(fx < 0, "evade should steer away from threat")
        expect_near(0, fy, 0.01)
    end)
    -- @covers LSteeringManager:addFlock
    it("addFlock uses stored neighbors", function()
        local sm = lurek.pathfind.newSteeringManager()
        sm:setEntity("a", 3, 0, 1, 0)
        sm:setEntity("b", 0, 4, 0, 1)
        sm:addFlock()
        local fx, fy = sm:calculate(0, 0, 0, 0, 100, 200, 1 / 60)
        expect_equal(1, sm:getBehaviorCount())
        expect_true(math.abs(fx) > 0.001 or math.abs(fy) > 0.001, "flock should produce steering")
    end)
    -- @covers LSteeringManager:setEntity
    it("setEntity stores named steering context", function()
        local sm = lurek.pathfind.newSteeringManager()
        sm:setEntity("target", 8, 0)
        expect_equal(1, sm:entityCount())
    end)
    -- @covers LSteeringManager:removeEntity
    it("removeEntity returns whether an entity existed", function()
        local sm = lurek.pathfind.newSteeringManager()
        sm:setEntity("target", 8, 0, 0, 0)
        expect_true(sm:removeEntity("target"))
        expect_false(sm:removeEntity("target"))
    end)
    -- @covers LSteeringManager:clearEntities
    it("clearEntities removes all steering context", function()
        local sm = lurek.pathfind.newSteeringManager()
        sm:setEntity("a", 1, 0)
        sm:setEntity("b", 2, 0)
        sm:clearEntities()
        expect_equal(0, sm:entityCount())
    end)
    -- @covers LSteeringManager:entityCount
    it("entityCount reports stored steering entities", function()
        local sm = lurek.pathfind.newSteeringManager()
        expect_equal(0, sm:entityCount())
        sm:setEntity("a", 1, 0)
        expect_equal(1, sm:entityCount())
    end)
    -- @covers LSteeringManager:getLastDiagnostic
    it("getLastDiagnostic records custom steering callback failures", function()
        local sm = lurek.pathfind.newSteeringManager()
        local _, agent = new_world_agent("steer_diagnostic")
        sm:addCustomBehavior(function()
            error("bad steer")
        end, 1.0)
        sm:applyCustomSteering(agent, 1 / 60)
        expect_true(type(sm:getLastDiagnostic()) == "string")
    end)
    -- @covers LSteeringManager:getBehaviorCount
    it("getBehaviorCount returns zero for a new manager", function()
        expect_equal(0, lurek.pathfind.newSteeringManager():getBehaviorCount())
    end)
    -- @covers LSteeringManager:setCombineMode
    it("setCombineMode updates the combine mode", function()
        local sm = lurek.pathfind.newSteeringManager()
        sm:setCombineMode("priority")
        expect_equal("priority", sm:getCombineMode())
    end)
    -- @covers LSteeringManager:getCombineMode
    it("getCombineMode returns a string", function()
        expect_type("string", lurek.pathfind.newSteeringManager():getCombineMode())
    end)
    -- @covers LSteeringManager:calculate
    it("calculate returns steering values", function()
        local sm = lurek.pathfind.newSteeringManager()
        sm:addSeek(100, 100)
        local fx, fy = sm:calculate(0, 0, 0, 0, 100, 200, 1 / 60)
        expect_type("number", fx)
        expect_type("number", fy)
    end)
    -- @covers LSteeringManager:getLastSteering
    it("getLastSteering returns the last steering pair", function()
        local sm = lurek.pathfind.newSteeringManager()
        sm:addSeek(100, 100)
        sm:calculate(0, 0, 0, 0, 100, 200, 1 / 60)
        local fx, fy = sm:getLastSteering()
        expect_type("number", fx)
        expect_type("number", fy)
    end)
    -- @covers LSteeringManager:setPath
    it("setPath accepts waypoint tables", function()
        local sm = lurek.pathfind.newSteeringManager()
        sm:setPath({ { x = 8, y = 8 }, { x = 16, y = 8 } })
        expect_true(sm:hasPath())
    end)
    -- @covers LSteeringManager:clearPath
    it("clearPath removes an active path", function()
        local sm = lurek.pathfind.newSteeringManager()
        sm:setPath({ { x = 8, y = 8 }, { x = 16, y = 8 } })
        sm:clearPath()
        expect_false(sm:hasPath())
    end)
    -- @covers LSteeringManager:hasPath
    it("hasPath is false by default", function()
        expect_false(lurek.pathfind.newSteeringManager():hasPath())
    end)
    -- @covers LSteeringManager:getPathProgress
    it("getPathProgress reports index and total", function()
        local sm = lurek.pathfind.newSteeringManager()
        sm:setPath({ { x = 8, y = 8 }, { x = 16, y = 8 } })
        local idx, total = sm:getPathProgress()
        expect_equal(1, idx)
        expect_equal(2, total)
    end)
    -- @covers LSteeringManager:type
    it("type returns LSteeringManager", function()
        expect_equal("LSteeringManager", lurek.pathfind.newSteeringManager():type())
    end)
    -- @covers LSteeringManager:typeOf
    it("typeOf reports steering manager inheritance", function()
        expect_true(lurek.pathfind.newSteeringManager():typeOf("LSteeringManager"))
    end)
    -- @covers LSteeringManager:setSpatialHashCellSize
    it("setSpatialHashCellSize accepts a custom cell size", function()
        local sm = lurek.pathfind.newSteeringManager()
        expect_no_error(function()
            sm:setSpatialHashCellSize(24.0)
        end)
    end)
    -- @covers LSteeringManager:enableSpatialHash
    it("enableSpatialHash toggles spatial hash acceleration", function()
        local sm = lurek.pathfind.newSteeringManager()
        expect_no_error(function()
            sm:enableSpatialHash(true)
            sm:enableSpatialHash(false)
        end)
    end)
    -- @covers LSteeringManager:addCustomBehavior
    it("addCustomBehavior accepts a Lua steering callback", function()
        local sm = lurek.pathfind.newSteeringManager()
        expect_no_error(function()
            sm:addCustomBehavior(function(_, _)
                return 1.0, -0.5
            end, 0.75)
        end)
    end)
    -- @covers LSteeringManager:applyCustomSteering
    it("applyCustomSteering combines custom behavior forces", function()
        local _, agent = new_world_agent("pusher")
        local sm = lurek.pathfind.newSteeringManager()
        sm:addCustomBehavior(function(_, _)
            return 25, -10
        end, 1.0)
        local fx, fy = sm:applyCustomSteering(agent, 1 / 60)
        expect_near(25, fx, 0.01)
        expect_near(-10, fy, 0.01)
    end)
    -- @covers LInfluenceMap:addLayer
    it("addLayer registers a named layer", function()
        local map = new_influence_map()
        map:addLayer("danger")
        expect_true(map:hasLayer("danger"))
    end)
    -- @covers LInfluenceMap:hasLayer
    it("hasLayer returns false before a layer is added", function()
        expect_false(new_influence_map():hasLayer("danger"))
    end)
    -- @covers LInfluenceMap:setInfluence
    it("setInfluence writes one cell value", function()
        local map = new_influence_map()
        map:addLayer("danger")
        map:setInfluence("danger", 2, 2, 0.75)
        expect_near(0.75, map:getInfluence("danger", 2, 2), 0.01)
    end)
    -- @covers LInfluenceMap:getInfluence
    it("getInfluence returns a number", function()
        local map = new_influence_map()
        map:addLayer("danger")
        expect_type("number", map:getInfluence("danger", 1, 1))
    end)
    -- @covers LInfluenceMap:clearLayer
    it("clearLayer resets values on one layer", function()
        local map = new_influence_map()
        map:addLayer("danger")
        map:setInfluence("danger", 2, 2, 0.75)
        map:clearLayer("danger")
        expect_near(0.0, map:getInfluence("danger", 2, 2), 0.01)
    end)
    -- @covers LInfluenceMap:clearAll
    it("clearAll removes every layer", function()
        local map = new_influence_map()
        map:addLayer("danger")
        map:setInfluence("danger", 2, 2, 0.75)
        map:clearAll()
        expect_near(0.0, map:getInfluence("danger", 2, 2), 0.01)
    end)
    -- @covers LInfluenceMap:getWidth
    it("getWidth returns configured width", function()
        expect_equal(4, new_influence_map():getWidth())
    end)
    -- @covers LInfluenceMap:getHeight
    it("getHeight returns configured height", function()
        expect_equal(3, new_influence_map():getHeight())
    end)
    -- @covers LInfluenceMap:getCellSize
    it("getCellSize returns configured cell size", function()
        expect_near(2, new_influence_map():getCellSize(), 0.01)
    end)
    -- @covers LInfluenceMap:type
    it("type returns LInfluenceMap", function()
        expect_equal("LInfluenceMap", new_influence_map():type())
    end)
    -- @covers LInfluenceMap:typeOf
    it("typeOf reports influence map inheritance", function()
        expect_true(new_influence_map():typeOf("LInfluenceMap"))
    end)
    -- @covers LInfluenceMap:stampInfluence
    it("stampInfluence writes radial influence into nearby cells", function()
        local map = lurek.pathfind.newInfluenceMap(20, 20, 1.0)
        map:addLayer("noise")
        map:stampInfluence("noise", 10.0, 10.0, 3.0, 1.0, 0.5)
        expect_true(map:getInfluence("noise", 10, 10) > 0.0)
    end)
    -- @covers LInfluenceMap:propagate
    it("propagate spreads influence to neighboring cells", function()
        local map = lurek.pathfind.newInfluenceMap(10, 10, 1.0)
        map:addLayer("scent")
        map:setInfluence("scent", 5, 5, 1.0)
        map:propagate("scent", 0.8)
        expect_true(map:getInfluence("scent", 4, 5) > 0.0)
    end)
    -- @covers LInfluenceMap:decay
    it("decay reduces stored influence values", function()
        local map = lurek.pathfind.newInfluenceMap(8, 8, 1.0)
        map:addLayer("heat")
        map:setInfluence("heat", 4, 4, 1.0)
        map:decay("heat", 0.5)
        expect_true(map:getInfluence("heat", 4, 4) < 1.0)
    end)
    -- @covers LInfluenceMap:getMaxPosition
    it("getMaxPosition returns the strongest cell coordinates", function()
        local map = lurek.pathfind.newInfluenceMap(10, 10, 1.0)
        map:addLayer("gold")
        map:setInfluence("gold", 7, 3, 0.9)
        map:setInfluence("gold", 2, 8, 0.4)
        local x, y = map:getMaxPosition("gold")
        expect_near(6.5, x, 0.01)
        expect_near(2.5, y, 0.01)
    end)
    -- @covers LInfluenceMap:getMinPosition
    it("getMinPosition returns the weakest cell coordinates", function()
        local map = lurek.pathfind.newInfluenceMap(10, 10, 1.0)
        map:addLayer("cold")
        map:setInfluence("cold", 1, 1, -0.5)
        map:setInfluence("cold", 5, 5, 0.3)
        local x, y = map:getMinPosition("cold")
        expect_near(0.5, x, 0.01)
        expect_near(0.5, y, 0.01)
    end)
    -- @covers LInfluenceMap:queryRect
    it("queryRect sums influence inside a rectangle", function()
        local map = lurek.pathfind.newInfluenceMap(10, 10, 1.0)
        map:addLayer("energy")
        map:setInfluence("energy", 2, 2, 0.5)
        map:setInfluence("energy", 3, 3, 0.5)
        expect_near(1.0, map:queryRect("energy", 1, 1, 4, 4), 0.01)
    end)
    -- @covers LInfluenceMap:blend
    it("blend writes a weighted combined layer", function()
        local map = lurek.pathfind.newInfluenceMap(8, 8, 1.0)
        map:addLayer("threat")
        map:addLayer("reward")
        map:addLayer("combined")
        map:setInfluence("threat", 4, 4, 1.0)
        map:setInfluence("reward", 4, 4, 0.8)
        map:blend("threat", 0.5, "reward", 0.5, "combined")
        expect_near(0.9, map:getInfluence("combined", 4, 4), 0.01)
    end)
    -- @covers LContextSteering:addSeekTarget
    it("addSeekTarget accepts a target attraction behavior", function()
        local cs = lurek.pathfind.newContextSteering(8)
        expect_no_error(function()
            cs:addSeekTarget(200, 150, 1.0)
        end)
    end)
    -- @covers LContextSteering:addWander
    it("addWander accepts a wander behavior", function()
        local cs = lurek.pathfind.newContextSteering(8)
        expect_no_error(function()
            cs:addWander(0.3, 0.5)
        end)
    end)
    -- @covers LContextSteering:addAvoidPoint
    it("addAvoidPoint accepts a point avoidance behavior", function()
        local cs = lurek.pathfind.newContextSteering(8)
        expect_no_error(function()
            cs:addAvoidPoint(50, 50, 20.0, 1.5)
        end)
    end)
    -- @covers LContextSteering:addAvoidBounds
    it("addAvoidBounds accepts rectangular avoidance bounds", function()
        local cs = lurek.pathfind.newContextSteering(8)
        expect_no_error(function()
            cs:addAvoidBounds(0, 0, 800, 600, 30.0, 1.0)
        end)
    end)
    -- @covers LContextSteering:clearBehaviors
    it("clearBehaviors removes configured steering behaviors", function()
        local cs = lurek.pathfind.newContextSteering(8)
        cs:addSeekTarget(100, 100, 1.0)
        cs:addAvoidPoint(50, 50, 10.0, 1.0)
        expect_no_error(function()
            cs:clearBehaviors()
        end)
    end)
    -- @covers LContextSteering:evaluate
    it("evaluate returns a chosen steering direction", function()
        local cs = lurek.pathfind.newContextSteering(8)
        cs:addSeekTarget(300, 200, 1.0)
        cs:addAvoidPoint(150, 150, 30.0, 2.0)
        local dx, dy = cs:evaluate(100, 100, 1.0, 0.0)
        expect_true(math.abs(dx) > 0 or math.abs(dy) > 0)
    end)
    -- @covers LContextSteering:chosenMagnitude
    it("chosenMagnitude reports the last selected slot strength", function()
        local cs = lurek.pathfind.newContextSteering(8)
        cs:addSeekTarget(200, 200, 1.0)
        cs:evaluate(0, 0, 0, 0)
        expect_true(cs:chosenMagnitude() > 0.0)
    end)
    -- @covers LContextSteering:slotCount
    it("slotCount returns the configured number of slots", function()
        expect_equal(16, lurek.pathfind.newContextSteering(16):slotCount())
    end)
    -- @covers LContextSteering:type
    it("type returns LContextSteering", function()
        expect_equal("LContextSteering", lurek.pathfind.newContextSteering(8):type())
    end)
    -- @covers LContextSteering:typeOf
    it("typeOf reports context steering inheritance", function()
        expect_true(lurek.pathfind.newContextSteering(8):typeOf("LContextSteering"))
    end)
    -- @covers LORCASolver:addAgent
    it("addAgent returns a zero-based solver index", function()
        local orca = lurek.pathfind.newORCASolver(2.0)
        expect_equal(0, orca:addAgent(10.0, 20.0, 0.5, 3.0))
    end)
    -- @covers LORCASolver:setPreferredVelocity
    it("setPreferredVelocity influences the computed safe velocity", function()
        local orca = lurek.pathfind.newORCASolver(2.0)
        orca:addAgent(0, 0, 0.5, 5.0)
        orca:setPreferredVelocity(0, 2.0, 1.0)
        orca:compute(0.016)
        local vx, vy = orca:getSafeVelocity(0)
        expect_near(2.0, vx, 0.01)
        expect_near(1.0, vy, 0.01)
    end)
    -- @covers LORCASolver:setPosition
    it("setPosition accepts a new agent position", function()
        local orca = lurek.pathfind.newORCASolver(2.0)
        orca:addAgent(0, 0, 0.5, 5.0)
        expect_no_error(function()
            orca:setPosition(0, 5.0, 3.0)
        end)
    end)
    -- @covers LORCASolver:compute
    it("compute updates safe velocities for the current agent set", function()
        local orca = lurek.pathfind.newORCASolver(1.5)
        orca:addAgent(0, 0, 0.5, 3.0)
        orca:addAgent(5, 0, 0.5, 3.0)
        orca:setPreferredVelocity(0, 1.0, 0.0)
        orca:setPreferredVelocity(1, -1.0, 0.0)
        expect_no_error(function()
            orca:compute(0.016)
        end)
    end)
    -- @covers LORCASolver:getSafeVelocity
    it("getSafeVelocity returns two numbers", function()
        local orca = lurek.pathfind.newORCASolver(1.5)
        orca:addAgent(0, 0, 0.5, 3.0)
        orca:setPreferredVelocity(0, 2.0, 0.0)
        orca:compute(0.016)
        local vx, vy = orca:getSafeVelocity(0)
        expect_type("number", vx)
        expect_type("number", vy)
    end)
    -- @covers LORCASolver:agentCount
    it("agentCount returns the number of registered agents", function()
        local orca = lurek.pathfind.newORCASolver(2.0)
        orca:addAgent(0, 0, 1.0, 2.0)
        orca:addAgent(5, 5, 1.0, 2.0)
        expect_equal(2, orca:agentCount())
    end)
    -- @covers LORCASolver:type
    it("type returns LORCASolver", function()
        expect_equal("LORCASolver", lurek.pathfind.newORCASolver(1.0):type())
    end)
    -- @covers LORCASolver:typeOf
    it("typeOf reports orca solver inheritance", function()
        expect_true(lurek.pathfind.newORCASolver(1.0):typeOf("LORCASolver"))
    end)
end)

end
-- END test_pathfind_core_unit.lua

test_summary()
