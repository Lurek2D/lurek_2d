-- Placeholder evidence suite for canvas artifacts.

local OUT = "tests/output/canvas/"

-- @description Placeholder canvas evidence suite.
describe("evidence: canvas", function()
    before_each(function()
        ensure_evidence_dir("canvas")
    end)

    -- @description Placeholder: canvas evidence cases pending migration.
    pending("canvas evidence cases pending migration")
end)

test_summary()
