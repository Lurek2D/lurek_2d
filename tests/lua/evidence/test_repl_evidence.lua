-- Canonical evidence file for lurek.repl visual artifacts.

dofile("tests/lua/fixtures/terminal_visual_helpers.lua")

local OUT = evidence_output_dir("repl")

local function save_screen(name, title, lines)
    terminal_visual.save(OUT .. name, {
        title = title,
        lines = lines,
        footer = "MODULE: LUREK.REPL  ARTIFACT: " .. name,
    })
    expect_evidence_created(OUT .. name)
end

local function input(text)
    return { text = "REPL> " .. text, color = "prompt" }
end

local function out(text, color)
    return { text = tostring(text), color = color or "text", indent = 24 }
end

local function first_match(items, expected)
    for _, item in ipairs(items) do
        if item == expected then
            return item
        end
    end
    return items[1] or "<none>"
end

-- @describe Evidence: repl
describe("Evidence: repl", function()
    before_each(function()
        ensure_evidence_dir("repl")
    end)

    -- Does: Evaluates expressions and statements in one REPL session, then renders the prompt/output transcript as a terminal UI.
    -- Shows: The PNG artifact should look like an interactive REPL console with evaluated values, stored globals, and prompts.
    -- Artifact: tests/artifacts/current/repl/repl_eval_session_ui.png
    -- Why: This proves the REPL eval path and history recording create reviewable interactive session output.
    it("PNG: repl eval session UI", function()
        local repl = lurek.repl.new(12)
        local out1 = repl:eval("2 + 2")
        local out2 = repl:eval("answer = 41")
        local out3 = repl:eval("answer + 1")
        save_screen("repl_eval_session_ui.png", "LUREK REPL - EVAL SESSION", {
            input("2 + 2"),
            out(out1, "ok"),
            input("answer = 41"),
            out(out2, "ok"),
            input("answer + 1"),
            out(out3, "ok"),
            out("HISTORY ENTRIES: " .. tostring(repl:len()), "dim"),
            input("_"),
        })
    end)

    -- Does: Runs REPL control commands for help, clear, reset, and quit, then displays command results in a control terminal.
    -- Shows: The PNG artifact should expose REPL command handling rather than only expression evaluation.
    -- Artifact: tests/artifacts/current/repl/repl_commands_ui.png
    -- Why: This captures the command vocabulary from the module spec in a UI shape that looks like a real REPL.
    it("PNG: repl control commands UI", function()
        local repl = lurek.repl.new(16)
        local help = repl:eval(":help")
        local clear = repl:eval(":clear")
        repl:eval("scratch_value = 99")
        local reset = repl:eval(":reset")
        local quit = repl:eval(":quit")
        save_screen("repl_commands_ui.png", "LUREK REPL - CONTROL COMMANDS", {
            input(":help"),
            out(help:gsub("\n", " | "):sub(1, 82), "accent"),
            input(":clear"),
            out(clear, "warn"),
            input(":reset"),
            out(reset, "warn"),
            input(":quit"),
            out(quit, "warn"),
            input("_"),
        })
    end)

    -- Does: Creates a runtime symbol, queries completions for built-in and dynamic prefixes, and renders the suggestions as a REPL popup.
    -- Shows: The PNG artifact should show autocomplete candidates anchored to a REPL prompt.
    -- Artifact: tests/artifacts/current/repl/repl_completion_ui.png
    -- Why: This makes REPL completion behavior visible and tied to live session symbols.
    it("PNG: repl completion UI", function()
        local repl = lurek.repl.new(12)
        repl:eval("custom_runtime_symbol = 7")
        local builtin = repl:complete("lurek.re")
        local dynamic = repl:complete("custom_run")
        save_screen("repl_completion_ui.png", "LUREK REPL - COMPLETION POPUP", {
            input("custom_runtime_symbol = 7"),
            out("(ok)", "ok"),
            input("lurek.re<TAB>"),
            out("> " .. first_match(builtin, "lurek.repl"), "ok"),
            input("custom_run<TAB>"),
            out("> " .. first_match(dynamic, "custom_runtime_symbol"), "ok"),
            out("BUILTIN MATCHES=" .. tostring(#builtin) .. " DYNAMIC MATCHES=" .. tostring(#dynamic), "dim"),
            input("_"),
        })
    end)

    -- Does: Fills a bounded REPL history, proves oldest entries drop, and renders the retained commands as a history pane.
    -- Shows: The PNG artifact should show current history contents and bounded capacity semantics.
    -- Artifact: tests/artifacts/current/repl/repl_history_ui.png
    -- Why: This turns the REPL history buffer into a visible terminal-side review artifact.
    it("PNG: repl bounded history UI", function()
        local repl = lurek.repl.new(5)
        for i = 1, 8 do
            repl:eval("value_" .. tostring(i) .. " = " .. tostring(i))
        end
        local lines = {
            input("FOR I=1,8 DO EVAL('VALUE_'..I) END"),
            out("CAPACITY=5 RETAINED=" .. tostring(repl:len()), "warn"),
            { text = "+--------------- HISTORY PANE ---------------+", color = "accent" },
        }
        for i, item in ipairs(repl:history()) do
            lines[#lines + 1] = out(string.format("%02d  %s", i, item), "text")
        end
        lines[#lines + 1] = input("_")
        save_screen("repl_history_ui.png", "LUREK REPL - BOUNDED HISTORY", lines)
    end)

    -- Does: Runs failing REPL input, a failing load command, and a successful expression afterward to prove recovery.
    -- Shows: The PNG artifact should look like a REPL error console with red error rows and a green recovery result.
    -- Artifact: tests/artifacts/current/repl/repl_error_recovery_ui.png
    -- Why: This documents REPL failure reporting and continued session usability in one visual artifact.
    it("PNG: repl error recovery UI", function()
        local repl = lurek.repl.new(12)
        local err1 = repl:eval("return )")
        local err2 = repl:eval(":load __missing_repl_evidence_file__.lua")
        local ok = repl:eval("10 * 3")
        save_screen("repl_error_recovery_ui.png", "LUREK REPL - ERROR RECOVERY", {
            input("return )"),
            out(err1:sub(1, 82), "error"),
            input(":load __missing_repl_evidence_file__.lua"),
            out(err2:sub(1, 82), "error"),
            input("10 * 3"),
            out(ok, "ok"),
            out("SESSION RECOVERED; HISTORY ENTRIES=" .. tostring(repl:len()), "dim"),
            input("_"),
        })
    end)
end)

test_summary()
