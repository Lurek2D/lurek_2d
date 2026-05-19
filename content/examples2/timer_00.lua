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
    print("estimated avg FPS = " .. math.floor(1 / avg))
end

--@api-stub: lurek.timer.getSmoothedDelta
--@api-stub: lurek.setSmoothingFactor
-- Exponentially smoothed delta.
do
    lurek.timer.setSmoothingFactor(0.1)
    local sd = lurek.timer.getSmoothedDelta()
    print("smoothed delta (alpha=0.1) = " .. sd)
    lurek.timer.setSmoothingFactor(0.5)
    sd = lurek.timer.getSmoothedDelta()
    print("smoothed delta (alpha=0.5) = " .. sd)
end

--@api-stub: lurek.timer.getPhysicsDelta
--@api-stub: lurek.setPhysicsDelta
-- Fixed physics timestep configuration.
do
    local pdt = lurek.timer.getPhysicsDelta()
    print("physics delta = " .. pdt)
    lurek.timer.setPhysicsDelta(1 / 120)
    print("set to 120Hz: " .. lurek.timer.getPhysicsDelta())
    lurek.timer.setPhysicsDelta(1 / 60)
end

--@api-stub: lurek.timer.getPhysicsMaxSteps
--@api-stub: lurek.setPhysicsMaxSteps
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
--@api-stub: LScheduler:update
-- One-shot delayed callback.
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local fired = false
    local id = sched:after(0.5, function()
        fired = true
        print("callback fired after 0.5s")
    end)
    print("scheduled id = " .. id)
    print("count = " .. sched:getCount())
    -- simulate time passing
    sched:update(0.3)
    print("after 0.3s, fired = " .. tostring(fired))
    sched:update(0.3)
    print("after 0.6s, fired = " .. tostring(fired))
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
--@api-stub: LScheduler:cancelNamed
-- Named one-shot for debouncing.
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    sched:afterNamed("save", 2.0, function()
        print("save triggered")
    end)
    sched:update(1.0)
    -- Reset the timer by scheduling again with same name
    sched:afterNamed("save", 2.0, function()
        print("save triggered (reset)")
    end)
    sched:update(1.5)
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
--@api-stub: LScheduler:everyFrames
--@api-stub: LScheduler:updateFrames
-- Frame-based scheduling.
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
--@api-stub: LScheduler:cancelAll
-- Cancelling scheduled events.
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
--@api-stub: LScheduler:resume
--@api-stub: LScheduler:isPaused
-- Pausing and resuming events.
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
--@api-stub: LScheduler:getInterval
--@api-stub: LScheduler:getRepeatCount
--@api-stub: LScheduler:resetEvent
-- Querying event state.
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
--@api-stub: LScheduler:setTimeScale
--@api-stub: LScheduler:getTimeScale
-- Dynamic interval and time scaling.
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
--@api-stub: lurek.tickRealTimers
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

print("timer_00.lua")
