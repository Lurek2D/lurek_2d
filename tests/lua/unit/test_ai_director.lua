-- Lurek2D AI — AIDirector pacing tests

-- =========================================================================
-- 1. Factory
-- =========================================================================
-- @description Verifies the AIDirector factory and basic API.
describe("lurek.ai.newAIDirector factory", function()
    -- @covers lurek.ai.newAIDirector
    it("exists as a function", function()
        expect_type("function", lurek.ai.newAIDirector)
    end)

    -- @covers lurek.ai.newAIDirector
    it("creates a userdata object", function()
        local d = lurek.ai.newAIDirector()
        expect_type("userdata", d)
    end)

    -- @covers lurek.ai.newAIDirector
    it("starts with zero tension", function()
        local d = lurek.ai.newAIDirector()
        expect_near(d:tension(), 0.0, 0.001)
    end)

    -- @covers lurek.ai.newAIDirector
    it("starts in Relief phase", function()
        local d = lurek.ai.newAIDirector()
        expect_equal(d:phase(), "Relief")
    end)
end)

-- =========================================================================
-- 2. pushEvent raises tension
-- =========================================================================
-- @description Verifies that pushEvent() increases tension.
describe("AIDirector pushEvent", function()
    -- @covers lurek.ai.newAIDirector
    it("pushEvent raises tension", function()
        local d = lurek.ai.newAIDirector()
        d:pushEvent(0.8)
        expect_equal(d:tension() > 0.0, true)
    end)

    -- @covers lurek.ai.newAIDirector
    it("tension does not exceed 1.0", function()
        local d = lurek.ai.newAIDirector()
        for i = 1, 50 do d:pushEvent(1.0) end
        expect_equal(d:tension() <= 1.0, true)
    end)
end)

-- =========================================================================
-- 3. Update advances phase
-- =========================================================================
-- @description Verifies that update() transitions through phases.
describe("AIDirector update", function()
    -- @covers lurek.ai.newAIDirector
    it("update does not crash", function()
        local d = lurek.ai.newAIDirector()
        d:pushEvent(1.0)
        d:update(0.1)
        expect_type("string", d:phase())
    end)

    -- @covers lurek.ai.newAIDirector
    it("spawnRateFactor returns a number", function()
        local d = lurek.ai.newAIDirector()
        expect_type("number", d:spawnRateFactor())
    end)

    -- @covers lurek.ai.newAIDirector
    it("lootFactor returns a number", function()
        local d = lurek.ai.newAIDirector()
        expect_type("number", d:lootFactor())
    end)

    -- @covers lurek.ai.newAIDirector
    it("ambientIntensity returns a number", function()
        local d = lurek.ai.newAIDirector()
        expect_type("number", d:ambientIntensity())
    end)
end)

-- =========================================================================
-- 4. Reset
-- =========================================================================
-- @description Verifies that reset() restores zero tension.
describe("AIDirector reset", function()
    -- @covers lurek.ai.newAIDirector
    it("reset clears tension", function()
        local d = lurek.ai.newAIDirector()
        d:pushEvent(1.0)
        d:reset()
        expect_near(d:tension(), 0.0, 0.001)
    end)

    -- @covers lurek.ai.newAIDirector
    it("setTension changes tension directly", function()
        local d = lurek.ai.newAIDirector()
        d:setTension(0.5)
        expect_near(d:tension(), 0.5, 0.01)
    end)
end)

-- Print summary
test_summary()
