-- content/examples/timer.lua
-- Auto-generated from content/examples2/timer_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/timer.lua

--- Timer Module: delta time, FPS, scheduler, real-time waits, physics timestep


--@api-stub: lurek.timer.getDelta
-- Reading frame delta time.
do
    local dt = lurek.timer.getDelta()
    print("delta time = " .. dt .. " seconds")
end

--@api-stub: lurek.timer.getFPS
-- Current frames per second.
do
    local fps = lurek.timer.getFPS()
    print("current FPS = " .. fps)
end

--@api-stub: lurek.timer.getTime
-- Total elapsed game time.
do
    local t = lurek.timer.getTime()
    print("elapsed time = " .. t .. " seconds")
end

--@api-stub: lurek.timer.getFrameCount
-- Total rendered frames.
do
    local frames = lurek.timer.getFrameCount()
    print("total frames = " .. frames)
end

--@api-stub: lurek.timer.getMicroTime
-- High-resolution timing for benchmarks.
do
    local start = lurek.timer.getMicroTime()
    local sum = 0
    for i = 1, 10000 do sum = sum + i end
    local elapsed = lurek.timer.getMicroTime() - start
    print("loop took " .. elapsed .. " seconds")
end

--@api-stub: lurek.timer.getAverageDelta
-- Smoothed average delta for display.
do
    local avg = lurek.timer.getAverageDelta()
    print("average delta = " .. avg)
end

--@api-stub: lurek.timer.getSmoothedDelta
-- Exponentially smoothed delta.
do
    lurek.timer.setSmoothingFactor(0.1)
    local sd = lurek.timer.getSmoothedDelta()
    print("smoothed delta (alpha=0.1) = " .. sd)
end

--@api-stub: lurek.timer.getPhysicsDelta
-- Fixed physics timestep configuration.
do
    local pdt = lurek.timer.getPhysicsDelta()
    print("physics delta = " .. pdt)
end

--@api-stub: lurek.timer.getPhysicsMaxSteps
-- Physics step limit per frame.
do
    local max = lurek.timer.getPhysicsMaxSteps()
    print("max physics steps = " .. max)
    lurek.timer.setPhysicsMaxSteps(8)
    print("set to 8: " .. lurek.timer.getPhysicsMaxSteps())
end

--@api-stub: lurek.timer.step
-- Manual clock advance.
do
    local dt = lurek.timer.step()
    print("stepped, dt = " .. dt)
end

--@api-stub: lurek.timer.newScheduler
-- Creating a scheduler instance.
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    print("type = " .. sched:type())
    print("is LScheduler = " .. tostring(sched:typeOf("LScheduler")))
    print("empty = " .. tostring(sched:isEmpty()))
end

--@api-stub: LScheduler:after
-- One-shot delayed callback. Focus: after.
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local fired = false
    local id = sched:after(0.5, function()
        fired = true
        print("callback fired after 0.5s")
    end)
    print("scheduled id = " .. id)
end

--@api-stub: LScheduler:update
-- One-shot delayed callback. Focus: update.
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local fired = false
    local id = sched:after(0.5, function()
        fired = true
        print("callback fired after 0.5s")
    end)
    sched:update(0.3)
    print("after 0.3s, fired = " .. tostring(fired))
end

--@api-stub: LScheduler:every
-- Repeating interval callback.
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local count = 0
    local id = sched:every(0.25, function()
        count = count + 1
        print("tick " .. count)
    end, 4)
    print("repeating id = " .. id)
    for i = 1, 8 do
        sched:update(0.25)
    end
    print("final count = " .. count)
end

--@api-stub: LScheduler:afterNamed
-- Named one-shot for debouncing. Focus: afterNamed.
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    sched:afterNamed("save", 2.0, function()
        print("save triggered")
    end)
    print("named timer scheduled")
end

--@api-stub: LScheduler:cancelNamed
-- Named one-shot for debouncing. Focus: cancelNamed.
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    sched:afterNamed("save", 2.0, function()
        print("save triggered")
    end)
    local cancelled = sched:cancelNamed("save")
    print("cancelled = " .. tostring(cancelled))
end

--@api-stub: LScheduler:everyNamed
-- Named repeating callback.
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    sched:everyNamed("regen", 1.0, function()
        print("health regen tick")
    end)
    sched:update(1.0)
    sched:update(1.0)
    sched:pauseNamed("regen")
    print("paused = " .. tostring(sched:isPausedNamed("regen")))
    sched:resumeNamed("regen")
    print("resumed")
end

--@api-stub: LScheduler:afterFrames
-- Frame-based scheduling. Focus: afterFrames.
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    sched:afterFrames(3, function()
        print("fired after 3 frames")
    end)
    sched:everyFrames(2, function()
        print("every 2 frames")
    end, 3)
    for i = 1, 6 do
        local n = sched:updateFrames()
        if n > 0 then
            print("  frame " .. i .. ": " .. n .. " fired")
        end
    end
end

--@api-stub: LScheduler:everyFrames
-- Frame-based scheduling. Focus: everyFrames.
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    sched:afterFrames(3, function()
        print("fired after 3 frames")
    end)
    sched:everyFrames(2, function()
        print("every 2 frames")
    end, 3)
    for i = 1, 6 do
        local n = sched:updateFrames()
        if n > 0 then
            print("  frame " .. i .. ": " .. n .. " fired")
        end
    end
end

--@api-stub: LScheduler:updateFrames
-- Frame-based scheduling. Focus: updateFrames.
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    sched:afterFrames(3, function()
        print("fired after 3 frames")
    end)
    sched:everyFrames(2, function()
        print("every 2 frames")
    end, 3)
    for i = 1, 6 do
        local n = sched:updateFrames()
        if n > 0 then
            print("  frame " .. i .. ": " .. n .. " fired")
        end
    end
end

--@api-stub: LScheduler:cancel
-- Cancelling scheduled events. Focus: cancel.
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local id1 = sched:after(1.0, function() end)
    local id2 = sched:after(2.0, function() end)
    local id3 = sched:after(3.0, function() end)
    print("count = " .. sched:getCount())
    local ok = sched:cancel(id2)
    print("cancel id2 = " .. tostring(ok))
    print("count after = " .. sched:getCount())
    local removed = sched:cancelAll()
    print("cancelAll removed = " .. removed)
    print("empty = " .. tostring(sched:isEmpty()))
end

--@api-stub: LScheduler:cancelAll
-- Cancelling scheduled events. Focus: cancelAll.
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local id1 = sched:after(1.0, function() end)
    local id2 = sched:after(2.0, function() end)
    local id3 = sched:after(3.0, function() end)
    print("count = " .. sched:getCount())
    local ok = sched:cancel(id2)
    print("cancel id2 = " .. tostring(ok))
    print("count after = " .. sched:getCount())
    local removed = sched:cancelAll()
    print("cancelAll removed = " .. removed)
    print("empty = " .. tostring(sched:isEmpty()))
end

--@api-stub: LScheduler:pause
-- Pausing and resuming events. Focus: pause.
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local id = sched:after(1.0, function()
        print("should not fire while paused")
    end)
    sched:pause(id)
    print("paused = " .. tostring(sched:isPaused(id)))
    sched:update(2.0)
    sched:resume(id)
    print("resumed, paused = " .. tostring(sched:isPaused(id)))
    sched:update(1.0)
end

--@api-stub: LScheduler:resume
-- Pausing and resuming events. Focus: resume.
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local id = sched:after(1.0, function()
        print("should not fire while paused")
    end)
    sched:pause(id)
    print("paused = " .. tostring(sched:isPaused(id)))
    sched:update(2.0)
    sched:resume(id)
    print("resumed, paused = " .. tostring(sched:isPaused(id)))
    sched:update(1.0)
end

--@api-stub: LScheduler:isPaused
-- Pausing and resuming events. Focus: isPaused.
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local id = sched:after(1.0, function()
        print("should not fire while paused")
    end)
    sched:pause(id)
    print("paused = " .. tostring(sched:isPaused(id)))
    sched:update(2.0)
    sched:resume(id)
    print("resumed, paused = " .. tostring(sched:isPaused(id)))
    sched:update(1.0)
end

--@api-stub: LScheduler:getRemaining
-- Querying event state. Focus: getRemaining.
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local id = sched:every(0.5, function() end, 10)
    local found, remaining = sched:getRemaining(id)
    print("found = " .. tostring(found) .. ", remaining = " .. remaining)
    local found2, interval = sched:getInterval(id)
    print("interval = " .. interval)
    local found3, repeats = sched:getRepeatCount(id)
    print("repeat count = " .. repeats)
    sched:update(0.3)
    sched:resetEvent(id)
    found, remaining = sched:getRemaining(id)
    print("after reset, remaining = " .. remaining)
end

--@api-stub: LScheduler:getInterval
-- Querying event state. Focus: getInterval.
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local id = sched:every(0.5, function() end, 10)
    local found, remaining = sched:getRemaining(id)
    print("found = " .. tostring(found) .. ", remaining = " .. remaining)
    local found2, interval = sched:getInterval(id)
    print("interval = " .. interval)
    local found3, repeats = sched:getRepeatCount(id)
    print("repeat count = " .. repeats)
    sched:update(0.3)
    sched:resetEvent(id)
    found, remaining = sched:getRemaining(id)
    print("after reset, remaining = " .. remaining)
end

--@api-stub: LScheduler:getRepeatCount
-- Querying event state. Focus: getRepeatCount.
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local id = sched:every(0.5, function() end, 10)
    local found, remaining = sched:getRemaining(id)
    print("found = " .. tostring(found) .. ", remaining = " .. remaining)
    local found2, interval = sched:getInterval(id)
    print("interval = " .. interval)
    local found3, repeats = sched:getRepeatCount(id)
    print("repeat count = " .. repeats)
    sched:update(0.3)
    sched:resetEvent(id)
    found, remaining = sched:getRemaining(id)
    print("after reset, remaining = " .. remaining)
end

--@api-stub: LScheduler:resetEvent
-- Querying event state. Focus: resetEvent.
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local id = sched:every(0.5, function() end, 10)
    local found, remaining = sched:getRemaining(id)
    print("found = " .. tostring(found) .. ", remaining = " .. remaining)
    local found2, interval = sched:getInterval(id)
    print("interval = " .. interval)
    local found3, repeats = sched:getRepeatCount(id)
    print("repeat count = " .. repeats)
    sched:update(0.3)
    sched:resetEvent(id)
    found, remaining = sched:getRemaining(id)
    print("after reset, remaining = " .. remaining)
end

--@api-stub: LScheduler:setInterval
-- Dynamic interval and time scaling. Focus: setInterval.
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local id = sched:every(1.0, function()
        print("tick")
    end)
    sched:setInterval(id, 0.5)
    print("interval changed to 0.5")
    sched:setTimeScale(2.0)
    print("time scale = " .. sched:getTimeScale())
    -- At 2x speed, 0.25s real = 0.5s game
    sched:update(0.25)
end

--@api-stub: LScheduler:setTimeScale
-- Dynamic interval and time scaling. Focus: setTimeScale.
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local id = sched:every(1.0, function()
        print("tick")
    end)
    sched:setInterval(id, 0.5)
    print("interval changed to 0.5")
    sched:setTimeScale(2.0)
    print("time scale = " .. sched:getTimeScale())
    -- At 2x speed, 0.25s real = 0.5s game
    sched:update(0.25)
end

--@api-stub: LScheduler:getTimeScale
-- Dynamic interval and time scaling. Focus: getTimeScale.
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local id = sched:every(1.0, function()
        print("tick")
    end)
    sched:setInterval(id, 0.5)
    print("interval changed to 0.5")
    sched:setTimeScale(2.0)
    print("time scale = " .. sched:getTimeScale())
    -- At 2x speed, 0.25s real = 0.5s game
    sched:update(0.25)
end

--@api-stub: lurek.timer.chain
-- Chaining delayed callbacks into a sequence.
do
    ---@type LScheduler
    local sched = lurek.timer.chain({
        { delay = 0.5, func = function() print("step 1 at 0.5s") end },
        { delay = 1.0, func = function() print("step 2 at 1.5s") end },
        { delay = 0.5, func = function() print("step 3 at 2.0s") end },
    })
    sched:update(0.5)
    sched:update(1.0)
    sched:update(0.5)
end

--@api-stub: lurek.timer.afterReal
-- Real-time (unscaled) timer.
do
    lurek.timer.afterReal(1.0, function()
        print("1 second of real time passed")
    end)
    local fired = lurek.timer.tickRealTimers()
    print("real timers fired = " .. fired)
end

--@api-stub: lurek.timer.sleep
-- Blocking sleep (use sparingly).
do
    print("sleeping 0.01s...")
    lurek.timer.sleep(0.01)
    print("woke up")
end

--- Timer Part 1: advanced timer functions, scheduler full coverage


--@api-stub: lurek.timer.setPhysicsDelta
-- Advanced timer functions: physics delta, smoothing, wait helpers, tick hooks. Focus: setPhysicsDelta.
do
    lurek.timer.setPhysicsDelta(1/60)
    local pd = lurek.timer.getPhysicsDelta()
    print("physics_delta=" .. pd)

    lurek.timer.setPhysicsMaxSteps(5)
    local pm = lurek.timer.getPhysicsMaxSteps()
    print("physics_max_steps=" .. pm)

    lurek.timer.setSmoothingFactor(0.1)
    local sd = lurek.timer.getSmoothedDelta()
    print("smoothed_delta=" .. sd)

    lurek.timer.tickRealTimers()
    lurek.timer.tickWaits()

    local co = coroutine.create(function()
        lurek.timer.waitFrames(1)
        lurek.timer.waitSeconds(0)
    end)
    coroutine.resume(co)
    lurek.timer.tickWaits()
    lurek.timer.tickWaits()
    print("wait coroutine = " .. coroutine.status(co))
end

--@api-stub: lurek.timer.setPhysicsMaxSteps
-- Advanced timer functions: physics delta, smoothing, wait helpers, tick hooks. Focus: setPhysicsMaxSteps.
do
    lurek.timer.setPhysicsDelta(1/60)
    local pd = lurek.timer.getPhysicsDelta()
    print("physics_delta=" .. pd)

    lurek.timer.setPhysicsMaxSteps(5)
    local pm = lurek.timer.getPhysicsMaxSteps()
    print("physics_max_steps=" .. pm)

    lurek.timer.setSmoothingFactor(0.1)
    local sd = lurek.timer.getSmoothedDelta()
    print("smoothed_delta=" .. sd)

    lurek.timer.tickRealTimers()
    lurek.timer.tickWaits()

    local co = coroutine.create(function()
        lurek.timer.waitFrames(1)
        lurek.timer.waitSeconds(0)
    end)
    coroutine.resume(co)
    lurek.timer.tickWaits()
    lurek.timer.tickWaits()
    print("wait coroutine = " .. coroutine.status(co))
end

--@api-stub: lurek.timer.setSmoothingFactor
-- Advanced timer functions: physics delta, smoothing, wait helpers, tick hooks. Focus: setSmoothingFactor.
do
    lurek.timer.setPhysicsDelta(1/60)
    local pd = lurek.timer.getPhysicsDelta()
    print("physics_delta=" .. pd)

    lurek.timer.setPhysicsMaxSteps(5)
    local pm = lurek.timer.getPhysicsMaxSteps()
    print("physics_max_steps=" .. pm)

    lurek.timer.setSmoothingFactor(0.1)
    local sd = lurek.timer.getSmoothedDelta()
    print("smoothed_delta=" .. sd)

    lurek.timer.tickRealTimers()
    lurek.timer.tickWaits()

    local co = coroutine.create(function()
        lurek.timer.waitFrames(1)
        lurek.timer.waitSeconds(0)
    end)
    coroutine.resume(co)
    lurek.timer.tickWaits()
    lurek.timer.tickWaits()
    print("wait coroutine = " .. coroutine.status(co))
end

--@api-stub: lurek.timer.tickRealTimers
-- Advanced timer functions: physics delta, smoothing, wait helpers, tick hooks. Focus: tickRealTimers.
do
    lurek.timer.setPhysicsDelta(1/60)
    local pd = lurek.timer.getPhysicsDelta()
    print("physics_delta=" .. pd)

    lurek.timer.setPhysicsMaxSteps(5)
    local pm = lurek.timer.getPhysicsMaxSteps()
    print("physics_max_steps=" .. pm)

    lurek.timer.setSmoothingFactor(0.1)
    local sd = lurek.timer.getSmoothedDelta()
    print("smoothed_delta=" .. sd)

    lurek.timer.tickRealTimers()
    lurek.timer.tickWaits()

    local co = coroutine.create(function()
        lurek.timer.waitFrames(1)
        lurek.timer.waitSeconds(0)
    end)
    coroutine.resume(co)
    lurek.timer.tickWaits()
    lurek.timer.tickWaits()
    print("wait coroutine = " .. coroutine.status(co))
end

--@api-stub: lurek.timer.tickWaits
-- Advanced timer functions: physics delta, smoothing, wait helpers, tick hooks. Focus: tickWaits.
do
    lurek.timer.setPhysicsDelta(1/60)
    local pd = lurek.timer.getPhysicsDelta()
    print("physics_delta=" .. pd)

    lurek.timer.setPhysicsMaxSteps(5)
    local pm = lurek.timer.getPhysicsMaxSteps()
    print("physics_max_steps=" .. pm)

    lurek.timer.setSmoothingFactor(0.1)
    local sd = lurek.timer.getSmoothedDelta()
    print("smoothed_delta=" .. sd)

    lurek.timer.tickRealTimers()
    lurek.timer.tickWaits()

    local co = coroutine.create(function()
        lurek.timer.waitFrames(1)
        lurek.timer.waitSeconds(0)
    end)
    coroutine.resume(co)
    lurek.timer.tickWaits()
    lurek.timer.tickWaits()
    print("wait coroutine = " .. coroutine.status(co))
end

--@api-stub: lurek.timer.waitFrames
-- Advanced timer functions: physics delta, smoothing, wait helpers, tick hooks. Focus: waitFrames.
do
    lurek.timer.setPhysicsDelta(1/60)
    local pd = lurek.timer.getPhysicsDelta()
    print("physics_delta=" .. pd)

    lurek.timer.setPhysicsMaxSteps(5)
    local pm = lurek.timer.getPhysicsMaxSteps()
    print("physics_max_steps=" .. pm)

    lurek.timer.setSmoothingFactor(0.1)
    local sd = lurek.timer.getSmoothedDelta()
    print("smoothed_delta=" .. sd)

    lurek.timer.tickRealTimers()
    lurek.timer.tickWaits()

    local co = coroutine.create(function()
        lurek.timer.waitFrames(1)
        lurek.timer.waitSeconds(0)
    end)
    coroutine.resume(co)
    lurek.timer.tickWaits()
    lurek.timer.tickWaits()
    print("wait coroutine = " .. coroutine.status(co))
end

--@api-stub: lurek.timer.waitSeconds
-- Advanced timer functions: physics delta, smoothing, wait helpers, tick hooks. Focus: waitSeconds.
do
    lurek.timer.setPhysicsDelta(1/60)
    local pd = lurek.timer.getPhysicsDelta()
    print("physics_delta=" .. pd)

    lurek.timer.setPhysicsMaxSteps(5)
    local pm = lurek.timer.getPhysicsMaxSteps()
    print("physics_max_steps=" .. pm)

    lurek.timer.setSmoothingFactor(0.1)
    local sd = lurek.timer.getSmoothedDelta()
    print("smoothed_delta=" .. sd)

    lurek.timer.tickRealTimers()
    lurek.timer.tickWaits()

    local co = coroutine.create(function()
        lurek.timer.waitFrames(1)
        lurek.timer.waitSeconds(0)
    end)
    coroutine.resume(co)
    lurek.timer.tickWaits()
    lurek.timer.tickWaits()
    print("wait coroutine = " .. coroutine.status(co))
end

--@api-stub: LScheduler:getCount
-- LScheduler: schedule delayed/repeating callbacks by time or frame, pause/resume, type. Focus: getCount.
do
    local sched = lurek.timer.newScheduler()
    print("type=" .. sched:type())
    print("typeOf=" .. tostring(sched:typeOf("LScheduler")))
    print("empty=" .. tostring(sched:isEmpty()))
    print("count=" .. sched:getCount())

    local id1 = sched:after(1.0, function() print("after") end)
    local id2 = sched:afterFrames(30, function() print("frames") end)
    local id3 = sched:every(0.5, function() print("every") end, 3)
    local id4 = sched:everyFrames(10, function() print("everyFrames") end, 2)
    sched:afterNamed("named_once", 2.0, function() print("named_once") end)
    sched:everyNamed("named_repeat", 1.0, function() print("named_repeat") end, 5)

    print("count_after=" .. sched:getCount())
    print("interval_id1=" .. tostring(sched:getInterval(id1)))
    print("remaining_id1=" .. tostring(sched:getRemaining(id1)))
    print("repeat_id3=" .. tostring(sched:getRepeatCount(id3)))

    sched:pause(id1)
    print("paused_id1=" .. tostring(sched:isPaused(id1)))
    sched:pauseNamed("named_once")
    print("paused_named=" .. tostring(sched:isPausedNamed("named_once")))
    sched:resume(id1)
    sched:resumeNamed("named_once")
    sched:resetEvent(id3)

    sched:setTimeScale(2.0)
    print("time_scale=" .. sched:getTimeScale())

    sched:update(0.016)

    sched:cancel(id2)
    sched:cancelNamed("named_repeat")
    sched:cancelAll()
    print("empty_after=" .. tostring(sched:isEmpty()))
end

--@api-stub: LScheduler:isEmpty
-- LScheduler: schedule delayed/repeating callbacks by time or frame, pause/resume, type. Focus: isEmpty.
do
    local sched = lurek.timer.newScheduler()
    print("type=" .. sched:type())
    print("typeOf=" .. tostring(sched:typeOf("LScheduler")))
    print("empty=" .. tostring(sched:isEmpty()))
    print("count=" .. sched:getCount())

    local id1 = sched:after(1.0, function() print("after") end)
    local id2 = sched:afterFrames(30, function() print("frames") end)
    local id3 = sched:every(0.5, function() print("every") end, 3)
    local id4 = sched:everyFrames(10, function() print("everyFrames") end, 2)
    sched:afterNamed("named_once", 2.0, function() print("named_once") end)
    sched:everyNamed("named_repeat", 1.0, function() print("named_repeat") end, 5)

    print("count_after=" .. sched:getCount())
    print("interval_id1=" .. tostring(sched:getInterval(id1)))
    print("remaining_id1=" .. tostring(sched:getRemaining(id1)))
    print("repeat_id3=" .. tostring(sched:getRepeatCount(id3)))

    sched:pause(id1)
    print("paused_id1=" .. tostring(sched:isPaused(id1)))
    sched:pauseNamed("named_once")
    print("paused_named=" .. tostring(sched:isPausedNamed("named_once")))
    sched:resume(id1)
    sched:resumeNamed("named_once")
    sched:resetEvent(id3)

    sched:setTimeScale(2.0)
    print("time_scale=" .. sched:getTimeScale())

    sched:update(0.016)

    sched:cancel(id2)
    sched:cancelNamed("named_repeat")
    sched:cancelAll()
    print("empty_after=" .. tostring(sched:isEmpty()))
end

--@api-stub: LScheduler:isPausedNamed
-- LScheduler: schedule delayed/repeating callbacks by time or frame, pause/resume, type. Focus: isPausedNamed.
do
    local sched = lurek.timer.newScheduler()
    print("type=" .. sched:type())
    print("typeOf=" .. tostring(sched:typeOf("LScheduler")))
    print("empty=" .. tostring(sched:isEmpty()))
    print("count=" .. sched:getCount())

    local id1 = sched:after(1.0, function() print("after") end)
    local id2 = sched:afterFrames(30, function() print("frames") end)
    local id3 = sched:every(0.5, function() print("every") end, 3)
    local id4 = sched:everyFrames(10, function() print("everyFrames") end, 2)
    sched:afterNamed("named_once", 2.0, function() print("named_once") end)
    sched:everyNamed("named_repeat", 1.0, function() print("named_repeat") end, 5)

    print("count_after=" .. sched:getCount())
    print("interval_id1=" .. tostring(sched:getInterval(id1)))
    print("remaining_id1=" .. tostring(sched:getRemaining(id1)))
    print("repeat_id3=" .. tostring(sched:getRepeatCount(id3)))

    sched:pause(id1)
    print("paused_id1=" .. tostring(sched:isPaused(id1)))
    sched:pauseNamed("named_once")
    print("paused_named=" .. tostring(sched:isPausedNamed("named_once")))
    sched:resume(id1)
    sched:resumeNamed("named_once")
    sched:resetEvent(id3)

    sched:setTimeScale(2.0)
    print("time_scale=" .. sched:getTimeScale())

    sched:update(0.016)

    sched:cancel(id2)
    sched:cancelNamed("named_repeat")
    sched:cancelAll()
    print("empty_after=" .. tostring(sched:isEmpty()))
end

--@api-stub: LScheduler:pauseNamed
-- LScheduler: schedule delayed/repeating callbacks by time or frame, pause/resume, type. Focus: pauseNamed.
do
    local sched = lurek.timer.newScheduler()
    print("type=" .. sched:type())
    print("typeOf=" .. tostring(sched:typeOf("LScheduler")))
    print("empty=" .. tostring(sched:isEmpty()))
    print("count=" .. sched:getCount())

    local id1 = sched:after(1.0, function() print("after") end)
    local id2 = sched:afterFrames(30, function() print("frames") end)
    local id3 = sched:every(0.5, function() print("every") end, 3)
    local id4 = sched:everyFrames(10, function() print("everyFrames") end, 2)
    sched:afterNamed("named_once", 2.0, function() print("named_once") end)
    sched:everyNamed("named_repeat", 1.0, function() print("named_repeat") end, 5)

    print("count_after=" .. sched:getCount())
    print("interval_id1=" .. tostring(sched:getInterval(id1)))
    print("remaining_id1=" .. tostring(sched:getRemaining(id1)))
    print("repeat_id3=" .. tostring(sched:getRepeatCount(id3)))

    sched:pause(id1)
    print("paused_id1=" .. tostring(sched:isPaused(id1)))
    sched:pauseNamed("named_once")
    print("paused_named=" .. tostring(sched:isPausedNamed("named_once")))
    sched:resume(id1)
    sched:resumeNamed("named_once")
    sched:resetEvent(id3)

    sched:setTimeScale(2.0)
    print("time_scale=" .. sched:getTimeScale())

    sched:update(0.016)

    sched:cancel(id2)
    sched:cancelNamed("named_repeat")
    sched:cancelAll()
    print("empty_after=" .. tostring(sched:isEmpty()))
end

--@api-stub: LScheduler:resumeNamed
-- LScheduler: schedule delayed/repeating callbacks by time or frame, pause/resume, type. Focus: resumeNamed.
do
    local sched = lurek.timer.newScheduler()
    print("type=" .. sched:type())
    print("typeOf=" .. tostring(sched:typeOf("LScheduler")))
    print("empty=" .. tostring(sched:isEmpty()))
    print("count=" .. sched:getCount())

    local id1 = sched:after(1.0, function() print("after") end)
    local id2 = sched:afterFrames(30, function() print("frames") end)
    local id3 = sched:every(0.5, function() print("every") end, 3)
    local id4 = sched:everyFrames(10, function() print("everyFrames") end, 2)
    sched:afterNamed("named_once", 2.0, function() print("named_once") end)
    sched:everyNamed("named_repeat", 1.0, function() print("named_repeat") end, 5)

    print("count_after=" .. sched:getCount())
    print("interval_id1=" .. tostring(sched:getInterval(id1)))
    print("remaining_id1=" .. tostring(sched:getRemaining(id1)))
    print("repeat_id3=" .. tostring(sched:getRepeatCount(id3)))

    sched:pause(id1)
    print("paused_id1=" .. tostring(sched:isPaused(id1)))
    sched:pauseNamed("named_once")
    print("paused_named=" .. tostring(sched:isPausedNamed("named_once")))
    sched:resume(id1)
    sched:resumeNamed("named_once")
    sched:resetEvent(id3)

    sched:setTimeScale(2.0)
    print("time_scale=" .. sched:getTimeScale())

    sched:update(0.016)

    sched:cancel(id2)
    sched:cancelNamed("named_repeat")
    sched:cancelAll()
    print("empty_after=" .. tostring(sched:isEmpty()))
end

--@api-stub: LScheduler:type
-- LScheduler: schedule delayed/repeating callbacks by time or frame, pause/resume, type. Focus: type.
do
    local sched = lurek.timer.newScheduler()
    print("type=" .. sched:type())
    print("typeOf=" .. tostring(sched:typeOf("LScheduler")))
    print("empty=" .. tostring(sched:isEmpty()))
    print("count=" .. sched:getCount())

    local id1 = sched:after(1.0, function() print("after") end)
    local id2 = sched:afterFrames(30, function() print("frames") end)
    local id3 = sched:every(0.5, function() print("every") end, 3)
    local id4 = sched:everyFrames(10, function() print("everyFrames") end, 2)
    sched:afterNamed("named_once", 2.0, function() print("named_once") end)
    sched:everyNamed("named_repeat", 1.0, function() print("named_repeat") end, 5)

    print("count_after=" .. sched:getCount())
    print("interval_id1=" .. tostring(sched:getInterval(id1)))
    print("remaining_id1=" .. tostring(sched:getRemaining(id1)))
    print("repeat_id3=" .. tostring(sched:getRepeatCount(id3)))

    sched:pause(id1)
    print("paused_id1=" .. tostring(sched:isPaused(id1)))
    sched:pauseNamed("named_once")
    print("paused_named=" .. tostring(sched:isPausedNamed("named_once")))
    sched:resume(id1)
    sched:resumeNamed("named_once")
    sched:resetEvent(id3)

    sched:setTimeScale(2.0)
    print("time_scale=" .. sched:getTimeScale())

    sched:update(0.016)

    sched:cancel(id2)
    sched:cancelNamed("named_repeat")
    sched:cancelAll()
    print("empty_after=" .. tostring(sched:isEmpty()))
end

--@api-stub: LScheduler:typeOf
-- LScheduler: schedule delayed/repeating callbacks by time or frame, pause/resume, type. Focus: typeOf.
do
    local sched = lurek.timer.newScheduler()
    print("type=" .. sched:type())
    print("typeOf=" .. tostring(sched:typeOf("LScheduler")))
    print("empty=" .. tostring(sched:isEmpty()))
    print("count=" .. sched:getCount())

    local id1 = sched:after(1.0, function() print("after") end)
    local id2 = sched:afterFrames(30, function() print("frames") end)
    local id3 = sched:every(0.5, function() print("every") end, 3)
    local id4 = sched:everyFrames(10, function() print("everyFrames") end, 2)
    sched:afterNamed("named_once", 2.0, function() print("named_once") end)
    sched:everyNamed("named_repeat", 1.0, function() print("named_repeat") end, 5)

    print("count_after=" .. sched:getCount())
    print("interval_id1=" .. tostring(sched:getInterval(id1)))
    print("remaining_id1=" .. tostring(sched:getRemaining(id1)))
    print("repeat_id3=" .. tostring(sched:getRepeatCount(id3)))

    sched:pause(id1)
    print("paused_id1=" .. tostring(sched:isPaused(id1)))
    sched:pauseNamed("named_once")
    print("paused_named=" .. tostring(sched:isPausedNamed("named_once")))
    sched:resume(id1)
    sched:resumeNamed("named_once")
    sched:resetEvent(id3)

    sched:setTimeScale(2.0)
    print("time_scale=" .. sched:getTimeScale())

    sched:update(0.016)

    sched:cancel(id2)
    sched:cancelNamed("named_repeat")
    sched:cancelAll()
    print("empty_after=" .. tostring(sched:isEmpty()))
end

print("content/examples/timer.lua")
