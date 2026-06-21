-- Golden test: animation compare evidence output against golden samples

-- @describe golden: animation evidence comparison
describe("golden: animation evidence comparison", function()
    it("matches animation frame and preview baselines", function()
        expect_golden_file_match(
            evidence_output_dir("animation") .. "animation_current_frame_walk.png",
            "tests/artifacts/baselines/animation/animation_current_frame_walk.png"
        )
        expect_golden_file_match(
            evidence_output_dir("animation") .. "animation_clip_preview_frame_01.png",
            "tests/artifacts/baselines/animation/animation_clip_preview_frame_01.png"
        )
        expect_golden_file_match(
            evidence_output_dir("animation") .. "animation_clip_preview_frame_02.png",
            "tests/artifacts/baselines/animation/animation_clip_preview_frame_02.png"
        )
        expect_golden_file_match(
            evidence_output_dir("animation") .. "animation_clip_preview_frame_03.png",
            "tests/artifacts/baselines/animation/animation_clip_preview_frame_03.png"
        )
        expect_golden_file_match(
            evidence_output_dir("animation") .. "animation_clip_preview_frame_04.png",
            "tests/artifacts/baselines/animation/animation_clip_preview_frame_04.png"
        )
        expect_golden_file_match(
            evidence_output_dir("animation") .. "animation_clip_preview_frame_05.png",
            "tests/artifacts/baselines/animation/animation_clip_preview_frame_05.png"
        )
        expect_golden_file_match(
            evidence_output_dir("animation") .. "animation_clip_preview_frame_06.png",
            "tests/artifacts/baselines/animation/animation_clip_preview_frame_06.png"
        )
        expect_golden_file_match(
            evidence_output_dir("animation") .. "animation_clip_preview_frame_07.png",
            "tests/artifacts/baselines/animation/animation_clip_preview_frame_07.png"
        )
        expect_golden_file_match(
            evidence_output_dir("animation") .. "animation_clip_preview_frame_08.png",
            "tests/artifacts/baselines/animation/animation_clip_preview_frame_08.png"
        )
        expect_golden_text_match(
            evidence_output_dir("animation") .. "animation_blend_crossfade_state.txt",
            "tests/artifacts/baselines/animation/animation_blend_crossfade_state.txt"
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
