-- content/examples/ui.lua
-- Auto-generated from content/examples2/ui_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/ui.lua

--- UI Module Part 1: core widgets (button, label, panel) and base LUiWidget operations


--@api: lurek.ui.newButton
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LButton
    local btn = lurek.ui.newButton("Click Me")
    example_print_log("type = " .. btn:type())
    example_print_log("text = " .. btn:getText())
    example_print_log("button text = " .. btn:getText())
    example_print_log("button width = " .. select(3, btn:getRect()))
end

--@api: LButton:setOnClick
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LButton
    local btn = lurek.ui.newButton("Submit")
    btn:setOnClick(function()
        example_print_log("button clicked!")
    end)
    btn:setId("submit_btn")
    example_print_log("button id = " .. btn:getId())
end

--@api: lurek.ui.newLabel
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lbl = lurek.ui.newLabel("Hello, World!")
    example_print_log("type = " .. lbl:type())
    example_print_log("text = " .. lbl:getText())
    lbl:setText("Score: 100")
    example_print_log("updated text = " .. lbl:getText())
end

--@api: lurek.ui.newPanel
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LPanel
    local panel = lurek.ui.newPanel()
    example_print_log("type = " .. panel:type())
    example_print_log("child count = " .. panel:getChildCount())
    example_print_log("visible = " .. tostring(panel:isVisible()))
    example_print_log("panel children = " .. panel:getChildCount())
end

--@api: LUiWidget:setPosition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LButton
    local btn = lurek.ui.newButton("Pos Test")
    btn:setPosition(100, 50)
    local x, y = btn:getPosition()
    example_print_log("position = " .. x .. ", " .. y)
    example_print_log("button text = " .. btn:getText())
end

--@api: LUiWidget:getPosition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LButton
    local btn = lurek.ui.newButton("Pos Test")
    btn:setPosition(100, 50)
    local x, y = btn:getPosition()
    example_print_log("position = " .. x .. ", " .. y)
    example_print_log("button text = " .. btn:getText())
end

--@api: LUiWidget:setSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setSize(300, 200)
    local w, h = panel:getSize()
    example_print_log("size = " .. w .. "x" .. h)
    example_print_log("panel children = " .. panel:getChildCount())
end

--@api: LUiWidget:getSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setSize(300, 200)
    local w, h = panel:getSize()
    example_print_log("size = " .. w .. "x" .. h)
    example_print_log("panel children = " .. panel:getChildCount())
end

--@api: LUiWidget:getRect
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn = lurek.ui.newButton("Bounds")
    btn:setPosition(50, 30)
    btn:setSize(120, 40)
    local x, y, w, h = btn:getRect()
    example_print_log("rect = " .. x .. "," .. y .. " " .. w .. "x" .. h)
end

--@api: LUiWidget:isVisible
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LLabel
    local lbl = lurek.ui.newLabel("Toggle Me")
    example_print_log("visible = " .. tostring(lbl:isVisible()))
    lbl:setVisible(false)
    example_print_log("hidden = " .. tostring(lbl:isVisible()))
    example_print_log("label text = " .. lbl:getText())
end

--@api: LUiWidget:setVisible
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LLabel
    local lbl = lurek.ui.newLabel("Toggle Me")
    lbl:setVisible(false)
    example_print_log("hidden = " .. tostring(lbl:isVisible()))
    example_print_log("label text = " .. lbl:getText())
    example_print_log("label width = " .. select(3, lbl:getRect()))
end

--@api: LUiWidget:isEnabled
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LButton
    local btn = lurek.ui.newButton("Action")
    example_print_log("enabled = " .. tostring(btn:isEnabled()))
    btn:setEnabled(false)
    example_print_log("disabled = " .. tostring(btn:isEnabled()))
    example_print_log("button text = " .. btn:getText())
end

--@api: LUiWidget:setEnabled
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LButton
    local btn = lurek.ui.newButton("Action")
    btn:setEnabled(false)
    example_print_log("disabled = " .. tostring(btn:isEnabled()))
    example_print_log("button text = " .. btn:getText())
    example_print_log("button width = " .. select(3, btn:getRect()))
end

--@api: LUiWidget:getAlpha
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local panel = lurek.ui.newPanel()
    example_print_log("alpha = " .. panel:getAlpha())
    panel:setAlpha(0.5)
    example_print_log("set to 50% = " .. panel:getAlpha())
    panel:setAlpha(1.0)
end

--@api: LUiWidget:setAlpha
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local panel = lurek.ui.newPanel()
    example_print_log("alpha = " .. panel:getAlpha())
    panel:setAlpha(0.5)
    example_print_log("set to 50% = " .. panel:getAlpha())
    panel:setAlpha(1.0)
end

--@api: LUiWidget:animateAlpha
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn = lurek.ui.newButton("Fade")
    btn:setAlpha(1.0)
    btn:animateAlpha(0.0, 0.5)
    example_print_log("animating = " .. tostring(btn:isAnimating()))
    btn:cancelAnimations()
    btn:animateAlpha(0.0, 0.3, true)
    example_print_log("fade-out with hide_on_complete started")
end

--@api: LUiWidget:fadeIn
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LLabel
    local lbl = lurek.ui.newLabel("Fading")
    lbl:setAlpha(0)
    lbl:fadeIn()
    example_print_log("fading in, animating = " .. tostring(lbl:isAnimating()))
    example_print_log("label text = " .. lbl:getText())
end

--@api: LUiWidget:fadeOut
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LLabel
    local lbl = lurek.ui.newLabel("Fading")
    lbl:fadeOut()
    example_print_log("fading out")
    example_print_log("label text = " .. lbl:getText())
    example_print_log("label width = " .. select(3, lbl:getRect()))
end

--@api: LUiWidget:animatePosition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local panel = lurek.ui.newPanel()
    panel:setPosition(0, 0)
    panel:animatePosition(200, 100, 0.5)
    example_print_log("animating = " .. tostring(panel:isAnimating()))
    example_print_log("target = 200, 100")
end

--@api: LUiWidget:slideIn
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local panel = lurek.ui.newPanel()
    panel:cancelAnimations()
    panel:slideIn(300, 0)
    local x, y = panel:getPosition()
    example_print_log("visible = " .. tostring(panel:isVisible()))
    example_print_log("position = " .. x .. ", " .. y)
end

--@api: LUiWidget:slideOut
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local panel = lurek.ui.newPanel()
    panel:setVisible(true)
    panel:setPosition(40, 20)
    panel:slideOut(320, 20)
    local x, y = panel:getPosition()
    example_print_log("visible = " .. tostring(panel:isVisible()))
    example_print_log("position = " .. x .. ", " .. y)
end

--@api: LUiWidget:setId
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    example_print_log("id = " .. btn:getId())
    example_print_log("tooltip = " .. btn:getTooltip())
end

--@api: LUiWidget:getId
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    example_print_log("id = " .. btn:getId())
    example_print_log("tooltip = " .. btn:getTooltip())
end

--@api: LUiWidget:setTooltip
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    example_print_log("id = " .. btn:getId())
    example_print_log("tooltip = " .. btn:getTooltip())
end

--@api: LUiWidget:getTooltip
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    example_print_log("id = " .. btn:getId())
    example_print_log("tooltip = " .. btn:getTooltip())
end

--@api: LUiWidget:setZOrder
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local front = lurek.ui.newPanel()
    local back = lurek.ui.newPanel()
    front:setZOrder(10)
    back:setZOrder(1)
    example_print_log("front z = " .. front:getZOrder())
    example_print_log("back z = " .. back:getZOrder())
end

--@api: LUiWidget:getZOrder
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local front = lurek.ui.newPanel()
    local back = lurek.ui.newPanel()
    front:setZOrder(10)
    back:setZOrder(1)
    example_print_log("front z = " .. front:getZOrder())
    example_print_log("back z = " .. back:getZOrder())
end

--@api: LUiWidget:containsPoint
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn = lurek.ui.newButton("Hit Test")
    btn:setPosition(50, 50)
    btn:setSize(100, 40)
    example_print_log("(75,60) inside = " .. tostring(btn:containsPoint(75, 60)))
    example_print_log("(200,200) inside = " .. tostring(btn:containsPoint(200, 200)))
end

--@api: LUiWidget:getState
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LButton
    local btn = lurek.ui.newButton("State")
    local state = btn:getState()
    example_print_log("state = " .. state)
    example_print_log("button text = " .. btn:getText())
    example_print_log("button width = " .. select(3, btn:getRect()))
end

--@api: lurek.ui.getRoot
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local root = lurek.ui.getRoot()
    example_print_log("root = " .. tostring(root))
    example_print_log("widget count = " .. lurek.ui.getWidgetCount())
    example_print_log("root widgets = " .. lurek.ui.getWidgetCount())
    example_print_log("focus exists = " .. tostring(lurek.ui.getFocus() ~= nil))
end

--@api: lurek.ui.update
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local before = lurek.ui.getWidgetCount()
    lurek.ui.update(1 / 60)
    lurek.ui.draw()
    local after = lurek.ui.getWidgetCount()
    example_print_log("UI frame processed")
    example_print_log("widgets before=" .. before .. " after=" .. after)
end

--- UI Module Part 2: layout, containers (DockPanel, SplitPanel, ScrollPanel), flex, margin, padding

--@api: lurek.ui.newLayout
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local row = lurek.ui.newLayout("horizontal")
    example_print_log("type = " .. row:type())
    example_print_log("direction = " .. row:getDirection())
    example_print_log("spacing = " .. row:getSpacing())

    local col = lurek.ui.newLayout("vertical")
    col:setSpacing(10)
    example_print_log("direction = " .. col:getDirection())
    example_print_log("spacing = " .. col:getSpacing())
end

--@api: LLayout:setDirection
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LLayout
    local grid = lurek.ui.newLayout("grid")
    grid:setDirection("vertical")
    grid:setColumns(3)
    grid:setSpacing(5)
    example_print_log("direction = " .. grid:getDirection())
end

--@api: LLayout:setColumns
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LLayout
    local grid = lurek.ui.newLayout("grid")
    grid:setColumns(3)
    grid:setSpacing(5)
    example_print_log("direction = " .. grid:getDirection())
    example_print_log("layout direction = " .. grid:getDirection())
end

--@api: LLayout:setAlign
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local layout = lurek.ui.newLayout("horizontal")
    layout:setAlign("center")
    example_print_log("align = " .. layout:getAlign())
    layout:setAlign("stretch")
    example_print_log("align = " .. layout:getAlign())
end

--@api: LLayout:getAlign
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local layout = lurek.ui.newLayout("horizontal")
    layout:setAlign("center")
    example_print_log("align = " .. layout:getAlign())
    layout:setAlign("stretch")
    example_print_log("align = " .. layout:getAlign())
end

--@api: LLayout:setJustify
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local layout = lurek.ui.newLayout("horizontal")
    layout:setJustify("space-between")
    example_print_log("justify = " .. layout:getJustify())
    layout:setJustify("center")
    example_print_log("justify = " .. layout:getJustify())
end

--@api: LLayout:getJustify
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local layout = lurek.ui.newLayout("horizontal")
    layout:setJustify("space-between")
    example_print_log("justify = " .. layout:getJustify())
    layout:setJustify("center")
    example_print_log("justify = " .. layout:getJustify())
end

--@api: LLayout:setWrap
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LLayout
    local layout = lurek.ui.newLayout("horizontal")
    example_print_log("wrap = " .. tostring(layout:getWrap()))
    layout:setWrap(true)
    example_print_log("wrap enabled = " .. tostring(layout:getWrap()))
    example_print_log("layout direction = " .. layout:getDirection())
end

--@api: LLayout:getWrap
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LLayout
    local layout = lurek.ui.newLayout("horizontal")
    example_print_log("wrap = " .. tostring(layout:getWrap()))
    layout:setWrap(true)
    example_print_log("wrap enabled = " .. tostring(layout:getWrap()))
    example_print_log("layout direction = " .. layout:getDirection())
end

--@api: LUiWidget:addChild
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local layout = lurek.ui.newLayout("vertical")
    local btn1 = lurek.ui.newButton("First")
    local btn2 = lurek.ui.newButton("Second")
    local btn3 = lurek.ui.newButton("Third")
    layout:addChild(btn1)
    layout:addChild(btn2)
    layout:addChild(btn3)
    example_print_log("children = " .. layout:getChildCount())
    layout:removeChild(btn2)
    example_print_log("after remove = " .. layout:getChildCount())
end

--@api: LUiWidget:removeChild
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local layout = lurek.ui.newLayout("vertical")
    local btn1 = lurek.ui.newButton("First")
    local btn2 = lurek.ui.newButton("Second")
    local btn3 = lurek.ui.newButton("Third")
    layout:addChild(btn1)
    layout:addChild(btn2)
    layout:addChild(btn3)
    example_print_log("children = " .. layout:getChildCount())
    layout:removeChild(btn2)
    example_print_log("after remove = " .. layout:getChildCount())
end

--@api: LUiWidget:getChildCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local layout = lurek.ui.newLayout("vertical")
    local btn1 = lurek.ui.newButton("First")
    local btn2 = lurek.ui.newButton("Second")
    local btn3 = lurek.ui.newButton("Third")
    layout:addChild(btn1)
    layout:addChild(btn2)
    layout:addChild(btn3)
    example_print_log("children = " .. layout:getChildCount())
    layout:removeChild(btn2)
    example_print_log("after remove = " .. layout:getChildCount())
end

--@api: LUiWidget:getChildren
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local panel = lurek.ui.newPanel()
    panel:addChild(lurek.ui.newLabel("A"))
    panel:addChild(lurek.ui.newLabel("B"))
    panel:addChild(lurek.ui.newLabel("C"))
    local children = panel:getChildren()
    example_print_log("child list length = " .. #children)
end

--@api: LUiWidget:setMargin
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn = lurek.ui.newButton("Margin")
    btn:setMargin(10, 20, 10, 20)
    local top, right, bottom, left = btn:getMargin()
    example_print_log("margin = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
    btn:setMargin(5)
    top, right, bottom, left = btn:getMargin()
    example_print_log("uniform = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
end

--@api: LUiWidget:getMargin
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn = lurek.ui.newButton("Margin")
    btn:setMargin(10, 20, 10, 20)
    local top, right, bottom, left = btn:getMargin()
    example_print_log("margin = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
    btn:setMargin(5)
    top, right, bottom, left = btn:getMargin()
    example_print_log("uniform = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
end

--@api: LUiWidget:setPadding
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setPadding(8, 16, 8, 16)
    local top, right, bottom, left = panel:getPadding()
    example_print_log("padding = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
    example_print_log("panel children = " .. panel:getChildCount())
end

--@api: LUiWidget:getPadding
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setPadding(8, 16, 8, 16)
    local top, right, bottom, left = panel:getPadding()
    example_print_log("padding = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
    example_print_log("panel children = " .. panel:getChildCount())
end

--@api: LUiWidget:setFlexGrow
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local row = lurek.ui.newLayout("horizontal")
    local left = lurek.ui.newPanel()
    local right = lurek.ui.newPanel()
    left:setFlexGrow(1)
    right:setFlexGrow(2)
    row:addChild(left)
    row:addChild(right)
    example_print_log("left grow = " .. left:getFlexGrow())
    example_print_log("right grow = " .. right:getFlexGrow())
end

--@api: LUiWidget:getFlexGrow
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local row = lurek.ui.newLayout("horizontal")
    local left = lurek.ui.newPanel()
    local right = lurek.ui.newPanel()
    left:setFlexGrow(1)
    right:setFlexGrow(2)
    row:addChild(left)
    row:addChild(right)
    example_print_log("left grow = " .. left:getFlexGrow())
    example_print_log("right grow = " .. right:getFlexGrow())
end

--@api: LUiWidget:setFlexShrink
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn = lurek.ui.newButton("Shrinkable")
    btn:setFlexShrink(0)
    example_print_log("shrink = " .. btn:getFlexShrink())
    btn:setFlexShrink(1)
    example_print_log("shrink = " .. btn:getFlexShrink())
end

--@api: LUiWidget:getFlexShrink
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn = lurek.ui.newButton("Shrinkable")
    btn:setFlexShrink(0)
    example_print_log("shrink = " .. btn:getFlexShrink())
    btn:setFlexShrink(1)
    example_print_log("shrink = " .. btn:getFlexShrink())
end

--@api: LUiWidget:setMinSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local panel = lurek.ui.newPanel()
    panel:setMinSize(100, 50)
    local minW, minH = panel:getMinSize()
    example_print_log("min = " .. minW .. "x" .. minH)
    panel:setMaxSize(400, 300)
    local maxW, maxH = panel:getMaxSize()
    example_print_log("max = " .. maxW .. "x" .. maxH)
end

--@api: LUiWidget:getMinSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local panel = lurek.ui.newPanel()
    panel:setMinSize(100, 50)
    local minW, minH = panel:getMinSize()
    example_print_log("min = " .. minW .. "x" .. minH)
    panel:setMaxSize(400, 300)
    local maxW, maxH = panel:getMaxSize()
    example_print_log("max = " .. maxW .. "x" .. maxH)
end

--@api: LUiWidget:setMaxSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local panel = lurek.ui.newPanel()
    panel:setMinSize(100, 50)
    local minW, minH = panel:getMinSize()
    example_print_log("min = " .. minW .. "x" .. minH)
    panel:setMaxSize(400, 300)
    local maxW, maxH = panel:getMaxSize()
    example_print_log("max = " .. maxW .. "x" .. maxH)
end

--@api: LUiWidget:getMaxSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local panel = lurek.ui.newPanel()
    panel:setMinSize(100, 50)
    local minW, minH = panel:getMinSize()
    example_print_log("min = " .. minW .. "x" .. minH)
    panel:setMaxSize(400, 300)
    local maxW, maxH = panel:getMaxSize()
    example_print_log("max = " .. maxW .. "x" .. maxH)
end

--@api: LUiWidget:setAnchor
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn = lurek.ui.newButton("Anchored")
    btn:setAnchor(10, 10, 10, nil)
    example_print_log("anchors applied")
    btn:clearAnchor()
    btn:setAnchorCenter(0.5, 0.5)
    example_print_log("center anchor applied")
end

--@api: LUiWidget:setAnchorCenter
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn = lurek.ui.newButton("Anchored")
    btn:setAnchor(10, 10, 10, nil)
    example_print_log("anchors applied")
    btn:clearAnchor()
    btn:setAnchorCenter(0.5, 0.5)
    example_print_log("center anchor applied")
end

--@api: LUiWidget:clearAnchor
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn = lurek.ui.newButton("Anchored")
    btn:setAnchor(10, 10, 10, nil)
    example_print_log("anchors applied")
    btn:clearAnchor()
    btn:setAnchorCenter(0.5, 0.5)
    example_print_log("center anchor applied")
end

--@api: lurek.ui.newDockPanel
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dock = lurek.ui.newDockPanel()
    local header = lurek.ui.newPanel()
    local sidebar = lurek.ui.newPanel()
    example_print_log("type = " .. dock:type())
    header:setSize(0, 60)
    sidebar:setSize(200, 0)
    dock:addChild(header)
    dock:addChild(sidebar)
    dock:dock(header._idx, "top")
    dock:dock(sidebar._idx, "left")
    dock:setSplitSize("left", 200)
    dock:setSplitSize("top", 60)
    example_print_log("docked count = " .. dock:getDockedCount())
    example_print_log("left size = " .. dock:getSplitSize("left"))
end

--@api: LDockPanel:undock
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dock = lurek.ui.newDockPanel()
    local footer = lurek.ui.newPanel()
    dock:addChild(footer)
    dock:dock(footer._idx, "bottom")
    example_print_log("docked = " .. dock:getDockedCount())
    dock:undock(footer._idx)
    example_print_log("after undock = " .. dock:getDockedCount())
end

--@api: lurek.ui.newSplitPanel
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local split = lurek.ui.newSplitPanel("horizontal")
    local left = lurek.ui.newPanel()
    local right = lurek.ui.newPanel()
    example_print_log("type = " .. split:type())
    example_print_log("orientation = " .. split:getOrientation())
    split:setFirstChild(left._idx)
    split:setSecondChild(right._idx)
    split:setSplitPosition(0.3)
    split:setMinPanelSize(100)
    example_print_log("split at " .. split:getSplitPosition())
    example_print_log("min panel = " .. split:getMinPanelSize())
end

--@api: lurek.ui.newScrollPanel
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local scroll = lurek.ui.newScrollPanel()
    example_print_log("type = " .. scroll:type())
    scroll:setContentSize(1200, 2000)
    local cw, ch = scroll:getContentSize()
    example_print_log("content size = " .. cw .. "x" .. ch)
    scroll:setScrollPosition(0, 100)
    local sx, sy = scroll:getScrollPosition()
    example_print_log("scroll pos = " .. sx .. ", " .. sy)
    local mx, my = scroll:getMaxScroll()
    example_print_log("max scroll = " .. mx .. ", " .. my)
end

--@api: LScrollPanel:setScrollSpeed
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LScrollPanel
    local scroll = lurek.ui.newScrollPanel()
    scroll:setScrollSpeed(30)
    example_print_log("scroll speed = " .. scroll:getScrollSpeed())
    example_print_log("scroll x = " .. select(1, scroll:getScrollPosition()))
    example_print_log("scroll y = " .. select(2, scroll:getScrollPosition()))
end

--@api: LScrollPanel:getScrollSpeed
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LScrollPanel
    local scroll = lurek.ui.newScrollPanel()
    scroll:setScrollSpeed(30)
    example_print_log("scroll speed = " .. scroll:getScrollSpeed())
    example_print_log("scroll x = " .. select(1, scroll:getScrollPosition()))
    example_print_log("scroll y = " .. select(2, scroll:getScrollPosition()))
end

--@api: LUiWidget:findById
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local root = lurek.ui.newLayout("vertical")
    local btn = lurek.ui.newButton("Find Me")
    btn:setId("target_btn")
    root:addChild(btn)
    local found = root:findById("target_btn")
    example_print_log("found = " .. tostring(found ~= nil))
end

--- UI Module Part 3: input widgets â€” TextInput, Checkbox, Slider, SpinBox, Switch, ComboBox

--@api: lurek.ui.newTextInput
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local input = lurek.ui.newTextInput()
    example_print_log("type = " .. input:type())
    example_print_log("text = '" .. input:getText() .. "'")
    input:setText("Hello")
    example_print_log("set text = " .. input:getText())
end

--@api: LTextInput:setPlaceholder
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LTextInput
    local input = lurek.ui.newTextInput()
    input:setPlaceholder("Enter your name...")
    example_print_log("placeholder = " .. input:getPlaceholder())
    example_print_log("text value = " .. input:getText())
    example_print_log("placeholder = " .. input:getPlaceholder())
end

--@api: LTextInput:getPlaceholder
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LTextInput
    local input = lurek.ui.newTextInput()
    input:setPlaceholder("Enter your name...")
    example_print_log("placeholder = " .. input:getPlaceholder())
    example_print_log("text value = " .. input:getText())
    example_print_log("placeholder = " .. input:getPlaceholder())
end

--@api: LTextInput:setMaxLength
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local input = lurek.ui.newTextInput()
    input:setMaxLength(50)
    input:setText("Short text")
    local pos = input:getCursorPosition()
    example_print_log("cursor at = " .. pos)
    example_print_log("focused = " .. tostring(input:isFocused()))
end

--@api: LTextInput:getCursorPosition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local input = lurek.ui.newTextInput()
    input:setMaxLength(50)
    input:setText("Short text")
    local pos = input:getCursorPosition()
    example_print_log("cursor at = " .. pos)
    example_print_log("focused = " .. tostring(input:isFocused()))
end

--@api: LTextInput:setSubmitOnEnter
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local input = lurek.ui.newTextInput()
    input:setSubmitOnEnter(false)
    input:setText("Confirm name")
    example_print_log("submit_on_enter = " .. tostring(input:getSubmitOnEnter()))
    example_print_log("text = " .. input:getText())
end

--@api: LTextInput:getSubmitOnEnter
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local input = lurek.ui.newTextInput()
    input:setSubmitOnEnter(false)
    example_print_log("submit_on_enter = " .. tostring(input:getSubmitOnEnter()))
    example_print_log("focused = " .. tostring(input:isFocused()))
    example_print_log("text = " .. input:getText())
end

--@api: lurek.ui.newCheckbox
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LCheckbox
    local cb = lurek.ui.newCheckbox("Enable Sound")
    example_print_log("type = " .. cb:type())
    example_print_log("text = " .. cb:getText())
    example_print_log("checked = " .. tostring(cb:isChecked()))
    example_print_log("checkbox text = " .. cb:getText())
end

--@api: LCheckbox:setChecked
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cb = lurek.ui.newCheckbox("Option A")
    cb:setChecked(true)
    example_print_log("checked = " .. tostring(cb:isChecked()))
    cb:setText("Option B")
    example_print_log("text = " .. cb:getText())
    cb:setChecked(false)
    example_print_log("unchecked = " .. tostring(cb:isChecked()))
end

--@api: LCheckbox:setText
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cb = lurek.ui.newCheckbox("Option A")
    cb:setChecked(true)
    example_print_log("checked = " .. tostring(cb:isChecked()))
    cb:setText("Option B")
    example_print_log("text = " .. cb:getText())
    cb:setChecked(false)
    example_print_log("unchecked = " .. tostring(cb:isChecked()))
end

--@api: LCheckbox:setOnChange
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LCheckbox
    local cb = lurek.ui.newCheckbox("Fullscreen")
    cb:setOnChange(function()
        example_print_log("checkbox changed, now = " .. tostring(cb:isChecked()))
    end)
    example_print_log("change callback registered")
end

--@api: lurek.ui.newSlider
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local slider = lurek.ui.newSlider(0, 100)
    example_print_log("type = " .. slider:type())
    example_print_log("min = " .. slider:getMin())
    example_print_log("max = " .. slider:getMax())
    example_print_log("value = " .. slider:getValue())
end

--@api: LSlider:setValue
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local slider = lurek.ui.newSlider(0, 1)
    slider:setStep(0.1)
    slider:setValue(0.5)
    example_print_log("value = " .. slider:getValue())
    slider:setValue(1.5)
    example_print_log("clamped = " .. slider:getValue())
end

--@api: LSlider:setStep
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local slider = lurek.ui.newSlider(0, 1)
    slider:setStep(0.1)
    slider:setValue(0.5)
    example_print_log("value = " .. slider:getValue())
    slider:setValue(1.5)
    example_print_log("clamped = " .. slider:getValue())
end

--@api: LSlider:setRange
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local slider = lurek.ui.newSlider(0, 10)
    slider:setValue(5)
    example_print_log("before: " .. slider:getMin() .. " to " .. slider:getMax() .. " val=" .. slider:getValue())
    slider:setRange(0, 100)
    example_print_log("after: " .. slider:getMin() .. " to " .. slider:getMax() .. " val=" .. slider:getValue())
end

--@api: lurek.ui.newSpinBox
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local spin = lurek.ui.newSpinBox(1, 99)
    example_print_log("type = " .. spin:type())
    example_print_log("value = " .. spin:getValue())
    spin:setValue(50)
    example_print_log("set to 50 = " .. spin:getValue())
end

--@api: LSpinBox:increment
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local spin = lurek.ui.newSpinBox(0, 100)
    spin:setValue(10)
    spin:setStep(5)
    spin:increment()
    example_print_log("after increment = " .. spin:getValue())
    spin:decrement()
    spin:decrement()
    example_print_log("after 2 decrements = " .. spin:getValue())
end

--@api: LSpinBox:decrement
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local spin = lurek.ui.newSpinBox(0, 100)
    spin:setValue(10)
    spin:setStep(5)
    spin:increment()
    example_print_log("after increment = " .. spin:getValue())
    spin:decrement()
    spin:decrement()
    example_print_log("after 2 decrements = " .. spin:getValue())
end

--@api: LSpinBox:setStep
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local spin = lurek.ui.newSpinBox(0, 100)
    spin:setValue(10)
    spin:setStep(5)
    spin:increment()
    example_print_log("after increment = " .. spin:getValue())
    spin:decrement()
    spin:decrement()
    example_print_log("after 2 decrements = " .. spin:getValue())
end

--@api: LSpinBox:setRange
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LSpinBox
    local spin = lurek.ui.newSpinBox(0, 10)
    spin:setValue(8)
    spin:setRange(0, 5)
    example_print_log("clamped to range = " .. spin:getValue())
    example_print_log("rect x = " .. select(1, spin:getRect()))
end

--@api: lurek.ui.newSwitch
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LSwitch
    local sw = lurek.ui.newSwitch(false)
    example_print_log("type = " .. sw:type())
    example_print_log("on = " .. tostring(sw:isOn()))
    example_print_log("switch on = " .. tostring(sw:isOn()))
    example_print_log("switch width = " .. select(3, sw:getRect()))
end

--@api: LSwitch:setOn
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sw = lurek.ui.newSwitch(true)
    example_print_log("initial = " .. tostring(sw:isOn()))
    sw:toggle()
    example_print_log("toggled = " .. tostring(sw:isOn()))
    sw:setOn(true)
    example_print_log("forced on = " .. tostring(sw:isOn()))
end

--@api: LSwitch:toggle
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sw = lurek.ui.newSwitch(true)
    example_print_log("initial = " .. tostring(sw:isOn()))
    sw:toggle()
    example_print_log("toggled = " .. tostring(sw:isOn()))
    sw:setOn(true)
    example_print_log("forced on = " .. tostring(sw:isOn()))
end

--@api: lurek.ui.newComboBox
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LComboBox
    local combo = lurek.ui.newComboBox()
    example_print_log("type = " .. combo:type())
    example_print_log("items = " .. combo:getItemCount())
    example_print_log("item count = " .. combo:getItemCount())
    example_print_log("selected index = " .. tostring(combo:getSelectedIndex()))
end

--@api: LComboBox:addItem
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local combo = lurek.ui.newComboBox()
    combo:addItem("Easy")
    combo:addItem("Normal")
    combo:addItem("Hard")
    combo:addItem("Nightmare")
    example_print_log("item count = " .. combo:getItemCount())
    example_print_log("item 2 = " .. combo:getItem(2))
    example_print_log("item 4 = " .. combo:getItem(4))
end

--@api: LComboBox:getItem
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local combo = lurek.ui.newComboBox()
    combo:addItem("Easy")
    combo:addItem("Normal")
    combo:addItem("Hard")
    combo:addItem("Nightmare")
    example_print_log("item count = " .. combo:getItemCount())
    example_print_log("item 2 = " .. combo:getItem(2))
    example_print_log("item 4 = " .. combo:getItem(4))
end

--@api: LComboBox:getItemCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local combo = lurek.ui.newComboBox()
    combo:addItem("Easy")
    combo:addItem("Normal")
    combo:addItem("Hard")
    combo:addItem("Nightmare")
    example_print_log("item count = " .. combo:getItemCount())
    example_print_log("item 2 = " .. combo:getItem(2))
    example_print_log("item 4 = " .. combo:getItem(4))
end

--@api: LComboBox:getSelectedIndex
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local combo = lurek.ui.newComboBox()
    combo:addItem("Red")
    combo:addItem("Green")
    combo:addItem("Blue")
    combo:setSelectedIndex(2)
    local idx = combo:getSelectedIndex()
    local item = combo:getSelectedItem()
    example_print_log("selected index = " .. idx)
    example_print_log("selected item = " .. tostring(item))
    combo:clearItems()
    example_print_log("after clear = " .. combo:getItemCount())
end

--@api: LComboBox:getSelectedItem
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local combo = lurek.ui.newComboBox()
    combo:addItem("Red")
    combo:addItem("Green")
    combo:addItem("Blue")
    combo:setSelectedIndex(2)
    local idx = combo:getSelectedIndex()
    local item = combo:getSelectedItem()
    example_print_log("selected index = " .. idx)
    example_print_log("selected item = " .. tostring(item))
    combo:clearItems()
    example_print_log("after clear = " .. combo:getItemCount())
end

--@api: LComboBox:clearItems
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local combo = lurek.ui.newComboBox()
    combo:addItem("Red")
    combo:addItem("Green")
    combo:addItem("Blue")
    combo:setSelectedIndex(2)
    local idx = combo:getSelectedIndex()
    local item = combo:getSelectedItem()
    example_print_log("selected index = " .. idx)
    example_print_log("selected item = " .. tostring(item))
    combo:clearItems()
    example_print_log("after clear = " .. combo:getItemCount())
end

--@api: LComboBox:setMaxVisibleItems
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local combo = lurek.ui.newComboBox()
    combo:addItem("Easy")
    combo:addItem("Normal")
    combo:addItem("Hard")
    combo:addItem("Nightmare")
    combo:setMaxVisibleItems(3)
    example_print_log("max visible = " .. combo:getMaxVisibleItems())
    example_print_log("item count = " .. combo:getItemCount())
end

--@api: LComboBox:getMaxVisibleItems
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local combo = lurek.ui.newComboBox()
    combo:setMaxVisibleItems(3)
    example_print_log("max visible = " .. combo:getMaxVisibleItems())
    example_print_log("selected index = " .. tostring(combo:getSelectedIndex()))
    example_print_log("item count = " .. combo:getItemCount())
end

--@api: lurek.ui.setFocus
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local input = lurek.ui.newTextInput()
    lurek.ui.setFocus(input)
    local focused = lurek.ui.getFocus()
    example_print_log("focus set, has focus = " .. tostring(focused ~= nil))
    lurek.ui.clearFocus()
    focused = lurek.ui.getFocus()
    example_print_log("after clear = " .. tostring(focused))
end

--@api: lurek.ui.focusNext
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.ui.newTextInput()
    local b = lurek.ui.newTextInput()
    local c = lurek.ui.newTextInput()
    lurek.ui.setFocus(a)
    lurek.ui.focusNext()
    example_print_log("moved focus forward")
    lurek.ui.focusPrev()
    example_print_log("moved focus back")
end

--- UI Module Part 4: lists, menus, tabs, accordion

--@api: lurek.ui.newList
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LListBox
    local list = lurek.ui.newList()
    example_print_log("type = " .. list:type())
    example_print_log("items = " .. list:getItemCount())
    example_print_log("list count = " .. list:getItemCount())
    example_print_log("list width = " .. select(3, list:getRect()))
end

--@api: LListBox:addItem
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local list = lurek.ui.newList()
    list:addItem("Sword")
    list:addItem("Shield")
    list:addItem("Potion")
    list:addItem("Scroll")
    example_print_log("count = " .. list:getItemCount())
    example_print_log("item 1 = " .. list:getItem(1))
    example_print_log("item 3 = " .. list:getItem(3))
end

--@api: LListBox:getItem
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local list = lurek.ui.newList()
    list:addItem("Sword")
    list:addItem("Shield")
    list:addItem("Potion")
    list:addItem("Scroll")
    example_print_log("count = " .. list:getItemCount())
    example_print_log("item 1 = " .. list:getItem(1))
    example_print_log("item 3 = " .. list:getItem(3))
end

--@api: LListBox:getItemCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local list = lurek.ui.newList()
    list:addItem("Sword")
    list:addItem("Shield")
    list:addItem("Potion")
    list:addItem("Scroll")
    example_print_log("count = " .. list:getItemCount())
    example_print_log("item 1 = " .. list:getItem(1))
    example_print_log("item 3 = " .. list:getItem(3))
end

--@api: LListBox:setSelectedIndex
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local list = lurek.ui.newList()
    list:addItem("Option A")
    list:addItem("Option B")
    list:addItem("Option C")
    list:setSelectedIndex(2)
    example_print_log("selected = " .. list:getSelectedIndex())
    list:setSelectedIndex(3)
    example_print_log("changed to = " .. list:getSelectedIndex())
end

--@api: LListBox:getSelectedIndex
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local list = lurek.ui.newList()
    list:addItem("Option A")
    list:addItem("Option B")
    list:addItem("Option C")
    list:setSelectedIndex(2)
    example_print_log("selected = " .. list:getSelectedIndex())
    list:setSelectedIndex(3)
    example_print_log("changed to = " .. list:getSelectedIndex())
end

--@api: LListBox:removeItem
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local list = lurek.ui.newList()
    list:addItem("First")
    list:addItem("Second")
    list:addItem("Third")
    list:setItemHeight(30)
    list:removeItem(2)
    example_print_log("after remove: count=" .. list:getItemCount())
    example_print_log("item 2 now = " .. tostring(list:getItem(2)))
    list:clearItems()
    example_print_log("after clear = " .. list:getItemCount())
end

--@api: LListBox:clearItems
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local list = lurek.ui.newList()
    list:addItem("First")
    list:addItem("Second")
    list:addItem("Third")
    list:setItemHeight(30)
    list:removeItem(2)
    example_print_log("after remove: count=" .. list:getItemCount())
    example_print_log("item 2 now = " .. tostring(list:getItem(2)))
    list:clearItems()
    example_print_log("after clear = " .. list:getItemCount())
end

--@api: LListBox:setItemHeight
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local list = lurek.ui.newList()
    list:addItem("First")
    list:addItem("Second")
    list:addItem("Third")
    list:setItemHeight(30)
    list:removeItem(2)
    example_print_log("after remove: count=" .. list:getItemCount())
    example_print_log("item 2 now = " .. tostring(list:getItem(2)))
    list:clearItems()
    example_print_log("after clear = " .. list:getItemCount())
end

--@api: lurek.ui.newMenuBar
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LMenuBar
    local bar = lurek.ui.newMenuBar()
    example_print_log("type = " .. bar:type())
    example_print_log("menu count = " .. bar:getMenuCount())
    example_print_log("menu count = " .. bar:getMenuCount())
    example_print_log("menu width = " .. select(3, bar:getRect()))
end

--@api: lurek.ui.newMenuItem
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local item = lurek.ui.newMenuItem("File")
    example_print_log("type = " .. item:type())
    example_print_log("text = " .. item:getText())
    item:setShortcut("Ctrl+F")
    example_print_log("shortcut = " .. item:getShortcut())
end

--@api: LMenuItem:setText
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LMenuItem
    local item = lurek.ui.newMenuItem("Toggle Grid")
    item:setOnClick(function()
        example_print_log("  grid toggle clicked")
    end)
    item:setChecked(true)
    example_print_log("checked = " .. tostring(item:isChecked()))
    item:setText("Show Grid")
    example_print_log("renamed = " .. item:getText())
end

--@api: LMenuItem:setOnClick
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LMenuItem
    local item = lurek.ui.newMenuItem("Toggle Grid")
    item:setOnClick(function()
        example_print_log("  grid toggle clicked")
    end)
    item:setChecked(true)
    example_print_log("checked = " .. tostring(item:isChecked()))
    item:setText("Show Grid")
    example_print_log("renamed = " .. item:getText())
end

--@api: LMenuItem:setChecked
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LMenuItem
    local item = lurek.ui.newMenuItem("Toggle Grid")
    item:setOnClick(function()
        example_print_log("  grid toggle clicked")
    end)
    item:setChecked(true)
    example_print_log("checked = " .. tostring(item:isChecked()))
    item:setText("Show Grid")
    example_print_log("renamed = " .. item:getText())
end

--@api: LMenuItem:isChecked
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LMenuItem
    local item = lurek.ui.newMenuItem("Toggle Grid")
    item:setOnClick(function()
        example_print_log("  grid toggle clicked")
    end)
    item:setChecked(true)
    example_print_log("checked = " .. tostring(item:isChecked()))
    item:setText("Show Grid")
    example_print_log("renamed = " .. item:getText())
end

--@api: LMenuItem:addSubItem
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("File has " .. #subs .. " sub-items")
end

--@api: LMenuItem:getSubItems
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("File has " .. #subs .. " sub-items")
end

--@api: LMenuBar:addMenu
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bar = lurek.ui.newMenuBar()
    local fileMenu = lurek.ui.newMenuItem("File")
    local editMenu = lurek.ui.newMenuItem("Edit")
    local viewMenu = lurek.ui.newMenuItem("View")
    bar:addMenu(fileMenu._idx)
    bar:addMenu(editMenu._idx)
    bar:addMenu(viewMenu._idx)
    example_print_log("menus = " .. bar:getMenuCount())
    local menus = bar:getMenus()
    example_print_log("menu indices: " .. #menus .. " entries")
end

--@api: LMenuBar:getMenuCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bar = lurek.ui.newMenuBar()
    local fileMenu = lurek.ui.newMenuItem("File")
    local editMenu = lurek.ui.newMenuItem("Edit")
    local viewMenu = lurek.ui.newMenuItem("View")
    bar:addMenu(fileMenu._idx)
    bar:addMenu(editMenu._idx)
    bar:addMenu(viewMenu._idx)
    example_print_log("menus = " .. bar:getMenuCount())
    local menus = bar:getMenus()
    example_print_log("menu indices: " .. #menus .. " entries")
end

--@api: LMenuBar:getMenus
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bar = lurek.ui.newMenuBar()
    local fileMenu = lurek.ui.newMenuItem("File")
    local editMenu = lurek.ui.newMenuItem("Edit")
    local viewMenu = lurek.ui.newMenuItem("View")
    bar:addMenu(fileMenu._idx)
    bar:addMenu(editMenu._idx)
    bar:addMenu(viewMenu._idx)
    example_print_log("menus = " .. bar:getMenuCount())
    local menus = bar:getMenus()
    example_print_log("menu indices: " .. #menus .. " entries")
end

--@api: LMenuBar:removeMenu
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bar = lurek.ui.newMenuBar()
    local m = lurek.ui.newMenuItem("Tools")
    bar:addMenu(m._idx)
    example_print_log("before remove = " .. bar:getMenuCount())
    local ok = bar:removeMenu(m._idx)
    example_print_log("removed = " .. tostring(ok))
    example_print_log("after remove = " .. bar:getMenuCount())
end

--@api: lurek.ui.newTabBar
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LTabBar
    local tabs = lurek.ui.newTabBar()
    example_print_log("type = " .. tabs:type())
    example_print_log("tab count = " .. tabs:getTabCount())
    example_print_log("tab count = " .. tabs:getTabCount())
    example_print_log("active tab = " .. tostring(tabs:getActiveTab()))
end

--@api: LTabBar:addTab
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tabs = lurek.ui.newTabBar()
    tabs:addTab("General")
    tabs:addTab("Graphics")
    tabs:addTab("Audio")
    tabs:addTab("Controls")
    example_print_log("count = " .. tabs:getTabCount())
    example_print_log("tab 1 = " .. tabs:getTab(1))
    example_print_log("tab 3 = " .. tabs:getTab(3))
end

--@api: LTabBar:getTab
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tabs = lurek.ui.newTabBar()
    tabs:addTab("General")
    tabs:addTab("Graphics")
    tabs:addTab("Audio")
    tabs:addTab("Controls")
    example_print_log("count = " .. tabs:getTabCount())
    example_print_log("tab 1 = " .. tabs:getTab(1))
    example_print_log("tab 3 = " .. tabs:getTab(3))
end

--@api: LTabBar:getTabCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tabs = lurek.ui.newTabBar()
    tabs:addTab("General")
    tabs:addTab("Graphics")
    tabs:addTab("Audio")
    tabs:addTab("Controls")
    example_print_log("count = " .. tabs:getTabCount())
    example_print_log("tab 1 = " .. tabs:getTab(1))
    example_print_log("tab 3 = " .. tabs:getTab(3))
end

--@api: LTabBar:setActiveTab
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tabs = lurek.ui.newTabBar()
    tabs:addTab("Home")
    tabs:addTab("Settings")
    tabs:addTab("Help")
    tabs:setActiveTab(2)
    example_print_log("active = " .. tabs:getActiveTab())
    local ok = tabs:removeTab(3)
    example_print_log("removed Help = " .. tostring(ok))
    example_print_log("remaining = " .. tabs:getTabCount())
end

--@api: LTabBar:getActiveTab
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tabs = lurek.ui.newTabBar()
    tabs:addTab("Home")
    tabs:addTab("Settings")
    tabs:addTab("Help")
    tabs:setActiveTab(2)
    example_print_log("active = " .. tabs:getActiveTab())
    local ok = tabs:removeTab(3)
    example_print_log("removed Help = " .. tostring(ok))
    example_print_log("remaining = " .. tabs:getTabCount())
end

--@api: LTabBar:removeTab
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tabs = lurek.ui.newTabBar()
    tabs:addTab("Home")
    tabs:addTab("Settings")
    tabs:addTab("Help")
    tabs:setActiveTab(2)
    example_print_log("active = " .. tabs:getActiveTab())
    local ok = tabs:removeTab(3)
    example_print_log("removed Help = " .. tostring(ok))
    example_print_log("remaining = " .. tabs:getTabCount())
end

--@api: lurek.ui.newAccordion
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LAccordion
    local acc = lurek.ui.newAccordion()
    example_print_log("type = " .. acc:type())
    example_print_log("sections = " .. acc:getSectionCount())
    example_print_log("section count = " .. acc:getSectionCount())
    example_print_log("exclusive = " .. tostring(acc:isExclusive()))
end

--@api: LAccordion:addSection
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local acc = lurek.ui.newAccordion()
    acc:addSection("Player Stats")
    acc:addSection("Inventory")
    acc:addSection("Quest Log")
    example_print_log("sections = " .. acc:getSectionCount())
    example_print_log("section 1 = " .. acc:getSectionTitle(1))
    example_print_log("section 2 = " .. acc:getSectionTitle(2))
end

--@api: LAccordion:getSectionCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local acc = lurek.ui.newAccordion()
    acc:addSection("Player Stats")
    acc:addSection("Inventory")
    acc:addSection("Quest Log")
    example_print_log("sections = " .. acc:getSectionCount())
    example_print_log("section 1 = " .. acc:getSectionTitle(1))
    example_print_log("section 2 = " .. acc:getSectionTitle(2))
end

--@api: LAccordion:getSectionTitle
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local acc = lurek.ui.newAccordion()
    acc:addSection("Player Stats")
    acc:addSection("Inventory")
    acc:addSection("Quest Log")
    example_print_log("sections = " .. acc:getSectionCount())
    example_print_log("section 1 = " .. acc:getSectionTitle(1))
    example_print_log("section 2 = " .. acc:getSectionTitle(2))
end

--@api: LAccordion:toggleSection
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local acc = lurek.ui.newAccordion()
    acc:addSection("A")
    acc:addSection("B")
    acc:addSection("C")
    acc:setExclusive(true)
    example_print_log("exclusive = " .. tostring(acc:isExclusive()))
    acc:toggleSection(1)
    example_print_log("section 1 expanded = " .. tostring(acc:isSectionExpanded(1)))
    acc:toggleSection(2)
    example_print_log("section 1 after toggle 2 = " .. tostring(acc:isSectionExpanded(1)))
    example_print_log("section 2 expanded = " .. tostring(acc:isSectionExpanded(2)))
end

--@api: LAccordion:isSectionExpanded
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local acc = lurek.ui.newAccordion()
    acc:addSection("A")
    acc:addSection("B")
    acc:addSection("C")
    acc:setExclusive(true)
    example_print_log("exclusive = " .. tostring(acc:isExclusive()))
    acc:toggleSection(1)
    example_print_log("section 1 expanded = " .. tostring(acc:isSectionExpanded(1)))
    acc:toggleSection(2)
    example_print_log("section 1 after toggle 2 = " .. tostring(acc:isSectionExpanded(1)))
    example_print_log("section 2 expanded = " .. tostring(acc:isSectionExpanded(2)))
end

--@api: LAccordion:setExclusive
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local acc = lurek.ui.newAccordion()
    acc:addSection("A")
    acc:addSection("B")
    acc:addSection("C")
    acc:setExclusive(true)
    example_print_log("exclusive = " .. tostring(acc:isExclusive()))
    acc:toggleSection(1)
    example_print_log("section 1 expanded = " .. tostring(acc:isSectionExpanded(1)))
    acc:toggleSection(2)
    example_print_log("section 1 after toggle 2 = " .. tostring(acc:isSectionExpanded(1)))
    example_print_log("section 2 expanded = " .. tostring(acc:isSectionExpanded(2)))
end

--@api: lurek.ui.newDialog
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
        example_print_log("default action fired:", action_idx)
    end, "default", true)
    modal:addAction("Back", function(_, action_idx)
        example_print_log("cancel action fired:", action_idx)
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

    example_print_log("modal open:", modal:isOpen(), "non modal open:", inspector:isOpen())
end

--@api: lurek.ui.newWindow
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local win = lurek.ui.newWindow("Editor")
    win:setDraggable(true)
    win:setResizable(true)
    win:setCloseable(true)
    win:setOnClose(function(idx)
        example_print_log("window closed, widget index:", idx)
    end)
    example_print_log("window title:", win:getTitle())
    example_print_log("is draggable:", win:isDraggable())
    example_print_log("is resizable:", win:isResizable())
    example_print_log("is closeable:", win:isCloseable())

    win:setTitle("Object Inspector")
    example_print_log("title:", win:getTitle())
    win:setDraggable(false)
    example_print_log("draggable after disable:", win:isDraggable())
    win:setResizable(false)
    example_print_log("resizable after disable:", win:isResizable())
    win:setCloseable(false)
    example_print_log("closeable after disable:", win:isCloseable())
end

--@api: lurek.ui.newToolbar
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("save", "Save file")
    example_print_log("orientation:", tb:getOrientation())
    example_print_log("toolbar orientation = " .. tb:getOrientation())
    example_print_log("toolbar width = " .. select(3, tb:getRect()))
end

--@api: lurek.ui.newStatusBar
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newStatusBar()
    sb:addSection("Ready", 150)
    example_print_log("section count:", sb:getSectionCount())
    example_print_log("section 1:", sb:getSectionText(1))
    example_print_log("rect x = " .. select(1, sb:getRect()))
end

--@api: lurek.ui.newProgressBar
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bar = lurek.ui.newProgressBar(0, 100)
    bar:setValue(35)
    example_print_log("value:", bar:getValue())
    example_print_log("progress (normalized):", bar:getProgress())
    example_print_log("progress value = " .. bar:getValue())
end

--@api: lurek.ui.newImageWidget
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.ui.newImageWidget()
    img:setScaleMode("fit")
    example_print_log("scale mode:", img:getScaleMode())
    img:setTint(1.0, 0.8, 0.6, 0.9)
    local r, g, b, a = img:getTint()
    example_print_log("tint:", r, g, b, a)
end

--@api: lurek.ui.newNinePatch
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(128, 128)
    np:setInsets(16, 16, 16, 16)
    local w, h = np:getImageDimensions()
    example_print_log("image size:", w, h)
end

--@api: lurek.ui.newBadge
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local badge = lurek.ui.newBadge(5)
    example_print_log("count:", badge:getCount())
    example_print_log("display:", badge:getDisplayText())
    badge:setCount(120)
    example_print_log("large count display:", badge:getDisplayText())
end

--@api: lurek.ui.newSpacer
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newSpacer(20, 10)
    sp:setSize(40, 20)
    local w, h = sp:getSize()
    example_print_log("spacer size:", w, h)
    example_print_log("rect x = " .. select(1, sp:getRect()))
end

--@api: lurek.ui.newSeparator
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sep = lurek.ui.newSeparator(false)
    example_print_log("is vertical:", sep:isVertical())
    sep:setThickness(2)
    example_print_log("new thickness:", sep:getThickness())
    example_print_log("rect x = " .. select(1, sep:getRect()))
end

--@api: lurek.ui.newColorPicker
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cp = lurek.ui.newColorPicker()
    cp:setColor(0.8, 0.2, 0.5, 1.0)
    local r, g, b, a = cp:getColor()
    example_print_log("color:", r, g, b, a)
    cp:setColorMode("hsv")
    example_print_log("mode:", cp:getColorMode())
end

--@api: lurek.ui.newRadioButton
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rb1 = lurek.ui.newRadioButton("Small", "size_group")
    local rb2 = lurek.ui.newRadioButton("Medium", "size_group")
    local rb3 = lurek.ui.newRadioButton("Large", "size_group")
    rb2:setSelected(true)
    example_print_log("rb1 selected:", rb1:isSelected())
    example_print_log("rb2 selected:", rb2:isSelected())
    example_print_log("rb2 group:", rb2:getGroup())
    example_print_log("rb2 text:", rb2:getText())
end

--@api: lurek.ui.newTreeView
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.ui.newTreeView()
    local root = tree:addNode("Project")
    tree:addNode("main.lua", root)
    example_print_log("total nodes:", tree:getNodeCount())
    example_print_log("root text:", tree:getNodeText(root))
end

--@api: lurek.ui.newToast
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local toast = lurek.ui.newToast("File saved!", 2.5)
    example_print_log("message:", toast:getMessage())
    example_print_log("duration:", toast:getDuration())
    toast:setMessage("Upload complete")
    toast:setDuration(4.0)
    example_print_log("updated message:", toast:getMessage())
    example_print_log("expired:", toast:isExpired())
end

--@api: lurek.ui.newTooltipPanel
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn = lurek.ui.newButton("Hover me")
    local tip = lurek.ui.newTooltipPanel("Click to submit form")
    tip:setDelay(0.5)
    tip:setTarget(btn._idx)
    example_print_log("tooltip text:", tip:getText())
    example_print_log("delay:", tip:getDelay())
    example_print_log("target:", tip:getTarget())
    tip:setText("Updated tooltip text")
    example_print_log("new text:", tip:getText())
end

--@api: lurek.ui.newTheme
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local theme = lurek.ui.newTheme()
    theme:setStyle("button", "normal", { bg_r = 0.2, bg_g = 0.2, bg_b = 0.3, bg_a = 1.0, fg_r = 1.0, fg_g = 1.0, fg_b = 1.0, fg_a = 1.0, })
    theme:setStyle("button", "hovered", { bg_r = 0.3, bg_g = 0.3, bg_b = 0.5, bg_a = 1.0, })
    lurek.ui.setTheme(theme)
    example_print_log("theme active:", lurek.ui.getTheme())
    example_print_log("theme type:", theme:type())
end

--@api: lurek.ui.setTheme
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local theme = lurek.ui.newTheme()
    theme:setStyle("button", "normal", { bg_r = 0.2, bg_g = 0.2, bg_b = 0.3, bg_a = 1.0, fg_r = 1.0, fg_g = 1.0, fg_b = 1.0, fg_a = 1.0, })
    theme:setStyle("button", "hovered", { bg_r = 0.3, bg_g = 0.3, bg_b = 0.5, bg_a = 1.0, })
    lurek.ui.setTheme(theme)
    example_print_log("theme active:", lurek.ui.getTheme())
    example_print_log("theme type:", theme:type())
end

--@api: lurek.ui.getTheme
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local theme = lurek.ui.newTheme()
    theme:setStyle("button", "normal", { bg_r = 0.2, bg_g = 0.2, bg_b = 0.3, bg_a = 1.0, fg_r = 1.0, fg_g = 1.0, fg_b = 1.0, fg_a = 1.0, })
    theme:setStyle("button", "hovered", { bg_r = 0.3, bg_g = 0.3, bg_b = 0.5, bg_a = 1.0, })
    lurek.ui.setTheme(theme)
    example_print_log("theme active:", lurek.ui.getTheme())
    example_print_log("theme type:", theme:type())
end

--@api: lurek.ui.getFocus
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn1 = lurek.ui.newButton("First")
    local btn2 = lurek.ui.newButton("Second")
    lurek.ui.setFocus(btn1)
    example_print_log("focused widget:", lurek.ui.getFocus())
    lurek.ui.focusNext()
    example_print_log("after focusNext:", lurek.ui.getFocus())
    lurek.ui.focusPrev()
    example_print_log("after focusPrev:", lurek.ui.getFocus())
    lurek.ui.clearFocus()
    example_print_log("after clear:", lurek.ui.getFocus())
end

--@api: lurek.ui.focusPrev
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn1 = lurek.ui.newButton("First")
    local btn2 = lurek.ui.newButton("Second")
    lurek.ui.setFocus(btn1)
    example_print_log("focused widget:", lurek.ui.getFocus())
    lurek.ui.focusNext()
    example_print_log("after focusNext:", lurek.ui.getFocus())
    lurek.ui.focusPrev()
    example_print_log("after focusPrev:", lurek.ui.getFocus())
    lurek.ui.clearFocus()
    example_print_log("after clear:", lurek.ui.getFocus())
end

--@api: lurek.ui.clearFocus
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn1 = lurek.ui.newButton("First")
    local btn2 = lurek.ui.newButton("Second")
    lurek.ui.setFocus(btn1)
    example_print_log("focused widget:", lurek.ui.getFocus())
    lurek.ui.focusNext()
    example_print_log("after focusNext:", lurek.ui.getFocus())
    lurek.ui.focusPrev()
    example_print_log("after focusPrev:", lurek.ui.getFocus())
    lurek.ui.clearFocus()
    example_print_log("after clear:", lurek.ui.getFocus())
end

--@api: lurek.ui.beginDrag
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local source = lurek.ui.newPanel()
    local target = lurek.ui.newPanel()
    lurek.ui.beginDrag(source)
    example_print_log("active drag:", lurek.ui.getActiveDrag())
    lurek.ui.dropOn(target)
    example_print_log("after drop, active drag:", lurek.ui.getActiveDrag())
end

--@api: lurek.ui.getActiveDrag
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local source = lurek.ui.newPanel()
    local target = lurek.ui.newPanel()
    lurek.ui.beginDrag(source)
    example_print_log("active drag:", lurek.ui.getActiveDrag())
    lurek.ui.dropOn(target)
    example_print_log("after drop, active drag:", lurek.ui.getActiveDrag())
end

--@api: lurek.ui.dropOn
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local source = lurek.ui.newPanel()
    local target = lurek.ui.newPanel()
    lurek.ui.beginDrag(source)
    example_print_log("active drag:", lurek.ui.getActiveDrag())
    lurek.ui.dropOn(target)
    example_print_log("after drop, active drag:", lurek.ui.getActiveDrag())
end

--- UI Part 8: LAccordion, LColorPicker, LProgressBar, LMenuBar

--@api: LAccordion:isExclusive
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local acc = lurek.ui.newAccordion()
    example_print_log("type=" .. acc:type())
    acc:addSection("Section A")
    acc:addSection("Section B")
    example_print_log("count=" .. acc:getSectionCount())
    example_print_log("title0=" .. acc:getSectionTitle(1))
    example_print_log("expanded0=" .. tostring(acc:isSectionExpanded(1)))
    acc:toggleSection(1)
    example_print_log("expanded0_after=" .. tostring(acc:isSectionExpanded(1)))
    example_print_log("exclusive=" .. tostring(acc:isExclusive()))
    acc:setExclusive(true)
    example_print_log("exclusive_after=" .. tostring(acc:isExclusive()))
end

--@api: LColorPicker:getColor
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cp = lurek.ui.newColorPicker()
    example_print_log("type=" .. cp:type())
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    example_print_log("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    example_print_log("mode=" .. tostring(cp:getColorMode()))
    cp:setColorMode("hsv")
    example_print_log("mode_after=" .. cp:getColorMode())
    example_print_log("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2)
        example_print_log("changed", r2, g2, b2, a2)
    end)
end

--@api: LColorPicker:getColorMode
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cp = lurek.ui.newColorPicker()
    example_print_log("type=" .. cp:type())
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    example_print_log("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    example_print_log("mode=" .. tostring(cp:getColorMode()))
    cp:setColorMode("hsv")
    example_print_log("mode_after=" .. cp:getColorMode())
    example_print_log("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) example_print_log("changed", r2, g2, b2, a2) end)
end

--@api: LColorPicker:getShowAlpha
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cp = lurek.ui.newColorPicker()
    example_print_log("type=" .. cp:type())
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    example_print_log("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    example_print_log("mode=" .. tostring(cp:getColorMode()))
    cp:setColorMode("hsv")
    example_print_log("mode_after=" .. cp:getColorMode())
    example_print_log("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) example_print_log("changed", r2, g2, b2, a2) end)
end

--@api: LColorPicker:setColor
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cp = lurek.ui.newColorPicker()
    example_print_log("type=" .. cp:type())
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    example_print_log("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    example_print_log("mode=" .. tostring(cp:getColorMode()))
    cp:setColorMode("hsv")
    example_print_log("mode_after=" .. cp:getColorMode())
    example_print_log("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) example_print_log("changed", r2, g2, b2, a2) end)
end

--@api: LColorPicker:setColorMode
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cp = lurek.ui.newColorPicker()
    example_print_log("type=" .. cp:type())
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    example_print_log("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    example_print_log("mode=" .. tostring(cp:getColorMode()))
    cp:setColorMode("hsv")
    example_print_log("mode_after=" .. cp:getColorMode())
    example_print_log("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) example_print_log("changed", r2, g2, b2, a2) end)
end

--@api: LColorPicker:setOnChange
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cp = lurek.ui.newColorPicker()
    example_print_log("type=" .. cp:type())
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    example_print_log("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    example_print_log("mode=" .. tostring(cp:getColorMode()))
    cp:setColorMode("hsv")
    example_print_log("mode_after=" .. cp:getColorMode())
    example_print_log("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) example_print_log("changed", r2, g2, b2, a2) end)
end

--@api: LColorPicker:setShowAlpha
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cp = lurek.ui.newColorPicker()
    example_print_log("type=" .. cp:type())
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    example_print_log("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    example_print_log("mode=" .. tostring(cp:getColorMode()))
    cp:setColorMode("hsv")
    example_print_log("mode_after=" .. cp:getColorMode())
    example_print_log("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) example_print_log("changed", r2, g2, b2, a2) end)
end

--@api: LProgressBar:getMax
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pb = lurek.ui.newProgressBar(0, 100)
    example_print_log("type=" .. pb:type())
    example_print_log("min=" .. pb:getMin())
    example_print_log("max=" .. pb:getMax())
    pb:setValue(75)
    example_print_log("value=" .. pb:getValue())
    example_print_log("progress=" .. pb:getProgress())
    pb:setRange(0, 200)
    example_print_log("max_after=" .. pb:getMax())
end

--@api: LProgressBar:getMin
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pb = lurek.ui.newProgressBar(0, 100)
    example_print_log("type=" .. pb:type())
    example_print_log("min=" .. pb:getMin())
    example_print_log("max=" .. pb:getMax())
    pb:setValue(75)
    example_print_log("value=" .. pb:getValue())
    example_print_log("progress=" .. pb:getProgress())
    pb:setRange(0, 200)
    example_print_log("max_after=" .. pb:getMax())
end

--@api: LProgressBar:getProgress
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pb = lurek.ui.newProgressBar(0, 100)
    example_print_log("type=" .. pb:type())
    example_print_log("min=" .. pb:getMin())
    example_print_log("max=" .. pb:getMax())
    pb:setValue(75)
    example_print_log("value=" .. pb:getValue())
    example_print_log("progress=" .. pb:getProgress())
    pb:setRange(0, 200)
    example_print_log("max_after=" .. pb:getMax())
end

--@api: LProgressBar:getValue
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pb = lurek.ui.newProgressBar(0, 100)
    example_print_log("type=" .. pb:type())
    example_print_log("min=" .. pb:getMin())
    example_print_log("max=" .. pb:getMax())
    pb:setValue(75)
    example_print_log("value=" .. pb:getValue())
    example_print_log("progress=" .. pb:getProgress())
    pb:setRange(0, 200)
    example_print_log("max_after=" .. pb:getMax())
end

--@api: LProgressBar:setRange
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pb = lurek.ui.newProgressBar(0, 100)
    example_print_log("type=" .. pb:type())
    example_print_log("min=" .. pb:getMin())
    example_print_log("max=" .. pb:getMax())
    pb:setValue(75)
    example_print_log("value=" .. pb:getValue())
    example_print_log("progress=" .. pb:getProgress())
    pb:setRange(0, 200)
    example_print_log("max_after=" .. pb:getMax())
end

--@api: LProgressBar:setValue
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pb = lurek.ui.newProgressBar(0, 100)
    example_print_log("type=" .. pb:type())
    example_print_log("min=" .. pb:getMin())
    example_print_log("max=" .. pb:getMax())
    pb:setValue(75)
    example_print_log("value=" .. pb:getValue())
    example_print_log("progress=" .. pb:getProgress())
    pb:setRange(0, 200)
    example_print_log("max_after=" .. pb:getMax())
end

--- UI Part 9: LTabBar, LStatusBar, LToolbar

--@api: LStatusBar:addSection
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newStatusBar()
    example_print_log("type=" .. sb:type())
    sb:addSection("Ready", 120)
    sb:addSection("Line 1", 80)
    example_print_log("sections=" .. sb:getSectionCount())
    example_print_log("text1=" .. sb:getSectionText(1))
    sb:setSectionText(1, "Loading...")
    example_print_log("text1_after=" .. sb:getSectionText(1))
end

--@api: LStatusBar:getSectionCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newStatusBar()
    example_print_log("type=" .. sb:type())
    sb:addSection("Ready", 120)
    sb:addSection("Line 1", 80)
    example_print_log("sections=" .. sb:getSectionCount())
    example_print_log("text1=" .. sb:getSectionText(1))
    sb:setSectionText(1, "Loading...")
    example_print_log("text1_after=" .. sb:getSectionText(1))
end

--@api: LStatusBar:getSectionText
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newStatusBar()
    example_print_log("type=" .. sb:type())
    sb:addSection("Ready", 120)
    sb:addSection("Line 1", 80)
    example_print_log("sections=" .. sb:getSectionCount())
    example_print_log("text1=" .. sb:getSectionText(1))
    sb:setSectionText(1, "Loading...")
    example_print_log("text1_after=" .. sb:getSectionText(1))
end

--@api: LStatusBar:setSectionText
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newStatusBar()
    example_print_log("type=" .. sb:type())
    sb:addSection("Ready", 120)
    sb:addSection("Line 1", 80)
    example_print_log("sections=" .. sb:getSectionCount())
    example_print_log("text1=" .. sb:getSectionText(1))
    sb:setSectionText(1, "Loading...")
    example_print_log("text1_after=" .. sb:getSectionText(1))
end

--@api: LToolbar:addButton
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    example_print_log("btn=" .. tostring(bar:getButton("btn_save") ~= nil))
    example_print_log("toolbar orientation = " .. bar:getOrientation())
    example_print_log("toolbar width = " .. select(3, bar:getRect()))
end

--@api: LToolbar:addSeparator
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    bar:addSeparator()
    example_print_log("separator added")
    example_print_log("toolbar orientation = " .. bar:getOrientation())
end

--@api: LToolbar:getButton

do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    local btn = bar:getButton("btn_save")
    example_print_log("btn=" .. tostring(btn ~= nil))
    example_print_log("toolbar type=" .. tostring(bar:type()))
end

--@api: LToolbar:getOrientation
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bar = lurek.ui.newToolbar("horizontal")
    example_print_log("orientation=" .. bar:getOrientation())
    example_print_log("toolbar orientation = " .. bar:getOrientation())
    example_print_log("toolbar width = " .. select(3, bar:getRect()))
    example_print_log("toolbar visible = " .. tostring(bar:isVisible()))
end

--@api: LToolbar:isButtonToggled
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    example_print_log("toggled=" .. tostring(bar:isButtonToggled("btn_save")))
    example_print_log("toolbar orientation = " .. bar:getOrientation())
    example_print_log("toolbar width = " .. select(3, bar:getRect()))
end

--@api: LToolbar:setButtonEnabled
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_open", "Open file")
    bar:setButtonEnabled("btn_open", false)
    example_print_log("btn_open disabled")
    example_print_log("toolbar orientation = " .. bar:getOrientation())
end

--@api: LToolbar:setButtonToggled
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    bar:setButtonToggled("btn_save", true)
    example_print_log("toggled_after=" .. tostring(bar:isButtonToggled("btn_save")))
    example_print_log("toolbar orientation = " .. bar:getOrientation())
end

--@api: LToolbar:setOrientation
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bar = lurek.ui.newToolbar("horizontal")
    bar:setOrientation("vertical")
    example_print_log("orientation_after=" .. bar:getOrientation())
    example_print_log("toolbar orientation = " .. bar:getOrientation())
    example_print_log("toolbar width = " .. select(3, bar:getRect()))
end

--@api: lurek.ui.addToast
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.ui.addToast({ message = "File saved successfully", duration = 3.0, type = "info" })
    example_print_log("toast added")
    local layout = lurek.ui.loadLayout({ type = "panel", children = {} })
    example_print_log("layout id=" .. tostring(layout))
    example_print_log("layout loaded=" .. tostring(type(layout) == "number"))
end

--@api: lurek.ui.loadLayout
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.ui.addToast({ message = "File saved successfully", duration = 3.0, type = "info" })
    example_print_log("toast added")
    local layout = lurek.ui.loadLayout({
        type = "layout",
        direction = "grid",
        columns = 2,
        padding = { 8, 8, 8, 8 },
        children = {
            { type = "label", text = "HP", textAlign = "right", margin = { 2, 4, 2, 4 } },
        },
    })
    example_print_log("layout=" .. tostring(layout ~= nil))
end

--@api: lurek.ui.setAutoInput
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.ui.setAutoInput(true)
    local enabled = lurek.ui.hasAutoInput()
    lurek.ui.setAutoInput(false)
    local disabled = lurek.ui.hasAutoInput()
    example_print_log("auto input enabled=" .. tostring(enabled))
    example_print_log("auto input disabled=" .. tostring(disabled))
end

--@api: lurek.ui.hasAutoInput
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.ui.setAutoInput(true)
    local enabled = lurek.ui.hasAutoInput()
    lurek.ui.setAutoInput(false)
    local disabled = lurek.ui.hasAutoInput()
    example_print_log("auto input enabled=" .. tostring(enabled))
    example_print_log("auto input disabled=" .. tostring(disabled))
end

--@api: lurek.ui.setAutoUpdate
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.ui.setAutoUpdate(true)
    local enabled = lurek.ui.hasAutoUpdate()
    lurek.ui.setAutoUpdate(false)
    local disabled = lurek.ui.hasAutoUpdate()
    example_print_log("auto update enabled=" .. tostring(enabled))
    example_print_log("auto update disabled=" .. tostring(disabled))
end

--@api: lurek.ui.hasAutoUpdate
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.ui.setAutoUpdate(true)
    local enabled = lurek.ui.hasAutoUpdate()
    lurek.ui.setAutoUpdate(false)
    local disabled = lurek.ui.hasAutoUpdate()
    example_print_log("auto update enabled=" .. tostring(enabled))
    example_print_log("auto update disabled=" .. tostring(disabled))
end

--- UI Part 10: LBadge, LDockPanel, LImageWidget, LNinePatch, LRadioButton, LSpinBox, LSplitPanel, LSwitch, LTable, LToast, LTooltipPanel, LTreeView

--@api: LBadge:getCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local badge = lurek.ui.newBadge(3)
    example_print_log("type=" .. badge:type())
    example_print_log("count=" .. badge:getCount())
    badge:setCount(7)
    example_print_log("count_after=" .. badge:getCount())
    local text = badge:getDisplayText()
    example_print_log("text=" .. tostring(text))
end

--@api: LBadge:getDisplayText
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local badge = lurek.ui.newBadge(3)
    example_print_log("type=" .. badge:type())
    example_print_log("count=" .. badge:getCount())
    badge:setCount(7)
    example_print_log("count_after=" .. badge:getCount())
    local text = badge:getDisplayText()
    example_print_log("text=" .. tostring(text))
end

--@api: LBadge:setCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local badge = lurek.ui.newBadge(3)
    example_print_log("type=" .. badge:type())
    example_print_log("count=" .. badge:getCount())
    badge:setCount(7)
    example_print_log("count_after=" .. badge:getCount())
    local text = badge:getDisplayText()
    example_print_log("text=" .. tostring(text))
end

--@api: LDockPanel:dock
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dp = lurek.ui.newDockPanel()
    local child = lurek.ui.newPanel()
    example_print_log("type=" .. dp:type())
    dp:addChild(child)
    dp:dock(child._idx, "left")
    example_print_log("docked=" .. dp:getDockedCount())
    example_print_log("split_size=" .. tostring(dp:getSplitSize("left")))
    dp:setSplitSize("left", 150)
    dp:undock(child._idx)
    example_print_log("docked_after=" .. dp:getDockedCount())
end

--@api: LDockPanel:getDockedCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dp = lurek.ui.newDockPanel()
    example_print_log("type=" .. dp:type())
    local child = lurek.ui.newPanel()
    dp:dock(0, "left")
    example_print_log("docked=" .. dp:getDockedCount())
    local sz = dp:getSplitSize("left")
    example_print_log("split_size=" .. tostring(sz))
    dp:setSplitSize("left", 150)
    dp:undock(0)
    example_print_log("docked_after=" .. dp:getDockedCount())
end

--@api: LDockPanel:getSplitSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dp = lurek.ui.newDockPanel()
    example_print_log("type=" .. dp:type())
    local child = lurek.ui.newPanel()
    dp:dock(0, "left")
    example_print_log("docked=" .. dp:getDockedCount())
    local sz = dp:getSplitSize("left")
    example_print_log("split_size=" .. tostring(sz))
    dp:setSplitSize("left", 150)
    dp:undock(0)
    example_print_log("docked_after=" .. dp:getDockedCount())
end

--@api: LDockPanel:setSplitSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dp = lurek.ui.newDockPanel()
    example_print_log("type=" .. dp:type())
    local child = lurek.ui.newPanel()
    dp:dock(0, "left")
    example_print_log("docked=" .. dp:getDockedCount())
    local sz = dp:getSplitSize("left")
    example_print_log("split_size=" .. tostring(sz))
    dp:setSplitSize("left", 150)
    dp:undock(0)
    example_print_log("docked_after=" .. dp:getDockedCount())
end

--@api: LImageWidget:getScaleMode
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iw = lurek.ui.newImageWidget()
    example_print_log("type=" .. iw:type())
    example_print_log("scale_mode=" .. tostring(iw:getScaleMode()))
    iw:setScaleMode("stretch")
    example_print_log("scale_mode_after=" .. iw:getScaleMode())
    iw:setTint(1.0, 0.78, 0.5, 1.0)
    local r, g, b, a = iw:getTint()
    example_print_log("tint=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageWidget:getTint
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iw = lurek.ui.newImageWidget()
    example_print_log("type=" .. iw:type())
    example_print_log("scale_mode=" .. tostring(iw:getScaleMode()))
    iw:setScaleMode("stretch")
    example_print_log("scale_mode_after=" .. iw:getScaleMode())
    iw:setTint(1.0, 0.78, 0.5, 1.0)
    local r, g, b, a = iw:getTint()
    example_print_log("tint=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageWidget:setScaleMode
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iw = lurek.ui.newImageWidget()
    example_print_log("type=" .. iw:type())
    example_print_log("scale_mode=" .. tostring(iw:getScaleMode()))
    iw:setScaleMode("stretch")
    example_print_log("scale_mode_after=" .. iw:getScaleMode())
    iw:setTint(1.0, 0.78, 0.5, 1.0)
    local r, g, b, a = iw:getTint()
    example_print_log("tint=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageWidget:setTint
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iw = lurek.ui.newImageWidget()
    example_print_log("type=" .. iw:type())
    example_print_log("scale_mode=" .. tostring(iw:getScaleMode()))
    iw:setScaleMode("stretch")
    example_print_log("scale_mode_after=" .. iw:getScaleMode())
    iw:setTint(1.0, 0.78, 0.5, 1.0)
    local r, g, b, a = iw:getTint()
    example_print_log("tint=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LNinePatch:getImageDimensions
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local np = lurek.ui.newNinePatch()
    example_print_log("type=" .. np:type())
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    example_print_log("img_dim=" .. w .. "x" .. h)
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    example_print_log("insets=" .. l .. "," .. t .. "," .. r .. "," .. b)
    local slices = np:getSlices()
    example_print_log("slices=" .. tostring(slices ~= nil))
end

--@api: LNinePatch:getInsets
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local np = lurek.ui.newNinePatch()
    example_print_log("type=" .. np:type())
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    example_print_log("img_dim=" .. w .. "x" .. h)
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    example_print_log("insets=" .. l .. "," .. t .. "," .. r .. "," .. b)
    local slices = np:getSlices()
    example_print_log("slices=" .. tostring(slices ~= nil))
end

--@api: LNinePatch:getSlices
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local np = lurek.ui.newNinePatch()
    example_print_log("type=" .. np:type())
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    example_print_log("img_dim=" .. w .. "x" .. h)
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    example_print_log("insets=" .. l .. "," .. t .. "," .. r .. "," .. b)
    local slices = np:getSlices()
    example_print_log("slices=" .. tostring(slices ~= nil))
end

--@api: LNinePatch:setImageDimensions
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local np = lurek.ui.newNinePatch()
    example_print_log("type=" .. np:type())
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    example_print_log("img_dim=" .. w .. "x" .. h)
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    example_print_log("insets=" .. l .. "," .. t .. "," .. r .. "," .. b)
    local slices = np:getSlices()
    example_print_log("slices=" .. tostring(slices ~= nil))
end

--@api: LNinePatch:setInsets
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local np = lurek.ui.newNinePatch()
    example_print_log("type=" .. np:type())
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    example_print_log("img_dim=" .. w .. "x" .. h)
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    example_print_log("insets=" .. l .. "," .. t .. "," .. r .. "," .. b)
    local slices = np:getSlices()
    example_print_log("slices=" .. tostring(slices ~= nil))
end

--@api: LRadioButton:getGroup
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rb1 = lurek.ui.newRadioButton("Option A", "opt_group")
    local rb2 = lurek.ui.newRadioButton("Option B", "opt_group")
    example_print_log("type=" .. rb1:type())
    example_print_log("text=" .. rb1:getText())
    example_print_log("group=" .. rb1:getGroup())
    example_print_log("selected=" .. tostring(rb1:isSelected()))
    rb1:setGroup("new_group")
    example_print_log("group_after=" .. rb1:getGroup())
end

--@api: LRadioButton:getText
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rb1 = lurek.ui.newRadioButton("Option A", "opt_group")
    local rb2 = lurek.ui.newRadioButton("Option B", "opt_group")
    example_print_log("type=" .. rb1:type())
    example_print_log("text=" .. rb1:getText())
    example_print_log("group=" .. rb1:getGroup())
    example_print_log("selected=" .. tostring(rb1:isSelected()))
    rb1:setGroup("new_group")
    example_print_log("group_after=" .. rb1:getGroup())
end

--@api: LRadioButton:isSelected
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rb1 = lurek.ui.newRadioButton("Option A", "opt_group")
    local rb2 = lurek.ui.newRadioButton("Option B", "opt_group")
    example_print_log("type=" .. rb1:type())
    example_print_log("text=" .. rb1:getText())
    example_print_log("group=" .. rb1:getGroup())
    example_print_log("selected=" .. tostring(rb1:isSelected()))
    rb1:setGroup("new_group")
    example_print_log("group_after=" .. rb1:getGroup())
end

--@api: LRadioButton:setGroup
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rb1 = lurek.ui.newRadioButton("Option A", "opt_group")
    local rb2 = lurek.ui.newRadioButton("Option B", "opt_group")
    example_print_log("type=" .. rb1:type())
    example_print_log("text=" .. rb1:getText())
    example_print_log("group=" .. rb1:getGroup())
    example_print_log("selected=" .. tostring(rb1:isSelected()))
    rb1:setGroup("new_group")
    example_print_log("group_after=" .. rb1:getGroup())
end

--@api: LSpinBox:getValue
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newSpinBox(1, 10)
    example_print_log("type=" .. sb:type())
    sb:setValue(5)
    example_print_log("value=" .. sb:getValue())
    sb:setStep(2)
    sb:setRange(0, 100)
    sb:increment()
    example_print_log("value_after_inc=" .. sb:getValue())
    sb:decrement()
    example_print_log("value_after_dec=" .. sb:getValue())
end

--@api: LSpinBox:setValue
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newSpinBox(1, 10)
    example_print_log("type=" .. sb:type())
    sb:setValue(5)
    example_print_log("value=" .. sb:getValue())
    sb:setStep(2)
    sb:setRange(0, 100)
    sb:increment()
    example_print_log("value_after_inc=" .. sb:getValue())
    sb:decrement()
    example_print_log("value_after_dec=" .. sb:getValue())
end

--@api: LSplitPanel:getFirstChild
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newSplitPanel("horizontal")
    local first = lurek.ui.newPanel()
    local second = lurek.ui.newPanel()
    example_print_log("type=" .. sp:type())
    example_print_log("orientation=" .. sp:getOrientation())
    sp:setFirstChild(first._idx)
    sp:setSecondChild(second._idx)
    local fc = sp:getFirstChild()
    local sc = sp:getSecondChild()
    example_print_log("fc=" .. tostring(fc))
    example_print_log("sc=" .. tostring(sc))
    sp:setSplitPosition(0.4)
    example_print_log("split_pos=" .. sp:getSplitPosition())
    sp:setMinPanelSize(80)
    example_print_log("min_panel=" .. sp:getMinPanelSize())
    sp:setOrientation("vertical")
    example_print_log("orientation_after=" .. sp:getOrientation())
end

--@api: LSplitPanel:getMinPanelSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newSplitPanel("horizontal")
    example_print_log("type=" .. sp:type())
    example_print_log("orientation=" .. sp:getOrientation())
    sp:setFirstChild(0)
    sp:setSecondChild(1)
    local fc = sp:getFirstChild()
    example_print_log("fc=" .. tostring(fc))
    local sc = sp:getSecondChild()
    example_print_log("sc=" .. tostring(sc))
    sp:setSplitPosition(200)
    example_print_log("split_pos=" .. sp:getSplitPosition())
    sp:setMinPanelSize(80)
    example_print_log("min_panel=" .. sp:getMinPanelSize())
    sp:setOrientation("vertical")
    example_print_log("orientation_after=" .. sp:getOrientation())
end

--@api: LSplitPanel:getOrientation
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newSplitPanel("horizontal")
    example_print_log("type=" .. sp:type())
    example_print_log("orientation=" .. sp:getOrientation())
    sp:setFirstChild(0)
    sp:setSecondChild(1)
    local fc = sp:getFirstChild()
    example_print_log("fc=" .. tostring(fc))
    local sc = sp:getSecondChild()
    example_print_log("sc=" .. tostring(sc))
    sp:setSplitPosition(200)
    example_print_log("split_pos=" .. sp:getSplitPosition())
    sp:setMinPanelSize(80)
    example_print_log("min_panel=" .. sp:getMinPanelSize())
    sp:setOrientation("vertical")
    example_print_log("orientation_after=" .. sp:getOrientation())
end

--@api: LSplitPanel:getSecondChild
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newSplitPanel("horizontal")
    example_print_log("type=" .. sp:type())
    example_print_log("orientation=" .. sp:getOrientation())
    sp:setFirstChild(0)
    sp:setSecondChild(1)
    local fc = sp:getFirstChild()
    example_print_log("fc=" .. tostring(fc))
    local sc = sp:getSecondChild()
    example_print_log("sc=" .. tostring(sc))
    sp:setSplitPosition(200)
    example_print_log("split_pos=" .. sp:getSplitPosition())
    sp:setMinPanelSize(80)
    example_print_log("min_panel=" .. sp:getMinPanelSize())
    sp:setOrientation("vertical")
    example_print_log("orientation_after=" .. sp:getOrientation())
end

--@api: LSplitPanel:getSplitPosition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newSplitPanel("horizontal")
    example_print_log("type=" .. sp:type())
    example_print_log("orientation=" .. sp:getOrientation())
    sp:setFirstChild(0)
    sp:setSecondChild(1)
    local fc = sp:getFirstChild()
    example_print_log("fc=" .. tostring(fc))
    local sc = sp:getSecondChild()
    example_print_log("sc=" .. tostring(sc))
    sp:setSplitPosition(200)
    example_print_log("split_pos=" .. sp:getSplitPosition())
    sp:setMinPanelSize(80)
    example_print_log("min_panel=" .. sp:getMinPanelSize())
    sp:setOrientation("vertical")
    example_print_log("orientation_after=" .. sp:getOrientation())
end

--@api: LSplitPanel:setFirstChild
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newSplitPanel("horizontal")
    example_print_log("type=" .. sp:type())
    example_print_log("orientation=" .. sp:getOrientation())
    sp:setFirstChild(0)
    sp:setSecondChild(1)
    local fc = sp:getFirstChild()
    example_print_log("fc=" .. tostring(fc))
    local sc = sp:getSecondChild()
    example_print_log("sc=" .. tostring(sc))
    sp:setSplitPosition(200)
    example_print_log("split_pos=" .. sp:getSplitPosition())
    sp:setMinPanelSize(80)
    example_print_log("min_panel=" .. sp:getMinPanelSize())
    sp:setOrientation("vertical")
    example_print_log("orientation_after=" .. sp:getOrientation())
end

--@api: LSplitPanel:setMinPanelSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newSplitPanel("horizontal")
    example_print_log("type=" .. sp:type())
    example_print_log("orientation=" .. sp:getOrientation())
    sp:setFirstChild(0)
    sp:setSecondChild(1)
    local fc = sp:getFirstChild()
    example_print_log("fc=" .. tostring(fc))
    local sc = sp:getSecondChild()
    example_print_log("sc=" .. tostring(sc))
    sp:setSplitPosition(200)
    example_print_log("split_pos=" .. sp:getSplitPosition())
    sp:setMinPanelSize(80)
    example_print_log("min_panel=" .. sp:getMinPanelSize())
    sp:setOrientation("vertical")
    example_print_log("orientation_after=" .. sp:getOrientation())
end

--@api: LSplitPanel:setOrientation
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newSplitPanel("horizontal")
    example_print_log("type=" .. sp:type())
    example_print_log("orientation=" .. sp:getOrientation())
    sp:setFirstChild(0)
    sp:setSecondChild(1)
    local fc = sp:getFirstChild()
    example_print_log("fc=" .. tostring(fc))
    local sc = sp:getSecondChild()
    example_print_log("sc=" .. tostring(sc))
    sp:setSplitPosition(200)
    example_print_log("split_pos=" .. sp:getSplitPosition())
    sp:setMinPanelSize(80)
    example_print_log("min_panel=" .. sp:getMinPanelSize())
    sp:setOrientation("vertical")
    example_print_log("orientation_after=" .. sp:getOrientation())
end

--@api: LSplitPanel:setSecondChild
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newSplitPanel("horizontal")
    example_print_log("type=" .. sp:type())
    example_print_log("orientation=" .. sp:getOrientation())
    sp:setFirstChild(0)
    sp:setSecondChild(1)
    local fc = sp:getFirstChild()
    example_print_log("fc=" .. tostring(fc))
    local sc = sp:getSecondChild()
    example_print_log("sc=" .. tostring(sc))
    sp:setSplitPosition(200)
    example_print_log("split_pos=" .. sp:getSplitPosition())
    sp:setMinPanelSize(80)
    example_print_log("min_panel=" .. sp:getMinPanelSize())
    sp:setOrientation("vertical")
    example_print_log("orientation_after=" .. sp:getOrientation())
end

--@api: LSplitPanel:setSplitPosition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newSplitPanel("horizontal")
    example_print_log("type=" .. sp:type())
    example_print_log("orientation=" .. sp:getOrientation())
    sp:setFirstChild(0)
    sp:setSecondChild(1)
    local fc = sp:getFirstChild()
    example_print_log("fc=" .. tostring(fc))
    local sc = sp:getSecondChild()
    example_print_log("sc=" .. tostring(sc))
    sp:setSplitPosition(200)
    example_print_log("split_pos=" .. sp:getSplitPosition())
    sp:setMinPanelSize(80)
    example_print_log("min_panel=" .. sp:getMinPanelSize())
    sp:setOrientation("vertical")
    example_print_log("orientation_after=" .. sp:getOrientation())
end

--@api: LSwitch:isOn
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sw = lurek.ui.newSwitch(false)
    example_print_log("type=" .. sw:type())
    example_print_log("is_on=" .. tostring(sw:isOn()))
    sw:setOn(true)
    example_print_log("is_on_after=" .. tostring(sw:isOn()))
    sw:setOnChange(function(v) example_print_log("switch_changed=" .. tostring(v)) end)
end

--@api: LSwitch:setOnChange
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sw = lurek.ui.newSwitch(false)
    example_print_log("type=" .. sw:type())
    example_print_log("is_on=" .. tostring(sw:isOn()))
    sw:setOn(true)
    example_print_log("is_on_after=" .. tostring(sw:isOn()))
    sw:setOnChange(function(v) example_print_log("switch_changed=" .. tostring(v)) end)
end

--@api: LGuiTable:addColumn
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.ui.newTable()
    example_print_log("type=" .. tbl:type())
    tbl:addColumn("Name")
    tbl:addColumn("Score")
    example_print_log("cols=" .. tbl:getColumnCount())
    tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" })
    example_print_log("rows=" .. tbl:getRowCount())
    example_print_log("cell11=" .. tostring(tbl:getCell(1, 1)))
    tbl:setCell(1, 2, "999")
    tbl:setSelectedRow(1)
    example_print_log("selected=" .. tostring(tbl:getSelectedRow()))
end

--@api: LGuiTable:addRow
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.ui.newTable()
    example_print_log("type=" .. tbl:type())
    tbl:addColumn("Name")
    tbl:addColumn("Score")
    example_print_log("cols=" .. tbl:getColumnCount())
    tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" })
    example_print_log("rows=" .. tbl:getRowCount())
    local cell = tbl:getCell(0, 0)
    example_print_log("cell00=" .. tostring(cell))
    tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1)
    example_print_log("selected=" .. tbl:getSelectedRow())
end

--@api: LGuiTable:clearRows
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.ui.newTable()
    tbl:setRows({ { "Food", 420 }, { "Rent", 1200 } })
    tbl:setSelectedRow(1)
    tbl:clearRows()
    example_print_log("rows=" .. tbl:getRowCount())
end

--@api: LGuiTable:setRows
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.ui.newTable()
    local count = tbl:setRows({ { "Income", 3200 }, { "Savings", 640 } })
    example_print_log("setRows=" .. count .. ", first=" .. tostring(tbl:getCell(1, 1)))
    example_print_log("rect x = " .. select(1, tbl:getRect()))
    example_print_log("rect y = " .. select(2, tbl:getRect()))
end

--@api: LGuiTable:setDataFrame
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local df = lurek.dataframe.fromRows({ "category", "amount" }, { { "Food", 420 }, { "Rent", 1200 } })
    local tbl = lurek.ui.newTable()
    local count = tbl:setDataFrame(df, { columns = { "category", "amount" }, maxRows = 2 })
    example_print_log("setDataFrame=" .. count .. ", cols=" .. tbl:getColumnCount())
    example_print_log("rect x = " .. select(1, tbl:getRect()))
end

--@api: LGuiTable:getCell
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.ui.newTable()
    example_print_log("type=" .. tbl:type())
    tbl:addColumn("Name")
    tbl:addColumn("Score")
    example_print_log("cols=" .. tbl:getColumnCount())
    tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" })
    example_print_log("rows=" .. tbl:getRowCount())
    local cell = tbl:getCell(0, 0)
    example_print_log("cell00=" .. tostring(cell))
    tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1)
    example_print_log("selected=" .. tbl:getSelectedRow())
end

--@api: LGuiTable:getColumnCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.ui.newTable()
    example_print_log("type=" .. tbl:type())
    tbl:addColumn("Name")
    tbl:addColumn("Score")
    example_print_log("cols=" .. tbl:getColumnCount())
    tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" })
    example_print_log("rows=" .. tbl:getRowCount())
    local cell = tbl:getCell(0, 0)
    example_print_log("cell00=" .. tostring(cell))
    tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1)
    example_print_log("selected=" .. tbl:getSelectedRow())
end

--@api: LGuiTable:getRowCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.ui.newTable()
    example_print_log("type=" .. tbl:type())
    tbl:addColumn("Name")
    tbl:addColumn("Score")
    example_print_log("cols=" .. tbl:getColumnCount())
    tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" })
    example_print_log("rows=" .. tbl:getRowCount())
    local cell = tbl:getCell(0, 0)
    example_print_log("cell00=" .. tostring(cell))
    tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1)
    example_print_log("selected=" .. tbl:getSelectedRow())
end

--@api: LGuiTable:getSelectedRow
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.ui.newTable()
    example_print_log("type=" .. tbl:type())
    tbl:addColumn("Name")
    tbl:addColumn("Score")
    example_print_log("cols=" .. tbl:getColumnCount())
    tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" })
    example_print_log("rows=" .. tbl:getRowCount())
    local cell = tbl:getCell(0, 0)
    example_print_log("cell00=" .. tostring(cell))
    tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1)
    example_print_log("selected=" .. tbl:getSelectedRow())
end

--@api: LGuiTable:setCell
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.ui.newTable()
    example_print_log("type=" .. tbl:type())
    tbl:addColumn("Name")
    tbl:addColumn("Score")
    example_print_log("cols=" .. tbl:getColumnCount())
    tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" })
    example_print_log("rows=" .. tbl:getRowCount())
    local cell = tbl:getCell(0, 0)
    example_print_log("cell00=" .. tostring(cell))
    tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1)
    example_print_log("selected=" .. tbl:getSelectedRow())
end

--@api: LGuiTable:setSelectedRow
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.ui.newTable()
    example_print_log("type=" .. tbl:type())
    tbl:addColumn("Name")
    tbl:addColumn("Score")
    example_print_log("cols=" .. tbl:getColumnCount())
    tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" })
    example_print_log("rows=" .. tbl:getRowCount())
    local cell = tbl:getCell(0, 0)
    example_print_log("cell00=" .. tostring(cell))
    tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1)
    example_print_log("selected=" .. tbl:getSelectedRow())
end

--@api: lurek.ui.newTable
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.ui.newTable()
    example_print_log("type=" .. tbl:type())
    tbl:addColumn("Name")
    tbl:addColumn("Score")
    example_print_log("cols=" .. tbl:getColumnCount())
    tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" })
    example_print_log("rows=" .. tbl:getRowCount())
    local cell = tbl:getCell(0, 0)
    example_print_log("cell00=" .. tostring(cell))
    tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1)
    example_print_log("selected=" .. tbl:getSelectedRow())
end

--@api: LToast:getDuration
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local toast = lurek.ui.newToast("File saved", 3.0)
    example_print_log("type=" .. toast:type())
    example_print_log("msg=" .. toast:getMessage())
    example_print_log("dur=" .. toast:getDuration())
    example_print_log("progress=" .. toast:getProgress())
    example_print_log("expired=" .. tostring(toast:isExpired()))
    toast:setMessage("Updated message")
    toast:setDuration(5.0)
    example_print_log("msg_after=" .. toast:getMessage())
    example_print_log("dur_after=" .. toast:getDuration())
end

--@api: LToast:getMessage
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local toast = lurek.ui.newToast("File saved", 3.0)
    example_print_log("type=" .. toast:type())
    example_print_log("msg=" .. toast:getMessage())
    example_print_log("dur=" .. toast:getDuration())
    example_print_log("progress=" .. toast:getProgress())
    example_print_log("expired=" .. tostring(toast:isExpired()))
    toast:setMessage("Updated message")
    toast:setDuration(5.0)
    example_print_log("msg_after=" .. toast:getMessage())
    example_print_log("dur_after=" .. toast:getDuration())
end

--@api: LToast:getProgress
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local toast = lurek.ui.newToast("File saved", 3.0)
    example_print_log("type=" .. toast:type())
    example_print_log("msg=" .. toast:getMessage())
    example_print_log("dur=" .. toast:getDuration())
    example_print_log("progress=" .. toast:getProgress())
    example_print_log("expired=" .. tostring(toast:isExpired()))
    toast:setMessage("Updated message")
    toast:setDuration(5.0)
    example_print_log("msg_after=" .. toast:getMessage())
    example_print_log("dur_after=" .. toast:getDuration())
end

--@api: LToast:isExpired
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local toast = lurek.ui.newToast("File saved", 3.0)
    example_print_log("type=" .. toast:type())
    example_print_log("msg=" .. toast:getMessage())
    example_print_log("dur=" .. toast:getDuration())
    example_print_log("progress=" .. toast:getProgress())
    example_print_log("expired=" .. tostring(toast:isExpired()))
    toast:setMessage("Updated message")
    toast:setDuration(5.0)
    example_print_log("msg_after=" .. toast:getMessage())
    example_print_log("dur_after=" .. toast:getDuration())
end

--@api: LToast:setDuration
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local toast = lurek.ui.newToast("File saved", 3.0)
    example_print_log("type=" .. toast:type())
    example_print_log("msg=" .. toast:getMessage())
    example_print_log("dur=" .. toast:getDuration())
    example_print_log("progress=" .. toast:getProgress())
    example_print_log("expired=" .. tostring(toast:isExpired()))
    toast:setMessage("Updated message")
    toast:setDuration(5.0)
    example_print_log("msg_after=" .. toast:getMessage())
    example_print_log("dur_after=" .. toast:getDuration())
end

--@api: LToast:setMessage
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local toast = lurek.ui.newToast("File saved", 3.0)
    example_print_log("type=" .. toast:type())
    example_print_log("msg=" .. toast:getMessage())
    example_print_log("dur=" .. toast:getDuration())
    example_print_log("progress=" .. toast:getProgress())
    example_print_log("expired=" .. tostring(toast:isExpired()))
    toast:setMessage("Updated message")
    toast:setDuration(5.0)
    example_print_log("msg_after=" .. toast:getMessage())
    example_print_log("dur_after=" .. toast:getDuration())
end

--@api: LTooltipPanel:getDelay
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ttp = lurek.ui.newTooltipPanel("Hover info")
    example_print_log("type=" .. ttp:type())
    example_print_log("text=" .. ttp:getText())
    ttp:setText("Updated tooltip")
    example_print_log("text_after=" .. ttp:getText())
    ttp:setDelay(0.5)
    example_print_log("delay=" .. ttp:getDelay())
end

--@api: LTooltipPanel:getText
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ttp = lurek.ui.newTooltipPanel("Hover info")
    example_print_log("type=" .. ttp:type())
    example_print_log("text=" .. ttp:getText())
    ttp:setText("Updated tooltip")
    example_print_log("text_after=" .. ttp:getText())
    ttp:setDelay(0.5)
    example_print_log("delay=" .. ttp:getDelay())
end

--@api: LTooltipPanel:setDelay
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ttp = lurek.ui.newTooltipPanel("Hover info")
    example_print_log("type=" .. ttp:type())
    example_print_log("text=" .. ttp:getText())
    ttp:setText("Updated tooltip")
    example_print_log("text_after=" .. ttp:getText())
    ttp:setDelay(0.5)
    example_print_log("delay=" .. ttp:getDelay())
end

--@api: LTooltipPanel:setText
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ttp = lurek.ui.newTooltipPanel("Hover info")
    example_print_log("type=" .. ttp:type())
    example_print_log("text=" .. ttp:getText())
    ttp:setText("Updated tooltip")
    example_print_log("text_after=" .. ttp:getText())
    ttp:setDelay(0.5)
    example_print_log("delay=" .. ttp:getDelay())
end

--@api: LTreeView:addNode
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child = tv:addNode("Child C", root)
    example_print_log("child added = " .. tostring(child ~= nil))
    example_print_log("node count = " .. tv:getNodeCount())
end

--@api: LTreeView:clearNodes
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    tv:clearNodes()
    example_print_log("nodes = " .. tv:getNodeCount())
end

--@api: LTreeView:collapseAll
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    tv:expandAll()
    tv:collapseAll()
    example_print_log("root expanded = " .. tostring(tv:isExpanded(root)))
end

--@api: LTreeView:collapseNode
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:expandNode(root)
    tv:collapseNode(root)
    example_print_log("root expanded = " .. tostring(tv:isNodeExpanded(root)))
end

--@api: LTreeView:expandAll
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    tv:expandAll()
    example_print_log("root expanded = " .. tostring(tv:isExpanded(root)))
end

--@api: LTreeView:expandNode
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:expandNode(root)
    example_print_log("root expanded = " .. tostring(tv:isNodeExpanded(root)))
    example_print_log("node count = " .. tv:getNodeCount())
end

--@api: LTreeView:getChildNodes
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    tv:addNode("Child B", root)
    local children = tv:getChildNodes(root)
    example_print_log("child count = " .. #children)
end

--@api: LTreeView:getNodeCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    example_print_log("nodes = " .. tv:getNodeCount())
    example_print_log("node count = " .. tv:getNodeCount())
end

--@api: LTreeView:getNodeDepth
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    example_print_log("depth = " .. tv:getNodeDepth(child1))
    example_print_log("node count = " .. tv:getNodeCount())
end

--@api: LTreeView:getNodeText
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    example_print_log("text = " .. tv:getNodeText(child1))
    example_print_log("node count = " .. tv:getNodeCount())
end

--@api: LTreeView:getParentNode
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    example_print_log("parent = " .. tostring(tv:getParentNode(child1) == root))
    example_print_log("node count = " .. tv:getNodeCount())
end

--@api: LTreeView:getSelectedNode
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    tv:setSelectedNode(child1)
    example_print_log("selected = " .. tostring(tv:getSelectedNode()))
end

--@api: LTreeView:isExpanded
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:expandAll()
    example_print_log("expanded = " .. tostring(tv:isExpanded(root)))
    example_print_log("node count = " .. tv:getNodeCount())
end

--@api: LTreeView:isNodeExpanded
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:expandNode(root)
    example_print_log("node expanded = " .. tostring(tv:isNodeExpanded(root)))
    example_print_log("node count = " .. tv:getNodeCount())
end

--@api: LTreeView:removeNode
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    local child2 = tv:addNode("Child B", root)
    tv:removeNode(child2)
    example_print_log("nodes = " .. tv:getNodeCount())
end

--@api: LTreeView:setNodeIcon
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    tv:setNodeIcon(child1, "folder")
    example_print_log("icon set on child")
end

--@api: LTreeView:setNodeText
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    tv:setNodeText(child1, "Renamed A")
    example_print_log("text = " .. tv:getNodeText(child1))
end

--@api: LTreeView:setSelectedNode
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    tv:setSelectedNode(child1)
    example_print_log("selected = " .. tostring(tv:getSelectedNode()))
end

--@api: LTreeView:toggleNode
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    local child2 = tv:addNode("Child B", root)
    tv:toggleNode(child2)
    example_print_log("child toggled")
end

--@api: LAccordion:getSectionTitle.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local acc = lurek.ui.newAccordion()
    acc:addSection("Chapter 1")
    acc:addSection("Chapter 2")
    local cnt = acc:getSectionCount()
    local title = acc:getSectionTitle(1)
    example_print_log("sections:", cnt, "title:", title)
end

--@api: LAccordion:getSectionTitle.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local acc = lurek.ui.newAccordion()
    acc:addSection("Chapter 1")
    acc:addSection("Chapter 2")
    local cnt = acc:getSectionCount()
    local title = acc:getSectionTitle(1)
    example_print_log("sections:", cnt, "title:", title)
end

--@api: LAccordion:getSectionTitle.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local acc = lurek.ui.newAccordion()
    acc:addSection("Chapter 1")
    acc:addSection("Chapter 2")
    local cnt = acc:getSectionCount()
    local title = acc:getSectionTitle(1)
    example_print_log("sections:", cnt, "title:", title)
end

--@api: LAccordion:isSectionExpanded.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local acc = lurek.ui.newAccordion()
    acc:addSection("A")
    acc:setExclusive(true)
    local ex = acc:isExclusive()
    local expanded = acc:isSectionExpanded(1)
    example_print_log("exclusive:", ex, "expanded:", expanded)
end

--@api: LAccordion:isSectionExpanded.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local acc = lurek.ui.newAccordion()
    acc:addSection("A")
    acc:setExclusive(true)
    local ex = acc:isExclusive()
    local expanded = acc:isSectionExpanded(1)
    example_print_log("exclusive:", ex, "expanded:", expanded)
end

--@api: LAccordion:isSectionExpanded.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local acc = lurek.ui.newAccordion()
    acc:addSection("A")
    acc:setExclusive(true)
    local ex = acc:isExclusive()
    local expanded = acc:isSectionExpanded(1)
    example_print_log("exclusive:", ex, "expanded:", expanded)
end

--@api: LAccordion:toggleSection.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local acc = lurek.ui.newAccordion()
    acc:addSection("Toggle me")
    local newState = acc:toggleSection(1)
    local badge = lurek.ui.newBadge(5)
    local count = badge:getCount()
    local disp = badge:getDisplayText()
    example_print_log("toggled:", newState, "badge count:", count, "display:", disp)
end

--@api: LAccordion:toggleSection.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local acc = lurek.ui.newAccordion()
    acc:addSection("Toggle me")
    local newState = acc:toggleSection(1)
    local badge = lurek.ui.newBadge(5)
    local count = badge:getCount()
    local disp = badge:getDisplayText()
    example_print_log("toggled:", newState, "badge count:", count, "display:", disp)
end

--@api: LAccordion:toggleSection.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local acc = lurek.ui.newAccordion()
    acc:addSection("Toggle me")
    local newState = acc:toggleSection(1)
    local badge = lurek.ui.newBadge(5)
    local count = badge:getCount()
    local disp = badge:getDisplayText()
    example_print_log("toggled:", newState, "badge count:", count, "display:", disp)
end

--@api: LBadge:setCount.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local badge = lurek.ui.newBadge(0)
    badge:setCount(42)
    local btn = lurek.ui.newButton("Click me")
    local t = btn:getText()
    btn:setText("OK")
    example_print_log("badge count:", badge:getCount(), "button text:", btn:getText())
end

--@api: LButton:getText
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local badge = lurek.ui.newBadge(0)
    badge:setCount(42)
    local btn = lurek.ui.newButton("Click me")
    local t = btn:getText()
    btn:setText("OK")
    example_print_log("badge count:", badge:getCount(), "button text:", btn:getText())
end

--@api: LButton:setText
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local badge = lurek.ui.newBadge(0)
    badge:setCount(42)
    local btn = lurek.ui.newButton("Click me")
    local t = btn:getText()
    btn:setText("OK")
    example_print_log("badge count:", badge:getCount(), "button text:", btn:getText())
end

--@api: LCheckbox:getText
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cb = lurek.ui.newCheckbox("Enable feature")
    local t = cb:getText()
    cb:setChecked(true)
    local checked = cb:isChecked()
    example_print_log("checkbox text:", t, "checked:", checked)
end

--@api: LCheckbox:isChecked
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cb = lurek.ui.newCheckbox("Enable feature")
    local t = cb:getText()
    cb:setChecked(true)
    local checked = cb:isChecked()
    example_print_log("checkbox text:", t, "checked:", checked)
end

--@api: LCheckbox:isChecked.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cb = lurek.ui.newCheckbox("Enable feature")
    local t = cb:getText()
    cb:setChecked(true)
    local checked = cb:isChecked()
    example_print_log("checkbox text:", t, "checked:", checked)
end

--@api: LCheckbox:setText.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cb = lurek.ui.newCheckbox("old")
    cb:setText("new label")
    example_print_log("checkbox setText ok")
    example_print_log("checkbox text = " .. cb:getText())
    example_print_log("checked = " .. tostring(cb:isChecked()))
end

--@api: LColorPicker:getShowAlpha.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cp = lurek.ui.newColorPicker()
    cp:setColor(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = cp:getColor()
    local mode = cp:getColorMode()
    local showAlpha = cp:getShowAlpha()
    example_print_log("color:", r, g, b, a, "mode:", mode, "showAlpha:", showAlpha)
end

--@api: LColorPicker:getShowAlpha.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cp = lurek.ui.newColorPicker()
    cp:setColor(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = cp:getColor()
    local mode = cp:getColorMode()
    local showAlpha = cp:getShowAlpha()
    example_print_log("color:", r, g, b, a, "mode:", mode, "showAlpha:", showAlpha)
end

--@api: LColorPicker:getShowAlpha.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cp = lurek.ui.newColorPicker()
    cp:setColor(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = cp:getColor()
    local mode = cp:getColorMode()
    local showAlpha = cp:getShowAlpha()
    example_print_log("color:", r, g, b, a, "mode:", mode, "showAlpha:", showAlpha)
end

--@api: LColorPicker:setColorMode.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cp = lurek.ui.newColorPicker()
    cp:setColor(0.2, 0.8, 0.4, 1.0)
    cp:setColorMode("hsv")
    cp:setOnChange(function(idx) example_print_log("color changed", idx) end)
    cp:setShowAlpha(true)
    example_print_log("setColor/setColorMode/setOnChange ok")
end

--@api: LColorPicker:setColorMode.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cp = lurek.ui.newColorPicker()
    cp:setColor(0.2, 0.8, 0.4, 1.0)
    cp:setColorMode("hsv")
    cp:setOnChange(function(idx) example_print_log("color changed", idx) end)
    cp:setShowAlpha(true)
    example_print_log("setColor/setColorMode/setOnChange ok")
end

--@api: LColorPicker:setColorMode.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cp = lurek.ui.newColorPicker()
    cp:setColor(0.2, 0.8, 0.4, 1.0)
    cp:setColorMode("hsv")
    cp:setOnChange(function(idx) example_print_log("color changed", idx) end)
    cp:setShowAlpha(true)
    example_print_log("setColor/setColorMode/setOnChange ok")
end

--@api: LColorPicker:setShowAlpha.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cp = lurek.ui.newColorPicker()
    cp:setShowAlpha(false)
    local cb = lurek.ui.newComboBox()
    cb:addItem("Option A")
    cb:addItem("Option B")
    cb:addItem("Option C")
    cb:clearItems()
    example_print_log("setShowAlpha ok; combo items cleared")
end

--@api: LColorPicker:setShowAlpha.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cp = lurek.ui.newColorPicker()
    cp:setShowAlpha(false)
    local cb = lurek.ui.newComboBox()
    cb:addItem("Option A")
    cb:addItem("Option B")
    cb:addItem("Option C")
    cb:clearItems()
    example_print_log("setShowAlpha ok; combo items cleared")
end

--@api: LColorPicker:setShowAlpha.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cp = lurek.ui.newColorPicker()
    cp:setShowAlpha(false)
    local cb = lurek.ui.newComboBox()
    cb:addItem("Option A")
    cb:addItem("Option B")
    cb:addItem("Option C")
    cb:clearItems()
    example_print_log("setShowAlpha ok; combo items cleared")
end

--@api: LComboBox:getSelectedIndex.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cb = lurek.ui.newComboBox()
    cb:addItem("First")
    cb:addItem("Second")
    cb:addItem("Third")
    local cnt = cb:getItemCount()
    local item = cb:getItem(2)
    cb:setSelectedIndex(1)
    local sel = cb:getSelectedIndex()
    example_print_log("getItemCount:", cnt, "getItem:", item, "getSelectedIndex:", sel)
end

--@api: LComboBox:getSelectedIndex.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cb = lurek.ui.newComboBox()
    cb:addItem("First")
    cb:addItem("Second")
    cb:addItem("Third")
    local cnt = cb:getItemCount()
    local item = cb:getItem(2)
    cb:setSelectedIndex(1)
    local sel = cb:getSelectedIndex()
    example_print_log("getItemCount:", cnt, "getItem:", item, "getSelectedIndex:", sel)
end

--@api: LComboBox:getSelectedIndex.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cb = lurek.ui.newComboBox()
    cb:addItem("First")
    cb:addItem("Second")
    cb:addItem("Third")
    local cnt = cb:getItemCount()
    local item = cb:getItem(2)
    cb:setSelectedIndex(1)
    local sel = cb:getSelectedIndex()
    example_print_log("getItemCount:", cnt, "getItem:", item, "getSelectedIndex:", sel)
end

--@api: LComboBox:removeItem.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cb = lurek.ui.newComboBox()
    cb:addItem("Alpha")
    cb:addItem("Beta")
    cb:setSelectedIndex(2)
    local selItem = cb:getSelectedItem()
    cb:removeItem(1)
    example_print_log("getSelectedItem:", selItem, "removeItem ok")
end

--@api: LComboBox:removeItem
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cb = lurek.ui.newComboBox()
    cb:addItem("Alpha")
    cb:addItem("Beta")
    cb:setSelectedIndex(2)
    local selItem = cb:getSelectedItem()
    cb:removeItem(1)
    example_print_log("getSelectedItem:", selItem, "removeItem ok")
end

--@api: LComboBox:setSelectedIndex
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cb = lurek.ui.newComboBox()
    cb:addItem("Alpha")
    cb:addItem("Beta")
    cb:setSelectedIndex(2)
    local selItem = cb:getSelectedItem()
    cb:removeItem(1)
    example_print_log("getSelectedItem:", selItem, "removeItem ok")
end

--@api: LDialog:addButton
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Info")
    local btnIdx = dlg:addButton("OK")
    local content = dlg:getContent()
    dlg:open()
    dlg:close()
    example_print_log("addButton:", btnIdx, "close ok")
end

--@api: LDialog:close
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Info")
    local btnIdx = dlg:addButton("OK")
    local content = dlg:getContent()
    dlg:open()
    dlg:close()
    example_print_log("addButton:", btnIdx, "close ok")
end

--@api: LDialog:getContent
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Info")
    local btnIdx = dlg:addButton("OK")
    local content = dlg:getContent()
    dlg:open()
    dlg:close()
    example_print_log("addButton:", btnIdx, "close ok")
end

--@api: LDialog:getTitle
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("My Dialog")
    local title = dlg:getTitle()
    dlg:setModal(true)
    local modal = dlg:isModal()
    local open = dlg:isOpen()
    example_print_log("title:", title, "isModal:", modal, "isOpen:", open)
end

--@api: LDialog:isModal
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("My Dialog")
    local title = dlg:getTitle()
    dlg:setModal(true)
    local modal = dlg:isModal()
    local open = dlg:isOpen()
    example_print_log("title:", title, "isModal:", modal, "isOpen:", open)
end

--@api: LDialog:isOpen
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("My Dialog")
    local title = dlg:getTitle()
    dlg:setModal(true)
    local modal = dlg:isModal()
    local open = dlg:isOpen()
    example_print_log("title:", title, "isModal:", modal, "isOpen:", open)
end

--@api: LDialog:open
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Setup")
    dlg:setModal(false)
    dlg:setContent(nil)
    dlg:open()
    dlg:close()
    example_print_log("open/setContent/setModal ok")
end

--@api: LDialog:setContent
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Setup")
    dlg:setModal(false)
    dlg:setContent(nil)
    dlg:open()
    dlg:close()
    example_print_log("open/setContent/setModal ok")
end

--@api: LDialog:setModal
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Setup")
    dlg:setModal(false)
    dlg:setContent(nil)
    dlg:open()
    dlg:close()
    example_print_log("open/setContent/setModal ok")
end

--@api: LDialog:setOnClose
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Old")
    dlg:setTitle("New Title")
    dlg:setOnClose(function(idx) example_print_log("closed", idx) end)
    local dp = lurek.ui.newDockPanel()
    local btn = lurek.ui.newButton("Side")
    example_print_log("setTitle/setOnClose ok; DockPanel created")
end

--@api: LDialog:setTitle
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Old")
    dlg:setTitle("New Title")
    dlg:setOnClose(function(idx) example_print_log("closed", idx) end)
    local dp = lurek.ui.newDockPanel()
    local btn = lurek.ui.newButton("Side")
    example_print_log("setTitle/setOnClose ok; DockPanel created")
end

--@api: LDialog:setTitle.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Old")
    dlg:setTitle("New Title")
    dlg:setOnClose(function(idx) example_print_log("closed", idx) end)
    local dp = lurek.ui.newDockPanel()
    local btn = lurek.ui.newButton("Side")
    example_print_log("setTitle/setOnClose ok; DockPanel created")
end

--@api: LDialog:addAction
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Actions")
    local idx = dlg:addAction("Apply", nil, "default", true)
    dlg:setDefaultAction(idx)
    example_print_log("addAction/default:", idx, dlg:getDefaultAction())
    example_print_log("dialog title = " .. dlg:getTitle())
end

--@api: LDialog:centerInViewport
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Center")
    dlg:setCenterOnOpen(false)
    dlg:centerInViewport()
    example_print_log("centerInViewport ok")
    example_print_log("dialog title = " .. dlg:getTitle())
end

--@api: LDialog:getCancelAction
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Cancel")
    local idx = dlg:addAction("Cancel", nil, "cancel", true)
    dlg:setCancelAction(idx)
    example_print_log("cancel action:", dlg:getCancelAction())
    example_print_log("dialog title = " .. dlg:getTitle())
end

--@api: LDialog:getDefaultAction
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Default")
    local idx = dlg:addAction("Confirm", nil, "default", true)
    dlg:setDefaultAction(idx)
    example_print_log("default action:", dlg:getDefaultAction())
    example_print_log("dialog title = " .. dlg:getTitle())
end

--@api: LDialog:setDefaultAction
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Default Setter")
    local idx = dlg:addAction("Confirm", nil, "default", true)
    dlg:setDefaultAction(idx)
    example_print_log("set default action:", idx)
    example_print_log("dialog title = " .. dlg:getTitle())
end

--@api: LDialog:getCenterOnOpen
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Center Flag")
    dlg:setCenterOnOpen(false)
    example_print_log("centerOnOpen:", dlg:getCenterOnOpen())
    example_print_log("dialog title = " .. dlg:getTitle())
    example_print_log("dialog open = " .. tostring(dlg:isOpen()))
end

--@api: LDialog:getDismissOnOutsideClick
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Dismiss Flag")
    dlg:setDismissOnOutsideClick(true)
    example_print_log("dismissOnOutsideClick:", dlg:getDismissOnOutsideClick())
    example_print_log("dialog title = " .. dlg:getTitle())
    example_print_log("dialog open = " .. tostring(dlg:isOpen()))
end

--@api: LDialog:getFooter
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Footer")
    local footer = lurek.ui.newPanel()
    dlg:setFooter(footer._idx)
    example_print_log("footer idx:", dlg:getFooter())
    example_print_log("dialog title = " .. dlg:getTitle())
end

--@api: LDialog:getMaxSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Max")
    dlg:setMaxSize(420, 260)
    local w, h = dlg:getMaxSize()
    example_print_log("max size:", w, h)
    example_print_log("dialog title = " .. dlg:getTitle())
end

--@api: LDialog:getMinSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Min")
    dlg:setMinSize(220, 140)
    local w, h = dlg:getMinSize()
    example_print_log("min size:", w, h)
    example_print_log("dialog title = " .. dlg:getTitle())
end

--@api: LDialog:isCloseable
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Closeable")
    example_print_log("isCloseable:", dlg:isCloseable())
    example_print_log("dialog title = " .. dlg:getTitle())
    example_print_log("dialog open = " .. tostring(dlg:isOpen()))
    example_print_log("dialog modal = " .. tostring(dlg:isModal()))
end

--@api: LDialog:isDraggable
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Draggable")
    example_print_log("isDraggable:", dlg:isDraggable())
    example_print_log("dialog title = " .. dlg:getTitle())
    example_print_log("dialog open = " .. tostring(dlg:isOpen()))
    example_print_log("dialog modal = " .. tostring(dlg:isModal()))
end

--@api: LDialog:isResizable
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Resizable")
    example_print_log("isResizable:", dlg:isResizable())
    example_print_log("dialog title = " .. dlg:getTitle())
    example_print_log("dialog open = " .. tostring(dlg:isOpen()))
    example_print_log("dialog modal = " .. tostring(dlg:isModal()))
end

--@api: LDialog:setCloseable
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Closeable Setter")
    dlg:setCloseable(false)
    example_print_log("setCloseable:", false)
    example_print_log("dialog title = " .. dlg:getTitle())
    example_print_log("dialog open = " .. tostring(dlg:isOpen()))
end

--@api: LDialog:setDraggable
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Draggable Setter")
    dlg:setDraggable(true)
    example_print_log("setDraggable:", true)
    example_print_log("dialog title = " .. dlg:getTitle())
    example_print_log("dialog open = " .. tostring(dlg:isOpen()))
end

--@api: LDialog:setResizable
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Resizable Setter")
    dlg:setResizable(true)
    example_print_log("setResizable:", true)
    example_print_log("dialog title = " .. dlg:getTitle())
    example_print_log("dialog open = " .. tostring(dlg:isOpen()))
end

--@api: LDialog:setFooter
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Footer Setter")
    local footer = lurek.ui.newLayout("horizontal")
    dlg:setFooter(footer._idx)
    example_print_log("setFooter:", dlg:getFooter())
    example_print_log("dialog title = " .. dlg:getTitle())
end

--@api: LDialog:setMaxSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Max Size")
    dlg:setMaxSize(480, 320)
    example_print_log("setMaxSize:", 480, 320)
    example_print_log("dialog title = " .. dlg:getTitle())
    example_print_log("dialog open = " .. tostring(dlg:isOpen()))
end

--@api: LDialog:setMinSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Min Size")
    dlg:setMinSize(200, 120)
    example_print_log("setMinSize:", 200, 120)
    example_print_log("dialog title = " .. dlg:getTitle())
    example_print_log("dialog open = " .. tostring(dlg:isOpen()))
end

--@api: LDialog:setDismissOnOutsideClick
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Dismiss")
    dlg:setModal(false)
    dlg:setDismissOnOutsideClick(true)
    example_print_log("dismiss setter ok")
    example_print_log("dialog title = " .. dlg:getTitle())
end

--@api: LDialog:setCenterOnOpen
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Center Setter")
    dlg:setCenterOnOpen(false)
    example_print_log("setCenterOnOpen ok")
    example_print_log("dialog title = " .. dlg:getTitle())
    example_print_log("dialog open = " .. tostring(dlg:isOpen()))
end

--@api: LDialog:setCancelAction
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dlg = lurek.ui.newDialog("Cancel Setter")
    local idx = dlg:addAction("Abort", nil, "cancel", true)
    dlg:setCancelAction(idx)
    example_print_log("setCancelAction:", dlg:getCancelAction())
    example_print_log("dialog title = " .. dlg:getTitle())
end

--@api: LDockPanel:getSplitSize.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dp = lurek.ui.newDockPanel()
    local cnt = dp:getDockedCount()
    dp:setSplitSize("left", 200)
    local sz = dp:getSplitSize("left")
    example_print_log("getDockedCount:", cnt, "splitSize:", sz)
end

--@api: LDockPanel:getSplitSize.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dp = lurek.ui.newDockPanel()
    local cnt = dp:getDockedCount()
    dp:setSplitSize("left", 200)
    local sz = dp:getSplitSize("left")
    example_print_log("getDockedCount:", cnt, "splitSize:", sz)
end

--@api: LDockPanel:getSplitSize.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dp = lurek.ui.newDockPanel()
    local cnt = dp:getDockedCount()
    dp:setSplitSize("left", 200)
    local sz = dp:getSplitSize("left")
    example_print_log("getDockedCount:", cnt, "splitSize:", sz)
end

--@api: LDockPanel:undock.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dp = lurek.ui.newDockPanel()
    local dockedCount = dp:getDockedCount()
    dp:undock(0)
    local tbl = lurek.ui.newTable()
    example_print_log("undock ok (dockedCount was:", dockedCount, "); newTable ok")
end

--@api: LDockPanel:undock.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dp = lurek.ui.newDockPanel()
    local dockedCount = dp:getDockedCount()
    dp:undock(0)
    local tbl = lurek.ui.newTable()
    example_print_log("undock ok (dockedCount was:", dockedCount, "); newTable ok")
end

--@api: LDockPanel:undock.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dp = lurek.ui.newDockPanel()
    local dockedCount = dp:getDockedCount()
    dp:undock(0)
    local tbl = lurek.ui.newTable()
    example_print_log("undock ok (dockedCount was:", dockedCount, "); newTable ok")
end

--@api: LTable:addColumn
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.ui.newTable()
    tbl:addColumn("Name", 100)
    tbl:addColumn("Value", 80)
    tbl:addRow({"Alice", "42"})
    tbl:addRow({"Bob", "99"})
    local cell = tbl:getCell(1, 1)
    example_print_log("addColumn/addRow/getCell ok, cell:", cell)
end

--@api: LTable:getSelectedRow
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.ui.newTable()
    tbl:addColumn("Col1")
    tbl:addColumn("Col2")
    tbl:addRow({"A", "1"})
    tbl:addRow({"B", "2"})
    local cols = tbl:getColumnCount()
    local rows = tbl:getRowCount()
    local sel = tbl:getSelectedRow()
    example_print_log("cols:", cols, "rows:", rows, "selectedRow:", sel)
end

--@api: LTable:getSelectedRow.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.ui.newTable()
    tbl:addColumn("Col1")
    tbl:addColumn("Col2")
    tbl:addRow({"A", "1"})
    tbl:addRow({"B", "2"})
    local cols = tbl:getColumnCount()
    local rows = tbl:getRowCount()
    local sel = tbl:getSelectedRow()
    example_print_log("cols:", cols, "rows:", rows, "selectedRow:", sel)
end

--@api: LTable:getSelectedRow.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.ui.newTable()
    tbl:addColumn("Col1")
    tbl:addColumn("Col2")
    tbl:addRow({"A", "1"})
    tbl:addRow({"B", "2"})
    local cols = tbl:getColumnCount()
    local rows = tbl:getRowCount()
    local sel = tbl:getSelectedRow()
    example_print_log("cols:", cols, "rows:", rows, "selectedRow:", sel)
end

--@api: LGuiTable:isSortable
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.ui.newTable()
    tbl:addColumn("ID")
    tbl:addRow({"1"})
    tbl:setSortable(true)
    tbl:setCell(1, 1, "changed")
    tbl:setOnSelect(function(idx) example_print_log("row selected", idx) end)
    example_print_log("isSortable/setCell/setOnSelect ok")
end

--@api: LTable:setCell
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.ui.newTable()
    tbl:addColumn("ID")
    tbl:addRow({"1"})
    tbl:setSortable(true)
    tbl:setCell(1, 1, "changed")
    tbl:setOnSelect(function(idx) example_print_log("row selected", idx) end)
    example_print_log("isSortable/setCell/setOnSelect ok")
end

--@api: LGuiTable:setOnSelect
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.ui.newTable()
    tbl:addColumn("ID")
    tbl:addRow({"1"})
    tbl:setSortable(true)
    tbl:setCell(1, 1, "changed")
    tbl:setOnSelect(function(idx) example_print_log("row selected", idx) end)
    example_print_log("isSortable/setCell/setOnSelect ok")
end

--@api: LTable:setSortable
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.ui.newTable()
    tbl:addColumn("X")
    tbl:addRow({"row1"})
    tbl:setSelectedRow(1)
    local sel = tbl:getSelectedRow()
    tbl:setSortable(false)
    local win = lurek.ui.newWindow("My Window")
    local title = win:getTitle()
    example_print_log("setSelectedRow:", sel, "setSortable ok, win title:", title)
end

--@api: LGuiTable:setSortable
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("sorted first row:", tbl:getCell(1, 1))
end

--@api: LGuiWindow:getTitle
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.ui.newTable()
    tbl:addColumn("X")
    tbl:addRow({"row1"})
    tbl:setSelectedRow(1)
    local sel = tbl:getSelectedRow()
    tbl:setSortable(false)
    local win = lurek.ui.newWindow("My Window")
    local title = win:getTitle()
    example_print_log("setSelectedRow:", sel, "setSortable ok, win title:", title)
end

--@api: LGuiWindow:isCloseable
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local win = lurek.ui.newWindow("Test Win")
    local closeable = win:isCloseable()
    local draggable = win:isDraggable()
    local resizable = win:isResizable()
    example_print_log("isCloseable:", closeable, "isDraggable:", draggable, "isResizable:", resizable)
end

--@api: LGuiWindow:isDraggable
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local win = lurek.ui.newWindow("Test Win")
    local closeable = win:isCloseable()
    local draggable = win:isDraggable()
    local resizable = win:isResizable()
    example_print_log("isCloseable:", closeable, "isDraggable:", draggable, "isResizable:", resizable)
end

--@api: LGuiWindow:isResizable
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local win = lurek.ui.newWindow("Test Win")
    local closeable = win:isCloseable()
    local draggable = win:isDraggable()
    local resizable = win:isResizable()
    example_print_log("isCloseable:", closeable, "isDraggable:", draggable, "isResizable:", resizable)
end

--@api: LGuiWindow:setCloseable
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local win = lurek.ui.newWindow("Config")
    win:setCloseable(true)
    win:setDraggable(true)
    win:setOnClose(function(idx) example_print_log("window closed", idx) end)
    example_print_log("setCloseable/setDraggable/setOnClose ok")
end

--@api: LGuiWindow:setDraggable
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local win = lurek.ui.newWindow("Config")
    win:setCloseable(true)
    win:setDraggable(true)
    win:setOnClose(function(idx) example_print_log("window closed", idx) end)
    example_print_log("setCloseable/setDraggable/setOnClose ok")
end

--@api: LGuiWindow:setOnClose
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local win = lurek.ui.newWindow("Config")
    win:setCloseable(true)
    win:setDraggable(true)
    win:setOnClose(function(idx) example_print_log("window closed", idx) end)
    example_print_log("setCloseable/setDraggable/setOnClose ok")
end

--@api: LGuiWindow:setResizable
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local win = lurek.ui.newWindow("Old")
    win:setResizable(false)
    win:setTitle("New Title")
    local iw = lurek.ui.newImageWidget()
    local mode = iw:getScaleMode()
    example_print_log("setResizable/setTitle ok; scaleMode:", mode)
end

--@api: LGuiWindow:setTitle
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local win = lurek.ui.newWindow("Old")
    win:setResizable(false)
    win:setTitle("New Title")
    local iw = lurek.ui.newImageWidget()
    local mode = iw:getScaleMode()
    example_print_log("setResizable/setTitle ok; scaleMode:", mode)
end

--@api: LWindow:setResizable
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local win = lurek.ui.newWindow("Old")
    win:setResizable(false)
    win:setTitle("New Title")
    local iw = lurek.ui.newImageWidget()
    local mode = iw:getScaleMode()
    example_print_log("setResizable/setTitle ok; scaleMode:", mode)
end

--@api: LImageWidget:scaleMode
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iw = lurek.ui.newImageWidget()
    iw:setTint(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = iw:getTint()
    iw:setScaleMode("fit")
    example_print_log("tint:", r, g, b, a, "scaleMode: fit")
end

--@api: LImageWidget:setScaleMode.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iw = lurek.ui.newImageWidget()
    iw:setTint(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = iw:getTint()
    iw:setScaleMode("fit")
    example_print_log("tint:", r, g, b, a, "scaleMode: fit")
end

--@api: LImageWidget:setScaleMode.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iw = lurek.ui.newImageWidget()
    iw:setTint(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = iw:getTint()
    iw:setScaleMode("fit")
    example_print_log("tint:", r, g, b, a, "scaleMode: fit")
end

--@api: LLabel:getText
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lbl = lurek.ui.newLabel("Hello")
    lbl:setText("World")
    local layout = lurek.ui.newLayout("horizontal")
    local align = layout:getAlign()
    example_print_log("label text:", lbl:getText(), "layout align:", align)
end

--@api: LLabel:setText
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lbl = lurek.ui.newLabel("Hello")
    lbl:setText("World")
    local layout = lurek.ui.newLayout("horizontal")
    local align = layout:getAlign()
    example_print_log("label text:", lbl:getText(), "layout align:", align)
end

--@api: LLabel:setText.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lbl = lurek.ui.newLabel("Hello")
    lbl:setText("World")
    local layout = lurek.ui.newLayout("horizontal")
    local align = layout:getAlign()
    example_print_log("label text:", lbl:getText(), "layout align:", align)
end

--@api: LLayout:getDirection
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local layout = lurek.ui.newLayout("vertical")
    local dir = layout:getDirection()
    local justify = layout:getJustify()
    local spacing = layout:getSpacing()
    example_print_log("direction:", dir, "justify:", justify, "spacing:", spacing)
end

--@api: LLayout:getSpacing.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local layout = lurek.ui.newLayout("vertical")
    local dir = layout:getDirection()
    local justify = layout:getJustify()
    local spacing = layout:getSpacing()
    example_print_log("direction:", dir, "justify:", justify, "spacing:", spacing)
end

--@api: LLayout:getSpacing
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local layout = lurek.ui.newLayout("vertical")
    local dir = layout:getDirection()
    local justify = layout:getJustify()
    local spacing = layout:getSpacing()
    example_print_log("direction:", dir, "justify:", justify, "spacing:", spacing)
end

--@api: LLayout:setColumns.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local layout = lurek.ui.newLayout("grid")
    local wrap = layout:getWrap()
    layout:setAlign("center")
    layout:setColumns(3)
    example_print_log("getWrap:", wrap, "setAlign: center, setColumns: 3 ok")
end

--@api: LLayout:setColumns.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local layout = lurek.ui.newLayout("grid")
    local wrap = layout:getWrap()
    layout:setAlign("center")
    layout:setColumns(3)
    example_print_log("getWrap:", wrap, "setAlign: center, setColumns: 3 ok")
end

--@api: LLayout:setColumns.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local layout = lurek.ui.newLayout("grid")
    local wrap = layout:getWrap()
    layout:setAlign("center")
    layout:setColumns(3)
    example_print_log("getWrap:", wrap, "setAlign: center, setColumns: 3 ok")
end

--@api: LLayout:setSpacing.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local layout = lurek.ui.newLayout("horizontal")
    layout:setDirection("vertical")
    layout:setJustify("center")
    layout:setSpacing(8)
    example_print_log("setDirection/setJustify/setSpacing ok")
end

--@api: LLayout:setSpacing.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local layout = lurek.ui.newLayout("horizontal")
    layout:setDirection("vertical")
    layout:setJustify("center")
    layout:setSpacing(8)
    example_print_log("setDirection/setJustify/setSpacing ok")
end

--@api: LLayout:setSpacing
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local layout = lurek.ui.newLayout("horizontal")
    layout:setDirection("vertical")
    layout:setJustify("center")
    layout:setSpacing(8)
    example_print_log("setDirection/setJustify/setSpacing ok")
end

--@api: LLayout:setWrap.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local layout = lurek.ui.newLayout("horizontal")
    layout:setWrap(true)
    example_print_log("setWrap ok")
    example_print_log("layout direction = " .. layout:getDirection())
    example_print_log("layout spacing = " .. layout:getSpacing())
end

--@api: LLayout:setWrap.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local layout = lurek.ui.newLayout("horizontal")
    layout:setWrap(true)
    example_print_log("setWrap ok")
    example_print_log("layout direction = " .. layout:getDirection())
    example_print_log("layout spacing = " .. layout:getSpacing())
end

--@api: LList:clearItems
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lb = lurek.ui.newList()
    lb:addItem("Apple")
    lb:addItem("Banana")
    lb:addItem("Cherry")
    local item = lb:getItem(2)
    lb:clearItems()
    example_print_log("addItem/clearItems/getItem ok, item:", item)
end

--@api: LList:clearItems.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lb = lurek.ui.newList()
    lb:addItem("Apple")
    lb:addItem("Banana")
    lb:addItem("Cherry")
    local item = lb:getItem(2)
    lb:clearItems()
    example_print_log("addItem/clearItems/getItem ok, item:", item)
end

--@api: LList:removeItem
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lb = lurek.ui.newList()
    lb:addItem("X")
    lb:addItem("Y")
    lb:addItem("Z")
    local cnt = lb:getItemCount()
    lb:setSelectedIndex(2)
    local sel = lb:getSelectedIndex()
    lb:removeItem(1)
    example_print_log("count:", cnt, "selectedIndex:", sel, "removeItem ok")
end

--@api: LList:removeItem.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lb = lurek.ui.newList()
    lb:addItem("X")
    lb:addItem("Y")
    lb:addItem("Z")
    local cnt = lb:getItemCount()
    lb:setSelectedIndex(2)
    local sel = lb:getSelectedIndex()
    lb:removeItem(1)
    example_print_log("count:", cnt, "selectedIndex:", sel, "removeItem ok")
end

--@api: LList:removeItem.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lb = lurek.ui.newList()
    lb:addItem("X")
    lb:addItem("Y")
    lb:addItem("Z")
    local cnt = lb:getItemCount()
    lb:setSelectedIndex(2)
    local sel = lb:getSelectedIndex()
    lb:removeItem(1)
    example_print_log("count:", cnt, "selectedIndex:", sel, "removeItem ok")
end

--@api: LList:setItemHeight
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lb = lurek.ui.newList()
    lb:setItemHeight(20)
    lb:addItem("Item")
    lb:setSelectedIndex(1)
    local mb = lurek.ui.newMenuBar()
    local mi = lurek.ui.newMenuItem("File")
    local idx = mb:addMenu(mi._idx)
    example_print_log("setItemHeight ok; addMenu idx:", idx)
end

--@api: LList:setSelectedIndex
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lb = lurek.ui.newList()
    lb:setItemHeight(20)
    lb:addItem("Item")
    lb:setSelectedIndex(1)
    local mb = lurek.ui.newMenuBar()
    local mi = lurek.ui.newMenuItem("File")
    local idx = mb:addMenu(mi._idx)
    example_print_log("setItemHeight ok; addMenu idx:", idx)
end

--@api: LList:setSelectedIndex.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lb = lurek.ui.newList()
    lb:setItemHeight(20)
    lb:addItem("Item")
    lb:setSelectedIndex(1)
    local mb = lurek.ui.newMenuBar()
    local mi = lurek.ui.newMenuItem("File")
    local idx = mb:addMenu(mi._idx)
    example_print_log("setItemHeight ok; addMenu idx:", idx)
end

--@api: LMenuBar:removeMenu.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mb = lurek.ui.newMenuBar()
    local mi1 = lurek.ui.newMenuItem("Edit")
    local mi2 = lurek.ui.newMenuItem("View")
    mb:addMenu(mi1._idx)
    mb:addMenu(mi2._idx)
    local cnt = mb:getMenuCount()
    local menus = mb:getMenus()
    mb:removeMenu(1)
    example_print_log("menuCount:", cnt, "getMenus ok; removeMenu ok")
end

--@api: LMenuBar:removeMenu.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mb = lurek.ui.newMenuBar()
    local mi1 = lurek.ui.newMenuItem("Edit")
    local mi2 = lurek.ui.newMenuItem("View")
    mb:addMenu(mi1._idx)
    mb:addMenu(mi2._idx)
    local cnt = mb:getMenuCount()
    local menus = mb:getMenus()
    mb:removeMenu(1)
    example_print_log("menuCount:", cnt, "getMenus ok; removeMenu ok")
end

--@api: LMenuBar:removeMenu.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mb = lurek.ui.newMenuBar()
    local mi1 = lurek.ui.newMenuItem("Edit")
    local mi2 = lurek.ui.newMenuItem("View")
    mb:addMenu(mi1._idx)
    mb:addMenu(mi2._idx)
    local cnt = mb:getMenuCount()
    local menus = mb:getMenus()
    mb:removeMenu(1)
    example_print_log("menuCount:", cnt, "getMenus ok; removeMenu ok")
end

--@api: LMenuItem:getShortcut.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mi = lurek.ui.newMenuItem("Tools")
    local sub1 = lurek.ui.newMenuItem("Options")
    mi:addSubItem(sub1._idx)
    local subs = mi:getSubItems()
    mi:setShortcut("Ctrl+T")
    local sc = mi:getShortcut()
    example_print_log("addSubItem ok; getSubItems:", type(subs), "shortcut:", sc)
end

--@api: LMenuItem:getShortcut
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mi = lurek.ui.newMenuItem("Tools")
    local sub1 = lurek.ui.newMenuItem("Options")
    mi:addSubItem(sub1._idx)
    local subs = mi:getSubItems()
    mi:setShortcut("Ctrl+T")
    local sc = mi:getShortcut()
    example_print_log("addSubItem ok; getSubItems:", type(subs), "shortcut:", sc)
end

--@api: LMenuItem:getShortcut.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mi = lurek.ui.newMenuItem("Tools")
    local sub1 = lurek.ui.newMenuItem("Options")
    mi:addSubItem(sub1._idx)
    local subs = mi:getSubItems()
    mi:setShortcut("Ctrl+T")
    local sc = mi:getShortcut()
    example_print_log("addSubItem ok; getSubItems:", type(subs), "shortcut:", sc)
end

--@api: LMenuItem:getText
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mi = lurek.ui.newMenuItem("Enable")
    local t = mi:getText()
    mi:setChecked(true)
    local checked = mi:isChecked()
    mi:setChecked(false)
    example_print_log("getText:", t, "isChecked:", mi:isChecked(), "setChecked ok")
end

--@api: LMenuItem:setChecked.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mi = lurek.ui.newMenuItem("Enable")
    local t = mi:getText()
    mi:setChecked(true)
    local checked = mi:isChecked()
    mi:setChecked(false)
    example_print_log("getText:", t, "isChecked:", mi:isChecked(), "setChecked ok")
end

--@api: LMenuItem:setChecked.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mi = lurek.ui.newMenuItem("Enable")
    local t = mi:getText()
    mi:setChecked(true)
    local checked = mi:isChecked()
    mi:setChecked(false)
    example_print_log("getText:", t, "isChecked:", mi:isChecked(), "setChecked ok")
end

--@api: LMenuItem:setOnClick.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mi = lurek.ui.newMenuItem("Old")
    mi:setOnClick(function(idx) example_print_log("menu clicked", idx) end)
    mi:setShortcut("Alt+F4")
    mi:setText("New Name")
    example_print_log("setOnClick/setShortcut/setText ok")
end

--@api: LMenuItem:setShortcut
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mi = lurek.ui.newMenuItem("Old")
    mi:setOnClick(function(idx) example_print_log("menu clicked", idx) end)
    mi:setShortcut("Alt+F4")
    mi:setText("New Name")
    example_print_log("setOnClick/setShortcut/setText ok")
end

--@api: LMenuItem:setOnClick.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mi = lurek.ui.newMenuItem("Old")
    mi:setOnClick(function(idx) example_print_log("menu clicked", idx) end)
    mi:setShortcut("Alt+F4")
    mi:setText("New Name")
    example_print_log("setOnClick/setShortcut/setText ok")
end

--@api: LNinePatch:getSlices.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    local slices = np:getSlices()
    example_print_log("imgDims:", w, h, "insets:", l, t, r, b, "slices:", type(slices))
end

--@api: LNinePatch:getSlices.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    local slices = np:getSlices()
    example_print_log("imgDims:", w, h, "insets:", l, t, r, b, "slices:", type(slices))
end

--@api: LNinePatch:getSlices.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    local slices = np:getSlices()
    example_print_log("imgDims:", w, h, "insets:", l, t, r, b, "slices:", type(slices))
end

--@api: LNinePatch:getInsets.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(32, 32)
    np:setInsets(4, 4, 4, 4)
    local l, t, r, b = np:getInsets()
    local panel = lurek.ui.newPanel()
    panel:setTitle("My Panel")
    local title = panel:getTitle()
    example_print_log("setInsets ok; panel title:", title)
end

--@api: LNinePatch:getInsets.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(32, 32)
    np:setInsets(4, 4, 4, 4)
    local l, t, r, b = np:getInsets()
    local panel = lurek.ui.newPanel()
    panel:setTitle("My Panel")
    local title = panel:getTitle()
    example_print_log("setInsets ok; panel title:", title)
end

--@api: LPanel:getTitle
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(32, 32)
    np:setInsets(4, 4, 4, 4)
    local l, t, r, b = np:getInsets()
    local panel = lurek.ui.newPanel()
    panel:setTitle("My Panel")
    local title = panel:getTitle()
    example_print_log("setInsets ok; panel title:", title)
end

--@api: LPanel:setScrollable
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local panel = lurek.ui.newPanel()
    panel:setScrollable(true)
    panel:setTitle("Data")
    example_print_log("panel scrollable ok")
    example_print_log("panel children = " .. panel:getChildCount())
end

--@api: LPanel:setTitle
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local panel = lurek.ui.newPanel()
    panel:setScrollable(true)
    panel:setTitle("Data")
    example_print_log("panel scrollable ok")
    example_print_log("panel children = " .. panel:getChildCount())
end

--@api: LProgressBar:getProgress.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pb = lurek.ui.newProgressBar(0, 100)
    local mn = pb:getMin()
    local mx = pb:getMax()
    pb:setValue(75)
    local prog = pb:getProgress()
    example_print_log("min:", mn, "max:", mx, "progress:", prog)
end

--@api: LProgressBar:getProgress.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pb = lurek.ui.newProgressBar(0, 100)
    local mn = pb:getMin()
    local mx = pb:getMax()
    pb:setValue(75)
    local prog = pb:getProgress()
    example_print_log("min:", mn, "max:", mx, "progress:", prog)
end

--@api: LProgressBar:getProgress.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pb = lurek.ui.newProgressBar(0, 100)
    local mn = pb:getMin()
    local mx = pb:getMax()
    pb:setValue(75)
    local prog = pb:getProgress()
    example_print_log("min:", mn, "max:", mx, "progress:", prog)
end

--@api: LProgressBar:setRange.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pb = lurek.ui.newProgressBar(0, 200)
    pb:setValue(100)
    local v = pb:getValue()
    pb:setRange(10, 90)
    pb:setValue(50)
    example_print_log("getValue:", v, "setRange ok, setValue ok")
end

--@api: LProgressBar:setRange.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pb = lurek.ui.newProgressBar(0, 200)
    pb:setValue(100)
    local v = pb:getValue()
    pb:setRange(10, 90)
    pb:setValue(50)
    example_print_log("getValue:", v, "setRange ok, setValue ok")
end

--@api: LProgressBar:setRange.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pb = lurek.ui.newProgressBar(0, 200)
    pb:setValue(100)
    local v = pb:getValue()
    pb:setRange(10, 90)
    pb:setValue(50)
    example_print_log("getValue:", v, "setRange ok, setValue ok")
end

--@api: LRadioButton:isSelected.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rb = lurek.ui.newRadioButton("Option A", "group1")
    local grp = rb:getGroup()
    local t = rb:getText()
    local sel = rb:isSelected()
    example_print_log("group:", grp, "text:", t, "isSelected:", sel)
end

--@api: LRadioButton:isSelected.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rb = lurek.ui.newRadioButton("Option A", "group1")
    local grp = rb:getGroup()
    local t = rb:getText()
    local sel = rb:isSelected()
    example_print_log("group:", grp, "text:", t, "isSelected:", sel)
end

--@api: LRadioButton:isSelected.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rb = lurek.ui.newRadioButton("Option A", "group1")
    local grp = rb:getGroup()
    local t = rb:getText()
    local sel = rb:isSelected()
    example_print_log("group:", grp, "text:", t, "isSelected:", sel)
end

--@api: LRadioButton:setSelected.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rb = lurek.ui.newRadioButton("B", "g1")
    rb:setGroup("g2")
    rb:setSelected(true)
    rb:setOnChange(function(idx) example_print_log("radio changed", idx) end)
    rb:setText("New B")
    example_print_log("setGroup/setSelected/setOnChange/setText ok")
end

--@api: LRadioButton:setOnChange
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rb = lurek.ui.newRadioButton("B", "g1")
    rb:setGroup("g2")
    rb:setSelected(true)
    rb:setOnChange(function(idx) example_print_log("radio changed", idx) end)
    rb:setText("New B")
    example_print_log("setGroup/setSelected/setOnChange/setText ok")
end

--@api: LRadioButton:setSelected
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rb = lurek.ui.newRadioButton("B", "g1")
    rb:setGroup("g2")
    rb:setSelected(true)
    rb:setOnChange(function(idx) example_print_log("radio changed", idx) end)
    rb:setText("New B")
    example_print_log("setGroup/setSelected/setOnChange/setText ok")
end

--@api: LRadioButton:setText
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rb = lurek.ui.newRadioButton("original", "group_test")
    rb:setText("updated")
    example_print_log("LRadioButton setText:", rb:getText())
    example_print_log("rect x = " .. select(1, rb:getRect()))
    example_print_log("rect y = " .. select(2, rb:getRect()))
end

--@api: LScrollBar:getContentSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newScrollBar(true)
    local cs = sb:getContentSize()
    local pos = sb:getScrollPosition()
    local vs = sb:getViewSize()
    example_print_log("contentSize:", cs, "scrollPos:", pos, "viewSize:", vs)
end

--@api: LScrollBar:getScrollPosition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newScrollBar(true)
    local cs = sb:getContentSize()
    local pos = sb:getScrollPosition()
    local vs = sb:getViewSize()
    example_print_log("contentSize:", cs, "scrollPos:", pos, "viewSize:", vs)
end

--@api: LScrollBar:getViewSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newScrollBar(true)
    local cs = sb:getContentSize()
    local pos = sb:getScrollPosition()
    local vs = sb:getViewSize()
    example_print_log("contentSize:", cs, "scrollPos:", pos, "viewSize:", vs)
end

--@api: LScrollBar:isVertical
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newScrollBar(false)
    local vert = sb:isVertical()
    sb:setContentSize(500)
    sb:setOnChange(function(val) example_print_log("scroll:", val) end)
    local cs = sb:getContentSize()
    example_print_log("isVertical:", vert, "contentSize after set:", cs)
end

--@api: LScrollBar:setContentSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newScrollBar(false)
    local vert = sb:isVertical()
    sb:setContentSize(500)
    sb:setOnChange(function(val) example_print_log("scroll:", val) end)
    local cs = sb:getContentSize()
    example_print_log("isVertical:", vert, "contentSize after set:", cs)
end

--@api: LScrollBar:setOnChange
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newScrollBar(false)
    local vert = sb:isVertical()
    sb:setContentSize(500)
    sb:setOnChange(function(val) example_print_log("scroll:", val) end)
    local cs = sb:getContentSize()
    example_print_log("isVertical:", vert, "contentSize after set:", cs)
end

--@api: LScrollBar:setScrollPosition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newScrollBar(true)
    sb:setContentSize(800)
    sb:setViewSize(200)
    sb:setScrollPosition(100)
    local pos = sb:getScrollPosition()
    local sp = lurek.ui.newScrollPanel()
    local cw, ch = sp:getContentSize()
    example_print_log("scrollPos:", pos, "panel contentSize:", cw, ch)
end

--@api: LScrollBar:setViewSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newScrollBar(true)
    sb:setContentSize(800)
    sb:setViewSize(200)
    sb:setScrollPosition(100)
    local pos = sb:getScrollPosition()
    local sp = lurek.ui.newScrollPanel()
    local cw, ch = sp:getContentSize()
    example_print_log("scrollPos:", pos, "panel contentSize:", cw, ch)
end

--@api: LScrollPanel:getContentSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newScrollBar(true)
    sb:setContentSize(800)
    sb:setViewSize(200)
    sb:setScrollPosition(100)
    local pos = sb:getScrollPosition()
    local sp = lurek.ui.newScrollPanel()
    local cw, ch = sp:getContentSize()
    example_print_log("scrollPos:", pos, "panel contentSize:", cw, ch)
end

--@api: LScrollPanel:getMaxScroll
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newScrollPanel()
    local mx, my = sp:getMaxScroll()
    local px, py = sp:getScrollPosition()
    local speed = sp:getScrollSpeed()
    example_print_log("maxScroll:", mx, my, "scrollPos:", px, py, "speed:", speed)
end

--@api: LScrollPanel:getScrollPosition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newScrollPanel()
    local mx, my = sp:getMaxScroll()
    local px, py = sp:getScrollPosition()
    local speed = sp:getScrollSpeed()
    example_print_log("maxScroll:", mx, my, "scrollPos:", px, py, "speed:", speed)
end

--@api: LScrollPanel:getScrollSpeed.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newScrollPanel()
    local mx, my = sp:getMaxScroll()
    local px, py = sp:getScrollPosition()
    local speed = sp:getScrollSpeed()
    example_print_log("maxScroll:", mx, my, "scrollPos:", px, py, "speed:", speed)
end

--@api: LScrollPanel:setContentSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newScrollPanel()
    sp:setContentSize(800, 600)
    local cw, ch = sp:getContentSize()
    sp:setScrollPosition(50, 100)
    local px, py = sp:getScrollPosition()
    sp:setScrollSpeed(3.0)
    local speed = sp:getScrollSpeed()
    example_print_log("contentSize:", cw, ch, "scrollPos:", px, py, "speed:", speed)
end

--@api: LScrollPanel:setScrollPosition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newScrollPanel()
    sp:setContentSize(800, 600)
    local cw, ch = sp:getContentSize()
    sp:setScrollPosition(50, 100)
    local px, py = sp:getScrollPosition()
    sp:setScrollSpeed(3.0)
    local speed = sp:getScrollSpeed()
    example_print_log("contentSize:", cw, ch, "scrollPos:", px, py, "speed:", speed)
end

--@api: LScrollPanel:getScrollSpeed.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newScrollPanel()
    sp:setContentSize(800, 600)
    local cw, ch = sp:getContentSize()
    sp:setScrollPosition(50, 100)
    local px, py = sp:getScrollPosition()
    sp:setScrollSpeed(3.0)
    local speed = sp:getScrollSpeed()
    example_print_log("contentSize:", cw, ch, "scrollPos:", px, py, "speed:", speed)
end

--@api: LSeparator:getThickness
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sep = lurek.ui.newSeparator(true)
    local vert = sep:isVertical()
    local thick = sep:getThickness()
    sep:setThickness(4)
    local t2 = sep:getThickness()
    example_print_log("isVertical:", vert, "thickness:", thick, "â†’", t2)
end

--@api: LSeparator:isVertical
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sep = lurek.ui.newSeparator(true)
    local vert = sep:isVertical()
    local thick = sep:getThickness()
    sep:setThickness(4)
    local t2 = sep:getThickness()
    example_print_log("isVertical:", vert, "thickness:", thick, "â†’", t2)
end

--@api: LSeparator:setThickness
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sep = lurek.ui.newSeparator(true)
    local vert = sep:isVertical()
    local thick = sep:getThickness()
    sep:setThickness(4)
    local t2 = sep:getThickness()
    example_print_log("isVertical:", vert, "thickness:", thick, "â†’", t2)
end

--@api: LSeparator:setVertical
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sep = lurek.ui.newSeparator(false)
    sep:setVertical(true)
    local sl = lurek.ui.newSlider(0, 100)
    local mn = sl:getMin()
    local mx = sl:getMax()
    example_print_log("separator setVertical ok; slider min:", mn, "max:", mx)
end

--@api: LSlider:getMax
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sep = lurek.ui.newSeparator(false)
    sep:setVertical(true)
    local sl = lurek.ui.newSlider(0, 100)
    local mn = sl:getMin()
    local mx = sl:getMax()
    example_print_log("separator setVertical ok; slider min:", mn, "max:", mx)
end

--@api: LSlider:getMin
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sep = lurek.ui.newSeparator(false)
    sep:setVertical(true)
    local sl = lurek.ui.newSlider(0, 100)
    local mn = sl:getMin()
    local mx = sl:getMax()
    example_print_log("separator setVertical ok; slider min:", mn, "max:", mx)
end

--@api: LSlider:getValue
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sl = lurek.ui.newSlider(0, 50)
    sl:setRange(0, 100)
    local mx = sl:getMax()
    sl:setStep(5)
    sl:setValue(75)
    local v = sl:getValue()
    example_print_log("setRange max:", mx, "getValue:", v)
end

--@api: LSlider:getValue.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sl = lurek.ui.newSlider(0, 50)
    sl:setRange(0, 100)
    local mx = sl:getMax()
    sl:setStep(5)
    sl:setValue(75)
    local v = sl:getValue()
    example_print_log("setRange max:", mx, "getValue:", v)
end

--@api: LSlider:getValue.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sl = lurek.ui.newSlider(0, 50)
    sl:setRange(0, 100)
    local mx = sl:getMax()
    sl:setStep(5)
    sl:setValue(75)
    local v = sl:getValue()
    example_print_log("setRange max:", mx, "getValue:", v)
end

--@api: LSlider:getValue.5
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sl = lurek.ui.newSlider(0, 10)
    sl:setValue(7)
    local v = sl:getValue()
    local sb = lurek.ui.newSpinBox(0, 10)
    sb:setValue(5)
    sb:decrement()
    local sv = sb:getValue()
    example_print_log("slider value:", v, "spinbox after decrement:", sv)
end

--@api: LSlider:getValue.6
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sl = lurek.ui.newSlider(0, 10)
    sl:setValue(7)
    local v = sl:getValue()
    local sb = lurek.ui.newSpinBox(0, 10)
    sb:setValue(5)
    sb:decrement()
    local sv = sb:getValue()
    example_print_log("slider value:", v, "spinbox after decrement:", sv)
end

--@api: LSlider:getValue.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sl = lurek.ui.newSlider(0, 10)
    sl:setValue(7)
    local v = sl:getValue()
    local sb = lurek.ui.newSpinBox(0, 10)
    sb:setValue(5)
    sb:decrement()
    local sv = sb:getValue()
    example_print_log("slider value:", v, "spinbox after decrement:", sv)
end

--@api: LSpinBox:getValue.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newSpinBox(0, 100)
    sb:setValue(10)
    sb:increment()
    local v = sb:getValue()
    sb:setRange(5, 50)
    sb:setStep(2)
    local v2 = sb:getValue()
    example_print_log("after increment:", v, "after setRange/setStep:", v2)
end

--@api: LSpinBox:getValue.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newSpinBox(0, 100)
    sb:setValue(10)
    sb:increment()
    local v = sb:getValue()
    sb:setRange(5, 50)
    sb:setStep(2)
    local v2 = sb:getValue()
    example_print_log("after increment:", v, "after setRange/setStep:", v2)
end

--@api: LSpinBox:getValue.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newSpinBox(0, 100)
    sb:setValue(10)
    sb:increment()
    local v = sb:getValue()
    sb:setRange(5, 50)
    sb:setStep(2)
    local v2 = sb:getValue()
    example_print_log("after increment:", v, "after setRange/setStep:", v2)
end

--@api: LSpinBox:getValue.5
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newSpinBox(1, 100)
    sb:setValue(42)
    local v = sb:getValue()
    sb:setValue(1)
    local v2 = sb:getValue()
    sb:setValue(100)
    local v3 = sb:getValue()
    example_print_log("setValue: 42â†’", v, "1â†’", v2, "100â†’", v3)
end

--@api: LSplitPanel:getMinPanelSize.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newSplitPanel("horizontal")
    local fc = sp:getFirstChild()
    local sc = sp:getSecondChild()
    local ori = sp:getOrientation()
    local mps = sp:getMinPanelSize()
    example_print_log("firstChild:", fc, "secondChild:", sc, "orientation:", ori, "minPanel:", mps)
end

--@api: LSplitPanel:getMinPanelSize.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newSplitPanel("horizontal")
    local fc = sp:getFirstChild()
    local sc = sp:getSecondChild()
    local ori = sp:getOrientation()
    local mps = sp:getMinPanelSize()
    example_print_log("firstChild:", fc, "secondChild:", sc, "orientation:", ori, "minPanel:", mps)
end

--@api: LSplitPanel:getMinPanelSize.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newSplitPanel("horizontal")
    local fc = sp:getFirstChild()
    local sc = sp:getSecondChild()
    local ori = sp:getOrientation()
    local mps = sp:getMinPanelSize()
    example_print_log("firstChild:", fc, "secondChild:", sc, "orientation:", ori, "minPanel:", mps)
end

--@api: LSplitPanel:getSplitPosition.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newSplitPanel("vertical")
    local lbl = lurek.ui.newLabel("left")
    local btn = lurek.ui.newButton("right")
    sp:setFirstChild(lbl:getId() and 1 or 1)
    local fc = sp:getFirstChild()
    sp:setSecondChild(btn:getId() and 2 or 2)
    local pos = sp:getSplitPosition()
    example_print_log("firstChild after set:", fc, "splitPos:", pos)
end

--@api: LSplitPanel:getSplitPosition.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newSplitPanel("vertical")
    local lbl = lurek.ui.newLabel("left")
    local btn = lurek.ui.newButton("right")
    sp:setFirstChild(lbl:getId() and 1 or 1)
    local fc = sp:getFirstChild()
    sp:setSecondChild(btn:getId() and 2 or 2)
    local pos = sp:getSplitPosition()
    example_print_log("firstChild after set:", fc, "splitPos:", pos)
end

--@api: LSplitPanel:getSplitPosition.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newSplitPanel("vertical")
    local lbl = lurek.ui.newLabel("left")
    local btn = lurek.ui.newButton("right")
    sp:setFirstChild(lbl:getId() and 1 or 1)
    local fc = sp:getFirstChild()
    sp:setSecondChild(btn:getId() and 2 or 2)
    local pos = sp:getSplitPosition()
    example_print_log("firstChild after set:", fc, "splitPos:", pos)
end

--@api: LSplitPanel:setSecondChild.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newSplitPanel("horizontal")
    sp:setOrientation("vertical")
    local ori = sp:getOrientation()
    sp:setMinPanelSize(80)
    local mps = sp:getMinPanelSize()
    local lbl = lurek.ui.newLabel("panel")
    sp:setSecondChild(lbl:getId() and 1 or 1)
    example_print_log("orientation:", ori, "minPanel:", mps)
end

--@api: LSplitPanel:setSecondChild.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newSplitPanel("horizontal")
    sp:setOrientation("vertical")
    local ori = sp:getOrientation()
    sp:setMinPanelSize(80)
    local mps = sp:getMinPanelSize()
    local lbl = lurek.ui.newLabel("panel")
    sp:setSecondChild(lbl:getId() and 1 or 1)
    example_print_log("orientation:", ori, "minPanel:", mps)
end

--@api: LSplitPanel:setSecondChild.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newSplitPanel("horizontal")
    sp:setOrientation("vertical")
    local ori = sp:getOrientation()
    sp:setMinPanelSize(80)
    local mps = sp:getMinPanelSize()
    local lbl = lurek.ui.newLabel("panel")
    sp:setSecondChild(lbl:getId() and 1 or 1)
    example_print_log("orientation:", ori, "minPanel:", mps)
end

--@api: LSplitPanel:getSplitPosition.5
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newSplitPanel("horizontal")
    sp:setSplitPosition(200)
    local pos = sp:getSplitPosition()
    local sb = lurek.ui.newStatusBar()
    sb:addSection("Ready", 100)
    local cnt = sb:getSectionCount()
    example_print_log("splitPos:", pos, "statusBar sectionCount:", cnt)
end

--@api: LSplitPanel:getSplitPosition.6
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newSplitPanel("horizontal")
    sp:setSplitPosition(200)
    local pos = sp:getSplitPosition()
    local sb = lurek.ui.newStatusBar()
    sb:addSection("Ready", 100)
    local cnt = sb:getSectionCount()
    example_print_log("splitPos:", pos, "statusBar sectionCount:", cnt)
end

--@api: LSplitPanel:getSplitPosition.7
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sp = lurek.ui.newSplitPanel("horizontal")
    sp:setSplitPosition(200)
    local pos = sp:getSplitPosition()
    local sb = lurek.ui.newStatusBar()
    sb:addSection("Ready", 100)
    local cnt = sb:getSectionCount()
    example_print_log("splitPos:", pos, "statusBar sectionCount:", cnt)
end

--@api: LStatusBar:setSectionCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newStatusBar()
    sb:setSectionCount(3)
    local cnt = sb:getSectionCount()
    sb:setSectionText(1, "Line 1")
    local txt = sb:getSectionText(1)
    sb:setSectionText(2, "Col 5")
    example_print_log("sectionCount:", cnt, "section1:", txt)
end

--@api: LStatusBar:setSectionText.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newStatusBar()
    sb:setSectionCount(3)
    local cnt = sb:getSectionCount()
    sb:setSectionText(1, "Line 1")
    local txt = sb:getSectionText(1)
    sb:setSectionText(2, "Col 5")
    example_print_log("sectionCount:", cnt, "section1:", txt)
end

--@api: LStatusBar:setSectionText.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newStatusBar()
    sb:setSectionCount(3)
    local cnt = sb:getSectionCount()
    sb:setSectionText(1, "Line 1")
    local txt = sb:getSectionText(1)
    sb:setSectionText(2, "Col 5")
    example_print_log("sectionCount:", cnt, "section1:", txt)
end

--@api: LStatusBar:setSectionWidget
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newStatusBar()
    sb:setSectionCount(2)
    local lbl = lurek.ui.newLabel("status")
    sb:setSectionWidget(1, lbl)
    local sw = lurek.ui.newSwitch(false)
    local on = sw:isOn()
    sw:setOn(true)
    example_print_log("sectionWidget set ok; switch isOn:", sw:isOn())
end

--@api: LStatusBar:setSectionWidget.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newStatusBar()
    sb:setSectionCount(2)
    local lbl = lurek.ui.newLabel("status")
    sb:setSectionWidget(1, lbl)
    local sw = lurek.ui.newSwitch(false)
    local on = sw:isOn()
    sw:setOn(true)
    example_print_log("sectionWidget set ok; switch isOn:", sw:isOn())
end

--@api: LStatusBar:setSectionWidget.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sb = lurek.ui.newStatusBar()
    sb:setSectionCount(2)
    local lbl = lurek.ui.newLabel("status")
    sb:setSectionWidget(1, lbl)
    local sw = lurek.ui.newSwitch(false)
    local on = sw:isOn()
    sw:setOn(true)
    example_print_log("sectionWidget set ok; switch isOn:", sw:isOn())
end

--@api: LSwitch:isOn.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sw = lurek.ui.newSwitch(false)
    sw:toggle()
    local on = sw:isOn()
    local tb = lurek.ui.newTabBar()
    tb:addTab("Tab 1")
    tb:addTab("Tab 2")
    local active = tb:getActiveTab()
    example_print_log("switch after toggle:", on, "activeTab:", active)
end

--@api: LSwitch:isOn.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sw = lurek.ui.newSwitch(false)
    sw:toggle()
    local on = sw:isOn()
    local tb = lurek.ui.newTabBar()
    tb:addTab("Tab 1")
    tb:addTab("Tab 2")
    local active = tb:getActiveTab()
    example_print_log("switch after toggle:", on, "activeTab:", active)
end

--@api: LSwitch:isOn.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sw = lurek.ui.newSwitch(false)
    sw:toggle()
    local on = sw:isOn()
    local tb = lurek.ui.newTabBar()
    tb:addTab("Tab 1")
    tb:addTab("Tab 2")
    local active = tb:getActiveTab()
    example_print_log("switch after toggle:", on, "activeTab:", active)
end

--@api: LTabBar:getTabCount.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tb = lurek.ui.newTabBar()
    tb:addTab("Alpha")
    tb:addTab("Beta")
    tb:addTab("Gamma")
    local cnt = tb:getTabCount()
    local label = tb:getTab(1)
    tb:removeTab(3)
    local cnt2 = tb:getTabCount()
    example_print_log("tabCount:", cnt, "tab1:", label, "after remove:", cnt2)
end

--@api: LTabBar:getTabCount.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tb = lurek.ui.newTabBar()
    tb:addTab("Alpha")
    tb:addTab("Beta")
    tb:addTab("Gamma")
    local cnt = tb:getTabCount()
    local label = tb:getTab(1)
    tb:removeTab(3)
    local cnt2 = tb:getTabCount()
    example_print_log("tabCount:", cnt, "tab1:", label, "after remove:", cnt2)
end

--@api: LTabBar:getTabCount.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tb = lurek.ui.newTabBar()
    tb:addTab("Alpha")
    tb:addTab("Beta")
    tb:addTab("Gamma")
    local cnt = tb:getTabCount()
    local label = tb:getTab(1)
    tb:removeTab(3)
    local cnt2 = tb:getTabCount()
    example_print_log("tabCount:", cnt, "tab1:", label, "after remove:", cnt2)
end

--@api: LTabBar:getActiveTab.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tb = lurek.ui.newTabBar()
    tb:addTab("First")
    tb:addTab("Second")
    tb:setActiveTab(2)
    local active = tb:getActiveTab()
    tb:setActiveTab(1)
    local a2 = tb:getActiveTab()
    example_print_log("setActiveTab to 2:", active, "then to 1:", a2)
end

--@api: LTextInput:setText
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ti = lurek.ui.newTextInput()
    ti:setText("hello")
    local txt = ti:getText()
    ti:setPlaceholder("type here")
    local ph = ti:getPlaceholder()
    local cur = ti:getCursorPosition()
    example_print_log("text:", txt, "placeholder:", ph, "cursor:", cur)
end

--@api: LTextInput:getCursorPosition.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ti = lurek.ui.newTextInput()
    ti:setText("hello")
    local txt = ti:getText()
    ti:setPlaceholder("type here")
    local ph = ti:getPlaceholder()
    local cur = ti:getCursorPosition()
    example_print_log("text:", txt, "placeholder:", ph, "cursor:", cur)
end

--@api: LTextInput:getText
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ti = lurek.ui.newTextInput()
    ti:setText("hello")
    local txt = ti:getText()
    ti:setPlaceholder("type here")
    local ph = ti:getPlaceholder()
    local cur = ti:getCursorPosition()
    example_print_log("text:", txt, "placeholder:", ph, "cursor:", cur)
end

--@api: LTextInput:isFocused
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ti = lurek.ui.newTextInput()
    ti:setPlaceholder("Search...")
    local ph = ti:getPlaceholder()
    ti:setMaxLength(50)
    local focused = ti:isFocused()
    example_print_log("placeholder:", ph, "isFocused:", focused)
end

--@api: LTextInput:isFocused.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ti = lurek.ui.newTextInput()
    ti:setPlaceholder("Search...")
    local ph = ti:getPlaceholder()
    ti:setMaxLength(50)
    local focused = ti:isFocused()
    example_print_log("placeholder:", ph, "isFocused:", focused)
end

--@api: LTextInput:isFocused.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ti = lurek.ui.newTextInput()
    ti:setPlaceholder("Search...")
    local ph = ti:getPlaceholder()
    ti:setMaxLength(50)
    local focused = ti:isFocused()
    example_print_log("placeholder:", ph, "isFocused:", focused)
end

--@api: LTextInput:getText.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ti = lurek.ui.newTextInput()
    ti:setText("sample input")
    local txt = ti:getText()
    local th = lurek.ui.newTheme()
    th:setStyle("button", "normal", {bg_color = {0.2, 0.3, 0.8}})
    local t = th:type()
    example_print_log("text:", txt, "theme type:", t)
end

--@api: LTheme:setStyle
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ti = lurek.ui.newTextInput()
    ti:setText("sample input")
    local txt = ti:getText()
    local th = lurek.ui.newTheme()
    th:setStyle("button", "normal", {bg_color = {0.2, 0.3, 0.8}})
    local t = th:type()
    example_print_log("text:", txt, "theme type:", t)
end

--@api: LTheme:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ti = lurek.ui.newTextInput()
    ti:setText("sample input")
    local txt = ti:getText()
    local th = lurek.ui.newTheme()
    th:setStyle("button", "normal", {bg_color = {0.2, 0.3, 0.8}})
    local t = th:type()
    example_print_log("text:", txt, "theme type:", t)
end

--@api: LTheme:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local th = lurek.ui.newTheme()
    local ok = th:typeOf("LTheme")
    local toast = lurek.ui.newToast("Level up!", 3.0)
    local dur = toast:getDuration()
    local msg = toast:getMessage()
    example_print_log("theme typeOf:", ok, "duration:", dur, "message:", msg)
end

--@api: LTheme:typeOf.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local th = lurek.ui.newTheme()
    local ok = th:typeOf("LTheme")
    local toast = lurek.ui.newToast("Level up!", 3.0)
    local dur = toast:getDuration()
    local msg = toast:getMessage()
    example_print_log("theme typeOf:", ok, "duration:", dur, "message:", msg)
end

--@api: LTheme:typeOf.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local th = lurek.ui.newTheme()
    local ok = th:typeOf("LTheme")
    local toast = lurek.ui.newToast("Level up!", 3.0)
    local dur = toast:getDuration()
    local msg = toast:getMessage()
    example_print_log("theme typeOf:", ok, "duration:", dur, "message:", msg)
end

--@api: LToast:getDuration.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local toast = lurek.ui.newToast("Achievement unlocked", 2.0)
    local prog = toast:getProgress()
    local exp = toast:isExpired()
    toast:setDuration(5.0)
    local dur = toast:getDuration()
    example_print_log("progress:", prog, "isExpired:", exp, "duration:", dur)
end

--@api: LToast:getDuration.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local toast = lurek.ui.newToast("Achievement unlocked", 2.0)
    local prog = toast:getProgress()
    local exp = toast:isExpired()
    toast:setDuration(5.0)
    local dur = toast:getDuration()
    example_print_log("progress:", prog, "isExpired:", exp, "duration:", dur)
end

--@api: LToast:getDuration.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local toast = lurek.ui.newToast("Achievement unlocked", 2.0)
    local prog = toast:getProgress()
    local exp = toast:isExpired()
    toast:setDuration(5.0)
    local dur = toast:getDuration()
    example_print_log("progress:", prog, "isExpired:", exp, "duration:", dur)
end

--@api: LToast:getMessage.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local toast = lurek.ui.newToast("old message", 2.0)
    toast:setMessage("new message")
    local msg = toast:getMessage()
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("save", "Save file")
    tb:addSeparator()
    tb:addButton("open", "Open file")
    example_print_log("toast:", msg, "toolbar buttons added ok")
end

--@api: LToast:getMessage.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local toast = lurek.ui.newToast("old message", 2.0)
    toast:setMessage("new message")
    local msg = toast:getMessage()
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("save", "Save file")
    tb:addSeparator()
    tb:addButton("open", "Open file")
    example_print_log("toast:", msg, "toolbar buttons added ok")
end

--@api: LToast:getMessage.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local toast = lurek.ui.newToast("old message", 2.0)
    toast:setMessage("new message")
    local msg = toast:getMessage()
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("save", "Save file")
    tb:addSeparator()
    tb:addButton("open", "Open file")
    example_print_log("toast:", msg, "toolbar buttons added ok")
end

--@api: LToolbar:addSpacer
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("cut", "Cut")
    tb:addSpacer(10)
    tb:addButton("paste", "Paste")
    local ori = tb:getOrientation()
    local btn = tb:getButton("cut")
    example_print_log("orientation:", ori, "button:", btn)
end

--@api: LToolbar:getButton.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("cut", "Cut")
    tb:addSpacer(10)
    tb:addButton("paste", "Paste")
    local ori = tb:getOrientation()
    local btn = tb:getButton("cut")
    example_print_log("orientation:", ori, "button:", btn)
end

--@api: LToolbar:getButton.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("cut", "Cut")
    tb:addSpacer(10)
    tb:addButton("paste", "Paste")
    local ori = tb:getOrientation()
    local btn = tb:getButton("cut")
    example_print_log("orientation:", ori, "button:", btn)
end

--@api: LToolbar:setButtonEnabled.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("bold", "Bold")
    tb:setButtonToggled("bold", true)
    local tog = tb:isButtonToggled("bold")
    tb:setButtonEnabled("bold", false)
    example_print_log("bold toggled:", tog)
end

--@api: LToolbar:setButtonEnabled.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("bold", "Bold")
    tb:setButtonToggled("bold", true)
    local tog = tb:isButtonToggled("bold")
    tb:setButtonEnabled("bold", false)
    example_print_log("bold toggled:", tog)
end

--@api: LToolbar:setButtonEnabled.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("bold", "Bold")
    tb:setButtonToggled("bold", true)
    local tog = tb:isButtonToggled("bold")
    tb:setButtonEnabled("bold", false)
    example_print_log("bold toggled:", tog)
end

--@api: LToolbar:getOrientation.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tb = lurek.ui.newToolbar("horizontal")
    tb:setOrientation("vertical")
    local ori = tb:getOrientation()
    local tp = lurek.ui.newTooltipPanel("Hover help")
    local delay = tp:getDelay()
    local target = tp:getTarget()
    example_print_log("orientation:", ori, "delay:", delay, "target:", target)
end

--@api: LToolbar:getOrientation.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tb = lurek.ui.newToolbar("horizontal")
    tb:setOrientation("vertical")
    local ori = tb:getOrientation()
    local tp = lurek.ui.newTooltipPanel("Hover help")
    local delay = tp:getDelay()
    local target = tp:getTarget()
    example_print_log("orientation:", ori, "delay:", delay, "target:", target)
end

--@api: LTooltipPanel:getTarget
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tb = lurek.ui.newToolbar("horizontal")
    tb:setOrientation("vertical")
    local ori = tb:getOrientation()
    local tp = lurek.ui.newTooltipPanel("Hover help")
    local delay = tp:getDelay()
    local target = tp:getTarget()
    example_print_log("orientation:", ori, "delay:", delay, "target:", target)
end

--@api: LTooltipPanel:setTarget.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tp = lurek.ui.newTooltipPanel("initial tip")
    local txt = tp:getText()
    tp:setDelay(0.5)
    local d = tp:getDelay()
    local btn = lurek.ui.newButton("hover me")
    tp:setTarget(btn:getId() and 1 or 1)
    example_print_log("text:", txt, "delay:", d)
end

--@api: LTooltipPanel:setTarget.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tp = lurek.ui.newTooltipPanel("initial tip")
    local txt = tp:getText()
    tp:setDelay(0.5)
    local d = tp:getDelay()
    local btn = lurek.ui.newButton("hover me")
    tp:setTarget(btn:getId() and 1 or 1)
    example_print_log("text:", txt, "delay:", d)
end

--@api: LTooltipPanel:setTarget
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tp = lurek.ui.newTooltipPanel("initial tip")
    local txt = tp:getText()
    tp:setDelay(0.5)
    local d = tp:getDelay()
    local btn = lurek.ui.newButton("hover me")
    tp:setTarget(btn:getId() and 1 or 1)
    example_print_log("text:", txt, "delay:", d)
end

--@api: LTooltipPanel:setDelay.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tp = lurek.ui.newTooltipPanel("old tip")
    tp:setText("new tooltip text")
    local txt = tp:getText()
    tp:setText("another tip")
    local txt2 = tp:getText()
    tp:setDelay(1.0)
    example_print_log("setText:", txt, "â†’", txt2)
end

--@api: LTreeView:getNodeCount.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local n1 = tv:addNode("Root", nil)
    local n2 = tv:addNode("Child", n1)
    tv:collapseAll()
    tv:clearNodes()
    local cnt = tv:getNodeCount()
    example_print_log("addNode/collapseAll/clearNodes ok; count after clear:", cnt)
end

--@api: LTreeView:getNodeCount.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local n1 = tv:addNode("Root", nil)
    local n2 = tv:addNode("Child", n1)
    tv:collapseAll()
    tv:clearNodes()
    local cnt = tv:getNodeCount()
    example_print_log("addNode/collapseAll/clearNodes ok; count after clear:", cnt)
end

--@api: LTreeView:getNodeCount.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local n1 = tv:addNode("Root", nil)
    local n2 = tv:addNode("Child", n1)
    tv:collapseAll()
    tv:clearNodes()
    local cnt = tv:getNodeCount()
    example_print_log("addNode/collapseAll/clearNodes ok; count after clear:", cnt)
end

--@api: LTreeView:getNodeCount.5
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local n1 = tv:addNode("Animals", nil)
    local n2 = tv:addNode("Mammals", n1)
    tv:addNode("Dog", n2)
    tv:expandAll()
    tv:collapseNode(n1)
    tv:expandNode(n1)
    local cnt = tv:getNodeCount()
    example_print_log("expandAll/collapseNode/expandNode ok; count:", cnt)
end

--@api: LTreeView:getNodeCount.6
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local n1 = tv:addNode("Animals", nil)
    local n2 = tv:addNode("Mammals", n1)
    tv:addNode("Dog", n2)
    tv:expandAll()
    tv:collapseNode(n1)
    tv:expandNode(n1)
    local cnt = tv:getNodeCount()
    example_print_log("expandAll/collapseNode/expandNode ok; count:", cnt)
end

--@api: LTreeView:getNodeCount.7
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local n1 = tv:addNode("Animals", nil)
    local n2 = tv:addNode("Mammals", n1)
    tv:addNode("Dog", n2)
    tv:expandAll()
    tv:collapseNode(n1)
    tv:expandNode(n1)
    local cnt = tv:getNodeCount()
    example_print_log("expandAll/collapseNode/expandNode ok; count:", cnt)
end

--@api: LTreeView:getNodeDepth.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    local c1 = tv:addNode("Child1", r)
    tv:addNode("Child2", r)
    local children = tv:getChildNodes(r)
    local cnt = tv:getNodeCount()
    local depth = tv:getNodeDepth(c1)
    example_print_log("children:", children, "count:", cnt, "depth:", depth)
end

--@api: LTreeView:getNodeDepth.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    local c1 = tv:addNode("Child1", r)
    tv:addNode("Child2", r)
    local children = tv:getChildNodes(r)
    local cnt = tv:getNodeCount()
    local depth = tv:getNodeDepth(c1)
    example_print_log("children:", children, "count:", cnt, "depth:", depth)
end

--@api: LTreeView:getNodeDepth.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    local c1 = tv:addNode("Child1", r)
    tv:addNode("Child2", r)
    local children = tv:getChildNodes(r)
    local cnt = tv:getNodeCount()
    local depth = tv:getNodeDepth(c1)
    example_print_log("children:", children, "count:", cnt, "depth:", depth)
end

--@api: LTreeView:getSelectedNode.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    local c = tv:addNode("Child", r)
    local txt = tv:getNodeText(c)
    local parent = tv:getParentNode(c)
    local sel = tv:getSelectedNode()
    example_print_log("text:", txt, "parent:", parent, "selected:", sel)
end

--@api: LTreeView:getSelectedNode.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    local c = tv:addNode("Child", r)
    local txt = tv:getNodeText(c)
    local parent = tv:getParentNode(c)
    local sel = tv:getSelectedNode()
    example_print_log("text:", txt, "parent:", parent, "selected:", sel)
end

--@api: LTreeView:getSelectedNode.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    local c = tv:addNode("Child", r)
    local txt = tv:getNodeText(c)
    local parent = tv:getParentNode(c)
    local sel = tv:getSelectedNode()
    example_print_log("text:", txt, "parent:", parent, "selected:", sel)
end

--@api: LTreeView:getNodeCount.8
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    local c = tv:addNode("Child", r)
    tv:expandNode(r)
    local exp = tv:isExpanded(r)
    local ne = tv:isNodeExpanded(r)
    tv:removeNode(c)
    local cnt = tv:getNodeCount()
    example_print_log("isExpanded:", exp, "isNodeExpanded:", ne, "count after remove:", cnt)
end

--@api: LTreeView:getNodeCount.9
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    local c = tv:addNode("Child", r)
    tv:expandNode(r)
    local exp = tv:isExpanded(r)
    local ne = tv:isNodeExpanded(r)
    tv:removeNode(c)
    local cnt = tv:getNodeCount()
    example_print_log("isExpanded:", exp, "isNodeExpanded:", ne, "count after remove:", cnt)
end

--@api: LTreeView:getNodeCount.10
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    local c = tv:addNode("Child", r)
    tv:expandNode(r)
    local exp = tv:isExpanded(r)
    local ne = tv:isNodeExpanded(r)
    tv:removeNode(c)
    local cnt = tv:getNodeCount()
    example_print_log("isExpanded:", exp, "isNodeExpanded:", ne, "count after remove:", cnt)
end

--@api: LTreeView:setNodeIcon.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("old text", nil)
    tv:setNodeText(r, "new text")
    local txt = tv:getNodeText(r)
    tv:setSelectedNode(r)
    local sel = tv:getSelectedNode()
    tv:setNodeIcon(r, "folder")
    example_print_log("setText:", txt, "selected:", sel)
end

--@api: LTreeView:setNodeIcon.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("old text", nil)
    tv:setNodeText(r, "new text")
    local txt = tv:getNodeText(r)
    tv:setSelectedNode(r)
    local sel = tv:getSelectedNode()
    tv:setNodeIcon(r, "folder")
    example_print_log("setText:", txt, "selected:", sel)
end

--@api: LTreeView:setNodeIcon.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("old text", nil)
    tv:setNodeText(r, "new text")
    local txt = tv:getNodeText(r)
    tv:setSelectedNode(r)
    local sel = tv:getSelectedNode()
    tv:setNodeIcon(r, "folder")
    example_print_log("setText:", txt, "selected:", sel)
end

--@api: LTreeView:toggleNode.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tv = lurek.ui.newTreeView()
    local r = tv:addNode("Root", nil)
    tv:addNode("Child", r)
    tv:expandNode(r)
    local was = tv:isExpanded(r)
    tv:toggleNode(r)
    local now = tv:isExpanded(r)
    tv:toggleNode(r)
    local back = tv:isExpanded(r)
    example_print_log("expanded:", was, "after toggle:", now, "after toggle back:", back)
end

--@api: lurek.ui.newCustomWidget
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local child = lurek.ui.newLabel("label")
    w:addChild(child)
    w:animateAlpha(0.5, 0.3, false)
    w:animatePosition(10, 20, 0.5)
    local cnt = w:getChildCount()
    example_print_log("addChild/animateAlpha/animatePosition ok; childCount:", cnt)
end

--@api: LCustomWidget:addChild
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local child = lurek.ui.newLabel("label")
    w:addChild(child)
    w:animateAlpha(0.5, 0.3, false)
    w:animatePosition(10, 20, 0.5)
    local cnt = w:getChildCount()
    example_print_log("addChild/animateAlpha/animatePosition ok; childCount:", cnt)
end

--@api: LCustomWidget:getChildCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local child = lurek.ui.newLabel("label")
    w:addChild(child)
    w:animateAlpha(0.5, 0.3, false)
    w:animatePosition(10, 20, 0.5)
    local cnt = w:getChildCount()
    example_print_log("addChild/animateAlpha/animatePosition ok; childCount:", cnt)
end

--@api: LUiWidget:attachToEntity
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=80, height=40})
    w:attachToEntity(1)
    w:animateAlpha(0.0, 1.0, false)
    local animating = w:isAnimating()
    w:cancelAnimations()
    w:bind("click")
    w:detachFromEntity()
    example_print_log("attachToEntity/bind/cancelAnimations ok")
end

--@api: LUiWidget:bind
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=80, height=40})
    w:attachToEntity(1)
    w:animateAlpha(0.0, 1.0, false)
    local animating = w:isAnimating()
    w:cancelAnimations()
    w:bind("click")
    w:detachFromEntity()
    example_print_log("attachToEntity/bind/cancelAnimations ok")
end

--@api: LUiWidget:cancelAnimations
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=80, height=40})
    w:attachToEntity(1)
    w:animateAlpha(0.0, 1.0, false)
    local animating = w:isAnimating()
    w:cancelAnimations()
    w:bind("click")
    w:detachFromEntity()
    example_print_log("attachToEntity/bind/cancelAnimations ok")
end

--@api: LCustomWidget:setAnchor
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setAnchor(0, 0, 1, 0)
    w:clearAnchor()
    w:setPosition(10, 10)
    local hit = w:containsPoint(15, 15)
    w:attachToEntity(2)
    w:detachFromEntity()
    example_print_log("clearAnchor/containsPoint:", hit, "detachFromEntity ok")
end

--@api: LCustomWidget:detachFromEntity
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setAnchor(0, 0, 1, 0)
    w:clearAnchor()
    w:setPosition(10, 10)
    local hit = w:containsPoint(15, 15)
    w:attachToEntity(2)
    w:detachFromEntity()
    example_print_log("clearAnchor/containsPoint:", hit, "detachFromEntity ok")
end

--@api: LUiWidget:detachFromEntity
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setAnchor(0, 0, 1, 0)
    w:clearAnchor()
    w:setPosition(10, 10)
    local hit = w:containsPoint(15, 15)
    w:attachToEntity(2)
    w:detachFromEntity()
    example_print_log("clearAnchor/containsPoint:", hit, "detachFromEntity ok")
end

--@api: LCustomWidget:setId
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setId("my-panel")
    w:fadeOut()
    w:fadeIn()
    local child = lurek.ui.newLabel("inner")
    child:setId("inner-lbl")
    w:addChild(child)
    local found = w:findById("inner-lbl")
    example_print_log("fadeIn/fadeOut ok; findById:", found)
end

--@api: LCustomWidget:findById
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setId("my-panel")
    w:fadeOut()
    w:fadeIn()
    local child = lurek.ui.newLabel("inner")
    child:setId("inner-lbl")
    w:addChild(child)
    local found = w:findById("inner-lbl")
    example_print_log("fadeIn/fadeOut ok; findById:", found)
end

--@api: LCustomWidget:findById.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setId("my-panel")
    w:fadeOut()
    w:fadeIn()
    local child = lurek.ui.newLabel("inner")
    child:setId("inner-lbl")
    w:addChild(child)
    local found = w:findById("inner-lbl")
    example_print_log("fadeIn/fadeOut ok; findById:", found)
end

--@api: LCustomWidget:setAlpha
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setAlpha(0.75)
    local alpha = w:getAlpha()
    w:addChild(lurek.ui.newLabel("c1"))
    w:addChild(lurek.ui.newLabel("c2"))
    local cnt = w:getChildCount()
    local children = w:getChildren()
    example_print_log("alpha:", alpha, "childCount:", cnt, "children:", children)
end

--@api: LCustomWidget:getChildren
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setAlpha(0.75)
    local alpha = w:getAlpha()
    w:addChild(lurek.ui.newLabel("c1"))
    w:addChild(lurek.ui.newLabel("c2"))
    local cnt = w:getChildCount()
    local children = w:getChildren()
    example_print_log("alpha:", alpha, "childCount:", cnt, "children:", children)
end

--@api: LCustomWidget:getChildren.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setAlpha(0.75)
    local alpha = w:getAlpha()
    w:addChild(lurek.ui.newLabel("c1"))
    w:addChild(lurek.ui.newLabel("c2"))
    local cnt = w:getChildCount()
    local children = w:getChildren()
    example_print_log("alpha:", alpha, "childCount:", cnt, "children:", children)
end

--@api: LCustomWidget:setFlexGrow
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setFlexGrow(2)
    local grow = w:getFlexGrow()
    w:setFlexShrink(1)
    local shrink = w:getFlexShrink()
    w:setId("widget-abc")
    local id = w:getId()
    example_print_log("flexGrow:", grow, "flexShrink:", shrink, "id:", id)
end

--@api: LCustomWidget:getId
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setFlexGrow(2)
    local grow = w:getFlexGrow()
    w:setFlexShrink(1)
    local shrink = w:getFlexShrink()
    w:setId("widget-abc")
    local id = w:getId()
    example_print_log("flexGrow:", grow, "flexShrink:", shrink, "id:", id)
end

--@api: LCustomWidget:getId.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setFlexGrow(2)
    local grow = w:getFlexGrow()
    w:setFlexShrink(1)
    local shrink = w:getFlexShrink()
    w:setId("widget-abc")
    local id = w:getId()
    example_print_log("flexGrow:", grow, "flexShrink:", shrink, "id:", id)
end

--@api: LCustomWidget:setMargin
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setMargin(4, 8, 4, 8)
    local mt, mr, mb, ml = w:getMargin()
    w:setMaxSize(400, 300)
    local mxw, mxh = w:getMaxSize()
    w:setMinSize(50, 25)
    local mnw, mnh = w:getMinSize()
    example_print_log("margin:", mt, mr, mb, ml, "max:", mxw, mxh, "min:", mnw, mnh)
end

--@api: LCustomWidget:getMinSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setMargin(4, 8, 4, 8)
    local mt, mr, mb, ml = w:getMargin()
    w:setMaxSize(400, 300)
    local mxw, mxh = w:getMaxSize()
    w:setMinSize(50, 25)
    local mnw, mnh = w:getMinSize()
    example_print_log("margin:", mt, mr, mb, ml, "max:", mxw, mxh, "min:", mnw, mnh)
end

--@api: LCustomWidget:getMinSize.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setMargin(4, 8, 4, 8)
    local mt, mr, mb, ml = w:getMargin()
    w:setMaxSize(400, 300)
    local mxw, mxh = w:getMaxSize()
    w:setMinSize(50, 25)
    local mnw, mnh = w:getMinSize()
    example_print_log("margin:", mt, mr, mb, ml, "max:", mxw, mxh, "min:", mnw, mnh)
end

--@api: LCustomWidget:setPadding
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setPadding(5, 5, 5, 5)
    local pt, pr, pb, pl = w:getPadding()
    w:setPosition(30, 40)
    local px, py = w:getPosition()
    local rx, ry, rw, rh = w:getRect()
    example_print_log("padding:", pt, "position:", px, py, "rect:", rx, ry, rw, rh)
end

--@api: LCustomWidget:getRect
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setPadding(5, 5, 5, 5)
    local pt, pr, pb, pl = w:getPadding()
    w:setPosition(30, 40)
    local px, py = w:getPosition()
    local rx, ry, rw, rh = w:getRect()
    example_print_log("padding:", pt, "position:", px, py, "rect:", rx, ry, rw, rh)
end

--@api: LCustomWidget:getRect.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setPadding(5, 5, 5, 5)
    local pt, pr, pb, pl = w:getPadding()
    w:setPosition(30, 40)
    local px, py = w:getPosition()
    local rx, ry, rw, rh = w:getRect()
    example_print_log("padding:", pt, "position:", px, py, "rect:", rx, ry, rw, rh)
end

--@api: LCustomWidget:setSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=120, height=60})
    w:setSize(150, 80)
    local sw, sh = w:getSize()
    local state = w:getState()
    w:setTooltip("hover tip")
    local tip = w:getTooltip()
    example_print_log("size:", sw, sh, "state:", state, "tooltip:", tip)
end

--@api: LCustomWidget:getTooltip
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=120, height=60})
    w:setSize(150, 80)
    local sw, sh = w:getSize()
    local state = w:getState()
    w:setTooltip("hover tip")
    local tip = w:getTooltip()
    example_print_log("size:", sw, sh, "state:", state, "tooltip:", tip)
end

--@api: LCustomWidget:getTooltip.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=120, height=60})
    w:setSize(150, 80)
    local sw, sh = w:getSize()
    local state = w:getState()
    w:setTooltip("hover tip")
    local tip = w:getTooltip()
    example_print_log("size:", sw, sh, "state:", state, "tooltip:", tip)
end

--@api: LCustomWidget:setZOrder
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setZOrder(5)
    local z = w:getZOrder()
    local animating = w:isAnimating()
    local enabled = w:isEnabled()
    w:setEnabled(false)
    example_print_log("zOrder:", z, "isAnimating:", animating, "isEnabled:", enabled)
end

--@api: LUiWidget:isAnimating
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setZOrder(5)
    local z = w:getZOrder()
    local animating = w:isAnimating()
    local enabled = w:isEnabled()
    w:setEnabled(false)
    example_print_log("zOrder:", z, "isAnimating:", animating, "isEnabled:", enabled)
end

--@api: LCustomWidget:setEnabled
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setZOrder(5)
    local z = w:getZOrder()
    local animating = w:isAnimating()
    local enabled = w:isEnabled()
    w:setEnabled(false)
    example_print_log("zOrder:", z, "isAnimating:", animating, "isEnabled:", enabled)
end

--@api: LCustomWidget:isVisible
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local vis = w:isVisible()
    w:setVisible(false)
    local child = lurek.ui.newLabel("removable")
    w:addChild(child)
    w:removeChild(child)
    w:setAlpha(0.9)
    local alpha = w:getAlpha()
    example_print_log("isVisible:", vis, "removeChild ok, alpha:", alpha)
end

--@api: LCustomWidget:getAlpha
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local vis = w:isVisible()
    w:setVisible(false)
    local child = lurek.ui.newLabel("removable")
    w:addChild(child)
    w:removeChild(child)
    w:setAlpha(0.9)
    local alpha = w:getAlpha()
    example_print_log("isVisible:", vis, "removeChild ok, alpha:", alpha)
end

--@api: LCustomWidget:getAlpha.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local vis = w:isVisible()
    w:setVisible(false)
    local child = lurek.ui.newLabel("removable")
    w:addChild(child)
    w:removeChild(child)
    w:setAlpha(0.9)
    local alpha = w:getAlpha()
    example_print_log("isVisible:", vis, "removeChild ok, alpha:", alpha)
end

--@api: LCustomWidget:isEnabled
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setAnchor(0, 0, 1, 1)
    w:clearAnchor()
    w:setAnchorCenter(0.5, 0.5)
    w:setEnabled(true)
    local enabled = w:isEnabled()
    w:setEnabled(false)
    example_print_log("setAnchor/setAnchorCenter/setEnabled ok")
end

--@api: LCustomWidget:setEnabled.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setAnchor(0, 0, 1, 1)
    w:clearAnchor()
    w:setAnchorCenter(0.5, 0.5)
    w:setEnabled(true)
    local enabled = w:isEnabled()
    w:setEnabled(false)
    example_print_log("setAnchor/setAnchorCenter/setEnabled ok")
end

--@api: LCustomWidget:setEnabled.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setAnchor(0, 0, 1, 1)
    w:clearAnchor()
    w:setAnchorCenter(0.5, 0.5)
    w:setEnabled(true)
    local enabled = w:isEnabled()
    w:setEnabled(false)
    example_print_log("setAnchor/setAnchorCenter/setEnabled ok")
end

--@api: LCustomWidget:getId.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setFlexGrow(3)
    local fg = w:getFlexGrow()
    w:setFlexShrink(0)
    local fs = w:getFlexShrink()
    w:setId("flex-widget")
    local id = w:getId()
    example_print_log("flexGrow:", fg, "flexShrink:", fs, "id:", id)
end

--@api: LCustomWidget:getId.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setFlexGrow(3)
    local fg = w:getFlexGrow()
    w:setFlexShrink(0)
    local fs = w:getFlexShrink()
    w:setId("flex-widget")
    local id = w:getId()
    example_print_log("flexGrow:", fg, "flexShrink:", fs, "id:", id)
end

--@api: LCustomWidget:getId.5
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setFlexGrow(3)
    local fg = w:getFlexGrow()
    w:setFlexShrink(0)
    local fs = w:getFlexShrink()
    w:setId("flex-widget")
    local id = w:getId()
    example_print_log("flexGrow:", fg, "flexShrink:", fs, "id:", id)
end

--@api: LCustomWidget:getMinSize.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setMargin(2, 4, 2, 4)
    local mt = w:getMargin()
    w:setMaxSize(500, 400)
    local mxw = w:getMaxSize()
    w:setMinSize(60, 30)
    local mnw = w:getMinSize()
    example_print_log("margin set ok; maxSize:", mxw, "minSize:", mnw)
end

--@api: LCustomWidget:getMinSize.4
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setMargin(2, 4, 2, 4)
    local mt = w:getMargin()
    w:setMaxSize(500, 400)
    local mxw = w:getMaxSize()
    w:setMinSize(60, 30)
    local mnw = w:getMinSize()
    example_print_log("margin set ok; maxSize:", mxw, "minSize:", mnw)
end

--@api: LCustomWidget:getMinSize.5
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setMargin(2, 4, 2, 4)
    local mt = w:getMargin()
    w:setMaxSize(500, 400)
    local mxw = w:getMaxSize()
    w:setMinSize(60, 30)
    local mnw = w:getMinSize()
    example_print_log("margin set ok; maxSize:", mxw, "minSize:", mnw)
end

--@api: LUiWidget:setOnChange
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setOnChange(function() example_print_log("changed") end)
    w:setOnClick(function() example_print_log("clicked") end)
    w:setOnDraw(function() example_print_log("drawing") end)
    local id = w:getId()
    local vis = w:isVisible()
    example_print_log("setOnChange/setOnClick/setOnDraw ok; id:", id, "vis:", vis)
end

--@api: LUiWidget:setOnClick
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setOnChange(function() example_print_log("changed") end)
    w:setOnClick(function() example_print_log("clicked") end)
    w:setOnDraw(function() example_print_log("drawing") end)
    local id = w:getId()
    local vis = w:isVisible()
    example_print_log("setOnChange/setOnClick/setOnDraw ok; id:", id, "vis:", vis)
end

--@api: LUiWidget:setOnDraw
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setOnChange(function() example_print_log("changed") end)
    w:setOnClick(function() example_print_log("clicked") end)
    w:setOnDraw(function() example_print_log("drawing") end)
    local id = w:getId()
    local vis = w:isVisible()
    example_print_log("setOnChange/setOnClick/setOnDraw ok; id:", id, "vis:", vis)
end

--@api: LCustomWidget:getSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setPadding(6, 6, 6, 6)
    local pt = w:getPadding()
    w:setPosition(50, 100)
    local px, py = w:getPosition()
    w:setSize(200, 100)
    local sw, sh = w:getSize()
    example_print_log("padding:", pt, "position:", px, py, "size:", sw, sh)
end

--@api: LCustomWidget:getSize.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setPadding(6, 6, 6, 6)
    local pt = w:getPadding()
    w:setPosition(50, 100)
    local px, py = w:getPosition()
    w:setSize(200, 100)
    local sw, sh = w:getSize()
    example_print_log("padding:", pt, "position:", px, py, "size:", sw, sh)
end

--@api: LCustomWidget:getSize.3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setPadding(6, 6, 6, 6)
    local pt = w:getPadding()
    w:setPosition(50, 100)
    local px, py = w:getPosition()
    w:setSize(200, 100)
    local sw, sh = w:getSize()
    example_print_log("padding:", pt, "position:", px, py, "size:", sw, sh)
end

--@api: LCustomWidget:setTooltip
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setTooltip("my tooltip")
    local tip = w:getTooltip()
    w:setVisible(false)
    w:setVisible(true)
    w:setZOrder(10)
    local z = w:getZOrder()
    example_print_log("tooltip:", tip, "zOrder:", z)
end

--@api: LCustomWidget:getZOrder
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setTooltip("my tooltip")
    local tip = w:getTooltip()
    w:setVisible(false)
    w:setVisible(true)
    w:setZOrder(10)
    local z = w:getZOrder()
    example_print_log("tooltip:", tip, "zOrder:", z)
end

--@api: LCustomWidget:getZOrder.2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setTooltip("my tooltip")
    local tip = w:getTooltip()
    w:setVisible(false)
    w:setVisible(true)
    w:setZOrder(10)
    local z = w:getZOrder()
    example_print_log("tooltip:", tip, "zOrder:", z)
end

--@api: LCustomWidget:slideIn
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:slideIn(0, -50)
    w:slideOut(0, 50)
    local t = w:type()
    local ok = w:typeOf("LUiWidget")
    w:unbind()
    example_print_log("slideIn/slideOut ok; type:", t, "typeOf:", ok)
end

--@api: LCustomWidget:unbind
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:slideIn(0, -50)
    w:slideOut(0, 50)
    local t = w:type()
    local ok = w:typeOf("LUiWidget")
    w:unbind()
    example_print_log("slideIn/slideOut ok; type:", t, "typeOf:", ok)
end

--@api: LUiWidget:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:slideIn(0, -50)
    w:slideOut(0, 50)
    local t = w:type()
    local ok = w:typeOf("LUiWidget")
    w:unbind()
    example_print_log("slideIn/slideOut ok; type:", t, "typeOf:", ok)
end

--@api: LUiWidget:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=80, height=40})
    w:bind("click")
    w:unbind()
    local ok1 = w:typeOf("LUiWidget")
    local ok2 = w:typeOf("LButton")
    local t = w:type()
    example_print_log("typeOf LUiWidget:", ok1, "typeOf LButton:", ok2, "type:", t)
end

--@api: LUiWidget:unbind
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=80, height=40})
    w:bind("click")
    w:unbind()
    local ok1 = w:typeOf("LUiWidget")
    local ok2 = w:typeOf("LButton")
    local t = w:type()
    example_print_log("typeOf LUiWidget:", ok1, "typeOf LButton:", ok2, "type:", t)
end

--@api: lurek.ui.draw
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=80, height=40})
    lurek.ui.beginDrag(w)
    lurek.ui.endDrag()
    lurek.ui.clearFocus()
    lurek.ui.draw()
    example_print_log("beginDrag/endDrag/clearFocus/draw ok")
end

--@api: lurek.ui.drawToImage
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.ui.drawToImage(320, 240)
    local w = lurek.ui.newCustomWidget({width=80, height=40})
    lurek.ui.beginDrag(w)
    lurek.ui.dropOn(w)
    lurek.ui.endDrag()
    example_print_log("drawToImage ok; dropOn/endDrag ok")
end

--@api: lurek.ui.endDrag
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.ui.drawToImage(320, 240)
    local w = lurek.ui.newCustomWidget({width=80, height=40})
    lurek.ui.beginDrag(w)
    lurek.ui.dropOn(w)
    lurek.ui.endDrag()
    example_print_log("drawToImage ok; dropOn/endDrag ok")
end

--@api: lurek.ui.flushCache
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.ui.flushCache()
    lurek.ui.focusPrev()
    local drag = lurek.ui.getActiveDrag()
    local focus = lurek.ui.getFocus()
    lurek.ui.clearFocus()
    example_print_log("flushCache/focusPrev ok; activeDrag:", drag, "focus:", focus)
end

--@api: lurek.ui.getToastCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.ui.clearFocus()
    local foc = lurek.ui.getFocus()
    local theme = lurek.ui.getTheme()
    local toasts = lurek.ui.getToastCount()
    local widgets = lurek.ui.getWidgetCount()
    example_print_log("focus:", foc, "theme:", theme, "toastCount:", toasts, "widgetCount:", widgets)
end

--@api: lurek.ui.getWidgetCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cnt = lurek.ui.getWidgetCount()
    lurek.ui.keypressed("escape")
    local layout = lurek.ui.loadLayoutFile("content/examples/assets/layouts/sample_main_menu.toml")
    lurek.ui.textinput("a")
    example_print_log("widgetCount:", cnt, "loadLayoutFile ok; textinput ok")
end

--@api: lurek.ui.keypressed
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cnt = lurek.ui.getWidgetCount()
    lurek.ui.keypressed("escape")
    local layout = lurek.ui.loadLayoutFile("content/examples/assets/layouts/sample_main_menu.toml")
    lurek.ui.textinput("a")
    example_print_log("widgetCount:", cnt, "loadLayoutFile ok; textinput ok")
end

--@api: lurek.ui.loadLayoutFile
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cnt = lurek.ui.getWidgetCount()
    lurek.ui.keypressed("escape")
    local layout = lurek.ui.loadLayoutFile("content/examples/assets/layouts/sample_main_menu.toml")
    lurek.ui.textinput("a")
    example_print_log("widgetCount:", cnt, "loadLayoutFile ok; textinput ok")
end

--@api: lurek.ui.loadLayoutGameFile
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ok, result = pcall(function()
        return lurek.ui.loadLayoutGameFile("content/examples/assets/layouts/sample_main_menu.toml")
    end)
    example_print_log("loadLayoutGameFile ok:", ok, "result:", tostring(result))
    example_print_log("result type:", type(result))
    example_print_log("loaded layout:", tostring(ok and result ~= nil))
end

--@api: lurek.ui.mousemoved
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local slider = lurek.ui.newSlider(0, 100)
    slider:setPosition(20, 520)
    slider:setSize(200, 20)
    slider:setZOrder(2200)
    lurek.ui.mousepressed(40, 530, 1)
    lurek.ui.mousemoved(180, 530)
    lurek.ui.mousereleased(180, 530, 1)
    lurek.ui.update(0)
    example_print_log("slider value after drag:", slider:getValue())
end

--@api: lurek.ui.mousepressed
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("active tab after click:", tabs:getActiveTab())
end

--@api: lurek.ui.mousereleased
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("combo selected:", combo:getSelectedItem())
end

--@api: LCustomWidget:UNKNOWN
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local layout = lurek.ui.newLayout("row")
    local sb = lurek.ui.newScrollBar(true)
    example_print_log("newCustomWidget:", w, "newLayout:", layout, "newScrollBar:", sb)
    example_print_log("rect x = " .. select(1, w:getRect()))
end

--@api: lurek.ui.newScrollBar
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local layout = lurek.ui.newLayout("row")
    local sb = lurek.ui.newScrollBar(true)
    example_print_log("newCustomWidget:", w, "newLayout:", layout, "newScrollBar:", sb)
    example_print_log("rect x = " .. select(1, w:getRect()))
end

--@api: lurek.ui.parseWidgetState
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local th = lurek.ui.newTheme()
    local state = lurek.ui.parseWidgetState("normal")
    local result = lurek.ui.renderToImage(320, 240, "save/ui_render.png")
    example_print_log("newTheme ok; parseWidgetState:", state, "renderToImage:", result)
    lurek.ui.setTheme(th)
    example_print_log("theme applied = " .. tostring(lurek.ui.getTheme() ~= nil))
end

--@api: lurek.ui.renderToImage
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local th = lurek.ui.newTheme()
    local state = lurek.ui.parseWidgetState("normal")
    local result = lurek.ui.renderToImage(320, 240, "save/ui_render.png")
    example_print_log("newTheme ok; parseWidgetState:", state, "renderToImage:", result)
    lurek.ui.setTheme(th)
    example_print_log("theme applied = " .. tostring(lurek.ui.getTheme() ~= nil))
end

--@api: lurek.ui.setDefaultTheme
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local th = lurek.ui.newTheme()
    lurek.ui.setTheme(th)
    lurek.ui.setDefaultTheme()
    lurek.ui.setViewport(1280, 720)
    local cnt = lurek.ui.getWidgetCount()
    example_print_log("setTheme/setDefaultTheme/setViewport ok; widgets:", cnt)
end

--@api: lurek.ui.setViewport
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local th = lurek.ui.newTheme()
    lurek.ui.setTheme(th)
    lurek.ui.setDefaultTheme()
    lurek.ui.setViewport(1280, 720)
    local cnt = lurek.ui.getWidgetCount()
    example_print_log("setTheme/setDefaultTheme/setViewport ok; widgets:", cnt)
end

--@api: lurek.ui.textinput
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.ui.textinput("hello")
    lurek.ui.textinput(" world")
    lurek.ui.update_bindings({dt=0.016})
    lurek.ui.wheelmoved(0, 1)
    lurek.ui.wheelmoved(1, 0)
    example_print_log("textinput/update_bindings/wheelmoved ok")
end

--@api: lurek.ui.update_bindings
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.ui.textinput("hello")
    lurek.ui.textinput(" world")
    lurek.ui.update_bindings({dt=0.016})
    lurek.ui.wheelmoved(0, 1)
    lurek.ui.wheelmoved(1, 0)
    example_print_log("textinput/update_bindings/wheelmoved ok")
end

--@api: lurek.ui.wheelmoved
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local panel = lurek.ui.newScrollPanel()
    panel:setPosition(300, 520)
    panel:setSize(120, 70)
    panel:setZOrder(2500)
    panel:setContentSize(120, 300)
    lurek.ui.mousemoved(310, 530)
    lurek.ui.wheelmoved(0, -3)
    local _, sy = panel:getScrollPosition()
    example_print_log("hover scroll y:", sy)
end

--@api: LTextInput:setPosition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local input = lurek.ui.newTextInput()
    input:setPosition(20, 650)
    input:setSize(160, 28)
    input:setZOrder(2600)
    lurek.ui.setFocus(input)
    lurek.ui.textinput("42")
    lurek.ui.keypressed("left")
    lurek.ui.textinput(".")
    lurek.ui.update(0)
    example_print_log("focused text:", input:isFocused(), input:getText())
end

--@api: LToolbar:setPosition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local toolbar = lurek.ui.newToolbar("horizontal")
    toolbar:setPosition(220, 650)
    toolbar:setSize(120, 32)
    toolbar:setZOrder(2610)
    toolbar:addButton("save", "Save")
    toolbar:setOnChange(function() example_print_log("toolbar changed") end)
    lurek.ui.mousepressed(230, 666, 1)
    lurek.ui.mousereleased(230, 666, 1)
    lurek.ui.update(0)
    example_print_log("save toggled:", toolbar:isButtonToggled("save"))
end

--@api: LRadioButton:setPosition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cash = lurek.ui.newRadioButton("Cash", "payment_kind")
    cash:setPosition(370, 650)
    cash:setSize(100, 24)
    cash:setZOrder(2620)
    local card = lurek.ui.newRadioButton("Card", "payment_kind")
    card:setPosition(370, 678)
    card:setSize(100, 24)
    card:setZOrder(2630)
    card:setOnChange(function() example_print_log("card selected") end)
    lurek.ui.mousepressed(380, 688, 1)
    lurek.ui.mousereleased(380, 688, 1)
    lurek.ui.update(0)
    example_print_log("cash/card:", cash:isSelected(), card:isSelected())
end

--@api: LScrollBar:setPosition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bar = lurek.ui.newScrollBar(true)
    bar:setPosition(500, 650)
    bar:setSize(20, 100)
    bar:setZOrder(2640)
    bar:setContentSize(400)
    bar:setViewSize(100)
    bar:setOnChange(function() example_print_log("scrollbar changed") end)
    lurek.ui.mousepressed(510, 720, 1)
    lurek.ui.mousemoved(510, 740)
    lurek.ui.mousereleased(510, 740, 1)
    lurek.ui.update(0)
    example_print_log("scrollbar position:", bar:getScrollPosition())
end

--@api: LWindow:setPosition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local win = lurek.ui.newWindow("Inspector")
    win:setPosition(550, 650)
    win:setSize(150, 90)
    win:setZOrder(2650)
    win:setOnClose(function() example_print_log("window closed") end)
    lurek.ui.mousepressed(690, 660, 1)
    lurek.ui.mousereleased(690, 660, 1)
    lurek.ui.update(0)
    example_print_log("window visible:", win:isVisible())
end

--@api: LDialog:setPosition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dialog = lurek.ui.newDialog("Confirm")
    dialog:setCenterOnOpen(false)
    dialog:setPosition(720, 650)
    dialog:setSize(180, 100)
    dialog:setZOrder(2660)
    dialog:addButton("Close")
    dialog:setOnClose(function() example_print_log("dialog closed") end)
    dialog:open()
    lurek.ui.mousepressed(830, 724, 1)
    lurek.ui.mousereleased(830, 724, 1)
end

--@api: LUiWidget:setMouseFilter
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    -- Sets the mouse filter mode on a panel. "ignore" passes events to underlying widgets,
    -- useful for decorative overlays or transparent layout containers.
    local panel = lurek.ui.newPanel()
    panel:setMouseFilter("ignore")
    example_print_log("mouse filter set to ignore")
    example_print_log("panel children = " .. panel:getChildCount())
    example_print_log("panel width = " .. select(3, panel:getRect()))
end

--@api: LUiWidget:getMouseFilter
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    -- Retrieves the current mouse filter behavior of a widget.
    local panel = lurek.ui.newPanel()
    panel:setMouseFilter("pass")
    local filter = panel:getMouseFilter()
    example_print_log("mouse filter: " .. filter)
    example_print_log("panel children = " .. panel:getChildCount())
end

--@api: LUiWidget:setStyleClass
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    -- Assigns a custom style class to a widget. If defined in the active theme,
    -- the button will use "primary" colors and metrics instead of default ones.
    local btn = lurek.ui.newButton("Submit")
    btn:setStyleClass("primary")
    example_print_log("style class set to primary")
    example_print_log("button text = " .. btn:getText())
    example_print_log("button width = " .. select(3, btn:getRect()))
end

--@api: LUiWidget:getStyleClass
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    -- Retrieves the currently assigned style class of a widget, or an empty string if none.
    local btn = lurek.ui.newButton("Cancel")
    btn:setStyleClass("danger")
    local class = btn:getStyleClass()
    example_print_log("style class: " .. class)
    example_print_log("button text = " .. btn:getText())
end

--@api: LUiWidget:setAlign
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    -- Configures the flexbox cross-axis alignment. "center" aligns children
    -- vertically in a horizontal layout.
    local layout = lurek.ui.newLayout("horizontal")
    layout:setAlign("center")
    example_print_log("align set to center")
    example_print_log("layout direction = " .. layout:getDirection())
    example_print_log("layout spacing = " .. layout:getSpacing())
end

--@api: LUiWidget:getAlign
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    -- Gets the current flexbox alignment property.
    local layout = lurek.ui.newLayout("horizontal")
    layout:setAlign("stretch")
    local align = layout:getAlign()
    example_print_log("align: " .. align)
    example_print_log("layout direction = " .. layout:getDirection())
end

--@api: LUiWidget:setJustify
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    -- Configures the flexbox main-axis justification. "space-between" spreads
    -- children to edges.
    local layout = lurek.ui.newLayout("horizontal")
    layout:setJustify("space-between")
    example_print_log("justify set to space-between")
    example_print_log("layout direction = " .. layout:getDirection())
    example_print_log("layout spacing = " .. layout:getSpacing())
end

--@api: LUiWidget:getJustify
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    -- Gets the current flexbox justification property.
    local layout = lurek.ui.newLayout("horizontal")
    layout:setJustify("end")
    local justify = layout:getJustify()
    example_print_log("justify: " .. justify)
    example_print_log("layout direction = " .. layout:getDirection())
end

--@api: LTable:clearRows
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    -- Removes all rows from a GUI table without deleting its column definitions.
    local tbl = lurek.ui.newTable()
    tbl:addColumn("Name")
    tbl:addRow({"Alice"})
    tbl:clearRows()
    example_print_log("cleared rows")
end

--@api: LTable:setRows
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    -- Bulk-replaces all current rows with the provided list of row data.
    local tbl = lurek.ui.newTable()
    tbl:addColumn("Score")
    tbl:setRows({{"100"}, {"200"}})
    example_print_log("set rows")
    example_print_log("rect x = " .. select(1, tbl:getRect()))
end

--@api: lurek.ui.setFont
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    -- Example for setFont
    local widget = lurek.ui.newButton("Test Widget")
    widget:setText("Using setFont")
    local w, h = widget:getSize()
    lurek.log.info("Invoked setFont on widget size " .. w .. "x" .. h)
    if w > 0 then widget:setVisible(true) end
end

--@api: lurek.ui.getFont
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    -- Example for getFont
    local widget = lurek.ui.newButton("Test Widget")
    widget:setText("Using getFont")
    local w, h = widget:getSize()
    lurek.log.info("Invoked getFont on widget size " .. w .. "x" .. h)
    if w > 0 then widget:setVisible(true) end
end

--@api: lurek.ui.clearFont
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    -- Example for clearFont
    local widget = lurek.ui.newButton("Test Widget")
    widget:setText("Using clearFont")
    local w, h = widget:getSize()
    lurek.log.info("Invoked clearFont on widget size " .. w .. "x" .. h)
    if w > 0 then widget:setVisible(true) end
end

--@api: lurek.ui.getWidgetFont
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    -- Example for getWidgetFont
    local widget = lurek.ui.newButton("Test Widget")
    widget:setText("Using getWidgetFont")
    local w, h = widget:getSize()
    lurek.log.info("Invoked getWidgetFont on widget size " .. w .. "x" .. h)
    if w > 0 then widget:setVisible(true) end
end

--@api: lurek.ui.updateBindings
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    -- Example for updateBindings
    local widget = lurek.ui.newButton("Test Widget")
    widget:setText("Using updateBindings")
    local w, h = widget:getSize()
    lurek.log.info("Invoked updateBindings on widget size " .. w .. "x" .. h)
    if w > 0 then widget:setVisible(true) end
end

--@api: LUiWidget:setFont
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    -- Example for setFont
    local widget = lurek.ui.newButton("Test Widget")
    widget:setText("Using setFont")
    local w, h = widget:getSize()
    lurek.log.info("Invoked setFont on widget size " .. w .. "x" .. h)
    if w > 0 then widget:setVisible(true) end
end

--@api: LUiWidget:clearFont
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    -- Example for clearFont
    local widget = lurek.ui.newButton("Test Widget")
    widget:setText("Using clearFont")
    local w, h = widget:getSize()
    lurek.log.info("Invoked clearFont on widget size " .. w .. "x" .. h)
    if w > 0 then widget:setVisible(true) end
end

--@api: LUiWidget:setBindKey
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    -- Example for setBindKey
    local widget = lurek.ui.newButton("Test Widget")
    widget:setText("Using setBindKey")
    local w, h = widget:getSize()
    lurek.log.info("Invoked setBindKey on widget size " .. w .. "x" .. h)
    if w > 0 then widget:setVisible(true) end
end

--@api: LUiWidget:setTextWrap
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lbl = lurek.ui.newLabel("This is a long text that can wrap")
    lbl:setTextWrap(true)
    example_print_log("label text = " .. lbl:getText())
    example_print_log("label width = " .. select(3, lbl:getRect()))
    example_print_log("label visible = " .. tostring(lbl:isVisible()))
end

--@api: LUiWidget:setTextEllipsis
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lbl = lurek.ui.newLabel("This is a very long one-line text")
    lbl:setTextEllipsis(true)
    example_print_log("label text = " .. lbl:getText())
    example_print_log("label width = " .. select(3, lbl:getRect()))
    example_print_log("label visible = " .. tostring(lbl:isVisible()))
end

--@api: LUiWidget:setTextVAlign
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lbl = lurek.ui.newLabel("Centered")
    lbl:setTextVAlign("middle")
    example_print_log("label text = " .. lbl:getText())
    example_print_log("label width = " .. select(3, lbl:getRect()))
    example_print_log("label visible = " .. tostring(lbl:isVisible()))
end

--@api: LUiWidget:setTextAlign
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lbl = lurek.ui.newLabel("Right aligned")
    lbl:setTextAlign("right")
    example_print_log("label text = " .. lbl:getText())
    example_print_log("label width = " .. select(3, lbl:getRect()))
    example_print_log("label visible = " .. tostring(lbl:isVisible()))
end

--@api: LUiWidget:getTextAlign
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lbl = lurek.ui.newLabel("Aligned")
    lbl:setTextAlign("center")
    example_print_log("textAlign=" .. lbl:getTextAlign())
    example_print_log("label text = " .. lbl:getText())
    example_print_log("label width = " .. select(3, lbl:getRect()))
end

--@api: LUiWidget:setFocusable
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn = lurek.ui.newButton("Focusable")
    btn:setFocusable(true)
    example_print_log("button text = " .. btn:getText())
    example_print_log("button width = " .. select(3, btn:getRect()))
    example_print_log("button enabled = " .. tostring(btn:isEnabled()))
end

--@api: LUiWidget:setTabIndex
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn = lurek.ui.newButton("Tab")
    btn:setTabIndex(10)
    example_print_log("button text = " .. btn:getText())
    example_print_log("button width = " .. select(3, btn:getRect()))
    example_print_log("button enabled = " .. tostring(btn:isEnabled()))
end

--@api: LUiWidget:setFocusGroup
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn = lurek.ui.newButton("Group")
    btn:setFocusGroup("menu")
    example_print_log("button text = " .. btn:getText())
    example_print_log("button width = " .. select(3, btn:getRect()))
    example_print_log("button enabled = " .. tostring(btn:isEnabled()))
end

--@api: LUiWidget:setFocusNeighbor
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.ui.newButton("A")
    local b = lurek.ui.newButton("B")
    a:setFocusNeighbor("right", b._idx)
    example_print_log("button text = " .. a:getText())
    example_print_log("button width = " .. select(3, a:getRect()))
end

--@api: LUiWidget:setRole
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn = lurek.ui.newButton("Save")
    btn:setRole("button")
    example_print_log("button text = " .. btn:getText())
    example_print_log("button width = " .. select(3, btn:getRect()))
    example_print_log("button enabled = " .. tostring(btn:isEnabled()))
end

--@api: LUiWidget:setAriaName
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn = lurek.ui.newButton("Save")
    btn:setAriaName("Save game")
    example_print_log("button text = " .. btn:getText())
    example_print_log("button width = " .. select(3, btn:getRect()))
    example_print_log("button enabled = " .. tostring(btn:isEnabled()))
end

--@api: LUiWidget:getRole
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn = lurek.ui.newButton("Save")
    btn:setRole("button")
    example_print_log("button role = " .. btn:getRole())
    example_print_log("button text = " .. btn:getText())
    example_print_log("button visible = " .. tostring(btn:isVisible()))
end

--@api: LUiWidget:getAriaName
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn = lurek.ui.newButton("Save")
    btn:setAriaName("Save game")
    example_print_log("aria name = " .. btn:getAriaName())
    example_print_log("button text = " .. btn:getText())
    example_print_log("button visible = " .. tostring(btn:isVisible()))
end

--@api: LUiWidget:setLabelFor
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local label = lurek.ui.newLabel("Name")
    local input = lurek.ui.newTextInput()
    label:setLabelFor(input._idx)
    example_print_log("label target = " .. tostring(label:getLabelFor()))
    example_print_log("input idx = " .. tostring(input._idx))
end

--@api: LUiWidget:getLabelFor
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local label = lurek.ui.newLabel("Email")
    local input = lurek.ui.newTextInput()
    label:setLabelFor(input._idx)
    example_print_log("label for = " .. tostring(label:getLabelFor()))
    example_print_log("label text = " .. label:getText())
end

--@api: lurek.ui.getStyleToken
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local spacing = lurek.ui.getStyleToken("spacing_md")
    local color = lurek.ui.getStyleToken("color_primary")
    example_print_log("spacing_md=" .. tostring(spacing))
    if type(color) == "table" then
        example_print_log("color_primary a=" .. tostring(color.a))
    end
end

--@api: lurek.ui.focusNeighbor
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.ui.newButton("A")
    local b = lurek.ui.newButton("B")
    a:setFocusNeighbor("right", b._idx)
    lurek.ui.setFocus(a)
    local moved = lurek.ui.focusNeighbor("right")
    example_print_log("focus moved=" .. tostring(moved))
end

--@api: lurek.ui.clear
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local root = lurek.ui.getRoot()
    if root then
        lurek.ui.clear()
    end
    example_print_log("root widgets = " .. lurek.ui.getWidgetCount())
end

--@api: lurek.ui.getAccessibilityTree
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.ui.clear()
    local label = lurek.ui.newLabel("Name")
    local input = lurek.ui.newTextInput()
    label:setLabelFor(input._idx)
    local nodes = lurek.ui.getAccessibilityTree()
    example_print_log("a11y nodes = " .. tostring(#nodes))
    example_print_log("first node role = " .. tostring(nodes[1] and nodes[1].role))
    example_print_log("first node name = " .. tostring(nodes[1] and nodes[1].name))
end

--@api: lurek.ui.validateUx
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.ui.clear()
    lurek.ui.setViewport(100, 100)
    local dialog = lurek.ui.newDialog("Confirm")
    dialog:open()
    dialog:setModal(true)
    dialog:setCloseable(false)
    dialog:setPosition(-20, 10)
    dialog:setSize(120, 90)
    local diagnostics = lurek.ui.validateUx()
    example_print_log("validateUx count = " .. tostring(#diagnostics))
    example_print_log("validateUx first = " .. tostring(diagnostics[1] and diagnostics[1].message))
end

--@api: lurek.ui.focusDirection
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.ui.newButton("A")
    local b = lurek.ui.newButton("B")
    a:setFocusNeighbor("right", b._idx)
    lurek.ui.setFocus(a)
    local moved = lurek.ui.focusDirection(1.0, 0.0)
    example_print_log("lurek.ui.focusDirection moved=" .. tostring(moved))
end

--@api: lurek.ui.updateResolution
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.ui.setBaseResolution(1280, 720)
    local before = lurek.ui.getScaleFactor()
    lurek.ui.updateResolution(1920, 1080)
    local after = lurek.ui.getScaleFactor()
    example_print_log("scale before=" .. before)
    example_print_log("scale after=" .. after)
end

--@api: lurek.ui.setBaseResolution
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.ui.setBaseResolution(1280, 720)
    local base_scale = lurek.ui.getScaleFactor()
    lurek.ui.updateResolution(1920, 1080)
    local viewport_scale = lurek.ui.getScaleFactor()
    example_print_log("base scale=" .. base_scale)
    example_print_log("viewport scale=" .. viewport_scale)
end

--@api: lurek.ui.getScaleFactor
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.ui.setBaseResolution(1280, 720)
    local base_scale = lurek.ui.getScaleFactor()
    lurek.ui.updateResolution(1920, 1080)
    local viewport_scale = lurek.ui.getScaleFactor()
    example_print_log("base scale=" .. base_scale)
    example_print_log("viewport scale=" .. viewport_scale)
end

--@api: lurek.ui.visibleRange
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local list = lurek.ui.newList()
    local x, y = lurek.ui.visibleRange(list, 50, 20.0)
    example_print_log("lurek.ui.visibleRange x=" .. x .. " y=" .. y)
    example_print_log("list count = " .. list:getItemCount())
    example_print_log("list width = " .. select(3, list:getRect()))
end

--@api: lurek.ui.animateScale
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local btn = lurek.ui.newButton("Scale")
    lurek.ui.animateScale(btn._idx, 1.0, 1.0, 1.2, 1.2, 0.3)
    example_print_log("lurek.ui.animateScale ok")
    example_print_log("button text = " .. btn:getText())
    example_print_log("button width = " .. select(3, btn:getRect()))
end

--@api: lurek.ui.animateRotation
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.ui.newPanel()
    lurek.ui.animateRotation(img._idx, 0, 360, 1.0)
    example_print_log("lurek.ui.animateRotation ok")
    example_print_log("panel children = " .. img:getChildCount())
    example_print_log("panel width = " .. select(3, img:getRect()))
end

--@api: lurek.ui.animateColor
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lbl = lurek.ui.newLabel("Hello")
    lurek.ui.animateColor(lbl._idx, {r=1,g=1,b=1,a=1}, {r=1,g=0.5,b=0,a=1}, 0.5)
    example_print_log("lurek.ui.animateColor ok")
    example_print_log("label text = " .. lbl:getText())
    example_print_log("label width = " .. select(3, lbl:getRect()))
end

--@api: lurek.ui.getIconNames
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local names = lurek.ui.getIconNames()
    local first = names[1] or ""
    local last = names[#names] or ""
    example_print_log("icon count = " .. #names)
    example_print_log("first icon = " .. first)
    example_print_log("last icon = " .. last)
end

--@api: lurek.ui.hasIcon
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local can_save = lurek.ui.hasIcon("save")
    local can_map = lurek.ui.hasIcon("map")
    local missing = lurek.ui.hasIcon("missing-icon")
    example_print_log("save icon = " .. tostring(can_save))
    example_print_log("map icon = " .. tostring(can_map))
    example_print_log("missing icon = " .. tostring(missing))
end

--@api: lurek.ui.getIconGlyph
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local save_glyph = lurek.ui.getIconGlyph("save") or ""
    local health_glyph = lurek.ui.getIconGlyph("health") or ""
    local missing_glyph = lurek.ui.getIconGlyph("missing-icon")
    example_print_log("save glyph = " .. save_glyph)
    example_print_log("health glyph = " .. health_glyph)
    example_print_log("missing glyph = " .. tostring(missing_glyph))
end

--@api: lurek.ui.newPropertyWidget
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local props = lurek.ui.newPropertyWidget()
    props:setPosition(16, 16)
    props:setSize(320, 220)
    props:setLabelWidth(132)
    local group = props:addGroup("Video System", false)
    props:addProperty(group, "Resolution", "UHD - 2160p", "select", { "HD", "UHD - 2160p" })
    example_print_log("property widget type = " .. props:type())
end

--@api: LPropertyWidget:addGroup
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local props = lurek.ui.newPropertyWidget()
    props:setSize(280, 180)
    local video = props:addGroup("Video", false)
    local audio = props:addGroup("Audio", true)
    props:addProperty(video, "Bits", 10, "number")
    props:addProperty(audio, "Enable Audio", true, "bool")
    example_print_log("groups = " .. video .. "," .. audio)
end

--@api: LPropertyWidget:getGroupCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local props = lurek.ui.newPropertyWidget()
    props:addGroup("Video", false)
    props:addGroup("Audio", false)
    props:addGroup("Control", true)
    local count = props:getGroupCount()
    props:setSize(300, 160)
    example_print_log("property groups = " .. count)
end

--@api: LPropertyWidget:toggleGroup
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local props = lurek.ui.newPropertyWidget()
    local group = props:addGroup("Output Settings", false)
    props:addProperty(group, "Source Connector", "SDI IN A", "select", { "SDI IN A", "HDMI" })
    local collapsed = props:toggleGroup(group)
    props:setSize(320, 120)
    example_print_log("collapsed = " .. tostring(collapsed))
end

--@api: LPropertyWidget:isGroupCollapsed
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local props = lurek.ui.newPropertyWidget()
    local group = props:addGroup("Key Settings", true)
    props:addProperty(group, "Invert Luma", false, "bool")
    local collapsed = props:isGroupCollapsed(group)
    props:setSize(260, 120)
    example_print_log("key collapsed = " .. tostring(collapsed))
end

--@api: LPropertyWidget:addProperty
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local props = lurek.ui.newPropertyWidget()
    local group = props:addGroup("Audio Settings", false)
    local row = props:addProperty(group, "Audio Channels", "2 Channels", "select", { "2 Channels", "8 Channels" })
    props:addProperty(group, "Delay DVE", 4, "number")
    props:addProperty(group, "Enable Audio", true, "bool")
    example_print_log("added row = " .. row)
end

--@api: LPropertyWidget:getPropertyCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local props = lurek.ui.newPropertyWidget()
    local group = props:addGroup("Video", false)
    props:addProperty(group, "Contains Alpha", false, "bool")
    props:addProperty(group, "Delay DVE", 1, "number")
    local count = props:getPropertyCount(group)
    example_print_log("property rows = " .. count)
end

--@api: LPropertyWidget:getPropertyValue
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local props = lurek.ui.newPropertyWidget()
    local group = props:addGroup("Colorimetry", false)
    props:addProperty(group, "Colorimetry", "Rec. 709", "select", { "Rec. 709", "P3" })
    props:addProperty(group, "Tint", "#55AAFF", "color")
    local value = props:getPropertyValue("Colorimetry")
    example_print_log("colorimetry = " .. tostring(value))
end

--@api: LPropertyWidget:setPropertyValue
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local props = lurek.ui.newPropertyWidget()
    local group = props:addGroup("VBI Settings", false)
    props:addProperty(group, "Delay VBI", 4, "number")
    local changed = props:setPropertyValue("Delay VBI", 14)
    local value = props:getPropertyValue("Delay VBI")
    example_print_log("vbi changed=" .. tostring(changed) .. " value=" .. tostring(value))
end

--@api: LPropertyWidget:getPropertyType
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local props = lurek.ui.newPropertyWidget()
    local group = props:addGroup("Output", false)
    props:addProperty(group, "Enable Audio", true, "boolean")
    props:addProperty(group, "Source Connector", "SDI IN A", "select", { "SDI IN A", "HDMI" })
    local value_type = props:getPropertyType("Enable Audio")
    example_print_log("type = " .. tostring(value_type))
end

--@api: LPropertyWidget:getPropertyOptions
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local props = lurek.ui.newPropertyWidget()
    local group = props:addGroup("Video System", false)
    props:addProperty(group, "Resolution", "UHD - 2160p", "select", { "HD - 1080p", "UHD - 2160p" })
    local options = props:getPropertyOptions("Resolution")
    local first = options[1] or ""
    example_print_log("first option = " .. first)
end

--@api: LPropertyWidget:setLabelWidth
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local props = lurek.ui.newPropertyWidget()
    props:setLabelWidth(150)
    props:setSize(340, 180)
    local group = props:addGroup("Inspector", false)
    props:addProperty(group, "Name Column", "150 px", "text")
    example_print_log("label width = " .. props:getLabelWidth())
end

--@api: LPropertyWidget:getLabelWidth
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local props = lurek.ui.newPropertyWidget()
    local before = props:getLabelWidth()
    props:setLabelWidth(120)
    local after = props:getLabelWidth()
    props:addGroup("Columns", false)
    example_print_log("label width before=" .. before .. " after=" .. after)
end

--@api: lurek.ui.newIcon
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local icon = lurek.ui.newIcon("settings")
    icon:setSize(28, 28)
    icon:setPosition(12, 12)
    example_print_log("icon type = " .. icon:type())
    example_print_log("icon name = " .. tostring(icon:getIcon()))
    example_print_log("icon position = " .. icon:getIconPosition())
end

--@api: LUiWidget:setIcon
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local button = lurek.ui.newButton("Save")
    local ok = button:setIcon("save")
    local bad = button:setIcon("missing-icon")
    example_print_log("set icon ok = " .. tostring(ok))
    example_print_log("set icon bad = " .. tostring(bad))
    example_print_log("button icon = " .. tostring(button:getIcon()))
end

--@api: LUiWidget:getIcon
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local button = lurek.ui.newButton("Inventory")
    local before = button:getIcon()
    button:setIcon("inventory")
    local after = button:getIcon()
    example_print_log("icon before = " .. tostring(before))
    example_print_log("icon after = " .. tostring(after))
    example_print_log("button text = " .. button:getText())
end

--@api: LUiWidget:clearIcon
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local button = lurek.ui.newButton("Map")
    button:setIcon("map")
    local before = button:getIcon()
    button:clearIcon()
    example_print_log("icon before clear = " .. tostring(before))
    example_print_log("icon after clear = " .. tostring(button:getIcon()))
    example_print_log("button text = " .. button:getText())
end

--@api: LUiWidget:setIconPosition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local button = lurek.ui.newButton("Settings")
    button:setIcon("settings")
    local ok = button:setIconPosition("right")
    local bad = button:setIconPosition("diagonal")
    example_print_log("position ok = " .. tostring(ok))
    example_print_log("position bad = " .. tostring(bad))
    example_print_log("position = " .. button:getIconPosition())
end

--@api: LUiWidget:getIconPosition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local button = lurek.ui.newButton("Play")
    local before = button:getIconPosition()
    button:setIcon("play")
    button:setIconPosition("only")
    example_print_log("position before = " .. before)
    example_print_log("position after = " .. button:getIconPosition())
    example_print_log("icon = " .. tostring(button:getIcon()))
end

--@api: LUiWidget:setIconSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local button = lurek.ui.newButton("Zoom")
    button:setIcon("zoom-in")
    local ok = button:setIconSize(18)
    local bad = button:setIconSize(-1)
    example_print_log("size ok = " .. tostring(ok))
    example_print_log("size bad = " .. tostring(bad))
    example_print_log("size = " .. button:getIconSize())
end

--@api: LUiWidget:getIconSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local button = lurek.ui.newButton("Health")
    local default_size = button:getIconSize()
    button:setIcon("health")
    button:setIconSize(20)
    example_print_log("default size = " .. default_size)
    example_print_log("updated size = " .. button:getIconSize())
    example_print_log("icon = " .. tostring(button:getIcon()))
end

-- Duplicate coverage lives in content/examples/charts.lua.
