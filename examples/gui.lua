-- examples/gui.lua
-- Retained-mode widget GUI system for Luna2D
-- API: luna.gui
-- Constructors return widget tables; all forward events from game callbacks.

--------------------------------------------------------------------------------
-- Module-level setup and themes
--------------------------------------------------------------------------------

-- Create and apply a custom theme
local theme = luna.gui.newTheme()
luna.gui.setTheme(theme)
local t = luna.gui.getTheme()   -- returns theme table or nil

-- Access root context widget count
local n = luna.gui.getWidgetCount()  -- number

-- Toast notifications
luna.gui.addToast({ message = "Hello!", duration = 3.0 })
local tc = luna.gui.getToastCount()  -- number

-- Focus management
luna.gui.setFocus(nil)              -- clear focus
local focused = luna.gui.getFocus() -- number or nil
luna.gui.focusNext()
luna.gui.focusPrev()
luna.gui.clearFocus()

--------------------------------------------------------------------------------
-- Event forwarding (call from game callbacks)
--------------------------------------------------------------------------------

luna.mousepressed = function(x, y, btn)
    luna.gui.mousepressed(x, y, btn)
end

luna.mousereleased = function(x, y, btn)
    luna.gui.mousereleased(x, y, btn)
end

luna.mousemoved = function(x, y)
    local consumed = luna.gui.mousemoved(x, y)  -- returns boolean
end

luna.keypressed = function(key)
    local consumed = luna.gui.keypressed(key)   -- returns boolean
end

luna.textinput = function(text)
    luna.gui.textinput(text)
end

luna.wheelmoved = function(x, y)
    luna.gui.wheelmoved(x, y)
end

luna.update = function(dt)
    luna.gui.update(dt)
end

--------------------------------------------------------------------------------
-- Base widget methods (shared by ALL widget types)
--------------------------------------------------------------------------------

-- All widget constructors return a "widget table" with these shared methods:
-- :setPosition(x, y)       :getPosition() → x, y
-- :setSize(w, h)           :getSize()     → w, h
-- :setVisible(bool)        :isVisible()   → bool
-- :setEnabled(bool)        :isEnabled()   → bool
-- :setId(str)              :getId()       → str
-- :setTooltip(str)         :getTooltip()  → str
-- :getState()              → "normal" | "hover" | "pressed" | "disabled"
-- :addChild(child_tbl)     :removeChild(child_tbl)
-- :getChildCount()         → integer
-- :findById(id)            → widget table or nil
-- :setOnClick(fn)          :setOnChange(fn)    :setOnDraw(fn)
-- :containsPoint(x, y)    → boolean
-- :setPadding(top, right?, bottom?, left?)    :getPadding() → t,r,b,l
-- :setMargin(top, right?, bottom?, left?)     :getMargin()  → t,r,b,l
-- :setZOrder(z)            :getZOrder()   → z
-- :setMinSize(w, h)        :getMinSize()  → w, h
-- :setMaxSize(w, h)        :getMaxSize()  → w, h
-- :setAnchor(left?, top?, right?, bottom?)
-- :setAnchorCenter(cx?, cy?)   :clearAnchor()
-- :setFlexGrow(n)          :getFlexGrow() → n
-- :setFlexShrink(n)        :getFlexShrink() → n

--------------------------------------------------------------------------------
-- Button
--------------------------------------------------------------------------------

local btn = luna.gui.newButton("Click me")
btn:setText("Submit")
local txt = btn:getText()    -- "Submit"
btn:setOnClick(function() print("clicked!") end)
btn:setPosition(10, 10)
btn:setSize(100, 30)

--------------------------------------------------------------------------------
-- Label
--------------------------------------------------------------------------------

local lbl = luna.gui.newLabel("Hello, World!")
lbl:setText("Updated text")
local s = lbl:getText()    -- "Updated text"
lbl:setPosition(10, 50)

--------------------------------------------------------------------------------
-- TextInput
--------------------------------------------------------------------------------

local ti = luna.gui.newTextInput()
ti:setText("initial value")
ti:setPlaceholder("Type here...")
local ph = ti:getPlaceholder()    -- "Type here..."
ti:setMaxLength(100)
local focused = ti:isFocused()    -- boolean
local cursor = ti:getCursorPosition()  -- integer
ti:setOnChange(function() print("changed:", ti:getText()) end)

--------------------------------------------------------------------------------
-- CheckBox
--------------------------------------------------------------------------------

local cb = luna.gui.newCheckbox("Enable feature")
cb:setChecked(true)
local checked = cb:isChecked()   -- boolean
cb:setOnChange(function() print("checked:", cb:isChecked()) end)

--------------------------------------------------------------------------------
-- Slider
--------------------------------------------------------------------------------

local sl = luna.gui.newSlider(0, 100)
sl:setValue(50)
local v = sl:getValue()   -- 50
sl:setRange(0, 200)
sl:setStep(5)
local mn = sl:getMin()    -- 0
local mx = sl:getMax()    -- 200
sl:setOnChange(function() print("slider:", sl:getValue()) end)

--------------------------------------------------------------------------------
-- ProgressBar
--------------------------------------------------------------------------------

local pb = luna.gui.newProgressBar(0, 100)
pb:setValue(75)
local pv = pb:getValue()      -- 75
local pp = pb:getProgress()   -- 0.75 (normalized)
pb:setRange(0, 200)
local pm = pb:getMin()        -- 0
local pmx = pb:getMax()       -- 200

--------------------------------------------------------------------------------
-- ComboBox (dropdown)
--------------------------------------------------------------------------------

local combo = luna.gui.newComboBox()
combo:addItem("Option A")
combo:addItem("Option B")
combo:addItem("Option C")
combo:removeItem(1)    -- remove first item by index
local count = combo:getItemCount()    -- number
local item = combo:getItem(1)         -- string
combo:setSelectedIndex(2)
local idx = combo:getSelectedIndex()  -- integer
local sel = combo:getSelectedItem()   -- string
combo:setOnChange(function() print("selected:", combo:getSelectedItem()) end)
combo:clearItems()

--------------------------------------------------------------------------------
-- ListBox
--------------------------------------------------------------------------------

local lb = luna.gui.newList()
lb:addItem("Row 1")
lb:addItem("Row 2")
lb:addItem("Row 3")
lb:removeItem(1)
local lcount = lb:getItemCount()     -- number
local litem = lb:getItem(2)          -- string
lb:setSelectedIndex(1)
local lidx = lb:getSelectedIndex()   -- integer
lb:setItemHeight(20)
lb:clearItems()

--------------------------------------------------------------------------------
-- TabBar
--------------------------------------------------------------------------------

local tabs = luna.gui.newTabBar()
tabs:addTab("General")
tabs:addTab("Advanced")
tabs:addTab("Help")
tabs:removeTab(3)
local tab = tabs:getTab(1)      -- string
local tc2 = tabs:getTabCount()  -- number
tabs:setActiveTab(2)
local active = tabs:getActiveTab()  -- integer (1-based)

--------------------------------------------------------------------------------
-- Panel (container with optional title)
--------------------------------------------------------------------------------

local panel = luna.gui.newPanel()
panel:setTitle("Settings")
local pt = panel:getTitle()     -- "Settings"
panel:setScrollable(true)
panel:addChild(btn)
panel:addChild(lbl)

--------------------------------------------------------------------------------
-- Layout (flex-style auto-layout container)
--------------------------------------------------------------------------------

local layout = luna.gui.newLayout("horizontal")  -- or "vertical" (default)
layout:setDirection("vertical")
local dir = layout:getDirection()   -- "vertical"
layout:setSpacing(5)
local sp = layout:getSpacing()      -- 5
layout:setColumns(2)
layout:setWrap(true)
local wrap = layout:getWrap()       -- boolean
layout:setAlign("center")           -- "start" | "center" | "end" | "stretch"
local align = layout:getAlign()
layout:setJustify("space-between")  -- "start" | "end" | "center" | "space-between" | "space-around"
local just = layout:getJustify()
layout:addChild(btn)
layout:addChild(lbl)

--------------------------------------------------------------------------------
-- ScrollPanel
--------------------------------------------------------------------------------

local sp2 = luna.gui.newScrollPanel()
sp2:setContentSize(400, 800)
local cw, ch = sp2:getContentSize()  -- content dimensions
sp2:setScrollPosition(0, 100)
local sx, sy = sp2:getScrollPosition()
local maxX, maxY = sp2:getMaxScroll()
sp2:setScrollSpeed(3)
local speed = sp2:getScrollSpeed()  -- number

--------------------------------------------------------------------------------
-- Separator and Spacer
--------------------------------------------------------------------------------

local sep = luna.gui.newSeparator(false)  -- false = horizontal (default)
sep:setVertical(true)
local vert = sep:isVertical()   -- boolean
sep:setThickness(2)
local thick = sep:getThickness()   -- number

local spacer = luna.gui.newSpacer(10, 20)   -- fixed w, h
spacer:setSize(30, 30)

--------------------------------------------------------------------------------
-- TreeView
--------------------------------------------------------------------------------

local tree = luna.gui.newTreeView()
tree:addNode("Root")                 -- returns node index (1-based)
tree:addNode("Child A", 1)           -- add child of node 1
tree:addNode("Child B", 1)
tree:setNodeText(2, "Updated Child")
local text = tree:getNodeText(2)     -- "Updated Child"
tree:setNodeIcon(1, "folder")
tree:expandNode(1)
tree:collapseNode(1)
tree:toggleNode(1)
local expanded = tree:isNodeExpanded(1)  -- boolean
local isExp = tree:isExpanded(1)          -- alias
tree:expandAll()
tree:collapseAll()
local count3 = tree:getNodeCount()   -- total nodes
tree:setSelectedNode(2)
local selNode = tree:getSelectedNode()   -- index or nil
local children = tree:getChildNodes(1)   -- table of indices
local parent = tree:getParentNode(2)     -- parent index or nil
local depth = tree:getNodeDepth(2)       -- 0-based depth
tree:removeNode(3)
tree:clearNodes()

--------------------------------------------------------------------------------
-- RadioButton
--------------------------------------------------------------------------------

local rb = luna.gui.newRadioButton("Option 1", "group_a")
rb:setGroup("group_a")
local g = rb:getGroup()      -- "group_a"
rb:setSelected(true)
local sel2 = rb:isSelected() -- boolean
rb:setOnChange(function() print("radio changed:", rb:isSelected()) end)

--------------------------------------------------------------------------------
-- ScrollBar
--------------------------------------------------------------------------------

local sb = luna.gui.newScrollBar(false)  -- false = horizontal
sb:setScrollPosition(50)
local spos = sb:getScrollPosition()   -- number
sb:setContentSize(500)
local csize = sb:getContentSize()     -- number
sb:setViewSize(200)
local vsize = sb:getViewSize()        -- number
local isV = sb:isVertical()           -- boolean
sb:setOnChange(function() print("scroll:", sb:getScrollPosition()) end)

--------------------------------------------------------------------------------
-- GUIWindow (floating dialog-style window)
--------------------------------------------------------------------------------

local win = luna.gui.newWindow("My Window")
win:setTitle("Updated Title")
local wt = win:getTitle()       -- string
win:setCloseable(true)
local close = win:isCloseable() -- boolean
win:setDraggable(true)
local drag = win:isDraggable()  -- boolean
win:setResizable(true)
local resize = win:isResizable()  -- boolean
win:setOnClose(function() print("window closed") end)
win:addChild(lbl)

--------------------------------------------------------------------------------
-- SplitPanel (resizable two-pane split)
--------------------------------------------------------------------------------

local split = luna.gui.newSplitPanel("horizontal")  -- or "vertical"
split:setOrientation("vertical")
local orient = split:getOrientation()  -- "vertical"
split:setSplitPosition(0.5)
local pos = split:getSplitPosition()   -- 0.5
split:setMinPanelSize(50)
local minSize = split:getMinPanelSize()  -- 50
split:setFirstChild(panel)
split:setSecondChild(layout)
local fc = split:getFirstChild()   -- widget table
local sc = split:getSecondChild()  -- widget table

--------------------------------------------------------------------------------
-- DockPanel (dockable child panels)
--------------------------------------------------------------------------------

local dock = luna.gui.newDockPanel()
dock:dock(panel, "left")      -- sides: "left", "right", "top", "bottom"
dock:dock(layout, "bottom")
dock:undock(panel)
local dc = dock:getDockedCount()  -- number
dock:setSplitSize(200)
local ds = dock:getSplitSize()    -- number

--------------------------------------------------------------------------------
-- Toolbar
--------------------------------------------------------------------------------

local toolbar = luna.gui.newToolbar("horizontal")
toolbar:setOrientation("vertical")
local to = toolbar:getOrientation()   -- "vertical"
toolbar:addButton("save", "Save file")
toolbar:addButton("open", "Open file")
local tbBtn = toolbar:getButton("save")  -- widget table or nil
toolbar:setButtonEnabled("save", true)
toolbar:setButtonToggled("save", false)
local toggled = toolbar:isButtonToggled("save")  -- boolean

--------------------------------------------------------------------------------
-- MenuBar
--------------------------------------------------------------------------------

local menu = luna.gui.newMenuBar()
local fileMenu = luna.gui.newMenuItem("File")
local editMenu = luna.gui.newMenuItem("Edit")
menu:addChild(fileMenu)
menu:addChild(editMenu)

--------------------------------------------------------------------------------
-- Specialized widgets
--------------------------------------------------------------------------------

-- Dialog (modal workflow)
local dlg = luna.gui.newDialog("Confirm?")
dlg:setTitle("Are you sure?")
dlg:addChild(luna.gui.newLabel("This cannot be undone."))
dlg:addChild(luna.gui.newButton("OK"))
dlg:addChild(luna.gui.newButton("Cancel"))

-- StatusBar
local status = luna.gui.newStatusBar()
status:addChild(luna.gui.newLabel("Ready"))

-- Accordion (collapsing sections)
local accord = luna.gui.newAccordion()
accord:addChild(luna.gui.newPanel())

-- TooltipPanel
local tip = luna.gui.newTooltipPanel("Helpful hint here")

-- NinePatch (scalable 9-slice image)
local nine = luna.gui.newNinePatch()
nine:setInsets(10, 10, 10, 10)    -- top, right, bottom, left
local t2, r2, b2, l2 = nine:getInsets()
nine:setImageDimensions(64, 64)
local nw, nh = nine:getImageDimensions()
local slices = nine:getSlices()   -- table of patch rects

-- Toast (auto-dismissing notification)
local toast = luna.gui.newToast("Saved!", 2.0)
toast:setMessage("File saved.")
local msg = toast:getMessage()    -- string
toast:setDuration(3)
local dur = toast:getDuration()   -- number
local prog = toast:getProgress()  -- 0.0–1.0 elapsed
local exp = toast:isExpired()     -- boolean

-- ColorPicker
local picker = luna.gui.newColorPicker()
picker:setOnChange(function() print("color changed") end)

-- Table widget (grid data view)
local tblWidget = luna.gui.newTable()
tblWidget:addChild(luna.gui.newLabel("Header"))

-- ImageWidget
local imgW = luna.gui.newImageWidget()
imgW:setSize(128, 128)

--------------------------------------------------------------------------------
-- Root container usage pattern
--------------------------------------------------------------------------------

local root = luna.gui.getRoot()   -- main root panel widget
root:addChild(panel)
root:addChild(toolbar)

luna.draw = function()
    -- GUI is drawn automatically via engine — no explicit draw call needed
end
