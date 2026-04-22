-- content/examples/ui.lua
-- love2d-style usage snippets for the lurek.ui API (363 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/ui.lua

-- ── lurek.ui.* functions ──

--@api-stub: lurek.ui.setPosition
-- Sets the widget position.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.ui.setPosition(100, 100)
print("setPosition applied")
print("ok")

--@api-stub: lurek.ui.getPosition
-- Returns the widget position.
-- Cheap to call; safe inside callbacks.
local value = lurek.ui.getPosition()
print("getPosition:", value)
return value

--@api-stub: lurek.ui.setSize
-- Sets the width and height of the widget in UI pixels.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.ui.setSize(64, 64)
print("setSize applied")
print("ok")

--@api-stub: lurek.ui.getSize
-- Returns the current width and height of the widget in UI pixels.
-- Cheap to call; safe inside callbacks.
local value = lurek.ui.getSize()
print("getSize:", value)
return value

--@api-stub: lurek.ui.getRect
-- Returns the computed screen-space rectangle after layout.
-- Cheap to call; safe inside callbacks.
local value = lurek.ui.getRect()
print("getRect:", value)
return value

--@api-stub: lurek.ui.setVisible
-- Shows or hides the widget; hidden widgets are not rendered or interactive.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.ui.setVisible(v)
print("setVisible applied")
print("ok")

--@api-stub: lurek.ui.isVisible
-- Returns whether the widget is visible.
-- Use as a guard inside lurek.update or event handlers.
if lurek.ui.isVisible() then
  print("isVisible -> true")
end

--@api-stub: lurek.ui.setEnabled
-- Sets whether the widget is enabled.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.ui.setEnabled(v)
print("setEnabled applied")
print("ok")

--@api-stub: lurek.ui.isEnabled
-- Returns whether the widget is enabled.
-- Use as a guard inside lurek.update or event handlers.
if lurek.ui.isEnabled() then
  print("isEnabled -> true")
end

--@api-stub: lurek.ui.setId
-- Sets the widget string identifier.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.ui.setId(1)
print("setId applied")
print("ok")

--@api-stub: lurek.ui.getId
-- Returns the widget string identifier.
-- Cheap to call; safe inside callbacks.
local value = lurek.ui.getId()
print("getId:", value)
return value

--@api-stub: lurek.ui.setTooltip
-- Sets the widget tooltip text.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.ui.setTooltip("hello")
print("setTooltip applied")
print("ok")

--@api-stub: lurek.ui.getTooltip
-- Returns the widget tooltip text.
-- Cheap to call; safe inside callbacks.
local value = lurek.ui.getTooltip()
print("getTooltip:", value)
return value

--@api-stub: lurek.ui.getState
-- Returns the widget interaction state name.
-- Cheap to call; safe inside callbacks.
local value = lurek.ui.getState()
print("getState:", value)
return value

--@api-stub: lurek.ui.addChild
-- Adds a child widget to this container.
-- Side-effecting; safe to call any time after init.
lurek.ui.addChild(child)
-- mutator; side effect applied
print("addChild done")
print("ok")

--@api-stub: lurek.ui.removeChild
-- Removes a child widget from this container.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.ui.removeChild(child)
print("removeChild done")
print("ok")

--@api-stub: lurek.ui.getChildCount
-- Returns the number of children in this container.
-- Cheap to call; safe inside callbacks.
local value = lurek.ui.getChildCount()
print("getChildCount:", value)
return value

--@api-stub: lurek.ui.getChildren
-- Returns this container's children as widget-handle tables.
-- Cheap to call; safe inside callbacks.
local value = lurek.ui.getChildren()
print("getChildren:", value)
return value

--@api-stub: lurek.ui.findById
-- Recursively searches for a widget by id starting from this widget.
-- Cheap to call; safe inside callbacks.
local value = lurek.ui.findById(1)
print("findById:", value)
return value

--@api-stub: lurek.ui.setOnClick
-- Registers a callback invoked when this widget is clicked.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.ui.setOnClick(f)
print("setOnClick applied")
print("ok")

--@api-stub: lurek.ui.setOnChange
-- Registers a callback invoked when this widget's value changes.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.ui.setOnChange(f)
print("setOnChange applied")
print("ok")

--@api-stub: lurek.ui.setOnDraw
-- Stores a custom draw callback for later invocation.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.ui.setOnDraw(f)
print("setOnDraw applied")
print("ok")

--@api-stub: lurek.ui.containsPoint
-- Returns whether (x, y) is inside this widget.
-- See the module spec for detailed semantics.
local result = lurek.ui.containsPoint(100, 100)
print("containsPoint:", result)
return result

--@api-stub: lurek.ui.setPadding
-- Sets widget padding (CSS-like: top, right?, bottom?, left?).
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.ui.setPadding(top, right, bottom, left)
print("setPadding applied")
print("ok")

--@api-stub: lurek.ui.getPadding
-- Returns the widget padding (top, right, bottom, left).
-- Cheap to call; safe inside callbacks.
local value = lurek.ui.getPadding()
print("getPadding:", value)
return value

--@api-stub: lurek.ui.setMargin
-- Sets widget margin (CSS-like: top, right?, bottom?, left?).
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.ui.setMargin(top, right, bottom, left)
print("setMargin applied")
print("ok")

--@api-stub: lurek.ui.getMargin
-- Returns the widget margin (top, right, bottom, left).
-- Cheap to call; safe inside callbacks.
local value = lurek.ui.getMargin()
print("getMargin:", value)
return value

--@api-stub: lurek.ui.setZOrder
-- Sets the widget z-order for draw sorting.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.ui.setZOrder(0)
print("setZOrder applied")
print("ok")

--@api-stub: lurek.ui.getZOrder
-- Returns the widget z-order.
-- Cheap to call; safe inside callbacks.
local value = lurek.ui.getZOrder()
print("getZOrder:", value)
return value

--@api-stub: lurek.ui.setMinSize
-- Sets the minimum widget size.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.ui.setMinSize(64, 64)
print("setMinSize applied")
print("ok")

--@api-stub: lurek.ui.getMinSize
-- Returns the minimum widget size.
-- Cheap to call; safe inside callbacks.
local value = lurek.ui.getMinSize()
print("getMinSize:", value)
return value

--@api-stub: lurek.ui.setMaxSize
-- Sets the maximum widget size.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.ui.setMaxSize(64, 64)
print("setMaxSize applied")
print("ok")

--@api-stub: lurek.ui.getMaxSize
-- Returns the maximum widget size.
-- Cheap to call; safe inside callbacks.
local value = lurek.ui.getMaxSize()
print("getMaxSize:", value)
return value

--@api-stub: lurek.ui.setAnchor
-- Sets anchor edges (left, top, right, bottom).
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.ui.setAnchor()
print("setAnchor applied")
print("ok")

--@api-stub: lurek.ui.setAnchorCenter
-- Sets center anchor offsets.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.ui.setAnchorCenter(cx, cy)
print("setAnchorCenter applied")
print("ok")

--@api-stub: lurek.ui.clearAnchor
-- Removes all anchor constraints.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.ui.clearAnchor()
print("clearAnchor done")
print("ok")

--@api-stub: lurek.ui.setFlexGrow
-- Sets the flex-grow factor.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.ui.setFlexGrow(grow)
print("setFlexGrow applied")
print("ok")

--@api-stub: lurek.ui.getFlexGrow
-- Returns the flex-grow factor.
-- Cheap to call; safe inside callbacks.
local value = lurek.ui.getFlexGrow()
print("getFlexGrow:", value)
return value

--@api-stub: lurek.ui.setFlexShrink
-- Sets the flex-shrink factor.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.ui.setFlexShrink(shrink)
print("setFlexShrink applied")
print("ok")

--@api-stub: lurek.ui.getFlexShrink
-- Returns the flex-shrink factor.
-- Cheap to call; safe inside callbacks.
local value = lurek.ui.getFlexShrink()
print("getFlexShrink:", value)
return value

--@api-stub: lurek.ui.bind
-- Registers a data-binding key on this widget.
-- Side-effecting; safe to call any time after init.
lurek.ui.bind("space")
-- mutator; side effect applied
print("bind done")
print("ok")

--@api-stub: lurek.ui.unbind
-- Removes the data-binding key from this widget.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.ui.unbind()
print("unbind done")
print("ok")

--@api-stub: lurek.ui.setAlpha
-- Sets the widget's alpha transparency (`0.0` fully transparent, `1.0` opaque).
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.ui.setAlpha(1)
print("setAlpha applied")
print("ok")

--@api-stub: lurek.ui.getAlpha
-- Returns the widget's current alpha transparency.
-- Cheap to call; safe inside callbacks.
local value = lurek.ui.getAlpha()
print("getAlpha:", value)
return value

--@api-stub: lurek.ui.fadeIn
-- Instantly fades the widget in (sets alpha to `1.0`).
-- See the module spec for detailed semantics.
local result = lurek.ui.fadeIn()
print("fadeIn:", result)
return result

--@api-stub: lurek.ui.fadeOut
-- Instantly fades the widget out (sets alpha to `0.0` and hides it).
-- See the module spec for detailed semantics.
local result = lurek.ui.fadeOut()
print("fadeOut:", result)
return result

--@api-stub: lurek.ui.slideIn
-- Instantly moves the widget to `(x, y)` and makes it visible.
-- See the module spec for detailed semantics.
local result = lurek.ui.slideIn(100, 100)
print("slideIn:", result)
return result

--@api-stub: lurek.ui.slideOut
-- Instantly moves the widget to the off-screen position `(x, y)` and hides it.
-- See the module spec for detailed semantics.
local result = lurek.ui.slideOut(100, 100)
print("slideOut:", result)
return result

--@api-stub: lurek.ui.attachToEntity
-- Anchors this widget to a world-space entity by its numeric ID.
-- Side-effecting; safe to call any time after init.
lurek.ui.attachToEntity(1)
-- mutator; side effect applied
print("attachToEntity done")
print("ok")

--@api-stub: lurek.ui.detachFromEntity
-- Removes the entity anchor from this widget, restoring normal layout positioning.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.ui.detachFromEntity()
print("detachFromEntity done")
print("ok")

-- ── Button methods ──

--@api-stub: Button:setText
-- Sets the text for this Button widget.
-- Apply at startup or in response to user input.
local button = lurek.ui.newButton()
button:setText("hello")
print("Button:setText applied")

--@api-stub: Button:getText
-- Returns the text of this Button widget.
-- Cheap to call; safe inside callbacks.
local button = lurek.ui.newButton()  -- or your existing handle
local value = button:getText()
print("Button:getText ->", value)

-- ── Label methods ──

--@api-stub: Label:setText
-- Sets the text for this Label widget.
-- Apply at startup or in response to user input.
local label = lurek.ui.newLabel()
label:setText("hello")
print("Label:setText applied")

--@api-stub: Label:getText
-- Returns the text of this Label widget.
-- Cheap to call; safe inside callbacks.
local label = lurek.ui.newLabel()  -- or your existing handle
local value = label:getText()
print("Label:getText ->", value)

-- ── Text_Input methods ──

--@api-stub: Text_Input:setText
-- Sets the text for this Text_Input widget.
-- Apply at startup or in response to user input.
local text_Input = lurek.ui.newText_Input()
text_Input:setText("hello")
print("Text_Input:setText applied")

--@api-stub: Text_Input:getText
-- Returns the text of this Text_Input widget.
-- Cheap to call; safe inside callbacks.
local text_Input = lurek.ui.newText_Input()  -- or your existing handle
local value = text_Input:getText()
print("Text_Input:getText ->", value)

--@api-stub: Text_Input:setPlaceholder
-- Sets the placeholder for this Text_Input widget.
-- Apply at startup or in response to user input.
local text_Input = lurek.ui.newText_Input()
text_Input:setPlaceholder("hello")
print("Text_Input:setPlaceholder applied")

--@api-stub: Text_Input:getPlaceholder
-- Returns the placeholder of this Text_Input widget.
-- Cheap to call; safe inside callbacks.
local text_Input = lurek.ui.newText_Input()  -- or your existing handle
local value = text_Input:getPlaceholder()
print("Text_Input:getPlaceholder ->", value)

--@api-stub: Text_Input:setMaxLength
-- Sets the max length for this Text_Input widget.
-- Apply at startup or in response to user input.
local text_Input = lurek.ui.newText_Input()
text_Input:setMaxLength(10)
print("Text_Input:setMaxLength applied")

--@api-stub: Text_Input:isFocused
-- Returns true if focused is enabled for this Text_Input widget.
-- Use as a guard inside lurek.update or event handlers.
local text_Input = lurek.ui.newText_Input()
if text_Input:isFocused() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Text_Input:getCursorPosition
-- Returns the cursor position of this Text_Input widget.
-- Cheap to call; safe inside callbacks.
local text_Input = lurek.ui.newText_Input()  -- or your existing handle
local value = text_Input:getCursorPosition()
print("Text_Input:getCursorPosition ->", value)

-- ── Checkbox methods ──

--@api-stub: Checkbox:setChecked
-- Sets the checked for this Checkbox widget.
-- Apply at startup or in response to user input.
local checkbox = lurek.ui.newCheckbox()
checkbox:setChecked(checked)
print("Checkbox:setChecked applied")

--@api-stub: Checkbox:isChecked
-- Returns true if checked is enabled for this Checkbox widget.
-- Use as a guard inside lurek.update or event handlers.
local checkbox = lurek.ui.newCheckbox()
if checkbox:isChecked() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Checkbox:setText
-- Sets the text for this Checkbox widget.
-- Apply at startup or in response to user input.
local checkbox = lurek.ui.newCheckbox()
checkbox:setText("hello")
print("Checkbox:setText applied")

--@api-stub: Checkbox:getText
-- Returns the text of this Checkbox widget.
-- Cheap to call; safe inside callbacks.
local checkbox = lurek.ui.newCheckbox()  -- or your existing handle
local value = checkbox:getText()
print("Checkbox:getText ->", value)

-- ── Slider methods ──

--@api-stub: Slider:setValue
-- Sets the value for this Slider widget.
-- Apply at startup or in response to user input.
local slider = lurek.ui.newSlider()
slider:setValue(v)
print("Slider:setValue applied")

--@api-stub: Slider:getValue
-- Returns the value of this Slider widget.
-- Cheap to call; safe inside callbacks.
local slider = lurek.ui.newSlider()  -- or your existing handle
local value = slider:getValue()
print("Slider:getValue ->", value)

--@api-stub: Slider:setRange
-- Sets the range for this Slider widget.
-- Apply at startup or in response to user input.
local slider = lurek.ui.newSlider()
slider:setRange(0, 100)
print("Slider:setRange applied")

--@api-stub: Slider:setStep
-- Sets the step for this Slider widget.
-- Apply at startup or in response to user input.
local slider = lurek.ui.newSlider()
slider:setStep(step)
print("Slider:setStep applied")

--@api-stub: Slider:getMin
-- Returns the min of this Slider widget.
-- Cheap to call; safe inside callbacks.
local slider = lurek.ui.newSlider()  -- or your existing handle
local value = slider:getMin()
print("Slider:getMin ->", value)

--@api-stub: Slider:getMax
-- Returns the max of this Slider widget.
-- Cheap to call; safe inside callbacks.
local slider = lurek.ui.newSlider()  -- or your existing handle
local value = slider:getMax()
print("Slider:getMax ->", value)

-- ── Progress_Bar methods ──

--@api-stub: Progress_Bar:setValue
-- Sets the value for this Progress_Bar widget.
-- Apply at startup or in response to user input.
local progress_Bar = lurek.ui.newProgress_Bar()
progress_Bar:setValue(v)
print("Progress_Bar:setValue applied")

--@api-stub: Progress_Bar:getValue
-- Returns the value of this Progress_Bar widget.
-- Cheap to call; safe inside callbacks.
local progress_Bar = lurek.ui.newProgress_Bar()  -- or your existing handle
local value = progress_Bar:getValue()
print("Progress_Bar:getValue ->", value)

--@api-stub: Progress_Bar:getProgress
-- Returns the progress of this Progress_Bar widget.
-- Cheap to call; safe inside callbacks.
local progress_Bar = lurek.ui.newProgress_Bar()  -- or your existing handle
local value = progress_Bar:getProgress()
print("Progress_Bar:getProgress ->", value)

--@api-stub: Progress_Bar:setRange
-- Sets the range for this Progress_Bar widget.
-- Apply at startup or in response to user input.
local progress_Bar = lurek.ui.newProgress_Bar()
progress_Bar:setRange(0, 100)
print("Progress_Bar:setRange applied")

--@api-stub: Progress_Bar:getMin
-- Returns the min of this Progress_Bar widget.
-- Cheap to call; safe inside callbacks.
local progress_Bar = lurek.ui.newProgress_Bar()  -- or your existing handle
local value = progress_Bar:getMin()
print("Progress_Bar:getMin ->", value)

--@api-stub: Progress_Bar:getMax
-- Returns the max of this Progress_Bar widget.
-- Cheap to call; safe inside callbacks.
local progress_Bar = lurek.ui.newProgress_Bar()  -- or your existing handle
local value = progress_Bar:getMax()
print("Progress_Bar:getMax ->", value)

-- ── Combo_Box methods ──

--@api-stub: Combo_Box:addItem
-- Adds a item entry to this Combo_Box widget.
-- Side-effecting; safe to call any time after init.
local combo_Box = lurek.ui.newCombo_Box()
combo_Box:addItem("hello")
print("Combo_Box:addItem done")

--@api-stub: Combo_Box:removeItem
-- Removes the item from this Combo_Box widget.
-- Pair with the matching constructor to free resources.
local combo_Box = lurek.ui.newCombo_Box()
combo_Box:removeItem(1)
-- combo_Box is now released
print("ok")

--@api-stub: Combo_Box:clearItems
-- Clears all items entries from this Combo_Box widget.
-- Pair with the matching constructor to free resources.
local combo_Box = lurek.ui.newCombo_Box()
combo_Box:clearItems()
-- combo_Box is now released
print("ok")

--@api-stub: Combo_Box:getItemCount
-- Returns the item count of this Combo_Box widget.
-- Cheap to call; safe inside callbacks.
local combo_Box = lurek.ui.newCombo_Box()  -- or your existing handle
local value = combo_Box:getItemCount()
print("Combo_Box:getItemCount ->", value)

--@api-stub: Combo_Box:getItem
-- Returns the item of this Combo_Box widget.
-- Cheap to call; safe inside callbacks.
local combo_Box = lurek.ui.newCombo_Box()  -- or your existing handle
local value = combo_Box:getItem(1)
print("Combo_Box:getItem ->", value)

--@api-stub: Combo_Box:setSelectedIndex
-- Sets the selected index for this Combo_Box widget.
-- Apply at startup or in response to user input.
local combo_Box = lurek.ui.newCombo_Box()
combo_Box:setSelectedIndex(1)
print("Combo_Box:setSelectedIndex applied")

--@api-stub: Combo_Box:getSelectedIndex
-- Returns the selected index of this Combo_Box widget.
-- Cheap to call; safe inside callbacks.
local combo_Box = lurek.ui.newCombo_Box()  -- or your existing handle
local value = combo_Box:getSelectedIndex()
print("Combo_Box:getSelectedIndex ->", value)

--@api-stub: Combo_Box:getSelectedItem
-- Returns the selected item of this Combo_Box widget.
-- Cheap to call; safe inside callbacks.
local combo_Box = lurek.ui.newCombo_Box()  -- or your existing handle
local value = combo_Box:getSelectedItem()
print("Combo_Box:getSelectedItem ->", value)

-- ── List_Box methods ──

--@api-stub: List_Box:addItem
-- Adds a item entry to this List_Box widget.
-- Side-effecting; safe to call any time after init.
local list_Box = lurek.ui.newList_Box()
list_Box:addItem("hello")
print("List_Box:addItem done")

--@api-stub: List_Box:removeItem
-- Removes the item from this List_Box widget.
-- Pair with the matching constructor to free resources.
local list_Box = lurek.ui.newList_Box()
list_Box:removeItem(1)
-- list_Box is now released
print("ok")

--@api-stub: List_Box:clearItems
-- Clears all items entries from this List_Box widget.
-- Pair with the matching constructor to free resources.
local list_Box = lurek.ui.newList_Box()
list_Box:clearItems()
-- list_Box is now released
print("ok")

--@api-stub: List_Box:getItemCount
-- Returns the item count of this List_Box widget.
-- Cheap to call; safe inside callbacks.
local list_Box = lurek.ui.newList_Box()  -- or your existing handle
local value = list_Box:getItemCount()
print("List_Box:getItemCount ->", value)

--@api-stub: List_Box:getItem
-- Returns the item of this List_Box widget.
-- Cheap to call; safe inside callbacks.
local list_Box = lurek.ui.newList_Box()  -- or your existing handle
local value = list_Box:getItem(1)
print("List_Box:getItem ->", value)

--@api-stub: List_Box:setSelectedIndex
-- Sets the selected index for this List_Box widget.
-- Apply at startup or in response to user input.
local list_Box = lurek.ui.newList_Box()
list_Box:setSelectedIndex(1)
print("List_Box:setSelectedIndex applied")

--@api-stub: List_Box:getSelectedIndex
-- Returns the selected index of this List_Box widget.
-- Cheap to call; safe inside callbacks.
local list_Box = lurek.ui.newList_Box()  -- or your existing handle
local value = list_Box:getSelectedIndex()
print("List_Box:getSelectedIndex ->", value)

--@api-stub: List_Box:setItemHeight
-- Sets the item height for this List_Box widget.
-- Apply at startup or in response to user input.
local list_Box = lurek.ui.newList_Box()
list_Box:setItemHeight(64)
print("List_Box:setItemHeight applied")

-- ── Tab_Bar methods ──

--@api-stub: Tab_Bar:addTab
-- Adds a tab entry to this Tab_Bar widget.
-- Side-effecting; safe to call any time after init.
local tab_Bar = lurek.ui.newTab_Bar()
tab_Bar:addTab("main")
print("Tab_Bar:addTab done")

--@api-stub: Tab_Bar:removeTab
-- Removes the tab from this Tab_Bar widget.
-- Pair with the matching constructor to free resources.
local tab_Bar = lurek.ui.newTab_Bar()
tab_Bar:removeTab(1)
-- tab_Bar is now released
print("ok")

--@api-stub: Tab_Bar:getTab
-- Returns the tab of this Tab_Bar widget.
-- Cheap to call; safe inside callbacks.
local tab_Bar = lurek.ui.newTab_Bar()  -- or your existing handle
local value = tab_Bar:getTab(1)
print("Tab_Bar:getTab ->", value)

--@api-stub: Tab_Bar:getTabCount
-- Returns the tab count of this Tab_Bar widget.
-- Cheap to call; safe inside callbacks.
local tab_Bar = lurek.ui.newTab_Bar()  -- or your existing handle
local value = tab_Bar:getTabCount()
print("Tab_Bar:getTabCount ->", value)

--@api-stub: Tab_Bar:setActiveTab
-- Sets the active tab for this Tab_Bar widget.
-- Apply at startup or in response to user input.
local tab_Bar = lurek.ui.newTab_Bar()
tab_Bar:setActiveTab(1)
print("Tab_Bar:setActiveTab applied")

--@api-stub: Tab_Bar:getActiveTab
-- Returns the active tab of this Tab_Bar widget.
-- Cheap to call; safe inside callbacks.
local tab_Bar = lurek.ui.newTab_Bar()  -- or your existing handle
local value = tab_Bar:getActiveTab()
print("Tab_Bar:getActiveTab ->", value)

-- ── Spin_Box methods ──

--@api-stub: Spin_Box:setValue
-- Sets the value for this SpinBox widget.
-- Apply at startup or in response to user input.
local spin_Box = lurek.ui.newSpin_Box()
spin_Box:setValue(v)
print("Spin_Box:setValue applied")

--@api-stub: Spin_Box:getValue
-- Returns the current value of this SpinBox widget.
-- Cheap to call; safe inside callbacks.
local spin_Box = lurek.ui.newSpin_Box()  -- or your existing handle
local value = spin_Box:getValue()
print("Spin_Box:getValue ->", value)

--@api-stub: Spin_Box:increment
-- Increments the value by one step.
-- See the module spec for detailed semantics.
local spin_Box = lurek.ui.newSpin_Box()
spin_Box:increment()
print("Spin_Box:increment done")

--@api-stub: Spin_Box:decrement
-- Decrements the value by one step.
-- See the module spec for detailed semantics.
local spin_Box = lurek.ui.newSpin_Box()
spin_Box:decrement()
print("Spin_Box:decrement done")

--@api-stub: Spin_Box:setRange
-- Sets the valid range for this SpinBox widget.
-- Apply at startup or in response to user input.
local spin_Box = lurek.ui.newSpin_Box()
spin_Box:setRange(0, 100)
print("Spin_Box:setRange applied")

--@api-stub: Spin_Box:setStep
-- Sets the increment step for this SpinBox widget.
-- Apply at startup or in response to user input.
local spin_Box = lurek.ui.newSpin_Box()
spin_Box:setStep(step)
print("Spin_Box:setStep applied")

-- ── Switch methods ──

--@api-stub: Switch:setOn
-- Sets the on/off state of this Switch widget.
-- Apply at startup or in response to user input.
local switch = lurek.ui.newSwitch()
switch:setOn(on)
print("Switch:setOn applied")

--@api-stub: Switch:isOn
-- Returns the on/off state of this Switch widget.
-- Use as a guard inside lurek.update or event handlers.
local switch = lurek.ui.newSwitch()
if switch:isOn() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Switch:toggle
-- Toggles the on/off state of this Switch widget.
-- Trigger from input, timers, or game events.
local switch = lurek.ui.newSwitch()
switch:toggle()
-- trigger from input, timer, or event
print("ok")

-- ── Badge methods ──

--@api-stub: Badge:setCount
-- Sets the count displayed on this Badge widget.
-- Apply at startup or in response to user input.
local badge = lurek.ui.newBadge()
badge:setCount(10)
print("Badge:setCount applied")

--@api-stub: Badge:getCount
-- Returns the raw count of this Badge widget.
-- Cheap to call; safe inside callbacks.
local badge = lurek.ui.newBadge()  -- or your existing handle
local value = badge:getCount()
print("Badge:getCount ->", value)

--@api-stub: Badge:getDisplayText
-- Returns the display text of this Badge widget, e.g.
-- Cheap to call; safe inside callbacks.
local badge = lurek.ui.newBadge()  -- or your existing handle
local value = badge:getDisplayText()
print("Badge:getDisplayText ->", value)

-- ── Panel methods ──

--@api-stub: Panel:setTitle
-- Sets the title for this Panel widget.
-- Apply at startup or in response to user input.
local panel = lurek.ui.newPanel()
panel:setTitle(title)
print("Panel:setTitle applied")

--@api-stub: Panel:getTitle
-- Returns the title of this Panel widget.
-- Cheap to call; safe inside callbacks.
local panel = lurek.ui.newPanel()  -- or your existing handle
local value = panel:getTitle()
print("Panel:getTitle ->", value)

--@api-stub: Panel:setScrollable
-- Sets the scrollable for this Panel widget.
-- Apply at startup or in response to user input.
local panel = lurek.ui.newPanel()
panel:setScrollable(scrollable)
print("Panel:setScrollable applied")

-- ── Layout methods ──

--@api-stub: Layout:setDirection
-- Sets the direction for this Layout widget.
-- Apply at startup or in response to user input.
local layout = lurek.ui.newLayout()
layout:setDirection("data/file.txt")
print("Layout:setDirection applied")

--@api-stub: Layout:getDirection
-- Returns the direction of this Layout widget.
-- Cheap to call; safe inside callbacks.
local layout = lurek.ui.newLayout()  -- or your existing handle
local value = layout:getDirection()
print("Layout:getDirection ->", value)

--@api-stub: Layout:setSpacing
-- Sets the spacing for this Layout widget.
-- Apply at startup or in response to user input.
local layout = lurek.ui.newLayout()
layout:setSpacing(spacing)
print("Layout:setSpacing applied")

--@api-stub: Layout:getSpacing
-- Returns the spacing of this Layout widget.
-- Cheap to call; safe inside callbacks.
local layout = lurek.ui.newLayout()  -- or your existing handle
local value = layout:getSpacing()
print("Layout:getSpacing ->", value)

--@api-stub: Layout:setColumns
-- Sets the columns for this Layout widget.
-- Apply at startup or in response to user input.
local layout = lurek.ui.newLayout()
layout:setColumns(10)
print("Layout:setColumns applied")

--@api-stub: Layout:setWrap
-- Sets the wrap for this Layout widget.
-- Apply at startup or in response to user input.
local layout = lurek.ui.newLayout()
layout:setWrap(wrap)
print("Layout:setWrap applied")

--@api-stub: Layout:getWrap
-- Returns the wrap of this Layout widget.
-- Cheap to call; safe inside callbacks.
local layout = lurek.ui.newLayout()  -- or your existing handle
local value = layout:getWrap()
print("Layout:getWrap ->", value)

--@api-stub: Layout:setAlign
-- Sets the align for this Layout widget.
-- Apply at startup or in response to user input.
local layout = lurek.ui.newLayout()
layout:setAlign(align)
print("Layout:setAlign applied")

--@api-stub: Layout:getAlign
-- Returns the align of this Layout widget.
-- Cheap to call; safe inside callbacks.
local layout = lurek.ui.newLayout()  -- or your existing handle
local value = layout:getAlign()
print("Layout:getAlign ->", value)

--@api-stub: Layout:setJustify
-- Sets the justify for this Layout widget.
-- Apply at startup or in response to user input.
local layout = lurek.ui.newLayout()
layout:setJustify(justify)
print("Layout:setJustify applied")

--@api-stub: Layout:getJustify
-- Returns the justify of this Layout widget.
-- Cheap to call; safe inside callbacks.
local layout = lurek.ui.newLayout()  -- or your existing handle
local value = layout:getJustify()
print("Layout:getJustify ->", value)

-- ── Scroll_Panel methods ──

--@api-stub: Scroll_Panel:setContentSize
-- Sets the content size for this Scroll_Panel widget.
-- Apply at startup or in response to user input.
local scroll_Panel = lurek.ui.newScroll_Panel()
scroll_Panel:setContentSize(64, 64)
print("Scroll_Panel:setContentSize applied")

--@api-stub: Scroll_Panel:getContentSize
-- Returns the content size of this Scroll_Panel widget.
-- Cheap to call; safe inside callbacks.
local scroll_Panel = lurek.ui.newScroll_Panel()  -- or your existing handle
local value = scroll_Panel:getContentSize()
print("Scroll_Panel:getContentSize ->", value)

--@api-stub: Scroll_Panel:setScrollPosition
-- Sets the scroll position for this Scroll_Panel widget.
-- Apply at startup or in response to user input.
local scroll_Panel = lurek.ui.newScroll_Panel()
scroll_Panel:setScrollPosition(100, 100)
print("Scroll_Panel:setScrollPosition applied")

--@api-stub: Scroll_Panel:getScrollPosition
-- Returns the scroll position of this Scroll_Panel widget.
-- Cheap to call; safe inside callbacks.
local scroll_Panel = lurek.ui.newScroll_Panel()  -- or your existing handle
local value = scroll_Panel:getScrollPosition()
print("Scroll_Panel:getScrollPosition ->", value)

--@api-stub: Scroll_Panel:getMaxScroll
-- Returns the max scroll of this Scroll_Panel widget.
-- Cheap to call; safe inside callbacks.
local scroll_Panel = lurek.ui.newScroll_Panel()  -- or your existing handle
local value = scroll_Panel:getMaxScroll()
print("Scroll_Panel:getMaxScroll ->", value)

--@api-stub: Scroll_Panel:setScrollSpeed
-- Sets the scroll speed for this Scroll_Panel widget.
-- Apply at startup or in response to user input.
local scroll_Panel = lurek.ui.newScroll_Panel()
scroll_Panel:setScrollSpeed(speed)
print("Scroll_Panel:setScrollSpeed applied")

--@api-stub: Scroll_Panel:getScrollSpeed
-- Returns the scroll speed of this Scroll_Panel widget.
-- Cheap to call; safe inside callbacks.
local scroll_Panel = lurek.ui.newScroll_Panel()  -- or your existing handle
local value = scroll_Panel:getScrollSpeed()
print("Scroll_Panel:getScrollSpeed ->", value)

-- ── Nine_Patch methods ──

--@api-stub: Nine_Patch:setInsets
-- Sets the insets for this Nine_Patch widget.
-- Apply at startup or in response to user input.
local nine_Patch = lurek.ui.newNine_Patch()
nine_Patch:setInsets(left, top, right, bottom)
print("Nine_Patch:setInsets applied")

--@api-stub: Nine_Patch:getInsets
-- Returns the insets of this Nine_Patch widget.
-- Cheap to call; safe inside callbacks.
local nine_Patch = lurek.ui.newNine_Patch()  -- or your existing handle
local value = nine_Patch:getInsets()
print("Nine_Patch:getInsets ->", value)

--@api-stub: Nine_Patch:setImageDimensions
-- Sets the image dimensions for this Nine_Patch widget.
-- Apply at startup or in response to user input.
local nine_Patch = lurek.ui.newNine_Patch()
nine_Patch:setImageDimensions(64, 64)
print("Nine_Patch:setImageDimensions applied")

--@api-stub: Nine_Patch:getImageDimensions
-- Returns the image dimensions of this Nine_Patch widget.
-- Cheap to call; safe inside callbacks.
local nine_Patch = lurek.ui.newNine_Patch()  -- or your existing handle
local value = nine_Patch:getImageDimensions()
print("Nine_Patch:getImageDimensions ->", value)

--@api-stub: Nine_Patch:getSlices
-- Returns the slices of this Nine_Patch widget.
-- Cheap to call; safe inside callbacks.
local nine_Patch = lurek.ui.newNine_Patch()  -- or your existing handle
local value = nine_Patch:getSlices()
print("Nine_Patch:getSlices ->", value)

-- ── Toast methods ──

--@api-stub: Toast:setMessage
-- Sets the message for this Toast widget.
-- Apply at startup or in response to user input.
local toast = lurek.ui.newToast()
toast:setMessage("hello")
print("Toast:setMessage applied")

--@api-stub: Toast:getMessage
-- Returns the message of this Toast widget.
-- Cheap to call; safe inside callbacks.
local toast = lurek.ui.newToast()  -- or your existing handle
local value = toast:getMessage()
print("Toast:getMessage ->", value)

--@api-stub: Toast:setDuration
-- Sets the duration for this Toast widget.
-- Apply at startup or in response to user input.
local toast = lurek.ui.newToast()
toast:setDuration(d)
print("Toast:setDuration applied")

--@api-stub: Toast:getDuration
-- Returns the duration of this Toast widget.
-- Cheap to call; safe inside callbacks.
local toast = lurek.ui.newToast()  -- or your existing handle
local value = toast:getDuration()
print("Toast:getDuration ->", value)

--@api-stub: Toast:getProgress
-- Returns the progress of this Toast widget.
-- Cheap to call; safe inside callbacks.
local toast = lurek.ui.newToast()  -- or your existing handle
local value = toast:getProgress()
print("Toast:getProgress ->", value)

--@api-stub: Toast:isExpired
-- Returns true if expired is enabled for this Toast widget.
-- Use as a guard inside lurek.update or event handlers.
local toast = lurek.ui.newToast()
if toast:isExpired() then print("yes") end
-- swap the constructor for your real handle
print("ok")

-- ── Separator methods ──

--@api-stub: Separator:setVertical
-- Sets the vertical for this Separator widget.
-- Apply at startup or in response to user input.
local separator = lurek.ui.newSeparator()
separator:setVertical(v)
print("Separator:setVertical applied")

--@api-stub: Separator:isVertical
-- Returns true if vertical is enabled for this Separator widget.
-- Use as a guard inside lurek.update or event handlers.
local separator = lurek.ui.newSeparator()
if separator:isVertical() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Separator:setThickness
-- Sets the thickness for this Separator widget.
-- Apply at startup or in response to user input.
local separator = lurek.ui.newSeparator()
separator:setThickness(thickness)
print("Separator:setThickness applied")

--@api-stub: Separator:getThickness
-- Returns the thickness of this Separator widget.
-- Cheap to call; safe inside callbacks.
local separator = lurek.ui.newSeparator()  -- or your existing handle
local value = separator:getThickness()
print("Separator:getThickness ->", value)

-- ── Tree_View methods ──

--@api-stub: Tree_View:addNode
-- Adds a node entry to this Tree_View widget.
-- Side-effecting; safe to call any time after init.
local tree_View = lurek.ui.newTree_View()
tree_View:addNode("hello", 1)
print("Tree_View:addNode done")

--@api-stub: Tree_View:toggleNode
-- Toggles the expanded/collapsed status of a Tree_View node.
-- Trigger from input, timers, or game events.
local tree_View = lurek.ui.newTree_View()
tree_View:toggleNode(1)
-- trigger from input, timer, or event
print("ok")

--@api-stub: Tree_View:isExpanded
-- Returns true if expanded is enabled for this Tree_View widget.
-- Use as a guard inside lurek.update or event handlers.
local tree_View = lurek.ui.newTree_View()
if tree_View:isExpanded(1) then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Tree_View:getNodeCount
-- Returns the node count of this Tree_View widget.
-- Cheap to call; safe inside callbacks.
local tree_View = lurek.ui.newTree_View()  -- or your existing handle
local value = tree_View:getNodeCount()
print("Tree_View:getNodeCount ->", value)

--@api-stub: Tree_View:removeNode
-- Removes the node from this Tree_View widget.
-- Pair with the matching constructor to free resources.
local tree_View = lurek.ui.newTree_View()
tree_View:removeNode(1)
-- tree_View is now released
print("ok")

--@api-stub: Tree_View:clearNodes
-- Clears all nodes entries from this Tree_View widget.
-- Pair with the matching constructor to free resources.
local tree_View = lurek.ui.newTree_View()
tree_View:clearNodes()
-- tree_View is now released
print("ok")

--@api-stub: Tree_View:getNodeText
-- Returns the node text of this Tree_View widget.
-- Cheap to call; safe inside callbacks.
local tree_View = lurek.ui.newTree_View()  -- or your existing handle
local value = tree_View:getNodeText(1)
print("Tree_View:getNodeText ->", value)

--@api-stub: Tree_View:setNodeText
-- Sets the node text for this Tree_View widget.
-- Apply at startup or in response to user input.
local tree_View = lurek.ui.newTree_View()
tree_View:setNodeText(1, "hello")
print("Tree_View:setNodeText applied")

--@api-stub: Tree_View:setNodeIcon
-- Sets the node icon for this Tree_View widget.
-- Apply at startup or in response to user input.
local tree_View = lurek.ui.newTree_View()
tree_View:setNodeIcon(1, icon)
print("Tree_View:setNodeIcon applied")

--@api-stub: Tree_View:expandNode
-- Performs the expand node operation on this Tree_View widget.
-- See the module spec for detailed semantics.
local tree_View = lurek.ui.newTree_View()
tree_View:expandNode(1)
print("Tree_View:expandNode done")

--@api-stub: Tree_View:collapseNode
-- Performs the collapse node operation on this Tree_View widget.
-- See the module spec for detailed semantics.
local tree_View = lurek.ui.newTree_View()
tree_View:collapseNode(1)
print("Tree_View:collapseNode done")

--@api-stub: Tree_View:isNodeExpanded
-- Returns true if node expanded is enabled for this Tree_View widget.
-- Use as a guard inside lurek.update or event handlers.
local tree_View = lurek.ui.newTree_View()
if tree_View:isNodeExpanded(1) then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Tree_View:expandAll
-- Performs the expand all operation on this Tree_View widget.
-- See the module spec for detailed semantics.
local tree_View = lurek.ui.newTree_View()
tree_View:expandAll()
print("Tree_View:expandAll done")

--@api-stub: Tree_View:collapseAll
-- Performs the collapse all operation on this Tree_View widget.
-- See the module spec for detailed semantics.
local tree_View = lurek.ui.newTree_View()
tree_View:collapseAll()
print("Tree_View:collapseAll done")

--@api-stub: Tree_View:setSelectedNode
-- Sets the selected node for this Tree_View widget.
-- Apply at startup or in response to user input.
local tree_View = lurek.ui.newTree_View()
tree_View:setSelectedNode(1)
print("Tree_View:setSelectedNode applied")

--@api-stub: Tree_View:getSelectedNode
-- Returns the selected node of this Tree_View widget.
-- Cheap to call; safe inside callbacks.
local tree_View = lurek.ui.newTree_View()  -- or your existing handle
local value = tree_View:getSelectedNode()
print("Tree_View:getSelectedNode ->", value)

--@api-stub: Tree_View:getChildNodes
-- Returns the child nodes of this Tree_View widget.
-- Cheap to call; safe inside callbacks.
local tree_View = lurek.ui.newTree_View()  -- or your existing handle
local value = tree_View:getChildNodes(1)
print("Tree_View:getChildNodes ->", value)

--@api-stub: Tree_View:getParentNode
-- Returns the parent node of this Tree_View widget.
-- Cheap to call; safe inside callbacks.
local tree_View = lurek.ui.newTree_View()  -- or your existing handle
local value = tree_View:getParentNode(1)
print("Tree_View:getParentNode ->", value)

--@api-stub: Tree_View:getNodeDepth
-- Returns the node depth of this Tree_View widget.
-- Cheap to call; safe inside callbacks.
local tree_View = lurek.ui.newTree_View()  -- or your existing handle
local value = tree_View:getNodeDepth(1)
print("Tree_View:getNodeDepth ->", value)

-- ── Radio_Button methods ──

--@api-stub: Radio_Button:getText
-- Returns the text of this Radio_Button widget.
-- Cheap to call; safe inside callbacks.
local radio_Button = lurek.ui.newRadio_Button()  -- or your existing handle
local value = radio_Button:getText()
print("Radio_Button:getText ->", value)

--@api-stub: Radio_Button:setText
-- Sets the text for this Radio_Button widget.
-- Apply at startup or in response to user input.
local radio_Button = lurek.ui.newRadio_Button()
radio_Button:setText("hello")
print("Radio_Button:setText applied")

--@api-stub: Radio_Button:isSelected
-- Returns true if selected is enabled for this Radio_Button widget.
-- Use as a guard inside lurek.update or event handlers.
local radio_Button = lurek.ui.newRadio_Button()
if radio_Button:isSelected() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Radio_Button:setSelected
-- Sets the selected for this Radio_Button widget.
-- Apply at startup or in response to user input.
local radio_Button = lurek.ui.newRadio_Button()
radio_Button:setSelected(v)
print("Radio_Button:setSelected applied")

--@api-stub: Radio_Button:getGroup
-- Returns the group of this Radio_Button widget.
-- Cheap to call; safe inside callbacks.
local radio_Button = lurek.ui.newRadio_Button()  -- or your existing handle
local value = radio_Button:getGroup()
print("Radio_Button:getGroup ->", value)

--@api-stub: Radio_Button:setGroup
-- Sets the group for this Radio_Button widget.
-- Apply at startup or in response to user input.
local radio_Button = lurek.ui.newRadio_Button()
radio_Button:setGroup(group)
print("Radio_Button:setGroup applied")

--@api-stub: Radio_Button:setOnChange
-- Registers a callback invoked when this widget's value changes.
-- Apply at startup or in response to user input.
local radio_Button = lurek.ui.newRadio_Button()
radio_Button:setOnChange(f)
print("Radio_Button:setOnChange applied")

-- ── Scroll_Bar methods ──

--@api-stub: Scroll_Bar:getScrollPosition
-- Returns the scroll position of this Scroll_Bar widget.
-- Cheap to call; safe inside callbacks.
local scroll_Bar = lurek.ui.newScroll_Bar()  -- or your existing handle
local value = scroll_Bar:getScrollPosition()
print("Scroll_Bar:getScrollPosition ->", value)

--@api-stub: Scroll_Bar:setScrollPosition
-- Sets the scroll position for this Scroll_Bar widget.
-- Apply at startup or in response to user input.
local scroll_Bar = lurek.ui.newScroll_Bar()
scroll_Bar:setScrollPosition(v)
print("Scroll_Bar:setScrollPosition applied")

--@api-stub: Scroll_Bar:getContentSize
-- Returns the content size of this Scroll_Bar widget.
-- Cheap to call; safe inside callbacks.
local scroll_Bar = lurek.ui.newScroll_Bar()  -- or your existing handle
local value = scroll_Bar:getContentSize()
print("Scroll_Bar:getContentSize ->", value)

--@api-stub: Scroll_Bar:setContentSize
-- Sets the content size for this Scroll_Bar widget.
-- Apply at startup or in response to user input.
local scroll_Bar = lurek.ui.newScroll_Bar()
scroll_Bar:setContentSize(v)
print("Scroll_Bar:setContentSize applied")

--@api-stub: Scroll_Bar:getViewSize
-- Returns the view size of this Scroll_Bar widget.
-- Cheap to call; safe inside callbacks.
local scroll_Bar = lurek.ui.newScroll_Bar()  -- or your existing handle
local value = scroll_Bar:getViewSize()
print("Scroll_Bar:getViewSize ->", value)

--@api-stub: Scroll_Bar:setViewSize
-- Sets the view size for this Scroll_Bar widget.
-- Apply at startup or in response to user input.
local scroll_Bar = lurek.ui.newScroll_Bar()
scroll_Bar:setViewSize(v)
print("Scroll_Bar:setViewSize applied")

--@api-stub: Scroll_Bar:isVertical
-- Returns true if vertical is enabled for this Scroll_Bar widget.
-- Use as a guard inside lurek.update or event handlers.
local scroll_Bar = lurek.ui.newScroll_Bar()
if scroll_Bar:isVertical() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Scroll_Bar:setOnChange
-- Registers a callback invoked when this widget's value changes.
-- Apply at startup or in response to user input.
local scroll_Bar = lurek.ui.newScroll_Bar()
scroll_Bar:setOnChange(f)
print("Scroll_Bar:setOnChange applied")

-- ── Gui_Window methods ──

--@api-stub: Gui_Window:getTitle
-- Returns the title of this Gui_Window widget.
-- Cheap to call; safe inside callbacks.
local gui_Window = lurek.ui.newGui_Window()  -- or your existing handle
local value = gui_Window:getTitle()
print("Gui_Window:getTitle ->", value)

--@api-stub: Gui_Window:setTitle
-- Sets the title for this Gui_Window widget.
-- Apply at startup or in response to user input.
local gui_Window = lurek.ui.newGui_Window()
gui_Window:setTitle(title)
print("Gui_Window:setTitle applied")

--@api-stub: Gui_Window:isCloseable
-- Returns true if closeable is enabled for this Gui_Window widget.
-- Use as a guard inside lurek.update or event handlers.
local gui_Window = lurek.ui.newGui_Window()
if gui_Window:isCloseable() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Gui_Window:setCloseable
-- Sets the closeable for this Gui_Window widget.
-- Apply at startup or in response to user input.
local gui_Window = lurek.ui.newGui_Window()
gui_Window:setCloseable(v)
print("Gui_Window:setCloseable applied")

--@api-stub: Gui_Window:isDraggable
-- Returns true if draggable is enabled for this Gui_Window widget.
-- Use as a guard inside lurek.update or event handlers.
local gui_Window = lurek.ui.newGui_Window()
if gui_Window:isDraggable() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Gui_Window:setDraggable
-- Sets the draggable for this Gui_Window widget.
-- Apply at startup or in response to user input.
local gui_Window = lurek.ui.newGui_Window()
gui_Window:setDraggable(v)
print("Gui_Window:setDraggable applied")

--@api-stub: Gui_Window:isResizable
-- Returns true if resizable is enabled for this Gui_Window widget.
-- Use as a guard inside lurek.update or event handlers.
local gui_Window = lurek.ui.newGui_Window()
if gui_Window:isResizable() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Gui_Window:setResizable
-- Sets the resizable for this Gui_Window widget.
-- Apply at startup or in response to user input.
local gui_Window = lurek.ui.newGui_Window()
gui_Window:setResizable(v)
print("Gui_Window:setResizable applied")

--@api-stub: Gui_Window:setOnClose
-- Registers a callback invoked when this window is closed.
-- Apply at startup or in response to user input.
local gui_Window = lurek.ui.newGui_Window()
gui_Window:setOnClose(f)
print("Gui_Window:setOnClose applied")

-- ── Split_Panel methods ──

--@api-stub: Split_Panel:getOrientation
-- Returns the orientation of this Split_Panel widget.
-- Cheap to call; safe inside callbacks.
local split_Panel = lurek.ui.newSplit_Panel()  -- or your existing handle
local value = split_Panel:getOrientation()
print("Split_Panel:getOrientation ->", value)

--@api-stub: Split_Panel:setOrientation
-- Sets the orientation for this Split_Panel widget.
-- Apply at startup or in response to user input.
local split_Panel = lurek.ui.newSplit_Panel()
split_Panel:setOrientation(v)
print("Split_Panel:setOrientation applied")

--@api-stub: Split_Panel:getSplitPosition
-- Returns the split position of this Split_Panel widget.
-- Cheap to call; safe inside callbacks.
local split_Panel = lurek.ui.newSplit_Panel()  -- or your existing handle
local value = split_Panel:getSplitPosition()
print("Split_Panel:getSplitPosition ->", value)

--@api-stub: Split_Panel:setSplitPosition
-- Sets the split position for this Split_Panel widget.
-- Apply at startup or in response to user input.
local split_Panel = lurek.ui.newSplit_Panel()
split_Panel:setSplitPosition(v)
print("Split_Panel:setSplitPosition applied")

--@api-stub: Split_Panel:getMinPanelSize
-- Returns the min panel size of this Split_Panel widget.
-- Cheap to call; safe inside callbacks.
local split_Panel = lurek.ui.newSplit_Panel()  -- or your existing handle
local value = split_Panel:getMinPanelSize()
print("Split_Panel:getMinPanelSize ->", value)

--@api-stub: Split_Panel:setMinPanelSize
-- Sets the min panel size for this Split_Panel widget.
-- Apply at startup or in response to user input.
local split_Panel = lurek.ui.newSplit_Panel()
split_Panel:setMinPanelSize(v)
print("Split_Panel:setMinPanelSize applied")

--@api-stub: Split_Panel:setFirstChild
-- Sets the first child for this Split_Panel widget.
-- Apply at startup or in response to user input.
local split_Panel = lurek.ui.newSplit_Panel()
split_Panel:setFirstChild(1)
print("Split_Panel:setFirstChild applied")

--@api-stub: Split_Panel:setSecondChild
-- Sets the second child for this Split_Panel widget.
-- Apply at startup or in response to user input.
local split_Panel = lurek.ui.newSplit_Panel()
split_Panel:setSecondChild(1)
print("Split_Panel:setSecondChild applied")

--@api-stub: Split_Panel:getFirstChild
-- Returns the first child of this Split_Panel widget.
-- Cheap to call; safe inside callbacks.
local split_Panel = lurek.ui.newSplit_Panel()  -- or your existing handle
local value = split_Panel:getFirstChild()
print("Split_Panel:getFirstChild ->", value)

--@api-stub: Split_Panel:getSecondChild
-- Returns the second child of this Split_Panel widget.
-- Cheap to call; safe inside callbacks.
local split_Panel = lurek.ui.newSplit_Panel()  -- or your existing handle
local value = split_Panel:getSecondChild()
print("Split_Panel:getSecondChild ->", value)

-- ── Dock_Panel methods ──

--@api-stub: Dock_Panel:dock
-- Performs the dock operation on this Dock_Panel widget.
-- See the module spec for detailed semantics.
local dock_Panel = lurek.ui.newDock_Panel()
dock_Panel:dock(1, side)
print("Dock_Panel:dock done")

--@api-stub: Dock_Panel:undock
-- Performs the undock operation on this Dock_Panel widget.
-- See the module spec for detailed semantics.
local dock_Panel = lurek.ui.newDock_Panel()
dock_Panel:undock(1)
print("Dock_Panel:undock done")

--@api-stub: Dock_Panel:getDockedCount
-- Returns the docked count of this Dock_Panel widget.
-- Cheap to call; safe inside callbacks.
local dock_Panel = lurek.ui.newDock_Panel()  -- or your existing handle
local value = dock_Panel:getDockedCount()
print("Dock_Panel:getDockedCount ->", value)

--@api-stub: Dock_Panel:setSplitSize
-- Sets the split size for this Dock_Panel widget.
-- Apply at startup or in response to user input.
local dock_Panel = lurek.ui.newDock_Panel()
dock_Panel:setSplitSize(side, 10)
print("Dock_Panel:setSplitSize applied")

--@api-stub: Dock_Panel:getSplitSize
-- Returns the split size of this Dock_Panel widget.
-- Cheap to call; safe inside callbacks.
local dock_Panel = lurek.ui.newDock_Panel()  -- or your existing handle
local value = dock_Panel:getSplitSize(side)
print("Dock_Panel:getSplitSize ->", value)

-- ── Toolbar methods ──

--@api-stub: Toolbar:getOrientation
-- Returns the orientation of this Toolbar widget.
-- Cheap to call; safe inside callbacks.
local toolbar = lurek.ui.newToolbar()  -- or your existing handle
local value = toolbar:getOrientation()
print("Toolbar:getOrientation ->", value)

--@api-stub: Toolbar:setOrientation
-- Sets the orientation for this Toolbar widget.
-- Apply at startup or in response to user input.
local toolbar = lurek.ui.newToolbar()
toolbar:setOrientation(v)
print("Toolbar:setOrientation applied")

--@api-stub: Toolbar:addButton
-- Adds a button entry to this Toolbar widget.
-- Side-effecting; safe to call any time after init.
local toolbar = lurek.ui.newToolbar()
toolbar:addButton(1, tooltip)
print("Toolbar:addButton done")

--@api-stub: Toolbar:addSeparator
-- Adds a separator entry to this Toolbar widget.
-- Side-effecting; safe to call any time after init.
local toolbar = lurek.ui.newToolbar()
toolbar:addSeparator()
print("Toolbar:addSeparator done")

--@api-stub: Toolbar:addSpacer
-- Adds a spacer entry to this Toolbar widget.
-- Side-effecting; safe to call any time after init.
local toolbar = lurek.ui.newToolbar()
toolbar:addSpacer(10)
print("Toolbar:addSpacer done")

--@api-stub: Toolbar:getButton
-- Returns the button of this Toolbar widget.
-- Cheap to call; safe inside callbacks.
local toolbar = lurek.ui.newToolbar()  -- or your existing handle
local value = toolbar:getButton(1)
print("Toolbar:getButton ->", value)

--@api-stub: Toolbar:setButtonEnabled
-- Sets the button enabled for this Toolbar widget.
-- Apply at startup or in response to user input.
local toolbar = lurek.ui.newToolbar()
toolbar:setButtonEnabled(1, enabled)
print("Toolbar:setButtonEnabled applied")

--@api-stub: Toolbar:setButtonToggled
-- Sets the button toggled for this Toolbar widget.
-- Apply at startup or in response to user input.
local toolbar = lurek.ui.newToolbar()
toolbar:setButtonToggled(1, toggled)
print("Toolbar:setButtonToggled applied")

--@api-stub: Toolbar:isButtonToggled
-- Returns true if button toggled is enabled for this Toolbar widget.
-- Use as a guard inside lurek.update or event handlers.
local toolbar = lurek.ui.newToolbar()
if toolbar:isButtonToggled(1) then print("yes") end
-- swap the constructor for your real handle
print("ok")

-- ── Menu_Bar methods ──

--@api-stub: Menu_Bar:addMenu
-- Adds a menu entry to this Menu_Bar widget.
-- Side-effecting; safe to call any time after init.
local menu_Bar = lurek.ui.newMenu_Bar()
menu_Bar:addMenu(1)
print("Menu_Bar:addMenu done")

--@api-stub: Menu_Bar:removeMenu
-- Removes the menu from this Menu_Bar widget.
-- Pair with the matching constructor to free resources.
local menu_Bar = lurek.ui.newMenu_Bar()
menu_Bar:removeMenu(1)
-- menu_Bar is now released
print("ok")

--@api-stub: Menu_Bar:getMenus
-- Returns the menus of this Menu_Bar widget.
-- Cheap to call; safe inside callbacks.
local menu_Bar = lurek.ui.newMenu_Bar()  -- or your existing handle
local value = menu_Bar:getMenus()
print("Menu_Bar:getMenus ->", value)

--@api-stub: Menu_Bar:getMenuCount
-- Returns the menu count of this Menu_Bar widget.
-- Cheap to call; safe inside callbacks.
local menu_Bar = lurek.ui.newMenu_Bar()  -- or your existing handle
local value = menu_Bar:getMenuCount()
print("Menu_Bar:getMenuCount ->", value)

-- ── Menu_Item methods ──

--@api-stub: Menu_Item:getText
-- Returns the text of this Menu_Item widget.
-- Cheap to call; safe inside callbacks.
local menu_Item = lurek.ui.newMenu_Item()  -- or your existing handle
local value = menu_Item:getText()
print("Menu_Item:getText ->", value)

--@api-stub: Menu_Item:setText
-- Sets the text for this Menu_Item widget.
-- Apply at startup or in response to user input.
local menu_Item = lurek.ui.newMenu_Item()
menu_Item:setText("hello")
print("Menu_Item:setText applied")

--@api-stub: Menu_Item:getShortcut
-- Returns the shortcut of this Menu_Item widget.
-- Cheap to call; safe inside callbacks.
local menu_Item = lurek.ui.newMenu_Item()  -- or your existing handle
local value = menu_Item:getShortcut()
print("Menu_Item:getShortcut ->", value)

--@api-stub: Menu_Item:setShortcut
-- Sets the shortcut for this Menu_Item widget.
-- Apply at startup or in response to user input.
local menu_Item = lurek.ui.newMenu_Item()
menu_Item:setShortcut(shortcut)
print("Menu_Item:setShortcut applied")

--@api-stub: Menu_Item:isChecked
-- Returns true if checked is enabled for this Menu_Item widget.
-- Use as a guard inside lurek.update or event handlers.
local menu_Item = lurek.ui.newMenu_Item()
if menu_Item:isChecked() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Menu_Item:setChecked
-- Sets the checked for this Menu_Item widget.
-- Apply at startup or in response to user input.
local menu_Item = lurek.ui.newMenu_Item()
menu_Item:setChecked(v)
print("Menu_Item:setChecked applied")

--@api-stub: Menu_Item:addSubItem
-- Adds a sub item entry to this Menu_Item widget.
-- Side-effecting; safe to call any time after init.
local menu_Item = lurek.ui.newMenu_Item()
menu_Item:addSubItem(1)
print("Menu_Item:addSubItem done")

--@api-stub: Menu_Item:getSubItems
-- Returns the sub items of this Menu_Item widget.
-- Cheap to call; safe inside callbacks.
local menu_Item = lurek.ui.newMenu_Item()  -- or your existing handle
local value = menu_Item:getSubItems()
print("Menu_Item:getSubItems ->", value)

--@api-stub: Menu_Item:setOnClick
-- Registers a callback invoked when this menu item is clicked.
-- Apply at startup or in response to user input.
local menu_Item = lurek.ui.newMenu_Item()
menu_Item:setOnClick(f)
print("Menu_Item:setOnClick applied")

-- ── Dialog methods ──

--@api-stub: Dialog:getTitle
-- Returns the title of this Dialog widget.
-- Cheap to call; safe inside callbacks.
local dialog = lurek.ui.newDialog()  -- or your existing handle
local value = dialog:getTitle()
print("Dialog:getTitle ->", value)

--@api-stub: Dialog:setTitle
-- Sets the title for this Dialog widget.
-- Apply at startup or in response to user input.
local dialog = lurek.ui.newDialog()
dialog:setTitle(title)
print("Dialog:setTitle applied")

--@api-stub: Dialog:isModal
-- Returns true if modal is enabled for this Dialog widget.
-- Use as a guard inside lurek.update or event handlers.
local dialog = lurek.ui.newDialog()
if dialog:isModal() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Dialog:setModal
-- Sets the modal for this Dialog widget.
-- Apply at startup or in response to user input.
local dialog = lurek.ui.newDialog()
dialog:setModal(v)
print("Dialog:setModal applied")

--@api-stub: Dialog:isOpen
-- Returns true if open is enabled for this Dialog widget.
-- Use as a guard inside lurek.update or event handlers.
local dialog = lurek.ui.newDialog()
if dialog:isOpen() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Dialog:open
-- Performs the open operation on this Dialog widget.
-- Build once at startup; reuse across frames.
local dialog = lurek.ui.newDialog()
dialog:open()
print("Dialog:open done")

--@api-stub: Dialog:close
-- Closes and removes this dialog from the screen.
-- See the module spec for detailed semantics.
local dialog = lurek.ui.newDialog()
dialog:close()
print("Dialog:close done")

--@api-stub: Dialog:setOnClose
-- Registers a callback invoked when this dialog is closed.
-- Apply at startup or in response to user input.
local dialog = lurek.ui.newDialog()
dialog:setOnClose(f)
print("Dialog:setOnClose applied")

--@api-stub: Dialog:setContent
-- Sets the content for this Dialog widget.
-- Apply at startup or in response to user input.
local dialog = lurek.ui.newDialog()
dialog:setContent(1)
print("Dialog:setContent applied")

--@api-stub: Dialog:getContent
-- Returns the content of this Dialog widget.
-- Cheap to call; safe inside callbacks.
local dialog = lurek.ui.newDialog()  -- or your existing handle
local value = dialog:getContent()
print("Dialog:getContent ->", value)

--@api-stub: Dialog:addButton
-- Adds a button entry to this Dialog widget.
-- Side-effecting; safe to call any time after init.
local dialog = lurek.ui.newDialog()
dialog:addButton("hello", function() print("addButton fired") end)
print("Dialog:addButton done")

-- ── Status_Bar methods ──

--@api-stub: Status_Bar:addSection
-- Adds a section entry to this Status_Bar widget.
-- Side-effecting; safe to call any time after init.
local status_Bar = lurek.ui.newStatus_Bar()
status_Bar:addSection("hello", 64)
print("Status_Bar:addSection done")

--@api-stub: Status_Bar:setSectionText
-- Sets the section text for this Status_Bar widget.
-- Apply at startup or in response to user input.
local status_Bar = lurek.ui.newStatus_Bar()
status_Bar:setSectionText(1, "hello")
print("Status_Bar:setSectionText applied")

--@api-stub: Status_Bar:getSectionText
-- Returns the section text of this Status_Bar widget.
-- Cheap to call; safe inside callbacks.
local status_Bar = lurek.ui.newStatus_Bar()  -- or your existing handle
local value = status_Bar:getSectionText(1)
print("Status_Bar:getSectionText ->", value)

--@api-stub: Status_Bar:getSectionCount
-- Returns the section count of this Status_Bar widget.
-- Cheap to call; safe inside callbacks.
local status_Bar = lurek.ui.newStatus_Bar()  -- or your existing handle
local value = status_Bar:getSectionCount()
print("Status_Bar:getSectionCount ->", value)

--@api-stub: Status_Bar:setSectionCount
-- Resizes the section list for this Status_Bar widget.
-- Apply at startup or in response to user input.
local status_Bar = lurek.ui.newStatus_Bar()
status_Bar:setSectionCount(10)
print("Status_Bar:setSectionCount applied")

--@api-stub: Status_Bar:setSectionWidget
-- Compatibility shim for assigning a widget to a section.
-- Apply at startup or in response to user input.
local status_Bar = lurek.ui.newStatus_Bar()
status_Bar:setSectionWidget(1, widget)
print("Status_Bar:setSectionWidget applied")

-- ── Accordion methods ──

--@api-stub: Accordion:addSection
-- Adds a section entry to this Accordion widget.
-- Side-effecting; safe to call any time after init.
local accordion = lurek.ui.newAccordion()
accordion:addSection(title, 1)
print("Accordion:addSection done")

--@api-stub: Accordion:getSectionCount
-- Returns the section count of this Accordion widget.
-- Cheap to call; safe inside callbacks.
local accordion = lurek.ui.newAccordion()  -- or your existing handle
local value = accordion:getSectionCount()
print("Accordion:getSectionCount ->", value)

--@api-stub: Accordion:toggleSection
-- Toggles the expanded/collapsed status of an Accordion section.
-- Trigger from input, timers, or game events.
local accordion = lurek.ui.newAccordion()
accordion:toggleSection(1)
-- trigger from input, timer, or event
print("ok")

--@api-stub: Accordion:isSectionExpanded
-- Returns true if section expanded is enabled for this Accordion widget.
-- Use as a guard inside lurek.update or event handlers.
local accordion = lurek.ui.newAccordion()
if accordion:isSectionExpanded(1) then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Accordion:isExclusive
-- Returns true if exclusive is enabled for this Accordion widget.
-- Use as a guard inside lurek.update or event handlers.
local accordion = lurek.ui.newAccordion()
if accordion:isExclusive() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Accordion:setExclusive
-- Sets the exclusive for this Accordion widget.
-- Apply at startup or in response to user input.
local accordion = lurek.ui.newAccordion()
accordion:setExclusive(v)
print("Accordion:setExclusive applied")

--@api-stub: Accordion:getSectionTitle
-- Returns the section title of this Accordion widget.
-- Cheap to call; safe inside callbacks.
local accordion = lurek.ui.newAccordion()  -- or your existing handle
local value = accordion:getSectionTitle(1)
print("Accordion:getSectionTitle ->", value)

-- ── Tooltip_Panel methods ──

--@api-stub: Tooltip_Panel:getText
-- Returns the text of this Tooltip_Panel widget.
-- Cheap to call; safe inside callbacks.
local tooltip_Panel = lurek.ui.newTooltip_Panel()  -- or your existing handle
local value = tooltip_Panel:getText()
print("Tooltip_Panel:getText ->", value)

--@api-stub: Tooltip_Panel:setText
-- Sets the text for this Tooltip_Panel widget.
-- Apply at startup or in response to user input.
local tooltip_Panel = lurek.ui.newTooltip_Panel()
tooltip_Panel:setText("hello")
print("Tooltip_Panel:setText applied")

--@api-stub: Tooltip_Panel:getDelay
-- Returns the delay of this Tooltip_Panel widget.
-- Cheap to call; safe inside callbacks.
local tooltip_Panel = lurek.ui.newTooltip_Panel()  -- or your existing handle
local value = tooltip_Panel:getDelay()
print("Tooltip_Panel:getDelay ->", value)

--@api-stub: Tooltip_Panel:setDelay
-- Sets the delay for this Tooltip_Panel widget.
-- Apply at startup or in response to user input.
local tooltip_Panel = lurek.ui.newTooltip_Panel()
tooltip_Panel:setDelay(v)
print("Tooltip_Panel:setDelay applied")

--@api-stub: Tooltip_Panel:getTarget
-- Returns the target of this Tooltip_Panel widget.
-- Cheap to call; safe inside callbacks.
local tooltip_Panel = lurek.ui.newTooltip_Panel()  -- or your existing handle
local value = tooltip_Panel:getTarget()
print("Tooltip_Panel:getTarget ->", value)

--@api-stub: Tooltip_Panel:setTarget
-- Sets the target for this Tooltip_Panel widget.
-- Apply at startup or in response to user input.
local tooltip_Panel = lurek.ui.newTooltip_Panel()
tooltip_Panel:setTarget(target)
print("Tooltip_Panel:setTarget applied")

-- ── Color_Picker methods ──

--@api-stub: Color_Picker:getColor
-- Returns the color of this Color_Picker widget.
-- Cheap to call; safe inside callbacks.
local color_Picker = lurek.ui.newColor_Picker()  -- or your existing handle
local value = color_Picker:getColor()
print("Color_Picker:getColor ->", value)

--@api-stub: Color_Picker:setColor
-- Sets the color for this Color_Picker widget.
-- Apply at startup or in response to user input.
local color_Picker = lurek.ui.newColor_Picker()
color_Picker:setColor(1, 0.5, 0, 1)
print("Color_Picker:setColor applied")

--@api-stub: Color_Picker:getShowAlpha
-- Returns the show alpha of this Color_Picker widget.
-- Cheap to call; safe inside callbacks.
local color_Picker = lurek.ui.newColor_Picker()  -- or your existing handle
local value = color_Picker:getShowAlpha()
print("Color_Picker:getShowAlpha ->", value)

--@api-stub: Color_Picker:setShowAlpha
-- Sets the show alpha for this Color_Picker widget.
-- Apply at startup or in response to user input.
local color_Picker = lurek.ui.newColor_Picker()
color_Picker:setShowAlpha(v)
print("Color_Picker:setShowAlpha applied")

--@api-stub: Color_Picker:getColorMode
-- Returns the color mode of this Color_Picker widget.
-- Cheap to call; safe inside callbacks.
local color_Picker = lurek.ui.newColor_Picker()  -- or your existing handle
local value = color_Picker:getColorMode()
print("Color_Picker:getColorMode ->", value)

--@api-stub: Color_Picker:setColorMode
-- Sets the color mode for this Color_Picker widget.
-- Apply at startup or in response to user input.
local color_Picker = lurek.ui.newColor_Picker()
color_Picker:setColorMode(mode)
print("Color_Picker:setColorMode applied")

--@api-stub: Color_Picker:setOnChange
-- Registers a callback invoked when this widget's value changes.
-- Apply at startup or in response to user input.
local color_Picker = lurek.ui.newColor_Picker()
color_Picker:setOnChange(f)
print("Color_Picker:setOnChange applied")

-- ── Gui_Table methods ──

--@api-stub: Gui_Table:addColumn
-- Adds a column entry to this Gui_Table widget.
-- Side-effecting; safe to call any time after init.
local gui_Table = lurek.ui.newGui_Table()
gui_Table:addColumn(header, 64)
print("Gui_Table:addColumn done")

--@api-stub: Gui_Table:getColumnCount
-- Returns the column count of this Gui_Table widget.
-- Cheap to call; safe inside callbacks.
local gui_Table = lurek.ui.newGui_Table()  -- or your existing handle
local value = gui_Table:getColumnCount()
print("Gui_Table:getColumnCount ->", value)

--@api-stub: Gui_Table:addRow
-- Adds a row entry to this Gui_Table widget.
-- Side-effecting; safe to call any time after init.
local gui_Table = lurek.ui.newGui_Table()
gui_Table:addRow(cells)
print("Gui_Table:addRow done")

--@api-stub: Gui_Table:getRowCount
-- Returns the row count of this Gui_Table widget.
-- Cheap to call; safe inside callbacks.
local gui_Table = lurek.ui.newGui_Table()  -- or your existing handle
local value = gui_Table:getRowCount()
print("Gui_Table:getRowCount ->", value)

--@api-stub: Gui_Table:getCell
-- Returns the cell of this Gui_Table widget.
-- Cheap to call; safe inside callbacks.
local gui_Table = lurek.ui.newGui_Table()  -- or your existing handle
local value = gui_Table:getCell(row, col)
print("Gui_Table:getCell ->", value)

--@api-stub: Gui_Table:setCell
-- Sets the cell for this Gui_Table widget.
-- Apply at startup or in response to user input.
local gui_Table = lurek.ui.newGui_Table()
gui_Table:setCell(row, col, "hello")
print("Gui_Table:setCell applied")

--@api-stub: Gui_Table:getSelectedRow
-- Returns the selected row of this Gui_Table widget.
-- Cheap to call; safe inside callbacks.
local gui_Table = lurek.ui.newGui_Table()  -- or your existing handle
local value = gui_Table:getSelectedRow()
print("Gui_Table:getSelectedRow ->", value)

--@api-stub: Gui_Table:setSelectedRow
-- Sets the selected row for this Gui_Table widget.
-- Apply at startup or in response to user input.
local gui_Table = lurek.ui.newGui_Table()
gui_Table:setSelectedRow(row)
print("Gui_Table:setSelectedRow applied")

--@api-stub: Gui_Table:isSortable
-- Returns true if sortable is enabled for this Gui_Table widget.
-- Use as a guard inside lurek.update or event handlers.
local gui_Table = lurek.ui.newGui_Table()
if gui_Table:isSortable() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Gui_Table:setSortable
-- Sets the sortable for this Gui_Table widget.
-- Apply at startup or in response to user input.
local gui_Table = lurek.ui.newGui_Table()
gui_Table:setSortable(v)
print("Gui_Table:setSortable applied")

--@api-stub: Gui_Table:setOnSelect
-- Registers a callback invoked when a table row is selected.
-- Apply at startup or in response to user input.
local gui_Table = lurek.ui.newGui_Table()
gui_Table:setOnSelect(f)
print("Gui_Table:setOnSelect applied")

-- ── Image_Widget methods ──

--@api-stub: Image_Widget:getScaleMode
-- Returns the scale mode of this Image_Widget widget.
-- Cheap to call; safe inside callbacks.
local image_Widget = lurek.ui.newImage_Widget()  -- or your existing handle
local value = image_Widget:getScaleMode()
print("Image_Widget:getScaleMode ->", value)

--@api-stub: Image_Widget:setScaleMode
-- Sets the scale mode for this Image_Widget widget.
-- Apply at startup or in response to user input.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:setScaleMode(mode)
print("Image_Widget:setScaleMode applied")

--@api-stub: Image_Widget:getTint
-- Returns the tint of this Image_Widget widget.
-- Cheap to call; safe inside callbacks.
local image_Widget = lurek.ui.newImage_Widget()  -- or your existing handle
local value = image_Widget:getTint()
print("Image_Widget:getTint ->", value)

--@api-stub: Image_Widget:setTint
-- Sets the tint for this Image_Widget widget.
-- Apply at startup or in response to user input.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:setTint(1, 0.5, 0, 1)
print("Image_Widget:setTint applied")

--@api-stub: Image_Widget:newButton
-- Creates and returns a new interactive button widget as a child of this widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newButton("hello")
print("Image_Widget:newButton done")

--@api-stub: Image_Widget:newLabel
-- Creates a text label widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newLabel("hello")
print("Image_Widget:newLabel done")

--@api-stub: Image_Widget:newTextInput
-- Creates a text input widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newTextInput()
print("Image_Widget:newTextInput done")

--@api-stub: Image_Widget:newCheckbox
-- Creates a checkbox widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newCheckbox("hello")
print("Image_Widget:newCheckbox done")

--@api-stub: Image_Widget:newSlider
-- Creates a value slider widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newSlider(0, 100)
print("Image_Widget:newSlider done")

--@api-stub: Image_Widget:newProgressBar
-- Creates a progress bar widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newProgressBar(0, 100)
print("Image_Widget:newProgressBar done")

--@api-stub: Image_Widget:newComboBox
-- Creates a dropdown combo box widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newComboBox()
print("Image_Widget:newComboBox done")

--@api-stub: Image_Widget:newList
-- Creates a selectable list widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newList()
print("Image_Widget:newList done")

--@api-stub: Image_Widget:newPanel
-- Creates a container panel widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newPanel()
print("Image_Widget:newPanel done")

--@api-stub: Image_Widget:newLayout
-- Creates a flexbox layout container.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newLayout("data/file.txt")
print("Image_Widget:newLayout done")

--@api-stub: Image_Widget:newScrollPanel
-- Creates a scrollable panel widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newScrollPanel()
print("Image_Widget:newScrollPanel done")

--@api-stub: Image_Widget:newNinePatch
-- Creates a 9-patch slicer widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newNinePatch()
print("Image_Widget:newNinePatch done")

--@api-stub: Image_Widget:newTabBar
-- Creates a tab bar widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newTabBar()
print("Image_Widget:newTabBar done")

--@api-stub: Image_Widget:newSeparator
-- Creates a separator line.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newSeparator(vertical)
print("Image_Widget:newSeparator done")

--@api-stub: Image_Widget:newSpacer
-- Creates a spacing filler widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newSpacer(64, 64)
print("Image_Widget:newSpacer done")

--@api-stub: Image_Widget:newToast
-- Creates a toast notification widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newToast(message, 1.0)
print("Image_Widget:newToast done")

--@api-stub: Image_Widget:newTreeView
-- Creates a collapsible tree view widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newTreeView()
print("Image_Widget:newTreeView done")

--@api-stub: Image_Widget:newRadioButton
-- Creates a grouped radio button widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newRadioButton("hello", group)
print("Image_Widget:newRadioButton done")

--@api-stub: Image_Widget:newScrollBar
-- Creates a scroll bar widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newScrollBar(vertical)
print("Image_Widget:newScrollBar done")

--@api-stub: Image_Widget:newWindow
-- Creates a draggable window widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newWindow(title)
print("Image_Widget:newWindow done")

--@api-stub: Image_Widget:newSplitPanel
-- Creates a resizable split panel.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newSplitPanel(orientation)
print("Image_Widget:newSplitPanel done")

--@api-stub: Image_Widget:newDockPanel
-- Creates and returns a new docking panel that arranges children along its edges.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newDockPanel()
print("Image_Widget:newDockPanel done")

--@api-stub: Image_Widget:newToolbar
-- Creates a toolbar widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newToolbar(orientation)
print("Image_Widget:newToolbar done")

--@api-stub: Image_Widget:newMenuBar
-- Creates a menu bar widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newMenuBar()
print("Image_Widget:newMenuBar done")

--@api-stub: Image_Widget:newMenuItem
-- Creates a menu item widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newMenuItem("hello")
print("Image_Widget:newMenuItem done")

--@api-stub: Image_Widget:newDialog
-- Creates a modal dialog widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newDialog(title)
print("Image_Widget:newDialog done")

--@api-stub: Image_Widget:newStatusBar
-- Creates a status bar widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newStatusBar()
print("Image_Widget:newStatusBar done")

--@api-stub: Image_Widget:newAccordion
-- Creates a collapsible accordion widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newAccordion()
print("Image_Widget:newAccordion done")

--@api-stub: Image_Widget:newTooltipPanel
-- Creates a tooltip panel widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newTooltipPanel("hello")
print("Image_Widget:newTooltipPanel done")

--@api-stub: Image_Widget:newColorPicker
-- Creates a color picker widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newColorPicker()
print("Image_Widget:newColorPicker done")

--@api-stub: Image_Widget:newTable
-- Creates a data table widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newTable()
print("Image_Widget:newTable done")

--@api-stub: Image_Widget:newImageWidget
-- Creates an image display widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newImageWidget()
print("Image_Widget:newImageWidget done")

--@api-stub: Image_Widget:newTheme
-- Creates a new theme instance.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newTheme()
print("Image_Widget:newTheme done")

--@api-stub: Image_Widget:setTheme
-- Sets the active GUI theme.
-- Apply at startup or in response to user input.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:setTheme(theme_ud)
print("Image_Widget:setTheme applied")

--@api-stub: Image_Widget:getTheme
-- Returns whether a theme is set.
-- Cheap to call; safe inside callbacks.
local image_Widget = lurek.ui.newImage_Widget()  -- or your existing handle
local value = image_Widget:getTheme()
print("Image_Widget:getTheme ->", value)

--@api-stub: Image_Widget:getRoot
-- Returns the root panel widget table.
-- Cheap to call; safe inside callbacks.
local image_Widget = lurek.ui.newImage_Widget()  -- or your existing handle
local value = image_Widget:getRoot()
print("Image_Widget:getRoot ->", value)

--@api-stub: Image_Widget:setFocus
-- Sets keyboard focus to a widget or clears it.
-- Apply at startup or in response to user input.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:setFocus(widget)
print("Image_Widget:setFocus applied")

--@api-stub: Image_Widget:getFocus
-- Returns the focused widget index or nil.
-- Cheap to call; safe inside callbacks.
local image_Widget = lurek.ui.newImage_Widget()  -- or your existing handle
local value = image_Widget:getFocus()
print("Image_Widget:getFocus ->", value)

--@api-stub: Image_Widget:focusNext
-- Moves focus to the next focusable widget.
-- See the module spec for detailed semantics.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:focusNext()
print("Image_Widget:focusNext done")

--@api-stub: Image_Widget:focusPrev
-- Moves focus to the previous focusable widget.
-- See the module spec for detailed semantics.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:focusPrev()
print("Image_Widget:focusPrev done")

--@api-stub: Image_Widget:clearFocus
-- Removes keyboard focus from this widget so key events go to the next focusable.
-- Pair with the matching constructor to free resources.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:clearFocus()
-- image_Widget is now released
print("ok")

--@api-stub: Image_Widget:addToast
-- Queues a toast notification from a table.
-- Side-effecting; safe to call any time after init.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:addToast({ x = 0, y = 0 })
print("Image_Widget:addToast done")

--@api-stub: Image_Widget:getToastCount
-- Returns the number of active toasts.
-- Cheap to call; safe inside callbacks.
local image_Widget = lurek.ui.newImage_Widget()  -- or your existing handle
local value = image_Widget:getToastCount()
print("Image_Widget:getToastCount ->", value)

--@api-stub: Image_Widget:mousepressed
-- Forwards a mouse press event to the GUI.
-- See the module spec for detailed semantics.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:mousepressed(100, 100, btn)
print("Image_Widget:mousepressed done")

--@api-stub: Image_Widget:mousereleased
-- Forwards a mouse release event to the GUI.
-- See the module spec for detailed semantics.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:mousereleased(100, 100, btn)
print("Image_Widget:mousereleased done")

--@api-stub: Image_Widget:mousemoved
-- Forwards a mouse move event to the GUI.
-- See the module spec for detailed semantics.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:mousemoved(100, 100)
print("Image_Widget:mousemoved done")

--@api-stub: Image_Widget:keypressed
-- Forwards a key press event to the GUI.
-- See the module spec for detailed semantics.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:keypressed("space")
print("Image_Widget:keypressed done")

--@api-stub: Image_Widget:textinput
-- Forwards text input to the focused text input widget.
-- See the module spec for detailed semantics.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:textinput("hello")
print("Image_Widget:textinput done")

--@api-stub: Image_Widget:wheelmoved
-- Forwards a mouse wheel event to the GUI.
-- See the module spec for detailed semantics.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:wheelmoved(100, 100)
print("Image_Widget:wheelmoved done")

--@api-stub: Image_Widget:update
-- Advances toast timers, removes expired toasts, and dispatches pending GUI events.
-- Apply at startup or in response to user input.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:update(dt)
print("Image_Widget:update applied")

--@api-stub: Image_Widget:draw
-- Headless compatibility stub for GUI draw.
-- Place inside `function lurek.render() ... end`.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:draw()
print("Image_Widget:draw done")

--@api-stub: Image_Widget:getWidgetCount
-- Returns the total widget count in the context.
-- Cheap to call; safe inside callbacks.
local image_Widget = lurek.ui.newImage_Widget()  -- or your existing handle
local value = image_Widget:getWidgetCount()
print("Image_Widget:getWidgetCount ->", value)

--@api-stub: Image_Widget:drawToImage
-- Renders the UI widget tree to a CPU ImageData at the given resolution.
-- Place inside `function lurek.render() ... end`.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:drawToImage(64, 64)
print("Image_Widget:drawToImage done")

--@api-stub: Image_Widget:newLineChart
-- Creates a new line chart.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newLineChart({ x = 0, y = 0 })
print("Image_Widget:newLineChart done")

--@api-stub: Image_Widget:newBarChart
-- Creates and returns a new bar chart widget attached to this image widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newBarChart({ x = 0, y = 0 })
print("Image_Widget:newBarChart done")

--@api-stub: Image_Widget:newScatterPlot
-- Creates a new scatter plot.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newScatterPlot({ x = 0, y = 0 })
print("Image_Widget:newScatterPlot done")

--@api-stub: Image_Widget:newPieChart
-- Creates and returns a new pie chart widget attached to this image widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newPieChart({ x = 0, y = 0 })
print("Image_Widget:newPieChart done")

--@api-stub: Image_Widget:newAreaChart
-- Creates a new stacked-area chart.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newAreaChart({ x = 0, y = 0 })
print("Image_Widget:newAreaChart done")

--@api-stub: Image_Widget:newLineChart
-- Creates a new line chart.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newLineChart({ x = 0, y = 0 })
print("Image_Widget:newLineChart done")

--@api-stub: Image_Widget:newBarChart
-- Creates and returns a new bar chart widget attached to this image widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newBarChart({ x = 0, y = 0 })
print("Image_Widget:newBarChart done")

--@api-stub: Image_Widget:newScatterPlot
-- Creates a new scatter plot.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newScatterPlot({ x = 0, y = 0 })
print("Image_Widget:newScatterPlot done")

--@api-stub: Image_Widget:newPieChart
-- Creates and returns a new pie chart widget attached to this image widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newPieChart({ x = 0, y = 0 })
print("Image_Widget:newPieChart done")

--@api-stub: Image_Widget:newAreaChart
-- Creates a new stacked-area chart.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newAreaChart({ x = 0, y = 0 })
print("Image_Widget:newAreaChart done")

--@api-stub: Image_Widget:parseWidgetState
-- Parses a widget state string, returning the canonical form or nil if invalid.
-- See the module spec for detailed semantics.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:parseWidgetState(state)
print("Image_Widget:parseWidgetState done")

--@api-stub: Image_Widget:newSpinBox
-- Creates a numeric spin box widget with increment and decrement buttons.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newSpinBox(0, 100)
print("Image_Widget:newSpinBox done")

--@api-stub: Image_Widget:newSwitch
-- Creates a toggle switch widget.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newSwitch(on)
print("Image_Widget:newSwitch done")

--@api-stub: Image_Widget:newBadge
-- Creates a badge widget displaying a numeric count.
-- Build once at startup; reuse across frames.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:newBadge(10)
print("Image_Widget:newBadge done")

--@api-stub: Image_Widget:setDefaultTheme
-- Installs the built-in dark theme as the active GUI theme.
-- Apply at startup or in response to user input.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:setDefaultTheme()
print("Image_Widget:setDefaultTheme applied")

--@api-stub: Image_Widget:setViewport
-- Sets the viewport dimensions used for anchor constraints and layout.
-- Apply at startup or in response to user input.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:setViewport(64, 64)
print("Image_Widget:setViewport applied")

--@api-stub: Image_Widget:flushCache
-- Returns true if the widget tree changed since the last call, then resets the flag.
-- See the module spec for detailed semantics.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:flushCache()
print("Image_Widget:flushCache done")

--@api-stub: Image_Widget:update_bindings
-- Updates all widgets that have a data-binding key registered via `:bind(key)`.
-- Apply at startup or in response to user input.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:update_bindings()
print("Image_Widget:update_bindings applied")

--@api-stub: Image_Widget:loadLayout
-- Load a widget tree from a Lua table definition and attach it to the UI.
-- May block — call from a worker thread for large payloads.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:loadLayout()
print("Image_Widget:loadLayout done")

--@api-stub: Image_Widget:loadLayoutFile
-- Load a widget tree from a TOML layout file and attach it to the UI root.
-- May block — call from a worker thread for large payloads.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:loadLayoutFile("data/file.txt")
print("Image_Widget:loadLayoutFile done")

--@api-stub: Image_Widget:renderToImage
-- Render the current UI widget tree to a PNG file for testing purposes.
-- See the module spec for detailed semantics.
local image_Widget = lurek.ui.newImage_Widget()
image_Widget:renderToImage(64, 64, "data/file.txt")
print("Image_Widget:renderToImage done")

-- ── LineChart methods ──

--@api-stub: LineChart:setYMax
-- Sets the maximum Y value for axis scaling.
-- Apply at startup or in response to user input.
local lineChart = lurek.ui.newLineChart()
lineChart:setYMax(v)
print("LineChart:setYMax applied")

--@api-stub: LineChart:setXMax
-- Sets the maximum X value for axis scaling.
-- Apply at startup or in response to user input.
local lineChart = lurek.ui.newLineChart()
lineChart:setXMax(v)
print("LineChart:setXMax applied")

--@api-stub: LineChart:drawToImage
-- Renders the line chart into an existing ImageData.
-- Place inside `function lurek.render() ... end`.
local lineChart = lurek.ui.newLineChart()
lineChart:drawToImage()
print("LineChart:drawToImage done")

-- ── BarChart methods ──

--@api-stub: BarChart:drawToImage
-- Renders the bar chart into an existing ImageData.
-- Place inside `function lurek.render() ... end`.
local barChart = lurek.ui.newBarChart()
barChart:drawToImage()
print("BarChart:drawToImage done")

-- ── ScatterPlot methods ──

--@api-stub: ScatterPlot:setXRange
-- Sets the X-axis data range.
-- Apply at startup or in response to user input.
local scatterPlot = lurek.ui.newScatterPlot()
scatterPlot:setXRange(mn, mx)
print("ScatterPlot:setXRange applied")

--@api-stub: ScatterPlot:setYRange
-- Sets the Y-axis data range.
-- Apply at startup or in response to user input.
local scatterPlot = lurek.ui.newScatterPlot()
scatterPlot:setYRange(mn, mx)
print("ScatterPlot:setYRange applied")

--@api-stub: ScatterPlot:drawToImage
-- Renders the scatter plot into an existing ImageData.
-- Place inside `function lurek.render() ... end`.
local scatterPlot = lurek.ui.newScatterPlot()
scatterPlot:drawToImage()
print("ScatterPlot:drawToImage done")

-- ── PieChart methods ──

--@api-stub: PieChart:drawToImage
-- Renders the pie chart into an existing ImageData.
-- Place inside `function lurek.render() ... end`.
local pieChart = lurek.ui.newPieChart()
pieChart:drawToImage()
print("PieChart:drawToImage done")

-- ── AreaChart methods ──

--@api-stub: AreaChart:setYMax
-- Sets the maximum Y value for axis scaling.
-- Apply at startup or in response to user input.
local areaChart = lurek.ui.newAreaChart()
areaChart:setYMax(v)
print("AreaChart:setYMax applied")

--@api-stub: AreaChart:drawToImage
-- Renders the area chart into an existing ImageData.
-- Place inside `function lurek.render() ... end`.
local areaChart = lurek.ui.newAreaChart()
areaChart:drawToImage()
print("AreaChart:drawToImage done")

