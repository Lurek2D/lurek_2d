-- Integration: tilefield movement semantics feed pathfinding.

-- @describe integration: tilefield feeds pathfind movement
describe("integration: tilefield feeds pathfind movement", function()
    -- @integration lurek.tilefield.new
    -- @integration LTileField:applyProfile
    -- @integration lurek.pathfind.newNavGridFromField
    -- @integration lurek.pathfind.newPathfinder
    -- @integration LNavGrid:isBlocked
    -- @integration LUnitPathfinder:findPath
    it("window blocks movement through pathfind adapter", function()
        local field = lurek.tilefield.new({ width = 5, height = 3 })
        field:applyProfile(3, 2, 1, "window")

        local nav = lurek.pathfind.newNavGridFromField(field, { level = 1, channel = "move" })
        local pathfinder = lurek.pathfind.newPathfinder(nav)
        local path = pathfinder:findPath(1, 2, 5, 2)

        expect_true(nav:isBlocked(3, 2))
        expect_not_nil(path)
        for i = 1, #path do
            expect_true(not (path[i].x == 3 and path[i].y == 2), "path avoids window movement blocker")
        end
    end)
end)

test_summary()
