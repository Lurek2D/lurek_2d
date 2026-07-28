//! This module re-exports the serialization subsystem surface for codecs, formats, Lua bridging, and schema helpers.
//! It is the navigation map for shared value representation, text or binary translation, and validation boundaries.
//! `codec.rs` dispatches format-aware encode and decode entry points, while `lua_table.rs` owns the shared value tree.
//! `json.rs`, `toml.rs`, `csv.rs`, `xml.rs`, `ini.rs`, and `msgpack.rs` each implement one concrete format path.
//! `schema.rs` applies defaults and validates decoded trees before those values flow into runtime or tooling code.
//! Change this file when the public serialization symbol map moves; change siblings when format behavior changes.

/// Unified codec: format detection, encode, and decode entry points.
pub mod codec;
/// CSV parsing and generation with configurable options.
pub mod csv;
/// INI file parser. This module is publicly re-exported.
pub mod ini;
/// JSON serialization and deserialization.
pub mod json;
/// SerialValue type bridging Lua tables and Rust data.
pub mod lua_table;
/// MessagePack binary encode/decode.
pub mod msgpack;
/// Schema validation and default-value application.
pub mod schema;
/// TOML parsing and encoding. This module is publicly re-exported.
pub mod toml;
/// XML decoding. This module is publicly re-exported.
pub mod xml;
pub use codec::{
    decode_bytes, decode_bytes_with_options, decode_bytes_with_schema, decode_text,
    decode_text_detailed, decode_text_with_schema, detect_format, detect_format_detailed, encode,
    DecodeOptions, DecodeReport, DecodedValue, EncodeOptions, EncodedValue, SerialFormat,
    SerializeError, SerializeLimitKind, SerializeLimits,
};
pub use csv::{from_csv, to_csv, CsvComplexCellPolicy, CsvOptions};
pub use ini::from_ini;
pub use json::{from_json, to_json};
pub use lua_table::{
    canonical_encode, canonical_hash, from_lua_with_limits, validate_serial_value, SerialValue,
};
pub use msgpack::{decode as from_msgpack, decode_json, encode as to_msgpack, encode_json};
pub use schema::{
    apply_defaults as apply_schema_defaults, apply_defaults_with_report,
    validate as validate_schema, validation_errors, DefaultsApplied,
};
pub use toml::{encode_toml, from_toml, parse_toml, to_toml};
pub use xml::decode as from_xml;
