-- Placeholder evidence suite for bezier artifacts.

local OUT = "tests/output/bezier/"

-- @description Placeholder bezier evidence suite.
describe("evidence: bezier", function()
    before_each(function()
        ensure_evidence_dir("bezier")
    end)

    -- @description Placeholder: bezier evidence cases pending migration.
    pending("bezier evidence cases pending migration")
end)

test_summary()
