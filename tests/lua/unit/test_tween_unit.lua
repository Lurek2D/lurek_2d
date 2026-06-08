-- tests/lua/unit/test_tween_unit.lua
-- Lua-first unit tests for lurek.tween module covering chain construction, playback, and callbacks.

local harness = require("tests.lua.harness")

-- @describe lurek.tween
describe("lurek.tween", function()
    -- @covers lurek.tween.newChain
    it("creates a new tween chain", function()
        local chain = lurek.tween.newChain(false)
        assert_equal("userdata", type(chain))
        assert_equal("LuaTweenChain", chain:type())
    end)

    -- @covers lurek.tween.newChain
    it("creates looping tween chain", function()
        local chain = lurek.tween.newChain(true)
        local is_loop = chain:isLooping()
        assert_equal(true, is_loop)
    end)

    -- Tween sequence methods
    -- @covers lurek.tween.LuaTweenChain.to
    it("adds property tween to chain", function()
        local obj = {x = 0, y = 0}
        local chain = lurek.tween.newChain(false)
        chain:to(obj, {x = 100, y = 50}, 1.0, "linear")
        assert_equal("userdata", type(chain))
    end)

    -- @covers lurek.tween.LuaTweenChain.wait
    it("adds delay step to chain", function()
        local chain = lurek.tween.newChain(false)
        chain:wait(0.5)
        assert_equal("userdata", type(chain))
    end)

    -- @covers lurek.tween.LuaTweenChain.call
    it("adds callback step to chain", function()
        local chain = lurek.tween.newChain(false)
        local called = false
        chain:call(function() called = true end)
        assert_equal("userdata", type(chain))
    end)

    -- Loop control
    -- @covers lurek.tween.LuaTweenChain.loop
    it("sets loop count for chain", function()
        local chain = lurek.tween.newChain(false)
        chain:loop(3)
        assert_equal("userdata", type(chain))
    end)

    -- Callbacks
    -- @covers lurek.tween.LuaTweenChain.onLoop
    it("registers loop callback", function()
        local chain = lurek.tween.newChain(true)
        local count = 0
        chain:onLoop(function() count = count + 1 end)
        assert_equal("userdata", type(chain))
    end)

    -- @covers lurek.tween.LuaTweenChain.onComplete
    it("registers completion callback", function()
        local chain = lurek.tween.newChain(false)
        chain:onComplete(function() end)
        assert_equal("userdata", type(chain))
    end)

    -- Playback control
    -- @covers lurek.tween.LuaTweenChain.start
    it("starts chain playback", function()
        local obj = {x = 0}
        local chain = lurek.tween.newChain(false)
        chain:to(obj, {x = 100}, 1.0)
        chain:start()
        assert_equal(true, chain:isActive())
    end)

    -- @covers lurek.tween.LuaTweenChain.stop
    it("stops chain playback", function()
        local obj = {x = 0}
        local chain = lurek.tween.newChain(false)
        chain:to(obj, {x = 100}, 1.0)
        chain:start()
        chain:stop()
        assert_equal(false, chain:isActive())
    end)

    -- @covers lurek.tween.LuaTweenChain.pause
    it("pauses chain without stopping", function()
        local obj = {x = 0}
        local chain = lurek.tween.newChain(false)
        chain:to(obj, {x = 100}, 1.0)
        chain:start()
        chain:pause()
        assert_equal(false, chain:isActive())
    end)

    -- @covers lurek.tween.LuaTweenChain.resume
    it("resumes paused chain", function()
        local obj = {x = 0}
        local chain = lurek.tween.newChain(false)
        chain:to(obj, {x = 100}, 1.0)
        chain:start()
        chain:pause()
        chain:resume()
        assert_equal(true, chain:isActive())
    end)

    -- State queries
    -- @covers lurek.tween.LuaTweenChain.isComplete
    it("reports completion state", function()
        local chain = lurek.tween.newChain(false)
        local completed = chain:isComplete()
        assert_true(type(completed) == "boolean")
    end)

    -- @covers lurek.tween.LuaTweenChain.isActive
    it("reports active state", function()
        local chain = lurek.tween.newChain(false)
        local active = chain:isActive()
        assert_true(type(active) == "boolean")
    end)

    -- @covers lurek.tween.LuaTweenChain.getProgress
    it("returns current progress 0..1", function()
        local obj = {x = 0}
        local chain = lurek.tween.newChain(false)
        chain:to(obj, {x = 100}, 1.0)
        chain:start()
        local prog = chain:getProgress()
        assert_true(prog >= 0.0 and prog <= 1.0)
    end)

    -- @covers lurek.tween.LuaTweenChain.getIteration
    it("returns current iteration count", function()
        local chain = lurek.tween.newChain(true)
        chain:loop(5)
        chain:start()
        local iter = chain:getIteration()
        assert_equal("number", type(iter))
        assert_true(iter >= 0)
    end)

    -- Update
    -- @covers lurek.tween.LuaTweenChain.update
    it("advances chain by delta time", function()
        local obj = {x = 0}
        local chain = lurek.tween.newChain(false)
        chain:to(obj, {x = 100}, 1.0)
        chain:start()
        chain:update(0.1)
        assert_near(obj.x, 10, 5)  -- Should have moved ~10 units in 0.1s of 1s tween
    end)
end)
test_summary()
