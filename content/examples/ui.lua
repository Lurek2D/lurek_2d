-- content/examples/ui.lua
-- Auto-generated from content/examples2/ui_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/ui.lua

--- UI Module Part 1: core widgets (button, label, panel) and base LUiWidget operations


--@api-stub: lurek.ui.newButton
do
    ---@type LButton
    local btn = lurek.ui.newButton("Click Me")
    print("type = " .. btn:type())
    print("text = " .. btn:getText())
end

--@api-stub: LButton:setOnClick
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
do
    local lbl = lurek.ui.newLabel("Hello, World!")
    print("type = " .. lbl:type())
    print("text = " .. lbl:getText())
    lbl:setText("Score: 100")
    print("updated text = " .. lbl:getText())
end

--@api-stub: lurek.ui.newPanel
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    print("type = " .. panel:type())
    print("child count = " .. panel:getChildCount())
    print("visible = " .. tostring(panel:isVisible()))
end

--@api-stub: LUiWidget:setPosition
do
    ---@type LButton
    local btn = lurek.ui.newButton("Pos Test")
    btn:setPosition(100, 50)
    local x, y = btn:getPosition()
    print("position = " .. x .. ", " .. y)
end

--@api-stub: LUiWidget:getPosition
do
    ---@type LButton
    local btn = lurek.ui.newButton("Pos Test")
    btn:setPosition(100, 50)
    local x, y = btn:getPosition()
    print("position = " .. x .. ", " .. y)
end

--@api-stub: LUiWidget:setSize
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setSize(300, 200)
    local w, h = panel:getSize()
    print("size = " .. w .. "x" .. h)
end

--@api-stub: LUiWidget:getSize
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setSize(300, 200)
    local w, h = panel:getSize()
    print("size = " .. w .. "x" .. h)
end

--@api-stub: LUiWidget:getRect
do
    local btn = lurek.ui.newButton("Bounds")
    btn:setPosition(50, 30)
    btn:setSize(120, 40)
    local x, y, w, h = btn:getRect()
    print("rect = " .. x .. "," .. y .. " " .. w .. "x" .. h)
end

--@api-stub: LUiWidget:isVisible
do
    ---@type LLabel
    local lbl = lurek.ui.newLabel("Toggle Me")
    print("visible = " .. tostring(lbl:isVisible()))
    lbl:setVisible(false)
    print("hidden = " .. tostring(lbl:isVisible()))
end

--@api-stub: LUiWidget:setVisible
do
    ---@type LLabel
    local lbl = lurek.ui.newLabel("Toggle Me")
    lbl:setVisible(false)
    print("hidden = " .. tostring(lbl:isVisible()))
end

--@api-stub: LUiWidget:isEnabled
do
    ---@type LButton
    local btn = lurek.ui.newButton("Action")
    print("enabled = " .. tostring(btn:isEnabled()))
    btn:setEnabled(false)
    print("disabled = " .. tostring(btn:isEnabled()))
end

--@api-stub: LUiWidget:setEnabled
do
    ---@type LButton
    local btn = lurek.ui.newButton("Action")
    btn:setEnabled(false)
    print("disabled = " .. tostring(btn:isEnabled()))
end

--@api-stub: LUiWidget:getAlpha
do
    local panel = lurek.ui.newPanel()
    print("alpha = " .. panel:getAlpha())
    panel:setAlpha(0.5)
    print("set to 50% = " .. panel:getAlpha())
    panel:setAlpha(1.0)
end

--@api-stub: LUiWidget:setAlpha
do
    local panel = lurek.ui.newPanel()
    print("alpha = " .. panel:getAlpha())
    panel:setAlpha(0.5)
    print("set to 50% = " .. panel:getAlpha())
    panel:setAlpha(1.0)
end

--@api-stub: LUiWidget:animateAlpha
do
    local btn = lurek.ui.newButton("Fade"); btn:setAlpha(1.0)
    btn:animateAlpha(0.0, 0.5)
    print("animating = " .. tostring(btn:isAnimating()))
    btn:animateAlpha(1.0, 0.3, true)
    print("fade with hide_on_complete")
end

--@api-stub: LUiWidget:fadeIn
do
    ---@type LLabel
    local lbl = lurek.ui.newLabel("Fading")
    lbl:setAlpha(0)
    lbl:fadeIn()
    print("fading in, animating = " .. tostring(lbl:isAnimating()))
end

--@api-stub: LUiWidget:fadeOut
do
    ---@type LLabel
    local lbl = lurek.ui.newLabel("Fading")
    lbl:fadeOut()
    print("fading out")
end

--@api-stub: LUiWidget:animatePosition
do
    local panel = lurek.ui.newPanel(); panel:setPosition(0, 0)
    panel:animatePosition(200, 100, 0.5); print("moving to 200,100 over 0.5s")
    panel:cancelAnimations()
    panel:slideIn(300, 0)
    print("sliding in from right")
end

--@api-stub: LUiWidget:slideIn
do
    local panel = lurek.ui.newPanel(); panel:setPosition(0, 0)
    panel:animatePosition(200, 100, 0.5); print("moving to 200,100 over 0.5s")
    panel:cancelAnimations()
    panel:slideIn(300, 0)
    print("sliding in from right")
end

--@api-stub: LUiWidget:slideOut
do
    local panel = lurek.ui.newPanel(); panel:setPosition(0, 0)
    panel:animatePosition(200, 100, 0.5); print("moving to 200,100 over 0.5s")
    panel:cancelAnimations()
    panel:slideIn(300, 0)
    print("sliding in from right")
end

--@api-stub: LUiWidget:setId
do
    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    print("id = " .. btn:getId())
    print("tooltip = " .. btn:getTooltip())
end

--@api-stub: LUiWidget:getId
do
    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    print("id = " .. btn:getId())
    print("tooltip = " .. btn:getTooltip())
end

--@api-stub: LUiWidget:setTooltip
do
    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    print("id = " .. btn:getId())
    print("tooltip = " .. btn:getTooltip())
end

--@api-stub: LUiWidget:getTooltip
do
    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    print("id = " .. btn:getId())
    print("tooltip = " .. btn:getTooltip())
end

--@api-stub: LUiWidget:setZOrder
do
    local front = lurek.ui.newPanel(); local back = lurek.ui.newPanel()
    front:setZOrder(10)
    back:setZOrder(1)
    print("front z = " .. front:getZOrder())
    print("back z = " .. back:getZOrder())
end

--@api-stub: LUiWidget:getZOrder
do
    local front = lurek.ui.newPanel(); local back = lurek.ui.newPanel()
    front:setZOrder(10)
    back:setZOrder(1)
    print("front z = " .. front:getZOrder())
    print("back z = " .. back:getZOrder())
end

--@api-stub: LUiWidget:containsPoint
do
    local btn = lurek.ui.newButton("Hit Test")
    btn:setPosition(50, 50)
    btn:setSize(100, 40)
    print("(75,60) inside = " .. tostring(btn:containsPoint(75, 60)))
    print("(200,200) inside = " .. tostring(btn:containsPoint(200, 200)))
end

--@api-stub: LUiWidget:getState
do
    ---@type LButton
    local btn = lurek.ui.newButton("State")
    local state = btn:getState()
    print("state = " .. state)
end

--@api-stub: lurek.ui.getRoot
do
    local root = lurek.ui.getRoot()
    print("root = " .. tostring(root))
    print("widget count = " .. lurek.ui.getWidgetCount())
end

--@api-stub: lurek.ui.update
do
    lurek.ui.update(1 / 60)
    lurek.ui.draw()
    print("UI frame processed")
end

--- UI Module Part 2: layout, containers (DockPanel, SplitPanel, ScrollPanel), flex, margin, padding

--@api-stub: lurek.ui.newLayout
do
    local row = lurek.ui.newLayout("horizontal"); print("type = " .. row:type())
    print("direction = " .. row:getDirection()); print("spacing = " .. row:getSpacing())
    local col = lurek.ui.newLayout("vertical"); col:setSpacing(10)
    print("direction = " .. col:getDirection())
    print("spacing = " .. col:getSpacing())
end

--@api-stub: LLayout:setDirection
do
    ---@type LLayout
    local grid = lurek.ui.newLayout("grid")
    grid:setColumns(3)
    grid:setSpacing(5)
    print("direction = " .. grid:getDirection())
end

--@api-stub: LLayout:setColumns
do
    ---@type LLayout
    local grid = lurek.ui.newLayout("grid")
    grid:setColumns(3)
    grid:setSpacing(5)
    print("direction = " .. grid:getDirection())
end

--@api-stub: LLayout:setAlign
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setAlign("center")
    print("align = " .. layout:getAlign())
    layout:setAlign("stretch")
    print("align = " .. layout:getAlign())
end

--@api-stub: LLayout:getAlign
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setAlign("center")
    print("align = " .. layout:getAlign())
    layout:setAlign("stretch")
    print("align = " .. layout:getAlign())
end

--@api-stub: LLayout:setJustify
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setJustify("space-between")
    print("justify = " .. layout:getJustify())
    layout:setJustify("center")
    print("justify = " .. layout:getJustify())
end

--@api-stub: LLayout:getJustify
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setJustify("space-between")
    print("justify = " .. layout:getJustify())
    layout:setJustify("center")
    print("justify = " .. layout:getJustify())
end

--@api-stub: LLayout:setWrap
do
    ---@type LLayout
    local layout = lurek.ui.newLayout("horizontal")
    print("wrap = " .. tostring(layout:getWrap()))
    layout:setWrap(true)
    print("wrap enabled = " .. tostring(layout:getWrap()))
end

--@api-stub: LLayout:getWrap
do
    ---@type LLayout
    local layout = lurek.ui.newLayout("horizontal")
    print("wrap = " .. tostring(layout:getWrap()))
    layout:setWrap(true)
    print("wrap enabled = " .. tostring(layout:getWrap()))
end

--@api-stub: LUiWidget:addChild
do
    local layout = lurek.ui.newLayout("vertical"); local btn1 = lurek.ui.newButton("First")
    local btn2 = lurek.ui.newButton("Second"); local btn3 = lurek.ui.newButton("Third")
    layout:addChild(btn1); layout:addChild(btn2)
    layout:addChild(btn3); print("children = " .. layout:getChildCount())
    layout:removeChild(btn2); print("after remove = " .. layout:getChildCount())
end

--@api-stub: LUiWidget:removeChild
do
    local layout = lurek.ui.newLayout("vertical"); local btn1 = lurek.ui.newButton("First")
    local btn2 = lurek.ui.newButton("Second"); local btn3 = lurek.ui.newButton("Third")
    layout:addChild(btn1); layout:addChild(btn2)
    layout:addChild(btn3); print("children = " .. layout:getChildCount())
    layout:removeChild(btn2); print("after remove = " .. layout:getChildCount())
end

--@api-stub: LUiWidget:getChildCount
do
    local layout = lurek.ui.newLayout("vertical"); local btn1 = lurek.ui.newButton("First")
    local btn2 = lurek.ui.newButton("Second"); local btn3 = lurek.ui.newButton("Third")
    layout:addChild(btn1); layout:addChild(btn2)
    layout:addChild(btn3); print("children = " .. layout:getChildCount())
    layout:removeChild(btn2); print("after remove = " .. layout:getChildCount())
end

--@api-stub: LUiWidget:getChildren
do
    local panel = lurek.ui.newPanel(); panel:addChild(lurek.ui.newLabel("A"))
    panel:addChild(lurek.ui.newLabel("B"))
    panel:addChild(lurek.ui.newLabel("C"))
    local children = panel:getChildren()
    print("child list length = " .. #children)
end

--@api-stub: LUiWidget:setMargin
do
    local btn = lurek.ui.newButton("Margin"); btn:setMargin(10, 20, 10, 20)
    local top, right, bottom, left = btn:getMargin(); print("margin = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
    btn:setMargin(5)
    top, right, bottom, left = btn:getMargin()
    print("uniform = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
end

--@api-stub: LUiWidget:getMargin
do
    local btn = lurek.ui.newButton("Margin"); btn:setMargin(10, 20, 10, 20)
    local top, right, bottom, left = btn:getMargin(); print("margin = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
    btn:setMargin(5)
    top, right, bottom, left = btn:getMargin()
    print("uniform = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
end

--@api-stub: LUiWidget:setPadding
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setPadding(8, 16, 8, 16)
    local top, right, bottom, left = panel:getPadding()
    print("padding = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
end

--@api-stub: LUiWidget:getPadding
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setPadding(8, 16, 8, 16)
    local top, right, bottom, left = panel:getPadding()
    print("padding = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
end

--@api-stub: LUiWidget:setFlexGrow
do
    local row = lurek.ui.newLayout("horizontal"); local left = lurek.ui.newPanel()
    left:setFlexGrow(1); local right = lurek.ui.newPanel()
    right:setFlexGrow(2); row:addChild(left)
    row:addChild(right); print("left grow = " .. left:getFlexGrow())
    print("right grow = " .. right:getFlexGrow())
end

--@api-stub: LUiWidget:getFlexGrow
do
    local row = lurek.ui.newLayout("horizontal"); local left = lurek.ui.newPanel()
    left:setFlexGrow(1); local right = lurek.ui.newPanel()
    right:setFlexGrow(2); row:addChild(left)
    row:addChild(right); print("left grow = " .. left:getFlexGrow())
    print("right grow = " .. right:getFlexGrow())
end

--@api-stub: LUiWidget:setFlexShrink
do
    local btn = lurek.ui.newButton("Shrinkable")
    btn:setFlexShrink(0)
    print("shrink = " .. btn:getFlexShrink())
    btn:setFlexShrink(1)
    print("shrink = " .. btn:getFlexShrink())
end

--@api-stub: LUiWidget:getFlexShrink
do
    local btn = lurek.ui.newButton("Shrinkable")
    btn:setFlexShrink(0)
    print("shrink = " .. btn:getFlexShrink())
    btn:setFlexShrink(1)
    print("shrink = " .. btn:getFlexShrink())
end

--@api-stub: LUiWidget:setMinSize
do
    local panel = lurek.ui.newPanel(); panel:setMinSize(100, 50)
    local minW, minH = panel:getMinSize(); print("min = " .. minW .. "x" .. minH)
    panel:setMaxSize(400, 300)
    local maxW, maxH = panel:getMaxSize()
    print("max = " .. maxW .. "x" .. maxH)
end

--@api-stub: LUiWidget:getMinSize
do
    local panel = lurek.ui.newPanel(); panel:setMinSize(100, 50)
    local minW, minH = panel:getMinSize(); print("min = " .. minW .. "x" .. minH)
    panel:setMaxSize(400, 300)
    local maxW, maxH = panel:getMaxSize()
    print("max = " .. maxW .. "x" .. maxH)
end

--@api-stub: LUiWidget:setMaxSize
do
    local panel = lurek.ui.newPanel(); panel:setMinSize(100, 50)
    local minW, minH = panel:getMinSize(); print("min = " .. minW .. "x" .. minH)
    panel:setMaxSize(400, 300)
    local maxW, maxH = panel:getMaxSize()
    print("max = " .. maxW .. "x" .. maxH)
end

--@api-stub: LUiWidget:getMaxSize
do
    local panel = lurek.ui.newPanel(); panel:setMinSize(100, 50)
    local minW, minH = panel:getMinSize(); print("min = " .. minW .. "x" .. minH)
    panel:setMaxSize(400, 300)
    local maxW, maxH = panel:getMaxSize()
    print("max = " .. maxW .. "x" .. maxH)
end

--@api-stub: LUiWidget:setAnchor
do
    local btn = lurek.ui.newButton("Anchored"); btn:setAnchor(10, 10, 10, nil)
    print("anchored left=10, top=10, right=10")
    btn:clearAnchor()
    btn:setAnchorCenter(0.5, 0.5)
    print("centered in parent")
end

--@api-stub: LUiWidget:setAnchorCenter
do
    local btn = lurek.ui.newButton("Anchored"); btn:setAnchor(10, 10, 10, nil)
    print("anchored left=10, top=10, right=10")
    btn:clearAnchor()
    btn:setAnchorCenter(0.5, 0.5)
    print("centered in parent")
end

--@api-stub: LUiWidget:clearAnchor
do
    local btn = lurek.ui.newButton("Anchored"); btn:setAnchor(10, 10, 10, nil)
    print("anchored left=10, top=10, right=10")
    btn:clearAnchor()
    btn:setAnchorCenter(0.5, 0.5)
    print("centered in parent")
end

--@api-stub: lurek.ui.newDockPanel
do
    local dock = lurek.ui.newDockPanel(); print("type = " .. dock:type()); local header = lurek.ui.newPanel()
    header:setSize(0, 60); dock:addChild(header); dock:dock(header._idx, "top")
    local sidebar = lurek.ui.newPanel(); sidebar:setSize(200, 0); dock:addChild(sidebar)
    dock:dock(sidebar._idx, "left"); dock:setSplitSize("left", 200); dock:setSplitSize("top", 60)
    print("docked count = " .. dock:getDockedCount()); print("left size = " .. dock:getSplitSize("left"))
end

--@api-stub: LDockPanel:undock
do
    local dock = lurek.ui.newDockPanel(); local footer = lurek.ui.newPanel()
    dock:addChild(footer); dock:dock(footer._idx, "bottom")
    print("docked = " .. dock:getDockedCount())
    dock:undock(footer._idx)
    print("after undock = " .. dock:getDockedCount())
end

--@api-stub: lurek.ui.newSplitPanel
do
    local split = lurek.ui.newSplitPanel("horizontal"); print("type = " .. split:type()); print("orientation = " .. split:getOrientation())
    local left = lurek.ui.newPanel(); local right = lurek.ui.newPanel()
    split:setFirstChild(left._idx); split:setSecondChild(right._idx)
    split:setSplitPosition(0.3); print("split at " .. split:getSplitPosition())
    split:setMinPanelSize(100); print("min panel = " .. split:getMinPanelSize())
end

--@api-stub: lurek.ui.newScrollPanel
do
    local scroll = lurek.ui.newScrollPanel(); print("type = " .. scroll:type())
    scroll:setContentSize(1200, 2000); local cw, ch = scroll:getContentSize()
    print("content size = " .. cw .. "x" .. ch); scroll:setScrollPosition(0, 100)
    local sx, sy = scroll:getScrollPosition(); print("scroll pos = " .. sx .. ", " .. sy)
    local mx, my = scroll:getMaxScroll(); print("max scroll = " .. mx .. ", " .. my)
end

--@api-stub: LScrollPanel:setScrollSpeed
do
    ---@type LScrollPanel
    local scroll = lurek.ui.newScrollPanel()
    scroll:setScrollSpeed(30)
    print("scroll speed = " .. scroll:getScrollSpeed())
end

--@api-stub: LScrollPanel:getScrollSpeed
do
    ---@type LScrollPanel
    local scroll = lurek.ui.newScrollPanel()
    scroll:setScrollSpeed(30)
    print("scroll speed = " .. scroll:getScrollSpeed())
end

--@api-stub: LUiWidget:findById
do
    local root = lurek.ui.newLayout("vertical"); local btn = lurek.ui.newButton("Find Me")
    btn:setId("target_btn")
    root:addChild(btn)
    local found = root:findById("target_btn")
    print("found = " .. tostring(found ~= nil))
end

--- UI Module Part 3: input widgets â€” TextInput, Checkbox, Slider, SpinBox, Switch, ComboBox


--@api-stub: lurek.ui.newTextInput
do
    local input = lurek.ui.newTextInput()
    print("type = " .. input:type())
    print("text = '" .. input:getText() .. "'")
    input:setText("Hello")
    print("set text = " .. input:getText())
end

--@api-stub: LTextInput:setPlaceholder
do
    ---@type LTextInput
    local input = lurek.ui.newTextInput()
    input:setPlaceholder("Enter your name...")
    print("placeholder = " .. input:getPlaceholder())
end

--@api-stub: LTextInput:getPlaceholder
do
    ---@type LTextInput
    local input = lurek.ui.newTextInput()
    input:setPlaceholder("Enter your name...")
    print("placeholder = " .. input:getPlaceholder())
end

--@api-stub: LTextInput:setMaxLength
do
    local input = lurek.ui.newTextInput(); input:setMaxLength(50)
    input:setText("Short text")
    local pos = input:getCursorPosition()
    print("cursor at = " .. pos)
    print("focused = " .. tostring(input:isFocused()))
end

--@api-stub: LTextInput:getCursorPosition
do
    local input = lurek.ui.newTextInput(); input:setMaxLength(50)
    input:setText("Short text")
    local pos = input:getCursorPosition()
    print("cursor at = " .. pos)
    print("focused = " .. tostring(input:isFocused()))
end

--@api-stub: lurek.ui.newCheckbox
do
    ---@type LCheckbox
    local cb = lurek.ui.newCheckbox("Enable Sound")
    print("type = " .. cb:type())
    print("text = " .. cb:getText())
    print("checked = " .. tostring(cb:isChecked()))
end

--@api-stub: LCheckbox:setChecked
do
    local cb = lurek.ui.newCheckbox("Option A"); cb:setChecked(true)
    print("checked = " .. tostring(cb:isChecked())); cb:setText("Option B")
    print("text = " .. cb:getText())
    cb:setChecked(false)
    print("unchecked = " .. tostring(cb:isChecked()))
end

--@api-stub: LCheckbox:setText
do
    local cb = lurek.ui.newCheckbox("Option A"); cb:setChecked(true)
    print("checked = " .. tostring(cb:isChecked())); cb:setText("Option B")
    print("text = " .. cb:getText())
    cb:setChecked(false)
    print("unchecked = " .. tostring(cb:isChecked()))
end

--@api-stub: LCheckbox:setOnChange
do
    ---@type LCheckbox
    local cb = lurek.ui.newCheckbox("Fullscreen")
    cb:setOnChange(function()
        print("checkbox changed, now = " .. tostring(cb:isChecked()))
    end)
    print("change callback registered")
end

--@api-stub: lurek.ui.newSlider
do
    local slider = lurek.ui.newSlider(0, 100)
    print("type = " .. slider:type())
    print("min = " .. slider:getMin())
    print("max = " .. slider:getMax())
    print("value = " .. slider:getValue())
end

--@api-stub: LSlider:setValue
do
    local slider = lurek.ui.newSlider(0, 1); slider:setStep(0.1)
    slider:setValue(0.5)
    print("value = " .. slider:getValue())
    slider:setValue(1.5)
    print("clamped = " .. slider:getValue())
end

--@api-stub: LSlider:setStep
do
    local slider = lurek.ui.newSlider(0, 1); slider:setStep(0.1)
    slider:setValue(0.5)
    print("value = " .. slider:getValue())
    slider:setValue(1.5)
    print("clamped = " .. slider:getValue())
end

--@api-stub: LSlider:setRange
do
    local slider = lurek.ui.newSlider(0, 10)
    slider:setValue(5)
    print("before: " .. slider:getMin() .. " to " .. slider:getMax() .. " val=" .. slider:getValue())
    slider:setRange(0, 100)
    print("after: " .. slider:getMin() .. " to " .. slider:getMax() .. " val=" .. slider:getValue())
end

--@api-stub: lurek.ui.newSpinBox
do
    local spin = lurek.ui.newSpinBox(1, 99)
    print("type = " .. spin:type())
    print("value = " .. spin:getValue())
    spin:setValue(50)
    print("set to 50 = " .. spin:getValue())
end

--@api-stub: LSpinBox:increment
do
    local spin = lurek.ui.newSpinBox(0, 100); spin:setValue(10)
    spin:setStep(5); spin:increment()
    print("after increment = " .. spin:getValue()); spin:decrement()
    spin:decrement()
    print("after 2 decrements = " .. spin:getValue())
end

--@api-stub: LSpinBox:decrement
do
    local spin = lurek.ui.newSpinBox(0, 100); spin:setValue(10)
    spin:setStep(5); spin:increment()
    print("after increment = " .. spin:getValue()); spin:decrement()
    spin:decrement()
    print("after 2 decrements = " .. spin:getValue())
end

--@api-stub: LSpinBox:setStep
do
    local spin = lurek.ui.newSpinBox(0, 100); spin:setValue(10)
    spin:setStep(5); spin:increment()
    print("after increment = " .. spin:getValue()); spin:decrement()
    spin:decrement()
    print("after 2 decrements = " .. spin:getValue())
end

--@api-stub: LSpinBox:setRange
do
    ---@type LSpinBox
    local spin = lurek.ui.newSpinBox(0, 10)
    spin:setValue(8)
    spin:setRange(0, 5)
    print("clamped to range = " .. spin:getValue())
end

--@api-stub: lurek.ui.newSwitch
do
    ---@type LSwitch
    local sw = lurek.ui.newSwitch(false)
    print("type = " .. sw:type())
    print("on = " .. tostring(sw:isOn()))
end

--@api-stub: LSwitch:setOn
do
    local sw = lurek.ui.newSwitch(true); print("initial = " .. tostring(sw:isOn()))
    sw:toggle()
    print("toggled = " .. tostring(sw:isOn()))
    sw:setOn(true)
    print("forced on = " .. tostring(sw:isOn()))
end

--@api-stub: LSwitch:toggle
do
    local sw = lurek.ui.newSwitch(true); print("initial = " .. tostring(sw:isOn()))
    sw:toggle()
    print("toggled = " .. tostring(sw:isOn()))
    sw:setOn(true)
    print("forced on = " .. tostring(sw:isOn()))
end

--@api-stub: lurek.ui.newComboBox
do
    ---@type LComboBox
    local combo = lurek.ui.newComboBox()
    print("type = " .. combo:type())
    print("items = " .. combo:getItemCount())
end

--@api-stub: LComboBox:addItem
do
    local combo = lurek.ui.newComboBox(); combo:addItem("Easy")
    combo:addItem("Normal"); combo:addItem("Hard")
    combo:addItem("Nightmare"); print("item count = " .. combo:getItemCount())
    print("item 2 = " .. combo:getItem(2))
    print("item 4 = " .. combo:getItem(4))
end

--@api-stub: LComboBox:getItem
do
    local combo = lurek.ui.newComboBox(); combo:addItem("Easy")
    combo:addItem("Normal"); combo:addItem("Hard")
    combo:addItem("Nightmare"); print("item count = " .. combo:getItemCount())
    print("item 2 = " .. combo:getItem(2))
    print("item 4 = " .. combo:getItem(4))
end

--@api-stub: LComboBox:getItemCount
do
    local combo = lurek.ui.newComboBox(); combo:addItem("Easy")
    combo:addItem("Normal"); combo:addItem("Hard")
    combo:addItem("Nightmare"); print("item count = " .. combo:getItemCount())
    print("item 2 = " .. combo:getItem(2))
    print("item 4 = " .. combo:getItem(4))
end

--@api-stub: LComboBox:getSelectedIndex
do
    local combo = lurek.ui.newComboBox(); combo:addItem("Red")
    combo:addItem("Green"); combo:addItem("Blue")
    local idx = combo:getSelectedIndex(); print("selected index = " .. idx)
    local item = combo:getSelectedItem(); print("selected item = " .. tostring(item))
    combo:clearItems(); print("after clear = " .. combo:getItemCount())
end

--@api-stub: LComboBox:getSelectedItem
do
    local combo = lurek.ui.newComboBox(); combo:addItem("Red")
    combo:addItem("Green"); combo:addItem("Blue")
    local idx = combo:getSelectedIndex(); print("selected index = " .. idx)
    local item = combo:getSelectedItem(); print("selected item = " .. tostring(item))
    combo:clearItems(); print("after clear = " .. combo:getItemCount())
end

--@api-stub: LComboBox:clearItems
do
    local combo = lurek.ui.newComboBox(); combo:addItem("Red")
    combo:addItem("Green"); combo:addItem("Blue")
    local idx = combo:getSelectedIndex(); print("selected index = " .. idx)
    local item = combo:getSelectedItem(); print("selected item = " .. tostring(item))
    combo:clearItems(); print("after clear = " .. combo:getItemCount())
end

--@api-stub: lurek.ui.setFocus
do
    local input = lurek.ui.newTextInput(); lurek.ui.setFocus(input)
    local focused = lurek.ui.getFocus(); print("focus set, has focus = " .. tostring(focused ~= nil))
    lurek.ui.clearFocus()
    focused = lurek.ui.getFocus()
    print("after clear = " .. tostring(focused))
end

--@api-stub: lurek.ui.focusNext
do
    local a = lurek.ui.newTextInput(); local b = lurek.ui.newTextInput()
    local c = lurek.ui.newTextInput(); lurek.ui.setFocus(a)
    lurek.ui.focusNext(); print("moved focus forward")
    lurek.ui.focusPrev()
    print("moved focus back")
end

--- UI Module Part 4: lists, menus, tabs, accordion


--@api-stub: lurek.ui.newList
do
    ---@type LListBox
    local list = lurek.ui.newList()
    print("type = " .. list:type())
    print("items = " .. list:getItemCount())
end

--@api-stub: LListBox:addItem
do
    local list = lurek.ui.newList(); list:addItem("Sword")
    list:addItem("Shield"); list:addItem("Potion")
    list:addItem("Scroll"); print("count = " .. list:getItemCount())
    print("item 1 = " .. list:getItem(1))
    print("item 3 = " .. list:getItem(3))
end

--@api-stub: LListBox:getItem
do
    local list = lurek.ui.newList(); list:addItem("Sword")
    list:addItem("Shield"); list:addItem("Potion")
    list:addItem("Scroll"); print("count = " .. list:getItemCount())
    print("item 1 = " .. list:getItem(1))
    print("item 3 = " .. list:getItem(3))
end

--@api-stub: LListBox:getItemCount
do
    local list = lurek.ui.newList(); list:addItem("Sword")
    list:addItem("Shield"); list:addItem("Potion")
    list:addItem("Scroll"); print("count = " .. list:getItemCount())
    print("item 1 = " .. list:getItem(1))
    print("item 3 = " .. list:getItem(3))
end

--@api-stub: LListBox:setSelectedIndex
do
    local list = lurek.ui.newList(); list:addItem("Option A")
    list:addItem("Option B"); list:addItem("Option C")
    list:setSelectedIndex(2); print("selected = " .. list:getSelectedIndex())
    list:setSelectedIndex(3)
    print("changed to = " .. list:getSelectedIndex())
end

--@api-stub: LListBox:getSelectedIndex
do
    local list = lurek.ui.newList(); list:addItem("Option A")
    list:addItem("Option B"); list:addItem("Option C")
    list:setSelectedIndex(2); print("selected = " .. list:getSelectedIndex())
    list:setSelectedIndex(3)
    print("changed to = " .. list:getSelectedIndex())
end

--@api-stub: LListBox:removeItem
do
    local list = lurek.ui.newList(); list:addItem("First")
    list:addItem("Second"); list:addItem("Third")
    list:setItemHeight(30); list:removeItem(2)
    print("after remove: count=" .. list:getItemCount()); print("item 2 now = " .. list:getItem(2))
    list:clearItems(); print("after clear = " .. list:getItemCount())
end

--@api-stub: LListBox:clearItems
do
    local list = lurek.ui.newList(); list:addItem("First")
    list:addItem("Second"); list:addItem("Third")
    list:setItemHeight(30); list:removeItem(2)
    print("after remove: count=" .. list:getItemCount()); print("item 2 now = " .. list:getItem(2))
    list:clearItems(); print("after clear = " .. list:getItemCount())
end

--@api-stub: LListBox:setItemHeight
do
    local list = lurek.ui.newList(); list:addItem("First")
    list:addItem("Second"); list:addItem("Third")
    list:setItemHeight(30); list:removeItem(2)
    print("after remove: count=" .. list:getItemCount()); print("item 2 now = " .. list:getItem(2))
    list:clearItems(); print("after clear = " .. list:getItemCount())
end

--@api-stub: lurek.ui.newMenuBar
do
    ---@type LMenuBar
    local bar = lurek.ui.newMenuBar()
    print("type = " .. bar:type())
    print("menu count = " .. bar:getMenuCount())
end

--@api-stub: lurek.ui.newMenuItem
do
    local item = lurek.ui.newMenuItem("File")
    print("type = " .. item:type())
    print("text = " .. item:getText())
    item:setShortcut("Ctrl+F")
    print("shortcut = " .. item:getShortcut())
end

--@api-stub: LMenuItem:setText
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

--@api-stub: LMenuItem:setOnClick
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

--@api-stub: LMenuItem:setChecked
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

--@api-stub: LMenuItem:isChecked
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
do
    local fileMenu = lurek.ui.newMenuItem("File"); local openItem = lurek.ui.newMenuItem("Open"); openItem:setShortcut("Ctrl+O")
    local saveItem = lurek.ui.newMenuItem("Save"); saveItem:setShortcut("Ctrl+S")
    local exitItem = lurek.ui.newMenuItem("Exit"); fileMenu:addSubItem(openItem._idx)
    fileMenu:addSubItem(saveItem._idx); fileMenu:addSubItem(exitItem._idx)
    local subs = fileMenu:getSubItems(); print("File has " .. #subs .. " sub-items")
end

--@api-stub: LMenuItem:getSubItems
do
    local fileMenu = lurek.ui.newMenuItem("File"); local openItem = lurek.ui.newMenuItem("Open"); openItem:setShortcut("Ctrl+O")
    local saveItem = lurek.ui.newMenuItem("Save"); saveItem:setShortcut("Ctrl+S")
    local exitItem = lurek.ui.newMenuItem("Exit"); fileMenu:addSubItem(openItem._idx)
    fileMenu:addSubItem(saveItem._idx); fileMenu:addSubItem(exitItem._idx)
    local subs = fileMenu:getSubItems(); print("File has " .. #subs .. " sub-items")
end

--@api-stub: LMenuBar:addMenu
do
    local bar = lurek.ui.newMenuBar(); local fileMenu = lurek.ui.newMenuItem("File")
    local editMenu = lurek.ui.newMenuItem("Edit"); local viewMenu = lurek.ui.newMenuItem("View")
    bar:addMenu(fileMenu._idx); bar:addMenu(editMenu._idx)
    bar:addMenu(viewMenu._idx); print("menus = " .. bar:getMenuCount())
    local menus = bar:getMenus(); print("menu indices: " .. #menus .. " entries")
end

--@api-stub: LMenuBar:getMenuCount
do
    local bar = lurek.ui.newMenuBar(); local fileMenu = lurek.ui.newMenuItem("File")
    local editMenu = lurek.ui.newMenuItem("Edit"); local viewMenu = lurek.ui.newMenuItem("View")
    bar:addMenu(fileMenu._idx); bar:addMenu(editMenu._idx)
    bar:addMenu(viewMenu._idx); print("menus = " .. bar:getMenuCount())
    local menus = bar:getMenus(); print("menu indices: " .. #menus .. " entries")
end

--@api-stub: LMenuBar:getMenus
do
    local bar = lurek.ui.newMenuBar(); local fileMenu = lurek.ui.newMenuItem("File")
    local editMenu = lurek.ui.newMenuItem("Edit"); local viewMenu = lurek.ui.newMenuItem("View")
    bar:addMenu(fileMenu._idx); bar:addMenu(editMenu._idx)
    bar:addMenu(viewMenu._idx); print("menus = " .. bar:getMenuCount())
    local menus = bar:getMenus(); print("menu indices: " .. #menus .. " entries")
end

--@api-stub: LMenuBar:removeMenu
do
    local bar = lurek.ui.newMenuBar(); local m = lurek.ui.newMenuItem("Tools")
    bar:addMenu(m._idx); print("before remove = " .. bar:getMenuCount())
    local ok = bar:removeMenu(m._idx)
    print("removed = " .. tostring(ok))
    print("after remove = " .. bar:getMenuCount())
end

--@api-stub: lurek.ui.newTabBar
do
    ---@type LTabBar
    local tabs = lurek.ui.newTabBar()
    print("type = " .. tabs:type())
    print("tab count = " .. tabs:getTabCount())
end

--@api-stub: LTabBar:addTab
do
    local tabs = lurek.ui.newTabBar(); tabs:addTab("General")
    tabs:addTab("Graphics"); tabs:addTab("Audio")
    tabs:addTab("Controls"); print("count = " .. tabs:getTabCount())
    print("tab 1 = " .. tabs:getTab(1))
    print("tab 3 = " .. tabs:getTab(3))
end

--@api-stub: LTabBar:getTab
do
    local tabs = lurek.ui.newTabBar(); tabs:addTab("General")
    tabs:addTab("Graphics"); tabs:addTab("Audio")
    tabs:addTab("Controls"); print("count = " .. tabs:getTabCount())
    print("tab 1 = " .. tabs:getTab(1))
    print("tab 3 = " .. tabs:getTab(3))
end

--@api-stub: LTabBar:getTabCount
do
    local tabs = lurek.ui.newTabBar(); tabs:addTab("General")
    tabs:addTab("Graphics"); tabs:addTab("Audio")
    tabs:addTab("Controls"); print("count = " .. tabs:getTabCount())
    print("tab 1 = " .. tabs:getTab(1))
    print("tab 3 = " .. tabs:getTab(3))
end

--@api-stub: LTabBar:setActiveTab
do
    local tabs = lurek.ui.newTabBar(); tabs:addTab("Home")
    tabs:addTab("Settings"); tabs:addTab("Help")
    tabs:setActiveTab(2); print("active = " .. tabs:getActiveTab())
    local ok = tabs:removeTab(3); print("removed Help = " .. tostring(ok))
    print("remaining = " .. tabs:getTabCount())
end

--@api-stub: LTabBar:getActiveTab
do
    local tabs = lurek.ui.newTabBar(); tabs:addTab("Home")
    tabs:addTab("Settings"); tabs:addTab("Help")
    tabs:setActiveTab(2); print("active = " .. tabs:getActiveTab())
    local ok = tabs:removeTab(3); print("removed Help = " .. tostring(ok))
    print("remaining = " .. tabs:getTabCount())
end

--@api-stub: LTabBar:removeTab
do
    local tabs = lurek.ui.newTabBar(); tabs:addTab("Home")
    tabs:addTab("Settings"); tabs:addTab("Help")
    tabs:setActiveTab(2); print("active = " .. tabs:getActiveTab())
    local ok = tabs:removeTab(3); print("removed Help = " .. tostring(ok))
    print("remaining = " .. tabs:getTabCount())
end

--@api-stub: lurek.ui.newAccordion
do
    ---@type LAccordion
    local acc = lurek.ui.newAccordion()
    print("type = " .. acc:type())
    print("sections = " .. acc:getSectionCount())
end

--@api-stub: LAccordion:addSection
do
    local acc = lurek.ui.newAccordion(); acc:addSection("Player Stats")
    acc:addSection("Inventory"); acc:addSection("Quest Log")
    print("sections = " .. acc:getSectionCount())
    print("section 1 = " .. acc:getSectionTitle(1))
    print("section 2 = " .. acc:getSectionTitle(2))
end

--@api-stub: LAccordion:getSectionCount
do
    local acc = lurek.ui.newAccordion(); acc:addSection("Player Stats")
    acc:addSection("Inventory"); acc:addSection("Quest Log")
    print("sections = " .. acc:getSectionCount())
    print("section 1 = " .. acc:getSectionTitle(1))
    print("section 2 = " .. acc:getSectionTitle(2))
end

--@api-stub: LAccordion:getSectionTitle
do
    local acc = lurek.ui.newAccordion(); acc:addSection("Player Stats")
    acc:addSection("Inventory"); acc:addSection("Quest Log")
    print("sections = " .. acc:getSectionCount())
    print("section 1 = " .. acc:getSectionTitle(1))
    print("section 2 = " .. acc:getSectionTitle(2))
end

--@api-stub: LAccordion:toggleSection
do
    local acc = lurek.ui.newAccordion(); acc:addSection("A"); acc:addSection("B")
    acc:addSection("C"); acc:setExclusive(true)
    print("exclusive = " .. tostring(acc:isExclusive())); acc:toggleSection(1)
    print("section 1 expanded = " .. tostring(acc:isSectionExpanded(1))); acc:toggleSection(2)
    print("section 1 after toggle 2 = " .. tostring(acc:isSectionExpanded(1))); print("section 2 expanded = " .. tostring(acc:isSectionExpanded(2)))
end

--@api-stub: LAccordion:isSectionExpanded
do
    local acc = lurek.ui.newAccordion(); acc:addSection("A"); acc:addSection("B")
    acc:addSection("C"); acc:setExclusive(true)
    print("exclusive = " .. tostring(acc:isExclusive())); acc:toggleSection(1)
    print("section 1 expanded = " .. tostring(acc:isSectionExpanded(1))); acc:toggleSection(2)
    print("section 1 after toggle 2 = " .. tostring(acc:isSectionExpanded(1))); print("section 2 expanded = " .. tostring(acc:isSectionExpanded(2)))
end

--@api-stub: LAccordion:setExclusive
do
    local acc = lurek.ui.newAccordion(); acc:addSection("A"); acc:addSection("B")
    acc:addSection("C"); acc:setExclusive(true)
    print("exclusive = " .. tostring(acc:isExclusive())); acc:toggleSection(1)
    print("section 1 expanded = " .. tostring(acc:isSectionExpanded(1))); acc:toggleSection(2)
    print("section 1 after toggle 2 = " .. tostring(acc:isSectionExpanded(1))); print("section 2 expanded = " .. tostring(acc:isSectionExpanded(2)))
end

--@api-stub: lurek.ui.newDialog
do
    local dlg = lurek.ui.newDialog("Confirm Action")
    dlg:setModal(true)
    dlg:addButton("OK")
    dlg:addButton("Cancel")
    dlg:setOnClose(function(idx) print("dialog closed, widget index:", idx)
    end)
    dlg:open()
    print("dialog title:", dlg:getTitle())
    print("is modal:", dlg:isModal())
    print("is open:", dlg:isOpen())

    -- Example usage for newDialog.
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
    local win = lurek.ui.newWindow("Editor")
    win:setDraggable(true)
    win:setResizable(true)
    win:setCloseable(true)
    win:setOnClose(function(idx) print("window closed, widget index:", idx)
    end)
    print("window title:", win:getTitle())
    print("is draggable:", win:isDraggable())
    print("is resizable:", win:isResizable())
    print("is closeable:", win:isCloseable())

    -- Example usage for newWindow.
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
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("save", "Save file")
    print("orientation:", tb:getOrientation())
end

--@api-stub: lurek.ui.newStatusBar
do
    local sb = lurek.ui.newStatusBar()
    sb:addSection("Ready", 150)
    print("section count:", sb:getSectionCount())
    print("section 1:", sb:getSectionText(1))
end

--@api-stub: lurek.ui.newProgressBar
do
    local bar = lurek.ui.newProgressBar(0, 100)
    bar:setValue(35)
    print("value:", bar:getValue())
    print("progress (normalized):", bar:getProgress())
end

--@api-stub: lurek.ui.newImageWidget
do
    local img = lurek.ui.newImageWidget(); img:setScaleMode("fit")
    print("scale mode:", img:getScaleMode())
    img:setTint(1.0, 0.8, 0.6, 0.9)
    local r, g, b, a = img:getTint()
    print("tint:", r, g, b, a)
end

--@api-stub: lurek.ui.newNinePatch
do
    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(128, 128)
    np:setInsets(16, 16, 16, 16)
    local w, h = np:getImageDimensions()
    print("image size:", w, h)
end

--@api-stub: lurek.ui.newBadge
do
    local badge = lurek.ui.newBadge(5)
    print("count:", badge:getCount())
    print("display:", badge:getDisplayText())
    badge:setCount(120)
    print("large count display:", badge:getDisplayText())
end

--@api-stub: lurek.ui.newSpacer
do
    local sp = lurek.ui.newSpacer(20, 10)
    sp:setSize(40, 20)
    local w, h = sp:getSize()
    print("spacer size:", w, h)
end

--@api-stub: lurek.ui.newSeparator
do
    local sep = lurek.ui.newSeparator(false)
    print("is vertical:", sep:isVertical())
    sep:setThickness(2)
    print("new thickness:", sep:getThickness())
end

--@api-stub: lurek.ui.newAreaChart
do
    local chart = lurek.ui.newAreaChart({ width = 400, height = 200, title = "CPU Usage" }); chart:addLayer("user", { 10, 25, 30, 45, 50, 40, 35 }, 0.2, 0.6, 1.0)
    chart:addLayer("system", { 5, 10, 15, 20, 15, 10, 8 }, 1.0, 0.4, 0.2)
    chart:setYMax(100)
    print("area chart type:", chart:type())
    print("is area chart:", chart:typeOf("LAreaChart"))
end

--@api-stub: lurek.ui.newBarChart
do
    local chart = lurek.ui.newBarChart({ width = 300, height = 200, title = "Sales" }); chart:addSeries("Q1", 0.2, 0.8, 0.4)
    chart:addSeries("Q2", 0.8, 0.2, 0.4); chart:addCategory("Widgets", { 150, 200 })
    chart:addCategory("Gadgets", { 90, 120 })
    chart:addCategory("Tools", { 60, 80 })
    print("bar chart type:", chart:type())
end

--@api-stub: lurek.ui.newLineChart
do
    local chart = lurek.ui.newLineChart({ width = 400, height = 250, title = "Temperature" }); chart:addSeries("indoor", { { x = 0, y = 20 }, { x = 6, y = 19 }, { x = 12, y = 22 }, { x = 18, y = 21 }, { x = 24, y = 20 } }, 1.0, 0.3, 0.3)
    chart:addSeries("outdoor", { { x = 0, y = 5 }, { x = 6, y = 3 }, { x = 12, y = 15 }, { x = 18, y = 10 }, { x = 24, y = 6 } }, 0.3, 0.3, 1.0)
    chart:setXMax(24)
    chart:setYMax(30)
    print("line chart type:", chart:type())
end

--@api-stub: lurek.ui.newPieChart
do
    local chart = lurek.ui.newPieChart({ width = 200, height = 200, title = "Market Share" }); chart:addSegment("Product A", 45, 0.2, 0.6, 1.0)
    chart:addSegment("Product B", 30, 1.0, 0.4, 0.2); chart:addSegment("Product C", 15, 0.3, 0.9, 0.3)
    chart:addSegment("Other", 10, 0.7, 0.7, 0.7)
    print("pie chart type:", chart:type())
    print("is pie chart:", chart:typeOf("LPieChart"))
end

--@api-stub: lurek.ui.newScatterPlot
do
    local chart = lurek.ui.newScatterPlot({ width = 400, height = 300, title = "Height vs Weight" }); chart:addSeries("male", { { x = 170, y = 70 }, { x = 180, y = 80 }, { x = 175, y = 75 }, { x = 185, y = 90 } }, 0.2, 0.5, 1.0)
    chart:addSeries("female", { { x = 160, y = 55 }, { x = 165, y = 60 }, { x = 170, y = 65 }, { x = 155, y = 50 } }, 1.0, 0.3, 0.6)
    chart:setXRange(150, 200)
    chart:setYRange(40, 100)
    print("scatter plot type:", chart:type())
end

--@api-stub: lurek.ui.newColorPicker
do
    local cp = lurek.ui.newColorPicker(); cp:setColor(0.8, 0.2, 0.5, 1.0)
    local r, g, b, a = cp:getColor()
    print("color:", r, g, b, a)
    cp:setColorMode("hsv")
    print("mode:", cp:getColorMode())
end

--@api-stub: lurek.ui.newRadioButton
do
    local rb1 = lurek.ui.newRadioButton("Small", "size_group"); local rb2 = lurek.ui.newRadioButton("Medium", "size_group")
    local rb3 = lurek.ui.newRadioButton("Large", "size_group"); rb2:setSelected(true)
    print("rb1 selected:", rb1:isSelected()); print("rb2 selected:", rb2:isSelected())
    print("rb2 group:", rb2:getGroup())
    print("rb2 text:", rb2:getText())
end

--@api-stub: lurek.ui.newTreeView
do
    local tree = lurek.ui.newTreeView()
    local root = tree:addNode("Project")
    tree:addNode("main.lua", root)
    print("total nodes:", tree:getNodeCount())
    print("root text:", tree:getNodeText(root))
end

--@api-stub: lurek.ui.newToast
do
    local toast = lurek.ui.newToast("File saved!", 2.5); print("message:", toast:getMessage())
    print("duration:", toast:getDuration()); toast:setMessage("Upload complete")
    toast:setDuration(4.0)
    print("updated message:", toast:getMessage())
    print("expired:", toast:isExpired())
end

--@api-stub: lurek.ui.newTooltipPanel
do
    local btn = lurek.ui.newButton("Hover me"); local tip = lurek.ui.newTooltipPanel("Click to submit form")
    tip:setDelay(0.5); tip:setTarget(1)
    print("tooltip text:", tip:getText()); print("delay:", tip:getDelay())
    print("target:", tip:getTarget()); tip:setText("Updated tooltip text")
    print("new text:", tip:getText())
end

--@api-stub: lurek.ui.newTheme
do
    local theme = lurek.ui.newTheme(); theme:setStyle("button", "normal", { bg_r = 0.2, bg_g = 0.2, bg_b = 0.3, bg_a = 1.0, fg_r = 1.0, fg_g = 1.0, fg_b = 1.0, fg_a = 1.0, })
    theme:setStyle("button", "hovered", { bg_r = 0.3, bg_g = 0.3, bg_b = 0.5, bg_a = 1.0, })
    lurek.ui.setTheme(theme)
    print("theme active:", lurek.ui.getTheme())
    print("theme type:", theme:type())
end

--@api-stub: lurek.ui.setTheme
do
    local theme = lurek.ui.newTheme(); theme:setStyle("button", "normal", { bg_r = 0.2, bg_g = 0.2, bg_b = 0.3, bg_a = 1.0, fg_r = 1.0, fg_g = 1.0, fg_b = 1.0, fg_a = 1.0, })
    theme:setStyle("button", "hovered", { bg_r = 0.3, bg_g = 0.3, bg_b = 0.5, bg_a = 1.0, })
    lurek.ui.setTheme(theme)
    print("theme active:", lurek.ui.getTheme())
    print("theme type:", theme:type())
end

--@api-stub: lurek.ui.getTheme
do
    local theme = lurek.ui.newTheme(); theme:setStyle("button", "normal", { bg_r = 0.2, bg_g = 0.2, bg_b = 0.3, bg_a = 1.0, fg_r = 1.0, fg_g = 1.0, fg_b = 1.0, fg_a = 1.0, })
    theme:setStyle("button", "hovered", { bg_r = 0.3, bg_g = 0.3, bg_b = 0.5, bg_a = 1.0, })
    lurek.ui.setTheme(theme)
    print("theme active:", lurek.ui.getTheme())
    print("theme type:", theme:type())
end

--@api-stub: lurek.ui.getFocus
do
    local btn1 = lurek.ui.newButton("First"); local btn2 = lurek.ui.newButton("Second")
    lurek.ui.setFocus(btn1); print("focused widget:", lurek.ui.getFocus())
    lurek.ui.focusNext(); print("after focusNext:", lurek.ui.getFocus())
    lurek.ui.focusPrev(); print("after focusPrev:", lurek.ui.getFocus())
    lurek.ui.clearFocus(); print("after clear:", lurek.ui.getFocus())
end

--@api-stub: lurek.ui.focusPrev
do
    local btn1 = lurek.ui.newButton("First"); local btn2 = lurek.ui.newButton("Second")
    lurek.ui.setFocus(btn1); print("focused widget:", lurek.ui.getFocus())
    lurek.ui.focusNext(); print("after focusNext:", lurek.ui.getFocus())
    lurek.ui.focusPrev(); print("after focusPrev:", lurek.ui.getFocus())
    lurek.ui.clearFocus(); print("after clear:", lurek.ui.getFocus())
end

--@api-stub: lurek.ui.clearFocus
do
    local btn1 = lurek.ui.newButton("First"); local btn2 = lurek.ui.newButton("Second")
    lurek.ui.setFocus(btn1); print("focused widget:", lurek.ui.getFocus())
    lurek.ui.focusNext(); print("after focusNext:", lurek.ui.getFocus())
    lurek.ui.focusPrev(); print("after focusPrev:", lurek.ui.getFocus())
    lurek.ui.clearFocus(); print("after clear:", lurek.ui.getFocus())
end

--@api-stub: lurek.ui.beginDrag
do
    local source = lurek.ui.newPanel(); local target = lurek.ui.newPanel()
    lurek.ui.beginDrag(source)
    print("active drag:", lurek.ui.getActiveDrag())
    lurek.ui.dropOn(target)
    print("after drop, active drag:", lurek.ui.getActiveDrag())
end

--@api-stub: lurek.ui.getActiveDrag
do
    local source = lurek.ui.newPanel(); local target = lurek.ui.newPanel()
    lurek.ui.beginDrag(source)
    print("active drag:", lurek.ui.getActiveDrag())
    lurek.ui.dropOn(target)
    print("after drop, active drag:", lurek.ui.getActiveDrag())
end

--@api-stub: lurek.ui.dropOn
do
    local source = lurek.ui.newPanel(); local target = lurek.ui.newPanel()
    lurek.ui.beginDrag(source)
    print("active drag:", lurek.ui.getActiveDrag())
    lurek.ui.dropOn(target)
    print("after drop, active drag:", lurek.ui.getActiveDrag())
end

--- UI Part 8: LAccordion, LColorPicker, LProgressBar, LMenuBar


--@api-stub: LAccordion:isExclusive
do
    local acc = lurek.ui.newAccordion(); print("type=" .. acc:type()); acc:addSection("Section A")
    acc:addSection("Section B"); print("count=" .. acc:getSectionCount()); print("title0=" .. acc:getSectionTitle(1))
    print("expanded0=" .. tostring(acc:isSectionExpanded(1))); acc:toggleSection(1)
    print("expanded0_after=" .. tostring(acc:isSectionExpanded(1))); print("exclusive=" .. tostring(acc:isExclusive()))
    acc:setExclusive(true); print("exclusive_after=" .. tostring(acc:isExclusive()))
end

--@api-stub: LColorPicker:getColor
do
    local cp = lurek.ui.newColorPicker(); print("type=" .. cp:type()); cp:setColor(255, 128, 0, 255)
    local r, g, b, a = cp:getColor(); print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    print("mode=" .. tostring(cp:getColorMode())); cp:setColorMode("hsv")
    print("mode_after=" .. cp:getColorMode()); print("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true); cp:setOnChange(function(r2, g2, b2, a2) print("changed") end)
end

--@api-stub: LColorPicker:getColorMode
do
    local cp = lurek.ui.newColorPicker(); print("type=" .. cp:type()); cp:setColor(255, 128, 0, 255)
    local r, g, b, a = cp:getColor(); print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    print("mode=" .. tostring(cp:getColorMode())); cp:setColorMode("hsv")
    print("mode_after=" .. cp:getColorMode()); print("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true); cp:setOnChange(function(r2, g2, b2, a2) print("changed") end)
end

--@api-stub: LColorPicker:getShowAlpha
do
    local cp = lurek.ui.newColorPicker(); print("type=" .. cp:type()); cp:setColor(255, 128, 0, 255)
    local r, g, b, a = cp:getColor(); print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    print("mode=" .. tostring(cp:getColorMode())); cp:setColorMode("hsv")
    print("mode_after=" .. cp:getColorMode()); print("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true); cp:setOnChange(function(r2, g2, b2, a2) print("changed") end)
end

--@api-stub: LColorPicker:setColor
do
    local cp = lurek.ui.newColorPicker(); print("type=" .. cp:type()); cp:setColor(255, 128, 0, 255)
    local r, g, b, a = cp:getColor(); print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    print("mode=" .. tostring(cp:getColorMode())); cp:setColorMode("hsv")
    print("mode_after=" .. cp:getColorMode()); print("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true); cp:setOnChange(function(r2, g2, b2, a2) print("changed") end)
end

--@api-stub: LColorPicker:setColorMode
do
    local cp = lurek.ui.newColorPicker(); print("type=" .. cp:type()); cp:setColor(255, 128, 0, 255)
    local r, g, b, a = cp:getColor(); print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    print("mode=" .. tostring(cp:getColorMode())); cp:setColorMode("hsv")
    print("mode_after=" .. cp:getColorMode()); print("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true); cp:setOnChange(function(r2, g2, b2, a2) print("changed") end)
end

--@api-stub: LColorPicker:setOnChange
do
    local cp = lurek.ui.newColorPicker(); print("type=" .. cp:type()); cp:setColor(255, 128, 0, 255)
    local r, g, b, a = cp:getColor(); print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    print("mode=" .. tostring(cp:getColorMode())); cp:setColorMode("hsv")
    print("mode_after=" .. cp:getColorMode()); print("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true); cp:setOnChange(function(r2, g2, b2, a2) print("changed") end)
end

--@api-stub: LColorPicker:setShowAlpha
do
    local cp = lurek.ui.newColorPicker(); print("type=" .. cp:type()); cp:setColor(255, 128, 0, 255)
    local r, g, b, a = cp:getColor(); print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    print("mode=" .. tostring(cp:getColorMode())); cp:setColorMode("hsv")
    print("mode_after=" .. cp:getColorMode()); print("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true); cp:setOnChange(function(r2, g2, b2, a2) print("changed") end)
end

--@api-stub: LProgressBar:getMax
do
    local pb = lurek.ui.newProgressBar(0, 100); print("type=" .. pb:type())
    print("min=" .. pb:getMin()); print("max=" .. pb:getMax())
    pb:setValue(75); print("value=" .. pb:getValue())
    print("progress=" .. pb:getProgress()); pb:setRange(0, 200)
    print("max_after=" .. pb:getMax())
end

--@api-stub: LProgressBar:getMin
do
    local pb = lurek.ui.newProgressBar(0, 100); print("type=" .. pb:type())
    print("min=" .. pb:getMin()); print("max=" .. pb:getMax())
    pb:setValue(75); print("value=" .. pb:getValue())
    print("progress=" .. pb:getProgress()); pb:setRange(0, 200)
    print("max_after=" .. pb:getMax())
end

--@api-stub: LProgressBar:getProgress
do
    local pb = lurek.ui.newProgressBar(0, 100); print("type=" .. pb:type())
    print("min=" .. pb:getMin()); print("max=" .. pb:getMax())
    pb:setValue(75); print("value=" .. pb:getValue())
    print("progress=" .. pb:getProgress()); pb:setRange(0, 200)
    print("max_after=" .. pb:getMax())
end

--@api-stub: LProgressBar:getValue
do
    local pb = lurek.ui.newProgressBar(0, 100); print("type=" .. pb:type())
    print("min=" .. pb:getMin()); print("max=" .. pb:getMax())
    pb:setValue(75); print("value=" .. pb:getValue())
    print("progress=" .. pb:getProgress()); pb:setRange(0, 200)
    print("max_after=" .. pb:getMax())
end

--@api-stub: LProgressBar:setRange
do
    local pb = lurek.ui.newProgressBar(0, 100); print("type=" .. pb:type())
    print("min=" .. pb:getMin()); print("max=" .. pb:getMax())
    pb:setValue(75); print("value=" .. pb:getValue())
    print("progress=" .. pb:getProgress()); pb:setRange(0, 200)
    print("max_after=" .. pb:getMax())
end

--@api-stub: LProgressBar:setValue
do
    local pb = lurek.ui.newProgressBar(0, 100); print("type=" .. pb:type())
    print("min=" .. pb:getMin()); print("max=" .. pb:getMax())
    pb:setValue(75); print("value=" .. pb:getValue())
    print("progress=" .. pb:getProgress()); pb:setRange(0, 200)
    print("max_after=" .. pb:getMax())
end

--- UI Part 9: LTabBar, LStatusBar, LToolbar


--@api-stub: LStatusBar:addSection
do
    local sb = lurek.ui.newStatusBar(); print("type=" .. sb:type())
    sb:addSection("Ready", 120); sb:addSection("Line 1", 80)
    print("sections=" .. sb:getSectionCount()); print("text1=" .. sb:getSectionText(1))
    sb:setSectionText(1, "Loading...")
    print("text1_after=" .. sb:getSectionText(1))
end

--@api-stub: LStatusBar:getSectionCount
do
    local sb = lurek.ui.newStatusBar(); print("type=" .. sb:type())
    sb:addSection("Ready", 120); sb:addSection("Line 1", 80)
    print("sections=" .. sb:getSectionCount()); print("text0=" .. sb:getSectionText(0))
    sb:setSectionText(0, "Loading...")
    print("text0_after=" .. sb:getSectionText(0))
end

--@api-stub: LStatusBar:getSectionText
do
    local sb = lurek.ui.newStatusBar(); print("type=" .. sb:type())
    sb:addSection("Ready", 120); sb:addSection("Line 1", 80)
    print("sections=" .. sb:getSectionCount()); print("text0=" .. sb:getSectionText(0))
    sb:setSectionText(0, "Loading...")
    print("text0_after=" .. sb:getSectionText(0))
end

--@api-stub: LStatusBar:setSectionText
do
    local sb = lurek.ui.newStatusBar(); print("type=" .. sb:type())
    sb:addSection("Ready", 120); sb:addSection("Line 1", 80)
    print("sections=" .. sb:getSectionCount()); print("text0=" .. sb:getSectionText(0))
    sb:setSectionText(0, "Loading...")
    print("text0_after=" .. sb:getSectionText(0))
end

--@api-stub: LToolbar:addButton
do
    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    print("btn=" .. tostring(bar:getButton("btn_save") ~= nil))
end

--@api-stub: LToolbar:addSeparator
do
    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    bar:addSeparator()
    print("separator added")
end

--@api-stub: LToolbar:getButton

do
    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    local btn = bar:getButton("btn_save")
    print("btn=" .. tostring(btn ~= nil))
end

--@api-stub: LToolbar:getOrientation
do
    local bar = lurek.ui.newToolbar("horizontal")
    print("orientation=" .. bar:getOrientation())
end

--@api-stub: LToolbar:isButtonToggled
do
    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    print("toggled=" .. tostring(bar:isButtonToggled("btn_save")))
end

--@api-stub: LToolbar:setButtonEnabled
do
    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_open", "Open file")
    bar:setButtonEnabled("btn_open", false)
    print("btn_open disabled")
end

--@api-stub: LToolbar:setButtonToggled
do
    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    bar:setButtonToggled("btn_save", true)
    print("toggled_after=" .. tostring(bar:isButtonToggled("btn_save")))
end

--@api-stub: LToolbar:setOrientation
do
    local bar = lurek.ui.newToolbar("horizontal")
    bar:setOrientation("vertical")
    print("orientation_after=" .. bar:getOrientation())
end

--@api-stub: lurek.ui.addToast
do
    lurek.ui.addToast({ message = "File saved successfully", duration = 3.0, type = "info" })
    print("toast added")
    local layout = lurek.ui.loadLayout({ type = "panel", children = {} })
    print("layout=" .. tostring(layout ~= nil))
end

--@api-stub: lurek.ui.loadLayout
do
    lurek.ui.addToast({ message = "File saved successfully", duration = 3.0, type = "info" })
    print("toast added")
    local layout = lurek.ui.loadLayout({ type = "panel", children = {} })
    print("layout=" .. tostring(layout ~= nil))
end

--- UI Part 10: LBadge, LDockPanel, LImageWidget, LNinePatch, LRadioButton, LSpinBox, LSplitPanel, LSwitch, LTable, LToast, LTooltipPanel, LTreeView


--@api-stub: LBadge:getCount
do
    local badge = lurek.ui.newBadge(3); print("type=" .. badge:type())
    print("count=" .. badge:getCount()); badge:setCount(7)
    print("count_after=" .. badge:getCount())
    local text = badge:getDisplayText()
    print("text=" .. tostring(text))
end

--@api-stub: LBadge:getDisplayText
do
    local badge = lurek.ui.newBadge(3); print("type=" .. badge:type())
    print("count=" .. badge:getCount()); badge:setCount(7)
    print("count_after=" .. badge:getCount())
    local text = badge:getDisplayText()
    print("text=" .. tostring(text))
end

--@api-stub: LBadge:setCount
do
    local badge = lurek.ui.newBadge(3); print("type=" .. badge:type())
    print("count=" .. badge:getCount()); badge:setCount(7)
    print("count_after=" .. badge:getCount())
    local text = badge:getDisplayText()
    print("text=" .. tostring(text))
end

--@api-stub: LDockPanel:dock
do
    local dp = lurek.ui.newDockPanel(); print("type=" .. dp:type())
    local child = lurek.ui.newPanel(); dp:dock(0, "left")
    print("docked=" .. dp:getDockedCount()); local sz = dp:getSplitSize("left")
    print("split_size=" .. tostring(sz)); dp:setSplitSize("left", 150)
    dp:undock(0); print("docked_after=" .. dp:getDockedCount())
end

--@api-stub: LDockPanel:getDockedCount
do
    local dp = lurek.ui.newDockPanel(); print("type=" .. dp:type())
    local child = lurek.ui.newPanel(); dp:dock(0, "left")
    print("docked=" .. dp:getDockedCount()); local sz = dp:getSplitSize("left")
    print("split_size=" .. tostring(sz)); dp:setSplitSize("left", 150)
    dp:undock(0); print("docked_after=" .. dp:getDockedCount())
end

--@api-stub: LDockPanel:getSplitSize
do
    local dp = lurek.ui.newDockPanel(); print("type=" .. dp:type())
    local child = lurek.ui.newPanel(); dp:dock(0, "left")
    print("docked=" .. dp:getDockedCount()); local sz = dp:getSplitSize("left")
    print("split_size=" .. tostring(sz)); dp:setSplitSize("left", 150)
    dp:undock(0); print("docked_after=" .. dp:getDockedCount())
end

--@api-stub: LDockPanel:setSplitSize
do
    local dp = lurek.ui.newDockPanel(); print("type=" .. dp:type())
    local child = lurek.ui.newPanel(); dp:dock(0, "left")
    print("docked=" .. dp:getDockedCount()); local sz = dp:getSplitSize("left")
    print("split_size=" .. tostring(sz)); dp:setSplitSize("left", 150)
    dp:undock(0); print("docked_after=" .. dp:getDockedCount())
end

--@api-stub: LImageWidget:getScaleMode
do
    local iw = lurek.ui.newImageWidget(); print("type=" .. iw:type())
    print("scale_mode=" .. tostring(iw:getScaleMode())); iw:setScaleMode("stretch")
    print("scale_mode_after=" .. iw:getScaleMode()); iw:setTint(255, 200, 128, 255)
    local r, g, b, a = iw:getTint()
    print("tint=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LImageWidget:getTint
do
    local iw = lurek.ui.newImageWidget(); print("type=" .. iw:type())
    print("scale_mode=" .. tostring(iw:getScaleMode())); iw:setScaleMode("stretch")
    print("scale_mode_after=" .. iw:getScaleMode()); iw:setTint(255, 200, 128, 255)
    local r, g, b, a = iw:getTint()
    print("tint=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LImageWidget:setScaleMode
do
    local iw = lurek.ui.newImageWidget(); print("type=" .. iw:type())
    print("scale_mode=" .. tostring(iw:getScaleMode())); iw:setScaleMode("stretch")
    print("scale_mode_after=" .. iw:getScaleMode()); iw:setTint(255, 200, 128, 255)
    local r, g, b, a = iw:getTint()
    print("tint=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LImageWidget:setTint
do
    local iw = lurek.ui.newImageWidget(); print("type=" .. iw:type())
    print("scale_mode=" .. tostring(iw:getScaleMode())); iw:setScaleMode("stretch")
    print("scale_mode_after=" .. iw:getScaleMode()); iw:setTint(255, 200, 128, 255)
    local r, g, b, a = iw:getTint()
    print("tint=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LNinePatch:getImageDimensions
do
    local np = lurek.ui.newNinePatch(); print("type=" .. np:type())
    np:setImageDimensions(64, 64); local w, h = np:getImageDimensions()
    print("img_dim=" .. w .. "x" .. h); np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets(); print("insets=" .. l .. "," .. t .. "," .. r .. "," .. b)
    local slices = np:getSlices(); print("slices=" .. tostring(slices ~= nil))
end

--@api-stub: LNinePatch:getInsets
do
    local np = lurek.ui.newNinePatch(); print("type=" .. np:type())
    np:setImageDimensions(64, 64); local w, h = np:getImageDimensions()
    print("img_dim=" .. w .. "x" .. h); np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets(); print("insets=" .. l .. "," .. t .. "," .. r .. "," .. b)
    local slices = np:getSlices(); print("slices=" .. tostring(slices ~= nil))
end

--@api-stub: LNinePatch:getSlices
do
    local np = lurek.ui.newNinePatch(); print("type=" .. np:type())
    np:setImageDimensions(64, 64); local w, h = np:getImageDimensions()
    print("img_dim=" .. w .. "x" .. h); np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets(); print("insets=" .. l .. "," .. t .. "," .. r .. "," .. b)
    local slices = np:getSlices(); print("slices=" .. tostring(slices ~= nil))
end

--@api-stub: LNinePatch:setImageDimensions
do
    local np = lurek.ui.newNinePatch(); print("type=" .. np:type())
    np:setImageDimensions(64, 64); local w, h = np:getImageDimensions()
    print("img_dim=" .. w .. "x" .. h); np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets(); print("insets=" .. l .. "," .. t .. "," .. r .. "," .. b)
    local slices = np:getSlices(); print("slices=" .. tostring(slices ~= nil))
end

--@api-stub: LNinePatch:setInsets
do
    local np = lurek.ui.newNinePatch(); print("type=" .. np:type())
    np:setImageDimensions(64, 64); local w, h = np:getImageDimensions()
    print("img_dim=" .. w .. "x" .. h); np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets(); print("insets=" .. l .. "," .. t .. "," .. r .. "," .. b)
    local slices = np:getSlices(); print("slices=" .. tostring(slices ~= nil))
end

--@api-stub: LRadioButton:getGroup
do
    local rb1 = lurek.ui.newRadioButton("Option A", "opt_group"); local rb2 = lurek.ui.newRadioButton("Option B", "opt_group")
    print("type=" .. rb1:type()); print("text=" .. rb1:getText())
    print("group=" .. rb1:getGroup()); print("selected=" .. tostring(rb1:isSelected()))
    rb1:setGroup("new_group")
    print("group_after=" .. rb1:getGroup())
end

--@api-stub: LRadioButton:getText
do
    local rb1 = lurek.ui.newRadioButton("Option A", "opt_group"); local rb2 = lurek.ui.newRadioButton("Option B", "opt_group")
    print("type=" .. rb1:type()); print("text=" .. rb1:getText())
    print("group=" .. rb1:getGroup()); print("selected=" .. tostring(rb1:isSelected()))
    rb1:setGroup("new_group")
    print("group_after=" .. rb1:getGroup())
end

--@api-stub: LRadioButton:isSelected
do
    local rb1 = lurek.ui.newRadioButton("Option A", "opt_group"); local rb2 = lurek.ui.newRadioButton("Option B", "opt_group")
    print("type=" .. rb1:type()); print("text=" .. rb1:getText())
    print("group=" .. rb1:getGroup()); print("selected=" .. tostring(rb1:isSelected()))
    rb1:setGroup("new_group")
    print("group_after=" .. rb1:getGroup())
end

--@api-stub: LRadioButton:setGroup
do
    local rb1 = lurek.ui.newRadioButton("Option A", "opt_group"); local rb2 = lurek.ui.newRadioButton("Option B", "opt_group")
    print("type=" .. rb1:type()); print("text=" .. rb1:getText())
    print("group=" .. rb1:getGroup()); print("selected=" .. tostring(rb1:isSelected()))
    rb1:setGroup("new_group")
    print("group_after=" .. rb1:getGroup())
end

--@api-stub: LSpinBox:getValue
do
    local sb = lurek.ui.newSpinBox(1, 10); print("type=" .. sb:type())
    sb:setValue(5); print("value=" .. sb:getValue())
    sb:setStep(2); sb:setRange(0, 100)
    sb:increment(); print("value_after_inc=" .. sb:getValue())
    sb:decrement(); print("value_after_dec=" .. sb:getValue())
end

--@api-stub: LSpinBox:setValue
do
    local sb = lurek.ui.newSpinBox(1, 10); print("type=" .. sb:type())
    sb:setValue(5); print("value=" .. sb:getValue())
    sb:setStep(2); sb:setRange(0, 100)
    sb:increment(); print("value_after_inc=" .. sb:getValue())
    sb:decrement(); print("value_after_dec=" .. sb:getValue())
end

--@api-stub: LSplitPanel:getFirstChild
do
    local sp = lurek.ui.newSplitPanel("horizontal"); print("type=" .. sp:type()); print("orientation=" .. sp:getOrientation())
    sp:setFirstChild(0); sp:setSecondChild(1); local fc = sp:getFirstChild()
    print("fc=" .. tostring(fc)); local sc = sp:getSecondChild(); print("sc=" .. tostring(sc))
    sp:setSplitPosition(200); print("split_pos=" .. sp:getSplitPosition()); sp:setMinPanelSize(80)
    print("min_panel=" .. sp:getMinPanelSize()); sp:setOrientation("vertical"); print("orientation_after=" .. sp:getOrientation())
end

--@api-stub: LSplitPanel:getMinPanelSize
do
    local sp = lurek.ui.newSplitPanel("horizontal"); print("type=" .. sp:type()); print("orientation=" .. sp:getOrientation())
    sp:setFirstChild(0); sp:setSecondChild(1); local fc = sp:getFirstChild()
    print("fc=" .. tostring(fc)); local sc = sp:getSecondChild(); print("sc=" .. tostring(sc))
    sp:setSplitPosition(200); print("split_pos=" .. sp:getSplitPosition()); sp:setMinPanelSize(80)
    print("min_panel=" .. sp:getMinPanelSize()); sp:setOrientation("vertical"); print("orientation_after=" .. sp:getOrientation())
end

--@api-stub: LSplitPanel:getOrientation
do
    local sp = lurek.ui.newSplitPanel("horizontal"); print("type=" .. sp:type()); print("orientation=" .. sp:getOrientation())
    sp:setFirstChild(0); sp:setSecondChild(1); local fc = sp:getFirstChild()
    print("fc=" .. tostring(fc)); local sc = sp:getSecondChild(); print("sc=" .. tostring(sc))
    sp:setSplitPosition(200); print("split_pos=" .. sp:getSplitPosition()); sp:setMinPanelSize(80)
    print("min_panel=" .. sp:getMinPanelSize()); sp:setOrientation("vertical"); print("orientation_after=" .. sp:getOrientation())
end

--@api-stub: LSplitPanel:getSecondChild
do
    local sp = lurek.ui.newSplitPanel("horizontal"); print("type=" .. sp:type()); print("orientation=" .. sp:getOrientation())
    sp:setFirstChild(0); sp:setSecondChild(1); local fc = sp:getFirstChild()
    print("fc=" .. tostring(fc)); local sc = sp:getSecondChild(); print("sc=" .. tostring(sc))
    sp:setSplitPosition(200); print("split_pos=" .. sp:getSplitPosition()); sp:setMinPanelSize(80)
    print("min_panel=" .. sp:getMinPanelSize()); sp:setOrientation("vertical"); print("orientation_after=" .. sp:getOrientation())
end

--@api-stub: LSplitPanel:getSplitPosition
do
    local sp = lurek.ui.newSplitPanel("horizontal"); print("type=" .. sp:type()); print("orientation=" .. sp:getOrientation())
    sp:setFirstChild(0); sp:setSecondChild(1); local fc = sp:getFirstChild()
    print("fc=" .. tostring(fc)); local sc = sp:getSecondChild(); print("sc=" .. tostring(sc))
    sp:setSplitPosition(200); print("split_pos=" .. sp:getSplitPosition()); sp:setMinPanelSize(80)
    print("min_panel=" .. sp:getMinPanelSize()); sp:setOrientation("vertical"); print("orientation_after=" .. sp:getOrientation())
end

--@api-stub: LSplitPanel:setFirstChild
do
    local sp = lurek.ui.newSplitPanel("horizontal"); print("type=" .. sp:type()); print("orientation=" .. sp:getOrientation())
    sp:setFirstChild(0); sp:setSecondChild(1); local fc = sp:getFirstChild()
    print("fc=" .. tostring(fc)); local sc = sp:getSecondChild(); print("sc=" .. tostring(sc))
    sp:setSplitPosition(200); print("split_pos=" .. sp:getSplitPosition()); sp:setMinPanelSize(80)
    print("min_panel=" .. sp:getMinPanelSize()); sp:setOrientation("vertical"); print("orientation_after=" .. sp:getOrientation())
end

--@api-stub: LSplitPanel:setMinPanelSize
do
    local sp = lurek.ui.newSplitPanel("horizontal"); print("type=" .. sp:type()); print("orientation=" .. sp:getOrientation())
    sp:setFirstChild(0); sp:setSecondChild(1); local fc = sp:getFirstChild()
    print("fc=" .. tostring(fc)); local sc = sp:getSecondChild(); print("sc=" .. tostring(sc))
    sp:setSplitPosition(200); print("split_pos=" .. sp:getSplitPosition()); sp:setMinPanelSize(80)
    print("min_panel=" .. sp:getMinPanelSize()); sp:setOrientation("vertical"); print("orientation_after=" .. sp:getOrientation())
end

--@api-stub: LSplitPanel:setOrientation
do
    local sp = lurek.ui.newSplitPanel("horizontal"); print("type=" .. sp:type()); print("orientation=" .. sp:getOrientation())
    sp:setFirstChild(0); sp:setSecondChild(1); local fc = sp:getFirstChild()
    print("fc=" .. tostring(fc)); local sc = sp:getSecondChild(); print("sc=" .. tostring(sc))
    sp:setSplitPosition(200); print("split_pos=" .. sp:getSplitPosition()); sp:setMinPanelSize(80)
    print("min_panel=" .. sp:getMinPanelSize()); sp:setOrientation("vertical"); print("orientation_after=" .. sp:getOrientation())
end

--@api-stub: LSplitPanel:setSecondChild
do
    local sp = lurek.ui.newSplitPanel("horizontal"); print("type=" .. sp:type()); print("orientation=" .. sp:getOrientation())
    sp:setFirstChild(0); sp:setSecondChild(1); local fc = sp:getFirstChild()
    print("fc=" .. tostring(fc)); local sc = sp:getSecondChild(); print("sc=" .. tostring(sc))
    sp:setSplitPosition(200); print("split_pos=" .. sp:getSplitPosition()); sp:setMinPanelSize(80)
    print("min_panel=" .. sp:getMinPanelSize()); sp:setOrientation("vertical"); print("orientation_after=" .. sp:getOrientation())
end

--@api-stub: LSplitPanel:setSplitPosition
do
    local sp = lurek.ui.newSplitPanel("horizontal"); print("type=" .. sp:type()); print("orientation=" .. sp:getOrientation())
    sp:setFirstChild(0); sp:setSecondChild(1); local fc = sp:getFirstChild()
    print("fc=" .. tostring(fc)); local sc = sp:getSecondChild(); print("sc=" .. tostring(sc))
    sp:setSplitPosition(200); print("split_pos=" .. sp:getSplitPosition()); sp:setMinPanelSize(80)
    print("min_panel=" .. sp:getMinPanelSize()); sp:setOrientation("vertical"); print("orientation_after=" .. sp:getOrientation())
end

--@api-stub: LSwitch:isOn
do
    local sw = lurek.ui.newSwitch(false); print("type=" .. sw:type())
    print("is_on=" .. tostring(sw:isOn()))
    sw:setOn(true)
    print("is_on_after=" .. tostring(sw:isOn()))
    sw:setOnChange(function(v) print("switch_changed=" .. tostring(v)) end)
end

--@api-stub: LSwitch:setOnChange
do
    local sw = lurek.ui.newSwitch(false); print("type=" .. sw:type())
    print("is_on=" .. tostring(sw:isOn()))
    sw:setOn(true)
    print("is_on_after=" .. tostring(sw:isOn()))
    sw:setOnChange(function(v) print("switch_changed=" .. tostring(v)) end)
end

--@api-stub: LGuiTable:addColumn
do
    local tbl = lurek.ui.newTable(); print("type=" .. tbl:type()); tbl:addColumn("Name")
    tbl:addColumn("Score"); print("cols=" .. tbl:getColumnCount()); tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" }); print("rows=" .. tbl:getRowCount()); local cell = tbl:getCell(0, 0)
    print("cell00=" .. tostring(cell)); tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1); print("selected=" .. tbl:getSelectedRow())
end

--@api-stub: LGuiTable:addRow
do
    local tbl = lurek.ui.newTable(); print("type=" .. tbl:type()); tbl:addColumn("Name")
    tbl:addColumn("Score"); print("cols=" .. tbl:getColumnCount()); tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" }); print("rows=" .. tbl:getRowCount()); local cell = tbl:getCell(0, 0)
    print("cell00=" .. tostring(cell)); tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1); print("selected=" .. tbl:getSelectedRow())
end

--@api-stub: LGuiTable:clearRows
do
    local tbl = lurek.ui.newTable()
    tbl:setRows({ { "Food", 420 }, { "Rent", 1200 } })
    tbl:setSelectedRow(1)
    tbl:clearRows()
    print("rows=" .. tbl:getRowCount())
end

--@api-stub: LGuiTable:setRows
do
    local tbl = lurek.ui.newTable()
    local count = tbl:setRows({ { "Income", 3200 }, { "Savings", 640 } })
    print("setRows=" .. count .. ", first=" .. tostring(tbl:getCell(1, 1)))
end

--@api-stub: LGuiTable:setDataFrame
do
    local df = lurek.dataframe.fromRows({ "category", "amount" }, { { "Food", 420 }, { "Rent", 1200 } })
    local tbl = lurek.ui.newTable()
    local count = tbl:setDataFrame(df, { columns = { "category", "amount" }, maxRows = 2 })
    print("setDataFrame=" .. count .. ", cols=" .. tbl:getColumnCount())
end

--@api-stub: LGuiTable:getCell
do
    local tbl = lurek.ui.newTable(); print("type=" .. tbl:type()); tbl:addColumn("Name")
    tbl:addColumn("Score"); print("cols=" .. tbl:getColumnCount()); tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" }); print("rows=" .. tbl:getRowCount()); local cell = tbl:getCell(0, 0)
    print("cell00=" .. tostring(cell)); tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1); print("selected=" .. tbl:getSelectedRow())
end

--@api-stub: LGuiTable:getColumnCount
do
    local tbl = lurek.ui.newTable(); print("type=" .. tbl:type()); tbl:addColumn("Name")
    tbl:addColumn("Score"); print("cols=" .. tbl:getColumnCount()); tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" }); print("rows=" .. tbl:getRowCount()); local cell = tbl:getCell(0, 0)
    print("cell00=" .. tostring(cell)); tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1); print("selected=" .. tbl:getSelectedRow())
end

--@api-stub: LGuiTable:getRowCount
do
    local tbl = lurek.ui.newTable(); print("type=" .. tbl:type()); tbl:addColumn("Name")
    tbl:addColumn("Score"); print("cols=" .. tbl:getColumnCount()); tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" }); print("rows=" .. tbl:getRowCount()); local cell = tbl:getCell(0, 0)
    print("cell00=" .. tostring(cell)); tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1); print("selected=" .. tbl:getSelectedRow())
end

--@api-stub: LGuiTable:getSelectedRow
do
    local tbl = lurek.ui.newTable(); print("type=" .. tbl:type()); tbl:addColumn("Name")
    tbl:addColumn("Score"); print("cols=" .. tbl:getColumnCount()); tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" }); print("rows=" .. tbl:getRowCount()); local cell = tbl:getCell(0, 0)
    print("cell00=" .. tostring(cell)); tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1); print("selected=" .. tbl:getSelectedRow())
end

--@api-stub: LGuiTable:setCell
do
    local tbl = lurek.ui.newTable(); print("type=" .. tbl:type()); tbl:addColumn("Name")
    tbl:addColumn("Score"); print("cols=" .. tbl:getColumnCount()); tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" }); print("rows=" .. tbl:getRowCount()); local cell = tbl:getCell(0, 0)
    print("cell00=" .. tostring(cell)); tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1); print("selected=" .. tbl:getSelectedRow())
end

--@api-stub: LGuiTable:setSelectedRow
do
    local tbl = lurek.ui.newTable(); print("type=" .. tbl:type()); tbl:addColumn("Name")
    tbl:addColumn("Score"); print("cols=" .. tbl:getColumnCount()); tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" }); print("rows=" .. tbl:getRowCount()); local cell = tbl:getCell(0, 0)
    print("cell00=" .. tostring(cell)); tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1); print("selected=" .. tbl:getSelectedRow())
end

--@api-stub: lurek.ui.newTable
do
    local tbl = lurek.ui.newTable(); print("type=" .. tbl:type()); tbl:addColumn("Name")
    tbl:addColumn("Score"); print("cols=" .. tbl:getColumnCount()); tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" }); print("rows=" .. tbl:getRowCount()); local cell = tbl:getCell(0, 0)
    print("cell00=" .. tostring(cell)); tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1); print("selected=" .. tbl:getSelectedRow())
end

--@api-stub: LToast:getDuration
do
    local toast = lurek.ui.newToast("File saved", 3.0); print("type=" .. toast:type())
    print("msg=" .. toast:getMessage()); print("dur=" .. toast:getDuration())
    print("progress=" .. toast:getProgress()); print("expired=" .. tostring(toast:isExpired()))
    toast:setMessage("Updated message"); toast:setDuration(5.0)
    print("msg_after=" .. toast:getMessage()); print("dur_after=" .. toast:getDuration())
end

--@api-stub: LToast:getMessage
do
    local toast = lurek.ui.newToast("File saved", 3.0); print("type=" .. toast:type())
    print("msg=" .. toast:getMessage()); print("dur=" .. toast:getDuration())
    print("progress=" .. toast:getProgress()); print("expired=" .. tostring(toast:isExpired()))
    toast:setMessage("Updated message"); toast:setDuration(5.0)
    print("msg_after=" .. toast:getMessage()); print("dur_after=" .. toast:getDuration())
end

--@api-stub: LToast:getProgress
do
    local toast = lurek.ui.newToast("File saved", 3.0); print("type=" .. toast:type())
    print("msg=" .. toast:getMessage()); print("dur=" .. toast:getDuration())
    print("progress=" .. toast:getProgress()); print("expired=" .. tostring(toast:isExpired()))
    toast:setMessage("Updated message"); toast:setDuration(5.0)
    print("msg_after=" .. toast:getMessage()); print("dur_after=" .. toast:getDuration())
end

--@api-stub: LToast:isExpired
do
    local toast = lurek.ui.newToast("File saved", 3.0); print("type=" .. toast:type())
    print("msg=" .. toast:getMessage()); print("dur=" .. toast:getDuration())
    print("progress=" .. toast:getProgress()); print("expired=" .. tostring(toast:isExpired()))
    toast:setMessage("Updated message"); toast:setDuration(5.0)
    print("msg_after=" .. toast:getMessage()); print("dur_after=" .. toast:getDuration())
end

--@api-stub: LToast:setDuration
do
    local toast = lurek.ui.newToast("File saved", 3.0); print("type=" .. toast:type())
    print("msg=" .. toast:getMessage()); print("dur=" .. toast:getDuration())
    print("progress=" .. toast:getProgress()); print("expired=" .. tostring(toast:isExpired()))
    toast:setMessage("Updated message"); toast:setDuration(5.0)
    print("msg_after=" .. toast:getMessage()); print("dur_after=" .. toast:getDuration())
end

--@api-stub: LToast:setMessage
do
    local toast = lurek.ui.newToast("File saved", 3.0); print("type=" .. toast:type())
    print("msg=" .. toast:getMessage()); print("dur=" .. toast:getDuration())
    print("progress=" .. toast:getProgress()); print("expired=" .. tostring(toast:isExpired()))
    toast:setMessage("Updated message"); toast:setDuration(5.0)
    print("msg_after=" .. toast:getMessage()); print("dur_after=" .. toast:getDuration())
end

--@api-stub: LTooltipPanel:getDelay
do
    local ttp = lurek.ui.newTooltipPanel("Hover info"); print("type=" .. ttp:type())
    print("text=" .. ttp:getText()); ttp:setText("Updated tooltip")
    print("text_after=" .. ttp:getText())
    ttp:setDelay(0.5)
    print("delay=" .. ttp:getDelay())
end

--@api-stub: LTooltipPanel:getText
do
    local ttp = lurek.ui.newTooltipPanel("Hover info"); print("type=" .. ttp:type())
    print("text=" .. ttp:getText()); ttp:setText("Updated tooltip")
    print("text_after=" .. ttp:getText())
    ttp:setDelay(0.5)
    print("delay=" .. ttp:getDelay())
end

--@api-stub: LTooltipPanel:setDelay
do
    local ttp = lurek.ui.newTooltipPanel("Hover info"); print("type=" .. ttp:type())
    print("text=" .. ttp:getText()); ttp:setText("Updated tooltip")
    print("text_after=" .. ttp:getText())
    ttp:setDelay(0.5)
    print("delay=" .. ttp:getDelay())
end

--@api-stub: LTooltipPanel:setText
do
    local ttp = lurek.ui.newTooltipPanel("Hover info"); print("type=" .. ttp:type())
    print("text=" .. ttp:getText()); ttp:setText("Updated tooltip")
    print("text_after=" .. ttp:getText())
    ttp:setDelay(0.5)
    print("delay=" .. ttp:getDelay())
end

--@api-stub: LTreeView:addNode
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child = tv:addNode("Child C", root)
    print("child added = " .. tostring(child ~= nil))
end

--@api-stub: LTreeView:clearNodes
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    tv:clearNodes()
    print("nodes = " .. tv:getNodeCount())
end

--@api-stub: LTreeView:collapseAll
do
    local tv = lurek.ui.newTreeView(); local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    tv:expandAll()
    tv:collapseAll()
    print("root expanded = " .. tostring(tv:isExpanded(root)))
end

--@api-stub: LTreeView:collapseNode
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:expandNode(root)
    tv:collapseNode(root)
    print("root expanded = " .. tostring(tv:isNodeExpanded(root)))
end

--@api-stub: LTreeView:expandAll
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    tv:expandAll()
    print("root expanded = " .. tostring(tv:isExpanded(root)))
end

--@api-stub: LTreeView:expandNode
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:expandNode(root)
    print("root expanded = " .. tostring(tv:isNodeExpanded(root)))
end

--@api-stub: LTreeView:getChildNodes
do
    local tv = lurek.ui.newTreeView(); local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    tv:addNode("Child B", root)
    local children = tv:getChildNodes(root)
    print("child count = " .. #children)
end

--@api-stub: LTreeView:getNodeCount
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    print("nodes = " .. tv:getNodeCount())
end

--@api-stub: LTreeView:getNodeDepth
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    print("depth = " .. tv:getNodeDepth(child1))
end

--@api-stub: LTreeView:getNodeText
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    print("text = " .. tv:getNodeText(child1))
end

--@api-stub: LTreeView:getParentNode
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    print("parent = " .. tostring(tv:getParentNode(child1) == root))
end

--@api-stub: LTreeView:getSelectedNode
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    tv:setSelectedNode(child1)
    print("selected = " .. tostring(tv:getSelectedNode()))
end

--@api-stub: LTreeView:isExpanded
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:expandAll()
    print("expanded = " .. tostring(tv:isExpanded(root)))
end

--@api-stub: LTreeView:isNodeExpanded
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:expandNode(root)
    print("node expanded = " .. tostring(tv:isNodeExpanded(root)))
end

--@api-stub: LTreeView:removeNode
do
    local tv = lurek.ui.newTreeView(); local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    local child2 = tv:addNode("Child B", root)
    tv:removeNode(child2)
    print("nodes = " .. tv:getNodeCount())
end

--@api-stub: LTreeView:setNodeIcon
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    tv:setNodeIcon(child1, "folder")
    print("icon set on child")
end

--@api-stub: LTreeView:setNodeText
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    tv:setNodeText(child1, "Renamed A")
    print("text = " .. tv:getNodeText(child1))
end

--@api-stub: LTreeView:setSelectedNode
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    tv:setSelectedNode(child1)
    print("selected = " .. tostring(tv:getSelectedNode()))
end

--@api-stub: LTreeView:toggleNode
do
    local tv = lurek.ui.newTreeView(); local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    local child2 = tv:addNode("Child B", root)
    tv:toggleNode(child2)
    print("child toggled")
end

--@api-stub: LAccordion.addSection
do
    local acc = lurek.ui.newAccordion(); acc:addSection("Chapter 1")
    acc:addSection("Chapter 2")
    local cnt = acc:getSectionCount()
    local title = acc:getSectionTitle(1)
    print("sections:", cnt, "title:", title)
end

--@api-stub: LAccordion.getSectionCount
do
    local acc = lurek.ui.newAccordion(); acc:addSection("Chapter 1")
    acc:addSection("Chapter 2")
    local cnt = acc:getSectionCount()
    local title = acc:getSectionTitle(1)
    print("sections:", cnt, "title:", title)
end

--@api-stub: LAccordion.getSectionTitle
do
    local acc = lurek.ui.newAccordion(); acc:addSection("Chapter 1")
    acc:addSection("Chapter 2")
    local cnt = acc:getSectionCount()
    local title = acc:getSectionTitle(1)
    print("sections:", cnt, "title:", title)
end

--@api-stub: LAccordion.isExclusive
do
    local acc = lurek.ui.newAccordion(); acc:addSection("A")
    acc:setExclusive(true)
    local ex = acc:isExclusive()
    local expanded = acc:isSectionExpanded(1)
    print("exclusive:", ex, "expanded:", expanded)
end

--@api-stub: LAccordion.isSectionExpanded
do
    local acc = lurek.ui.newAccordion(); acc:addSection("A")
    acc:setExclusive(true)
    local ex = acc:isExclusive()
    local expanded = acc:isSectionExpanded(1)
    print("exclusive:", ex, "expanded:", expanded)
end

--@api-stub: LAccordion.setExclusive
do
    local acc = lurek.ui.newAccordion(); acc:addSection("A")
    acc:setExclusive(true)
    local ex = acc:isExclusive()
    local expanded = acc:isSectionExpanded(1)
    print("exclusive:", ex, "expanded:", expanded)
end

--@api-stub: LAccordion.toggleSection
do
    local acc = lurek.ui.newAccordion(); acc:addSection("Toggle me")
    local newState = acc:toggleSection(1); local badge = lurek.ui.newBadge(5)
    local count = badge:getCount()
    local disp = badge:getDisplayText()
    print("toggled:", newState, "badge count:", count, "display:", disp)
end

--@api-stub: LBadge.getCount
do
    local acc = lurek.ui.newAccordion(); acc:addSection("Toggle me")
    local newState = acc:toggleSection(1); local badge = lurek.ui.newBadge(5)
    local count = badge:getCount()
    local disp = badge:getDisplayText()
    print("toggled:", newState, "badge count:", count, "display:", disp)
end

--@api-stub: LBadge.getDisplayText
do
    local acc = lurek.ui.newAccordion(); acc:addSection("Toggle me")
    local newState = acc:toggleSection(1); local badge = lurek.ui.newBadge(5)
    local count = badge:getCount()
    local disp = badge:getDisplayText()
    print("toggled:", newState, "badge count:", count, "display:", disp)
end

--@api-stub: LBadge.setCount
do
    local badge = lurek.ui.newBadge(0); badge:setCount(42)
    local btn = lurek.ui.newButton("Click me")
    local t = btn:getText()
    btn:setText("OK")
    print("badge count:", badge:getCount(), "button text:", btn:getText())
end

--@api-stub: LButton.getText
do
    local badge = lurek.ui.newBadge(0); badge:setCount(42)
    local btn = lurek.ui.newButton("Click me")
    local t = btn:getText()
    btn:setText("OK")
    print("badge count:", badge:getCount(), "button text:", btn:getText())
end

--@api-stub: LButton.setText
do
    local badge = lurek.ui.newBadge(0); badge:setCount(42)
    local btn = lurek.ui.newButton("Click me")
    local t = btn:getText()
    btn:setText("OK")
    print("badge count:", badge:getCount(), "button text:", btn:getText())
end

--@api-stub: LCheckbox.getText
do
    local cb = lurek.ui.newCheckbox("Enable feature")
    local t = cb:getText()
    cb:setChecked(true)
    local checked = cb:isChecked()
    print("checkbox text:", t, "checked:", checked)
end

--@api-stub: LCheckbox.isChecked
do
    local cb = lurek.ui.newCheckbox("Enable feature")
    local t = cb:getText()
    cb:setChecked(true)
    local checked = cb:isChecked()
    print("checkbox text:", t, "checked:", checked)
end

--@api-stub: LCheckbox.setChecked
do
    local cb = lurek.ui.newCheckbox("Enable feature")
    local t = cb:getText()
    cb:setChecked(true)
    local checked = cb:isChecked()
    print("checkbox text:", t, "checked:", checked)
end

--@api-stub: LCheckbox.setText
do
    local cb = lurek.ui.newCheckbox("old"); cb:setText("new label")
    local chart = lurek.ui.newAreaChart({width = 200, height = 100})
    chart:setYMax(100)
    chart:addLayer("series1", {10, 20, 30, 25, 15}, 1.0, 0.2, 0.2)
    print("checkbox setText ok; addLayer, setYMax ok")
end

--@api-stub: LAreaChart:addLayer
do
    local cb = lurek.ui.newCheckbox("old"); cb:setText("new label")
    local chart = lurek.ui.newAreaChart({width = 200, height = 100})
    chart:setYMax(100)
    chart:addLayer("series1", {10, 20, 30, 25, 15}, 1.0, 0.2, 0.2)
    print("checkbox setText ok; addLayer, setYMax ok")
end

--@api-stub: LAreaChart:addLayerFromDataFrame
do
    local df = lurek.dataframe.fromRows({ "balance" }, { { 1200 }, { "1325" }, { "bad" } })
    local chart = lurek.ui.newAreaChart({width = 200, height = 100})
    local count = chart:addLayerFromDataFrame("Balance", df, "balance", 0.2, 0.6, 0.9)
    print("area df values=" .. count)
end

--@api-stub: LAreaChart:setYMax
do
    local cb = lurek.ui.newCheckbox("old"); cb:setText("new label")
    local chart = lurek.ui.newAreaChart({width = 200, height = 100})
    chart:setYMax(100)
    chart:addLayer("series1", {10, 20, 30, 25, 15}, 1.0, 0.2, 0.2)
    print("checkbox setText ok; addLayer, setYMax ok")
end

--@api-stub: LAreaChart:drawToImage
do
    local chart = lurek.ui.newAreaChart({width = 64, height = 64}); chart:setYMax(50)
    chart:addLayer("d", {5, 10, 15}, 0.5, 0.8, 0.2); local img = lurek.image.newImageData(64, 64)
    chart:drawToImage(img); local t = chart:type()
    local ok = chart:typeOf("LAreaChart")
    print("drawToImage ok, type:", t, "typeOf:", ok)
end

--@api-stub: LAreaChart:type
do
    local chart = lurek.ui.newAreaChart({width = 64, height = 64}); chart:setYMax(50)
    chart:addLayer("d", {5, 10, 15}, 0.5, 0.8, 0.2); local img = lurek.image.newImageData(64, 64)
    chart:drawToImage(img); local t = chart:type()
    local ok = chart:typeOf("LAreaChart")
    print("drawToImage ok, type:", t, "typeOf:", ok)
end

--@api-stub: LAreaChart:typeOf
do
    local chart = lurek.ui.newAreaChart({width = 64, height = 64}); chart:setYMax(50)
    chart:addLayer("d", {5, 10, 15}, 0.5, 0.8, 0.2); local img = lurek.image.newImageData(64, 64)
    chart:drawToImage(img); local t = chart:type()
    local ok = chart:typeOf("LAreaChart")
    print("drawToImage ok, type:", t, "typeOf:", ok)
end

--@api-stub: LBarChart:addCategory
do
    local chart = lurek.ui.newBarChart({width = 200, height = 100}); chart:addSeries("Q1", 0.2, 0.6, 1.0)
    chart:addSeries("Q2", 1.0, 0.5, 0.1); chart:addCategory("Jan", {30, 45})
    chart:addCategory("Feb", {40, 35}); local img = lurek.image.newImageData(200, 100)
    chart:drawToImage(img)
    print("barChart addSeries/addCategory/drawToImage ok")
end

--@api-stub: LBarChart:addCategoriesFromDataFrame
do
    local df = lurek.dataframe.fromRows({ "month", "income", "expense" }, { { "Jan", 100, 60 }, { "Feb", "120", "bad" } })
    local chart = lurek.ui.newBarChart({width = 200, height = 100})
    chart:addSeries("Income", 0.2, 0.6, 0.9)
    chart:addSeries("Expense", 0.9, 0.4, 0.2)
    local count = chart:addCategoriesFromDataFrame(df, "month", { "income", "expense" })
    print("bar df categories=" .. count)
end

--@api-stub: LBarChart:addSeries
do
    local chart = lurek.ui.newBarChart({width = 200, height = 100}); chart:addSeries("Q1", 0.2, 0.6, 1.0)
    chart:addSeries("Q2", 1.0, 0.5, 0.1); chart:addCategory("Jan", {30, 45})
    chart:addCategory("Feb", {40, 35}); local img = lurek.image.newImageData(200, 100)
    chart:drawToImage(img)
    print("barChart addSeries/addCategory/drawToImage ok")
end

--@api-stub: LBarChart:drawToImage
do
    local chart = lurek.ui.newBarChart({width = 200, height = 100}); chart:addSeries("Q1", 0.2, 0.6, 1.0)
    chart:addSeries("Q2", 1.0, 0.5, 0.1); chart:addCategory("Jan", {30, 45})
    chart:addCategory("Feb", {40, 35}); local img = lurek.image.newImageData(200, 100)
    chart:drawToImage(img)
    print("barChart addSeries/addCategory/drawToImage ok")
end

--@api-stub: LBarChart:type
do
    local chart = lurek.ui.newBarChart({width = 100, height = 50})
    local t = chart:type()
    local ok = chart:typeOf("LBarChart")
    local notOk = chart:typeOf("LAreaChart")
    print("LBarChart type:", t, "typeOf:", ok, "typeOf LAreaChart:", notOk)
end

--@api-stub: LBarChart:typeOf
do
    local chart = lurek.ui.newBarChart({width = 100, height = 50})
    local t = chart:type()
    local ok = chart:typeOf("LBarChart")
    local notOk = chart:typeOf("LAreaChart")
    print("LBarChart type:", t, "typeOf:", ok, "typeOf LAreaChart:", notOk)
end

--@api-stub: LColorPicker.getColor
do
    local cp = lurek.ui.newColorPicker(); cp:setColor(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = cp:getColor()
    local mode = cp:getColorMode()
    local showAlpha = cp:getShowAlpha()
    print("color:", r, g, b, a, "mode:", mode, "showAlpha:", showAlpha)
end

--@api-stub: LColorPicker.getColorMode
do
    local cp = lurek.ui.newColorPicker(); cp:setColor(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = cp:getColor()
    local mode = cp:getColorMode()
    local showAlpha = cp:getShowAlpha()
    print("color:", r, g, b, a, "mode:", mode, "showAlpha:", showAlpha)
end

--@api-stub: LColorPicker.getShowAlpha
do
    local cp = lurek.ui.newColorPicker(); cp:setColor(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = cp:getColor()
    local mode = cp:getColorMode()
    local showAlpha = cp:getShowAlpha()
    print("color:", r, g, b, a, "mode:", mode, "showAlpha:", showAlpha)
end

--@api-stub: LColorPicker.setColor
do
    local cp = lurek.ui.newColorPicker(); cp:setColor(0.2, 0.8, 0.4, 1.0)
    cp:setColorMode("hsv")
    cp:setOnChange(function(idx) print("color changed", idx) end)
    cp:setShowAlpha(true)
    print("setColor/setColorMode/setOnChange ok")
end

--@api-stub: LColorPicker.setColorMode
do
    local cp = lurek.ui.newColorPicker(); cp:setColor(0.2, 0.8, 0.4, 1.0)
    cp:setColorMode("hsv")
    cp:setOnChange(function(idx) print("color changed", idx) end)
    cp:setShowAlpha(true)
    print("setColor/setColorMode/setOnChange ok")
end

--@api-stub: LColorPicker.setOnChange
do
    local cp = lurek.ui.newColorPicker(); cp:setColor(0.2, 0.8, 0.4, 1.0)
    cp:setColorMode("hsv")
    cp:setOnChange(function(idx) print("color changed", idx) end)
    cp:setShowAlpha(true)
    print("setColor/setColorMode/setOnChange ok")
end

--@api-stub: LColorPicker.setShowAlpha
do
    local cp = lurek.ui.newColorPicker(); cp:setShowAlpha(false)
    local cb = lurek.ui.newComboBox(); cb:addItem("Option A")
    cb:addItem("Option B"); cb:addItem("Option C")
    cb:clearItems()
    print("setShowAlpha ok; combo items cleared")
end

--@api-stub: LComboBox.addItem
do
    local cp = lurek.ui.newColorPicker(); cp:setShowAlpha(false)
    local cb = lurek.ui.newComboBox(); cb:addItem("Option A")
    cb:addItem("Option B"); cb:addItem("Option C")
    cb:clearItems()
    print("setShowAlpha ok; combo items cleared")
end

--@api-stub: LComboBox.clearItems
do
    local cp = lurek.ui.newColorPicker(); cp:setShowAlpha(false)
    local cb = lurek.ui.newComboBox(); cb:addItem("Option A")
    cb:addItem("Option B"); cb:addItem("Option C")
    cb:clearItems()
    print("setShowAlpha ok; combo items cleared")
end

--@api-stub: LComboBox.getItem
do
    local cb = lurek.ui.newComboBox(); cb:addItem("First")
    cb:addItem("Second"); cb:addItem("Third")
    local cnt = cb:getItemCount(); local item = cb:getItem(2)
    cb:setSelectedIndex(1); local sel = cb:getSelectedIndex()
    print("getItemCount:", cnt, "getItem:", item, "getSelectedIndex:", sel)
end

--@api-stub: LComboBox.getItemCount
do
    local cb = lurek.ui.newComboBox(); cb:addItem("First")
    cb:addItem("Second"); cb:addItem("Third")
    local cnt = cb:getItemCount(); local item = cb:getItem(2)
    cb:setSelectedIndex(1); local sel = cb:getSelectedIndex()
    print("getItemCount:", cnt, "getItem:", item, "getSelectedIndex:", sel)
end

--@api-stub: LComboBox.getSelectedIndex
do
    local cb = lurek.ui.newComboBox(); cb:addItem("First")
    cb:addItem("Second"); cb:addItem("Third")
    local cnt = cb:getItemCount(); local item = cb:getItem(2)
    cb:setSelectedIndex(1); local sel = cb:getSelectedIndex()
    print("getItemCount:", cnt, "getItem:", item, "getSelectedIndex:", sel)
end

--@api-stub: LComboBox.getSelectedItem
do
    local cb = lurek.ui.newComboBox(); cb:addItem("Alpha")
    cb:addItem("Beta"); cb:setSelectedIndex(2)
    local selItem = cb:getSelectedItem()
    cb:removeItem(1)
    print("getSelectedItem:", selItem, "removeItem ok")
end

--@api-stub: LComboBox.removeItem
do
    local cb = lurek.ui.newComboBox(); cb:addItem("Alpha")
    cb:addItem("Beta"); cb:setSelectedIndex(2)
    local selItem = cb:getSelectedItem()
    cb:removeItem(1)
    print("getSelectedItem:", selItem, "removeItem ok")
end

--@api-stub: LComboBox.setSelectedIndex
do
    local cb = lurek.ui.newComboBox(); cb:addItem("Alpha")
    cb:addItem("Beta"); cb:setSelectedIndex(2)
    local selItem = cb:getSelectedItem()
    cb:removeItem(1)
    print("getSelectedItem:", selItem, "removeItem ok")
end

--@api-stub: LDialog.addButton
do
    local dlg = lurek.ui.newDialog("Info"); local btnIdx = dlg:addButton("OK")
    local content = dlg:getContent()
    dlg:open()
    dlg:close()
    print("addButton:", btnIdx, "close ok")
end

--@api-stub: LDialog.close
do
    local dlg = lurek.ui.newDialog("Info"); local btnIdx = dlg:addButton("OK")
    local content = dlg:getContent()
    dlg:open()
    dlg:close()
    print("addButton:", btnIdx, "close ok")
end

--@api-stub: LDialog.getContent
do
    local dlg = lurek.ui.newDialog("Info"); local btnIdx = dlg:addButton("OK")
    local content = dlg:getContent()
    dlg:open()
    dlg:close()
    print("addButton:", btnIdx, "close ok")
end

--@api-stub: LDialog.getTitle
do
    local dlg = lurek.ui.newDialog("My Dialog"); local title = dlg:getTitle()
    dlg:setModal(true)
    local modal = dlg:isModal()
    local open = dlg:isOpen()
    print("title:", title, "isModal:", modal, "isOpen:", open)
end

--@api-stub: LDialog.isModal
do
    local dlg = lurek.ui.newDialog("My Dialog"); local title = dlg:getTitle()
    dlg:setModal(true)
    local modal = dlg:isModal()
    local open = dlg:isOpen()
    print("title:", title, "isModal:", modal, "isOpen:", open)
end

--@api-stub: LDialog.isOpen
do
    local dlg = lurek.ui.newDialog("My Dialog"); local title = dlg:getTitle()
    dlg:setModal(true)
    local modal = dlg:isModal()
    local open = dlg:isOpen()
    print("title:", title, "isModal:", modal, "isOpen:", open)
end

--@api-stub: LDialog.open
do
    local dlg = lurek.ui.newDialog("Setup"); dlg:setModal(false)
    dlg:setContent(nil)
    dlg:open()
    dlg:close()
    print("open/setContent/setModal ok")
end

--@api-stub: LDialog.setContent
do
    local dlg = lurek.ui.newDialog("Setup"); dlg:setModal(false)
    dlg:setContent(nil)
    dlg:open()
    dlg:close()
    print("open/setContent/setModal ok")
end

--@api-stub: LDialog.setModal
do
    local dlg = lurek.ui.newDialog("Setup"); dlg:setModal(false)
    dlg:setContent(nil)
    dlg:open()
    dlg:close()
    print("open/setContent/setModal ok")
end

--@api-stub: LDialog.setOnClose
do
    local dlg = lurek.ui.newDialog("Old"); dlg:setTitle("New Title")
    dlg:setOnClose(function(idx) print("closed", idx) end)
    local dp = lurek.ui.newDockPanel()
    local btn = lurek.ui.newButton("Side")
    print("setTitle/setOnClose ok; DockPanel created")
end

--@api-stub: LDialog.setTitle
do
    local dlg = lurek.ui.newDialog("Old"); dlg:setTitle("New Title")
    dlg:setOnClose(function(idx) print("closed", idx) end)
    local dp = lurek.ui.newDockPanel()
    local btn = lurek.ui.newButton("Side")
    print("setTitle/setOnClose ok; DockPanel created")
end

--@api-stub: LDockPanel.dock
do
    local dlg = lurek.ui.newDialog("Old"); dlg:setTitle("New Title")
    dlg:setOnClose(function(idx) print("closed", idx) end)
    local dp = lurek.ui.newDockPanel()
    local btn = lurek.ui.newButton("Side")
    print("setTitle/setOnClose ok; DockPanel created")
end

--@api-stub: LDockPanel.getDockedCount
do
    local dp = lurek.ui.newDockPanel()
    local cnt = dp:getDockedCount()
    dp:setSplitSize("left", 200)
    local sz = dp:getSplitSize("left")
    print("getDockedCount:", cnt, "splitSize:", sz)
end

--@api-stub: LDockPanel.getSplitSize
do
    local dp = lurek.ui.newDockPanel()
    local cnt = dp:getDockedCount()
    dp:setSplitSize("left", 200)
    local sz = dp:getSplitSize("left")
    print("getDockedCount:", cnt, "splitSize:", sz)
end

--@api-stub: LDockPanel.setSplitSize
do
    local dp = lurek.ui.newDockPanel()
    local cnt = dp:getDockedCount()
    dp:setSplitSize("left", 200)
    local sz = dp:getSplitSize("left")
    print("getDockedCount:", cnt, "splitSize:", sz)
end

--@api-stub: LDockPanel.undock
do
    local dp = lurek.ui.newDockPanel()
    local dockedCount = dp:getDockedCount()
    dp:undock(0)
    local tbl = lurek.ui.newTable()
    print("undock ok (dockedCount was:", dockedCount, "); newTable ok")
end

--@api-stub: LGuiTable.addColumn
do
    local dp = lurek.ui.newDockPanel()
    local dockedCount = dp:getDockedCount()
    dp:undock(0)
    local tbl = lurek.ui.newTable()
    print("undock ok (dockedCount was:", dockedCount, "); newTable ok")
end

--@api-stub: LGuiTable.addRow
do
    local dp = lurek.ui.newDockPanel()
    local dockedCount = dp:getDockedCount()
    dp:undock(0)
    local tbl = lurek.ui.newTable()
    print("undock ok (dockedCount was:", dockedCount, "); newTable ok")
end

--@api-stub: LGuiTable.getCell
do
    local tbl = lurek.ui.newTable(); tbl:addColumn("Name", 100)
    tbl:addColumn("Value", 80); tbl:addRow({"Alice", "42"})
    tbl:addRow({"Bob", "99"})
    local cell = tbl:getCell(1, 1)
    print("addColumn/addRow/getCell ok, cell:", cell)
end

--@api-stub: LGuiTable.getColumnCount
do
    local tbl = lurek.ui.newTable(); tbl:addColumn("Col1")
    tbl:addColumn("Col2"); tbl:addRow({"A", "1"})
    tbl:addRow({"B", "2"}); local cols = tbl:getColumnCount()
    local rows = tbl:getRowCount(); local sel = tbl:getSelectedRow()
    print("cols:", cols, "rows:", rows, "selectedRow:", sel)
end

--@api-stub: LGuiTable.getRowCount
do
    local tbl = lurek.ui.newTable(); tbl:addColumn("Col1")
    tbl:addColumn("Col2"); tbl:addRow({"A", "1"})
    tbl:addRow({"B", "2"}); local cols = tbl:getColumnCount()
    local rows = tbl:getRowCount(); local sel = tbl:getSelectedRow()
    print("cols:", cols, "rows:", rows, "selectedRow:", sel)
end

--@api-stub: LGuiTable.getSelectedRow
do
    local tbl = lurek.ui.newTable(); tbl:addColumn("Col1")
    tbl:addColumn("Col2"); tbl:addRow({"A", "1"})
    tbl:addRow({"B", "2"}); local cols = tbl:getColumnCount()
    local rows = tbl:getRowCount(); local sel = tbl:getSelectedRow()
    print("cols:", cols, "rows:", rows, "selectedRow:", sel)
end

--@api-stub: LGuiTable.isSortable
do
    local tbl = lurek.ui.newTable(); tbl:addColumn("ID")
    tbl:addRow({"1"}); tbl:setSortable(true)
    tbl:setCell(1, 1, "changed")
    tbl:setOnSelect(function(idx) print("row selected", idx) end)
    print("isSortable/setCell/setOnSelect ok")
end

--@api-stub: LGuiTable.setCell
do
    local tbl = lurek.ui.newTable(); tbl:addColumn("ID")
    tbl:addRow({"1"}); tbl:setSortable(true)
    tbl:setCell(1, 1, "changed")
    tbl:setOnSelect(function(idx) print("row selected", idx) end)
    print("isSortable/setCell/setOnSelect ok")
end

--@api-stub: LGuiTable.setOnSelect
do
    local tbl = lurek.ui.newTable(); tbl:addColumn("ID")
    tbl:addRow({"1"}); tbl:setSortable(true)
    tbl:setCell(1, 1, "changed")
    tbl:setOnSelect(function(idx) print("row selected", idx) end)
    print("isSortable/setCell/setOnSelect ok")
end

--@api-stub: LGuiTable.setSelectedRow
do
    local tbl = lurek.ui.newTable(); tbl:addColumn("X")
    tbl:addRow({"row1"}); tbl:setSelectedRow(1)
    local sel = tbl:getSelectedRow(); tbl:setSortable(false)
    local win = lurek.ui.newWindow("My Window"); local title = win:getTitle()
    print("setSelectedRow:", sel, "setSortable ok, win title:", title)
end

--@api-stub: LGuiTable.setSortable
do
    local tbl = lurek.ui.newTable(); tbl:setPosition(20, 420); tbl:setSize(220, 90); tbl:setZOrder(2100)
    tbl:addColumn("Name", 120); tbl:addColumn("Value", 80)
    tbl:addRow({"B", "20"}); tbl:addRow({"A", "10"}); tbl:setSortable(true)
    lurek.ui.mousepressed(25, 430, 1); lurek.ui.mousereleased(25, 430, 1); lurek.ui.update(0)
    print("sorted first row:", tbl:getCell(1, 1))
end

--@api-stub: LGuiWindow.getTitle
do
    local tbl = lurek.ui.newTable(); tbl:addColumn("X")
    tbl:addRow({"row1"}); tbl:setSelectedRow(1)
    local sel = tbl:getSelectedRow(); tbl:setSortable(false)
    local win = lurek.ui.newWindow("My Window"); local title = win:getTitle()
    print("setSelectedRow:", sel, "setSortable ok, win title:", title)
end

--@api-stub: LGuiWindow.isCloseable
do
    local win = lurek.ui.newWindow("Test Win")
    local closeable = win:isCloseable()
    local draggable = win:isDraggable()
    local resizable = win:isResizable()
    print("isCloseable:", closeable, "isDraggable:", draggable, "isResizable:", resizable)
end

--@api-stub: LGuiWindow.isDraggable
do
    local win = lurek.ui.newWindow("Test Win")
    local closeable = win:isCloseable()
    local draggable = win:isDraggable()
    local resizable = win:isResizable()
    print("isCloseable:", closeable, "isDraggable:", draggable, "isResizable:", resizable)
end

--@api-stub: LGuiWindow.isResizable
do
    local win = lurek.ui.newWindow("Test Win")
    local closeable = win:isCloseable()
    local draggable = win:isDraggable()
    local resizable = win:isResizable()
    print("isCloseable:", closeable, "isDraggable:", draggable, "isResizable:", resizable)
end

--@api-stub: LGuiWindow.setCloseable
do
    local win = lurek.ui.newWindow("Config")
    win:setCloseable(true)
    win:setDraggable(true)
    win:setOnClose(function(idx) print("window closed", idx) end)
    print("setCloseable/setDraggable/setOnClose ok")
end

--@api-stub: LGuiWindow.setDraggable
do
    local win = lurek.ui.newWindow("Config")
    win:setCloseable(true)
    win:setDraggable(true)
    win:setOnClose(function(idx) print("window closed", idx) end)
    print("setCloseable/setDraggable/setOnClose ok")
end

--@api-stub: LGuiWindow.setOnClose
do
    local win = lurek.ui.newWindow("Config")
    win:setCloseable(true)
    win:setDraggable(true)
    win:setOnClose(function(idx) print("window closed", idx) end)
    print("setCloseable/setDraggable/setOnClose ok")
end

--@api-stub: LGuiWindow.setResizable
do
    local win = lurek.ui.newWindow("Old"); win:setResizable(false)
    win:setTitle("New Title")
    local iw = lurek.ui.newImageWidget()
    local mode = iw:getScaleMode()
    print("setResizable/setTitle ok; scaleMode:", mode)
end

--@api-stub: LGuiWindow.setTitle
do
    local win = lurek.ui.newWindow("Old"); win:setResizable(false)
    win:setTitle("New Title")
    local iw = lurek.ui.newImageWidget()
    local mode = iw:getScaleMode()
    print("setResizable/setTitle ok; scaleMode:", mode)
end

--@api-stub: LImageWidget.getScaleMode
do
    local win = lurek.ui.newWindow("Old"); win:setResizable(false)
    win:setTitle("New Title")
    local iw = lurek.ui.newImageWidget()
    local mode = iw:getScaleMode()
    print("setResizable/setTitle ok; scaleMode:", mode)
end

--@api-stub: LImageWidget.getTint
do
    local iw = lurek.ui.newImageWidget()
    iw:setTint(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = iw:getTint()
    iw:setScaleMode("fit")
    print("tint:", r, g, b, a, "scaleMode: fit")
end

--@api-stub: LImageWidget.setScaleMode
do
    local iw = lurek.ui.newImageWidget()
    iw:setTint(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = iw:getTint()
    iw:setScaleMode("fit")
    print("tint:", r, g, b, a, "scaleMode: fit")
end

--@api-stub: LImageWidget.setTint
do
    local iw = lurek.ui.newImageWidget()
    iw:setTint(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = iw:getTint()
    iw:setScaleMode("fit")
    print("tint:", r, g, b, a, "scaleMode: fit")
end

--@api-stub: LLabel.getText
do
    local lbl = lurek.ui.newLabel("Hello")
    lbl:setText("World")
    local layout = lurek.ui.newLayout("horizontal")
    local align = layout:getAlign()
    print("label text:", lbl:getText(), "layout align:", align)
end

--@api-stub: LLabel.setText
do
    local lbl = lurek.ui.newLabel("Hello")
    lbl:setText("World")
    local layout = lurek.ui.newLayout("horizontal")
    local align = layout:getAlign()
    print("label text:", lbl:getText(), "layout align:", align)
end

--@api-stub: LLayout.getAlign
do
    local lbl = lurek.ui.newLabel("Hello")
    lbl:setText("World")
    local layout = lurek.ui.newLayout("horizontal")
    local align = layout:getAlign()
    print("label text:", lbl:getText(), "layout align:", align)
end

--@api-stub: LLayout.getDirection
do
    local layout = lurek.ui.newLayout("vertical")
    local dir = layout:getDirection()
    local justify = layout:getJustify()
    local spacing = layout:getSpacing()
    print("direction:", dir, "justify:", justify, "spacing:", spacing)
end

--@api-stub: LLayout.getJustify
do
    local layout = lurek.ui.newLayout("vertical")
    local dir = layout:getDirection()
    local justify = layout:getJustify()
    local spacing = layout:getSpacing()
    print("direction:", dir, "justify:", justify, "spacing:", spacing)
end

--@api-stub: LLayout.getSpacing
do
    local layout = lurek.ui.newLayout("vertical")
    local dir = layout:getDirection()
    local justify = layout:getJustify()
    local spacing = layout:getSpacing()
    print("direction:", dir, "justify:", justify, "spacing:", spacing)
end

--@api-stub: LLayout.getWrap
do
    local layout = lurek.ui.newLayout("grid")
    local wrap = layout:getWrap()
    layout:setAlign("center")
    layout:setColumns(3)
    print("getWrap:", wrap, "setAlign: center, setColumns: 3 ok")
end

--@api-stub: LLayout.setAlign
do
    local layout = lurek.ui.newLayout("grid")
    local wrap = layout:getWrap()
    layout:setAlign("center")
    layout:setColumns(3)
    print("getWrap:", wrap, "setAlign: center, setColumns: 3 ok")
end

--@api-stub: LLayout.setColumns
do
    local layout = lurek.ui.newLayout("grid")
    local wrap = layout:getWrap()
    layout:setAlign("center")
    layout:setColumns(3)
    print("getWrap:", wrap, "setAlign: center, setColumns: 3 ok")
end

--@api-stub: LLayout.setDirection
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setDirection("vertical")
    layout:setJustify("center")
    layout:setSpacing(8)
    print("setDirection/setJustify/setSpacing ok")
end

--@api-stub: LLayout.setJustify
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setDirection("vertical")
    layout:setJustify("center")
    layout:setSpacing(8)
    print("setDirection/setJustify/setSpacing ok")
end

--@api-stub: LLayout.setSpacing
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setDirection("vertical")
    layout:setJustify("center")
    layout:setSpacing(8)
    print("setDirection/setJustify/setSpacing ok")
end

--@api-stub: LLayout.setWrap
do
    local layout = lurek.ui.newLayout("horizontal"); layout:setWrap(true)
    local lc = lurek.ui.newLineChart({width = 200, height = 100}); lc:addSeries("speed", {{1,10},{2,20},{3,15}}, 0.2, 0.8, 0.4)
    local img = lurek.image.newImageData(200, 100)
    lc:drawToImage(img)
    print("setWrap ok; addSeries/drawToImage ok")
end

--@api-stub: LLineChart:addSeries
do
    local layout = lurek.ui.newLayout("horizontal"); layout:setWrap(true)
    local lc = lurek.ui.newLineChart({width = 200, height = 100}); lc:addSeries("speed", {{1,10},{2,20},{3,15}}, 0.2, 0.8, 0.4)
    local img = lurek.image.newImageData(200, 100)
    lc:drawToImage(img)
    print("setWrap ok; addSeries/drawToImage ok")
end

--@api-stub: LLineChart:addSeriesFromDataFrame
do
    local df = lurek.dataframe.fromRows({ "month", "savings" }, { { 1, 240 }, { 2, "260" }, { 3, "bad" } })
    local chart = lurek.ui.newLineChart({width = 200, height = 100})
    local count = chart:addSeriesFromDataFrame("Savings", df, "month", "savings", 0.2, 0.8, 0.4)
    print("line df points=" .. count)
end

--@api-stub: LLineChart:drawToImage
do
    local layout = lurek.ui.newLayout("horizontal"); layout:setWrap(true)
    local lc = lurek.ui.newLineChart({width = 200, height = 100}); lc:addSeries("speed", {{1,10},{2,20},{3,15}}, 0.2, 0.8, 0.4)
    local img = lurek.image.newImageData(200, 100)
    lc:drawToImage(img)
    print("setWrap ok; addSeries/drawToImage ok")
end

--@api-stub: LLineChart:setXMax
do
    local lc = lurek.ui.newLineChart({width = 150, height = 80}); lc:setXMax(100)
    lc:setYMax(50)
    lc:addSeries("data", {{0,0},{100,50}}, 1.0, 0.2, 0.2)
    local t = lc:type()
    print("setXMax/setYMax ok; type:", t)
end

--@api-stub: LLineChart:setYMax
do
    local lc = lurek.ui.newLineChart({width = 150, height = 80}); lc:setXMax(100)
    lc:setYMax(50)
    lc:addSeries("data", {{0,0},{100,50}}, 1.0, 0.2, 0.2)
    local t = lc:type()
    print("setXMax/setYMax ok; type:", t)
end

--@api-stub: LLineChart:type
do
    local lc = lurek.ui.newLineChart({width = 150, height = 80}); lc:setXMax(100)
    lc:setYMax(50)
    lc:addSeries("data", {{0,0},{100,50}}, 1.0, 0.2, 0.2)
    local t = lc:type()
    print("setXMax/setYMax ok; type:", t)
end

--@api-stub: LLineChart:typeOf
do
    local lc = lurek.ui.newLineChart({width = 100, height = 60})
    local ok = lc:typeOf("LLineChart")
    local notOk = lc:typeOf("LBarChart")
    print("LLineChart typeOf:", ok, "typeOf LBarChart:", notOk)
end

--@api-stub: LListBox.addItem
do
    local lb = lurek.ui.newList(); lb:addItem("Apple")
    lb:addItem("Banana"); lb:addItem("Cherry")
    local item = lb:getItem(2)
    lb:clearItems()
    print("addItem/clearItems/getItem ok, item:", item)
end

--@api-stub: LListBox.clearItems
do
    local lb = lurek.ui.newList(); lb:addItem("Apple")
    lb:addItem("Banana"); lb:addItem("Cherry")
    local item = lb:getItem(2)
    lb:clearItems()
    print("addItem/clearItems/getItem ok, item:", item)
end

--@api-stub: LListBox.getItem
do
    local lb = lurek.ui.newList(); lb:addItem("Apple")
    lb:addItem("Banana"); lb:addItem("Cherry")
    local item = lb:getItem(2)
    lb:clearItems()
    print("addItem/clearItems/getItem ok, item:", item)
end

--@api-stub: LListBox.getItemCount
do
    local lb = lurek.ui.newList(); lb:addItem("X")
    lb:addItem("Y"); lb:addItem("Z")
    local cnt = lb:getItemCount(); lb:setSelectedIndex(2)
    local sel = lb:getSelectedIndex(); lb:removeItem(1)
    print("count:", cnt, "selectedIndex:", sel, "removeItem ok")
end

--@api-stub: LListBox.getSelectedIndex
do
    local lb = lurek.ui.newList(); lb:addItem("X")
    lb:addItem("Y"); lb:addItem("Z")
    local cnt = lb:getItemCount(); lb:setSelectedIndex(2)
    local sel = lb:getSelectedIndex(); lb:removeItem(1)
    print("count:", cnt, "selectedIndex:", sel, "removeItem ok")
end

--@api-stub: LListBox.removeItem
do
    local lb = lurek.ui.newList(); lb:addItem("X")
    lb:addItem("Y"); lb:addItem("Z")
    local cnt = lb:getItemCount(); lb:setSelectedIndex(2)
    local sel = lb:getSelectedIndex(); lb:removeItem(1)
    print("count:", cnt, "selectedIndex:", sel, "removeItem ok")
end

--@api-stub: LListBox.setItemHeight
do
    local lb = lurek.ui.newList(); lb:setItemHeight(20)
    lb:addItem("Item"); lb:setSelectedIndex(1)
    local mb = lurek.ui.newMenuBar(); local mi = lurek.ui.newMenuItem("File")
    local idx = mb:addMenu(mi._idx)
    print("setItemHeight ok; addMenu idx:", idx)
end

--@api-stub: LListBox.setSelectedIndex
do
    local lb = lurek.ui.newList(); lb:setItemHeight(20)
    lb:addItem("Item"); lb:setSelectedIndex(1)
    local mb = lurek.ui.newMenuBar(); local mi = lurek.ui.newMenuItem("File")
    local idx = mb:addMenu(mi._idx)
    print("setItemHeight ok; addMenu idx:", idx)
end

--@api-stub: LMenuBar.addMenu
do
    local lb = lurek.ui.newList(); lb:setItemHeight(20)
    lb:addItem("Item"); lb:setSelectedIndex(1)
    local mb = lurek.ui.newMenuBar(); local mi = lurek.ui.newMenuItem("File")
    local idx = mb:addMenu(mi._idx)
    print("setItemHeight ok; addMenu idx:", idx)
end

--@api-stub: LMenuBar.getMenuCount
do
    local mb = lurek.ui.newMenuBar(); local mi1 = lurek.ui.newMenuItem("Edit")
    local mi2 = lurek.ui.newMenuItem("View"); mb:addMenu(mi1._idx)
    mb:addMenu(mi2._idx); local cnt = mb:getMenuCount()
    local menus = mb:getMenus(); mb:removeMenu(1)
    print("menuCount:", cnt, "getMenus ok; removeMenu ok")
end

--@api-stub: LMenuBar.getMenus
do
    local mb = lurek.ui.newMenuBar(); local mi1 = lurek.ui.newMenuItem("Edit")
    local mi2 = lurek.ui.newMenuItem("View"); mb:addMenu(mi1._idx)
    mb:addMenu(mi2._idx); local cnt = mb:getMenuCount()
    local menus = mb:getMenus(); mb:removeMenu(1)
    print("menuCount:", cnt, "getMenus ok; removeMenu ok")
end

--@api-stub: LMenuBar.removeMenu
do
    local mb = lurek.ui.newMenuBar(); local mi1 = lurek.ui.newMenuItem("Edit")
    local mi2 = lurek.ui.newMenuItem("View"); mb:addMenu(mi1._idx)
    mb:addMenu(mi2._idx); local cnt = mb:getMenuCount()
    local menus = mb:getMenus(); mb:removeMenu(1)
    print("menuCount:", cnt, "getMenus ok; removeMenu ok")
end

--@api-stub: LMenuItem.addSubItem
do
    local mi = lurek.ui.newMenuItem("Tools"); local sub1 = lurek.ui.newMenuItem("Options")
    mi:addSubItem(sub1._idx); local subs = mi:getSubItems()
    mi:setShortcut("Ctrl+T")
    local sc = mi:getShortcut()
    print("addSubItem ok; getSubItems:", type(subs), "shortcut:", sc)
end

--@api-stub: LMenuItem.getShortcut
do
    local mi = lurek.ui.newMenuItem("Tools"); local sub1 = lurek.ui.newMenuItem("Options")
    mi:addSubItem(sub1._idx); local subs = mi:getSubItems()
    mi:setShortcut("Ctrl+T")
    local sc = mi:getShortcut()
    print("addSubItem ok; getSubItems:", type(subs), "shortcut:", sc)
end

--@api-stub: LMenuItem.getSubItems
do
    local mi = lurek.ui.newMenuItem("Tools"); local sub1 = lurek.ui.newMenuItem("Options")
    mi:addSubItem(sub1._idx); local subs = mi:getSubItems()
    mi:setShortcut("Ctrl+T")
    local sc = mi:getShortcut()
    print("addSubItem ok; getSubItems:", type(subs), "shortcut:", sc)
end

--@api-stub: LMenuItem.getText
do
    local mi = lurek.ui.newMenuItem("Enable"); local t = mi:getText()
    mi:setChecked(true)
    local checked = mi:isChecked()
    mi:setChecked(false)
    print("getText:", t, "isChecked:", mi:isChecked(), "setChecked ok")
end

--@api-stub: LMenuItem.isChecked
do
    local mi = lurek.ui.newMenuItem("Enable"); local t = mi:getText()
    mi:setChecked(true)
    local checked = mi:isChecked()
    mi:setChecked(false)
    print("getText:", t, "isChecked:", mi:isChecked(), "setChecked ok")
end

--@api-stub: LMenuItem.setChecked
do
    local mi = lurek.ui.newMenuItem("Enable"); local t = mi:getText()
    mi:setChecked(true)
    local checked = mi:isChecked()
    mi:setChecked(false)
    print("getText:", t, "isChecked:", mi:isChecked(), "setChecked ok")
end

--@api-stub: LMenuItem.setOnClick
do
    local mi = lurek.ui.newMenuItem("Old")
    mi:setOnClick(function(idx) print("menu clicked", idx) end)
    mi:setShortcut("Alt+F4")
    mi:setText("New Name")
    print("setOnClick/setShortcut/setText ok")
end

--@api-stub: LMenuItem.setShortcut
do
    local mi = lurek.ui.newMenuItem("Old")
    mi:setOnClick(function(idx) print("menu clicked", idx) end)
    mi:setShortcut("Alt+F4")
    mi:setText("New Name")
    print("setOnClick/setShortcut/setText ok")
end

--@api-stub: LMenuItem.setText
do
    local mi = lurek.ui.newMenuItem("Old")
    mi:setOnClick(function(idx) print("menu clicked", idx) end)
    mi:setShortcut("Alt+F4")
    mi:setText("New Name")
    print("setOnClick/setShortcut/setText ok")
end

--@api-stub: LNinePatch.getImageDimensions
do
    local np = lurek.ui.newNinePatch(); np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions(); np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    local slices = np:getSlices()
    print("imgDims:", w, h, "insets:", l, t, r, b, "slices:", type(slices))
end

--@api-stub: LNinePatch.getInsets
do
    local np = lurek.ui.newNinePatch(); np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions(); np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    local slices = np:getSlices()
    print("imgDims:", w, h, "insets:", l, t, r, b, "slices:", type(slices))
end

--@api-stub: LNinePatch.getSlices
do
    local np = lurek.ui.newNinePatch(); np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions(); np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    local slices = np:getSlices()
    print("imgDims:", w, h, "insets:", l, t, r, b, "slices:", type(slices))
end

--@api-stub: LNinePatch.setImageDimensions
do
    local np = lurek.ui.newNinePatch(); np:setImageDimensions(32, 32)
    np:setInsets(4, 4, 4, 4); local l, t, r, b = np:getInsets()
    local panel = lurek.ui.newPanel(); panel:setTitle("My Panel")
    local title = panel:getTitle()
    print("setInsets ok; panel title:", title)
end

--@api-stub: LNinePatch.setInsets
do
    local np = lurek.ui.newNinePatch(); np:setImageDimensions(32, 32)
    np:setInsets(4, 4, 4, 4); local l, t, r, b = np:getInsets()
    local panel = lurek.ui.newPanel(); panel:setTitle("My Panel")
    local title = panel:getTitle()
    print("setInsets ok; panel title:", title)
end

--@api-stub: LPanel.getTitle
do
    local np = lurek.ui.newNinePatch(); np:setImageDimensions(32, 32)
    np:setInsets(4, 4, 4, 4); local l, t, r, b = np:getInsets()
    local panel = lurek.ui.newPanel(); panel:setTitle("My Panel")
    local title = panel:getTitle()
    print("setInsets ok; panel title:", title)
end

--@api-stub: LPanel.setScrollable
do
    local panel = lurek.ui.newPanel(); panel:setScrollable(true)
    panel:setTitle("Data"); local pc = lurek.ui.newPieChart({width = 128, height = 128})
    pc:addSegment("A", 30, 0.9, 0.2, 0.2); pc:addSegment("B", 50, 0.2, 0.9, 0.2)
    pc:addSegment("C", 20, 0.2, 0.2, 0.9)
    print("panel scrollable ok; pie segments added")
end

--@api-stub: LPanel.setTitle
do
    local panel = lurek.ui.newPanel(); panel:setScrollable(true)
    panel:setTitle("Data"); local pc = lurek.ui.newPieChart({width = 128, height = 128})
    pc:addSegment("A", 30, 0.9, 0.2, 0.2); pc:addSegment("B", 50, 0.2, 0.9, 0.2)
    pc:addSegment("C", 20, 0.2, 0.2, 0.9)
    print("panel scrollable ok; pie segments added")
end

--@api-stub: LPieChart:addSegment
do
    local panel = lurek.ui.newPanel(); panel:setScrollable(true)
    panel:setTitle("Data"); local pc = lurek.ui.newPieChart({width = 128, height = 128})
    pc:addSegment("A", 30, 0.9, 0.2, 0.2); pc:addSegment("B", 50, 0.2, 0.9, 0.2)
    pc:addSegment("C", 20, 0.2, 0.2, 0.9)
    print("panel scrollable ok; pie segments added")
end

--@api-stub: LPieChart:addSegmentsFromDataFrame
do
    local df = lurek.dataframe.fromRows({ "category", "amount" }, { { "Food", 420 }, { "Rent", "1200" }, { "Skip", "bad" } })
    local chart = lurek.ui.newPieChart({width = 128, height = 128})
    local count = chart:addSegmentsFromDataFrame(df, "category", "amount")
    print("pie df segments=" .. count)
end

--@api-stub: LPieChart:drawToImage
do
    local pc = lurek.ui.newPieChart({width = 64, height = 64}); pc:addSegment("X", 60, 1.0, 0.5, 0.1)
    pc:addSegment("Y", 40, 0.1, 0.5, 1.0); local img = lurek.image.newImageData(64, 64)
    pc:drawToImage(img); local t = pc:type()
    local ok = pc:typeOf("LPieChart")
    print("drawToImage ok, type:", t, "typeOf:", ok)
end

--@api-stub: LPieChart:type
do
    local pc = lurek.ui.newPieChart({width = 64, height = 64}); pc:addSegment("X", 60, 1.0, 0.5, 0.1)
    pc:addSegment("Y", 40, 0.1, 0.5, 1.0); local img = lurek.image.newImageData(64, 64)
    pc:drawToImage(img); local t = pc:type()
    local ok = pc:typeOf("LPieChart")
    print("drawToImage ok, type:", t, "typeOf:", ok)
end

--@api-stub: LPieChart:typeOf
do
    local pc = lurek.ui.newPieChart({width = 64, height = 64}); pc:addSegment("X", 60, 1.0, 0.5, 0.1)
    pc:addSegment("Y", 40, 0.1, 0.5, 1.0); local img = lurek.image.newImageData(64, 64)
    pc:drawToImage(img); local t = pc:type()
    local ok = pc:typeOf("LPieChart")
    print("drawToImage ok, type:", t, "typeOf:", ok)
end

--@api-stub: LProgressBar.getMax
do
    local pb = lurek.ui.newProgressBar(0, 100); local mn = pb:getMin()
    local mx = pb:getMax()
    pb:setValue(75)
    local prog = pb:getProgress()
    print("min:", mn, "max:", mx, "progress:", prog)
end

--@api-stub: LProgressBar.getMin
do
    local pb = lurek.ui.newProgressBar(0, 100); local mn = pb:getMin()
    local mx = pb:getMax()
    pb:setValue(75)
    local prog = pb:getProgress()
    print("min:", mn, "max:", mx, "progress:", prog)
end

--@api-stub: LProgressBar.getProgress
do
    local pb = lurek.ui.newProgressBar(0, 100); local mn = pb:getMin()
    local mx = pb:getMax()
    pb:setValue(75)
    local prog = pb:getProgress()
    print("min:", mn, "max:", mx, "progress:", prog)
end

--@api-stub: LProgressBar.getValue
do
    local pb = lurek.ui.newProgressBar(0, 200); pb:setValue(100)
    local v = pb:getValue()
    pb:setRange(10, 90)
    pb:setValue(50)
    print("getValue:", v, "setRange ok, setValue ok")
end

--@api-stub: LProgressBar.setRange
do
    local pb = lurek.ui.newProgressBar(0, 200); pb:setValue(100)
    local v = pb:getValue()
    pb:setRange(10, 90)
    pb:setValue(50)
    print("getValue:", v, "setRange ok, setValue ok")
end

--@api-stub: LProgressBar.setValue
do
    local pb = lurek.ui.newProgressBar(0, 200); pb:setValue(100)
    local v = pb:getValue()
    pb:setRange(10, 90)
    pb:setValue(50)
    print("getValue:", v, "setRange ok, setValue ok")
end

--@api-stub: LRadioButton.getGroup
do
    local rb = lurek.ui.newRadioButton("Option A", "group1")
    local grp = rb:getGroup()
    local t = rb:getText()
    local sel = rb:isSelected()
    print("group:", grp, "text:", t, "isSelected:", sel)
end

--@api-stub: LRadioButton.getText
do
    local rb = lurek.ui.newRadioButton("Option A", "group1")
    local grp = rb:getGroup()
    local t = rb:getText()
    local sel = rb:isSelected()
    print("group:", grp, "text:", t, "isSelected:", sel)
end

--@api-stub: LRadioButton.isSelected
do
    local rb = lurek.ui.newRadioButton("Option A", "group1")
    local grp = rb:getGroup()
    local t = rb:getText()
    local sel = rb:isSelected()
    print("group:", grp, "text:", t, "isSelected:", sel)
end

--@api-stub: LRadioButton.setGroup
do
    local rb = lurek.ui.newRadioButton("B", "g1"); rb:setGroup("g2")
    rb:setSelected(true)
    rb:setOnChange(function(idx) print("radio changed", idx) end)
    rb:setText("New B")
    print("setGroup/setSelected/setOnChange/setText ok")
end

--@api-stub: LRadioButton.setOnChange
do
    local rb = lurek.ui.newRadioButton("B", "g1"); rb:setGroup("g2")
    rb:setSelected(true)
    rb:setOnChange(function(idx) print("radio changed", idx) end)
    rb:setText("New B")
    print("setGroup/setSelected/setOnChange/setText ok")
end

--@api-stub: LRadioButton.setSelected
do
    local rb = lurek.ui.newRadioButton("B", "g1"); rb:setGroup("g2")
    rb:setSelected(true)
    rb:setOnChange(function(idx) print("radio changed", idx) end)
    rb:setText("New B")
    print("setGroup/setSelected/setOnChange/setText ok")
end

--@api-stub: LRadioButton.setText
do
    local rb = lurek.ui.newRadioButton("original", "group_test")
    rb:setText("updated")
    print("LRadioButton setText:", rb:getText())
end

--@api-stub: LScatterPlot:addSeries
do
    local sp = lurek.ui.newScatterPlot({width = 200, height = 150}); sp:setXRange(0, 100)
    sp:setYRange(0, 100); sp:addSeries("data1", {{10,20},{30,40},{50,30},{70,60}}, 0.9, 0.2, 0.2)
    local img = lurek.image.newImageData(200, 150)
    sp:drawToImage(img)
    print("ScatterPlot addSeries/setXRange/drawToImage ok")
end

--@api-stub: LScatterPlot:drawToImage
do
    local sp = lurek.ui.newScatterPlot({width = 200, height = 150}); sp:setXRange(0, 100)
    sp:setYRange(0, 100); sp:addSeries("data1", {{10,20},{30,40},{50,30},{70,60}}, 0.9, 0.2, 0.2)
    local img = lurek.image.newImageData(200, 150)
    sp:drawToImage(img)
    print("ScatterPlot addSeries/setXRange/drawToImage ok")
end

--@api-stub: LScatterPlot:setXRange
do
    local sp = lurek.ui.newScatterPlot({width = 200, height = 150}); sp:setXRange(0, 100)
    sp:setYRange(0, 100); sp:addSeries("data1", {{10,20},{30,40},{50,30},{70,60}}, 0.9, 0.2, 0.2)
    local img = lurek.image.newImageData(200, 150)
    sp:drawToImage(img)
    print("ScatterPlot addSeries/setXRange/drawToImage ok")
end

--@api-stub: LScatterPlot:setYRange
do
    local sp = lurek.ui.newScatterPlot({width = 100, height = 80}); sp:setXRange(0, 50)
    sp:setYRange(0, 50)
    local t = sp:type()
    local ok = sp:typeOf("LScatterPlot")
    print("setYRange ok, type:", t, "typeOf:", ok)
end

--@api-stub: LScatterPlot:type
do
    local sp = lurek.ui.newScatterPlot({width = 100, height = 80}); sp:setXRange(0, 50)
    sp:setYRange(0, 50)
    local t = sp:type()
    local ok = sp:typeOf("LScatterPlot")
    print("setYRange ok, type:", t, "typeOf:", ok)
end

--@api-stub: LScatterPlot:typeOf
do
    local sp = lurek.ui.newScatterPlot({width = 100, height = 80}); sp:setXRange(0, 50)
    sp:setYRange(0, 50)
    local t = sp:type()
    local ok = sp:typeOf("LScatterPlot")
    print("setYRange ok, type:", t, "typeOf:", ok)
end

--@api-stub: LScrollBar.getContentSize
do
    local sb = lurek.ui.newScrollBar(true)
    local cs = sb:getContentSize()
    local pos = sb:getScrollPosition()
    local vs = sb:getViewSize()
    print("contentSize:", cs, "scrollPos:", pos, "viewSize:", vs)
end

--@api-stub: LScrollBar.getScrollPosition
do
    local sb = lurek.ui.newScrollBar(true)
    local cs = sb:getContentSize()
    local pos = sb:getScrollPosition()
    local vs = sb:getViewSize()
    print("contentSize:", cs, "scrollPos:", pos, "viewSize:", vs)
end

--@api-stub: LScrollBar.getViewSize
do
    local sb = lurek.ui.newScrollBar(true)
    local cs = sb:getContentSize()
    local pos = sb:getScrollPosition()
    local vs = sb:getViewSize()
    print("contentSize:", cs, "scrollPos:", pos, "viewSize:", vs)
end

--@api-stub: LScrollBar.isVertical
do
    local sb = lurek.ui.newScrollBar(false); local vert = sb:isVertical()
    sb:setContentSize(500)
    sb:setOnChange(function(val) print("scroll:", val) end)
    local cs = sb:getContentSize()
    print("isVertical:", vert, "contentSize after set:", cs)
end

--@api-stub: LScrollBar.setContentSize
do
    local sb = lurek.ui.newScrollBar(false); local vert = sb:isVertical()
    sb:setContentSize(500)
    sb:setOnChange(function(val) print("scroll:", val) end)
    local cs = sb:getContentSize()
    print("isVertical:", vert, "contentSize after set:", cs)
end

--@api-stub: LScrollBar.setOnChange
do
    local sb = lurek.ui.newScrollBar(false); local vert = sb:isVertical()
    sb:setContentSize(500)
    sb:setOnChange(function(val) print("scroll:", val) end)
    local cs = sb:getContentSize()
    print("isVertical:", vert, "contentSize after set:", cs)
end

--@api-stub: LScrollBar.setScrollPosition
do
    local sb = lurek.ui.newScrollBar(true); sb:setContentSize(800)
    sb:setViewSize(200); sb:setScrollPosition(100)
    local pos = sb:getScrollPosition(); local sp = lurek.ui.newScrollPanel()
    local cw, ch = sp:getContentSize()
    print("scrollPos:", pos, "panel contentSize:", cw, ch)
end

--@api-stub: LScrollBar.setViewSize
do
    local sb = lurek.ui.newScrollBar(true); sb:setContentSize(800)
    sb:setViewSize(200); sb:setScrollPosition(100)
    local pos = sb:getScrollPosition(); local sp = lurek.ui.newScrollPanel()
    local cw, ch = sp:getContentSize()
    print("scrollPos:", pos, "panel contentSize:", cw, ch)
end

--@api-stub: LScrollPanel.getContentSize
do
    local sb = lurek.ui.newScrollBar(true); sb:setContentSize(800)
    sb:setViewSize(200); sb:setScrollPosition(100)
    local pos = sb:getScrollPosition(); local sp = lurek.ui.newScrollPanel()
    local cw, ch = sp:getContentSize()
    print("scrollPos:", pos, "panel contentSize:", cw, ch)
end

--@api-stub: LScrollPanel.getMaxScroll
do
    local sp = lurek.ui.newScrollPanel()
    local mx, my = sp:getMaxScroll()
    local px, py = sp:getScrollPosition()
    local speed = sp:getScrollSpeed()
    print("maxScroll:", mx, my, "scrollPos:", px, py, "speed:", speed)
end

--@api-stub: LScrollPanel.getScrollPosition
do
    local sp = lurek.ui.newScrollPanel()
    local mx, my = sp:getMaxScroll()
    local px, py = sp:getScrollPosition()
    local speed = sp:getScrollSpeed()
    print("maxScroll:", mx, my, "scrollPos:", px, py, "speed:", speed)
end

--@api-stub: LScrollPanel.getScrollSpeed
do
    local sp = lurek.ui.newScrollPanel()
    local mx, my = sp:getMaxScroll()
    local px, py = sp:getScrollPosition()
    local speed = sp:getScrollSpeed()
    print("maxScroll:", mx, my, "scrollPos:", px, py, "speed:", speed)
end

--@api-stub: LScrollPanel.setContentSize
do
    local sp = lurek.ui.newScrollPanel(); sp:setContentSize(800, 600)
    local cw, ch = sp:getContentSize(); sp:setScrollPosition(50, 100)
    local px, py = sp:getScrollPosition(); sp:setScrollSpeed(3.0)
    local speed = sp:getScrollSpeed()
    print("contentSize:", cw, ch, "scrollPos:", px, py, "speed:", speed)
end

--@api-stub: LScrollPanel.setScrollPosition
do
    local sp = lurek.ui.newScrollPanel(); sp:setContentSize(800, 600)
    local cw, ch = sp:getContentSize(); sp:setScrollPosition(50, 100)
    local px, py = sp:getScrollPosition(); sp:setScrollSpeed(3.0)
    local speed = sp:getScrollSpeed()
    print("contentSize:", cw, ch, "scrollPos:", px, py, "speed:", speed)
end

--@api-stub: LScrollPanel.setScrollSpeed
do
    local sp = lurek.ui.newScrollPanel(); sp:setContentSize(800, 600)
    local cw, ch = sp:getContentSize(); sp:setScrollPosition(50, 100)
    local px, py = sp:getScrollPosition(); sp:setScrollSpeed(3.0)
    local speed = sp:getScrollSpeed()
    print("contentSize:", cw, ch, "scrollPos:", px, py, "speed:", speed)
end

--@api-stub: LSeparator.getThickness
do
    local sep = lurek.ui.newSeparator(true); local vert = sep:isVertical()
    local thick = sep:getThickness()
    sep:setThickness(4)
    local t2 = sep:getThickness()
    print("isVertical:", vert, "thickness:", thick, "â†’", t2)
end

--@api-stub: LSeparator.isVertical
do
    local sep = lurek.ui.newSeparator(true); local vert = sep:isVertical()
    local thick = sep:getThickness()
    sep:setThickness(4)
    local t2 = sep:getThickness()
    print("isVertical:", vert, "thickness:", thick, "â†’", t2)
end

--@api-stub: LSeparator.setThickness
do
    local sep = lurek.ui.newSeparator(true); local vert = sep:isVertical()
    local thick = sep:getThickness()
    sep:setThickness(4)
    local t2 = sep:getThickness()
    print("isVertical:", vert, "thickness:", thick, "â†’", t2)
end

--@api-stub: LSeparator.setVertical
do
    local sep = lurek.ui.newSeparator(false); sep:setVertical(true)
    local sl = lurek.ui.newSlider(0, 100)
    local mn = sl:getMin()
    local mx = sl:getMax()
    print("separator setVertical ok; slider min:", mn, "max:", mx)
end

--@api-stub: LSlider.getMax
do
    local sep = lurek.ui.newSeparator(false); sep:setVertical(true)
    local sl = lurek.ui.newSlider(0, 100)
    local mn = sl:getMin()
    local mx = sl:getMax()
    print("separator setVertical ok; slider min:", mn, "max:", mx)
end

--@api-stub: LSlider.getMin
do
    local sep = lurek.ui.newSeparator(false); sep:setVertical(true)
    local sl = lurek.ui.newSlider(0, 100)
    local mn = sl:getMin()
    local mx = sl:getMax()
    print("separator setVertical ok; slider min:", mn, "max:", mx)
end

--@api-stub: LSlider.getValue
do
    local sl = lurek.ui.newSlider(0, 50); sl:setRange(0, 100)
    local mx = sl:getMax(); sl:setStep(5)
    sl:setValue(75)
    local v = sl:getValue()
    print("setRange max:", mx, "getValue:", v)
end

--@api-stub: LSlider.setRange
do
    local sl = lurek.ui.newSlider(0, 50); sl:setRange(0, 100)
    local mx = sl:getMax(); sl:setStep(5)
    sl:setValue(75)
    local v = sl:getValue()
    print("setRange max:", mx, "getValue:", v)
end

--@api-stub: LSlider.setStep
do
    local sl = lurek.ui.newSlider(0, 50); sl:setRange(0, 100)
    local mx = sl:getMax(); sl:setStep(5)
    sl:setValue(75)
    local v = sl:getValue()
    print("setRange max:", mx, "getValue:", v)
end

--@api-stub: LSlider.setValue
do
    local sl = lurek.ui.newSlider(0, 10); sl:setValue(7)
    local v = sl:getValue(); local sb = lurek.ui.newSpinBox(0, 10)
    sb:setValue(5); sb:decrement()
    local sv = sb:getValue()
    print("slider value:", v, "spinbox after decrement:", sv)
end

--@api-stub: LSpinBox.decrement
do
    local sl = lurek.ui.newSlider(0, 10); sl:setValue(7)
    local v = sl:getValue(); local sb = lurek.ui.newSpinBox(0, 10)
    sb:setValue(5); sb:decrement()
    local sv = sb:getValue()
    print("slider value:", v, "spinbox after decrement:", sv)
end

--@api-stub: LSpinBox.getValue
do
    local sl = lurek.ui.newSlider(0, 10); sl:setValue(7)
    local v = sl:getValue(); local sb = lurek.ui.newSpinBox(0, 10)
    sb:setValue(5); sb:decrement()
    local sv = sb:getValue()
    print("slider value:", v, "spinbox after decrement:", sv)
end

--@api-stub: LSpinBox.increment
do
    local sb = lurek.ui.newSpinBox(0, 100); sb:setValue(10)
    sb:increment(); local v = sb:getValue()
    sb:setRange(5, 50); sb:setStep(2)
    local v2 = sb:getValue()
    print("after increment:", v, "after setRange/setStep:", v2)
end

--@api-stub: LSpinBox.setRange
do
    local sb = lurek.ui.newSpinBox(0, 100); sb:setValue(10)
    sb:increment(); local v = sb:getValue()
    sb:setRange(5, 50); sb:setStep(2)
    local v2 = sb:getValue()
    print("after increment:", v, "after setRange/setStep:", v2)
end

--@api-stub: LSpinBox.setStep
do
    local sb = lurek.ui.newSpinBox(0, 100); sb:setValue(10)
    sb:increment(); local v = sb:getValue()
    sb:setRange(5, 50); sb:setStep(2)
    local v2 = sb:getValue()
    print("after increment:", v, "after setRange/setStep:", v2)
end

--@api-stub: LSpinBox.setValue
do
    local sb = lurek.ui.newSpinBox(1, 100); sb:setValue(42)
    local v = sb:getValue(); sb:setValue(1)
    local v2 = sb:getValue(); sb:setValue(100)
    local v3 = sb:getValue()
    print("setValue: 42â†’", v, "1â†’", v2, "100â†’", v3)
end

--@api-stub: LSplitPanel.getFirstChild
do
    local sp = lurek.ui.newSplitPanel("horizontal"); local fc = sp:getFirstChild()
    local sc = sp:getSecondChild()
    local ori = sp:getOrientation()
    local mps = sp:getMinPanelSize()
    print("firstChild:", fc, "secondChild:", sc, "orientation:", ori, "minPanel:", mps)
end

--@api-stub: LSplitPanel.getMinPanelSize
do
    local sp = lurek.ui.newSplitPanel("horizontal"); local fc = sp:getFirstChild()
    local sc = sp:getSecondChild()
    local ori = sp:getOrientation()
    local mps = sp:getMinPanelSize()
    print("firstChild:", fc, "secondChild:", sc, "orientation:", ori, "minPanel:", mps)
end

--@api-stub: LSplitPanel.getOrientation
do
    local sp = lurek.ui.newSplitPanel("horizontal"); local fc = sp:getFirstChild()
    local sc = sp:getSecondChild()
    local ori = sp:getOrientation()
    local mps = sp:getMinPanelSize()
    print("firstChild:", fc, "secondChild:", sc, "orientation:", ori, "minPanel:", mps)
end

--@api-stub: LSplitPanel.getSecondChild
do
    local sp = lurek.ui.newSplitPanel("vertical"); local lbl = lurek.ui.newLabel("left")
    local btn = lurek.ui.newButton("right"); sp:setFirstChild(lbl:getId() and 1 or 1)
    local fc = sp:getFirstChild(); sp:setSecondChild(btn:getId() and 2 or 2)
    local pos = sp:getSplitPosition()
    print("firstChild after set:", fc, "splitPos:", pos)
end

--@api-stub: LSplitPanel.getSplitPosition
do
    local sp = lurek.ui.newSplitPanel("vertical"); local lbl = lurek.ui.newLabel("left")
    local btn = lurek.ui.newButton("right"); sp:setFirstChild(lbl:getId() and 1 or 1)
    local fc = sp:getFirstChild(); sp:setSecondChild(btn:getId() and 2 or 2)
    local pos = sp:getSplitPosition()
    print("firstChild after set:", fc, "splitPos:", pos)
end

--@api-stub: LSplitPanel.setFirstChild
do
    local sp = lurek.ui.newSplitPanel("vertical"); local lbl = lurek.ui.newLabel("left")
    local btn = lurek.ui.newButton("right"); sp:setFirstChild(lbl:getId() and 1 or 1)
    local fc = sp:getFirstChild(); sp:setSecondChild(btn:getId() and 2 or 2)
    local pos = sp:getSplitPosition()
    print("firstChild after set:", fc, "splitPos:", pos)
end

--@api-stub: LSplitPanel.setMinPanelSize
do
    local sp = lurek.ui.newSplitPanel("horizontal"); sp:setOrientation("vertical")
    local ori = sp:getOrientation(); sp:setMinPanelSize(80)
    local mps = sp:getMinPanelSize(); local lbl = lurek.ui.newLabel("panel")
    sp:setSecondChild(lbl:getId() and 1 or 1)
    print("orientation:", ori, "minPanel:", mps)
end

--@api-stub: LSplitPanel.setOrientation
do
    local sp = lurek.ui.newSplitPanel("horizontal"); sp:setOrientation("vertical")
    local ori = sp:getOrientation(); sp:setMinPanelSize(80)
    local mps = sp:getMinPanelSize(); local lbl = lurek.ui.newLabel("panel")
    sp:setSecondChild(lbl:getId() and 1 or 1)
    print("orientation:", ori, "minPanel:", mps)
end

--@api-stub: LSplitPanel.setSecondChild
do
    local sp = lurek.ui.newSplitPanel("horizontal"); sp:setOrientation("vertical")
    local ori = sp:getOrientation(); sp:setMinPanelSize(80)
    local mps = sp:getMinPanelSize(); local lbl = lurek.ui.newLabel("panel")
    sp:setSecondChild(lbl:getId() and 1 or 1)
    print("orientation:", ori, "minPanel:", mps)
end

--@api-stub: LSplitPanel.setSplitPosition
do
    local sp = lurek.ui.newSplitPanel("horizontal"); sp:setSplitPosition(200)
    local pos = sp:getSplitPosition(); local sb = lurek.ui.newStatusBar()
    sb:addSection("Ready", 100)
    local cnt = sb:getSectionCount()
    print("splitPos:", pos, "statusBar sectionCount:", cnt)
end

--@api-stub: LStatusBar.addSection
do
    local sp = lurek.ui.newSplitPanel("horizontal"); sp:setSplitPosition(200)
    local pos = sp:getSplitPosition(); local sb = lurek.ui.newStatusBar()
    sb:addSection("Ready", 100)
    local cnt = sb:getSectionCount()
    print("splitPos:", pos, "statusBar sectionCount:", cnt)
end

--@api-stub: LStatusBar.getSectionCount
do
    local sp = lurek.ui.newSplitPanel("horizontal"); sp:setSplitPosition(200)
    local pos = sp:getSplitPosition(); local sb = lurek.ui.newStatusBar()
    sb:addSection("Ready", 100)
    local cnt = sb:getSectionCount()
    print("splitPos:", pos, "statusBar sectionCount:", cnt)
end

--@api-stub: LStatusBar.getSectionText
do
    local sb = lurek.ui.newStatusBar(); sb:setSectionCount(3)
    local cnt = sb:getSectionCount(); sb:setSectionText(1, "Line 1")
    local txt = sb:getSectionText(1)
    sb:setSectionText(2, "Col 5")
    print("sectionCount:", cnt, "section1:", txt)
end

--@api-stub: LStatusBar.setSectionCount
do
    local sb = lurek.ui.newStatusBar(); sb:setSectionCount(3)
    local cnt = sb:getSectionCount(); sb:setSectionText(1, "Line 1")
    local txt = sb:getSectionText(1)
    sb:setSectionText(2, "Col 5")
    print("sectionCount:", cnt, "section1:", txt)
end

--@api-stub: LStatusBar.setSectionText
do
    local sb = lurek.ui.newStatusBar(); sb:setSectionCount(3)
    local cnt = sb:getSectionCount(); sb:setSectionText(1, "Line 1")
    local txt = sb:getSectionText(1)
    sb:setSectionText(2, "Col 5")
    print("sectionCount:", cnt, "section1:", txt)
end

--@api-stub: LStatusBar.setSectionWidget
do
    local sb = lurek.ui.newStatusBar(); sb:setSectionCount(2)
    local lbl = lurek.ui.newLabel("status"); sb:setSectionWidget(1, lbl)
    local sw = lurek.ui.newSwitch(false); local on = sw:isOn()
    sw:setOn(true)
    print("sectionWidget set ok; switch isOn:", sw:isOn())
end

--@api-stub: LSwitch.isOn
do
    local sb = lurek.ui.newStatusBar(); sb:setSectionCount(2)
    local lbl = lurek.ui.newLabel("status"); sb:setSectionWidget(1, lbl)
    local sw = lurek.ui.newSwitch(false); local on = sw:isOn()
    sw:setOn(true)
    print("sectionWidget set ok; switch isOn:", sw:isOn())
end

--@api-stub: LSwitch.setOn
do
    local sb = lurek.ui.newStatusBar(); sb:setSectionCount(2)
    local lbl = lurek.ui.newLabel("status"); sb:setSectionWidget(1, lbl)
    local sw = lurek.ui.newSwitch(false); local on = sw:isOn()
    sw:setOn(true)
    print("sectionWidget set ok; switch isOn:", sw:isOn())
end

--@api-stub: LSwitch.toggle
do
    local sw = lurek.ui.newSwitch(false); sw:toggle()
    local on = sw:isOn(); local tb = lurek.ui.newTabBar()
    tb:addTab("Tab 1"); tb:addTab("Tab 2")
    local active = tb:getActiveTab()
    print("switch after toggle:", on, "activeTab:", active)
end

--@api-stub: LTabBar.addTab
do
    local sw = lurek.ui.newSwitch(false); sw:toggle()
    local on = sw:isOn(); local tb = lurek.ui.newTabBar()
    tb:addTab("Tab 1"); tb:addTab("Tab 2")
    local active = tb:getActiveTab()
    print("switch after toggle:", on, "activeTab:", active)
end

--@api-stub: LTabBar.getActiveTab
do
    local sw = lurek.ui.newSwitch(false); sw:toggle()
    local on = sw:isOn(); local tb = lurek.ui.newTabBar()
    tb:addTab("Tab 1"); tb:addTab("Tab 2")
    local active = tb:getActiveTab()
    print("switch after toggle:", on, "activeTab:", active)
end

--@api-stub: LTabBar.getTab
do
    local tb = lurek.ui.newTabBar(); tb:addTab("Alpha")
    tb:addTab("Beta"); tb:addTab("Gamma")
    local cnt = tb:getTabCount(); local label = tb:getTab(1)
    tb:removeTab(3); local cnt2 = tb:getTabCount()
    print("tabCount:", cnt, "tab1:", label, "after remove:", cnt2)
end

--@api-stub: LTabBar.getTabCount
do
    local tb = lurek.ui.newTabBar(); tb:addTab("Alpha")
    tb:addTab("Beta"); tb:addTab("Gamma")
    local cnt = tb:getTabCount(); local label = tb:getTab(1)
    tb:removeTab(3); local cnt2 = tb:getTabCount()
    print("tabCount:", cnt, "tab1:", label, "after remove:", cnt2)
end

--@api-stub: LTabBar.removeTab
do
    local tb = lurek.ui.newTabBar(); tb:addTab("Alpha")
    tb:addTab("Beta"); tb:addTab("Gamma")
    local cnt = tb:getTabCount(); local label = tb:getTab(1)
    tb:removeTab(3); local cnt2 = tb:getTabCount()
    print("tabCount:", cnt, "tab1:", label, "after remove:", cnt2)
end

--@api-stub: LTabBar.setActiveTab
do
    local tb = lurek.ui.newTabBar(); tb:addTab("First")
    tb:addTab("Second"); tb:setActiveTab(2)
    local active = tb:getActiveTab(); tb:setActiveTab(1)
    local a2 = tb:getActiveTab()
    print("setActiveTab to 2:", active, "then to 1:", a2)
end

--@api-stub: LTextInput.getCursorPosition
do
    local ti = lurek.ui.newTextInput(); ti:setText("hello")
    local txt = ti:getText(); ti:setPlaceholder("type here")
    local ph = ti:getPlaceholder()
    local cur = ti:getCursorPosition()
    print("text:", txt, "placeholder:", ph, "cursor:", cur)
end

--@api-stub: LTextInput.getPlaceholder
do
    local ti = lurek.ui.newTextInput(); ti:setText("hello")
    local txt = ti:getText(); ti:setPlaceholder("type here")
    local ph = ti:getPlaceholder()
    local cur = ti:getCursorPosition()
    print("text:", txt, "placeholder:", ph, "cursor:", cur)
end

--@api-stub: LTextInput.getText
do
    local ti = lurek.ui.newTextInput(); ti:setText("hello")
    local txt = ti:getText(); ti:setPlaceholder("type here")
    local ph = ti:getPlaceholder()
    local cur = ti:getCursorPosition()
    print("text:", txt, "placeholder:", ph, "cursor:", cur)
end

--@api-stub: LTextInput.isFocused
do
    local ti = lurek.ui.newTextInput(); ti:setPlaceholder("Search...")
    local ph = ti:getPlaceholder()
    ti:setMaxLength(50)
    local focused = ti:isFocused()
    print("placeholder:", ph, "isFocused:", focused)
end

--@api-stub: LTextInput.setMaxLength
do
    local ti = lurek.ui.newTextInput(); ti:setPlaceholder("Search...")
    local ph = ti:getPlaceholder()
    ti:setMaxLength(50)
    local focused = ti:isFocused()
    print("placeholder:", ph, "isFocused:", focused)
end

--@api-stub: LTextInput.setPlaceholder
do
    local ti = lurek.ui.newTextInput(); ti:setPlaceholder("Search...")
    local ph = ti:getPlaceholder()
    ti:setMaxLength(50)
    local focused = ti:isFocused()
    print("placeholder:", ph, "isFocused:", focused)
end

--@api-stub: LTextInput.setText
do
    local ti = lurek.ui.newTextInput(); ti:setText("sample input")
    local txt = ti:getText(); local th = lurek.ui.newTheme()
    th:setStyle("LButton", "normal", {bg_color = {0.2, 0.3, 0.8}})
    local t = th:type()
    print("text:", txt, "theme type:", t)
end

--@api-stub: LTheme:setStyle
do
    local ti = lurek.ui.newTextInput(); ti:setText("sample input")
    local txt = ti:getText(); local th = lurek.ui.newTheme()
    th:setStyle("LButton", "normal", {bg_color = {0.2, 0.3, 0.8}})
    local t = th:type()
    print("text:", txt, "theme type:", t)
end

--@api-stub: LTheme:type
do
    local ti = lurek.ui.newTextInput(); ti:setText("sample input")
    local txt = ti:getText(); local th = lurek.ui.newTheme()
    th:setStyle("LButton", "normal", {bg_color = {0.2, 0.3, 0.8}})
    local t = th:type()
    print("text:", txt, "theme type:", t)
end

--@api-stub: LTheme:typeOf
do
    local th = lurek.ui.newTheme(); local ok = th:typeOf("LTheme")
    local toast = lurek.ui.newToast("Level up!", 3.0)
    local dur = toast:getDuration()
    local msg = toast:getMessage()
    print("theme typeOf:", ok, "duration:", dur, "message:", msg)
end

--@api-stub: LToast.getDuration
do
    local th = lurek.ui.newTheme(); local ok = th:typeOf("LTheme")
    local toast = lurek.ui.newToast("Level up!", 3.0)
    local dur = toast:getDuration()
    local msg = toast:getMessage()
    print("theme typeOf:", ok, "duration:", dur, "message:", msg)
end

--@api-stub: LToast.getMessage
do
    local th = lurek.ui.newTheme(); local ok = th:typeOf("LTheme")
    local toast = lurek.ui.newToast("Level up!", 3.0)
    local dur = toast:getDuration()
    local msg = toast:getMessage()
    print("theme typeOf:", ok, "duration:", dur, "message:", msg)
end

--@api-stub: LToast.getProgress
do
    local toast = lurek.ui.newToast("Achievement unlocked", 2.0); local prog = toast:getProgress()
    local exp = toast:isExpired()
    toast:setDuration(5.0)
    local dur = toast:getDuration()
    print("progress:", prog, "isExpired:", exp, "duration:", dur)
end

--@api-stub: LToast.isExpired
do
    local toast = lurek.ui.newToast("Achievement unlocked", 2.0); local prog = toast:getProgress()
    local exp = toast:isExpired()
    toast:setDuration(5.0)
    local dur = toast:getDuration()
    print("progress:", prog, "isExpired:", exp, "duration:", dur)
end

--@api-stub: LToast.setDuration
do
    local toast = lurek.ui.newToast("Achievement unlocked", 2.0); local prog = toast:getProgress()
    local exp = toast:isExpired()
    toast:setDuration(5.0)
    local dur = toast:getDuration()
    print("progress:", prog, "isExpired:", exp, "duration:", dur)
end

--@api-stub: LToast.setMessage
do
    local toast = lurek.ui.newToast("old message", 2.0); toast:setMessage("new message")
    local msg = toast:getMessage(); local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("save", "Save file"); tb:addSeparator()
    tb:addButton("open", "Open file")
    print("toast:", msg, "toolbar buttons added ok")
end

--@api-stub: LToolbar.addButton
do
    local toast = lurek.ui.newToast("old message", 2.0); toast:setMessage("new message")
    local msg = toast:getMessage(); local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("save", "Save file"); tb:addSeparator()
    tb:addButton("open", "Open file")
    print("toast:", msg, "toolbar buttons added ok")
end

--@api-stub: LToolbar.addSeparator
do
    local toast = lurek.ui.newToast("old message", 2.0); toast:setMessage("new message")
    local msg = toast:getMessage(); local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("save", "Save file"); tb:addSeparator()
    tb:addButton("open", "Open file")
    print("toast:", msg, "toolbar buttons added ok")
end

--@api-stub: LToolbar.addSpacer
do
    local tb = lurek.ui.newToolbar("horizontal"); tb:addButton("cut", "Cut")
    tb:addSpacer(10); tb:addButton("paste", "Paste")
    local ori = tb:getOrientation()
    local btn = tb:getButton("cut")
    print("orientation:", ori, "button:", btn)
end

--@api-stub: LToolbar.getButton
do
    local tb = lurek.ui.newToolbar("horizontal"); tb:addButton("cut", "Cut")
    tb:addSpacer(10); tb:addButton("paste", "Paste")
    local ori = tb:getOrientation()
    local btn = tb:getButton("cut")
    print("orientation:", ori, "button:", btn)
end

--@api-stub: LToolbar.getOrientation
do
    local tb = lurek.ui.newToolbar("horizontal"); tb:addButton("cut", "Cut")
    tb:addSpacer(10); tb:addButton("paste", "Paste")
    local ori = tb:getOrientation()
    local btn = tb:getButton("cut")
    print("orientation:", ori, "button:", btn)
end

--@api-stub: LToolbar.isButtonToggled
do
    local tb = lurek.ui.newToolbar("horizontal"); tb:addButton("bold", "Bold")
    tb:setButtonToggled("bold", true)
    local tog = tb:isButtonToggled("bold")
    tb:setButtonEnabled("bold", false)
    print("bold toggled:", tog)
end

--@api-stub: LToolbar.setButtonEnabled
do
    local tb = lurek.ui.newToolbar("horizontal"); tb:addButton("bold", "Bold")
    tb:setButtonToggled("bold", true)
    local tog = tb:isButtonToggled("bold")
    tb:setButtonEnabled("bold", false)
    print("bold toggled:", tog)
end

--@api-stub: LToolbar.setButtonToggled
do
    local tb = lurek.ui.newToolbar("horizontal"); tb:addButton("bold", "Bold")
    tb:setButtonToggled("bold", true)
    local tog = tb:isButtonToggled("bold")
    tb:setButtonEnabled("bold", false)
    print("bold toggled:", tog)
end

--@api-stub: LToolbar.setOrientation
do
    local tb = lurek.ui.newToolbar("horizontal"); tb:setOrientation("vertical")
    local ori = tb:getOrientation(); local tp = lurek.ui.newTooltipPanel("Hover help")
    local delay = tp:getDelay()
    local target = tp:getTarget()
    print("orientation:", ori, "delay:", delay, "target:", target)
end

--@api-stub: LTooltipPanel.getDelay
do
    local tb = lurek.ui.newToolbar("horizontal"); tb:setOrientation("vertical")
    local ori = tb:getOrientation(); local tp = lurek.ui.newTooltipPanel("Hover help")
    local delay = tp:getDelay()
    local target = tp:getTarget()
    print("orientation:", ori, "delay:", delay, "target:", target)
end

--@api-stub: LTooltipPanel.getTarget
do
    local tb = lurek.ui.newToolbar("horizontal"); tb:setOrientation("vertical")
    local ori = tb:getOrientation(); local tp = lurek.ui.newTooltipPanel("Hover help")
    local delay = tp:getDelay()
    local target = tp:getTarget()
    print("orientation:", ori, "delay:", delay, "target:", target)
end

--@api-stub: LTooltipPanel.getText
do
    local tp = lurek.ui.newTooltipPanel("initial tip"); local txt = tp:getText()
    tp:setDelay(0.5); local d = tp:getDelay()
    local btn = lurek.ui.newButton("hover me")
    tp:setTarget(btn:getId() and 1 or 1)
    print("text:", txt, "delay:", d)
end

--@api-stub: LTooltipPanel.setDelay
do
    local tp = lurek.ui.newTooltipPanel("initial tip"); local txt = tp:getText()
    tp:setDelay(0.5); local d = tp:getDelay()
    local btn = lurek.ui.newButton("hover me")
    tp:setTarget(btn:getId() and 1 or 1)
    print("text:", txt, "delay:", d)
end

--@api-stub: LTooltipPanel.setTarget
do
    local tp = lurek.ui.newTooltipPanel("initial tip"); local txt = tp:getText()
    tp:setDelay(0.5); local d = tp:getDelay()
    local btn = lurek.ui.newButton("hover me")
    tp:setTarget(btn:getId() and 1 or 1)
    print("text:", txt, "delay:", d)
end

--@api-stub: LTooltipPanel.setText
do
    local tp = lurek.ui.newTooltipPanel("old tip"); tp:setText("new tooltip text")
    local txt = tp:getText(); tp:setText("another tip")
    local txt2 = tp:getText()
    tp:setDelay(1.0)
    print("setText:", txt, "â†’", txt2)
end

--@api-stub: LTreeView.addNode
do
    local tv = lurek.ui.newTreeView(); local n1 = tv:addNode("Root", nil)
    local n2 = tv:addNode("Child", n1); tv:collapseAll()
    tv:clearNodes()
    local cnt = tv:getNodeCount()
    print("addNode/collapseAll/clearNodes ok; count after clear:", cnt)
end

--@api-stub: LTreeView.clearNodes
do
    local tv = lurek.ui.newTreeView(); local n1 = tv:addNode("Root", nil)
    local n2 = tv:addNode("Child", n1); tv:collapseAll()
    tv:clearNodes()
    local cnt = tv:getNodeCount()
    print("addNode/collapseAll/clearNodes ok; count after clear:", cnt)
end

--@api-stub: LTreeView.collapseAll
do
    local tv = lurek.ui.newTreeView(); local n1 = tv:addNode("Root", nil)
    local n2 = tv:addNode("Child", n1); tv:collapseAll()
    tv:clearNodes()
    local cnt = tv:getNodeCount()
    print("addNode/collapseAll/clearNodes ok; count after clear:", cnt)
end

--@api-stub: LTreeView.collapseNode
do
    local tv = lurek.ui.newTreeView(); local n1 = tv:addNode("Animals", nil)
    local n2 = tv:addNode("Mammals", n1); tv:addNode("Dog", n2)
    tv:expandAll(); tv:collapseNode(n1)
    tv:expandNode(n1); local cnt = tv:getNodeCount()
    print("expandAll/collapseNode/expandNode ok; count:", cnt)
end

--@api-stub: LTreeView.expandAll
do
    local tv = lurek.ui.newTreeView(); local n1 = tv:addNode("Animals", nil)
    local n2 = tv:addNode("Mammals", n1); tv:addNode("Dog", n2)
    tv:expandAll(); tv:collapseNode(n1)
    tv:expandNode(n1); local cnt = tv:getNodeCount()
    print("expandAll/collapseNode/expandNode ok; count:", cnt)
end

--@api-stub: LTreeView.expandNode
do
    local tv = lurek.ui.newTreeView(); local n1 = tv:addNode("Animals", nil)
    local n2 = tv:addNode("Mammals", n1); tv:addNode("Dog", n2)
    tv:expandAll(); tv:collapseNode(n1)
    tv:expandNode(n1); local cnt = tv:getNodeCount()
    print("expandAll/collapseNode/expandNode ok; count:", cnt)
end

--@api-stub: LTreeView.getChildNodes
do
    local tv = lurek.ui.newTreeView(); local r = tv:addNode("Root", nil)
    local c1 = tv:addNode("Child1", r); tv:addNode("Child2", r)
    local children = tv:getChildNodes(r); local cnt = tv:getNodeCount()
    local depth = tv:getNodeDepth(c1)
    print("children:", children, "count:", cnt, "depth:", depth)
end

--@api-stub: LTreeView.getNodeCount
do
    local tv = lurek.ui.newTreeView(); local r = tv:addNode("Root", nil)
    local c1 = tv:addNode("Child1", r); tv:addNode("Child2", r)
    local children = tv:getChildNodes(r); local cnt = tv:getNodeCount()
    local depth = tv:getNodeDepth(c1)
    print("children:", children, "count:", cnt, "depth:", depth)
end

--@api-stub: LTreeView.getNodeDepth
do
    local tv = lurek.ui.newTreeView(); local r = tv:addNode("Root", nil)
    local c1 = tv:addNode("Child1", r); tv:addNode("Child2", r)
    local children = tv:getChildNodes(r); local cnt = tv:getNodeCount()
    local depth = tv:getNodeDepth(c1)
    print("children:", children, "count:", cnt, "depth:", depth)
end

--@api-stub: LTreeView.getNodeText
do
    local tv = lurek.ui.newTreeView(); local r = tv:addNode("Root", nil)
    local c = tv:addNode("Child", r); local txt = tv:getNodeText(c)
    local parent = tv:getParentNode(c)
    local sel = tv:getSelectedNode()
    print("text:", txt, "parent:", parent, "selected:", sel)
end

--@api-stub: LTreeView.getParentNode
do
    local tv = lurek.ui.newTreeView(); local r = tv:addNode("Root", nil)
    local c = tv:addNode("Child", r); local txt = tv:getNodeText(c)
    local parent = tv:getParentNode(c)
    local sel = tv:getSelectedNode()
    print("text:", txt, "parent:", parent, "selected:", sel)
end

--@api-stub: LTreeView.getSelectedNode
do
    local tv = lurek.ui.newTreeView(); local r = tv:addNode("Root", nil)
    local c = tv:addNode("Child", r); local txt = tv:getNodeText(c)
    local parent = tv:getParentNode(c)
    local sel = tv:getSelectedNode()
    print("text:", txt, "parent:", parent, "selected:", sel)
end

--@api-stub: LTreeView.isExpanded
do
    local tv = lurek.ui.newTreeView(); local r = tv:addNode("Root", nil)
    local c = tv:addNode("Child", r); tv:expandNode(r)
    local exp = tv:isExpanded(r); local ne = tv:isNodeExpanded(r)
    tv:removeNode(c); local cnt = tv:getNodeCount()
    print("isExpanded:", exp, "isNodeExpanded:", ne, "count after remove:", cnt)
end

--@api-stub: LTreeView.isNodeExpanded
do
    local tv = lurek.ui.newTreeView(); local r = tv:addNode("Root", nil)
    local c = tv:addNode("Child", r); tv:expandNode(r)
    local exp = tv:isExpanded(r); local ne = tv:isNodeExpanded(r)
    tv:removeNode(c); local cnt = tv:getNodeCount()
    print("isExpanded:", exp, "isNodeExpanded:", ne, "count after remove:", cnt)
end

--@api-stub: LTreeView.removeNode
do
    local tv = lurek.ui.newTreeView(); local r = tv:addNode("Root", nil)
    local c = tv:addNode("Child", r); tv:expandNode(r)
    local exp = tv:isExpanded(r); local ne = tv:isNodeExpanded(r)
    tv:removeNode(c); local cnt = tv:getNodeCount()
    print("isExpanded:", exp, "isNodeExpanded:", ne, "count after remove:", cnt)
end

--@api-stub: LTreeView.setNodeIcon
do
    local tv = lurek.ui.newTreeView(); local r = tv:addNode("old text", nil)
    tv:setNodeText(r, "new text"); local txt = tv:getNodeText(r)
    tv:setSelectedNode(r); local sel = tv:getSelectedNode()
    tv:setNodeIcon(r, "folder")
    print("setText:", txt, "selected:", sel)
end

--@api-stub: LTreeView.setNodeText
do
    local tv = lurek.ui.newTreeView(); local r = tv:addNode("old text", nil)
    tv:setNodeText(r, "new text"); local txt = tv:getNodeText(r)
    tv:setSelectedNode(r); local sel = tv:getSelectedNode()
    tv:setNodeIcon(r, "folder")
    print("setText:", txt, "selected:", sel)
end

--@api-stub: LTreeView.setSelectedNode
do
    local tv = lurek.ui.newTreeView(); local r = tv:addNode("old text", nil)
    tv:setNodeText(r, "new text"); local txt = tv:getNodeText(r)
    tv:setSelectedNode(r); local sel = tv:getSelectedNode()
    tv:setNodeIcon(r, "folder")
    print("setText:", txt, "selected:", sel)
end

--@api-stub: LTreeView.toggleNode
do
    local tv = lurek.ui.newTreeView(); local r = tv:addNode("Root", nil)
    tv:addNode("Child", r); tv:expandNode(r)
    local was = tv:isExpanded(r); tv:toggleNode(r)
    local now = tv:isExpanded(r); tv:toggleNode(r)
    local back = tv:isExpanded(r); print("expanded:", was, "after toggle:", now, "after toggle back:", back)
end

--@api-stub: LUiWidget.addChild
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); local child = lurek.ui.newLabel("label")
    w:addChild(child); w:animateAlpha(0.5, 0.3, false)
    w:animatePosition(10, 20, 0.5)
    local cnt = w:getChildCount()
    print("addChild/animateAlpha/animatePosition ok; childCount:", cnt)
end

--@api-stub: LUiWidget.animateAlpha
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); local child = lurek.ui.newLabel("label")
    w:addChild(child); w:animateAlpha(0.5, 0.3, false)
    w:animatePosition(10, 20, 0.5)
    local cnt = w:getChildCount()
    print("addChild/animateAlpha/animatePosition ok; childCount:", cnt)
end

--@api-stub: LUiWidget.animatePosition
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); local child = lurek.ui.newLabel("label")
    w:addChild(child); w:animateAlpha(0.5, 0.3, false)
    w:animatePosition(10, 20, 0.5)
    local cnt = w:getChildCount()
    print("addChild/animateAlpha/animatePosition ok; childCount:", cnt)
end

--@api-stub: LUiWidget.attachToEntity
do
    local w = lurek.ui.newCustomWidget({width=80, height=40}); w:attachToEntity(1)
    w:animateAlpha(0.0, 1.0, false); local animating = w:isAnimating()
    w:cancelAnimations(); w:bind("click")
    w:detachFromEntity()
    print("attachToEntity/bind/cancelAnimations ok")
end

--@api-stub: LUiWidget.bind
do
    local w = lurek.ui.newCustomWidget({width=80, height=40}); w:attachToEntity(1)
    w:animateAlpha(0.0, 1.0, false); local animating = w:isAnimating()
    w:cancelAnimations(); w:bind("click")
    w:detachFromEntity()
    print("attachToEntity/bind/cancelAnimations ok")
end

--@api-stub: LUiWidget.cancelAnimations
do
    local w = lurek.ui.newCustomWidget({width=80, height=40}); w:attachToEntity(1)
    w:animateAlpha(0.0, 1.0, false); local animating = w:isAnimating()
    w:cancelAnimations(); w:bind("click")
    w:detachFromEntity()
    print("attachToEntity/bind/cancelAnimations ok")
end

--@api-stub: LUiWidget.clearAnchor
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setAnchor(0, 0, 1, 0)
    w:clearAnchor(); w:setPosition(10, 10)
    local hit = w:containsPoint(15, 15); w:attachToEntity(2)
    w:detachFromEntity()
    print("clearAnchor/containsPoint:", hit, "detachFromEntity ok")
end

--@api-stub: LUiWidget.containsPoint
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setAnchor(0, 0, 1, 0)
    w:clearAnchor(); w:setPosition(10, 10)
    local hit = w:containsPoint(15, 15); w:attachToEntity(2)
    w:detachFromEntity()
    print("clearAnchor/containsPoint:", hit, "detachFromEntity ok")
end

--@api-stub: LUiWidget.detachFromEntity
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setAnchor(0, 0, 1, 0)
    w:clearAnchor(); w:setPosition(10, 10)
    local hit = w:containsPoint(15, 15); w:attachToEntity(2)
    w:detachFromEntity()
    print("clearAnchor/containsPoint:", hit, "detachFromEntity ok")
end

--@api-stub: LUiWidget.fadeIn
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setId("my-panel")
    w:fadeOut(); w:fadeIn()
    local child = lurek.ui.newLabel("inner"); child:setId("inner-lbl")
    w:addChild(child); local found = w:findById("inner-lbl")
    print("fadeIn/fadeOut ok; findById:", found)
end

--@api-stub: LUiWidget.fadeOut
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setId("my-panel")
    w:fadeOut(); w:fadeIn()
    local child = lurek.ui.newLabel("inner"); child:setId("inner-lbl")
    w:addChild(child); local found = w:findById("inner-lbl")
    print("fadeIn/fadeOut ok; findById:", found)
end

--@api-stub: LUiWidget.findById
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setId("my-panel")
    w:fadeOut(); w:fadeIn()
    local child = lurek.ui.newLabel("inner"); child:setId("inner-lbl")
    w:addChild(child); local found = w:findById("inner-lbl")
    print("fadeIn/fadeOut ok; findById:", found)
end

--@api-stub: LUiWidget.getAlpha
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setAlpha(0.75)
    local alpha = w:getAlpha(); w:addChild(lurek.ui.newLabel("c1"))
    w:addChild(lurek.ui.newLabel("c2")); local cnt = w:getChildCount()
    local children = w:getChildren()
    print("alpha:", alpha, "childCount:", cnt, "children:", children)
end

--@api-stub: LUiWidget.getChildCount
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setAlpha(0.75)
    local alpha = w:getAlpha(); w:addChild(lurek.ui.newLabel("c1"))
    w:addChild(lurek.ui.newLabel("c2")); local cnt = w:getChildCount()
    local children = w:getChildren()
    print("alpha:", alpha, "childCount:", cnt, "children:", children)
end

--@api-stub: LUiWidget.getChildren
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setAlpha(0.75)
    local alpha = w:getAlpha(); w:addChild(lurek.ui.newLabel("c1"))
    w:addChild(lurek.ui.newLabel("c2")); local cnt = w:getChildCount()
    local children = w:getChildren()
    print("alpha:", alpha, "childCount:", cnt, "children:", children)
end

--@api-stub: LUiWidget.getFlexGrow
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setFlexGrow(2)
    local grow = w:getFlexGrow(); w:setFlexShrink(1)
    local shrink = w:getFlexShrink(); w:setId("widget-abc")
    local id = w:getId()
    print("flexGrow:", grow, "flexShrink:", shrink, "id:", id)
end

--@api-stub: LUiWidget.getFlexShrink
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setFlexGrow(2)
    local grow = w:getFlexGrow(); w:setFlexShrink(1)
    local shrink = w:getFlexShrink(); w:setId("widget-abc")
    local id = w:getId()
    print("flexGrow:", grow, "flexShrink:", shrink, "id:", id)
end

--@api-stub: LUiWidget.getId
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setFlexGrow(2)
    local grow = w:getFlexGrow(); w:setFlexShrink(1)
    local shrink = w:getFlexShrink(); w:setId("widget-abc")
    local id = w:getId()
    print("flexGrow:", grow, "flexShrink:", shrink, "id:", id)
end

--@api-stub: LUiWidget.getMargin
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setMargin(4, 8, 4, 8)
    local mt, mr, mb, ml = w:getMargin(); w:setMaxSize(400, 300)
    local mxw, mxh = w:getMaxSize(); w:setMinSize(50, 25)
    local mnw, mnh = w:getMinSize()
    print("margin:", mt, mr, mb, ml, "max:", mxw, mxh, "min:", mnw, mnh)
end

--@api-stub: LUiWidget.getMaxSize
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setMargin(4, 8, 4, 8)
    local mt, mr, mb, ml = w:getMargin(); w:setMaxSize(400, 300)
    local mxw, mxh = w:getMaxSize(); w:setMinSize(50, 25)
    local mnw, mnh = w:getMinSize()
    print("margin:", mt, mr, mb, ml, "max:", mxw, mxh, "min:", mnw, mnh)
end

--@api-stub: LUiWidget.getMinSize
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setMargin(4, 8, 4, 8)
    local mt, mr, mb, ml = w:getMargin(); w:setMaxSize(400, 300)
    local mxw, mxh = w:getMaxSize(); w:setMinSize(50, 25)
    local mnw, mnh = w:getMinSize()
    print("margin:", mt, mr, mb, ml, "max:", mxw, mxh, "min:", mnw, mnh)
end

--@api-stub: LUiWidget.getPadding
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setPadding(5, 5, 5, 5)
    local pt, pr, pb, pl = w:getPadding(); w:setPosition(30, 40)
    local px, py = w:getPosition()
    local rx, ry, rw, rh = w:getRect()
    print("padding:", pt, "position:", px, py, "rect:", rx, ry, rw, rh)
end

--@api-stub: LUiWidget.getPosition
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setPadding(5, 5, 5, 5)
    local pt, pr, pb, pl = w:getPadding(); w:setPosition(30, 40)
    local px, py = w:getPosition()
    local rx, ry, rw, rh = w:getRect()
    print("padding:", pt, "position:", px, py, "rect:", rx, ry, rw, rh)
end

--@api-stub: LUiWidget.getRect
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setPadding(5, 5, 5, 5)
    local pt, pr, pb, pl = w:getPadding(); w:setPosition(30, 40)
    local px, py = w:getPosition()
    local rx, ry, rw, rh = w:getRect()
    print("padding:", pt, "position:", px, py, "rect:", rx, ry, rw, rh)
end

--@api-stub: LUiWidget.getSize
do
    local w = lurek.ui.newCustomWidget({width=120, height=60}); w:setSize(150, 80)
    local sw, sh = w:getSize(); local state = w:getState()
    w:setTooltip("hover tip")
    local tip = w:getTooltip()
    print("size:", sw, sh, "state:", state, "tooltip:", tip)
end

--@api-stub: LUiWidget.getState
do
    local w = lurek.ui.newCustomWidget({width=120, height=60}); w:setSize(150, 80)
    local sw, sh = w:getSize(); local state = w:getState()
    w:setTooltip("hover tip")
    local tip = w:getTooltip()
    print("size:", sw, sh, "state:", state, "tooltip:", tip)
end

--@api-stub: LUiWidget.getTooltip
do
    local w = lurek.ui.newCustomWidget({width=120, height=60}); w:setSize(150, 80)
    local sw, sh = w:getSize(); local state = w:getState()
    w:setTooltip("hover tip")
    local tip = w:getTooltip()
    print("size:", sw, sh, "state:", state, "tooltip:", tip)
end

--@api-stub: LUiWidget.getZOrder
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setZOrder(5)
    local z = w:getZOrder(); local animating = w:isAnimating()
    local enabled = w:isEnabled()
    w:setEnabled(false)
    print("zOrder:", z, "isAnimating:", animating, "isEnabled:", enabled)
end

--@api-stub: LUiWidget.isAnimating
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setZOrder(5)
    local z = w:getZOrder(); local animating = w:isAnimating()
    local enabled = w:isEnabled()
    w:setEnabled(false)
    print("zOrder:", z, "isAnimating:", animating, "isEnabled:", enabled)
end

--@api-stub: LUiWidget.isEnabled
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setZOrder(5)
    local z = w:getZOrder(); local animating = w:isAnimating()
    local enabled = w:isEnabled()
    w:setEnabled(false)
    print("zOrder:", z, "isAnimating:", animating, "isEnabled:", enabled)
end

--@api-stub: LUiWidget.isVisible
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); local vis = w:isVisible()
    w:setVisible(false); local child = lurek.ui.newLabel("removable")
    w:addChild(child); w:removeChild(child)
    w:setAlpha(0.9); local alpha = w:getAlpha()
    print("isVisible:", vis, "removeChild ok, alpha:", alpha)
end

--@api-stub: LUiWidget.removeChild
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); local vis = w:isVisible()
    w:setVisible(false); local child = lurek.ui.newLabel("removable")
    w:addChild(child); w:removeChild(child)
    w:setAlpha(0.9); local alpha = w:getAlpha()
    print("isVisible:", vis, "removeChild ok, alpha:", alpha)
end

--@api-stub: LUiWidget.setAlpha
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); local vis = w:isVisible()
    w:setVisible(false); local child = lurek.ui.newLabel("removable")
    w:addChild(child); w:removeChild(child)
    w:setAlpha(0.9); local alpha = w:getAlpha()
    print("isVisible:", vis, "removeChild ok, alpha:", alpha)
end

--@api-stub: LUiWidget.setAnchor
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setAnchor(0, 0, 1, 1)
    w:clearAnchor(); w:setAnchorCenter(0.5, 0.5)
    w:setEnabled(true); local enabled = w:isEnabled()
    w:setEnabled(false)
    print("setAnchor/setAnchorCenter/setEnabled ok")
end

--@api-stub: LUiWidget.setAnchorCenter
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setAnchor(0, 0, 1, 1)
    w:clearAnchor(); w:setAnchorCenter(0.5, 0.5)
    w:setEnabled(true); local enabled = w:isEnabled()
    w:setEnabled(false)
    print("setAnchor/setAnchorCenter/setEnabled ok")
end

--@api-stub: LUiWidget.setEnabled
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setAnchor(0, 0, 1, 1)
    w:clearAnchor(); w:setAnchorCenter(0.5, 0.5)
    w:setEnabled(true); local enabled = w:isEnabled()
    w:setEnabled(false)
    print("setAnchor/setAnchorCenter/setEnabled ok")
end

--@api-stub: LUiWidget.setFlexGrow
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setFlexGrow(3)
    local fg = w:getFlexGrow(); w:setFlexShrink(0)
    local fs = w:getFlexShrink(); w:setId("flex-widget")
    local id = w:getId()
    print("flexGrow:", fg, "flexShrink:", fs, "id:", id)
end

--@api-stub: LUiWidget.setFlexShrink
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setFlexGrow(3)
    local fg = w:getFlexGrow(); w:setFlexShrink(0)
    local fs = w:getFlexShrink(); w:setId("flex-widget")
    local id = w:getId()
    print("flexGrow:", fg, "flexShrink:", fs, "id:", id)
end

--@api-stub: LUiWidget.setId
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setFlexGrow(3)
    local fg = w:getFlexGrow(); w:setFlexShrink(0)
    local fs = w:getFlexShrink(); w:setId("flex-widget")
    local id = w:getId()
    print("flexGrow:", fg, "flexShrink:", fs, "id:", id)
end

--@api-stub: LUiWidget.setMargin
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setMargin(2, 4, 2, 4)
    local mt = w:getMargin(); w:setMaxSize(500, 400)
    local mxw = w:getMaxSize(); w:setMinSize(60, 30)
    local mnw = w:getMinSize()
    print("margin set ok; maxSize:", mxw, "minSize:", mnw)
end

--@api-stub: LUiWidget.setMaxSize
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setMargin(2, 4, 2, 4)
    local mt = w:getMargin(); w:setMaxSize(500, 400)
    local mxw = w:getMaxSize(); w:setMinSize(60, 30)
    local mnw = w:getMinSize()
    print("margin set ok; maxSize:", mxw, "minSize:", mnw)
end

--@api-stub: LUiWidget.setMinSize
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setMargin(2, 4, 2, 4)
    local mt = w:getMargin(); w:setMaxSize(500, 400)
    local mxw = w:getMaxSize(); w:setMinSize(60, 30)
    local mnw = w:getMinSize()
    print("margin set ok; maxSize:", mxw, "minSize:", mnw)
end

--@api-stub: LUiWidget.setOnChange
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setOnChange(function() print("changed") end)
    w:setOnClick(function() print("clicked") end); w:setOnDraw(function() print("drawing") end)
    local id = w:getId()
    local vis = w:isVisible()
    print("setOnChange/setOnClick/setOnDraw ok; id:", id, "vis:", vis)
end

--@api-stub: LUiWidget.setOnClick
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setOnChange(function() print("changed") end)
    w:setOnClick(function() print("clicked") end); w:setOnDraw(function() print("drawing") end)
    local id = w:getId()
    local vis = w:isVisible()
    print("setOnChange/setOnClick/setOnDraw ok; id:", id, "vis:", vis)
end

--@api-stub: LUiWidget.setOnDraw
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setOnChange(function() print("changed") end)
    w:setOnClick(function() print("clicked") end); w:setOnDraw(function() print("drawing") end)
    local id = w:getId()
    local vis = w:isVisible()
    print("setOnChange/setOnClick/setOnDraw ok; id:", id, "vis:", vis)
end

--@api-stub: LUiWidget.setPadding
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setPadding(6, 6, 6, 6)
    local pt = w:getPadding(); w:setPosition(50, 100)
    local px, py = w:getPosition(); w:setSize(200, 100)
    local sw, sh = w:getSize()
    print("padding:", pt, "position:", px, py, "size:", sw, sh)
end

--@api-stub: LUiWidget.setPosition
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setPadding(6, 6, 6, 6)
    local pt = w:getPadding(); w:setPosition(50, 100)
    local px, py = w:getPosition(); w:setSize(200, 100)
    local sw, sh = w:getSize()
    print("padding:", pt, "position:", px, py, "size:", sw, sh)
end

--@api-stub: LUiWidget.setSize
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setPadding(6, 6, 6, 6)
    local pt = w:getPadding(); w:setPosition(50, 100)
    local px, py = w:getPosition(); w:setSize(200, 100)
    local sw, sh = w:getSize()
    print("padding:", pt, "position:", px, py, "size:", sw, sh)
end

--@api-stub: LUiWidget.setTooltip
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setTooltip("my tooltip")
    local tip = w:getTooltip(); w:setVisible(false)
    w:setVisible(true); w:setZOrder(10)
    local z = w:getZOrder()
    print("tooltip:", tip, "zOrder:", z)
end

--@api-stub: LUiWidget.setVisible
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setTooltip("my tooltip")
    local tip = w:getTooltip(); w:setVisible(false)
    w:setVisible(true); w:setZOrder(10)
    local z = w:getZOrder()
    print("tooltip:", tip, "zOrder:", z)
end

--@api-stub: LUiWidget.setZOrder
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:setTooltip("my tooltip")
    local tip = w:getTooltip(); w:setVisible(false)
    w:setVisible(true); w:setZOrder(10)
    local z = w:getZOrder()
    print("tooltip:", tip, "zOrder:", z)
end

--@api-stub: LUiWidget.slideIn
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:slideIn(0, -50)
    w:slideOut(0, 50); local t = w:type()
    local ok = w:typeOf("LUiWidget")
    w:unbind()
    print("slideIn/slideOut ok; type:", t, "typeOf:", ok)
end

--@api-stub: LUiWidget.slideOut
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:slideIn(0, -50)
    w:slideOut(0, 50); local t = w:type()
    local ok = w:typeOf("LUiWidget")
    w:unbind()
    print("slideIn/slideOut ok; type:", t, "typeOf:", ok)
end

--@api-stub: LUiWidget.type
do
    local w = lurek.ui.newCustomWidget({width=100, height=50}); w:slideIn(0, -50)
    w:slideOut(0, 50); local t = w:type()
    local ok = w:typeOf("LUiWidget")
    w:unbind()
    print("slideIn/slideOut ok; type:", t, "typeOf:", ok)
end

--@api-stub: LUiWidget.typeOf
do
    local w = lurek.ui.newCustomWidget({width=80, height=40}); w:bind("click")
    w:unbind(); local ok1 = w:typeOf("LUiWidget")
    local ok2 = w:typeOf("LButton")
    local t = w:type()
    print("typeOf LUiWidget:", ok1, "typeOf LButton:", ok2, "type:", t)
end

--@api-stub: LUiWidget.unbind
do
    local w = lurek.ui.newCustomWidget({width=80, height=40}); w:bind("click")
    w:unbind(); local ok1 = w:typeOf("LUiWidget")
    local ok2 = w:typeOf("LButton")
    local t = w:type()
    print("typeOf LUiWidget:", ok1, "typeOf LButton:", ok2, "type:", t)
end

--@api-stub: lurek.ui.draw
do
    local w = lurek.ui.newCustomWidget({width=80, height=40}); lurek.ui.beginDrag(w)
    lurek.ui.endDrag()
    lurek.ui.clearFocus()
    lurek.ui.draw()
    print("beginDrag/endDrag/clearFocus/draw ok")
end

--@api-stub: lurek.ui.drawToImage
do
    local img = lurek.ui.drawToImage(320, 240); local w = lurek.ui.newCustomWidget({width=80, height=40})
    lurek.ui.beginDrag(w)
    lurek.ui.dropOn(w)
    lurek.ui.endDrag()
    print("drawToImage ok; dropOn/endDrag ok")
end

--@api-stub: lurek.ui.endDrag
do
    local img = lurek.ui.drawToImage(320, 240); local w = lurek.ui.newCustomWidget({width=80, height=40})
    lurek.ui.beginDrag(w)
    lurek.ui.dropOn(w)
    lurek.ui.endDrag()
    print("drawToImage ok; dropOn/endDrag ok")
end

--@api-stub: lurek.ui.flushCache
do
    lurek.ui.flushCache(); lurek.ui.focusPrev()
    local drag = lurek.ui.getActiveDrag()
    local focus = lurek.ui.getFocus()
    lurek.ui.clearFocus()
    print("flushCache/focusPrev ok; activeDrag:", drag, "focus:", focus)
end

--@api-stub: lurek.ui.getToastCount
do
    lurek.ui.clearFocus(); local foc = lurek.ui.getFocus()
    local theme = lurek.ui.getTheme()
    local toasts = lurek.ui.getToastCount()
    local widgets = lurek.ui.getWidgetCount()
    print("focus:", foc, "theme:", theme, "toastCount:", toasts, "widgetCount:", widgets)
end

--@api-stub: lurek.ui.getWidgetCount
do
    local cnt = lurek.ui.getWidgetCount()
    lurek.ui.keypressed("escape")
    local layout = lurek.ui.loadLayoutFile("content/examples/assets/layouts/sample_main_menu.toml")
    lurek.ui.textinput("a")
    print("widgetCount:", cnt, "loadLayoutFile ok; textinput ok")
end

--@api-stub: lurek.ui.keypressed
do
    local cnt = lurek.ui.getWidgetCount()
    lurek.ui.keypressed("escape")
    local layout = lurek.ui.loadLayoutFile("content/examples/assets/layouts/sample_main_menu.toml")
    lurek.ui.textinput("a")
    print("widgetCount:", cnt, "loadLayoutFile ok; textinput ok")
end

--@api-stub: lurek.ui.loadLayoutFile
do
    local cnt = lurek.ui.getWidgetCount()
    lurek.ui.keypressed("escape")
    local layout = lurek.ui.loadLayoutFile("content/examples/assets/layouts/sample_main_menu.toml")
    lurek.ui.textinput("a")
    print("widgetCount:", cnt, "loadLayoutFile ok; textinput ok")
end

--@api-stub: lurek.ui.mousemoved
do
    local slider = lurek.ui.newSlider(0, 100); slider:setPosition(20, 520); slider:setSize(200, 20); slider:setZOrder(2200)
    lurek.ui.mousepressed(40, 530, 1); lurek.ui.mousemoved(180, 530); lurek.ui.mousereleased(180, 530, 1)
    lurek.ui.update(0)
    print("slider value after drag:", slider:getValue())
end

--@api-stub: lurek.ui.mousepressed
do
    local tabs = lurek.ui.newTabBar(); tabs:setPosition(20, 560); tabs:setSize(240, 28); tabs:setZOrder(2300)
    tabs:addTab("Home"); tabs:addTab("Reports"); tabs:addTab("Settings")
    lurek.ui.mousepressed(120, 574, 1); lurek.ui.mousereleased(120, 574, 1); lurek.ui.update(0)
    print("active tab after click:", tabs:getActiveTab())
end

--@api-stub: lurek.ui.mousereleased
do
    local combo = lurek.ui.newComboBox(); combo:setPosition(20, 600); combo:setSize(160, 28); combo:setZOrder(2400)
    combo:addItem("All"); combo:addItem("Food"); combo:addItem("Rent")
    lurek.ui.mousepressed(30, 614, 1); lurek.ui.mousereleased(30, 614, 1)
    lurek.ui.mousepressed(30, 670, 1); lurek.ui.mousereleased(30, 670, 1); lurek.ui.update(0)
    print("combo selected:", combo:getSelectedItem())
end

--@api-stub: lurek.ui.newCustomWidget
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local layout = lurek.ui.newLayout("row")
    local sb = lurek.ui.newScrollBar(true)
    print("newCustomWidget:", w, "newLayout:", layout, "newScrollBar:", sb)
end

--@api-stub: lurek.ui.newScrollBar
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local layout = lurek.ui.newLayout("row")
    local sb = lurek.ui.newScrollBar(true)
    print("newCustomWidget:", w, "newLayout:", layout, "newScrollBar:", sb)
end

--@api-stub: lurek.ui.parseWidgetState
do
    local th = lurek.ui.newTheme()
    local state = lurek.ui.parseWidgetState("normal")
    local result = lurek.ui.renderToImage(320, 240, "save/ui_render.png")
    print("newTheme ok; parseWidgetState:", state, "renderToImage:", result)
end

--@api-stub: lurek.ui.renderToImage
do
    local th = lurek.ui.newTheme()
    local state = lurek.ui.parseWidgetState("normal")
    local result = lurek.ui.renderToImage(320, 240, "save/ui_render.png")
    print("newTheme ok; parseWidgetState:", state, "renderToImage:", result)
end

--@api-stub: lurek.ui.setDefaultTheme
do
    local th = lurek.ui.newTheme(); lurek.ui.setTheme(th)
    lurek.ui.setDefaultTheme()
    lurek.ui.setViewport(1280, 720)
    local cnt = lurek.ui.getWidgetCount()
    print("setTheme/setDefaultTheme/setViewport ok; widgets:", cnt)
end

--@api-stub: lurek.ui.setViewport
do
    local th = lurek.ui.newTheme(); lurek.ui.setTheme(th)
    lurek.ui.setDefaultTheme()
    lurek.ui.setViewport(1280, 720)
    local cnt = lurek.ui.getWidgetCount()
    print("setTheme/setDefaultTheme/setViewport ok; widgets:", cnt)
end

--@api-stub: lurek.ui.textinput
do
    lurek.ui.textinput("hello"); lurek.ui.textinput(" world")
    lurek.ui.update_bindings({dt=0.016})
    lurek.ui.wheelmoved(0, 1)
    lurek.ui.wheelmoved(1, 0)
    print("textinput/update_bindings/wheelmoved ok")
end

--@api-stub: lurek.ui.update_bindings
do
    lurek.ui.textinput("hello"); lurek.ui.textinput(" world")
    lurek.ui.update_bindings({dt=0.016})
    lurek.ui.wheelmoved(0, 1)
    lurek.ui.wheelmoved(1, 0)
    print("textinput/update_bindings/wheelmoved ok")
end

--@api-stub: lurek.ui.wheelmoved
do
    local panel = lurek.ui.newScrollPanel(); panel:setPosition(300, 520); panel:setSize(120, 70); panel:setZOrder(2500)
    panel:setContentSize(120, 300)
    lurek.ui.mousemoved(310, 530); lurek.ui.wheelmoved(0, -3)
    local _, sy = panel:getScrollPosition()
    print("hover scroll y:", sy)
end

--@api-stub: LTextInput:isFocused
do
    local input = lurek.ui.newTextInput(); input:setPosition(20, 650); input:setSize(160, 28); input:setZOrder(2600)
    lurek.ui.setFocus(input)
    lurek.ui.textinput("42")
    lurek.ui.keypressed("left")
    lurek.ui.textinput(".")
    lurek.ui.update(0)
    print("focused text:", input:isFocused(), input:getText())
end

--@api-stub: LUiWidget:setOnChange
do
    local toolbar = lurek.ui.newToolbar("horizontal"); toolbar:setPosition(220, 650); toolbar:setSize(120, 32); toolbar:setZOrder(2610)
    toolbar:addButton("save", "Save")
    toolbar:setOnChange(function() print("toolbar changed") end)
    lurek.ui.mousepressed(230, 666, 1); lurek.ui.mousereleased(230, 666, 1)
    lurek.ui.update(0)
    print("save toggled:", toolbar:isButtonToggled("save"))
end

--@api-stub: LRadioButton:setOnChange
do
    local cash = lurek.ui.newRadioButton("Cash", "payment_kind"); cash:setPosition(370, 650); cash:setSize(100, 24); cash:setZOrder(2620)
    local card = lurek.ui.newRadioButton("Card", "payment_kind"); card:setPosition(370, 678); card:setSize(100, 24); card:setZOrder(2630)
    card:setOnChange(function() print("card selected") end)
    lurek.ui.mousepressed(380, 688, 1); lurek.ui.mousereleased(380, 688, 1)
    lurek.ui.update(0)
    print("cash/card:", cash:isSelected(), card:isSelected())
end

--@api-stub: LScrollBar:setOnChange
do
    local bar = lurek.ui.newScrollBar(true); bar:setPosition(500, 650); bar:setSize(20, 100); bar:setZOrder(2640)
    bar:setContentSize(400); bar:setViewSize(100)
    bar:setOnChange(function() print("scrollbar changed") end)
    lurek.ui.mousepressed(510, 720, 1); lurek.ui.mousemoved(510, 740); lurek.ui.mousereleased(510, 740, 1)
    lurek.ui.update(0)
    print("scrollbar position:", bar:getScrollPosition())
end

--@api-stub: LGuiWindow:setOnClose
do
    local win = lurek.ui.newWindow("Inspector"); win:setPosition(550, 650); win:setSize(150, 90); win:setZOrder(2650)
    win:setOnClose(function() print("window closed") end)
    lurek.ui.mousepressed(690, 660, 1); lurek.ui.mousereleased(690, 660, 1)
    lurek.ui.update(0)
    print("window visible:", win:isVisible())
end

--@api-stub: LDialog:setOnClose
do
    local dialog = lurek.ui.newDialog("Confirm"); dialog:setPosition(720, 650); dialog:setSize(180, 100); dialog:setZOrder(2660)
    dialog:addButton("Close")
    dialog:setOnClose(function() print("dialog closed") end)
    dialog:open()
    lurek.ui.mousepressed(830, 724, 1); lurek.ui.mousereleased(830, 724, 1)
end

--@api-stub: lurek.ui.getToastCount
do
    lurek.ui.clearFocus(); local foc = lurek.ui.getFocus()
    local theme = lurek.ui.getTheme()
    local toasts = lurek.ui.getToastCount()
    local widgets = lurek.ui.getWidgetCount()
    print("focus:", foc, "theme:", theme, "toastCount:", toasts, "widgetCount:", widgets)
end

--@api-stub: lurek.ui.getWidgetCount
do
    local cnt = lurek.ui.getWidgetCount()
    lurek.ui.keypressed("escape")
    local layout = lurek.ui.loadLayoutFile("content/examples/assets/layouts/sample_main_menu.toml")
    lurek.ui.textinput("a")
    print("widgetCount:", cnt, "loadLayoutFile ok; textinput ok")
end

--@api-stub: lurek.ui.keypressed
do
    local cnt = lurek.ui.getWidgetCount()
    lurek.ui.keypressed("escape")
    local layout = lurek.ui.loadLayoutFile("content/examples/assets/layouts/sample_main_menu.toml")
    lurek.ui.textinput("a")
    print("widgetCount:", cnt, "loadLayoutFile ok; textinput ok")
end

--@api-stub: lurek.ui.loadLayoutFile
do
    local cnt = lurek.ui.getWidgetCount()
    lurek.ui.keypressed("escape")
    local layout = lurek.ui.loadLayoutFile("content/examples/assets/layouts/sample_main_menu.toml")
    lurek.ui.textinput("a")
    print("widgetCount:", cnt, "loadLayoutFile ok; textinput ok")
end

--@api-stub: lurek.ui.mousemoved
do
    local slider = lurek.ui.newSlider(0, 100); slider:setPosition(20, 520); slider:setSize(200, 20); slider:setZOrder(2200)
    lurek.ui.mousepressed(40, 530, 1); lurek.ui.mousemoved(180, 530); lurek.ui.mousereleased(180, 530, 1)
    lurek.ui.update(0)
    print("slider value after drag:", slider:getValue())
end

--@api-stub: lurek.ui.mousepressed
do
    local tabs = lurek.ui.newTabBar(); tabs:setPosition(20, 560); tabs:setSize(240, 28); tabs:setZOrder(2300)
    tabs:addTab("Home"); tabs:addTab("Reports"); tabs:addTab("Settings")
    lurek.ui.mousepressed(120, 574, 1); lurek.ui.mousereleased(120, 574, 1); lurek.ui.update(0)
    print("active tab after click:", tabs:getActiveTab())
end

--@api-stub: lurek.ui.mousereleased
do
    local combo = lurek.ui.newComboBox(); combo:setPosition(20, 600); combo:setSize(160, 28); combo:setZOrder(2400)
    combo:addItem("All"); combo:addItem("Food"); combo:addItem("Rent")
    lurek.ui.mousepressed(30, 614, 1); lurek.ui.mousereleased(30, 614, 1)
    lurek.ui.mousepressed(30, 670, 1); lurek.ui.mousereleased(30, 670, 1); lurek.ui.update(0)
    print("combo selected:", combo:getSelectedItem())
end

--@api-stub: lurek.ui.newCustomWidget
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local layout = lurek.ui.newLayout("row")
    local sb = lurek.ui.newScrollBar(true)
    print("newCustomWidget:", w, "newLayout:", layout, "newScrollBar:", sb)
end

--@api-stub: lurek.ui.newScrollBar
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local layout = lurek.ui.newLayout("row")
    local sb = lurek.ui.newScrollBar(true)
    print("newCustomWidget:", w, "newLayout:", layout, "newScrollBar:", sb)
end

--@api-stub: lurek.ui.parseWidgetState
do
    local th = lurek.ui.newTheme()
    local state = lurek.ui.parseWidgetState("normal")
    local result = lurek.ui.renderToImage(320, 240, "save/ui_render.png")
    print("newTheme ok; parseWidgetState:", state, "renderToImage:", result)
end

--@api-stub: lurek.ui.renderToImage
do
    local th = lurek.ui.newTheme()
    local state = lurek.ui.parseWidgetState("normal")
    local result = lurek.ui.renderToImage(320, 240, "save/ui_render.png")
    print("newTheme ok; parseWidgetState:", state, "renderToImage:", result)
end

--@api-stub: lurek.ui.setDefaultTheme
do
    local th = lurek.ui.newTheme(); lurek.ui.setTheme(th)
    lurek.ui.setDefaultTheme()
    lurek.ui.setViewport(1280, 720)
    local cnt = lurek.ui.getWidgetCount()
    print("setTheme/setDefaultTheme/setViewport ok; widgets:", cnt)
end

--@api-stub: lurek.ui.setViewport
do
    local th = lurek.ui.newTheme(); lurek.ui.setTheme(th)
    lurek.ui.setDefaultTheme()
    lurek.ui.setViewport(1280, 720)
    local cnt = lurek.ui.getWidgetCount()
    print("setTheme/setDefaultTheme/setViewport ok; widgets:", cnt)
end

--@api-stub: lurek.ui.textinput
do
    lurek.ui.textinput("hello"); lurek.ui.textinput(" world")
    lurek.ui.update_bindings({dt=0.016})
    lurek.ui.wheelmoved(0, 1)
    lurek.ui.wheelmoved(1, 0)
    print("textinput/update_bindings/wheelmoved ok")
end

--@api-stub: lurek.ui.update_bindings
do
    lurek.ui.textinput("hello"); lurek.ui.textinput(" world")
    lurek.ui.update_bindings({dt=0.016})
    lurek.ui.wheelmoved(0, 1)
    lurek.ui.wheelmoved(1, 0)
    print("textinput/update_bindings/wheelmoved ok")
end

--@api-stub: lurek.ui.wheelmoved
do
    local panel = lurek.ui.newScrollPanel(); panel:setPosition(300, 520); panel:setSize(120, 70); panel:setZOrder(2500)
    panel:setContentSize(120, 300)
    lurek.ui.mousemoved(310, 530); lurek.ui.wheelmoved(0, -3)
    local _, sy = panel:getScrollPosition()
    print("hover scroll y:", sy)
end

--@api-stub: LTextInput:isFocused
do
    local input = lurek.ui.newTextInput(); input:setPosition(20, 650); input:setSize(160, 28); input:setZOrder(2600)
    lurek.ui.setFocus(input)
    lurek.ui.textinput("42")
    lurek.ui.keypressed("left")
    lurek.ui.textinput(".")
    lurek.ui.update(0)
    print("focused text:", input:isFocused(), input:getText())
end

--@api-stub: LUiWidget:setOnChange
do
    local toolbar = lurek.ui.newToolbar("horizontal"); toolbar:setPosition(220, 650); toolbar:setSize(120, 32); toolbar:setZOrder(2610)
    toolbar:addButton("save", "Save")
    toolbar:setOnChange(function() print("toolbar changed") end)
    lurek.ui.mousepressed(230, 666, 1); lurek.ui.mousereleased(230, 666, 1)
    lurek.ui.update(0)
    print("save toggled:", toolbar:isButtonToggled("save"))
end

--@api-stub: LRadioButton:setOnChange
do
    local cash = lurek.ui.newRadioButton("Cash", "payment_kind"); cash:setPosition(370, 650); cash:setSize(100, 24); cash:setZOrder(2620)
    local card = lurek.ui.newRadioButton("Card", "payment_kind"); card:setPosition(370, 678); card:setSize(100, 24); card:setZOrder(2630)
    card:setOnChange(function() print("card selected") end)
    lurek.ui.mousepressed(380, 688, 1); lurek.ui.mousereleased(380, 688, 1)
    lurek.ui.update(0)
    print("cash/card:", cash:isSelected(), card:isSelected())
end

--@api-stub: LScrollBar:setOnChange
do
    local bar = lurek.ui.newScrollBar(true); bar:setPosition(500, 650); bar:setSize(20, 100); bar:setZOrder(2640)
    bar:setContentSize(400); bar:setViewSize(100)
    bar:setOnChange(function() print("scrollbar changed") end)
    lurek.ui.mousepressed(510, 720, 1); lurek.ui.mousemoved(510, 740); lurek.ui.mousereleased(510, 740, 1)
    lurek.ui.update(0)
    print("scrollbar position:", bar:getScrollPosition())
end

--@api-stub: LGuiWindow:setOnClose
do
    local win = lurek.ui.newWindow("Inspector"); win:setPosition(550, 650); win:setSize(150, 90); win:setZOrder(2650)
    win:setOnClose(function() print("window closed") end)
    lurek.ui.mousepressed(690, 660, 1); lurek.ui.mousereleased(690, 660, 1)
    lurek.ui.update(0)
    print("window visible:", win:isVisible())
end

--@api-stub: LDialog:setOnClose
do
    local dialog = lurek.ui.newDialog("Confirm"); dialog:setPosition(720, 650); dialog:setSize(180, 100); dialog:setZOrder(2660)
    dialog:addButton("Close")
    dialog:setOnClose(function() print("dialog closed") end)
    dialog:open()
    lurek.ui.mousepressed(830, 724, 1); lurek.ui.mousereleased(830, 724, 1)
    lurek.ui.update(0)
    print("dialog open:", dialog:isOpen())
end

--@api-stub: LUiWidget.setMouseFilter
do
    -- Sets the mouse filter mode on a panel. "ignore" passes events to underlying widgets,
    -- useful for decorative overlays or transparent layout containers.
    local panel = lurek.ui.newPanel()
    panel:setMouseFilter("ignore")
    print("mouse filter set to ignore")
end

--@api-stub: LUiWidget.getMouseFilter
do
    -- Retrieves the current mouse filter behavior of a widget.
    local panel = lurek.ui.newPanel()
    panel:setMouseFilter("pass")
    local filter = panel:getMouseFilter()
    print("mouse filter: " .. filter)
end

--@api-stub: LUiWidget.setStyleClass
do
    -- Assigns a custom style class to a widget. If defined in the active theme,
    -- the button will use "primary" colors and metrics instead of default ones.
    local btn = lurek.ui.newButton("Submit")
    btn:setStyleClass("primary")
    print("style class set to primary")
end

--@api-stub: LUiWidget.getStyleClass
do
    -- Retrieves the currently assigned style class of a widget, or an empty string if none.
    local btn = lurek.ui.newButton("Cancel")
    btn:setStyleClass("danger")
    local class = btn:getStyleClass()
    print("style class: " .. class)
end

--@api-stub: LUiWidget:setAlign
do
    -- Configures the flexbox cross-axis alignment. "center" aligns children
    -- vertically in a horizontal layout.
    local layout = lurek.ui.newLayout("horizontal")
    layout:setAlign("center")
    print("align set to center")
end

--@api-stub: LUiWidget:getAlign
do
    -- Gets the current flexbox alignment property.
    local layout = lurek.ui.newLayout("horizontal")
    layout:setAlign("stretch")
    local align = layout:getAlign()
    print("align: " .. align)
end

--@api-stub: LUiWidget:setJustify
do
    -- Configures the flexbox main-axis justification. "space-between" spreads
    -- children to edges.
    local layout = lurek.ui.newLayout("horizontal")
    layout:setJustify("space-between")
    print("justify set to space-between")
end

--@api-stub: LUiWidget:getJustify
do
    -- Gets the current flexbox justification property.
    local layout = lurek.ui.newLayout("horizontal")
    layout:setJustify("end")
    local justify = layout:getJustify()
    print("justify: " .. justify)
end

--@api-stub: LScatterPlot:addSeriesFromDataFrame
do
    -- Adds a series of points to a scatter plot by pulling 'x' and 'y' columns
    -- directly from a dataframe.
    local df = lurek.dataframe.fromRows({ "x", "y" }, { { 1, 2 }, { 3, 4 }, { 5, 6 } })
    local chart = lurek.ui.newScatterPlot({width = 200, height = 100})
    local count = chart:addSeriesFromDataFrame("Data", df, "x", "y", 0.5, 0.5, 0.5)
    print("scatter df points=" .. count)
end

--@api-stub: LGuiTable.clearRows
do
    -- Removes all rows from a GUI table without deleting its column definitions.
    local tbl = lurek.ui.newTable()
    tbl:addColumn("Name")
    tbl:addRow({"Alice"})
    tbl:clearRows()
    print("cleared rows")
end

--@api-stub: LGuiTable.setRows
do
    -- Bulk-replaces all current rows with the provided list of row data.
    local tbl = lurek.ui.newTable()
    tbl:addColumn("Score")
    tbl:setRows({{"100"}, {"200"}})
    print("set rows")
end

--@api-stub: LGuiTable.setDataFrame
do
    -- Binds a dataframe to the table, automatically setting columns and rows
    -- to match the dataframe contents.
    local df = lurek.dataframe.fromRows({ "Player", "Score" }, { { "Alice", 100 }, { "Bob", 200 } })
    local tbl = lurek.ui.newTable()
    tbl:setDataFrame(df)
    print("set dataframe")
end

print("content/examples/ui.lua")
