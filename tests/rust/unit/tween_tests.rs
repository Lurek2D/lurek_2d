//! Tests for the tween module.

use lurek2d::tween::*;

// ── state ─────────────────────────────────────────────────────────────────────

mod state_tests {
    use super::*;

    #[test]
    fn new_starts_at_zero() {
        let s = TweenState::new(1.0, "linear");
        assert!((s.elapsed).abs() < 1e-10);
        assert!(!s.is_complete());
    }

    #[test]
    fn tick_advances_elapsed() {
        let mut s = TweenState::new(1.0, "linear");
        let done = s.tick(0.5);
        assert!(!done);
        assert!((s.elapsed - 0.5).abs() < 1e-10);
    }

    #[test]
    fn tick_returns_true_on_completion() {
        let mut s = TweenState::new(1.0, "linear");
        let done = s.tick(1.5);
        assert!(done);
        assert!(s.is_complete());
    }

    #[test]
    fn t_raw_clamps_to_unit() {
        let mut s = TweenState::new(1.0, "linear");
        s.tick(2.0);
        assert!((s.t_raw() - 1.0).abs() < 1e-5);
    }

    #[test]
    fn lerp_linear_midpoint() {
        let mut s = TweenState::new(1.0, "linear");
        s.tick(0.5);
        let v = s.lerp(0.0, 100.0);
        assert!((v - 50.0).abs() < 1.0);
    }

    #[test]
    fn reset_clears_elapsed() {
        let mut s = TweenState::new(1.0, "linear");
        s.tick(0.7);
        s.reset();
        assert!((s.elapsed).abs() < 1e-10);
    }

    #[test]
    fn paused_tick_does_not_advance() {
        let mut s = TweenState::new(1.0, "linear");
        s.paused = true;
        let done = s.tick(0.5);
        assert!(!done);
        assert!((s.elapsed).abs() < 1e-10);
    }

    #[test]
    fn resolve_easing_known_names() {
        assert!(resolve_easing("linear").is_some());
        assert!(resolve_easing("cubicIn").is_some());
        assert!(resolve_easing("bounceOut").is_some());
    }

    #[test]
    fn resolve_easing_unknown_returns_none() {
        assert!(resolve_easing("nonexistent").is_none());
    }

    #[test]
    fn builtin_names_is_nonempty() {
        let names = builtin_easing_names();
        assert!(names.len() > 10);
        assert!(names.contains(&"linear"));
    }

    #[test]
    fn zero_duration_clamped() {
        let s = TweenState::new(0.0, "linear");
        assert!(s.duration > 0.0);
        assert!((s.t_raw() - 0.0).abs() < 1e-3);
    }
}

// ── spring ────────────────────────────────────────────────────────────────────

mod spring_tests {
    use super::*;

    #[test]
    fn spring_axis_settles_at_target() {
        let mut axis = SpringAxis::new(0.0, 10.0, 100.0, 10.0, 0.01);
        // Simulate many small steps
        for _ in 0..500 {
            axis.update(0.016);
        }
        assert!(axis.is_settled());
        assert!((axis.position - 10.0).abs() < 0.01);
    }

    #[test]
    fn spring_axis_already_at_target_is_settled() {
        let axis = SpringAxis::new(5.0, 5.0, 100.0, 10.0, 0.1);
        assert!(axis.is_settled());
    }

    #[test]
    fn spring_axis_reset_clears_velocity() {
        let mut axis = SpringAxis::new(0.0, 10.0, 100.0, 10.0, 0.01);
        axis.update(0.016);
        assert!(axis.velocity.abs() > 0.0);
        axis.reset(0.0, 5.0);
        assert!((axis.velocity).abs() < 1e-10);
        assert!((axis.target - 5.0).abs() < 1e-5);
    }

    #[test]
    fn spring_axis_set_target_unsettles() {
        let mut axis = SpringAxis::new(5.0, 5.0, 100.0, 10.0, 0.01);
        assert!(axis.is_settled());
        axis.set_target(20.0);
        assert!(!axis.is_settled());
    }

    #[test]
    fn spring_system_all_axes_settle() {
        let mut sys = SpringSystem::new(100.0, 10.0, 0.01);
        sys.add_axis("x".to_string(), 0.0, 10.0);
        sys.add_axis("y".to_string(), 0.0, 20.0);
        for _ in 0..500 {
            sys.update(0.016);
        }
        assert!(sys.is_settled());
        assert!((sys.get_position("x").unwrap() - 10.0).abs() < 0.01);
        assert!((sys.get_position("y").unwrap() - 20.0).abs() < 0.01);
    }

    #[test]
    fn spring_system_set_target_updates_axis() {
        let mut sys = SpringSystem::new(100.0, 10.0, 0.01);
        sys.add_axis("x".to_string(), 0.0, 5.0);
        sys.set_target("x", 15.0);
        for _ in 0..500 {
            sys.update(0.016);
        }
        assert!((sys.get_position("x").unwrap() - 15.0).abs() < 0.01);
    }

    #[test]
    fn spring_system_get_position_missing_key() {
        let sys = SpringSystem::new(100.0, 10.0, 0.01);
        assert!(sys.get_position("missing").is_none());
    }
}
