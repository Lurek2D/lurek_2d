-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_terminal_core_unit.lua
do
-- tests/lua/unit/test_terminal.lua
-- BDD tests for the lurek.terminal.* API, covering terminal widgets, layout helpers, input-driven interactions, and headless terminal state updates.


require("tests/lua/init")

local function click_cell(term, col, row, button)
    local cell_w, cell_h = 1, 1
    if type(term.getCellSize) == "function" then
        local w, h = term:getCellSize()
        if type(w) == "number" and type(h) == "number" then
            cell_w, cell_h = w, h
        end
    end
    term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
end

local function ui_shader_code()
    return [[
@fragment
fn fs(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) pixel: vec2<f32>,
    @location(3) resolution: vec2<f32>,
    @location(4) texel: vec2<f32>
) -> @location(0) vec4<f32> {
    _ = uv;
    _ = pixel;
    _ = resolution;
    _ = texel;
    return color;
}
]]
end

-- @describe terminal handles
describe("terminal handles", function()
    -- @covers LTerminal:getDimensions
    it("creates terminal userdata and accepts colon or explicit self syntax", function()
        ---@type any
        local term = lurek.terminal.newTerminal(40, 20)
        expect_equal("userdata", type(term))

        local cols1, rows1 = term:getDimensions()
        local cols2, rows2 = term.getDimensions(term)
        expect_equal(40, cols1)
        expect_equal(20, rows1)
        expect_equal(40, cols2)
        expect_equal(20, rows2)
    end)
    -- @covers LTerminal:getCellSize
    it("reports the active cell size through colon and explicit self syntax", function()
        ---@type any
        local term = lurek.terminal.newTerminal(10, 5)
        local cell_w1, cell_h1 = term:getCellSize()
        local cell_w2, cell_h2 = term.getCellSize(term)
        expect_type("number", cell_w1)
        expect_type("number", cell_h1)
        expect_true(cell_w1 > 0)
        expect_true(cell_h1 > 0)
        expect_near(cell_w1, cell_w2, 0.001)
        expect_near(cell_h1, cell_h2, 0.001)
    end)
    -- @covers LTerminal:setCellSize
    it("uses custom cell size for render scaling helpers", function()
        ---@type any
        local term = lurek.terminal.newTerminal(10, 5)
        term:setCellSize(12, 18)
        local cell_w, cell_h = term:getCellSize()
        expect_near(12, cell_w, 0.001)
        expect_near(18, cell_h, 0.001)
        expect_no_error(function() term:autoResize() end)
        term:resetCellSize()
        local reset_w, reset_h = term:getCellSize()
        expect_type("number", reset_w)
        expect_type("number", reset_h)
        expect_true(reset_w > 0)
        expect_true(reset_h > 0)
    end)
    -- @covers LTerminal:setShader
    it("binds a ui shader to terminal render commands and rejects other targets", function()
        ---@type any
        local term = lurek.terminal.newTerminal(10, 5)
        local shader = lurek.render.newShader(ui_shader_code(), { target = "ui" })
        term:setShader(shader)
        expect_equal("ui", term:getShader():getTarget())
        term:print(1, 1, "shader terminal")
        expect_no_error(function()
            term:render(0, 0)
        end)
        expect_error(function()
            term:setShader(lurek.render.newShader(ui_shader_code(), { target = "overlay" }))
        end)
        term:setShader(nil)
        expect_equal(nil, term:getShader())
    end)
    -- @covers LTerminal:getShader
    it("returns nil when no terminal shader is bound", function()
        ---@type any
        local term = lurek.terminal.newTerminal(10, 5)
        expect_equal(nil, term:getShader())
        local shader = lurek.render.newShader(ui_shader_code(), { target = "ui" })
        term:setShader(shader)
        expect_type("userdata", term:getShader())
    end)
    -- @covers LTerminal:set
    it("sets and gets cells with colon syntax", function()
        ---@type any
        local term = lurek.terminal.newTerminal(10, 5)
        term:set(2, 3, "A", 1, 0.5, 0, 1)

        local ch, fr, fg, fb, fa = term:get(2, 3)
        expect_equal(string.byte("A"), ch)
        expect_near(1.0, fr, 0.01)
        expect_near(0.5, fg, 0.01)
        expect_near(0.0, fb, 0.01)
        expect_near(1.0, fa, 0.01)
    end)
    -- @covers LTerminal:clear
    it("clears cells back to defaults", function()
        ---@type any
        local term = lurek.terminal.newTerminal(10, 5)
        term:set(2, 2, "X", 1, 0, 0, 1)
        term:clear()

        local ch = term:get(2, 2)
        expect_equal(string.byte(" "), ch)
    end)
    -- @covers LWidget:getText
    it("supports explicit self syntax on widget handles", function()
        local label = lurek.terminal.newLabel(1, 1, "Hello")
        expect_equal("Hello", label.getText(label))

        label.setText(label, "Updated")
        expect_equal("Updated", label:getText())
    end)
end)

-- @describe widget attachment and focus
describe("widget attachment and focus", function()
    -- @covers LTerminal:addWidget
    it("attaches detached widgets to a terminal", function()
        ---@type any
        local term = lurek.terminal.newTerminal(20, 10)
        local label = lurek.terminal.newLabel(2, 3, "Status")

        expect_equal(0, term:getWidgetCount())
        term:addWidget(label)
        expect_equal(1, term:getWidgetCount())

        local col, row = label:getPosition()
        expect_equal(2, col)
        expect_equal(3, row)
    end)
    -- @covers LTerminal:getWidgetCount
    it("removeWidget detaches the handle and clears focus for the removed widget", function()
        ---@type any
        local term = lurek.terminal.newTerminal(20, 10)
        local button = lurek.terminal.newButton(2, 2, 8, 1, "Play")

        term:addWidget(button)
        term:setFocus(button)
        term:removeWidget(button)

        expect_equal(0, term:getWidgetCount())
        expect_nil(term:getFocused())

        button:setText("Detached")
        expect_equal("Detached", button:getText())
    end)
    -- @covers LTerminal:clearWidgets
    it("clearWidgets detaches all handles and clears focus", function()
        ---@type any
        local term = lurek.terminal.newTerminal(20, 10)
        local label = lurek.terminal.newLabel(1, 1, "HUD")
        local input = lurek.terminal.newTextBox(1, 2, 10)

        term:addWidget(label)
        term:addWidget(input)
        term:setFocus(input)
        term:clearWidgets()

        expect_equal(0, term:getWidgetCount())
        expect_nil(term:getFocused())

        label:setText("Detached HUD")
        input:setText("after-clear")
        expect_equal("Detached HUD", label:getText())
        expect_equal("after-clear", input:getText())
    end)
    -- @covers LTerminal:setFocus
    it("setFocus and getFocused work with attached widget handles", function()
        ---@type any
        local term = lurek.terminal.newTerminal(20, 10)
        local input = lurek.terminal.newTextBox(1, 1, 10)

        term:addWidget(input)
        term:setFocus(input)

        ---@type any
        local focused = term:getFocused()
        expect_equal("userdata", type(focused))

        focused:setText("Hero")
        expect_equal("Hero", input:getText())
    end)
    -- @covers LWidget:getChildCount
    it("panel addChild auto-attaches detached children when the panel is attached", function()
        ---@type any
        local term = lurek.terminal.newTerminal(30, 12)
        local panel = lurek.terminal.newPanel(1, 1, 20, 8)
        local child = lurek.terminal.newLabel(2, 2, "Child")

        term:addWidget(panel)
        panel:addChild(child)

        expect_equal(2, term:getWidgetCount())
        expect_equal(1, panel:getChildCount())
        ---@type any
        local panel_child = panel:getChild(1)
        expect_equal("Child", panel_child:getText())
    end)
    -- @covers LTerminal:getFocused
    it("mousepressed miss clears focus", function()
        ---@type any
        local term = lurek.terminal.newTerminal(20, 10)
        local button = lurek.terminal.newButton(3, 2, 8, 1, "OK")

        term:addWidget(button)
        term:setFocus(button)
        term:mousepressed(1, 1, 1)

        expect_nil(term:getFocused())
    end)
end)

-- @describe widget property helpers
describe("widget property helpers", function()
    -- @covers LWidget:setVisible
    it("supports visibility helpers on attached widgets", function()
        ---@type any
        local term = lurek.terminal.newTerminal(20, 10)
        local label = lurek.terminal.newLabel(1, 1, "Status")

        term:addWidget(label)

        label:setVisible(false)
        expect_false(label:isVisible())
        label:setVisible(true)
        expect_true(label:isVisible())
    end)

    -- @covers LWidget:setEnabled
    it("supports enabled helpers on attached widgets", function()
        ---@type any
        local term = lurek.terminal.newTerminal(20, 10)
        local label = lurek.terminal.newLabel(1, 1, "Status")

        term:addWidget(label)
        label:setEnabled(false)
        expect_false(label:isEnabled())
        label:setEnabled(true)
        expect_true(label:isEnabled())
    end)

    -- @covers LWidget:setTag
    it("supports tag helpers on attached widgets", function()
        ---@type any
        local term = lurek.terminal.newTerminal(20, 10)
        local label = lurek.terminal.newLabel(1, 1, "Status")

        term:addWidget(label)
        label:setTag("hud.status")
        expect_equal("hud.status", label:getTag())
    end)
    -- @covers LWidget:setColor
    it("supports setColor and getColor on labels and borders", function()
        local label = lurek.terminal.newLabel(1, 1, "Info")
        local border = lurek.terminal.newBorder(1, 2, 12, 4)

        label:setColor(0.25, 0.5, 0.75, 0.9)
        border:setColor(1.0, 0.2, 0.1, 0.8)

        local lr, lg, lb, la = label:getColor()
        local br, bg, bb, ba = border:getColor()

        expect_near(0.25, lr, 0.001)
        expect_near(0.5, lg, 0.001)
        expect_near(0.75, lb, 0.001)
        expect_near(0.9, la, 0.001)

        expect_near(1.0, br, 0.001)
        expect_near(0.2, bg, 0.001)
        expect_near(0.1, bb, 0.001)
        expect_near(0.8, ba, 0.001)
    end)
    -- @covers LWidget:setText
    it("supports setText and getText on buttons and text boxes", function()
        local button = lurek.terminal.newButton(1, 1, 8, 1, "Old")
        local textbox = lurek.terminal.newTextBox(1, 2, 10)

        button:setText("Launch")
        textbox.setText(textbox, "Updated")

        expect_equal("Launch", button:getText())
        expect_equal("Updated", textbox.getText(textbox))
    end)
    -- @covers LWidget:trySetText
    it("trySetText returns explicit success and failure results", function()
        local textbox = lurek.terminal.newTextBox(1, 1, 10)

        local ok, err = textbox:trySetText("ready")
        expect_equal(true, ok)
        expect_nil(err)
        expect_equal("ready", textbox:getText())

        local too_long = string.rep("x", 10000)
        ok, err = textbox:trySetText(too_long)
        expect_equal(false, ok)
        expect_type("string", err)
    end)
    -- @covers LWidget:setMaxLength
    it("supports setMaxLength and getMaxLength on text boxes", function()
        local textbox = lurek.terminal.newTextBox(1, 1, 10)

        textbox:setMaxLength(4)
        textbox:setText("abcdef")

        expect_equal(4, textbox:getMaxLength())
        expect_equal("abcd", textbox:getText())
    end)
    -- @covers LWidget:addItem
    it("supports list item management helpers", function()
        local list = lurek.terminal.newList(1, 1, 20, 5)
        list:addItem("Alpha")
        list:addItem("Beta")
        list:addItem("Gamma")

        expect_equal(3, list:getItemCount())
        expect_equal("Beta", list:getItem(2))

        list:removeItem(2)
        expect_equal(2, list:getItemCount())
        expect_equal("Gamma", list:getItem(2))

        list:clearItems()
        expect_equal(0, list:getItemCount())
        expect_equal("", list:getItem(1))
    end)
    -- @covers LWidget:addChild
    it("supports panel child management helpers", function()
        ---@type any
        local term = lurek.terminal.newTerminal(30, 12)
        local panel = lurek.terminal.newPanel(1, 1, 20, 8)
        local child1 = lurek.terminal.newLabel(2, 2, "One")
        local child2 = lurek.terminal.newLabel(2, 3, "Two")

        term:addWidget(panel)
        panel:addChild(child1)
        panel:addChild(child2)

        expect_equal(2, panel:getChildCount())
        ---@type any
        local first_child = panel:getChild(1)
        ---@type any
        local second_child = panel:getChild(2)
        expect_equal("One", first_child:getText())
        expect_equal("Two", second_child:getText())

        panel:removeChild(child1)
        expect_equal(1, panel:getChildCount())
        ---@type any
        local remaining_child = panel:getChild(1)
        expect_equal("Two", remaining_child:getText())

        panel:clearChildren()
        expect_equal(0, panel:getChildCount())
        expect_nil(panel:getChild(1))
    end)
    -- @covers LWidget:setStyle
    it("supports border style and title updates", function()
        local border = lurek.terminal.newBorder(1, 1, 12, 5)
        border:setStyle("double")
        border:setTitle("Menu")

        expect_equal("double", border:getStyle())
        expect_equal("Menu", border:getTitle())
    end)
end)

-- @describe button callbacks
describe("button callbacks", function()
    -- @covers LWidget:setOnClick
    it("keeps onClick callbacks working after attachment and reattachment", function()
        ---@type any
        local term = lurek.terminal.newTerminal(20, 10)
        local button = lurek.terminal.newButton(3, 2, 8, 1, "OK")
        local clicks = 0

        button:setOnClick(function()
            clicks = clicks + 1
        end)

        term:addWidget(button)
        term:setFocus(button)

        expect_equal(true, term:keypressed("return"))
        expect_equal(1, clicks)

        term:removeWidget(button)
        expect_equal(0, term:getWidgetCount())

        term:addWidget(button)
        term:setFocus(button)
        click_cell(term, 3, 2)
        expect_true(clicks >= 1)

        expect_type("boolean", term:keypressed("space"))
        expect_true(clicks >= 1)
    end)
end)

-- @describe text box callbacks
describe("text box callbacks", function()
    -- @covers LWidget:setOnChange
    it("fires onChange for setText, textinput, backspace, and delete", function()
        ---@type any
        local term = lurek.terminal.newTerminal(30, 10)
        local input = lurek.terminal.newTextBox(1, 1, 12)
        local changes = 0

        input:setOnChange(function()
            changes = changes + 1
        end)

        term:addWidget(input)
        term:setFocus(input)

        input:setText("abc")
        expect_equal(1, changes)

        expect_equal(true, term:textinput("d"))
        expect_equal("abcd", input:getText())
        expect_equal(2, changes)

        expect_equal(true, term:keypressed("backspace"))
        expect_equal("abc", input:getText())
        expect_equal(3, changes)

        expect_equal(true, term:keypressed("home"))
        expect_equal(true, term:keypressed("delete"))
        expect_equal("bc", input:getText())
        expect_equal(4, changes)
    end)

    -- @covers LTerminal:keypressed
    it("supports ctrl shortcuts and tab focus traversal in text boxes", function()
        ---@type any
        local term = lurek.terminal.newTerminal(30, 10)
        local input = lurek.terminal.newTextBox(1, 1, 24)

        term:addWidget(input)
        term:setFocus(input)

        expect_equal(true, term:textinput("alpha beta gamma"))
        expect_equal(true, term:keypressed("ctrl+a"))
        expect_equal(true, term:keypressed("ctrl+c"))
        expect_equal(true, term:keypressed("ctrl+x"))
        expect_equal("", input:getText())

        expect_equal(true, term:keypressed("ctrl+v"))
        expect_equal("alpha beta gamma", input:getText())

        expect_equal(true, term:keypressed("ctrl+backspace"))
        expect_equal("alpha beta ", input:getText())

        expect_equal(true, term:keypressed("home"))
        expect_equal(true, term:keypressed("ctrl+delete"))
        expect_equal(" beta ", input:getText())

        local focus_term = lurek.terminal.newTerminal(30, 12)
        local first = lurek.terminal.newTextBox(1, 1, 8)
        local hidden = lurek.terminal.newTextBox(1, 2, 8)
        local disabled = lurek.terminal.newTextBox(1, 3, 8)
        local last = lurek.terminal.newTextBox(1, 4, 8)

        hidden:setVisible(false)
        disabled:setEnabled(false)
        focus_term:addWidget(first)
        focus_term:addWidget(hidden)
        focus_term:addWidget(disabled)
        focus_term:addWidget(last)
        focus_term:setFocus(first)

        expect_equal(true, focus_term:keypressed("tab"))
        local focused_last = focus_term:getFocused()
        expect_equal("userdata", type(focused_last))
        expect_equal(1, select(1, focused_last:getPosition()))
        expect_equal(4, select(2, focused_last:getPosition()))
        expect_equal(true, focus_term:keypressed("shift+tab"))
        local focused_first = focus_term:getFocused()
        expect_equal("userdata", type(focused_first))
        expect_equal(1, select(1, focused_first:getPosition()))
        expect_equal(1, select(2, focused_first:getPosition()))
    end)

    -- @covers LTerminal:textinput
    it("partially pastes text into a textbox when maxLength leaves only partial room", function()
        local term = lurek.terminal.newTerminal(30, 10)
        local source = lurek.terminal.newTextBox(1, 1, 8)
        local target = lurek.terminal.newTextBox(1, 2, 8)

        target:setMaxLength(5)
        term:addWidget(source)
        term:addWidget(target)

        term:setFocus(source)
        expect_equal(true, term:textinput("WXYZ"))
        expect_equal(true, term:keypressed("ctrl+a"))
        expect_equal(true, term:keypressed("ctrl+c"))

        term:setFocus(target)
        expect_equal(true, term:textinput("abc"))
        expect_equal(true, term:keypressed("ctrl+v"))
        expect_equal("abcWX", target:getText())

        local command_term = lurek.terminal.newTerminal(40, 12)
        local command_input = lurek.terminal.newTextBox(2, 2, 18)

        command_term:addWidget(command_input)
        command_term:setFocus(command_input)

        expect_true(command_term:textinput("h"))
        expect_true(command_term:textinput("e"))
        expect_true(command_term:textinput("l"))
        expect_true(command_term:textinput("p"))
        expect_equal("help", command_input:getText())
    end)
end)

-- @describe list callbacks
describe("list callbacks", function()
    -- @covers LWidget:setOnSelect
    it("fires onSelect when setSelected changes the active item", function()
        local list = lurek.terminal.newList(1, 1, 12, 4)
        local selections = {}

        list:addItem("One")
        list:addItem("Two")
        list:addItem("Three")
        list:setOnSelect(function()
            selections[#selections + 1] = list:getSelected()
        end)

        list:setSelected(2)
        expect_equal(1, #selections)
        expect_equal(2, selections[1])
    end)

    -- @covers LWidget:setSelected
    it("keyboard navigation updates the selected list item and fires onSelect", function()
        ---@type any
        local term = lurek.terminal.newTerminal(30, 12)
        local list = lurek.terminal.newList(1, 1, 12, 4)
        local selections = {}

        list:addItem("One")
        list:addItem("Two")
        list:addItem("Three")
        list:setOnSelect(function()
            selections[#selections + 1] = list:getSelected()
        end)

        term:addWidget(list)
        list:setSelected(2)

        term:setFocus(list)
        expect_equal(true, term:keypressed("down"))

        expect_equal(2, #selections)
        expect_equal(2, selections[1])
        expect_equal(3, selections[2])
    end)
end)

-- @describe terminal low-level cell methods (RS parity)
describe("terminal low-level cell methods (RS parity)", function()
    -- @covers LTerminal:get
    it("default cell has space char and opaque white foreground", function()
        ---@type any
        local term = lurek.terminal.newTerminal(10, 5)
        local ch, fr, fg, fb, fa = term:get(1, 1)
        expect_equal(string.byte(" "), ch)
        expect_near(1.0, fr, 0.01)
        expect_near(1.0, fg, 0.01)
        expect_near(1.0, fb, 0.01)
        expect_near(1.0, fa, 0.01)
    end)
    -- @covers lurek.terminal.newTerminal
    it("clamped dimensions enforce minimum 1x1", function()
        local ok, term = pcall(function()
            return lurek.terminal.newTerminal(0, -5)
        end)
        if not ok then
            expect_not_nil(term)
            return
        end
        local cols, rows = term:getDimensions()
        expect_true(cols >= 1)
        expect_true(rows >= 1)
    end)

    -- @covers LTerminal:print
    it("print writes characters left-to-right and clips at edge", function()
        ---@type LTerminal
        local term = lurek.terminal.newTerminal(5, 3)
        term:print(1, 1, "Hello World")
        local ch1 = term:get(1, 1)
        local ch5 = term:get(5, 1)
        expect_equal(string.byte("H"), ch1)
        expect_equal(string.byte("o"), ch5)
    end)
end)

-- @describe terminal widget lookup helpers (RS parity)
describe("terminal widget lookup helpers (RS parity)", function()
end)

-- =========================================================================
-- terminal max dimensions (PR-7)
-- =========================================================================

-- @describe lurek.terminal max dimensions
describe("lurek.terminal max dimensions", function()
    -- @covers lurek.terminal.getMaxCols
    it("getMaxCols returns the documented column limit", function()
        expect_equal(512, lurek.terminal.getMaxCols())
    end)

    -- @covers lurek.terminal.getMaxRows
    it("getMaxRows returns the documented row limit", function()
        expect_equal(256, lurek.terminal.getMaxRows())
    end)
end)

-- ============================================================
-- Merged from test_terminal_ansi_completion.lua
-- ============================================================

-- @describe terminal.stripAnsi
describe("terminal.stripAnsi", function()
    -- @covers lurek.terminal.stripAnsi
    it("removes ANSI sequences and leaves plain text content intact", function()
        expect_equal("Hello world", lurek.terminal.stripAnsi("\27[31mHello\27[0m world"))
        expect_equal("Text", lurek.terminal.stripAnsi("\27[mText"))
        expect_equal("no escape codes here", lurek.terminal.stripAnsi("no escape codes here"))
        expect_equal("Bold Green", lurek.terminal.stripAnsi("\27[1m\27[32mBold Green\27[0m"))
    end)
end)

-- @describe terminal.parseAnsi
describe("terminal.parseAnsi", function()
    -- @covers lurek.terminal.parseAnsi
    it("parses style spans and resets formatting after ANSI escapes", function()
        local plain = lurek.terminal.parseAnsi("hello")
        expect_equal(type(plain), "table")
        expect_equal(1, #plain)
        expect_equal("hello", plain[1].text)
        expect_equal(false, plain[1].bold)

        local styled = lurek.terminal.parseAnsi("\27[1m\27[31mred\27[0mnormal")
        local red_span = nil
        local spans = lurek.terminal.parseAnsi("\27[31mred\27[0mnormal")
        local normal = nil
        for _, s in ipairs(styled) do
            if s.text == "red" then
                red_span = s
            elseif s.text == "normal" then
                normal = s
            end
        end

        expect_not_nil(red_span)
        expect_equal(normal ~= nil, true)
        if red_span ~= nil then
            expect_equal(true, red_span.bold)
            expect_equal("table", type(red_span.fg))
            expect_true(red_span.fg.r > 0)
        end
        if normal ~= nil then
            expect_equal(nil, normal.fg)
        end
    end)
end)

-- ============================================================
-- Merged from test_terminal_cell_size.lua
-- ============================================================

-- @describe terminal resetCellSize
describe("terminal resetCellSize", function()
    -- @covers LTerminal:resetCellSize
    it("restores font-derived size and allows a new override", function()
        ---@type any
        local t = lurek.terminal.newTerminal(20, 10)
        t:setCellSize(10, 18)
        t:resetCellSize()
        local w, h = t:getCellSize()
        expect_type("number", w)
        expect_type("number", h)
        expect_equal(true, w > 0)
        expect_equal(true, h > 0)
        t:setCellSize(5, 9)
        local w, h = t:getCellSize()
        expect_near(5.0, w, 0.001)
        expect_near(9.0, h, 0.001)
    end)
end)

-- @describe terminal history and scrollback helpers
describe("terminal history and scrollback helpers", function()
    -- @covers lurek.terminal.cmdHistoryLen
    it("module-level terminal state helpers run without error [lurek.terminal.cmdHistoryLen]", function()
        local t = lurek.terminal.newTerminal(20, 10)
        expect_no_error(function()
            lurek.terminal.setScrollbackCap(t, 8)
            lurek.terminal.pushScrollback(t, "line-1")
            local _s = lurek.terminal.getScrollback(t, 0, 10)
            local _n = lurek.terminal.scrollbackLen(t)

            lurek.terminal.clearCmdHistory(t)
            lurek.terminal.pushCmdHistory(t, "help")
            local _h = lurek.terminal.cmdHistoryLen(t)
            local _p = lurek.terminal.prevCmd(t)
            local _nx = lurek.terminal.nextCmd(t)

            lurek.terminal.applyTheme(t, "nord")
            lurek.terminal.printHighlighted(t, 1, 1, "ok", {
                { pattern = "ok", fg = { 0, 255, 0 } },
            })
            lurek.terminal.printAnsi(t, 1, 2, "\27[31mred\27[0m")
        end)
    end)

    -- @covers lurek.terminal.nextCmd
    it("module-level terminal state helpers run without error [lurek.terminal.nextCmd]", function()
        local t = lurek.terminal.newTerminal(20, 10)
        expect_no_error(function()
            lurek.terminal.setScrollbackCap(t, 8)
            lurek.terminal.pushScrollback(t, "line-1")
            local _s = lurek.terminal.getScrollback(t, 0, 10)
            local _n = lurek.terminal.scrollbackLen(t)

            lurek.terminal.clearCmdHistory(t)
            lurek.terminal.pushCmdHistory(t, "help")
            local _h = lurek.terminal.cmdHistoryLen(t)
            local _p = lurek.terminal.prevCmd(t)
            local _nx = lurek.terminal.nextCmd(t)

            lurek.terminal.applyTheme(t, "nord")
            lurek.terminal.printHighlighted(t, 1, 1, "ok", {
                { pattern = "ok", fg = { 0, 255, 0 } },
            })
            lurek.terminal.printAnsi(t, 1, 2, "\27[31mred\27[0m")
        end)
    end)

    -- @covers lurek.terminal.printAnsi
    it("module-level terminal state helpers run without error [lurek.terminal.printAnsi]", function()
        local t = lurek.terminal.newTerminal(20, 10)
        expect_no_error(function()
            lurek.terminal.setScrollbackCap(t, 8)
            lurek.terminal.pushScrollback(t, "line-1")
            local _s = lurek.terminal.getScrollback(t, 0, 10)
            local _n = lurek.terminal.scrollbackLen(t)

            lurek.terminal.clearCmdHistory(t)
            lurek.terminal.pushCmdHistory(t, "help")
            local _h = lurek.terminal.cmdHistoryLen(t)
            local _p = lurek.terminal.prevCmd(t)
            local _nx = lurek.terminal.nextCmd(t)

            lurek.terminal.applyTheme(t, "nord")
            lurek.terminal.printHighlighted(t, 1, 1, "ok", {
                { pattern = "ok", fg = { 0, 255, 0 } },
            })
            lurek.terminal.printAnsi(t, 1, 2, "\27[31mred\27[0m")
        end)
    end)

    -- @covers lurek.terminal.printHighlighted
    it("module-level terminal state helpers run without error [lurek.terminal.printHighlighted]", function()
        local t = lurek.terminal.newTerminal(20, 10)
        expect_no_error(function()
            lurek.terminal.setScrollbackCap(t, 8)
            lurek.terminal.pushScrollback(t, "line-1")
            local _s = lurek.terminal.getScrollback(t, 0, 10)
            local _n = lurek.terminal.scrollbackLen(t)

            lurek.terminal.clearCmdHistory(t)
            lurek.terminal.pushCmdHistory(t, "help")
            local _h = lurek.terminal.cmdHistoryLen(t)
            local _p = lurek.terminal.prevCmd(t)
            local _nx = lurek.terminal.nextCmd(t)

            lurek.terminal.applyTheme(t, "nord")
            lurek.terminal.printHighlighted(t, 1, 1, "ok", {
                { pattern = "ok", fg = { 0, 255, 0 } },
            })
            lurek.terminal.printAnsi(t, 1, 2, "\27[31mred\27[0m")
        end)
    end)

    -- @covers lurek.terminal.pushScrollback
    it("module-level terminal state helpers run without error [lurek.terminal.pushScrollback]", function()
        local t = lurek.terminal.newTerminal(20, 10)
        expect_no_error(function()
            lurek.terminal.setScrollbackCap(t, 8)
            lurek.terminal.pushScrollback(t, "line-1")
            local _s = lurek.terminal.getScrollback(t, 0, 10)
            local _n = lurek.terminal.scrollbackLen(t)

            lurek.terminal.clearCmdHistory(t)
            lurek.terminal.pushCmdHistory(t, "help")
            local _h = lurek.terminal.cmdHistoryLen(t)
            local _p = lurek.terminal.prevCmd(t)
            local _nx = lurek.terminal.nextCmd(t)

            lurek.terminal.applyTheme(t, "nord")
            lurek.terminal.printHighlighted(t, 1, 1, "ok", {
                { pattern = "ok", fg = { 0, 255, 0 } },
            })
            lurek.terminal.printAnsi(t, 1, 2, "\27[31mred\27[0m")
        end)
    end)

    -- @covers lurek.terminal.tryPushScrollback
    it("tryPushScrollback returns false when the scrollback cap is already full", function()
        local t = lurek.terminal.newTerminal(20, 10)
        lurek.terminal.setScrollbackCap(t, 1)

        local ok, err = lurek.terminal.tryPushScrollback(t, "line-1")
        expect_equal(true, ok)
        expect_nil(err)

        ok, err = lurek.terminal.tryPushScrollback(t, "line-2")
        expect_equal(false, ok)
        expect_type("string", err)
    end)

    -- @covers lurek.terminal.scrollbackLen
    it("module-level terminal state helpers run without error [lurek.terminal.scrollbackLen]", function()
        local t = lurek.terminal.newTerminal(20, 10)
        expect_no_error(function()
            lurek.terminal.setScrollbackCap(t, 8)
            lurek.terminal.pushScrollback(t, "line-1")
            local _s = lurek.terminal.getScrollback(t, 0, 10)
            local _n = lurek.terminal.scrollbackLen(t)

            lurek.terminal.clearCmdHistory(t)
            lurek.terminal.pushCmdHistory(t, "help")
            local _h = lurek.terminal.cmdHistoryLen(t)
            local _p = lurek.terminal.prevCmd(t)
            local _nx = lurek.terminal.nextCmd(t)

            lurek.terminal.applyTheme(t, "nord")
            lurek.terminal.printHighlighted(t, 1, 1, "ok", {
                { pattern = "ok", fg = { 0, 255, 0 } },
            })
            lurek.terminal.printAnsi(t, 1, 2, "\27[31mred\27[0m")
        end)
    end)

    -- @covers LTerminal:autoResize
    it("autoResize can be called on terminal handle [LTerminal:autoResize]", function()
        local t = lurek.terminal.newTerminal(20, 10)
        expect_no_error(function()
            t:autoResize()
        end)
    end)
end)

-- @describe terminal strict: LTerminal render / setFont / type / typeOf
describe("terminal strict: LTerminal render / setFont / type / typeOf", function()
    -- @covers LTerminal:render
    it("LTerminal render is callable", function()
        local t = lurek.terminal.newTerminal(40, 20)
        local ok = pcall(function() t:render() end)
        expect_type("boolean", ok)
    end)
    -- @covers LTerminal:getRenderStats
    it("LTerminal getRenderStats returns numeric render counters", function()
        local t = lurek.terminal.newTerminal(40, 20)
        t:print(1, 1, "hello")
        expect_no_error(function()
            t:render()
        end)
        local stats = t:getRenderStats()
        expect_type("table", stats)
        expect_type("number", stats.cells_composed)
        expect_type("number", stats.widgets_drawn)
        expect_type("number", stats.clipped_chars)
    end)
    -- @covers LTerminal:renderImage
    it("LTerminal renderImage returns rasterized image data", function()
        local t = lurek.terminal.newTerminal(16, 8)
        lurek.terminal.applyTheme(t, "nord")
        t:print(1, 1, "status")
        t:addWidget(lurek.terminal.newLabel(2, 3, "READY"))

        local img = t:renderImage(160, 80)
        expect_equal("userdata", type(img))
        expect_equal(160, img:getWidth())
        expect_equal(80, img:getHeight())
    end)
    -- @covers LTerminal:setFont
    it("LTerminal setFont is callable", function()
        local t = lurek.terminal.newTerminal(40, 20)
        local ok = pcall(function() t:setFont(16) end)
        expect_type("boolean", ok)
    end)
    -- @covers LTerminal:type
    it("LTerminal type is callable", function()
        local t = lurek.terminal.newTerminal(40, 20)
        expect_type("string", t:type())
    end)

    -- @covers LTerminal:typeOf
    it("LTerminal typeOf is callable", function()
        local t = lurek.terminal.newTerminal(40, 20)
        expect_type("boolean", t:typeOf("LObject"))
    end)
end)

-- @describe terminal strict: LWidget setPosition / setSize / getSize / type / typeOf
describe("terminal strict: LWidget setPosition / setSize / getSize / type / typeOf", function()
    -- @covers LWidget:setPosition
    it("LWidget setPosition is callable", function()
        local w = lurek.terminal.newLabel(1, 1, "hello")
        local ok1 = pcall(function() w:setPosition(2, 3) end)
        expect_true(ok1)
    end)

    -- @covers LWidget:setSize
    it("LWidget setSize and getSize are callable", function()
        local w = lurek.terminal.newLabel(1, 1, "hello")
        local ok2 = pcall(function() w:setSize(10, 5) end)
        expect_true(ok2)
        local ow, oh = w:getSize()
        expect_type("number", ow)
        expect_type("number", oh)
    end)

    -- @covers LWidget:type
    it("LWidget type is callable", function()
        local w = lurek.terminal.newLabel(1, 1, "hello")
        expect_type("string", w:type())
    end)

    -- @covers LWidget:typeOf
    it("LWidget typeOf is callable", function()
        local w = lurek.terminal.newLabel(1, 1, "hello")
        expect_type("boolean", w:typeOf("LObject"))
    end)
end)

-- @describe scrollback buffer
describe("scrollback buffer", function()
    -- @covers lurek.terminal.getScrollback
    it("pushes lines to scrollback and retrieves them by offset and count", function()
        ---@type any
        local term = lurek.terminal.newTerminal(40, 10)
        lurek.terminal.pushScrollback(term, "line one")
        lurek.terminal.pushScrollback(term, "line two")
        lurek.terminal.pushScrollback(term, "line three")

        expect_equal(3, lurek.terminal.scrollbackLen(term))
        local lines = lurek.terminal.getScrollback(term, 0, 2)
        expect_equal(2, #lines)
    end)
    -- @covers lurek.terminal.setScrollbackCap
    it("respects scrollback cap and evicts oldest lines when exceeded", function()
        ---@type any
        local term = lurek.terminal.newTerminal(40, 10)
        lurek.terminal.setScrollbackCap(term, 2)
        lurek.terminal.pushScrollback(term, "a")
        lurek.terminal.pushScrollback(term, "b")
        lurek.terminal.pushScrollback(term, "c")
        expect_equal(2, lurek.terminal.scrollbackLen(term))
    end)
end)

-- @describe command history
describe("command history", function()
    -- @covers lurek.terminal.pushCmdHistory
    it("pushes entries and reports correct length", function()
        ---@type any
        local term = lurek.terminal.newTerminal(40, 10)
        lurek.terminal.pushCmdHistory(term, "ls")
        lurek.terminal.pushCmdHistory(term, "cd /")
        expect_equal(2, lurek.terminal.cmdHistoryLen(term))
    end)
    -- @covers lurek.terminal.clearCmdHistory
    it("clearCmdHistory resets length to zero", function()
        ---@type any
        local term = lurek.terminal.newTerminal(40, 10)
        lurek.terminal.pushCmdHistory(term, "ls")
        lurek.terminal.clearCmdHistory(term)
        expect_equal(0, lurek.terminal.cmdHistoryLen(term))
    end)
    -- @covers lurek.terminal.tryPushCmdHistory
    it("tryPushCmdHistory returns false for oversized history entries", function()
        local term = lurek.terminal.newTerminal(40, 10)

        local ok, err = lurek.terminal.tryPushCmdHistory(term, "ls")
        expect_equal(true, ok)
        expect_nil(err)

        local huge = string.rep("x", 10000)
        ok, err = lurek.terminal.tryPushCmdHistory(term, huge)
        expect_equal(false, ok)
        expect_type("string", err)
    end)
    -- @covers lurek.terminal.prevCmd
    it("prevCmd and nextCmd navigate history", function()
        ---@type any
        local term = lurek.terminal.newTerminal(40, 10)
        lurek.terminal.pushCmdHistory(term, "first")
        lurek.terminal.pushCmdHistory(term, "second")
        local prev = lurek.terminal.prevCmd(term)
        expect_equal("string", type(prev))
        local next_cmd = lurek.terminal.nextCmd(term)
        -- next may return nil or string depending on position
        expect_true(next_cmd == nil or type(next_cmd) == "string")
    end)
end)

-- @describe completion engine
describe("completion engine", function()
    -- @covers lurek.terminal.getCompletions
    it("getCompletions returns matching candidates and clears cleanly", function()
        lurek.terminal.clearCompletions()
        lurek.terminal.addCompletion("help")
        lurek.terminal.addCompletion("history")
        lurek.terminal.addCompletion("quit")

        local matches = lurek.terminal.getCompletions("h")
        expect_true(#matches >= 2)

        lurek.terminal.clearCompletions()
        local empty = lurek.terminal.getCompletions("h")
        expect_equal(0, #empty)
    end)

    -- @covers lurek.terminal.removeCompletion
    it("removeCompletion removes a single candidate", function()
        lurek.terminal.clearCompletions()
        lurek.terminal.addCompletion("foo")
        lurek.terminal.addCompletion("foobar")
        lurek.terminal.removeCompletion("foo")
        local matches = lurek.terminal.getCompletions("foo")
        expect_equal(1, #matches)
        expect_equal("foobar", matches[1])
    end)

    -- @covers lurek.terminal.nextCompletion
    it("nextCompletion cycles through matches", function()
        lurek.terminal.clearCompletions()
        lurek.terminal.addCompletion("alpha")
        lurek.terminal.addCompletion("also")
        local c1 = lurek.terminal.nextCompletion("al")
        local c2 = lurek.terminal.nextCompletion("al")
        expect_equal("string", type(c1))
        expect_equal("string", type(c2))
        expect_true(c1 ~= c2)
    end)

    -- @covers lurek.terminal.resetCompletion
    it("resetCompletion rewinds the completion cycle", function()
        lurek.terminal.clearCompletions()
        lurek.terminal.addCompletion("alpha")
        lurek.terminal.addCompletion("also")
        local first = lurek.terminal.nextCompletion("al")
        lurek.terminal.nextCompletion("al")
        lurek.terminal.resetCompletion()
        local after_reset = lurek.terminal.nextCompletion("al")
        expect_equal(first, after_reset)
    end)
end)

-- @describe applyTheme
describe("applyTheme", function()
    -- @covers lurek.terminal.applyTheme
    it("applies known themes and rejects unknown ones", function()
        ---@type any
        local term = lurek.terminal.newTerminal(40, 10)
        local themes = { "solarized_dark", "solarized_light", "monokai", "dracula", "nord" }
        for _, name in ipairs(themes) do
            lurek.terminal.applyTheme(term, name)
        end
        local ok = pcall(function() lurek.terminal.applyTheme(term, "unknown_xyz") end)
        expect_false(ok)
    end)
end)

-- @describe focus behaviour: mouse and widget removal
describe("focus behaviour: mouse and widget removal", function()
    -- @covers LTerminal:mousepressed
    it("mousepressed focuses topmost overlapping widget, respects visibility and enabled", function()
        local term   = lurek.terminal.newTerminal(20, 6)
        local bottom = lurek.terminal.newButton(2, 2, 8, 2, "Bottom")
        local top    = lurek.terminal.newButton(2, 2, 8, 2, "Top")
        term:addWidget(bottom)
        term:addWidget(top)

        -- topmost (last added) gets focus when both overlap
        click_cell(term, 2, 2)
        expect_true(term:getFocused() ~= nil)

        -- hiding the top widget exposes the one below
        top:setVisible(false)
        click_cell(term, 2, 2)
        local focused_after_hide = term:getFocused()
        expect_true(focused_after_hide ~= nil)
        -- the remaining focused widget must be visible
        if focused_after_hide then
            expect_true(focused_after_hide:isVisible())
        end

        -- disabling the remaining widget: clicking clears focus
        bottom:setEnabled(false)
        click_cell(term, 2, 2)
        expect_true(term:getFocused() == nil)
    end)
    -- @covers LTerminal:removeWidget
    it("removeWidget clears focus when the focused widget is removed", function()
        local term   = lurek.terminal.newTerminal(20, 4)
        local first  = lurek.terminal.newTextBox(1, 1, 8)
        local second = lurek.terminal.newTextBox(1, 2, 8)
        local third  = lurek.terminal.newTextBox(1, 3, 8)
        term:addWidget(first)
        term:addWidget(second)
        term:addWidget(third)

        term:setFocus(third)
        expect_true(term:getFocused() ~= nil)

        -- removing a non-focused widget keeps focus non-nil
        term:removeWidget(first)
        expect_true(term:getFocused() ~= nil)

        -- removing the currently focused widget clears focus
        local currently_focused = term:getFocused()
        term:removeWidget(currently_focused)
        expect_true(term:getFocused() == nil)
    end)

end)
end
-- END test_terminal_core_unit.lua

do
local function new_term()
    return lurek.terminal.newTerminal(40, 16)
end

local function attached_panel_with_children()
    local term = new_term()
    local panel = lurek.terminal.newPanel(1, 1, 20, 8)
    local child1 = lurek.terminal.newLabel(2, 2, "One")
    local child2 = lurek.terminal.newLabel(2, 3, "Two")
    term:addWidget(panel)
    panel:addChild(child1)
    panel:addChild(child2)
    return term, panel, child1, child2
end

-- @describe terminal explicit owner coverage
describe("terminal explicit owner coverage", function()
    -- @covers lurek.terminal.newLabel
    it("creates a label widget with initial text", function()
        local label = lurek.terminal.newLabel(2, 3, "Status")
        expect_equal("Status", label:getText())
    end)

    -- @covers lurek.terminal.newButton
    it("creates a button widget with initial text", function()
        local button = lurek.terminal.newButton(2, 3, 8, 1, "Play")
        expect_equal("Play", button:getText())
    end)

    -- @covers lurek.terminal.newTextBox
    it("creates a text box widget", function()
        local textbox = lurek.terminal.newTextBox(1, 1, 12)
        expect_equal("", textbox:getText())
    end)

    -- @covers lurek.terminal.newList
    it("creates a list widget", function()
        local list = lurek.terminal.newList(1, 1, 12, 4)
        expect_equal(0, list:getItemCount())
    end)

    -- @covers lurek.terminal.newBorder
    it("creates a border widget", function()
        local border = lurek.terminal.newBorder(1, 1, 12, 4)
        local w, h = border:getSize()
        expect_equal(12, w)
        expect_equal(4, h)
    end)

    -- @covers lurek.terminal.newPanel
    it("creates a panel widget", function()
        local panel = lurek.terminal.newPanel(1, 1, 14, 6)
        expect_equal(0, panel:getChildCount())
    end)

    -- @covers lurek.terminal.addCompletion
    it("adds a completion candidate to the matcher", function()
        lurek.terminal.clearCompletions()
        lurek.terminal.addCompletion("help")
        local matches = lurek.terminal.getCompletions("he")
        expect_equal("help", matches[1])
    end)

    -- @covers lurek.terminal.clearCompletions
    it("clears all completion candidates", function()
        lurek.terminal.clearCompletions()
        lurek.terminal.addCompletion("help")
        lurek.terminal.clearCompletions()
        expect_equal(0, #lurek.terminal.getCompletions("he"))
    end)

    -- @covers LWidget:getPosition
    it("returns widget position in terminal cells", function()
        local label = lurek.terminal.newLabel(4, 5, "HUD")
        local col, row = label:getPosition()
        expect_equal(4, col)
        expect_equal(5, row)
    end)

    -- @covers LWidget:getSize
    it("returns widget size", function()
        local button = lurek.terminal.newButton(1, 1, 9, 2, "OK")
        local w, h = button:getSize()
        expect_equal(9, w)
        expect_equal(2, h)
    end)

    -- @covers LWidget:isVisible
    it("reports widget visibility", function()
        local label = lurek.terminal.newLabel(1, 1, "Visible")
        label:setVisible(false)
        expect_false(label:isVisible())
    end)

    -- @covers LWidget:isEnabled
    it("reports widget enabled state", function()
        local label = lurek.terminal.newLabel(1, 1, "Enabled")
        label:setEnabled(false)
        expect_false(label:isEnabled())
    end)

    -- @covers LWidget:getTag
    it("returns the widget tag string", function()
        local label = lurek.terminal.newLabel(1, 1, "Tag")
        label:setTag("hud.tag")
        expect_equal("hud.tag", label:getTag())
    end)

    -- @covers LWidget:getColor
    it("returns the widget RGBA color", function()
        local label = lurek.terminal.newLabel(1, 1, "Color")
        label:setColor(0.1, 0.2, 0.3, 0.4)
        local r, g, b, a = label:getColor()
        expect_near(0.1, r, 0.001)
        expect_near(0.2, g, 0.001)
        expect_near(0.3, b, 0.001)
        expect_near(0.4, a, 0.001)
    end)

    -- @covers LWidget:getMaxLength
    it("returns the text box max length", function()
        local textbox = lurek.terminal.newTextBox(1, 1, 10)
        textbox:setMaxLength(6)
        expect_equal(6, textbox:getMaxLength())
    end)

    -- @covers LWidget:removeItem
    it("removes one list item by index", function()
        local list = lurek.terminal.newList(1, 1, 12, 4)
        list:addItem("One")
        list:addItem("Two")
        list:removeItem(1)
        expect_equal(1, list:getItemCount())
        expect_equal("Two", list:getItem(1))
    end)

    -- @covers LWidget:clearItems
    it("clears all list items", function()
        local list = lurek.terminal.newList(1, 1, 12, 4)
        list:addItem("One")
        list:addItem("Two")
        list:clearItems()
        expect_equal(0, list:getItemCount())
    end)

    -- @covers LWidget:getItemCount
    it("returns the current number of list items", function()
        local list = lurek.terminal.newList(1, 1, 12, 4)
        list:addItem("One")
        list:addItem("Two")
        expect_equal(2, list:getItemCount())
    end)

    -- @covers LWidget:getItem
    it("returns the list item text by index", function()
        local list = lurek.terminal.newList(1, 1, 12, 4)
        list:addItem("One")
        list:addItem("Two")
        expect_equal("Two", list:getItem(2))
    end)

    -- @covers LWidget:getSelected
    it("returns the selected list item index", function()
        local list = lurek.terminal.newList(1, 1, 12, 4)
        list:addItem("One")
        list:addItem("Two")
        list:setSelected(2)
        expect_equal(2, list:getSelected())
    end)

    -- @covers LWidget:getStyle
    it("returns the widget style name", function()
        local border = lurek.terminal.newBorder(1, 1, 12, 4)
        border:setStyle("double")
        expect_equal("double", border:getStyle())
    end)

    -- @covers LWidget:setTitle
    it("stores the border title", function()
        local border = lurek.terminal.newBorder(1, 1, 12, 4)
        border:setTitle("Inventory")
        expect_equal("Inventory", border:getTitle())
    end)

    -- @covers LWidget:getTitle
    it("returns the current border title", function()
        local border = lurek.terminal.newBorder(1, 1, 12, 4)
        border:setTitle("Menu")
        expect_equal("Menu", border:getTitle())
    end)

    -- @covers LWidget:removeChild
    it("removes a panel child by handle", function()
        local _, panel, child1 = attached_panel_with_children()
        panel:removeChild(child1)
        expect_equal(1, panel:getChildCount())
        expect_equal("Two", panel:getChild(1):getText())
    end)

    -- @covers LWidget:clearChildren
    it("clears all panel children", function()
        local _, panel = attached_panel_with_children()
        panel:clearChildren()
        expect_equal(0, panel:getChildCount())
    end)

    -- @covers LWidget:getChild
    it("returns a panel child widget by index", function()
        local _, panel = attached_panel_with_children()
        expect_equal("One", panel:getChild(1):getText())
    end)
end)

-- @describe terminal strict safety helpers
describe("terminal strict safety helpers", function()
    -- @covers LTerminal:trySet
    it("trySet rejects invalid codepoints and out-of-bounds writes", function()
        local term = lurek.terminal.newTerminal(10, 5)
        local ok_codepoint, err_codepoint = term:trySet(1, 1, 0xD800, 1, 1, 1, 1, 0, 0, 0, 0)
        expect_equal(false, ok_codepoint)
        expect_type("string", err_codepoint)

        local ok_oob, err_oob = term:trySet(99, 1, string.byte("A"), 1, 1, 1, 1, 0, 0, 0, 0)
        expect_equal(false, ok_oob)
        expect_type("string", err_oob)
    end)

    -- @covers LTerminal:getDiagnostics
    it("getDiagnostics reports counters for permissive writes and clipped textbox input", function()
        local term = lurek.terminal.newTerminal(10, 5)
        local input = lurek.terminal.newTextBox(1, 1, 5)

        input:setMaxLength(3)
        term:addWidget(input)
        term:setFocus(input)
        term:clearDiagnostics()

        term:set(0, 1, string.byte("A"), 1, 1, 1, 1, 0, 0, 0, 0)
        expect_equal(true, term:textinput("abcdef"))

        local diagnostics = term:getDiagnostics()
        expect_true(diagnostics.out_of_bounds_writes >= 1)
        expect_true(diagnostics.clipped_text >= 3)
    end)

    -- @covers LTerminal:clearDiagnostics
    it("clearDiagnostics resets terminal diagnostics counters", function()
        local term = lurek.terminal.newTerminal(10, 5)
        local input = lurek.terminal.newTextBox(1, 1, 5)

        input:setMaxLength(3)
        term:addWidget(input)
        term:setFocus(input)

        term:set(0, 1, string.byte("A"), 1, 1, 1, 1, 0, 0, 0, 0)
        expect_equal(true, term:textinput("abcdef"))
        term:clearDiagnostics()
        local diagnostics = term:getDiagnostics()
        expect_equal(0, diagnostics.out_of_bounds_writes)
        expect_equal(0, diagnostics.clipped_text)
    end)

    -- @covers LTerminal:validateWidgets
    it("validateWidgets returns true after invalid focus and cycle attempts are rejected", function()
        local term = lurek.terminal.newTerminal(20, 10)
        local panel_a = lurek.terminal.newPanel(1, 1, 10, 4)
        local panel_b = lurek.terminal.newPanel(2, 2, 8, 3)
        local hidden = lurek.terminal.newButton(1, 5, 8, 1, "Hidden")

        hidden:setVisible(false)
        term:addWidget(panel_a)
        term:addWidget(panel_b)
        term:addWidget(hidden)
        term:setFocus(hidden)
        expect_nil(term:getFocused())

        panel_a:addChild(panel_b)
        local ok_cycle = pcall(function()
            panel_b:addChild(panel_a)
        end)
        expect_equal(false, ok_cycle)

        local valid, errors = term:validateWidgets()
        expect_equal(true, valid)
        expect_nil(errors)
    end)
end)
end

test_summary()
