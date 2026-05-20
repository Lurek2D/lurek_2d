-- content/examples/automation.lua
-- Auto-generated from content/examples2/automation_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/automation.lua

--- Automation Examples: Script loading, playback control, macros, conditions


--@api-stub: lurek.automation.load
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("login_flow", { steps = steps })
    print("loaded = " .. tostring(lurek.automation.hasScript("login_flow")))
end

--@api-stub: lurek.automation.unload
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("temp_script", { steps = steps })
    lurek.automation.unload("temp_script")
    print("unloaded = " .. tostring(not lurek.automation.hasScript("temp_script")))
end

--@api-stub: lurek.automation.hasScript
do
    local has = lurek.automation.hasScript("nonexistent")
    print("has nonexistent = " .. tostring(has))
end

--@api-stub: lurek.automation.getScripts
do
    local scripts = lurek.automation.getScripts()
    print("loaded scripts = " .. #scripts)
end

--@api-stub: lurek.automation.start
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("run_test", { steps = steps })
    lurek.automation.start("run_test")
    print("running = " .. tostring(lurek.automation.isRunning()))
end

--@api-stub: lurek.automation.stop
do
    lurek.automation.stop()
    print("stopped = " .. tostring(not lurek.automation.isRunning()))
end

--@api-stub: lurek.automation.pause
do
    lurek.automation.pause()
    print("paused = " .. tostring(lurek.automation.isPaused()))
end

--@api-stub: lurek.automation.resume
do
    lurek.automation.resume()
    print("resumed")
end

--@api-stub: lurek.automation.update
do
    lurek.automation.update(0.016)
    print("updated by 16ms")
end

--@api-stub: lurek.automation.isRunning
do
    local running = lurek.automation.isRunning()
    print("isRunning = " .. tostring(running))
end

--@api-stub: lurek.automation.isPaused
do
    local paused = lurek.automation.isPaused()
    print("isPaused = " .. tostring(paused))
end

--@api-stub: lurek.automation.isComplete
do
    local done = lurek.automation.isComplete()
    print("isComplete = " .. tostring(done))
end

--@api-stub: lurek.automation.isFailed
do
    local failed = lurek.automation.isFailed()
    print("isFailed = " .. tostring(failed))
end

--@api-stub: lurek.automation.getLastError
do
    local err = lurek.automation.getLastError()
    print("last error = " .. (err or ""))
end

--@api-stub: lurek.automation.setCondition
do
    lurek.automation.setCondition("logged_in", true)
    print("condition set")
end

--@api-stub: lurek.automation.getCondition
do
    lurek.automation.setCondition("ready", true)
    local val = lurek.automation.getCondition("ready")
    print("ready = " .. tostring(val))
end

--@api-stub: lurek.automation.getCurrentStep
do
    local step = lurek.automation.getCurrentStep()
    print("current step = " .. tostring(step))
end

--@api-stub: lurek.automation.getStepCount
do
    local count = lurek.automation.getStepCount()
    print("step count = " .. tostring(count))
end

--@api-stub: lurek.automation.getCurrentScript
do
    local name = lurek.automation.getCurrentScript()
    print("current script = " .. tostring(name))
end

--@api-stub: lurek.automation.getElapsedTime
do
    local t = lurek.automation.getElapsedTime()
    print("elapsed = " .. tostring(t) .. "s")
end

--@api-stub: lurek.automation.loadFromToml
do
    local toml = "[[steps]]\naction = \"wait\"\ntime = 0.0\n"
    lurek.automation.loadFromToml("toml_script", toml)
    print("loaded from TOML = " .. tostring(lurek.automation.hasScript("toml_script")))
end

--@api-stub: lurek.automation.getStepLimit
do
    local limit = lurek.automation.getStepLimit("run_test")
    print("step limit = " .. limit)
end

--@api-stub: lurek.automation.setStepLimit
do
    lurek.automation.setStepLimit("run_test", 1000)
    print("step limit set to 1000")
end

--@api-stub: lurek.automation.saveMacro
do
    lurek.automation.saveMacro("fast_login", "login_flow")
    print("macro saved")
end

--@api-stub: lurek.automation.playMacro
do
    lurek.automation.playMacro("fast_login")
    print("macro playing")
end

--@api-stub: lurek.automation.hasMacro
do
    local has = lurek.automation.hasMacro("fast_login")
    print("has macro = " .. tostring(has))
end

--@api-stub: lurek.automation.listMacros
do
    local macros = lurek.automation.listMacros()
    print("macros = " .. #macros)
end

--@api-stub: lurek.automation.setPlaybackSpeed
do
    lurek.automation.setPlaybackSpeed(2.0)
    print("speed = " .. lurek.automation.getPlaybackSpeed())
end

--@api-stub: lurek.automation.getPlaybackSpeed
do
    local speed = lurek.automation.getPlaybackSpeed()
    print("playback speed = " .. speed)
end

--@api-stub: lurek.automation.setHighlightMode
do
    lurek.automation.setHighlightMode(true)
    print("highlight = " .. tostring(lurek.automation.isHighlightMode()))
end

--@api-stub: lurek.automation.isHighlightMode
do
    local hl = lurek.automation.isHighlightMode()
    print("highlight mode = " .. tostring(hl))
end

--@api-stub: lurek.automation.waitUntil
do
    lurek.automation.waitUntil(function()
        return lurek.automation.getCondition("ready")
    end, 5.0)
    print("waitUntil registered with 5s timeout")
end

print("content/examples/automation.lua")
