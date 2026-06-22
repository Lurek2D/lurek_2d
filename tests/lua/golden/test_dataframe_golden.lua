-- Canonical golden file for lurek.dataframe evidence comparisons.

-- @describe golden: dataframe evidence comparison
describe("golden: dataframe evidence comparison", function()
    it("matches dataframe evidence baselines", function()
        expect_golden_text_match(
            evidence_output_dir("dataframe") .. "dataframe_csv_statistics.txt",
            "tests/artifacts/baselines/dataframe/dataframe_csv_statistics.txt"
        )
        expect_golden_text_match(
            evidence_output_dir("dataframe") .. "dataframe_transform_snapshot.txt",
            "tests/artifacts/baselines/dataframe/dataframe_transform_snapshot.txt"
        )
        expect_golden_text_match(
            evidence_output_dir("dataframe") .. "dataframe_descriptive_statistics.txt",
            "tests/artifacts/baselines/dataframe/dataframe_descriptive_statistics.txt"
        )
        expect_golden_text_match(
            evidence_output_dir("dataframe") .. "dataframe_serialization_snapshot.txt",
            "tests/artifacts/baselines/dataframe/dataframe_serialization_snapshot.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("dataframe") .. "dataframe_value_bars.png",
            "tests/artifacts/baselines/dataframe/dataframe_value_bars.png"
        )
        expect_golden_text_match(
            evidence_output_dir("dataframe") .. "dataframe_structure_query_trace.txt",
            "tests/artifacts/baselines/dataframe/dataframe_structure_query_trace.txt"
        )
        expect_golden_text_match(
            evidence_output_dir("dataframe") .. "dataframe_grouped_kpi_pipeline.txt",
            "tests/artifacts/baselines/dataframe/dataframe_grouped_kpi_pipeline.txt"
        )
        expect_golden_text_match(
            evidence_output_dir("dataframe") .. "dataframe_window_risk_analysis.txt",
            "tests/artifacts/baselines/dataframe/dataframe_window_risk_analysis.txt"
        )
        expect_golden_text_match(
            evidence_output_dir("dataframe") .. "dataframe_join_pivot_query_trace.txt",
            "tests/artifacts/baselines/dataframe/dataframe_join_pivot_query_trace.txt"
        )
        expect_golden_text_match(
            evidence_output_dir("dataframe") .. "dataframe_lazy_feature_pipeline.txt",
            "tests/artifacts/baselines/dataframe/dataframe_lazy_feature_pipeline.txt"
        )
        expect_golden_text_match(
            evidence_output_dir("dataframe") .. "dataframe_vecframe_compute_trace.txt",
            "tests/artifacts/baselines/dataframe/dataframe_vecframe_compute_trace.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("dataframe") .. "dataframe_correlation_matrix_heatmap.png",
            "tests/artifacts/baselines/dataframe/dataframe_correlation_matrix_heatmap.png"
        )
    end)
end)
test_summary()
