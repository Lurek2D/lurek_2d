-- Golden test: minimap

-- @describe golden: minimap evidence comparison
describe("golden: minimap evidence comparison", function()
    it("matches golden samples", function()
        expect_golden_file_match(
            evidence_output_dir("minimap") .. "minimap_terrain.png",
            "tests/artifacts/baselines/minimap/minimap_terrain.png"
        )
        expect_golden_file_match(
            evidence_output_dir("minimap") .. "minimap_fog.png",
            "tests/artifacts/baselines/minimap/minimap_fog.png"
        )
        expect_golden_file_match(
            evidence_output_dir("minimap") .. "minimap_blips.png",
            "tests/artifacts/baselines/minimap/minimap_blips.png"
        )
        expect_golden_file_match(
            evidence_output_dir("minimap") .. "minimap_viewport_bounds.png",
            "tests/artifacts/baselines/minimap/minimap_viewport_bounds.png"
        )
        expect_golden_file_match(
            evidence_output_dir("minimap") .. "minimap_waypoints.png",
            "tests/artifacts/baselines/minimap/minimap_waypoints.png"
        )
        expect_golden_file_match(
            evidence_output_dir("minimap") .. "minimap_radar_sweep.png",
            "tests/artifacts/baselines/minimap/minimap_radar_sweep.png"
        )
        expect_golden_file_match(
            evidence_output_dir("minimap") .. "minimap_zoomed_sector.png",
            "tests/artifacts/baselines/minimap/minimap_zoomed_sector.png"
        )
        expect_golden_file_match(
            evidence_output_dir("minimap") .. "minimap_circular_border.png",
            "tests/artifacts/baselines/minimap/minimap_circular_border.png"
        )
        expect_golden_file_match(
            evidence_output_dir("minimap") .. "minimap_multi_floor_overview.png",
            "tests/artifacts/baselines/minimap/minimap_multi_floor_overview.png"
        )
        expect_golden_file_match(
            evidence_output_dir("minimap") .. "minimap_unexplored_mask.png",
            "tests/artifacts/baselines/minimap/minimap_unexplored_mask.png"
        )
    end)
end)
test_summary()
