-- Golden test: layout

-- @describe golden: layout evidence comparison
describe("golden: layout evidence comparison", function()
    it("matches golden samples", function()
        expect_golden_file_match(
            evidence_output_dir("layout") .. "layout_tree_hierarchy.png",
            "tests/artifacts/baselines/layout/layout_tree_hierarchy.png"
        )
        expect_golden_file_match(
            evidence_output_dir("layout") .. "layout_dag_pipeline.png",
            "tests/artifacts/baselines/layout/layout_dag_pipeline.png"
        )
        expect_golden_file_match(
            evidence_output_dir("layout") .. "layout_force_cluster.png",
            "tests/artifacts/baselines/layout/layout_force_cluster.png"
        )
        expect_golden_file_match(
            evidence_output_dir("layout") .. "layout_snap_to_grid.png",
            "tests/artifacts/baselines/layout/layout_snap_to_grid.png"
        )
        expect_golden_file_match(
            evidence_output_dir("layout") .. "layout_center_in_area.png",
            "tests/artifacts/baselines/layout/layout_center_in_area.png"
        )
        expect_golden_file_match(
            evidence_output_dir("layout") .. "layout_quality_metrics.txt",
            "tests/artifacts/baselines/layout/layout_quality_metrics.txt"
        )
    end)
end)

test_summary()
