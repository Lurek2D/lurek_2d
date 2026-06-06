# serialize

## General Info

- Module group: `Foundations`
- Source path: `src/serialize/`
- Binding: `src/lua_api/serialize_api.rs`
- Namespace: `lurek.serial`
- Lua API surface: `15` functions, `0` types, `0` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

This module serves as the primary data-translation and validation subsystem for Lurek2D, providing a unified frontend to ingest and export data. The subsystem translates all text and binary inputs into a format-agnostic intermediate value tree. Through a single entry point, the codec automatically detects and parses payloads—including JSON, TOML, CSV, XML, INI, and MessagePack—isolating format quirks from the runtime.

The module provides dedicated adapters to bridge scripts and raw files. It handles CSV rows, sectioned INI settings, hierarchical XML nodes, TOML configs, MessagePack binary packets, and JSON streams. The system automatically distinguishes between sequence arrays and maps when bridging dynamic Lua tables to the intermediate tree, preserving layout structures without manual tagging.

To guarantee data integrity, a declarative schema validation engine defines required types and constraints. Validation passes automatically merge schema-defined default values into missing fields. When validation fails, it reports precise paths pointing to the exact entry that broke the contract.

## Files

### [codec.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/serialize/codec.rs)

- This file provides the format-agnostic front door for serialization work across text and binary payloads.
- It decides which codec to use, how to route decoding and encoding, and when content can be recognized automatically.
- Text and binary paths are separated here so callers can use one interface without collapsing all format quirks into one parser.
- The file is therefore the dispatcher that turns unknown serialized input into a chosen translation path.
- It is the hub where multi-format support becomes one practical API.

### [csv.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/serialize/csv.rs)

- This file translates between tabular CSV text and the engine's generic serial value tree.
- It supports row-oriented data that may be keyed by headers or treated as plain positional sequences.
- Delimiters, quoting behavior, and output shape are handled here so spreadsheet-style data stays usable without special caller code.
- Encoding and decoding live together because CSV round-trips depend on consistent assumptions about row structure.
- The file is the serialization layer for flat table data rather than nested document-like formats.

### [ini.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/serialize/ini.rs)

- This file handles INI-style configuration text for projects and tools that still prefer simple sectioned key-value documents.
- It converts section headers, assignments, and comments into a nested serial representation without pretending INI is richer than it is.
- Insertion order is preserved so output remains readable and familiar when round-tripped back toward human-edited config files.
- The file is the narrow compatibility bridge between lightweight legacy config text and the engine's generic serial model.

### [json.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/serialize/json.rs)

- This file provides JSON translation to and from the engine's intermediate serial value tree.
- It preserves the normal JSON shape of scalars, arrays, and objects while exposing that data through one engine-wide representation.
- Pretty and compact output choices live here because readable config and compact payloads are both common JSON use cases.
- The file is therefore the JSON-specific adapter inside the broader multi-format serialization system.

### [lua_table.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/serialize/lua_table.rs)

- This file bridges the dynamic world of Lua tables and values into the typed intermediate tree used by the serialization subsystem.
- It decides when Lua data should be treated as sequences, maps, scalars, or explicit null-like values for downstream codecs.
- Array-like tables are recognized structurally so callers do not have to tag them manually before encoding.
- The reverse path also lives here, turning decoded serial values back into Lua-friendly tables and primitives.
- This file is the language boundary where loose script data becomes format-ready structured data.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/serialize/mod.rs)

- This module provides the engine's multi-format serialization stack around one shared intermediate value representation.
- It covers encoding, decoding, schema validation, defaults, and Lua bridging across text and binary data formats.
- At the highest level this is the data-translation foundation used when engine data must cross file, tool, or script boundaries.

### [msgpack.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/serialize/msgpack.rs)

- This file handles the compact binary MessagePack path for serial values when text readability is less important than size and speed.
- It translates through an internal bridge representation that fits the expectations of the underlying MessagePack tooling.
- Buffer sizing and conversion details are handled here so callers can treat MessagePack as just another supported format.
- Compatibility with JSON-like value shapes is preserved where practical to keep cross-format workflows predictable.
- The file is the binary-leaning codec within a mostly document-oriented serialization family.

### [schema.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/serialize/schema.rs)

- This file validates serialized data against declarative structural expectations before that data reaches game logic.
- Schemas describe required fields, allowed types, numeric and string constraints, nested shapes, and array item rules.
- Missing values can also be filled from schema defaults so partially specified input can be upgraded into a complete shape.
- Validation failures are reported with paths that point at the exact part of the value tree that broke the contract.
- Logging support is integrated because schema checks often matter during content ingestion, save loading, and config debugging.
- The file is therefore the correctness gate of the serialization subsystem.

### [toml.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/serialize/toml.rs)

- This file translates TOML documents into the engine's intermediate serial tree and back again.
- It exists mainly for human-edited structured configuration where readability and stable nesting matter more than raw compactness.
- Conversion details between the external TOML value model and the engine's generic serial model are localized here.
- The file is the TOML-specific bridge used whenever engine or game config needs round-trip persistence.

### [xml.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/serialize/xml.rs)

- This file handles XML decoding for hierarchical data sources that arrive as elements, attributes, text nodes, and repeated children.
- It recursively reshapes document structure into the engine's generic serial tree without requiring callers to speak DOM directly.
- Attribute and child-content handling are kept together here so engine importers see one consistent XML-to-value mapping.
- The file is the XML ingestion path inside the broader serialization module.
