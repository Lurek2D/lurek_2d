-- content/examples/automation.lua
-- Auto-generated from content/examples2/automation_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/automation.lua

--- Automation Examples: Script loading, playback control, macros, conditions

--@api-stub: lurek.automation.load
-- Loads an automation script by name with step data.
do
    local steps = {
        { action = "click", x = 100, y = 200 },
        { action = "wait", duration = 0.5 },
        { action = "click", x = 300, y = 100 },
    }
    lurek.automation.load("login_flow", steps)
    print("loaded = " .. tostring(lurek.automation.hasScript("login_flow")))
end

--@api-stub: lurek.automation.unload
-- Unloads a previously loaded automation script.
do
    local steps = { { action = "click", x = 50, y = 50 } }
    lurek.automation.load("temp_script", steps)
    lurek.automation.unload("temp_script")
    print("unloaded = " .. tostring(not lurek.automation.hasScript("temp_script")))
end

--@api-stub: lurek.automation.hasScript
-- Checks if a named script is currently loaded.
do
    local has = lurek.automation.hasScript("nonexistent")
    print("has nonexistent = " .. tostring(has))
end

--@api-stub: lurek.automation.getScripts
-- Returns a list of all loaded script names.
do
    local scripts = lurek.automation.getScripts()
    print("loaded scripts = " .. #scripts)
end

--@api-stub: lurek.automation.start
-- Starts executing a loaded automation script.
do
    local steps = { { action = "wait", duration = 1.0 } }
    lurek.automation.load("run_test", steps)
    lurek.automation.start("run_test")
    print("running = " .. tostring(lurek.automation.isRunning()))
end

--@api-stub: lurek.automation.stop
-- Stops the currently running automation script.
do
    lurek.automation.stop()
    print("stopped = " .. tostring(not lurek.automation.isRunning()))
end

--@api-stub: lurek.automation.pause
-- Pauses the running automation script.
do
    lurek.automation.pause()
    print("paused = " .. tostring(lurek.automation.isPaused()))
end

--@api-stub: lurek.automation.resume
-- Resumes a paused automation script.
do
    lurek.automation.resume()
    print("resumed")
end

--@api-stub: lurek.automation.update
-- Advances automation execution by a time delta.
do
    lurek.automation.update(0.016)
    print("updated by 16ms")
end

--@api-stub: lurek.automation.isRunning
-- Returns true if an automation script is currently executing.
do
    local running = lurek.automation.isRunning()
    print("isRunning = " .. tostring(running))
end

--@api-stub: lurek.automation.isPaused
-- Returns true if the automation is paused.
do
    local paused = lurek.automation.isPaused()
    print("isPaused = " .. tostring(paused))
end

--@api-stub: lurek.automation.isComplete
-- Returns true if the script finished all steps successfully.
do
    local done = lurek.automation.isComplete()
    print("isComplete = " .. tostring(done))
end

--@api-stub: lurek.automation.isFailed
-- Returns true if the script encountered a failure.
do
    local failed = lurek.automation.isFailed()
    print("isFailed = " .. tostring(failed))
end

--@api-stub: lurek.automation.getLastError
-- Returns the last error message or empty string if none.
do
    local err = lurek.automation.getLastError()
    print("last error = " .. (err or ""))
end

--@api-stub: lurek.automation.setCondition
-- Sets a named boolean condition for script branching.
do
    lurek.automation.setCondition("logged_in", true)
    print("condition set")
end

--@api-stub: lurek.automation.getCondition
-- Returns the value of a named condition.
do
    lurek.automation.setCondition("ready", true)
    local val = lurek.automation.getCondition("ready")
    print("ready = " .. tostring(val))
end

--@api-stub: lurek.automation.getCurrentStep
-- Returns the index of the currently executing step.
do
    local step = lurek.automation.getCurrentStep()
    print("current step = " .. step)
end

--@api-stub: lurek.automation.getStepCount
-- Returns the total number of steps in the running script.
do
    local count = lurek.automation.getStepCount()
    print("step count = " .. count)
end

--@api-stub: lurek.automation.getCurrentScript
-- Returns the name of the currently running script.
do
    local name = lurek.automation.getCurrentScript()
    print("current script = " .. name)
end

--@api-stub: lurek.automation.getElapsedTime
-- Returns elapsed time since the script started.
do
    local t = lurek.automation.getElapsedTime()
    print("elapsed = " .. t .. "s")
end

--@api-stub: lurek.automation.loadFromToml
-- Loads a script from a TOML-formatted string.
do
    local toml = "[steps]\naction = \"click\"\nx = 200\ny = 150\n"
    lurek.automation.loadFromToml("toml_script", toml)
    print("loaded from TOML = " .. tostring(lurek.automation.hasScript("toml_script")))
end

--@api-stub: lurek.automation.getStepLimit
-- Returns the maximum step count before forced stop.
do
    local limit = lurek.automation.getStepLimit("run_test")
    print("step limit = " .. limit)
end

--@api-stub: lurek.automation.setStepLimit
-- Sets a maximum step count to prevent infinite loops.
do
    lurek.automation.setStepLimit("run_test", 1000)
    print("step limit set to 1000")
end

--@api-stub: lurek.automation.saveMacro
-- Records a running script as a replayable macro.
do
    lurek.automation.saveMacro("fast_login", "login_flow")
    print("macro saved")
end

--@api-stub: lurek.automation.playMacro
-- Replays a previously saved macro.
do
    lurek.automation.playMacro("fast_login")
    print("macro playing")
end

--@api-stub: lurek.automation.hasMacro
-- Checks if a named macro exists.
do
    local has = lurek.automation.hasMacro("fast_login")
    print("has macro = " .. tostring(has))
end

--@api-stub: lurek.automation.listMacros
-- Returns a list of all saved macro names.
do
    local macros = lurek.automation.listMacros()
    print("macros = " .. #macros)
end

--@api-stub: lurek.automation.setPlaybackSpeed
-- Sets the playback speed multiplier for automation.
do
    lurek.automation.setPlaybackSpeed(2.0)
    print("speed = " .. lurek.automation.getPlaybackSpeed())
end

--@api-stub: lurek.automation.getPlaybackSpeed
-- Returns the current playback speed multiplier.
do
    local speed = lurek.automation.getPlaybackSpeed()
    print("playback speed = " .. speed)
end

--@api-stub: lurek.automation.setHighlightMode
-- Enables or disables visual highlighting of automated actions.
do
    lurek.automation.setHighlightMode(true)
    print("highlight = " .. tostring(lurek.automation.isHighlightMode()))
end

--@api-stub: lurek.automation.isHighlightMode
-- Returns true if highlight mode is enabled.
do
    local hl = lurek.automation.isHighlightMode()
    print("highlight mode = " .. tostring(hl))
end

--@api-stub: lurek.automation.waitUntil
-- Registers a predicate that must become true before continuing.
do
    lurek.automation.waitUntil(function()
        return lurek.automation.getCondition("ready")
    end, 5.0)
    print("waitUntil registered with 5s timeout")
end

print("content/examples/automation.lua")
