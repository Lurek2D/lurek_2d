//! File: tests/rust/unit/save_tests.rs

use lurek2d::save::*;
use mlua::prelude::{Lua, LuaValue};
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
        assert_eq!(
            serialize_value(&SaveValue::Bool(true), 0).expect("bool"),
            "true"
        );
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

    #[test]
    fn slot_path_rejects_path_traversal_and_invalid_names() {
        let sm = SaveManager::new();
        assert!(sm.slot_path_checked("../evil").is_err());
        assert!(sm.slot_path_checked("/tmp/x").is_err());
        assert!(sm.slot_path_checked("").is_err());
        assert!(sm.slot_path_checked(&"a".repeat(65)).is_err());
        assert_eq!(
            sm.slot_path_checked("valid_slot-1")
                .expect("validated slot"),
            "save/slot_valid_slot-1.sav"
        );
    }

    #[test]
    fn migration_plan_reports_missing_steps() {
        let mut sm = SaveManager::new();
        sm.set_schema_version(4);
        sm.add_migration(1);
        sm.add_migration(3);
        let err = sm.migration_plan(1).expect_err("missing step");
        assert!(err.to_string().contains("2"));
    }

    #[test]
    fn parse_rejects_deep_or_huge_table() {
        let mut nested = String::from("return ");
        for _ in 0..10 {
            nested.push_str("{ child = ");
        }
        nested.push_str("1");
        for _ in 0..10 {
            nested.push('}');
        }
        let deep_limits = SaveParseLimits {
            max_depth: 4,
            ..SaveParseLimits::default()
        };
        assert!(parse_save_table_with_limits(&nested, &deep_limits).is_err());

        let huge_string = format!("return {{ text = \"{}\" }}", "x".repeat(32));
        let string_limits = SaveParseLimits {
            max_string_chars: 8,
            ..SaveParseLimits::default()
        };
        assert!(parse_save_table_with_limits(&huge_string, &string_limits).is_err());
    }

    #[test]
    fn from_lua_rejects_cyclic_table() {
        let lua = Lua::new();
        let table = lua.create_table().expect("table");
        table.set("self", table.clone()).expect("cycle");
        let err =
            SaveValue::from_lua_with_limits(&LuaValue::Table(table), &SaveLuaLimits::default())
                .expect_err("cyclic table should fail");
        assert!(err.to_string().contains("cyclic"));
    }

    #[test]
    fn save_rejects_nan_inf_numbers() {
        let nan_err =
            SaveValue::from_lua(&LuaValue::Number(f64::NAN)).expect_err("nan should fail");
        assert!(nan_err.to_string().contains("non-finite"));

        let inf_err = serialize_value(&SaveValue::Number(f64::INFINITY), 0)
            .expect_err("infinity should fail");
        assert!(inf_err.contains("non-finite"));

        let parsed_err = parse_save_table("return { value = 1e999 }").expect_err("infinite parse");
        assert!(parsed_err.contains("non-finite"));
    }

    #[test]
    fn auto_save_rejects_invalid_interval_and_dt() {
        let mut sm = SaveManager::new();
        assert!(sm.enable_auto_save(0.0, "auto").is_err());
        assert!(sm.enable_auto_save(f64::NAN, "auto").is_err());
        assert!(sm.enable_auto_save(-1.0, "auto").is_err());

        sm.enable_auto_save(0.5, "auto").expect("valid autosave");
        sm.mark_dirty();
        assert_eq!(sm.update(f64::NAN), None);
        assert_eq!(sm.update(-0.1), None);
        assert_eq!(
            sm.diagnostics().last(),
            Some("delta time must be finite and >= 0 seconds (got -0.1)")
        );
    }

    #[test]
    fn decompress_rejects_output_over_limit() {
        let plain = format!("return {{ blob = \"{}\" }}\n", "x".repeat(256));
        let compressed = compress_save_content(&plain).expect("compress");
        let limits = SaveCompressionLimits {
            max_decompressed_bytes: 64,
            ..SaveCompressionLimits::default()
        };
        let err = decompress_save_content_with_limits(&compressed, &limits)
            .expect_err("limit should reject payload");
        assert!(err.to_string().contains("decompressed bytes"));
    }

    #[test]
    fn compressed_header_checksum_detects_corruption() {
        let plain = "return { hp = 10 }\n";
        let compressed = compress_save_content(plain).expect("compress");
        let mut lines: Vec<String> = compressed.lines().map(str::to_string).collect();
        let header = &mut lines[0];
        let checksum_pos = header.find("sha256=").expect("checksum field") + "sha256=".len();
        let corrupt_pos = checksum_pos;
        let replacement = if &header[corrupt_pos..corrupt_pos + 1] == "a" {
            "b"
        } else {
            "a"
        };
        header.replace_range(corrupt_pos..corrupt_pos + 1, replacement);
        let corrupt = format!("{}\n{}\n", lines[0], lines[1]);
        let err = decompress_save_content(&corrupt).expect_err("checksum mismatch");
        assert!(err.contains("checksum"));
    }
}
