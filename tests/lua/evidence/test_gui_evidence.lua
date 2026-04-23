-- Placeholder evidence suite for gui artifacts.

local OUT = "tests/output/gui/"

-- @description Placeholder gui evidence suite.
describe("evidence: gui", function()
    before_each(function()
        ensure_evidence_dir("gui")
    end)

    -- @description Placeholder: gui evidence cases pending migration.
    pending("gui evidence cases pending migration")
end)

test_summary()
