-- Regression: RelationshipManager:defineType must not panic when the optional
-- default_level argument is omitted or empty. Before the fix, an empty default
-- string tripped a debug_assert in RelationType::new.

-- @description Covers suite: RelationshipManager regression — defineType must not panic on empty default_level.
describe("RelationshipManager regression: empty default_level", function()
    -- @covers lurek.patterns.newRelationshipManager
    -- @covers lurek.patterns.RelationshipManager.defineType
    -- @covers lurek.patterns.RelationshipManager.typeNames
    it("defineType without default_level does not panic", function()
        local rm = lurek.patterns.newRelationshipManager()
        expect_no_error(function()
            rm:defineType("diplomacy", { "war", "neutral", "alliance" })
        end)
        local names = rm:typeNames()
        expect_equal(1, #names)
        expect_equal("diplomacy", names[1])
    end)

    -- @covers lurek.patterns.RelationshipManager.defineType
    it("defineType rejects empty levels table with a Lua error (not a panic)", function()
        local rm = lurek.patterns.newRelationshipManager()
        expect_error(function()
            rm:defineType("bad", {})
        end)
    end)
end)

test_summary()
