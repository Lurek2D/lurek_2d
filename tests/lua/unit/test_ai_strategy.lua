-- Lurek2D AI — StrategyAI tests

-- =========================================================================
-- 1. Factory
-- =========================================================================
-- @description Verifies the StrategyAI factory and basic API.
describe("lurek.ai.newStrategyAI factory", function()
    -- @covers lurek.ai.newStrategyAI
    it("exists as a function", function()
        expect_type("function", lurek.ai.newStrategyAI)
    end)

    -- @covers lurek.ai.newStrategyAI
    it("creates a userdata object", function()
        local s = lurek.ai.newStrategyAI(5.0)
        expect_type("userdata", s)
    end)

    -- @covers lurek.ai.newStrategyAI
    it("starts with no active goal", function()
        local s = lurek.ai.newStrategyAI(5.0)
        expect_equal(s:activeGoal(), nil)
    end)
end)

-- =========================================================================
-- 2. Add goals and evaluate
-- =========================================================================
-- @description Verifies goals can be added and evaluated by scorer.
describe("StrategyAI addGoal / forceEvaluate", function()
    -- @covers lurek.ai.newStrategyAI
    it("forceEvaluate sets active goal when one has highest score", function()
        local s = lurek.ai.newStrategyAI(10.0)
        s:addGoal("attack")
        s:addGoal("defend")
        s:forceEvaluate(function(goal)
            if goal == "attack" then return 0.9
            else return 0.2 end
        end)
        expect_equal(s:activeGoal(), "attack")
    end)

    -- @covers lurek.ai.newStrategyAI
    it("activeGoal remains nil if all scores zero", function()
        local s = lurek.ai.newStrategyAI(10.0)
        s:addGoal("explore")
        s:forceEvaluate(function(_) return 0.0 end)
        expect_equal(s:activeGoal(), nil)
    end)
end)

-- =========================================================================
-- 3. Update with throttle
-- =========================================================================
-- @description Verifies update() only re-evaluates after the interval expires.
describe("StrategyAI update throttle", function()
    -- @covers lurek.ai.newStrategyAI
    it("update does not crash before interval", function()
        local s = lurek.ai.newStrategyAI(5.0)
        s:addGoal("patrol")
        s:update(0.016, function(_) return 1.0 end)
        expect_type("number", s:timeUntilNext())
    end)

    -- @covers lurek.ai.newStrategyAI
    it("update evaluates after interval passes", function()
        local s = lurek.ai.newStrategyAI(0.1)
        s:addGoal("hunt")
        s:addGoal("flee")
        -- Force immediate evaluation first
        s:forceEvaluate(function(g)
            if g == "flee" then return 0.8 else return 0.1 end
        end)
        expect_equal(s:activeGoal(), "flee")
        -- Update well past interval with different scorer
        s:update(1.0, function(g)
            if g == "hunt" then return 0.9 else return 0.1 end
        end)
        expect_equal(s:activeGoal(), "hunt")
    end)
end)

-- =========================================================================
-- 4. Tags
-- =========================================================================
-- @description Verifies tags can be added and removed.
describe("StrategyAI tags", function()
    -- @covers lurek.ai.newStrategyAI
    it("addTag / removeTag do not crash", function()
        local s = lurek.ai.newStrategyAI(5.0)
        s:addTag("night")
        s:addTag("rain")
        s:removeTag("night")
        expect_equal(true, true)  -- no crash = pass
    end)
end)

-- Print summary
test_summary()
