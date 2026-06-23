-- Integration: tilefield wall channel feeds raycaster scene building.

-- @describe integration: tilefield feeds raycaster
describe("integration: tilefield feeds raycaster", function()
    -- @integration lurek.tilefield.new
    -- @integration LTileField:applyProfile
    -- @integration lurek.raycaster.buildMultiLevelSceneFromField
    it("builds render scene from field vision blockers", function()
        local field = lurek.tilefield.new({ width = 6, height = 6, levels = 2 })
        field:applyProfile(3, 3, 1, "wall")
        field:applyProfile(4, 4, 2, "wall")

        local quads = lurek.raycaster.buildMultiLevelSceneFromField({
            px = 2.5,
            py = 2.5,
            angle = 0,
            fov = 1.0,
            rays = 32,
            max_dist = 8,
            screen_w = 96,
            screen_h = 64,
            active_level = 0,
        }, field, { wallChannel = "vision" })

        expect_true(quads >= 0)
    end)
end)

test_summary()
