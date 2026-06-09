//! File: tests/rust/unit/audio_tests.rs

// TODO(lua-first): public Rust API coverage in this file should live in tests/lua/unit/; keep only private/internal seams here.

use lurek2d::audio::*;

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
        data[8..12].copy_from_slice(b"WAVE");
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
        assert!((s.orientation[2] + 1.0).abs() < 0.001);
        assert!((s.orientation[4] - 1.0).abs() < 0.001);
    }
}
