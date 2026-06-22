-- Canonical golden file for lurek.charts evidence comparisons.

-- @describe golden: charts evidence comparison
describe("golden: charts evidence comparison", function()
    it("matches charts visual baselines", function()
        expect_golden_file_match(
            evidence_output_dir("charts") .. "charts_line_revenue_trend.png",
            "tests/artifacts/baselines/charts/charts_line_revenue_trend.png"
        )
        expect_golden_file_match(
            evidence_output_dir("charts") .. "charts_bar_category_revenue.png",
            "tests/artifacts/baselines/charts/charts_bar_category_revenue.png"
        )
        expect_golden_file_match(
            evidence_output_dir("charts") .. "charts_area_layered_usage.png",
            "tests/artifacts/baselines/charts/charts_area_layered_usage.png"
        )
        expect_golden_file_match(
            evidence_output_dir("charts") .. "charts_scatter_player_scores.png",
            "tests/artifacts/baselines/charts/charts_scatter_player_scores.png"
        )
        expect_golden_file_match(
            evidence_output_dir("charts") .. "charts_pie_market_share.png",
            "tests/artifacts/baselines/charts/charts_pie_market_share.png"
        )
        expect_golden_file_match(
            evidence_output_dir("charts") .. "charts_histogram_latency_distribution.png",
            "tests/artifacts/baselines/charts/charts_histogram_latency_distribution.png"
        )
        expect_golden_file_match(
            evidence_output_dir("charts") .. "charts_heatmap_region_load.png",
            "tests/artifacts/baselines/charts/charts_heatmap_region_load.png"
        )
        expect_golden_file_match(
            evidence_output_dir("charts") .. "charts_dataframe_line.png",
            "tests/artifacts/baselines/charts/charts_dataframe_line.png"
        )
        expect_golden_file_match(
            evidence_output_dir("charts") .. "charts_dataframe_heatmap.png",
            "tests/artifacts/baselines/charts/charts_dataframe_heatmap.png"
        )
        expect_golden_file_match(
            evidence_output_dir("charts") .. "charts_dataframe_histogram.png",
            "tests/artifacts/baselines/charts/charts_dataframe_histogram.png"
        )
        expect_golden_file_match(
            evidence_output_dir("charts") .. "charts_dataframe_pie.png",
            "tests/artifacts/baselines/charts/charts_dataframe_pie.png"
        )
        expect_golden_text_match(
            evidence_output_dir("charts") .. "charts_nearest_trace.json",
            "tests/artifacts/baselines/charts/charts_nearest_trace.json"
        )
    end)
end)
test_summary()
