-- Golden test: raycaster

local FILES = {
    "raycaster_corridor_view_with_fov.png",
    "raycaster_depth_columns_vs_view.png",
    "raycaster_camera_sweep_atlas.png",
    "raycaster_topdown_reveal_fov.png",
    "raycaster_los_wall_window_door.png",
    "raycaster_transparent_layered_hits.png",
    "raycaster_feature_walls_view_pick.png",
    "raycaster_minimap_reveal_lighting.png",
    "raycaster_floor_ceiling_pick_uv.png",
    "raycaster_multilevel_hole_pick.png",
}

-- @describe golden: raycaster evidence comparison
describe("golden: raycaster evidence comparison", function()
    it("matches raycaster baselines", function()
        for _, name in ipairs(FILES) do
            expect_golden_file_match(
                evidence_output_dir("raycaster") .. name,
                "tests/artifacts/baselines/raycaster/" .. name
            )
        end
    end)
end)

test_summary()
