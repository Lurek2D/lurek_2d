-- Placeholder evidence suite for cellular_sand artifacts.

local OUT = "tests/output/cellular_sand/"

-- @description Placeholder cellular_sand evidence suite.
describe("evidence: cellular_sand", function()
    before_each(function()
        ensure_evidence_dir("cellular_sand")
    end)

    -- @description Placeholder: cellular_sand evidence cases pending migration.
    pending("cellular_sand evidence cases pending migration")
end)

test_summary()
