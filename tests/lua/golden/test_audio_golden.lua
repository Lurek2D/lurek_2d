-- Golden test: audio compare-only evidence validation.

-- @describe golden: audio evidence comparison
describe("golden: audio evidence comparison", function()
    it("matches audio fixture baselines", function()
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_waveform_chord_c_major.png",
            "tests/artifacts/baselines/audio/audio_waveform_chord_c_major.png"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_sine_440hz_mono.wav",
            "tests/artifacts/baselines/audio/audio_sine_440hz_mono.wav"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_chord_c_major.wav",
            "tests/artifacts/baselines/audio/audio_chord_c_major.wav"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_frequency_sweep_200_2000.wav",
            "tests/artifacts/baselines/audio/audio_frequency_sweep_200_2000.wav"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_waveform_frequency_sweep.png",
            "tests/artifacts/baselines/audio/audio_waveform_frequency_sweep.png"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_waveform_sine_440hz.png",
            "tests/artifacts/baselines/audio/audio_waveform_sine_440hz.png"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_mix_into_base.png",
            "tests/artifacts/baselines/audio/audio_mix_into_base.png"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_mix_into_mixed.png",
            "tests/artifacts/baselines/audio/audio_mix_into_mixed.png"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_stereo_ping_pong.wav",
            "tests/artifacts/baselines/audio/audio_stereo_ping_pong.wav"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_bus_volume_half_gain.wav",
            "tests/artifacts/baselines/audio/audio_bus_volume_half_gain.wav"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_bus_volume_fadeout.wav",
            "tests/artifacts/baselines/audio/audio_bus_volume_fadeout.wav"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_bus_pitch_up_150.wav",
            "tests/artifacts/baselines/audio/audio_bus_pitch_up_150.wav"
        )
    end)
end)
test_summary()
