# `data` — Agent Reference

| Property | Value |
|----------|-------|
| **Tier** | Tier 1 — Core Engine Subsystems |
| **Status** | Implemented — Full |
| **Lua API** | `luna.data` |
| **Source** | `src/data/` |
| **Rust Tests** | `tests/unit/data_tests.rs` |
| **Lua Tests** | `tests/lua/unit/test_data.lua` |
| **Architecture** | — |

## Summary

The `data` module provides binary data manipulation, compression, hashing, encoding, and
structured pack/unpack for Lua scripts. It is a Tier 1 Engine Subsystem.

`ByteData` wraps `Vec<u8>` and exposes byte-level read/write via the `luna.data` Lua API.
The `compress` sub-module supports deflate, gzip, lz4, and zlib via flate2 and lz4_flex.
The `hash` sub-module computes MD5, SHA-1, SHA-256, and SHA-512 digests. The `encode`
sub-module converts binary buffers to/from Base64 and hex strings. The `bin_pack` sub-module
provides C-style `pack`/`unpack` with format strings compatible with Python's `struct` module,
enabling binary protocol work. `DataView` gives a windowed read-only cursor into a byte slice.

Scripts use `luna.data.newByteData(size)`, `luna.data.compress(fmt, bytes)`,
`luna.data.hash(algo, data)`, `luna.data.encode(fmt, data)`, and `luna.data.pack(fmt, ...)`.

**Scope boundary**: This module is a pure CPU data-processing layer with no GPU, audio,
or filesystem dependencies.
## Architecture

```
data (module root)
  ├── bin_pack.rs — Luna2D Binary Pack Format — format-string based binary serialization. Provides `write`, `read`, and `measure_size` for the `luna.data` module. Format strings use space-separated named type tokens. # Format string tokens | Token  | Type                       | Byte size  | |--------|----------------------------|------------| | `le`   | switch to little-endian    | (modifier) | | `be`   | switch to big-endian       | (modifier) | | `u8`   | unsigned 8-bit integer     | 1          | | `u16`  | unsigned 16-bit integer    | 2          | | `u32`  | unsigned 32-bit integer    | 4          | | `u64`  | unsigned 64-bit integer    | 8          | | `i8`   | signed 8-bit integer       | 1          | | `i16`  | signed 16-bit integer      | 2          | | `i32`  | signed 32-bit integer      | 4          | | `i64`  | signed 64-bit integer      | 8          | | `f32`  | 32-bit float               | 4          | | `f64`  | 64-bit float               | 8          | | `bool` | boolean (u8: 0=false)      | 1          | | `str`  | u32-length-prefixed UTF-8  | 4 + len    | | `cstr` | null-terminated UTF-8      | len + 1    | | `pad`  | zero padding byte          | 1          |
  ├── byte_data.rs — Contiguous byte buffer accessible from Lua. This module is part of Luna2D's `data` subsystem and provides the implementation details for byte data-related operations and data management. Key types exported from this module: `ByteData`. Primary functions: `new()`, `from_bytes()`, `from_string()`, `len()`. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.
  ├── compress.rs — Data compression and decompression using deflate, gzip, zlib, and LZ4. This module is part of Luna2D's `data` subsystem and provides the implementation details for compress-related operations and data management. Key types exported from this module: `CompressFormat`. Primary functions: `parse_str()`, `compress()`, `decompress()`. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.
  ├── dataview.rs — Read-only windowed view into a shared byte buffer. `DataView` provides typed accessor methods over a slice of a `Vec<u8>` without copying the underlying data. All reads are little-endian. Bounds are checked on every access; out-of-range indices return an error.
  ├── encode.rs — Base64 and hex encoding/decoding for data serialization. This module is part of Luna2D's `data` subsystem and provides the implementation details for encode-related operations and data management. Key types exported from this module: `EncodeFormat`. Primary functions: `parse_str()`, `encode()`, `decode()`. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.
  ├── hash.rs — Cryptographic hash functions for data integrity verification. This module is part of Luna2D's `data` subsystem and provides the implementation details for hash-related operations and data management. Key types exported from this module: `HashAlgorithm`. Primary functions: `parse_str()`, `hash()`. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.
  ├── pack.rs — Binary pack/unpack utilities compatible with LÖVE2D's `data.pack` API. Provides format-string based binary serialization for the `luna.data` module. Supports little-endian and big-endian byte order via `<` and `>` prefixes.
  ├── toml_convert.rs — TOML parsing and encoding for Luna2D. Converts between TOML strings and Lua tables. Supports the full TOML spec via the `toml` crate, mapping types to their Lua equivalents. This module is part of Luna2D's `data` subsystem and provides the implementation details for toml convert-related operations and data management. Primary functions: `parse_toml()`, `encode_toml()`. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.
```

## Source Files

| File | Purpose |
|------|---------|
| `bin_pack.rs` | Luna2D Binary Pack Format — format-string based binary serialization. Provides `write`, `read`, and `measure_size` for the `luna.data` module. Format strings use space-separated named type tokens. # Format string tokens | Token  | Type                       | Byte size  | |--------|----------------------------|------------| | `le`   | switch to little-endian    | (modifier) | | `be`   | switch to big-endian       | (modifier) | | `u8`   | unsigned 8-bit integer     | 1          | | `u16`  | unsigned 16-bit integer    | 2          | | `u32`  | unsigned 32-bit integer    | 4          | | `u64`  | unsigned 64-bit integer    | 8          | | `i8`   | signed 8-bit integer       | 1          | | `i16`  | signed 16-bit integer      | 2          | | `i32`  | signed 32-bit integer      | 4          | | `i64`  | signed 64-bit integer      | 8          | | `f32`  | 32-bit float               | 4          | | `f64`  | 64-bit float               | 8          | | `bool` | boolean (u8: 0=false)      | 1          | | `str`  | u32-length-prefixed UTF-8  | 4 + len    | | `cstr` | null-terminated UTF-8      | len + 1    | | `pad`  | zero padding byte          | 1          | |
| `byte_data.rs` | Contiguous byte buffer accessible from Lua. This module is part of Luna2D's `data` subsystem and provides the implementation details for byte data-related operations and data management. Key types exported from this module: `ByteData`. Primary functions: `new()`, `from_bytes()`, `from_string()`, `len()`. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface. |
| `compress.rs` | Data compression and decompression using deflate, gzip, zlib, and LZ4. This module is part of Luna2D's `data` subsystem and provides the implementation details for compress-related operations and data management. Key types exported from this module: `CompressFormat`. Primary functions: `parse_str()`, `compress()`, `decompress()`. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface. |
| `dataview.rs` | Read-only windowed view into a shared byte buffer. `DataView` provides typed accessor methods over a slice of a `Vec<u8>` without copying the underlying data. All reads are little-endian. Bounds are checked on every access; out-of-range indices return an error. |
| `encode.rs` | Base64 and hex encoding/decoding for data serialization. This module is part of Luna2D's `data` subsystem and provides the implementation details for encode-related operations and data management. Key types exported from this module: `EncodeFormat`. Primary functions: `parse_str()`, `encode()`, `decode()`. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface. |
| `hash.rs` | Cryptographic hash functions for data integrity verification. This module is part of Luna2D's `data` subsystem and provides the implementation details for hash-related operations and data management. Key types exported from this module: `HashAlgorithm`. Primary functions: `parse_str()`, `hash()`. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface. |
| `pack.rs` | Binary pack/unpack utilities compatible with LÖVE2D's `data.pack` API. Provides format-string based binary serialization for the `luna.data` module. Supports little-endian and big-endian byte order via `<` and `>` prefixes. |
| `toml_convert.rs` | TOML parsing and encoding for Luna2D. Converts between TOML strings and Lua tables. Supports the full TOML spec via the `toml` crate, mapping types to their Lua equivalents. This module is part of Luna2D's `data` subsystem and provides the implementation details for toml convert-related operations and data management. Primary functions: `parse_toml()`, `encode_toml()`. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface. |

## Submodules

### `data::bin_pack`

Luna2D Binary Pack Format — format-string based binary serialization. Provides `write`, `read`, and `measure_size` for the `luna.data` module. Format strings use space-separated named type tokens. # Format string tokens | Token  | Type                       | Byte size  | |--------|----------------------------|------------| | `le`   | switch to little-endian    | (modifier) | | `be`   | switch to big-endian       | (modifier) | | `u8`   | unsigned 8-bit integer     | 1          | | `u16`  | unsigned 16-bit integer    | 2          | | `u32`  | unsigned 32-bit integer    | 4          | | `u64`  | unsigned 64-bit integer    | 8          | | `i8`   | signed 8-bit integer       | 1          | | `i16`  | signed 16-bit integer      | 2          | | `i32`  | signed 32-bit integer      | 4          | | `i64`  | signed 64-bit integer      | 8          | | `f32`  | 32-bit float               | 4          | | `f64`  | 64-bit float               | 8          | | `bool` | boolean (u8: 0=false)      | 1          | | `str`  | u32-length-prefixed UTF-8  | 4 + len    | | `cstr` | null-terminated UTF-8      | len + 1    | | `pad`  | zero padding byte          | 1          |

- **`BinValue`** (enum): TODO: one-line description.

### `data::byte_data`

Contiguous byte buffer accessible from Lua. This module is part of Luna2D's `data` subsystem and provides the implementation details for byte data-related operations and data management. Key types exported from this module: `ByteData`. Primary functions: `new()`, `from_bytes()`, `from_string()`, `len()`. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.

- **`ByteData`** (struct): TODO: one-line description.

### `data::compress`

Data compression and decompression using deflate, gzip, zlib, and LZ4. This module is part of Luna2D's `data` subsystem and provides the implementation details for compress-related operations and data management. Key types exported from this module: `CompressFormat`. Primary functions: `parse_str()`, `compress()`, `decompress()`. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.

- **`CompressFormat`** (enum): TODO: one-line description.

### `data::dataview`

Read-only windowed view into a shared byte buffer. `DataView` provides typed accessor methods over a slice of a `Vec<u8>` without copying the underlying data. All reads are little-endian. Bounds are checked on every access; out-of-range indices return an error.

- **`DataView`** (struct): TODO: one-line description.

### `data::encode`

Base64 and hex encoding/decoding for data serialization. This module is part of Luna2D's `data` subsystem and provides the implementation details for encode-related operations and data management. Key types exported from this module: `EncodeFormat`. Primary functions: `parse_str()`, `encode()`, `decode()`. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.

- **`EncodeFormat`** (enum): TODO: one-line description.

### `data::hash`

Cryptographic hash functions for data integrity verification. This module is part of Luna2D's `data` subsystem and provides the implementation details for hash-related operations and data management. Key types exported from this module: `HashAlgorithm`. Primary functions: `parse_str()`, `hash()`. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.

- **`HashAlgorithm`** (enum): TODO: one-line description.

### `data::pack`

Binary pack/unpack utilities compatible with LÖVE2D's `data.pack` API. Provides format-string based binary serialization for the `luna.data` module. Supports little-endian and big-endian byte order via `<` and `>` prefixes.

- **`PackValue`** (enum): TODO: one-line description.

### `data::toml_convert`

TOML parsing and encoding for Luna2D. Converts between TOML strings and Lua tables. Supports the full TOML spec via the `toml` crate, mapping types to their Lua equivalents. This module is part of Luna2D's `data` subsystem and provides the implementation details for toml convert-related operations and data management. Primary functions: `parse_toml()`, `encode_toml()`. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.

## Key Types

### Structs

#### `data::byte_data::ByteData`

TODO: description from `///` doc comment.

#### `data::dataview::DataView`

TODO: description from `///` doc comment.

### Enums

#### `data::bin_pack::BinValue`

TODO: description from `///` doc comment.

#### `data::compress::CompressFormat`

TODO: description from `///` doc comment.

#### `data::encode::EncodeFormat`

TODO: description from `///` doc comment.

#### `data::hash::HashAlgorithm`

TODO: description from `///` doc comment.

#### `data::pack::PackValue`

TODO: description from `///` doc comment.

## Lua API

Exposed under `luna.data.*` by `src\lua_api\data_api.rs`.

TODO: Describe the overall API surface. List the major categories of functions.

Exposed functions include: `data`.

## Lua Examples

```lua
-- Example: Basic data usage
function luna.load()
    -- TODO: replace with real data setup
    local obj = luna.data.data()
end

function luna.update(dt)
    -- TODO: update logic
end
```

## Item Summary

| Kind | Count |
|------|-------|
| `struct` | 2 |
| `enum`   | 5 |
| `fn`     | 13 |
| **Total** | **20** |

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
