-- content/examples/automation.lua
-- love2d-style usage snippets for the lurek.automation API (28 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/automation.lua

-- ── lurek.automation.* functions ──

--@api-stub: lurek.automation.load
-- Loads a named script from a Lua data table containing a steps array.
-- May block — call from a worker thread for large payloads.
local result = lurek.automation.load("main", { x = 0, y = 0 })
-- may block; consider lurek.thread for large payloads
print("load:", result)
print("ok")

--@api-stub: lurek.automation.unload
-- Removes a loaded script by name, returning true if it existed.
-- See the module spec for detailed semantics.
local result = lurek.automation.unload("main")
print("unload:", result)
return result

--@api-stub: lurek.automation.hasScript
-- Returns true if a script with the given name is registered.
-- Use as a guard inside lurek.update or event handlers.
if lurek.automation.hasScript("main") then
  print("hasScript -> true")
end

--@api-stub: lurek.automation.getScripts
-- Returns an array of all registered script names.
-- Cheap to call; safe inside callbacks.
local value = lurek.automation.getScripts()
print("getScripts:", value)
return value

--@api-stub: lurek.automation.start
-- Starts playback of the named script from the beginning.
-- Trigger from input, timers, or game events.
-- trigger from input or timer
lurek.automation.start("main")
print("start fired")
print("ok")

--@api-stub: lurek.automation.stop
-- Stops playback and resets the simulator to idle.
-- Trigger from input, timers, or game events.
-- trigger from input or timer
lurek.automation.stop()
print("stop fired")
print("ok")

--@api-stub: lurek.automation.pause
-- Pauses playback at the current step position.
-- Trigger from input, timers, or game events.
-- trigger from input or timer
lurek.automation.pause()
print("pause fired")
print("ok")

--@api-stub: lurek.automation.resume
-- Resumes playback from a paused position.
-- Trigger from input, timers, or game events.
-- trigger from input or timer
lurek.automation.resume()
print("resume fired")
print("ok")

--@api-stub: lurek.automation.update
-- Advances the playback clock by `dt` seconds, dispatching due steps.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.automation.update(dt)
print("update applied")
print("ok")

--@api-stub: lurek.automation.isRunning
-- Returns true if the simulator is actively playing a script.
-- Use as a guard inside lurek.update or event handlers.
if lurek.automation.isRunning() then
  print("isRunning -> true")
end

--@api-stub: lurek.automation.isPaused
-- Returns true if playback is currently paused.
-- Use as a guard inside lurek.update or event handlers.
if lurek.automation.isPaused() then
  print("isPaused -> true")
end

--@api-stub: lurek.automation.isComplete
-- Returns true if all steps in the active script have been dispatched.
-- Use as a guard inside lurek.update or event handlers.
if lurek.automation.isComplete() then
  print("isComplete -> true")
end

--@api-stub: lurek.automation.getCurrentStep
-- Returns the index of the next step to be dispatched.
-- Cheap to call; safe inside callbacks.
local value = lurek.automation.getCurrentStep()
print("getCurrentStep:", value)
return value

--@api-stub: lurek.automation.getStepCount
-- Returns the total number of steps in the active script.
-- Cheap to call; safe inside callbacks.
local value = lurek.automation.getStepCount()
print("getStepCount:", value)
return value

--@api-stub: lurek.automation.getCurrentScript
-- Returns the name of the active script, or nil if idle.
-- Cheap to call; safe inside callbacks.
local value = lurek.automation.getCurrentScript()
print("getCurrentScript:", value)
return value

--@api-stub: lurek.automation.getElapsedTime
-- Returns seconds elapsed since playback started.
-- Cheap to call; safe inside callbacks.
local value = lurek.automation.getElapsedTime()
print("getElapsedTime:", value)
return value

--@api-stub: lurek.automation.loadFromToml
-- Parses a TOML string and registers it as a named script.
-- May block — call from a worker thread for large payloads.
local result = lurek.automation.loadFromToml("main", "hello")
-- may block; consider lurek.thread for large payloads
print("loadFromToml:", result)
print("ok")

--@api-stub: lurek.automation.getStepLimit
-- Returns the step limit for the named script, or nil if not found.
-- Cheap to call; safe inside callbacks.
local value = lurek.automation.getStepLimit("main")
print("getStepLimit:", value)
return value

--@api-stub: lurek.automation.setStepLimit
-- Sets the step limit for the named script (clamped to 1..MAX_STEPS).
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.automation.setStepLimit("main", 10)
print("setStepLimit applied")
print("ok")

--@api-stub: lurek.automation.saveMacro
-- Saves a currently-loaded script under a macro name for fast replay.
-- May block — call from a worker thread for large payloads.
local result = lurek.automation.saveMacro("main", "main")
-- may block; consider lurek.thread for large payloads
print("saveMacro:", result)
print("ok")

--@api-stub: lurek.automation.playMacro
-- Loads and starts playback of a previously saved macro.
-- Trigger from input, timers, or game events.
-- trigger from input or timer
lurek.automation.playMacro("main")
print("playMacro fired")
print("ok")

--@api-stub: lurek.automation.hasMacro
-- Returns true if a macro with the given name has been saved.
-- Use as a guard inside lurek.update or event handlers.
if lurek.automation.hasMacro("main") then
  print("hasMacro -> true")
end

--@api-stub: lurek.automation.listMacros
-- Returns an array of all saved macro names.
-- See the module spec for detailed semantics.
local result = lurek.automation.listMacros()
print("listMacros:", result)
return result

--@api-stub: lurek.automation.setPlaybackSpeed
-- Sets the dt multiplier for script playback (0.5 = half speed, 2.0 = double).
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.automation.setPlaybackSpeed(1.0)
print("setPlaybackSpeed applied")
print("ok")

--@api-stub: lurek.automation.getPlaybackSpeed
-- Returns the current playback speed multiplier (default 1.0).
-- Cheap to call; safe inside callbacks.
local value = lurek.automation.getPlaybackSpeed()
print("getPlaybackSpeed:", value)
return value

--@api-stub: lurek.automation.setHighlightMode
-- Enables or disables the highlight overlay hint.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.automation.setHighlightMode(enable)
print("setHighlightMode applied")
print("ok")

--@api-stub: lurek.automation.isHighlightMode
-- Returns whether the highlight overlay hint is active.
-- Use as a guard inside lurek.update or event handlers.
if lurek.automation.isHighlightMode() then
  print("isHighlightMode -> true")
end

--@api-stub: lurek.automation.waitUntil
-- Pauses playback advancement until predicate() returns true or timeout seconds elapse.
-- See the module spec for detailed semantics.
local result = lurek.automation.waitUntil(predicate, timeout)
print("waitUntil:", result)
return result

