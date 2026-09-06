-- Canonical golden file for lurek.province evidence comparisons.

-- @describe golden: province evidence comparison
describe("golden: province evidence comparison", function()
    it("matches province evidence baselines", function()
        expect_golden_file_match(evidence_output_dir("province") .. "province_border_segments.png", "tests/artifacts/baselines/province/province_border_segments.png")
        expect_golden_file_match(evidence_output_dir("province") .. "province_capitals_labels_centroids.png", "tests/artifacts/baselines/province/province_capitals_labels_centroids.png")
        expect_golden_file_match(evidence_output_dir("province") .. "province_revision_timeline.gif", "tests/artifacts/baselines/province/province_revision_timeline.gif")
        expect_golden_file_match(evidence_output_dir("province") .. "province_route_trace.png", "tests/artifacts/baselines/province/province_route_trace.png")
        expect_golden_file_match(evidence_output_dir("province") .. "province_sanitized_map.png", "tests/artifacts/baselines/province/province_sanitized_map.png")
        expect_golden_file_match(evidence_output_dir("province") .. "province_span_runs.png", "tests/artifacts/baselines/province/province_span_runs.png")
        expect_golden_file_match(evidence_output_dir("province") .. "province_strategy_modes.png", "tests/artifacts/baselines/province/province_strategy_modes.png")
        expect_golden_file_match(evidence_output_dir("province") .. "province_zoom_pick_view.png", "tests/artifacts/baselines/province/province_zoom_pick_view.png")
        expect_golden_file_match(evidence_output_dir("province") .. "province_tiled_polygon_commands.png", "tests/artifacts/baselines/province/province_tiled_polygon_commands.png")
        expect_golden_file_match(evidence_output_dir("province") .. "province_tiled_polygon_gpu.png", "tests/artifacts/baselines/province/province_tiled_polygon_gpu.png")
        expect_golden_file_match(evidence_output_dir("province") .. "province_tiled_polygon_segments.png", "tests/artifacts/baselines/province/province_tiled_polygon_segments.png")
    end)
end)

test_summary()
