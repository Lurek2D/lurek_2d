-- Golden test: dataframe compare-only evidence validation.

-- @description Compares dataframe_golden.txt emitted by the evidence layer against the committed deterministic DataFrame sample.
describe("golden: dataframe DataFrame deterministic statistics", function()
    -- @golden
    -- @description Compares dataframe_golden.txt from the evidence layer against the committed DataFrame sample.
    it("matches golden sample", function()
        local evidence = "save/golden_text/dataframe/dataframe_golden.txt"
        local golden = "tests/samples/dataframe/dataframe_golden.txt"
        expect_golden_text_match(evidence, golden)
    end)
end)

test_summary()
