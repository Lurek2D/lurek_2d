-- content/examples/automation.lua
-- Auto-generated from content/examples2/automation_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/automation.lua

--- Automation Examples: Script loading, playback control, macros, conditions


--@api: lurek.automation.load
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("login_flow", { steps = steps })
    local scripts = lurek.automation.getScripts()
    example_print_log("loaded = " .. tostring(lurek.automation.hasScript("login_flow")))
    example_print_log("script count = " .. tostring(#scripts))
    lurek.automation.unload("login_flow")
end

--@api: lurek.automation.unload
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("temp_script", { steps = steps })
    local loaded = lurek.automation.hasScript("temp_script")
    lurek.automation.unload("temp_script")
    local still_loaded = lurek.automation.hasScript("temp_script")
    example_print_log("loaded before unload = " .. tostring(loaded))
    example_print_log("unloaded = " .. tostring(not lurek.automation.hasScript("temp_script")))
    example_print_log("loaded after unload = " .. tostring(still_loaded))
end

--@api: lurek.automation.hasScript
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("status_check", { steps = steps })
    local has = lurek.automation.hasScript("nonexistent")
    local loaded = lurek.automation.hasScript("status_check")
    example_print_log("has nonexistent = " .. tostring(has))
    example_print_log("has status_check = " .. tostring(loaded))
end

--@api: lurek.automation.getScripts
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("list_one", { steps = steps })
    lurek.automation.load("list_two", { steps = steps })
    local scripts = lurek.automation.getScripts()
    example_print_log("loaded scripts = " .. #scripts)
    example_print_log("first script = " .. tostring(scripts[1]))
end

--@api: lurek.automation.start
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("run_test", { steps = steps })
    lurek.automation.start("run_test")
    local current = lurek.automation.getCurrentScript()
    example_print_log("running = " .. tostring(lurek.automation.isRunning()))
    example_print_log("current script = " .. tostring(current))
    lurek.automation.stop()
    lurek.automation.unload("run_test")
end

--@api: lurek.automation.stop
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("stop_test", { steps = steps })
    lurek.automation.start("stop_test")
    lurek.automation.stop()
    example_print_log("stopped = " .. tostring(not lurek.automation.isRunning()))
    example_print_log("current script = " .. tostring(lurek.automation.getCurrentScript()))
end

--@api: lurek.automation.pause
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.5 },
    }
    lurek.automation.load("pause_test", { steps = steps })
    lurek.automation.start("pause_test")
    lurek.automation.pause()
    example_print_log("paused = " .. tostring(lurek.automation.isPaused()))
    example_print_log("running = " .. tostring(lurek.automation.isRunning()))
end

--@api: lurek.automation.resume
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.5 },
    }
    lurek.automation.load("resume_test", { steps = steps })
    lurek.automation.start("resume_test")
    lurek.automation.pause()
    lurek.automation.resume()
    example_print_log("paused after resume = " .. tostring(lurek.automation.isPaused()))
    example_print_log("running after resume = " .. tostring(lurek.automation.isRunning()))
end

--@api: lurek.automation.update
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.1 },
    }
    lurek.automation.load("update_test", { steps = steps })
    lurek.automation.start("update_test")
    lurek.automation.update(0.016)
    example_print_log("updated by 16ms")
    example_print_log("elapsed = " .. tostring(lurek.automation.getElapsedTime()))
end

--@api: lurek.automation.isRunning
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("running_test", { steps = steps })
    lurek.automation.start("running_test")
    local running = lurek.automation.isRunning()
    example_print_log("isRunning = " .. tostring(running))
    lurek.automation.stop()
    example_print_log("isRunning after stop = " .. tostring(lurek.automation.isRunning()))
end

--@api: lurek.automation.isPaused
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.5 },
    }
    lurek.automation.load("paused_test", { steps = steps })
    lurek.automation.start("paused_test")
    lurek.automation.pause()
    local paused = lurek.automation.isPaused()
    example_print_log("isPaused = " .. tostring(paused))
    lurek.automation.resume()
    example_print_log("isPaused after resume = " .. tostring(lurek.automation.isPaused()))
end

--@api: lurek.automation.isComplete
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("complete_test", { steps = steps })
    lurek.automation.start("complete_test")
    lurek.automation.update(0.1)
    local done = lurek.automation.isComplete()
    example_print_log("isComplete = " .. tostring(done))
    example_print_log("current step = " .. tostring(lurek.automation.getCurrentStep()))
end

--@api: lurek.automation.isFailed
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.automation.stop()
    local err = lurek.automation.getLastError()
    local failed = lurek.automation.isFailed()
    example_print_log("last error = " .. tostring(err))
    example_print_log("isFailed = " .. tostring(failed))
end

--@api: lurek.automation.getLastError
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.automation.stop()
    local err = lurek.automation.getLastError()
    local failed = lurek.automation.isFailed()
    example_print_log("last error = " .. tostring(err))
    example_print_log("failed = " .. tostring(failed))
    example_print_log("has error text = " .. tostring(err ~= nil and err ~= ""))
end

--@api: lurek.automation.setCondition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.automation.setCondition("logged_in", true)
    lurek.automation.setCondition("ready", false)
    example_print_log("condition set")
    example_print_log("logged_in = " .. tostring(lurek.automation.getCondition("logged_in")))
    example_print_log("ready = " .. tostring(lurek.automation.getCondition("ready")))
end

--@api: lurek.automation.getCondition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.automation.setCondition("ready", true)
    local val = lurek.automation.getCondition("ready")
    local missing = lurek.automation.getCondition("missing_condition")
    example_print_log("ready = " .. tostring(val))
    example_print_log("missing_condition = " .. tostring(missing))
    lurek.automation.setCondition("ready", false)
end

--@api: lurek.automation.getCurrentStep
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.2 },
    }
    lurek.automation.load("step_test", { steps = steps })
    lurek.automation.start("step_test")
    local step = lurek.automation.getCurrentStep()
    example_print_log("current step = " .. tostring(step))
    example_print_log("step count = " .. tostring(lurek.automation.getStepCount()))
end

--@api: lurek.automation.getStepCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.2 },
        { action = "wait", time = 0.4 },
    }
    lurek.automation.load("count_test", { steps = steps })
    lurek.automation.start("count_test")
    local count = lurek.automation.getStepCount()
    example_print_log("step count = " .. tostring(count))
    example_print_log("current step = " .. tostring(lurek.automation.getCurrentStep()))
end

--@api: lurek.automation.getCurrentScript
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("current_test", { steps = steps })
    lurek.automation.start("current_test")
    local name = lurek.automation.getCurrentScript()
    example_print_log("current script = " .. tostring(name))
    example_print_log("running = " .. tostring(lurek.automation.isRunning()))
end

--@api: lurek.automation.getElapsedTime
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.2 },
    }
    lurek.automation.load("elapsed_test", { steps = steps })
    lurek.automation.start("elapsed_test")
    lurek.automation.update(0.05)
    local t = lurek.automation.getElapsedTime()
    example_print_log("elapsed = " .. tostring(t) .. "s")
    example_print_log("current script = " .. tostring(lurek.automation.getCurrentScript()))
end

--@api: lurek.automation.loadFromToml
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local toml = "[[steps]]\naction = \"wait\"\ntime = 0.0\n"
    lurek.automation.loadFromToml("toml_script", toml)
    local scripts = lurek.automation.getScripts()
    example_print_log("loaded from TOML = " .. tostring(lurek.automation.hasScript("toml_script")))
    example_print_log("script count = " .. tostring(#scripts))
    lurek.automation.unload("toml_script")
end

--@api: lurek.automation.getStepLimit
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("limit_query", { steps = steps })
    local limit = lurek.automation.getStepLimit("run_test")
    local loaded_limit = lurek.automation.getStepLimit("limit_query")
    example_print_log("step limit for run_test = " .. tostring(limit))
    example_print_log("step limit for limit_query = " .. tostring(loaded_limit))
end

--@api: lurek.automation.setStepLimit
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("limit_set", { steps = steps })
    local ok = lurek.automation.setStepLimit("limit_set", 1000)
    example_print_log("step limit updated = " .. tostring(ok))
    example_print_log("step limit = " .. tostring(lurek.automation.getStepLimit("limit_set")))
end

--@api: lurek.automation.saveMacro
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("macro_source", { steps = steps })
    lurek.automation.saveMacro("fast_login", "macro_source")
    example_print_log("macro saved = " .. tostring(lurek.automation.hasMacro("fast_login")))
    example_print_log("macro count = " .. tostring(#lurek.automation.listMacros()))
end

--@api: lurek.automation.playMacro
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("macro_play_source", { steps = steps })
    lurek.automation.saveMacro("fast_login", "macro_play_source")
    lurek.automation.playMacro("fast_login")
    example_print_log("macro playing = " .. tostring(lurek.automation.isRunning()))
    example_print_log("current script = " .. tostring(lurek.automation.getCurrentScript()))
end

--@api: lurek.automation.hasMacro
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("macro_has_source", { steps = steps })
    lurek.automation.saveMacro("fast_login", "macro_has_source")
    local has = lurek.automation.hasMacro("fast_login")
    example_print_log("has macro = " .. tostring(has))
    example_print_log("macro count = " .. tostring(#lurek.automation.listMacros()))
    lurek.automation.unload("macro_has_source")
end

--@api: lurek.automation.listMacros
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("macro_list_source", { steps = steps })
    lurek.automation.saveMacro("fast_login", "macro_list_source")
    local macros = lurek.automation.listMacros()
    example_print_log("macros = " .. #macros)
    example_print_log("first macro = " .. tostring(macros[1]))
end

--@api: lurek.automation.setPlaybackSpeed
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local before = lurek.automation.getPlaybackSpeed()
    lurek.automation.setPlaybackSpeed(2.0)
    example_print_log("configured speed = 2.0")
    example_print_log("speed before = " .. tostring(before))
    example_print_log("speed = " .. tostring(lurek.automation.getPlaybackSpeed()))
end

--@api: lurek.automation.getPlaybackSpeed
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.automation.setPlaybackSpeed(1.5)
    local speed = lurek.automation.getPlaybackSpeed()
    example_print_log("playback speed = " .. tostring(speed))
    example_print_log("speed query completed")
    lurek.automation.setPlaybackSpeed(1.0)
end

--@api: lurek.automation.setHighlightMode
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local before = lurek.automation.isHighlightMode()
    lurek.automation.setHighlightMode(true)
    example_print_log("highlight before = " .. tostring(before))
    example_print_log("highlight = " .. tostring(lurek.automation.isHighlightMode()))
    lurek.automation.setHighlightMode(false)
    example_print_log("highlight after reset = " .. tostring(lurek.automation.isHighlightMode()))
end

--@api: lurek.automation.isHighlightMode
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.automation.setHighlightMode(true)
    local hl = lurek.automation.isHighlightMode()
    example_print_log("highlight mode = " .. tostring(hl))
    lurek.automation.setHighlightMode(false)
    example_print_log("highlight mode after reset = " .. tostring(lurek.automation.isHighlightMode()))
end

--@api: lurek.automation.waitUntil
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.automation.setCondition("ready", false)
    lurek.automation.waitUntil(function()
        return lurek.automation.getCondition("ready")
    end, 5.0)
    lurek.automation.setCondition("ready", true)
    example_print_log("waitUntil registered with 5s timeout")
    example_print_log("ready = " .. tostring(lurek.automation.getCondition("ready")))
end
