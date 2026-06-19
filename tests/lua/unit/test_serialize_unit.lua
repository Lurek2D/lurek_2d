-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_serialize_core_unit.lua
do
-- lurek.serialize API unit tests.
-- Canonical one-owner behavioral coverage for headless-safe serialization helpers.

-- @describe lurek.serial JSON helpers
describe("lurek.serial JSON helpers", function()
    -- @covers lurek.serial.fromJson
    it("fromJson parses objects and arrays and rejects malformed input", function()
        expect_type("function", lurek.serial.fromJson)

        local obj = lurek.serial.fromJson('{"name":"luna","version":1}')
        expect_type("table", obj)
        expect_equal("luna", obj.name)
        expect_equal(1, obj.version)

        local arr = lurek.serial.fromJson("[1,2,3]")
        expect_type("table", arr)
        expect_equal(1, arr[1])
        expect_equal(3, arr[3])

        expect_error(function()
            lurek.serial.fromJson("not json {{{")
        end)
    end)

    -- @covers lurek.serial.toJson
    it("toJson serializes nested tables and supports pretty output", function()
        expect_type("function", lurek.serial.toJson)

        local nested = {
            meta = { version = 2, engine = "lurek" },
            data = { { x = 1, y = 2 }, { x = 3, y = 4 } },
        }

        local compact = lurek.serial.toJson(nested, false)
        local pretty = lurek.serial.toJson(nested, true)
        expect_type("string", compact)
        expect_type("string", pretty)
        expect_true(#compact > 0)
        expect_true(#pretty >= #compact)

        local decoded = lurek.serial.fromJson(compact)
        expect_equal(2, decoded.meta.version)
        expect_equal("lurek", decoded.meta.engine)
        expect_equal(4, decoded.data[2].y)

        local cyclic = {}
        cyclic.self = cyclic
        expect_error(function()
            lurek.serial.toJson(cyclic, false)
        end)

        expect_error(function()
            lurek.serial.toJson({ bad = math.huge }, false)
        end)
    end)
end)

-- @describe lurek.serial TOML helpers
describe("lurek.serial TOML helpers", function()
    -- @covers lurek.serial.fromToml
    it("fromToml parses tables and rejects malformed input", function()
        expect_type("function", lurek.serial.fromToml)

        local t = lurek.serial.fromToml('[window]\ntitle = "Lurek2D"\nwidth = 800\n')
        expect_type("table", t)
        expect_type("table", t.window)
        expect_equal("Lurek2D", t.window.title)
        expect_equal(800, t.window.width)

        expect_error(function()
            lurek.serial.fromToml("[[broken = = ]]")
        end)
    end)

    -- @covers lurek.serial.toToml
    it("toToml serializes tables and round-trips scalar values", function()
        expect_type("function", lurek.serial.toToml)

        local s = lurek.serial.toToml({ game = { fps = 60 }, score = 100 })
        expect_type("string", s)
        expect_true(#s > 0)

        local back = lurek.serial.fromToml(s)
        expect_equal(60, back.game.fps)
        expect_equal(100, back.score)
    end)
end)

-- @describe lurek.serial INI helper
describe("lurek.serial INI helper", function()
    -- @covers lurek.serial.fromIni
    it("fromIni parses sectioned ini text", function()
        local cfg = lurek.serial.fromIni("[player]\nname=hero\n")
        expect_equal("hero", cfg.player.name)
    end)
end)

-- @describe lurek.serial CSV helpers
describe("lurek.serial CSV helpers", function()
    -- @covers lurek.serial.fromCsv
    it("fromCsv supports headers, no headers, and custom delimiters", function()
        expect_type("function", lurek.serial.fromCsv)

        local rows = lurek.serial.fromCsv("name,score\nalice,10\nbob,20\n", nil, true)
        expect_true(#rows >= 2)
        expect_equal("alice", rows[1].name)
        expect_equal("10", rows[1].score)

        local raw_rows = lurek.serial.fromCsv("alice,10\nbob,20\n", nil, false)
        expect_true(#raw_rows >= 2)
        expect_not_nil(raw_rows[1][1])

        local tsv = lurek.serial.fromCsv("name\tscore\nalice\t10\nbob\t20\n", "\t", true)
        expect_equal("alice", tsv[1].name)
    end)

    -- @covers lurek.serial.toCsv
    it("toCsv serializes row tables and round-trips them", function()
        expect_type("function", lurek.serial.toCsv)

        local data = {
            { name = "test", value = "42" },
            { name = "next", value = "7" },
        }
        local csv = lurek.serial.toCsv(data)
        expect_type("string", csv)
        expect_true(#csv > 0)

        local back = lurek.serial.fromCsv(csv)
        expect_equal("test", back[1].name)
        expect_equal("42", back[1].value)
    end)
end)

-- @describe lurek.serial MsgPack helpers
describe("lurek.serial MsgPack helpers", function()
    -- @covers lurek.serial.encodeMsgPack
    it("encodeMsgPack serializes tables and rejects unsupported input", function()
        local bytes = lurek.serial.encodeMsgPack({ name = "hero", level = 5 })
        expect_equal("string", type(bytes))
        expect_true(#bytes > 0)

        expect_error(function()
            lurek.serial.encodeMsgPack(nil)
        end)
        expect_error(function()
            lurek.serial.encodeMsgPack("not a table")
        end)
        expect_error(function()
            lurek.serial.encodeMsgPack(42)
        end)
    end)

    -- @covers lurek.serial.decodeMsgPack
    it("decodeMsgPack round-trips structured data and rejects invalid bytes", function()
        local tbl = {
            name = "hero",
            level = 5,
            pos = { x = 10, y = 20 },
            items = { "sword", "shield", "potion" },
        }
        local decoded = lurek.serial.decodeMsgPack(lurek.serial.encodeMsgPack(tbl))
        expect_equal("hero", decoded.name)
        expect_equal(5, decoded.level)
        expect_equal(10, decoded.pos.x)
        expect_equal("shield", decoded.items[2])

        expect_error(function()
            lurek.serial.decodeMsgPack("\xc1\xc1\xc1")
        end)
    end)
end)

-- @describe lurek.serial schema helper
describe("lurek.serial schema helper", function()
    -- @covers lurek.serial.validate
    it("validate enforces type, required, range, length, fields, and items", function()
        local ok, err = lurek.serial.validate("hello", { type = "string" })
        expect_equal(true, ok)
        expect_equal(nil, err)

        ok, err = lurek.serial.validate(42, { type = "string" })
        expect_equal(false, ok)
        expect_type("string", err)

        ok = lurek.serial.validate(nil, { type = "string" })
        expect_equal(true, ok)

        ok, err = lurek.serial.validate(nil, { type = "string", required = true })
        expect_equal(false, ok)
        expect_type("string", err)

        ok = lurek.serial.validate(50, { type = "number", min = 1, max = 100 })
        expect_equal(true, ok)
        ok, err = lurek.serial.validate(101, { type = "number", min = 1, max = 100 })
        expect_equal(false, ok)
        expect_type("string", err)

        ok = lurek.serial.validate("abc", { type = "string", minlen = 1, maxlen = 10 })
        expect_equal(true, ok)
        ok, err = lurek.serial.validate("toolong", { type = "string", maxlen = 3 })
        expect_equal(false, ok)
        expect_type("string", err)

        local table_schema = {
            type = "table",
            fields = {
                name = { type = "string", required = true },
                level = { type = "number", min = 1, max = 100 },
            }
        }
        expect_equal(true, lurek.serial.validate({ name = "hero", level = 5 }, table_schema))
        ok, err = lurek.serial.validate({ level = 5 }, table_schema)
        expect_equal(false, ok)
        expect_type("string", err)

        local list_schema = { type = "table", items = { type = "string" } }
        expect_equal(true, lurek.serial.validate({ "a", "b", "c" }, list_schema))
        ok, err = lurek.serial.validate({ "a", 2, "c" }, list_schema)
        expect_equal(false, ok)
        expect_type("string", err)
    end)
end)

-- @describe lurek.serial XML helper
describe("lurek.serial XML helper", function()
    -- @covers lurek.serial.decodeXml
    it("decodeXml captures tags, text, attrs, children, and malformed input", function()
        local root = lurek.serial.decodeXml('<player id="1" name="hero">ready</player>')
        expect_equal("player", root.tag)
        expect_equal("ready", root.text)
        expect_equal("1", root.attrs.id)
        expect_equal("hero", root.attrs.name)

        local nested = lurek.serial.decodeXml("<items><item>sword</item><item>shield</item></items>")
        expect_equal("items", nested.tag)
        expect_equal(2, #nested.children)
        expect_equal("item", nested.children[1].tag)
        expect_equal("shield", nested.children[2].text)

        local leaf = lurek.serial.decodeXml("<leaf>text</leaf>")
        expect_equal(nil, leaf.children)

        expect_error(function()
            lurek.serial.decodeXml("<unclosed")
        end)
        expect_error(function()
            lurek.serial.decodeXml("<a></b>")
        end)
    end)
end)

-- @describe lurek.serial unified codec helpers
describe("lurek.serial unified codec helpers", function()
    -- @covers lurek.serial.detectFormat
    it("detectFormat identifies known formats and ignores unknown text", function()
        expect_equal("json", lurek.serial.detectFormat('{"name":"hero"}'))
        expect_equal(nil, lurek.serial.detectFormat("hello world"))
    end)

    -- @covers lurek.serial.decode
    it("decode supports auto-detected and explicit formats", function()
        local toml = lurek.serial.decode('title = "demo"')
        expect_equal("demo", toml.title)

        local ini = lurek.serial.decode("[player]\nname=hero\n", "ini")
        expect_equal("hero", ini.player.name)

        local bytes = lurek.serial.encodeMsgPack({ hp = 10 })
        local msgpack = lurek.serial.decode(bytes, "msgpack")
        expect_equal(10, msgpack.hp)

        local patched = lurek.serial.decode('{"name":"hero"}', "json", {
            schema = {
                type = "table",
                fields = {
                    name = { type = "string", required = true },
                    hp = { type = "number", default = 10 },
                },
            },
        })
        expect_equal("hero", patched.name)
        expect_equal(10, patched.hp)

        expect_error(function()
            lurek.serial.decode("title = \"demo\"", nil, {
                allowed_formats = { "json", "toml" },
                max_detect_attempts = 1,
            })
        end)

        expect_error(function()
            lurek.serial.decode("name,score\nada,10\nlin,20\n", "csv", {
                max_rows = 1,
            })
        end)

        expect_error(function()
            lurek.serial.decode("name,score\nada,toolong\n", "csv", {
                max_field_chars = 3,
            })
        end)
    end)

    -- @covers lurek.serial.encode
    it("encode supports json pretty output and csv options", function()
        local json = lurek.serial.encode({ a = 1 }, "json", { pretty = true })
        expect_equal("string", type(json))
        expect_true(#json > 0)

        local rows = {
            { name = "ada", score = "10" },
            { name = "lin", score = "20" },
        }
        local csv = lurek.serial.encode(rows, "csv", { delimiter = ";", has_headers = true })
        expect_true(string.find(csv, ";", 1, true) ~= nil)

        local big = {}
        for i = 1, 20 do
            big[i] = i
        end
        expect_error(function()
            lurek.serial.encode(big, "json", { max_sequence_len = 10 })
        end)

        expect_error(function()
            lurek.serial.encode({
                { name = "ada", payload = { nested = true } },
            }, "csv")
        end)

        local csv_nested = lurek.serial.encode({
            { name = "ada", payload = { nested = true } },
        }, "csv", {
            complex_cells = "json",
        })
        expect_true(string.find(csv_nested, '{"nested":true}', 1, true) ~= nil)
    end)

    -- @covers lurek.serial.applyDefaults
    it("applyDefaults fills missing fields from schema defaults", function()
        local schema = {
            type = "table",
            fields = {
                hp = { type = "number", default = 100 },
                name = { type = "string", default = "hero" },
            },
        }
        local patched = lurek.serial.applyDefaults({}, schema)
        expect_equal(100, patched.hp)
        expect_equal("hero", patched.name)
    end)
end)
end
-- END test_serialize_core_unit.lua

test_summary()
