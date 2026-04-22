-- content/examples/serial.lua
-- love2d-style usage snippets for the lurek.serial API (10 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/serial.lua

-- ── lurek.serial.* functions ──

--@api-stub: lurek.serial.fromJson
-- Parses a JSON string and returns a Lua table.
-- Build once at startup; reuse across frames.
local fromjson = lurek.serial.fromJson(s)
print("created", fromjson)
return fromjson

--@api-stub: lurek.serial.toJson
-- Serializes a Lua value to a JSON string.
-- See the module spec for detailed semantics.
local result = lurek.serial.toJson(value, pretty)
print("toJson:", result)
return result

--@api-stub: lurek.serial.fromToml
-- Parses a TOML string and returns a Lua table.
-- Build once at startup; reuse across frames.
local fromtoml = lurek.serial.fromToml(s)
print("created", fromtoml)
return fromtoml

--@api-stub: lurek.serial.toToml
-- Serializes a Lua table to a TOML string.
-- See the module spec for detailed semantics.
local result = lurek.serial.toToml(value)
print("toToml:", result)
return result

--@api-stub: lurek.serial.fromCsv
-- Parses a CSV string and returns a sequence of row tables.
-- Build once at startup; reuse across frames.
local fromcsv = lurek.serial.fromCsv(s, delim, headers)
print("created", fromcsv)
return fromcsv

--@api-stub: lurek.serial.toCsv
-- Serializes a sequence of row tables to a CSV string.
-- See the module spec for detailed semantics.
local result = lurek.serial.toCsv(value, delim, headers)
print("toCsv:", result)
return result

--@api-stub: lurek.serial.encodeMsgPack
-- Encodes a Lua table to a binary MessagePack string.
-- May block — call from a worker thread for large payloads.
local result = lurek.serial.encodeMsgPack(value)
-- may block; consider lurek.thread for large payloads
print("encodeMsgPack:", result)
print("ok")

--@api-stub: lurek.serial.decodeMsgPack
-- Decodes a binary MessagePack string into a Lua table.
-- May block — call from a worker thread for large payloads.
local result = lurek.serial.decodeMsgPack()
-- may block; consider lurek.thread for large payloads
print("decodeMsgPack:", result)
print("ok")

--@api-stub: lurek.serial.decodeXml
-- Parses an XML string and returns a nested Lua table.
-- May block — call from a worker thread for large payloads.
local result = lurek.serial.decodeXml(s)
-- may block; consider lurek.thread for large payloads
print("decodeXml:", result)
print("ok")

--@api-stub: lurek.serial.validate
-- Validates a Lua table against a schema table.
-- See the module spec for detailed semantics.
local result = lurek.serial.validate(value, schema)
print("validate:", result)
return result

