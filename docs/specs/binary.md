# binary

## TL;DR

- The `binary` module is a comprehensive binary data toolkit situated in the Foundations tier of the engine.

## General Info

- Module group: `Foundations`
- Source path: `src/binary/`
- Lua API path(s): `src/lua_api/binary_api.rs`
- Primary Lua namespace: `lurek.binary`
- Rust test path(s): tests/rust/unit/binary_tests.rs; tests/rust/stress/binary_stress_tests.rs; inline tests in src/binary/byte_data.rs, src/binary/encode.rs, src/binary/hash.rs
- Lua test path(s): tests/lua/unit/test_binary_core_unit.lua; tests/lua/stress/test_binary_stress.lua; tests/lua/integration/test_binary_filesystem.lua; tests/lua/integration/test_binary_compute.lua; tests/lua/golden/test_binary_golden.lua

## Summary

The `binary` module provides byte-level data utilities for serialization, packing, compression, encoding, hashing, and bounded buffering. It is a foundational data layer intended for protocol payloads, save blobs, and binary interchange, independent from renderer or gameplay concerns.

The module is split by responsibility: `byte_data` and `dataview` handle owned/shared byte access, `data_writer` handles sequential writes, `pack` and `bin_pack` handle structured format-string style serialization, `compress` and `encode` provide transport helpers, and `hash` provides checksum/digest utilities. `ring` adds fixed-capacity FIFO behavior with overwrite semantics for streaming scenarios.

Design emphasis is predictable low-level behavior and reusable primitives rather than one monolithic serializer. Callers can compose the specific pieces they need, from quick encode/decode helpers to full packed-structure workflows.

Because this module sits in foundations, its contracts must remain stable and explicit: byte order, bounds behavior, and transformation semantics should be documented and deterministic so higher layers can rely on it for cross-module interoperability.

Implementation detail and boundary guarantees for binary: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: bin_pack.rs: Token-based binary packing and unpacking using whitespace-separated format strings - Endian-aware serialization of integers, floats, booleans, strings, and raw bytes - Coercion helpers that convert between BinValue variants at write time - Length-prefixed and null-terminated stri; byte_data.rs: Owned mutable byte buffer with indexed read and write access - UTF-8 string encoding and lossy decoding from raw bytes - Immutable and mutable slice views for zero-copy downstream use; compress.rs: Multi-codec compression and decompression (deflate, gzip, zlib, lz4) - Full-buffer and streaming APIs for both single slices and chunk lists - Configurable compression level clamped to valid range (0-9) - ChunkReader adapter that flattens multiple borrowed slices into one Read st; data_writer.rs: Sequential binary writer with a movable cursor over a growable byte buffer - Little-endian and big-endian integer, float, and string write methods - Seek support with automatic zero-fill when moving past buffer end; dataview.rs: Read-only typed accessor over a shared Arc byte buffer - Bounds-checked scalar reads for u8, i8, u16, i16, u32, i32, f32, f64 - Sub-slice views with validated offset and size - LuaDataView wrapper for Lua-facing ownership patterns; encode.rs: Base64 and hexadecimal encoding and decoding for opaque byte payloads - Format selection via enum variant parsed from user-facing labels - Consistent error wrapping for malformed input; hash.rs: Cryptographic hash digest computation (MD5, SHA-1, SHA-256, SHA-512) - CRC32 checksum for fast integrity checks - Hex-encoded string output for all digest algorithms; mod.rs: Binary packing, unpacking, and struct-style format-string serialization - Owned byte buffers, shared data views, and sequential writers - Compression codecs (deflate, gzip, zlib, lz4) with stream and chunk APIs - Encoding helpers (base64, hex) and hash digests (MD5, SHA, CRC32) -; pack.rs: Python struct-style format-string packing and unpacking - Single-character format tokens for integers, floats, strings, and padding - Endian switching via '<' (little) and '>' (big) prefix characters - Length-prefixed ('s') and null-terminated ('z') string support - Coercion help; ring_buffer.rs: Fixed-capacity circular buffer with oldest-overwrite FIFO semantics - Push, pop, peek, and index-based access with O(1) operations - Iteration and collection helpers from oldest to newest element - Copy-optimized collection for Clone + Copy element types. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

## Files

### bin_pack.rs

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

### byte_data.rs

- Implements an owned mutable byte buffer with indexed access and conversion helpers.
- Supports UTF-8 encoding and tolerant text decoding from arbitrary byte content.
- Exposes immutable and mutable slice views for efficient downstream processing.
- Serves as the foundational byte container shared across binary utility modules.

### compress.rs

- Implements multi-codec compression and decompression for buffer and stream style workflows.
- Supports deflate, gzip, zlib, and lz4 variants through one unified format selection surface.
- Provides full-buffer and chunked processing paths for different memory and throughput constraints.
- Applies bounded compression-level normalization to keep codec settings within valid operating ranges.
- Adapts chunk lists into stream readers for incremental processing integration.
- Returns codec-contextual error results that preserve failure source clarity.

### data_writer.rs

- Implements sequential binary writing over a growable buffer with explicit cursor control.
- Supports little-endian and big-endian emission for integers, floats, and string payloads.
- Allows seeking within the buffer to overwrite or append structured binary segments.
- Zero-fills gaps when seeking past current length to keep layout deterministic.
- Serves as the mutable write surface for format-driven serialization workflows.

### dataview.rs

- Implements a read-only typed view over shared byte storage with offset and length windows.
- Provides bounds-checked scalar decoding for integer and floating-point primitive types.
- Supports validated sub-view creation for structured parsing of nested binary regions.
- Keeps shared ownership cheap through Arc-backed buffer references in multi-consumer paths.
- Serves as the safe read surface for binary inspection and Lua-facing bridge wrappers.

### encode.rs

- Implements textual encoding and decoding of opaque bytes via base64 and hexadecimal formats.
- Selects algorithms through stable enum variants parsed from user-facing format labels.
- Returns normalized failures for malformed textual payloads during decode operations.

### hash.rs

- Implements digest and checksum computation over byte payloads for integrity and fingerprint workflows.
- Supports MD5, SHA-1, SHA-256, and SHA-512 cryptographic hash algorithm variants.
- Provides CRC32 checksum generation for fast non-cryptographic validation scenarios.
- Returns all computed digests as stable hexadecimal text for interoperable output handling.

### mod.rs

- Defines the binary utility module boundary for byte serialization, transformation, and integrity workflows.
- Groups packing, encoding, compression, hashing, and buffer primitives under one coherent toolbox.
- Serves as the composition root for engine-side binary data manipulation operations.

### pack.rs

- Implements struct-style format packing and unpacking for compact binary schema workflows.
- Parses tokenized format strings covering numeric types, strings, and explicit padding markers.
- Supports endian switching through prefix directives for cross-platform wire compatibility.
- Handles both fixed and variable-width string representations during serialization and decode.
- Applies numeric widening and coercion rules so value variants map safely onto target tokens.
- Performs strict bounds checks on reads with token-aware failure context for truncated input.
- Computes static or dynamic packed size to aid allocation and validation steps.
- Produces owned byte outputs integrated with shared binary data container contracts.

### ring_buffer.rs

- Implements a fixed-capacity circular queue with overwrite-on-full FIFO behavior.
- Supports push, pop, peek, and indexed access over the current logical element window.
- Preserves deterministic oldest-to-newest traversal for iteration and collection flows.
- Provides copy-optimized extraction helpers for compatible element type constraints.
- Serves as a compact buffering primitive for streaming and rolling-window scenarios.

## Lua API Ref

- Binding: `src/lua_api/binary_api.rs`
- Namespace: `lurek.binary`

### Functions

- `lurek.binary.compress`: Compresses a binary string using a named compression format.
- `lurek.binary.compressChunks`: Compresses a string or table of strings as a chunked byte stream.
- `lurek.binary.crc32`: Computes CRC32 for a binary string.
- `lurek.binary.decode`: Decodes a string using a named text encoding format.
- `lurek.binary.decompress`: Decompresses a binary string using a named compression format.
- `lurek.binary.decompressChunks`: Decompresses a string or table of strings as a chunked byte stream.
- `lurek.binary.encode`: Encodes a binary string using a named text encoding format.
- `lurek.binary.encodeToml`: Encodes a Lua table into a TOML document string.
- `lurek.binary.fromMsgPack`: Decodes a structured binary interchange payload back into Lua values.
- `lurek.binary.getPackedSize`: Computes the packed byte size for values and a format string.
- `lurek.binary.hash`: Hashes a binary string with a named algorithm.
- `lurek.binary.newByteData`: Creates ByteData from a size or string.
- `lurek.binary.newDataView`: Creates a DataView over a binary string slice.
- `lurek.binary.newRingBuffer`: Creates a fixed-capacity ring buffer for Lua values.
- `lurek.binary.newWriter`: Creates an empty binary data writer.
- `lurek.binary.pack`: Packs Lua values into a binary string using a format string.
- `lurek.binary.parseToml`: Parses TOML text into Lua tables and scalar values.
- `lurek.binary.read`: Reads binary values from a byte string using a format string.
- `lurek.binary.size`: Measures fixed byte size for a binary format string.
- `lurek.binary.toMsgPack`: Encodes a Lua value into the current structured binary interchange payload.
- `lurek.binary.unpack`: Unpacks values from a binary string using a format string.
- `lurek.binary.write`: Writes binary values into a byte string using a format string.

### Enums

- No documented module-level enums/constants.

### Types

#### LByteData Type

- Exposes byte-buffer inspection and bit editing methods to Lua.

##### Fields

- No documented fields.

##### Methods

- `LByteData:clone`: Returns a deep copy of the entire byte buffer.
- `LByteData:getBit`: Reads one bit inside a byte at the given offsets.
- `LByteData:getByte`: Reads one byte at a zero-based offset.
- `LByteData:getSize`: Returns the byte buffer length in bytes.
- `LByteData:getString`: Returns the byte buffer as a string.
- `LByteData:readBits`: Reads up to 32 bits starting at a byte and bit offset.
- `LByteData:setBit`: Sets or clears one bit inside a byte at the given offset.
- `LByteData:setByte`: Writes one byte at a zero-based offset inside the buffer.
- `LByteData:type`: Returns the type name of this object for runtime type-checking.
- `LByteData:typeOf`: Checks whether this object matches the given type name.

#### LDataView Type

- Creates a DataView over a binary string slice.

##### Fields

- No documented fields.

##### Methods

- `LDataView:getDouble`: Reads a 64-bit float at a byte offset.
- `LDataView:getFloat`: Reads a 32-bit float at a byte offset.
- `LDataView:getInt16`: Reads a signed 16-bit integer at a byte offset.
- `LDataView:getInt32`: Reads a signed 32-bit integer at a byte offset.
- `LDataView:getInt8`: Reads a signed 8-bit integer at a byte offset.
- `LDataView:getSize`: Returns this data view size in bytes.
- `LDataView:getUInt16`: Reads an unsigned 16-bit integer at a byte offset.
- `LDataView:getUInt32`: Reads an unsigned 32-bit integer at a byte offset.
- `LDataView:getUInt8`: Reads an unsigned 8-bit integer at a byte offset.
- `LDataView:type`: Returns the Lua-visible type name for this data view handle.
- `LDataView:typeOf`: Returns whether this data view handle matches a supported type name.

#### LDataWriter Type

- Lua-side binary writer for sequential byte construction.

##### Fields

- No documented fields.

##### Methods

- `LDataWriter:len`: Returns the current length of the writer buffer.
- `LDataWriter:seek`: Moves the writer cursor to a specific byte position.
- `LDataWriter:tell`: Returns the writer cursor position.
- `LDataWriter:toBytes`: Returns the writer buffer as a binary string.
- `LDataWriter:type`: Returns the Lua-visible type name for this data writer handle.
- `LDataWriter:typeOf`: Returns whether this data writer handle matches a supported type name.
- `LDataWriter:writeBytes`: Appends raw bytes from a Lua string to the writer buffer.
- `LDataWriter:writeF32LE`: Appends a 32-bit float value in little-endian byte order.
- `LDataWriter:writeF64LE`: Appends a 64-bit float value in little-endian byte order.
- `LDataWriter:writeI16LE`: Appends a signed 16-bit integer in little-endian byte order.
- `LDataWriter:writeI32LE`: Appends a signed 32-bit integer in little-endian byte order.
- `LDataWriter:writeI8`: Appends a signed 8-bit integer to the writer buffer.
- `LDataWriter:writeString`: Appends a UTF-8 encoded string to the writer buffer.
- `LDataWriter:writeU16BE`: Appends an unsigned 16-bit integer in big-endian byte order.
- `LDataWriter:writeU16LE`: Appends an unsigned 16-bit integer in little-endian byte order.
- `LDataWriter:writeU32LE`: Appends an unsigned 32-bit integer in little-endian byte order.
- `LDataWriter:writeU8`: Appends an unsigned 8-bit integer to the writer buffer.

#### LRingBuffer Type

- Lua-side fixed-capacity FIFO buffer that stores registry-protected Lua values.

##### Fields

- No documented fields.

##### Methods

- `LRingBuffer:capacity`: Returns the maximum capacity of the ring buffer.
- `LRingBuffer:clear`: Removes every stored value and releases their registry keys.
- `LRingBuffer:isEmpty`: Returns whether the ring buffer has no values.
- `LRingBuffer:isFull`: Returns whether the ring buffer is at capacity.
- `LRingBuffer:len`: Returns the number of values currently stored.
- `LRingBuffer:peek`: Returns the oldest stored value without removing it from the ring buffer.
- `LRingBuffer:peekNewest`: Returns the newest stored value without removing it from the ring buffer.
- `LRingBuffer:pop`: Removes and returns the oldest stored value from the ring buffer.
- `LRingBuffer:push`: Pushes a value into the ring buffer and evicts the oldest value when full.
- `LRingBuffer:toTable`: Returns stored values in oldest-to-newest order.
- `LRingBuffer:type`: Returns the Lua-visible type name for this ring buffer handle.
- `LRingBuffer:typeOf`: Returns whether this ring buffer handle matches a supported type name.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.
