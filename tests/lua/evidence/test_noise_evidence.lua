-- Evidence tests: noise module
-- Output-only evidence from direct lurek.math noise APIs.

local function write_text(path, text)
    local f = io and io.open and io.open(path, "w") or nil
    if f then
        f:write(text)
        f:close()
    end
end

describe("evidence: noise", function()
    before_each(function()
        ensure_evidence_dir("noise")
    end)

    -- @evidence file
    it("exports perlin grid JSON", function()
        local dir = evidence_output_dir("noise")
        local path = dir .. "perlin_grid.json"
        local rows = {}
        for y = 0, 15 do
            local cols = {}
            for x = 0, 15 do
                cols[#cols + 1] = string.format("%.5f", tonumber(lurek.math.perlin2d(x * 0.08, y * 0.08)) or 0)
            end
            rows[#rows + 1] = "[" .. table.concat(cols, ",") .. "]"
        end
        write_text(path, "[" .. table.concat(rows, ",") .. "]")
    end)

    -- @evidence file
    it("exports simplex grid JSON", function()
        local dir = evidence_output_dir("noise")
        local path = dir .. "simplex_grid.json"
        local rows = {}
        for y = 0, 15 do
            local cols = {}
            for x = 0, 15 do
                cols[#cols + 1] = string.format("%.5f", tonumber(lurek.math.simplex2d(x * 0.10, y * 0.10)) or 0)
            end
            rows[#rows + 1] = "[" .. table.concat(cols, ",") .. "]"
        end
        write_text(path, "[" .. table.concat(rows, ",") .. "]")
    end)

    -- @evidence file
    it("exports seeded noise generator samples", function()
        local dir = evidence_output_dir("noise")
        local path = dir .. "seeded_noise.json"
        local ng = lurek.math.newNoiseGenerator(42)

        local rows = {}
        for y = 0, 15 do
            local cols = {}
            for x = 0, 15 do
                cols[#cols + 1] = string.format("%.5f", tonumber(ng:perlin2d(x * 0.12, y * 0.12)) or 0)
            end
            rows[#rows + 1] = "[" .. table.concat(cols, ",") .. "]"
        end
        write_text(path, "[" .. table.concat(rows, ",") .. "]")
    end)
end)

test_summary()
