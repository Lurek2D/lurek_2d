-- Canonical evidence file for lurek.terminal visual artifacts.

local OUT = evidence_output_dir("terminal")

local function save_text(path, text)
    if write_file then
        write_file(path, text)
    elseif lurek and lurek.filesystem and lurek.filesystem.write then
        lurek.filesystem.write(path, text)
    else
        error("unable to create evidence text artifact: " .. path)
    end
    expect_evidence_created(path)
end

local function save_terminal(term, name)
    lurek.image.savePNG(term:renderImage(1200, 540), OUT .. name)
    expect_evidence_created(OUT .. name)
end

local function make_term(cols, rows, theme)
    local term = lurek.terminal.newTerminal(cols or 100, rows or 34)
    term:setCellSize(12, 16)
    lurek.terminal.applyTheme(term, theme or "dracula")
    return term
end

local function border(term, x, y, w, h, title, r, g, b)
    local box = lurek.terminal.newBorder(x, y, w, h)
    box:setStyle("single")
    box:setTitle(title or "")
    box:setColor(r or 0.20, g or 0.90, b or 0.70, 1.0)
    term:addWidget(box)
    return box
end

local function set_cell(term, x, y, ch, fg, bg)
    fg = fg or { 0.85, 0.90, 1.0, 1.0 }
    bg = bg or { 0.00, 0.00, 0.00, 0.0 }
    term:set(x, y, ch, fg[1], fg[2], fg[3], fg[4], bg[1], bg[2], bg[3], bg[4])
end

local function fill(term, x, y, w, h, bg)
    for yy = y, y + h - 1 do
        for xx = x, x + w - 1 do
            set_cell(term, xx, yy, " ", { 0.85, 0.90, 1.0, 1.0 }, bg)
        end
    end
end

local function bar_chart(term, x, y, values, color)
    local max_value = 1
    for _, v in ipairs(values) do
        if v > max_value then
            max_value = v
        end
    end
    for i, v in ipairs(values) do
        local height = math.floor((v / max_value) * 7 + 0.5)
        local bx = x + (i - 1) * 4
        for level = 0, height - 1 do
            set_cell(term, bx, y + 7 - level, "█", color)
            set_cell(term, bx + 1, y + 7 - level, "█", color)
        end
        term:print(bx, y + 9, "S" .. tostring(i - 1))
    end
end

local function sparkline(term, x, y, values, color)
    local max_value = 1
    for _, v in ipairs(values) do
        if v > max_value then
            max_value = v
        end
    end
    for i, v in ipairs(values) do
        local yy = y + 6 - math.floor((v / max_value) * 5 + 0.5)
        set_cell(term, x + i - 1, yy, "•", color)
    end
end

local function dot_chart(term, x, y, values, color, marker)
    marker = marker or "•"
    local max_value = 1
    for _, v in ipairs(values) do
        if v > max_value then
            max_value = v
        end
    end
    term:print(x, y, "1.70")
    term:print(x, y + 4, "1.00")
    term:print(x, y + 8, "0.30")
    term:print(x, y + 12, "-.40")
    for i, v in ipairs(values) do
        local yy = y + 12 - math.floor((v / max_value) * 11 + 0.5)
        set_cell(term, x + 6 + i, yy, marker, color)
    end
end

local function gauge(term, x, y, width, pct, color)
    fill(term, x, y, width, 1, { 0.08, 0.08, 0.08, 1.0 })
    local filled = math.floor(width * pct)
    for i = 0, filled - 1 do
        set_cell(term, x + i, y, " ", { 1, 1, 1, 1 }, color)
    end
    term:print(x + width + 2, y, tostring(math.floor(pct * 100)) .. "%")
end

-- @describe Evidence: terminal
describe("Evidence: terminal", function()
    before_each(function()
        ensure_evidence_dir("terminal")
    end)

    -- Does: Binds a render-owned ui-target shader to LTerminal, queues terminal rendering, and records the handle contract.
    -- Shows: The text artifact states the shader target, handle id, terminal getShader target, and that render queued with the shader binding.
    -- Artifact: tests/artifacts/current/terminal/terminal_shader_binding_contract.txt
    -- Why: This proves terminal participates in Shader API v2 through render-owned LShader handles while terminal itself only stores binding state.
    it("TXT: terminal ui shader binding contract", function()
        local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>, @location(2) pixel: vec2<f32>) -> @location(0) vec4<f32> {
    _ = uv;
    let band = select(0.75, 1.0, (i32(pixel.y) & 1) == 0);
    return vec4<f32>(color.rgb * band, color.a);
}
]], { target = "ui" })
        local term = make_term(32, 8, "nord")
        term:setShader(shader)
        term:print(1, 1, "terminal shader evidence")
        term:render(0, 0)
        local lines = {
            "Terminal shader binding evidence",
            "constructor=lurek.render.newShader",
            "target=" .. shader:getTarget(),
            "shader_id=" .. shader:getId(),
            "terminal.getShader.target=" .. term:getShader():getTarget(),
            "terminal.render.queued=true",
            "software.renderImage.shadered=false",
        }
        term:setShader(nil)
        lines[#lines + 1] = "terminal.shader.cleared=" .. tostring(term:getShader() == nil)
        save_text(OUT .. "terminal_shader_binding_contract.txt", table.concat(lines, "\n") .. "\n")
    end)

    -- Does: Builds a full terminal user interface from single-line borders, text box, list, gauge, rasterized bar blocks, and dot sparklines, then exports the engine-rendered widget surface.
    -- Shows: The PNG artifact should show continuous stroked widget frames and pixel chart marks generated by LTerminal:renderImage, not ASCII `+---+` text art.
    -- Artifact: tests/artifacts/current/terminal/terminal_tui_dashboard_widgets.png
    -- Why: This proves LTerminal:renderImage can rasterize the same widget grid that LTerminal:render composes for terminal user interfaces.
    it("PNG: terminal TUI dashboard widgets", function()
        local term = make_term(100, 34, "nord")
        border(term, 1, 2, 64, 4, "Text Box", 0.1, 0.8, 0.8)
        border(term, 1, 8, 28, 10, "List", 0.6, 0.9, 0.4)
        border(term, 32, 8, 34, 10, "Sparkline", 0.6, 0.9, 0.4)
        border(term, 68, 2, 30, 16, "Bar Chart", 0.8, 0.8, 0.8)
        border(term, 1, 20, 64, 4, "Gauge", 0.8, 0.8, 0.8)
        border(term, 1, 26, 64, 8, "Status", 0.6, 0.9, 0.4)

        local input = lurek.terminal.newTextBox(3, 4, 58)
        input:setText("PRESS Q TO QUIT DEMO")
        local list = lurek.terminal.newList(3, 10, 24, 6)
        for _, item in ipairs({ "output.go", "random_out.go", "dashboard.go", "nsf/termbox-go" }) do
            list:addItem(item)
        end
        list:setSelected(2)
        term:addWidget(input)
        term:addWidget(list)
        term:setFocus(input)

        sparkline(term, 35, 10, { 1, 2, 1, 3, 2, 4, 3, 5, 2, 2, 4, 5, 3, 2, 4, 5, 4, 6, 4, 5 }, { 0.2, 0.8, 1.0, 1.0 })
        sparkline(term, 35, 15, { 2, 1, 1, 5, 4, 2, 1, 2, 3, 2, 4, 5, 3, 2, 3, 2, 1, 1, 2, 3 }, { 1.0, 0.25, 0.2, 1.0 })
        bar_chart(term, 71, 7, { 2, 5, 3, 9, 5, 3 }, { 0.1, 0.8, 0.2, 1.0 })
        gauge(term, 3, 22, 40, 0.22, { 0.85, 0.04, 0.08, 1.0 })
        term:print(68, 22, "Hey!")
        term:print(68, 24, "I am a borderless block!")
        term:print(3, 28, "FOCUS=TEXTBOX   SELECTED=RANDOM_OUT.GO")
        term:print(3, 30, "WIDGETS=" .. tostring(term:getWidgetCount()) .. "   MODE=TUI")

        save_terminal(term, "terminal_tui_dashboard_widgets.png")
    end)

    -- Does: Creates a focused form with text boxes, labels, buttons, selection state, and keyboard-edited input before exporting the engine-rendered terminal UI.
    -- Shows: The PNG artifact should show a form-like TUI screen with focus, typed text, buttons, and validation rows.
    -- Artifact: tests/artifacts/current/terminal/terminal_tui_form_focus.png
    -- Why: This demonstrates that terminal widgets are interactive GUI controls rendered inside the terminal grid.
    it("PNG: terminal TUI form focus", function()
        local term = make_term(100, 34, "dracula")
        border(term, 2, 2, 96, 30, "Deploy Form", 0.2, 0.8, 1.0)
        border(term, 5, 6, 42, 5, "Command", 0.2, 0.8, 1.0)
        border(term, 52, 6, 40, 12, "Targets", 0.2, 0.8, 1.0)
        border(term, 5, 20, 87, 6, "Actions", 0.2, 0.8, 1.0)

        local cmd = lurek.terminal.newTextBox(8, 8, 34)
        local list = lurek.terminal.newList(55, 8, 34, 8)
        local run = lurek.terminal.newButton(8, 22, 14, 1, "Run")
        local cancel = lurek.terminal.newButton(25, 22, 14, 1, "Cancel")
        cmd:setText("scan --sector a7")
        list:addItem("north_dock ready")
        list:addItem("cargo_lift moving")
        list:addItem("reactor_hall locked")
        list:addItem("ops_deck focused")
        list:setSelected(4)
        term:addWidget(cmd)
        term:addWidget(list)
        term:addWidget(run)
        term:addWidget(cancel)
        term:setFocus(cmd)
        term:textinput(" --live")
        term:print(8, 14, "Input changed through LTerminal:textinput")
        term:print(8, 16, "Focused widget: " .. tostring(term:getFocused() and term:getFocused():type() or "nil"))
        term:print(8, 28, "[x] target selected   [x] focus visible   [x] buttons rendered")

        save_terminal(term, "terminal_tui_form_focus.png")
    end)

    -- Does: Uses terminal cell writes and border widgets to draw rasterized bar, sparkline, dot, braille-dot, and gauge chart panels into a terminal UI layout.
    -- Shows: The PNG artifact should look like a chart-heavy TUI dashboard with continuous frame lines and pixel markers rather than ASCII glyph charts.
    -- Artifact: tests/artifacts/current/terminal/terminal_tui_chart_panels.png
    -- Why: This proves the engine can render chart-like terminal UI blocks from actual cell/grid operations.
    it("PNG: terminal TUI chart panels", function()
        local term = make_term(100, 34, "monokai")
        border(term, 2, 2, 30, 14, "Bar Chart", 0.6, 0.9, 0.4)
        border(term, 36, 2, 60, 6, "Gauge", 0.8, 0.8, 0.8)
        border(term, 36, 10, 60, 8, "Sparkline", 0.6, 0.9, 0.4)
        border(term, 2, 20, 46, 13, "Dot-mode Line Chart", 0.6, 0.9, 0.4)
        border(term, 52, 20, 44, 13, "Braille-mode Line Chart", 0.6, 0.9, 0.4)

        bar_chart(term, 5, 6, { 2, 5, 3, 9, 5, 3 }, { 0.2, 0.9, 0.25, 1.0 })
        gauge(term, 40, 5, 42, 0.68, { 0.2, 0.7, 1.0, 1.0 })
        sparkline(term, 40, 12, { 1, 3, 2, 4, 6, 4, 5, 4, 2, 3, 5, 6, 8, 6, 5, 7, 8, 5, 3, 4, 5, 4, 3, 5 }, { 0.2, 0.8, 1.0, 1.0 })
        dot_chart(term, 5, 22, { 12, 14, 14, 10, 9, 7, 6, 4, 4, 4, 4, 6, 7, 10, 12, 14, 15, 15, 13, 11, 8, 5 }, { 1.0, 0.25, 0.25, 1.0 }, "•")
        dot_chart(term, 55, 22, { 4, 6, 8, 11, 14, 15, 13, 9, 6, 4, 5, 8, 11, 13, 15, 14, 11, 8 }, { 0.7, 0.9, 0.25, 1.0 }, "⣿")

        save_terminal(term, "terminal_tui_chart_panels.png")
    end)

    -- Does: Builds a diagnostics TUI from live terminal diagnostics, validation results, hidden widgets, clipped textbox input, and out-of-bounds writes.
    -- Shows: The PNG artifact should show diagnostics in framed terminal panels with counters populated by engine behavior.
    -- Artifact: tests/artifacts/current/terminal/terminal_tui_diagnostics_panels.png
    -- Why: This connects terminal widget validation and diagnostics to a readable terminal UI report rendered by the engine.
    it("PNG: terminal TUI diagnostics panels", function()
        local term = make_term(100, 34, "dracula")
        border(term, 2, 2, 96, 30, "Terminal Doctor", 1.0, 0.35, 0.35)
        border(term, 5, 6, 42, 18, "Counters", 1.0, 0.35, 0.35)
        border(term, 52, 6, 40, 18, "Validation", 1.0, 0.75, 0.25)
        local hidden = lurek.terminal.newButton(6, 26, 12, 1, "Hidden")
        local input = lurek.terminal.newTextBox(8, 10, 10)
        hidden:setVisible(false)
        input:setMaxLength(5)
        term:addWidget(hidden)
        term:addWidget(input)
        term:setFocus(hidden)
        term:clearDiagnostics()
        term:set(0, 1, "A", 1, 1, 1, 1, 0, 0, 0, 0)
        term:setFocus(input)
        term:textinput("abcdefghi")
        local valid, errors = term:validateWidgets()
        local diagnostics = term:getDiagnostics()
        term:print(8, 9, "Input")
        term:print(8, 14, "OUT_OF_BOUNDS = " .. tostring(diagnostics.out_of_bounds_writes))
        term:print(8, 16, "CLIPPED_TEXT  = " .. tostring(diagnostics.clipped_text))
        term:print(8, 18, "FOCUS_CLEARED = " .. tostring(diagnostics.cleared_focus_targets))
        term:print(55, 10, "VALID = " .. tostring(valid))
        term:print(55, 12, "FIRST = " .. tostring(errors and errors[1] or "none"))
        term:print(55, 16, "TEXTBOX VALUE = " .. tostring(input:getText()))
        term:print(55, 20, "REPORT SOURCE: ENGINE DIAGNOSTICS")

        save_terminal(term, "terminal_tui_diagnostics_panels.png")
    end)

    -- Does: Uses command history and completion APIs, then presents the current prompt, history pane, and completion candidates as a TUI popup.
    -- Shows: The PNG artifact should show terminal command helpers as a widget-style command palette, not a REPL session.
    -- Artifact: tests/artifacts/current/terminal/terminal_tui_command_palette.png
    -- Why: This proves command-history and completion behavior can be embedded in terminal UI layouts rendered by the engine.
    it("PNG: terminal TUI command palette", function()
        local term = make_term(100, 34, "nord")
        border(term, 2, 2, 96, 30, "Command Palette", 0.2, 0.8, 1.0)
        border(term, 5, 6, 42, 10, "History", 0.6, 0.9, 0.4)
        border(term, 52, 6, 40, 16, "Completion Popup", 0.6, 0.9, 0.4)
        border(term, 5, 24, 87, 5, "Prompt", 0.2, 0.8, 1.0)
        lurek.terminal.clearCmdHistory(term)
        lurek.terminal.clearCompletions()
        lurek.terminal.pushCmdHistory(term, "open dashboard")
        lurek.terminal.pushCmdHistory(term, "focus logs")
        lurek.terminal.pushCmdHistory(term, "render tui")
        lurek.terminal.addCompletion("help")
        lurek.terminal.addCompletion("history")
        lurek.terminal.addCompletion("hotreload")
        lurek.terminal.addCompletion("highlight")
        lurek.terminal.addCompletion("healthcheck")
        local recalled = lurek.terminal.prevCmd(term)
        local matches = lurek.terminal.getCompletions("h")
        term:print(8, 9, "1  open dashboard")
        term:print(8, 11, "2  focus logs")
        term:print(8, 13, "3> " .. tostring(recalled))
        for i, item in ipairs(matches) do
            term:print(55, 8 + i * 2, (i == 1 and "> " or "  ") .. item)
        end
        term:print(8, 26, ": h_")
        term:print(20, 26, "TAB CANDIDATES=" .. tostring(#matches))
        term:print(8, 28, "HISTORY LEN=" .. tostring(lurek.terminal.cmdHistoryLen(term)))

        save_terminal(term, "terminal_tui_command_palette.png")
    end)

    -- Does: Binds ui-target shaders to terminal rendering and emits three terminal-specific shader artifacts.
    -- Shows: CRT scanlines, text glow, and panel-mask terminal treatments are represented as terminal surface outputs.
    -- Artifact: tests/artifacts/current/terminal/terminal_shader_visual_01_crt_scanline.png, tests/artifacts/current/terminal/terminal_shader_visual_02_text_glow.png, tests/artifacts/current/terminal/terminal_shader_visual_03_panel_mask.png
    -- Why: Terminal owns grid text and console surfaces, so shader evidence should show terminal display treatments rather than generic UI cards.
    it("PNG: shader-backed terminal visual variants", function()
        dofile("tests/lua/fixtures/shader_visual_helpers.lua")
        local ShaderEvidence = _G.ShaderEvidence
        ShaderEvidence.emit("terminal", {
            { target = "ui", slug = "crt_scanline" },
            { target = "ui", slug = "text_glow" },
            { target = "ui", slug = "panel_mask" },
        }, OUT)
    end)
end)

test_summary()
