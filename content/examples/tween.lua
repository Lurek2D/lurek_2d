-- content/examples/tween.lua
-- Auto-generated from content/examples2/tween_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/tween.lua

--- Tween Module Part 1: basic tweens, easing, LTween, LTweenState, springs, color tweens


--@api: lurek.tween.tween
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { x = 0, y = 0 }
    local tw = lurek.tween.tween(1.0, obj, { x = 100, y = 50 })
    example_print_log("type = " .. tw:type())
    lurek.tween.update(0.5)
    example_print_log("at 0.5s: x=" .. obj.x .. " y=" .. obj.y)
end

--@api: lurek.tween.update
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local camera = { x = -240, y = 96 }
    local focus = { x = 0, y = 64 }
    local pan = lurek.tween.to(camera, focus, 0.6, "easeOutQuad")
    lurek.tween.update(0.3)
    lurek.log.info("camera midpoint x=" .. string.format("%.1f", camera.x) .. " y=" .. string.format("%.1f", camera.y))
    lurek.tween.update(0.3)
    lurek.log.info("camera settled active=" .. tostring(pan:isActive()))
end

--@api: lurek.tween.to
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bossBar = { width = 24, alpha = 0.2 }
    local reveal = lurek.tween.to(bossBar, { width = 220, alpha = 1.0 }, 0.8, "easeOutCubic")
    lurek.log.info("boss bar fields=" .. table.concat(reveal:getFields(), ", "))
    lurek.tween.update(0.4)
    lurek.log.info("boss bar width=" .. string.format("%.1f", bossBar.width))
    lurek.tween.update(0.4)
    lurek.log.info("boss bar remaining=" .. string.format("%.2f", reveal:getRemaining()))
end

--@api: LTween:onComplete
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local chest = { scale = 0.8, glow = 0.0 }
    local tw = lurek.tween.tween(0.6, chest, { scale = 1.2, glow = 1.0 })
    tw:onComplete(function() lurek.log.info("chest reveal complete scale=" .. string.format("%.2f", chest.scale)) end)
    lurek.tween.update(0.3)
    lurek.log.info("chest reveal active=" .. tostring(tw:isActive()))
    lurek.tween.update(0.3)
    lurek.log.info("chest glow=" .. string.format("%.2f", chest.glow))
end

--@api: LTween:onUpdate
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local waypoint = { x = 0, y = 0 }
    local lastT = 0.0
    local tw = lurek.tween.tween(0.5, waypoint, { x = 96, y = 32 })
    tw:onUpdate(function(t) lastT = t end)
    lurek.tween.update(0.25)
    lurek.log.info("patrol progress=" .. string.format("%.2f", lastT))
    lurek.tween.update(0.25)
    lurek.log.info("patrol x=" .. string.format("%.1f", waypoint.x))
end

--@api: LTween:onCancel
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local shutter = { y = 0 }
    local cancelled = false
    local tw = lurek.tween.tween(1.0, shutter, { y = -180 })
    tw:onCancel(function() cancelled = true end)
    lurek.tween.update(0.2)
    tw:cancel()
    lurek.log.info("shutter cancelled=" .. tostring(cancelled))
    lurek.log.info("shutter active=" .. tostring(tw:isActive()))
end

--@api: LTween:pause
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { rotation = 0 }
    local tw = lurek.tween.tween(2.0, obj, { rotation = 360 })

    lurek.tween.update(0.5)
    example_print_log("before pause: " .. obj.rotation)
    tw:pause()
    lurek.tween.update(1.0)
    example_print_log("while paused: " .. obj.rotation)
end

--@api: LTween:resume
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { rotation = 0 }
    local tw = lurek.tween.tween(2.0, obj, { rotation = 360 })

    lurek.tween.update(0.5)
    example_print_log("before pause: " .. obj.rotation)
    tw:pause()
    lurek.tween.update(1.0)
    example_print_log("while paused: " .. obj.rotation)

    tw:resume()
    lurek.tween.update(0.5)
    example_print_log("after resume: " .. obj.rotation)
end

--@api: LTween:cancel
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { w = 100 }
    local tw = lurek.tween.tween(1.0, obj, { w = 200 })

    lurek.tween.update(0.3)
    example_print_log("before cancel: w=" .. obj.w)
    tw:cancel()
    example_print_log("active after cancel = " .. tostring(tw:isActive()))
    lurek.tween.update(1.0)
    example_print_log("after update: w=" .. obj.w)
end

--@api: LTween:setRepeat
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local beacon = { alpha = 0.0 }
    local tw = lurek.tween.tween(0.2, beacon, { alpha = 1.0 })
    tw:setRepeat(2)
    lurek.tween.update(0.2)
    lurek.log.info("beacon pulse alpha=" .. string.format("%.2f", beacon.alpha))
    lurek.tween.update(0.2)
    lurek.log.info("beacon pulse active=" .. tostring(tw:isActive()))
end

--@api: LTween:setYoyo
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local prompt = { y = 0 }
    local tw = lurek.tween.tween(0.2, prompt, { y = -14 })
    tw:setRepeat(1)
    tw:setYoyo(true)
    lurek.tween.update(0.2)
    lurek.tween.update(0.2)
    lurek.log.info("jump prompt returned y=" .. string.format("%.1f", prompt.y))
end

--@api: LTween:relative
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local player = { x = 48, y = 96 }
    local tw = lurek.tween.tween(0.4, player, { x = 32, y = -16 }):relative(true)
    lurek.tween.update(0.2)
    lurek.log.info("dash midpoint x=" .. string.format("%.1f", player.x) .. " y=" .. string.format("%.1f", player.y))
    lurek.tween.update(0.2)
    lurek.log.info("dash end x=" .. string.format("%.1f", player.x) .. " y=" .. string.format("%.1f", player.y))
end

--@api: LTween:getFields
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local panel = { alpha = 0.0, x = -320, y = 24 }
    local tw = lurek.tween.tween(0.5, panel, { alpha = 1.0, x = 16, y = 40 })
    local fields = tw:getFields()
    lurek.log.info("panel fields=" .. table.concat(fields, ", "))
    lurek.tween.update(0.25)
    lurek.log.info("panel midpoint x=" .. string.format("%.1f", panel.x))
    lurek.tween.update(0.25)
    lurek.log.info("panel alpha=" .. string.format("%.2f", panel.alpha))
end

--@api: lurek.tween.tweenColor
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local color = { r = 1.0, g = 0.0, b = 0.0, a = 1.0 }
    local tw = lurek.tween.tweenColor(2.0, color, { r = 0.0, g = 0.0, b = 1.0 }, "linear")

    lurek.tween.update(1.0)
    example_print_log("midpoint: r=" .. string.format("%.2f", color.r) .. " g=" .. string.format("%.2f", color.g) .. " b=" .. string.format("%.2f", color.b))
    lurek.tween.update(1.0)
    example_print_log("end: r=" .. color.r .. " b=" .. color.b)
end

--@api: lurek.tween.newState
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local state = lurek.tween.newState(2.0, "easeInOutCubic")
    example_print_log("type = " .. state:type())
    example_print_log("complete = " .. tostring(state:isComplete()))

    state:tick(1.0)
    local val = state:lerp(0.0, 1.0)
    example_print_log("at 1.0s: eased value = " .. string.format("%.3f", val))
    example_print_log("raw t = " .. string.format("%.3f", state:t()))

    local interp = state:lerp(100, 200)
    example_print_log("lerp(100, 200) = " .. string.format("%.1f", interp))
    state:tick(1.0)
    example_print_log("complete = " .. tostring(state:isComplete()))
end

--@api: LTweenState:reset
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local state = lurek.tween.newState(1.0)
    state:tick(1.0)
    example_print_log("done = " .. tostring(state:isComplete()))
    state:reset()
    example_print_log("after reset, done = " .. tostring(state:isComplete()))
    example_print_log("t = " .. state:t())
end

--@api: lurek.tween.spring
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { x = 0, y = 0 }
    local spring = lurek.tween.spring(obj, { x = 100, y = 50 }, {
        stiffness = 200,
        damping = 15,
        precision = 0.01,
    })

    example_print_log("type = " .. spring:type())
    example_print_log("active = " .. tostring(spring:isActive()))
    for i = 1, 10 do spring:update(1 / 60) end
    example_print_log("after 10 frames: x=" .. string.format("%.1f", obj.x) .. " y=" .. string.format("%.1f", obj.y))
    example_print_log("settled = " .. tostring(spring:isSettled()))
end

--@api: LSpring:setTarget
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { size = 50 }
    local spring = lurek.tween.spring(obj, { size = 100 })
    spring:setStiffness(300)
    spring:setDamping(20)

    for i = 1, 30 do
        spring:update(1 / 60)
    end
    example_print_log("size = " .. string.format("%.1f", obj.size))

    spring:setTarget({ size = 0 })
    for i = 1, 60 do
        spring:update(1 / 60)
    end

    local pos = spring:getPosition("size")
    example_print_log("retargeted size = " .. string.format("%.1f", obj.size))
    example_print_log("getPosition = " .. tostring(pos))
end

--@api: LSpring:setStiffness
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { size = 50 }
    local spring = lurek.tween.spring(obj, { size = 100 })
    spring:setStiffness(300)
    spring:update(1 / 10)
    example_print_log("size after stronger spring = " .. string.format("%.1f", obj.size))
    example_print_log("position = " .. tostring(spring:getPosition("size")))
end

--@api: LSpring:setDamping
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { size = 50 }
    local spring = lurek.tween.spring(obj, { size = 100 })
    spring:setDamping(20)
    spring:update(1 / 10)
    example_print_log("size after damping = " .. string.format("%.1f", obj.size))
    example_print_log("settled = " .. tostring(spring:isSettled()))
end

--@api: LSpring:getPosition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { size = 50 }
    local spring = lurek.tween.spring(obj, { size = 100 })
    spring:update(1 / 10)

    local pos = spring:getPosition("size")
    example_print_log("size = " .. string.format("%.1f", obj.size))
    example_print_log("getPosition = " .. tostring(pos))
end

--@api: LSpring:cancel
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { val = 0 }
    local spring = lurek.tween.spring(obj, { val = 100 })
    spring:update(1 / 60)
    spring:cancel()
    example_print_log("active after cancel = " .. tostring(spring:isActive()))
end

--@api: lurek.tween.getActiveCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = { x = 0 }
    local b = { y = 0 }
    lurek.tween.tween(1.0, a, { x = 10 })
    lurek.tween.tween(2.0, b, { y = 20 })
    example_print_log("active count = " .. lurek.tween.getActiveCount())
    lurek.tween.cancelAll()
    example_print_log("after cancelAll = " .. lurek.tween.getActiveCount())
end

--@api: lurek.tween.registerEasing
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.tween.registerEasing("bounce3", function(t)
        return 1 - math.abs(math.cos(t * math.pi * 3)) * (1 - t)
    end)

    local names = lurek.tween.getEasingNames()
    local obj = { v = 0 }
    example_print_log("available easings: " .. #names)
    lurek.tween.tween(1.0, obj, { v = 1 }, "bounce3")
    lurek.tween.update(0.5)
    example_print_log("custom easing at 0.5: " .. string.format("%.3f", obj.v))
end

--- Tween Module Part 2: sequences, parallels, delay, tweenChain, update

--@api: lurek.tween.sequence
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { x = 0, y = 0 }
    local seq = lurek.tween.sequence()
    example_print_log("type = " .. seq:type())

    seq:tween(0.5, obj, { x = 100 }, "easeOutQuad")
    seq:tween(0.5, obj, { y = 100 }, "easeInQuad")
    seq:start()

    example_print_log("active = " .. tostring(seq:isActive()))
    lurek.tween.update(0.5)
    example_print_log("after step 1: x=" .. obj.x .. " y=" .. obj.y)
    lurek.tween.update(0.5)
    example_print_log("after step 2: x=" .. obj.x .. " y=" .. obj.y)
end

--@api: LTweenSequence:delay
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { alpha = 0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.3, obj, { alpha = 1 })
    seq:delay(0.5)
    seq:tween(0.3, obj, { alpha = 0 })
    seq:start()

    lurek.tween.update(0.3)
    example_print_log("fade in done: alpha=" .. obj.alpha)
    lurek.tween.update(0.5)
    example_print_log("after delay: alpha=" .. obj.alpha)
    lurek.tween.update(0.3)
    example_print_log("fade out done: alpha=" .. obj.alpha)
end

--@api: LTweenSequence:callback
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { scale = 1 }
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { scale = 2 })
    seq:callback(function() example_print_log("  halfway callback! scale=" .. obj.scale) end)
    seq:tween(0.5, obj, { scale = 1 })
    seq:onComplete(function() example_print_log("  sequence complete") end)
    seq:start()

    lurek.tween.update(0.5)
    lurek.tween.update(0.5)
end

--@api: LTweenSequence:getProgress
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { w = 0 }
    local seq = lurek.tween.sequence()
    seq:tween(1.0, obj, { w = 100 })
    seq:tween(1.0, obj, { w = 0 })
    seq:start()
    lurek.tween.update(1.0)

    example_print_log("progress at midpoint = " .. seq:getProgress())
    seq:cancel()
    example_print_log("active after cancel = " .. tostring(seq:isActive()))
end

--@api: LTweenSequence:cancel
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { w = 0 }
    local seq = lurek.tween.sequence()
    seq:tween(1.0, obj, { w = 100 })
    seq:tween(1.0, obj, { w = 0 })
    seq:start()
    lurek.tween.update(1.0)

    example_print_log("progress at midpoint = " .. seq:getProgress())
    seq:cancel()
    example_print_log("active after cancel = " .. tostring(seq:isActive()))
end

--@api: lurek.tween.parallel
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = { x = 0 }
    local b = { y = 0 }
    local c = { rot = 0 }
    local par = lurek.tween.parallel()
    example_print_log("type = " .. par:type())

    par:tween(1.0, a, { x = 200 }, "linear")
    par:tween(1.0, b, { y = 150 }, "easeOutQuad")
    par:tween(1.0, c, { rot = 360 }, "easeInOutSine")
    par:start()

    example_print_log("active = " .. tostring(par:isActive()))
    lurek.tween.update(0.5)
    example_print_log("midpoint: x=" .. a.x .. " y=" .. string.format("%.0f", b.y) .. " rot=" .. c.rot)
    lurek.tween.update(0.5)
    example_print_log("done: x=" .. a.x .. " y=" .. b.y .. " rot=" .. c.rot)
end

--@api: LTweenParallel:add
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj1 = { alpha = 1 }
    local obj2 = { scale = 1 }
    local tw1 = lurek.tween.tween(0.8, obj1, { alpha = 0 })
    local tw2 = lurek.tween.tween(0.8, obj2, { scale = 3 })
    local par = lurek.tween.parallel()

    par:add(tw1)
    par:add(tw2)
    par:onComplete(function() example_print_log("  parallel group done") end)
    par:start()

    lurek.tween.update(0.8)
    example_print_log("alpha=" .. obj1.alpha .. " scale=" .. obj2.scale)
end

--@api: LTweenParallel:cancel
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = { x = 0 }
    local b = { y = 0 }
    local par = lurek.tween.parallel()
    par:tween(2.0, a, { x = 100 })
    par:tween(2.0, b, { y = 100 })
    par:start()

    lurek.tween.update(1.0)
    par:cancel()
    example_print_log("cancelled: active=" .. tostring(par:isActive()))
    example_print_log("x=" .. a.x .. " y=" .. b.y)
end

--@api: lurek.tween.delay
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local gate = { locked = true, alpha = 0.0 }
    local d = lurek.tween.delay(1.5, function()
        gate.locked = false
        gate.alpha = 1.0
    end)
    lurek.tween.update(0.75)
    lurek.log.info("gate warning visible=" .. string.format("%.1f", gate.alpha))
    lurek.tween.update(0.75)
    lurek.log.info("gate unlocked=" .. tostring(not gate.locked))
end

--@api: lurek.tween.tweenChain
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { x = 0, y = 0 }
    local chain = lurek.tween.tweenChain({
        { duration = 0.5, target = obj, fields = { x = 100 }, easing = "easeOutQuad" },
        { duration = 0.5, target = obj, fields = { y = 100 }, easing = "easeInQuad" },
    })

    example_print_log("chain active = " .. tostring(chain:isActive()))
    lurek.tween.update(0.5)
    lurek.tween.update(0.5)
    example_print_log("chain result: x=" .. obj.x .. " y=" .. obj.y)
end

--@api: lurek.tween.newChain
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.2, label = "raise_platform" })
    chain:push({ from = 1.0, to = 0.8, duration = 0.1, label = "settle_platform" })
    chain:tick(0.2)
    lurek.log.info("platform cue value=" .. string.format("%.2f", chain:value()))
    lurek.log.info("platform cue steps=" .. tostring(chain:len()))
end

--@api: LTweenChain:to
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 10 }, 0.25, "linear")
    chain:start()
    lurek.tween.update(0.25)
    example_print_log("x = " .. tostring(obj.x))
end

--@api: LTweenChain:wait
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fired = false
    local chain = lurek.tween.newChain()
    chain:wait(0.1, function() fired = true end)
    chain:start()
    lurek.tween.update(0.1)
    example_print_log("wait fired = " .. tostring(fired))
end

--@api: LTweenChain:call
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local called = false
    local chain = lurek.tween.newChain()
    chain:call(function() called = true end)
    chain:start()
    lurek.tween.update(0.01)
    example_print_log("called = " .. tostring(called))
end

--@api: LTweenChain:loop
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 1 }, 0.01, "linear"):loop(2)
    chain:start()
    lurek.tween.update(0.03)
    example_print_log("iteration = " .. tostring(chain:getIteration()))
end

--@api: LTweenChain:onLoop
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local loops = 0
    local chain = lurek.tween.newChain()
    chain:to({ x = 0 }, { x = 1 }, 0.01, "linear"):loop(2):onLoop(function() loops = loops + 1 end)
    chain:start()
    lurek.tween.update(0.03)
    example_print_log("loops = " .. tostring(loops))
end

--@api: LTweenChain:onComplete
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local done = false
    local chain = lurek.tween.newChain()
    chain:wait(0.01):onComplete(function() done = true end)
    chain:start()
    lurek.tween.update(0.02)
    example_print_log("complete callback = " .. tostring(done))
end

--@api: LTweenChain:start
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 10 }, 0.1, "linear")
    chain:start()
    example_print_log("active = " .. tostring(chain:isActive()))
end

--@api: LTweenChain:pause
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 10 }, 0.1, "linear")
    chain:start()
    lurek.tween.update(0.05)
    chain:pause()
    example_print_log("progress after pause = " .. tostring(chain:getProgress()))
end

--@api: LTweenChain:resume
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 10 }, 0.1, "linear")
    chain:start()
    chain:pause()
    chain:resume()
    example_print_log("active after resume = " .. tostring(chain:isActive()))
end

--@api: LTweenChain:stop
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 10 }, 0.1, "linear")
    chain:start()
    chain:stop()
    example_print_log("active after stop = " .. tostring(chain:isActive()))
end

--@api: LTweenChain:getProgress
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 10 }, 0.2, "linear")
    chain:start()
    lurek.tween.update(0.1)
    example_print_log("progress = " .. tostring(chain:getProgress()))
end

--@api: LTweenChain:isComplete
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 10 }, 0.05, "linear")
    chain:start()
    lurek.tween.update(0.06)
    example_print_log("isComplete = " .. tostring(chain:isComplete()))
end

--@api: LTweenChain:isActive
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 10 }, 0.1, "linear")
    chain:start()
    example_print_log("isActive = " .. tostring(chain:isActive()))
end

--@api: LTweenChain:getIteration
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 1 }, 0.01, "linear"):loop(2)
    chain:start()
    lurek.tween.update(0.03)
    example_print_log("iteration = " .. tostring(chain:getIteration()))
end

--@api: LTweenChain:clear
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.1, label = "windup" })
    chain:push({ from = 1.0, to = 0.4, duration = 0.1, label = "release" })
    lurek.log.info("camera shake steps before clear=" .. tostring(chain:len()))
    chain:clear()
    lurek.log.info("camera shake steps after clear=" .. tostring(chain:len()))
    lurek.log.info("camera shake cursor=" .. tostring(chain:cursor()))
end

--@api: LTweenChain:cursor
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.1, label = "charge" })
    chain:push({ from = 1.0, to = 0.0, duration = 0.1, label = "release" })
    lurek.log.info("beam cursor before tick=" .. tostring(chain:cursor()))
    chain:tick(0.12)
    lurek.log.info("beam cursor after tick=" .. tostring(chain:cursor()))
    lurek.log.info("beam value=" .. string.format("%.2f", chain:value()))
end

--@api: LTweenChain:isFinished
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 0.5, duration = 0.01, label = "flare_in" })
    chain:push({ from = 0.5, to = 0.0, duration = 0.01, label = "flare_out" })
    lurek.log.info("muzzle flash finished before=" .. tostring(chain:isFinished()))
    chain:tick(0.01)
    chain:tick(0.02)
    lurek.log.info("muzzle flash finished after=" .. tostring(chain:isFinished()))
end

--@api: LTweenChain:isLooping
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.1, label = "radar_ping" })
    chain:setLooping(true)
    lurek.log.info("radar looping before tick=" .. tostring(chain:isLooping()))
    chain:tick(0.15)
    lurek.log.info("radar cursor=" .. tostring(chain:cursor()))
    lurek.log.info("radar looping after tick=" .. tostring(chain:isLooping()))
end

--@api: LTweenChain:jumpTo
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.1, label = "a" })
    chain:push({ from = 1.0, to = 2.0, duration = 0.1, label = "b" })
    chain:jumpTo(2)
    example_print_log("cursor after jump = " .. tostring(chain:cursor()))
end

--@api: LTweenChain:len
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.1, label = "intro" })
    chain:push({ from = 1.0, to = 2.0, duration = 0.1, label = "hold" })
    chain:push({ from = 2.0, to = 0.0, duration = 0.1, label = "outro" })
    lurek.log.info("warning banner steps=" .. tostring(chain:len()))
    chain:tick(0.1)
    lurek.log.info("warning banner cursor=" .. tostring(chain:cursor()))
end

--@api: LTweenChain:push
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local chain = lurek.tween.newChain()
    local fadeIn = chain:push({ from = 0.0, to = 1.0, duration = 0.1, label = "fade_in" })
    local fadeOut = chain:push({ from = 1.0, to = 0.0, duration = 0.1, label = "fade_out" })
    lurek.log.info("toast fade in index=" .. tostring(fadeIn))
    lurek.log.info("toast fade out index=" .. tostring(fadeOut))
    chain:tick(0.1)
    lurek.log.info("toast alpha=" .. string.format("%.2f", chain:value()))
end

--@api: LTweenChain:reset
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 5.0, duration = 1.0 })
    chain:tick(0.5)
    chain:reset()
    example_print_log("value after reset = " .. tostring(chain:value()))
end

--@api: LTweenChain:setLooping
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.1, label = "alarm_on" })
    chain:setLooping(true)
    chain:tick(0.15)
    lurek.log.info("alarm looping=" .. tostring(chain:isLooping()))
    lurek.log.info("alarm value=" .. string.format("%.2f", chain:value()))
    lurek.log.info("alarm cursor=" .. tostring(chain:cursor()))
end

--@api: LTweenChain:tick
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.1, label = "charge" })
    chain:push({ from = 1.0, to = 0.0, duration = 0.1, label = "cooldown" })
    local events = chain:tick(0.2)
    lurek.log.info("laser cue events=" .. tostring(#events))
    lurek.log.info("laser cue value=" .. string.format("%.2f", chain:value()))
    lurek.log.info("laser cue finished=" .. tostring(chain:isFinished()))
end

--@api: LTweenChain:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.2, label = "charge" })
    lurek.log.info("chain type=" .. tostring(chain:type()))
    lurek.log.info("chain typeOf LTweenChain=" .. tostring(chain:typeOf("LTweenChain")))
    chain:tick(0.1)
    lurek.log.info("chain value=" .. string.format("%.2f", chain:value()))
end

--@api: LTweenChain:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.2, label = "shield_up" })
    lurek.log.info("shield typeOf LTweenChain=" .. tostring(chain:typeOf("LTweenChain")))
    lurek.log.info("shield typeOf Object=" .. tostring(chain:typeOf("Object")))
    chain:tick(0.1)
    lurek.log.info("shield type=" .. tostring(chain:type()))
end

--@api: LTweenChain:value
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 5.0, duration = 1.0, label = "danger_fill" })
    chain:tick(0.5)
    lurek.log.info("danger meter value=" .. string.format("%.2f", chain:value()))
    lurek.log.info("danger meter cursor=" .. tostring(chain:cursor()))
    chain:tick(0.5)
    lurek.log.info("danger meter finished=" .. tostring(chain:isFinished()))
end

--- Tween Part 2: LTween extended, LTweenParallel, LTweenSequence, LTweenState, advanced module fns

--@api: Lto:getDuration
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tooltip = { alpha = 0.0, y = 24.0 }
    local tw = lurek.tween.to(tooltip, { alpha = 1.0, y = 8.0 }, 1.0, "linear")
    lurek.log.info("tooltip duration=" .. string.format("%.2f", tw:getDuration()))
    lurek.log.info("tooltip type=" .. tw:type())
    lurek.tween.update(0.5)
    lurek.log.info("tooltip remaining=" .. string.format("%.2f", tw:getRemaining()))
    lurek.log.info("tooltip alpha=" .. string.format("%.2f", tooltip.alpha))
end

--@api: LTween:await
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    local co = coroutine.create(function()
        tw:await()
        example_print_log("await resumed at x=" .. target.x)
    end)

    coroutine.resume(co)
    lurek.tween.update(1.0)
    example_print_log("coroutine status = " .. coroutine.status(co))
end

--@api: LTween:getDuration
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local popup = { x = -64.0, alpha = 0.0 }
    local tw = lurek.tween.to(popup, { x = 16.0, alpha = 1.0 }, 1.0, "linear")
    lurek.log.info("popup duration=" .. string.format("%.2f", tw:getDuration()))
    lurek.tween.update(0.25)
    lurek.log.info("popup remaining=" .. string.format("%.2f", tw:getRemaining()))
    lurek.log.info("popup elapsed=" .. string.format("%.2f", tw:getElapsed()))
    lurek.log.info("popup alpha=" .. string.format("%.2f", popup.alpha))
end

--@api: LTween:getEasingName
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    local ok, easing = pcall(function()
        return tw:getEasingName()
    end)
    example_print_log("easing=" .. tostring(ok and easing or "unavailable"))
    example_print_log("typeOf=" .. tostring(tw:typeOf("LTween")))
end

--@api: LTween:getElapsed
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    lurek.tween.update(0.25)
    example_print_log("elapsed=" .. tw:getElapsed())
    example_print_log("x=" .. target.x)
end

--@api: LTween:getProgress
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    lurek.tween.update(0.5)
    example_print_log("progress=" .. tw:getProgress())
    example_print_log("x=" .. target.x)
end

--@api: LTween:getRemaining
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    lurek.tween.update(0.25)
    example_print_log("remaining=" .. tw:getRemaining())
    example_print_log("active=" .. tostring(tw:isActive()))
end

--@api: LTween:isActive
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    example_print_log("active before = " .. tostring(tw:isActive()))
    tw:cancel()
    example_print_log("active after = " .. tostring(tw:isActive()))
end

--@api: LTween:setRelative
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local target = { x = 10.0 }
    local tw = lurek.tween.to(target, { x = 5 }, 1.0, "linear")
    tw:setRelative(true)
    lurek.tween.update(1.0)
    example_print_log("relative x=" .. target.x)
    example_print_log("type=" .. tw:type())
end

--@api: LTween:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cursor = { x = 0.0, alpha = 0.3 }
    local tw = lurek.tween.to(cursor, { x = 48.0, alpha = 1.0 }, 1.0, "linear")
    lurek.log.info("cursor tween type=" .. tw:type())
    lurek.log.info("cursor tween active=" .. tostring(tw:isActive()))
    lurek.tween.update(0.5)
    lurek.log.info("cursor tween progress=" .. string.format("%.2f", tw:getProgress()))
    lurek.log.info("cursor alpha=" .. string.format("%.2f", cursor.alpha))
end

--@api: LTween:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local reticle = { scale = 0.6 }
    local tw = lurek.tween.to(reticle, { scale = 1.0 }, 1.0, "linear")
    lurek.log.info("reticle typeOf LTween=" .. tostring(tw:typeOf("LTween")))
    lurek.log.info("reticle typeOf Object=" .. tostring(tw:typeOf("Object")))
    lurek.tween.update(0.5)
    lurek.log.info("reticle type=" .. tw:type())
    lurek.log.info("reticle scale=" .. string.format("%.2f", reticle.scale))
end

--@api: Lparallel:tween
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() example_print_log("parallel_done") end) ; example_print_log("par_active=" .. tostring(par:isActive()))
    example_print_log("par_type=" .. par:type()) ; example_print_log("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end

--@api: LTweenParallel:isActive
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() example_print_log("parallel_done") end) ; example_print_log("par_active=" .. tostring(par:isActive()))
    example_print_log("par_type=" .. par:type()) ; example_print_log("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end

--@api: LTweenParallel:onComplete
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() example_print_log("parallel_done") end) ; example_print_log("par_active=" .. tostring(par:isActive()))
    example_print_log("par_type=" .. par:type()) ; example_print_log("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end

--@api: LTweenParallel:start
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() example_print_log("parallel_done") end) ; example_print_log("par_active=" .. tostring(par:isActive()))
    example_print_log("par_type=" .. par:type()) ; example_print_log("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end

--@api: LTweenParallel:tween
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() example_print_log("parallel_done") end) ; example_print_log("par_active=" .. tostring(par:isActive()))
    example_print_log("par_type=" .. par:type()) ; example_print_log("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end

--@api: LTweenParallel:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() example_print_log("parallel_done") end) ; example_print_log("par_active=" .. tostring(par:isActive()))
    example_print_log("par_type=" .. par:type()) ; example_print_log("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end

--@api: LTweenParallel:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() example_print_log("parallel_done") end) ; example_print_log("par_active=" .. tostring(par:isActive()))
    example_print_log("par_type=" .. par:type()) ; example_print_log("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end

--@api: Lsequence:tween
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { x = 0.0, alpha = 1.0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { x = 100 }, "linear")
    seq:delay(0.1, function() example_print_log("seq_delay_cb") end)
    seq:tween(0.5, obj, { alpha = 0 }, "easeout")
    seq:start()

    lurek.tween.update(0.5)
    example_print_log("seq x=" .. obj.x)
    example_print_log("seq alpha=" .. obj.alpha)
end

--@api: LTweenSequence:onComplete
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { x = 0.0, alpha = 1.0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { x = 100 }, "linear")
    seq:onComplete(function() example_print_log("seq_done") end)
    seq:start()
    lurek.tween.update(0.5)
    example_print_log("seq active = " .. tostring(seq:isActive()))
end

--@api: LTweenSequence:tween
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { x = 0.0, alpha = 1.0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { x = 100 }, "linear")
    seq:tween(0.5, obj, { alpha = 0 }, "easeout")
    seq:start()
    lurek.tween.update(0.5)
    example_print_log("seq x=" .. obj.x)
    example_print_log("seq active = " .. tostring(seq:isActive()))
end

--@api: LTweenSequence:await
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { x = 0.0 }
    local seq = lurek.tween.sequence()
    local co = coroutine.create(function()
        seq:await()
        example_print_log("sequence await resumed at x=" .. obj.x)
    end)

    seq:tween(0.5, obj, { x = 100 }, "linear")
    seq:start()
    coroutine.resume(co)
    lurek.tween.update(0.5)
    example_print_log("coroutine status = " .. coroutine.status(co))
end

--@api: LTweenSequence:isActive
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { x = 0.0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { x = 100 }, "linear")
    example_print_log("seq active before = " .. tostring(seq:isActive()))
    seq:start()
    example_print_log("seq active after = " .. tostring(seq:isActive()))
end

--@api: LTweenSequence:start
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { x = 0.0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { x = 100 }, "linear")
    seq:start()
    example_print_log("seq active = " .. tostring(seq:isActive()))
    lurek.tween.update(0.5)
    example_print_log("seq x = " .. obj.x)
end

--@api: LTweenSequence:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local panel = { alpha = 0.0, x = -100.0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.2, panel, { alpha = 1.0, x = 0.0 }, "linear")
    seq:delay(0.1)
    lurek.log.info("sequence type=" .. seq:type())
    lurek.log.info("sequence typeOf=" .. tostring(seq:typeOf("LTweenSequence")))
    seq:start()
    lurek.tween.update(0.2)
    lurek.log.info("sequence panel x=" .. string.format("%.1f", panel.x))
end

--@api: LTweenSequence:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local alert = { alpha = 0.0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.2, alert, { alpha = 1.0 }, "linear")
    lurek.log.info("alert typeOf LTweenSequence=" .. tostring(seq:typeOf("LTweenSequence")))
    lurek.log.info("alert typeOf Object=" .. tostring(seq:typeOf("Object")))
    seq:start()
    lurek.tween.update(0.2)
    lurek.log.info("alert sequence type=" .. seq:type())
    lurek.log.info("alert alpha=" .. string.format("%.2f", alert.alpha))
end

--@api: LTweenState:isComplete
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    example_print_log("t=" .. state:t())
    example_print_log("lerp=" .. state:lerp(0, 100))
    example_print_log("complete=" .. tostring(state:isComplete()))
    example_print_log("type=" .. state:type())
    example_print_log("typeOf=" .. tostring(state:typeOf("LTweenState")))
end

--@api: LTweenState:lerp
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    example_print_log("t=" .. state:t())
    example_print_log("lerp=" .. state:lerp(0, 100))
    example_print_log("complete=" .. tostring(state:isComplete()))
    example_print_log("type=" .. state:type())
    example_print_log("typeOf=" .. tostring(state:typeOf("LTweenState")))
end

--@api: LTweenState:t
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    example_print_log("t=" .. state:t())
    example_print_log("lerp=" .. state:lerp(0, 100))
    example_print_log("complete=" .. tostring(state:isComplete()))
    example_print_log("type=" .. state:type())
    example_print_log("typeOf=" .. tostring(state:typeOf("LTweenState")))
end

--@api: LTweenState:tick
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    example_print_log("t=" .. state:t())
    example_print_log("lerp=" .. state:lerp(0, 100))
    example_print_log("complete=" .. tostring(state:isComplete()))
    example_print_log("type=" .. state:type())
    example_print_log("typeOf=" .. tostring(state:typeOf("LTweenState")))
end

--@api: LTweenState:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    example_print_log("t=" .. state:t())
    example_print_log("lerp=" .. state:lerp(0, 100))
    example_print_log("complete=" .. tostring(state:isComplete()))
    example_print_log("type=" .. state:type())
    example_print_log("typeOf=" .. tostring(state:typeOf("LTweenState")))
end

--@api: LTweenState:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    example_print_log("t=" .. state:t())
    example_print_log("lerp=" .. state:lerp(0, 100))
    example_print_log("complete=" .. tostring(state:isComplete()))
    example_print_log("type=" .. state:type())
    example_print_log("typeOf=" .. tostring(state:typeOf("LTweenState")))
end

--@api: lurek.tween.cancelAll
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local target = { v = 0.0 }
    lurek.tween.to(target, { v = 1 }, 2.0, "linear")
    example_print_log("active=" .. lurek.tween.getActiveCount())
    lurek.tween.cancelAll()
    example_print_log("active_after=" .. lurek.tween.getActiveCount())
    local names = lurek.tween.getEasingNames()
    example_print_log("easing_count=" .. #names)
end

--@api: lurek.tween.getEasingNames
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local target = { v = 0.0 }
    lurek.tween.to(target, { v = 1 }, 2.0, "linear")
    example_print_log("active=" .. lurek.tween.getActiveCount())
    lurek.tween.cancelAll()
    example_print_log("active_after=" .. lurek.tween.getActiveCount())
    local names = lurek.tween.getEasingNames()
    example_print_log("easing_count=" .. #names)
end

--@api: LSpring:isActive
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { x = 0 }
    local sp = lurek.tween.spring(obj, { x = 100 }, { stiffness = 200, damping = 20 })
    sp:update(0.016)
    local active = sp:isActive()
    local settled = sp:isSettled()
    example_print_log("spring active:", active, "settled:", settled)
end

--@api: LSpring:isSettled
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { x = 0 }
    local sp = lurek.tween.spring(obj, { x = 100 }, { stiffness = 200, damping = 20 })
    sp:update(0.016)
    local active = sp:isActive()
    local settled = sp:isSettled()
    example_print_log("spring active:", active, "settled:", settled)
end

--@api: LSpring:update
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local obj = { x = 0 }
    local sp = lurek.tween.spring(obj, { x = 100 }, { stiffness = 200, damping = 20 })
    local still_active = sp:update(0.016)
    example_print_log("spring x:", obj.x)
    example_print_log("spring still active:", still_active)
end

--@api: LSpring:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local state = {v = 0}
    local sp = lurek.tween.spring(state, {v = 50}, {stiffness = 150, damping = 15})
    local t = sp:type()
    local ok = sp:typeOf("LSpring")
    example_print_log("spring type:", t, "typeOf:", ok)
end

--@api: LSpring:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local state = {v = 0}
    local sp = lurek.tween.spring(state, {v = 50}, {stiffness = 150, damping = 15})
    local t = sp:type()
    local ok = sp:typeOf("LSpring")
    example_print_log("spring type:", t, "typeOf:", ok)
end
