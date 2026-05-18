-- content/examples/automation.lua
-- Demonstrates the lurek.automation module for scripted input playback, macros, and test automation.
-- Run: cargo run -- content/examples/automation.lua
--@api-stub: lurek.automation.getCondition
-- Reads a named boolean condition that automation steps can use in when/assert expressions.
do
  -- Conditions are shared with automation scripts, so a game can expose state
  -- without giving the script direct access to gameplay tables.
  lurek.automation.setCondition("boss_defeated", true)
  lurek.automation.setCondition("exit_unlocked", false)

  local boss_done = lurek.automation.getCondition("boss_defeated") == true
  local exit_ready = lurek.automation.getCondition("exit_unlocked") == true
  local route = boss_done and exit_ready and "leave_arena" or "keep_testing"

  lurek.log.info("automation route: " .. route, "automation")
end
--@api-stub: lurek.automation.getCurrentScript
-- Returns the active script name, or nil when no script is playing.
do
  -- The active name is useful for debug HUDs and for checking that a test
  -- harness started the route it intended to run.
  lurek.automation.load("current_script_demo", {
    meta = { description = "short script used to show current script lookup" },
    steps = {
      { time = 0.0, action = "wait" },
      { time = 0.1, action = "keypress", key = "space" },
      { time = 0.2, action = "keyrelease", key = "space" },
    },
  })
  lurek.automation.start("current_script_demo")

  local active = lurek.automation.getCurrentScript()
  if active then
    lurek.log.debug("playing automation script: " .. active, "automation")
  end

  lurek.automation.stop()
end
--@api-stub: lurek.automation.getCurrentStep
-- Reports the index of the next step that playback will evaluate.
do
  -- getCurrentStep tracks the next pending step. It starts at 0, then moves
  -- forward as update(dt) dispatches timed input events.
  lurek.automation.load("step_cursor_demo", {
    steps = {
      { time = 0.0, action = "keypress", key = "right" },
      { time = 0.2, action = "keyrelease", key = "right" },
      { time = 0.3, action = "keypress", key = "space" },
    },
  })
  lurek.automation.start("step_cursor_demo")
  lurek.automation.update(0.05)

  local next_step = lurek.automation.getCurrentStep()
  lurek.log.debug("next automation step index: " .. next_step, "automation")

  lurek.automation.stop()
end
--@api-stub: lurek.automation.getElapsedTime
-- Returns scaled playback time for the current script in seconds.
do
  -- Elapsed time is affected by setPlaybackSpeed. At 2x speed, an update of
  -- 0.25 seconds advances automation by roughly 0.5 seconds.
  lurek.automation.load("elapsed_time_demo", {
    steps = {
      { time = 0.0, action = "wait" },
      { time = 1.0, action = "keypress", key = "return" },
    },
  })
  lurek.automation.setPlaybackSpeed(2.0)
  lurek.automation.start("elapsed_time_demo")
  lurek.automation.update(0.25)

  local elapsed = lurek.automation.getElapsedTime()
  lurek.log.info(string.format("automation elapsed: %.2fs", elapsed), "automation")

  lurek.automation.stop()
  lurek.automation.setPlaybackSpeed(1.0)
end
--@api-stub: lurek.automation.getLastError
-- Returns the most recent automation failure message when an assert or macro step fails.
do
  -- An assert action uses the same condition expression syntax as when:
  -- names, true/false, !, &&, ||, and parentheses.
  lurek.automation.setCondition("door_open", false)
  lurek.automation.load("last_error_demo", {
    steps = {
      { time = 0.0, action = "assert", assert = "door_open" },
      { time = 0.1, action = "keypress", key = "up" },
    },
  })
  lurek.automation.start("last_error_demo")
  lurek.automation.update(0.1)

  local message = lurek.automation.getLastError()
  if message then
    lurek.log.warn("automation stopped with: " .. message, "automation")
  end

  lurek.automation.stop()
end
--@api-stub: lurek.automation.getPlaybackSpeed
-- Reads the current automation playback speed multiplier.
do
  -- A debug overlay can show the multiplier so timing-sensitive scripts are
  -- not mistaken for real-time input playback.
  lurek.automation.setPlaybackSpeed(0.5)
  local speed = lurek.automation.getPlaybackSpeed()

  if speed ~= 1.0 then
    lurek.log.info(string.format("automation running at %.1fx speed", speed), "automation")
  end

  lurek.automation.setPlaybackSpeed(1.0)
end
--@api-stub: lurek.automation.getScripts
-- Returns the names of all currently loaded automation scripts.
do
  -- The returned array is useful for a debug console command such as
  -- "automation list". Sort it when you want deterministic display order.
  lurek.automation.load("inventory_open_demo", {
    steps = { { time = 0.0, action = "keypress", key = "i" } },
  })
  lurek.automation.load("inventory_close_demo", {
    steps = { { time = 0.0, action = "keyrelease", key = "i" } },
  })

  local scripts = lurek.automation.getScripts()
  table.sort(scripts)
  lurek.log.debug("loaded scripts: " .. table.concat(scripts, ", "), "automation")
end
--@api-stub: lurek.automation.getStepCount
-- Returns how many steps are in the active script.
do
  -- Step count is only reported for the active script. Use it with
  -- getCurrentStep to build a simple progress indicator.
  lurek.automation.load("step_count_demo", {
    steps = {
      { time = 0.0, action = "keypress", key = "right" },
      { time = 0.4, action = "keyrelease", key = "right" },
      { time = 0.5, action = "keypress", key = "space" },
      { time = 0.6, action = "keyrelease", key = "space" },
    },
  })
  lurek.automation.start("step_count_demo")

  local total = lurek.automation.getStepCount()
  lurek.log.info("step_count_demo contains " .. total .. " steps", "automation")

  lurek.automation.stop()
end
--@api-stub: lurek.automation.getStepLimit
-- Returns the configured maximum number of retained steps for a loaded script.
do
  -- Scripts default to the engine limit, but setStepLimit can lower the cap
  -- for CI runs or generated scripts that should never grow without bound.
  lurek.automation.load("limit_lookup_demo", {
    steps = {
      { time = 0.0, action = "keypress", key = "a" },
      { time = 0.1, action = "keyrelease", key = "a" },
    },
  })
  lurek.automation.setStepLimit("limit_lookup_demo", 8)

  local limit = lurek.automation.getStepLimit("limit_lookup_demo")
  if limit then
    lurek.log.debug("limit_lookup_demo step limit: " .. limit, "automation")
  end
end
--@api-stub: lurek.automation.hasMacro
-- Checks whether a named macro has been saved.
do
  -- Use hasMacro before playMacro so a missing optional macro does not turn
  -- into a runtime error during a test run.
  lurek.automation.load("confirm_button_source", {
    steps = {
      { time = 0.0, action = "keypress", key = "return" },
      { time = 0.1, action = "keyrelease", key = "return" },
    },
  })
  lurek.automation.saveMacro("confirm_button", "confirm_button_source")

  if lurek.automation.hasMacro("confirm_button") then
    lurek.log.info("confirm_button macro is ready", "automation")
  end
end
--@api-stub: lurek.automation.hasScript
-- Checks whether a script is already loaded under a given name.
do
  -- Loading a script with the same name replaces the old one. Guard with
  -- hasScript when a setup routine may run more than once.
  if not lurek.automation.hasScript("menu_skip_guarded") then
    lurek.automation.load("menu_skip_guarded", {
      meta = { description = "skip title and open the first save slot" },
      steps = {
        { time = 0.0, action = "keypress", key = "return" },
        { time = 0.1, action = "keyrelease", key = "return" },
        { time = 0.4, action = "keypress", key = "return" },
        { time = 0.5, action = "keyrelease", key = "return" },
      },
    })
  end
end
--@api-stub: lurek.automation.isComplete
-- Reports whether the active script has dispatched all of its steps.
do
  -- A completed script remains complete until stop() resets playback state.
  -- This is useful for chaining routes in a longer test scenario.
  lurek.automation.load("complete_demo", {
    steps = {
      { time = 0.0, action = "wait" },
    },
  })
  lurek.automation.start("complete_demo")
  lurek.automation.update(0.01)

  if lurek.automation.isComplete() then
    lurek.log.info("complete_demo finished", "automation")
  end

  lurek.automation.stop()
end
--@api-stub: lurek.automation.isFailed
-- Reports whether playback is halted because an assert, macro, or visual check failed.
do
  -- Failed state is separate from complete state, so test harnesses can tell
  -- the difference between a finished route and a broken route.
  lurek.automation.setCondition("player_alive", false)
  lurek.automation.load("failure_state_demo", {
    steps = {
      { time = 0.0, action = "assert", assert = "player_alive" },
    },
  })
  lurek.automation.start("failure_state_demo")
  lurek.automation.update(0.05)

  if lurek.automation.isFailed() then
    lurek.log.error("automation route failed before completion", "automation")
  end

  lurek.automation.stop()
end
--@api-stub: lurek.automation.isHighlightMode
-- Reads whether visual highlighting of automated input is enabled.
do
  -- Highlight mode is just a stored flag. Rendering code can read it and draw
  -- its own overlay around the UI element currently being exercised.
  lurek.automation.setHighlightMode(true)

  if lurek.automation.isHighlightMode() then
    lurek.log.debug("automation highlight overlay enabled", "automation")
  end

  lurek.automation.setHighlightMode(false)
end
--@api-stub: lurek.automation.isPaused
-- Reports whether playback is currently paused.
do
  -- Paused playback keeps the active script and current step, but update(dt)
  -- will not advance until resume() is called.
  lurek.automation.load("paused_state_demo", {
    steps = {
      { time = 0.0, action = "keypress", key = "right" },
      { time = 1.0, action = "keyrelease", key = "right" },
    },
  })
  lurek.automation.start("paused_state_demo")
  lurek.automation.pause()

  if lurek.automation.isPaused() then
    lurek.log.info("automation paused while modal menu is open", "automation")
  end

  lurek.automation.stop()
end
--@api-stub: lurek.automation.isRunning
-- Reports whether a script is actively advancing through update(dt).
do
  -- isRunning returns false while paused, complete, failed, or idle.
  lurek.automation.load("running_state_demo", {
    steps = {
      { time = 0.2, action = "keypress", key = "d" },
      { time = 0.4, action = "keyrelease", key = "d" },
    },
  })
  lurek.automation.start("running_state_demo")

  if lurek.automation.isRunning() then
    lurek.log.debug("running_state_demo is active", "automation")
  end

  lurek.automation.stop()
end
--@api-stub: lurek.automation.listMacros
-- Returns the names of all saved automation macros.
do
  -- Macros are reusable script copies. A QA overlay can list them so testers
  -- know which short input sequences are available for replay.
  lurek.automation.load("macro_confirm_source", {
    steps = {
      { time = 0.0, action = "keypress", key = "return" },
      { time = 0.08, action = "keyrelease", key = "return" },
    },
  })
  lurek.automation.load("macro_cancel_source", {
    steps = {
      { time = 0.0, action = "keypress", key = "escape" },
      { time = 0.08, action = "keyrelease", key = "escape" },
    },
  })
  lurek.automation.saveMacro("confirm", "macro_confirm_source")
  lurek.automation.saveMacro("cancel", "macro_cancel_source")

  local macros = lurek.automation.listMacros()
  table.sort(macros)
  lurek.log.info("registered macros: " .. table.concat(macros, ", "), "automation")
end
--@api-stub: lurek.automation.load
-- Loads a Lua-table script containing timed steps and optional metadata.
do
  -- A script is a table with optional meta.description and a steps array.
  -- Valid action strings include keypress, keyrelease, mousemove, mousepress,
  -- mouserelease, mousewheel, textinput, wait, callmacro, assert, and visualassert.
  -- The when field skips a step unless its condition expression is true.
  local checkout_route = {
    meta = { description = "open inventory, choose item, and confirm use" },
    steps = {
      { time = 0.00, action = "keypress", key = "i", scancode = "i" },
      { time = 0.08, action = "keyrelease", key = "i", scancode = "i" },
      { time = 0.20, action = "mousemove", x = 320, y = 180, dx = 320, dy = 180 },
      { time = 0.25, action = "mousepress", x = 320, y = 180, button = 1, clicks = 1 },
      { time = 0.32, action = "mouserelease", x = 320, y = 180, button = 1 },
      { time = 0.45, action = "textinput", text = "potion" },
      { time = 0.70, action = "keypress", key = "return", when = "inventory_open" },
      { time = 0.78, action = "keyrelease", key = "return", when = "inventory_open" },
      { time = 1.00, action = "wait" },
    },
  }

  lurek.automation.load("checkout_route", checkout_route)
  lurek.automation.setCondition("inventory_open", true)
end
--@api-stub: lurek.automation.loadFromToml
-- Loads a script from TOML text using the same step fields as load().
do
  -- TOML is convenient for external automation files checked into a project.
  -- Use decimal time values so the TOML parser reads them as floats.
  local toml_text = [=[
[meta]
description = "press jump, then dash when the route is clear"

[[steps]]
time = 0.0
action = "keypress"
key = "space"

[[steps]]
time = 0.1
action = "keyrelease"
key = "space"

[[steps]]
time = 0.2
action = "keypress"
key = "lshift"
when = "route_clear && !dialog_open"

[[steps]]
time = 0.3
action = "keyrelease"
key = "lshift"
when = "route_clear && !dialog_open"
]=]

  lurek.automation.loadFromToml("jump_dash_route", toml_text)
  lurek.automation.setCondition("route_clear", true)
  lurek.automation.setCondition("dialog_open", false)
end
--@api-stub: lurek.automation.pause
-- Pauses playback without clearing the active script or progress.
do
  -- Pause when a modal menu, loading screen, or manual inspection tool opens.
  -- The same script can later continue from its current step with resume().
  lurek.automation.load("pause_demo", {
    steps = {
      { time = 0.0, action = "keypress", key = "right" },
      { time = 2.0, action = "keyrelease", key = "right" },
    },
  })
  lurek.automation.start("pause_demo")
  lurek.automation.update(0.25)
  lurek.automation.pause()

  lurek.log.debug("pause_demo paused at step " .. lurek.automation.getCurrentStep(), "automation")

  lurek.automation.stop()
end
--@api-stub: lurek.automation.playMacro
-- Starts playback of a previously saved macro.
do
  -- A macro is saved by name, but playback runs the script copy stored inside
  -- the macro. Use hasMacro first when the macro is optional.
  lurek.automation.load("macro_play_source", {
    steps = {
      { time = 0.0, action = "keypress", key = "return" },
      { time = 0.1, action = "keyrelease", key = "return" },
    },
  })
  lurek.automation.saveMacro("play_confirm", "macro_play_source")

  if lurek.automation.hasMacro("play_confirm") then
    lurek.automation.playMacro("play_confirm")
    lurek.automation.update(0.2)
    lurek.automation.stop()
  end
end
--@api-stub: lurek.automation.resume
-- Resumes a paused script from its current progress point.
do
  -- resume() is a no-op unless the simulator is paused. This makes it safe
  -- to call when closing a menu that may or may not have paused automation.
  lurek.automation.load("resume_demo", {
    steps = {
      { time = 0.0, action = "keypress", key = "right" },
      { time = 0.5, action = "keyrelease", key = "right" },
    },
  })
  lurek.automation.start("resume_demo")
  lurek.automation.pause()
  lurek.automation.resume()

  if lurek.automation.isRunning() then
    lurek.log.info("resume_demo continued after pause", "automation")
  end

  lurek.automation.stop()
end
--@api-stub: lurek.automation.saveMacro
-- Stores a loaded script as a reusable named macro.
do
  -- saveMacro copies an existing loaded script. The original script can be
  -- unloaded later without removing the saved macro.
  lurek.automation.load("save_macro_source", {
    meta = { description = "confirm the currently focused dialog" },
    steps = {
      { time = 0.00, action = "keypress", key = "return" },
      { time = 0.08, action = "keyrelease", key = "return" },
    },
  })
  lurek.automation.saveMacro("dialog_confirm", "save_macro_source")
  lurek.automation.unload("save_macro_source")

  if lurek.automation.hasMacro("dialog_confirm") then
    lurek.log.debug("dialog_confirm macro saved", "automation")
  end
end
--@api-stub: lurek.automation.setCondition
-- Sets a named boolean condition used by when/assert expressions.
do
  -- Conditions support simple boolean expressions. Unknown names evaluate to
  -- false, so set every condition your route depends on before playback.
  local player_ready = true
  local dialog_open = false
  lurek.automation.setCondition("player_ready", player_ready)
  lurek.automation.setCondition("dialog_open", dialog_open)

  lurek.automation.load("conditioned_route", {
    steps = {
      { time = 0.0, action = "keypress", key = "space", when = "player_ready && !dialog_open" },
      { time = 0.1, action = "keyrelease", key = "space", when = "player_ready && !dialog_open" },
    },
  })
end
--@api-stub: lurek.automation.setHighlightMode
-- Enables or disables the automation highlight flag for debug visuals.
do
  -- The engine stores the flag; your render code decides how to visualize it.
  -- Turn it on for manual debugging and off for normal CI playback.
  local manual_debug_session = true
  lurek.automation.setHighlightMode(manual_debug_session)

  if manual_debug_session then
    lurek.log.info("input highlight mode enabled for automation", "automation")
  end

  lurek.automation.setHighlightMode(false)
end
--@api-stub: lurek.automation.setPlaybackSpeed
-- Sets a multiplier applied to dt during automation update().
do
  -- Values above 1.0 make scripts complete faster; values between 0 and 1
  -- slow them down for visual debugging. Negative values are clamped to 0.
  lurek.automation.load("speed_demo", {
    steps = {
      { time = 0.0, action = "keypress", key = "d" },
      { time = 1.0, action = "keyrelease", key = "d" },
    },
  })
  lurek.automation.setPlaybackSpeed(3.0)
  lurek.automation.start("speed_demo")
  lurek.automation.update(0.2)

  lurek.log.debug("speed_demo elapsed: " .. lurek.automation.getElapsedTime(), "automation")

  lurek.automation.stop()
  lurek.automation.setPlaybackSpeed(1.0)
end
--@api-stub: lurek.automation.setStepLimit
-- Sets the maximum number of retained steps for a loaded script.
do
  -- Repeat expansion happens when a script is loaded. Lowering the step limit
  -- truncates the loaded script so generated routes cannot run too long.
  lurek.automation.load("limited_repeats", {
    steps = {
      { time = 0.0, action = "keypress", key = "right", ["repeat"] = 10, repeatInterval = 0.1 },
      { time = 1.2, action = "keyrelease", key = "right" },
    },
  })

  local changed = lurek.automation.setStepLimit("limited_repeats", 4)
  if changed then
    lurek.automation.start("limited_repeats")
    lurek.log.info("limited_repeats retained " .. lurek.automation.getStepCount() .. " steps", "automation")
    lurek.automation.stop()
  end
end
--@api-stub: lurek.automation.start
-- Starts playback of a loaded automation script from the beginning.
do
  -- start() resets elapsed time and current step for the named script. It
  -- raises an error if the script has not been loaded.
  lurek.automation.load("start_route", {
    meta = { description = "move right and jump once" },
    steps = {
      { time = 0.0, action = "keypress", key = "d" },
      { time = 0.4, action = "keyrelease", key = "d" },
      { time = 0.5, action = "keypress", key = "space" },
      { time = 0.6, action = "keyrelease", key = "space" },
    },
  })

  lurek.automation.start("start_route")
  lurek.log.info("start_route started", "automation")
  lurek.automation.stop()
end
--@api-stub: lurek.automation.stop
-- Stops playback and clears the active script state.
do
  -- stop() is safe to call from a cancel key, a failed assertion handler, or
  -- the end of a scenario. It returns the simulator to idle.
  lurek.automation.load("stop_demo", {
    steps = {
      { time = 0.0, action = "keypress", key = "left" },
      { time = 3.0, action = "keyrelease", key = "left" },
    },
  })
  lurek.automation.start("stop_demo")
  lurek.automation.update(0.2)
  lurek.automation.stop()

  if not lurek.automation.isRunning() then
    lurek.log.debug("stop_demo returned automation to idle", "automation")
  end
end
--@api-stub: lurek.automation.unload
-- Removes a loaded script by name and stops it first if it is active.
do
  -- Use unload for temporary scripts generated by a level, tutorial, or test
  -- case so the registry does not keep stale routes around.
  lurek.automation.load("temporary_route", {
    steps = {
      { time = 0.0, action = "keypress", key = "tab" },
      { time = 0.1, action = "keyrelease", key = "tab" },
    },
  })
  lurek.automation.start("temporary_route")

  local removed = lurek.automation.unload("temporary_route")
  if removed then
    lurek.log.info("temporary_route unloaded", "automation")
  end
end
--@api-stub: lurek.automation.update
-- Advances playback by dt seconds and dispatches due input events.
do
  -- Call update(dt) once per frame from lurek.process(dt). The simulator
  -- compares scaled elapsed time with each step's time and queues input events.
  lurek.automation.load("update_loop_demo", {
    steps = {
      { time = 0.0, action = "keypress", key = "right" },
      { time = 0.4, action = "keyrelease", key = "right" },
      { time = 0.5, action = "keypress", key = "space" },
      { time = 0.6, action = "keyrelease", key = "space" },
    },
  })
  lurek.automation.start("update_loop_demo")

  function lurek.process(dt)
    lurek.automation.update(dt)
    if lurek.automation.isComplete() or lurek.automation.isFailed() then
      lurek.automation.stop()
    end
  end
end
--@api-stub: lurek.automation.waitUntil
-- Suspends automation updates until a predicate returns true or the timeout elapses.
do
  -- waitUntil is useful around loading screens. While the predicate is false,
  -- update(dt) returns early and no script steps are dispatched.
  local level_ready = false
  lurek.automation.load("wait_until_demo", {
    steps = {
      { time = 0.0, action = "keypress", key = "return" },
      { time = 0.1, action = "keyrelease", key = "return" },
    },
  })
  lurek.automation.start("wait_until_demo")
  lurek.automation.waitUntil(function()
    return level_ready
  end, 5.0)

  level_ready = true
  lurek.automation.update(0.1)
  lurek.automation.stop()
end
print("content/examples/automation.lua")