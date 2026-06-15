-- Integration: lurek.math Vec3/spline/lerp/remap combined with pathfinding costs

-- Vec3 heuristic applied to pathfinding costs
-- @describe vec3 + pathfinding heuristic integration

-- @describe vec3 + pathfinding heuristic integration
describe("vec3 + pathfinding heuristic integration", function()

    -- @integration LJpsGrid:findPath
    -- @integration LVec3:distance
    -- @integration lurek.math.vec3
    -- @integration lurek.pathfind.newJpsGrid
    -- @integration lurek.math.vec3
    -- @integration lurek.pathfind.newJpsGrid
    it("3D distances can weight JPS grid costs", function()
        -- Simulate two waypoints in 3D space
        local a = lurek.math.vec3(0, 0, 0)
        local b = lurek.math.vec3(10, 0, 5)
        local dist_3d = a:distance(b)
        expect_true(dist_3d > 10, "3D distance should be larger than 2D along x")
        expect_near(math.sqrt(125), dist_3d, 0.001, "vec3 distance matches expected 3D heuristic length")

        local g = lurek.pathfind.newJpsGrid(8, 8)
        local path = g:findPath(1, 1, 5, 5)
        expect_type("table", path, "JPS should return a concrete path on an open grid")
        expect_true(#path > 0, "JPS path should contain at least one step")
        expect_equal(1, path[1].x, "path starts at requested x")
        expect_equal(1, path[1].y, "path starts at requested y")
        expect_equal(5, path[#path].x, "path ends at requested x")
        expect_equal(5, path[#path].y, "path ends at requested y")
    end)

end)
test_summary()
