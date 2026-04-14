-- Lurek2D AI — EmotionModel tests

-- =========================================================================
-- 1. Factory
-- =========================================================================
-- @description Verifies the EmotionModel factory and basic API.
describe("lurek.ai.newEmotionModel factory", function()
    -- @covers lurek.ai.newEmotionModel
    it("exists as a function", function()
        expect_type("function", lurek.ai.newEmotionModel)
    end)

    -- @covers lurek.ai.newEmotionModel
    it("creates a userdata object", function()
        local em = lurek.ai.newEmotionModel()
        expect_type("userdata", em)
    end)
end)

-- =========================================================================
-- 2. Add emotions
-- =========================================================================
-- @description Verifies emotions can be added and queried.
describe("EmotionModel add/query", function()
    -- @covers lurek.ai.newEmotionModel
    it("dominant returns nil when empty", function()
        local em = lurek.ai.newEmotionModel()
        expect_equal(em:dominant(), nil)
    end)

    -- @covers lurek.ai.newEmotionModel
    it("get returns 0 for unknown emotion", function()
        local em = lurek.ai.newEmotionModel()
        expect_near(em:get("anger"), 0.0, 0.001)
    end)

    -- @covers lurek.ai.newEmotionModel
    it("trigger raises emotion value", function()
        local em = lurek.ai.newEmotionModel()
        em:add("fear", 0.0, 0.5, 0.1)
        em:trigger("fear", 0.8)
        expect_equal(em:get("fear") > 0.0, true)
    end)

    -- @covers lurek.ai.newEmotionModel
    it("isActive returns false before trigger", function()
        local em = lurek.ai.newEmotionModel()
        em:add("joy", 0.0, 0.3, 0.2)
        expect_equal(em:isActive("joy"), false)
    end)

    -- @covers lurek.ai.newEmotionModel
    it("isActive returns true after strong trigger", function()
        local em = lurek.ai.newEmotionModel()
        em:add("joy", 0.0, 0.3, 0.2)
        em:trigger("joy", 0.9)
        expect_equal(em:isActive("joy"), true)
    end)
end)

-- =========================================================================
-- 3. Dominant
-- =========================================================================
-- @description Verifies dominant() returns the strongest emotion.
describe("EmotionModel dominant", function()
    -- @covers lurek.ai.newEmotionModel
    it("dominant returns the triggered emotion when only one", function()
        local em = lurek.ai.newEmotionModel()
        em:add("rage", 0.0, 0.2, 0.1)
        em:trigger("rage", 1.0)
        expect_equal(em:dominant(), "rage")
    end)
end)

-- =========================================================================
-- 4. Decay and reset
-- =========================================================================
-- @description Verifies update() decays emotions and reset() clears them.
describe("EmotionModel update/reset", function()
    -- @covers lurek.ai.newEmotionModel
    it("update does not crash", function()
        local em = lurek.ai.newEmotionModel()
        em:update(0.016)
        expect_equal(em:dominant(), nil)
    end)

    -- @covers lurek.ai.newEmotionModel
    it("reset brings emotions to resting level", function()
        local em = lurek.ai.newEmotionModel()
        em:add("dread", 0.0, 0.5, 0.1)
        em:trigger("dread", 1.0)
        em:reset()
        expect_near(em:get("dread"), 0.0, 0.01)
    end)
end)

-- Print summary
test_summary()
