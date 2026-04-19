//! Tests for the event module.

// ── signal ────────────────────────────────────────────────────────────────────

mod signal_tests {
    use lurek2d::event::Signal;

    // ── Subscribe ───────────────────────────────────────────────────────────

    #[test]
    fn subscribe_returns_incrementing_handles() {
        let mut s = Signal::new();
        let h1 = s.subscribe("click");
        let h2 = s.subscribe("click");
        assert!(h2 > h1);
    }

    #[test]
    fn get_count_after_subscribe() {
        let mut s = Signal::new();
        s.subscribe("fire");
        s.subscribe("fire");
        assert_eq!(s.get_count("fire"), 2);
    }

    #[test]
    fn subscribe_two_events_independent() {
        let mut s = Signal::new();
        s.subscribe("a");
        s.subscribe("b");
        s.subscribe("b");
        assert_eq!(s.get_count("a"), 1);
        assert_eq!(s.get_count("b"), 2);
    }

    // ── Remove ────────────────────────────────────────────────────────────────

    #[test]
    fn remove_decrements_count() {
        let mut s = Signal::new();
        let h = s.subscribe("update");
        assert_eq!(s.get_count("update"), 1);
        let removed = s.remove(h);
        assert!(removed);
        assert_eq!(s.get_count("update"), 0);
    }

    #[test]
    fn remove_nonexistent_handle_returns_false() {
        let mut s = Signal::new();
        assert!(!s.remove(999));
    }

    // ── Clear ─────────────────────────────────────────────────────────────────

    #[test]
    fn clear_empties_named_event() {
        let mut s = Signal::new();
        s.subscribe("draw");
        s.subscribe("draw");
        s.clear("draw");
        assert_eq!(s.get_count("draw"), 0);
    }

    #[test]
    fn clear_all_removes_everything() {
        let mut s = Signal::new();
        s.subscribe("a");
        s.subscribe("b");
        s.clear_all();
        assert_eq!(s.get_total_count(), 0);
    }
}

// ── event_queue ───────────────────────────────────────────────────────────────

mod event_queue_tests {
    use lurek2d::event::{Event, EventArg, EventQueue};

    // ── Push / Len ────────────────────────────────────────────────────────────

    #[test]
    fn new_queue_is_empty() {
        let q = EventQueue::new();
        assert!(q.is_empty());
        assert_eq!(q.len(), 0);
    }

    #[test]
    fn push_event_increments_len() {
        let mut q = EventQueue::new();
        q.push_event("keypressed", vec![EventArg::Str("a".to_string())]);
        assert_eq!(q.len(), 1);
    }

    // ── FIFO order ─────────────────────────────────────────────────────────────

    #[test]
    fn poll_fifo_order_preserved() {
        let mut q = EventQueue::new();
        q.push_event("first", vec![]);
        q.push_event("second", vec![]);
        let e1 = q.poll().unwrap();
        let e2 = q.poll().unwrap();
        assert_eq!(e1.name, "first");
        assert_eq!(e2.name, "second");
    }

    #[test]
    fn poll_empty_returns_none() {
        let mut q = EventQueue::new();
        assert!(q.poll().is_none());
    }

    // ── Clear ─────────────────────────────────────────────────────────────────

    #[test]
    fn clear_empties_queue() {
        let mut q = EventQueue::new();
        q.push_event("a", vec![]);
        q.push_event("b", vec![]);
        q.clear();
        assert!(q.is_empty());
    }

    #[test]
    fn push_direct_and_poll_roundtrip() {
        let mut q = EventQueue::new();
        q.push(Event {
            name: "custom".to_string(),
            args: vec![EventArg::Num(42.0)],
        });
        let evt = q.poll().unwrap();
        assert_eq!(evt.name, "custom");
    }

    // ── Wait with zero timeout ────────────────────────────────────────────

    #[test]
    fn wait_zero_timeout_returns_none_when_empty() {
        let mut q = EventQueue::new();
        assert!(q.wait(Some(0)).is_none());
    }

    #[test]
    fn wait_zero_timeout_returns_event_when_available() {
        let mut q = EventQueue::new();
        q.push_event("ready", vec![]);
        let evt = q.wait(Some(0)).unwrap();
        assert_eq!(evt.name, "ready");
    }

    // ── EventArg variants ─────────────────────────────────────────────────

    #[test]
    fn event_arg_clone_preserves_variants() {
        let args = vec![
            EventArg::Str("hello".into()),
            EventArg::Num(3.14),
            EventArg::Bool(true),
            EventArg::Nil,
        ];
        let cloned = args.clone();
        assert_eq!(cloned.len(), 4);
    }

    // ── Default ───────────────────────────────────────────────────────────

    #[test]
    fn default_queue_is_empty() {
        let q = EventQueue::default();
        assert!(q.is_empty());
    }
}
