# serialize

## TL;DR

- Translates JSON, TOML, CSV, XML, INI, and MessagePack via one intermediate tree.
- Validates data against schemas.

## General Info

- Module group: `Foundations`
- Source path: `src/serialize/`
- Binding: `src/lua_api/serialize_api.rs`
- Namespace: `lurek.serial`
- Lua API surface: `16` functions, `0` types, `0` methods
- Rust test path(s): tests/rust/unit/serial_tests.rs
- Lua test path(s): tests/lua/unit/test_serialize_unit.lua

## Summary

- The `serialize` module is the format-translation surface for users who want several external data formats to map into one shared runtime value model.
- JSON, TOML, CSV, XML, INI, MessagePack, schemas, and codec entrypoints all matter here because a project often needs to move content between several representations without rewriting conversion logic each time.
- The module is useful both for loading or saving data and for validating whether data actually fits the expected structure after translation.
- Its shared intermediate tree is the key user-facing idea: several formats can participate in the same workflows because they resolve into one common serial representation.
- That shared representation is what makes cross-format tooling practical. A validator, exporter, or transform step can reason about one normalized value model instead of reimplementing logic for every source format separately.
- That shared model keeps cross-format validation and conversion workflows in one place.
- Read `serialize` as the normalization layer for structured data. Other modules decide what the data means, but `serialize` decides how that data is parsed, validated, and emitted across supported formats.


## Imports

- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Foundations` into `Core Runtime`.

## Files

### codec.rs

- This file owns the format-agnostic serialization front door for text and binary payloads across supported formats.
- It defines `SerialFormat`, encode or decode options, and the `EncodedValue` result used by top-level callers.
- Format detection inspects text content, while explicit routing sends MessagePack through byte decoding only.
- Encode and decode helpers centralize dispatch so callers do not need per-format branching spread across modules.
- Open this file when top-level serialization routing changes; concrete format implementations live in siblings.

### csv.rs

- This file owns CSV translation between delimited rows and the shared `SerialValue` tree used by the engine.
- It defines `CsvOptions`, parses header-aware or positional records, and serializes row sequences back to text.
- Header mode maps columns into ordered maps, while headerless mode keeps each record as a plain value sequence.
- Encoding enforces compatible row shapes so CSV assumptions stay aligned between read and write operations.
- Open this file when tabular serialization rules change; generic dispatch and value-tree ownership live nearby.

### ini.rs

- This file owns INI decoding for simple sectioned key-value configuration that fits the shared serial tree.
- It parses comments, section headers, and `key=value` assignments into ordered root and nested section maps.
- Top-level keys remain at the root, while named sections become child maps under their section identifiers.
- Open this file when INI parsing rules change; generic codec dispatch and other formats live in sibling files.

### json.rs

- This file owns JSON translation between `serde_json::Value` and the engine's shared `SerialValue` tree.
- It parses input text, converts scalars, arrays, and objects, and emits compact or pretty JSON output on demand.
- Ordered maps and JSON-specific success logging live here so structure and instrumentation stay format-local.
- Open this file when JSON mapping rules change; codec dispatch and Lua bridging remain in sibling modules.

### lua_table.rs

- This file owns `SerialValue` plus Lua conversion helpers that bridge dynamic Lua values into serializable Rust data.
- It decides whether Lua tables become sequences or maps, while preserving scalars, nulls, and string-keyed content.
- `to_lua` rebuilds Lua primitives and tables from decoded values so serialized data can round-trip through scripts.
- Array detection is structural and automatic, which keeps callers from tagging plain Lua tables before encoding.
- Open this file when shared value semantics change; concrete text and binary codecs live in sibling modules.

### mod.rs

- This module re-exports the serialization subsystem surface for codecs, formats, Lua bridging, and schema helpers.
- It is the navigation map for shared value representation, text or binary translation, and validation boundaries.
- `codec.rs` dispatches format-aware encode and decode entry points, while `lua_table.rs` owns the shared value tree.
- `json.rs`, `toml.rs`, `csv.rs`, `xml.rs`, `ini.rs`, and `msgpack.rs` each implement one concrete format path.
- `schema.rs` applies defaults and validates decoded trees before those values flow into runtime or tooling code.
- Change this file when the public serialization symbol map moves; change siblings when format behavior changes.

### msgpack.rs

- This file owns MessagePack translation for compact binary serialization of the shared `SerialValue` tree.
- It converts through a local `MsgValue` bridge that matches serde-based MessagePack encoding and decoding needs.
- Size estimation, trailing-byte checks, and JSON-value helpers keep binary workflows predictable for callers.
- Logging lives here so MessagePack-specific encode and decode activity stays next to the binary conversion path.
- Open this file when MessagePack mapping changes; generic dispatch and shared value ownership live nearby.

### schema.rs

- This file owns schema validation and default application for decoded `SerialValue` trees before runtime use.
- Validation checks required fields, declared types, numeric limits, string lengths, nested fields, and array items.
- Errors include dotted paths so content authors can find the exact subtree that violates a schema contract.
- Default application walks the same tree shape, filling missing fields or items from schema-provided fallback values.
- Schema pass and fail logging also lives here because validation is a common content-ingestion debugging boundary.
- Open this file when structural validation rules change; format parsers and Lua conversion live in sibling files.

### toml.rs

- This file owns TOML translation between human-edited configuration text and the shared `SerialValue` tree.
- It parses raw TOML, converts value trees in both directions, and encodes table-shaped output back to text.
- Datetime values are normalized into strings, while nulls are rejected because TOML has no native null value.
- Open this file when TOML mapping rules change; generic codec dispatch and other formats live in sibling files.

### xml.rs

- This file owns XML decoding into the shared `SerialValue` tree for element, attribute, text, and child structure.
- It reshapes each node into a map containing tag name, optional attrs, optional text, and optional child sequences.
- The mapping keeps XML hierarchy explicit so importers can inspect one predictable tree instead of raw DOM APIs.
- Open this file when XML-to-value rules change; generic dispatch and non-XML codecs live in sibling modules.



## Lua API Ref

### Functions

- `lurek.serial.applyDefaults(value, schema) -> table`: Merges a schema's default values into a data table, filling in any missing fields without overwriting existing ones. Use this to ensure game config or save data always has complete fields even when the user provides only partial overrides.
- `lurek.serial.decode(payload, format?, opts?) -> table`: Universal decoder that parses a string payload into a Lua table using the specified format. If no format is given, auto-detects from the content. Supports JSON, TOML, CSV, XML, INI, and MessagePack. Use this as a single entry point when handling files of varying or unknown formats.
- `lurek.serial.decodeMsgPack(bytes) -> table`: Decodes a binary MessagePack string back into a Lua table. Use this to read save files, network packets, or any data previously encoded with encodeMsgPack.
- `lurek.serial.decodeXml(text) -> table`: Parses an XML string into a Lua table structure. Elements become nested tables with tag names as keys. Useful for loading Tiled map exports, SVG data, UI layout definitions, or other XML-based game assets.
- `lurek.serial.detectFormat(text) -> string`: Attempts to auto-detect the serialization format of a string by inspecting its content (e.g., leading `{` for JSON, `[section]` for INI, XML declaration for XML). Returns the format name or nil if detection fails. Useful for loading user-provided files where the format is unknown.
- `lurek.serial.encode(value, format, opts?) -> string`: Universal encoder that serializes a Lua value into the specified format. Supports JSON, TOML, CSV, and MessagePack. Returns a string (text for JSON/TOML/CSV, binary for MessagePack). Use this as a single entry point for all serialization needs.
- `lurek.serial.encodeMsgPack(value) -> string`: Encodes a Lua table into a compact binary MessagePack string. MessagePack is faster and smaller than JSON, making it ideal for save files, network packets, or any scenario where performance matters more than human readability. The argument must be a table.
- `lurek.serial.encodeMsgPack(value) -> string`: Encodes a Lua table into a compact binary MessagePack string. MessagePack is faster and smaller than JSON, making it ideal for save files, network packets, or any scenario where performance matters more than human readability. The argument must be a table.
- `lurek.serial.fromCsv(text, delimiter?, hasHeaders?) -> table`: Parses a CSV string into a Lua table (array of rows). Each row is either a keyed table (when headers are present) or an indexed array of field values. Useful for loading spreadsheet exports, leaderboard data, or tabular game data.
- `lurek.serial.fromIni(text) -> table`: Parses an INI-format string into a Lua table. Sections become nested tables, and key-value pairs become string fields. Useful for legacy config files or simple settings.
- `lurek.serial.fromJson(text) -> table`: Parses a JSON string into a Lua table. Use this to load configuration files, network responses, or any structured data stored as JSON.
- `lurek.serial.fromToml(text) -> table`: Parses a TOML string into a Lua table. Ideal for loading game configuration files, level definitions, and engine settings stored in TOML format.
- `lurek.serial.toCsv(value, delimiter?, hasHeaders?) -> string`: Serializes a Lua table (array of row tables) into a CSV-formatted string. Each row table should have consistent keys or be an indexed array. Use this to export leaderboards, save tabular data, or generate spreadsheet-compatible output.
- `lurek.serial.toJson(value, pretty?) -> string`: Serializes a Lua value (table, string, number, boolean, or nil) into a JSON string. Useful for saving game state, writing config files, or preparing network payloads.
- `lurek.serial.toToml(value) -> string`: Serializes a Lua table into a TOML-formatted string. Use this to write configuration files, save structured settings, or export data in a human-readable format.
- `lurek.serial.validate(value, schema) -> boolean`: Validates a Lua value against a schema table. The schema defines expected types, required fields, and constraints. Returns a success boolean and an optional error message string describing the first validation failure. Use this to verify save data integrity or user-provided configuration before processing.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

- No documented module types.

## References

- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Foundations` into `Core Runtime`.

## Notes

- No additional module-specific notes.
