# binary

## TL;DR

- Manages byte buffers, format packing, and MsgPack/TOML serialization.
- Controls compression, cryptographic hashing, and element ring buffers.

## General Info

- Module group: `Foundations`
- Source path: `src/binary/`
- Binding: `src/lua_api/binary_api.rs`
- Namespace: `lurek.binary`
- Lua API surface: `22` functions, `4` types, `50` methods
- Rust test path(s): tests/rust/unit/binary_tests.rs; tests/rust/stress/binary_stress_tests.rs; inline tests in src/binary/byte_data.rs, src/binary/encode.rs, src/binary/hash.rs
- Lua test path(s): tests/lua_reorg/unit/test_binary_core_unit.lua; tests/lua_reorg/stress/test_binary_stress.lua; tests/lua_reorg/integration/test_binary_filesystem.lua; tests/lua_reorg/integration/test_binary_compute.lua; tests/lua_reorg/golden/test_binary_golden.lua

## Summary

- Gives scripts low-level byte control for save formats, protocol payloads, and compact runtime data exchange.
- Supports mutable binary buffers for write-heavy flows and typed read views for safe structured parsing.
- Enables bit-level edits and indexed byte access when gameplay systems need precise binary patch operations.
- Provides format-string pack and unpack paths so teams can define wire/file layouts without hand-rolled serializers.
- Handles endian selection and padding concerns for cross-platform compatibility and legacy format interoperability.
- Offers data-writer primitives for building binary payloads incrementally with explicit cursor control.
- Exposes TOML encode/decode helpers that bridge textual config and binary-centric pipelines.
- Includes MsgPack conversion to move rich Lua values through compact transport or storage channels.
- Provides compression and decompression across multiple codecs for bandwidth and disk footprint reduction.
- Supports chunked compression paths for stream-like workflows where full-buffer loading is undesirable.
- Adds base64 and hex transforms for systems that require text-safe binary representation.
- Includes cryptographic and checksum hashing to verify integrity or fingerprint content deterministically.
- Supplies ring-buffer utilities for rolling windows, streaming queues, and fixed-memory pipelines.
- Helps users keep binary tooling in-engine instead of relying on external preprocessors.
- Serves as the practical bridge between high-level Lua logic and byte-accurate data contracts.
- Reduces serialization bugs by centralizing common conversion, packing, and validation patterns.
- Improves debugging by exposing readable conversion outputs and deterministic hash/checksum results.
- Lets gameplay and tooling scripts share one consistent binary workflow surface across the project.

This module is mostly self-contained inside the `Foundations` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

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

### Functions

- `lurek.binary.compress(format_str, raw_data, level?) -> string`: Compresses a binary string using a named compression format.
- `lurek.binary.compressChunks(format_str, chunks, level?) -> string`: Compresses a string or table of strings as a chunked byte stream.
- `lurek.binary.crc32(raw_data) -> integer`: Computes CRC32 for a binary string.
- `lurek.binary.decode(format_str, encoded) -> string`: Decodes a string using a named text encoding format.
- `lurek.binary.decompress(format_str, compressed) -> string`: Decompresses a binary string using a named compression format.
- `lurek.binary.decompressChunks(format_str, chunks) -> string`: Decompresses a string or table of strings as a chunked byte stream.
- `lurek.binary.encode(format_str, raw_data) -> string`: Encodes a binary string using a named text encoding format.
- `lurek.binary.encodeToml(tbl) -> string`: Encodes a Lua table into a TOML document string.
- `lurek.binary.fromMsgPack(bytes) -> LuaValue`: Decodes a structured binary interchange payload back into Lua values.
- `lurek.binary.getPackedSize(fmt, ...) -> integer`: Computes the packed byte size for values and a format string.
- `lurek.binary.hash(algo_str, raw_data) -> string`: Hashes a binary string with a named algorithm.
- `lurek.binary.newByteData(value) -> LByteData`: Creates ByteData from a size or string.
- `lurek.binary.newDataView(raw, offset?, size?) -> LDataView`: Creates a DataView over a binary string slice.
- `lurek.binary.newRingBuffer(capacity) -> LRingBuffer`: Creates a fixed-capacity ring buffer for Lua values.
- `lurek.binary.newWriter() -> LDataWriter`: Creates an empty binary data writer.
- `lurek.binary.pack(fmt, ...) -> string`: Packs Lua values into a binary string using a format string.
- `lurek.binary.parseToml(text) -> table`: Parses TOML text into Lua tables and scalar values.
- `lurek.binary.read(fmt, raw, offset?) -> LuaValue`: Reads binary values from a byte string using a format string.
- `lurek.binary.size(fmt) -> integer`: Measures fixed byte size for a binary format string.
- `lurek.binary.toMsgPack(value) -> string`: Encodes a Lua value into the current structured binary interchange payload.
- `lurek.binary.unpack(fmt, raw, offset?) -> LuaValue`: Unpacks values from a binary string using a format string.
- `lurek.binary.write(fmt, ...) -> string`: Writes binary values into a byte string using a format string.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LByteData Type

- Exposes byte-buffer inspection and bit editing methods to Lua.

##### Fields

- No documented fields.

##### Methods

- `LByteData:clone() -> LByteData`: Returns a deep copy of the entire byte buffer.
- `LByteData:getBit(byte_offset, bit_offset) -> boolean`: Reads one bit inside a byte at the given offsets.
- `LByteData:getByte(offset) -> integer`: Reads one byte at a zero-based offset.
- `LByteData:getSize() -> integer`: Returns the byte buffer length in bytes.
- `LByteData:getString() -> string`: Returns the byte buffer as a string.
- `LByteData:readBits(byte_offset, bit_offset, count) -> integer`: Reads up to 32 bits starting at a byte and bit offset.
- `LByteData:setBit(byte_offset, bit_offset, value) -> nil`: Sets or clears one bit inside a byte at the given offset.
- `LByteData:setByte(offset, value) -> nil`: Writes one byte at a zero-based offset inside the buffer.
- `LByteData:type() -> string`: Returns the type name of this object for runtime type-checking.
- `LByteData:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LDataView Type

- Creates a DataView over a binary string slice.

##### Fields

- No documented fields.

##### Methods

- `LDataView:getDouble(offset) -> number`: Reads a 64-bit float at a byte offset.
- `LDataView:getFloat(offset) -> number`: Reads a 32-bit float at a byte offset.
- `LDataView:getInt16(offset) -> integer`: Reads a signed 16-bit integer at a byte offset.
- `LDataView:getInt32(offset) -> integer`: Reads a signed 32-bit integer at a byte offset.
- `LDataView:getInt8(offset) -> integer`: Reads a signed 8-bit integer at a byte offset.
- `LDataView:getSize() -> integer`: Returns this data view size in bytes.
- `LDataView:getUInt16(offset) -> integer`: Reads an unsigned 16-bit integer at a byte offset.
- `LDataView:getUInt32(offset) -> integer`: Reads an unsigned 32-bit integer at a byte offset.
- `LDataView:getUInt8(offset) -> integer`: Reads an unsigned 8-bit integer at a byte offset.
- `LDataView:type() -> string`: Returns the Lua-visible type name for this data view handle.
- `LDataView:typeOf(name) -> boolean`: Returns whether this data view handle matches a supported type name.

#### LDataWriter Type

- Lua-side binary writer for sequential byte construction.

##### Fields

- No documented fields.

##### Methods

- `LDataWriter:len() -> integer`: Returns the current length of the writer buffer.
- `LDataWriter:seek(pos) -> nil`: Moves the writer cursor to a specific byte position.
- `LDataWriter:tell() -> integer`: Returns the writer cursor position.
- `LDataWriter:toBytes() -> string`: Returns the writer buffer as a binary string.
- `LDataWriter:type() -> string`: Returns the Lua-visible type name for this data writer handle.
- `LDataWriter:typeOf(name) -> boolean`: Returns whether this data writer handle matches a supported type name.
- `LDataWriter:writeBytes(s) -> nil`: Appends raw bytes from a Lua string to the writer buffer.
- `LDataWriter:writeF32LE(v) -> nil`: Appends a 32-bit float value in little-endian byte order.
- `LDataWriter:writeF64LE(v) -> nil`: Appends a 64-bit float value in little-endian byte order.
- `LDataWriter:writeI16LE(v) -> nil`: Appends a signed 16-bit integer in little-endian byte order.
- `LDataWriter:writeI32LE(v) -> nil`: Appends a signed 32-bit integer in little-endian byte order.
- `LDataWriter:writeI8(v) -> nil`: Appends a signed 8-bit integer to the writer buffer.
- `LDataWriter:writeString(s) -> nil`: Appends a UTF-8 encoded string to the writer buffer.
- `LDataWriter:writeU16BE(v) -> nil`: Appends an unsigned 16-bit integer in big-endian byte order.
- `LDataWriter:writeU16LE(v) -> nil`: Appends an unsigned 16-bit integer in little-endian byte order.
- `LDataWriter:writeU32LE(v) -> nil`: Appends an unsigned 32-bit integer in little-endian byte order.
- `LDataWriter:writeU8(v) -> nil`: Appends an unsigned 8-bit integer to the writer buffer.

#### LRingBuffer Type

- Lua-side fixed-capacity FIFO buffer that stores registry-protected Lua values.

##### Fields

- No documented fields.

##### Methods

- `LRingBuffer:capacity() -> integer`: Returns the maximum capacity of the ring buffer.
- `LRingBuffer:clear() -> nil`: Removes every stored value and releases their registry keys.
- `LRingBuffer:isEmpty() -> boolean`: Returns whether the ring buffer has no values.
- `LRingBuffer:isFull() -> boolean`: Returns whether the ring buffer is at capacity.
- `LRingBuffer:len() -> integer`: Returns the number of values currently stored.
- `LRingBuffer:peek() -> LuaValue`: Returns the oldest stored value without removing it from the ring buffer.
- `LRingBuffer:peekNewest() -> LuaValue`: Returns the newest stored value without removing it from the ring buffer.
- `LRingBuffer:pop() -> LuaValue`: Removes and returns the oldest stored value from the ring buffer.
- `LRingBuffer:push(value) -> boolean`: Pushes a value into the ring buffer and evicts the oldest value when full.
- `LRingBuffer:toTable() -> number[]`: Returns stored values in oldest-to-newest order.
- `LRingBuffer:type() -> string`: Returns the Lua-visible type name for this ring buffer handle.
- `LRingBuffer:typeOf(name) -> boolean`: Returns whether this ring buffer handle matches a supported type name.
