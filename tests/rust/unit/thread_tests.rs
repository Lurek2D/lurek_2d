//! File: tests/rust/unit/thread_tests.rs

// TODO(lua-first): public Rust API coverage in this file should live in tests/lua/unit/; keep only private/internal seams here.

mod internal_tests {
    use lurek2d::thread::channel::ChannelValue;
    use lurek2d::thread::worker::ThreadState;

    #[test]
    fn channel_value_clone_roundtrip() {
        let original = ChannelValue::Table(vec![(
            ChannelValue::String("key".into()),
            ChannelValue::Number(42.0),
        )]);
        let cloned = original.clone();
        match cloned {
            ChannelValue::Table(pairs) => {
                assert_eq!(pairs.len(), 1);
            }
            _ => panic!("expected Table"),
        }
    }

    #[test]
    fn thread_state_variants_eq() {
        assert_eq!(ThreadState::Pending, ThreadState::Pending);
        assert_eq!(ThreadState::Running, ThreadState::Running);
        assert_eq!(ThreadState::Completed, ThreadState::Completed);
        assert_ne!(ThreadState::Pending, ThreadState::Running);
        assert_eq!(
            ThreadState::Error("x".into()),
            ThreadState::Error("x".into())
        );
    }
}

mod promise_tests {
    use lurek2d::thread::promise::PromiseState;

    #[test]
    fn promise_state_pending_is_default() {
        let state = PromiseState::Pending;
        assert_eq!(state, PromiseState::Pending);
    }

    #[test]
    fn promise_state_done_eq() {
        assert_eq!(PromiseState::Done, PromiseState::Done);
        assert_ne!(PromiseState::Done, PromiseState::Pending);
    }

    #[test]
    fn promise_state_error_carries_message() {
        let state = PromiseState::Error("runtime error".into());
        match state {
            PromiseState::Error(msg) => assert_eq!(msg, "runtime error"),
            _ => panic!("expected Error variant"),
        }
    }

    #[test]
    fn promise_state_clone() {
        let original = PromiseState::Error("oops".into());
        let cloned = original.clone();
        assert_eq!(cloned, PromiseState::Error("oops".into()));
    }
}
