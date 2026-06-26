-- Golden test: pathfind

-- @describe golden: pathfind evidence comparison
describe("golden: pathfind evidence comparison", function()
    it("matches golden samples", function()
        expect_golden_file_match(
            evidence_output_dir("pathfind") .. "astar_basic.png",
            "tests/artifacts/baselines/pathfind/astar_basic.png"
        )
        expect_golden_file_match(
            evidence_output_dir("pathfind") .. "pathfind_api_surface.png",
            "tests/artifacts/baselines/pathfind/pathfind_api_surface.png"
        )
        expect_golden_file_match(
            evidence_output_dir("pathfind") .. "weighted_route.png",
            "tests/artifacts/baselines/pathfind/weighted_route.png"
        )
        expect_golden_file_match(
            evidence_output_dir("pathfind") .. "pathfind_hex_tilefield_route.png",
            "tests/artifacts/baselines/pathfind/pathfind_hex_tilefield_route.png"
        )
        expect_golden_file_match(
            evidence_output_dir("pathfind") .. "pathfind_iso_tilefield_route.png",
            "tests/artifacts/baselines/pathfind/pathfind_iso_tilefield_route.png"
        )
        expect_golden_text_match(
            evidence_output_dir("pathfind") .. "pathfind_astar_gap_trace.json",
            "tests/artifacts/baselines/pathfind/pathfind_astar_gap_trace.json"
        )
        expect_golden_text_match(
            evidence_output_dir("pathfind") .. "pathfind_flow_field_samples.json",
            "tests/artifacts/baselines/pathfind/pathfind_flow_field_samples.json"
        )
        expect_golden_text_match(
            evidence_output_dir("pathfind") .. "pathfind_hex_tilefield_trace.json",
            "tests/artifacts/baselines/pathfind/pathfind_hex_tilefield_trace.json"
        )
        expect_golden_text_match(
            evidence_output_dir("pathfind") .. "pathfind_iso_tilefield_trace.json",
            "tests/artifacts/baselines/pathfind/pathfind_iso_tilefield_trace.json"
        )
        expect_golden_text_match(
            evidence_output_dir("pathfind") .. "pathfind_weighted_route_trace.json",
            "tests/artifacts/baselines/pathfind/pathfind_weighted_route_trace.json"
        )
    end)
end)
test_summary()
