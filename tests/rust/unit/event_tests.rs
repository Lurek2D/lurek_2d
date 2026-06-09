//! File: tests/rust/unit/event_tests.rs

// TODO(lua-first): public Rust API coverage in this file should live in tests/lua/unit/; keep only private/internal seams here.

use lurek2d::event::Signal;

#[test]
fn wildcard_empty_pattern_matches_only_empty_name() {
    let mut signal = Signal::new();
    let handle = signal.subscribe_wildcard("");
    let empty_match = signal.get_wildcard_handles("");
    let non_empty_match = signal.get_wildcard_handles("x");

    assert_eq!(empty_match, vec![handle]);
    assert!(non_empty_match.is_empty());
}
