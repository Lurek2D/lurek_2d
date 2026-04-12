-- Golden test: graph â€” compare evidence output against golden samples
-- @golden

-- @description Covers suite: golden: graph evidence comparison.
describe("golden: graph evidence comparison", function()
    -- @golden
    -- @covers expect_golden_file_match
    -- @description Compares the generated graph_traversal.png evidence image against the committed graph golden sample.
    it("matches golden sample for graph_traversal.png", function()
        local evidence = evidence_output_dir("graph") .. "graph_traversal.png"
        local golden = "tests/lua/golden/samples/graph/graph_traversal.png"
        expect_golden_file_match(evidence, golden)
    end)
end)

test_summary()
