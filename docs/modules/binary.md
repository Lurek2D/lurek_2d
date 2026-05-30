# Binary

## Summary

The `binary` module provides byte-level data utilities for serialization, packing, compression, encoding, hashing, and bounded buffering. It is a foundational data layer intended for protocol payloads, save blobs, and binary interchange, independent from renderer or gameplay concerns.

The module is split by responsibility: `byte_data` and `dataview` handle owned/shared byte access, `data_writer` handles sequential writes, `pack` and `bin_pack` handle structured format-string style serialization, `compress` and `encode` provide transport helpers, and `hash` provides checksum/digest utilities. `ring` adds fixed-capacity FIFO behavior with overwrite semantics for streaming scenarios.

Design emphasis is predictable low-level behavior and reusable primitives rather than one monolithic serializer. Callers can compose the specific pieces they need, from quick encode/decode helpers to full packed-structure workflows.

Because this module sits in foundations, its contracts must remain stable and explicit: byte order, bounds behavior, and transformation semantics should be documented and deterministic so higher layers can rely on it for cross-module interoperability.

Implementation detail and boundary guarantees for binary: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: bin_pack.rs: Token-based binary packing and unpacking using whitespace-separated format strings - Endian-aware serialization of integers, floats, booleans, strings, and raw bytes - Coercion helpers that convert between BinValue variants at write time - Length-prefixed and null-terminated stri; byte_data.rs: Owned mutable byte buffer with indexed read and write access - UTF-8 string encoding and lossy decoding from raw bytes - Immutable and mutable slice views for zero-copy downstream use; compress.rs: Multi-codec compression and decompression (deflate, gzip, zlib, lz4) - Full-buffer and streaming APIs for both single slices and chunk lists - Configurable compression level clamped to valid range (0-9) - ChunkReader adapter that flattens multiple borrowed slices into one Read st; data_writer.rs: Sequential binary writer with a movable cursor over a growable byte buffer - Little-endian and big-endian integer, float, and string write methods - Seek support with automatic zero-fill when moving past buffer end; dataview.rs: Read-only typed accessor over a shared Arc byte buffer - Bounds-checked scalar reads for u8, i8, u16, i16, u32, i32, f32, f64 - Sub-slice views with validated offset and size - LuaDataView wrapper for Lua-facing ownership patterns; encode.rs: Base64 and hexadecimal encoding and decoding for opaque byte payloads - Format selection via enum variant parsed from user-facing labels - Consistent error wrapping for malformed input; hash.rs: Cryptographic hash digest computation (MD5, SHA-1, SHA-256, SHA-512) - CRC32 checksum for fast integrity checks - Hex-encoded string output for all digest algorithms; mod.rs: Binary packing, unpacking, and struct-style format-string serialization - Owned byte buffers, shared data views, and sequential writers - Compression codecs (deflate, gzip, zlib, lz4) with stream and chunk APIs - Encoding helpers (base64, hex) and hash digests (MD5, SHA, CRC32) -; pack.rs: Python struct-style format-string packing and unpacking - Single-character format tokens for integers, floats, strings, and padding - Endian switching via '<' (little) and '>' (big) prefix characters - Length-prefixed ('s') and null-terminated ('z') string support - Coercion help; ring_buffer.rs: Fixed-capacity circular buffer with oldest-overwrite FIFO semantics - Push, pop, peek, and index-based access with O(1) operations - Iteration and collection helpers from oldest to newest element - Copy-optimized collection for Clone + Copy element types. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

## Spec File Descriptions

_Poniższe opisy plików pochodzą bezpośrednio ze specyfikacji modułu (`docs/specs/<module>.md`)._

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

## Functions

### `lurek.binary.compress`

Compresses a binary string using a named compression format.

```lua
lurek.binary.compress(format_str, raw_data, level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `format_str` | string | Compression format name. |
| `raw_data` | string | Raw binary data to compress. |
| `level?` | number | Optional compression level; defaults to 6. |

**Returns**

| Type | Description |
|------|-------------|
| string | Compressed binary byte string. |

**Example**

```lua
do
    local raw = string.rep("hello", 100)
    local compressed = lurek.binary.compress("deflate", raw)
    print("raw len = " .. #raw)
    print("compressed len = " .. #compressed)
end
```

---

### `lurek.binary.compressChunks`

Compresses a string or table of strings as a chunked byte stream.

```lua
lurek.binary.compressChunks(format_str, chunks, level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `format_str` | string | Compression format name. |
| `chunks` | any | Binary string or array table of binary strings. |
| `level?` | number | Optional compression level; defaults to 6. |

**Returns**

| Type | Description |
|------|-------------|
| string | Compressed binary byte string. |

**Example**

```lua
do
    local chunks = {"chunk1", "chunk2", "chunk3"}
    local compressed = lurek.binary.compressChunks("deflate", chunks)
    print("chunk count = " .. #chunks)
    print("chunks compressed len = " .. #compressed)
end
```

---

### `lurek.binary.crc32`

Computes CRC32 for a binary string.

```lua
lurek.binary.crc32(raw_data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `raw_data` | string | Raw binary data to checksum. |

**Returns**

| Type | Description |
|------|-------------|
| number | CRC32 checksum value. |

**Example**

```lua
do
    local crc = lurek.binary.crc32("test data")
    print("crc32 = " .. crc)
    print("crc32 type = " .. type(crc))
end
```

---

### `lurek.binary.decode`

Decodes a string using a named text encoding format.

```lua
lurek.binary.decode(format_str, encoded)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `format_str` | string | Encoding format name. |
| `encoded` | string | Encoded string to decode. |

**Returns**

| Type | Description |
|------|-------------|
| string | Decoded binary byte string. |

**Example**

```lua
do
    local encoded = lurek.binary.encode("base64", "Hello")
    local decoded = lurek.binary.decode("base64", encoded)
    print("decoded = " .. decoded)
end
```

---

### `lurek.binary.decompress`

Decompresses a binary string using a named compression format.

```lua
lurek.binary.decompress(format_str, compressed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `format_str` | string | Compression format name. |
| `compressed` | string | Compressed binary data. |

**Returns**

| Type | Description |
|------|-------------|
| string | Decompressed binary byte string. |

**Example**

```lua
do
    local raw = string.rep("world", 100)
    local compressed = lurek.binary.compress("deflate", raw)
    local restored = lurek.binary.decompress("deflate", compressed)
    print("restored len = " .. #restored)
    print("restored matches = " .. tostring(restored == raw))
end
```

---

### `lurek.binary.decompressChunks`

Decompresses a string or table of strings as a chunked byte stream.

```lua
lurek.binary.decompressChunks(format_str, chunks)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `format_str` | string | Compression format name. |
| `chunks` | any | Binary string or array table of binary strings. |

**Returns**

| Type | Description |
|------|-------------|
| string | Decompressed binary byte string. |

**Example**

```lua
do
    local chunks = {"aaaa", "bbbb", "cccc"}
    local compressed = lurek.binary.compressChunks("deflate", chunks)
    local restored = lurek.binary.decompressChunks("deflate", compressed)
    print("decompressed chunks len = " .. #restored)
    print("restored preview = " .. restored:sub(1, 8))
end
```

---

### `lurek.binary.encode`

Encodes a binary string using a named text encoding format.

```lua
lurek.binary.encode(format_str, raw_data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `format_str` | string | Encoding format name. |
| `raw_data` | string | Raw binary data to encode. |

**Returns**

| Type | Description |
|------|-------------|
| string | Encoded string. |

**Example**

```lua
do
    local encoded = lurek.binary.encode("base64", "Hello, World!")
    print("base64 = " .. encoded)
end
```

---

### `lurek.binary.encodeToml`

Encodes a Lua table into a TOML document string.

```lua
lurek.binary.encodeToml(tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tbl` | table | Lua table to encode as TOML. |

**Returns**

| Type | Description |
|------|-------------|
| string | TOML document text. |

**Example**

```lua
do
    local t = {title = "My Game", version = "1.0"}
    local text = lurek.binary.encodeToml(t)
    print("toml len = " .. #text)
    print("toml preview = " .. text:sub(1, 20))
end
```

---

### `lurek.binary.fromMsgPack`

Decodes a structured binary interchange payload back into Lua values.

```lua
lurek.binary.fromMsgPack(bytes)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bytes` | string | Encoded binary payload. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Decoded Lua value. |

**Example**

```lua
do
    local payload = {score = 100, name = "test"}
    local bytes = lurek.binary.toMsgPack(payload)
    local decoded = lurek.binary.fromMsgPack(bytes)
    print("decoded score = " .. decoded.score)
    print("decoded name = " .. decoded.name)
end
```

---

### `lurek.binary.getPackedSize`

Computes the packed byte size for values and a format string.

```lua
lurek.binary.getPackedSize(fmt, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fmt` | string | Binary pack format string. |
| — | — | @param ... any Values measured according to the format. |

**Returns**

| Type | Description |
|------|-------------|
| number | Packed byte size. |

**Example**

```lua
do
    local sz = lurek.binary.getPackedSize("BHI", 0, 0, 0)
    local packed = lurek.binary.pack("BHI", 0, 0, 0)
    print("packed size = " .. sz)
    print("matches packed len = " .. tostring(sz == #packed))
end
```

---

### `lurek.binary.hash`

Hashes a binary string with a named algorithm.

```lua
lurek.binary.hash(algo_str, raw_data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `algo_str` | string | Hash algorithm name. |
| `raw_data` | string | Raw binary data to hash. |

**Returns**

| Type | Description |
|------|-------------|
| string | Hash digest string. |

**Example**

```lua
do
    local digest = lurek.binary.hash("sha256", "secret data")
    print("sha256 = " .. digest)
    print("digest length = " .. #digest)
end
```

---

### `lurek.binary.newByteData`

Creates ByteData from a size or string.

```lua
lurek.binary.newByteData(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Integer size for zeroed bytes, or string used as initial bytes. |

**Returns**

| Type | Description |
|------|-------------|
| [LByteData](#lbytedata-handle) | New [LByteData](#lbytedata-handle) userdata. |

**Example**

```lua
do
    local bd = lurek.binary.newByteData(16)
    print("bytedata size = " .. bd:getSize())
    print("first byte = " .. bd:getByte(0))
end
```

---

### `lurek.binary.newDataView`

Creates a DataView over a binary string slice.

```lua
lurek.binary.newDataView(raw, offset, size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `raw` | string | Binary byte string backing the view. |
| `offset?` | number | Optional zero-based start offset; defaults to zero. |
| `size?` | number | Optional view size in bytes; defaults to the remaining bytes. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataView](#ldataview-handle) | New data view handle. |

**Example**

```lua
do
    local raw = lurek.binary.pack("<II", 42, 99)
    local view = lurek.binary.newDataView(raw)
    print("view size = " .. view:getSize())
    print("first value = " .. view:getUInt32(0))
end
```

---

### `lurek.binary.newRingBuffer`

Creates a fixed-capacity ring buffer for Lua values.

```lua
lurek.binary.newRingBuffer(capacity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `capacity` | number | Maximum value count; must be greater than zero. |

**Returns**

| Type | Description |
|------|-------------|
| [LRingBuffer](#lringbuffer-handle) | New ring buffer handle. |

**Example**

```lua
do
    local rb = lurek.binary.newRingBuffer(8)
    print("ring capacity = " .. rb:capacity())
    print("ring empty = " .. tostring(rb:isEmpty()))
end
```

---

### `lurek.binary.newWriter`

Creates an empty binary data writer.

```lua
lurek.binary.newWriter()
```

**Returns**

| Type | Description |
|------|-------------|
| [LDataWriter](#ldatawriter-handle) | New data writer handle. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    print("writer created = " .. tostring(w ~= nil))
    print("writer type = " .. w:type())
end
```

---

### `lurek.binary.pack`

Packs Lua values into a binary string using a format string.

```lua
lurek.binary.pack(fmt, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fmt` | string | Binary pack format string. |
| — | — | @param ... any Values to pack according to the format. |

**Returns**

| Type | Description |
|------|-------------|
| string | Packed binary byte string. |

**Example**

```lua
do
    local packed = lurek.binary.pack("BHI", 255, 1000, 123456)
    print("packed len = " .. #packed)
    print("first byte = " .. string.byte(packed, 1))
end
```

---

### `lurek.binary.parseToml`

Parses TOML text into Lua tables and scalar values.

```lua
lurek.binary.parseToml(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | TOML document text. |

**Returns**

| Type | Description |
|------|-------------|
| table | Lua representation of the TOML document. |

**Example**

```lua
do
    local toml_text = "[player]\nname = \"Hero\"\nlevel = 5"
    local t = lurek.binary.parseToml(toml_text)
    print("player name = " .. t.player.name)
    print("player level = " .. tostring(t.player.level))
end
```

---

### `lurek.binary.read`

Reads binary values from a byte string using a format string.

```lua
lurek.binary.read(fmt, raw, offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fmt` | string | Binary reader format string. |
| `raw` | string | Binary byte string to read. |
| `offset?` | number | Optional zero-based byte offset; defaults to zero. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Values read from the byte string. |

**Example**

```lua
do
    local bytes = lurek.binary.write("u32", 42)
    local val = lurek.binary.read("u32", bytes)
    print("read val = " .. val)
end
```

---

### `lurek.binary.size`

Measures fixed byte size for a binary format string.

```lua
lurek.binary.size(fmt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fmt` | string | Binary format string to measure. |

**Returns**

| Type | Description |
|------|-------------|
| number | Fixed byte size for the format. |

**Example**

```lua
do
    local sz = lurek.binary.size("u32")
    local bytes = lurek.binary.write("u32", 7)
    print("format size = " .. sz)
    print("matches write len = " .. tostring(sz == #bytes))
end
```

---

### `lurek.binary.toMsgPack`

Encodes a Lua value into the current structured binary interchange payload.

```lua
lurek.binary.toMsgPack(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Lua value to encode through the serial table converter. |

**Returns**

| Type | Description |
|------|-------------|
| string | Encoded binary payload. |

**Example**

```lua
do
    local payload = {score = 100, name = "test"}
    local bytes = lurek.binary.toMsgPack(payload)
    print("msgpack len = " .. #bytes)
    print("first byte = " .. string.byte(bytes, 1))
end
```

---

### `lurek.binary.unpack`

Unpacks values from a binary string using a format string.

```lua
lurek.binary.unpack(fmt, raw, offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fmt` | string | Binary unpack format string. |
| `raw` | string | Binary byte string to unpack. |
| `offset?` | number | Optional zero-based byte offset; defaults to zero. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Unpacked values followed by the next byte offset. |

**Example**

```lua
do
    local packed = lurek.binary.pack("BHI", 255, 1000, 123456)
    local b, h, i = lurek.binary.unpack("BHI", packed)
    print("unpacked: " .. b .. ", " .. h .. ", " .. i)
end
```

---

### `lurek.binary.write`

Writes binary values into a byte string using a format string.

```lua
lurek.binary.write(fmt, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fmt` | string | Binary writer format string. |
| — | — | @param ... any Values to write according to the format. |

**Returns**

| Type | Description |
|------|-------------|
| string | Binary byte string containing written values. |

**Example**

```lua
do
    local bytes = lurek.binary.write("u32", 42)
    print("write len = " .. #bytes)
    print("read back = " .. lurek.binary.read("u32", bytes))
end
```

---

## Module Fields

*No module-level fields documented.*

## Types

- [LByteData Handle](#lbytedata-handle)
- [LDataView Handle](#ldataview-handle)
- [LDataWriter Handle](#ldatawriter-handle)
- [LRingBuffer Handle](#lringbuffer-handle)

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## LByteData Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LByteData:clone`

Returns a deep copy of the entire byte buffer.

```lua
LByteData:clone()
```

**Returns**

| Type | Description |
|------|-------------|
| [LByteData](#lbytedata-handle) | New [LByteData](#lbytedata-handle) userdata containing copied bytes. |

**Example**

```lua
do
    local bd = lurek.binary.newByteData("test")
    local copy = bd:clone()
    copy:setByte(0, 88)
    print("original[0] = " .. bd:getByte(0) .. " copy[0] = " .. copy:getByte(0))
end
```

---

#### `LByteData:getBit`

Reads one bit inside a byte at the given offsets.

```lua
LByteData:getBit(byte_offset, bit_offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `byte_offset` | number | Zero-based byte offset. |
| `bit_offset` | number | Bit offset from 0 to 7 inside the byte. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the bit is set. |

**Example**

```lua
do
    local bd = lurek.binary.newByteData(1)
    bd:setByte(0, 0x80)
    print("bit7 = " .. tostring(bd:getBit(0, 7)))
    print("bit0 = " .. tostring(bd:getBit(0, 0)))
end
```

---

#### `LByteData:getByte`

Reads one byte at a zero-based offset.

```lua
LByteData:getByte(offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | number | Zero-based byte offset. |

**Returns**

| Type | Description |
|------|-------------|
| number | Byte value from 0 to 255. |

**Example**

```lua
do
    local bd = lurek.binary.newByteData("ABC")
    print("byte[0] = " .. bd:getByte(0))
end
```

---

#### `LByteData:getSize`

Returns the byte buffer length in bytes.

```lua
LByteData:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Buffer length in bytes. |

**Example**

```lua
do
    local bd = lurek.binary.newByteData(32)
    print("size = " .. bd:getSize())
end
```

---

#### `LByteData:getString`

Returns the byte buffer as a string.

```lua
LByteData:getString()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Byte buffer contents as a Lua string. |

**Example**

```lua
do
    local bd = lurek.binary.newByteData("Hello")
    print("str = " .. bd:getString())
    print("size = " .. bd:getSize())
end
```

---

#### `LByteData:readBits`

Reads up to 32 bits starting at a byte and bit offset.

```lua
LByteData:readBits(byte_offset, bit_offset, count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `byte_offset` | number | Zero-based byte offset. |
| `bit_offset` | number | Bit offset from 0 to 7 inside the starting byte. |
| `count` | number | Number of bits to read, from 1 to 32. |

**Returns**

| Type | Description |
|------|-------------|
| number | Unsigned integer containing the requested bits. |

**Example**

```lua
do
    local bd = lurek.binary.newByteData(2)
    bd:setByte(0, 0xFF)
    bd:setByte(1, 0x0F)
    local val = bd:readBits(0, 0, 12)
    print("12 bits = " .. val)
end
```

---

#### `LByteData:setBit`

Sets or clears one bit inside a byte at the given offset.

```lua
LByteData:setBit(byte_offset, bit_offset, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `byte_offset` | number | Zero-based byte offset. |
| `bit_offset` | number | Bit offset from 0 to 7 inside the byte. |
| `value` | boolean | True to set the bit, false to clear it. |

**Example**

```lua
do
    local bd = lurek.binary.newByteData(1)
    bd:setBit(0, 0, true)
    bd:setBit(0, 7, true)
    print("byte = " .. bd:getByte(0))
    print("bit 7 = " .. tostring(bd:getBit(0, 7)))
end
```

---

#### `LByteData:setByte`

Writes one byte at a zero-based offset inside the buffer.

```lua
LByteData:setByte(offset, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | number | Zero-based byte offset. |
| `value` | number | Byte value from 0 to 255. |

**Example**

```lua
do
    local bd = lurek.binary.newByteData(4)
    bd:setByte(0, 255)
    print("byte[0] = " .. bd:getByte(0))
end
```

---

#### `LByteData:type`

Returns the type name of this object for runtime type-checking.

```lua
LByteData:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always returns "[LByteData](#lbytedata-handle)". |

**Example**

```lua
do
    local bd = lurek.binary.newByteData(1)
    print("type = " .. bd:type())
end
```

---

#### `LByteData:typeOf`

Checks whether this object matches the given type name.

```lua
LByteData:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check (e.g. "[LByteData](#lbytedata-handle)" or "LObject"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if this object matches the given type. |

**Example**

```lua
do
    local bd = lurek.binary.newByteData(1)
    print("is LByteData = " .. tostring(bd:typeOf("LByteData")))
end
```

---

## LDataView Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LDataView:getDouble`

Reads a 64-bit float at a byte offset.

```lua
LDataView:getDouble(offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | number | Zero-based byte offset inside the view. |

**Returns**

| Type | Description |
|------|-------------|
| number | 64-bit float value. |

**Example**

```lua
do
    local raw = lurek.binary.pack("d", 2.718281828)
    local view = lurek.binary.newDataView(raw)
    print("f64[0] = " .. view:getDouble(0))
end
```

---

#### `LDataView:getFloat`

Reads a 32-bit float at a byte offset.

```lua
LDataView:getFloat(offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | number | Zero-based byte offset inside the view. |

**Returns**

| Type | Description |
|------|-------------|
| number | 32-bit float value converted to Lua number. |

**Example**

```lua
do
    local raw = lurek.binary.pack("f", 3.14)
    local view = lurek.binary.newDataView(raw)
    print("f32[0] = " .. view:getFloat(0))
    print("view size = " .. view:getSize())
end
```

---

#### `LDataView:getInt16`

Reads a signed 16-bit integer at a byte offset.

```lua
LDataView:getInt16(offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | number | Zero-based byte offset inside the view. |

**Returns**

| Type | Description |
|------|-------------|
| number | Signed 16-bit value. |

**Example**

```lua
do
    local raw = lurek.binary.pack("h", -1000)
    local view = lurek.binary.newDataView(raw)
    print("i16[0] = " .. view:getInt16(0))
end
```

---

#### `LDataView:getInt32`

Reads a signed 32-bit integer at a byte offset.

```lua
LDataView:getInt32(offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | number | Zero-based byte offset inside the view. |

**Returns**

| Type | Description |
|------|-------------|
| number | Signed 32-bit value. |

**Example**

```lua
do
    local raw = lurek.binary.pack("<i", -100000)
    local view = lurek.binary.newDataView(raw)
    print("i32[0] = " .. view:getInt32(0))
end
```

---

#### `LDataView:getInt8`

Reads a signed 8-bit integer at a byte offset.

```lua
LDataView:getInt8(offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | number | Zero-based byte offset inside the view. |

**Returns**

| Type | Description |
|------|-------------|
| number | Signed 8-bit value. |

**Example**

```lua
do
    local raw = lurek.binary.pack("b", -42)
    local view = lurek.binary.newDataView(raw)
    print("i8[0] = " .. view:getInt8(0))
end
```

---

#### `LDataView:getSize`

Returns this data view size in bytes.

```lua
LDataView:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | View size in bytes. |

**Example**

```lua
do
    local raw = lurek.binary.pack("<III", 1, 2, 3)
    local view = lurek.binary.newDataView(raw)
    print("view size = " .. view:getSize())
    print("last value = " .. view:getUInt32(8))
end
```

---

#### `LDataView:getUInt16`

Reads an unsigned 16-bit integer at a byte offset.

```lua
LDataView:getUInt16(offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | number | Zero-based byte offset inside the view. |

**Returns**

| Type | Description |
|------|-------------|
| number | Unsigned 16-bit value. |

**Example**

```lua
do
    local raw = lurek.binary.pack("H", 65000)
    local view = lurek.binary.newDataView(raw)
    print("u16[0] = " .. view:getUInt16(0))
end
```

---

#### `LDataView:getUInt32`

Reads an unsigned 32-bit integer at a byte offset.

```lua
LDataView:getUInt32(offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | number | Zero-based byte offset inside the view. |

**Returns**

| Type | Description |
|------|-------------|
| number | Unsigned 32-bit value. |

**Example**

```lua
do
    local raw = lurek.binary.pack("<I", 3000000)
    local view = lurek.binary.newDataView(raw)
    print("u32[0] = " .. view:getUInt32(0))
end
```

---

#### `LDataView:getUInt8`

Reads an unsigned 8-bit integer at a byte offset.

```lua
LDataView:getUInt8(offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | number | Zero-based byte offset inside the view. |

**Returns**

| Type | Description |
|------|-------------|
| number | Unsigned 8-bit value. |

**Example**

```lua
do
    local raw = lurek.binary.pack("BBBB", 10, 20, 30, 40)
    local view = lurek.binary.newDataView(raw)
    print("u8[0] = " .. view:getUInt8(0))
    print("u8[1] = " .. view:getUInt8(1))
end
```

---

#### `LDataView:type`

Returns the Lua-visible type name for this data view handle.

```lua
LDataView:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LDataView](#ldataview-handle)`. |

**Example**

```lua
do
    local view = lurek.binary.newDataView("abc")
    print("type = " .. view:type())
end
```

---

#### `LDataView:typeOf`

Returns whether this data view handle matches a supported type name.

```lua
LDataView:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LDataView](#ldataview-handle)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local view = lurek.binary.newDataView("abc")
    print("is LDataView = " .. tostring(view:typeOf("LDataView")))
end
```

---

## LDataWriter Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LDataWriter:len`

Returns the current length of the writer buffer.

```lua
LDataWriter:len()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Buffer length in bytes. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeU16LE(100)
    w:writeU16LE(200)
    print("writer len = " .. w:len())
end
```

---

#### `LDataWriter:seek`

Moves the writer cursor to a specific byte position.

```lua
LDataWriter:seek(pos)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pos` | number | New cursor position in bytes. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeU32LE(0)
    w:seek(0)
    w:writeU32LE(42)
    print("seek then overwrite, len = " .. w:len())
    print("cursor = " .. w:tell())
end
```

---

#### `LDataWriter:tell`

Returns the writer cursor position.

```lua
LDataWriter:tell()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current cursor position in bytes. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeU8(1)
    w:writeU8(2)
    print("cursor at = " .. w:tell())
end
```

---

#### `LDataWriter:toBytes`

Returns the writer buffer as a binary string.

```lua
LDataWriter:toBytes()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Binary byte string containing writer contents. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeU8(65)
    w:writeU8(66)
    local bytes = w:toBytes()
    print("bytes len = " .. #bytes)
    print("bytes text = " .. bytes)
end
```

---

#### `LDataWriter:type`

Returns the Lua-visible type name for this data writer handle.

```lua
LDataWriter:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LDataWriter](#ldatawriter-handle)`. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    print("type = " .. w:type())
end
```

---

#### `LDataWriter:typeOf`

Returns whether this data writer handle matches a supported type name.

```lua
LDataWriter:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LDataWriter](#ldatawriter-handle)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    print("is LDataWriter = " .. tostring(w:typeOf("LDataWriter")))
end
```

---

#### `LDataWriter:writeBytes`

Appends raw bytes from a Lua string to the writer buffer.

```lua
LDataWriter:writeBytes(s)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `s` | string | Raw byte string to write. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeBytes("\x00\x01\x02\x03")
    print("after writeBytes len = " .. w:len())
end
```

---

#### `LDataWriter:writeF32LE`

Appends a 32-bit float value in little-endian byte order.

```lua
LDataWriter:writeF32LE(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Value to write. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeF32LE(3.14)
    print("after writeF32LE len = " .. w:len())
end
```

---

#### `LDataWriter:writeF64LE`

Appends a 64-bit float value in little-endian byte order.

```lua
LDataWriter:writeF64LE(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Value to write. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeF64LE(2.718281828)
    print("after writeF64LE len = " .. w:len())
end
```

---

#### `LDataWriter:writeI16LE`

Appends a signed 16-bit integer in little-endian byte order.

```lua
LDataWriter:writeI16LE(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Value to write. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeI16LE(-500)
    print("after writeI16LE len = " .. w:len())
end
```

---

#### `LDataWriter:writeI32LE`

Appends a signed 32-bit integer in little-endian byte order.

```lua
LDataWriter:writeI32LE(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Value to write. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeI32LE(-99999)
    print("after writeI32LE len = " .. w:len())
end
```

---

#### `LDataWriter:writeI8`

Appends a signed 8-bit integer to the writer buffer.

```lua
LDataWriter:writeI8(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Value to write. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeI8(-128)
    print("after writeI8 len = " .. w:len())
end
```

---

#### `LDataWriter:writeString`

Appends a UTF-8 encoded string to the writer buffer.

```lua
LDataWriter:writeString(s)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `s` | string | String contents to write. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeString("Hello!")
    print("after writeString len = " .. w:len())
end
```

---

#### `LDataWriter:writeU16BE`

Appends an unsigned 16-bit integer in big-endian byte order.

```lua
LDataWriter:writeU16BE(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Value to write. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeU16BE(1000)
    print("after writeU16BE len = " .. w:len())
end
```

---

#### `LDataWriter:writeU16LE`

Appends an unsigned 16-bit integer in little-endian byte order.

```lua
LDataWriter:writeU16LE(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Value to write. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeU16LE(1000)
    print("after writeU16LE len = " .. w:len())
end
```

---

#### `LDataWriter:writeU32LE`

Appends an unsigned 32-bit integer in little-endian byte order.

```lua
LDataWriter:writeU32LE(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Value to write. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeU32LE(123456)
    print("after writeU32LE len = " .. w:len())
end
```

---

#### `LDataWriter:writeU8`

Appends an unsigned 8-bit integer to the writer buffer.

```lua
LDataWriter:writeU8(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Value to write. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeU8(255)
    print("after writeU8 len = " .. w:len())
    print("first byte = " .. string.byte(w:toBytes(), 1))
end
```

---

## LRingBuffer Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LRingBuffer:capacity`

Returns the maximum capacity of the ring buffer.

```lua
LRingBuffer:capacity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Maximum number of stored values. |

**Example**

```lua
do
    local rb = lurek.binary.newRingBuffer(5)
    print("capacity = " .. rb:capacity())
end
```

---

#### `LRingBuffer:clear`

Removes every stored value and releases their registry keys.

```lua
LRingBuffer:clear()
```

**Example**

```lua
do
    local rb = lurek.binary.newRingBuffer(4)
    rb:push(1)
    rb:push(2)
    rb:clear()
    print("after clear len = " .. rb:len())
end
```

---

#### `LRingBuffer:isEmpty`

Returns whether the ring buffer has no values.

```lua
LRingBuffer:isEmpty()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the buffer is empty. |

**Example**

```lua
do
    local rb = lurek.binary.newRingBuffer(4)
    print("empty = " .. tostring(rb:isEmpty()))
    rb:push("value")
    print("empty after push = " .. tostring(rb:isEmpty()))
end
```

---

#### `LRingBuffer:isFull`

Returns whether the ring buffer is at capacity.

```lua
LRingBuffer:isFull()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the buffer length is at least its capacity. |

**Example**

```lua
do
    local rb = lurek.binary.newRingBuffer(2)
    rb:push("a")
    rb:push("b")
    print("full = " .. tostring(rb:isFull()))
    print("len = " .. tostring(rb:len()))
end
```

---

#### `LRingBuffer:len`

Returns the number of values currently stored.

```lua
LRingBuffer:len()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current buffer length. |

**Example**

```lua
do
    local rb = lurek.binary.newRingBuffer(10)
    rb:push(1)
    rb:push(2)
    print("len = " .. rb:len())
    print("capacity = " .. rb:capacity())
end
```

---

#### `LRingBuffer:peek`

Returns the oldest stored value without removing it from the ring buffer.

```lua
LRingBuffer:peek()
```

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Oldest stored value, or nil when the buffer is empty. |

**Example**

```lua
do
    local rb = lurek.binary.newRingBuffer(4)
    rb:push("first")
    rb:push("second")
    print("peek = " .. rb:peek())
end
```

---

#### `LRingBuffer:peekNewest`

Returns the newest stored value without removing it from the ring buffer.

```lua
LRingBuffer:peekNewest()
```

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Newest stored value, or nil when the buffer is empty. |

**Example**

```lua
do
    local rb = lurek.binary.newRingBuffer(4)
    rb:push("old")
    rb:push("new")
    print("newest = " .. rb:peekNewest())
end
```

---

#### `LRingBuffer:pop`

Removes and returns the oldest stored value from the ring buffer.

```lua
LRingBuffer:pop()
```

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Oldest stored value, or nil when the buffer is empty. |

**Example**

```lua
do
    local rb = lurek.binary.newRingBuffer(4)
    rb:push(10)
    rb:push(20)
    local oldest = rb:pop()
    print("popped = " .. oldest)
end
```

---

#### `LRingBuffer:push`

Pushes a value into the ring buffer and evicts the oldest value when full.

```lua
LRingBuffer:push(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Lua value to store in the buffer. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the push evicted an older value. |

**Example**

```lua
do
    local rb = lurek.binary.newRingBuffer(3)
    rb:push("a")
    rb:push("b")
    local evicted = rb:push("d")
    print("evicted = " .. tostring(evicted))
    print("newest = " .. tostring(rb:peekNewest()))
end
```

---

#### `LRingBuffer:toTable`

Returns stored values in oldest-to-newest order.

```lua
LRingBuffer:toTable()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of stored values. |

**Example**

```lua
do
    local rb = lurek.binary.newRingBuffer(4)
    rb:push(10)
    rb:push(20)
    local t = rb:toTable()
    print("table len = " .. #t)
    print("first item = " .. tostring(t[1]))
end
```

---

#### `LRingBuffer:type`

Returns the Lua-visible type name for this ring buffer handle.

```lua
LRingBuffer:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LRingBuffer](#lringbuffer-handle)`. |

**Example**

```lua
do
    local rb = lurek.binary.newRingBuffer(4)
    print("type = " .. rb:type())
end
```

---

#### `LRingBuffer:typeOf`

Returns whether this ring buffer handle matches a supported type name.

```lua
LRingBuffer:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LRingBuffer](#lringbuffer-handle)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local rb = lurek.binary.newRingBuffer(4)
    print("is LRingBuffer = " .. tostring(rb:typeOf("LRingBuffer")))
end
```

---
