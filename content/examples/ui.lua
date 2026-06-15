-- content/examples/ui.lua
-- Auto-generated from content/examples2/ui_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/ui.lua

--- UI Module Part 1: core widgets (button, label, panel) and base LUiWidget operations

--@api: lurek.ui.newButton
do
    ---@type LButton
    local btn = lurek.ui.newButton("Click Me")
    print("type = " .. btn:type())
    print("text = " .. btn:getText())
end

--@api: LButton:setOnClick
do
    ---@type LButton
    local btn = lurek.ui.newButton("Submit")
    btn:setOnClick(function()
        print("button clicked!")
    end)
    btn:setId("submit_btn")
    print("button id = " .. btn:getId())
end

--@api: lurek.ui.newLabel
do
    local lbl = lurek.ui.newLabel("Hello, World!")
    print("type = " .. lbl:type())
    print("text = " .. lbl:getText())
    lbl:setText("Score: 100")
    print("updated text = " .. lbl:getText())
end

--@api: lurek.ui.newPanel
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    print("type = " .. panel:type())
    print("child count = " .. panel:getChildCount())
    print("visible = " .. tostring(panel:isVisible()))
end

--@api: LUiWidget:setPosition
do
    ---@type LButton
    local btn = lurek.ui.newButton("Pos Test")
    btn:setPosition(100, 50)
    local x, y = btn:getPosition()
    print("position = " .. x .. ", " .. y)
end

--@api: LUiWidget:getPosition
do
    ---@type LButton
    local btn = lurek.ui.newButton("Pos Test")
    btn:setPosition(100, 50)
    local x, y = btn:getPosition()
    print("position = " .. x .. ", " .. y)
end

--@api: LUiWidget:setSize
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setSize(300, 200)
    local w, h = panel:getSize()
    print("size = " .. w .. "x" .. h)
end

--@api: LUiWidget:getSize
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setSize(300, 200)
    local w, h = panel:getSize()
    print("size = " .. w .. "x" .. h)
end

--@api: LUiWidget:getRect
do
    local btn = lurek.ui.newButton("Bounds")
    btn:setPosition(50, 30)
    btn:setSize(120, 40)
    local x, y, w, h = btn:getRect()
    print("rect = " .. x .. "," .. y .. " " .. w .. "x" .. h)
end

--@api: LUiWidget:isVisible
do
    ---@type LLabel
    local lbl = lurek.ui.newLabel("Toggle Me")
    print("visible = " .. tostring(lbl:isVisible()))
    lbl:setVisible(false)
    print("hidden = " .. tostring(lbl:isVisible()))
end

--@api: LUiWidget:setVisible
do
    ---@type LLabel
    local lbl = lurek.ui.newLabel("Toggle Me")
    lbl:setVisible(false)
    print("hidden = " .. tostring(lbl:isVisible()))
end

--@api: LUiWidget:isEnabled
do
    ---@type LButton
    local btn = lurek.ui.newButton("Action")
    print("enabled = " .. tostring(btn:isEnabled()))
    btn:setEnabled(false)
    print("disabled = " .. tostring(btn:isEnabled()))
end

--@api: LUiWidget:setEnabled
do
    ---@type LButton
    local btn = lurek.ui.newButton("Action")
    btn:setEnabled(false)
    print("disabled = " .. tostring(btn:isEnabled()))
end

--@api: LUiWidget:getAlpha
do
    local panel = lurek.ui.newPanel()
    print("alpha = " .. panel:getAlpha())
    panel:setAlpha(0.5)
    print("set to 50% = " .. panel:getAlpha())
    panel:setAlpha(1.0)
end

--@api: LUiWidget:setAlpha
do
    local panel = lurek.ui.newPanel()
    print("alpha = " .. panel:getAlpha())
    panel:setAlpha(0.5)
    print("set to 50% = " .. panel:getAlpha())
    panel:setAlpha(1.0)
end

--@api: LUiWidget:animateAlpha
do
    local btn = lurek.ui.newButton("Fade")
    btn:setAlpha(1.0)
    btn:animateAlpha(0.0, 0.5)
    print("animating = " .. tostring(btn:isAnimating()))
    btn:cancelAnimations()
    btn:animateAlpha(0.0, 0.3, true)
    print("fade-out with hide_on_complete started")
end

--@api: LUiWidget:fadeIn
do
    ---@type LLabel
    local lbl = lurek.ui.newLabel("Fading")
    lbl:setAlpha(0)
    lbl:fadeIn()
    print("fading in, animating = " .. tostring(lbl:isAnimating()))
end

--@api: LUiWidget:fadeOut
do
    ---@type LLabel
    local lbl = lurek.ui.newLabel("Fading")
    lbl:fadeOut()
    print("fading out")
end

--@api: LUiWidget:animatePosition
do
    local panel = lurek.ui.newPanel()
    panel:setPosition(0, 0)
    panel:animatePosition(200, 100, 0.5)
    print("animating = " .. tostring(panel:isAnimating()))
    print("target = 200, 100")
end

--@api: LUiWidget:slideIn
do
    local panel = lurek.ui.newPanel()
    panel:cancelAnimations()
    panel:slideIn(300, 0)
    local x, y = panel:getPosition()
    print("visible = " .. tostring(panel:isVisible()))
    print("position = " .. x .. ", " .. y)
end

--@api: LUiWidget:slideOut
do
    local panel = lurek.ui.newPanel()
    panel:setVisible(true)
    panel:setPosition(40, 20)
    panel:slideOut(320, 20)
    local x, y = panel:getPosition()
    print("visible = " .. tostring(panel:isVisible()))
    print("position = " .. x .. ", " .. y)
end

--@api: LUiWidget:setId
do
    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    print("id = " .. btn:getId())
    print("tooltip = " .. btn:getTooltip())
end

--@api: LUiWidget:getId
do
    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    print("id = " .. btn:getId())
    print("tooltip = " .. btn:getTooltip())
end

--@api: LUiWidget:setTooltip
do
    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    print("id = " .. btn:getId())
    print("tooltip = " .. btn:getTooltip())
end

--@api: LUiWidget:getTooltip
do
    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    print("id = " .. btn:getId())
    print("tooltip = " .. btn:getTooltip())
end

--@api: LUiWidget:setZOrder
do
    local front = lurek.ui.newPanel()
    local back = lurek.ui.newPanel()
    front:setZOrder(10)
    back:setZOrder(1)
    print("front z = " .. front:getZOrder())
    print("back z = " .. back:getZOrder())
end

--@api: LUiWidget:getZOrder
do
    local front = lurek.ui.newPanel()
    local back = lurek.ui.newPanel()
    front:setZOrder(10)
    back:setZOrder(1)
    print("front z = " .. front:getZOrder())
    print("back z = " .. back:getZOrder())
end

--@api: LUiWidget:containsPoint
do
    local btn = lurek.ui.newButton("Hit Test")
    btn:setPosition(50, 50)
    btn:setSize(100, 40)
    print("(75,60) inside = " .. tostring(btn:containsPoint(75, 60)))
    print("(200,200) inside = " .. tostring(btn:containsPoint(200, 200)))
end

--@api: LUiWidget:getState
do
    ---@type LButton
    local btn = lurek.ui.newButton("State")
    local state = btn:getState()
    print("state = " .. state)
end

--@api: lurek.ui.getRoot
do
    local root = lurek.ui.getRoot()
    print("root = " .. tostring(root))
    print("widget count = " .. lurek.ui.getWidgetCount())
end

--@api: lurek.ui.update
do
    lurek.ui.update(1 / 60)
    lurek.ui.draw()
    print("UI frame processed")
end

--- UI Module Part 2: layout, containers (DockPanel, SplitPanel, ScrollPanel), flex, margin, padding

--@api: lurek.ui.newLayout
do
    local row = lurek.ui.newLayout("horizontal")
    print("type = " .. row:type())
    print("direction = " .. row:getDirection())
    print("spacing = " .. row:getSpacing())

    local col = lurek.ui.newLayout("vertical")
    col:setSpacing(10)
    print("direction = " .. col:getDirection())
    print("spacing = " .. col:getSpacing())
end

--@api: LLayout:setDirection
do
    ---@type LLayout
    local grid = lurek.ui.newLayout("grid")
    grid:setDirection("vertical")
    grid:setColumns(3)
    grid:setSpacing(5)
    print("direction = " .. grid:getDirection())
end

--@api: LLayout:setColumns
do
    ---@type LLayout
    local grid = lurek.ui.newLayout("grid")
    grid:setColumns(3)
    grid:setSpacing(5)
    print("direction = " .. grid:getDirection())
end

--@api: LLayout:setAlign
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setAlign("center")
    print("align = " .. layout:getAlign())
    layout:setAlign("stretch")
    print("align = " .. layout:getAlign())
end

--@api: LLayout:getAlign
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setAlign("center")
    print("align = " .. layout:getAlign())
    layout:setAlign("stretch")
    print("align = " .. layout:getAlign())
end

--@api: LLayout:setJustify
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setJustify("space-between")
    print("justify = " .. layout:getJustify())
    layout:setJustify("center")
    print("justify = " .. layout:getJustify())
end

--@api: LLayout:getJustify
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setJustify("space-between")
    print("justify = " .. layout:getJustify())
    layout:setJustify("center")
    print("justify = " .. layout:getJustify())
end

--@api: LLayout:setWrap
do
    ---@type LLayout
    local layout = lurek.ui.newLayout("horizontal")
    print("wrap = " .. tostring(layout:getWrap()))
    layout:setWrap(true)
    print("wrap enabled = " .. tostring(layout:getWrap()))
end

--@api: LLayout:getWrap
do
    ---@type LLayout
    local layout = lurek.ui.newLayout("horizontal")
    print("wrap = " .. tostring(layout:getWrap()))
    layout:setWrap(true)
    print("wrap enabled = " .. tostring(layout:getWrap()))
end

--@api: LUiWidget:addChild
do
    local layout = lurek.ui.newLayout("vertical")
    local btn1 = lurek.ui.newButton("First")
    local btn2 = lurek.ui.newButton("Second")
    local btn3 = lurek.ui.newButton("Third")
    layout:addChild(btn1)
    layout:addChild(btn2)
    layout:addChild(btn3)
    print("children = " .. layout:getChildCount())
    layout:removeChild(btn2)
    print("after remove = " .. layout:getChildCount())
end

--@api: LUiWidget:removeChild
do
    local layout = lurek.ui.newLayout("vertical")
    local btn1 = lurek.ui.newButton("First")
    local btn2 = lurek.ui.newButton("Second")
    local btn3 = lurek.ui.newButton("Third")
    layout:addChild(btn1)
    layout:addChild(btn2)
    layout:addChild(btn3)
    print("children = " .. layout:getChildCount())
    layout:removeChild(btn2)
    print("after remove = " .. layout:getChildCount())
end

--@api: LUiWidget:getChildCount
do
    local layout = lurek.ui.newLayout("vertical")
    local btn1 = lurek.ui.newButton("First")
    local btn2 = lurek.ui.newButton("Second")
    local btn3 = lurek.ui.newButton("Third")
    layout:addChild(btn1)
    layout:addChild(btn2)
    layout:addChild(btn3)
    print("children = " .. layout:getChildCount())
    layout:removeChild(btn2)
    print("after remove = " .. layout:getChildCount())
end

--@api: LUiWidget:getChildren
do
    local panel = lurek.ui.newPanel()
    panel:addChild(lurek.ui.newLabel("A"))
    panel:addChild(lurek.ui.newLabel("B"))
    panel:addChild(lurek.ui.newLabel("C"))
    local children = panel:getChildren()
    print("child list length = " .. #children)
end

--@api: LUiWidget:setMargin
do
    local btn = lurek.ui.newButton("Margin")
    btn:setMargin(10, 20, 10, 20)
    local top, right, bottom, left = btn:getMargin()
    print("margin = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
    btn:setMargin(5)
    top, right, bottom, left = btn:getMargin()
    print("uniform = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
end

--@api: LUiWidget:getMargin
do
    local btn = lurek.ui.newButton("Margin")
    btn:setMargin(10, 20, 10, 20)
    local top, right, bottom, left = btn:getMargin()
    print("margin = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
    btn:setMargin(5)
    top, right, bottom, left = btn:getMargin()
    print("uniform = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
end

--@api: LUiWidget:setPadding
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setPadding(8, 16, 8, 16)
    local top, right, bottom, left = panel:getPadding()
    print("padding = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
end

--@api: LUiWidget:getPadding
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setPadding(8, 16, 8, 16)
    local top, right, bottom, left = panel:getPadding()
    print("padding = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
end

--@api: LUiWidget:setFlexGrow
do
    local row = lurek.ui.newLayout("horizontal")
    local left = lurek.ui.newPanel()
    local right = lurek.ui.newPanel()
    left:setFlexGrow(1)
    right:setFlexGrow(2)
    row:addChild(left)
    row:addChild(right)
    print("left grow = " .. left:getFlexGrow())
    print("right grow = " .. right:getFlexGrow())
end

--@api: LUiWidget:getFlexGrow
do
    local row = lurek.ui.newLayout("horizontal")
    local left = lurek.ui.newPanel()
    local right = lurek.ui.newPanel()
    left:setFlexGrow(1)
    right:setFlexGrow(2)
    row:addChild(left)
    row:addChild(right)
    print("left grow = " .. left:getFlexGrow())
    print("right grow = " .. right:getFlexGrow())
end

--@api: LUiWidget:setFlexShrink
do
    local btn = lurek.ui.newButton("Shrinkable")
    btn:setFlexShrink(0)
    print("shrink = " .. btn:getFlexShrink())
    btn:setFlexShrink(1)
    print("shrink = " .. btn:getFlexShrink())
end

--@api: LUiWidget:getFlexShrink
do
    local btn = lurek.ui.newButton("Shrinkable")
    btn:setFlexShrink(0)
    print("shrink = " .. btn:getFlexShrink())
    btn:setFlexShrink(1)
    print("shrink = " .. btn:getFlexShrink())
end

--@api: LUiWidget:setMinSize
do
    local panel = lurek.ui.newPanel()
    panel:setMinSize(100, 50)
    local minW, minH = panel:getMinSize()
    print("min = " .. minW .. "x" .. minH)
    panel:setMaxSize(400, 300)
    local maxW, maxH = panel:getMaxSize()
    print("max = " .. maxW .. "x" .. maxH)
end

--@api: LUiWidget:getMinSize
do
    local panel = lurek.ui.newPanel()
    panel:setMinSize(100, 50)
    local minW, minH = panel:getMinSize()
    print("min = " .. minW .. "x" .. minH)
    panel:setMaxSize(400, 300)
    local maxW, maxH = panel:getMaxSize()
    print("max = " .. maxW .. "x" .. maxH)
end

--@api: LUiWidget:setMaxSize
do
    local panel = lurek.ui.newPanel()
    panel:setMinSize(100, 50)
    local minW, minH = panel:getMinSize()
    print("min = " .. minW .. "x" .. minH)
    panel:setMaxSize(400, 300)
    local maxW, maxH = panel:getMaxSize()
    print("max = " .. maxW .. "x" .. maxH)
end

--@api: LUiWidget:getMaxSize
do
    local panel = lurek.ui.newPanel()
    panel:setMinSize(100, 50)
    local minW, minH = panel:getMinSize()
    print("min = " .. minW .. "x" .. minH)
    panel:setMaxSize(400, 300)
    local maxW, maxH = panel:getMaxSize()
    print("max = " .. maxW .. "x" .. maxH)
end

--@api: LUiWidget:setAnchor
do
    local btn = lurek.ui.newButton("Anchored")
    btn:setAnchor(10, 10, 10, nil)
    print("anchors applied")
    btn:clearAnchor()
    btn:setAnchorCenter(0.5, 0.5)
    print("center anchor applied")
end

--@api: LUiWidget:setAnchorCenter
do
    local btn = lurek.ui.newButton("Anchored")
    btn:setAnchor(10, 10, 10, nil)
    print("anchors applied")
    btn:clearAnchor()
    btn:setAnchorCenter(0.5, 0.5)
    print("center anchor applied")
end

--@api: LUiWidget:clearAnchor
do
    local btn = lurek.ui.newButton("Anchored")
    btn:setAnchor(10, 10, 10, nil)
    print("anchors applied")
    btn:clearAnchor()
    btn:setAnchorCenter(0.5, 0.5)
    print("center anchor applied")
end

--@api: lurek.ui.newDockPanel
do
    local dock = lurek.ui.newDockPanel()
    local header = lurek.ui.newPanel()
    local sidebar = lurek.ui.newPanel()
    print("type = " .. dock:type())
    header:setSize(0, 60)
    sidebar:setSize(200, 0)
    dock:addChild(header)
    dock:addChild(sidebar)
    dock:dock(header._idx, "top")
    dock:dock(sidebar._idx, "left")
    dock:setSplitSize("left", 200)
    dock:setSplitSize("top", 60)
    print("docked count = " .. dock:getDockedCount())
    print("left size = " .. dock:getSplitSize("left"))
end

--@api: LDockPanel:undock
do
    local dock = lurek.ui.newDockPanel()
    local footer = lurek.ui.newPanel()
    dock:addChild(footer)
    dock:dock(footer._idx, "bottom")
    print("docked = " .. dock:getDockedCount())
    dock:undock(footer._idx)
    print("after undock = " .. dock:getDockedCount())
end

--@api: lurek.ui.newSplitPanel
do
    local split = lurek.ui.newSplitPanel("horizontal")
    local left = lurek.ui.newPanel()
    local right = lurek.ui.newPanel()
    print("type = " .. split:type())
    print("orientation = " .. split:getOrientation())
    split:setFirstChild(left._idx)
    split:setSecondChild(right._idx)
    split:setSplitPosition(0.3)
    split:setMinPanelSize(100)
    print("split at " .. split:getSplitPosition())
    print("min panel = " .. split:getMinPanelSize())
end

--@api: lurek.ui.newScrollPanel
do
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

--@api: LScrollPanel:setScrollSpeed
do
    ---@type LScrollPanel
    local scroll = lurek.ui.newScrollPanel()
    scroll:setScrollSpeed(30)
    print("scroll speed = " .. scroll:getScrollSpeed())
end

--@api: LScrollPanel:getScrollSpeed
do
    ---@type LScrollPanel
    local scroll = lurek.ui.newScrollPanel()
    scroll:setScrollSpeed(30)
    print("scroll speed = " .. scroll:getScrollSpeed())
end

--@api: LUiWidget:findById
do
    local root = lurek.ui.newLayout("vertical")
    local btn = lurek.ui.newButton("Find Me")
    btn:setId("target_btn")
    root:addChild(btn)
    local found = root:findById("target_btn")
    print("found = " .. tostring(found ~= nil))
end

--- UI Module Part 3: input widgets â€” TextInput, Checkbox, Slider, SpinBox, Switch, ComboBox

--@api: lurek.ui.newTextInput
do
    local input = lurek.ui.newTextInput()
    print("type = " .. input:type())
    print("text = '" .. input:getText() .. "'")
    input:setText("Hello")
    print("set text = " .. input:getText())
end

--@api: LTextInput:setPlaceholder
do
    ---@type LTextInput
    local input = lurek.ui.newTextInput()
    input:setPlaceholder("Enter your name...")
    print("placeholder = " .. input:getPlaceholder())
end

--@api: LTextInput:getPlaceholder
do
    ---@type LTextInput
    local input = lurek.ui.newTextInput()
    input:setPlaceholder("Enter your name...")
    print("placeholder = " .. input:getPlaceholder())
end

--@api: LTextInput:setMaxLength
do
    local input = lurek.ui.newTextInput()
    input:setMaxLength(50)
    input:setText("Short text")
    local pos = input:getCursorPosition()
    print("cursor at = " .. pos)
    print("focused = " .. tostring(input:isFocused()))
end

--@api: LTextInput:getCursorPosition
do
    local input = lurek.ui.newTextInput()
    input:setMaxLength(50)
    input:setText("Short text")
    local pos = input:getCursorPosition()
    print("cursor at = " .. pos)
    print("focused = " .. tostring(input:isFocused()))
end

--@api: lurek.ui.newCheckbox
do
    ---@type LCheckbox
    local cb = lurek.ui.newCheckbox("Enable Sound")
    print("type = " .. cb:type())
    print("text = " .. cb:getText())
    print("checked = " .. tostring(cb:isChecked()))
end

--@api: LCheckbox:setChecked
do
    local cb = lurek.ui.newCheckbox("Option A")
    cb:setChecked(true)
    print("checked = " .. tostring(cb:isChecked()))
    cb:setText("Option B")
    print("text = " .. cb:getText())
    cb:setChecked(false)
    print("unchecked = " .. tostring(cb:isChecked()))
end

--@api: LCheckbox:setText
do
    local cb = lurek.ui.newCheckbox("Option A")
    cb:setChecked(true)
    print("checked = " .. tostring(cb:isChecked()))
    cb:setText("Option B")
    print("text = " .. cb:getText())
    cb:setChecked(false)
    print("unchecked = " .. tostring(cb:isChecked()))
end

--@api: LCheckbox:setOnChange
do
    ---@type LCheckbox
    local cb = lurek.ui.newCheckbox("Fullscreen")
    cb:setOnChange(function()
        print("checkbox changed, now = " .. tostring(cb:isChecked()))
    end)
    print("change callback registered")
end

--@api: lurek.ui.newSlider
do
    local slider = lurek.ui.newSlider(0, 100)
    print("type = " .. slider:type())
    print("min = " .. slider:getMin())
    print("max = " .. slider:getMax())
    print("value = " .. slider:getValue())
end

--@api: LSlider:setValue
do
    local slider = lurek.ui.newSlider(0, 1)
    slider:setStep(0.1)
    slider:setValue(0.5)
    print("value = " .. slider:getValue())
    slider:setValue(1.5)
    print("clamped = " .. slider:getValue())
end

--@api: LSlider:setStep
do
    local slider = lurek.ui.newSlider(0, 1)
    slider:setStep(0.1)
    slider:setValue(0.5)
    print("value = " .. slider:getValue())
    slider:setValue(1.5)
    print("clamped = " .. slider:getValue())
end

--@api: LSlider:setRange
do
    local slider = lurek.ui.newSlider(0, 10)
    slider:setValue(5)
    print("before: " .. slider:getMin() .. " to " .. slider:getMax() .. " val=" .. slider:getValue())
    slider:setRange(0, 100)
    print("after: " .. slider:getMin() .. " to " .. slider:getMax() .. " val=" .. slider:getValue())
end

--@api: lurek.ui.newSpinBox
do
    local spin = lurek.ui.newSpinBox(1, 99)
    print("type = " .. spin:type())
    print("value = " .. spin:getValue())
    spin:setValue(50)
    print("set to 50 = " .. spin:getValue())
end

--@api: LSpinBox:increment
do
    local spin = lurek.ui.newSpinBox(0, 100)
    spin:setValue(10)
    spin:setStep(5)
    spin:increment()
    print("after increment = " .. spin:getValue())
    spin:decrement()
    spin:decrement()
    print("after 2 decrements = " .. spin:getValue())
end

--@api: LSpinBox:decrement
do
    local spin = lurek.ui.newSpinBox(0, 100)
    spin:setValue(10)
    spin:setStep(5)
    spin:increment()
    print("after increment = " .. spin:getValue())
    spin:decrement()
    spin:decrement()
    print("after 2 decrements = " .. spin:getValue())
end

--@api: LSpinBox:setStep
do
    local spin = lurek.ui.newSpinBox(0, 100)
    spin:setValue(10)
    spin:setStep(5)
    spin:increment()
    print("after increment = " .. spin:getValue())
    spin:decrement()
    spin:decrement()
    print("after 2 decrements = " .. spin:getValue())
end

--@api: LSpinBox:setRange
do
    ---@type LSpinBox
    local spin = lurek.ui.newSpinBox(0, 10)
    spin:setValue(8)
    spin:setRange(0, 5)
    print("clamped to range = " .. spin:getValue())
end

--@api: lurek.ui.newSwitch
do
    ---@type LSwitch
    local sw = lurek.ui.newSwitch(false)
    print("type = " .. sw:type())
    print("on = " .. tostring(sw:isOn()))
end

--@api: LSwitch:setOn
do
    local sw = lurek.ui.newSwitch(true)
    print("initial = " .. tostring(sw:isOn()))
    sw:toggle()
    print("toggled = " .. tostring(sw:isOn()))
    sw:setOn(true)
    print("forced on = " .. tostring(sw:isOn()))
end

--@api: LSwitch:toggle
do
    local sw = lurek.ui.newSwitch(true)
    print("initial = " .. tostring(sw:isOn()))
    sw:toggle()
    print("toggled = " .. tostring(sw:isOn()))
    sw:setOn(true)
    print("forced on = " .. tostring(sw:isOn()))
end

--@api: lurek.ui.newComboBox
do
    ---@type LComboBox
    local combo = lurek.ui.newComboBox()
    print("type = " .. combo:type())
    print("items = " .. combo:getItemCount())
end

--@api: LComboBox:addItem
do
    local combo = lurek.ui.newComboBox()
    combo:addItem("Easy")
    combo:addItem("Normal")
    combo:addItem("Hard")
    combo:addItem("Nightmare")
    print("item count = " .. combo:getItemCount())
    print("item 2 = " .. combo:getItem(2))
    print("item 4 = " .. combo:getItem(4))
end

--@api: LComboBox:getItem
do
    local combo = lurek.ui.newComboBox()
    combo:addItem("Easy")
    combo:addItem("Normal")
    combo:addItem("Hard")
    combo:addItem("Nightmare")
    print("item count = " .. combo:getItemCount())
    print("item 2 = " .. combo:getItem(2))
    print("item 4 = " .. combo:getItem(4))
end

--@api: LComboBox:getItemCount
do
    local combo = lurek.ui.newComboBox()
    combo:addItem("Easy")
    combo:addItem("Normal")
    combo:addItem("Hard")
    combo:addItem("Nightmare")
    print("item count = " .. combo:getItemCount())
    print("item 2 = " .. combo:getItem(2))
    print("item 4 = " .. combo:getItem(4))
end

--@api: LComboBox:getSelectedIndex
do
    local combo = lurek.ui.newComboBox()
    combo:addItem("Red")
    combo:addItem("Green")
    combo:addItem("Blue")
    combo:setSelectedIndex(2)
    local idx = combo:getSelectedIndex()
    local item = combo:getSelectedItem()
    print("selected index = " .. idx)
    print("selected item = " .. tostring(item))
    combo:clearItems()
    print("after clear = " .. combo:getItemCount())
end

--@api: LComboBox:getSelectedItem
do
    local combo = lurek.ui.newComboBox()
    combo:addItem("Red")
    combo:addItem("Green")
    combo:addItem("Blue")
    combo:setSelectedIndex(2)
    local idx = combo:getSelectedIndex()
    local item = combo:getSelectedItem()
    print("selected index = " .. idx)
    print("selected item = " .. tostring(item))
    combo:clearItems()
    print("after clear = " .. combo:getItemCount())
end

--@api: LComboBox:clearItems
do
    local combo = lurek.ui.newComboBox()
    combo:addItem("Red")
    combo:addItem("Green")
    combo:addItem("Blue")
    combo:setSelectedIndex(2)
    local idx = combo:getSelectedIndex()
    local item = combo:getSelectedItem()
    print("selected index = " .. idx)
    print("selected item = " .. tostring(item))
    combo:clearItems()
    print("after clear = " .. combo:getItemCount())
end

--@api: lurek.ui.setFocus
do
    local input = lurek.ui.newTextInput()
    lurek.ui.setFocus(input)
    local focused = lurek.ui.getFocus()
    print("focus set, has focus = " .. tostring(focused ~= nil))
    lurek.ui.clearFocus()
    focused = lurek.ui.getFocus()
    print("after clear = " .. tostring(focused))
end

--@api: lurek.ui.focusNext
do
    local a = lurek.ui.newTextInput()
    local b = lurek.ui.newTextInput()
    local c = lurek.ui.newTextInput()
    lurek.ui.setFocus(a)
    lurek.ui.focusNext()
    print("moved focus forward")
    lurek.ui.focusPrev()
    print("moved focus back")
end

--- UI Module Part 4: lists, menus, tabs, accordion

--@api: lurek.ui.newList
do
    ---@type LListBox
    local list = lurek.ui.newList()
    print("type = " .. list:type())
    print("items = " .. list:getItemCount())
end

--@api: LListBox:addItem
do
    local list = lurek.ui.newList()
    list:addItem("Sword")
    list:addItem("Shield")
    list:addItem("Potion")
    list:addItem("Scroll")
    print("count = " .. list:getItemCount())
    print("item 1 = " .. list:getItem(1))
    print("item 3 = " .. list:getItem(3))
end

--@api: LListBox:getItem
do
    local list = lurek.ui.newList()
    list:addItem("Sword")
    list:addItem("Shield")
    list:addItem("Potion")
    list:addItem("Scroll")
    print("count = " .. list:getItemCount())
    print("item 1 = " .. list:getItem(1))
    print("item 3 = " .. list:getItem(3))
end

--@api: LListBox:getItemCount
do
    local list = lurek.ui.newList()
    list:addItem("Sword")
    list:addItem("Shield")
    list:addItem("Potion")
    list:addItem("Scroll")
    print("count = " .. list:getItemCount())
    print("item 1 = " .. list:getItem(1))
    print("item 3 = " .. list:getItem(3))
end

--@api: LListBox:setSelectedIndex
do
    local list = lurek.ui.newList()
    list:addItem("Option A")
    list:addItem("Option B")
    list:addItem("Option C")
    list:setSelectedIndex(2)
    print("selected = " .. list:getSelectedIndex())
    list:setSelectedIndex(3)
    print("changed to = " .. list:getSelectedIndex())
end

--@api: LListBox:getSelectedIndex
do
    local list = lurek.ui.newList()
    list:addItem("Option A")
    list:addItem("Option B")
    list:addItem("Option C")
    list:setSelectedIndex(2)
    print("selected = " .. list:getSelectedIndex())
    list:setSelectedIndex(3)
    print("changed to = " .. list:getSelectedIndex())
end

--@api: LListBox:removeItem
do
    local list = lurek.ui.newList()
    list:addItem("First")
    list:addItem("Second")
    list:addItem("Third")
    list:setItemHeight(30)
    list:removeItem(2)
    print("after remove: count=" .. list:getItemCount())
    print("item 2 now = " .. tostring(list:getItem(2)))
    list:clearItems()
    print("after clear = " .. list:getItemCount())
end

--@api: LListBox:clearItems
do
    local list = lurek.ui.newList()
    list:addItem("First")
    list:addItem("Second")
    list:addItem("Third")
    list:setItemHeight(30)
    list:removeItem(2)
    print("after remove: count=" .. list:getItemCount())
    print("item 2 now = " .. tostring(list:getItem(2)))
    list:clearItems()
    print("after clear = " .. list:getItemCount())
end

--@api: LListBox:setItemHeight
do
    local list = lurek.ui.newList()
    list:addItem("First")
    list:addItem("Second")
    list:addItem("Third")
    list:setItemHeight(30)
    list:removeItem(2)
    print("after remove: count=" .. list:getItemCount())
    print("item 2 now = " .. tostring(list:getItem(2)))
    list:clearItems()
    print("after clear = " .. list:getItemCount())
end

--@api: lurek.ui.newMenuBar
do
    ---@type LMenuBar
    local bar = lurek.ui.newMenuBar()
    print("type = " .. bar:type())
    print("menu count = " .. bar:getMenuCount())
end

--@api: lurek.ui.newMenuItem
do
    local item = lurek.ui.newMenuItem("File")
    print("type = " .. item:type())
    print("text = " .. item:getText())
    item:setShortcut("Ctrl+F")
    print("shortcut = " .. item:getShortcut())
end

--@api: LMenuItem:setText
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

--@api: LMenuItem:setOnClick
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

--@api: LMenuItem:setChecked
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

--@api: LMenuItem:isChecked
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

--@api: LMenuItem:addSubItem
do
    local fileMenu = lurek.ui.newMenuItem("File")
    local openItem = lurek.ui.newMenuItem("Open")
    openItem:setShortcut("Ctrl+O")
    local saveItem = lurek.ui.newMenuItem("Save")
    saveItem:setShortcut("Ctrl+S")
    local exitItem = lurek.ui.newMenuItem("Exit")
    fileMenu:addSubItem(openItem._idx)
    fileMenu:addSubItem(saveItem._idx)
    fileMenu:addSubItem(exitItem._idx)
    local subs = fileMenu:getSubItems()
    print("File has " .. #subs .. " sub-items")
end

--@api: LMenuItem:getSubItems
do
    local fileMenu = lurek.ui.newMenuItem("File")
    local openItem = lurek.ui.newMenuItem("Open")
    openItem:setShortcut("Ctrl+O")
    local saveItem = lurek.ui.newMenuItem("Save")
    saveItem:setShortcut("Ctrl+S")
    local exitItem = lurek.ui.newMenuItem("Exit")
    fileMenu:addSubItem(openItem._idx)
    fileMenu:addSubItem(saveItem._idx)
    fileMenu:addSubItem(exitItem._idx)
    local subs = fileMenu:getSubItems()
    print("File has " .. #subs .. " sub-items")
end

--@api: LMenuBar:addMenu
do
    local bar = lurek.ui.newMenuBar()
    local fileMenu = lurek.ui.newMenuItem("File")
    local editMenu = lurek.ui.newMenuItem("Edit")
    local viewMenu = lurek.ui.newMenuItem("View")
    bar:addMenu(fileMenu._idx)
    bar:addMenu(editMenu._idx)
    bar:addMenu(viewMenu._idx)
    print("menus = " .. bar:getMenuCount())
    local menus = bar:getMenus()
    print("menu indices: " .. #menus .. " entries")
end

--@api: LMenuBar:getMenuCount
do
    local bar = lurek.ui.newMenuBar()
    local fileMenu = lurek.ui.newMenuItem("File")
    local editMenu = lurek.ui.newMenuItem("Edit")
    local viewMenu = lurek.ui.newMenuItem("View")
    bar:addMenu(fileMenu._idx)
    bar:addMenu(editMenu._idx)
    bar:addMenu(viewMenu._idx)
    print("menus = " .. bar:getMenuCount())
    local menus = bar:getMenus()
    print("menu indices: " .. #menus .. " entries")
end

--@api: LMenuBar:getMenus
do
    local bar = lurek.ui.newMenuBar()
    local fileMenu = lurek.ui.newMenuItem("File")
    local editMenu = lurek.ui.newMenuItem("Edit")
    local viewMenu = lurek.ui.newMenuItem("View")
    bar:addMenu(fileMenu._idx)
    bar:addMenu(editMenu._idx)
    bar:addMenu(viewMenu._idx)
    print("menus = " .. bar:getMenuCount())
    local menus = bar:getMenus()
    print("menu indices: " .. #menus .. " entries")
end

--@api: LMenuBar:removeMenu
do
    local bar = lurek.ui.newMenuBar()
    local m = lurek.ui.newMenuItem("Tools")
    bar:addMenu(m._idx)
    print("before remove = " .. bar:getMenuCount())
    local ok = bar:removeMenu(m._idx)
    print("removed = " .. tostring(ok))
    print("after remove = " .. bar:getMenuCount())
end

--@api: lurek.ui.newTabBar
do
    ---@type LTabBar
    local tabs = lurek.ui.newTabBar()
    print("type = " .. tabs:type())
    print("tab count = " .. tabs:getTabCount())
end

--@api: LTabBar:addTab
do
    local tabs = lurek.ui.newTabBar()
    tabs:addTab("General")
    tabs:addTab("Graphics")
    tabs:addTab("Audio")
    tabs:addTab("Controls")
    print("count = " .. tabs:getTabCount())
    print("tab 1 = " .. tabs:getTab(1))
    print("tab 3 = " .. tabs:getTab(3))
end

--@api: LTabBar:getTab
do
    local tabs = lurek.ui.newTabBar()
    tabs:addTab("General")
    tabs:addTab("Graphics")
    tabs:addTab("Audio")
    tabs:addTab("Controls")
    print("count = " .. tabs:getTabCount())
    print("tab 1 = " .. tabs:getTab(1))
    print("tab 3 = " .. tabs:getTab(3))
end

--@api: LTabBar:getTabCount
do
    local tabs = lurek.ui.newTabBar()
    tabs:addTab("General")
    tabs:addTab("Graphics")
    tabs:addTab("Audio")
    tabs:addTab("Controls")
    print("count = " .. tabs:getTabCount())
    print("tab 1 = " .. tabs:getTab(1))
    print("tab 3 = " .. tabs:getTab(3))
end

--@api: LTabBar:setActiveTab
do
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

--@api: LTabBar:getActiveTab
do
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

--@api: LTabBar:removeTab
do
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

--@api: lurek.ui.newAccordion
do
    ---@type LAccordion
    local acc = lurek.ui.newAccordion()
    print("type = " .. acc:type())
    print("sections = " .. acc:getSectionCount())
end

--@api: LAccordion:addSection
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("Player Stats")
    acc:addSection("Inventory")
    acc:addSection("Quest Log")
    print("sections = " .. acc:getSectionCount())
    print("section 1 = " .. acc:getSectionTitle(1))
    print("section 2 = " .. acc:getSectionTitle(2))
end

--@api: LAccordion:getSectionCount
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("Player Stats")
    acc:addSection("Inventory")
    acc:addSection("Quest Log")
    print("sections = " .. acc:getSectionCount())
    print("section 1 = " .. acc:getSectionTitle(1))
    print("section 2 = " .. acc:getSectionTitle(2))
end

--@api: LAccordion:getSectionTitle
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("Player Stats")
    acc:addSection("Inventory")
    acc:addSection("Quest Log")
    print("sections = " .. acc:getSectionCount())
    print("section 1 = " .. acc:getSectionTitle(1))
    print("section 2 = " .. acc:getSectionTitle(2))
end

--@api: LAccordion:toggleSection
do
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

--@api: LAccordion:isSectionExpanded
do
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

--@api: LAccordion:setExclusive
do
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

--@api: lurek.ui.newDialog
do
    local modal = lurek.ui.newDialog("Quest Reward")
    modal:setPosition(120, 100)
    modal:setSize(320, 220)
    modal:setModal(true)
    modal:setDraggable(true)
    modal:setResizable(true)
    modal:setCenterOnOpen(false)
    modal:setCloseable(false)

    local body = lurek.ui.newPanel()
    body:setSize(300, 150)
    local preview = lurek.ui.newImageWidget()
    preview:setSize(64, 64)
    local copy = lurek.ui.newLabel("Choose your reward and confirm.")
    copy:setPosition(76, 8)
    body:addChild(preview)
    body:addChild(copy)

    local footer = lurek.ui.newLayout("horizontal")
    footer:setSize(300, 26)
    modal:setContent(body._idx)
    modal:setFooter(footer._idx)
    modal:addAction("Equip", function(_, action_idx)
        print("default action fired:", action_idx)
    end, "default", true)
    modal:addAction("Back", function(_, action_idx)
        print("cancel action fired:", action_idx)
    end, "cancel", true)
    modal:setDefaultAction(1)
    modal:setCancelAction(2)
    modal:open()

    local inspector = lurek.ui.newDialog("Companion Notes")
    inspector:setModal(false)
    inspector:setDismissOnOutsideClick(true)
    inspector:setDraggable(true)
    inspector:setResizable(true)
    inspector:setCenterOnOpen(false)
    inspector:setPosition(470, 110)
    inspector:setSize(260, 180)
    inspector:addButton("Close")
    inspector:open()

    print("modal open:", modal:isOpen(), "non modal open:", inspector:isOpen())
end

--@api: lurek.ui.newWindow
do
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

    win:setTitle("Object Inspector")
    print("title:", win:getTitle())
    win:setDraggable(false)
    print("draggable after disable:", win:isDraggable())
    win:setResizable(false)
    print("resizable after disable:", win:isResizable())
    win:setCloseable(false)
    print("closeable after disable:", win:isCloseable())
end

--@api: lurek.ui.newToolbar
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("save", "Save file")
    print("orientation:", tb:getOrientation())
end

--@api: lurek.ui.newStatusBar
do
    local sb = lurek.ui.newStatusBar()
    sb:addSection("Ready", 150)
    print("section count:", sb:getSectionCount())
    print("section 1:", sb:getSectionText(1))
end

--@api: lurek.ui.newProgressBar
do
    local bar = lurek.ui.newProgressBar(0, 100)
    bar:setValue(35)
    print("value:", bar:getValue())
    print("progress (normalized):", bar:getProgress())
end

--@api: lurek.ui.newImageWidget
do
    local img = lurek.ui.newImageWidget()
    img:setScaleMode("fit")
    print("scale mode:", img:getScaleMode())
    img:setTint(1.0, 0.8, 0.6, 0.9)
    local r, g, b, a = img:getTint()
    print("tint:", r, g, b, a)
end

--@api: lurek.ui.newNinePatch
do
    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(128, 128)
    np:setInsets(16, 16, 16, 16)
    local w, h = np:getImageDimensions()
    print("image size:", w, h)
end

--@api: lurek.ui.newBadge
do
    local badge = lurek.ui.newBadge(5)
    print("count:", badge:getCount())
    print("display:", badge:getDisplayText())
    badge:setCount(120)
    print("large count display:", badge:getDisplayText())
end

--@api: lurek.ui.newSpacer
do
    local sp = lurek.ui.newSpacer(20, 10)
    sp:setSize(40, 20)
    local w, h = sp:getSize()
    print("spacer size:", w, h)
end

--@api: lurek.ui.newSeparator
do
    local sep = lurek.ui.newSeparator(false)
    print("is vertical:", sep:isVertical())
    sep:setThickness(2)
    print("new thickness:", sep:getThickness())
end

--@api: lurek.ui.newColorPicker
do
    local cp = lurek.ui.newColorPicker()
    cp:setColor(0.8, 0.2, 0.5, 1.0)
    local r, g, b, a = cp:getColor()
    print("color:", r, g, b, a)
    cp:setColorMode("hsv")
    print("mode:", cp:getColorMode())
end

--@api: lurek.ui.newRadioButton
do
    local rb1 = lurek.ui.newRadioButton("Small", "size_group")
    local rb2 = lurek.ui.newRadioButton("Medium", "size_group")
    local rb3 = lurek.ui.newRadioButton("Large", "size_group")
    rb2:setSelected(true)
    print("rb1 selected:", rb1:isSelected())
    print("rb2 selected:", rb2:isSelected())
    print("rb2 group:", rb2:getGroup())
    print("rb2 text:", rb2:getText())
end

--@api: lurek.ui.newTreeView
do
    local tree = lurek.ui.newTreeView()
    local root = tree:addNode("Project")
    tree:addNode("main.lua", root)
    print("total nodes:", tree:getNodeCount())
    print("root text:", tree:getNodeText(root))
end

--@api: lurek.ui.newToast
do
    local toast = lurek.ui.newToast("File saved!", 2.5)
    print("message:", toast:getMessage())
    print("duration:", toast:getDuration())
    toast:setMessage("Upload complete")
    toast:setDuration(4.0)
    print("updated message:", toast:getMessage())
    print("expired:", toast:isExpired())
end

--@api: lurek.ui.newTooltipPanel
do
    local btn = lurek.ui.newButton("Hover me")
    local tip = lurek.ui.newTooltipPanel("Click to submit form")
    tip:setDelay(0.5)
    tip:setTarget(btn._idx)
    print("tooltip text:", tip:getText())
    print("delay:", tip:getDelay())
    print("target:", tip:getTarget())
    tip:setText("Updated tooltip text")
    print("new text:", tip:getText())
end

--@api: lurek.ui.newTheme
do
    local theme = lurek.ui.newTheme()
    theme:setStyle("button", "normal", { bg_r = 0.2, bg_g = 0.2, bg_b = 0.3, bg_a = 1.0, fg_r = 1.0, fg_g = 1.0, fg_b = 1.0, fg_a = 1.0, })
    theme:setStyle("button", "hovered", { bg_r = 0.3, bg_g = 0.3, bg_b = 0.5, bg_a = 1.0, })
    lurek.ui.setTheme(theme)
    print("theme active:", lurek.ui.getTheme())
    print("theme type:", theme:type())
end

--@api: lurek.ui.setTheme
do
    local theme = lurek.ui.newTheme()
    theme:setStyle("button", "normal", { bg_r = 0.2, bg_g = 0.2, bg_b = 0.3, bg_a = 1.0, fg_r = 1.0, fg_g = 1.0, fg_b = 1.0, fg_a = 1.0, })
    theme:setStyle("button", "hovered", { bg_r = 0.3, bg_g = 0.3, bg_b = 0.5, bg_a = 1.0, })
    lurek.ui.setTheme(theme)
    print("theme active:", lurek.ui.getTheme())
    print("theme type:", theme:type())
end

--@api: lurek.ui.getTheme
do
    local theme = lurek.ui.newTheme()
    theme:setStyle("button", "normal", { bg_r = 0.2, bg_g = 0.2, bg_b = 0.3, bg_a = 1.0, fg_r = 1.0, fg_g = 1.0, fg_b = 1.0, fg_a = 1.0, })
    theme:setStyle("button", "hovered", { bg_r = 0.3, bg_g = 0.3, bg_b = 0.5, bg_a = 1.0, })
    lurek.ui.setTheme(theme)
    print("theme active:", lurek.ui.getTheme())
    print("theme type:", theme:type())
end

--@api: lurek.ui.getFocus
do
    local btn1 = lurek.ui.newButton("First")
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

--@api: lurek.ui.focusPrev
do
    local btn1 = lurek.ui.newButton("First")
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

--@api: lurek.ui.clearFocus
do
    local btn1 = lurek.ui.newButton("First")
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

--@api: lurek.ui.beginDrag
do
    local source = lurek.ui.newPanel()
    local target = lurek.ui.newPanel()
    lurek.ui.beginDrag(source)
    print("active drag:", lurek.ui.getActiveDrag())
    lurek.ui.dropOn(target)
    print("after drop, active drag:", lurek.ui.getActiveDrag())
end

--@api: lurek.ui.getActiveDrag
do
    local source = lurek.ui.newPanel()
    local target = lurek.ui.newPanel()
    lurek.ui.beginDrag(source)
    print("active drag:", lurek.ui.getActiveDrag())
    lurek.ui.dropOn(target)
    print("after drop, active drag:", lurek.ui.getActiveDrag())
end

--@api: lurek.ui.dropOn
do
    local source = lurek.ui.newPanel()
    local target = lurek.ui.newPanel()
    lurek.ui.beginDrag(source)
    print("active drag:", lurek.ui.getActiveDrag())
    lurek.ui.dropOn(target)
    print("after drop, active drag:", lurek.ui.getActiveDrag())
end

--- UI Part 8: LAccordion, LColorPicker, LProgressBar, LMenuBar

--@api: LAccordion:isExclusive
do
    local acc = lurek.ui.newAccordion()
    print("type=" .. acc:type())
    acc:addSection("Section A")
    acc:addSection("Section B")
    print("count=" .. acc:getSectionCount())
    print("title0=" .. acc:getSectionTitle(1))
    print("expanded0=" .. tostring(acc:isSectionExpanded(1)))
    acc:toggleSection(1)
    print("expanded0_after=" .. tostring(acc:isSectionExpanded(1)))
    print("exclusive=" .. tostring(acc:isExclusive()))
    acc:setExclusive(true)
    print("exclusive_after=" .. tostring(acc:isExclusive()))
end

--@api: LColorPicker:getColor
do
    local cp = lurek.ui.newColorPicker()
    print("type=" .. cp:type())
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    print("mode=" .. tostring(cp:getColorMode()))
    cp:setColorMode("hsv")
    print("mode_after=" .. cp:getColorMode())
    print("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2)
        print("changed", r2, g2, b2, a2)
    end)
end

--@api: LColorPicker:getColorMode
do
    local cp = lurek.ui.newColorPicker()
    print("type=" .. cp:type())
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    print("mode=" .. tostring(cp:getColorMode()))
    cp:setColorMode("hsv")
    print("mode_after=" .. cp:getColorMode())
    print("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) print("changed", r2, g2, b2, a2) end)
end

--@api: LColorPicker:getShowAlpha
do
    local cp = lurek.ui.newColorPicker()
    print("type=" .. cp:type())
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    print("mode=" .. tostring(cp:getColorMode()))
    cp:setColorMode("hsv")
    print("mode_after=" .. cp:getColorMode())
    print("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) print("changed", r2, g2, b2, a2) end)
end

--@api: LColorPicker:setColor
do
    local cp = lurek.ui.newColorPicker()
    print("type=" .. cp:type())
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    print("mode=" .. tostring(cp:getColorMode()))
    cp:setColorMode("hsv")
    print("mode_after=" .. cp:getColorMode())
    print("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) print("changed", r2, g2, b2, a2) end)
end

--@api: LColorPicker:setColorMode
do
    local cp = lurek.ui.newColorPicker()
    print("type=" .. cp:type())
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    print("mode=" .. tostring(cp:getColorMode()))
    cp:setColorMode("hsv")
    print("mode_after=" .. cp:getColorMode())
    print("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) print("changed", r2, g2, b2, a2) end)
end

--@api: LColorPicker:setOnChange
do
    local cp = lurek.ui.newColorPicker()
    print("type=" .. cp:type())
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    print("mode=" .. tostring(cp:getColorMode()))
    cp:setColorMode("hsv")
    print("mode_after=" .. cp:getColorMode())
    print("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) print("changed", r2, g2, b2, a2) end)
end

--@api: LColorPicker:setShowAlpha
do
    local cp = lurek.ui.newColorPicker()
    print("type=" .. cp:type())
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    print("mode=" .. tostring(cp:getColorMode()))
    cp:setColorMode("hsv")
    print("mode_after=" .. cp:getColorMode())
    print("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) print("changed", r2, g2, b2, a2) end)
end

--@api: LProgressBar:getMax
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

--@api: LProgressBar:getMin
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

--@api: LProgressBar:getProgress
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

--@api: LProgressBar:getValue
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

--@api: LProgressBar:setRange
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

--@api: LProgressBar:setValue
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

--@api: LStatusBar:addSection
do
    local sb = lurek.ui.newStatusBar()
    print("type=" .. sb:type())
    sb:addSection("Ready", 120)
    sb:addSection("Line 1", 80)
    print("sections=" .. sb:getSectionCount())
    print("text1=" .. sb:getSectionText(1))
    sb:setSectionText(1, "Loading...")
    print("text1_after=" .. sb:getSectionText(1))
end

--@api: LStatusBar:getSectionCount
do
    local sb = lurek.ui.newStatusBar()
    print("type=" .. sb:type())
    sb:addSection("Ready", 120)
    sb:addSection("Line 1", 80)
    print("sections=" .. sb:getSectionCount())
    print("text1=" .. sb:getSectionText(1))
    sb:setSectionText(1, "Loading...")
    print("text1_after=" .. sb:getSectionText(1))
end

--@api: LStatusBar:getSectionText
do
    local sb = lurek.ui.newStatusBar()
    print("type=" .. sb:type())
    sb:addSection("Ready", 120)
    sb:addSection("Line 1", 80)
    print("sections=" .. sb:getSectionCount())
    print("text1=" .. sb:getSectionText(1))
    sb:setSectionText(1, "Loading...")
    print("text1_after=" .. sb:getSectionText(1))
end

--@api: LStatusBar:setSectionText
do
    local sb = lurek.ui.newStatusBar()
    print("type=" .. sb:type())
    sb:addSection("Ready", 120)
    sb:addSection("Line 1", 80)
    print("sections=" .. sb:getSectionCount())
    print("text1=" .. sb:getSectionText(1))
    sb:setSectionText(1, "Loading...")
    print("text1_after=" .. sb:getSectionText(1))
end

--@api: LToolbar:addButton
do
    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    print("btn=" .. tostring(bar:getButton("btn_save") ~= nil))
end

--@api: LToolbar:addSeparator
do
    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    bar:addSeparator()
    print("separator added")
end

--@api: LToolbar:getButton

do
    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    local btn = bar:getButton("btn_save")
    print("btn=" .. tostring(btn ~= nil))
end

--@api: LToolbar:getOrientation
do
    local bar = lurek.ui.newToolbar("horizontal")
    print("orientation=" .. bar:getOrientation())
end

--@api: LToolbar:isButtonToggled
do
    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    print("toggled=" .. tostring(bar:isButtonToggled("btn_save")))
end

--@api: LToolbar:setButtonEnabled
do
    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_open", "Open file")
    bar:setButtonEnabled("btn_open", false)
    print("btn_open disabled")
end

--@api: LToolbar:setButtonToggled
do
    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    bar:setButtonToggled("btn_save", true)
    print("toggled_after=" .. tostring(bar:isButtonToggled("btn_save")))
end

--@api: LToolbar:setOrientation
do
    local bar = lurek.ui.newToolbar("horizontal")
    bar:setOrientation("vertical")
    print("orientation_after=" .. bar:getOrientation())
end

--@api: lurek.ui.addToast
do
    lurek.ui.addToast({ message = "File saved successfully", duration = 3.0, type = "info" })
    print("toast added")
    local layout = lurek.ui.loadLayout({ type = "panel", children = {} })
    print("layout=" .. tostring(layout ~= nil))
end

--@api: lurek.ui.loadLayout
do
    lurek.ui.addToast({ message = "File saved successfully", duration = 3.0, type = "info" })
    print("toast added")
    local layout = lurek.ui.loadLayout({
        type = "layout",
        direction = "grid",
        columns = 2,
        padding = { 8, 8, 8, 8 },
        children = {
            { type = "label", text = "HP", textAlign = "right", margin = { 2, 4, 2, 4 } },
        },
    })
    print("layout=" .. tostring(layout ~= nil))
end

--@api: lurek.ui.setAutoInput
do
    lurek.ui.setAutoInput(true)
    print("auto input=" .. tostring(lurek.ui.hasAutoInput()))
end

--@api: lurek.ui.hasAutoInput
do
    lurek.ui.setAutoInput(true)
    print("auto input=" .. tostring(lurek.ui.hasAutoInput()))
end

--@api: lurek.ui.setAutoUpdate
do
    lurek.ui.setAutoUpdate(true)
    print("auto update=" .. tostring(lurek.ui.hasAutoUpdate()))
end

--@api: lurek.ui.hasAutoUpdate
do
    lurek.ui.setAutoUpdate(true)
    print("auto update=" .. tostring(lurek.ui.hasAutoUpdate()))
end

--- UI Part 10: LBadge, LDockPanel, LImageWidget, LNinePatch, LRadioButton, LSpinBox, LSplitPanel, LSwitch, LTable, LToast, LTooltipPanel, LTreeView

--@api: LBadge:getCount
do
    local badge = lurek.ui.newBadge(3)
    print("type=" .. badge:type())
    print("count=" .. badge:getCount())
    badge:setCount(7)
    print("count_after=" .. badge:getCount())
    local text = badge:getDisplayText()
    print("text=" .. tostring(text))
end

--@api: LBadge:getDisplayText
do
    local badge = lurek.ui.newBadge(3)
    print("type=" .. badge:type())
    print("count=" .. badge:getCount())
    badge:setCount(7)
    print("count_after=" .. badge:getCount())
    local text = badge:getDisplayText()
    print("text=" .. tostring(text))
end

--@api: LBadge:setCount
do
    local badge = lurek.ui.newBadge(3)
    print("type=" .. badge:type())
    print("count=" .. badge:getCount())
    badge:setCount(7)
    print("count_after=" .. badge:getCount())
    local text = badge:getDisplayText()
    print("text=" .. tostring(text))
end

--@api: LDockPanel:dock
do
    local dp = lurek.ui.newDockPanel()
    local child = lurek.ui.newPanel()
    print("type=" .. dp:type())
    dp:addChild(child)
    dp:dock(child._idx, "left")
    print("docked=" .. dp:getDockedCount())
    print("split_size=" .. tostring(dp:getSplitSize("left")))
    dp:setSplitSize("left", 150)
    dp:undock(child._idx)
    print("docked_after=" .. dp:getDockedCount())
end

--@api: LDockPanel:getDockedCount
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

--@api: LDockPanel:getSplitSize
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

--@api: LDockPanel:setSplitSize
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

--@api: LImageWidget:getScaleMode
do
    local iw = lurek.ui.newImageWidget()
    print("type=" .. iw:type())
    print("scale_mode=" .. tostring(iw:getScaleMode()))
    iw:setScaleMode("stretch")
    print("scale_mode_after=" .. iw:getScaleMode())
    iw:setTint(1.0, 0.78, 0.5, 1.0)
    local r, g, b, a = iw:getTint()
    print("tint=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageWidget:getTint
do
    local iw = lurek.ui.newImageWidget()
    print("type=" .. iw:type())
    print("scale_mode=" .. tostring(iw:getScaleMode()))
    iw:setScaleMode("stretch")
    print("scale_mode_after=" .. iw:getScaleMode())
    iw:setTint(1.0, 0.78, 0.5, 1.0)
    local r, g, b, a = iw:getTint()
    print("tint=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageWidget:setScaleMode
do
    local iw = lurek.ui.newImageWidget()
    print("type=" .. iw:type())
    print("scale_mode=" .. tostring(iw:getScaleMode()))
    iw:setScaleMode("stretch")
    print("scale_mode_after=" .. iw:getScaleMode())
    iw:setTint(1.0, 0.78, 0.5, 1.0)
    local r, g, b, a = iw:getTint()
    print("tint=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageWidget:setTint
do
    local iw = lurek.ui.newImageWidget()
    print("type=" .. iw:type())
    print("scale_mode=" .. tostring(iw:getScaleMode()))
    iw:setScaleMode("stretch")
    print("scale_mode_after=" .. iw:getScaleMode())
    iw:setTint(1.0, 0.78, 0.5, 1.0)
    local r, g, b, a = iw:getTint()
    print("tint=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LNinePatch:getImageDimensions
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

--@api: LNinePatch:getInsets
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

--@api: LNinePatch:getSlices
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

--@api: LNinePatch:setImageDimensions
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

--@api: LNinePatch:setInsets
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

--@api: LRadioButton:getGroup
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

--@api: LRadioButton:getText
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

--@api: LRadioButton:isSelected
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

--@api: LRadioButton:setGroup
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

--@api: LSpinBox:getValue
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

--@api: LSpinBox:setValue
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

--@api: LSplitPanel:getFirstChild
do
    local sp = lurek.ui.newSplitPanel("horizontal")
    local first = lurek.ui.newPanel()
    local second = lurek.ui.newPanel()
    print("type=" .. sp:type())
    print("orientation=" .. sp:getOrientation())
    sp:setFirstChild(first._idx)
    sp:setSecondChild(second._idx)
    local fc = sp:getFirstChild()
    local sc = sp:getSecondChild()
    print("fc=" .. tostring(fc))
    print("sc=" .. tostring(sc))
    sp:setSplitPosition(0.4)
    print("split_pos=" .. sp:getSplitPosition())
    sp:setMinPanelSize(80)
    print("min_panel=" .. sp:getMinPanelSize())
    sp:setOrientation("vertical")
    print("orientation_after=" .. sp:getOrientation())
end

--@api: LSplitPanel:getMinPanelSize
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

--@api: LSplitPanel:getOrientation
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

--@api: LSplitPanel:getSecondChild
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

--@api: LSplitPanel:getSplitPosition
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

--@api: LSplitPanel:setFirstChild
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

--@api: LSplitPanel:setMinPanelSize
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

--@api: LSplitPanel:setOrientation
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

--@api: LSplitPanel:setSecondChild
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

--@api: LSplitPanel:setSplitPosition
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

--@api: LSwitch:isOn
do
    local sw = lurek.ui.newSwitch(false)
    print("type=" .. sw:type())
    print("is_on=" .. tostring(sw:isOn()))
    sw:setOn(true)
    print("is_on_after=" .. tostring(sw:isOn()))
    sw:setOnChange(function(v) print("switch_changed=" .. tostring(v)) end)
end

--@api: LSwitch:setOnChange
do
    local sw = lurek.ui.newSwitch(false)
    print("type=" .. sw:type())
    print("is_on=" .. tostring(sw:isOn()))
    sw:setOn(true)
    print("is_on_after=" .. tostring(sw:isOn()))
    sw:setOnChange(function(v) print("switch_changed=" .. tostring(v)) end)
end

--@api: LGuiTable:addColumn
do
    local tbl = lurek.ui.newTable()
    print("type=" .. tbl:type())
    tbl:addColumn("Name")
    tbl:addColumn("Score")
    print("cols=" .. tbl:getColumnCount())
    tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" })
    print("rows=" .. tbl:getRowCount())
    print("cell11=" .. tostring(tbl:getCell(1, 1)))
    tbl:setCell(1, 2, "999")
    tbl:setSelectedRow(1)
    print("selected=" .. tostring(tbl:getSelectedRow()))
end

--@api: LGuiTable:addRow
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

--@api: LGuiTable:clearRows
do
    local tbl = lurek.ui.newTable()
    tbl:setRows({ { "Food", 420 }, { "Rent", 1200 } })
    tbl:setSelectedRow(1)
    tbl:clearRows()
    print("rows=" .. tbl:getRowCount())
end

--@api: LGuiTable:setRows
do
    local tbl = lurek.ui.newTable()
    local count = tbl:setRows({ { "Income", 3200 }, { "Savings", 640 } })
    print("setRows=" .. count .. ", first=" .. tostring(tbl:getCell(1, 1)))
end

--@api: LGuiTable:setDataFrame
do
    local df = lurek.dataframe.fromRows({ "category", "amount" }, { { "Food", 420 }, { "Rent", 1200 } })
    local tbl = lurek.ui.newTable()
    local count = tbl:setDataFrame(df, { columns = { "category", "amount" }, maxRows = 2 })
    print("setDataFrame=" .. count .. ", cols=" .. tbl:getColumnCount())
end

--@api: LGuiTable:getCell
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

--@api: LGuiTable:getColumnCount
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

--@api: LGuiTable:getRowCount
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

--@api: LGuiTable:getSelectedRow
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

--@api: LGuiTable:setCell
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

--@api: LGuiTable:setSelectedRow
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

--@api: lurek.ui.newTable
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

--@api: LToast:getDuration
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

--@api: LToast:getMessage
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

--@api: LToast:getProgress
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

--@api: LToast:isExpired
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

--@api: LToast:setDuration
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

--@api: LToast:setMessage
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

--@api: LTooltipPanel:getDelay
do
    local ttp = lurek.ui.newTooltipPanel("Hover info")
    print("type=" .. ttp:type())
    print("text=" .. ttp:getText())
    ttp:setText("Updated tooltip")
    print("text_after=" .. ttp:getText())
    ttp:setDelay(0.5)
    print("delay=" .. ttp:getDelay())
end

--@api: LTooltipPanel:getText
do
    local ttp = lurek.ui.newTooltipPanel("Hover info")
    print("type=" .. ttp:type())
    print("text=" .. ttp:getText())
    ttp:setText("Updated tooltip")
    print("text_after=" .. ttp:getText())
    ttp:setDelay(0.5)
    print("delay=" .. ttp:getDelay())
end

--@api: LTooltipPanel:setDelay
do
    local ttp = lurek.ui.newTooltipPanel("Hover info")
    print("type=" .. ttp:type())
    print("text=" .. ttp:getText())
    ttp:setText("Updated tooltip")
    print("text_after=" .. ttp:getText())
    ttp:setDelay(0.5)
    print("delay=" .. ttp:getDelay())
end

--@api: LTooltipPanel:setText
do
    local ttp = lurek.ui.newTooltipPanel("Hover info")
    print("type=" .. ttp:type())
    print("text=" .. ttp:getText())
    ttp:setText("Updated tooltip")
    print("text_after=" .. ttp:getText())
    ttp:setDelay(0.5)
    print("delay=" .. ttp:getDelay())
end

--@api: LTreeView:addNode
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child = tv:addNode("Child C", root)
    print("child added = " .. tostring(child ~= nil))
end

--@api: LTreeView:clearNodes
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    tv:clearNodes()
    print("nodes = " .. tv:getNodeCount())
end

--@api: LTreeView:collapseAll
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    tv:expandAll()
    tv:collapseAll()
    print("root expanded = " .. tostring(tv:isExpanded(root)))
end

--@api: LTreeView:collapseNode
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:expandNode(root)
    tv:collapseNode(root)
    print("root expanded = " .. tostring(tv:isNodeExpanded(root)))
end

--@api: LTreeView:expandAll
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    tv:expandAll()
    print("root expanded = " .. tostring(tv:isExpanded(root)))
end

--@api: LTreeView:expandNode
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:expandNode(root)
    print("root expanded = " .. tostring(tv:isNodeExpanded(root)))
end

--@api: LTreeView:getChildNodes
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    tv:addNode("Child B", root)
    local children = tv:getChildNodes(root)
    print("child count = " .. #children)
end

--@api: LTreeView:getNodeCount
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    print("nodes = " .. tv:getNodeCount())
end

--@api: LTreeView:getNodeDepth
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    print("depth = " .. tv:getNodeDepth(child1))
end

--@api: LTreeView:getNodeText
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    print("text = " .. tv:getNodeText(child1))
end

--@api: LTreeView:getParentNode
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    print("parent = " .. tostring(tv:getParentNode(child1) == root))
end

--@api: LTreeView:getSelectedNode
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    tv:setSelectedNode(child1)
    print("selected = " .. tostring(tv:getSelectedNode()))
end

--@api: LTreeView:isExpanded
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:expandAll()
    print("expanded = " .. tostring(tv:isExpanded(root)))
end

--@api: LTreeView:isNodeExpanded
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:expandNode(root)
    print("node expanded = " .. tostring(tv:isNodeExpanded(root)))
end

--@api: LTreeView:removeNode
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    local child2 = tv:addNode("Child B", root)
    tv:removeNode(child2)
    print("nodes = " .. tv:getNodeCount())
end

--@api: LTreeView:setNodeIcon
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    tv:setNodeIcon(child1, "folder")
    print("icon set on child")
end

--@api: LTreeView:setNodeText
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    tv:setNodeText(child1, "Renamed A")
    print("text = " .. tv:getNodeText(child1))
end

--@api: LTreeView:setSelectedNode
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    tv:setSelectedNode(child1)
    print("selected = " .. tostring(tv:getSelectedNode()))
end

--@api: LTreeView:toggleNode
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    local child2 = tv:addNode("Child B", root)
    tv:toggleNode(child2)
    print("child toggled")
end

--@api: LAccordion:getSectionTitle.2
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("Chapter 1")
    acc:addSection("Chapter 2")
    local cnt = acc:getSectionCount()
    local title = acc:getSectionTitle(1)
    print("sections:", cnt, "title:", title)
end

--@api: LAccordion:getSectionTitle.3
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("Chapter 1")
    acc:addSection("Chapter 2")
    local cnt = acc:getSectionCount()
    local title = acc:getSectionTitle(1)
    print("sections:", cnt, "title:", title)
end

--@api: LAccordion:getSectionTitle.4
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("Chapter 1")
    acc:addSection("Chapter 2")
    local cnt = acc:getSectionCount()
    local title = acc:getSectionTitle(1)
    print("sections:", cnt, "title:", title)
end

--@api: LAccordion:isSectionExpanded.2
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("A")
    acc:setExclusive(true)
    local ex = acc:isExclusive()
    local expanded = acc:isSectionExpanded(1)
    print("exclusive:", ex, "expanded:", expanded)
end

--@api: LAccordion:isSectionExpanded.3
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("A")
    acc:setExclusive(true)
    local ex = acc:isExclusive()
    local expanded = acc:isSectionExpanded(1)
    print("exclusive:", ex, "expanded:", expanded)
end

--@api: LAccordion:isSectionExpanded.4
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("A")
    acc:setExclusive(true)
    local ex = acc:isExclusive()
    local expanded = acc:isSectionExpanded(1)
    print("exclusive:", ex, "expanded:", expanded)
end

--@api: LAccordion:toggleSection.2
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("Toggle me")
    local newState = acc:toggleSection(1)
    local badge = lurek.ui.newBadge(5)
    local count = badge:getCount()
    local disp = badge:getDisplayText()
    print("toggled:", newState, "badge count:", count, "display:", disp)
end

--@api: LAccordion:toggleSection.3
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("Toggle me")
    local newState = acc:toggleSection(1)
    local badge = lurek.ui.newBadge(5)
    local count = badge:getCount()
    local disp = badge:getDisplayText()
    print("toggled:", newState, "badge count:", count, "display:", disp)
end

--@api: LAccordion:toggleSection.4
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("Toggle me")
    local newState = acc:toggleSection(1)
    local badge = lurek.ui.newBadge(5)
    local count = badge:getCount()
    local disp = badge:getDisplayText()
    print("toggled:", newState, "badge count:", count, "display:", disp)
end

--@api: LBadge:setCount.2
do
    local badge = lurek.ui.newBadge(0)
    badge:setCount(42)
    local btn = lurek.ui.newButton("Click me")
    local t = btn:getText()
    btn:setText("OK")
    print("badge count:", badge:getCount(), "button text:", btn:getText())
end

--@api: LButton:getText
do
    local badge = lurek.ui.newBadge(0)
    badge:setCount(42)
    local btn = lurek.ui.newButton("Click me")
    local t = btn:getText()
    btn:setText("OK")
    print("badge count:", badge:getCount(), "button text:", btn:getText())
end

--@api: LButton:setText
do
    local badge = lurek.ui.newBadge(0)
    badge:setCount(42)
    local btn = lurek.ui.newButton("Click me")
    local t = btn:getText()
    btn:setText("OK")
    print("badge count:", badge:getCount(), "button text:", btn:getText())
end

--@api: LCheckbox:getText
do
    local cb = lurek.ui.newCheckbox("Enable feature")
    local t = cb:getText()
    cb:setChecked(true)
    local checked = cb:isChecked()
    print("checkbox text:", t, "checked:", checked)
end

--@api: LCheckbox:isChecked
do
    local cb = lurek.ui.newCheckbox("Enable feature")
    local t = cb:getText()
    cb:setChecked(true)
    local checked = cb:isChecked()
    print("checkbox text:", t, "checked:", checked)
end

--@api: LCheckbox:isChecked.2
do
    local cb = lurek.ui.newCheckbox("Enable feature")
    local t = cb:getText()
    cb:setChecked(true)
    local checked = cb:isChecked()
    print("checkbox text:", t, "checked:", checked)
end

--@api: LCheckbox:setText.2
do
    local cb = lurek.ui.newCheckbox("old")
    cb:setText("new label")
    print("checkbox setText ok")
end

--@api: LColorPicker:getShowAlpha.2
do
    local cp = lurek.ui.newColorPicker()
    cp:setColor(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = cp:getColor()
    local mode = cp:getColorMode()
    local showAlpha = cp:getShowAlpha()
    print("color:", r, g, b, a, "mode:", mode, "showAlpha:", showAlpha)
end

--@api: LColorPicker:getShowAlpha.3
do
    local cp = lurek.ui.newColorPicker()
    cp:setColor(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = cp:getColor()
    local mode = cp:getColorMode()
    local showAlpha = cp:getShowAlpha()
    print("color:", r, g, b, a, "mode:", mode, "showAlpha:", showAlpha)
end

--@api: LColorPicker:getShowAlpha.4
do
    local cp = lurek.ui.newColorPicker()
    cp:setColor(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = cp:getColor()
    local mode = cp:getColorMode()
    local showAlpha = cp:getShowAlpha()
    print("color:", r, g, b, a, "mode:", mode, "showAlpha:", showAlpha)
end

--@api: LColorPicker:setColorMode.2
do
    local cp = lurek.ui.newColorPicker()
    cp:setColor(0.2, 0.8, 0.4, 1.0)
    cp:setColorMode("hsv")
    cp:setOnChange(function(idx) print("color changed", idx) end)
    cp:setShowAlpha(true)
    print("setColor/setColorMode/setOnChange ok")
end

--@api: LColorPicker:setColorMode.3
do
    local cp = lurek.ui.newColorPicker()
    cp:setColor(0.2, 0.8, 0.4, 1.0)
    cp:setColorMode("hsv")
    cp:setOnChange(function(idx) print("color changed", idx) end)
    cp:setShowAlpha(true)
    print("setColor/setColorMode/setOnChange ok")
end

--@api: LColorPicker:setColorMode.4
do
    local cp = lurek.ui.newColorPicker()
    cp:setColor(0.2, 0.8, 0.4, 1.0)
    cp:setColorMode("hsv")
    cp:setOnChange(function(idx) print("color changed", idx) end)
    cp:setShowAlpha(true)
    print("setColor/setColorMode/setOnChange ok")
end

--@api: LColorPicker:setShowAlpha.2
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

--@api: LColorPicker:setShowAlpha.3
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

--@api: LColorPicker:setShowAlpha.4
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

--@api: LComboBox:getSelectedIndex.2
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

--@api: LComboBox:getSelectedIndex.3
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

--@api: LComboBox:getSelectedIndex.4
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

--@api: LComboBox:removeItem.2
do
    local cb = lurek.ui.newComboBox()
    cb:addItem("Alpha")
    cb:addItem("Beta")
    cb:setSelectedIndex(2)
    local selItem = cb:getSelectedItem()
    cb:removeItem(1)
    print("getSelectedItem:", selItem, "removeItem ok")
end

--@api: LComboBox:removeItem
do
    local cb = lurek.ui.newComboBox()
    cb:addItem("Alpha")
    cb:addItem("Beta")
    cb:setSelectedIndex(2)
    local selItem = cb:getSelectedItem()
    cb:removeItem(1)
    print("getSelectedItem:", selItem, "removeItem ok")
end

--@api: LComboBox:setSelectedIndex
do
    local cb = lurek.ui.newComboBox()
    cb:addItem("Alpha")
    cb:addItem("Beta")
    cb:setSelectedIndex(2)
    local selItem = cb:getSelectedItem()
    cb:removeItem(1)
    print("getSelectedItem:", selItem, "removeItem ok")
end

--@api: LDialog:addButton
do
    local dlg = lurek.ui.newDialog("Info")
    local btnIdx = dlg:addButton("OK")
    local content = dlg:getContent()
    dlg:open()
    dlg:close()
    print("addButton:", btnIdx, "close ok")
end

--@api: LDialog:close
do
    local dlg = lurek.ui.newDialog("Info")
    local btnIdx = dlg:addButton("OK")
    local content = dlg:getContent()
    dlg:open()
    dlg:close()
    print("addButton:", btnIdx, "close ok")
end

--@api: LDialog:getContent
do
    local dlg = lurek.ui.newDialog("Info")
    local btnIdx = dlg:addButton("OK")
    local content = dlg:getContent()
    dlg:open()
    dlg:close()
    print("addButton:", btnIdx, "close ok")
end

--@api: LDialog:getTitle
do
    local dlg = lurek.ui.newDialog("My Dialog")
    local title = dlg:getTitle()
    dlg:setModal(true)
    local modal = dlg:isModal()
    local open = dlg:isOpen()
    print("title:", title, "isModal:", modal, "isOpen:", open)
end

--@api: LDialog:isModal
do
    local dlg = lurek.ui.newDialog("My Dialog")
    local title = dlg:getTitle()
    dlg:setModal(true)
    local modal = dlg:isModal()
    local open = dlg:isOpen()
    print("title:", title, "isModal:", modal, "isOpen:", open)
end

--@api: LDialog:isOpen
do
    local dlg = lurek.ui.newDialog("My Dialog")
    local title = dlg:getTitle()
    dlg:setModal(true)
    local modal = dlg:isModal()
    local open = dlg:isOpen()
    print("title:", title, "isModal:", modal, "isOpen:", open)
end

--@api: LDialog:open
do
    local dlg = lurek.ui.newDialog("Setup")
    dlg:setModal(false)
    dlg:setContent(nil)
    dlg:open()
    dlg:close()
    print("open/setContent/setModal ok")
end

--@api: LDialog:setContent
do
    local dlg = lurek.ui.newDialog("Setup")
    dlg:setModal(false)
    dlg:setContent(nil)
    dlg:open()
    dlg:close()
    print("open/setContent/setModal ok")
end

--@api: LDialog:setModal
do
    local dlg = lurek.ui.newDialog("Setup")
    dlg:setModal(false)
    dlg:setContent(nil)
    dlg:open()
    dlg:close()
    print("open/setContent/setModal ok")
end

--@api: LDialog:setOnClose
do
    local dlg = lurek.ui.newDialog("Old")
    dlg:setTitle("New Title")
    dlg:setOnClose(function(idx) print("closed", idx) end)
    local dp = lurek.ui.newDockPanel()
    local btn = lurek.ui.newButton("Side")
    print("setTitle/setOnClose ok; DockPanel created")
end

--@api: LDialog:setTitle
do
    local dlg = lurek.ui.newDialog("Old")
    dlg:setTitle("New Title")
    dlg:setOnClose(function(idx) print("closed", idx) end)
    local dp = lurek.ui.newDockPanel()
    local btn = lurek.ui.newButton("Side")
    print("setTitle/setOnClose ok; DockPanel created")
end

--@api: LDialog:setTitle.2
do
    local dlg = lurek.ui.newDialog("Old")
    dlg:setTitle("New Title")
    dlg:setOnClose(function(idx) print("closed", idx) end)
    local dp = lurek.ui.newDockPanel()
    local btn = lurek.ui.newButton("Side")
    print("setTitle/setOnClose ok; DockPanel created")
end

--@api: LDialog:addAction
do
    local dlg = lurek.ui.newDialog("Actions")
    local idx = dlg:addAction("Apply", nil, "default", true)
    dlg:setDefaultAction(idx)
    print("addAction/default:", idx, dlg:getDefaultAction())
end

--@api: LDialog:centerInViewport
do
    local dlg = lurek.ui.newDialog("Center")
    dlg:setCenterOnOpen(false)
    dlg:centerInViewport()
    print("centerInViewport ok")
end

--@api: LDialog:getCancelAction
do
    local dlg = lurek.ui.newDialog("Cancel")
    local idx = dlg:addAction("Cancel", nil, "cancel", true)
    dlg:setCancelAction(idx)
    print("cancel action:", dlg:getCancelAction())
end

--@api: LDialog:getDefaultAction
do
    local dlg = lurek.ui.newDialog("Default")
    local idx = dlg:addAction("Confirm", nil, "default", true)
    dlg:setDefaultAction(idx)
    print("default action:", dlg:getDefaultAction())
end

--@api: LDialog:setDefaultAction
do
    local dlg = lurek.ui.newDialog("Default Setter")
    local idx = dlg:addAction("Confirm", nil, "default", true)
    dlg:setDefaultAction(idx)
    print("set default action:", idx)
end

--@api: LDialog:getCenterOnOpen
do
    local dlg = lurek.ui.newDialog("Center Flag")
    dlg:setCenterOnOpen(false)
    print("centerOnOpen:", dlg:getCenterOnOpen())
end

--@api: LDialog:getDismissOnOutsideClick
do
    local dlg = lurek.ui.newDialog("Dismiss Flag")
    dlg:setDismissOnOutsideClick(true)
    print("dismissOnOutsideClick:", dlg:getDismissOnOutsideClick())
end

--@api: LDialog:getFooter
do
    local dlg = lurek.ui.newDialog("Footer")
    local footer = lurek.ui.newPanel()
    dlg:setFooter(footer._idx)
    print("footer idx:", dlg:getFooter())
end

--@api: LDialog:getMaxSize
do
    local dlg = lurek.ui.newDialog("Max")
    dlg:setMaxSize(420, 260)
    local w, h = dlg:getMaxSize()
    print("max size:", w, h)
end

--@api: LDialog:getMinSize
do
    local dlg = lurek.ui.newDialog("Min")
    dlg:setMinSize(220, 140)
    local w, h = dlg:getMinSize()
    print("min size:", w, h)
end

--@api: LDialog:isCloseable
do
    local dlg = lurek.ui.newDialog("Closeable")
    print("isCloseable:", dlg:isCloseable())
end

--@api: LDialog:isDraggable
do
    local dlg = lurek.ui.newDialog("Draggable")
    print("isDraggable:", dlg:isDraggable())
end

--@api: LDialog:isResizable
do
    local dlg = lurek.ui.newDialog("Resizable")
    print("isResizable:", dlg:isResizable())
end

--@api: LDialog:setCloseable
do
    local dlg = lurek.ui.newDialog("Closeable Setter")
    dlg:setCloseable(false)
    print("setCloseable:", false)
end

--@api: LDialog:setDraggable
do
    local dlg = lurek.ui.newDialog("Draggable Setter")
    dlg:setDraggable(true)
    print("setDraggable:", true)
end

--@api: LDialog:setResizable
do
    local dlg = lurek.ui.newDialog("Resizable Setter")
    dlg:setResizable(true)
    print("setResizable:", true)
end

--@api: LDialog:setFooter
do
    local dlg = lurek.ui.newDialog("Footer Setter")
    local footer = lurek.ui.newLayout("horizontal")
    dlg:setFooter(footer._idx)
    print("setFooter:", dlg:getFooter())
end

--@api: LDialog:setMaxSize
do
    local dlg = lurek.ui.newDialog("Max Size")
    dlg:setMaxSize(480, 320)
    print("setMaxSize:", 480, 320)
end

--@api: LDialog:setMinSize
do
    local dlg = lurek.ui.newDialog("Min Size")
    dlg:setMinSize(200, 120)
    print("setMinSize:", 200, 120)
end

--@api: LDialog:setDismissOnOutsideClick
do
    local dlg = lurek.ui.newDialog("Dismiss")
    dlg:setModal(false)
    dlg:setDismissOnOutsideClick(true)
    print("dismiss setter ok")
end

--@api: LDialog:setCenterOnOpen
do
    local dlg = lurek.ui.newDialog("Center Setter")
    dlg:setCenterOnOpen(false)
    print("setCenterOnOpen ok")
end

--@api: LDialog:setCancelAction
do
    local dlg = lurek.ui.newDialog("Cancel Setter")
    local idx = dlg:addAction("Abort", nil, "cancel", true)
    dlg:setCancelAction(idx)
    print("setCancelAction:", dlg:getCancelAction())
end

--@api: LDockPanel:getSplitSize.2
do
    local dp = lurek.ui.newDockPanel()
    local cnt = dp:getDockedCount()
    dp:setSplitSize("left", 200)
    local sz = dp:getSplitSize("left")
    print("getDockedCount:", cnt, "splitSize:", sz)
end

--@api: LDockPanel:getSplitSize.3
do
    local dp = lurek.ui.newDockPanel()
    local cnt = dp:getDockedCount()
    dp:setSplitSize("left", 200)
    local sz = dp:getSplitSize("left")
    print("getDockedCount:", cnt, "splitSize:", sz)
end

--@api: LDockPanel:getSplitSize.4
do
    local dp = lurek.ui.newDockPanel()
    local cnt = dp:getDockedCount()
    dp:setSplitSize("left", 200)
    local sz = dp:getSplitSize("left")
    print("getDockedCount:", cnt, "splitSize:", sz)
end

--@api: LDockPanel:undock.2
do
    local dp = lurek.ui.newDockPanel()
    local dockedCount = dp:getDockedCount()
    dp:undock(0)
    local tbl = lurek.ui.newTable()
    print("undock ok (dockedCount was:", dockedCount, "); newTable ok")
end

--@api: LDockPanel:undock.3
do
    local dp = lurek.ui.newDockPanel()
    local dockedCount = dp:getDockedCount()
    dp:undock(0)
    local tbl = lurek.ui.newTable()
    print("undock ok (dockedCount was:", dockedCount, "); newTable ok")
end

--@api: LDockPanel:undock.4
do
    local dp = lurek.ui.newDockPanel()
    local dockedCount = dp:getDockedCount()
    dp:undock(0)
    local tbl = lurek.ui.newTable()
    print("undock ok (dockedCount was:", dockedCount, "); newTable ok")
end

--@api: LTable:addColumn
do
    local tbl = lurek.ui.newTable()
    tbl:addColumn("Name", 100)
    tbl:addColumn("Value", 80)
    tbl:addRow({"Alice", "42"})
    tbl:addRow({"Bob", "99"})
    local cell = tbl:getCell(1, 1)
    print("addColumn/addRow/getCell ok, cell:", cell)
end

--@api: LTable:getSelectedRow
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

--@api: LTable:getSelectedRow.2
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

--@api: LTable:getSelectedRow.3
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

--@api: LGuiTable:isSortable
do
    local tbl = lurek.ui.newTable()
    tbl:addColumn("ID")
    tbl:addRow({"1"})
    tbl:setSortable(true)
    tbl:setCell(1, 1, "changed")
    tbl:setOnSelect(function(idx) print("row selected", idx) end)
    print("isSortable/setCell/setOnSelect ok")
end

--@api: LTable:setCell
do
    local tbl = lurek.ui.newTable()
    tbl:addColumn("ID")
    tbl:addRow({"1"})
    tbl:setSortable(true)
    tbl:setCell(1, 1, "changed")
    tbl:setOnSelect(function(idx) print("row selected", idx) end)
    print("isSortable/setCell/setOnSelect ok")
end

--@api: LGuiTable:setOnSelect
do
    local tbl = lurek.ui.newTable()
    tbl:addColumn("ID")
    tbl:addRow({"1"})
    tbl:setSortable(true)
    tbl:setCell(1, 1, "changed")
    tbl:setOnSelect(function(idx) print("row selected", idx) end)
    print("isSortable/setCell/setOnSelect ok")
end

--@api: LTable:setSortable
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

--@api: LGuiTable:setSortable
do
    local tbl = lurek.ui.newTable()
    tbl:setPosition(20, 420)
    tbl:setSize(220, 90)
    tbl:setZOrder(2100)
    tbl:addColumn("Name", 120)
    tbl:addColumn("Value", 80)
    tbl:addRow({"B", "20"})
    tbl:addRow({"A", "10"})
    tbl:setSortable(true)
    lurek.ui.mousepressed(25, 430, 1)
    lurek.ui.mousereleased(25, 430, 1)
    lurek.ui.update(0)
    print("sorted first row:", tbl:getCell(1, 1))
end

--@api: LGuiWindow:getTitle
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

--@api: LGuiWindow:isCloseable
do
    local win = lurek.ui.newWindow("Test Win")
    local closeable = win:isCloseable()
    local draggable = win:isDraggable()
    local resizable = win:isResizable()
    print("isCloseable:", closeable, "isDraggable:", draggable, "isResizable:", resizable)
end

--@api: LGuiWindow:isDraggable
do
    local win = lurek.ui.newWindow("Test Win")
    local closeable = win:isCloseable()
    local draggable = win:isDraggable()
    local resizable = win:isResizable()
    print("isCloseable:", closeable, "isDraggable:", draggable, "isResizable:", resizable)
end

--@api: LGuiWindow:isResizable
do
    local win = lurek.ui.newWindow("Test Win")
    local closeable = win:isCloseable()
    local draggable = win:isDraggable()
    local resizable = win:isResizable()
    print("isCloseable:", closeable, "isDraggable:", draggable, "isResizable:", resizable)
end

--@api: LGuiWindow:setCloseable
do
    local win = lurek.ui.newWindow("Config")
    win:setCloseable(true)
    win:setDraggable(true)
    win:setOnClose(function(idx) print("window closed", idx) end)
    print("setCloseable/setDraggable/setOnClose ok")
end

--@api: LGuiWindow:setDraggable
do
    local win = lurek.ui.newWindow("Config")
    win:setCloseable(true)
    win:setDraggable(true)
    win:setOnClose(function(idx) print("window closed", idx) end)
    print("setCloseable/setDraggable/setOnClose ok")
end

--@api: LGuiWindow:setOnClose
do
    local win = lurek.ui.newWindow("Config")
    win:setCloseable(true)
    win:setDraggable(true)
    win:setOnClose(function(idx) print("window closed", idx) end)
    print("setCloseable/setDraggable/setOnClose ok")
end

--@api: LGuiWindow:setResizable
do
    local win = lurek.ui.newWindow("Old")
    win:setResizable(false)
    win:setTitle("New Title")
    local iw = lurek.ui.newImageWidget()
    local mode = iw:getScaleMode()
    print("setResizable/setTitle ok; scaleMode:", mode)
end

--@api: LGuiWindow:setTitle
do
    local win = lurek.ui.newWindow("Old")
    win:setResizable(false)
    win:setTitle("New Title")
    local iw = lurek.ui.newImageWidget()
    local mode = iw:getScaleMode()
    print("setResizable/setTitle ok; scaleMode:", mode)
end

--@api: LWindow:setResizable
do
    local win = lurek.ui.newWindow("Old")
    win:setResizable(false)
    win:setTitle("New Title")
    local iw = lurek.ui.newImageWidget()
    local mode = iw:getScaleMode()
    print("setResizable/setTitle ok; scaleMode:", mode)
end

--@api: LImageWidget:scaleMode
do
    local iw = lurek.ui.newImageWidget()
    iw:setTint(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = iw:getTint()
    iw:setScaleMode("fit")
    print("tint:", r, g, b, a, "scaleMode: fit")
end

--@api: LImageWidget:setScaleMode.2
do
    local iw = lurek.ui.newImageWidget()
    iw:setTint(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = iw:getTint()
    iw:setScaleMode("fit")
    print("tint:", r, g, b, a, "scaleMode: fit")
end

--@api: LImageWidget:setScaleMode.3
do
    local iw = lurek.ui.newImageWidget()
    iw:setTint(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = iw:getTint()
    iw:setScaleMode("fit")
    print("tint:", r, g, b, a, "scaleMode: fit")
end

--@api: LLabel:getText
do
    local lbl = lurek.ui.newLabel("Hello")
    lbl:setText("World")
    local layout = lurek.ui.newLayout("horizontal")
    local align = layout:getAlign()
    print("label text:", lbl:getText(), "layout align:", align)
end

--@api: LLabel:setText
do
    local lbl = lurek.ui.newLabel("Hello")
    lbl:setText("World")
    local layout = lurek.ui.newLayout("horizontal")
    local align = layout:getAlign()
    print("label text:", lbl:getText(), "layout align:", align)
end

--@api: LLabel:setText.2
do
    local lbl = lurek.ui.newLabel("Hello")
    lbl:setText("World")
    local layout = lurek.ui.newLayout("horizontal")
    local align = layout:getAlign()
    print("label text:", lbl:getText(), "layout align:", align)
end

--@api: LLayout:getDirection
do
    local layout = lurek.ui.newLayout("vertical")
    local dir = layout:getDirection()
    local justify = layout:getJustify()
    local spacing = layout:getSpacing()
    print("direction:", dir, "justify:", justify, "spacing:", spacing)
end

--@api: LLayout:getSpacing.2
do
    local layout = lurek.ui.newLayout("vertical")
    local dir = layout:getDirection()
    local justify = layout:getJustify()
    local spacing = layout:getSpacing()
    print("direction:", dir, "justify:", justify, "spacing:", spacing)
end

--@api: LLayout:getSpacing
do
    local layout = lurek.ui.newLayout("vertical")
    local dir = layout:getDirection()
    local justify = layout:getJustify()
    local spacing = layout:getSpacing()
    print("direction:", dir, "justify:", justify, "spacing:", spacing)
end

--@api: LLayout:setColumns.2
do
    local layout = lurek.ui.newLayout("grid")
    local wrap = layout:getWrap()
    layout:setAlign("center")
    layout:setColumns(3)
    print("getWrap:", wrap, "setAlign: center, setColumns: 3 ok")
end

--@api: LLayout:setColumns.3
do
    local layout = lurek.ui.newLayout("grid")
    local wrap = layout:getWrap()
    layout:setAlign("center")
    layout:setColumns(3)
    print("getWrap:", wrap, "setAlign: center, setColumns: 3 ok")
end

--@api: LLayout:setColumns.4
do
    local layout = lurek.ui.newLayout("grid")
    local wrap = layout:getWrap()
    layout:setAlign("center")
    layout:setColumns(3)
    print("getWrap:", wrap, "setAlign: center, setColumns: 3 ok")
end

--@api: LLayout:setSpacing.2
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setDirection("vertical")
    layout:setJustify("center")
    layout:setSpacing(8)
    print("setDirection/setJustify/setSpacing ok")
end

--@api: LLayout:setSpacing.3
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setDirection("vertical")
    layout:setJustify("center")
    layout:setSpacing(8)
    print("setDirection/setJustify/setSpacing ok")
end

--@api: LLayout:setSpacing
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setDirection("vertical")
    layout:setJustify("center")
    layout:setSpacing(8)
    print("setDirection/setJustify/setSpacing ok")
end

--@api: LLayout:setWrap.2
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setWrap(true)
    print("setWrap ok")
end

--@api: LLayout:setWrap.3
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setWrap(true)
    print("setWrap ok")
end

--@api: LList:clearItems
do
    local lb = lurek.ui.newList()
    lb:addItem("Apple")
    lb:addItem("Banana")
    lb:addItem("Cherry")
    local item = lb:getItem(2)
    lb:clearItems()
    print("addItem/clearItems/getItem ok, item:", item)
end

--@api: LList:clearItems.2
do
    local lb = lurek.ui.newList()
    lb:addItem("Apple")
    lb:addItem("Banana")
    lb:addItem("Cherry")
    local item = lb:getItem(2)
    lb:clearItems()
    print("addItem/clearItems/getItem ok, item:", item)
end

--@api: LList:removeItem
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

--@api: LList:removeItem.2
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

--@api: LList:removeItem.3
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

--@api: LList:setItemHeight
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

--@api: LList:setSelectedIndex
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

--@api: LList:setSelectedIndex.2
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

--@api: LMenuBar:removeMenu.2
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

--@api: LMenuBar:removeMenu.3
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

--@api: LMenuBar:removeMenu.4
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

--@api: LMenuItem:getShortcut.2
do
    local mi = lurek.ui.newMenuItem("Tools")
    local sub1 = lurek.ui.newMenuItem("Options")
    mi:addSubItem(sub1._idx)
    local subs = mi:getSubItems()
    mi:setShortcut("Ctrl+T")
    local sc = mi:getShortcut()
    print("addSubItem ok; getSubItems:", type(subs), "shortcut:", sc)
end

--@api: LMenuItem:getShortcut
do
    local mi = lurek.ui.newMenuItem("Tools")
    local sub1 = lurek.ui.newMenuItem("Options")
    mi:addSubItem(sub1._idx)
    local subs = mi:getSubItems()
    mi:setShortcut("Ctrl+T")
    local sc = mi:getShortcut()
    print("addSubItem ok; getSubItems:", type(subs), "shortcut:", sc)
end

--@api: LMenuItem:getShortcut.3
do
    local mi = lurek.ui.newMenuItem("Tools")
    local sub1 = lurek.ui.newMenuItem("Options")
    mi:addSubItem(sub1._idx)
    local subs = mi:getSubItems()
    mi:setShortcut("Ctrl+T")
    local sc = mi:getShortcut()
    print("addSubItem ok; getSubItems:", type(subs), "shortcut:", sc)
end

--@api: LMenuItem:getText
do
    local mi = lurek.ui.newMenuItem("Enable")
    local t = mi:getText()
    mi:setChecked(true)
    local checked = mi:isChecked()
    mi:setChecked(false)
    print("getText:", t, "isChecked:", mi:isChecked(), "setChecked ok")
end

--@api: LMenuItem:setChecked.2
do
    local mi = lurek.ui.newMenuItem("Enable")
    local t = mi:getText()
    mi:setChecked(true)
    local checked = mi:isChecked()
    mi:setChecked(false)
    print("getText:", t, "isChecked:", mi:isChecked(), "setChecked ok")
end

--@api: LMenuItem:setChecked.3
do
    local mi = lurek.ui.newMenuItem("Enable")
    local t = mi:getText()
    mi:setChecked(true)
    local checked = mi:isChecked()
    mi:setChecked(false)
    print("getText:", t, "isChecked:", mi:isChecked(), "setChecked ok")
end

--@api: LMenuItem:setOnClick.2
do
    local mi = lurek.ui.newMenuItem("Old")
    mi:setOnClick(function(idx) print("menu clicked", idx) end)
    mi:setShortcut("Alt+F4")
    mi:setText("New Name")
    print("setOnClick/setShortcut/setText ok")
end

--@api: LMenuItem:setShortcut
do
    local mi = lurek.ui.newMenuItem("Old")
    mi:setOnClick(function(idx) print("menu clicked", idx) end)
    mi:setShortcut("Alt+F4")
    mi:setText("New Name")
    print("setOnClick/setShortcut/setText ok")
end

--@api: LMenuItem:setOnClick.3
do
    local mi = lurek.ui.newMenuItem("Old")
    mi:setOnClick(function(idx) print("menu clicked", idx) end)
    mi:setShortcut("Alt+F4")
    mi:setText("New Name")
    print("setOnClick/setShortcut/setText ok")
end

--@api: LNinePatch:getSlices.2
do
    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    local slices = np:getSlices()
    print("imgDims:", w, h, "insets:", l, t, r, b, "slices:", type(slices))
end

--@api: LNinePatch:getSlices.3
do
    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    local slices = np:getSlices()
    print("imgDims:", w, h, "insets:", l, t, r, b, "slices:", type(slices))
end

--@api: LNinePatch:getSlices.4
do
    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    local slices = np:getSlices()
    print("imgDims:", w, h, "insets:", l, t, r, b, "slices:", type(slices))
end

--@api: LNinePatch:getInsets.2
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

--@api: LNinePatch:getInsets.3
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

--@api: LPanel:getTitle
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

--@api: LPanel:setScrollable
do
    local panel = lurek.ui.newPanel()
    panel:setScrollable(true)
    panel:setTitle("Data")
    print("panel scrollable ok")
end

--@api: LPanel:setTitle
do
    local panel = lurek.ui.newPanel()
    panel:setScrollable(true)
    panel:setTitle("Data")
    print("panel scrollable ok")
end

--@api: LProgressBar:getProgress.2
do
    local pb = lurek.ui.newProgressBar(0, 100)
    local mn = pb:getMin()
    local mx = pb:getMax()
    pb:setValue(75)
    local prog = pb:getProgress()
    print("min:", mn, "max:", mx, "progress:", prog)
end

--@api: LProgressBar:getProgress.3
do
    local pb = lurek.ui.newProgressBar(0, 100)
    local mn = pb:getMin()
    local mx = pb:getMax()
    pb:setValue(75)
    local prog = pb:getProgress()
    print("min:", mn, "max:", mx, "progress:", prog)
end

--@api: LProgressBar:getProgress.4
do
    local pb = lurek.ui.newProgressBar(0, 100)
    local mn = pb:getMin()
    local mx = pb:getMax()
    pb:setValue(75)
    local prog = pb:getProgress()
    print("min:", mn, "max:", mx, "progress:", prog)
end

--@api: LProgressBar:setRange.2
do
    local pb = lurek.ui.newProgressBar(0, 200)
    pb:setValue(100)
    local v = pb:getValue()
    pb:setRange(10, 90)
    pb:setValue(50)
    print("getValue:", v, "setRange ok, setValue ok")
end

--@api: LProgressBar:setRange.3
do
    local pb = lurek.ui.newProgressBar(0, 200)
    pb:setValue(100)
    local v = pb:getValue()
    pb:setRange(10, 90)
    pb:setValue(50)
    print("getValue:", v, "setRange ok, setValue ok")
end

--@api: LProgressBar:setRange.4
do
    local pb = lurek.ui.newProgressBar(0, 200)
    pb:setValue(100)
    local v = pb:getValue()
    pb:setRange(10, 90)
    pb:setValue(50)
    print("getValue:", v, "setRange ok, setValue ok")
end

--@api: LRadioButton:isSelected.2
do
    local rb = lurek.ui.newRadioButton("Option A", "group1")
    local grp = rb:getGroup()
    local t = rb:getText()
    local sel = rb:isSelected()
    print("group:", grp, "text:", t, "isSelected:", sel)
end

--@api: LRadioButton:isSelected.3
do
    local rb = lurek.ui.newRadioButton("Option A", "group1")
    local grp = rb:getGroup()
    local t = rb:getText()
    local sel = rb:isSelected()
    print("group:", grp, "text:", t, "isSelected:", sel)
end

--@api: LRadioButton:isSelected.4
do
    local rb = lurek.ui.newRadioButton("Option A", "group1")
    local grp = rb:getGroup()
    local t = rb:getText()
    local sel = rb:isSelected()
    print("group:", grp, "text:", t, "isSelected:", sel)
end

--@api: LRadioButton:setSelected.2
do
    local rb = lurek.ui.newRadioButton("B", "g1")
    rb:setGroup("g2")
    rb:setSelected(true)
    rb:setOnChange(function(idx) print("radio changed", idx) end)
    rb:setText("New B")
    print("setGroup/setSelected/setOnChange/setText ok")
end

--@api: LRadioButton:setOnChange
do
    local rb = lurek.ui.newRadioButton("B", "g1")
    rb:setGroup("g2")
    rb:setSelected(true)
    rb:setOnChange(function(idx) print("radio changed", idx) end)
    rb:setText("New B")
    print("setGroup/setSelected/setOnChange/setText ok")
end

--@api: LRadioButton:setSelected
do
    local rb = lurek.ui.newRadioButton("B", "g1")
    rb:setGroup("g2")
    rb:setSelected(true)
    rb:setOnChange(function(idx) print("radio changed", idx) end)
    rb:setText("New B")
    print("setGroup/setSelected/setOnChange/setText ok")
end

--@api: LRadioButton:setText
do
    local rb = lurek.ui.newRadioButton("original", "group_test")
    rb:setText("updated")
    print("LRadioButton setText:", rb:getText())
end

--@api: LScrollBar:getContentSize
do
    local sb = lurek.ui.newScrollBar(true)
    local cs = sb:getContentSize()
    local pos = sb:getScrollPosition()
    local vs = sb:getViewSize()
    print("contentSize:", cs, "scrollPos:", pos, "viewSize:", vs)
end

--@api: LScrollBar:getScrollPosition
do
    local sb = lurek.ui.newScrollBar(true)
    local cs = sb:getContentSize()
    local pos = sb:getScrollPosition()
    local vs = sb:getViewSize()
    print("contentSize:", cs, "scrollPos:", pos, "viewSize:", vs)
end

--@api: LScrollBar:getViewSize
do
    local sb = lurek.ui.newScrollBar(true)
    local cs = sb:getContentSize()
    local pos = sb:getScrollPosition()
    local vs = sb:getViewSize()
    print("contentSize:", cs, "scrollPos:", pos, "viewSize:", vs)
end

--@api: LScrollBar:isVertical
do
    local sb = lurek.ui.newScrollBar(false)
    local vert = sb:isVertical()
    sb:setContentSize(500)
    sb:setOnChange(function(val) print("scroll:", val) end)
    local cs = sb:getContentSize()
    print("isVertical:", vert, "contentSize after set:", cs)
end

--@api: LScrollBar:setContentSize
do
    local sb = lurek.ui.newScrollBar(false)
    local vert = sb:isVertical()
    sb:setContentSize(500)
    sb:setOnChange(function(val) print("scroll:", val) end)
    local cs = sb:getContentSize()
    print("isVertical:", vert, "contentSize after set:", cs)
end

--@api: LScrollBar:setOnChange
do
    local sb = lurek.ui.newScrollBar(false)
    local vert = sb:isVertical()
    sb:setContentSize(500)
    sb:setOnChange(function(val) print("scroll:", val) end)
    local cs = sb:getContentSize()
    print("isVertical:", vert, "contentSize after set:", cs)
end

--@api: LScrollBar:setScrollPosition
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

--@api: LScrollBar:setViewSize
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

--@api: LScrollPanel:getContentSize
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

--@api: LScrollPanel:getMaxScroll
do
    local sp = lurek.ui.newScrollPanel()
    local mx, my = sp:getMaxScroll()
    local px, py = sp:getScrollPosition()
    local speed = sp:getScrollSpeed()
    print("maxScroll:", mx, my, "scrollPos:", px, py, "speed:", speed)
end

--@api: LScrollPanel:getScrollPosition
do
    local sp = lurek.ui.newScrollPanel()
    local mx, my = sp:getMaxScroll()
    local px, py = sp:getScrollPosition()
    local speed = sp:getScrollSpeed()
    print("maxScroll:", mx, my, "scrollPos:", px, py, "speed:", speed)
end

--@api: LScrollPanel:getScrollSpeed.2
do
    local sp = lurek.ui.newScrollPanel()
    local mx, my = sp:getMaxScroll()
    local px, py = sp:getScrollPosition()
    local speed = sp:getScrollSpeed()
    print("maxScroll:", mx, my, "scrollPos:", px, py, "speed:", speed)
end

--@api: LScrollPanel:setContentSize
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

--@api: LScrollPanel:setScrollPosition
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

--@api: LScrollPanel:getScrollSpeed.3
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

--@api: LSeparator:getThickness
do
    local sep = lurek.ui.newSeparator(true)
    local vert = sep:isVertical()
    local thick = sep:getThickness()
    sep:setThickness(4)
    local t2 = sep:getThickness()
    print("isVertical:", vert, "thickness:", thick, "â†’", t2)
end

--@api: LSeparator:isVertical
do
    local sep = lurek.ui.newSeparator(true)
    local vert = sep:isVertical()
    local thick = sep:getThickness()
    sep:setThickness(4)
    local t2 = sep:getThickness()
    print("isVertical:", vert, "thickness:", thick, "â†’", t2)
end

--@api: LSeparator:setThickness
do
    local sep = lurek.ui.newSeparator(true)
    local vert = sep:isVertical()
    local thick = sep:getThickness()
    sep:setThickness(4)
    local t2 = sep:getThickness()
    print("isVertical:", vert, "thickness:", thick, "â†’", t2)
end

--@api: LSeparator:setVertical
do
    local sep = lurek.ui.newSeparator(false)
    sep:setVertical(true)
    local sl = lurek.ui.newSlider(0, 100)
    local mn = sl:getMin()
    local mx = sl:getMax()
    print("separator setVertical ok; slider min:", mn, "max:", mx)
end

--@api: LSlider:getMax
do
    local sep = lurek.ui.newSeparator(false)
    sep:setVertical(true)
    local sl = lurek.ui.newSlider(0, 100)
    local mn = sl:getMin()
    local mx = sl:getMax()
    print("separator setVertical ok; slider min:", mn, "max:", mx)
end

--@api: LSlider:getMin
do
    local sep = lurek.ui.newSeparator(false)
    sep:setVertical(true)
    local sl = lurek.ui.newSlider(0, 100)
    local mn = sl:getMin()
    local mx = sl:getMax()
    print("separator setVertical ok; slider min:", mn, "max:", mx)
end

--@api: LSlider:getValue
do
    local sl = lurek.ui.newSlider(0, 50)
    sl:setRange(0, 100)
    local mx = sl:getMax()
    sl:setStep(5)
    sl:setValue(75)
    local v = sl:getValue()
    print("setRange max:", mx, "getValue:", v)
end

--@api: LSlider:getValue.2
do
    local sl = lurek.ui.newSlider(0, 50)
    sl:setRange(0, 100)
    local mx = sl:getMax()
    sl:setStep(5)
    sl:setValue(75)
    local v = sl:getValue()
    print("setRange max:", mx, "getValue:", v)
end

--@api: LSlider:getValue.3
do
    local sl = lurek.ui.newSlider(0, 50)
    sl:setRange(0, 100)
    local mx = sl:getMax()
    sl:setStep(5)
    sl:setValue(75)
    local v = sl:getValue()
    print("setRange max:", mx, "getValue:", v)
end

--@api: LSlider:getValue.5
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

--@api: LSlider:getValue.6
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

--@api: LSlider:getValue.4
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

--@api: LSpinBox:getValue.2
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

--@api: LSpinBox:getValue.3
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

--@api: LSpinBox:getValue.4
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

--@api: LSpinBox:getValue.5
do
    local sb = lurek.ui.newSpinBox(1, 100)
    sb:setValue(42)
    local v = sb:getValue()
    sb:setValue(1)
    local v2 = sb:getValue()
    sb:setValue(100)
    local v3 = sb:getValue()
    print("setValue: 42â†’", v, "1â†’", v2, "100â†’", v3)
end

--@api: LSplitPanel:getMinPanelSize.2
do
    local sp = lurek.ui.newSplitPanel("horizontal")
    local fc = sp:getFirstChild()
    local sc = sp:getSecondChild()
    local ori = sp:getOrientation()
    local mps = sp:getMinPanelSize()
    print("firstChild:", fc, "secondChild:", sc, "orientation:", ori, "minPanel:", mps)
end

--@api: LSplitPanel:getMinPanelSize.3
do
    local sp = lurek.ui.newSplitPanel("horizontal")
    local fc = sp:getFirstChild()
    local sc = sp:getSecondChild()
    local ori = sp:getOrientation()
    local mps = sp:getMinPanelSize()
    print("firstChild:", fc, "secondChild:", sc, "orientation:", ori, "minPanel:", mps)
end

--@api: LSplitPanel:getMinPanelSize.4
do
    local sp = lurek.ui.newSplitPanel("horizontal")
    local fc = sp:getFirstChild()
    local sc = sp:getSecondChild()
    local ori = sp:getOrientation()
    local mps = sp:getMinPanelSize()
    print("firstChild:", fc, "secondChild:", sc, "orientation:", ori, "minPanel:", mps)
end

--@api: LSplitPanel:getSplitPosition.2
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

--@api: LSplitPanel:getSplitPosition.3
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

--@api: LSplitPanel:getSplitPosition.4
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

--@api: LSplitPanel:setSecondChild.2
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

--@api: LSplitPanel:setSecondChild.3
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

--@api: LSplitPanel:setSecondChild.4
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

--@api: LSplitPanel:getSplitPosition.5
do
    local sp = lurek.ui.newSplitPanel("horizontal")
    sp:setSplitPosition(200)
    local pos = sp:getSplitPosition()
    local sb = lurek.ui.newStatusBar()
    sb:addSection("Ready", 100)
    local cnt = sb:getSectionCount()
    print("splitPos:", pos, "statusBar sectionCount:", cnt)
end

--@api: LSplitPanel:getSplitPosition.6
do
    local sp = lurek.ui.newSplitPanel("horizontal")
    sp:setSplitPosition(200)
    local pos = sp:getSplitPosition()
    local sb = lurek.ui.newStatusBar()
    sb:addSection("Ready", 100)
    local cnt = sb:getSectionCount()
    print("splitPos:", pos, "statusBar sectionCount:", cnt)
end

--@api: LSplitPanel:getSplitPosition.7
do
    local sp = lurek.ui.newSplitPanel("horizontal")
    sp:setSplitPosition(200)
    local pos = sp:getSplitPosition()
    local sb = lurek.ui.newStatusBar()
    sb:addSection("Ready", 100)
    local cnt = sb:getSectionCount()
    print("splitPos:", pos, "statusBar sectionCount:", cnt)
end

--@api: LStatusBar:setSectionCount
do
    local sb = lurek.ui.newStatusBar()
    sb:setSectionCount(3)
    local cnt = sb:getSectionCount()
    sb:setSectionText(1, "Line 1")
    local txt = sb:getSectionText(1)
    sb:setSectionText(2, "Col 5")
    print("sectionCount:", cnt, "section1:", txt)
end

--@api: LStatusBar:setSectionText.2
do
    local sb = lurek.ui.newStatusBar()
    sb:setSectionCount(3)
    local cnt = sb:getSectionCount()
    sb:setSectionText(1, "Line 1")
    local txt = sb:getSectionText(1)
    sb:setSectionText(2, "Col 5")
    print("sectionCount:", cnt, "section1:", txt)
end

--@api: LStatusBar:setSectionText.3
do
    local sb = lurek.ui.newStatusBar()
    sb:setSectionCount(3)
    local cnt = sb:getSectionCount()
    sb:setSectionText(1, "Line 1")
    local txt = sb:getSectionText(1)
    sb:setSectionText(2, "Col 5")
    print("sectionCount:", cnt, "section1:", txt)
end

--@api: LStatusBar:setSectionWidget
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

--@api: LStatusBar:setSectionWidget.2
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

--@api: LStatusBar:setSectionWidget.3
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

--@api: LSwitch:isOn.2
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

--@api: LSwitch:isOn.3
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

--@api: LSwitch:isOn.4
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

--@api: LTabBar:getTabCount.2
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

--@api: LTabBar:getTabCount.3
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

--@api: LTabBar:getTabCount.4
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

--@api: LTabBar:getActiveTab.2
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

--@api: LTextInput:setText
do
    local ti = lurek.ui.newTextInput()
    ti:setText("hello")
    local txt = ti:getText()
    ti:setPlaceholder("type here")
    local ph = ti:getPlaceholder()
    local cur = ti:getCursorPosition()
    print("text:", txt, "placeholder:", ph, "cursor:", cur)
end

--@api: LTextInput:getCursorPosition.2
do
    local ti = lurek.ui.newTextInput()
    ti:setText("hello")
    local txt = ti:getText()
    ti:setPlaceholder("type here")
    local ph = ti:getPlaceholder()
    local cur = ti:getCursorPosition()
    print("text:", txt, "placeholder:", ph, "cursor:", cur)
end

--@api: LTextInput:getText
do
    local ti = lurek.ui.newTextInput()
    ti:setText("hello")
    local txt = ti:getText()
    ti:setPlaceholder("type here")
    local ph = ti:getPlaceholder()
    local cur = ti:getCursorPosition()
    print("text:", txt, "placeholder:", ph, "cursor:", cur)
end

--@api: LTextInput:isFocused
do
    local ti = lurek.ui.newTextInput()
    ti:setPlaceholder("Search...")
    local ph = ti:getPlaceholder()
    ti:setMaxLength(50)
    local focused = ti:isFocused()
    print("placeholder:", ph, "isFocused:", focused)
end

--@api: LTextInput:isFocused.2
do
    local ti = lurek.ui.newTextInput()
    ti:setPlaceholder("Search...")
    local ph = ti:getPlaceholder()
    ti:setMaxLength(50)
    local focused = ti:isFocused()
    print("placeholder:", ph, "isFocused:", focused)
end

--@api: LTextInput:isFocused.3
do
    local ti = lurek.ui.newTextInput()
    ti:setPlaceholder("Search...")
    local ph = ti:getPlaceholder()
    ti:setMaxLength(50)
    local focused = ti:isFocused()
    print("placeholder:", ph, "isFocused:", focused)
end

--@api: LTextInput:getText.2
do
    local ti = lurek.ui.newTextInput()
    ti:setText("sample input")
    local txt = ti:getText()
    local th = lurek.ui.newTheme()
    th:setStyle("button", "normal", {bg_color = {0.2, 0.3, 0.8}})
    local t = th:type()
    print("text:", txt, "theme type:", t)
end

--@api: LTheme:setStyle
do
    local ti = lurek.ui.newTextInput()
    ti:setText("sample input")
    local txt = ti:getText()
    local th = lurek.ui.newTheme()
    th:setStyle("button", "normal", {bg_color = {0.2, 0.3, 0.8}})
    local t = th:type()
    print("text:", txt, "theme type:", t)
end

--@api: LTheme:type
do
    local ti = lurek.ui.newTextInput()
    ti:setText("sample input")
    local txt = ti:getText()
    local th = lurek.ui.newTheme()
    th:setStyle("button", "normal", {bg_color = {0.2, 0.3, 0.8}})
    local t = th:type()
    print("text:", txt, "theme type:", t)
end

--@api: LTheme:typeOf
do
    local th = lurek.ui.newTheme()
    local ok = th:typeOf("LTheme")
    local toast = lurek.ui.newToast("Level up!", 3.0)
    local dur = toast:getDuration()
    local msg = toast:getMessage()
    print("theme typeOf:", ok, "duration:", dur, "message:", msg)
end

--@api: LTheme:typeOf.2
do
    local th = lurek.ui.newTheme()
    local ok = th:typeOf("LTheme")
    local toast = lurek.ui.newToast("Level up!", 3.0)
    local dur = toast:getDuration()
    local msg = toast:getMessage()
    print("theme typeOf:", ok, "duration:", dur, "message:", msg)
end

--@api: LTheme:typeOf.3
do
    local th = lurek.ui.newTheme()
    local ok = th:typeOf("LTheme")
    local toast = lurek.ui.newToast("Level up!", 3.0)
    local dur = toast:getDuration()
    local msg = toast:getMessage()
    print("theme typeOf:", ok, "duration:", dur, "message:", msg)
end

--@api: LToast:getDuration.2
do
    local toast = lurek.ui.newToast("Achievement unlocked", 2.0)
    local prog = toast:getProgress()
    local exp = toast:isExpired()
    toast:setDuration(5.0)
    local dur = toast:getDuration()
    print("progress:", prog, "isExpired:", exp, "duration:", dur)
end

--@api: LToast:getDuration.3
do
    local toast = lurek.ui.newToast("Achievement unlocked", 2.0)
    local prog = toast:getProgress()
    local exp = toast:isExpired()
    toast:setDuration(5.0)
    local dur = toast:getDuration()
    print("progress:", prog, "isExpired:", exp, "duration:", dur)
end

--@api: LToast:getDuration.4
do
    local toast = lurek.ui.newToast("Achievement unlocked", 2.0)
    local prog = toast:getProgress()
    local exp = toast:isExpired()
    toast:setDuration(5.0)
    local dur = toast:getDuration()
    print("progress:", prog, "isExpired:", exp, "duration:", dur)
end

--@api: LToast:getMessage.2
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

--@api: LToast:getMessage.3
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

--@api: LToast:getMessage.4
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

--@api: LToolbar:addSpacer
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("cut", "Cut")
    tb:addSpacer(10)
    tb:addButton("paste", "Paste")
    local ori = tb:getOrientation()
    local btn = tb:getButton("cut")
    print("orientation:", ori, "button:", btn)
end

--@api: LToolbar:getButton.2
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("cut", "Cut")
    tb:addSpacer(10)
    tb:addButton("paste", "Paste")
    local ori = tb:getOrientation()
    local btn = tb:getButton("cut")
    print("orientation:", ori, "button:", btn)
end

--@api: LToolbar:getButton.3
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("cut", "Cut")
    tb:addSpacer(10)
    tb:addButton("paste", "Paste")
    local ori = tb:getOrientation()
    local btn = tb:getButton("cut")
    print("orientation:", ori, "button:", btn)
end

--@api: LToolbar:setButtonEnabled.2
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("bold", "Bold")
    tb:setButtonToggled("bold", true)
    local tog = tb:isButtonToggled("bold")
    tb:setButtonEnabled("bold", false)
    print("bold toggled:", tog)
end

--@api: LToolbar:setButtonEnabled.3
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("bold", "Bold")
    tb:setButtonToggled("bold", true)
    local tog = tb:isButtonToggled("bold")
    tb:setButtonEnabled("bold", false)
    print("bold toggled:", tog)
end

--@api: LToolbar:setButtonEnabled.4
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("bold", "Bold")
    tb:setButtonToggled("bold", true)
    local tog = tb:isButtonToggled("bold")
    tb:setButtonEnabled("bold", false)
    print("bold toggled:", tog)
end

--@api: LToolbar:getOrientation.2
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:setOrientation("vertical")
    local ori = tb:getOrientation()
    local tp = lurek.ui.newTooltipPanel("Hover help")
    local delay = tp:getDelay()
    local target = tp:getTarget()
    print("orientation:", ori, "delay:", delay, "target:", target)
end

--@api: LToolbar:getOrientation.3
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:setOrientation("vertical")
    local ori = tb:getOrientation()
    local tp = lurek.ui.newTooltipPanel("Hover help")
    local delay = tp:getDelay()
    local target = tp:getTarget()
    print("orientation:", ori, "delay:", delay, "target:", target)
end

--@api: LTooltipPanel:getTarget
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:setOrientation("vertical")
    local ori = tb:getOrientation()
    local tp = lurek.ui.newTooltipPanel("Hover help")
    local delay = tp:getDelay()
    local target = tp:getTarget()
    print("orientation:", ori, "delay:", delay, "target:", target)
end

--@api: LTooltipPanel:setTarget.2
do
    local tp = lurek.ui.newTooltipPanel("initial tip")
    local txt = tp:getText()
    tp:setDelay(0.5)
    local d = tp:getDelay()
    local btn = lurek.ui.newButton("hover me")
    tp:setTarget(btn:getId() and 1 or 1)
    print("text:", txt, "delay:", d)
end

--@api: LTooltipPanel:setTarget.3
do
    local tp = lurek.ui.newTooltipPanel("initial tip")
    local txt = tp:getText()
    tp:setDelay(0.5)
    local d = tp:getDelay()
    local btn = lurek.ui.newButton("hover me")
    tp:setTarget(btn:getId() and 1 or 1)
    print("text:", txt, "delay:", d)
end

--@api: LTooltipPanel:setTarget
do
    local tp = lurek.ui.newTooltipPanel("initial tip")
    local txt = tp:getText()
    tp:setDelay(0.5)
    local d = tp:getDelay()
    local btn = lurek.ui.newButton("hover me")
    tp:setTarget(btn:getId() and 1 or 1)
    print("text:", txt, "delay:", d)
end

--@api: LTooltipPanel:setDelay.2
do
    local tp = lurek.ui.newTooltipPanel("old tip")
    tp:setText("new tooltip text")
    local txt = tp:getText()
    tp:setText("another tip")
    local txt2 = tp:getText()
    tp:setDelay(1.0)
    print("setText:", txt, "â†’", txt2)
end

--@api: LTreeView:getNodeCount.2
do
    local tv = lurek.ui.newTreeView()
    local n1 = tv:addNode("Root", nil)
    local n2 = tv:addNode("Child", n1)
    tv:collapseAll()
    tv:clearNodes()
    local cnt = tv:getNodeCount()
    print("addNode/collapseAll/clearNodes ok; count after clear:", cnt)
end

--@api: LTreeView:getNodeCount.3
do
    local tv = lurek.ui.newTreeView()
    local n1 = tv:addNode("Root", nil)
    local n2 = tv:addNode("Child", n1)
    tv:collapseAll()
    tv:clearNodes()
    local cnt = tv:getNodeCount()
    print("addNode/collapseAll/clearNodes ok; count after clear:", cnt)
end

--@api: LTreeView:getNodeCount.4
do
    local tv = lurek.ui.newTreeView()
    local n1 = tv:addNode("Root", nil)
    local n2 = tv:addNode("Child", n1)
    tv:collapseAll()
    tv:clearNodes()
    local cnt = tv:getNodeCount()
    print("addNode/collapseAll/clearNodes ok; count after clear:", cnt)
end

--@api: LTreeView:getNodeCount.5
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

--@api: LTreeView:getNodeCount.6
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

--@api: LTreeView:getNodeCount.7
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

--@api: LTreeView:getNodeDepth.2
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

--@api: LTreeView:getNodeDepth.3
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

--@api: LTreeView:getNodeDepth.4
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

--@api: LTreeView:getSelectedNode.2
do
    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    local c = tv:addNode("Child", r)
    local txt = tv:getNodeText(c)
    local parent = tv:getParentNode(c)
    local sel = tv:getSelectedNode()
    print("text:", txt, "parent:", parent, "selected:", sel)
end

--@api: LTreeView:getSelectedNode.3
do
    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    local c = tv:addNode("Child", r)
    local txt = tv:getNodeText(c)
    local parent = tv:getParentNode(c)
    local sel = tv:getSelectedNode()
    print("text:", txt, "parent:", parent, "selected:", sel)
end

--@api: LTreeView:getSelectedNode.4
do
    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    local c = tv:addNode("Child", r)
    local txt = tv:getNodeText(c)
    local parent = tv:getParentNode(c)
    local sel = tv:getSelectedNode()
    print("text:", txt, "parent:", parent, "selected:", sel)
end

--@api: LTreeView:getNodeCount.8
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

--@api: LTreeView:getNodeCount.9
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

--@api: LTreeView:getNodeCount.10
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

--@api: LTreeView:setNodeIcon.2
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

--@api: LTreeView:setNodeIcon.3
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

--@api: LTreeView:setNodeIcon.4
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

--@api: LTreeView:toggleNode.2
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

--@api: lurek.ui.newCustomWidget
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local child = lurek.ui.newLabel("label")
    w:addChild(child)
    w:animateAlpha(0.5, 0.3, false)
    w:animatePosition(10, 20, 0.5)
    local cnt = w:getChildCount()
    print("addChild/animateAlpha/animatePosition ok; childCount:", cnt)
end

--@api: LCustomWidget:addChild
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local child = lurek.ui.newLabel("label")
    w:addChild(child)
    w:animateAlpha(0.5, 0.3, false)
    w:animatePosition(10, 20, 0.5)
    local cnt = w:getChildCount()
    print("addChild/animateAlpha/animatePosition ok; childCount:", cnt)
end

--@api: LCustomWidget:getChildCount
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local child = lurek.ui.newLabel("label")
    w:addChild(child)
    w:animateAlpha(0.5, 0.3, false)
    w:animatePosition(10, 20, 0.5)
    local cnt = w:getChildCount()
    print("addChild/animateAlpha/animatePosition ok; childCount:", cnt)
end

--@api: LUiWidget:attachToEntity
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

--@api: LUiWidget:bind
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

--@api: LUiWidget:cancelAnimations
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

--@api: LCustomWidget:setAnchor
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

--@api: LCustomWidget:detachFromEntity
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

--@api: LUiWidget:detachFromEntity
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

--@api: LCustomWidget:setId
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

--@api: LCustomWidget:findById
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

--@api: LCustomWidget:findById.2
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

--@api: LCustomWidget:setAlpha
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

--@api: LCustomWidget:getChildren
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

--@api: LCustomWidget:getChildren.2
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

--@api: LCustomWidget:setFlexGrow
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

--@api: LCustomWidget:getId
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

--@api: LCustomWidget:getId.2
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

--@api: LCustomWidget:setMargin
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

--@api: LCustomWidget:getMinSize
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

--@api: LCustomWidget:getMinSize.2
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

--@api: LCustomWidget:setPadding
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setPadding(5, 5, 5, 5)
    local pt, pr, pb, pl = w:getPadding()
    w:setPosition(30, 40)
    local px, py = w:getPosition()
    local rx, ry, rw, rh = w:getRect()
    print("padding:", pt, "position:", px, py, "rect:", rx, ry, rw, rh)
end

--@api: LCustomWidget:getRect
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setPadding(5, 5, 5, 5)
    local pt, pr, pb, pl = w:getPadding()
    w:setPosition(30, 40)
    local px, py = w:getPosition()
    local rx, ry, rw, rh = w:getRect()
    print("padding:", pt, "position:", px, py, "rect:", rx, ry, rw, rh)
end

--@api: LCustomWidget:getRect.2
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setPadding(5, 5, 5, 5)
    local pt, pr, pb, pl = w:getPadding()
    w:setPosition(30, 40)
    local px, py = w:getPosition()
    local rx, ry, rw, rh = w:getRect()
    print("padding:", pt, "position:", px, py, "rect:", rx, ry, rw, rh)
end

--@api: LCustomWidget:setSize
do
    local w = lurek.ui.newCustomWidget({width=120, height=60})
    w:setSize(150, 80)
    local sw, sh = w:getSize()
    local state = w:getState()
    w:setTooltip("hover tip")
    local tip = w:getTooltip()
    print("size:", sw, sh, "state:", state, "tooltip:", tip)
end

--@api: LCustomWidget:getTooltip
do
    local w = lurek.ui.newCustomWidget({width=120, height=60})
    w:setSize(150, 80)
    local sw, sh = w:getSize()
    local state = w:getState()
    w:setTooltip("hover tip")
    local tip = w:getTooltip()
    print("size:", sw, sh, "state:", state, "tooltip:", tip)
end

--@api: LCustomWidget:getTooltip.2
do
    local w = lurek.ui.newCustomWidget({width=120, height=60})
    w:setSize(150, 80)
    local sw, sh = w:getSize()
    local state = w:getState()
    w:setTooltip("hover tip")
    local tip = w:getTooltip()
    print("size:", sw, sh, "state:", state, "tooltip:", tip)
end

--@api: LCustomWidget:setZOrder
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setZOrder(5)
    local z = w:getZOrder()
    local animating = w:isAnimating()
    local enabled = w:isEnabled()
    w:setEnabled(false)
    print("zOrder:", z, "isAnimating:", animating, "isEnabled:", enabled)
end

--@api: LUiWidget:isAnimating
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setZOrder(5)
    local z = w:getZOrder()
    local animating = w:isAnimating()
    local enabled = w:isEnabled()
    w:setEnabled(false)
    print("zOrder:", z, "isAnimating:", animating, "isEnabled:", enabled)
end

--@api: LCustomWidget:setEnabled
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setZOrder(5)
    local z = w:getZOrder()
    local animating = w:isAnimating()
    local enabled = w:isEnabled()
    w:setEnabled(false)
    print("zOrder:", z, "isAnimating:", animating, "isEnabled:", enabled)
end

--@api: LCustomWidget:isVisible
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

--@api: LCustomWidget:getAlpha
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

--@api: LCustomWidget:getAlpha.2
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

--@api: LCustomWidget:isEnabled
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

--@api: LCustomWidget:setEnabled.2
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

--@api: LCustomWidget:setEnabled.3
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

--@api: LCustomWidget:getId.3
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

--@api: LCustomWidget:getId.4
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

--@api: LCustomWidget:getId.5
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

--@api: LCustomWidget:getMinSize.3
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

--@api: LCustomWidget:getMinSize.4
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

--@api: LCustomWidget:getMinSize.5
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

--@api: LUiWidget:setOnChange
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setOnChange(function() print("changed") end)
    w:setOnClick(function() print("clicked") end)
    w:setOnDraw(function() print("drawing") end)
    local id = w:getId()
    local vis = w:isVisible()
    print("setOnChange/setOnClick/setOnDraw ok; id:", id, "vis:", vis)
end

--@api: LUiWidget:setOnClick
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setOnChange(function() print("changed") end)
    w:setOnClick(function() print("clicked") end)
    w:setOnDraw(function() print("drawing") end)
    local id = w:getId()
    local vis = w:isVisible()
    print("setOnChange/setOnClick/setOnDraw ok; id:", id, "vis:", vis)
end

--@api: LUiWidget:setOnDraw
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setOnChange(function() print("changed") end)
    w:setOnClick(function() print("clicked") end)
    w:setOnDraw(function() print("drawing") end)
    local id = w:getId()
    local vis = w:isVisible()
    print("setOnChange/setOnClick/setOnDraw ok; id:", id, "vis:", vis)
end

--@api: LCustomWidget:getSize
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

--@api: LCustomWidget:getSize.2
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

--@api: LCustomWidget:getSize.3
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

--@api: LCustomWidget:setTooltip
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

--@api: LCustomWidget:getZOrder
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

--@api: LCustomWidget:getZOrder.2
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

--@api: LCustomWidget:slideIn
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:slideIn(0, -50)
    w:slideOut(0, 50)
    local t = w:type()
    local ok = w:typeOf("LUiWidget")
    w:unbind()
    print("slideIn/slideOut ok; type:", t, "typeOf:", ok)
end

--@api: LCustomWidget:unbind
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:slideIn(0, -50)
    w:slideOut(0, 50)
    local t = w:type()
    local ok = w:typeOf("LUiWidget")
    w:unbind()
    print("slideIn/slideOut ok; type:", t, "typeOf:", ok)
end

--@api: LUiWidget:type
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:slideIn(0, -50)
    w:slideOut(0, 50)
    local t = w:type()
    local ok = w:typeOf("LUiWidget")
    w:unbind()
    print("slideIn/slideOut ok; type:", t, "typeOf:", ok)
end

--@api: LUiWidget:typeOf
do
    local w = lurek.ui.newCustomWidget({width=80, height=40})
    w:bind("click")
    w:unbind()
    local ok1 = w:typeOf("LUiWidget")
    local ok2 = w:typeOf("LButton")
    local t = w:type()
    print("typeOf LUiWidget:", ok1, "typeOf LButton:", ok2, "type:", t)
end

--@api: LUiWidget:unbind
do
    local w = lurek.ui.newCustomWidget({width=80, height=40})
    w:bind("click")
    w:unbind()
    local ok1 = w:typeOf("LUiWidget")
    local ok2 = w:typeOf("LButton")
    local t = w:type()
    print("typeOf LUiWidget:", ok1, "typeOf LButton:", ok2, "type:", t)
end

--@api: lurek.ui.draw
do
    local w = lurek.ui.newCustomWidget({width=80, height=40})
    lurek.ui.beginDrag(w)
    lurek.ui.endDrag()
    lurek.ui.clearFocus()
    lurek.ui.draw()
    print("beginDrag/endDrag/clearFocus/draw ok")
end

--@api: lurek.ui.drawToImage
do
    local img = lurek.ui.drawToImage(320, 240)
    local w = lurek.ui.newCustomWidget({width=80, height=40})
    lurek.ui.beginDrag(w)
    lurek.ui.dropOn(w)
    lurek.ui.endDrag()
    print("drawToImage ok; dropOn/endDrag ok")
end

--@api: lurek.ui.endDrag
do
    local img = lurek.ui.drawToImage(320, 240)
    local w = lurek.ui.newCustomWidget({width=80, height=40})
    lurek.ui.beginDrag(w)
    lurek.ui.dropOn(w)
    lurek.ui.endDrag()
    print("drawToImage ok; dropOn/endDrag ok")
end

--@api: lurek.ui.flushCache
do
    lurek.ui.flushCache()
    lurek.ui.focusPrev()
    local drag = lurek.ui.getActiveDrag()
    local focus = lurek.ui.getFocus()
    lurek.ui.clearFocus()
    print("flushCache/focusPrev ok; activeDrag:", drag, "focus:", focus)
end

--@api: lurek.ui.getToastCount
do
    lurek.ui.clearFocus()
    local foc = lurek.ui.getFocus()
    local theme = lurek.ui.getTheme()
    local toasts = lurek.ui.getToastCount()
    local widgets = lurek.ui.getWidgetCount()
    print("focus:", foc, "theme:", theme, "toastCount:", toasts, "widgetCount:", widgets)
end

--@api: lurek.ui.getWidgetCount
do
    local cnt = lurek.ui.getWidgetCount()
    lurek.ui.keypressed("escape")
    local layout = lurek.ui.loadLayoutFile("content/examples/assets/layouts/sample_main_menu.toml")
    lurek.ui.textinput("a")
    print("widgetCount:", cnt, "loadLayoutFile ok; textinput ok")
end

--@api: lurek.ui.keypressed
do
    local cnt = lurek.ui.getWidgetCount()
    lurek.ui.keypressed("escape")
    local layout = lurek.ui.loadLayoutFile("content/examples/assets/layouts/sample_main_menu.toml")
    lurek.ui.textinput("a")
    print("widgetCount:", cnt, "loadLayoutFile ok; textinput ok")
end

--@api: lurek.ui.loadLayoutFile
do
    local cnt = lurek.ui.getWidgetCount()
    lurek.ui.keypressed("escape")
    local layout = lurek.ui.loadLayoutFile("content/examples/assets/layouts/sample_main_menu.toml")
    lurek.ui.textinput("a")
    print("widgetCount:", cnt, "loadLayoutFile ok; textinput ok")
end

--@api: lurek.ui.loadLayoutGameFile
do
    local ok, result = pcall(function()
        return lurek.ui.loadLayoutGameFile("content/examples/assets/layouts/sample_main_menu.toml")
    end)
    print("loadLayoutGameFile ok:", ok, "result:", tostring(result))
end

--@api: lurek.ui.mousemoved
do
    local slider = lurek.ui.newSlider(0, 100)
    slider:setPosition(20, 520)
    slider:setSize(200, 20)
    slider:setZOrder(2200)
    lurek.ui.mousepressed(40, 530, 1)
    lurek.ui.mousemoved(180, 530)
    lurek.ui.mousereleased(180, 530, 1)
    lurek.ui.update(0)
    print("slider value after drag:", slider:getValue())
end

--@api: lurek.ui.mousepressed
do
    local tabs = lurek.ui.newTabBar()
    tabs:setPosition(20, 560)
    tabs:setSize(240, 28)
    tabs:setZOrder(2300)
    tabs:addTab("Home")
    tabs:addTab("Reports")
    tabs:addTab("Settings")
    lurek.ui.mousepressed(120, 574, 1)
    lurek.ui.mousereleased(120, 574, 1)
    lurek.ui.update(0)
    print("active tab after click:", tabs:getActiveTab())
end

--@api: lurek.ui.mousereleased
do
    local combo = lurek.ui.newComboBox()
    combo:setPosition(20, 600)
    combo:setSize(160, 28)
    combo:setZOrder(2400)
    combo:addItem("All")
    combo:addItem("Food")
    combo:addItem("Rent")
    lurek.ui.mousepressed(30, 614, 1)
    lurek.ui.mousereleased(30, 614, 1)
    lurek.ui.mousepressed(30, 670, 1)
    lurek.ui.mousereleased(30, 670, 1)
    lurek.ui.update(0)
    print("combo selected:", combo:getSelectedItem())
end

--@api: LCustomWidget:UNKNOWN
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local layout = lurek.ui.newLayout("row")
    local sb = lurek.ui.newScrollBar(true)
    print("newCustomWidget:", w, "newLayout:", layout, "newScrollBar:", sb)
end

--@api: lurek.ui.newScrollBar
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local layout = lurek.ui.newLayout("row")
    local sb = lurek.ui.newScrollBar(true)
    print("newCustomWidget:", w, "newLayout:", layout, "newScrollBar:", sb)
end

--@api: lurek.ui.parseWidgetState
do
    local th = lurek.ui.newTheme()
    local state = lurek.ui.parseWidgetState("normal")
    local result = lurek.ui.renderToImage(320, 240, "save/ui_render.png")
    print("newTheme ok; parseWidgetState:", state, "renderToImage:", result)
end

--@api: lurek.ui.renderToImage
do
    local th = lurek.ui.newTheme()
    local state = lurek.ui.parseWidgetState("normal")
    local result = lurek.ui.renderToImage(320, 240, "save/ui_render.png")
    print("newTheme ok; parseWidgetState:", state, "renderToImage:", result)
end

--@api: lurek.ui.setDefaultTheme
do
    local th = lurek.ui.newTheme()
    lurek.ui.setTheme(th)
    lurek.ui.setDefaultTheme()
    lurek.ui.setViewport(1280, 720)
    local cnt = lurek.ui.getWidgetCount()
    print("setTheme/setDefaultTheme/setViewport ok; widgets:", cnt)
end

--@api: lurek.ui.setViewport
do
    local th = lurek.ui.newTheme()
    lurek.ui.setTheme(th)
    lurek.ui.setDefaultTheme()
    lurek.ui.setViewport(1280, 720)
    local cnt = lurek.ui.getWidgetCount()
    print("setTheme/setDefaultTheme/setViewport ok; widgets:", cnt)
end

--@api: lurek.ui.textinput
do
    lurek.ui.textinput("hello")
    lurek.ui.textinput(" world")
    lurek.ui.update_bindings({dt=0.016})
    lurek.ui.wheelmoved(0, 1)
    lurek.ui.wheelmoved(1, 0)
    print("textinput/update_bindings/wheelmoved ok")
end

--@api: lurek.ui.update_bindings
do
    lurek.ui.textinput("hello")
    lurek.ui.textinput(" world")
    lurek.ui.update_bindings({dt=0.016})
    lurek.ui.wheelmoved(0, 1)
    lurek.ui.wheelmoved(1, 0)
    print("textinput/update_bindings/wheelmoved ok")
end

--@api: lurek.ui.wheelmoved
do
    local panel = lurek.ui.newScrollPanel()
    panel:setPosition(300, 520)
    panel:setSize(120, 70)
    panel:setZOrder(2500)
    panel:setContentSize(120, 300)
    lurek.ui.mousemoved(310, 530)
    lurek.ui.wheelmoved(0, -3)
    local _, sy = panel:getScrollPosition()
    print("hover scroll y:", sy)
end

--@api: LTextInput:setPosition
do
    local input = lurek.ui.newTextInput()
    input:setPosition(20, 650)
    input:setSize(160, 28)
    input:setZOrder(2600)
    lurek.ui.setFocus(input)
    lurek.ui.textinput("42")
    lurek.ui.keypressed("left")
    lurek.ui.textinput(".")
    lurek.ui.update(0)
    print("focused text:", input:isFocused(), input:getText())
end

--@api: LToolbar:setPosition
do
    local toolbar = lurek.ui.newToolbar("horizontal")
    toolbar:setPosition(220, 650)
    toolbar:setSize(120, 32)
    toolbar:setZOrder(2610)
    toolbar:addButton("save", "Save")
    toolbar:setOnChange(function() print("toolbar changed") end)
    lurek.ui.mousepressed(230, 666, 1)
    lurek.ui.mousereleased(230, 666, 1)
    lurek.ui.update(0)
    print("save toggled:", toolbar:isButtonToggled("save"))
end

--@api: LRadioButton:setPosition
do
    local cash = lurek.ui.newRadioButton("Cash", "payment_kind")
    cash:setPosition(370, 650)
    cash:setSize(100, 24)
    cash:setZOrder(2620)
    local card = lurek.ui.newRadioButton("Card", "payment_kind")
    card:setPosition(370, 678)
    card:setSize(100, 24)
    card:setZOrder(2630)
    card:setOnChange(function() print("card selected") end)
    lurek.ui.mousepressed(380, 688, 1)
    lurek.ui.mousereleased(380, 688, 1)
    lurek.ui.update(0)
    print("cash/card:", cash:isSelected(), card:isSelected())
end

--@api: LScrollBar:setPosition
do
    local bar = lurek.ui.newScrollBar(true)
    bar:setPosition(500, 650)
    bar:setSize(20, 100)
    bar:setZOrder(2640)
    bar:setContentSize(400)
    bar:setViewSize(100)
    bar:setOnChange(function() print("scrollbar changed") end)
    lurek.ui.mousepressed(510, 720, 1)
    lurek.ui.mousemoved(510, 740)
    lurek.ui.mousereleased(510, 740, 1)
    lurek.ui.update(0)
    print("scrollbar position:", bar:getScrollPosition())
end

--@api: LWindow:setPosition
do
    local win = lurek.ui.newWindow("Inspector")
    win:setPosition(550, 650)
    win:setSize(150, 90)
    win:setZOrder(2650)
    win:setOnClose(function() print("window closed") end)
    lurek.ui.mousepressed(690, 660, 1)
    lurek.ui.mousereleased(690, 660, 1)
    lurek.ui.update(0)
    print("window visible:", win:isVisible())
end

--@api: LDialog:setPosition
do
    local dialog = lurek.ui.newDialog("Confirm")
    dialog:setCenterOnOpen(false)
    dialog:setPosition(720, 650)
    dialog:setSize(180, 100)
    dialog:setZOrder(2660)
    dialog:addButton("Close")
    dialog:setOnClose(function() print("dialog closed") end)
    dialog:open()
    lurek.ui.mousepressed(830, 724, 1)
    lurek.ui.mousereleased(830, 724, 1)
end

--@api: LUiWidget:setMouseFilter
do
    -- Sets the mouse filter mode on a panel. "ignore" passes events to underlying widgets,
    -- useful for decorative overlays or transparent layout containers.
    local panel = lurek.ui.newPanel()
    panel:setMouseFilter("ignore")
    print("mouse filter set to ignore")
end

--@api: LUiWidget:getMouseFilter
do
    -- Retrieves the current mouse filter behavior of a widget.
    local panel = lurek.ui.newPanel()
    panel:setMouseFilter("pass")
    local filter = panel:getMouseFilter()
    print("mouse filter: " .. filter)
end

--@api: LUiWidget:setStyleClass
do
    -- Assigns a custom style class to a widget. If defined in the active theme,
    -- the button will use "primary" colors and metrics instead of default ones.
    local btn = lurek.ui.newButton("Submit")
    btn:setStyleClass("primary")
    print("style class set to primary")
end

--@api: LUiWidget:getStyleClass
do
    -- Retrieves the currently assigned style class of a widget, or an empty string if none.
    local btn = lurek.ui.newButton("Cancel")
    btn:setStyleClass("danger")
    local class = btn:getStyleClass()
    print("style class: " .. class)
end

--@api: LUiWidget:setAlign
do
    -- Configures the flexbox cross-axis alignment. "center" aligns children
    -- vertically in a horizontal layout.
    local layout = lurek.ui.newLayout("horizontal")
    layout:setAlign("center")
    print("align set to center")
end

--@api: LUiWidget:getAlign
do
    -- Gets the current flexbox alignment property.
    local layout = lurek.ui.newLayout("horizontal")
    layout:setAlign("stretch")
    local align = layout:getAlign()
    print("align: " .. align)
end

--@api: LUiWidget:setJustify
do
    -- Configures the flexbox main-axis justification. "space-between" spreads
    -- children to edges.
    local layout = lurek.ui.newLayout("horizontal")
    layout:setJustify("space-between")
    print("justify set to space-between")
end

--@api: LUiWidget:getJustify
do
    -- Gets the current flexbox justification property.
    local layout = lurek.ui.newLayout("horizontal")
    layout:setJustify("end")
    local justify = layout:getJustify()
    print("justify: " .. justify)
end

--@api: LTable:clearRows
do
    -- Removes all rows from a GUI table without deleting its column definitions.
    local tbl = lurek.ui.newTable()
    tbl:addColumn("Name")
    tbl:addRow({"Alice"})
    tbl:clearRows()
    print("cleared rows")
end

--@api: LTable:setRows
do
    -- Bulk-replaces all current rows with the provided list of row data.
    local tbl = lurek.ui.newTable()
    tbl:addColumn("Score")
    tbl:setRows({{"100"}, {"200"}})
    print("set rows")
end

--@api: lurek.ui.setFont
do
    -- Example for setFont
    local widget = lurek.ui.newButton("Test Widget")
    widget:setText("Using setFont")
    local w, h = widget:getSize()
    lurek.log.info("Invoked setFont on widget size " .. w .. "x" .. h)
    if w > 0 then widget:setVisible(true) end
end

--@api: lurek.ui.getFont
do
    -- Example for getFont
    local widget = lurek.ui.newButton("Test Widget")
    widget:setText("Using getFont")
    local w, h = widget:getSize()
    lurek.log.info("Invoked getFont on widget size " .. w .. "x" .. h)
    if w > 0 then widget:setVisible(true) end
end

--@api: lurek.ui.clearFont
do
    -- Example for clearFont
    local widget = lurek.ui.newButton("Test Widget")
    widget:setText("Using clearFont")
    local w, h = widget:getSize()
    lurek.log.info("Invoked clearFont on widget size " .. w .. "x" .. h)
    if w > 0 then widget:setVisible(true) end
end

--@api: lurek.ui.getWidgetFont
do
    -- Example for getWidgetFont
    local widget = lurek.ui.newButton("Test Widget")
    widget:setText("Using getWidgetFont")
    local w, h = widget:getSize()
    lurek.log.info("Invoked getWidgetFont on widget size " .. w .. "x" .. h)
    if w > 0 then widget:setVisible(true) end
end

--@api: lurek.ui.updateBindings
do
    -- Example for updateBindings
    local widget = lurek.ui.newButton("Test Widget")
    widget:setText("Using updateBindings")
    local w, h = widget:getSize()
    lurek.log.info("Invoked updateBindings on widget size " .. w .. "x" .. h)
    if w > 0 then widget:setVisible(true) end
end

--@api: LUiWidget:setFont
do
    -- Example for setFont
    local widget = lurek.ui.newButton("Test Widget")
    widget:setText("Using setFont")
    local w, h = widget:getSize()
    lurek.log.info("Invoked setFont on widget size " .. w .. "x" .. h)
    if w > 0 then widget:setVisible(true) end
end

--@api: LUiWidget:clearFont
do
    -- Example for clearFont
    local widget = lurek.ui.newButton("Test Widget")
    widget:setText("Using clearFont")
    local w, h = widget:getSize()
    lurek.log.info("Invoked clearFont on widget size " .. w .. "x" .. h)
    if w > 0 then widget:setVisible(true) end
end

--@api: LUiWidget:setBindKey
do
    -- Example for setBindKey
    local widget = lurek.ui.newButton("Test Widget")
    widget:setText("Using setBindKey")
    local w, h = widget:getSize()
    lurek.log.info("Invoked setBindKey on widget size " .. w .. "x" .. h)
    if w > 0 then widget:setVisible(true) end
end

--@api: LUiWidget:setTextWrap
do
    local lbl = lurek.ui.newLabel("This is a long text that can wrap")
    lbl:setTextWrap(true)
end

--@api: LUiWidget:setTextEllipsis
do
    local lbl = lurek.ui.newLabel("This is a very long one-line text")
    lbl:setTextEllipsis(true)
end

--@api: LUiWidget:setTextVAlign
do
    local lbl = lurek.ui.newLabel("Centered")
    lbl:setTextVAlign("middle")
end

--@api: LUiWidget:setTextAlign
do
    local lbl = lurek.ui.newLabel("Right aligned")
    lbl:setTextAlign("right")
end

--@api: LUiWidget:getTextAlign
do
    local lbl = lurek.ui.newLabel("Aligned")
    lbl:setTextAlign("center")
    print("textAlign=" .. lbl:getTextAlign())
end

--@api: LUiWidget:setFocusable
do
    local btn = lurek.ui.newButton("Focusable")
    btn:setFocusable(true)
end

--@api: LUiWidget:setTabIndex
do
    local btn = lurek.ui.newButton("Tab")
    btn:setTabIndex(10)
end

--@api: LUiWidget:setFocusGroup
do
    local btn = lurek.ui.newButton("Group")
    btn:setFocusGroup("menu")
end

--@api: LUiWidget:setFocusNeighbor
do
    local a = lurek.ui.newButton("A")
    local b = lurek.ui.newButton("B")
    a:setFocusNeighbor("right", b._idx)
end

--@api: LUiWidget:setRole
do
    local btn = lurek.ui.newButton("Save")
    btn:setRole("button")
end

--@api: LUiWidget:setAriaName
do
    local btn = lurek.ui.newButton("Save")
    btn:setAriaName("Save game")
end

--@api: lurek.ui.getStyleToken
do
    local spacing = lurek.ui.getStyleToken("spacing_md")
    local color = lurek.ui.getStyleToken("color_primary")
    print("spacing_md=" .. tostring(spacing))
    if type(color) == "table" then
        print("color_primary a=" .. tostring(color.a))
    end
end

--@api: lurek.ui.focusNeighbor
do
    local a = lurek.ui.newButton("A")
    local b = lurek.ui.newButton("B")
    a:setFocusNeighbor("right", b._idx)
    lurek.ui.setFocus(a)
    local moved = lurek.ui.focusNeighbor("right")
    print("focus moved=" .. tostring(moved))
end

--@api: lurek.ui.clear
do
    local root = lurek.ui.getRoot()
    if root then
        lurek.ui.clear()
    end
end

--@api: lurek.ui.focusDirection
do
    lurek.ui.focusDirection(1.0, 0.0)
    print("lurek.ui.focusDirection ok")
end

--@api: lurek.ui.updateResolution
do
    lurek.ui.updateResolution(1920, 1080)
    print("lurek.ui.updateResolution ok")
end

--@api: lurek.ui.setBaseResolution
do
    lurek.ui.setBaseResolution(1280, 720)
    print("lurek.ui.setBaseResolution scaleFactor=" .. lurek.ui.getScaleFactor())
end

--@api: lurek.ui.getScaleFactor
do
    local sf = lurek.ui.getScaleFactor()
    print("lurek.ui.getScaleFactor=" .. sf)
end

--@api: lurek.ui.visibleRange
do
    local list = lurek.ui.newList()
    local x, y = lurek.ui.visibleRange(list, 50, 20.0)
    print("lurek.ui.visibleRange x=" .. x .. " y=" .. y)
end

--@api: lurek.ui.animateScale
do
    local btn = lurek.ui.newButton("Scale")
    lurek.ui.animateScale(btn._idx, 1.0, 1.0, 1.2, 1.2, 0.3)
    print("lurek.ui.animateScale ok")
end

--@api: lurek.ui.animateRotation
do
    local img = lurek.ui.newPanel()
    lurek.ui.animateRotation(img._idx, 0, 360, 1.0)
    print("lurek.ui.animateRotation ok")
end

--@api: lurek.ui.animateColor
do
    local lbl = lurek.ui.newLabel("Hello")
    lurek.ui.animateColor(lbl._idx, {r=1,g=1,b=1,a=1}, {r=1,g=0.5,b=0,a=1}, 0.5)
    print("lurek.ui.animateColor ok")
end

-- Duplicate coverage lives in content/examples/charts.lua.
