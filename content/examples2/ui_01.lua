--- UI Module Part 2: layout, containers (DockPanel, SplitPanel, ScrollPanel), flex, margin, padding

--@api-stub: lurek.ui.newLayout (horizontal)
-- Creating a horizontal layout.
do
    ---@type LLayout
    local row = lurek.ui.newLayout("horizontal")
    print("type = " .. row:type())
    print("direction = " .. row:getDirection())
    print("spacing = " .. row:getSpacing())
end

--@api-stub: lurek.ui.newLayout (vertical)
-- Creating a vertical layout.
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

print("ui_01.lua")
