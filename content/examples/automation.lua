-- content/examples/automation.lua
-- Lurek2D lurek.automation API Reference
-- Run with: cargo run -- content/examples/automation

-- =============================================================================
-- lurek.automation — Scriptable test automation and macro recording
--
-- The automation module plays back recorded action sequences for automated
-- testing, demo recording, and tutorial replay.  Scripts are step-based
-- sequences loaded from Lua tables or TOML files.  Macros record and replay
-- player input for QA regression testing.
-- =============================================================================

-- ---- Stub: lurek.automation.load -----------------------------------------
--@api-stub: lurek.automation.load
-- Load a test automation script that walks through the tutorial flow.  Each
-- step describes an action (click, move, wait) with timing metadata.
local tutorial_script = {
    name = "tutorial_walkthrough",
    steps = {
        { action = "click",  target = "btn_new_game", delay = 0.5 },
        { action = "wait",   duration = 1.0 },
        { action = "move",   x = 400, y = 300, duration = 0.3 },
        { action = "click",  target = "btn_start", delay = 0.2 },
        { action = "keypress", key = "space", delay = 0.5 },
    },
}
lurek.automation.load(tutorial_script)
print("loaded automation script: " .. tutorial_script.name)
print("steps: " .. #tutorial_script.steps)

-- ---- Stub: lurek.automation.loadFromToml ---------------------------------
--@api-stub: lurek.automation.loadFromToml
-- Demonstrates the proper usage of lurek.automation.loadFromToml.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_automation_loadFromToml()
    lurek.automation.loadFromToml("tests/automation/smoke_test.toml")
    print("loaded TOML automation script")
end
local _ok, _err = pcall(demo_lurek_automation_loadFromToml)

-- ---- Stub: lurek.automation.hasScript ------------------------------------
--@api-stub: lurek.automation.hasScript
-- Demonstrates the proper usage of lurek.automation.hasScript.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_automation_hasScript()
    local has_tutorial = lurek.automation.hasScript("tutorial_walkthrough")
    print("tutorial script loaded: " .. tostring(has_tutorial))
end
local _ok, _err = pcall(demo_lurek_automation_hasScript)

-- ---- Stub: lurek.automation.getScripts -----------------------------------
--@api-stub: lurek.automation.getScripts
-- List all loaded automation scripts in the QA dashboard so testers can
-- pick which sequence to run.
local scripts = lurek.automation.getScripts()
print("loaded scripts:")
for i, name in ipairs(scripts) do
    print(string.format("  [%d] %s", i, name))
end

-- ---- Stub: lurek.automation.unload ---------------------------------------
--@api-stub: lurek.automation.unload
-- Remove a script after it finishes to free memory.  Useful in long QA
-- sessions that cycle through dozens of test plans.
lurek.automation.unload("tutorial_walkthrough")
print("unloaded tutorial_walkthrough script")

-- Reload for subsequent examples
lurek.automation.load(tutorial_script)

-- ---- Stub: lurek.automation.start ----------------------------------------
--@api-stub: lurek.automation.start
-- Demonstrates the proper usage of lurek.automation.start.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_automation_start()
    lurek.automation.start("tutorial_walkthrough")
    print("automation playback started")
end
local _ok, _err = pcall(demo_lurek_automation_start)

-- ---- Stub: lurek.automation.isRunning ------------------------------------
--@api-stub: lurek.automation.isRunning
-- Show a "REPLAY" badge in the corner of the screen while automation is
-- actively playing back so developers know input is synthetic.
local running = lurek.automation.isRunning()
print("automation running: " .. tostring(running))
if running then
    print("  [REPLAY] indicator should be visible")
end

-- ---- Stub: lurek.automation.update ---------------------------------------
--@api-stub: lurek.automation.update
-- Advance the automation by one frame's worth of time.  Call this in
-- lurek.process() so automation keeps pace with the game loop.
local dt = 0.016   -- 60 FPS delta
lurek.automation.update(dt)
print("automation advanced by " .. dt .. " seconds")

-- ---- Stub: lurek.automation.getCurrentStep -------------------------------
--@api-stub: lurek.automation.getCurrentStep
-- Demonstrates the proper usage of lurek.automation.getCurrentStep.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_automation_getCurrentStep()
    local step = lurek.automation.getCurrentStep()
    print("current step index: " .. tostring(step))
end
local _ok, _err = pcall(demo_lurek_automation_getCurrentStep)

-- ---- Stub: lurek.automation.getStepCount ---------------------------------
--@api-stub: lurek.automation.getStepCount
-- Demonstrates the proper usage of lurek.automation.getStepCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_automation_getStepCount()
    local total = lurek.automation.getStepCount()
    local current = lurek.automation.getCurrentStep()
    print(string.format("progress: step %d of %d", current or 0, total or 0))
end
local _ok, _err = pcall(demo_lurek_automation_getStepCount)

-- ---- Stub: lurek.automation.getCurrentScript -----------------------------
--@api-stub: lurek.automation.getCurrentScript
-- Demonstrates the proper usage of lurek.automation.getCurrentScript.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_automation_getCurrentScript()
    local script_name = lurek.automation.getCurrentScript()
    print("active script: " .. (script_name or "none"))
end
local _ok, _err = pcall(demo_lurek_automation_getCurrentScript)

-- ---- Stub: lurek.automation.getElapsedTime -------------------------------
--@api-stub: lurek.automation.getElapsedTime
-- Demonstrates the proper usage of lurek.automation.getElapsedTime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_automation_getElapsedTime()
    local elapsed = lurek.automation.getElapsedTime()
    print(string.format("elapsed playback time: %.2f sec", elapsed or 0))
end
local _ok, _err = pcall(demo_lurek_automation_getElapsedTime)

-- ---- Stub: lurek.automation.pause ----------------------------------------
--@api-stub: lurek.automation.pause
-- Demonstrates the proper usage of lurek.automation.pause.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_automation_pause()
    lurek.automation.pause()
    print("automation paused during loading screen")
end
local _ok, _err = pcall(demo_lurek_automation_pause)

-- ---- Stub: lurek.automation.isPaused -------------------------------------
--@api-stub: lurek.automation.isPaused
-- Demonstrates the proper usage of lurek.automation.isPaused.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_automation_isPaused()
    local paused = lurek.automation.isPaused()
    print("automation paused: " .. tostring(paused))
end
local _ok, _err = pcall(demo_lurek_automation_isPaused)

-- ---- Stub: lurek.automation.resume ---------------------------------------
--@api-stub: lurek.automation.resume
-- Demonstrates the proper usage of lurek.automation.resume.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_automation_resume()
    lurek.automation.resume()
    print("automation resumed after loading")
end
local _ok, _err = pcall(demo_lurek_automation_resume)

-- ---- Stub: lurek.automation.stop -----------------------------------------
--@api-stub: lurek.automation.stop
-- Demonstrates the proper usage of lurek.automation.stop.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_automation_stop()
    lurek.automation.stop()
    print("automation stopped -- all steps cancelled")
end
local _ok, _err = pcall(demo_lurek_automation_stop)

-- ---- Stub: lurek.automation.isComplete -----------------------------------
--@api-stub: lurek.automation.isComplete
-- Demonstrates the proper usage of lurek.automation.isComplete.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_automation_isComplete()
    local complete = lurek.automation.isComplete()
    print("script completed naturally: " .. tostring(complete))
end
local _ok, _err = pcall(demo_lurek_automation_isComplete)

-- ---- Stub: lurek.automation.getStepLimit ---------------------------------
--@api-stub: lurek.automation.getStepLimit
-- Demonstrates the proper usage of lurek.automation.getStepLimit.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_automation_getStepLimit()
    local limit = lurek.automation.getStepLimit()
    print("step limit: " .. tostring(limit or "unlimited"))
end
local _ok, _err = pcall(demo_lurek_automation_getStepLimit)

-- ---- Stub: lurek.automation.setStepLimit ---------------------------------
--@api-stub: lurek.automation.setStepLimit
-- Demonstrates the proper usage of lurek.automation.setStepLimit.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_automation_setStepLimit()
    lurek.automation.setStepLimit(100)
    print("step limit set to 100")
end
local _ok, _err = pcall(demo_lurek_automation_setStepLimit)

-- ---- Stub: lurek.automation.setPlaybackSpeed -----------------------------
--@api-stub: lurek.automation.setPlaybackSpeed
-- Demonstrates the proper usage of lurek.automation.setPlaybackSpeed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_automation_setPlaybackSpeed()
    lurek.automation.setPlaybackSpeed(4.0)
    print("playback speed: 4.0x")
end
local _ok, _err = pcall(demo_lurek_automation_setPlaybackSpeed)

-- ---- Stub: lurek.automation.getPlaybackSpeed -----------------------------
--@api-stub: lurek.automation.getPlaybackSpeed
-- Demonstrates the proper usage of lurek.automation.getPlaybackSpeed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_automation_getPlaybackSpeed()
    local speed = lurek.automation.getPlaybackSpeed()
    print("current playback speed: " .. speed .. "x")
end
local _ok, _err = pcall(demo_lurek_automation_getPlaybackSpeed)

-- ---- Stub: lurek.automation.saveMacro ------------------------------------
--@api-stub: lurek.automation.saveMacro
-- Demonstrates the proper usage of lurek.automation.saveMacro.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_automation_saveMacro()
    lurek.automation.saveMacro("boss_fight_attempt_1")
    print("macro saved: boss_fight_attempt_1")
end
local _ok, _err = pcall(demo_lurek_automation_saveMacro)

-- ---- Stub: lurek.automation.hasMacro -------------------------------------
--@api-stub: lurek.automation.hasMacro
-- Demonstrates the proper usage of lurek.automation.hasMacro.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_automation_hasMacro()
    local has_macro = lurek.automation.hasMacro("boss_fight_attempt_1")
    print("boss fight macro exists: " .. tostring(has_macro))
end
local _ok, _err = pcall(demo_lurek_automation_hasMacro)

-- ---- Stub: lurek.automation.listMacros -----------------------------------
--@api-stub: lurek.automation.listMacros
-- Demonstrates the proper usage of lurek.automation.listMacros.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_automation_listMacros()
    local macros = lurek.automation.listMacros()
    print("saved macros:")
    for i, name in ipairs(macros) do
    print(string.format("  [%d] %s", i, name))
end
local _ok, _err = pcall(demo_lurek_automation_listMacros)

-- ---- Stub: lurek.automation.playMacro ------------------------------------
--@api-stub: lurek.automation.playMacro
-- Demonstrates the proper usage of lurek.automation.playMacro.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_automation_playMacro()
    lurek.automation.playMacro("boss_fight_attempt_1")
    print("replaying macro: boss_fight_attempt_1")
end
local _ok, _err = pcall(demo_lurek_automation_playMacro)

-- ---- Stub: lurek.automation.setHighlightMode -----------------------------
--@api-stub: lurek.automation.setHighlightMode
-- Demonstrates the proper usage of lurek.automation.setHighlightMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_automation_setHighlightMode()
    lurek.automation.setHighlightMode(true)
    print("highlight mode enabled -- active element will be visually marked")
end
local _ok, _err = pcall(demo_lurek_automation_setHighlightMode)

-- ---- Stub: lurek.automation.isHighlightMode ------------------------------
--@api-stub: lurek.automation.isHighlightMode
-- Demonstrates the proper usage of lurek.automation.isHighlightMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_automation_isHighlightMode()
    local highlight = lurek.automation.isHighlightMode()
    print("highlight mode: " .. tostring(highlight))
end
local _ok, _err = pcall(demo_lurek_automation_isHighlightMode)

-- ---- Stub: lurek.automation.waitUntil ------------------------------------
--@api-stub: lurek.automation.waitUntil
-- Register a condition callback that blocks the automation until a game
-- state is reached (e.g. "wait until boss health < 50%").  This makes
-- scripts resilient to timing variations between machines.
lurek.automation.waitUntil(function()
    -- In a real game, check actual game state here
    local boss_hp_pct = 45   -- simulated
    return boss_hp_pct < 50
end, 10.0)    -- timeout after 10 seconds
print("waitUntil registered: boss HP < 50% (timeout 10s)")
