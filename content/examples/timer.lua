-- content/examples/timer.lua
-- Demonstrates every lurek.timer function and LScheduler method with realistic game usage.
-- Run: cargo run -- content/examples/timer.lua
--@api-stub: lurek.timer.getDelta
-- Returns delta time in seconds since the last frame; essential for frame-rate independent movement.
do
  local player_x = 100
  local speed = 200 -- pixels per second

  function lurek.process()
    -- Multiply speed by dt so the player moves the same distance regardless of FPS
    local dt = lurek.timer.getDelta()
    player_x = player_x + speed * dt
  end
end
--@api-stub: lurek.timer.getFPS
-- Returns the current frames-per-second count for performance monitoring overlays.
do
  function lurek.draw_ui()
    local fps = lurek.timer.getFPS()
    -- Show a warning in the HUD when performance drops below acceptable threshold
    if fps < 30 then
      lurek.log.warn("performance drop: " .. fps .. " FPS", "perf")
    end
  end
end
--@api-stub: lurek.timer.getTime
-- Returns total elapsed game time in seconds since engine start; useful for continuous animations.
do
  function lurek.draw()
    -- Create a pulsing opacity effect using sine of elapsed time
    local t = lurek.timer.getTime()
    local alpha = 0.5 + 0.5 * math.sin(t * 3.0)
    lurek.log.debug(string.format("glow alpha=%.2f", alpha), "fx")
  end
end
--@api-stub: lurek.timer.getAverageDelta
-- Returns smoothed average delta time over a recent frame window; more stable than getDelta for adaptive logic.
do
  function lurek.process()
    local avg_dt = lurek.timer.getAverageDelta()
    local budget_ms = avg_dt * 1000
    -- Use average frame time to decide whether to enable expensive effects
    if budget_ms > 18 then
      lurek.log.warn(string.format("frame budget tight: %.1fms", budget_ms), "perf")
    end
  end
end
--@api-stub: lurek.timer.getFrameCount
-- Returns total frames rendered since engine start; useful for frame-based triggers.
do
  function lurek.process()
    local frame = lurek.timer.getFrameCount()
    -- Log a heartbeat every 300 frames (roughly every 5 seconds at 60 FPS)
    if frame % 300 == 0 then
      lurek.log.info("heartbeat at frame " .. frame, "engine")
    end
  end
end
--@api-stub: lurek.timer.step
-- Manually advances the internal clock by one tick; called by the engine loop. Rarely needed in game scripts.
do
  -- Useful for deterministic replay systems where you control time advancement
  local dt = lurek.timer.step()
  lurek.log.debug(string.format("manual step: dt=%.4fs", dt), "replay")
end
--@api-stub: lurek.timer.getMicroTime
-- Returns high-resolution time in seconds since engine start; ideal for micro-benchmarks.
do
  -- Measure how long a pathfinding computation takes
  local t0 = lurek.timer.getMicroTime()
  local sum = 0
  for i = 1, 50000 do sum = sum + i end
  local elapsed = lurek.timer.getMicroTime() - t0
  lurek.log.info(string.format("computation took %.3fms", elapsed * 1000), "bench")
end
--@api-stub: lurek.timer.getPhysicsDelta
-- Returns the fixed timestep in seconds used for physics simulation (default 1/60).
do
  local pdt = lurek.timer.getPhysicsDelta()
  local hz = math.floor(1.0 / pdt + 0.5)
  -- Display the physics tick rate for debugging physics behavior
  lurek.log.info("physics running at " .. hz .. " Hz (dt=" .. pdt .. "s)", "physics")
end
--@api-stub: lurek.timer.setPhysicsDelta
-- Sets the fixed timestep for physics; lower values = more accuracy, more CPU cost. Clamped [1/240, 1/10].
do
  -- Double physics precision for a boss fight with tight collision requirements
  lurek.timer.setPhysicsDelta(1 / 120)
  local pdt = lurek.timer.getPhysicsDelta()
  lurek.log.info("physics precision mode: " .. math.floor(1 / pdt + 0.5) .. " Hz", "physics")
end
--@api-stub: lurek.timer.getPhysicsMaxSteps
-- Returns max physics steps per frame; prevents spiral-of-death when the game lags.
do
  local max_steps = lurek.timer.getPhysicsMaxSteps()
  -- Warn if the cap is too low for a physics-heavy game
  if max_steps < 4 then
    lurek.log.warn("low physics step cap (" .. max_steps .. "); may skip collisions on lag spikes", "physics")
  end
end
--@api-stub: lurek.timer.setPhysicsMaxSteps
-- Sets the max physics steps per frame. Higher = more accurate under lag, but costs more CPU. Clamped [1, 64].
do
  -- Allow more catch-up steps for a fast-paced bullet-hell game
  lurek.timer.setPhysicsMaxSteps(8)
  lurek.log.info("physics catch-up cap set to 8 steps/frame", "physics")
end
--@api-stub: lurek.timer.sleep
-- Blocks the entire game loop for the given seconds. Use only for loading screens or sync waits.
do
  -- Simulate a brief pause during a loading transition
  lurek.log.info("loading assets...", "loader")
  local before = lurek.timer.getMicroTime()
  lurek.timer.sleep(0.05)
  local elapsed = lurek.timer.getMicroTime() - before
  lurek.log.info(string.format("blocked for %.1fms", elapsed * 1000), "loader")
end
--@api-stub: lurek.timer.newScheduler
-- Creates a new independent scheduler with its own event list and time scale.
do
  -- Separate schedulers let you pause UI timers without affecting gameplay
  local ui_timers = lurek.timer.newScheduler()
  local game_timers = lurek.timer.newScheduler()

  ui_timers:after(2.0, function() lurek.log.info("hide tooltip", "ui") end)
  game_timers:every(1.0, function() lurek.log.debug("enemy patrol step", "ai") end)

  function lurek.process(dt)
    ui_timers:update(dt)
    game_timers:update(dt)
  end
end
--@api-stub: lurek.timer.chain
-- Creates a scheduler pre-loaded with a sequence of accumulated delays; ideal for cutscenes.
do
  -- Chain steps for a simple cutscene: each delay is relative to the previous step
  local cutscene = lurek.timer.chain({
    { delay = 0.0, func = function() lurek.log.info("fade from black", "cutscene") end },
    { delay = 1.5, func = function() lurek.log.info("show dialog box", "cutscene") end },
    { delay = 3.0, func = function() lurek.log.info("camera pan to exit", "cutscene") end },
    { delay = 1.0, func = function() lurek.log.info("give player control", "cutscene") end },
  })

  function lurek.process(dt) cutscene:update(dt) end
end
--@api-stub: lurek.timer.afterReal
-- Schedules a one-shot callback on wall-clock time, unaffected by game pause or time scale.
do
  -- Show a "session played" notification after 3 real seconds regardless of game speed
  lurek.timer.afterReal(3.0, function()
    lurek.log.info("you have been playing for a while!", "ui")
  end)

  function lurek.process() lurek.timer.tickRealTimers() end
end
--@api-stub: lurek.timer.tickRealTimers
-- Fires all real-time timers whose deadline has passed; call once per frame after afterReal scheduling.
do
  -- Register a toast notification that auto-hides after 0.5 real seconds
  lurek.timer.afterReal(0.5, function() lurek.log.debug("toast dismissed", "ui") end)

  function lurek.process()
    local fired = lurek.timer.tickRealTimers()
    if fired > 0 then
      lurek.log.debug("real-time callbacks fired: " .. fired, "timer")
    end
  end
end
--@api-stub: lurek.timer.setSmoothingFactor
-- Sets the exponential smoothing factor for getSmoothedDelta. Lower = smoother but more lag. Clamped [0.01, 1.0].
do
  -- Use a low factor for a very stable frame time display
  lurek.timer.setSmoothingFactor(0.05)
  lurek.log.info("smoothing factor set to 0.05 for stable HUD timer", "perf")
end
--@api-stub: lurek.timer.getSmoothedDelta
-- Returns exponentially smoothed delta time; reduces jitter for UI frame time displays.
do
  function lurek.draw_ui()
    local sdt = lurek.timer.getSmoothedDelta()
    -- Display smooth frame time in the debug HUD without flicker
    local ms = sdt * 1000
    lurek.log.debug(string.format("frame: %.2fms", ms), "hud")
  end
end
--@api-stub: lurek.timer.waitSeconds
-- Yields the current coroutine for real-time seconds; must call tickWaits each frame to resume.
do
  -- Use coroutine-based sequencing for a multi-phase intro
  local intro = coroutine.wrap(function()
    lurek.log.info("wave 1: spawn enemies", "game")
    lurek.timer.waitSeconds(2.0)
    lurek.log.info("wave 2: spawn boss", "game")
    lurek.timer.waitSeconds(3.0)
    lurek.log.info("wave complete", "game")
  end)

  function lurek.init() intro() end
  function lurek.process() lurek.timer.tickWaits() end
end
--@api-stub: lurek.timer.waitFrames
-- Yields the current coroutine for N frames; must call tickWaits each frame to resume.
do
  -- Wait exactly 120 frames (2 seconds at 60 FPS) before enabling player input
  local setup = coroutine.wrap(function()
    lurek.log.debug("waiting 120 frames for intro to finish", "game")
    lurek.timer.waitFrames(120)
    lurek.log.info("player input enabled", "game")
  end)

  function lurek.init() setup() end
  function lurek.process() lurek.timer.tickWaits() end
end
--@api-stub: lurek.timer.tickWaits
-- Resumes all waitSeconds/waitFrames coroutines whose deadline has passed; call once per frame.
do
  function lurek.process()
    local resumed = lurek.timer.tickWaits()
    if resumed > 0 then
      lurek.log.debug("resumed " .. resumed .. " waiting coroutines", "timer")
    end
  end
end
--@api-stub: LScheduler:after
-- Schedules a one-shot callback after a delay in seconds; returns an event ID for management.
do
  local sched = lurek.timer.newScheduler()
  -- Spawn a power-up 3 seconds into the level
  local id = sched:after(3.0, function()
    lurek.log.info("power-up spawned at center", "game")
  end)
  lurek.log.debug("power-up timer id=" .. id, "timer")

  function lurek.process(dt) sched:update(dt) end
end
--@api-stub: LScheduler:afterFrames
-- Schedules a one-shot callback after N frames; useful for frame-exact gameplay events.
do
  local sched = lurek.timer.newScheduler()
  -- Flash the screen white exactly 15 frames after an explosion
  sched:afterFrames(15, function()
    lurek.log.info("screen flash complete", "fx")
  end)

  function lurek.process() sched:updateFrames() end
end
--@api-stub: LScheduler:afterNamed
-- Schedules a named one-shot; replaces any existing timer with the same name (debounce pattern).
do
  local sched = lurek.timer.newScheduler()
  -- Each hit resets the combo timeout; only fires when player stops attacking
  sched:afterNamed("combo_timeout", 1.5, function()
    lurek.log.info("combo dropped", "combat")
  end)
  -- Simulate another hit resetting the timer
  sched:afterNamed("combo_timeout", 1.5, function()
    lurek.log.info("combo dropped (reset)", "combat")
  end)

  function lurek.process(dt) sched:update(dt) end
end
--@api-stub: LScheduler:cancel
-- Cancels a scheduled event by ID; returns true if found and removed.
do
  local sched = lurek.timer.newScheduler()
  -- Schedule a self-destruct, then defuse it
  local bomb_id = sched:after(5.0, function()
    lurek.log.info("BOOM!", "game")
  end)
  local defused = sched:cancel(bomb_id)
  lurek.log.info("bomb defused: " .. tostring(defused), "game")
end
--@api-stub: LScheduler:cancelNamed
-- Cancels a named event; returns true if found and removed.
do
  local sched = lurek.timer.newScheduler()
  sched:afterNamed("invulnerability", 5.0, function()
    lurek.log.info("invuln expired", "combat")
  end)
  -- Player picked up another star; cancel old timer before scheduling new one
  local ok = sched:cancelNamed("invulnerability")
  lurek.log.debug("old invuln cancelled: " .. tostring(ok), "combat")
end
--@api-stub: LScheduler:cancelAll
-- Removes all events from the scheduler; use on scene transitions to clean up.
do
  local sched = lurek.timer.newScheduler()
  sched:after(1.0, function() end)
  sched:every(0.5, function() end)
  sched:after(3.0, function() end)
  -- Scene is ending; drop everything at once
  local removed = sched:cancelAll()
  lurek.log.info("scene exit: cleared " .. removed .. " timers", "scene")
end
--@api-stub: LScheduler:every
-- Schedules a repeating callback at a fixed interval; pass count to limit repetitions.
do
  local sched = lurek.timer.newScheduler()
  -- Spawn a coin every 2 seconds, up to 10 times
  local id = sched:every(2.0, function()
    lurek.log.info("coin spawned", "game")
  end, 10)
  lurek.log.debug("coin spawner id=" .. id, "game")

  function lurek.process(dt) sched:update(dt) end
end
--@api-stub: LScheduler:everyFrames
-- Schedules a repeating callback every N frames; useful for fixed-rate visual effects.
do
  local sched = lurek.timer.newScheduler()
  -- Emit a trail particle every 4 frames while the missile is alive
  sched:everyFrames(4, function()
    lurek.log.debug("trail particle emitted", "fx")
  end)

  function lurek.process() sched:updateFrames() end
end
--@api-stub: LScheduler:everyNamed
-- Schedules a named repeating callback; replaces any existing timer with that name.
do
  local sched = lurek.timer.newScheduler()
  -- Health regen ticks every 2 seconds; upgrading resets to faster rate
  sched:everyNamed("hp_regen", 2.0, function()
    lurek.log.debug("+5 HP", "rpg")
  end)
  -- After upgrade, replace with faster regen
  sched:everyNamed("hp_regen", 1.0, function()
    lurek.log.debug("+5 HP (upgraded)", "rpg")
  end)

  function lurek.process(dt) sched:update(dt) end
end
--@api-stub: LScheduler:pause
-- Pauses a scheduled event by ID; it stops accumulating time until resumed.
do
  local sched = lurek.timer.newScheduler()
  local patrol_id = sched:every(1.0, function()
    lurek.log.debug("guard patrol step", "ai")
  end)
  -- Pause the patrol when the player enters a dialog
  sched:pause(patrol_id)
  lurek.log.info("guard patrol paused during dialog", "ai")
end
--@api-stub: LScheduler:resume
-- Resumes a previously paused event so it continues counting down.
do
  local sched = lurek.timer.newScheduler()
  local id = sched:every(0.5, function()
    lurek.log.debug("heartbeat", "fx")
  end)
  sched:pause(id)
  -- Dialog ended; resume the effect
  local ok = sched:resume(id)
  lurek.log.info("heartbeat resumed: " .. tostring(ok), "fx")
end
--@api-stub: LScheduler:isPaused
-- Checks whether an event is currently paused; useful for toggle buttons.
do
  local sched = lurek.timer.newScheduler()
  local id = sched:every(2.0, function() end)
  sched:pause(id)
  -- Toggle logic: only show "paused" icon if timer is actually paused
  if sched:isPaused(id) then
    lurek.log.debug("showing pause indicator for timer " .. id, "ui")
  end
end
--@api-stub: LScheduler:pauseNamed
-- Pauses a named event; convenient when you don't track IDs.
do
  local sched = lurek.timer.newScheduler()
  sched:everyNamed("auto_save", 30.0, function()
    lurek.log.info("auto-saving...", "save")
  end)
  -- Pause auto-save during a boss fight to avoid hitches
  sched:pauseNamed("auto_save")
  lurek.log.info("auto-save paused for boss fight", "save")
end
--@api-stub: LScheduler:resumeNamed
-- Resumes a named event that was previously paused.
do
  local sched = lurek.timer.newScheduler()
  sched:everyNamed("auto_save", 30.0, function() end)
  sched:pauseNamed("auto_save")
  -- Boss fight over; resume auto-save
  local ok = sched:resumeNamed("auto_save")
  lurek.log.info("auto-save resumed: " .. tostring(ok), "save")
end
--@api-stub: LScheduler:isPausedNamed
-- Checks if a named event is paused; use for UI state display.
do
  local sched = lurek.timer.newScheduler()
  sched:everyNamed("music_fade", 5.0, function() end)
  sched:pauseNamed("music_fade")
  if sched:isPausedNamed("music_fade") then
    lurek.log.debug("music fade is on hold", "audio")
  end
end
--@api-stub: LScheduler:getRemaining
-- Returns remaining time before an event fires; useful for cooldown displays.
do
  local sched = lurek.timer.newScheduler()
  local id = sched:after(5.0, function()
    lurek.log.info("ability ready!", "combat")
  end)
  -- Query how much time remains on the cooldown
  local found, remaining = sched:getRemaining(id)
  if found then
    lurek.log.info(string.format("cooldown: %.1fs remaining", remaining), "hud")
  end
end
--@api-stub: LScheduler:getInterval
-- Returns the interval duration of a repeating event; useful for displaying tick rate.
do
  local sched = lurek.timer.newScheduler()
  local id = sched:every(2.5, function() end)
  local found, interval = sched:getInterval(id)
  if found then
    lurek.log.debug(string.format("spawn interval: %.1fs", interval), "game")
  end
end
--@api-stub: LScheduler:getRepeatCount
-- Returns remaining repeat count for a limited-repetition event; -1 means infinite.
do
  local sched = lurek.timer.newScheduler()
  -- Fire 5 shots with a 0.3s delay between each
  local id = sched:every(0.3, function()
    lurek.log.debug("shot fired", "combat")
  end, 5)
  local found, charges = sched:getRepeatCount(id)
  if found then
    lurek.log.info("burst shots remaining: " .. charges, "combat")
  end
end
--@api-stub: LScheduler:getCount
-- Returns total number of active events; useful for diagnostics.
do
  local sched = lurek.timer.newScheduler()
  sched:after(1.0, function() end)
  sched:every(0.5, function() end)
  sched:after(3.0, function() end)
  local n = sched:getCount()
  lurek.log.debug("active scheduled events: " .. n, "timer")
end
--@api-stub: LScheduler:isEmpty
-- Returns true when no events are scheduled; useful to skip update calls.
do
  local sched = lurek.timer.newScheduler()

  function lurek.process(dt)
    -- Only call update when there is work to do
    if not sched:isEmpty() then
      sched:update(dt)
    end
  end
end
--@api-stub: LScheduler:setInterval
-- Changes the interval of an existing repeating event; useful for dynamic difficulty.
do
  local sched = lurek.timer.newScheduler()
  local spawn_id = sched:every(3.0, function()
    lurek.log.debug("enemy spawned", "ai")
  end)
  -- As the game progresses, increase spawn rate
  sched:setInterval(spawn_id, 1.0)
  lurek.log.info("spawn rate increased: now every 1.0s", "difficulty")
end
--@api-stub: LScheduler:resetEvent
-- Resets an event's elapsed time to zero, restarting its countdown.
do
  local sched = lurek.timer.newScheduler()
  -- A buff expires in 10 seconds; picking up another refreshes the timer
  local buff_id = sched:after(10.0, function()
    lurek.log.info("shield buff expired", "rpg")
  end)
  -- Player picked up another shield orb: refresh the timer
  sched:resetEvent(buff_id)
  lurek.log.info("shield buff refreshed to full duration", "rpg")
end
--@api-stub: LScheduler:setTimeScale
-- Sets the time scale for this scheduler; 2.0 = double speed, 0.5 = half speed.
do
  local enemies = lurek.timer.newScheduler()
  enemies:every(1.0, function()
    lurek.log.debug("enemy action tick", "ai")
  end)
  -- Slow-motion effect: enemies run at quarter speed
  enemies:setTimeScale(0.25)
  lurek.log.info("slow-motion activated: enemy time scale = 0.25", "fx")

  function lurek.process(dt) enemies:update(dt) end
end
--@api-stub: LScheduler:getTimeScale
-- Returns the current time scale multiplier for this scheduler.
do
  local sched = lurek.timer.newScheduler()
  sched:setTimeScale(2.0)
  local scale = sched:getTimeScale()
  lurek.log.info("scheduler running at " .. scale .. "x speed", "debug")
end
--@api-stub: LScheduler:update
-- Advances all time-based events by dt seconds, fires ready callbacks, cleans up one-shots.
do
  local sched = lurek.timer.newScheduler()
  sched:after(0.5, function() lurek.log.info("delayed event fired", "game") end)
  sched:every(1.0, function() lurek.log.debug("periodic tick", "game") end)

  function lurek.process(dt)
    -- Call once per frame with the frame's delta time
    local fired = sched:update(dt)
    if fired > 0 then
      lurek.log.debug("callbacks fired this frame: " .. fired, "timer")
    end
  end
end
--@api-stub: LScheduler:updateFrames
-- Advances all frame-based events by one frame; call once per frame for frame-count timers.
do
  local sched = lurek.timer.newScheduler()
  sched:everyFrames(15, function()
    lurek.log.debug("quarter-second visual tick", "fx")
  end)
  sched:afterFrames(60, function()
    lurek.log.info("one-second mark reached", "game")
  end)

  function lurek.process()
    -- Separate from update(dt); handles frame-counted events
    sched:updateFrames()
  end
end
--@api-stub: LScheduler:type
-- Returns the type name string "LScheduler" for this object.
do
  local sched = lurek.timer.newScheduler()
  -- Useful for generic serialization or debug logging of object types
  lurek.log.debug("object type: " .. sched:type(), "debug")
end
--@api-stub: LScheduler:typeOf
-- Checks if this object matches a given type name; accepts "LScheduler" or "Object".
do
  local sched = lurek.timer.newScheduler()
  -- Runtime type checking for polymorphic systems
  if sched:typeOf("LScheduler") then
    lurek.log.debug("confirmed: this is a scheduler", "debug")
  end
end
print("content/examples/timer.lua")
