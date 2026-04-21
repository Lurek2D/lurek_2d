-- Golden test: animation â€” compare evidence output against golden samples

-- @description Covers suite: golden: animation evidence comparison.
describe("golden: animation evidence comparison", function()
    -- @golden
    -- @covers expect_golden_file_match
    -- @description Compares the generated sprite_frames.png animation evidence image against the committed golden sample.
    it("matches golden sample for sprite_frames.png", function()
        local evidence = evidence_output_dir("animation") .. "sprite_frames.png"
        local golden = "tests/samples/animation/sprite_frames.png"
        expect_golden_file_match(evidence, golden)
    end)
end)

test_summary()
