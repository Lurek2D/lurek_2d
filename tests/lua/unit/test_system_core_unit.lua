-- Lurek2D system API Tests

-- =========================================================================
-- =========================================================================

-- @describe lurek.runtime.runBatch
describe("lurek.runtime.runBatch", function()
    -- @covers lurek.runtime.runBatch
    it("runBatch with single task returns results table", function()
        local results = lurek.runtime.runBatch({
            task_a = function() return true end
        })
        expect_type("table", results)
    end)

    -- @covers lurek.runtime.getBatchResults
    it("getBatchResults returns pass/fail/skip counts", function()
        local results = lurek.runtime.runBatch({
            t1 = function() return true end,
            t2 = function() return true end
        })
        local passed, failed, skipped = lurek.runtime.getBatchResults(results)
        expect_type("number", passed)
        expect_type("number", failed)
        expect_type("number", skipped)
        expect_true(passed >= 0, "passed must be non-negative")
        expect_true(failed >= 0, "failed must be non-negative")
    end)
end)
test_summary()
