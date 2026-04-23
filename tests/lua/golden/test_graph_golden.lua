-- Golden test: graph          compare evidence output against golden samples

-- @description Covers suite: golden: graph evidence comparison.
describe("golden: graph evidence comparison", function()
    -- @golden
    -- @covers expect_golden_file_match
    -- @description Compares the generated graph_traversal.png evidence image against the committed graph golden sample.
    xit("matches golden sample for graph_traversal.png", function()
        local evidence = evidence_output_dir("graph") .. "graph_traversal.png"
        local golden = "tests/samples/graph/graph_traversal.png"
        expect_golden_file_match(evidence, golden)
    end)
end)

test_summary()
