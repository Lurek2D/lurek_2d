-- Golden test: globe compare evidence output against golden samples

-- @describe golden: globe evidence comparison
describe("golden: globe evidence comparison", function()
    it("matches globe baselines", function()
        expect_golden_file_match(
            evidence_output_dir("globe") .. "globe_great_circle_route.png",
            "tests/artifacts/baselines/globe/globe_great_circle_route.png"
        )
        expect_golden_file_match(
            evidence_output_dir("globe") .. "globe_province_projection.png",
            "tests/artifacts/baselines/globe/globe_province_projection.png"
        )
        expect_golden_text_match(
            evidence_output_dir("globe") .. "globe_great_circle_metrics.txt",
            "tests/artifacts/baselines/globe/globe_great_circle_metrics.txt"
        )
        expect_golden_text_match(
            evidence_output_dir("globe") .. "globe_region_trace.txt",
            "tests/artifacts/baselines/globe/globe_region_trace.txt"
        )
        expect_golden_text_match(
            evidence_output_dir("globe") .. "globe_camera_fog_registry_trace.txt",
            "tests/artifacts/baselines/globe/globe_camera_fog_registry_trace.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("globe") .. "globe_layer_heat_fog_composite.png",
            "tests/artifacts/baselines/globe/globe_layer_heat_fog_composite.png"
        )
        expect_golden_file_match(
            evidence_output_dir("globe") .. "globe_marker_pick_surface.png",
            "tests/artifacts/baselines/globe/globe_marker_pick_surface.png"
        )
        expect_golden_file_match(
            evidence_output_dir("globe") .. "globe_topology_cost_route.png",
            "tests/artifacts/baselines/globe/globe_topology_cost_route.png"
        )
        expect_golden_file_match(
            evidence_output_dir("globe") .. "globe_camera_lod_panels.png",
            "tests/artifacts/baselines/globe/globe_camera_lod_panels.png"
        )
        expect_golden_file_match(
            evidence_output_dir("globe") .. "globe_semantic_region_holes.png",
            "tests/artifacts/baselines/globe/globe_semantic_region_holes.png"
        )
    end)
end)
test_summary()
