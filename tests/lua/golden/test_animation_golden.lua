-- Golden test: animation compare evidence output against golden samples

-- @describe golden: animation evidence comparison
describe("golden: animation evidence comparison", function()
    it("matches animation frame and preview baselines", function()
        expect_golden_file_match(
            evidence_output_dir("animation") .. "animation_current_frame_walk.png",
            "tests/artifacts/baselines/animation/animation_current_frame_walk.png"
        )
        expect_golden_file_match(
            evidence_output_dir("animation") .. "animation_clip_preview_frames.gif",
            "tests/artifacts/baselines/animation/animation_clip_preview_frames.gif"
        )
        expect_golden_file_match(
            evidence_output_dir("animation") .. "animation_crossfade_transition.gif",
            "tests/artifacts/baselines/animation/animation_crossfade_transition.gif"
        )
        expect_golden_file_match(
            evidence_output_dir("animation") .. "animation_curve_linear.png",
            "tests/artifacts/baselines/animation/animation_curve_linear.png"
        )
        expect_golden_file_match(
            evidence_output_dir("animation") .. "animation_curve_eased.png",
            "tests/artifacts/baselines/animation/animation_curve_eased.png"
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
