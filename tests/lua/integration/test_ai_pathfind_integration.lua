-- Integration: AI state machine + pathfinding A*
-- @describe integration: AI agent uses pathfinding to navigate
describe("integration: AI agent uses pathfinding to navigate", function()
    -- @integration LStateMachine:addState
    -- @integration LStateMachine:addTransition
    -- @integration LStateMachine:forceState
    -- @integration LStateMachine:getCurrentState
    -- @integration LUnitPathfinder:findPath
    -- @integration lurek.ai.newStateMachine
    -- @integration lurek.pathfind.newNavGrid
    -- @integration lurek.pathfind.newPathfinder
    it("AI state machine requests path and transitions to moving state", function()
        local grid = lurek.pathfind.newNavGrid(20, 20)
        local pf   = lurek.pathfind.newPathfinder(grid)

        -- Find path from (1,1) to (6,6) on open grid (1-based coords)
        local path = pf:findPath(1, 1, 6, 6)
        expect_not_nil(path, "pathfinder returned a path")

        local path_len = #path
        expect_true(path_len > 0, "path has at least one step")

        -- Simulate AI state machine: IDLE -> MOVING
        local sm = lurek.ai.newStateMachine()
        sm:addState("IDLE",   { onUpdate = function() end })
        sm:addState("MOVING", { onUpdate = function() end })
        sm:addTransition("IDLE", "MOVING")
        sm:forceState("IDLE")
        expect_equal("IDLE", sm:getCurrentState(), "started in IDLE")

        -- Simulate: found path -> transition to MOVING
        if path_len > 0 then
            sm:forceState("MOVING")
        end
        expect_equal("MOVING", sm:getCurrentState(), "transitioned to MOVING after path found")
    end)

end)
test_summary()
