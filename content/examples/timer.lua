-- content/examples/timer.lua
-- Lurek2D lurek.timer API Reference
-- Run with: cargo run -- content/examples/timer

-- =============================================================================
-- lurek.timer — Frame timing, schedulers, and time control
--
-- The timer module provides frame delta time, FPS counters, physics timing,
-- and a Scheduler object for game-logic timers (cooldowns, delayed spawns,
-- repeating effects).  It also offers real-time timers, coroutine-style waits,
-- and a chaining API for sequencing timed events.
-- =============================================================================

-- ---- Stub: lurek.timer.getDelta ------------------------------------------
--@api-stub: lurek.timer.getDelta
-- Read the frame delta time to move the player at a consistent speed
-- regardless of frame rate.  At 60 FPS delta is ~0.0167 seconds.
local dt = lurek.timer.getDelta()
print(string.format("frame delta: %.4f sec", dt))
local player_speed = 200   -- pixels per second
local move_x = player_speed * dt
print(string.format("player moves %.2f pixels this frame", move_x))

-- ---- Stub: lurek.timer.getFPS --------------------------------------------
--@api-stub: lurek.timer.getFPS
-- Display a live FPS counter in the debug overlay.  Compare against the
-- target (60 FPS) to detect performance regressions.
local fps = lurek.timer.getFPS()
print(string.format("current FPS: %.1f", fps))
if fps < 55 then
    print("  WARNING: below 60 FPS target")
end

-- ---- Stub: lurek.timer.getTime -------------------------------------------
--@api-stub: lurek.timer.getTime
-- Get the total elapsed time since engine start.  Use it to drive continuous
-- animations like a sine-wave idle bob on the player sprite.
local t = lurek.timer.getTime()
local bob_offset = math.sin(t * 3.0) * 4.0   -- 3 Hz oscillation, 4 px amplitude
print(string.format("time: %.2f sec  idle bob offset: %.1f px", t, bob_offset))

-- ---- Stub: lurek.timer.getAverageDelta -----------------------------------
--@api-stub: lurek.timer.getAverageDelta
-- Demonstrates the proper usage of lurek.timer.getAverageDelta.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_timer_getAverageDelta()
    local avg_dt = lurek.timer.getAverageDelta()
    local smooth_fps = 1.0 / math.max(avg_dt, 0.001)
    print(string.format("avg delta: %.4f sec  smooth FPS: %.1f", avg_dt, smooth_fps))
end
local _ok, _err = pcall(demo_lurek_timer_getAverageDelta)

-- ---- Stub: lurek.timer.getFrameCount -------------------------------------
--@api-stub: lurek.timer.getFrameCount
-- Use the frame counter to trigger periodic tasks: auto-save every 3600
-- frames (~60 sec at 60 FPS) without tracking wall-clock time.
local frames = lurek.timer.getFrameCount()
print("total frames: " .. frames)
if frames > 0 and frames % 3600 == 0 then
    print("  auto-save triggered at frame " .. frames)
end

-- ---- Stub: lurek.timer.step ----------------------------------------------
--@api-stub: lurek.timer.step
-- Demonstrates the proper usage of lurek.timer.step.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_timer_step()
    lurek.timer.step(0.016)   -- advance exactly one 60-FPS frame
    print("timer stepped by 0.016 sec (1 frame at 60 FPS)")
end
local _ok, _err = pcall(demo_lurek_timer_step)

-- ---- Stub: lurek.timer.getMicroTime --------------------------------------
--@api-stub: lurek.timer.getMicroTime
-- High-resolution timestamp for micro-benchmarking code sections.
local t0 = lurek.timer.getMicroTime()
-- simulate work
local sum = 0
for i = 1, 10000 do sum = sum + i end
local t1 = lurek.timer.getMicroTime()
local elapsed_us = (t1 - t0) * 1000000
print(string.format("loop took %.1f microseconds", elapsed_us))

-- ---- Stub: lurek.timer.getPhysicsDelta -----------------------------------
--@api-stub: lurek.timer.getPhysicsDelta
-- Demonstrates the proper usage of lurek.timer.getPhysicsDelta.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_timer_getPhysicsDelta()
    local phys_dt = lurek.timer.getPhysicsDelta()
    print(string.format("physics delta: %.4f sec (%.0f Hz)", phys_dt, 1.0 / phys_dt))
end
local _ok, _err = pcall(demo_lurek_timer_getPhysicsDelta)

-- ---- Stub: lurek.timer.setPhysicsDelta -----------------------------------
--@api-stub: lurek.timer.setPhysicsDelta
-- Increase the physics step to 120 Hz for a fighting game that needs
-- precise collision detection at high speed.
lurek.timer.setPhysicsDelta(1.0 / 120.0)
print("physics rate set to 120 Hz")
print("  new physics delta: " .. lurek.timer.getPhysicsDelta())

-- ---- Stub: lurek.timer.getPhysicsMaxSteps --------------------------------
--@api-stub: lurek.timer.getPhysicsMaxSteps
-- Demonstrates the proper usage of lurek.timer.getPhysicsMaxSteps.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_timer_getPhysicsMaxSteps()
    local max_steps = lurek.timer.getPhysicsMaxSteps()
    print("max physics steps per frame: " .. max_steps)
end
local _ok, _err = pcall(demo_lurek_timer_getPhysicsMaxSteps)

-- ---- Stub: lurek.timer.setPhysicsMaxSteps --------------------------------
--@api-stub: lurek.timer.setPhysicsMaxSteps
-- Demonstrates the proper usage of lurek.timer.setPhysicsMaxSteps.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_timer_setPhysicsMaxSteps()
    lurek.timer.setPhysicsMaxSteps(4)
    print("physics max steps capped at 4")
end
local _ok, _err = pcall(demo_lurek_timer_setPhysicsMaxSteps)

-- ---- Stub: lurek.timer.sleep ---------------------------------------------
--@api-stub: lurek.timer.sleep
-- Artificial delay for tool scripts or splash screens.  Never use in
-- gameplay code (blocks the entire frame loop).
if false then
    -- Guarded: would block the engine
    lurek.timer.sleep(1.5)
end
print("lurek.timer.sleep(1.5) would pause for 1.5 seconds")

-- ---- Stub: lurek.timer.setSmoothingFactor --------------------------------
--@api-stub: lurek.timer.setSmoothingFactor
-- Demonstrates the proper usage of lurek.timer.setSmoothingFactor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_timer_setSmoothingFactor()
    lurek.timer.setSmoothingFactor(0.9)
    print("delta smoothing factor set to 0.9 (high smoothing)")
end
local _ok, _err = pcall(demo_lurek_timer_setSmoothingFactor)

-- ---- Stub: lurek.timer.getSmoothedDelta ----------------------------------
--@api-stub: lurek.timer.getSmoothedDelta
-- Demonstrates the proper usage of lurek.timer.getSmoothedDelta.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_timer_getSmoothedDelta()
    local smooth_dt = lurek.timer.getSmoothedDelta()
    print(string.format("smoothed delta: %.4f sec", smooth_dt))
end
local _ok, _err = pcall(demo_lurek_timer_getSmoothedDelta)

-- =============================================================================
-- Scheduler — game-logic timers: cooldowns, delayed spawns, repeating effects
-- =============================================================================

-- ---- Stub: lurek.timer.newScheduler --------------------------------------
--@api-stub: lurek.timer.newScheduler
-- Demonstrates the proper usage of lurek.timer.newScheduler.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_timer_newScheduler()
    local sched = lurek.timer.newScheduler()
    print("scheduler created: " .. tostring(sched))
end
local _ok, _err = pcall(demo_lurek_timer_newScheduler)

-- ---- Stub: Scheduler:after -----------------------------------------------
--@api-stub: Scheduler:after
-- Schedule a bullet despawn 3 seconds after firing.  The callback removes
-- the bullet from the world.
local despawn_id = sched:after(3.0, function()
    print("  [timer] bullet despawned after 3 seconds")
end)
print("despawn timer id: " .. tostring(despawn_id))

-- Schedule a repeating damage-over-time tick every 0.5 seconds, 6 times total.
local dot_id = sched:after(0.5, function()
    print("  [timer] poison tick: -5 HP")
end, 6)   -- repeat count
print("poison DOT timer id: " .. tostring(dot_id))

-- ---- Stub: Scheduler:cancel ----------------------------------------------
--@api-stub: Scheduler:cancel
-- Demonstrates the proper usage of Scheduler:cancel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Scheduler_cancel()
    local cancelled = sched:cancel(despawn_id)
    print("despawn timer cancelled: " .. tostring(cancelled))
end
local _ok, _err = pcall(demo_Scheduler_cancel)

-- ---- Stub: Scheduler:cancelNamed -----------------------------------------
--@api-stub: Scheduler:cancelNamed
-- Cancel a named timer by tag.  Named timers are easier to manage than
-- tracking integer IDs when many systems use the scheduler.
sched:after(5.0, function() print("shield expires") end):setName("shield_buff")
sched:cancelNamed("shield_buff")
print("shield_buff timer cancelled by name")

-- ---- Stub: Scheduler:cancelAll -------------------------------------------
--@api-stub: Scheduler:cancelAll
-- Demonstrates the proper usage of Scheduler:cancelAll.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Scheduler_cancelAll()
    sched:cancelAll()
    print("all timers cancelled for level transition")
end
local _ok, _err = pcall(demo_Scheduler_cancelAll)

-- ---- Stub: Scheduler:update ----------------------------------------------
--@api-stub: Scheduler:update
-- Advance all active timers by the frame delta.  Call this once per frame
-- in lurek.process().  Expired timers fire their callbacks.
sched:after(0.1, function() print("  [timer] quick ping!") end)
sched:update(0.05)   -- half the delay
print("updated by 0.05 sec -- timer not yet expired")
sched:update(0.06)   -- past the 0.1 threshold
print("updated by 0.06 sec -- timer should have fired")

-- ---- Stub: Scheduler:getCount --------------------------------------------
--@api-stub: Scheduler:getCount
-- Demonstrates the proper usage of Scheduler:getCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Scheduler_getCount()
    local active = sched:getCount()
    print("active timers: " .. active)
end
local _ok, _err = pcall(demo_Scheduler_getCount)

-- ---- Stub: Scheduler:isEmpty ---------------------------------------------
--@api-stub: Scheduler:isEmpty
-- Demonstrates the proper usage of Scheduler:isEmpty.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Scheduler_isEmpty()
    if sched:isEmpty() then
    print("scheduler is empty -- skipping update")
    else
    print("scheduler has " .. sched:getCount() .. " active timers")
end
local _ok, _err = pcall(demo_Scheduler_isEmpty)

-- ---- Stub: Scheduler:pause -----------------------------------------------
--@api-stub: Scheduler:pause
-- Demonstrates the proper usage of Scheduler:pause.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Scheduler_pause()
    sched:after(2.0, function() print("ability ready") end)
    sched:pause()
    print("all timers paused")
end
local _ok, _err = pcall(demo_Scheduler_pause)

-- ---- Stub: Scheduler:isPaused --------------------------------------------
--@api-stub: Scheduler:isPaused
-- Demonstrates the proper usage of Scheduler:isPaused.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Scheduler_isPaused()
    local is_paused = sched:isPaused()
    print("scheduler paused: " .. tostring(is_paused))
end
local _ok, _err = pcall(demo_Scheduler_isPaused)

-- ---- Stub: Scheduler:resume ----------------------------------------------
--@api-stub: Scheduler:resume
-- Demonstrates the proper usage of Scheduler:resume.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Scheduler_resume()
    sched:resume()
    print("timers resumed -- cooldowns continue ticking")
end
local _ok, _err = pcall(demo_Scheduler_resume)

-- ---- Stub: Scheduler:pauseNamed ------------------------------------------
--@api-stub: Scheduler:pauseNamed
-- Pause only the "shield_buff" timer while keeping combat timers running.
-- Useful for time-stop abilities that freeze buffs but not attack cooldowns.
sched:after(10.0, function() end):setName("shield_buff_2")
sched:pauseNamed("shield_buff_2")
print("shield_buff_2 paused independently")

-- ---- Stub: Scheduler:resumeNamed -----------------------------------------
--@api-stub: Scheduler:resumeNamed
-- Demonstrates the proper usage of Scheduler:resumeNamed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Scheduler_resumeNamed()
    sched:resumeNamed("shield_buff_2")
    print("shield_buff_2 resumed")
end
local _ok, _err = pcall(demo_Scheduler_resumeNamed)

-- ---- Stub: Scheduler:isPausedNamed ---------------------------------------
--@api-stub: Scheduler:isPausedNamed
-- Demonstrates the proper usage of Scheduler:isPausedNamed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Scheduler_isPausedNamed()
    local buff_paused = sched:isPausedNamed("shield_buff_2")
    print("shield_buff_2 paused: " .. tostring(buff_paused))
end
local _ok, _err = pcall(demo_Scheduler_isPausedNamed)

-- ---- Stub: Scheduler:getRemaining ----------------------------------------
--@api-stub: Scheduler:getRemaining
-- Display the remaining seconds on a cooldown bar.  Create a fresh timer
-- to query its remaining time.
local cd_id = sched:after(5.0, function() print("fireball ready!") end)
local remaining = sched:getRemaining(cd_id)
print(string.format("fireball cooldown: %.1f sec remaining", remaining or 0))

-- ---- Stub: Scheduler:getInterval -----------------------------------------
--@api-stub: Scheduler:getInterval
-- Show the original interval of a repeating timer for UI tooltip display
-- (e.g. "ticks every 0.5 sec").
local tick_id = sched:after(0.5, function() end, 10)
local interval = sched:getInterval(tick_id)
print("DOT tick interval: " .. tostring(interval) .. " sec")

-- ---- Stub: Scheduler:getRepeatCount --------------------------------------
--@api-stub: Scheduler:getRepeatCount
-- Demonstrates the proper usage of Scheduler:getRepeatCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Scheduler_getRepeatCount()
    local repeats = sched:getRepeatCount(tick_id)
    print("DOT remaining ticks: " .. tostring(repeats))
end
local _ok, _err = pcall(demo_Scheduler_getRepeatCount)

-- ---- Stub: Scheduler:setInterval -----------------------------------------
--@api-stub: Scheduler:setInterval
-- Demonstrates the proper usage of Scheduler:setInterval.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Scheduler_setInterval()
    sched:setInterval(tick_id, 0.25)
    print("DOT tick rate doubled: 0.25 sec interval")
end
local _ok, _err = pcall(demo_Scheduler_setInterval)

-- ---- Stub: Scheduler:resetEvent ------------------------------------------
--@api-stub: Scheduler:resetEvent
-- Demonstrates the proper usage of Scheduler:resetEvent.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Scheduler_resetEvent()
    sched:resetEvent(cd_id)
    print("fireball cooldown reset -- timer restarted from full duration")
end
local _ok, _err = pcall(demo_Scheduler_resetEvent)

-- ---- Stub: Scheduler:setTimeScale ----------------------------------------
--@api-stub: Scheduler:setTimeScale
-- Demonstrates the proper usage of Scheduler:setTimeScale.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Scheduler_setTimeScale()
    sched:setTimeScale(0.5)
    print("scheduler time scale: 0.5x (bullet time)")
end
local _ok, _err = pcall(demo_Scheduler_setTimeScale)

-- ---- Stub: Scheduler:getTimeScale ----------------------------------------
--@api-stub: Scheduler:getTimeScale
-- Read the time scale to adjust UI animations proportionally.
local scale = sched:getTimeScale()
print("current time scale: " .. scale .. "x")

-- Reset to normal
sched:setTimeScale(1.0)


-- =============================================================================
-- Chaining, real-time timers, and coroutine-style waits
-- =============================================================================

-- ---- Stub: lurek.timer.chain ---------------------------------------------
--@api-stub: lurek.timer.chain
-- Chain timed events for a cutscene: fade in -> show text -> fade out.
-- Each step starts after the previous one finishes.
lurek.timer.chain({
    { delay = 0.5, fn = function() print("  [chain] fade in complete") end },
    { delay = 2.0, fn = function() print("  [chain] dialog text shown for 2 sec") end },
    { delay = 0.5, fn = function() print("  [chain] fade out complete") end },
})
print("cutscene chain queued: 3 steps")

-- ---- Stub: lurek.timer.afterReal -----------------------------------------
--@api-stub: lurek.timer.afterReal
-- Schedule a real-time callback that fires even when the game is paused.
-- Use for UI animations in the pause menu.
lurek.timer.afterReal(1.0, function()
    print("  [real-time] 1 second of wall-clock time passed")
end)
print("real-time timer set for 1.0 sec")

-- ---- Stub: lurek.timer.tickRealTimers ------------------------------------
--@api-stub: lurek.timer.tickRealTimers
-- Demonstrates the proper usage of lurek.timer.tickRealTimers.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_timer_tickRealTimers()
    lurek.timer.tickRealTimers(0.5)
    print("real-time timers advanced by 0.5 sec")
end
local _ok, _err = pcall(demo_lurek_timer_tickRealTimers)

-- ---- Stub: lurek.timer.waitSeconds ---------------------------------------
--@api-stub: lurek.timer.waitSeconds
-- Coroutine-style wait in a sequential script.  The caller yields for
-- the specified duration, then resumes.
local wait_handle = lurek.timer.waitSeconds(2.0)
print("wait handle: " .. tostring(wait_handle))
print("  -> in a coroutine, execution resumes after 2 seconds")

-- ---- Stub: lurek.timer.waitFrames ----------------------------------------
--@api-stub: lurek.timer.waitFrames
-- Demonstrates the proper usage of lurek.timer.waitFrames.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_timer_waitFrames()
    local frame_wait = lurek.timer.waitFrames(10)
    print("waiting for 10 frames: " .. tostring(frame_wait))
end
local _ok, _err = pcall(demo_lurek_timer_waitFrames)

-- ---- Stub: lurek.timer.tickWaits -----------------------------------------
--@api-stub: lurek.timer.tickWaits
-- Demonstrates the proper usage of lurek.timer.tickWaits.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_timer_tickWaits()
    lurek.timer.tickWaits(0.016)
    print("waits ticked by 0.016 sec")
end
local _ok, _err = pcall(demo_lurek_timer_tickWaits)

-- ---- Stub: lurek.timer.delay ----------------------------------------------
--@api-stub: lurek.timer.delay
-- Coroutine-based yield-for-duration sugar.  Call from within a coroutine to
-- pause execution for a given number of seconds without blocking the main loop.
-- Requires lurek.timer.tickWaits() to be called each frame.
--
-- Example: cutscene scripted with sequential delays in a single coroutine.
local cutscene = coroutine.create(function()
    print("[cutscene] Part 1: fade in")
    lurek.timer.delay(1.0)        -- yield until 1 second passes
    print("[cutscene] Part 2: show dialog")
    lurek.timer.delay(3.0)
    print("[cutscene] Part 3: fade out")
end)
-- The game loop would call coroutine.resume(cutscene) once, then
-- lurek.timer.tickWaits() each frame to resume it at the right moment.
-- Here we just start it to show the API:
coroutine.resume(cutscene)
print("delay: cutscene coroutine started and waiting for tick advances")

-- =============================================================================
-- New in 0.15.0: Frame-count Based Scheduler Events
-- =============================================================================

-- Create a scheduler and use afterFrames to trigger a one-shot callback.
local sched = lurek.timer.newScheduler()

sched:afterFrames(3, function()
  print("fired: afterFrames(3)")
end)

-- everyFrames with a count limit.
sched:everyFrames(2, function()
  print("everyFrames(2) fired")
end, 4)  -- fires at most 4 times

-- Simulate 6 game ticks.
for i = 1, 6 do
  local fired_count = sched:updateFrames()
  print(string.format("tick %d: %d event(s) fired", i, fired_count))
end
