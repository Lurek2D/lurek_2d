-- Lurek2D AI — TraitProfile tests

-- =========================================================================
-- 1. Factory
-- =========================================================================
-- @description Verifies the TraitProfile factory exists and creates a valid object.
describe("lurek.ai.newTraitProfile factory", function()
    -- @covers lurek.ai.newTraitProfile
    it("exists as a function", function()
        expect_type("function", lurek.ai.newTraitProfile)
    end)

    -- @covers lurek.ai.newTraitProfile
    it("creates a userdata object", function()
        local tp = lurek.ai.newTraitProfile()
        expect_type("userdata", tp)
    end)
end)

-- =========================================================================
-- 2. set / get roundtrip
-- =========================================================================
-- @description Verifies that trait values set via set() are returned by get().
describe("TraitProfile set/get", function()
    -- @covers lurek.ai.newTraitProfile
    it("starts with zero for unknown trait", function()
        local tp = lurek.ai.newTraitProfile()
        expect_near(tp:get("aggression"), 0.0, 0.001)
    end)

    -- @covers lurek.ai.newTraitProfile
    it("returns set value", function()
        local tp = lurek.ai.newTraitProfile()
        tp:set("courage", 0.75)
        expect_near(tp:get("courage"), 0.75, 0.001)
    end)

    -- @covers lurek.ai.newTraitProfile
    it("has() returns false for unset trait", function()
        local tp = lurek.ai.newTraitProfile()
        expect_equal(tp:has("unknown_trait"), false)
    end)

    -- @covers lurek.ai.newTraitProfile
    it("has() returns true after set", function()
        local tp = lurek.ai.newTraitProfile()
        tp:set("loyalty", 0.5)
        expect_equal(tp:has("loyalty"), true)
    end)

    -- @covers lurek.ai.newTraitProfile
    it("traitCount increments after set", function()
        local tp = lurek.ai.newTraitProfile()
        tp:set("a", 0.1)
        tp:set("b", 0.2)
        expect_equal(tp:traitCount(), 2)
    end)
end)

-- =========================================================================
-- 3. Modifiers
-- =========================================================================
-- @description Verifies that timed modifiers alter the effective trait value.
describe("TraitProfile modifiers", function()
    -- @covers lurek.ai.newTraitProfile
    it("modifier raises effective value immediately", function()
        local tp = lurek.ai.newTraitProfile()
        tp:set("fear", 0.2)
        tp:addModifier("fear", 0.5, nil, "poison")
        expect_near(tp:get("fear"), 0.7, 0.01)
    end)

    -- @covers lurek.ai.newTraitProfile
    it("removeModifiers restores base value", function()
        local tp = lurek.ai.newTraitProfile()
        tp:set("fear", 0.2)
        tp:addModifier("fear", 0.5, nil, "poison")
        tp:removeModifiers("poison")
        expect_near(tp:get("fear"), 0.2, 0.01)
    end)

    -- @covers lurek.ai.newTraitProfile
    it("getBase is unchanged by modifier", function()
        local tp = lurek.ai.newTraitProfile()
        tp:set("strength", 0.8)
        tp:addModifier("strength", 0.1, nil, "buff")
        expect_near(tp:getBase("strength"), 0.8, 0.01)
    end)
end)

-- =========================================================================
-- 4. Update / decay
-- =========================================================================
-- @description Verifies that update() ticks the modifier timer and expires timed modifiers.
describe("TraitProfile update", function()
    -- @covers lurek.ai.newTraitProfile
    it("update does not crash with no modifiers", function()
        local tp = lurek.ai.newTraitProfile()
        tp:update(0.016)
        expect_equal(tp:traitCount(), 0)
    end)

    -- @covers lurek.ai.newTraitProfile
    it("timed modifier expires after update", function()
        local tp = lurek.ai.newTraitProfile()
        tp:set("speed", 0.5)
        tp:addModifier("speed", 0.3, 0.001, "boost")  -- expires in 0.001 s
        tp:update(1.0)  -- well past expiry
        expect_near(tp:get("speed"), 0.5, 0.01)
    end)
end)

-- Print summary
test_summary()
