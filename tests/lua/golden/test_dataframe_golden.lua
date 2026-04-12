-- Golden test: dataframe â€” deterministic text output comparison
-- @golden
-- @covers lurek.dataframe.new
-- @covers DataFrame:addColumn
-- @covers DataFrame:sum
-- @covers DataFrame:mean

-- @description Covers suite: golden: dataframe DataFrame deterministic statistics.
describe("golden: dataframe DataFrame deterministic statistics", function()
    -- @covers lurek.dataframe.new
    -- @covers DataFrame:addColumn
    -- @covers DataFrame:sum
    -- @covers DataFrame:mean
    -- @covers expect_evidence_created
    -- @description Writes dataframe_golden.txt with the fixed row count, sum, and mean for a single values column, then checks that the evidence file exists.
    it("produces deterministic text output", function()

        local output = {}
        local df = lurek.dataframe.new()
        df:addColumn("values", {10, 20, 30, 40, 50})
        output[#output + 1] = "row_count=5"
        output[#output + 1] = "sum=" .. string.format("%.6f", df:sum("values"))
        output[#output + 1] = "mean=" .. string.format("%.6f", df:mean("values"))
        local text = table.concat(output, "\n") .. "\n"

        local path = evidence_output_dir("dataframe") .. "dataframe_golden.txt"
        ensure_evidence_dir("dataframe")
        local f = io.open(path, "w")
        if f then f:write(text); f:close() end
        expect_evidence_created(path)
    end)

    -- @golden
    -- @covers expect_golden_text_match
    -- @description Compares the generated dataframe_golden.txt evidence file against the committed golden text sample.
    it("matches golden sample", function()
        local evidence = evidence_output_dir("dataframe") .. "dataframe_golden.txt"
        local golden = "tests/lua/golden/samples/dataframe/dataframe_golden.txt"
        expect_golden_text_match(evidence, golden)
    end)
end)

test_summary()
