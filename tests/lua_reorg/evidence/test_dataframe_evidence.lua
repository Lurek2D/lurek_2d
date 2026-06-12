-- Canonical evidence file for lurek.dataframe data outputs.

local OUT = evidence_output_dir("dataframe")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

-- @describe Evidence: lurek.dataframe data outputs
describe("Evidence: lurek.dataframe data outputs", function()
    before_each(function()
        ensure_evidence_dir("dataframe")
    end)

    -- @evidence lurek.dataframe.fromCSV
    it("writes dataframe_csv_statistics.txt", function()
        local df = lurek.dataframe.fromCSV("values\n10\n20\n30\n40\n50")
        local text = table.concat({
            "row_count=5",
            "sum=" .. string.format("%.6f", df:sum("values")),
            "mean=" .. string.format("%.6f", df:mean("values")),
        }, "\n")
        write_text(OUT .. "dataframe_csv_statistics.txt", text)
    end)
end)
test_summary()
