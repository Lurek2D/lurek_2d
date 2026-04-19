//! Tests for the devtools module.

// ── frame_stats ───────────────────────────────────────────────────────────────

mod frame_stats_tests {
    use lurek2d::devtools::frame_stats::FrameStats;

    #[test]
    fn empty_snapshot_is_zero() {
        let fs = FrameStats::new(100);
        let snap = fs.snapshot();
        assert_eq!(snap.samples, 0);
        assert_eq!(snap.fps, 0.0);
    }

    #[test]
    fn record_and_snapshot() {
        let mut fs = FrameStats::new(10);
        for _ in 0..5 {
            fs.record(0.016);
        }
        let snap = fs.snapshot();
        assert_eq!(snap.samples, 5);
        assert!((snap.avg - 0.016).abs() < 0.001);
        assert!(snap.fps > 50.0);
    }

    #[test]
    fn capacity_evicts_old_samples() {
        let mut fs = FrameStats::new(10);
        for i in 0..20 {
            fs.record(i as f64 * 0.001);
        }
        assert_eq!(fs.history.len(), 10);
    }

    #[test]
    fn set_capacity_trims() {
        let mut fs = FrameStats::new(100);
        for _ in 0..50 {
            fs.record(0.016);
        }
        fs.set_capacity(20);
        assert!(fs.history.len() <= 20);
    }

    #[test]
    fn percentiles_in_range() {
        let mut fs = FrameStats::new(100);
        for i in 0..100 {
            fs.record(i as f64 * 0.001);
        }
        let snap = fs.snapshot();
        assert!(snap.p50 >= snap.min);
        assert!(snap.p95 >= snap.p50);
        assert!(snap.p99 >= snap.p95);
        assert!(snap.max >= snap.p99);
    }
}

// ── watcher ───────────────────────────────────────────────────────────────────

mod watcher_tests {
    use lurek2d::devtools::watcher::FileWatcher;

    #[test]
    fn new_watcher_is_empty() {
        let w = FileWatcher::new();
        assert!(w.paths.is_empty());
    }

    #[test]
    fn watch_and_unwatch() {
        let mut w = FileWatcher::new();
        w.watch("test.txt");
        assert_eq!(w.watched_paths().len(), 1);
        assert!(w.unwatch("test.txt"));
        assert!(w.paths.is_empty());
    }

    #[test]
    fn unwatch_nonexistent_returns_false() {
        let mut w = FileWatcher::new();
        assert!(!w.unwatch("missing.txt"));
    }

    #[test]
    fn clear_removes_all() {
        let mut w = FileWatcher::new();
        w.watch("a.txt");
        w.watch("b.txt");
        w.clear();
        assert!(w.paths.is_empty());
    }

    #[test]
    fn poll_nonexistent_file_no_panic() {
        let mut w = FileWatcher::new();
        w.watch("nonexistent_file_12345.txt");
        let changed = w.poll();
        assert!(changed.is_empty(), "first poll should be baseline");
    }
}

// ── repl ──────────────────────────────────────────────────────────────────────

mod repl_tests {
    use lurek2d::devtools::repl::ReplConsole;

    #[test]
    fn new_repl_is_empty() {
        let r = ReplConsole::new(50);
        assert!(r.is_empty());
        assert_eq!(r.len(), 0);
    }
}

// ── profiler ──────────────────────────────────────────────────────────────────

mod profiler_tests {
    use lurek2d::devtools::profiler::{ProfileZone, Profiler};

    #[test]
    fn profiler_disabled_by_default() {
        let p = Profiler::new();
        assert!(!p.enabled);
    }

    #[test]
    fn push_pop_when_disabled_is_noop() {
        let mut p = Profiler::new();
        p.push("zone");
        p.pop();
        p.end_frame();
        assert!(p.frames.is_empty());
    }

    #[test]
    fn enabled_push_pop_records_zone() {
        let mut p = Profiler::new();
        p.enabled = true;
        p.push("update");
        p.pop();
        p.end_frame();
        assert_eq!(p.frames.len(), 1);
        assert!(!p.frames[0].is_empty());
        assert_eq!(p.frames[0][0].name, "update");
    }

    #[test]
    fn nested_zones_build_tree() {
        let mut p = Profiler::new();
        p.enabled = true;
        p.push("outer");
        p.push("inner");
        p.pop();
        p.pop();
        p.end_frame();
        let frame = &p.frames[0];
        assert_eq!(frame.len(), 1);
        assert_eq!(frame[0].name, "outer");
        assert_eq!(frame[0].children.len(), 1);
        assert_eq!(frame[0].children[0].name, "inner");
    }

    #[test]
    fn profile_zone_self_time() {
        let zone = ProfileZone {
            name: "parent".to_string(),
            start_time: 0.0,
            end_time: 1.0,
            children: vec![ProfileZone {
                name: "child".to_string(),
                start_time: 0.2,
                end_time: 0.5,
                children: vec![],
            }],
        };
        assert!((zone.total_time() - 1.0).abs() < f64::EPSILON);
        assert!((zone.self_time() - 0.7).abs() < 0.001);
    }

    #[test]
    fn flatten_collects_all_zones() {
        let zone = ProfileZone {
            name: "a".to_string(),
            start_time: 0.0,
            end_time: 1.0,
            children: vec![ProfileZone {
                name: "b".to_string(),
                start_time: 0.1,
                end_time: 0.5,
                children: vec![],
            }],
        };
        let flat = zone.flatten();
        assert_eq!(flat.len(), 2);
    }

    #[test]
    fn max_frames_eviction() {
        let mut p = Profiler::new();
        p.enabled = true;
        p.max_frames = 3;
        for _ in 0..5 {
            p.push("z");
            p.pop();
            p.end_frame();
        }
        assert_eq!(p.frames.len(), 3);
    }

    #[test]
    fn reset_clears_everything() {
        let mut p = Profiler::new();
        p.enabled = true;
        p.push("z");
        p.pop();
        p.end_frame();
        p.reset();
        assert!(p.frames.is_empty());
    }
}

// ── logger ────────────────────────────────────────────────────────────────────

mod logger_tests {
    use lurek2d::devtools::logger::{LogLevel, Logger};

    #[test]
    fn log_level_roundtrip() {
        for name in &["trace", "debug", "info", "warn", "error", "fatal"] {
            let level = LogLevel::from_str(name).unwrap();
            assert_eq!(level.as_str(), *name);
        }
    }

    #[test]
    fn log_level_parse_unknown_returns_none() {
        assert!(LogLevel::from_str("verbose").is_none());
    }

    #[test]
    fn logger_push_respects_min_level() {
        let mut logger = Logger::new();
        logger.console_enabled = false;
        logger.min_level = LogLevel::Warn;
        logger.push("info", "should be filtered", "test", 1, None);
        assert!(logger.history.is_empty());
        logger.push("warn", "should pass", "test", 2, None);
        assert_eq!(logger.history.len(), 1);
    }

    #[test]
    fn logger_tail_returns_last_n() {
        let mut logger = Logger::new();
        logger.console_enabled = false;
        for i in 0..10 {
            logger.push("info", &format!("msg{i}"), "test", i, None);
        }
        let tail = logger.tail(Some(3));
        assert_eq!(tail.len(), 3);
        assert_eq!(tail[0].message, "msg7");
    }

    #[test]
    fn logger_filter_category() {
        let mut logger = Logger::new();
        logger.console_enabled = false;
        logger.push("info", "a", "test", 1, Some("audio"));
        logger.push("info", "b", "test", 2, Some("physics"));
        logger.push("info", "c", "test", 3, Some("audio_mixer"));
        let filtered = logger.filter_category("audio");
        assert_eq!(filtered.len(), 2);
    }

    #[test]
    fn logger_clear_empties_history() {
        let mut logger = Logger::new();
        logger.console_enabled = false;
        logger.push("info", "msg", "test", 1, None);
        logger.clear();
        assert!(logger.history.is_empty());
    }

    #[test]
    fn logger_max_history_eviction() {
        let mut logger = Logger::new();
        logger.console_enabled = false;
        logger.max_history = 5;
        for i in 0..10 {
            logger.push("info", &format!("msg{i}"), "test", i, None);
        }
        assert_eq!(logger.history.len(), 5);
    }
}
