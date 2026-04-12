-- Golden test: math â€” deterministic text output comparison
-- @golden
-- @covers lurek.math.pi
-- @covers lurek.math.sin
-- @covers lurek.math.cos
-- @covers lurek.math.exp
-- @covers lurek.math.sqrt
-- @covers lurek.math.rad

-- @description Covers suite: golden: math Math constants and trig identities.
describe("golden: math Math constants and trig identities", function()
    -- @covers lurek.math.pi
    -- @covers lurek.math.exp
    -- @covers lurek.math.sqrt
    -- @covers lurek.math.rad
    -- @covers lurek.math.sin
    -- @covers lurek.math.cos
    -- @covers expect_evidence_created
    -- @description Writes math_golden.txt with fixed constant values and sin/cos rows for every 45 degrees from 0 through 360, then checks that the evidence file exists.
    it("produces deterministic text output", function()

        local output = {}
        output[#output + 1] = "pi=" .. string.format("%.15f", lurek.math.pi)
        output[#output + 1] = "e=" .. string.format("%.15f", lurek.math.exp(1))
        output[#output + 1] = "sqrt2=" .. string.format("%.15f", lurek.math.sqrt(2))
        for deg = 0, 360, 45 do
            local rad = lurek.math.rad(deg)
            local s = lurek.math.sin(rad)
            local c = lurek.math.cos(rad)
            output[#output + 1] = string.format("deg=%d sin=%.10f cos=%.10f", deg, s, c)
        end
        local text = table.concat(output, "\n") .. "\n"

        local path = evidence_output_dir("math") .. "math_golden.txt"
        ensure_evidence_dir("math")
        local f = io.open(path, "w")
        if f then f:write(text); f:close() end
        expect_evidence_created(path)
    end)

    -- @golden
    -- @covers expect_golden_text_match
    -- @covers expect_golden_file_match
    -- @description Compares math_golden.txt and the additional all_curves_gallery.png and comparison_chart.png artifacts against their committed math golden samples.
    it("matches golden sample", function()
        local evidence = evidence_output_dir("math") .. "math_golden.txt"
        local golden = "tests/lua/golden/samples/math/math_golden.txt"
        expect_golden_text_match(evidence, golden)
            expect_golden_file_match(evidence_output_dir("math") .. "all_curves_gallery.png", "tests/lua/golden/samples/math/all_curves_gallery.png")
        expect_golden_file_match(evidence_output_dir("math") .. "comparison_chart.png", "tests/lua/golden/samples/math/comparison_chart.png")
end)
end)

test_summary()
