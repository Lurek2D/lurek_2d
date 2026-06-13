-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_automation_core_unit.lua
do
-- Lua unit tests for lurek.automation
-- One owner test per public automation API.

local automation = lurek.automation

local function reset_automation()
    automation.stop()
    automation.setPlaybackSpeed(1.0)
    automation.setHighlightMode(false)
    for _, name in ipairs(automation.getScripts()) do
        automation.unload(name)
    end
    automation.setCondition("ready_flag", false)
    automation.setCondition("boss_dead_flag", false)
    automation.setCondition("phase2_flag", false)
    automation.setCondition("invalid_ready_flag", false)
end

local function load_wait_script(name, times)
    local steps = {}
    for _, t in ipairs(times) do
        table.insert(steps, { action = "wait", time = t })
    end
    automation.load(name, { steps = steps })
end

local function expect_table_contains(values, expected)
    local found = false
    for _, value in ipairs(values) do
        if value == expected then
            found = true
        end
    end
    expect_true(found, "expected list to contain " .. tostring(expected))
end

-- @describe lurek.automation
describe("lurek.automation", function()
    before_each(reset_automation)
    after_each(reset_automation)

    -- @covers lurek.automation.load
    it("loads a script and replaces an existing script with the same name", function()
        load_wait_script("dup_script", { 0.0 })
        load_wait_script("dup_script", { 0.0, 1.0 })
        expect_true(automation.hasScript("dup_script"))
        automation.start("dup_script")
        expect_equal(2, automation.getStepCount())
    end)

    -- @covers lurek.automation.unload
    it("returns true for loaded scripts and removes them", function()
        load_wait_script("remove_me", { 0.0 })
        expect_true(automation.unload("remove_me"))
        expect_false(automation.hasScript("remove_me"))
        expect_false(automation.unload("remove_me"))
    end)

    -- @covers lurek.automation.hasScript
    it("reports whether a named script is loaded", function()
        expect_false(automation.hasScript("missing_script"))
        load_wait_script("known_script", { 0.0 })
        expect_true(automation.hasScript("known_script"))
    end)

    -- @covers lurek.automation.getScripts
    it("lists the currently loaded script names", function()
        load_wait_script("alpha_script", { 0.0 })
        load_wait_script("beta_script", { 0.0 })
        local names = automation.getScripts()
        expect_type("table", names)
        expect_table_contains(names, "alpha_script")
        expect_table_contains(names, "beta_script")
    end)

    -- @covers lurek.automation.start
    it("starts a loaded script and sets it as current", function()
        load_wait_script("start_script", { 1.0 })
        automation.start("start_script")
        expect_true(automation.isRunning())
        expect_equal("start_script", automation.getCurrentScript())
    end)

    -- @covers lurek.automation.stop
    it("stops playback and resets active script state", function()
        load_wait_script("stop_script", { 1.0 })
        automation.start("stop_script")
        automation.stop()
        expect_false(automation.isRunning())
        expect_nil(automation.getCurrentScript())
        expect_equal(0, automation.getCurrentStep())
    end)

    -- @covers lurek.automation.pause
    it("pauses a running script without advancing it", function()
        load_wait_script("pause_script", { 0.0, 1.0 })
        automation.start("pause_script")
        automation.pause()
        automation.update(0.5)
        expect_true(automation.isPaused())
        expect_equal(0, automation.getCurrentStep())
        expect_near(0.0, automation.getElapsedTime(), 0.001)
    end)

    -- @covers lurek.automation.resume
    it("resumes playback after a pause", function()
        load_wait_script("resume_script", { 0.0, 0.2 })
        automation.start("resume_script")
        automation.pause()
        automation.resume()
        expect_false(automation.isPaused())
        expect_true(automation.isRunning())
    end)

    -- @covers lurek.automation.update
    it("advances repeated steps and elapsed time", function()
        automation.load("repeat_script", {
            steps = {
                { action = "wait", time = 0.5, ["repeat"] = 2, repeatInterval = 0.25 },
            }
        })
        automation.start("repeat_script")
        automation.update(0.50)
        expect_equal(1, automation.getCurrentStep())
        automation.update(0.25)
        expect_equal(2, automation.getCurrentStep())
        automation.update(0.25)
        expect_equal(3, automation.getCurrentStep())
        expect_true(automation.getElapsedTime() >= 1.0)
    end)

    -- @covers lurek.automation.isRunning
    it("returns false when idle and true while a script is active", function()
        expect_false(automation.isRunning())
        load_wait_script("running_script", { 1.0 })
        automation.start("running_script")
        expect_true(automation.isRunning())
    end)

    -- @covers lurek.automation.isPaused
    it("returns true only while playback is paused", function()
        expect_false(automation.isPaused())
        load_wait_script("paused_script", { 1.0 })
        automation.start("paused_script")
        automation.pause()
        expect_true(automation.isPaused())
    end)

    -- @covers lurek.automation.isComplete
    it("returns true after a script finishes", function()
        load_wait_script("complete_script", { 0.0, 0.1 })
        automation.start("complete_script")
        automation.update(0.5)
        expect_true(automation.isComplete())
        expect_false(automation.isRunning())
    end)

    -- @covers lurek.automation.getCurrentStep
    it("tracks the dispatched step index", function()
        load_wait_script("step_script", { 0.0, 0.5, 1.0 })
        automation.start("step_script")
        automation.update(0.1)
        expect_equal(1, automation.getCurrentStep())
        automation.update(0.5)
        expect_equal(2, automation.getCurrentStep())
    end)

    -- @covers lurek.automation.getStepCount
    it("returns the number of steps in the active script", function()
        load_wait_script("count_script", { 0.0, 0.5, 1.0 })
        automation.start("count_script")
        expect_equal(3, automation.getStepCount())
    end)

    -- @covers lurek.automation.getCurrentScript
    it("returns nil when idle and the running script name when active", function()
        expect_nil(automation.getCurrentScript())
        load_wait_script("current_script", { 1.0 })
        automation.start("current_script")
        expect_equal("current_script", automation.getCurrentScript())
    end)

    -- @covers lurek.automation.getElapsedTime
    it("accumulates virtual playback time during updates", function()
        load_wait_script("elapsed_script", { 10.0 })
        automation.start("elapsed_script")
        automation.update(0.5)
        automation.update(0.3)
        expect_near(0.8, automation.getElapsedTime(), 0.001)
    end)

    -- @covers lurek.automation.loadFromToml
    it("loads scripts from TOML text", function()
        local toml = [=[
[[steps]]
action = "wait"
time = 0.0

[[steps]]
action = "wait"
time = 0.2
]=]
        automation.loadFromToml("toml_script", toml)
        expect_true(automation.hasScript("toml_script"))
        automation.start("toml_script")
        expect_equal(2, automation.getStepCount())
    end)

    -- @covers lurek.automation.saveMacro
    it("saves a loaded script as a macro", function()
        load_wait_script("macro_source", { 0.01 })
        automation.saveMacro("saved_macro", "macro_source")
        expect_true(automation.hasMacro("saved_macro"))
    end)

    -- @covers lurek.automation.listMacros
    it("returns saved macro names", function()
        load_wait_script("macro_list_source", { 0.01 })
        automation.saveMacro("listed_macro", "macro_list_source")
        local macros = automation.listMacros()
        expect_type("table", macros)
        expect_table_contains(macros, "listed_macro")
    end)

    -- @covers lurek.automation.playMacro
    it("starts playback of a saved macro", function()
        load_wait_script("macro_play_source", { 0.05 })
        automation.saveMacro("playable_macro", "macro_play_source")
        automation.playMacro("playable_macro")
        expect_true(automation.isRunning())
    end)

    -- @covers lurek.automation.setPlaybackSpeed
    it("changes playback speed for later updates", function()
        load_wait_script("speed_script", { 0.10 })
        automation.setPlaybackSpeed(2.0)
        automation.start("speed_script")
        automation.update(0.06)
        expect_true(automation.isComplete())
    end)

    -- @covers lurek.automation.getPlaybackSpeed
    it("returns the current playback speed multiplier", function()
        expect_near(1.0, automation.getPlaybackSpeed(), 0.001)
        automation.setPlaybackSpeed(2.5)
        expect_near(2.5, automation.getPlaybackSpeed(), 0.001)
    end)

    -- @covers lurek.automation.waitUntil
    it("holds script progress until the predicate becomes true and then resumes on a later update", function()
        local ready = false
        load_wait_script("wait_until_script", { 0.01 })
        automation.start("wait_until_script")
        automation.waitUntil(function()
            return ready
        end, 1.0)
        automation.update(0.5)
        expect_equal(0, automation.getCurrentStep())
        ready = true
        automation.update(0.01)
        automation.update(0.02)
        expect_true(automation.isComplete() or automation.getCurrentStep() >= 1)
    end)

    -- @covers lurek.automation.getStepLimit
    it("returns nil for missing scripts and the default limit for loaded scripts", function()
        expect_nil(automation.getStepLimit("missing_limit_script"))
        load_wait_script("limit_query_script", { 0.01 })
        expect_equal(100000, automation.getStepLimit("limit_query_script"))
    end)

    -- @covers lurek.automation.setStepLimit
    it("stores and overwrites step limits for loaded scripts", function()
        load_wait_script("limit_set_script", { 0.01 })
        expect_true(automation.setStepLimit("limit_set_script", 25))
        expect_equal(25, automation.getStepLimit("limit_set_script"))
        expect_true(automation.setStepLimit("limit_set_script", 99))
        expect_equal(99, automation.getStepLimit("limit_set_script"))
        expect_false(automation.setStepLimit("missing_limit_script", 10))
    end)

    -- @covers lurek.automation.setHighlightMode
    it("toggles highlight mode on and off", function()
        automation.setHighlightMode(true)
        expect_true(automation.isHighlightMode())
        automation.setHighlightMode(false)
        expect_false(automation.isHighlightMode())
    end)

    -- @covers lurek.automation.isHighlightMode
    it("returns a boolean state", function()
        expect_type("boolean", automation.isHighlightMode())
    end)

    -- @covers lurek.automation.setCondition
    it("stores boolean conditions used by automation scripts", function()
        automation.setCondition("ready_flag", true)
        expect_true(automation.getCondition("ready_flag"))
        automation.setCondition("ready_flag", false)
        expect_false(automation.getCondition("ready_flag"))
    end)

    -- @covers lurek.automation.getCondition
    it("returns false for unset conditions and true for set ones", function()
        expect_false(automation.getCondition("boss_dead_flag"))
        automation.setCondition("boss_dead_flag", true)
        expect_true(automation.getCondition("boss_dead_flag"))
    end)

    -- @covers lurek.automation.isFailed
    it("reports failed automation assertions", function()
        automation.load("failed_script", {
            steps = {
                {
                    action = "assert",
                    assert = "ready_flag && (boss_dead_flag || phase2_flag)",
                    time = 0.0,
                },
            }
        })
        automation.setCondition("ready_flag", true)
        automation.start("failed_script")
        automation.update(0.016)
        expect_true(automation.isFailed())
    end)

    -- @covers lurek.automation.getLastError
    it("exposes parser or assertion failure text", function()
        automation.load("error_script", {
            steps = {
                {
                    action = "assert",
                    assert = "invalid_ready_flag && (phase2_flag",
                    time = 0.0,
                },
            }
        })
        automation.setCondition("invalid_ready_flag", true)
        automation.start("error_script")
        automation.update(0.016)
        local err = automation.getLastError()
        expect_type("string", err)
        expect_contains(err, "expected ')'")
    end)

    -- @covers lurek.automation.hasMacro
    it("reports whether a macro exists", function()
        expect_false(automation.hasMacro("missing_macro"))
        load_wait_script("macro_probe_source", { 0.01 })
        automation.saveMacro("known_macro", "macro_probe_source")
        expect_true(automation.hasMacro("known_macro"))
    end)
end)

reset_automation()
end
-- END test_automation_core_unit.lua

test_summary()
