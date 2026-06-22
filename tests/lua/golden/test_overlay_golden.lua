-- Golden test: overlay compare evidence output against golden samples

-- @describe golden: overlay evidence comparison
describe("golden: overlay evidence comparison", function()
    it("matches overlay baselines", function()
        expect_golden_file_match(
            evidence_output_dir("overlay") .. "overlay_screen_effects_timeline.gif",
            "tests/artifacts/baselines/overlay/overlay_screen_effects_timeline.gif"
        )
        expect_golden_file_match(
            evidence_output_dir("overlay") .. "overlay_environment_layers.gif",
            "tests/artifacts/baselines/overlay/overlay_environment_layers.gif"
        )
        expect_golden_file_match(
            evidence_output_dir("overlay") .. "overlay_transition_modes.gif",
            "tests/artifacts/baselines/overlay/overlay_transition_modes.gif"
        )
        expect_golden_file_match(
            evidence_output_dir("overlay") .. "overlay_weather_wind_field.png",
            "tests/artifacts/baselines/overlay/overlay_weather_wind_field.png"
        )
        expect_golden_file_match(
            evidence_output_dir("overlay") .. "overlay_transition_mask_atlas.png",
            "tests/artifacts/baselines/overlay/overlay_transition_mask_atlas.png"
        )
        expect_golden_file_match(
            evidence_output_dir("overlay") .. "overlay_atmosphere_compositor.png",
            "tests/artifacts/baselines/overlay/overlay_atmosphere_compositor.png"
        )
        expect_golden_file_match(
            evidence_output_dir("overlay") .. "overlay_storm_front_wind_sweep.gif",
            "tests/artifacts/baselines/overlay/overlay_storm_front_wind_sweep.gif"
        )
        expect_golden_file_match(
            evidence_output_dir("overlay") .. "overlay_flash_shake_fade_composite.gif",
            "tests/artifacts/baselines/overlay/overlay_flash_shake_fade_composite.gif"
        )
        expect_golden_text_match(
            evidence_output_dir("overlay") .. "overlay_weather_state_trace.json",
            "tests/artifacts/baselines/overlay/overlay_weather_state_trace.json"
        )
    end)
end)

test_summary()
