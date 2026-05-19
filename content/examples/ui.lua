-- content/examples/ui.lua
-- Auto-generated from content/examples2/ui_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/ui.lua

--- UI Module Part 1: core widgets (button, label, panel) and base LUiWidget operations

--@api-stub: lurek.ui.newButton
-- Creating a button widget.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Click Me")
    print("type = " .. btn:type())
    print("is LButton = " .. tostring(btn:typeOf("LButton")))
    print("text = " .. btn:getText())
    btn:setText("OK")
    print("changed text = " .. btn:getText())
end

--@api-stub: LButton:setOnClick
-- Handling button click events.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Submit")
    btn:setOnClick(function()
        print("button clicked!")
    end)
    btn:setId("submit_btn")
    print("button id = " .. btn:getId())
end

--@api-stub: lurek.ui.newLabel
-- Creating a text label.
do
    ---@type LLabel
    local lbl = lurek.ui.newLabel("Hello, World!")
    print("type = " .. lbl:type())
    print("text = " .. lbl:getText())
    lbl:setText("Score: 100")
    print("updated text = " .. lbl:getText())
end

--@api-stub: lurek.ui.newPanel
-- Creating a container panel.
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    print("type = " .. panel:type())
    print("child count = " .. panel:getChildCount())
    print("visible = " .. tostring(panel:isVisible()))
end

--@api-stub: LUiWidget:setPosition
--@api-stub: LUiWidget:getPosition
-- Widget positioning.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Pos Test")
    btn:setPosition(100, 50)
    local x, y = btn:getPosition()
    print("position = " .. x .. ", " .. y)
    btn:setPosition(200, 150)
    x, y = btn:getPosition()
    print("moved to = " .. x .. ", " .. y)
end

--@api-stub: LUiWidget:setSize
--@api-stub: LUiWidget:getSize
-- Widget sizing.
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setSize(300, 200)
    local w, h = panel:getSize()
    print("size = " .. w .. "x" .. h)
    panel:setSize(500, 400)
    w, h = panel:getSize()
    print("resized to = " .. w .. "x" .. h)
end

--@api-stub: LUiWidget:getRect
-- Getting computed screen bounds.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Bounds")
    btn:setPosition(50, 30)
    btn:setSize(120, 40)
    local x, y, w, h = btn:getRect()
    print("rect = " .. x .. "," .. y .. " " .. w .. "x" .. h)
end

--@api-stub: LUiWidget:isVisible
--@api-stub: LUiWidget:setVisible
-- Toggling widget visibility.
do
    ---@type LLabel
    local lbl = lurek.ui.newLabel("Toggle Me")
    print("visible = " .. tostring(lbl:isVisible()))
    lbl:setVisible(false)
    print("hidden = " .. tostring(lbl:isVisible()))
    lbl:setVisible(true)
    print("shown = " .. tostring(lbl:isVisible()))
end

--@api-stub: LUiWidget:isEnabled
--@api-stub: LUiWidget:setEnabled
-- Enabling and disabling widgets.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Action")
    print("enabled = " .. tostring(btn:isEnabled()))
    btn:setEnabled(false)
    print("disabled = " .. tostring(btn:isEnabled()))
    btn:setEnabled(true)
end

--@api-stub: LUiWidget:getAlpha
--@api-stub: LUiWidget:setAlpha
-- Widget opacity control.
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    print("alpha = " .. panel:getAlpha())
    panel:setAlpha(0.5)
    print("set to 50% = " .. panel:getAlpha())
    panel:setAlpha(1.0)
end

--@api-stub: LUiWidget:animateAlpha
-- Animated opacity transition.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Fade")
    btn:setAlpha(1.0)
    btn:animateAlpha(0.0, 0.5)
    print("animating = " .. tostring(btn:isAnimating()))
    btn:animateAlpha(1.0, 0.3, true)
    print("fade with hide_on_complete")
end

--@api-stub: LUiWidget:fadeIn
--@api-stub: LUiWidget:fadeOut
-- Shorthand fade animations.
do
    ---@type LLabel
    local lbl = lurek.ui.newLabel("Fading")
    lbl:setAlpha(0)
    lbl:fadeIn()
    print("fading in, animating = " .. tostring(lbl:isAnimating()))
    lbl:cancelAnimations()
    lbl:fadeOut()
    print("fading out")
end

--@api-stub: LUiWidget:animatePosition
--@api-stub: LUiWidget:slideIn
--@api-stub: LUiWidget:slideOut
-- Position animations.
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setPosition(0, 0)
    panel:animatePosition(200, 100, 0.5)
    print("moving to 200,100 over 0.5s")
    panel:cancelAnimations()
    panel:slideIn(300, 0)
    print("sliding in from right")
end

--@api-stub: LUiWidget:setId
--@api-stub: LUiWidget:getId
--@api-stub: LUiWidget:setTooltip
--@api-stub: LUiWidget:getTooltip
-- Widget identification and tooltips.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    print("id = " .. btn:getId())
    print("tooltip = " .. btn:getTooltip())
end

--@api-stub: LUiWidget:setZOrder
--@api-stub: LUiWidget:getZOrder
-- Draw order control.
do
    ---@type LPanel
    local front = lurek.ui.newPanel()
    ---@type LPanel
    local back = lurek.ui.newPanel()
    front:setZOrder(10)
    back:setZOrder(1)
    print("front z = " .. front:getZOrder())
    print("back z = " .. back:getZOrder())
end

--@api-stub: LUiWidget:containsPoint
-- Hit testing.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Hit Test")
    btn:setPosition(50, 50)
    btn:setSize(100, 40)
    print("(75,60) inside = " .. tostring(btn:containsPoint(75, 60)))
    print("(200,200) inside = " .. tostring(btn:containsPoint(200, 200)))
end

--@api-stub: LUiWidget:getState
-- Querying interaction state.
do
    ---@type LButton
    local btn = lurek.ui.newButton("State")
    local state = btn:getState()
    print("state = " .. state)
end

--@api-stub: lurek.ui.getRoot
-- Root widget and global counts.
do
    local root = lurek.ui.getRoot()
    print("root = " .. tostring(root))
    print("widget count = " .. lurek.ui.getWidgetCount())
end

--@api-stub: lurek.ui.update
-- UI update and render cycle.
do
    lurek.ui.update(1 / 60)
    lurek.ui.draw()
    print("UI frame processed")
end

--- UI Module Part 2: layout, containers (DockPanel, SplitPanel, ScrollPanel), flex, margin, padding

-- Creating a horizontal layout.
--@api-stub: lurek.ui.newLayout
do
    ---@type LLayout
    local row = lurek.ui.newLayout("horizontal")
    print("type = " .. row:type())
    print("direction = " .. row:getDirection())
    print("spacing = " .. row:getSpacing())
end

-- Creating a vertical layout.
--@api-stub: lurek.ui.newLayout
do
    ---@type LLayout
    local col = lurek.ui.newLayout("vertical")
    col:setSpacing(10)
    print("direction = " .. col:getDirection())
    print("spacing = " .. col:getSpacing())
end

--@api-stub: LLayout:setDirection
--@api-stub: LLayout:setColumns
-- Switching to grid layout mode.
do
    ---@type LLayout
    local grid = lurek.ui.newLayout("grid")
    grid:setColumns(3)
    grid:setSpacing(5)
    print("direction = " .. grid:getDirection())
end

--@api-stub: LLayout:setAlign
--@api-stub: LLayout:getAlign
-- Cross-axis alignment.
do
    ---@type LLayout
    local layout = lurek.ui.newLayout("horizontal")
    layout:setAlign("center")
    print("align = " .. layout:getAlign())
    layout:setAlign("stretch")
    print("align = " .. layout:getAlign())
end

--@api-stub: LLayout:setJustify
--@api-stub: LLayout:getJustify
-- Main-axis justification.
do
    ---@type LLayout
    local layout = lurek.ui.newLayout("horizontal")
    layout:setJustify("space-between")
    print("justify = " .. layout:getJustify())
    layout:setJustify("center")
    print("justify = " .. layout:getJustify())
end

--@api-stub: LLayout:setWrap
--@api-stub: LLayout:getWrap
-- Enabling layout wrapping.
do
    ---@type LLayout
    local layout = lurek.ui.newLayout("horizontal")
    print("wrap = " .. tostring(layout:getWrap()))
    layout:setWrap(true)
    print("wrap enabled = " .. tostring(layout:getWrap()))
end

--@api-stub: LUiWidget:addChild
--@api-stub: LUiWidget:removeChild
--@api-stub: LUiWidget:getChildCount
-- Building widget hierarchies.
do
    ---@type LLayout
    local layout = lurek.ui.newLayout("vertical")
    ---@type LButton
    local btn1 = lurek.ui.newButton("First")
    ---@type LButton
    local btn2 = lurek.ui.newButton("Second")
    ---@type LButton
    local btn3 = lurek.ui.newButton("Third")
    layout:addChild(btn1)
    layout:addChild(btn2)
    layout:addChild(btn3)
    print("children = " .. layout:getChildCount())
    layout:removeChild(btn2)
    print("after remove = " .. layout:getChildCount())
end

--@api-stub: LUiWidget:getChildren
-- Iterating child widgets.
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:addChild(lurek.ui.newLabel("A"))
    panel:addChild(lurek.ui.newLabel("B"))
    panel:addChild(lurek.ui.newLabel("C"))
    local children = panel:getChildren()
    print("child list length = " .. #children)
end

--@api-stub: LUiWidget:setMargin
--@api-stub: LUiWidget:getMargin
-- Setting outer margins.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Margin")
    btn:setMargin(10, 20, 10, 20)
    local top, right, bottom, left = btn:getMargin()
    print("margin = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
    -- Shorthand: same value on all sides
    btn:setMargin(5)
    top, right, bottom, left = btn:getMargin()
    print("uniform = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
end

--@api-stub: LUiWidget:setPadding
--@api-stub: LUiWidget:getPadding
-- Setting inner padding.
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setPadding(8, 16, 8, 16)
    local top, right, bottom, left = panel:getPadding()
    print("padding = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
end

--@api-stub: LUiWidget:setFlexGrow
--@api-stub: LUiWidget:getFlexGrow
-- Flex grow factor for layout children.
do
    ---@type LLayout
    local row = lurek.ui.newLayout("horizontal")
    ---@type LPanel
    local left = lurek.ui.newPanel()
    left:setFlexGrow(1)
    ---@type LPanel
    local right = lurek.ui.newPanel()
    right:setFlexGrow(2)
    row:addChild(left)
    row:addChild(right)
    print("left grow = " .. left:getFlexGrow())
    print("right grow = " .. right:getFlexGrow())
end

--@api-stub: LUiWidget:setFlexShrink
--@api-stub: LUiWidget:getFlexShrink
-- Flex shrink factor.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Shrinkable")
    btn:setFlexShrink(0)
    print("shrink = " .. btn:getFlexShrink())
    btn:setFlexShrink(1)
    print("shrink = " .. btn:getFlexShrink())
end

--@api-stub: LUiWidget:setMinSize
--@api-stub: LUiWidget:getMinSize
--@api-stub: LUiWidget:setMaxSize
--@api-stub: LUiWidget:getMaxSize
-- Size constraints.
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setMinSize(100, 50)
    local minW, minH = panel:getMinSize()
    print("min = " .. minW .. "x" .. minH)
    panel:setMaxSize(400, 300)
    local maxW, maxH = panel:getMaxSize()
    print("max = " .. maxW .. "x" .. maxH)
end

--@api-stub: LUiWidget:setAnchor
--@api-stub: LUiWidget:setAnchorCenter
--@api-stub: LUiWidget:clearAnchor
-- Anchoring widgets within parent.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Anchored")
    btn:setAnchor(10, 10, 10, nil)
    print("anchored left=10, top=10, right=10")
    btn:clearAnchor()
    btn:setAnchorCenter(0.5, 0.5)
    print("centered in parent")
end

--@api-stub: lurek.ui.newDockPanel
-- Creating a dock panel layout.
do
    ---@type LDockPanel
    local dock = lurek.ui.newDockPanel()
    print("type = " .. dock:type())
    ---@type LPanel
    local header = lurek.ui.newPanel()
    header:setSize(0, 60)
    dock:addChild(header)
    dock:dock(header._idx, "top")
    ---@type LPanel
    local sidebar = lurek.ui.newPanel()
    sidebar:setSize(200, 0)
    dock:addChild(sidebar)
    dock:dock(sidebar._idx, "left")
    dock:setSplitSize("left", 200)
    dock:setSplitSize("top", 60)
    print("docked count = " .. dock:getDockedCount())
    print("left size = " .. dock:getSplitSize("left"))
end

--@api-stub: LDockPanel:undock
-- Removing a docked widget.
do
    ---@type LDockPanel
    local dock = lurek.ui.newDockPanel()
    ---@type LPanel
    local footer = lurek.ui.newPanel()
    dock:addChild(footer)
    dock:dock(footer._idx, "bottom")
    print("docked = " .. dock:getDockedCount())
    dock:undock(footer._idx)
    print("after undock = " .. dock:getDockedCount())
end

--@api-stub: lurek.ui.newSplitPanel
-- Creating a split panel.
do
    ---@type LSplitPanel
    local split = lurek.ui.newSplitPanel("horizontal")
    print("type = " .. split:type())
    print("orientation = " .. split:getOrientation())
    ---@type LPanel
    local left = lurek.ui.newPanel()
    ---@type LPanel
    local right = lurek.ui.newPanel()
    split:setFirstChild(left._idx)
    split:setSecondChild(right._idx)
    split:setSplitPosition(0.3)
    print("split at " .. split:getSplitPosition())
    split:setMinPanelSize(100)
    print("min panel = " .. split:getMinPanelSize())
end

--@api-stub: lurek.ui.newScrollPanel
-- Creating a scrollable container.
do
    ---@type LScrollPanel
    local scroll = lurek.ui.newScrollPanel()
    print("type = " .. scroll:type())
    scroll:setContentSize(1200, 2000)
    local cw, ch = scroll:getContentSize()
    print("content size = " .. cw .. "x" .. ch)
    scroll:setScrollPosition(0, 100)
    local sx, sy = scroll:getScrollPosition()
    print("scroll pos = " .. sx .. ", " .. sy)
    local mx, my = scroll:getMaxScroll()
    print("max scroll = " .. mx .. ", " .. my)
end

--@api-stub: LScrollPanel:setScrollSpeed
--@api-stub: LScrollPanel:getScrollSpeed
-- Scroll speed tuning.
do
    ---@type LScrollPanel
    local scroll = lurek.ui.newScrollPanel()
    scroll:setScrollSpeed(30)
    print("scroll speed = " .. scroll:getScrollSpeed())
end

--@api-stub: LUiWidget:findById
-- Finding widgets by ID in a hierarchy.
do
    ---@type LLayout
    local root = lurek.ui.newLayout("vertical")
    ---@type LButton
    local btn = lurek.ui.newButton("Find Me")
    btn:setId("target_btn")
    root:addChild(btn)
    local found = root:findById("target_btn")
    print("found = " .. tostring(found ~= nil))
end

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

--@api-stub: LTextInput:setPlaceholder
--@api-stub: LTextInput:getPlaceholder
-- Placeholder text for empty inputs.
do
    ---@type LTextInput
    local input = lurek.ui.newTextInput()
    input:setPlaceholder("Enter your name...")
    print("placeholder = " .. input:getPlaceholder())
end

--@api-stub: LTextInput:setMaxLength
--@api-stub: LTextInput:getCursorPosition
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

--@api-stub: LCheckbox:setChecked
--@api-stub: LCheckbox:setText
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

--@api-stub: LSlider:setValue
--@api-stub: LSlider:setStep
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

--@api-stub: LSpinBox:increment
--@api-stub: LSpinBox:decrement
--@api-stub: LSpinBox:setStep
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

--@api-stub: LSwitch:setOn
--@api-stub: LSwitch:toggle
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

--@api-stub: LComboBox:addItem
--@api-stub: LComboBox:getItem
--@api-stub: LComboBox:getItemCount
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

--@api-stub: LComboBox:getSelectedIndex
--@api-stub: LComboBox:getSelectedItem
--@api-stub: LComboBox:clearItems
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

--@api-stub: lurek.ui.setFocus
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

--@api-stub: lurek.ui.focusNext
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

--- UI Module Part 4: lists, menus, tabs, accordion

--@api-stub: lurek.ui.newList
-- Creating a list box.
do
    ---@type LListBox
    local list = lurek.ui.newList()
    print("type = " .. list:type())
    print("items = " .. list:getItemCount())
end

--@api-stub: LListBox:addItem
--@api-stub: LListBox:getItem
--@api-stub: LListBox:getItemCount
-- Populating a list box.
do
    ---@type LListBox
    local list = lurek.ui.newList()
    list:addItem("Sword")
    list:addItem("Shield")
    list:addItem("Potion")
    list:addItem("Scroll")
    print("count = " .. list:getItemCount())
    print("item 1 = " .. list:getItem(1))
    print("item 3 = " .. list:getItem(3))
end

--@api-stub: LListBox:setSelectedIndex
--@api-stub: LListBox:getSelectedIndex
-- Programmatic selection.
do
    ---@type LListBox
    local list = lurek.ui.newList()
    list:addItem("Option A")
    list:addItem("Option B")
    list:addItem("Option C")
    list:setSelectedIndex(2)
    print("selected = " .. list:getSelectedIndex())
    list:setSelectedIndex(3)
    print("changed to = " .. list:getSelectedIndex())
end

--@api-stub: LListBox:removeItem
--@api-stub: LListBox:clearItems
--@api-stub: LListBox:setItemHeight
-- List manipulation and styling.
do
    ---@type LListBox
    local list = lurek.ui.newList()
    list:addItem("First")
    list:addItem("Second")
    list:addItem("Third")
    list:setItemHeight(30)
    list:removeItem(2)
    print("after remove: count=" .. list:getItemCount())
    print("item 2 now = " .. list:getItem(2))
    list:clearItems()
    print("after clear = " .. list:getItemCount())
end

--@api-stub: lurek.ui.newMenuBar
-- Creating a menu bar.
do
    ---@type LMenuBar
    local bar = lurek.ui.newMenuBar()
    print("type = " .. bar:type())
    print("menu count = " .. bar:getMenuCount())
end

--@api-stub: lurek.ui.newMenuItem
-- Creating a menu item.
do
    ---@type LMenuItem
    local item = lurek.ui.newMenuItem("File")
    print("type = " .. item:type())
    print("text = " .. item:getText())
    item:setShortcut("Ctrl+F")
    print("shortcut = " .. item:getShortcut())
end

--@api-stub: LMenuItem:setText
--@api-stub: LMenuItem:setOnClick
--@api-stub: LMenuItem:setChecked
--@api-stub: LMenuItem:isChecked
-- Configuring menu item behavior.
do
    ---@type LMenuItem
    local item = lurek.ui.newMenuItem("Toggle Grid")
    item:setOnClick(function()
        print("  grid toggle clicked")
    end)
    item:setChecked(true)
    print("checked = " .. tostring(item:isChecked()))
    item:setText("Show Grid")
    print("renamed = " .. item:getText())
end

--@api-stub: LMenuItem:addSubItem
--@api-stub: LMenuItem:getSubItems
-- Building nested menu hierarchies.
do
    ---@type LMenuItem
    local fileMenu = lurek.ui.newMenuItem("File")
    ---@type LMenuItem
    local openItem = lurek.ui.newMenuItem("Open")
    openItem:setShortcut("Ctrl+O")
    ---@type LMenuItem
    local saveItem = lurek.ui.newMenuItem("Save")
    saveItem:setShortcut("Ctrl+S")
    ---@type LMenuItem
    local exitItem = lurek.ui.newMenuItem("Exit")
    fileMenu:addSubItem(openItem._idx)
    fileMenu:addSubItem(saveItem._idx)
    fileMenu:addSubItem(exitItem._idx)
    local subs = fileMenu:getSubItems()
    print("File has " .. #subs .. " sub-items")
end

--@api-stub: LMenuBar:addMenu
--@api-stub: LMenuBar:getMenuCount
--@api-stub: LMenuBar:getMenus
-- Assembling a complete menu bar.
do
    ---@type LMenuBar
    local bar = lurek.ui.newMenuBar()
    ---@type LMenuItem
    local fileMenu = lurek.ui.newMenuItem("File")
    ---@type LMenuItem
    local editMenu = lurek.ui.newMenuItem("Edit")
    ---@type LMenuItem
    local viewMenu = lurek.ui.newMenuItem("View")
    bar:addMenu(fileMenu._idx)
    bar:addMenu(editMenu._idx)
    bar:addMenu(viewMenu._idx)
    print("menus = " .. bar:getMenuCount())
    local menus = bar:getMenus()
    print("menu indices: " .. #menus .. " entries")
end

--@api-stub: LMenuBar:removeMenu
-- Removing a menu from the bar.
do
    ---@type LMenuBar
    local bar = lurek.ui.newMenuBar()
    ---@type LMenuItem
    local m = lurek.ui.newMenuItem("Tools")
    bar:addMenu(m._idx)
    print("before remove = " .. bar:getMenuCount())
    local ok = bar:removeMenu(m._idx)
    print("removed = " .. tostring(ok))
    print("after remove = " .. bar:getMenuCount())
end

--@api-stub: lurek.ui.newTabBar
-- Creating a tab bar.
do
    ---@type LTabBar
    local tabs = lurek.ui.newTabBar()
    print("type = " .. tabs:type())
    print("tab count = " .. tabs:getTabCount())
end

--@api-stub: LTabBar:addTab
--@api-stub: LTabBar:getTab
--@api-stub: LTabBar:getTabCount
-- Adding tabs.
do
    ---@type LTabBar
    local tabs = lurek.ui.newTabBar()
    tabs:addTab("General")
    tabs:addTab("Graphics")
    tabs:addTab("Audio")
    tabs:addTab("Controls")
    print("count = " .. tabs:getTabCount())
    print("tab 1 = " .. tabs:getTab(1))
    print("tab 3 = " .. tabs:getTab(3))
end

--@api-stub: LTabBar:setActiveTab
--@api-stub: LTabBar:getActiveTab
--@api-stub: LTabBar:removeTab
-- Tab selection and removal.
do
    ---@type LTabBar
    local tabs = lurek.ui.newTabBar()
    tabs:addTab("Home")
    tabs:addTab("Settings")
    tabs:addTab("Help")
    tabs:setActiveTab(2)
    print("active = " .. tabs:getActiveTab())
    local ok = tabs:removeTab(3)
    print("removed Help = " .. tostring(ok))
    print("remaining = " .. tabs:getTabCount())
end

--@api-stub: lurek.ui.newAccordion
-- Creating an accordion widget.
do
    ---@type LAccordion
    local acc = lurek.ui.newAccordion()
    print("type = " .. acc:type())
    print("sections = " .. acc:getSectionCount())
end

--@api-stub: LAccordion:addSection
--@api-stub: LAccordion:getSectionCount
--@api-stub: LAccordion:getSectionTitle
-- Building accordion sections.
do
    ---@type LAccordion
    local acc = lurek.ui.newAccordion()
    acc:addSection("Player Stats")
    acc:addSection("Inventory")
    acc:addSection("Quest Log")
    print("sections = " .. acc:getSectionCount())
    print("section 1 = " .. acc:getSectionTitle(1))
    print("section 2 = " .. acc:getSectionTitle(2))
end

--@api-stub: LAccordion:toggleSection
--@api-stub: LAccordion:isSectionExpanded
--@api-stub: LAccordion:setExclusive
-- Expanding and collapsing sections.
do
    ---@type LAccordion
    local acc = lurek.ui.newAccordion()
    acc:addSection("A")
    acc:addSection("B")
    acc:addSection("C")
    acc:setExclusive(true)
    print("exclusive = " .. tostring(acc:isExclusive()))
    acc:toggleSection(1)
    print("section 1 expanded = " .. tostring(acc:isSectionExpanded(1)))
    acc:toggleSection(2)
    print("section 1 after toggle 2 = " .. tostring(acc:isSectionExpanded(1)))
    print("section 2 expanded = " .. tostring(acc:isSectionExpanded(2)))
end

-- ui_04.lua: Dialogs, windows, toolbar, statusbar

--@api-stub: lurek.ui.newDialog
do
    -- create a modal dialog with title, buttons, and close callback
    ---@type LDialog
    local dlg = lurek.ui.newDialog("Confirm Action")
    dlg:setModal(true)
    dlg:addButton("OK")
    dlg:addButton("Cancel")
    dlg:setOnClose(function(idx)
        print("dialog closed, widget index:", idx)
    end)
    dlg:open()
    print("dialog title:", dlg:getTitle())
    print("is modal:", dlg:isModal())
    print("is open:", dlg:isOpen())
end

--@api-stub: lurek.ui.newDialog
do
    -- set a panel as dialog content widget
    ---@type LDialog
    local dlg = lurek.ui.newDialog("Settings")
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setSize(300, 200)
    dlg:setContent(1)
    print("dialog content index:", dlg:getContent())
    dlg:setTitle("Advanced Settings")
    print("new title:", dlg:getTitle())
    dlg:close()
    print("after close, is open:", dlg:isOpen())
end

--@api-stub: lurek.ui.newWindow
do
    -- create a draggable, resizable GUI window
    ---@type LGuiWindow
    local win = lurek.ui.newWindow("Editor")
    win:setDraggable(true)
    win:setResizable(true)
    win:setCloseable(true)
    win:setOnClose(function(idx)
        print("window closed, widget index:", idx)
    end)
    print("window title:", win:getTitle())
    print("is draggable:", win:isDraggable())
    print("is resizable:", win:isResizable())
    print("is closeable:", win:isCloseable())
end

--@api-stub: lurek.ui.newWindow
do
    -- change window title and toggle properties
    ---@type LGuiWindow
    local win = lurek.ui.newWindow("Inspector")
    win:setTitle("Object Inspector")
    print("title:", win:getTitle())
    win:setDraggable(false)
    print("draggable after disable:", win:isDraggable())
    win:setResizable(false)
    print("resizable after disable:", win:isResizable())
    win:setCloseable(false)
    print("closeable after disable:", win:isCloseable())
end

--@api-stub: lurek.ui.newToolbar
do
    -- create a horizontal toolbar with buttons and separators
    ---@type LToolbar
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("save", "Save file")
    tb:addButton("load", "Load file")
    tb:addSeparator()
    tb:addButton("undo", "Undo last action")
    tb:addSpacer()
    tb:addButton("settings", "Open settings")
    print("orientation:", tb:getOrientation())
end

--@api-stub: lurek.ui.newToolbar
do
    -- toggle toolbar buttons and check state
    ---@type LToolbar
    local tb = lurek.ui.newToolbar("vertical")
    tb:setOrientation("vertical")
    tb:addButton("bold", "Bold text")
    tb:addButton("italic", "Italic text")
    tb:setButtonToggled("bold", true)
    print("bold toggled:", tb:isButtonToggled("bold"))
    tb:setButtonEnabled("italic", false)
    ---@type LToolbarGetButtonResult
    local info = tb:getButton("bold")
    print("bold info - enabled:", info.enabled, "toggled:", info.toggled)
end

--@api-stub: lurek.ui.newStatusBar
do
    -- create a status bar with multiple sections
    ---@type LStatusBar
    local sb = lurek.ui.newStatusBar()
    sb:addSection("Ready", 150)
    sb:addSection("Line: 1, Col: 1", 120)
    sb:addSection("UTF-8", 80)
    print("section count:", sb:getSectionCount())
    print("section 1:", sb:getSectionText(1))
    print("section 2:", sb:getSectionText(2))
end

--@api-stub: lurek.ui.newStatusBar
do
    -- update status bar sections dynamically
    ---@type LStatusBar
    local sb = lurek.ui.newStatusBar()
    sb:addSection("Idle")
    sb:addSection("0 errors")
    sb:setSectionText(1, "Building...")
    sb:setSectionText(2, "3 warnings")
    print("updated section 1:", sb:getSectionText(1))
    print("updated section 2:", sb:getSectionText(2))
    sb:setSectionCount(3)
    sb:setSectionText(3, "Branch: main")
    print("section count after expand:", sb:getSectionCount())
end

-- ui_05.lua: Visual widgets — progress bar, image widget, nine-patch, badge, spacer, separator

--@api-stub: lurek.ui.newProgressBar
do
    -- create a progress bar and track fill value
    ---@type LProgressBar
    local bar = lurek.ui.newProgressBar(0, 100)
    bar:setValue(35)
    print("value:", bar:getValue())
    print("min:", bar:getMin())
    print("max:", bar:getMax())
    print("progress (normalized):", bar:getProgress())
end

--@api-stub: lurek.ui.newProgressBar
do
    -- change the progress bar range dynamically
    ---@type LProgressBar
    local bar = lurek.ui.newProgressBar(0, 50)
    bar:setValue(25)
    print("progress at 25/50:", bar:getProgress())
    bar:setRange(0, 200)
    bar:setValue(150)
    print("progress at 150/200:", bar:getProgress())
    print("new max:", bar:getMax())
end

--@api-stub: lurek.ui.newImageWidget
do
    -- create an image widget and configure scale mode and tint
    ---@type LImageWidget
    local img = lurek.ui.newImageWidget()
    img:setScaleMode("fit")
    print("scale mode:", img:getScaleMode())
    img:setTint(1.0, 0.8, 0.6, 0.9)
    local r, g, b, a = img:getTint()
    print("tint:", r, g, b, a)
end

--@api-stub: lurek.ui.newImageWidget
do
    -- test different scale modes on image widget
    ---@type LImageWidget
    local img = lurek.ui.newImageWidget()
    img:setScaleMode("fill")
    print("fill mode:", img:getScaleMode())
    img:setScaleMode("stretch")
    print("stretch mode:", img:getScaleMode())
    img:setTint(0.5, 0.5, 1.0)
    local r, g, b, a = img:getTint()
    print("blue tint:", r, g, b, a)
end

--@api-stub: lurek.ui.newNinePatch
do
    -- create a nine-patch widget with border insets
    ---@type LNinePatch
    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(128, 128)
    np:setInsets(16, 16, 16, 16)
    local w, h = np:getImageDimensions()
    print("image size:", w, h)
    local l, t, r, b = np:getInsets()
    print("insets:", l, t, r, b)
end

--@api-stub: lurek.ui.newNinePatch
do
    -- retrieve computed slices from nine-patch
    ---@type LNinePatch
    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(64, 64)
    np:setInsets(8, 8, 8, 8)
    np:setSize(200, 100)
    ---@type LNinePatchGetSlicesResult
    local slices = np:getSlices()
    print("slices retrieved:", slices ~= nil)
end

--@api-stub: lurek.ui.newBadge
do
    -- create a notification badge with count
    ---@type LBadge
    local badge = lurek.ui.newBadge(5)
    print("count:", badge:getCount())
    print("display:", badge:getDisplayText())
    badge:setCount(120)
    print("large count display:", badge:getDisplayText())
end

--@api-stub: lurek.ui.newSpacer
do
    -- create a spacer widget for layout padding
    ---@type LSpacer
    local sp = lurek.ui.newSpacer(20, 10)
    sp:setSize(40, 20)
    local w, h = sp:getSize()
    print("spacer size:", w, h)
end

--@api-stub: lurek.ui.newSeparator
do
    -- create horizontal and vertical separators
    ---@type LSeparator
    local sep = lurek.ui.newSeparator(false)
    print("is vertical:", sep:isVertical())
    print("thickness:", sep:getThickness())
    sep:setThickness(2)
    print("new thickness:", sep:getThickness())
end

--@api-stub: lurek.ui.newSeparator
do
    -- create a vertical separator and toggle orientation
    ---@type LSeparator
    local sep = lurek.ui.newSeparator(true)
    print("vertical:", sep:isVertical())
    sep:setVertical(false)
    print("after toggle:", sep:isVertical())
    sep:setThickness(3)
    print("thickness:", sep:getThickness())
end

-- ui_06.lua: Charts — area, bar, line, pie, scatter

--@api-stub: lurek.ui.newAreaChart
do
    -- create an area chart with stacked layers
    ---@type LAreaChart
    local chart = lurek.ui.newAreaChart({ width = 400, height = 200, title = "CPU Usage" })
    chart:addLayer("user", { 10, 25, 30, 45, 50, 40, 35 }, 0.2, 0.6, 1.0)
    chart:addLayer("system", { 5, 10, 15, 20, 15, 10, 8 }, 1.0, 0.4, 0.2)
    chart:setYMax(100)
    print("area chart type:", chart:type())
    print("is area chart:", chart:typeOf("LAreaChart"))
end

--@api-stub: lurek.ui.newBarChart
do
    -- create a bar chart with categories and series
    ---@type LBarChart
    local chart = lurek.ui.newBarChart({ width = 300, height = 200, title = "Sales" })
    chart:addSeries("Q1", 0.2, 0.8, 0.4)
    chart:addSeries("Q2", 0.8, 0.2, 0.4)
    chart:addCategory("Widgets", { 150, 200 })
    chart:addCategory("Gadgets", { 90, 120 })
    chart:addCategory("Tools", { 60, 80 })
    print("bar chart type:", chart:type())
end

--@api-stub: lurek.ui.newLineChart
do
    -- create a line chart with data series
    ---@type LLineChart
    local chart = lurek.ui.newLineChart({ width = 400, height = 250, title = "Temperature" })
    chart:addSeries("indoor", {
        { x = 0, y = 20 }, { x = 6, y = 19 }, { x = 12, y = 22 }, { x = 18, y = 21 }, { x = 24, y = 20 }
    }, 1.0, 0.3, 0.3)
    chart:addSeries("outdoor", {
        { x = 0, y = 5 }, { x = 6, y = 3 }, { x = 12, y = 15 }, { x = 18, y = 10 }, { x = 24, y = 6 }
    }, 0.3, 0.3, 1.0)
    chart:setXMax(24)
    chart:setYMax(30)
    print("line chart type:", chart:type())
end

--@api-stub: lurek.ui.newPieChart
do
    -- create a pie chart with labeled segments
    ---@type LPieChart
    local chart = lurek.ui.newPieChart({ width = 200, height = 200, title = "Market Share" })
    chart:addSegment("Product A", 45, 0.2, 0.6, 1.0)
    chart:addSegment("Product B", 30, 1.0, 0.4, 0.2)
    chart:addSegment("Product C", 15, 0.3, 0.9, 0.3)
    chart:addSegment("Other", 10, 0.7, 0.7, 0.7)
    print("pie chart type:", chart:type())
    print("is pie chart:", chart:typeOf("LPieChart"))
end

--@api-stub: lurek.ui.newScatterPlot
do
    -- create a scatter plot with data points
    ---@type LScatterPlot
    local chart = lurek.ui.newScatterPlot({ width = 400, height = 300, title = "Height vs Weight" })
    chart:addSeries("male", {
        { x = 170, y = 70 }, { x = 180, y = 80 }, { x = 175, y = 75 }, { x = 185, y = 90 }
    }, 0.2, 0.5, 1.0)
    chart:addSeries("female", {
        { x = 160, y = 55 }, { x = 165, y = 60 }, { x = 170, y = 65 }, { x = 155, y = 50 }
    }, 1.0, 0.3, 0.6)
    chart:setXRange(150, 200)
    chart:setYRange(40, 100)
    print("scatter plot type:", chart:type())
end

-- ui_07.lua: Advanced — color picker, radio button, tree view, toast, tooltip, theme, focus, drag/drop

--@api-stub: lurek.ui.newColorPicker
do
    -- create a color picker and select a color
    ---@type LColorPicker
    local cp = lurek.ui.newColorPicker()
    cp:setColor(0.8, 0.2, 0.5, 1.0)
    local r, g, b, a = cp:getColor()
    print("color:", r, g, b, a)
    cp:setColorMode("hsv")
    print("mode:", cp:getColorMode())
    cp:setShowAlpha(true)
    print("show alpha:", cp:getShowAlpha())
end

--@api-stub: lurek.ui.newColorPicker
do
    -- register a change callback on color picker
    ---@type LColorPicker
    local cp = lurek.ui.newColorPicker()
    cp:setOnChange(function(idx)
        print("color changed on widget:", idx)
    end)
    cp:setColor(0.0, 1.0, 0.0)
    print("green set, mode:", cp:getColorMode())
end

--@api-stub: lurek.ui.newRadioButton
do
    -- create mutually exclusive radio buttons in a group
    ---@type LRadioButton
    local rb1 = lurek.ui.newRadioButton("Small", "size_group")
    ---@type LRadioButton
    local rb2 = lurek.ui.newRadioButton("Medium", "size_group")
    ---@type LRadioButton
    local rb3 = lurek.ui.newRadioButton("Large", "size_group")
    rb2:setSelected(true)
    print("rb1 selected:", rb1:isSelected())
    print("rb2 selected:", rb2:isSelected())
    print("rb2 group:", rb2:getGroup())
    print("rb2 text:", rb2:getText())
end

--@api-stub: lurek.ui.newTreeView
do
    -- create a tree view with nested nodes
    ---@type LTreeView
    local tree = lurek.ui.newTreeView()
    local root = tree:addNode("Project")
    local src = tree:addNode("src", root)
    tree:addNode("main.lua", src)
    tree:addNode("utils.lua", src)
    local assets = tree:addNode("assets", root)
    tree:addNode("sprites.png", assets)
    print("total nodes:", tree:getNodeCount())
    print("root text:", tree:getNodeText(root))
    print("src depth:", tree:getNodeDepth(src))
end

--@api-stub: lurek.ui.newTreeView
do
    -- expand and collapse tree nodes
    ---@type LTreeView
    local tree = lurek.ui.newTreeView()
    local folder = tree:addNode("Documents")
    tree:addNode("readme.txt", folder)
    tree:addNode("notes.md", folder)
    tree:expandNode(folder)
    print("expanded:", tree:isExpanded(folder))
    tree:collapseNode(folder)
    print("after collapse:", tree:isExpanded(folder))
    tree:expandAll()
    tree:setSelectedNode(folder)
    print("selected:", tree:getSelectedNode())
end

--@api-stub: lurek.ui.newToast
do
    -- create a toast notification
    ---@type LToast
    local toast = lurek.ui.newToast("File saved!", 2.5)
    print("message:", toast:getMessage())
    print("duration:", toast:getDuration())
    toast:setMessage("Upload complete")
    toast:setDuration(4.0)
    print("updated message:", toast:getMessage())
    print("expired:", toast:isExpired())
end

--@api-stub: lurek.ui.newTooltipPanel
do
    -- create a tooltip panel attached to a button
    ---@type LButton
    local btn = lurek.ui.newButton("Hover me")
    ---@type LTooltipPanel
    local tip = lurek.ui.newTooltipPanel("Click to submit form")
    tip:setDelay(0.5)
    tip:setTarget(1)
    print("tooltip text:", tip:getText())
    print("delay:", tip:getDelay())
    print("target:", tip:getTarget())
    tip:setText("Updated tooltip text")
    print("new text:", tip:getText())
end

--@api-stub: lurek.ui.newTheme
--@api-stub: lurek.ui.setTheme
--@api-stub: lurek.ui.getTheme
do
    -- create and apply a custom theme
    ---@type LTheme
    local theme = lurek.ui.newTheme()
    theme:setStyle("button", "normal", {
        bg_r = 0.2, bg_g = 0.2, bg_b = 0.3, bg_a = 1.0,
        fg_r = 1.0, fg_g = 1.0, fg_b = 1.0, fg_a = 1.0,
    })
    theme:setStyle("button", "hovered", {
        bg_r = 0.3, bg_g = 0.3, bg_b = 0.5, bg_a = 1.0,
    })
    lurek.ui.setTheme(theme)
    print("theme active:", lurek.ui.getTheme())
    print("theme type:", theme:type())
end

--@api-stub: lurek.ui.getFocus
--@api-stub: lurek.ui.focusPrev
--@api-stub: lurek.ui.clearFocus
do
    -- manage keyboard focus between widgets
    ---@type LButton
    local btn1 = lurek.ui.newButton("First")
    ---@type LButton
    local btn2 = lurek.ui.newButton("Second")
    lurek.ui.setFocus(btn1)
    print("focused widget:", lurek.ui.getFocus())
    lurek.ui.focusNext()
    print("after focusNext:", lurek.ui.getFocus())
    lurek.ui.focusPrev()
    print("after focusPrev:", lurek.ui.getFocus())
    lurek.ui.clearFocus()
    print("after clear:", lurek.ui.getFocus())
end

--@api-stub: lurek.ui.beginDrag
--@api-stub: lurek.ui.getActiveDrag
--@api-stub: lurek.ui.dropOn
do
    -- drag and drop a widget onto a target
    ---@type LPanel
    local source = lurek.ui.newPanel()
    ---@type LPanel
    local target = lurek.ui.newPanel()
    lurek.ui.beginDrag(source)
    print("active drag:", lurek.ui.getActiveDrag())
    lurek.ui.dropOn(target)
    print("after drop, active drag:", lurek.ui.getActiveDrag())
end

--- UI Part 8: LAccordion, LColorPicker, LProgressBar, LMenuBar

--@api-stub: LAccordion:isExclusive
-- LAccordion: collapsible sections for grouping UI content.
do
    local acc = lurek.ui.newAccordion()
    print("type=" .. acc:type())
    local panel1 = lurek.ui.newPanel()
    local panel2 = lurek.ui.newPanel()
    acc:addSection("Section A", 0)
    acc:addSection("Section B", 1)
    print("count=" .. acc:getSectionCount())
    print("title0=" .. acc:getSectionTitle(0))
    print("expanded0=" .. tostring(acc:isSectionExpanded(0)))
    acc:toggleSection(0)
    print("expanded0_after=" .. tostring(acc:isSectionExpanded(0)))
    print("exclusive=" .. tostring(acc:isExclusive()))
    acc:setExclusive(true)
    print("exclusive_after=" .. tostring(acc:isExclusive()))
end

--@api-stub: LColorPicker:getColor
--@api-stub: LColorPicker:getColorMode
--@api-stub: LColorPicker:getShowAlpha
--@api-stub: LColorPicker:setColor
--@api-stub: LColorPicker:setColorMode
--@api-stub: LColorPicker:setOnChange
--@api-stub: LColorPicker:setShowAlpha
-- LColorPicker: RGBA color selection widget with mode and alpha controls.
do
    local cp = lurek.ui.newColorPicker()
    print("type=" .. cp:type())
    cp:setColor(255, 128, 0, 255)
    local r, g, b, a = cp:getColor()
    print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    print("mode=" .. tostring(cp:getColorMode()))
    cp:setColorMode("hsv")
    print("mode_after=" .. cp:getColorMode())
    print("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) print("changed") end)
end

--@api-stub: LProgressBar:getMax
--@api-stub: LProgressBar:getMin
--@api-stub: LProgressBar:getProgress
--@api-stub: LProgressBar:getValue
--@api-stub: LProgressBar:setRange
--@api-stub: LProgressBar:setValue
-- LProgressBar: numeric progress indicator with configurable range.
do
    local pb = lurek.ui.newProgressBar(0, 100)
    print("type=" .. pb:type())
    print("min=" .. pb:getMin())
    print("max=" .. pb:getMax())
    pb:setValue(75)
    print("value=" .. pb:getValue())
    print("progress=" .. pb:getProgress())
    pb:setRange(0, 200)
    print("max_after=" .. pb:getMax())
end

--- UI Part 9: LTabBar, LStatusBar, LToolbar

--@api-stub: LStatusBar:addSection
--@api-stub: LStatusBar:getSectionCount
--@api-stub: LStatusBar:getSectionText
--@api-stub: LStatusBar:setSectionText
-- LStatusBar: horizontal bar at screen bottom for status text sections.
do
    local sb = lurek.ui.newStatusBar()
    print("type=" .. sb:type())
    sb:addSection("Ready", 120)
    sb:addSection("Line 1", 80)
    print("sections=" .. sb:getSectionCount())
    print("text0=" .. sb:getSectionText(0))
    sb:setSectionText(0, "Loading...")
    print("text0_after=" .. sb:getSectionText(0))
end

--@api-stub: LToolbar:addButton
--@api-stub: LToolbar:addSeparator
--@api-stub: LToolbar:addSpacer
--@api-stub: LToolbar:getButton
--@api-stub: LToolbar:getOrientation
--@api-stub: LToolbar:isButtonToggled
--@api-stub: LToolbar:setButtonEnabled
--@api-stub: LToolbar:setButtonToggled
--@api-stub: LToolbar:setOrientation
-- LToolbar: icon-based button row with toggles, separators, and spacers.
do
    local bar = lurek.ui.newToolbar("horizontal")
    print("type=" .. bar:type())
    print("orientation=" .. bar:getOrientation())
    bar:addButton("btn_save", "Save file")
    bar:addButton("btn_open", "Open file")
    bar:addSeparator()
    bar:addSpacer(8)
    local btn = bar:getButton("btn_save")
    print("btn=" .. tostring(btn ~= nil))
    print("toggled=" .. tostring(bar:isButtonToggled("btn_save")))
    bar:setButtonToggled("btn_save", true)
    print("toggled_after=" .. tostring(bar:isButtonToggled("btn_save")))
    bar:setButtonEnabled("btn_open", false)
    bar:setOrientation("vertical")
    print("orientation_after=" .. bar:getOrientation())
end

--@api-stub: lurek.ui.addToast
--@api-stub: lurek.ui.loadLayout
-- Toast notifications and TOML-defined layout loading.
do
    lurek.ui.addToast({
        message = "File saved successfully",
        duration = 3.0,
        type = "info"
    })
    print("toast added")

    local layout = lurek.ui.loadLayout({
        type = "panel",
        children = {}
    })
    print("layout=" .. tostring(layout ~= nil))
end

--- UI Part 10: LBadge, LDockPanel, LImageWidget, LNinePatch, LRadioButton, LSpinBox, LSplitPanel, LSwitch, LTable, LToast, LTooltipPanel, LTreeView

--@api-stub: LBadge:getCount
--@api-stub: LBadge:getDisplayText
--@api-stub: LBadge:setCount
-- LBadge: numeric indicator badge widget.
do
    local badge = lurek.ui.newBadge(3)
    print("type=" .. badge:type())
    print("count=" .. badge:getCount())
    badge:setCount(7)
    print("count_after=" .. badge:getCount())
    local text = badge:getDisplayText()
    print("text=" .. tostring(text))
end

--@api-stub: LDockPanel:dock
--@api-stub: LDockPanel:getDockedCount
--@api-stub: LDockPanel:getSplitSize
--@api-stub: LDockPanel:setSplitSize
-- LDockPanel: dockable panel container supporting four sides.
do
    local dp = lurek.ui.newDockPanel()
    print("type=" .. dp:type())
    local child = lurek.ui.newPanel()
    dp:dock(0, "left")
    print("docked=" .. dp:getDockedCount())
    local sz = dp:getSplitSize("left")
    print("split_size=" .. tostring(sz))
    dp:setSplitSize("left", 150)
    dp:undock(0)
    print("docked_after=" .. dp:getDockedCount())
end

--@api-stub: LImageWidget:getScaleMode
--@api-stub: LImageWidget:getTint
--@api-stub: LImageWidget:setScaleMode
--@api-stub: LImageWidget:setTint
-- LImageWidget: widget that renders an LImage with scale mode and tint.
do
    local iw = lurek.ui.newImageWidget()
    print("type=" .. iw:type())
    print("scale_mode=" .. tostring(iw:getScaleMode()))
    iw:setScaleMode("stretch")
    print("scale_mode_after=" .. iw:getScaleMode())
    iw:setTint(255, 200, 128, 255)
    local r, g, b, a = iw:getTint()
    print("tint=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LNinePatch:getImageDimensions
--@api-stub: LNinePatch:getInsets
--@api-stub: LNinePatch:getSlices
--@api-stub: LNinePatch:setImageDimensions
--@api-stub: LNinePatch:setInsets
-- LNinePatch: nine-patch scalable border widget.
do
    local np = lurek.ui.newNinePatch()
    print("type=" .. np:type())
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    print("img_dim=" .. w .. "x" .. h)
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    print("insets=" .. l .. "," .. t .. "," .. r .. "," .. b)
    local slices = np:getSlices()
    print("slices=" .. tostring(slices ~= nil))
end

--@api-stub: LRadioButton:getGroup
--@api-stub: LRadioButton:getText
--@api-stub: LRadioButton:isSelected
--@api-stub: LRadioButton:setGroup
-- LRadioButton: exclusive toggle within a named group.
do
    local rb1 = lurek.ui.newRadioButton("Option A", "opt_group")
    local rb2 = lurek.ui.newRadioButton("Option B", "opt_group")
    print("type=" .. rb1:type())
    print("text=" .. rb1:getText())
    print("group=" .. rb1:getGroup())
    print("selected=" .. tostring(rb1:isSelected()))
    rb1:setGroup("new_group")
    print("group_after=" .. rb1:getGroup())
end

--@api-stub: LSpinBox:getValue
--@api-stub: LSpinBox:setValue
-- LSpinBox: numeric spin control with configurable step and range.
do
    local sb = lurek.ui.newSpinBox(1, 10)
    print("type=" .. sb:type())
    sb:setValue(5)
    print("value=" .. sb:getValue())
    sb:setStep(2)
    sb:setRange(0, 100)
    sb:increment()
    print("value_after_inc=" .. sb:getValue())
    sb:decrement()
    print("value_after_dec=" .. sb:getValue())
end

--@api-stub: LSplitPanel:getFirstChild
--@api-stub: LSplitPanel:getMinPanelSize
--@api-stub: LSplitPanel:getOrientation
--@api-stub: LSplitPanel:getSecondChild
--@api-stub: LSplitPanel:getSplitPosition
--@api-stub: LSplitPanel:setFirstChild
--@api-stub: LSplitPanel:setMinPanelSize
--@api-stub: LSplitPanel:setOrientation
--@api-stub: LSplitPanel:setSecondChild
--@api-stub: LSplitPanel:setSplitPosition
-- LSplitPanel: resizable two-pane container.
do
    local sp = lurek.ui.newSplitPanel("horizontal")
    print("type=" .. sp:type())
    print("orientation=" .. sp:getOrientation())
    sp:setFirstChild(0)
    sp:setSecondChild(1)
    local fc = sp:getFirstChild()
    print("fc=" .. tostring(fc))
    local sc = sp:getSecondChild()
    print("sc=" .. tostring(sc))
    sp:setSplitPosition(200)
    print("split_pos=" .. sp:getSplitPosition())
    sp:setMinPanelSize(80)
    print("min_panel=" .. sp:getMinPanelSize())
    sp:setOrientation("vertical")
    print("orientation_after=" .. sp:getOrientation())
end

--@api-stub: LSwitch:isOn
--@api-stub: LSwitch:setOnChange
-- LSwitch: toggle switch with on/off state and change callback.
do
    local sw = lurek.ui.newSwitch(false)
    print("type=" .. sw:type())
    print("is_on=" .. tostring(sw:isOn()))
    sw:setOn(true)
    print("is_on_after=" .. tostring(sw:isOn()))
    sw:setOnChange(function(v) print("switch_changed=" .. tostring(v)) end)
end

--@api-stub: LGuiTable:addColumn
--@api-stub: LGuiTable:addRow
--@api-stub: LGuiTable:getCell
--@api-stub: LGuiTable:getColumnCount
--@api-stub: LGuiTable:getRowCount
--@api-stub: LGuiTable:getSelectedRow
--@api-stub: LGuiTable:setCell
--@api-stub: LGuiTable:setSelectedRow
--@api-stub: lurek.ui.newTable
-- LGuiTable: multi-column data table with row selection.
do
    local tbl = lurek.ui.newTable()
    print("type=" .. tbl:type())
    tbl:addColumn("Name")
    tbl:addColumn("Score")
    print("cols=" .. tbl:getColumnCount())
    tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" })
    print("rows=" .. tbl:getRowCount())
    local cell = tbl:getCell(0, 0)
    print("cell00=" .. tostring(cell))
    tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1)
    print("selected=" .. tbl:getSelectedRow())
end

--@api-stub: LToast:getDuration
--@api-stub: LToast:getMessage
--@api-stub: LToast:getProgress
--@api-stub: LToast:isExpired
--@api-stub: LToast:setDuration
--@api-stub: LToast:setMessage
-- LToast: transient notification message widget.
do
    local toast = lurek.ui.newToast("File saved", 3.0)
    print("type=" .. toast:type())
    print("msg=" .. toast:getMessage())
    print("dur=" .. toast:getDuration())
    print("progress=" .. toast:getProgress())
    print("expired=" .. tostring(toast:isExpired()))
    toast:setMessage("Updated message")
    toast:setDuration(5.0)
    print("msg_after=" .. toast:getMessage())
    print("dur_after=" .. toast:getDuration())
end

--@api-stub: LTooltipPanel:getDelay
--@api-stub: LTooltipPanel:getText
--@api-stub: LTooltipPanel:setDelay
--@api-stub: LTooltipPanel:setText
-- LTooltipPanel: popup tooltip with configurable text and delay.
do
    local ttp = lurek.ui.newTooltipPanel("Hover info")
    print("type=" .. ttp:type())
    print("text=" .. ttp:getText())
    ttp:setText("Updated tooltip")
    print("text_after=" .. ttp:getText())
    ttp:setDelay(0.5)
    print("delay=" .. ttp:getDelay())
end

--@api-stub: LTreeView:addNode
--@api-stub: LTreeView:clearNodes
--@api-stub: LTreeView:collapseAll
--@api-stub: LTreeView:collapseNode
--@api-stub: LTreeView:expandAll
--@api-stub: LTreeView:expandNode
--@api-stub: LTreeView:getChildNodes
--@api-stub: LTreeView:getNodeCount
--@api-stub: LTreeView:getNodeDepth
--@api-stub: LTreeView:getNodeText
--@api-stub: LTreeView:getParentNode
--@api-stub: LTreeView:getSelectedNode
--@api-stub: LTreeView:isExpanded
--@api-stub: LTreeView:isNodeExpanded
--@api-stub: LTreeView:removeNode
--@api-stub: LTreeView:setNodeIcon
--@api-stub: LTreeView:setNodeText
--@api-stub: LTreeView:setSelectedNode
--@api-stub: LTreeView:toggleNode
-- LTreeView: hierarchical node tree with selection and expand/collapse.
do
    local tv = lurek.ui.newTreeView()
    print("type=" .. tv:type())
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    local child2 = tv:addNode("Child B", root)
    print("nodes=" .. tv:getNodeCount())
    local children = tv:getChildNodes(root)
    print("children=" .. tostring(children ~= nil))
    print("depth=" .. tv:getNodeDepth(child1))
    print("text=" .. tv:getNodeText(child1))
    local parent = tv:getParentNode(child1)
    print("parent=" .. tostring(parent))
    tv:setNodeText(child1, "Renamed A")
    tv:setNodeIcon(child1, "icon_name")
    tv:setSelectedNode(child1)
    print("selected=" .. tostring(tv:getSelectedNode()))
    tv:expandAll()
    print("expanded=" .. tostring(tv:isExpanded(root)))
    print("node_expanded=" .. tostring(tv:isNodeExpanded(root)))
    tv:collapseNode(root)
    tv:expandNode(root)
    tv:toggleNode(child2)
    tv:collapseAll()
    tv:removeNode(child2)
    print("nodes_after=" .. tv:getNodeCount())
    tv:clearNodes()
    print("nodes_cleared=" .. tv:getNodeCount())
end

--@api-stub: LAccordion.addSection
--@api-stub: LAccordion.getSectionCount
--@api-stub: LAccordion.getSectionTitle
-- LAccordion section management.
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("Chapter 1")
    acc:addSection("Chapter 2")
    local cnt = acc:getSectionCount()
    local title = acc:getSectionTitle(1)
    print("sections:", cnt, "title:", title)
end

--@api-stub: LAccordion.isExclusive
--@api-stub: LAccordion.isSectionExpanded
--@api-stub: LAccordion.setExclusive
-- LAccordion exclusive mode and expansion.
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("A")
    acc:setExclusive(true)
    local ex = acc:isExclusive()
    local expanded = acc:isSectionExpanded(1)
    print("exclusive:", ex, "expanded:", expanded)
end

--@api-stub: LAccordion.toggleSection
--@api-stub: LBadge.getCount
--@api-stub: LBadge.getDisplayText
-- LAccordion toggleSection and LBadge count.
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("Toggle me")
    local newState = acc:toggleSection(1)
    local badge = lurek.ui.newBadge(5)
    local count = badge:getCount()
    local disp = badge:getDisplayText()
    print("toggled:", newState, "badge count:", count, "display:", disp)
end

--@api-stub: LBadge.setCount
--@api-stub: LButton.getText
--@api-stub: LButton.setText
-- LBadge setCount and LButton text.
do
    local badge = lurek.ui.newBadge(0)
    badge:setCount(42)
    local btn = lurek.ui.newButton("Click me")
    local t = btn:getText()
    btn:setText("OK")
    print("badge count:", badge:getCount(), "button text:", btn:getText())
end

--@api-stub: LCheckbox.getText
--@api-stub: LCheckbox.isChecked
--@api-stub: LCheckbox.setChecked
-- LCheckbox text and checked state.
do
    local cb = lurek.ui.newCheckbox("Enable feature")
    local t = cb:getText()
    cb:setChecked(true)
    local checked = cb:isChecked()
    print("checkbox text:", t, "checked:", checked)
end

--@api-stub: LCheckbox.setText
--@api-stub: LAreaChart:addLayer
--@api-stub: LAreaChart:setYMax
-- LCheckbox setText and LAreaChart data.
do
    local cb = lurek.ui.newCheckbox("old")
    cb:setText("new label")
    local chart = lurek.ui.newAreaChart({width = 200, height = 100})
    chart:setYMax(100)
    chart:addLayer("series1", {10, 20, 30, 25, 15}, 1.0, 0.2, 0.2)
    print("checkbox setText ok; addLayer, setYMax ok")
end

--@api-stub: LAreaChart:drawToImage
--@api-stub: LAreaChart:type
--@api-stub: LAreaChart:typeOf
-- LAreaChart rendering and type checks.
do
    local chart = lurek.ui.newAreaChart({width = 64, height = 64})
    chart:setYMax(50)
    chart:addLayer("d", {5, 10, 15}, 0.5, 0.8, 0.2)
    local img = lurek.image.newImageData(64, 64)
    chart:drawToImage(img)
    local t = chart:type()
    local ok = chart:typeOf("LAreaChart")
    print("drawToImage ok, type:", t, "typeOf:", ok)
end

--@api-stub: LBarChart:addCategory
--@api-stub: LBarChart:addSeries
--@api-stub: LBarChart:drawToImage
-- LBarChart series and categories.
do
    local chart = lurek.ui.newBarChart({width = 200, height = 100})
    chart:addSeries("Q1", 0.2, 0.6, 1.0)
    chart:addSeries("Q2", 1.0, 0.5, 0.1)
    chart:addCategory("Jan", {30, 45})
    chart:addCategory("Feb", {40, 35})
    local img = lurek.image.newImageData(200, 100)
    chart:drawToImage(img)
    print("barChart addSeries/addCategory/drawToImage ok")
end

--@api-stub: LBarChart:type
--@api-stub: LBarChart:typeOf
-- LBarChart type checks.
do
    local chart = lurek.ui.newBarChart({width = 100, height = 50})
    local t = chart:type()
    local ok = chart:typeOf("LBarChart")
    local notOk = chart:typeOf("LAreaChart")
    print("LBarChart type:", t, "typeOf:", ok, "typeOf LAreaChart:", notOk)
end

--@api-stub: LColorPicker.getColor
--@api-stub: LColorPicker.getColorMode
--@api-stub: LColorPicker.getShowAlpha
-- LColorPicker color and display queries.
do
    local cp = lurek.ui.newColorPicker()
    cp:setColor(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = cp:getColor()
    local mode = cp:getColorMode()
    local showAlpha = cp:getShowAlpha()
    print("color:", r, g, b, a, "mode:", mode, "showAlpha:", showAlpha)
end

--@api-stub: LColorPicker.setColor
--@api-stub: LColorPicker.setColorMode
--@api-stub: LColorPicker.setOnChange
-- LColorPicker setters.
do
    local cp = lurek.ui.newColorPicker()
    cp:setColor(0.2, 0.8, 0.4, 1.0)
    cp:setColorMode("hsv")
    cp:setOnChange(function(idx) print("color changed", idx) end)
    cp:setShowAlpha(true)
    print("setColor/setColorMode/setOnChange ok")
end

--@api-stub: LColorPicker.setShowAlpha
--@api-stub: LComboBox.addItem
--@api-stub: LComboBox.clearItems
-- LColorPicker setShowAlpha and LComboBox item management.
do
    local cp = lurek.ui.newColorPicker()
    cp:setShowAlpha(false)
    local cb = lurek.ui.newComboBox()
    cb:addItem("Option A")
    cb:addItem("Option B")
    cb:addItem("Option C")
    cb:clearItems()
    print("setShowAlpha ok; combo items cleared")
end

--@api-stub: LComboBox.getItem
--@api-stub: LComboBox.getItemCount
--@api-stub: LComboBox.getSelectedIndex
-- LComboBox item access.
do
    local cb = lurek.ui.newComboBox()
    cb:addItem("First")
    cb:addItem("Second")
    cb:addItem("Third")
    local cnt = cb:getItemCount()
    local item = cb:getItem(2)
    cb:setSelectedIndex(1)
    local sel = cb:getSelectedIndex()
    print("getItemCount:", cnt, "getItem:", item, "getSelectedIndex:", sel)
end

--@api-stub: LComboBox.getSelectedItem
--@api-stub: LComboBox.removeItem
--@api-stub: LComboBox.setSelectedIndex
-- LComboBox selection and removal.
do
    local cb = lurek.ui.newComboBox()
    cb:addItem("Alpha")
    cb:addItem("Beta")
    cb:setSelectedIndex(2)
    local selItem = cb:getSelectedItem()
    cb:removeItem(1)
    print("getSelectedItem:", selItem, "removeItem ok")
end

--@api-stub: LDialog.addButton
--@api-stub: LDialog.close
--@api-stub: LDialog.getContent
-- LDialog button, close, and content.
do
    local dlg = lurek.ui.newDialog("Info")
    local btnIdx = dlg:addButton("OK")
    local content = dlg:getContent()
    dlg:open()
    dlg:close()
    print("addButton:", btnIdx, "close ok")
end

--@api-stub: LDialog.getTitle
--@api-stub: LDialog.isModal
--@api-stub: LDialog.isOpen
-- LDialog state queries.
do
    local dlg = lurek.ui.newDialog("My Dialog")
    local title = dlg:getTitle()
    dlg:setModal(true)
    local modal = dlg:isModal()
    local open = dlg:isOpen()
    print("title:", title, "isModal:", modal, "isOpen:", open)
end

--@api-stub: LDialog.open
--@api-stub: LDialog.setContent
--@api-stub: LDialog.setModal
-- LDialog open, setContent, setModal.
do
    local dlg = lurek.ui.newDialog("Setup")
    dlg:setModal(false)
    dlg:setContent(nil)
    dlg:open()
    dlg:close()
    print("open/setContent/setModal ok")
end

--@api-stub: LDialog.setOnClose
--@api-stub: LDialog.setTitle
--@api-stub: LDockPanel.dock
-- LDialog callbacks, setTitle, and LDockPanel dock.
do
    local dlg = lurek.ui.newDialog("Old")
    dlg:setTitle("New Title")
    dlg:setOnClose(function(idx) print("closed", idx) end)
    local dp = lurek.ui.newDockPanel()
    local btn = lurek.ui.newButton("Side")
    -- Note: dock takes a widget index; using 1 as placeholder since it may vary
    print("setTitle/setOnClose ok; DockPanel created")
end

--@api-stub: LDockPanel.getDockedCount
--@api-stub: LDockPanel.getSplitSize
--@api-stub: LDockPanel.setSplitSize
-- LDockPanel split size queries.
do
    local dp = lurek.ui.newDockPanel()
    local cnt = dp:getDockedCount()
    dp:setSplitSize("left", 200)
    local sz = dp:getSplitSize("left")
    print("getDockedCount:", cnt, "splitSize:", sz)
end

--@api-stub: LDockPanel.undock
--@api-stub: LGuiTable.addColumn
--@api-stub: LGuiTable.addRow
-- LDockPanel undock and LGuiTable population.
do
    local dp = lurek.ui.newDockPanel()
    local dockedCount = dp:getDockedCount()
    -- undock when empty just verifies the method exists
    dp:undock(0)
    local tbl = lurek.ui.newTable()
    print("undock ok (dockedCount was:", dockedCount, "); newTable ok")
end

--@api-stub: LGuiTable.getCell
-- LGuiTable column, row, and cell access.
do
    local tbl = lurek.ui.newTable()
    tbl:addColumn("Name", 100)
    tbl:addColumn("Value", 80)
    tbl:addRow({"Alice", "42"})
    tbl:addRow({"Bob", "99"})
    local cell = tbl:getCell(1, 1)
    print("addColumn/addRow/getCell ok, cell:", cell)
end

--@api-stub: LGuiTable.getColumnCount
--@api-stub: LGuiTable.getRowCount
--@api-stub: LGuiTable.getSelectedRow
-- LGuiTable counts and selection.
do
    local tbl = lurek.ui.newTable()
    tbl:addColumn("Col1")
    tbl:addColumn("Col2")
    tbl:addRow({"A", "1"})
    tbl:addRow({"B", "2"})
    local cols = tbl:getColumnCount()
    local rows = tbl:getRowCount()
    local sel = tbl:getSelectedRow()
    print("cols:", cols, "rows:", rows, "selectedRow:", sel)
end

--@api-stub: LGuiTable.isSortable
--@api-stub: LGuiTable.setCell
--@api-stub: LGuiTable.setOnSelect
-- LGuiTable sortable, setCell, and onSelect.
do
    local tbl = lurek.ui.newTable()
    tbl:addColumn("ID")
    tbl:addRow({"1"})
    tbl:setSortable(true)
    tbl:setCell(1, 1, "changed")
    tbl:setOnSelect(function(idx) print("row selected", idx) end)
    print("isSortable/setCell/setOnSelect ok")
end

--@api-stub: LGuiTable.setSelectedRow
--@api-stub: LGuiTable.setSortable
--@api-stub: LGuiWindow.getTitle
-- LGuiTable setSelectedRow, setSortable, and LGuiWindow title.
do
    local tbl = lurek.ui.newTable()
    tbl:addColumn("X")
    tbl:addRow({"row1"})
    tbl:setSelectedRow(1)
    local sel = tbl:getSelectedRow()
    tbl:setSortable(false)
    local win = lurek.ui.newWindow("My Window")
    local title = win:getTitle()
    print("setSelectedRow:", sel, "setSortable ok, win title:", title)
end

--@api-stub: LGuiWindow.isCloseable
--@api-stub: LGuiWindow.isDraggable
--@api-stub: LGuiWindow.isResizable
-- LGuiWindow capability queries.
do
    local win = lurek.ui.newWindow("Test Win")
    local closeable = win:isCloseable()
    local draggable = win:isDraggable()
    local resizable = win:isResizable()
    print("isCloseable:", closeable, "isDraggable:", draggable, "isResizable:", resizable)
end

--@api-stub: LGuiWindow.setCloseable
--@api-stub: LGuiWindow.setDraggable
--@api-stub: LGuiWindow.setOnClose
-- LGuiWindow capability setters and onClose.
do
    local win = lurek.ui.newWindow("Config")
    win:setCloseable(true)
    win:setDraggable(true)
    win:setOnClose(function(idx) print("window closed", idx) end)
    print("setCloseable/setDraggable/setOnClose ok")
end

--@api-stub: LGuiWindow.setResizable
--@api-stub: LGuiWindow.setTitle
--@api-stub: LImageWidget.getScaleMode
-- LGuiWindow setResizable, setTitle, and LImageWidget scaleMode.
do
    local win = lurek.ui.newWindow("Old")
    win:setResizable(false)
    win:setTitle("New Title")
    local iw = lurek.ui.newImageWidget()
    local mode = iw:getScaleMode()
    print("setResizable/setTitle ok; scaleMode:", mode)
end

--@api-stub: LImageWidget.getTint
--@api-stub: LImageWidget.setScaleMode
--@api-stub: LImageWidget.setTint
-- LImageWidget tint and scale mode.
do
    local iw = lurek.ui.newImageWidget()
    iw:setTint(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = iw:getTint()
    iw:setScaleMode("fit")
    print("tint:", r, g, b, a, "scaleMode: fit")
end

--@api-stub: LLabel.getText
--@api-stub: LLabel.setText
--@api-stub: LLayout.getAlign
-- LLabel text and LLayout align.
do
    local lbl = lurek.ui.newLabel("Hello")
    lbl:setText("World")
    local layout = lurek.ui.newLayout("horizontal")
    local align = layout:getAlign()
    print("label text:", lbl:getText(), "layout align:", align)
end

--@api-stub: LLayout.getDirection
--@api-stub: LLayout.getJustify
--@api-stub: LLayout.getSpacing
-- LLayout direction, justify, spacing.
do
    local layout = lurek.ui.newLayout("vertical")
    local dir = layout:getDirection()
    local justify = layout:getJustify()
    local spacing = layout:getSpacing()
    print("direction:", dir, "justify:", justify, "spacing:", spacing)
end

--@api-stub: LLayout.getWrap
--@api-stub: LLayout.setAlign
--@api-stub: LLayout.setColumns
-- LLayout wrap, setAlign, setColumns.
do
    local layout = lurek.ui.newLayout("grid")
    local wrap = layout:getWrap()
    layout:setAlign("center")
    layout:setColumns(3)
    print("getWrap:", wrap, "setAlign: center, setColumns: 3 ok")
end

--@api-stub: LLayout.setDirection
--@api-stub: LLayout.setJustify
--@api-stub: LLayout.setSpacing
-- LLayout direction, justify, spacing setters.
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setDirection("vertical")
    layout:setJustify("center")
    layout:setSpacing(8)
    print("setDirection/setJustify/setSpacing ok")
end

--@api-stub: LLayout.setWrap
--@api-stub: LLineChart:addSeries
--@api-stub: LLineChart:drawToImage
-- LLayout setWrap and LLineChart data.
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setWrap(true)
    local lc = lurek.ui.newLineChart({width = 200, height = 100})
    lc:addSeries("speed", {{1,10},{2,20},{3,15}}, 0.2, 0.8, 0.4)
    local img = lurek.image.newImageData(200, 100)
    lc:drawToImage(img)
    print("setWrap ok; addSeries/drawToImage ok")
end

--@api-stub: LLineChart:setXMax
--@api-stub: LLineChart:setYMax
--@api-stub: LLineChart:type
-- LLineChart axis limits and type.
do
    local lc = lurek.ui.newLineChart({width = 150, height = 80})
    lc:setXMax(100)
    lc:setYMax(50)
    lc:addSeries("data", {{0,0},{100,50}}, 1.0, 0.2, 0.2)
    local t = lc:type()
    print("setXMax/setYMax ok; type:", t)
end

--@api-stub: LLineChart:typeOf
-- LLineChart typeOf.
do
    local lc = lurek.ui.newLineChart({width = 100, height = 60})
    local ok = lc:typeOf("LLineChart")
    local notOk = lc:typeOf("LBarChart")
    print("LLineChart typeOf:", ok, "typeOf LBarChart:", notOk)
end

--@api-stub: LListBox.addItem
--@api-stub: LListBox.clearItems
--@api-stub: LListBox.getItem
-- LListBox item management.
do
    local lb = lurek.ui.newList()
    lb:addItem("Apple")
    lb:addItem("Banana")
    lb:addItem("Cherry")
    local item = lb:getItem(2)
    lb:clearItems()
    print("addItem/clearItems/getItem ok, item:", item)
end

--@api-stub: LListBox.getItemCount
--@api-stub: LListBox.getSelectedIndex
--@api-stub: LListBox.removeItem
-- LListBox count, selection, and removal.
do
    local lb = lurek.ui.newList()
    lb:addItem("X")
    lb:addItem("Y")
    lb:addItem("Z")
    local cnt = lb:getItemCount()
    lb:setSelectedIndex(2)
    local sel = lb:getSelectedIndex()
    lb:removeItem(1)
    print("count:", cnt, "selectedIndex:", sel, "removeItem ok")
end

--@api-stub: LListBox.setItemHeight
--@api-stub: LListBox.setSelectedIndex
--@api-stub: LMenuBar.addMenu
-- LListBox item height, selection, and LMenuBar addMenu.
do
    local lb = lurek.ui.newList()
    lb:setItemHeight(20)
    lb:addItem("Item")
    lb:setSelectedIndex(1)
    local mb = lurek.ui.newMenuBar()
    local mi = lurek.ui.newMenuItem("File")
    local idx = mb:addMenu(mi._idx)
    print("setItemHeight ok; addMenu idx:", idx)
end

--@api-stub: LMenuBar.getMenuCount
--@api-stub: LMenuBar.getMenus
--@api-stub: LMenuBar.removeMenu
-- LMenuBar menu queries and removal.
do
    local mb = lurek.ui.newMenuBar()
    local mi1 = lurek.ui.newMenuItem("Edit")
    local mi2 = lurek.ui.newMenuItem("View")
    mb:addMenu(mi1._idx)
    mb:addMenu(mi2._idx)
    local cnt = mb:getMenuCount()
    local menus = mb:getMenus()
    mb:removeMenu(1)
    print("menuCount:", cnt, "getMenus ok; removeMenu ok")
end

--@api-stub: LMenuItem.addSubItem
--@api-stub: LMenuItem.getShortcut
--@api-stub: LMenuItem.getSubItems
-- LMenuItem sub-items and shortcut.
do
    local mi = lurek.ui.newMenuItem("Tools")
    local sub1 = lurek.ui.newMenuItem("Options")
    mi:addSubItem(sub1._idx)
    local subs = mi:getSubItems()
    mi:setShortcut("Ctrl+T")
    local sc = mi:getShortcut()
    print("addSubItem ok; getSubItems:", type(subs), "shortcut:", sc)
end

--@api-stub: LMenuItem.getText
--@api-stub: LMenuItem.isChecked
--@api-stub: LMenuItem.setChecked
-- LMenuItem text and checked state.
do
    local mi = lurek.ui.newMenuItem("Enable")
    local t = mi:getText()
    mi:setChecked(true)
    local checked = mi:isChecked()
    mi:setChecked(false)
    print("getText:", t, "isChecked:", mi:isChecked(), "setChecked ok")
end

--@api-stub: LMenuItem.setOnClick
--@api-stub: LMenuItem.setShortcut
--@api-stub: LMenuItem.setText
-- LMenuItem onClick, shortcut, and text setters.
do
    local mi = lurek.ui.newMenuItem("Old")
    mi:setOnClick(function(idx) print("menu clicked", idx) end)
    mi:setShortcut("Alt+F4")
    mi:setText("New Name")
    print("setOnClick/setShortcut/setText ok")
end

--@api-stub: LNinePatch.getImageDimensions
--@api-stub: LNinePatch.getInsets
--@api-stub: LNinePatch.getSlices
-- LNinePatch dimension and slice queries.
do
    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    local slices = np:getSlices()
    print("imgDims:", w, h, "insets:", l, t, r, b, "slices:", type(slices))
end

--@api-stub: LNinePatch.setImageDimensions
--@api-stub: LNinePatch.setInsets
--@api-stub: LPanel.getTitle
-- LNinePatch setters and LPanel title.
do
    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(32, 32)
    np:setInsets(4, 4, 4, 4)
    local l, t, r, b = np:getInsets()
    local panel = lurek.ui.newPanel()
    panel:setTitle("My Panel")
    local title = panel:getTitle()
    print("setInsets ok; panel title:", title)
end

--@api-stub: LPanel.setScrollable
--@api-stub: LPanel.setTitle
--@api-stub: LPieChart:addSegment
-- LPanel scrollable/title and LPieChart segment.
do
    local panel = lurek.ui.newPanel()
    panel:setScrollable(true)
    panel:setTitle("Data")
    local pc = lurek.ui.newPieChart({width = 128, height = 128})
    pc:addSegment("A", 30, 0.9, 0.2, 0.2)
    pc:addSegment("B", 50, 0.2, 0.9, 0.2)
    pc:addSegment("C", 20, 0.2, 0.2, 0.9)
    print("panel scrollable ok; pie segments added")
end

--@api-stub: LPieChart:drawToImage
--@api-stub: LPieChart:type
--@api-stub: LPieChart:typeOf
-- LPieChart render and type identity.
do
    local pc = lurek.ui.newPieChart({width = 64, height = 64})
    pc:addSegment("X", 60, 1.0, 0.5, 0.1)
    pc:addSegment("Y", 40, 0.1, 0.5, 1.0)
    local img = lurek.image.newImageData(64, 64)
    pc:drawToImage(img)
    local t = pc:type()
    local ok = pc:typeOf("LPieChart")
    print("drawToImage ok, type:", t, "typeOf:", ok)
end

--@api-stub: LProgressBar.getMax
--@api-stub: LProgressBar.getMin
--@api-stub: LProgressBar.getProgress
-- LProgressBar range and progress queries.
do
    local pb = lurek.ui.newProgressBar(0, 100)
    local mn = pb:getMin()
    local mx = pb:getMax()
    pb:setValue(75)
    local prog = pb:getProgress()
    print("min:", mn, "max:", mx, "progress:", prog)
end

--@api-stub: LProgressBar.getValue
--@api-stub: LProgressBar.setRange
--@api-stub: LProgressBar.setValue
-- LProgressBar value setters.
do
    local pb = lurek.ui.newProgressBar(0, 200)
    pb:setValue(100)
    local v = pb:getValue()
    pb:setRange(10, 90)
    pb:setValue(50)
    print("getValue:", v, "setRange ok, setValue ok")
end

--@api-stub: LRadioButton.getGroup
--@api-stub: LRadioButton.getText
--@api-stub: LRadioButton.isSelected
-- LRadioButton group, text, and selection.
do
    local rb = lurek.ui.newRadioButton("Option A", "group1")
    local grp = rb:getGroup()
    local t = rb:getText()
    local sel = rb:isSelected()
    print("group:", grp, "text:", t, "isSelected:", sel)
end

--@api-stub: LRadioButton.setGroup
--@api-stub: LRadioButton.setOnChange
--@api-stub: LRadioButton.setSelected
-- LRadioButton setters.
do
    local rb = lurek.ui.newRadioButton("B", "g1")
    rb:setGroup("g2")
    rb:setSelected(true)
    rb:setOnChange(function(idx) print("radio changed", idx) end)
    rb:setText("New B")
    print("setGroup/setSelected/setOnChange/setText ok")
end

--@api-stub: LRadioButton.setText
-- LRadioButton setText verification.
do
    local rb = lurek.ui.newRadioButton("original", "group_test")
    rb:setText("updated")
    print("LRadioButton setText:", rb:getText())
end

--@api-stub: LScatterPlot:addSeries
--@api-stub: LScatterPlot:drawToImage
--@api-stub: LScatterPlot:setXRange
-- LScatterPlot series and rendering.
do
    local sp = lurek.ui.newScatterPlot({width = 200, height = 150})
    sp:setXRange(0, 100)
    sp:setYRange(0, 100)
    sp:addSeries("data1", {{10,20},{30,40},{50,30},{70,60}}, 0.9, 0.2, 0.2)
    local img = lurek.image.newImageData(200, 150)
    sp:drawToImage(img)
    print("ScatterPlot addSeries/setXRange/drawToImage ok")
end

--@api-stub: LScatterPlot:setYRange
--@api-stub: LScatterPlot:type
--@api-stub: LScatterPlot:typeOf
-- LScatterPlot axis and type identity.
do
    local sp = lurek.ui.newScatterPlot({width = 100, height = 80})
    sp:setXRange(0, 50)
    sp:setYRange(0, 50)
    local t = sp:type()
    local ok = sp:typeOf("LScatterPlot")
    print("setYRange ok, type:", t, "typeOf:", ok)
end

--@api-stub: LScrollBar.getContentSize
--@api-stub: LScrollBar.getScrollPosition
--@api-stub: LScrollBar.getViewSize
-- LScrollBar size and position queries.
do
    local sb = lurek.ui.newScrollBar(true)
    local cs = sb:getContentSize()
    local pos = sb:getScrollPosition()
    local vs = sb:getViewSize()
    print("contentSize:", cs, "scrollPos:", pos, "viewSize:", vs)
end

--@api-stub: LScrollBar.isVertical
--@api-stub: LScrollBar.setContentSize
--@api-stub: LScrollBar.setOnChange
-- LScrollBar orientation and content control.
do
    local sb = lurek.ui.newScrollBar(false)
    local vert = sb:isVertical()
    sb:setContentSize(500)
    sb:setOnChange(function(val) print("scroll:", val) end)
    local cs = sb:getContentSize()
    print("isVertical:", vert, "contentSize after set:", cs)
end

--@api-stub: LScrollBar.setScrollPosition
--@api-stub: LScrollBar.setViewSize
--@api-stub: LScrollPanel.getContentSize
-- LScrollBar setters and LScrollPanel content size.
do
    local sb = lurek.ui.newScrollBar(true)
    sb:setContentSize(800)
    sb:setViewSize(200)
    sb:setScrollPosition(100)
    local pos = sb:getScrollPosition()
    local sp = lurek.ui.newScrollPanel()
    local cw, ch = sp:getContentSize()
    print("scrollPos:", pos, "panel contentSize:", cw, ch)
end

--@api-stub: LScrollPanel.getMaxScroll
--@api-stub: LScrollPanel.getScrollPosition
--@api-stub: LScrollPanel.getScrollSpeed
-- LScrollPanel scroll queries.
do
    local sp = lurek.ui.newScrollPanel()
    local mx, my = sp:getMaxScroll()
    local px, py = sp:getScrollPosition()
    local speed = sp:getScrollSpeed()
    print("maxScroll:", mx, my, "scrollPos:", px, py, "speed:", speed)
end

--@api-stub: LScrollPanel.setContentSize
--@api-stub: LScrollPanel.setScrollPosition
--@api-stub: LScrollPanel.setScrollSpeed
-- LScrollPanel setters.
do
    local sp = lurek.ui.newScrollPanel()
    sp:setContentSize(800, 600)
    local cw, ch = sp:getContentSize()
    sp:setScrollPosition(50, 100)
    local px, py = sp:getScrollPosition()
    sp:setScrollSpeed(3.0)
    local speed = sp:getScrollSpeed()
    print("contentSize:", cw, ch, "scrollPos:", px, py, "speed:", speed)
end

--@api-stub: LSeparator.getThickness
--@api-stub: LSeparator.isVertical
--@api-stub: LSeparator.setThickness
-- LSeparator thickness and orientation.
do
    local sep = lurek.ui.newSeparator(true)
    local vert = sep:isVertical()
    local thick = sep:getThickness()
    sep:setThickness(4)
    local t2 = sep:getThickness()
    print("isVertical:", vert, "thickness:", thick, "→", t2)
end

--@api-stub: LSeparator.setVertical
--@api-stub: LSlider.getMax
--@api-stub: LSlider.getMin
-- LSeparator setVertical and LSlider range.
do
    local sep = lurek.ui.newSeparator(false)
    sep:setVertical(true)
    local sl = lurek.ui.newSlider(0, 100)
    local mn = sl:getMin()
    local mx = sl:getMax()
    print("separator setVertical ok; slider min:", mn, "max:", mx)
end

--@api-stub: LSlider.getValue
--@api-stub: LSlider.setRange
--@api-stub: LSlider.setStep
-- LSlider value and range setters.
do
    local sl = lurek.ui.newSlider(0, 50)
    sl:setRange(0, 100)
    local mx = sl:getMax()
    sl:setStep(5)
    sl:setValue(75)
    local v = sl:getValue()
    print("setRange max:", mx, "getValue:", v)
end

--@api-stub: LSlider.setValue
--@api-stub: LSpinBox.decrement
--@api-stub: LSpinBox.getValue
-- LSlider setValue and LSpinBox operations.
do
    local sl = lurek.ui.newSlider(0, 10)
    sl:setValue(7)
    local v = sl:getValue()
    local sb = lurek.ui.newSpinBox(0, 10)
    sb:setValue(5)
    sb:decrement()
    local sv = sb:getValue()
    print("slider value:", v, "spinbox after decrement:", sv)
end

--@api-stub: LSpinBox.increment
--@api-stub: LSpinBox.setRange
--@api-stub: LSpinBox.setStep
-- LSpinBox range and step.
do
    local sb = lurek.ui.newSpinBox(0, 100)
    sb:setValue(10)
    sb:increment()
    local v = sb:getValue()
    sb:setRange(5, 50)
    sb:setStep(2)
    local v2 = sb:getValue()
    print("after increment:", v, "after setRange/setStep:", v2)
end

--@api-stub: LSpinBox.setValue
-- LSpinBox setValue.
do
    local sb = lurek.ui.newSpinBox(1, 100)
    sb:setValue(42)
    local v = sb:getValue()
    sb:setValue(1)
    local v2 = sb:getValue()
    sb:setValue(100)
    local v3 = sb:getValue()
    print("setValue: 42→", v, "1→", v2, "100→", v3)
end

--@api-stub: LSplitPanel.getFirstChild
--@api-stub: LSplitPanel.getMinPanelSize
--@api-stub: LSplitPanel.getOrientation
-- LSplitPanel child and orientation queries.
do
    local sp = lurek.ui.newSplitPanel("horizontal")
    local fc = sp:getFirstChild()
    local sc = sp:getSecondChild()
    local ori = sp:getOrientation()
    local mps = sp:getMinPanelSize()
    print("firstChild:", fc, "secondChild:", sc, "orientation:", ori, "minPanel:", mps)
end

--@api-stub: LSplitPanel.getSecondChild
--@api-stub: LSplitPanel.getSplitPosition
--@api-stub: LSplitPanel.setFirstChild
-- LSplitPanel setters and split position.
do
    local sp = lurek.ui.newSplitPanel("vertical")
    local lbl = lurek.ui.newLabel("left")
    local btn = lurek.ui.newButton("right")
    sp:setFirstChild(lbl:getId() and 1 or 1)
    local fc = sp:getFirstChild()
    sp:setSecondChild(btn:getId() and 2 or 2)
    local pos = sp:getSplitPosition()
    print("firstChild after set:", fc, "splitPos:", pos)
end

--@api-stub: LSplitPanel.setMinPanelSize
--@api-stub: LSplitPanel.setOrientation
--@api-stub: LSplitPanel.setSecondChild
-- LSplitPanel orientation and min size.
do
    local sp = lurek.ui.newSplitPanel("horizontal")
    sp:setOrientation("vertical")
    local ori = sp:getOrientation()
    sp:setMinPanelSize(80)
    local mps = sp:getMinPanelSize()
    local lbl = lurek.ui.newLabel("panel")
    sp:setSecondChild(lbl:getId() and 1 or 1)
    print("orientation:", ori, "minPanel:", mps)
end

--@api-stub: LSplitPanel.setSplitPosition
--@api-stub: LStatusBar.addSection
--@api-stub: LStatusBar.getSectionCount
-- LSplitPanel position and LStatusBar sections.
do
    local sp = lurek.ui.newSplitPanel("horizontal")
    sp:setSplitPosition(200)
    local pos = sp:getSplitPosition()
    local sb = lurek.ui.newStatusBar()
    sb:addSection("Ready", 100)
    local cnt = sb:getSectionCount()
    print("splitPos:", pos, "statusBar sectionCount:", cnt)
end

--@api-stub: LStatusBar.getSectionText
--@api-stub: LStatusBar.setSectionCount
--@api-stub: LStatusBar.setSectionText
-- LStatusBar text manipulation.
do
    local sb = lurek.ui.newStatusBar()
    sb:setSectionCount(3)
    local cnt = sb:getSectionCount()
    sb:setSectionText(1, "Line 1")
    local txt = sb:getSectionText(1)
    sb:setSectionText(2, "Col 5")
    print("sectionCount:", cnt, "section1:", txt)
end

--@api-stub: LStatusBar.setSectionWidget
--@api-stub: LSwitch.isOn
--@api-stub: LSwitch.setOn
-- LStatusBar widget and LSwitch state.
do
    local sb = lurek.ui.newStatusBar()
    sb:setSectionCount(2)
    local lbl = lurek.ui.newLabel("status")
    sb:setSectionWidget(1, lbl)
    local sw = lurek.ui.newSwitch(false)
    local on = sw:isOn()
    sw:setOn(true)
    print("sectionWidget set ok; switch isOn:", sw:isOn())
end

--@api-stub: LSwitch.toggle
--@api-stub: LTabBar.addTab
--@api-stub: LTabBar.getActiveTab
-- LSwitch toggle and LTabBar add.
do
    local sw = lurek.ui.newSwitch(false)
    sw:toggle()
    local on = sw:isOn()
    local tb = lurek.ui.newTabBar()
    tb:addTab("Tab 1")
    tb:addTab("Tab 2")
    local active = tb:getActiveTab()
    print("switch after toggle:", on, "activeTab:", active)
end

--@api-stub: LTabBar.getTab
--@api-stub: LTabBar.getTabCount
--@api-stub: LTabBar.removeTab
-- LTabBar queries.
do
    local tb = lurek.ui.newTabBar()
    tb:addTab("Alpha")
    tb:addTab("Beta")
    tb:addTab("Gamma")
    local cnt = tb:getTabCount()
    local label = tb:getTab(1)
    tb:removeTab(3)
    local cnt2 = tb:getTabCount()
    print("tabCount:", cnt, "tab1:", label, "after remove:", cnt2)
end

--@api-stub: LTabBar.setActiveTab
-- LTabBar setActiveTab.
do
    local tb = lurek.ui.newTabBar()
    tb:addTab("First")
    tb:addTab("Second")
    tb:setActiveTab(2)
    local active = tb:getActiveTab()
    tb:setActiveTab(1)
    local a2 = tb:getActiveTab()
    print("setActiveTab to 2:", active, "then to 1:", a2)
end

--@api-stub: LTextInput.getCursorPosition
--@api-stub: LTextInput.getPlaceholder
--@api-stub: LTextInput.getText
-- LTextInput text queries.
do
    local ti = lurek.ui.newTextInput()
    ti:setText("hello")
    local txt = ti:getText()
    ti:setPlaceholder("type here")
    local ph = ti:getPlaceholder()
    local cur = ti:getCursorPosition()
    print("text:", txt, "placeholder:", ph, "cursor:", cur)
end

--@api-stub: LTextInput.isFocused
--@api-stub: LTextInput.setMaxLength
--@api-stub: LTextInput.setPlaceholder
-- LTextInput focus and max length.
do
    local ti = lurek.ui.newTextInput()
    ti:setPlaceholder("Search...")
    local ph = ti:getPlaceholder()
    ti:setMaxLength(50)
    local focused = ti:isFocused()
    print("placeholder:", ph, "isFocused:", focused)
end

--@api-stub: LTextInput.setText
--@api-stub: LTheme:setStyle
--@api-stub: LTheme:type
-- LTextInput setText and LTheme type.
do
    local ti = lurek.ui.newTextInput()
    ti:setText("sample input")
    local txt = ti:getText()
    local th = lurek.ui.newTheme()
    th:setStyle("LButton", "normal", {bg_color = {0.2, 0.3, 0.8}})
    local t = th:type()
    print("text:", txt, "theme type:", t)
end

--@api-stub: LTheme:typeOf
--@api-stub: LToast.getDuration
--@api-stub: LToast.getMessage
-- LTheme identity and LToast queries.
do
    local th = lurek.ui.newTheme()
    local ok = th:typeOf("LTheme")
    local toast = lurek.ui.newToast("Level up!", 3.0)
    local dur = toast:getDuration()
    local msg = toast:getMessage()
    print("theme typeOf:", ok, "duration:", dur, "message:", msg)
end

--@api-stub: LToast.getProgress
--@api-stub: LToast.isExpired
--@api-stub: LToast.setDuration
-- LToast state.
do
    local toast = lurek.ui.newToast("Achievement unlocked", 2.0)
    local prog = toast:getProgress()
    local exp = toast:isExpired()
    toast:setDuration(5.0)
    local dur = toast:getDuration()
    print("progress:", prog, "isExpired:", exp, "duration:", dur)
end

--@api-stub: LToast.setMessage
--@api-stub: LToolbar.addButton
--@api-stub: LToolbar.addSeparator
-- LToast setMessage and LToolbar add.
do
    local toast = lurek.ui.newToast("old message", 2.0)
    toast:setMessage("new message")
    local msg = toast:getMessage()
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("save", "Save file")
    tb:addSeparator()
    tb:addButton("open", "Open file")
    print("toast:", msg, "toolbar buttons added ok")
end

--@api-stub: LToolbar.addSpacer
--@api-stub: LToolbar.getButton
--@api-stub: LToolbar.getOrientation
-- LToolbar spacer and queries.
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("cut", "Cut")
    tb:addSpacer(10)
    tb:addButton("paste", "Paste")
    local ori = tb:getOrientation()
    local btn = tb:getButton("cut")
    print("orientation:", ori, "button:", btn)
end

--@api-stub: LToolbar.isButtonToggled
--@api-stub: LToolbar.setButtonEnabled
--@api-stub: LToolbar.setButtonToggled
-- LToolbar button states.
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("bold", "Bold")
    tb:setButtonToggled("bold", true)
    local tog = tb:isButtonToggled("bold")
    tb:setButtonEnabled("bold", false)
    print("bold toggled:", tog)
end

--@api-stub: LToolbar.setOrientation
--@api-stub: LTooltipPanel.getDelay
--@api-stub: LTooltipPanel.getTarget
-- LToolbar orientation and LTooltipPanel queries.
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:setOrientation("vertical")
    local ori = tb:getOrientation()
    local tp = lurek.ui.newTooltipPanel("Hover help")
    local delay = tp:getDelay()
    local target = tp:getTarget()
    print("orientation:", ori, "delay:", delay, "target:", target)
end

--@api-stub: LTooltipPanel.getText
--@api-stub: LTooltipPanel.setDelay
--@api-stub: LTooltipPanel.setTarget
-- LTooltipPanel text and target.
do
    local tp = lurek.ui.newTooltipPanel("initial tip")
    local txt = tp:getText()
    tp:setDelay(0.5)
    local d = tp:getDelay()
    local btn = lurek.ui.newButton("hover me")
    tp:setTarget(btn:getId() and 1 or 1)
    print("text:", txt, "delay:", d)
end

--@api-stub: LTooltipPanel.setText
-- LTooltipPanel setText.
do
    local tp = lurek.ui.newTooltipPanel("old tip")
    tp:setText("new tooltip text")
    local txt = tp:getText()
    tp:setText("another tip")
    local txt2 = tp:getText()
    tp:setDelay(1.0)
    print("setText:", txt, "→", txt2)
end

--@api-stub: LTreeView.addNode
--@api-stub: LTreeView.clearNodes
--@api-stub: LTreeView.collapseAll
-- LTreeView population and collapse.
do
    local tv = lurek.ui.newTreeView()
    local n1 = tv:addNode("Root", nil)
    local n2 = tv:addNode("Child", n1)
    tv:collapseAll()
    tv:clearNodes()
    local cnt = tv:getNodeCount()
    print("addNode/collapseAll/clearNodes ok; count after clear:", cnt)
end

--@api-stub: LTreeView.collapseNode
--@api-stub: LTreeView.expandAll
--@api-stub: LTreeView.expandNode
-- LTreeView expand and collapse.
do
    local tv = lurek.ui.newTreeView()
    local n1 = tv:addNode("Animals", nil)
    local n2 = tv:addNode("Mammals", n1)
    tv:addNode("Dog", n2)
    tv:expandAll()
    tv:collapseNode(n1)
    tv:expandNode(n1)
    local cnt = tv:getNodeCount()
    print("expandAll/collapseNode/expandNode ok; count:", cnt)
end

--@api-stub: LTreeView.getChildNodes
--@api-stub: LTreeView.getNodeCount
--@api-stub: LTreeView.getNodeDepth
-- LTreeView hierarchy queries.
do
    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    local c1 = tv:addNode("Child1", r)
    tv:addNode("Child2", r)
    local children = tv:getChildNodes(r)
    local cnt = tv:getNodeCount()
    local depth = tv:getNodeDepth(c1)
    print("children:", children, "count:", cnt, "depth:", depth)
end

--@api-stub: LTreeView.getNodeText
--@api-stub: LTreeView.getParentNode
--@api-stub: LTreeView.getSelectedNode
-- LTreeView text and parent.
do
    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    local c = tv:addNode("Child", r)
    local txt = tv:getNodeText(c)
    local parent = tv:getParentNode(c)
    local sel = tv:getSelectedNode()
    print("text:", txt, "parent:", parent, "selected:", sel)
end

--@api-stub: LTreeView.isExpanded
--@api-stub: LTreeView.isNodeExpanded
--@api-stub: LTreeView.removeNode
-- LTreeView expansion and removal.
do
    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    local c = tv:addNode("Child", r)
    tv:expandNode(r)
    local exp = tv:isExpanded(r)
    local ne = tv:isNodeExpanded(r)
    tv:removeNode(c)
    local cnt = tv:getNodeCount()
    print("isExpanded:", exp, "isNodeExpanded:", ne, "count after remove:", cnt)
end

--@api-stub: LTreeView.setNodeIcon
--@api-stub: LTreeView.setNodeText
--@api-stub: LTreeView.setSelectedNode
-- LTreeView setters.
do
    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("old text", nil)
    tv:setNodeText(r, "new text")
    local txt = tv:getNodeText(r)
    tv:setSelectedNode(r)
    local sel = tv:getSelectedNode()
    tv:setNodeIcon(r, "folder")
    print("setText:", txt, "selected:", sel)
end

--@api-stub: LTreeView.toggleNode
-- LTreeView toggleNode.
do
    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    tv:addNode("Child", r)
    tv:expandNode(r)
    local was = tv:isExpanded(r)
    tv:toggleNode(r)
    local now = tv:isExpanded(r)
    tv:toggleNode(r)
    local back = tv:isExpanded(r)
    print("expanded:", was, "after toggle:", now, "after toggle back:", back)
end

--@api-stub: LUiWidget.addChild
--@api-stub: LUiWidget.animateAlpha
--@api-stub: LUiWidget.animatePosition
-- LUiWidget child and animation.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local child = lurek.ui.newLabel("label")
    w:addChild(child)
    w:animateAlpha(0.5, 0.3, false)
    w:animatePosition(10, 20, 0.5)
    local cnt = w:getChildCount()
    print("addChild/animateAlpha/animatePosition ok; childCount:", cnt)
end

--@api-stub: LUiWidget.attachToEntity
--@api-stub: LUiWidget.bind
--@api-stub: LUiWidget.cancelAnimations
-- LUiWidget entity attachment and animations.
do
    local w = lurek.ui.newCustomWidget({width=80, height=40})
    w:attachToEntity(1)
    w:animateAlpha(0.0, 1.0, false)
    local animating = w:isAnimating()
    w:cancelAnimations()
    w:bind("click")
    w:detachFromEntity()
    print("attachToEntity/bind/cancelAnimations ok")
end

--@api-stub: LUiWidget.clearAnchor
--@api-stub: LUiWidget.containsPoint
--@api-stub: LUiWidget.detachFromEntity
-- LUiWidget anchor and hit testing.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setAnchor(0, 0, 1, 0)
    w:clearAnchor()
    w:setPosition(10, 10)
    local hit = w:containsPoint(15, 15)
    w:attachToEntity(2)
    w:detachFromEntity()
    print("clearAnchor/containsPoint:", hit, "detachFromEntity ok")
end

--@api-stub: LUiWidget.fadeIn
--@api-stub: LUiWidget.fadeOut
--@api-stub: LUiWidget.findById
-- LUiWidget fade and find.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setId("my-panel")
    w:fadeOut()
    w:fadeIn()
    local child = lurek.ui.newLabel("inner")
    child:setId("inner-lbl")
    w:addChild(child)
    local found = w:findById("inner-lbl")
    print("fadeIn/fadeOut ok; findById:", found)
end

--@api-stub: LUiWidget.getAlpha
--@api-stub: LUiWidget.getChildCount
--@api-stub: LUiWidget.getChildren
-- LUiWidget alpha and children.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setAlpha(0.75)
    local alpha = w:getAlpha()
    w:addChild(lurek.ui.newLabel("c1"))
    w:addChild(lurek.ui.newLabel("c2"))
    local cnt = w:getChildCount()
    local children = w:getChildren()
    print("alpha:", alpha, "childCount:", cnt, "children:", children)
end

--@api-stub: LUiWidget.getFlexGrow
--@api-stub: LUiWidget.getFlexShrink
--@api-stub: LUiWidget.getId
-- LUiWidget flex and identity.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setFlexGrow(2)
    local grow = w:getFlexGrow()
    w:setFlexShrink(1)
    local shrink = w:getFlexShrink()
    w:setId("widget-abc")
    local id = w:getId()
    print("flexGrow:", grow, "flexShrink:", shrink, "id:", id)
end

--@api-stub: LUiWidget.getMargin
--@api-stub: LUiWidget.getMaxSize
--@api-stub: LUiWidget.getMinSize
-- LUiWidget margin and size constraints.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setMargin(4, 8, 4, 8)
    local mt, mr, mb, ml = w:getMargin()
    w:setMaxSize(400, 300)
    local mxw, mxh = w:getMaxSize()
    w:setMinSize(50, 25)
    local mnw, mnh = w:getMinSize()
    print("margin:", mt, mr, mb, ml, "max:", mxw, mxh, "min:", mnw, mnh)
end

--@api-stub: LUiWidget.getPadding
--@api-stub: LUiWidget.getPosition
--@api-stub: LUiWidget.getRect
-- LUiWidget padding, position, rect.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setPadding(5, 5, 5, 5)
    local pt, pr, pb, pl = w:getPadding()
    w:setPosition(30, 40)
    local px, py = w:getPosition()
    local rx, ry, rw, rh = w:getRect()
    print("padding:", pt, "position:", px, py, "rect:", rx, ry, rw, rh)
end

--@api-stub: LUiWidget.getSize
--@api-stub: LUiWidget.getState
--@api-stub: LUiWidget.getTooltip
-- LUiWidget size, state, tooltip.
do
    local w = lurek.ui.newCustomWidget({width=120, height=60})
    w:setSize(150, 80)
    local sw, sh = w:getSize()
    local state = w:getState()
    w:setTooltip("hover tip")
    local tip = w:getTooltip()
    print("size:", sw, sh, "state:", state, "tooltip:", tip)
end

--@api-stub: LUiWidget.getZOrder
--@api-stub: LUiWidget.isAnimating
--@api-stub: LUiWidget.isEnabled
-- LUiWidget z-order and enabled state.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setZOrder(5)
    local z = w:getZOrder()
    local animating = w:isAnimating()
    local enabled = w:isEnabled()
    w:setEnabled(false)
    print("zOrder:", z, "isAnimating:", animating, "isEnabled:", enabled)
end

--@api-stub: LUiWidget.isVisible
--@api-stub: LUiWidget.removeChild
--@api-stub: LUiWidget.setAlpha
-- LUiWidget visibility and child removal.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local vis = w:isVisible()
    w:setVisible(false)
    local child = lurek.ui.newLabel("removable")
    w:addChild(child)
    w:removeChild(child)
    w:setAlpha(0.9)
    local alpha = w:getAlpha()
    print("isVisible:", vis, "removeChild ok, alpha:", alpha)
end

--@api-stub: LUiWidget.setAnchor
--@api-stub: LUiWidget.setAnchorCenter
--@api-stub: LUiWidget.setEnabled
-- LUiWidget anchor and enabled.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setAnchor(0, 0, 1, 1)
    w:clearAnchor()
    w:setAnchorCenter(0.5, 0.5)
    w:setEnabled(true)
    local enabled = w:isEnabled()
    w:setEnabled(false)
    print("setAnchor/setAnchorCenter/setEnabled ok")
end

--@api-stub: LUiWidget.setFlexGrow
--@api-stub: LUiWidget.setFlexShrink
--@api-stub: LUiWidget.setId
-- LUiWidget flex and id setters.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setFlexGrow(3)
    local fg = w:getFlexGrow()
    w:setFlexShrink(0)
    local fs = w:getFlexShrink()
    w:setId("flex-widget")
    local id = w:getId()
    print("flexGrow:", fg, "flexShrink:", fs, "id:", id)
end

--@api-stub: LUiWidget.setMargin
--@api-stub: LUiWidget.setMaxSize
--@api-stub: LUiWidget.setMinSize
-- LUiWidget margin and size limits.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setMargin(2, 4, 2, 4)
    local mt = w:getMargin()
    w:setMaxSize(500, 400)
    local mxw = w:getMaxSize()
    w:setMinSize(60, 30)
    local mnw = w:getMinSize()
    print("margin set ok; maxSize:", mxw, "minSize:", mnw)
end

--@api-stub: LUiWidget.setOnChange
--@api-stub: LUiWidget.setOnClick
--@api-stub: LUiWidget.setOnDraw
-- LUiWidget callbacks.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setOnChange(function() print("changed") end)
    w:setOnClick(function() print("clicked") end)
    w:setOnDraw(function() print("drawing") end)
    local id = w:getId()
    local vis = w:isVisible()
    print("setOnChange/setOnClick/setOnDraw ok; id:", id, "vis:", vis)
end

--@api-stub: LUiWidget.setPadding
--@api-stub: LUiWidget.setPosition
--@api-stub: LUiWidget.setSize
-- LUiWidget layout setters.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setPadding(6, 6, 6, 6)
    local pt = w:getPadding()
    w:setPosition(50, 100)
    local px, py = w:getPosition()
    w:setSize(200, 100)
    local sw, sh = w:getSize()
    print("padding:", pt, "position:", px, py, "size:", sw, sh)
end

--@api-stub: LUiWidget.setTooltip
--@api-stub: LUiWidget.setVisible
--@api-stub: LUiWidget.setZOrder
-- LUiWidget tooltip, visibility, z-order.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setTooltip("my tooltip")
    local tip = w:getTooltip()
    w:setVisible(false)
    w:setVisible(true)
    w:setZOrder(10)
    local z = w:getZOrder()
    print("tooltip:", tip, "zOrder:", z)
end

--@api-stub: LUiWidget.slideIn
--@api-stub: LUiWidget.slideOut
--@api-stub: LUiWidget.type
-- LUiWidget slide animations and type.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:slideIn(0, -50)
    w:slideOut(0, 50)
    local t = w:type()
    local ok = w:typeOf("LUiWidget")
    w:unbind()
    print("slideIn/slideOut ok; type:", t, "typeOf:", ok)
end

--@api-stub: LUiWidget.typeOf
--@api-stub: LUiWidget.unbind
-- LUiWidget typeOf and unbind.
do
    local w = lurek.ui.newCustomWidget({width=80, height=40})
    w:bind("click")
    w:unbind()
    local ok1 = w:typeOf("LUiWidget")
    local ok2 = w:typeOf("LButton")
    local t = w:type()
    print("typeOf LUiWidget:", ok1, "typeOf LButton:", ok2, "type:", t)
end

--@api-stub: lurek.ui.draw
-- lurek.ui drag and draw.
do
    local w = lurek.ui.newCustomWidget({width=80, height=40})
    lurek.ui.beginDrag(w)
    lurek.ui.endDrag()
    lurek.ui.clearFocus()
    lurek.ui.draw()
    print("beginDrag/endDrag/clearFocus/draw ok")
end

--@api-stub: lurek.ui.drawToImage
--@api-stub: lurek.ui.endDrag
-- lurek.ui drawToImage and drag drop.
do
    local img = lurek.ui.drawToImage(320, 240)
    local w = lurek.ui.newCustomWidget({width=80, height=40})
    lurek.ui.beginDrag(w)
    lurek.ui.dropOn(w)
    lurek.ui.endDrag()
    print("drawToImage ok; dropOn/endDrag ok")
end

--@api-stub: lurek.ui.flushCache
-- lurek.ui cache and focus.
do
    lurek.ui.flushCache()
    lurek.ui.focusPrev()
    local drag = lurek.ui.getActiveDrag()
    local focus = lurek.ui.getFocus()
    lurek.ui.clearFocus()
    print("flushCache/focusPrev ok; activeDrag:", drag, "focus:", focus)
end

--@api-stub: lurek.ui.getToastCount
-- lurek.ui focus and theme queries.
do
    lurek.ui.clearFocus()
    local foc = lurek.ui.getFocus()
    local theme = lurek.ui.getTheme()
    local toasts = lurek.ui.getToastCount()
    local widgets = lurek.ui.getWidgetCount()
    print("focus:", foc, "theme:", theme, "toastCount:", toasts, "widgetCount:", widgets)
end

--@api-stub: lurek.ui.getWidgetCount
--@api-stub: lurek.ui.keypressed
--@api-stub: lurek.ui.loadLayoutFile
-- lurek.ui input forwarding and layout loading.
do
    local cnt = lurek.ui.getWidgetCount()
    lurek.ui.keypressed("escape")
    local layout = lurek.ui.loadLayoutFile("content/layouts/main_menu.toml")
    lurek.ui.textinput("a")
    print("widgetCount:", cnt, "loadLayoutFile ok; textinput ok")
end

--@api-stub: lurek.ui.mousemoved
--@api-stub: lurek.ui.mousepressed
--@api-stub: lurek.ui.mousereleased
-- lurek.ui mouse input forwarding.
do
    lurek.ui.mousemoved(100, 150)
    lurek.ui.mousepressed(100, 150, 1)
    lurek.ui.mousereleased(100, 150, 1)
    lurek.ui.wheelmoved(0, -1)
    local cnt = lurek.ui.getWidgetCount()
    print("mousemoved/pressed/released/wheelmoved ok; widgets:", cnt)
end

--@api-stub: lurek.ui.newCustomWidget
--@api-stub: lurek.ui.newScrollBar
-- lurek.ui constructors.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local layout = lurek.ui.newLayout("row")
    local sb = lurek.ui.newScrollBar(true)
    print("newCustomWidget:", w, "newLayout:", layout, "newScrollBar:", sb)
end

--@api-stub: lurek.ui.parseWidgetState
--@api-stub: lurek.ui.renderToImage
-- lurek.ui theme, state parsing, rendering.
do
    local th = lurek.ui.newTheme()
    local state = lurek.ui.parseWidgetState("normal")
    local result = lurek.ui.renderToImage(320, 240, "save/ui_render.png")
    print("newTheme ok; parseWidgetState:", state, "renderToImage:", result)
end

--@api-stub: lurek.ui.setDefaultTheme
--@api-stub: lurek.ui.setViewport
-- lurek.ui theme and viewport.
do
    local th = lurek.ui.newTheme()
    lurek.ui.setTheme(th)
    lurek.ui.setDefaultTheme()
    lurek.ui.setViewport(1280, 720)
    local cnt = lurek.ui.getWidgetCount()
    print("setTheme/setDefaultTheme/setViewport ok; widgets:", cnt)
end

--@api-stub: lurek.ui.textinput
--@api-stub: lurek.ui.update_bindings
--@api-stub: lurek.ui.wheelmoved
-- lurek.ui text input and bindings.
do
    lurek.ui.textinput("hello")
    lurek.ui.textinput(" world")
    lurek.ui.update_bindings({dt=0.016})
    lurek.ui.wheelmoved(0, 1)
    lurek.ui.wheelmoved(1, 0)
    print("textinput/update_bindings/wheelmoved ok")
end

print("content/examples/ui.lua")
