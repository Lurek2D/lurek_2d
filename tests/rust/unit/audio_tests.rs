//! INTERNAL ONLY: Rust-only tests for audio helpers and data structures that are not directly
//! asserted through `lurek.audio.*`.
//!
//! Public playback, mixer, bus, MIDI-player, pool, and sound-data behaviour is
//! covered by the Lua-first suite in `tests/lua/unit/test_audio_unit.lua`.
//! The remaining Rust coverage keeps low-level DSP/state helpers and offline
//! struct invariants.

use lurek2d::audio::*;

// ── midi tests ───────────────────────────────────────────────────────────────

mod midi_tests {
    use super::*;

    fn make_fake_sf2(size: usize) -> Vec<u8> {
        let mut data = vec![0u8; size.max(12)];
        data[0..4].copy_from_slice(b"RIFF");
        data[8..12].copy_from_slice(b"sfbk");
        data
    }

    #[test]
    fn new_state_has_no_soundfont() {
        let state = MidiState::new();
        assert!(!state.has_soundfont());
        assert!(state.soundfont_path().is_none());
        assert!(state.soundfont_data().is_none());
    }

    #[test]
    fn set_and_check_soundfont() {
        let mut state = MidiState::new();
        let sf2 = make_fake_sf2(64);
        state
            .set_soundfont(sf2, Some("test.sf2".to_string()))
            .unwrap();
        assert!(state.has_soundfont());
        assert_eq!(state.soundfont_path(), Some("test.sf2"));
        assert!(state.soundfont_data().unwrap().len() >= 12);
    }

    #[test]
    fn clear_soundfont() {
        let mut state = MidiState::new();
        state.set_soundfont(make_fake_sf2(64), None).unwrap();
        assert!(state.has_soundfont());
        state.clear_soundfont();
        assert!(!state.has_soundfont());
        assert!(state.soundfont_path().is_none());
    }

    #[test]
    fn reject_too_small() {
        let mut state = MidiState::new();
        let result = state.set_soundfont(vec![0u8; 4], None);
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("too small"));
    }

    #[test]
    fn reject_invalid_header() {
        let mut state = MidiState::new();
        let result = state.set_soundfont(vec![0u8; 16], None);
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("RIFF"));
    }

    #[test]
    fn reject_non_sf2_riff() {
        let mut state = MidiState::new();
        let mut data = vec![0u8; 16];
        data[0..4].copy_from_slice(b"RIFF");
        data[8..12].copy_from_slice(b"WAVE"); // not sfbk
        let result = state.set_soundfont(data, None);
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("sfbk"));
    }

    #[test]
    fn default_is_empty() {
        let state = MidiState::default();
        assert!(!state.has_soundfont());
    }
}

// ── pool tests ───────────────────────────────────────────────────────────────

// ── source tests ─────────────────────────────────────────────────────────────

mod source_tests {
    use super::*;

    #[test]
    fn audio_source_defaults() {
        let src = AudioSource::new(42, "sfx/boom.ogg");
        assert_eq!(src.id, 42);
        assert_eq!(src.file_path, "sfx/boom.ogg");
        assert!((src.volume - 1.0).abs() < 0.001);
        assert!(!src.looping);
    }

    #[test]
    fn spatial_state_default() {
        let s = SpatialState::default();
        assert!(s.position.iter().all(|value| value.abs() < 0.001));
        assert!(s.velocity.iter().all(|value| value.abs() < 0.001));
        // Default orientation: forward = (0,0,-1), up = (0,1,0)
        assert!((s.orientation[2] + 1.0).abs() < 0.001);
        assert!((s.orientation[4] - 1.0).abs() < 0.001);
    }
}

// ── sound_data tests ─────────────────────────────────────────────────────────

mod sound_data_tests {
    use super::*;

    #[test]
    fn new_buffer_reports_shape() {
        let sound = SoundData::new(8, 44100, 2);
        assert_eq!(sound.sample_count(), 8);
        assert_eq!(sound.sample_rate(), 44100);
        assert_eq!(sound.channel_count(), 2);
    }

    #[test]
    fn new_buffer_uses_float_bit_depth() {
        let sound = SoundData::new(4, 22050, 1);
        assert_eq!(sound.bit_depth(), 32);
    }

    #[test]
    fn from_samples_reports_pcm_bit_depth() {
        let sound = SoundData::from_samples(vec![0.1, -0.1], 48000, 1);
        assert_eq!(sound.bit_depth(), 16);
    }

    #[test]
    fn from_samples_keeps_sample_values() {
        let sound = SoundData::from_samples(vec![0.25, -0.5], 48000, 1);
        assert!((sound.get_sample(0).unwrap_or_default() - 0.25).abs() < 0.001);
        assert!((sound.get_sample(1).unwrap_or_default() + 0.5).abs() < 0.001);
    }

    #[test]
    fn get_sample_returns_none_out_of_bounds() {
        let sound = SoundData::from_samples(vec![0.25], 48000, 1);
        assert!(sound.get_sample(4).is_none());
    }

    #[test]
    fn set_sample_updates_value() {
        let mut sound = SoundData::new(2, 44100, 1);
        assert!(sound.set_sample(1, 0.5));
        assert!((sound.get_sample(1).unwrap_or_default() - 0.5).abs() < 0.001);
    }

    #[test]
    fn set_sample_clamps_upper_bound() {
        let mut sound = SoundData::new(1, 44100, 1);
        assert!(sound.set_sample(0, 2.0));
        assert!((sound.get_sample(0).unwrap_or_default() - 1.0).abs() < 0.001);
    }

    #[test]
    fn set_sample_clamps_lower_bound() {
        let mut sound = SoundData::new(1, 44100, 1);
        assert!(sound.set_sample(0, -2.0));
        assert!((sound.get_sample(0).unwrap_or_default() + 1.0).abs() < 0.001);
    }

    #[test]
    fn set_sample_rejects_out_of_bounds() {
        let mut sound = SoundData::new(1, 44100, 1);
        assert!(!sound.set_sample(8, 0.5));
    }

    #[test]
    fn duration_uses_frame_count() {
        let sound = SoundData::new(44100, 44100, 2);
        assert!((sound.duration() - 1.0).abs() < 0.001);
    }

    #[test]
    fn duration_is_zero_when_sample_rate_is_zero() {
        let sound = SoundData::new(10, 0, 1);
        assert!(sound.duration().abs() < 0.001);
    }

    #[test]
    fn samples_slice_exposes_interleaved_len() {
        let sound = SoundData::new(3, 44100, 2);
        assert_eq!(sound.samples().len(), 6);
    }

    #[test]
    fn as_samples_matches_samples() {
        let sound = SoundData::from_samples(vec![0.1, 0.2], 44100, 1);
        assert_eq!(sound.as_samples().len(), sound.samples().len());
    }

    #[test]
    fn encode_wav_writes_riff_header() {
        let sound = SoundData::from_samples(vec![0.0, 0.5], 44100, 1);
        let bytes = sound.encode_wav();
        assert_eq!(&bytes[0..4], b"RIFF");
        assert_eq!(&bytes[8..12], b"WAVE");
    }

    #[test]
    fn mix_into_adds_samples() {
        let mut dest = SoundData::from_samples(vec![0.1, 0.2], 44100, 1);
        let src = SoundData::from_samples(vec![0.3, -0.1], 44100, 1);
        dest.mix_into(&src);
        assert!((dest.get_sample(0).unwrap_or_default() - 0.4).abs() < 0.001);
        assert!((dest.get_sample(1).unwrap_or_default() - 0.1).abs() < 0.001);
    }

    #[test]
    fn mix_into_extends_destination() {
        let mut dest = SoundData::from_samples(vec![0.1], 44100, 1);
        let src = SoundData::from_samples(vec![0.2, 0.3], 44100, 1);
        dest.mix_into(&src);
        assert_eq!(dest.samples().len(), 2);
        assert!((dest.get_sample(1).unwrap_or_default() - 0.3).abs() < 0.001);
    }

    #[test]
    fn apply_adsr_preserves_length() {
        let mut sound = SoundData::sine_wave(100.0, 0.1, 1000, 0.5);
        let len = sound.samples().len();
        sound.apply_adsr(0.01, 0.01, 0.5, 0.01);
        assert_eq!(sound.samples().len(), len);
    }
}

mod bus_tests {
    use super::*;

    #[test]
    fn bus_new_sets_name() {
        let bus = Bus::new("music");
        assert_eq!(bus.name(), "music");
    }

    #[test]
    fn bus_volume_clamps_to_zero() {
        let mut bus = Bus::new("sfx");
        bus.set_volume(-1.0);
        assert!(bus.volume().abs() < 0.001);
    }

    #[test]
    fn bus_pitch_clamps_to_zero() {
        let mut bus = Bus::new("sfx");
        bus.set_pitch(-1.0);
        assert!(bus.pitch().abs() < 0.001);
    }

    #[test]
    fn bus_pause_and_resume_toggle_state() {
        let mut bus = Bus::new("voice");
        bus.pause();
        assert!(bus.is_paused());
        bus.resume();
        assert!(!bus.is_paused());
    }

    #[test]
    fn bus_duck_target_clamps_volume() {
        let mut bus = Bus::new("voice");
        bus.set_duck_target("music", 2.0);
        let (_, volume) = bus.duck_target.as_ref().expect("duck target");
        assert!((*volume - 1.0).abs() < 0.001);
    }

    #[test]
    fn bus_clear_duck_removes_target() {
        let mut bus = Bus::new("voice");
        bus.set_duck_target("music", 0.5);
        bus.clear_duck_target();
        assert!(bus.duck_target.is_none());
    }

}
