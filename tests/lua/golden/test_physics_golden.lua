-- Golden test: physics â€” compare evidence output against golden samples

-- @description Covers suite: golden: physics evidence comparison.
describe("golden: physics evidence comparison", function()
    -- @golden
    -- @covers expect_golden_file_match
    -- @description Compares the generated draw_debug.png physics evidence image against the committed golden sample.
    it("matches golden sample for draw_debug.png", function()
        local evidence = evidence_output_dir("physics") .. "draw_debug.png"
        local golden = "tests/lua/golden/samples/physics/draw_debug.png"
        expect_golden_file_match(evidence, golden)
    end)
end)
test_summary()
