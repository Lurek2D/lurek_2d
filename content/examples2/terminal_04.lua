--@api-stub: LWidget:setColor
--@api-stub: LWidget:setEnabled
--@api-stub: LWidget:setVisible
-- LWidget color, enable, visible setters.
do
    local btn = lurek.terminal.newButton(0, 0, 10, 1, "Styled")
    btn:setColor(255, 200, 100, 255)
    btn:setEnabled(false)
    btn:setEnabled(true)
    btn:setVisible(false)
    btn:setVisible(true)
    print("setColor/setEnabled/setVisible ok")
end

--@api-stub: LWidget:setMaxLength
--@api-stub: LWidget:setPosition
--@api-stub: LWidget:setSize
-- LWidget max length, position, and size setters.
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
--@api-stub: LWidget:setTag
--@api-stub: LWidget:setText
-- LWidget style, tag, and text setters.
do
    local btn = lurek.terminal.newButton(0, 0, 10, 1, "Init")
    btn:setStyle("primary")
    local style = btn:getStyle()
    btn:setTag("btn_ok")
    btn:setText("Confirm")
    print("setStyle:", style, "setTag ok, setText: Confirm")
end

--@api-stub: LWidget:setTitle
--@api-stub: LWidget:setSelected
--@api-stub: LWidget:setOnChange
-- LWidget title, selection, and onChange callback.
do
    local list = lurek.terminal.newList(0, 0, 20, 8)
    list:setTitle("Options")
    list:addItem("choice1")
    list:addItem("choice2")
    list:setSelected(2)
    local sel = list:getSelected()
    list:setOnChange(function(idx) print("changed to", idx) end)
    print("setTitle/setSelected/setOnChange ok, sel:", sel)
end

--@api-stub: LWidget:setOnClick
--@api-stub: LWidget:setOnSelect
--@api-stub: LWidget:removeItem
-- LWidget onClick, onSelect callbacks, and removeItem.
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
