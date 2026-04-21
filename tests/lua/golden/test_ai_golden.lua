-- Golden test: ai compare-only evidence validation.

-- @description Compares the committed AI golden sample against the AI text evidence produced in the evidence layer.
describe("golden: ai AI state machine transitions", function()
    -- @golden
    -- @description Compares ai_golden.txt from the evidence layer against the committed AI sample without generating any new content in the golden suite.
    it("matches golden sample", function()
        local evidence = "save/golden_text/ai/ai_golden.txt"
        local golden = "tests/samples/ai/ai_golden.txt"
        expect_golden_text_match(evidence, golden)
    end)
end)

test_summary()
