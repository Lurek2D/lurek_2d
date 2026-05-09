-- Dialog public API contract tests.
-- This file verifies the current public contract for dialog exposure.

-- @describe dialog namespace contract
describe("dialog namespace contract", function()
    -- @covers lurek.dialog
    it("does not register a public lurek.dialog namespace", function()
        expect_type("table", lurek, "lurek root table")
        expect_nil(lurek.dialog, "lurek.dialog should stay nil until a real public API is implemented")
    end)

    -- @covers lurek.dialog
    it("keeps namespace lookup stable across repeated reads", function()
        local first_read = lurek.dialog
        local second_read = lurek.dialog

        expect_nil(first_read, "first lurek.dialog read should be nil")
        expect_nil(second_read, "second lurek.dialog read should be nil")
    end)
end)

test_summary()
