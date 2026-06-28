<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/serialize.md or source docstrings instead. -->

# serialize

## TL;DR

- Translates JSON, TOML, CSV, XML, INI, and MessagePack via one intermediate tree.
- Validates data against schemas.
- Enforces bounded decode, encode, and Lua-conversion limits for depth, nodes, strings, rows, and input size.

## General Info

- Module group: `Foundations`
- Source path: `src/serialize`
- Binding: `src/lua_api/serialize_api.rs`
- Namespace: `lurek.serialize`
- Lua API surface: `16` functions, `0` types, `0` methods
- User-facing: `true`
- Plugin tier: `core_keep`

## Summary

- The `serialize` module is the format-translation surface for users who want several external data formats to map into one shared runtime value model.
- JSON, TOML, CSV, XML, INI, MessagePack, schemas, and codec entrypoints all matter here because a project often needs to move content between several representations without rewriting conversion logic each time.
- The module is useful both for loading or saving data and for validating whether translated data actually fits an expected structure.
- Its shared intermediate tree is the key user-facing idea: several formats can participate in the same workflows because they resolve into one normalized serial representation.
- That normalized representation is what makes cross-format tooling practical. Validators, exporters, migration steps, and transforms can reason about one value model instead of reimplementing logic for every source format.
- That also makes migrations easier to reason about.
- Safety is part of the contract. Lua conversion, autodetection, CSV parsing, and MessagePack decode must stay bounded and reject cyclic or non-finite inputs instead of recursing or allocating without policy.
- Read `serialize` as the normalization layer for structured data moving between external formats and engine-facing workflows.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Foundations group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/serialize`
- Owning tier: `Foundations`
- Plugin tier: `core_keep`
- Lua binding owner: `src/lua_api/serialize_api.rs`
- Referenced engine modules: `runtime`

## Imports

- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Foundations` into `Core Runtime`.

## Source Files

### codec.rs

- Owns serialize behavior with explicit state, validation, and crate-local integration boundaries.
- Centers the implementation around SerialFormat, parse, all, with helpers kept close to their invariants.
- Defines how codec data is validated, transformed, or stored before neighboring systems use it.
- Owns serialize behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on codec behavior while Lua registration stays elsewhere.
- Documents the boundary where serialize code accepts inputs, reports errors, or updates state.
- Use this file when changing codec defaults, lifecycle handling, validation, or data ownership.
- Keeps failure paths and edge cases near the serialize state that can explain them while keeping call sites explicit.
- Preserves deterministic behavior by keeping codec calculations explicit at their owner boundary.

### csv.rs

- Owns the csv owner for the serialize subsystem and keeps its rules local to this file while keeping call sites explicit.
- Keeps serialize data ownership and helper behavior clear for future engine maintenance. for engine changes.
- Defines how csv data is validated, transformed, or stored before neighboring systems use it.
- Owns serialize behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on csv behavior while Lua registration stays elsewhere.
- Documents the boundary where serialize code accepts inputs, reports errors, or updates state.
- Use this file when changing csv defaults, lifecycle handling, validation, or data ownership.

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

- Owns the lua table owner for the serialize subsystem and keeps its rules local to this file.
- Centers the implementation around SerialValue, fmt, to_lua, with helpers kept close to their invariants.
- Defines how lua table data is validated, transformed, or stored before neighboring systems use it.
- Owns serialize behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on lua table behavior while Lua registration stays elsewhere.
- Documents the boundary where serialize code accepts inputs, reports errors, or updates state.
- Use this file when changing lua table defaults, lifecycle handling, validation, or data ownership.

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

- Owns serialize behavior with explicit state, validation, and crate-local integration boundaries.
- Centers the implementation around DefaultsApplied, child_path, item_path, with helpers kept close to their invariants.
- Defines how schema data is validated, transformed, or stored before neighboring systems use it.
- Owns serialize behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on schema behavior while Lua registration stays elsewhere.
- Documents the boundary where serialize code accepts inputs, reports errors, or updates state.
- Use this file when changing schema defaults, lifecycle handling, validation, or data ownership.

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

- `lurek.serialize.applyDefaults(value, schema) -> table`: Merges a schema's default values into a data table, filling in any missing fields without overwriting existing ones. Use this to ensure game config or save data always has complete fields even when the user provides only partial overrides.
- `lurek.serialize.decode(payload, format?, opts?) -> table`: Universal decoder that parses a string payload into a Lua table using the specified format. If no format is given, auto-detects from the content. Supports JSON, TOML, CSV, XML, INI, and MessagePack. Use this as a single entry point when handling files of varying or unknown formats.
- `lurek.serialize.decodeMsgPack(bytes) -> table`: Decodes a binary MessagePack string back into a Lua table. Use this to read save files, network packets, or any data previously encoded with encodeMsgPack.
- `lurek.serialize.decodeXml(text) -> table`: Parses an XML string into a Lua table structure. Elements become nested tables with tag names as keys. Useful for loading Tiled map exports, SVG data, UI layout definitions, or other XML-based game assets.
- `lurek.serialize.detectFormat(text) -> string`: Attempts to auto-detect the serialization format of a string by inspecting its content (e.g., leading `{` for JSON, `[section]` for INI, XML declaration for XML). Returns the format name or nil if detection fails. Useful for loading user-provided files where the format is unknown.
- `lurek.serialize.encode(value, format, opts?) -> string`: Universal encoder that serializes a Lua value into the specified format. Supports JSON, TOML, CSV, and MessagePack. Returns a string (text for JSON/TOML/CSV, binary for MessagePack). Use this as a single entry point for all serialization needs.
- `lurek.serialize.encodeMsgPack(value) -> string`: Encodes a Lua table into a compact binary MessagePack string. MessagePack is faster and smaller than JSON, making it ideal for save files, network packets, or any scenario where performance matters more than human readability. The argument must be a table.
- `lurek.serialize.encodeMsgPack(value) -> string`: Encodes a Lua table into a compact binary MessagePack string. MessagePack is faster and smaller than JSON, making it ideal for save files, network packets, or any scenario where performance matters more than human readability. The argument must be a table.
- `lurek.serialize.fromCsv(text, delimiter?, hasHeaders?) -> table`: Parses a CSV string into a Lua table (array of rows). Each row is either a keyed table (when headers are present) or an indexed array of field values. Useful for loading spreadsheet exports, leaderboard data, or tabular game data.
- `lurek.serialize.fromIni(text) -> table`: Parses an INI-format string into a Lua table. Sections become nested tables, and key-value pairs become string fields. Useful for legacy config files or simple settings.
- `lurek.serialize.fromJson(text) -> table`: Parses a JSON string into a Lua table. Use this to load configuration files, network responses, or any structured data stored as JSON.
- `lurek.serialize.fromToml(text) -> table`: Parses a TOML string into a Lua table. Ideal for loading game configuration files, level definitions, and engine settings stored in TOML format.
- `lurek.serialize.toCsv(value, delimiter?, hasHeaders?) -> string`: Serializes a Lua table (array of row tables) into a CSV-formatted string. Each row table should have consistent keys or be an indexed array. Use this to export leaderboards, save tabular data, or generate spreadsheet-compatible output.
- `lurek.serialize.toJson(value, pretty?) -> string`: Serializes a Lua value (table, string, number, boolean, or nil) into a JSON string. Useful for saving game state, writing config files, or preparing network payloads.
- `lurek.serialize.toToml(value) -> string`: Serializes a Lua table into a TOML-formatted string. Use this to write configuration files, save structured settings, or export data in a human-readable format.
- `lurek.serialize.validate(value, schema) -> boolean`: Validates a Lua value against a schema table. The schema defines expected types, required fields, and constraints. Returns a success boolean and an optional error message string describing the first validation failure. Use this to verify save data integrity or user-provided configuration before processing.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

- No documented module types.

## Examples

- `content/examples/serialize.lua` (present)

## Architecture Links

- Intentionally empty.

## Notes

- `SerializeLimits` are part of the module contract for untrusted or generated data. Depth, node, string, input-byte, and CSV budgets should stay explicit.
- Lua table cycles and non-finite numbers are rejected rather than coerced or silently serialized.
- `SerialFormat` exposes capability flags so tooling can discover whether a format can encode, decode text, or decode bytes before attempting the operation.
