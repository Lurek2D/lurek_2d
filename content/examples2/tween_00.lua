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

print("tween_00.lua")
