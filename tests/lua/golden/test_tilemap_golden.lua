-- Golden test: tilemap â€” compare evidence output against golden samples
-- @golden

-- @description Covers suite: golden: tilemap evidence comparison.
describe("golden: tilemap evidence comparison", function()
    -- @golden
    -- @covers expect_golden_file_match
    -- @description Compares the generated tilemap_render.png and world_to_tile.png evidence images against the committed tilemap golden samples.
    it("matches golden sample for tilemap_render.png", function()
        local evidence = evidence_output_dir("tilemap") .. "tilemap_render.png"
        local golden = "tests/lua/golden/samples/tilemap/tilemap_render.png"
        expect_golden_file_match(evidence, golden)
        expect_golden_file_match(evidence_output_dir("tilemap") .. "world_to_tile.png", "tests/lua/golden/samples/tilemap/world_to_tile.png")
end)
end)

test_summary()
