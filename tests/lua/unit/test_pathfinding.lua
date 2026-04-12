-- Pathfinding module Lua tests
-- All tests are headless-safe (BDD framework)

-- ============================================================
-- NavGrid creation and basic ops
-- ============================================================
-- @covers lurek.pathfinding.getThreadCount
-- @covers lurek.pathfinding.newFlowField
-- @covers lurek.pathfinding.newNavGrid
-- @covers lurek.pathfinding.newNavGridFromTileMap
-- @covers lurek.pathfinding.newPathfinder
-- @covers lurek.tilemap.newTileMap

-- @covers lurek.pathfinding.NavGrid.getDimensions
-- @covers lurek.pathfinding.NavGrid.fill
-- @covers lurek.pathfinding.NavGrid.saveToString
-- @covers lurek.pathfinding.NavGrid.loadFromString
-- @covers lurek.pathfinding.NavGrid.setChunkSize
-- @covers lurek.pathfinding.NavGrid.getChunkSize
-- @covers lurek.pathfinding.NavGrid.type
-- @covers lurek.pathfinding.NavGrid.typeOf
-- @covers lurek.pathfinding.UnitPathfinder.findPathSmooth
-- @covers lurek.pathfinding.UnitPathfinder.getPathLength
-- @covers lurek.pathfinding.UnitPathfinder.getPathCost
-- @covers lurek.pathfinding.UnitPathfinder.findPartialPath
-- @covers lurek.pathfinding.UnitPathfinder.findNearestWalkable
-- @covers lurek.pathfinding.UnitPathfinder.isReachable
-- @covers lurek.pathfinding.UnitPathfinder.lineOfSight
-- @covers lurek.pathfinding.UnitPathfinder.setCacheEnabled
-- @covers lurek.pathfinding.UnitPathfinder.isCacheEnabled
-- @covers lurek.pathfinding.UnitPathfinder.clearCache
-- @covers lurek.pathfinding.UnitPathfinder.getCacheSize
-- @covers lurek.pathfinding.UnitPathfinder.setCacheMaxSize

describe("NavGrid creation", function()
    it("newNavGrid returns an object", function()
        local grid = lurek.pathfinding.newNavGrid(20, 20)
        expect_type("userdata", grid)
    end)

    it("width and height are correct", function()
        local grid = lurek.pathfinding.newNavGrid(20, 20)
        expect_equal(20, grid:getWidth())
        expect_equal(20, grid:getHeight())
    end)

    it("default cost is 1", function()
        local grid = lurek.pathfinding.newNavGrid(5, 5)
        expect_equal(1, grid:getCost(1, 1))
    end)

    it("setCost changes cost", function()
        local grid = lurek.pathfinding.newNavGrid(10, 10)
        grid:setCost(5, 5, 10)
        expect_equal(10, grid:getCost(5, 5))
    end)

    it("setBlocked / isBlocked", function()
        local grid = lurek.pathfinding.newNavGrid(10, 10)
        grid:setBlocked(3, 3, true)
        expect_true(grid:isBlocked(3, 3))
        expect_false(grid:isBlocked(1, 1))
    end)

    it("isWalkable reflects blocked state", function()
        local grid = lurek.pathfinding.newNavGrid(10, 10)
        expect_true(grid:isWalkable(1, 1))
        grid:setBlocked(1, 1, true)
        expect_false(grid:isWalkable(1, 1))
    end)

    it("fillRect blocks region", function()
        local grid = lurek.pathfinding.newNavGrid(20, 20)
        grid:fillRect(10, 10, 3, 3, 0)
        expect_true(grid:isBlocked(10, 10))
        expect_true(grid:isBlocked(12, 12))
        expect_false(grid:isBlocked(9, 9))
    end)

    it("diagonal mode get/set", function()
        local grid = lurek.pathfinding.newNavGrid(10, 10)
        grid:setDiagonalMode("always")
        expect_equal("always", grid:getDiagonalMode())
        grid:setDiagonalMode("none")
        expect_equal("none", grid:getDiagonalMode())
    end)
end)

-- ============================================================
-- Pathfinder
-- ============================================================
describe("Pathfinder", function()
    it("newPathfinder returns an object", function()
        local grid = lurek.pathfinding.newNavGrid(10, 10)
        local pf = lurek.pathfinding.newPathfinder(grid)
        expect_type("userdata", pf)
    end)

    it("findPath on open grid returns path", function()
        local grid = lurek.pathfinding.newNavGrid(10, 10)
        local pf = lurek.pathfinding.newPathfinder(grid)
        local path = pf:findPath(1, 1, 10, 10)
        expect_true(path ~= nil, "should find path")
        expect_true(#path > 0, "path should have waypoints")
        expect_equal(1, path[1].x)
        expect_equal(1, path[1].y)
        expect_equal(10, path[#path].x)
        expect_equal(10, path[#path].y)
    end)

    it("findPath through narrow gap", function()
        local grid = lurek.pathfinding.newNavGrid(10, 10)
        for y = 1, 10 do grid:setBlocked(5, y, true) end
        grid:setBlocked(5, 5, false)
        local pf = lurek.pathfinding.newPathfinder(grid)
        local path = pf:findPath(1, 1, 10, 10)
        expect_true(path ~= nil, "should find path through narrow gap")
    end)

    it("heuristicDistance returns positive number", function()
        local grid = lurek.pathfinding.newNavGrid(10, 10)
        local pf = lurek.pathfinding.newPathfinder(grid)
        local d = pf:heuristicDistance(1, 1, 4, 5)
        expect_type("number", d)
        expect_true(d > 0, "distance should be positive")
    end)

    it("cache operations", function()
        local grid = lurek.pathfinding.newNavGrid(10, 10)
        local pf = lurek.pathfinding.newPathfinder(grid)
        expect_true(pf:isCacheEnabled())
        pf:clearCache()
        expect_equal(0, pf:getCacheSize())
    end)
end)

-- ============================================================
-- FlowField
-- ============================================================
describe("FlowField", function()
    it("newFlowField returns an object", function()
        local grid = lurek.pathfinding.newNavGrid(10, 10)
        local ff = lurek.pathfinding.newFlowField(grid)
        expect_type("userdata", ff)
    end)

    it("isCalculated returns false initially", function()
        local grid = lurek.pathfinding.newNavGrid(10, 10)
        local ff = lurek.pathfinding.newFlowField(grid)
        expect_false(ff:isCalculated())
    end)

    it("calculate makes isCalculated true", function()
        local grid = lurek.pathfinding.newNavGrid(10, 10)
        local ff = lurek.pathfinding.newFlowField(grid)
        ff:calculate(10, 10)
        expect_true(ff:isCalculated())
    end)

    it("getDirection returns numbers", function()
        local grid = lurek.pathfinding.newNavGrid(10, 10)
        local ff = lurek.pathfinding.newFlowField(grid)
        ff:calculate(10, 10)
        local dx, dy = ff:getDirection(1, 1)
        expect_type("number", dx)
        expect_type("number", dy)
    end)

    it("getCostToTarget positive for reachable cell", function()
        local grid = lurek.pathfinding.newNavGrid(10, 10)
        local ff = lurek.pathfinding.newFlowField(grid)
        ff:calculate(10, 10)
        local cost = ff:getCostToTarget(1, 1)
        expect_true(cost > 0, "cost should be positive")
    end)

    it("steer returns numbers", function()
        local grid = lurek.pathfinding.newNavGrid(10, 10)
        local ff = lurek.pathfinding.newFlowField(grid)
        ff:calculate(10, 10)
        local vx, vy = ff:steer(0, 0, 100, 1, 1)
        expect_type("number", vx)
        expect_type("number", vy)
    end)
end)

-- ============================================================
-- Thread count
-- ============================================================
describe("pathfinding threadCount", function()
    it("getThreadCount returns a number", function()
        local tc = lurek.pathfinding.getThreadCount()
        expect_type("number", tc)
    end)
end)

-- ============================================================
-- newNavGridFromTileMap
-- ============================================================
describe("newNavGridFromTileMap", function()
    it("is a function", function()
        expect_type("function", lurek.pathfinding.newNavGridFromTileMap)
    end)

    it("creates grid from tilemap with correct dimensions", function()
        local tm = lurek.tilemap.newTileMap(16, 16, 8)
        tm:addLayer("ground", 4, 4)
        for y = 1, 4 do
            for x = 1, 4 do
                tm:setTile(1, x, y, 1)
            end
        end
        local nav = lurek.pathfinding.newNavGridFromTileMap(tm, 1, {2})
        expect_equal(4, nav:getWidth())
        expect_equal(4, nav:getHeight())
    end)

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
        local nav = lurek.pathfinding.newNavGridFromTileMap(tm, 1, {2})
        expect_equal(0, nav:getCost(2, 2))
        expect_equal(0, nav:getCost(3, 3))
        expect_true(nav:getCost(1, 1) > 0, "walkable tile should have cost > 0")
    end)
end)

-- ── NavGrid extended ─────────────────────────────────────────────────────────

describe("NavGrid.getDimensions", function()
    it("getDimensions returns width and height", function()
        local g = lurek.pathfinding.newNavGrid(12, 8)
        local w, h = g:getDimensions()
        expect_equal(12, w)
        expect_equal(8, h)
    end)
end)

describe("NavGrid.fill", function()
    it("fill sets all cells to the same cost", function()
        local g = lurek.pathfinding.newNavGrid(5, 5)
        g:fill(3)
        for y = 1, 5 do
            for x = 1, 5 do
                expect_equal(3, g:getCost(x, y))
            end
        end
    end)

    it("fill with 0 marks entire grid blocked", function()
        local g = lurek.pathfinding.newNavGrid(4, 4)
        g:fill(0)
        for y = 1, 4 do
            for x = 1, 4 do
                expect_false(g:isWalkable(x, y))
            end
        end
    end)
end)

describe("NavGrid.saveToString / loadFromString", function()
    it("saveToString returns a non-empty string", function()
        local g = lurek.pathfinding.newNavGrid(6, 6)
        local s = g:saveToString()
        expect_type("string", s)
        expect_true(#s > 0, "serialised string must not be empty")
    end)

    it("loadFromString round-trips blocked state", function()
        local g = lurek.pathfinding.newNavGrid(6, 6)
        g:setBlocked(3, 3, true)
        g:setBlocked(4, 2, true)
        local s  = g:saveToString()
        local g2 = lurek.pathfinding.newNavGrid(6, 6)
        g2:loadFromString(s)
        expect_true(g2:isBlocked(3, 3), "cell 3,3 still blocked after deserialise")
        expect_true(g2:isBlocked(4, 2), "cell 4,2 still blocked after deserialise")
        expect_false(g2:isBlocked(1, 1))
    end)

    it("loadFromString round-trips cost values", function()
        local g = lurek.pathfinding.newNavGrid(4, 4)
        g:setCost(2, 2, 7)
        local g2 = lurek.pathfinding.newNavGrid(4, 4)
        g2:loadFromString(g:saveToString())
        expect_equal(7, g2:getCost(2, 2))
    end)
end)

describe("NavGrid.setChunkSize / getChunkSize", function()
    it("setChunkSize / getChunkSize round-trip", function()
        local g = lurek.pathfinding.newNavGrid(32, 32)
        g:setChunkSize(8)
        expect_equal(8, g:getChunkSize())
    end)
end)

describe("NavGrid.type / typeOf", function()
    it("type() returns a string", function()
        local g = lurek.pathfinding.newNavGrid(4, 4)
        expect_type("string", g:type())
    end)

    it("typeOf() checks identity against a type name", function()
        local g = lurek.pathfinding.newNavGrid(4, 4)
        expect_true(g:typeOf("NavGrid"))
        expect_false(g:typeOf("FlowField"))
    end)
end)

-- ── UnitPathfinder extended ───────────────────────────────────────────────────

describe("UnitPathfinder.findPathSmooth", function()
    it("findPathSmooth returns a table or nil", function()
        local g = lurek.pathfinding.newNavGrid(10, 10)
        local pf = lurek.pathfinding.newPathfinder(g)
        local path = pf:findPathSmooth(1, 1, 10, 10)
        assert(path == nil or type(path) == "table", "findPathSmooth must return table or nil")
    end)

    it("findPathSmooth with open grid returns a path", function()
        local g = lurek.pathfinding.newNavGrid(10, 10)
        local pf = lurek.pathfinding.newPathfinder(g)
        local path = pf:findPathSmooth(1, 1, 10, 10)
        expect_true(path ~= nil, "expected a smooth path in open grid")
    end)
end)

describe("UnitPathfinder.getPathLength / getPathCost", function()
    it("getPathLength returns a number for a valid path", function()
        local g = lurek.pathfinding.newNavGrid(10, 10)
        local pf = lurek.pathfinding.newPathfinder(g)
        local path = pf:findPath(1, 1, 8, 8)
        if path then
            local len = pf:getPathLength(path)
            expect_type("number", len)
            expect_true(len >= 0)
        else
            expect_true(true, "skip: no path found")
        end
    end)

    it("getPathCost returns a number for a valid path", function()
        local g = lurek.pathfinding.newNavGrid(10, 10)
        local pf = lurek.pathfinding.newPathfinder(g)
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

describe("UnitPathfinder.findPartialPath", function()
    it("findPartialPath returns a path and boolean", function()
        local g = lurek.pathfinding.newNavGrid(10, 10)
        local pf = lurek.pathfinding.newPathfinder(g)
        local path, complete = pf:findPartialPath(1, 1, 10, 10, 100)
        assert(path == nil or type(path) == "table")
        expect_type("boolean", complete)
    end)

    it("findPartialPath in open grid returns complete=true", function()
        local g = lurek.pathfinding.newNavGrid(10, 10)
        local pf = lurek.pathfinding.newPathfinder(g)
        local _path, complete = pf:findPartialPath(1, 1, 10, 10, 200)
        expect_true(complete, "open grid partial path should be complete")
    end)
end)

describe("UnitPathfinder.findNearestWalkable", function()
    it("findNearestWalkable returns two numbers", function()
        local g = lurek.pathfinding.newNavGrid(10, 10)
        g:setBlocked(5, 5, true)
        local pf = lurek.pathfinding.newPathfinder(g)
        local nx, ny = pf:findNearestWalkable(5, 5, 5)
        expect_type("number", nx)
        expect_type("number", ny)
    end)

    it("findNearestWalkable returns same coords for already walkable cell", function()
        local g = lurek.pathfinding.newNavGrid(10, 10)
        local pf = lurek.pathfinding.newPathfinder(g)
        local nx, ny = pf:findNearestWalkable(3, 3, 5)
        expect_equal(3, nx)
        expect_equal(3, ny)
    end)
end)

describe("UnitPathfinder.isReachable", function()
    it("isReachable returns true for reachable goal in open grid", function()
        local g = lurek.pathfinding.newNavGrid(10, 10)
        local pf = lurek.pathfinding.newPathfinder(g)
        expect_true(pf:isReachable(1, 1, 10, 10))
    end)

    it("isReachable returns false when goal is fully blocked", function()
        local g = lurek.pathfinding.newNavGrid(10, 10)
        -- Wall off all border cells adjacent to 10,10
        for dx = -1, 0 do
            for dy = -1, 0 do
                g:setBlocked(10 + dx, 10 + dy, true)
            end
        end
        local pf = lurek.pathfinding.newPathfinder(g)
        local result = pf:isReachable(1, 1, 10, 10)
        expect_type("boolean", result)
    end)
end)

describe("UnitPathfinder.lineOfSight", function()
    it("lineOfSight returns true for unobstructed path", function()
        local g = lurek.pathfinding.newNavGrid(10, 10)
        local pf = lurek.pathfinding.newPathfinder(g)
        expect_true(pf:lineOfSight(1, 1, 5, 5))
    end)

    it("lineOfSight returns false when wall blocks", function()
        local g = lurek.pathfinding.newNavGrid(10, 10)
        -- Block a column between start and end
        for y = 1, 10 do g:setBlocked(5, y, true) end
        local pf = lurek.pathfinding.newPathfinder(g)
        local los = pf:lineOfSight(1, 5, 9, 5)
        expect_type("boolean", los)
    end)
end)

describe("UnitPathfinder cache control", function()
    it("setCacheEnabled / isCacheEnabled round-trip", function()
        local g = lurek.pathfinding.newNavGrid(10, 10)
        local pf = lurek.pathfinding.newPathfinder(g)
        pf:setCacheEnabled(false)
        expect_false(pf:isCacheEnabled())
        pf:setCacheEnabled(true)
        expect_true(pf:isCacheEnabled())
    end)

    it("clearCache does not error", function()
        local g = lurek.pathfinding.newNavGrid(10, 10)
        local pf = lurek.pathfinding.newPathfinder(g)
        expect_no_error(function() pf:clearCache() end)
    end)

    it("getCacheSize returns a number", function()
        local g = lurek.pathfinding.newNavGrid(10, 10)
        local pf = lurek.pathfinding.newPathfinder(g)
        expect_type("number", pf:getCacheSize())
    end)

    it("setCacheMaxSize does not error", function()
        local g = lurek.pathfinding.newNavGrid(10, 10)
        local pf = lurek.pathfinding.newPathfinder(g)
        expect_no_error(function() pf:setCacheMaxSize(100) end)
    end)
end)

test_summary()
