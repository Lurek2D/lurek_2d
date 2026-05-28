# Ui

- The `ui` module is a comprehensive Feature Systems tier component that provides a full-featured, retained-mode Graphical User Interface (GUI) toolkit.

Designed for both engine tooling and in-game interfaces, it centers around the `GuiContext`, which manages the stateful widget tree, focus navigation, input routing, and rendering lifecycle. The framework offers an extensive library of over 35 distinct widget types, ranging from core controls (Buttons, Labels, TextInputs, Checkboxes, Sliders, ComboBoxes, ProgressBars) to advanced layout containers (ScrollPanels, SplitPanels, DockPanels) and specialized extras (TreeViews, Toolbars, Menus, Accordions, ColorPickers). All widgets embed a shared `WidgetBase` that handles layout parameters, visibility, anchoring, and transitions.

At the structural level, the module employs a robust flex-based layout engine (`Layout`) that supports vertical, horizontal, and grid packing, alongside alignment, spacing, padding, and min/max constraints. Layouts can be constructed programmatically in Lua or loaded dynamically from declarative TOML files using the built-in layout loader, which dramatically accelerates UI iteration. The visual presentation is governed by a flexible `Theme` system that maps widget states (Normal, Hovered, Pressed, Focused, Disabled) to specific styles containing color palettes, font overrides, borders, and shadows. The module natively supports resolution-independent 9-slice borders (`NinePatch`) and per-widget transition animations (alpha fades, position slides) to deliver a polished, responsive user experience.

Beyond standard UI components and input routing, the module integrates powerful data binding tools. The `GUITable` seamlessly integrates with the `dataframe` module, enabling bulk loading of structured rows directly into UI views without expensive Lua-side iterations. Fully exposed through the `lurek.ui.*` API, this module equips developers with everything needed to build intricate developer dashboards, complex menus, and data-rich game interfaces.

## Functions

### `lurek.ui.addToast`

Adds a toast notification to the queue.

```lua
-- signature
lurek.ui.addToast(toast_table)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `toast_table` | `table` | Table with message (string) and optional duration (number). |

**Example**

```lua
do
    lurek.ui.addToast({ message = "File saved successfully", duration = 3.0, type = "info" })
    print("toast added")
    local layout = lurek.ui.loadLayout({ type = "panel", children = {} })
    print("layout=" .. tostring(layout ~= nil))
end
```

---

### `lurek.ui.animateColor`

Animate widget color tint from one RGBA value to another.

```lua
-- signature
lurek.ui.animateColor(idx, from, to, duration, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | `number` | Widget index. |
| `from` | `table` | Starting color {r, g, b, a} (0-1 range). |
| `to` | `table` | Target color {r, g, b, a} (0-1 range). |
| `duration` | `number` | Duration in seconds. |
| `easing?` | `string` | Easing function name (default "linear"). |

**Returns**

| Type | Description |
|------|-------------|
| `nil` | Schedules the animation; no return value. |

**Example**

```lua
do
    local lbl = lurek.ui.newLabel("Hello")
    lurek.ui.animateColor(lbl._idx, {r=1,g=1,b=1,a=1}, {r=1,g=0.5,b=0,a=1}, 0.5)
    print("lurek.ui.animateColor ok")
end
```

---

### `lurek.ui.animateRotation`

Animate widget rotation from one angle to another (in radians).

```lua
-- signature
lurek.ui.animateRotation(idx, from, to, duration, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | `number` | Widget index. |
| `from` | `number` | Starting angle in radians. |
| `to` | `number` | Target angle in radians. |
| `duration` | `number` | Duration in seconds. |
| `easing?` | `string` | Easing function name (default "linear"). |

**Returns**

| Type | Description |
|------|-------------|
| `nil` | Schedules the animation; no return value. |

**Example**

```lua
do
    local img = lurek.ui.newPanel()
    lurek.ui.animateRotation(img._idx, 0, 360, 1.0)
    print("lurek.ui.animateRotation ok")
end
```

---

### `lurek.ui.animateScale`

Animate widget scale from one value to another.

```lua
-- signature
lurek.ui.animateScale(idx, from_sx, from_sy, to_sx, to_sy, duration, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | `number` | Widget index. |
| `from_sx` | `number` | Starting X scale. |
| `from_sy` | `number` | Starting Y scale. |
| `to_sx` | `number` | Target X scale. |
| `to_sy` | `number` | Target Y scale. |
| `duration` | `number` | Duration in seconds. |
| `easing?` | `string` | Easing function name (default "linear"). |

**Returns**

| Type | Description |
|------|-------------|
| `nil` | Schedules the animation; no return value. |

**Example**

```lua
do
    local btn = lurek.ui.newButton("Scale")
    lurek.ui.animateScale(btn._idx, 1.0, 1.0, 1.2, 1.2, 0.3)
    print("lurek.ui.animateScale ok")
end
```

---

### `lurek.ui.beginDrag`

Begins a drag operation on a widget.

```lua
-- signature
lurek.ui.beginDrag(widget)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `widget` | `table|number` | The widget table or widget index. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the drag started. |

**Example**

```lua
do
    local source = lurek.ui.newPanel()
    local target = lurek.ui.newPanel()
    lurek.ui.beginDrag(source)
    print("active drag:", lurek.ui.getActiveDrag())
    lurek.ui.dropOn(target)
    print("after drop, active drag:", lurek.ui.getActiveDrag())
end
```

---

### `lurek.ui.clear`

Clears all retained UI widgets and transient UI state while keeping the active theme.

```lua
-- signature
lurek.ui.clear()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of widgets removed from the retained UI tree. |

**Example**

```lua
do
    local root = lurek.ui.getRoot()
    if root then
        lurek.ui.clear()
    end
end
```

---

### `lurek.ui.clearFocus`

Clears keyboard focus from all widgets.

```lua
-- signature
lurek.ui.clearFocus()
```

**Example**

```lua
do
    local btn1 = lurek.ui.newButton("First")
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
```

---

### `lurek.ui.clearFont`

Clears the global UI font override so the UI falls back to the active render font again.

```lua
-- signature
lurek.ui.clearFont()
```

**Example**

```lua
do
    -- Example for clearFont
    local widget = lurek.ui.newButton("Test Widget")
    widget:setText("Using clearFont")
    local w, h = widget:getSize()
    lurek.log.info("Invoked clearFont on widget size " .. w .. "x" .. h)
    if w > 0 then widget:setVisible(true) end
end
```

---

### `lurek.ui.draw`

Invokes custom draw callbacks for all widgets that have one registered.

```lua
-- signature
lurek.ui.draw()
```

**Example**

```lua
do
    local w = lurek.ui.newCustomWidget({width=80, height=40})
    lurek.ui.beginDrag(w)
    lurek.ui.endDrag()
    lurek.ui.clearFocus()
    lurek.ui.draw()
    print("beginDrag/endDrag/clearFocus/draw ok")
end
```

---

### `lurek.ui.drawToImage`

Renders the entire UI to an image buffer.

```lua
-- signature
lurek.ui.drawToImage(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Image width in pixels. |
| `h` | `number` | Image height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| `LImageData` | The rendered image. |

**Example**

```lua
do
    local img = lurek.ui.drawToImage(320, 240)
    local w = lurek.ui.newCustomWidget({width=80, height=40})
    lurek.ui.beginDrag(w)
    lurek.ui.dropOn(w)
    lurek.ui.endDrag()
    print("drawToImage ok; dropOn/endDrag ok")
end
```

---

### `lurek.ui.dropOn`

Drops the currently dragged widget onto a target widget.

```lua
-- signature
lurek.ui.dropOn(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | `table|number` | The target widget table or widget index. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the drop succeeded. |

**Example**

```lua
do
    local source = lurek.ui.newPanel()
    local target = lurek.ui.newPanel()
    lurek.ui.beginDrag(source)
    print("active drag:", lurek.ui.getActiveDrag())
    lurek.ui.dropOn(target)
    print("after drop, active drag:", lurek.ui.getActiveDrag())
end
```

---

### `lurek.ui.endDrag`

Ends the current drag operation without dropping.

```lua
-- signature
lurek.ui.endDrag()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The widget index that was being dragged, or nil if no drag was active. |

**Example**

```lua
do
    local img = lurek.ui.drawToImage(320, 240)
    local w = lurek.ui.newCustomWidget({width=80, height=40})
    lurek.ui.beginDrag(w)
    lurek.ui.dropOn(w)
    lurek.ui.endDrag()
    print("drawToImage ok; dropOn/endDrag ok")
end
```

---

### `lurek.ui.flushCache`

Flushes internal UI layout and render caches.

```lua
-- signature
lurek.ui.flushCache()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the cache was flushed. |

**Example**

```lua
do
    lurek.ui.flushCache()
    lurek.ui.focusPrev()
    local drag = lurek.ui.getActiveDrag()
    local focus = lurek.ui.getFocus()
    lurek.ui.clearFocus()
    print("flushCache/focusPrev ok; activeDrag:", drag, "focus:", focus)
end
```

---

### `lurek.ui.focusDirection`

Move focus in a spatial direction. Uses geometry to find nearest focusable widget.

```lua
-- signature
lurek.ui.focusDirection(dx, dy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dx` | `number` | Horizontal direction (-1=left, 1=right, 0=none). |
| `dy` | `number` | Vertical direction (-1=up, 1=down, 0=none). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | Whether focus moved. |

**Example**

```lua
do
    lurek.ui.focusDirection(1.0, 0.0)
    print("lurek.ui.focusDirection ok")
end
```

---

### `lurek.ui.focusNeighbor`

Moves keyboard focus using an explicit directional focus link.

```lua
-- signature
lurek.ui.focusNeighbor(direction)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `direction` | `string` | Direction: "up", "down", "left", or "right". |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when focus was moved to a configured neighbor. |

**Example**

```lua
do
    local a = lurek.ui.newButton("A")
    local b = lurek.ui.newButton("B")
    a:setFocusNeighbor("right", b._idx)
    lurek.ui.setFocus(a)
    local moved = lurek.ui.focusNeighbor("right")
    print("focus moved=" .. tostring(moved))
end
```

---

### `lurek.ui.focusNext`

Moves keyboard focus to the next focusable widget.

```lua
-- signature
lurek.ui.focusNext()
```

**Example**

```lua
do
    local a = lurek.ui.newTextInput()
    local b = lurek.ui.newTextInput()
    local c = lurek.ui.newTextInput()
    lurek.ui.setFocus(a)
    lurek.ui.focusNext()
    print("moved focus forward")
    lurek.ui.focusPrev()
    print("moved focus back")
end
```

---

### `lurek.ui.focusPrev`

Moves keyboard focus to the previous focusable widget.

```lua
-- signature
lurek.ui.focusPrev()
```

**Example**

```lua
do
    local btn1 = lurek.ui.newButton("First")
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
```

---

### `lurek.ui.getActiveDrag`

Returns the widget index currently being dragged, or nil.

```lua
-- signature
lurek.ui.getActiveDrag()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The dragged widget index. |

**Example**

```lua
do
    local source = lurek.ui.newPanel()
    local target = lurek.ui.newPanel()
    lurek.ui.beginDrag(source)
    print("active drag:", lurek.ui.getActiveDrag())
    lurek.ui.dropOn(target)
    print("after drop, active drag:", lurek.ui.getActiveDrag())
end
```

---

### `lurek.ui.getFocus`

Returns the index of the currently focused widget, or nil.

```lua
-- signature
lurek.ui.getFocus()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The focused widget index. |

**Example**

```lua
do
    local btn1 = lurek.ui.newButton("First")
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
```

---

### `lurek.ui.getFont`

Returns the global UI font assigned to the root widget, or nil when UI uses the render fallback font.

```lua
-- signature
lurek.ui.getFont()
```

**Returns**

| Type | Description |
|------|-------------|
| `LFont` | Current global UI font handle. |

**Example**

```lua
do
    -- Example for getFont
    local widget = lurek.ui.newButton("Test Widget")
    widget:setText("Using getFont")
    local w, h = widget:getSize()
    lurek.log.info("Invoked getFont on widget size " .. w .. "x" .. h)
    if w > 0 then widget:setVisible(true) end
end
```

---

### `lurek.ui.getRoot`

Returns the root panel widget of the UI tree.

```lua
-- signature
lurek.ui.getRoot()
```

**Returns**

| Type | Description |
|------|-------------|
| `LPanel` | The root panel widget table. |

**Example**

```lua
do
    local root = lurek.ui.getRoot()
    print("root = " .. tostring(root))
    print("widget count = " .. lurek.ui.getWidgetCount())
end
```

---

### `lurek.ui.getScaleFactor`

Get the current UI scale factor (current_height / base_height).

```lua
-- signature
lurek.ui.getScaleFactor()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The scale factor. |

**Example**

```lua
do
    local sf = lurek.ui.getScaleFactor()
    print("lurek.ui.getScaleFactor=" .. sf)
end
```

---

### `lurek.ui.getStyleToken`

Returns the value of a named semantic style token from the active theme.

```lua
-- signature
lurek.ui.getStyleToken(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | The token name (e.g. "spacing_md", "color_primary"). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The token value for float tokens. |

**Example**

```lua
do
    local spacing = lurek.ui.getStyleToken("spacing_md")
    local color = lurek.ui.getStyleToken("color_primary")
    print("spacing_md=" .. tostring(spacing))
    if type(color) == "table" then
        print("color_primary a=" .. tostring(color.a))
    end
end
```

---

### `lurek.ui.getTheme`

Returns whether a theme is currently set.

```lua
-- signature
lurek.ui.getTheme()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if a theme is active. |

**Example**

```lua
do
    local theme = lurek.ui.newTheme()
    theme:setStyle("button", "normal", { bg_r = 0.2, bg_g = 0.2, bg_b = 0.3, bg_a = 1.0, fg_r = 1.0, fg_g = 1.0, fg_b = 1.0, fg_a = 1.0, })
    theme:setStyle("button", "hovered", { bg_r = 0.3, bg_g = 0.3, bg_b = 0.5, bg_a = 1.0, })
    lurek.ui.setTheme(theme)
    print("theme active:", lurek.ui.getTheme())
    print("theme type:", theme:type())
end
```

---

### `lurek.ui.getToastCount`

Returns the number of active toast notifications.

```lua
-- signature
lurek.ui.getToastCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The toast count. |

**Example**

```lua
do
    lurek.ui.clearFocus()
    local foc = lurek.ui.getFocus()
    local theme = lurek.ui.getTheme()
    local toasts = lurek.ui.getToastCount()
    local widgets = lurek.ui.getWidgetCount()
    print("focus:", foc, "theme:", theme, "toastCount:", toasts, "widgetCount:", widgets)
end
```

---

### `lurek.ui.getWidgetCount`

Returns the total number of widgets in the UI context.

```lua
-- signature
lurek.ui.getWidgetCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The widget count. |

**Example**

```lua
do
    local cnt = lurek.ui.getWidgetCount()
    lurek.ui.keypressed("escape")
    local layout = lurek.ui.loadLayoutFile("content/examples/assets/layouts/sample_main_menu.toml")
    lurek.ui.textinput("a")
    print("widgetCount:", cnt, "loadLayoutFile ok; textinput ok")
end
```

---

### `lurek.ui.getWidgetFont`

Returns the font override assigned to a widget, or nil when the widget inherits its font from a parent.

```lua
-- signature
lurek.ui.getWidgetFont(widget)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `widget` | `LUiWidget` | Widget handle to query. |

**Returns**

| Type | Description |
|------|-------------|
| `LFont` | Font override assigned to the widget. |

**Example**

```lua
do
    -- Example for getWidgetFont
    local widget = lurek.ui.newButton("Test Widget")
    widget:setText("Using getWidgetFont")
    local w, h = widget:getSize()
    lurek.log.info("Invoked getWidgetFont on widget size " .. w .. "x" .. h)
    if w > 0 then widget:setVisible(true) end
end
```

---

### `lurek.ui.keypressed`

Delivers a key press event to the UI.

```lua
-- signature
lurek.ui.keypressed(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `string` | The key name. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if a widget consumed the event. |

**Example**

```lua
do
    local cnt = lurek.ui.getWidgetCount()
    lurek.ui.keypressed("escape")
    local layout = lurek.ui.loadLayoutFile("content/examples/assets/layouts/sample_main_menu.toml")
    lurek.ui.textinput("a")
    print("widgetCount:", cnt, "loadLayoutFile ok; textinput ok")
end
```

---

### `lurek.ui.loadLayout`

Loads a UI layout from a Lua table definition.

```lua
-- signature
lurek.ui.loadLayout(def)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `def` | `table` | The layout definition table. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The root widget index. |

**Example**

```lua
do
    lurek.ui.addToast({ message = "File saved successfully", duration = 3.0, type = "info" })
    print("toast added")
    local layout = lurek.ui.loadLayout({ type = "panel", children = {} })
    print("layout=" .. tostring(layout ~= nil))
end
```

---

### `lurek.ui.loadLayoutFile`

Loads a UI layout from a TOML layout file.

```lua
-- signature
lurek.ui.loadLayoutFile(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Path to the TOML layout file. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The root widget index. |

**Example**

```lua
do
    local cnt = lurek.ui.getWidgetCount()
    lurek.ui.keypressed("escape")
    local layout = lurek.ui.loadLayoutFile("content/examples/assets/layouts/sample_main_menu.toml")
    lurek.ui.textinput("a")
    print("widgetCount:", cnt, "loadLayoutFile ok; textinput ok")
end
```

---

### `lurek.ui.loadLayoutGameFile`

Loads a UI layout from a TOML file resolved through GameFS.

```lua
-- signature
lurek.ui.loadLayoutGameFile(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS path to the TOML layout file. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The root widget index. |

**Example**

```lua
do
    local ok, result = pcall(function()
        return lurek.ui.loadLayoutGameFile("assets/layouts/sample_main_menu.toml")
    end)
    print("loadLayoutGameFile ok:", ok, "result:", tostring(result))
end
```

---

### `lurek.ui.mousemoved`

Delivers a mouse move event to the UI.

```lua
-- signature
lurek.ui.mousemoved(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Mouse X position. |
| `y` | `number` | Mouse Y position. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if a widget consumed the event. |

**Example**

```lua
do
    local slider = lurek.ui.newSlider(0, 100)
    slider:setPosition(20, 520)
    slider:setSize(200, 20)
    slider:setZOrder(2200)
    lurek.ui.mousepressed(40, 530, 1)
    lurek.ui.mousemoved(180, 530)
    lurek.ui.mousereleased(180, 530, 1)
    lurek.ui.update(0)
    print("slider value after drag:", slider:getValue())
end
```

---

### `lurek.ui.mousepressed`

Delivers a mouse press event to the UI.

```lua
-- signature
lurek.ui.mousepressed(x, y, btn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Mouse X position. |
| `y` | `number` | Mouse Y position. |
| `btn?` | `number` | Mouse button index (default 1). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if a widget consumed the event. |

**Example**

```lua
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
    print("active tab after click:", tabs:getActiveTab())
end
```

---

### `lurek.ui.mousereleased`

Delivers a mouse release event to the UI.

```lua
-- signature
lurek.ui.mousereleased(x, y, btn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Mouse X position. |
| `y` | `number` | Mouse Y position. |
| `btn?` | `number` | Mouse button index (default 1). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if a widget consumed the event. |

**Example**

```lua
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
    print("combo selected:", combo:getSelectedItem())
end
```

---

### `lurek.ui.newAccordion`

Creates a new accordion widget with collapsible sections.

```lua
-- signature
lurek.ui.newAccordion()
```

**Returns**

| Type | Description |
|------|-------------|
| `LAccordion` | The new accordion widget table. |

**Example**

```lua
do
    ---@type LAccordion
    local acc = lurek.ui.newAccordion()
    print("type = " .. acc:type())
    print("sections = " .. acc:getSectionCount())
end
```

---

### `lurek.ui.newAreaChart`

Creates a new area chart for data visualization.

```lua
-- signature
lurek.ui.newAreaChart(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | `table` | Table with width, height, and optional title. |

**Returns**

| Type | Description |
|------|-------------|
| `LAreaChart` | The new area chart userdata. |

**Example**

```lua
do
    local chart = lurek.ui.newAreaChart({ width = 400, height = 200, title = "CPU Usage" })
    chart:addLayer("user", { 10, 25, 30, 45, 50, 40, 35 }, 0.2, 0.6, 1.0)
    chart:addLayer("system", { 5, 10, 15, 20, 15, 10, 8 }, 1.0, 0.4, 0.2)
    chart:setYMax(100)
    print("area chart type:", chart:type())
    print("is area chart:", chart:typeOf("LAreaChart"))
end
```

---

### `lurek.ui.newBadge`

Creates a new badge widget for displaying counts.

```lua
-- signature
lurek.ui.newBadge(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count?` | `number` | Initial count (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| `LBadge` | The new badge widget table. |

**Example**

```lua
do
    local badge = lurek.ui.newBadge(5)
    print("count:", badge:getCount())
    print("display:", badge:getDisplayText())
    badge:setCount(120)
    print("large count display:", badge:getDisplayText())
end
```

---

### `lurek.ui.newBarChart`

Creates a new bar chart for data visualization.

```lua
-- signature
lurek.ui.newBarChart(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | `table` | Table with width, height, and optional title. |

**Returns**

| Type | Description |
|------|-------------|
| `LBarChart` | The new bar chart userdata. |

**Example**

```lua
do
    local chart = lurek.ui.newBarChart({ width = 300, height = 200, title = "Sales" })
    chart:addSeries("Q1", 0.2, 0.8, 0.4)
    chart:addSeries("Q2", 0.8, 0.2, 0.4)
    chart:addCategory("Widgets", { 150, 200 })
    chart:addCategory("Gadgets", { 90, 120 })
    chart:addCategory("Tools", { 60, 80 })
    print("bar chart type:", chart:type())
end
```

---

### `lurek.ui.newButton`

Creates a new button widget with optional label text.

```lua
-- signature
lurek.ui.newButton(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text?` | `string` | The button label text. |

**Returns**

| Type | Description |
|------|-------------|
| `LButton` | The new button widget table. |

**Example**

```lua
do
    ---@type LButton
    local btn = lurek.ui.newButton("Click Me")
    print("type = " .. btn:type())
    print("text = " .. btn:getText())
end
```

---

### `lurek.ui.newCheckbox`

Creates a new checkbox widget with optional label.

```lua
-- signature
lurek.ui.newCheckbox(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text?` | `string` | The checkbox label text. |

**Returns**

| Type | Description |
|------|-------------|
| `LCheckbox` | The new checkbox widget table. |

**Example**

```lua
do
    ---@type LCheckbox
    local cb = lurek.ui.newCheckbox("Enable Sound")
    print("type = " .. cb:type())
    print("text = " .. cb:getText())
    print("checked = " .. tostring(cb:isChecked()))
end
```

---

### `lurek.ui.newColorPicker`

Creates a new color picker widget for color selection.

```lua
-- signature
lurek.ui.newColorPicker()
```

**Returns**

| Type | Description |
|------|-------------|
| `LColorPicker` | The new color picker widget table. |

**Example**

```lua
do
    local cp = lurek.ui.newColorPicker()
    cp:setColor(0.8, 0.2, 0.5, 1.0)
    local r, g, b, a = cp:getColor()
    print("color:", r, g, b, a)
    cp:setColorMode("hsv")
    print("mode:", cp:getColorMode())
end
```

---

### `lurek.ui.newComboBox`

Creates a new combo box (drop-down) widget.

```lua
-- signature
lurek.ui.newComboBox()
```

**Returns**

| Type | Description |
|------|-------------|
| `LComboBox` | The new combo box widget table. |

**Example**

```lua
do
    ---@type LComboBox
    local combo = lurek.ui.newComboBox()
    print("type = " .. combo:type())
    print("items = " .. combo:getItemCount())
end
```

---

### `lurek.ui.newCustomWidget`

Creates a new custom widget with optional initial configuration.

```lua
-- signature
lurek.ui.newCustomWidget(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | `table` | Optional table with x, y, width, height, id, visible, enabled fields. |

**Returns**

| Type | Description |
|------|-------------|
| `LUiWidget` | The new custom widget table. |

**Example**

```lua
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local child = lurek.ui.newLabel("label")
    w:addChild(child)
    w:animateAlpha(0.5, 0.3, false)
    w:animatePosition(10, 20, 0.5)
    local cnt = w:getChildCount()
    print("addChild/animateAlpha/animatePosition ok; childCount:", cnt)
end
```

---

### `lurek.ui.newDialog`

Creates a new dialog widget with an optional title.

```lua
-- signature
lurek.ui.newDialog(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title?` | `string` | The dialog title. |

**Returns**

| Type | Description |
|------|-------------|
| `LDialog` | The new dialog widget table. |

**Example**

```lua
do
    local dlg = lurek.ui.newDialog("Confirm Action")
    local content = lurek.ui.newPanel()
    content:setSize(300, 200)
    dlg:setModal(true)
    dlg:setContent(content._idx)
    dlg:addButton("OK")
    dlg:addButton("Cancel")
    dlg:setOnClose(function(idx)
        print("dialog closed, widget index:", idx)
    end)
    dlg:open()
    print("dialog title:", dlg:getTitle())
    print("is modal:", dlg:isModal())
    print("is open:", dlg:isOpen())
    dlg:setTitle("Advanced Settings")
    print("dialog content index:", dlg:getContent())
    print("new title:", dlg:getTitle())
    dlg:close()
    print("after close, is open:", dlg:isOpen())
end
```

---

### `lurek.ui.newDockPanel`

Creates a new dock panel widget for docking child widgets to sides.

```lua
-- signature
lurek.ui.newDockPanel()
```

**Returns**

| Type | Description |
|------|-------------|
| `LDockPanel` | The new dock panel widget table. |

**Example**

```lua
do
    local dock = lurek.ui.newDockPanel()
    local header = lurek.ui.newPanel()
    local sidebar = lurek.ui.newPanel()
    print("type = " .. dock:type())
    header:setSize(0, 60)
    sidebar:setSize(200, 0)
    dock:addChild(header)
    dock:addChild(sidebar)
    dock:dock(header._idx, "top")
    dock:dock(sidebar._idx, "left")
    dock:setSplitSize("left", 200)
    dock:setSplitSize("top", 60)
    print("docked count = " .. dock:getDockedCount())
    print("left size = " .. dock:getSplitSize("left"))
end
```

---

### `lurek.ui.newImageWidget`

Creates a new image display widget.

```lua
-- signature
lurek.ui.newImageWidget()
```

**Returns**

| Type | Description |
|------|-------------|
| `LImageWidget` | The new image widget table. |

**Example**

```lua
do
    local img = lurek.ui.newImageWidget()
    img:setScaleMode("fit")
    print("scale mode:", img:getScaleMode())
    img:setTint(1.0, 0.8, 0.6, 0.9)
    local r, g, b, a = img:getTint()
    print("tint:", r, g, b, a)
end
```

---

### `lurek.ui.newLabel`

Creates a new label widget for displaying text.

```lua
-- signature
lurek.ui.newLabel(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text?` | `string` | The label text. |

**Returns**

| Type | Description |
|------|-------------|
| `LLabel` | The new label widget table. |

**Example**

```lua
do
    local lbl = lurek.ui.newLabel("Hello, World!")
    print("type = " .. lbl:type())
    print("text = " .. lbl:getText())
    lbl:setText("Score: 100")
    print("updated text = " .. lbl:getText())
end
```

---

### `lurek.ui.newLayout`

Creates a new layout container widget.

```lua
-- signature
lurek.ui.newLayout(direction)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `direction?` | `string` | Layout direction: "vertical" or "horizontal" (default "vertical"). |

**Returns**

| Type | Description |
|------|-------------|
| `LLayout` | The new layout widget table. |

**Example**

```lua
do
    local row = lurek.ui.newLayout("horizontal")
    print("type = " .. row:type())
    print("direction = " .. row:getDirection())
    print("spacing = " .. row:getSpacing())

    local col = lurek.ui.newLayout("vertical")
    col:setSpacing(10)
    print("direction = " .. col:getDirection())
    print("spacing = " .. col:getSpacing())
end
```

---

### `lurek.ui.newLineChart`

Creates a new line chart for data visualization.

```lua
-- signature
lurek.ui.newLineChart(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | `table` | Table with width, height, and optional title. |

**Returns**

| Type | Description |
|------|-------------|
| `LLineChart` | The new line chart userdata. |

**Example**

```lua
do
    local chart = lurek.ui.newLineChart({ width = 400, height = 250, title = "Temperature" })
    chart:addSeries("indoor", { { x = 0, y = 20 }, { x = 6, y = 19 }, { x = 12, y = 22 }, { x = 18, y = 21 }, { x = 24, y = 20 } }, 1.0, 0.3, 0.3)
    chart:addSeries("outdoor", { { x = 0, y = 5 }, { x = 6, y = 3 }, { x = 12, y = 15 }, { x = 18, y = 10 }, { x = 24, y = 6 } }, 0.3, 0.3, 1.0)
    chart:setXMax(24)
    chart:setYMax(30)
    print("line chart type:", chart:type())
end
```

---

### `lurek.ui.newList`

Creates a new list box widget for item selection.

```lua
-- signature
lurek.ui.newList()
```

**Returns**

| Type | Description |
|------|-------------|
| `LListBox` | The new list box widget table. |

**Example**

```lua
do
    ---@type LListBox
    local list = lurek.ui.newList()
    print("type = " .. list:type())
    print("items = " .. list:getItemCount())
end
```

---

### `lurek.ui.newMenuBar`

Creates a new menu bar widget for top-level menus.

```lua
-- signature
lurek.ui.newMenuBar()
```

**Returns**

| Type | Description |
|------|-------------|
| `LMenuBar` | The new menu bar widget table. |

**Example**

```lua
do
    ---@type LMenuBar
    local bar = lurek.ui.newMenuBar()
    print("type = " .. bar:type())
    print("menu count = " .. bar:getMenuCount())
end
```

---

### `lurek.ui.newMenuItem`

Creates a new menu item widget with optional text.

```lua
-- signature
lurek.ui.newMenuItem(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text?` | `string` | The menu item text. |

**Returns**

| Type | Description |
|------|-------------|
| `LMenuItem` | The new menu item widget table. |

**Example**

```lua
do
    local item = lurek.ui.newMenuItem("File")
    print("type = " .. item:type())
    print("text = " .. item:getText())
    item:setShortcut("Ctrl+F")
    print("shortcut = " .. item:getShortcut())
end
```

---

### `lurek.ui.newNinePatch`

Creates a new nine-patch widget for scalable bordered images.

```lua
-- signature
lurek.ui.newNinePatch()
```

**Returns**

| Type | Description |
|------|-------------|
| `LNinePatch` | The new nine-patch widget table. |

**Example**

```lua
do
    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(128, 128)
    np:setInsets(16, 16, 16, 16)
    local w, h = np:getImageDimensions()
    print("image size:", w, h)
end
```

---

### `lurek.ui.newPanel`

Creates a new panel widget (container).

```lua
-- signature
lurek.ui.newPanel()
```

**Returns**

| Type | Description |
|------|-------------|
| `LPanel` | The new panel widget table. |

**Example**

```lua
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    print("type = " .. panel:type())
    print("child count = " .. panel:getChildCount())
    print("visible = " .. tostring(panel:isVisible()))
end
```

---

### `lurek.ui.newPieChart`

Creates a new pie chart for data visualization.

```lua
-- signature
lurek.ui.newPieChart(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | `table` | Table with width, height, and optional title. |

**Returns**

| Type | Description |
|------|-------------|
| `LPieChart` | The new pie chart userdata. |

**Example**

```lua
do
    local chart = lurek.ui.newPieChart({ width = 200, height = 200, title = "Market Share" })
    chart:addSegment("Product A", 45, 0.2, 0.6, 1.0)
    chart:addSegment("Product B", 30, 1.0, 0.4, 0.2)
    chart:addSegment("Product C", 15, 0.3, 0.9, 0.3)
    chart:addSegment("Other", 10, 0.7, 0.7, 0.7)
    print("pie chart type:", chart:type())
    print("is pie chart:", chart:typeOf("LPieChart"))
end
```

---

### `lurek.ui.newProgressBar`

Creates a new progress bar widget with min and max.

```lua
-- signature
lurek.ui.newProgressBar(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min?` | `number` | Minimum value (default 0). |
| `max?` | `number` | Maximum value (default 100). |

**Returns**

| Type | Description |
|------|-------------|
| `LProgressBar` | The new progress bar widget table. |

**Example**

```lua
do
    local bar = lurek.ui.newProgressBar(0, 100)
    bar:setValue(35)
    print("value:", bar:getValue())
    print("progress (normalized):", bar:getProgress())
end
```

---

### `lurek.ui.newRadioButton`

Creates a new radio button widget in a named group.

```lua
-- signature
lurek.ui.newRadioButton(text, group)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text?` | `string` | The radio button label. |
| `group?` | `string` | The radio group name. |

**Returns**

| Type | Description |
|------|-------------|
| `LRadioButton` | The new radio button widget table. |

**Example**

```lua
do
    local rb1 = lurek.ui.newRadioButton("Small", "size_group")
    local rb2 = lurek.ui.newRadioButton("Medium", "size_group")
    local rb3 = lurek.ui.newRadioButton("Large", "size_group")
    rb2:setSelected(true)
    print("rb1 selected:", rb1:isSelected())
    print("rb2 selected:", rb2:isSelected())
    print("rb2 group:", rb2:getGroup())
    print("rb2 text:", rb2:getText())
end
```

---

### `lurek.ui.newScatterPlot`

Creates a new scatter plot for data visualization.

```lua
-- signature
lurek.ui.newScatterPlot(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | `table` | Table with width, height, and optional title. |

**Returns**

| Type | Description |
|------|-------------|
| `LScatterPlot` | The new scatter plot userdata. |

**Example**

```lua
do
    local chart = lurek.ui.newScatterPlot({ width = 400, height = 300, title = "Height vs Weight" })
    chart:addSeries("male", { { x = 170, y = 70 }, { x = 180, y = 80 }, { x = 175, y = 75 }, { x = 185, y = 90 } }, 0.2, 0.5, 1.0)
    chart:addSeries("female", { { x = 160, y = 55 }, { x = 165, y = 60 }, { x = 170, y = 65 }, { x = 155, y = 50 } }, 1.0, 0.3, 0.6)
    chart:setXRange(150, 200)
    chart:setYRange(40, 100)
    print("scatter plot type:", chart:type())
end
```

---

### `lurek.ui.newScrollBar`

Creates a new scroll bar widget for content scrolling.

```lua
-- signature
lurek.ui.newScrollBar(vertical)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vertical?` | `boolean` | True for vertical (default true). |

**Returns**

| Type | Description |
|------|-------------|
| `LScrollBar` | The new scroll bar widget table. |

**Example**

```lua
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local layout = lurek.ui.newLayout("row")
    local sb = lurek.ui.newScrollBar(true)
    print("newCustomWidget:", w, "newLayout:", layout, "newScrollBar:", sb)
end
```

---

### `lurek.ui.newScrollPanel`

Creates a new scrollable panel widget.

```lua
-- signature
lurek.ui.newScrollPanel()
```

**Returns**

| Type | Description |
|------|-------------|
| `LScrollPanel` | The new scroll panel widget table. |

**Example**

```lua
do
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
```

---

### `lurek.ui.newSeparator`

Creates a new separator widget for visual division.

```lua
-- signature
lurek.ui.newSeparator(vertical)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vertical?` | `boolean` | True for vertical separator (default false). |

**Returns**

| Type | Description |
|------|-------------|
| `LSeparator` | The new separator widget table. |

**Example**

```lua
do
    local sep = lurek.ui.newSeparator(false)
    print("is vertical:", sep:isVertical())
    sep:setThickness(2)
    print("new thickness:", sep:getThickness())
end
```

---

### `lurek.ui.newSlider`

Creates a new slider widget with adjustable range.

```lua
-- signature
lurek.ui.newSlider(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min?` | `number` | Minimum value (default 0). |
| `max?` | `number` | Maximum value (default 100). |

**Returns**

| Type | Description |
|------|-------------|
| `LSlider` | The new slider widget table. |

**Example**

```lua
do
    local slider = lurek.ui.newSlider(0, 100)
    print("type = " .. slider:type())
    print("min = " .. slider:getMin())
    print("max = " .. slider:getMax())
    print("value = " .. slider:getValue())
end
```

---

### `lurek.ui.newSpacer`

Creates a new spacer widget for spacing between other widgets.

```lua
-- signature
lurek.ui.newSpacer(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w?` | `number` | The width. |
| `h?` | `number` | The height. |

**Returns**

| Type | Description |
|------|-------------|
| `LSpacer` | The new spacer widget table. |

**Example**

```lua
do
    local sp = lurek.ui.newSpacer(20, 10)
    sp:setSize(40, 20)
    local w, h = sp:getSize()
    print("spacer size:", w, h)
end
```

---

### `lurek.ui.newSpinBox`

Creates a new spin box (numeric stepper) widget.

```lua
-- signature
lurek.ui.newSpinBox(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min?` | `number` | Minimum value (default 0). |
| `max?` | `number` | Maximum value (default 100). |

**Returns**

| Type | Description |
|------|-------------|
| `LSpinBox` | The new spin box widget table. |

**Example**

```lua
do
    local spin = lurek.ui.newSpinBox(1, 99)
    print("type = " .. spin:type())
    print("value = " .. spin:getValue())
    spin:setValue(50)
    print("set to 50 = " .. spin:getValue())
end
```

---

### `lurek.ui.newSplitPanel`

Creates a new split panel widget with two resizable sub-panels.

```lua
-- signature
lurek.ui.newSplitPanel(orientation)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `orientation?` | `string` | "horizontal" or "vertical" (default "horizontal"). |

**Returns**

| Type | Description |
|------|-------------|
| `LSplitPanel` | The new split panel widget table. |

**Example**

```lua
do
    local split = lurek.ui.newSplitPanel("horizontal")
    local left = lurek.ui.newPanel()
    local right = lurek.ui.newPanel()
    print("type = " .. split:type())
    print("orientation = " .. split:getOrientation())
    split:setFirstChild(left._idx)
    split:setSecondChild(right._idx)
    split:setSplitPosition(0.3)
    split:setMinPanelSize(100)
    print("split at " .. split:getSplitPosition())
    print("min panel = " .. split:getMinPanelSize())
end
```

---

### `lurek.ui.newStatusBar`

Creates a new status bar widget for app-level info.

```lua
-- signature
lurek.ui.newStatusBar()
```

**Returns**

| Type | Description |
|------|-------------|
| `LStatusBar` | The new status bar widget table. |

**Example**

```lua
do
    local sb = lurek.ui.newStatusBar()
    sb:addSection("Ready", 150)
    print("section count:", sb:getSectionCount())
    print("section 1:", sb:getSectionText(1))
end
```

---

### `lurek.ui.newSwitch`

Creates a new toggle switch widget.

```lua
-- signature
lurek.ui.newSwitch(on)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `on?` | `boolean` | Initial on/off state (default false). |

**Returns**

| Type | Description |
|------|-------------|
| `LSwitch` | The new switch widget table. |

**Example**

```lua
do
    ---@type LSwitch
    local sw = lurek.ui.newSwitch(false)
    print("type = " .. sw:type())
    print("on = " .. tostring(sw:isOn()))
end
```

---

### `lurek.ui.newTabBar`

Creates a new tab bar widget for tabbed navigation.

```lua
-- signature
lurek.ui.newTabBar()
```

**Returns**

| Type | Description |
|------|-------------|
| `LTabBar` | The new tab bar widget table. |

**Example**

```lua
do
    ---@type LTabBar
    local tabs = lurek.ui.newTabBar()
    print("type = " .. tabs:type())
    print("tab count = " .. tabs:getTabCount())
end
```

---

### `lurek.ui.newTable`

Creates a new table widget for tabular data display.

```lua
-- signature
lurek.ui.newTable()
```

**Returns**

| Type | Description |
|------|-------------|
| `LGuiTable` | The new table widget. |

**Example**

```lua
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
```

---

### `lurek.ui.newTextInput`

Creates a new text input widget for user entry.

```lua
-- signature
lurek.ui.newTextInput()
```

**Returns**

| Type | Description |
|------|-------------|
| `LTextInput` | The new text input widget table. |

**Example**

```lua
do
    local input = lurek.ui.newTextInput()
    print("type = " .. input:type())
    print("text = '" .. input:getText() .. "'")
    input:setText("Hello")
    print("set text = " .. input:getText())
end
```

---

### `lurek.ui.newTheme`

Creates a new UI theme for styling widgets.

```lua
-- signature
lurek.ui.newTheme()
```

**Returns**

| Type | Description |
|------|-------------|
| `LTheme` | The new theme userdata. |

**Example**

```lua
do
    local theme = lurek.ui.newTheme()
    theme:setStyle("button", "normal", { bg_r = 0.2, bg_g = 0.2, bg_b = 0.3, bg_a = 1.0, fg_r = 1.0, fg_g = 1.0, fg_b = 1.0, fg_a = 1.0, })
    theme:setStyle("button", "hovered", { bg_r = 0.3, bg_g = 0.3, bg_b = 0.5, bg_a = 1.0, })
    lurek.ui.setTheme(theme)
    print("theme active:", lurek.ui.getTheme())
    print("theme type:", theme:type())
end
```

---

### `lurek.ui.newToast`

Creates a new toast notification widget.

```lua
-- signature
lurek.ui.newToast(message, duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message?` | `string` | The toast message. |
| `duration?` | `number` | Display duration in seconds (default 3). |

**Returns**

| Type | Description |
|------|-------------|
| `LToast` | The new toast widget table. |

**Example**

```lua
do
    local toast = lurek.ui.newToast("File saved!", 2.5)
    print("message:", toast:getMessage())
    print("duration:", toast:getDuration())
    toast:setMessage("Upload complete")
    toast:setDuration(4.0)
    print("updated message:", toast:getMessage())
    print("expired:", toast:isExpired())
end
```

---

### `lurek.ui.newToolbar`

Creates a new toolbar widget for action buttons.

```lua
-- signature
lurek.ui.newToolbar(orientation)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `orientation?` | `string` | "horizontal" or "vertical" (default "horizontal"). |

**Returns**

| Type | Description |
|------|-------------|
| `LToolbar` | The new toolbar widget table. |

**Example**

```lua
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("save", "Save file")
    print("orientation:", tb:getOrientation())
end
```

---

### `lurek.ui.newTooltipPanel`

Creates a new tooltip panel widget.

```lua
-- signature
lurek.ui.newTooltipPanel(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text?` | `string` | The tooltip text. |

**Returns**

| Type | Description |
|------|-------------|
| `LTooltipPanel` | The new tooltip panel widget table. |

**Example**

```lua
do
    local btn = lurek.ui.newButton("Hover me")
    local tip = lurek.ui.newTooltipPanel("Click to submit form")
    tip:setDelay(0.5)
    tip:setTarget(btn._idx)
    print("tooltip text:", tip:getText())
    print("delay:", tip:getDelay())
    print("target:", tip:getTarget())
    tip:setText("Updated tooltip text")
    print("new text:", tip:getText())
end
```

---

### `lurek.ui.newTreeView`

Creates a new tree view widget for hierarchical data.

```lua
-- signature
lurek.ui.newTreeView()
```

**Returns**

| Type | Description |
|------|-------------|
| `LTreeView` | The new tree view widget table. |

**Example**

```lua
do
    local tree = lurek.ui.newTreeView()
    local root = tree:addNode("Project")
    tree:addNode("main.lua", root)
    print("total nodes:", tree:getNodeCount())
    print("root text:", tree:getNodeText(root))
end
```

---

### `lurek.ui.newWindow`

Creates a new GUI window widget with an optional title.

```lua
-- signature
lurek.ui.newWindow(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title?` | `string` | The window title. |

**Returns**

| Type | Description |
|------|-------------|
| `LGuiWindow` | The new window widget table. |

**Example**

```lua
do
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

    win:setTitle("Object Inspector")
    print("title:", win:getTitle())
    win:setDraggable(false)
    print("draggable after disable:", win:isDraggable())
    win:setResizable(false)
    print("resizable after disable:", win:isResizable())
    win:setCloseable(false)
    print("closeable after disable:", win:isCloseable())
end
```

---

### `lurek.ui.parseWidgetState`

Validates and normalizes a widget state string.

```lua
-- signature
lurek.ui.parseWidgetState(state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state` | `string` | The state name to parse (e.g. "normal", "hovered"). |

**Returns**

| Type | Description |
|------|-------------|
| `string` | The normalized state string, or nil if invalid. |

**Example**

```lua
do
    local th = lurek.ui.newTheme()
    local state = lurek.ui.parseWidgetState("normal")
    local result = lurek.ui.renderToImage(320, 240, "save/ui_render.png")
    print("newTheme ok; parseWidgetState:", state, "renderToImage:", result)
end
```

---

### `lurek.ui.renderToImage`

Renders the entire UI to a PNG image file.

```lua
-- signature
lurek.ui.renderToImage(pathOrWidth, widthOrHeight, heightOrPath)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pathOrWidth` | `any` | Output file path for path-first calls, or image width for canonical calls. |
| `widthOrHeight` | `number` | Image width for path-first calls, or image height for canonical calls. |
| `heightOrPath` | `any` | Image height for path-first calls, or output file path for canonical calls. |

**Example**

```lua
do
    local th = lurek.ui.newTheme()
    local state = lurek.ui.parseWidgetState("normal")
    local result = lurek.ui.renderToImage(320, 240, "save/ui_render.png")
    print("newTheme ok; parseWidgetState:", state, "renderToImage:", result)
end
```

---

### `lurek.ui.setBaseResolution`

Set the logical base resolution the UI was designed for.

```lua
-- signature
lurek.ui.setBaseResolution(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | Base width (default 1920). |
| `height` | `number` | Base height (default 1080). |

**Example**

```lua
do
    lurek.ui.setBaseResolution(1280, 720)
    print("lurek.ui.setBaseResolution scaleFactor=" .. lurek.ui.getScaleFactor())
end
```

---

### `lurek.ui.setDefaultTheme`

Applies the built-in default theme to the UI context.

```lua
-- signature
lurek.ui.setDefaultTheme()
```

**Example**

```lua
do
    local th = lurek.ui.newTheme()
    lurek.ui.setTheme(th)
    lurek.ui.setDefaultTheme()
    lurek.ui.setViewport(1280, 720)
    local cnt = lurek.ui.getWidgetCount()
    print("setTheme/setDefaultTheme/setViewport ok; widgets:", cnt)
end
```

---

### `lurek.ui.setFocus`

Sets keyboard focus to a widget, or clears focus if nil.

```lua
-- signature
lurek.ui.setFocus(widget)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `widget?` | `table` | The widget table to focus, or nil to clear. |

**Example**

```lua
do
    local input = lurek.ui.newTextInput()
    lurek.ui.setFocus(input)
    local focused = lurek.ui.getFocus()
    print("focus set, has focus = " .. tostring(focused ~= nil))
    lurek.ui.clearFocus()
    focused = lurek.ui.getFocus()
    print("after clear = " .. tostring(focused))
end
```

---

### `lurek.ui.setFont`

Sets the global UI font by applying it to the root widget.

```lua
-- signature
lurek.ui.setFont(font)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | `LFont` | Font handle used by the UI when widgets do not override it. |

**Example**

```lua
do
    -- Example for setFont
    local widget = lurek.ui.newButton("Test Widget")
    widget:setText("Using setFont")
    local w, h = widget:getSize()
    lurek.log.info("Invoked setFont on widget size " .. w .. "x" .. h)
    if w > 0 then widget:setVisible(true) end
end
```

---

### `lurek.ui.setTheme`

Applies a theme to the entire UI context.

```lua
-- signature
lurek.ui.setTheme(theme_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `theme_ud` | `LTheme` | The theme userdata to apply. |

**Example**

```lua
do
    local theme = lurek.ui.newTheme()
    theme:setStyle("button", "normal", { bg_r = 0.2, bg_g = 0.2, bg_b = 0.3, bg_a = 1.0, fg_r = 1.0, fg_g = 1.0, fg_b = 1.0, fg_a = 1.0, })
    theme:setStyle("button", "hovered", { bg_r = 0.3, bg_g = 0.3, bg_b = 0.5, bg_a = 1.0, })
    lurek.ui.setTheme(theme)
    print("theme active:", lurek.ui.getTheme())
    print("theme type:", theme:type())
end
```

---

### `lurek.ui.setViewport`

Sets the viewport size for the UI context.

```lua
-- signature
lurek.ui.setViewport(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Viewport width. |
| `h` | `number` | Viewport height. |

**Example**

```lua
do
    local th = lurek.ui.newTheme()
    lurek.ui.setTheme(th)
    lurek.ui.setDefaultTheme()
    lurek.ui.setViewport(1280, 720)
    local cnt = lurek.ui.getWidgetCount()
    print("setTheme/setDefaultTheme/setViewport ok; widgets:", cnt)
end
```

---

### `lurek.ui.textinput`

Delivers a text input event to the UI.

```lua
-- signature
lurek.ui.textinput(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | The input text. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if a widget consumed the event. |

**Example**

```lua
do
    lurek.ui.textinput("hello")
    lurek.ui.textinput(" world")
    lurek.ui.update_bindings({dt=0.016})
    lurek.ui.wheelmoved(0, 1)
    lurek.ui.wheelmoved(1, 0)
    print("textinput/update_bindings/wheelmoved ok")
end
```

---

### `lurek.ui.update`

Updates the UI context and dispatches pending events to callbacks.

```lua
-- signature
lurek.ui.update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Delta time in seconds. |

**Example**

```lua
do
    lurek.ui.update(1 / 60)
    lurek.ui.draw()
    print("UI frame processed")
end
```

---

### `lurek.ui.updateBindings`

Updates data bindings for widgets that reference binding keys.

```lua
-- signature
lurek.ui.updateBindings(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | `table` | A table mapping binding keys to values. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The number of widgets whose state changed. |

**Example**

```lua
do
    -- Example for updateBindings
    local widget = lurek.ui.newButton("Test Widget")
    widget:setText("Using updateBindings")
    local w, h = widget:getSize()
    lurek.log.info("Invoked updateBindings on widget size " .. w .. "x" .. h)
    if w > 0 then widget:setVisible(true) end
end
```

---

### `lurek.ui.updateResolution`

Update the current viewport resolution and recompute UI scale factor.

```lua
-- signature
lurek.ui.updateResolution(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | New viewport width in pixels. |
| `height` | `number` | New viewport height in pixels. |

**Example**

```lua
do
    lurek.ui.updateResolution(1920, 1080)
    print("lurek.ui.updateResolution ok")
end
```

---

### `lurek.ui.update_bindings`

Updates data bindings for widgets that reference binding keys.

```lua
-- signature
lurek.ui.update_bindings(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | `table` | A table mapping binding keys to values. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The number of widgets whose state changed. |

**Example**

```lua
do
    lurek.ui.textinput("hello")
    lurek.ui.textinput(" world")
    lurek.ui.update_bindings({dt=0.016})
    lurek.ui.wheelmoved(0, 1)
    lurek.ui.wheelmoved(1, 0)
    print("textinput/update_bindings/wheelmoved ok")
end
```

---

### `lurek.ui.visibleRange`

Calculate the visible item range for a scrollable list widget.

```lua
-- signature
lurek.ui.visibleRange(widget, item_count, item_height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `widget` | `table` | Widget table with _idx field. |
| `item_count` | `number` | Total number of items. |
| `item_height` | `number` | Height of each item in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Start index (0-based). |
| `number` | b End index (exclusive). |

**Example**

```lua
do
    local list = lurek.ui.newList()
    local x, y = lurek.ui.visibleRange(list, 50, 20.0)
    print("lurek.ui.visibleRange x=" .. x .. " y=" .. y)
end
```

---

### `lurek.ui.wheelmoved`

Delivers a mouse wheel event to the UI.

```lua
-- signature
lurek.ui.wheelmoved(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Horizontal scroll delta. |
| `y` | `number` | Vertical scroll delta. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if a widget consumed the event. |

**Example**

```lua
do
    local panel = lurek.ui.newScrollPanel()
    panel:setPosition(300, 520)
    panel:setSize(120, 70)
    panel:setZOrder(2500)
    panel:setContentSize(120, 300)
    lurek.ui.mousemoved(310, 530)
    lurek.ui.wheelmoved(0, -3)
    local _, sy = panel:getScrollPosition()
    print("hover scroll y:", sy)
end
```

---

## LAccordion

### `LAccordion:addSection`

Adds a collapsible section to this accordion.

```lua
-- signature
LAccordion:addSection(title, content_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | `string` | The section title. |
| `content_idx?` | `number` | Optional widget index for the section content. |

**Example**

```lua
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("Player Stats")
    acc:addSection("Inventory")
    acc:addSection("Quest Log")
    print("sections = " .. acc:getSectionCount())
    print("section 1 = " .. acc:getSectionTitle(1))
    print("section 2 = " .. acc:getSectionTitle(2))
end
```

---

### `LAccordion:getSectionCount`

Returns the number of sections in this accordion.

```lua
-- signature
LAccordion:getSectionCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The section count. |

**Example**

```lua
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("Player Stats")
    acc:addSection("Inventory")
    acc:addSection("Quest Log")
    print("sections = " .. acc:getSectionCount())
    print("section 1 = " .. acc:getSectionTitle(1))
    print("section 2 = " .. acc:getSectionTitle(2))
end
```

---

### `LAccordion:getSectionTitle`

Returns the title of an accordion section by its 1-based index.

```lua
-- signature
LAccordion:getSectionTitle(section_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `section_idx` | `number` | The 1-based section index. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | The section title, or nil if out of range. |

**Example**

```lua
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("Player Stats")
    acc:addSection("Inventory")
    acc:addSection("Quest Log")
    print("sections = " .. acc:getSectionCount())
    print("section 1 = " .. acc:getSectionTitle(1))
    print("section 2 = " .. acc:getSectionTitle(2))
end
```

---

### `LAccordion:isExclusive`

Returns whether this accordion is in exclusive mode (only one section open at a time).

```lua
-- signature
LAccordion:isExclusive()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if exclusive. |

**Example**

```lua
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
```

---

### `LAccordion:isSectionExpanded`

Returns whether an accordion section is expanded.

```lua
-- signature
LAccordion:isSectionExpanded(section_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `section_idx` | `number` | The 1-based section index. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if expanded. |

**Example**

```lua
do
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
```

---

### `LAccordion:setExclusive`

Sets exclusive mode. When true, expanding one section collapses all others.

```lua
-- signature
LAccordion:setExclusive(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `boolean` | True for exclusive mode. |

**Example**

```lua
do
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
```

---

### `LAccordion:toggleSection`

Toggles the expanded state of an accordion section by its 1-based index.

```lua
-- signature
LAccordion:toggleSection(section_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `section_idx` | `number` | The 1-based section index. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | The new expanded state. |

**Example**

```lua
do
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
```

---

## LAreaChart

### `LAreaChart:addLayer`

Adds a data layer to this area chart.

```lua
-- signature
LAreaChart:addLayer(name, vals_tbl, r, g, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | The layer name. |
| `vals_tbl` | `table` | Array of numeric values. |
| `r` | `number` | Red color component. |
| `g` | `number` | Green color component. |
| `b` | `number` | Blue color component. |

**Example**

```lua
do
    local cb = lurek.ui.newCheckbox("old")
    cb:setText("new label")
    local chart = lurek.ui.newAreaChart({width = 200, height = 100})
    chart:setYMax(100)
    chart:addLayer("series1", {10, 20, 30, 25, 15}, 1.0, 0.2, 0.2)
    print("checkbox setText ok; addLayer, setYMax ok")
end
```

---

### `LAreaChart:addLayerFromDataFrame`

Adds one area layer from a dataframe column, using zero for missing or non-numeric cells.

```lua
-- signature
LAreaChart:addLayerFromDataFrame(name, df, value_col, r, g, b, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | The layer name. |
| `df` | `LDataFrame` | Source dataframe. |
| `value_col` | `string` | Column name for layer values. |
| `r` | `number` | Red color component. |
| `g` | `number` | Green color component. |
| `b` | `number` | Blue color component. |
| `opts?` | `table` | Optional table with maxRows integer. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of values copied into the layer. |

**Example**

```lua
do
    local df = lurek.dataframe.fromRows({ "balance" }, { { 1200 }, { "1325" }, { "bad" } })
    local chart = lurek.ui.newAreaChart({width = 200, height = 100})
    local count = chart:addLayerFromDataFrame("Balance", df, "balance", 0.2, 0.6, 0.9)
    print("area df values=" .. count)
end
```

---

### `LAreaChart:addSeries`

Add a named data series to the area chart (stacked above previous).

```lua
-- signature
LAreaChart:addSeries(name, data, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Display name of the series. |
| `data` | `table` | Array of {x, y} point tables. |
| `color?` | `table` | Optional RGBA color {r, g, b, a}. |

---

### `LAreaChart:clear`

Removes all data series from this chart.

```lua
-- signature
LAreaChart:clear()
```

---

### `LAreaChart:drawToImage`

Renders this area chart to an image buffer.

```lua
-- signature
LAreaChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | `LImageData` | The image to draw into. |

**Example**

```lua
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
```

---

### `LAreaChart:getHeight`

Get the chart output height in pixels.

```lua
-- signature
LAreaChart:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Height in pixels. |

---

### `LAreaChart:getWidth`

Get the chart output width in pixels.

```lua
-- signature
LAreaChart:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Width in pixels. |

---

### `LAreaChart:render`

Renders the chart contents into a new pixel buffer.

```lua
-- signature
LAreaChart:render()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Output width in pixels. |
| `number` | b Output height in pixels. |
| `string` | c RGBA8 pixel data as a binary string. |

---

### `LAreaChart:setTitle`

Set or update the chart's displayed title.

```lua
-- signature
LAreaChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | `string` | New chart title text. |

---

### `LAreaChart:setYMax`

Sets the maximum Y-axis value for this area chart.

```lua
-- signature
LAreaChart:setYMax(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | The Y-axis maximum. |

**Example**

```lua
do
    local cb = lurek.ui.newCheckbox("old")
    cb:setText("new label")
    local chart = lurek.ui.newAreaChart({width = 200, height = 100})
    chart:setYMax(100)
    chart:addLayer("series1", {10, 20, 30, 25, 15}, 1.0, 0.2, 0.2)
    print("checkbox setText ok; addLayer, setYMax ok")
end
```

---

### `LAreaChart:type`

Returns the type name of this object.

```lua
-- signature
LAreaChart:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LAreaChart". |

**Example**

```lua
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
```

---

### `LAreaChart:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LAreaChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches this userdata type. |

**Example**

```lua
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
```

---

## LBadge

### `LBadge:getCount`

Returns the current notification count of this badge.

```lua
-- signature
LBadge:getCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The badge count. |

**Example**

```lua
do
    local badge = lurek.ui.newBadge(3)
    print("type=" .. badge:type())
    print("count=" .. badge:getCount())
    badge:setCount(7)
    print("count_after=" .. badge:getCount())
    local text = badge:getDisplayText()
    print("text=" .. tostring(text))
end
```

---

### `LBadge:getDisplayText`

Returns the formatted display text of this badge (e.g. "99+" when count exceeds the maximum).

```lua
-- signature
LBadge:getDisplayText()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The display text. |

**Example**

```lua
do
    local badge = lurek.ui.newBadge(3)
    print("type=" .. badge:type())
    print("count=" .. badge:getCount())
    badge:setCount(7)
    print("count_after=" .. badge:getCount())
    local text = badge:getDisplayText()
    print("text=" .. tostring(text))
end
```

---

### `LBadge:setCount`

Sets the notification count displayed by this badge.

```lua
-- signature
LBadge:setCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | `number` | The notification count. |

**Example**

```lua
do
    local badge = lurek.ui.newBadge(3)
    print("type=" .. badge:type())
    print("count=" .. badge:getCount())
    badge:setCount(7)
    print("count_after=" .. badge:getCount())
    local text = badge:getDisplayText()
    print("text=" .. tostring(text))
end
```

---

## LBarChart

### `LBarChart:addCategoriesFromDataFrame`

Adds bar categories from dataframe rows, using zero for missing or non-numeric value cells.

```lua
-- signature
LBarChart:addCategoriesFromDataFrame(df, label_col, value_cols, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `df` | `LDataFrame` | Source dataframe. |
| `label_col` | `string` | Column name for category labels. |
| `value_cols` | `string[]` | Value columns matching registered series order. |
| `opts?` | `table` | Optional table with maxRows integer. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of categories added. |

**Example**

```lua
do
    local df = lurek.dataframe.fromRows({ "month", "income", "expense" }, { { "Jan", 100, 60 }, { "Feb", "120", "bad" } })
    local chart = lurek.ui.newBarChart({width = 200, height = 100})
    chart:addSeries("Income", 0.2, 0.6, 0.9)
    chart:addSeries("Expense", 0.9, 0.4, 0.2)
    local count = chart:addCategoriesFromDataFrame(df, "month", { "income", "expense" })
    print("bar df categories=" .. count)
end
```

---

### `LBarChart:addCategory`

Adds a category with values for each series.

```lua
-- signature
LBarChart:addCategory(label, vals_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | `string` | The category label. |
| `vals_tbl` | `table` | Array of values, one per series. |

**Example**

```lua
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
```

---

### `LBarChart:addSeries`

Add a named data series to the bar chart.

```lua
-- signature
LBarChart:addSeries(name, data, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Display name of the series. |
| `data` | `table` | Array of {x, y} point tables. |
| `color?` | `table` | Optional RGBA color {r, g, b, a}. |

---

### `LBarChart:clear`

Removes all data series from this chart.

```lua
-- signature
LBarChart:clear()
```

---

### `LBarChart:drawToImage`

Renders this bar chart to an image buffer.

```lua
-- signature
LBarChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | `LImageData` | The image to draw into. |

**Example**

```lua
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
```

---

### `LBarChart:getHeight`

Get the chart output height in pixels.

```lua
-- signature
LBarChart:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Height in pixels. |

---

### `LBarChart:getWidth`

Get the chart output width in pixels.

```lua
-- signature
LBarChart:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Width in pixels. |

---

### `LBarChart:render`

Renders the chart contents into a new pixel buffer.

```lua
-- signature
LBarChart:render()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Output width in pixels. |
| `number` | b Output height in pixels. |
| `string` | c RGBA8 pixel data as a binary string. |

---

### `LBarChart:setBarWidth`

Set the pixel width of individual bars in this chart.

```lua
-- signature
LBarChart:setBarWidth(width)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | Bar width in pixels (minimum 1). |

---

### `LBarChart:setTitle`

Set or update the chart's displayed title.

```lua
-- signature
LBarChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | `string` | New chart title text. |

---

### `LBarChart:type`

Returns the type name of this object.

```lua
-- signature
LBarChart:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LBarChart". |

**Example**

```lua
do
    local chart = lurek.ui.newBarChart({width = 100, height = 50})
    local t = chart:type()
    local ok = chart:typeOf("LBarChart")
    local notOk = chart:typeOf("LAreaChart")
    print("LBarChart type:", t, "typeOf:", ok, "typeOf LAreaChart:", notOk)
end
```

---

### `LBarChart:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LBarChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches this userdata type. |

**Example**

```lua
do
    local chart = lurek.ui.newBarChart({width = 100, height = 50})
    local t = chart:type()
    local ok = chart:typeOf("LBarChart")
    local notOk = chart:typeOf("LAreaChart")
    print("LBarChart type:", t, "typeOf:", ok, "typeOf LAreaChart:", notOk)
end
```

---

## LButton

### `LButton:getText`

Returns the current display text of this button.

```lua
-- signature
LButton:getText()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The button label. |

**Example**

```lua
do
    local badge = lurek.ui.newBadge(0)
    badge:setCount(42)
    local btn = lurek.ui.newButton("Click me")
    local t = btn:getText()
    btn:setText("OK")
    print("badge count:", badge:getCount(), "button text:", btn:getText())
end
```

---

### `LButton:setText`

Sets the display text on this button.

```lua
-- signature
LButton:setText(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | The button label text. |

**Example**

```lua
do
    local badge = lurek.ui.newBadge(0)
    badge:setCount(42)
    local btn = lurek.ui.newButton("Click me")
    local t = btn:getText()
    btn:setText("OK")
    print("badge count:", badge:getCount(), "button text:", btn:getText())
end
```

---

## LCheckbox

### `LCheckbox:getText`

Returns the label text of this checkbox.

```lua
-- signature
LCheckbox:getText()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The checkbox label. |

**Example**

```lua
do
    local cb = lurek.ui.newCheckbox("Enable feature")
    local t = cb:getText()
    cb:setChecked(true)
    local checked = cb:isChecked()
    print("checkbox text:", t, "checked:", checked)
end
```

---

### `LCheckbox:isChecked`

Returns whether this checkbox is currently checked.

```lua
-- signature
LCheckbox:isChecked()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if checked. |

**Example**

```lua
do
    local cb = lurek.ui.newCheckbox("Enable feature")
    local t = cb:getText()
    cb:setChecked(true)
    local checked = cb:isChecked()
    print("checkbox text:", t, "checked:", checked)
end
```

---

### `LCheckbox:setChecked`

Sets the checked state of this checkbox.

```lua
-- signature
LCheckbox:setChecked(checked)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `checked` | `boolean` | True to check, false to uncheck. |

**Example**

```lua
do
    local cb = lurek.ui.newCheckbox("Option A")
    cb:setChecked(true)
    print("checked = " .. tostring(cb:isChecked()))
    cb:setText("Option B")
    print("text = " .. cb:getText())
    cb:setChecked(false)
    print("unchecked = " .. tostring(cb:isChecked()))
end
```

---

### `LCheckbox:setText`

Sets the label text displayed next to this checkbox.

```lua
-- signature
LCheckbox:setText(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | The checkbox label. |

**Example**

```lua
do
    local cb = lurek.ui.newCheckbox("Option A")
    cb:setChecked(true)
    print("checked = " .. tostring(cb:isChecked()))
    cb:setText("Option B")
    print("text = " .. cb:getText())
    cb:setChecked(false)
    print("unchecked = " .. tostring(cb:isChecked()))
end
```

---

## LColorPicker

### `LColorPicker:getColor`

Returns the current color as RGBA components (0.0 to 1.0).

```lua
-- signature
LColorPicker:getColor()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Red component. |
| `number` | b Green component. |
| `number` | c Blue component. |
| `number` | d Alpha component. |

**Example**

```lua
do
    local cp = lurek.ui.newColorPicker()
    print("type=" .. cp:type())
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    print("mode=" .. tostring(cp:getColorMode()))
    cp:setColorMode("hsv")
    print("mode_after=" .. cp:getColorMode())
    print("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2)
        print("changed", r2, g2, b2, a2)
    end)
end
```

---

### `LColorPicker:getColorMode`

Returns the color mode of this picker (e.g. "rgb", "hsv").

```lua
-- signature
LColorPicker:getColorMode()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The color mode. |

**Example**

```lua
do
    local cp = lurek.ui.newColorPicker()
    print("type=" .. cp:type())
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    print("mode=" .. tostring(cp:getColorMode()))
    cp:setColorMode("hsv")
    print("mode_after=" .. cp:getColorMode())
    print("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) print("changed", r2, g2, b2, a2) end)
end
```

---

### `LColorPicker:getShowAlpha`

Returns whether the alpha channel slider is visible.

```lua
-- signature
LColorPicker:getShowAlpha()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the alpha slider is shown. |

**Example**

```lua
do
    local cp = lurek.ui.newColorPicker()
    print("type=" .. cp:type())
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    print("mode=" .. tostring(cp:getColorMode()))
    cp:setColorMode("hsv")
    print("mode_after=" .. cp:getColorMode())
    print("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) print("changed", r2, g2, b2, a2) end)
end
```

---

### `LColorPicker:setColor`

Sets the current color as RGBA components.

```lua
-- signature
LColorPicker:setColor(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red (0.0 to 1.0). |
| `g` | `number` | Green (0.0 to 1.0). |
| `b` | `number` | Blue (0.0 to 1.0). |
| `a?` | `number` | Alpha (0.0 to 1.0), keeps current if omitted. |

**Example**

```lua
do
    local cp = lurek.ui.newColorPicker()
    print("type=" .. cp:type())
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    print("mode=" .. tostring(cp:getColorMode()))
    cp:setColorMode("hsv")
    print("mode_after=" .. cp:getColorMode())
    print("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) print("changed", r2, g2, b2, a2) end)
end
```

---

### `LColorPicker:setColorMode`

Sets the color mode of this picker (e.g. "rgb", "hsv").

```lua
-- signature
LColorPicker:setColorMode(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | The color mode. |

**Example**

```lua
do
    local cp = lurek.ui.newColorPicker()
    print("type=" .. cp:type())
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    print("mode=" .. tostring(cp:getColorMode()))
    cp:setColorMode("hsv")
    print("mode_after=" .. cp:getColorMode())
    print("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) print("changed", r2, g2, b2, a2) end)
end
```

---

### `LColorPicker:setOnChange`

Registers a callback invoked when this color picker's value changes.

```lua
-- signature
LColorPicker:setOnChange(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | `function` | Callback receiving the widget index. |

**Example**

```lua
do
    local cp = lurek.ui.newColorPicker()
    print("type=" .. cp:type())
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    print("mode=" .. tostring(cp:getColorMode()))
    cp:setColorMode("hsv")
    print("mode_after=" .. cp:getColorMode())
    print("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) print("changed", r2, g2, b2, a2) end)
end
```

---

### `LColorPicker:setShowAlpha`

Sets whether the alpha channel slider is visible.

```lua
-- signature
LColorPicker:setShowAlpha(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `boolean` | True to show the alpha slider. |

**Example**

```lua
do
    local cp = lurek.ui.newColorPicker()
    print("type=" .. cp:type())
    cp:setColor(1.0, 0.5, 0.0, 1.0)
    local r, g, b, a = cp:getColor()
    print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    print("mode=" .. tostring(cp:getColorMode()))
    cp:setColorMode("hsv")
    print("mode_after=" .. cp:getColorMode())
    print("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) print("changed", r2, g2, b2, a2) end)
end
```

---

## LComboBox

### `LComboBox:addItem`

Appends a new text item to this combo box's dropdown list.

```lua
-- signature
LComboBox:addItem(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | The item label to add. |

**Example**

```lua
do
    local combo = lurek.ui.newComboBox()
    combo:addItem("Easy")
    combo:addItem("Normal")
    combo:addItem("Hard")
    combo:addItem("Nightmare")
    print("item count = " .. combo:getItemCount())
    print("item 2 = " .. combo:getItem(2))
    print("item 4 = " .. combo:getItem(4))
end
```

---

### `LComboBox:clearItems`

Removes all items from this combo box.

```lua
-- signature
LComboBox:clearItems()
```

**Example**

```lua
do
    local combo = lurek.ui.newComboBox()
    combo:addItem("Red")
    combo:addItem("Green")
    combo:addItem("Blue")
    combo:setSelectedIndex(2)
    local idx = combo:getSelectedIndex()
    local item = combo:getSelectedItem()
    print("selected index = " .. idx)
    print("selected item = " .. tostring(item))
    combo:clearItems()
    print("after clear = " .. combo:getItemCount())
end
```

---

### `LComboBox:getItem`

Returns the text of the item at the given 1-based index.

```lua
-- signature
LComboBox:getItem(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | The 1-based item index. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | The item text, or nil if out of range. |

**Example**

```lua
do
    local combo = lurek.ui.newComboBox()
    combo:addItem("Easy")
    combo:addItem("Normal")
    combo:addItem("Hard")
    combo:addItem("Nightmare")
    print("item count = " .. combo:getItemCount())
    print("item 2 = " .. combo:getItem(2))
    print("item 4 = " .. combo:getItem(4))
end
```

---

### `LComboBox:getItemCount`

Returns the number of items in this combo box.

```lua
-- signature
LComboBox:getItemCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The item count. |

**Example**

```lua
do
    local combo = lurek.ui.newComboBox()
    combo:addItem("Easy")
    combo:addItem("Normal")
    combo:addItem("Hard")
    combo:addItem("Nightmare")
    print("item count = " .. combo:getItemCount())
    print("item 2 = " .. combo:getItem(2))
    print("item 4 = " .. combo:getItem(4))
end
```

---

### `LComboBox:getSelectedIndex`

Returns the 1-based index of the currently selected item, or 0 if none is selected.

```lua
-- signature
LComboBox:getSelectedIndex()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The selected index. |

**Example**

```lua
do
    local combo = lurek.ui.newComboBox()
    combo:addItem("Red")
    combo:addItem("Green")
    combo:addItem("Blue")
    combo:setSelectedIndex(2)
    local idx = combo:getSelectedIndex()
    local item = combo:getSelectedItem()
    print("selected index = " .. idx)
    print("selected item = " .. tostring(item))
    combo:clearItems()
    print("after clear = " .. combo:getItemCount())
end
```

---

### `LComboBox:getSelectedItem`

Returns the text of the currently selected item, or nil if none is selected.

```lua
-- signature
LComboBox:getSelectedItem()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The selected item text. |

**Example**

```lua
do
    local combo = lurek.ui.newComboBox()
    combo:addItem("Red")
    combo:addItem("Green")
    combo:addItem("Blue")
    combo:setSelectedIndex(2)
    local idx = combo:getSelectedIndex()
    local item = combo:getSelectedItem()
    print("selected index = " .. idx)
    print("selected item = " .. tostring(item))
    combo:clearItems()
    print("after clear = " .. combo:getItemCount())
end
```

---

### `LComboBox:removeItem`

Removes the item at the given 1-based index from this combo box.

```lua
-- signature
LComboBox:removeItem(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | The 1-based index of the item to remove. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the item was removed. |

**Example**

```lua
do
    local cb = lurek.ui.newComboBox()
    cb:addItem("Alpha")
    cb:addItem("Beta")
    cb:setSelectedIndex(2)
    local selItem = cb:getSelectedItem()
    cb:removeItem(1)
    print("getSelectedItem:", selItem, "removeItem ok")
end
```

---

### `LComboBox:setSelectedIndex`

Sets the selected item by 1-based index.

```lua
-- signature
LComboBox:setSelectedIndex(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | The 1-based index of the item to select. |

**Example**

```lua
do
    local cb = lurek.ui.newComboBox()
    cb:addItem("Alpha")
    cb:addItem("Beta")
    cb:setSelectedIndex(2)
    local selItem = cb:getSelectedItem()
    cb:removeItem(1)
    print("getSelectedItem:", selItem, "removeItem ok")
end
```

---

## LDialog

### `LDialog:addButton`

Adds a footer button to this dialog and returns its 1-based index.

```lua
-- signature
LDialog:addButton(text, cb)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | The button label. |
| `cb?` | `function` | Optional click callback (reserved for future use). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The 1-based button index. |

**Example**

```lua
do
    local dlg = lurek.ui.newDialog("Info")
    local btnIdx = dlg:addButton("OK")
    local content = dlg:getContent()
    dlg:open()
    dlg:close()
    print("addButton:", btnIdx, "close ok")
end
```

---

### `LDialog:close`

Closes this dialog and fires the onClose callback if it was open.

```lua
-- signature
LDialog:close()
```

**Example**

```lua
do
    local dlg = lurek.ui.newDialog("Info")
    local btnIdx = dlg:addButton("OK")
    local content = dlg:getContent()
    dlg:open()
    dlg:close()
    print("addButton:", btnIdx, "close ok")
end
```

---

### `LDialog:getContent`

Returns the widget index of this dialog's content, or nil if not set.

```lua
-- signature
LDialog:getContent()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The content widget index. |

**Example**

```lua
do
    local dlg = lurek.ui.newDialog("Info")
    local btnIdx = dlg:addButton("OK")
    local content = dlg:getContent()
    dlg:open()
    dlg:close()
    print("addButton:", btnIdx, "close ok")
end
```

---

### `LDialog:getTitle`

Returns the title text of this dialog.

```lua
-- signature
LDialog:getTitle()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The dialog title. |

**Example**

```lua
do
    local dlg = lurek.ui.newDialog("My Dialog")
    local title = dlg:getTitle()
    dlg:setModal(true)
    local modal = dlg:isModal()
    local open = dlg:isOpen()
    print("title:", title, "isModal:", modal, "isOpen:", open)
end
```

---

### `LDialog:isModal`

Returns whether this dialog is modal (blocks interaction with other widgets).

```lua
-- signature
LDialog:isModal()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if modal. |

**Example**

```lua
do
    local dlg = lurek.ui.newDialog("My Dialog")
    local title = dlg:getTitle()
    dlg:setModal(true)
    local modal = dlg:isModal()
    local open = dlg:isOpen()
    print("title:", title, "isModal:", modal, "isOpen:", open)
end
```

---

### `LDialog:isOpen`

Returns whether this dialog is currently open and visible.

```lua
-- signature
LDialog:isOpen()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if open. |

**Example**

```lua
do
    local dlg = lurek.ui.newDialog("My Dialog")
    local title = dlg:getTitle()
    dlg:setModal(true)
    local modal = dlg:isModal()
    local open = dlg:isOpen()
    print("title:", title, "isModal:", modal, "isOpen:", open)
end
```

---

### `LDialog:open`

Opens this dialog, making it visible.

```lua
-- signature
LDialog:open()
```

**Example**

```lua
do
    local dlg = lurek.ui.newDialog("Setup")
    dlg:setModal(false)
    dlg:setContent(nil)
    dlg:open()
    dlg:close()
    print("open/setContent/setModal ok")
end
```

---

### `LDialog:setContent`

Sets the content widget for this dialog.

```lua
-- signature
LDialog:setContent(content_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `content_idx?` | `number` | The widget index to show as content, or nil to clear. |

**Example**

```lua
do
    local dlg = lurek.ui.newDialog("Setup")
    dlg:setModal(false)
    dlg:setContent(nil)
    dlg:open()
    dlg:close()
    print("open/setContent/setModal ok")
end
```

---

### `LDialog:setModal`

Sets whether this dialog widget is modal.

```lua
-- signature
LDialog:setModal(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `boolean` | True to make modal. |

**Example**

```lua
do
    local dlg = lurek.ui.newDialog("Setup")
    dlg:setModal(false)
    dlg:setContent(nil)
    dlg:open()
    dlg:close()
    print("open/setContent/setModal ok")
end
```

---

### `LDialog:setOnClose`

Registers a callback invoked when this dialog is closed.

```lua
-- signature
LDialog:setOnClose(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | `function` | Callback receiving the widget index. |

**Example**

```lua
do
    local dlg = lurek.ui.newDialog("Old")
    dlg:setTitle("New Title")
    dlg:setOnClose(function(idx) print("closed", idx) end)
    local dp = lurek.ui.newDockPanel()
    local btn = lurek.ui.newButton("Side")
    print("setTitle/setOnClose ok; DockPanel created")
end
```

---

### `LDialog:setTitle`

Sets the title text of this dialog widget.

```lua
-- signature
LDialog:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | `string` | The dialog title. |

**Example**

```lua
do
    local dlg = lurek.ui.newDialog("Old")
    dlg:setTitle("New Title")
    dlg:setOnClose(function(idx) print("closed", idx) end)
    local dp = lurek.ui.newDockPanel()
    local btn = lurek.ui.newButton("Side")
    print("setTitle/setOnClose ok; DockPanel created")
end
```

---

## LDockPanel

### `LDockPanel:dock`

Docks a child widget to the specified side of this dock panel.

```lua
-- signature
LDockPanel:dock(child_idx, side)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `child_idx` | `number` | The widget index to dock. |
| `side` | `string` | The dock side ("left", "right", "top", "bottom", "center"). |

**Example**

```lua
do
    local dp = lurek.ui.newDockPanel()
    local child = lurek.ui.newPanel()
    print("type=" .. dp:type())
    dp:addChild(child)
    dp:dock(child._idx, "left")
    print("docked=" .. dp:getDockedCount())
    print("split_size=" .. tostring(dp:getSplitSize("left")))
    dp:setSplitSize("left", 150)
    dp:undock(child._idx)
    print("docked_after=" .. dp:getDockedCount())
end
```

---

### `LDockPanel:getDockedCount`

Returns the number of widgets docked in this dock panel.

```lua
-- signature
LDockPanel:getDockedCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The docked widget count. |

**Example**

```lua
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
```

---

### `LDockPanel:getSplitSize`

Returns the size configured for a dock panel side region.

```lua
-- signature
LDockPanel:getSplitSize(side)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `side` | `string` | The dock side. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The size in pixels, or nil if not set. |

**Example**

```lua
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
```

---

### `LDockPanel:setSplitSize`

Sets the size of a dock panel side region.

```lua
-- signature
LDockPanel:setSplitSize(side, size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `side` | `string` | The dock side ("left", "right", "top", "bottom"). |
| `size` | `number` | The size in pixels. |

**Example**

```lua
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
```

---

### `LDockPanel:undock`

Removes a child widget from this dock panel.

```lua
-- signature
LDockPanel:undock(child_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `child_idx` | `number` | The widget index to undock. |

**Example**

```lua
do
    local dock = lurek.ui.newDockPanel()
    local footer = lurek.ui.newPanel()
    dock:addChild(footer)
    dock:dock(footer._idx, "bottom")
    print("docked = " .. dock:getDockedCount())
    dock:undock(footer._idx)
    print("after undock = " .. dock:getDockedCount())
end
```

---

## LGuiTable

### `LGuiTable:addColumn`

Adds a new column to this table widget.

```lua
-- signature
LGuiTable:addColumn(header, width)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `header` | `string` | The column header text. |
| `width?` | `number` | The column width in pixels (default 100). |

**Example**

```lua
do
    local tbl = lurek.ui.newTable()
    print("type=" .. tbl:type())
    tbl:addColumn("Name")
    tbl:addColumn("Score")
    print("cols=" .. tbl:getColumnCount())
    tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" })
    print("rows=" .. tbl:getRowCount())
    print("cell11=" .. tostring(tbl:getCell(1, 1)))
    tbl:setCell(1, 2, "999")
    tbl:setSelectedRow(1)
    print("selected=" .. tostring(tbl:getSelectedRow()))
end
```

---

### `LGuiTable:addRow`

Adds a row of data to this table widget.

```lua
-- signature
LGuiTable:addRow(cells)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cells` | `table` | Array of cell text values. |

**Example**

```lua
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
```

---

### `LGuiTable:clearRows`

Clears all rows and the selected row in this table widget.

```lua
-- signature
LGuiTable:clearRows()
```

**Example**

```lua
do
    local tbl = lurek.ui.newTable()
    tbl:setRows({ { "Food", 420 }, { "Rent", 1200 } })
    tbl:setSelectedRow(1)
    tbl:clearRows()
    print("rows=" .. tbl:getRowCount())
end
```

---

### `LGuiTable:getCell`

Returns the text of a cell at the given 1-based row and column.

```lua
-- signature
LGuiTable:getCell(row, col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row` | `number` | The 1-based row index. |
| `col` | `number` | The 1-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | The cell text, or nil if out of range. |

**Example**

```lua
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
```

---

### `LGuiTable:getColumnCount`

Returns the number of columns in this table widget.

```lua
-- signature
LGuiTable:getColumnCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The column count. |

**Example**

```lua
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
```

---

### `LGuiTable:getRowCount`

Returns the number of rows in this table widget.

```lua
-- signature
LGuiTable:getRowCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The row count. |

**Example**

```lua
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
```

---

### `LGuiTable:getSelectedRow`

Returns the 1-based index of the currently selected row, or nil.

```lua
-- signature
LGuiTable:getSelectedRow()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The selected row index. |

**Example**

```lua
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
```

---

### `LGuiTable:isSortable`

Returns whether columns in this table can be sorted by clicking headers.

```lua
-- signature
LGuiTable:isSortable()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if sortable. |

**Example**

```lua
do
    local tbl = lurek.ui.newTable()
    tbl:addColumn("ID")
    tbl:addRow({"1"})
    tbl:setSortable(true)
    tbl:setCell(1, 1, "changed")
    tbl:setOnSelect(function(idx) print("row selected", idx) end)
    print("isSortable/setCell/setOnSelect ok")
end
```

---

### `LGuiTable:setCell`

Sets the text of a cell at the given 1-based row and column.

```lua
-- signature
LGuiTable:setCell(row, col, text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row` | `number` | The 1-based row index. |
| `col` | `number` | The 1-based column index. |
| `text` | `string` | The new cell text. |

**Example**

```lua
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
```

---

### `LGuiTable:setDataFrame`

Replaces columns and rows from a dataframe, stringifying cell values for display.

```lua
-- signature
LGuiTable:setDataFrame(df, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `df` | `LDataFrame` | Source dataframe. |
| `opts?` | `table` | Optional table with maxRows integer, columns string[], and includeHeaders boolean. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The resulting row count. |

**Example**

```lua
do
    local df = lurek.dataframe.fromRows({ "category", "amount" }, { { "Food", 420 }, { "Rent", 1200 } })
    local tbl = lurek.ui.newTable()
    local count = tbl:setDataFrame(df, { columns = { "category", "amount" }, maxRows = 2 })
    print("setDataFrame=" .. count .. ", cols=" .. tbl:getColumnCount())
end
```

---

### `LGuiTable:setOnSelect`

Registers a callback invoked when a table row is selected.

```lua
-- signature
LGuiTable:setOnSelect(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | `function` | Callback receiving the widget index. |

**Example**

```lua
do
    local tbl = lurek.ui.newTable()
    tbl:addColumn("ID")
    tbl:addRow({"1"})
    tbl:setSortable(true)
    tbl:setCell(1, 1, "changed")
    tbl:setOnSelect(function(idx) print("row selected", idx) end)
    print("isSortable/setCell/setOnSelect ok")
end
```

---

### `LGuiTable:setRows`

Replaces all rows with an array of row arrays.

```lua
-- signature
LGuiTable:setRows(rows)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `rows` | `table` | Array of row arrays containing scalar cell values. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The resulting row count. |

**Example**

```lua
do
    local tbl = lurek.ui.newTable()
    local count = tbl:setRows({ { "Income", 3200 }, { "Savings", 640 } })
    print("setRows=" .. count .. ", first=" .. tostring(tbl:getCell(1, 1)))
end
```

---

### `LGuiTable:setSelectedRow`

Sets the selected row by its 1-based index, or nil to deselect.

```lua
-- signature
LGuiTable:setSelectedRow(row)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row?` | `number` | The 1-based row index, or nil. |

**Example**

```lua
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
```

---

### `LGuiTable:setSortable`

Sets whether columns in this table can be sorted by clicking headers.

```lua
-- signature
LGuiTable:setSortable(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `boolean` | True to enable sorting. |

**Example**

```lua
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
    print("sorted first row:", tbl:getCell(1, 1))
end
```

---

## LGuiWindow

### `LGuiWindow:getTitle`

Returns the title bar text of this GUI window.

```lua
-- signature
LGuiWindow:getTitle()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The window title. |

**Example**

```lua
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
```

---

### `LGuiWindow:isCloseable`

Returns whether this window shows a close button.

```lua
-- signature
LGuiWindow:isCloseable()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if closeable. |

**Example**

```lua
do
    local win = lurek.ui.newWindow("Test Win")
    local closeable = win:isCloseable()
    local draggable = win:isDraggable()
    local resizable = win:isResizable()
    print("isCloseable:", closeable, "isDraggable:", draggable, "isResizable:", resizable)
end
```

---

### `LGuiWindow:isDraggable`

Returns whether this window can be dragged by its title bar.

```lua
-- signature
LGuiWindow:isDraggable()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if draggable. |

**Example**

```lua
do
    local win = lurek.ui.newWindow("Test Win")
    local closeable = win:isCloseable()
    local draggable = win:isDraggable()
    local resizable = win:isResizable()
    print("isCloseable:", closeable, "isDraggable:", draggable, "isResizable:", resizable)
end
```

---

### `LGuiWindow:isResizable`

Returns whether this window can be resized by dragging its edges.

```lua
-- signature
LGuiWindow:isResizable()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if resizable. |

**Example**

```lua
do
    local win = lurek.ui.newWindow("Test Win")
    local closeable = win:isCloseable()
    local draggable = win:isDraggable()
    local resizable = win:isResizable()
    print("isCloseable:", closeable, "isDraggable:", draggable, "isResizable:", resizable)
end
```

---

### `LGuiWindow:setCloseable`

Sets whether this window shows a close button.

```lua
-- signature
LGuiWindow:setCloseable(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `boolean` | True to show the close button. |

**Example**

```lua
do
    local win = lurek.ui.newWindow("Config")
    win:setCloseable(true)
    win:setDraggable(true)
    win:setOnClose(function(idx) print("window closed", idx) end)
    print("setCloseable/setDraggable/setOnClose ok")
end
```

---

### `LGuiWindow:setDraggable`

Sets whether this window can be dragged by its title bar.

```lua
-- signature
LGuiWindow:setDraggable(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `boolean` | True to allow dragging. |

**Example**

```lua
do
    local win = lurek.ui.newWindow("Config")
    win:setCloseable(true)
    win:setDraggable(true)
    win:setOnClose(function(idx) print("window closed", idx) end)
    print("setCloseable/setDraggable/setOnClose ok")
end
```

---

### `LGuiWindow:setOnClose`

Registers a callback invoked when this window is closed.

```lua
-- signature
LGuiWindow:setOnClose(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | `function` | Callback receiving the widget index. |

**Example**

```lua
do
    local win = lurek.ui.newWindow("Config")
    win:setCloseable(true)
    win:setDraggable(true)
    win:setOnClose(function(idx) print("window closed", idx) end)
    print("setCloseable/setDraggable/setOnClose ok")
end
```

---

### `LGuiWindow:setResizable`

Sets whether this window can be resized.

```lua
-- signature
LGuiWindow:setResizable(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `boolean` | True to allow resizing. |

**Example**

```lua
do
    local win = lurek.ui.newWindow("Old")
    win:setResizable(false)
    win:setTitle("New Title")
    local iw = lurek.ui.newImageWidget()
    local mode = iw:getScaleMode()
    print("setResizable/setTitle ok; scaleMode:", mode)
end
```

---

### `LGuiWindow:setTitle`

Sets the title bar text of this GUI window.

```lua
-- signature
LGuiWindow:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | `string` | The window title. |

**Example**

```lua
do
    local win = lurek.ui.newWindow("Old")
    win:setResizable(false)
    win:setTitle("New Title")
    local iw = lurek.ui.newImageWidget()
    local mode = iw:getScaleMode()
    print("setResizable/setTitle ok; scaleMode:", mode)
end
```

---

## LImageWidget

### `LImageWidget:getScaleMode`

Returns the image scaling mode (e.g. "fit", "fill", "stretch").

```lua
-- signature
LImageWidget:getScaleMode()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The scale mode. |

**Example**

```lua
do
    local iw = lurek.ui.newImageWidget()
    print("type=" .. iw:type())
    print("scale_mode=" .. tostring(iw:getScaleMode()))
    iw:setScaleMode("stretch")
    print("scale_mode_after=" .. iw:getScaleMode())
    iw:setTint(1.0, 0.78, 0.5, 1.0)
    local r, g, b, a = iw:getTint()
    print("tint=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

### `LImageWidget:getTint`

Returns the tint color of this image widget as RGBA components.

```lua
-- signature
LImageWidget:getTint()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Red component. |
| `number` | b Green component. |
| `number` | c Blue component. |
| `number` | d Alpha component. |

**Example**

```lua
do
    local iw = lurek.ui.newImageWidget()
    print("type=" .. iw:type())
    print("scale_mode=" .. tostring(iw:getScaleMode()))
    iw:setScaleMode("stretch")
    print("scale_mode_after=" .. iw:getScaleMode())
    iw:setTint(1.0, 0.78, 0.5, 1.0)
    local r, g, b, a = iw:getTint()
    print("tint=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

### `LImageWidget:setScaleMode`

Sets the image scaling mode (e.g. "fit", "fill", "stretch").

```lua
-- signature
LImageWidget:setScaleMode(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | The scale mode. |

**Example**

```lua
do
    local iw = lurek.ui.newImageWidget()
    print("type=" .. iw:type())
    print("scale_mode=" .. tostring(iw:getScaleMode()))
    iw:setScaleMode("stretch")
    print("scale_mode_after=" .. iw:getScaleMode())
    iw:setTint(1.0, 0.78, 0.5, 1.0)
    local r, g, b, a = iw:getTint()
    print("tint=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

### `LImageWidget:setTint`

Sets the tint color of this image widget as RGBA components.

```lua
-- signature
LImageWidget:setTint(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red (0.0 to 1.0). |
| `g` | `number` | Green (0.0 to 1.0). |
| `b` | `number` | Blue (0.0 to 1.0). |
| `a?` | `number` | Alpha (0.0 to 1.0), defaults to 1.0. |

**Example**

```lua
do
    local iw = lurek.ui.newImageWidget()
    print("type=" .. iw:type())
    print("scale_mode=" .. tostring(iw:getScaleMode()))
    iw:setScaleMode("stretch")
    print("scale_mode_after=" .. iw:getScaleMode())
    iw:setTint(1.0, 0.78, 0.5, 1.0)
    local r, g, b, a = iw:getTint()
    print("tint=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

## LLabel

### `LLabel:getText`

Returns the current display text of this label.

```lua
-- signature
LLabel:getText()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The label text. |

**Example**

```lua
do
    local lbl = lurek.ui.newLabel("Hello")
    lbl:setText("World")
    local layout = lurek.ui.newLayout("horizontal")
    local align = layout:getAlign()
    print("label text:", lbl:getText(), "layout align:", align)
end
```

---

### `LLabel:setText`

Sets the display text on this label.

```lua
-- signature
LLabel:setText(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | The label text. |

**Example**

```lua
do
    local lbl = lurek.ui.newLabel("Hello")
    lbl:setText("World")
    local layout = lurek.ui.newLayout("horizontal")
    local align = layout:getAlign()
    print("label text:", lbl:getText(), "layout align:", align)
end
```

---

## LLayout

### `LLayout:getAlign`

Returns the current cross-axis alignment mode.

```lua
-- signature
LLayout:getAlign()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The alignment mode. |

**Example**

```lua
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setAlign("center")
    print("align = " .. layout:getAlign())
    layout:setAlign("stretch")
    print("align = " .. layout:getAlign())
end
```

---

### `LLayout:getDirection`

Returns the current layout direction.

```lua
-- signature
LLayout:getDirection()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The direction name. |

**Example**

```lua
do
    local layout = lurek.ui.newLayout("vertical")
    local dir = layout:getDirection()
    local justify = layout:getJustify()
    local spacing = layout:getSpacing()
    print("direction:", dir, "justify:", justify, "spacing:", spacing)
end
```

---

### `LLayout:getJustify`

Returns the current main-axis justification mode.

```lua
-- signature
LLayout:getJustify()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The justification mode. |

**Example**

```lua
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setJustify("space-between")
    print("justify = " .. layout:getJustify())
    layout:setJustify("center")
    print("justify = " .. layout:getJustify())
end
```

---

### `LLayout:getSpacing`

Returns the current spacing between children.

```lua
-- signature
LLayout:getSpacing()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The spacing in pixels. |

**Example**

```lua
do
    local layout = lurek.ui.newLayout("vertical")
    local dir = layout:getDirection()
    local justify = layout:getJustify()
    local spacing = layout:getSpacing()
    print("direction:", dir, "justify:", justify, "spacing:", spacing)
end
```

---

### `LLayout:getWrap`

Returns whether wrapping is enabled for this layout.

```lua
-- signature
LLayout:getWrap()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if wrapping is on. |

**Example**

```lua
do
    ---@type LLayout
    local layout = lurek.ui.newLayout("horizontal")
    print("wrap = " .. tostring(layout:getWrap()))
    layout:setWrap(true)
    print("wrap enabled = " .. tostring(layout:getWrap()))
end
```

---

### `LLayout:setAlign`

Sets the cross-axis alignment for children (e.g. "start", "center", "end", "stretch").

```lua
-- signature
LLayout:setAlign(align)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `align` | `string` | The alignment mode. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the layout exists and the alignment was set. |

**Example**

```lua
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setAlign("center")
    print("align = " .. layout:getAlign())
    layout:setAlign("stretch")
    print("align = " .. layout:getAlign())
end
```

---

### `LLayout:setColumns`

Sets the number of columns for grid layout mode (minimum 1).

```lua
-- signature
LLayout:setColumns(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | `number` | Column count. |

**Example**

```lua
do
    ---@type LLayout
    local grid = lurek.ui.newLayout("grid")
    grid:setColumns(3)
    grid:setSpacing(5)
    print("direction = " .. grid:getDirection())
end
```

---

### `LLayout:setDirection`

Sets the layout direction for child arrangement ("horizontal", "vertical", or "grid").

```lua
-- signature
LLayout:setDirection(dir)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dir` | `string` | The layout direction. |

**Example**

```lua
do
    ---@type LLayout
    local grid = lurek.ui.newLayout("grid")
    grid:setColumns(3)
    grid:setSpacing(5)
    print("direction = " .. grid:getDirection())
end
```

---

### `LLayout:setJustify`

Sets the main-axis justification for children (e.g. "start", "center", "end", "space-between").

```lua
-- signature
LLayout:setJustify(justify)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `justify` | `string` | The justification mode. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the layout exists and the justification was set. |

**Example**

```lua
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setJustify("space-between")
    print("justify = " .. layout:getJustify())
    layout:setJustify("center")
    print("justify = " .. layout:getJustify())
end
```

---

### `LLayout:setSpacing`

Sets the spacing in pixels between child widgets in this layout.

```lua
-- signature
LLayout:setSpacing(spacing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `spacing` | `number` | Gap between children in pixels. |

**Example**

```lua
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setDirection("vertical")
    layout:setJustify("center")
    layout:setSpacing(8)
    print("setDirection/setJustify/setSpacing ok")
end
```

---

### `LLayout:setWrap`

Enables or disables wrapping of children to the next row/column when they overflow.

```lua
-- signature
LLayout:setWrap(wrap)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wrap` | `boolean` | True to enable wrapping. |

**Example**

```lua
do
    ---@type LLayout
    local layout = lurek.ui.newLayout("horizontal")
    print("wrap = " .. tostring(layout:getWrap()))
    layout:setWrap(true)
    print("wrap enabled = " .. tostring(layout:getWrap()))
end
```

---

## LLineChart

### `LLineChart:addSeries`

Add a named data series to the line chart.

```lua
-- signature
LLineChart:addSeries(name, data, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Display name of the series. |
| `data` | `table` | Array of {x, y} point tables. |
| `color?` | `table` | Optional RGBA color {r, g, b, a}. |

---

### `LLineChart:addSeriesFromDataFrame`

Adds a named series from dataframe columns, skipping rows with non-numeric x or y cells.

```lua
-- signature
LLineChart:addSeriesFromDataFrame(name, df, x_col, y_col, r, g, b, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | The series name. |
| `df` | `LDataFrame` | Source dataframe. |
| `x_col` | `string` | Column name for X values. |
| `y_col` | `string` | Column name for Y values. |
| `r` | `number` | Red color component. |
| `g` | `number` | Green color component. |
| `b` | `number` | Blue color component. |
| `opts?` | `table` | Optional table with maxRows integer. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of accepted points added to the series. |

**Example**

```lua
do
    local df = lurek.dataframe.fromRows({ "month", "savings" }, { { 1, 240 }, { 2, "260" }, { 3, "bad" } })
    local chart = lurek.ui.newLineChart({width = 200, height = 100})
    local count = chart:addSeriesFromDataFrame("Savings", df, "month", "savings", 0.2, 0.8, 0.4)
    print("line df points=" .. count)
end
```

---

### `LLineChart:clear`

Removes all data series from this chart.

```lua
-- signature
LLineChart:clear()
```

---

### `LLineChart:drawToImage`

Renders this line chart to an image buffer.

```lua
-- signature
LLineChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | `LImageData` | The image to draw into. |

**Example**

```lua
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setWrap(true)
    local lc = lurek.ui.newLineChart({width = 200, height = 100})
    lc:addSeries("speed", {{1,10},{2,20},{3,15}}, 0.2, 0.8, 0.4)
    local img = lurek.image.newImageData(200, 100)
    lc:drawToImage(img)
    print("setWrap ok; addSeries/drawToImage ok")
end
```

---

### `LLineChart:getHeight`

Get the chart output height in pixels.

```lua
-- signature
LLineChart:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Height in pixels. |

---

### `LLineChart:getWidth`

Get the chart output width in pixels.

```lua
-- signature
LLineChart:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Width in pixels. |

---

### `LLineChart:render`

Renders the chart contents into a new pixel buffer.

```lua
-- signature
LLineChart:render()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Output width in pixels. |
| `number` | b Output height in pixels. |
| `string` | c RGBA8 pixel data as a binary string. |

---

### `LLineChart:setTitle`

Set or update the chart's displayed title.

```lua
-- signature
LLineChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | `string` | New chart title text. |

---

### `LLineChart:setXMax`

Sets the maximum X-axis value for this line chart.

```lua
-- signature
LLineChart:setXMax(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | The X-axis maximum. |

**Example**

```lua
do
    local lc = lurek.ui.newLineChart({width = 150, height = 80})
    lc:setXMax(100)
    lc:setYMax(50)
    lc:addSeries("data", {{0,0},{100,50}}, 1.0, 0.2, 0.2)
    local t = lc:type()
    print("setXMax/setYMax ok; type:", t)
end
```

---

### `LLineChart:setYMax`

Sets the maximum Y-axis value for this line chart.

```lua
-- signature
LLineChart:setYMax(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | The Y-axis maximum. |

**Example**

```lua
do
    local lc = lurek.ui.newLineChart({width = 150, height = 80})
    lc:setXMax(100)
    lc:setYMax(50)
    lc:addSeries("data", {{0,0},{100,50}}, 1.0, 0.2, 0.2)
    local t = lc:type()
    print("setXMax/setYMax ok; type:", t)
end
```

---

### `LLineChart:type`

Returns the type name of this object.

```lua
-- signature
LLineChart:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LLineChart". |

**Example**

```lua
do
    local lc = lurek.ui.newLineChart({width = 150, height = 80})
    lc:setXMax(100)
    lc:setYMax(50)
    lc:addSeries("data", {{0,0},{100,50}}, 1.0, 0.2, 0.2)
    local t = lc:type()
    print("setXMax/setYMax ok; type:", t)
end
```

---

### `LLineChart:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LLineChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches this userdata type. |

**Example**

```lua
do
    local lc = lurek.ui.newLineChart({width = 100, height = 60})
    local ok = lc:typeOf("LLineChart")
    local notOk = lc:typeOf("LBarChart")
    print("LLineChart typeOf:", ok, "typeOf LBarChart:", notOk)
end
```

---

## LList

### `LList:add`

Append a value to the end of the list.

```lua
-- signature
LList:add(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `any` | The value to append. |

---

### `LList:clear`

Remove all items from the list. This method is available to Lua scripts.

```lua
-- signature
LList:clear()
```

---

### `LList:contains`

Check whether the list contains a specific value.

```lua
-- signature
LList:contains(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `string` | The value to search for. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if found. |

---

### `LList:get`

Get the value at a 1-based index. Returns nil if out of range.

```lua
-- signature
LList:get(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | 1-based position. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | a The value. |
| `nil` | b When not available. |

---

### `LList:indexOf`

Find the 1-based index of the first occurrence of a value. Returns nil if not found.

```lua
-- signature
LList:indexOf(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `string` | The value to search for. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The 1-based index, or nil when the value is not found. |

---

### `LList:insert`

Insert a value at a 1-based index, shifting subsequent items right.

```lua
-- signature
LList:insert(index, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | 1-based insertion position. |
| `value` | `any` | The value to insert. |

---

### `LList:isEmpty`

Check whether the list is empty. This method is available to Lua scripts.

```lua
-- signature
LList:isEmpty()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if empty. |

---

### `LList:len`

Return the number of items in the list.

```lua
-- signature
LList:len()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Item count. |

---

### `LList:pop`

Remove and return the last value. Returns nil if empty.

```lua
-- signature
LList:pop()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | a The popped value. |
| `nil` | b When not available. |

---

### `LList:push`

Append a value to the end of the list (alias for add).

```lua
-- signature
LList:push(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `any` | The value to append. |

---

### `LList:remove`

Remove and return the value at a 1-based index. Returns nil if out of range.

```lua
-- signature
LList:remove(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | 1-based position to remove. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | a The removed value. |
| `nil` | b When not available. |

---

### `LList:reverse`

Reverse the order of all items in the list in-place.

```lua
-- signature
LList:reverse()
```

---

### `LList:set`

Replace the value at a 1-based index. Errors if index is 0 or out of range.

```lua
-- signature
LList:set(index, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | 1-based position. |
| `value` | `any` | The new value. |

---

### `LList:shift`

Remove and return the first value. Returns nil if empty.

```lua
-- signature
LList:shift()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | a The shifted value. |
| `nil` | b When not available. |

---

### `LList:toArray`

Return all items as an array table. This method is available to Lua scripts.

```lua
-- signature
LList:toArray()
```

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array of all values. |

---

### `LList:unshift`

Insert a value at the beginning of the list.

```lua
-- signature
LList:unshift(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `any` | The value to prepend. |

---

## LListBox

### `LListBox:addItem`

Appends a new text item to this list box.

```lua
-- signature
LListBox:addItem(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | The item text to add. |

**Example**

```lua
do
    local list = lurek.ui.newList()
    list:addItem("Sword")
    list:addItem("Shield")
    list:addItem("Potion")
    list:addItem("Scroll")
    print("count = " .. list:getItemCount())
    print("item 1 = " .. list:getItem(1))
    print("item 3 = " .. list:getItem(3))
end
```

---

### `LListBox:clearItems`

Removes all items from this list box.

```lua
-- signature
LListBox:clearItems()
```

**Example**

```lua
do
    local list = lurek.ui.newList()
    list:addItem("First")
    list:addItem("Second")
    list:addItem("Third")
    list:setItemHeight(30)
    list:removeItem(2)
    print("after remove: count=" .. list:getItemCount())
    print("item 2 now = " .. tostring(list:getItem(2)))
    list:clearItems()
    print("after clear = " .. list:getItemCount())
end
```

---

### `LListBox:getItem`

Returns the text of the item at the given 1-based index.

```lua
-- signature
LListBox:getItem(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | The 1-based item index. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | The item text, or empty string if out of range. |

**Example**

```lua
do
    local list = lurek.ui.newList()
    list:addItem("Sword")
    list:addItem("Shield")
    list:addItem("Potion")
    list:addItem("Scroll")
    print("count = " .. list:getItemCount())
    print("item 1 = " .. list:getItem(1))
    print("item 3 = " .. list:getItem(3))
end
```

---

### `LListBox:getItemCount`

Returns the number of items in this list box.

```lua
-- signature
LListBox:getItemCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The item count. |

**Example**

```lua
do
    local list = lurek.ui.newList()
    list:addItem("Sword")
    list:addItem("Shield")
    list:addItem("Potion")
    list:addItem("Scroll")
    print("count = " .. list:getItemCount())
    print("item 1 = " .. list:getItem(1))
    print("item 3 = " .. list:getItem(3))
end
```

---

### `LListBox:getSelectedIndex`

Returns the 1-based index of the currently selected item, or 0 if none.

```lua
-- signature
LListBox:getSelectedIndex()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The selected index. |

**Example**

```lua
do
    local list = lurek.ui.newList()
    list:addItem("Option A")
    list:addItem("Option B")
    list:addItem("Option C")
    list:setSelectedIndex(2)
    print("selected = " .. list:getSelectedIndex())
    list:setSelectedIndex(3)
    print("changed to = " .. list:getSelectedIndex())
end
```

---

### `LListBox:removeItem`

Removes the item at the given 1-based index from this list box.

```lua
-- signature
LListBox:removeItem(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | The 1-based index to remove. |

**Example**

```lua
do
    local list = lurek.ui.newList()
    list:addItem("First")
    list:addItem("Second")
    list:addItem("Third")
    list:setItemHeight(30)
    list:removeItem(2)
    print("after remove: count=" .. list:getItemCount())
    print("item 2 now = " .. tostring(list:getItem(2)))
    list:clearItems()
    print("after clear = " .. list:getItemCount())
end
```

---

### `LListBox:setItemHeight`

Sets the pixel height of each item row in this list box.

```lua
-- signature
LListBox:setItemHeight(h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `h` | `number` | Row height in pixels. |

**Example**

```lua
do
    local list = lurek.ui.newList()
    list:addItem("First")
    list:addItem("Second")
    list:addItem("Third")
    list:setItemHeight(30)
    list:removeItem(2)
    print("after remove: count=" .. list:getItemCount())
    print("item 2 now = " .. tostring(list:getItem(2)))
    list:clearItems()
    print("after clear = " .. list:getItemCount())
end
```

---

### `LListBox:setSelectedIndex`

Sets the selected item by 1-based index.

```lua
-- signature
LListBox:setSelectedIndex(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | The 1-based index of the item to select. |

**Example**

```lua
do
    local list = lurek.ui.newList()
    list:addItem("Option A")
    list:addItem("Option B")
    list:addItem("Option C")
    list:setSelectedIndex(2)
    print("selected = " .. list:getSelectedIndex())
    list:setSelectedIndex(3)
    print("changed to = " .. list:getSelectedIndex())
end
```

---

## LMenuBar

### `LMenuBar:addMenu`

Adds a menu (by its widget index) to this menu bar.

```lua
-- signature
LMenuBar:addMenu(menu_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `menu_idx` | `number` | The widget index of the menu to add. |

**Example**

```lua
do
    local bar = lurek.ui.newMenuBar()
    local fileMenu = lurek.ui.newMenuItem("File")
    local editMenu = lurek.ui.newMenuItem("Edit")
    local viewMenu = lurek.ui.newMenuItem("View")
    bar:addMenu(fileMenu._idx)
    bar:addMenu(editMenu._idx)
    bar:addMenu(viewMenu._idx)
    print("menus = " .. bar:getMenuCount())
    local menus = bar:getMenus()
    print("menu indices: " .. #menus .. " entries")
end
```

---

### `LMenuBar:getMenuCount`

Returns the number of menus in this menu bar.

```lua
-- signature
LMenuBar:getMenuCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The menu count. |

**Example**

```lua
do
    local bar = lurek.ui.newMenuBar()
    local fileMenu = lurek.ui.newMenuItem("File")
    local editMenu = lurek.ui.newMenuItem("Edit")
    local viewMenu = lurek.ui.newMenuItem("View")
    bar:addMenu(fileMenu._idx)
    bar:addMenu(editMenu._idx)
    bar:addMenu(viewMenu._idx)
    print("menus = " .. bar:getMenuCount())
    local menus = bar:getMenus()
    print("menu indices: " .. #menus .. " entries")
end
```

---

### `LMenuBar:getMenus`

Returns a table of widget indices for all menus in this menu bar.

```lua
-- signature
LMenuBar:getMenus()
```

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Menu widget indices. |

**Example**

```lua
do
    local bar = lurek.ui.newMenuBar()
    local fileMenu = lurek.ui.newMenuItem("File")
    local editMenu = lurek.ui.newMenuItem("Edit")
    local viewMenu = lurek.ui.newMenuItem("View")
    bar:addMenu(fileMenu._idx)
    bar:addMenu(editMenu._idx)
    bar:addMenu(viewMenu._idx)
    print("menus = " .. bar:getMenuCount())
    local menus = bar:getMenus()
    print("menu indices: " .. #menus .. " entries")
end
```

---

### `LMenuBar:removeMenu`

Removes a menu from this menu bar by its widget index.

```lua
-- signature
LMenuBar:removeMenu(menu_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `menu_idx` | `number` | The widget index of the menu to remove. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the menu was found and removed. |

**Example**

```lua
do
    local bar = lurek.ui.newMenuBar()
    local m = lurek.ui.newMenuItem("Tools")
    bar:addMenu(m._idx)
    print("before remove = " .. bar:getMenuCount())
    local ok = bar:removeMenu(m._idx)
    print("removed = " .. tostring(ok))
    print("after remove = " .. bar:getMenuCount())
end
```

---

## LMenuItem

### `LMenuItem:addSubItem`

Adds a sub-item to this menu item for building nested menus.

```lua
-- signature
LMenuItem:addSubItem(child_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `child_idx` | `number` | The widget index of the sub-item to add. |

**Example**

```lua
do
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
    print("File has " .. #subs .. " sub-items")
end
```

---

### `LMenuItem:getShortcut`

Returns the keyboard shortcut string associated with this menu item.

```lua
-- signature
LMenuItem:getShortcut()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The shortcut text. |

**Example**

```lua
do
    local mi = lurek.ui.newMenuItem("Tools")
    local sub1 = lurek.ui.newMenuItem("Options")
    mi:addSubItem(sub1._idx)
    local subs = mi:getSubItems()
    mi:setShortcut("Ctrl+T")
    local sc = mi:getShortcut()
    print("addSubItem ok; getSubItems:", type(subs), "shortcut:", sc)
end
```

---

### `LMenuItem:getSubItems`

Returns a table of widget indices for all sub-items of this menu item.

```lua
-- signature
LMenuItem:getSubItems()
```

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Sub-item widget indices. |

**Example**

```lua
do
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
    print("File has " .. #subs .. " sub-items")
end
```

---

### `LMenuItem:getText`

Returns the display text of this menu item.

```lua
-- signature
LMenuItem:getText()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The menu item text. |

**Example**

```lua
do
    local mi = lurek.ui.newMenuItem("Enable")
    local t = mi:getText()
    mi:setChecked(true)
    local checked = mi:isChecked()
    mi:setChecked(false)
    print("getText:", t, "isChecked:", mi:isChecked(), "setChecked ok")
end
```

---

### `LMenuItem:isChecked`

Returns whether this menu item is checked (for checkable menu items).

```lua
-- signature
LMenuItem:isChecked()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if checked. |

**Example**

```lua
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
```

---

### `LMenuItem:setChecked`

Sets the checked state of this menu item.

```lua
-- signature
LMenuItem:setChecked(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `boolean` | True to check. |

**Example**

```lua
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
```

---

### `LMenuItem:setOnClick`

Registers a callback invoked when this menu item is clicked.

```lua
-- signature
LMenuItem:setOnClick(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | `function` | Callback receiving the widget index. |

**Example**

```lua
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
```

---

### `LMenuItem:setShortcut`

Sets the keyboard shortcut text displayed next to this menu item.

```lua
-- signature
LMenuItem:setShortcut(shortcut)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shortcut` | `string` | The shortcut text (e.g. "Ctrl+S"). |

**Example**

```lua
do
    local mi = lurek.ui.newMenuItem("Old")
    mi:setOnClick(function(idx) print("menu clicked", idx) end)
    mi:setShortcut("Alt+F4")
    mi:setText("New Name")
    print("setOnClick/setShortcut/setText ok")
end
```

---

### `LMenuItem:setText`

Sets the display text of this menu item.

```lua
-- signature
LMenuItem:setText(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | The menu item text. |

**Example**

```lua
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
```

---

## LNinePatch

### `LNinePatch:getImageDimensions`

Returns the original image dimensions of this nine-patch.

```lua
-- signature
LNinePatch:getImageDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Image width and height. |
| `number` | b Image width and height. |

**Example**

```lua
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
```

---

### `LNinePatch:getInsets`

Returns the border insets of this nine-patch.

```lua
-- signature
LNinePatch:getInsets()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Left, top, right, and bottom insets. |
| `number` | b Left, top, right, and bottom insets. |
| `number` | c Left, top, right, and bottom insets. |
| `number` | d Left, top, right, and bottom insets. |

**Example**

```lua
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
```

---

### `LNinePatch:getSlices`

Returns the computed nine-patch slices as a table of source/dest rectangles for rendering.

```lua
-- signature
LNinePatch:getSlices()
```

**Returns**

| Type | Description |
|------|-------------|
| `LNinePatchGetSlicesResult` | Array of slice tables with sx, sy, sw, sh, dx, dy, dw, dh fields, or nil. |

**Example**

```lua
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
```

---

### `LNinePatch:setImageDimensions`

Sets the original image dimensions used for nine-patch slice calculations.

```lua
-- signature
LNinePatch:setImageDimensions(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Image width in pixels. |
| `h` | `number` | Image height in pixels. |

**Example**

```lua
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
```

---

### `LNinePatch:setInsets`

Sets the border insets defining the stretchable center region of the nine-patch image.

```lua
-- signature
LNinePatch:setInsets(left, top, right, bottom)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `left` | `number` | Left inset in pixels. |
| `top` | `number` | Top inset in pixels. |
| `right` | `number` | Right inset in pixels. |
| `bottom` | `number` | Bottom inset in pixels. |

**Example**

```lua
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
```

---

## LPanel

### `LPanel:getTitle`

Returns the title text of this panel.

```lua
-- signature
LPanel:getTitle()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The panel title. |

**Example**

```lua
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
```

---

### `LPanel:setScrollable`

Enables or disables scrolling within this panel.

```lua
-- signature
LPanel:setScrollable(scrollable)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scrollable` | `boolean` | True to enable scrolling. |

**Example**

```lua
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
```

---

### `LPanel:setTitle`

Sets the title text displayed on this panel's header.

```lua
-- signature
LPanel:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | `string` | The panel title. |

**Example**

```lua
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
```

---

## LPieChart

### `LPieChart:addSegment`

Adds a labeled segment to this pie chart widget.

```lua
-- signature
LPieChart:addSegment(label, value, r, g, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | `string` | The segment label. |
| `value` | `number` | The segment value. |
| `r` | `number` | Red color component. |
| `g` | `number` | Green color component. |
| `b` | `number` | Blue color component. |

**Example**

```lua
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
```

---

### `LPieChart:addSegmentsFromDataFrame`

Adds pie segments from dataframe rows with a built-in color palette, skipping non-positive or non-numeric values.

```lua
-- signature
LPieChart:addSegmentsFromDataFrame(df, label_col, value_col, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `df` | `LDataFrame` | Source dataframe. |
| `label_col` | `string` | Column name for segment labels. |
| `value_col` | `string` | Column name for segment values. |
| `opts?` | `table` | Optional table with maxRows integer. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of segments added. |

**Example**

```lua
do
    local df = lurek.dataframe.fromRows({ "category", "amount" }, { { "Food", 420 }, { "Rent", "1200" }, { "Skip", "bad" } })
    local chart = lurek.ui.newPieChart({width = 128, height = 128})
    local count = chart:addSegmentsFromDataFrame(df, "category", "amount")
    print("pie df segments=" .. count)
end
```

---

### `LPieChart:addSlice`

Add a slice to the pie chart â€” Lua userdata object exposed by the engine.

```lua
-- signature
LPieChart:addSlice(label, value, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | `string` | Display label for the slice. |
| `value` | `number` | Numeric value determining the slice proportion. |
| `color?` | `table` | Optional RGBA color {r, g, b, a}. Auto-assigned from palette if nil. |

---

### `LPieChart:clear`

Removes all pie data slices from this chart.

```lua
-- signature
LPieChart:clear()
```

---

### `LPieChart:drawToImage`

Renders this pie chart to an image buffer.

```lua
-- signature
LPieChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | `LImageData` | The image to draw into. |

**Example**

```lua
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
```

---

### `LPieChart:getHeight`

Get the chart output height in pixels.

```lua
-- signature
LPieChart:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Height in pixels. |

---

### `LPieChart:getWidth`

Get the chart output width in pixels.

```lua
-- signature
LPieChart:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Width in pixels. |

---

### `LPieChart:render`

Renders the chart contents into a new pixel buffer.

```lua
-- signature
LPieChart:render()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Output width in pixels. |
| `number` | b Output height in pixels. |
| `string` | c RGBA8 pixel data as a binary string. |

---

### `LPieChart:setTitle`

Set or update the chart's displayed title.

```lua
-- signature
LPieChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | `string` | New chart title text. |

---

### `LPieChart:type`

Returns the type name of this object.

```lua
-- signature
LPieChart:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LPieChart". |

**Example**

```lua
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
```

---

### `LPieChart:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LPieChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches this userdata type. |

**Example**

```lua
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
```

---

## LProgressBar

### `LProgressBar:getMax`

Returns the maximum value of this progress bar's range.

```lua
-- signature
LProgressBar:getMax()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The maximum value. |

**Example**

```lua
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
```

---

### `LProgressBar:getMin`

Returns the minimum value of this progress bar's range.

```lua
-- signature
LProgressBar:getMin()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The minimum value. |

**Example**

```lua
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
```

---

### `LProgressBar:getProgress`

Returns the normalized progress as a fraction (0.0 to 1.0) of the current range.

```lua
-- signature
LProgressBar:getProgress()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The normalized progress. |

**Example**

```lua
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
```

---

### `LProgressBar:getValue`

Returns the current value of this progress bar.

```lua
-- signature
LProgressBar:getValue()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The progress value. |

**Example**

```lua
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
```

---

### `LProgressBar:setRange`

Sets the minimum and maximum bounds for this progress bar.

```lua
-- signature
LProgressBar:setRange(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | `number` | Minimum value. |
| `max` | `number` | Maximum value. |

**Example**

```lua
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
```

---

### `LProgressBar:setValue`

Sets the current fill value of this progress bar, clamped to its range.

```lua
-- signature
LProgressBar:setValue(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | The progress value. |

**Example**

```lua
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
```

---

## LRadioButton

### `LRadioButton:getGroup`

Returns the radio button group name. Buttons in the same group are mutually exclusive.

```lua
-- signature
LRadioButton:getGroup()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The group name. |

**Example**

```lua
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
```

---

### `LRadioButton:getText`

Returns the label text of this radio button.

```lua
-- signature
LRadioButton:getText()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The radio button label. |

**Example**

```lua
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
```

---

### `LRadioButton:isSelected`

Returns whether this radio button is currently selected.

```lua
-- signature
LRadioButton:isSelected()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if selected. |

**Example**

```lua
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
```

---

### `LRadioButton:setGroup`

Sets the radio button group name. Buttons in the same group are mutually exclusive.

```lua
-- signature
LRadioButton:setGroup(group)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group` | `string` | The group name. |

**Example**

```lua
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
```

---

### `LRadioButton:setOnChange`

Registers a callback invoked when this radio button's selection changes.

```lua
-- signature
LRadioButton:setOnChange(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | `function` | Callback receiving the widget index. |

**Example**

```lua
do
    local rb = lurek.ui.newRadioButton("B", "g1")
    rb:setGroup("g2")
    rb:setSelected(true)
    rb:setOnChange(function(idx) print("radio changed", idx) end)
    rb:setText("New B")
    print("setGroup/setSelected/setOnChange/setText ok")
end
```

---

### `LRadioButton:setSelected`

Sets the selected state of this radio button.

```lua
-- signature
LRadioButton:setSelected(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `boolean` | True to select. |

**Example**

```lua
do
    local rb = lurek.ui.newRadioButton("B", "g1")
    rb:setGroup("g2")
    rb:setSelected(true)
    rb:setOnChange(function(idx) print("radio changed", idx) end)
    rb:setText("New B")
    print("setGroup/setSelected/setOnChange/setText ok")
end
```

---

### `LRadioButton:setText`

Sets the label text of this radio button.

```lua
-- signature
LRadioButton:setText(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | The radio button label. |

**Example**

```lua
do
    local rb = lurek.ui.newRadioButton("original", "group_test")
    rb:setText("updated")
    print("LRadioButton setText:", rb:getText())
end
```

---

## LScatterPlot

### `LScatterPlot:addSeries`

Add a named data series to the scatter plot.

```lua
-- signature
LScatterPlot:addSeries(name, data, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Display name of the series. |
| `data` | `table` | Array of {x, y} point tables. |
| `color?` | `table` | Optional RGBA color {r, g, b, a}. |

---

### `LScatterPlot:addSeriesFromDataFrame`

Adds a data series from dataframe columns, skipping rows with non-numeric x or y cells.

```lua
-- signature
LScatterPlot:addSeriesFromDataFrame(name, df, x_col, y_col, r, g, b, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | The series name. |
| `df` | `LDataFrame` | Source dataframe. |
| `x_col` | `string` | Column name for X values. |
| `y_col` | `string` | Column name for Y values. |
| `r` | `number` | Red color component. |
| `g` | `number` | Green color component. |
| `b` | `number` | Blue color component. |
| `opts?` | `table` | Optional table with maxRows integer. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of accepted points added to the series. |

**Example**

```lua
do
    -- Adds a series of points to a scatter plot by pulling 'x' and 'y' columns
    -- directly from a dataframe.
    local df = lurek.dataframe.fromRows({ "x", "y" }, { { 1, 2 }, { 3, 4 }, { 5, 6 } })
    local chart = lurek.ui.newScatterPlot({width = 200, height = 100})
    local count = chart:addSeriesFromDataFrame("Data", df, "x", "y", 0.5, 0.5, 0.5)
    print("scatter df points=" .. count)
end
```

---

### `LScatterPlot:clear`

Removes all data series from this chart.

```lua
-- signature
LScatterPlot:clear()
```

---

### `LScatterPlot:drawToImage`

Renders this scatter plot to an image buffer.

```lua
-- signature
LScatterPlot:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | `LImageData` | The image to draw into. |

**Example**

```lua
do
    local sp = lurek.ui.newScatterPlot({width = 200, height = 150})
    sp:setXRange(0, 100)
    sp:setYRange(0, 100)
    sp:addSeries("data1", {{10,20},{30,40},{50,30},{70,60}}, 0.9, 0.2, 0.2)
    local img = lurek.image.newImageData(200, 150)
    sp:drawToImage(img)
    print("ScatterPlot addSeries/setXRange/drawToImage ok")
end
```

---

### `LScatterPlot:getHeight`

Get the chart output height in pixels.

```lua
-- signature
LScatterPlot:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Height in pixels. |

---

### `LScatterPlot:getWidth`

Get the chart output width in pixels.

```lua
-- signature
LScatterPlot:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Width in pixels. |

---

### `LScatterPlot:render`

Renders the chart contents into a new pixel buffer.

```lua
-- signature
LScatterPlot:render()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Output width in pixels. |
| `number` | b Output height in pixels. |
| `string` | c RGBA8 pixel data as a binary string. |

---

### `LScatterPlot:setDotRadius`

Set the radius of the dot drawn for each data point.

```lua
-- signature
LScatterPlot:setDotRadius(r)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Dot radius in pixels (minimum 1). |

---

### `LScatterPlot:setTitle`

Set or update the chart's displayed title.

```lua
-- signature
LScatterPlot:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | `string` | New chart title text. |

---

### `LScatterPlot:setXRange`

Sets the X-axis range for this scatter plot.

```lua
-- signature
LScatterPlot:setXRange(mn, mx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mn` | `number` | Minimum X value. |
| `mx` | `number` | Maximum X value. |

**Example**

```lua
do
    local sp = lurek.ui.newScatterPlot({width = 200, height = 150})
    sp:setXRange(0, 100)
    sp:setYRange(0, 100)
    sp:addSeries("data1", {{10,20},{30,40},{50,30},{70,60}}, 0.9, 0.2, 0.2)
    local img = lurek.image.newImageData(200, 150)
    sp:drawToImage(img)
    print("ScatterPlot addSeries/setXRange/drawToImage ok")
end
```

---

### `LScatterPlot:setYRange`

Sets the Y-axis range for this scatter plot.

```lua
-- signature
LScatterPlot:setYRange(mn, mx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mn` | `number` | Minimum Y value. |
| `mx` | `number` | Maximum Y value. |

**Example**

```lua
do
    local sp = lurek.ui.newScatterPlot({width = 100, height = 80})
    sp:setXRange(0, 50)
    sp:setYRange(0, 50)
    local t = sp:type()
    local ok = sp:typeOf("LScatterPlot")
    print("setYRange ok, type:", t, "typeOf:", ok)
end
```

---

### `LScatterPlot:type`

Returns the type name of this object.

```lua
-- signature
LScatterPlot:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LScatterPlot". |

**Example**

```lua
do
    local sp = lurek.ui.newScatterPlot({width = 100, height = 80})
    sp:setXRange(0, 50)
    sp:setYRange(0, 50)
    local t = sp:type()
    local ok = sp:typeOf("LScatterPlot")
    print("setYRange ok, type:", t, "typeOf:", ok)
end
```

---

### `LScatterPlot:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LScatterPlot:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches this userdata type. |

**Example**

```lua
do
    local sp = lurek.ui.newScatterPlot({width = 100, height = 80})
    sp:setXRange(0, 50)
    sp:setYRange(0, 50)
    local t = sp:type()
    local ok = sp:typeOf("LScatterPlot")
    print("setYRange ok, type:", t, "typeOf:", ok)
end
```

---

## LScrollBar

### `LScrollBar:getContentSize`

Returns the total content size tracked by this scroll bar.

```lua
-- signature
LScrollBar:getContentSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The content size. |

**Example**

```lua
do
    local sb = lurek.ui.newScrollBar(true)
    local cs = sb:getContentSize()
    local pos = sb:getScrollPosition()
    local vs = sb:getViewSize()
    print("contentSize:", cs, "scrollPos:", pos, "viewSize:", vs)
end
```

---

### `LScrollBar:getScrollPosition`

Returns the current scroll position of this scroll bar.

```lua
-- signature
LScrollBar:getScrollPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The scroll position. |

**Example**

```lua
do
    local sb = lurek.ui.newScrollBar(true)
    local cs = sb:getContentSize()
    local pos = sb:getScrollPosition()
    local vs = sb:getViewSize()
    print("contentSize:", cs, "scrollPos:", pos, "viewSize:", vs)
end
```

---

### `LScrollBar:getViewSize`

Returns the visible viewport size tracked by this scroll bar.

```lua
-- signature
LScrollBar:getViewSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The view size. |

**Example**

```lua
do
    local sb = lurek.ui.newScrollBar(true)
    local cs = sb:getContentSize()
    local pos = sb:getScrollPosition()
    local vs = sb:getViewSize()
    print("contentSize:", cs, "scrollPos:", pos, "viewSize:", vs)
end
```

---

### `LScrollBar:isVertical`

Returns whether this scroll bar is oriented vertically.

```lua
-- signature
LScrollBar:isVertical()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if vertical. |

**Example**

```lua
do
    local sb = lurek.ui.newScrollBar(false)
    local vert = sb:isVertical()
    sb:setContentSize(500)
    sb:setOnChange(function(val) print("scroll:", val) end)
    local cs = sb:getContentSize()
    print("isVertical:", vert, "contentSize after set:", cs)
end
```

---

### `LScrollBar:setContentSize`

Sets the total content size that this scroll bar represents.

```lua
-- signature
LScrollBar:setContentSize(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | The content size. |

**Example**

```lua
do
    local sb = lurek.ui.newScrollBar(false)
    local vert = sb:isVertical()
    sb:setContentSize(500)
    sb:setOnChange(function(val) print("scroll:", val) end)
    local cs = sb:getContentSize()
    print("isVertical:", vert, "contentSize after set:", cs)
end
```

---

### `LScrollBar:setOnChange`

Registers a callback invoked when this scroll bar's position changes.

```lua
-- signature
LScrollBar:setOnChange(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | `function` | Callback receiving the widget index. |

**Example**

```lua
do
    local sb = lurek.ui.newScrollBar(false)
    local vert = sb:isVertical()
    sb:setContentSize(500)
    sb:setOnChange(function(val) print("scroll:", val) end)
    local cs = sb:getContentSize()
    print("isVertical:", vert, "contentSize after set:", cs)
end
```

---

### `LScrollBar:setScrollPosition`

Sets the scroll position of this scroll bar, clamped to the valid range.

```lua
-- signature
LScrollBar:setScrollPosition(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | The scroll position. |

**Example**

```lua
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
```

---

### `LScrollBar:setViewSize`

Sets the visible viewport size for this scroll bar.

```lua
-- signature
LScrollBar:setViewSize(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | The view size. |

**Example**

```lua
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
```

---

## LScrollPanel

### `LScrollPanel:getContentSize`

Returns the virtual content dimensions of this scroll panel.

```lua
-- signature
LScrollPanel:getContentSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Content width and height in pixels. |
| `number` | b Content width and height in pixels. |

**Example**

```lua
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
```

---

### `LScrollPanel:getMaxScroll`

Returns the maximum scroll offset allowed in each axis.

```lua
-- signature
LScrollPanel:getMaxScroll()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Maximum horizontal and vertical scroll values. |
| `number` | b Maximum horizontal and vertical scroll values. |

**Example**

```lua
do
    local sp = lurek.ui.newScrollPanel()
    local mx, my = sp:getMaxScroll()
    local px, py = sp:getScrollPosition()
    local speed = sp:getScrollSpeed()
    print("maxScroll:", mx, my, "scrollPos:", px, py, "speed:", speed)
end
```

---

### `LScrollPanel:getScrollPosition`

Returns the current scroll offset of this scroll panel.

```lua
-- signature
LScrollPanel:getScrollPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Horizontal and vertical scroll offsets. |
| `number` | b Horizontal and vertical scroll offsets. |

**Example**

```lua
do
    local sp = lurek.ui.newScrollPanel()
    local mx, my = sp:getMaxScroll()
    local px, py = sp:getScrollPosition()
    local speed = sp:getScrollSpeed()
    print("maxScroll:", mx, my, "scrollPos:", px, py, "speed:", speed)
end
```

---

### `LScrollPanel:getScrollSpeed`

Returns the current scroll speed multiplier.

```lua
-- signature
LScrollPanel:getScrollSpeed()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The scroll speed. |

**Example**

```lua
do
    ---@type LScrollPanel
    local scroll = lurek.ui.newScrollPanel()
    scroll:setScrollSpeed(30)
    print("scroll speed = " .. scroll:getScrollSpeed())
end
```

---

### `LScrollPanel:setContentSize`

Sets the virtual content dimensions of this scroll panel.

```lua
-- signature
LScrollPanel:setContentSize(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Content width in pixels. |
| `h` | `number` | Content height in pixels. |

**Example**

```lua
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
```

---

### `LScrollPanel:setScrollPosition`

Sets the scroll offset position of this scroll panel.

```lua
-- signature
LScrollPanel:setScrollPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Horizontal scroll offset. |
| `y` | `number` | Vertical scroll offset. |

**Example**

```lua
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
```

---

### `LScrollPanel:setScrollSpeed`

Sets the scroll speed multiplier for mouse wheel scrolling.

```lua
-- signature
LScrollPanel:setScrollSpeed(speed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `speed` | `number` | Scroll speed in pixels per scroll tick. |

**Example**

```lua
do
    ---@type LScrollPanel
    local scroll = lurek.ui.newScrollPanel()
    scroll:setScrollSpeed(30)
    print("scroll speed = " .. scroll:getScrollSpeed())
end
```

---

## LSeparator

### `LSeparator:getThickness`

Returns the line thickness of this separator.

```lua
-- signature
LSeparator:getThickness()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The thickness in pixels. |

**Example**

```lua
do
    local sep = lurek.ui.newSeparator(true)
    local vert = sep:isVertical()
    local thick = sep:getThickness()
    sep:setThickness(4)
    local t2 = sep:getThickness()
    print("isVertical:", vert, "thickness:", thick, "â†’", t2)
end
```

---

### `LSeparator:isVertical`

Returns whether this separator is oriented vertically.

```lua
-- signature
LSeparator:isVertical()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if vertical. |

**Example**

```lua
do
    local sep = lurek.ui.newSeparator(true)
    local vert = sep:isVertical()
    local thick = sep:getThickness()
    sep:setThickness(4)
    local t2 = sep:getThickness()
    print("isVertical:", vert, "thickness:", thick, "â†’", t2)
end
```

---

### `LSeparator:setThickness`

Sets the line thickness of this separator in pixels.

```lua
-- signature
LSeparator:setThickness(thickness)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `thickness` | `number` | Thickness in pixels. |

**Example**

```lua
do
    local sep = lurek.ui.newSeparator(true)
    local vert = sep:isVertical()
    local thick = sep:getThickness()
    sep:setThickness(4)
    local t2 = sep:getThickness()
    print("isVertical:", vert, "thickness:", thick, "â†’", t2)
end
```

---

### `LSeparator:setVertical`

Sets whether this separator draws vertically or horizontally.

```lua
-- signature
LSeparator:setVertical(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `boolean` | True for vertical, false for horizontal. |

**Example**

```lua
do
    local sep = lurek.ui.newSeparator(false)
    sep:setVertical(true)
    local sl = lurek.ui.newSlider(0, 100)
    local mn = sl:getMin()
    local mx = sl:getMax()
    print("separator setVertical ok; slider min:", mn, "max:", mx)
end
```

---

## LSlider

### `LSlider:getMax`

Returns the maximum value of this slider's range.

```lua
-- signature
LSlider:getMax()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The maximum value. |

**Example**

```lua
do
    local sep = lurek.ui.newSeparator(false)
    sep:setVertical(true)
    local sl = lurek.ui.newSlider(0, 100)
    local mn = sl:getMin()
    local mx = sl:getMax()
    print("separator setVertical ok; slider min:", mn, "max:", mx)
end
```

---

### `LSlider:getMin`

Returns the minimum value of this slider's range.

```lua
-- signature
LSlider:getMin()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The minimum value. |

**Example**

```lua
do
    local sep = lurek.ui.newSeparator(false)
    sep:setVertical(true)
    local sl = lurek.ui.newSlider(0, 100)
    local mn = sl:getMin()
    local mx = sl:getMax()
    print("separator setVertical ok; slider min:", mn, "max:", mx)
end
```

---

### `LSlider:getValue`

Returns the current value of this slider.

```lua
-- signature
LSlider:getValue()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The slider value. |

**Example**

```lua
do
    local sl = lurek.ui.newSlider(0, 50)
    sl:setRange(0, 100)
    local mx = sl:getMax()
    sl:setStep(5)
    sl:setValue(75)
    local v = sl:getValue()
    print("setRange max:", mx, "getValue:", v)
end
```

---

### `LSlider:setRange`

Sets the minimum and maximum bounds for this slider.

```lua
-- signature
LSlider:setRange(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | `number` | Minimum value. |
| `max` | `number` | Maximum value. |

**Example**

```lua
do
    local slider = lurek.ui.newSlider(0, 10)
    slider:setValue(5)
    print("before: " .. slider:getMin() .. " to " .. slider:getMax() .. " val=" .. slider:getValue())
    slider:setRange(0, 100)
    print("after: " .. slider:getMin() .. " to " .. slider:getMax() .. " val=" .. slider:getValue())
end
```

---

### `LSlider:setStep`

Sets the step increment for this slider's value snapping.

```lua
-- signature
LSlider:setStep(step)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `step` | `number` | The step size. |

**Example**

```lua
do
    local slider = lurek.ui.newSlider(0, 1)
    slider:setStep(0.1)
    slider:setValue(0.5)
    print("value = " .. slider:getValue())
    slider:setValue(1.5)
    print("clamped = " .. slider:getValue())
end
```

---

### `LSlider:setValue`

Sets the current value of this slider, clamped to its range.

```lua
-- signature
LSlider:setValue(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | The value to set. |

**Example**

```lua
do
    local slider = lurek.ui.newSlider(0, 1)
    slider:setStep(0.1)
    slider:setValue(0.5)
    print("value = " .. slider:getValue())
    slider:setValue(1.5)
    print("clamped = " .. slider:getValue())
end
```

---

## LSpinBox

### `LSpinBox:decrement`

Decreases this spin box's value by one step.

```lua
-- signature
LSpinBox:decrement()
```

**Example**

```lua
do
    local spin = lurek.ui.newSpinBox(0, 100)
    spin:setValue(10)
    spin:setStep(5)
    spin:increment()
    print("after increment = " .. spin:getValue())
    spin:decrement()
    spin:decrement()
    print("after 2 decrements = " .. spin:getValue())
end
```

---

### `LSpinBox:getValue`

Returns the current numeric value of this spin box.

```lua
-- signature
LSpinBox:getValue()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The spin box value. |

**Example**

```lua
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
```

---

### `LSpinBox:increment`

Increases this spin box's value by one step.

```lua
-- signature
LSpinBox:increment()
```

**Example**

```lua
do
    local spin = lurek.ui.newSpinBox(0, 100)
    spin:setValue(10)
    spin:setStep(5)
    spin:increment()
    print("after increment = " .. spin:getValue())
    spin:decrement()
    spin:decrement()
    print("after 2 decrements = " .. spin:getValue())
end
```

---

### `LSpinBox:setRange`

Sets the minimum and maximum bounds for this spin box.

```lua
-- signature
LSpinBox:setRange(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | `number` | Minimum value. |
| `max` | `number` | Maximum value. |

**Example**

```lua
do
    ---@type LSpinBox
    local spin = lurek.ui.newSpinBox(0, 10)
    spin:setValue(8)
    spin:setRange(0, 5)
    print("clamped to range = " .. spin:getValue())
end
```

---

### `LSpinBox:setStep`

Sets the step increment for this spin box.

```lua
-- signature
LSpinBox:setStep(step)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `step` | `number` | The step size (minimum 1e-9). |

**Example**

```lua
do
    local spin = lurek.ui.newSpinBox(0, 100)
    spin:setValue(10)
    spin:setStep(5)
    spin:increment()
    print("after increment = " .. spin:getValue())
    spin:decrement()
    spin:decrement()
    print("after 2 decrements = " .. spin:getValue())
end
```

---

### `LSpinBox:setValue`

Sets the numeric value of this spin box, clamped to its range.

```lua
-- signature
LSpinBox:setValue(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | The value to set. |

**Example**

```lua
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
```

---

## LSplitPanel

### `LSplitPanel:getFirstChild`

Returns the widget index of the first (left/top) child panel.

```lua
-- signature
LSplitPanel:getFirstChild()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The widget index, or nil if not set. |

**Example**

```lua
do
    local sp = lurek.ui.newSplitPanel("horizontal")
    local first = lurek.ui.newPanel()
    local second = lurek.ui.newPanel()
    print("type=" .. sp:type())
    print("orientation=" .. sp:getOrientation())
    sp:setFirstChild(first._idx)
    sp:setSecondChild(second._idx)
    local fc = sp:getFirstChild()
    local sc = sp:getSecondChild()
    print("fc=" .. tostring(fc))
    print("sc=" .. tostring(sc))
    sp:setSplitPosition(0.4)
    print("split_pos=" .. sp:getSplitPosition())
    sp:setMinPanelSize(80)
    print("min_panel=" .. sp:getMinPanelSize())
    sp:setOrientation("vertical")
    print("orientation_after=" .. sp:getOrientation())
end
```

---

### `LSplitPanel:getMinPanelSize`

Returns the minimum pixel size of each split sub-panel.

```lua
-- signature
LSplitPanel:getMinPanelSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The minimum size in pixels. |

**Example**

```lua
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
```

---

### `LSplitPanel:getOrientation`

Returns the orientation of this split panel ("horizontal" or "vertical").

```lua
-- signature
LSplitPanel:getOrientation()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The orientation. |

**Example**

```lua
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
```

---

### `LSplitPanel:getSecondChild`

Returns the widget index of the second (right/bottom) child panel.

```lua
-- signature
LSplitPanel:getSecondChild()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The widget index, or nil if not set. |

**Example**

```lua
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
```

---

### `LSplitPanel:getSplitPosition`

Returns the split position as a fraction (0.0 to 1.0) of the panel's total size.

```lua
-- signature
LSplitPanel:getSplitPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The split fraction. |

**Example**

```lua
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
```

---

### `LSplitPanel:setFirstChild`

Sets the widget index for the first (left/top) panel.

```lua
-- signature
LSplitPanel:setFirstChild(child_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `child_idx` | `number` | The widget index. |

**Example**

```lua
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
```

---

### `LSplitPanel:setMinPanelSize`

Sets the minimum pixel size of each split sub-panel.

```lua
-- signature
LSplitPanel:setMinPanelSize(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | The minimum size in pixels. |

**Example**

```lua
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
```

---

### `LSplitPanel:setOrientation`

Sets the orientation of this split panel ("horizontal" or "vertical").

```lua
-- signature
LSplitPanel:setOrientation(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `string` | The orientation. |

**Example**

```lua
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
```

---

### `LSplitPanel:setSecondChild`

Sets the widget index for the second (right/bottom) panel.

```lua
-- signature
LSplitPanel:setSecondChild(child_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `child_idx` | `number` | The widget index. |

**Example**

```lua
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
```

---

### `LSplitPanel:setSplitPosition`

Sets the split position as a fraction (0.0 to 1.0).

```lua
-- signature
LSplitPanel:setSplitPosition(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | The split fraction. |

**Example**

```lua
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
```

---

## LStatusBar

### `LStatusBar:addSection`

Adds a labeled section to this status bar.

```lua
-- signature
LStatusBar:addSection(text, width)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | The section display text. |
| `width?` | `number` | The section width in pixels (default 100). |

**Example**

```lua
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
```

---

### `LStatusBar:getSectionCount`

Returns the number of sections in this status bar.

```lua
-- signature
LStatusBar:getSectionCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The section count. |

**Example**

```lua
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
```

---

### `LStatusBar:getSectionText`

Returns the text of a status bar section by its 1-based index.

```lua
-- signature
LStatusBar:getSectionText(section_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `section_idx` | `number` | The 1-based section index. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | The section text, or nil if out of range. |

**Example**

```lua
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
```

---

### `LStatusBar:setSectionCount`

Sets the number of sections, truncating or adding empty sections as needed.

```lua
-- signature
LStatusBar:setSectionCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | `number` | The desired section count. |

**Example**

```lua
do
    local sb = lurek.ui.newStatusBar()
    sb:setSectionCount(3)
    local cnt = sb:getSectionCount()
    sb:setSectionText(1, "Line 1")
    local txt = sb:getSectionText(1)
    sb:setSectionText(2, "Col 5")
    print("sectionCount:", cnt, "section1:", txt)
end
```

---

### `LStatusBar:setSectionText`

Sets the text of a status bar section by its 1-based index.

```lua
-- signature
LStatusBar:setSectionText(section_idx, text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `section_idx` | `number` | The 1-based section index. |
| `text` | `string` | The new section text. |

**Example**

```lua
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
```

---

### `LStatusBar:setSectionWidget`

Associates a widget with a status bar section (reserved for future use).

```lua
-- signature
LStatusBar:setSectionWidget(section_idx, widget)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `section_idx` | `number` | The 1-based section index. |
| `widget?` | `table` | The widget table to associate, or nil to clear. |

**Example**

```lua
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
```

---

## LSwitch

### `LSwitch:isOn`

Returns whether this switch is currently in the on state.

```lua
-- signature
LSwitch:isOn()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the switch is on. |

**Example**

```lua
do
    local sw = lurek.ui.newSwitch(false)
    print("type=" .. sw:type())
    print("is_on=" .. tostring(sw:isOn()))
    sw:setOn(true)
    print("is_on_after=" .. tostring(sw:isOn()))
    sw:setOnChange(function(v) print("switch_changed=" .. tostring(v)) end)
end
```

---

### `LSwitch:setOn`

Sets the on/off state of this toggle switch.

```lua
-- signature
LSwitch:setOn(on)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `on` | `boolean` | True to turn on, false to turn off. |

**Example**

```lua
do
    local sw = lurek.ui.newSwitch(true)
    print("initial = " .. tostring(sw:isOn()))
    sw:toggle()
    print("toggled = " .. tostring(sw:isOn()))
    sw:setOn(true)
    print("forced on = " .. tostring(sw:isOn()))
end
```

---

### `LSwitch:toggle`

Toggles this switch between on and off states.

```lua
-- signature
LSwitch:toggle()
```

**Example**

```lua
do
    local sw = lurek.ui.newSwitch(true)
    print("initial = " .. tostring(sw:isOn()))
    sw:toggle()
    print("toggled = " .. tostring(sw:isOn()))
    sw:setOn(true)
    print("forced on = " .. tostring(sw:isOn()))
end
```

---

## LTabBar

### `LTabBar:addTab`

Adds a new tab with the given label to this tab bar.

```lua
-- signature
LTabBar:addTab(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | `string` | The tab label text. |

**Example**

```lua
do
    local tabs = lurek.ui.newTabBar()
    tabs:addTab("General")
    tabs:addTab("Graphics")
    tabs:addTab("Audio")
    tabs:addTab("Controls")
    print("count = " .. tabs:getTabCount())
    print("tab 1 = " .. tabs:getTab(1))
    print("tab 3 = " .. tabs:getTab(3))
end
```

---

### `LTabBar:getActiveTab`

Returns the 1-based index of the currently active tab.

```lua
-- signature
LTabBar:getActiveTab()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The active tab index. |

**Example**

```lua
do
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
```

---

### `LTabBar:getTab`

Returns the label of the tab at the given 1-based index.

```lua
-- signature
LTabBar:getTab(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | The 1-based tab index. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | The tab label, or nil if out of range. |

**Example**

```lua
do
    local tabs = lurek.ui.newTabBar()
    tabs:addTab("General")
    tabs:addTab("Graphics")
    tabs:addTab("Audio")
    tabs:addTab("Controls")
    print("count = " .. tabs:getTabCount())
    print("tab 1 = " .. tabs:getTab(1))
    print("tab 3 = " .. tabs:getTab(3))
end
```

---

### `LTabBar:getTabCount`

Returns the total number of tabs in this tab bar.

```lua
-- signature
LTabBar:getTabCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The tab count. |

**Example**

```lua
do
    local tabs = lurek.ui.newTabBar()
    tabs:addTab("General")
    tabs:addTab("Graphics")
    tabs:addTab("Audio")
    tabs:addTab("Controls")
    print("count = " .. tabs:getTabCount())
    print("tab 1 = " .. tabs:getTab(1))
    print("tab 3 = " .. tabs:getTab(3))
end
```

---

### `LTabBar:removeTab`

Removes the tab at the given 1-based index.

```lua
-- signature
LTabBar:removeTab(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | The 1-based tab index. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the tab was removed. |

**Example**

```lua
do
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
```

---

### `LTabBar:setActiveTab`

Sets the active (selected) tab by 1-based index.

```lua
-- signature
LTabBar:setActiveTab(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | The 1-based tab index to activate. |

**Example**

```lua
do
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
```

---

## LTextInput

### `LTextInput:getCursorPosition`

Returns the current cursor position (character index) within the text input.

```lua
-- signature
LTextInput:getCursorPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The zero-based cursor position. |

**Example**

```lua
do
    local input = lurek.ui.newTextInput()
    input:setMaxLength(50)
    input:setText("Short text")
    local pos = input:getCursorPosition()
    print("cursor at = " .. pos)
    print("focused = " .. tostring(input:isFocused()))
end
```

---

### `LTextInput:getPlaceholder`

Returns the placeholder text of this text input.

```lua
-- signature
LTextInput:getPlaceholder()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The placeholder text. |

**Example**

```lua
do
    ---@type LTextInput
    local input = lurek.ui.newTextInput()
    input:setPlaceholder("Enter your name...")
    print("placeholder = " .. input:getPlaceholder())
end
```

---

### `LTextInput:getText`

Returns the current text content of this text input field.

```lua
-- signature
LTextInput:getText()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The input text. |

**Example**

```lua
do
    local ti = lurek.ui.newTextInput()
    ti:setText("hello")
    local txt = ti:getText()
    ti:setPlaceholder("type here")
    local ph = ti:getPlaceholder()
    local cur = ti:getCursorPosition()
    print("text:", txt, "placeholder:", ph, "cursor:", cur)
end
```

---

### `LTextInput:isFocused`

Returns whether this text input currently has keyboard focus.

```lua
-- signature
LTextInput:isFocused()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if focused. |

**Example**

```lua
do
    local ti = lurek.ui.newTextInput()
    ti:setPlaceholder("Search...")
    local ph = ti:getPlaceholder()
    ti:setMaxLength(50)
    local focused = ti:isFocused()
    print("placeholder:", ph, "isFocused:", focused)
end
```

---

### `LTextInput:setMaxLength`

Sets the maximum number of characters allowed in this text input.

```lua
-- signature
LTextInput:setMaxLength(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | `number` | Maximum character count. |

**Example**

```lua
do
    local input = lurek.ui.newTextInput()
    input:setMaxLength(50)
    input:setText("Short text")
    local pos = input:getCursorPosition()
    print("cursor at = " .. pos)
    print("focused = " .. tostring(input:isFocused()))
end
```

---

### `LTextInput:setPlaceholder`

Sets the placeholder text shown when the input is empty.

```lua
-- signature
LTextInput:setPlaceholder(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | The placeholder text. |

**Example**

```lua
do
    ---@type LTextInput
    local input = lurek.ui.newTextInput()
    input:setPlaceholder("Enter your name...")
    print("placeholder = " .. input:getPlaceholder())
end
```

---

### `LTextInput:setText`

Sets the text content of this text input field and moves the cursor to the end.

```lua
-- signature
LTextInput:setText(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | The text to set. |

**Example**

```lua
do
    local ti = lurek.ui.newTextInput()
    ti:setText("hello")
    local txt = ti:getText()
    ti:setPlaceholder("type here")
    local ph = ti:getPlaceholder()
    local cur = ti:getCursorPosition()
    print("text:", txt, "placeholder:", ph, "cursor:", cur)
end
```

---

## LTheme

### `LTheme:setStyle`

Sets a style entry for the given widget type and state, optionally restricted to a style class.

```lua
-- signature
LTheme:setStyle(widget_type, state, styleOrClass, styleTable)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `widget_type` | `string` | The widget type name (e.g. "button"). |
| `state` | `string` | The widget state (e.g. "normal", "hovered"). |
| `styleOrClass` | `any` | Style table for default styles, or a class string when `styleTable` is supplied. |
| `styleTable?` | `table` | Style table used when `styleOrClass` is a class string. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the style is applied. |

**Example**

```lua
do
    local ti = lurek.ui.newTextInput()
    ti:setText("sample input")
    local txt = ti:getText()
    local th = lurek.ui.newTheme()
    th:setStyle("button", "normal", {bg_color = {0.2, 0.3, 0.8}})
    local t = th:type()
    print("text:", txt, "theme type:", t)
end
```

---

### `LTheme:type`

Returns the type name of this object.

```lua
-- signature
LTheme:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LTheme". |

**Example**

```lua
do
    local ti = lurek.ui.newTextInput()
    ti:setText("sample input")
    local txt = ti:getText()
    local th = lurek.ui.newTheme()
    th:setStyle("button", "normal", {bg_color = {0.2, 0.3, 0.8}})
    local t = th:type()
    print("text:", txt, "theme type:", t)
end
```

---

### `LTheme:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LTheme:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches this userdata type. |

**Example**

```lua
do
    local th = lurek.ui.newTheme()
    local ok = th:typeOf("LTheme")
    local toast = lurek.ui.newToast("Level up!", 3.0)
    local dur = toast:getDuration()
    local msg = toast:getMessage()
    print("theme typeOf:", ok, "duration:", dur, "message:", msg)
end
```

---

## LToast

### `LToast:getDuration`

Returns the display duration of this toast in seconds.

```lua
-- signature
LToast:getDuration()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The duration. |

**Example**

```lua
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
```

---

### `LToast:getMessage`

Returns the message text of this toast.

```lua
-- signature
LToast:getMessage()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The toast message. |

**Example**

```lua
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
```

---

### `LToast:getProgress`

Returns the elapsed fraction (0.0 to 1.0) of this toast's lifetime.

```lua
-- signature
LToast:getProgress()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The progress fraction. |

**Example**

```lua
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
```

---

### `LToast:isExpired`

Returns whether this toast has exceeded its display duration.

```lua
-- signature
LToast:isExpired()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if expired. |

**Example**

```lua
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
```

---

### `LToast:setDuration`

Sets how long this toast is displayed in seconds.

```lua
-- signature
LToast:setDuration(d)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `d` | `number` | Duration in seconds. |

**Example**

```lua
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
```

---

### `LToast:setMessage`

Sets the message text displayed by this toast notification.

```lua
-- signature
LToast:setMessage(msg)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `msg` | `string` | The toast message. |

**Example**

```lua
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
```

---

## LToolbar

### `LToolbar:addButton`

Adds a new button to this toolbar and returns its 1-based index.

```lua
-- signature
LToolbar:addButton(id, tooltip)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `string` | The button identifier. |
| `tooltip?` | `string` | Optional tooltip text for the button. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The 1-based index of the added button. |

**Example**

```lua
do
    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    print("btn=" .. tostring(bar:getButton("btn_save") ~= nil))
end
```

---

### `LToolbar:addSeparator`

Adds a visual separator to this toolbar.

```lua
-- signature
LToolbar:addSeparator()
```

**Example**

```lua
do
    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    bar:addSeparator()
    print("separator added")
end
```

---

### `LToolbar:addSpacer`

Adds a flexible spacer to this toolbar.

```lua
-- signature
LToolbar:addSpacer(_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `_size?` | `number` | Optional size hint (reserved for future use). |

**Example**

```lua
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("cut", "Cut")
    tb:addSpacer(10)
    tb:addButton("paste", "Paste")
    local ori = tb:getOrientation()
    local btn = tb:getButton("cut")
    print("orientation:", ori, "button:", btn)
end
```

---

### `LToolbar:getButton`

Returns a table describing the toolbar button with the given ID.

```lua
-- signature
LToolbar:getButton(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `string` | The button identifier. |

**Returns**

| Type | Description |
|------|-------------|
| `LToolbarGetButtonResult` | Table with id, tooltip, enabled, toggled fields, or nil if not found. |

**Example**

```lua
do
    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    local btn = bar:getButton("btn_save")
    print("btn=" .. tostring(btn ~= nil))
end
```

---

### `LToolbar:getOrientation`

Returns the toolbar orientation ("horizontal" or "vertical").

```lua
-- signature
LToolbar:getOrientation()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The orientation. |

**Example**

```lua
do
    local bar = lurek.ui.newToolbar("horizontal")
    print("orientation=" .. bar:getOrientation())
end
```

---

### `LToolbar:isButtonToggled`

Returns whether a toolbar button is toggled on.

```lua
-- signature
LToolbar:isButtonToggled(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `string` | The button identifier. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if toggled, nil if not found. |

**Example**

```lua
do
    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    print("toggled=" .. tostring(bar:isButtonToggled("btn_save")))
end
```

---

### `LToolbar:setButtonEnabled`

Enables or disables a toolbar button by its ID.

```lua
-- signature
LToolbar:setButtonEnabled(id, enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `string` | The button identifier. |
| `enabled` | `boolean` | True to enable. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the button was found. |

**Example**

```lua
do
    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_open", "Open file")
    bar:setButtonEnabled("btn_open", false)
    print("btn_open disabled")
end
```

---

### `LToolbar:setButtonToggled`

Sets the toggle state of a toolbar button by its ID.

```lua
-- signature
LToolbar:setButtonToggled(id, toggled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `string` | The button identifier. |
| `toggled` | `boolean` | True to toggle on. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the button was found. |

**Example**

```lua
do
    local bar = lurek.ui.newToolbar("horizontal")
    bar:addButton("btn_save", "Save file")
    bar:setButtonToggled("btn_save", true)
    print("toggled_after=" .. tostring(bar:isButtonToggled("btn_save")))
end
```

---

### `LToolbar:setOrientation`

Sets the toolbar orientation ("horizontal" or "vertical").

```lua
-- signature
LToolbar:setOrientation(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `string` | The orientation. |

**Example**

```lua
do
    local bar = lurek.ui.newToolbar("horizontal")
    bar:setOrientation("vertical")
    print("orientation_after=" .. bar:getOrientation())
end
```

---

## LTooltipPanel

### `LTooltipPanel:getDelay`

Returns the delay in seconds before this tooltip appears.

```lua
-- signature
LTooltipPanel:getDelay()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The delay in seconds. |

**Example**

```lua
do
    local ttp = lurek.ui.newTooltipPanel("Hover info")
    print("type=" .. ttp:type())
    print("text=" .. ttp:getText())
    ttp:setText("Updated tooltip")
    print("text_after=" .. ttp:getText())
    ttp:setDelay(0.5)
    print("delay=" .. ttp:getDelay())
end
```

---

### `LTooltipPanel:getTarget`

Returns the widget index that this tooltip is attached to.

```lua
-- signature
LTooltipPanel:getTarget()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The target widget index, or nil if unset. |

**Example**

```lua
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:setOrientation("vertical")
    local ori = tb:getOrientation()
    local tp = lurek.ui.newTooltipPanel("Hover help")
    local delay = tp:getDelay()
    local target = tp:getTarget()
    print("orientation:", ori, "delay:", delay, "target:", target)
end
```

---

### `LTooltipPanel:getText`

Returns the current tooltip display text.

```lua
-- signature
LTooltipPanel:getText()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The tooltip text. |

**Example**

```lua
do
    local ttp = lurek.ui.newTooltipPanel("Hover info")
    print("type=" .. ttp:type())
    print("text=" .. ttp:getText())
    ttp:setText("Updated tooltip")
    print("text_after=" .. ttp:getText())
    ttp:setDelay(0.5)
    print("delay=" .. ttp:getDelay())
end
```

---

### `LTooltipPanel:setDelay`

Sets the delay in seconds before this tooltip appears.

```lua
-- signature
LTooltipPanel:setDelay(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | The delay in seconds. |

**Example**

```lua
do
    local ttp = lurek.ui.newTooltipPanel("Hover info")
    print("type=" .. ttp:type())
    print("text=" .. ttp:getText())
    ttp:setText("Updated tooltip")
    print("text_after=" .. ttp:getText())
    ttp:setDelay(0.5)
    print("delay=" .. ttp:getDelay())
end
```

---

### `LTooltipPanel:setTarget`

Sets the widget index that this tooltip is attached to.

```lua
-- signature
LTooltipPanel:setTarget(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target?` | `number` | The target widget index, or nil to detach. |

**Example**

```lua
do
    local tp = lurek.ui.newTooltipPanel("initial tip")
    local txt = tp:getText()
    tp:setDelay(0.5)
    local d = tp:getDelay()
    local btn = lurek.ui.newButton("hover me")
    tp:setTarget(btn:getId() and 1 or 1)
    print("text:", txt, "delay:", d)
end
```

---

### `LTooltipPanel:setText`

Sets the tooltip panel display text content.

```lua
-- signature
LTooltipPanel:setText(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | The tooltip text. |

**Example**

```lua
do
    local ttp = lurek.ui.newTooltipPanel("Hover info")
    print("type=" .. ttp:type())
    print("text=" .. ttp:getText())
    ttp:setText("Updated tooltip")
    print("text_after=" .. ttp:getText())
    ttp:setDelay(0.5)
    print("delay=" .. ttp:getDelay())
end
```

---

## LTreeView

### `LTreeView:addNode`

Adds a new node to this tree view, optionally under a parent node.

```lua
-- signature
LTreeView:addNode(text, parent_index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | The node label text. |
| `parent_index?` | `number` | The 1-based parent node index, or nil for a root node. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The 1-based index of the newly added node. |

**Example**

```lua
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child = tv:addNode("Child C", root)
    print("child added = " .. tostring(child ~= nil))
end
```

---

### `LTreeView:clearNodes`

Removes all nodes from this tree view.

```lua
-- signature
LTreeView:clearNodes()
```

**Example**

```lua
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    tv:clearNodes()
    print("nodes = " .. tv:getNodeCount())
end
```

---

### `LTreeView:collapseAll`

Collapses all nodes in this tree view.

```lua
-- signature
LTreeView:collapseAll()
```

**Example**

```lua
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    tv:expandAll()
    tv:collapseAll()
    print("root expanded = " .. tostring(tv:isExpanded(root)))
end
```

---

### `LTreeView:collapseNode`

Collapses the node at the given 1-based index to hide its children.

```lua
-- signature
LTreeView:collapseNode(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | The 1-based node index. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the node was collapsed. |

**Example**

```lua
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:expandNode(root)
    tv:collapseNode(root)
    print("root expanded = " .. tostring(tv:isNodeExpanded(root)))
end
```

---

### `LTreeView:expandAll`

Expands all nodes in this tree view.

```lua
-- signature
LTreeView:expandAll()
```

**Example**

```lua
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    tv:expandAll()
    print("root expanded = " .. tostring(tv:isExpanded(root)))
end
```

---

### `LTreeView:expandNode`

Expands the node at the given 1-based index to show its children.

```lua
-- signature
LTreeView:expandNode(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | The 1-based node index. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the node was expanded. |

**Example**

```lua
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:expandNode(root)
    print("root expanded = " .. tostring(tv:isNodeExpanded(root)))
end
```

---

### `LTreeView:getChildNodes`

Returns a table of 1-based child node indices for the node at the given index.

```lua
-- signature
LTreeView:getChildNodes(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | The 1-based parent node index. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | 1-based child indices. |

**Example**

```lua
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    tv:addNode("Child B", root)
    local children = tv:getChildNodes(root)
    print("child count = " .. #children)
end
```

---

### `LTreeView:getNodeCount`

Returns the total number of nodes in this tree view.

```lua
-- signature
LTreeView:getNodeCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The node count. |

**Example**

```lua
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    print("nodes = " .. tv:getNodeCount())
end
```

---

### `LTreeView:getNodeDepth`

Returns the nesting depth of the node at the given index (0 for root nodes).

```lua
-- signature
LTreeView:getNodeDepth(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | The 1-based node index. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The depth, or nil if index is invalid. |

**Example**

```lua
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    print("depth = " .. tv:getNodeDepth(child1))
end
```

---

### `LTreeView:getNodeText`

Returns the text of the node at the given 1-based index.

```lua
-- signature
LTreeView:getNodeText(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | The 1-based node index. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | The node text, or nil if the index is invalid. |

**Example**

```lua
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    print("text = " .. tv:getNodeText(child1))
end
```

---

### `LTreeView:getParentNode`

Returns the 1-based index of the parent of the node at the given index.

```lua
-- signature
LTreeView:getParentNode(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | The 1-based node index. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The parent node index, or nil for root nodes. |

**Example**

```lua
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    print("parent = " .. tostring(tv:getParentNode(child1) == root))
end
```

---

### `LTreeView:getSelectedNode`

Returns the 1-based index of the currently selected node.

```lua
-- signature
LTreeView:getSelectedNode()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The selected node index, or nil if none. |

**Example**

```lua
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    tv:setSelectedNode(child1)
    print("selected = " .. tostring(tv:getSelectedNode()))
end
```

---

### `LTreeView:isExpanded`

Returns whether the node at the given 1-based index is currently expanded.

```lua
-- signature
LTreeView:isExpanded(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | The 1-based node index. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if expanded. |

**Example**

```lua
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:expandAll()
    print("expanded = " .. tostring(tv:isExpanded(root)))
end
```

---

### `LTreeView:isNodeExpanded`

Returns whether the node at the given 1-based index is expanded. Returns nil if the index is invalid.

```lua
-- signature
LTreeView:isNodeExpanded(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | The 1-based node index. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if expanded, false if collapsed, nil if invalid. |

**Example**

```lua
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:expandNode(root)
    print("node expanded = " .. tostring(tv:isNodeExpanded(root)))
end
```

---

### `LTreeView:removeNode`

Removes the node at the given 1-based index from this tree view.

```lua
-- signature
LTreeView:removeNode(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | The 1-based node index. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the node was removed. |

**Example**

```lua
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    local child2 = tv:addNode("Child B", root)
    tv:removeNode(child2)
    print("nodes = " .. tv:getNodeCount())
end
```

---

### `LTreeView:setNodeIcon`

Sets the icon of the node at the given 1-based index.

```lua
-- signature
LTreeView:setNodeIcon(index, icon)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | The 1-based node index. |
| `icon` | `string` | The icon identifier string. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the icon was set. |

**Example**

```lua
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    tv:setNodeIcon(child1, "folder")
    print("icon set on child")
end
```

---

### `LTreeView:setNodeText`

Sets the text of the node at the given 1-based index.

```lua
-- signature
LTreeView:setNodeText(index, text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | The 1-based node index. |
| `text` | `string` | The new node text. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the node text was set. |

**Example**

```lua
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    tv:setNodeText(child1, "Renamed A")
    print("text = " .. tv:getNodeText(child1))
end
```

---

### `LTreeView:setSelectedNode`

Sets the selected node by 1-based index.

```lua
-- signature
LTreeView:setSelectedNode(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | The 1-based node index. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the node was selected. |

**Example**

```lua
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    tv:setSelectedNode(child1)
    print("selected = " .. tostring(tv:getSelectedNode()))
end
```

---

### `LTreeView:toggleNode`

Toggles the expanded/collapsed state of the node at the given 1-based index.

```lua
-- signature
LTreeView:toggleNode(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | The 1-based node index. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the node is now expanded, false if collapsed. |

**Example**

```lua
do
    local tv = lurek.ui.newTreeView()
    local root = tv:addNode("Root", nil)
    tv:addNode("Child A", root)
    local child2 = tv:addNode("Child B", root)
    tv:toggleNode(child2)
    print("child toggled")
end
```

---

## LUiWidget

### `LUiWidget:addChild`

Adds a child widget to this widget's hierarchy.

```lua
-- signature
LUiWidget:addChild(child)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `child` | `LUiWidget|number` | The child widget table or widget index to add. |

**Example**

```lua
do
    local layout = lurek.ui.newLayout("vertical")
    local btn1 = lurek.ui.newButton("First")
    local btn2 = lurek.ui.newButton("Second")
    local btn3 = lurek.ui.newButton("Third")
    layout:addChild(btn1)
    layout:addChild(btn2)
    layout:addChild(btn3)
    print("children = " .. layout:getChildCount())
    layout:removeChild(btn2)
    print("after remove = " .. layout:getChildCount())
end
```

---

### `LUiWidget:animateAlpha`

Smoothly animates this widget's opacity toward a target value over the given duration.

```lua
-- signature
LUiWidget:animateAlpha(target, duration, hide_on_complete)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | `number` | Target alpha value (0.0 to 1.0). |
| `duration?` | `number` | Animation duration in seconds. Defaults to 0.2. |
| `hide_on_complete?` | `boolean` | If true, hides the widget when alpha reaches 0. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Table result returned by this call. |

**Example**

```lua
do
    local btn = lurek.ui.newButton("Fade")
    btn:setAlpha(1.0)
    btn:animateAlpha(0.0, 0.5)
    print("animating = " .. tostring(btn:isAnimating()))
    btn:cancelAnimations()
    btn:animateAlpha(0.0, 0.3, true)
    print("fade-out with hide_on_complete started")
end
```

---

### `LUiWidget:animatePosition`

Smoothly animates this widget's position toward the target coordinates.

```lua
-- signature
LUiWidget:animatePosition(x, y, duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Target x position. |
| `y` | `number` | Target y position. |
| `duration?` | `number` | Animation duration in seconds. Defaults to 0.2. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Table result returned by this call. |

**Example**

```lua
do
    local panel = lurek.ui.newPanel()
    panel:setPosition(0, 0)
    panel:animatePosition(200, 100, 0.5)
    print("animating = " .. tostring(panel:isAnimating()))
    print("target = 200, 100")
end
```

---

### `LUiWidget:attachToEntity`

Attaches this widget to a game entity so it follows the entity's position on screen.

```lua
-- signature
LUiWidget:attachToEntity(entity_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `entity_id` | `number` | The entity ID to attach to. |

**Example**

```lua
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
```

---

### `LUiWidget:bind`

Binds this widget to a data key for use with update_bindings.

```lua
-- signature
LUiWidget:bind(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `string` | The binding key name. |

**Example**

```lua
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
```

---

### `LUiWidget:cancelAnimations`

Cancels all active animations on this widget, leaving it at its current state.

```lua
-- signature
LUiWidget:cancelAnimations()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if any animations were cancelled. |

**Example**

```lua
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
```

---

### `LUiWidget:clearAnchor`

Removes all anchor constraints from this widget.

```lua
-- signature
LUiWidget:clearAnchor()
```

**Example**

```lua
do
    local btn = lurek.ui.newButton("Anchored")
    btn:setAnchor(10, 10, 10, nil)
    print("anchors applied")
    btn:clearAnchor()
    btn:setAnchorCenter(0.5, 0.5)
    print("center anchor applied")
end
```

---

### `LUiWidget:clearFont`

Clears any font override on this widget so it inherits from its parent again.

```lua
-- signature
LUiWidget:clearFont()
```

**Example**

```lua
do
    -- Example for clearFont
    local widget = lurek.ui.newButton("Test Widget")
    widget:setText("Using clearFont")
    local w, h = widget:getSize()
    lurek.log.info("Invoked clearFont on widget size " .. w .. "x" .. h)
    if w > 0 then widget:setVisible(true) end
end
```

---

### `LUiWidget:containsPoint`

Tests whether the given screen-space point is inside this widget's bounds.

```lua
-- signature
LUiWidget:containsPoint(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate in screen pixels. |
| `y` | `number` | Y coordinate in screen pixels. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the point is within the widget. |

**Example**

```lua
do
    local btn = lurek.ui.newButton("Hit Test")
    btn:setPosition(50, 50)
    btn:setSize(100, 40)
    print("(75,60) inside = " .. tostring(btn:containsPoint(75, 60)))
    print("(200,200) inside = " .. tostring(btn:containsPoint(200, 200)))
end
```

---

### `LUiWidget:detachFromEntity`

Detaches this widget from any previously attached entity.

```lua
-- signature
LUiWidget:detachFromEntity()
```

**Example**

```lua
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
```

---

### `LUiWidget:fadeIn`

Instantly makes this widget fully opaque and visible.

```lua
-- signature
LUiWidget:fadeIn()
```

**Example**

```lua
do
    ---@type LLabel
    local lbl = lurek.ui.newLabel("Fading")
    lbl:setAlpha(0)
    lbl:fadeIn()
    print("fading in, animating = " .. tostring(lbl:isAnimating()))
end
```

---

### `LUiWidget:fadeOut`

Instantly makes this widget fully transparent and hidden.

```lua
-- signature
LUiWidget:fadeOut()
```

**Example**

```lua
do
    ---@type LLabel
    local lbl = lurek.ui.newLabel("Fading")
    lbl:fadeOut()
    print("fading out")
end
```

---

### `LUiWidget:findById`

Searches this widget's subtree for a child with the given ID.

```lua
-- signature
LUiWidget:findById(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `string` | The widget ID to search for. |

**Returns**

| Type | Description |
|------|-------------|
| `LWidget` | The found widget table, or nil if not found. |

**Example**

```lua
do
    local root = lurek.ui.newLayout("vertical")
    local btn = lurek.ui.newButton("Find Me")
    btn:setId("target_btn")
    root:addChild(btn)
    local found = root:findById("target_btn")
    print("found = " .. tostring(found ~= nil))
end
```

---

### `LUiWidget:getAlpha`

Returns the current opacity of this widget.

```lua
-- signature
LUiWidget:getAlpha()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The alpha value between 0.0 and 1.0. |

**Example**

```lua
do
    local panel = lurek.ui.newPanel()
    print("alpha = " .. panel:getAlpha())
    panel:setAlpha(0.5)
    print("set to 50% = " .. panel:getAlpha())
    panel:setAlpha(1.0)
end
```

---

### `LUiWidget:getChildCount`

Returns the number of direct child widgets attached to this widget.

```lua
-- signature
LUiWidget:getChildCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The child count. |

**Example**

```lua
do
    local layout = lurek.ui.newLayout("vertical")
    local btn1 = lurek.ui.newButton("First")
    local btn2 = lurek.ui.newButton("Second")
    local btn3 = lurek.ui.newButton("Third")
    layout:addChild(btn1)
    layout:addChild(btn2)
    layout:addChild(btn3)
    print("children = " .. layout:getChildCount())
    layout:removeChild(btn2)
    print("after remove = " .. layout:getChildCount())
end
```

---

### `LUiWidget:getChildren`

Returns a table of lightweight child widget references, each containing an _idx field.

```lua
-- signature
LUiWidget:getChildren()
```

**Returns**

| Type | Description |
|------|-------------|
| `LUiWidgetGetChildrenResult` | Array of child widget tables. |

**Example**

```lua
do
    local panel = lurek.ui.newPanel()
    panel:addChild(lurek.ui.newLabel("A"))
    panel:addChild(lurek.ui.newLabel("B"))
    panel:addChild(lurek.ui.newLabel("C"))
    local children = panel:getChildren()
    print("child list length = " .. #children)
end
```

---

### `LUiWidget:getFlexGrow`

Returns the flex-grow factor of this widget.

```lua
-- signature
LUiWidget:getFlexGrow()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The grow factor. |

**Example**

```lua
do
    local row = lurek.ui.newLayout("horizontal")
    local left = lurek.ui.newPanel()
    local right = lurek.ui.newPanel()
    left:setFlexGrow(1)
    right:setFlexGrow(2)
    row:addChild(left)
    row:addChild(right)
    print("left grow = " .. left:getFlexGrow())
    print("right grow = " .. right:getFlexGrow())
end
```

---

### `LUiWidget:getFlexShrink`

Returns the flex-shrink factor of this widget.

```lua
-- signature
LUiWidget:getFlexShrink()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The shrink factor. |

**Example**

```lua
do
    local btn = lurek.ui.newButton("Shrinkable")
    btn:setFlexShrink(0)
    print("shrink = " .. btn:getFlexShrink())
    btn:setFlexShrink(1)
    print("shrink = " .. btn:getFlexShrink())
end
```

---

### `LUiWidget:getId`

Returns the string identifier assigned to this widget.

```lua
-- signature
LUiWidget:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The widget ID, or an empty string if none was set. |

**Example**

```lua
do
    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    print("id = " .. btn:getId())
    print("tooltip = " .. btn:getTooltip())
end
```

---

### `LUiWidget:getMargin`

Returns the outer margin of this widget.

```lua
-- signature
LUiWidget:getMargin()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Top, right, bottom, and left margin in pixels. |
| `number` | b Top, right, bottom, and left margin in pixels. |
| `number` | c Top, right, bottom, and left margin in pixels. |
| `number` | d Top, right, bottom, and left margin in pixels. |

**Example**

```lua
do
    local btn = lurek.ui.newButton("Margin")
    btn:setMargin(10, 20, 10, 20)
    local top, right, bottom, left = btn:getMargin()
    print("margin = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
    btn:setMargin(5)
    top, right, bottom, left = btn:getMargin()
    print("uniform = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
end
```

---

### `LUiWidget:getMaxSize`

Returns the maximum width and height of this widget.

```lua
-- signature
LUiWidget:getMaxSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Maximum width and height in pixels. |
| `number` | b Maximum width and height in pixels. |

**Example**

```lua
do
    local panel = lurek.ui.newPanel()
    panel:setMinSize(100, 50)
    local minW, minH = panel:getMinSize()
    print("min = " .. minW .. "x" .. minH)
    panel:setMaxSize(400, 300)
    local maxW, maxH = panel:getMaxSize()
    print("max = " .. maxW .. "x" .. maxH)
end
```

---

### `LUiWidget:getMinSize`

Returns the minimum width and height of this widget.

```lua
-- signature
LUiWidget:getMinSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Minimum width and height in pixels. |
| `number` | b Minimum width and height in pixels. |

**Example**

```lua
do
    local panel = lurek.ui.newPanel()
    panel:setMinSize(100, 50)
    local minW, minH = panel:getMinSize()
    print("min = " .. minW .. "x" .. minH)
    panel:setMaxSize(400, 300)
    local maxW, maxH = panel:getMaxSize()
    print("max = " .. maxW .. "x" .. maxH)
end
```

---

### `LUiWidget:getMouseFilter`

Returns the mouse filter of this widget.

```lua
-- signature
LUiWidget:getMouseFilter()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The mouse filter type. |

**Example**

```lua
do
    -- Retrieves the current mouse filter behavior of a widget.
    local panel = lurek.ui.newPanel()
    panel:setMouseFilter("pass")
    local filter = panel:getMouseFilter()
    print("mouse filter: " .. filter)
end
```

---

### `LUiWidget:getPadding`

Returns the inner padding of this widget.

```lua
-- signature
LUiWidget:getPadding()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Top, right, bottom, and left padding in pixels. |
| `number` | b Top, right, bottom, and left padding in pixels. |
| `number` | c Top, right, bottom, and left padding in pixels. |
| `number` | d Top, right, bottom, and left padding in pixels. |

**Example**

```lua
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setPadding(8, 16, 8, 16)
    local top, right, bottom, left = panel:getPadding()
    print("padding = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
end
```

---

### `LUiWidget:getPosition`

Returns the local position of this widget relative to its parent.

```lua
-- signature
LUiWidget:getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a The x and y coordinates in pixels. |
| `number` | b The x and y coordinates in pixels. |

**Example**

```lua
do
    ---@type LButton
    local btn = lurek.ui.newButton("Pos Test")
    btn:setPosition(100, 50)
    local x, y = btn:getPosition()
    print("position = " .. x .. ", " .. y)
end
```

---

### `LUiWidget:getRect`

Returns the computed bounding rectangle of this widget in screen coordinates after layout.

```lua
-- signature
LUiWidget:getRect()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a The x, y, width, and height of the computed rect. |
| `number` | b The x, y, width, and height of the computed rect. |
| `number` | c The x, y, width, and height of the computed rect. |
| `number` | d The x, y, width, and height of the computed rect. |

**Example**

```lua
do
    local btn = lurek.ui.newButton("Bounds")
    btn:setPosition(50, 30)
    btn:setSize(120, 40)
    local x, y, w, h = btn:getRect()
    print("rect = " .. x .. "," .. y .. " " .. w .. "x" .. h)
end
```

---

### `LUiWidget:getSize`

Returns the width and height of this widget.

```lua
-- signature
LUiWidget:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a The width and height in pixels. |
| `number` | b The width and height in pixels. |

**Example**

```lua
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setSize(300, 200)
    local w, h = panel:getSize()
    print("size = " .. w .. "x" .. h)
end
```

---

### `LUiWidget:getState`

Returns the current interaction state of this widget (e.g. "normal", "hovered", "pressed", "disabled").

```lua
-- signature
LUiWidget:getState()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The widget state name. |

**Example**

```lua
do
    ---@type LButton
    local btn = lurek.ui.newButton("State")
    local state = btn:getState()
    print("state = " .. state)
end
```

---

### `LUiWidget:getStyleClass`

Returns the style class of this widget.

```lua
-- signature
LUiWidget:getStyleClass()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The style class name, or an empty string if none is set. |

**Example**

```lua
do
    -- Retrieves the currently assigned style class of a widget, or an empty string if none.
    local btn = lurek.ui.newButton("Cancel")
    btn:setStyleClass("danger")
    local class = btn:getStyleClass()
    print("style class: " .. class)
end
```

---

### `LUiWidget:getTooltip`

Returns the tooltip text of this widget.

```lua
-- signature
LUiWidget:getTooltip()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The tooltip text, or an empty string if none is set. |

**Example**

```lua
do
    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    print("id = " .. btn:getId())
    print("tooltip = " .. btn:getTooltip())
end
```

---

### `LUiWidget:getZOrder`

Returns the z-order (draw priority) of this widget.

```lua
-- signature
LUiWidget:getZOrder()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The z-order value. |

**Example**

```lua
do
    local front = lurek.ui.newPanel()
    local back = lurek.ui.newPanel()
    front:setZOrder(10)
    back:setZOrder(1)
    print("front z = " .. front:getZOrder())
    print("back z = " .. back:getZOrder())
end
```

---

### `LUiWidget:isAnimating`

Returns whether this widget currently has an active animation.

```lua
-- signature
LUiWidget:isAnimating()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if an animation is in progress. |

**Example**

```lua
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setZOrder(5)
    local z = w:getZOrder()
    local animating = w:isAnimating()
    local enabled = w:isEnabled()
    w:setEnabled(false)
    print("zOrder:", z, "isAnimating:", animating, "isEnabled:", enabled)
end
```

---

### `LUiWidget:isEnabled`

Returns whether this widget is currently enabled and can receive input.

```lua
-- signature
LUiWidget:isEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the widget is enabled. |

**Example**

```lua
do
    ---@type LButton
    local btn = lurek.ui.newButton("Action")
    print("enabled = " .. tostring(btn:isEnabled()))
    btn:setEnabled(false)
    print("disabled = " .. tostring(btn:isEnabled()))
end
```

---

### `LUiWidget:isVisible`

Returns whether this widget is currently visible.

```lua
-- signature
LUiWidget:isVisible()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the widget is visible. |

**Example**

```lua
do
    ---@type LLabel
    local lbl = lurek.ui.newLabel("Toggle Me")
    print("visible = " .. tostring(lbl:isVisible()))
    lbl:setVisible(false)
    print("hidden = " .. tostring(lbl:isVisible()))
end
```

---

### `LUiWidget:removeChild`

Removes a child widget from this widget's hierarchy.

```lua
-- signature
LUiWidget:removeChild(child)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `child` | `LUiWidget|number` | The child widget table or widget index to remove. |

**Example**

```lua
do
    local layout = lurek.ui.newLayout("vertical")
    local btn1 = lurek.ui.newButton("First")
    local btn2 = lurek.ui.newButton("Second")
    local btn3 = lurek.ui.newButton("Third")
    layout:addChild(btn1)
    layout:addChild(btn2)
    layout:addChild(btn3)
    print("children = " .. layout:getChildCount())
    layout:removeChild(btn2)
    print("after remove = " .. layout:getChildCount())
end
```

---

### `LUiWidget:setAlpha`

Sets the opacity of this widget, clamped to 0.0 (fully transparent) through 1.0 (fully opaque).

```lua
-- signature
LUiWidget:setAlpha(alpha)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `alpha` | `number` | The opacity value. |

**Example**

```lua
do
    local panel = lurek.ui.newPanel()
    print("alpha = " .. panel:getAlpha())
    panel:setAlpha(0.5)
    print("set to 50% = " .. panel:getAlpha())
    panel:setAlpha(1.0)
end
```

---

### `LUiWidget:setAnchor`

Anchors this widget to its parent's edges. Pass nil for any side to leave it unanchored.

```lua
-- signature
LUiWidget:setAnchor(left, top, right, bottom)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `left?` | `number` | Distance from parent's left edge, or nil. |
| `top?` | `number` | Distance from parent's top edge, or nil. |
| `right?` | `number` | Distance from parent's right edge, or nil. |
| `bottom?` | `number` | Distance from parent's bottom edge, or nil. |

**Example**

```lua
do
    local btn = lurek.ui.newButton("Anchored")
    btn:setAnchor(10, 10, 10, nil)
    print("anchors applied")
    btn:clearAnchor()
    btn:setAnchorCenter(0.5, 0.5)
    print("center anchor applied")
end
```

---

### `LUiWidget:setAnchorCenter`

Centers this widget within its parent using proportional anchor offsets (0.0 to 1.0).

```lua
-- signature
LUiWidget:setAnchorCenter(cx, cy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx?` | `number` | Horizontal center fraction (0.5 = centered). |
| `cy?` | `number` | Vertical center fraction (0.5 = centered). |

**Example**

```lua
do
    local btn = lurek.ui.newButton("Anchored")
    btn:setAnchor(10, 10, 10, nil)
    print("anchors applied")
    btn:clearAnchor()
    btn:setAnchorCenter(0.5, 0.5)
    print("center anchor applied")
end
```

---

### `LUiWidget:setAriaName`

Sets the accessible name metadata for this widget.

```lua
-- signature
LUiWidget:setAriaName(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Accessible name value. |

**Example**

```lua
do
    local btn = lurek.ui.newButton("Save")
    btn:setAriaName("Save game")
end
```

---

### `LUiWidget:setBindKey`

Binds this widget to a data key and reports whether the widget exists.

```lua
-- signature
LUiWidget:setBindKey(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `string` | The binding key name. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the widget exists and the binding key was set. |

**Example**

```lua
do
    -- Example for setBindKey
    local widget = lurek.ui.newButton("Test Widget")
    widget:setText("Using setBindKey")
    local w, h = widget:getSize()
    lurek.log.info("Invoked setBindKey on widget size " .. w .. "x" .. h)
    if w > 0 then widget:setVisible(true) end
end
```

---

### `LUiWidget:setEnabled`

Enables or disables this widget. Disabled widgets appear grayed out and ignore input.

```lua
-- signature
LUiWidget:setEnabled(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `boolean` | True to enable, false to disable. |

**Example**

```lua
do
    ---@type LButton
    local btn = lurek.ui.newButton("Action")
    btn:setEnabled(false)
    print("disabled = " .. tostring(btn:isEnabled()))
end
```

---

### `LUiWidget:setFlexGrow`

Sets the flex-grow factor controlling how much extra space this widget receives in a layout.

```lua
-- signature
LUiWidget:setFlexGrow(grow)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `grow` | `number` | The grow factor (0 = no growth). |

**Example**

```lua
do
    local row = lurek.ui.newLayout("horizontal")
    local left = lurek.ui.newPanel()
    local right = lurek.ui.newPanel()
    left:setFlexGrow(1)
    right:setFlexGrow(2)
    row:addChild(left)
    row:addChild(right)
    print("left grow = " .. left:getFlexGrow())
    print("right grow = " .. right:getFlexGrow())
end
```

---

### `LUiWidget:setFlexShrink`

Sets the flex-shrink factor controlling how much this widget shrinks when layout space is insufficient.

```lua
-- signature
LUiWidget:setFlexShrink(shrink)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shrink` | `number` | The shrink factor (0 = no shrinkage). |

**Example**

```lua
do
    local btn = lurek.ui.newButton("Shrinkable")
    btn:setFlexShrink(0)
    print("shrink = " .. btn:getFlexShrink())
    btn:setFlexShrink(1)
    print("shrink = " .. btn:getFlexShrink())
end
```

---

### `LUiWidget:setFocusGroup`

Sets the focus traversal group for this widget.

```lua
-- signature
LUiWidget:setFocusGroup(group)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group` | `string` | Focus group name; empty string means the default/global group. |

**Example**

```lua
do
    local btn = lurek.ui.newButton("Group")
    btn:setFocusGroup("menu")
end
```

---

### `LUiWidget:setFocusNeighbor`

Sets an explicit directional focus neighbor for this widget.

```lua
-- signature
LUiWidget:setFocusNeighbor(direction, target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `direction` | `string` | Neighbor direction: "up", "down", "left", or "right". |
| `target?` | `number` | Target widget index, or nil to clear the neighbor. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when direction is valid; false otherwise. |

**Example**

```lua
do
    local a = lurek.ui.newButton("A")
    local b = lurek.ui.newButton("B")
    a:setFocusNeighbor("right", b._idx)
end
```

---

### `LUiWidget:setFocusable`

Sets whether this widget participates in keyboard focus traversal.

```lua
-- signature
LUiWidget:setFocusable(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `boolean` | True to allow focus traversal; false to skip this widget. |

**Example**

```lua
do
    local btn = lurek.ui.newButton("Focusable")
    btn:setFocusable(true)
end
```

---

### `LUiWidget:setFont`

Assigns a specific font to this widget and its descendants unless overridden further down the tree.

```lua
-- signature
LUiWidget:setFont(font)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | `LFont` | Font handle to use for this widget subtree. |

**Example**

```lua
do
    -- Example for setFont
    local widget = lurek.ui.newButton("Test Widget")
    widget:setText("Using setFont")
    local w, h = widget:getSize()
    lurek.log.info("Invoked setFont on widget size " .. w .. "x" .. h)
    if w > 0 then widget:setVisible(true) end
end
```

---

### `LUiWidget:setId`

Assigns a string identifier to this widget for lookup with findById.

```lua
-- signature
LUiWidget:setId(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `string` | A unique identifier string. |

**Example**

```lua
do
    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    print("id = " .. btn:getId())
    print("tooltip = " .. btn:getTooltip())
end
```

---

### `LUiWidget:setMargin`

Sets the outer margin of this widget. Accepts 1 to 4 values (top, right?, bottom?, left?) following CSS shorthand rules.

```lua
-- signature
LUiWidget:setMargin(top, right, bottom, left)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `top` | `number` | Top margin in pixels (also used as default for other sides). |
| `right?` | `number` | Right margin. Defaults to top. |
| `bottom?` | `number` | Bottom margin. Defaults to top. |
| `left?` | `number` | Left margin. Defaults to right. |

**Example**

```lua
do
    local btn = lurek.ui.newButton("Margin")
    btn:setMargin(10, 20, 10, 20)
    local top, right, bottom, left = btn:getMargin()
    print("margin = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
    btn:setMargin(5)
    top, right, bottom, left = btn:getMargin()
    print("uniform = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
end
```

---

### `LUiWidget:setMaxSize`

Sets the maximum allowed width and height for this widget during layout.

```lua
-- signature
LUiWidget:setMaxSize(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Maximum width in pixels. |
| `h` | `number` | Maximum height in pixels. |

**Example**

```lua
do
    local panel = lurek.ui.newPanel()
    panel:setMinSize(100, 50)
    local minW, minH = panel:getMinSize()
    print("min = " .. minW .. "x" .. minH)
    panel:setMaxSize(400, 300)
    local maxW, maxH = panel:getMaxSize()
    print("max = " .. maxW .. "x" .. maxH)
end
```

---

### `LUiWidget:setMinSize`

Sets the minimum allowed width and height for this widget during layout.

```lua
-- signature
LUiWidget:setMinSize(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Minimum width in pixels. |
| `h` | `number` | Minimum height in pixels. |

**Example**

```lua
do
    local panel = lurek.ui.newPanel()
    panel:setMinSize(100, 50)
    local minW, minH = panel:getMinSize()
    print("min = " .. minW .. "x" .. minH)
    panel:setMaxSize(400, 300)
    local maxW, maxH = panel:getMaxSize()
    print("max = " .. maxW .. "x" .. maxH)
end
```

---

### `LUiWidget:setMouseFilter`

Sets the mouse filter for this widget ("stop", "pass", "ignore").

```lua
-- signature
LUiWidget:setMouseFilter(filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `filter` | `string` | The mouse filter type. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True for a valid filter, false when reset to "stop". |

**Example**

```lua
do
    -- Sets the mouse filter mode on a panel. "ignore" passes events to underlying widgets,
    -- useful for decorative overlays or transparent layout containers.
    local panel = lurek.ui.newPanel()
    panel:setMouseFilter("ignore")
    print("mouse filter set to ignore")
end
```

---

### `LUiWidget:setOnChange`

Registers a callback function invoked when this widget's value changes.

```lua
-- signature
LUiWidget:setOnChange(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | `function` | Callback receiving the widget index as argument. |

**Example**

```lua
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setOnChange(function() print("changed") end)
    w:setOnClick(function() print("clicked") end)
    w:setOnDraw(function() print("drawing") end)
    local id = w:getId()
    local vis = w:isVisible()
    print("setOnChange/setOnClick/setOnDraw ok; id:", id, "vis:", vis)
end
```

---

### `LUiWidget:setOnClick`

Registers a callback function invoked when this widget is clicked.

```lua
-- signature
LUiWidget:setOnClick(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | `function` | Callback receiving the widget index as argument. |

**Example**

```lua
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setOnChange(function() print("changed") end)
    w:setOnClick(function() print("clicked") end)
    w:setOnDraw(function() print("drawing") end)
    local id = w:getId()
    local vis = w:isVisible()
    print("setOnChange/setOnClick/setOnDraw ok; id:", id, "vis:", vis)
end
```

---

### `LUiWidget:setOnDraw`

Registers a custom draw callback for this widget, invoked each frame during the draw pass.

```lua
-- signature
LUiWidget:setOnDraw(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | `function` | Callback receiving a rect table {x, y, w, h} with the computed bounds. |

**Example**

```lua
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setOnChange(function() print("changed") end)
    w:setOnClick(function() print("clicked") end)
    w:setOnDraw(function() print("drawing") end)
    local id = w:getId()
    local vis = w:isVisible()
    print("setOnChange/setOnClick/setOnDraw ok; id:", id, "vis:", vis)
end
```

---

### `LUiWidget:setPadding`

Sets the inner padding of this widget. Accepts 1 to 4 values (top, right?, bottom?, left?) following CSS shorthand rules.

```lua
-- signature
LUiWidget:setPadding(top, right, bottom, left)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `top` | `number` | Top padding in pixels (also used as default for other sides). |
| `right?` | `number` | Right padding. Defaults to top. |
| `bottom?` | `number` | Bottom padding. Defaults to top. |
| `left?` | `number` | Left padding. Defaults to right. |

**Example**

```lua
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setPadding(8, 16, 8, 16)
    local top, right, bottom, left = panel:getPadding()
    print("padding = " .. top .. " " .. right .. " " .. bottom .. " " .. left)
end
```

---

### `LUiWidget:setPosition`

Sets the local position of this widget relative to its parent.

```lua
-- signature
LUiWidget:setPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Horizontal position in pixels. |
| `y` | `number` | Vertical position in pixels. |

**Example**

```lua
do
    ---@type LButton
    local btn = lurek.ui.newButton("Pos Test")
    btn:setPosition(100, 50)
    local x, y = btn:getPosition()
    print("position = " .. x .. ", " .. y)
end
```

---

### `LUiWidget:setRole`

Sets a semantic role string for this widget.

```lua
-- signature
LUiWidget:setRole(role)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `role` | `string` | Semantic role name. |

**Example**

```lua
do
    local btn = lurek.ui.newButton("Save")
    btn:setRole("button")
end
```

---

### `LUiWidget:setSize`

Sets the width and height of this widget in pixels.

```lua
-- signature
LUiWidget:setSize(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Width in pixels. |
| `h` | `number` | Height in pixels. |

**Example**

```lua
do
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setSize(300, 200)
    local w, h = panel:getSize()
    print("size = " .. w .. "x" .. h)
end
```

---

### `LUiWidget:setStyleClass`

Sets the style class of this widget.

```lua
-- signature
LUiWidget:setStyleClass(class)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `class` | `string` | The style class name. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the widget exists and the class was set. |

**Example**

```lua
do
    -- Assigns a custom style class to a widget. If defined in the active theme,
    -- the button will use "primary" colors and metrics instead of default ones.
    local btn = lurek.ui.newButton("Submit")
    btn:setStyleClass("primary")
    print("style class set to primary")
end
```

---

### `LUiWidget:setTabIndex`

Sets the tab-order index for this widget.

```lua
-- signature
LUiWidget:setTabIndex(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `number` | Tab-order index. |

**Example**

```lua
do
    local btn = lurek.ui.newButton("Tab")
    btn:setTabIndex(10)
end
```

---

### `LUiWidget:setTextEllipsis`

Enables or disables ellipsis clipping for overflowing single-line text.

```lua
-- signature
LUiWidget:setTextEllipsis(ellipsis)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ellipsis` | `boolean` | True to enable ellipsis on overflow. |

**Example**

```lua
do
    local lbl = lurek.ui.newLabel("This is a very long one-line text")
    lbl:setTextEllipsis(true)
end
```

---

### `LUiWidget:setTextVAlign`

Sets the vertical alignment of text inside this widget.

```lua
-- signature
LUiWidget:setTextVAlign(align)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `align` | `string` | Vertical alignment: "top", "middle", or "bottom". |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the alignment string is recognised; false leaves the previous value unchanged. |

**Example**

```lua
do
    local lbl = lurek.ui.newLabel("Centered")
    lbl:setTextVAlign("middle")
end
```

---

### `LUiWidget:setTextWrap`

Enables or disables word-wrap for text inside this widget.

```lua
-- signature
LUiWidget:setTextWrap(wrap)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wrap` | `boolean` | True to wrap text, false for single-line. |

**Example**

```lua
do
    local lbl = lurek.ui.newLabel("This is a long text that can wrap")
    lbl:setTextWrap(true)
end
```

---

### `LUiWidget:setTooltip`

Sets the tooltip text shown when the user hovers over this widget.

```lua
-- signature
LUiWidget:setTooltip(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | The tooltip message. |

**Example**

```lua
do
    local btn = lurek.ui.newButton("Info")
    btn:setId("info_button")
    btn:setTooltip("Click for more information")
    print("id = " .. btn:getId())
    print("tooltip = " .. btn:getTooltip())
end
```

---

### `LUiWidget:setVisible`

Shows or hides this widget. Hidden widgets are not drawn and do not receive input.

```lua
-- signature
LUiWidget:setVisible(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `boolean` | True to show, false to hide. |

**Example**

```lua
do
    ---@type LLabel
    local lbl = lurek.ui.newLabel("Toggle Me")
    lbl:setVisible(false)
    print("hidden = " .. tostring(lbl:isVisible()))
end
```

---

### `LUiWidget:setZOrder`

Sets the z-order (draw priority) of this widget. Higher values draw on top.

```lua
-- signature
LUiWidget:setZOrder(z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `z` | `number` | The z-order integer value. |

**Example**

```lua
do
    local front = lurek.ui.newPanel()
    local back = lurek.ui.newPanel()
    front:setZOrder(10)
    back:setZOrder(1)
    print("front z = " .. front:getZOrder())
    print("back z = " .. back:getZOrder())
end
```

---

### `LUiWidget:slideIn`

Moves this widget to the given position and makes it visible.

```lua
-- signature
LUiWidget:slideIn(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Target x position. |
| `y` | `number` | Target y position. |

**Example**

```lua
do
    local panel = lurek.ui.newPanel()
    panel:cancelAnimations()
    panel:slideIn(300, 0)
    local x, y = panel:getPosition()
    print("visible = " .. tostring(panel:isVisible()))
    print("position = " .. x .. ", " .. y)
end
```

---

### `LUiWidget:slideOut`

Moves this widget to the given position and hides it.

```lua
-- signature
LUiWidget:slideOut(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Target x position. |
| `y` | `number` | Target y position. |

**Example**

```lua
do
    local panel = lurek.ui.newPanel()
    panel:setVisible(true)
    panel:setPosition(40, 20)
    panel:slideOut(320, 20)
    local x, y = panel:getPosition()
    print("visible = " .. tostring(panel:isVisible()))
    print("position = " .. x .. ", " .. y)
end
```

---

### `LUiWidget:type`

Returns the type name string of this widget (e.g. "LButton", "LSlider").

```lua
-- signature
LUiWidget:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The widget type name. |

**Example**

```lua
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:slideIn(0, -50)
    w:slideOut(0, 50)
    local t = w:type()
    local ok = w:typeOf("LUiWidget")
    w:unbind()
    print("slideIn/slideOut ok; type:", t, "typeOf:", ok)
end
```

---

### `LUiWidget:typeOf`

Checks whether this widget matches the given type name, including base types "LWidget" and "Object".

```lua
-- signature
LUiWidget:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | The type name to check against. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the widget is of the given type. |

**Example**

```lua
do
    local w = lurek.ui.newCustomWidget({width=80, height=40})
    w:bind("click")
    w:unbind()
    local ok1 = w:typeOf("LUiWidget")
    local ok2 = w:typeOf("LButton")
    local t = w:type()
    print("typeOf LUiWidget:", ok1, "typeOf LButton:", ok2, "type:", t)
end
```

---

### `LUiWidget:unbind`

Removes the data binding from this widget.

```lua
-- signature
LUiWidget:unbind()
```

**Example**

```lua
do
    local w = lurek.ui.newCustomWidget({width=80, height=40})
    w:bind("click")
    w:unbind()
    local ok1 = w:typeOf("LUiWidget")
    local ok2 = w:typeOf("LButton")
    local t = w:type()
    print("typeOf LUiWidget:", ok1, "typeOf LButton:", ok2, "type:", t)
end
```

---
