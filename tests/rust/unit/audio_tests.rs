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

mod mixer_spatial_tests {
    use super::*;

    fn listener(id: &str, x: f32, weight: f32) -> SpatialListener {
        SpatialListener {
            id: id.to_string(),
            position: [x, 0.0, 0.0],
            velocity: [0.0, 0.0, 0.0],
            weight,
        }
    }

    #[test]
    fn nearest_listener_uses_distance_and_preserves_one_source() {
        let mut mixer = Mixer::new();
        let source = mixer.load_source("unused.wav", SourceType::Static);
        mixer.set_source_position(source, 90.0, 0.0, 0.0);
        mixer
            .set_listeners(
                vec![listener("left", 0.0, 1.0), listener("right", 100.0, 1.0)],
                SpatialListenerPolicy::Nearest,
            )
            .expect("listeners");

        let result = mixer
            .get_source_spatial_result(source)
            .expect("spatial result");
        assert_eq!(result.listener_id.as_deref(), Some("right"));
        assert_eq!(result.listener_ids, vec!["right"]);
        assert!((result.distance - 10.0).abs() < 0.001);
        assert_eq!(mixer.get_source_count(), 1);
    }

    #[test]
    fn weighted_and_manual_policies_are_bounded_and_masked() {
        let mut mixer = Mixer::new();
        let source = mixer.load_source("unused.wav", SourceType::Static);
        mixer.set_source_position(source, 0.0, 0.0, 0.0);
        let listeners = vec![listener("left", -100.0, 1.0), listener("right", 100.0, 1.0)];
        mixer
            .set_listeners(listeners.clone(), SpatialListenerPolicy::Weighted)
            .expect("weighted listeners");
        let weighted = mixer
            .get_source_spatial_result(source)
            .expect("weighted result");
        assert!(weighted.pan.abs() < 0.001);
        assert!((0.0..=1.0).contains(&weighted.gain));

        mixer
            .set_listeners(listeners, SpatialListenerPolicy::Manual)
            .expect("manual listeners");
        assert_eq!(
            mixer
                .get_source_spatial_result(source)
                .expect("silent result")
                .gain,
            0.0
        );
        mixer
            .set_source_listener_mask(source, Some(vec!["right".to_string()]))
            .expect("mask");
        let masked = mixer
            .get_source_spatial_result(source)
            .expect("masked result");
        assert_eq!(masked.listener_ids, vec!["right"]);
        assert!(masked.pan < 0.0);
    }

    #[test]
    fn listener_replacement_is_atomic_on_validation_failure() {
        let mut mixer = Mixer::new();
        mixer
            .set_listeners(
                vec![listener("stable", 0.0, 1.0)],
                SpatialListenerPolicy::Nearest,
            )
            .expect("initial listeners");
        let invalid = vec![listener("dup", 0.0, 1.0), listener("dup", 1.0, 1.0)];
        assert!(mixer
            .set_listeners(invalid, SpatialListenerPolicy::Weighted)
            .is_err());
        assert_eq!(mixer.get_listeners()[0].id, "stable");
        assert_eq!(mixer.get_listener_policy(), SpatialListenerPolicy::Nearest);
    }
}
