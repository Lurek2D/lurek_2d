# serial

## General Info

- Module group: `Foundations`
- Source path: `src/serial/`
- Lua API path(s): `src/lua_api/serial_api.rs`
- Primary Lua namespace: `lurek.serial`
- Rust test path(s): tests/rust/unit/serial_tests.rs; inline tests in src/serial/csv.rs, src/serial/json.rs, src/serial/toml.rs, src/serial/yaml.rs, src/serial/lua_table.rs, src/serial/msgpack.rs, src/serial/schema.rs, src/serial/xml.rs
- Lua test path(s): tests/lua/unit/test_serial.lua

## Summary

## Summary

The `serial` module provides Lurek2D's format-agnostic text and binary serialisation — a Foundations tier module with no Lurek2D imports. Its central type is `SerialValue`, a recursive enum (`Null`, `Bool`, `Int(i64)`, `Float(f64)`, `Str(String)`, `Seq(Vec<SerialValue>)`, `Map(IndexMap<String, SerialValue>)`) that acts as the common intermediate representation shared by every format driver. This decouples JSON, TOML, CSV, MessagePack, and Lua-table conversion from one another — each driver converts to/from `SerialValue` independently.

**TOML.** The preferred human-authored config format per binding constraint B-05. `to_toml(v)` serialises a `SerialValue` tree to a TOML string; `from_toml(s)` parses back. TOML imposes a table root and rejects null values — `to_toml` enforces these constraints at serialisation time, returning a descriptive `EngineError` for values that cannot be expressed in valid TOML. Used by `save`, `config`, `mods`, and game project configuration files.

**JSON.** For external API interop via `serde_json`: `to_json(v)` and `from_json(s)`. JSON supports null values and array roots. Pretty-print option via `JsonOptions::pretty`. Used by `network` (HTTP bodies) and `analytics` (event records). Per B-05 JSON is external-interop only — human-authored files use TOML.

**CSV.** `CsvOptions` configures header presence, delimiter character (default comma), and quote character. `to_csv(rows, opts)` serialises a `Vec<SerialValue::Map>` to CSV with header row. `from_csv(text, opts)` parses to a sequence of maps keyed by column name, or to a sequence of sequences without headers. Used by `dataframe` for data export.

**MessagePack.** Compact binary encoding/decoding via `rmp-serde`. `encode_msgpack(v)` returns a `Vec<u8>`; `decode_msgpack(bytes)` returns `SerialValue`. Uses `MsgValue` as an intermediate serde-compatible mirror type. Recommended format for all `network` application-level messages and `serial`-backed binary data blobs. 3-5x smaller than equivalent JSON for numeric-heavy game state.

**XML.** Read-only parsing via `roxmltree`: `decode_xml(s)` returns a nested `SerialValue::Map` tree representing element names, attributes (under `"@attrs"` key), and children. Write support is not provided — XML generation is out of scope per the engine's format policy. Used for importing third-party asset metadata (e.g. TMX tilemap files, Spine skeleton XML).

**YAML.** Excluded per constraint B-05. `yaml.rs` exists on disk as a stub but is intentionally not compiled or re-exported from `mod.rs`. Any attempt to use YAML should be redirected to TOML.

**Schema validation.** `validate(value, schema)` in `schema.rs` performs structural validation: required key presence, value-type constraints, optional field presence, and numeric range checks against a `SerialValue` schema descriptor. Returns a sorted list of human-readable error strings. Used by `config` to validate `conf.toml` at boot and by game code to validate mod manifests.

**Lua bridge.** `to_lua(sv, lua)` and `from_lua(lua_val)` in `lua_table.rs` convert between `SerialValue` trees and `mlua::Value` trees, enabling `serial_api.rs` to accept and return native Lua tables for every serialisation call. The `lurek.serial` namespace exposes: `fromJson(str)`, `toJson(table, opts)`, `fromToml(str)`, `toToml(table)`, `fromCsv(str, opts)`, `toCsv(rows, opts)`, `encodeMsgPack(table)` → bytes, `decodeMsgPack(bytes)`, `decodeXml(str)`, `validate(table, schema)` → errors array.

**No file I/O.** This module performs no file I/O — callers supply strings or byte slices and receive strings or byte slices. File reading and writing is the responsibility of `filesystem`. The `save` module calls `to_toml`/`from_toml`; the `data` module builds on top of serial encoders for binary storage formats.

**Scope boundary.** Foundations tier. Depends only on external crates: `toml`, `serde_json`, `csv`, `rmp-serde`, `roxmltree`, `indexmap`. No Lurek2D imports. Lua bridge in `src/lua_api/serial_api.rs`.

## Files

- `csv.rs`: Parses and writes CSV using `CsvOptions`, with support for header-based row maps or positional row sequences.
- `json.rs`: Converts between JSON text and `SerialValue`, including the module's only built-in structured success logging.
- `lua_table.rs`: Defines `SerialValue` plus generic conversion between that tree and Lua values and tables.
- `mod.rs`: Declares the active format drivers and re-exports the public serialization surface used by the Lua bridge and Rust callers.
- `msgpack.rs`: MessagePack encoding and decoding for Lurek2D.
- `schema.rs`: Schema validation for Lurek2D serialized values.
- `toml.rs`: Converts between TOML text and `SerialValue`, enforcing TOML-specific constraints such as a table root and no null values.
- `xml.rs`: XML parsing for Lurek2D (read-only).
- `yaml.rs`: Implements YAML conversion helpers on disk, but the module root does not compile or re-export it.

## Types

- `CsvOptions` (`struct`, `csv.rs`): Configuration for CSV parsing and encoding. It controls delimiter choice and whether the first row should be treated as headers.
- `SerialValue` (`enum`, `lua_table.rs`): Common intermediate representation shared by every active text format driver. It is the central type that keeps JSON, TOML, CSV, and Lua-table conversion decoupled from one another.
- `MsgValue` (`enum`, `msgpack.rs`): A serde-compatible mirror of `SerialValue` used as the msgpack bridge.

## Functions

- `from_csv` (`csv.rs`): Parse a CSV string into a `SerialValue`.
- `to_csv` (`csv.rs`): Serialize a `SerialValue` to a CSV string.
- `from_json` (`json.rs`): Parse a JSON string into a `SerialValue`.
- `to_json` (`json.rs`): Serialize a `SerialValue` to a JSON string.
- `to_lua` (`lua_table.rs`): Converts a `SerialValue` tree into a Lua value tree.
- `from_lua` (`lua_table.rs`): Converts a Lua value tree into a `SerialValue` tree.
- `encode` (`msgpack.rs`): Encode a `SerialValue` tree to MessagePack bytes.
- `decode` (`msgpack.rs`): Parse an XML string into a `SerialValue` tree.
- `validate` (`schema.rs`): Validate a `SerialValue` tree against a schema.
- `from_toml` (`toml.rs`): Parse a TOML string into a `SerialValue`.
- `to_toml` (`toml.rs`): Serialize a `SerialValue` to a TOML string.
- `decode` (`xml.rs`): Parse an XML string into a `SerialValue` tree.
- `from_yaml` (`yaml.rs`): Parse a YAML string into a `SerialValue`.
- `to_yaml` (`yaml.rs`): Serialize a `SerialValue` to a YAML string.

## Lua API Reference

- Binding path(s): `src/lua_api/serial_api.rs`
- Namespace: `lurek.serial`

### Module Functions
- `lurek.serial.fromJson`: Parses a JSON string and returns a Lua table.
- `lurek.serial.toJson`: Serializes a Lua value to a JSON string.
- `lurek.serial.fromToml`: Parses a TOML string and returns a Lua table.
- `lurek.serial.toToml`: Serializes a Lua table to a TOML string.
- `lurek.serial.fromCsv`: Parses a CSV string and returns a sequence of row tables.
- `lurek.serial.toCsv`: Serializes a sequence of row tables to a CSV string.
- `lurek.serial.encodeMsgPack`: Encodes a Lua table to a binary MessagePack string.
- `lurek.serial.decodeMsgPack`: Decodes a binary MessagePack string into a Lua table.
- `lurek.serial.decodeXml`: Parses an XML string and returns a nested Lua table.
- `lurek.serial.validate`: Validates a Lua table against a schema table.

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/serial/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
