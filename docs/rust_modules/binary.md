# binary

## General Info

- Module group: `Foundations`
- Source path: `src/binary/`
- Binding: `src/lua_api/binary_api.rs`
- Namespace: `lurek.binary`
- Lua API surface: `22` functions, `4` types, `50` methods
- Rust test path(s): tests/rust/unit/binary_tests.rs; tests/rust/stress/binary_stress_tests.rs; inline tests in src/binary/byte_data.rs, src/binary/encode.rs, src/binary/hash.rs
- Lua test path(s): tests/lua/unit/test_binary_core_unit.lua; tests/lua/stress/test_binary_stress.lua; tests/lua/integration/test_binary_filesystem.lua; tests/lua/integration/test_binary_compute.lua; tests/lua/golden/test_binary_golden.lua

## Summary

The `binary` module is the low-level data toolbox for byte-oriented workflows in the engine. It gives scripts and systems one consistent way to create buffers, read and write typed values, and transform payloads between raw bytes and transport-friendly formats.

Its practical scope covers the full binary path: structured pack and unpack operations, sequential writing, read-only views, text encoding and decoding, compression and decompression, and integrity checks with checksums and hashes. This makes it useful for save data, protocol payloads, and tool interoperability.

The module is intentionally composable. Instead of forcing one serializer style, it offers focused building blocks that can be combined as needed. Teams can use quick helpers for small tasks or build strict format-driven flows for larger binary contracts.

Predictability is a key value here. Endianness, bounds checks, cursor behavior, and conversion semantics are explicit and deterministic, so higher modules can rely on stable behavior over time.

## Files

### [bin_pack.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/binary/bin_pack.rs)

- Implements token-driven binary pack and unpack flows over whitespace-delimited format descriptions.
- Supports endian-aware serialization of scalar values, strings, booleans, and raw byte payloads.
- Applies value coercion rules so heterogeneous input variants can be normalized at write time.
- Handles fixed-width and variable-width token semantics including prefixed and null-terminated strings.
- Provides padding support for alignment-sensitive binary structure construction.
- Performs bounds-checked reads and returns structured failures on truncated source buffers.
- Computes format size where possible to aid buffer planning and validation.
- Returns owned byte containers suitable for downstream binary pipeline integration.
- Keeps format parsing and conversion behavior deterministic for script-driven packing contracts.
- Serves as a high-level schema layer above low-level byte buffer primitives.

### [byte_data.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/binary/byte_data.rs)

- Implements an owned mutable byte buffer with indexed access and conversion helpers.
- Supports UTF-8 encoding and tolerant text decoding from arbitrary byte content.
- Exposes immutable and mutable slice views for efficient downstream processing.
- Serves as the foundational byte container shared across binary utility modules.

### [compress.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/binary/compress.rs)

- Implements multi-codec compression and decompression for buffer and stream style workflows.
- Supports deflate, gzip, zlib, and lz4 variants through one unified format selection surface.
- Provides full-buffer and chunked processing paths for different memory and throughput constraints.
- Applies bounded compression-level normalization to keep codec settings within valid operating ranges.
- Adapts chunk lists into stream readers for incremental processing integration.
- Returns codec-contextual error results that preserve failure source clarity.

### [data_writer.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/binary/data_writer.rs)

- Implements sequential binary writing over a growable buffer with explicit cursor control.
- Supports little-endian and big-endian emission for integers, floats, and string payloads.
- Allows seeking within the buffer to overwrite or append structured binary segments.
- Zero-fills gaps when seeking past current length to keep layout deterministic.
- Serves as the mutable write surface for format-driven serialization workflows.

### [dataview.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/binary/dataview.rs)

- Implements a read-only typed view over shared byte storage with offset and length windows.
- Provides bounds-checked scalar decoding for integer and floating-point primitive types.
- Supports validated sub-view creation for structured parsing of nested binary regions.
- Keeps shared ownership cheap through Arc-backed buffer references in multi-consumer paths.
- Serves as the safe read surface for binary inspection and Lua-facing bridge wrappers.

### [encode.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/binary/encode.rs)

- Implements textual encoding and decoding of opaque bytes via base64 and hexadecimal formats.
- Selects algorithms through stable enum variants parsed from user-facing format labels.
- Returns normalized failures for malformed textual payloads during decode operations.

### [hash.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/binary/hash.rs)

- Implements digest and checksum computation over byte payloads for integrity and fingerprint workflows.
- Supports MD5, SHA-1, SHA-256, and SHA-512 cryptographic hash algorithm variants.
- Provides CRC32 checksum generation for fast non-cryptographic validation scenarios.
- Returns all computed digests as stable hexadecimal text for interoperable output handling.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/binary/mod.rs)

- Defines the binary utility module boundary for byte serialization, transformation, and integrity workflows.
- Groups packing, encoding, compression, hashing, and buffer primitives under one coherent toolbox.
- Serves as the composition root for engine-side binary data manipulation operations.

### [pack.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/binary/pack.rs)

- Implements struct-style format packing and unpacking for compact binary schema workflows.
- Parses tokenized format strings covering numeric types, strings, and explicit padding markers.
- Supports endian switching through prefix directives for cross-platform wire compatibility.
- Handles both fixed and variable-width string representations during serialization and decode.
- Applies numeric widening and coercion rules so value variants map safely onto target tokens.
- Performs strict bounds checks on reads with token-aware failure context for truncated input.
- Computes static or dynamic packed size to aid allocation and validation steps.
- Produces owned byte outputs integrated with shared binary data container contracts.

### [ring_buffer.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/binary/ring_buffer.rs)

- Implements a fixed-capacity circular queue with overwrite-on-full FIFO behavior.
- Supports push, pop, peek, and indexed access over the current logical element window.
- Preserves deterministic oldest-to-newest traversal for iteration and collection flows.
- Provides copy-optimized extraction helpers for compatible element type constraints.
- Serves as a compact buffering primitive for streaming and rolling-window scenarios.
