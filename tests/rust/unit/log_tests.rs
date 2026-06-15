//! File: tests/rust/unit/log_tests.rs

// TODO(lua-first): public Rust API coverage in this file should live in tests/lua/unit/; keep only private/internal seams here.

mod sinks_tests {
    use lurek2d::log::sinks::{Sink, SinkLevel};
    use std::time::{SystemTime, UNIX_EPOCH};

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
        assert!(SinkLevel::Trace < SinkLevel::Debug);
        assert!(SinkLevel::Debug < SinkLevel::Info);
        assert!(SinkLevel::Trace < SinkLevel::Info);
        assert!(SinkLevel::Info < SinkLevel::Warn);
        assert!(SinkLevel::Warn < SinkLevel::Error);
    }

    #[test]
    fn debug_sink_filters_out_trace_messages() {
        let sink = Sink::memory(1, 8, SinkLevel::Debug);
        sink.write(SinkLevel::Trace, "Lua", "trace");
        sink.write(SinkLevel::Debug, "Lua", "debug");

        let entries = sink.read_memory(false).unwrap();
        assert_eq!(entries.len(), 1);
        assert_eq!(entries[0].message, "debug");
        assert_eq!(entries[0].level, SinkLevel::Debug);
    }

    #[test]
    fn flush_writes_buffered_plain_file_sink_contents() {
        let unique = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_nanos();
        let path = std::env::temp_dir().join(format!("lurek_log_flush_{unique}.log"));
        let sink = Sink::file(1, path.to_str().unwrap(), SinkLevel::Trace).unwrap();

        sink.write(SinkLevel::Info, "Lua", "flush-me");
        assert_eq!(std::fs::read_to_string(&path).unwrap_or_default(), "");

        sink.flush();

        let content = std::fs::read_to_string(&path).unwrap();
        assert!(content.contains("flush-me"));

        let _ = std::fs::remove_file(path);
    }
}
