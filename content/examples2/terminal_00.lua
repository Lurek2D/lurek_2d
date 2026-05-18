--- Terminal Module Part 1: terminal creation, cell operations, fonts, widgets, rendering

--@api-stub: lurek.terminal.newTerminal
-- Creating terminal grid instances.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 40)
    print("type = " .. term:type())
    print("is LTerminal = " .. tostring(term:typeOf("LTerminal")))
    local cols, rows = term:getDimensions()
    print("dimensions = " .. cols .. "x" .. rows)
end

--@api-stub: lurek.terminal.newTerminal (custom size)
-- Creating a small terminal.
do
    ---@type LTerminal
    local small = lurek.terminal.newTerminal(40, 20)
    local cols, rows = small:getDimensions()
    print("small = " .. cols .. "x" .. rows)
end

--@api-stub: LTerminal:set / get
-- Writing and reading individual cells.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    term:set(1, 1, "H", 1, 1, 1, 1, 0, 0, 0, 0)
    term:set(2, 1, "e", 0, 1, 0, 1, 0, 0, 0.2, 1)
    term:set(3, 1, "l", 1, 0, 0, 1)
    term:set(4, 1, "l")
    term:set(5, 1, "o")
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

--@api-stub: LTerminal:getCellSize / setCellSize / resetCellSize
-- Adjusting cell pixel dimensions.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    local w, h = term:getCellSize()
    print("default cell = " .. w .. "x" .. h)
    term:setCellSize(12, 20)
    w, h = term:getCellSize()
    print("custom cell = " .. w .. "x" .. h)
    term:resetCellSize()
    w, h = term:getCellSize()
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

--@api-stub: LTerminal:render / autoResize
-- Rendering the terminal grid.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(60, 20)
    term:print(1, 1, "Rendering test")
    term:render()
    print("rendered at default pos")
    term:render(10, 10)
    print("rendered at offset 10,10")
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
    panel:setTitle("Main Panel")
    panel:setStyle("rounded")
    local label1 = lurek.terminal.newLabel(2, 2, "Name:")
    local label2 = lurek.terminal.newLabel(2, 3, "Class:")
    panel:addChild(label1)
    panel:addChild(label2)
    print("panel children = " .. panel:getChildCount())
    local child1 = panel:getChild(1)
    print("child 1 text = " .. child1:getText())
end

--@api-stub: LTerminal:addWidget / removeWidget / getWidgetCount / clearWidgets
-- Attaching widgets to the terminal.
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

--@api-stub: LTerminal:setFocus / getFocused
-- Widget focus management.
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

--@api-stub: LTerminal:keypressed / textinput / mousepressed
-- Forwarding input events.
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

print("terminal_00.lua")
