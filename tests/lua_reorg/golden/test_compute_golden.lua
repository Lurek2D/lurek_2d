-- Canonical golden file for lurek.compute evidence comparisons.

-- @describe golden: compute evidence comparison
describe("golden: compute evidence comparison", function()
    it("matches compute_ndarray_fill_summary.txt", function()
        expect_golden_text_match(
            evidence_output_dir("compute") .. "compute_ndarray_fill_summary.txt",
            "tests/artifacts/baselines/compute/compute_ndarray_fill_summary.txt"
        )
    end)
end)
test_summary()
