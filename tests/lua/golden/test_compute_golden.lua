-- Golden test: compute compare-only evidence validation.

-- @description Compares the committed compute sample against compute_golden.txt emitted by the evidence layer.
describe("golden: compute NdArray deterministic operations", function()
    -- @golden
    -- @description Compares compute_golden.txt from the evidence layer against the committed deterministic compute sample.
    it("matches golden sample", function()
        local evidence = "save/golden_text/compute/compute_golden.txt"
        local golden = "tests/lua/golden/samples/compute/compute_golden.txt"
        expect_golden_text_match(evidence, golden)
    end)
end)
test_summary()
