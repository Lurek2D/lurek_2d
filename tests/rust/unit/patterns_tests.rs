//! INTERNAL ONLY: Rust-only tests for pattern helper structures not directly asserted
//! through `lurek.patterns.*`.
//!
//! Lua-reachable pattern behavior belongs in `tests/lua/unit/test_patterns_core_unit.lua`.
//!
//! Remaining Rust coverage: BiMap, internal Blackboard fields, StackMeta/QueueMeta,
//! EventBus one-shot/disabled internals, StateMachine callback flags, and Trie.

use lurek2d::patterns::*;

// ── BiMap ────────────────────────────────────────────────────────────────────

mod bimap_tests {
    use super::*;

    #[test]
    fn insert_get_by_key_returns_value() {
        let mut m: BiMap<&str, u32> = BiMap::new();
        m.insert("health", 42);
        assert_eq!(m.get_by_key(&"health"), Some(&42));
    }

    #[test]
    fn get_by_value_returns_key() {
        let mut m: BiMap<&str, u32> = BiMap::new();
        m.insert("health", 42);
        assert_eq!(m.get_by_value(&42), Some(&"health"));
    }

    #[test]
    fn insert_same_key_removes_old_reverse() {
        let mut m: BiMap<&str, u32> = BiMap::new();
        m.insert("stat", 1);
        m.insert("stat", 2);
        assert!(!m.contains_value(&1));
        assert_eq!(m.get_by_key(&"stat"), Some(&2));
    }

    #[test]
    fn remove_by_key_removes_both_sides() {
        let mut m: BiMap<&str, u32> = BiMap::new();
        m.insert("x", 10);
        m.remove_by_key(&"x");
        assert!(!m.contains_key(&"x"));
        assert!(!m.contains_value(&10));
    }

    #[test]
    fn bijection_removes_stale_on_reinsert() {
        let mut m: BiMap<&str, u32> = BiMap::new();
        m.insert("k1", 100);
        m.insert("k2", 100);
        assert!(
            m.get_by_key(&"k1").is_none(),
            "k1 must be removed when k2 takes its value"
        );
        assert_eq!(m.get_by_key(&"k2"), Some(&100));
    }
}

// ── Blackboard ───────────────────────────────────────────────────────────────

mod blackboard_tests {
    use super::*;

    #[test]
    fn new_blackboard_is_empty() {
        let bb = Blackboard::new("test");
        assert!(bb.is_empty());
        assert_eq!(bb.len(), 0);
        assert_eq!(bb.revision, 0);
    }

    #[test]
    fn set_and_get_bool() {
        let mut bb = Blackboard::new("t");
        bb.set_bool("flag", true);
        assert_eq!(bb.get("flag"), Some(&BlackboardValue::Bool(true)));
    }

    #[test]
    fn set_and_get_number() {
        let mut bb = Blackboard::new("t");
        bb.set_number("hp", 42.0);
        assert_eq!(bb.get("hp"), Some(&BlackboardValue::Number(42.0)));
    }

    #[test]
    fn set_and_get_text() {
        let mut bb = Blackboard::new("t");
        bb.set_text("name", "hero".to_string());
        assert_eq!(bb.get("name"), Some(&BlackboardValue::Text("hero".into())));
    }

    #[test]
    fn clear_removes_key() {
        let mut bb = Blackboard::new("t");
        bb.set_bool("x", true);
        bb.remove("x");
        assert!(!bb.has("x"));
    }

    #[test]
    fn revision_increments_on_write() {
        let mut bb = Blackboard::new("t");
        bb.set_bool("a", true);
        assert_eq!(bb.revision, 1);
        bb.set_number("b", 1.0);
        assert_eq!(bb.revision, 2);
    }

    #[test]
    fn key_revision_tracks_per_key() {
        let mut bb = Blackboard::new("t");
        bb.set_bool("a", true);
        bb.set_bool("b", false);
        assert_eq!(bb.key_revision("a"), 1);
        assert_eq!(bb.key_revision("b"), 2);
    }

    #[test]
    fn clear_all_resets_everything() {
        let mut bb = Blackboard::new("t");
        bb.set_bool("a", true);
        bb.set_number("b", 2.0);
        bb.clear_all();
        assert!(bb.is_empty());
    }

    #[test]
    fn keys_returns_all_set_keys() {
        let mut bb = Blackboard::new("t");
        bb.set_bool("x", true);
        bb.set_bool("y", false);
        let keys = bb.keys();
        assert_eq!(keys.len(), 2);
    }

    #[test]
    fn snapshot_returns_pairs() {
        let mut bb = Blackboard::new("t");
        bb.set_number("hp", 100.0);
        let snap = bb.snapshot();
        assert_eq!(snap.len(), 1);
    }
}

// ── Collections ──────────────────────────────────────────────────────────────

mod collections_tests {
    use super::*;

    #[test]
    fn stack_meta_unlimited_never_full() {
        let s = StackMeta::new(0);
        assert!(!s.is_full(1_000_000));
    }

    #[test]
    fn stack_meta_capacity_enforced() {
        let s = StackMeta::new(5);
        assert!(!s.is_full(4));
        assert!(s.is_full(5));
    }

    #[test]
    fn queue_meta_unlimited_never_full() {
        let q = QueueMeta::new(0);
        assert!(!q.is_full(1_000_000));
    }

    #[test]
    fn queue_meta_capacity_enforced() {
        let q = QueueMeta::new(3);
        assert!(!q.is_full(2));
        assert!(q.is_full(3));
    }
}

// ── CommandStack ─────────────────────────────────────────────────────────────

mod event_bus_tests {
    use super::*;

    #[test]
    fn disabled_bus_returns_no_listeners() {
        let mut bus = EventBus::new("test");
        bus.subscribe("e", 0, false);
        bus.enabled = false;
        assert!(bus.get_listeners("e").is_empty());
    }

    #[test]
    fn drain_once_removes_one_shot_subs() {
        let mut bus = EventBus::new("test");
        let once_id = bus.subscribe("e", 0, true);
        let keep_id = bus.subscribe("e", 0, false);
        let listeners = bus.get_listeners("e");
        let removed = bus.drain_once(&listeners);
        assert!(removed.contains(&once_id));
        assert!(!removed.contains(&keep_id));
        assert_eq!(bus.total_count(), 1);
    }

    #[test]
    fn wildcard_subscriber_fires_for_all_events() {
        let mut bus = EventBus::new("test");
        let wc = bus.subscribe("*", 0, false);
        let listeners = bus.get_listeners("any_event");
        assert!(listeners.contains(&wc));
    }

    #[test]
    fn clear_event_removes_event_subs_only() {
        let mut bus = EventBus::new("test");
        bus.subscribe("a", 0, false);
        bus.subscribe("b", 0, false);
        bus.clear_event("a");
        assert_eq!(bus.listener_count("a"), 0);
        assert_eq!(bus.listener_count("b"), 1);
    }

    #[test]
    fn unsubscribe_removes_specific_handler() {
        let mut bus = EventBus::new("test");
        let id = bus.subscribe("e", 0, false);
        assert!(bus.unsubscribe(id));
        assert_eq!(bus.total_count(), 0);
    }
}

// ── Factory ──────────────────────────────────────────────────────────────────

// StateMachine transition API is internal; Lua uses behavior trees elsewhere.

mod state_machine_tests {
    use super::*;

    #[test]
    fn has_update_callback_flag() {
        let mut sm = StateMachine::new("test");
        sm.add_state("idle", false, false, true);
        assert!(sm.has_update_callback("idle"));
    }
}

mod trie_tests {
    use super::*;

    #[test]
    fn insert_search_finds_inserted_key() {
        let mut t = Trie::new();
        t.insert("hello");
        assert!(t.search("hello"));
        assert!(!t.search("hell"));
        assert!(!t.search("helloo"));
    }

    #[test]
    fn starts_with_returns_true() {
        let mut t = Trie::new();
        t.insert("apple");
        assert!(t.starts_with("app"));
    }

    #[test]
    fn prefix_search_returns_all_matches() {
        let mut t = Trie::new();
        t.insert("damage.fire");
        t.insert("damage.ice");
        t.insert("heal");
        let results = t.prefix_search("damage");
        assert_eq!(results.len(), 2);
        assert!(results.contains(&"damage.fire".to_string()));
        assert!(results.contains(&"damage.ice".to_string()));
    }

    #[test]
    fn remove_deletes_exact_key() {
        let mut t = Trie::new();
        t.insert("key");
        assert!(t.remove("key"));
        assert!(!t.search("key"));
    }

    #[test]
    fn search_missing_key_not_found() {
        let mut t = Trie::new();
        t.insert("apple");
        assert!(!t.search("app"));
    }
}
