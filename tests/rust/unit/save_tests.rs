//! File: tests/rust/unit/save_tests.rs

use lurek2d::save::*;
use std::collections::HashMap;

mod save_manager_tests {
    use super::*;

    #[test]
    fn migrations() {
        let mut sm = SaveManager::new();
        sm.set_schema_version(5);
        sm.add_migration(1);
        sm.add_migration(3);
        sm.add_migration(7);
        let applicable = sm.applicable_migrations(2);
        assert_eq!(applicable, vec![3]);
    }

    #[test]
    fn serialize_simple() {
        let mut data = HashMap::new();
        data.insert("name".to_string(), SaveValue::Str("hero".to_string()));
        data.insert("level".to_string(), SaveValue::Number(5.0));
        data.insert("active".to_string(), SaveValue::Bool(true));
        let s = serialize_table(&data, 0).expect("serialize");
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
    fn slot_path_format() {
        assert_eq!(SaveManager::slot_path("quick"), "save/slot_quick.sav");
        assert_eq!(SaveManager::slot_path("1"), "save/slot_1.sav");
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
        assert_eq!(result.expect("content"), "return { hp = 10 }");
    }

    #[test]
    fn serialize_nil_and_bool() {
        assert_eq!(serialize_value(&SaveValue::Nil, 0).expect("nil"), "nil");
        assert_eq!(serialize_value(&SaveValue::Bool(true), 0).expect("bool"), "true");
        assert_eq!(
            serialize_value(&SaveValue::Bool(false), 0).expect("bool"),
            "false"
        );
    }

    #[test]
    fn serialize_string_escapes() {
        let val = SaveValue::Str("line1\nline2".to_string());
        let s = serialize_value(&val, 0).expect("serialize");
        assert_eq!(s, "\"line1\\nline2\"");
    }

    #[test]
    fn serialize_nested_table() {
        let mut inner = HashMap::new();
        inner.insert("x".to_string(), SaveValue::Number(1.0));
        let mut outer = HashMap::new();
        outer.insert("pos".to_string(), SaveValue::Table(inner));
        let s = serialize_table(&outer, 0).expect("serialize");
        assert!(s.contains("pos = {"));
        assert!(s.contains("x = 1"));
    }

    #[test]
    fn add_migration_deduplicates_and_sorts() {
        let mut sm = SaveManager::new();
        sm.set_schema_version(10);
        sm.add_migration(5);
        sm.add_migration(3);
        sm.add_migration(5);
        sm.add_migration(1);
        let migrations = sm.applicable_migrations(0);
        assert_eq!(migrations, vec![1, 3, 5]);
    }

    #[test]
    fn serialize_special_key_needs_bracket() {
        let mut data = HashMap::new();
        data.insert("has space".to_string(), SaveValue::Number(1.0));
        let s = serialize_table(&data, 0).expect("serialize");
        assert!(s.contains("[\"has space\"] = 1"));
    }

    #[test]
    fn serialize_table_orders_keys_deterministically() {
        let mut data = HashMap::new();
        data.insert("zeta".to_string(), SaveValue::Number(1.0));
        data.insert("alpha".to_string(), SaveValue::Number(2.0));
        data.insert("middle value".to_string(), SaveValue::Number(3.0));

        let serialized = serialize_table(&data, 0).expect("serialize");
        let alpha = serialized.find("alpha = 2").expect("alpha");
        let middle = serialized.find("[\"middle value\"] = 3").expect("middle");
        let zeta = serialized.find("zeta = 1").expect("zeta");

        assert!(alpha < middle);
        assert!(middle < zeta);
    }

    #[test]
    fn slot_meta_default() {
        let meta = SlotMeta::default();
        assert_eq!(meta.slot, "");
        assert!(meta.timestamp.abs() < f64::EPSILON);
        assert_eq!(meta.version, 0);
        assert_eq!(meta.summary, "");
    }

    #[test]
    fn parse_save_table_round_trips_serialized_payload_without_eval() {
        let mut position = HashMap::new();
        position.insert("x".to_string(), SaveValue::Number(12.5));
        position.insert("y".to_string(), SaveValue::Bool(true));

        let mut data = HashMap::new();
        data.insert("name".to_string(), SaveValue::Str("hero".to_string()));
        data.insert("pos".to_string(), SaveValue::Table(position));

        let body = serialize_table(&data, 0).expect("serialize");
        let parsed = parse_save_table(&format!("return {}\n", body)).expect("parse");

        assert!(matches!(parsed.get("name"), Some(SaveValue::Str(name)) if name == "hero"));
        assert!(matches!(parsed.get("pos"), Some(SaveValue::Table(map))
            if matches!(map.get("x"), Some(SaveValue::Number(value)) if (*value - 12.5).abs() < f64::EPSILON)));
    }

    #[test]
    fn parse_save_table_rejects_non_table_code_payloads() {
        let err = parse_save_table("return (function() return 1 end)()").expect_err("reject");
        assert!(err.contains("unexpected save token") || err.contains("expected"));
    }

    #[test]
    fn compressed_save_content_round_trips_plain_payload() {
        let plain = "return {\n  name = \"hero\",\n}\n";
        let compressed = compress_save_content(plain).expect("compress");
        let restored = decompress_save_content(&compressed).expect("decompress");
        assert_eq!(restored, plain);
    }
}
