-- Integration: JSON serialization round-trip via filesystem I/O
-- @describe integration: data serialization with filesystem I/O

-- @describe integration: data serialization with filesystem I/O
describe("integration: data serialization with filesystem I/O", function()
    local TMP_PATH = "save/test_binary_fs_tmp.json"

    -- @integration lurek.filesystem.exists
    -- @integration lurek.filesystem.read
    -- @integration lurek.filesystem.remove
    -- @integration lurek.filesystem.write
    -- @integration lurek.serial.fromJson
    -- @integration lurek.serial.toJson
    -- @integration lurek.filesystem.exists
    -- @integration lurek.filesystem.read
    -- @integration lurek.filesystem.remove
    -- @integration lurek.filesystem.write
    -- @integration lurek.serial.fromJson
    -- @integration lurek.serial.toJson
    it("encodes table to JSON, writes, and reads back", function()
        local record = {
            name  = "player1",
            score = 9999,
            level = 7,
        }

        local json_str = lurek.serial.toJson(record)
        expect_type("string", json_str, "encoded to JSON string")
        expect_true(#json_str > 0, "JSON string is non-empty")

        -- Write, read back, and decode in the same it-block so the file persists
        lurek.filesystem.write(TMP_PATH, json_str)

        local exists = lurek.filesystem.exists(TMP_PATH)
        expect_true(exists, "temp file exists after write")

        local content = lurek.filesystem.read(TMP_PATH)
        expect_type("string", content, "file content is string")

        local decoded = lurek.serial.fromJson(content)
        expect_equal("player1", decoded.name,  "name round-tripped")
        expect_equal(9999,      decoded.score, "score round-tripped")
        expect_equal(7,         decoded.level, "level round-tripped")

        lurek.filesystem.remove(TMP_PATH)
        expect_false(lurek.filesystem.exists(TMP_PATH), "temp file is removed after round-trip")
    end)

end)
test_summary()
