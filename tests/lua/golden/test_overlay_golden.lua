-- Golden test: overlay compare evidence output against golden samples

-- @describe golden: overlay evidence comparison
describe("golden: overlay evidence comparison", function()
    it("matches overlay baselines", function()
        expect_golden_file_match(
            evidence_output_dir("overlay") .. "overlay_dawn_fog_preview.png",
            "tests/artifacts/baselines/overlay/overlay_dawn_fog_preview.png"
        )
        expect_golden_text_match(
            evidence_output_dir("overlay") .. "overlay_draw_to_image.json",
            "tests/artifacts/baselines/overlay/overlay_draw_to_image.json"
        )
        expect_golden_file_match(
            evidence_output_dir("overlay") .. "overlay_dusk_heat_preview.png",
            "tests/artifacts/baselines/overlay/overlay_dusk_heat_preview.png"
        )
        expect_golden_file_match(
            evidence_output_dir("overlay") .. "overlay_fade_preview.png",
            "tests/artifacts/baselines/overlay/overlay_fade_preview.png"
        )
        expect_golden_file_match(
            evidence_output_dir("overlay") .. "overlay_flash_preview.png",
            "tests/artifacts/baselines/overlay/overlay_flash_preview.png"
        )
        expect_golden_file_match(
            evidence_output_dir("overlay") .. "overlay_lightning_preview.png",
            "tests/artifacts/baselines/overlay/overlay_lightning_preview.png"
        )
        expect_golden_file_match(
            evidence_output_dir("overlay") .. "overlay_night_snow_preview.png",
            "tests/artifacts/baselines/overlay/overlay_night_snow_preview.png"
        )
        expect_golden_file_match(
            evidence_output_dir("overlay") .. "overlay_noon_rain_preview.png",
            "tests/artifacts/baselines/overlay/overlay_noon_rain_preview.png"
        )
        expect_golden_file_match(
            evidence_output_dir("overlay") .. "overlay_runtime_phase_heatmap.png",
            "tests/artifacts/baselines/overlay/overlay_runtime_phase_heatmap.png"
        )
        expect_golden_file_match(
            evidence_output_dir("overlay") .. "overlay_runtime_signal.png",
            "tests/artifacts/baselines/overlay/overlay_runtime_signal.png"
        )
        expect_golden_file_match(
            evidence_output_dir("overlay") .. "overlay_runtime_summary.png",
            "tests/artifacts/baselines/overlay/overlay_runtime_summary.png"
        )
        expect_golden_text_match(
            evidence_output_dir("overlay") .. "overlay_timeline.json",
            "tests/artifacts/baselines/overlay/overlay_timeline.json"
        )
    end)
end)
test_summary()
