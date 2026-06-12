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

## Types

- `BinValue` (`enum`, `bin_pack.rs`): Hold typed values used by token-based binary packing. Details: variants: U8, U16, U32, U64, I8, I16, I32, I64, F32, F64, Bool, Str, Bytes
- `ByteData` (`struct`, `byte_data.rs`): Hold owned raw bytes with convenience conversion helpers. Details: methods: as_bytes (Return immutable byte slice view.); as_bytes_mut (Return mutable byte slice view.); clone_data (Clone internal bytes and return copied buffer.); from_bytes (Wrap existing bytes and return new value.); from_string (Encode UTF-8 text bytes and return new value.); get_byte (Read byte at offset and return optional value.); get_string (Decode bytes as UTF-8 lossily and return string.); is_empty (Return true when buffer has no bytes.); len (Return buffer length in bytes.); new (Create zero-filled buffer and return new value.); set_byte (Write byte at offset and return success flag.)
- `CompressFormat` (`enum`, `compress.rs`): Select compression codec. Details: variants: Deflate, Gzip, Lz4, Zlib | methods: parse_str (Parse codec label and return variant or error.)
- `DataWriter` (`struct`, `data_writer.rs`): Hold buffer and cursor for binary writes. Details: methods: as_bytes (Return immutable bytes view.); into_bytes (Consume writer and return owned bytes.); is_empty (Return true when buffer is empty.); len (Return current buffer length.); new (Create empty writer and return value.); seek (Move cursor to position and grow buffer when needed.); tell (Return current cursor position.); with_capacity (Create writer with reserved capacity and return value.); write_bytes (Write raw bytes at cursor.); write_f32_le (Write f32 in little-endian order.); write_f64_le (Write f64 in little-endian order.); write_i16_le (Write i16 in little-endian order.); write_i32_le (Write i32 in little-endian order.); write_i8 (Write one i8 value at cursor.); write_string (Write length-prefixed UTF-8 string.); write_u16_be (Write u16 in big-endian order.); write_u16_le (Write u16 in little-endian order.); write_u32_le (Write u32 in little-endian order.); write_u8 (Write one u8 value at cursor.)
- `DataView` (`struct`, `dataview.rs`): Hold shared byte slice window with offset and size. Details: fields: data: Arc<Vec<u8>>, offset: usize, size: usize | methods: get_f32 (Read little-endian f32 at index and return value or error.); get_f64 (Read little-endian f64 at index and return value or error.); get_i16 (Read little-endian i16 at index and return value or error.); get_i32 (Read little-endian i32 at index and return value or error.); get_i8 (Read i8 at index and return value or error.); get_size (Return view size in bytes.); get_u16 (Read little-endian u16 at index and return value or error.); get_u32 (Read little-endian u32 at index and return value or error.); get_u8 (Read u8 at index and return value or error.); new (Create full-buffer view and return value.); new_slice (Create sub-slice view and return value or bounds error.)
- `LuaDataView` (`struct`, `dataview.rs`): Wrap DataView for Lua-facing ownership patterns. Details: fields: inner: DataView | methods: new (Wrap DataView and return LuaDataView.)
- `EncodeFormat` (`enum`, `encode.rs`): Select textual encoding algorithm. Details: variants: Base64, Hex | methods: parse_str (Parse format label and return encoding variant or error.)
- `HashAlgorithm` (`enum`, `hash.rs`): Select hash algorithm used for digest computation. Details: variants: Md5, Sha1, Sha256, Sha512 | methods: parse_str (Parse algorithm label and return hash variant or error.)
- `PackValue` (`enum`, `pack.rs`): Hold value variants used by pack and unpack formats. Details: variants: Int, UInt, Float, Double, Str, Bytes
- `RingBuffer` (`struct`, `ring_buffer.rs`): Hold circular queue storage with overwrite semantics. Details: methods: capacity (Return configured capacity.); clear (Clear all elements and reset indices.); collect_copy (Copy elements into Vec from oldest to newest.); get (Return element by logical index from oldest.); is_empty (Return true when element count is zero.); is_full (Return true when element count equals capacity.); iter (Iterate elements from oldest to newest.); len (Return current element count.); new (Create ring buffer with capacity clamped to at least one.); peek (Return oldest element reference.); peek_newest (Return newest element reference.); pop (Pop oldest value and return optional element.); push (Push value and return true when buffer was not full.); to_refs (Collect references into Vec from oldest to newest.); to_vec (Clone elements into Vec from oldest to newest.)

## Functions

- `write` (`bin_pack.rs`): Write values by token format and return ByteData or error.
- `read` (`bin_pack.rs`): Read values by token format and return values with next offset.
- `measure_size` (`bin_pack.rs`): Measure static size for token format without variable-width tokens.
- `ByteData::new` (`byte_data.rs`): Create zero-filled buffer and return new value.
- `ByteData::from_bytes` (`byte_data.rs`): Wrap existing bytes and return new value.
- `ByteData::from_string` (`byte_data.rs`): Encode UTF-8 text bytes and return new value.
- `ByteData::len` (`byte_data.rs`): Return buffer length in bytes.
- `ByteData::is_empty` (`byte_data.rs`): Return true when buffer has no bytes.
- `ByteData::get_byte` (`byte_data.rs`): Read byte at offset and return optional value.
- `ByteData::set_byte` (`byte_data.rs`): Write byte at offset and return success flag.
- `ByteData::get_string` (`byte_data.rs`): Decode bytes as UTF-8 lossily and return string.
- `ByteData::as_bytes` (`byte_data.rs`): Return immutable byte slice view.
- `ByteData::as_bytes_mut` (`byte_data.rs`): Return mutable byte slice view.
- `ByteData::clone_data` (`byte_data.rs`): Clone internal bytes and return copied buffer.
- `CompressFormat::parse_str` (`compress.rs`): Parse codec label and return variant or error.
- `compress` (`compress.rs`): Compress full byte slice and return compressed bytes.
- `decompress` (`compress.rs`): Decompress full byte slice and return decoded bytes.
- `compress_chunks` (`compress.rs`): Compress concatenated chunks and return compressed bytes.
- `decompress_chunks` (`compress.rs`): Decompress concatenated chunks and return decoded bytes.
- `compress_stream` (`compress.rs`): Compress bytes from reader into writer using selected codec.
- `decompress_stream` (`compress.rs`): Decompress bytes from reader into writer using selected codec.
- `DataWriter::new` (`data_writer.rs`): Create empty writer and return value.
- `DataWriter::with_capacity` (`data_writer.rs`): Create writer with reserved capacity and return value.
- `DataWriter::tell` (`data_writer.rs`): Return current cursor position.
- `DataWriter::len` (`data_writer.rs`): Return current buffer length.
- `DataWriter::is_empty` (`data_writer.rs`): Return true when buffer is empty.
- `DataWriter::seek` (`data_writer.rs`): Move cursor to position and grow buffer when needed.
- `DataWriter::into_bytes` (`data_writer.rs`): Consume writer and return owned bytes.
- `DataWriter::as_bytes` (`data_writer.rs`): Return immutable bytes view.
- `DataWriter::write_u8` (`data_writer.rs`): Write one u8 value at cursor.
- `DataWriter::write_i8` (`data_writer.rs`): Write one i8 value at cursor.
- `DataWriter::write_u16_le` (`data_writer.rs`): Write u16 in little-endian order.
- `DataWriter::write_u16_be` (`data_writer.rs`): Write u16 in big-endian order.
- `DataWriter::write_i16_le` (`data_writer.rs`): Write i16 in little-endian order.
- `DataWriter::write_u32_le` (`data_writer.rs`): Write u32 in little-endian order.
- `DataWriter::write_i32_le` (`data_writer.rs`): Write i32 in little-endian order.
- `DataWriter::write_f32_le` (`data_writer.rs`): Write f32 in little-endian order.
- `DataWriter::write_f64_le` (`data_writer.rs`): Write f64 in little-endian order.
- `DataWriter::write_string` (`data_writer.rs`): Write length-prefixed UTF-8 string.
- `DataWriter::write_bytes` (`data_writer.rs`): Write raw bytes at cursor.
- `DataView::new` (`dataview.rs`): Create full-buffer view and return value.
- `DataView::new_slice` (`dataview.rs`): Create sub-slice view and return value or bounds error.
- `DataView::get_size` (`dataview.rs`): Return view size in bytes.
- `DataView::get_u8` (`dataview.rs`): Read u8 at index and return value or error.
- `DataView::get_i8` (`dataview.rs`): Read i8 at index and return value or error.
- `DataView::get_u16` (`dataview.rs`): Read little-endian u16 at index and return value or error.
- `DataView::get_i16` (`dataview.rs`): Read little-endian i16 at index and return value or error.
- `DataView::get_u32` (`dataview.rs`): Read little-endian u32 at index and return value or error.
- `DataView::get_i32` (`dataview.rs`): Read little-endian i32 at index and return value or error.
- `DataView::get_f32` (`dataview.rs`): Read little-endian f32 at index and return value or error.
- `DataView::get_f64` (`dataview.rs`): Read little-endian f64 at index and return value or error.
- `LuaDataView::new` (`dataview.rs`): Wrap DataView and return LuaDataView.
- `EncodeFormat::parse_str` (`encode.rs`): Parse format label and return encoding variant or error.
- `encode` (`encode.rs`): Encode bytes with selected format and return text.
- `decode` (`encode.rs`): Decode text with selected format and return bytes or error.
- `HashAlgorithm::parse_str` (`hash.rs`): Parse algorithm label and return hash variant or error.
- `hash` (`hash.rs`): Hash bytes with selected algorithm and return hex digest.
- `crc32` (`hash.rs`): Compute CRC32 checksum and return value as u64.
- `pack` (`pack.rs`): Pack values by format string and return ByteData or error.
- `unpack` (`pack.rs`): Unpack values by format string and return values with next offset.
- `get_packed_size` (`pack.rs`): Compute packed byte size for format and provided values.
- `RingBuffer::new` (`ring_buffer.rs`): Create ring buffer with capacity clamped to at least one.
- `RingBuffer::push` (`ring_buffer.rs`): Push value and return true when buffer was not full.
- `RingBuffer::pop` (`ring_buffer.rs`): Pop oldest value and return optional element.
- `RingBuffer::peek` (`ring_buffer.rs`): Return oldest element reference.
- `RingBuffer::peek_newest` (`ring_buffer.rs`): Return newest element reference.
- `RingBuffer::get` (`ring_buffer.rs`): Return element by logical index from oldest.
- `RingBuffer::capacity` (`ring_buffer.rs`): Return configured capacity.
- `RingBuffer::len` (`ring_buffer.rs`): Return current element count.
- `RingBuffer::is_empty` (`ring_buffer.rs`): Return true when element count is zero.
- `RingBuffer::is_full` (`ring_buffer.rs`): Return true when element count equals capacity.
- `RingBuffer::clear` (`ring_buffer.rs`): Clear all elements and reset indices.
- `RingBuffer::iter` (`ring_buffer.rs`): Iterate elements from oldest to newest.
- `RingBuffer::to_vec` (`ring_buffer.rs`): Clone elements into Vec from oldest to newest.
- `RingBuffer::to_refs` (`ring_buffer.rs`): Collect references into Vec from oldest to newest.
- `RingBuffer::collect_copy` (`ring_buffer.rs`): Copy elements into Vec from oldest to newest.

## Lua API Reference

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

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- No additional module-specific notes.
