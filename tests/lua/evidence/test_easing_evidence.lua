-- Placeholder evidence suite for easing artifacts.

local OUT = "tests/output/easing/"

-- @description Placeholder easing evidence suite.
describe("evidence: easing", function()
    before_each(function()
        ensure_evidence_dir("easing")
    end)

    -- @description Placeholder: easing evidence cases pending migration.
    pending("easing evidence cases pending migration")
end)

test_summary()
