-- Canonical golden file for lurek.color evidence comparisons.

-- @describe golden: color evidence comparison
describe("golden: color evidence comparison", function()
    it("matches color evidence baselines", function()
        expect_golden_file_match(evidence_output_dir("color") .. "color_base_a.png", "tests/artifacts/baselines/color/color_base_a.png")
        expect_golden_file_match(evidence_output_dir("color") .. "color_base_b.png", "tests/artifacts/baselines/color/color_base_b.png")
        expect_golden_file_match(evidence_output_dir("color") .. "color_blend_additive.png", "tests/artifacts/baselines/color/color_blend_additive.png")
        expect_golden_file_match(evidence_output_dir("color") .. "color_blend_alpha_blend.png", "tests/artifacts/baselines/color/color_blend_alpha_blend.png")
        expect_golden_file_match(evidence_output_dir("color") .. "color_blend_invert_a.png", "tests/artifacts/baselines/color/color_blend_invert_a.png")
        expect_golden_file_match(evidence_output_dir("color") .. "color_blend_multiply.png", "tests/artifacts/baselines/color/color_blend_multiply.png")
        expect_golden_file_match(evidence_output_dir("color") .. "color_blend_overlay.png", "tests/artifacts/baselines/color/color_blend_overlay.png")
        expect_golden_file_match(evidence_output_dir("color") .. "color_blend_screen.png", "tests/artifacts/baselines/color/color_blend_screen.png")
        expect_golden_file_match(evidence_output_dir("color") .. "color_hsl_hue_band.png", "tests/artifacts/baselines/color/color_hsl_hue_band.png")
        expect_golden_text_match(evidence_output_dir("color") .. "color_conversion_trace.txt", "tests/artifacts/baselines/color/color_conversion_trace.txt")
    end)
end)
test_summary()
