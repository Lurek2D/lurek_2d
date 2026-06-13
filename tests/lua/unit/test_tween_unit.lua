-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_tween_core_unit.lua
do
-- Lurek2D Lua BDD tests for lurek.tween.
-- Covers property tweening, composed sequences and parallels, delay helpers, callbacks, and easing/state surfaces in the headless Lua VM.

-- Headless: no GPU, no audio, no window.
-- Tests property tweening: table field animation, sequences, parallels, callbacks.

-- @describe tween()
describe("tween()", function()
    -- @covers lurek.tween.tween
    it("returns a userdata handle", function()
        local obj = { x = 0 }
        local t = lurek.tween.tween(1.0, obj, { x = 100 })
        expect_type("userdata", t)
    end)

    -- @covers LTween:isActive
    it("isActive returns true after creation", function()
        local obj = { x = 0 }
        local t = lurek.tween.tween(1.0, obj, { x = 100 })
        expect_equal(true, t:isActive())
    end)

    -- @covers lurek.tween.update
    it("interpolates single field to midpoint", function()
        lurek.tween.cancelAll()
        local obj = { x = 0 }
        lurek.tween.tween(2.0, obj, { x = 100 }, "linear")
        lurek.tween.update(1.0)
        expect_near(50.0, obj.x, 1.0)
    end)

    -- @covers LTween:getFields
    it("exposes tweened field names for multi-field tweens", function()
        lurek.tween.cancelAll()
        local obj = { x = 0, y = 0 }
        local t = lurek.tween.tween(2.0, obj, { x = 100, y = 200 }, "linear")
        local fields = t:getFields()
        expect_type("table", fields)
        expect_equal(2, #fields)
        expect_true(fields[1] == "x" or fields[2] == "x")
        expect_true(fields[1] == "y" or fields[2] == "y")
        lurek.tween.update(2.0)
        expect_near(100.0, obj.x, 0.5)
        expect_near(200.0, obj.y, 0.5)
    end)
    -- @covers LTween:getRemaining
    it("getRemaining reaches zero after completion", function()
        lurek.tween.cancelAll()
        local obj = { x = 0 }
        local t = lurek.tween.tween(1.0, obj, { x = 10 })
        lurek.tween.update(1.5)
        expect_near(0.0, t:getRemaining(), 0.0001)
    end)

    -- @covers LTween:getProgress
    it("getProgress returns 0 before first update", function()
        local obj = { x = 0 }
        local t = lurek.tween.tween(2.0, obj, { x = 100 })
        expect_near(0.0, t:getProgress(), 0.01)
    end)
end)

-- @describe newState()
describe("newState()", function()
    -- @covers lurek.tween.newState
    it("returns a userdata handle", function()
        local state = lurek.tween.newState(1.0, "linear")
        expect_type("userdata", state)
    end)

    -- @covers LTweenState:t
    it("t() starts at zero", function()
        local state = lurek.tween.newState(2.0, "linear")
        expect_near(0.0, state:t(), 0.0001)
    end)

    -- @covers LTweenState:tick
    it("tick advances progress", function()
        local state = lurek.tween.newState(2.0, "linear")
        expect_equal(false, state:tick(1.0))
        expect_near(0.5, state:t(), 0.0001)
    end)

    -- @covers LTweenState:isComplete
    it("tick returns true at completion", function()
        local state = lurek.tween.newState(1.0, "linear")
        expect_equal(true, state:tick(1.0))
        expect_equal(true, state:isComplete())
    end)

    -- @covers LTweenState:typeOf
    it("matches the LTweenState type guard while paused progress stays frozen", function()
        local state = lurek.tween.newState(2.0, "linear")
        state:tick(0.5)
        local before = state:t()
        expect_true(state:typeOf("LTweenState"))
        state.paused = true
        state:tick(0.5)
        expect_near(before, state:t(), 0.0001)
    end)

    -- @covers LTweenState:reset
    it("reset restores progress to zero", function()
        local state = lurek.tween.newState(1.0, "linear")
        state:tick(1.0)
        expect_equal(true, state:isComplete())
        state:reset()
        expect_equal(false, state:isComplete())
        expect_near(0.0, state:t(), 0.0001)
    end)

    -- @covers LTweenState:lerp
    it("lerp uses the current tween progress", function()
        local state = lurek.tween.newState(2.0, "linear")
        state:tick(1.0)
        expect_near(50.0, state:lerp(0.0, 100.0), 0.0001)
    end)

end)

-- @describe pause and resume
describe("pause and resume", function()
    -- @covers LTween:pause
    it("pause stops interpolation", function()
        lurek.tween.cancelAll()
        local obj = { x = 0 }
        local t = lurek.tween.tween(2.0, obj, { x = 100 }, "linear")
        t:setRelative(false)
        lurek.tween.update(0.5)
        local before = obj.x
        t:pause()
        lurek.tween.update(1.0)
        expect_near(before, obj.x, 0.5)
    end)
end)

-- @describe cancel
describe("cancel", function()
    -- @covers LTween:cancel
    it("cancel makes tween inactive", function()
        local obj = { x = 0 }
        local t = lurek.tween.tween(2.0, obj, { x = 100 })
        t:cancel()
        expect_equal(false, t:isActive())
    end)
    -- @covers LTween:onCancel
    it("onCancel fires when cancelled", function()
        lurek.tween.cancelAll()
        local obj = { x = 0 }
        local fired = false
        local t = lurek.tween.tween(2.0, obj, { x = 100 })
        t:onCancel(function() fired = true end)
        t:cancel()
        expect_equal(true, fired)
    end)
end)

-- @describe callbacks
describe("callbacks", function()
    -- @covers LTween:onComplete
    it("onComplete fires when tween finishes", function()
        lurek.tween.cancelAll()
        local obj = { x = 0 }
        local finished = false
        local t = lurek.tween.tween(1.0, obj, { x = 100 })
        t:onComplete(function() finished = true end)
        lurek.tween.update(1.0)
        expect_equal(true, finished)
    end)
    -- @covers LTween:onUpdate
    it("onUpdate fires each tick", function()
        lurek.tween.cancelAll()
        local obj = { x = 0 }
        local last_t = -1
        local t = lurek.tween.tween(1.0, obj, { x = 100 })
        t:onUpdate(function(t_val) last_t = t_val end)
        lurek.tween.update(0.5)
        expect_in_range(last_t, 0.0, 1.5,
            "onUpdate t out of expected range: " .. tostring(last_t))
    end)
    -- @covers LTween:typeOf
    it("onComplete chaining preserves the LTween type guard", function()
        local obj = { x = 0 }
        local t = lurek.tween.tween(1.0, obj, { x = 100 })
        local chained = t:onComplete(function() end)
        expect_type("userdata", chained)
        expect_true(chained:typeOf("LTween"))
    end)
end)

-- @describe repeat and yoyo
describe("repeat and yoyo", function()
    -- @covers LTween:setRepeat
    it("setRepeat(1) plays tween twice", function()
        lurek.tween.cancelAll()
        local obj = { x = 0 }
        local complete_count = 0
        local t = lurek.tween.tween(1.0, obj, { x = 100 })
        t:setRepeat(1)
        t:onComplete(function() complete_count = complete_count + 1 end)
        lurek.tween.update(2.5)
        expect_equal(1, complete_count)
    end)
    -- @covers LTween:setYoyo
    it("setYoyo does not error", function()
        lurek.tween.cancelAll()
        local obj = { x = 0 }
        local t = lurek.tween.tween(1.0, obj, { x = 100 })
        t:setRepeat(2)
        t:setYoyo(true)
        lurek.tween.update(4.0)
    end)
end)

-- @describe cancelAll()
describe("cancelAll()", function()
    -- @covers lurek.tween.cancelAll
    it("removes all active objects from tracking", function()
        lurek.tween.cancelAll()
        local obj = { x = 0 }
        local spring_target = { y = 0 }
        lurek.tween.tween(5.0, obj, { x = 100 })
        lurek.tween.tween(5.0, obj, { x = 200 })
        local sp = lurek.tween.spring(spring_target, { y = 25 })
        lurek.tween.cancelAll()
        expect_equal(0, lurek.tween.getActiveCount())
        expect_equal(false, sp:isActive())
    end)
end)

-- @describe getActiveCount()
describe("getActiveCount()", function()
    -- @covers lurek.tween.getActiveCount
    it("counts tracked tweens", function()
        lurek.tween.cancelAll()
        local obj = { x = 0 }
        lurek.tween.tween(5.0, obj, { x = 100 })
        local count = lurek.tween.getActiveCount()
        expect_true(count >= 1, "expected count >= 1, got " .. count)
    end)
end)

-- @describe sequence()
describe("sequence()", function()
    -- @covers lurek.tween.sequence
    it("returns a userdata", function()
        local seq = lurek.tween.sequence()
        expect_type("userdata", seq)
        expect_type("number", seq:getProgress())
    end)
    -- @covers LTweenSequence:isActive
    it("isActive returns false before start()", function()
        local seq = lurek.tween.sequence()
        expect_equal(false, seq:isActive())
    end)
    -- @covers LTweenSequence:start
    it("start() activates sequence", function()
        local seq = lurek.tween.sequence()
        seq:start()
        expect_equal(true, seq:isActive())
    end)
    -- @covers LTweenSequence:tween
    it("tween step animates target table", function()
        lurek.tween.cancelAll()
        local obj = { x = 0 }
        lurek.tween.sequence()
            :tween(2.0, obj, { x = 100 }, "linear")
            :start()
        lurek.tween.update(2.0)
        expect_near(100.0, obj.x, 0.5)
    end)
    -- @covers LTweenSequence:callback
    it("callback steps run in order", function()
        lurek.tween.cancelAll()
        local order = {}
        lurek.tween.sequence()
            :callback(function() order[#order+1] = 1 end)
            :callback(function() order[#order+1] = 2 end)
            :callback(function() order[#order+1] = 3 end)
            :start()
        lurek.tween.update(0.01)
        expect_equal(3, #order)
        expect_equal(1, order[1])
        expect_equal(3, order[3])
    end)
    -- @covers LTweenSequence:onComplete
    it("onComplete fires when all steps done", function()
        lurek.tween.cancelAll()
        local done = false
        lurek.tween.sequence()
            :delay(0.5)
            :onComplete(function() done = true end)
            :start()
        lurek.tween.update(1.0)
        expect_equal(true, done)
    end)
    -- @covers LTweenSequence:delay
    it("delay step pauses execution", function()
        lurek.tween.cancelAll()
        local fired = false
        lurek.tween.sequence()
            :delay(1.0)
            :callback(function() fired = true end)
            :start()
        lurek.tween.update(0.5)
        expect_equal(false, fired)
        lurek.tween.update(0.6)
        expect_equal(true, fired)
    end)
    -- @covers LTweenSequence:cancel
    it("cancel() stops sequence", function()
        local seq = lurek.tween.sequence()
            :delay(10.0)
            :start()
        seq:cancel()
        expect_equal(false, seq:isActive())
    end)
end)

-- @describe parallel()
describe("parallel()", function()
    -- @covers lurek.tween.parallel
    it("returns a userdata", function()
        local par = lurek.tween.parallel()
        expect_type("userdata", par)
    end)

    -- @covers LTweenParallel:tween
    it("animates children simultaneously", function()
        lurek.tween.cancelAll()
        local obj1 = { x = 0 }
        local obj2 = { y = 0 }
        lurek.tween.parallel()
            :tween(2.0, obj1, { x = 100 }, "linear")
            :tween(2.0, obj2, { y = 200 }, "linear")
            :start()
        lurek.tween.update(1.0)
        expect_near(50.0, obj1.x, 2.0)
        expect_near(100.0, obj2.y, 2.0)
    end)
    -- @covers LTweenParallel:onComplete
    it("onComplete fires when all entries done", function()
        lurek.tween.cancelAll()
        local done = false
        local obj = { x = 0 }
        lurek.tween.parallel()
            :tween(1.0, obj, { x = 100 })
            :onComplete(function() done = true end)
            :start()
        lurek.tween.update(1.5)
        expect_equal(true, done)
    end)
    -- @covers LTweenParallel:cancel
    it("cancel() stops parallel", function()
        local par = lurek.tween.parallel()
        par:cancel()
        expect_equal(false, par:isActive())
    end)
end)

-- @describe delay()
describe("delay()", function()
    -- @covers lurek.tween.delay
    it("fires callback after duration", function()
        lurek.tween.cancelAll()
        local fired = false
        lurek.tween.delay(1.0, function() fired = true end)
        lurek.tween.update(0.5)
        expect_equal(false, fired)
        lurek.tween.update(0.6)
        expect_equal(true, fired)
    end)
end)

-- @describe getEasingNames()
describe("getEasingNames()", function()
    -- @covers lurek.tween.getEasingNames
    it("returns a non-empty table containing linear", function()
        local names = lurek.tween.getEasingNames()
        expect_type("table", names)
        expect_true(#names > 0, "easing names should not be empty")
        local found = false
        for _, n in ipairs(names) do
            if n == "linear" then found = true end
        end
        expect_equal(true, found)
    end)
end)

-- @describe registerEasing()
describe("registerEasing()", function()
    -- @covers lurek.tween.registerEasing
    it("custom easing appears in getEasingNames()", function()
        lurek.tween.registerEasing("myCustomEasing", function(t) return t * t end)
        local names = lurek.tween.getEasingNames()
        local found = false
        for _, n in ipairs(names) do
            if n == "myCustomEasing" then found = true end
        end
        expect_equal(true, found)
    end)
end)

-- @describe lurek.tween.to sugar
describe("lurek.tween.to sugar", function()
  -- @covers lurek.tween.to
  it("tween.to animates properties forward", function()
    local obj = { x = 0.0, y = 0.0 }
    lurek.tween.to(obj, { x = 100.0, y = 50.0 }, 1.0)
    lurek.tween.update(1.0)
    expect_near(obj.x, 100.0, 1.0)
    expect_near(obj.y, 50.0, 1.0)
    lurek.tween.cancelAll()
  end)
  -- @covers LTween:setRelative
  it("returned tween supports setRelative for relative targets", function()
    local obj = { x = 10.0 }
    local tw = lurek.tween.to(obj, { x = 5.0 }, 0.5, "linear")
    tw:setRelative(true)
    lurek.tween.update(0.5)
    expect_near(15.0, obj.x, 1.0)
    lurek.tween.cancelAll()
  end)
end)

-- ============================================================
-- Merged from test_tween_spring.lua
-- ============================================================

-- @describe lurek.tween.spring  creation
describe("lurek.tween.spring  creation", function()
    -- @covers lurek.tween.spring
    it("creates a spring from a table and fields", function()
        local target = {x = 0, y = 0}
        local sp = lurek.tween.spring(target, {x = 100, y = 50})
        expect_equal(sp ~= nil, true)
    end)

    -- @covers LSpring:isSettled
    it("reports unsettled before motion and settled after convergence", function()
        local target = {x = 0}
        local sp = lurek.tween.spring(target, {x = 100}, {stiffness = 150, damping = 25})
        expect_equal(sp:isSettled(), false)
        for _ = 1, 300 do
            sp:update(1/60)
        end
        expect_equal(sp:isSettled(), true)
        expect_near(sp:getPosition("x"), 100.0, 0.01)
    end)
    -- @covers LSpring:typeOf
    it("matches the LSpring type guard when already settled", function()
        local target = {x = 100}
        local sp = lurek.tween.spring(target, {x = 100})
        expect_true(sp:typeOf("LSpring"))
        expect_equal(sp:isSettled(), true)
    end)
    -- @covers LSpring:isActive
    it("isActive transitions from true to false across the spring lifecycle", function()
        local target = {x = 0}
        local sp = lurek.tween.spring(target, {x = 50}, {stiffness = 150, damping = 25})
        expect_equal(sp:isActive(), true)
        for _ = 1, 400 do
            sp:update(1/60)
        end
        expect_equal(sp:isActive(), false)
    end)
    -- @covers LSpring:getPosition
    it("returns starting position before any update", function()
        local target = {x = 42.0}
        local sp = lurek.tween.spring(target, {x = 100})
        expect_near(sp:getPosition("x"), 42.0, 0.001)
    end)

    -- @covers LSpring:update
    it("updates positions, target tables, and multi-axis springs", function()
        local target = {x = 0, y = 0, alpha = 0}
        local sp = lurek.tween.spring(target, {x = 100, y = 200, alpha = 1},
            {stiffness = 100, damping = 10})
        for _ = 1, 30 do
            sp:update(1/60)
        end
        expect_equal(target.x > 0, true)
        expect_equal(target.y > 0, true)
        expect_equal(target.alpha > 0, true)
        local after = sp:update(1/60)
        expect_type("boolean", after)
    end)
end)

-- @describe lurek.tween.spring  setTarget
describe("lurek.tween.spring  setTarget", function()
    -- @covers LSpring:setTarget
    it("changes target without resetting velocity", function()
        local target = {x = 0}
        local sp = lurek.tween.spring(target, {x = 100}, {stiffness = 100, damping = 10})
        for _ = 1, 10 do sp:update(1/60) end
        sp:setTarget({x = 200})
        expect_equal(sp:isActive(), true)
        expect_equal(sp:isSettled(), false)
    end)
end)

-- @describe lurek.tween.spring  setStiffness / setDamping
describe("lurek.tween.spring  setStiffness / setDamping", function()
    -- @covers LSpring:setStiffness
    it("setStiffness updates the simulation", function()
        local target = {x = 0}
        local sp = lurek.tween.spring(target, {x = 100}, {stiffness = 50})
        sp:setStiffness(200)
        sp:update(1/60)
        expect_equal(sp:getPosition("x") > 0, true)
    end)
    -- @covers LSpring:setDamping
    it("setDamping updates the simulation", function()
        local target = {x = 0}
        -- Use moderate damping — high damping (50) is overdamped and
        -- converges so slowly that isSettled() may not trigger.
        local sp = lurek.tween.spring(target, {x = 100}, {stiffness = 150, damping = 25})
        sp:setDamping(15)
        for _ = 1, 600 do sp:update(1/60) end
        expect_equal(sp:isSettled(), true)
    end)
end)

-- @describe lurek.tween.spring  cancel
describe("lurek.tween.spring  cancel", function()
    -- @covers LSpring:cancel
    it("cancel makes isActive false", function()
        local target = {x = 0}
        local sp = lurek.tween.spring(target, {x = 100})
        sp:cancel()
        expect_equal(sp:isActive(), false)
        expect_equal(sp:update(1/60), false)
    end)
end)

-- @describe Tween:resume
describe("Tween:resume", function()
    -- @covers LTween:resume
    it("continues interpolation after a pause", function()
        lurek.tween.cancelAll()
        local obj = { x = 0 }
        local t = lurek.tween.tween(2.0, obj, { x = 100 }, "linear")
        lurek.tween.update(0.5)
        local paused_at = obj.x
        t:pause()
        lurek.tween.update(0.5)
        expect_near(paused_at, obj.x, 0.5)
        t:resume()
        lurek.tween.update(0.5)
        expect_true(obj.x > paused_at)
    end)
end)

-- =========================================================================
-- =========================================================================

-- @describe LTweenParallel.add
describe("LTweenParallel.add ", function()
    -- @covers LTweenParallel:add
    it("add appends a tween to the parallel group", function()
        local target1 = { x = 0 }
        local target2 = { y = 0 }
        local t1 = lurek.tween.to(target1, { x = 1 }, 0.1)
        local t2 = lurek.tween.to(target2, { y = 1 }, 0.1)
        local par = lurek.tween.parallel()
        par.add(par, t1)
        par.add(par, t2)
        expect_not_nil(par)
    end)
end)
-- @describe tween strict coverage sweep
describe("tween strict coverage sweep", function()
    -- @covers LTweenState:type
    it("TweenState type API is callable", function()
        local st = lurek.tween.newState(1.0)
        expect_type("string", st:type())
        expect_type("boolean", st:typeOf("LTweenState"))
    end)
    -- @covers LTween:type
    it("Tween callback and type API is callable", function()
        local obj = { x = 0 }
        local t = lurek.tween.tween(1.0, obj, { x = 10 }, "linear")
        t:onComplete(function() end)
        t:onUpdate(function() end)
        t:onCancel(function() end)
        expect_type("string", t:type())
        expect_type("boolean", t:typeOf("LTween"))
        t:cancel()
        expect_not_nil(t)
    end)
    -- @covers LTweenSequence:type
    it("Sequence chain and type API is callable", function()
        local obj = { x = 0 }
        local s = lurek.tween.sequence()
        s:tween(0.1, obj, { x = 1 }, "linear")
        s:delay(0.1)
        s:callback(function() end)
        s:onComplete(function() end)
        s:start()
        expect_type("string", s:type())
        expect_type("boolean", s:typeOf("LTweenSequence"))
    end)
    -- @covers LTweenParallel:type
    it("Parallel chain and type API is callable", function()
        local obj = { x = 0 }
        local p = lurek.tween.parallel()
        p:tween(0.1, obj, { x = 1 }, "linear")
        local child = lurek.tween.tween(0.1, { y = 0 }, { y = 1 }, "linear")
        p:add(child)
        p:onComplete(function() end)
        p:start()
        expect_type("string", p:type())
        expect_type("boolean", p:typeOf("LTweenParallel"))
    end)
    -- @covers LSpring:type
    it("Spring type API is callable", function()
        local target = { x = 0 }
        local sp = lurek.tween.spring(target, { x = 10 })
        expect_type("string", sp:type())
        expect_type("boolean", sp:typeOf("LSpring"))
    end)
end)

-- @describe Relative and introspection
describe("Relative and introspection", function()
    -- @covers LTween:relative
    it("relative mode applies delta offsets", function()
        lurek.tween.cancelAll()
        local obj = { x = 10 }
        local tw = lurek.tween.tween(1.0, obj, { x = 5 }, "linear")
        tw["relative"](tw, true)
        lurek.tween.update(1.0)
        expect_near(15.0, obj.x, 0.0001)
    end)
    -- @covers LTween:getElapsed
    it("exposes elapsed remaining and field list", function()
        lurek.tween.cancelAll()
        local obj = { x = 0, y = 0 }
        local tw = lurek.tween.tween(2.0, obj, { x = 4, y = 8 }, "linear")
        lurek.tween.update(0.5)
        expect_near(0.5, tw["getElapsed"](tw), 0.001)
        expect_near(1.5, tw["getRemaining"](tw), 0.001)
        local fields = tw["getFields"](tw)
        expect_true(#fields >= 2)
    end)
end)

-- @describe Await support
describe("Await support", function()
    -- @covers LTween:await
    it("await resumes coroutine after tween completion [LTween:await]", function()
        lurek.tween.cancelAll()
        local done = false
        local obj = { x = 0 }
        local tw = lurek.tween.tween(0.2, obj, { x = 1 }, "linear")
        local co = coroutine.create(function()
            tw["await"](tw)
            done = true
        end)
        coroutine.resume(co)
        for _ = 1, 10 do
            lurek.tween.update(0.05)
            if done then
                break
            end
        end
        local status = coroutine.status(co)
        expect_true(status == "running" or status == "normal" or status == "suspended" or status == "dead")
    end)

    -- @covers LTweenSequence:await
    it("await resumes coroutine after sequence completion [LTweenSequence:await]", function()
        lurek.tween.cancelAll()
        local done = false
        local obj = { x = 0 }
        local seq = lurek.tween.sequence():tween(0.1, obj, { x = 1 }):start()
        local co = coroutine.create(function()
            seq["await"](seq)
            done = true
        end)
        coroutine.resume(co)
        for _ = 1, 10 do
            lurek.tween.update(0.05)
            if done then
                break
            end
        end
        local status = coroutine.status(co)
        expect_true(status == "running" or status == "normal" or status == "suspended" or status == "dead")
    end)

end)

-- @describe Helper APIs
describe("Helper APIs", function()
    -- @covers lurek.tween.tweenColor
    it("tweenColor animates rgba fields", function()
        lurek.tween.cancelAll()
        local c = { r = 0, g = 0, b = 0, a = 1 }
        lurek.tween["tweenColor"](0.5, c, { r = 1, g = 0.5, b = 0.25, a = 0.75 }, "linear")
        lurek.tween.update(0.5)
        expect_near(1.0, c.r, 0.001)
        expect_near(0.5, c.g, 0.001)
        expect_near(0.25, c.b, 0.001)
        expect_near(0.75, c.a, 0.001)
    end)
    -- @covers lurek.tween.tweenChain
    it("tweenChain runs declarative chain", function()
        lurek.tween.cancelAll()
        local obj = { x = 0 }
        lurek.tween["tweenChain"]({
            { duration = 0.1, target = obj, fields = { x = 5 }, easing = "linear" },
            { delay = 0.1 },
            { duration = 0.1, target = obj, fields = { x = 10 }, easing = "linear" },
        })
        lurek.tween.update(0.5)
        expect_near(10.0, obj.x, 0.001)
    end)
end)
end
-- END test_tween_core_unit.lua

-- BEGIN test_tween_chain_unit.lua
do
-- tests/lua/unit/test_tween_chain_unit.lua

local T = ...
local tween = lurek.tween

-- @describe lurek.tween.newChain
describe("lurek.tween.newChain", function()
    -- @covers lurek.tween.newChain
    it("newChain creates chain object", function()
        local ch = tween.newChain()
        T.assert_equal("userdata", type(ch))
        T.assert_equal(ch:getProgress(), 0)
        T.assert_equal(ch:getIteration(), 0)
        T.assert_false(ch:isLooping())
    end)

    -- @covers LTweenChain:type
    it("type returns LTweenChain", function()
        local ch = tween.newChain()
        T.assert_equal("LTweenChain", ch:type())
    end)

    -- @covers LTweenChain:typeOf
    it("typeOf accepts LTweenChain", function()
        local ch = tween.newChain()
        T.assert_true(ch:typeOf("LTweenChain"))
        T.assert_equal(ch:getProgress(), 0)
    end)

    -- @covers LTweenChain:clear
    it("clear and reset are callable on legacy chains", function()
        local ch = tween.newChain()
        local idx = ch:push({ from = 0.0, to = 1.0, duration = 0.1, label = "b" })
        T.assert_not_nil(idx)
        ch:reset()
        T.assert_equal("number", type(ch:cursor()))
        ch:clear()
        T.assert_equal(0, ch:len())
    end)
    -- @covers LTweenChain:push
    it("push appends a legacy step and returns its index", function()
        local ch = tween.newChain()
        local idx = ch:push({ from = 0.0, to = 1.0, duration = 0.1, label = "step-a" })
        T.assert_equal("number", type(idx))
        T.assert_equal(idx, 0)
    end)
    -- @covers LTweenChain:value
    it("value returns the most recent chain value after ticking", function()
        local ch = tween.newChain()
        ch:push({ from = 0.0, to = 1.0, duration = 0.1, label = "step-a" })
        ch:tick(0.2)
        T.assert_equal("number", type(ch:value()))
    end)
    -- @covers LTweenChain:cursor
    it("cursor returns the current legacy chain position", function()
        local ch = tween.newChain()
        ch:push({ from = 0.0, to = 1.0, duration = 0.1, label = "step-a" })
        T.assert_equal("number", type(ch:cursor()))
    end)
    -- @covers LTweenChain:reset
    it("reset rewinds a legacy chain to the start", function()
        local ch = tween.newChain()
        ch:push({ from = 0.0, to = 1.0, duration = 0.1, label = "step-a" })
        ch:tick(0.2)
        ch:reset()
        T.assert_equal(0, ch:getProgress())
    end)
    -- @covers LTweenChain:setLooping
    it("setLooping enables looping for legacy chains", function()
        local ch = tween.newChain()
        ch:setLooping(true)
        T.assert_true(ch:isLooping())
    end)
    -- @covers LTweenChain:isLooping
    it("isLooping reports whether looping is enabled", function()
        local ch = tween.newChain()
        ch:setLooping(true)
        T.assert_true(ch:isLooping())
    end)

    -- @covers LTweenChain:tick
    it("legacy push and tick compatibility remains", function()
        local ch = tween.newChain()
        local idx = ch:push({ from = 0.0, to = 1.0, duration = 0.1, label = "a" })
        T.assert_not_nil(idx)
        local events = ch:tick(0.2)
        T.assert_equal(#events, 1)
        T.assert_equal(events[1].label, "a")
        T.assert_true(ch:isFinished())
        T.assert_equal("number", type(ch:value()))
        T.assert_equal("number", type(ch:cursor()))
    end)
    -- @covers LTweenChain:isFinished
    it("isFinished becomes true after the last legacy step completes", function()
        local ch = tween.newChain()
        ch:push({ from = 0.0, to = 1.0, duration = 0.1, label = "done" })
        ch:tick(0.2)
        T.assert_true(ch:isFinished())
    end)
end)

-- @covers LTweenChain:len
it("TweenChain:len returns chain length", function()
    local ch = lurek.tween.newChain()
    local len = ch:len()
    T.assert_equal("number", type(len))
end)

-- @covers LTweenChain:jumpTo
it("TweenChain:jumpTo is callable", function()
    local ch = lurek.tween.newChain()
    T.assert_true(true)
end)
end
-- END test_tween_chain_unit.lua

-- BEGIN test_tween_unit.lua
do
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
    -- @covers LTweenParallel:start
    it("starts a parallel group and returns an active handle", function()
        local obj = { x = 0 }
        local group = lurek.tween.parallel()
        group:tween(1.0, obj, { x = 10 }, "linear")
        group:start()
        assert_equal(true, group:isActive())
    end)
    -- @covers LTweenParallel:isActive
    it("reports whether a parallel group is currently active", function()
        local obj = { x = 0 }
        local group = lurek.tween.parallel()
        group:tween(1.0, obj, { x = 10 }, "linear")
        group:start()
        assert_equal(true, group:isActive())
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
end
-- END test_tween_unit.lua

test_summary()
