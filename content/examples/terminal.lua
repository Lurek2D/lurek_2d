-- content/examples/terminal.lua
-- Auto-generated from content/examples2/terminal_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/terminal.lua

--- Terminal Module Part 1: terminal creation, cell operations, fonts, widgets, rendering


--@api-stub: lurek.terminal.newTerminal
-- Creating terminal grid instances.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 40)
    print("type = " .. term:type())
    local cols, rows = term:getDimensions()
    print("dimensions = " .. cols .. "x" .. rows)
end

--@api-stub: LTerminal:set
-- Writing and reading individual cells. Focus: set.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    term:set(1, 1, "H", 1, 1, 1, 1, 0, 0, 0, 0)
    local ch, fr, fg, fb, fa, br, bg, bb, ba = term:get(1, 1)
    print("cell(1,1) ch=" .. ch .. " fg=(" .. fr .. "," .. fg .. "," .. fb .. ")")
end

--@api-stub: LTerminal:get
-- Writing and reading individual cells. Focus: get.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    term:set(1, 1, "H", 1, 1, 1, 1, 0, 0, 0, 0)
    local ch, fr, fg, fb, fa, br, bg, bb, ba = term:get(1, 1)
    print("cell(1,1) ch=" .. ch .. " fg=(" .. fr .. "," .. fg .. "," .. fb .. ")")
end

--@api-stub: LTerminal:print
-- Writing text strings to the grid.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(60, 20)
    term:print(1, 1, "Hello, Terminal!")
    term:print(1, 2, "Line two here")
    term:print(5, 5, "Centered text at col 5, row 5")
    term:print(1, 20, "Bottom row")
end

--@api-stub: LTerminal:clear
-- Clearing the entire grid.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(40, 10)
    term:print(1, 1, "This will be erased")
    term:print(1, 2, "And this too")
    term:clear()
    local ch = term:get(1, 1)
    print("after clear ch = " .. ch)
end

--@api-stub: LTerminal:getCellSize
-- Adjusting cell pixel dimensions. Focus: getCellSize.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    term:setCellSize(12, 20)
    local w, h = term:getCellSize()
    print("custom cell = " .. w .. "x" .. h)
end

--@api-stub: LTerminal:setCellSize
-- Adjusting cell pixel dimensions. Focus: setCellSize.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    term:setCellSize(12, 20)
    print("cell size set")
end

--@api-stub: LTerminal:resetCellSize
-- Adjusting cell pixel dimensions. Focus: resetCellSize.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    term:setCellSize(12, 20)
    term:resetCellSize()
    local w, h = term:getCellSize()
    print("reset cell = " .. w .. "x" .. h)
end

--@api-stub: LTerminal:setFont
-- Selecting bitmap font by pixel height.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    term:setFont(16)
    local w, h = term:getCellSize()
    print("font 16: cell = " .. w .. "x" .. h)
    term:setFont(12)
    w, h = term:getCellSize()
    print("font 12: cell = " .. w .. "x" .. h)
end

--@api-stub: LTerminal:render
-- Rendering the terminal grid. Focus: render.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(60, 20)
    term:print(1, 1, "Rendering test")
    term:render()
    print("rendered at default pos")
end

--@api-stub: LTerminal:autoResize
-- Rendering the terminal grid. Focus: autoResize.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(60, 20)
    term:autoResize()
    print("auto-resized window to fit grid")
end

--@api-stub: lurek.terminal.newLabel
-- Creating label widgets.
do
    ---@type LWidget
    local label = lurek.terminal.newLabel(5, 3, "Score: 0")
    print("label type = " .. label:type())
    print("is LWidget = " .. tostring(label:typeOf("LWidget")))
    print("text = " .. label:getText())
    local col, row = label:getPosition()
    print("position = " .. col .. ", " .. row)
    label:setText("Score: 1500")
    print("updated text = " .. label:getText())
end

--@api-stub: lurek.terminal.newButton
-- Creating button widgets with click handlers.
do
    local clickCount = 0
    ---@type LWidget
    local btn = lurek.terminal.newButton(10, 5, 12, 1, "Click Me")
    print("button text = " .. btn:getText())
    local w, h = btn:getSize()
    print("button size = " .. w .. "x" .. h)
    btn:setOnClick(function()
        clickCount = clickCount + 1
        print("clicked! count = " .. clickCount)
    end)
    print("click handler set")
end

--@api-stub: lurek.terminal.newTextBox
-- Creating text input widgets.
do
    ---@type LWidget
    local input = lurek.terminal.newTextBox(5, 8, 20)
    print("input text = '" .. input:getText() .. "'")
    input:setText("Hello")
    print("set text = " .. input:getText())
    input:setMaxLength(30)
    print("max length = " .. input:getMaxLength())
    input:setOnChange(function()
        print("text changed to: " .. input:getText())
    end)
end

--@api-stub: lurek.terminal.newList
-- Creating scrollable list widgets.
do
    ---@type LWidget
    local list = lurek.terminal.newList(2, 3, 20, 8)
    list:addItem("Sword")
    list:addItem("Shield")
    list:addItem("Potion")
    list:addItem("Scroll")
    list:addItem("Bow")
    print("item count = " .. list:getItemCount())
    print("item 1 = " .. list:getItem(1))
    print("item 3 = " .. list:getItem(3))
    list:setSelected(2)
    print("selected = " .. list:getSelected())
    list:setOnSelect(function()
        print("selection changed to " .. list:getSelected())
    end)
end

--@api-stub: lurek.terminal.newBorder
-- Creating decorative borders.
do
    ---@type LWidget
    local border = lurek.terminal.newBorder(1, 1, 30, 10)
    print("border style = " .. border:getStyle())
    border:setStyle("double")
    print("new style = " .. border:getStyle())
    border:setTitle("Inventory")
    print("title = " .. border:getTitle())
end

--@api-stub: lurek.terminal.newPanel
-- Creating panel containers for child widgets.
do
    ---@type LWidget
    local panel = lurek.terminal.newPanel(1, 1, 40, 20)
    local label1 = lurek.terminal.newLabel(2, 2, "Name:")
    local label2 = lurek.terminal.newLabel(2, 3, "Class:")
    panel:addChild(label1)
    panel:addChild(label2)
    print("panel children = " .. panel:getChildCount())
    local child1 = panel:getChild(1)
    print("child 1 text = " .. child1:getText())
end

--@api-stub: LTerminal:addWidget
-- Attaching widgets to the terminal. Focus: addWidget.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(60, 20)
    local lbl = lurek.terminal.newLabel(1, 1, "Status")
    local btn = lurek.terminal.newButton(1, 3, 10, 1, "OK")
    term:addWidget(lbl)
    term:addWidget(btn)
    print("widget count = " .. term:getWidgetCount())
    term:removeWidget(btn)
    print("after remove = " .. term:getWidgetCount())
    term:clearWidgets()
    print("after clear = " .. term:getWidgetCount())
end

--@api-stub: LTerminal:removeWidget
-- Attaching widgets to the terminal. Focus: removeWidget.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(60, 20)
    local lbl = lurek.terminal.newLabel(1, 1, "Status")
    local btn = lurek.terminal.newButton(1, 3, 10, 1, "OK")
    term:addWidget(lbl)
    term:addWidget(btn)
    print("widget count = " .. term:getWidgetCount())
    term:removeWidget(btn)
    print("after remove = " .. term:getWidgetCount())
    term:clearWidgets()
    print("after clear = " .. term:getWidgetCount())
end

--@api-stub: LTerminal:getWidgetCount
-- Attaching widgets to the terminal. Focus: getWidgetCount.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(60, 20)
    local lbl = lurek.terminal.newLabel(1, 1, "Status")
    local btn = lurek.terminal.newButton(1, 3, 10, 1, "OK")
    term:addWidget(lbl)
    term:addWidget(btn)
    print("widget count = " .. term:getWidgetCount())
    term:removeWidget(btn)
    print("after remove = " .. term:getWidgetCount())
    term:clearWidgets()
    print("after clear = " .. term:getWidgetCount())
end

--@api-stub: LTerminal:clearWidgets
-- Attaching widgets to the terminal. Focus: clearWidgets.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(60, 20)
    local lbl = lurek.terminal.newLabel(1, 1, "Status")
    local btn = lurek.terminal.newButton(1, 3, 10, 1, "OK")
    term:addWidget(lbl)
    term:addWidget(btn)
    print("widget count = " .. term:getWidgetCount())
    term:removeWidget(btn)
    print("after remove = " .. term:getWidgetCount())
    term:clearWidgets()
    print("after clear = " .. term:getWidgetCount())
end

--@api-stub: LTerminal:setFocus
-- Widget focus management. Focus: setFocus.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(60, 20)
    local input1 = lurek.terminal.newTextBox(1, 1, 15)
    local input2 = lurek.terminal.newTextBox(1, 3, 15)
    term:addWidget(input1)
    term:addWidget(input2)
    term:setFocus(input1)
    local focused = term:getFocused()
    print("focused = " .. tostring(focused == input1))
    term:setFocus(input2)
    focused = term:getFocused()
    print("focused = " .. tostring(focused == input2))
    term:setFocus(nil)
    focused = term:getFocused()
    print("no focus = " .. tostring(focused == nil))
end

--@api-stub: LTerminal:getFocused
-- Widget focus management. Focus: getFocused.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(60, 20)
    local input1 = lurek.terminal.newTextBox(1, 1, 15)
    local input2 = lurek.terminal.newTextBox(1, 3, 15)
    term:addWidget(input1)
    term:addWidget(input2)
    term:setFocus(input1)
    local focused = term:getFocused()
    print("focused = " .. tostring(focused == input1))
    term:setFocus(input2)
    focused = term:getFocused()
    print("focused = " .. tostring(focused == input2))
    term:setFocus(nil)
    focused = term:getFocused()
    print("no focus = " .. tostring(focused == nil))
end

--@api-stub: LTerminal:keypressed
-- Forwarding input events. Focus: keypressed.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(60, 20)
    local input = lurek.terminal.newTextBox(1, 1, 20)
    term:addWidget(input)
    term:setFocus(input)
    local consumed = term:textinput("A")
    print("textinput consumed = " .. tostring(consumed))
    consumed = term:keypressed("backspace")
    print("keypressed consumed = " .. tostring(consumed))
    term:mousepressed(50, 10, 1)
    print("mousepressed sent")
end

--@api-stub: LTerminal:textinput
-- Forwarding input events. Focus: textinput.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(60, 20)
    local input = lurek.terminal.newTextBox(1, 1, 20)
    term:addWidget(input)
    term:setFocus(input)
    local consumed = term:textinput("A")
    print("textinput consumed = " .. tostring(consumed))
    consumed = term:keypressed("backspace")
    print("keypressed consumed = " .. tostring(consumed))
    term:mousepressed(50, 10, 1)
    print("mousepressed sent")
end

--@api-stub: LTerminal:mousepressed
-- Forwarding input events. Focus: mousepressed.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(60, 20)
    local input = lurek.terminal.newTextBox(1, 1, 20)
    term:addWidget(input)
    term:setFocus(input)
    local consumed = term:textinput("A")
    print("textinput consumed = " .. tostring(consumed))
    consumed = term:keypressed("backspace")
    print("keypressed consumed = " .. tostring(consumed))
    term:mousepressed(50, 10, 1)
    print("mousepressed sent")
end

--- Terminal Module Part 2: themes, command history, scrollback, completions, ANSI, highlighting


--@api-stub: lurek.terminal.applyTheme
-- Applying color themes to a terminal.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    lurek.terminal.applyTheme(term, "solarized_dark")
    print("applied solarized_dark")
    lurek.terminal.applyTheme(term, "monokai")
    print("applied monokai")
    lurek.terminal.applyTheme(term, "dracula")
    print("applied dracula")
    lurek.terminal.applyTheme(term, "nord")
    print("applied nord")
    lurek.terminal.applyTheme(term, "solarized_light")
    print("applied solarized_light")
end

--@api-stub: lurek.terminal.pushCmdHistory
-- Command history navigation.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    lurek.terminal.pushCmdHistory(term, "status")
    lurek.terminal.pushCmdHistory(term, "inventory")
    local prev = lurek.terminal.prevCmd(term)
    print("prev 1 = " .. tostring(prev))
    prev = lurek.terminal.prevCmd(term)
    print("prev 2 = " .. tostring(prev))
    local next_cmd = lurek.terminal.nextCmd(term)
    print("next = " .. tostring(next_cmd))
end

--@api-stub: lurek.terminal.cmdHistoryLen
-- Managing command history size.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    lurek.terminal.pushCmdHistory(term, "look")
    lurek.terminal.pushCmdHistory(term, "go north")
    lurek.terminal.pushCmdHistory(term, "take sword")
    print("history len = " .. lurek.terminal.cmdHistoryLen(term))
    lurek.terminal.clearCmdHistory(term)
    print("after clear len = " .. lurek.terminal.cmdHistoryLen(term))
end

--@api-stub: lurek.terminal.pushScrollback
-- Scrollback buffer operations.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    lurek.terminal.pushScrollback(term, "You see a dark corridor.")
    lurek.terminal.pushScrollback(term, "A torch flickers on the wall.")
    lurek.terminal.pushScrollback(term, "You hear footsteps.")
    lurek.terminal.pushScrollback(term, "An enemy appears!")
    print("scrollback len = " .. lurek.terminal.scrollbackLen(term))
    local lines = lurek.terminal.getScrollback(term, 0, 3)
    print("recent 3 lines:")
    for i, line in ipairs(lines) do
        print("  " .. i .. ": " .. line)
    end
end

--@api-stub: lurek.terminal.setScrollbackCap
-- Limiting scrollback buffer size.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    lurek.terminal.setScrollbackCap(term, 100)
    for i = 1, 150 do
        lurek.terminal.pushScrollback(term, "Line " .. i)
    end
    print("scrollback after overflow = " .. lurek.terminal.scrollbackLen(term))
end

--@api-stub: lurek.terminal.addCompletion
-- Registering and querying completions.
do
    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("help")
    lurek.terminal.addCompletion("health")
    lurek.terminal.addCompletion("heal")
    lurek.terminal.addCompletion("inventory")
    lurek.terminal.addCompletion("inspect")
    local matches = lurek.terminal.getCompletions("he")
    print("matches for 'he':")
    for _, m in ipairs(matches) do
        print("  " .. m)
    end
    local inv = lurek.terminal.getCompletions("in")
    print("matches for 'in' = " .. #inv)
end

--@api-stub: lurek.terminal.nextCompletion
-- Cycling through completion candidates.
do
    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("attack")
    lurek.terminal.addCompletion("attune")
    lurek.terminal.addCompletion("attract")
    lurek.terminal.resetCompletion()
    local c1 = lurek.terminal.nextCompletion("att")
    print("cycle 1 = " .. tostring(c1))
    local c2 = lurek.terminal.nextCompletion("att")
    print("cycle 2 = " .. tostring(c2))
    local c3 = lurek.terminal.nextCompletion("att")
    print("cycle 3 = " .. tostring(c3))
    lurek.terminal.removeCompletion("attune")
    lurek.terminal.resetCompletion()
    local after = lurek.terminal.nextCompletion("att")
    print("after remove = " .. tostring(after))
end

--@api-stub: lurek.terminal.parseAnsi
-- Parsing ANSI escape sequences into spans.
do
    local ansiText = "\27[1;31mError:\27[0m File not found"
    local spans = lurek.terminal.parseAnsi(ansiText)
    print("span count = " .. #spans)
    for i, span in ipairs(spans) do
        print("  span " .. i .. ": text='" .. span.text .. "' bold=" .. tostring(span.bold))
    end
end

--@api-stub: lurek.terminal.stripAnsi
-- Removing ANSI codes from text.
do
    local colored = "\27[32mSuccess\27[0m: Operation complete"
    local plain = lurek.terminal.stripAnsi(colored)
    print("stripped = " .. plain)
    print("length original = " .. #colored)
    print("length stripped = " .. #plain)
end

--@api-stub: lurek.terminal.printAnsi
-- Rendering ANSI-colored text onto the grid.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    lurek.terminal.printAnsi(term, 1, 1, "\27[1;33mWarning:\27[0m Low health")
    lurek.terminal.printAnsi(term, 1, 2, "\27[34mInfo:\27[0m Checkpoint saved")
    lurek.terminal.printAnsi(term, 1, 3, "\27[1;31mCritical:\27[0m System failure")
    print("ANSI text rendered to grid")
end

--@api-stub: lurek.terminal.printHighlighted
-- Syntax-highlighted text with custom rules.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    local rules = {
        { pattern = "local%s+%w+", fg = { r = 100, g = 150, b = 255 } },
        { pattern = '\"[^\"]*\"', fg = { r = 200, g = 200, b = 100 } },
        { pattern = "%-%-%s.*$", fg = { r = 100, g = 100, b = 100 } },
        { pattern = "%d+", fg = { r = 255, g = 150, b = 50 } },
    }
    local code = 'local name = "hero" -- player name'
    lurek.terminal.printHighlighted(term, 1, 1, code, rules)
    print("highlighted code rendered")
    local code2 = "local score = 42"
    lurek.terminal.printHighlighted(term, 1, 2, code2, rules)
    print("highlighted code2 rendered")
end

--@api-stub: lurek.terminal.getMaxCols
-- Querying terminal size limits.
do
    local maxCols = lurek.terminal.getMaxCols()
    local maxRows = lurek.terminal.getMaxRows()
    print("max cols = " .. maxCols)
    print("max rows = " .. maxRows)
end

--@api-stub: LLabel:setColor
-- Widget appearance control.
do
    ---@type LWidget
    local label = lurek.terminal.newLabel(1, 1, "Colored")
    label:setColor(0.2, 0.8, 0.3, 1)
    local r, g, b, a = label:getColor()
    print("color = " .. r .. ", " .. g .. ", " .. b .. ", " .. a)
    print("visible = " .. tostring(label:isVisible()))
    label:setVisible(false)
    print("after hide = " .. tostring(label:isVisible()))
    label:setVisible(true)
end

--@api-stub: LButton:isEnabled
-- Widget enable state and tagging.
do
    ---@type LWidget
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "Submit")
    print("enabled = " .. tostring(btn:isEnabled()))
    btn:setEnabled(false)
    print("after disable = " .. tostring(btn:isEnabled()))
    btn:setEnabled(true)
    btn:setTag("submit_button")
    print("tag = " .. btn:getTag())
end

--@api-stub: LList:addItem
-- Adding, removing, and querying list items.
do
    ---@type LWidget
    local list = lurek.terminal.newList(1, 1, 20, 5)
    list:addItem("Apple")
    list:addItem("Banana")
    list:addItem("Cherry")
    list:addItem("Date")
    print("items = " .. list:getItemCount())
    list:removeItem(2)
    print("after remove idx 2: items = " .. list:getItemCount())
    print("item 2 now = " .. list:getItem(2))
    list:clearItems()
    print("after clear: items = " .. list:getItemCount())
end

--@api-stub: LPanel:addChild
-- Managing panel child widgets.
do
    ---@type LWidget
    local panel = lurek.terminal.newPanel(1, 1, 40, 20)
    local child1 = lurek.terminal.newLabel(2, 2, "Label A")
    local child2 = lurek.terminal.newLabel(2, 4, "Label B")
    local child3 = lurek.terminal.newButton(2, 6, 10, 1, "Btn")
    panel:addChild(child1)
    panel:addChild(child2)
    panel:addChild(child3)
    print("children = " .. panel:getChildCount())
    panel:removeChild(child2)
    print("after remove = " .. panel:getChildCount())
    panel:clearChildren()
    print("after clear = " .. panel:getChildCount())
end

--- Terminal Part 2: LTerminal full API + missing module-level functions


--@api-stub: LTerminal:getDimensions
-- LTerminal full API: create, add widgets, print, render, type. Focus: getDimensions.
do
    local term = lurek.terminal.newTerminal(80, 24)
    print("type=" .. term:type())
    print("typeOf=" .. tostring(term:typeOf("LTerminal")))

    local cw, ch = term:getCellSize()
    print("cell_w=" .. cw .. " cell_h=" .. ch)

    local cols, rows = term:getDimensions()
    print("cols=" .. cols .. " rows=" .. rows)

    term:print(0, 0, "Hello Terminal")
    term:set(0, 1, "X", 255, 255, 255, 255, 0, 0, 0, 255)
    local cell = term:get(0, 0)
    print("cell=" .. tostring(cell))

    local lbl = lurek.terminal.newLabel(1, 1, "TestLabel")
    term:addWidget(lbl)
    print("widgets=" .. term:getWidgetCount())

    local focused = term:getFocused()
    print("focused=" .. tostring(focused ~= nil))

    term:setFocus(lbl)
    term:removeWidget(lbl)
    print("widgets_after=" .. term:getWidgetCount())
    term:clearWidgets()

    term:setFont(14)
    term:setCellSize(8, 16)
    term:autoResize()
    term:resetCellSize()

    term:keypressed("return")
    term:textinput("a")
    term:mousepressed(10, 10, 1)

    term:clear()
    term:render(0, 0)
end

--@api-stub: LTerminal:type
-- LTerminal full API: create, add widgets, print, render, type. Focus: type.
do
    local term = lurek.terminal.newTerminal(80, 24)
    print("type=" .. term:type())
    print("typeOf=" .. tostring(term:typeOf("LTerminal")))

    local cw, ch = term:getCellSize()
    print("cell_w=" .. cw .. " cell_h=" .. ch)

    local cols, rows = term:getDimensions()
    print("cols=" .. cols .. " rows=" .. rows)

    term:print(0, 0, "Hello Terminal")
    term:set(0, 1, "X", 255, 255, 255, 255, 0, 0, 0, 255)
    local cell = term:get(0, 0)
    print("cell=" .. tostring(cell))

    local lbl = lurek.terminal.newLabel(1, 1, "TestLabel")
    term:addWidget(lbl)
    print("widgets=" .. term:getWidgetCount())

    local focused = term:getFocused()
    print("focused=" .. tostring(focused ~= nil))

    term:setFocus(lbl)
    term:removeWidget(lbl)
    print("widgets_after=" .. term:getWidgetCount())
    term:clearWidgets()

    term:setFont(14)
    term:setCellSize(8, 16)
    term:autoResize()
    term:resetCellSize()

    term:keypressed("return")
    term:textinput("a")
    term:mousepressed(10, 10, 1)

    term:clear()
    term:render(0, 0)
end

--@api-stub: LTerminal:typeOf
-- LTerminal full API: create, add widgets, print, render, type. Focus: typeOf.
do
    local term = lurek.terminal.newTerminal(80, 24)
    print("type=" .. term:type())
    print("typeOf=" .. tostring(term:typeOf("LTerminal")))

    local cw, ch = term:getCellSize()
    print("cell_w=" .. cw .. " cell_h=" .. ch)

    local cols, rows = term:getDimensions()
    print("cols=" .. cols .. " rows=" .. rows)

    term:print(0, 0, "Hello Terminal")
    term:set(0, 1, "X", 255, 255, 255, 255, 0, 0, 0, 255)
    local cell = term:get(0, 0)
    print("cell=" .. tostring(cell))

    local lbl = lurek.terminal.newLabel(1, 1, "TestLabel")
    term:addWidget(lbl)
    print("widgets=" .. term:getWidgetCount())

    local focused = term:getFocused()
    print("focused=" .. tostring(focused ~= nil))

    term:setFocus(lbl)
    term:removeWidget(lbl)
    print("widgets_after=" .. term:getWidgetCount())
    term:clearWidgets()

    term:setFont(14)
    term:setCellSize(8, 16)
    term:autoResize()
    term:resetCellSize()

    term:keypressed("return")
    term:textinput("a")
    term:mousepressed(10, 10, 1)

    term:clear()
    term:render(0, 0)
end

--@api-stub: lurek.terminal.clearCmdHistory
-- Terminal module-level helpers: command history, scrollback, completions, ANSI. Focus: clearCmdHistory.
do
    local term = lurek.terminal.newTerminal(40, 10)

    lurek.terminal.clearCmdHistory(term)
    local prev = lurek.terminal.prevCmd(term)
    print("prev_cmd=" .. tostring(prev))
    local next_cmd = lurek.terminal.nextCmd(term)
    print("next_cmd=" .. tostring(next_cmd))

    local sb_len = lurek.terminal.scrollbackLen(term)
    print("scrollback_len=" .. sb_len)
    local sb = lurek.terminal.getScrollback(term, 0, 5)
    print("scrollback=" .. tostring(sb ~= nil))

    lurek.terminal.addCompletion("test_completion")
    lurek.terminal.removeCompletion("test_completion")
    lurek.terminal.resetCompletion()

    local stripped = lurek.terminal.stripAnsi("\27[31mRed\27[0m")
    print("stripped=" .. stripped)

    lurek.terminal.printHighlighted(term, 0, 0, "keyword", {})
    print("highlighted done")
end

--@api-stub: lurek.terminal.prevCmd
-- Terminal module-level helpers: command history, scrollback, completions, ANSI. Focus: prevCmd.
do
    local term = lurek.terminal.newTerminal(40, 10)

    lurek.terminal.clearCmdHistory(term)
    local prev = lurek.terminal.prevCmd(term)
    print("prev_cmd=" .. tostring(prev))
    local next_cmd = lurek.terminal.nextCmd(term)
    print("next_cmd=" .. tostring(next_cmd))

    local sb_len = lurek.terminal.scrollbackLen(term)
    print("scrollback_len=" .. sb_len)
    local sb = lurek.terminal.getScrollback(term, 0, 5)
    print("scrollback=" .. tostring(sb ~= nil))

    lurek.terminal.addCompletion("test_completion")
    lurek.terminal.removeCompletion("test_completion")
    lurek.terminal.resetCompletion()

    local stripped = lurek.terminal.stripAnsi("\27[31mRed\27[0m")
    print("stripped=" .. stripped)

    lurek.terminal.printHighlighted(term, 0, 0, "keyword", {})
    print("highlighted done")
end

--@api-stub: lurek.terminal.nextCmd
-- Terminal module-level helpers: command history, scrollback, completions, ANSI. Focus: nextCmd.
do
    local term = lurek.terminal.newTerminal(40, 10)

    lurek.terminal.clearCmdHistory(term)
    local prev = lurek.terminal.prevCmd(term)
    print("prev_cmd=" .. tostring(prev))
    local next_cmd = lurek.terminal.nextCmd(term)
    print("next_cmd=" .. tostring(next_cmd))

    local sb_len = lurek.terminal.scrollbackLen(term)
    print("scrollback_len=" .. sb_len)
    local sb = lurek.terminal.getScrollback(term, 0, 5)
    print("scrollback=" .. tostring(sb ~= nil))

    lurek.terminal.addCompletion("test_completion")
    lurek.terminal.removeCompletion("test_completion")
    lurek.terminal.resetCompletion()

    local stripped = lurek.terminal.stripAnsi("\27[31mRed\27[0m")
    print("stripped=" .. stripped)

    lurek.terminal.printHighlighted(term, 0, 0, "keyword", {})
    print("highlighted done")
end

--@api-stub: lurek.terminal.getScrollback
-- Terminal module-level helpers: command history, scrollback, completions, ANSI. Focus: getScrollback.
do
    local term = lurek.terminal.newTerminal(40, 10)

    lurek.terminal.clearCmdHistory(term)
    local prev = lurek.terminal.prevCmd(term)
    print("prev_cmd=" .. tostring(prev))
    local next_cmd = lurek.terminal.nextCmd(term)
    print("next_cmd=" .. tostring(next_cmd))

    local sb_len = lurek.terminal.scrollbackLen(term)
    print("scrollback_len=" .. sb_len)
    local sb = lurek.terminal.getScrollback(term, 0, 5)
    print("scrollback=" .. tostring(sb ~= nil))

    lurek.terminal.addCompletion("test_completion")
    lurek.terminal.removeCompletion("test_completion")
    lurek.terminal.resetCompletion()

    local stripped = lurek.terminal.stripAnsi("\27[31mRed\27[0m")
    print("stripped=" .. stripped)

    lurek.terminal.printHighlighted(term, 0, 0, "keyword", {})
    print("highlighted done")
end

--@api-stub: lurek.terminal.scrollbackLen
-- Terminal module-level helpers: command history, scrollback, completions, ANSI. Focus: scrollbackLen.
do
    local term = lurek.terminal.newTerminal(40, 10)

    lurek.terminal.clearCmdHistory(term)
    local prev = lurek.terminal.prevCmd(term)
    print("prev_cmd=" .. tostring(prev))
    local next_cmd = lurek.terminal.nextCmd(term)
    print("next_cmd=" .. tostring(next_cmd))

    local sb_len = lurek.terminal.scrollbackLen(term)
    print("scrollback_len=" .. sb_len)
    local sb = lurek.terminal.getScrollback(term, 0, 5)
    print("scrollback=" .. tostring(sb ~= nil))

    lurek.terminal.addCompletion("test_completion")
    lurek.terminal.removeCompletion("test_completion")
    lurek.terminal.resetCompletion()

    local stripped = lurek.terminal.stripAnsi("\27[31mRed\27[0m")
    print("stripped=" .. stripped)

    lurek.terminal.printHighlighted(term, 0, 0, "keyword", {})
    print("highlighted done")
end

--@api-stub: lurek.terminal.removeCompletion
-- Terminal module-level helpers: command history, scrollback, completions, ANSI. Focus: removeCompletion.
do
    local term = lurek.terminal.newTerminal(40, 10)

    lurek.terminal.clearCmdHistory(term)
    local prev = lurek.terminal.prevCmd(term)
    print("prev_cmd=" .. tostring(prev))
    local next_cmd = lurek.terminal.nextCmd(term)
    print("next_cmd=" .. tostring(next_cmd))

    local sb_len = lurek.terminal.scrollbackLen(term)
    print("scrollback_len=" .. sb_len)
    local sb = lurek.terminal.getScrollback(term, 0, 5)
    print("scrollback=" .. tostring(sb ~= nil))

    lurek.terminal.addCompletion("test_completion")
    lurek.terminal.removeCompletion("test_completion")
    lurek.terminal.resetCompletion()

    local stripped = lurek.terminal.stripAnsi("\27[31mRed\27[0m")
    print("stripped=" .. stripped)

    lurek.terminal.printHighlighted(term, 0, 0, "keyword", {})
    print("highlighted done")
end

--@api-stub: lurek.terminal.resetCompletion
-- Terminal module-level helpers: command history, scrollback, completions, ANSI. Focus: resetCompletion.
do
    local term = lurek.terminal.newTerminal(40, 10)

    lurek.terminal.clearCmdHistory(term)
    local prev = lurek.terminal.prevCmd(term)
    print("prev_cmd=" .. tostring(prev))
    local next_cmd = lurek.terminal.nextCmd(term)
    print("next_cmd=" .. tostring(next_cmd))

    local sb_len = lurek.terminal.scrollbackLen(term)
    print("scrollback_len=" .. sb_len)
    local sb = lurek.terminal.getScrollback(term, 0, 5)
    print("scrollback=" .. tostring(sb ~= nil))

    lurek.terminal.addCompletion("test_completion")
    lurek.terminal.removeCompletion("test_completion")
    lurek.terminal.resetCompletion()

    local stripped = lurek.terminal.stripAnsi("\27[31mRed\27[0m")
    print("stripped=" .. stripped)

    lurek.terminal.printHighlighted(term, 0, 0, "keyword", {})
    print("highlighted done")
end

--@api-stub: lurek.terminal.clearCompletions
-- Terminal completion and size query. Focus: clearCompletions.
do
    lurek.terminal.clearCompletions()
    local completions = lurek.terminal.getCompletions("he")
    local maxRows = lurek.terminal.getMaxRows()
    print("clearCompletions ok, getCompletions:", type(completions), "getMaxRows:", maxRows)
end

--@api-stub: lurek.terminal.getCompletions
-- Terminal completion and size query. Focus: getCompletions.
do
    lurek.terminal.clearCompletions()
    local completions = lurek.terminal.getCompletions("he")
    local maxRows = lurek.terminal.getMaxRows()
    print("clearCompletions ok, getCompletions:", type(completions), "getMaxRows:", maxRows)
end

--@api-stub: lurek.terminal.getMaxRows
-- Terminal completion and size query. Focus: getMaxRows.
do
    lurek.terminal.clearCompletions()
    local completions = lurek.terminal.getCompletions("he")
    local maxRows = lurek.terminal.getMaxRows()
    print("clearCompletions ok, getCompletions:", type(completions), "getMaxRows:", maxRows)
end

--@api-stub: LWidget:getChild
-- LWidget child management. Focus: getChild.
do
    local panel = lurek.terminal.newPanel(0, 0, 40, 20)
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "OK")
    panel:addChild(btn)
    local count = panel:getChildCount()
    local child = panel:getChild(1)
    print("addChild/getChild/getChildCount ok, count:", count)
end

--@api-stub: LWidget:getChildCount
-- LWidget child management. Focus: getChildCount.
do
    local panel = lurek.terminal.newPanel(0, 0, 40, 20)
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "OK")
    panel:addChild(btn)
    local count = panel:getChildCount()
    local child = panel:getChild(1)
    print("addChild/getChild/getChildCount ok, count:", count)
end

--@api-stub: LWidget:addChild
-- LWidget child management. Focus: addChild.
do
    local panel = lurek.terminal.newPanel(0, 0, 40, 20)
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "OK")
    panel:addChild(btn)
    local count = panel:getChildCount()
    local child = panel:getChild(1)
    print("addChild/getChild/getChildCount ok, count:", count)
end

--@api-stub: LWidget:clearChildren
-- LWidget clear children, remove child, addItem. Focus: clearChildren.
do
    local panel = lurek.terminal.newPanel(0, 0, 40, 20)
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "X")
    panel:addChild(btn)
    panel:removeChild(btn)
    panel:clearChildren()
    local list = lurek.terminal.newList(0, 0, 20, 10)
    list:addItem("item one")
    print("clearChildren/removeChild/addItem ok")
end

--@api-stub: LWidget:removeChild
-- LWidget clear children, remove child, addItem. Focus: removeChild.
do
    local panel = lurek.terminal.newPanel(0, 0, 40, 20)
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "X")
    panel:addChild(btn)
    panel:removeChild(btn)
    panel:clearChildren()
    local list = lurek.terminal.newList(0, 0, 20, 10)
    list:addItem("item one")
    print("clearChildren/removeChild/addItem ok")
end

--@api-stub: LWidget:addItem
-- LWidget clear children, remove child, addItem. Focus: addItem.
do
    local panel = lurek.terminal.newPanel(0, 0, 40, 20)
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "X")
    panel:addChild(btn)
    panel:removeChild(btn)
    panel:clearChildren()
    local list = lurek.terminal.newList(0, 0, 20, 10)
    list:addItem("item one")
    print("clearChildren/removeChild/addItem ok")
end

--@api-stub: LWidget:clearItems
-- LWidget list item access. Focus: clearItems.
do
    local list = lurek.terminal.newList(0, 0, 20, 10)
    list:addItem("alpha")
    list:addItem("beta")
    local count = list:getItemCount()
    local item = list:getItem(1)
    list:clearItems()
    print("clearItems/getItem/getItemCount ok, item:", item)
end

--@api-stub: LWidget:getItem
-- LWidget list item access. Focus: getItem.
do
    local list = lurek.terminal.newList(0, 0, 20, 10)
    list:addItem("alpha")
    list:addItem("beta")
    local count = list:getItemCount()
    local item = list:getItem(1)
    list:clearItems()
    print("clearItems/getItem/getItemCount ok, item:", item)
end

--@api-stub: LWidget:getItemCount
-- LWidget list item access. Focus: getItemCount.
do
    local list = lurek.terminal.newList(0, 0, 20, 10)
    list:addItem("alpha")
    list:addItem("beta")
    local count = list:getItemCount()
    local item = list:getItem(1)
    list:clearItems()
    print("clearItems/getItem/getItemCount ok, item:", item)
end

--@api-stub: LWidget:getColor
-- LWidget appearance getters. Focus: getColor.
do
    local label = lurek.terminal.newLabel(0, 0, "Tag")
    label:setColor(255, 200, 100, 255)
    local r, g, b, a = label:getColor()
    print("getColor:", r, g, b, a)
end

--@api-stub: LWidget:getStyle
-- LWidget appearance getters. Focus: getStyle.
do
    local border = lurek.terminal.newBorder(0, 1, 10, 3)
    border:setStyle("single")
    local style = border:getStyle()
    print("getStyle:", style)
end

--@api-stub: LWidget:getTag
-- LWidget appearance getters. Focus: getTag.
do
    local border = lurek.terminal.newBorder(0, 1, 10, 3)
    border:setTag("my_border")
    local tag = border:getTag()
    print("getTag:", tag)
end

--@api-stub: LWidget:getText
-- LWidget text getters. Focus: getText.
do
    local tb = lurek.terminal.newTextBox(0, 0, 20)
    tb:setText("hello")
    local txt = tb:getText()
    local border = lurek.terminal.newBorder(0, 1, 20, 3)
    border:setTitle("Input")
    local title = border:getTitle()
    local maxLen = tb:getMaxLength()
    print("getText:", txt, "getTitle:", title, "getMaxLength:", maxLen)
end

--@api-stub: LWidget:getTitle
-- LWidget text getters. Focus: getTitle.
do
    local tb = lurek.terminal.newTextBox(0, 0, 20)
    tb:setText("hello")
    local txt = tb:getText()
    local border = lurek.terminal.newBorder(0, 1, 20, 3)
    border:setTitle("Input")
    local title = border:getTitle()
    local maxLen = tb:getMaxLength()
    print("getText:", txt, "getTitle:", title, "getMaxLength:", maxLen)
end

--@api-stub: LWidget:getMaxLength
-- LWidget text getters. Focus: getMaxLength.
do
    local tb = lurek.terminal.newTextBox(0, 0, 20)
    tb:setText("hello")
    local txt = tb:getText()
    local border = lurek.terminal.newBorder(0, 1, 20, 3)
    border:setTitle("Input")
    local title = border:getTitle()
    local maxLen = tb:getMaxLength()
    print("getText:", txt, "getTitle:", title, "getMaxLength:", maxLen)
end

--@api-stub: LWidget:getPosition
-- LWidget position, size, and selection state. Focus: getPosition.
do
    local list = lurek.terminal.newList(5, 3, 15, 8)
    local px, py = list:getPosition()
    local w, h = list:getSize()
    list:addItem("opt1")
    list:setSelected(1)
    local sel = list:getSelected()
    print("getPosition:", px, py, "getSize:", w, h, "getSelected:", sel)
end

--@api-stub: LWidget:getSize
-- LWidget position, size, and selection state. Focus: getSize.
do
    local list = lurek.terminal.newList(5, 3, 15, 8)
    local px, py = list:getPosition()
    local w, h = list:getSize()
    list:addItem("opt1")
    list:setSelected(1)
    local sel = list:getSelected()
    print("getPosition:", px, py, "getSize:", w, h, "getSelected:", sel)
end

--@api-stub: LWidget:getSelected
-- LWidget position, size, and selection state. Focus: getSelected.
do
    local list = lurek.terminal.newList(5, 3, 15, 8)
    local px, py = list:getPosition()
    local w, h = list:getSize()
    list:addItem("opt1")
    list:setSelected(1)
    local sel = list:getSelected()
    print("getPosition:", px, py, "getSize:", w, h, "getSelected:", sel)
end

--@api-stub: LWidget:isEnabled
-- Example usage for isEnabled.
do
    local btn = lurek.terminal.newButton(0, 0, 10, 1, "Test")
    print("before:", btn:isEnabled())
    btn:setEnabled(false)
    print("after:", btn:isEnabled())
end

--@api-stub: LWidget:isVisible
-- Example usage for isVisible.
do
    local btn = lurek.terminal.newButton(0, 0, 10, 1, "Test")
    print("before:", btn:isVisible())
    btn:setVisible(false)
    print("after:", btn:isVisible())
end

--@api-stub: LWidget:type
-- LWidget runtime type name.
do
    local btn = lurek.terminal.newButton(0, 0, 10, 1, "Btn")
    print("type:", btn:type())
end

--@api-stub: LWidget:typeOf
-- LWidget typeOf identity check.
do
    local btn = lurek.terminal.newButton(0, 0, 10, 1, "Btn")
    local ok = btn:typeOf("LWidget")
    local notOk = btn:typeOf("LImage")
    print("typeOf LWidget:", ok, "typeOf LImage:", notOk)
end

--@api-stub: LWidget:setColor
-- LWidget color, enable, visible setters. Focus: setColor.
do
    local label = lurek.terminal.newLabel(0, 0, "Styled")
    label:setColor(255, 200, 100, 255)
    local r, g, b, a = label:getColor()
    print("setColor:", r, g, b, a)
end

--@api-stub: LWidget:setEnabled
-- LWidget color, enable, visible setters. Focus: setEnabled.
do
    local label = lurek.terminal.newLabel(0, 0, "Styled")
    label:setEnabled(false)
    print("setEnabled:", label:isEnabled())
end

--@api-stub: LWidget:setVisible
-- LWidget color, enable, visible setters. Focus: setVisible.
do
    local label = lurek.terminal.newLabel(0, 0, "Styled")
    label:setVisible(false)
    print("setVisible:", label:isVisible())
end

--@api-stub: LWidget:setMaxLength
-- LWidget max length, position, and size setters. Focus: setMaxLength.
do
    local tb = lurek.terminal.newTextBox(0, 0, 20)
    tb:setMaxLength(50)
    local ml = tb:getMaxLength()
    tb:setPosition(3, 5)
    local px, py = tb:getPosition()
    tb:setSize(25, 1)
    local w, h = tb:getSize()
    print("setMaxLength:", ml, "setPosition:", px, py, "setSize:", w)
end

--@api-stub: LWidget:setPosition
-- LWidget max length, position, and size setters. Focus: setPosition.
do
    local tb = lurek.terminal.newTextBox(0, 0, 20)
    tb:setMaxLength(50)
    local ml = tb:getMaxLength()
    tb:setPosition(3, 5)
    local px, py = tb:getPosition()
    tb:setSize(25, 1)
    local w, h = tb:getSize()
    print("setMaxLength:", ml, "setPosition:", px, py, "setSize:", w)
end

--@api-stub: LWidget:setSize
-- LWidget max length, position, and size setters. Focus: setSize.
do
    local tb = lurek.terminal.newTextBox(0, 0, 20)
    tb:setMaxLength(50)
    local ml = tb:getMaxLength()
    tb:setPosition(3, 5)
    local px, py = tb:getPosition()
    tb:setSize(25, 1)
    local w, h = tb:getSize()
    print("setMaxLength:", ml, "setPosition:", px, py, "setSize:", w)
end

--@api-stub: LWidget:setStyle
-- LWidget style, tag, and text setters. Focus: setStyle.
do
    local border = lurek.terminal.newBorder(0, 0, 12, 4)
    border:setStyle("double")
    local style = border:getStyle()
    border:setTag("border_ok")
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "Confirm")
    btn:setText("Confirm")
    print("setStyle:", style, "setTag ok, setText: Confirm")
end

--@api-stub: LWidget:setTag
-- LWidget style, tag, and text setters. Focus: setTag.
do
    local border = lurek.terminal.newBorder(0, 0, 12, 4)
    border:setStyle("double")
    local style = border:getStyle()
    border:setTag("border_ok")
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "Confirm")
    btn:setText("Confirm")
    print("setStyle:", style, "setTag ok, setText: Confirm")
end

--@api-stub: LWidget:setText
-- LWidget style, tag, and text setters. Focus: setText.
do
    local border = lurek.terminal.newBorder(0, 0, 12, 4)
    border:setStyle("double")
    local style = border:getStyle()
    border:setTag("border_ok")
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "Confirm")
    btn:setText("Confirm")
    print("setStyle:", style, "setTag ok, setText: Confirm")
end

--@api-stub: LWidget:setTitle
-- LWidget title, selection, and onChange callback. Focus: setTitle.
do
    local list = lurek.terminal.newList(0, 0, 20, 8)
    local border = lurek.terminal.newBorder(0, 0, 22, 10)
    border:setTitle("Options")
    list:addItem("choice1")
    list:addItem("choice2")
    list:setSelected(2)
    local sel = list:getSelected()
    print("setTitle/setSelected ok, sel:", sel)
end

--@api-stub: LWidget:setSelected
-- LWidget title, selection, and onChange callback. Focus: setSelected.
do
    local list = lurek.terminal.newList(0, 0, 20, 8)
    local border = lurek.terminal.newBorder(0, 0, 22, 10)
    border:setTitle("Options")
    list:addItem("choice1")
    list:addItem("choice2")
    list:setSelected(2)
    local sel = list:getSelected()
    list:setOnChange(function(idx) print("changed to", idx) end)
    print("setTitle/setSelected/setOnChange ok, sel:", sel)
end

--@api-stub: LWidget:setOnChange
-- LWidget title, selection, and onChange callback. Focus: setOnChange.
do
    local list = lurek.terminal.newList(0, 0, 20, 8)
    local border = lurek.terminal.newBorder(0, 0, 22, 10)
    border:setTitle("Options")
    list:addItem("choice1")
    list:addItem("choice2")
    list:setSelected(2)
    local sel = list:getSelected()
    list:setOnChange(function(idx) print("changed to", idx) end)
    print("setTitle/setSelected/setOnChange ok, sel:", sel)
end

--@api-stub: LWidget:setOnClick
-- LWidget onClick, onSelect callbacks, and removeItem. Focus: setOnClick.
do
    local btn = lurek.terminal.newButton(0, 0, 10, 1, "Click")
    btn:setOnClick(function() print("clicked") end)
    local list = lurek.terminal.newList(0, 0, 20, 8)
    list:setOnSelect(function(idx) print("selected", idx) end)
    list:addItem("remove_me")
    list:addItem("keep_me")
    list:removeItem(1)
    print("setOnClick/setOnSelect/removeItem ok")
end

--@api-stub: LWidget:setOnSelect
-- LWidget onClick, onSelect callbacks, and removeItem. Focus: setOnSelect.
do
    local btn = lurek.terminal.newButton(0, 0, 10, 1, "Click")
    btn:setOnClick(function() print("clicked") end)
    local list = lurek.terminal.newList(0, 0, 20, 8)
    list:setOnSelect(function(idx) print("selected", idx) end)
    list:addItem("remove_me")
    list:addItem("keep_me")
    list:removeItem(1)
    print("setOnClick/setOnSelect/removeItem ok")
end

--@api-stub: LWidget:removeItem
-- LWidget onClick, onSelect callbacks, and removeItem. Focus: removeItem.
do
    local btn = lurek.terminal.newButton(0, 0, 10, 1, "Click")
    btn:setOnClick(function() print("clicked") end)
    local list = lurek.terminal.newList(0, 0, 20, 8)
    list:setOnSelect(function(idx) print("selected", idx) end)
    list:addItem("remove_me")
    list:addItem("keep_me")
    list:removeItem(1)
    print("setOnClick/setOnSelect/removeItem ok")
end

print("content/examples/terminal.lua")
