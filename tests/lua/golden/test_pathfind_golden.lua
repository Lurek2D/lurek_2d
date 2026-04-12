-- Golden test: pathfind

-- @description Covers suite: golden: pathfind evidence comparison.
describe("golden: pathfind evidence comparison", function()
    local OUT = evidence_output_dir("pathfind")
    local SAMP = "tests/lua/golden/samples/pathfind/"

    -- @golden
    -- @covers expect_golden_file_match
    -- @description Compares the pathfind PNG batch for astar, navgrid costs, flow field, and influence map outputs against the committed golden samples.
    it("matches golden samples", function()
        expect_golden_file_match(evidence_output_dir("pathfind") .. "astar_basic.png", "tests/lua/golden/samples/pathfind/astar_basic.png")
        expect_golden_file_match(evidence_output_dir("pathfind") .. "navgrid_costs.png", "tests/lua/golden/samples/pathfind/navgrid_costs.png")
        expect_golden_file_match(evidence_output_dir("pathfind") .. "flow_field.png", "tests/lua/golden/samples/pathfind/flow_field.png")
        expect_golden_file_match(evidence_output_dir("pathfind") .. "influence_map.png", "tests/lua/golden/samples/pathfind/influence_map.png")
end)
end)
test_summary()
