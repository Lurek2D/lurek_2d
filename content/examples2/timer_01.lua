--- Timer Part 1: advanced timer functions, scheduler full coverage

--@api-stub: lurek.timer.setPhysicsDelta
--@api-stub: lurek.timer.setPhysicsMaxSteps
--@api-stub: lurek.timer.setSmoothingFactor
--@api-stub: lurek.timer.tickRealTimers
--@api-stub: lurek.timer.tickWaits
--@api-stub: lurek.timer.waitFrames
--@api-stub: lurek.timer.waitSeconds
-- Advanced timer functions: physics delta, smoothing, wait helpers, tick hooks.
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

    lurek.timer.waitFrames(1)
    lurek.timer.waitSeconds(0.0001)

end

--@api-stub: LScheduler:getCount
--@api-stub: LScheduler:isEmpty
--@api-stub: LScheduler:isPausedNamed
--@api-stub: LScheduler:pauseNamed
--@api-stub: LScheduler:resumeNamed
--@api-stub: LScheduler:type
--@api-stub: LScheduler:typeOf
-- LScheduler: schedule delayed/repeating callbacks by time or frame, pause/resume, type.
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

print("timer_01.lua")
