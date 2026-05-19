-- content/examples/tween.lua
-- Auto-generated from content/examples2/tween_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/tween.lua

--- Tween Module Part 1: basic tweens, easing, LTween, LTweenState, springs, color tweens

--@api-stub: lurek.tween.tween
-- Basic property tween.
do
    local obj = { x = 0, y = 0 }
    ---@type LTween
    local tw = lurek.tween.tween(1.0, obj, { x = 100, y = 50 })
    print("type = " .. tw:type())
    print("active = " .. tostring(tw:isActive()))
    print("duration = " .. tw:getDuration())
    lurek.tween.update(0.5)
    print("at 0.5s: x=" .. obj.x .. " y=" .. obj.y)
    print("progress = " .. tw:getProgress())
    print("elapsed = " .. tw:getElapsed())
    print("remaining = " .. tw:getRemaining())
end

-- Using a named easing function.
--@api-stub: lurek.tween.tween
--@api-stub: lurek.tween.update
do
    local obj = { alpha = 0 }
    ---@type LTween
    local tw = lurek.tween.tween(2.0, obj, { alpha = 1.0 }, "easeInOutQuad")
    lurek.tween.update(1.0)
    print("easeInOutQuad at midpoint: alpha=" .. obj.alpha)
end

--@api-stub: lurek.tween.to
-- Alternative parameter order (target first).
do
    local pos = { x = 100, y = 200 }
    ---@type LTween
    local tw = lurek.tween.to(pos, { x = 0, y = 0 }, 0.5, "easeOutBounce")
    lurek.tween.update(0.5)
    print("moved to: x=" .. pos.x .. " y=" .. pos.y)
end

--@api-stub: LTween:onComplete
--@api-stub: LTween:onUpdate
--@api-stub: LTween:onCancel
-- Tween lifecycle callbacks.
do
    local obj = { scale = 1 }
    ---@type LTween
    local tw = lurek.tween.tween(1.0, obj, { scale = 2 })
    tw:onUpdate(function(t)
        print("  update t=" .. string.format("%.2f", t))
    end)
    tw:onComplete(function()
        print("  completed! scale=" .. obj.scale)
    end)
    tw:onCancel(function()
        print("  cancelled")
    end)
    lurek.tween.update(0.5)
    lurek.tween.update(0.5)
end

--@api-stub: LTween:pause
--@api-stub: LTween:resume
-- Pausing and resuming a tween.
do
    local obj = { rotation = 0 }
    ---@type LTween
    local tw = lurek.tween.tween(2.0, obj, { rotation = 360 })
    lurek.tween.update(0.5)
    print("before pause: " .. obj.rotation)
    tw:pause()
    lurek.tween.update(1.0)
    print("while paused: " .. obj.rotation)
    tw:resume()
    lurek.tween.update(0.5)
    print("after resume: " .. obj.rotation)
end

--@api-stub: LTween:cancel
-- Cancelling a tween mid-flight.
do
    local obj = { w = 100 }
    ---@type LTween
    local tw = lurek.tween.tween(1.0, obj, { w = 200 })
    lurek.tween.update(0.3)
    print("before cancel: w=" .. obj.w)
    tw:cancel()
    print("active after cancel = " .. tostring(tw:isActive()))
    lurek.tween.update(1.0)
    print("after update: w=" .. obj.w)
end

--@api-stub: LTween:setRepeat
--@api-stub: LTween:setYoyo
-- Repeating and yoyo tweens.
do
    local obj = { x = 0 }
    ---@type LTween
    local tw = lurek.tween.tween(0.5, obj, { x = 100 })
    tw:setRepeat(3)
    tw:setYoyo(true)
    for i = 1, 8 do
        lurek.tween.update(0.25)
        print("step " .. i .. ": x=" .. string.format("%.0f", obj.x))
    end
end

--@api-stub: LTween:relative
-- Relative tween values (added to start).
do
    local obj = { x = 50, y = 50 }
    ---@type LTween
    local tw = lurek.tween.tween(1.0, obj, { x = 30, y = -20 }):relative(true)
    lurek.tween.update(1.0)
    print("relative result: x=" .. obj.x .. " y=" .. obj.y)
end

--@api-stub: LTween:getFields
-- Querying tweened field names.
do
    local obj = { a = 0, b = 0, c = 0 }
    ---@type LTween
    local tw = lurek.tween.tween(1.0, obj, { a = 1, b = 2, c = 3 })
    local fields = tw:getFields()
    print("fields: " .. table.concat(fields, ", "))
end

--@api-stub: lurek.tween.tweenColor
-- Color interpolation tween.
do
    local color = { r = 1.0, g = 0.0, b = 0.0, a = 1.0 }
    ---@type LTween
    local tw = lurek.tween.tweenColor(2.0, color, { r = 0.0, g = 0.0, b = 1.0 }, "linear")
    lurek.tween.update(1.0)
    print("midpoint: r=" .. string.format("%.2f", color.r) ..
        " g=" .. string.format("%.2f", color.g) ..
        " b=" .. string.format("%.2f", color.b))
    lurek.tween.update(1.0)
    print("end: r=" .. color.r .. " b=" .. color.b)
end

--@api-stub: lurek.tween.newState
-- Manual tween state for custom interpolation.
do
    ---@type LTweenState
    local state = lurek.tween.newState(2.0, "easeInOutCubic")
    print("type = " .. state:type())
    print("complete = " .. tostring(state:isComplete()))
    local val = state:tick(1.0)
    print("at 1.0s: eased value = " .. string.format("%.3f", val))
    print("raw t = " .. string.format("%.3f", state:t()))
    local interp = state:lerp(100, 200)
    print("lerp(100, 200) = " .. string.format("%.1f", interp))
    state:tick(1.0)
    print("complete = " .. tostring(state:isComplete()))
end

--@api-stub: LTweenState:reset
-- Resetting a tween state for replay.
do
    ---@type LTweenState
    local state = lurek.tween.newState(1.0)
    state:tick(1.0)
    print("done = " .. tostring(state:isComplete()))
    state:reset()
    print("after reset, done = " .. tostring(state:isComplete()))
    print("t = " .. state:t())
end

--@api-stub: lurek.tween.spring
-- Spring physics animation.
do
    local obj = { x = 0, y = 0 }
    ---@type LSpring
    local spring = lurek.tween.spring(obj, { x = 100, y = 50 }, {
        stiffness = 200,
        damping = 15,
        precision = 0.01,
    })
    print("type = " .. spring:type())
    print("active = " .. tostring(spring:isActive()))
    for i = 1, 10 do
        spring:update(1 / 60)
    end
    print("after 10 frames: x=" .. string.format("%.1f", obj.x) ..
        " y=" .. string.format("%.1f", obj.y))
    print("settled = " .. tostring(spring:isSettled()))
end

--@api-stub: LSpring:setTarget
--@api-stub: LSpring:setStiffness
--@api-stub: LSpring:setDamping
--@api-stub: LSpring:getPosition
-- Retargeting and tuning springs.
do
    local obj = { size = 50 }
    ---@type LSpring
    local spring = lurek.tween.spring(obj, { size = 100 })
    spring:setStiffness(300)
    spring:setDamping(20)
    for i = 1, 30 do spring:update(1 / 60) end
    print("size = " .. string.format("%.1f", obj.size))
    spring:setTarget({ size = 0 })
    for i = 1, 60 do spring:update(1 / 60) end
    print("retargeted size = " .. string.format("%.1f", obj.size))
    local pos = spring:getPosition("size")
    print("getPosition = " .. tostring(pos))
end

--@api-stub: LSpring:cancel
-- Cancelling a spring animation.
do
    local obj = { val = 0 }
    ---@type LSpring
    local spring = lurek.tween.spring(obj, { val = 100 })
    spring:update(1 / 60)
    spring:cancel()
    print("active after cancel = " .. tostring(spring:isActive()))
end

--@api-stub: lurek.tween.getActiveCount
-- Global tween management.
do
    local a = { x = 0 }
    local b = { y = 0 }
    lurek.tween.tween(1.0, a, { x = 10 })
    lurek.tween.tween(2.0, b, { y = 20 })
    print("active count = " .. lurek.tween.getActiveCount())
    lurek.tween.cancelAll()
    print("after cancelAll = " .. lurek.tween.getActiveCount())
end

--@api-stub: lurek.tween.registerEasing
-- Custom easing functions.
do
    lurek.tween.registerEasing("bounce3", function(t)
        return 1 - math.abs(math.cos(t * math.pi * 3)) * (1 - t)
    end)
    local names = lurek.tween.getEasingNames()
    print("available easings: " .. #names)
    -- Use the custom easing
    local obj = { v = 0 }
    lurek.tween.tween(1.0, obj, { v = 1 }, "bounce3")
    lurek.tween.update(0.5)
    print("custom easing at 0.5: " .. string.format("%.3f", obj.v))
end

--- Tween Module Part 2: sequences, parallels, delay, tweenChain, update

--@api-stub: lurek.tween.sequence
-- Creating a tween sequence.
do
    local obj = { x = 0, y = 0 }
    ---@type LTweenSequence
    local seq = lurek.tween.sequence()
    print("type = " .. seq:type())
    seq:tween(0.5, obj, { x = 100 }, "easeOutQuad")
    seq:tween(0.5, obj, { y = 100 }, "easeInQuad")
    seq:start()
    print("active = " .. tostring(seq:isActive()))
    lurek.tween.update(0.5)
    print("after step 1: x=" .. obj.x .. " y=" .. obj.y)
    lurek.tween.update(0.5)
    print("after step 2: x=" .. obj.x .. " y=" .. obj.y)
end

--@api-stub: LTweenSequence:delay
-- Adding delays between sequence steps.
do
    local obj = { alpha = 0 }
    ---@type LTweenSequence
    local seq = lurek.tween.sequence()
    seq:tween(0.3, obj, { alpha = 1 })
    seq:delay(0.5)
    seq:tween(0.3, obj, { alpha = 0 })
    seq:start()
    lurek.tween.update(0.3)
    print("fade in done: alpha=" .. obj.alpha)
    lurek.tween.update(0.5)
    print("after delay: alpha=" .. obj.alpha)
    lurek.tween.update(0.3)
    print("fade out done: alpha=" .. obj.alpha)
end

--@api-stub: LTweenSequence:callback
-- Inserting callbacks into a sequence.
do
    local obj = { scale = 1 }
    ---@type LTweenSequence
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { scale = 2 })
    seq:callback(function()
        print("  halfway callback! scale=" .. obj.scale)
    end)
    seq:tween(0.5, obj, { scale = 1 })
    seq:onComplete(function()
        print("  sequence complete")
    end)
    seq:start()
    lurek.tween.update(0.5)
    lurek.tween.update(0.5)
end

--@api-stub: LTweenSequence:getProgress
--@api-stub: LTweenSequence:cancel
-- Monitoring and cancelling a sequence.
do
    local obj = { w = 0 }
    ---@type LTweenSequence
    local seq = lurek.tween.sequence()
    seq:tween(1.0, obj, { w = 100 })
    seq:tween(1.0, obj, { w = 0 })
    seq:start()
    lurek.tween.update(1.0)
    print("progress at midpoint = " .. seq:getProgress())
    seq:cancel()
    print("active after cancel = " .. tostring(seq:isActive()))
end

-- Delay step with its own callback.
--@api-stub: lurek.tween.sequence
do
    local obj = { v = 0 }
    ---@type LTweenSequence
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { v = 50 })
    seq:delay(1.0, function()
        print("  delay elapsed, v=" .. obj.v)
    end)
    seq:tween(0.5, obj, { v = 100 })
    seq:start()
    lurek.tween.update(0.5)
    lurek.tween.update(1.0)
    lurek.tween.update(0.5)
    print("final v=" .. obj.v)
end

--@api-stub: lurek.tween.parallel
-- Running tweens simultaneously in a parallel group.
do
    local a = { x = 0 }
    local b = { y = 0 }
    local c = { rot = 0 }
    ---@type LTweenParallel
    local par = lurek.tween.parallel()
    print("type = " .. par:type())
    par:tween(1.0, a, { x = 200 }, "linear")
    par:tween(1.0, b, { y = 150 }, "easeOutQuad")
    par:tween(1.0, c, { rot = 360 }, "easeInOutSine")
    par:start()
    print("active = " .. tostring(par:isActive()))
    lurek.tween.update(0.5)
    print("midpoint: x=" .. a.x .. " y=" .. string.format("%.0f", b.y) .. " rot=" .. c.rot)
    lurek.tween.update(0.5)
    print("done: x=" .. a.x .. " y=" .. b.y .. " rot=" .. c.rot)
end

--@api-stub: LTweenParallel:add
-- Adding existing tweens to a parallel group.
do
    local obj1 = { alpha = 1 }
    local obj2 = { scale = 1 }
    ---@type LTween
    local tw1 = lurek.tween.tween(0.8, obj1, { alpha = 0 })
    ---@type LTween
    local tw2 = lurek.tween.tween(0.8, obj2, { scale = 3 })
    ---@type LTweenParallel
    local par = lurek.tween.parallel()
    par:add(tw1)
    par:add(tw2)
    par:onComplete(function()
        print("  parallel group done")
    end)
    par:start()
    lurek.tween.update(0.8)
    print("alpha=" .. obj1.alpha .. " scale=" .. obj2.scale)
end

--@api-stub: LTweenParallel:cancel
-- Cancelling all tweens in a parallel group.
do
    local a = { x = 0 }
    local b = { y = 0 }
    ---@type LTweenParallel
    local par = lurek.tween.parallel()
    par:tween(2.0, a, { x = 100 })
    par:tween(2.0, b, { y = 100 })
    par:start()
    lurek.tween.update(1.0)
    par:cancel()
    print("cancelled: active=" .. tostring(par:isActive()))
    print("x=" .. a.x .. " y=" .. b.y)
end

--@api-stub: lurek.tween.delay
-- Standalone delay utility.
do
    ---@type LTweenSequence
    local d = lurek.tween.delay(1.5, function()
        print("  delay complete")
    end)
    print("delay active = " .. tostring(d:isActive()))
    lurek.tween.update(1.5)
    print("delay done = " .. tostring(not d:isActive()))
end

--@api-stub: lurek.tween.tweenChain
-- Chain from descriptor table.
do
    local obj = { x = 0, y = 0 }
    ---@type LTweenSequence
    local chain = lurek.tween.tweenChain({
        { duration = 0.5, target = obj, fields = { x = 100 }, easing = "easeOutQuad" },
        { delay = 0.2 },
        { duration = 0.5, target = obj, fields = { y = 100 }, easing = "easeInQuad" },
        { callback = function() print("  chain finished: x=" .. obj.x .. " y=" .. obj.y) end },
    })
    lurek.tween.update(0.5)
    lurek.tween.update(0.2)
    lurek.tween.update(0.5)
    lurek.tween.update(0.01)
end

--- Tween Part 2: LTween extended, LTweenParallel, LTweenSequence, LTweenState, advanced module fns

--@api-stub: LTween.onComplete
--@api-stub: LTween:await
--@api-stub: LTween:getDuration
--@api-stub: LTween:getElapsed
--@api-stub: LTween:getProgress
--@api-stub: LTween:getRemaining
--@api-stub: LTween:isActive
--@api-stub: LTween:setRelative
--@api-stub: LTween:type
--@api-stub: LTween:typeOf
-- LTween extended: lifecycle, progress queries, callbacks, relative mode, type.
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    print("duration=" .. tw:getDuration())
    print("elapsed=" .. tw:getElapsed())
    print("progress=" .. tw:getProgress())
    print("remaining=" .. tw:getRemaining())
    print("active=" .. tostring(tw:isActive()))
    tw:onComplete(function() print("tween_complete") end)
    tw:setRelative(false)
    print("type=" .. tw:type())
    print("typeOf=" .. tostring(tw:typeOf("LTween")))
    tw:await()
    tw:cancel()
end

--@api-stub: LTweenParallel.add
--@api-stub: LTweenParallel:isActive
--@api-stub: LTweenParallel.onComplete
--@api-stub: LTweenParallel:start
--@api-stub: LTweenParallel.tween
--@api-stub: LTweenParallel:type
--@api-stub: LTweenParallel:typeOf
-- LTweenParallel: run multiple tweens simultaneously.
do
    local a = { x = 0.0 }
    local b = { y = 0.0 }
    local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear")
    par:tween(0.5, b, { y = 20 }, "easeinquad")
    local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra)
    par:onComplete(function() print("parallel_done") end)
    print("par_active=" .. tostring(par:isActive()))
    print("par_type=" .. par:type())
    print("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start()
    par:cancel()
end

--@api-stub: LTweenSequence.delay
--@api-stub: LTweenSequence.onComplete
--@api-stub: LTweenSequence.tween
--@api-stub: LTweenSequence:await
--@api-stub: LTweenSequence:isActive
--@api-stub: LTweenSequence:start
--@api-stub: LTweenSequence:type
--@api-stub: LTweenSequence:typeOf
-- LTweenSequence: chain tweens one after another.
do
    local obj = { x = 0.0, alpha = 1.0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { x = 100 }, "linear")
    seq:delay(0.1, function() print("seq_delay_cb") end)
    seq:tween(0.5, obj, { alpha = 0 }, "easeout")
    seq:onComplete(function() print("seq_done") end)
    print("seq_active=" .. tostring(seq:isActive()))
    print("seq_type=" .. seq:type())
    print("seq_typeOf=" .. tostring(seq:typeOf("LTweenSequence")))
    seq:start()
    seq:await()
    seq:cancel()
end

--@api-stub: LTweenState:isComplete
--@api-stub: LTweenState:lerp
--@api-stub: LTweenState:t
--@api-stub: LTweenState:tick
--@api-stub: LTweenState:type
--@api-stub: LTweenState:typeOf
-- LTweenState: a manual time-state value for custom lerp.
do
    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    print("t=" .. state:t())
    print("lerp=" .. state:lerp(0, 100))
    print("complete=" .. tostring(state:isComplete()))
    print("type=" .. state:type())
    print("typeOf=" .. tostring(state:typeOf("LTweenState")))
end

--@api-stub: lurek.tween.cancelAll
--@api-stub: lurek.tween.getEasingNames
-- Cancel all active tweens and list registered easing functions.
do
    local target = { v = 0.0 }
    lurek.tween.to(target, { v = 1 }, 2.0, "linear")
    print("active=" .. lurek.tween.getActiveCount())
    lurek.tween.cancelAll()
    print("active_after=" .. lurek.tween.getActiveCount())

    local names = lurek.tween.getEasingNames()
    print("easing_count=" .. #names)
end

--@api-stub: LSpring:isActive
--@api-stub: LSpring:isSettled
--@api-stub: LSpring:update
-- LSpring: physics-based spring animation.
do
    local obj = {x = 0}
    local sp = lurek.tween.spring(obj, {x = 100}, {stiffness = 200, damping = 20})
    sp:update(0.016)
    local active = sp:isActive()
    local settled = sp:isSettled()
    print("spring active:", active, "settled:", settled)
end

--@api-stub: LSpring:type
--@api-stub: LSpring:typeOf
-- LSpring type introspection.
do
    local state = {v = 0}
    local sp = lurek.tween.spring(state, {v = 50}, {stiffness = 150, damping = 15})
    local t = sp:type()
    local ok = sp:typeOf("LSpring")
    print("spring type:", t, "typeOf:", ok)
end

print("content/examples/tween.lua")
