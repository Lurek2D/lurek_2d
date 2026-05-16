-- content/examples/ui.lua
-- lurek.ui API examples.
-- Run: cargo run -- content/examples/ui.lua

--@api-stub: lurek.ui.beginDrag -- Begins a drag operation on a widget
do -- lurek.ui.beginDrag
  local w = lurek.ui.newButton("Drag")
  pcall(function() lurek.ui.beginDrag(w) end)
end

--@api-stub: lurek.ui.getActiveDrag -- Returns the widget index currently being dragged, or nil
do -- lurek.ui.getActiveDrag
  pcall(function()
    local v = lurek.ui.getActiveDrag()
    print("getActiveDrag:", v)
  end)
end

--@api-stub: lurek.ui.dropOn -- Drops the currently dragged widget onto a target widget
do -- lurek.ui.dropOn
  local container = lurek.ui.newPanel()
  local w = lurek.ui.newLabel("drop")
  pcall(function()
    lurek.ui.beginDrag(w)
    lurek.ui.dropOn(container)
  end)
end

--@api-stub: lurek.ui.endDrag -- Ends the current drag operation without dropping
do -- lurek.ui.endDrag
  pcall(function()
    local prev = lurek.ui.endDrag()
    print("endDrag:", prev)
  end)
end

--@api-stub: LUiWidget:animateAlpha
do -- LUiWidget:animateAlpha
  local w = lurek.ui.newLabel("alpha")
  pcall(function() w["animateAlpha"](0.5, 0.25, false) end)
end

--@api-stub: LUiWidget:animatePosition
do -- LUiWidget:animatePosition
  local w = lurek.ui.newLabel("move")
  pcall(function() w["animatePosition"](120, 40, 0.25) end)
end

--@api-stub: LUiWidget:isAnimating
do -- LUiWidget:isAnimating
  local w = lurek.ui.newLabel("state")
  pcall(function()
    local v = w["isAnimating"]()
    print("isAnimating:", v)
  end)
end

--@api-stub: LUiWidget:cancelAnimations
do -- LUiWidget:cancelAnimations
  local w = lurek.ui.newLabel("cancel")
  pcall(function() w["cancelAnimations"]() end)
end

--@api-stub: lurek.ui.setPosition
do -- lurek.ui.setPosition
  pcall(function() lurek.ui.setPosition(100, 200) end)
  print("applied")
end

--@api-stub: lurek.ui.getPosition
do -- lurek.ui.getPosition
  pcall(function()
    local v = lurek.ui.getPosition()
    print("getPosition:", v)
  end)
end

--@api-stub: lurek.ui.setSize
do -- lurek.ui.setSize
  pcall(function() lurek.ui.setSize(200, 50) end)
  print("applied")
end

--@api-stub: lurek.ui.getSize
do -- lurek.ui.getSize
  pcall(function()
    local v = lurek.ui.getSize()
    print("getSize:", v)
  end)
end

--@api-stub: lurek.ui.getRect
do -- lurek.ui.getRect
  pcall(function()
    local v = lurek.ui.getRect()
    print("getRect:", v)
  end)
end

--@api-stub: lurek.ui.setVisible
do -- lurek.ui.setVisible
  pcall(function() lurek.ui.setVisible(true) end)
  print("applied")
end

--@api-stub: lurek.ui.isVisible
do -- lurek.ui.isVisible
  pcall(function()
    local v = lurek.ui.isVisible()
    print("isVisible:", v)
  end)
end

--@api-stub: lurek.ui.setEnabled
do -- lurek.ui.setEnabled
  pcall(function() lurek.ui.setEnabled(true) end)
  print("applied")
end

--@api-stub: lurek.ui.isEnabled
do -- lurek.ui.isEnabled
  pcall(function()
    local v = lurek.ui.isEnabled()
    print("isEnabled:", v)
  end)
end

--@api-stub: lurek.ui.setId
do -- lurek.ui.setId
  pcall(function()
    lurek.ui.setId("primary")
    print("applied")
  end)
end

--@api-stub: lurek.ui.getId
do -- lurek.ui.getId
  pcall(function()
    local v = lurek.ui.getId()
    print("getId:", v)
  end)
end

--@api-stub: lurek.ui.setTooltip
do -- lurek.ui.setTooltip
  lurek.ui.setTooltip("Hello")
  print("applied")
end

--@api-stub: lurek.ui.getTooltip
do -- lurek.ui.getTooltip
  local v = lurek.ui.getTooltip()
  print("getTooltip:", v)
end

--@api-stub: lurek.ui.getState
do -- lurek.ui.getState
  local v = lurek.ui.getState()
  print("getState:", v)
end

--@api-stub: lurek.ui.addChild
do -- lurek.ui.addChild
  lurek.ui.addChild(1)
  print("added")
end

--@api-stub: lurek.ui.removeChild
do -- lurek.ui.removeChild
  lurek.ui.removeChild(1)
  print("done")
end

--@api-stub: lurek.ui.getChildCount
do -- lurek.ui.getChildCount
  local v = lurek.ui.getChildCount()
  print("getChildCount:", v)
end

--@api-stub: lurek.ui.getChildren
do -- lurek.ui.getChildren
  local v = lurek.ui.getChildren()
  print("getChildren:", v)
end

--@api-stub: lurek.ui.findById
do -- lurek.ui.findById
  local v = lurek.ui.findById("widget_id")
  print("findById:", v)
end

--@api-stub: lurek.ui.setOnClick
do -- lurek.ui.setOnClick
  lurek.ui.setOnClick(function() print("event") end)
  print("applied")
end

--@api-stub: lurek.ui.setOnChange
do -- lurek.ui.setOnChange
  lurek.ui.setOnChange(function() print("event") end)
  print("applied")
end

--@api-stub: lurek.ui.setOnDraw
do -- lurek.ui.setOnDraw
  lurek.ui.setOnDraw(function() print("event") end)
  print("applied")
end

--@api-stub: lurek.ui.containsPoint
do -- lurek.ui.containsPoint
  local v = lurek.ui.containsPoint(0, 0)
  print("containsPoint:", v)
end

--@api-stub: lurek.ui.setPadding
do -- lurek.ui.setPadding
  lurek.ui.setPadding(8)
  print("applied")
end

--@api-stub: lurek.ui.getPadding
do -- lurek.ui.getPadding
  local v = lurek.ui.getPadding()
  print("getPadding:", v)
end

--@api-stub: lurek.ui.setMargin
do -- lurek.ui.setMargin
  lurek.ui.setMargin(8)
  print("applied")
end

--@api-stub: lurek.ui.getMargin
do -- lurek.ui.getMargin
  local v = lurek.ui.getMargin()
  print("getMargin:", v)
end

--@api-stub: lurek.ui.setZOrder
do -- lurek.ui.setZOrder
  lurek.ui.setZOrder(1)
  print("applied")
end

--@api-stub: lurek.ui.getZOrder
do -- lurek.ui.getZOrder
  local v = lurek.ui.getZOrder()
  print("getZOrder:", v)
end

--@api-stub: lurek.ui.setMinSize
do -- lurek.ui.setMinSize
  lurek.ui.setMinSize(200, 50)
  print("applied")
end

--@api-stub: lurek.ui.getMinSize
do -- lurek.ui.getMinSize
  local v = lurek.ui.getMinSize()
  print("getMinSize:", v)
end

--@api-stub: lurek.ui.setMaxSize
do -- lurek.ui.setMaxSize
  lurek.ui.setMaxSize(200, 50)
  print("applied")
end

--@api-stub: lurek.ui.getMaxSize
do -- lurek.ui.getMaxSize
  local v = lurek.ui.getMaxSize()
  print("getMaxSize:", v)
end

--@api-stub: lurek.ui.setAnchor
do -- lurek.ui.setAnchor
  lurek.ui.setAnchor(8, 8, 8, 8)
  print("applied")
end

--@api-stub: lurek.ui.setAnchorCenter
do -- lurek.ui.setAnchorCenter
  lurek.ui.setAnchorCenter(0, 0)
  print("applied")
end

--@api-stub: lurek.ui.clearAnchor
do -- lurek.ui.clearAnchor
  lurek.ui.clearAnchor()
  print("done")
end

--@api-stub: lurek.ui.setFlexGrow
do -- lurek.ui.setFlexGrow
  lurek.ui.setFlexGrow(1)
  print("applied")
end

--@api-stub: lurek.ui.getFlexGrow
do -- lurek.ui.getFlexGrow
  local v = lurek.ui.getFlexGrow()
  print("getFlexGrow:", v)
end

--@api-stub: lurek.ui.setFlexShrink
do -- lurek.ui.setFlexShrink
  lurek.ui.setFlexShrink(1)
  print("applied")
end

--@api-stub: lurek.ui.getFlexShrink
do -- lurek.ui.getFlexShrink
  local v = lurek.ui.getFlexShrink()
  print("getFlexShrink:", v)
end

--@api-stub: lurek.ui.bind
do -- lurek.ui.bind
  lurek.ui.bind("key")
  print("bind called")
end

--@api-stub: lurek.ui.unbind
do -- lurek.ui.unbind
  lurek.ui.unbind()
  print("unbind called")
end

--@api-stub: lurek.ui.setAlpha
do -- lurek.ui.setAlpha
  lurek.ui.setAlpha(0.85)
  print("applied")
end

--@api-stub: lurek.ui.getAlpha
do -- lurek.ui.getAlpha
  local v = lurek.ui.getAlpha()
  print("getAlpha:", v)
end

--@api-stub: lurek.ui.fadeIn
do -- lurek.ui.fadeIn
  lurek.ui.fadeIn()
  print("fadeIn called")
end

--@api-stub: lurek.ui.fadeOut
do -- lurek.ui.fadeOut
  lurek.ui.fadeOut()
  print("fadeOut called")
end

--@api-stub: lurek.ui.slideIn
do -- lurek.ui.slideIn
  lurek.ui.slideIn(0, 0)
  print("slideIn called")
end

--@api-stub: lurek.ui.slideOut
do -- lurek.ui.slideOut
  lurek.ui.slideOut(0, 0)
  print("slideOut called")
end

--@api-stub: lurek.ui.attachToEntity
do -- lurek.ui.attachToEntity
  lurek.ui.attachToEntity(1)
  print("attachToEntity called")
end

--@api-stub: lurek.ui.detachFromEntity
do -- lurek.ui.detachFromEntity
  lurek.ui.detachFromEntity()
  print("detachFromEntity called")
end


---@return any
local function new_example_image_widget()
  return {}
end

--@api-stub: Button:setText
do -- Button:setText
  local btn = new_example_image_widget():newButton("btn_play", "Play")
  btn:setText("Hello")
end

--@api-stub: Button:getText
do -- Button:getText
  local btn = new_example_image_widget():newButton("btn_play", "Play")
  local v = btn:getText()
  print("getText:", v)
end

-- â”€â”€ Label methods â”€â”€

--@api-stub: Label:setText
do -- Label:setText
  local lbl = new_example_image_widget():newLabel("lbl_score", "Score: 0")
  lbl:setText("Hello")
end

--@api-stub: Label:getText
do -- Label:getText
  local lbl = new_example_image_widget():newLabel("lbl_score", "Score: 0")
  local v = lbl:getText()
  print("getText:", v)
end

-- â”€â”€ Text_Input methods â”€â”€

--@api-stub: Text_Input:setText
do -- Text_Input:setText
  local ti = new_example_image_widget():newTextInput("ti_name", "")
  ti:setText("Hello")
end

--@api-stub: Text_Input:getText
do -- Text_Input:getText
  local ti = new_example_image_widget():newTextInput("ti_name", "")
  local v = ti:getText()
  print("getText:", v)
end

--@api-stub: Text_Input:setPlaceholder
do -- Text_Input:setPlaceholder
  local ti = new_example_image_widget():newTextInput("ti_name", "")
  ti:setPlaceholder("Hello")
end

--@api-stub: Text_Input:getPlaceholder
do -- Text_Input:getPlaceholder
  local ti = new_example_image_widget():newTextInput("ti_name", "")
  local v = ti:getPlaceholder()
  print("getPlaceholder:", v)
end

--@api-stub: Text_Input:setMaxLength
do -- Text_Input:setMaxLength
  local ti = new_example_image_widget():newTextInput("ti_name", "")
  ti:setMaxLength(100)
end

--@api-stub: Text_Input:isFocused
do -- Text_Input:isFocused
  local ti = new_example_image_widget():newTextInput("ti_name", "")
  local v = ti:isFocused()
  print("isFocused:", v)
end

--@api-stub: Text_Input:getCursorPosition
do -- Text_Input:getCursorPosition
  local ti = new_example_image_widget():newTextInput("ti_name", "")
  local v = ti:getCursorPosition()
  print("getCursorPosition:", v)
end

-- â”€â”€ Checkbox methods â”€â”€

--@api-stub: Checkbox:setChecked
do -- Checkbox:setChecked
  local cb = new_example_image_widget():newCheckbox("cb_sound", "Sound", true)
  cb:setChecked(true)
end

--@api-stub: Checkbox:isChecked
do -- Checkbox:isChecked
  local cb = new_example_image_widget():newCheckbox("cb_sound", "Sound", true)
  local v = cb:isChecked()
  print("isChecked:", v)
end

--@api-stub: Checkbox:setText
do -- Checkbox:setText
  local cb = new_example_image_widget():newCheckbox("cb_sound", "Sound", true)
  cb:setText("Hello")
end

--@api-stub: Checkbox:getText
do -- Checkbox:getText
  local cb = new_example_image_widget():newCheckbox("cb_sound", "Sound", true)
  local v = cb:getText()
  print("getText:", v)
end

-- â”€â”€ Slider methods â”€â”€

--@api-stub: Slider:setValue
do -- Slider:setValue
  local sl = new_example_image_widget():newSlider(0, 100, 50)
  sl:setValue(0.5)
end

--@api-stub: Slider:getValue
do -- Slider:getValue
  local sl = new_example_image_widget():newSlider(0, 100, 50)
  local v = sl:getValue()
  print("getValue:", v)
end

--@api-stub: Slider:setRange
do -- Slider:setRange
  local sl = new_example_image_widget():newSlider(0, 100, 50)
  sl:setRange(1)
end

--@api-stub: Slider:setStep
do -- Slider:setStep
  local sl = new_example_image_widget():newSlider(0, 100, 50)
  sl:setStep(1)
end

--@api-stub: Slider:getMin
do -- Slider:getMin
  local sl = new_example_image_widget():newSlider(0, 100, 50)
  local v = sl:getMin()
  print("getMin:", v)
end

--@api-stub: Slider:getMax
do -- Slider:getMax
  local sl = new_example_image_widget():newSlider(0, 100, 50)
  local v = sl:getMax()
  print("getMax:", v)
end

-- â”€â”€ Progress_Bar methods â”€â”€

--@api-stub: Progress_Bar:setValue
do -- Progress_Bar:setValue
  local pb = new_example_image_widget():newProgressBar(0.5)
  pb:setValue(0.5)
end

--@api-stub: Progress_Bar:getValue
do -- Progress_Bar:getValue
  local pb = new_example_image_widget():newProgressBar(0.5)
  local v = pb:getValue()
  print("getValue:", v)
end

--@api-stub: Progress_Bar:getProgress
do -- Progress_Bar:getProgress
  local pb = new_example_image_widget():newProgressBar(0.5)
  local v = pb:getProgress()
  print("getProgress:", v)
end

--@api-stub: Progress_Bar:setRange
do -- Progress_Bar:setRange
  local pb = new_example_image_widget():newProgressBar(0.5)
  pb:setRange(1)
end

--@api-stub: Progress_Bar:getMin
do -- Progress_Bar:getMin
  local pb = new_example_image_widget():newProgressBar(0.5)
  local v = pb:getMin()
  print("getMin:", v)
end

--@api-stub: Progress_Bar:getMax
do -- Progress_Bar:getMax
  local pb = new_example_image_widget():newProgressBar(0.5)
  local v = pb:getMax()
  print("getMax:", v)
end

-- â”€â”€ Combo_Box methods â”€â”€

--@api-stub: Combo_Box:addItem
do -- Combo_Box:addItem
  local cb = new_example_image_widget():newComboBox({"Easy","Normal","Hard"})
  cb:addItem("item_1")
end

--@api-stub: Combo_Box:removeItem
do -- Combo_Box:removeItem
  local cb = new_example_image_widget():newComboBox({"Easy","Normal","Hard"})
  cb:removeItem()
end

--@api-stub: Combo_Box:clearItems
do -- Combo_Box:clearItems
  local cb = new_example_image_widget():newComboBox({"Easy","Normal","Hard"})
  cb:clearItems()
end

--@api-stub: Combo_Box:getItemCount
do -- Combo_Box:getItemCount
  local cb = new_example_image_widget():newComboBox({"Easy","Normal","Hard"})
  local v = cb:getItemCount()
  print("getItemCount:", v)
end

--@api-stub: Combo_Box:getItem
do -- Combo_Box:getItem
  local cb = new_example_image_widget():newComboBox({"Easy","Normal","Hard"})
  local v = cb:getItem()
  print("getItem:", v)
end

--@api-stub: Combo_Box:setSelectedIndex
do -- Combo_Box:setSelectedIndex
  local cb = new_example_image_widget():newComboBox({"Easy","Normal","Hard"})
  cb:setSelectedIndex(true)
end

--@api-stub: Combo_Box:getSelectedIndex
do -- Combo_Box:getSelectedIndex
  local cb = new_example_image_widget():newComboBox({"Easy","Normal","Hard"})
  local v = cb:getSelectedIndex()
  print("getSelectedIndex:", v)
end

--@api-stub: Combo_Box:getSelectedItem
do -- Combo_Box:getSelectedItem
  local cb = new_example_image_widget():newComboBox({"Easy","Normal","Hard"})
  local v = cb:getSelectedItem()
  print("getSelectedItem:", v)
end

-- â”€â”€ List_Box methods â”€â”€

--@api-stub: List_Box:addItem
do -- List_Box:addItem
  local w = new_example_image_widget():newList()
  w:addItem("item_1")
end

--@api-stub: List_Box:removeItem
do -- List_Box:removeItem
  local w = new_example_image_widget():newList()
  w:removeItem()
end

--@api-stub: List_Box:clearItems
do -- List_Box:clearItems
  local w = new_example_image_widget():newList()
  w:clearItems()
end

--@api-stub: List_Box:getItemCount
do -- List_Box:getItemCount
  local w = new_example_image_widget():newList()
  local v = w:getItemCount()
  print("getItemCount:", v)
end

--@api-stub: List_Box:getItem
do -- List_Box:getItem
  local w = new_example_image_widget():newList()
  local v = w:getItem()
  print("getItem:", v)
end

--@api-stub: List_Box:setSelectedIndex
do -- List_Box:setSelectedIndex
  local w = new_example_image_widget():newList()
  w:setSelectedIndex(true)
end

--@api-stub: List_Box:getSelectedIndex
do -- List_Box:getSelectedIndex
  local w = new_example_image_widget():newList()
  local v = w:getSelectedIndex()
  print("getSelectedIndex:", v)
end

--@api-stub: List_Box:setItemHeight
do -- List_Box:setItemHeight
  local w = new_example_image_widget():newList()
  w:setItemHeight(50)
end

-- â”€â”€ Tab_Bar methods â”€â”€

--@api-stub: Tab_Bar:addTab
do -- Tab_Bar:addTab
  local tabs = new_example_image_widget():newTabBar({"Equip","Stats","Map"})
  local child = new_example_image_widget():newButton("child_1", "Child")
  tabs:addTab(child)
end

--@api-stub: Tab_Bar:removeTab
do -- Tab_Bar:removeTab
  local tabs = new_example_image_widget():newTabBar({"Equip","Stats","Map"})
  tabs:removeTab()
end

--@api-stub: Tab_Bar:getTab
do -- Tab_Bar:getTab
  local tabs = new_example_image_widget():newTabBar({"Equip","Stats","Map"})
  local v = tabs:getTab()
  print("getTab:", v)
end

--@api-stub: Tab_Bar:getTabCount
do -- Tab_Bar:getTabCount
  local tabs = new_example_image_widget():newTabBar({"Equip","Stats","Map"})
  local v = tabs:getTabCount()
  print("getTabCount:", v)
end

--@api-stub: Tab_Bar:setActiveTab
do -- Tab_Bar:setActiveTab
  local tabs = new_example_image_widget():newTabBar({"Equip","Stats","Map"})
  tabs:setActiveTab(1)
end

--@api-stub: Tab_Bar:getActiveTab
do -- Tab_Bar:getActiveTab
  local tabs = new_example_image_widget():newTabBar({"Equip","Stats","Map"})
  local v = tabs:getActiveTab()
  print("getActiveTab:", v)
end

-- â”€â”€ Spin_Box methods â”€â”€

--@api-stub: Spin_Box:setValue
do -- Spin_Box:setValue
  local spin = new_example_image_widget():newSpinBox()
  spin:setValue(0.5)
end

--@api-stub: Spin_Box:getValue
do -- Spin_Box:getValue
  local spin = new_example_image_widget():newSpinBox()
  local v = spin:getValue()
  print("getValue:", v)
end

--@api-stub: Spin_Box:increment
do -- Spin_Box:increment
  local spin = new_example_image_widget():newSpinBox()
  spin:increment()
end

--@api-stub: Spin_Box:decrement
do -- Spin_Box:decrement
  local spin = new_example_image_widget():newSpinBox()
  spin:decrement()
end

--@api-stub: Spin_Box:setRange
do -- Spin_Box:setRange
  local spin = new_example_image_widget():newSpinBox()
  spin:setRange(1)
end

--@api-stub: Spin_Box:setStep
do -- Spin_Box:setStep
  local spin = new_example_image_widget():newSpinBox()
  spin:setStep(1)
end

-- â”€â”€ Switch methods â”€â”€

--@api-stub: Switch:setOn
do -- Switch:setOn
  local sw = new_example_image_widget():newSwitch(false)
  sw:setOn(function() print("event") end)
end

--@api-stub: Switch:isOn
do -- Switch:isOn
  local sw = new_example_image_widget():newSwitch(false)
  local v = sw:isOn()
  print("isOn:", v)
end

--@api-stub: Switch:toggle
do -- Switch:toggle
  local sw = new_example_image_widget():newSwitch(false)
  sw:toggle()
end

-- â”€â”€ Badge methods â”€â”€

--@api-stub: Badge:setCount
do -- Badge:setCount
  local badge = new_example_image_widget():newBadge("3")
  badge:setCount(4)
end

--@api-stub: Badge:getCount
do -- Badge:getCount
  local badge = new_example_image_widget():newBadge("3")
  local v = badge:getCount()
  print("getCount:", v)
end

--@api-stub: Badge:getDisplayText
do -- Badge:getDisplayText
  local badge = new_example_image_widget():newBadge("3")
  local v = badge:getDisplayText()
  print("getDisplayText:", v)
end

-- â”€â”€ Panel methods â”€â”€

--@api-stub: Panel:setTitle
do -- Panel:setTitle
  local panel = new_example_image_widget():newPanel()
  panel:setTitle("Hello")
end

--@api-stub: Panel:getTitle
do -- Panel:getTitle
  local panel = new_example_image_widget():newPanel()
  local v = panel:getTitle()
  print("getTitle:", v)
end

--@api-stub: Panel:setScrollable
do -- Panel:setScrollable
  local panel = new_example_image_widget():newPanel()
  panel:setScrollable(1)
end

-- â”€â”€ Layout methods â”€â”€

--@api-stub: Layout:setDirection
do -- Layout:setDirection
  local layout = new_example_image_widget():newLayout("vertical")
  layout:setDirection("horizontal")
end

--@api-stub: Layout:getDirection
do -- Layout:getDirection
  local layout = new_example_image_widget():newLayout("vertical")
  local v = layout:getDirection()
  print("getDirection:", v)
end

--@api-stub: Layout:setSpacing
do -- Layout:setSpacing
  local layout = new_example_image_widget():newLayout("vertical")
  layout:setSpacing(8)
end

--@api-stub: Layout:getSpacing
do -- Layout:getSpacing
  local layout = new_example_image_widget():newLayout("vertical")
  local v = layout:getSpacing()
  print("getSpacing:", v)
end

--@api-stub: Layout:setColumns
do -- Layout:setColumns
  local layout = new_example_image_widget():newLayout("vertical")
  layout:setColumns(1)
end

--@api-stub: Layout:setWrap
do -- Layout:setWrap
  local layout = new_example_image_widget():newLayout("vertical")
  layout:setWrap(true)
end

--@api-stub: Layout:getWrap
do -- Layout:getWrap
  local layout = new_example_image_widget():newLayout("vertical")
  local v = layout:getWrap()
  print("getWrap:", v)
end

--@api-stub: Layout:setAlign
do -- Layout:setAlign
  local layout = new_example_image_widget():newLayout("vertical")
  layout:setAlign("center")
end

--@api-stub: Layout:getAlign
do -- Layout:getAlign
  local layout = new_example_image_widget():newLayout("vertical")
  local v = layout:getAlign()
  print("getAlign:", v)
end

--@api-stub: Layout:setJustify
do -- Layout:setJustify
  local layout = new_example_image_widget():newLayout("vertical")
  layout:setJustify(1)
end

--@api-stub: Layout:getJustify
do -- Layout:getJustify
  local layout = new_example_image_widget():newLayout("vertical")
  local v = layout:getJustify()
  print("getJustify:", v)
end

-- â”€â”€ Scroll_Panel methods â”€â”€

--@api-stub: Scroll_Panel:setContentSize
do -- Scroll_Panel:setContentSize
  local sp = new_example_image_widget():newScrollPanel()
  sp:setContentSize(200, 50)
end

--@api-stub: Scroll_Panel:getContentSize
do -- Scroll_Panel:getContentSize
  local sp = new_example_image_widget():newScrollPanel()
  local v = sp:getContentSize()
  print("getContentSize:", v)
end

--@api-stub: Scroll_Panel:setScrollPosition
do -- Scroll_Panel:setScrollPosition
  local sp = new_example_image_widget():newScrollPanel()
  sp:setScrollPosition(100, 200)
end

--@api-stub: Scroll_Panel:getScrollPosition
do -- Scroll_Panel:getScrollPosition
  local sp = new_example_image_widget():newScrollPanel()
  local v = sp:getScrollPosition()
  print("getScrollPosition:", v)
end

--@api-stub: Scroll_Panel:getMaxScroll
do -- Scroll_Panel:getMaxScroll
  local sp = new_example_image_widget():newScrollPanel()
  local v = sp:getMaxScroll()
  print("getMaxScroll:", v)
end

--@api-stub: Scroll_Panel:setScrollSpeed
do -- Scroll_Panel:setScrollSpeed
  local sp = new_example_image_widget():newScrollPanel()
  sp:setScrollSpeed(1)
end

--@api-stub: Scroll_Panel:getScrollSpeed
do -- Scroll_Panel:getScrollSpeed
  local sp = new_example_image_widget():newScrollPanel()
  local v = sp:getScrollSpeed()
  print("getScrollSpeed:", v)
end

-- â”€â”€ Nine_Patch methods â”€â”€

--@api-stub: Nine_Patch:setInsets
do -- Nine_Patch:setInsets
  local np = new_example_image_widget():newNinePatch("assets/panel.9.png")
  np:setInsets(1)
end

--@api-stub: Nine_Patch:getInsets
do -- Nine_Patch:getInsets
  local np = new_example_image_widget():newNinePatch("assets/panel.9.png")
  local v = np:getInsets()
  print("getInsets:", v)
end

--@api-stub: Nine_Patch:setImageDimensions
do -- Nine_Patch:setImageDimensions
  local np = new_example_image_widget():newNinePatch("assets/panel.9.png")
  np:setImageDimensions("assets/icon.png")
end

--@api-stub: Nine_Patch:getImageDimensions
do -- Nine_Patch:getImageDimensions
  local np = new_example_image_widget():newNinePatch("assets/panel.9.png")
  local v = np:getImageDimensions()
  print("getImageDimensions:", v)
end

--@api-stub: Nine_Patch:getSlices
do -- Nine_Patch:getSlices
  local np = new_example_image_widget():newNinePatch("assets/panel.9.png")
  local v = np:getSlices()
  print("getSlices:", v)
end

-- â”€â”€ Toast methods â”€â”€

--@api-stub: Toast:setMessage
do -- Toast:setMessage
  local toast = new_example_image_widget():newToast("Saved.", 2.0)
  toast:setMessage(1)
end

--@api-stub: Toast:getMessage
do -- Toast:getMessage
  local toast = new_example_image_widget():newToast("Saved.", 2.0)
  local v = toast:getMessage()
  print("getMessage:", v)
end

--@api-stub: Toast:setDuration
do -- Toast:setDuration
  local toast = new_example_image_widget():newToast("Saved.", 2.0)
  toast:setDuration(0.5)
end

--@api-stub: Toast:getDuration
do -- Toast:getDuration
  local toast = new_example_image_widget():newToast("Saved.", 2.0)
  local v = toast:getDuration()
  print("getDuration:", v)
end

--@api-stub: Toast:getProgress
do -- Toast:getProgress
  local toast = new_example_image_widget():newToast("Saved.", 2.0)
  local v = toast:getProgress()
  print("getProgress:", v)
end

--@api-stub: Toast:isExpired
do -- Toast:isExpired
  local toast = new_example_image_widget():newToast("Saved.", 2.0)
  local v = toast:isExpired()
  print("isExpired:", v)
end

-- â”€â”€ Separator methods â”€â”€

--@api-stub: Separator:setVertical
do -- Separator:setVertical
  local sep = new_example_image_widget():newSeparator("horizontal")
  sep:setVertical(1)
end

--@api-stub: Separator:isVertical
do -- Separator:isVertical
  local sep = new_example_image_widget():newSeparator("horizontal")
  local v = sep:isVertical()
  print("isVertical:", v)
end

--@api-stub: Separator:setThickness
do -- Separator:setThickness
  local sep = new_example_image_widget():newSeparator("horizontal")
  sep:setThickness(1)
end

--@api-stub: Separator:getThickness
do -- Separator:getThickness
  local sep = new_example_image_widget():newSeparator("horizontal")
  local v = sep:getThickness()
  print("getThickness:", v)
end

-- â”€â”€ Tree_View methods â”€â”€

--@api-stub: Tree_View:addNode
do -- Tree_View:addNode
  local tree = new_example_image_widget():newTreeView({label="root"})
  tree:addNode("item_1")
end

--@api-stub: Tree_View:toggleNode
do -- Tree_View:toggleNode
  local tree = new_example_image_widget():newTreeView({label="root"})
  tree:toggleNode()
end

--@api-stub: Tree_View:isExpanded
do -- Tree_View:isExpanded
  local tree = new_example_image_widget():newTreeView({label="root"})
  local v = tree:isExpanded()
  print("isExpanded:", v)
end

--@api-stub: Tree_View:getNodeCount
do -- Tree_View:getNodeCount
  local tree = new_example_image_widget():newTreeView({label="root"})
  local v = tree:getNodeCount()
  print("getNodeCount:", v)
end

--@api-stub: Tree_View:removeNode
do -- Tree_View:removeNode
  local tree = new_example_image_widget():newTreeView({label="root"})
  tree:removeNode()
end

--@api-stub: Tree_View:clearNodes
do -- Tree_View:clearNodes
  local tree = new_example_image_widget():newTreeView({label="root"})
  tree:clearNodes()
end

--@api-stub: Tree_View:getNodeText
do -- Tree_View:getNodeText
  local tree = new_example_image_widget():newTreeView({label="root"})
  local v = tree:getNodeText()
  print("getNodeText:", v)
end

--@api-stub: Tree_View:setNodeText
do -- Tree_View:setNodeText
  local tree = new_example_image_widget():newTreeView({label="root"})
  tree:setNodeText("Hello")
end

--@api-stub: Tree_View:setNodeIcon
do -- Tree_View:setNodeIcon
  local tree = new_example_image_widget():newTreeView({label="root"})
  tree:setNodeIcon("assets/icon.png")
end

--@api-stub: Tree_View:expandNode
do -- Tree_View:expandNode
  local tree = new_example_image_widget():newTreeView({label="root"})
  tree:expandNode()
end

--@api-stub: Tree_View:collapseNode
do -- Tree_View:collapseNode
  local tree = new_example_image_widget():newTreeView({label="root"})
  tree:collapseNode()
end

--@api-stub: Tree_View:isNodeExpanded
do -- Tree_View:isNodeExpanded
  local tree = new_example_image_widget():newTreeView({label="root"})
  local v = tree:isNodeExpanded()
  print("isNodeExpanded:", v)
end

--@api-stub: Tree_View:expandAll
do -- Tree_View:expandAll
  local tree = new_example_image_widget():newTreeView({label="root"})
  tree:expandAll()
end

--@api-stub: Tree_View:collapseAll
do -- Tree_View:collapseAll
  local tree = new_example_image_widget():newTreeView({label="root"})
  tree:collapseAll()
end

--@api-stub: Tree_View:setSelectedNode
do -- Tree_View:setSelectedNode
  local tree = new_example_image_widget():newTreeView({label="root"})
  tree:setSelectedNode(true)
end

--@api-stub: Tree_View:getSelectedNode
do -- Tree_View:getSelectedNode
  local tree = new_example_image_widget():newTreeView({label="root"})
  local v = tree:getSelectedNode()
  print("getSelectedNode:", v)
end

--@api-stub: Tree_View:getChildNodes
do -- Tree_View:getChildNodes
  local tree = new_example_image_widget():newTreeView({label="root"})
  local v = tree:getChildNodes()
  print("getChildNodes:", v)
end

--@api-stub: Tree_View:getParentNode
do -- Tree_View:getParentNode
  local tree = new_example_image_widget():newTreeView({label="root"})
  local v = tree:getParentNode()
  print("getParentNode:", v)
end

--@api-stub: Tree_View:getNodeDepth
do -- Tree_View:getNodeDepth
  local tree = new_example_image_widget():newTreeView({label="root"})
  local v = tree:getNodeDepth()
  print("getNodeDepth:", v)
end

-- â”€â”€ Radio_Button methods â”€â”€

--@api-stub: Radio_Button:getText
do -- Radio_Button:getText
  local rb = new_example_image_widget():newRadioButton("rb_easy","Easy","diff")
  local v = rb:getText()
  print("getText:", v)
end

--@api-stub: Radio_Button:setText
do -- Radio_Button:setText
  local rb = new_example_image_widget():newRadioButton("rb_easy","Easy","diff")
  rb:setText("Hello")
end

--@api-stub: Radio_Button:isSelected
do -- Radio_Button:isSelected
  local rb = new_example_image_widget():newRadioButton("rb_easy","Easy","diff")
  local v = rb:isSelected()
  print("isSelected:", v)
end

--@api-stub: Radio_Button:setSelected
do -- Radio_Button:setSelected
  local rb = new_example_image_widget():newRadioButton("rb_easy","Easy","diff")
  rb:setSelected(true)
end

--@api-stub: Radio_Button:getGroup
do -- Radio_Button:getGroup
  local rb = new_example_image_widget():newRadioButton("rb_easy","Easy","diff")
  local v = rb:getGroup()
  print("getGroup:", v)
end

--@api-stub: Radio_Button:setGroup
do -- Radio_Button:setGroup
  local rb = new_example_image_widget():newRadioButton("rb_easy","Easy","diff")
  rb:setGroup(1)
end

--@api-stub: Radio_Button:setOnChange
do -- Radio_Button:setOnChange
  local rb = new_example_image_widget():newRadioButton("rb_easy","Easy","diff")
  rb:setOnChange(function() print("event") end)
end

-- â”€â”€ Scroll_Bar methods â”€â”€

--@api-stub: Scroll_Bar:getScrollPosition
do -- Scroll_Bar:getScrollPosition
  local sb = new_example_image_widget():newScrollBar("vertical", 0, 100)
  local v = sb:getScrollPosition()
  print("getScrollPosition:", v)
end

--@api-stub: Scroll_Bar:setScrollPosition
do -- Scroll_Bar:setScrollPosition
  local sb = new_example_image_widget():newScrollBar("vertical", 0, 100)
  sb:setScrollPosition(100, 200)
end

--@api-stub: Scroll_Bar:getContentSize
do -- Scroll_Bar:getContentSize
  local sb = new_example_image_widget():newScrollBar("vertical", 0, 100)
  local v = sb:getContentSize()
  print("getContentSize:", v)
end

--@api-stub: Scroll_Bar:setContentSize
do -- Scroll_Bar:setContentSize
  local sb = new_example_image_widget():newScrollBar("vertical", 0, 100)
  sb:setContentSize(200, 50)
end

--@api-stub: Scroll_Bar:getViewSize
do -- Scroll_Bar:getViewSize
  local sb = new_example_image_widget():newScrollBar("vertical", 0, 100)
  local v = sb:getViewSize()
  print("getViewSize:", v)
end

--@api-stub: Scroll_Bar:setViewSize
do -- Scroll_Bar:setViewSize
  local sb = new_example_image_widget():newScrollBar("vertical", 0, 100)
  sb:setViewSize(200, 50)
end

--@api-stub: Scroll_Bar:isVertical
do -- Scroll_Bar:isVertical
  local sb = new_example_image_widget():newScrollBar("vertical", 0, 100)
  local v = sb:isVertical()
  print("isVertical:", v)
end

--@api-stub: Scroll_Bar:setOnChange
do -- Scroll_Bar:setOnChange
  local sb = new_example_image_widget():newScrollBar("vertical", 0, 100)
  sb:setOnChange(function() print("event") end)
end

-- â”€â”€ Gui_Window methods â”€â”€

--@api-stub: Gui_Window:getTitle
do -- Gui_Window:getTitle
  local w = new_example_image_widget():newPanel()
  local v = w:getTitle()
  print("getTitle:", v)
end

--@api-stub: Gui_Window:setTitle
do -- Gui_Window:setTitle
  local w = new_example_image_widget():newPanel()
  w:setTitle("Hello")
end

--@api-stub: Gui_Window:isCloseable
do -- Gui_Window:isCloseable
  local w = new_example_image_widget():newPanel()
  local v = w:isCloseable()
  print("isCloseable:", v)
end

--@api-stub: Gui_Window:setCloseable
do -- Gui_Window:setCloseable
  local w = new_example_image_widget():newPanel()
  w:setCloseable(1)
end

--@api-stub: Gui_Window:isDraggable
do -- Gui_Window:isDraggable
  local w = new_example_image_widget():newPanel()
  local v = w:isDraggable()
  print("isDraggable:", v)
end

--@api-stub: Gui_Window:setDraggable
do -- Gui_Window:setDraggable
  local w = new_example_image_widget():newPanel()
  w:setDraggable(1)
end

--@api-stub: Gui_Window:isResizable
do -- Gui_Window:isResizable
  local w = new_example_image_widget():newPanel()
  local v = w:isResizable()
  print("isResizable:", v)
end

--@api-stub: Gui_Window:setResizable
do -- Gui_Window:setResizable
  local w = new_example_image_widget():newPanel()
  w:setResizable(true)
end

--@api-stub: Gui_Window:setOnClose
do -- Gui_Window:setOnClose
  local w = new_example_image_widget():newPanel()
  w:setOnClose(function() print("event") end)
end

-- â”€â”€ Split_Panel methods â”€â”€

--@api-stub: Split_Panel:getOrientation
do -- Split_Panel:getOrientation
  local split = new_example_image_widget():newSplitPanel("horizontal", 0.5)
  local v = split:getOrientation()
  print("getOrientation:", v)
end

--@api-stub: Split_Panel:setOrientation
do -- Split_Panel:setOrientation
  local split = new_example_image_widget():newSplitPanel("horizontal", 0.5)
  split:setOrientation("horizontal")
end

--@api-stub: Split_Panel:getSplitPosition
do -- Split_Panel:getSplitPosition
  local split = new_example_image_widget():newSplitPanel("horizontal", 0.5)
  local v = split:getSplitPosition()
  print("getSplitPosition:", v)
end

--@api-stub: Split_Panel:setSplitPosition
do -- Split_Panel:setSplitPosition
  local split = new_example_image_widget():newSplitPanel("horizontal", 0.5)
  split:setSplitPosition(100, 200)
end

--@api-stub: Split_Panel:getMinPanelSize
do -- Split_Panel:getMinPanelSize
  local split = new_example_image_widget():newSplitPanel("horizontal", 0.5)
  local v = split:getMinPanelSize()
  print("getMinPanelSize:", v)
end

--@api-stub: Split_Panel:setMinPanelSize
do -- Split_Panel:setMinPanelSize
  local split = new_example_image_widget():newSplitPanel("horizontal", 0.5)
  split:setMinPanelSize(200, 50)
end

--@api-stub: Split_Panel:setFirstChild
do -- Split_Panel:setFirstChild
  local split = new_example_image_widget():newSplitPanel("horizontal", 0.5)
  split:setFirstChild(1)
end

--@api-stub: Split_Panel:setSecondChild
do -- Split_Panel:setSecondChild
  local split = new_example_image_widget():newSplitPanel("horizontal", 0.5)
  split:setSecondChild(function() print("event") end)
end

--@api-stub: Split_Panel:getFirstChild
do -- Split_Panel:getFirstChild
  local split = new_example_image_widget():newSplitPanel("horizontal", 0.5)
  local v = split:getFirstChild()
  print("getFirstChild:", v)
end

--@api-stub: Split_Panel:getSecondChild
do -- Split_Panel:getSecondChild
  local split = new_example_image_widget():newSplitPanel("horizontal", 0.5)
  local v = split:getSecondChild()
  print("getSecondChild:", v)
end

-- â”€â”€ Dock_Panel methods â”€â”€

--@api-stub: Dock_Panel:dock
do -- Dock_Panel:dock
  local dock = new_example_image_widget():newDockPanel()
  dock:dock()
end

--@api-stub: Dock_Panel:undock
do -- Dock_Panel:undock
  local dock = new_example_image_widget():newDockPanel()
  dock:undock()
end

--@api-stub: Dock_Panel:getDockedCount
do -- Dock_Panel:getDockedCount
  local dock = new_example_image_widget():newDockPanel()
  local v = dock:getDockedCount()
  print("getDockedCount:", v)
end

--@api-stub: Dock_Panel:setSplitSize
do -- Dock_Panel:setSplitSize
  local dock = new_example_image_widget():newDockPanel()
  dock:setSplitSize(200, 50)
end

--@api-stub: Dock_Panel:getSplitSize
do -- Dock_Panel:getSplitSize
  local dock = new_example_image_widget():newDockPanel()
  local v = dock:getSplitSize()
  print("getSplitSize:", v)
end

-- â”€â”€ Toolbar methods â”€â”€

--@api-stub: Toolbar:getOrientation
do -- Toolbar:getOrientation
  local tb = new_example_image_widget():newToolbar()
  local v = tb:getOrientation()
  print("getOrientation:", v)
end

--@api-stub: Toolbar:setOrientation
do -- Toolbar:setOrientation
  local tb = new_example_image_widget():newToolbar()
  tb:setOrientation("horizontal")
end

--@api-stub: Toolbar:addButton
do -- Toolbar:addButton
  local tb = new_example_image_widget():newToolbar()
  tb:addButton(1)
end

--@api-stub: Toolbar:addSeparator
do -- Toolbar:addSeparator
  local tb = new_example_image_widget():newToolbar()
  tb:addSeparator(1)
end

--@api-stub: Toolbar:addSpacer
do -- Toolbar:addSpacer
  local tb = new_example_image_widget():newToolbar()
  tb:addSpacer(1)
end

--@api-stub: Toolbar:getButton
do -- Toolbar:getButton
  local tb = new_example_image_widget():newToolbar()
  local v = tb:getButton()
  print("getButton:", v)
end

--@api-stub: Toolbar:setButtonEnabled
do -- Toolbar:setButtonEnabled
  local tb = new_example_image_widget():newToolbar()
  tb:setButtonEnabled(true)
end

--@api-stub: Toolbar:setButtonToggled
do -- Toolbar:setButtonToggled
  local tb = new_example_image_widget():newToolbar()
  tb:setButtonToggled(function() print("event") end)
end

--@api-stub: Toolbar:isButtonToggled
do -- Toolbar:isButtonToggled
  local tb = new_example_image_widget():newToolbar()
  local v = tb:isButtonToggled()
  print("isButtonToggled:", v)
end

-- â”€â”€ Menu_Bar methods â”€â”€

--@api-stub: Menu_Bar:addMenu
do -- Menu_Bar:addMenu
  local mb = new_example_image_widget():newMenuBar()
  local child = new_example_image_widget():newButton("child_1", "Child")
  mb:addMenu(child)
end

--@api-stub: Menu_Bar:removeMenu
do -- Menu_Bar:removeMenu
  local mb = new_example_image_widget():newMenuBar()
  mb:removeMenu()
end

--@api-stub: Menu_Bar:getMenus
do -- Menu_Bar:getMenus
  local mb = new_example_image_widget():newMenuBar()
  local v = mb:getMenus()
  print("getMenus:", v)
end

--@api-stub: Menu_Bar:getMenuCount
do -- Menu_Bar:getMenuCount
  local mb = new_example_image_widget():newMenuBar()
  local v = mb:getMenuCount()
  print("getMenuCount:", v)
end

-- â”€â”€ Menu_Item methods â”€â”€

--@api-stub: Menu_Item:getText
do -- Menu_Item:getText
  local mi = new_example_image_widget():newMenuItem("New Game")
  local v = mi:getText()
  print("getText:", v)
end

--@api-stub: Menu_Item:setText
do -- Menu_Item:setText
  local mi = new_example_image_widget():newMenuItem("New Game")
  mi:setText("Hello")
end

--@api-stub: Menu_Item:getShortcut
do -- Menu_Item:getShortcut
  local mi = new_example_image_widget():newMenuItem("New Game")
  local v = mi:getShortcut()
  print("getShortcut:", v)
end

--@api-stub: Menu_Item:setShortcut
do -- Menu_Item:setShortcut
  local mi = new_example_image_widget():newMenuItem("New Game")
  mi:setShortcut(1)
end

--@api-stub: Menu_Item:isChecked
do -- Menu_Item:isChecked
  local mi = new_example_image_widget():newMenuItem("New Game")
  local v = mi:isChecked()
  print("isChecked:", v)
end

--@api-stub: Menu_Item:setChecked
do -- Menu_Item:setChecked
  local mi = new_example_image_widget():newMenuItem("New Game")
  mi:setChecked(true)
end

--@api-stub: Menu_Item:addSubItem
do -- Menu_Item:addSubItem
  local mi = new_example_image_widget():newMenuItem("New Game")
  mi:addSubItem("item_1")
end

--@api-stub: Menu_Item:getSubItems
do -- Menu_Item:getSubItems
  local mi = new_example_image_widget():newMenuItem("New Game")
  local v = mi:getSubItems()
  print("getSubItems:", v)
end

--@api-stub: Menu_Item:setOnClick
do -- Menu_Item:setOnClick
  local mi = new_example_image_widget():newMenuItem("New Game")
  mi:setOnClick(function() print("event") end)
end

-- â”€â”€ Dialog methods â”€â”€

--@api-stub: Dialog:getTitle
do -- Dialog:getTitle
  local dlg = new_example_image_widget():newDialog("dlg_quit", "Quit?")
  local v = dlg:getTitle()
  print("getTitle:", v)
end

--@api-stub: Dialog:setTitle
do -- Dialog:setTitle
  local dlg = new_example_image_widget():newDialog("dlg_quit", "Quit?")
  dlg:setTitle("Hello")
end

--@api-stub: Dialog:isModal
do -- Dialog:isModal
  local dlg = new_example_image_widget():newDialog("dlg_quit", "Quit?")
  local v = dlg:isModal()
  print("isModal:", v)
end

--@api-stub: Dialog:setModal
do -- Dialog:setModal
  local dlg = new_example_image_widget():newDialog("dlg_quit", "Quit?")
  dlg:setModal(true)
end

--@api-stub: Dialog:isOpen
do -- Dialog:isOpen
  local dlg = new_example_image_widget():newDialog("dlg_quit", "Quit?")
  local v = dlg:isOpen()
  print("isOpen:", v)
end

--@api-stub: Dialog:open
do -- Dialog:open
  local dlg = new_example_image_widget():newDialog("dlg_quit", "Quit?")
  dlg:open()
end

--@api-stub: Dialog:close
do -- Dialog:close
  local dlg = new_example_image_widget():newDialog("dlg_quit", "Quit?")
  dlg:close()
end

--@api-stub: Dialog:setOnClose
do -- Dialog:setOnClose
  local dlg = new_example_image_widget():newDialog("dlg_quit", "Quit?")
  dlg:setOnClose(function() print("event") end)
end

--@api-stub: Dialog:setContent
do -- Dialog:setContent
  local dlg = new_example_image_widget():newDialog("dlg_quit", "Quit?")
  dlg:setContent(function() print("event") end)
end

--@api-stub: Dialog:getContent
do -- Dialog:getContent
  local dlg = new_example_image_widget():newDialog("dlg_quit", "Quit?")
  local v = dlg:getContent()
  print("getContent:", v)
end

--@api-stub: Dialog:addButton
do -- Dialog:addButton
  local dlg = new_example_image_widget():newDialog("dlg_quit", "Quit?")
  dlg:addButton(1)
end

-- â”€â”€ Status_Bar methods â”€â”€

--@api-stub: Status_Bar:addSection
do -- Status_Bar:addSection
  local sb = new_example_image_widget():newStatusBar()
  sb:addSection(1)
end

--@api-stub: Status_Bar:setSectionText
do -- Status_Bar:setSectionText
  local sb = new_example_image_widget():newStatusBar()
  sb:setSectionText("Hello")
end

--@api-stub: Status_Bar:getSectionText
do -- Status_Bar:getSectionText
  local sb = new_example_image_widget():newStatusBar()
  local v = sb:getSectionText()
  print("getSectionText:", v)
end

--@api-stub: Status_Bar:getSectionCount
do -- Status_Bar:getSectionCount
  local sb = new_example_image_widget():newStatusBar()
  local v = sb:getSectionCount()
  print("getSectionCount:", v)
end

--@api-stub: Status_Bar:setSectionCount
do -- Status_Bar:setSectionCount
  local sb = new_example_image_widget():newStatusBar()
  sb:setSectionCount(4)
end

--@api-stub: Status_Bar:setSectionWidget
do -- Status_Bar:setSectionWidget
  local sb = new_example_image_widget():newStatusBar()
  sb:setSectionWidget("primary")
end

-- â”€â”€ Accordion methods â”€â”€

--@api-stub: Accordion:addSection
do -- Accordion:addSection
  local acc = new_example_image_widget():newAccordion()
  acc:addSection(1)
end

--@api-stub: Accordion:getSectionCount
do -- Accordion:getSectionCount
  local acc = new_example_image_widget():newAccordion()
  local v = acc:getSectionCount()
  print("getSectionCount:", v)
end

--@api-stub: Accordion:toggleSection
do -- Accordion:toggleSection
  local acc = new_example_image_widget():newAccordion()
  acc:toggleSection()
end

--@api-stub: Accordion:isSectionExpanded
do -- Accordion:isSectionExpanded
  local acc = new_example_image_widget():newAccordion()
  local v = acc:isSectionExpanded()
  print("isSectionExpanded:", v)
end

--@api-stub: Accordion:isExclusive
do -- Accordion:isExclusive
  local acc = new_example_image_widget():newAccordion()
  local v = acc:isExclusive()
  print("isExclusive:", v)
end

--@api-stub: Accordion:setExclusive
do -- Accordion:setExclusive
  local acc = new_example_image_widget():newAccordion()
  acc:setExclusive(1)
end

--@api-stub: Accordion:getSectionTitle
do -- Accordion:getSectionTitle
  local acc = new_example_image_widget():newAccordion()
  local v = acc:getSectionTitle()
  print("getSectionTitle:", v)
end

-- â”€â”€ Tooltip_Panel methods â”€â”€

--@api-stub: Tooltip_Panel:getText
do -- Tooltip_Panel:getText
  local tip = new_example_image_widget():newTooltipPanel("Click to attack")
  local v = tip:getText()
  print("getText:", v)
end

--@api-stub: Tooltip_Panel:setText
do -- Tooltip_Panel:setText
  local tip = new_example_image_widget():newTooltipPanel("Click to attack")
  tip:setText("Hello")
end

--@api-stub: Tooltip_Panel:getDelay
do -- Tooltip_Panel:getDelay
  local tip = new_example_image_widget():newTooltipPanel("Click to attack")
  local v = tip:getDelay()
  print("getDelay:", v)
end

--@api-stub: Tooltip_Panel:setDelay
do -- Tooltip_Panel:setDelay
  local tip = new_example_image_widget():newTooltipPanel("Click to attack")
  tip:setDelay(2.0)
end

--@api-stub: Tooltip_Panel:getTarget
do -- Tooltip_Panel:getTarget
  local tip = new_example_image_widget():newTooltipPanel("Click to attack")
  local v = tip:getTarget()
  print("getTarget:", v)
end

--@api-stub: Tooltip_Panel:setTarget
do -- Tooltip_Panel:setTarget
  local tip = new_example_image_widget():newTooltipPanel("Click to attack")
  tip:setTarget(1)
end

-- â”€â”€ Color_Picker methods â”€â”€

--@api-stub: Color_Picker:getColor
do -- Color_Picker:getColor
  local cp = new_example_image_widget():newColorPicker({1,0,0,1})
  local v = cp:getColor()
  print("getColor:", v)
end

--@api-stub: Color_Picker:setColor
do -- Color_Picker:setColor
  local cp = new_example_image_widget():newColorPicker({1,0,0,1})
  cp:setColor({0.2, 0.6, 1.0, 1.0})
end

--@api-stub: Color_Picker:getShowAlpha
do -- Color_Picker:getShowAlpha
  local cp = new_example_image_widget():newColorPicker({1,0,0,1})
  local v = cp:getShowAlpha()
  print("getShowAlpha:", v)
end

--@api-stub: Color_Picker:setShowAlpha
do -- Color_Picker:setShowAlpha
  local cp = new_example_image_widget():newColorPicker({1,0,0,1})
  cp:setShowAlpha(0.85)
end

--@api-stub: Color_Picker:getColorMode
do -- Color_Picker:getColorMode
  local cp = new_example_image_widget():newColorPicker({1,0,0,1})
  local v = cp:getColorMode()
  print("getColorMode:", v)
end

--@api-stub: Color_Picker:setColorMode
do -- Color_Picker:setColorMode
  local cp = new_example_image_widget():newColorPicker({1,0,0,1})
  cp:setColorMode({0.2, 0.6, 1.0, 1.0})
end

--@api-stub: Color_Picker:setOnChange
do -- Color_Picker:setOnChange
  local cp = new_example_image_widget():newColorPicker({1,0,0,1})
  cp:setOnChange(function() print("event") end)
end

-- â”€â”€ Gui_Table methods â”€â”€

--@api-stub: Gui_Table:addColumn
do -- Gui_Table:addColumn
  local tbl = new_example_image_widget():newTable({"Name","Score"})
  tbl:addColumn("item_1")
end

--@api-stub: Gui_Table:getColumnCount
do -- Gui_Table:getColumnCount
  local tbl = new_example_image_widget():newTable({"Name","Score"})
  local v = tbl:getColumnCount()
  print("getColumnCount:", v)
end

--@api-stub: Gui_Table:addRow
do -- Gui_Table:addRow
  local tbl = new_example_image_widget():newTable({"Name","Score"})
  tbl:addRow("item_1")
end

--@api-stub: Gui_Table:getRowCount
do -- Gui_Table:getRowCount
  local tbl = new_example_image_widget():newTable({"Name","Score"})
  local v = tbl:getRowCount()
  print("getRowCount:", v)
end

--@api-stub: Gui_Table:getCell
do -- Gui_Table:getCell
  local tbl = new_example_image_widget():newTable({"Name","Score"})
  local v = tbl:getCell()
  print("getCell:", v)
end

--@api-stub: Gui_Table:setCell
do -- Gui_Table:setCell
  local tbl = new_example_image_widget():newTable({"Name","Score"})
  tbl:setCell(1)
end

--@api-stub: Gui_Table:getSelectedRow
do -- Gui_Table:getSelectedRow
  local tbl = new_example_image_widget():newTable({"Name","Score"})
  local v = tbl:getSelectedRow()
  print("getSelectedRow:", v)
end

--@api-stub: Gui_Table:setSelectedRow
do -- Gui_Table:setSelectedRow
  local tbl = new_example_image_widget():newTable({"Name","Score"})
  tbl:setSelectedRow(true)
end

--@api-stub: Gui_Table:isSortable
do -- Gui_Table:isSortable
  local tbl = new_example_image_widget():newTable({"Name","Score"})
  local v = tbl:isSortable()
  print("isSortable:", v)
end

--@api-stub: Gui_Table:setSortable
do -- Gui_Table:setSortable
  local tbl = new_example_image_widget():newTable({"Name","Score"})
  tbl:setSortable(1)
end

--@api-stub: Gui_Table:setOnSelect
do -- Gui_Table:setOnSelect
  local tbl = new_example_image_widget():newTable({"Name","Score"})
  tbl:setOnSelect(function() print("event") end)
end

-- â”€â”€ Image_Widget methods â”€â”€

--@api-stub: Image_Widget:getScaleMode
do -- Image_Widget:getScaleMode
  local img = new_example_image_widget()
  local v = img:getScaleMode()
  print("getScaleMode:", v)
end

--@api-stub: Image_Widget:setScaleMode
do -- Image_Widget:setScaleMode
  local img = new_example_image_widget()
  img:setScaleMode(1.5)
end

--@api-stub: Image_Widget:getTint
do -- Image_Widget:getTint
  local img = new_example_image_widget()
  local v = img:getTint()
  print("getTint:", v)
end

--@api-stub: Image_Widget:setTint
do -- Image_Widget:setTint
  local img = new_example_image_widget()
  img:setTint({0.2, 0.6, 1.0, 1.0})
end

--@api-stub: Image_Widget:newButton
do -- Image_Widget:newButton
  local img = new_example_image_widget()
  img:newButton()
end

--@api-stub: Image_Widget:newLabel
do -- Image_Widget:newLabel
  local img = new_example_image_widget()
  img:newLabel()
end

--@api-stub: Image_Widget:newTextInput
do -- Image_Widget:newTextInput
  local img = new_example_image_widget()
  img:newTextInput()
end

--@api-stub: Image_Widget:newCheckbox
do -- Image_Widget:newCheckbox
  local img = new_example_image_widget()
  img:newCheckbox()
end

--@api-stub: Image_Widget:newSlider
do -- Image_Widget:newSlider
  local img = new_example_image_widget()
  img:newSlider()
end

--@api-stub: Image_Widget:newProgressBar
do -- Image_Widget:newProgressBar
  local img = new_example_image_widget()
  img:newProgressBar()
end

--@api-stub: Image_Widget:newComboBox
do -- Image_Widget:newComboBox
  local img = new_example_image_widget()
  img:newComboBox()
end

--@api-stub: Image_Widget:newList
do -- Image_Widget:newList
  local img = new_example_image_widget()
  img:newList()
end

--@api-stub: Image_Widget:newPanel
do -- Image_Widget:newPanel
  local img = new_example_image_widget()
  img:newPanel()
end

--@api-stub: Image_Widget:newLayout
do -- Image_Widget:newLayout
  local img = new_example_image_widget()
  img:newLayout()
end

--@api-stub: Image_Widget:newScrollPanel
do -- Image_Widget:newScrollPanel
  local img = new_example_image_widget()
  img:newScrollPanel()
end

--@api-stub: Image_Widget:newNinePatch
do -- Image_Widget:newNinePatch
  local img = new_example_image_widget()
  img:newNinePatch()
end

--@api-stub: Image_Widget:newTabBar
do -- Image_Widget:newTabBar
  local img = new_example_image_widget()
  img:newTabBar()
end

--@api-stub: Image_Widget:newSeparator
do -- Image_Widget:newSeparator
  local img = new_example_image_widget()
  img:newSeparator()
end

--@api-stub: Image_Widget:newSpacer
do -- Image_Widget:newSpacer
  local img = new_example_image_widget()
  img:newSpacer()
end

--@api-stub: Image_Widget:newToast
do -- Image_Widget:newToast
  local img = new_example_image_widget()
  img:newToast()
end

--@api-stub: Image_Widget:newTreeView
do -- Image_Widget:newTreeView
  local img = new_example_image_widget()
  img:newTreeView()
end

--@api-stub: Image_Widget:newRadioButton
do -- Image_Widget:newRadioButton
  local img = new_example_image_widget()
  img:newRadioButton()
end

--@api-stub: Image_Widget:newScrollBar
do -- Image_Widget:newScrollBar
  local img = new_example_image_widget()
  img:newScrollBar()
end

--@api-stub: Image_Widget:newWindow
do -- Image_Widget:newWindow
  local img = new_example_image_widget()
  img:newWindow()
end

--@api-stub: Image_Widget:newSplitPanel
do -- Image_Widget:newSplitPanel
  local img = new_example_image_widget()
  img:newSplitPanel()
end

--@api-stub: Image_Widget:newDockPanel
do -- Image_Widget:newDockPanel
  local img = new_example_image_widget()
  img:newDockPanel()
end

--@api-stub: Image_Widget:newToolbar
do -- Image_Widget:newToolbar
  local img = new_example_image_widget()
  img:newToolbar()
end

--@api-stub: Image_Widget:newMenuBar
do -- Image_Widget:newMenuBar
  local img = new_example_image_widget()
  img:newMenuBar()
end

--@api-stub: Image_Widget:newMenuItem
do -- Image_Widget:newMenuItem
  local img = new_example_image_widget()
  img:newMenuItem()
end

--@api-stub: Image_Widget:newDialog
do -- Image_Widget:newDialog
  local img = new_example_image_widget()
  img:newDialog()
end

--@api-stub: Image_Widget:newStatusBar
do -- Image_Widget:newStatusBar
  local img = new_example_image_widget()
  img:newStatusBar()
end

--@api-stub: Image_Widget:newAccordion
do -- Image_Widget:newAccordion
  local img = new_example_image_widget()
  img:newAccordion()
end

--@api-stub: Image_Widget:newTooltipPanel
do -- Image_Widget:newTooltipPanel
  local img = new_example_image_widget()
  img:newTooltipPanel()
end

--@api-stub: Image_Widget:newColorPicker
do -- Image_Widget:newColorPicker
  local img = new_example_image_widget()
  img:newColorPicker()
end

--@api-stub: Image_Widget:newTable
do -- Image_Widget:newTable
  local img = new_example_image_widget()
  img:newTable()
end

--@api-stub: Image_Widget:newImageWidget
do -- Image_Widget:newImageWidget
  local img = new_example_image_widget()
  img:newImageWidget()
end

--@api-stub: Image_Widget:newTheme
do -- Image_Widget:newTheme
  local img = new_example_image_widget()
  img:newTheme()
end

--@api-stub: Image_Widget:setTheme
do -- Image_Widget:setTheme
  local img = new_example_image_widget()
  img:setTheme("dark")
end

--@api-stub: Image_Widget:getTheme
do -- Image_Widget:getTheme
  local img = new_example_image_widget()
  local v = img:getTheme()
  print("getTheme:", v)
end

--@api-stub: Image_Widget:getRoot
do -- Image_Widget:getRoot
  local img = new_example_image_widget()
  local v = img:getRoot()
  print("getRoot:", v)
end

--@api-stub: Image_Widget:setFocus
do -- Image_Widget:setFocus
  local img = new_example_image_widget()
  img:setFocus(1)
end

--@api-stub: Image_Widget:getFocus
do -- Image_Widget:getFocus
  local img = new_example_image_widget()
  local v = img:getFocus()
  print("getFocus:", v)
end

--@api-stub: Image_Widget:focusNext
do -- Image_Widget:focusNext
  local img = new_example_image_widget()
  img:focusNext()
end

--@api-stub: Image_Widget:focusPrev
do -- Image_Widget:focusPrev
  local img = new_example_image_widget()
  img:focusPrev()
end

--@api-stub: Image_Widget:clearFocus
do -- Image_Widget:clearFocus
  local img = new_example_image_widget()
  img:clearFocus()
end

--@api-stub: Image_Widget:addToast
do -- Image_Widget:addToast
  local img = new_example_image_widget()
  img:addToast(1)
end

--@api-stub: Image_Widget:getToastCount
do -- Image_Widget:getToastCount
  local img = new_example_image_widget()
  local v = img:getToastCount()
  print("getToastCount:", v)
end

--@api-stub: Image_Widget:mousepressed
do -- Image_Widget:mousepressed
  local img = new_example_image_widget()
  img:mousepressed()
end

--@api-stub: Image_Widget:mousereleased
do -- Image_Widget:mousereleased
  local img = new_example_image_widget()
  img:mousereleased()
end

--@api-stub: Image_Widget:mousemoved
do -- Image_Widget:mousemoved
  local img = new_example_image_widget()
  img:mousemoved()
end
--@api-stub: Image_Widget:keypressed
do -- Image_Widget:keypressed
  local img = new_example_image_widget()
  img:keypressed()
end

--@api-stub: Image_Widget:textinput
do -- Image_Widget:textinput
  local img = new_example_image_widget()
  img:textinput()
end

--@api-stub: Image_Widget:wheelmoved
do -- Image_Widget:wheelmoved
  local img = new_example_image_widget()
  img:wheelmoved()
end

--@api-stub: Image_Widget:update
do -- Image_Widget:update
  local img = new_example_image_widget()
  img:update()
end

--@api-stub: Image_Widget:draw
do -- Image_Widget:draw
  local img = new_example_image_widget()
  img:draw()
end

--@api-stub: Image_Widget:getWidgetCount
do -- Image_Widget:getWidgetCount
  local img = new_example_image_widget()
  local v = img:getWidgetCount()
  print("getWidgetCount:", v)
end

--@api-stub: Image_Widget:drawToImage
do -- Image_Widget:drawToImage
  local img = new_example_image_widget()
  img:drawToImage()
end

--@api-stub: Image_Widget:newLineChart
do -- Image_Widget:newLineChart
  local img = new_example_image_widget()
  img:newLineChart()
end

--@api-stub: Image_Widget:newBarChart
do -- Image_Widget:newBarChart
  local img = new_example_image_widget()
  img:newBarChart()
end

--@api-stub: Image_Widget:newScatterPlot
do -- Image_Widget:newScatterPlot
  local img = new_example_image_widget()
  img:newScatterPlot()
end

--@api-stub: Image_Widget:newPieChart
do -- Image_Widget:newPieChart
  local img = new_example_image_widget()
  img:newPieChart()
end

--@api-stub: Image_Widget:newAreaChart
do -- Image_Widget:newAreaChart
  local img = new_example_image_widget()
  img:newAreaChart()
end

--@api-stub: Image_Widget:parseWidgetState
do -- Image_Widget:parseWidgetState
  local img = new_example_image_widget()
  img:parseWidgetState()
end

--@api-stub: Image_Widget:newSpinBox
do -- Image_Widget:newSpinBox
  local img = new_example_image_widget()
  img:newSpinBox()
end

--@api-stub: Image_Widget:newSwitch
do -- Image_Widget:newSwitch
  local img = new_example_image_widget()
  img:newSwitch()
end

--@api-stub: Image_Widget:newBadge
do -- Image_Widget:newBadge
  local img = new_example_image_widget()
  img:newBadge()
end

--@api-stub: Image_Widget:setDefaultTheme
do -- Image_Widget:setDefaultTheme
  local img = new_example_image_widget()
  img:setDefaultTheme("dark")
end

--@api-stub: Image_Widget:setViewport
do -- Image_Widget:setViewport
  local img = new_example_image_widget()
  img:setViewport(1)
end

--@api-stub: Image_Widget:flushCache
do -- Image_Widget:flushCache
  local img = new_example_image_widget()
  img:flushCache()
end

--@api-stub: Image_Widget:update_bindings
do -- Image_Widget:update_bindings
  local img = new_example_image_widget()
  img:update_bindings()
end

--@api-stub: Image_Widget:loadLayout
do -- Image_Widget:loadLayout
  local img = new_example_image_widget()
  img:loadLayout()
end

--@api-stub: Image_Widget:loadLayoutFile
do -- Image_Widget:loadLayoutFile
  local img = new_example_image_widget()
  img:loadLayoutFile()
end

--@api-stub: Image_Widget:renderToImage
do -- Image_Widget:renderToImage
  local img = new_example_image_widget()
  img:renderToImage()
end

-- â”€â”€ LineChart methods â”€â”€

--@api-stub: LineChart:setYMax
do -- LineChart:setYMax
  local chart = new_example_image_widget():newLineChart({0.1,0.3,0.5,0.7})
  chart:setYMax(100)
end

--@api-stub: LineChart:setXMax
do -- LineChart:setXMax
  local chart = new_example_image_widget():newLineChart({0.1,0.3,0.5,0.7})
  chart:setXMax(100)
end

--@api-stub: LineChart:drawToImage
do -- LineChart:drawToImage
  local chart = new_example_image_widget():newLineChart({0.1,0.3,0.5,0.7})
  chart:drawToImage()
end

-- â”€â”€ BarChart methods â”€â”€

--@api-stub: BarChart:drawToImage
do -- BarChart:drawToImage
  local w = new_example_image_widget():newPanel()
  w:drawToImage()
end

-- â”€â”€ ScatterPlot methods â”€â”€

--@api-stub: ScatterPlot:setXRange
do -- ScatterPlot:setXRange
  local plot = new_example_image_widget():newScatterPlot({{1,2},{3,4},{5,6}})
  plot:setXRange(1)
end

--@api-stub: ScatterPlot:setYRange
do -- ScatterPlot:setYRange
  local plot = new_example_image_widget():newScatterPlot({{1,2},{3,4},{5,6}})
  plot:setYRange(1)
end

--@api-stub: ScatterPlot:drawToImage
do -- ScatterPlot:drawToImage
  local plot = new_example_image_widget():newScatterPlot({{1,2},{3,4},{5,6}})
  plot:drawToImage()
end

-- â”€â”€ PieChart methods â”€â”€

--@api-stub: PieChart:drawToImage
do -- PieChart:drawToImage
  local chart = new_example_image_widget():newPieChart({{label="HP",value=70}})
  chart:drawToImage()
end

-- â”€â”€ AreaChart methods â”€â”€

--@api-stub: AreaChart:setYMax
do -- AreaChart:setYMax
  local w = new_example_image_widget():newPanel()
  w:setYMax(100)
end

--@api-stub: AreaChart:drawToImage
do -- AreaChart:drawToImage
  local w = new_example_image_widget():newPanel()
  w:drawToImage()
end

-- â”€â”€ Custom widget extensibility â”€â”€

--@api-stub: Image_Widget:newCustomWidget
do -- Image_Widget:newCustomWidget
  local widget = new_example_image_widget():newCustomWidget({
    x = 50, y = 50, width = 300, height = 200, id = "health_bar",
  })
  if widget and widget.setOnDraw then
    widget:setOnDraw(function(rect)
      local health = 0.75
      -- Draw background
      lurek.render.setColor(0.2, 0.2, 0.2, 1)
        lurek.render.rectangle("fill", rect.x, rect.y, rect.w, rect.h)
      -- Draw health fill
      lurek.render.setColor(0, 1, 0, 1)
        lurek.render.rectangle("fill", rect.x, rect.y, rect.w * health, rect.h)
      -- Draw label
      lurek.render.setColor(1, 1, 1, 1)
      lurek.render.print("HP: 75%", rect.x + 4, rect.y + 4)
    end)
  end
  print("newCustomWidget: ok")
end


--@api-stub: BarChart:addCategory
do -- BarChart:addCategory
  lurek.log.info("BarChart:addCategory usage: chart:addCategory('Jan')", "ui")
  local bc = new_example_image_widget():newBarChart(200, 100)
  bc:addCategory("Jan")
  bc:addCategory("Feb")
  lurek.log.info("categories added", "ui")
end

--@api-stub: AreaChart:addLayer
do -- AreaChart:addLayer
  local ac = new_example_image_widget():newAreaChart(300, 150)
  ac:addLayer("series_a", {1,0.3,0.3,0.7}, {10,20,15,30,25})
  ac:addLayer("series_b", {0.3,0.6,1,0.7}, {5,10,8,14,12})
  lurek.log.info("area layers added", "ui")
end

--@api-stub: PieChart:addSegment
do -- PieChart:addSegment
  local pc = new_example_image_widget():newPieChart(150, 150)
  pc:addSegment("Wheat",  40, {0.9, 0.8, 0.3, 1})
  pc:addSegment("Sheep",  25, {0.8, 0.9, 0.5, 1})
  pc:addSegment("Forest", 35, {0.2, 0.7, 0.3, 1})
  lurek.log.info("pie segments added", "ui")
end

--@api-stub: LineChart:addSeries
do -- LineChart:addSeries
  local lc = new_example_image_widget():newLineChart(300, 150)
  lc:addSeries("revenue", {0.2, 0.8, 0.4, 1}, {10, 20, 15, 35, 30})
  lc:addSeries("cost",    {0.9, 0.3, 0.2, 1}, {8,  12, 10, 18, 20})
  lurek.log.info("line series added", "ui")
end

--@api-stub: BarChart:addSeries
do -- BarChart:addSeries
  local bc = new_example_image_widget():newBarChart(300, 150)
  bc:addCategory("Q1"); bc:addCategory("Q2")
  bc:addSeries("sales",   {0.2, 0.6, 0.9, 1}, {120, 180})
  bc:addSeries("returns", {0.9, 0.3, 0.2, 1}, {10,  15})
  lurek.log.info("bar series added", "ui")
end

--@api-stub: ScatterPlot:addSeries
do -- ScatterPlot:addSeries
  local sp = new_example_image_widget():newScatterPlot(200, 200)
  sp:addSeries("players", {0.2, 0.7, 1, 1}, {10,20, 30,40, 50,35, 70,55})
  sp:setXRange(0, 100); sp:setYRange(0, 80)
  lurek.log.info("scatter series added", "ui")
end

--@api-stub: Theme:setStyle
do -- Theme:setStyle
  local theme = new_example_image_widget():newTheme()
  theme:setStyle("button.background", {0.2, 0.4, 0.8, 1})
  theme:setStyle("button.text_color",  {1, 1, 1, 1})
  lurek.log.info("theme styles set", "ui")
end

-- =============================================================================
-- COVERAGE: 12 uncovered lurek.ui API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================



-- LineChart methods


--@api-stub: LineChart:type
do -- LineChart:type
  local chart = new_example_image_widget():newLineChart({0.1,0.3,0.5,0.7})
    chart:setYMax(100)
  local t = chart:type()
  lurek.log.info("LineChart:type = " .. t, "ui")
end
--@api-stub: LineChart:typeOf
do -- LineChart:typeOf
  local chart = new_example_image_widget():newLineChart({0.1,0.3,0.5,0.7})
    chart:setYMax(100)
  lurek.log.info("is LineChart: " .. tostring(chart:typeOf("LineChart")), "ui")
  lurek.log.info("is wrong: " .. tostring(chart:typeOf("Unknown")), "ui")
end


-- LAreaChart methods


--@api-stub: LAreaChart:type -- Returns the type name of this object
do -- LAreaChart:type
  local w = new_example_image_widget():newPanel()
    w:setYMax(100)
  local t = w:type()
  lurek.log.info("LAreaChart:type = " .. t, "ui")
end
--@api-stub: LAreaChart:typeOf -- Checks whether this object matches the given type name
do -- LAreaChart:typeOf
  local w = new_example_image_widget():newPanel()
    w:setYMax(100)
  lurek.log.info("is LAreaChart: " .. tostring(w:typeOf("LAreaChart")), "ui")
  lurek.log.info("is wrong: " .. tostring(w:typeOf("Unknown")), "ui")
end
--@api-stub: LBarChart:type -- Returns the type name of this object
do -- LBarChart:type
  local w = new_example_image_widget():newPanel()
    w:drawToImage()
  local t = w:type()
  lurek.log.info("LBarChart:type = " .. t, "ui")
end
--@api-stub: LBarChart:typeOf -- Checks whether this object matches the given type name
do -- LBarChart:typeOf
  local w = new_example_image_widget():newPanel()
    w:drawToImage()
  lurek.log.info("is LBarChart: " .. tostring(w:typeOf("LBarChart")), "ui")
  lurek.log.info("is wrong: " .. tostring(w:typeOf("Unknown")), "ui")
end
--@api-stub: LLineChart:type -- Returns the type name of this object
do -- LLineChart:type
  local chart = lurek.ui.newLineChart({ width = 400, height = 300, title = "Sales" })
  local t = chart:type()
  lurek.log.info("LLineChart:type=" .. t, "ui")
end
--@api-stub: LLineChart:typeOf -- Checks whether this object matches the given type name
do -- LLineChart:typeOf
  local chart = lurek.ui.newLineChart({ width = 400, height = 300, title = "Revenue" })
  lurek.log.info("is LLineChart: " .. tostring(chart:typeOf("LLineChart")), "ui")
  lurek.log.info("is wrong: " .. tostring(chart:typeOf("Unknown")), "ui")
end
--@api-stub: LPieChart:type -- Returns the type name of this object
do -- LPieChart:type
  local chart = new_example_image_widget():newPieChart({{label="HP",value=70}})
    chart:drawToImage()
  local t = chart:type()
  lurek.log.info("LPieChart:type = " .. t, "ui")
end
--@api-stub: LPieChart:typeOf -- Checks whether this object matches the given type name
do -- LPieChart:typeOf
  local chart = new_example_image_widget():newPieChart({{label="HP",value=70}})
    chart:drawToImage()
  lurek.log.info("is LPieChart: " .. tostring(chart:typeOf("LPieChart")), "ui")
  lurek.log.info("is wrong: " .. tostring(chart:typeOf("Unknown")), "ui")
end
--@api-stub: LScatterPlot:type -- Returns the type name of this object
do -- LScatterPlot:type
  local plot = new_example_image_widget():newScatterPlot({{1,2},{3,4},{5,6}})
    plot:setXRange(1)
  local t = plot:type()
  lurek.log.info("LScatterPlot:type = " .. t, "ui")
end
--@api-stub: LScatterPlot:typeOf -- Checks whether this object matches the given type name
do -- LScatterPlot:typeOf
  local plot = new_example_image_widget():newScatterPlot({{1,2},{3,4},{5,6}})
    plot:setXRange(1)
  lurek.log.info("is LScatterPlot: " .. tostring(plot:typeOf("LScatterPlot")), "ui")
  lurek.log.info("is wrong: " .. tostring(plot:typeOf("Unknown")), "ui")
end
--@api-stub: LTheme:type -- Returns the type name of this object
do -- LTheme:type
  local theme = new_example_image_widget():newTheme()
    theme:setStyle("button.background", {0.2, 0.4, 0.8, 1})
    theme:setStyle("button.text_color",  {1, 1, 1, 1})
  local t = theme:type()
  lurek.log.info("LTheme:type = " .. t, "ui")
end
--@api-stub: LTheme:typeOf -- Checks whether this object matches the given type name
do -- LTheme:typeOf
  local theme = new_example_image_widget():newTheme()
    theme:setStyle("button.background", {0.2, 0.4, 0.8, 1})
    theme:setStyle("button.text_color",  {1, 1, 1, 1})
  lurek.log.info("is LTheme: " .. tostring(theme:typeOf("LTheme")), "ui")
  lurek.log.info("is wrong: " .. tostring(theme:typeOf("Unknown")), "ui")
end

--@api-stub: lurek.ui.type
do -- lurek.ui.type
  local chart = lurek.ui.newLineChart({ width = 200, height = 150, title = "FPS" })
  local t = chart:type()
  lurek.log.info("ui.type=" .. tostring(t), "ui")
end
--@api-stub: LLineChart:setYMax -- Sets the maximum Y-axis value for this line chart
do -- LLineChart:setYMax
  local chart = lurek.ui.newLineChart({ width = 400, height = 300, title = "Score" })
  chart:setYMax(1000)
  lurek.log.info("y-axis max set to 1000", "ui")
end
--@api-stub: LLineChart:setXMax -- Sets the maximum X-axis value for this line chart
do -- LLineChart:setXMax
  local chart = lurek.ui.newLineChart({ width = 400, height = 300, title = "FPS" })
  chart:setXMax(60)   -- fixed 60-second window
  lurek.log.info("x-axis max set to 60", "ui")
end
--@api-stub: LLineChart:drawToImage -- Renders this line chart to an image buffer
do -- LLineChart:drawToImage
  local chart = lurek.ui.newLineChart({ width = 256, height = 128, title = "Wave" })
  chart:setXMax(10)
  chart:setYMax(1.0)
  local idata = lurek.image.newImageData(256, 128)
  chart:drawToImage(idata)
  lurek.log.info("chart rendered to ImageData 256x128", "ui")
end

-- =============================================================================
-- COVERAGE: 352 uncovered lurek.ui API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================

--@api-stub: lurek.ui.newButton -- Creates a new button widget
do -- lurek.ui.newButton
  local btn = lurek.ui.newButton("Play")
  lurek.log.info("newButton: " .. tostring(btn), "ui")
end


--@api-stub: lurek.ui.newLabel -- Creates a new label widget
do -- lurek.ui.newLabel
  local lbl = lurek.ui.newLabel("Score: 0")
  lurek.log.info("newLabel: " .. tostring(lbl), "ui")
end


--@api-stub: lurek.ui.newTextInput -- Creates a new text input widget
do -- lurek.ui.newTextInput
  local input = lurek.ui.newTextInput()
  lurek.log.info("newTextInput: " .. tostring(input), "ui")
end


--@api-stub: lurek.ui.newCheckbox -- Creates a new checkbox widget
do -- lurek.ui.newCheckbox
  local cb = lurek.ui.newCheckbox("Enable music")
  lurek.log.info("newCheckbox: " .. tostring(cb), "ui")
end


--@api-stub: lurek.ui.newSlider -- Creates a new slider widget
do -- lurek.ui.newSlider
  local slider = lurek.ui.newSlider(0, 100)
  lurek.log.info("newSlider: " .. tostring(slider), "ui")
end


--@api-stub: lurek.ui.newProgressBar -- Creates a new progress bar widget
do -- lurek.ui.newProgressBar
  local bar = lurek.ui.newProgressBar(0, 100)
  lurek.log.info("newProgressBar: " .. tostring(bar), "ui")
end


--@api-stub: lurek.ui.newComboBox -- Creates a new combo box (drop-down) widget
do -- lurek.ui.newComboBox
  local combo = lurek.ui.newComboBox()
  lurek.log.info("newComboBox: " .. tostring(combo), "ui")
end


--@api-stub: lurek.ui.newList -- Creates a new list box widget
do -- lurek.ui.newList
  local list = lurek.ui.newList()
  lurek.log.info("newList: " .. tostring(list), "ui")
end


--@api-stub: lurek.ui.newPanel -- Creates a new panel widget (container)
do -- lurek.ui.newPanel
  local panel = lurek.ui.newPanel()
  lurek.log.info("newPanel: " .. tostring(panel), "ui")
end


--@api-stub: lurek.ui.newLayout -- Creates a new layout container widget
do -- lurek.ui.newLayout
  local layout = lurek.ui.newLayout("horizontal")
  lurek.log.info("newLayout: " .. tostring(layout), "ui")
end


--@api-stub: lurek.ui.newScrollPanel -- Creates a new scrollable panel widget
do -- lurek.ui.newScrollPanel
  local sp = lurek.ui.newScrollPanel()
  lurek.log.info("newScrollPanel: " .. tostring(sp), "ui")
end


--@api-stub: lurek.ui.newNinePatch -- Creates a new nine-patch widget for scalable bordered images
do -- lurek.ui.newNinePatch
  local np = lurek.ui.newNinePatch()
  lurek.log.info("newNinePatch: " .. tostring(np), "ui")
end


--@api-stub: lurek.ui.newTabBar -- Creates a new tab bar widget
do -- lurek.ui.newTabBar
  local tabs = lurek.ui.newTabBar()
  lurek.log.info("newTabBar: " .. tostring(tabs), "ui")
end


--@api-stub: lurek.ui.newSeparator -- Creates a new separator widget
do -- lurek.ui.newSeparator
  local sep = lurek.ui.newSeparator(false)
  lurek.log.info("newSeparator: " .. tostring(sep), "ui")
end


--@api-stub: lurek.ui.newSpacer -- Creates a new spacer widget for spacing between other widgets
do -- lurek.ui.newSpacer
  local spacer = lurek.ui.newSpacer(20, 10)
  lurek.log.info("newSpacer: " .. tostring(spacer), "ui")
end


--@api-stub: lurek.ui.newToast -- Creates a new toast notification widget
do -- lurek.ui.newToast
  local toast = lurek.ui.newToast("Item collected!", 3.0)
  lurek.log.info("newToast: " .. tostring(toast), "ui")
end


--@api-stub: lurek.ui.newTreeView -- Creates a new tree view widget
do -- lurek.ui.newTreeView
  local tree = lurek.ui.newTreeView()
  lurek.log.info("newTreeView: " .. tostring(tree), "ui")
end


--@api-stub: lurek.ui.newRadioButton -- Creates a new radio button widget
do -- lurek.ui.newRadioButton
  local rb = lurek.ui.newRadioButton("Easy", "difficulty")
  lurek.log.info("newRadioButton: " .. tostring(rb), "ui")
end


--@api-stub: lurek.ui.newScrollBar -- Creates a new scroll bar widget
do -- lurek.ui.newScrollBar
  local sb = lurek.ui.newScrollBar(true)
  lurek.log.info("newScrollBar: " .. tostring(sb), "ui")
end


--@api-stub: lurek.ui.newWindow -- Creates a new GUI window widget
do -- lurek.ui.newWindow
  local win = lurek.ui.newWindow("Inventory")
  lurek.log.info("newWindow: " .. tostring(win), "ui")
end


--@api-stub: lurek.ui.newSplitPanel -- Creates a new split panel widget with two resizable sub-panels
do -- lurek.ui.newSplitPanel
  local split = lurek.ui.newSplitPanel("vertical")
  lurek.log.info("newSplitPanel: " .. tostring(split), "ui")
end


--@api-stub: lurek.ui.newDockPanel -- Creates a new dock panel widget for docking child widgets to sides
do -- lurek.ui.newDockPanel
  local dock = lurek.ui.newDockPanel()
  lurek.log.info("newDockPanel: " .. tostring(dock), "ui")
end


--@api-stub: lurek.ui.newToolbar -- Creates a new toolbar widget
do -- lurek.ui.newToolbar
  local tb = lurek.ui.newToolbar("horizontal")
  lurek.log.info("newToolbar: " .. tostring(tb), "ui")
end


--@api-stub: lurek.ui.newMenuBar -- Creates a new menu bar widget
do -- lurek.ui.newMenuBar
  local mb = lurek.ui.newMenuBar()
  lurek.log.info("newMenuBar: " .. tostring(mb), "ui")
end


--@api-stub: lurek.ui.newMenuItem -- Creates a new menu item widget
do -- lurek.ui.newMenuItem
  local mi = lurek.ui.newMenuItem("File")
  lurek.log.info("newMenuItem: " .. tostring(mi), "ui")
end


--@api-stub: lurek.ui.newDialog -- Creates a new dialog widget
do -- lurek.ui.newDialog
  local dlg = lurek.ui.newDialog("Confirm Exit")
  lurek.log.info("newDialog: " .. tostring(dlg), "ui")
end


--@api-stub: lurek.ui.newStatusBar -- Creates a new status bar widget
do -- lurek.ui.newStatusBar
  local sbar = lurek.ui.newStatusBar()
  lurek.log.info("newStatusBar: " .. tostring(sbar), "ui")
end


--@api-stub: lurek.ui.newAccordion -- Creates a new accordion widget
do -- lurek.ui.newAccordion
  local acc = lurek.ui.newAccordion()
  lurek.log.info("newAccordion: " .. tostring(acc), "ui")
end


--@api-stub: lurek.ui.newTooltipPanel -- Creates a new tooltip panel widget
do -- lurek.ui.newTooltipPanel
  local tp = lurek.ui.newTooltipPanel("Hover info")
  lurek.log.info("newTooltipPanel: " .. tostring(tp), "ui")
end


--@api-stub: lurek.ui.newColorPicker -- Creates a new color picker widget
do -- lurek.ui.newColorPicker
  local cp = lurek.ui.newColorPicker()
  lurek.log.info("newColorPicker: " .. tostring(cp), "ui")
end


--@api-stub: lurek.ui.newTable -- Creates a new table widget for tabular data display
do -- lurek.ui.newTable
  local tbl = lurek.ui.newTable()
  lurek.log.info("newTable: " .. tostring(tbl), "ui")
end


--@api-stub: lurek.ui.newImageWidget -- Creates a new image display widget
do -- lurek.ui.newImageWidget
  local iw = lurek.ui.newImageWidget()
  lurek.log.info("newImageWidget: " .. tostring(iw), "ui")
end


--@api-stub: lurek.ui.newTheme -- Creates a new UI theme for styling widgets
do -- lurek.ui.newTheme
  local theme = lurek.ui.newTheme()
  lurek.log.info("newTheme: " .. tostring(theme), "ui")
end


--@api-stub: lurek.ui.setTheme -- Applies a theme to the UI context
do -- lurek.ui.setTheme
  local theme = lurek.ui.newTheme()
  lurek.ui.setTheme(theme)
  lurek.log.info("theme applied", "ui")
end


--@api-stub: lurek.ui.getTheme -- Returns whether a theme is currently set
do -- lurek.ui.getTheme
  local theme = lurek.ui.getTheme()
  lurek.log.info("getTheme: " .. tostring(theme), "ui")
end


--@api-stub: lurek.ui.getRoot -- Returns the root panel widget
do -- lurek.ui.getRoot
  local root = lurek.ui.getRoot()
  lurek.log.info("root: " .. tostring(root), "ui")
end


--@api-stub: lurek.ui.setFocus -- Sets keyboard focus to a widget, or clears focus if nil
do -- lurek.ui.setFocus
  local btn = lurek.ui.newButton("Focus")
  lurek.ui.setFocus(btn)
  lurek.log.info("focus set", "ui")
end


--@api-stub: lurek.ui.getFocus -- Returns the index of the currently focused widget, or nil
do -- lurek.ui.getFocus
  local idx = lurek.ui.getFocus()
  lurek.log.info("focus idx=" .. tostring(idx), "ui")
end


--@api-stub: lurek.ui.focusNext -- Moves keyboard focus to the next focusable widget
do -- lurek.ui.focusNext
  lurek.ui.focusNext()
  lurek.log.info("focus moved next", "ui")
end


--@api-stub: lurek.ui.focusPrev -- Moves keyboard focus to the previous focusable widget
do -- lurek.ui.focusPrev
  lurek.ui.focusPrev()
  lurek.log.info("focus moved prev", "ui")
end


--@api-stub: lurek.ui.clearFocus -- Clears keyboard focus from all widgets
do -- lurek.ui.clearFocus
  lurek.ui.clearFocus()
  lurek.log.info("focus cleared", "ui")
end


--@api-stub: lurek.ui.addToast -- Adds a toast notification to the queue
do -- lurek.ui.addToast
  lurek.ui.addToast({ message = "Achievement!", duration = 2.5 })
  lurek.log.info("toast queued", "ui")
end


--@api-stub: lurek.ui.getToastCount -- Returns the number of active toast notifications
do -- lurek.ui.getToastCount
  local count = lurek.ui.getToastCount()
  lurek.log.info("toasts=" .. tostring(count), "ui")
end


--@api-stub: lurek.ui.mousepressed -- Delivers a mouse press event to the UI
do -- lurek.ui.mousepressed
  local handled = lurek.ui.mousepressed(100.0, 200.0, 1)
  lurek.log.info("mousepressed=" .. tostring(handled), "ui")
end


--@api-stub: lurek.ui.mousereleased -- Delivers a mouse release event to the UI
do -- lurek.ui.mousereleased
  local handled = lurek.ui.mousereleased(100.0, 200.0, 1)
  lurek.log.info("mousereleased=" .. tostring(handled), "ui")
end


--@api-stub: lurek.ui.mousemoved -- Delivers a mouse move event to the UI
do -- lurek.ui.mousemoved
  local handled = lurek.ui.mousemoved(150.0, 250.0)
  lurek.log.info("mousemoved=" .. tostring(handled), "ui")
end


--@api-stub: lurek.ui.keypressed -- Delivers a key press event to the UI
do -- lurek.ui.keypressed
  local handled = lurek.ui.keypressed("return")
  lurek.log.info("keypressed=" .. tostring(handled), "ui")
end


--@api-stub: lurek.ui.textinput -- Delivers a text input event to the UI
do -- lurek.ui.textinput
  local handled = lurek.ui.textinput("A")
  lurek.log.info("textinput=" .. tostring(handled), "ui")
end


--@api-stub: lurek.ui.wheelmoved -- Delivers a mouse wheel event to the UI
do -- lurek.ui.wheelmoved
  local handled = lurek.ui.wheelmoved(0.0, 3.0)
  lurek.log.info("wheelmoved=" .. tostring(handled), "ui")
end


--@api-stub: lurek.ui.update -- Updates the UI context and dispatches pending events to callbacks
do -- lurek.ui.update
  lurek.ui.update(0.016)
  lurek.log.info("ui updated", "ui")
end


--@api-stub: lurek.ui.draw -- Invokes custom draw callbacks for all widgets that have one registered
do -- lurek.ui.draw
  lurek.ui.draw()
  lurek.log.info("ui draw invoked", "ui")
end


--@api-stub: lurek.ui.newCustomWidget -- Creates a new custom widget with optional initial configuration
do -- lurek.ui.newCustomWidget
  local cw = lurek.ui.newCustomWidget({ width = 100, height = 50 })
  lurek.log.info("newCustomWidget: " .. tostring(cw), "ui")
end


--@api-stub: lurek.ui.getWidgetCount -- Returns the total number of widgets in the UI context
do -- lurek.ui.getWidgetCount
  local count = lurek.ui.getWidgetCount()
  lurek.log.info("widgets=" .. tostring(count), "ui")
end


--@api-stub: lurek.ui.drawToImage -- Renders the entire UI to an image buffer
do -- lurek.ui.drawToImage
  local img = lurek.ui.drawToImage(128.0, 64.0)
  lurek.log.info("rendered to image: " .. tostring(img), "ui")
end


--@api-stub: lurek.ui.newLineChart -- Creates a new line chart for data visualization
do -- lurek.ui.newLineChart
  local chart = lurek.ui.newLineChart({ width = 300, height = 200, title = "FPS" })
  lurek.log.info("newLineChart: " .. tostring(chart), "ui")
end


--@api-stub: lurek.ui.newBarChart -- Creates a new bar chart for data visualization
do -- lurek.ui.newBarChart
  local chart = lurek.ui.newBarChart({ width = 300, height = 200, title = "Sales" })
  lurek.log.info("newBarChart: " .. tostring(chart), "ui")
end


--@api-stub: lurek.ui.newScatterPlot -- Creates a new scatter plot for data visualization
do -- lurek.ui.newScatterPlot
  local plot = lurek.ui.newScatterPlot({ width = 300, height = 200, title = "Data" })
  lurek.log.info("newScatterPlot: " .. tostring(plot), "ui")
end


--@api-stub: lurek.ui.newPieChart -- Creates a new pie chart for data visualization
do -- lurek.ui.newPieChart
  local chart = lurek.ui.newPieChart({ width = 200, height = 200, title = "Budget" })
  lurek.log.info("newPieChart: " .. tostring(chart), "ui")
end


--@api-stub: lurek.ui.newAreaChart -- Creates a new area chart for data visualization
do -- lurek.ui.newAreaChart
  local chart = lurek.ui.newAreaChart({ width = 300, height = 200, title = "Traffic" })
  lurek.log.info("newAreaChart: " .. tostring(chart), "ui")
end


--@api-stub: lurek.ui.parseWidgetState -- Validates and normalizes a widget state string
do -- lurek.ui.parseWidgetState
  local state = lurek.ui.parseWidgetState("hovered")
  lurek.log.info("state=" .. tostring(state), "ui")
end


--@api-stub: lurek.ui.newSpinBox -- Creates a new spin box (numeric stepper) widget
do -- lurek.ui.newSpinBox
  local sb = lurek.ui.newSpinBox(1, 10)
  lurek.log.info("newSpinBox: " .. tostring(sb), "ui")
end


--@api-stub: lurek.ui.newSwitch -- Creates a new toggle switch widget
do -- lurek.ui.newSwitch
  local sw = lurek.ui.newSwitch(false)
  lurek.log.info("newSwitch: " .. tostring(sw), "ui")
end


--@api-stub: lurek.ui.newBadge -- Creates a new badge widget for displaying counts
do -- lurek.ui.newBadge
  local badge = lurek.ui.newBadge(5)
  lurek.log.info("newBadge: " .. tostring(badge), "ui")
end


--@api-stub: lurek.ui.setDefaultTheme -- Applies the built-in default theme to the UI context
do -- lurek.ui.setDefaultTheme
  lurek.ui.setDefaultTheme()
  lurek.log.info("default theme set", "ui")
end


--@api-stub: lurek.ui.setViewport -- Sets the viewport size for the UI context
do -- lurek.ui.setViewport
  lurek.ui.setViewport(1280.0, 720.0)
  lurek.log.info("viewport set", "ui")
end


--@api-stub: lurek.ui.flushCache -- Flushes internal UI caches
do -- lurek.ui.flushCache
  local changed = lurek.ui.flushCache()
  lurek.log.info("cache flushed=" .. tostring(changed), "ui")
end


--@api-stub: lurek.ui.update_bindings -- Updates data bindings for widgets that reference binding keys
do -- lurek.ui.update_bindings
  lurek.ui.update_bindings({ health = 75, score = 1200 })
  lurek.log.info("bindings updated", "ui")
end


--@api-stub: lurek.ui.loadLayout -- Loads a UI layout from a Lua table definition
do -- lurek.ui.loadLayout
  local root = lurek.ui.loadLayout({ type = "panel", width = 200, height = 100 })
  lurek.log.info("layout root=" .. tostring(root), "ui")
end


--@api-stub: lurek.ui.loadLayoutFile -- Loads a UI layout from a TOML file
do -- lurek.ui.loadLayoutFile
  local ok, count = pcall(lurek.ui.loadLayoutFile, "content/layouts/hud.toml")
  if ok then lurek.log.info("layout=" .. tostring(count), "ui") end
end


--@api-stub: lurek.ui.renderToImage -- Renders the UI to a PNG file
do -- lurek.ui.renderToImage
  pcall(lurek.ui.renderToImage, 256, 256, "save/ui_snapshot.png")
  lurek.log.info("rendered to file", "ui")
end



-- LAccordion methods


--@api-stub: LAccordion:addSection
do -- LAccordion:addSection
  local acc = lurek.ui.newAccordion()
  acc:addSection("Section", 1)
  lurek.log.info("LAccordion:addSection done", "ui")
end


--@api-stub: LAccordion:getSectionCount
do -- LAccordion:getSectionCount
  local acc = lurek.ui.newAccordion()
  local val = acc:getSectionCount()
  lurek.log.info("LAccordion:getSectionCount=" .. tostring(val), "ui")
end


--@api-stub: LAccordion:toggleSection
do -- LAccordion:toggleSection
  local acc = lurek.ui.newAccordion()
  local val = acc:toggleSection(1)
  lurek.log.info("LAccordion:toggleSection=" .. tostring(val), "ui")
end


--@api-stub: LAccordion:isSectionExpanded
do -- LAccordion:isSectionExpanded
  local acc = lurek.ui.newAccordion()
  local val = acc:isSectionExpanded(1)
  lurek.log.info("LAccordion:isSectionExpanded=" .. tostring(val), "ui")
end


--@api-stub: LAccordion:isExclusive
do -- LAccordion:isExclusive
  local acc = lurek.ui.newAccordion()
  local val = acc:isExclusive()
  lurek.log.info("LAccordion:isExclusive=" .. tostring(val), "ui")
end


--@api-stub: LAccordion:setExclusive
do -- LAccordion:setExclusive
  local acc = lurek.ui.newAccordion()
  acc:setExclusive(1.0)
  lurek.log.info("LAccordion:setExclusive applied", "ui")
end


--@api-stub: LAccordion:getSectionTitle
do -- LAccordion:getSectionTitle
  local acc = lurek.ui.newAccordion()
  local val = acc:getSectionTitle(1)
  lurek.log.info("LAccordion:getSectionTitle=" .. tostring(val), "ui")
end



-- LBadge methods


--@api-stub: LBadge:setCount
do -- LBadge:setCount
  local badge = lurek.ui.newBadge(5)
  badge:setCount(10)
  lurek.log.info("LBadge:setCount applied", "ui")
end


--@api-stub: LBadge:getCount
do -- LBadge:getCount
  local badge = lurek.ui.newBadge(5)
  local val = badge:getCount()
  lurek.log.info("LBadge:getCount=" .. tostring(val), "ui")
end


--@api-stub: LBadge:getDisplayText
do -- LBadge:getDisplayText
  local badge = lurek.ui.newBadge(5)
  local val = badge:getDisplayText()
  lurek.log.info("LBadge:getDisplayText=" .. tostring(val), "ui")
end



-- LButton methods


--@api-stub: LButton:setText
do -- LButton:setText
  local btn = lurek.ui.newButton("Click")
  btn:setText("Hello, world!")
  lurek.log.info("LButton:setText applied", "ui")
end


--@api-stub: LButton:getText
do -- LButton:getText
  local btn = lurek.ui.newButton("Click")
  local val = btn:getText()
  lurek.log.info("LButton:getText=" .. tostring(val), "ui")
end



-- LCheckbox methods


--@api-stub: LCheckbox:setChecked
do -- LCheckbox:setChecked
  local cb = lurek.ui.newCheckbox("Option")
  cb:setChecked(true)
  lurek.log.info("LCheckbox:setChecked applied", "ui")
end


--@api-stub: LCheckbox:isChecked
do -- LCheckbox:isChecked
  local cb = lurek.ui.newCheckbox("Option")
  local val = cb:isChecked()
  lurek.log.info("LCheckbox:isChecked=" .. tostring(val), "ui")
end


--@api-stub: LCheckbox:setText
do -- LCheckbox:setText
  local cb = lurek.ui.newCheckbox("Option")
  cb:setText("Hello, world!")
  lurek.log.info("LCheckbox:setText applied", "ui")
end


--@api-stub: LCheckbox:getText
do -- LCheckbox:getText
  local cb = lurek.ui.newCheckbox("Option")
  local val = cb:getText()
  lurek.log.info("LCheckbox:getText=" .. tostring(val), "ui")
end



-- LColorPicker methods


--@api-stub: LColorPicker:getColor
do -- LColorPicker:getColor
  local cp = lurek.ui.newColorPicker()
  local val = cp:getColor()
  lurek.log.info("LColorPicker:getColor=" .. tostring(val), "ui")
end


--@api-stub: LColorPicker:setColor
do -- LColorPicker:setColor
  local cp = lurek.ui.newColorPicker()
  cp:setColor(1.0, 1.0, 0.2, 1.0)
  lurek.log.info("LColorPicker:setColor applied", "ui")
end


--@api-stub: LColorPicker:getShowAlpha
do -- LColorPicker:getShowAlpha
  local cp = lurek.ui.newColorPicker()
  local val = cp:getShowAlpha()
  lurek.log.info("LColorPicker:getShowAlpha=" .. tostring(val), "ui")
end


--@api-stub: LColorPicker:setShowAlpha
do -- LColorPicker:setShowAlpha
  local cp = lurek.ui.newColorPicker()
  cp:setShowAlpha(1.0)
  lurek.log.info("LColorPicker:setShowAlpha applied", "ui")
end


--@api-stub: LColorPicker:getColorMode
do -- LColorPicker:getColorMode
  local cp = lurek.ui.newColorPicker()
  local val = cp:getColorMode()
  lurek.log.info("LColorPicker:getColorMode=" .. tostring(val), "ui")
end


--@api-stub: LColorPicker:setColorMode
do -- LColorPicker:setColorMode
  local cp = lurek.ui.newColorPicker()
  cp:setColorMode("left")
  lurek.log.info("LColorPicker:setColorMode applied", "ui")
end


--@api-stub: LColorPicker:setOnChange
do -- LColorPicker:setOnChange
  local cp = lurek.ui.newColorPicker()
  cp:setOnChange(function() end)
  lurek.log.info("LColorPicker:setOnChange callback set", "ui")
end



-- LComboBox methods


--@api-stub: LComboBox:addItem
do -- LComboBox:addItem
  local combo = lurek.ui.newComboBox()
  combo:addItem("Hello, world!")
  lurek.log.info("LComboBox:addItem done", "ui")
end


--@api-stub: LComboBox:removeItem
do -- LComboBox:removeItem
  local combo = lurek.ui.newComboBox()
  combo:removeItem(1)
  lurek.log.info("LComboBox:removeItem done", "ui")
end


--@api-stub: LComboBox:clearItems
do -- LComboBox:clearItems
  local combo = lurek.ui.newComboBox()
  combo:clearItems()
  lurek.log.info("LComboBox:clearItems done", "ui")
end


--@api-stub: LComboBox:getItemCount
do -- LComboBox:getItemCount
  local combo = lurek.ui.newComboBox()
  local val = combo:getItemCount()
  lurek.log.info("LComboBox:getItemCount=" .. tostring(val), "ui")
end


--@api-stub: LComboBox:getItem
do -- LComboBox:getItem
  local combo = lurek.ui.newComboBox()
  local val = combo:getItem(1)
  lurek.log.info("LComboBox:getItem=" .. tostring(val), "ui")
end


--@api-stub: LComboBox:setSelectedIndex
do -- LComboBox:setSelectedIndex
  local combo = lurek.ui.newComboBox()
  combo:setSelectedIndex(1)
  lurek.log.info("LComboBox:setSelectedIndex applied", "ui")
end


--@api-stub: LComboBox:getSelectedIndex
do -- LComboBox:getSelectedIndex
  local combo = lurek.ui.newComboBox()
  local val = combo:getSelectedIndex()
  lurek.log.info("LComboBox:getSelectedIndex=" .. tostring(val), "ui")
end


--@api-stub: LComboBox:getSelectedItem
do -- LComboBox:getSelectedItem
  local combo = lurek.ui.newComboBox()
  local val = combo:getSelectedItem()
  lurek.log.info("LComboBox:getSelectedItem=" .. tostring(val), "ui")
end



-- LDialog methods


--@api-stub: LDialog:getTitle
do -- LDialog:getTitle
  local dlg = lurek.ui.newDialog("Title")
  local val = dlg:getTitle()
  lurek.log.info("LDialog:getTitle=" .. tostring(val), "ui")
end


--@api-stub: LDialog:setTitle
do -- LDialog:setTitle
  local dlg = lurek.ui.newDialog("Title")
  dlg:setTitle("Section")
  lurek.log.info("LDialog:setTitle applied", "ui")
end


--@api-stub: LDialog:isModal
do -- LDialog:isModal
  local dlg = lurek.ui.newDialog("Title")
  local val = dlg:isModal()
  lurek.log.info("LDialog:isModal=" .. tostring(val), "ui")
end


--@api-stub: LDialog:setModal
do -- LDialog:setModal
  local dlg = lurek.ui.newDialog("Title")
  dlg:setModal(1.0)
  lurek.log.info("LDialog:setModal applied", "ui")
end


--@api-stub: LDialog:isOpen
do -- LDialog:isOpen
  local dlg = lurek.ui.newDialog("Title")
  local val = dlg:isOpen()
  lurek.log.info("LDialog:isOpen=" .. tostring(val), "ui")
end


--@api-stub: LDialog:open
do -- LDialog:open
  local dlg = lurek.ui.newDialog("Title")
  dlg:open()
  lurek.log.info("LDialog:open called", "ui")
end


--@api-stub: LDialog:close
do -- LDialog:close
  local dlg = lurek.ui.newDialog("Title")
  dlg:close()
  lurek.log.info("LDialog:close called", "ui")
end


--@api-stub: LDialog:setOnClose
do -- LDialog:setOnClose
  local dlg = lurek.ui.newDialog("Title")
  dlg:setOnClose(function() end)
  lurek.log.info("LDialog:setOnClose callback set", "ui")
end


--@api-stub: LDialog:setContent
do -- LDialog:setContent
  local dlg = lurek.ui.newDialog("Title")
  dlg:setContent(1)
  lurek.log.info("LDialog:setContent applied", "ui")
end


--@api-stub: LDialog:getContent
do -- LDialog:getContent
  local dlg = lurek.ui.newDialog("Title")
  local val = dlg:getContent()
  lurek.log.info("LDialog:getContent=" .. tostring(val), "ui")
end


--@api-stub: LDialog:addButton
do -- LDialog:addButton
  local dlg = lurek.ui.newDialog("Title")
  dlg:addButton("Hello, world!", function() end)
  lurek.log.info("LDialog:addButton done", "ui")
end



-- LDockPanel methods


--@api-stub: LDockPanel:dock
do -- LDockPanel:dock
  local dock = lurek.ui.newDockPanel()
  dock:dock(1, "left")
  lurek.log.info("LDockPanel:dock called", "ui")
end


--@api-stub: LDockPanel:undock
do -- LDockPanel:undock
  local dock = lurek.ui.newDockPanel()
  dock:undock(1)
  lurek.log.info("LDockPanel:undock called", "ui")
end


--@api-stub: LDockPanel:getDockedCount
do -- LDockPanel:getDockedCount
  local dock = lurek.ui.newDockPanel()
  local val = dock:getDockedCount()
  lurek.log.info("LDockPanel:getDockedCount=" .. tostring(val), "ui")
end


--@api-stub: LDockPanel:setSplitSize
do -- LDockPanel:setSplitSize
  local dock = lurek.ui.newDockPanel()
  dock:setSplitSize("left", 64.0)
  lurek.log.info("LDockPanel:setSplitSize applied", "ui")
end


--@api-stub: LDockPanel:getSplitSize
do -- LDockPanel:getSplitSize
  local dock = lurek.ui.newDockPanel()
  local val = dock:getSplitSize("left")
  lurek.log.info("LDockPanel:getSplitSize=" .. tostring(val), "ui")
end



-- LGuiTable methods


--@api-stub: LGuiTable:addColumn
do -- LGuiTable:addColumn
  local tbl = lurek.ui.newTable()
  tbl:addColumn("Hello", 64.0)
  lurek.log.info("LGuiTable:addColumn done", "ui")
end


--@api-stub: LGuiTable:getColumnCount
do -- LGuiTable:getColumnCount
  local tbl = lurek.ui.newTable()
  local val = tbl:getColumnCount()
  lurek.log.info("LGuiTable:getColumnCount=" .. tostring(val), "ui")
end


--@api-stub: LGuiTable:addRow
do -- LGuiTable:addRow
  local tbl = lurek.ui.newTable()
  tbl:addRow({1, 2, 3})
  lurek.log.info("LGuiTable:addRow done", "ui")
end


--@api-stub: LGuiTable:getRowCount
do -- LGuiTable:getRowCount
  local tbl = lurek.ui.newTable()
  local val = tbl:getRowCount()
  lurek.log.info("LGuiTable:getRowCount=" .. tostring(val), "ui")
end


--@api-stub: LGuiTable:getCell
do -- LGuiTable:getCell
  local tbl = lurek.ui.newTable()
  local val = tbl:getCell(1, 1)
  lurek.log.info("LGuiTable:getCell=" .. tostring(val), "ui")
end


--@api-stub: LGuiTable:setCell
do -- LGuiTable:setCell
  local tbl = lurek.ui.newTable()
  tbl:setCell(1, 1, "Hello, world!")
  lurek.log.info("LGuiTable:setCell applied", "ui")
end


--@api-stub: LGuiTable:getSelectedRow
do -- LGuiTable:getSelectedRow
  local tbl = lurek.ui.newTable()
  local val = tbl:getSelectedRow()
  lurek.log.info("LGuiTable:getSelectedRow=" .. tostring(val), "ui")
end


--@api-stub: LGuiTable:setSelectedRow
do -- LGuiTable:setSelectedRow
  local tbl = lurek.ui.newTable()
  tbl:setSelectedRow(1)
  lurek.log.info("LGuiTable:setSelectedRow applied", "ui")
end


--@api-stub: LGuiTable:isSortable
do -- LGuiTable:isSortable
  local tbl = lurek.ui.newTable()
  local val = tbl:isSortable()
  lurek.log.info("LGuiTable:isSortable=" .. tostring(val), "ui")
end


--@api-stub: LGuiTable:setSortable
do -- LGuiTable:setSortable
  local tbl = lurek.ui.newTable()
  tbl:setSortable(1.0)
  lurek.log.info("LGuiTable:setSortable applied", "ui")
end


--@api-stub: LGuiTable:setOnSelect
do -- LGuiTable:setOnSelect
  local tbl = lurek.ui.newTable()
  tbl:setOnSelect(function() end)
  lurek.log.info("LGuiTable:setOnSelect callback set", "ui")
end



-- LGuiWindow methods


--@api-stub: LGuiWindow:getTitle
do -- LGuiWindow:getTitle
  local win = lurek.ui.newWindow("Title")
  local val = win:getTitle()
  lurek.log.info("LGuiWindow:getTitle=" .. tostring(val), "ui")
end


--@api-stub: LGuiWindow:setTitle
do -- LGuiWindow:setTitle
  local win = lurek.ui.newWindow("Title")
  win:setTitle("Section")
  lurek.log.info("LGuiWindow:setTitle applied", "ui")
end


--@api-stub: LGuiWindow:isCloseable
do -- LGuiWindow:isCloseable
  local win = lurek.ui.newWindow("Title")
  local val = win:isCloseable()
  lurek.log.info("LGuiWindow:isCloseable=" .. tostring(val), "ui")
end


--@api-stub: LGuiWindow:setCloseable
do -- LGuiWindow:setCloseable
  local win = lurek.ui.newWindow("Title")
  win:setCloseable(1.0)
  lurek.log.info("LGuiWindow:setCloseable applied", "ui")
end


--@api-stub: LGuiWindow:isDraggable
do -- LGuiWindow:isDraggable
  local win = lurek.ui.newWindow("Title")
  local val = win:isDraggable()
  lurek.log.info("LGuiWindow:isDraggable=" .. tostring(val), "ui")
end


--@api-stub: LGuiWindow:setDraggable
do -- LGuiWindow:setDraggable
  local win = lurek.ui.newWindow("Title")
  win:setDraggable(1.0)
  lurek.log.info("LGuiWindow:setDraggable applied", "ui")
end


--@api-stub: LGuiWindow:isResizable
do -- LGuiWindow:isResizable
  local win = lurek.ui.newWindow("Title")
  local val = win:isResizable()
  lurek.log.info("LGuiWindow:isResizable=" .. tostring(val), "ui")
end


--@api-stub: LGuiWindow:setResizable
do -- LGuiWindow:setResizable
  local win = lurek.ui.newWindow("Title")
  win:setResizable(1.0)
  lurek.log.info("LGuiWindow:setResizable applied", "ui")
end


--@api-stub: LGuiWindow:setOnClose
do -- LGuiWindow:setOnClose
  local win = lurek.ui.newWindow("Title")
  win:setOnClose(function() end)
  lurek.log.info("LGuiWindow:setOnClose callback set", "ui")
end



-- LImageWidget methods


--@api-stub: LImageWidget:getScaleMode
do -- LImageWidget:getScaleMode
  local iw = lurek.ui.newImageWidget()
  local val = iw:getScaleMode()
  lurek.log.info("LImageWidget:getScaleMode=" .. tostring(val), "ui")
end


--@api-stub: LImageWidget:setScaleMode
do -- LImageWidget:setScaleMode
  local iw = lurek.ui.newImageWidget()
  iw:setScaleMode("left")
  lurek.log.info("LImageWidget:setScaleMode applied", "ui")
end


--@api-stub: LImageWidget:getTint
do -- LImageWidget:getTint
  local iw = lurek.ui.newImageWidget()
  local val = iw:getTint()
  lurek.log.info("LImageWidget:getTint=" .. tostring(val), "ui")
end


--@api-stub: LImageWidget:setTint
do -- LImageWidget:setTint
  local iw = lurek.ui.newImageWidget()
  iw:setTint(1.0, 1.0, 0.2, 1.0)
  lurek.log.info("LImageWidget:setTint applied", "ui")
end



-- LLabel methods


--@api-stub: LLabel:setText
do -- LLabel:setText
  local lbl = lurek.ui.newLabel("Text")
  lbl:setText("Hello, world!")
  lurek.log.info("LLabel:setText applied", "ui")
end


--@api-stub: LLabel:getText
do -- LLabel:getText
  local lbl = lurek.ui.newLabel("Text")
  local val = lbl:getText()
  lurek.log.info("LLabel:getText=" .. tostring(val), "ui")
end



-- LLayout methods


--@api-stub: LLayout:setDirection
do -- LLayout:setDirection
  local layout = lurek.ui.newLayout("horizontal")
  layout:setDirection("left")
  lurek.log.info("LLayout:setDirection applied", "ui")
end


--@api-stub: LLayout:getDirection
do -- LLayout:getDirection
  local layout = lurek.ui.newLayout("horizontal")
  local val = layout:getDirection()
  lurek.log.info("LLayout:getDirection=" .. tostring(val), "ui")
end


--@api-stub: LLayout:setSpacing
do -- LLayout:setSpacing
  local layout = lurek.ui.newLayout("horizontal")
  layout:setSpacing(0.0)
  lurek.log.info("LLayout:setSpacing applied", "ui")
end


--@api-stub: LLayout:getSpacing
do -- LLayout:getSpacing
  local layout = lurek.ui.newLayout("horizontal")
  local val = layout:getSpacing()
  lurek.log.info("LLayout:getSpacing=" .. tostring(val), "ui")
end


--@api-stub: LLayout:setColumns
do -- LLayout:setColumns
  local layout = lurek.ui.newLayout("horizontal")
  layout:setColumns(5)
  lurek.log.info("LLayout:setColumns applied", "ui")
end


--@api-stub: LLayout:setWrap
do -- LLayout:setWrap
  local layout = lurek.ui.newLayout("horizontal")
  layout:setWrap(true)
  lurek.log.info("LLayout:setWrap applied", "ui")
end


--@api-stub: LLayout:getWrap
do -- LLayout:getWrap
  local layout = lurek.ui.newLayout("horizontal")
  local val = layout:getWrap()
  lurek.log.info("LLayout:getWrap=" .. tostring(val), "ui")
end


--@api-stub: LLayout:setAlign
do -- LLayout:setAlign
  local layout = lurek.ui.newLayout("horizontal")
  layout:setAlign("left")
  lurek.log.info("LLayout:setAlign applied", "ui")
end


--@api-stub: LLayout:getAlign
do -- LLayout:getAlign
  local layout = lurek.ui.newLayout("horizontal")
  local val = layout:getAlign()
  lurek.log.info("LLayout:getAlign=" .. tostring(val), "ui")
end


--@api-stub: LLayout:setJustify
do -- LLayout:setJustify
  local layout = lurek.ui.newLayout("horizontal")
  layout:setJustify("left")
  lurek.log.info("LLayout:setJustify applied", "ui")
end


--@api-stub: LLayout:getJustify
do -- LLayout:getJustify
  local layout = lurek.ui.newLayout("horizontal")
  local val = layout:getJustify()
  lurek.log.info("LLayout:getJustify=" .. tostring(val), "ui")
end



-- LLineChart methods


--@api-stub: LLineChart:addSeries -- Adds a named series of points to this line chart
do -- LLineChart:addSeries
  local chart = lurek.ui.newLineChart({ width = 300, height = 200, title = "Data" })
  chart:addSeries("hero", {1, 2, 3}, 1.0, 0.8, 0.2)
  lurek.log.info("LLineChart:addSeries done", "ui")
end



-- LListBox methods


--@api-stub: LListBox:addItem
do -- LListBox:addItem
  local list = lurek.ui.newList()
  list:addItem("Hello, world!")
  lurek.log.info("LListBox:addItem done", "ui")
end


--@api-stub: LListBox:removeItem
do -- LListBox:removeItem
  local list = lurek.ui.newList()
  list:removeItem(1)
  lurek.log.info("LListBox:removeItem done", "ui")
end


--@api-stub: LListBox:clearItems
do -- LListBox:clearItems
  local list = lurek.ui.newList()
  list:clearItems()
  lurek.log.info("LListBox:clearItems done", "ui")
end


--@api-stub: LListBox:getItemCount
do -- LListBox:getItemCount
  local list = lurek.ui.newList()
  local val = list:getItemCount()
  lurek.log.info("LListBox:getItemCount=" .. tostring(val), "ui")
end


--@api-stub: LListBox:getItem
do -- LListBox:getItem
  local list = lurek.ui.newList()
  local val = list:getItem(1)
  lurek.log.info("LListBox:getItem=" .. tostring(val), "ui")
end


--@api-stub: LListBox:setSelectedIndex
do -- LListBox:setSelectedIndex
  local list = lurek.ui.newList()
  list:setSelectedIndex(1)
  lurek.log.info("LListBox:setSelectedIndex applied", "ui")
end


--@api-stub: LListBox:getSelectedIndex
do -- LListBox:getSelectedIndex
  local list = lurek.ui.newList()
  local val = list:getSelectedIndex()
  lurek.log.info("LListBox:getSelectedIndex=" .. tostring(val), "ui")
end


--@api-stub: LListBox:setItemHeight
do -- LListBox:setItemHeight
  local list = lurek.ui.newList()
  list:setItemHeight(64.0)
  lurek.log.info("LListBox:setItemHeight applied", "ui")
end



-- LMenuBar methods


--@api-stub: LMenuBar:addMenu
do -- LMenuBar:addMenu
  local mb = lurek.ui.newMenuBar()
  mb:addMenu(1)
  lurek.log.info("LMenuBar:addMenu done", "ui")
end


--@api-stub: LMenuBar:removeMenu
do -- LMenuBar:removeMenu
  local mb = lurek.ui.newMenuBar()
  mb:removeMenu(1)
  lurek.log.info("LMenuBar:removeMenu done", "ui")
end


--@api-stub: LMenuBar:getMenus
do -- LMenuBar:getMenus
  local mb = lurek.ui.newMenuBar()
  local val = mb:getMenus()
  lurek.log.info("LMenuBar:getMenus=" .. tostring(val), "ui")
end


--@api-stub: LMenuBar:getMenuCount
do -- LMenuBar:getMenuCount
  local mb = lurek.ui.newMenuBar()
  local val = mb:getMenuCount()
  lurek.log.info("LMenuBar:getMenuCount=" .. tostring(val), "ui")
end



-- LMenuItem methods


--@api-stub: LMenuItem:getText
do -- LMenuItem:getText
  local mi = lurek.ui.newMenuItem("File")
  local val = mi:getText()
  lurek.log.info("LMenuItem:getText=" .. tostring(val), "ui")
end


--@api-stub: LMenuItem:setText
do -- LMenuItem:setText
  local mi = lurek.ui.newMenuItem("File")
  mi:setText("Hello, world!")
  lurek.log.info("LMenuItem:setText applied", "ui")
end


--@api-stub: LMenuItem:getShortcut
do -- LMenuItem:getShortcut
  local mi = lurek.ui.newMenuItem("File")
  local val = mi:getShortcut()
  lurek.log.info("LMenuItem:getShortcut=" .. tostring(val), "ui")
end


--@api-stub: LMenuItem:setShortcut
do -- LMenuItem:setShortcut
  local mi = lurek.ui.newMenuItem("File")
  mi:setShortcut("Hello")
  lurek.log.info("LMenuItem:setShortcut applied", "ui")
end


--@api-stub: LMenuItem:isChecked
do -- LMenuItem:isChecked
  local mi = lurek.ui.newMenuItem("File")
  local val = mi:isChecked()
  lurek.log.info("LMenuItem:isChecked=" .. tostring(val), "ui")
end


--@api-stub: LMenuItem:setChecked
do -- LMenuItem:setChecked
  local mi = lurek.ui.newMenuItem("File")
  mi:setChecked(1.0)
  lurek.log.info("LMenuItem:setChecked applied", "ui")
end


--@api-stub: LMenuItem:addSubItem
do -- LMenuItem:addSubItem
  local mi = lurek.ui.newMenuItem("File")
  mi:addSubItem(1)
  lurek.log.info("LMenuItem:addSubItem done", "ui")
end


--@api-stub: LMenuItem:getSubItems
do -- LMenuItem:getSubItems
  local mi = lurek.ui.newMenuItem("File")
  local val = mi:getSubItems()
  lurek.log.info("LMenuItem:getSubItems=" .. tostring(val), "ui")
end


--@api-stub: LMenuItem:setOnClick
do -- LMenuItem:setOnClick
  local mi = lurek.ui.newMenuItem("File")
  mi:setOnClick(function() end)
  lurek.log.info("LMenuItem:setOnClick callback set", "ui")
end



-- LNinePatch methods


--@api-stub: LNinePatch:setInsets
do -- LNinePatch:setInsets
  local np = lurek.ui.newNinePatch()
  np:setInsets(64.0, 64.0, 64.0, 64.0)
  lurek.log.info("LNinePatch:setInsets applied", "ui")
end


--@api-stub: LNinePatch:getInsets
do -- LNinePatch:getInsets
  local np = lurek.ui.newNinePatch()
  local val = np:getInsets()
  lurek.log.info("LNinePatch:getInsets=" .. tostring(val), "ui")
end


--@api-stub: LNinePatch:setImageDimensions
do -- LNinePatch:setImageDimensions
  local np = lurek.ui.newNinePatch()
  np:setImageDimensions(64.0, 64.0)
  lurek.log.info("LNinePatch:setImageDimensions applied", "ui")
end


--@api-stub: LNinePatch:getImageDimensions
do -- LNinePatch:getImageDimensions
  local np = lurek.ui.newNinePatch()
  local val = np:getImageDimensions()
  lurek.log.info("LNinePatch:getImageDimensions=" .. tostring(val), "ui")
end


--@api-stub: LNinePatch:getSlices
do -- LNinePatch:getSlices
  local np = lurek.ui.newNinePatch()
  local val = np:getSlices()
  lurek.log.info("LNinePatch:getSlices=" .. tostring(val), "ui")
end



-- LPanel methods


--@api-stub: LPanel:setTitle
do -- LPanel:setTitle
  local panel = lurek.ui.newPanel()
  panel:setTitle("Section")
  lurek.log.info("LPanel:setTitle applied", "ui")
end


--@api-stub: LPanel:getTitle
do -- LPanel:getTitle
  local panel = lurek.ui.newPanel()
  local val = panel:getTitle()
  lurek.log.info("LPanel:getTitle=" .. tostring(val), "ui")
end


--@api-stub: LPanel:setScrollable
do -- LPanel:setScrollable
  local panel = lurek.ui.newPanel()
  panel:setScrollable(true)
  lurek.log.info("LPanel:setScrollable applied", "ui")
end



-- LProgressBar methods


--@api-stub: LProgressBar:setValue
do -- LProgressBar:setValue
  local bar = lurek.ui.newProgressBar(0, 100)
  bar:setValue(1.0)
  lurek.log.info("LProgressBar:setValue applied", "ui")
end


--@api-stub: LProgressBar:getValue
do -- LProgressBar:getValue
  local bar = lurek.ui.newProgressBar(0, 100)
  local val = bar:getValue()
  lurek.log.info("LProgressBar:getValue=" .. tostring(val), "ui")
end


--@api-stub: LProgressBar:getProgress
do -- LProgressBar:getProgress
  local bar = lurek.ui.newProgressBar(0, 100)
  local val = bar:getProgress()
  lurek.log.info("LProgressBar:getProgress=" .. tostring(val), "ui")
end


--@api-stub: LProgressBar:setRange
do -- LProgressBar:setRange
  local bar = lurek.ui.newProgressBar(0, 100)
  bar:setRange(0.0, 0.0)
  lurek.log.info("LProgressBar:setRange applied", "ui")
end


--@api-stub: LProgressBar:getMin
do -- LProgressBar:getMin
  local bar = lurek.ui.newProgressBar(0, 100)
  local val = bar:getMin()
  lurek.log.info("LProgressBar:getMin=" .. tostring(val), "ui")
end


--@api-stub: LProgressBar:getMax
do -- LProgressBar:getMax
  local bar = lurek.ui.newProgressBar(0, 100)
  local val = bar:getMax()
  lurek.log.info("LProgressBar:getMax=" .. tostring(val), "ui")
end



-- LRadioButton methods


--@api-stub: LRadioButton:getText
do -- LRadioButton:getText
  local rb = lurek.ui.newRadioButton("Option", "group1")
  local val = rb:getText()
  lurek.log.info("LRadioButton:getText=" .. tostring(val), "ui")
end


--@api-stub: LRadioButton:setText
do -- LRadioButton:setText
  local rb = lurek.ui.newRadioButton("Option", "group1")
  rb:setText("Hello, world!")
  lurek.log.info("LRadioButton:setText applied", "ui")
end


--@api-stub: LRadioButton:isSelected
do -- LRadioButton:isSelected
  local rb = lurek.ui.newRadioButton("Option", "group1")
  local val = rb:isSelected()
  lurek.log.info("LRadioButton:isSelected=" .. tostring(val), "ui")
end


--@api-stub: LRadioButton:setSelected
do -- LRadioButton:setSelected
  local rb = lurek.ui.newRadioButton("Option", "group1")
  rb:setSelected(1.0)
  lurek.log.info("LRadioButton:setSelected applied", "ui")
end


--@api-stub: LRadioButton:getGroup
do -- LRadioButton:getGroup
  local rb = lurek.ui.newRadioButton("Option", "group1")
  local val = rb:getGroup()
  lurek.log.info("LRadioButton:getGroup=" .. tostring(val), "ui")
end


--@api-stub: LRadioButton:setGroup
do -- LRadioButton:setGroup
  local rb = lurek.ui.newRadioButton("Option", "group1")
  rb:setGroup("left")
  lurek.log.info("LRadioButton:setGroup applied", "ui")
end


--@api-stub: LRadioButton:setOnChange
do -- LRadioButton:setOnChange
  local rb = lurek.ui.newRadioButton("Option", "group1")
  rb:setOnChange(function() end)
  lurek.log.info("LRadioButton:setOnChange callback set", "ui")
end



-- LScrollBar methods


--@api-stub: LScrollBar:getScrollPosition
do -- LScrollBar:getScrollPosition
  local scrollbar = lurek.ui.newScrollBar(true)
  local val = scrollbar:getScrollPosition()
  lurek.log.info("LScrollBar:getScrollPosition=" .. tostring(val), "ui")
end


--@api-stub: LScrollBar:setScrollPosition
do -- LScrollBar:setScrollPosition
  local scrollbar = lurek.ui.newScrollBar(true)
  scrollbar:setScrollPosition(1.0)
  lurek.log.info("LScrollBar:setScrollPosition applied", "ui")
end


--@api-stub: LScrollBar:getContentSize
do -- LScrollBar:getContentSize
  local scrollbar = lurek.ui.newScrollBar(true)
  local val = scrollbar:getContentSize()
  lurek.log.info("LScrollBar:getContentSize=" .. tostring(val), "ui")
end


--@api-stub: LScrollBar:setContentSize
do -- LScrollBar:setContentSize
  local scrollbar = lurek.ui.newScrollBar(true)
  scrollbar:setContentSize(1.0)
  lurek.log.info("LScrollBar:setContentSize applied", "ui")
end


--@api-stub: LScrollBar:getViewSize
do -- LScrollBar:getViewSize
  local scrollbar = lurek.ui.newScrollBar(true)
  local val = scrollbar:getViewSize()
  lurek.log.info("LScrollBar:getViewSize=" .. tostring(val), "ui")
end


--@api-stub: LScrollBar:setViewSize
do -- LScrollBar:setViewSize
  local scrollbar = lurek.ui.newScrollBar(true)
  scrollbar:setViewSize(1.0)
  lurek.log.info("LScrollBar:setViewSize applied", "ui")
end


--@api-stub: LScrollBar:isVertical
do -- LScrollBar:isVertical
  local scrollbar = lurek.ui.newScrollBar(true)
  local val = scrollbar:isVertical()
  lurek.log.info("LScrollBar:isVertical=" .. tostring(val), "ui")
end


--@api-stub: LScrollBar:setOnChange
do -- LScrollBar:setOnChange
  local scrollbar = lurek.ui.newScrollBar(true)
  scrollbar:setOnChange(function() end)
  lurek.log.info("LScrollBar:setOnChange callback set", "ui")
end



-- LScrollPanel methods


--@api-stub: LScrollPanel:setContentSize
do -- LScrollPanel:setContentSize
  local sp = lurek.ui.newScrollPanel()
  sp:setContentSize(64.0, 64.0)
  lurek.log.info("LScrollPanel:setContentSize applied", "ui")
end


--@api-stub: LScrollPanel:getContentSize
do -- LScrollPanel:getContentSize
  local sp = lurek.ui.newScrollPanel()
  local val = sp:getContentSize()
  lurek.log.info("LScrollPanel:getContentSize=" .. tostring(val), "ui")
end


--@api-stub: LScrollPanel:setScrollPosition
do -- LScrollPanel:setScrollPosition
  local sp = lurek.ui.newScrollPanel()
  sp:setScrollPosition(0.0, 0.0)
  lurek.log.info("LScrollPanel:setScrollPosition applied", "ui")
end


--@api-stub: LScrollPanel:getScrollPosition
do -- LScrollPanel:getScrollPosition
  local sp = lurek.ui.newScrollPanel()
  local val = sp:getScrollPosition()
  lurek.log.info("LScrollPanel:getScrollPosition=" .. tostring(val), "ui")
end


--@api-stub: LScrollPanel:getMaxScroll
do -- LScrollPanel:getMaxScroll
  local sp = lurek.ui.newScrollPanel()
  local val = sp:getMaxScroll()
  lurek.log.info("LScrollPanel:getMaxScroll=" .. tostring(val), "ui")
end


--@api-stub: LScrollPanel:setScrollSpeed
do -- LScrollPanel:setScrollSpeed
  local sp = lurek.ui.newScrollPanel()
  sp:setScrollSpeed(120.0)
  lurek.log.info("LScrollPanel:setScrollSpeed applied", "ui")
end


--@api-stub: LScrollPanel:getScrollSpeed
do -- LScrollPanel:getScrollSpeed
  local sp = lurek.ui.newScrollPanel()
  local val = sp:getScrollSpeed()
  lurek.log.info("LScrollPanel:getScrollSpeed=" .. tostring(val), "ui")
end



-- LSeparator methods


--@api-stub: LSeparator:setVertical
do -- LSeparator:setVertical
  local sep = lurek.ui.newSeparator(false)
  sep:setVertical(1.0)
  lurek.log.info("LSeparator:setVertical applied", "ui")
end


--@api-stub: LSeparator:isVertical
do -- LSeparator:isVertical
  local sep = lurek.ui.newSeparator(false)
  local val = sep:isVertical()
  lurek.log.info("LSeparator:isVertical=" .. tostring(val), "ui")
end


--@api-stub: LSeparator:setThickness
do -- LSeparator:setThickness
  local sep = lurek.ui.newSeparator(false)
  sep:setThickness(64.0)
  lurek.log.info("LSeparator:setThickness applied", "ui")
end


--@api-stub: LSeparator:getThickness
do -- LSeparator:getThickness
  local sep = lurek.ui.newSeparator(false)
  local val = sep:getThickness()
  lurek.log.info("LSeparator:getThickness=" .. tostring(val), "ui")
end



-- LSlider methods


--@api-stub: LSlider:setValue
do -- LSlider:setValue
  local slider = lurek.ui.newSlider(0, 100)
  slider:setValue(1.0)
  lurek.log.info("LSlider:setValue applied", "ui")
end


--@api-stub: LSlider:getValue
do -- LSlider:getValue
  local slider = lurek.ui.newSlider(0, 100)
  local val = slider:getValue()
  lurek.log.info("LSlider:getValue=" .. tostring(val), "ui")
end


--@api-stub: LSlider:setRange
do -- LSlider:setRange
  local slider = lurek.ui.newSlider(0, 100)
  slider:setRange(0.0, 0.0)
  lurek.log.info("LSlider:setRange applied", "ui")
end


--@api-stub: LSlider:setStep
do -- LSlider:setStep
  local slider = lurek.ui.newSlider(0, 100)
  slider:setStep(0.0)
  lurek.log.info("LSlider:setStep applied", "ui")
end


--@api-stub: LSlider:getMin
do -- LSlider:getMin
  local slider = lurek.ui.newSlider(0, 100)
  local val = slider:getMin()
  lurek.log.info("LSlider:getMin=" .. tostring(val), "ui")
end


--@api-stub: LSlider:getMax
do -- LSlider:getMax
  local slider = lurek.ui.newSlider(0, 100)
  local val = slider:getMax()
  lurek.log.info("LSlider:getMax=" .. tostring(val), "ui")
end



-- LSpinBox methods


--@api-stub: LSpinBox:setValue
do -- LSpinBox:setValue
  local sb = lurek.ui.newSpinBox(0, 100)
  sb:setValue(1.0)
  lurek.log.info("LSpinBox:setValue applied", "ui")
end


--@api-stub: LSpinBox:getValue
do -- LSpinBox:getValue
  local sb = lurek.ui.newSpinBox(0, 100)
  local val = sb:getValue()
  lurek.log.info("LSpinBox:getValue=" .. tostring(val), "ui")
end


--@api-stub: LSpinBox:increment
do -- LSpinBox:increment
  local sb = lurek.ui.newSpinBox(0, 100)
  sb:increment()
  lurek.log.info("LSpinBox:increment called", "ui")
end


--@api-stub: LSpinBox:decrement
do -- LSpinBox:decrement
  local sb = lurek.ui.newSpinBox(0, 100)
  sb:decrement()
  lurek.log.info("LSpinBox:decrement called", "ui")
end


--@api-stub: LSpinBox:setRange
do -- LSpinBox:setRange
  local sb = lurek.ui.newSpinBox(0, 100)
  sb:setRange(0.0, 0.0)
  lurek.log.info("LSpinBox:setRange applied", "ui")
end


--@api-stub: LSpinBox:setStep
do -- LSpinBox:setStep
  local sb = lurek.ui.newSpinBox(0, 100)
  sb:setStep(0.0)
  lurek.log.info("LSpinBox:setStep applied", "ui")
end



-- LSplitPanel methods


--@api-stub: LSplitPanel:getOrientation
do -- LSplitPanel:getOrientation
  local split = lurek.ui.newSplitPanel("vertical")
  local val = split:getOrientation()
  lurek.log.info("LSplitPanel:getOrientation=" .. tostring(val), "ui")
end


--@api-stub: LSplitPanel:setOrientation
do -- LSplitPanel:setOrientation
  local split = lurek.ui.newSplitPanel("vertical")
  split:setOrientation(1.0)
  lurek.log.info("LSplitPanel:setOrientation applied", "ui")
end


--@api-stub: LSplitPanel:getSplitPosition
do -- LSplitPanel:getSplitPosition
  local split = lurek.ui.newSplitPanel("vertical")
  local val = split:getSplitPosition()
  lurek.log.info("LSplitPanel:getSplitPosition=" .. tostring(val), "ui")
end


--@api-stub: LSplitPanel:setSplitPosition
do -- LSplitPanel:setSplitPosition
  local split = lurek.ui.newSplitPanel("vertical")
  split:setSplitPosition(1.0)
  lurek.log.info("LSplitPanel:setSplitPosition applied", "ui")
end


--@api-stub: LSplitPanel:getMinPanelSize
do -- LSplitPanel:getMinPanelSize
  local split = lurek.ui.newSplitPanel("vertical")
  local val = split:getMinPanelSize()
  lurek.log.info("LSplitPanel:getMinPanelSize=" .. tostring(val), "ui")
end


--@api-stub: LSplitPanel:setMinPanelSize
do -- LSplitPanel:setMinPanelSize
  local split = lurek.ui.newSplitPanel("vertical")
  split:setMinPanelSize(1.0)
  lurek.log.info("LSplitPanel:setMinPanelSize applied", "ui")
end


--@api-stub: LSplitPanel:setFirstChild
do -- LSplitPanel:setFirstChild
  local split = lurek.ui.newSplitPanel("vertical")
  split:setFirstChild(1)
  lurek.log.info("LSplitPanel:setFirstChild applied", "ui")
end


--@api-stub: LSplitPanel:setSecondChild
do -- LSplitPanel:setSecondChild
  local split = lurek.ui.newSplitPanel("vertical")
  split:setSecondChild(1)
  lurek.log.info("LSplitPanel:setSecondChild applied", "ui")
end


--@api-stub: LSplitPanel:getFirstChild
do -- LSplitPanel:getFirstChild
  local split = lurek.ui.newSplitPanel("vertical")
  local val = split:getFirstChild()
  lurek.log.info("LSplitPanel:getFirstChild=" .. tostring(val), "ui")
end


--@api-stub: LSplitPanel:getSecondChild
do -- LSplitPanel:getSecondChild
  local split = lurek.ui.newSplitPanel("vertical")
  local val = split:getSecondChild()
  lurek.log.info("LSplitPanel:getSecondChild=" .. tostring(val), "ui")
end



-- LStatusBar methods


--@api-stub: LStatusBar:addSection
do -- LStatusBar:addSection
  local sbar = lurek.ui.newStatusBar()
  sbar:addSection("Hello, world!", 64.0)
  lurek.log.info("LStatusBar:addSection done", "ui")
end


--@api-stub: LStatusBar:setSectionText
do -- LStatusBar:setSectionText
  local sbar = lurek.ui.newStatusBar()
  sbar:setSectionText(1, "Hello, world!")
  lurek.log.info("LStatusBar:setSectionText applied", "ui")
end


--@api-stub: LStatusBar:getSectionText
do -- LStatusBar:getSectionText
  local sbar = lurek.ui.newStatusBar()
  local val = sbar:getSectionText(1)
  lurek.log.info("LStatusBar:getSectionText=" .. tostring(val), "ui")
end


--@api-stub: LStatusBar:getSectionCount
do -- LStatusBar:getSectionCount
  local sbar = lurek.ui.newStatusBar()
  local val = sbar:getSectionCount()
  lurek.log.info("LStatusBar:getSectionCount=" .. tostring(val), "ui")
end


--@api-stub: LStatusBar:setSectionCount
do -- LStatusBar:setSectionCount
  local sbar = lurek.ui.newStatusBar()
  sbar:setSectionCount(10)
  lurek.log.info("LStatusBar:setSectionCount applied", "ui")
end


--@api-stub: LStatusBar:setSectionWidget
do -- LStatusBar:setSectionWidget
  local sbar = lurek.ui.newStatusBar()
  sbar:setSectionWidget(1, 1.0)
  lurek.log.info("LStatusBar:setSectionWidget applied", "ui")
end



-- LSwitch methods


--@api-stub: LSwitch:setOn
do -- LSwitch:setOn
  local sw = lurek.ui.newSwitch(false)
  sw:setOn(function() end)
  lurek.log.info("LSwitch:setOn callback set", "ui")
end


--@api-stub: LSwitch:isOn
do -- LSwitch:isOn
  local sw = lurek.ui.newSwitch(false)
  local val = sw:isOn()
  lurek.log.info("LSwitch:isOn=" .. tostring(val), "ui")
end


--@api-stub: LSwitch:toggle
do -- LSwitch:toggle
  local sw = lurek.ui.newSwitch(false)
  local val = sw:toggle()
  lurek.log.info("LSwitch:toggle=" .. tostring(val), "ui")
end



-- LTabBar methods


--@api-stub: LTabBar:addTab
do -- LTabBar:addTab
  local tabs = lurek.ui.newTabBar()
  tabs:addTab("Hello")
  lurek.log.info("LTabBar:addTab done", "ui")
end


--@api-stub: LTabBar:removeTab
do -- LTabBar:removeTab
  local tabs = lurek.ui.newTabBar()
  tabs:removeTab(1)
  lurek.log.info("LTabBar:removeTab done", "ui")
end


--@api-stub: LTabBar:getTab
do -- LTabBar:getTab
  local tabs = lurek.ui.newTabBar()
  local val = tabs:getTab(1)
  lurek.log.info("LTabBar:getTab=" .. tostring(val), "ui")
end


--@api-stub: LTabBar:getTabCount
do -- LTabBar:getTabCount
  local tabs = lurek.ui.newTabBar()
  local val = tabs:getTabCount()
  lurek.log.info("LTabBar:getTabCount=" .. tostring(val), "ui")
end


--@api-stub: LTabBar:setActiveTab
do -- LTabBar:setActiveTab
  local tabs = lurek.ui.newTabBar()
  tabs:setActiveTab(1)
  lurek.log.info("LTabBar:setActiveTab applied", "ui")
end


--@api-stub: LTabBar:getActiveTab
do -- LTabBar:getActiveTab
  local tabs = lurek.ui.newTabBar()
  local val = tabs:getActiveTab()
  lurek.log.info("LTabBar:getActiveTab=" .. tostring(val), "ui")
end



-- LTextInput methods


--@api-stub: LTextInput:setText
do -- LTextInput:setText
  local input = lurek.ui.newTextInput()
  input:setText("Hello, world!")
  lurek.log.info("LTextInput:setText applied", "ui")
end


--@api-stub: LTextInput:getText
do -- LTextInput:getText
  local input = lurek.ui.newTextInput()
  local val = input:getText()
  lurek.log.info("LTextInput:getText=" .. tostring(val), "ui")
end


--@api-stub: LTextInput:setPlaceholder
do -- LTextInput:setPlaceholder
  local input = lurek.ui.newTextInput()
  input:setPlaceholder("Hello, world!")
  lurek.log.info("LTextInput:setPlaceholder applied", "ui")
end


--@api-stub: LTextInput:getPlaceholder
do -- LTextInput:getPlaceholder
  local input = lurek.ui.newTextInput()
  local val = input:getPlaceholder()
  lurek.log.info("LTextInput:getPlaceholder=" .. tostring(val), "ui")
end


--@api-stub: LTextInput:setMaxLength
do -- LTextInput:setMaxLength
  local input = lurek.ui.newTextInput()
  input:setMaxLength(5)
  lurek.log.info("LTextInput:setMaxLength applied", "ui")
end


--@api-stub: LTextInput:isFocused
do -- LTextInput:isFocused
  local input = lurek.ui.newTextInput()
  local val = input:isFocused()
  lurek.log.info("LTextInput:isFocused=" .. tostring(val), "ui")
end


--@api-stub: LTextInput:getCursorPosition
do -- LTextInput:getCursorPosition
  local input = lurek.ui.newTextInput()
  local val = input:getCursorPosition()
  lurek.log.info("LTextInput:getCursorPosition=" .. tostring(val), "ui")
end



-- LToast methods


--@api-stub: LToast:setMessage
do -- LToast:setMessage
  local toast = lurek.ui.newToast("Hello!", 2.0)
  toast:setMessage("level_complete")
  lurek.log.info("LToast:setMessage applied", "ui")
end


--@api-stub: LToast:getMessage
do -- LToast:getMessage
  local toast = lurek.ui.newToast("Hello!", 2.0)
  local val = toast:getMessage()
  lurek.log.info("LToast:getMessage=" .. tostring(val), "ui")
end


--@api-stub: LToast:setDuration
do -- LToast:setDuration
  local toast = lurek.ui.newToast("Hello!", 2.0)
  toast:setDuration(1.0)
  lurek.log.info("LToast:setDuration applied", "ui")
end


--@api-stub: LToast:getDuration
do -- LToast:getDuration
  local toast = lurek.ui.newToast("Hello!", 2.0)
  local val = toast:getDuration()
  lurek.log.info("LToast:getDuration=" .. tostring(val), "ui")
end


--@api-stub: LToast:getProgress
do -- LToast:getProgress
  local toast = lurek.ui.newToast("Hello!", 2.0)
  local val = toast:getProgress()
  lurek.log.info("LToast:getProgress=" .. tostring(val), "ui")
end


--@api-stub: LToast:isExpired
do -- LToast:isExpired
  local toast = lurek.ui.newToast("Hello!", 2.0)
  local val = toast:isExpired()
  lurek.log.info("LToast:isExpired=" .. tostring(val), "ui")
end



-- LToolbar methods


--@api-stub: LToolbar:getOrientation
do -- LToolbar:getOrientation
  local tb = lurek.ui.newToolbar("horizontal")
  local val = tb:getOrientation()
  lurek.log.info("LToolbar:getOrientation=" .. tostring(val), "ui")
end


--@api-stub: LToolbar:setOrientation
do -- LToolbar:setOrientation
  local tb = lurek.ui.newToolbar("horizontal")
  tb:setOrientation(1.0)
  lurek.log.info("LToolbar:setOrientation applied", "ui")
end


--@api-stub: LToolbar:addButton
do -- LToolbar:addButton
  local tb = lurek.ui.newToolbar("horizontal")
  tb:addButton(1, 1.0)
  lurek.log.info("LToolbar:addButton done", "ui")
end


--@api-stub: LToolbar:addSeparator
do -- LToolbar:addSeparator
  local tb = lurek.ui.newToolbar("horizontal")
  tb:addSeparator()
  lurek.log.info("LToolbar:addSeparator done", "ui")
end


--@api-stub: LToolbar:addSpacer
do -- LToolbar:addSpacer
  local tb = lurek.ui.newToolbar("horizontal")
  tb:addSpacer(64.0)
  lurek.log.info("LToolbar:addSpacer done", "ui")
end


--@api-stub: LToolbar:getButton
do -- LToolbar:getButton
  local tb = lurek.ui.newToolbar("horizontal")
  local val = tb:getButton(1)
  lurek.log.info("LToolbar:getButton=" .. tostring(val), "ui")
end


--@api-stub: LToolbar:setButtonEnabled
do -- LToolbar:setButtonEnabled
  local tb = lurek.ui.newToolbar("horizontal")
  tb:setButtonEnabled(1, true)
  lurek.log.info("LToolbar:setButtonEnabled applied", "ui")
end


--@api-stub: LToolbar:setButtonToggled
do -- LToolbar:setButtonToggled
  local tb = lurek.ui.newToolbar("horizontal")
  tb:setButtonToggled(1, 1.0)
  lurek.log.info("LToolbar:setButtonToggled applied", "ui")
end


--@api-stub: LToolbar:isButtonToggled
do -- LToolbar:isButtonToggled
  local tb = lurek.ui.newToolbar("horizontal")
  local val = tb:isButtonToggled(1)
  lurek.log.info("LToolbar:isButtonToggled=" .. tostring(val), "ui")
end



-- LTooltipPanel methods


--@api-stub: LTooltipPanel:getText
do -- LTooltipPanel:getText
  local tp = lurek.ui.newTooltipPanel("Info")
  local val = tp:getText()
  lurek.log.info("LTooltipPanel:getText=" .. tostring(val), "ui")
end


--@api-stub: LTooltipPanel:setText
do -- LTooltipPanel:setText
  local tp = lurek.ui.newTooltipPanel("Info")
  tp:setText("Hello, world!")
  lurek.log.info("LTooltipPanel:setText applied", "ui")
end


--@api-stub: LTooltipPanel:getDelay
do -- LTooltipPanel:getDelay
  local tp = lurek.ui.newTooltipPanel("Info")
  local val = tp:getDelay()
  lurek.log.info("LTooltipPanel:getDelay=" .. tostring(val), "ui")
end


--@api-stub: LTooltipPanel:setDelay
do -- LTooltipPanel:setDelay
  local tp = lurek.ui.newTooltipPanel("Info")
  tp:setDelay(1.0)
  lurek.log.info("LTooltipPanel:setDelay applied", "ui")
end


--@api-stub: LTooltipPanel:getTarget
do -- LTooltipPanel:getTarget
  local tp = lurek.ui.newTooltipPanel("Info")
  local val = tp:getTarget()
  lurek.log.info("LTooltipPanel:getTarget=" .. tostring(val), "ui")
end


--@api-stub: LTooltipPanel:setTarget
do -- LTooltipPanel:setTarget
  local tp = lurek.ui.newTooltipPanel("Info")
  tp:setTarget(1.0)
  lurek.log.info("LTooltipPanel:setTarget applied", "ui")
end



-- LTreeView methods


--@api-stub: LTreeView:addNode
do -- LTreeView:addNode
  local tree = lurek.ui.newTreeView()
  tree:addNode("Hello, world!", 1.0)
  lurek.log.info("LTreeView:addNode done", "ui")
end


--@api-stub: LTreeView:toggleNode
do -- LTreeView:toggleNode
  local tree = lurek.ui.newTreeView()
  local val = tree:toggleNode(1)
  lurek.log.info("LTreeView:toggleNode=" .. tostring(val), "ui")
end


--@api-stub: LTreeView:isExpanded
do -- LTreeView:isExpanded
  local tree = lurek.ui.newTreeView()
  local val = tree:isExpanded(1)
  lurek.log.info("LTreeView:isExpanded=" .. tostring(val), "ui")
end


--@api-stub: LTreeView:getNodeCount
do -- LTreeView:getNodeCount
  local tree = lurek.ui.newTreeView()
  local val = tree:getNodeCount()
  lurek.log.info("LTreeView:getNodeCount=" .. tostring(val), "ui")
end


--@api-stub: LTreeView:removeNode
do -- LTreeView:removeNode
  local tree = lurek.ui.newTreeView()
  tree:removeNode(1)
  lurek.log.info("LTreeView:removeNode done", "ui")
end


--@api-stub: LTreeView:clearNodes
do -- LTreeView:clearNodes
  local tree = lurek.ui.newTreeView()
  tree:clearNodes()
  lurek.log.info("LTreeView:clearNodes done", "ui")
end


--@api-stub: LTreeView:getNodeText
do -- LTreeView:getNodeText
  local tree = lurek.ui.newTreeView()
  local val = tree:getNodeText(1)
  lurek.log.info("LTreeView:getNodeText=" .. tostring(val), "ui")
end


--@api-stub: LTreeView:setNodeText
do -- LTreeView:setNodeText
  local tree = lurek.ui.newTreeView()
  tree:setNodeText(1, "Hello, world!")
  lurek.log.info("LTreeView:setNodeText applied", "ui")
end


--@api-stub: LTreeView:setNodeIcon
do -- LTreeView:setNodeIcon
  local tree = lurek.ui.newTreeView()
  tree:setNodeIcon(1, 1.0)
  lurek.log.info("LTreeView:setNodeIcon applied", "ui")
end


--@api-stub: LTreeView:expandNode
do -- LTreeView:expandNode
  local tree = lurek.ui.newTreeView()
  tree:expandNode(1)
  lurek.log.info("LTreeView:expandNode called", "ui")
end


--@api-stub: LTreeView:collapseNode
do -- LTreeView:collapseNode
  local tree = lurek.ui.newTreeView()
  tree:collapseNode(1)
  lurek.log.info("LTreeView:collapseNode called", "ui")
end


--@api-stub: LTreeView:isNodeExpanded
do -- LTreeView:isNodeExpanded
  local tree = lurek.ui.newTreeView()
  local val = tree:isNodeExpanded(1)
  lurek.log.info("LTreeView:isNodeExpanded=" .. tostring(val), "ui")
end


--@api-stub: LTreeView:expandAll
do -- LTreeView:expandAll
  local tree = lurek.ui.newTreeView()
  tree:expandAll()
  lurek.log.info("LTreeView:expandAll called", "ui")
end


--@api-stub: LTreeView:collapseAll
do -- LTreeView:collapseAll
  local tree = lurek.ui.newTreeView()
  tree:collapseAll()
  lurek.log.info("LTreeView:collapseAll called", "ui")
end


--@api-stub: LTreeView:setSelectedNode
do -- LTreeView:setSelectedNode
  local tree = lurek.ui.newTreeView()
  tree:setSelectedNode(1)
  lurek.log.info("LTreeView:setSelectedNode applied", "ui")
end


--@api-stub: LTreeView:getSelectedNode
do -- LTreeView:getSelectedNode
  local tree = lurek.ui.newTreeView()
  local val = tree:getSelectedNode()
  lurek.log.info("LTreeView:getSelectedNode=" .. tostring(val), "ui")
end


--@api-stub: LTreeView:getChildNodes
do -- LTreeView:getChildNodes
  local tree = lurek.ui.newTreeView()
  local val = tree:getChildNodes(1)
  lurek.log.info("LTreeView:getChildNodes=" .. tostring(val), "ui")
end


--@api-stub: LTreeView:getParentNode
do -- LTreeView:getParentNode
  local tree = lurek.ui.newTreeView()
  local val = tree:getParentNode(1)
  lurek.log.info("LTreeView:getParentNode=" .. tostring(val), "ui")
end


--@api-stub: LTreeView:getNodeDepth
do -- LTreeView:getNodeDepth
  local tree = lurek.ui.newTreeView()
  local val = tree:getNodeDepth(1)
  lurek.log.info("LTreeView:getNodeDepth=" .. tostring(val), "ui")
end



-- LUiWidget methods


--@api-stub: LUiWidget:type
do -- LUiWidget:type
  local w = lurek.ui.newPanel()
  local val = w:type()
  lurek.log.info("LUiWidget:type=" .. tostring(val), "ui")
end


--@api-stub: LUiWidget:typeOf
do -- LUiWidget:typeOf
  local w = lurek.ui.newPanel()
  local val = w:typeOf("hero")
  lurek.log.info("LUiWidget:typeOf=" .. tostring(val), "ui")
end


--@api-stub: LUiWidget:setPosition
do -- LUiWidget:setPosition
  local w = lurek.ui.newPanel()
  w:setPosition(0.0, 0.0)
  lurek.log.info("LUiWidget:setPosition applied", "ui")
end


--@api-stub: LUiWidget:getPosition
do -- LUiWidget:getPosition
  local w = lurek.ui.newPanel()
  local val = w:getPosition()
  lurek.log.info("LUiWidget:getPosition=" .. tostring(val), "ui")
end


--@api-stub: LUiWidget:setSize
do -- LUiWidget:setSize
  local w = lurek.ui.newPanel()
  w:setSize(64.0, 64.0)
  lurek.log.info("LUiWidget:setSize applied", "ui")
end


--@api-stub: LUiWidget:getSize
do -- LUiWidget:getSize
  local w = lurek.ui.newPanel()
  local val = w:getSize()
  lurek.log.info("LUiWidget:getSize=" .. tostring(val), "ui")
end


--@api-stub: LUiWidget:getRect
do -- LUiWidget:getRect
  local w = lurek.ui.newPanel()
  local val = w:getRect()
  lurek.log.info("LUiWidget:getRect=" .. tostring(val), "ui")
end


--@api-stub: LUiWidget:setVisible
do -- LUiWidget:setVisible
  local w = lurek.ui.newPanel()
  w:setVisible(1.0)
  lurek.log.info("LUiWidget:setVisible applied", "ui")
end


--@api-stub: LUiWidget:isVisible
do -- LUiWidget:isVisible
  local w = lurek.ui.newPanel()
  local val = w:isVisible()
  lurek.log.info("LUiWidget:isVisible=" .. tostring(val), "ui")
end


--@api-stub: LUiWidget:setEnabled
do -- LUiWidget:setEnabled
  local w = lurek.ui.newPanel()
  w:setEnabled(1.0)
  lurek.log.info("LUiWidget:setEnabled applied", "ui")
end


--@api-stub: LUiWidget:isEnabled
do -- LUiWidget:isEnabled
  local w = lurek.ui.newPanel()
  local val = w:isEnabled()
  lurek.log.info("LUiWidget:isEnabled=" .. tostring(val), "ui")
end


--@api-stub: LUiWidget:setId
do -- LUiWidget:setId
  local w = lurek.ui.newPanel()
  w:setId(1)
  lurek.log.info("LUiWidget:setId applied", "ui")
end


--@api-stub: LUiWidget:getId
do -- LUiWidget:getId
  local w = lurek.ui.newPanel()
  local val = w:getId()
  lurek.log.info("LUiWidget:getId=" .. tostring(val), "ui")
end


--@api-stub: LUiWidget:setTooltip
do -- LUiWidget:setTooltip
  local w = lurek.ui.newPanel()
  w:setTooltip("Hello, world!")
  lurek.log.info("LUiWidget:setTooltip applied", "ui")
end


--@api-stub: LUiWidget:getTooltip
do -- LUiWidget:getTooltip
  local w = lurek.ui.newPanel()
  local val = w:getTooltip()
  lurek.log.info("LUiWidget:getTooltip=" .. tostring(val), "ui")
end


--@api-stub: LUiWidget:getState
do -- LUiWidget:getState
  local w = lurek.ui.newPanel()
  local val = w:getState()
  lurek.log.info("LUiWidget:getState=" .. tostring(val), "ui")
end


--@api-stub: LUiWidget:addChild
do -- LUiWidget:addChild
  local w = lurek.ui.newPanel()
  w:addChild(1.0)
  lurek.log.info("LUiWidget:addChild done", "ui")
end


--@api-stub: LUiWidget:removeChild
do -- LUiWidget:removeChild
  local w = lurek.ui.newPanel()
  w:removeChild(1.0)
  lurek.log.info("LUiWidget:removeChild done", "ui")
end


--@api-stub: LUiWidget:getChildCount
do -- LUiWidget:getChildCount
  local w = lurek.ui.newPanel()
  local val = w:getChildCount()
  lurek.log.info("LUiWidget:getChildCount=" .. tostring(val), "ui")
end


--@api-stub: LUiWidget:getChildren
do -- LUiWidget:getChildren
  local w = lurek.ui.newPanel()
  local val = w:getChildren()
  lurek.log.info("LUiWidget:getChildren=" .. tostring(val), "ui")
end


--@api-stub: LUiWidget:findById
do -- LUiWidget:findById
  local w = lurek.ui.newPanel()
  w:findById(1)
  lurek.log.info("LUiWidget:findById called", "ui")
end


--@api-stub: LUiWidget:setOnClick
do -- LUiWidget:setOnClick
  local w = lurek.ui.newPanel()
  w:setOnClick(function() end)
  lurek.log.info("LUiWidget:setOnClick callback set", "ui")
end


--@api-stub: LUiWidget:setOnChange
do -- LUiWidget:setOnChange
  local w = lurek.ui.newPanel()
  w:setOnChange(function() end)
  lurek.log.info("LUiWidget:setOnChange callback set", "ui")
end


--@api-stub: LUiWidget:setOnDraw
do -- LUiWidget:setOnDraw
  local w = lurek.ui.newPanel()
  w:setOnDraw(function() end)
  lurek.log.info("LUiWidget:setOnDraw callback set", "ui")
end


--@api-stub: LUiWidget:containsPoint
do -- LUiWidget:containsPoint
  local w = lurek.ui.newPanel()
  local val = w:containsPoint(0.0, 0.0)
  lurek.log.info("LUiWidget:containsPoint=" .. tostring(val), "ui")
end


--@api-stub: LUiWidget:setPadding
do -- LUiWidget:setPadding
  local w = lurek.ui.newPanel()
  w:setPadding(64.0, 64.0, 64.0, 64.0)
  lurek.log.info("LUiWidget:setPadding applied", "ui")
end


--@api-stub: LUiWidget:getPadding
do -- LUiWidget:getPadding
  local w = lurek.ui.newPanel()
  local val = w:getPadding()
  lurek.log.info("LUiWidget:getPadding=" .. tostring(val), "ui")
end


--@api-stub: LUiWidget:setMargin
do -- LUiWidget:setMargin
  local w = lurek.ui.newPanel()
  w:setMargin(64.0, 64.0, 64.0, 64.0)
  lurek.log.info("LUiWidget:setMargin applied", "ui")
end


--@api-stub: LUiWidget:getMargin
do -- LUiWidget:getMargin
  local w = lurek.ui.newPanel()
  local val = w:getMargin()
  lurek.log.info("LUiWidget:getMargin=" .. tostring(val), "ui")
end


--@api-stub: LUiWidget:setZOrder
do -- LUiWidget:setZOrder
  local w = lurek.ui.newPanel()
  w:setZOrder(0)
  lurek.log.info("LUiWidget:setZOrder applied", "ui")
end


--@api-stub: LUiWidget:getZOrder
do -- LUiWidget:getZOrder
  local w = lurek.ui.newPanel()
  local val = w:getZOrder()
  lurek.log.info("LUiWidget:getZOrder=" .. tostring(val), "ui")
end


--@api-stub: LUiWidget:setMinSize
do -- LUiWidget:setMinSize
  local w = lurek.ui.newPanel()
  w:setMinSize(64.0, 64.0)
  lurek.log.info("LUiWidget:setMinSize applied", "ui")
end


--@api-stub: LUiWidget:getMinSize
do -- LUiWidget:getMinSize
  local w = lurek.ui.newPanel()
  local val = w:getMinSize()
  lurek.log.info("LUiWidget:getMinSize=" .. tostring(val), "ui")
end


--@api-stub: LUiWidget:setMaxSize
do -- LUiWidget:setMaxSize
  local w = lurek.ui.newPanel()
  w:setMaxSize(64.0, 64.0)
  lurek.log.info("LUiWidget:setMaxSize applied", "ui")
end


--@api-stub: LUiWidget:getMaxSize
do -- LUiWidget:getMaxSize
  local w = lurek.ui.newPanel()
  local val = w:getMaxSize()
  lurek.log.info("LUiWidget:getMaxSize=" .. tostring(val), "ui")
end


--@api-stub: LUiWidget:setAnchor
do -- LUiWidget:setAnchor
  local w = lurek.ui.newPanel()
  w:setAnchor()
  lurek.log.info("LUiWidget:setAnchor applied", "ui")
end


--@api-stub: LUiWidget:setAnchorCenter
do -- LUiWidget:setAnchorCenter
  local w = lurek.ui.newPanel()
  w:setAnchorCenter(1.0, 1.0)
  lurek.log.info("LUiWidget:setAnchorCenter applied", "ui")
end


--@api-stub: LUiWidget:clearAnchor
do -- LUiWidget:clearAnchor
  local w = lurek.ui.newPanel()
  w:clearAnchor()
  lurek.log.info("LUiWidget:clearAnchor done", "ui")
end


--@api-stub: LUiWidget:setFlexGrow
do -- LUiWidget:setFlexGrow
  local w = lurek.ui.newPanel()
  w:setFlexGrow(1.0)
  lurek.log.info("LUiWidget:setFlexGrow applied", "ui")
end


--@api-stub: LUiWidget:getFlexGrow
do -- LUiWidget:getFlexGrow
  local w = lurek.ui.newPanel()
  local val = w:getFlexGrow()
  lurek.log.info("LUiWidget:getFlexGrow=" .. tostring(val), "ui")
end


--@api-stub: LUiWidget:setFlexShrink
do -- LUiWidget:setFlexShrink
  local w = lurek.ui.newPanel()
  w:setFlexShrink(1.0)
  lurek.log.info("LUiWidget:setFlexShrink applied", "ui")
end


--@api-stub: LUiWidget:getFlexShrink
do -- LUiWidget:getFlexShrink
  local w = lurek.ui.newPanel()
  local val = w:getFlexShrink()
  lurek.log.info("LUiWidget:getFlexShrink=" .. tostring(val), "ui")
end


--@api-stub: LUiWidget:bind
do -- LUiWidget:bind
  local w = lurek.ui.newPanel()
  w:bind("player_score")
  lurek.log.info("LUiWidget:bind called", "ui")
end


--@api-stub: LUiWidget:unbind
do -- LUiWidget:unbind
  local w = lurek.ui.newPanel()
  w:unbind()
  lurek.log.info("LUiWidget:unbind called", "ui")
end


--@api-stub: LUiWidget:setAlpha
do -- LUiWidget:setAlpha
  local w = lurek.ui.newPanel()
  w:setAlpha(1.0)
  lurek.log.info("LUiWidget:setAlpha applied", "ui")
end


--@api-stub: LUiWidget:getAlpha
do -- LUiWidget:getAlpha
  local w = lurek.ui.newPanel()
  local val = w:getAlpha()
  lurek.log.info("LUiWidget:getAlpha=" .. tostring(val), "ui")
end


--@api-stub: LUiWidget:fadeIn
do -- LUiWidget:fadeIn
  local w = lurek.ui.newPanel()
  w:fadeIn()
  lurek.log.info("LUiWidget:fadeIn called", "ui")
end


--@api-stub: LUiWidget:fadeOut
do -- LUiWidget:fadeOut
  local w = lurek.ui.newPanel()
  w:fadeOut()
  lurek.log.info("LUiWidget:fadeOut called", "ui")
end


--@api-stub: LUiWidget:slideIn
do -- LUiWidget:slideIn
  local w = lurek.ui.newPanel()
  w:slideIn(0.0, 0.0)
  lurek.log.info("LUiWidget:slideIn called", "ui")
end


--@api-stub: LUiWidget:slideOut
do -- LUiWidget:slideOut
  local w = lurek.ui.newPanel()
  w:slideOut(0.0, 0.0)
  lurek.log.info("LUiWidget:slideOut called", "ui")
end


--@api-stub: LUiWidget:attachToEntity
do -- LUiWidget:attachToEntity
  local w = lurek.ui.newPanel()
  w:attachToEntity(1.0)
  lurek.log.info("LUiWidget:attachToEntity called", "ui")
end


--@api-stub: LUiWidget:detachFromEntity
do -- LUiWidget:detachFromEntity
  local w = lurek.ui.newPanel()
  w:detachFromEntity()
  lurek.log.info("LUiWidget:detachFromEntity called", "ui")
end

