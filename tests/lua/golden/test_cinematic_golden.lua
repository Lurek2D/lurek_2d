-- Golden test: cinematic compare evidence output against golden samples.

-- @describe golden: cinematic evidence comparison
describe("golden: cinematic evidence comparison", function()
    it("matches cinematic visual baselines", function()
        expect_golden_file_match(
            evidence_output_dir("cinematic") .. "cinematic_multitrack_schedule.png",
            "tests/artifacts/baselines/cinematic/cinematic_multitrack_schedule.png"
        )
        expect_golden_file_match(
            evidence_output_dir("cinematic") .. "cinematic_labels_branching.png",
            "tests/artifacts/baselines/cinematic/cinematic_labels_branching.png"
        )
        expect_golden_file_match(
            evidence_output_dir("cinematic") .. "cinematic_completion_controls.png",
            "tests/artifacts/baselines/cinematic/cinematic_completion_controls.png"
        )
        expect_golden_file_match(
            evidence_output_dir("cinematic") .. "cinematic_legacy_cut_list.png",
            "tests/artifacts/baselines/cinematic/cinematic_legacy_cut_list.png"
        )
        expect_golden_file_match(
            evidence_output_dir("cinematic") .. "cinematic_signal_audio_sequence.png",
            "tests/artifacts/baselines/cinematic/cinematic_signal_audio_sequence.png"
        )
        expect_golden_file_match(
            evidence_output_dir("cinematic") .. "cinematic_playhead_controls.gif",
            "tests/artifacts/baselines/cinematic/cinematic_playhead_controls.gif"
        )
    end)
end)

test_summary()
