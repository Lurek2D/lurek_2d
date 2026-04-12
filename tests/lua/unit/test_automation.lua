-- Lua BDD tests for lurek.simulator (automation module)
-- @covers lurek.simulator.getCurrentScript
-- @covers lurek.simulator.getCurrentStep
-- @covers lurek.simulator.getElapsedTime
-- @covers lurek.simulator.getScripts
-- @covers lurek.simulator.getStepCount
-- @covers lurek.simulator.hasScript
-- @covers lurek.simulator.isComplete
-- @covers lurek.simulator.isPaused
-- @covers lurek.simulator.isRunning
-- @covers lurek.simulator.load
-- @covers lurek.simulator.loadFromToml
-- @covers lurek.simulator.pause
-- @covers lurek.simulator.resume
-- @covers lurek.simulator.start
-- @covers lurek.simulator.stop
-- @covers lurek.simulator.unload
-- @covers lurek.simulator.update


-- @description Verifies the simulator namespace is exposed and that every documented loader, lifecycle, query, and TOML helper entry point is registered on the Lua side.
describe("lurek.simulator - namespace", function()
    -- @description Confirms the simulator namespace is registered as a Lua table.
    it("should exist as a table", function()
        expect_type("table", lurek.simulator)
    end)

    -- @description Checks the scripted automation loader is exported for table-based script definitions.
    it("should have load function", function()
        expect_type("function", lurek.simulator.load)
    end)

    -- @description Checks the unload entry point is exported for removing previously loaded scripts.
    it("should have unload function", function()
        expect_type("function", lurek.simulator.unload)
    end)

    -- @description Verifies the namespace exposes the script-existence query helper.
    it("should have hasScript function", function()
        expect_type("function", lurek.simulator.hasScript)
    end)

    -- @description Verifies the namespace exposes the loaded-script listing helper.
    it("should have getScripts function", function()
        expect_type("function", lurek.simulator.getScripts)
    end)

    -- @description Confirms playback can be started through the exported start function.
    it("should have start function", function()
        expect_type("function", lurek.simulator.start)
    end)

    -- @description Confirms playback can be stopped through the exported stop function.
    it("should have stop function", function()
        expect_type("function", lurek.simulator.stop)
    end)

    -- @description Confirms the pause control is available on the namespace.
    it("should have pause function", function()
        expect_type("function", lurek.simulator.pause)
    end)

    -- @description Confirms the resume control is available on the namespace.
    it("should have resume function", function()
        expect_type("function", lurek.simulator.resume)
    end)

    -- @description Verifies the time-step update entry point is exported for dispatching queued steps.
    it("should have update function", function()
        expect_type("function", lurek.simulator.update)
    end)

    -- @description Checks the running-state query exists so callers can detect active playback.
    it("should have isRunning function", function()
        expect_type("function", lurek.simulator.isRunning)
    end)

    -- @description Checks the paused-state query exists so callers can detect paused playback.
    it("should have isPaused function", function()
        expect_type("function", lurek.simulator.isPaused)
    end)

    -- @description Checks the completion-state query exists so callers can detect fully consumed scripts.
    it("should have isComplete function", function()
        expect_type("function", lurek.simulator.isComplete)
    end)

    -- @description Verifies the current-step query helper is exported.
    it("should have getCurrentStep function", function()
        expect_type("function", lurek.simulator.getCurrentStep)
    end)

    -- @description Verifies the total-step-count query helper is exported.
    it("should have getStepCount function", function()
        expect_type("function", lurek.simulator.getStepCount)
    end)

    -- @description Verifies the current-script query helper is exported.
    it("should have getCurrentScript function", function()
        expect_type("function", lurek.simulator.getCurrentScript)
    end)

    -- @description Verifies the elapsed-time query helper is exported.
    it("should have getElapsedTime function", function()
        expect_type("function", lurek.simulator.getElapsedTime)
    end)

    -- @description Confirms TOML-based loading is available alongside table-based loading.
    it("should have loadFromToml function", function()
        expect_type("function", lurek.simulator.loadFromToml)
    end)
end)

-- @description Exercises loading, replacing, listing, and unloading simulator scripts built from step tables and optional metadata.
describe("lurek.simulator - script management", function()
    -- @description Loads a minimal one-step keypress script and verifies it is registered under the requested name.
    it("should load a script with a single keypress step", function()
        lurek.simulator.load("single_key", {
            steps = {
                { action = "keypress", key = "a", time = 0.5 }
            }
        })
        expect_equal(lurek.simulator.hasScript("single_key"), true)
        lurek.simulator.unload("single_key")
    end)

    -- @description Loads a mixed-action script covering keyboard, mouse, text, and wait steps to verify the parser accepts every supported step shape.
    it("should load a script with multiple step types", function()
        lurek.simulator.load("multi", {
            steps = {
                { action = "keypress", key = "space", time = 0.0 },
                { action = "keyrelease", key = "space", time = 0.1 },
                { action = "mousemove", x = 100, y = 200, dx = 5, dy = 3, time = 0.5 },
                { action = "mousepress", x = 100, y = 200, button = 1, time = 0.6 },
                { action = "mouserelease", x = 100, y = 200, button = 1, time = 0.7 },
                { action = "mousewheel", x = 0, y = 3, time = 1.0 },
                { action = "textinput", text = "hello", time = 1.5 },
                { action = "wait", time = 2.0 },
            }
        })
        expect_equal(lurek.simulator.hasScript("multi"), true)
        lurek.simulator.unload("multi")
    end)

    -- @description Confirms script metadata can accompany the step list without preventing registration.
    it("should load a script with meta description", function()
        lurek.simulator.load("described", {
            steps = { { action = "wait", time = 0.0 } },
            meta = { description = "A test script with description" }
        })
        expect_equal(lurek.simulator.hasScript("described"), true)
        lurek.simulator.unload("described")
    end)

    -- @description Verifies unknown script names are reported as absent rather than raising errors.
    it("should report hasScript false for unknown scripts", function()
        expect_equal(lurek.simulator.hasScript("nonexistent"), false)
    end)

    -- @description Loads and unloads a script, then checks the removal call returns success and clears the registry entry.
    it("should unload a loaded script", function()
        lurek.simulator.load("to_remove", {
            steps = { { action = "wait", time = 0.0 } }
        })
        local result = lurek.simulator.unload("to_remove")
        expect_equal(result, true)
        expect_equal(lurek.simulator.hasScript("to_remove"), false)
    end)

    -- @description Verifies unloading a missing script is a harmless false result instead of an exception.
    it("should return false when unloading nonexistent script", function()
        local result = lurek.simulator.unload("does_not_exist")
        expect_equal(result, false)
    end)

    -- @description Confirms the loaded-script listing includes every registered name when multiple scripts coexist.
    it("should list loaded scripts via getScripts", function()
        lurek.simulator.load("alpha", {
            steps = { { action = "wait", time = 0.0 } }
        })
        lurek.simulator.load("beta", {
            steps = { { action = "wait", time = 0.0 } }
        })
        local names = lurek.simulator.getScripts()
        expect_type("table", names)
        -- Should contain both names
        local found_alpha = false
        local found_beta = false
        for _, name in ipairs(names) do
            if name == "alpha" then found_alpha = true end
            if name == "beta" then found_beta = true end
        end
        expect_equal(found_alpha, true)
        expect_equal(found_beta, true)
        lurek.simulator.unload("alpha")
        lurek.simulator.unload("beta")
    end)

    -- @description Clears any existing state and verifies the script listing becomes an empty table when nothing is loaded.
    it("should return empty table when no scripts loaded", function()
        -- Clean state
        for _, name in ipairs(lurek.simulator.getScripts()) do
            lurek.simulator.unload(name)
        end
        local names = lurek.simulator.getScripts()
        expect_equal(#names, 0)
    end)

    -- @description Loads the same script name twice and verifies the second definition replaces the first, including its step count.
    it("should replace script when loading same name twice", function()
        lurek.simulator.load("dup", {
            steps = { { action = "wait", time = 0.0 } }
        })
        lurek.simulator.load("dup", {
            steps = {
                { action = "wait", time = 0.0 },
                { action = "wait", time = 1.0 },
            }
        })
        expect_equal(lurek.simulator.hasScript("dup"), true)
        -- Start to check step count reflects the second load
        lurek.simulator.start("dup")
        expect_equal(lurek.simulator.getStepCount(), 2)
        lurek.simulator.stop()
        lurek.simulator.unload("dup")
    end)
end)

-- @description Covers simulator playback lifecycle transitions including starting, stopping, pausing, resuming, and no-op control calls when idle.
describe("lurek.simulator - playback control", function()
    -- @description Starts a loaded script and checks that running-state and current-script queries reflect the active playback.
    it("should start playback of a loaded script", function()
        lurek.simulator.load("play", {
            steps = { { action = "wait", time = 1.0 } }
        })
        lurek.simulator.start("play")
        expect_equal(lurek.simulator.isRunning(), true)
        expect_equal(lurek.simulator.getCurrentScript(), "play")
        lurek.simulator.stop()
        lurek.simulator.unload("play")
    end)

    -- @description Verifies attempting to start an unknown script raises an error instead of entering an invalid running state.
    it("should error when starting nonexistent script", function()
        expect_error(function()
            lurek.simulator.start("nonexistent_script")
        end)
    end)

    -- @description Stops an active script and verifies the runtime resets its running flag, current script, and current step index.
    it("should stop playback and reset state", function()
        lurek.simulator.load("stop_test", {
            steps = { { action = "wait", time = 1.0 } }
        })
        lurek.simulator.start("stop_test")
        lurek.simulator.stop()
        expect_equal(lurek.simulator.isRunning(), false)
        expect_equal(lurek.simulator.getCurrentScript(), nil)
        expect_equal(lurek.simulator.getCurrentStep(), 0)
        lurek.simulator.unload("stop_test")
    end)

    -- @description Pauses a running script and verifies the paused and running state flags flip appropriately.
    it("should pause running playback", function()
        lurek.simulator.load("pause_test", {
            steps = { { action = "wait", time = 1.0 } }
        })
        lurek.simulator.start("pause_test")
        lurek.simulator.pause()
        expect_equal(lurek.simulator.isPaused(), true)
        expect_equal(lurek.simulator.isRunning(), false)
        lurek.simulator.stop()
        lurek.simulator.unload("pause_test")
    end)

    -- @description Resumes a paused script and verifies playback returns to the running state while clearing the paused flag.
    it("should resume paused playback", function()
        lurek.simulator.load("resume_test", {
            steps = { { action = "wait", time = 1.0 } }
        })
        lurek.simulator.start("resume_test")
        lurek.simulator.pause()
        lurek.simulator.resume()
        expect_equal(lurek.simulator.isRunning(), true)
        expect_equal(lurek.simulator.isPaused(), false)
        lurek.simulator.stop()
        lurek.simulator.unload("resume_test")
    end)

    -- @description Ensures calling pause while idle is a safe no-op that does not manufacture a paused state.
    it("should be safe to pause when idle", function()
        lurek.simulator.pause()
        expect_equal(lurek.simulator.isPaused(), false)
    end)

    -- @description Ensures calling stop while idle is a safe no-op that leaves the simulator non-running.
    it("should be safe to stop when idle", function()
        lurek.simulator.stop()
        expect_equal(lurek.simulator.isRunning(), false)
    end)

    -- @description Verifies resume is idempotent when playback is already running and does not disrupt the active script.
    it("should be safe to resume when not paused", function()
        lurek.simulator.load("resume_noop", {
            steps = { { action = "wait", time = 1.0 } }
        })
        lurek.simulator.start("resume_noop")
        lurek.simulator.resume() -- already running, should be noop
        expect_equal(lurek.simulator.isRunning(), true)
        lurek.simulator.stop()
        lurek.simulator.unload("resume_noop")
    end)
end)

-- @description Verifies the simulator exposes stable default query values while idle with no script loaded or running.
describe("lurek.simulator - state queries", function()
    -- @description Checks the running-state query reports false before playback begins.
    it("should report not running when idle", function()
        expect_equal(lurek.simulator.isRunning(), false)
    end)

    -- @description Checks the paused-state query reports false in idle state.
    it("should report not paused when idle", function()
        expect_equal(lurek.simulator.isPaused(), false)
    end)

    -- @description Checks the completion-state query reports false when no script has been executed.
    it("should report not complete when idle", function()
        expect_equal(lurek.simulator.isComplete(), false)
    end)

    -- @description Checks the elapsed-time counter starts at zero before any updates are processed.
    it("should report zero elapsed time when idle", function()
        expect_near(lurek.simulator.getElapsedTime(), 0.0, 0.001)
    end)

    -- @description Checks the current-step query starts at zero before playback begins.
    it("should report zero current step when idle", function()
        expect_equal(lurek.simulator.getCurrentStep(), 0)
    end)

    -- @description Checks the total-step-count query reports zero when no active script is selected.
    it("should report zero step count when idle", function()
        expect_equal(lurek.simulator.getStepCount(), 0)
    end)

    -- @description Checks the current-script query returns nil when the simulator is idle.
    it("should report nil current script when idle", function()
        expect_equal(lurek.simulator.getCurrentScript(), nil)
    end)
end)

-- @description Exercises runtime advancement, event dispatch, completion handling, and paused behavior while simulator time is updated.
describe("lurek.simulator - update and completion", function()
    -- @description Advances a running script in two updates and verifies elapsed time accumulates exactly across calls.
    it("should advance elapsed time on update", function()
        lurek.simulator.load("time_test", {
            steps = { { action = "wait", time = 10.0 } }
        })
        lurek.simulator.start("time_test")
        lurek.simulator.update(0.5)
        expect_near(lurek.simulator.getElapsedTime(), 0.5, 0.001)
        lurek.simulator.update(0.3)
        expect_near(lurek.simulator.getElapsedTime(), 0.8, 0.001)
        lurek.simulator.stop()
        lurek.simulator.unload("time_test")
    end)

    -- @description Runs past the timestamps of every step in a short script and verifies the simulator marks playback complete and stops running.
    it("should complete after all steps pass", function()
        lurek.simulator.load("complete_test", {
            steps = {
                { action = "wait", time = 0.0 },
                { action = "wait", time = 0.1 },
            }
        })
        lurek.simulator.start("complete_test")
        lurek.simulator.update(0.5) -- advance past all steps
        expect_equal(lurek.simulator.isComplete(), true)
        expect_equal(lurek.simulator.isRunning(), false)
        lurek.simulator.stop()
        lurek.simulator.unload("complete_test")
    end)

    -- @description Verifies current-step tracking increments as timed wait steps become eligible for dispatch over multiple updates.
    it("should advance current step as steps are dispatched", function()
        lurek.simulator.load("step_advance", {
            steps = {
                { action = "wait", time = 0.0 },
                { action = "wait", time = 0.5 },
                { action = "wait", time = 1.0 },
            }
        })
        lurek.simulator.start("step_advance")
        expect_equal(lurek.simulator.getStepCount(), 3)

        lurek.simulator.update(0.1) -- step 0 fires (time 0.0)
        expect_equal(lurek.simulator.getCurrentStep(), 1)

        lurek.simulator.update(0.5) -- step 1 fires (time 0.5, elapsed 0.6)
        expect_equal(lurek.simulator.getCurrentStep(), 2)

        lurek.simulator.stop()
        lurek.simulator.unload("step_advance")
    end)

    -- @description Pauses playback before updating and verifies neither elapsed time nor current-step state advances while paused.
    it("should not advance when paused", function()
        lurek.simulator.load("pause_hold", {
            steps = { { action = "wait", time = 0.0 } }
        })
        lurek.simulator.start("pause_hold")
        lurek.simulator.pause()
        lurek.simulator.update(1.0)
        expect_equal(lurek.simulator.getCurrentStep(), 0)
        expect_near(lurek.simulator.getElapsedTime(), 0.0, 0.001)
        lurek.simulator.stop()
        lurek.simulator.unload("pause_hold")
    end)

    -- @description Dispatches a keypress and keyrelease sequence through update and verifies the script completes after both keyboard events are processed.
    it("should dispatch keypress events via update", function()
        lurek.simulator.load("key_test", {
            steps = {
                { action = "keypress", key = "a", time = 0.0 },
                { action = "keyrelease", key = "a", time = 0.1 },
            }
        })
        lurek.simulator.start("key_test")
        lurek.simulator.update(0.2)
        expect_equal(lurek.simulator.isComplete(), true)
        lurek.simulator.stop()
        lurek.simulator.unload("key_test")
    end)

    -- @description Dispatches mouse movement, press, release, and wheel steps and verifies the scripted mouse sequence completes in one update window.
    it("should dispatch mouse events via update", function()
        lurek.simulator.load("mouse_test", {
            steps = {
                { action = "mousemove", x = 100, y = 200, dx = 0, dy = 0, time = 0.0 },
                { action = "mousepress", x = 100, y = 200, button = 1, time = 0.1 },
                { action = "mouserelease", x = 100, y = 200, button = 1, time = 0.2 },
                { action = "mousewheel", x = 0, y = 3, time = 0.3 },
            }
        })
        lurek.simulator.start("mouse_test")
        lurek.simulator.update(0.5)
        expect_equal(lurek.simulator.isComplete(), true)
        lurek.simulator.stop()
        lurek.simulator.unload("mouse_test")
    end)

    -- @description Dispatches a text-input step and verifies the single-step script reaches completion.
    it("should dispatch textinput events via update", function()
        lurek.simulator.load("text_test", {
            steps = { { action = "textinput", text = "hello world", time = 0.0 } }
        })
        lurek.simulator.start("text_test")
        lurek.simulator.update(0.1)
        expect_equal(lurek.simulator.isComplete(), true)
        lurek.simulator.stop()
        lurek.simulator.unload("text_test")
    end)

    -- @description Starts a script with no steps and verifies the simulator treats it as immediately complete without errors.
    it("should handle empty script gracefully", function()
        lurek.simulator.load("empty", { steps = {} })
        lurek.simulator.start("empty")
        lurek.simulator.update(0.1)
        expect_equal(lurek.simulator.isComplete(), true)
        lurek.simulator.stop()
        lurek.simulator.unload("empty")
    end)
end)

-- @description Verifies invalid simulator script definitions fail fast with descriptive errors instead of registering broken playback data.
describe("lurek.simulator - error handling", function()
    -- @description Rejects script loads that omit the required steps array entirely.
    it("should error on load with missing steps", function()
        expect_error(function()
            lurek.simulator.load("bad", {})
        end)
    end)

    -- @description Rejects steps whose action name is not part of the supported simulator action set.
    it("should error on load with unknown action", function()
        expect_error(function()
            lurek.simulator.load("bad_action", {
                steps = { { action = "explode", time = 0.0 } }
            })
        end)
    end)

    -- @description Rejects step tables that omit the mandatory action field.
    it("should error on load with missing action field", function()
        expect_error(function()
            lurek.simulator.load("no_action", {
                steps = { { time = 0.5 } }
            })
        end)
    end)
end)

-- @description Exercises parsing automation scripts from TOML strings for keyboard, mouse, and wait-only step sequences.
describe("lurek.simulator - TOML loading", function()
    -- @description Loads a TOML document containing keypress and keyrelease steps and verifies the resulting script can be started with the expected step count.
    it("should load from a TOML string", function()
        local toml = [=[
[meta]
name = "toml_demo"
description = "Loaded from TOML"

[[steps]]
action = "keypress"
key = "space"
time = 0.0

[[steps]]
action = "keyrelease"
key = "space"
time = 0.2
]=]
        lurek.simulator.loadFromToml("toml_demo", toml)
        expect_equal(lurek.simulator.hasScript("toml_demo"), true)
        lurek.simulator.start("toml_demo")
        expect_equal(lurek.simulator.getStepCount(), 2)
        lurek.simulator.stop()
        lurek.simulator.unload("toml_demo")
    end)

    -- @description Loads a TOML document containing mouse movement and press steps and verifies both steps are parsed into the runtime script.
    it("should load a TOML with mouse steps", function()
        local toml = [=[
[[steps]]
action = "mousemove"
x = 400.0
y = 300.0
dx = 0.0
dy = 0.0
time = 0.0

[[steps]]
action = "mousepress"
x = 400.0
y = 300.0
button = 1
time = 0.1
]=]
        lurek.simulator.loadFromToml("mouse_toml", toml)
        expect_equal(lurek.simulator.hasScript("mouse_toml"), true)
        lurek.simulator.start("mouse_toml")
        expect_equal(lurek.simulator.getStepCount(), 2)
        lurek.simulator.stop()
        lurek.simulator.unload("mouse_toml")
    end)

    -- @description Loads a TOML document composed only of timed wait steps and verifies all three entries are present after parsing.
    it("should load a TOML with wait steps", function()
        local toml = [=[
[[steps]]
action = "wait"
time = 0.0

[[steps]]
action = "wait"
time = 1.0

[[steps]]
action = "wait"
time = 2.0
]=]
        lurek.simulator.loadFromToml("wait_toml", toml)
        expect_equal(lurek.simulator.hasScript("wait_toml"), true)
        lurek.simulator.start("wait_toml")
        expect_equal(lurek.simulator.getStepCount(), 3)
        lurek.simulator.stop()
        lurek.simulator.unload("wait_toml")
    end)
end)

-- @description Stress-tests repeated lifecycle operations, multi-script registry behavior, script switching, and full mixed-input automation sequences.
describe("lurek.simulator - complex scenarios", function()
    -- @description Repeats start and stop operations on the same script to verify lifecycle state stays consistent through rapid cycling.
    it("should handle rapid start/stop cycling", function()
        lurek.simulator.load("cycle", {
            steps = { { action = "wait", time = 1.0 } }
        })
        for i = 1, 10 do
            lurek.simulator.start("cycle")
            expect_equal(lurek.simulator.isRunning(), true)
            lurek.simulator.stop()
            expect_equal(lurek.simulator.isRunning(), false)
        end
        lurek.simulator.unload("cycle")
    end)

    -- @description Repeats load and unload operations with unique script names to verify registry cleanup remains stable over multiple cycles.
    it("should handle load/unload cycling", function()
        for i = 1, 10 do
            local name = "cycle_" .. i
            lurek.simulator.load(name, {
                steps = { { action = "wait", time = 0.0 } }
            })
            expect_equal(lurek.simulator.hasScript(name), true)
            lurek.simulator.unload(name)
            expect_equal(lurek.simulator.hasScript(name), false)
        end
    end)

    -- @description Loads several scripts side by side and verifies the registry can hold all of them simultaneously before cleanup.
    it("should handle multiple scripts loaded simultaneously", function()
        for i = 1, 5 do
            lurek.simulator.load("multi_" .. i, {
                steps = { { action = "wait", time = 0.0 } }
            })
        end
        local scripts = lurek.simulator.getScripts()
        expect_equal(#scripts, 5)
        for i = 1, 5 do
            lurek.simulator.unload("multi_" .. i)
        end
    end)

    -- @description Starts one script, then another, to verify the active script pointer switches cleanly between loaded scripts.
    it("should handle switching between scripts", function()
        lurek.simulator.load("script_a", {
            steps = { { action = "keypress", key = "a", time = 0.0 } }
        })
        lurek.simulator.load("script_b", {
            steps = { { action = "keypress", key = "b", time = 0.0 } }
        })

        lurek.simulator.start("script_a")
        expect_equal(lurek.simulator.getCurrentScript(), "script_a")

        lurek.simulator.start("script_b")
        expect_equal(lurek.simulator.getCurrentScript(), "script_b")

        lurek.simulator.stop()
        lurek.simulator.unload("script_a")
        lurek.simulator.unload("script_b")
    end)

    -- @description Runs a mixed mouse, keyboard, text, and wait script end-to-end and verifies the simulator reaches completion with every step counted.
    it("should run a complete automation sequence", function()
        lurek.simulator.load("full_sequence", {
            steps = {
                { action = "mousemove", x = 200, y = 300, dx = 0, dy = 0, time = 0.0 },
                { action = "mousepress", x = 200, y = 300, button = 1, time = 0.1 },
                { action = "mouserelease", x = 200, y = 300, button = 1, time = 0.2 },
                { action = "keypress", key = "w", time = 0.5 },
                { action = "keyrelease", key = "w", time = 0.6 },
                { action = "textinput", text = "test", time = 1.0 },
                { action = "wait", time = 1.5 },
            },
            meta = { description = "Full integration test sequence" }
        })

        lurek.simulator.start("full_sequence")
        expect_equal(lurek.simulator.isRunning(), true)
        expect_equal(lurek.simulator.getStepCount(), 7)

        -- Run through the entire script
        lurek.simulator.update(2.0)
        expect_equal(lurek.simulator.isComplete(), true)
        expect_equal(lurek.simulator.getCurrentStep(), 7)

        lurek.simulator.stop()
        lurek.simulator.unload("full_sequence")
    end)

    -- @description Verifies steps without an explicit time default to zero and are dispatched immediately on the first update.
    it("should handle default time of zero", function()
        lurek.simulator.load("no_time", {
            steps = {
                { action = "keypress", key = "x" },
            }
        })
        lurek.simulator.start("no_time")
        lurek.simulator.update(0.01)
        expect_equal(lurek.simulator.isComplete(), true)
        lurek.simulator.stop()
        lurek.simulator.unload("no_time")
    end)
end)

test_summary()
