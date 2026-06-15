-- content/examples/terminal.lua
-- Auto-generated from content/examples2/terminal_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/terminal.lua

--- Terminal Module Part 1: terminal creation, cell operations, fonts, widgets, rendering

--@api: lurek.terminal.newTerminal
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 40)
    print("type = " .. term:type())
    local cols, rows = term:getDimensions()
    print("dimensions = " .. cols .. "x" .. rows)
end

--@api: LTerminal:set
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    term:set(1, 1, "H", 1, 1, 1, 1, 0, 0, 0, 0)
    local ch, fr, fg, fb, fa, br, bg, bb, ba = term:get(1, 1)
    print("cell(1,1) ch=" .. ch .. " fg=(" .. fr .. "," .. fg .. "," .. fb .. ")")
end

--@api: LTerminal:get
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    term:set(1, 1, "H", 1, 1, 1, 1, 0, 0, 0, 0)
    local ch, fr, fg, fb, fa, br, bg, bb, ba = term:get(1, 1)
    print("cell(1,1) ch=" .. ch .. " fg=(" .. fr .. "," .. fg .. "," .. fb .. ")")
end

--@api: LTerminal:print
do
    local term = lurek.terminal.newTerminal(60, 20)
    term:print(1, 1, "Hello, Terminal!")
    term:print(1, 2, "Line two here")
    term:print(5, 5, "Centered text at col 5, row 5")
    term:print(1, 20, "Bottom row")
    local ch = term:get(1, 1)
    print("printed first cell = " .. tostring(ch))
end

--@api: LTerminal:clear
do
    local term = lurek.terminal.newTerminal(40, 10)
    term:print(1, 1, "This will be erased")
    term:print(1, 2, "And this too")
    term:clear()
    local ch = term:get(1, 1)
    print("after clear ch = " .. ch)
end

--@api: LTerminal:getCellSize
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    term:setCellSize(12, 20)
    local w, h = term:getCellSize()
    print("custom cell = " .. w .. "x" .. h)
end

--@api: LTerminal:setCellSize
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    term:setCellSize(12, 20)
    print("cell size set")
end

--@api: LTerminal:resetCellSize
do
    local term = lurek.terminal.newTerminal(80, 25)
    term:setCellSize(12, 20)
    term:resetCellSize()
    local w, h = term:getCellSize()
    print("reset cell = " .. w .. "x" .. h)
end

--@api: LTerminal:setFont
do
    local term = lurek.terminal.newTerminal(80, 25)
    term:setFont(16)
    local w, h = term:getCellSize()
    print("font 16: cell = " .. w .. "x" .. h)
    term:setFont(12)
    w, h = term:getCellSize()
    print("font 12: cell = " .. w .. "x" .. h)
end

--@api: LTerminal:render
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(60, 20)
    term:print(1, 1, "Rendering test")
    term:render()
    print("rendered at default pos")
end

--@api: LTerminal:autoResize
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(60, 20)
    term:autoResize()
    print("auto-resized window to fit grid")
end

--@api: lurek.terminal.newLabel
do
    local label = lurek.terminal.newLabel(5, 3, "Score: 0")
    local col, row = label:getPosition()
    print("label type = " .. label:type() .. " is LWidget = " .. tostring(label:typeOf("LWidget")))
    print("text = " .. label:getText() .. " position = " .. col .. ", " .. row)
    label:setText("Score: 1500")
    print("updated text = " .. label:getText())
end

--@api: lurek.terminal.newButton
do
    local clickCount = 0
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

--@api: lurek.terminal.newTextBox
do
    local input = lurek.terminal.newTextBox(5, 8, 20)
    print("input text = '" .. input:getText() .. "'")
    input:setText("Hello")
    print("set text = " .. input:getText())
    input:setMaxLength(30)
    print("max length = " .. input:getMaxLength())
    input:setOnChange(function() print("text changed to: " .. input:getText()) end)
end

--@api: lurek.terminal.newList
do
    local list = lurek.terminal.newList(2, 3, 20, 8)
    list:addItem("Sword")
    list:addItem("Shield")
    list:addItem("Potion")
    list:addItem("Scroll")
    list:addItem("Bow")
    print("item count = " .. list:getItemCount() .. " item 1 = " .. list:getItem(1) .. " item 3 = " .. list:getItem(3))
    list:setSelected(2)
    print("selected = " .. list:getSelected())
    list:setOnSelect(function() print("selection changed to " .. list:getSelected()) end)
end

--@api: lurek.terminal.newBorder
do
    local border = lurek.terminal.newBorder(1, 1, 30, 10)
    print("border style = " .. border:getStyle())
    border:setStyle("double")
    print("new style = " .. border:getStyle())
    border:setTitle("Inventory")
    print("title = " .. border:getTitle())
end

--@api: lurek.terminal.newPanel
do
    local panel = lurek.terminal.newPanel(1, 1, 40, 20)
    panel:addChild(lurek.terminal.newLabel(2, 2, "Name:"))
    panel:addChild(lurek.terminal.newLabel(2, 3, "Class:"))
    print("panel children = " .. panel:getChildCount())
    local child1 = panel:getChild(1)
    print("child 1 text = " .. child1:getText())
end

--@api: LTerminal:addWidget
do
    local term = lurek.terminal.newTerminal(60, 20)
    term:addWidget(lurek.terminal.newLabel(1, 1, "Status"))
    term:addWidget(lurek.terminal.newButton(1, 3, 10, 1, "OK"))
    print("widget count = " .. term:getWidgetCount())
end

--@api: LTerminal:removeWidget
do
    local term = lurek.terminal.newTerminal(60, 20)
    local btn = lurek.terminal.newButton(1, 3, 10, 1, "OK")
    term:addWidget(lurek.terminal.newLabel(1, 1, "Status"))
    term:addWidget(btn)
    print("widget count = " .. term:getWidgetCount())
    term:removeWidget(btn)
    print("after remove = " .. term:getWidgetCount())
end

--@api: LTerminal:getWidgetCount
do
    local term = lurek.terminal.newTerminal(60, 20)
    term:addWidget(lurek.terminal.newLabel(1, 1, "Status"))
    term:addWidget(lurek.terminal.newButton(1, 3, 10, 1, "OK"))
    print("widget count = " .. term:getWidgetCount())
end

--@api: LTerminal:clearWidgets
do
    local term = lurek.terminal.newTerminal(60, 20)
    term:addWidget(lurek.terminal.newLabel(1, 1, "Status"))
    term:addWidget(lurek.terminal.newButton(1, 3, 10, 1, "OK"))
    print("widget count = " .. term:getWidgetCount())
    term:clearWidgets()
    print("after clear = " .. term:getWidgetCount())
end

--@api: LTerminal:setFocus
do
    local term = lurek.terminal.newTerminal(60, 20)
    local input1 = lurek.terminal.newTextBox(1, 1, 15)
    term:addWidget(input1)
    term:addWidget(lurek.terminal.newTextBox(1, 3, 15))
    term:setFocus(input1)
    local focused = term:getFocused()
    print("focused = " .. tostring(focused == input1))
    term:setFocus(nil)
    focused = term:getFocused()
    print("no focus = " .. tostring(focused == nil))
end

--@api: LTerminal:getFocused
do
    local term = lurek.terminal.newTerminal(60, 20)
    term:addWidget(lurek.terminal.newTextBox(1, 1, 15))
    local input2 = lurek.terminal.newTextBox(1, 3, 15)
    term:addWidget(input2)
    term:setFocus(input2)
    local focused = term:getFocused()
    print("focused = " .. tostring(focused == input2))
    term:setFocus(nil)
    focused = term:getFocused()
    print("no focus = " .. tostring(focused == nil))
end

--@api: LTerminal:keypressed
do
    local term = lurek.terminal.newTerminal(60, 20)
    local input = lurek.terminal.newTextBox(1, 1, 20)
    term:addWidget(input)
    term:setFocus(input)
    local consumed = term:textinput("A")
    print("textinput consumed = " .. tostring(consumed))
    consumed = term:keypressed("backspace")
    print("keypressed consumed = " .. tostring(consumed))
    term:textinput("alpha beta")
    term:keypressed("ctrl+a")
    term:keypressed("ctrl+c")
    term:keypressed("ctrl+x")
    term:keypressed("ctrl+v")
    term:keypressed("ctrl+backspace")
    term:keypressed("ctrl+delete")
    term:mousepressed(50, 10, 1)
    print("mousepressed sent")
end

--@api: LTerminal:textinput
do
    local term = lurek.terminal.newTerminal(60, 20)
    local input = lurek.terminal.newTextBox(1, 1, 20)
    term:addWidget(input)
    term:setFocus(input)
    local consumed = term:textinput("A")
    print("textinput consumed = " .. tostring(consumed))
end

--@api: LTerminal:mousepressed
do
    local term = lurek.terminal.newTerminal(60, 20)
    local input = lurek.terminal.newTextBox(1, 1, 20)
    term:addWidget(input)
    term:setFocus(input)
    term:mousepressed(50, 10, 1)
    print("mousepressed sent")
end

--- Terminal Module Part 2: themes, command history, scrollback, completions, ANSI, highlighting

--@api: lurek.terminal.applyTheme
do
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

--@api: lurek.terminal.pushCmdHistory
do
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

--@api: lurek.terminal.cmdHistoryLen
do
    local term = lurek.terminal.newTerminal(80, 25)
    lurek.terminal.pushCmdHistory(term, "look")
    lurek.terminal.pushCmdHistory(term, "go north")
    lurek.terminal.pushCmdHistory(term, "take sword")
    print("history len = " .. lurek.terminal.cmdHistoryLen(term))
    lurek.terminal.clearCmdHistory(term)
    print("after clear len = " .. lurek.terminal.cmdHistoryLen(term))
end

--@api: lurek.terminal.pushScrollback
do
    local term = lurek.terminal.newTerminal(80, 25)
    lurek.terminal.pushScrollback(term, "You see a dark corridor.")
    lurek.terminal.pushScrollback(term, "A torch flickers on the wall.")
    lurek.terminal.pushScrollback(term, "You hear footsteps.")
    lurek.terminal.pushScrollback(term, "An enemy appears!")
    print("scrollback len = " .. lurek.terminal.scrollbackLen(term))
    local lines = lurek.terminal.getScrollback(term, 0, 3)
    print("recent 3 lines: " .. table.concat(lines, " | "))
end

--@api: lurek.terminal.setScrollbackCap
do
    local term = lurek.terminal.newTerminal(80, 25)
    lurek.terminal.setScrollbackCap(term, 2)
    lurek.terminal.pushScrollback(term, "Line 1")
    lurek.terminal.pushScrollback(term, "Line 2")
    lurek.terminal.pushScrollback(term, "Line 3")
    print("scrollback after overflow = " .. lurek.terminal.scrollbackLen(term))
end

--@api: lurek.terminal.addCompletion
do
    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("help")
    lurek.terminal.addCompletion("health")
    lurek.terminal.addCompletion("heal")
    lurek.terminal.addCompletion("inventory")
    lurek.terminal.addCompletion("inspect")
    local matches = lurek.terminal.getCompletions("he")
    print("matches for 'he': " .. table.concat(matches, ", "))
    local inv = lurek.terminal.getCompletions("in")
    print("matches for 'in' = " .. #inv)
end

--@api: lurek.terminal.nextCompletion
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
end

--@api: lurek.terminal.parseAnsi
do
    local ansiText = "\27[1;31mError:\27[0m File not found"
    local spans = lurek.terminal.parseAnsi(ansiText)
    print("span count = " .. #spans)
    if spans[1] then print("span 1: text='" .. spans[1].text .. "' bold=" .. tostring(spans[1].bold)) end
end

--@api: lurek.terminal.stripAnsi
do
    local colored = "\27[32mSuccess\27[0m: Operation complete"
    local plain = lurek.terminal.stripAnsi(colored)
    print("stripped = " .. plain)
    print("length original = " .. #colored)
    print("length stripped = " .. #plain)
end

--@api: lurek.terminal.printAnsi
do
    local term = lurek.terminal.newTerminal(80, 25)
    lurek.terminal.printAnsi(term, 1, 1, "\27[1;33mWarning:\27[0m Low health")
    lurek.terminal.printAnsi(term, 1, 2, "\27[34mInfo:\27[0m Checkpoint saved")
    lurek.terminal.printAnsi(term, 1, 3, "\27[1;31mCritical:\27[0m System failure")
    print("ANSI text rendered to grid")
end

--@api: lurek.terminal.printHighlighted
do
    local term = lurek.terminal.newTerminal(80, 25)
    local rules = { { pattern = "local%s+%w+", fg = { r = 100, g = 150, b = 255 } }, { pattern = '\"[^\"]*\"', fg = { r = 200, g = 200, b = 100 } }, { pattern = "%-%-%s.*$", fg = { r = 100, g = 100, b = 100 } }, { pattern = "%d+", fg = { r = 255, g = 150, b = 50 } } }
    local code = 'local name = "hero" -- player name'
    lurek.terminal.printHighlighted(term, 1, 1, code, rules)
    print("highlighted code rendered")
end

--@api: lurek.terminal.getMaxCols
do
    local maxCols = lurek.terminal.getMaxCols()
    print("max cols = " .. maxCols)
end

--@api: LLabel:setColor
do
    ---@type LWidget
    local label = lurek.terminal.newLabel(1, 1, "Colored")
    label:setColor(0.2, 0.8, 0.3, 1)
    local r, g, b, a = label:getColor()
    print("color = " .. r .. ", " .. g .. ", " .. b .. ", " .. a)
end

--@api: LButton:isEnabled
do
    ---@type LWidget
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "Submit")
    print("enabled = " .. tostring(btn:isEnabled()))
    btn:setEnabled(false)
    print("after disable = " .. tostring(btn:isEnabled()))
end

--@api: LList:addItem
do
    local list = lurek.terminal.newList(1, 1, 20, 5)
    list:addItem("Apple")
    list:addItem("Banana")
    list:addItem("Cherry")
    list:addItem("Date")
    print("items = " .. list:getItemCount())
end

--@api: LPanel:addChild
do
    local panel = lurek.terminal.newPanel(1, 1, 40, 20)
    panel:addChild(lurek.terminal.newLabel(2, 2, "Label A"))
    panel:addChild(lurek.terminal.newLabel(2, 4, "Label B"))
    panel:addChild(lurek.terminal.newButton(2, 6, 10, 1, "Btn"))
    print("children = " .. panel:getChildCount())
end

--- Terminal Part 2: LTerminal full API + missing module-level functions

--@api: LTerminal:getDimensions
do
    local term = lurek.terminal.newTerminal(80, 24)
    local cols, rows = term:getDimensions()
    print("cols=" .. cols .. " rows=" .. rows)
end

--@api: LTerminal:type
do
    local term = lurek.terminal.newTerminal(80, 24)
    print("type=" .. term:type())
end

--@api: LTerminal:typeOf
do
    local term = lurek.terminal.newTerminal(80, 24)
    print("typeOf=" .. tostring(term:typeOf("LTerminal")))
end

--@api: lurek.terminal.clearCmdHistory
do
    local term = lurek.terminal.newTerminal(40, 10)
    lurek.terminal.clearCmdHistory(term)
    local prev = lurek.terminal.prevCmd(term)
    print("prev_cmd=" .. tostring(prev))
    local next_cmd = lurek.terminal.nextCmd(term)
    print("next_cmd=" .. tostring(next_cmd))
end

--@api: lurek.terminal.prevCmd
do
    local term = lurek.terminal.newTerminal(40, 10)
    lurek.terminal.pushCmdHistory(term, "look")
    lurek.terminal.pushCmdHistory(term, "take key")
    lurek.terminal.clearCmdHistory(term)
    local prev = lurek.terminal.prevCmd(term)
    print("prev_cmd=" .. tostring(prev))
end

--@api: lurek.terminal.nextCmd
do
    local term = lurek.terminal.newTerminal(40, 10)
    lurek.terminal.pushCmdHistory(term, "north")
    lurek.terminal.pushCmdHistory(term, "east")
    print("prev_cmd=" .. tostring(lurek.terminal.prevCmd(term)))
    local next_cmd = lurek.terminal.nextCmd(term)
    print("next_cmd=" .. tostring(next_cmd))
end

--@api: lurek.terminal.getScrollback
do
    local term = lurek.terminal.newTerminal(40, 10)
    lurek.terminal.pushScrollback(term, "line one")
    lurek.terminal.pushScrollback(term, "line two")
    lurek.terminal.pushScrollback(term, "line three")
    local sb = lurek.terminal.getScrollback(term, 0, 5)
    print("scrollback count=" .. #sb)
    print("first line=" .. tostring(sb[1]))
end

--@api: lurek.terminal.scrollbackLen
do
    local term = lurek.terminal.newTerminal(40, 10)
    lurek.terminal.pushScrollback(term, "alpha")
    lurek.terminal.pushScrollback(term, "beta")
    local sb_len = lurek.terminal.scrollbackLen(term)
    print("scrollback_len=" .. sb_len)
end

--@api: lurek.terminal.removeCompletion
do
    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("test_completion")
    lurek.terminal.addCompletion("test_other")
    lurek.terminal.removeCompletion("test_completion")
    local completions = lurek.terminal.getCompletions("test")
    print("remaining completions = " .. #completions)
    print("first completion = " .. tostring(completions[1]))
end

--@api: lurek.terminal.resetCompletion
do
    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("test_completion")
    lurek.terminal.addCompletion("test_case")
    print("first = " .. tostring(lurek.terminal.nextCompletion("test")))
    lurek.terminal.resetCompletion()
    print("after reset = " .. tostring(lurek.terminal.nextCompletion("test")))
end

--@api: lurek.terminal.clearCompletions
do
    lurek.terminal.addCompletion("help")
    lurek.terminal.addCompletion("heal")
    lurek.terminal.clearCompletions()
    local completions = lurek.terminal.getCompletions("he")
    print("completion count = " .. #completions)
end

--@api: lurek.terminal.getCompletions
do
    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("help")
    lurek.terminal.addCompletion("heal")
    lurek.terminal.addCompletion("hex")
    local completions = lurek.terminal.getCompletions("he")
    print("matches = " .. #completions)
    print("first match = " .. tostring(completions[1]))
end

--@api: lurek.terminal.getMaxRows
do
    local maxRows = lurek.terminal.getMaxRows()
    local maxCols = lurek.terminal.getMaxCols()
    print("max rows = " .. maxRows)
    print("max cols = " .. maxCols)
end

--@api: LWidget:getChild
do
    local panel = lurek.terminal.newPanel(0, 0, 40, 20)
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "OK")
    panel:addChild(btn)
    local child = panel:getChild(1)
    print("child exists = " .. tostring(child ~= nil))
    print("child type = " .. tostring(child and child:type()))
end

--@api: LWidget:getChildCount
do
    local panel = lurek.terminal.newPanel(0, 0, 40, 20)
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "OK")
    panel:addChild(btn)
    panel:addChild(lurek.terminal.newLabel(1, 3, "Hint"))
    local count = panel:getChildCount()
    print("child count = " .. count)
end

--@api: LWidget:addChild
do
    local panel = lurek.terminal.newPanel(0, 0, 40, 20)
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "OK")
    panel:addChild(btn)
    local count = panel:getChildCount()
    print("child count = " .. count)
    print("first child type = " .. panel:getChild(1):type())
end

--@api: LWidget:clearChildren
do
    local panel = lurek.terminal.newPanel(0, 0, 40, 20)
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "X")
    panel:addChild(btn)
    panel:addChild(lurek.terminal.newLabel(1, 3, "Info"))
    panel:clearChildren()
    print("child count after clear = " .. panel:getChildCount())
end

--@api: LWidget:removeChild
do
    local panel = lurek.terminal.newPanel(0, 0, 40, 20)
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "X")
    panel:addChild(btn)
    panel:removeChild(btn)
    print("child count after remove = " .. panel:getChildCount())
end

--@api: LWidget:addItem
do
    local list = lurek.terminal.newList(0, 0, 20, 10)
    list:addItem("item one")
    list:addItem("item two")
    print("item count = " .. list:getItemCount())
end

--@api: LWidget:clearItems
do
    local list = lurek.terminal.newList(0, 0, 20, 10)
    list:addItem("alpha")
    list:addItem("beta")
    list:clearItems()
    print("item count after clear = " .. list:getItemCount())
end

--@api: LWidget:getItem
do
    local list = lurek.terminal.newList(0, 0, 20, 10)
    list:addItem("alpha")
    list:addItem("beta")
    local item = list:getItem(1)
    print("first item = " .. item)
end

--@api: LWidget:getItemCount
do
    local list = lurek.terminal.newList(0, 0, 20, 10)
    list:addItem("alpha")
    list:addItem("beta")
    local count = list:getItemCount()
    print("item count = " .. count)
end

--@api: LWidget:getColor
do
    local label = lurek.terminal.newLabel(0, 0, "Tag")
    label:setColor(255, 200, 100, 255)
    local r, g, b, a = label:getColor()
    print("color = " .. r .. ", " .. g .. ", " .. b .. ", " .. a)
end

--@api: LWidget:getStyle
do
    local border = lurek.terminal.newBorder(0, 1, 10, 3)
    border:setStyle("single")
    local style = border:getStyle()
    print("style = " .. style)
end

--@api: LWidget:getTag
do
    local border = lurek.terminal.newBorder(0, 1, 10, 3)
    border:setTag("my_border")
    local tag = border:getTag()
    print("tag = " .. tag)
end

--@api: LWidget:getText
do
    local tb = lurek.terminal.newTextBox(0, 0, 20)
    tb:setText("hello")
    local txt = tb:getText()
    print("text = " .. txt)
end

--@api: LWidget:getTitle
do
    local border = lurek.terminal.newBorder(0, 1, 20, 3)
    border:setTitle("Input")
    local title = border:getTitle()
    print("title = " .. title)
end

--@api: LWidget:getMaxLength
do
    local tb = lurek.terminal.newTextBox(0, 0, 20)
    tb:setMaxLength(32)
    local maxLen = tb:getMaxLength()
    print("max length = " .. maxLen)
end

--@api: LWidget:getPosition
do
    local list = lurek.terminal.newList(5, 3, 15, 8)
    local px, py = list:getPosition()
    print("position = " .. px .. ", " .. py)
end

--@api: LWidget:getSize
do
    local list = lurek.terminal.newList(5, 3, 15, 8)
    local w, h = list:getSize()
    print("size = " .. w .. "x" .. h)
end

--@api: LWidget:getSelected
do
    local list = lurek.terminal.newList(5, 3, 15, 8)
    list:addItem("opt1")
    list:addItem("opt2")
    list:setSelected(1)
    local sel = list:getSelected()
    print("selected = " .. sel)
end

--@api: LWidget:isEnabled
do
    local btn = lurek.terminal.newButton(0, 0, 10, 1, "Test")
    print("before = " .. tostring(btn:isEnabled()))
    btn:setEnabled(false)
    print("after = " .. tostring(btn:isEnabled()))
end

--@api: LWidget:isVisible
do
    local btn = lurek.terminal.newButton(0, 0, 10, 1, "Test")
    print("before = " .. tostring(btn:isVisible()))
    btn:setVisible(false)
    print("after = " .. tostring(btn:isVisible()))
end

--@api: LWidget:type
do
    local btn = lurek.terminal.newButton(0, 0, 10, 1, "Btn")
    print("type = " .. btn:type())
end

--@api: LWidget:typeOf
do
    local btn = lurek.terminal.newButton(0, 0, 10, 1, "Btn")
    local ok = btn:typeOf("LWidget")
    print("typeOf LWidget = " .. tostring(ok))
end

--@api: LWidget:setColor
do
    local label = lurek.terminal.newLabel(0, 0, "Styled")
    label:setColor(255, 200, 100, 255)
    local r, g, b, a = label:getColor()
    print("setColor = " .. r .. ", " .. g .. ", " .. b .. ", " .. a)
end

--@api: LWidget:setEnabled
do
    local label = lurek.terminal.newLabel(0, 0, "Styled")
    label:setEnabled(false)
    print("setEnabled = " .. tostring(label:isEnabled()))
end

--@api: LWidget:setVisible
do
    local label = lurek.terminal.newLabel(0, 0, "Styled")
    label:setVisible(false)
    print("setVisible = " .. tostring(label:isVisible()))
end

--@api: LWidget:setMaxLength
do
    local tb = lurek.terminal.newTextBox(0, 0, 20)
    tb:setMaxLength(50)
    local ml = tb:getMaxLength()
    print("setMaxLength = " .. ml)
end

--@api: LWidget:setPosition
do
    local tb = lurek.terminal.newTextBox(0, 0, 20)
    tb:setPosition(3, 5)
    local px, py = tb:getPosition()
    print("setPosition = " .. px .. ", " .. py)
end

--@api: LWidget:setSize
do
    local tb = lurek.terminal.newTextBox(0, 0, 20)
    tb:setSize(25, 1)
    local w, h = tb:getSize()
    print("setSize = " .. w .. "x" .. h)
end

--@api: LWidget:setStyle
do
    local border = lurek.terminal.newBorder(0, 0, 12, 4)
    border:setStyle("double")
    local style = border:getStyle()
    print("setStyle = " .. style)
end

--@api: LWidget:setTag
do
    local border = lurek.terminal.newBorder(0, 0, 12, 4)
    border:setTag("border_ok")
    print("setTag = " .. border:getTag())
end

--@api: LWidget:setText
do
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "Confirm")
    btn:setText("Apply")
    print("setText = " .. btn:getText())
end

--@api: LWidget:setTitle
do
    local border = lurek.terminal.newBorder(0, 0, 22, 10)
    border:setTitle("Options")
    print("setTitle = " .. border:getTitle())
end

--@api: LWidget:setSelected
do
    local list = lurek.terminal.newList(0, 0, 20, 8)
    list:addItem("choice1")
    list:addItem("choice2")
    list:setSelected(2)
    local sel = list:getSelected()
    print("setSelected = " .. sel)
end

--@api: LWidget:setOnChange
do
    local tb = lurek.terminal.newTextBox(0, 0, 20)
    tb:setOnChange(function(text)
        print("changed to " .. tostring(text))
    end)
    tb:setText("hello")
    print("text box length = " .. #tb:getText())
end

--@api: LWidget:setOnClick
do
    local btn = lurek.terminal.newButton(0, 0, 10, 1, "Click")
    btn:setOnClick(function() print("clicked") end)
    print("button text = " .. btn:getText())
end

--@api: LWidget:setOnSelect
do
    local list = lurek.terminal.newList(0, 0, 20, 8)
    list:addItem("small")
    list:addItem("large")
    list:setOnSelect(function(idx)
        print("selected " .. tostring(idx))
    end)
    list:setSelected(2)
    print("selected index = " .. list:getSelected())
end

--@api: LWidget:removeItem
do
    local list = lurek.terminal.newList(0, 0, 20, 8)
    list:addItem("remove_me")
    list:addItem("keep_me")
    list:removeItem(1)
    print("remaining count = " .. list:getItemCount())
    print("first item = " .. tostring(list:getItem(1)))
end
