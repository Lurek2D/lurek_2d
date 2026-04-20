//! Tests for the log module.

use std::collections::BTreeMap;

// ── log mod ───────────────────────────────────────────────────────────────────

mod log_mod_tests {
    use lurek2d::log::*;

    #[test]
    fn enabled_for_off_returns_false() {
        assert!(!enabled_for("off"));
        assert!(!enabled_for("none"));
    }

    #[test]
    fn enabled_for_unknown_returns_false() {
        assert!(!enabled_for("garbage"));
        assert!(!enabled_for(""));
    }

    #[test]
    fn log_structured_empty_fields_produces_plain_message() {
        // Smoke test: does not panic with empty fields
        let fields = LogFields::new();
        log_structured(::log::Level::Info, Some("test"), "hello", &fields);
    }

    #[test]
    fn log_structured_with_fields_does_not_panic() {
        let mut fields = LogFields::new();
        fields.insert("key".to_string(), "value".to_string());
        log_structured(::log::Level::Debug, None, "msg", &fields);
    }

    #[test]
    fn get_level_returns_string() {
        let level = get_level();
        // Level is always a non-empty string
        assert!(!level.is_empty());
    }

    #[test]
    fn log_structured_all_levels_do_not_panic() {
        let fields = LogFields::new();
        for &lvl in &[
            ::log::Level::Error,
            ::log::Level::Warn,
            ::log::Level::Info,
            ::log::Level::Debug,
            ::log::Level::Trace,
        ] {
            log_structured(lvl, Some("test"), "msg", &fields);
        }
    }

    #[test]
    fn log_structured_default_tag_does_not_panic() {
        let mut fields = LogFields::new();
        fields.insert("a".into(), "1".into());
        fields.insert("b".into(), "2".into());
        // tag = None should default to "Lua"
        log_structured(::log::Level::Warn, None, "multi-field", &fields);
    }

    #[test]
    fn enabled_for_recognises_warning_alias() {
        // "warning" is an alias for "warn"
        let warn_result = enabled_for("warn");
        let warning_result = enabled_for("warning");
        assert_eq!(warn_result, warning_result);
    }

    #[test]
    fn set_level_does_not_panic() {
        // Smoke: calling with both valid and invalid values should not panic.
        set_level("info");
        set_level("nonsense");
    }
}

// ── sinks ─────────────────────────────────────────────────────────────────────

mod sinks_tests {
    use lurek2d::log::{Sink, SinkLevel, SinkRegistry};
    use std::collections::BTreeMap;

    // ── SinkLevel ─────────────────────────────────────────────────────────

    #[test]
    fn sink_level_from_str_defaults_to_debug() {
        assert_eq!(SinkLevel::from_str("unknown"), SinkLevel::Debug);
        assert_eq!(SinkLevel::from_str(""), SinkLevel::Debug);
    }

    #[test]
    fn sink_level_from_str_parses_known_levels() {
        assert_eq!(SinkLevel::from_str("info"), SinkLevel::Info);
        assert_eq!(SinkLevel::from_str("WARN"), SinkLevel::Warn);
        assert_eq!(SinkLevel::from_str("Error"), SinkLevel::Error);
        assert_eq!(SinkLevel::from_str("warning"), SinkLevel::Warn);
        assert_eq!(SinkLevel::from_str("err"), SinkLevel::Error);
    }

    #[test]
    fn sink_level_as_str_roundtrip() {
        assert_eq!(SinkLevel::Debug.as_str(), "DEBUG");
        assert_eq!(SinkLevel::Info.as_str(), "INFO");
        assert_eq!(SinkLevel::Warn.as_str(), "WARN");
        assert_eq!(SinkLevel::Error.as_str(), "ERROR");
    }

    #[test]
    fn sink_level_ordering() {
        assert!(SinkLevel::Debug < SinkLevel::Info);
        assert!(SinkLevel::Info < SinkLevel::Warn);
        assert!(SinkLevel::Warn < SinkLevel::Error);
    }

    // ── SinkRegistry ──────────────────────────────────────────────────────

    #[test]
    fn registry_add_assigns_incremental_ids() {
        let mut reg = SinkRegistry::new();
        let s1 = Sink::memory(0, 10, SinkLevel::Debug);
        let s2 = Sink::memory(0, 10, SinkLevel::Debug);
        let id1 = reg.add(s1);
        let id2 = reg.add(s2);
        assert!(id2 > id1);
    }

    #[test]
    fn registry_remove_by_id() {
        let mut reg = SinkRegistry::new();
        let s = Sink::memory(0, 10, SinkLevel::Debug);
        let id = reg.add(s);
        assert!(reg.remove(id));
        assert!(!reg.remove(id)); // already removed
    }

    #[test]
    fn registry_clear_removes_all() {
        let mut reg = SinkRegistry::new();
        reg.add(Sink::memory(0, 10, SinkLevel::Debug));
        reg.add(Sink::memory(0, 10, SinkLevel::Debug));
        reg.clear();
        assert!(reg.sinks.is_empty());
    }

    // ── Memory sink ───────────────────────────────────────────────────────

    #[test]
    fn memory_sink_stores_entries() {
        let sink = Sink::memory(1, 5, SinkLevel::Debug);
        sink.write(SinkLevel::Info, "test", "hello");
        let entries = sink.read_memory(false).unwrap();
        assert_eq!(entries.len(), 1);
        assert_eq!(entries[0].message, "hello");
    }

    #[test]
    fn memory_sink_respects_capacity() {
        let sink = Sink::memory(1, 2, SinkLevel::Debug);
        sink.write(SinkLevel::Info, "t", "a");
        sink.write(SinkLevel::Info, "t", "b");
        sink.write(SinkLevel::Info, "t", "c");
        let entries = sink.read_memory(false).unwrap();
        // Capacity is 2, oldest should be evicted
        assert_eq!(entries.len(), 2);
        assert_eq!(entries[0].message, "b");
    }

    #[test]
    fn memory_sink_drain_clears_buffer() {
        let sink = Sink::memory(1, 10, SinkLevel::Debug);
        sink.write(SinkLevel::Info, "t", "msg");
        let drained = sink.read_memory(true).unwrap();
        assert_eq!(drained.len(), 1);
        let remaining = sink.read_memory(false).unwrap();
        assert!(remaining.is_empty());
    }

    #[test]
    fn sink_write_below_min_level_is_noop() {
        let sink = Sink::memory(1, 10, SinkLevel::Warn);
        sink.write(SinkLevel::Debug, "t", "should be dropped");
        sink.write(SinkLevel::Info, "t", "also dropped");
        let entries = sink.read_memory(false).unwrap();
        assert!(entries.is_empty());
    }

    #[test]
    fn sink_type_name_returns_correct_strings() {
        let mem = Sink::memory(1, 10, SinkLevel::Debug);
        assert_eq!(mem.type_name(), "memory");
    }

    // ── Structured writes ─────────────────────────────────────────────────

    #[test]
    fn memory_sink_stores_structured_fields() {
        let sink = Sink::memory(1, 10, SinkLevel::Debug);
        let mut fields = BTreeMap::new();
        fields.insert("key".into(), "val".into());
        sink.write_structured(SinkLevel::Info, "t", "hello", &fields);
        let entries = sink.read_memory(false).unwrap();
        assert_eq!(entries.len(), 1);
        assert!(entries[0].fields.is_some());
        assert_eq!(entries[0].fields.as_ref().unwrap()["key"], "val");
    }

    #[test]
    fn write_structured_below_level_is_noop() {
        let sink = Sink::memory(1, 10, SinkLevel::Error);
        let fields = BTreeMap::new();
        sink.write_structured(SinkLevel::Info, "t", "dropped", &fields);
        let entries = sink.read_memory(false).unwrap();
        assert!(entries.is_empty());
    }

    // ── Sink path / read_memory on non-memory ─────────────────────────────

    #[test]
    fn memory_sink_path_returns_none() {
        let sink = Sink::memory(1, 10, SinkLevel::Debug);
        assert!(sink.path().is_none());
    }

    #[test]
    fn memory_sink_capacity_clamps_to_one() {
        // Passing capacity=0 should be clamped to 1.
        let sink = Sink::memory(1, 0, SinkLevel::Debug);
        sink.write(SinkLevel::Info, "t", "a");
        let entries = sink.read_memory(false).unwrap();
        assert_eq!(entries.len(), 1);
    }

    // ── Registry dispatch ─────────────────────────────────────────────────

    #[test]
    fn registry_dispatch_fans_out_to_all_sinks() {
        let mut reg = SinkRegistry::new();
        reg.add(Sink::memory(0, 10, SinkLevel::Debug));
        reg.add(Sink::memory(0, 10, SinkLevel::Debug));
        reg.dispatch(SinkLevel::Info, "t", "hello");
        for sink in &reg.sinks {
            let entries = sink.read_memory(false).unwrap();
            assert_eq!(entries.len(), 1);
        }
    }

    #[test]
    fn registry_dispatch_structured_fans_out() {
        let mut reg = SinkRegistry::new();
        reg.add(Sink::memory(0, 10, SinkLevel::Debug));
        let mut fields = BTreeMap::new();
        fields.insert("k".into(), "v".into());
        reg.dispatch_structured(SinkLevel::Warn, "t", "msg", &fields);
        let entries = reg.sinks[0].read_memory(false).unwrap();
        assert_eq!(entries.len(), 1);
        assert!(entries[0].fields.is_some());
    }

    #[test]
    fn registry_get_returns_correct_sink() {
        let mut reg = SinkRegistry::new();
        let id = reg.add(Sink::memory(0, 5, SinkLevel::Info));
        assert!(reg.get(id).is_some());
        assert!(reg.get(id + 999).is_none());
    }

    #[test]
    fn registry_remove_nonexistent_returns_false() {
        let mut reg = SinkRegistry::new();
        assert!(!reg.remove(42));
    }
}
