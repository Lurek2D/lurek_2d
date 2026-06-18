-- content/examples/timer.lua
-- Auto-generated from content/examples2/timer_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/timer.lua

--- Timer Module: delta time, FPS, scheduler, real-time waits, physics timestep

--@api: lurek.timer.getDelta
do
    local dt = lurek.timer.getDelta()
    local fps = lurek.timer.getFPS()
    local avg = lurek.timer.getAverageDelta()
    local smoothed = lurek.timer.getSmoothedDelta()
    lurek.log.info("frame delta = " .. dt .. " seconds")
    lurek.log.info("fps=" .. fps .. " avg=" .. avg .. " smoothed=" .. smoothed)
end

--@api: lurek.timer.getFPS
do
    local fps = lurek.timer.getFPS()
    local dt = lurek.timer.getDelta()
    local avg = lurek.timer.getAverageDelta()
    local frames = lurek.timer.getFrameCount()
    lurek.log.info("current FPS = " .. fps)
    lurek.log.info("dt=" .. dt .. " avg=" .. avg .. " frames=" .. frames)
end

--@api: lurek.timer.getTime
do
    local t = lurek.timer.getTime()
    local frames = lurek.timer.getFrameCount()
    local fps = lurek.timer.getFPS()
    local uptime_per_frame = frames > 0 and (t / frames) or 0
    lurek.log.info("elapsed time = " .. t .. " seconds")
    lurek.log.info("frames=" .. frames .. " fps=" .. fps .. " sec/frame=" .. uptime_per_frame)
end

--@api: lurek.timer.getFrameCount
do
    local frames = lurek.timer.getFrameCount()
    local time = lurek.timer.getTime()
    local fps = lurek.timer.getFPS()
    local warm = frames > 60
    lurek.log.info("total frames = " .. frames)
    lurek.log.info("time=" .. time .. " fps=" .. fps .. " warmed=" .. tostring(warm))
end

--@api: lurek.timer.getMicroTime
do
    local start = lurek.timer.getMicroTime()
    local sum = 0
    for i = 1, 10000 do sum = sum + i end
    local elapsed = lurek.timer.getMicroTime() - start
    lurek.log.info("loop took " .. elapsed .. " seconds")
end

--@api: lurek.timer.getAverageDelta
do
    local avg = lurek.timer.getAverageDelta()
    local dt = lurek.timer.getDelta()
    local smoothed = lurek.timer.getSmoothedDelta()
    local fps = lurek.timer.getFPS()
    lurek.log.info("average delta = " .. avg)
    lurek.log.info("current=" .. dt .. " smoothed=" .. smoothed .. " fps=" .. fps)
end

--@api: lurek.timer.getSmoothedDelta
do
    lurek.timer.setSmoothingFactor(0.1)
    local sd = lurek.timer.getSmoothedDelta()
    local raw = lurek.timer.getDelta()
    local avg = lurek.timer.getAverageDelta()
    lurek.log.info("smoothed delta (alpha=0.1) = " .. sd)
    lurek.log.info("raw=" .. raw .. " avg=" .. avg)
end

--@api: lurek.timer.getPhysicsDelta
do
    local pdt = lurek.timer.getPhysicsDelta()
    local max_steps = lurek.timer.getPhysicsMaxSteps()
    local per_second = 1 / pdt
    local dt = lurek.timer.getDelta()
    lurek.log.info("physics delta = " .. pdt)
    lurek.log.info("steps/sec=" .. per_second .. " maxSteps=" .. max_steps .. " frameDt=" .. dt)
end

--@api: lurek.timer.getPhysicsMaxSteps
do
    local max = lurek.timer.getPhysicsMaxSteps()
    lurek.timer.setPhysicsMaxSteps(8)
    local updated = lurek.timer.getPhysicsMaxSteps()
    local pdt = lurek.timer.getPhysicsDelta()
    lurek.log.info("max physics steps = " .. max)
    lurek.log.info("set to " .. updated .. " with physics dt=" .. pdt)
end

--@api: lurek.timer.step
do
    local dt = lurek.timer.step()
    local after = lurek.timer.getDelta()
    local fps = lurek.timer.getFPS()
    local frames = lurek.timer.getFrameCount()
    lurek.log.info("step produced dt = " .. dt)
    lurek.log.info("stored dt=" .. after .. " fps=" .. fps .. " frames=" .. frames)
end

--@api: lurek.timer.newScheduler
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local type_name = sched:type()
    local is_sched = sched:typeOf("LScheduler")
    local empty = sched:isEmpty()
    local count = sched:getCount()
    lurek.log.info("scheduler type = " .. type_name)
    lurek.log.info("isScheduler=" .. tostring(is_sched) .. " empty=" .. tostring(empty) .. " count=" .. count)
end

--@api: LScheduler:after
do
    local sched = lurek.timer.newScheduler()
    local fired = 0
    local id = sched:after(0.5, function() fired = fired + 1 end)
    local before = sched:getCount()
    local callbacks = sched:update(0.5)
    lurek.log.info("scheduled one-shot id = " .. id .. " countBefore=" .. before)
    lurek.log.info("callbacks=" .. callbacks .. " fired=" .. fired)
end

--@api: LScheduler:update
do
    local fired = 0
    local sched = lurek.timer.newScheduler()
    sched:after(0.5, function() fired = fired + 1 end)
    sched:update(0.5)
    lurek.log.info("fired = " .. fired)
end

--@api: LScheduler:every
do
    local count = 0
    local sched = lurek.timer.newScheduler()
    sched:every(0.25, function() count = count + 1 end, 2)
    sched:update(0.25)
    sched:update(0.25)
    lurek.log.info("final count = " .. count)
end

--@api: LScheduler:afterNamed
do
    local sched = lurek.timer.newScheduler()
    local fired = 0
    sched:afterNamed("save", 2.0, function() fired = fired + 1 end)
    local count = sched:getCount()
    local paused = sched:isPausedNamed("save")
    lurek.log.info("named timer scheduled for save")
    lurek.log.info("count=" .. count .. " paused=" .. tostring(paused) .. " fired=" .. fired)
end

--@api: LScheduler:cancelNamed
do
    local sched = lurek.timer.newScheduler()
    sched:afterNamed("save", 2.0, function() end)
    local cancelled = sched:cancelNamed("save")
    local empty = sched:isEmpty()
    local count = sched:getCount()
    lurek.log.info("cancelled named timer = " .. tostring(cancelled))
    lurek.log.info("empty=" .. tostring(empty) .. " count=" .. count)
end

--@api: LScheduler:everyNamed
do
    local count = 0
    local sched = lurek.timer.newScheduler()
    sched:everyNamed("regen", 1.0, function() count = count + 1 end)
    sched:update(1.0)
    sched:update(1.0)
    lurek.log.info("ticks = " .. count)
end

--@api: LScheduler:afterFrames
do
    local fired_count = 0
    local sched = lurek.timer.newScheduler()
    sched:afterFrames(3, function() fired_count = fired_count + 1 end)
    sched:updateFrames()
    sched:updateFrames()
    local fired = sched:updateFrames()
    lurek.log.info("frame events = " .. fired)
    lurek.log.info("callback count = " .. fired_count)
end

--@api: LScheduler:everyFrames
do
    local count = 0
    local sched = lurek.timer.newScheduler()
    sched:everyFrames(2, function() count = count + 1 end, 2)
    sched:updateFrames()
    sched:updateFrames()
    sched:updateFrames()
    sched:updateFrames()
    lurek.log.info("frame ticks = " .. count)
end

--@api: LScheduler:updateFrames
do
    local sched = lurek.timer.newScheduler()
    local fired = 0
    sched:afterFrames(1, function() fired = fired + 1 end)
    local callbacks = sched:updateFrames()
    local empty = sched:isEmpty()
    lurek.log.info("frame events = " .. callbacks)
    lurek.log.info("callback count=" .. fired .. " empty=" .. tostring(empty))
end

--@api: LScheduler:cancel
do
    local sched = lurek.timer.newScheduler()
    sched:after(1.0, function() end)
    sched:after(3.0, function() end)
    local id = sched:after(2.0, function() end)
    local ok = sched:cancel(id)
    lurek.log.info("cancel id = " .. tostring(ok))
    lurek.log.info("count after = " .. sched:getCount())
end

--@api: LScheduler:cancelAll
do
    local sched = lurek.timer.newScheduler()
    sched:after(1.0, function() end)
    sched:after(2.0, function() end)
    sched:after(3.0, function() end)
    local removed = sched:cancelAll()
    lurek.log.info("cancelAll removed = " .. removed)
    lurek.log.info("empty = " .. tostring(sched:isEmpty()))
end

--@api: LScheduler:pause
do
    local sched = lurek.timer.newScheduler()
    local id = sched:after(1.0, function() end)
    sched:pause(id)
    local paused = sched:isPaused(id)
    local found, remaining = sched:getRemaining(id)
    local count = sched:getCount()
    lurek.log.info("paused event id=" .. id .. " paused=" .. tostring(paused))
    lurek.log.info("found=" .. tostring(found) .. " remaining=" .. remaining .. " count=" .. count)
end

--@api: LScheduler:resume
do
    local sched = lurek.timer.newScheduler()
    local id = sched:after(1.0, function() end)
    sched:pause(id)
    sched:resume(id)
    lurek.log.info("resumed, paused = " .. tostring(sched:isPaused(id)))
end

--@api: LScheduler:isPaused
do
    local sched = lurek.timer.newScheduler()
    local id = sched:after(1.0, function() end)
    sched:pause(id)
    local paused = sched:isPaused(id)
    sched:resume(id)
    local resumed = sched:isPaused(id)
    lurek.log.info("paused state = " .. tostring(paused))
    lurek.log.info("after resume paused = " .. tostring(resumed))
end

--@api: LScheduler:getRemaining
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local id = sched:every(0.5, function() end, 10)
    local found, remaining = sched:getRemaining(id)
    sched:update(0.2)
    local found2, remaining2 = sched:getRemaining(id)
    lurek.log.info("remaining found=" .. tostring(found) .. " time=" .. remaining)
    lurek.log.info("after update found=" .. tostring(found2) .. " time=" .. remaining2)
end

--@api: LScheduler:getInterval
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local id = sched:every(0.5, function() end, 10)
    local found2, interval = sched:getInterval(id)
    local _, repeats = sched:getRepeatCount(id)
    local _, remaining = sched:getRemaining(id)
    lurek.log.info("interval found=" .. tostring(found2) .. " value=" .. interval)
    lurek.log.info("repeat count=" .. repeats .. " remaining=" .. remaining)
end

--@api: LScheduler:getRepeatCount
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local id = sched:every(0.5, function() end, 10)
    local found3, repeats = sched:getRepeatCount(id)
    sched:update(0.5)
    local _, repeats_after = sched:getRepeatCount(id)
    lurek.log.info("repeat count found=" .. tostring(found3) .. " value=" .. repeats)
    lurek.log.info("after one tick repeats = " .. repeats_after)
end

--@api: LScheduler:resetEvent
do
    local sched = lurek.timer.newScheduler()
    local id = sched:every(0.5, function() end, 10)
    sched:update(0.3)
    sched:resetEvent(id)
    local found, remaining = sched:getRemaining(id)
    lurek.log.info("after reset, remaining = " .. remaining)
end

--@api: LScheduler:setInterval
do
    local sched = lurek.timer.newScheduler()
    local id = sched:every(1.0, function() end)
    sched:setInterval(id, 0.5)
    local found, interval = sched:getInterval(id)
    local _, remaining = sched:getRemaining(id)
    lurek.log.info("interval changed to 0.5 found=" .. tostring(found))
    lurek.log.info("interval=" .. interval .. " remaining=" .. remaining)
end

--@api: LScheduler:setTimeScale
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    sched:setTimeScale(2.0)
    local scale = sched:getTimeScale()
    local fired = 0
    sched:after(1.0, function() fired = fired + 1 end)
    local callbacks = sched:update(0.5)
    lurek.log.info("time scale = " .. scale)
    lurek.log.info("callbacks=" .. callbacks .. " fired=" .. fired)
end

--@api: LScheduler:getTimeScale
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    sched:setTimeScale(2.0)
    local scale = sched:getTimeScale()
    local count = sched:getCount()
    local type_name = sched:type()
    lurek.log.info("time scale = " .. scale)
    lurek.log.info("scheduler count=" .. count .. " type=" .. type_name)
end

--@api: lurek.timer.chain
do
    local count = 0
    local sched = lurek.timer.chain({
        { delay = 0.5, func = function() count = count + 1 end },
        { delay = 1.0, func = function() count = count + 1 end },
    })

    sched:update(0.5)
    sched:update(1.0)
    lurek.log.info("chain steps = " .. count)
end

--@api: lurek.timer.afterReal
do
    local callback_count = 0
    lurek.timer.afterReal(0.0, function() callback_count = callback_count + 1 end)
    local fired = lurek.timer.tickRealTimers()
    local second = lurek.timer.tickRealTimers()
    lurek.log.info("real timers fired = " .. fired)
    lurek.log.info("callback count=" .. callback_count .. " second tick=" .. second)
end

--@api: lurek.timer.sleep
do
    local before = lurek.timer.getMicroTime()
    lurek.timer.sleep(0)
    local after_zero = lurek.timer.getMicroTime()
    lurek.timer.sleep(0.01)
    local after_sleep = lurek.timer.getMicroTime()
    lurek.log.info("sleep(0) elapsed = " .. (after_zero - before))
    lurek.log.info("sleep(0.01) elapsed = " .. (after_sleep - after_zero))
end

--- Timer Part 1: advanced timer functions, scheduler full coverage

--@api: lurek.timer.setPhysicsDelta
do
    lurek.timer.setPhysicsDelta(1/60)
    local pd = lurek.timer.getPhysicsDelta()
    local steps = lurek.timer.getPhysicsMaxSteps()
    local per_second = 1 / pd
    lurek.log.info("physics_delta=" .. pd)
    lurek.log.info("steps/sec=" .. per_second .. " maxSteps=" .. steps)
end

--@api: lurek.timer.setPhysicsMaxSteps
do
    lurek.timer.setPhysicsMaxSteps(5)
    local pm = lurek.timer.getPhysicsMaxSteps()
    local pdt = lurek.timer.getPhysicsDelta()
    local total_budget = pm * pdt
    lurek.log.info("physics_max_steps=" .. pm)
    lurek.log.info("maximum catch-up seconds=" .. total_budget)
end

--@api: lurek.timer.setSmoothingFactor
do
    lurek.timer.setSmoothingFactor(0.1)
    local sd = lurek.timer.getSmoothedDelta()
    local raw = lurek.timer.getDelta()
    local avg = lurek.timer.getAverageDelta()
    lurek.log.info("smoothed_delta=" .. sd)
    lurek.log.info("raw=" .. raw .. " avg=" .. avg)
end

--@api: lurek.timer.tickRealTimers
do
    local fired = lurek.timer.tickRealTimers()
    local fired2 = lurek.timer.tickRealTimers()
    local now = lurek.timer.getTime()
    lurek.log.info("real timers fired = " .. fired)
    lurek.log.info("second tick=" .. fired2 .. " time=" .. now)
end

--@api: lurek.timer.tickWaits
do
    local co = coroutine.create(function()
        lurek.timer.waitFrames(1)
        lurek.timer.waitSeconds(0)
    end)
    coroutine.resume(co)
    lurek.timer.tickWaits()
    lurek.timer.tickWaits()
    lurek.log.info("wait coroutine = " .. coroutine.status(co))
end

--@api: lurek.timer.waitFrames
do
    local co = coroutine.create(function() lurek.timer.waitFrames(1) end)
    coroutine.resume(co)
    lurek.timer.tickWaits()
    lurek.timer.tickWaits()
    lurek.log.info("wait coroutine = " .. coroutine.status(co))
end

--@api: lurek.timer.waitSeconds
do
    local co = coroutine.create(function() lurek.timer.waitSeconds(0) end)
    coroutine.resume(co)
    lurek.timer.tickWaits()
    local status = coroutine.status(co)
    local resumed = lurek.timer.tickWaits()
    lurek.log.info("wait coroutine = " .. status)
    lurek.log.info("second tick resumed = " .. resumed)
end

--@api: LScheduler:getCount
do
    local sched = lurek.timer.newScheduler()
    local before = sched:getCount()
    sched:after(1.0, function() lurek.log.info("after timer fired") end)
    local after = sched:getCount()
    local empty = sched:isEmpty()
    lurek.log.info("count before = " .. before)
    lurek.log.info("count after = " .. after .. " empty=" .. tostring(empty))
end

--@api: LScheduler:isEmpty
do
    local sched = lurek.timer.newScheduler()
    local empty_before = sched:isEmpty()
    sched:after(1.0, function() end)
    local empty_with_timer = sched:isEmpty()
    sched:cancelAll()
    local empty_after = sched:isEmpty()
    lurek.log.info("empty before = " .. tostring(empty_before) .. " withTimer=" .. tostring(empty_with_timer))
    lurek.log.info("empty after cancelAll = " .. tostring(empty_after))
end

--@api: LScheduler:isPausedNamed
do
    local sched = lurek.timer.newScheduler()
    sched:afterNamed("named_once", 2.0, function() end)
    sched:pauseNamed("named_once")
    local paused = sched:isPausedNamed("named_once")
    local count = sched:getCount()
    sched:resumeNamed("named_once")
    lurek.log.info("paused_named=" .. tostring(paused))
    lurek.log.info("count=" .. count .. " resumed=" .. tostring(sched:isPausedNamed("named_once")))
end

--@api: LScheduler:pauseNamed
do
    local sched = lurek.timer.newScheduler()
    sched:afterNamed("named_once", 2.0, function() end)
    sched:pauseNamed("named_once")
    local paused = sched:isPausedNamed("named_once")
    local cancelled = sched:cancelNamed("named_once")
    lurek.log.info("paused_named=" .. tostring(paused))
    lurek.log.info("cancelled after pause = " .. tostring(cancelled))
end

--@api: LScheduler:resumeNamed
do
    local sched = lurek.timer.newScheduler()
    sched:afterNamed("named_once", 2.0, function() end)
    sched:pauseNamed("named_once")
    local resumed = sched:resumeNamed("named_once")
    lurek.log.info("resumeNamed ok = " .. tostring(resumed))
    lurek.log.info("paused_named = " .. tostring(sched:isPausedNamed("named_once")))
end

--@api: LScheduler:type
do
    local sched = lurek.timer.newScheduler()
    local type_name = sched:type()
    local is_sched = sched:typeOf("LScheduler")
    local is_object = sched:typeOf("LObject")
    lurek.log.info("type=" .. type_name)
    lurek.log.info("isScheduler=" .. tostring(is_sched) .. " isObject=" .. tostring(is_object))
end

--@api: LScheduler:typeOf
do
    local sched = lurek.timer.newScheduler()
    local is_sched = sched:typeOf("LScheduler")
    local is_object = sched:typeOf("LObject")
    local is_window = sched:typeOf("LWindow")
    lurek.log.info("typeOf LScheduler = " .. tostring(is_sched))
    lurek.log.info("window span = " .. tostring(tw:getWindow()) .. " window=" .. tostring(is_window))
end
