-- Golden test: raycaster

-- @describe golden: raycaster evidence comparison
describe("golden: raycaster evidence comparison", function()
    it("matches golden samples", function()
        expect_golden_file_match(
            evidence_output_dir("raycaster") .. "raycaster_topdown.png",
            "tests/artifacts/baselines/raycaster/raycaster_topdown.png"
        )
        expect_golden_file_match(
            evidence_output_dir("raycaster") .. "raycaster_depth.png",
            "tests/artifacts/baselines/raycaster/raycaster_depth.png"
        )
        expect_golden_file_match(
            evidence_output_dir("raycaster") .. "raycaster_fov.png",
            "tests/artifacts/baselines/raycaster/raycaster_fov.png"
        )
        expect_golden_file_match(
            evidence_output_dir("raycaster") .. "raycaster_minimap.png",
            "tests/artifacts/baselines/raycaster/raycaster_minimap.png"
        )
        expect_golden_file_match(
            evidence_output_dir("raycaster") .. "raycaster_shaded_walls.png",
            "tests/artifacts/baselines/raycaster/raycaster_shaded_walls.png"
        )
        expect_golden_file_match(
            evidence_output_dir("raycaster") .. "raycaster_mirrors.png",
            "tests/artifacts/baselines/raycaster/raycaster_mirrors.png"
        )
        expect_golden_file_match(
            evidence_output_dir("raycaster") .. "raycaster_glass.png",
            "tests/artifacts/baselines/raycaster/raycaster_glass.png"
        )
        expect_golden_file_match(
            evidence_output_dir("raycaster") .. "raycaster_floor_ceiling.png",
            "tests/artifacts/baselines/raycaster/raycaster_floor_ceiling.png"
        )
        expect_golden_file_match(
            evidence_output_dir("raycaster") .. "raycaster_animated_walls.png",
            "tests/artifacts/baselines/raycaster/raycaster_animated_walls.png"
        )
        expect_golden_file_match(
            evidence_output_dir("raycaster") .. "raycaster_billboard.png",
            "tests/artifacts/baselines/raycaster/raycaster_billboard.png"
        )
        expect_golden_file_match(
            evidence_output_dir("raycaster") .. "raycaster_textured_corridor_view.png",
            "tests/artifacts/baselines/raycaster/raycaster_textured_corridor_view.png"
        )
    end)
end)
test_summary()
