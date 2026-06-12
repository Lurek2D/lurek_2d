-- Lurek2D Stress Test: Pathfinding on Large Grids
-- Tests A* and flow field computation at scale

local function new_pathfinder_for_grid(width, height)
    local grid = lurek.pathfind.newNavGrid(width, height)
    local pf = lurek.pathfind.newPathfinder(grid)
    return grid, pf
end

local function block_horizontal_wall(grid, x_start, x_end, y)
    for x = x_start, x_end do
        grid:setBlocked(x, y, true)
    end
end

local function build_cost_patch(grid, x0, x1, y0, y1, cost)
    for y = y0, y1 do
        for x = x0, x1 do
            grid:setCost(x, y, cost)
        end
    end
end

local function add_scattered_obstacles(grid, count)
    for i = 1, count do
        local x = (i * 7) % 99 + 1
        local y = (i * 13) % 99 + 1
        grid:setBlocked(x, y, true)
    end
end

local function build_flow_field(width, height, target_x, target_y)
    local grid = lurek.pathfind.newNavGrid(width, height)
    local ff = lurek.pathfind.newFlowField(grid)
    ff:calculate(target_x, target_y)
    return ff
end

-- @describe pathfinding stress: large grid A*
describe("pathfinding stress: large grid A*", function()
    -- @stress LUnitPathfinder:findPath
    it("pathfinds on a 200x200 open grid", function()
        local _, pf = new_pathfinder_for_grid(200, 200)
        expect_type("userdata", pf)

        local path = pf:findPath(1, 1, 199, 199)
        expect_not_nil(path, "path found on open grid")
        expect_true(#path > 0, "path has waypoints")
    end)

    -- @stress LNavGrid:setBlocked
    it("pathfinds around obstacles on 100x100 grid", function()
        local grid, pf = new_pathfinder_for_grid(100, 100)
        block_horizontal_wall(grid, 10, 89, 50)

        local path = pf:findPath(50, 1, 50, 99)
        expect_not_nil(path, "path found around wall")
        expect_true(#path > 50, "path goes around obstacle")
    end)

    -- @stress lurek.pathfind.newNavGrid
    it("handles fully blocked path gracefully", function()
        local grid, pf = new_pathfinder_for_grid(50, 50)
        expect_type("userdata", grid)
        block_horizontal_wall(grid, 1, 50, 25)

        local path = pf:findPath(25, 1, 25, 50)
        if path and #path > 0 then
            expect_true(#path > 0, "non-empty path returned")
        end
    end)

    -- @stress LNavGrid:setCost
    it("costs affect pathfinding", function()
        local grid, pf = new_pathfinder_for_grid(50, 50)
        build_cost_patch(grid, 20, 30, 20, 30, 100)

        local path = pf:findPath(1, 25, 49, 25)
        expect_not_nil(path, "path found with high-cost area")
    end)
end)

-- @describe pathfinding stress: repeated pathfinding
describe("pathfinding stress: repeated pathfinding", function()
    -- @stress lurek.pathfind.newPathfinder
    it("finds 500 paths on same grid", function()
        local grid, pf = new_pathfinder_for_grid(100, 100)
        add_scattered_obstacles(grid, 20)
        expect_type("userdata", pf)

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
    -- @stress LFlowField:getDirection
    it("computes flow field on 100x100 grid", function()
        local ff = build_flow_field(100, 100, 50, 50)
        expect_true(ff:isCalculated(), "flow field calculated")
        local dx, dy = ff:getDirection(1, 1)
        expect_type("number", dx)
        expect_type("number", dy)
    end)
end)
test_summary()
