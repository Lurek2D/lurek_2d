-- Placeholder evidence suite for noise artifacts.

local OUT = "tests/output/noise/"

-- @description Placeholder noise evidence suite.
describe("evidence: noise", function()
    before_each(function()
        ensure_evidence_dir("noise")
    end)

    -- @description Placeholder: noise evidence cases pending migration.
    pending("noise evidence cases pending migration")
end)

test_summary()
