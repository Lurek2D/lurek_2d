-- Canonical evidence file for lurek.terminal artifacts.

local OUT = evidence_output_dir("terminal")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function click_cell(term, col, row, button)
    local cell_w, cell_h = term:getCellSize()
    term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
end

local function make_console(cols, rows)
    local term = lurek.terminal.newTerminal(cols or 40, rows or 12)
    lurek.terminal.applyTheme(term, "nord")
    term:print(1, 1, "> diagnostics")
    term:print(1, 2, "bridge online")
    return term
end

-- @describe Evidence: terminal
describe("Evidence: terminal", function()
    before_each(function()
        ensure_evidence_dir("terminal")
    end)

    -- Does: Builds one terminal dashboard with widgets, focus, command history, scrollback, and render stats, then serializes the resulting state.
    -- Shows: The TXT artifact should make the composed terminal UI reviewable without needing to run an interactive console by hand.
    -- Artifact: tests/artifacts/current/terminal/terminal_console_snapshot.txt
    -- Why: This is meaningful because the snapshot is assembled from live terminal/widget state after using the public creation, focus, history, and render APIs.
    it("TXT: terminal console snapshot", function()
        local term = make_console(48, 16)
        local panel = lurek.terminal.newPanel(1, 4, 24, 8)
        local title = lurek.terminal.newLabel(2, 1, "Bridge Status")
        local button = lurek.terminal.newButton(2, 3, 12, 1, "Open Door")
        local input = lurek.terminal.newTextBox(2, 6, 18)
        local list = lurek.terminal.newList(28, 4, 16, 5)

        list:addItem("North Dock")
        list:addItem("Cargo Lift")
        list:addItem("Ops Deck")
        list:setSelected(2)
        panel:addChild(title)
        term:addWidget(panel)
        term:addWidget(button)
        term:addWidget(input)
        term:addWidget(list)

        term:setFocus(input)
        term:textinput("status --full")
        click_cell(term, 28, 5, 1)
        lurek.terminal.pushCmdHistory(term, "help")
        lurek.terminal.tryPushCmdHistory(term, "status --full")
        lurek.terminal.pushScrollback(term, "[ok] debug bridge online")
        lurek.terminal.tryPushScrollback(term, "[warn] camera drift")
        term:render()

        local stats = term:getRenderStats()
        local focused = term:getFocused()
        local scrollback = lurek.terminal.getScrollback(term, 0, 4)
        local last_history = lurek.terminal.prevCmd(term)
        local lines = {
            "widget_count=" .. tostring(term:getWidgetCount()),
            "focused_type=" .. tostring(focused and focused:type() or "nil"),
            "input_text=" .. tostring(input:getText()),
            "list_selected=" .. tostring(list:getSelected()),
            "list_item=" .. tostring(list:getItem(list:getSelected())),
            "cmd_history_len=" .. tostring(lurek.terminal.cmdHistoryLen(term)),
            "cmd_history_last=" .. tostring(last_history),
            "scrollback_len=" .. tostring(lurek.terminal.scrollbackLen(term)),
            "scrollback_latest=" .. tostring(scrollback[1]),
            "render_cells=" .. tostring(stats.cells_composed),
            "render_widgets=" .. tostring(stats.widgets_drawn),
            "render_list_items=" .. tostring(stats.list_items_drawn),
        }

        write_text(OUT .. "terminal_console_snapshot.txt", table.concat(lines, "\n") .. "\n")
    end)

    -- Does: Forces one terminal into out-of-bounds writes, clipped text, invalid focus, and widget-graph issues, then records diagnostics and validation output.
    -- Shows: The TXT artifact should give a reviewer a concrete terminal failure report instead of an opaque pass/fail result.
    -- Artifact: tests/artifacts/current/terminal/terminal_diagnostics_trace.txt
    -- Why: This is meaningful because the trace is emitted directly from terminal diagnostics and validation APIs after constructing a broken widget graph on purpose.
    it("TXT: terminal diagnostics and validation trace", function()
        local term = lurek.terminal.newTerminal(20, 10)
        local panel_a = lurek.terminal.newPanel(1, 1, 10, 4)
        local panel_b = lurek.terminal.newPanel(2, 2, 8, 3)
        local hidden = lurek.terminal.newButton(1, 5, 8, 1, "Hidden")
        local input = lurek.terminal.newTextBox(1, 8, 5)

        input:setMaxLength(3)
        hidden:setVisible(false)

        term:addWidget(panel_a)
        term:addWidget(panel_b)
        term:addWidget(hidden)
        term:addWidget(input)
        term:setFocus(hidden)
        panel_a:addChild(panel_b)
        pcall(function()
            panel_b:addChild(panel_a)
        end)

        term:clearDiagnostics()
        term:set(0, 1, "A", 1, 1, 1, 1, 0, 0, 0, 0)
        term:setFocus(input)
        term:textinput("abcdef")

        local diagnostics = term:getDiagnostics()
        local valid, errors = term:validateWidgets()
        local first_error = errors and errors[1] or "none"
        local lines = {
            "out_of_bounds_writes=" .. tostring(diagnostics.out_of_bounds_writes),
            "clipped_text=" .. tostring(diagnostics.clipped_text),
            "valid=" .. tostring(valid),
            "error_count=" .. tostring(errors and #errors or 0),
            "first_error=" .. tostring(first_error),
        }

        write_text(OUT .. "terminal_diagnostics_trace.txt", table.concat(lines, "\n") .. "\n")
    end)
end)

test_summary()
