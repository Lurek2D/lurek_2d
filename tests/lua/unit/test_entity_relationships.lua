-- Lurek2D Lua BDD tests for lurek.patterns.newRelationshipManager
-- Headless: no GPU, no audio, no window.

-- @description Covers suite: lurek.patterns RelationshipManager.
describe("lurek.patterns.RelationshipManager", function()
    -- @covers lurek.patterns.newRelationshipManager
    -- @covers lurek.patterns.RelationshipManager.setValue
    -- @covers lurek.patterns.RelationshipManager.getValue
    -- @description Verifies basic numeric relationship storage.
    it("stores and retrieves numeric values between entity pairs", function()
        local rm = lurek.patterns.newRelationshipManager()
        local a, b = 1, 2
        rm:setValue(a, b, 75.0)
        expect_near(75.0, rm:getValue(a, b), 1e-5)
    end)

    -- @covers lurek.patterns.RelationshipManager.adjustValue
    -- @description Verifies that adjustValue changes the stored value by the delta.
    it("adjustValue changes the value by delta", function()
        local rm = lurek.patterns.newRelationshipManager()
        rm:setValue(1, 2, 50.0)
        rm:adjustValue(1, 2, -10.0)
        expect_near(40.0, rm:getValue(1, 2), 1e-5)
    end)

    -- @covers lurek.patterns.RelationshipManager.defineType
    -- @covers lurek.patterns.RelationshipManager.setLevel
    -- @covers lurek.patterns.RelationshipManager.getLevel
    -- @description Verifies that named relationship levels can be defined and retrieved.
    it("supports named relationship type levels", function()
        local rm = lurek.patterns.newRelationshipManager()
        rm:defineType("Faction", {"enemy", "neutral", "ally"}, "neutral")
        local ok = rm:setLevel(1, 2, "Faction", "ally")
        expect_equal(true, ok)
        expect_equal("ally", rm:getLevel(1, 2, "Faction"))
    end)

    -- @covers lurek.patterns.RelationshipManager.removePair
    -- @covers lurek.patterns.RelationshipManager.pairCount
    -- @description Verifies that removePair removes both numeric and level data.
    it("removePair resets to defaults and decrements pairCount", function()
        local rm = lurek.patterns.newRelationshipManager()
        rm:setValue(1, 2, 100.0)
        expect_equal(1, rm:pairCount())
        rm:removePair(1, 2)
        expect_equal(0, rm:pairCount())
        expect_near(0.0, rm:getValue(1, 2), 1e-5)
    end)

    -- @covers lurek.patterns.RelationshipManager.typeNames
    -- @description Verifies that typeNames returns all defined relationship type names.
    it("typeNames returns all defined type names", function()
        local rm = lurek.patterns.newRelationshipManager()
        rm:defineType("Friendship", {"stranger","friend","bestfriend"})
        rm:defineType("Faction", {"enemy","ally"})
        local names = rm:typeNames()
        expect_equal(2, #names)
    end)
end)
test_summary()
