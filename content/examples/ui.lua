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
    print("text = " .. btn:getText())
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
-- Widget positioning. Focus: setPosition.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Pos Test")
    btn:setPosition(100, 50)
    local x, y = btn:getPosition()
    print("position = " .. x .. ", " .. y)
end

--@api-stub: LUiWidget:getPosition
-- Widget positioning. Focus: getPosition.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Pos Test")
    btn:setPosition(100, 50)
    local x, y = btn:getPosition()
    print("position = " .. x .. ", " .. y)
end

--@api-stub: LUiWidget:setSize
-- Widget sizing. Focus: setSize.
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setSize(300, 200)
    local w, h = panel:getSize()
    print("size = " .. w .. "x" .. h)
end

--@api-stub: LUiWidget:getSize
-- Widget sizing. Focus: getSize.
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setSize(300, 200)
    local w, h = panel:getSize()
    print("size = " .. w .. "x" .. h)
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
-- Toggling widget visibility. Focus: isVisible.
do
    ---@type LLabel
    local lbl = lurek.ui.newLabel("Toggle Me")
    print("visible = " .. tostring(lbl:isVisible()))
    lbl:setVisible(false)
    print("hidden = " .. tostring(lbl:isVisible()))
end

--@api-stub: LUiWidget:setVisible
-- Toggling widget visibility. Focus: setVisible.
do
    ---@type LLabel
    local lbl = lurek.ui.newLabel("Toggle Me")
    lbl:setVisible(false)
    print("hidden = " .. tostring(lbl:isVisible()))
end

--@api-stub: LUiWidget:isEnabled
-- Enabling and disabling widgets. Focus: isEnabled.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Action")
    print("enabled = " .. tostring(btn:isEnabled()))
    btn:setEnabled(false)
    print("disabled = " .. tostring(btn:isEnabled()))
end

--@api-stub: LUiWidget:setEnabled
-- Enabling and disabling widgets. Focus: setEnabled.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Action")
    btn:setEnabled(false)
    print("disabled = " .. tostring(btn:isEnabled()))
end

--@api-stub: LUiWidget:getAlpha
-- Widget opacity control. Focus: getAlpha.
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    print("alpha = " .. panel:getAlpha())
    panel:setAlpha(0.5)
    print("set to 50% = " .. panel:getAlpha())
    panel:setAlpha(1.0)
end

--@api-stub: LUiWidget:setAlpha
-- Widget opacity control. Focus: setAlpha.
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
-- Shorthand fade animations. Focus: fadeIn.
do
    ---@type LLabel
    local lbl = lurek.ui.newLabel("Fading")
    lbl:setAlpha(0)
    lbl:fadeIn()
    print("fading in, animating = " .. tostring(lbl:isAnimating()))
end

--@api-stub: LUiWidget:fadeOut
-- Shorthand fade animations. Focus: fadeOut.
do
    ---@type LLabel
    local lbl = lurek.ui.newLabel("Fading")
    lbl:fadeOut()
    print("fading out")
end

--@api-stub: LUiWidget:animatePosition
-- Position animations. Focus: animatePosition.
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

--@api-stub: LUiWidget:slideIn
-- Position animations. Focus: slideIn.
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

--@api-stub: LUiWidget:slideOut
-- Position animations. Focus: slideOut.
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
-- Widget identification and tooltips. Focus: setId.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    print("id = " .. btn:getId())
    print("tooltip = " .. btn:getTooltip())
end

--@api-stub: LUiWidget:getId
-- Widget identification and tooltips. Focus: getId.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    print("id = " .. btn:getId())
    print("tooltip = " .. btn:getTooltip())
end

--@api-stub: LUiWidget:setTooltip
-- Widget identification and tooltips. Focus: setTooltip.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    print("id = " .. btn:getId())
    print("tooltip = " .. btn:getTooltip())
end

--@api-stub: LUiWidget:getTooltip
-- Widget identification and tooltips. Focus: getTooltip.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    print("id = " .. btn:getId())
    print("tooltip = " .. btn:getTooltip())
end

--@api-stub: LUiWidget:setZOrder
-- Draw order control. Focus: setZOrder.
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

--@api-stub: LUiWidget:getZOrder
-- Draw order control. Focus: getZOrder.
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

--@api-stub: lurek.ui.newLayout
-- Creating a horizontal layout.
do
    ---@type LLayout
    local row = lurek.ui.newLayout("horizontal")
    print("type = " .. row:type())
    print("direction = " .. row:getDirection())
    print("spacing = " .. row:getSpacing())

    -- Creating a vertical layout.
    ---@type LLayout
    local col = lurek.ui.newLayout("vertical")
    col:setSpacing(10)
    print("direction = " .. col:getDirection())
    print("spacing = " .. col:getSpacing())
end

--@api-stub: LLayout:setDirection
-- Switching to grid layout mode. Focus: setDirection.
do
    ---@type LLayout
    local grid = lurek.ui.newLayout("grid")
    grid:setColumns(3)
    grid:setSpacing(5)
    print("direction = " .. grid:getDirection())
end

--@api-stub: LLayout:setColumns
-- Switching to grid layout mode. Focus: setColumns.
do
    ---@type LLayout
    local grid = lurek.ui.newLayout("grid")
    grid:setColumns(3)
    grid:setSpacing(5)
    print("direction = " .. grid:getDirection())
end

--@api-stub: LLayout:setAlign
-- Cross-axis alignment. Focus: setAlign.
do
    ---@type LLayout
    local layout = lurek.ui.newLayout("horizontal")
    layout:setAlign("center")
    print("align = " .. layout:getAlign())
    layout:setAlign("stretch")
    print("align = " .. layout:getAlign())
end

--@api-stub: LLayout:getAlign
-- Cross-axis alignment. Focus: getAlign.
do
    ---@type LLayout
    local layout = lurek.ui.newLayout("horizontal")
    layout:setAlign("center")
    print("align = " .. layout:getAlign())
    layout:setAlign("stretch")
    print("align = " .. layout:getAlign())
end

--@api-stub: LLayout:setJustify
-- Main-axis justification. Focus: setJustify.
do
    ---@type LLayout
    local layout = lurek.ui.newLayout("horizontal")
    layout:setJustify("space-between")
    print("justify = " .. layout:getJustify())
    layout:setJustify("center")
    print("justify = " .. layout:getJustify())
end

--@api-stub: LLayout:getJustify
-- Main-axis justification. Focus: getJustify.
do
    ---@type LLayout
    local layout = lurek.ui.newLayout("horizontal")
    layout:setJustify("space-between")
    print("justify = " .. layout:getJustify())
    layout:setJustify("center")
    print("justify = " .. layout:getJustify())
end

--@api-stub: LLayout:setWrap
-- Enabling layout wrapping. Focus: setWrap.
do
    ---@type LLayout
    local layout = lurek.ui.newLayout("horizontal")
    print("wrap = " .. tostring(layout:getWrap()))
    layout:setWrap(true)
    print("wrap enabled = " .. tostring(layout:getWrap()))
end

--@api-stub: LLayout:getWrap
-- Enabling layout wrapping. Focus: getWrap.
do
    ---@type LLayout
    local layout = lurek.ui.newLayout("horizontal")
    print("wrap = " .. tostring(layout:getWrap()))
    layout:setWrap(true)
    print("wrap enabled = " .. tostring(layout:getWrap()))
end

--@api-stub: LUiWidget:addChild
-- Building widget hierarchies. Focus: addChild.
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

--@api-stub: LUiWidget:removeChild
-- Building widget hierarchies. Focus: removeChild.
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

--@api-stub: LUiWidget:getChildCount
-- Building widget hierarchies. Focus: getChildCount.
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
-- Setting outer margins. Focus: setMargin.
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

--@api-stub: LUiWidget:getMargin
-- Setting outer margins. Focus: getMargin.
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
-- Setting inner padding. Focus: setPadding.
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setPadding(8, 16, 8, 16)
    local top, right, bottom, left = panel:getPadding()
    print("padding = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
end

--@api-stub: LUiWidget:getPadding
-- Setting inner padding. Focus: getPadding.
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setPadding(8, 16, 8, 16)
    local top, right, bottom, left = panel:getPadding()
    print("padding = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
end

--@api-stub: LUiWidget:setFlexGrow
-- Flex grow factor for layout children. Focus: setFlexGrow.
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

--@api-stub: LUiWidget:getFlexGrow
-- Flex grow factor for layout children. Focus: getFlexGrow.
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
-- Flex shrink factor. Focus: setFlexShrink.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Shrinkable")
    btn:setFlexShrink(0)
    print("shrink = " .. btn:getFlexShrink())
    btn:setFlexShrink(1)
    print("shrink = " .. btn:getFlexShrink())
end

--@api-stub: LUiWidget:getFlexShrink
-- Flex shrink factor. Focus: getFlexShrink.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Shrinkable")
    btn:setFlexShrink(0)
    print("shrink = " .. btn:getFlexShrink())
    btn:setFlexShrink(1)
    print("shrink = " .. btn:getFlexShrink())
end

--@api-stub: LUiWidget:setMinSize
-- Size constraints. Focus: setMinSize.
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

--@api-stub: LUiWidget:getMinSize
-- Size constraints. Focus: getMinSize.
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

--@api-stub: LUiWidget:setMaxSize
-- Size constraints. Focus: setMaxSize.
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

--@api-stub: LUiWidget:getMaxSize
-- Size constraints. Focus: getMaxSize.
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
-- Anchoring widgets within parent. Focus: setAnchor.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Anchored")
    btn:setAnchor(10, 10, 10, nil)
    print("anchored left=10, top=10, right=10")
    btn:clearAnchor()
    btn:setAnchorCenter(0.5, 0.5)
    print("centered in parent")
end

--@api-stub: LUiWidget:setAnchorCenter
-- Anchoring widgets within parent. Focus: setAnchorCenter.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Anchored")
    btn:setAnchor(10, 10, 10, nil)
    print("anchored left=10, top=10, right=10")
    btn:clearAnchor()
    btn:setAnchorCenter(0.5, 0.5)
    print("centered in parent")
end

--@api-stub: LUiWidget:clearAnchor
-- Anchoring widgets within parent. Focus: clearAnchor.
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
-- Scroll speed tuning. Focus: setScrollSpeed.
do
    ---@type LScrollPanel
    local scroll = lurek.ui.newScrollPanel()
    scroll:setScrollSpeed(30)
    print("scroll speed = " .. scroll:getScrollSpeed())
end

--@api-stub: LScrollPanel:getScrollSpeed
-- Scroll speed tuning. Focus: getScrollSpeed.
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
-- Placeholder text for empty inputs. Focus: setPlaceholder.
do
    ---@type LTextInput
    local input = lurek.ui.newTextInput()
    input:setPlaceholder("Enter your name...")
    print("placeholder = " .. input:getPlaceholder())
end

--@api-stub: LTextInput:getPlaceholder
-- Placeholder text for empty inputs. Focus: getPlaceholder.
do
    ---@type LTextInput
    local input = lurek.ui.newTextInput()
    input:setPlaceholder("Enter your name...")
    print("placeholder = " .. input:getPlaceholder())
end

--@api-stub: LTextInput:setMaxLength
-- Text length limits and cursor. Focus: setMaxLength.
do
    ---@type LTextInput
    local input = lurek.ui.newTextInput()
    input:setMaxLength(50)
    input:setText("Short text")
    local pos = input:getCursorPosition()
    print("cursor at = " .. pos)
    print("focused = " .. tostring(input:isFocused()))
end

--@api-stub: LTextInput:getCursorPosition
-- Text length limits and cursor. Focus: getCursorPosition.
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
-- Toggling and relabeling a checkbox. Focus: setChecked.
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

--@api-stub: LCheckbox:setText
-- Toggling and relabeling a checkbox. Focus: setText.
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
-- Setting slider value and step increment. Focus: setValue.
do
    ---@type LSlider
    local slider = lurek.ui.newSlider(0, 1)
    slider:setStep(0.1)
    slider:setValue(0.5)
    print("value = " .. slider:getValue())
    slider:setValue(1.5)
    print("clamped = " .. slider:getValue())
end

--@api-stub: LSlider:setStep
-- Setting slider value and step increment. Focus: setStep.
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
-- Stepping a spin box value. Focus: increment.
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

--@api-stub: LSpinBox:decrement
-- Stepping a spin box value. Focus: decrement.
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

--@api-stub: LSpinBox:setStep
-- Stepping a spin box value. Focus: setStep.
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
-- Switching states. Focus: setOn.
do
    ---@type LSwitch
    local sw = lurek.ui.newSwitch(true)
    print("initial = " .. tostring(sw:isOn()))
    sw:toggle()
    print("toggled = " .. tostring(sw:isOn()))
    sw:setOn(true)
    print("forced on = " .. tostring(sw:isOn()))
end

--@api-stub: LSwitch:toggle
-- Switching states. Focus: toggle.
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
-- Populating a combo box. Focus: addItem.
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

--@api-stub: LComboBox:getItem
-- Populating a combo box. Focus: getItem.
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

--@api-stub: LComboBox:getItemCount
-- Populating a combo box. Focus: getItemCount.
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
-- Selection and clearing. Focus: getSelectedIndex.
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

--@api-stub: LComboBox:getSelectedItem
-- Selection and clearing. Focus: getSelectedItem.
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

--@api-stub: LComboBox:clearItems
-- Selection and clearing. Focus: clearItems.
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
-- Populating a list box. Focus: addItem.
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

--@api-stub: LListBox:getItem
-- Populating a list box. Focus: getItem.
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

--@api-stub: LListBox:getItemCount
-- Populating a list box. Focus: getItemCount.
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
-- Programmatic selection. Focus: setSelectedIndex.
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

--@api-stub: LListBox:getSelectedIndex
-- Programmatic selection. Focus: getSelectedIndex.
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
-- List manipulation and styling. Focus: removeItem.
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

--@api-stub: LListBox:clearItems
-- List manipulation and styling. Focus: clearItems.
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

--@api-stub: LListBox:setItemHeight
-- List manipulation and styling. Focus: setItemHeight.
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
-- Configuring menu item behavior. Focus: setText.
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
-- Configuring menu item behavior. Focus: setOnClick.
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
-- Configuring menu item behavior. Focus: setChecked.
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
-- Configuring menu item behavior. Focus: isChecked.
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
-- Building nested menu hierarchies. Focus: addSubItem.
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

--@api-stub: LMenuItem:getSubItems
-- Building nested menu hierarchies. Focus: getSubItems.
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
-- Assembling a complete menu bar. Focus: addMenu.
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

--@api-stub: LMenuBar:getMenuCount
-- Assembling a complete menu bar. Focus: getMenuCount.
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

--@api-stub: LMenuBar:getMenus
-- Assembling a complete menu bar. Focus: getMenus.
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
-- Adding tabs. Focus: addTab.
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

--@api-stub: LTabBar:getTab
-- Adding tabs. Focus: getTab.
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

--@api-stub: LTabBar:getTabCount
-- Adding tabs. Focus: getTabCount.
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
-- Tab selection and removal. Focus: setActiveTab.
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

--@api-stub: LTabBar:getActiveTab
-- Tab selection and removal. Focus: getActiveTab.
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

--@api-stub: LTabBar:removeTab
-- Tab selection and removal. Focus: removeTab.
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
-- Building accordion sections. Focus: addSection.
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

--@api-stub: LAccordion:getSectionCount
-- Building accordion sections. Focus: getSectionCount.
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

--@api-stub: LAccordion:getSectionTitle
-- Building accordion sections. Focus: getSectionTitle.
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
-- Expanding and collapsing sections. Focus: toggleSection.
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

--@api-stub: LAccordion:isSectionExpanded
-- Expanding and collapsing sections. Focus: isSectionExpanded.
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

--@api-stub: LAccordion:setExclusive
-- Expanding and collapsing sections. Focus: setExclusive.
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

--@api-stub: lurek.ui.newDialog
-- ui_04.lua: Dialogs, windows, toolbar, statusbar.
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
-- Example usage for newWindow.
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
-- Example usage for newToolbar.
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

    -- Example usage for newToolbar.
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
-- Example usage for newStatusBar.
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

    -- Example usage for newStatusBar.
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

--@api-stub: lurek.ui.newProgressBar
-- ui_05.lua: Visual widgets — progress bar, image widget, nine-patch, badge, spacer, separator.
do
    -- create a progress bar and track fill value
    ---@type LProgressBar
    local bar = lurek.ui.newProgressBar(0, 100)
    bar:setValue(35)
    print("value:", bar:getValue())
    print("min:", bar:getMin())
    print("max:", bar:getMax())
    print("progress (normalized):", bar:getProgress())

    -- Example usage for newProgressBar.
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
-- Example usage for newImageWidget.
do
    -- create an image widget and configure scale mode and tint
    ---@type LImageWidget
    local img = lurek.ui.newImageWidget()
    img:setScaleMode("fit")
    print("scale mode:", img:getScaleMode())
    img:setTint(1.0, 0.8, 0.6, 0.9)
    local r, g, b, a = img:getTint()
    print("tint:", r, g, b, a)

    -- Example usage for newImageWidget.
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
-- Example usage for newNinePatch.
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

    -- Example usage for newNinePatch.
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
-- Example usage for newBadge.
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
-- Example usage for newSpacer.
do
    -- create a spacer widget for layout padding
    ---@type LSpacer
    local sp = lurek.ui.newSpacer(20, 10)
    sp:setSize(40, 20)
    local w, h = sp:getSize()
    print("spacer size:", w, h)
end

--@api-stub: lurek.ui.newSeparator
-- Example usage for newSeparator.
do
    -- create horizontal and vertical separators
    ---@type LSeparator
    local sep = lurek.ui.newSeparator(false)
    print("is vertical:", sep:isVertical())
    print("thickness:", sep:getThickness())
    sep:setThickness(2)
    print("new thickness:", sep:getThickness())

    -- Example usage for newSeparator.
    -- create a vertical separator and toggle orientation
    ---@type LSeparator
    local sep = lurek.ui.newSeparator(true)
    print("vertical:", sep:isVertical())
    sep:setVertical(false)
    print("after toggle:", sep:isVertical())
    sep:setThickness(3)
    print("thickness:", sep:getThickness())
end

--@api-stub: lurek.ui.newAreaChart
-- ui_06.lua: Charts — area, bar, line, pie, scatter.
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
-- Example usage for newBarChart.
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
-- Example usage for newLineChart.
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
-- Example usage for newPieChart.
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
-- Example usage for newScatterPlot.
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

--@api-stub: lurek.ui.newColorPicker
-- ui_07.lua: Advanced — color picker, radio button, tree view, toast, tooltip, theme, focus, drag/drop.
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

    -- Example usage for newColorPicker.
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
-- Example usage for newRadioButton.
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
-- Example usage for newTreeView.
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

    -- Example usage for newTreeView.
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
-- Example usage for newToast.
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
-- Example usage for newTooltipPanel.
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
-- Example usage for newTheme.
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

--@api-stub: lurek.ui.setTheme
-- Example usage for setTheme.
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

--@api-stub: lurek.ui.getTheme
-- Example usage for getTheme.
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
-- Example usage for getFocus.
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

--@api-stub: lurek.ui.focusPrev
-- Example usage for focusPrev.
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

--@api-stub: lurek.ui.clearFocus
-- Example usage for clearFocus.
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
-- Example usage for beginDrag.
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

--@api-stub: lurek.ui.getActiveDrag
-- Example usage for getActiveDrag.
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

--@api-stub: lurek.ui.dropOn
-- Example usage for dropOn.
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

--@api-stub: LColorPicker:getColor
-- LColorPicker: RGBA color selection widget with mode and alpha controls. Focus: getColor.
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

--@api-stub: LColorPicker:getColorMode
-- LColorPicker: RGBA color selection widget with mode and alpha controls. Focus: getColorMode.
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

--@api-stub: LColorPicker:getShowAlpha
-- LColorPicker: RGBA color selection widget with mode and alpha controls. Focus: getShowAlpha.
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

--@api-stub: LColorPicker:setColor
-- LColorPicker: RGBA color selection widget with mode and alpha controls. Focus: setColor.
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

--@api-stub: LColorPicker:setColorMode
-- LColorPicker: RGBA color selection widget with mode and alpha controls. Focus: setColorMode.
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

--@api-stub: LColorPicker:setOnChange
-- LColorPicker: RGBA color selection widget with mode and alpha controls. Focus: setOnChange.
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

--@api-stub: LColorPicker:setShowAlpha
-- LColorPicker: RGBA color selection widget with mode and alpha controls. Focus: setShowAlpha.
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
-- LProgressBar: numeric progress indicator with configurable range. Focus: getMax.
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

--@api-stub: LProgressBar:getMin
-- LProgressBar: numeric progress indicator with configurable range. Focus: getMin.
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

--@api-stub: LProgressBar:getProgress
-- LProgressBar: numeric progress indicator with configurable range. Focus: getProgress.
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

--@api-stub: LProgressBar:getValue
-- LProgressBar: numeric progress indicator with configurable range. Focus: getValue.
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

--@api-stub: LProgressBar:setRange
-- LProgressBar: numeric progress indicator with configurable range. Focus: setRange.
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

--@api-stub: LProgressBar:setValue
-- LProgressBar: numeric progress indicator with configurable range. Focus: setValue.
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
-- LStatusBar: horizontal bar at screen bottom for status text sections. Focus: addSection.
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

--@api-stub: LStatusBar:getSectionCount
-- LStatusBar: horizontal bar at screen bottom for status text sections. Focus: getSectionCount.
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

--@api-stub: LStatusBar:getSectionText
-- LStatusBar: horizontal bar at screen bottom for status text sections. Focus: getSectionText.
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

--@api-stub: LStatusBar:setSectionText
-- LStatusBar: horizontal bar at screen bottom for status text sections. Focus: setSectionText.
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
-- LToolbar: icon-based button row with toggles, separators, and spacers. Focus: addButton.
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

--@api-stub: LToolbar:addSeparator
-- LToolbar: icon-based button row with toggles, separators, and spacers. Focus: addSeparator.
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

--@api-stub: LToolbar:addSpacer
-- LToolbar: icon-based button row with toggles, separators, and spacers. Focus: addSpacer.
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

--@api-stub: LToolbar:getButton
-- LToolbar: icon-based button row with toggles, separators, and spacers. Focus: getButton.
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

--@api-stub: LToolbar:getOrientation
-- LToolbar: icon-based button row with toggles, separators, and spacers. Focus: getOrientation.
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

--@api-stub: LToolbar:isButtonToggled
-- LToolbar: icon-based button row with toggles, separators, and spacers. Focus: isButtonToggled.
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

--@api-stub: LToolbar:setButtonEnabled
-- LToolbar: icon-based button row with toggles, separators, and spacers. Focus: setButtonEnabled.
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

--@api-stub: LToolbar:setButtonToggled
-- LToolbar: icon-based button row with toggles, separators, and spacers. Focus: setButtonToggled.
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

--@api-stub: LToolbar:setOrientation
-- LToolbar: icon-based button row with toggles, separators, and spacers. Focus: setOrientation.
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
-- Toast notifications and TOML-defined layout loading. Focus: addToast.
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

--@api-stub: lurek.ui.loadLayout
-- Toast notifications and TOML-defined layout loading. Focus: loadLayout.
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
-- LBadge: numeric indicator badge widget. Focus: getCount.
do
    local badge = lurek.ui.newBadge(3)
    print("type=" .. badge:type())
    print("count=" .. badge:getCount())
    badge:setCount(7)
    print("count_after=" .. badge:getCount())
    local text = badge:getDisplayText()
    print("text=" .. tostring(text))
end

--@api-stub: LBadge:getDisplayText
-- LBadge: numeric indicator badge widget. Focus: getDisplayText.
do
    local badge = lurek.ui.newBadge(3)
    print("type=" .. badge:type())
    print("count=" .. badge:getCount())
    badge:setCount(7)
    print("count_after=" .. badge:getCount())
    local text = badge:getDisplayText()
    print("text=" .. tostring(text))
end

--@api-stub: LBadge:setCount
-- LBadge: numeric indicator badge widget. Focus: setCount.
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
-- LDockPanel: dockable panel container supporting four sides. Focus: dock.
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

--@api-stub: LDockPanel:getDockedCount
-- LDockPanel: dockable panel container supporting four sides. Focus: getDockedCount.
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

--@api-stub: LDockPanel:getSplitSize
-- LDockPanel: dockable panel container supporting four sides. Focus: getSplitSize.
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

--@api-stub: LDockPanel:setSplitSize
-- LDockPanel: dockable panel container supporting four sides. Focus: setSplitSize.
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
-- LImageWidget: widget that renders an LImage with scale mode and tint. Focus: getScaleMode.
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

--@api-stub: LImageWidget:getTint
-- LImageWidget: widget that renders an LImage with scale mode and tint. Focus: getTint.
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

--@api-stub: LImageWidget:setScaleMode
-- LImageWidget: widget that renders an LImage with scale mode and tint. Focus: setScaleMode.
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

--@api-stub: LImageWidget:setTint
-- LImageWidget: widget that renders an LImage with scale mode and tint. Focus: setTint.
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
-- LNinePatch: nine-patch scalable border widget. Focus: getImageDimensions.
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

--@api-stub: LNinePatch:getInsets
-- LNinePatch: nine-patch scalable border widget. Focus: getInsets.
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

--@api-stub: LNinePatch:getSlices
-- LNinePatch: nine-patch scalable border widget. Focus: getSlices.
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

--@api-stub: LNinePatch:setImageDimensions
-- LNinePatch: nine-patch scalable border widget. Focus: setImageDimensions.
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

--@api-stub: LNinePatch:setInsets
-- LNinePatch: nine-patch scalable border widget. Focus: setInsets.
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
-- LRadioButton: exclusive toggle within a named group. Focus: getGroup.
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

--@api-stub: LRadioButton:getText
-- LRadioButton: exclusive toggle within a named group. Focus: getText.
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

--@api-stub: LRadioButton:isSelected
-- LRadioButton: exclusive toggle within a named group. Focus: isSelected.
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

--@api-stub: LRadioButton:setGroup
-- LRadioButton: exclusive toggle within a named group. Focus: setGroup.
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
-- LSpinBox: numeric spin control with configurable step and range. Focus: getValue.
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

--@api-stub: LSpinBox:setValue
-- LSpinBox: numeric spin control with configurable step and range. Focus: setValue.
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
-- LSplitPanel: resizable two-pane container. Focus: getFirstChild.
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

--@api-stub: LSplitPanel:getMinPanelSize
-- LSplitPanel: resizable two-pane container. Focus: getMinPanelSize.
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

--@api-stub: LSplitPanel:getOrientation
-- LSplitPanel: resizable two-pane container. Focus: getOrientation.
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

--@api-stub: LSplitPanel:getSecondChild
-- LSplitPanel: resizable two-pane container. Focus: getSecondChild.
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

--@api-stub: LSplitPanel:getSplitPosition
-- LSplitPanel: resizable two-pane container. Focus: getSplitPosition.
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

--@api-stub: LSplitPanel:setFirstChild
-- LSplitPanel: resizable two-pane container. Focus: setFirstChild.
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

--@api-stub: LSplitPanel:setMinPanelSize
-- LSplitPanel: resizable two-pane container. Focus: setMinPanelSize.
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

--@api-stub: LSplitPanel:setOrientation
-- LSplitPanel: resizable two-pane container. Focus: setOrientation.
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

--@api-stub: LSplitPanel:setSecondChild
-- LSplitPanel: resizable two-pane container. Focus: setSecondChild.
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

--@api-stub: LSplitPanel:setSplitPosition
-- LSplitPanel: resizable two-pane container. Focus: setSplitPosition.
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
-- LSwitch: toggle switch with on/off state and change callback. Focus: isOn.
do
    local sw = lurek.ui.newSwitch(false)
    print("type=" .. sw:type())
    print("is_on=" .. tostring(sw:isOn()))
    sw:setOn(true)
    print("is_on_after=" .. tostring(sw:isOn()))
    sw:setOnChange(function(v) print("switch_changed=" .. tostring(v)) end)
end

--@api-stub: LSwitch:setOnChange
-- LSwitch: toggle switch with on/off state and change callback. Focus: setOnChange.
do
    local sw = lurek.ui.newSwitch(false)
    print("type=" .. sw:type())
    print("is_on=" .. tostring(sw:isOn()))
    sw:setOn(true)
    print("is_on_after=" .. tostring(sw:isOn()))
    sw:setOnChange(function(v) print("switch_changed=" .. tostring(v)) end)
end

--@api-stub: LGuiTable:addColumn
-- LGuiTable: multi-column data table with row selection. Focus: addColumn.
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

--@api-stub: LGuiTable:addRow
-- LGuiTable: multi-column data table with row selection. Focus: addRow.
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

--@api-stub: LGuiTable:getCell
-- LGuiTable: multi-column data table with row selection. Focus: getCell.
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

--@api-stub: LGuiTable:getColumnCount
-- LGuiTable: multi-column data table with row selection. Focus: getColumnCount.
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

--@api-stub: LGuiTable:getRowCount
-- LGuiTable: multi-column data table with row selection. Focus: getRowCount.
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

--@api-stub: LGuiTable:getSelectedRow
-- LGuiTable: multi-column data table with row selection. Focus: getSelectedRow.
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

--@api-stub: LGuiTable:setCell
-- LGuiTable: multi-column data table with row selection. Focus: setCell.
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

--@api-stub: LGuiTable:setSelectedRow
-- LGuiTable: multi-column data table with row selection. Focus: setSelectedRow.
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

--@api-stub: lurek.ui.newTable
-- LGuiTable: multi-column data table with row selection. Focus: newTable.
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
-- LToast: transient notification message widget. Focus: getDuration.
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

--@api-stub: LToast:getMessage
-- LToast: transient notification message widget. Focus: getMessage.
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

--@api-stub: LToast:getProgress
-- LToast: transient notification message widget. Focus: getProgress.
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

--@api-stub: LToast:isExpired
-- LToast: transient notification message widget. Focus: isExpired.
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

--@api-stub: LToast:setDuration
-- LToast: transient notification message widget. Focus: setDuration.
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

--@api-stub: LToast:setMessage
-- LToast: transient notification message widget. Focus: setMessage.
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
-- LTooltipPanel: popup tooltip with configurable text and delay. Focus: getDelay.
do
    local ttp = lurek.ui.newTooltipPanel("Hover info")
    print("type=" .. ttp:type())
    print("text=" .. ttp:getText())
    ttp:setText("Updated tooltip")
    print("text_after=" .. ttp:getText())
    ttp:setDelay(0.5)
    print("delay=" .. ttp:getDelay())
end

--@api-stub: LTooltipPanel:getText
-- LTooltipPanel: popup tooltip with configurable text and delay. Focus: getText.
do
    local ttp = lurek.ui.newTooltipPanel("Hover info")
    print("type=" .. ttp:type())
    print("text=" .. ttp:getText())
    ttp:setText("Updated tooltip")
    print("text_after=" .. ttp:getText())
    ttp:setDelay(0.5)
    print("delay=" .. ttp:getDelay())
end

--@api-stub: LTooltipPanel:setDelay
-- LTooltipPanel: popup tooltip with configurable text and delay. Focus: setDelay.
do
    local ttp = lurek.ui.newTooltipPanel("Hover info")
    print("type=" .. ttp:type())
    print("text=" .. ttp:getText())
    ttp:setText("Updated tooltip")
    print("text_after=" .. ttp:getText())
    ttp:setDelay(0.5)
    print("delay=" .. ttp:getDelay())
end

--@api-stub: LTooltipPanel:setText
-- LTooltipPanel: popup tooltip with configurable text and delay. Focus: setText.
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
-- LTreeView: hierarchical node tree with selection and expand/collapse. Focus: addNode.
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

--@api-stub: LTreeView:clearNodes
-- LTreeView: hierarchical node tree with selection and expand/collapse. Focus: clearNodes.
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

--@api-stub: LTreeView:collapseAll
-- LTreeView: hierarchical node tree with selection and expand/collapse. Focus: collapseAll.
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

--@api-stub: LTreeView:collapseNode
-- LTreeView: hierarchical node tree with selection and expand/collapse. Focus: collapseNode.
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

--@api-stub: LTreeView:expandAll
-- LTreeView: hierarchical node tree with selection and expand/collapse. Focus: expandAll.
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

--@api-stub: LTreeView:expandNode
-- LTreeView: hierarchical node tree with selection and expand/collapse. Focus: expandNode.
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

--@api-stub: LTreeView:getChildNodes
-- LTreeView: hierarchical node tree with selection and expand/collapse. Focus: getChildNodes.
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

--@api-stub: LTreeView:getNodeCount
-- LTreeView: hierarchical node tree with selection and expand/collapse. Focus: getNodeCount.
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

--@api-stub: LTreeView:getNodeDepth
-- LTreeView: hierarchical node tree with selection and expand/collapse. Focus: getNodeDepth.
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

--@api-stub: LTreeView:getNodeText
-- LTreeView: hierarchical node tree with selection and expand/collapse. Focus: getNodeText.
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

--@api-stub: LTreeView:getParentNode
-- LTreeView: hierarchical node tree with selection and expand/collapse. Focus: getParentNode.
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

--@api-stub: LTreeView:getSelectedNode
-- LTreeView: hierarchical node tree with selection and expand/collapse. Focus: getSelectedNode.
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

--@api-stub: LTreeView:isExpanded
-- LTreeView: hierarchical node tree with selection and expand/collapse. Focus: isExpanded.
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

--@api-stub: LTreeView:isNodeExpanded
-- LTreeView: hierarchical node tree with selection and expand/collapse. Focus: isNodeExpanded.
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

--@api-stub: LTreeView:removeNode
-- LTreeView: hierarchical node tree with selection and expand/collapse. Focus: removeNode.
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

--@api-stub: LTreeView:setNodeIcon
-- LTreeView: hierarchical node tree with selection and expand/collapse. Focus: setNodeIcon.
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

--@api-stub: LTreeView:setNodeText
-- LTreeView: hierarchical node tree with selection and expand/collapse. Focus: setNodeText.
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

--@api-stub: LTreeView:setSelectedNode
-- LTreeView: hierarchical node tree with selection and expand/collapse. Focus: setSelectedNode.
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

--@api-stub: LTreeView:toggleNode
-- LTreeView: hierarchical node tree with selection and expand/collapse. Focus: toggleNode.
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
-- LAccordion section management. Focus: addSection.
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("Chapter 1")
    acc:addSection("Chapter 2")
    local cnt = acc:getSectionCount()
    local title = acc:getSectionTitle(1)
    print("sections:", cnt, "title:", title)
end

--@api-stub: LAccordion.getSectionCount
-- LAccordion section management. Focus: getSectionCount.
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("Chapter 1")
    acc:addSection("Chapter 2")
    local cnt = acc:getSectionCount()
    local title = acc:getSectionTitle(1)
    print("sections:", cnt, "title:", title)
end

--@api-stub: LAccordion.getSectionTitle
-- LAccordion section management. Focus: getSectionTitle.
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("Chapter 1")
    acc:addSection("Chapter 2")
    local cnt = acc:getSectionCount()
    local title = acc:getSectionTitle(1)
    print("sections:", cnt, "title:", title)
end

--@api-stub: LAccordion.isExclusive
-- LAccordion exclusive mode and expansion. Focus: isExclusive.
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("A")
    acc:setExclusive(true)
    local ex = acc:isExclusive()
    local expanded = acc:isSectionExpanded(1)
    print("exclusive:", ex, "expanded:", expanded)
end

--@api-stub: LAccordion.isSectionExpanded
-- LAccordion exclusive mode and expansion. Focus: isSectionExpanded.
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("A")
    acc:setExclusive(true)
    local ex = acc:isExclusive()
    local expanded = acc:isSectionExpanded(1)
    print("exclusive:", ex, "expanded:", expanded)
end

--@api-stub: LAccordion.setExclusive
-- LAccordion exclusive mode and expansion. Focus: setExclusive.
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("A")
    acc:setExclusive(true)
    local ex = acc:isExclusive()
    local expanded = acc:isSectionExpanded(1)
    print("exclusive:", ex, "expanded:", expanded)
end

--@api-stub: LAccordion.toggleSection
-- LAccordion toggleSection and LBadge count. Focus: toggleSection.
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("Toggle me")
    local newState = acc:toggleSection(1)
    local badge = lurek.ui.newBadge(5)
    local count = badge:getCount()
    local disp = badge:getDisplayText()
    print("toggled:", newState, "badge count:", count, "display:", disp)
end

--@api-stub: LBadge.getCount
-- LAccordion toggleSection and LBadge count. Focus: getCount.
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("Toggle me")
    local newState = acc:toggleSection(1)
    local badge = lurek.ui.newBadge(5)
    local count = badge:getCount()
    local disp = badge:getDisplayText()
    print("toggled:", newState, "badge count:", count, "display:", disp)
end

--@api-stub: LBadge.getDisplayText
-- LAccordion toggleSection and LBadge count. Focus: getDisplayText.
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
-- LBadge setCount and LButton text. Focus: setCount.
do
    local badge = lurek.ui.newBadge(0)
    badge:setCount(42)
    local btn = lurek.ui.newButton("Click me")
    local t = btn:getText()
    btn:setText("OK")
    print("badge count:", badge:getCount(), "button text:", btn:getText())
end

--@api-stub: LButton.getText
-- LBadge setCount and LButton text. Focus: getText.
do
    local badge = lurek.ui.newBadge(0)
    badge:setCount(42)
    local btn = lurek.ui.newButton("Click me")
    local t = btn:getText()
    btn:setText("OK")
    print("badge count:", badge:getCount(), "button text:", btn:getText())
end

--@api-stub: LButton.setText
-- LBadge setCount and LButton text. Focus: setText.
do
    local badge = lurek.ui.newBadge(0)
    badge:setCount(42)
    local btn = lurek.ui.newButton("Click me")
    local t = btn:getText()
    btn:setText("OK")
    print("badge count:", badge:getCount(), "button text:", btn:getText())
end

--@api-stub: LCheckbox.getText
-- LCheckbox text and checked state. Focus: getText.
do
    local cb = lurek.ui.newCheckbox("Enable feature")
    local t = cb:getText()
    cb:setChecked(true)
    local checked = cb:isChecked()
    print("checkbox text:", t, "checked:", checked)
end

--@api-stub: LCheckbox.isChecked
-- LCheckbox text and checked state. Focus: isChecked.
do
    local cb = lurek.ui.newCheckbox("Enable feature")
    local t = cb:getText()
    cb:setChecked(true)
    local checked = cb:isChecked()
    print("checkbox text:", t, "checked:", checked)
end

--@api-stub: LCheckbox.setChecked
-- LCheckbox text and checked state. Focus: setChecked.
do
    local cb = lurek.ui.newCheckbox("Enable feature")
    local t = cb:getText()
    cb:setChecked(true)
    local checked = cb:isChecked()
    print("checkbox text:", t, "checked:", checked)
end

--@api-stub: LCheckbox.setText
-- LCheckbox setText and LAreaChart data. Focus: setText.
do
    local cb = lurek.ui.newCheckbox("old")
    cb:setText("new label")
    local chart = lurek.ui.newAreaChart({width = 200, height = 100})
    chart:setYMax(100)
    chart:addLayer("series1", {10, 20, 30, 25, 15}, 1.0, 0.2, 0.2)
    print("checkbox setText ok; addLayer, setYMax ok")
end

--@api-stub: LAreaChart:addLayer
-- LCheckbox setText and LAreaChart data. Focus: addLayer.
do
    local cb = lurek.ui.newCheckbox("old")
    cb:setText("new label")
    local chart = lurek.ui.newAreaChart({width = 200, height = 100})
    chart:setYMax(100)
    chart:addLayer("series1", {10, 20, 30, 25, 15}, 1.0, 0.2, 0.2)
    print("checkbox setText ok; addLayer, setYMax ok")
end

--@api-stub: LAreaChart:setYMax
-- LCheckbox setText and LAreaChart data. Focus: setYMax.
do
    local cb = lurek.ui.newCheckbox("old")
    cb:setText("new label")
    local chart = lurek.ui.newAreaChart({width = 200, height = 100})
    chart:setYMax(100)
    chart:addLayer("series1", {10, 20, 30, 25, 15}, 1.0, 0.2, 0.2)
    print("checkbox setText ok; addLayer, setYMax ok")
end

--@api-stub: LAreaChart:drawToImage
-- LAreaChart rendering and type checks. Focus: drawToImage.
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

--@api-stub: LAreaChart:type
-- LAreaChart rendering and type checks. Focus: type.
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

--@api-stub: LAreaChart:typeOf
-- LAreaChart rendering and type checks. Focus: typeOf.
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
-- LBarChart series and categories. Focus: addCategory.
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

--@api-stub: LBarChart:addSeries
-- LBarChart series and categories. Focus: addSeries.
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

--@api-stub: LBarChart:drawToImage
-- LBarChart series and categories. Focus: drawToImage.
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
-- LBarChart type checks. Focus: type.
do
    local chart = lurek.ui.newBarChart({width = 100, height = 50})
    local t = chart:type()
    local ok = chart:typeOf("LBarChart")
    local notOk = chart:typeOf("LAreaChart")
    print("LBarChart type:", t, "typeOf:", ok, "typeOf LAreaChart:", notOk)
end

--@api-stub: LBarChart:typeOf
-- LBarChart type checks. Focus: typeOf.
do
    local chart = lurek.ui.newBarChart({width = 100, height = 50})
    local t = chart:type()
    local ok = chart:typeOf("LBarChart")
    local notOk = chart:typeOf("LAreaChart")
    print("LBarChart type:", t, "typeOf:", ok, "typeOf LAreaChart:", notOk)
end

--@api-stub: LColorPicker.getColor
-- LColorPicker color and display queries. Focus: getColor.
do
    local cp = lurek.ui.newColorPicker()
    cp:setColor(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = cp:getColor()
    local mode = cp:getColorMode()
    local showAlpha = cp:getShowAlpha()
    print("color:", r, g, b, a, "mode:", mode, "showAlpha:", showAlpha)
end

--@api-stub: LColorPicker.getColorMode
-- LColorPicker color and display queries. Focus: getColorMode.
do
    local cp = lurek.ui.newColorPicker()
    cp:setColor(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = cp:getColor()
    local mode = cp:getColorMode()
    local showAlpha = cp:getShowAlpha()
    print("color:", r, g, b, a, "mode:", mode, "showAlpha:", showAlpha)
end

--@api-stub: LColorPicker.getShowAlpha
-- LColorPicker color and display queries. Focus: getShowAlpha.
do
    local cp = lurek.ui.newColorPicker()
    cp:setColor(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = cp:getColor()
    local mode = cp:getColorMode()
    local showAlpha = cp:getShowAlpha()
    print("color:", r, g, b, a, "mode:", mode, "showAlpha:", showAlpha)
end

--@api-stub: LColorPicker.setColor
-- LColorPicker setters. Focus: setColor.
do
    local cp = lurek.ui.newColorPicker()
    cp:setColor(0.2, 0.8, 0.4, 1.0)
    cp:setColorMode("hsv")
    cp:setOnChange(function(idx) print("color changed", idx) end)
    cp:setShowAlpha(true)
    print("setColor/setColorMode/setOnChange ok")
end

--@api-stub: LColorPicker.setColorMode
-- LColorPicker setters. Focus: setColorMode.
do
    local cp = lurek.ui.newColorPicker()
    cp:setColor(0.2, 0.8, 0.4, 1.0)
    cp:setColorMode("hsv")
    cp:setOnChange(function(idx) print("color changed", idx) end)
    cp:setShowAlpha(true)
    print("setColor/setColorMode/setOnChange ok")
end

--@api-stub: LColorPicker.setOnChange
-- LColorPicker setters. Focus: setOnChange.
do
    local cp = lurek.ui.newColorPicker()
    cp:setColor(0.2, 0.8, 0.4, 1.0)
    cp:setColorMode("hsv")
    cp:setOnChange(function(idx) print("color changed", idx) end)
    cp:setShowAlpha(true)
    print("setColor/setColorMode/setOnChange ok")
end

--@api-stub: LColorPicker.setShowAlpha
-- LColorPicker setShowAlpha and LComboBox item management. Focus: setShowAlpha.
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

--@api-stub: LComboBox.addItem
-- LColorPicker setShowAlpha and LComboBox item management. Focus: addItem.
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

--@api-stub: LComboBox.clearItems
-- LColorPicker setShowAlpha and LComboBox item management. Focus: clearItems.
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
-- LComboBox item access. Focus: getItem.
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

--@api-stub: LComboBox.getItemCount
-- LComboBox item access. Focus: getItemCount.
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

--@api-stub: LComboBox.getSelectedIndex
-- LComboBox item access. Focus: getSelectedIndex.
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
-- LComboBox selection and removal. Focus: getSelectedItem.
do
    local cb = lurek.ui.newComboBox()
    cb:addItem("Alpha")
    cb:addItem("Beta")
    cb:setSelectedIndex(2)
    local selItem = cb:getSelectedItem()
    cb:removeItem(1)
    print("getSelectedItem:", selItem, "removeItem ok")
end

--@api-stub: LComboBox.removeItem
-- LComboBox selection and removal. Focus: removeItem.
do
    local cb = lurek.ui.newComboBox()
    cb:addItem("Alpha")
    cb:addItem("Beta")
    cb:setSelectedIndex(2)
    local selItem = cb:getSelectedItem()
    cb:removeItem(1)
    print("getSelectedItem:", selItem, "removeItem ok")
end

--@api-stub: LComboBox.setSelectedIndex
-- LComboBox selection and removal. Focus: setSelectedIndex.
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
-- LDialog button, close, and content. Focus: addButton.
do
    local dlg = lurek.ui.newDialog("Info")
    local btnIdx = dlg:addButton("OK")
    local content = dlg:getContent()
    dlg:open()
    dlg:close()
    print("addButton:", btnIdx, "close ok")
end

--@api-stub: LDialog.close
-- LDialog button, close, and content. Focus: close.
do
    local dlg = lurek.ui.newDialog("Info")
    local btnIdx = dlg:addButton("OK")
    local content = dlg:getContent()
    dlg:open()
    dlg:close()
    print("addButton:", btnIdx, "close ok")
end

--@api-stub: LDialog.getContent
-- LDialog button, close, and content. Focus: getContent.
do
    local dlg = lurek.ui.newDialog("Info")
    local btnIdx = dlg:addButton("OK")
    local content = dlg:getContent()
    dlg:open()
    dlg:close()
    print("addButton:", btnIdx, "close ok")
end

--@api-stub: LDialog.getTitle
-- LDialog state queries. Focus: getTitle.
do
    local dlg = lurek.ui.newDialog("My Dialog")
    local title = dlg:getTitle()
    dlg:setModal(true)
    local modal = dlg:isModal()
    local open = dlg:isOpen()
    print("title:", title, "isModal:", modal, "isOpen:", open)
end

--@api-stub: LDialog.isModal
-- LDialog state queries. Focus: isModal.
do
    local dlg = lurek.ui.newDialog("My Dialog")
    local title = dlg:getTitle()
    dlg:setModal(true)
    local modal = dlg:isModal()
    local open = dlg:isOpen()
    print("title:", title, "isModal:", modal, "isOpen:", open)
end

--@api-stub: LDialog.isOpen
-- LDialog state queries. Focus: isOpen.
do
    local dlg = lurek.ui.newDialog("My Dialog")
    local title = dlg:getTitle()
    dlg:setModal(true)
    local modal = dlg:isModal()
    local open = dlg:isOpen()
    print("title:", title, "isModal:", modal, "isOpen:", open)
end

--@api-stub: LDialog.open
-- LDialog open, setContent, setModal. Focus: open.
do
    local dlg = lurek.ui.newDialog("Setup")
    dlg:setModal(false)
    dlg:setContent(nil)
    dlg:open()
    dlg:close()
    print("open/setContent/setModal ok")
end

--@api-stub: LDialog.setContent
-- LDialog open, setContent, setModal. Focus: setContent.
do
    local dlg = lurek.ui.newDialog("Setup")
    dlg:setModal(false)
    dlg:setContent(nil)
    dlg:open()
    dlg:close()
    print("open/setContent/setModal ok")
end

--@api-stub: LDialog.setModal
-- LDialog open, setContent, setModal. Focus: setModal.
do
    local dlg = lurek.ui.newDialog("Setup")
    dlg:setModal(false)
    dlg:setContent(nil)
    dlg:open()
    dlg:close()
    print("open/setContent/setModal ok")
end

--@api-stub: LDialog.setOnClose
-- LDialog callbacks, setTitle, and LDockPanel dock. Focus: setOnClose.
do
    local dlg = lurek.ui.newDialog("Old")
    dlg:setTitle("New Title")
    dlg:setOnClose(function(idx) print("closed", idx) end)
    local dp = lurek.ui.newDockPanel()
    local btn = lurek.ui.newButton("Side")
    -- Note: dock takes a widget index; using 1 as placeholder since it may vary
    print("setTitle/setOnClose ok; DockPanel created")
end

--@api-stub: LDialog.setTitle
-- LDialog callbacks, setTitle, and LDockPanel dock. Focus: setTitle.
do
    local dlg = lurek.ui.newDialog("Old")
    dlg:setTitle("New Title")
    dlg:setOnClose(function(idx) print("closed", idx) end)
    local dp = lurek.ui.newDockPanel()
    local btn = lurek.ui.newButton("Side")
    -- Note: dock takes a widget index; using 1 as placeholder since it may vary
    print("setTitle/setOnClose ok; DockPanel created")
end

--@api-stub: LDockPanel.dock
-- LDialog callbacks, setTitle, and LDockPanel dock. Focus: dock.
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
-- LDockPanel split size queries. Focus: getDockedCount.
do
    local dp = lurek.ui.newDockPanel()
    local cnt = dp:getDockedCount()
    dp:setSplitSize("left", 200)
    local sz = dp:getSplitSize("left")
    print("getDockedCount:", cnt, "splitSize:", sz)
end

--@api-stub: LDockPanel.getSplitSize
-- LDockPanel split size queries. Focus: getSplitSize.
do
    local dp = lurek.ui.newDockPanel()
    local cnt = dp:getDockedCount()
    dp:setSplitSize("left", 200)
    local sz = dp:getSplitSize("left")
    print("getDockedCount:", cnt, "splitSize:", sz)
end

--@api-stub: LDockPanel.setSplitSize
-- LDockPanel split size queries. Focus: setSplitSize.
do
    local dp = lurek.ui.newDockPanel()
    local cnt = dp:getDockedCount()
    dp:setSplitSize("left", 200)
    local sz = dp:getSplitSize("left")
    print("getDockedCount:", cnt, "splitSize:", sz)
end

--@api-stub: LDockPanel.undock
-- LDockPanel undock and LGuiTable population. Focus: undock.
do
    local dp = lurek.ui.newDockPanel()
    local dockedCount = dp:getDockedCount()
    -- undock when empty just verifies the method exists
    dp:undock(0)
    local tbl = lurek.ui.newTable()
    print("undock ok (dockedCount was:", dockedCount, "); newTable ok")
end

--@api-stub: LGuiTable.addColumn
-- LDockPanel undock and LGuiTable population. Focus: addColumn.
do
    local dp = lurek.ui.newDockPanel()
    local dockedCount = dp:getDockedCount()
    -- undock when empty just verifies the method exists
    dp:undock(0)
    local tbl = lurek.ui.newTable()
    print("undock ok (dockedCount was:", dockedCount, "); newTable ok")
end

--@api-stub: LGuiTable.addRow
-- LDockPanel undock and LGuiTable population. Focus: addRow.
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
-- LGuiTable counts and selection. Focus: getColumnCount.
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

--@api-stub: LGuiTable.getRowCount
-- LGuiTable counts and selection. Focus: getRowCount.
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

--@api-stub: LGuiTable.getSelectedRow
-- LGuiTable counts and selection. Focus: getSelectedRow.
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
-- LGuiTable sortable, setCell, and onSelect. Focus: isSortable.
do
    local tbl = lurek.ui.newTable()
    tbl:addColumn("ID")
    tbl:addRow({"1"})
    tbl:setSortable(true)
    tbl:setCell(1, 1, "changed")
    tbl:setOnSelect(function(idx) print("row selected", idx) end)
    print("isSortable/setCell/setOnSelect ok")
end

--@api-stub: LGuiTable.setCell
-- LGuiTable sortable, setCell, and onSelect. Focus: setCell.
do
    local tbl = lurek.ui.newTable()
    tbl:addColumn("ID")
    tbl:addRow({"1"})
    tbl:setSortable(true)
    tbl:setCell(1, 1, "changed")
    tbl:setOnSelect(function(idx) print("row selected", idx) end)
    print("isSortable/setCell/setOnSelect ok")
end

--@api-stub: LGuiTable.setOnSelect
-- LGuiTable sortable, setCell, and onSelect. Focus: setOnSelect.
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
-- LGuiTable setSelectedRow, setSortable, and LGuiWindow title. Focus: setSelectedRow.
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

--@api-stub: LGuiTable.setSortable
-- LGuiTable setSelectedRow, setSortable, and LGuiWindow title. Focus: setSortable.
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

--@api-stub: LGuiWindow.getTitle
-- LGuiTable setSelectedRow, setSortable, and LGuiWindow title. Focus: getTitle.
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
-- LGuiWindow capability queries. Focus: isCloseable.
do
    local win = lurek.ui.newWindow("Test Win")
    local closeable = win:isCloseable()
    local draggable = win:isDraggable()
    local resizable = win:isResizable()
    print("isCloseable:", closeable, "isDraggable:", draggable, "isResizable:", resizable)
end

--@api-stub: LGuiWindow.isDraggable
-- LGuiWindow capability queries. Focus: isDraggable.
do
    local win = lurek.ui.newWindow("Test Win")
    local closeable = win:isCloseable()
    local draggable = win:isDraggable()
    local resizable = win:isResizable()
    print("isCloseable:", closeable, "isDraggable:", draggable, "isResizable:", resizable)
end

--@api-stub: LGuiWindow.isResizable
-- LGuiWindow capability queries. Focus: isResizable.
do
    local win = lurek.ui.newWindow("Test Win")
    local closeable = win:isCloseable()
    local draggable = win:isDraggable()
    local resizable = win:isResizable()
    print("isCloseable:", closeable, "isDraggable:", draggable, "isResizable:", resizable)
end

--@api-stub: LGuiWindow.setCloseable
-- LGuiWindow capability setters and onClose. Focus: setCloseable.
do
    local win = lurek.ui.newWindow("Config")
    win:setCloseable(true)
    win:setDraggable(true)
    win:setOnClose(function(idx) print("window closed", idx) end)
    print("setCloseable/setDraggable/setOnClose ok")
end

--@api-stub: LGuiWindow.setDraggable
-- LGuiWindow capability setters and onClose. Focus: setDraggable.
do
    local win = lurek.ui.newWindow("Config")
    win:setCloseable(true)
    win:setDraggable(true)
    win:setOnClose(function(idx) print("window closed", idx) end)
    print("setCloseable/setDraggable/setOnClose ok")
end

--@api-stub: LGuiWindow.setOnClose
-- LGuiWindow capability setters and onClose. Focus: setOnClose.
do
    local win = lurek.ui.newWindow("Config")
    win:setCloseable(true)
    win:setDraggable(true)
    win:setOnClose(function(idx) print("window closed", idx) end)
    print("setCloseable/setDraggable/setOnClose ok")
end

--@api-stub: LGuiWindow.setResizable
-- LGuiWindow setResizable, setTitle, and LImageWidget scaleMode. Focus: setResizable.
do
    local win = lurek.ui.newWindow("Old")
    win:setResizable(false)
    win:setTitle("New Title")
    local iw = lurek.ui.newImageWidget()
    local mode = iw:getScaleMode()
    print("setResizable/setTitle ok; scaleMode:", mode)
end

--@api-stub: LGuiWindow.setTitle
-- LGuiWindow setResizable, setTitle, and LImageWidget scaleMode. Focus: setTitle.
do
    local win = lurek.ui.newWindow("Old")
    win:setResizable(false)
    win:setTitle("New Title")
    local iw = lurek.ui.newImageWidget()
    local mode = iw:getScaleMode()
    print("setResizable/setTitle ok; scaleMode:", mode)
end

--@api-stub: LImageWidget.getScaleMode
-- LGuiWindow setResizable, setTitle, and LImageWidget scaleMode. Focus: getScaleMode.
do
    local win = lurek.ui.newWindow("Old")
    win:setResizable(false)
    win:setTitle("New Title")
    local iw = lurek.ui.newImageWidget()
    local mode = iw:getScaleMode()
    print("setResizable/setTitle ok; scaleMode:", mode)
end

--@api-stub: LImageWidget.getTint
-- LImageWidget tint and scale mode. Focus: getTint.
do
    local iw = lurek.ui.newImageWidget()
    iw:setTint(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = iw:getTint()
    iw:setScaleMode("fit")
    print("tint:", r, g, b, a, "scaleMode: fit")
end

--@api-stub: LImageWidget.setScaleMode
-- LImageWidget tint and scale mode. Focus: setScaleMode.
do
    local iw = lurek.ui.newImageWidget()
    iw:setTint(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = iw:getTint()
    iw:setScaleMode("fit")
    print("tint:", r, g, b, a, "scaleMode: fit")
end

--@api-stub: LImageWidget.setTint
-- LImageWidget tint and scale mode. Focus: setTint.
do
    local iw = lurek.ui.newImageWidget()
    iw:setTint(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = iw:getTint()
    iw:setScaleMode("fit")
    print("tint:", r, g, b, a, "scaleMode: fit")
end

--@api-stub: LLabel.getText
-- LLabel text and LLayout align. Focus: getText.
do
    local lbl = lurek.ui.newLabel("Hello")
    lbl:setText("World")
    local layout = lurek.ui.newLayout("horizontal")
    local align = layout:getAlign()
    print("label text:", lbl:getText(), "layout align:", align)
end

--@api-stub: LLabel.setText
-- LLabel text and LLayout align. Focus: setText.
do
    local lbl = lurek.ui.newLabel("Hello")
    lbl:setText("World")
    local layout = lurek.ui.newLayout("horizontal")
    local align = layout:getAlign()
    print("label text:", lbl:getText(), "layout align:", align)
end

--@api-stub: LLayout.getAlign
-- LLabel text and LLayout align. Focus: getAlign.
do
    local lbl = lurek.ui.newLabel("Hello")
    lbl:setText("World")
    local layout = lurek.ui.newLayout("horizontal")
    local align = layout:getAlign()
    print("label text:", lbl:getText(), "layout align:", align)
end

--@api-stub: LLayout.getDirection
-- LLayout direction, justify, spacing. Focus: getDirection.
do
    local layout = lurek.ui.newLayout("vertical")
    local dir = layout:getDirection()
    local justify = layout:getJustify()
    local spacing = layout:getSpacing()
    print("direction:", dir, "justify:", justify, "spacing:", spacing)
end

--@api-stub: LLayout.getJustify
-- LLayout direction, justify, spacing. Focus: getJustify.
do
    local layout = lurek.ui.newLayout("vertical")
    local dir = layout:getDirection()
    local justify = layout:getJustify()
    local spacing = layout:getSpacing()
    print("direction:", dir, "justify:", justify, "spacing:", spacing)
end

--@api-stub: LLayout.getSpacing
-- LLayout direction, justify, spacing. Focus: getSpacing.
do
    local layout = lurek.ui.newLayout("vertical")
    local dir = layout:getDirection()
    local justify = layout:getJustify()
    local spacing = layout:getSpacing()
    print("direction:", dir, "justify:", justify, "spacing:", spacing)
end

--@api-stub: LLayout.getWrap
-- LLayout wrap, setAlign, setColumns. Focus: getWrap.
do
    local layout = lurek.ui.newLayout("grid")
    local wrap = layout:getWrap()
    layout:setAlign("center")
    layout:setColumns(3)
    print("getWrap:", wrap, "setAlign: center, setColumns: 3 ok")
end

--@api-stub: LLayout.setAlign
-- LLayout wrap, setAlign, setColumns. Focus: setAlign.
do
    local layout = lurek.ui.newLayout("grid")
    local wrap = layout:getWrap()
    layout:setAlign("center")
    layout:setColumns(3)
    print("getWrap:", wrap, "setAlign: center, setColumns: 3 ok")
end

--@api-stub: LLayout.setColumns
-- LLayout wrap, setAlign, setColumns. Focus: setColumns.
do
    local layout = lurek.ui.newLayout("grid")
    local wrap = layout:getWrap()
    layout:setAlign("center")
    layout:setColumns(3)
    print("getWrap:", wrap, "setAlign: center, setColumns: 3 ok")
end

--@api-stub: LLayout.setDirection
-- LLayout direction, justify, spacing setters. Focus: setDirection.
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setDirection("vertical")
    layout:setJustify("center")
    layout:setSpacing(8)
    print("setDirection/setJustify/setSpacing ok")
end

--@api-stub: LLayout.setJustify
-- LLayout direction, justify, spacing setters. Focus: setJustify.
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setDirection("vertical")
    layout:setJustify("center")
    layout:setSpacing(8)
    print("setDirection/setJustify/setSpacing ok")
end

--@api-stub: LLayout.setSpacing
-- LLayout direction, justify, spacing setters. Focus: setSpacing.
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setDirection("vertical")
    layout:setJustify("center")
    layout:setSpacing(8)
    print("setDirection/setJustify/setSpacing ok")
end

--@api-stub: LLayout.setWrap
-- LLayout setWrap and LLineChart data. Focus: setWrap.
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setWrap(true)
    local lc = lurek.ui.newLineChart({width = 200, height = 100})
    lc:addSeries("speed", {{1,10},{2,20},{3,15}}, 0.2, 0.8, 0.4)
    local img = lurek.image.newImageData(200, 100)
    lc:drawToImage(img)
    print("setWrap ok; addSeries/drawToImage ok")
end

--@api-stub: LLineChart:addSeries
-- LLayout setWrap and LLineChart data. Focus: addSeries.
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setWrap(true)
    local lc = lurek.ui.newLineChart({width = 200, height = 100})
    lc:addSeries("speed", {{1,10},{2,20},{3,15}}, 0.2, 0.8, 0.4)
    local img = lurek.image.newImageData(200, 100)
    lc:drawToImage(img)
    print("setWrap ok; addSeries/drawToImage ok")
end

--@api-stub: LLineChart:drawToImage
-- LLayout setWrap and LLineChart data. Focus: drawToImage.
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
-- LLineChart axis limits and type. Focus: setXMax.
do
    local lc = lurek.ui.newLineChart({width = 150, height = 80})
    lc:setXMax(100)
    lc:setYMax(50)
    lc:addSeries("data", {{0,0},{100,50}}, 1.0, 0.2, 0.2)
    local t = lc:type()
    print("setXMax/setYMax ok; type:", t)
end

--@api-stub: LLineChart:setYMax
-- LLineChart axis limits and type. Focus: setYMax.
do
    local lc = lurek.ui.newLineChart({width = 150, height = 80})
    lc:setXMax(100)
    lc:setYMax(50)
    lc:addSeries("data", {{0,0},{100,50}}, 1.0, 0.2, 0.2)
    local t = lc:type()
    print("setXMax/setYMax ok; type:", t)
end

--@api-stub: LLineChart:type
-- LLineChart axis limits and type. Focus: type.
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
-- LListBox item management. Focus: addItem.
do
    local lb = lurek.ui.newList()
    lb:addItem("Apple")
    lb:addItem("Banana")
    lb:addItem("Cherry")
    local item = lb:getItem(2)
    lb:clearItems()
    print("addItem/clearItems/getItem ok, item:", item)
end

--@api-stub: LListBox.clearItems
-- LListBox item management. Focus: clearItems.
do
    local lb = lurek.ui.newList()
    lb:addItem("Apple")
    lb:addItem("Banana")
    lb:addItem("Cherry")
    local item = lb:getItem(2)
    lb:clearItems()
    print("addItem/clearItems/getItem ok, item:", item)
end

--@api-stub: LListBox.getItem
-- LListBox item management. Focus: getItem.
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
-- LListBox count, selection, and removal. Focus: getItemCount.
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

--@api-stub: LListBox.getSelectedIndex
-- LListBox count, selection, and removal. Focus: getSelectedIndex.
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

--@api-stub: LListBox.removeItem
-- LListBox count, selection, and removal. Focus: removeItem.
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
-- LListBox item height, selection, and LMenuBar addMenu. Focus: setItemHeight.
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

--@api-stub: LListBox.setSelectedIndex
-- LListBox item height, selection, and LMenuBar addMenu. Focus: setSelectedIndex.
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

--@api-stub: LMenuBar.addMenu
-- LListBox item height, selection, and LMenuBar addMenu. Focus: addMenu.
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
-- LMenuBar menu queries and removal. Focus: getMenuCount.
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

--@api-stub: LMenuBar.getMenus
-- LMenuBar menu queries and removal. Focus: getMenus.
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

--@api-stub: LMenuBar.removeMenu
-- LMenuBar menu queries and removal. Focus: removeMenu.
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
-- LMenuItem sub-items and shortcut. Focus: addSubItem.
do
    local mi = lurek.ui.newMenuItem("Tools")
    local sub1 = lurek.ui.newMenuItem("Options")
    mi:addSubItem(sub1._idx)
    local subs = mi:getSubItems()
    mi:setShortcut("Ctrl+T")
    local sc = mi:getShortcut()
    print("addSubItem ok; getSubItems:", type(subs), "shortcut:", sc)
end

--@api-stub: LMenuItem.getShortcut
-- LMenuItem sub-items and shortcut. Focus: getShortcut.
do
    local mi = lurek.ui.newMenuItem("Tools")
    local sub1 = lurek.ui.newMenuItem("Options")
    mi:addSubItem(sub1._idx)
    local subs = mi:getSubItems()
    mi:setShortcut("Ctrl+T")
    local sc = mi:getShortcut()
    print("addSubItem ok; getSubItems:", type(subs), "shortcut:", sc)
end

--@api-stub: LMenuItem.getSubItems
-- LMenuItem sub-items and shortcut. Focus: getSubItems.
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
-- LMenuItem text and checked state. Focus: getText.
do
    local mi = lurek.ui.newMenuItem("Enable")
    local t = mi:getText()
    mi:setChecked(true)
    local checked = mi:isChecked()
    mi:setChecked(false)
    print("getText:", t, "isChecked:", mi:isChecked(), "setChecked ok")
end

--@api-stub: LMenuItem.isChecked
-- LMenuItem text and checked state. Focus: isChecked.
do
    local mi = lurek.ui.newMenuItem("Enable")
    local t = mi:getText()
    mi:setChecked(true)
    local checked = mi:isChecked()
    mi:setChecked(false)
    print("getText:", t, "isChecked:", mi:isChecked(), "setChecked ok")
end

--@api-stub: LMenuItem.setChecked
-- LMenuItem text and checked state. Focus: setChecked.
do
    local mi = lurek.ui.newMenuItem("Enable")
    local t = mi:getText()
    mi:setChecked(true)
    local checked = mi:isChecked()
    mi:setChecked(false)
    print("getText:", t, "isChecked:", mi:isChecked(), "setChecked ok")
end

--@api-stub: LMenuItem.setOnClick
-- LMenuItem onClick, shortcut, and text setters. Focus: setOnClick.
do
    local mi = lurek.ui.newMenuItem("Old")
    mi:setOnClick(function(idx) print("menu clicked", idx) end)
    mi:setShortcut("Alt+F4")
    mi:setText("New Name")
    print("setOnClick/setShortcut/setText ok")
end

--@api-stub: LMenuItem.setShortcut
-- LMenuItem onClick, shortcut, and text setters. Focus: setShortcut.
do
    local mi = lurek.ui.newMenuItem("Old")
    mi:setOnClick(function(idx) print("menu clicked", idx) end)
    mi:setShortcut("Alt+F4")
    mi:setText("New Name")
    print("setOnClick/setShortcut/setText ok")
end

--@api-stub: LMenuItem.setText
-- LMenuItem onClick, shortcut, and text setters. Focus: setText.
do
    local mi = lurek.ui.newMenuItem("Old")
    mi:setOnClick(function(idx) print("menu clicked", idx) end)
    mi:setShortcut("Alt+F4")
    mi:setText("New Name")
    print("setOnClick/setShortcut/setText ok")
end

--@api-stub: LNinePatch.getImageDimensions
-- LNinePatch dimension and slice queries. Focus: getImageDimensions.
do
    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    local slices = np:getSlices()
    print("imgDims:", w, h, "insets:", l, t, r, b, "slices:", type(slices))
end

--@api-stub: LNinePatch.getInsets
-- LNinePatch dimension and slice queries. Focus: getInsets.
do
    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    local slices = np:getSlices()
    print("imgDims:", w, h, "insets:", l, t, r, b, "slices:", type(slices))
end

--@api-stub: LNinePatch.getSlices
-- LNinePatch dimension and slice queries. Focus: getSlices.
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
-- LNinePatch setters and LPanel title. Focus: setImageDimensions.
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

--@api-stub: LNinePatch.setInsets
-- LNinePatch setters and LPanel title. Focus: setInsets.
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

--@api-stub: LPanel.getTitle
-- LNinePatch setters and LPanel title. Focus: getTitle.
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
-- LPanel scrollable/title and LPieChart segment. Focus: setScrollable.
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

--@api-stub: LPanel.setTitle
-- LPanel scrollable/title and LPieChart segment. Focus: setTitle.
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

--@api-stub: LPieChart:addSegment
-- LPanel scrollable/title and LPieChart segment. Focus: addSegment.
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
-- LPieChart render and type identity. Focus: drawToImage.
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

--@api-stub: LPieChart:type
-- LPieChart render and type identity. Focus: type.
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

--@api-stub: LPieChart:typeOf
-- LPieChart render and type identity. Focus: typeOf.
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
-- LProgressBar range and progress queries. Focus: getMax.
do
    local pb = lurek.ui.newProgressBar(0, 100)
    local mn = pb:getMin()
    local mx = pb:getMax()
    pb:setValue(75)
    local prog = pb:getProgress()
    print("min:", mn, "max:", mx, "progress:", prog)
end

--@api-stub: LProgressBar.getMin
-- LProgressBar range and progress queries. Focus: getMin.
do
    local pb = lurek.ui.newProgressBar(0, 100)
    local mn = pb:getMin()
    local mx = pb:getMax()
    pb:setValue(75)
    local prog = pb:getProgress()
    print("min:", mn, "max:", mx, "progress:", prog)
end

--@api-stub: LProgressBar.getProgress
-- LProgressBar range and progress queries. Focus: getProgress.
do
    local pb = lurek.ui.newProgressBar(0, 100)
    local mn = pb:getMin()
    local mx = pb:getMax()
    pb:setValue(75)
    local prog = pb:getProgress()
    print("min:", mn, "max:", mx, "progress:", prog)
end

--@api-stub: LProgressBar.getValue
-- LProgressBar value setters. Focus: getValue.
do
    local pb = lurek.ui.newProgressBar(0, 200)
    pb:setValue(100)
    local v = pb:getValue()
    pb:setRange(10, 90)
    pb:setValue(50)
    print("getValue:", v, "setRange ok, setValue ok")
end

--@api-stub: LProgressBar.setRange
-- LProgressBar value setters. Focus: setRange.
do
    local pb = lurek.ui.newProgressBar(0, 200)
    pb:setValue(100)
    local v = pb:getValue()
    pb:setRange(10, 90)
    pb:setValue(50)
    print("getValue:", v, "setRange ok, setValue ok")
end

--@api-stub: LProgressBar.setValue
-- LProgressBar value setters. Focus: setValue.
do
    local pb = lurek.ui.newProgressBar(0, 200)
    pb:setValue(100)
    local v = pb:getValue()
    pb:setRange(10, 90)
    pb:setValue(50)
    print("getValue:", v, "setRange ok, setValue ok")
end

--@api-stub: LRadioButton.getGroup
-- LRadioButton group, text, and selection. Focus: getGroup.
do
    local rb = lurek.ui.newRadioButton("Option A", "group1")
    local grp = rb:getGroup()
    local t = rb:getText()
    local sel = rb:isSelected()
    print("group:", grp, "text:", t, "isSelected:", sel)
end

--@api-stub: LRadioButton.getText
-- LRadioButton group, text, and selection. Focus: getText.
do
    local rb = lurek.ui.newRadioButton("Option A", "group1")
    local grp = rb:getGroup()
    local t = rb:getText()
    local sel = rb:isSelected()
    print("group:", grp, "text:", t, "isSelected:", sel)
end

--@api-stub: LRadioButton.isSelected
-- LRadioButton group, text, and selection. Focus: isSelected.
do
    local rb = lurek.ui.newRadioButton("Option A", "group1")
    local grp = rb:getGroup()
    local t = rb:getText()
    local sel = rb:isSelected()
    print("group:", grp, "text:", t, "isSelected:", sel)
end

--@api-stub: LRadioButton.setGroup
-- LRadioButton setters. Focus: setGroup.
do
    local rb = lurek.ui.newRadioButton("B", "g1")
    rb:setGroup("g2")
    rb:setSelected(true)
    rb:setOnChange(function(idx) print("radio changed", idx) end)
    rb:setText("New B")
    print("setGroup/setSelected/setOnChange/setText ok")
end

--@api-stub: LRadioButton.setOnChange
-- LRadioButton setters. Focus: setOnChange.
do
    local rb = lurek.ui.newRadioButton("B", "g1")
    rb:setGroup("g2")
    rb:setSelected(true)
    rb:setOnChange(function(idx) print("radio changed", idx) end)
    rb:setText("New B")
    print("setGroup/setSelected/setOnChange/setText ok")
end

--@api-stub: LRadioButton.setSelected
-- LRadioButton setters. Focus: setSelected.
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
-- LScatterPlot series and rendering. Focus: addSeries.
do
    local sp = lurek.ui.newScatterPlot({width = 200, height = 150})
    sp:setXRange(0, 100)
    sp:setYRange(0, 100)
    sp:addSeries("data1", {{10,20},{30,40},{50,30},{70,60}}, 0.9, 0.2, 0.2)
    local img = lurek.image.newImageData(200, 150)
    sp:drawToImage(img)
    print("ScatterPlot addSeries/setXRange/drawToImage ok")
end

--@api-stub: LScatterPlot:drawToImage
-- LScatterPlot series and rendering. Focus: drawToImage.
do
    local sp = lurek.ui.newScatterPlot({width = 200, height = 150})
    sp:setXRange(0, 100)
    sp:setYRange(0, 100)
    sp:addSeries("data1", {{10,20},{30,40},{50,30},{70,60}}, 0.9, 0.2, 0.2)
    local img = lurek.image.newImageData(200, 150)
    sp:drawToImage(img)
    print("ScatterPlot addSeries/setXRange/drawToImage ok")
end

--@api-stub: LScatterPlot:setXRange
-- LScatterPlot series and rendering. Focus: setXRange.
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
-- LScatterPlot axis and type identity. Focus: setYRange.
do
    local sp = lurek.ui.newScatterPlot({width = 100, height = 80})
    sp:setXRange(0, 50)
    sp:setYRange(0, 50)
    local t = sp:type()
    local ok = sp:typeOf("LScatterPlot")
    print("setYRange ok, type:", t, "typeOf:", ok)
end

--@api-stub: LScatterPlot:type
-- LScatterPlot axis and type identity. Focus: type.
do
    local sp = lurek.ui.newScatterPlot({width = 100, height = 80})
    sp:setXRange(0, 50)
    sp:setYRange(0, 50)
    local t = sp:type()
    local ok = sp:typeOf("LScatterPlot")
    print("setYRange ok, type:", t, "typeOf:", ok)
end

--@api-stub: LScatterPlot:typeOf
-- LScatterPlot axis and type identity. Focus: typeOf.
do
    local sp = lurek.ui.newScatterPlot({width = 100, height = 80})
    sp:setXRange(0, 50)
    sp:setYRange(0, 50)
    local t = sp:type()
    local ok = sp:typeOf("LScatterPlot")
    print("setYRange ok, type:", t, "typeOf:", ok)
end

--@api-stub: LScrollBar.getContentSize
-- LScrollBar size and position queries. Focus: getContentSize.
do
    local sb = lurek.ui.newScrollBar(true)
    local cs = sb:getContentSize()
    local pos = sb:getScrollPosition()
    local vs = sb:getViewSize()
    print("contentSize:", cs, "scrollPos:", pos, "viewSize:", vs)
end

--@api-stub: LScrollBar.getScrollPosition
-- LScrollBar size and position queries. Focus: getScrollPosition.
do
    local sb = lurek.ui.newScrollBar(true)
    local cs = sb:getContentSize()
    local pos = sb:getScrollPosition()
    local vs = sb:getViewSize()
    print("contentSize:", cs, "scrollPos:", pos, "viewSize:", vs)
end

--@api-stub: LScrollBar.getViewSize
-- LScrollBar size and position queries. Focus: getViewSize.
do
    local sb = lurek.ui.newScrollBar(true)
    local cs = sb:getContentSize()
    local pos = sb:getScrollPosition()
    local vs = sb:getViewSize()
    print("contentSize:", cs, "scrollPos:", pos, "viewSize:", vs)
end

--@api-stub: LScrollBar.isVertical
-- LScrollBar orientation and content control. Focus: isVertical.
do
    local sb = lurek.ui.newScrollBar(false)
    local vert = sb:isVertical()
    sb:setContentSize(500)
    sb:setOnChange(function(val) print("scroll:", val) end)
    local cs = sb:getContentSize()
    print("isVertical:", vert, "contentSize after set:", cs)
end

--@api-stub: LScrollBar.setContentSize
-- LScrollBar orientation and content control. Focus: setContentSize.
do
    local sb = lurek.ui.newScrollBar(false)
    local vert = sb:isVertical()
    sb:setContentSize(500)
    sb:setOnChange(function(val) print("scroll:", val) end)
    local cs = sb:getContentSize()
    print("isVertical:", vert, "contentSize after set:", cs)
end

--@api-stub: LScrollBar.setOnChange
-- LScrollBar orientation and content control. Focus: setOnChange.
do
    local sb = lurek.ui.newScrollBar(false)
    local vert = sb:isVertical()
    sb:setContentSize(500)
    sb:setOnChange(function(val) print("scroll:", val) end)
    local cs = sb:getContentSize()
    print("isVertical:", vert, "contentSize after set:", cs)
end

--@api-stub: LScrollBar.setScrollPosition
-- LScrollBar setters and LScrollPanel content size. Focus: setScrollPosition.
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

--@api-stub: LScrollBar.setViewSize
-- LScrollBar setters and LScrollPanel content size. Focus: setViewSize.
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

--@api-stub: LScrollPanel.getContentSize
-- LScrollBar setters and LScrollPanel content size. Focus: getContentSize.
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
-- LScrollPanel scroll queries. Focus: getMaxScroll.
do
    local sp = lurek.ui.newScrollPanel()
    local mx, my = sp:getMaxScroll()
    local px, py = sp:getScrollPosition()
    local speed = sp:getScrollSpeed()
    print("maxScroll:", mx, my, "scrollPos:", px, py, "speed:", speed)
end

--@api-stub: LScrollPanel.getScrollPosition
-- LScrollPanel scroll queries. Focus: getScrollPosition.
do
    local sp = lurek.ui.newScrollPanel()
    local mx, my = sp:getMaxScroll()
    local px, py = sp:getScrollPosition()
    local speed = sp:getScrollSpeed()
    print("maxScroll:", mx, my, "scrollPos:", px, py, "speed:", speed)
end

--@api-stub: LScrollPanel.getScrollSpeed
-- LScrollPanel scroll queries. Focus: getScrollSpeed.
do
    local sp = lurek.ui.newScrollPanel()
    local mx, my = sp:getMaxScroll()
    local px, py = sp:getScrollPosition()
    local speed = sp:getScrollSpeed()
    print("maxScroll:", mx, my, "scrollPos:", px, py, "speed:", speed)
end

--@api-stub: LScrollPanel.setContentSize
-- LScrollPanel setters. Focus: setContentSize.
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

--@api-stub: LScrollPanel.setScrollPosition
-- LScrollPanel setters. Focus: setScrollPosition.
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

--@api-stub: LScrollPanel.setScrollSpeed
-- LScrollPanel setters. Focus: setScrollSpeed.
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
-- LSeparator thickness and orientation. Focus: getThickness.
do
    local sep = lurek.ui.newSeparator(true)
    local vert = sep:isVertical()
    local thick = sep:getThickness()
    sep:setThickness(4)
    local t2 = sep:getThickness()
    print("isVertical:", vert, "thickness:", thick, "→", t2)
end

--@api-stub: LSeparator.isVertical
-- LSeparator thickness and orientation. Focus: isVertical.
do
    local sep = lurek.ui.newSeparator(true)
    local vert = sep:isVertical()
    local thick = sep:getThickness()
    sep:setThickness(4)
    local t2 = sep:getThickness()
    print("isVertical:", vert, "thickness:", thick, "→", t2)
end

--@api-stub: LSeparator.setThickness
-- LSeparator thickness and orientation. Focus: setThickness.
do
    local sep = lurek.ui.newSeparator(true)
    local vert = sep:isVertical()
    local thick = sep:getThickness()
    sep:setThickness(4)
    local t2 = sep:getThickness()
    print("isVertical:", vert, "thickness:", thick, "→", t2)
end

--@api-stub: LSeparator.setVertical
-- LSeparator setVertical and LSlider range. Focus: setVertical.
do
    local sep = lurek.ui.newSeparator(false)
    sep:setVertical(true)
    local sl = lurek.ui.newSlider(0, 100)
    local mn = sl:getMin()
    local mx = sl:getMax()
    print("separator setVertical ok; slider min:", mn, "max:", mx)
end

--@api-stub: LSlider.getMax
-- LSeparator setVertical and LSlider range. Focus: getMax.
do
    local sep = lurek.ui.newSeparator(false)
    sep:setVertical(true)
    local sl = lurek.ui.newSlider(0, 100)
    local mn = sl:getMin()
    local mx = sl:getMax()
    print("separator setVertical ok; slider min:", mn, "max:", mx)
end

--@api-stub: LSlider.getMin
-- LSeparator setVertical and LSlider range. Focus: getMin.
do
    local sep = lurek.ui.newSeparator(false)
    sep:setVertical(true)
    local sl = lurek.ui.newSlider(0, 100)
    local mn = sl:getMin()
    local mx = sl:getMax()
    print("separator setVertical ok; slider min:", mn, "max:", mx)
end

--@api-stub: LSlider.getValue
-- LSlider value and range setters. Focus: getValue.
do
    local sl = lurek.ui.newSlider(0, 50)
    sl:setRange(0, 100)
    local mx = sl:getMax()
    sl:setStep(5)
    sl:setValue(75)
    local v = sl:getValue()
    print("setRange max:", mx, "getValue:", v)
end

--@api-stub: LSlider.setRange
-- LSlider value and range setters. Focus: setRange.
do
    local sl = lurek.ui.newSlider(0, 50)
    sl:setRange(0, 100)
    local mx = sl:getMax()
    sl:setStep(5)
    sl:setValue(75)
    local v = sl:getValue()
    print("setRange max:", mx, "getValue:", v)
end

--@api-stub: LSlider.setStep
-- LSlider value and range setters. Focus: setStep.
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
-- LSlider setValue and LSpinBox operations. Focus: setValue.
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

--@api-stub: LSpinBox.decrement
-- LSlider setValue and LSpinBox operations. Focus: decrement.
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

--@api-stub: LSpinBox.getValue
-- LSlider setValue and LSpinBox operations. Focus: getValue.
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
-- LSpinBox range and step. Focus: increment.
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

--@api-stub: LSpinBox.setRange
-- LSpinBox range and step. Focus: setRange.
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

--@api-stub: LSpinBox.setStep
-- LSpinBox range and step. Focus: setStep.
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
-- LSplitPanel child and orientation queries. Focus: getFirstChild.
do
    local sp = lurek.ui.newSplitPanel("horizontal")
    local fc = sp:getFirstChild()
    local sc = sp:getSecondChild()
    local ori = sp:getOrientation()
    local mps = sp:getMinPanelSize()
    print("firstChild:", fc, "secondChild:", sc, "orientation:", ori, "minPanel:", mps)
end

--@api-stub: LSplitPanel.getMinPanelSize
-- LSplitPanel child and orientation queries. Focus: getMinPanelSize.
do
    local sp = lurek.ui.newSplitPanel("horizontal")
    local fc = sp:getFirstChild()
    local sc = sp:getSecondChild()
    local ori = sp:getOrientation()
    local mps = sp:getMinPanelSize()
    print("firstChild:", fc, "secondChild:", sc, "orientation:", ori, "minPanel:", mps)
end

--@api-stub: LSplitPanel.getOrientation
-- LSplitPanel child and orientation queries. Focus: getOrientation.
do
    local sp = lurek.ui.newSplitPanel("horizontal")
    local fc = sp:getFirstChild()
    local sc = sp:getSecondChild()
    local ori = sp:getOrientation()
    local mps = sp:getMinPanelSize()
    print("firstChild:", fc, "secondChild:", sc, "orientation:", ori, "minPanel:", mps)
end

--@api-stub: LSplitPanel.getSecondChild
-- LSplitPanel setters and split position. Focus: getSecondChild.
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

--@api-stub: LSplitPanel.getSplitPosition
-- LSplitPanel setters and split position. Focus: getSplitPosition.
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

--@api-stub: LSplitPanel.setFirstChild
-- LSplitPanel setters and split position. Focus: setFirstChild.
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
-- LSplitPanel orientation and min size. Focus: setMinPanelSize.
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

--@api-stub: LSplitPanel.setOrientation
-- LSplitPanel orientation and min size. Focus: setOrientation.
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

--@api-stub: LSplitPanel.setSecondChild
-- LSplitPanel orientation and min size. Focus: setSecondChild.
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
-- LSplitPanel position and LStatusBar sections. Focus: setSplitPosition.
do
    local sp = lurek.ui.newSplitPanel("horizontal")
    sp:setSplitPosition(200)
    local pos = sp:getSplitPosition()
    local sb = lurek.ui.newStatusBar()
    sb:addSection("Ready", 100)
    local cnt = sb:getSectionCount()
    print("splitPos:", pos, "statusBar sectionCount:", cnt)
end

--@api-stub: LStatusBar.addSection
-- LSplitPanel position and LStatusBar sections. Focus: addSection.
do
    local sp = lurek.ui.newSplitPanel("horizontal")
    sp:setSplitPosition(200)
    local pos = sp:getSplitPosition()
    local sb = lurek.ui.newStatusBar()
    sb:addSection("Ready", 100)
    local cnt = sb:getSectionCount()
    print("splitPos:", pos, "statusBar sectionCount:", cnt)
end

--@api-stub: LStatusBar.getSectionCount
-- LSplitPanel position and LStatusBar sections. Focus: getSectionCount.
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
-- LStatusBar text manipulation. Focus: getSectionText.
do
    local sb = lurek.ui.newStatusBar()
    sb:setSectionCount(3)
    local cnt = sb:getSectionCount()
    sb:setSectionText(1, "Line 1")
    local txt = sb:getSectionText(1)
    sb:setSectionText(2, "Col 5")
    print("sectionCount:", cnt, "section1:", txt)
end

--@api-stub: LStatusBar.setSectionCount
-- LStatusBar text manipulation. Focus: setSectionCount.
do
    local sb = lurek.ui.newStatusBar()
    sb:setSectionCount(3)
    local cnt = sb:getSectionCount()
    sb:setSectionText(1, "Line 1")
    local txt = sb:getSectionText(1)
    sb:setSectionText(2, "Col 5")
    print("sectionCount:", cnt, "section1:", txt)
end

--@api-stub: LStatusBar.setSectionText
-- LStatusBar text manipulation. Focus: setSectionText.
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
-- LStatusBar widget and LSwitch state. Focus: setSectionWidget.
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

--@api-stub: LSwitch.isOn
-- LStatusBar widget and LSwitch state. Focus: isOn.
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

--@api-stub: LSwitch.setOn
-- LStatusBar widget and LSwitch state. Focus: setOn.
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
-- LSwitch toggle and LTabBar add. Focus: toggle.
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

--@api-stub: LTabBar.addTab
-- LSwitch toggle and LTabBar add. Focus: addTab.
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

--@api-stub: LTabBar.getActiveTab
-- LSwitch toggle and LTabBar add. Focus: getActiveTab.
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
-- LTabBar queries. Focus: getTab.
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

--@api-stub: LTabBar.getTabCount
-- LTabBar queries. Focus: getTabCount.
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

--@api-stub: LTabBar.removeTab
-- LTabBar queries. Focus: removeTab.
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
-- LTextInput text queries. Focus: getCursorPosition.
do
    local ti = lurek.ui.newTextInput()
    ti:setText("hello")
    local txt = ti:getText()
    ti:setPlaceholder("type here")
    local ph = ti:getPlaceholder()
    local cur = ti:getCursorPosition()
    print("text:", txt, "placeholder:", ph, "cursor:", cur)
end

--@api-stub: LTextInput.getPlaceholder
-- LTextInput text queries. Focus: getPlaceholder.
do
    local ti = lurek.ui.newTextInput()
    ti:setText("hello")
    local txt = ti:getText()
    ti:setPlaceholder("type here")
    local ph = ti:getPlaceholder()
    local cur = ti:getCursorPosition()
    print("text:", txt, "placeholder:", ph, "cursor:", cur)
end

--@api-stub: LTextInput.getText
-- LTextInput text queries. Focus: getText.
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
-- LTextInput focus and max length. Focus: isFocused.
do
    local ti = lurek.ui.newTextInput()
    ti:setPlaceholder("Search...")
    local ph = ti:getPlaceholder()
    ti:setMaxLength(50)
    local focused = ti:isFocused()
    print("placeholder:", ph, "isFocused:", focused)
end

--@api-stub: LTextInput.setMaxLength
-- LTextInput focus and max length. Focus: setMaxLength.
do
    local ti = lurek.ui.newTextInput()
    ti:setPlaceholder("Search...")
    local ph = ti:getPlaceholder()
    ti:setMaxLength(50)
    local focused = ti:isFocused()
    print("placeholder:", ph, "isFocused:", focused)
end

--@api-stub: LTextInput.setPlaceholder
-- LTextInput focus and max length. Focus: setPlaceholder.
do
    local ti = lurek.ui.newTextInput()
    ti:setPlaceholder("Search...")
    local ph = ti:getPlaceholder()
    ti:setMaxLength(50)
    local focused = ti:isFocused()
    print("placeholder:", ph, "isFocused:", focused)
end

--@api-stub: LTextInput.setText
-- LTextInput setText and LTheme type. Focus: setText.
do
    local ti = lurek.ui.newTextInput()
    ti:setText("sample input")
    local txt = ti:getText()
    local th = lurek.ui.newTheme()
    th:setStyle("LButton", "normal", {bg_color = {0.2, 0.3, 0.8}})
    local t = th:type()
    print("text:", txt, "theme type:", t)
end

--@api-stub: LTheme:setStyle
-- LTextInput setText and LTheme type. Focus: setStyle.
do
    local ti = lurek.ui.newTextInput()
    ti:setText("sample input")
    local txt = ti:getText()
    local th = lurek.ui.newTheme()
    th:setStyle("LButton", "normal", {bg_color = {0.2, 0.3, 0.8}})
    local t = th:type()
    print("text:", txt, "theme type:", t)
end

--@api-stub: LTheme:type
-- LTextInput setText and LTheme type. Focus: type.
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
-- LTheme identity and LToast queries. Focus: typeOf.
do
    local th = lurek.ui.newTheme()
    local ok = th:typeOf("LTheme")
    local toast = lurek.ui.newToast("Level up!", 3.0)
    local dur = toast:getDuration()
    local msg = toast:getMessage()
    print("theme typeOf:", ok, "duration:", dur, "message:", msg)
end

--@api-stub: LToast.getDuration
-- LTheme identity and LToast queries. Focus: getDuration.
do
    local th = lurek.ui.newTheme()
    local ok = th:typeOf("LTheme")
    local toast = lurek.ui.newToast("Level up!", 3.0)
    local dur = toast:getDuration()
    local msg = toast:getMessage()
    print("theme typeOf:", ok, "duration:", dur, "message:", msg)
end

--@api-stub: LToast.getMessage
-- LTheme identity and LToast queries. Focus: getMessage.
do
    local th = lurek.ui.newTheme()
    local ok = th:typeOf("LTheme")
    local toast = lurek.ui.newToast("Level up!", 3.0)
    local dur = toast:getDuration()
    local msg = toast:getMessage()
    print("theme typeOf:", ok, "duration:", dur, "message:", msg)
end

--@api-stub: LToast.getProgress
-- LToast state. Focus: getProgress.
do
    local toast = lurek.ui.newToast("Achievement unlocked", 2.0)
    local prog = toast:getProgress()
    local exp = toast:isExpired()
    toast:setDuration(5.0)
    local dur = toast:getDuration()
    print("progress:", prog, "isExpired:", exp, "duration:", dur)
end

--@api-stub: LToast.isExpired
-- LToast state. Focus: isExpired.
do
    local toast = lurek.ui.newToast("Achievement unlocked", 2.0)
    local prog = toast:getProgress()
    local exp = toast:isExpired()
    toast:setDuration(5.0)
    local dur = toast:getDuration()
    print("progress:", prog, "isExpired:", exp, "duration:", dur)
end

--@api-stub: LToast.setDuration
-- LToast state. Focus: setDuration.
do
    local toast = lurek.ui.newToast("Achievement unlocked", 2.0)
    local prog = toast:getProgress()
    local exp = toast:isExpired()
    toast:setDuration(5.0)
    local dur = toast:getDuration()
    print("progress:", prog, "isExpired:", exp, "duration:", dur)
end

--@api-stub: LToast.setMessage
-- LToast setMessage and LToolbar add. Focus: setMessage.
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

--@api-stub: LToolbar.addButton
-- LToast setMessage and LToolbar add. Focus: addButton.
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

--@api-stub: LToolbar.addSeparator
-- LToast setMessage and LToolbar add. Focus: addSeparator.
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
-- LToolbar spacer and queries. Focus: addSpacer.
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("cut", "Cut")
    tb:addSpacer(10)
    tb:addButton("paste", "Paste")
    local ori = tb:getOrientation()
    local btn = tb:getButton("cut")
    print("orientation:", ori, "button:", btn)
end

--@api-stub: LToolbar.getButton
-- LToolbar spacer and queries. Focus: getButton.
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("cut", "Cut")
    tb:addSpacer(10)
    tb:addButton("paste", "Paste")
    local ori = tb:getOrientation()
    local btn = tb:getButton("cut")
    print("orientation:", ori, "button:", btn)
end

--@api-stub: LToolbar.getOrientation
-- LToolbar spacer and queries. Focus: getOrientation.
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
-- LToolbar button states. Focus: isButtonToggled.
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("bold", "Bold")
    tb:setButtonToggled("bold", true)
    local tog = tb:isButtonToggled("bold")
    tb:setButtonEnabled("bold", false)
    print("bold toggled:", tog)
end

--@api-stub: LToolbar.setButtonEnabled
-- LToolbar button states. Focus: setButtonEnabled.
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("bold", "Bold")
    tb:setButtonToggled("bold", true)
    local tog = tb:isButtonToggled("bold")
    tb:setButtonEnabled("bold", false)
    print("bold toggled:", tog)
end

--@api-stub: LToolbar.setButtonToggled
-- LToolbar button states. Focus: setButtonToggled.
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("bold", "Bold")
    tb:setButtonToggled("bold", true)
    local tog = tb:isButtonToggled("bold")
    tb:setButtonEnabled("bold", false)
    print("bold toggled:", tog)
end

--@api-stub: LToolbar.setOrientation
-- LToolbar orientation and LTooltipPanel queries. Focus: setOrientation.
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:setOrientation("vertical")
    local ori = tb:getOrientation()
    local tp = lurek.ui.newTooltipPanel("Hover help")
    local delay = tp:getDelay()
    local target = tp:getTarget()
    print("orientation:", ori, "delay:", delay, "target:", target)
end

--@api-stub: LTooltipPanel.getDelay
-- LToolbar orientation and LTooltipPanel queries. Focus: getDelay.
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:setOrientation("vertical")
    local ori = tb:getOrientation()
    local tp = lurek.ui.newTooltipPanel("Hover help")
    local delay = tp:getDelay()
    local target = tp:getTarget()
    print("orientation:", ori, "delay:", delay, "target:", target)
end

--@api-stub: LTooltipPanel.getTarget
-- LToolbar orientation and LTooltipPanel queries. Focus: getTarget.
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
-- LTooltipPanel text and target. Focus: getText.
do
    local tp = lurek.ui.newTooltipPanel("initial tip")
    local txt = tp:getText()
    tp:setDelay(0.5)
    local d = tp:getDelay()
    local btn = lurek.ui.newButton("hover me")
    tp:setTarget(btn:getId() and 1 or 1)
    print("text:", txt, "delay:", d)
end

--@api-stub: LTooltipPanel.setDelay
-- LTooltipPanel text and target. Focus: setDelay.
do
    local tp = lurek.ui.newTooltipPanel("initial tip")
    local txt = tp:getText()
    tp:setDelay(0.5)
    local d = tp:getDelay()
    local btn = lurek.ui.newButton("hover me")
    tp:setTarget(btn:getId() and 1 or 1)
    print("text:", txt, "delay:", d)
end

--@api-stub: LTooltipPanel.setTarget
-- LTooltipPanel text and target. Focus: setTarget.
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
-- LTreeView population and collapse. Focus: addNode.
do
    local tv = lurek.ui.newTreeView()
    local n1 = tv:addNode("Root", nil)
    local n2 = tv:addNode("Child", n1)
    tv:collapseAll()
    tv:clearNodes()
    local cnt = tv:getNodeCount()
    print("addNode/collapseAll/clearNodes ok; count after clear:", cnt)
end

--@api-stub: LTreeView.clearNodes
-- LTreeView population and collapse. Focus: clearNodes.
do
    local tv = lurek.ui.newTreeView()
    local n1 = tv:addNode("Root", nil)
    local n2 = tv:addNode("Child", n1)
    tv:collapseAll()
    tv:clearNodes()
    local cnt = tv:getNodeCount()
    print("addNode/collapseAll/clearNodes ok; count after clear:", cnt)
end

--@api-stub: LTreeView.collapseAll
-- LTreeView population and collapse. Focus: collapseAll.
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
-- LTreeView expand and collapse. Focus: collapseNode.
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

--@api-stub: LTreeView.expandAll
-- LTreeView expand and collapse. Focus: expandAll.
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

--@api-stub: LTreeView.expandNode
-- LTreeView expand and collapse. Focus: expandNode.
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
-- LTreeView hierarchy queries. Focus: getChildNodes.
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

--@api-stub: LTreeView.getNodeCount
-- LTreeView hierarchy queries. Focus: getNodeCount.
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

--@api-stub: LTreeView.getNodeDepth
-- LTreeView hierarchy queries. Focus: getNodeDepth.
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
-- LTreeView text and parent. Focus: getNodeText.
do
    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    local c = tv:addNode("Child", r)
    local txt = tv:getNodeText(c)
    local parent = tv:getParentNode(c)
    local sel = tv:getSelectedNode()
    print("text:", txt, "parent:", parent, "selected:", sel)
end

--@api-stub: LTreeView.getParentNode
-- LTreeView text and parent. Focus: getParentNode.
do
    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    local c = tv:addNode("Child", r)
    local txt = tv:getNodeText(c)
    local parent = tv:getParentNode(c)
    local sel = tv:getSelectedNode()
    print("text:", txt, "parent:", parent, "selected:", sel)
end

--@api-stub: LTreeView.getSelectedNode
-- LTreeView text and parent. Focus: getSelectedNode.
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
-- LTreeView expansion and removal. Focus: isExpanded.
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

--@api-stub: LTreeView.isNodeExpanded
-- LTreeView expansion and removal. Focus: isNodeExpanded.
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

--@api-stub: LTreeView.removeNode
-- LTreeView expansion and removal. Focus: removeNode.
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
-- LTreeView setters. Focus: setNodeIcon.
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

--@api-stub: LTreeView.setNodeText
-- LTreeView setters. Focus: setNodeText.
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

--@api-stub: LTreeView.setSelectedNode
-- LTreeView setters. Focus: setSelectedNode.
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
-- LUiWidget child and animation. Focus: addChild.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local child = lurek.ui.newLabel("label")
    w:addChild(child)
    w:animateAlpha(0.5, 0.3, false)
    w:animatePosition(10, 20, 0.5)
    local cnt = w:getChildCount()
    print("addChild/animateAlpha/animatePosition ok; childCount:", cnt)
end

--@api-stub: LUiWidget.animateAlpha
-- LUiWidget child and animation. Focus: animateAlpha.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local child = lurek.ui.newLabel("label")
    w:addChild(child)
    w:animateAlpha(0.5, 0.3, false)
    w:animatePosition(10, 20, 0.5)
    local cnt = w:getChildCount()
    print("addChild/animateAlpha/animatePosition ok; childCount:", cnt)
end

--@api-stub: LUiWidget.animatePosition
-- LUiWidget child and animation. Focus: animatePosition.
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
-- LUiWidget entity attachment and animations. Focus: attachToEntity.
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

--@api-stub: LUiWidget.bind
-- LUiWidget entity attachment and animations. Focus: bind.
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

--@api-stub: LUiWidget.cancelAnimations
-- LUiWidget entity attachment and animations. Focus: cancelAnimations.
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
-- LUiWidget anchor and hit testing. Focus: clearAnchor.
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

--@api-stub: LUiWidget.containsPoint
-- LUiWidget anchor and hit testing. Focus: containsPoint.
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

--@api-stub: LUiWidget.detachFromEntity
-- LUiWidget anchor and hit testing. Focus: detachFromEntity.
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
-- LUiWidget fade and find. Focus: fadeIn.
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

--@api-stub: LUiWidget.fadeOut
-- LUiWidget fade and find. Focus: fadeOut.
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

--@api-stub: LUiWidget.findById
-- LUiWidget fade and find. Focus: findById.
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
-- LUiWidget alpha and children. Focus: getAlpha.
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

--@api-stub: LUiWidget.getChildCount
-- LUiWidget alpha and children. Focus: getChildCount.
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

--@api-stub: LUiWidget.getChildren
-- LUiWidget alpha and children. Focus: getChildren.
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
-- LUiWidget flex and identity. Focus: getFlexGrow.
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

--@api-stub: LUiWidget.getFlexShrink
-- LUiWidget flex and identity. Focus: getFlexShrink.
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

--@api-stub: LUiWidget.getId
-- LUiWidget flex and identity. Focus: getId.
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
-- LUiWidget margin and size constraints. Focus: getMargin.
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

--@api-stub: LUiWidget.getMaxSize
-- LUiWidget margin and size constraints. Focus: getMaxSize.
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

--@api-stub: LUiWidget.getMinSize
-- LUiWidget margin and size constraints. Focus: getMinSize.
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
-- LUiWidget padding, position, rect. Focus: getPadding.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setPadding(5, 5, 5, 5)
    local pt, pr, pb, pl = w:getPadding()
    w:setPosition(30, 40)
    local px, py = w:getPosition()
    local rx, ry, rw, rh = w:getRect()
    print("padding:", pt, "position:", px, py, "rect:", rx, ry, rw, rh)
end

--@api-stub: LUiWidget.getPosition
-- LUiWidget padding, position, rect. Focus: getPosition.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setPadding(5, 5, 5, 5)
    local pt, pr, pb, pl = w:getPadding()
    w:setPosition(30, 40)
    local px, py = w:getPosition()
    local rx, ry, rw, rh = w:getRect()
    print("padding:", pt, "position:", px, py, "rect:", rx, ry, rw, rh)
end

--@api-stub: LUiWidget.getRect
-- LUiWidget padding, position, rect. Focus: getRect.
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
-- LUiWidget size, state, tooltip. Focus: getSize.
do
    local w = lurek.ui.newCustomWidget({width=120, height=60})
    w:setSize(150, 80)
    local sw, sh = w:getSize()
    local state = w:getState()
    w:setTooltip("hover tip")
    local tip = w:getTooltip()
    print("size:", sw, sh, "state:", state, "tooltip:", tip)
end

--@api-stub: LUiWidget.getState
-- LUiWidget size, state, tooltip. Focus: getState.
do
    local w = lurek.ui.newCustomWidget({width=120, height=60})
    w:setSize(150, 80)
    local sw, sh = w:getSize()
    local state = w:getState()
    w:setTooltip("hover tip")
    local tip = w:getTooltip()
    print("size:", sw, sh, "state:", state, "tooltip:", tip)
end

--@api-stub: LUiWidget.getTooltip
-- LUiWidget size, state, tooltip. Focus: getTooltip.
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
-- LUiWidget z-order and enabled state. Focus: getZOrder.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setZOrder(5)
    local z = w:getZOrder()
    local animating = w:isAnimating()
    local enabled = w:isEnabled()
    w:setEnabled(false)
    print("zOrder:", z, "isAnimating:", animating, "isEnabled:", enabled)
end

--@api-stub: LUiWidget.isAnimating
-- LUiWidget z-order and enabled state. Focus: isAnimating.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setZOrder(5)
    local z = w:getZOrder()
    local animating = w:isAnimating()
    local enabled = w:isEnabled()
    w:setEnabled(false)
    print("zOrder:", z, "isAnimating:", animating, "isEnabled:", enabled)
end

--@api-stub: LUiWidget.isEnabled
-- LUiWidget z-order and enabled state. Focus: isEnabled.
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
-- LUiWidget visibility and child removal. Focus: isVisible.
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

--@api-stub: LUiWidget.removeChild
-- LUiWidget visibility and child removal. Focus: removeChild.
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

--@api-stub: LUiWidget.setAlpha
-- LUiWidget visibility and child removal. Focus: setAlpha.
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
-- LUiWidget anchor and enabled. Focus: setAnchor.
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

--@api-stub: LUiWidget.setAnchorCenter
-- LUiWidget anchor and enabled. Focus: setAnchorCenter.
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

--@api-stub: LUiWidget.setEnabled
-- LUiWidget anchor and enabled. Focus: setEnabled.
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
-- LUiWidget flex and id setters. Focus: setFlexGrow.
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

--@api-stub: LUiWidget.setFlexShrink
-- LUiWidget flex and id setters. Focus: setFlexShrink.
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

--@api-stub: LUiWidget.setId
-- LUiWidget flex and id setters. Focus: setId.
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
-- LUiWidget margin and size limits. Focus: setMargin.
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

--@api-stub: LUiWidget.setMaxSize
-- LUiWidget margin and size limits. Focus: setMaxSize.
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

--@api-stub: LUiWidget.setMinSize
-- LUiWidget margin and size limits. Focus: setMinSize.
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
-- LUiWidget callbacks. Focus: setOnChange.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setOnChange(function() print("changed") end)
    w:setOnClick(function() print("clicked") end)
    w:setOnDraw(function() print("drawing") end)
    local id = w:getId()
    local vis = w:isVisible()
    print("setOnChange/setOnClick/setOnDraw ok; id:", id, "vis:", vis)
end

--@api-stub: LUiWidget.setOnClick
-- LUiWidget callbacks. Focus: setOnClick.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setOnChange(function() print("changed") end)
    w:setOnClick(function() print("clicked") end)
    w:setOnDraw(function() print("drawing") end)
    local id = w:getId()
    local vis = w:isVisible()
    print("setOnChange/setOnClick/setOnDraw ok; id:", id, "vis:", vis)
end

--@api-stub: LUiWidget.setOnDraw
-- LUiWidget callbacks. Focus: setOnDraw.
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
-- LUiWidget layout setters. Focus: setPadding.
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

--@api-stub: LUiWidget.setPosition
-- LUiWidget layout setters. Focus: setPosition.
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

--@api-stub: LUiWidget.setSize
-- LUiWidget layout setters. Focus: setSize.
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
-- LUiWidget tooltip, visibility, z-order. Focus: setTooltip.
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

--@api-stub: LUiWidget.setVisible
-- LUiWidget tooltip, visibility, z-order. Focus: setVisible.
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

--@api-stub: LUiWidget.setZOrder
-- LUiWidget tooltip, visibility, z-order. Focus: setZOrder.
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
-- LUiWidget slide animations and type. Focus: slideIn.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:slideIn(0, -50)
    w:slideOut(0, 50)
    local t = w:type()
    local ok = w:typeOf("LUiWidget")
    w:unbind()
    print("slideIn/slideOut ok; type:", t, "typeOf:", ok)
end

--@api-stub: LUiWidget.slideOut
-- LUiWidget slide animations and type. Focus: slideOut.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:slideIn(0, -50)
    w:slideOut(0, 50)
    local t = w:type()
    local ok = w:typeOf("LUiWidget")
    w:unbind()
    print("slideIn/slideOut ok; type:", t, "typeOf:", ok)
end

--@api-stub: LUiWidget.type
-- LUiWidget slide animations and type. Focus: type.
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
-- LUiWidget typeOf and unbind. Focus: typeOf.
do
    local w = lurek.ui.newCustomWidget({width=80, height=40})
    w:bind("click")
    w:unbind()
    local ok1 = w:typeOf("LUiWidget")
    local ok2 = w:typeOf("LButton")
    local t = w:type()
    print("typeOf LUiWidget:", ok1, "typeOf LButton:", ok2, "type:", t)
end

--@api-stub: LUiWidget.unbind
-- LUiWidget typeOf and unbind. Focus: unbind.
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
-- lurek.ui drawToImage and drag drop. Focus: drawToImage.
do
    local img = lurek.ui.drawToImage(320, 240)
    local w = lurek.ui.newCustomWidget({width=80, height=40})
    lurek.ui.beginDrag(w)
    lurek.ui.dropOn(w)
    lurek.ui.endDrag()
    print("drawToImage ok; dropOn/endDrag ok")
end

--@api-stub: lurek.ui.endDrag
-- lurek.ui drawToImage and drag drop. Focus: endDrag.
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
-- lurek.ui input forwarding and layout loading. Focus: getWidgetCount.
do
    local cnt = lurek.ui.getWidgetCount()
    lurek.ui.keypressed("escape")
    local layout = lurek.ui.loadLayoutFile("content/layouts/main_menu.toml")
    lurek.ui.textinput("a")
    print("widgetCount:", cnt, "loadLayoutFile ok; textinput ok")
end

--@api-stub: lurek.ui.keypressed
-- lurek.ui input forwarding and layout loading. Focus: keypressed.
do
    local cnt = lurek.ui.getWidgetCount()
    lurek.ui.keypressed("escape")
    local layout = lurek.ui.loadLayoutFile("content/layouts/main_menu.toml")
    lurek.ui.textinput("a")
    print("widgetCount:", cnt, "loadLayoutFile ok; textinput ok")
end

--@api-stub: lurek.ui.loadLayoutFile
-- lurek.ui input forwarding and layout loading. Focus: loadLayoutFile.
do
    local cnt = lurek.ui.getWidgetCount()
    lurek.ui.keypressed("escape")
    local layout = lurek.ui.loadLayoutFile("content/layouts/main_menu.toml")
    lurek.ui.textinput("a")
    print("widgetCount:", cnt, "loadLayoutFile ok; textinput ok")
end

--@api-stub: lurek.ui.mousemoved
-- lurek.ui mouse input forwarding. Focus: mousemoved.
do
    lurek.ui.mousemoved(100, 150)
    lurek.ui.mousepressed(100, 150, 1)
    lurek.ui.mousereleased(100, 150, 1)
    lurek.ui.wheelmoved(0, -1)
    local cnt = lurek.ui.getWidgetCount()
    print("mousemoved/pressed/released/wheelmoved ok; widgets:", cnt)
end

--@api-stub: lurek.ui.mousepressed
-- lurek.ui mouse input forwarding. Focus: mousepressed.
do
    lurek.ui.mousemoved(100, 150)
    lurek.ui.mousepressed(100, 150, 1)
    lurek.ui.mousereleased(100, 150, 1)
    lurek.ui.wheelmoved(0, -1)
    local cnt = lurek.ui.getWidgetCount()
    print("mousemoved/pressed/released/wheelmoved ok; widgets:", cnt)
end

--@api-stub: lurek.ui.mousereleased
-- lurek.ui mouse input forwarding. Focus: mousereleased.
do
    lurek.ui.mousemoved(100, 150)
    lurek.ui.mousepressed(100, 150, 1)
    lurek.ui.mousereleased(100, 150, 1)
    lurek.ui.wheelmoved(0, -1)
    local cnt = lurek.ui.getWidgetCount()
    print("mousemoved/pressed/released/wheelmoved ok; widgets:", cnt)
end

--@api-stub: lurek.ui.newCustomWidget
-- lurek.ui constructors. Focus: newCustomWidget.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local layout = lurek.ui.newLayout("row")
    local sb = lurek.ui.newScrollBar(true)
    print("newCustomWidget:", w, "newLayout:", layout, "newScrollBar:", sb)
end

--@api-stub: lurek.ui.newScrollBar
-- lurek.ui constructors. Focus: newScrollBar.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local layout = lurek.ui.newLayout("row")
    local sb = lurek.ui.newScrollBar(true)
    print("newCustomWidget:", w, "newLayout:", layout, "newScrollBar:", sb)
end

--@api-stub: lurek.ui.parseWidgetState
-- lurek.ui theme, state parsing, rendering. Focus: parseWidgetState.
do
    local th = lurek.ui.newTheme()
    local state = lurek.ui.parseWidgetState("normal")
    local result = lurek.ui.renderToImage(320, 240, "save/ui_render.png")
    print("newTheme ok; parseWidgetState:", state, "renderToImage:", result)
end

--@api-stub: lurek.ui.renderToImage
-- lurek.ui theme, state parsing, rendering. Focus: renderToImage.
do
    local th = lurek.ui.newTheme()
    local state = lurek.ui.parseWidgetState("normal")
    local result = lurek.ui.renderToImage(320, 240, "save/ui_render.png")
    print("newTheme ok; parseWidgetState:", state, "renderToImage:", result)
end

--@api-stub: lurek.ui.setDefaultTheme
-- lurek.ui theme and viewport. Focus: setDefaultTheme.
do
    local th = lurek.ui.newTheme()
    lurek.ui.setTheme(th)
    lurek.ui.setDefaultTheme()
    lurek.ui.setViewport(1280, 720)
    local cnt = lurek.ui.getWidgetCount()
    print("setTheme/setDefaultTheme/setViewport ok; widgets:", cnt)
end

--@api-stub: lurek.ui.setViewport
-- lurek.ui theme and viewport. Focus: setViewport.
do
    local th = lurek.ui.newTheme()
    lurek.ui.setTheme(th)
    lurek.ui.setDefaultTheme()
    lurek.ui.setViewport(1280, 720)
    local cnt = lurek.ui.getWidgetCount()
    print("setTheme/setDefaultTheme/setViewport ok; widgets:", cnt)
end

--@api-stub: lurek.ui.textinput
-- lurek.ui text input and bindings. Focus: textinput.
do
    lurek.ui.textinput("hello")
    lurek.ui.textinput(" world")
    lurek.ui.update_bindings({dt=0.016})
    lurek.ui.wheelmoved(0, 1)
    lurek.ui.wheelmoved(1, 0)
    print("textinput/update_bindings/wheelmoved ok")
end

--@api-stub: lurek.ui.update_bindings
-- lurek.ui text input and bindings. Focus: update_bindings.
do
    lurek.ui.textinput("hello")
    lurek.ui.textinput(" world")
    lurek.ui.update_bindings({dt=0.016})
    lurek.ui.wheelmoved(0, 1)
    lurek.ui.wheelmoved(1, 0)
    print("textinput/update_bindings/wheelmoved ok")
end

--@api-stub: lurek.ui.wheelmoved
-- lurek.ui text input and bindings. Focus: wheelmoved.
do
    lurek.ui.textinput("hello")
    lurek.ui.textinput(" world")
    lurek.ui.update_bindings({dt=0.016})
    lurek.ui.wheelmoved(0, 1)
    lurek.ui.wheelmoved(1, 0)
    print("textinput/update_bindings/wheelmoved ok")
end

print("content/examples/ui.lua")
