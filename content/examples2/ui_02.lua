--- UI Module Part 3: input widgets — TextInput, Checkbox, Slider, SpinBox, Switch, ComboBox

--@api-stub: lurek.ui.newTextInput
-- Creating a text input field.
do
    ---@type LTextInput
    local input = lurek.ui.newTextInput()
    print("type = " .. input:type())
    print("text = '" .. input:getText() .. "'")
    input:setText("Hello")
    print("set text = " .. input:getText())
end

--@api-stub: LTextInput:setPlaceholder / getPlaceholder
-- Placeholder text for empty inputs.
do
    ---@type LTextInput
    local input = lurek.ui.newTextInput()
    input:setPlaceholder("Enter your name...")
    print("placeholder = " .. input:getPlaceholder())
end

--@api-stub: LTextInput:setMaxLength / getCursorPosition
-- Text length limits and cursor.
do
    ---@type LTextInput
    local input = lurek.ui.newTextInput()
    input:setMaxLength(50)
    input:setText("Short text")
    local pos = input:getCursorPosition()
    print("cursor at = " .. pos)
    print("focused = " .. tostring(input:isFocused()))
end

--@api-stub: lurek.ui.newCheckbox
-- Creating a checkbox widget.
do
    ---@type LCheckbox
    local cb = lurek.ui.newCheckbox("Enable Sound")
    print("type = " .. cb:type())
    print("text = " .. cb:getText())
    print("checked = " .. tostring(cb:isChecked()))
end

--@api-stub: LCheckbox:setChecked / setText
-- Toggling and relabeling a checkbox.
do
    ---@type LCheckbox
    local cb = lurek.ui.newCheckbox("Option A")
    cb:setChecked(true)
    print("checked = " .. tostring(cb:isChecked()))
    cb:setText("Option B")
    print("text = " .. cb:getText())
    cb:setChecked(false)
    print("unchecked = " .. tostring(cb:isChecked()))
end

--@api-stub: LCheckbox:setOnChange
-- Reacting to checkbox state changes.
do
    ---@type LCheckbox
    local cb = lurek.ui.newCheckbox("Fullscreen")
    cb:setOnChange(function()
        print("checkbox changed, now = " .. tostring(cb:isChecked()))
    end)
    print("change callback registered")
end

--@api-stub: lurek.ui.newSlider
-- Creating a value slider.
do
    ---@type LSlider
    local slider = lurek.ui.newSlider(0, 100)
    print("type = " .. slider:type())
    print("min = " .. slider:getMin())
    print("max = " .. slider:getMax())
    print("value = " .. slider:getValue())
end

--@api-stub: LSlider:setValue / setStep
-- Setting slider value and step increment.
do
    ---@type LSlider
    local slider = lurek.ui.newSlider(0, 1)
    slider:setStep(0.1)
    slider:setValue(0.5)
    print("value = " .. slider:getValue())
    slider:setValue(1.5)
    print("clamped = " .. slider:getValue())
end

--@api-stub: LSlider:setRange
-- Dynamically changing slider range.
do
    ---@type LSlider
    local slider = lurek.ui.newSlider(0, 10)
    slider:setValue(5)
    print("before: " .. slider:getMin() .. " to " .. slider:getMax() .. " val=" .. slider:getValue())
    slider:setRange(0, 100)
    print("after: " .. slider:getMin() .. " to " .. slider:getMax() .. " val=" .. slider:getValue())
end

--@api-stub: lurek.ui.newSpinBox
-- Creating a numeric spin box.
do
    ---@type LSpinBox
    local spin = lurek.ui.newSpinBox(1, 99)
    print("type = " .. spin:type())
    print("value = " .. spin:getValue())
    spin:setValue(50)
    print("set to 50 = " .. spin:getValue())
end

--@api-stub: LSpinBox:increment / decrement / setStep
-- Stepping a spin box value.
do
    ---@type LSpinBox
    local spin = lurek.ui.newSpinBox(0, 100)
    spin:setValue(10)
    spin:setStep(5)
    spin:increment()
    print("after increment = " .. spin:getValue())
    spin:decrement()
    spin:decrement()
    print("after 2 decrements = " .. spin:getValue())
end

--@api-stub: LSpinBox:setRange
-- Changing spin box range.
do
    ---@type LSpinBox
    local spin = lurek.ui.newSpinBox(0, 10)
    spin:setValue(8)
    spin:setRange(0, 5)
    print("clamped to range = " .. spin:getValue())
end

--@api-stub: lurek.ui.newSwitch
-- Creating a toggle switch.
do
    ---@type LSwitch
    local sw = lurek.ui.newSwitch(false)
    print("type = " .. sw:type())
    print("on = " .. tostring(sw:isOn()))
end

--@api-stub: LSwitch:setOn / toggle
-- Switching states.
do
    ---@type LSwitch
    local sw = lurek.ui.newSwitch(true)
    print("initial = " .. tostring(sw:isOn()))
    sw:toggle()
    print("toggled = " .. tostring(sw:isOn()))
    sw:setOn(true)
    print("forced on = " .. tostring(sw:isOn()))
end

--@api-stub: lurek.ui.newComboBox
-- Creating a dropdown combo box.
do
    ---@type LComboBox
    local combo = lurek.ui.newComboBox()
    print("type = " .. combo:type())
    print("items = " .. combo:getItemCount())
end

--@api-stub: LComboBox:addItem / getItem / getItemCount
-- Populating a combo box.
do
    ---@type LComboBox
    local combo = lurek.ui.newComboBox()
    combo:addItem("Easy")
    combo:addItem("Normal")
    combo:addItem("Hard")
    combo:addItem("Nightmare")
    print("item count = " .. combo:getItemCount())
    print("item 2 = " .. combo:getItem(2))
    print("item 4 = " .. combo:getItem(4))
end

--@api-stub: LComboBox:getSelectedIndex / getSelectedItem / clearItems
-- Selection and clearing.
do
    ---@type LComboBox
    local combo = lurek.ui.newComboBox()
    combo:addItem("Red")
    combo:addItem("Green")
    combo:addItem("Blue")
    local idx = combo:getSelectedIndex()
    print("selected index = " .. idx)
    local item = combo:getSelectedItem()
    print("selected item = " .. tostring(item))
    combo:clearItems()
    print("after clear = " .. combo:getItemCount())
end

--@api-stub: lurek.ui.setFocus / getFocus / clearFocus
-- Focus management.
do
    ---@type LTextInput
    local input = lurek.ui.newTextInput()
    lurek.ui.setFocus(input)
    local focused = lurek.ui.getFocus()
    print("focus set, has focus = " .. tostring(focused ~= nil))
    lurek.ui.clearFocus()
    focused = lurek.ui.getFocus()
    print("after clear = " .. tostring(focused))
end

--@api-stub: lurek.ui.focusNext / focusPrev
-- Tab-style focus navigation.
do
    ---@type LTextInput
    local a = lurek.ui.newTextInput()
    ---@type LTextInput
    local b = lurek.ui.newTextInput()
    ---@type LTextInput
    local c = lurek.ui.newTextInput()
    lurek.ui.setFocus(a)
    lurek.ui.focusNext()
    print("moved focus forward")
    lurek.ui.focusPrev()
    print("moved focus back")
end

print("ui_02.lua")
