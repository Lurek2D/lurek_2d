# binary

## TL;DR

- Manages byte buffers, format packing, compression, hashing, and byte-safe encodings.
- Controls compression, cryptographic hashing, and element ring buffers.

## General Info

- Module group: `Foundations`
- Source path: `src/binary/`
- Binding: `src/lua_api/binary_api.rs`
- Namespace: `lurek.binary`
- Lua API surface: `18` functions, `4` types, `50` methods
- Rust test path(s): tests/rust/unit/binary_tests.rs; tests/rust/stress/binary_stress_tests.rs; inline tests in src/binary/byte_data.rs, src/binary/encode.rs, src/binary/hash.rs
- Lua test path(s): tests/lua/unit/test_binary_core_unit.lua; tests/lua/stress/test_binary_stress.lua; tests/lua/integration/test_binary_filesystem.lua; tests/lua/integration/test_binary_compute.lua; tests/lua/golden/test_binary_golden.lua

## Summary

- The `binary` module is the byte-oriented data surface for users who need exact control over compact formats, protocol payloads, and structured runtime interchange.
- Mutable byte containers, typed views, sequential writers, and pack-style helpers work together so a script can both inspect existing binary data and build new payloads without inventing its own low-level buffer rules.
- Compression, encoding, hashes, checksums, and ring-buffer helpers matter because real binary workflows usually involve transport safety, storage reduction, and integrity checks alongside raw reads and writes.
- Byte encodings, compression, hashes, checksums, and schema-like packing utilities make the module useful for both debug tooling and production-facing data paths such as saves, networking, and cached assets.
- Exact offset control, byte-order awareness, and sequential write semantics are especially valuable when interoperating with protocols or compact save formats where structure must be reproduced precisely.
- The module therefore acts as the engine's low-level data construction kit whenever higher-level structured formats are too heavy or too opaque for the problem at hand.
- That also makes it useful when tests or tools need to inspect raw payload layout instead of only decoded high-level values.
- It keeps raw layout work first-class.
- Read `binary` as the shared byte-language of the engine: other modules decide what the data means, but `binary` owns how that data is packed, transformed, verified, and moved around safely.
- Structured interchange formats such as TOML and MessagePack belong to `serialize`; `binary` must not expose format-specific structured parsers just because a format can be represented as bytes.

This module is mostly self-contained inside the `Foundations` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### bin_pack.rs

- This file owns the tokenized packing layer that reads whitespace-separated type names for binary layouts.
- `BinValue` represents explicit scalar, boolean, string, and raw byte values consumed by parsed tokens.
- Format parsing normalizes endianness selectors and operation tokens before any read, write, or sizing work.
- The `write` path serializes typed values into bytes, including padding, prefixed strings, and C strings.
- The `read` path decodes bytes back into typed variants, advancing an offset cursor and checking token spans.
- `measure_size` computes only fixed-width layouts, rejecting `str` and `cstr` because they remain data-sized.
- Coercion helpers accept compatible numeric and boolean inputs so callers can feed mixed variants safely.
- Open it when token-schema semantics change; char-format packing and raw buffer helpers live in siblings.

### byte_data.rs

- This file owns `ByteData`, the basic owned byte container used by higher-level binary helpers and Lua wrappers.
- It stores bytes in one growable vector and exposes length, emptiness, indexed mutation, and clone accessors.
- String conversion helpers bridge UTF-8 text to raw bytes so packers and codecs can share one simple buffer type.
- Open it when raw buffer ownership semantics change; typed views, writers, and schema formats live in siblings.

### compress.rs

- This file owns multi-codec compression and decompression helpers for whole buffers, chunks, and stream adapters.
- `CompressFormat` normalizes user codec choice across deflate, gzip, zlib, and LZ4 entry points.
- Full-buffer helpers wrap stream implementations so callers can compress or restore byte vectors directly.
- Chunk helpers flatten borrowed slice lists through `ChunkReader`, preserving incremental read-based call sites.
- Stream helpers handle codec-specific encoder and decoder wiring plus bounded compression-level normalization.
- Open it when binary size or transport semantics change; hashing, text encoding, and schema packing live nearby.

### data_writer.rs

- This file owns `DataWriter`, the sequential binary emitter used to build mutable byte layouts with a cursor.
- It stores one growable buffer plus write position, allowing append and in-place overwrite flows from one owner.
- Endian-specific helpers write integers and floats, while string helpers emit length-prefixed UTF-8 payloads.
- Seeking past current length zero-fills the gap, which keeps patched binary layouts deterministic for readers.
- Open it when raw write semantics change; typed reading, compression, and schema packing live in siblings.

### dataview.rs

- This file owns `DataView`, the shared read-only byte window used for typed inspection of existing buffers.
- It stores an Arc-backed buffer with offset and size bounds so subviews can share storage without copying.
- Scalar getters decode little-endian integers and floats while rejecting out-of-range reads with explicit errors.
- `LuaDataView` wraps the validated view for Lua ownership, separating scripting handles from raw storage.
- Open it when typed read semantics change; writers, packers, and byte ownership helpers live in siblings.

### encode.rs

- This file owns reversible Base64 and hexadecimal conversions for bytes moving through text-only boundaries.
- `EncodeFormat` parses user codec labels, and the helpers expose one small surface for encode and decode work.
- Open it when textual binary transport changes; hashing, compression, and structured packing live in siblings.

### hash.rs

- This file owns digest and checksum helpers that turn arbitrary bytes into deterministic hash strings or CRC32.
- `HashAlgorithm` normalizes user-facing algorithm names for MD5, SHA-1, SHA-256, and SHA-512 selection.
- The main helpers compute lowercase hex digests from buffers without introducing streaming or file I/O concerns.
- Open it when binary identity or integrity semantics change; compression and packing behavior live in siblings.

### mod.rs

- This module is the public binary toolkit index, re-exporting byte containers, codecs, hashes, and packing surfaces.
- It is the entry point for callers that need one import path for raw buffers, typed views, writers, and ring helpers.
- `byte_data.rs`, `data_writer.rs`, and `dataview.rs` own buffer storage, mutation, and typed read access concerns.
- `encode.rs`, `compress.rs`, and `hash.rs` provide reversible text codecs, compression codecs, and digest utilities.
- `pack.rs` and `bin_pack.rs` own two schema formats for struct-like layouts and tokenized typed payload streams.
- Change this file when public binary exports move; change sibling files when buffer semantics or formats change.

### pack.rs

- This file owns the character-format packing layer that serializes and parses compact struct-like layouts.
- `PackValue` carries signed, unsigned, floating, string, and raw byte variants consumed by the interpreter.
- The `pack` path walks one-character tokens to write padding, endian-selected scalars, and variable strings.
- The `unpack` path mirrors those tokens, advances an offset cursor, and returns values plus the next offset.
- Supported tokens cover integer widths, floats, doubles, length-prefixed bytes, null-terminated bytes, and pad.
- Coercion helpers widen numeric variants and accept strings or raw bytes where the format expects payload data.
- Bounds helpers attach token-specific underflow errors so truncated buffers fail with structural context.
- Open it when compact schema rules change; tokenized `bin_pack` and raw buffer utilities live in siblings.

### ring_buffer.rs

- This file owns `RingBuffer`, the fixed-capacity FIFO container that overwrites the oldest item when full.
- It stores slot storage, head index, configured capacity, and current length for deterministic queue rotation.
- Core helpers cover push, pop, peeking, indexed access, clearing, and oldest-to-newest iteration of entries.
- Copy-aware extraction methods let callers collect values or references without repeating circular index math.
- Open it when transient queue buffering changes; binary codecs, views, and schema packing live in siblings.



## Lua API Ref

### Functions

- `lurek.binary.compress(format_str, raw_data, level?) -> string`: Compresses a binary string using a named compression format.
- `lurek.binary.compressChunks(format_str, chunks, level?) -> string`: Compresses a string or table of strings as a chunked byte stream.
- `lurek.binary.crc32(raw_data) -> integer`: Computes CRC32 for a binary string.
- `lurek.binary.decode(format_str, encoded) -> string`: Decodes a string using a named text encoding format.
- `lurek.binary.decompress(format_str, compressed) -> string`: Decompresses a binary string using a named compression format.
- `lurek.binary.decompressChunks(format_str, chunks) -> string`: Decompresses a string or table of strings as a chunked byte stream.
- `lurek.binary.encode(format_str, raw_data) -> string`: Encodes a binary string using a named text encoding format.
- `lurek.binary.getPackedSize(fmt, ...) -> integer`: Computes the packed byte size for values and a format string.
- `lurek.binary.hash(algo_str, raw_data) -> string`: Hashes a binary string with a named algorithm.
- `lurek.binary.newByteData(value) -> LByteData`: Creates ByteData from a size or raw byte string.
- `lurek.binary.newDataView(raw, offset?, size?) -> LDataView`: Creates a DataView over a binary string slice.
- `lurek.binary.newRingBuffer(capacity) -> LRingBuffer`: Creates a fixed-capacity ring buffer for Lua values.
- `lurek.binary.newWriter() -> LDataWriter`: Creates an empty binary data writer.
- `lurek.binary.pack(fmt, ...) -> string`: Packs Lua values into a binary string using a format string.
- `lurek.binary.read(fmt, raw, offset?) -> LuaValue`: Reads binary values from a byte string using a format string.
- `lurek.binary.size(fmt) -> integer`: Measures fixed byte size for a binary format string.
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

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- No additional module-specific notes.
