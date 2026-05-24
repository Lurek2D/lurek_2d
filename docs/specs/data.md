# data

## TL;DR

- The `data` module is a comprehensive binary data toolkit situated in the Foundations tier of the engine.

## General Info

- Module group: `Foundations`
- Source path: `src/data/`
- Lua API path(s): `src/lua_api/data_api.rs`
- Primary Lua namespace: `lurek.data`
- Rust test path(s): tests/rust/unit/data_tests.rs; tests/rust/stress/data_stress_tests.rs; inline tests in src/data/byte_data.rs, src/data/encode.rs, src/data/hash.rs
- Lua test path(s): tests/lua/unit/test_data_core_unit.lua; tests/lua/stress/test_data_stress.lua; tests/lua/integration/test_data_filesystem.lua; tests/lua/integration/test_data_compute.lua; tests/lua/golden/test_data_golden.lua

## Summary

 It provides high-performance data manipulation utilities entirely decoupled from engine-specific state, making it highly portable and resilient. It offers a robust suite of tools for byte buffering, compression, cryptographic hashing, string encoding, and structured binary packing and unpacking operations, all of which are critical for tasks ranging from network protocols to save-game serialization.

At the center of the module is `ByteData`, an owned, resizable byte vector equipped with indexed read and write access for all primitive types (including integers and floating-point numbers) in both little-endian and big-endian formats. For zero-copy inspection of binary payloads, the `DataView` struct provides read-only typed access over shared byte slices, minimizing overhead when decoding large network packets or streaming assets. Complementing this is `DataWriter`, a sequential builder that accumulates serialized binary output using a movable cursor.

The module supports an extensive array of compression codecs—LZ4, Zstd, Deflate, and Gzip—accessible via the `CompressFormat` enum. These codecs are exposed through full-buffer, streaming, and chunked APIs. For integrity checks and cryptography, the `HashAlgorithm` enum gives access to industry-standard hashes such as MD5, SHA-1, SHA-256, SHA-512, CRC32, xxHash, and BLAKE3. The `EncodeFormat` helpers seamlessly handle conversion of binary payloads to and from Base64, Hex, and URL-safe text formats.

A major feature of the module is its `pack` and `unpack` functions, which utilize Python `struct`-style format strings. These utilities translate between dynamically typed inputs (or Lua tables) and strongly typed binary layouts, natively handling endian switching, padding, and both length-prefixed and null-terminated strings. Additionally, the `RingBuffer` type provides a fixed-capacity circular buffer with oldest-overwrite FIFO semantics, ideal for streaming data pipelines or rolling logs. The entire toolset is deeply integrated with the Lua runtime through the `lurek.data.*` namespace, allowing script developers to efficiently process arbitrary binary data.

## Source Documentation

### `bin_pack.rs`
- Token-based binary packing and unpacking using whitespace-separated format strings
- Endian-aware serialization of integers, floats, booleans, strings, and raw bytes
- Coercion helpers that convert between BinValue variants at write time
- Length-prefixed and null-terminated string support for wire protocols
- Padding tokens for alignment and fixed-layout binary structures
- Bounds-checked reads with descriptive underflow error messages
- Static size measurement for formats without variable-width tokens
- ByteData output for zero-copy integration with the data module pipeline

### `byte_data.rs`
- Owned mutable byte buffer with indexed read and write access
- UTF-8 string encoding and lossy decoding from raw bytes
- Immutable and mutable slice views for zero-copy downstream use

### `compress.rs`
- Multi-codec compression and decompression (deflate, gzip, zlib, lz4)
- Full-buffer and streaming APIs for both single slices and chunk lists
- Configurable compression level clamped to valid range (0-9)
- ChunkReader adapter that flattens multiple borrowed slices into one Read stream
- Consistent error wrapping with codec-specific context messages

### `data_writer.rs`
- Sequential binary writer with a movable cursor over a growable byte buffer
- Little-endian and big-endian integer, float, and string write methods
- Seek support with automatic zero-fill when moving past buffer end

### `dataview.rs`
- Read-only typed accessor over a shared Arc byte buffer
- Bounds-checked scalar reads for u8, i8, u16, i16, u32, i32, f32, f64
- Sub-slice views with validated offset and size
- LuaDataView wrapper for Lua-facing ownership patterns

### `encode.rs`
- Base64 and hexadecimal encoding and decoding for opaque byte payloads
- Format selection via enum variant parsed from user-facing labels
- Consistent error wrapping for malformed input

### `hash.rs`
- Cryptographic hash digest computation (MD5, SHA-1, SHA-256, SHA-512)
- CRC32 checksum for fast integrity checks
- Hex-encoded string output for all digest algorithms

### `mod.rs`
- Binary packing, unpacking, and struct-style format-string serialization
- Owned byte buffers, shared data views, and sequential writers
- Compression codecs (deflate, gzip, zlib, lz4) with stream and chunk APIs
- Encoding helpers (base64, hex) and hash digests (MD5, SHA, CRC32)
- Fixed-capacity ring buffer with overwrite-on-full FIFO semantics

### `pack.rs`
- Python struct-style format-string packing and unpacking
- Single-character format tokens for integers, floats, strings, and padding
- Endian switching via '<' (little) and '>' (big) prefix characters
- Length-prefixed ('s') and null-terminated ('z') string support
- Coercion helpers that widen numeric PackValue variants at write time
- Bounds-checked reads with per-token underflow error messages
- Static and dynamic packed-size calculation for buffer pre-allocation
- ByteData output for integration with the data module pipeline

### `ring_buffer.rs`
- Fixed-capacity circular buffer with oldest-overwrite FIFO semantics
- Push, pop, peek, and index-based access with O(1) operations
- Iteration and collection helpers from oldest to newest element
- Copy-optimized collection for `Clone + Copy` element types

## Types

- `BinValue` (`enum`, `bin_pack.rs`): Tagged value enum used by the named-token pack format. It is the bridge between dynamically typed inputs and strongly typed binary writes and reads.
- `ByteData` (`struct`, `byte_data.rs`): Primary owned byte buffer for Lua and Rust interop. It is the mutable container that other helpers serialize into or read from.
- `CompressFormat` (`enum`, `compress.rs`): Supported compression backends for whole-buffer, stream, and chunked compression/decompression. It keeps format parsing and dispatch explicit rather than stringly typed deep in the implementation.
- `DataWriter` (`struct`, `data_writer.rs`): A growable byte buffer with a write cursor.
- `DataView` (`struct`, `dataview.rs`): Read-only window over shared bytes with typed accessors. It exists for cheap inspection of binary payloads without copying or mutating them.
- `LuaDataView` (`struct`, `dataview.rs`): Lua-facing wrapper over `DataView`. Keeping it separate lets the domain type stay free of Lua-specific method registration.
- `EncodeFormat` (`enum`, `encode.rs`): Supported binary-to-text encoding modes. It is the small dispatch enum behind the base64 and hex helpers.
- `HashAlgorithm` (`enum`, `hash.rs`): Supported digest algorithms for byte hashing. It centralizes algorithm parsing so the Lua API and Rust callers use the same accepted names.
- `PackValue` (`enum`, `pack.rs`): Tagged value enum used by the LÖVE-compatible pack format. It preserves the compatibility surface independently from the native `BinValue` format.
- `RingBuffer` (`struct`, `ring_buffer.rs`): A fixed-capacity circular ring buffer.

## Functions

- `write` (`bin_pack.rs`): Write values into a binary buffer according to a Lurek2D format string.
- `read` (`bin_pack.rs`): Read values from a binary buffer according to a Lurek2D format string.
- `measure_size` (`bin_pack.rs`): Compute the total byte size that `write` would produce for the given format string.
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
- `compress` (`compress.rs`): Compress data using the specified format and compression level (0-9).
- `decompress` (`compress.rs`): Decompress data using the specified format.
- `compress_chunks` (`compress.rs`): Compresses ordered byte chunks without pre-concatenating input.
- `decompress_chunks` (`compress.rs`): Decompresses ordered compressed chunks back into a contiguous byte vector.
- `compress_stream` (`compress.rs`): Compresses data from any `Read` source into any `Write` sink.
- `decompress_stream` (`compress.rs`): Decompresses data from any `Read` source into any `Write` sink.
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
- `encode` (`encode.rs`): Encode bytes into a string using the specified format.
- `decode` (`encode.rs`): Decode a string back into bytes using the specified format.
- `HashAlgorithm::parse_str` (`hash.rs`): Parse algorithm label and return hash variant or error.
- `hash` (`hash.rs`): Compute the hash of data using the specified algorithm, returned as a hex string.
- `crc32` (`hash.rs`): Compute the CRC-32 checksum of `data`, returned as a `u64` in the range `[0, 2³²)`.
- `pack` (`pack.rs`): Packs values according to a format string into a `ByteData` buffer.
- `unpack` (`pack.rs`): Unpacks values from a byte buffer according to a format string.
- `get_packed_size` (`pack.rs`): Computes the total byte size that `pack` would produce for the given format and values.
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

- Binding path(s): `src/lua_api/data_api.rs`
- Namespace: `lurek.data`

### Module Functions
- `lurek.data.pack`: Packs Lua values into a binary string using a format string.
- `lurek.data.unpack`: Unpacks values from a binary string using a format string.
- `lurek.data.getPackedSize`: Computes the packed byte size for values and a format string.
- `lurek.data.compress`: Compresses a binary string using a named compression format.
- `lurek.data.decompress`: Decompresses a binary string using a named compression format.
- `lurek.data.compressChunks`: Compresses a string or table of strings as a chunked byte stream.
- `lurek.data.decompressChunks`: Decompresses a string or table of strings as a chunked byte stream.
- `lurek.data.encode`: Encodes a binary string using a named text encoding format.
- `lurek.data.decode`: Decodes a string using a named text encoding format.
- `lurek.data.hash`: Hashes a binary string with a named algorithm.
- `lurek.data.crc32`: Computes CRC32 for a binary string.
- `lurek.data.newByteData`: Creates ByteData from a size or string.
- `lurek.data.newDataView`: Creates a DataView over a binary string slice.
- `lurek.data.write`: Writes binary values into a byte string using a format string.
- `lurek.data.read`: Reads binary values from a byte string using a format string.
- `lurek.data.size`: Measures fixed byte size for a binary format string.
- `lurek.data.parseToml`: Parses TOML text into Lua tables and scalar values.
- `lurek.data.encodeToml`: Encodes a Lua table into a TOML document string.
- `lurek.data.newRingBuffer`: Creates a fixed-capacity ring buffer for Lua values.
- `lurek.data.toMsgPack`: Encodes a Lua value into the current structured binary interchange payload.
- `lurek.data.fromMsgPack`: Decodes a structured binary interchange payload back into Lua values.
- `lurek.data.newWriter`: Creates an empty binary data writer.

### `LByteData` Methods
- `LByteData:getSize`: Returns the byte buffer length in bytes.
- `LByteData:getString`: Returns the byte buffer as a string.
- `LByteData:getByte`: Reads one byte at a zero-based offset.
- `LByteData:setByte`: Writes one byte at a zero-based offset inside the buffer.
- `LByteData:clone`: Returns a deep copy of the entire byte buffer.
- `LByteData:setBit`: Sets or clears one bit inside a byte at the given offset.
- `LByteData:getBit`: Reads one bit inside a byte at the given offsets.
- `LByteData:readBits`: Reads up to 32 bits starting at a byte and bit offset.
- `LByteData:type`: Returns the type name of this object for runtime type-checking.
- `LByteData:typeOf`: Checks whether this object matches the given type name.

### `LDataView` Methods
- `LDataView:getUInt8`: Reads an unsigned 8-bit integer at a byte offset.
- `LDataView:getInt8`: Reads a signed 8-bit integer at a byte offset.
- `LDataView:getInt16`: Reads a signed 16-bit integer at a byte offset.
- `LDataView:getUInt16`: Reads an unsigned 16-bit integer at a byte offset.
- `LDataView:getInt32`: Reads a signed 32-bit integer at a byte offset.
- `LDataView:getUInt32`: Reads an unsigned 32-bit integer at a byte offset.
- `LDataView:getFloat`: Reads a 32-bit float at a byte offset.
- `LDataView:getDouble`: Reads a 64-bit float at a byte offset.
- `LDataView:getSize`: Returns this data view size in bytes.
- `LDataView:type`: Returns the Lua-visible type name for this data view handle.
- `LDataView:typeOf`: Returns whether this data view handle matches a supported type name.

### `LDataWriter` Methods
- `LDataWriter:writeU8`: Appends an unsigned 8-bit integer to the writer buffer.
- `LDataWriter:writeI8`: Appends a signed 8-bit integer to the writer buffer.
- `LDataWriter:writeU16LE`: Appends an unsigned 16-bit integer in little-endian byte order.
- `LDataWriter:writeU16BE`: Appends an unsigned 16-bit integer in big-endian byte order.
- `LDataWriter:writeI16LE`: Appends a signed 16-bit integer in little-endian byte order.
- `LDataWriter:writeU32LE`: Appends an unsigned 32-bit integer in little-endian byte order.
- `LDataWriter:writeI32LE`: Appends a signed 32-bit integer in little-endian byte order.
- `LDataWriter:writeF32LE`: Appends a 32-bit float value in little-endian byte order.
- `LDataWriter:writeF64LE`: Appends a 64-bit float value in little-endian byte order.
- `LDataWriter:writeString`: Appends a UTF-8 encoded string to the writer buffer.
- `LDataWriter:writeBytes`: Appends raw bytes from a Lua string to the writer buffer.
- `LDataWriter:seek`: Moves the writer cursor to a specific byte position.
- `LDataWriter:tell`: Returns the writer cursor position.
- `LDataWriter:len`: Returns the current length of the writer buffer.
- `LDataWriter:toBytes`: Returns the writer buffer as a binary string.
- `LDataWriter:type`: Returns the Lua-visible type name for this data writer handle.
- `LDataWriter:typeOf`: Returns whether this data writer handle matches a supported type name.

### `LRingBuffer` Methods
- `LRingBuffer:push`: Pushes a value into the ring buffer and evicts the oldest value when full.
- `LRingBuffer:pop`: Removes and returns the oldest stored value from the ring buffer.
- `LRingBuffer:peek`: Returns the oldest stored value without removing it from the ring buffer.
- `LRingBuffer:peekNewest`: Returns the newest stored value without removing it from the ring buffer.
- `LRingBuffer:len`: Returns the number of values currently stored.
- `LRingBuffer:capacity`: Returns the maximum capacity of the ring buffer.
- `LRingBuffer:isEmpty`: Returns whether the ring buffer has no values.
- `LRingBuffer:isFull`: Returns whether the ring buffer is at capacity.
- `LRingBuffer:clear`: Removes every stored value and releases their registry keys.
- `LRingBuffer:toTable`: Returns stored values in oldest-to-newest order.
- `LRingBuffer:type`: Returns the Lua-visible type name for this ring buffer handle.
- `LRingBuffer:typeOf`: Returns whether this ring buffer handle matches a supported type name.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- Keep this module reference synchronized with `src/data/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
