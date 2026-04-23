-- Placeholder evidence suite for charts artifacts.

local OUT = "tests/output/charts/"

-- @description Placeholder charts evidence suite.
describe("evidence: charts", function()
    before_each(function()
        ensure_evidence_dir("charts")
    end)

    -- @description Placeholder: charts evidence cases pending migration.
    pending("charts evidence cases pending migration")
end)

test_summary()
