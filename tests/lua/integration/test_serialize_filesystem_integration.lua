-- Integration: lurek.serialize JSON/TOML/CSV round-trip via lurek.filesystem
-- @describe serialize + filesystem integration

-- @describe serialize + filesystem integration
describe("serialize + filesystem integration", function()
    local tmp = "save/integration_serialize_fs/"

    before_each(function()
        lurek.filesystem.mkdir(tmp)
    end)

    -- @integration lurek.filesystem.read
    -- @integration lurek.filesystem.write
    -- @integration lurek.serialize.fromJson
    -- @integration lurek.serialize.toJson
    -- @integration lurek.filesystem.mkdir
    -- @integration lurek.filesystem.read
    -- @integration lurek.filesystem.write
    -- @integration lurek.serialize.fromCsv
    -- @integration lurek.serialize.fromJson
    -- @integration lurek.serialize.fromToml
    -- @integration lurek.serialize.toJson
    -- @integration lurek.serialize.toToml
    it("round-trips a Lua table through JSON via the filesystem", function()
        local data = { name = "Luna", version = 2, active = true }
        local json_str = lurek.serialize.toJson(data)
        expect_type("string", json_str, "toJson returns string")

        lurek.filesystem.write(tmp .. "data.json", json_str)
        local read_back = lurek.filesystem.read(tmp .. "data.json")
        expect_type("string", read_back, "read returns string")

        local restored = lurek.serialize.fromJson(read_back)
        expect_equal(restored.name, "Luna", "name round-trips through JSON+filesystem")
        expect_equal(restored.version, 2, "number round-trips")
    end)

    -- @integration lurek.filesystem.read
    -- @integration lurek.filesystem.write
    -- @integration lurek.serialize.fromToml
    -- @integration lurek.serialize.toToml
    it("round-trips a Lua table through TOML via the filesystem", function()
        local data = { engine = "lurek2d", revision = 5 }
        local toml_str = lurek.serialize.toToml(data)
        expect_type("string", toml_str, "toToml returns string")

        lurek.filesystem.write(tmp .. "conf.toml", toml_str)
        local read_back = lurek.filesystem.read(tmp .. "conf.toml")
        local restored = lurek.serialize.fromToml(read_back)
        expect_equal(restored.engine, "lurek2d", "string TOML round-trip")
        expect_equal(restored.revision, 5, "number TOML round-trip")
    end)

    -- @integration lurek.filesystem.read
    -- @integration lurek.filesystem.write
    -- @integration lurek.serialize.fromCsv
    it("parses CSV rows from a file written by serial.toCsv", function()
        local rows = { { "x", "y" }, { "1", "2" }, { "3", "4" } }
        local csv_str = rows[1][1] .. "," .. rows[1][2] .. "\n"
                     .. rows[2][1] .. "," .. rows[2][2] .. "\n"
                     .. rows[3][1] .. "," .. rows[3][2] .. "\n"
        lurek.filesystem.write(tmp .. "points.csv", csv_str)
        local read_back = lurek.filesystem.read(tmp .. "points.csv")
        local parsed = lurek.serialize.fromCsv(read_back)
        expect_true(#parsed >= 2, "CSV parse returns at least 2 data rows")
    end)

end)
test_summary()
