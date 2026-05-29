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

- Token-based binary packing and unpacking using whitespace-separated format strings
- Endian-aware serialization of integers, floats, booleans, strings, and raw bytes
- Coercion helpers that convert between BinValue variants at write time
- Length-prefixed and null-terminated string support for wire protocols
- Padding tokens for alignment and fixed-layout binary structures
- Bounds-checked reads with descriptive underflow error messages
- Static size measurement for formats without variable-width tokens
- ByteData output for zero-copy integration with the binary module pipeline

### byte_data.rs

- Owned mutable byte buffer with indexed read and write access
- UTF-8 string encoding and lossy decoding from raw bytes
- Immutable and mutable slice views for zero-copy downstream use

### compress.rs

- Multi-codec compression and decompression (deflate, gzip, zlib, lz4)
- Full-buffer and streaming APIs for both single slices and chunk lists
- Configurable compression level clamped to valid range (0-9)
- ChunkReader adapter that flattens multiple borrowed slices into one Read stream
- Consistent error wrapping with codec-specific context messages

### data_writer.rs

- Sequential binary writer with a movable cursor over a growable byte buffer
- Little-endian and big-endian integer, float, and string write methods
- Seek support with automatic zero-fill when moving past buffer end

### dataview.rs

- Read-only typed accessor over a shared Arc byte buffer
- Bounds-checked scalar reads for u8, i8, u16, i16, u32, i32, f32, f64
- Sub-slice views with validated offset and size
- LuaDataView wrapper for Lua-facing ownership patterns

### encode.rs

- Base64 and hexadecimal encoding and decoding for opaque byte payloads
- Format selection via enum variant parsed from user-facing labels
- Consistent error wrapping for malformed input

### hash.rs

- Cryptographic hash digest computation (MD5, SHA-1, SHA-256, SHA-512)
- CRC32 checksum for fast integrity checks
- Hex-encoded string output for all digest algorithms

### mod.rs

- Binary packing, unpacking, and struct-style format-string serialization
- Owned byte buffers, shared data views, and sequential writers
- Compression codecs (deflate, gzip, zlib, lz4) with stream and chunk APIs
- Encoding helpers (base64, hex) and hash digests (MD5, SHA, CRC32)
- Fixed-capacity ring buffer with overwrite-on-full FIFO semantics

### pack.rs

- Python struct-style format-string packing and unpacking
- Single-character format tokens for integers, floats, strings, and padding
- Endian switching via '<' (little) and '>' (big) prefix characters
- Length-prefixed ('s') and null-terminated ('z') string support
- Coercion helpers that widen numeric PackValue variants at write time
- Bounds-checked reads with per-token underflow error messages
- Static and dynamic packed-size calculation for buffer pre-allocation
- ByteData output for integration with the binary module pipeline

### ring_buffer.rs

- Fixed-capacity circular buffer with oldest-overwrite FIFO semantics
- Push, pop, peek, and index-based access with O(1) operations
- Iteration and collection helpers from oldest to newest element
- Copy-optimized collection for `Clone + Copy` element types

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
