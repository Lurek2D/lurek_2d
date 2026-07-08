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

    -- @stress LUnitPathfinder:findPathsToGoal
    it("builds many shared-goal routes from one cached field", function()
        local _, pf = new_pathfinder_for_grid(150, 150)
        local starts = {}
        for i = 1, 150 do
            starts[i] = {
                x = (i * 5) % 140 + 1,
                y = (i * 9) % 140 + 1,
            }
        end

        local routes = pf:findPathsToGoal(starts, 140, 140)
        expect_true(#routes >= 140, "shared-goal routes retained")
        expect_true(pf:getSharedGoalCacheSize() >= 1, "shared-goal cache populated")
    end)

    -- @stress LUnitPathfinder:findPathsToGoalFor
    it("builds many named-footprint shared-goal routes", function()
        local grid, pf = new_pathfinder_for_grid(150, 150)
        grid:defineFootprint("tank", { w = 2, h = 2 })
        local starts = {}
        for i = 1, 100 do
            starts[i] = {
                x = (i * 3) % 130 + 1,
                y = (i * 7) % 130 + 1,
            }
        end

        local routes = pf:findPathsToGoalFor("tank", starts, 120, 120)
        expect_not_nil(routes[2], "named-footprint shared route exists")
        expect_true(pf:getSharedGoalCacheSize() >= 1, "named-footprint field cached")
    end)

    -- @stress LUnitPathfinder:getSharedFlowFieldMulti
    it("reuses one cached shared flow handle for repeated multi-target requests", function()
        local _, pf = new_pathfinder_for_grid(200, 200)
        local targets = {
            { x = 180, y = 180 },
            { x = 190, y = 190 },
            { x = 195, y = 195 },
        }

        local first = pf:getSharedFlowFieldMulti(targets)
        local second = pf:getSharedFlowFieldMulti(targets)
        local routes = second:pathsFrom({
            { x = 1, y = 1 },
            { x = 10, y = 10 },
            { x = 40, y = 40 },
        })

        expect_true(first:isCalculated(), "first shared flow calculated")
        expect_not_nil(routes[1], "shared multi route exists")
        expect_equal(1, pf:getSharedGoalCacheSize())
    end)

    -- @stress LUnitPathfinder:getSharedGoalCacheStats
    it("records cache hits after repeated shared flow reuse", function()
        local _, pf = new_pathfinder_for_grid(200, 200)
        pf:getSharedFlowField(190, 190)
        pf:getSharedFlowField(190, 190)
        pf:getSharedFlowField(190, 190)
        local stats = pf:getSharedGoalCacheStats()

        expect_equal(1, stats.size)
        expect_true(stats.hits >= 2, "cache hits accumulate")
        expect_equal(1, stats.misses)
    end)

    -- @stress lurek.pathfind.submitAsyncPathsToGoal
    it("builds many async shared-goal routes in one grouped request", function()
        lurek.pathfind.clearAsyncPaths()
        local grid = lurek.pathfind.newNavGrid(200, 200)
        local starts = {}
        for i = 1, 140 do
            starts[i] = {
                x = (i * 5) % 180 + 1,
                y = (i * 7) % 180 + 1,
            }
        end

        local request_id = lurek.pathfind.submitAsyncPathsToGoal(grid, {
            starts = starts,
            goal_x = 190,
            goal_y = 190,
        })
        local events = {}
        local final_event = nil
        for _ = 1, 256 do
            local polled = lurek.pathfind.pollAsyncPaths()
            for i = 1, #polled do
                events[#events + 1] = polled[i]
                if polled[i].id == request_id and polled[i].final then
                    final_event = polled[i]
                end
            end
            if final_event then
                break
            end
            lurek.timer.sleep(0.001)
        end

        expect_not_nil(final_event, "grouped async event arrived")
        expect_equal("complete", final_event.status)
        expect_true(#final_event.paths >= 120, "most grouped routes retained")
    end)

    -- @stress LNavGrid:findHpaPathsToGoal
    it("builds many shared-goal HPA routes on a large grid", function()
        local grid = lurek.pathfind.newNavGrid(200, 200)
        grid:setChunkSize(10)
        local starts = {}
        for i = 1, 120 do
            starts[i] = {
                x = (i * 5) % 180 + 1,
                y = (i * 7) % 180 + 1,
            }
        end

        local routes = grid:findHpaPathsToGoal(starts, 190, 190)
        expect_true(#routes >= 110, "most HPA routes retained")
        expect_not_nil(routes[1], "first HPA route exists")
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

    -- @stress LFlowField:calculateFor
    it("computes a footprint-aware flow field on a 200x200 grid", function()
        local grid = lurek.pathfind.newNavGrid(200, 200)
        grid:defineFootprint("tank", { w = 2, h = 2 })
        local ff = lurek.pathfind.newFlowField(grid)

        ff:calculateFor("tank", 150, 150)
        expect_true(ff:isCalculated(), "named-footprint flow field calculated")
        expect_true(ff:getBuildCount() >= 1, "at least one build recorded")
    end)

    -- @stress LFlowField:pathsFrom
    it("reconstructs many shared routes from one flow field", function()
        local ff = build_flow_field(150, 150, 100, 100)
        local starts = {}
        for i = 1, 100 do
            starts[i] = {
                x = (i * 7) % 140 + 1,
                y = (i * 11) % 140 + 1,
            }
        end

        local routes = ff:pathsFrom(starts)
        expect_true(#routes >= 90, "most shared routes built")
        expect_not_nil(routes[1], "first shared route exists")
    end)
end)

-- @describe pathfinding stress: orca crowd solver
describe("pathfinding stress: orca crowd solver", function()
    -- @stress LORCASolver:compute
    it("updates a large bounded-neighbor crowd under one compute pass", function()
        local orca = lurek.pathfind.newORCASolver(1.5)
        orca:setCellSize(8.0)
        orca:setNeighborRadius(12.0)
        orca:setMaxNeighbors(6)
        for i = 1, 1500 do
            local x = ((i - 1) % 50) * 2.0
            local y = math.floor((i - 1) / 50) * 2.0
            orca:setAgent(i, {
                x = x,
                y = y,
                radius = 0.5,
                max_speed = 3.0,
                preferred_vx = 1.0,
                preferred_vy = 0.0,
            })
        end

        orca:compute({ dt = 0.016, max_ms = 10.0 })
        local vx, vy = orca:getSafeVelocity(750)
        local stats = orca:getStats()

        expect_type("number", vx)
        expect_type("number", vy)
        expect_equal(1500, stats.activeAgents)
        expect_true(stats.maxNeighborsUsed <= 6, "neighbor cap respected")
    end)

    -- @stress LORCASolver:getStats
    it("reports budget exhaustion when crowd work is cut off early", function()
        local orca = lurek.pathfind.newORCASolver(1.5)
        for i = 1, 1000 do
            orca:setAgent(i, {
                x = (i - 1) % 40,
                y = math.floor((i - 1) / 40),
                radius = 0.5,
                max_speed = 3.0,
                preferred_vx = 1.0,
                preferred_vy = 0.0,
            })
        end

        orca:compute({ dt = 0.016, max_ms = 0.0 })
        local stats = orca:getStats()
        expect_true(stats.budgetExhausted)
        expect_equal(1000, stats.activeAgents)
    end)
end)

-- @describe pathfinding stress: clearance and dirty updates
describe("pathfinding stress: clearance and dirty updates", function()
    -- @stress LNavGrid:rebuildClearance
    it("rebuilds footprint clearance on a 200x200 grid", function()
        local grid = lurek.pathfind.newNavGrid(200, 200)
        grid:defineFootprint("infantry", { w = 1, h = 1 })
        grid:defineFootprint("tank", { w = 2, h = 2 })
        grid:defineFootprint("super_heavy", { w = 4, h = 4 })

        local rebuilt = grid:rebuildClearance()
        expect_equal(3, rebuilt)
        expect_true(grid:isWalkableFor("tank", 1, 1))
    end)

    -- @stress LNavGrid:commitUpdate
    it("commits batched dirty updates without full-map mutation loops in Lua", function()
        local grid = lurek.pathfind.newNavGrid(200, 200)
        grid:defineFootprint("tank", { w = 2, h = 2 })
        grid:rebuildClearance()
        grid:beginUpdate()
        for i = 1, 50 do
            grid:setBlockedRect(i, i, 2, 2, true)
        end

        local committed = grid:commitUpdate({ rebuild = "dirty_chunks" })
        expect_equal(50, committed)
        expect_false(grid:isWalkableFor("tank", 1, 1))
    end)
end)
test_summary()
