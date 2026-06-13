-- Canonical golden file for lurek.dataframe evidence comparisons.

-- @describe golden: dataframe evidence comparison
describe("golden: dataframe evidence comparison", function()
    it("matches dataframe_csv_statistics.txt", function()
        expect_golden_text_match(
            evidence_output_dir("dataframe") .. "dataframe_csv_statistics.txt",
            "tests/artifacts/baselines/dataframe/dataframe_csv_statistics.txt"
        )
    end)
end)
test_summary()
