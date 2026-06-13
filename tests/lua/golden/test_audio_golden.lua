-- Golden test: audio compare-only evidence validation.

-- @describe golden: audio evidence comparison
describe("golden: audio evidence comparison", function()
    it("matches audio fixture baselines", function()
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_fixture_stereo_two_tones.wav",
            "tests/artifacts/baselines/audio/audio_fixture_stereo_two_tones.wav"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_fixture_frequency_sweep_100_4000.wav",
            "tests/artifacts/baselines/audio/audio_fixture_frequency_sweep_100_4000.wav"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_fixture_amplitude_envelope.wav",
            "tests/artifacts/baselines/audio/audio_fixture_amplitude_envelope.wav"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_fixture_square_wave_440hz.wav",
            "tests/artifacts/baselines/audio/audio_fixture_square_wave_440hz.wav"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_fixture_sawtooth_wave_440hz.wav",
            "tests/artifacts/baselines/audio/audio_fixture_sawtooth_wave_440hz.wav"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_fixture_white_noise.wav",
            "tests/artifacts/baselines/audio/audio_fixture_white_noise.wav"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_fixture_silence_half_second.wav",
            "tests/artifacts/baselines/audio/audio_fixture_silence_half_second.wav"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_fixture_waveform_sine_440hz.wav",
            "tests/artifacts/baselines/audio/audio_fixture_waveform_sine_440hz.wav"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_waveform_generator_atlas.png",
            "tests/artifacts/baselines/audio/audio_waveform_generator_atlas.png"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_dsp_lowpass_compare.png",
            "tests/artifacts/baselines/audio/audio_dsp_lowpass_compare.png"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_fixture_waveform.png",
            "tests/artifacts/baselines/audio/audio_fixture_waveform.png"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_dsp_bandpass_compare.png",
            "tests/artifacts/baselines/audio/audio_dsp_bandpass_compare.png"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_dsp_highpass_compare.png",
            "tests/artifacts/baselines/audio/audio_dsp_highpass_compare.png"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_dsp_mix_compare.png",
            "tests/artifacts/baselines/audio/audio_dsp_mix_compare.png"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_fixture_spectrogram.png",
            "tests/artifacts/baselines/audio/audio_fixture_spectrogram.png"
        )
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
            evidence_output_dir("audio") .. "audio_normalized_peak_09.wav",
            "tests/artifacts/baselines/audio/audio_normalized_peak_09.wav"
        )
        expect_golden_file_match(
            evidence_output_dir("audio") .. "audio_offline_lowpass_1khz.wav",
            "tests/artifacts/baselines/audio/audio_offline_lowpass_1khz.wav"
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
