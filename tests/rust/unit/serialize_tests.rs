//! File: tests/rust/unit/serialize_tests.rs
//! Owns Rust-side coverage for private serialize limits, reports, and typed error paths.

use indexmap::IndexMap;
use lurek2d::serialize::{
    canonical_encode, canonical_hash, decode_bytes_with_options, decode_text,
    decode_text_with_schema, detect_format_detailed, encode, from_lua_with_limits, to_msgpack,
    CsvComplexCellPolicy, CsvOptions, DecodeOptions, EncodeOptions, SerialFormat, SerialValue,
    SerializeError, SerializeLimitKind, SerializeLimits,
};
use mlua::{Lua, Value as LuaValue};

fn serialize_schema() -> SerialValue {
    let mut hp_schema = IndexMap::new();
    hp_schema.insert("type".to_string(), SerialValue::Str("number".to_string()));
    hp_schema.insert("default".to_string(), SerialValue::Int(10));

    let mut name_schema = IndexMap::new();
    name_schema.insert("type".to_string(), SerialValue::Str("string".to_string()));
    name_schema.insert("required".to_string(), SerialValue::Bool(true));

    let mut fields = IndexMap::new();
    fields.insert("hp".to_string(), SerialValue::Map(hp_schema));
    fields.insert("name".to_string(), SerialValue::Map(name_schema));

    let mut schema = IndexMap::new();
    schema.insert("type".to_string(), SerialValue::Str("table".to_string()));
    schema.insert("fields".to_string(), SerialValue::Map(fields));
    SerialValue::Map(schema)
}

#[test]
fn canonical_encoding_sorts_nested_keys_and_hashes_stably() {
    let mut nested = IndexMap::new();
    nested.insert("z".to_string(), SerialValue::Int(2));
    nested.insert("a".to_string(), SerialValue::Int(1));
    let mut value = IndexMap::new();
    value.insert("nested".to_string(), SerialValue::Map(nested));
    value.insert("before".to_string(), SerialValue::Bool(true));
    let value = SerialValue::Map(value);
    let limits = SerializeLimits::default();

    let encoded = canonical_encode(&value, &limits).unwrap();
    assert_eq!(encoded, r#"{"before":true,"nested":{"a":1,"z":2}}"#);
    let hash = canonical_hash(&value, &limits).unwrap();
    assert_eq!(hash.len(), 16);
    assert_eq!(hash, canonical_hash(&value, &limits).unwrap());
}

#[test]
fn serialize_from_lua_rejects_cyclic_table() {
    let lua = Lua::new();
    let table: mlua::Table = lua
        .load("local t = {}; t.self = t; return t")
        .eval()
        .expect("cyclic table");

    let err = from_lua_with_limits(&LuaValue::Table(table), &SerializeLimits::default())
        .expect_err("cyclic table should fail");

    assert!(matches!(err, SerializeError::CyclicLuaTable { .. }));
}

#[test]
fn serialize_from_lua_rejects_huge_raw_len() {
    let lua = Lua::new();
    let table: mlua::Table = lua
        .load("local t = {}; for i = 1, 16 do t[i] = i end; return t")
        .eval()
        .expect("sequence table");
    let limits = SerializeLimits {
        max_sequence_len: 8,
        ..SerializeLimits::default()
    };

    let err = from_lua_with_limits(&LuaValue::Table(table), &limits)
        .expect_err("sequence length should be bounded");

    assert!(matches!(
        err,
        SerializeError::LimitExceeded {
            kind: SerializeLimitKind::SequenceLength,
            ..
        }
    ));
}

#[test]
fn serialize_rejects_nan_inf_numbers() {
    let err = from_lua_with_limits(
        &LuaValue::Number(f64::INFINITY),
        &SerializeLimits::default(),
    )
    .expect_err("lua infinity should fail");
    assert!(matches!(err, SerializeError::NonFiniteNumber { .. }));

    for value in [
        SerialValue::Float(f64::NAN),
        SerialValue::Float(f64::NEG_INFINITY),
    ] {
        let err = match encode(&value, SerialFormat::Json, EncodeOptions::default()) {
            Ok(_) => panic!("non-finite numbers should not encode"),
            Err(err) => err,
        };
        assert!(matches!(err, SerializeError::NonFiniteNumber { .. }));
    }
}

#[test]
fn detect_format_respects_input_and_attempt_limits() {
    let opts = DecodeOptions {
        limits: SerializeLimits {
            max_input_bytes: 4,
            ..SerializeLimits::default()
        },
        ..DecodeOptions::default()
    };
    let err = detect_format_detailed("12345", &opts).expect_err("input bytes should be bounded");
    assert!(matches!(
        err,
        SerializeError::LimitExceeded {
            kind: SerializeLimitKind::InputBytes,
            ..
        }
    ));

    let opts = DecodeOptions {
        limits: SerializeLimits {
            max_detect_attempts: 1,
            ..SerializeLimits::default()
        },
        allowed_formats: vec![SerialFormat::Json, SerialFormat::Toml],
        ..DecodeOptions::default()
    };
    let err = detect_format_detailed("title = \"demo\"", &opts)
        .expect_err("detect attempts should be bounded");
    assert!(matches!(
        err,
        SerializeError::LimitExceeded {
            kind: SerializeLimitKind::DetectAttempts,
            ..
        }
    ));
}

#[test]
fn msgpack_decode_rejects_nested_over_limit() {
    let nested = SerialValue::Seq(vec![SerialValue::Seq(vec![SerialValue::Seq(vec![
        SerialValue::Int(1),
    ])])]);
    let bytes = to_msgpack(&nested).expect("msgpack encode");
    let opts = DecodeOptions {
        limits: SerializeLimits {
            max_depth: 2,
            ..SerializeLimits::default()
        },
        ..DecodeOptions::default()
    };

    let err = decode_bytes_with_options(&bytes, SerialFormat::MsgPack, opts)
        .expect_err("deep msgpack should fail");

    assert!(matches!(
        err,
        SerializeError::LimitExceeded {
            kind: SerializeLimitKind::Depth,
            ..
        }
    ));
}

#[test]
fn csv_decode_respects_row_column_field_limits() {
    let err = decode_text(
        "name,score\nada,10\nlin,20\n",
        Some(SerialFormat::Csv),
        DecodeOptions {
            csv: CsvOptions {
                max_rows: 1,
                ..CsvOptions::default()
            },
            ..DecodeOptions::default()
        },
    )
    .expect_err("csv row limit should fail");
    assert!(matches!(
        err,
        SerializeError::Codec { context, message }
            if context == "decode_text" && message.contains("CsvRows limit exceeded")
    ));

    let err = decode_text(
        "name,score\nada,toolong\n",
        Some(SerialFormat::Csv),
        DecodeOptions {
            csv: CsvOptions {
                max_field_chars: 3,
                ..CsvOptions::default()
            },
            ..DecodeOptions::default()
        },
    )
    .expect_err("csv field limit should fail");
    assert!(matches!(
        err,
        SerializeError::Codec { context, message }
            if context == "decode_text" && message.contains("CsvFieldChars limit exceeded")
    ));

    let err = decode_text(
        "name,score\nada,10,extra\n",
        Some(SerialFormat::Csv),
        DecodeOptions {
            csv: CsvOptions {
                strict_column_count: true,
                ..CsvOptions::default()
            },
            ..DecodeOptions::default()
        },
    )
    .expect_err("strict column count should fail");
    assert!(matches!(
        err,
        SerializeError::Codec { context, message }
            if context == "decode_text" && message.contains("CSV parse error")
    ));
}

#[test]
fn csv_encode_rejects_complex_cell_in_strict_mode() {
    let mut row = IndexMap::new();
    row.insert(
        "payload".to_string(),
        SerialValue::Map(IndexMap::from([(
            "nested".to_string(),
            SerialValue::Int(1),
        )])),
    );
    let rows = SerialValue::Seq(vec![SerialValue::Map(row)]);

    let err = match encode(
        &rows,
        SerialFormat::Csv,
        EncodeOptions {
            csv: CsvOptions {
                complex_cells: CsvComplexCellPolicy::Reject,
                ..CsvOptions::default()
            },
            ..EncodeOptions::default()
        },
    ) {
        Ok(_) => panic!("nested csv cells should fail by default"),
        Err(err) => err,
    };

    assert!(matches!(
        err,
        SerializeError::Codec { context, message }
            if context == "encode"
                && message.contains("nested CSV cell values require complex_cells='json'")
    ));
}

#[test]
fn decode_with_schema_reports_defaults_and_errors() {
    let schema = serialize_schema();
    let decoded = decode_text_with_schema(
        "{\"name\":\"hero\"}",
        Some(SerialFormat::Json),
        &schema,
        DecodeOptions::default(),
    )
    .expect("schema defaults should apply");

    match decoded.value {
        SerialValue::Map(map) => {
            assert!(matches!(map.get("name"), Some(SerialValue::Str(name)) if name == "hero"));
            assert!(matches!(map.get("hp"), Some(SerialValue::Int(10))));
        }
        other => panic!("expected map, got {other:?}"),
    }
    assert_eq!(decoded.report.defaults_applied, vec!["$.hp".to_string()]);
    assert!(decoded.report.validation_errors.is_empty());

    let err = decode_text_with_schema(
        "{}",
        Some(SerialFormat::Json),
        &schema,
        DecodeOptions::default(),
    )
    .expect_err("required field should fail validation");

    match err {
        SerializeError::SchemaValidation { errors, .. } => {
            assert!(errors.iter().any(|entry| entry.contains("$.name")));
        }
        other => panic!("expected schema validation error, got {other:?}"),
    }
}

#[test]
fn serial_format_capability_flags() {
    assert!(SerialFormat::Json.can_encode());
    assert!(SerialFormat::Json.can_decode_text());
    assert!(!SerialFormat::Json.can_decode_bytes());

    assert!(!SerialFormat::Xml.can_encode());
    assert!(SerialFormat::Xml.can_decode_text());

    assert!(SerialFormat::MsgPack.can_encode());
    assert!(!SerialFormat::MsgPack.can_decode_text());
    assert!(SerialFormat::MsgPack.can_decode_bytes());
}
