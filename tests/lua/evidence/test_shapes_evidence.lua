-- Placeholder evidence suite for shapes artifacts.

local OUT = "tests/output/shapes/"

-- @description Placeholder shapes evidence suite.
describe("evidence: shapes", function()
    before_each(function()
        ensure_evidence_dir("shapes")
    end)

    -- @description Placeholder: shapes evidence cases pending migration.
    pending("shapes evidence cases pending migration")
end)

test_summary()
