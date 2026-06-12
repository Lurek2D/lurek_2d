-- Golden test: overlay compare evidence output against golden samples

-- @describe golden: overlay evidence comparison
describe("golden: overlay evidence comparison", function()
    it("matches overlay baselines", function()
        expect_golden_file_match(
            evidence_output_dir("overlay") .. "image_postfx_strip.png",
            "tests/artifacts/baselines/overlay/image_postfx_strip.png"
        )
        expect_golden_text_match(
            evidence_output_dir("overlay") .. "overlay_draw_to_image.json",
            "tests/artifacts/baselines/overlay/overlay_draw_to_image.json"
        )
        expect_golden_file_match(
            evidence_output_dir("overlay") .. "overlay_image_postfx_strip.png",
            "tests/artifacts/baselines/overlay/overlay_image_postfx_strip.png"
        )
        expect_golden_text_match(
            evidence_output_dir("overlay") .. "overlay_timeline.json",
            "tests/artifacts/baselines/overlay/overlay_timeline.json"
        )
    end)
end)
test_summary()
