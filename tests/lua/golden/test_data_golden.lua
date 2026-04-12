-- Golden test: data â€” deterministic text output comparison
-- @golden
-- @covers lurek.data.encodeJSON

-- @description Covers suite: golden: data JSON/TOML serialization round-trip.
describe("golden: data JSON/TOML serialization round-trip", function()
    -- @covers lurek.data.encodeJSON
    -- @covers expect_evidence_created
    -- @description Writes data_golden.txt containing the JSON encoding of a fixed nested Lua table and checks that the evidence file exists.
    it("produces deterministic text output", function()

        local output = {}
        local tbl = {name = "test", value = 42, nested = {a = 1}}
        local json = lurek.data.encodeJSON(tbl)
        output[#output + 1] = "json=" .. json
        local text = table.concat(output, "\n") .. "\n"

        local path = evidence_output_dir("data") .. "data_golden.txt"
        ensure_evidence_dir("data")
        local f = io.open(path, "w")
        if f then f:write(text); f:close() end
        expect_evidence_created(path)
    end)

    -- @golden
    -- @covers expect_golden_text_match
    -- @description Compares the generated data_golden.txt evidence file against the committed golden text sample for JSON output stability.
    it("matches golden sample", function()
        local evidence = evidence_output_dir("data") .. "data_golden.txt"
        local golden = "tests/lua/golden/samples/data/data_golden.txt"
        expect_golden_text_match(evidence, golden)
    end)
end)

test_summary()
