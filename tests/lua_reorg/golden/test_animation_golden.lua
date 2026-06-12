-- Golden test: animation compare evidence output against golden samples

-- @describe golden: animation evidence comparison
describe("golden: animation evidence comparison", function()
    it("matches animation frame and preview baselines", function()
        expect_golden_file_match(
            evidence_output_dir("animation") .. "animation_current_frame_walk.png",
            "tests/artifacts/baselines/animation/animation_current_frame_walk.png"
        )
        expect_golden_file_match(
            evidence_output_dir("animation") .. "animation_clip_preview_grid.png",
            "tests/artifacts/baselines/animation/animation_clip_preview_grid.png"
        )
        expect_golden_text_match(
            evidence_output_dir("animation") .. "animation_blend_crossfade_state.txt",
            "tests/artifacts/baselines/animation/animation_blend_crossfade_state.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("animation") .. "animation_curve_comparison.png",
            "tests/artifacts/baselines/animation/animation_curve_comparison.png"
        )
        expect_golden_text_match(
            evidence_output_dir("animation") .. "animation_state_machine_transition_trace.txt",
            "tests/artifacts/baselines/animation/animation_state_machine_transition_trace.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("animation") .. "animation_walk_cycle_preview.gif",
            "tests/artifacts/baselines/animation/animation_walk_cycle_preview.gif"
        )
    end)
end)
test_summary()
