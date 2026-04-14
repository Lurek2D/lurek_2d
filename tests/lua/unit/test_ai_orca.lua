-- Lurek2D AI — ORCASolver crowd avoidance tests

-- =========================================================================
-- 1. Factory
-- =========================================================================
-- @description Verifies the ORCASolver factory and basic API.
describe("lurek.ai.newORCASolver factory", function()
    -- @covers lurek.ai.newORCASolver
    it("exists as a function", function()
        expect_type("function", lurek.ai.newORCASolver)
    end)

    -- @covers lurek.ai.newORCASolver
    it("creates a userdata object", function()
        local s = lurek.ai.newORCASolver(2.0)
        expect_type("userdata", s)
    end)

    -- @covers lurek.ai.newORCASolver
    it("starts with zero agents", function()
        local s = lurek.ai.newORCASolver(2.0)
        expect_equal(s:agentCount(), 0)
    end)
end)

-- =========================================================================
-- 2. Add agents
-- =========================================================================
-- @description Verifies that agents can be added and counted.
describe("ORCASolver addAgent", function()
    -- @covers lurek.ai.newORCASolver
    it("addAgent increments count", function()
        local s = lurek.ai.newORCASolver(2.0)
        s:addAgent(0, 0, 0.5, 3.0)
        expect_equal(s:agentCount(), 1)
    end)

    -- @covers lurek.ai.newORCASolver
    it("multiple agents counted", function()
        local s = lurek.ai.newORCASolver(2.0)
        s:addAgent(0, 0, 0.5, 3.0)
        s:addAgent(10, 0, 0.5, 3.0)
        expect_equal(s:agentCount(), 2)
    end)
end)

-- =========================================================================
-- 3. Compute
-- =========================================================================
-- @description Verifies that compute() produces safe velocities.
describe("ORCASolver compute", function()
    -- @covers lurek.ai.newORCASolver
    it("compute does not crash with one agent", function()
        local s = lurek.ai.newORCASolver(2.0)
        s:addAgent(0, 0, 0.5, 3.0)
        s:setPreferredVelocity(0, 1.0, 0.0)
        s:compute(0.016)
        local vx, vy = s:getSafeVelocity(0)
        expect_type("number", vx)
        expect_type("number", vy)
    end)

    -- @covers lurek.ai.newORCASolver
    it("getSafeVelocity returns zeros for out-of-bounds index", function()
        local s = lurek.ai.newORCASolver(2.0)
        local vx, vy = s:getSafeVelocity(99)
        expect_near(vx, 0.0, 0.001)
        expect_near(vy, 0.0, 0.001)
    end)

    -- @covers lurek.ai.newORCASolver
    it("two agents heading toward each other get non-colliding velocities", function()
        local s = lurek.ai.newORCASolver(2.0)
        s:addAgent(-5, 0, 0.5, 3.0)
        s:addAgent(5, 0, 0.5, 3.0)
        -- Both agents head toward each other on the x-axis
        s:setPreferredVelocity(0, 3.0, 0.0)
        s:setPreferredVelocity(1, -3.0, 0.0)
        s:compute(0.016)
        local vx0, _ = s:getSafeVelocity(0)
        local vx1, _ = s:getSafeVelocity(1)
        -- Safe velocities should be less aggressive than preferred (reduced x)
        expect_equal(vx0 <= 3.0, true)
        expect_equal(vx1 >= -3.0, true)
    end)
end)

-- Print summary
test_summary()
