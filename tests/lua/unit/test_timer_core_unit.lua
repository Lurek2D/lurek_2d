-- Lurek2D timer API unit tests
-- One owner test per public timer symbol.

local function new_scheduler()
    return lurek.timer.newScheduler()
end

local function run_wait_coroutine(wait_fn)
    local co = coroutine.create(wait_fn)
    coroutine.resume(co)
    lurek.timer.tickWaits()
    return coroutine.status(co)
end

-- @describe lurek.timer
describe("lurek.timer", function()
    -- @covers lurek.timer.getDelta
    it("returns a non-negative frame delta", function()
        local dt = lurek.timer.getDelta()
        expect_type("number", dt)
        expect_true(dt >= 0)
    end)

    -- @covers lurek.timer.getFPS
    it("returns a non-negative frames-per-second value", function()
        local fps = lurek.timer.getFPS()
        expect_type("number", fps)
        expect_true(fps >= 0)
    end)

    -- @covers lurek.timer.getTime
    it("returns a non-negative engine time", function()
        local t = lurek.timer.getTime()
        expect_type("number", t)
        expect_true(t >= 0)
    end)

    -- @covers lurek.timer.getAverageDelta
    it("returns a non-negative average frame delta", function()
        local avg = lurek.timer.getAverageDelta()
        expect_type("number", avg)
        expect_true(avg >= 0)
    end)

    -- @covers lurek.timer.getMicroTime
    it("returns monotonic high-resolution time", function()
        local t1 = lurek.timer.getMicroTime()
        local t2 = lurek.timer.getMicroTime()
        expect_type("number", t1)
        expect_true(t2 >= t1)
    end)

    -- @covers lurek.timer.sleep
    it("accepts zero or negative sleep durations without error", function()
        expect_no_error(function()
            lurek.timer.sleep(0)
            lurek.timer.sleep(-1)
        end)
    end)

    -- @covers lurek.timer.step
    it("advances the timer and updates getDelta", function()
        local dt = lurek.timer.step()
        local after = lurek.timer.getDelta()
        expect_type("number", dt)
        expect_true(dt >= 0)
        expect_true(math.abs(after - dt) < 1e-9)
    end)

    -- @covers lurek.timer.getPhysicsDelta
    it("returns the fixed physics timestep", function()
        local dt = lurek.timer.getPhysicsDelta()
        expect_type("number", dt)
        expect_near(1.0 / 60.0, dt, 1e-6)
    end)

    -- @covers lurek.timer.setPhysicsDelta
    it("clamps and stores physics delta values", function()
        lurek.timer.setPhysicsDelta(1.0 / 30.0)
        expect_near(1.0 / 30.0, lurek.timer.getPhysicsDelta(), 1e-9)
        lurek.timer.setPhysicsDelta(0.001)
        expect_near(1.0 / 240.0, lurek.timer.getPhysicsDelta(), 1e-9)
        lurek.timer.setPhysicsDelta(1.0)
        expect_near(1.0 / 10.0, lurek.timer.getPhysicsDelta(), 1e-9)
        lurek.timer.setPhysicsDelta(1.0 / 60.0)
    end)

    -- @covers lurek.timer.newScheduler
    it("creates an empty scheduler handle", function()
        local sched = new_scheduler()
        expect_not_nil(sched)
        expect_equal(0, sched:getCount())
        expect_true(sched:isEmpty())
    end)

    -- @covers lurek.timer.getFrameCount
    it("returns a non-negative integer frame count", function()
        local count = lurek.timer.getFrameCount()
        expect_type("number", count)
        expect_true(count >= 0)
        expect_equal(math.floor(count), count)
    end)

    -- @covers lurek.timer.chain
    it("builds a scheduler that fires sequential steps", function()
        local results = {}
        local sched = lurek.timer.chain({
            { delay = 0.1, func = function() table.insert(results, 1) end },
            { delay = 0.2, func = function() table.insert(results, 2) end },
        })
        sched:update(0.15)
        expect_equal(1, #results)
        sched:update(0.2)
        expect_equal(2, #results)
    end)

    -- @covers lurek.timer.tickRealTimers
    it("fires real-time callbacks scheduled for immediate execution", function()
        local fired = false
        lurek.timer.afterReal(0.0, function()
            fired = true
        end)
        local count = lurek.timer.tickRealTimers()
        expect_true(count >= 1)
        expect_true(fired)
    end)

    -- @covers lurek.timer.getSmoothedDelta
    it("returns a non-negative smoothed delta", function()
        lurek.timer.setSmoothingFactor(0.5)
        local dt = lurek.timer.getSmoothedDelta()
        expect_type("number", dt)
        expect_true(dt >= 0)
    end)

    -- @covers lurek.timer.tickWaits
    it("resumes ready waiting coroutines and returns a resume count", function()
        local co = coroutine.create(function()
            lurek.timer.waitFrames(1)
        end)
        coroutine.resume(co)
        local resumed = lurek.timer.tickWaits()
        expect_type("number", resumed)
        expect_equal("dead", coroutine.status(co))
    end)

    -- @covers lurek.timer.waitFrames
    it("requires coroutine context", function()
        expect_error(function()
            lurek.timer.waitFrames(1)
        end)
    end)

    -- @covers lurek.timer.waitSeconds
    it("yields inside a coroutine until tickWaits resumes it", function()
        expect_equal("dead", run_wait_coroutine(function()
            lurek.timer.waitSeconds(0)
        end))
    end)

    -- @covers lurek.timer.getPhysicsMaxSteps
    it("returns the default maximum physics step count", function()
        expect_equal(8, lurek.timer.getPhysicsMaxSteps())
    end)

    -- @covers lurek.timer.setPhysicsMaxSteps
    it("clamps and stores physics max step counts", function()
        lurek.timer.setPhysicsMaxSteps(16)
        expect_equal(16, lurek.timer.getPhysicsMaxSteps())
        lurek.timer.setPhysicsMaxSteps(0)
        expect_equal(1, lurek.timer.getPhysicsMaxSteps())
        lurek.timer.setPhysicsMaxSteps(999)
        expect_equal(64, lurek.timer.getPhysicsMaxSteps())
        lurek.timer.setPhysicsMaxSteps(8)
    end)

    -- @covers lurek.timer.afterReal
    it("schedules a real-time callback", function()
        local fired = false
        lurek.timer.afterReal(0.0, function()
            fired = true
        end)
        lurek.timer.tickRealTimers()
        expect_true(fired)
    end)

    -- @covers lurek.timer.setSmoothingFactor
    it("accepts smoothing factor changes", function()
        expect_no_error(function()
            lurek.timer.setSmoothingFactor(0.1)
            lurek.timer.setSmoothingFactor(1.0)
        end)
    end)

    -- @covers LScheduler:after
    it("creates a one-shot timer that fires once", function()
        local sched = new_scheduler()
        local fired = false
        local id = sched:after(0.5, function() fired = true end)
        expect_type("number", id)
        sched:update(0.3)
        expect_false(fired)
        sched:update(0.3)
        expect_true(fired)
        expect_equal(0, sched:getCount())
    end)

    -- @covers LScheduler:afterFrames
    it("fires after the requested number of frame updates", function()
        local sched = new_scheduler()
        local fired = 0
        sched:afterFrames(2, function() fired = fired + 1 end)
        sched:updateFrames()
        expect_equal(0, fired)
        sched:updateFrames()
        expect_equal(1, fired)
    end)

    -- @covers LScheduler:afterNamed
    it("replaces existing named one-shot timers", function()
        local sched = new_scheduler()
        local fired_old = false
        local fired_new = false
        sched:afterNamed("action", 0.1, function() fired_old = true end)
        sched:afterNamed("action", 0.1, function() fired_new = true end)
        expect_equal(1, sched:getCount())
        sched:update(0.2)
        expect_false(fired_old)
        expect_true(fired_new)
    end)

    -- @covers LScheduler:cancel
    it("cancels events by id", function()
        local sched = new_scheduler()
        local id = sched:after(1.0, function() end)
        expect_true(sched:cancel(id))
        expect_false(sched:cancel(9999))
    end)

    -- @covers LScheduler:cancelAll
    it("removes all scheduled events", function()
        local sched = new_scheduler()
        sched:after(1.0, function() end)
        sched:after(2.0, function() end)
        sched:every(0.5, function() end)
        expect_true(sched:cancelAll() >= 3)
        expect_equal(0, sched:getCount())
    end)

    -- @covers LScheduler:cancelNamed
    it("cancels named events", function()
        local sched = new_scheduler()
        sched:afterNamed("mytimer", 1.0, function() end)
        expect_true(sched:cancelNamed("mytimer"))
        expect_equal(0, sched:getCount())
    end)

    -- @covers LScheduler:every
    it("fires repeating timers at the configured interval", function()
        local sched = new_scheduler()
        local count = 0
        local id = sched:every(0.5, function() count = count + 1 end, 3)
        expect_type("number", id)
        sched:update(0.5)
        sched:update(0.5)
        sched:update(0.5)
        expect_equal(3, count)
    end)

    -- @covers LScheduler:everyFrames
    it("fires repeating frame-based timers", function()
        local sched = new_scheduler()
        local count = 0
        sched:everyFrames(2, function() count = count + 1 end, 3)
        for _ = 1, 6 do
            sched:updateFrames()
        end
        expect_equal(3, count)
    end)

    -- @covers LScheduler:everyNamed
    it("supports named repeating timers", function()
        local sched = new_scheduler()
        local count = 0
        sched:everyNamed("ticker", 0.1, function() count = count + 1 end, 2)
        sched:update(0.1)
        sched:update(0.1)
        expect_equal(2, count)
    end)

    -- @covers LScheduler:getCount
    it("returns the number of scheduled events", function()
        local sched = new_scheduler()
        sched:after(1.0, function() end)
        sched:after(2.0, function() end)
        expect_equal(2, sched:getCount())
    end)

    -- @covers LScheduler:getInterval
    it("returns the configured interval for repeating events", function()
        local sched = new_scheduler()
        local id = sched:every(0.25, function() end)
        local ok, interval = sched:getInterval(id)
        expect_true(ok)
        expect_near(0.25, interval, 0.0001)
    end)

    -- @covers LScheduler:getRemaining
    it("tracks remaining time before an event fires", function()
        local sched = new_scheduler()
        local id = sched:after(5.0, function() end)
        local ok1, remaining1 = sched:getRemaining(id)
        expect_true(ok1)
        expect_near(5.0, remaining1, 0.0001)
        sched:update(1.0)
        local ok2, remaining2 = sched:getRemaining(id)
        expect_true(ok2)
        expect_near(4.0, remaining2, 0.0001)
    end)

    -- @covers LScheduler:getRepeatCount
    it("tracks remaining repeat counts", function()
        local sched = new_scheduler()
        local id = sched:every(0.5, function() end, 3)
        local ok1, count1 = sched:getRepeatCount(id)
        expect_true(ok1)
        expect_equal(3, count1)
        sched:update(0.5)
        local ok2, count2 = sched:getRepeatCount(id)
        expect_true(ok2)
        expect_equal(2, count2)
    end)

    -- @covers LScheduler:getTimeScale
    it("returns the configured scheduler time scale", function()
        local sched = new_scheduler()
        sched:setTimeScale(2.0)
        expect_near(2.0, sched:getTimeScale(), 0.0001)
    end)

    -- @covers LScheduler:isEmpty
    it("returns false once events are scheduled", function()
        local sched = new_scheduler()
        expect_true(sched:isEmpty())
        sched:after(1.0, function() end)
        expect_false(sched:isEmpty())
    end)

    -- @covers LScheduler:isPaused
    it("reflects pause state for events by id", function()
        local sched = new_scheduler()
        local id = sched:after(1.0, function() end)
        expect_false(sched:isPaused(id))
        sched:pause(id)
        expect_true(sched:isPaused(id))
    end)

    -- @covers LScheduler:isPausedNamed
    it("reflects pause state for named events", function()
        local sched = new_scheduler()
        sched:everyNamed("ticker", 1.0, function() end)
        expect_false(sched:isPausedNamed("ticker"))
        sched:pauseNamed("ticker")
        expect_true(sched:isPausedNamed("ticker"))
    end)

    -- @covers LScheduler:pause
    it("pauses timed events until they are resumed", function()
        local sched = new_scheduler()
        local fired = false
        local id = sched:after(1.0, function() fired = true end)
        sched:update(0.4)
        sched:pause(id)
        sched:update(5.0)
        expect_false(fired)
        sched:resume(id)
        sched:update(0.7)
        expect_true(fired)
    end)

    -- @covers LScheduler:pauseNamed
    it("pauses named events", function()
        local sched = new_scheduler()
        local fired = false
        sched:everyNamed("paused", 0.1, function() fired = true end)
        sched:pauseNamed("paused")
        sched:update(0.2)
        expect_false(fired)
    end)

    -- @covers LScheduler:resetEvent
    it("restarts the countdown for an event", function()
        local sched = new_scheduler()
        local fired = false
        local id = sched:after(1.0, function() fired = true end)
        sched:update(0.7)
        expect_true(sched:resetEvent(id))
        sched:update(0.5)
        expect_false(fired)
        sched:update(0.6)
        expect_true(fired)
    end)

    -- @covers LScheduler:resume
    it("resumes paused events by id", function()
        local sched = new_scheduler()
        local fired = false
        local id = sched:after(1.0, function() fired = true end)
        sched:pause(id)
        sched:resume(id)
        sched:update(1.0)
        expect_true(fired)
    end)

    -- @covers LScheduler:resumeNamed
    it("resumes paused named events", function()
        local sched = new_scheduler()
        local fired = false
        sched:everyNamed("resumable", 0.1, function() fired = true end, 1)
        sched:pauseNamed("resumable")
        sched:resumeNamed("resumable")
        sched:update(0.1)
        expect_true(fired)
    end)

    -- @covers LScheduler:setInterval
    it("changes the interval of a repeating event", function()
        local sched = new_scheduler()
        local id = sched:every(0.5, function() end)
        sched:setInterval(id, 1.0)
        local ok, interval = sched:getInterval(id)
        expect_true(ok)
        expect_near(1.0, interval, 0.0001)
    end)

    -- @covers LScheduler:setTimeScale
    it("affects how quickly time-based events elapse", function()
        local sched = new_scheduler()
        local fired = false
        sched:after(1.0, function() fired = true end)
        sched:setTimeScale(2.0)
        sched:update(0.5)
        expect_true(fired)
    end)

    -- @covers LScheduler:type
    it("reports the scheduler type name", function()
        expect_type("string", new_scheduler():type())
    end)

    -- @covers LScheduler:typeOf
    it("checks scheduler type compatibility", function()
        expect_type("boolean", new_scheduler():typeOf("LObject"))
    end)

    -- @covers LScheduler:update
    it("advances timers and fires due callbacks", function()
        local sched = new_scheduler()
        local fired = 0
        sched:after(0.1, function() fired = fired + 1 end)
        sched:update(0.2)
        expect_equal(1, fired)
    end)

    -- @covers LScheduler:updateFrames
    it("returns the number of fired frame-based callbacks", function()
        local sched = new_scheduler()
        sched:afterFrames(1, function() end)
        sched:afterFrames(1, function() end)
        local count = sched:updateFrames()
        expect_equal(2, count)
    end)
end)

test_summary()
