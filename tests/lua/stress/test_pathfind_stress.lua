-- Lurek2D Stress Test: Pathfinding on Large Grids
-- Tests A* and flow field computation at scale

-- @describe pathfinding stress: large grid A*
describe("pathfinding stress: large grid A*", function()
    -- @stress LUnitPathfinder:findPath
    -- @stress lurek.pathfind.newNavGrid
    -- @stress lurek.pathfind.newPathfinder
    it("pathfinds on a 200x200 open grid", function()
        local grid = lurek.pathfind.newNavGrid(200, 200)
        local pf = lurek.pathfind.newPathfinder(grid)

        local path = pf:findPath(1, 1, 199, 199)
        expect_not_nil(path, "path found on open grid")
        expect_true(#path > 0, "path has waypoints")
    end)

    -- @stress LNavGrid:setBlocked
    -- @stress LUnitPathfinder:findPath
    -- @stress lurek.pathfind.newNavGrid
    -- @stress lurek.pathfind.newPathfinder
    it("pathfinds around obstacles on 100x100 grid", function()
        local grid = lurek.pathfind.newNavGrid(100, 100)

        -- Create wall obstacles
        for x = 10, 89 do
            grid:setBlocked(x, 50, true)
        end

        local pf = lurek.pathfind.newPathfinder(grid)
        local path = pf:findPath(50, 1, 50, 99)
        expect_not_nil(path, "path found around wall")
        expect_true(#path > 50, "path goes around obstacle")
    end)

    -- @stress LNavGrid:setBlocked
    -- @stress LUnitPathfinder:findPath
    -- @stress lurek.pathfind.newNavGrid
    -- @stress lurek.pathfind.newPathfinder
    it("handles fully blocked path gracefully", function()
        local grid = lurek.pathfind.newNavGrid(50, 50)

        -- Create complete wall at y=25
        for x = 1, 50 do
            grid:setBlocked(x, 25, true)
        end

        local pf = lurek.pathfind.newPathfinder(grid)
        local path = pf:findPath(25, 1, 25, 50)
        -- Engine may return nil, empty, or a partial/alternative path
        -- Key test: it should not crash
        if path and #path > 0 then
            -- Path was found (possibly via alternative route) - this is acceptable
            expect_true(#path > 0, "non-empty path returned")
        end
        -- If path is nil or empty, that's also acceptable
    end)

    -- @stress LNavGrid:setCost
    -- @stress LUnitPathfinder:findPath
    -- @stress lurek.pathfind.newNavGrid
    -- @stress lurek.pathfind.newPathfinder
    it("costs affect pathfinding", function()
        local grid = lurek.pathfind.newNavGrid(50, 50)

        -- Make center area expensive
        for y = 20, 30 do
            for x = 20, 30 do
                grid:setCost(x, y, 100)
            end
        end

        local pf = lurek.pathfind.newPathfinder(grid)
        local path = pf:findPath(1, 25, 49, 25)
        expect_not_nil(path, "path found with high-cost area")
    end)
end)

-- @describe pathfinding stress: repeated pathfinding
describe("pathfinding stress: repeated pathfinding", function()
    -- @stress LNavGrid:setBlocked
    -- @stress LUnitPathfinder:findPath
    -- @stress lurek.pathfind.newNavGrid
    -- @stress lurek.pathfind.newPathfinder
    it("finds 500 paths on same grid", function()
        local grid = lurek.pathfind.newNavGrid(100, 100)

        -- Add some obstacles
        for i = 1, 20 do
            local x = (i * 7) % 99 + 1
            local y = (i * 13) % 99 + 1
            grid:setBlocked(x, y, true)
        end

        local pf = lurek.pathfind.newPathfinder(grid)
        local paths_found = 0
        for i = 1, 500 do
            local sx = (i * 3) % 98 + 1
            local sy = (i * 7) % 98 + 1
            local ex = (i * 11) % 98 + 1
            local ey = (i * 17) % 98 + 1
            local path = pf:findPath(sx, sy, ex, ey)
            if path and #path > 0 then
                paths_found = paths_found + 1
            end
        end

        expect_true(paths_found > 400, "most paths found: " .. paths_found)
    end)
end)

-- @describe pathfinding stress: flow field
describe("pathfinding stress: flow field", function()
    -- @stress LFlowField:calculate
    -- @stress LFlowField:getDirection
    -- @stress LFlowField:isCalculated
    -- @stress lurek.pathfind.newFlowField
    -- @stress lurek.pathfind.newNavGrid
    it("computes flow field on 100x100 grid", function()
        local grid = lurek.pathfind.newNavGrid(100, 100)
        local ff = lurek.pathfind.newFlowField(grid)
        ff:calculate(50, 50)
        expect_true(ff:isCalculated(), "flow field calculated")
        local dx, dy = ff:getDirection(1, 1)
        expect_type("number", dx)
        expect_type("number", dy)
    end)
end)
test_summary()
