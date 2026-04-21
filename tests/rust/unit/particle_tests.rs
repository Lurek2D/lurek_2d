//! Smoke tests for the particle module against the current public API.

use lurek2d::particle::visualization::draw_to_image;
use lurek2d::particle::{ParticleConfig, ParticleSystem, Trail};

mod emitter_tests {
    use super::*;

    #[test]
    fn emit_increases_count() {
        let mut ps = ParticleSystem::new(ParticleConfig::default());
        assert!(ps.is_empty());
        ps.emit(5);
        assert!(ps.count() > 0);
    }

    #[test]
    fn state_transitions_toggle_flags() {
        let mut ps = ParticleSystem::new(ParticleConfig::default());
        assert!(ps.is_active());
        ps.start();
        assert!(ps.is_active());
        ps.pause();
        assert!(ps.is_paused());
        ps.resume();
        assert!(ps.is_active());
        ps.stop();
        assert!(ps.is_stopped());
    }

    #[test]
    fn attractor_management() {
        let mut ps = ParticleSystem::new(ParticleConfig::default());
        ps.add_attractor(0.0, 0.0, 10.0, 32.0);
        assert_eq!(ps.attractor_count(), 1);
        ps.clear_attractors();
        assert_eq!(ps.attractor_count(), 0);
    }
}

mod trail_tests {
    use super::*;

    #[test]
    fn push_point_and_clear() {
        let mut trail = Trail::new(1.0, 4.0);
        trail.push_point(0.0, 0.0);
        trail.push_point(5.0, 5.0);
        assert_eq!(trail.get_point_count(), 2);
        trail.clear();
        assert_eq!(trail.get_point_count(), 0);
    }

    #[test]
    fn width_and_lifetime_roundtrip() {
        let mut trail = Trail::new(1.0, 4.0);
        trail.set_width(4.0, Some(1.0));
        trail.set_lifetime(2.5);
        assert_eq!(trail.get_width(), (4.0, 1.0));
        assert!((trail.get_lifetime() - 2.5).abs() < f32::EPSILON);
    }

    #[test]
    fn draw_to_image_correct_dimensions() {
        let trail = Trail::new(1.0, 4.0);
        let img = trail.draw_to_image(64, 32);
        assert_eq!(img.width(), 64);
        assert_eq!(img.height(), 32);
    }
}

mod visualization_tests {
    use super::*;

    #[test]
    fn draw_to_image_correct_dimensions() {
        let ps = ParticleSystem::new(ParticleConfig::default());
        let img = draw_to_image(&ps, 80, 40);
        assert_eq!(img.width(), 80);
        assert_eq!(img.height(), 40);
    }
}
