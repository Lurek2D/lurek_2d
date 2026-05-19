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

print("tween_01.lua")
