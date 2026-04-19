//! Tests for the serial module.

// ── json ──────────────────────────────────────────────────────────────────────

mod json_tests {
    use lurek2d::serial::{from_json, to_json, SerialValue};

    #[test]
    fn round_trip_bool_and_number() {
        let val = SerialValue::Seq(vec![SerialValue::Bool(true), SerialValue::Int(42)]);
        let json = to_json(&val, false).unwrap();
        let parsed = from_json(&json).unwrap();
        match parsed {
            SerialValue::Seq(v) => {
                assert_eq!(v.len(), 2);
                assert!(matches!(v[0], SerialValue::Bool(true)));
            }
            other => panic!("expected Seq, got {:?}", other),
        }
    }

    #[test]
    fn from_json_string_value() {
        let result = from_json(r#""hello""#).unwrap();
        assert!(matches!(result, SerialValue::Str(s) if s == "hello"));
    }
}

// ── csv ───────────────────────────────────────────────────────────────────────

mod csv_tests {
    use lurek2d::serial::{from_csv, CsvOptions, SerialValue};

    #[test]
    fn from_csv_with_headers_returns_seq_of_maps() {
        let csv = "name,score\nalice,10\nbob,20\n";
        let result = from_csv(csv, CsvOptions::default()).unwrap();
        match result {
            SerialValue::Seq(rows) => {
                assert_eq!(rows.len(), 2);
                match &rows[0] {
                    SerialValue::Map(m) => {
                        assert!(matches!(m.get("name"), Some(SerialValue::Str(s)) if s == "alice"));
                    }
                    other => panic!("expected Map, got {:?}", other),
                }
            }
            other => panic!("expected Seq, got {:?}", other),
        }
    }

    #[test]
    fn from_csv_no_headers_returns_seq_of_seqs() {
        let csv = "a,b\nc,d\n";
        let opts = CsvOptions { has_headers: false, ..CsvOptions::default() };
        let result = from_csv(csv, opts).unwrap();
        match result {
            SerialValue::Seq(rows) => assert_eq!(rows.len(), 2),
            other => panic!("expected Seq, got {:?}", other),
        }
    }
}

// ── toml ──────────────────────────────────────────────────────────────────────

mod toml_tests {
    use lurek2d::serial::{from_toml, to_toml, SerialValue};

    #[test]
    fn round_trip_simple_table() {
        let src = "[section]\nkey = \"value\"\nnum = 42\n";
        let parsed = from_toml(src).unwrap();
        let back = to_toml(&parsed).unwrap();
        // Should round-trip without error; check key presence
        assert!(back.contains("key"));
        assert!(back.contains("value"));
    }

    #[test]
    fn from_toml_integer_preserved() {
        let src = "[t]\nn = 7\n";
        let parsed = from_toml(src).unwrap();
        match parsed {
            SerialValue::Map(m) => match m.get("t") {
                Some(SerialValue::Map(inner)) => {
                    assert!(matches!(inner.get("n"), Some(SerialValue::Int(7))));
                }
                _ => panic!("expected nested map"),
            },
            other => panic!("expected Map, got {:?}", other),
        }
    }
}

// ── xml ───────────────────────────────────────────────────────────────────────

mod xml_tests {
    use lurek2d::serial::xml::decode;
    use lurek2d::serial::SerialValue;

    #[test]
    fn decode_simple_element() {
        let val = decode("<root/>").unwrap();
        match val {
            SerialValue::Map(m) => {
                assert!(matches!(m.get("tag"), Some(SerialValue::Str(s)) if s == "root"));
            }
            other => panic!("expected Map, got {:?}", other),
        }
    }

    #[test]
    fn decode_element_with_attributes() {
        let val = decode(r#"<item id="1" name="test"/>"#).unwrap();
        match val {
            SerialValue::Map(m) => match m.get("attrs") {
                Some(SerialValue::Map(attrs)) => {
                    assert!(matches!(attrs.get("id"), Some(SerialValue::Str(s)) if s == "1"));
                    assert!(matches!(attrs.get("name"), Some(SerialValue::Str(s)) if s == "test"));
                }
                other => panic!("expected attrs Map, got {:?}", other),
            },
            other => panic!("expected Map, got {:?}", other),
        }
    }

    #[test]
    fn decode_element_with_text() {
        let val = decode("<msg>hello world</msg>").unwrap();
        match val {
            SerialValue::Map(m) => {
                assert!(matches!(m.get("text"), Some(SerialValue::Str(s)) if s == "hello world"));
            }
            other => panic!("expected Map, got {:?}", other),
        }
    }

    #[test]
    fn decode_nested_children() {
        let val = decode("<root><a/><b/></root>").unwrap();
        match val {
            SerialValue::Map(m) => match m.get("children") {
                Some(SerialValue::Seq(children)) => assert_eq!(children.len(), 2),
                other => panic!("expected children Seq, got {:?}", other),
            },
            other => panic!("expected Map, got {:?}", other),
        }
    }

    #[test]
    fn decode_empty_element_has_no_text_key() {
        let val = decode("<empty/>").unwrap();
        match val {
            SerialValue::Map(m) => {
                assert!(m.get("text").is_none());
                assert!(m.get("children").is_none());
            }
            other => panic!("expected Map, got {:?}", other),
        }
    }

    #[test]
    fn decode_invalid_xml_returns_error() {
        assert!(decode("<not<valid>").is_err());
    }
}

// ── schema ────────────────────────────────────────────────────────────────────

mod schema_tests {
    use lurek2d::serial::schema::validate;
    use lurek2d::serial::SerialValue;
    use indexmap::IndexMap;

    /// Build a schema `SerialValue::Map` from key-value pairs.
    fn schema(entries: Vec<(&str, SerialValue)>) -> SerialValue {
        let mut map = IndexMap::new();
        for (k, v) in entries {
            map.insert(k.to_string(), v);
        }
        SerialValue::Map(map)
    }

    #[test]
    fn type_string_pass() {
        let s = schema(vec![("type", SerialValue::Str("string".to_string()))]);
        assert!(validate(&SerialValue::Str("hello".to_string()), &s).is_ok());
    }

    #[test]
    fn type_string_fail_on_int() {
        let s = schema(vec![("type", SerialValue::Str("string".to_string()))]);
        assert!(validate(&SerialValue::Int(42), &s).is_err());
    }

    #[test]
    fn type_number_accepts_int_and_float() {
        let s = schema(vec![("type", SerialValue::Str("number".to_string()))]);
        assert!(validate(&SerialValue::Int(7), &s).is_ok());
        assert!(validate(&SerialValue::Float(3.14), &s).is_ok());
    }

    #[test]
    fn type_boolean_pass() {
        let s = schema(vec![("type", SerialValue::Str("boolean".to_string()))]);
        assert!(validate(&SerialValue::Bool(false), &s).is_ok());
    }

    #[test]
    fn required_rejects_null() {
        let s = schema(vec![("required", SerialValue::Bool(true))]);
        assert!(validate(&SerialValue::Null, &s).is_err());
    }

    #[test]
    fn optional_allows_null() {
        let s = schema(vec![("required", SerialValue::Bool(false))]);
        assert!(validate(&SerialValue::Null, &s).is_ok());
    }

    #[test]
    fn numeric_min_max_range() {
        let s = schema(vec![
            ("type", SerialValue::Str("number".to_string())),
            ("min", SerialValue::Int(1)),
            ("max", SerialValue::Int(100)),
        ]);
        assert!(validate(&SerialValue::Int(50), &s).is_ok());
        assert!(validate(&SerialValue::Int(0), &s).is_err());
        assert!(validate(&SerialValue::Int(101), &s).is_err());
    }

    #[test]
    fn string_length_bounds() {
        let s = schema(vec![
            ("type", SerialValue::Str("string".to_string())),
            ("minlen", SerialValue::Int(2)),
            ("maxlen", SerialValue::Int(5)),
        ]);
        assert!(validate(&SerialValue::Str("ab".to_string()), &s).is_ok());
        assert!(validate(&SerialValue::Str("a".to_string()), &s).is_err());
        assert!(validate(&SerialValue::Str("abcdef".to_string()), &s).is_err());
    }

    #[test]
    fn nested_fields_validation() {
        let mut field_schemas = IndexMap::new();
        field_schemas.insert(
            "name".to_string(),
            schema(vec![
                ("type", SerialValue::Str("string".to_string())),
                ("required", SerialValue::Bool(true)),
            ]),
        );
        let s = schema(vec![
            ("type", SerialValue::Str("table".to_string())),
            ("fields", SerialValue::Map(field_schemas)),
        ]);
        let mut val_map = IndexMap::new();
        val_map.insert("name".to_string(), SerialValue::Str("alice".to_string()));
        assert!(validate(&SerialValue::Map(val_map), &s).is_ok());

        // Missing required field triggers error
        let empty_map = IndexMap::new();
        assert!(validate(&SerialValue::Map(empty_map), &s).is_err());
    }

    #[test]
    fn sequence_items_validation() {
        let item_schema = schema(vec![("type", SerialValue::Str("number".to_string()))]);
        let s = schema(vec![
            ("type", SerialValue::Str("table".to_string())),
            ("items", item_schema),
        ]);
        let good = SerialValue::Seq(vec![SerialValue::Int(1), SerialValue::Int(2)]);
        assert!(validate(&good, &s).is_ok());

        let bad = SerialValue::Seq(vec![
            SerialValue::Int(1),
            SerialValue::Str("x".to_string()),
        ]);
        assert!(validate(&bad, &s).is_err());
    }

    #[test]
    fn any_type_accepts_everything() {
        let s = schema(vec![("type", SerialValue::Str("any".to_string()))]);
        assert!(validate(&SerialValue::Int(1), &s).is_ok());
        assert!(validate(&SerialValue::Str("x".to_string()), &s).is_ok());
        assert!(validate(&SerialValue::Bool(true), &s).is_ok());
    }

    #[test]
    fn unknown_type_returns_error() {
        let s = schema(vec![("type", SerialValue::Str("foobar".to_string()))]);
        assert!(validate(&SerialValue::Int(1), &s).is_err());
    }

    #[test]
    fn non_map_schema_returns_error() {
        assert!(validate(&SerialValue::Int(1), &SerialValue::Int(0)).is_err());
    }
}

// ── msgpack ───────────────────────────────────────────────────────────────────

mod msgpack_tests {
    use lurek2d::serial::msgpack::{decode, encode};
    use lurek2d::serial::SerialValue;
    use indexmap::IndexMap;

    #[test]
    fn round_trip_null() {
        let bytes = encode(&SerialValue::Null).unwrap();
        let back = decode(&bytes).unwrap();
        assert!(matches!(back, SerialValue::Null));
    }

    #[test]
    fn round_trip_bool() {
        let bytes = encode(&SerialValue::Bool(true)).unwrap();
        let back = decode(&bytes).unwrap();
        assert!(matches!(back, SerialValue::Bool(true)));
    }

    #[test]
    fn round_trip_int() {
        let bytes = encode(&SerialValue::Int(42)).unwrap();
        let back = decode(&bytes).unwrap();
        assert!(matches!(back, SerialValue::Int(42)));
    }

    #[test]
    fn round_trip_float() {
        let bytes = encode(&SerialValue::Float(3.14)).unwrap();
        let back = decode(&bytes).unwrap();
        match back {
            SerialValue::Float(f) => assert!((f - 3.14).abs() < 1e-10),
            other => panic!("expected Float, got {:?}", other),
        }
    }

    #[test]
    fn round_trip_string() {
        let bytes = encode(&SerialValue::Str("hello".to_string())).unwrap();
        let back = decode(&bytes).unwrap();
        assert!(matches!(back, SerialValue::Str(ref s) if s == "hello"));
    }

    #[test]
    fn round_trip_seq() {
        let val = SerialValue::Seq(vec![SerialValue::Int(1), SerialValue::Int(2)]);
        let bytes = encode(&val).unwrap();
        let back = decode(&bytes).unwrap();
        match back {
            SerialValue::Seq(v) => assert_eq!(v.len(), 2),
            other => panic!("expected Seq, got {:?}", other),
        }
    }

    #[test]
    fn round_trip_nested_map() {
        let mut inner = IndexMap::new();
        inner.insert("a".to_string(), SerialValue::Int(1));
        let mut outer = IndexMap::new();
        outer.insert("nested".to_string(), SerialValue::Map(inner));
        let val = SerialValue::Map(outer);
        let bytes = encode(&val).unwrap();
        let back = decode(&bytes).unwrap();
        match back {
            SerialValue::Map(m) => assert!(m.contains_key("nested")),
            other => panic!("expected Map, got {:?}", other),
        }
    }

    #[test]
    fn decode_invalid_bytes_returns_error() {
        // 0xC1 is a reserved/never-used msgpack format byte
        let result = decode(&[0xC1]);
        assert!(result.is_err());
    }
}

// ── lua_table ─────────────────────────────────────────────────────────────────

mod lua_table_tests {
    use lurek2d::serial::lua_table::{from_lua, to_lua, SerialValue};
    use indexmap::IndexMap;
    use mlua::prelude::*;

    #[test]
    fn to_lua_null_becomes_nil() {
        let lua = Lua::new();
        let val = to_lua(&lua, &SerialValue::Null).unwrap();
        assert!(matches!(val, LuaValue::Nil));
    }

    #[test]
    fn to_lua_bool_preserved() {
        let lua = Lua::new();
        let val = to_lua(&lua, &SerialValue::Bool(true)).unwrap();
        assert!(matches!(val, LuaValue::Boolean(true)));
    }

    #[test]
    fn to_lua_int_preserved() {
        let lua = Lua::new();
        let val = to_lua(&lua, &SerialValue::Int(42)).unwrap();
        assert!(matches!(val, LuaValue::Integer(42)));
    }

    #[test]
    fn to_lua_float_preserved() {
        let lua = Lua::new();
        let val = to_lua(&lua, &SerialValue::Float(3.14)).unwrap();
        match val {
            LuaValue::Number(n) => assert!((n - 3.14).abs() < 1e-10),
            other => panic!("expected Number, got {:?}", other),
        }
    }

    #[test]
    fn to_lua_string_preserved() {
        let lua = Lua::new();
        let val = to_lua(&lua, &SerialValue::Str("hello".to_string())).unwrap();
        match val {
            LuaValue::String(s) => assert_eq!(s.to_str().unwrap(), "hello"),
            other => panic!("expected String, got {:?}", other),
        }
    }

    #[test]
    fn round_trip_seq() {
        let lua = Lua::new();
        let original = SerialValue::Seq(vec![
            SerialValue::Int(1),
            SerialValue::Int(2),
            SerialValue::Int(3),
        ]);
        let lua_val = to_lua(&lua, &original).unwrap();
        let back = from_lua(&lua_val).unwrap();
        match back {
            SerialValue::Seq(v) => {
                assert_eq!(v.len(), 3);
                assert!(matches!(v[0], SerialValue::Int(1)));
            }
            other => panic!("expected Seq, got {:?}", other),
        }
    }

    #[test]
    fn round_trip_map() {
        let lua = Lua::new();
        let mut map = IndexMap::new();
        map.insert("key".to_string(), SerialValue::Str("val".to_string()));
        let original = SerialValue::Map(map);
        let lua_val = to_lua(&lua, &original).unwrap();
        let back = from_lua(&lua_val).unwrap();
        match back {
            SerialValue::Map(m) => {
                assert!(matches!(m.get("key"), Some(SerialValue::Str(s)) if s == "val"));
            }
            other => panic!("expected Map, got {:?}", other),
        }
    }

    #[test]
    fn from_lua_whole_number_coerces_to_int() {
        // Lua Number 5.0 with zero fractional part should coerce to Int(5)
        let val = LuaValue::Number(5.0);
        let sv = from_lua(&val).unwrap();
        assert!(matches!(sv, SerialValue::Int(5)));
    }

    #[test]
    fn from_lua_fractional_number_stays_float() {
        let val = LuaValue::Number(3.14);
        let sv = from_lua(&val).unwrap();
        match sv {
            SerialValue::Float(f) => assert!((f - 3.14).abs() < 1e-10),
            other => panic!("expected Float, got {:?}", other),
        }
    }

    #[test]
    fn from_lua_rejects_unsupported_types() {
        let lua = Lua::new();
        let func = lua.create_function(|_, ()| Ok(())).unwrap();
        let val = LuaValue::Function(func);
        assert!(from_lua(&val).is_err());
    }
}
