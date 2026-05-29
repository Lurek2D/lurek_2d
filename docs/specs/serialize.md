# serialize

## TL;DR

- The `serial` module is a fundamental Foundations tier component providing a format-agnostic serialization and deserialization engine.

## General Info

- Module group: `Foundations`
- Source path: `src/serialize/`
- Lua API path(s): `src/lua_api/serialize_api.rs`
- Primary Lua namespace: `lurek.serial`
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

At its core, it relies on the recursive `SerialValue` enum—an intermediate type-erased representation—to seamlessly map between native Lua tables and six popular text and binary formats: JSON, TOML, CSV, XML, INI, and MessagePack. This design allows developers to read and write diverse data sources using a unified API without worrying about the underlying parsing mechanics. The module features an intelligent auto-detection system that inspects content bytes to automatically guess the correct `SerialFormat` during decoding, making it exceptionally robust for loading arbitrary user-provided files or unknown network payloads.

Each format codec is highly specialized to handle the nuances of its specific specification. For instance, the CSV parser efficiently handles headers, custom delimiters, quoting, and multi-line fields, easily mapping between spreadsheet rows and Lua arrays of tables. The TOML and INI parsers support deep nesting and sections, perfect for configuration files. The XML parser correctly interprets attributes and text nodes, crucial for importing complex assets like Tiled map exports. For performance-critical paths—such as save states or network synchronization—the MessagePack codec provides fast, compact binary encoding that significantly outperforms text formats in both speed and size.

Beyond simple format translation, the module includes a powerful schema validation system. Developers can define typed constraints to validate `SerialValue` trees against expected shapes, enforcing required fields, numeric ranges, and string lengths before the data reaches game logic. Additionally, the schema system can apply default values to automatically fill missing fields, ensuring backwards compatibility with older save files or partial configurations. Coupled with seamless bi-directional conversion between `SerialValue` and the Lua runtime, the `lurek.serial.*` API equips developers with an extremely versatile and reliable data pipeline for config loading, state persistence, and external tool integration.

## Files

### codec.rs

- Format detection, decoding, and encoding for the serial module.
- Supports JSON, TOML, CSV, MsgPack, XML, and INI formats.
- Provides auto-detection of text formats by content inspection.
- Separates text-based and binary decode paths.

### csv.rs

- Parse CSV text or streams into `SerialValue` sequences of maps or arrays.
- Serialize `SerialValue` back to CSV with configurable delimiter and header behavior.
- Support both header-keyed (map rows) and index-only (sequence rows) modes.

### ini.rs

- Parse INI text into a nested `SerialValue` map.
- Support sections, key=value pairs, and comment lines.
- Preserve insertion order via `IndexMap`.

### json.rs

- Parse JSON strings into the engine's `SerialValue` intermediate representation.
- Encode `SerialValue` trees back to JSON (compact or pretty-printed).
- Map JSON types (null, bool, number, string, array, object) to `SerialValue` variants bidirectionally.

### lua_table.rs

- Bidirectional conversion between Lua tables and a typed serial value tree.
- Supports null, bool, int, float, string, sequence, and map variants.
- Detects array-like tables automatically and emits `Seq`; otherwise emits `Map`.

### mod.rs

- Serialization and deserialization for multiple formats (JSON, TOML, CSV, XML, MsgPack, INI)
- Unified codec interface with auto-detection and round-trip encode/decode
- Schema validation and default application for structured data
- Lua table ↔ Rust value bridging via SerialValue

### msgpack.rs

- MessagePack binary encoding and decoding for SerialValue trees.
- Intermediate MsgValue enum bridging SerialValue to rmp_serde.
- Size estimation for pre-allocated encode buffers.
- JSON-compatible encode/decode path via serde_json::Value.

### schema.rs

- Validate a `SerialValue` tree against a schema describing expected types, ranges, and structure.
- Enforce required fields, numeric min/max, string length bounds, nested table fields, and array items.
- Apply default values from a schema to fill missing fields in a value tree.
- Report path-qualified error messages when validation fails.
- Log schema pass/fail outcomes through the engine log system.

### toml.rs

- Parse TOML strings into engine-internal `SerialValue` trees.
- Encode `SerialValue` back to TOML text for config persistence.
- Bridge between the `toml` crate's value types and the serial layer.

### xml.rs

- Parse XML strings into a SerialValue tree using roxmltree.
- Recursively convert elements, attributes, text, and children into map/seq structures.
- Provide a single `decode` entry point for the serial module.

## Lua API Ref

- Binding: `src/lua_api/serialize_api.rs`
- Namespace: `lurek.serial`

### Functions

- `lurek.serial.applyDefaults`: Merges a schema's default values into a data table, filling in any missing fields without overwriting existing ones. Use this to ensure game config or save data always has complete fields even when the user provides only partial overrides.
- `lurek.serial.decode`: Universal decoder that parses a string payload into a Lua table using the specified format. If no format is given, auto-detects from the content. Supports JSON, TOML, CSV, XML, INI, and MessagePack. Use this as a single entry point when handling files of varying or unknown formats.
- `lurek.serial.decodeMsgPack`: Decodes a binary MessagePack string back into a Lua table. Use this to read save files, network packets, or any data previously encoded with encodeMsgPack.
- `lurek.serial.decodeXml`: Parses an XML string into a Lua table structure. Elements become nested tables with tag names as keys. Useful for loading Tiled map exports, SVG data, UI layout definitions, or other XML-based game assets.
- `lurek.serial.detectFormat`: Attempts to auto-detect the serialization format of a string by inspecting its content (e.g., leading `{` for JSON, `[section]` for INI, XML declaration for XML). Returns the format name or nil if detection fails. Useful for loading user-provided files where the format is unknown.
- `lurek.serial.encode`: Universal encoder that serializes a Lua value into the specified format. Supports JSON, TOML, CSV, and MessagePack. Returns a string (text for JSON/TOML/CSV, binary for MessagePack). Use this as a single entry point for all serialization needs.
- `lurek.serial.encodeMsgPack`: Encodes a Lua table into a compact binary MessagePack string. MessagePack is faster and smaller than JSON, making it ideal for save files, network packets, or any scenario where performance matters more than human readability. The argument must be a table.
- `lurek.serial.fromCsv`: Parses a CSV string into a Lua table (array of rows). Each row is either a keyed table (when headers are present) or an indexed array of field values. Useful for loading spreadsheet exports, leaderboard data, or tabular game data.
- `lurek.serial.fromIni`: Parses an INI-format string into a Lua table. Sections become nested tables, and key-value pairs become string fields. Useful for legacy config files or simple settings.
- `lurek.serial.fromJson`: Parses a JSON string into a Lua table. Use this to load configuration files, network responses, or any structured data stored as JSON.
- `lurek.serial.fromToml`: Parses a TOML string into a Lua table. Ideal for loading game configuration files, level definitions, and engine settings stored in TOML format.
- `lurek.serial.toCsv`: Serializes a Lua table (array of row tables) into a CSV-formatted string. Each row table should have consistent keys or be an indexed array. Use this to export leaderboards, save tabular data, or generate spreadsheet-compatible output.
- `lurek.serial.toJson`: Serializes a Lua value (table, string, number, boolean, or nil) into a JSON string. Useful for saving game state, writing config files, or preparing network payloads.
- `lurek.serial.toToml`: Serializes a Lua table into a TOML-formatted string. Use this to write configuration files, save structured settings, or export data in a human-readable format.
- `lurek.serial.validate`: Validates a Lua value against a schema table. The schema defines expected types, required fields, and constraints. Returns a success boolean and an optional error message string describing the first validation failure. Use this to verify save data integrity or user-provided configuration before processing.

### Enums

- No documented module-level enums/constants.

### Types

- No documented module types.

## References

- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Foundations` into `Core Runtime`.
