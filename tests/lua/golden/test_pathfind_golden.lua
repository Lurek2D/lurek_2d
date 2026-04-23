-- Golden test: pathfind

-- @description Covers suite: golden: pathfind evidence comparison.
describe("golden: pathfind evidence comparison", function()
    local OUT = evidence_output_dir("pathfind")
    local SAMP = "tests/samples/pathfind/"

    -- @golden
    -- @covers expect_golden_file_match
    -- @description Compares the pathfind PNG batch for astar, navgrid costs, flow field, and influence map outputs against the committed golden samples.
    xit("matches golden samples", function()
        expect_golden_file_match(evidence_output_dir("pathfind") .. "astar_basic.png", "tests/samples/pathfind/astar_basic.png")
        expect_golden_file_match(evidence_output_dir("pathfind") .. "navgrid_costs.png", "tests/samples/pathfind/navgrid_costs.png")
        expect_golden_file_match(evidence_output_dir("pathfind") .. "flow_field.png", "tests/samples/pathfind/flow_field.png")
        expect_golden_file_match(evidence_output_dir("pathfind") .. "influence_map.png", "tests/samples/pathfind/influence_map.png")
end)
end)



-- ================================================================
-- Merged from: test_pathfind_golden_grid.lua
-- ================================================================

-- Golden test: pathfinding          compare evidence output against golden samples

-- @description Covers suite: golden: pathfinding evidence comparison.
describe("golden: pathfinding evidence comparison", function()
    -- @golden
    -- @covers expect_golden_file_match
    -- @description Compares the generated pathfinding_grid.png evidence image against the committed pathfinding golden sample.
    xit("matches golden sample for pathfinding_grid.png", function()
        local evidence = evidence_output_dir("pathfind") .. "pathfinding_grid.png"
        local golden = "tests/samples/pathfinding/pathfinding_grid.png"
        expect_golden_file_match(evidence, golden)
    end)
end)

test_summary()
