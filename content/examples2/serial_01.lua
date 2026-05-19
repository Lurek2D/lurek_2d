--- Serial Module: decode, decodeMsgPack, toCsv, toJson, toToml

--@api-stub: lurek.serial.decodeMsgPack
-- Decode binary or formatted payload into a Lua table.
do
    local ok, t = lurek.serial.decode('{"key": 1}', "json")
    print("decode ok=" .. tostring(ok))
    local bytes = lurek.serial.encodeMsgPack({ x = 1, y = 2 })
    local ok2, t2 = lurek.serial.decodeMsgPack(bytes)
    print("msgpack ok=" .. tostring(ok2))
end

--@api-stub: lurek.serial.toCsv
--@api-stub: lurek.serial.toToml
-- Serialize a table to CSV, JSON, or TOML string.
do
    local data = { { name = "Alice", score = 100 }, { name = "Bob", score = 90 } }
    local csv = lurek.serial.toCsv(data, ",", true)
    print("csv lines = " .. #csv)
    local json = lurek.serial.toJson({ a = 1, b = "hello" }, true)
    print("json = " .. json)
    local toml = lurek.serial.toToml({ version = "1.0", debug = false })
    print("toml = " .. toml)
end

print("serial_01.lua")
