# `data` — Agent Reference

| Property | Value |
|----------|-------|
| **Tier** | Tier 1 — Basic Core |
| **Lua API** | `luna.data` |
| **Source** | `src/data/` |
| **Tests** | `tests/data_tests.rs` |
| **Lua Tests** | `tests/lua/unit/test_data.lua` |

## Summary

The data module provides a runtime key-value store and a TOML serialisation
surface that together fill the gap between ephemeral Lua local variables and
full save-game persistence.  Global game flags, player preferences,
cross-scene statistics, and configuration values live here: any Lua script can
read or write a named key without passing values through the call stack or
storing them in globals.

The TOML marshaller (`luna.data.parseToml` / `luna.data.encodeToml`) handles
the full TOML value space — strings, integers, floats, booleans, datetime
strings, inline tables, and arrays — mapping each TOML type to the nearest Lua
equivalent and back with round-trip fidelity for typical config patterns.
Beyond TOML the module also exposes hash functions (MD5, SHA-1, CRC32) for
save-data integrity checksums and deflate/inflate compression for binary
storage and network transfer.

## Architecture

```
data/
  │
  ├── ByteData ── Vec<u8> wrapper with Lua UserData interface
  │
  ├── compress ── deflate / gzip / lz4 / zlib (level 0-9)
  │
  ├── encode ── base64 / hex encoding and decoding
  │
  ├── hash ── md5 / sha1 / sha256 / sha512 → hex string
  │
  └── toml_convert ── parse_toml / encode_toml for TOML ↔ Lua table
```

## Source Files

| File | Purpose |
|------|---------|
| `mod.rs` | Module root; re-exports all public API items |
| `byte_data.rs` | Contiguous byte buffer accessible from Lua |
| `compress.rs` | Data compression and decompression using deflate, gzip, zlib, and LZ4 |
| `dataview.rs` | Read-only windowed view into a shared byte buffer |
| `encode.rs` | Base64 and hex encoding/decoding for data serialization |
| `hash.rs` | Cryptographic hash functions for data integrity verification |
| `pack.rs` | Binary pack/unpack utilities compatible with LÖVE2D `data.pack` API |
### `data::byte_data`

Contiguous byte buffer accessible from Lua.

- **`ByteData`** (struct): Contiguous byte buffer for binary data manipulation.  Wraps a `Vec<u8>` with indexed get/set operations and string...

### `data::compress`

Data compression and decompression using deflate, gzip, zlib, and LZ4.

- **`CompressFormat`** (enum): Supported compression formats. Consult the module-level documentation for the broader usage context and preconditions.
- **`compress`** (fn): Compress data using the specified format and compression level (0-9).
- **`decompress`** (fn): Decompress data using the specified format.

### `data::encode`

Base64 and hex encoding/decoding for data serialization.

- **`EncodeFormat`** (enum): Supported encoding formats. Consult the module-level documentation for the broader usage context and preconditions.
- **`encode`** (fn): Encode bytes into a string using the specified format.
- **`decode`** (fn): Decode a string back into bytes using the specified format.

### `data::hash`

Cryptographic hash functions for data integrity verification.

- **`HashAlgorithm`** (enum): Supported hash algorithms. Consult the module-level documentation for the broader usage context and preconditions.
- **`hash`** (fn): Compute the hash of data using the specified algorithm, returned as a hex string.

### `data::dataview`

Read-only windowed view into a shared byte buffer.

- **`DataView`** (struct): Typed accessor over a byte slice; supports `get_u8`, `get_u16`, `get_u32`, `get_i8`, `get_i16`, `get_i32`, `get_f32`, `get_f64`, and `get_bytes`.

### `data::pack`

Binary pack/unpack utilities compatible with LÖVE2D `data.pack` API.

- **`PackValue`** (enum): Typed value that can be packed or unpacked: Bool, Int, Float, String, Bytes.
- **`pack`** (fn): Serialize a slice of `PackValue` to `ByteData` using a format string.
- **`unpack`** (fn): Deserialize bytes at `offset` into a `Vec<PackValue>` using a format string.
- **`get_packed_size`** (fn): Return the byte size a set of values would occupy without allocating.

### `data::toml_convert`

TOML parsing and encoding for Luna2D.

- **`parse_toml`** (fn): Parse a TOML string into a `toml::Value`.
- **`encode_toml`** (fn): Encode a `toml::Value` into a TOML string.

## Key Types

### Structs

#### `data::byte_data::ByteData`

Contiguous byte buffer for binary data manipulation. Wraps a `Vec<u8>` with indexed get/set operations and string conversion.

#### `data::dataview::DataView`

Read-only windowed view into a shared byte buffer. Typed accessors (`get_u8`, `get_u16`, `get_f32`, etc.) operate on a sub-slice at a given offset.

### Enums

#### `data::compress::CompressFormat`

Supported compression formats.

#### `data::encode::EncodeFormat`

Supported encoding formats.

#### `data::hash::HashAlgorithm`

Supported hash algorithms.

#### `data::pack::PackValue`

Typed value that can be packed or unpacked: Bool, Int, Float, String, Bytes.

## Public Functions

- **`compress()`** `compress::` — Compress data using the specified format and compression level (0-9).
- **`decode()`** `encode::` — Decode a string back into bytes using the specified format.
- **`decompress()`** `compress::` — Decompress data using the specified format.
- **`encode()`** `encode::` — Encode bytes into a string using the specified format.
- **`encode_toml()`** `toml_convert::` — Encode a `toml::Value` into a TOML string.
- **`get_packed_size()`** `pack::` — Return the byte size a set of values would occupy without allocating.
- **`hash()`** `hash::` — Compute the hash of data using the specified algorithm, returned as a hex string.
- **`pack()`** `pack::` — Serialize a slice of `PackValue` to `ByteData` using a format string.
- **`parse_toml()`** `toml_convert::` — Parse a TOML string into a `toml::Value`.
- **`unpack()`** `pack::` — Deserialize bytes at `offset` into a `Vec<PackValue>` using a format string.

## Lua API

Exposed under `luna.data.*` by `src/lua_api/data_api/`.

## Item Summary

| Kind | Count |
|------|-------|
| `enum` | 4 |
| `fn` | 10 |
| `mod` | 7 |
| `struct` | 2 |
| **Total** | **23** |

