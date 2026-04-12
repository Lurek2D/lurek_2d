-- Golden test: serial â€” deterministic text output comparison
-- @golden
-- @covers lurek.serial.base64Encode
-- @covers lurek.serial.hexEncode

-- @description Covers suite: golden: serial Encode/decode deterministic output.
describe("golden: serial Encode/decode deterministic output", function()
    -- @covers lurek.serial.base64Encode
    -- @covers lurek.serial.hexEncode
    -- @covers expect_evidence_created
    -- @description Writes serial_golden.txt with the fixed base64 and hex encodings for known input strings, then checks that the evidence file exists.
    it("produces deterministic text output", function()

        local output = {}
        local b64 = lurek.serial.base64Encode("Hello, World!")
        output[#output + 1] = "base64=" .. b64
        local hex = lurek.serial.hexEncode("ABC")
        output[#output + 1] = "hex=" .. hex
        local text = table.concat(output, "\n") .. "\n"

        local path = evidence_output_dir("serial") .. "serial_golden.txt"
        ensure_evidence_dir("serial")
        local f = io.open(path, "w")
        if f then f:write(text); f:close() end
        expect_evidence_created(path)
    end)

    -- @golden
    -- @covers expect_golden_text_match
    -- @description Compares the generated serial_golden.txt evidence file against the committed golden text sample.
    it("matches golden sample", function()
        local evidence = evidence_output_dir("serial") .. "serial_golden.txt"
        local golden = "tests/lua/golden/samples/serial/serial_golden.txt"
        expect_golden_text_match(evidence, golden)
    end)
end)

test_summary()
