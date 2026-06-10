-- tests/lua/unit/test_tween_unit.lua
-- Lua-first unit tests for lurek.tween module covering chain construction, playback, and callbacks.

local harness = require("tests.lua.harness")

-- @describe lurek.tween
describe("lurek.tween", function()
    -- @covers LTweenParallel:typeOf
    it("creates a new tween parallel group with a stable userdata type", function()
        local group = lurek.tween.parallel()
        assert_equal("userdata", type(group))
        assert_true(group:typeOf("LTweenParallel"))
    end)

    -- @covers LTweenSequence:typeOf
    it("creates a new tween sequence with the expected userdata type", function()
        local seq = lurek.tween.sequence()
        assert_equal("userdata", type(seq))
        assert_true(seq:typeOf("LTweenSequence"))
    end)

    -- Tween sequence methods
    -- @covers LTweenChain:to
    it("adds property tween to chain", function()
        local obj = {x = 0, y = 0}
        local chain = lurek.tween.newChain(false)
        chain:to(obj, {x = 100, y = 50}, 1.0, "linear")
        assert_equal("userdata", type(chain))
    end)

    -- @covers LTweenChain:wait
    it("adds delay step to chain", function()
        local chain = lurek.tween.newChain(false)
        chain:wait(0.5)
        assert_equal("userdata", type(chain))
    end)

    -- @covers LTweenChain:call
    it("adds callback step to chain", function()
        local chain = lurek.tween.newChain(false)
        local called = false
        chain:call(function() called = true end)
        assert_equal("userdata", type(chain))
    end)

    -- Loop control
    -- @covers LTweenChain:loop
    it("sets loop count for chain", function()
        local chain = lurek.tween.newChain(false)
        chain:loop(3)
        assert_equal("userdata", type(chain))
    end)

    -- Callbacks
    -- @covers LTweenChain:onLoop
    it("registers loop callback", function()
        local chain = lurek.tween.newChain(true)
        local count = 0
        chain:onLoop(function() count = count + 1 end)
        assert_equal("userdata", type(chain))
    end)

    -- @covers LTweenChain:onComplete
    it("registers completion callback", function()
        local chain = lurek.tween.newChain(false)
        chain:onComplete(function() end)
        assert_equal("userdata", type(chain))
    end)

    -- Playback control
    -- @covers LTweenChain:start
    it("starts chain playback", function()
        local obj = {x = 0}
        local chain = lurek.tween.newChain(false)
        chain:to(obj, {x = 100}, 1.0)
        chain:start()
        assert_equal(true, chain:isActive())
    end)

    -- @covers LTweenChain:stop
    it("stops chain playback", function()
        local obj = {x = 0}
        local chain = lurek.tween.newChain(false)
        chain:to(obj, {x = 100}, 1.0)
        chain:start()
        chain:stop()
        assert_equal(false, chain:isActive())
    end)

    -- @covers LTweenChain:pause
    it("pauses chain without stopping", function()
        local obj = {x = 0}
        local chain = lurek.tween.newChain(false)
        chain:to(obj, {x = 100}, 1.0)
        chain:start()
        lurek.tween.update(0.25)
        local before = chain:getProgress()
        chain:pause()
        lurek.tween.update(0.25)
        assert_near(before, chain:getProgress(), 0.001)
    end)

    -- @covers LTweenChain:resume
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
    -- @covers LTweenChain:isComplete
    it("reports completion state", function()
        local chain = lurek.tween.newChain(false)
        local completed = chain:isComplete()
        assert_true(type(completed) == "boolean")
    end)

    -- @covers LTweenChain:isActive
    it("reports active state", function()
        local chain = lurek.tween.newChain(false)
        local active = chain:isActive()
        assert_true(type(active) == "boolean")
    end)

    -- @covers LTweenChain:getProgress
    it("returns current progress 0..1", function()
        local obj = {x = 0}
        local chain = lurek.tween.newChain(false)
        chain:to(obj, {x = 100}, 1.0)
        chain:start()
        local prog = chain:getProgress()
        assert_true(prog >= 0.0 and prog <= 1.0)
    end)

    -- @covers LTweenChain:getIteration
    it("returns current iteration count", function()
        local chain = lurek.tween.newChain(true)
        chain:loop(5)
        chain:start()
        local iter = chain:getIteration()
        assert_equal("number", type(iter))
        assert_true(iter >= 0)
    end)

    -- Update
    -- @covers LTweenSequence:getProgress
    it("advances a tween sequence and reports normalized progress", function()
        local obj = {x = 0}
        local seq = lurek.tween.sequence()
        seq:tween(1.0, obj, {x = 100})
        seq:start()
        lurek.tween.update(0.1)
        local prog = seq:getProgress()
        assert_true(prog >= 0.0 and prog <= 1.0)
    end)
end)
test_summary()
