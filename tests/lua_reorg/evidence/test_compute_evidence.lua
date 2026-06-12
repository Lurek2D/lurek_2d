-- Canonical evidence file for lurek.compute data outputs.

local OUT = evidence_output_dir("compute")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

-- @describe Evidence: lurek.compute data outputs
describe("Evidence: lurek.compute data outputs", function()
    before_each(function()
        ensure_evidence_dir("compute")
    end)

    -- @evidence lurek.compute.zeros
    it("writes compute_ndarray_fill_summary.txt", function()
        local arr = lurek.compute.zeros({2, 3})
        arr:fill(1.5)
        local text = table.concat({
            "shape=2x3",
            "fill_value=1.500000",
            "sum=" .. string.format("%.6f", arr:sum()),
        }, "\n")
        write_text(OUT .. "compute_ndarray_fill_summary.txt", text)
    end)
end)
test_summary()
