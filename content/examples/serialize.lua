-- content/examples/serial.lua
-- Auto-generated from content/examples2/serial_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/serial.lua

--- Serial Module: JSON, TOML, CSV, INI, MsgPack, XML, format detection, schema validation

--@api-stub: lurek.serial.fromJson
do
    local jsonStr = '{"name":"warrior","level":12,"alive":true,"items":["sword","shield"]}'
    local data = lurek.serial.fromJson(jsonStr)
    print("name = " .. data.name)
    print("items count = " .. #data.items)
end

--@api-stub: lurek.serial.toJson
do
    local json = lurek.serial.toJson({ player = { name = "Alice", level = 2 } }, true)
    print("encoded length = " .. #json)
    print("has player = " .. tostring(json:find('"player"') ~= nil))
end

--@api-stub: lurek.serial.fromToml
do
    local tomlStr = '[game]\ntitle = "Dungeon Quest"\n[window]\nwidth = 1920\nheight = 1080'
    local config = lurek.serial.fromToml(tomlStr)
    print("title = " .. config.game.title)
    print("window = " .. config.window.width .. "x" .. config.window.height)
end

--@api-stub: lurek.serial.fromCsv
do
    local csvWithHeaders = "name,age,city\nAlice,30,Warsaw\nBob,25,Krakow\nCarol,35,Gdansk"
    local rows = lurek.serial.fromCsv(csvWithHeaders, ",", true)
    print("rows with headers = " .. #rows)
    print("first row name = " .. rows[1].name)
    print("second row city = " .. rows[2].city)
end

--@api-stub: lurek.serial.fromIni
do
    local iniStr = '[player]\nname = Hero\nclass = warrior\n[controls]\njump = space'
    local ini = lurek.serial.fromIni(iniStr)
    print("player name = " .. ini.player.name)
    print("jump key = " .. ini.controls.jump)
end

--@api-stub: lurek.serial.encodeMsgPack
do
    local packed = lurek.serial.encodeMsgPack({ version = 2, entities = { { id = 1, hp = 100 } } })
    local unpacked = lurek.serial.decodeMsgPack(packed)
    print("version = " .. unpacked.version)
    print("entities = " .. #unpacked.entities)
end

--@api-stub: lurek.serial.decodeXml
do
    local doc = lurek.serial.decodeXml('<tilemap><layer name="ground" visible="true"/></tilemap>')
    print("root tag = " .. (doc.tag or doc.name or "unknown"))
    print("decoded xml type = " .. type(doc))
end

--@api-stub: lurek.serial.encode
do
    local jsonOut = lurek.serial.encode({ greeting = "hello", count = 42 }, "json", { pretty = true })
    print("json encode = " .. jsonOut)
    print("count = " .. lurek.serial.decode(jsonOut, "json").count)
end

--@api-stub: lurek.serial.detectFormat
do
    local format = lurek.serial.detectFormat('{"key": "value"}')
    print("json detected = " .. tostring(format))
end

--@api-stub: lurek.serial.validate
do
    local schema = { type = "object", required = { "name", "level" } }
    local ok, err = lurek.serial.validate({ name = "Knight", level = 50 }, schema)
    print("valid data ok = " .. tostring(ok))
    print("valid err = " .. tostring(err))
end

--@api-stub: lurek.serial.applyDefaults
do
    local schema = { fields = { width = { default = 800 }, height = { default = 600 }, title = { default = "Untitled" } } }
    local filled = lurek.serial.applyDefaults({ width = 1280 }, schema)
    print("width = " .. filled.width)
    print("height = " .. filled.height)
    print("title = " .. filled.title)
end

--@api-stub: lurek.serial.decode
do
    local jsonPayload = '{"auto": true, "score": 99}'
    local result = lurek.serial.decode(jsonPayload)
    print("auto-detected json: auto = " .. tostring(result.auto))
    print("score = " .. result.score)
end

--- Serial Module: decode, decodeMsgPack, toCsv, toJson, toToml

--@api-stub: lurek.serial.decodeMsgPack
do
    local bytes = lurek.serial.encodeMsgPack({ x = 1, y = 2 })
    local decoded = lurek.serial.decodeMsgPack(bytes)
    print("x = " .. tostring(decoded.x))
    print("y = " .. tostring(decoded.y))
end

--@api-stub: lurek.serial.toCsv
do
    local csv = lurek.serial.toCsv({ { name = "Alice", score = 100 }, { name = "Bob", score = 90 } }, ",", true)
    print("csv length = " .. #csv)
    print("contains header = " .. tostring(csv:find("name") ~= nil))
end

--@api-stub: lurek.serial.toToml
do
    local toml = lurek.serial.toToml({ version = "1.0", debug = false })
    print("toml length = " .. #toml)
    print("contains version = " .. tostring(toml:find("version") ~= nil))
end
