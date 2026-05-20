-- content/examples/timer.lua
-- Auto-generated from content/examples2/timer_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/timer.lua

--- Timer Module: delta time, FPS, scheduler, real-time waits, physics timestep


--@api-stub: lurek.timer.getDelta
do
    local dt = lurek.timer.getDelta()
    print("delta time = " .. dt .. " seconds")
end

--@api-stub: lurek.timer.getFPS
do
    local fps = lurek.timer.getFPS()
    print("current FPS = " .. fps)
end

--@api-stub: lurek.timer.getTime
do
    local t = lurek.timer.getTime()
    print("elapsed time = " .. t .. " seconds")
end

--@api-stub: lurek.timer.getFrameCount
do
    local frames = lurek.timer.getFrameCount()
    print("total frames = " .. frames)
end

--@api-stub: lurek.timer.getMicroTime
do
    local start = lurek.timer.getMicroTime()
    local sum = 0
    for i = 1, 10000 do sum = sum + i end
    local elapsed = lurek.timer.getMicroTime() - start
    print("loop took " .. elapsed .. " seconds")
end

--@api-stub: lurek.timer.getAverageDelta
do
    local avg = lurek.timer.getAverageDelta()
    print("average delta = " .. avg)
end

--@api-stub: lurek.timer.getSmoothedDelta
do
    lurek.timer.setSmoothingFactor(0.1)
    local sd = lurek.timer.getSmoothedDelta()
    print("smoothed delta (alpha=0.1) = " .. sd)
end

--@api-stub: lurek.timer.getPhysicsDelta
do
    local pdt = lurek.timer.getPhysicsDelta()
    print("physics delta = " .. pdt)
end

--@api-stub: lurek.timer.getPhysicsMaxSteps
do
    local max = lurek.timer.getPhysicsMaxSteps()
    print("max physics steps = " .. max)
    lurek.timer.setPhysicsMaxSteps(8)
    print("set to 8: " .. lurek.timer.getPhysicsMaxSteps())
end

--@api-stub: lurek.timer.step
do
    local dt = lurek.timer.step()
    print("stepped, dt = " .. dt)
end

--@api-stub: lurek.timer.newScheduler
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    print("type = " .. sched:type())
    print("is LScheduler = " .. tostring(sched:typeOf("LScheduler")))
    print("empty = " .. tostring(sched:isEmpty()))
end

--@api-stub: LScheduler:after
do
    local sched = lurek.timer.newScheduler()
    local id = sched:after(0.5, function() end)
    print("scheduled id = " .. id)
end

--@api-stub: LScheduler:update
do
    local fired = 0
    local sched = lurek.timer.newScheduler()
    sched:after(0.5, function() fired = fired + 1 end)
    sched:update(0.5)
    print("fired = " .. fired)
end

--@api-stub: LScheduler:every
do
    local count = 0
    local sched = lurek.timer.newScheduler()
    sched:every(0.25, function() count = count + 1 end, 2)
    sched:update(0.25); sched:update(0.25)
    print("final count = " .. count)
end

--@api-stub: LScheduler:afterNamed
do
    local sched = lurek.timer.newScheduler()
    sched:afterNamed("save", 2.0, function() end)
    print("named timer scheduled")
end

--@api-stub: LScheduler:cancelNamed
do
    local sched = lurek.timer.newScheduler()
    sched:afterNamed("save", 2.0, function() end)
    local cancelled = sched:cancelNamed("save")
    print("cancelled = " .. tostring(cancelled))
end

--@api-stub: LScheduler:everyNamed
do
    local count = 0
    local sched = lurek.timer.newScheduler()
    sched:everyNamed("regen", 1.0, function() count = count + 1 end)
    sched:update(1.0); sched:update(1.0)
    print("ticks = " .. count)
end

--@api-stub: LScheduler:afterFrames
do
    local sched = lurek.timer.newScheduler()
    sched:afterFrames(3, function() end)
    sched:updateFrames(); sched:updateFrames(); local fired = sched:updateFrames()
    print("frame events = " .. fired)
end

--@api-stub: LScheduler:everyFrames
do
    local count = 0
    local sched = lurek.timer.newScheduler()
    sched:everyFrames(2, function() count = count + 1 end, 2)
    sched:updateFrames(); sched:updateFrames(); sched:updateFrames(); sched:updateFrames()
    print("frame ticks = " .. count)
end

--@api-stub: LScheduler:updateFrames
do
    local sched = lurek.timer.newScheduler()
    sched:afterFrames(1, function() end)
    print("frame events = " .. sched:updateFrames())
end

--@api-stub: LScheduler:cancel
do
    local sched = lurek.timer.newScheduler(); sched:after(1.0, function() end); sched:after(3.0, function() end)
    local id = sched:after(2.0, function() end)
    local ok = sched:cancel(id)
    print("cancel id = " .. tostring(ok))
    print("count after = " .. sched:getCount())
end

--@api-stub: LScheduler:cancelAll
do
    local sched = lurek.timer.newScheduler()
    sched:after(1.0, function() end); sched:after(2.0, function() end); sched:after(3.0, function() end)
    local removed = sched:cancelAll()
    print("cancelAll removed = " .. removed)
    print("empty = " .. tostring(sched:isEmpty()))
end

--@api-stub: LScheduler:pause
do
    local sched = lurek.timer.newScheduler()
    local id = sched:after(1.0, function() end)
    sched:pause(id)
    print("paused = " .. tostring(sched:isPaused(id)))
end

--@api-stub: LScheduler:resume
do
    local sched = lurek.timer.newScheduler()
    local id = sched:after(1.0, function() end)
    sched:pause(id)
    sched:resume(id)
    print("resumed, paused = " .. tostring(sched:isPaused(id)))
end

--@api-stub: LScheduler:isPaused
do
    local sched = lurek.timer.newScheduler()
    local id = sched:after(1.0, function() end)
    sched:pause(id)
    print("paused = " .. tostring(sched:isPaused(id)))
end

--@api-stub: LScheduler:getRemaining
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local id = sched:every(0.5, function() end, 10)
    local found, remaining = sched:getRemaining(id)
    print("found = " .. tostring(found) .. ", remaining = " .. remaining)
end

--@api-stub: LScheduler:getInterval
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local id = sched:every(0.5, function() end, 10)
    local found2, interval = sched:getInterval(id)
    print("interval = " .. interval)
end

--@api-stub: LScheduler:getRepeatCount
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local id = sched:every(0.5, function() end, 10)
    local found3, repeats = sched:getRepeatCount(id)
    print("repeat count = " .. repeats)
end

--@api-stub: LScheduler:resetEvent
do
    local sched = lurek.timer.newScheduler()
    local id = sched:every(0.5, function() end, 10)
    sched:update(0.3); sched:resetEvent(id)
    local found, remaining = sched:getRemaining(id)
    print("after reset, remaining = " .. remaining)
end

--@api-stub: LScheduler:setInterval
do
    local sched = lurek.timer.newScheduler()
    local id = sched:every(1.0, function() end)
    sched:setInterval(id, 0.5)
    print("interval changed to 0.5")
end

--@api-stub: LScheduler:setTimeScale
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    sched:setTimeScale(2.0)
    print("time scale = " .. sched:getTimeScale())
end

--@api-stub: LScheduler:getTimeScale
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    sched:setTimeScale(2.0)
    print("time scale = " .. sched:getTimeScale())
end

--@api-stub: lurek.timer.chain
do
    local count = 0
    local sched = lurek.timer.chain({ { delay = 0.5, func = function() count = count + 1 end }, { delay = 1.0, func = function() count = count + 1 end } })
    sched:update(0.5); sched:update(1.0)
    print("chain steps = " .. count)
end

--@api-stub: lurek.timer.afterReal
do
    lurek.timer.afterReal(1.0, function() end)
    local fired = lurek.timer.tickRealTimers()
    print("real timers fired = " .. fired)
end

--@api-stub: lurek.timer.sleep
do
    print("sleeping 0.01s...")
    lurek.timer.sleep(0.01)
    print("woke up")
end

--- Timer Part 1: advanced timer functions, scheduler full coverage


--@api-stub: lurek.timer.setPhysicsDelta
do
    lurek.timer.setPhysicsDelta(1/60)
    local pd = lurek.timer.getPhysicsDelta()
    print("physics_delta=" .. pd)
end

--@api-stub: lurek.timer.setPhysicsMaxSteps
do
    lurek.timer.setPhysicsMaxSteps(5)
    local pm = lurek.timer.getPhysicsMaxSteps()
    print("physics_max_steps=" .. pm)
end

--@api-stub: lurek.timer.setSmoothingFactor
do
    lurek.timer.setSmoothingFactor(0.1)
    local sd = lurek.timer.getSmoothedDelta()
    print("smoothed_delta=" .. sd)
end

--@api-stub: lurek.timer.tickRealTimers
do
    local fired = lurek.timer.tickRealTimers()
    print("real timers fired = " .. fired)
end

--@api-stub: lurek.timer.tickWaits
do
    local co = coroutine.create(function() lurek.timer.waitFrames(1); lurek.timer.waitSeconds(0) end)
    coroutine.resume(co)
    lurek.timer.tickWaits()
    lurek.timer.tickWaits()
    print("wait coroutine = " .. coroutine.status(co))
end

--@api-stub: lurek.timer.waitFrames
do
    local co = coroutine.create(function() lurek.timer.waitFrames(1) end)
    coroutine.resume(co)
    lurek.timer.tickWaits()
    lurek.timer.tickWaits()
    print("wait coroutine = " .. coroutine.status(co))
end

--@api-stub: lurek.timer.waitSeconds
do
    local co = coroutine.create(function() lurek.timer.waitSeconds(0) end)
    coroutine.resume(co)
    lurek.timer.tickWaits()
    print("wait coroutine = " .. coroutine.status(co))
end

--@api-stub: LScheduler:getCount
do
    local sched = lurek.timer.newScheduler()
    print("count=" .. sched:getCount())

    local id1 = sched:after(1.0, function() print("after") end)
    print("count_after=" .. sched:getCount())
end

--@api-stub: LScheduler:isEmpty
do
    local sched = lurek.timer.newScheduler()
    print("empty=" .. tostring(sched:isEmpty()))
    sched:cancelAll()
    print("empty_after=" .. tostring(sched:isEmpty()))
end

--@api-stub: LScheduler:isPausedNamed
do
    local sched = lurek.timer.newScheduler()
    sched:afterNamed("named_once", 2.0, function() end)
    sched:pauseNamed("named_once")
    print("paused_named=" .. tostring(sched:isPausedNamed("named_once")))
end

--@api-stub: LScheduler:pauseNamed
do
    local sched = lurek.timer.newScheduler()
    sched:afterNamed("named_once", 2.0, function() end)
    sched:pauseNamed("named_once")
    print("paused_named=" .. tostring(sched:isPausedNamed("named_once")))
end

--@api-stub: LScheduler:resumeNamed
do
    local sched = lurek.timer.newScheduler()
    sched:afterNamed("named_once", 2.0, function() end)
    sched:pauseNamed("named_once")
    sched:resumeNamed("named_once")
    print("resumeNamed ok")
end

--@api-stub: LScheduler:type
do
    local sched = lurek.timer.newScheduler()
    print("type=" .. sched:type())
end

--@api-stub: LScheduler:typeOf
do
    local sched = lurek.timer.newScheduler()
    print("typeOf=" .. tostring(sched:typeOf("LScheduler")))
end

print("content/examples/timer.lua")
