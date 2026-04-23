-- Placeholder evidence suite for geometry artifacts.

local OUT = "tests/output/geometry/"

-- @description Placeholder geometry evidence suite.
describe("evidence: geometry", function()
    before_each(function()
        ensure_evidence_dir("geometry")
    end)

    -- @description Placeholder: geometry evidence cases pending migration.
    pending("geometry evidence cases pending migration")
end)

test_summary()
