-- content/examples/timer.lua
-- love2d-style usage snippets for the lurek.timer API (43 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/timer.lua

-- ── lurek.timer.* functions ──

--@api-stub: lurek.timer.getDelta
-- Returns the delta time in seconds for the current frame.
-- Cheap to call; safe inside callbacks.
local value = lurek.timer.getDelta()
print("getDelta:", value)
return value

--@api-stub: lurek.timer.getFPS
-- Returns the current frames-per-second measurement.
-- Cheap to call; safe inside callbacks.
local value = lurek.timer.getFPS()
print("getFPS:", value)
return value

--@api-stub: lurek.timer.getTime
-- Returns the total elapsed time since engine start in seconds.
-- Cheap to call; safe inside callbacks.
local value = lurek.timer.getTime()
print("getTime:", value)
return value

--@api-stub: lurek.timer.getAverageDelta
-- Returns the rolling-average frame delta time in seconds.
-- Cheap to call; safe inside callbacks.
local value = lurek.timer.getAverageDelta()
print("getAverageDelta:", value)
return value

--@api-stub: lurek.timer.getFrameCount
-- Returns the total number of frames rendered since engine start.
-- Cheap to call; safe inside callbacks.
local value = lurek.timer.getFrameCount()
print("getFrameCount:", value)
return value

--@api-stub: lurek.timer.step
-- Advances the timer by one frame, returning the delta time.
-- Trigger from input, timers, or game events.
-- trigger from input or timer
lurek.timer.step()
print("step fired")
print("ok")

--@api-stub: lurek.timer.getMicroTime
-- Returns the high-resolution elapsed time since engine start in seconds.
-- Cheap to call; safe inside callbacks.
local value = lurek.timer.getMicroTime()
print("getMicroTime:", value)
return value

--@api-stub: lurek.timer.getPhysicsDelta
-- Returns the fixed timestep used by `process_physics` callbacks (seconds).
-- Cheap to call; safe inside callbacks.
local value = lurek.timer.getPhysicsDelta()
print("getPhysicsDelta:", value)
return value

--@api-stub: lurek.timer.setPhysicsDelta
-- Sets the fixed timestep for `process_physics` callbacks (seconds).
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.timer.setPhysicsDelta(dt)
print("setPhysicsDelta applied")
print("ok")

--@api-stub: lurek.timer.getPhysicsMaxSteps
-- Returns the maximum number of physics sub-steps allowed per frame.
-- Cheap to call; safe inside callbacks.
local value = lurek.timer.getPhysicsMaxSteps()
print("getPhysicsMaxSteps:", value)
return value

--@api-stub: lurek.timer.setPhysicsMaxSteps
-- Sets the maximum number of physics sub-steps allowed per frame (clamped 1â€“64).
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.timer.setPhysicsMaxSteps(10)
print("setPhysicsMaxSteps applied")
print("ok")

--@api-stub: lurek.timer.sleep
-- Suspends execution for the given number of seconds.
-- See the module spec for detailed semantics.
local result = lurek.timer.sleep(1.0)
print("sleep:", result)
return result

--@api-stub: lurek.timer.newScheduler
-- Creates a new independent Scheduler for managing timed callbacks.
-- Build once at startup; reuse across frames.
local scheduler = lurek.timer.newScheduler()
print("created", scheduler)
return scheduler

--@api-stub: lurek.timer.chain
-- Creates a new Scheduler loaded with a sequenced one-shot chain.
-- See the module spec for detailed semantics.
local result = lurek.timer.chain(steps)
print("chain:", result)
return result

--@api-stub: lurek.timer.afterReal
-- Schedules a one-shot callback that fires after `delay` wall-clock seconds,.
-- See the module spec for detailed semantics.
local result = lurek.timer.afterReal(1.0, function() print("afterReal fired") end)
print("afterReal:", result)
return result

--@api-stub: lurek.timer.tickRealTimers
-- Advances all real-time timers by one tick; called automatically each frame.
-- Trigger from input, timers, or game events.
-- trigger from input or timer
lurek.timer.tickRealTimers()
print("tickRealTimers fired")
print("ok")

--@api-stub: lurek.timer.setSmoothingFactor
-- Sets the smoothing factor (alpha) for `getSmoothedDelta`.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.timer.setSmoothingFactor(1)
print("setSmoothingFactor applied")
print("ok")

--@api-stub: lurek.timer.getSmoothedDelta
-- Returns the exponential moving-average of frame deltas in seconds.
-- Cheap to call; safe inside callbacks.
local value = lurek.timer.getSmoothedDelta()
print("getSmoothedDelta:", value)
return value

--@api-stub: lurek.timer.waitSeconds
-- Yields the current Lua coroutine for at least `seconds` wall-clock seconds.
-- See the module spec for detailed semantics.
local result = lurek.timer.waitSeconds(1.0)
print("waitSeconds:", result)
return result

--@api-stub: lurek.timer.waitFrames
-- Yields the current Lua coroutine for at least `frames` engine frames.
-- See the module spec for detailed semantics.
local result = lurek.timer.waitFrames(frames)
print("waitFrames:", result)
return result

--@api-stub: lurek.timer.tickWaits
-- Advances all `lurek.timer.wait()` coroutines by one tick; called each frame.
-- Trigger from input, timers, or game events.
-- trigger from input or timer
lurek.timer.tickWaits()
print("tickWaits fired")
print("ok")

-- ── Scheduler methods ──

--@api-stub: Scheduler:after
-- Schedules a callback to fire once after a delay.
-- See the module spec for detailed semantics.
local scheduler = lurek.timer.newScheduler()
scheduler:after(1.0, function() print("after fired") end)
print("Scheduler:after done")

--@api-stub: Scheduler:afterFrames
-- Schedules a callback to fire once after `n` frames.
-- See the module spec for detailed semantics.
local scheduler = lurek.timer.newScheduler()
scheduler:afterFrames(10, function() print("afterFrames fired") end)
print("Scheduler:afterFrames done")

--@api-stub: Scheduler:cancel
-- Cancels a scheduled event by its numeric ID.
-- Pair with the matching constructor to free resources.
local scheduler = lurek.timer.newScheduler()
scheduler:cancel(1)
-- scheduler is now released
print("ok")

--@api-stub: Scheduler:cancelNamed
-- Cancels a scheduled event by its string name.
-- Pair with the matching constructor to free resources.
local scheduler = lurek.timer.newScheduler()
scheduler:cancelNamed("main")
-- scheduler is now released
print("ok")

--@api-stub: Scheduler:cancelAll
-- Cancels all scheduled events and returns the count removed.
-- Pair with the matching constructor to free resources.
local scheduler = lurek.timer.newScheduler()
scheduler:cancelAll()
-- scheduler is now released
print("ok")

--@api-stub: Scheduler:pause
-- Pauses a scheduled event by its ID.
-- Trigger from input, timers, or game events.
local scheduler = lurek.timer.newScheduler()
scheduler:pause(1)
-- trigger from input, timer, or event
print("ok")

--@api-stub: Scheduler:resume
-- Resumes a paused event by its ID.
-- Trigger from input, timers, or game events.
local scheduler = lurek.timer.newScheduler()
scheduler:resume(1)
-- trigger from input, timer, or event
print("ok")

--@api-stub: Scheduler:isPaused
-- Returns whether the given event is currently paused.
-- Use as a guard inside lurek.update or event handlers.
local scheduler = lurek.timer.newScheduler()
if scheduler:isPaused(1) then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Scheduler:pauseNamed
-- Pauses a scheduled event by its string name.
-- Trigger from input, timers, or game events.
local scheduler = lurek.timer.newScheduler()
scheduler:pauseNamed("main")
-- trigger from input, timer, or event
print("ok")

--@api-stub: Scheduler:resumeNamed
-- Resumes a paused event by its string name.
-- Trigger from input, timers, or game events.
local scheduler = lurek.timer.newScheduler()
scheduler:resumeNamed("main")
-- trigger from input, timer, or event
print("ok")

--@api-stub: Scheduler:isPausedNamed
-- Returns whether the named event is currently paused.
-- Use as a guard inside lurek.update or event handlers.
local scheduler = lurek.timer.newScheduler()
if scheduler:isPausedNamed("main") then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Scheduler:getRemaining
-- Returns the seconds remaining until the next fire for an event, or nil.
-- Cheap to call; safe inside callbacks.
local scheduler = lurek.timer.newScheduler()  -- or your existing handle
local value = scheduler:getRemaining(1)
print("Scheduler:getRemaining ->", value)

--@api-stub: Scheduler:getInterval
-- Returns the base interval in seconds for an event, or nil.
-- Cheap to call; safe inside callbacks.
local scheduler = lurek.timer.newScheduler()  -- or your existing handle
local value = scheduler:getInterval(1)
print("Scheduler:getInterval ->", value)

--@api-stub: Scheduler:getRepeatCount
-- Returns the repeat count remaining for an event, or nil.
-- Cheap to call; safe inside callbacks.
local scheduler = lurek.timer.newScheduler()  -- or your existing handle
local value = scheduler:getRepeatCount(1)
print("Scheduler:getRepeatCount ->", value)

--@api-stub: Scheduler:getCount
-- Returns the number of active scheduled events.
-- Cheap to call; safe inside callbacks.
local scheduler = lurek.timer.newScheduler()  -- or your existing handle
local value = scheduler:getCount()
print("Scheduler:getCount ->", value)

--@api-stub: Scheduler:isEmpty
-- Returns whether the scheduler has no active events.
-- Use as a guard inside lurek.update or event handlers.
local scheduler = lurek.timer.newScheduler()
if scheduler:isEmpty() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Scheduler:setInterval
-- Changes the repeat interval of an existing event.
-- Apply at startup or in response to user input.
local scheduler = lurek.timer.newScheduler()
scheduler:setInterval(1, interval)
print("Scheduler:setInterval applied")

--@api-stub: Scheduler:resetEvent
-- Resets an event's remaining time back to its original interval.
-- Pair with the matching constructor to free resources.
local scheduler = lurek.timer.newScheduler()
scheduler:resetEvent(1)
-- scheduler is now released
print("ok")

--@api-stub: Scheduler:setTimeScale
-- Sets a global time-scale multiplier for this scheduler.
-- Apply at startup or in response to user input.
local scheduler = lurek.timer.newScheduler()
scheduler:setTimeScale(1.0)
print("Scheduler:setTimeScale applied")

--@api-stub: Scheduler:getTimeScale
-- Returns the current time-scale multiplier.
-- Cheap to call; safe inside callbacks.
local scheduler = lurek.timer.newScheduler()  -- or your existing handle
local value = scheduler:getTimeScale()
print("Scheduler:getTimeScale ->", value)

--@api-stub: Scheduler:update
-- Advances all timers by dt seconds, firing due callbacks.
-- Apply at startup or in response to user input.
local scheduler = lurek.timer.newScheduler()
scheduler:update(dt)
print("Scheduler:update applied")

--@api-stub: Scheduler:updateFrames
-- Advances frame-based events by one frame, firing due callbacks.
-- Apply at startup or in response to user input.
local scheduler = lurek.timer.newScheduler()
scheduler:updateFrames()
print("Scheduler:updateFrames applied")

