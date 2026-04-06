# `serial` — Agent Reference

| Property | Value |
|----------|-------|
| **Tier** | Unassigned |
| **Status** | Implemented — Full |
| **Lua API** | `luna.serial` |
| **Source** | `src/serial/` |
| **Rust Tests** | `tests/unit/serial_tests.rs` |
| **Lua Tests** | `tests/lua/unit/test_serial.lua` |
| **Architecture** | — |

## Summary

The `serial` module provides format-agnostic serialisation and deserialisation for JSON,
TOML, CSV, and Lua table literals. It is a Tier 1 Engine Subsystem.

`SerialValue` is a common intermediate representation (Null, Bool, Int, Float, String,
Array, Map) that all format drivers produce and consume. This means a Lua script can
load a JSON file, mutate it as a `SerialValue` tree, and save it as TOML without any
format-specific knowledge.

Supported formats: JSON (via `serde_json`), TOML (via `toml`), CSV (rows-of-strings),
and Lua table literals (hand-rolled parser for simple config files). YAML is explicitly
not supported — design assumption B-05 prohibits YAML anywhere in the project.

The module contains no file I/O: callers supply strings and receive strings back.
Filesystem operations are handled by `luna.filesystem` or `luna.data`.

**Scope boundary**: `serial` is a pure string-in / string-out transformation module.
It has no GPU, audio, or physics dependencies.
## Architecture

```
serial (module root)
  ├── csv.rs — CSV parsing and serialization for Luna2D. Converts between CSV strings and `SerialValue` using the `csv` crate. Parses CSV rows into ordered maps keyed by header columns.
  ├── json.rs — JSON parsing and serialization for Luna2D. Converts between JSON strings and `SerialValue` using `serde_json`.
  ├── lua_table.rs — `SerialValue`: shared intermediate representation for all serial format modules. All format modules (json, toml, csv, yaml) convert to/from `SerialValue`. `Lua-table` is the canonical name because the primary use case is bridging between Lua tables and text serialization formats.
  ├── toml.rs — TOML parsing and serialization for Luna2D. Converts between TOML strings and `SerialValue` using the `toml` crate. Provides the functionality previously in `data::toml_convert`.
  ├── yaml.rs — YAML parsing and serialization for Luna2D. Converts between YAML strings and `SerialValue` using `serde_yml`.
```

## Source Files

| File | Purpose |
|------|---------|
| `csv.rs` | CSV parsing and serialization for Luna2D. Converts between CSV strings and `SerialValue` using the `csv` crate. Parses CSV rows into ordered maps keyed by header columns. |
| `json.rs` | JSON parsing and serialization for Luna2D. Converts between JSON strings and `SerialValue` using `serde_json`. |
| `lua_table.rs` | `SerialValue`: shared intermediate representation for all serial format modules. All format modules (json, toml, csv, yaml) convert to/from `SerialValue`. `Lua-table` is the canonical name because the primary use case is bridging between Lua tables and text serialization formats. |
| `toml.rs` | TOML parsing and serialization for Luna2D. Converts between TOML strings and `SerialValue` using the `toml` crate. Provides the functionality previously in `data::toml_convert`. |
| `yaml.rs` | YAML parsing and serialization for Luna2D. Converts between YAML strings and `SerialValue` using `serde_yml`. |

## Submodules

### `serial::csv`

CSV parsing and serialization for Luna2D. Converts between CSV strings and `SerialValue` using the `csv` crate. Parses CSV rows into ordered maps keyed by header columns.

- **`CsvOptions`** (struct): TODO: one-line description.

### `serial::json`

JSON parsing and serialization for Luna2D. Converts between JSON strings and `SerialValue` using `serde_json`.

### `serial::lua_table`

`SerialValue`: shared intermediate representation for all serial format modules. All format modules (json, toml, csv, yaml) convert to/from `SerialValue`. `Lua-table` is the canonical name because the primary use case is bridging between Lua tables and text serialization formats.

- **`SerialValue`** (enum): TODO: one-line description.

### `serial::toml`

TOML parsing and serialization for Luna2D. Converts between TOML strings and `SerialValue` using the `toml` crate. Provides the functionality previously in `data::toml_convert`.

### `serial::yaml`

YAML parsing and serialization for Luna2D. Converts between YAML strings and `SerialValue` using `serde_yml`.

## Key Types

### Structs

#### `serial::csv::CsvOptions`

TODO: description from `///` doc comment.

### Enums

#### `serial::lua_table::SerialValue`

TODO: description from `///` doc comment.

## Lua API

Exposed under `luna.serial.*` by `src\lua_api\serial_api.rs`.

TODO: Describe the overall API surface. List the major categories of functions.

Exposed functions include: `serial`.

## Lua Examples

```lua
-- Example: Basic serial usage
function luna.load()
    -- TODO: replace with real serial setup
    local obj = luna.serial.serial()
end

function luna.update(dt)
    -- TODO: update logic
end
```

## Item Summary

| Kind | Count |
|------|-------|
| `struct` | 1 |
| `enum`   | 1 |
| `fn`     | 8 |
| **Total** | **10** |

## References

| Module | Relationship | Notes |
|--------|--------------|-------|
| `engine` | Imports from | Uses SharedState, EngineError |
| `math` | Imports from | Vec2, Color, Rect |
| `lua_api` | Imported by | Binds public API to Lua |

TODO: Add entries for similar modules and explain the separation of duties.

## Notes

TODO: Document unique facts an agent must know before editing this module:
- External crate constraints (version, thread-safety, API limitations)
- Hardware or OS-specific behaviour (e.g., headless fallback on CI)
- Known limitations or intentional omissions
- Best practices and anti-patterns for this module
- What Lua scripts will break if the API changes
