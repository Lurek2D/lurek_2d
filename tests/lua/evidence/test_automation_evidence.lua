-- Canonical evidence file for lurek.automation artifacts.
-- @covers lurek.automation.getCondition
-- @covers lurek.automation.getCurrentScript
-- @covers lurek.automation.getCurrentStep
-- @covers lurek.automation.getElapsedTime
-- @covers lurek.automation.getPlaybackSpeed
-- @covers lurek.automation.getScripts
-- @covers lurek.automation.getStepCount
-- @covers lurek.automation.getStepLimit
-- @covers lurek.automation.hasMacro
-- @covers lurek.automation.isComplete
-- @covers lurek.automation.isHighlightMode
-- @covers lurek.automation.isPaused
-- @covers lurek.automation.isRunning
-- @covers lurek.automation.listMacros
-- @covers lurek.automation.load
-- @covers lurek.automation.pause
-- @covers lurek.automation.playMacro
-- @covers lurek.automation.resume
-- @covers lurek.automation.saveMacro
-- @covers lurek.automation.setCondition
-- @covers lurek.automation.setHighlightMode
-- @covers lurek.automation.setPlaybackSpeed
-- @covers lurek.automation.setStepLimit
-- @covers lurek.automation.start
-- @covers lurek.automation.stop
-- @covers lurek.automation.unload
-- @covers lurek.automation.update
-- @covers lurek.automation.waitUntil
-- @covers lurek.filesystem.write


local OUT = evidence_output_dir("automation")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function reset_automation()
    lurek.automation.stop()
    lurek.automation.setPlaybackSpeed(1.0)
    lurek.automation.setHighlightMode(false)
    for _, name in ipairs(lurek.automation.getScripts()) do
        lurek.automation.unload(name)
    end
    lurek.automation.setCondition("evidence_ready", false)
    lurek.automation.setCondition("evidence_phase2", false)
end

local function load_wait_script(name, times)
    local steps = {}
    for _, t in ipairs(times) do
        steps[#steps + 1] = { action = "wait", time = t }
    end
    lurek.automation.load(name, { steps = steps })
end

-- @describe Evidence: automation
describe("Evidence: automation", function()
    before_each(function()
        ensure_evidence_dir("automation")
        reset_automation()
    end)

    after_each(reset_automation)

    -- Does: Runs one deterministic automation script through load, start, update, pause, resume, and completion while recording step and elapsed-time state.
    -- Shows: The TXT artifact should let a reviewer inspect how the active script advances frame by frame instead of only seeing a boolean pass/fail.
    -- Artifact: tests/artifacts/current/automation/automation_timeline_trace.txt
    -- Why: This is meaningful because every line comes from live lurek.automation playback state, not from a handwritten expected transcript.
    it("TXT: automation playback timeline trace", function()
        load_wait_script("timeline_trace", { 0.0, 0.15, 0.10 })
        lurek.automation.start("timeline_trace")

        local lines = {
            "current_script=" .. tostring(lurek.automation.getCurrentScript()),
            "step_count=" .. tostring(lurek.automation.getStepCount()),
            "running_initial=" .. tostring(lurek.automation.isRunning()),
        }

        local deltas = { 0.00, 0.08, 0.10, 0.12 }
        for i, dt in ipairs(deltas) do
            if i == 2 then
                lurek.automation.pause()
                lines[#lines + 1] = "paused_before_update=" .. tostring(lurek.automation.isPaused())
            end
            if i == 3 then
                lurek.automation.resume()
                lines[#lines + 1] = "paused_after_resume=" .. tostring(lurek.automation.isPaused())
            end

            lurek.automation.update(dt)
            lines[#lines + 1] = string.format(
                "tick_%d dt=%.2f step=%s elapsed=%.3f running=%s complete=%s",
                i,
                dt,
                tostring(lurek.automation.getCurrentStep()),
                tonumber(lurek.automation.getElapsedTime()) or 0.0,
                tostring(lurek.automation.isRunning()),
                tostring(lurek.automation.isComplete())
            )
        end

        write_text(OUT .. "automation_timeline_trace.txt", table.concat(lines, "\n") .. "\n")
    end)

    -- Does: Uses conditions and waitUntil gating to hold a script in place, then releases it and records the transition.
    -- Shows: The TXT artifact should make the gating behavior legible by showing the frozen step index before release and the resumed state afterwards.
    -- Artifact: tests/artifacts/current/automation/automation_condition_gate_trace.txt
    -- Why: This is meaningful because the artifact comes from the public condition and waitUntil APIs coordinating actual playback state.
    it("TXT: automation condition gate trace", function()
        load_wait_script("condition_gate", { 0.01, 0.01 })
        lurek.automation.start("condition_gate")
        lurek.automation.waitUntil(function()
            return lurek.automation.getCondition("evidence_ready")
        end, 1.0)

        lurek.automation.update(0.30)
        local before_release = {
            "ready_before=" .. tostring(lurek.automation.getCondition("evidence_ready")),
            "step_before=" .. tostring(lurek.automation.getCurrentStep()),
            "elapsed_before=" .. tostring(lurek.automation.getElapsedTime()),
            "running_before=" .. tostring(lurek.automation.isRunning()),
        }

        lurek.automation.setCondition("evidence_ready", true)
        lurek.automation.update(0.02)
        lurek.automation.update(0.02)

        local after_release = {
            "ready_after=" .. tostring(lurek.automation.getCondition("evidence_ready")),
            "step_after=" .. tostring(lurek.automation.getCurrentStep()),
            "elapsed_after=" .. tostring(lurek.automation.getElapsedTime()),
            "complete_after=" .. tostring(lurek.automation.isComplete()),
        }

        write_text(
            OUT .. "automation_condition_gate_trace.txt",
            table.concat(before_release, "\n") .. "\n" .. table.concat(after_release, "\n") .. "\n"
        )
    end)

    -- Does: Saves a script as a macro, applies playback controls, launches the macro, and serializes the resulting control state.
    -- Shows: The TXT artifact should show that macro persistence, speed control, highlight mode, and step limits all belong to one coherent automation control surface.
    -- Artifact: tests/artifacts/current/automation/automation_macro_control_trace.txt
    -- Why: This is meaningful because the snapshot is assembled from the macro and playback APIs that a reviewer would use when driving automation for real.
    it("TXT: automation macro and control trace", function()
        load_wait_script("macro_source", { 0.05, 0.05 })
        lurek.automation.setStepLimit("macro_source", 12)
        lurek.automation.saveMacro("macro_probe", "macro_source")
        lurek.automation.setPlaybackSpeed(1.75)
        lurek.automation.setHighlightMode(true)
        lurek.automation.playMacro("macro_probe")
        lurek.automation.update(0.03)

        local macros = lurek.automation.listMacros()
        local lines = {
            "macro_count=" .. tostring(#macros),
            "has_macro_probe=" .. tostring(lurek.automation.hasMacro("macro_probe")),
            "current_script=" .. tostring(lurek.automation.getCurrentScript()),
            "step_limit=" .. tostring(lurek.automation.getStepLimit("macro_source")),
            "playback_speed=" .. tostring(lurek.automation.getPlaybackSpeed()),
            "highlight_mode=" .. tostring(lurek.automation.isHighlightMode()),
            "running=" .. tostring(lurek.automation.isRunning()),
            "current_step=" .. tostring(lurek.automation.getCurrentStep()),
        }

        write_text(OUT .. "automation_macro_control_trace.txt", table.concat(lines, "\n") .. "\n")
    end)
end)

test_summary()
