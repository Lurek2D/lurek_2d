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
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("status_check", { steps = steps })
    local has = lurek.automation.hasScript("nonexistent")
    local loaded = lurek.automation.hasScript("status_check")
    print("has nonexistent = " .. tostring(has))
    print("has status_check = " .. tostring(loaded))
end

--@api-stub: lurek.automation.getScripts
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("list_one", { steps = steps })
    lurek.automation.load("list_two", { steps = steps })
    local scripts = lurek.automation.getScripts()
    print("loaded scripts = " .. #scripts)
    print("first script = " .. tostring(scripts[1]))
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
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("stop_test", { steps = steps })
    lurek.automation.start("stop_test")
    lurek.automation.stop()
    print("stopped = " .. tostring(not lurek.automation.isRunning()))
    print("current script = " .. tostring(lurek.automation.getCurrentScript()))
end

--@api-stub: lurek.automation.pause
do
    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.5 },
    }
    lurek.automation.load("pause_test", { steps = steps })
    lurek.automation.start("pause_test")
    lurek.automation.pause()
    print("paused = " .. tostring(lurek.automation.isPaused()))
    print("running = " .. tostring(lurek.automation.isRunning()))
end

--@api-stub: lurek.automation.resume
do
    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.5 },
    }
    lurek.automation.load("resume_test", { steps = steps })
    lurek.automation.start("resume_test")
    lurek.automation.pause()
    lurek.automation.resume()
    print("paused after resume = " .. tostring(lurek.automation.isPaused()))
    print("running after resume = " .. tostring(lurek.automation.isRunning()))
end

--@api-stub: lurek.automation.update
do
    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.1 },
    }
    lurek.automation.load("update_test", { steps = steps })
    lurek.automation.start("update_test")
    lurek.automation.update(0.016)
    print("updated by 16ms")
    print("elapsed = " .. tostring(lurek.automation.getElapsedTime()))
end

--@api-stub: lurek.automation.isRunning
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("running_test", { steps = steps })
    lurek.automation.start("running_test")
    local running = lurek.automation.isRunning()
    print("isRunning = " .. tostring(running))
    lurek.automation.stop()
    print("isRunning after stop = " .. tostring(lurek.automation.isRunning()))
end

--@api-stub: lurek.automation.isPaused
do
    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.5 },
    }
    lurek.automation.load("paused_test", { steps = steps })
    lurek.automation.start("paused_test")
    lurek.automation.pause()
    local paused = lurek.automation.isPaused()
    print("isPaused = " .. tostring(paused))
    lurek.automation.resume()
    print("isPaused after resume = " .. tostring(lurek.automation.isPaused()))
end

--@api-stub: lurek.automation.isComplete
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("complete_test", { steps = steps })
    lurek.automation.start("complete_test")
    lurek.automation.update(0.1)
    local done = lurek.automation.isComplete()
    print("isComplete = " .. tostring(done))
    print("current step = " .. tostring(lurek.automation.getCurrentStep()))
end

--@api-stub: lurek.automation.isFailed
do
    local failed = lurek.automation.isFailed()
    print("isFailed = " .. tostring(failed))
end

--@api-stub: lurek.automation.getLastError
do
    lurek.automation.stop()
    local err = lurek.automation.getLastError()
    print("last error = " .. tostring(err))
    print("failed = " .. tostring(lurek.automation.isFailed()))
end

--@api-stub: lurek.automation.setCondition
do
    lurek.automation.setCondition("logged_in", true)
    print("condition set")
    print("logged_in = " .. tostring(lurek.automation.getCondition("logged_in")))
end

--@api-stub: lurek.automation.getCondition
do
    lurek.automation.setCondition("ready", true)
    local val = lurek.automation.getCondition("ready")
    print("ready = " .. tostring(val))
end

--@api-stub: lurek.automation.getCurrentStep
do
    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.2 },
    }
    lurek.automation.load("step_test", { steps = steps })
    lurek.automation.start("step_test")
    local step = lurek.automation.getCurrentStep()
    print("current step = " .. tostring(step))
    print("step count = " .. tostring(lurek.automation.getStepCount()))
end

--@api-stub: lurek.automation.getStepCount
do
    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.2 },
        { action = "wait", time = 0.4 },
    }
    lurek.automation.load("count_test", { steps = steps })
    lurek.automation.start("count_test")
    local count = lurek.automation.getStepCount()
    print("step count = " .. tostring(count))
    print("current step = " .. tostring(lurek.automation.getCurrentStep()))
end

--@api-stub: lurek.automation.getCurrentScript
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("current_test", { steps = steps })
    lurek.automation.start("current_test")
    local name = lurek.automation.getCurrentScript()
    print("current script = " .. tostring(name))
    print("running = " .. tostring(lurek.automation.isRunning()))
end

--@api-stub: lurek.automation.getElapsedTime
do
    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.2 },
    }
    lurek.automation.load("elapsed_test", { steps = steps })
    lurek.automation.start("elapsed_test")
    lurek.automation.update(0.05)
    local t = lurek.automation.getElapsedTime()
    print("elapsed = " .. tostring(t) .. "s")
    print("current script = " .. tostring(lurek.automation.getCurrentScript()))
end

--@api-stub: lurek.automation.loadFromToml
do
    local toml = "[[steps]]\naction = \"wait\"\ntime = 0.0\n"
    lurek.automation.loadFromToml("toml_script", toml)
    print("loaded from TOML = " .. tostring(lurek.automation.hasScript("toml_script")))
end

--@api-stub: lurek.automation.getStepLimit
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("limit_query", { steps = steps })
    local limit = lurek.automation.getStepLimit("run_test")
    local loaded_limit = lurek.automation.getStepLimit("limit_query")
    print("step limit for run_test = " .. tostring(limit))
    print("step limit for limit_query = " .. tostring(loaded_limit))
end

--@api-stub: lurek.automation.setStepLimit
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("limit_set", { steps = steps })
    local ok = lurek.automation.setStepLimit("limit_set", 1000)
    print("step limit updated = " .. tostring(ok))
    print("step limit = " .. tostring(lurek.automation.getStepLimit("limit_set")))
end

--@api-stub: lurek.automation.saveMacro
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("macro_source", { steps = steps })
    lurek.automation.saveMacro("fast_login", "macro_source")
    print("macro saved = " .. tostring(lurek.automation.hasMacro("fast_login")))
    print("macro count = " .. tostring(#lurek.automation.listMacros()))
end

--@api-stub: lurek.automation.playMacro
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("macro_play_source", { steps = steps })
    lurek.automation.saveMacro("fast_login", "macro_play_source")
    lurek.automation.playMacro("fast_login")
    print("macro playing = " .. tostring(lurek.automation.isRunning()))
    print("current script = " .. tostring(lurek.automation.getCurrentScript()))
end

--@api-stub: lurek.automation.hasMacro
do
    local has = lurek.automation.hasMacro("fast_login")
    print("has macro = " .. tostring(has))
end

--@api-stub: lurek.automation.listMacros
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("macro_list_source", { steps = steps })
    lurek.automation.saveMacro("fast_login", "macro_list_source")
    local macros = lurek.automation.listMacros()
    print("macros = " .. #macros)
    print("first macro = " .. tostring(macros[1]))
end

--@api-stub: lurek.automation.setPlaybackSpeed
do
    lurek.automation.setPlaybackSpeed(2.0)
    print("configured speed = 2.0")
    print("speed = " .. tostring(lurek.automation.getPlaybackSpeed()))
end

--@api-stub: lurek.automation.getPlaybackSpeed
do
    local speed = lurek.automation.getPlaybackSpeed()
    print("playback speed = " .. tostring(speed))
    print("speed query completed")
end

--@api-stub: lurek.automation.setHighlightMode
do
    lurek.automation.setHighlightMode(true)
    print("highlight = " .. tostring(lurek.automation.isHighlightMode()))
    lurek.automation.setHighlightMode(false)
    print("highlight after reset = " .. tostring(lurek.automation.isHighlightMode()))
end

--@api-stub: lurek.automation.isHighlightMode
do
    lurek.automation.setHighlightMode(true)
    local hl = lurek.automation.isHighlightMode()
    print("highlight mode = " .. tostring(hl))
    lurek.automation.setHighlightMode(false)
    print("highlight mode after reset = " .. tostring(lurek.automation.isHighlightMode()))
end

--@api-stub: lurek.automation.waitUntil
do
    lurek.automation.waitUntil(function()
        return lurek.automation.getCondition("ready")
    end, 5.0)
    print("waitUntil registered with 5s timeout")
end
