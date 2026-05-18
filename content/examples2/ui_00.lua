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

--@api-stub: LUiWidget:setPosition / getPosition
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

--@api-stub: LUiWidget:setSize / getSize
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

--@api-stub: LUiWidget:isVisible / setVisible
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

--@api-stub: LUiWidget:isEnabled / setEnabled
-- Enabling and disabling widgets.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Action")
    print("enabled = " .. tostring(btn:isEnabled()))
    btn:setEnabled(false)
    print("disabled = " .. tostring(btn:isEnabled()))
    btn:setEnabled(true)
end

--@api-stub: LUiWidget:getAlpha / setAlpha
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

--@api-stub: LUiWidget:fadeIn / fadeOut
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

--@api-stub: LUiWidget:animatePosition / slideIn / slideOut
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

--@api-stub: LUiWidget:setId / getId / setTooltip / getTooltip
-- Widget identification and tooltips.
do
    ---@type LButton
    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    print("id = " .. btn:getId())
    print("tooltip = " .. btn:getTooltip())
end

--@api-stub: LUiWidget:setZOrder / getZOrder
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

--@api-stub: lurek.ui.getRoot / getWidgetCount
-- Root widget and global counts.
do
    local root = lurek.ui.getRoot()
    print("root = " .. tostring(root))
    print("widget count = " .. lurek.ui.getWidgetCount())
end

--@api-stub: lurek.ui.update / draw
-- UI update and render cycle.
do
    lurek.ui.update(1 / 60)
    lurek.ui.draw()
    print("UI frame processed")
end

print("ui_00.lua")
