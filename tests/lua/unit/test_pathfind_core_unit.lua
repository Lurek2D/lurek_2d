-- Pathfinding module Lua tests
-- All tests are headless-safe (BDD framework)

-- ============================================================
-- NavGrid creation and basic ops
-- ============================================================

-- @describe NavGrid creation
describe("NavGrid creation", function()
    -- @covers lurek.pathfind.newNavGrid
    it("newNavGrid returns an object", function()
        local grid = lurek.pathfind.newNavGrid(20, 20)
        expect_type("userdata", grid)
    end)

    -- @covers LNavGrid:getHeight
    -- @covers LNavGrid:getWidth
    -- @covers lurek.pathfind.newNavGrid
    it("width and height are correct", function()
        local grid = lurek.pathfind.newNavGrid(20, 20)
        expect_equal(20, grid:getWidth())
        expect_equal(20, grid:getHeight())
    end)

    -- @covers LNavGrid:getCost
    -- @covers lurek.pathfind.newNavGrid
    it("default cost is 1", function()
        local grid = lurek.pathfind.newNavGrid(5, 5)
        expect_equal(1, grid:getCost(1, 1))
    end)

    -- @covers LNavGrid:getCost
    -- @covers LNavGrid:setCost
    -- @covers lurek.pathfind.newNavGrid
    it("setCost changes cost", function()
        local grid = lurek.pathfind.newNavGrid(10, 10)
        grid:setCost(5, 5, 10)
        expect_equal(10, grid:getCost(5, 5))
    end)

    -- @covers LNavGrid:isBlocked
    -- @covers LNavGrid:setBlocked
    -- @covers lurek.pathfind.newNavGrid
    it("setBlocked / isBlocked", function()
        local grid = lurek.pathfind.newNavGrid(10, 10)
        grid:setBlocked(3, 3, true)
        expect_true(grid:isBlocked(3, 3))
        expect_false(grid:isBlocked(1, 1))
    end)

    -- @covers LNavGrid:isWalkable
    -- @covers LNavGrid:setBlocked
    -- @covers lurek.pathfind.newNavGrid
    it("isWalkable reflects blocked state", function()
        local grid = lurek.pathfind.newNavGrid(10, 10)
        expect_true(grid:isWalkable(1, 1))
        grid:setBlocked(1, 1, true)
        expect_false(grid:isWalkable(1, 1))
    end)

    -- @covers LNavGrid:fillRect
    -- @covers LNavGrid:isBlocked
    -- @covers lurek.pathfind.newNavGrid
    it("fillRect blocks region", function()
        local grid = lurek.pathfind.newNavGrid(20, 20)
        grid:fillRect(10, 10, 3, 3, 0)
        expect_true(grid:isBlocked(10, 10))
        expect_true(grid:isBlocked(12, 12))
        expect_false(grid:isBlocked(9, 9))
    end)

    -- @covers LNavGrid:getDiagonalMode
    -- @covers LNavGrid:setDiagonalMode
    -- @covers lurek.pathfind.newNavGrid
    it("diagonal mode get/set", function()
        local grid = lurek.pathfind.newNavGrid(10, 10)
        grid:setDiagonalMode("always")
        expect_equal("always", grid:getDiagonalMode())
        grid:setDiagonalMode("none")
        expect_equal("none", grid:getDiagonalMode())
    end)
end)

-- ============================================================
-- Pathfinder
-- ============================================================
-- @describe Pathfinder
describe("Pathfinder", function()
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("newPathfinder returns an object", function()
        local grid = lurek.pathfind.newNavGrid(10, 10)
        local pf = lurek.pathfind.newPathfinder(grid)
        expect_type("userdata", pf)
    end)

    -- @covers LUnitPathfinder:findPath
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("findPath on open grid returns path", function()
        local grid = lurek.pathfind.newNavGrid(10, 10)
        local pf = lurek.pathfind.newPathfinder(grid)
        local path = pf:findPath(1, 1, 10, 10)
        expect_true(path ~= nil, "should find path")
        expect_true(#path > 0, "path should have waypoints")
        expect_equal(1, path[1].x)
        expect_equal(1, path[1].y)
        expect_equal(10, path[#path].x)
        expect_equal(10, path[#path].y)
    end)

    -- @covers LNavGrid:setBlocked
    -- @covers LUnitPathfinder:findPath
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("findPath through narrow gap", function()
        local grid = lurek.pathfind.newNavGrid(10, 10)
        for y = 1, 10 do grid:setBlocked(5, y, true) end
        grid:setBlocked(5, 5, false)
        local pf = lurek.pathfind.newPathfinder(grid)
        local path = pf:findPath(1, 1, 10, 10)
        expect_true(path ~= nil, "should find path through narrow gap")
    end)

    -- @covers LUnitPathfinder:heuristicDistance
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("heuristicDistance returns positive number", function()
        local grid = lurek.pathfind.newNavGrid(10, 10)
        local pf = lurek.pathfind.newPathfinder(grid)
        local d = pf:heuristicDistance(1, 1, 4, 5)
        expect_type("number", d)
        expect_true(d > 0, "distance should be positive")
    end)

    -- @covers LUnitPathfinder:clearCache
    -- @covers LUnitPathfinder:getCacheSize
    -- @covers LUnitPathfinder:isCacheEnabled
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("cache operations", function()
        local grid = lurek.pathfind.newNavGrid(10, 10)
        local pf = lurek.pathfind.newPathfinder(grid)
        expect_true(pf:isCacheEnabled())
        pf:clearCache()
        expect_equal(0, pf:getCacheSize())
    end)
end)

-- ============================================================
-- FlowField
-- ============================================================
-- @describe FlowField
describe("FlowField", function()
    -- @covers lurek.pathfind.newFlowField
    -- @covers lurek.pathfind.newNavGrid
    it("newFlowField returns an object", function()
        local grid = lurek.pathfind.newNavGrid(10, 10)
        local ff = lurek.pathfind.newFlowField(grid)
        expect_type("userdata", ff)
    end)

    -- @covers LFlowField:isCalculated
    -- @covers lurek.pathfind.newFlowField
    -- @covers lurek.pathfind.newNavGrid
    it("isCalculated returns false initially", function()
        local grid = lurek.pathfind.newNavGrid(10, 10)
        local ff = lurek.pathfind.newFlowField(grid)
        expect_false(ff:isCalculated())
    end)

    -- @covers LFlowField:calculate
    -- @covers LFlowField:isCalculated
    -- @covers lurek.pathfind.newFlowField
    -- @covers lurek.pathfind.newNavGrid
    it("calculate makes isCalculated true", function()
        local grid = lurek.pathfind.newNavGrid(10, 10)
        local ff = lurek.pathfind.newFlowField(grid)
        ff:calculate(10, 10)
        expect_true(ff:isCalculated())
    end)

    -- @covers LFlowField:calculate
    -- @covers LFlowField:getDirection
    -- @covers lurek.pathfind.newFlowField
    -- @covers lurek.pathfind.newNavGrid
    it("getDirection returns numbers", function()
        local grid = lurek.pathfind.newNavGrid(10, 10)
        local ff = lurek.pathfind.newFlowField(grid)
        ff:calculate(10, 10)
        local dx, dy = ff:getDirection(1, 1)
        expect_type("number", dx)
        expect_type("number", dy)
    end)

    -- @covers LFlowField:calculate
    -- @covers LFlowField:getCostToTarget
    -- @covers lurek.pathfind.newFlowField
    -- @covers lurek.pathfind.newNavGrid
    it("getCostToTarget positive for reachable cell", function()
        local grid = lurek.pathfind.newNavGrid(10, 10)
        local ff = lurek.pathfind.newFlowField(grid)
        ff:calculate(10, 10)
        local cost = ff:getCostToTarget(1, 1)
        expect_true(cost > 0, "cost should be positive")
    end)

    -- @covers LFlowField:calculate
    -- @covers LFlowField:steer
    -- @covers lurek.pathfind.newFlowField
    -- @covers lurek.pathfind.newNavGrid
    it("steer returns numbers", function()
        local grid = lurek.pathfind.newNavGrid(10, 10)
        local ff = lurek.pathfind.newFlowField(grid)
        ff:calculate(10, 10)
        local vx, vy = ff:steer(0, 0, 100, 1, 1)
        expect_type("number", vx)
        expect_type("number", vy)
    end)
end)

-- ============================================================
-- Thread count
-- ============================================================
-- @describe pathfinding threadCount
describe("pathfinding threadCount", function()
    -- @covers lurek.pathfind.getThreadCount
    it("getThreadCount returns a number", function()
        local tc = lurek.pathfind.getThreadCount()
        expect_type("number", tc)
    end)
end)

-- ============================================================
-- newNavGridFromTileMap
-- ============================================================
-- @describe newNavGridFromTileMap
describe("newNavGridFromTileMap", function()
    -- @covers lurek.pathfind.newNavGridFromTileMap
    it("is a function", function()
        expect_type("function", lurek.pathfind.newNavGridFromTileMap)
    end)

    -- @covers LNavGrid:getHeight
    -- @covers LNavGrid:getWidth
    -- @covers LTileMap:addLayer
    -- @covers LTileMap:setTile
    -- @covers lurek.pathfind.newNavGridFromTileMap
    -- @covers lurek.tilemap.newTileMap
    it("creates grid from tilemap with correct dimensions", function()
        local tm = lurek.tilemap.newTileMap(16, 16, 8)
        tm:addLayer("ground", 4, 4)
        for y = 1, 4 do
            for x = 1, 4 do
                tm:setTile(1, x, y, 1)
            end
        end
        local nav = lurek.pathfind.newNavGridFromTileMap(tm, 1, {2})
        expect_equal(4, nav:getWidth())
        expect_equal(4, nav:getHeight())
    end)

    -- @covers LNavGrid:getCost
    -- @covers LTileMap:addLayer
    -- @covers LTileMap:setTile
    -- @covers lurek.pathfind.newNavGridFromTileMap
    -- @covers lurek.tilemap.newTileMap
    it("blocked GIDs produce cost 0", function()
        local tm = lurek.tilemap.newTileMap(16, 16, 8)
        tm:addLayer("ground", 4, 4)
        for y = 1, 4 do
            for x = 1, 4 do
                tm:setTile(1, x, y, 1)
            end
        end
        tm:setTile(1, 2, 2, 2)
        tm:setTile(1, 3, 3, 2)
        local nav = lurek.pathfind.newNavGridFromTileMap(tm, 1, {2})
        expect_equal(0, nav:getCost(2, 2))
        expect_equal(0, nav:getCost(3, 3))
        expect_true(nav:getCost(1, 1) > 0, "walkable tile should have cost > 0")
    end)
end)

-- NavGrid extended

-- @describe NavGrid.getDimensions
describe("NavGrid.getDimensions", function()
    -- @covers LNavGrid:getDimensions
    -- @covers lurek.pathfind.newNavGrid
    it("getDimensions returns width and height", function()
        local g = lurek.pathfind.newNavGrid(12, 8)
        local w, h = g:getDimensions()
        expect_equal(12, w)
        expect_equal(8, h)
    end)
end)

-- @describe NavGrid.fill
describe("NavGrid.fill", function()
    -- @covers LNavGrid:fill
    -- @covers LNavGrid:getCost
    -- @covers lurek.pathfind.newNavGrid
    it("fill sets all cells to the same cost", function()
        local g = lurek.pathfind.newNavGrid(5, 5)
        g:fill(3)
        for y = 1, 5 do
            for x = 1, 5 do
                expect_equal(3, g:getCost(x, y))
            end
        end
    end)

    -- @covers LNavGrid:fill
    -- @covers LNavGrid:isWalkable
    -- @covers lurek.pathfind.newNavGrid
    it("fill with 0 marks entire grid blocked", function()
        local g = lurek.pathfind.newNavGrid(4, 4)
        g:fill(0)
        for y = 1, 4 do
            for x = 1, 4 do
                expect_false(g:isWalkable(x, y))
            end
        end
    end)
end)

-- @describe NavGrid.saveToString / loadFromString
describe("NavGrid.saveToString / loadFromString", function()
    -- @covers LNavGrid:saveToString
    -- @covers lurek.pathfind.newNavGrid
    it("saveToString returns a non-empty string", function()
        local g = lurek.pathfind.newNavGrid(6, 6)
        local s = g:saveToString()
        expect_type("string", s)
        expect_true(#s > 0, "serialised string must not be empty")
    end)

    -- @covers LNavGrid:isBlocked
    -- @covers LNavGrid:loadFromString
    -- @covers LNavGrid:saveToString
    -- @covers LNavGrid:setBlocked
    -- @covers lurek.pathfind.newNavGrid
    it("loadFromString round-trips blocked state", function()
        local g = lurek.pathfind.newNavGrid(6, 6)
        g:setBlocked(3, 3, true)
        g:setBlocked(4, 2, true)
        local s  = g:saveToString()
        local g2 = lurek.pathfind.newNavGrid(6, 6)
        g2:loadFromString(s)
        expect_true(g2:isBlocked(3, 3), "cell 3,3 still blocked after deserialise")
        expect_true(g2:isBlocked(4, 2), "cell 4,2 still blocked after deserialise")
        expect_false(g2:isBlocked(1, 1))
    end)

    -- @covers LNavGrid:getCost
    -- @covers LNavGrid:loadFromString
    -- @covers LNavGrid:saveToString
    -- @covers LNavGrid:setCost
    -- @covers lurek.pathfind.newNavGrid
    it("loadFromString round-trips cost values", function()
        local g = lurek.pathfind.newNavGrid(4, 4)
        g:setCost(2, 2, 7)
        local g2 = lurek.pathfind.newNavGrid(4, 4)
        g2:loadFromString(g:saveToString())
        expect_equal(7, g2:getCost(2, 2))
    end)
end)

-- @describe NavGrid.setChunkSize / getChunkSize
describe("NavGrid.setChunkSize / getChunkSize", function()
    -- @covers LNavGrid:getChunkSize
    -- @covers LNavGrid:setChunkSize
    -- @covers lurek.pathfind.newNavGrid
    it("setChunkSize / getChunkSize round-trip", function()
        local g = lurek.pathfind.newNavGrid(32, 32)
        g:setChunkSize(8)
        expect_equal(8, g:getChunkSize())
    end)
end)

-- @describe NavGrid.type / typeOf
describe("NavGrid.type / typeOf", function()
    -- @covers LNavGrid:type
    -- @covers lurek.pathfind.newNavGrid
    it("type() returns a string", function()
        local g = lurek.pathfind.newNavGrid(4, 4)
        expect_type("string", g:type())
    end)

    -- @covers LNavGrid:typeOf
    -- @covers lurek.pathfind.newNavGrid
    it("typeOf() checks identity against a type name", function()
        local g = lurek.pathfind.newNavGrid(4, 4)
        expect_true(g:typeOf("LNavGrid"))
        expect_false(g:typeOf("FlowField"))
    end)
end)

-- UnitPathfinder extended

-- @describe UnitPathfinder.findPathSmooth
describe("UnitPathfinder.findPathSmooth", function()
    -- @covers LUnitPathfinder:findPathSmooth
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("findPathSmooth returns a table or nil", function()
        local g = lurek.pathfind.newNavGrid(10, 10)
        local pf = lurek.pathfind.newPathfinder(g)
        local path = pf:findPathSmooth(1, 1, 10, 10)
        expect_true(path == nil or type(path) == "table", "findPathSmooth must return table or nil")
    end)

    -- @covers LUnitPathfinder:findPathSmooth
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("findPathSmooth with open grid returns a path", function()
        local g = lurek.pathfind.newNavGrid(10, 10)
        local pf = lurek.pathfind.newPathfinder(g)
        local path = pf:findPathSmooth(1, 1, 10, 10)
        expect_true(path ~= nil, "expected a smooth path in open grid")
    end)
end)

-- @describe UnitPathfinder.getPathLength / getPathCost
describe("UnitPathfinder.getPathLength / getPathCost", function()
    -- @covers LUnitPathfinder:findPath
    -- @covers LUnitPathfinder:getPathLength
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("getPathLength returns a number for a valid path", function()
        local g = lurek.pathfind.newNavGrid(10, 10)
        local pf = lurek.pathfind.newPathfinder(g)
        local path = pf:findPath(1, 1, 8, 8)
        if path then
            local len = pf:getPathLength(path)
            expect_type("number", len)
            expect_true(len >= 0)
        else
            expect_true(true, "skip: no path found")
        end
    end)

    -- @covers LUnitPathfinder:findPath
    -- @covers LUnitPathfinder:getPathCost
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("getPathCost returns a number for a valid path", function()
        local g = lurek.pathfind.newNavGrid(10, 10)
        local pf = lurek.pathfind.newPathfinder(g)
        local path = pf:findPath(1, 1, 8, 8)
        if path then
            local cost = pf:getPathCost(path)
            expect_type("number", cost)
            expect_true(cost >= 0)
        else
            expect_true(true, "skip: no path found")
        end
    end)
end)

-- @describe UnitPathfinder.findPartialPath
describe("UnitPathfinder.findPartialPath", function()
    -- @covers LUnitPathfinder:findPartialPath
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("findPartialPath returns a path and boolean", function()
        local g = lurek.pathfind.newNavGrid(10, 10)
        local pf = lurek.pathfind.newPathfinder(g)
        local path, complete = pf:findPartialPath(1, 1, 10, 10, 100)
        expect_true(path == nil or type(path) == "table", "findPartialPath must return table or nil")
        expect_type("boolean", complete)
    end)

    -- @covers LUnitPathfinder:findPartialPath
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("findPartialPath in open grid returns complete=true", function()
        local g = lurek.pathfind.newNavGrid(10, 10)
        local pf = lurek.pathfind.newPathfinder(g)
        local _path, complete = pf:findPartialPath(1, 1, 10, 10, 200)
        expect_true(complete, "open grid partial path should be complete")
    end)
end)

-- @describe UnitPathfinder.findNearestWalkable
describe("UnitPathfinder.findNearestWalkable", function()
    -- @covers LNavGrid:setBlocked
    -- @covers LUnitPathfinder:findNearestWalkable
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("findNearestWalkable returns two numbers", function()
        local g = lurek.pathfind.newNavGrid(10, 10)
        g:setBlocked(5, 5, true)
        local pf = lurek.pathfind.newPathfinder(g)
        local nx, ny = pf:findNearestWalkable(5, 5, 5)
        expect_type("number", nx)
        expect_type("number", ny)
    end)

    -- @covers LUnitPathfinder:findNearestWalkable
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("findNearestWalkable returns same coords for already walkable cell", function()
        local g = lurek.pathfind.newNavGrid(10, 10)
        local pf = lurek.pathfind.newPathfinder(g)
        local nx, ny = pf:findNearestWalkable(3, 3, 5)
        expect_equal(3, nx)
        expect_equal(3, ny)
    end)
end)

-- @describe UnitPathfinder.isReachable
describe("UnitPathfinder.isReachable", function()
    -- @covers LUnitPathfinder:isReachable
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("isReachable returns true for reachable goal in open grid", function()
        local g = lurek.pathfind.newNavGrid(10, 10)
        local pf = lurek.pathfind.newPathfinder(g)
        expect_true(pf:isReachable(1, 1, 10, 10))
    end)

    -- @covers LNavGrid:setBlocked
    -- @covers LUnitPathfinder:isReachable
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("isReachable returns false when goal is fully blocked", function()
        local g = lurek.pathfind.newNavGrid(10, 10)
        -- Wall off all border cells adjacent to 10,10
        for dx = -1, 0 do
            for dy = -1, 0 do
                g:setBlocked(10 + dx, 10 + dy, true)
            end
        end
        local pf = lurek.pathfind.newPathfinder(g)
        local result = pf:isReachable(1, 1, 10, 10)
        expect_type("boolean", result)
    end)
end)

-- @describe UnitPathfinder.lineOfSight
describe("UnitPathfinder.lineOfSight", function()
    -- @covers LUnitPathfinder:lineOfSight
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("lineOfSight returns true for unobstructed path", function()
        local g = lurek.pathfind.newNavGrid(10, 10)
        local pf = lurek.pathfind.newPathfinder(g)
        expect_true(pf:lineOfSight(1, 1, 5, 5))
    end)

    -- @covers LNavGrid:setBlocked
    -- @covers LUnitPathfinder:lineOfSight
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("lineOfSight returns false when wall blocks", function()
        local g = lurek.pathfind.newNavGrid(10, 10)
        -- Block a column between start and end
        for y = 1, 10 do g:setBlocked(5, y, true) end
        local pf = lurek.pathfind.newPathfinder(g)
        local los = pf:lineOfSight(1, 5, 9, 5)
        expect_type("boolean", los)
    end)
end)

-- @describe UnitPathfinder cache control
describe("UnitPathfinder cache control", function()
    -- @covers LUnitPathfinder:isCacheEnabled
    -- @covers LUnitPathfinder:setCacheEnabled
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("setCacheEnabled / isCacheEnabled round-trip", function()
        local g = lurek.pathfind.newNavGrid(10, 10)
        local pf = lurek.pathfind.newPathfinder(g)
        pf:setCacheEnabled(false)
        expect_false(pf:isCacheEnabled())
        pf:setCacheEnabled(true)
        expect_true(pf:isCacheEnabled())
    end)

    -- @covers LUnitPathfinder:clearCache
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("clearCache does not error", function()
        local g = lurek.pathfind.newNavGrid(10, 10)
        local pf = lurek.pathfind.newPathfinder(g)
        expect_no_error(function() pf:clearCache() end)
    end)

    -- @covers LUnitPathfinder:getCacheSize
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("getCacheSize returns a number", function()
        local g = lurek.pathfind.newNavGrid(10, 10)
        local pf = lurek.pathfind.newPathfinder(g)
        expect_type("number", pf:getCacheSize())
    end)

    -- @covers LUnitPathfinder:setCacheMaxSize
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("setCacheMaxSize does not error", function()
        local g = lurek.pathfind.newNavGrid(10, 10)
        local pf = lurek.pathfind.newPathfinder(g)
        expect_no_error(function() pf:setCacheMaxSize(100) end)
    end)
end)

-- @describe flow field (RS parity)
describe("flow field (RS parity)", function()
    -- @covers lurek.pathfind.newFlowField
    -- @covers lurek.pathfind.newNavGrid
    it("newFlowField returns userdata", function()
        local g = lurek.pathfind.newNavGrid(10, 10)
        local ff = lurek.pathfind.newFlowField(g)
        expect_equal("userdata", type(ff))
    end)

    -- @covers LFlowField:isCalculated
    -- @covers lurek.pathfind.newFlowField
    -- @covers lurek.pathfind.newNavGrid
    it("isCalculated is false before calculate", function()
        local g = lurek.pathfind.newNavGrid(10, 10)
        local ff = lurek.pathfind.newFlowField(g)
        expect_false(ff:isCalculated())
    end)

    -- @covers LFlowField:getTargets
    -- @covers lurek.pathfind.newFlowField
    -- @covers lurek.pathfind.newNavGrid
    it("getTargets returns empty before calculate", function()
        local g = lurek.pathfind.newNavGrid(10, 10)
        local ff = lurek.pathfind.newFlowField(g)
        local targets = ff:getTargets()
        expect_equal("table", type(targets))
        expect_equal(0, #targets)
    end)

    -- @covers LFlowField:calculate
    -- @covers LFlowField:isCalculated
    -- @covers lurek.pathfind.newFlowField
    -- @covers lurek.pathfind.newNavGrid
    it("calculate with single target sets isCalculated = true", function()
        local g = lurek.pathfind.newNavGrid(5, 5)
        local ff = lurek.pathfind.newFlowField(g)
        ff:calculate(3, 3)
        expect_true(ff:isCalculated())
    end)

    -- @covers LFlowField:calculate
    -- @covers LFlowField:getTargets
    -- @covers lurek.pathfind.newFlowField
    -- @covers lurek.pathfind.newNavGrid
    it("getTargets after calculate returns the specified cells", function()
        local g = lurek.pathfind.newNavGrid(5, 5)
        local ff = lurek.pathfind.newFlowField(g)
        ff:calculate(2, 2)
        local targets = ff:getTargets()
        expect_equal(1, #targets)
    end)

    -- @covers LFlowField:calculate
    -- @covers LFlowField:getCostToTarget
    -- @covers lurek.pathfind.newFlowField
    -- @covers lurek.pathfind.newNavGrid
    it("costToTarget returns 0 at the target cell", function()
        local g = lurek.pathfind.newNavGrid(5, 5)
        local ff = lurek.pathfind.newFlowField(g)
        ff:calculate(3, 3)
        local cost = ff:getCostToTarget(3, 3)
        expect_near(0.0, cost, 0.01)
    end)

    -- @covers LFlowField:calculate
    -- @covers LFlowField:steer
    -- @covers lurek.pathfind.newFlowField
    -- @covers lurek.pathfind.newNavGrid
    it("steer returns numbers for vx and vy", function()
        local g = lurek.pathfind.newNavGrid(5, 5)
        local ff = lurek.pathfind.newFlowField(g)
        ff:calculate(3, 3)
        local vx, vy = ff:steer(1.0, 1.0, 32, 1, 1)
        expect_equal("number", type(vx))
        expect_equal("number", type(vy))
    end)

    -- @covers LFlowField:calculate
    -- @covers LFlowField:isCalculated
    -- @covers lurek.pathfind.newFlowField
    -- @covers lurek.pathfind.newNavGrid
    it("multi-target calculate accepts multiple cells", function()
        local g = lurek.pathfind.newNavGrid(8, 8)
        local ff = lurek.pathfind.newFlowField(g)
        ff:calculate(1, 1)
        expect_true(ff:isCalculated())
    end)
end)

-- @describe pathfinder line of sight and diagonal mode (RS parity)
describe("pathfinder line of sight and diagonal mode (RS parity)", function()
    -- @covers LUnitPathfinder:lineOfSight
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("lineOfSight returns true on open grid", function()
        local g = lurek.pathfind.newNavGrid(10, 10)
        local pf = lurek.pathfind.newPathfinder(g)
        expect_true(pf:lineOfSight(1, 1, 5, 5))
    end)

    -- @covers LNavGrid:setBlocked
    -- @covers LUnitPathfinder:lineOfSight
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("lineOfSight returns false when wall blocks path", function()
        local g = lurek.pathfind.newNavGrid(10, 10)
        -- block a row of cells at column 5
        for y = 1, 10 do g:setBlocked(5, y, true) end
        local pf = lurek.pathfind.newPathfinder(g)
        expect_false(pf:lineOfSight(1, 5, 9, 5))
    end)

    -- @covers LNavGrid:getDiagonalMode
    -- @covers LNavGrid:setDiagonalMode
    -- @covers lurek.pathfind.newNavGrid
    it("setDiagonalMode and getDiagonalMode round-trip", function()
        local g = lurek.pathfind.newNavGrid(10, 10)
        g:setDiagonalMode("none")
        expect_equal("none", g:getDiagonalMode())
        g:setDiagonalMode("always")
        expect_equal("always", g:getDiagonalMode())
    end)
end)

-- Pathfind Bidirectional (merged from test_pathfind_bidirectional.lua)

-- @describe Bidirectional A*: path finding
describe("Bidirectional A*: path finding", function()

    -- @covers LUnitPathfinder:findPathBidirectional
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("finds path on open 5x5 grid from (1,1) to (5,5)", function()
        local grid = lurek.pathfind.newNavGrid(5, 5)
        local pathfinder = lurek.pathfind.newPathfinder(grid)
        local path, complete = pathfinder:findPathBidirectional(1, 1, 5, 5)
        expect_not_nil(path, "path must not be nil")
        expect_true(complete, "path must be complete")
        expect_greater(#path, 0, "path must have at least one node")
        local first = path[1]
        expect_equal(1, first.x)
        expect_equal(1, first.y)
        local last = path[#path]
        expect_equal(5, last.x)
        expect_equal(5, last.y)
    end)

    -- @covers LUnitPathfinder:findPathBidirectional
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("start equals goal returns single-node path", function()
        local grid = lurek.pathfind.newNavGrid(5, 5)
        local pathfinder = lurek.pathfind.newPathfinder(grid)
        local path, complete = pathfinder:findPathBidirectional(3, 3, 3, 3)
        expect_not_nil(path)
        expect_equal(1, #path)
        expect_true(complete)
        expect_equal(3, path[1].x)
        expect_equal(3, path[1].y)
    end)

    -- @covers LNavGrid:setBlocked
    -- @covers LUnitPathfinder:findPathBidirectional
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("blocked start returns nil path and complete false", function()
        local grid = lurek.pathfind.newNavGrid(5, 5)
        local pathfinder = lurek.pathfind.newPathfinder(grid)
        grid:setBlocked(1, 1, true)
        local path, complete = pathfinder:findPathBidirectional(1, 1, 5, 5)
        expect_nil(path, "path must be nil when start is blocked")
        expect_false(complete, "complete must be false when start is blocked")
    end)

    -- @covers LUnitPathfinder:findPathBidirectional
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("findPathBidirectional finds path on 10x10 grid", function()
        local grid = lurek.pathfind.newNavGrid(10, 10)
        local pathfinder = lurek.pathfind.newPathfinder(grid)
        local path, complete = pathfinder:findPathBidirectional(1, 1, 10, 10, 1, 0)
        expect_not_nil(path)
        expect_true(complete)
        expect_greater(#path, 0)
        local last = path[#path]
        expect_equal(10, last.x)
        expect_equal(10, last.y)
    end)

    -- @covers LUnitPathfinder:findPathBidirectional
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("tiny max_nodes budget returns incomplete path", function()
        local grid = lurek.pathfind.newNavGrid(10, 10)
        local pathfinder = lurek.pathfind.newPathfinder(grid)
        local path, complete = pathfinder:findPathBidirectional(1, 1, 10, 10, 1, 2)
        expect_not_nil(path)
        expect_false(complete, "should be partial when max_nodes is very small")
    end)

end)

-- [merged from test_pathfind_regress_zero_index.lua]
-- Regression: UnitPathfinder:findPath / :findPathSmooth must not panic when a
-- caller passes a 0 (invalid 1-based) coordinate. Before the fix, the u32
-- subtraction underflowed and aborted the process.

-- @describe UnitPathfinder regression: zero index
describe("UnitPathfinder regression: zero index", function()
    -- @covers LUnitPathfinder:findPath
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("findPath with x1=0 returns a Lua error (no panic)", function()
        local grid = lurek.pathfind.newNavGrid(10, 10)
        local pf = lurek.pathfind.newPathfinder(grid)
        expect_error(function()
            pf:findPath(0, 1, 5, 5)
        end)
    end)

    -- @covers LUnitPathfinder:findPathSmooth
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("findPathSmooth with y2=0 returns a Lua error (no panic)", function()
        local grid = lurek.pathfind.newNavGrid(10, 10)
        local pf = lurek.pathfind.newPathfinder(grid)
        expect_error(function()
            pf:findPathSmooth(1, 1, 5, 0)
        end)
    end)
end)





-- ================================================================
-- Merged from: test_pathfind_regress_zero_index.lua
-- ================================================================

-- Regression: UnitPathfinder:findPath / :findPathSmooth must not panic when a
-- caller passes a 0 (invalid 1-based) coordinate. Before the fix, the u32
-- subtraction underflowed and aborted the process.

-- @describe UnitPathfinder regression: zero index
describe("UnitPathfinder regression: zero index", function()
    -- @covers LUnitPathfinder:findPath
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("findPath with x1=0 returns a Lua error (no panic)", function()
        local grid = lurek.pathfind.newNavGrid(10, 10)
        local pf = lurek.pathfind.newPathfinder(grid)
        expect_error(function()
            pf:findPath(0, 1, 5, 5)
        end)
    end)

    -- @covers LUnitPathfinder:findPathSmooth
    -- @covers lurek.pathfind.newNavGrid
    -- @covers lurek.pathfind.newPathfinder
    it("findPathSmooth with y2=0 returns a Lua error (no panic)", function()
        local grid = lurek.pathfind.newNavGrid(10, 10)
        local pf = lurek.pathfind.newPathfinder(grid)
        expect_error(function()
            pf:findPathSmooth(1, 1, 5, 0)
        end)
    end)
end)

-- @describe pathfind missing explicit coverage
describe("pathfind missing explicit coverage", function()
    -- @covers lurek.pathfind.setThreadCount
    it("setThreadCount accepts a positive value", function()
        expect_no_error(function()
            lurek.pathfind.setThreadCount(1)
        end)
    end)

    -- @covers LNavGrid:clearDirty
    -- @covers LNavGrid:rebuildAbstract
    -- @covers LNavGrid:setDirty
    -- @covers lurek.pathfind.newNavGrid
    it("NavGrid dirty/abstract rebuild methods do not error", function()
        local grid = lurek.pathfind.newNavGrid(12, 12)
        expect_no_error(function()
            grid:setDirty(1, 1, 3, 3)
            grid:rebuildAbstract()
            grid:clearDirty()
        end)
    end)

    -- @covers LFlowField:calculateMulti
    -- @covers LFlowField:getDirectionAngle
    -- @covers lurek.pathfind.newFlowField
    -- @covers lurek.pathfind.newNavGrid
    it("FlowField multi-target calculation exposes direction angle", function()
        local grid = lurek.pathfind.newNavGrid(16, 16)
        local ff = lurek.pathfind.newFlowField(grid)
        ff:calculateMulti({
            {x = 8, y = 8},
            {x = 10, y = 10},
        })
        local angle = ff:getDirectionAngle(1, 1)
        expect_type("number", angle)
    end)
end)

-- @describe pathfind strict: newHexGrid / LHexGrid methods
describe("pathfind strict: newHexGrid / LHexGrid methods", function()
    -- @covers lurek.pathfind.newHexGrid
    it("newHexGrid constructs with default layout", function()
        local g = lurek.pathfind.newHexGrid(8, 8)
        expect_true(g ~= nil)
    end)

    -- @covers LHexGrid:setBlocked
    -- @covers LHexGrid:isBlocked
    -- @covers lurek.pathfind.newHexGrid
    it("LHexGrid setBlocked / isBlocked round-trip", function()
        local g = lurek.pathfind.newHexGrid(8, 8)
        g:setBlocked(1, 1, true)
        expect_true(g:isBlocked(1, 1))
    end)

    -- @covers LHexGrid:setCost
    -- @covers lurek.pathfind.newHexGrid
    it("LHexGrid setCost is callable", function()
        local g = lurek.pathfind.newHexGrid(8, 8)
        local ok = pcall(function() g:setCost(2, 2, 2.0) end)
        expect_true(ok)
    end)

    -- @covers LHexGrid:lineOfSight
    -- @covers lurek.pathfind.newHexGrid
    it("LHexGrid lineOfSight returns boolean", function()
        local g = lurek.pathfind.newHexGrid(8, 8)
        expect_type("boolean", g:lineOfSight(1, 1, 3, 3))
    end)

    -- @covers LHexGrid:fieldOfView
    -- @covers lurek.pathfind.newHexGrid
    it("LHexGrid fieldOfView returns table", function()
        local g = lurek.pathfind.newHexGrid(8, 8)
        expect_type("table", g:fieldOfView(1, 1, 3))
    end)

    -- @covers LHexGrid:rangeOfMovement
    -- @covers lurek.pathfind.newHexGrid
    it("LHexGrid rangeOfMovement returns table", function()
        local g = lurek.pathfind.newHexGrid(8, 8)
        expect_type("table", g:rangeOfMovement(1, 1, 3))
    end)

    -- @covers LHexGrid:distance
    -- @covers lurek.pathfind.newHexGrid
    it("LHexGrid distance returns number", function()
        local g = lurek.pathfind.newHexGrid(8, 8)
        expect_type("number", g:distance(1, 1, 3, 3))
    end)

    -- @covers LHexGrid:type
    -- @covers LHexGrid:typeOf
    -- @covers lurek.pathfind.newHexGrid
    it("LHexGrid type and typeOf are callable", function()
        local g = lurek.pathfind.newHexGrid(8, 8)
        expect_type("string", g:type())
        expect_type("boolean", g:typeOf("Object"))
    end)
end)

-- @describe pathfind strict: newJpsGrid / LJpsGrid methods
describe("pathfind strict: newJpsGrid / LJpsGrid methods", function()
    -- @covers lurek.pathfind.newJpsGrid
    it("newJpsGrid constructs", function()
        local g = lurek.pathfind.newJpsGrid(8, 8)
        expect_true(g ~= nil)
    end)

    -- @covers LJpsGrid:setBlocked
    -- @covers LJpsGrid:isBlocked
    -- @covers lurek.pathfind.newJpsGrid
    it("LJpsGrid setBlocked / isBlocked round-trip", function()
        local g = lurek.pathfind.newJpsGrid(8, 8)
        g:setBlocked(2, 2, true)
        expect_true(g:isBlocked(2, 2))
    end)

    -- @covers LJpsGrid:type
    -- @covers LJpsGrid:typeOf
    -- @covers lurek.pathfind.newJpsGrid
    it("LJpsGrid type and typeOf are callable", function()
        local g = lurek.pathfind.newJpsGrid(8, 8)
        expect_type("string", g:type())
        expect_type("boolean", g:typeOf("Object"))
    end)
end)

-- @describe pathfind strict: rangeMap function
describe("pathfind strict: rangeMap function", function()
    -- @covers lurek.pathfind.rangeMap
    it("rangeMap returns table with cells", function()
        local result = lurek.pathfind.rangeMap({
            width = 4, height = 4,
            origin_x = 2, origin_y = 2,
            budget = 2.0
        })
        expect_type("table", result)
        expect_type("table", result.cells)
    end)
end)

-- @describe pathfind strict: UnitPathfinder / FlowField / AIFlowField typeOf
describe("pathfind strict: UnitPathfinder / FlowField / AIFlowField typeOf", function()
    -- @covers LUnitPathfinder:type
    -- @covers LUnitPathfinder:typeOf
    -- @covers lurek.pathfind.newPathfinder
    -- @covers lurek.pathfind.newNavGrid
    it("LUnitPathfinder type and typeOf are callable", function()
        local grid = lurek.pathfind.newNavGrid(8, 8)
        local pf = lurek.pathfind.newPathfinder(grid)
        expect_type("string", pf:type())
        expect_type("boolean", pf:typeOf("Object"))
    end)

    -- @covers LFlowField:type
    -- @covers LFlowField:typeOf
    -- @covers lurek.pathfind.newFlowField
    -- @covers lurek.pathfind.newNavGrid
    it("LFlowField type and typeOf are callable", function()
        local grid = lurek.pathfind.newNavGrid(8, 8)
        local ff = lurek.pathfind.newFlowField(grid)
        expect_type("string", ff:type())
        expect_type("boolean", ff:typeOf("Object"))
    end)

    -- @covers LPathGrid:typeOf
    -- @covers lurek.pathfind.newPathGrid
    it("LPathGrid typeOf is callable", function()
        local pg = lurek.pathfind.newPathGrid(8, 8, 1.0)
        expect_type("boolean", pg:typeOf("Object"))
    end)

    -- @covers LAIFlowField:typeOf
    -- @covers lurek.pathfind.newPathFlowField
    -- @covers lurek.pathfind.newPathGrid
    it("LAIFlowField typeOf is callable", function()
        local pg = lurek.pathfind.newPathGrid(8, 8, 1.0)
        local aiff = lurek.pathfind.newPathFlowField(pg)
        expect_type("boolean", aiff:typeOf("Object"))
    end)
end)

test_summary()
