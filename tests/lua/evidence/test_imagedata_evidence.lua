-- Placeholder evidence suite for imagedata artifacts.

local OUT = "tests/output/imagedata/"

-- @description Placeholder imagedata evidence suite.
describe("evidence: imagedata", function()
    before_each(function()
        ensure_evidence_dir("imagedata")
    end)

    -- @description Placeholder: imagedata evidence cases pending migration.
    pending("imagedata evidence cases pending migration")
end)

test_summary()
