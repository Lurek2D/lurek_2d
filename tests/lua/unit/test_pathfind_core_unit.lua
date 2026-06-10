-- Canonical unit coverage for lurek.pathfind.

local function new_nav_grid(width, height)
    return lurek.pathfind.newNavGrid(width or 12, height or 12)
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
    it("newPathGrid creates userdata", function()
        expect_type("userdata", new_path_grid())
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
    it("setCost updates the cell traversal cost", function()
        local grid = new_nav_grid()
        grid:setCost(3, 3, 7)
        expect_equal(7, grid:getCost(3, 3))
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

    -- @covers LUnitPathfinder:lineOfSight
    it("lineOfSight returns true for an unobstructed segment", function()
        local _, pathfinder = new_pathfinder()
        expect_true(pathfinder:lineOfSight(1, 1, 5, 5))
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
    it("setWalkable flips walkability", function()
        local grid = new_path_grid()
        grid:setWalkable(2, 2, false)
        expect_false(grid:isWalkable(2, 2))
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

    -- @covers LHexGrid:lineOfSight
    it("lineOfSight returns true in open space", function()
        expect_true(new_hex_grid():lineOfSight(1, 1, 2, 2))
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

test_summary()
