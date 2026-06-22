-- Golden test: flownet

-- @describe golden: flownet evidence comparison
describe("golden: flownet evidence comparison", function()
    it("matches golden samples", function()
        expect_golden_file_match(
            evidence_output_dir("flownet") .. "flownet_topology_algorithms.png",
            "tests/artifacts/baselines/flownet/flownet_topology_algorithms.png"
        )
        expect_golden_file_match(
            evidence_output_dir("flownet") .. "flownet_route_constraints.png",
            "tests/artifacts/baselines/flownet/flownet_route_constraints.png"
        )
        expect_golden_file_match(
            evidence_output_dir("flownet") .. "flownet_transit_capacity.png",
            "tests/artifacts/baselines/flownet/flownet_transit_capacity.png"
        )
        expect_golden_file_match(
            evidence_output_dir("flownet") .. "flownet_queue_overflow.png",
            "tests/artifacts/baselines/flownet/flownet_queue_overflow.png"
        )
        expect_golden_file_match(
            evidence_output_dir("flownet") .. "flownet_supply_conversion.png",
            "tests/artifacts/baselines/flownet/flownet_supply_conversion.png"
        )
    end)
end)

test_summary()
