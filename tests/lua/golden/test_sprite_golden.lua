-- Golden test: sprite compare evidence output against golden samples.

-- @describe golden: sprite evidence comparison
describe("golden: sprite evidence comparison", function()
    it("matches sprite visual baselines", function()
        expect_golden_file_match(
            evidence_output_dir("sprite") .. "sprite_sheet_groups.png",
            "tests/artifacts/baselines/sprite/sprite_sheet_groups.png"
        )
        expect_golden_file_match(
            evidence_output_dir("sprite") .. "sprite_animator_clip_playback.gif",
            "tests/artifacts/baselines/sprite/sprite_animator_clip_playback.gif"
        )
        expect_golden_file_match(
            evidence_output_dir("sprite") .. "sprite_atlas_regions_flips.png",
            "tests/artifacts/baselines/sprite/sprite_atlas_regions_flips.png"
        )
        expect_golden_file_match(
            evidence_output_dir("sprite") .. "sprite_packer_nine_slice.png",
            "tests/artifacts/baselines/sprite/sprite_packer_nine_slice.png"
        )
        expect_golden_file_match(
            evidence_output_dir("sprite") .. "sprite_lit_normal_state.png",
            "tests/artifacts/baselines/sprite/sprite_lit_normal_state.png"
        )
    end)
end)

test_summary()
