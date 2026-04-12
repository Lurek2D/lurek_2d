-- Golden test: math compare-only evidence validation.

-- @description Compares only pre-generated math evidence artifacts against committed math golden samples.
describe("golden: math Math constants and trig identities", function()
    -- @golden
    -- @description Compares the evidence-layer easing gallery PNGs against the committed math golden samples without generating any new content here.
    it("matches golden sample", function()
        expect_golden_file_match(evidence_output_dir("math") .. "all_curves_gallery.png", "tests/lua/golden/samples/math/all_curves_gallery.png")
        expect_golden_file_match(evidence_output_dir("math") .. "comparison_chart.png", "tests/lua/golden/samples/math/comparison_chart.png")
    end)
end)
test_summary()
