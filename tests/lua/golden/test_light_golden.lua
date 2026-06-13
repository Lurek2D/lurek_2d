-- Golden test: light compare evidence output against golden samples

-- @describe golden: light evidence comparison
describe("golden: light evidence comparison", function()
    it("matches light baselines", function()
        expect_golden_file_match(
            evidence_output_dir("light") .. "light_color_mix.png",
            "tests/artifacts/baselines/light/light_color_mix.png"
        )
        expect_golden_file_match(
            evidence_output_dir("light") .. "light_cone_spotlight.png",
            "tests/artifacts/baselines/light/light_cone_spotlight.png"
        )
        expect_golden_file_match(
            evidence_output_dir("light") .. "light_falloff.png",
            "tests/artifacts/baselines/light/light_falloff.png"
        )
        expect_golden_file_match(
            evidence_output_dir("light") .. "light_normal_map.png",
            "tests/artifacts/baselines/light/light_normal_map.png"
        )
        expect_golden_file_match(
            evidence_output_dir("light") .. "light_shadow_occlusion.png",
            "tests/artifacts/baselines/light/light_shadow_occlusion.png"
        )
        expect_golden_file_match(
            evidence_output_dir("light") .. "light_spotlight_sweep.gif",
            "tests/artifacts/baselines/light/light_spotlight_sweep.gif"
        )
    end)
end)
test_summary()
