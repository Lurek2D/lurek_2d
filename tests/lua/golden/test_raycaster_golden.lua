-- Golden test: raycaster

-- @description Covers suite: golden: raycaster evidence comparison.
describe("golden: raycaster evidence comparison", function()
    local OUT = evidence_output_dir("raycaster")
    local SAMP = "tests/lua/golden/samples/raycaster/"

    -- @golden
    -- @covers expect_golden_file_match
    -- @description Compares the raycaster PNG batch for top-down, depth-column, and line-of-sight outputs against the committed golden samples.
    it("matches golden samples", function()
        expect_golden_file_match(evidence_output_dir("raycaster") .. "top_down_view.png", "tests/lua/golden/samples/raycaster/top_down_view.png")
        expect_golden_file_match(evidence_output_dir("raycaster") .. "depth_column_view.png", "tests/lua/golden/samples/raycaster/depth_column_view.png")
        expect_golden_file_match(evidence_output_dir("raycaster") .. "line_of_sight.png", "tests/lua/golden/samples/raycaster/line_of_sight.png")
end)
end)
test_summary()
