-- Canonical evidence file for lurek.binary data outputs.

local OUT = evidence_output_dir("binary")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

-- @describe Evidence: lurek.binary data outputs
describe("Evidence: lurek.binary data outputs", function()
    before_each(function()
        ensure_evidence_dir("binary")
    end)

    -- @evidence lurek.binary.parseToml
    -- @evidence lurek.binary.encodeToml
    -- @evidence lurek.binary.encode
    it("writes binary_toml_roundtrip_snapshot.toml", function()
        local input = [[
[game]
title = "Test Game"
version = "1.0.0"

[window]
width = 800
height = 600
fullscreen = false

[physics]
gravity_x = 0.0
gravity_y = 9.8
max_bodies = 1000
]]
        local parsed = lurek.binary.parseToml(input)
        local encoded = lurek.binary.encodeToml(parsed)
        write_text(OUT .. "binary_toml_roundtrip_snapshot.toml", encoded)
    end)

    -- @evidence lurek.binary.encode
    it("writes binary_encode_reference_values.txt", function()
        local text = table.concat({
            "base64=" .. lurek.binary.encode("base64", "Lurek2D rocks!"),
            "hex=" .. lurek.binary.encode("hex", "Lurek2D rocks!"),
        }, "\n")
        write_text(OUT .. "binary_encode_reference_values.txt", text)
    end)

    -- @evidence lurek.binary.hash
    it("writes binary_hash_reference_values.txt", function()
        local text = table.concat({
            "md5_hello=" .. lurek.binary.hash("md5", "Hello, Lurek2D!"),
            "sha1_engine=" .. lurek.binary.hash("sha1", "Lurek2D engine test vector"),
            "sha256_hello=" .. lurek.binary.hash("sha256", "Hello, Lurek2D!"),
            "sha512_engine=" .. lurek.binary.hash("sha512", "Lurek2D engine test vector"),
        }, "\n")
        write_text(OUT .. "binary_hash_reference_values.txt", text)
    end)
end)
test_summary()
