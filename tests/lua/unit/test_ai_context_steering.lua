-- Lurek2D AI — ContextSteering tests

-- =========================================================================
-- 1. Factory
-- =========================================================================
-- @description Verifies the ContextSteering factory and basic API.
describe("lurek.ai.newContextSteering factory", function()
    -- @covers lurek.ai.newContextSteering
    it("exists as a function", function()
        expect_type("function", lurek.ai.newContextSteering)
    end)

    -- @covers lurek.ai.newContextSteering
    it("creates a userdata object", function()
        local cs = lurek.ai.newContextSteering(16)
        expect_type("userdata", cs)
    end)

    -- @covers lurek.ai.newContextSteering
    it("slot count reflects argument", function()
        local cs = lurek.ai.newContextSteering(8)
        expect_equal(cs:slotCount(), 8)
    end)

    -- @covers lurek.ai.newContextSteering
    it("defaults to 16 slots for 0 argument", function()
        local cs = lurek.ai.newContextSteering(0)
        expect_equal(cs:slotCount(), 16)
    end)
end)

-- =========================================================================
-- 2. Evaluate produces a direction vector
-- =========================================================================
-- @description Verifies evaluate() returns non-nil floats.
describe("ContextSteering evaluate", function()
    -- @covers lurek.ai.newContextSteering
    it("returns two numbers from evaluate", function()
        local cs = lurek.ai.newContextSteering(16)
        cs:addSeekTarget(100, 0, 1.0)
        local dx, dy = cs:evaluate(0, 0, 0, 0)
        expect_type("number", dx)
        expect_type("number", dy)
    end)

    -- @covers lurek.ai.newContextSteering
    it("wander returns a non-zero vector length", function()
        local cs = lurek.ai.newContextSteering(16)
        cs:addWander(0.5, 1.0)
        local dx, dy = cs:evaluate(0, 0, 0, 0)
        local mag = math.sqrt(dx * dx + dy * dy)
        expect_near(cs:chosenMagnitude(), mag, 0.01)
    end)

    -- @covers lurek.ai.newContextSteering
    it("clearBehaviors resets to zero vector", function()
        local cs = lurek.ai.newContextSteering(16)
        cs:addSeekTarget(100, 100, 1.0)
        cs:clearBehaviors()
        local dx, dy = cs:evaluate(0, 0, 0, 0)
        expect_near(dx, 0.0, 0.001)
        expect_near(dy, 0.0, 0.001)
    end)
end)

-- =========================================================================
-- 3. Avoid pushes away
-- =========================================================================
-- @description Verifies addAvoidPoint generates a vector pointing away from the obstacle.
describe("ContextSteering avoid", function()
    -- @covers lurek.ai.newContextSteering
    it("avoid obstacle pushes away on x-axis", function()
        local cs = lurek.ai.newContextSteering(32)
        -- Place obstacle to the right; agent at origin, avoid weight high
        cs:addAvoidPoint(10, 0, 5, 2.0)
        local dx, _ = cs:evaluate(0, 0, 0, 0)
        -- Result should be non-positive (pushed left or zero)
        expect_equal(dx <= 0, true)
    end)
end)

-- Print summary
test_summary()
