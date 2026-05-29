//! INTERNAL ONLY: Rust-only tests for logging helpers that are not directly asserted through
//! `lurek.log.*`.
//!
//! Public log configuration behaviour is covered by `tests/lua/unit/test_log_unit.lua`.
//! The remaining Rust tests keep internal level parsing and sink-level helper
//! invariants.

mod log_mod_tests {
    use lurek2d::log::{get_level, set_level};

    #[test]
    fn set_level_accepts_warning_alias() {
        set_level("warning");
        assert_eq!(get_level(), "warn");
    }

    #[test]
    fn set_level_rejects_unknown_and_keeps_previous() {
        set_level("info");
        set_level("garbage");
        assert_eq!(get_level(), "info");
    }
}

mod sinks_tests {
    use lurek2d::log::sinks::SinkLevel;

    #[test]
    fn sink_level_from_str_defaults_to_debug() {
        assert_eq!(
            "unknown".parse::<SinkLevel>().unwrap_or(SinkLevel::Debug),
            SinkLevel::Debug
        );
        assert_eq!(
            "".parse::<SinkLevel>().unwrap_or(SinkLevel::Debug),
            SinkLevel::Debug
        );
    }

    #[test]
    fn sink_level_from_str_parses_known_levels() {
        assert_eq!("info".parse::<SinkLevel>().unwrap(), SinkLevel::Info);
        assert_eq!("TRACE".parse::<SinkLevel>().unwrap(), SinkLevel::Trace);
        assert_eq!("WARN".parse::<SinkLevel>().unwrap(), SinkLevel::Warn);
        assert_eq!("Error".parse::<SinkLevel>().unwrap(), SinkLevel::Error);
        assert_eq!("warning".parse::<SinkLevel>().unwrap(), SinkLevel::Warn);
        assert_eq!("err".parse::<SinkLevel>().unwrap(), SinkLevel::Error);
    }

    #[test]
    fn sink_level_as_str_roundtrip() {
        assert_eq!(SinkLevel::Debug.as_str(), "DEBUG");
        assert_eq!(SinkLevel::Trace.as_str(), "TRACE");
        assert_eq!(SinkLevel::Info.as_str(), "INFO");
        assert_eq!(SinkLevel::Warn.as_str(), "WARN");
        assert_eq!(SinkLevel::Error.as_str(), "ERROR");
    }

    #[test]
    fn sink_level_ordering() {
        assert!(SinkLevel::Debug < SinkLevel::Info);
        assert!(SinkLevel::Debug < SinkLevel::Trace);
        assert!(SinkLevel::Trace < SinkLevel::Info);
        assert!(SinkLevel::Info < SinkLevel::Warn);
        assert!(SinkLevel::Warn < SinkLevel::Error);
    }
}
