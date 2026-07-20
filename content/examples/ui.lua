-- content/examples/ui.lua
-- Auto-generated from content/examples2/ui_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/ui.lua

--- UI Module Part 1: core widgets (button, label, panel) and base LUiWidget operations


--@api: lurek.ui.newButton
do

    ---@type LButton
    local btn = lurek.ui.newButton("Click Me")
    lurek.log.info(tostring("type = " .. btn:type()))
    lurek.log.info(tostring("text = " .. btn:getText()))
    lurek.log.info(tostring("button text = " .. btn:getText()))
    lurek.log.info(tostring("button width = " .. select(3, btn:getRect())))
end

--@api: lurek.ui.newStatPanel
do
    local panel = lurek.ui.newStatPanel({ speed = 10, armor = 3 })
    local children = panel:getChildCount()
    local kind = panel:type()
    local has_rows = children >= 2
    lurek.log.info("stat panel type=" .. tostring(kind) .. " rows=" .. tostring(children) .. " ok=" .. tostring(has_rows))
end

--@api: lurek.ui.newSlotGrid
do
    local grid = lurek.ui.newSlotGrid({ { name = "torso", part = "medium" }, "weapon" }, 2)
    local children = grid:getChildCount()
    local kind = grid:type()
    local has_slots = children >= 2
    lurek.log.info("slot grid type=" .. tostring(kind) .. " slots=" .. tostring(children) .. " ok=" .. tostring(has_slots))
end

--@api: lurek.ui.newComparisonBar
do
    local bar = lurek.ui.newComparisonBar("speed", 10, 12)
    local children = bar:getChildCount()
    local kind = bar:type()
    local improved = children >= 3
    lurek.log.info("comparison bar type=" .. tostring(kind) .. " children=" .. tostring(children) .. " ok=" .. tostring(improved))
end

--@api: LButton:setOnClick
do

    ---@type LButton
    local btn = lurek.ui.newButton("Submit")
    btn:setOnClick(function()
        lurek.log.info(tostring("button clicked!"))
    end)
    btn:setId("submit_btn")
    lurek.log.info(tostring("button id = " .. btn:getId()))
end

--@api: lurek.ui.newLabel
do

    local lbl = lurek.ui.newLabel("Hello, World!")
    lurek.log.info(tostring("type = " .. lbl:type()))
    lurek.log.info(tostring("text = " .. lbl:getText()))
    lbl:setText("Score: 100")
    lurek.log.info(tostring("updated text = " .. lbl:getText()))
end

--@api: lurek.ui.newRichLabel
do

    local rich = lurek.ui.newRichLabel("[b]Warning[/b]")
    local text = rich:getText()
    local plain = rich:getPlainText()
    rich:setText("[color=yellow]Ready[/color]")
    lurek.log.info(tostring("rich text = " .. text))
    lurek.log.info(tostring("plain text = " .. plain))
end

--@api: LRichLabel:setText
do

    local rich = lurek.ui.newRichLabel("Initial")
    rich:setText("[b]Updated[/b]")
    local text = rich:getText()
    local plain = rich:getPlainText()
    lurek.log.info(tostring("rich text = " .. text))
    lurek.log.info(tostring("plain text = " .. plain))
end

--@api: LRichLabel:getText
do

    local rich = lurek.ui.newRichLabel("[b]Status[/b]")
    local text = rich:getText()
    rich:setText("[color=green]Online[/color]")
    lurek.log.info(tostring("rich text = " .. text))
    lurek.log.info(tostring("new plain = " .. rich:getPlainText()))
end

--@api: LRichLabel:getPlainText
do

    local rich = lurek.ui.newRichLabel("[b]Alert[/b]")
    local plain = rich:getPlainText()
    rich:setText("[color=red]Alert[/color]")
    lurek.log.info(tostring("plain text = " .. plain))
    lurek.log.info(tostring("updated text = " .. rich:getText()))
end

--@api: lurek.ui.newPanel
do

    ---@type LPanel
    local panel = lurek.ui.newPanel()
    lurek.log.info(tostring("type = " .. panel:type()))
    lurek.log.info(tostring("child count = " .. panel:getChildCount()))
    lurek.log.info(tostring("visible = " .. tostring(panel:isVisible())))
    lurek.log.info(tostring("panel children = " .. panel:getChildCount()))
end

--@api: lurek.ui.newAspectRatioContainer
do

    local container = lurek.ui.newAspectRatioContainer()
    container:setRatio(16 / 9)
    container:setFit("contain")
    local ratio = container:getRatio()
    lurek.log.info(tostring("aspect type = " .. container:type()))
    lurek.log.info(tostring("aspect ratio = " .. ratio))
end

--@api: LAspectRatioContainer:setRatio
do

    local container = lurek.ui.newAspectRatioContainer()
    container:setRatio(4 / 3)
    container:setFit("cover")
    local ratio = container:getRatio()
    lurek.log.info(tostring("aspect ratio = " .. ratio))
    lurek.log.info(tostring("aspect fit = " .. container:getFit()))
end

--@api: LAspectRatioContainer:getRatio
do

    local container = lurek.ui.newAspectRatioContainer()
    container:setRatio(1.5)
    local ratio = container:getRatio()
    container:setFit("stretch")
    lurek.log.info(tostring("aspect ratio = " .. ratio))
    lurek.log.info(tostring("aspect fit = " .. container:getFit()))
end

--@api: LAspectRatioContainer:setFit
do

    local container = lurek.ui.newAspectRatioContainer()
    container:setFit("cover")
    container:setRatio(2.0)
    local fit = container:getFit()
    lurek.log.info(tostring("aspect fit = " .. fit))
    lurek.log.info(tostring("aspect ratio = " .. container:getRatio()))
end

--@api: LAspectRatioContainer:getFit
do

    local container = lurek.ui.newAspectRatioContainer()
    container:setFit("contain")
    local fit = container:getFit()
    container:setRatio(1.0)
    lurek.log.info(tostring("aspect fit = " .. fit))
    lurek.log.info(tostring("aspect ratio = " .. container:getRatio()))
end

--@api: LUiWidget:setPosition
do

    ---@type LButton
    local btn = lurek.ui.newButton("Pos Test")
    btn:setPosition(100, 50)
    local x, y = btn:getPosition()
    lurek.log.info(tostring("position = " .. x .. ", " .. y))
    lurek.log.info(tostring("button text = " .. btn:getText()))
end

--@api: LUiWidget:getPosition
do

    ---@type LButton
    local btn = lurek.ui.newButton("Pos Test")
    btn:setPosition(100, 50)
    local x, y = btn:getPosition()
    lurek.log.info(tostring("position = " .. x .. ", " .. y))
    lurek.log.info(tostring("button text = " .. btn:getText()))
end

--@api: LUiWidget:setSize
do

    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setSize(300, 200)
    local w, h = panel:getSize()
    lurek.log.info(tostring("size = " .. w .. "x" .. h))
    lurek.log.info(tostring("panel children = " .. panel:getChildCount()))
end

--@api: LUiWidget:getSize
do

    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setSize(300, 200)
    local w, h = panel:getSize()
    lurek.log.info(tostring("size = " .. w .. "x" .. h))
    lurek.log.info(tostring("panel children = " .. panel:getChildCount()))
end

--@api: LUiWidget:getRect
do

    local btn = lurek.ui.newButton("Bounds")
    btn:setPosition(50, 30)
    btn:setSize(120, 40)
    local x, y, w, h = btn:getRect()
    lurek.log.info(tostring("rect = " .. x .. "," .. y .. " " .. w .. "x" .. h))
end

--@api: LUiWidget:isVisible
do

    ---@type LLabel
    local lbl = lurek.ui.newLabel("Toggle Me")
    lurek.log.info(tostring("visible = " .. tostring(lbl:isVisible())))
    lbl:setVisible(false)
    lurek.log.info(tostring("hidden = " .. tostring(lbl:isVisible())))
    lurek.log.info(tostring("label text = " .. lbl:getText()))
end

--@api: LUiWidget:setVisible
do

    ---@type LLabel
    local lbl = lurek.ui.newLabel("Toggle Me")
    lbl:setVisible(false)
    lurek.log.info(tostring("hidden = " .. tostring(lbl:isVisible())))
    lurek.log.info(tostring("label text = " .. lbl:getText()))
    lurek.log.info(tostring("label width = " .. select(3, lbl:getRect())))
end

--@api: LUiWidget:isEnabled
do

    ---@type LButton
    local btn = lurek.ui.newButton("Action")
    lurek.log.info(tostring("enabled = " .. tostring(btn:isEnabled())))
    btn:setEnabled(false)
    lurek.log.info(tostring("disabled = " .. tostring(btn:isEnabled())))
    lurek.log.info(tostring("button text = " .. btn:getText()))
end

--@api: LUiWidget:setEnabled
do

    ---@type LButton
    local btn = lurek.ui.newButton("Action")
    btn:setEnabled(false)
    lurek.log.info(tostring("disabled = " .. tostring(btn:isEnabled())))
    lurek.log.info(tostring("button text = " .. btn:getText()))
    lurek.log.info(tostring("button width = " .. select(3, btn:getRect())))
end

--@api: LUiWidget:getAlpha
do

    local panel = lurek.ui.newPanel()
    lurek.log.info(tostring("alpha = " .. panel:getAlpha()))
    panel:setAlpha(0.5)
    lurek.log.info(tostring("set to 50% = " .. panel:getAlpha()))
    panel:setAlpha(1.0)
end

--@api: LUiWidget:setAlpha
do

    local panel = lurek.ui.newPanel()
    lurek.log.info(tostring("alpha = " .. panel:getAlpha()))
    panel:setAlpha(0.5)
    lurek.log.info(tostring("set to 50% = " .. panel:getAlpha()))
    panel:setAlpha(1.0)
end

--@api: LUiWidget:animateAlpha
do

    local btn = lurek.ui.newButton("Fade")
    btn:setAlpha(1.0)
    btn:animateAlpha(0.0, 0.5)
    lurek.log.info(tostring("animating = " .. tostring(btn:isAnimating())))
    btn:cancelAnimations()
    btn:animateAlpha(0.0, 0.3, true)
    lurek.log.info(tostring("fade-out with hide_on_complete started"))
end

--@api: LUiWidget:fadeIn
do

    ---@type LLabel
    local lbl = lurek.ui.newLabel("Fading")
    lbl:setAlpha(0)
    lbl:fadeIn()
    lurek.log.info(tostring("fading in, animating = " .. tostring(lbl:isAnimating())))
    lurek.log.info(tostring("label text = " .. lbl:getText()))
end

--@api: LUiWidget:fadeOut
do

    ---@type LLabel
    local lbl = lurek.ui.newLabel("Fading")
    lbl:fadeOut()
    lurek.log.info(tostring("fading out"))
    lurek.log.info(tostring("label text = " .. lbl:getText()))
    lurek.log.info(tostring("label width = " .. select(3, lbl:getRect())))
end

--@api: LUiWidget:animatePosition
do

    local panel = lurek.ui.newPanel()
    panel:setPosition(0, 0)
    panel:animatePosition(200, 100, 0.5)
    lurek.log.info(tostring("animating = " .. tostring(panel:isAnimating())))
    lurek.log.info(tostring("target = 200, 100"))
end

--@api: LUiWidget:slideIn
do

    local panel = lurek.ui.newPanel()
    panel:cancelAnimations()
    panel:slideIn(300, 0)
    local x, y = panel:getPosition()
    lurek.log.info(tostring("visible = " .. tostring(panel:isVisible())))
    lurek.log.info(tostring("position = " .. x .. ", " .. y))
end

--@api: LUiWidget:slideOut
do

    local panel = lurek.ui.newPanel()
    panel:setVisible(true)
    panel:setPosition(40, 20)
    panel:slideOut(320, 20)
    local x, y = panel:getPosition()
    lurek.log.info(tostring("visible = " .. tostring(panel:isVisible())))
    lurek.log.info(tostring("position = " .. x .. ", " .. y))
end

--@api: LUiWidget:setId
do

    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    lurek.log.info(tostring("id = " .. btn:getId()))
    lurek.log.info(tostring("tooltip = " .. btn:getTooltip()))
end

--@api: LUiWidget:getId
do

    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    lurek.log.info(tostring("id = " .. btn:getId()))
    lurek.log.info(tostring("tooltip = " .. btn:getTooltip()))
end

--@api: LUiWidget:setTooltip
do

    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    lurek.log.info(tostring("id = " .. btn:getId()))
    lurek.log.info(tostring("tooltip = " .. btn:getTooltip()))
end

--@api: LUiWidget:getTooltip
do

    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    lurek.log.info(tostring("id = " .. btn:getId()))
    lurek.log.info(tostring("tooltip = " .. btn:getTooltip()))
end

--@api: LUiWidget:setZOrder
do

    local front = lurek.ui.newPanel()
    local back = lurek.ui.newPanel()
    front:setZOrder(10)
    back:setZOrder(1)
    lurek.log.info(tostring("front z = " .. front:getZOrder()))
    lurek.log.info(tostring("back z = " .. back:getZOrder()))
end

--@api: LUiWidget:getZOrder
do

    local front = lurek.ui.newPanel()
    local back = lurek.ui.newPanel()
    front:setZOrder(10)
    back:setZOrder(1)
    lurek.log.info(tostring("front z = " .. front:getZOrder()))
    lurek.log.info(tostring("back z = " .. back:getZOrder()))
end

--@api: LUiWidget:containsPoint
do

    local btn = lurek.ui.newButton("Hit Test")
    btn:setPosition(50, 50)
    btn:setSize(100, 40)
    lurek.log.info(tostring("(75,60) inside = " .. tostring(btn:containsPoint(75, 60))))
    lurek.log.info(tostring("(200,200) inside = " .. tostring(btn:containsPoint(200, 200))))
end

--@api: LUiWidget:getState
do

    ---@type LButton
    local btn = lurek.ui.newButton("State")
    local state = btn:getState()
    lurek.log.info(tostring("state = " .. state))
    lurek.log.info(tostring("button text = " .. btn:getText()))
    lurek.log.info(tostring("button width = " .. select(3, btn:getRect())))
end

--@api: lurek.ui.getRoot
do

    local root = lurek.ui.getRoot()
    lurek.log.info(tostring("root = " .. tostring(root)))
    lurek.log.info(tostring("widget count = " .. lurek.ui.getWidgetCount()))
    lurek.log.info(tostring("root widgets = " .. lurek.ui.getWidgetCount()))
    lurek.log.info(tostring("focus exists = " .. tostring(lurek.ui.getFocus() ~= nil)))
end

--@api: lurek.ui.update
do

    local before = lurek.ui.getWidgetCount()
    lurek.ui.update(1 / 60)
    lurek.ui.draw()
    local after = lurek.ui.getWidgetCount()
    lurek.log.info(tostring("UI frame processed"))
    lurek.log.info(tostring("widgets before=" .. before .. " after=" .. after))
end

--- UI Module Part 2: layout, containers (DockPanel, SplitPanel, ScrollPanel), flex, margin, padding

--@api: lurek.ui.newLayout
do

    local row = lurek.ui.newLayout("horizontal")
    lurek.log.info(tostring("type = " .. row:type()))
    lurek.log.info(tostring("direction = " .. row:getDirection()))
    lurek.log.info(tostring("spacing = " .. row:getSpacing()))

    local col = lurek.ui.newLayout("vertical")
    col:setSpacing(10)
    lurek.log.info(tostring("direction = " .. col:getDirection()))
    lurek.log.info(tostring("spacing = " .. col:getSpacing()))
end

--@api: lurek.ui.newVBoxContainer
do

    local menu = lurek.ui.newVBoxContainer()
    menu:setSpacing(8)
    menu:addChild(lurek.ui.newButton("Start"))
    menu:addChild(lurek.ui.newButton("Options"))
    lurek.log.info(tostring("vbox children = " .. menu:getChildCount()))
end

--@api: lurek.ui.newHBoxContainer
do

    local hud = lurek.ui.newHBoxContainer()
    hud:setSpacing(6)
    hud:addChild(lurek.ui.newLabel("HP"))
    hud:addChild(lurek.ui.newProgressBar(0, 100))
    lurek.log.info(tostring("hbox direction = " .. hud:getDirection()))
end

--@api: lurek.ui.newGridContainer
do

    local inventory = lurek.ui.newGridContainer(3)
    inventory:setSpacing(4)
    inventory:addChild(lurek.ui.newButton("Slot 1"))
    inventory:addChild(lurek.ui.newButton("Slot 2"))
    lurek.log.info(tostring("grid direction = " .. inventory:getDirection()))
end

--@api: lurek.ui.newMarginContainer
do

    local safe_hud = lurek.ui.newMarginContainer(12, 16)
    local label = lurek.ui.newLabel("Quest updated")
    safe_hud:addChild(label)
    local top, right = safe_hud:getPadding()
    lurek.log.info(tostring("margin padding = " .. top .. "," .. right))
end

--@api: lurek.ui.newCenterContainer
do

    local modal_host = lurek.ui.newCenterContainer()
    modal_host:addChild(lurek.ui.newPanel())
    lurek.log.info(tostring("center align = " .. modal_host:getAlign()))
    lurek.log.info(tostring("center justify = " .. modal_host:getJustify()))
    lurek.log.info(tostring("center children = " .. modal_host:getChildCount()))
end

--@api: LLayout:setDirection
do

    ---@type LLayout
    local grid = lurek.ui.newLayout("grid")
    grid:setDirection("vertical")
    grid:setColumns(3)
    grid:setSpacing(5)
    lurek.log.info(tostring("direction = " .. grid:getDirection()))
end

--@api: LLayout:setColumns
do

    ---@type LLayout
    local grid = lurek.ui.newLayout("grid")
    grid:setColumns(3)
    grid:setSpacing(5)
    lurek.log.info(tostring("direction = " .. grid:getDirection()))
    lurek.log.info(tostring("layout direction = " .. grid:getDirection()))
end

--@api: LLayout:setAlign
do

    local layout = lurek.ui.newLayout("horizontal")
    layout:setAlign("center")
    lurek.log.info(tostring("align = " .. layout:getAlign()))
    layout:setAlign("stretch")
    lurek.log.info(tostring("align = " .. layout:getAlign()))
end

--@api: LLayout:getAlign
do

    local layout = lurek.ui.newLayout("horizontal")
    layout:setAlign("center")
    lurek.log.info(tostring("align = " .. layout:getAlign()))
    layout:setAlign("stretch")
    lurek.log.info(tostring("align = " .. layout:getAlign()))
end

--@api: LLayout:setJustify
do

    local layout = lurek.ui.newLayout("horizontal")
    layout:setJustify("space-between")
    lurek.log.info(tostring("justify = " .. layout:getJustify()))
    layout:setJustify("center")
    lurek.log.info(tostring("justify = " .. layout:getJustify()))
end

--@api: LLayout:getJustify
do

    local layout = lurek.ui.newLayout("horizontal")
    layout:setJustify("space-between")
    lurek.log.info(tostring("justify = " .. layout:getJustify()))
    layout:setJustify("center")
    lurek.log.info(tostring("justify = " .. layout:getJustify()))
end

--@api: LLayout:setWrap
do

    ---@type LLayout
    local layout = lurek.ui.newLayout("horizontal")
    lurek.log.info(tostring("wrap = " .. tostring(layout:getWrap())))
    layout:setWrap(true)
    lurek.log.info(tostring("wrap enabled = " .. tostring(layout:getWrap())))
    lurek.log.info(tostring("layout direction = " .. layout:getDirection()))
end

--@api: LLayout:getWrap
do

    ---@type LLayout
    local layout = lurek.ui.newLayout("horizontal")
    lurek.log.info(tostring("wrap = " .. tostring(layout:getWrap())))
    layout:setWrap(true)
    lurek.log.info(tostring("wrap enabled = " .. tostring(layout:getWrap())))
    lurek.log.info(tostring("layout direction = " .. layout:getDirection()))
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
    lurek.log.info(tostring("children = " .. layout:getChildCount()))
    layout:removeChild(btn2)
    lurek.log.info(tostring("after remove = " .. layout:getChildCount()))
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
    lurek.log.info(tostring("children = " .. layout:getChildCount()))
    layout:removeChild(btn2)
    lurek.log.info(tostring("after remove = " .. layout:getChildCount()))
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
    lurek.log.info(tostring("children = " .. layout:getChildCount()))
    layout:removeChild(btn2)
    lurek.log.info(tostring("after remove = " .. layout:getChildCount()))
end

--@api: LUiWidget:getChildren
do

    local panel = lurek.ui.newPanel()
    panel:addChild(lurek.ui.newLabel("A"))
    panel:addChild(lurek.ui.newLabel("B"))
    panel:addChild(lurek.ui.newLabel("C"))
    local children = panel:getChildren()
    lurek.log.info(tostring("child list length = " .. #children))
end

--@api: LUiWidget:setMargin
do

    local btn = lurek.ui.newButton("Margin")
    btn:setMargin(10, 20, 10, 20)
    local top, right, bottom, left = btn:getMargin()
    lurek.log.info(tostring("margin = " .. top .. " " .. right .. " " .. bottom .. " " .. left))
    btn:setMargin(5)
    top, right, bottom, left = btn:getMargin()
    lurek.log.info(tostring("uniform = " .. top .. " " .. right .. " " .. bottom .. " " .. left))
end

--@api: LUiWidget:getMargin
do

    local btn = lurek.ui.newButton("Margin")
    btn:setMargin(10, 20, 10, 20)
    local top, right, bottom, left = btn:getMargin()
    lurek.log.info(tostring("margin = " .. top .. " " .. right .. " " .. bottom .. " " .. left))
    btn:setMargin(5)
    top, right, bottom, left = btn:getMargin()
    lurek.log.info(tostring("uniform = " .. top .. " " .. right .. " " .. bottom .. " " .. left))
end

--@api: LUiWidget:setPadding
do

    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setPadding(8, 16, 8, 16)
    local top, right, bottom, left = panel:getPadding()
    lurek.log.info(tostring("padding = " .. top .. " " .. right .. " " .. bottom .. " " .. left))
    lurek.log.info(tostring("panel children = " .. panel:getChildCount()))
end

--@api: LUiWidget:getPadding
do

    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setPadding(8, 16, 8, 16)
    local top, right, bottom, left = panel:getPadding()
    lurek.log.info(tostring("padding = " .. top .. " " .. right .. " " .. bottom .. " " .. left))
    lurek.log.info(tostring("panel children = " .. panel:getChildCount()))
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
    lurek.log.info(tostring("left grow = " .. left:getFlexGrow()))
    lurek.log.info(tostring("right grow = " .. right:getFlexGrow()))
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
    lurek.log.info(tostring("left grow = " .. left:getFlexGrow()))
    lurek.log.info(tostring("right grow = " .. right:getFlexGrow()))
end

--@api: LUiWidget:setFlexShrink
do

    local btn = lurek.ui.newButton("Shrinkable")
    btn:setFlexShrink(0)
    lurek.log.info(tostring("shrink = " .. btn:getFlexShrink()))
    btn:setFlexShrink(1)
    lurek.log.info(tostring("shrink = " .. btn:getFlexShrink()))
end

--@api: LUiWidget:getFlexShrink
do

    local btn = lurek.ui.newButton("Shrinkable")
    btn:setFlexShrink(0)
    lurek.log.info(tostring("shrink = " .. btn:getFlexShrink()))
    btn:setFlexShrink(1)
    lurek.log.info(tostring("shrink = " .. btn:getFlexShrink()))
end

--@api: LUiWidget:setMinSize
do

    local panel = lurek.ui.newPanel()
    panel:setMinSize(100, 50)
    local minW, minH = panel:getMinSize()
    lurek.log.info(tostring("min = " .. minW .. "x" .. minH))
    panel:setMaxSize(400, 300)
    local maxW, maxH = panel:getMaxSize()
    lurek.log.info(tostring("max = " .. maxW .. "x" .. maxH))
end

--@api: LUiWidget:getMinSize
do

    local panel = lurek.ui.newPanel()
    panel:setMinSize(100, 50)
    local minW, minH = panel:getMinSize()
    lurek.log.info(tostring("min = " .. minW .. "x" .. minH))
    panel:setMaxSize(400, 300)
    local maxW, maxH = panel:getMaxSize()
    lurek.log.info(tostring("max = " .. maxW .. "x" .. maxH))
end

--@api: LUiWidget:setMaxSize
do

    local panel = lurek.ui.newPanel()
    panel:setMinSize(100, 50)
    local minW, minH = panel:getMinSize()
    lurek.log.info(tostring("min = " .. minW .. "x" .. minH))
    panel:setMaxSize(400, 300)
    local maxW, maxH = panel:getMaxSize()
    lurek.log.info(tostring("max = " .. maxW .. "x" .. maxH))
end

--@api: LUiWidget:getMaxSize
do

    local panel = lurek.ui.newPanel()
    panel:setMinSize(100, 50)
    local minW, minH = panel:getMinSize()
    lurek.log.info(tostring("min = " .. minW .. "x" .. minH))
    panel:setMaxSize(400, 300)
    local maxW, maxH = panel:getMaxSize()
    lurek.log.info(tostring("max = " .. maxW .. "x" .. maxH))
end

--@api: LUiWidget:setAnchor
do

    local btn = lurek.ui.newButton("Anchored")
    btn:setAnchor(10, 10, 10, nil)
    lurek.log.info(tostring("anchors applied"))
    btn:clearAnchor()
    btn:setAnchorCenter(0.5, 0.5)
    lurek.log.info(tostring("center anchor applied"))
end

--@api: LUiWidget:setAnchorCenter
do

    local btn = lurek.ui.newButton("Anchored")
    btn:setAnchor(10, 10, 10, nil)
    lurek.log.info(tostring("anchors applied"))
    btn:clearAnchor()
    btn:setAnchorCenter(0.5, 0.5)
    lurek.log.info(tostring("center anchor applied"))
end

--@api: LUiWidget:clearAnchor
do

    local btn = lurek.ui.newButton("Anchored")
    btn:setAnchor(10, 10, 10, nil)
    lurek.log.info(tostring("anchors applied"))
    btn:clearAnchor()
    btn:setAnchorCenter(0.5, 0.5)
    lurek.log.info(tostring("center anchor applied"))
end

--@api: lurek.ui.newDockPanel
do

    local dock = lurek.ui.newDockPanel()
    local header = lurek.ui.newPanel()
    local sidebar = lurek.ui.newPanel()
    lurek.log.info(tostring("type = " .. dock:type()))
    header:setSize(0, 60)
    sidebar:setSize(200, 0)
    dock:addChild(header)
    dock:addChild(sidebar)
    dock:dock(header, "top")
    dock:dock(sidebar, "left")
    dock:setSplitSize("left", 200)
    dock:setSplitSize("top", 60)
    lurek.log.info(tostring("docked count = " .. dock:getDockedCount()))
    lurek.log.info(tostring("left size = " .. dock:getSplitSize("left")))
end

--@api: LDockPanel:undock
do

    local dock = lurek.ui.newDockPanel()
    local footer = lurek.ui.newPanel()
    dock:addChild(footer)
    dock:dock(footer, "bottom")
    lurek.log.info(tostring("docked = " .. dock:getDockedCount()))
    dock:undock(footer)
    lurek.log.info(tostring("after undock = " .. dock:getDockedCount()))
end

--@api: lurek.ui.newSplitPanel
do

    local split = lurek.ui.newSplitPanel("horizontal")
    local left = lurek.ui.newPanel()
    local right = lurek.ui.newPanel()
    lurek.log.info(tostring("type = " .. split:type()))
    lurek.log.info(tostring("orientation = " .. split:getOrientation()))
    split:setFirstChild(left)
    split:setSecondChild(right)
    split:setSplitPosition(0.3)
    split:setMinPanelSize(100)
    lurek.log.info(tostring("split at " .. split:getSplitPosition()))
    lurek.log.info(tostring("min panel = " .. split:getMinPanelSize()))
end

--@api: lurek.ui.newSplitContainer
do

    local split = lurek.ui.newSplitContainer("vertical")
    local top = lurek.ui.newPanel()
    local bottom = lurek.ui.newPanel()
    split:setFirstChild(top)
    split:setSecondChild(bottom)
    lurek.log.info(tostring("split container = " .. split:getOrientation()))
end

--@api: lurek.ui.newScrollPanel
do

    local scroll = lurek.ui.newScrollPanel()
    lurek.log.info(tostring("type = " .. scroll:type()))
    scroll:setContentSize(1200, 2000)
    local cw, ch = scroll:getContentSize()
    lurek.log.info(tostring("content size = " .. cw .. "x" .. ch))
    scroll:setScrollPosition(0, 100)
    local sx, sy = scroll:getScrollPosition()
    lurek.log.info(tostring("scroll pos = " .. sx .. ", " .. sy))
    local mx, my = scroll:getMaxScroll()
    lurek.log.info(tostring("max scroll = " .. mx .. ", " .. my))
end

--@api: lurek.ui.newScrollContainer
do

    local scroll = lurek.ui.newScrollContainer()
    scroll:setContentSize(640, 960)
    scroll:setScrollPosition(0, 32)
    local sx, sy = scroll:getScrollPosition()
    lurek.log.info(tostring("scroll container pos = " .. sx .. ", " .. sy))
end

--@api: lurek.ui.newStackContainer
do

    local stack = lurek.ui.newStackContainer()
    stack:addChild(lurek.ui.newPanel())
    stack:addChild(lurek.ui.newPanel())
    stack:setActiveIndex(2)
    lurek.log.info(tostring("stack active = " .. stack:getActiveIndex()))
end

--@api: LStackContainer:setActiveIndex
do

    local stack = lurek.ui.newStackContainer()
    stack:addChild(lurek.ui.newPanel())
    stack:addChild(lurek.ui.newPanel())
    local changed = stack:setActiveIndex(2)
    lurek.log.info(tostring("active changed = " .. tostring(changed)))
end

--@api: LStackContainer:getActiveIndex
do

    local stack = lurek.ui.newStackContainer()
    stack:addChild(lurek.ui.newPanel())
    stack:setActiveIndex(1)
    lurek.log.info(tostring("active index = " .. stack:getActiveIndex()))
    lurek.log.info(tostring("stack children = " .. stack:getChildCount()))
end

--@api: LStackContainer:getActiveChild
do

    local stack = lurek.ui.newStackContainer()
    local page = lurek.ui.newPanel()
    stack:addChild(page)
    lurek.log.info(tostring("active child = " .. tostring(stack:getActiveChild())))
    lurek.log.info(tostring("active index = " .. stack:getActiveIndex()))
end

--@api: LStackContainer:addTab
do

    local stack = lurek.ui.newStackContainer()
    stack:addTab("Inventory")
    stack:addTab("Map")
    lurek.log.info(tostring("stack labels = " .. stack:getTabCount()))
    lurek.log.info(tostring("first label = " .. tostring(stack:getTab(1))))
end

--@api: LStackContainer:getTab
do

    local stack = lurek.ui.newStackContainer()
    stack:addTab("Journal")
    local label = stack:getTab(1)
    lurek.log.info(tostring("stack label = " .. tostring(label)))
    lurek.log.info(tostring("stack labels = " .. stack:getTabCount()))
end

--@api: LStackContainer:getTabCount
do

    local stack = lurek.ui.newStackContainer()
    stack:addTab("Stats")
    stack:addTab("Equipment")
    lurek.log.info(tostring("stack label count = " .. stack:getTabCount()))
    lurek.log.info(tostring("first label = " .. tostring(stack:getTab(1))))
end

--@api: lurek.ui.newTabContainer
do

    local tabs = lurek.ui.newTabContainer()
    tabs:addTab("Video")
    tabs:addChild(lurek.ui.newPanel())
    lurek.log.info(tostring("tab container count = " .. tabs:getTabCount()))
    lurek.log.info(tostring("active tab = " .. tabs:getActiveIndex()))
end

--@api: LTabContainer:setActiveIndex
do

    local tabs = lurek.ui.newTabContainer()
    tabs:addChild(lurek.ui.newPanel())
    tabs:addChild(lurek.ui.newPanel())
    local changed = tabs:setActiveIndex(2)
    lurek.log.info(tostring("tab active changed = " .. tostring(changed)))
end

--@api: LTabContainer:getActiveIndex
do

    local tabs = lurek.ui.newTabContainer()
    tabs:addChild(lurek.ui.newPanel())
    tabs:setActiveIndex(1)
    lurek.log.info(tostring("tab active index = " .. tabs:getActiveIndex()))
    lurek.log.info(tostring("tab children = " .. tabs:getChildCount()))
end

--@api: LTabContainer:getActiveChild
do

    local tabs = lurek.ui.newTabContainer()
    local page = lurek.ui.newPanel()
    tabs:addChild(page)
    lurek.log.info(tostring("tab active child = " .. tostring(tabs:getActiveChild())))
    lurek.log.info(tostring("tab active index = " .. tabs:getActiveIndex()))
end

--@api: LTabContainer:addTab
do

    local tabs = lurek.ui.newTabContainer()
    tabs:addTab("Audio")
    tabs:addTab("Controls")
    lurek.log.info(tostring("tab labels = " .. tabs:getTabCount()))
    lurek.log.info(tostring("first tab = " .. tostring(tabs:getTab(1))))
end

--@api: LTabContainer:getTab
do

    local tabs = lurek.ui.newTabContainer()
    tabs:addTab("Gameplay")
    local label = tabs:getTab(1)
    lurek.log.info(tostring("first tab = " .. tostring(label)))
    lurek.log.info(tostring("tab labels = " .. tabs:getTabCount()))
end

--@api: LTabContainer:getTabCount
do

    local tabs = lurek.ui.newTabContainer()
    tabs:addTab("Video")
    tabs:addTab("Audio")
    lurek.log.info(tostring("tab count = " .. tabs:getTabCount()))
    lurek.log.info(tostring("first tab = " .. tostring(tabs:getTab(1))))
end

--@api: LScrollPanel:setScrollSpeed
do

    ---@type LScrollPanel
    local scroll = lurek.ui.newScrollPanel()
    scroll:setScrollSpeed(30)
    lurek.log.info(tostring("scroll speed = " .. scroll:getScrollSpeed()))
    lurek.log.info(tostring("scroll x = " .. select(1, scroll:getScrollPosition())))
    lurek.log.info(tostring("scroll y = " .. select(2, scroll:getScrollPosition())))
end

--@api: LScrollPanel:getScrollSpeed
do

    ---@type LScrollPanel
    local scroll = lurek.ui.newScrollPanel()
    scroll:setScrollSpeed(30)
    lurek.log.info(tostring("scroll speed = " .. scroll:getScrollSpeed()))
    lurek.log.info(tostring("scroll x = " .. select(1, scroll:getScrollPosition())))
    lurek.log.info(tostring("scroll y = " .. select(2, scroll:getScrollPosition())))
end

--@api: LUiWidget:findById
do

    local root = lurek.ui.newLayout("vertical")
    local btn = lurek.ui.newButton("Find Me")
    btn:setId("target_btn")
    root:addChild(btn)
    local found = root:findById("target_btn")
    lurek.log.info(tostring("found = " .. tostring(found ~= nil)))
end

--- UI Module Part 3: input widgets â€” TextInput, Checkbox, Slider, SpinBox, Switch, ComboBox

--@api: lurek.ui.newTextInput
do

    local input = lurek.ui.newTextInput()
    lurek.log.info(tostring("type = " .. input:type()))
    lurek.log.info(tostring("text = '" .. input:getText() .. "'"))
    input:setText("Hello")
    lurek.log.info(tostring("set text = " .. input:getText()))
end

--@api: LTextInput:setPlaceholder
do

    ---@type LTextInput
    local input = lurek.ui.newTextInput()
    input:setPlaceholder("Enter your name...")
    lurek.log.info(tostring("placeholder = " .. input:getPlaceholder()))
    lurek.log.info(tostring("text value = " .. input:getText()))
    lurek.log.info(tostring("placeholder = " .. input:getPlaceholder()))
end

--@api: LTextInput:getPlaceholder
do

    ---@type LTextInput
    local input = lurek.ui.newTextInput()
    input:setPlaceholder("Enter your name...")
    lurek.log.info(tostring("placeholder = " .. input:getPlaceholder()))
    lurek.log.info(tostring("text value = " .. input:getText()))
    lurek.log.info(tostring("placeholder = " .. input:getPlaceholder()))
end

--@api: LTextInput:setMaxLength
do

    local input = lurek.ui.newTextInput()
    input:setMaxLength(50)
    input:setText("Short text")
    local pos = input:getCursorPosition()
    lurek.log.info(tostring("cursor at = " .. pos))
    lurek.log.info(tostring("focused = " .. tostring(input:isFocused())))
end

--@api: LTextInput:getCursorPosition
do

    local input = lurek.ui.newTextInput()
    input:setMaxLength(50)
    input:setText("Short text")
    local pos = input:getCursorPosition()
    lurek.log.info(tostring("cursor at = " .. pos))
    lurek.log.info(tostring("focused = " .. tostring(input:isFocused())))
end

--@api: LTextInput:setSubmitOnEnter
do

    local input = lurek.ui.newTextInput()
    input:setSubmitOnEnter(false)
    input:setText("Confirm name")
    lurek.log.info(tostring("submit_on_enter = " .. tostring(input:getSubmitOnEnter())))
    lurek.log.info(tostring("text = " .. input:getText()))
end

--@api: LTextInput:getSubmitOnEnter
do

    local input = lurek.ui.newTextInput()
    input:setSubmitOnEnter(false)
    lurek.log.info(tostring("submit_on_enter = " .. tostring(input:getSubmitOnEnter())))
    lurek.log.info(tostring("focused = " .. tostring(input:isFocused())))
    lurek.log.info(tostring("text = " .. input:getText()))
end

--@api: lurek.ui.newTextArea
do

    local area = lurek.ui.newTextArea()
    area:setText("Line one\nLine two")
    area:setPlaceholder("Notes")
    local cursor = area:getCursorPosition()
    lurek.log.info(tostring("textarea type = " .. area:type()))
    lurek.log.info(tostring("textarea cursor = " .. cursor))
end

--@api: LTextArea:setText
do

    local area = lurek.ui.newTextArea()
    area:setText("Alpha\nBeta")
    area:setPlaceholder("Body")
    local text = area:getText()
    lurek.log.info(tostring("textarea text = " .. text))
    lurek.log.info(tostring("textarea placeholder = " .. area:getPlaceholder()))
end

--@api: LTextArea:getText
do

    local area = lurek.ui.newTextArea()
    area:setText("Draft\nReady")
    area:setMaxLength(32)
    local text = area:getText()
    lurek.log.info(tostring("textarea text = " .. text))
    lurek.log.info(tostring("textarea cursor = " .. area:getCursorPosition()))
end

--@api: LTextArea:setPlaceholder
do

    local area = lurek.ui.newTextArea()
    area:setPlaceholder("Enter notes")
    area:setText("")
    local placeholder = area:getPlaceholder()
    lurek.log.info(tostring("textarea placeholder = " .. placeholder))
    lurek.log.info(tostring("textarea focused = " .. tostring(area:isFocused())))
end

--@api: LTextArea:getPlaceholder
do

    local area = lurek.ui.newTextArea()
    area:setPlaceholder("Body text")
    area:setText("Existing body")
    local placeholder = area:getPlaceholder()
    lurek.log.info(tostring("textarea placeholder = " .. placeholder))
    lurek.log.info(tostring("textarea text = " .. area:getText()))
end

--@api: LTextArea:setMaxLength
do

    local area = lurek.ui.newTextArea()
    area:setMaxLength(5)
    area:setText("abcdef")
    local text = area:getText()
    lurek.log.info(tostring("textarea capped = " .. text))
    lurek.log.info(tostring("textarea cursor = " .. area:getCursorPosition()))
end

--@api: LTextArea:isFocused
do

    local area = lurek.ui.newTextArea()
    area:setText("Focus target")
    area:setPlaceholder("Focus")
    local focused = area:isFocused()
    lurek.log.info(tostring("textarea focused = " .. tostring(focused)))
    lurek.log.info(tostring("textarea type = " .. area:type()))
end

--@api: LTextArea:getCursorPosition
do

    local area = lurek.ui.newTextArea()
    area:setText("First\nSecond")
    area:setMaxLength(64)
    local cursor = area:getCursorPosition()
    lurek.log.info(tostring("textarea cursor = " .. cursor))
    lurek.log.info(tostring("textarea text = " .. area:getText()))
end

--@api: lurek.ui.newCheckbox
do

    ---@type LCheckbox
    local cb = lurek.ui.newCheckbox("Enable Sound")
    lurek.log.info(tostring("type = " .. cb:type()))
    lurek.log.info(tostring("text = " .. cb:getText()))
    lurek.log.info(tostring("checked = " .. tostring(cb:isChecked())))
    lurek.log.info(tostring("checkbox text = " .. cb:getText()))
end

--@api: LCheckbox:setChecked
do

    local cb = lurek.ui.newCheckbox("Option A")
    cb:setChecked(true)
    lurek.log.info(tostring("checked = " .. tostring(cb:isChecked())))
    cb:setText("Option B")
    lurek.log.info(tostring("text = " .. cb:getText()))
    cb:setChecked(false)
    lurek.log.info(tostring("unchecked = " .. tostring(cb:isChecked())))
end

--@api: LCheckbox:setText
do

    local cb = lurek.ui.newCheckbox("Option A")
    cb:setChecked(true)
    lurek.log.info(tostring("checked = " .. tostring(cb:isChecked())))
    cb:setText("Option B")
    lurek.log.info(tostring("text = " .. cb:getText()))
    cb:setChecked(false)
    lurek.log.info(tostring("unchecked = " .. tostring(cb:isChecked())))
end

--@api: LCheckbox:setOnChange
do

    ---@type LCheckbox
    local cb = lurek.ui.newCheckbox("Fullscreen")
    cb:setOnChange(function()
        lurek.log.info(tostring("checkbox changed, now = " .. tostring(cb:isChecked())))
    end)
    lurek.log.info(tostring("change callback registered"))
end

--@api: lurek.ui.newSlider
do

    local slider = lurek.ui.newSlider(0, 100)
    lurek.log.info(tostring("type = " .. slider:type()))
    lurek.log.info(tostring("min = " .. slider:getMin()))
    lurek.log.info(tostring("max = " .. slider:getMax()))
    lurek.log.info(tostring("value = " .. slider:getValue()))
end

--@api: LSlider:setValue
do

    local slider = lurek.ui.newSlider(0, 1)
    slider:setStep(0.1)
    slider:setValue(0.5)
    lurek.log.info(tostring("value = " .. slider:getValue()))
    slider:setValue(1.5)
    lurek.log.info(tostring("clamped = " .. slider:getValue()))
end

--@api: LSlider:setStep
do

    local slider = lurek.ui.newSlider(0, 1)
    slider:setStep(0.1)
    slider:setValue(0.5)
    lurek.log.info(tostring("value = " .. slider:getValue()))
    slider:setValue(1.5)
    lurek.log.info(tostring("clamped = " .. slider:getValue()))
end

--@api: LSlider:setRange
do

    local slider = lurek.ui.newSlider(0, 10)
    slider:setValue(5)
    lurek.log.info(tostring("before: " .. slider:getMin() .. " to " .. slider:getMax() .. " val=" .. slider:getValue()))
    slider:setRange(0, 100)
    lurek.log.info(tostring("after: " .. slider:getMin() .. " to " .. slider:getMax() .. " val=" .. slider:getValue()))
end

--@api: lurek.ui.newSpinBox
do

    local spin = lurek.ui.newSpinBox(1, 99)
    lurek.log.info(tostring("type = " .. spin:type()))
    lurek.log.info(tostring("value = " .. spin:getValue()))
    spin:setValue(50)
    lurek.log.info(tostring("set to 50 = " .. spin:getValue()))
end

--@api: LSpinBox:increment
do

    local spin = lurek.ui.newSpinBox(0, 100)
    spin:setValue(10)
    spin:setStep(5)
    spin:increment()
    lurek.log.info(tostring("after increment = " .. spin:getValue()))
    spin:decrement()
    spin:decrement()
    lurek.log.info(tostring("after 2 decrements = " .. spin:getValue()))
end

--@api: LSpinBox:decrement
do

    local spin = lurek.ui.newSpinBox(0, 100)
    spin:setValue(10)
    spin:setStep(5)
    spin:increment()
    lurek.log.info(tostring("after increment = " .. spin:getValue()))
    spin:decrement()
    spin:decrement()
    lurek.log.info(tostring("after 2 decrements = " .. spin:getValue()))
end

--@api: LSpinBox:setStep
do

    local spin = lurek.ui.newSpinBox(0, 100)
    spin:setValue(10)
    spin:setStep(5)
    spin:increment()
    lurek.log.info(tostring("after increment = " .. spin:getValue()))
    spin:decrement()
    spin:decrement()
    lurek.log.info(tostring("after 2 decrements = " .. spin:getValue()))
end

--@api: LSpinBox:setRange
do

    ---@type LSpinBox
    local spin = lurek.ui.newSpinBox(0, 10)
    spin:setValue(8)
    spin:setRange(0, 5)
    lurek.log.info(tostring("clamped to range = " .. spin:getValue()))
    lurek.log.info(tostring("rect x = " .. select(1, spin:getRect())))
end

--@api: lurek.ui.newSwitch
do

    ---@type LSwitch
    local sw = lurek.ui.newSwitch(false)
    lurek.log.info(tostring("type = " .. sw:type()))
    lurek.log.info(tostring("on = " .. tostring(sw:isOn())))
    lurek.log.info(tostring("switch on = " .. tostring(sw:isOn())))
    lurek.log.info(tostring("switch width = " .. select(3, sw:getRect())))
end

--@api: LSwitch:setOn
do

    local sw = lurek.ui.newSwitch(true)
    lurek.log.info(tostring("initial = " .. tostring(sw:isOn())))
    sw:toggle()
    lurek.log.info(tostring("toggled = " .. tostring(sw:isOn())))
    sw:setOn(true)
    lurek.log.info(tostring("forced on = " .. tostring(sw:isOn())))
end

--@api: LSwitch:toggle
do

    local sw = lurek.ui.newSwitch(true)
    lurek.log.info(tostring("initial = " .. tostring(sw:isOn())))
    sw:toggle()
    lurek.log.info(tostring("toggled = " .. tostring(sw:isOn())))
    sw:setOn(true)
    lurek.log.info(tostring("forced on = " .. tostring(sw:isOn())))
end

--@api: lurek.ui.newComboBox
do

    ---@type LComboBox
    local combo = lurek.ui.newComboBox()
    lurek.log.info(tostring("type = " .. combo:type()))
    lurek.log.info(tostring("items = " .. combo:getItemCount()))
    lurek.log.info(tostring("item count = " .. combo:getItemCount()))
    lurek.log.info(tostring("selected index = " .. tostring(combo:getSelectedIndex())))
end

--@api: LComboBox:addItem
do

    local combo = lurek.ui.newComboBox()
    combo:addItem("Easy")
    combo:addItem("Normal")
    combo:addItem("Hard")
    combo:addItem("Nightmare")
    lurek.log.info(tostring("item count = " .. combo:getItemCount()))
    lurek.log.info(tostring("item 2 = " .. combo:getItem(2)))
    lurek.log.info(tostring("item 4 = " .. combo:getItem(4)))
end

--@api: LComboBox:getItem
do

    local combo = lurek.ui.newComboBox()
    combo:addItem("Easy")
    combo:addItem("Normal")
    combo:addItem("Hard")
    combo:addItem("Nightmare")
    lurek.log.info(tostring("item count = " .. combo:getItemCount()))
    lurek.log.info(tostring("item 2 = " .. combo:getItem(2)))
    lurek.log.info(tostring("item 4 = " .. combo:getItem(4)))
end

--@api: LComboBox:getItemCount
do

    local combo = lurek.ui.newComboBox()
    combo:addItem("Easy")
    combo:addItem("Normal")
    combo:addItem("Hard")
    combo:addItem("Nightmare")
    lurek.log.info(tostring("item count = " .. combo:getItemCount()))
    lurek.log.info(tostring("item 2 = " .. combo:getItem(2)))
    lurek.log.info(tostring("item 4 = " .. combo:getItem(4)))
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
    lurek.log.info(tostring("selected index = " .. idx))
    lurek.log.info(tostring("selected item = " .. tostring(item)))
    combo:clearItems()
    lurek.log.info(tostring("after clear = " .. combo:getItemCount()))
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
    lurek.log.info(tostring("selected index = " .. idx))
    lurek.log.info(tostring("selected item = " .. tostring(item)))
    combo:clearItems()
    lurek.log.info(tostring("after clear = " .. combo:getItemCount()))
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
    lurek.log.info(tostring("selected index = " .. idx))
    lurek.log.info(tostring("selected item = " .. tostring(item)))
    combo:clearItems()
    lurek.log.info(tostring("after clear = " .. combo:getItemCount()))
end

--@api: LComboBox:setMaxVisibleItems
do

    local combo = lurek.ui.newComboBox()
    combo:addItem("Easy")
    combo:addItem("Normal")
    combo:addItem("Hard")
    combo:addItem("Nightmare")
    combo:setMaxVisibleItems(3)
    lurek.log.info(tostring("max visible = " .. combo:getMaxVisibleItems()))
    lurek.log.info(tostring("item count = " .. combo:getItemCount()))
end

--@api: LComboBox:getMaxVisibleItems
do

    local combo = lurek.ui.newComboBox()
    combo:setMaxVisibleItems(3)
    lurek.log.info(tostring("max visible = " .. combo:getMaxVisibleItems()))
    lurek.log.info(tostring("selected index = " .. tostring(combo:getSelectedIndex())))
    lurek.log.info(tostring("item count = " .. combo:getItemCount()))
end

--@api: lurek.ui.setFocus
do

    local input = lurek.ui.newTextInput()
    lurek.ui.setFocus(input)
    local focused = lurek.ui.getFocus()
    lurek.log.info(tostring("focus set, has focus = " .. tostring(focused ~= nil)))
    lurek.ui.clearFocus()
    focused = lurek.ui.getFocus()
    lurek.log.info(tostring("after clear = " .. tostring(focused)))
end

--@api: lurek.ui.focusNext
do

    local a = lurek.ui.newTextInput()
    local b = lurek.ui.newTextInput()
    local c = lurek.ui.newTextInput()
    lurek.ui.setFocus(a)
    lurek.ui.focusNext()
    lurek.log.info(tostring("moved focus forward"))
    lurek.ui.focusPrev()
    lurek.log.info(tostring("moved focus back"))
end

--- UI Module Part 4: lists, menus, tabs, accordion

--@api: lurek.ui.newList
do

    ---@type LListBox
    local list = lurek.ui.newList()
    lurek.log.info(tostring("type = " .. list:type()))
    lurek.log.info(tostring("items = " .. list:getItemCount()))
    lurek.log.info(tostring("list count = " .. list:getItemCount()))
    lurek.log.info(tostring("list width = " .. select(3, list:getRect())))
end

--@api: LListBox:addItem
do

    local list = lurek.ui.newList()
    list:addItem("Sword")
    list:addItem("Shield")
    list:addItem("Potion")
    list:addItem("Scroll")
    lurek.log.info(tostring("count = " .. list:getItemCount()))
    lurek.log.info(tostring("item 1 = " .. list:getItem(1)))
    lurek.log.info(tostring("item 3 = " .. list:getItem(3)))
end

--@api: LListBox:getItem
do

    local list = lurek.ui.newList()
    list:addItem("Sword")
    list:addItem("Shield")
    list:addItem("Potion")
    list:addItem("Scroll")
    lurek.log.info(tostring("count = " .. list:getItemCount()))
    lurek.log.info(tostring("item 1 = " .. list:getItem(1)))
    lurek.log.info(tostring("item 3 = " .. list:getItem(3)))
end

--@api: LListBox:getItemCount
do

    local list = lurek.ui.newList()
    list:addItem("Sword")
    list:addItem("Shield")
    list:addItem("Potion")
    list:addItem("Scroll")
    lurek.log.info(tostring("count = " .. list:getItemCount()))
    lurek.log.info(tostring("item 1 = " .. list:getItem(1)))
    lurek.log.info(tostring("item 3 = " .. list:getItem(3)))
end

--@api: LListBox:setSelectedIndex
do

    local list = lurek.ui.newList()
    list:addItem("Option A")
    list:addItem("Option B")
    list:addItem("Option C")
    list:setSelectedIndex(2)
    lurek.log.info(tostring("selected = " .. list:getSelectedIndex()))
    list:setSelectedIndex(3)
    lurek.log.info(tostring("changed to = " .. list:getSelectedIndex()))
end

--@api: LListBox:getSelectedIndex
do

    local list = lurek.ui.newList()
    list:addItem("Option A")
    list:addItem("Option B")
    list:addItem("Option C")
    list:setSelectedIndex(2)
    lurek.log.info(tostring("selected = " .. list:getSelectedIndex()))
    list:setSelectedIndex(3)
    lurek.log.info(tostring("changed to = " .. list:getSelectedIndex()))
end

--@api: LListBox:removeItem
do

    local list = lurek.ui.newList()
    list:addItem("First")
    list:addItem("Second")
    list:addItem("Third")
    list:setItemHeight(30)
    list:removeItem(2)
    lurek.log.info(tostring("after remove: count=" .. list:getItemCount()))
    lurek.log.info(tostring("item 2 now = " .. tostring(list:getItem(2))))
    list:clearItems()
    lurek.log.info(tostring("after clear = " .. list:getItemCount()))
end

--@api: LListBox:clearItems
do

    local list = lurek.ui.newList()
    list:addItem("First")
    list:addItem("Second")
    list:addItem("Third")
    list:setItemHeight(30)
    list:removeItem(2)
    lurek.log.info(tostring("after remove: count=" .. list:getItemCount()))
    lurek.log.info(tostring("item 2 now = " .. tostring(list:getItem(2))))
    list:clearItems()
    lurek.log.info(tostring("after clear = " .. list:getItemCount()))
end

--@api: LListBox:setItemHeight
do

    local list = lurek.ui.newList()
    list:addItem("First")
    list:addItem("Second")
    list:addItem("Third")
    list:setItemHeight(30)
    list:removeItem(2)
    lurek.log.info(tostring("after remove: count=" .. list:getItemCount()))
    lurek.log.info(tostring("item 2 now = " .. tostring(list:getItem(2))))
    list:clearItems()
    lurek.log.info(tostring("after clear = " .. list:getItemCount()))
end

--@api: lurek.ui.newMenuBar
do

    ---@type LMenuBar
    local bar = lurek.ui.newMenuBar()
    lurek.log.info(tostring("type = " .. bar:type()))
    lurek.log.info(tostring("menu count = " .. bar:getMenuCount()))
    lurek.log.info(tostring("menu count = " .. bar:getMenuCount()))
    lurek.log.info(tostring("menu width = " .. select(3, bar:getRect())))
end

--@api: lurek.ui.newMenuItem
do

    local item = lurek.ui.newMenuItem("File")
    lurek.log.info(tostring("type = " .. item:type()))
    lurek.log.info(tostring("text = " .. item:getText()))
    item:setShortcut("Ctrl+F")
    lurek.log.info(tostring("shortcut = " .. item:getShortcut()))
end

--@api: LMenuItem:setText
do

    ---@type LMenuItem
    local item = lurek.ui.newMenuItem("Toggle Grid")
    item:setOnClick(function()
        lurek.log.info(tostring("  grid toggle clicked"))
    end)
    item:setChecked(true)
    lurek.log.info(tostring("checked = " .. tostring(item:isChecked())))
    item:setText("Show Grid")
    lurek.log.info(tostring("renamed = " .. item:getText()))
end

--@api: LMenuItem:setOnClick
do

    ---@type LMenuItem
    local item = lurek.ui.newMenuItem("Toggle Grid")
    item:setOnClick(function()
        lurek.log.info(tostring("  grid toggle clicked"))
    end)
    item:setChecked(true)
    lurek.log.info(tostring("checked = " .. tostring(item:isChecked())))
    item:setText("Show Grid")
    lurek.log.info(tostring("renamed = " .. item:getText()))
end

--@api: LMenuItem:setChecked
do

    ---@type LMenuItem
    local item = lurek.ui.newMenuItem("Toggle Grid")
    item:setOnClick(function()
        lurek.log.info(tostring("  grid toggle clicked"))
    end)
    item:setChecked(true)
    lurek.log.info(tostring("checked = " .. tostring(item:isChecked())))
    item:setText("Show Grid")
    lurek.log.info(tostring("renamed = " .. item:getText()))
end

--@api: LMenuItem:isChecked
do

    ---@type LMenuItem
    local item = lurek.ui.newMenuItem("Toggle Grid")
    item:setOnClick(function()
        lurek.log.info(tostring("  grid toggle clicked"))
    end)
    item:setChecked(true)
    lurek.log.info(tostring("checked = " .. tostring(item:isChecked())))
    item:setText("Show Grid")
    lurek.log.info(tostring("renamed = " .. item:getText()))
end

--@api: LMenuItem:addSubItem
do

    local fileMenu = lurek.ui.newMenuItem("File")
    local openItem = lurek.ui.newMenuItem("Open")
    openItem:setShortcut("Ctrl+O")
    local saveItem = lurek.ui.newMenuItem("Save")
    saveItem:setShortcut("Ctrl+S")
    local exitItem = lurek.ui.newMenuItem("Exit")
    fileMenu:addSubItem(openItem)
    fileMenu:addSubItem(saveItem)
    fileMenu:addSubItem(exitItem)
    local subs = fileMenu:getSubItems()
    lurek.log.info(tostring("File has " .. #subs .. " sub-items"))
end

--@api: LMenuItem:getSubItems
do

    local fileMenu = lurek.ui.newMenuItem("File")
    local openItem = lurek.ui.newMenuItem("Open")
    openItem:setShortcut("Ctrl+O")
    local saveItem = lurek.ui.newMenuItem("Save")
    saveItem:setShortcut("Ctrl+S")
    local exitItem = lurek.ui.newMenuItem("Exit")
    fileMenu:addSubItem(openItem)
    fileMenu:addSubItem(saveItem)
    fileMenu:addSubItem(exitItem)
    local subs = fileMenu:getSubItems()
    lurek.log.info(tostring("File has " .. #subs .. " sub-items"))
end

--@api: LMenuBar:addMenu
do

    local bar = lurek.ui.newMenuBar()
    local fileMenu = lurek.ui.newMenuItem("File")
    local editMenu = lurek.ui.newMenuItem("Edit")
    local viewMenu = lurek.ui.newMenuItem("View")
    bar:addMenu(fileMenu)
    bar:addMenu(editMenu)
    bar:addMenu(viewMenu)
    lurek.log.info(tostring("menus = " .. bar:getMenuCount()))
    local menus = bar:getMenus()
    lurek.log.info(tostring("menu indices: " .. #menus .. " entries"))
end

--@api: LMenuBar:getMenuCount
do

    local bar = lurek.ui.newMenuBar()
    local fileMenu = lurek.ui.newMenuItem("File")
    local editMenu = lurek.ui.newMenuItem("Edit")
    local viewMenu = lurek.ui.newMenuItem("View")
    bar:addMenu(fileMenu)
    bar:addMenu(editMenu)
    bar:addMenu(viewMenu)
    lurek.log.info(tostring("menus = " .. bar:getMenuCount()))
    local menus = bar:getMenus()
    lurek.log.info(tostring("menu indices: " .. #menus .. " entries"))
end

--@api: LMenuBar:getMenus
do

    local bar = lurek.ui.newMenuBar()
    local fileMenu = lurek.ui.newMenuItem("File")
    local editMenu = lurek.ui.newMenuItem("Edit")
    local viewMenu = lurek.ui.newMenuItem("View")
    bar:addMenu(fileMenu)
    bar:addMenu(editMenu)
    bar:addMenu(viewMenu)
    lurek.log.info(tostring("menus = " .. bar:getMenuCount()))
    local menus = bar:getMenus()
    lurek.log.info(tostring("menu indices: " .. #menus .. " entries"))
end

--@api: LMenuBar:removeMenu
do

    local bar = lurek.ui.newMenuBar()
    local m = lurek.ui.newMenuItem("Tools")
    bar:addMenu(m)
    lurek.log.info(tostring("before remove = " .. bar:getMenuCount()))
    local ok = bar:removeMenu(m)
    lurek.log.info(tostring("removed = " .. tostring(ok)))
    lurek.log.info(tostring("after remove = " .. bar:getMenuCount()))
end

--@api: lurek.ui.newTabBar
do

    ---@type LTabBar
    local tabs = lurek.ui.newTabBar()
    lurek.log.info(tostring("type = " .. tabs:type()))
    lurek.log.info(tostring("tab count = " .. tabs:getTabCount()))
    lurek.log.info(tostring("tab count = " .. tabs:getTabCount()))
    lurek.log.info(tostring("active tab = " .. tostring(tabs:getActiveTab())))
end

--@api: LTabBar:addTab
do

    local tabs = lurek.ui.newTabBar()
    tabs:addTab("General")
    tabs:addTab("Graphics")
    tabs:addTab("Audio")
    tabs:addTab("Controls")
    lurek.log.info(tostring("count = " .. tabs:getTabCount()))
    lurek.log.info(tostring("tab 1 = " .. tabs:getTab(1)))
    lurek.log.info(tostring("tab 3 = " .. tabs:getTab(3)))
end

--@api: LTabBar:getTab
do

    local tabs = lurek.ui.newTabBar()
    tabs:addTab("General")
    tabs:addTab("Graphics")
    tabs:addTab("Audio")
    tabs:addTab("Controls")
    lurek.log.info(tostring("count = " .. tabs:getTabCount()))
    lurek.log.info(tostring("tab 1 = " .. tabs:getTab(1)))
    lurek.log.info(tostring("tab 3 = " .. tabs:getTab(3)))
end

--@api: LTabBar:getTabCount
do

    local tabs = lurek.ui.newTabBar()
    tabs:addTab("General")
    tabs:addTab("Graphics")
    tabs:addTab("Audio")
    tabs:addTab("Controls")
    lurek.log.info(tostring("count = " .. tabs:getTabCount()))
    lurek.log.info(tostring("tab 1 = " .. tabs:getTab(1)))
    lurek.log.info(tostring("tab 3 = " .. tabs:getTab(3)))
end

--@api: LTabBar:setActiveTab
do

    local tabs = lurek.ui.newTabBar()
    tabs:addTab("Home")
    tabs:addTab("Settings")
    tabs:addTab("Help")
    tabs:setActiveTab(2)
    lurek.log.info(tostring("active = " .. tabs:getActiveTab()))
    local ok = tabs:removeTab(3)
    lurek.log.info(tostring("removed Help = " .. tostring(ok)))
    lurek.log.info(tostring("remaining = " .. tabs:getTabCount()))
end

--@api: LTabBar:getActiveTab
do

    local tabs = lurek.ui.newTabBar()
    tabs:addTab("Home")
    tabs:addTab("Settings")
    tabs:addTab("Help")
    tabs:setActiveTab(2)
    lurek.log.info(tostring("active = " .. tabs:getActiveTab()))
    local ok = tabs:removeTab(3)
    lurek.log.info(tostring("removed Help = " .. tostring(ok)))
    lurek.log.info(tostring("remaining = " .. tabs:getTabCount()))
end

--@api: LTabBar:removeTab
do

    local tabs = lurek.ui.newTabBar()
    tabs:addTab("Home")
    tabs:addTab("Settings")
    tabs:addTab("Help")
    tabs:setActiveTab(2)
    lurek.log.info(tostring("active = " .. tabs:getActiveTab()))
    local ok = tabs:removeTab(3)
    lurek.log.info(tostring("removed Help = " .. tostring(ok)))
    lurek.log.info(tostring("remaining = " .. tabs:getTabCount()))
end

--@api: lurek.ui.newAccordion
do

    ---@type LAccordion
    local acc = lurek.ui.newAccordion()
    lurek.log.info(tostring("type = " .. acc:type()))
    lurek.log.info(tostring("sections = " .. acc:getSectionCount()))
    lurek.log.info(tostring("section count = " .. acc:getSectionCount()))
    lurek.log.info(tostring("exclusive = " .. tostring(acc:isExclusive())))
end

--@api: LAccordion:addSection
do

    local acc = lurek.ui.newAccordion()
    acc:addSection("Player Stats")
    acc:addSection("Inventory")
    acc:addSection("Quest Log")
    lurek.log.info(tostring("sections = " .. acc:getSectionCount()))
    lurek.log.info(tostring("section 1 = " .. acc:getSectionTitle(1)))
    lurek.log.info(tostring("section 2 = " .. acc:getSectionTitle(2)))
end

--@api: LAccordion:getSectionCount
do

    local acc = lurek.ui.newAccordion()
    acc:addSection("Player Stats")
    acc:addSection("Inventory")
    acc:addSection("Quest Log")
    lurek.log.info(tostring("sections = " .. acc:getSectionCount()))
    lurek.log.info(tostring("section 1 = " .. acc:getSectionTitle(1)))
    lurek.log.info(tostring("section 2 = " .. acc:getSectionTitle(2)))
end

--@api: LAccordion:getSectionTitle
do

    local acc = lurek.ui.newAccordion()
    acc:addSection("Player Stats")
    acc:addSection("Inventory")
    acc:addSection("Quest Log")
    lurek.log.info(tostring("sections = " .. acc:getSectionCount()))
    lurek.log.info(tostring("section 1 = " .. acc:getSectionTitle(1)))
    lurek.log.info(tostring("section 2 = " .. acc:getSectionTitle(2)))
end

--@api: LAccordion:toggleSection
do

    local acc = lurek.ui.newAccordion()
    acc:addSection("A")
    acc:addSection("B")
    acc:addSection("C")
    acc:setExclusive(true)
    lurek.log.info(tostring("exclusive = " .. tostring(acc:isExclusive())))
    acc:toggleSection(1)
    lurek.log.info(tostring("section 1 expanded = " .. tostring(acc:isSectionExpanded(1))))
    acc:toggleSection(2)
    lurek.log.info(tostring("section 1 after toggle 2 = " .. tostring(acc:isSectionExpanded(1))))
    lurek.log.info(tostring("section 2 expanded = " .. tostring(acc:isSectionExpanded(2))))
end

--@api: LAccordion:isSectionExpanded
do

    local acc = lurek.ui.newAccordion()
    acc:addSection("A")
    acc:addSection("B")
    acc:addSection("C")
    acc:setExclusive(true)
    lurek.log.info(tostring("exclusive = " .. tostring(acc:isExclusive())))
    acc:toggleSection(1)
    lurek.log.info(tostring("section 1 expanded = " .. tostring(acc:isSectionExpanded(1))))
    acc:toggleSection(2)
    lurek.log.info(tostring("section 1 after toggle 2 = " .. tostring(acc:isSectionExpanded(1))))
    lurek.log.info(tostring("section 2 expanded = " .. tostring(acc:isSectionExpanded(2))))
end

--@api: LAccordion:setExclusive
do

    local acc = lurek.ui.newAccordion()
    acc:addSection("A")
    acc:addSection("B")
    acc:addSection("C")
    acc:setExclusive(true)
    lurek.log.info(tostring("exclusive = " .. tostring(acc:isExclusive())))
    acc:toggleSection(1)
    lurek.log.info(tostring("section 1 expanded = " .. tostring(acc:isSectionExpanded(1))))
    acc:toggleSection(2)
    lurek.log.info(tostring("section 1 after toggle 2 = " .. tostring(acc:isSectionExpanded(1))))
    lurek.log.info(tostring("section 2 expanded = " .. tostring(acc:isSectionExpanded(2))))
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
    modal:setContent(body)
    modal:setFooter(footer)
    modal:addAction("Equip", function(_, action_idx)
        lurek.log.info(tostring("default action fired:") .. " " .. tostring(action_idx))
    end, "default", true)
    modal:addAction("Back", function(_, action_idx)
        lurek.log.info(tostring("cancel action fired:") .. " " .. tostring(action_idx))
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

    lurek.log.info(tostring("modal open:") .. " " .. tostring(modal:isOpen()) .. " " .. tostring("non modal open:") .. " " .. tostring(inspector:isOpen()))
end

--@api: lurek.ui.newWindow
do

    local win = lurek.ui.newWindow("Editor")
    win:setDraggable(true)
    win:setResizable(true)
    win:setCloseable(true)
    win:setOnClose(function(idx)
        lurek.log.info(tostring("window closed, widget index:") .. " " .. tostring(idx))
    end)
    lurek.log.info(tostring("window title:") .. " " .. tostring(win:getTitle()))
    lurek.log.info(tostring("is draggable:") .. " " .. tostring(win:isDraggable()))
    lurek.log.info(tostring("is resizable:") .. " " .. tostring(win:isResizable()))
    lurek.log.info(tostring("is closeable:") .. " " .. tostring(win:isCloseable()))

    win:setTitle("Object Inspector")
    lurek.log.info(tostring("title:") .. " " .. tostring(win:getTitle()))
    win:setDraggable(false)
    lurek.log.info(tostring("draggable after disable:") .. " " .. tostring(win:isDraggable()))
    win:setResizable(false)
    lurek.log.info(tostring("resizable after disable:") .. " " .. tostring(win:isResizable()))
    win:setCloseable(false)
    lurek.log.info(tostring("closeable after disable:") .. " " .. tostring(win:isCloseable()))
end

--@api: lurek.ui.newToolbar
do

    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("save", "Save file")
    lurek.log.info(tostring("orientation:") .. " " .. tostring(tb:getOrientation()))
    lurek.log.info(tostring("toolbar orientation = " .. tb:getOrientation()))
    lurek.log.info(tostring("toolbar width = " .. select(3, tb:getRect())))
end

--@api: lurek.ui.newStatusBar
do

    local sb = lurek.ui.newStatusBar()
    sb:addSection("Ready", 150)
    lurek.log.info(tostring("section count:") .. " " .. tostring(sb:getSectionCount()))
    lurek.log.info(tostring("section 1:") .. " " .. tostring(sb:getSectionText(1)))
    lurek.log.info(tostring("rect x = " .. select(1, sb:getRect())))
end

--@api: lurek.ui.newProgressBar
do

    local bar = lurek.ui.newProgressBar(0, 100)
    bar:setValue(35)
    lurek.log.info(tostring("value:") .. " " .. tostring(bar:getValue()))
    lurek.log.info(tostring("progress (normalized):") .. " " .. tostring(bar:getProgress()))
    lurek.log.info(tostring("progress value = " .. bar:getValue()))
end

--@api: lurek.ui.newImageWidget
do

    local img = lurek.ui.newImageWidget()
    img:setScaleMode("fit")
    lurek.log.info(tostring("scale mode:") .. " " .. tostring(img:getScaleMode()))
    img:setTint(1.0, 0.8, 0.6, 0.9)
    local r, g, b, a = img:getTint()
    lurek.log.info(tostring("tint:") .. " " .. tostring(r) .. " " .. tostring(g) .. " " .. tostring(b) .. " " .. tostring(a))
end

--@api: lurek.ui.newNinePatch
do

    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(128, 128)
    np:setInsets(16, 16, 16, 16)
    local w, h = np:getImageDimensions()
    lurek.log.info(tostring("image size:") .. " " .. tostring(w) .. " " .. tostring(h))
end

--@api: lurek.ui.newBadge
do

    local badge = lurek.ui.newBadge(5)
    lurek.log.info(tostring("count:") .. " " .. tostring(badge:getCount()))
    lurek.log.info(tostring("display:") .. " " .. tostring(badge:getDisplayText()))
    badge:setCount(120)
    lurek.log.info(tostring("large count display:") .. " " .. tostring(badge:getDisplayText()))
end

--@api: lurek.ui.newSpacer
do

    local sp = lurek.ui.newSpacer(20, 10)
    sp:setSize(40, 20)
    local w, h = sp:getSize()
    lurek.log.info(tostring("spacer size:") .. " " .. tostring(w) .. " " .. tostring(h))
    lurek.log.info(tostring("rect x = " .. select(1, sp:getRect())))
end

--@api: lurek.ui.newSeparator
do

    local sep = lurek.ui.newSeparator(false)
    lurek.log.info(tostring("is vertical:") .. " " .. tostring(sep:isVertical()))
    sep:setThickness(2)
    lurek.log.info(tostring("new thickness:") .. " " .. tostring(sep:getThickness()))
    lurek.log.info(tostring("rect x = " .. select(1, sep:getRect())))
end

--@api: lurek.ui.newColorPicker
do

    local cp = lurek.ui.newColorPicker()
    cp:setColor(0.8, 0.2, 0.5, 1.0)
    local r, g, b, a = cp:getColor()
    lurek.log.info(tostring("color:") .. " " .. tostring(r) .. " " .. tostring(g) .. " " .. tostring(b) .. " " .. tostring(a))
    cp:setColorMode("hsv")
    lurek.log.info(tostring("mode:") .. " " .. tostring(cp:getColorMode()))
end

--@api: lurek.ui.newRadioButton
do

    local rb1 = lurek.ui.newRadioButton("Small", "size_group")
    local rb2 = lurek.ui.newRadioButton("Medium", "size_group")
    local rb3 = lurek.ui.newRadioButton("Large", "size_group")
    rb2:setSelected(true)
    lurek.log.info(tostring("rb1 selected:") .. " " .. tostring(rb1:isSelected()))
    lurek.log.info(tostring("rb2 selected:") .. " " .. tostring(rb2:isSelected()))
    lurek.log.info(tostring("rb2 group:") .. " " .. tostring(rb2:getGroup()))
    lurek.log.info(tostring("rb2 text:") .. " " .. tostring(rb2:getText()))
end

--@api: lurek.ui.newTreeView
do

    local tree = lurek.ui.newTreeView()
    local root = tree:addNode("Project")
    tree:addNode("main.lua", root)
    lurek.log.info(tostring("total nodes:") .. " " .. tostring(tree:getNodeCount()))
    lurek.log.info(tostring("root text:") .. " " .. tostring(tree:getNodeText(root)))
end

--@api: lurek.ui.newToast
do

    local toast = lurek.ui.newToast("File saved!", 2.5)
    lurek.log.info(tostring("message:") .. " " .. tostring(toast:getMessage()))
    lurek.log.info(tostring("duration:") .. " " .. tostring(toast:getDuration()))
    toast:setMessage("Upload complete")
    toast:setDuration(4.0)
    lurek.log.info(tostring("updated message:") .. " " .. tostring(toast:getMessage()))
    lurek.log.info(tostring("expired:") .. " " .. tostring(toast:isExpired()))
end

--@api: lurek.ui.newTooltipPanel
do

    local btn = lurek.ui.newButton("Hover me")
    local tip = lurek.ui.newTooltipPanel("Click to submit form")
    tip:setDelay(0.5)
    tip:setTarget(btn)
    lurek.log.info(tostring("tooltip text:") .. " " .. tostring(tip:getText()))
    lurek.log.info(tostring("delay:") .. " " .. tostring(tip:getDelay()))
    lurek.log.info(tostring("target:") .. " " .. tostring(tip:getTarget()))
    tip:setText("Updated tooltip text")
    lurek.log.info(tostring("new text:") .. " " .. tostring(tip:getText()))
end

--@api: lurek.ui.newTheme
do

    local theme = lurek.ui.newTheme()
    theme:setStyle("button", "normal", { bg_r = 0.2, bg_g = 0.2, bg_b = 0.3, bg_a = 1.0, fg_r = 1.0, fg_g = 1.0, fg_b = 1.0, fg_a = 1.0, })
    theme:setStyle("button", "hovered", { bg_r = 0.3, bg_g = 0.3, bg_b = 0.5, bg_a = 1.0, })
    lurek.ui.setTheme(theme)
    lurek.log.info(tostring("theme active:") .. " " .. tostring(lurek.ui.getTheme()))
    lurek.log.info(tostring("theme type:") .. " " .. tostring(theme:type()))
end

--@api: lurek.ui.setTheme
do

    local theme = lurek.ui.newTheme()
    theme:setStyle("button", "normal", { bg_r = 0.2, bg_g = 0.2, bg_b = 0.3, bg_a = 1.0, fg_r = 1.0, fg_g = 1.0, fg_b = 1.0, fg_a = 1.0, })
    theme:setStyle("button", "hovered", { bg_r = 0.3, bg_g = 0.3, bg_b = 0.5, bg_a = 1.0, })
    lurek.ui.setTheme(theme)
    lurek.log.info(tostring("theme active:") .. " " .. tostring(lurek.ui.getTheme()))
    lurek.log.info(tostring("theme type:") .. " " .. tostring(theme:type()))
end

--@api: lurek.ui.getTheme
do

    local theme = lurek.ui.newTheme()
    theme:setStyle("button", "normal", { bg_r = 0.2, bg_g = 0.2, bg_b = 0.3, bg_a = 1.0, fg_r = 1.0, fg_g = 1.0, fg_b = 1.0, fg_a = 1.0, })
    theme:setStyle("button", "hovered", { bg_r = 0.3, bg_g = 0.3, bg_b = 0.5, bg_a = 1.0, })
    lurek.ui.setTheme(theme)
    lurek.log.info(tostring("theme active:") .. " " .. tostring(lurek.ui.getTheme()))
    lurek.log.info(tostring("theme type:") .. " " .. tostring(theme:type()))
end

--@api: lurek.ui.getFocus
do

    local btn1 = lurek.ui.newButton("First")
    local btn2 = lurek.ui.newButton("Second")
    lurek.ui.setFocus(btn1)
    lurek.log.info(tostring("focused widget:") .. " " .. tostring(lurek.ui.getFocus()))
    lurek.ui.focusNext()
    lurek.log.info(tostring("after focusNext:") .. " " .. tostring(lurek.ui.getFocus()))
    lurek.ui.focusPrev()
    lurek.log.info(tostring("after focusPrev:") .. " " .. tostring(lurek.ui.getFocus()))
    lurek.ui.clearFocus()
    lurek.log.info(tostring("after clear:") .. " " .. tostring(lurek.ui.getFocus()))
end

--@api: lurek.ui.focusPrev
do

    local btn1 = lurek.ui.newButton("First")
    local btn2 = lurek.ui.newButton("Second")
    lurek.ui.setFocus(btn1)
    lurek.log.info(tostring("focused widget:") .. " " .. tostring(lurek.ui.getFocus()))
    lurek.ui.focusNext()
    lurek.log.info(tostring("after focusNext:") .. " " .. tostring(lurek.ui.getFocus()))
    lurek.ui.focusPrev()
    lurek.log.info(tostring("after focusPrev:") .. " " .. tostring(lurek.ui.getFocus()))
    lurek.ui.clearFocus()
    lurek.log.info(tostring("after clear:") .. " " .. tostring(lurek.ui.getFocus()))
end

--@api: lurek.ui.clearFocus
do

    local btn1 = lurek.ui.newButton("First")
    local btn2 = lurek.ui.newButton("Second")
    lurek.ui.setFocus(btn1)
    lurek.log.info(tostring("focused widget:") .. " " .. tostring(lurek.ui.getFocus()))
    lurek.ui.focusNext()
    lurek.log.info(tostring("after focusNext:") .. " " .. tostring(lurek.ui.getFocus()))
    lurek.ui.focusPrev()
    lurek.log.info(tostring("after focusPrev:") .. " " .. tostring(lurek.ui.getFocus()))
    lurek.ui.clearFocus()
    lurek.log.info(tostring("after clear:") .. " " .. tostring(lurek.ui.getFocus()))
end

--@api: lurek.ui.beginDrag
do

    local source = lurek.ui.newPanel()
    local target = lurek.ui.newPanel()
    lurek.ui.beginDrag(source)
    lurek.log.info(tostring("active drag:") .. " " .. tostring(lurek.ui.getActiveDrag()))
    lurek.ui.dropOn(target)
    lurek.log.info(tostring("after drop, active drag:") .. " " .. tostring(lurek.ui.getActiveDrag()))
end

--@api: lurek.ui.getActiveDrag
do

    local source = lurek.ui.newPanel()
    local target = lurek.ui.newPanel()
    lurek.ui.beginDrag(source)
    lurek.log.info(tostring("active drag:") .. " " .. tostring(lurek.ui.getActiveDrag()))
    lurek.ui.dropOn(target)
    lurek.log.info(tostring("after drop, active drag:") .. " " .. tostring(lurek.ui.getActiveDrag()))
end

--@api: lurek.ui.dropOn
do

    local source = lurek.ui.newPanel()
    local target = lurek.ui.newPanel()
    lurek.ui.beginDrag(source)
    lurek.log.info(tostring("active drag:") .. " " .. tostring(lurek.ui.getActiveDrag()))
    lurek.ui.dropOn(target)
    lurek.log.info(tostring("after drop, active drag:") .. " " .. tostring(lurek.ui.getActiveDrag()))
end

--- UI Part 8: LAccordion, LColorPicker, LProgressBar, LMenuBar

--@api: LAccordion:isExclusive
do

    local acc = lurek.ui.newAccordion()
    lurek.log.info(tostring("type=" .. acc:type()))
    acc:addSection("Section A")
    acc:addSection("Section B")
    lurek.log.info(tostring("count=" .. acc:getSectionCount()))
    lurek.log.info(tostring("title0=" .. acc:getSectionTitle(1)))
    lurek.log.info(tostring("expanded0=" .. tostring(acc:isSectionExpanded(1))))
    acc:toggleSection(1)
    lurek.log.info(tostring("expanded0_after=" .. tostring(acc:isSectionExpanded(1))))
    lurek.log.info(tostring("exclusive=" .. tostring(acc:isExclusive())))
    acc:setExclusive(true)
    lurek.log.info(tostring("exclusive_after=" .. tostring(acc:isExclusive())))
end

--@api: LColorPicker:getColor
do

    local cp = lurek.ui.newColorPicker()
    lurek.log.info(tostring("type=" .. cp:type()))
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    lurek.log.info(tostring("color=" .. r .. "," .. g .. "," .. b .. "," .. a))
    lurek.log.info(tostring("mode=" .. tostring(cp:getColorMode())))
    cp:setColorMode("hsv")
    lurek.log.info(tostring("mode_after=" .. cp:getColorMode()))
    lurek.log.info(tostring("show_alpha=" .. tostring(cp:getShowAlpha())))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2)
        lurek.log.info(tostring("changed") .. " " .. tostring(r2) .. " " .. tostring(g2) .. " " .. tostring(b2) .. " " .. tostring(a2))
    end)
end

--@api: LColorPicker:getColorMode
do

    local cp = lurek.ui.newColorPicker()
    lurek.log.info(tostring("type=" .. cp:type()))
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    lurek.log.info(tostring("color=" .. r .. "," .. g .. "," .. b .. "," .. a))
    lurek.log.info(tostring("mode=" .. tostring(cp:getColorMode())))
    cp:setColorMode("hsv")
    lurek.log.info(tostring("mode_after=" .. cp:getColorMode()))
    lurek.log.info(tostring("show_alpha=" .. tostring(cp:getShowAlpha())))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) lurek.log.info(tostring("changed") .. " " .. tostring(r2) .. " " .. tostring(g2) .. " " .. tostring(b2) .. " " .. tostring(a2)) end)
end

--@api: LColorPicker:getShowAlpha
do

    local cp = lurek.ui.newColorPicker()
    lurek.log.info(tostring("type=" .. cp:type()))
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    lurek.log.info(tostring("color=" .. r .. "," .. g .. "," .. b .. "," .. a))
    lurek.log.info(tostring("mode=" .. tostring(cp:getColorMode())))
    cp:setColorMode("hsv")
    lurek.log.info(tostring("mode_after=" .. cp:getColorMode()))
    lurek.log.info(tostring("show_alpha=" .. tostring(cp:getShowAlpha())))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) lurek.log.info(tostring("changed") .. " " .. tostring(r2) .. " " .. tostring(g2) .. " " .. tostring(b2) .. " " .. tostring(a2)) end)
end

--@api: LColorPicker:setColor
do

    local cp = lurek.ui.newColorPicker()
    lurek.log.info(tostring("type=" .. cp:type()))
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    lurek.log.info(tostring("color=" .. r .. "," .. g .. "," .. b .. "," .. a))
    lurek.log.info(tostring("mode=" .. tostring(cp:getColorMode())))
    cp:setColorMode("hsv")
    lurek.log.info(tostring("mode_after=" .. cp:getColorMode()))
    lurek.log.info(tostring("show_alpha=" .. tostring(cp:getShowAlpha())))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) lurek.log.info(tostring("changed") .. " " .. tostring(r2) .. " " .. tostring(g2) .. " " .. tostring(b2) .. " " .. tostring(a2)) end)
end

--@api: LColorPicker:setColorMode
do

    local cp = lurek.ui.newColorPicker()
    lurek.log.info(tostring("type=" .. cp:type()))
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    lurek.log.info(tostring("color=" .. r .. "," .. g .. "," .. b .. "," .. a))
    lurek.log.info(tostring("mode=" .. tostring(cp:getColorMode())))
    cp:setColorMode("hsv")
    lurek.log.info(tostring("mode_after=" .. cp:getColorMode()))
    lurek.log.info(tostring("show_alpha=" .. tostring(cp:getShowAlpha())))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) lurek.log.info(tostring("changed") .. " " .. tostring(r2) .. " " .. tostring(g2) .. " " .. tostring(b2) .. " " .. tostring(a2)) end)
end

--@api: LColorPicker:setOnChange
do

    local cp = lurek.ui.newColorPicker()
    lurek.log.info(tostring("type=" .. cp:type()))
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    lurek.log.info(tostring("color=" .. r .. "," .. g .. "," .. b .. "," .. a))
    lurek.log.info(tostring("mode=" .. tostring(cp:getColorMode())))
    cp:setColorMode("hsv")
    lurek.log.info(tostring("mode_after=" .. cp:getColorMode()))
    lurek.log.info(tostring("show_alpha=" .. tostring(cp:getShowAlpha())))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) lurek.log.info(tostring("changed") .. " " .. tostring(r2) .. " " .. tostring(g2) .. " " .. tostring(b2) .. " " .. tostring(a2)) end)
end

--@api: LColorPicker:setShowAlpha
do

    local cp = lurek.ui.newColorPicker()
    lurek.log.info(tostring("type=" .. cp:type()))
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    lurek.log.info(tostring("color=" .. r .. "," .. g .. "," .. b .. "," .. a))
    lurek.log.info(tostring("mode=" .. tostring(cp:getColorMode())))
    cp:setColorMode("hsv")
    lurek.log.info(tostring("mode_after=" .. cp:getColorMode()))
    lurek.log.info(tostring("show_alpha=" .. tostring(cp:getShowAlpha())))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) lurek.log.info(tostring("changed") .. " " .. tostring(r2) .. " " .. tostring(g2) .. " " .. tostring(b2) .. " " .. tostring(a2)) end)
end

--@api: LProgressBar:getMax
do

    local pb = lurek.ui.newProgressBar(0, 100)
    lurek.log.info(tostring("type=" .. pb:type()))
    lurek.log.info(tostring("min=" .. pb:getMin()))
    lurek.log.info(tostring("max=" .. pb:getMax()))
    pb:setValue(75)
    lurek.log.info(tostring("value=" .. pb:getValue()))
    lurek.log.info(tostring("progress=" .. pb:getProgress()))
    pb:setRange(0, 200)
    lurek.log.info(tostring("max_after=" .. pb:getMax()))
end

--@api: LProgressBar:getMin
do

    local pb = lurek.ui.newProgressBar(0, 100)
    lurek.log.info(tostring("type=" .. pb:type()))
    lurek.log.info(tostring("min=" .. pb:getMin()))
    lurek.log.info(tostring("max=" .. pb:getMax()))
    pb:setValue(75)
    lurek.log.info(tostring("value=" .. pb:getValue()))
    lurek.log.info(tostring("progress=" .. pb:getProgress()))
    pb:setRange(0, 200)
    lurek.log.info(tostring("max_after=" .. pb:getMax()))
end

--@api: LProgressBar:getProgress
do

    local pb = lurek.ui.newProgressBar(0, 100)
    lurek.log.info(tostring("type=" .. pb:type()))
    lurek.log.info(tostring("min=" .. pb:getMin()))
    lurek.log.info(tostring("max=" .. pb:getMax()))
    pb:setValue(75)
    lurek.log.info(tostring("value=" .. pb:getValue()))
    lurek.log.info(tostring("progress=" .. pb:getProgress()))
    pb:setRange(0, 200)
    lurek.log.info(tostring("max_after=" .. pb:getMax()))
end

--@api: LProgressBar:getValue
do

    local pb = lurek.ui.newProgressBar(0, 100)
    lurek.log.info(tostring("type=" .. pb:type()))
    lurek.log.info(tostring("min=" .. pb:getMin()))
    lurek.log.info(tostring("max=" .. pb:getMax()))
    pb:setValue(75)
    lurek.log.info(tostring("value=" .. pb:getValue()))
    lurek.log.info(tostring("progress=" .. pb:getProgress()))
    pb:setRange(0, 200)
    lurek.log.info(tostring("max_after=" .. pb:getMax()))
end

--@api: LProgressBar:setRange
do

    local pb = lurek.ui.newProgressBar(0, 100)
    lurek.log.info(tostring("type=" .. pb:type()))
    lurek.log.info(tostring("min=" .. pb:getMin()))
    lurek.log.info(tostring("max=" .. pb:getMax()))
    pb:setValue(75)
    lurek.log.info(tostring("value=" .. pb:getValue()))
    lurek.log.info(tostring("progress=" .. pb:getProgress()))
    pb:setRange(0, 200)
    lurek.log.info(tostring("max_after=" .. pb:getMax()))
end

--@api: LProgressBar:setValue
do

    local pb = lurek.ui.newProgressBar(0, 100)
    lurek.log.info(tostring("type=" .. pb:type()))
    lurek.log.info(tostring("min=" .. pb:getMin()))
    lurek.log.info(tostring("max=" .. pb:getMax()))
    pb:setValue(75)
    lurek.log.info(tostring("value=" .. pb:getValue()))
    lurek.log.info(tostring("progress=" .. pb:getProgress()))
    pb:setRange(0, 200)
    lurek.log.info(tostring("max_after=" .. pb:getMax()))
end

--- UI Part 9: LTabBar, LStatusBar, LToolbar

--@api: LStatusBar:addSection
do

    local sb = lurek.ui.newStatusBar()
    lurek.log.info(tostring("type=" .. sb:type()))
    sb:addSection("Ready", 120)
    sb:addSection("Line 1", 80)
    lurek.log.info(tostring("sections=" .. sb:getSectionCount()))
    lurek.log.info(tostring("text1=" .. sb:getSectionText(1)))
    sb:setSectionText(1, "Loading...")
    lurek.log.info(tostring("text1_after=" .. sb:getSectionText(1)))
end

--@api: LStatusBar:getSectionCount
do

    local sb = lurek.ui.newStatusBar()
    lurek.log.info(tostring("type=" .. sb:type()))
    sb:addSection("Ready", 120)
    sb:addSection("Line 1", 80)
    lurek.log.info(tostring("sections=" .. sb:getSectionCount()))
    lurek.log.info(tostring("text1=" .. sb:getSectionText(1)))
    sb:setSectionText(1, "Loading...")
    lurek.log.info(tostring("text1_after=" .. sb:getSectionText(1)))
end

--@api: LStatusBar:getSectionText
do

    local sb = lurek.ui.newStatusBar()
    lurek.log.info(tostring("type=" .. sb:type()))
    sb:addSection("Ready", 120)
    sb:addSection("Line 1", 80)
    lurek.log.info(tostring("sections=" .. sb:getSectionCount()))
    lurek.log.info(tostring("text1=" .. sb:getSectionText(1)))
    sb:setSectionText(1, "Loading...")
    lurek.log.info(tostring("text1_after=" .. sb:getSectionText(1)))
end

--@api: LStatusBar:setSectionText
do

    local sb = lurek.ui.newStatusBar()
    lurek.log.info(tostring("type=" .. sb:type()))
    sb:addSection("Ready", 120)
    sb:addSection("Line 1", 80)
    lurek.log.info(tostring("sections=" .. sb:getSectionCount()))
    lurek.log.info(tostring("text1=" .. sb:getSectionText(1)))
    sb:setSectionText(1, "Loading...")
    lurek.log.info(tostring("text1_after=" .. sb:getSectionText(1)))
end

--@api: LToolbar:addButton
do

    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    lurek.log.info(tostring("btn=" .. tostring(bar:getButton("btn_save") ~= nil)))
    lurek.log.info(tostring("toolbar orientation = " .. bar:getOrientation()))
    lurek.log.info(tostring("toolbar width = " .. select(3, bar:getRect())))
end

--@api: LToolbar:addSeparator
do

    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    bar:addSeparator()
    lurek.log.info(tostring("separator added"))
    lurek.log.info(tostring("toolbar orientation = " .. bar:getOrientation()))
end

--@api: LToolbar:getButton

do

    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    local btn = bar:getButton("btn_save")
    lurek.log.info(tostring("btn=" .. tostring(btn ~= nil)))
    lurek.log.info(tostring("toolbar type=" .. tostring(bar:type())))
end

--@api: LToolbar:getOrientation
do

    local bar = lurek.ui.newToolbar("horizontal")
    lurek.log.info(tostring("orientation=" .. bar:getOrientation()))
    lurek.log.info(tostring("toolbar orientation = " .. bar:getOrientation()))
    lurek.log.info(tostring("toolbar width = " .. select(3, bar:getRect())))
    lurek.log.info(tostring("toolbar visible = " .. tostring(bar:isVisible())))
end

--@api: LToolbar:isButtonToggled
do

    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    lurek.log.info(tostring("toggled=" .. tostring(bar:isButtonToggled("btn_save"))))
    lurek.log.info(tostring("toolbar orientation = " .. bar:getOrientation()))
    lurek.log.info(tostring("toolbar width = " .. select(3, bar:getRect())))
end

--@api: LToolbar:setButtonEnabled
do

    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_open", "Open file")
    bar:setButtonEnabled("btn_open", false)
    lurek.log.info(tostring("btn_open disabled"))
    lurek.log.info(tostring("toolbar orientation = " .. bar:getOrientation()))
end

--@api: LToolbar:setButtonToggled
do

    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    bar:setButtonToggled("btn_save", true)
    lurek.log.info(tostring("toggled_after=" .. tostring(bar:isButtonToggled("btn_save"))))
    lurek.log.info(tostring("toolbar orientation = " .. bar:getOrientation()))
end

--@api: LToolbar:setOrientation
do

    local bar = lurek.ui.newToolbar("horizontal")
    bar:setOrientation("vertical")
    lurek.log.info(tostring("orientation_after=" .. bar:getOrientation()))
    lurek.log.info(tostring("toolbar orientation = " .. bar:getOrientation()))
    lurek.log.info(tostring("toolbar width = " .. select(3, bar:getRect())))
end

--@api: lurek.ui.addToast
do

    lurek.ui.addToast({ message = "File saved successfully", duration = 3.0, type = "info" })
    lurek.log.info(tostring("toast added"))
    local layout = lurek.ui.loadLayout({ type = "panel", children = {} })
    lurek.log.info(tostring("layout id=" .. tostring(layout)))
    lurek.log.info(tostring("layout loaded=" .. tostring(type(layout) == "number")))
end

--@api: lurek.ui.loadLayout
do

    lurek.ui.addToast({ message = "File saved successfully", duration = 3.0, type = "info" })
    lurek.log.info(tostring("toast added"))
    local layout = lurek.ui.loadLayout({
        type = "layout",
        direction = "grid",
        columns = 2,
        padding = { 8, 8, 8, 8 },
        children = {
            { type = "label", text = "HP", textAlign = "right", margin = { 2, 4, 2, 4 } },
        },
    })
    lurek.log.info(tostring("layout=" .. tostring(layout ~= nil)))
end

--@api: lurek.ui.setAutoInput
do

    lurek.ui.setAutoInput(true)
    local enabled = lurek.ui.hasAutoInput()
    lurek.ui.setAutoInput(false)
    local disabled = lurek.ui.hasAutoInput()
    lurek.log.info(tostring("auto input enabled=" .. tostring(enabled)))
    lurek.log.info(tostring("auto input disabled=" .. tostring(disabled)))
end

--@api: lurek.ui.hasAutoInput
do

    lurek.ui.setAutoInput(true)
    local enabled = lurek.ui.hasAutoInput()
    lurek.ui.setAutoInput(false)
    local disabled = lurek.ui.hasAutoInput()
    lurek.log.info(tostring("auto input enabled=" .. tostring(enabled)))
    lurek.log.info(tostring("auto input disabled=" .. tostring(disabled)))
end

--@api: lurek.ui.setAutoUpdate
do

    lurek.ui.setAutoUpdate(true)
    local enabled = lurek.ui.hasAutoUpdate()
    lurek.ui.setAutoUpdate(false)
    local disabled = lurek.ui.hasAutoUpdate()
    lurek.log.info(tostring("auto update enabled=" .. tostring(enabled)))
    lurek.log.info(tostring("auto update disabled=" .. tostring(disabled)))
end

--@api: lurek.ui.hasAutoUpdate
do

    lurek.ui.setAutoUpdate(true)
    local enabled = lurek.ui.hasAutoUpdate()
    lurek.ui.setAutoUpdate(false)
    local disabled = lurek.ui.hasAutoUpdate()
    lurek.log.info(tostring("auto update enabled=" .. tostring(enabled)))
    lurek.log.info(tostring("auto update disabled=" .. tostring(disabled)))
end

--- UI Part 10: LBadge, LDockPanel, LImageWidget, LNinePatch, LRadioButton, LSpinBox, LSplitPanel, LSwitch, LTable, LToast, LTooltipPanel, LTreeView

--@api: LBadge:getCount
do

    local badge = lurek.ui.newBadge(3)
    lurek.log.info(tostring("type=" .. badge:type()))
    lurek.log.info(tostring("count=" .. badge:getCount()))
    badge:setCount(7)
    lurek.log.info(tostring("count_after=" .. badge:getCount()))
    local text = badge:getDisplayText()
    lurek.log.info(tostring("text=" .. tostring(text)))
end

--@api: LBadge:getDisplayText
do

    local badge = lurek.ui.newBadge(3)
    lurek.log.info(tostring("type=" .. badge:type()))
    lurek.log.info(tostring("count=" .. badge:getCount()))
    badge:setCount(7)
    lurek.log.info(tostring("count_after=" .. badge:getCount()))
    local text = badge:getDisplayText()
    lurek.log.info(tostring("text=" .. tostring(text)))
end

--@api: LBadge:setCount
do

    local badge = lurek.ui.newBadge(3)
    lurek.log.info(tostring("type=" .. badge:type()))
    lurek.log.info(tostring("count=" .. badge:getCount()))
    badge:setCount(7)
    lurek.log.info(tostring("count_after=" .. badge:getCount()))
    local text = badge:getDisplayText()
    lurek.log.info(tostring("text=" .. tostring(text)))
end

--@api: LDockPanel:dock
do

    local dp = lurek.ui.newDockPanel()
    local child = lurek.ui.newPanel()
    lurek.log.info(tostring("type=" .. dp:type()))
    dp:addChild(child)
    dp:dock(child, "left")
    lurek.log.info(tostring("docked=" .. dp:getDockedCount()))
    lurek.log.info(tostring("split_size=" .. tostring(dp:getSplitSize("left"))))
    dp:setSplitSize("left", 150)
    dp:undock(child)
    lurek.log.info(tostring("docked_after=" .. dp:getDockedCount()))
end

--@api: LDockPanel:getDockedCount
do

    local dp = lurek.ui.newDockPanel()
    lurek.log.info(tostring("type=" .. dp:type()))
    local child = lurek.ui.newPanel()
    dp:dock(0, "left")
    lurek.log.info(tostring("docked=" .. dp:getDockedCount()))
    local sz = dp:getSplitSize("left")
    lurek.log.info(tostring("split_size=" .. tostring(sz)))
    dp:setSplitSize("left", 150)
    dp:undock(0)
    lurek.log.info(tostring("docked_after=" .. dp:getDockedCount()))
end

--@api: LDockPanel:getSplitSize
do

    local dp = lurek.ui.newDockPanel()
    lurek.log.info(tostring("type=" .. dp:type()))
    local child = lurek.ui.newPanel()
    dp:dock(0, "left")
    lurek.log.info(tostring("docked=" .. dp:getDockedCount()))
    local sz = dp:getSplitSize("left")
    lurek.log.info(tostring("split_size=" .. tostring(sz)))
    dp:setSplitSize("left", 150)
    dp:undock(0)
    lurek.log.info(tostring("docked_after=" .. dp:getDockedCount()))
end

--@api: LDockPanel:setSplitSize
do

    local dp = lurek.ui.newDockPanel()
    lurek.log.info(tostring("type=" .. dp:type()))
    local child = lurek.ui.newPanel()
    dp:dock(0, "left")
    lurek.log.info(tostring("docked=" .. dp:getDockedCount()))
    local sz = dp:getSplitSize("left")
    lurek.log.info(tostring("split_size=" .. tostring(sz)))
    dp:setSplitSize("left", 150)
    dp:undock(0)
    lurek.log.info(tostring("docked_after=" .. dp:getDockedCount()))
end

--@api: LImageWidget:getScaleMode
do

    local iw = lurek.ui.newImageWidget()
    lurek.log.info(tostring("type=" .. iw:type()))
    lurek.log.info(tostring("scale_mode=" .. tostring(iw:getScaleMode())))
    iw:setScaleMode("stretch")
    lurek.log.info(tostring("scale_mode_after=" .. iw:getScaleMode()))
    iw:setTint(1.0, 0.78, 0.5, 1.0)
    local r, g, b, a = iw:getTint()
    lurek.log.info(tostring("tint=" .. r .. "," .. g .. "," .. b .. "," .. a))
end

--@api: LImageWidget:getTint
do

    local iw = lurek.ui.newImageWidget()
    lurek.log.info(tostring("type=" .. iw:type()))
    lurek.log.info(tostring("scale_mode=" .. tostring(iw:getScaleMode())))
    iw:setScaleMode("stretch")
    lurek.log.info(tostring("scale_mode_after=" .. iw:getScaleMode()))
    iw:setTint(1.0, 0.78, 0.5, 1.0)
    local r, g, b, a = iw:getTint()
    lurek.log.info(tostring("tint=" .. r .. "," .. g .. "," .. b .. "," .. a))
end

--@api: LImageWidget:setScaleMode
do

    local iw = lurek.ui.newImageWidget()
    lurek.log.info(tostring("type=" .. iw:type()))
    lurek.log.info(tostring("scale_mode=" .. tostring(iw:getScaleMode())))
    iw:setScaleMode("stretch")
    lurek.log.info(tostring("scale_mode_after=" .. iw:getScaleMode()))
    iw:setTint(1.0, 0.78, 0.5, 1.0)
    local r, g, b, a = iw:getTint()
    lurek.log.info(tostring("tint=" .. r .. "," .. g .. "," .. b .. "," .. a))
end

--@api: LImageWidget:setTint
do

    local iw = lurek.ui.newImageWidget()
    lurek.log.info(tostring("type=" .. iw:type()))
    lurek.log.info(tostring("scale_mode=" .. tostring(iw:getScaleMode())))
    iw:setScaleMode("stretch")
    lurek.log.info(tostring("scale_mode_after=" .. iw:getScaleMode()))
    iw:setTint(1.0, 0.78, 0.5, 1.0)
    local r, g, b, a = iw:getTint()
    lurek.log.info(tostring("tint=" .. r .. "," .. g .. "," .. b .. "," .. a))
end

--@api: LNinePatch:getImageDimensions
do

    local np = lurek.ui.newNinePatch()
    lurek.log.info(tostring("type=" .. np:type()))
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    lurek.log.info(tostring("img_dim=" .. w .. "x" .. h))
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    lurek.log.info(tostring("insets=" .. l .. "," .. t .. "," .. r .. "," .. b))
    local slices = np:getSlices()
    lurek.log.info(tostring("slices=" .. tostring(slices ~= nil)))
end

--@api: LNinePatch:getInsets
do

    local np = lurek.ui.newNinePatch()
    lurek.log.info(tostring("type=" .. np:type()))
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    lurek.log.info(tostring("img_dim=" .. w .. "x" .. h))
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    lurek.log.info(tostring("insets=" .. l .. "," .. t .. "," .. r .. "," .. b))
    local slices = np:getSlices()
    lurek.log.info(tostring("slices=" .. tostring(slices ~= nil)))
end

--@api: LNinePatch:getSlices
do

    local np = lurek.ui.newNinePatch()
    lurek.log.info(tostring("type=" .. np:type()))
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    lurek.log.info(tostring("img_dim=" .. w .. "x" .. h))
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    lurek.log.info(tostring("insets=" .. l .. "," .. t .. "," .. r .. "," .. b))
    local slices = np:getSlices()
    lurek.log.info(tostring("slices=" .. tostring(slices ~= nil)))
end

--@api: LNinePatch:setImageDimensions
do

    local np = lurek.ui.newNinePatch()
    lurek.log.info(tostring("type=" .. np:type()))
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    lurek.log.info(tostring("img_dim=" .. w .. "x" .. h))
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    lurek.log.info(tostring("insets=" .. l .. "," .. t .. "," .. r .. "," .. b))
    local slices = np:getSlices()
    lurek.log.info(tostring("slices=" .. tostring(slices ~= nil)))
end

--@api: LNinePatch:setInsets
do

    local np = lurek.ui.newNinePatch()
    lurek.log.info(tostring("type=" .. np:type()))
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    lurek.log.info(tostring("img_dim=" .. w .. "x" .. h))
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    lurek.log.info(tostring("insets=" .. l .. "," .. t .. "," .. r .. "," .. b))
    local slices = np:getSlices()
    lurek.log.info(tostring("slices=" .. tostring(slices ~= nil)))
end

--@api: LRadioButton:getGroup
do

    local rb1 = lurek.ui.newRadioButton("Option A", "opt_group")
    local rb2 = lurek.ui.newRadioButton("Option B", "opt_group")
    lurek.log.info(tostring("type=" .. rb1:type()))
    lurek.log.info(tostring("text=" .. rb1:getText()))
    lurek.log.info(tostring("group=" .. rb1:getGroup()))
    lurek.log.info(tostring("selected=" .. tostring(rb1:isSelected())))
    rb1:setGroup("new_group")
    lurek.log.info(tostring("group_after=" .. rb1:getGroup()))
end

--@api: LRadioButton:getText
do

    local rb1 = lurek.ui.newRadioButton("Option A", "opt_group")
    local rb2 = lurek.ui.newRadioButton("Option B", "opt_group")
    lurek.log.info(tostring("type=" .. rb1:type()))
    lurek.log.info(tostring("text=" .. rb1:getText()))
    lurek.log.info(tostring("group=" .. rb1:getGroup()))
    lurek.log.info(tostring("selected=" .. tostring(rb1:isSelected())))
    rb1:setGroup("new_group")
    lurek.log.info(tostring("group_after=" .. rb1:getGroup()))
end

--@api: LRadioButton:isSelected
do

    local rb1 = lurek.ui.newRadioButton("Option A", "opt_group")
    local rb2 = lurek.ui.newRadioButton("Option B", "opt_group")
    lurek.log.info(tostring("type=" .. rb1:type()))
    lurek.log.info(tostring("text=" .. rb1:getText()))
    lurek.log.info(tostring("group=" .. rb1:getGroup()))
    lurek.log.info(tostring("selected=" .. tostring(rb1:isSelected())))
    rb1:setGroup("new_group")
    lurek.log.info(tostring("group_after=" .. rb1:getGroup()))
end

--@api: LRadioButton:setGroup
do

    local rb1 = lurek.ui.newRadioButton("Option A", "opt_group")
    local rb2 = lurek.ui.newRadioButton("Option B", "opt_group")
    lurek.log.info(tostring("type=" .. rb1:type()))
    lurek.log.info(tostring("text=" .. rb1:getText()))
    lurek.log.info(tostring("group=" .. rb1:getGroup()))
    lurek.log.info(tostring("selected=" .. tostring(rb1:isSelected())))
    rb1:setGroup("new_group")
    lurek.log.info(tostring("group_after=" .. rb1:getGroup()))
end

--@api: LSpinBox:getValue
do

    local sb = lurek.ui.newSpinBox(1, 10)
    lurek.log.info(tostring("type=" .. sb:type()))
    sb:setValue(5)
    lurek.log.info(tostring("value=" .. sb:getValue()))
    sb:setStep(2)
    sb:setRange(0, 100)
    sb:increment()
    lurek.log.info(tostring("value_after_inc=" .. sb:getValue()))
    sb:decrement()
    lurek.log.info(tostring("value_after_dec=" .. sb:getValue()))
end

--@api: LSpinBox:setValue
do

    local sb = lurek.ui.newSpinBox(1, 10)
    lurek.log.info(tostring("type=" .. sb:type()))
    sb:setValue(5)
    lurek.log.info(tostring("value=" .. sb:getValue()))
    sb:setStep(2)
    sb:setRange(0, 100)
    sb:increment()
    lurek.log.info(tostring("value_after_inc=" .. sb:getValue()))
    sb:decrement()
    lurek.log.info(tostring("value_after_dec=" .. sb:getValue()))
end

--@api: LSplitPanel:getFirstChild
do

    local sp = lurek.ui.newSplitPanel("horizontal")
    local first = lurek.ui.newPanel()
    local second = lurek.ui.newPanel()
    lurek.log.info(tostring("type=" .. sp:type()))
    lurek.log.info(tostring("orientation=" .. sp:getOrientation()))
    sp:setFirstChild(first)
    sp:setSecondChild(second)
    local fc = sp:getFirstChild()
    local sc = sp:getSecondChild()
    lurek.log.info(tostring("fc=" .. tostring(fc)))
    lurek.log.info(tostring("sc=" .. tostring(sc)))
    sp:setSplitPosition(0.4)
    lurek.log.info(tostring("split_pos=" .. sp:getSplitPosition()))
    sp:setMinPanelSize(80)
    lurek.log.info(tostring("min_panel=" .. sp:getMinPanelSize()))
    sp:setOrientation("vertical")
    lurek.log.info(tostring("orientation_after=" .. sp:getOrientation()))
end

--@api: LSplitPanel:getMinPanelSize
do

    local sp = lurek.ui.newSplitPanel("horizontal")
    lurek.log.info(tostring("type=" .. sp:type()))
    lurek.log.info(tostring("orientation=" .. sp:getOrientation()))
    sp:setFirstChild(lurek.ui.newPanel())
    sp:setSecondChild(lurek.ui.newPanel())
    local fc = sp:getFirstChild()
    lurek.log.info(tostring("fc=" .. tostring(fc)))
    local sc = sp:getSecondChild()
    lurek.log.info(tostring("sc=" .. tostring(sc)))
    sp:setSplitPosition(200)
    lurek.log.info(tostring("split_pos=" .. sp:getSplitPosition()))
    sp:setMinPanelSize(80)
    lurek.log.info(tostring("min_panel=" .. sp:getMinPanelSize()))
    sp:setOrientation("vertical")
    lurek.log.info(tostring("orientation_after=" .. sp:getOrientation()))
end

--@api: LSplitPanel:getOrientation
do

    local sp = lurek.ui.newSplitPanel("horizontal")
    lurek.log.info(tostring("type=" .. sp:type()))
    lurek.log.info(tostring("orientation=" .. sp:getOrientation()))
    sp:setFirstChild(lurek.ui.newPanel())
    sp:setSecondChild(lurek.ui.newPanel())
    local fc = sp:getFirstChild()
    lurek.log.info(tostring("fc=" .. tostring(fc)))
    local sc = sp:getSecondChild()
    lurek.log.info(tostring("sc=" .. tostring(sc)))
    sp:setSplitPosition(200)
    lurek.log.info(tostring("split_pos=" .. sp:getSplitPosition()))
    sp:setMinPanelSize(80)
    lurek.log.info(tostring("min_panel=" .. sp:getMinPanelSize()))
    sp:setOrientation("vertical")
    lurek.log.info(tostring("orientation_after=" .. sp:getOrientation()))
end

--@api: LSplitPanel:getSecondChild
do

    local sp = lurek.ui.newSplitPanel("horizontal")
    lurek.log.info(tostring("type=" .. sp:type()))
    lurek.log.info(tostring("orientation=" .. sp:getOrientation()))
    sp:setFirstChild(lurek.ui.newPanel())
    sp:setSecondChild(lurek.ui.newPanel())
    local fc = sp:getFirstChild()
    lurek.log.info(tostring("fc=" .. tostring(fc)))
    local sc = sp:getSecondChild()
    lurek.log.info(tostring("sc=" .. tostring(sc)))
    sp:setSplitPosition(200)
    lurek.log.info(tostring("split_pos=" .. sp:getSplitPosition()))
    sp:setMinPanelSize(80)
    lurek.log.info(tostring("min_panel=" .. sp:getMinPanelSize()))
    sp:setOrientation("vertical")
    lurek.log.info(tostring("orientation_after=" .. sp:getOrientation()))
end

--@api: LSplitPanel:getSplitPosition
do

    local sp = lurek.ui.newSplitPanel("horizontal")
    lurek.log.info(tostring("type=" .. sp:type()))
    lurek.log.info(tostring("orientation=" .. sp:getOrientation()))
    sp:setFirstChild(lurek.ui.newPanel())
    sp:setSecondChild(lurek.ui.newPanel())
    local fc = sp:getFirstChild()
    lurek.log.info(tostring("fc=" .. tostring(fc)))
    local sc = sp:getSecondChild()
    lurek.log.info(tostring("sc=" .. tostring(sc)))
    sp:setSplitPosition(200)
    lurek.log.info(tostring("split_pos=" .. sp:getSplitPosition()))
    sp:setMinPanelSize(80)
    lurek.log.info(tostring("min_panel=" .. sp:getMinPanelSize()))
    sp:setOrientation("vertical")
    lurek.log.info(tostring("orientation_after=" .. sp:getOrientation()))
end

--@api: LSplitPanel:setFirstChild
do

    local sp = lurek.ui.newSplitPanel("horizontal")
    lurek.log.info(tostring("type=" .. sp:type()))
    lurek.log.info(tostring("orientation=" .. sp:getOrientation()))
    sp:setFirstChild(lurek.ui.newPanel())
    sp:setSecondChild(lurek.ui.newPanel())
    local fc = sp:getFirstChild()
    lurek.log.info(tostring("fc=" .. tostring(fc)))
    local sc = sp:getSecondChild()
    lurek.log.info(tostring("sc=" .. tostring(sc)))
    sp:setSplitPosition(200)
    lurek.log.info(tostring("split_pos=" .. sp:getSplitPosition()))
    sp:setMinPanelSize(80)
    lurek.log.info(tostring("min_panel=" .. sp:getMinPanelSize()))
    sp:setOrientation("vertical")
    lurek.log.info(tostring("orientation_after=" .. sp:getOrientation()))
end

--@api: LSplitPanel:setMinPanelSize
do

    local sp = lurek.ui.newSplitPanel("horizontal")
    lurek.log.info(tostring("type=" .. sp:type()))
    lurek.log.info(tostring("orientation=" .. sp:getOrientation()))
    sp:setFirstChild(lurek.ui.newPanel())
    sp:setSecondChild(lurek.ui.newPanel())
    local fc = sp:getFirstChild()
    lurek.log.info(tostring("fc=" .. tostring(fc)))
    local sc = sp:getSecondChild()
    lurek.log.info(tostring("sc=" .. tostring(sc)))
    sp:setSplitPosition(200)
    lurek.log.info(tostring("split_pos=" .. sp:getSplitPosition()))
    sp:setMinPanelSize(80)
    lurek.log.info(tostring("min_panel=" .. sp:getMinPanelSize()))
    sp:setOrientation("vertical")
    lurek.log.info(tostring("orientation_after=" .. sp:getOrientation()))
end

--@api: LSplitPanel:setOrientation
do

    local sp = lurek.ui.newSplitPanel("horizontal")
    lurek.log.info(tostring("type=" .. sp:type()))
    lurek.log.info(tostring("orientation=" .. sp:getOrientation()))
    sp:setFirstChild(lurek.ui.newPanel())
    sp:setSecondChild(lurek.ui.newPanel())
    local fc = sp:getFirstChild()
    lurek.log.info(tostring("fc=" .. tostring(fc)))
    local sc = sp:getSecondChild()
    lurek.log.info(tostring("sc=" .. tostring(sc)))
    sp:setSplitPosition(200)
    lurek.log.info(tostring("split_pos=" .. sp:getSplitPosition()))
    sp:setMinPanelSize(80)
    lurek.log.info(tostring("min_panel=" .. sp:getMinPanelSize()))
    sp:setOrientation("vertical")
    lurek.log.info(tostring("orientation_after=" .. sp:getOrientation()))
end

--@api: LSplitPanel:setSecondChild
do

    local sp = lurek.ui.newSplitPanel("horizontal")
    lurek.log.info(tostring("type=" .. sp:type()))
    lurek.log.info(tostring("orientation=" .. sp:getOrientation()))
    sp:setFirstChild(lurek.ui.newPanel())
    sp:setSecondChild(lurek.ui.newPanel())
    local fc = sp:getFirstChild()
    lurek.log.info(tostring("fc=" .. tostring(fc)))
    local sc = sp:getSecondChild()
    lurek.log.info(tostring("sc=" .. tostring(sc)))
    sp:setSplitPosition(200)
    lurek.log.info(tostring("split_pos=" .. sp:getSplitPosition()))
    sp:setMinPanelSize(80)
    lurek.log.info(tostring("min_panel=" .. sp:getMinPanelSize()))
    sp:setOrientation("vertical")
    lurek.log.info(tostring("orientation_after=" .. sp:getOrientation()))
end

--@api: LSplitPanel:setSplitPosition
do

    local sp = lurek.ui.newSplitPanel("horizontal")
    lurek.log.info(tostring("type=" .. sp:type()))
    lurek.log.info(tostring("orientation=" .. sp:getOrientation()))
    sp:setFirstChild(lurek.ui.newPanel())
    sp:setSecondChild(lurek.ui.newPanel())
    local fc = sp:getFirstChild()
    lurek.log.info(tostring("fc=" .. tostring(fc)))
    local sc = sp:getSecondChild()
    lurek.log.info(tostring("sc=" .. tostring(sc)))
    sp:setSplitPosition(200)
    lurek.log.info(tostring("split_pos=" .. sp:getSplitPosition()))
    sp:setMinPanelSize(80)
    lurek.log.info(tostring("min_panel=" .. sp:getMinPanelSize()))
    sp:setOrientation("vertical")
    lurek.log.info(tostring("orientation_after=" .. sp:getOrientation()))
end

--@api: LSwitch:isOn
do

    local sw = lurek.ui.newSwitch(false)
    lurek.log.info(tostring("type=" .. sw:type()))
    lurek.log.info(tostring("is_on=" .. tostring(sw:isOn())))
    sw:setOn(true)
    lurek.log.info(tostring("is_on_after=" .. tostring(sw:isOn())))
    sw:setOnChange(function(v) lurek.log.info(tostring("switch_changed=" .. tostring(v))) end)
end

--@api: LSwitch:setOnChange
do

    local sw = lurek.ui.newSwitch(false)
    lurek.log.info(tostring("type=" .. sw:type()))
    lurek.log.info(tostring("is_on=" .. tostring(sw:isOn())))
    sw:setOn(true)
    lurek.log.info(tostring("is_on_after=" .. tostring(sw:isOn())))
    sw:setOnChange(function(v) lurek.log.info(tostring("switch_changed=" .. tostring(v))) end)
end

--@api: LGuiTable:addColumn
do

    local tbl = lurek.ui.newTable()
    lurek.log.info(tostring("type=" .. tbl:type()))
    tbl:addColumn("Name")
    tbl:addColumn("Score")
    lurek.log.info(tostring("cols=" .. tbl:getColumnCount()))
    tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" })
    lurek.log.info(tostring("rows=" .. tbl:getRowCount()))
    lurek.log.info(tostring("cell11=" .. tostring(tbl:getCell(1, 1))))
    tbl:setCell(1, 2, "999")
    tbl:setSelectedRow(1)
    lurek.log.info(tostring("selected=" .. tostring(tbl:getSelectedRow())))
end

--@api: LGuiTable:addRow
do

    local tbl = lurek.ui.newTable()
    lurek.log.info(tostring("type=" .. tbl:type()))
    tbl:addColumn("Name")
    tbl:addColumn("Score")
    lurek.log.info(tostring("cols=" .. tbl:getColumnCount()))
    tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" })
    lurek.log.info(tostring("rows=" .. tbl:getRowCount()))
    local cell = tbl:getCell(0, 0)
    lurek.log.info(tostring("cell00=" .. tostring(cell)))
    tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1)
    lurek.log.info(tostring("selected=" .. tbl:getSelectedRow()))
end

--@api: LGuiTable:clearRows
do

    local tbl = lurek.ui.newTable()
    tbl:setRows({ { "Food", 420 }, { "Rent", 1200 } })
    tbl:setSelectedRow(1)
    tbl:clearRows()
    lurek.log.info(tostring("rows=" .. tbl:getRowCount()))
end

--@api: LGuiTable:setRows
do

    local tbl = lurek.ui.newTable()
    local count = tbl:setRows({ { "Income", 3200 }, { "Savings", 640 } })
    lurek.log.info(tostring("setRows=" .. count .. ", first=" .. tostring(tbl:getCell(1, 1))))
    lurek.log.info(tostring("rect x = " .. select(1, tbl:getRect())))
    lurek.log.info(tostring("rect y = " .. select(2, tbl:getRect())))
end

--@api: LGuiTable:setDataFrame
do

    local df = lurek.dataframe.fromRows({ "category", "amount" }, { { "Food", 420 }, { "Rent", 1200 } })
    local tbl = lurek.ui.newTable()
    local count = tbl:setDataFrame(df, { columns = { "category", "amount" }, maxRows = 2 })
    lurek.log.info(tostring("setDataFrame=" .. count .. ", cols=" .. tbl:getColumnCount()))
    lurek.log.info(tostring("rect x = " .. select(1, tbl:getRect())))
end

--@api: LGuiTable:getCell
do

    local tbl = lurek.ui.newTable()
    lurek.log.info(tostring("type=" .. tbl:type()))
    tbl:addColumn("Name")
    tbl:addColumn("Score")
    lurek.log.info(tostring("cols=" .. tbl:getColumnCount()))
    tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" })
    lurek.log.info(tostring("rows=" .. tbl:getRowCount()))
    local cell = tbl:getCell(0, 0)
    lurek.log.info(tostring("cell00=" .. tostring(cell)))
    tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1)
    lurek.log.info(tostring("selected=" .. tbl:getSelectedRow()))
end

--@api: LGuiTable:getColumnCount
do

    local tbl = lurek.ui.newTable()
    lurek.log.info(tostring("type=" .. tbl:type()))
    tbl:addColumn("Name")
    tbl:addColumn("Score")
    lurek.log.info(tostring("cols=" .. tbl:getColumnCount()))
    tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" })
    lurek.log.info(tostring("rows=" .. tbl:getRowCount()))
    local cell = tbl:getCell(0, 0)
    lurek.log.info(tostring("cell00=" .. tostring(cell)))
    tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1)
    lurek.log.info(tostring("selected=" .. tbl:getSelectedRow()))
end

--@api: LGuiTable:getRowCount
do

    local tbl = lurek.ui.newTable()
    lurek.log.info(tostring("type=" .. tbl:type()))
    tbl:addColumn("Name")
    tbl:addColumn("Score")
    lurek.log.info(tostring("cols=" .. tbl:getColumnCount()))
    tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" })
    lurek.log.info(tostring("rows=" .. tbl:getRowCount()))
    local cell = tbl:getCell(0, 0)
    lurek.log.info(tostring("cell00=" .. tostring(cell)))
    tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1)
    lurek.log.info(tostring("selected=" .. tbl:getSelectedRow()))
end

--@api: LGuiTable:getSelectedRow
do

    local tbl = lurek.ui.newTable()
    lurek.log.info(tostring("type=" .. tbl:type()))
    tbl:addColumn("Name")
    tbl:addColumn("Score")
    lurek.log.info(tostring("cols=" .. tbl:getColumnCount()))
    tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" })
    lurek.log.info(tostring("rows=" .. tbl:getRowCount()))
    local cell = tbl:getCell(0, 0)
    lurek.log.info(tostring("cell00=" .. tostring(cell)))
    tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1)
    lurek.log.info(tostring("selected=" .. tbl:getSelectedRow()))
end

--@api: LGuiTable:setCell
do

    local tbl = lurek.ui.newTable()
    lurek.log.info(tostring("type=" .. tbl:type()))
    tbl:addColumn("Name")
    tbl:addColumn("Score")
    lurek.log.info(tostring("cols=" .. tbl:getColumnCount()))
    tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" })
    lurek.log.info(tostring("rows=" .. tbl:getRowCount()))
    local cell = tbl:getCell(0, 0)
    lurek.log.info(tostring("cell00=" .. tostring(cell)))
    tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1)
    lurek.log.info(tostring("selected=" .. tbl:getSelectedRow()))
end

--@api: LGuiTable:setSelectedRow
do

    local tbl = lurek.ui.newTable()
    lurek.log.info(tostring("type=" .. tbl:type()))
    tbl:addColumn("Name")
    tbl:addColumn("Score")
    lurek.log.info(tostring("cols=" .. tbl:getColumnCount()))
    tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" })
    lurek.log.info(tostring("rows=" .. tbl:getRowCount()))
    local cell = tbl:getCell(0, 0)
    lurek.log.info(tostring("cell00=" .. tostring(cell)))
    tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1)
    lurek.log.info(tostring("selected=" .. tbl:getSelectedRow()))
end

--@api: lurek.ui.newTable
do

    local tbl = lurek.ui.newTable()
    lurek.log.info(tostring("type=" .. tbl:type()))
    tbl:addColumn("Name")
    tbl:addColumn("Score")
    lurek.log.info(tostring("cols=" .. tbl:getColumnCount()))
    tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" })
    lurek.log.info(tostring("rows=" .. tbl:getRowCount()))
    local cell = tbl:getCell(0, 0)
    lurek.log.info(tostring("cell00=" .. tostring(cell)))
    tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1)
    lurek.log.info(tostring("selected=" .. tbl:getSelectedRow()))
end

--@api: LToast:getDuration
do

    local toast = lurek.ui.newToast("File saved", 3.0)
    lurek.log.info(tostring("type=" .. toast:type()))
    lurek.log.info(tostring("msg=" .. toast:getMessage()))
    lurek.log.info(tostring("dur=" .. toast:getDuration()))
    lurek.log.info(tostring("progress=" .. toast:getProgress()))
    lurek.log.info(tostring("expired=" .. tostring(toast:isExpired())))
    toast:setMessage("Updated message")
    toast:setDuration(5.0)
    lurek.log.info(tostring("msg_after=" .. toast:getMessage()))
    lurek.log.info(tostring("dur_after=" .. toast:getDuration()))
end

--@api: LToast:getMessage
do

    local toast = lurek.ui.newToast("File saved", 3.0)
    lurek.log.info(tostring("type=" .. toast:type()))
    lurek.log.info(tostring("msg=" .. toast:getMessage()))
    lurek.log.info(tostring("dur=" .. toast:getDuration()))
    lurek.log.info(tostring("progress=" .. toast:getProgress()))
    lurek.log.info(tostring("expired=" .. tostring(toast:isExpired())))
    toast:setMessage("Updated message")
    toast:setDuration(5.0)
    lurek.log.info(tostring("msg_after=" .. toast:getMessage()))
    lurek.log.info(tostring("dur_after=" .. toast:getDuration()))
end

--@api: LToast:getProgress
do

    local toast = lurek.ui.newToast("File saved", 3.0)
    lurek.log.info(tostring("type=" .. toast:type()))
    lurek.log.info(tostring("msg=" .. toast:getMessage()))
    lurek.log.info(tostring("dur=" .. toast:getDuration()))
    lurek.log.info(tostring("progress=" .. toast:getProgress()))
    lurek.log.info(tostring("expired=" .. tostring(toast:isExpired())))
    toast:setMessage("Updated message")
    toast:setDuration(5.0)
    lurek.log.info(tostring("msg_after=" .. toast:getMessage()))
    lurek.log.info(tostring("dur_after=" .. toast:getDuration()))
end

--@api: LToast:isExpired
do

    local toast = lurek.ui.newToast("File saved", 3.0)
    lurek.log.info(tostring("type=" .. toast:type()))
    lurek.log.info(tostring("msg=" .. toast:getMessage()))
    lurek.log.info(tostring("dur=" .. toast:getDuration()))
    lurek.log.info(tostring("progress=" .. toast:getProgress()))
    lurek.log.info(tostring("expired=" .. tostring(toast:isExpired())))
    toast:setMessage("Updated message")
    toast:setDuration(5.0)
    lurek.log.info(tostring("msg_after=" .. toast:getMessage()))
    lurek.log.info(tostring("dur_after=" .. toast:getDuration()))
end

--@api: LToast:setDuration
do

    local toast = lurek.ui.newToast("File saved", 3.0)
    lurek.log.info(tostring("type=" .. toast:type()))
    lurek.log.info(tostring("msg=" .. toast:getMessage()))
    lurek.log.info(tostring("dur=" .. toast:getDuration()))
    lurek.log.info(tostring("progress=" .. toast:getProgress()))
    lurek.log.info(tostring("expired=" .. tostring(toast:isExpired())))
    toast:setMessage("Updated message")
    toast:setDuration(5.0)
    lurek.log.info(tostring("msg_after=" .. toast:getMessage()))
    lurek.log.info(tostring("dur_after=" .. toast:getDuration()))
end

--@api: LToast:setMessage
do

    local toast = lurek.ui.newToast("File saved", 3.0)
    lurek.log.info(tostring("type=" .. toast:type()))
    lurek.log.info(tostring("msg=" .. toast:getMessage()))
    lurek.log.info(tostring("dur=" .. toast:getDuration()))
    lurek.log.info(tostring("progress=" .. toast:getProgress()))
    lurek.log.info(tostring("expired=" .. tostring(toast:isExpired())))
    toast:setMessage("Updated message")
    toast:setDuration(5.0)
    lurek.log.info(tostring("msg_after=" .. toast:getMessage()))
    lurek.log.info(tostring("dur_after=" .. toast:getDuration()))
end

--@api: LTooltipPanel:getDelay
do

    local ttp = lurek.ui.newTooltipPanel("Hover info")
    lurek.log.info(tostring("type=" .. ttp:type()))
    lurek.log.info(tostring("text=" .. ttp:getText()))
    ttp:setText("Updated tooltip")
    lurek.log.info(tostring("text_after=" .. ttp:getText()))
    ttp:setDelay(0.5)
    lurek.log.info(tostring("delay=" .. ttp:getDelay()))
end

--@api: LTooltipPanel:getText
do

    local ttp = lurek.ui.newTooltipPanel("Hover info")
    lurek.log.info(tostring("type=" .. ttp:type()))
    lurek.log.info(tostring("text=" .. ttp:getText()))
    ttp:setText("Updated tooltip")
    lurek.log.info(tostring("text_after=" .. ttp:getText()))
    ttp:setDelay(0.5)
    lurek.log.info(tostring("delay=" .. ttp:getDelay()))
end

--@api: LTooltipPanel:setDelay
do

    local ttp = lurek.ui.newTooltipPanel("Hover info")
    lurek.log.info(tostring("type=" .. ttp:type()))
    lurek.log.info(tostring("text=" .. ttp:getText()))
    ttp:setText("Updated tooltip")
    lurek.log.info(tostring("text_after=" .. ttp:getText()))
    ttp:setDelay(0.5)
    lurek.log.info(tostring("delay=" .. ttp:getDelay()))
end

--@api: LTooltipPanel:setText
do

    local ttp = lurek.ui.newTooltipPanel("Hover info")
    lurek.log.info(tostring("type=" .. ttp:type()))
    lurek.log.info(tostring("text=" .. ttp:getText()))
    ttp:setText("Updated tooltip")
    lurek.log.info(tostring("text_after=" .. ttp:getText()))
    ttp:setDelay(0.5)
    lurek.log.info(tostring("delay=" .. ttp:getDelay()))
end

--@api: LTreeView:addNode
do

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child = tv:addNode("Child C", root)
    lurek.log.info(tostring("child added = " .. tostring(child ~= nil)))
    lurek.log.info(tostring("node count = " .. tv:getNodeCount()))
end

--@api: LTreeView:clearNodes
do

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    tv:clearNodes()
    lurek.log.info(tostring("nodes = " .. tv:getNodeCount()))
end

--@api: LTreeView:collapseAll
do

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    tv:expandAll()
    tv:collapseAll()
    lurek.log.info(tostring("root expanded = " .. tostring(tv:isExpanded(root))))
end

--@api: LTreeView:collapseNode
do

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:expandNode(root)
    tv:collapseNode(root)
    lurek.log.info(tostring("root expanded = " .. tostring(tv:isNodeExpanded(root))))
end

--@api: LTreeView:expandAll
do

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    tv:expandAll()
    lurek.log.info(tostring("root expanded = " .. tostring(tv:isExpanded(root))))
end

--@api: LTreeView:expandNode
do

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:expandNode(root)
    lurek.log.info(tostring("root expanded = " .. tostring(tv:isNodeExpanded(root))))
    lurek.log.info(tostring("node count = " .. tv:getNodeCount()))
end

--@api: LTreeView:getChildNodes
do

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    tv:addNode("Child B", root)
    local children = tv:getChildNodes(root)
    lurek.log.info(tostring("child count = " .. #children))
end

--@api: LTreeView:getNodeCount
do

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    lurek.log.info(tostring("nodes = " .. tv:getNodeCount()))
    lurek.log.info(tostring("node count = " .. tv:getNodeCount()))
end

--@api: LTreeView:getNodeDepth
do

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    lurek.log.info(tostring("depth = " .. tv:getNodeDepth(child1)))
    lurek.log.info(tostring("node count = " .. tv:getNodeCount()))
end

--@api: LTreeView:getNodeText
do

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    lurek.log.info(tostring("text = " .. tv:getNodeText(child1)))
    lurek.log.info(tostring("node count = " .. tv:getNodeCount()))
end

--@api: LTreeView:getParentNode
do

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    lurek.log.info(tostring("parent = " .. tostring(tv:getParentNode(child1) == root)))
    lurek.log.info(tostring("node count = " .. tv:getNodeCount()))
end

--@api: LTreeView:getSelectedNode
do

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    tv:setSelectedNode(child1)
    lurek.log.info(tostring("selected = " .. tostring(tv:getSelectedNode())))
end

--@api: LTreeView:isExpanded
do

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:expandAll()
    lurek.log.info(tostring("expanded = " .. tostring(tv:isExpanded(root))))
    lurek.log.info(tostring("node count = " .. tv:getNodeCount()))
end

--@api: LTreeView:isNodeExpanded
do

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:expandNode(root)
    lurek.log.info(tostring("node expanded = " .. tostring(tv:isNodeExpanded(root))))
    lurek.log.info(tostring("node count = " .. tv:getNodeCount()))
end

--@api: LTreeView:removeNode
do

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    local child2 = tv:addNode("Child B", root)
    tv:removeNode(child2)
    lurek.log.info(tostring("nodes = " .. tv:getNodeCount()))
end

--@api: LTreeView:setNodeIcon
do

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    tv:setNodeIcon(child1, "folder")
    lurek.log.info(tostring("icon set on child"))
end

--@api: LTreeView:setNodeText
do

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    tv:setNodeText(child1, "Renamed A")
    lurek.log.info(tostring("text = " .. tv:getNodeText(child1)))
end

--@api: LTreeView:setSelectedNode
do

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    tv:setSelectedNode(child1)
    lurek.log.info(tostring("selected = " .. tostring(tv:getSelectedNode())))
end

--@api: LTreeView:toggleNode
do

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    local child2 = tv:addNode("Child B", root)
    tv:toggleNode(child2)
    lurek.log.info(tostring("child toggled"))
end

--@api: LAccordion:getSectionTitle.2
do

    local acc = lurek.ui.newAccordion()
    acc:addSection("Chapter 1")
    acc:addSection("Chapter 2")
    local cnt = acc:getSectionCount()
    local title = acc:getSectionTitle(1)
    lurek.log.info(tostring("sections:") .. " " .. tostring(cnt) .. " " .. tostring("title:") .. " " .. tostring(title))
end

--@api: LAccordion:getSectionTitle.3
do

    local acc = lurek.ui.newAccordion()
    acc:addSection("Chapter 1")
    acc:addSection("Chapter 2")
    local cnt = acc:getSectionCount()
    local title = acc:getSectionTitle(1)
    lurek.log.info(tostring("sections:") .. " " .. tostring(cnt) .. " " .. tostring("title:") .. " " .. tostring(title))
end

--@api: LAccordion:getSectionTitle.4
do

    local acc = lurek.ui.newAccordion()
    acc:addSection("Chapter 1")
    acc:addSection("Chapter 2")
    local cnt = acc:getSectionCount()
    local title = acc:getSectionTitle(1)
    lurek.log.info(tostring("sections:") .. " " .. tostring(cnt) .. " " .. tostring("title:") .. " " .. tostring(title))
end

--@api: LAccordion:isSectionExpanded.2
do

    local acc = lurek.ui.newAccordion()
    acc:addSection("A")
    acc:setExclusive(true)
    local ex = acc:isExclusive()
    local expanded = acc:isSectionExpanded(1)
    lurek.log.info(tostring("exclusive:") .. " " .. tostring(ex) .. " " .. tostring("expanded:") .. " " .. tostring(expanded))
end

--@api: LAccordion:isSectionExpanded.3
do

    local acc = lurek.ui.newAccordion()
    acc:addSection("A")
    acc:setExclusive(true)
    local ex = acc:isExclusive()
    local expanded = acc:isSectionExpanded(1)
    lurek.log.info(tostring("exclusive:") .. " " .. tostring(ex) .. " " .. tostring("expanded:") .. " " .. tostring(expanded))
end

--@api: LAccordion:isSectionExpanded.4
do

    local acc = lurek.ui.newAccordion()
    acc:addSection("A")
    acc:setExclusive(true)
    local ex = acc:isExclusive()
    local expanded = acc:isSectionExpanded(1)
    lurek.log.info(tostring("exclusive:") .. " " .. tostring(ex) .. " " .. tostring("expanded:") .. " " .. tostring(expanded))
end

--@api: LAccordion:toggleSection.2
do

    local acc = lurek.ui.newAccordion()
    acc:addSection("Toggle me")
    local newState = acc:toggleSection(1)
    local badge = lurek.ui.newBadge(5)
    local count = badge:getCount()
    local disp = badge:getDisplayText()
    lurek.log.info(tostring("toggled:") .. " " .. tostring(newState) .. " " .. tostring("badge count:") .. " " .. tostring(count) .. " " .. tostring("display:") .. " " .. tostring(disp))
end

--@api: LAccordion:toggleSection.3
do

    local acc = lurek.ui.newAccordion()
    acc:addSection("Toggle me")
    local newState = acc:toggleSection(1)
    local badge = lurek.ui.newBadge(5)
    local count = badge:getCount()
    local disp = badge:getDisplayText()
    lurek.log.info(tostring("toggled:") .. " " .. tostring(newState) .. " " .. tostring("badge count:") .. " " .. tostring(count) .. " " .. tostring("display:") .. " " .. tostring(disp))
end

--@api: LAccordion:toggleSection.4
do

    local acc = lurek.ui.newAccordion()
    acc:addSection("Toggle me")
    local newState = acc:toggleSection(1)
    local badge = lurek.ui.newBadge(5)
    local count = badge:getCount()
    local disp = badge:getDisplayText()
    lurek.log.info(tostring("toggled:") .. " " .. tostring(newState) .. " " .. tostring("badge count:") .. " " .. tostring(count) .. " " .. tostring("display:") .. " " .. tostring(disp))
end

--@api: LBadge:setCount.2
do

    local badge = lurek.ui.newBadge(0)
    badge:setCount(42)
    local btn = lurek.ui.newButton("Click me")
    local t = btn:getText()
    btn:setText("OK")
    lurek.log.info(tostring("badge count:") .. " " .. tostring(badge:getCount()) .. " " .. tostring("button text:") .. " " .. tostring(btn:getText()))
end

--@api: LButton:getText
do

    local badge = lurek.ui.newBadge(0)
    badge:setCount(42)
    local btn = lurek.ui.newButton("Click me")
    local t = btn:getText()
    btn:setText("OK")
    lurek.log.info(tostring("badge count:") .. " " .. tostring(badge:getCount()) .. " " .. tostring("button text:") .. " " .. tostring(btn:getText()))
end

--@api: LButton:setText
do

    local badge = lurek.ui.newBadge(0)
    badge:setCount(42)
    local btn = lurek.ui.newButton("Click me")
    local t = btn:getText()
    btn:setText("OK")
    lurek.log.info(tostring("badge count:") .. " " .. tostring(badge:getCount()) .. " " .. tostring("button text:") .. " " .. tostring(btn:getText()))
end

--@api: LCheckbox:getText
do

    local cb = lurek.ui.newCheckbox("Enable feature")
    local t = cb:getText()
    cb:setChecked(true)
    local checked = cb:isChecked()
    lurek.log.info(tostring("checkbox text:") .. " " .. tostring(t) .. " " .. tostring("checked:") .. " " .. tostring(checked))
end

--@api: LCheckbox:isChecked
do

    local cb = lurek.ui.newCheckbox("Enable feature")
    local t = cb:getText()
    cb:setChecked(true)
    local checked = cb:isChecked()
    lurek.log.info(tostring("checkbox text:") .. " " .. tostring(t) .. " " .. tostring("checked:") .. " " .. tostring(checked))
end

--@api: LCheckbox:isChecked.2
do

    local cb = lurek.ui.newCheckbox("Enable feature")
    local t = cb:getText()
    cb:setChecked(true)
    local checked = cb:isChecked()
    lurek.log.info(tostring("checkbox text:") .. " " .. tostring(t) .. " " .. tostring("checked:") .. " " .. tostring(checked))
end

--@api: LCheckbox:setText.2
do

    local cb = lurek.ui.newCheckbox("old")
    cb:setText("new label")
    lurek.log.info(tostring("checkbox setText ok"))
    lurek.log.info(tostring("checkbox text = " .. cb:getText()))
    lurek.log.info(tostring("checked = " .. tostring(cb:isChecked())))
end

--@api: LColorPicker:getShowAlpha.2
do

    local cp = lurek.ui.newColorPicker()
    cp:setColor(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = cp:getColor()
    local mode = cp:getColorMode()
    local showAlpha = cp:getShowAlpha()
    lurek.log.info(tostring("color:") .. " " .. tostring(r) .. " " .. tostring(g) .. " " .. tostring(b) .. " " .. tostring(a) .. " " .. tostring("mode:") .. " " .. tostring(mode) .. " " .. tostring("showAlpha:") .. " " .. tostring(showAlpha))
end

--@api: LColorPicker:getShowAlpha.3
do

    local cp = lurek.ui.newColorPicker()
    cp:setColor(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = cp:getColor()
    local mode = cp:getColorMode()
    local showAlpha = cp:getShowAlpha()
    lurek.log.info(tostring("color:") .. " " .. tostring(r) .. " " .. tostring(g) .. " " .. tostring(b) .. " " .. tostring(a) .. " " .. tostring("mode:") .. " " .. tostring(mode) .. " " .. tostring("showAlpha:") .. " " .. tostring(showAlpha))
end

--@api: LColorPicker:getShowAlpha.4
do

    local cp = lurek.ui.newColorPicker()
    cp:setColor(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = cp:getColor()
    local mode = cp:getColorMode()
    local showAlpha = cp:getShowAlpha()
    lurek.log.info(tostring("color:") .. " " .. tostring(r) .. " " .. tostring(g) .. " " .. tostring(b) .. " " .. tostring(a) .. " " .. tostring("mode:") .. " " .. tostring(mode) .. " " .. tostring("showAlpha:") .. " " .. tostring(showAlpha))
end

--@api: LColorPicker:setColorMode.2
do

    local cp = lurek.ui.newColorPicker()
    cp:setColor(0.2, 0.8, 0.4, 1.0)
    cp:setColorMode("hsv")
    cp:setOnChange(function(idx) lurek.log.info(tostring("color changed") .. " " .. tostring(idx)) end)
    cp:setShowAlpha(true)
    lurek.log.info(tostring("setColor/setColorMode/setOnChange ok"))
end

--@api: LColorPicker:setColorMode.3
do

    local cp = lurek.ui.newColorPicker()
    cp:setColor(0.2, 0.8, 0.4, 1.0)
    cp:setColorMode("hsv")
    cp:setOnChange(function(idx) lurek.log.info(tostring("color changed") .. " " .. tostring(idx)) end)
    cp:setShowAlpha(true)
    lurek.log.info(tostring("setColor/setColorMode/setOnChange ok"))
end

--@api: LColorPicker:setColorMode.4
do

    local cp = lurek.ui.newColorPicker()
    cp:setColor(0.2, 0.8, 0.4, 1.0)
    cp:setColorMode("hsv")
    cp:setOnChange(function(idx) lurek.log.info(tostring("color changed") .. " " .. tostring(idx)) end)
    cp:setShowAlpha(true)
    lurek.log.info(tostring("setColor/setColorMode/setOnChange ok"))
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
    lurek.log.info(tostring("setShowAlpha ok; combo items cleared"))
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
    lurek.log.info(tostring("setShowAlpha ok; combo items cleared"))
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
    lurek.log.info(tostring("setShowAlpha ok; combo items cleared"))
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
    lurek.log.info(tostring("getItemCount:") .. " " .. tostring(cnt) .. " " .. tostring("getItem:") .. " " .. tostring(item) .. " " .. tostring("getSelectedIndex:") .. " " .. tostring(sel))
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
    lurek.log.info(tostring("getItemCount:") .. " " .. tostring(cnt) .. " " .. tostring("getItem:") .. " " .. tostring(item) .. " " .. tostring("getSelectedIndex:") .. " " .. tostring(sel))
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
    lurek.log.info(tostring("getItemCount:") .. " " .. tostring(cnt) .. " " .. tostring("getItem:") .. " " .. tostring(item) .. " " .. tostring("getSelectedIndex:") .. " " .. tostring(sel))
end

--@api: LComboBox:removeItem.2
do

    local cb = lurek.ui.newComboBox()
    cb:addItem("Alpha")
    cb:addItem("Beta")
    cb:setSelectedIndex(2)
    local selItem = cb:getSelectedItem()
    cb:removeItem(1)
    lurek.log.info(tostring("getSelectedItem:") .. " " .. tostring(selItem) .. " " .. tostring("removeItem ok"))
end

--@api: LComboBox:removeItem
do

    local cb = lurek.ui.newComboBox()
    cb:addItem("Alpha")
    cb:addItem("Beta")
    cb:setSelectedIndex(2)
    local selItem = cb:getSelectedItem()
    cb:removeItem(1)
    lurek.log.info(tostring("getSelectedItem:") .. " " .. tostring(selItem) .. " " .. tostring("removeItem ok"))
end

--@api: LComboBox:setSelectedIndex
do

    local cb = lurek.ui.newComboBox()
    cb:addItem("Alpha")
    cb:addItem("Beta")
    cb:setSelectedIndex(2)
    local selItem = cb:getSelectedItem()
    cb:removeItem(1)
    lurek.log.info(tostring("getSelectedItem:") .. " " .. tostring(selItem) .. " " .. tostring("removeItem ok"))
end

--@api: LDialog:addButton
do

    local dlg = lurek.ui.newDialog("Info")
    local btnIdx = dlg:addButton("OK")
    local content = dlg:getContent()
    dlg:open()
    dlg:close()
    lurek.log.info(tostring("addButton:") .. " " .. tostring(btnIdx) .. " " .. tostring("close ok"))
end

--@api: LDialog:close
do

    local dlg = lurek.ui.newDialog("Info")
    local btnIdx = dlg:addButton("OK")
    local content = dlg:getContent()
    dlg:open()
    dlg:close()
    lurek.log.info(tostring("addButton:") .. " " .. tostring(btnIdx) .. " " .. tostring("close ok"))
end

--@api: LDialog:getContent
do

    local dlg = lurek.ui.newDialog("Info")
    local btnIdx = dlg:addButton("OK")
    local content = dlg:getContent()
    dlg:open()
    dlg:close()
    lurek.log.info(tostring("addButton:") .. " " .. tostring(btnIdx) .. " " .. tostring("close ok"))
end

--@api: LDialog:getTitle
do

    local dlg = lurek.ui.newDialog("My Dialog")
    local title = dlg:getTitle()
    dlg:setModal(true)
    local modal = dlg:isModal()
    local open = dlg:isOpen()
    lurek.log.info(tostring("title:") .. " " .. tostring(title) .. " " .. tostring("isModal:") .. " " .. tostring(modal) .. " " .. tostring("isOpen:") .. " " .. tostring(open))
end

--@api: LDialog:isModal
do

    local dlg = lurek.ui.newDialog("My Dialog")
    local title = dlg:getTitle()
    dlg:setModal(true)
    local modal = dlg:isModal()
    local open = dlg:isOpen()
    lurek.log.info(tostring("title:") .. " " .. tostring(title) .. " " .. tostring("isModal:") .. " " .. tostring(modal) .. " " .. tostring("isOpen:") .. " " .. tostring(open))
end

--@api: LDialog:isOpen
do

    local dlg = lurek.ui.newDialog("My Dialog")
    local title = dlg:getTitle()
    dlg:setModal(true)
    local modal = dlg:isModal()
    local open = dlg:isOpen()
    lurek.log.info(tostring("title:") .. " " .. tostring(title) .. " " .. tostring("isModal:") .. " " .. tostring(modal) .. " " .. tostring("isOpen:") .. " " .. tostring(open))
end

--@api: LDialog:open
do

    local dlg = lurek.ui.newDialog("Setup")
    dlg:setModal(false)
    dlg:setContent(nil)
    dlg:open()
    dlg:close()
    lurek.log.info(tostring("open/setContent/setModal ok"))
end

--@api: LDialog:setContent
do

    local dlg = lurek.ui.newDialog("Setup")
    dlg:setModal(false)
    dlg:setContent(nil)
    dlg:open()
    dlg:close()
    lurek.log.info(tostring("open/setContent/setModal ok"))
end

--@api: LDialog:setModal
do

    local dlg = lurek.ui.newDialog("Setup")
    dlg:setModal(false)
    dlg:setContent(nil)
    dlg:open()
    dlg:close()
    lurek.log.info(tostring("open/setContent/setModal ok"))
end

--@api: LDialog:setOnClose
do

    local dlg = lurek.ui.newDialog("Old")
    dlg:setTitle("New Title")
    dlg:setOnClose(function(idx) lurek.log.info(tostring("closed") .. " " .. tostring(idx)) end)
    local dp = lurek.ui.newDockPanel()
    local btn = lurek.ui.newButton("Side")
    lurek.log.info(tostring("setTitle/setOnClose ok; DockPanel created"))
end

--@api: LDialog:setTitle
do

    local dlg = lurek.ui.newDialog("Old")
    dlg:setTitle("New Title")
    dlg:setOnClose(function(idx) lurek.log.info(tostring("closed") .. " " .. tostring(idx)) end)
    local dp = lurek.ui.newDockPanel()
    local btn = lurek.ui.newButton("Side")
    lurek.log.info(tostring("setTitle/setOnClose ok; DockPanel created"))
end

--@api: LDialog:setTitle.2
do

    local dlg = lurek.ui.newDialog("Old")
    dlg:setTitle("New Title")
    dlg:setOnClose(function(idx) lurek.log.info(tostring("closed") .. " " .. tostring(idx)) end)
    local dp = lurek.ui.newDockPanel()
    local btn = lurek.ui.newButton("Side")
    lurek.log.info(tostring("setTitle/setOnClose ok; DockPanel created"))
end

--@api: LDialog:addAction
do

    local dlg = lurek.ui.newDialog("Actions")
    local idx = dlg:addAction("Apply", nil, "default", true)
    dlg:setDefaultAction(idx)
    lurek.log.info(tostring("addAction/default:") .. " " .. tostring(idx) .. " " .. tostring(dlg:getDefaultAction()))
    lurek.log.info(tostring("dialog title = " .. dlg:getTitle()))
end

--@api: LDialog:centerInViewport
do

    local dlg = lurek.ui.newDialog("Center")
    dlg:setCenterOnOpen(false)
    dlg:centerInViewport()
    lurek.log.info(tostring("centerInViewport ok"))
    lurek.log.info(tostring("dialog title = " .. dlg:getTitle()))
end

--@api: LDialog:getCancelAction
do

    local dlg = lurek.ui.newDialog("Cancel")
    local idx = dlg:addAction("Cancel", nil, "cancel", true)
    dlg:setCancelAction(idx)
    lurek.log.info(tostring("cancel action:") .. " " .. tostring(dlg:getCancelAction()))
    lurek.log.info(tostring("dialog title = " .. dlg:getTitle()))
end

--@api: LDialog:getDefaultAction
do

    local dlg = lurek.ui.newDialog("Default")
    local idx = dlg:addAction("Confirm", nil, "default", true)
    dlg:setDefaultAction(idx)
    lurek.log.info(tostring("default action:") .. " " .. tostring(dlg:getDefaultAction()))
    lurek.log.info(tostring("dialog title = " .. dlg:getTitle()))
end

--@api: LDialog:setDefaultAction
do

    local dlg = lurek.ui.newDialog("Default Setter")
    local idx = dlg:addAction("Confirm", nil, "default", true)
    dlg:setDefaultAction(idx)
    lurek.log.info(tostring("set default action:") .. " " .. tostring(idx))
    lurek.log.info(tostring("dialog title = " .. dlg:getTitle()))
end

--@api: LDialog:getCenterOnOpen
do

    local dlg = lurek.ui.newDialog("Center Flag")
    dlg:setCenterOnOpen(false)
    lurek.log.info(tostring("centerOnOpen:") .. " " .. tostring(dlg:getCenterOnOpen()))
    lurek.log.info(tostring("dialog title = " .. dlg:getTitle()))
    lurek.log.info(tostring("dialog open = " .. tostring(dlg:isOpen())))
end

--@api: LDialog:getDismissOnOutsideClick
do

    local dlg = lurek.ui.newDialog("Dismiss Flag")
    dlg:setDismissOnOutsideClick(true)
    lurek.log.info(tostring("dismissOnOutsideClick:") .. " " .. tostring(dlg:getDismissOnOutsideClick()))
    lurek.log.info(tostring("dialog title = " .. dlg:getTitle()))
    lurek.log.info(tostring("dialog open = " .. tostring(dlg:isOpen())))
end

--@api: LDialog:getFooter
do

    local dlg = lurek.ui.newDialog("Footer")
    local footer = lurek.ui.newPanel()
    dlg:setFooter(footer)
    lurek.log.info(tostring("footer idx:") .. " " .. tostring(dlg:getFooter()))
    lurek.log.info(tostring("dialog title = " .. dlg:getTitle()))
end

--@api: LDialog:getMaxSize
do

    local dlg = lurek.ui.newDialog("Max")
    dlg:setMaxSize(420, 260)
    local w, h = dlg:getMaxSize()
    lurek.log.info(tostring("max size:") .. " " .. tostring(w) .. " " .. tostring(h))
    lurek.log.info(tostring("dialog title = " .. dlg:getTitle()))
end

--@api: LDialog:getMinSize
do

    local dlg = lurek.ui.newDialog("Min")
    dlg:setMinSize(220, 140)
    local w, h = dlg:getMinSize()
    lurek.log.info(tostring("min size:") .. " " .. tostring(w) .. " " .. tostring(h))
    lurek.log.info(tostring("dialog title = " .. dlg:getTitle()))
end

--@api: LDialog:isCloseable
do

    local dlg = lurek.ui.newDialog("Closeable")
    lurek.log.info(tostring("isCloseable:") .. " " .. tostring(dlg:isCloseable()))
    lurek.log.info(tostring("dialog title = " .. dlg:getTitle()))
    lurek.log.info(tostring("dialog open = " .. tostring(dlg:isOpen())))
    lurek.log.info(tostring("dialog modal = " .. tostring(dlg:isModal())))
end

--@api: LDialog:isDraggable
do

    local dlg = lurek.ui.newDialog("Draggable")
    lurek.log.info(tostring("isDraggable:") .. " " .. tostring(dlg:isDraggable()))
    lurek.log.info(tostring("dialog title = " .. dlg:getTitle()))
    lurek.log.info(tostring("dialog open = " .. tostring(dlg:isOpen())))
    lurek.log.info(tostring("dialog modal = " .. tostring(dlg:isModal())))
end

--@api: LDialog:isResizable
do

    local dlg = lurek.ui.newDialog("Resizable")
    lurek.log.info(tostring("isResizable:") .. " " .. tostring(dlg:isResizable()))
    lurek.log.info(tostring("dialog title = " .. dlg:getTitle()))
    lurek.log.info(tostring("dialog open = " .. tostring(dlg:isOpen())))
    lurek.log.info(tostring("dialog modal = " .. tostring(dlg:isModal())))
end

--@api: LDialog:setCloseable
do

    local dlg = lurek.ui.newDialog("Closeable Setter")
    dlg:setCloseable(false)
    lurek.log.info(tostring("setCloseable:") .. " " .. tostring(false))
    lurek.log.info(tostring("dialog title = " .. dlg:getTitle()))
    lurek.log.info(tostring("dialog open = " .. tostring(dlg:isOpen())))
end

--@api: LDialog:setDraggable
do

    local dlg = lurek.ui.newDialog("Draggable Setter")
    dlg:setDraggable(true)
    lurek.log.info(tostring("setDraggable:") .. " " .. tostring(true))
    lurek.log.info(tostring("dialog title = " .. dlg:getTitle()))
    lurek.log.info(tostring("dialog open = " .. tostring(dlg:isOpen())))
end

--@api: LDialog:setResizable
do

    local dlg = lurek.ui.newDialog("Resizable Setter")
    dlg:setResizable(true)
    lurek.log.info(tostring("setResizable:") .. " " .. tostring(true))
    lurek.log.info(tostring("dialog title = " .. dlg:getTitle()))
    lurek.log.info(tostring("dialog open = " .. tostring(dlg:isOpen())))
end

--@api: LDialog:setFooter
do

    local dlg = lurek.ui.newDialog("Footer Setter")
    local footer = lurek.ui.newLayout("horizontal")
    dlg:setFooter(footer)
    lurek.log.info(tostring("setFooter:") .. " " .. tostring(dlg:getFooter()))
    lurek.log.info(tostring("dialog title = " .. dlg:getTitle()))
end

--@api: LDialog:setMaxSize
do

    local dlg = lurek.ui.newDialog("Max Size")
    dlg:setMaxSize(480, 320)
    lurek.log.info(tostring("setMaxSize:") .. " " .. tostring(480) .. " " .. tostring(320))
    lurek.log.info(tostring("dialog title = " .. dlg:getTitle()))
    lurek.log.info(tostring("dialog open = " .. tostring(dlg:isOpen())))
end

--@api: LDialog:setMinSize
do

    local dlg = lurek.ui.newDialog("Min Size")
    dlg:setMinSize(200, 120)
    lurek.log.info(tostring("setMinSize:") .. " " .. tostring(200) .. " " .. tostring(120))
    lurek.log.info(tostring("dialog title = " .. dlg:getTitle()))
    lurek.log.info(tostring("dialog open = " .. tostring(dlg:isOpen())))
end

--@api: LDialog:setDismissOnOutsideClick
do

    local dlg = lurek.ui.newDialog("Dismiss")
    dlg:setModal(false)
    dlg:setDismissOnOutsideClick(true)
    lurek.log.info(tostring("dismiss setter ok"))
    lurek.log.info(tostring("dialog title = " .. dlg:getTitle()))
end

--@api: LDialog:setCenterOnOpen
do

    local dlg = lurek.ui.newDialog("Center Setter")
    dlg:setCenterOnOpen(false)
    lurek.log.info(tostring("setCenterOnOpen ok"))
    lurek.log.info(tostring("dialog title = " .. dlg:getTitle()))
    lurek.log.info(tostring("dialog open = " .. tostring(dlg:isOpen())))
end

--@api: LDialog:setCancelAction
do

    local dlg = lurek.ui.newDialog("Cancel Setter")
    local idx = dlg:addAction("Abort", nil, "cancel", true)
    dlg:setCancelAction(idx)
    lurek.log.info(tostring("setCancelAction:") .. " " .. tostring(dlg:getCancelAction()))
    lurek.log.info(tostring("dialog title = " .. dlg:getTitle()))
end

--@api: LDockPanel:getSplitSize.2
do

    local dp = lurek.ui.newDockPanel()
    local cnt = dp:getDockedCount()
    dp:setSplitSize("left", 200)
    local sz = dp:getSplitSize("left")
    lurek.log.info(tostring("getDockedCount:") .. " " .. tostring(cnt) .. " " .. tostring("splitSize:") .. " " .. tostring(sz))
end

--@api: LDockPanel:getSplitSize.3
do

    local dp = lurek.ui.newDockPanel()
    local cnt = dp:getDockedCount()
    dp:setSplitSize("left", 200)
    local sz = dp:getSplitSize("left")
    lurek.log.info(tostring("getDockedCount:") .. " " .. tostring(cnt) .. " " .. tostring("splitSize:") .. " " .. tostring(sz))
end

--@api: LDockPanel:getSplitSize.4
do

    local dp = lurek.ui.newDockPanel()
    local cnt = dp:getDockedCount()
    dp:setSplitSize("left", 200)
    local sz = dp:getSplitSize("left")
    lurek.log.info(tostring("getDockedCount:") .. " " .. tostring(cnt) .. " " .. tostring("splitSize:") .. " " .. tostring(sz))
end

--@api: LDockPanel:undock.2
do

    local dp = lurek.ui.newDockPanel()
    local dockedCount = dp:getDockedCount()
    dp:undock(0)
    local tbl = lurek.ui.newTable()
    lurek.log.info(tostring("undock ok (dockedCount was:") .. " " .. tostring(dockedCount) .. " " .. tostring("); newTable ok"))
end

--@api: LDockPanel:undock.3
do

    local dp = lurek.ui.newDockPanel()
    local dockedCount = dp:getDockedCount()
    dp:undock(0)
    local tbl = lurek.ui.newTable()
    lurek.log.info(tostring("undock ok (dockedCount was:") .. " " .. tostring(dockedCount) .. " " .. tostring("); newTable ok"))
end

--@api: LDockPanel:undock.4
do

    local dp = lurek.ui.newDockPanel()
    local dockedCount = dp:getDockedCount()
    dp:undock(0)
    local tbl = lurek.ui.newTable()
    lurek.log.info(tostring("undock ok (dockedCount was:") .. " " .. tostring(dockedCount) .. " " .. tostring("); newTable ok"))
end

--@api: LTable:addColumn
do

    local tbl = lurek.ui.newTable()
    tbl:addColumn("Name", 100)
    tbl:addColumn("Value", 80)
    tbl:addRow({"Alice", "42"})
    tbl:addRow({"Bob", "99"})
    local cell = tbl:getCell(1, 1)
    lurek.log.info(tostring("addColumn/addRow/getCell ok, cell:") .. " " .. tostring(cell))
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
    lurek.log.info(tostring("cols:") .. " " .. tostring(cols) .. " " .. tostring("rows:") .. " " .. tostring(rows) .. " " .. tostring("selectedRow:") .. " " .. tostring(sel))
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
    lurek.log.info(tostring("cols:") .. " " .. tostring(cols) .. " " .. tostring("rows:") .. " " .. tostring(rows) .. " " .. tostring("selectedRow:") .. " " .. tostring(sel))
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
    lurek.log.info(tostring("cols:") .. " " .. tostring(cols) .. " " .. tostring("rows:") .. " " .. tostring(rows) .. " " .. tostring("selectedRow:") .. " " .. tostring(sel))
end

--@api: LGuiTable:isSortable
do

    local tbl = lurek.ui.newTable()
    tbl:addColumn("ID")
    tbl:addRow({"1"})
    tbl:setSortable(true)
    tbl:setCell(1, 1, "changed")
    tbl:setOnSelect(function(idx) lurek.log.info(tostring("row selected") .. " " .. tostring(idx)) end)
    lurek.log.info(tostring("isSortable/setCell/setOnSelect ok"))
end

--@api: LTable:setCell
do

    local tbl = lurek.ui.newTable()
    tbl:addColumn("ID")
    tbl:addRow({"1"})
    tbl:setSortable(true)
    tbl:setCell(1, 1, "changed")
    tbl:setOnSelect(function(idx) lurek.log.info(tostring("row selected") .. " " .. tostring(idx)) end)
    lurek.log.info(tostring("isSortable/setCell/setOnSelect ok"))
end

--@api: LGuiTable:setOnSelect
do

    local tbl = lurek.ui.newTable()
    tbl:addColumn("ID")
    tbl:addRow({"1"})
    tbl:setSortable(true)
    tbl:setCell(1, 1, "changed")
    tbl:setOnSelect(function(idx) lurek.log.info(tostring("row selected") .. " " .. tostring(idx)) end)
    lurek.log.info(tostring("isSortable/setCell/setOnSelect ok"))
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
    lurek.log.info(tostring("setSelectedRow:") .. " " .. tostring(sel) .. " " .. tostring("setSortable ok, win title:") .. " " .. tostring(title))
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
    lurek.log.info(tostring("sorted first row:") .. " " .. tostring(tbl:getCell(1, 1)))
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
    lurek.log.info(tostring("setSelectedRow:") .. " " .. tostring(sel) .. " " .. tostring("setSortable ok, win title:") .. " " .. tostring(title))
end

--@api: LGuiWindow:isCloseable
do

    local win = lurek.ui.newWindow("Test Win")
    local closeable = win:isCloseable()
    local draggable = win:isDraggable()
    local resizable = win:isResizable()
    lurek.log.info(tostring("isCloseable:") .. " " .. tostring(closeable) .. " " .. tostring("isDraggable:") .. " " .. tostring(draggable) .. " " .. tostring("isResizable:") .. " " .. tostring(resizable))
end

--@api: LGuiWindow:isDraggable
do

    local win = lurek.ui.newWindow("Test Win")
    local closeable = win:isCloseable()
    local draggable = win:isDraggable()
    local resizable = win:isResizable()
    lurek.log.info(tostring("isCloseable:") .. " " .. tostring(closeable) .. " " .. tostring("isDraggable:") .. " " .. tostring(draggable) .. " " .. tostring("isResizable:") .. " " .. tostring(resizable))
end

--@api: LGuiWindow:isResizable
do

    local win = lurek.ui.newWindow("Test Win")
    local closeable = win:isCloseable()
    local draggable = win:isDraggable()
    local resizable = win:isResizable()
    lurek.log.info(tostring("isCloseable:") .. " " .. tostring(closeable) .. " " .. tostring("isDraggable:") .. " " .. tostring(draggable) .. " " .. tostring("isResizable:") .. " " .. tostring(resizable))
end

--@api: LGuiWindow:setCloseable
do

    local win = lurek.ui.newWindow("Config")
    win:setCloseable(true)
    win:setDraggable(true)
    win:setOnClose(function(idx) lurek.log.info(tostring("window closed") .. " " .. tostring(idx)) end)
    lurek.log.info(tostring("setCloseable/setDraggable/setOnClose ok"))
end

--@api: LGuiWindow:setDraggable
do

    local win = lurek.ui.newWindow("Config")
    win:setCloseable(true)
    win:setDraggable(true)
    win:setOnClose(function(idx) lurek.log.info(tostring("window closed") .. " " .. tostring(idx)) end)
    lurek.log.info(tostring("setCloseable/setDraggable/setOnClose ok"))
end

--@api: LGuiWindow:setOnClose
do

    local win = lurek.ui.newWindow("Config")
    win:setCloseable(true)
    win:setDraggable(true)
    win:setOnClose(function(idx) lurek.log.info(tostring("window closed") .. " " .. tostring(idx)) end)
    lurek.log.info(tostring("setCloseable/setDraggable/setOnClose ok"))
end

--@api: LGuiWindow:setResizable
do

    local win = lurek.ui.newWindow("Old")
    win:setResizable(false)
    win:setTitle("New Title")
    local iw = lurek.ui.newImageWidget()
    local mode = iw:getScaleMode()
    lurek.log.info(tostring("setResizable/setTitle ok; scaleMode:") .. " " .. tostring(mode))
end

--@api: LGuiWindow:setTitle
do

    local win = lurek.ui.newWindow("Old")
    win:setResizable(false)
    win:setTitle("New Title")
    local iw = lurek.ui.newImageWidget()
    local mode = iw:getScaleMode()
    lurek.log.info(tostring("setResizable/setTitle ok; scaleMode:") .. " " .. tostring(mode))
end

--@api: LWindow:setResizable
do

    local win = lurek.ui.newWindow("Old")
    win:setResizable(false)
    win:setTitle("New Title")
    local iw = lurek.ui.newImageWidget()
    local mode = iw:getScaleMode()
    lurek.log.info(tostring("setResizable/setTitle ok; scaleMode:") .. " " .. tostring(mode))
end

--@api: LImageWidget:scaleMode
do

    local iw = lurek.ui.newImageWidget()
    iw:setTint(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = iw:getTint()
    iw:setScaleMode("fit")
    lurek.log.info(tostring("tint:") .. " " .. tostring(r) .. " " .. tostring(g) .. " " .. tostring(b) .. " " .. tostring(a) .. " " .. tostring("scaleMode: fit"))
end

--@api: LImageWidget:setScaleMode.2
do

    local iw = lurek.ui.newImageWidget()
    iw:setTint(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = iw:getTint()
    iw:setScaleMode("fit")
    lurek.log.info(tostring("tint:") .. " " .. tostring(r) .. " " .. tostring(g) .. " " .. tostring(b) .. " " .. tostring(a) .. " " .. tostring("scaleMode: fit"))
end

--@api: LImageWidget:setScaleMode.3
do

    local iw = lurek.ui.newImageWidget()
    iw:setTint(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = iw:getTint()
    iw:setScaleMode("fit")
    lurek.log.info(tostring("tint:") .. " " .. tostring(r) .. " " .. tostring(g) .. " " .. tostring(b) .. " " .. tostring(a) .. " " .. tostring("scaleMode: fit"))
end

--@api: LLabel:getText
do

    local lbl = lurek.ui.newLabel("Hello")
    lbl:setText("World")
    local layout = lurek.ui.newLayout("horizontal")
    local align = layout:getAlign()
    lurek.log.info(tostring("label text:") .. " " .. tostring(lbl:getText()) .. " " .. tostring("layout align:") .. " " .. tostring(align))
end

--@api: LLabel:setText
do

    local lbl = lurek.ui.newLabel("Hello")
    lbl:setText("World")
    local layout = lurek.ui.newLayout("horizontal")
    local align = layout:getAlign()
    lurek.log.info(tostring("label text:") .. " " .. tostring(lbl:getText()) .. " " .. tostring("layout align:") .. " " .. tostring(align))
end

--@api: LLabel:setText.2
do

    local lbl = lurek.ui.newLabel("Hello")
    lbl:setText("World")
    local layout = lurek.ui.newLayout("horizontal")
    local align = layout:getAlign()
    lurek.log.info(tostring("label text:") .. " " .. tostring(lbl:getText()) .. " " .. tostring("layout align:") .. " " .. tostring(align))
end

--@api: LLayout:getDirection
do

    local layout = lurek.ui.newLayout("vertical")
    local dir = layout:getDirection()
    local justify = layout:getJustify()
    local spacing = layout:getSpacing()
    lurek.log.info(tostring("direction:") .. " " .. tostring(dir) .. " " .. tostring("justify:") .. " " .. tostring(justify) .. " " .. tostring("spacing:") .. " " .. tostring(spacing))
end

--@api: LLayout:getSpacing.2
do

    local layout = lurek.ui.newLayout("vertical")
    local dir = layout:getDirection()
    local justify = layout:getJustify()
    local spacing = layout:getSpacing()
    lurek.log.info(tostring("direction:") .. " " .. tostring(dir) .. " " .. tostring("justify:") .. " " .. tostring(justify) .. " " .. tostring("spacing:") .. " " .. tostring(spacing))
end

--@api: LLayout:getSpacing
do

    local layout = lurek.ui.newLayout("vertical")
    local dir = layout:getDirection()
    local justify = layout:getJustify()
    local spacing = layout:getSpacing()
    lurek.log.info(tostring("direction:") .. " " .. tostring(dir) .. " " .. tostring("justify:") .. " " .. tostring(justify) .. " " .. tostring("spacing:") .. " " .. tostring(spacing))
end

--@api: LLayout:setColumns.2
do

    local layout = lurek.ui.newLayout("grid")
    local wrap = layout:getWrap()
    layout:setAlign("center")
    layout:setColumns(3)
    lurek.log.info(tostring("getWrap:") .. " " .. tostring(wrap) .. " " .. tostring("setAlign: center, setColumns: 3 ok"))
end

--@api: LLayout:setColumns.3
do

    local layout = lurek.ui.newLayout("grid")
    local wrap = layout:getWrap()
    layout:setAlign("center")
    layout:setColumns(3)
    lurek.log.info(tostring("getWrap:") .. " " .. tostring(wrap) .. " " .. tostring("setAlign: center, setColumns: 3 ok"))
end

--@api: LLayout:setColumns.4
do

    local layout = lurek.ui.newLayout("grid")
    local wrap = layout:getWrap()
    layout:setAlign("center")
    layout:setColumns(3)
    lurek.log.info(tostring("getWrap:") .. " " .. tostring(wrap) .. " " .. tostring("setAlign: center, setColumns: 3 ok"))
end

--@api: LLayout:setSpacing.2
do

    local layout = lurek.ui.newLayout("horizontal")
    layout:setDirection("vertical")
    layout:setJustify("center")
    layout:setSpacing(8)
    lurek.log.info(tostring("setDirection/setJustify/setSpacing ok"))
end

--@api: LLayout:setSpacing.3
do

    local layout = lurek.ui.newLayout("horizontal")
    layout:setDirection("vertical")
    layout:setJustify("center")
    layout:setSpacing(8)
    lurek.log.info(tostring("setDirection/setJustify/setSpacing ok"))
end

--@api: LLayout:setSpacing
do

    local layout = lurek.ui.newLayout("horizontal")
    layout:setDirection("vertical")
    layout:setJustify("center")
    layout:setSpacing(8)
    lurek.log.info(tostring("setDirection/setJustify/setSpacing ok"))
end

--@api: LLayout:setWrap.2
do

    local layout = lurek.ui.newLayout("horizontal")
    layout:setWrap(true)
    lurek.log.info(tostring("setWrap ok"))
    lurek.log.info(tostring("layout direction = " .. layout:getDirection()))
    lurek.log.info(tostring("layout spacing = " .. layout:getSpacing()))
end

--@api: LLayout:setWrap.3
do

    local layout = lurek.ui.newLayout("horizontal")
    layout:setWrap(true)
    lurek.log.info(tostring("setWrap ok"))
    lurek.log.info(tostring("layout direction = " .. layout:getDirection()))
    lurek.log.info(tostring("layout spacing = " .. layout:getSpacing()))
end

--@api: LList:clearItems
do

    local lb = lurek.ui.newList()
    lb:addItem("Apple")
    lb:addItem("Banana")
    lb:addItem("Cherry")
    local item = lb:getItem(2)
    lb:clearItems()
    lurek.log.info(tostring("addItem/clearItems/getItem ok, item:") .. " " .. tostring(item))
end

--@api: LList:clearItems.2
do

    local lb = lurek.ui.newList()
    lb:addItem("Apple")
    lb:addItem("Banana")
    lb:addItem("Cherry")
    local item = lb:getItem(2)
    lb:clearItems()
    lurek.log.info(tostring("addItem/clearItems/getItem ok, item:") .. " " .. tostring(item))
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
    lurek.log.info(tostring("count:") .. " " .. tostring(cnt) .. " " .. tostring("selectedIndex:") .. " " .. tostring(sel) .. " " .. tostring("removeItem ok"))
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
    lurek.log.info(tostring("count:") .. " " .. tostring(cnt) .. " " .. tostring("selectedIndex:") .. " " .. tostring(sel) .. " " .. tostring("removeItem ok"))
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
    lurek.log.info(tostring("count:") .. " " .. tostring(cnt) .. " " .. tostring("selectedIndex:") .. " " .. tostring(sel) .. " " .. tostring("removeItem ok"))
end

--@api: LList:setItemHeight
do

    local lb = lurek.ui.newList()
    lb:setItemHeight(20)
    lb:addItem("Item")
    lb:setSelectedIndex(1)
    local mb = lurek.ui.newMenuBar()
    local mi = lurek.ui.newMenuItem("File")
    local idx = mb:addMenu(mi)
    lurek.log.info(tostring("setItemHeight ok; addMenu idx:") .. " " .. tostring(idx))
end

--@api: LList:setSelectedIndex
do

    local lb = lurek.ui.newList()
    lb:setItemHeight(20)
    lb:addItem("Item")
    lb:setSelectedIndex(1)
    local mb = lurek.ui.newMenuBar()
    local mi = lurek.ui.newMenuItem("File")
    local idx = mb:addMenu(mi)
    lurek.log.info(tostring("setItemHeight ok; addMenu idx:") .. " " .. tostring(idx))
end

--@api: LList:setSelectedIndex.2
do

    local lb = lurek.ui.newList()
    lb:setItemHeight(20)
    lb:addItem("Item")
    lb:setSelectedIndex(1)
    local mb = lurek.ui.newMenuBar()
    local mi = lurek.ui.newMenuItem("File")
    local idx = mb:addMenu(mi)
    lurek.log.info(tostring("setItemHeight ok; addMenu idx:") .. " " .. tostring(idx))
end

--@api: LMenuBar:removeMenu.2
do

    local mb = lurek.ui.newMenuBar()
    local mi1 = lurek.ui.newMenuItem("Edit")
    local mi2 = lurek.ui.newMenuItem("View")
    mb:addMenu(mi1)
    mb:addMenu(mi2)
    local cnt = mb:getMenuCount()
    local menus = mb:getMenus()
    mb:removeMenu(1)
    lurek.log.info(tostring("menuCount:") .. " " .. tostring(cnt) .. " " .. tostring("getMenus ok; removeMenu ok"))
end

--@api: LMenuBar:removeMenu.3
do

    local mb = lurek.ui.newMenuBar()
    local mi1 = lurek.ui.newMenuItem("Edit")
    local mi2 = lurek.ui.newMenuItem("View")
    mb:addMenu(mi1)
    mb:addMenu(mi2)
    local cnt = mb:getMenuCount()
    local menus = mb:getMenus()
    mb:removeMenu(1)
    lurek.log.info(tostring("menuCount:") .. " " .. tostring(cnt) .. " " .. tostring("getMenus ok; removeMenu ok"))
end

--@api: LMenuBar:removeMenu.4
do

    local mb = lurek.ui.newMenuBar()
    local mi1 = lurek.ui.newMenuItem("Edit")
    local mi2 = lurek.ui.newMenuItem("View")
    mb:addMenu(mi1)
    mb:addMenu(mi2)
    local cnt = mb:getMenuCount()
    local menus = mb:getMenus()
    mb:removeMenu(1)
    lurek.log.info(tostring("menuCount:") .. " " .. tostring(cnt) .. " " .. tostring("getMenus ok; removeMenu ok"))
end

--@api: LMenuItem:getShortcut.2
do

    local mi = lurek.ui.newMenuItem("Tools")
    local sub1 = lurek.ui.newMenuItem("Options")
    mi:addSubItem(sub1)
    local subs = mi:getSubItems()
    mi:setShortcut("Ctrl+T")
    local sc = mi:getShortcut()
    lurek.log.info(tostring("addSubItem ok; getSubItems:") .. " " .. tostring(type(subs)) .. " " .. tostring("shortcut:") .. " " .. tostring(sc))
end

--@api: LMenuItem:getShortcut
do

    local mi = lurek.ui.newMenuItem("Tools")
    local sub1 = lurek.ui.newMenuItem("Options")
    mi:addSubItem(sub1)
    local subs = mi:getSubItems()
    mi:setShortcut("Ctrl+T")
    local sc = mi:getShortcut()
    lurek.log.info(tostring("addSubItem ok; getSubItems:") .. " " .. tostring(type(subs)) .. " " .. tostring("shortcut:") .. " " .. tostring(sc))
end

--@api: LMenuItem:getShortcut.3
do

    local mi = lurek.ui.newMenuItem("Tools")
    local sub1 = lurek.ui.newMenuItem("Options")
    mi:addSubItem(sub1)
    local subs = mi:getSubItems()
    mi:setShortcut("Ctrl+T")
    local sc = mi:getShortcut()
    lurek.log.info(tostring("addSubItem ok; getSubItems:") .. " " .. tostring(type(subs)) .. " " .. tostring("shortcut:") .. " " .. tostring(sc))
end

--@api: LMenuItem:getText
do

    local mi = lurek.ui.newMenuItem("Enable")
    local t = mi:getText()
    mi:setChecked(true)
    local checked = mi:isChecked()
    mi:setChecked(false)
    lurek.log.info(tostring("getText:") .. " " .. tostring(t) .. " " .. tostring("isChecked:") .. " " .. tostring(mi:isChecked()) .. " " .. tostring("setChecked ok"))
end

--@api: LMenuItem:setChecked.2
do

    local mi = lurek.ui.newMenuItem("Enable")
    local t = mi:getText()
    mi:setChecked(true)
    local checked = mi:isChecked()
    mi:setChecked(false)
    lurek.log.info(tostring("getText:") .. " " .. tostring(t) .. " " .. tostring("isChecked:") .. " " .. tostring(mi:isChecked()) .. " " .. tostring("setChecked ok"))
end

--@api: LMenuItem:setChecked.3
do

    local mi = lurek.ui.newMenuItem("Enable")
    local t = mi:getText()
    mi:setChecked(true)
    local checked = mi:isChecked()
    mi:setChecked(false)
    lurek.log.info(tostring("getText:") .. " " .. tostring(t) .. " " .. tostring("isChecked:") .. " " .. tostring(mi:isChecked()) .. " " .. tostring("setChecked ok"))
end

--@api: LMenuItem:setOnClick.2
do

    local mi = lurek.ui.newMenuItem("Old")
    mi:setOnClick(function(idx) lurek.log.info(tostring("menu clicked") .. " " .. tostring(idx)) end)
    mi:setShortcut("Alt+F4")
    mi:setText("New Name")
    lurek.log.info(tostring("setOnClick/setShortcut/setText ok"))
end

--@api: LMenuItem:setShortcut
do

    local mi = lurek.ui.newMenuItem("Old")
    mi:setOnClick(function(idx) lurek.log.info(tostring("menu clicked") .. " " .. tostring(idx)) end)
    mi:setShortcut("Alt+F4")
    mi:setText("New Name")
    lurek.log.info(tostring("setOnClick/setShortcut/setText ok"))
end

--@api: LMenuItem:setOnClick.3
do

    local mi = lurek.ui.newMenuItem("Old")
    mi:setOnClick(function(idx) lurek.log.info(tostring("menu clicked") .. " " .. tostring(idx)) end)
    mi:setShortcut("Alt+F4")
    mi:setText("New Name")
    lurek.log.info(tostring("setOnClick/setShortcut/setText ok"))
end

--@api: LNinePatch:getSlices.2
do

    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    local slices = np:getSlices()
    lurek.log.info(tostring("imgDims:") .. " " .. tostring(w) .. " " .. tostring(h) .. " " .. tostring("insets:") .. " " .. tostring(l) .. " " .. tostring(t) .. " " .. tostring(r) .. " " .. tostring(b) .. " " .. tostring("slices:") .. " " .. tostring(type(slices)))
end

--@api: LNinePatch:getSlices.3
do

    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    local slices = np:getSlices()
    lurek.log.info(tostring("imgDims:") .. " " .. tostring(w) .. " " .. tostring(h) .. " " .. tostring("insets:") .. " " .. tostring(l) .. " " .. tostring(t) .. " " .. tostring(r) .. " " .. tostring(b) .. " " .. tostring("slices:") .. " " .. tostring(type(slices)))
end

--@api: LNinePatch:getSlices.4
do

    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    local slices = np:getSlices()
    lurek.log.info(tostring("imgDims:") .. " " .. tostring(w) .. " " .. tostring(h) .. " " .. tostring("insets:") .. " " .. tostring(l) .. " " .. tostring(t) .. " " .. tostring(r) .. " " .. tostring(b) .. " " .. tostring("slices:") .. " " .. tostring(type(slices)))
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
    lurek.log.info(tostring("setInsets ok; panel title:") .. " " .. tostring(title))
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
    lurek.log.info(tostring("setInsets ok; panel title:") .. " " .. tostring(title))
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
    lurek.log.info(tostring("setInsets ok; panel title:") .. " " .. tostring(title))
end

--@api: LPanel:setScrollable
do

    local panel = lurek.ui.newPanel()
    panel:setScrollable(true)
    panel:setTitle("Data")
    lurek.log.info(tostring("panel scrollable ok"))
    lurek.log.info(tostring("panel children = " .. panel:getChildCount()))
end

--@api: LPanel:setTitle
do

    local panel = lurek.ui.newPanel()
    panel:setScrollable(true)
    panel:setTitle("Data")
    lurek.log.info(tostring("panel scrollable ok"))
    lurek.log.info(tostring("panel children = " .. panel:getChildCount()))
end

--@api: LProgressBar:getProgress.2
do

    local pb = lurek.ui.newProgressBar(0, 100)
    local mn = pb:getMin()
    local mx = pb:getMax()
    pb:setValue(75)
    local prog = pb:getProgress()
    lurek.log.info(tostring("min:") .. " " .. tostring(mn) .. " " .. tostring("max:") .. " " .. tostring(mx) .. " " .. tostring("progress:") .. " " .. tostring(prog))
end

--@api: LProgressBar:getProgress.3
do

    local pb = lurek.ui.newProgressBar(0, 100)
    local mn = pb:getMin()
    local mx = pb:getMax()
    pb:setValue(75)
    local prog = pb:getProgress()
    lurek.log.info(tostring("min:") .. " " .. tostring(mn) .. " " .. tostring("max:") .. " " .. tostring(mx) .. " " .. tostring("progress:") .. " " .. tostring(prog))
end

--@api: LProgressBar:getProgress.4
do

    local pb = lurek.ui.newProgressBar(0, 100)
    local mn = pb:getMin()
    local mx = pb:getMax()
    pb:setValue(75)
    local prog = pb:getProgress()
    lurek.log.info(tostring("min:") .. " " .. tostring(mn) .. " " .. tostring("max:") .. " " .. tostring(mx) .. " " .. tostring("progress:") .. " " .. tostring(prog))
end

--@api: LProgressBar:setRange.2
do

    local pb = lurek.ui.newProgressBar(0, 200)
    pb:setValue(100)
    local v = pb:getValue()
    pb:setRange(10, 90)
    pb:setValue(50)
    lurek.log.info(tostring("getValue:") .. " " .. tostring(v) .. " " .. tostring("setRange ok, setValue ok"))
end

--@api: LProgressBar:setRange.3
do

    local pb = lurek.ui.newProgressBar(0, 200)
    pb:setValue(100)
    local v = pb:getValue()
    pb:setRange(10, 90)
    pb:setValue(50)
    lurek.log.info(tostring("getValue:") .. " " .. tostring(v) .. " " .. tostring("setRange ok, setValue ok"))
end

--@api: LProgressBar:setRange.4
do

    local pb = lurek.ui.newProgressBar(0, 200)
    pb:setValue(100)
    local v = pb:getValue()
    pb:setRange(10, 90)
    pb:setValue(50)
    lurek.log.info(tostring("getValue:") .. " " .. tostring(v) .. " " .. tostring("setRange ok, setValue ok"))
end

--@api: LRadioButton:isSelected.2
do

    local rb = lurek.ui.newRadioButton("Option A", "group1")
    local grp = rb:getGroup()
    local t = rb:getText()
    local sel = rb:isSelected()
    lurek.log.info(tostring("group:") .. " " .. tostring(grp) .. " " .. tostring("text:") .. " " .. tostring(t) .. " " .. tostring("isSelected:") .. " " .. tostring(sel))
end

--@api: LRadioButton:isSelected.3
do

    local rb = lurek.ui.newRadioButton("Option A", "group1")
    local grp = rb:getGroup()
    local t = rb:getText()
    local sel = rb:isSelected()
    lurek.log.info(tostring("group:") .. " " .. tostring(grp) .. " " .. tostring("text:") .. " " .. tostring(t) .. " " .. tostring("isSelected:") .. " " .. tostring(sel))
end

--@api: LRadioButton:isSelected.4
do

    local rb = lurek.ui.newRadioButton("Option A", "group1")
    local grp = rb:getGroup()
    local t = rb:getText()
    local sel = rb:isSelected()
    lurek.log.info(tostring("group:") .. " " .. tostring(grp) .. " " .. tostring("text:") .. " " .. tostring(t) .. " " .. tostring("isSelected:") .. " " .. tostring(sel))
end

--@api: LRadioButton:setSelected.2
do

    local rb = lurek.ui.newRadioButton("B", "g1")
    rb:setGroup("g2")
    rb:setSelected(true)
    rb:setOnChange(function(idx) lurek.log.info(tostring("radio changed") .. " " .. tostring(idx)) end)
    rb:setText("New B")
    lurek.log.info(tostring("setGroup/setSelected/setOnChange/setText ok"))
end

--@api: LRadioButton:setOnChange
do

    local rb = lurek.ui.newRadioButton("B", "g1")
    rb:setGroup("g2")
    rb:setSelected(true)
    rb:setOnChange(function(idx) lurek.log.info(tostring("radio changed") .. " " .. tostring(idx)) end)
    rb:setText("New B")
    lurek.log.info(tostring("setGroup/setSelected/setOnChange/setText ok"))
end

--@api: LRadioButton:setSelected
do

    local rb = lurek.ui.newRadioButton("B", "g1")
    rb:setGroup("g2")
    rb:setSelected(true)
    rb:setOnChange(function(idx) lurek.log.info(tostring("radio changed") .. " " .. tostring(idx)) end)
    rb:setText("New B")
    lurek.log.info(tostring("setGroup/setSelected/setOnChange/setText ok"))
end

--@api: LRadioButton:setText
do

    local rb = lurek.ui.newRadioButton("original", "group_test")
    rb:setText("updated")
    lurek.log.info(tostring("LRadioButton setText:") .. " " .. tostring(rb:getText()))
    lurek.log.info(tostring("rect x = " .. select(1, rb:getRect())))
    lurek.log.info(tostring("rect y = " .. select(2, rb:getRect())))
end

--@api: LScrollBar:getContentSize
do

    local sb = lurek.ui.newScrollBar(true)
    local cs = sb:getContentSize()
    local pos = sb:getScrollPosition()
    local vs = sb:getViewSize()
    lurek.log.info(tostring("contentSize:") .. " " .. tostring(cs) .. " " .. tostring("scrollPos:") .. " " .. tostring(pos) .. " " .. tostring("viewSize:") .. " " .. tostring(vs))
end

--@api: LScrollBar:getScrollPosition
do

    local sb = lurek.ui.newScrollBar(true)
    local cs = sb:getContentSize()
    local pos = sb:getScrollPosition()
    local vs = sb:getViewSize()
    lurek.log.info(tostring("contentSize:") .. " " .. tostring(cs) .. " " .. tostring("scrollPos:") .. " " .. tostring(pos) .. " " .. tostring("viewSize:") .. " " .. tostring(vs))
end

--@api: LScrollBar:getViewSize
do

    local sb = lurek.ui.newScrollBar(true)
    local cs = sb:getContentSize()
    local pos = sb:getScrollPosition()
    local vs = sb:getViewSize()
    lurek.log.info(tostring("contentSize:") .. " " .. tostring(cs) .. " " .. tostring("scrollPos:") .. " " .. tostring(pos) .. " " .. tostring("viewSize:") .. " " .. tostring(vs))
end

--@api: LScrollBar:isVertical
do

    local sb = lurek.ui.newScrollBar(false)
    local vert = sb:isVertical()
    sb:setContentSize(500)
    sb:setOnChange(function(val) lurek.log.info(tostring("scroll:") .. " " .. tostring(val)) end)
    local cs = sb:getContentSize()
    lurek.log.info(tostring("isVertical:") .. " " .. tostring(vert) .. " " .. tostring("contentSize after set:") .. " " .. tostring(cs))
end

--@api: LScrollBar:setContentSize
do

    local sb = lurek.ui.newScrollBar(false)
    local vert = sb:isVertical()
    sb:setContentSize(500)
    sb:setOnChange(function(val) lurek.log.info(tostring("scroll:") .. " " .. tostring(val)) end)
    local cs = sb:getContentSize()
    lurek.log.info(tostring("isVertical:") .. " " .. tostring(vert) .. " " .. tostring("contentSize after set:") .. " " .. tostring(cs))
end

--@api: LScrollBar:setOnChange
do

    local sb = lurek.ui.newScrollBar(false)
    local vert = sb:isVertical()
    sb:setContentSize(500)
    sb:setOnChange(function(val) lurek.log.info(tostring("scroll:") .. " " .. tostring(val)) end)
    local cs = sb:getContentSize()
    lurek.log.info(tostring("isVertical:") .. " " .. tostring(vert) .. " " .. tostring("contentSize after set:") .. " " .. tostring(cs))
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
    lurek.log.info(tostring("scrollPos:") .. " " .. tostring(pos) .. " " .. tostring("panel contentSize:") .. " " .. tostring(cw) .. " " .. tostring(ch))
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
    lurek.log.info(tostring("scrollPos:") .. " " .. tostring(pos) .. " " .. tostring("panel contentSize:") .. " " .. tostring(cw) .. " " .. tostring(ch))
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
    lurek.log.info(tostring("scrollPos:") .. " " .. tostring(pos) .. " " .. tostring("panel contentSize:") .. " " .. tostring(cw) .. " " .. tostring(ch))
end

--@api: LScrollPanel:getMaxScroll
do

    local sp = lurek.ui.newScrollPanel()
    local mx, my = sp:getMaxScroll()
    local px, py = sp:getScrollPosition()
    local speed = sp:getScrollSpeed()
    lurek.log.info(tostring("maxScroll:") .. " " .. tostring(mx) .. " " .. tostring(my) .. " " .. tostring("scrollPos:") .. " " .. tostring(px) .. " " .. tostring(py) .. " " .. tostring("speed:") .. " " .. tostring(speed))
end

--@api: LScrollPanel:getScrollPosition
do

    local sp = lurek.ui.newScrollPanel()
    local mx, my = sp:getMaxScroll()
    local px, py = sp:getScrollPosition()
    local speed = sp:getScrollSpeed()
    lurek.log.info(tostring("maxScroll:") .. " " .. tostring(mx) .. " " .. tostring(my) .. " " .. tostring("scrollPos:") .. " " .. tostring(px) .. " " .. tostring(py) .. " " .. tostring("speed:") .. " " .. tostring(speed))
end

--@api: LScrollPanel:getScrollSpeed.2
do

    local sp = lurek.ui.newScrollPanel()
    local mx, my = sp:getMaxScroll()
    local px, py = sp:getScrollPosition()
    local speed = sp:getScrollSpeed()
    lurek.log.info(tostring("maxScroll:") .. " " .. tostring(mx) .. " " .. tostring(my) .. " " .. tostring("scrollPos:") .. " " .. tostring(px) .. " " .. tostring(py) .. " " .. tostring("speed:") .. " " .. tostring(speed))
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
    lurek.log.info(tostring("contentSize:") .. " " .. tostring(cw) .. " " .. tostring(ch) .. " " .. tostring("scrollPos:") .. " " .. tostring(px) .. " " .. tostring(py) .. " " .. tostring("speed:") .. " " .. tostring(speed))
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
    lurek.log.info(tostring("contentSize:") .. " " .. tostring(cw) .. " " .. tostring(ch) .. " " .. tostring("scrollPos:") .. " " .. tostring(px) .. " " .. tostring(py) .. " " .. tostring("speed:") .. " " .. tostring(speed))
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
    lurek.log.info(tostring("contentSize:") .. " " .. tostring(cw) .. " " .. tostring(ch) .. " " .. tostring("scrollPos:") .. " " .. tostring(px) .. " " .. tostring(py) .. " " .. tostring("speed:") .. " " .. tostring(speed))
end

--@api: LSeparator:getThickness
do

    local sep = lurek.ui.newSeparator(true)
    local vert = sep:isVertical()
    local thick = sep:getThickness()
    sep:setThickness(4)
    local t2 = sep:getThickness()
    lurek.log.info(tostring("isVertical:") .. " " .. tostring(vert) .. " " .. tostring("thickness:") .. " " .. tostring(thick) .. " " .. tostring("â†’") .. " " .. tostring(t2))
end

--@api: LSeparator:isVertical
do

    local sep = lurek.ui.newSeparator(true)
    local vert = sep:isVertical()
    local thick = sep:getThickness()
    sep:setThickness(4)
    local t2 = sep:getThickness()
    lurek.log.info(tostring("isVertical:") .. " " .. tostring(vert) .. " " .. tostring("thickness:") .. " " .. tostring(thick) .. " " .. tostring("â†’") .. " " .. tostring(t2))
end

--@api: LSeparator:setThickness
do

    local sep = lurek.ui.newSeparator(true)
    local vert = sep:isVertical()
    local thick = sep:getThickness()
    sep:setThickness(4)
    local t2 = sep:getThickness()
    lurek.log.info(tostring("isVertical:") .. " " .. tostring(vert) .. " " .. tostring("thickness:") .. " " .. tostring(thick) .. " " .. tostring("â†’") .. " " .. tostring(t2))
end

--@api: LSeparator:setVertical
do

    local sep = lurek.ui.newSeparator(false)
    sep:setVertical(true)
    local sl = lurek.ui.newSlider(0, 100)
    local mn = sl:getMin()
    local mx = sl:getMax()
    lurek.log.info(tostring("separator setVertical ok; slider min:") .. " " .. tostring(mn) .. " " .. tostring("max:") .. " " .. tostring(mx))
end

--@api: LSlider:getMax
do

    local sep = lurek.ui.newSeparator(false)
    sep:setVertical(true)
    local sl = lurek.ui.newSlider(0, 100)
    local mn = sl:getMin()
    local mx = sl:getMax()
    lurek.log.info(tostring("separator setVertical ok; slider min:") .. " " .. tostring(mn) .. " " .. tostring("max:") .. " " .. tostring(mx))
end

--@api: LSlider:getMin
do

    local sep = lurek.ui.newSeparator(false)
    sep:setVertical(true)
    local sl = lurek.ui.newSlider(0, 100)
    local mn = sl:getMin()
    local mx = sl:getMax()
    lurek.log.info(tostring("separator setVertical ok; slider min:") .. " " .. tostring(mn) .. " " .. tostring("max:") .. " " .. tostring(mx))
end

--@api: LSlider:getValue
do

    local sl = lurek.ui.newSlider(0, 50)
    sl:setRange(0, 100)
    local mx = sl:getMax()
    sl:setStep(5)
    sl:setValue(75)
    local v = sl:getValue()
    lurek.log.info(tostring("setRange max:") .. " " .. tostring(mx) .. " " .. tostring("getValue:") .. " " .. tostring(v))
end

--@api: LSlider:getValue.2
do

    local sl = lurek.ui.newSlider(0, 50)
    sl:setRange(0, 100)
    local mx = sl:getMax()
    sl:setStep(5)
    sl:setValue(75)
    local v = sl:getValue()
    lurek.log.info(tostring("setRange max:") .. " " .. tostring(mx) .. " " .. tostring("getValue:") .. " " .. tostring(v))
end

--@api: LSlider:getValue.3
do

    local sl = lurek.ui.newSlider(0, 50)
    sl:setRange(0, 100)
    local mx = sl:getMax()
    sl:setStep(5)
    sl:setValue(75)
    local v = sl:getValue()
    lurek.log.info(tostring("setRange max:") .. " " .. tostring(mx) .. " " .. tostring("getValue:") .. " " .. tostring(v))
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
    lurek.log.info(tostring("slider value:") .. " " .. tostring(v) .. " " .. tostring("spinbox after decrement:") .. " " .. tostring(sv))
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
    lurek.log.info(tostring("slider value:") .. " " .. tostring(v) .. " " .. tostring("spinbox after decrement:") .. " " .. tostring(sv))
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
    lurek.log.info(tostring("slider value:") .. " " .. tostring(v) .. " " .. tostring("spinbox after decrement:") .. " " .. tostring(sv))
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
    lurek.log.info(tostring("after increment:") .. " " .. tostring(v) .. " " .. tostring("after setRange/setStep:") .. " " .. tostring(v2))
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
    lurek.log.info(tostring("after increment:") .. " " .. tostring(v) .. " " .. tostring("after setRange/setStep:") .. " " .. tostring(v2))
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
    lurek.log.info(tostring("after increment:") .. " " .. tostring(v) .. " " .. tostring("after setRange/setStep:") .. " " .. tostring(v2))
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
    lurek.log.info(tostring("setValue: 42â†’") .. " " .. tostring(v) .. " " .. tostring("1â†’") .. " " .. tostring(v2) .. " " .. tostring("100â†’") .. " " .. tostring(v3))
end

--@api: LSplitPanel:getMinPanelSize.2
do

    local sp = lurek.ui.newSplitPanel("horizontal")
    local fc = sp:getFirstChild()
    local sc = sp:getSecondChild()
    local ori = sp:getOrientation()
    local mps = sp:getMinPanelSize()
    lurek.log.info(tostring("firstChild:") .. " " .. tostring(fc) .. " " .. tostring("secondChild:") .. " " .. tostring(sc) .. " " .. tostring("orientation:") .. " " .. tostring(ori) .. " " .. tostring("minPanel:") .. " " .. tostring(mps))
end

--@api: LSplitPanel:getMinPanelSize.3
do

    local sp = lurek.ui.newSplitPanel("horizontal")
    local fc = sp:getFirstChild()
    local sc = sp:getSecondChild()
    local ori = sp:getOrientation()
    local mps = sp:getMinPanelSize()
    lurek.log.info(tostring("firstChild:") .. " " .. tostring(fc) .. " " .. tostring("secondChild:") .. " " .. tostring(sc) .. " " .. tostring("orientation:") .. " " .. tostring(ori) .. " " .. tostring("minPanel:") .. " " .. tostring(mps))
end

--@api: LSplitPanel:getMinPanelSize.4
do

    local sp = lurek.ui.newSplitPanel("horizontal")
    local fc = sp:getFirstChild()
    local sc = sp:getSecondChild()
    local ori = sp:getOrientation()
    local mps = sp:getMinPanelSize()
    lurek.log.info(tostring("firstChild:") .. " " .. tostring(fc) .. " " .. tostring("secondChild:") .. " " .. tostring(sc) .. " " .. tostring("orientation:") .. " " .. tostring(ori) .. " " .. tostring("minPanel:") .. " " .. tostring(mps))
end

--@api: LSplitPanel:getSplitPosition.2
do

    local sp = lurek.ui.newSplitPanel("vertical")
    local lbl = lurek.ui.newLabel("left")
    local btn = lurek.ui.newButton("right")
    sp:setFirstChild(lbl)
    local fc = sp:getFirstChild()
    sp:setSecondChild(btn)
    local pos = sp:getSplitPosition()
    lurek.log.info(tostring("firstChild after set:") .. " " .. tostring(fc) .. " " .. tostring("splitPos:") .. " " .. tostring(pos))
end

--@api: LSplitPanel:getSplitPosition.3
do

    local sp = lurek.ui.newSplitPanel("vertical")
    local lbl = lurek.ui.newLabel("left")
    local btn = lurek.ui.newButton("right")
    sp:setFirstChild(lbl)
    local fc = sp:getFirstChild()
    sp:setSecondChild(btn)
    local pos = sp:getSplitPosition()
    lurek.log.info(tostring("firstChild after set:") .. " " .. tostring(fc) .. " " .. tostring("splitPos:") .. " " .. tostring(pos))
end

--@api: LSplitPanel:getSplitPosition.4
do

    local sp = lurek.ui.newSplitPanel("vertical")
    local lbl = lurek.ui.newLabel("left")
    local btn = lurek.ui.newButton("right")
    sp:setFirstChild(lbl)
    local fc = sp:getFirstChild()
    sp:setSecondChild(btn)
    local pos = sp:getSplitPosition()
    lurek.log.info(tostring("firstChild after set:") .. " " .. tostring(fc) .. " " .. tostring("splitPos:") .. " " .. tostring(pos))
end

--@api: LSplitPanel:setSecondChild.2
do

    local sp = lurek.ui.newSplitPanel("horizontal")
    sp:setOrientation("vertical")
    local ori = sp:getOrientation()
    sp:setMinPanelSize(80)
    local mps = sp:getMinPanelSize()
    local lbl = lurek.ui.newLabel("panel")
    sp:setSecondChild(lbl)
    lurek.log.info(tostring("orientation:") .. " " .. tostring(ori) .. " " .. tostring("minPanel:") .. " " .. tostring(mps))
end

--@api: LSplitPanel:setSecondChild.3
do

    local sp = lurek.ui.newSplitPanel("horizontal")
    sp:setOrientation("vertical")
    local ori = sp:getOrientation()
    sp:setMinPanelSize(80)
    local mps = sp:getMinPanelSize()
    local lbl = lurek.ui.newLabel("panel")
    sp:setSecondChild(lbl)
    lurek.log.info(tostring("orientation:") .. " " .. tostring(ori) .. " " .. tostring("minPanel:") .. " " .. tostring(mps))
end

--@api: LSplitPanel:setSecondChild.4
do

    local sp = lurek.ui.newSplitPanel("horizontal")
    sp:setOrientation("vertical")
    local ori = sp:getOrientation()
    sp:setMinPanelSize(80)
    local mps = sp:getMinPanelSize()
    local lbl = lurek.ui.newLabel("panel")
    sp:setSecondChild(lbl)
    lurek.log.info(tostring("orientation:") .. " " .. tostring(ori) .. " " .. tostring("minPanel:") .. " " .. tostring(mps))
end

--@api: LSplitPanel:getSplitPosition.5
do

    local sp = lurek.ui.newSplitPanel("horizontal")
    sp:setSplitPosition(200)
    local pos = sp:getSplitPosition()
    local sb = lurek.ui.newStatusBar()
    sb:addSection("Ready", 100)
    local cnt = sb:getSectionCount()
    lurek.log.info(tostring("splitPos:") .. " " .. tostring(pos) .. " " .. tostring("statusBar sectionCount:") .. " " .. tostring(cnt))
end

--@api: LSplitPanel:getSplitPosition.6
do

    local sp = lurek.ui.newSplitPanel("horizontal")
    sp:setSplitPosition(200)
    local pos = sp:getSplitPosition()
    local sb = lurek.ui.newStatusBar()
    sb:addSection("Ready", 100)
    local cnt = sb:getSectionCount()
    lurek.log.info(tostring("splitPos:") .. " " .. tostring(pos) .. " " .. tostring("statusBar sectionCount:") .. " " .. tostring(cnt))
end

--@api: LSplitPanel:getSplitPosition.7
do

    local sp = lurek.ui.newSplitPanel("horizontal")
    sp:setSplitPosition(200)
    local pos = sp:getSplitPosition()
    local sb = lurek.ui.newStatusBar()
    sb:addSection("Ready", 100)
    local cnt = sb:getSectionCount()
    lurek.log.info(tostring("splitPos:") .. " " .. tostring(pos) .. " " .. tostring("statusBar sectionCount:") .. " " .. tostring(cnt))
end

--@api: LStatusBar:setSectionCount
do

    local sb = lurek.ui.newStatusBar()
    sb:setSectionCount(3)
    local cnt = sb:getSectionCount()
    sb:setSectionText(1, "Line 1")
    local txt = sb:getSectionText(1)
    sb:setSectionText(2, "Col 5")
    lurek.log.info(tostring("sectionCount:") .. " " .. tostring(cnt) .. " " .. tostring("section1:") .. " " .. tostring(txt))
end

--@api: LStatusBar:setSectionText.2
do

    local sb = lurek.ui.newStatusBar()
    sb:setSectionCount(3)
    local cnt = sb:getSectionCount()
    sb:setSectionText(1, "Line 1")
    local txt = sb:getSectionText(1)
    sb:setSectionText(2, "Col 5")
    lurek.log.info(tostring("sectionCount:") .. " " .. tostring(cnt) .. " " .. tostring("section1:") .. " " .. tostring(txt))
end

--@api: LStatusBar:setSectionText.3
do

    local sb = lurek.ui.newStatusBar()
    sb:setSectionCount(3)
    local cnt = sb:getSectionCount()
    sb:setSectionText(1, "Line 1")
    local txt = sb:getSectionText(1)
    sb:setSectionText(2, "Col 5")
    lurek.log.info(tostring("sectionCount:") .. " " .. tostring(cnt) .. " " .. tostring("section1:") .. " " .. tostring(txt))
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
    lurek.log.info(tostring("sectionWidget set ok; switch isOn:") .. " " .. tostring(sw:isOn()))
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
    lurek.log.info(tostring("sectionWidget set ok; switch isOn:") .. " " .. tostring(sw:isOn()))
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
    lurek.log.info(tostring("sectionWidget set ok; switch isOn:") .. " " .. tostring(sw:isOn()))
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
    lurek.log.info(tostring("switch after toggle:") .. " " .. tostring(on) .. " " .. tostring("activeTab:") .. " " .. tostring(active))
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
    lurek.log.info(tostring("switch after toggle:") .. " " .. tostring(on) .. " " .. tostring("activeTab:") .. " " .. tostring(active))
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
    lurek.log.info(tostring("switch after toggle:") .. " " .. tostring(on) .. " " .. tostring("activeTab:") .. " " .. tostring(active))
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
    lurek.log.info(tostring("tabCount:") .. " " .. tostring(cnt) .. " " .. tostring("tab1:") .. " " .. tostring(label) .. " " .. tostring("after remove:") .. " " .. tostring(cnt2))
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
    lurek.log.info(tostring("tabCount:") .. " " .. tostring(cnt) .. " " .. tostring("tab1:") .. " " .. tostring(label) .. " " .. tostring("after remove:") .. " " .. tostring(cnt2))
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
    lurek.log.info(tostring("tabCount:") .. " " .. tostring(cnt) .. " " .. tostring("tab1:") .. " " .. tostring(label) .. " " .. tostring("after remove:") .. " " .. tostring(cnt2))
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
    lurek.log.info(tostring("setActiveTab to 2:") .. " " .. tostring(active) .. " " .. tostring("then to 1:") .. " " .. tostring(a2))
end

--@api: LTextInput:setText
do

    local ti = lurek.ui.newTextInput()
    ti:setText("hello")
    local txt = ti:getText()
    ti:setPlaceholder("type here")
    local ph = ti:getPlaceholder()
    local cur = ti:getCursorPosition()
    lurek.log.info(tostring("text:") .. " " .. tostring(txt) .. " " .. tostring("placeholder:") .. " " .. tostring(ph) .. " " .. tostring("cursor:") .. " " .. tostring(cur))
end

--@api: LTextInput:getCursorPosition.2
do

    local ti = lurek.ui.newTextInput()
    ti:setText("hello")
    local txt = ti:getText()
    ti:setPlaceholder("type here")
    local ph = ti:getPlaceholder()
    local cur = ti:getCursorPosition()
    lurek.log.info(tostring("text:") .. " " .. tostring(txt) .. " " .. tostring("placeholder:") .. " " .. tostring(ph) .. " " .. tostring("cursor:") .. " " .. tostring(cur))
end

--@api: LTextInput:getText
do

    local ti = lurek.ui.newTextInput()
    ti:setText("hello")
    local txt = ti:getText()
    ti:setPlaceholder("type here")
    local ph = ti:getPlaceholder()
    local cur = ti:getCursorPosition()
    lurek.log.info(tostring("text:") .. " " .. tostring(txt) .. " " .. tostring("placeholder:") .. " " .. tostring(ph) .. " " .. tostring("cursor:") .. " " .. tostring(cur))
end

--@api: LTextInput:isFocused
do

    local ti = lurek.ui.newTextInput()
    ti:setPlaceholder("Search...")
    local ph = ti:getPlaceholder()
    ti:setMaxLength(50)
    local focused = ti:isFocused()
    lurek.log.info(tostring("placeholder:") .. " " .. tostring(ph) .. " " .. tostring("isFocused:") .. " " .. tostring(focused))
end

--@api: LTextInput:isFocused.2
do

    local ti = lurek.ui.newTextInput()
    ti:setPlaceholder("Search...")
    local ph = ti:getPlaceholder()
    ti:setMaxLength(50)
    local focused = ti:isFocused()
    lurek.log.info(tostring("placeholder:") .. " " .. tostring(ph) .. " " .. tostring("isFocused:") .. " " .. tostring(focused))
end

--@api: LTextInput:isFocused.3
do

    local ti = lurek.ui.newTextInput()
    ti:setPlaceholder("Search...")
    local ph = ti:getPlaceholder()
    ti:setMaxLength(50)
    local focused = ti:isFocused()
    lurek.log.info(tostring("placeholder:") .. " " .. tostring(ph) .. " " .. tostring("isFocused:") .. " " .. tostring(focused))
end

--@api: LTextInput:getText.2
do

    local ti = lurek.ui.newTextInput()
    ti:setText("sample input")
    local txt = ti:getText()
    local th = lurek.ui.newTheme()
    th:setStyle("button", "normal", {bg_color = {0.2, 0.3, 0.8}})
    local t = th:type()
    lurek.log.info(tostring("text:") .. " " .. tostring(txt) .. " " .. tostring("theme type:") .. " " .. tostring(t))
end

--@api: LTheme:setStyle
do

    local ti = lurek.ui.newTextInput()
    ti:setText("sample input")
    local txt = ti:getText()
    local th = lurek.ui.newTheme()
    th:setStyle("button", "normal", {bg_color = {0.2, 0.3, 0.8}})
    local t = th:type()
    lurek.log.info(tostring("text:") .. " " .. tostring(txt) .. " " .. tostring("theme type:") .. " " .. tostring(t))
end

--@api: LTheme:type
do

    local ti = lurek.ui.newTextInput()
    ti:setText("sample input")
    local txt = ti:getText()
    local th = lurek.ui.newTheme()
    th:setStyle("button", "normal", {bg_color = {0.2, 0.3, 0.8}})
    local t = th:type()
    lurek.log.info(tostring("text:") .. " " .. tostring(txt) .. " " .. tostring("theme type:") .. " " .. tostring(t))
end

--@api: LTheme:typeOf
do

    local th = lurek.ui.newTheme()
    local ok = th:typeOf("LTheme")
    local toast = lurek.ui.newToast("Level up!", 3.0)
    local dur = toast:getDuration()
    local msg = toast:getMessage()
    lurek.log.info(tostring("theme typeOf:") .. " " .. tostring(ok) .. " " .. tostring("duration:") .. " " .. tostring(dur) .. " " .. tostring("message:") .. " " .. tostring(msg))
end

--@api: LTheme:typeOf.2
do

    local th = lurek.ui.newTheme()
    local ok = th:typeOf("LTheme")
    local toast = lurek.ui.newToast("Level up!", 3.0)
    local dur = toast:getDuration()
    local msg = toast:getMessage()
    lurek.log.info(tostring("theme typeOf:") .. " " .. tostring(ok) .. " " .. tostring("duration:") .. " " .. tostring(dur) .. " " .. tostring("message:") .. " " .. tostring(msg))
end

--@api: LTheme:typeOf.3
do

    local th = lurek.ui.newTheme()
    local ok = th:typeOf("LTheme")
    local toast = lurek.ui.newToast("Level up!", 3.0)
    local dur = toast:getDuration()
    local msg = toast:getMessage()
    lurek.log.info(tostring("theme typeOf:") .. " " .. tostring(ok) .. " " .. tostring("duration:") .. " " .. tostring(dur) .. " " .. tostring("message:") .. " " .. tostring(msg))
end

--@api: LToast:getDuration.2
do

    local toast = lurek.ui.newToast("Achievement unlocked", 2.0)
    local prog = toast:getProgress()
    local exp = toast:isExpired()
    toast:setDuration(5.0)
    local dur = toast:getDuration()
    lurek.log.info(tostring("progress:") .. " " .. tostring(prog) .. " " .. tostring("isExpired:") .. " " .. tostring(exp) .. " " .. tostring("duration:") .. " " .. tostring(dur))
end

--@api: LToast:getDuration.3
do

    local toast = lurek.ui.newToast("Achievement unlocked", 2.0)
    local prog = toast:getProgress()
    local exp = toast:isExpired()
    toast:setDuration(5.0)
    local dur = toast:getDuration()
    lurek.log.info(tostring("progress:") .. " " .. tostring(prog) .. " " .. tostring("isExpired:") .. " " .. tostring(exp) .. " " .. tostring("duration:") .. " " .. tostring(dur))
end

--@api: LToast:getDuration.4
do

    local toast = lurek.ui.newToast("Achievement unlocked", 2.0)
    local prog = toast:getProgress()
    local exp = toast:isExpired()
    toast:setDuration(5.0)
    local dur = toast:getDuration()
    lurek.log.info(tostring("progress:") .. " " .. tostring(prog) .. " " .. tostring("isExpired:") .. " " .. tostring(exp) .. " " .. tostring("duration:") .. " " .. tostring(dur))
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
    lurek.log.info(tostring("toast:") .. " " .. tostring(msg) .. " " .. tostring("toolbar buttons added ok"))
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
    lurek.log.info(tostring("toast:") .. " " .. tostring(msg) .. " " .. tostring("toolbar buttons added ok"))
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
    lurek.log.info(tostring("toast:") .. " " .. tostring(msg) .. " " .. tostring("toolbar buttons added ok"))
end

--@api: LToolbar:addSpacer
do

    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("cut", "Cut")
    tb:addSpacer(10)
    tb:addButton("paste", "Paste")
    local ori = tb:getOrientation()
    local btn = tb:getButton("cut")
    lurek.log.info(tostring("orientation:") .. " " .. tostring(ori) .. " " .. tostring("button:") .. " " .. tostring(btn))
end

--@api: LToolbar:getButton.2
do

    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("cut", "Cut")
    tb:addSpacer(10)
    tb:addButton("paste", "Paste")
    local ori = tb:getOrientation()
    local btn = tb:getButton("cut")
    lurek.log.info(tostring("orientation:") .. " " .. tostring(ori) .. " " .. tostring("button:") .. " " .. tostring(btn))
end

--@api: LToolbar:getButton.3
do

    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("cut", "Cut")
    tb:addSpacer(10)
    tb:addButton("paste", "Paste")
    local ori = tb:getOrientation()
    local btn = tb:getButton("cut")
    lurek.log.info(tostring("orientation:") .. " " .. tostring(ori) .. " " .. tostring("button:") .. " " .. tostring(btn))
end

--@api: LToolbar:setButtonEnabled.2
do

    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("bold", "Bold")
    tb:setButtonToggled("bold", true)
    local tog = tb:isButtonToggled("bold")
    tb:setButtonEnabled("bold", false)
    lurek.log.info(tostring("bold toggled:") .. " " .. tostring(tog))
end

--@api: LToolbar:setButtonEnabled.3
do

    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("bold", "Bold")
    tb:setButtonToggled("bold", true)
    local tog = tb:isButtonToggled("bold")
    tb:setButtonEnabled("bold", false)
    lurek.log.info(tostring("bold toggled:") .. " " .. tostring(tog))
end

--@api: LToolbar:setButtonEnabled.4
do

    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("bold", "Bold")
    tb:setButtonToggled("bold", true)
    local tog = tb:isButtonToggled("bold")
    tb:setButtonEnabled("bold", false)
    lurek.log.info(tostring("bold toggled:") .. " " .. tostring(tog))
end

--@api: LToolbar:getOrientation.2
do

    local tb = lurek.ui.newToolbar("horizontal")
    tb:setOrientation("vertical")
    local ori = tb:getOrientation()
    local tp = lurek.ui.newTooltipPanel("Hover help")
    local delay = tp:getDelay()
    local target = tp:getTarget()
    lurek.log.info(tostring("orientation:") .. " " .. tostring(ori) .. " " .. tostring("delay:") .. " " .. tostring(delay) .. " " .. tostring("target:") .. " " .. tostring(target))
end

--@api: LToolbar:getOrientation.3
do

    local tb = lurek.ui.newToolbar("horizontal")
    tb:setOrientation("vertical")
    local ori = tb:getOrientation()
    local tp = lurek.ui.newTooltipPanel("Hover help")
    local delay = tp:getDelay()
    local target = tp:getTarget()
    lurek.log.info(tostring("orientation:") .. " " .. tostring(ori) .. " " .. tostring("delay:") .. " " .. tostring(delay) .. " " .. tostring("target:") .. " " .. tostring(target))
end

--@api: LTooltipPanel:getTarget
do

    local tb = lurek.ui.newToolbar("horizontal")
    tb:setOrientation("vertical")
    local ori = tb:getOrientation()
    local tp = lurek.ui.newTooltipPanel("Hover help")
    local delay = tp:getDelay()
    local target = tp:getTarget()
    lurek.log.info(tostring("orientation:") .. " " .. tostring(ori) .. " " .. tostring("delay:") .. " " .. tostring(delay) .. " " .. tostring("target:") .. " " .. tostring(target))
end

--@api: LTooltipPanel:setTarget.2
do

    local tp = lurek.ui.newTooltipPanel("initial tip")
    local txt = tp:getText()
    tp:setDelay(0.5)
    local d = tp:getDelay()
    local btn = lurek.ui.newButton("hover me")
    tp:setTarget(btn:getId() and 1 or 1)
    lurek.log.info(tostring("text:") .. " " .. tostring(txt) .. " " .. tostring("delay:") .. " " .. tostring(d))
end

--@api: LTooltipPanel:setTarget.3
do

    local tp = lurek.ui.newTooltipPanel("initial tip")
    local txt = tp:getText()
    tp:setDelay(0.5)
    local d = tp:getDelay()
    local btn = lurek.ui.newButton("hover me")
    tp:setTarget(btn:getId() and 1 or 1)
    lurek.log.info(tostring("text:") .. " " .. tostring(txt) .. " " .. tostring("delay:") .. " " .. tostring(d))
end

--@api: LTooltipPanel:setTarget
do

    local tp = lurek.ui.newTooltipPanel("initial tip")
    local txt = tp:getText()
    tp:setDelay(0.5)
    local d = tp:getDelay()
    local btn = lurek.ui.newButton("hover me")
    tp:setTarget(btn:getId() and 1 or 1)
    lurek.log.info(tostring("text:") .. " " .. tostring(txt) .. " " .. tostring("delay:") .. " " .. tostring(d))
end

--@api: LTooltipPanel:setDelay.2
do

    local tp = lurek.ui.newTooltipPanel("old tip")
    tp:setText("new tooltip text")
    local txt = tp:getText()
    tp:setText("another tip")
    local txt2 = tp:getText()
    tp:setDelay(1.0)
    lurek.log.info(tostring("setText:") .. " " .. tostring(txt) .. " " .. tostring("â†’") .. " " .. tostring(txt2))
end

--@api: LTreeView:getNodeCount.2
do

    local tv = lurek.ui.newTreeView()
    local n1 = tv:addNode("Root", nil)
    local n2 = tv:addNode("Child", n1)
    tv:collapseAll()
    tv:clearNodes()
    local cnt = tv:getNodeCount()
    lurek.log.info(tostring("addNode/collapseAll/clearNodes ok; count after clear:") .. " " .. tostring(cnt))
end

--@api: LTreeView:getNodeCount.3
do

    local tv = lurek.ui.newTreeView()
    local n1 = tv:addNode("Root", nil)
    local n2 = tv:addNode("Child", n1)
    tv:collapseAll()
    tv:clearNodes()
    local cnt = tv:getNodeCount()
    lurek.log.info(tostring("addNode/collapseAll/clearNodes ok; count after clear:") .. " " .. tostring(cnt))
end

--@api: LTreeView:getNodeCount.4
do

    local tv = lurek.ui.newTreeView()
    local n1 = tv:addNode("Root", nil)
    local n2 = tv:addNode("Child", n1)
    tv:collapseAll()
    tv:clearNodes()
    local cnt = tv:getNodeCount()
    lurek.log.info(tostring("addNode/collapseAll/clearNodes ok; count after clear:") .. " " .. tostring(cnt))
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
    lurek.log.info(tostring("expandAll/collapseNode/expandNode ok; count:") .. " " .. tostring(cnt))
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
    lurek.log.info(tostring("expandAll/collapseNode/expandNode ok; count:") .. " " .. tostring(cnt))
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
    lurek.log.info(tostring("expandAll/collapseNode/expandNode ok; count:") .. " " .. tostring(cnt))
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
    lurek.log.info(tostring("children:") .. " " .. tostring(children) .. " " .. tostring("count:") .. " " .. tostring(cnt) .. " " .. tostring("depth:") .. " " .. tostring(depth))
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
    lurek.log.info(tostring("children:") .. " " .. tostring(children) .. " " .. tostring("count:") .. " " .. tostring(cnt) .. " " .. tostring("depth:") .. " " .. tostring(depth))
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
    lurek.log.info(tostring("children:") .. " " .. tostring(children) .. " " .. tostring("count:") .. " " .. tostring(cnt) .. " " .. tostring("depth:") .. " " .. tostring(depth))
end

--@api: LTreeView:getSelectedNode.2
do

    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    local c = tv:addNode("Child", r)
    local txt = tv:getNodeText(c)
    local parent = tv:getParentNode(c)
    local sel = tv:getSelectedNode()
    lurek.log.info(tostring("text:") .. " " .. tostring(txt) .. " " .. tostring("parent:") .. " " .. tostring(parent) .. " " .. tostring("selected:") .. " " .. tostring(sel))
end

--@api: LTreeView:getSelectedNode.3
do

    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    local c = tv:addNode("Child", r)
    local txt = tv:getNodeText(c)
    local parent = tv:getParentNode(c)
    local sel = tv:getSelectedNode()
    lurek.log.info(tostring("text:") .. " " .. tostring(txt) .. " " .. tostring("parent:") .. " " .. tostring(parent) .. " " .. tostring("selected:") .. " " .. tostring(sel))
end

--@api: LTreeView:getSelectedNode.4
do

    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    local c = tv:addNode("Child", r)
    local txt = tv:getNodeText(c)
    local parent = tv:getParentNode(c)
    local sel = tv:getSelectedNode()
    lurek.log.info(tostring("text:") .. " " .. tostring(txt) .. " " .. tostring("parent:") .. " " .. tostring(parent) .. " " .. tostring("selected:") .. " " .. tostring(sel))
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
    lurek.log.info(tostring("isExpanded:") .. " " .. tostring(exp) .. " " .. tostring("isNodeExpanded:") .. " " .. tostring(ne) .. " " .. tostring("count after remove:") .. " " .. tostring(cnt))
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
    lurek.log.info(tostring("isExpanded:") .. " " .. tostring(exp) .. " " .. tostring("isNodeExpanded:") .. " " .. tostring(ne) .. " " .. tostring("count after remove:") .. " " .. tostring(cnt))
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
    lurek.log.info(tostring("isExpanded:") .. " " .. tostring(exp) .. " " .. tostring("isNodeExpanded:") .. " " .. tostring(ne) .. " " .. tostring("count after remove:") .. " " .. tostring(cnt))
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
    lurek.log.info(tostring("setText:") .. " " .. tostring(txt) .. " " .. tostring("selected:") .. " " .. tostring(sel))
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
    lurek.log.info(tostring("setText:") .. " " .. tostring(txt) .. " " .. tostring("selected:") .. " " .. tostring(sel))
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
    lurek.log.info(tostring("setText:") .. " " .. tostring(txt) .. " " .. tostring("selected:") .. " " .. tostring(sel))
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
    lurek.log.info(tostring("expanded:") .. " " .. tostring(was) .. " " .. tostring("after toggle:") .. " " .. tostring(now) .. " " .. tostring("after toggle back:") .. " " .. tostring(back))
end

--@api: lurek.ui.newCustomWidget
do

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local child = lurek.ui.newLabel("label")
    w:addChild(child)
    w:animateAlpha(0.5, 0.3, false)
    w:animatePosition(10, 20, 0.5)
    local cnt = w:getChildCount()
    lurek.log.info(tostring("addChild/animateAlpha/animatePosition ok; childCount:") .. " " .. tostring(cnt))
end

--@api: LCustomWidget:addChild
do

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local child = lurek.ui.newLabel("label")
    w:addChild(child)
    w:animateAlpha(0.5, 0.3, false)
    w:animatePosition(10, 20, 0.5)
    local cnt = w:getChildCount()
    lurek.log.info(tostring("addChild/animateAlpha/animatePosition ok; childCount:") .. " " .. tostring(cnt))
end

--@api: LCustomWidget:getChildCount
do

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local child = lurek.ui.newLabel("label")
    w:addChild(child)
    w:animateAlpha(0.5, 0.3, false)
    w:animatePosition(10, 20, 0.5)
    local cnt = w:getChildCount()
    lurek.log.info(tostring("addChild/animateAlpha/animatePosition ok; childCount:") .. " " .. tostring(cnt))
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
    lurek.log.info(tostring("attachToEntity/bind/cancelAnimations ok"))
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
    lurek.log.info(tostring("attachToEntity/bind/cancelAnimations ok"))
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
    lurek.log.info(tostring("attachToEntity/bind/cancelAnimations ok"))
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
    lurek.log.info(tostring("clearAnchor/containsPoint:") .. " " .. tostring(hit) .. " " .. tostring("detachFromEntity ok"))
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
    lurek.log.info(tostring("clearAnchor/containsPoint:") .. " " .. tostring(hit) .. " " .. tostring("detachFromEntity ok"))
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
    lurek.log.info(tostring("clearAnchor/containsPoint:") .. " " .. tostring(hit) .. " " .. tostring("detachFromEntity ok"))
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
    lurek.log.info(tostring("fadeIn/fadeOut ok; findById:") .. " " .. tostring(found))
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
    lurek.log.info(tostring("fadeIn/fadeOut ok; findById:") .. " " .. tostring(found))
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
    lurek.log.info(tostring("fadeIn/fadeOut ok; findById:") .. " " .. tostring(found))
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
    lurek.log.info(tostring("alpha:") .. " " .. tostring(alpha) .. " " .. tostring("childCount:") .. " " .. tostring(cnt) .. " " .. tostring("children:") .. " " .. tostring(children))
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
    lurek.log.info(tostring("alpha:") .. " " .. tostring(alpha) .. " " .. tostring("childCount:") .. " " .. tostring(cnt) .. " " .. tostring("children:") .. " " .. tostring(children))
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
    lurek.log.info(tostring("alpha:") .. " " .. tostring(alpha) .. " " .. tostring("childCount:") .. " " .. tostring(cnt) .. " " .. tostring("children:") .. " " .. tostring(children))
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
    lurek.log.info(tostring("flexGrow:") .. " " .. tostring(grow) .. " " .. tostring("flexShrink:") .. " " .. tostring(shrink) .. " " .. tostring("id:") .. " " .. tostring(id))
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
    lurek.log.info(tostring("flexGrow:") .. " " .. tostring(grow) .. " " .. tostring("flexShrink:") .. " " .. tostring(shrink) .. " " .. tostring("id:") .. " " .. tostring(id))
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
    lurek.log.info(tostring("flexGrow:") .. " " .. tostring(grow) .. " " .. tostring("flexShrink:") .. " " .. tostring(shrink) .. " " .. tostring("id:") .. " " .. tostring(id))
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
    lurek.log.info(tostring("margin:") .. " " .. tostring(mt) .. " " .. tostring(mr) .. " " .. tostring(mb) .. " " .. tostring(ml) .. " " .. tostring("max:") .. " " .. tostring(mxw) .. " " .. tostring(mxh) .. " " .. tostring("min:") .. " " .. tostring(mnw) .. " " .. tostring(mnh))
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
    lurek.log.info(tostring("margin:") .. " " .. tostring(mt) .. " " .. tostring(mr) .. " " .. tostring(mb) .. " " .. tostring(ml) .. " " .. tostring("max:") .. " " .. tostring(mxw) .. " " .. tostring(mxh) .. " " .. tostring("min:") .. " " .. tostring(mnw) .. " " .. tostring(mnh))
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
    lurek.log.info(tostring("margin:") .. " " .. tostring(mt) .. " " .. tostring(mr) .. " " .. tostring(mb) .. " " .. tostring(ml) .. " " .. tostring("max:") .. " " .. tostring(mxw) .. " " .. tostring(mxh) .. " " .. tostring("min:") .. " " .. tostring(mnw) .. " " .. tostring(mnh))
end

--@api: LCustomWidget:setPadding
do

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setPadding(5, 5, 5, 5)
    local pt, pr, pb, pl = w:getPadding()
    w:setPosition(30, 40)
    local px, py = w:getPosition()
    local rx, ry, rw, rh = w:getRect()
    lurek.log.info(tostring("padding:") .. " " .. tostring(pt) .. " " .. tostring("position:") .. " " .. tostring(px) .. " " .. tostring(py) .. " " .. tostring("rect:") .. " " .. tostring(rx) .. " " .. tostring(ry) .. " " .. tostring(rw) .. " " .. tostring(rh))
end

--@api: LCustomWidget:getRect
do

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setPadding(5, 5, 5, 5)
    local pt, pr, pb, pl = w:getPadding()
    w:setPosition(30, 40)
    local px, py = w:getPosition()
    local rx, ry, rw, rh = w:getRect()
    lurek.log.info(tostring("padding:") .. " " .. tostring(pt) .. " " .. tostring("position:") .. " " .. tostring(px) .. " " .. tostring(py) .. " " .. tostring("rect:") .. " " .. tostring(rx) .. " " .. tostring(ry) .. " " .. tostring(rw) .. " " .. tostring(rh))
end

--@api: LCustomWidget:getRect.2
do

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setPadding(5, 5, 5, 5)
    local pt, pr, pb, pl = w:getPadding()
    w:setPosition(30, 40)
    local px, py = w:getPosition()
    local rx, ry, rw, rh = w:getRect()
    lurek.log.info(tostring("padding:") .. " " .. tostring(pt) .. " " .. tostring("position:") .. " " .. tostring(px) .. " " .. tostring(py) .. " " .. tostring("rect:") .. " " .. tostring(rx) .. " " .. tostring(ry) .. " " .. tostring(rw) .. " " .. tostring(rh))
end

--@api: LCustomWidget:setSize
do

    local w = lurek.ui.newCustomWidget({width=120, height=60})
    w:setSize(150, 80)
    local sw, sh = w:getSize()
    local state = w:getState()
    w:setTooltip("hover tip")
    local tip = w:getTooltip()
    lurek.log.info(tostring("size:") .. " " .. tostring(sw) .. " " .. tostring(sh) .. " " .. tostring("state:") .. " " .. tostring(state) .. " " .. tostring("tooltip:") .. " " .. tostring(tip))
end

--@api: LCustomWidget:getTooltip
do

    local w = lurek.ui.newCustomWidget({width=120, height=60})
    w:setSize(150, 80)
    local sw, sh = w:getSize()
    local state = w:getState()
    w:setTooltip("hover tip")
    local tip = w:getTooltip()
    lurek.log.info(tostring("size:") .. " " .. tostring(sw) .. " " .. tostring(sh) .. " " .. tostring("state:") .. " " .. tostring(state) .. " " .. tostring("tooltip:") .. " " .. tostring(tip))
end

--@api: LCustomWidget:getTooltip.2
do

    local w = lurek.ui.newCustomWidget({width=120, height=60})
    w:setSize(150, 80)
    local sw, sh = w:getSize()
    local state = w:getState()
    w:setTooltip("hover tip")
    local tip = w:getTooltip()
    lurek.log.info(tostring("size:") .. " " .. tostring(sw) .. " " .. tostring(sh) .. " " .. tostring("state:") .. " " .. tostring(state) .. " " .. tostring("tooltip:") .. " " .. tostring(tip))
end

--@api: LCustomWidget:setZOrder
do

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setZOrder(5)
    local z = w:getZOrder()
    local animating = w:isAnimating()
    local enabled = w:isEnabled()
    w:setEnabled(false)
    lurek.log.info(tostring("zOrder:") .. " " .. tostring(z) .. " " .. tostring("isAnimating:") .. " " .. tostring(animating) .. " " .. tostring("isEnabled:") .. " " .. tostring(enabled))
end

--@api: LUiWidget:isAnimating
do

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setZOrder(5)
    local z = w:getZOrder()
    local animating = w:isAnimating()
    local enabled = w:isEnabled()
    w:setEnabled(false)
    lurek.log.info(tostring("zOrder:") .. " " .. tostring(z) .. " " .. tostring("isAnimating:") .. " " .. tostring(animating) .. " " .. tostring("isEnabled:") .. " " .. tostring(enabled))
end

--@api: LCustomWidget:setEnabled
do

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setZOrder(5)
    local z = w:getZOrder()
    local animating = w:isAnimating()
    local enabled = w:isEnabled()
    w:setEnabled(false)
    lurek.log.info(tostring("zOrder:") .. " " .. tostring(z) .. " " .. tostring("isAnimating:") .. " " .. tostring(animating) .. " " .. tostring("isEnabled:") .. " " .. tostring(enabled))
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
    lurek.log.info(tostring("isVisible:") .. " " .. tostring(vis) .. " " .. tostring("removeChild ok, alpha:") .. " " .. tostring(alpha))
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
    lurek.log.info(tostring("isVisible:") .. " " .. tostring(vis) .. " " .. tostring("removeChild ok, alpha:") .. " " .. tostring(alpha))
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
    lurek.log.info(tostring("isVisible:") .. " " .. tostring(vis) .. " " .. tostring("removeChild ok, alpha:") .. " " .. tostring(alpha))
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
    lurek.log.info(tostring("setAnchor/setAnchorCenter/setEnabled ok"))
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
    lurek.log.info(tostring("setAnchor/setAnchorCenter/setEnabled ok"))
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
    lurek.log.info(tostring("setAnchor/setAnchorCenter/setEnabled ok"))
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
    lurek.log.info(tostring("flexGrow:") .. " " .. tostring(fg) .. " " .. tostring("flexShrink:") .. " " .. tostring(fs) .. " " .. tostring("id:") .. " " .. tostring(id))
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
    lurek.log.info(tostring("flexGrow:") .. " " .. tostring(fg) .. " " .. tostring("flexShrink:") .. " " .. tostring(fs) .. " " .. tostring("id:") .. " " .. tostring(id))
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
    lurek.log.info(tostring("flexGrow:") .. " " .. tostring(fg) .. " " .. tostring("flexShrink:") .. " " .. tostring(fs) .. " " .. tostring("id:") .. " " .. tostring(id))
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
    lurek.log.info(tostring("margin set ok; maxSize:") .. " " .. tostring(mxw) .. " " .. tostring("minSize:") .. " " .. tostring(mnw))
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
    lurek.log.info(tostring("margin set ok; maxSize:") .. " " .. tostring(mxw) .. " " .. tostring("minSize:") .. " " .. tostring(mnw))
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
    lurek.log.info(tostring("margin set ok; maxSize:") .. " " .. tostring(mxw) .. " " .. tostring("minSize:") .. " " .. tostring(mnw))
end

--@api: LUiWidget:setOnChange
do

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setOnChange(function() lurek.log.info(tostring("changed")) end)
    w:setOnClick(function() lurek.log.info(tostring("clicked")) end)
    w:setOnDraw(function() lurek.log.info(tostring("drawing")) end)
    local id = w:getId()
    local vis = w:isVisible()
    lurek.log.info(tostring("setOnChange/setOnClick/setOnDraw ok; id:") .. " " .. tostring(id) .. " " .. tostring("vis:") .. " " .. tostring(vis))
end

--@api: LUiWidget:setOnClick
do

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setOnChange(function() lurek.log.info(tostring("changed")) end)
    w:setOnClick(function() lurek.log.info(tostring("clicked")) end)
    w:setOnDraw(function() lurek.log.info(tostring("drawing")) end)
    local id = w:getId()
    local vis = w:isVisible()
    lurek.log.info(tostring("setOnChange/setOnClick/setOnDraw ok; id:") .. " " .. tostring(id) .. " " .. tostring("vis:") .. " " .. tostring(vis))
end

--@api: LUiWidget:setOnDraw
do

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setOnChange(function() lurek.log.info(tostring("changed")) end)
    w:setOnClick(function() lurek.log.info(tostring("clicked")) end)
    w:setOnDraw(function() lurek.log.info(tostring("drawing")) end)
    local id = w:getId()
    local vis = w:isVisible()
    lurek.log.info(tostring("setOnChange/setOnClick/setOnDraw ok; id:") .. " " .. tostring(id) .. " " .. tostring("vis:") .. " " .. tostring(vis))
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
    lurek.log.info(tostring("padding:") .. " " .. tostring(pt) .. " " .. tostring("position:") .. " " .. tostring(px) .. " " .. tostring(py) .. " " .. tostring("size:") .. " " .. tostring(sw) .. " " .. tostring(sh))
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
    lurek.log.info(tostring("padding:") .. " " .. tostring(pt) .. " " .. tostring("position:") .. " " .. tostring(px) .. " " .. tostring(py) .. " " .. tostring("size:") .. " " .. tostring(sw) .. " " .. tostring(sh))
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
    lurek.log.info(tostring("padding:") .. " " .. tostring(pt) .. " " .. tostring("position:") .. " " .. tostring(px) .. " " .. tostring(py) .. " " .. tostring("size:") .. " " .. tostring(sw) .. " " .. tostring(sh))
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
    lurek.log.info(tostring("tooltip:") .. " " .. tostring(tip) .. " " .. tostring("zOrder:") .. " " .. tostring(z))
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
    lurek.log.info(tostring("tooltip:") .. " " .. tostring(tip) .. " " .. tostring("zOrder:") .. " " .. tostring(z))
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
    lurek.log.info(tostring("tooltip:") .. " " .. tostring(tip) .. " " .. tostring("zOrder:") .. " " .. tostring(z))
end

--@api: LCustomWidget:slideIn
do

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:slideIn(0, -50)
    w:slideOut(0, 50)
    local t = w:type()
    local ok = w:typeOf("LUiWidget")
    w:unbind()
    lurek.log.info(tostring("slideIn/slideOut ok; type:") .. " " .. tostring(t) .. " " .. tostring("typeOf:") .. " " .. tostring(ok))
end

--@api: LCustomWidget:unbind
do

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:slideIn(0, -50)
    w:slideOut(0, 50)
    local t = w:type()
    local ok = w:typeOf("LUiWidget")
    w:unbind()
    lurek.log.info(tostring("slideIn/slideOut ok; type:") .. " " .. tostring(t) .. " " .. tostring("typeOf:") .. " " .. tostring(ok))
end

--@api: LUiWidget:type
do

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:slideIn(0, -50)
    w:slideOut(0, 50)
    local t = w:type()
    local ok = w:typeOf("LUiWidget")
    w:unbind()
    lurek.log.info(tostring("slideIn/slideOut ok; type:") .. " " .. tostring(t) .. " " .. tostring("typeOf:") .. " " .. tostring(ok))
end

--@api: LUiWidget:typeOf
do

    local w = lurek.ui.newCustomWidget({width=80, height=40})
    w:bind("click")
    w:unbind()
    local ok1 = w:typeOf("LUiWidget")
    local ok2 = w:typeOf("LButton")
    local t = w:type()
    lurek.log.info(tostring("typeOf LUiWidget:") .. " " .. tostring(ok1) .. " " .. tostring("typeOf LButton:") .. " " .. tostring(ok2) .. " " .. tostring("type:") .. " " .. tostring(t))
end

--@api: LUiWidget:unbind
do

    local w = lurek.ui.newCustomWidget({width=80, height=40})
    w:bind("click")
    w:unbind()
    local ok1 = w:typeOf("LUiWidget")
    local ok2 = w:typeOf("LButton")
    local t = w:type()
    lurek.log.info(tostring("typeOf LUiWidget:") .. " " .. tostring(ok1) .. " " .. tostring("typeOf LButton:") .. " " .. tostring(ok2) .. " " .. tostring("type:") .. " " .. tostring(t))
end

--@api: lurek.ui.draw
do

    local w = lurek.ui.newCustomWidget({width=80, height=40})
    lurek.ui.beginDrag(w)
    lurek.ui.endDrag()
    lurek.ui.clearFocus()
    lurek.ui.draw()
    lurek.log.info(tostring("beginDrag/endDrag/clearFocus/draw ok"))
end

--@api: lurek.ui.drawToImage
do

    local img = lurek.ui.drawToImage(320, 240)
    local w = lurek.ui.newCustomWidget({width=80, height=40})
    lurek.ui.beginDrag(w)
    lurek.ui.dropOn(w)
    lurek.ui.endDrag()
    lurek.log.info(tostring("drawToImage ok; dropOn/endDrag ok"))
end

--@api: lurek.ui.endDrag
do

    local img = lurek.ui.drawToImage(320, 240)
    local w = lurek.ui.newCustomWidget({width=80, height=40})
    lurek.ui.beginDrag(w)
    lurek.ui.dropOn(w)
    lurek.ui.endDrag()
    lurek.log.info(tostring("drawToImage ok; dropOn/endDrag ok"))
end

--@api: lurek.ui.flushCache
do

    lurek.ui.flushCache()
    lurek.ui.focusPrev()
    local drag = lurek.ui.getActiveDrag()
    local focus = lurek.ui.getFocus()
    lurek.ui.clearFocus()
    lurek.log.info(tostring("flushCache/focusPrev ok; activeDrag:") .. " " .. tostring(drag) .. " " .. tostring("focus:") .. " " .. tostring(focus))
end

--@api: lurek.ui.getToastCount
do

    lurek.ui.clearFocus()
    local foc = lurek.ui.getFocus()
    local theme = lurek.ui.getTheme()
    local toasts = lurek.ui.getToastCount()
    local widgets = lurek.ui.getWidgetCount()
    lurek.log.info(tostring("focus:") .. " " .. tostring(foc) .. " " .. tostring("theme:") .. " " .. tostring(theme) .. " " .. tostring("toastCount:") .. " " .. tostring(toasts) .. " " .. tostring("widgetCount:") .. " " .. tostring(widgets))
end

--@api: lurek.ui.getWidgetCount
do

    local cnt = lurek.ui.getWidgetCount()
    lurek.ui.keypressed("escape")
    local layout = lurek.ui.loadLayoutFile("content/examples/assets/layouts/sample_main_menu.toml")
    lurek.ui.textinput("a")
    lurek.log.info(tostring("widgetCount:") .. " " .. tostring(cnt) .. " " .. tostring("loadLayoutFile ok; textinput ok"))
end

--@api: lurek.ui.keypressed
do

    local cnt = lurek.ui.getWidgetCount()
    lurek.ui.keypressed("escape")
    local layout = lurek.ui.loadLayoutFile("content/examples/assets/layouts/sample_main_menu.toml")
    lurek.ui.textinput("a")
    lurek.log.info(tostring("widgetCount:") .. " " .. tostring(cnt) .. " " .. tostring("loadLayoutFile ok; textinput ok"))
end

--@api: lurek.ui.loadLayoutFile
do

    local cnt = lurek.ui.getWidgetCount()
    lurek.ui.keypressed("escape")
    local layout = lurek.ui.loadLayoutFile("content/examples/assets/layouts/sample_main_menu.toml")
    lurek.ui.textinput("a")
    lurek.log.info(tostring("widgetCount:") .. " " .. tostring(cnt) .. " " .. tostring("loadLayoutFile ok; textinput ok"))
end

--@api: lurek.ui.loadLayoutGameFile
do

    local ok, result = pcall(function()
        return lurek.ui.loadLayoutGameFile("content/examples/assets/layouts/sample_main_menu.toml")
    end)
    lurek.log.info(tostring("loadLayoutGameFile ok:") .. " " .. tostring(ok) .. " " .. tostring("result:") .. " " .. tostring(tostring(result)))
    lurek.log.info(tostring("result type:") .. " " .. tostring(type(result)))
    lurek.log.info(tostring("loaded layout:") .. " " .. tostring(tostring(ok and result ~= nil)))
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
    lurek.log.info(tostring("slider value after drag:") .. " " .. tostring(slider:getValue()))
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
    lurek.log.info(tostring("active tab after click:") .. " " .. tostring(tabs:getActiveTab()))
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
    lurek.log.info(tostring("combo selected:") .. " " .. tostring(combo:getSelectedItem()))
end

--@api: LCustomWidget:UNKNOWN
do

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local layout = lurek.ui.newLayout("row")
    local sb = lurek.ui.newScrollBar(true)
    lurek.log.info(tostring("newCustomWidget:") .. " " .. tostring(w) .. " " .. tostring("newLayout:") .. " " .. tostring(layout) .. " " .. tostring("newScrollBar:") .. " " .. tostring(sb))
    lurek.log.info(tostring("rect x = " .. select(1, w:getRect())))
end

--@api: lurek.ui.newScrollBar
do

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local layout = lurek.ui.newLayout("row")
    local sb = lurek.ui.newScrollBar(true)
    lurek.log.info(tostring("newCustomWidget:") .. " " .. tostring(w) .. " " .. tostring("newLayout:") .. " " .. tostring(layout) .. " " .. tostring("newScrollBar:") .. " " .. tostring(sb))
    lurek.log.info(tostring("rect x = " .. select(1, w:getRect())))
end

--@api: lurek.ui.parseWidgetState
do

    local th = lurek.ui.newTheme()
    local state = lurek.ui.parseWidgetState("normal")
    local result = lurek.ui.renderToImage(320, 240, "save/ui_render.png")
    lurek.log.info(tostring("newTheme ok; parseWidgetState:") .. " " .. tostring(state) .. " " .. tostring("renderToImage:") .. " " .. tostring(result))
    lurek.ui.setTheme(th)
    lurek.log.info(tostring("theme applied = " .. tostring(lurek.ui.getTheme() ~= nil)))
end

--@api: lurek.ui.renderToImage
do

    local th = lurek.ui.newTheme()
    local state = lurek.ui.parseWidgetState("normal")
    local result = lurek.ui.renderToImage(320, 240, "save/ui_render.png")
    lurek.log.info(tostring("newTheme ok; parseWidgetState:") .. " " .. tostring(state) .. " " .. tostring("renderToImage:") .. " " .. tostring(result))
    lurek.ui.setTheme(th)
    lurek.log.info(tostring("theme applied = " .. tostring(lurek.ui.getTheme() ~= nil)))
end

--@api: lurek.ui.setDefaultTheme
do

    local th = lurek.ui.newTheme()
    lurek.ui.setTheme(th)
    lurek.ui.setDefaultTheme()
    lurek.ui.setViewport(1280, 720)
    local cnt = lurek.ui.getWidgetCount()
    lurek.log.info(tostring("setTheme/setDefaultTheme/setViewport ok; widgets:") .. " " .. tostring(cnt))
end

--@api: lurek.ui.setViewport
do

    local th = lurek.ui.newTheme()
    lurek.ui.setTheme(th)
    lurek.ui.setDefaultTheme()
    lurek.ui.setViewport(1280, 720)
    local cnt = lurek.ui.getWidgetCount()
    lurek.log.info(tostring("setTheme/setDefaultTheme/setViewport ok; widgets:") .. " " .. tostring(cnt))
end

--@api: lurek.ui.textinput
do

    lurek.ui.textinput("hello")
    lurek.ui.textinput(" world")
    lurek.ui.update_bindings({dt=0.016})
    lurek.ui.wheelmoved(0, 1)
    lurek.ui.wheelmoved(1, 0)
    lurek.log.info(tostring("textinput/update_bindings/wheelmoved ok"))
end

--@api: lurek.ui.update_bindings
do

    lurek.ui.textinput("hello")
    lurek.ui.textinput(" world")
    lurek.ui.update_bindings({dt=0.016})
    lurek.ui.wheelmoved(0, 1)
    lurek.ui.wheelmoved(1, 0)
    lurek.log.info(tostring("textinput/update_bindings/wheelmoved ok"))
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
    lurek.log.info(tostring("hover scroll y:") .. " " .. tostring(sy))
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
    lurek.log.info(tostring("focused text:") .. " " .. tostring(input:isFocused()) .. " " .. tostring(input:getText()))
end

--@api: LToolbar:setPosition
do

    local toolbar = lurek.ui.newToolbar("horizontal")
    toolbar:setPosition(220, 650)
    toolbar:setSize(120, 32)
    toolbar:setZOrder(2610)
    toolbar:addButton("save", "Save")
    toolbar:setOnChange(function() lurek.log.info(tostring("toolbar changed")) end)
    lurek.ui.mousepressed(230, 666, 1)
    lurek.ui.mousereleased(230, 666, 1)
    lurek.ui.update(0)
    lurek.log.info(tostring("save toggled:") .. " " .. tostring(toolbar:isButtonToggled("save")))
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
    card:setOnChange(function() lurek.log.info(tostring("card selected")) end)
    lurek.ui.mousepressed(380, 688, 1)
    lurek.ui.mousereleased(380, 688, 1)
    lurek.ui.update(0)
    lurek.log.info(tostring("cash/card:") .. " " .. tostring(cash:isSelected()) .. " " .. tostring(card:isSelected()))
end

--@api: LScrollBar:setPosition
do

    local bar = lurek.ui.newScrollBar(true)
    bar:setPosition(500, 650)
    bar:setSize(20, 100)
    bar:setZOrder(2640)
    bar:setContentSize(400)
    bar:setViewSize(100)
    bar:setOnChange(function() lurek.log.info(tostring("scrollbar changed")) end)
    lurek.ui.mousepressed(510, 720, 1)
    lurek.ui.mousemoved(510, 740)
    lurek.ui.mousereleased(510, 740, 1)
    lurek.ui.update(0)
    lurek.log.info(tostring("scrollbar position:") .. " " .. tostring(bar:getScrollPosition()))
end

--@api: LWindow:setPosition
do

    local win = lurek.ui.newWindow("Inspector")
    win:setPosition(550, 650)
    win:setSize(150, 90)
    win:setZOrder(2650)
    win:setOnClose(function() lurek.log.info(tostring("window closed")) end)
    lurek.ui.mousepressed(690, 660, 1)
    lurek.ui.mousereleased(690, 660, 1)
    lurek.ui.update(0)
    lurek.log.info(tostring("window visible:") .. " " .. tostring(win:isVisible()))
end

--@api: LDialog:setPosition
do

    local dialog = lurek.ui.newDialog("Confirm")
    dialog:setCenterOnOpen(false)
    dialog:setPosition(720, 650)
    dialog:setSize(180, 100)
    dialog:setZOrder(2660)
    dialog:addButton("Close")
    dialog:setOnClose(function() lurek.log.info(tostring("dialog closed")) end)
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
    lurek.log.info(tostring("mouse filter set to ignore"))
    lurek.log.info(tostring("panel children = " .. panel:getChildCount()))
    lurek.log.info(tostring("panel width = " .. select(3, panel:getRect())))
end

--@api: LUiWidget:getMouseFilter
do

    -- Retrieves the current mouse filter behavior of a widget.
    local panel = lurek.ui.newPanel()
    panel:setMouseFilter("pass")
    local filter = panel:getMouseFilter()
    lurek.log.info(tostring("mouse filter: " .. filter))
    lurek.log.info(tostring("panel children = " .. panel:getChildCount()))
end

--@api: LUiWidget:setStyleClass
do

    -- Assigns a custom style class to a widget. If defined in the active theme,
    -- the button will use "primary" colors and metrics instead of default ones.
    local btn = lurek.ui.newButton("Submit")
    btn:setStyleClass("primary")
    lurek.log.info(tostring("style class set to primary"))
    lurek.log.info(tostring("button text = " .. btn:getText()))
    lurek.log.info(tostring("button width = " .. select(3, btn:getRect())))
end

--@api: LUiWidget:getStyleClass
do

    -- Retrieves the currently assigned style class of a widget, or an empty string if none.
    local btn = lurek.ui.newButton("Cancel")
    btn:setStyleClass("danger")
    local class = btn:getStyleClass()
    lurek.log.info(tostring("style class: " .. class))
    lurek.log.info(tostring("button text = " .. btn:getText()))
end

--@api: LUiWidget:setAlign
do

    -- Configures the flexbox cross-axis alignment. "center" aligns children
    -- vertically in a horizontal layout.
    local layout = lurek.ui.newLayout("horizontal")
    layout:setAlign("center")
    lurek.log.info(tostring("align set to center"))
    lurek.log.info(tostring("layout direction = " .. layout:getDirection()))
    lurek.log.info(tostring("layout spacing = " .. layout:getSpacing()))
end

--@api: LUiWidget:getAlign
do

    -- Gets the current flexbox alignment property.
    local layout = lurek.ui.newLayout("horizontal")
    layout:setAlign("stretch")
    local align = layout:getAlign()
    lurek.log.info(tostring("align: " .. align))
    lurek.log.info(tostring("layout direction = " .. layout:getDirection()))
end

--@api: LUiWidget:setJustify
do

    -- Configures the flexbox main-axis justification. "space-between" spreads
    -- children to edges.
    local layout = lurek.ui.newLayout("horizontal")
    layout:setJustify("space-between")
    lurek.log.info(tostring("justify set to space-between"))
    lurek.log.info(tostring("layout direction = " .. layout:getDirection()))
    lurek.log.info(tostring("layout spacing = " .. layout:getSpacing()))
end

--@api: LUiWidget:getJustify
do

    -- Gets the current flexbox justification property.
    local layout = lurek.ui.newLayout("horizontal")
    layout:setJustify("end")
    local justify = layout:getJustify()
    lurek.log.info(tostring("justify: " .. justify))
    lurek.log.info(tostring("layout direction = " .. layout:getDirection()))
end

--@api: LTable:clearRows
do

    -- Removes all rows from a GUI table without deleting its column definitions.
    local tbl = lurek.ui.newTable()
    tbl:addColumn("Name")
    tbl:addRow({"Alice"})
    tbl:clearRows()
    lurek.log.info(tostring("cleared rows"))
end

--@api: LTable:setRows
do

    -- Bulk-replaces all current rows with the provided list of row data.
    local tbl = lurek.ui.newTable()
    tbl:addColumn("Score")
    tbl:setRows({{"100"}, {"200"}})
    lurek.log.info(tostring("set rows"))
    lurek.log.info(tostring("rect x = " .. select(1, tbl:getRect())))
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
    lurek.log.info(tostring("label text = " .. lbl:getText()))
    lurek.log.info(tostring("label width = " .. select(3, lbl:getRect())))
    lurek.log.info(tostring("label visible = " .. tostring(lbl:isVisible())))
end

--@api: LUiWidget:setTextEllipsis
do

    local lbl = lurek.ui.newLabel("This is a very long one-line text")
    lbl:setTextEllipsis(true)
    lurek.log.info(tostring("label text = " .. lbl:getText()))
    lurek.log.info(tostring("label width = " .. select(3, lbl:getRect())))
    lurek.log.info(tostring("label visible = " .. tostring(lbl:isVisible())))
end

--@api: LUiWidget:setTextVAlign
do

    local lbl = lurek.ui.newLabel("Centered")
    lbl:setTextVAlign("middle")
    lurek.log.info(tostring("label text = " .. lbl:getText()))
    lurek.log.info(tostring("label width = " .. select(3, lbl:getRect())))
    lurek.log.info(tostring("label visible = " .. tostring(lbl:isVisible())))
end

--@api: LUiWidget:setTextAlign
do

    local lbl = lurek.ui.newLabel("Right aligned")
    lbl:setTextAlign("right")
    lurek.log.info(tostring("label text = " .. lbl:getText()))
    lurek.log.info(tostring("label width = " .. select(3, lbl:getRect())))
    lurek.log.info(tostring("label visible = " .. tostring(lbl:isVisible())))
end

--@api: LUiWidget:getTextAlign
do

    local lbl = lurek.ui.newLabel("Aligned")
    lbl:setTextAlign("center")
    lurek.log.info(tostring("textAlign=" .. lbl:getTextAlign()))
    lurek.log.info(tostring("label text = " .. lbl:getText()))
    lurek.log.info(tostring("label width = " .. select(3, lbl:getRect())))
end

--@api: LUiWidget:setFocusable
do

    local btn = lurek.ui.newButton("Focusable")
    btn:setFocusable(true)
    lurek.log.info(tostring("button text = " .. btn:getText()))
    lurek.log.info(tostring("button width = " .. select(3, btn:getRect())))
    lurek.log.info(tostring("button enabled = " .. tostring(btn:isEnabled())))
end

--@api: LUiWidget:setTabIndex
do

    local btn = lurek.ui.newButton("Tab")
    btn:setTabIndex(10)
    lurek.log.info(tostring("button text = " .. btn:getText()))
    lurek.log.info(tostring("button width = " .. select(3, btn:getRect())))
    lurek.log.info(tostring("button enabled = " .. tostring(btn:isEnabled())))
end

--@api: LUiWidget:setFocusGroup
do

    local btn = lurek.ui.newButton("Group")
    btn:setFocusGroup("menu")
    lurek.log.info(tostring("button text = " .. btn:getText()))
    lurek.log.info(tostring("button width = " .. select(3, btn:getRect())))
    lurek.log.info(tostring("button enabled = " .. tostring(btn:isEnabled())))
end

--@api: LUiWidget:setFocusNeighbor
do

    local a = lurek.ui.newButton("A")
    local b = lurek.ui.newButton("B")
    a:setFocusNeighbor("right", b)
    lurek.log.info(tostring("button text = " .. a:getText()))
    lurek.log.info(tostring("button width = " .. select(3, a:getRect())))
end

--@api: LUiWidget:setRole
do

    local btn = lurek.ui.newButton("Save")
    btn:setRole("button")
    lurek.log.info(tostring("button text = " .. btn:getText()))
    lurek.log.info(tostring("button width = " .. select(3, btn:getRect())))
    lurek.log.info(tostring("button enabled = " .. tostring(btn:isEnabled())))
end

--@api: LUiWidget:setAriaName
do

    local btn = lurek.ui.newButton("Save")
    btn:setAriaName("Save game")
    lurek.log.info(tostring("button text = " .. btn:getText()))
    lurek.log.info(tostring("button width = " .. select(3, btn:getRect())))
    lurek.log.info(tostring("button enabled = " .. tostring(btn:isEnabled())))
end

--@api: LUiWidget:getRole
do

    local btn = lurek.ui.newButton("Save")
    btn:setRole("button")
    lurek.log.info(tostring("button role = " .. btn:getRole()))
    lurek.log.info(tostring("button text = " .. btn:getText()))
    lurek.log.info(tostring("button visible = " .. tostring(btn:isVisible())))
end

--@api: LUiWidget:getAriaName
do

    local btn = lurek.ui.newButton("Save")
    btn:setAriaName("Save game")
    lurek.log.info(tostring("aria name = " .. btn:getAriaName()))
    lurek.log.info(tostring("button text = " .. btn:getText()))
    lurek.log.info(tostring("button visible = " .. tostring(btn:isVisible())))
end

--@api: LUiWidget:setLabelFor
do

    local label = lurek.ui.newLabel("Name")
    local input = lurek.ui.newTextInput()
    label:setLabelFor(input)
    lurek.log.info(tostring("label target = " .. tostring(label:getLabelFor())))
    lurek.log.info(tostring("input idx = " .. tostring(input._idx)))
end

--@api: LUiWidget:getLabelFor
do

    local label = lurek.ui.newLabel("Email")
    local input = lurek.ui.newTextInput()
    label:setLabelFor(input)
    lurek.log.info(tostring("label for = " .. tostring(label:getLabelFor())))
    lurek.log.info(tostring("label text = " .. label:getText()))
end

--@api: lurek.ui.getStyleToken
do

    local spacing = lurek.ui.getStyleToken("spacing_md")
    local color = lurek.ui.getStyleToken("color_primary")
    lurek.log.info(tostring("spacing_md=" .. tostring(spacing)))
    if type(color) == "table" then
        lurek.log.info(tostring("color_primary a=" .. tostring(color.a)))
    end
end

--@api: lurek.ui.focusNeighbor
do

    local a = lurek.ui.newButton("A")
    local b = lurek.ui.newButton("B")
    a:setFocusNeighbor("right", b)
    lurek.ui.setFocus(a)
    local moved = lurek.ui.focusNeighbor("right")
    lurek.log.info(tostring("focus moved=" .. tostring(moved)))
end

--@api: lurek.ui.clear
do

    local root = lurek.ui.getRoot()
    if root then
        lurek.ui.clear()
    end
    lurek.log.info(tostring("root widgets = " .. lurek.ui.getWidgetCount()))
end

--@api: lurek.ui.getAccessibilityTree
do

    lurek.ui.clear()
    local label = lurek.ui.newLabel("Name")
    local input = lurek.ui.newTextInput()
    label:setLabelFor(input)
    local nodes = lurek.ui.getAccessibilityTree()
    lurek.log.info(tostring("a11y nodes = " .. tostring(#nodes)))
    lurek.log.info(tostring("first node role = " .. tostring(nodes[1] and nodes[1].role)))
    lurek.log.info(tostring("first node name = " .. tostring(nodes[1] and nodes[1].name)))
end

--@api: lurek.ui.validateUx
do

    lurek.ui.clear()
    lurek.ui.setViewport(100, 100)
    local dialog = lurek.ui.newDialog("Confirm")
    dialog:open()
    dialog:setModal(true)
    dialog:setCloseable(false)
    dialog:setPosition(-20, 10)
    dialog:setSize(120, 90)
    local diagnostics = lurek.ui.validateUx()
    lurek.log.info(tostring("validateUx count = " .. tostring(#diagnostics)))
    lurek.log.info(tostring("validateUx first = " .. tostring(diagnostics[1] and diagnostics[1].message)))
end

--@api: lurek.ui.focusDirection
do

    local a = lurek.ui.newButton("A")
    local b = lurek.ui.newButton("B")
    a:setFocusNeighbor("right", b)
    lurek.ui.setFocus(a)
    local moved = lurek.ui.focusDirection(1.0, 0.0)
    lurek.log.info(tostring("lurek.ui.focusDirection moved=" .. tostring(moved)))
end

--@api: lurek.ui.updateResolution
do

    lurek.ui.setBaseResolution(1280, 720)
    local before = lurek.ui.getScaleFactor()
    lurek.ui.updateResolution(1920, 1080)
    local after = lurek.ui.getScaleFactor()
    lurek.log.info(tostring("scale before=" .. before))
    lurek.log.info(tostring("scale after=" .. after))
end

--@api: lurek.ui.setBaseResolution
do

    lurek.ui.setBaseResolution(1280, 720)
    local base_scale = lurek.ui.getScaleFactor()
    lurek.ui.updateResolution(1920, 1080)
    local viewport_scale = lurek.ui.getScaleFactor()
    lurek.log.info(tostring("base scale=" .. base_scale))
    lurek.log.info(tostring("viewport scale=" .. viewport_scale))
end

--@api: lurek.ui.getScaleFactor
do

    lurek.ui.setBaseResolution(1280, 720)
    local base_scale = lurek.ui.getScaleFactor()
    lurek.ui.updateResolution(1920, 1080)
    local viewport_scale = lurek.ui.getScaleFactor()
    lurek.log.info(tostring("base scale=" .. base_scale))
    lurek.log.info(tostring("viewport scale=" .. viewport_scale))
end

--@api: lurek.ui.visibleRange
do

    local list = lurek.ui.newList()
    local x, y = lurek.ui.visibleRange(list, 50, 20.0)
    lurek.log.info(tostring("lurek.ui.visibleRange x=" .. x .. " y=" .. y))
    lurek.log.info(tostring("list count = " .. list:getItemCount()))
    lurek.log.info(tostring("list width = " .. select(3, list:getRect())))
end

--@api: lurek.ui.animateScale
do

    local btn = lurek.ui.newButton("Scale")
    lurek.ui.animateScale(btn, 1.0, 1.0, 1.2, 1.2, 0.3)
    lurek.log.info(tostring("lurek.ui.animateScale ok"))
    lurek.log.info(tostring("button text = " .. btn:getText()))
    lurek.log.info(tostring("button width = " .. select(3, btn:getRect())))
end

--@api: lurek.ui.animateRotation
do

    local img = lurek.ui.newPanel()
    lurek.ui.animateRotation(img, 0, 360, 1.0)
    lurek.log.info(tostring("lurek.ui.animateRotation ok"))
    lurek.log.info(tostring("panel children = " .. img:getChildCount()))
    lurek.log.info(tostring("panel width = " .. select(3, img:getRect())))
end

--@api: lurek.ui.animateColor
do

    local lbl = lurek.ui.newLabel("Hello")
    lurek.ui.animateColor(lbl, {r=1,g=1,b=1,a=1}, {r=1,g=0.5,b=0,a=1}, 0.5)
    lurek.log.info(tostring("lurek.ui.animateColor ok"))
    lurek.log.info(tostring("label text = " .. lbl:getText()))
    lurek.log.info(tostring("label width = " .. select(3, lbl:getRect())))
end

--@api: lurek.ui.getIconNames
do

    local names = lurek.ui.getIconNames()
    local first = names[1] or ""
    local last = names[#names] or ""
    lurek.log.info(tostring("icon count = " .. #names))
    lurek.log.info(tostring("first icon = " .. first))
    lurek.log.info(tostring("last icon = " .. last))
end

--@api: lurek.ui.hasIcon
do

    local can_save = lurek.ui.hasIcon("save")
    local can_map = lurek.ui.hasIcon("map")
    local missing = lurek.ui.hasIcon("missing-icon")
    lurek.log.info(tostring("save icon = " .. tostring(can_save)))
    lurek.log.info(tostring("map icon = " .. tostring(can_map)))
    lurek.log.info(tostring("missing icon = " .. tostring(missing)))
end

--@api: lurek.ui.getIconGlyph
do

    local save_glyph = lurek.ui.getIconGlyph("save") or ""
    local health_glyph = lurek.ui.getIconGlyph("health") or ""
    local missing_glyph = lurek.ui.getIconGlyph("missing-icon")
    lurek.log.info(tostring("save glyph = " .. save_glyph))
    lurek.log.info(tostring("health glyph = " .. health_glyph))
    lurek.log.info(tostring("missing glyph = " .. tostring(missing_glyph)))
end

--@api: lurek.ui.newPropertyWidget
do

    local props = lurek.ui.newPropertyWidget()
    props:setPosition(16, 16)
    props:setSize(320, 220)
    props:setLabelWidth(132)
    local group = props:addGroup("Video System", false)
    props:addProperty(group, "Resolution", "UHD - 2160p", "select", { "HD", "UHD - 2160p" })
    lurek.log.info(tostring("property widget type = " .. props:type()))
end

--@api: LPropertyWidget:addGroup
do

    local props = lurek.ui.newPropertyWidget()
    props:setSize(280, 180)
    local video = props:addGroup("Video", false)
    local audio = props:addGroup("Audio", true)
    props:addProperty(video, "Bits", 10, "number")
    props:addProperty(audio, "Enable Audio", true, "bool")
    lurek.log.info(tostring("groups = " .. video .. "," .. audio))
end

--@api: LPropertyWidget:getGroupCount
do

    local props = lurek.ui.newPropertyWidget()
    props:addGroup("Video", false)
    props:addGroup("Audio", false)
    props:addGroup("Control", true)
    local count = props:getGroupCount()
    props:setSize(300, 160)
    lurek.log.info(tostring("property groups = " .. count))
end

--@api: LPropertyWidget:toggleGroup
do

    local props = lurek.ui.newPropertyWidget()
    local group = props:addGroup("Output Settings", false)
    props:addProperty(group, "Source Connector", "SDI IN A", "select", { "SDI IN A", "HDMI" })
    local collapsed = props:toggleGroup(group)
    props:setSize(320, 120)
    lurek.log.info(tostring("collapsed = " .. tostring(collapsed)))
end

--@api: LPropertyWidget:isGroupCollapsed
do

    local props = lurek.ui.newPropertyWidget()
    local group = props:addGroup("Key Settings", true)
    props:addProperty(group, "Invert Luma", false, "bool")
    local collapsed = props:isGroupCollapsed(group)
    props:setSize(260, 120)
    lurek.log.info(tostring("key collapsed = " .. tostring(collapsed)))
end

--@api: LPropertyWidget:addProperty
do

    local props = lurek.ui.newPropertyWidget()
    local group = props:addGroup("Audio Settings", false)
    local row = props:addProperty(group, "Audio Channels", "2 Channels", "select", { "2 Channels", "8 Channels" })
    props:addProperty(group, "Delay DVE", 4, "number")
    props:addProperty(group, "Enable Audio", true, "bool")
    lurek.log.info(tostring("added row = " .. row))
end

--@api: LPropertyWidget:getPropertyCount
do

    local props = lurek.ui.newPropertyWidget()
    local group = props:addGroup("Video", false)
    props:addProperty(group, "Contains Alpha", false, "bool")
    props:addProperty(group, "Delay DVE", 1, "number")
    local count = props:getPropertyCount(group)
    lurek.log.info(tostring("property rows = " .. count))
end

--@api: LPropertyWidget:getPropertyValue
do

    local props = lurek.ui.newPropertyWidget()
    local group = props:addGroup("Colorimetry", false)
    props:addProperty(group, "Colorimetry", "Rec. 709", "select", { "Rec. 709", "P3" })
    props:addProperty(group, "Tint", "#55AAFF", "color")
    local value = props:getPropertyValue("Colorimetry")
    lurek.log.info(tostring("colorimetry = " .. tostring(value)))
end

--@api: LPropertyWidget:setPropertyValue
do

    local props = lurek.ui.newPropertyWidget()
    local group = props:addGroup("VBI Settings", false)
    props:addProperty(group, "Delay VBI", 4, "number")
    local changed = props:setPropertyValue("Delay VBI", 14)
    local value = props:getPropertyValue("Delay VBI")
    lurek.log.info(tostring("vbi changed=" .. tostring(changed) .. " value=" .. tostring(value)))
end

--@api: LPropertyWidget:getPropertyType
do

    local props = lurek.ui.newPropertyWidget()
    local group = props:addGroup("Output", false)
    props:addProperty(group, "Enable Audio", true, "boolean")
    props:addProperty(group, "Source Connector", "SDI IN A", "select", { "SDI IN A", "HDMI" })
    local value_type = props:getPropertyType("Enable Audio")
    lurek.log.info(tostring("type = " .. tostring(value_type)))
end

--@api: LPropertyWidget:getPropertyOptions
do

    local props = lurek.ui.newPropertyWidget()
    local group = props:addGroup("Video System", false)
    props:addProperty(group, "Resolution", "UHD - 2160p", "select", { "HD - 1080p", "UHD - 2160p" })
    local options = props:getPropertyOptions("Resolution")
    local first = options[1] or ""
    lurek.log.info(tostring("first option = " .. first))
end

--@api: LPropertyWidget:setLabelWidth
do

    local props = lurek.ui.newPropertyWidget()
    props:setLabelWidth(150)
    props:setSize(340, 180)
    local group = props:addGroup("Inspector", false)
    props:addProperty(group, "Name Column", "150 px", "text")
    lurek.log.info(tostring("label width = " .. props:getLabelWidth()))
end

--@api: LPropertyWidget:getLabelWidth
do

    local props = lurek.ui.newPropertyWidget()
    local before = props:getLabelWidth()
    props:setLabelWidth(120)
    local after = props:getLabelWidth()
    props:addGroup("Columns", false)
    lurek.log.info(tostring("label width before=" .. before .. " after=" .. after))
end

--@api: lurek.ui.newIcon
do

    local icon = lurek.ui.newIcon("settings")
    icon:setSize(28, 28)
    icon:setPosition(12, 12)
    lurek.log.info(tostring("icon type = " .. icon:type()))
    lurek.log.info(tostring("icon name = " .. tostring(icon:getIcon())))
    lurek.log.info(tostring("icon position = " .. icon:getIconPosition()))
end

--@api: LUiWidget:setIcon
do

    local button = lurek.ui.newButton("Save")
    local ok = button:setIcon("save")
    local bad = button:setIcon("missing-icon")
    lurek.log.info(tostring("set icon ok = " .. tostring(ok)))
    lurek.log.info(tostring("set icon bad = " .. tostring(bad)))
    lurek.log.info(tostring("button icon = " .. tostring(button:getIcon())))
end

--@api: LUiWidget:getIcon
do

    local button = lurek.ui.newButton("Inventory")
    local before = button:getIcon()
    button:setIcon("inventory")
    local after = button:getIcon()
    lurek.log.info(tostring("icon before = " .. tostring(before)))
    lurek.log.info(tostring("icon after = " .. tostring(after)))
    lurek.log.info(tostring("button text = " .. button:getText()))
end

--@api: LUiWidget:clearIcon
do

    local button = lurek.ui.newButton("Map")
    button:setIcon("map")
    local before = button:getIcon()
    button:clearIcon()
    lurek.log.info(tostring("icon before clear = " .. tostring(before)))
    lurek.log.info(tostring("icon after clear = " .. tostring(button:getIcon())))
    lurek.log.info(tostring("button text = " .. button:getText()))
end

--@api: LUiWidget:setIconPosition
do

    local button = lurek.ui.newButton("Settings")
    button:setIcon("settings")
    local ok = button:setIconPosition("right")
    local bad = button:setIconPosition("diagonal")
    lurek.log.info(tostring("position ok = " .. tostring(ok)))
    lurek.log.info(tostring("position bad = " .. tostring(bad)))
    lurek.log.info(tostring("position = " .. button:getIconPosition()))
end

--@api: LUiWidget:getIconPosition
do

    local button = lurek.ui.newButton("Play")
    local before = button:getIconPosition()
    button:setIcon("play")
    button:setIconPosition("only")
    lurek.log.info(tostring("position before = " .. before))
    lurek.log.info(tostring("position after = " .. button:getIconPosition()))
    lurek.log.info(tostring("icon = " .. tostring(button:getIcon())))
end

--@api: LUiWidget:setIconSize
do

    local button = lurek.ui.newButton("Zoom")
    button:setIcon("zoom-in")
    local ok = button:setIconSize(18)
    local bad = button:setIconSize(-1)
    lurek.log.info(tostring("size ok = " .. tostring(ok)))
    lurek.log.info(tostring("size bad = " .. tostring(bad)))
    lurek.log.info(tostring("size = " .. button:getIconSize()))
end

--@api: LUiWidget:getIconSize
do

    local button = lurek.ui.newButton("Health")
    local default_size = button:getIconSize()
    button:setIcon("health")
    button:setIconSize(20)
    lurek.log.info(tostring("default size = " .. default_size))
    lurek.log.info(tostring("updated size = " .. button:getIconSize()))
    lurek.log.info(tostring("icon = " .. tostring(button:getIcon())))
end

-- Duplicate coverage lives in content/examples/charts.lua.

--@api: LUiWidget:setShader
do

    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>, @location(2) pixel: vec2<f32>) -> @location(0) vec4<f32> {
    let tint = vec3<f32>(0.15 + uv.x * 0.5, 0.45, 0.9);
    return vec4<f32>(mix(color.rgb, tint, 0.35 + pixel.x * 0.0), color.a);
}
]], { target = "ui" })
    local button = lurek.ui.newButton("Shader Button")
    button:setPosition(24, 24)
    button:setSize(160, 36)
    button:setShader(shader)
    lurek.ui.draw()
    lurek.log.info(tostring("ui widget shader = " .. shader:getTarget()))
end

--@api: LUiWidget:setShaderLayer
do

    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(3) resolution: vec2<f32>) -> @location(0) vec4<f32> {
    let keep = clamp(resolution.x / max(resolution.x, 1.0), 0.0, 1.0);
    return vec4<f32>(color.rgb * vec3<f32>(keep, 0.85, 1.15), color.a);
}
]], { target = "ui" })
    local panel = lurek.ui.newPanel()
    panel:setPosition(16, 80)
    panel:setSize(220, 96)
    panel:setShaderLayer("panel_tint", shader)
    lurek.ui.draw()
    panel:setShaderLayer("panel_tint", nil)
    lurek.log.info(tostring("ui shader layer cleared"))
end

--@api: LUiWidget:setDragEnabled
do
    local source = lurek.ui.newButton("Drag source")
    local enabled = source:setDragEnabled(true)
    source:setPosition(20, 20)
    source:setSize(120, 32)
    lurek.log.info(tostring("drag enabled = " .. tostring(enabled)))
end

--@api: LUiWidget:isDragEnabled
do
    local source = lurek.ui.newButton("Drag source")
    local before = source:isDragEnabled()
    source:setDragEnabled(true)
    local after = source:isDragEnabled()
    lurek.log.info(tostring("drag flags = " .. tostring(before) .. ", " .. tostring(after)))
end

--@api: LUiWidget:setDropEnabled
do
    local target = lurek.ui.newPanel()
    local enabled = target:setDropEnabled(true)
    target:setPosition(180, 20)
    target:setSize(140, 80)
    lurek.log.info(tostring("drop enabled = " .. tostring(enabled)))
end

--@api: LUiWidget:isDropEnabled
do
    local target = lurek.ui.newPanel()
    local before = target:isDropEnabled()
    target:setDropEnabled(true)
    local after = target:isDropEnabled()
    lurek.log.info(tostring("drop flags = " .. tostring(before) .. ", " .. tostring(after)))
end

--@api: LUiWidget:setOnDragStart
do
    local source = lurek.ui.newButton("Drag source")
    source:setDragEnabled(true)
    source:setOnDragStart(function(source_idx)
        lurek.log.info(tostring("drag started by " .. source_idx))
    end)
    lurek.ui.beginDrag(source)
    lurek.ui.update(0)
end

--@api: LUiWidget:isValid
do
    local widget = lurek.ui.newButton("Lifecycle")
    lurek.log.info(tostring("live=" .. tostring(widget:isValid())))
end

--@api: LUiWidget:destroy
do
    local widget = lurek.ui.newButton("Destroy me")
    widget:destroy()
end

--@api: lurek.ui.destroy
do
    local widget = lurek.ui.newButton("Destroy me")
    lurek.ui.destroy(widget)
end

--@api: LUiWidget:setOnDragEnd
do
    local source = lurek.ui.newButton("Drag source")
    source:setOnDragEnd(function(source_idx, target_idx)
        lurek.log.info(tostring("drag ended " .. source_idx .. " -> " .. tostring(target_idx)))
    end)
    lurek.ui.beginDrag(source)
    lurek.ui.endDrag()
    lurek.ui.update(0)
end

--@api: LUiWidget:setOnDragEnter
do
    local target = lurek.ui.newPanel()
    target:setDropEnabled(true)
    target:setOnDragEnter(function(source_idx, target_idx)
        lurek.log.info(tostring("drag entered " .. source_idx .. " -> " .. target_idx))
    end)
    target:setPosition(180, 20)
    target:setSize(140, 80)
end

--@api: LUiWidget:setOnDragLeave
do
    local target = lurek.ui.newPanel()
    target:setDropEnabled(true)
    target:setOnDragLeave(function(source_idx, target_idx)
        lurek.log.info(tostring("drag left " .. source_idx .. " -> " .. target_idx))
    end)
    target:setPosition(180, 20)
    target:setSize(140, 80)
end

--@api: LUiWidget:setOnDrop
do
    local source = lurek.ui.newButton("Drag source")
    local target = lurek.ui.newPanel()
    target:setDropEnabled(true)
    target:setOnDrop(function(source_idx, target_idx)
        lurek.log.info(tostring("dropped " .. source_idx .. " -> " .. target_idx))
    end)
    lurek.ui.beginDrag(source)
    lurek.ui.dropOn(target)
    lurek.ui.update(0)
end
