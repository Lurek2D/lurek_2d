//! File: tests/rust/unit/audio_tests.rs

// TODO(lua-first): public Rust API coverage in this file should live in tests/lua/unit/; keep only private/internal seams here.

use lurek2d::audio::*;

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
