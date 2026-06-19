# Binary

## Summary

- The `binary` module is the byte-oriented data surface for users who need exact control over compact formats, protocol payloads, and structured runtime interchange.
- Mutable byte containers, typed views, sequential writers, and pack-style helpers work together so a script can both inspect existing binary data and build new payloads without inventing its own low-level buffer rules.
- Compression, encoding, hashes, checksums, and ring-buffer helpers matter because real binary workflows usually involve transport safety, storage reduction, and integrity checks alongside raw reads and writes.
- MsgPack, TOML bridges, and schema-like packing utilities make the module useful for both debug tooling and production-facing data paths such as saves, networking, and cached assets.
- Exact offset control, byte-order awareness, and sequential write semantics are especially valuable when interoperating with protocols or compact save formats where structure must be reproduced precisely.
- The module therefore acts as the engine's low-level data construction kit whenever higher-level structured formats are too heavy or too opaque for the problem at hand.
- That also makes it useful when tests or tools need to inspect raw payload layout instead of only decoded high-level values.
- It keeps raw layout work first-class.
- Read `binary` as the shared byte-language of the engine: other modules decide what the data means, but `binary` owns how that data is packed, transformed, verified, and moved around safely.

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
    local restored = lurek.binary.decompress("deflate", compressed)
    local savedBytes = #raw - #compressed
    lurek.log.info("dialogue raw bytes=" .. tostring(#raw))
    lurek.log.info("dialogue compressed bytes=" .. tostring(#compressed) .. " saved=" .. tostring(savedBytes) .. " restored=" .. tostring(restored == raw))
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
    local restored = lurek.binary.decompressChunks("deflate", compressed)
    local merged = table.concat(chunks)
    local restoredLen = #restored
    lurek.log.info("replay chunk count=" .. tostring(#chunks))
    lurek.log.info("replay compressed bytes=" .. tostring(#compressed) .. " restored ok=" .. tostring(restored == merged) .. " restored len=" .. tostring(restoredLen))
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
    local changedCrc = lurek.binary.crc32("test data!")
    local crcType = type(crc)
    lurek.log.info("packet crc32=" .. tostring(crc))
    lurek.log.info("packet crc type=" .. tostring(crcType) .. " changed payload differs=" .. tostring(changedCrc ~= crc))
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
    local reencoded = lurek.binary.encode("base64", decoded)
    local samePayload = reencoded == encoded
    lurek.log.info("decoded chat snippet=" .. tostring(decoded))
    lurek.log.info("decoded round trip stable=" .. tostring(samePayload))
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
    example_print_log("restored len = " .. #restored)
    example_print_log("restored matches = " .. tostring(restored == raw))
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
    example_print_log("decompressed chunks len = " .. #restored)
    example_print_log("restored preview = " .. restored:sub(1, 8))
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
    local decoded = lurek.binary.decode("base64", encoded)
    local header = encoded:sub(1, 8)
    lurek.log.info("encoded quest note header=" .. tostring(header))
    lurek.log.info("quest note restored=" .. tostring(decoded))
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
    local parsed = lurek.binary.parseToml(text)
    local preview = text:sub(1, 20)
    lurek.log.info("encoded toml len=" .. tostring(#text) .. " preview=" .. tostring(preview))
    lurek.log.info("encoded toml title=" .. tostring(parsed.title) .. " version=" .. tostring(parsed.version))
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
    example_print_log("decoded score = " .. decoded.score)
    example_print_log("decoded name = " .. decoded.name)
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
    local itemPacket = lurek.binary.pack("BHI", 7, 25, 9000)
    local itemPacketSize = lurek.binary.getPackedSize("BHI", 7, 25, 9000)
    lurek.log.info("fixed packet size=" .. tostring(sz))
    lurek.log.info("item packet size matches=" .. tostring(itemPacketSize == #itemPacket))
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
    local otherDigest = lurek.binary.hash("sha256", "secret data v2")
    local sameDigest = digest == otherDigest
    lurek.log.info("save manifest sha256 len=" .. tostring(#digest))
    lurek.log.info("different payload same digest=" .. tostring(sameDigest))
end
```

---

### `lurek.binary.newByteData`

Creates ByteData from a size or raw byte string.

```lua
lurek.binary.newByteData(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Integer size for zeroed bytes, or raw Lua string used as initial bytes. |

**Returns**

| Type | Description |
|------|-------------|
| [LByteData](#lbytedata) | New [LByteData](#lbytedata) userdata. |

**Example**

```lua
do
    local bd = lurek.binary.newByteData(16)
    bd:setByte(0, 65)
    bd:setByte(1, 66)
    local size = bd:getSize()
    local firstByte = bd:getByte(0)
    lurek.log.info("byte buffer size=" .. tostring(size))
    lurek.log.info("byte buffer first bytes=" .. tostring(firstByte) .. "," .. tostring(bd:getByte(1)))
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
| [LDataView](#ldataview) | New data view handle. |

**Example**

```lua
do
    local raw = lurek.binary.pack("<II", 42, 99)
    local view = lurek.binary.newDataView(raw)
    local firstValue = view:getUInt32(0)
    local secondValue = view:getUInt32(4)
    local size = view:getSize()
    lurek.log.info("spawn view size=" .. tostring(size))
    lurek.log.info("spawn view values=" .. tostring(firstValue) .. "," .. tostring(secondValue))
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
| [LRingBuffer](#lringbuffer) | New ring buffer handle. |

**Example**

```lua
do
    local rb = lurek.binary.newRingBuffer(8)
    rb:push("spawn")
    rb:push("loot")
    local capacity = rb:capacity()
    local length = rb:len()
    lurek.log.info("event ring capacity=" .. tostring(capacity))
    lurek.log.info("event ring len=" .. tostring(length) .. " empty=" .. tostring(rb:isEmpty()))
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
| [LDataWriter](#ldatawriter) | New data writer handle. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeU8(1)
    w:writeU8(2)
    local writerLen = w:len()
    local typeName = w:type()
    lurek.log.info("writer created=" .. tostring(w ~= nil))
    lurek.log.info("writer type=" .. tostring(typeName) .. " len=" .. tostring(writerLen))
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
    local actorId = 255
    local health = 1000
    local gold = 123456
    local packed = lurek.binary.pack("BHI", actorId, health, gold)
    local savedActorId, savedHealth, savedGold = lurek.binary.unpack("BHI", packed)
    lurek.log.info("save header bytes=" .. tostring(#packed))
    lurek.log.info("save header actor=" .. tostring(savedActorId) .. " hp=" .. tostring(savedHealth) .. " gold=" .. tostring(savedGold))
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
    local playerName = t.player.name
    local playerLevel = t.player.level
    local playerSummary = playerName .. ":" .. tostring(playerLevel)
    lurek.log.info("parsed toml player=" .. tostring(playerSummary))
    lurek.log.info("parsed toml has player table=" .. tostring(t.player ~= nil))
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
    local bytes = lurek.binary.write("bool cstr", true, "ok")
    local flag, text = lurek.binary.read("bool cstr", bytes)
    local rawSize = #bytes
    lurek.log.info("network flag=" .. tostring(flag))
    lurek.log.info("network text=" .. tostring(text) .. " bytes=" .. tostring(rawSize))
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
    local transformSize = lurek.binary.size("f32 f32 f32")
    local transformBytes = lurek.binary.write("f32 f32 f32", 1.0, 2.0, 3.0)
    lurek.log.info("single u32 size=" .. tostring(sz))
    lurek.log.info("transform bytes match=" .. tostring(transformSize == #transformBytes))
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
    local decoded = lurek.binary.fromMsgPack(bytes)
    local firstByte = string.byte(bytes, 1)
    lurek.log.info("msgpack bytes=" .. tostring(#bytes) .. " first byte=" .. tostring(firstByte))
    lurek.log.info("msgpack score=" .. tostring(decoded.score) .. " name=" .. tostring(decoded.name))
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
    local checksum = b + h + i
    local headerSize = lurek.binary.getPackedSize("BHI", 255, 1000, 123456)
    lurek.log.info("enemy packet values=" .. tostring(b) .. "," .. tostring(h) .. "," .. tostring(i))
    lurek.log.info("enemy packet checksum=" .. tostring(checksum) .. " size=" .. tostring(headerSize))
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
    local rewardBytes = lurek.binary.write("u32 u32", 42, 500)
    local questId, reward = lurek.binary.read("u32 u32", rewardBytes)
    lurek.log.info("reward packet bytes=" .. tostring(#rewardBytes))
    lurek.log.info("reward packet quest=" .. tostring(questId) .. " reward=" .. tostring(reward))
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## Types

- [LByteData](#lbytedata)
- [LDataView](#ldataview)
- [LDataWriter](#ldatawriter)
- [LRingBuffer](#lringbuffer)

## LByteData

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LByteData:clone`

Returns a deep copy of the entire byte buffer.

```lua
LByteData:clone()
```

**Returns**

| Type | Description |
|------|-------------|
| [LByteData](#lbytedata) | New [LByteData](#lbytedata) userdata containing copied bytes. |

**Example**

```lua
do
    local bd = lurek.binary.newByteData("test")
    local copy = bd:clone()
    copy:setByte(0, 88)
    local originalByte = bd:getByte(0)
    local copiedByte = copy:getByte(0)
    local sameSize = bd:getSize() == copy:getSize()
    lurek.log.info("clone keeps original byte=" .. tostring(originalByte))
    lurek.log.info("clone changed byte=" .. tostring(copiedByte) .. " size match=" .. tostring(sameSize))
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
    local highBit = bd:getBit(0, 7)
    local lowBit = bd:getBit(0, 0)
    local storedByte = bd:getByte(0)
    lurek.log.info("stored byte=" .. tostring(storedByte))
    lurek.log.info("high bit=" .. tostring(highBit) .. " low bit=" .. tostring(lowBit))
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
    local firstByte = bd:getByte(0)
    local secondByte = bd:getByte(1)
    local size = bd:getSize()
    lurek.log.info("byte data ascii=" .. tostring(firstByte) .. "," .. tostring(secondByte))
    lurek.log.info("byte data size=" .. tostring(size))
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
    bd:setByte(0, 10)
    bd:setByte(31, 99)
    local size = bd:getSize()
    local firstByte = bd:getByte(0)
    lurek.log.info("byte data size=" .. tostring(size))
    lurek.log.info("byte data edge bytes=" .. tostring(firstByte) .. "," .. tostring(bd:getByte(31)))
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
| string | Raw byte buffer contents as a Lua string without UTF-8 validation. |

**Example**

```lua
do
    local bd = lurek.binary.newByteData(string.char(0x48, 0x65, 0x00, 0xFF))
    local rawString = bd:getString()
    local size = bd:getSize()
    local lastByte = bd:getByte(3)
    lurek.log.info("byte data string len=" .. tostring(#rawString))
    lurek.log.info("byte data size=" .. tostring(size) .. " last byte=" .. tostring(lastByte))
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
    example_print_log("12 bits = " .. val)
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
    example_print_log("byte = " .. bd:getByte(0))
    example_print_log("bit 7 = " .. tostring(bd:getBit(0, 7)))
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
    bd:setByte(1, 128)
    local firstByte = bd:getByte(0)
    local secondByte = bd:getByte(1)
    lurek.log.info("written bytes=" .. tostring(firstByte) .. "," .. tostring(secondByte))
    lurek.log.info("byte data size=" .. tostring(bd:getSize()))
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
| string | Always returns "[LByteData](#lbytedata)". |

**Example**

```lua
do
    local bd = lurek.binary.newByteData(1)
    bd:setByte(0, 7)
    local typeName = bd:type()
    local size = bd:getSize()
    lurek.log.info("byte data type=" .. tostring(typeName))
    lurek.log.info("byte data size=" .. tostring(size))
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
| `name` | string | Type name to check (e.g. "[LByteData](#lbytedata)" or "LObject"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if this object matches the given type. |

**Example**

```lua
do
    local bd = lurek.binary.newByteData(1)
    bd:setByte(0, 7)
    local isByteData = bd:typeOf("LByteData")
    local isView = bd:typeOf("LDataView")
    lurek.log.info("is byte data=" .. tostring(isByteData))
    lurek.log.info("is data view=" .. tostring(isView))
end
```

---

## LDataView

### Type Fields

*No documented fields for this handle.*

### Type Methods

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
    local precisionValue = view:getDouble(0)
    local size = view:getSize()
    local isView = view:typeOf("LDataView")
    lurek.log.info("double precision value=" .. tostring(precisionValue))
    lurek.log.info("double view size=" .. tostring(size) .. " is view=" .. tostring(isView))
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
    local radius = view:getFloat(0)
    local size = view:getSize()
    local bytes = lurek.binary.pack("f", radius * 2.0)
    lurek.log.info("float radius=" .. tostring(radius))
    lurek.log.info("float view size=" .. tostring(size) .. " doubled bytes=" .. tostring(#bytes))
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
    local yVelocity = view:getInt16(0)
    local size = view:getSize()
    local isView = view:typeOf("LDataView")
    lurek.log.info("signed y velocity=" .. tostring(yVelocity))
    lurek.log.info("i16 view size=" .. tostring(size) .. " is view=" .. tostring(isView))
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
    local worldOffset = view:getInt32(0)
    local size = view:getSize()
    local isView = view:typeOf("LDataView")
    lurek.log.info("signed world offset=" .. tostring(worldOffset))
    lurek.log.info("i32 view size=" .. tostring(size) .. " is view=" .. tostring(isView))
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
    local velocity = view:getInt8(0)
    local size = view:getSize()
    local typeName = view:type()
    lurek.log.info("signed velocity byte=" .. tostring(velocity))
    lurek.log.info("velocity view size=" .. tostring(size) .. " type=" .. tostring(typeName))
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
    local size = view:getSize()
    local firstValue = view:getUInt32(0)
    local lastValue = view:getUInt32(8)
    lurek.log.info("navigation node blob size=" .. tostring(size))
    lurek.log.info("navigation node values=" .. tostring(firstValue) .. "," .. tostring(lastValue))
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
    local tileId = view:getUInt16(0)
    local size = view:getSize()
    local typeName = view:type()
    lurek.log.info("tileset entry id=" .. tostring(tileId))
    lurek.log.info("u16 view size=" .. tostring(size) .. " type=" .. tostring(typeName))
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
    local saveVersion = view:getUInt32(0)
    local size = view:getSize()
    local typeName = view:type()
    lurek.log.info("save version id=" .. tostring(saveVersion))
    lurek.log.info("u32 view size=" .. tostring(size) .. " type=" .. tostring(typeName))
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
    local red = view:getUInt8(0)
    local green = view:getUInt8(1)
    local blue = view:getUInt8(2)
    lurek.log.info("palette rgb=" .. tostring(red) .. "," .. tostring(green) .. "," .. tostring(blue))
    lurek.log.info("palette raw bytes=" .. tostring(view:getSize()))
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
| string | The string `[LDataView](#ldataview)`. |

**Example**

```lua
do
    local view = lurek.binary.newDataView("abc")
    local typeName = view:type()
    local size = view:getSize()
    local isView = view:typeOf("LDataView")
    lurek.log.info("data view type=" .. tostring(typeName))
    lurek.log.info("data view size=" .. tostring(size) .. " is view=" .. tostring(isView))
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
| `name` | string | Type name to compare against `[LDataView](#ldataview)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local view = lurek.binary.newDataView("abc")
    local isView = view:typeOf("LDataView")
    local isWriter = view:typeOf("LDataWriter")
    local size = view:getSize()
    lurek.log.info("is data view=" .. tostring(isView))
    lurek.log.info("is data writer=" .. tostring(isWriter) .. " size=" .. tostring(size))
end
```

---

## LDataWriter

### Type Fields

*No documented fields for this handle.*

### Type Methods

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
    local len = w:len()
    local cursor = w:tell()
    local bytes = w:toBytes()
    lurek.log.info("writer len after two u16 values=" .. tostring(len))
    lurek.log.info("writer cursor=" .. tostring(cursor) .. " first byte=" .. tostring(string.byte(bytes, 1)))
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
    example_print_log("seek then overwrite, len = " .. w:len())
    example_print_log("cursor = " .. w:tell())
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
    local cursor = w:tell()
    local len = w:len()
    local bytes = w:toBytes()
    lurek.log.info("writer cursor=" .. tostring(cursor))
    lurek.log.info("writer len=" .. tostring(len) .. " last byte=" .. tostring(string.byte(bytes, 2)))
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
    example_print_log("bytes len = " .. #bytes)
    example_print_log("bytes text = " .. bytes)
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
| string | The string `[LDataWriter](#ldatawriter)`. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeU8(7)
    local typeName = w:type()
    local len = w:len()
    lurek.log.info("writer type=" .. tostring(typeName))
    lurek.log.info("writer len=" .. tostring(len))
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
| `name` | string | Type name to compare against `[LDataWriter](#ldatawriter)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local w = lurek.binary.newWriter()
    w:writeU8(7)
    local isWriter = w:typeOf("LDataWriter")
    local isView = w:typeOf("LDataView")
    lurek.log.info("is data writer=" .. tostring(isWriter))
    lurek.log.info("is data view=" .. tostring(isView))
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
    w:writeBytes("\x04\x05")
    local bytes = w:toBytes()
    local len = w:len()
    lurek.log.info("raw byte writer len=" .. tostring(len))
    lurek.log.info("raw byte tail=" .. tostring(string.byte(bytes, 5)) .. "," .. tostring(string.byte(bytes, 6)))
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
    w:writeF32LE(6.28)
    local bytes = w:toBytes()
    local view = lurek.binary.newDataView(bytes)
    lurek.log.info("f32le writer len=" .. tostring(w:len()))
    lurek.log.info("f32le values=" .. tostring(view:getFloat(0)) .. "," .. tostring(view:getFloat(4)))
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
    w:writeF64LE(1.414213562)
    local bytes = w:toBytes()
    local view = lurek.binary.newDataView(bytes)
    lurek.log.info("f64le writer len=" .. tostring(w:len()))
    lurek.log.info("f64le first value=" .. tostring(view:getDouble(0)) .. " second value=" .. tostring(view:getDouble(8)))
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
    w:writeI16LE(125)
    local bytes = w:toBytes()
    local view = lurek.binary.newDataView(bytes)
    lurek.log.info("i16le writer len=" .. tostring(w:len()))
    lurek.log.info("i16le values=" .. tostring(view:getInt16(0)) .. "," .. tostring(view:getInt16(2)))
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
    w:writeI32LE(12345)
    local bytes = w:toBytes()
    local view = lurek.binary.newDataView(bytes)
    lurek.log.info("i32le writer len=" .. tostring(w:len()))
    lurek.log.info("i32le values=" .. tostring(view:getInt32(0)) .. "," .. tostring(view:getInt32(4)))
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
    w:writeI8(12)
    local bytes = w:toBytes()
    local view = lurek.binary.newDataView(bytes)
    lurek.log.info("i8 writer len=" .. tostring(w:len()))
    lurek.log.info("i8 writer values=" .. tostring(view:getInt8(0)) .. "," .. tostring(view:getInt8(1)))
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
    w:writeString("Quest")
    local bytes = w:toBytes()
    local len = w:len()
    lurek.log.info("string writer len=" .. tostring(len))
    lurek.log.info("string writer preview=" .. tostring(bytes:sub(1, 6)))
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
    w:writeU16BE(2000)
    local bytes = w:toBytes()
    local firstPair = string.byte(bytes, 1) .. "," .. string.byte(bytes, 2)
    lurek.log.info("u16be writer len=" .. tostring(w:len()))
    lurek.log.info("u16be first pair=" .. tostring(firstPair) .. " second first byte=" .. tostring(string.byte(bytes, 3)))
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
    w:writeU16LE(2000)
    local bytes = w:toBytes()
    local view = lurek.binary.newDataView(bytes)
    lurek.log.info("u16le writer len=" .. tostring(w:len()))
    lurek.log.info("u16le values=" .. tostring(view:getUInt16(0)) .. "," .. tostring(view:getUInt16(2)))
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
    w:writeU32LE(654321)
    local bytes = w:toBytes()
    local view = lurek.binary.newDataView(bytes)
    lurek.log.info("u32le writer len=" .. tostring(w:len()))
    lurek.log.info("u32le values=" .. tostring(view:getUInt32(0)) .. "," .. tostring(view:getUInt32(4)))
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
    w:writeU8(64)
    local bytes = w:toBytes()
    local len = w:len()
    lurek.log.info("u8 writer len=" .. tostring(len))
    lurek.log.info("u8 writer bytes=" .. tostring(string.byte(bytes, 1)) .. "," .. tostring(string.byte(bytes, 2)))
end
```

---

## LRingBuffer

### Type Fields

*No documented fields for this handle.*

### Type Methods

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
    rb:push("north")
    rb:push("east")
    local capacity = rb:capacity()
    local count = rb:len()
    lurek.log.info("input history capacity=" .. tostring(capacity))
    lurek.log.info("input history count=" .. tostring(count))
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
    example_print_log("after clear len = " .. rb:len())
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
    local beforePush = rb:isEmpty()
    rb:push("value")
    local afterPush = rb:isEmpty()
    local newest = rb:peekNewest()
    lurek.log.info("buffer empty before push=" .. tostring(beforePush))
    lurek.log.info("buffer empty after push=" .. tostring(afterPush) .. " newest=" .. tostring(newest))
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
    example_print_log("full = " .. tostring(rb:isFull()))
    example_print_log("len = " .. tostring(rb:len()))
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
    example_print_log("len = " .. rb:len())
    example_print_log("capacity = " .. rb:capacity())
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
    local oldest = rb:peek()
    local newest = rb:peekNewest()
    local count = rb:len()
    lurek.log.info("oldest queued event=" .. tostring(oldest))
    lurek.log.info("newest queued event=" .. tostring(newest) .. " count=" .. tostring(count))
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
    local oldest = rb:peek()
    local newest = rb:peekNewest()
    local count = rb:len()
    lurek.log.info("oldest replay marker=" .. tostring(oldest))
    lurek.log.info("newest replay marker=" .. tostring(newest) .. " count=" .. tostring(count))
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
    example_print_log("popped = " .. oldest)
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
    example_print_log("evicted = " .. tostring(evicted))
    example_print_log("newest = " .. tostring(rb:peekNewest()))
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
    example_print_log("table len = " .. #t)
    example_print_log("first item = " .. tostring(t[1]))
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
| string | The string `[LRingBuffer](#lringbuffer)`. |

**Example**

```lua
do
    local rb = lurek.binary.newRingBuffer(4)
    rb:push("fx")
    local typeName = rb:type()
    local count = rb:len()
    lurek.log.info("ring buffer type=" .. tostring(typeName))
    lurek.log.info("ring buffer count=" .. tostring(count))
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
| `name` | string | Type name to compare against `[LRingBuffer](#lringbuffer)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local rb = lurek.binary.newRingBuffer(4)
    rb:push("fx")
    local isRingBuffer = rb:typeOf("LRingBuffer")
    local isWriter = rb:typeOf("LDataWriter")
    lurek.log.info("is ring buffer=" .. tostring(isRingBuffer))
    lurek.log.info("is writer=" .. tostring(isWriter))
end
```

---
