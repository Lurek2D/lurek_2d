-- Lurek2D Lua BDD tests for lurek.patterns.newStrategy
-- Headless: no GPU, no audio, no window.

-- @description Covers suite: lurek.patterns Strategy.
describe("lurek.patterns.Strategy", function()
    -- @covers lurek.patterns.newStrategy
    -- @covers lurek.patterns.Strategy.register
    -- @covers lurek.patterns.Strategy.set
    -- @covers lurek.patterns.Strategy.execute
    -- @description Verifies that register+set+execute calls the registered function.
    it("register, set, and execute calls the strategy function", function()
        local s = lurek.patterns.newStrategy()
        local called = false
        s:register("run", function() called = true end)
        s:set("run")
        s:execute()
        expect_equal(true, called)
    end)

    -- @covers lurek.patterns.Strategy.getCurrent
    -- @description Verifies that getCurrent returns the active strategy name.
    it("getCurrent returns the active strategy name", function()
        local s = lurek.patterns.newStrategy()
        s:register("patrol", function() end)
        expect_equal(nil, s:getCurrent())
        s:set("patrol")
        expect_equal("patrol", s:getCurrent())
    end)

    -- @covers lurek.patterns.Strategy.has
    -- @description Verifies that has returns true for registered strategies and false otherwise.
    it("has returns true for registered names and false for unknown", function()
        local s = lurek.patterns.newStrategy()
        s:register("attack", function() end)
        expect_equal(true, s:has("attack"))
        expect_equal(false, s:has("retreat"))
    end)

    -- @covers lurek.patterns.Strategy.remove
    -- @description Verifies that remove unregisters a strategy and clears current if it was active.
    it("remove unregisters a strategy", function()
        local s = lurek.patterns.newStrategy()
        s:register("idle", function() end)
        s:set("idle")
        local ok = s:remove("idle")
        expect_equal(true, ok)
        expect_equal(false, s:has("idle"))
        expect_equal(nil, s:getCurrent())
    end)

    -- @covers lurek.patterns.Strategy.names
    -- @description Verifies that names returns all registered strategy names.
    it("names returns all registered names", function()
        local s = lurek.patterns.newStrategy()
        s:register("walk", function() end)
        s:register("sprint", function() end)
        s:register("crouch", function() end)
        local names = s:names()
        expect_equal(3, #names)
    end)

    -- @covers lurek.patterns.Strategy.execute
    -- @description Verifies that execute passes arguments to the strategy function.
    it("execute passes arguments to the strategy function", function()
        local s = lurek.patterns.newStrategy()
        local got_dt = nil
        s:register("move", function(dt) got_dt = dt end)
        s:set("move")
        s:execute(0.016)
        expect_near(0.016, got_dt, 1e-6)
    end)

    -- @covers lurek.patterns.Strategy.clear
    -- @description Verifies that clear removes all strategies and resets current.
    it("clear removes all strategies", function()
        local s = lurek.patterns.newStrategy()
        s:register("a", function() end)
        s:register("b", function() end)
        s:set("a")
        s:clear()
        expect_equal(0, #s:names())
        expect_equal(nil, s:getCurrent())
    end)
end)
test_summary()
