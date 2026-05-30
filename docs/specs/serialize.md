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

- This file provides the format-agnostic front door for serialization work across text and binary payloads.
- It decides which codec to use, how to route decoding and encoding, and when content can be recognized automatically.
- Text and binary paths are separated here so callers can use one interface without collapsing all format quirks into one parser.
- The file is therefore the dispatcher that turns unknown serialized input into a chosen translation path.
- It is the hub where multi-format support becomes one practical API.

### csv.rs

- This file translates between tabular CSV text and the engine's generic serial value tree.
- It supports row-oriented data that may be keyed by headers or treated as plain positional sequences.
- Delimiters, quoting behavior, and output shape are handled here so spreadsheet-style data stays usable without special caller code.
- Encoding and decoding live together because CSV round-trips depend on consistent assumptions about row structure.
- The file is the serialization layer for flat table data rather than nested document-like formats.

### ini.rs

- This file handles INI-style configuration text for projects and tools that still prefer simple sectioned key-value documents.
- It converts section headers, assignments, and comments into a nested serial representation without pretending INI is richer than it is.
- Insertion order is preserved so output remains readable and familiar when round-tripped back toward human-edited config files.
- The file is the narrow compatibility bridge between lightweight legacy config text and the engine's generic serial model.

### json.rs

- This file provides JSON translation to and from the engine's intermediate serial value tree.
- It preserves the normal JSON shape of scalars, arrays, and objects while exposing that data through one engine-wide representation.
- Pretty and compact output choices live here because readable config and compact payloads are both common JSON use cases.
- The file is therefore the JSON-specific adapter inside the broader multi-format serialization system.

### lua_table.rs

- This file bridges the dynamic world of Lua tables and values into the typed intermediate tree used by the serialization subsystem.
- It decides when Lua data should be treated as sequences, maps, scalars, or explicit null-like values for downstream codecs.
- Array-like tables are recognized structurally so callers do not have to tag them manually before encoding.
- The reverse path also lives here, turning decoded serial values back into Lua-friendly tables and primitives.
- This file is the language boundary where loose script data becomes format-ready structured data.

### mod.rs

- This module provides the engine's multi-format serialization stack around one shared intermediate value representation.
- It covers encoding, decoding, schema validation, defaults, and Lua bridging across text and binary data formats.
- At the highest level this is the data-translation foundation used when engine data must cross file, tool, or script boundaries.

### msgpack.rs

- This file handles the compact binary MessagePack path for serial values when text readability is less important than size and speed.
- It translates through an internal bridge representation that fits the expectations of the underlying MessagePack tooling.
- Buffer sizing and conversion details are handled here so callers can treat MessagePack as just another supported format.
- Compatibility with JSON-like value shapes is preserved where practical to keep cross-format workflows predictable.
- The file is the binary-leaning codec within a mostly document-oriented serialization family.

### schema.rs

- This file validates serialized data against declarative structural expectations before that data reaches game logic.
- Schemas describe required fields, allowed types, numeric and string constraints, nested shapes, and array item rules.
- Missing values can also be filled from schema defaults so partially specified input can be upgraded into a complete shape.
- Validation failures are reported with paths that point at the exact part of the value tree that broke the contract.
- Logging support is integrated because schema checks often matter during content ingestion, save loading, and config debugging.
- The file is therefore the correctness gate of the serialization subsystem.

### toml.rs

- This file translates TOML documents into the engine's intermediate serial tree and back again.
- It exists mainly for human-edited structured configuration where readability and stable nesting matter more than raw compactness.
- Conversion details between the external TOML value model and the engine's generic serial model are localized here.
- The file is the TOML-specific bridge used whenever engine or game config needs round-trip persistence.

### xml.rs

- This file handles XML decoding for hierarchical data sources that arrive as elements, attributes, text nodes, and repeated children.
- It recursively reshapes document structure into the engine's generic serial tree without requiring callers to speak DOM directly.
- Attribute and child-content handling are kept together here so engine importers see one consistent XML-to-value mapping.
- The file is the XML ingestion path inside the broader serialization module.

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
