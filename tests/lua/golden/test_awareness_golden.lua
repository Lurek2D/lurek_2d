-- Golden test: awareness

-- @describe golden: awareness evidence comparison
describe("golden: awareness evidence comparison", function()
    it("matches golden samples", function()
        expect_golden_file_match(
            evidence_output_dir("awareness") .. "awareness_fov_blockers.png",
            "tests/artifacts/baselines/awareness/awareness_fov_blockers.png"
        )
        expect_golden_file_match(
            evidence_output_dir("awareness") .. "awareness_hex_cone_share.png",
            "tests/artifacts/baselines/awareness/awareness_hex_cone_share.png"
        )
        expect_golden_file_match(
            evidence_output_dir("awareness") .. "awareness_region_state_matrix.png",
            "tests/artifacts/baselines/awareness/awareness_region_state_matrix.png"
        )
        expect_golden_text_match(
            evidence_output_dir("awareness") .. "awareness_tilefield_action_trace.txt",
            "tests/artifacts/baselines/awareness/awareness_tilefield_action_trace.txt"
        )
    end)
end)
test_summary()
