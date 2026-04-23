-- Placeholder evidence suite for layers artifacts.

local OUT = "tests/output/layers/"

-- @description Placeholder layers evidence suite.
describe("evidence: layers", function()
    before_each(function()
        ensure_evidence_dir("layers")
    end)

    -- @description Placeholder: layers evidence cases pending migration.
    pending("layers evidence cases pending migration")
end)

test_summary()
