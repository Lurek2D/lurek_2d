-- content/examples/terminal.lua
-- love2d-style usage snippets for the lurek.terminal API (82 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/terminal.lua

-- ── lurek.terminal.* functions ──

--@api-stub: lurek.terminal.newTerminal
-- Creates a new terminal grid with the given dimensions.
-- Build once at startup; reuse across frames.
local terminal = lurek.terminal.newTerminal(10, 10)
print("created", terminal)
return terminal

--@api-stub: lurek.terminal.newLabel
-- Creates a new label widget at 1-based coordinates.
-- Build once at startup; reuse across frames.
local label = lurek.terminal.newLabel(col, row, "hello")
print("created", label)
return label

--@api-stub: lurek.terminal.newButton
-- Creates a new button widget at 1-based coordinates.
-- Build once at startup; reuse across frames.
local button = lurek.terminal.newButton()
print("created", button)
return button

--@api-stub: lurek.terminal.newTextBox
-- Creates a new single-line text box widget at 1-based coordinates.
-- Build once at startup; reuse across frames.
local textbox = lurek.terminal.newTextBox(col, row, 64)
print("created", textbox)
return textbox

--@api-stub: lurek.terminal.newList
-- Creates a new scrollable list widget at 1-based coordinates.
-- Build once at startup; reuse across frames.
local list = lurek.terminal.newList(col, row, 64, 64)
print("created", list)
return list

--@api-stub: lurek.terminal.newBorder
-- Creates a new decorative border widget at 1-based coordinates.
-- Build once at startup; reuse across frames.
local border = lurek.terminal.newBorder(col, row, 64, 64)
print("created", border)
return border

--@api-stub: lurek.terminal.newPanel
-- Creates a new container panel widget at 1-based coordinates.
-- Build once at startup; reuse across frames.
local panel = lurek.terminal.newPanel(col, row, 64, 64)
print("created", panel)
return panel

--@api-stub: lurek.terminal.pushScrollback
-- Appends a line to this terminal's scrollback buffer.
-- Side-effecting; safe to call any time after init.
lurek.terminal.pushScrollback(term_ud, line)
-- mutator; side effect applied
print("pushScrollback done")
print("ok")

--@api-stub: lurek.terminal.getScrollback
-- Returns a table of lines from the scrollback buffer.
-- Cheap to call; safe inside callbacks.
local value = lurek.terminal.getScrollback(term_ud, offset, 10)
print("getScrollback:", value)
return value

--@api-stub: lurek.terminal.scrollbackLen
-- Returns the number of lines currently in this terminal's scrollback buffer.
-- See the module spec for detailed semantics.
local result = lurek.terminal.scrollbackLen(term_ud)
print("scrollbackLen:", result)
return result

--@api-stub: lurek.terminal.setScrollbackCap
-- Sets the maximum number of lines retained in the scrollback buffer.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.terminal.setScrollbackCap(term_ud, cap)
print("setScrollbackCap applied")
print("ok")

--@api-stub: lurek.terminal.pushCmdHistory
-- Appends a command string to this terminal's history.
-- Side-effecting; safe to call any time after init.
lurek.terminal.pushCmdHistory(term_ud, cmd)
-- mutator; side effect applied
print("pushCmdHistory done")
print("ok")

--@api-stub: lurek.terminal.prevCmd
-- Steps one entry back in command history (toward older commands).
-- See the module spec for detailed semantics.
local result = lurek.terminal.prevCmd(term_ud)
print("prevCmd:", result)
return result

--@api-stub: lurek.terminal.nextCmd
-- Steps one entry forward in command history (toward newer commands).
-- See the module spec for detailed semantics.
local result = lurek.terminal.nextCmd(term_ud)
print("nextCmd:", result)
return result

--@api-stub: lurek.terminal.cmdHistoryLen
-- Returns the total number of entries in this terminal's command history.
-- See the module spec for detailed semantics.
local result = lurek.terminal.cmdHistoryLen(term_ud)
print("cmdHistoryLen:", result)
return result

--@api-stub: lurek.terminal.clearCmdHistory
-- Clears all entries from this terminal's command history.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.terminal.clearCmdHistory(term_ud)
print("clearCmdHistory done")
print("ok")

--@api-stub: lurek.terminal.applyTheme
-- Applies a named colour theme to a terminal, recolouring all existing cells.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.terminal.applyTheme(term_ud, theme)
print("applyTheme applied")
print("ok")

--@api-stub: lurek.terminal.printHighlighted
-- Prints text at 1-based `(col, row)` with per-keyword colour highlighting.
-- See the module spec for detailed semantics.
local result = lurek.terminal.printHighlighted()
print("printHighlighted:", result)
return result

--@api-stub: lurek.terminal.stripAnsi
-- Strips all ANSI escape codes from `text` and returns the plain string.
-- See the module spec for detailed semantics.
local result = lurek.terminal.stripAnsi("hello")
print("stripAnsi:", result)
return result

--@api-stub: lurek.terminal.parseAnsi
-- Parses `text` into coloured spans.
-- See the module spec for detailed semantics.
local result = lurek.terminal.parseAnsi("hello")
print("parseAnsi:", result)
return result

--@api-stub: lurek.terminal.printAnsi
-- Prints ANSI-escaped `text` onto terminal `t` starting at `(col, row)`.
-- See the module spec for detailed semantics.
local result = lurek.terminal.printAnsi(t_ud, col, row, "hello")
print("printAnsi:", result)
return result

--@api-stub: lurek.terminal.addCompletion
-- Adds a candidate string to the tab-completion engine.
-- Side-effecting; safe to call any time after init.
lurek.terminal.addCompletion(candidate)
-- mutator; side effect applied
print("addCompletion done")
print("ok")

--@api-stub: lurek.terminal.removeCompletion
-- Removes a candidate string from the tab-completion engine.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.terminal.removeCompletion(candidate)
print("removeCompletion done")
print("ok")

--@api-stub: lurek.terminal.clearCompletions
-- Clears all completion candidates.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.terminal.clearCompletions()
print("clearCompletions done")
print("ok")

--@api-stub: lurek.terminal.getCompletions
-- Returns all registered candidates that start with `prefix`, as a sorted array.
-- Cheap to call; safe inside callbacks.
local value = lurek.terminal.getCompletions(prefix)
print("getCompletions:", value)
return value

--@api-stub: lurek.terminal.nextCompletion
-- Returns the next candidate for `prefix`, cycling on repeated calls.
-- See the module spec for detailed semantics.
local result = lurek.terminal.nextCompletion(prefix)
print("nextCompletion:", result)
return result

--@api-stub: lurek.terminal.resetCompletion
-- Resets the cycling cursor without clearing the candidate list.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.terminal.resetCompletion()
print("resetCompletion done")
print("ok")

--@api-stub: lurek.terminal.getMaxCols
-- Returns the maximum number of columns a Terminal can be constructed with.
-- Cheap to call; safe inside callbacks.
local value = lurek.terminal.getMaxCols()
print("getMaxCols:", value)
return value

--@api-stub: lurek.terminal.getMaxRows
-- Returns the maximum number of rows a Terminal can be constructed with.
-- Cheap to call; safe inside callbacks.
local value = lurek.terminal.getMaxRows()
print("getMaxRows:", value)
return value

-- ── Terminal methods ──

--@api-stub: Terminal:set
-- Sets a cell at 1-based coordinates with character FG and BG colours.
-- Apply at startup or in response to user input.
local terminal = lurek.terminal.newTerminal()
terminal:set({ x = 0, y = 0 })
print("Terminal:set applied")

--@api-stub: Terminal:get
-- Returns the cell data at 1-based coordinates.
-- Cheap to call; safe inside callbacks.
local terminal = lurek.terminal.newTerminal()  -- or your existing handle
local value = terminal:get(col, row)
print("Terminal:get ->", value)

--@api-stub: Terminal:clear
-- Clears all cells to defaults.
-- Pair with the matching constructor to free resources.
local terminal = lurek.terminal.newTerminal()
terminal:clear()
-- terminal is now released
print("ok")

--@api-stub: Terminal:getDimensions
-- Returns the terminal grid dimensions.
-- Cheap to call; safe inside callbacks.
local terminal = lurek.terminal.newTerminal()  -- or your existing handle
local value = terminal:getDimensions()
print("Terminal:getDimensions ->", value)

--@api-stub: Terminal:getCellSize
-- Returns the current cell size in pixels derived from the active font.
-- Cheap to call; safe inside callbacks.
local terminal = lurek.terminal.newTerminal()  -- or your existing handle
local value = terminal:getCellSize()
print("Terminal:getCellSize ->", value)

--@api-stub: Terminal:addWidget
-- Attaches a widget to this terminal.
-- Side-effecting; safe to call any time after init.
local terminal = lurek.terminal.newTerminal()
terminal:addWidget(widget_ud)
print("Terminal:addWidget done")

--@api-stub: Terminal:removeWidget
-- Detaches a widget from this terminal.
-- Pair with the matching constructor to free resources.
local terminal = lurek.terminal.newTerminal()
terminal:removeWidget(widget_ud)
-- terminal is now released
print("ok")

--@api-stub: Terminal:clearWidgets
-- Detaches all widgets from this terminal.
-- Pair with the matching constructor to free resources.
local terminal = lurek.terminal.newTerminal()
terminal:clearWidgets()
-- terminal is now released
print("ok")

--@api-stub: Terminal:getWidgetCount
-- Returns the number of attached widgets.
-- Cheap to call; safe inside callbacks.
local terminal = lurek.terminal.newTerminal()  -- or your existing handle
local value = terminal:getWidgetCount()
print("Terminal:getWidgetCount ->", value)

--@api-stub: Terminal:setFocus
-- Sets the focused widget, or clears focus if nil is passed.
-- Apply at startup or in response to user input.
local terminal = lurek.terminal.newTerminal()
terminal:setFocus(value)
print("Terminal:setFocus applied")

--@api-stub: Terminal:getFocused
-- Returns the currently focused widget, or nil.
-- Cheap to call; safe inside callbacks.
local terminal = lurek.terminal.newTerminal()  -- or your existing handle
local value = terminal:getFocused()
print("Terminal:getFocused ->", value)

--@api-stub: Terminal:keypressed
-- Routes a key press to the focused widget and fires callbacks.
-- See the module spec for detailed semantics.
local terminal = lurek.terminal.newTerminal()
terminal:keypressed("space")
print("Terminal:keypressed done")

--@api-stub: Terminal:textinput
-- Routes text input to the focused widget and fires callbacks.
-- See the module spec for detailed semantics.
local terminal = lurek.terminal.newTerminal()
terminal:textinput("hello")
print("Terminal:textinput done")

--@api-stub: Terminal:render
-- Renders the terminal grid and widgets as render commands.
-- See the module spec for detailed semantics.
local terminal = lurek.terminal.newTerminal()
terminal:render(100, 100)
print("Terminal:render done")

--@api-stub: Terminal:setFont
-- Sets the terminal font by pixel height, snapping to the nearest built-in size.
-- Apply at startup or in response to user input.
local terminal = lurek.terminal.newTerminal()
terminal:setFont(64)
print("Terminal:setFont applied")

--@api-stub: Terminal:setCellSize
-- Sets a per-terminal cell pixel size override, bypassing the font-derived size.
-- Apply at startup or in response to user input.
local terminal = lurek.terminal.newTerminal()
terminal:setCellSize(64, 64)
print("Terminal:setCellSize applied")

--@api-stub: Terminal:resetCellSize
-- Removes the cell size override, restoring font-derived cell dimensions.
-- Pair with the matching constructor to free resources.
local terminal = lurek.terminal.newTerminal()
terminal:resetCellSize()
-- terminal is now released
print("ok")

--@api-stub: Terminal:getCellSize
-- Returns the active cell size override as `{w, h}`, or `nil` if none is set.
-- Cheap to call; safe inside callbacks.
local terminal = lurek.terminal.newTerminal()  -- or your existing handle
local value = terminal:getCellSize()
print("Terminal:getCellSize ->", value)

--@api-stub: Terminal:autoResize
-- Resizes the window to exactly fit the terminal grid at the current font size.
-- See the module spec for detailed semantics.
local terminal = lurek.terminal.newTerminal()
terminal:autoResize()
print("Terminal:autoResize done")

-- ── Widget methods ──

--@api-stub: Widget:setPosition
-- Sets the widget position from 1-based coordinates.
-- Apply at startup or in response to user input.
local widget = lurek.terminal.newWidget()
widget:setPosition(col, row)
print("Widget:setPosition applied")

--@api-stub: Widget:getPosition
-- Returns the widget position as 1-based coordinates.
-- Cheap to call; safe inside callbacks.
local widget = lurek.terminal.newWidget()  -- or your existing handle
local value = widget:getPosition()
print("Widget:getPosition ->", value)

--@api-stub: Widget:setSize
-- Sets the widget size in cells.
-- Apply at startup or in response to user input.
local widget = lurek.terminal.newWidget()
widget:setSize(64, 64)
print("Widget:setSize applied")

--@api-stub: Widget:getSize
-- Returns the widget size in cells.
-- Cheap to call; safe inside callbacks.
local widget = lurek.terminal.newWidget()  -- or your existing handle
local value = widget:getSize()
print("Widget:getSize ->", value)

--@api-stub: Widget:setVisible
-- Sets the widget visibility.
-- Apply at startup or in response to user input.
local widget = lurek.terminal.newWidget()
widget:setVisible(visible)
print("Widget:setVisible applied")

--@api-stub: Widget:isVisible
-- Returns whether the widget is visible.
-- Use as a guard inside lurek.update or event handlers.
local widget = lurek.terminal.newWidget()
if widget:isVisible() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Widget:setEnabled
-- Sets whether the widget accepts input.
-- Apply at startup or in response to user input.
local widget = lurek.terminal.newWidget()
widget:setEnabled(enabled)
print("Widget:setEnabled applied")

--@api-stub: Widget:isEnabled
-- Returns whether the widget accepts input.
-- Use as a guard inside lurek.update or event handlers.
local widget = lurek.terminal.newWidget()
if widget:isEnabled() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Widget:setTag
-- Sets the free-form identification tag.
-- Apply at startup or in response to user input.
local widget = lurek.terminal.newWidget()
widget:setTag("main")
print("Widget:setTag applied")

--@api-stub: Widget:getTag
-- Returns the free-form identification tag.
-- Cheap to call; safe inside callbacks.
local widget = lurek.terminal.newWidget()  -- or your existing handle
local value = widget:getTag()
print("Widget:getTag ->", value)

--@api-stub: Widget:setText
-- Sets the text content of a label, button, or text box widget.
-- Apply at startup or in response to user input.
local widget = lurek.terminal.newWidget()
widget:setText("hello")
print("Widget:setText applied")

--@api-stub: Widget:getText
-- Returns the text content of a label, button, or text box widget.
-- Cheap to call; safe inside callbacks.
local widget = lurek.terminal.newWidget()  -- or your existing handle
local value = widget:getText()
print("Widget:getText ->", value)

--@api-stub: Widget:getColor
-- Returns the colour of a label or border widget.
-- Cheap to call; safe inside callbacks.
local widget = lurek.terminal.newWidget()  -- or your existing handle
local value = widget:getColor()
print("Widget:getColor ->", value)

--@api-stub: Widget:setOnClick
-- Registers a click callback for a button widget.
-- Apply at startup or in response to user input.
local widget = lurek.terminal.newWidget()
widget:setOnClick(function() print("setOnClick fired") end)
print("Widget:setOnClick applied")

--@api-stub: Widget:setMaxLength
-- Sets the maximum character length of a text box widget.
-- Apply at startup or in response to user input.
local widget = lurek.terminal.newWidget()
widget:setMaxLength(max_length)
print("Widget:setMaxLength applied")

--@api-stub: Widget:getMaxLength
-- Returns the maximum character length of a text box widget.
-- Cheap to call; safe inside callbacks.
local widget = lurek.terminal.newWidget()  -- or your existing handle
local value = widget:getMaxLength()
print("Widget:getMaxLength ->", value)

--@api-stub: Widget:setOnChange
-- Registers a text change callback for a text box widget.
-- Apply at startup or in response to user input.
local widget = lurek.terminal.newWidget()
widget:setOnChange(function() print("setOnChange fired") end)
print("Widget:setOnChange applied")

--@api-stub: Widget:addItem
-- Adds an item to a list widget.
-- Side-effecting; safe to call any time after init.
local widget = lurek.terminal.newWidget()
widget:addItem(item)
print("Widget:addItem done")

--@api-stub: Widget:removeItem
-- Removes an item from a list widget by 1-based index.
-- Pair with the matching constructor to free resources.
local widget = lurek.terminal.newWidget()
widget:removeItem(1)
-- widget is now released
print("ok")

--@api-stub: Widget:clearItems
-- Removes all items from a list widget.
-- Pair with the matching constructor to free resources.
local widget = lurek.terminal.newWidget()
widget:clearItems()
-- widget is now released
print("ok")

--@api-stub: Widget:getItemCount
-- Returns the number of items in a list widget.
-- Cheap to call; safe inside callbacks.
local widget = lurek.terminal.newWidget()  -- or your existing handle
local value = widget:getItemCount()
print("Widget:getItemCount ->", value)

--@api-stub: Widget:getItem
-- Returns a list item by 1-based index.
-- Cheap to call; safe inside callbacks.
local widget = lurek.terminal.newWidget()  -- or your existing handle
local value = widget:getItem(1)
print("Widget:getItem ->", value)

--@api-stub: Widget:setSelected
-- Sets the selected item in a list widget by 1-based index.
-- Apply at startup or in response to user input.
local widget = lurek.terminal.newWidget()
widget:setSelected(1)
print("Widget:setSelected applied")

--@api-stub: Widget:getSelected
-- Returns the selected item index (1-based) in a list widget, or nil.
-- Cheap to call; safe inside callbacks.
local widget = lurek.terminal.newWidget()  -- or your existing handle
local value = widget:getSelected()
print("Widget:getSelected ->", value)

--@api-stub: Widget:setOnSelect
-- Registers a selection change callback for a list widget.
-- Apply at startup or in response to user input.
local widget = lurek.terminal.newWidget()
widget:setOnSelect(function() print("setOnSelect fired") end)
print("Widget:setOnSelect applied")

--@api-stub: Widget:setStyle
-- Sets the border style of a border widget.
-- Apply at startup or in response to user input.
local widget = lurek.terminal.newWidget()
widget:setStyle("main")
print("Widget:setStyle applied")

--@api-stub: Widget:getStyle
-- Returns the border style name of a border widget.
-- Cheap to call; safe inside callbacks.
local widget = lurek.terminal.newWidget()  -- or your existing handle
local value = widget:getStyle()
print("Widget:getStyle ->", value)

--@api-stub: Widget:setTitle
-- Sets the title of a border widget.
-- Apply at startup or in response to user input.
local widget = lurek.terminal.newWidget()
widget:setTitle(title)
print("Widget:setTitle applied")

--@api-stub: Widget:getTitle
-- Returns the title of a border widget.
-- Cheap to call; safe inside callbacks.
local widget = lurek.terminal.newWidget()  -- or your existing handle
local value = widget:getTitle()
print("Widget:getTitle ->", value)

--@api-stub: Widget:addChild
-- Adds a child widget to a panel widget.
-- Side-effecting; safe to call any time after init.
local widget = lurek.terminal.newWidget()
widget:addChild(child_ud)
print("Widget:addChild done")

--@api-stub: Widget:removeChild
-- Removes a child widget from a panel widget.
-- Pair with the matching constructor to free resources.
local widget = lurek.terminal.newWidget()
widget:removeChild(child_ud)
-- widget is now released
print("ok")

--@api-stub: Widget:clearChildren
-- Removes all children from a panel widget.
-- Pair with the matching constructor to free resources.
local widget = lurek.terminal.newWidget()
widget:clearChildren()
-- widget is now released
print("ok")

--@api-stub: Widget:getChildCount
-- Returns the number of children in a panel widget.
-- Cheap to call; safe inside callbacks.
local widget = lurek.terminal.newWidget()  -- or your existing handle
local value = widget:getChildCount()
print("Widget:getChildCount ->", value)

--@api-stub: Widget:getChild
-- Returns a child widget from a panel by 1-based index, or nil.
-- Cheap to call; safe inside callbacks.
local widget = lurek.terminal.newWidget()  -- or your existing handle
local value = widget:getChild(1)
print("Widget:getChild ->", value)

