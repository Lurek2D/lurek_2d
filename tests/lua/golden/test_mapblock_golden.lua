-- Canonical golden file for lurek.mapblock evidence comparisons.

-- @describe golden: mapblock evidence comparison
describe("golden: mapblock evidence comparison", function()
    it("matches mapblock evidence baselines", function()
        expect_golden_file_match(evidence_output_dir("mapblock") .. "mapblock_edge_interior_constraints.png", "tests/artifacts/baselines/mapblock/mapblock_edge_interior_constraints.png")
        expect_golden_file_match(evidence_output_dir("mapblock") .. "mapblock_generation_timeline.gif", "tests/artifacts/baselines/mapblock/mapblock_generation_timeline.gif")
        expect_golden_file_match(evidence_output_dir("mapblock") .. "mapblock_multilevel_layers.png", "tests/artifacts/baselines/mapblock/mapblock_multilevel_layers.png")
        expect_golden_file_match(evidence_output_dir("mapblock") .. "mapblock_result_contract_histogram.png", "tests/artifacts/baselines/mapblock/mapblock_result_contract_histogram.png")
        expect_golden_file_match(evidence_output_dir("mapblock") .. "mapblock_scripted_paint_diagnostics.png", "tests/artifacts/baselines/mapblock/mapblock_scripted_paint_diagnostics.png")
        expect_golden_file_match(evidence_output_dir("mapblock") .. "mapblock_script_pipeline_storyboard.png", "tests/artifacts/baselines/mapblock/mapblock_script_pipeline_storyboard.png")
        expect_golden_file_match(evidence_output_dir("mapblock") .. "mapblock_socket_constraints.png", "tests/artifacts/baselines/mapblock/mapblock_socket_constraints.png")
        expect_golden_file_match(evidence_output_dir("mapblock") .. "mapblock_solver_footprints.png", "tests/artifacts/baselines/mapblock/mapblock_solver_footprints.png")
        expect_golden_file_match(evidence_output_dir("mapblock") .. "mapblock_strategic_tactical_split.png", "tests/artifacts/baselines/mapblock/mapblock_strategic_tactical_split.png")
        expect_golden_file_match(evidence_output_dir("mapblock") .. "mapblock_transform_export.png", "tests/artifacts/baselines/mapblock/mapblock_transform_export.png")
        expect_golden_file_match(evidence_output_dir("mapblock") .. "mapblock_two_level_cutaway.png", "tests/artifacts/baselines/mapblock/mapblock_two_level_cutaway.png")
    end)
end)

test_summary()
