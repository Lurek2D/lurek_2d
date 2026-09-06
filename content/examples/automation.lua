-- content/examples/automation.lua
-- Auto-generated from content/examples2/automation_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/automation.lua

--- Automation Examples: Script loading, playback control, macros, conditions


--@api: lurek.automation.load
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("login_flow", { steps = steps })
    local scripts = lurek.automation.getScripts()
    lurek.log.info(tostring("loaded = " .. tostring(lurek.automation.hasScript("login_flow"))))
    lurek.log.info(tostring("script count = " .. tostring(#scripts)))
    lurek.automation.unload("login_flow")
end

--@api: lurek.automation.unload
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("temp_script", { steps = steps })
    local loaded = lurek.automation.hasScript("temp_script")
    lurek.automation.unload("temp_script")
    local still_loaded = lurek.automation.hasScript("temp_script")
    lurek.log.info(tostring("loaded before unload = " .. tostring(loaded)))
    lurek.log.info(tostring("unloaded = " .. tostring(not lurek.automation.hasScript("temp_script"))))
    lurek.log.info(tostring("loaded after unload = " .. tostring(still_loaded)))
end

--@api: lurek.automation.hasScript
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("status_check", { steps = steps })
    local has = lurek.automation.hasScript("nonexistent")
    local loaded = lurek.automation.hasScript("status_check")
    lurek.log.info(tostring("has nonexistent = " .. tostring(has)))
    lurek.log.info(tostring("has status_check = " .. tostring(loaded)))
end

--@api: lurek.automation.getScripts
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("list_one", { steps = steps })
    lurek.automation.load("list_two", { steps = steps })
    local scripts = lurek.automation.getScripts()
    lurek.log.info(tostring("loaded scripts = " .. #scripts))
    lurek.log.info(tostring("first script = " .. tostring(scripts[1])))
end

--@api: lurek.automation.start
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("run_test", { steps = steps })
    lurek.automation.start("run_test")
    local current = lurek.automation.getCurrentScript()
    lurek.log.info(tostring("running = " .. tostring(lurek.automation.isRunning())))
    lurek.log.info(tostring("current script = " .. tostring(current)))
    lurek.automation.stop()
    lurek.automation.unload("run_test")
end

--@api: lurek.automation.stop
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("stop_test", { steps = steps })
    lurek.automation.start("stop_test")
    lurek.automation.stop()
    lurek.log.info(tostring("stopped = " .. tostring(not lurek.automation.isRunning())))
    lurek.log.info(tostring("current script = " .. tostring(lurek.automation.getCurrentScript())))
end

--@api: lurek.automation.pause
do
    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.5 },
    }
    lurek.automation.load("pause_test", { steps = steps })
    lurek.automation.start("pause_test")
    lurek.automation.pause()
    lurek.log.info(tostring("paused = " .. tostring(lurek.automation.isPaused())))
    lurek.log.info(tostring("running = " .. tostring(lurek.automation.isRunning())))
end

--@api: lurek.automation.resume
do
    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.5 },
    }
    lurek.automation.load("resume_test", { steps = steps })
    lurek.automation.start("resume_test")
    lurek.automation.pause()
    lurek.automation.resume()
    lurek.log.info(tostring("paused after resume = " .. tostring(lurek.automation.isPaused())))
    lurek.log.info(tostring("running after resume = " .. tostring(lurek.automation.isRunning())))
end

--@api: lurek.automation.update
do
local steps = {
{ action = "wait", time = 0.0 },
{ action = "wait", time = 0.1 },
}
lurek.automation.load("update_test", { steps = steps })
lurek.automation.start("update_test")
lurek.automation.update(0.016)
lurek.log.info(tostring("updated by 16ms"))
lurek.log.info(tostring("elapsed = " .. tostring(lurek.automation.getElapsedTime())))
end

--@api: lurek.automation.isRunning
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("running_test", { steps = steps })
    lurek.automation.start("running_test")
    local running = lurek.automation.isRunning()
    lurek.log.info(tostring("isRunning = " .. tostring(running)))
    lurek.automation.stop()
    lurek.log.info(tostring("isRunning after stop = " .. tostring(lurek.automation.isRunning())))
end

--@api: lurek.automation.isPaused
do
    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.5 },
    }
    lurek.automation.load("paused_test", { steps = steps })
    lurek.automation.start("paused_test")
    lurek.automation.pause()
    local paused = lurek.automation.isPaused()
    lurek.log.info(tostring("isPaused = " .. tostring(paused)))
    lurek.automation.resume()
    lurek.log.info(tostring("isPaused after resume = " .. tostring(lurek.automation.isPaused())))
end

--@api: lurek.automation.isComplete
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("complete_test", { steps = steps })
    lurek.automation.start("complete_test")
    lurek.automation.update(0.1)
    local done = lurek.automation.isComplete()
    lurek.log.info(tostring("isComplete = " .. tostring(done)))
    lurek.log.info(tostring("current step = " .. tostring(lurek.automation.getCurrentStep())))
end

--@api: lurek.automation.isFailed
do
    lurek.automation.stop()
    local err = lurek.automation.getLastError()
    local failed = lurek.automation.isFailed()
    lurek.log.info(tostring("last error = " .. tostring(err)))
    lurek.log.info(tostring("isFailed = " .. tostring(failed)))
end

--@api: lurek.automation.getLastError
do
    lurek.automation.stop()
    local err = lurek.automation.getLastError()
    local failed = lurek.automation.isFailed()
    lurek.log.info(tostring("last error = " .. tostring(err)))
    lurek.log.info(tostring("failed = " .. tostring(failed)))
    lurek.log.info(tostring("has error text = " .. tostring(err ~= nil and err ~= "")))
end

--@api: lurek.automation.setCondition
do
    lurek.automation.setCondition("logged_in", true)
    lurek.automation.setCondition("ready", false)
    lurek.log.info(tostring("condition set"))
    lurek.log.info(tostring("logged_in = " .. tostring(lurek.automation.getCondition("logged_in"))))
    lurek.log.info(tostring("ready = " .. tostring(lurek.automation.getCondition("ready"))))
end

--@api: lurek.automation.getCondition
do
    lurek.automation.setCondition("ready", true)
    local val = lurek.automation.getCondition("ready")
    local missing = lurek.automation.getCondition("missing_condition")
    lurek.log.info(tostring("ready = " .. tostring(val)))
    lurek.log.info(tostring("missing_condition = " .. tostring(missing)))
    lurek.automation.setCondition("ready", false)
end

--@api: lurek.automation.getCurrentStep
do
    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.2 },
    }
    lurek.automation.load("step_test", { steps = steps })
    lurek.automation.start("step_test")
    local step = lurek.automation.getCurrentStep()
    lurek.log.info(tostring("current step = " .. tostring(step)))
    lurek.log.info(tostring("step count = " .. tostring(lurek.automation.getStepCount())))
end

--@api: lurek.automation.getStepCount
do
    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.2 },
        { action = "wait", time = 0.4 },
    }
    lurek.automation.load("count_test", { steps = steps })
    lurek.automation.start("count_test")
    local count = lurek.automation.getStepCount()
    lurek.log.info(tostring("step count = " .. tostring(count)))
    lurek.log.info(tostring("current step = " .. tostring(lurek.automation.getCurrentStep())))
end

--@api: lurek.automation.getCurrentScript
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("current_test", { steps = steps })
    lurek.automation.start("current_test")
    local name = lurek.automation.getCurrentScript()
    lurek.log.info(tostring("current script = " .. tostring(name)))
    lurek.log.info(tostring("running = " .. tostring(lurek.automation.isRunning())))
end

--@api: lurek.automation.getElapsedTime
do
    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.2 },
    }
    lurek.automation.load("elapsed_test", { steps = steps })
    lurek.automation.start("elapsed_test")
    lurek.automation.update(0.05)
    local t = lurek.automation.getElapsedTime()
    lurek.log.info(tostring("elapsed = " .. tostring(t) .. "s"))
    lurek.log.info(tostring("current script = " .. tostring(lurek.automation.getCurrentScript())))
end

--@api: lurek.automation.loadFromToml
do
    local toml = "[[steps]]\naction = \"wait\"\ntime = 0.0\n"
    lurek.automation.loadFromToml("toml_script", toml)
    local scripts = lurek.automation.getScripts()
    lurek.log.info(tostring("loaded from TOML = " .. tostring(lurek.automation.hasScript("toml_script"))))
    lurek.log.info(tostring("script count = " .. tostring(#scripts)))
    lurek.automation.unload("toml_script")
end

--@api: lurek.automation.getStepLimit
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("limit_query", { steps = steps })
    local limit = lurek.automation.getStepLimit("run_test")
    local loaded_limit = lurek.automation.getStepLimit("limit_query")
    lurek.log.info(tostring("step limit for run_test = " .. tostring(limit)))
    lurek.log.info(tostring("step limit for limit_query = " .. tostring(loaded_limit)))
end

--@api: lurek.automation.setStepLimit
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("limit_set", { steps = steps })
    local ok = lurek.automation.setStepLimit("limit_set", 1000)
    lurek.log.info(tostring("step limit updated = " .. tostring(ok)))
    lurek.log.info(tostring("step limit = " .. tostring(lurek.automation.getStepLimit("limit_set"))))
end

--@api: lurek.automation.saveMacro
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("macro_source", { steps = steps })
    lurek.automation.saveMacro("fast_login", "macro_source")
    lurek.log.info(tostring("macro saved = " .. tostring(lurek.automation.hasMacro("fast_login"))))
    lurek.log.info(tostring("macro count = " .. tostring(#lurek.automation.listMacros())))
end

--@api: lurek.automation.playMacro
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("macro_play_source", { steps = steps })
    lurek.automation.saveMacro("fast_login", "macro_play_source")
    lurek.automation.playMacro("fast_login")
    lurek.log.info(tostring("macro playing = " .. tostring(lurek.automation.isRunning())))
    lurek.log.info(tostring("current script = " .. tostring(lurek.automation.getCurrentScript())))
end

--@api: lurek.automation.hasMacro
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("macro_has_source", { steps = steps })
    lurek.automation.saveMacro("fast_login", "macro_has_source")
    local has = lurek.automation.hasMacro("fast_login")
    lurek.log.info(tostring("has macro = " .. tostring(has)))
    lurek.log.info(tostring("macro count = " .. tostring(#lurek.automation.listMacros())))
    lurek.automation.unload("macro_has_source")
end

--@api: lurek.automation.listMacros
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("macro_list_source", { steps = steps })
    lurek.automation.saveMacro("fast_login", "macro_list_source")
    local macros = lurek.automation.listMacros()
    lurek.log.info(tostring("macros = " .. #macros))
    lurek.log.info(tostring("first macro = " .. tostring(macros[1])))
end

--@api: lurek.automation.setPlaybackSpeed
do
    local before = lurek.automation.getPlaybackSpeed()
    lurek.automation.setPlaybackSpeed(2.0)
    lurek.log.info(tostring("configured speed = 2.0"))
    lurek.log.info(tostring("speed before = " .. tostring(before)))
    lurek.log.info(tostring("speed = " .. tostring(lurek.automation.getPlaybackSpeed())))
end

--@api: lurek.automation.getPlaybackSpeed
do
    lurek.automation.setPlaybackSpeed(1.5)
    local speed = lurek.automation.getPlaybackSpeed()
    lurek.log.info(tostring("playback speed = " .. tostring(speed)))
    lurek.log.info(tostring("speed query completed"))
    lurek.automation.setPlaybackSpeed(1.0)
end

--@api: lurek.automation.setHighlightMode
do
    local before = lurek.automation.isHighlightMode()
    lurek.automation.setHighlightMode(true)
    lurek.log.info(tostring("highlight before = " .. tostring(before)))
    lurek.log.info(tostring("highlight = " .. tostring(lurek.automation.isHighlightMode())))
    lurek.automation.setHighlightMode(false)
    lurek.log.info(tostring("highlight after reset = " .. tostring(lurek.automation.isHighlightMode())))
end

--@api: lurek.automation.isHighlightMode
do
    lurek.automation.setHighlightMode(true)
    local hl = lurek.automation.isHighlightMode()
    lurek.log.info(tostring("highlight mode = " .. tostring(hl)))
    lurek.automation.setHighlightMode(false)
    lurek.log.info(tostring("highlight mode after reset = " .. tostring(lurek.automation.isHighlightMode())))
end

--@api: lurek.automation.waitUntil
do
    lurek.automation.setCondition("ready", false)
    lurek.automation.waitUntil(function()
        return lurek.automation.getCondition("ready")
    end, 5.0)
    lurek.automation.setCondition("ready", true)
    lurek.log.info(tostring("waitUntil registered with 5s timeout"))
    lurek.log.info(tostring("ready = " .. tostring(lurek.automation.getCondition("ready"))))
end
