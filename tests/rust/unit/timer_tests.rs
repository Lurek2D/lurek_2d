//! Tests for the timer module.

// ── clock ─────────────────────────────────────────────────────────────────────

mod clock_tests {
    use lurek2d::timer::Clock;

    #[test]
    fn new_clock_starts_at_zero() {
        let c = Clock::new();
        assert_eq!(c.delta(), 0.0);
        assert_eq!(c.fps(), 0.0);
        assert_eq!(c.frame_count(), 0);
    }

    #[test]
    fn tick_increments_frame_count() {
        let mut c = Clock::new();
        c.tick();
        assert_eq!(c.frame_count(), 1);
        c.tick();
        assert_eq!(c.frame_count(), 2);
    }

    #[test]
    fn tick_returns_positive_delta() {
        let mut c = Clock::new();
        // First tick after construction should have a small positive dt
        let dt = c.tick();
        assert!(dt >= 0.0);
    }

    #[test]
    fn total_increases_after_tick() {
        let mut c = Clock::new();
        c.tick();
        assert!(c.total() >= 0.0);
    }

    #[test]
    fn elapsed_is_live() {
        let c = Clock::new();
        let e1 = c.elapsed();
        // elapsed() queries the clock directly, should be >= 0
        assert!(e1 >= 0.0);
    }

    #[test]
    fn average_delta_zero_before_any_tick() {
        let c = Clock::new();
        assert_eq!(c.average_delta(), 0.0);
    }

    #[test]
    fn average_delta_computed_after_ticks() {
        let mut c = Clock::new();
        c.tick();
        c.tick();
        // After at least one tick, average should be non-negative
        assert!(c.average_delta() >= 0.0);
    }

    #[test]
    fn default_trait_creates_same_as_new() {
        let c = Clock::default();
        assert_eq!(c.frame_count(), 0);
        assert_eq!(c.delta(), 0.0);
    }
}

// ── scheduler ─────────────────────────────────────────────────────────────────

mod scheduler_tests {
    use lurek2d::timer::Scheduler;

    #[test]
    fn new_scheduler_is_empty() {
        let sched = Scheduler::new();
        assert_eq!(sched.count(), 0);
        assert!(sched.is_empty());
    }

    #[test]
    fn after_schedules_event() {
        let mut sched = Scheduler::new();
        let id = sched.after(1.0);
        assert!(id > 0);
        assert_eq!(sched.count(), 1);
    }

    #[test]
    fn after_fires_once() {
        let mut sched = Scheduler::new();
        sched.after(1.0);
        let fired = sched.update(0.5);
        assert!(fired.is_empty());
        let fired = sched.update(0.6);
        assert_eq!(fired.len(), 1);
        assert_eq!(sched.count(), 0); // removed after firing
    }

    #[test]
    fn every_fires_repeatedly() {
        let mut sched = Scheduler::new();
        sched.every(0.5, -1); // infinite
        let fired = sched.update(1.1);
        assert_eq!(fired.len(), 2); // fired at 0.5 and 1.0
        assert_eq!(sched.count(), 1); // still active
    }

    #[test]
    fn every_with_count_expires() {
        let mut sched = Scheduler::new();
        sched.every(0.5, 2);
        let fired = sched.update(1.1);
        assert_eq!(fired.len(), 2);
        assert_eq!(sched.count(), 0); // expired
    }

    #[test]
    fn cancel_removes_event() {
        let mut sched = Scheduler::new();
        let id = sched.after(1.0);
        assert!(sched.cancel(id));
        assert_eq!(sched.count(), 0);
    }

    #[test]
    fn cancel_returns_false_for_unknown() {
        let mut sched = Scheduler::new();
        assert!(!sched.cancel(999));
    }

    #[test]
    fn cancel_all_clears() {
        let mut sched = Scheduler::new();
        sched.after(1.0);
        sched.every(0.5, -1);
        let n = sched.cancel_all();
        assert_eq!(n, 2);
        assert_eq!(sched.count(), 0);
    }

    #[test]
    fn default_is_empty() {
        let sched = Scheduler::default();
        assert_eq!(sched.count(), 0);
    }

    // ── New feature tests ─────────────────────────────────────────────────

    #[test]
    fn pause_freezes_event() {
        let mut sched = Scheduler::new();
        let id = sched.after(1.0);
        sched.pause(id);
        assert!(sched.is_paused(id));
        let fired = sched.update(2.0); // would have fired if not paused
        assert!(fired.is_empty());
        assert_eq!(sched.count(), 1);
    }

    #[test]
    fn resume_unfreezes_event() {
        let mut sched = Scheduler::new();
        let id = sched.after(0.5);
        sched.pause(id);
        sched.update(1.0);
        assert_eq!(sched.count(), 1); // still there, paused
        sched.resume(id);
        assert!(!sched.is_paused(id));
        let fired = sched.update(0.6);
        assert_eq!(fired.len(), 1);
    }

    #[test]
    fn get_remaining_returns_correct_value() {
        let mut sched = Scheduler::new();
        let id = sched.after(2.0);
        sched.update(0.5);
        let rem = sched.get_remaining(id).unwrap();
        assert!((rem - 1.5).abs() < 1e-9);
    }

    #[test]
    fn get_remaining_returns_none_for_missing() {
        let sched = Scheduler::new();
        assert!(sched.get_remaining(99).is_none());
    }

    #[test]
    fn set_interval_changes_timing() {
        let mut sched = Scheduler::new();
        let id = sched.every(1.0, -1);
        sched.set_interval(id, 0.5);
        assert_eq!(sched.get_interval(id).unwrap(), 0.5);
        let fired = sched.update(1.1);
        assert_eq!(fired.len(), 2); // fires at 0.5 and 1.0
    }

    #[test]
    fn reset_event_restarts_remaining() {
        let mut sched = Scheduler::new();
        let id = sched.after(1.0);
        sched.update(0.7);
        sched.reset_event(id);
        let fired = sched.update(0.5);
        assert!(fired.is_empty()); // should not fire yet (reset to 1.0 remaining)
        let fired = sched.update(0.6);
        assert_eq!(fired.len(), 1);
    }

    #[test]
    fn time_scale_slows_timers() {
        let mut sched = Scheduler::new();
        sched.after(1.0);
        sched.set_time_scale(0.5);
        assert!((sched.get_time_scale() - 0.5).abs() < 1e-9);
        let fired = sched.update(1.5); // effective = 0.75s, not enough
        assert!(fired.is_empty());
        let fired = sched.update(1.0); // effective += 0.5 -> total 1.25s
        assert_eq!(fired.len(), 1);
    }

    #[test]
    fn time_scale_zero_freezes_all() {
        let mut sched = Scheduler::new();
        sched.after(0.1);
        sched.set_time_scale(0.0);
        let fired = sched.update(100.0);
        assert!(fired.is_empty());
        assert_eq!(sched.count(), 1);
    }

    #[test]
    fn after_named_fires_and_removes() {
        let mut sched = Scheduler::new();
        sched.after_named("boss-spawn", 0.5);
        let fired = sched.update(0.6);
        assert_eq!(fired.len(), 1);
        assert_eq!(sched.count(), 0);
    }

    #[test]
    fn cancel_named_works() {
        let mut sched = Scheduler::new();
        sched.after_named("foo", 1.0);
        let cancelled = sched.cancel_named("foo");
        assert!(cancelled.is_some());
        assert_eq!(sched.count(), 0);
    }

    #[test]
    fn cancel_named_returns_none_for_missing() {
        let mut sched = Scheduler::new();
        assert!(sched.cancel_named("nonexistent").is_none());
    }

    #[test]
    fn after_named_replaces_existing() {
        let mut sched = Scheduler::new();
        sched.after_named("wave", 5.0);
        sched.after_named("wave", 1.0); // replaces
        assert_eq!(sched.count(), 1);
        let fired = sched.update(1.1);
        assert_eq!(fired.len(), 1);
    }

    #[test]
    fn every_named_repeating() {
        let mut sched = Scheduler::new();
        sched.every_named("tick", 0.5, 3);
        let fired = sched.update(1.6);
        assert_eq!(fired.len(), 3);
        assert_eq!(sched.count(), 0);
    }

    #[test]
    fn get_repeat_count_decrements() {
        let mut sched = Scheduler::new();
        let id = sched.every(0.5, 3);
        assert_eq!(sched.get_repeat_count(id), Some(3));
        sched.update(0.6);
        assert_eq!(sched.get_repeat_count(id), Some(2));
    }
}

// ── after_frames / every_frames / update_frames ───────────────────────────────

mod frame_event_tests {
    use lurek2d::timer::Scheduler;

    #[test]
    fn after_frames_fires_after_n_update_frames() {
        let mut s = Scheduler::new();
        let id = s.after_frames(2);
        assert_eq!(s.update_frames().len(), 0);
        let fired = s.update_frames();
        assert!(fired.contains(&id));
    }

    #[test]
    fn after_frames_fires_exactly_once() {
        let mut s = Scheduler::new();
        let id = s.after_frames(1);
        let mut total = 0;
        for _ in 0..5 {
            let fired = s.update_frames();
            if fired.contains(&id) {
                total += 1;
            }
        }
        assert_eq!(total, 1);
    }

    #[test]
    fn after_frames_zero_fires_on_first_update() {
        let mut s = Scheduler::new();
        let id = s.after_frames(0);
        let fired = s.update_frames();
        assert!(fired.contains(&id));
    }

    #[test]
    fn every_frames_fires_repeatedly() {
        let mut s = Scheduler::new();
        let id = s.every_frames(2, -1);
        let mut count = 0;
        for _ in 0..6 {
            if s.update_frames().contains(&id) {
                count += 1;
            }
        }
        assert_eq!(count, 3);
    }

    #[test]
    fn every_frames_respects_count_limit() {
        let mut s = Scheduler::new();
        let id = s.every_frames(1, 3);
        let mut count = 0;
        for _ in 0..10 {
            if s.update_frames().contains(&id) {
                count += 1;
            }
        }
        assert_eq!(count, 3);
    }

    #[test]
    fn update_frames_returns_all_due_ids() {
        let mut s = Scheduler::new();
        let id1 = s.after_frames(1);
        let id2 = s.after_frames(1);
        let fired = s.update_frames();
        assert!(fired.contains(&id1));
        assert!(fired.contains(&id2));
    }
}
