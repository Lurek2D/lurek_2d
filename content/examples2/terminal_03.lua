--@api-stub: lurek.terminal.clearCompletions
--@api-stub: lurek.terminal.getCompletions
--@api-stub: lurek.terminal.getMaxRows
-- Terminal completion and size query.
do
    lurek.terminal.clearCompletions()
    local completions = lurek.terminal.getCompletions("he")
    local maxRows = lurek.terminal.getMaxRows()
    print("clearCompletions ok, getCompletions:", type(completions), "getMaxRows:", maxRows)
end

--@api-stub: LWidget:getChild
--@api-stub: LWidget:getChildCount
--@api-stub: LWidget:addChild
-- LWidget child management.
do
    local panel = lurek.terminal.newPanel(0, 0, 40, 20)
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "OK")
    panel:addChild(btn)
    local count = panel:getChildCount()
    local child = panel:getChild(1)
    print("addChild/getChild/getChildCount ok, count:", count)
end

--@api-stub: LWidget:clearChildren
--@api-stub: LWidget:removeChild
--@api-stub: LWidget:addItem
-- LWidget clear children, remove child, addItem.
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
--@api-stub: LWidget:getItem
--@api-stub: LWidget:getItemCount
-- LWidget list item access.
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
--@api-stub: LWidget:getStyle
--@api-stub: LWidget:getTag
-- LWidget appearance getters.
do
    local btn = lurek.terminal.newButton(0, 0, 10, 1, "Tag")
    btn:setTag("my_btn")
    local tag = btn:getTag()
    local color = btn:getColor()
    local style = btn:getStyle()
    print("getColor:", type(color), "getStyle:", style, "getTag:", tag)
end

--@api-stub: LWidget:getText
--@api-stub: LWidget:getTitle
--@api-stub: LWidget:getMaxLength
-- LWidget text getters.
do
    local tb = lurek.terminal.newTextBox(0, 0, 20)
    tb:setText("hello")
    local txt = tb:getText()
    tb:setTitle("Input")
    local title = tb:getTitle()
    local maxLen = tb:getMaxLength()
    print("getText:", txt, "getTitle:", title, "getMaxLength:", maxLen)
end

--@api-stub: LWidget:getPosition
--@api-stub: LWidget:getSize
--@api-stub: LWidget:getSelected
-- LWidget position, size, and selection state.
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
--@api-stub: LWidget:isVisible
--@api-stub: LWidget:type
-- LWidget state checks and type name.
do
    local btn = lurek.terminal.newButton(0, 0, 10, 1, "Test")
    local enabled = btn:isEnabled()
    local visible = btn:isVisible()
    local t = btn:type()
    print("isEnabled:", enabled, "isVisible:", visible, "type:", t)
end

--@api-stub: LWidget:typeOf
-- LWidget typeOf identity check.
do
    local btn = lurek.terminal.newButton(0, 0, 10, 1, "Btn")
    local ok = btn:typeOf("LWidget")
    local notOk = btn:typeOf("LImage")
    print("typeOf LWidget:", ok, "typeOf LImage:", notOk)
end
