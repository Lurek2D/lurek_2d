# Binary

- The `binary` module is a comprehensive binary data toolkit situated in the Foundations tier of the engine.

It provides high-performance data manipulation utilities entirely decoupled from engine-specific state, making it highly portable and resilient. It offers a robust suite of tools for byte buffering, compression, cryptographic hashing, string encoding, and structured binary packing and unpacking operations, all of which are critical for tasks ranging from network protocols to save-game serialization.

At the center of the module is `ByteData`, an owned, resizable byte vector equipped with indexed read and write access for all primitive types (including integers and floating-point numbers) in both little-endian and big-endian formats. For zero-copy inspection of binary payloads, the `DataView` struct provides read-only typed access over shared byte slices, minimizing overhead when decoding large network packets or streaming assets. Complementing this is `DataWriter`, a sequential builder that accumulates serialized binary output using a movable cursor.

The module supports an extensive array of compression codecs—LZ4, Zstd, Deflate, and Gzip—accessible via the `CompressFormat` enum. These codecs are exposed through full-buffer, streaming, and chunked APIs. For integrity checks and cryptography, the `HashAlgorithm` enum gives access to industry-standard hashes such as MD5, SHA-1, SHA-256, SHA-512, CRC32, xxHash, and BLAKE3. The `EncodeFormat` helpers seamlessly handle conversion of binary payloads to and from Base64, Hex, and URL-safe text formats.

A major feature of the module is its `pack` and `unpack` functions, which utilize Python `struct`-style format strings. These utilities translate between dynamically typed inputs (or Lua tables) and strongly typed binary layouts, natively handling endian switching, padding, and both length-prefixed and null-terminated strings. Additionally, the `RingBuffer` type provides a fixed-capacity circular buffer with oldest-overwrite FIFO semantics, ideal for streaming data pipelines or rolling logs. The entire toolset is deeply integrated with the Lua runtime through the `lurek.binary.*` namespace, allowing script developers to efficiently process arbitrary binary data.

## Functions

### `lurek.binary.compress`

Compresses a binary string using a named compression format.

```lua
-- signature
lurek.binary.compress(format_str, raw_data, level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `format_str` | `string` | Compression format name. |
| `raw_data` | `string` | Raw binary data to compress. |
| `level?` | `number` | Optional compression level; defaults to 6. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Compressed binary byte string. |

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
-- signature
lurek.binary.compressChunks(format_str, chunks, level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `format_str` | `string` | Compression format name. |
| `chunks` | `any` | Binary string or array table of binary strings. |
| `level?` | `number` | Optional compression level; defaults to 6. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Compressed binary byte string. |

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
-- signature
lurek.binary.crc32(raw_data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `raw_data` | `string` | Raw binary data to checksum. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | CRC32 checksum value. |

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
-- signature
lurek.binary.decode(format_str, encoded)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `format_str` | `string` | Encoding format name. |
| `encoded` | `string` | Encoded string to decode. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Decoded binary byte string. |

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
-- signature
lurek.binary.decompress(format_str, compressed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `format_str` | `string` | Compression format name. |
| `compressed` | `string` | Compressed binary data. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Decompressed binary byte string. |

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
-- signature
lurek.binary.decompressChunks(format_str, chunks)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `format_str` | `string` | Compression format name. |
| `chunks` | `any` | Binary string or array table of binary strings. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Decompressed binary byte string. |

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
-- signature
lurek.binary.encode(format_str, raw_data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `format_str` | `string` | Encoding format name. |
| `raw_data` | `string` | Raw binary data to encode. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Encoded string. |

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
-- signature
lurek.binary.encodeToml(tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tbl` | `table` | Lua table to encode as TOML. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | TOML document text. |

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
-- signature
lurek.binary.fromMsgPack(bytes)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bytes` | `string` | Encoded binary payload. |

**Returns**

| Type | Description |
|------|-------------|
| `LuaValue` | Decoded Lua value. |

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
-- signature
lurek.binary.getPackedSize(fmt, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fmt` | `string` | Binary pack format string. |
| — | — | @param ... any Values measured according to the format. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Packed byte size. |

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
-- signature
lurek.binary.hash(algo_str, raw_data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `algo_str` | `string` | Hash algorithm name. |
| `raw_data` | `string` | Raw binary data to hash. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Hash digest string. |

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
-- signature
lurek.binary.newByteData(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `any` | Integer size for zeroed bytes, or string used as initial bytes. |

**Returns**

| Type | Description |
|------|-------------|
| `LByteData` | New LByteData userdata. |

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
-- signature
lurek.binary.newDataView(raw, offset, size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `raw` | `string` | Binary byte string backing the view. |
| `offset?` | `number` | Optional zero-based start offset; defaults to zero. |
| `size?` | `number` | Optional view size in bytes; defaults to the remaining bytes. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataView` | New data view handle. |

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
-- signature
lurek.binary.newRingBuffer(capacity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `capacity` | `number` | Maximum value count; must be greater than zero. |

**Returns**

| Type | Description |
|------|-------------|
| `LRingBuffer` | New ring buffer handle. |

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
-- signature
lurek.binary.newWriter()
```

**Returns**

| Type | Description |
|------|-------------|
| `LDataWriter` | New data writer handle. |

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
-- signature
lurek.binary.pack(fmt, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fmt` | `string` | Binary pack format string. |
| — | — | @param ... any Values to pack according to the format. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Packed binary byte string. |

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
-- signature
lurek.binary.parseToml(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | TOML document text. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Lua representation of the TOML document. |

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
-- signature
lurek.binary.read(fmt, raw, offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fmt` | `string` | Binary reader format string. |
| `raw` | `string` | Binary byte string to read. |
| `offset?` | `number` | Optional zero-based byte offset; defaults to zero. |

**Returns**

| Type | Description |
|------|-------------|
| `LuaValue` | Values read from the byte string. |

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
-- signature
lurek.binary.size(fmt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fmt` | `string` | Binary format string to measure. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Fixed byte size for the format. |

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
-- signature
lurek.binary.toMsgPack(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `any` | Lua value to encode through the serial table converter. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Encoded binary payload. |

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
-- signature
lurek.binary.unpack(fmt, raw, offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fmt` | `string` | Binary unpack format string. |
| `raw` | `string` | Binary byte string to unpack. |
| `offset?` | `number` | Optional zero-based byte offset; defaults to zero. |

**Returns**

| Type | Description |
|------|-------------|
| `LuaValue` | Unpacked values followed by the next byte offset. |

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
-- signature
lurek.binary.write(fmt, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fmt` | `string` | Binary writer format string. |
| — | — | @param ... any Values to write according to the format. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Binary byte string containing written values. |

**Example**

```lua
do
    local bytes = lurek.binary.write("u32", 42)
    print("write len = " .. #bytes)
    print("read back = " .. lurek.binary.read("u32", bytes))
end
```

---

## LByteData

### `LByteData:clone`

Returns a deep copy of the entire byte buffer.

```lua
-- signature
LByteData:clone()
```

**Returns**

| Type | Description |
|------|-------------|
| `LByteData` | New LByteData userdata containing copied bytes. |

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

### `LByteData:getBit`

Reads one bit inside a byte at the given offsets.

```lua
-- signature
LByteData:getBit(byte_offset, bit_offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `byte_offset` | `number` | Zero-based byte offset. |
| `bit_offset` | `number` | Bit offset from 0 to 7 inside the byte. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the bit is set. |

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

### `LByteData:getByte`

Reads one byte at a zero-based offset.

```lua
-- signature
LByteData:getByte(offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | `number` | Zero-based byte offset. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Byte value from 0 to 255. |

**Example**

```lua
do
    local bd = lurek.binary.newByteData("ABC")
    print("byte[0] = " .. bd:getByte(0))
end
```

---

### `LByteData:getSize`

Returns the byte buffer length in bytes.

```lua
-- signature
LByteData:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Buffer length in bytes. |

**Example**

```lua
do
    local bd = lurek.binary.newByteData(32)
    print("size = " .. bd:getSize())
end
```

---

### `LByteData:getString`

Returns the byte buffer as a string.

```lua
-- signature
LByteData:getString()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Byte buffer contents as a Lua string. |

**Example**

```lua
do
    local bd = lurek.binary.newByteData("Hello")
    print("str = " .. bd:getString())
    print("size = " .. bd:getSize())
end
```

---

### `LByteData:readBits`

Reads up to 32 bits starting at a byte and bit offset.

```lua
-- signature
LByteData:readBits(byte_offset, bit_offset, count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `byte_offset` | `number` | Zero-based byte offset. |
| `bit_offset` | `number` | Bit offset from 0 to 7 inside the starting byte. |
| `count` | `number` | Number of bits to read, from 1 to 32. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Unsigned integer containing the requested bits. |

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

### `LByteData:setBit`

Sets or clears one bit inside a byte at the given offset.

```lua
-- signature
LByteData:setBit(byte_offset, bit_offset, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `byte_offset` | `number` | Zero-based byte offset. |
| `bit_offset` | `number` | Bit offset from 0 to 7 inside the byte. |
| `value` | `boolean` | True to set the bit, false to clear it. |

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

### `LByteData:setByte`

Writes one byte at a zero-based offset inside the buffer.

```lua
-- signature
LByteData:setByte(offset, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | `number` | Zero-based byte offset. |
| `value` | `number` | Byte value from 0 to 255. |

**Example**

```lua
do
    local bd = lurek.binary.newByteData(4)
    bd:setByte(0, 255)
    print("byte[0] = " .. bd:getByte(0))
end
```

---

### `LByteData:type`

Returns the type name of this object for runtime type-checking.

```lua
-- signature
LByteData:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always returns "LByteData". |

**Example**

```lua
do
    local bd = lurek.binary.newByteData(1)
    print("type = " .. bd:type())
end
```

---

### `LByteData:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LByteData:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check (e.g. "LByteData" or "LObject"). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if this object matches the given type. |

**Example**

```lua
do
    local bd = lurek.binary.newByteData(1)
    print("is LByteData = " .. tostring(bd:typeOf("LByteData")))
end
```

---

## LDataView

### `LDataView:getDouble`

Reads a 64-bit float at a byte offset.

```lua
-- signature
LDataView:getDouble(offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | `number` | Zero-based byte offset inside the view. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | 64-bit float value. |

**Example**

```lua
do
    local raw = lurek.binary.pack("d", 2.718281828)
    local view = lurek.binary.newDataView(raw)
    print("f64[0] = " .. view:getDouble(0))
end
```

---

### `LDataView:getFloat`

Reads a 32-bit float at a byte offset.

```lua
-- signature
LDataView:getFloat(offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | `number` | Zero-based byte offset inside the view. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | 32-bit float value converted to Lua number. |

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

### `LDataView:getInt16`

Reads a signed 16-bit integer at a byte offset.

```lua
-- signature
LDataView:getInt16(offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | `number` | Zero-based byte offset inside the view. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Signed 16-bit value. |

**Example**

```lua
do
    local raw = lurek.binary.pack("h", -1000)
    local view = lurek.binary.newDataView(raw)
    print("i16[0] = " .. view:getInt16(0))
end
```

---

### `LDataView:getInt32`

Reads a signed 32-bit integer at a byte offset.

```lua
-- signature
LDataView:getInt32(offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | `number` | Zero-based byte offset inside the view. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Signed 32-bit value. |

**Example**

```lua
do
    local raw = lurek.binary.pack("<i", -100000)
    local view = lurek.binary.newDataView(raw)
    print("i32[0] = " .. view:getInt32(0))
end
```

---

### `LDataView:getInt8`

Reads a signed 8-bit integer at a byte offset.

```lua
-- signature
LDataView:getInt8(offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | `number` | Zero-based byte offset inside the view. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Signed 8-bit value. |

**Example**

```lua
do
    local raw = lurek.binary.pack("b", -42)
    local view = lurek.binary.newDataView(raw)
    print("i8[0] = " .. view:getInt8(0))
end
```

---

### `LDataView:getSize`

Returns this data view size in bytes.

```lua
-- signature
LDataView:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | View size in bytes. |

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

### `LDataView:getUInt16`

Reads an unsigned 16-bit integer at a byte offset.

```lua
-- signature
LDataView:getUInt16(offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | `number` | Zero-based byte offset inside the view. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Unsigned 16-bit value. |

**Example**

```lua
do
    local raw = lurek.binary.pack("H", 65000)
    local view = lurek.binary.newDataView(raw)
    print("u16[0] = " .. view:getUInt16(0))
end
```

---

### `LDataView:getUInt32`

Reads an unsigned 32-bit integer at a byte offset.

```lua
-- signature
LDataView:getUInt32(offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | `number` | Zero-based byte offset inside the view. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Unsigned 32-bit value. |

**Example**

```lua
do
    local raw = lurek.binary.pack("<I", 3000000)
    local view = lurek.binary.newDataView(raw)
    print("u32[0] = " .. view:getUInt32(0))
end
```

---

### `LDataView:getUInt8`

Reads an unsigned 8-bit integer at a byte offset.

```lua
-- signature
LDataView:getUInt8(offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | `number` | Zero-based byte offset inside the view. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Unsigned 8-bit value. |

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

### `LDataView:type`

Returns the Lua-visible type name for this data view handle.

```lua
-- signature
LDataView:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LDataView`. |

**Example**

```lua
do
    local view = lurek.binary.newDataView("abc")
    print("type = " .. view:type())
end
```

---

### `LDataView:typeOf`

Returns whether this data view handle matches a supported type name.

```lua
-- signature
LDataView:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LDataView` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local view = lurek.binary.newDataView("abc")
    print("is LDataView = " .. tostring(view:typeOf("LDataView")))
end
```

---

## LDataWriter

### `LDataWriter:len`

Returns the current length of the writer buffer.

```lua
-- signature
LDataWriter:len()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Buffer length in bytes. |

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

### `LDataWriter:seek`

Moves the writer cursor to a specific byte position.

```lua
-- signature
LDataWriter:seek(pos)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pos` | `number` | New cursor position in bytes. |

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

### `LDataWriter:tell`

Returns the writer cursor position.

```lua
-- signature
LDataWriter:tell()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current cursor position in bytes. |

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

### `LDataWriter:toBytes`

Returns the writer buffer as a binary string.

```lua
-- signature
LDataWriter:toBytes()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Binary byte string containing writer contents. |

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

### `LDataWriter:type`

Returns the Lua-visible type name for this data writer handle.

```lua
-- signature
LDataWriter:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LDataWriter`. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    print("type = " .. w:type())
end
```

---

### `LDataWriter:typeOf`

Returns whether this data writer handle matches a supported type name.

```lua
-- signature
LDataWriter:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LDataWriter` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    print("is LDataWriter = " .. tostring(w:typeOf("LDataWriter")))
end
```

---

### `LDataWriter:writeBytes`

Appends raw bytes from a Lua string to the writer buffer.

```lua
-- signature
LDataWriter:writeBytes(s)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `s` | `string` | Raw byte string to write. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeBytes("\x00\x01\x02\x03")
    print("after writeBytes len = " .. w:len())
end
```

---

### `LDataWriter:writeF32LE`

Appends a 32-bit float value in little-endian byte order.

```lua
-- signature
LDataWriter:writeF32LE(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Value to write. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeF32LE(3.14)
    print("after writeF32LE len = " .. w:len())
end
```

---

### `LDataWriter:writeF64LE`

Appends a 64-bit float value in little-endian byte order.

```lua
-- signature
LDataWriter:writeF64LE(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Value to write. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeF64LE(2.718281828)
    print("after writeF64LE len = " .. w:len())
end
```

---

### `LDataWriter:writeI16LE`

Appends a signed 16-bit integer in little-endian byte order.

```lua
-- signature
LDataWriter:writeI16LE(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Value to write. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeI16LE(-500)
    print("after writeI16LE len = " .. w:len())
end
```

---

### `LDataWriter:writeI32LE`

Appends a signed 32-bit integer in little-endian byte order.

```lua
-- signature
LDataWriter:writeI32LE(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Value to write. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeI32LE(-99999)
    print("after writeI32LE len = " .. w:len())
end
```

---

### `LDataWriter:writeI8`

Appends a signed 8-bit integer to the writer buffer.

```lua
-- signature
LDataWriter:writeI8(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Value to write. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeI8(-128)
    print("after writeI8 len = " .. w:len())
end
```

---

### `LDataWriter:writeString`

Appends a UTF-8 encoded string to the writer buffer.

```lua
-- signature
LDataWriter:writeString(s)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `s` | `string` | String contents to write. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeString("Hello!")
    print("after writeString len = " .. w:len())
end
```

---

### `LDataWriter:writeU16BE`

Appends an unsigned 16-bit integer in big-endian byte order.

```lua
-- signature
LDataWriter:writeU16BE(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Value to write. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeU16BE(1000)
    print("after writeU16BE len = " .. w:len())
end
```

---

### `LDataWriter:writeU16LE`

Appends an unsigned 16-bit integer in little-endian byte order.

```lua
-- signature
LDataWriter:writeU16LE(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Value to write. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeU16LE(1000)
    print("after writeU16LE len = " .. w:len())
end
```

---

### `LDataWriter:writeU32LE`

Appends an unsigned 32-bit integer in little-endian byte order.

```lua
-- signature
LDataWriter:writeU32LE(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Value to write. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeU32LE(123456)
    print("after writeU32LE len = " .. w:len())
end
```

---

### `LDataWriter:writeU8`

Appends an unsigned 8-bit integer to the writer buffer.

```lua
-- signature
LDataWriter:writeU8(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Value to write. |

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

## LRingBuffer

### `LRingBuffer:capacity`

Returns the maximum capacity of the ring buffer.

```lua
-- signature
LRingBuffer:capacity()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Maximum number of stored values. |

**Example**

```lua
do
    local rb = lurek.binary.newRingBuffer(5)
    print("capacity = " .. rb:capacity())
end
```

---

### `LRingBuffer:clear`

Removes every stored value and releases their registry keys.

```lua
-- signature
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

### `LRingBuffer:isEmpty`

Returns whether the ring buffer has no values.

```lua
-- signature
LRingBuffer:isEmpty()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the buffer is empty. |

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

### `LRingBuffer:isFull`

Returns whether the ring buffer is at capacity.

```lua
-- signature
LRingBuffer:isFull()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the buffer length is at least its capacity. |

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

### `LRingBuffer:len`

Returns the number of values currently stored.

```lua
-- signature
LRingBuffer:len()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current buffer length. |

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

### `LRingBuffer:peek`

Returns the oldest stored value without removing it from the ring buffer.

```lua
-- signature
LRingBuffer:peek()
```

**Returns**

| Type | Description |
|------|-------------|
| `LuaValue` | Oldest stored value, or nil when the buffer is empty. |

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

### `LRingBuffer:peekNewest`

Returns the newest stored value without removing it from the ring buffer.

```lua
-- signature
LRingBuffer:peekNewest()
```

**Returns**

| Type | Description |
|------|-------------|
| `LuaValue` | Newest stored value, or nil when the buffer is empty. |

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

### `LRingBuffer:pop`

Removes and returns the oldest stored value from the ring buffer.

```lua
-- signature
LRingBuffer:pop()
```

**Returns**

| Type | Description |
|------|-------------|
| `LuaValue` | Oldest stored value, or nil when the buffer is empty. |

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

### `LRingBuffer:push`

Pushes a value into the ring buffer and evicts the oldest value when full.

```lua
-- signature
LRingBuffer:push(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `any` | Lua value to store in the buffer. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the push evicted an older value. |

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

### `LRingBuffer:toTable`

Returns stored values in oldest-to-newest order.

```lua
-- signature
LRingBuffer:toTable()
```

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of stored values. |

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

### `LRingBuffer:type`

Returns the Lua-visible type name for this ring buffer handle.

```lua
-- signature
LRingBuffer:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LRingBuffer`. |

**Example**

```lua
do
    local rb = lurek.binary.newRingBuffer(4)
    print("type = " .. rb:type())
end
```

---

### `LRingBuffer:typeOf`

Returns whether this ring buffer handle matches a supported type name.

```lua
-- signature
LRingBuffer:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LRingBuffer` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local rb = lurek.binary.newRingBuffer(4)
    print("is LRingBuffer = " .. tostring(rb:typeOf("LRingBuffer")))
end
```

---
