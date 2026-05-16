-- content/examples/automation.lua
-- lurek.automation API examples.
-- Run: cargo run -- content/examples/automation.lua

--@api-stub: lurek.automation.load -- Loads an automation script from a Lua table of steps and optional metadata
do -- lurek.automation.load
  local intro = {
    meta = { description = "intro cutscene skip" },
    steps = {
      { time = 0.0, action = "keypress",   key = "space" },
      { time = 0.5, action = "keyrelease", key = "space" },
    },
  }
  lurek.automation.load("intro_skip", intro)
end

--@api-stub: lurek.automation.unload -- Unloads a named automation script
do -- lurek.automation.unload
  lurek.automation.load("boot_autoplay", { steps = { { time = 0, action = "wait" } } })
  if lurek.automation.unload("boot_autoplay") then
    lurek.log.info("boot_autoplay script removed", "automation")
  end
end

--@api-stub: lurek.automation.hasScript -- Returns whether a script is loaded
do -- lurek.automation.hasScript
  if not lurek.automation.hasScript("attract_loop") then
    lurek.automation.load("attract_loop", {
      steps = { { time = 1.0, action = "keypress", key = "return" } },
    })
  end
end

--@api-stub: lurek.automation.getScripts -- Returns the names of loaded automation scripts
do -- lurek.automation.getScripts
  lurek.automation.load("a", { steps = { { time = 0, action = "wait" } } })
  lurek.automation.load("b", { steps = { { time = 0, action = "wait" } } })
  for _, name in ipairs(lurek.automation.getScripts()) do
    lurek.log.debug("registered script: " .. name, "automation")
  end
end

--@api-stub: lurek.automation.start -- Starts playback of a loaded automation script
do -- lurek.automation.start
  lurek.automation.load("hop", {
    steps = { { time = 0.2, action = "keypress", key = "space" } },
  })
  function lurek.init() lurek.automation.start("hop") end
end

--@api-stub: lurek.automation.stop -- Stops the current automation script
do -- lurek.automation.stop
  function lurek.init()
    if lurek.automation.isRunning() then
      lurek.automation.stop()
    end
  end
end

--@api-stub: lurek.automation.pause -- Pauses automation playback
do -- lurek.automation.pause
  local menu_open = true
  if menu_open and lurek.automation.isRunning() then
    lurek.automation.pause()
  end
end

--@api-stub: lurek.automation.resume -- Resumes automation playback
do -- lurek.automation.resume
  if lurek.automation.isPaused() then
    lurek.automation.resume()
  end
end

--@api-stub: lurek.automation.update -- Advances automation playback and dispatches generated input events
do -- lurek.automation.update
  function lurek.process(dt)
    lurek.automation.update(dt)
  end
end

--@api-stub: lurek.automation.isRunning -- Returns whether automation playback is running
do -- lurek.automation.isRunning
  function lurek.draw_ui()
    if lurek.automation.isRunning() then
      lurek.render.print("[AUTO] press ESC to skip", 8, 8)
    end
  end
end

--@api-stub: lurek.automation.isPaused -- Returns whether automation playback is paused
do -- lurek.automation.isPaused
  if lurek.automation.isPaused() then
    lurek.log.info("script halted on pause menu", "automation")
  end
end

--@api-stub: lurek.automation.isComplete -- Returns whether the current automation script completed
do -- lurek.automation.isComplete
  function lurek.process(dt)
    lurek.automation.update(dt)
    if lurek.automation.isComplete() then
      lurek.automation.stop()
    end
  end
end

--@api-stub: lurek.automation.getCurrentStep -- Returns the current step index of the active script
do -- lurek.automation.getCurrentStep
  function lurek.draw_ui()
    local i = lurek.automation.getCurrentStep()
    local n = lurek.automation.getStepCount()
    lurek.render.print("step " .. i .. " / " .. n, 8, 24)
  end
end

--@api-stub: lurek.automation.getStepCount -- Returns the number of steps in the active script
do -- lurek.automation.getStepCount
  local total = 0
  function lurek.init()
    lurek.automation.start("intro_skip")
    total = lurek.automation.getStepCount()
    lurek.log.info("playing " .. total .. " steps", "automation")
  end
end

--@api-stub: lurek.automation.getCurrentScript -- Returns the current script name when a script is active
do -- lurek.automation.getCurrentScript
  function lurek.draw_ui()
    local name = lurek.automation.getCurrentScript() or "(idle)"
    lurek.render.print("script: " .. name, 8, 40)
  end
end

--@api-stub: lurek.automation.getElapsedTime -- Returns elapsed playback time for the current script
do -- lurek.automation.getElapsedTime
  function lurek.draw_ui()
    local t = lurek.automation.getElapsedTime()
    lurek.render.print(string.format("t = %.2fs", t), 8, 56)
  end
end

--@api-stub: lurek.automation.loadFromToml -- Loads an automation script from TOML text
do -- lurek.automation.loadFromToml
  local toml = [=[
[meta]
description = "left-right wiggle"
[[steps]]
time = 0.0
action = "keypress"
key = "left"
[[steps]]
time = 0.3
action = "keyrelease"
key = "left"
]=]
  lurek.automation.loadFromToml("wiggle", toml)
end

--@api-stub: lurek.automation.getStepLimit -- Returns the configured step limit for a loaded script
do -- lurek.automation.getStepLimit
  local limit = lurek.automation.getStepLimit("intro_skip")
  if limit then
    lurek.log.debug("intro_skip step limit = " .. limit, "automation")
  end
end

--@api-stub: lurek.automation.setStepLimit -- Sets the maximum step count for a loaded script
do -- lurek.automation.setStepLimit
  if lurek.automation.setStepLimit("wiggle", 64) then
    lurek.log.info("wiggle script limited to 64 steps", "automation")
  end
end

--@api-stub: lurek.automation.saveMacro -- Saves a loaded script as a named macro
do -- lurek.automation.saveMacro
  lurek.automation.load("dismiss_dialog", {
    steps = { { time = 0.05, action = "keypress", key = "return" } },
  })
  lurek.automation.saveMacro("dismiss", "dismiss_dialog")
end

--@api-stub: lurek.automation.playMacro -- Starts playback of a saved macro
do -- lurek.automation.playMacro
  function lurek.init()
    if lurek.automation.hasMacro("dismiss") then
      lurek.automation.playMacro("dismiss")
    end
  end
end

--@api-stub: lurek.automation.hasMacro -- Returns whether a macro is saved
do -- lurek.automation.hasMacro
  if not lurek.automation.hasMacro("dismiss") then
    lurek.log.warn("macro 'dismiss' not registered yet", "automation")
  end
end

--@api-stub: lurek.automation.listMacros -- Returns the names of saved macros
do -- lurek.automation.listMacros
  for _, name in ipairs(lurek.automation.listMacros()) do
    lurek.log.debug("macro available: " .. name, "automation")
  end
end

--@api-stub: lurek.automation.setPlaybackSpeed -- Sets automation playback speed multiplier
do -- lurek.automation.setPlaybackSpeed
  local fast_ci = true
  lurek.automation.setPlaybackSpeed(fast_ci and 4.0 or 1.0)
end

--@api-stub: lurek.automation.getPlaybackSpeed -- Returns automation playback speed multiplier
do -- lurek.automation.getPlaybackSpeed
  local speed = lurek.automation.getPlaybackSpeed()
  if speed ~= 1.0 then
    lurek.log.info("automation running at " .. speed .. "x", "automation")
  end
end

--@api-stub: lurek.automation.setHighlightMode -- Enables or disables automation highlight mode
do -- lurek.automation.setHighlightMode
  local recording = true
  lurek.automation.setHighlightMode(recording)
end

--@api-stub: lurek.automation.isHighlightMode -- Returns whether automation highlight mode is enabled
do -- lurek.automation.isHighlightMode

  function lurek.draw()
    if lurek.automation.isHighlightMode() then
      lurek.render.setColor(1, 1, 0, 0.5)
      lurek.render.circle("line", 320, 240, 24)
    end
  end
end

--@api-stub: lurek.automation.waitUntil -- Suspends automation updates until a predicate returns true or a timeout elapses
do -- lurek.automation.waitUntil
  local level_ready = false
  function lurek.init()
    lurek.automation.waitUntil(function() return level_ready end, 5.0)
  end
end

--@api-stub: lurek.automation.setCondition -- Sets a named boolean condition used by automation steps
do -- lurek.automation.setCondition
  local boss_dead = false
  function lurek.process(dt)
    lurek.automation.setCondition("boss_dead", boss_dead)
  end
end

--@api-stub: lurek.automation.getCondition -- Returns a named automation condition value
do -- lurek.automation.getCondition
  local v = lurek.automation.getCondition("boss_dead")
  lurek.log.debug("boss_dead=" .. tostring(v), "automation")
end

--@api-stub: lurek.automation.isFailed -- Returns whether the current automation script failed
do -- lurek.automation.isFailed
  function lurek.process(dt)
    lurek.automation.update(dt)
    if lurek.automation.isFailed() then
      lurek.log.error("automation failed", "automation")
    end
  end
end

--@api-stub: lurek.automation.getLastError -- Returns the last automation error message when one exists
do -- lurek.automation.getLastError
  local err = lurek.automation.getLastError()
  if err then lurek.log.error(err, "automation") end
end
