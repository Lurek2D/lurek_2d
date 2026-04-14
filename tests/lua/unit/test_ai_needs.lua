-- Lurek2D AI — NeedSystem tests

-- =========================================================================
-- 1. Factory
-- =========================================================================
-- @description Verifies the NeedSystem factory and basic API.
describe("lurek.ai.newNeedSystem factory", function()
    -- @covers lurek.ai.newNeedSystem
    it("exists as a function", function()
        expect_type("function", lurek.ai.newNeedSystem)
    end)

    -- @covers lurek.ai.newNeedSystem
    it("creates a userdata object", function()
        local ns = lurek.ai.newNeedSystem()
        expect_type("userdata", ns)
    end)
end)

-- =========================================================================
-- 2. Add needs
-- =========================================================================
-- @description Verifies that needs can be added and queried.
describe("NeedSystem add/query", function()
    -- @covers lurek.ai.newNeedSystem
    it("mostUrgent returns nil when empty", function()
        local ns = lurek.ai.newNeedSystem()
        expect_equal(ns:mostUrgent(), nil)
    end)

    -- @covers lurek.ai.newNeedSystem
    it("valueOf returns 1.0 for new needs (full by default)", function()
        local ns = lurek.ai.newNeedSystem()
        ns:addNeed("hunger", 0.1, 0.3, 2.0)
        expect_near(ns:valueOf("hunger"), 1.0, 0.001)
    end)

    -- @covers lurek.ai.newNeedSystem
    it("valueOf returns 0 for unknown need", function()
        local ns = lurek.ai.newNeedSystem()
        expect_near(ns:valueOf("unknown"), 0.0, 0.001)
    end)
end)

-- =========================================================================
-- 3. Decay
-- =========================================================================
-- @description Verifies that needs decay over time.
describe("NeedSystem update/decay", function()
    -- @covers lurek.ai.newNeedSystem
    it("update does not crash with empty system", function()
        local ns = lurek.ai.newNeedSystem()
        ns:update(0.016)
        expect_equal(ns:mostUrgent(), nil)
    end)

    -- @covers lurek.ai.newNeedSystem
    it("hunger decays after large dt", function()
        local ns = lurek.ai.newNeedSystem()
        ns:addNeed("hunger", 1.0, 0.3, 2.0)   -- fast decay
        ns:update(0.8)                           -- should reduce value
        expect_equal(ns:valueOf("hunger") < 1.0, true)
    end)
end)

-- =========================================================================
-- 4. Satisfy
-- =========================================================================
-- @description Verifies that satisfy() increases need value.
describe("NeedSystem satisfy", function()
    -- @covers lurek.ai.newNeedSystem
    it("satisfy increases value", function()
        local ns = lurek.ai.newNeedSystem()
        ns:addNeed("hunger", 1.0, 0.3, 2.0)
        ns:update(1.0)  -- deplete first
        local before = ns:valueOf("hunger")
        ns:satisfy("hunger", 0.5)
        expect_equal(ns:valueOf("hunger") > before, true)
    end)
end)

-- =========================================================================
-- 5. Most urgent
-- =========================================================================
-- @description Verifies mostUrgent returns the name of the most depleted need.
describe("NeedSystem mostUrgent", function()
    -- @covers lurek.ai.newNeedSystem
    it("returns the name of the urgent need when depleted", function()
        local ns = lurek.ai.newNeedSystem()
        ns:addNeed("sleep", 0.1, 0.8, 3.0)
        ns:update(10.0)  -- deplete completely
        local urgent = ns:mostUrgent()
        -- The one need should become urgent
        expect_type("string", urgent)
    end)
end)

-- Print summary
test_summary()
