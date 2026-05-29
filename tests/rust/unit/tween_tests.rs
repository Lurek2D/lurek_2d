//! File: tests/rust/unit/tween_tests.rs

mod state_tests {
    use lurek2d::tween::{builtin_easing_names, TweenState};

    #[test]
    fn tween_state_zero_duration_clamps_and_completes() {
        let mut state = TweenState::new(0.0, "linear");
        assert!(state.tick(0.0002));
        assert!(state.is_complete());
    }

    #[test]
    fn tween_state_pause_resume_and_extreme_dt() {
        let mut state = TweenState::new(1.0, "linear");
        state.paused = true;
        assert!(!state.tick(10.0));
        assert_eq!(state.elapsed, 0.0);

        state.paused = false;
        assert!(state.tick(10.0));
        assert!(state.is_complete());
        assert_eq!(state.t_raw(), 1.0);
    }

    #[test]
    fn builtin_easing_names_contains_linear() {
        assert!(builtin_easing_names().contains(&"linear"));
        assert!(builtin_easing_names().contains(&"quadInOut"));
    }
}

mod spring_tests {
    use lurek2d::tween::{SpringAxis, SpringSystem};

    #[test]
    fn spring_axis_reaches_target_with_updates() {
        let mut axis = SpringAxis::new(0.0, 1.0, 120.0, 18.0, 0.001);
        for _ in 0..600 {
            axis.update(1.0 / 60.0);
        }
        assert!(axis.is_settled());
    }

    #[test]
    fn spring_system_updates_multiple_axes() {
        let mut system = SpringSystem::new(100.0, 14.0, 0.001);
        system.add_axis("x".to_string(), 0.0, 10.0);
        system.add_axis("y".to_string(), 0.0, -5.0);

        for _ in 0..600 {
            system.update(1.0 / 60.0);
        }

        assert!(system.is_settled());
        let x = system.get_position("x").expect("x axis present");
        let y = system.get_position("y").expect("y axis present");
        assert!((x - 10.0).abs() < 0.05);
        assert!((y + 5.0).abs() < 0.05);
    }
}
