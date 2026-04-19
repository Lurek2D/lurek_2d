//! Tests for the save module.

use lurek2d::save::*;
use std::collections::HashMap;

// ── save_manager tests ───────────────────────────────────────────────────────

mod save_manager_tests {
    use super::*;

    #[test]
    fn save_manager_defaults() {
        let sm = SaveManager::new();
        assert_eq!(sm.schema_version(), 0);
        assert!(!sm.is_dirty());
        assert!(sm.registered_names().is_empty());
    }

    #[test]
    fn register_unregister() {
        let mut sm = SaveManager::new();
        sm.register("player");
        sm.register("inventory");
        assert_eq!(sm.registered_names().len(), 2);
        sm.unregister("player");
        assert_eq!(sm.registered_names(), &["inventory"]);
    }

    #[test]
    fn dirty_tracking() {
        let mut sm = SaveManager::new();
        assert!(!sm.is_dirty());
        sm.mark_dirty();
        assert!(sm.is_dirty());
        sm.clear_dirty();
        assert!(!sm.is_dirty());
    }

    #[test]
    fn auto_save_triggers() {
        let mut sm = SaveManager::new();
        sm.enable_auto_save(5.0, "quick");
        sm.mark_dirty();
        assert!(sm.update(4.0).is_none());
        assert_eq!(sm.update(1.5).unwrap(), "quick");
    }

    #[test]
    fn auto_save_not_when_clean() {
        let mut sm = SaveManager::new();
        sm.enable_auto_save(1.0, "slot");
        assert!(sm.update(2.0).is_none()); // not dirty
    }

    #[test]
    fn migrations() {
        let mut sm = SaveManager::new();
        sm.set_schema_version(5);
        sm.add_migration(1);
        sm.add_migration(3);
        sm.add_migration(7); // above current
        let applicable = sm.applicable_migrations(2);
        assert_eq!(applicable, vec![3]);
    }

    #[test]
    fn serialize_simple() {
        let mut data = HashMap::new();
        data.insert("name".to_string(), SaveValue::Str("hero".to_string()));
        data.insert("level".to_string(), SaveValue::Number(5.0));
        data.insert("active".to_string(), SaveValue::Bool(true));
        let s = serialize_table(&data, 0).unwrap();
        assert!(s.contains("name = \"hero\""));
        assert!(s.contains("level = 5"));
        assert!(s.contains("active = true"));
    }

    #[test]
    fn serialize_depth_limit() {
        let inner = HashMap::new();
        let mut current = SaveValue::Table(inner);
        for _ in 0..35 {
            let mut t = HashMap::new();
            t.insert("nested".to_string(), current);
            current = SaveValue::Table(t);
        }
        if let SaveValue::Table(t) = current {
            let result = serialize_table(&t, 0);
            assert!(result.is_err());
        }
    }

    #[test]
    fn reset_clears_all() {
        let mut sm = SaveManager::new();
        sm.register("a");
        sm.set_schema_version(3);
        sm.mark_dirty();
        sm.enable_auto_save(1.0, "slot");
        sm.reset();
        assert!(!sm.is_dirty());
        assert_eq!(sm.schema_version(), 0);
        assert!(sm.registered_names().is_empty());
    }

    #[test]
    fn slot_path_format() {
        assert_eq!(SaveManager::slot_path("quick"), "save/slot_quick.sav");
        assert_eq!(SaveManager::slot_path("1"), "save/slot_1.sav");
    }

    #[test]
    fn summary_set_and_get() {
        let mut sm = SaveManager::new();
        assert_eq!(sm.summary(), "");
        sm.set_summary("Chapter 3 — Forest".to_string());
        assert_eq!(sm.summary(), "Chapter 3 — Forest");
    }

    #[test]
    fn parse_save_string_rejects_empty() {
        assert!(SaveManager::parse_save_string("").is_err());
        assert!(SaveManager::parse_save_string("   \n  ").is_err());
    }

    #[test]
    fn parse_save_string_accepts_content() {
        let result = SaveManager::parse_save_string("return { hp = 10 }");
        assert!(result.is_ok());
        assert_eq!(result.unwrap(), "return { hp = 10 }");
    }

    #[test]
    fn serialize_nil_and_bool() {
        assert_eq!(serialize_value(&SaveValue::Nil, 0).unwrap(), "nil");
        assert_eq!(serialize_value(&SaveValue::Bool(true), 0).unwrap(), "true");
        assert_eq!(serialize_value(&SaveValue::Bool(false), 0).unwrap(), "false");
    }

    #[test]
    fn serialize_string_escapes() {
        let val = SaveValue::Str("line1\nline2".to_string());
        let s = serialize_value(&val, 0).unwrap();
        assert_eq!(s, "\"line1\\nline2\"");
    }

    #[test]
    fn serialize_nested_table() {
        let mut inner = HashMap::new();
        inner.insert("x".to_string(), SaveValue::Number(1.0));
        let mut outer = HashMap::new();
        outer.insert("pos".to_string(), SaveValue::Table(inner));
        let s = serialize_table(&outer, 0).unwrap();
        assert!(s.contains("pos = {"));
        assert!(s.contains("x = 1"));
    }

    #[test]
    fn register_duplicate_is_noop() {
        let mut sm = SaveManager::new();
        sm.register("player");
        sm.register("player");
        assert_eq!(sm.registered_names().len(), 1);
    }

    #[test]
    fn disable_auto_save_stops_timer() {
        let mut sm = SaveManager::new();
        sm.enable_auto_save(1.0, "slot");
        sm.mark_dirty();
        sm.disable_auto_save();
        assert!(sm.update(5.0).is_none());
    }

    #[test]
    fn add_migration_deduplicates_and_sorts() {
        let mut sm = SaveManager::new();
        sm.set_schema_version(10);
        sm.add_migration(5);
        sm.add_migration(3);
        sm.add_migration(5); // duplicate
        sm.add_migration(1);
        let migrations = sm.applicable_migrations(0);
        assert_eq!(migrations, vec![1, 3, 5]);
    }

    #[test]
    fn serialize_special_key_needs_bracket() {
        let mut data = HashMap::new();
        data.insert("has space".to_string(), SaveValue::Number(1.0));
        let s = serialize_table(&data, 0).unwrap();
        assert!(s.contains("[\"has space\"] = 1"));
    }

    #[test]
    fn slot_meta_default() {
        let meta = SlotMeta::default();
        assert_eq!(meta.slot, "");
        assert_eq!(meta.timestamp, 0.0);
        assert_eq!(meta.version, 0);
        assert_eq!(meta.summary, "");
    }
}
