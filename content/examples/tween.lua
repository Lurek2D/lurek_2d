-- content/examples/tween.lua
-- Auto-generated from content/examples2/tween_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/tween.lua

--- Tween Module Part 1: basic tweens, easing, LTween, LTweenState, springs, color tweens

--@api: lurek.tween.tween
do
    local obj = { x = 0, y = 0 }
    local tw = lurek.tween.tween(1.0, obj, { x = 100, y = 50 })
    print("type = " .. tw:type())
    lurek.tween.update(0.5)
    print("at 0.5s: x=" .. obj.x .. " y=" .. obj.y)
end

--@api: lurek.tween.update
do
    local pos = { x = 100, y = 200 }
    lurek.tween.to(pos, { x = 0, y = 0 }, 0.5, "easeOutBounce")
    lurek.tween.update(0.5)
    print("moved to: x=" .. pos.x .. " y=" .. pos.y)
end

--@api: lurek.tween.to
do
    local pos = { x = 100, y = 200 }
    lurek.tween.to(pos, { x = 0, y = 0 }, 0.5, "easeOutBounce")
    lurek.tween.update(0.5)
    print("moved to: x=" .. pos.x .. " y=" .. pos.y)
end

--@api: LTween:onComplete
do
    local obj = { scale = 1 }
    local tw = lurek.tween.tween(1.0, obj, { scale = 2 })
    tw:onComplete(function() print("  completed! scale=" .. obj.scale) end)
    lurek.tween.update(0.5)
end

--@api: LTween:onUpdate
do
    local obj = { scale = 1 }
    local tw = lurek.tween.tween(1.0, obj, { scale = 2 })
    tw:onUpdate(function(t) print("  update t=" .. string.format("%.2f", t)) end)
    lurek.tween.update(0.5)
end

--@api: LTween:onCancel
do
    local obj = { scale = 1 }
    local tw = lurek.tween.tween(1.0, obj, { scale = 2 })
    tw:onCancel(function() print("  cancelled") end)
    tw:cancel()
end

--@api: LTween:pause
do
    local obj = { rotation = 0 }
    local tw = lurek.tween.tween(2.0, obj, { rotation = 360 })

    lurek.tween.update(0.5)
    print("before pause: " .. obj.rotation)
    tw:pause()
    lurek.tween.update(1.0)
    print("while paused: " .. obj.rotation)
end

--@api: LTween:resume
do
    local obj = { rotation = 0 }
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

--@api: LTween:cancel
do
    local obj = { w = 100 }
    local tw = lurek.tween.tween(1.0, obj, { w = 200 })

    lurek.tween.update(0.3)
    print("before cancel: w=" .. obj.w)
    tw:cancel()
    print("active after cancel = " .. tostring(tw:isActive()))
    lurek.tween.update(1.0)
    print("after update: w=" .. obj.w)
end

--@api: LTween:setRepeat
do
    local obj = { x = 0 }
    ---@type LTween
    local tw = lurek.tween.tween(0.5, obj, { x = 100 })
    tw:setRepeat(3)
    print("repeat set")
end

--@api: LTween:setYoyo
do
    local obj = { x = 0 }
    ---@type LTween
    local tw = lurek.tween.tween(0.5, obj, { x = 100 })
    tw:setYoyo(true)
    print("yoyo set")
end

--@api: LTween:relative
do
    local obj = { x = 50, y = 50 }
    ---@type LTween
    local tw = lurek.tween.tween(1.0, obj, { x = 30, y = -20 }):relative(true)
    lurek.tween.update(1.0)
    print("relative result: x=" .. obj.x .. " y=" .. obj.y)
end

--@api: LTween:getFields
do
    local obj = { a = 0, b = 0, c = 0 }
    ---@type LTween
    local tw = lurek.tween.tween(1.0, obj, { a = 1, b = 2, c = 3 })
    local fields = tw:getFields()
    print("fields: " .. table.concat(fields, ", "))
end

--@api: lurek.tween.tweenColor
do
    local color = { r = 1.0, g = 0.0, b = 0.0, a = 1.0 }
    local tw = lurek.tween.tweenColor(2.0, color, { r = 0.0, g = 0.0, b = 1.0 }, "linear")

    lurek.tween.update(1.0)
    print("midpoint: r=" .. string.format("%.2f", color.r) .. " g=" .. string.format("%.2f", color.g) .. " b=" .. string.format("%.2f", color.b))
    lurek.tween.update(1.0)
    print("end: r=" .. color.r .. " b=" .. color.b)
end

--@api: lurek.tween.newState
do
    local state = lurek.tween.newState(2.0, "easeInOutCubic")
    print("type = " .. state:type())
    print("complete = " .. tostring(state:isComplete()))

    state:tick(1.0)
    local val = state:lerp(0.0, 1.0)
    print("at 1.0s: eased value = " .. string.format("%.3f", val))
    print("raw t = " .. string.format("%.3f", state:t()))

    local interp = state:lerp(100, 200)
    print("lerp(100, 200) = " .. string.format("%.1f", interp))
    state:tick(1.0)
    print("complete = " .. tostring(state:isComplete()))
end

--@api: LTweenState:reset
do
    local state = lurek.tween.newState(1.0)
    state:tick(1.0)
    print("done = " .. tostring(state:isComplete()))
    state:reset()
    print("after reset, done = " .. tostring(state:isComplete()))
    print("t = " .. state:t())
end

--@api: lurek.tween.spring
do
    local obj = { x = 0, y = 0 }
    local spring = lurek.tween.spring(obj, { x = 100, y = 50 }, {
        stiffness = 200,
        damping = 15,
        precision = 0.01,
    })

    print("type = " .. spring:type())
    print("active = " .. tostring(spring:isActive()))
    for i = 1, 10 do spring:update(1 / 60) end
    print("after 10 frames: x=" .. string.format("%.1f", obj.x) .. " y=" .. string.format("%.1f", obj.y))
    print("settled = " .. tostring(spring:isSettled()))
end

--@api: LSpring:setTarget
do
    local obj = { size = 50 }
    local spring = lurek.tween.spring(obj, { size = 100 })
    spring:setStiffness(300)
    spring:setDamping(20)

    for i = 1, 30 do
        spring:update(1 / 60)
    end
    print("size = " .. string.format("%.1f", obj.size))

    spring:setTarget({ size = 0 })
    for i = 1, 60 do
        spring:update(1 / 60)
    end

    local pos = spring:getPosition("size")
    print("retargeted size = " .. string.format("%.1f", obj.size))
    print("getPosition = " .. tostring(pos))
end

--@api: LSpring:setStiffness
do
    local obj = { size = 50 }
    local spring = lurek.tween.spring(obj, { size = 100 })
    spring:setStiffness(300)
    spring:update(1 / 10)
    print("size after stronger spring = " .. string.format("%.1f", obj.size))
    print("position = " .. tostring(spring:getPosition("size")))
end

--@api: LSpring:setDamping
do
    local obj = { size = 50 }
    local spring = lurek.tween.spring(obj, { size = 100 })
    spring:setDamping(20)
    spring:update(1 / 10)
    print("size after damping = " .. string.format("%.1f", obj.size))
    print("settled = " .. tostring(spring:isSettled()))
end

--@api: LSpring:getPosition
do
    local obj = { size = 50 }
    local spring = lurek.tween.spring(obj, { size = 100 })
    spring:update(1 / 10)

    local pos = spring:getPosition("size")
    print("size = " .. string.format("%.1f", obj.size))
    print("getPosition = " .. tostring(pos))
end

--@api: LSpring:cancel
do
    local obj = { val = 0 }
    local spring = lurek.tween.spring(obj, { val = 100 })
    spring:update(1 / 60)
    spring:cancel()
    print("active after cancel = " .. tostring(spring:isActive()))
end

--@api: lurek.tween.getActiveCount
do
    local a = { x = 0 }
    local b = { y = 0 }
    lurek.tween.tween(1.0, a, { x = 10 })
    lurek.tween.tween(2.0, b, { y = 20 })
    print("active count = " .. lurek.tween.getActiveCount())
    lurek.tween.cancelAll()
    print("after cancelAll = " .. lurek.tween.getActiveCount())
end

--@api: lurek.tween.registerEasing
do
    lurek.tween.registerEasing("bounce3", function(t)
        return 1 - math.abs(math.cos(t * math.pi * 3)) * (1 - t)
    end)

    local names = lurek.tween.getEasingNames()
    local obj = { v = 0 }
    print("available easings: " .. #names)
    lurek.tween.tween(1.0, obj, { v = 1 }, "bounce3")
    lurek.tween.update(0.5)
    print("custom easing at 0.5: " .. string.format("%.3f", obj.v))
end

--- Tween Module Part 2: sequences, parallels, delay, tweenChain, update

--@api: lurek.tween.sequence
do
    local obj = { x = 0, y = 0 }
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

--@api: LTweenSequence:delay
do
    local obj = { alpha = 0 }
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

--@api: LTweenSequence:callback
do
    local obj = { scale = 1 }
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { scale = 2 })
    seq:callback(function() print("  halfway callback! scale=" .. obj.scale) end)
    seq:tween(0.5, obj, { scale = 1 })
    seq:onComplete(function() print("  sequence complete") end)
    seq:start()

    lurek.tween.update(0.5)
    lurek.tween.update(0.5)
end

--@api: LTweenSequence:getProgress
do
    local obj = { w = 0 }
    local seq = lurek.tween.sequence()
    seq:tween(1.0, obj, { w = 100 })
    seq:tween(1.0, obj, { w = 0 })
    seq:start()
    lurek.tween.update(1.0)

    print("progress at midpoint = " .. seq:getProgress())
    seq:cancel()
    print("active after cancel = " .. tostring(seq:isActive()))
end

--@api: LTweenSequence:cancel
do
    local obj = { w = 0 }
    local seq = lurek.tween.sequence()
    seq:tween(1.0, obj, { w = 100 })
    seq:tween(1.0, obj, { w = 0 })
    seq:start()
    lurek.tween.update(1.0)

    print("progress at midpoint = " .. seq:getProgress())
    seq:cancel()
    print("active after cancel = " .. tostring(seq:isActive()))
end

--@api: lurek.tween.parallel
do
    local a = { x = 0 }
    local b = { y = 0 }
    local c = { rot = 0 }
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

--@api: LTweenParallel:add
do
    local obj1 = { alpha = 1 }
    local obj2 = { scale = 1 }
    local tw1 = lurek.tween.tween(0.8, obj1, { alpha = 0 })
    local tw2 = lurek.tween.tween(0.8, obj2, { scale = 3 })
    local par = lurek.tween.parallel()

    par:add(tw1)
    par:add(tw2)
    par:onComplete(function() print("  parallel group done") end)
    par:start()

    lurek.tween.update(0.8)
    print("alpha=" .. obj1.alpha .. " scale=" .. obj2.scale)
end

--@api: LTweenParallel:cancel
do
    local a = { x = 0 }
    local b = { y = 0 }
    local par = lurek.tween.parallel()
    par:tween(2.0, a, { x = 100 })
    par:tween(2.0, b, { y = 100 })
    par:start()

    lurek.tween.update(1.0)
    par:cancel()
    print("cancelled: active=" .. tostring(par:isActive()))
    print("x=" .. a.x .. " y=" .. b.y)
end

--@api: lurek.tween.delay
do
    local d = lurek.tween.delay(1.5, function() print("  delay complete") end)
    print("delay active = " .. tostring(d:isActive()))
    lurek.tween.update(1.5)
    print("delay done = " .. tostring(not d:isActive()))
end

--@api: lurek.tween.tweenChain
do
    local obj = { x = 0, y = 0 }
    local chain = lurek.tween.tweenChain({
        { duration = 0.5, target = obj, fields = { x = 100 }, easing = "easeOutQuad" },
        { duration = 0.5, target = obj, fields = { y = 100 }, easing = "easeInQuad" },
    })

    print("chain active = " .. tostring(chain:isActive()))
    lurek.tween.update(0.5)
    lurek.tween.update(0.5)
    print("chain result: x=" .. obj.x .. " y=" .. obj.y)
end

--@api: lurek.tween.newChain
do
    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.1, label = "intro" })
    print("steps = " .. tostring(chain:len()))
end

--@api: LTweenChain:to
do
    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 10 }, 0.25, "linear")
    chain:start()
    lurek.tween.update(0.25)
    print("x = " .. tostring(obj.x))
end

--@api: LTweenChain:wait
do
    local fired = false
    local chain = lurek.tween.newChain()
    chain:wait(0.1, function() fired = true end)
    chain:start()
    lurek.tween.update(0.1)
    print("wait fired = " .. tostring(fired))
end

--@api: LTweenChain:call
do
    local called = false
    local chain = lurek.tween.newChain()
    chain:call(function() called = true end)
    chain:start()
    lurek.tween.update(0.01)
    print("called = " .. tostring(called))
end

--@api: LTweenChain:loop
do
    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 1 }, 0.01, "linear"):loop(2)
    chain:start()
    lurek.tween.update(0.03)
    print("iteration = " .. tostring(chain:getIteration()))
end

--@api: LTweenChain:onLoop
do
    local loops = 0
    local chain = lurek.tween.newChain()
    chain:to({ x = 0 }, { x = 1 }, 0.01, "linear"):loop(2):onLoop(function() loops = loops + 1 end)
    chain:start()
    lurek.tween.update(0.03)
    print("loops = " .. tostring(loops))
end

--@api: LTweenChain:onComplete
do
    local done = false
    local chain = lurek.tween.newChain()
    chain:wait(0.01):onComplete(function() done = true end)
    chain:start()
    lurek.tween.update(0.02)
    print("complete callback = " .. tostring(done))
end

--@api: LTweenChain:start
do
    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 10 }, 0.1, "linear")
    chain:start()
    print("active = " .. tostring(chain:isActive()))
end

--@api: LTweenChain:pause
do
    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 10 }, 0.1, "linear")
    chain:start()
    lurek.tween.update(0.05)
    chain:pause()
    print("progress after pause = " .. tostring(chain:getProgress()))
end

--@api: LTweenChain:resume
do
    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 10 }, 0.1, "linear")
    chain:start()
    chain:pause()
    chain:resume()
    print("active after resume = " .. tostring(chain:isActive()))
end

--@api: LTweenChain:stop
do
    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 10 }, 0.1, "linear")
    chain:start()
    chain:stop()
    print("active after stop = " .. tostring(chain:isActive()))
end

--@api: LTweenChain:getProgress
do
    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 10 }, 0.2, "linear")
    chain:start()
    lurek.tween.update(0.1)
    print("progress = " .. tostring(chain:getProgress()))
end

--@api: LTweenChain:isComplete
do
    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 10 }, 0.05, "linear")
    chain:start()
    lurek.tween.update(0.06)
    print("isComplete = " .. tostring(chain:isComplete()))
end

--@api: LTweenChain:isActive
do
    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 10 }, 0.1, "linear")
    chain:start()
    print("isActive = " .. tostring(chain:isActive()))
end

--@api: LTweenChain:getIteration
do
    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 1 }, 0.01, "linear"):loop(2)
    chain:start()
    lurek.tween.update(0.03)
    print("iteration = " .. tostring(chain:getIteration()))
end

--@api: LTweenChain:clear
do
    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.1 })
    chain:clear()
    print("len after clear = " .. tostring(chain:len()))
end

--@api: LTweenChain:cursor
do
    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.1 })
    print("cursor = " .. tostring(chain:cursor()))
end

--@api: LTweenChain:isFinished
do
    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.01 })
    chain:tick(0.02)
    print("isFinished = " .. tostring(chain:isFinished()))
end

--@api: LTweenChain:isLooping
do
    local chain = lurek.tween.newChain()
    chain:setLooping(true)
    print("isLooping = " .. tostring(chain:isLooping()))
end

--@api: LTweenChain:jumpTo
do
    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.1, label = "a" })
    chain:push({ from = 1.0, to = 2.0, duration = 0.1, label = "b" })
    chain:jumpTo(2)
    print("cursor after jump = " .. tostring(chain:cursor()))
end

--@api: LTweenChain:len
do
    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.1 })
    chain:push({ from = 1.0, to = 2.0, duration = 0.1 })
    print("len = " .. tostring(chain:len()))
end

--@api: LTweenChain:push
do
    local chain = lurek.tween.newChain()
    local idx = chain:push({ from = 0.0, to = 1.0, duration = 0.1, label = "intro" })
    print("push index = " .. tostring(idx))
end

--@api: LTweenChain:reset
do
    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 5.0, duration = 1.0 })
    chain:tick(0.5)
    chain:reset()
    print("value after reset = " .. tostring(chain:value()))
end

--@api: LTweenChain:setLooping
do
    local chain = lurek.tween.newChain()
    chain:setLooping(true)
    print("looping = " .. tostring(chain:isLooping()))
end

--@api: LTweenChain:tick
do
    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.1, label = "step" })
    local events = chain:tick(0.2)
    print("tick events = " .. tostring(#events))
end

--@api: LTweenChain:type
do
    local chain = lurek.tween.newChain()
    print("type = " .. tostring(chain:type()))
    print("typeOf LTweenChain = " .. tostring(chain:typeOf("LTweenChain")))
end

--@api: LTweenChain:typeOf
do
    local chain = lurek.tween.newChain()
    print("typeOf LTweenChain = " .. tostring(chain:typeOf("LTweenChain")))
    print("type = " .. tostring(chain:type()))
end

--@api: LTweenChain:value
do
    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 5.0, duration = 1.0 })
    chain:tick(0.5)
    print("value = " .. tostring(chain:value()))
end

--- Tween Part 2: LTween extended, LTweenParallel, LTweenSequence, LTweenState, advanced module fns

--@api: Lto:getDuration
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")

    print("duration=" .. tw:getDuration())
    print("type=" .. tw:type())
end

--@api: LTween:await
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    local co = coroutine.create(function()
        tw:await()
        print("await resumed at x=" .. target.x)
    end)

    coroutine.resume(co)
    lurek.tween.update(1.0)
    print("coroutine status = " .. coroutine.status(co))
end

--@api: LTween:getDuration
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    print("duration=" .. tw:getDuration())
    print("remaining=" .. tw:getRemaining())
end

--@api: LTween:getEasingName
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    local ok, easing = pcall(function()
        return tw:getEasingName()
    end)
    print("easing=" .. tostring(ok and easing or "unavailable"))
    print("typeOf=" .. tostring(tw:typeOf("LTween")))
end

--@api: LTween:getElapsed
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    lurek.tween.update(0.25)
    print("elapsed=" .. tw:getElapsed())
    print("x=" .. target.x)
end

--@api: LTween:getProgress
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    lurek.tween.update(0.5)
    print("progress=" .. tw:getProgress())
    print("x=" .. target.x)
end

--@api: LTween:getRemaining
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    lurek.tween.update(0.25)
    print("remaining=" .. tw:getRemaining())
    print("active=" .. tostring(tw:isActive()))
end

--@api: LTween:isActive
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    print("active before = " .. tostring(tw:isActive()))
    tw:cancel()
    print("active after = " .. tostring(tw:isActive()))
end

--@api: LTween:setRelative
do
    local target = { x = 10.0 }
    local tw = lurek.tween.to(target, { x = 5 }, 1.0, "linear")
    tw:setRelative(true)
    lurek.tween.update(1.0)
    print("relative x=" .. target.x)
    print("type=" .. tw:type())
end

--@api: LTween:type
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    print("type=" .. tw:type())
    print("active=" .. tostring(tw:isActive()))
end

--@api: LTween:typeOf
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    print("typeOf LTween = " .. tostring(tw:typeOf("LTween")))
    print("typeOf Object = " .. tostring(tw:typeOf("Object")))
end

--@api: Lparallel:tween
do
    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() print("parallel_done") end) ; print("par_active=" .. tostring(par:isActive()))
    print("par_type=" .. par:type()) ; print("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end

--@api: LTweenParallel:isActive
do
    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() print("parallel_done") end) ; print("par_active=" .. tostring(par:isActive()))
    print("par_type=" .. par:type()) ; print("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end

--@api: LTweenParallel:onComplete
do
    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() print("parallel_done") end) ; print("par_active=" .. tostring(par:isActive()))
    print("par_type=" .. par:type()) ; print("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end

--@api: LTweenParallel:start
do
    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() print("parallel_done") end) ; print("par_active=" .. tostring(par:isActive()))
    print("par_type=" .. par:type()) ; print("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end

--@api: LTweenParallel:tween
do
    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() print("parallel_done") end) ; print("par_active=" .. tostring(par:isActive()))
    print("par_type=" .. par:type()) ; print("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end

--@api: LTweenParallel:type
do
    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() print("parallel_done") end) ; print("par_active=" .. tostring(par:isActive()))
    print("par_type=" .. par:type()) ; print("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end

--@api: LTweenParallel:typeOf
do
    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() print("parallel_done") end) ; print("par_active=" .. tostring(par:isActive()))
    print("par_type=" .. par:type()) ; print("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end

--@api: Lsequence:tween
do
    local obj = { x = 0.0, alpha = 1.0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { x = 100 }, "linear")
    seq:delay(0.1, function() print("seq_delay_cb") end)
    seq:tween(0.5, obj, { alpha = 0 }, "easeout")
    seq:start()

    lurek.tween.update(0.5)
    print("seq x=" .. obj.x)
    print("seq alpha=" .. obj.alpha)
end

--@api: LTweenSequence:onComplete
do
    local obj = { x = 0.0, alpha = 1.0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { x = 100 }, "linear")
    seq:onComplete(function() print("seq_done") end)
    seq:start()
    lurek.tween.update(0.5)
    print("seq active = " .. tostring(seq:isActive()))
end

--@api: LTweenSequence:tween
do
    local obj = { x = 0.0, alpha = 1.0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { x = 100 }, "linear")
    seq:tween(0.5, obj, { alpha = 0 }, "easeout")
    seq:start()
    lurek.tween.update(0.5)
    print("seq x=" .. obj.x)
    print("seq active = " .. tostring(seq:isActive()))
end

--@api: LTweenSequence:await
do
    local obj = { x = 0.0 }
    local seq = lurek.tween.sequence()
    local co = coroutine.create(function()
        seq:await()
        print("sequence await resumed at x=" .. obj.x)
    end)

    seq:tween(0.5, obj, { x = 100 }, "linear")
    seq:start()
    coroutine.resume(co)
    lurek.tween.update(0.5)
    print("coroutine status = " .. coroutine.status(co))
end

--@api: LTweenSequence:isActive
do
    local obj = { x = 0.0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { x = 100 }, "linear")
    print("seq active before = " .. tostring(seq:isActive()))
    seq:start()
    print("seq active after = " .. tostring(seq:isActive()))
end

--@api: LTweenSequence:start
do
    local obj = { x = 0.0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { x = 100 }, "linear")
    seq:start()
    print("seq active = " .. tostring(seq:isActive()))
    lurek.tween.update(0.5)
    print("seq x = " .. obj.x)
end

--@api: LTweenSequence:type
do
    local seq = lurek.tween.sequence()
    print("seq type = " .. seq:type())
    print("seq typeOf = " .. tostring(seq:typeOf("LTweenSequence")))
end

--@api: LTweenSequence:typeOf
do
    local seq = lurek.tween.sequence()
    print("typeOf LTweenSequence = " .. tostring(seq:typeOf("LTweenSequence")))
    print("typeOf Object = " .. tostring(seq:typeOf("Object")))
end

--@api: LTweenState:isComplete
do
    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    print("t=" .. state:t())
    print("lerp=" .. state:lerp(0, 100))
    print("complete=" .. tostring(state:isComplete()))
    print("type=" .. state:type())
    print("typeOf=" .. tostring(state:typeOf("LTweenState")))
end

--@api: LTweenState:lerp
do
    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    print("t=" .. state:t())
    print("lerp=" .. state:lerp(0, 100))
    print("complete=" .. tostring(state:isComplete()))
    print("type=" .. state:type())
    print("typeOf=" .. tostring(state:typeOf("LTweenState")))
end

--@api: LTweenState:t
do
    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    print("t=" .. state:t())
    print("lerp=" .. state:lerp(0, 100))
    print("complete=" .. tostring(state:isComplete()))
    print("type=" .. state:type())
    print("typeOf=" .. tostring(state:typeOf("LTweenState")))
end

--@api: LTweenState:tick
do
    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    print("t=" .. state:t())
    print("lerp=" .. state:lerp(0, 100))
    print("complete=" .. tostring(state:isComplete()))
    print("type=" .. state:type())
    print("typeOf=" .. tostring(state:typeOf("LTweenState")))
end

--@api: LTweenState:type
do
    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    print("t=" .. state:t())
    print("lerp=" .. state:lerp(0, 100))
    print("complete=" .. tostring(state:isComplete()))
    print("type=" .. state:type())
    print("typeOf=" .. tostring(state:typeOf("LTweenState")))
end

--@api: LTweenState:typeOf
do
    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    print("t=" .. state:t())
    print("lerp=" .. state:lerp(0, 100))
    print("complete=" .. tostring(state:isComplete()))
    print("type=" .. state:type())
    print("typeOf=" .. tostring(state:typeOf("LTweenState")))
end

--@api: lurek.tween.cancelAll
do
    local target = { v = 0.0 }
    lurek.tween.to(target, { v = 1 }, 2.0, "linear")
    print("active=" .. lurek.tween.getActiveCount())
    lurek.tween.cancelAll()
    print("active_after=" .. lurek.tween.getActiveCount())
    local names = lurek.tween.getEasingNames()
    print("easing_count=" .. #names)
end

--@api: lurek.tween.getEasingNames
do
    local target = { v = 0.0 }
    lurek.tween.to(target, { v = 1 }, 2.0, "linear")
    print("active=" .. lurek.tween.getActiveCount())
    lurek.tween.cancelAll()
    print("active_after=" .. lurek.tween.getActiveCount())
    local names = lurek.tween.getEasingNames()
    print("easing_count=" .. #names)
end

--@api: LSpring:isActive
do
    local obj = { x = 0 }
    local sp = lurek.tween.spring(obj, { x = 100 }, { stiffness = 200, damping = 20 })
    sp:update(0.016)
    local active = sp:isActive()
    local settled = sp:isSettled()
    print("spring active:", active, "settled:", settled)
end

--@api: LSpring:isSettled
do
    local obj = { x = 0 }
    local sp = lurek.tween.spring(obj, { x = 100 }, { stiffness = 200, damping = 20 })
    sp:update(0.016)
    local active = sp:isActive()
    local settled = sp:isSettled()
    print("spring active:", active, "settled:", settled)
end

--@api: LSpring:update
do
    local obj = { x = 0 }
    local sp = lurek.tween.spring(obj, { x = 100 }, { stiffness = 200, damping = 20 })
    local still_active = sp:update(0.016)
    print("spring x:", obj.x)
    print("spring still active:", still_active)
end

--@api: LSpring:type
do
    local state = {v = 0}
    local sp = lurek.tween.spring(state, {v = 50}, {stiffness = 150, damping = 15})
    local t = sp:type()
    local ok = sp:typeOf("LSpring")
    print("spring type:", t, "typeOf:", ok)
end

--@api: LSpring:typeOf
do
    local state = {v = 0}
    local sp = lurek.tween.spring(state, {v = 50}, {stiffness = 150, damping = 15})
    local t = sp:type()
    local ok = sp:typeOf("LSpring")
    print("spring type:", t, "typeOf:", ok)
end
