-- Golden test: compute â€” deterministic text output comparison
-- @golden
-- @covers lurek.compute.zeros
-- @covers NdArray:fill
-- @covers NdArray:sum

-- @description Covers suite: golden: compute NdArray deterministic operations.
describe("golden: compute NdArray deterministic operations", function()
    -- @covers lurek.compute.zeros
    -- @covers NdArray:fill
    -- @covers NdArray:sum
    -- @covers expect_evidence_created
    -- @description Writes compute_golden.txt from a fixed 2x3 zero array after filling it with 1.5 and recording the resulting sum.
    it("produces deterministic text output", function()

        local output = {}
        local arr = lurek.compute.zeros(2, 3)
        arr:fill(1.5)
        output[#output + 1] = "shape=2x3"
        output[#output + 1] = "fill_value=1.500000"
        output[#output + 1] = "sum=" .. string.format("%.6f", arr:sum())
        local text = table.concat(output, "\n") .. "\n"

        local path = evidence_output_dir("compute") .. "compute_golden.txt"
        ensure_evidence_dir("compute")
        local f = io.open(path, "w")
        if f then f:write(text); f:close() end
        expect_evidence_created(path)
    end)

    -- @golden
    -- @covers expect_golden_text_match
    -- @description Compares the generated compute_golden.txt evidence file against the committed golden text sample for deterministic NdArray output.
    it("matches golden sample", function()
        local evidence = evidence_output_dir("compute") .. "compute_golden.txt"
        local golden = "tests/lua/golden/samples/compute/compute_golden.txt"
        expect_golden_text_match(evidence, golden)
    end)
end)

test_summary()
