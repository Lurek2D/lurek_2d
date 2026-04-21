-- Golden test: minimap

-- @description Covers suite: golden: minimap evidence comparison.
describe("golden: minimap evidence comparison", function()
    local OUT = evidence_output_dir("minimap")
    local SAMP = "tests/samples/minimap/"

    -- @golden
    -- @covers expect_golden_file_match
    -- @description Compares the minimap PNG batch for terrain, fog of war, object markers, and political mode against the committed golden samples.
    it("matches golden samples", function()
        expect_golden_file_match(evidence_output_dir("minimap") .. "terrain.png", "tests/samples/minimap/terrain.png")
        expect_golden_file_match(evidence_output_dir("minimap") .. "fog_of_war.png", "tests/samples/minimap/fog_of_war.png")
        expect_golden_file_match(evidence_output_dir("minimap") .. "objects_markers.png", "tests/samples/minimap/objects_markers.png")
        expect_golden_file_match(evidence_output_dir("minimap") .. "political_mode.png", "tests/samples/minimap/political_mode.png")
end)
end)

test_summary()
