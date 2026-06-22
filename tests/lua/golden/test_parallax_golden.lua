-- Golden test: parallax compare evidence output against golden samples.

-- @describe golden: parallax evidence comparison
describe("golden: parallax evidence comparison", function()
    it("matches parallax visual baselines", function()
        expect_golden_file_match(
            evidence_output_dir("parallax") .. "parallax_depth_scroll_factors.png",
            "tests/artifacts/baselines/parallax/parallax_depth_scroll_factors.png"
        )
        expect_golden_file_match(
            evidence_output_dir("parallax") .. "parallax_tiling_coverage_stats.png",
            "tests/artifacts/baselines/parallax/parallax_tiling_coverage_stats.png"
        )
        expect_golden_file_match(
            evidence_output_dir("parallax") .. "parallax_z_sorted_set.png",
            "tests/artifacts/baselines/parallax/parallax_z_sorted_set.png"
        )
        expect_golden_file_match(
            evidence_output_dir("parallax") .. "parallax_effect_tint_motion_stretch.png",
            "tests/artifacts/baselines/parallax/parallax_effect_tint_motion_stretch.png"
        )
        expect_golden_file_match(
            evidence_output_dir("parallax") .. "parallax_preset_layer_profiles.png",
            "tests/artifacts/baselines/parallax/parallax_preset_layer_profiles.png"
        )
        expect_golden_file_match(
            evidence_output_dir("parallax") .. "parallax_autoscroll_motion.gif",
            "tests/artifacts/baselines/parallax/parallax_autoscroll_motion.gif"
        )
    end)
end)

test_summary()
