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

- The serialize module gives users one multi-format surface for decoding, encoding, and validation.
- It supports JSON, TOML, CSV, XML, INI, and MessagePack through a shared intermediate value model.
- Automatic format detection helps ingest unknown text payloads in tool-style workflows.
- Lua table bridging converts between script data and typed serialized structures.
- Mixed Lua tables that combine array slots with named fields are preserved as maps instead of silently dropping named entries.
- Codec adapters isolate format-specific quirks so callers can use consistent APIs.
- Schema validation enforces structure and constraints before data reaches gameplay logic.
- Default-merge helpers fill missing fields from schema definitions.
- Path-specific validation errors make malformed data easier to diagnose quickly.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Foundations group rather than absorb behavior owned by those neighbors.

## Imports

- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Foundations` into `Core Runtime`.

## Files

### codec.rs

- This file provides the format-agnostic front door for serialization work across text and binary payloads. `serialize/codec` delivers the codec implementation for the serialize subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- It decides which codec to use, how to route decoding and encoding, and when content can be recognized automatically. The file owns or coordinates data contracts including `SerialFormat`, `DecodeOptions`, `EncodeOptions`, `EncodedValue`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Text and binary paths are separated here so callers can use one interface without collapsing all format quirks into one parser.
- The file is therefore the dispatcher that turns unknown serialized input into a chosen translation path. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### csv.rs

- This file translates between tabular CSV text and the engine's generic serial value tree. `serialize/csv` delivers the csv implementation for the serialize subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- It supports row-oriented data that may be keyed by headers or treated as plain positional sequences. The file owns or coordinates data contracts including `CsvOptions`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Delimiters, quoting behavior, and output shape are handled here so spreadsheet-style data stays usable without special caller code.
- Encoding and decoding live together because CSV round-trips depend on consistent assumptions about row structure. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### ini.rs

- This file handles INI-style configuration text for projects and tools that still prefer simple sectioned key-value documents.
- It converts section headers, assignments, and comments into a nested serial representation without pretending INI is richer than it is.
- Insertion order is preserved so output remains readable and familiar when round-tripped back toward human-edited config files.

### json.rs

- This file provides JSON translation to and from the engine's intermediate serial value tree. `serialize/json` delivers the json implementation for the serialize subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- It preserves the normal JSON shape of scalars, arrays, and objects while exposing that data through one engine-wide representation.
- Pretty and compact output choices live here because readable config and compact payloads are both common JSON use cases.

### lua_table.rs

- This file bridges the dynamic world of Lua tables and values into the typed intermediate tree used by the serialization subsystem.
- It decides when Lua data should be treated as sequences, maps, scalars, or explicit null-like values for downstream codecs.
- Array-like tables are recognized structurally so callers do not have to tag them manually before encoding. Public callable behavior is centered on `to_lua`, `from_lua`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- The reverse path also lives here, turning decoded serial values back into Lua-friendly tables and primitives. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### mod.rs

- This module provides the engine's multi-format serialization stack around one shared intermediate value representation. `serialize/mod` is the serialize module index, declaring `codec`, `csv`, `ini`, `json`, `lua_table`, and 4 more so agents can identify which files own each feature slice before opening implementation code.
- It covers encoding, decoding, schema validation, defaults, and Lua bridging across text and binary data formats. `src/serialize/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `codec::{ decode_bytes, decode_text, detect_format, encode, DecodeOptions, EncodeOptions, EncodedValue, SerialFormat, }`, `csv::{from_csv, to_csv, CsvOptions}`, `ini::from_ini`, `json::{from_json, to_json}`, and 5 more centralized for the serialize subsystem.
- At the highest level this is the data-translation foundation used when engine data must cross file, tool, or script boundaries.
- `serialize/mod` is the serialize module index, declaring `codec`, `csv`, `ini`, `json`, `lua_table`, and 4 more so agents can identify which files own each feature slice before opening implementation code.
- `src/serialize/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `codec::{ decode_bytes, decode_text, detect_format, encode, DecodeOptions, EncodeOptions, EncodedValue, SerialFormat, }`, `csv::{from_csv, to_csv, CsvOptions}`, `ini::from_ini`, `json::{from_json, to_json}`, and 5 more centralized for the serialize subsystem.
- The file documents how serialize submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.

### msgpack.rs

- This file handles the compact binary MessagePack path for serial values when text readability is less important than size and speed.
- It translates through an internal bridge representation that fits the expectations of the underlying MessagePack tooling.
- Buffer sizing and conversion details are handled here so callers can treat MessagePack as just another supported format.
- Compatibility with JSON-like value shapes is preserved where practical to keep cross-format workflows predictable. Runtime integration reaches sibling engine areas through crate modules `log_msg`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### schema.rs

- This file validates serialized data against declarative structural expectations before that data reaches game logic. `serialize/schema` delivers the schema implementation for the serialize subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Schemas describe required fields, allowed types, numeric and string constraints, nested shapes, and array item rules. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Missing values can also be filled from schema defaults so partially specified input can be upgraded into a complete shape.
- Validation failures are reported with paths that point at the exact part of the value tree that broke the contract. Runtime integration reaches sibling engine areas through crate modules `log_msg`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Logging support is integrated because schema checks often matter during content ingestion, save loading, and config debugging.

### toml.rs

- This file translates TOML documents into the engine's intermediate serial tree and back again. `serialize/toml` delivers the toml implementation for the serialize subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- It exists mainly for human-edited structured configuration where readability and stable nesting matter more than raw compactness.
- Conversion details between the external TOML value model and the engine's generic serial model are localized here. Public callable behavior is centered on `parse_toml`, `from_toml`, `encode_toml`, `to_toml`, while method-level behavior such as no named public items stays attached to the local data model and invariants.

### xml.rs

- This file handles XML decoding for hierarchical data sources that arrive as elements, attributes, text nodes, and repeated children.
- It recursively reshapes document structure into the engine's generic serial tree without requiring callers to speak DOM directly.
- Attribute and child-content handling are kept together here so engine importers see one consistent XML-to-value mapping.



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
