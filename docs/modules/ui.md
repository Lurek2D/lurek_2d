# Ui

## Purpose

Centralized retained-mode UI context with arena storage, automatic layouts, and resolution scaling.

## When To Use

- Its core promise is continuity across frames. The UI context remembers widget identity, parent-child structure, focus, hover, active state, capture, bindings, transitions, and pending events, so a screen can evolve over time without losing the state that makes it feel interactive and stable.
- This retained model matters because large interfaces are rarely redrawn from pure stateless logic. Text inputs need cursors and selection, lists need scroll position, windows need placement, trees need expansion state, and complex panels need to survive temporary data changes without resetting user intent.
- Container widgets define the structural grammar of the module. Panels, windows, stacks, docks, split regions, scroll containers, frames, and nine-slice shells let projects assemble larger interface layouts from composable blocks rather than hand-managing every rectangle.

## Minimal Example

Example block: `lurek.ui.newButton`

```lua
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
```

## Common Patterns

- Start with `lurek.ui.addToast` when exploring this module.
- Start with `lurek.ui.animateColor` when exploring this module.
- Start with `lurek.ui.animateRotation` when exploring this module.
- Start with `lurek.ui.animateScale` when exploring this module.
- Start with `lurek.ui.beginDrag` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `ui` module is the engine's retained-interface system for users who want menus, HUDs, editors, overlays, and tool panels to behave like one persistent application layer instead of a loose pile of draw calls and ad hoc click tests.
- Its core promise is continuity across frames. The UI context remembers widget identity, parent-child structure, focus, hover, active state, capture, bindings, transitions, and pending events, so a screen can evolve over time without losing the state that makes it feel interactive and stable.
- This retained model matters because large interfaces are rarely redrawn from pure stateless logic. Text inputs need cursors and selection, lists need scroll position, windows need placement, trees need expansion state, and complex panels need to survive temporary data changes without resetting user intent.
- Container widgets define the structural grammar of the module. Panels, windows, stacks, docks, split regions, scroll containers, frames, and nine-slice shells let projects assemble larger interface layouts from composable blocks rather than hand-managing every rectangle.
- Basic controls sit on top of that structure as first-class runtime widgets. Buttons, labels, checkboxes, sliders, text boxes, radio groups, combo boxes, lists, tabs, steppers, toggles, and status displays all share the same identity, event, and style model.
- Property widgets cover editor-style inspector panels where a script or TOML layout needs a left-hand property name, a right-hand value, predefined editor semantics such as text/number/bool/select/color, and collapsible groups that can hide advanced settings without rebuilding the widget tree.
- The `extras` surface pushes the module past ordinary menus into more tool-like workflows by covering dialogs, menus, tree views, inspectors, status bars, toasts, overlays, and richer dashboard-oriented pieces that are common in internal tools and game editors.
- Declarative layout loading from TOML is one of the most important user-facing capabilities because it means interface structure can be authored as content. Teams can describe screens in data, instantiate them into live widgets, and still use the same event, style, and binding behavior as hand-written UI.
- For inspector-style tools, TOML can define property widget groups and rows directly, so configuration panels can live as content while Lua remains responsible for runtime value updates and callbacks.
- Styling is not a thin afterthought. Themes, classes, semantic colors, spacing, typography, borders, fills, corner treatment, widget states, and transition-friendly variants all live inside one coherent theme system so several screens can share a recognizable visual language.
- Layout calculation is another central responsibility. The module resolves requested size, parent constraints, alignment, padding, spacing, scrolling, overflow, clipping, stacking order, and viewport-aware placement into concrete geometry so widgets can be reasoned about structurally instead of geometrically line by line.
- Layout-manager constructors expose the common screen-structure vocabulary directly: `newVBoxContainer`, `newHBoxContainer`, `newGridContainer`, `newMarginContainer`, `newCenterContainer`, `newScrollContainer`, `newSplitContainer`, `newStackContainer`, and `newTabContainer`. These names mirror the way users think about menu columns, HUD rows, inventory grids, safe-area padding, centered dialogs, scrollable lists, resizable panes, layered views, and settings tabs.
- `Layout` remains the underlying owner for box, grid, margin, and center behavior, so spacing, padding, alignment, justification, flex grow, and child margins stay on one code path instead of fragmenting into one-off containers.
- `StackContainer` and `TabContainer` own page selection. They keep all child pages in the retained tree while the layout pass marks only the active child as effectively visible, which lets hidden pages preserve state without being drawn or hit-tested as active content.
- `SplitPanel` owns two explicit child slots and divides its content rectangle in the layout pass with a clamped split fraction and minimum panel size, making dockable editor-style panes layout-managed rather than manually positioned.
- Scroll regions, nested containers, resizable panels, and dock-like arrangements are important examples of why layout belongs here: they require persistent bookkeeping and cross-widget coordination that would become brittle if each feature implemented its own layout rules.
- Input routing is part of the same authority. Mouse, keyboard, controller-like activation, focus traversal, drag, drop, text entry, pointer capture, and event bubbling all flow through the UI context so the entire screen obeys one interaction model.
- Binding support turns UI from a decorative layer into a practical application surface. Widgets can synchronize with script-visible values, settings models, editor records, or runtime debug state without every screen inventing its own plumbing for reads, writes, and synchronization.
- That makes the module useful for options menus, save slots, inventory panels, runtime profilers, asset inspectors, conversation UIs, mission journals, or modding tools where visible controls need reliable two-way data flow.
- Transition support matters because retained UI should still feel alive. Alpha fades, motion offsets, highlight ramps, show-hide behavior, and state-based animation can advance inside the same widget runtime instead of being bolted on as unrelated per-screen tween code.
- Rendering support keeps the module viable in both normal gameplay and tooling contexts. The same resolved widget tree can be drawn into the live frame, directed to overlays, or exported through headless paths for screenshots, docs, regression tests, and proof artifacts.
- The module also serves as a coordination layer between neighboring systems. `input` contributes raw control state, `render` turns resolved draw commands into pixels, `font` and `image` provide assets, and game systems provide data, but `ui` owns how those pieces become one coherent interface runtime.
- Accessibility-like concerns such as focus order, keyboard navigation, readable state transitions, and predictable interaction semantics also belong naturally here because a retained UI system is only useful if complex screens remain operable and legible under several input styles.
- That retained model is especially valuable for editor-style surfaces, where selection, docking, inspectors, and scroll state must survive incremental content changes.
- It also gives testing and evidence workflows a stable target, because headless captures can reflect the same widget resolution and theme rules as the live runtime.
- Data-driven layouts and retained state work well together here: authored screen structure can evolve without discarding the persistent interaction model behind it.
- This is what lets the module cover both simple menus and large tool workspaces without switching to a different UI paradigm halfway through a project.
- The module is therefore not only a widget library but also a screen-architecture system. It gives projects a stable way to build interfaces that can grow from a few controls to full editors, dashboards, and data-heavy tool surfaces without changing mental models.
- For wiki readers, the practical boundary is clear: if a feature is about widget identity, composition, style, layout, focus, event dispatch, data binding, or retained state over time, it belongs to `ui` even when another system supplies the data being shown.
- Read `ui` as the engine's main authority for structured interactive surfaces. It is the module that makes screens persistent, composable, themeable, testable, and interoperable, whether the result is a simple pause menu or a full internal editor workspace.

This module primarily collaborates with `dataframe`, `image`, `math`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.ui.addToast`

Adds a toast notification to the queue.

```lua
lurek.ui.addToast(toast_table)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `toast_table` | table | Table with message (string) and optional duration (number). |

**Example**

```lua
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
```

---

### `lurek.ui.animateColor`

Animate widget color tint from one RGBA value to another.

```lua
lurek.ui.animateColor(idx, from, to, duration, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Widget index. |
| `from` | table | Starting color {r, g, b, a} (0-1 range). |
| `to` | table | Target color {r, g, b, a} (0-1 range). |
| `duration` | number | Duration in seconds. |
| `easing?` | string | Easing function name (default "linear"). |

**Returns**

| Type | Description |
|------|-------------|
| nil | Schedules the animation; no return value. |

**Example**

```lua
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
```

---

### `lurek.ui.animateRotation`

Animate widget rotation from one angle to another (in radians).

```lua
lurek.ui.animateRotation(idx, from, to, duration, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Widget index. |
| `from` | number | Starting angle in radians. |
| `to` | number | Target angle in radians. |
| `duration` | number | Duration in seconds. |
| `easing?` | string | Easing function name (default "linear"). |

**Returns**

| Type | Description |
|------|-------------|
| nil | Schedules the animation; no return value. |

**Example**

```lua
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
```

---

### `lurek.ui.animateScale`

Animate widget scale from one value to another.

```lua
lurek.ui.animateScale(idx, from_sx, from_sy, to_sx, to_sy, duration, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Widget index. |
| `from_sx` | number | Starting X scale. |
| `from_sy` | number | Starting Y scale. |
| `to_sx` | number | Target X scale. |
| `to_sy` | number | Target Y scale. |
| `duration` | number | Duration in seconds. |
| `easing?` | string | Easing function name (default "linear"). |

**Returns**

| Type | Description |
|------|-------------|
| nil | Schedules the animation; no return value. |

**Example**

```lua
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
```

---

### `lurek.ui.beginDrag`

Begins a drag operation on a widget.

```lua
lurek.ui.beginDrag(widget)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `widget` | table|number | The widget table or widget index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the drag started. |

**Example**

```lua
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
```

---

### `lurek.ui.clear`

Clears all retained UI widgets and transient UI state while keeping the active theme.

```lua
lurek.ui.clear()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of widgets removed from the retained UI tree. |

**Example**

```lua
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
```

---

### `lurek.ui.clearFocus`

Clears keyboard focus from all widgets.

```lua
lurek.ui.clearFocus()
```

**Example**

```lua
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
```

---

### `lurek.ui.clearFont`

Clears the global UI font override so the UI falls back to the active render font again.

```lua
lurek.ui.clearFont()
```

**Example**

```lua
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
```

---

### `lurek.ui.draw`

Invokes custom draw callbacks for all widgets that have one registered.

```lua
lurek.ui.draw()
```

**Example**

```lua
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
```

---

### `lurek.ui.drawToImage`

Renders the entire UI to an image buffer.

```lua
lurek.ui.drawToImage(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Image width in pixels. |
| `h` | number | Image height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | The rendered image. |

**Example**

```lua
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
```

---

### `lurek.ui.dropOn`

Drops the currently dragged widget onto a target widget.

```lua
lurek.ui.dropOn(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | table|number | The target widget table or widget index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the drop succeeded. |

**Example**

```lua
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
```

---

### `lurek.ui.endDrag`

Ends the current drag operation without dropping.

```lua
lurek.ui.endDrag()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The widget index that was being dragged, or nil if no drag was active. |

**Example**

```lua
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
```

---

### `lurek.ui.flushCache`

Flushes internal UI layout and render caches.

```lua
lurek.ui.flushCache()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the cache was flushed. |

**Example**

```lua
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
```

---

### `lurek.ui.focusDirection`

Move focus in a spatial direction. Uses geometry to find nearest focusable widget.

```lua
lurek.ui.focusDirection(dx, dy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dx` | number | Horizontal direction (-1=left, 1=right, 0=none). |
| `dy` | number | Vertical direction (-1=up, 1=down, 0=none). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | Whether focus moved. |

**Example**

```lua
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
```

---

### `lurek.ui.focusNeighbor`

Moves keyboard focus using an explicit directional focus link.

```lua
lurek.ui.focusNeighbor(direction)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `direction` | string | Direction: "up", "down", "left", or "right". |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when focus was moved to a configured neighbor. |

**Example**

```lua
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
```

---

### `lurek.ui.focusNext`

Moves keyboard focus to the next focusable widget.

```lua
lurek.ui.focusNext()
```

**Example**

```lua
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
```

---

### `lurek.ui.focusPrev`

Moves keyboard focus to the previous focusable widget.

```lua
lurek.ui.focusPrev()
```

**Example**

```lua
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
```

---

### `lurek.ui.getAccessibilityTree`

Returns a flattened accessibility snapshot for all live widgets except the root.

```lua
lurek.ui.getAccessibilityTree()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of accessibility node tables. |

**Example**

```lua
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
```

---

### `lurek.ui.getActiveDrag`

Returns the widget index currently being dragged, or nil.

```lua
lurek.ui.getActiveDrag()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The dragged widget index. |

**Example**

```lua
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
```

---

### `lurek.ui.getFocus`

Returns the index of the currently focused widget, or nil.

```lua
lurek.ui.getFocus()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The focused widget index. |

**Example**

```lua
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
```

---

### `lurek.ui.getFont`

Returns the global UI font assigned to the root widget, or nil when UI uses the render fallback font.

```lua
lurek.ui.getFont()
```

**Returns**

| Type | Description |
|------|-------------|
| [LFont](#lfont) | Current global UI font handle. |

**Example**

```lua
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
```

---

### `lurek.ui.getIconGlyph`

Returns the built-in text glyph for an icon name, or nil when missing.

```lua
lurek.ui.getIconGlyph(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Icon name to resolve. |

**Returns**

| Type | Description |
|------|-------------|
| string | nil | The text glyph used by the built-in renderer backend. |

**Example**

```lua
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
```

---

### `lurek.ui.getIconNames`

Returns all built-in UI icon names in stable catalog order.

```lua
lurek.ui.getIconNames()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Built-in icon names such as "save", "settings", and "inventory". |

**Example**

```lua
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
```

---

### `lurek.ui.getRoot`

Returns the root panel widget of the UI tree.

```lua
lurek.ui.getRoot()
```

**Returns**

| Type | Description |
|------|-------------|
| [LPanel](#lpanel) | The root panel widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.getScaleFactor`

Get the current UI scale factor (current_height / base_height).

```lua
lurek.ui.getScaleFactor()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The scale factor. |

**Example**

```lua
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
```

---

### `lurek.ui.getStyleToken`

Returns the value of a named semantic style token from the active theme.

```lua
lurek.ui.getStyleToken(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The token name (e.g. "spacing_md", "color_primary"). |

**Returns**

| Type | Description |
|------|-------------|
| number | The token value for float tokens. |

**Example**

```lua
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
```

---

### `lurek.ui.getTheme`

Returns whether a theme is currently set.

```lua
lurek.ui.getTheme()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if a theme is active. |

**Example**

```lua
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
```

---

### `lurek.ui.getToastCount`

Returns the number of active toast notifications.

```lua
lurek.ui.getToastCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The toast count. |

**Example**

```lua
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
```

---

### `lurek.ui.getWidgetCount`

Returns the total number of widgets in the UI context.

```lua
lurek.ui.getWidgetCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The widget count. |

**Example**

```lua
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
```

---

### `lurek.ui.getWidgetFont`

Returns the font override assigned to a widget, or nil when the widget inherits its font from a parent.

```lua
lurek.ui.getWidgetFont(widget)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `widget` | [LUiWidget](#luiwidget) | Widget handle to query. |

**Returns**

| Type | Description |
|------|-------------|
| [LFont](#lfont) | Font override assigned to the widget. |

**Example**

```lua
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
```

---

### `lurek.ui.hasAutoInput`

Returns whether platform input is automatically forwarded to `lurek.ui`.

```lua
lurek.ui.hasAutoInput()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when automatic UI input forwarding is enabled. |

**Example**

```lua
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
```

---

### `lurek.ui.hasAutoUpdate`

Returns whether `lurek.ui.update(dt)` is called automatically each frame.

```lua
lurek.ui.hasAutoUpdate()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when automatic UI updates are enabled. |

**Example**

```lua
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
```

---

### `lurek.ui.hasIcon`

Returns whether a built-in UI icon name exists.

```lua
lurek.ui.hasIcon(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Icon name to resolve. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the icon exists. |

**Example**

```lua
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
```

---

### `lurek.ui.keypressed`

Delivers a key press event to the UI.

```lua
lurek.ui.keypressed(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | The key name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if a widget consumed the event. |

**Example**

```lua
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
```

---

### `lurek.ui.loadLayout`

Loads a UI layout from a Lua table definition.

```lua
lurek.ui.loadLayout(def)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `def` | table | The layout definition table. |

**Returns**

| Type | Description |
|------|-------------|
| number | The root widget index. |

**Example**

```lua
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
```

---

### `lurek.ui.loadLayoutFile`

Loads a UI layout from a TOML layout file.

```lua
lurek.ui.loadLayoutFile(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Path to the TOML layout file. |

**Returns**

| Type | Description |
|------|-------------|
| number | The root widget index. |

**Example**

```lua
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
```

---

### `lurek.ui.loadLayoutGameFile`

Loads a UI layout from a TOML file resolved through GameFS.

```lua
lurek.ui.loadLayoutGameFile(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to the TOML layout file. |

**Returns**

| Type | Description |
|------|-------------|
| number | The root widget index. |

**Example**

```lua
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
```

---

### `lurek.ui.mousemoved`

Delivers a mouse move event to the UI.

```lua
lurek.ui.mousemoved(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Mouse X position. |
| `y` | number | Mouse Y position. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if a widget consumed the event. |

**Example**

```lua
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
```

---

### `lurek.ui.mousepressed`

Delivers a mouse press event to the UI.

```lua
lurek.ui.mousepressed(x, y, btn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Mouse X position. |
| `y` | number | Mouse Y position. |
| `btn?` | number | Mouse button index (default 1). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if a widget consumed the event. |

**Example**

```lua
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
```

---

### `lurek.ui.mousereleased`

Delivers a mouse release event to the UI.

```lua
lurek.ui.mousereleased(x, y, btn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Mouse X position. |
| `y` | number | Mouse Y position. |
| `btn?` | number | Mouse button index (default 1). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if a widget consumed the event. |

**Example**

```lua
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
```

---

### `lurek.ui.newAccordion`

Creates a new accordion widget with collapsible sections.

```lua
lurek.ui.newAccordion()
```

**Returns**

| Type | Description |
|------|-------------|
| [LAccordion](#laccordion) | The new accordion widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newBadge`

Creates a new badge widget for displaying counts.

```lua
lurek.ui.newBadge(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count?` | number | Initial count (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| [LBadge](#lbadge) | The new badge widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newButton`

Creates a new button widget with optional label text.

```lua
lurek.ui.newButton(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text?` | string | The button label text. |

**Returns**

| Type | Description |
|------|-------------|
| [LButton](#lbutton) | The new button widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newCenterContainer`

Creates a container that centers its child along both axes.

```lua
lurek.ui.newCenterContainer()
```

**Returns**

| Type | Description |
|------|-------------|
| [LLayout](#llayout) | The new centered layout widget table. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local modal_host = lurek.ui.newCenterContainer()
    modal_host:addChild(lurek.ui.newPanel())
    example_print_log("center align = " .. modal_host:getAlign())
    example_print_log("center justify = " .. modal_host:getJustify())
end
```

---

### `lurek.ui.newCheckbox`

Creates a new checkbox widget with optional label.

```lua
lurek.ui.newCheckbox(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text?` | string | The checkbox label text. |

**Returns**

| Type | Description |
|------|-------------|
| [LCheckbox](#lcheckbox) | The new checkbox widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newColorPicker`

Creates a new color picker widget for color selection.

```lua
lurek.ui.newColorPicker()
```

**Returns**

| Type | Description |
|------|-------------|
| [LColorPicker](#lcolorpicker) | The new color picker widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newComboBox`

Creates a new combo box (drop-down) widget.

```lua
lurek.ui.newComboBox()
```

**Returns**

| Type | Description |
|------|-------------|
| [LComboBox](#lcombobox) | The new combo box widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newCustomWidget`

Creates a new custom widget with optional initial configuration.

```lua
lurek.ui.newCustomWidget(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | table | Optional table with x, y, width, height, id, visible, enabled fields. |

**Returns**

| Type | Description |
|------|-------------|
| [LUiWidget](#luiwidget) | The new custom widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newDialog`

Creates a new dialog widget with an optional title.

```lua
lurek.ui.newDialog(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title?` | string | The dialog title. |

**Returns**

| Type | Description |
|------|-------------|
| [LDialog](#ldialog) | The new dialog widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newDockPanel`

Creates a new dock panel widget for docking child widgets to sides.

```lua
lurek.ui.newDockPanel()
```

**Returns**

| Type | Description |
|------|-------------|
| [LDockPanel](#ldockpanel) | The new dock panel widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newGridContainer`

Creates a grid container with an optional column count.

```lua
lurek.ui.newGridContainer(columns)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `columns?` | number | Number of columns; defaults to 1. |

**Returns**

| Type | Description |
|------|-------------|
| [LLayout](#llayout) | The new grid layout widget table. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local inventory = lurek.ui.newGridContainer(3)
    inventory:setSpacing(4)
    inventory:addChild(lurek.ui.newButton("Slot 1"))
    inventory:addChild(lurek.ui.newButton("Slot 2"))
    example_print_log("grid direction = " .. inventory:getDirection())
end
```

---

### `lurek.ui.newHBoxContainer`

Creates a horizontal box container that stacks children left-to-right.

```lua
lurek.ui.newHBoxContainer()
```

**Returns**

| Type | Description |
|------|-------------|
| [LLayout](#llayout) | The new horizontal layout widget table. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hud = lurek.ui.newHBoxContainer()
    hud:setSpacing(6)
    hud:addChild(lurek.ui.newLabel("HP"))
    hud:addChild(lurek.ui.newProgressBar(0, 100))
    example_print_log("hbox direction = " .. hud:getDirection())
end
```

---

### `lurek.ui.newIcon`

Creates a label-like widget that displays only a built-in UI icon.

```lua
lurek.ui.newIcon(icon)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `icon` | string | Built-in icon name. |

**Returns**

| Type | Description |
|------|-------------|
| [LLabel](#llabel) | nil | The icon widget, or nil when the icon name is unknown. |

**Example**

```lua
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
```

---

### `lurek.ui.newImageWidget`

Creates a new image display widget.

```lua
lurek.ui.newImageWidget()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageWidget](#limagewidget) | The new image widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newLabel`

Creates a new label widget for displaying text.

```lua
lurek.ui.newLabel(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text?` | string | The label text. |

**Returns**

| Type | Description |
|------|-------------|
| [LLabel](#llabel) | The new label widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newLayout`

Creates a new layout container widget.

```lua
lurek.ui.newLayout(direction)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `direction?` | string | Layout direction: "vertical" or "horizontal" (default "vertical"). |

**Returns**

| Type | Description |
|------|-------------|
| [LLayout](#llayout) | The new layout widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newList`

Creates a new list box widget for item selection.

```lua
lurek.ui.newList()
```

**Returns**

| Type | Description |
|------|-------------|
| [LListBox](#llistbox) | The new list box widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newMarginContainer`

Creates a padding container around one or more child widgets using CSS-style shorthand.

```lua
lurek.ui.newMarginContainer(top, right, bottom, left)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `top?` | number | Top padding in pixels; defaults to 0. |
| `right?` | number | Right padding; defaults to top. |
| `bottom?` | number | Bottom padding; defaults to top. |
| `left?` | number | Left padding; defaults to right. |

**Returns**

| Type | Description |
|------|-------------|
| [LLayout](#llayout) | The new margin container widget table. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local safe_hud = lurek.ui.newMarginContainer(12, 16)
    local label = lurek.ui.newLabel("Quest updated")
    safe_hud:addChild(label)
    local top, right = safe_hud:getPadding()
    example_print_log("margin padding = " .. top .. "," .. right)
end
```

---

### `lurek.ui.newMenuBar`

Creates a new menu bar widget for top-level menus.

```lua
lurek.ui.newMenuBar()
```

**Returns**

| Type | Description |
|------|-------------|
| [LMenuBar](#lmenubar) | The new menu bar widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newMenuItem`

Creates a new menu item widget with optional text.

```lua
lurek.ui.newMenuItem(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text?` | string | The menu item text. |

**Returns**

| Type | Description |
|------|-------------|
| [LMenuItem](#lmenuitem) | The new menu item widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newNinePatch`

Creates a new nine-patch widget for scalable bordered images.

```lua
lurek.ui.newNinePatch()
```

**Returns**

| Type | Description |
|------|-------------|
| [LNinePatch](#lninepatch) | The new nine-patch widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newPanel`

Creates a new panel widget (container).

```lua
lurek.ui.newPanel()
```

**Returns**

| Type | Description |
|------|-------------|
| [LPanel](#lpanel) | The new panel widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newProgressBar`

Creates a new progress bar widget with min and max.

```lua
lurek.ui.newProgressBar(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min?` | number | Minimum value (default 0). |
| `max?` | number | Maximum value (default 100). |

**Returns**

| Type | Description |
|------|-------------|
| [LProgressBar](#lprogressbar) | The new progress bar widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newPropertyWidget`

Creates a new property inspector widget with collapsible groups and typed value rows.

```lua
lurek.ui.newPropertyWidget()
```

**Returns**

| Type | Description |
|------|-------------|
| [LPropertyWidget](#lpropertywidget) | The new property widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newRadioButton`

Creates a new radio button widget in a named group.

```lua
lurek.ui.newRadioButton(text, group)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text?` | string | The radio button label. |
| `group?` | string | The radio group name. |

**Returns**

| Type | Description |
|------|-------------|
| [LRadioButton](#lradiobutton) | The new radio button widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newScrollBar`

Creates a new scroll bar widget for content scrolling.

```lua
lurek.ui.newScrollBar(vertical)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vertical?` | boolean | True for vertical (default true). |

**Returns**

| Type | Description |
|------|-------------|
| [LScrollBar](#lscrollbar) | The new scroll bar widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newScrollContainer`

Creates a scroll container alias for `newScrollPanel`.

```lua
lurek.ui.newScrollContainer()
```

**Returns**

| Type | Description |
|------|-------------|
| [LScrollPanel](#lscrollpanel) | The new scroll panel widget table. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local scroll = lurek.ui.newScrollContainer()
    scroll:setContentSize(640, 960)
    scroll:setScrollPosition(0, 32)
    local sx, sy = scroll:getScrollPosition()
    example_print_log("scroll container pos = " .. sx .. ", " .. sy)
end
```

---

### `lurek.ui.newScrollPanel`

Creates a new scrollable panel widget.

```lua
lurek.ui.newScrollPanel()
```

**Returns**

| Type | Description |
|------|-------------|
| [LScrollPanel](#lscrollpanel) | The new scroll panel widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newSeparator`

Creates a new separator widget for visual division.

```lua
lurek.ui.newSeparator(vertical)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vertical?` | boolean | True for vertical separator (default false). |

**Returns**

| Type | Description |
|------|-------------|
| [LSeparator](#lseparator) | The new separator widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newSlider`

Creates a new slider widget with adjustable range.

```lua
lurek.ui.newSlider(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min?` | number | Minimum value (default 0). |
| `max?` | number | Maximum value (default 100). |

**Returns**

| Type | Description |
|------|-------------|
| [LSlider](#lslider) | The new slider widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newSpacer`

Creates a new spacer widget for spacing between other widgets.

```lua
lurek.ui.newSpacer(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w?` | number | The width. |
| `h?` | number | The height. |

**Returns**

| Type | Description |
|------|-------------|
| LSpacer | The new spacer widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newSpinBox`

Creates a new spin box (numeric stepper) widget.

```lua
lurek.ui.newSpinBox(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min?` | number | Minimum value (default 0). |
| `max?` | number | Maximum value (default 100). |

**Returns**

| Type | Description |
|------|-------------|
| [LSpinBox](#lspinbox) | The new spin box widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newSplitContainer`

Creates a split container alias for `newSplitPanel`.

```lua
lurek.ui.newSplitContainer(orientation)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `orientation?` | string | "horizontal" or "vertical" (default "horizontal"). |

**Returns**

| Type | Description |
|------|-------------|
| [LSplitPanel](#lsplitpanel) | The new split panel widget table. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local split = lurek.ui.newSplitContainer("vertical")
    local top = lurek.ui.newPanel()
    local bottom = lurek.ui.newPanel()
    split:setFirstChild(top._idx)
    split:setSecondChild(bottom._idx)
    example_print_log("split container = " .. split:getOrientation())
end
```

---

### `lurek.ui.newSplitPanel`

Creates a new split panel widget with two resizable sub-panels.

```lua
lurek.ui.newSplitPanel(orientation)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `orientation?` | string | "horizontal" or "vertical" (default "horizontal"). |

**Returns**

| Type | Description |
|------|-------------|
| [LSplitPanel](#lsplitpanel) | The new split panel widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newStackContainer`

Creates a stack container that lays out all children in one rectangle and shows one active child.

```lua
lurek.ui.newStackContainer()
```

**Returns**

| Type | Description |
|------|-------------|
| [LStackContainer](#lstackcontainer) | The new stack container widget table. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.ui.newStackContainer()
    stack:addChild(lurek.ui.newPanel())
    stack:addChild(lurek.ui.newPanel())
    stack:setActiveIndex(2)
    example_print_log("stack active = " .. stack:getActiveIndex())
end
```

---

### `lurek.ui.newStatusBar`

Creates a new status bar widget for app-level info.

```lua
lurek.ui.newStatusBar()
```

**Returns**

| Type | Description |
|------|-------------|
| [LStatusBar](#lstatusbar) | The new status bar widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newSwitch`

Creates a new toggle switch widget.

```lua
lurek.ui.newSwitch(on)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `on?` | boolean | Initial on/off state (default false). |

**Returns**

| Type | Description |
|------|-------------|
| [LSwitch](#lswitch) | The new switch widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newTabBar`

Creates a new tab bar widget for tabbed navigation.

```lua
lurek.ui.newTabBar()
```

**Returns**

| Type | Description |
|------|-------------|
| [LTabBar](#ltabbar) | The new tab bar widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newTabContainer`

Creates a tab container with tab labels and one active child page.

```lua
lurek.ui.newTabContainer()
```

**Returns**

| Type | Description |
|------|-------------|
| [LTabContainer](#ltabcontainer) | The new tab container widget table. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tabs = lurek.ui.newTabContainer()
    tabs:addTab("Video")
    tabs:addChild(lurek.ui.newPanel())
    example_print_log("tab container count = " .. tabs:getTabCount())
end
```

---

### `lurek.ui.newTable`

Creates a new table widget for tabular data display.

```lua
lurek.ui.newTable()
```

**Returns**

| Type | Description |
|------|-------------|
| [LGuiTable](#lguitable) | The new table widget. |

**Example**

```lua
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
```

---

### `lurek.ui.newTextInput`

Creates a new text input widget for user entry.

```lua
lurek.ui.newTextInput()
```

**Returns**

| Type | Description |
|------|-------------|
| [LTextInput](#ltextinput) | The new text input widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newTheme`

Creates a new UI theme for styling widgets.

```lua
lurek.ui.newTheme()
```

**Returns**

| Type | Description |
|------|-------------|
| [LTheme](#ltheme) | The new theme userdata. |

**Example**

```lua
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
```

---

### `lurek.ui.newToast`

Creates a new toast notification widget.

```lua
lurek.ui.newToast(message, duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message?` | string | The toast message. |
| `duration?` | number | Display duration in seconds (default 3). |

**Returns**

| Type | Description |
|------|-------------|
| [LToast](#ltoast) | The new toast widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newToolbar`

Creates a new toolbar widget for action buttons.

```lua
lurek.ui.newToolbar(orientation)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `orientation?` | string | "horizontal" or "vertical" (default "horizontal"). |

**Returns**

| Type | Description |
|------|-------------|
| [LToolbar](#ltoolbar) | The new toolbar widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newTooltipPanel`

Creates a new tooltip panel widget.

```lua
lurek.ui.newTooltipPanel(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text?` | string | The tooltip text. |

**Returns**

| Type | Description |
|------|-------------|
| [LTooltipPanel](#ltooltippanel) | The new tooltip panel widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newTreeView`

Creates a new tree view widget for hierarchical data.

```lua
lurek.ui.newTreeView()
```

**Returns**

| Type | Description |
|------|-------------|
| [LTreeView](#ltreeview) | The new tree view widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.newVBoxContainer`

Creates a vertical box container that stacks children top-to-bottom.

```lua
lurek.ui.newVBoxContainer()
```

**Returns**

| Type | Description |
|------|-------------|
| [LLayout](#llayout) | The new vertical layout widget table. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local menu = lurek.ui.newVBoxContainer()
    menu:setSpacing(8)
    menu:addChild(lurek.ui.newButton("Start"))
    menu:addChild(lurek.ui.newButton("Options"))
    example_print_log("vbox children = " .. menu:getChildCount())
end
```

---

### `lurek.ui.newWindow`

Creates a new GUI window widget with an optional title.

```lua
lurek.ui.newWindow(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title?` | string | The window title. |

**Returns**

| Type | Description |
|------|-------------|
| [LGuiWindow](#lguiwindow) | The new window widget table. |

**Example**

```lua
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
```

---

### `lurek.ui.parseWidgetState`

Validates and normalizes a widget state string.

```lua
lurek.ui.parseWidgetState(state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state` | string | The state name to parse (e.g. "normal", "hovered"). |

**Returns**

| Type | Description |
|------|-------------|
| string | The normalized state string, or nil if invalid. |

**Example**

```lua
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
```

---

### `lurek.ui.renderToImage`

Renders the entire UI to a PNG image file.

```lua
lurek.ui.renderToImage(pathOrWidth, widthOrHeight, heightOrPath)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pathOrWidth` | any | Output file path for path-first calls, or image width for canonical calls. |
| `widthOrHeight` | number | Image width for path-first calls, or image height for canonical calls. |
| `heightOrPath` | any | Image height for path-first calls, or output file path for canonical calls. |

**Example**

```lua
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
```

---

### `lurek.ui.setAutoInput`

Enables or disables automatic forwarding of platform mouse, wheel, key, and text input to `lurek.ui`.

```lua
lurek.ui.setAutoInput(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | True to forward platform input to the UI automatically. |

**Example**

```lua
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
```

---

### `lurek.ui.setAutoUpdate`

Enables or disables automatic `lurek.ui.update(dt)` calls during the frame update.

```lua
lurek.ui.setAutoUpdate(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | True to update retained UI state automatically each frame. |

**Example**

```lua
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
```

---

### `lurek.ui.setBaseResolution`

Set the logical base resolution the UI was designed for.

```lua
lurek.ui.setBaseResolution(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Base width (default 1920). |
| `height` | number | Base height (default 1080). |

**Example**

```lua
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
```

---

### `lurek.ui.setDefaultTheme`

Applies the built-in default theme to the UI context.

```lua
lurek.ui.setDefaultTheme()
```

**Example**

```lua
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
```

---

### `lurek.ui.setFocus`

Sets keyboard focus to a widget, or clears focus if nil.

```lua
lurek.ui.setFocus(widget)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `widget?` | table | The widget table to focus, or nil to clear. |

**Example**

```lua
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
```

---

### `lurek.ui.setFont`

Sets the global UI font by applying it to the root widget.

```lua
lurek.ui.setFont(font)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | [LFont](#lfont) | Font handle used by the UI when widgets do not override it. |

**Example**

```lua
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
```

---

### `lurek.ui.setTheme`

Applies a theme to the entire UI context.

```lua
lurek.ui.setTheme(theme_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `theme_ud` | [LTheme](#ltheme) | The theme userdata to apply. |

**Example**

```lua
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
```

---

### `lurek.ui.setViewport`

Sets the viewport size for the UI context.

```lua
lurek.ui.setViewport(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Viewport width. |
| `h` | number | Viewport height. |

**Example**

```lua
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
```

---

### `lurek.ui.textinput`

Delivers a text input event to the UI.

```lua
lurek.ui.textinput(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | The input text. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if a widget consumed the event. |

**Example**

```lua
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
```

---

### `lurek.ui.update`

Updates the UI context and dispatches pending events to callbacks.

```lua
lurek.ui.update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Example**

```lua
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
```

---

### `lurek.ui.updateBindings`

Updates data bindings for widgets that reference binding keys.

```lua
lurek.ui.updateBindings(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | table | A table mapping binding keys to values. |

**Returns**

| Type | Description |
|------|-------------|
| number | The number of widgets whose state changed. |

**Example**

```lua
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
```

---

### `lurek.ui.updateResolution`

Update the current viewport resolution and recompute UI scale factor.

```lua
lurek.ui.updateResolution(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | New viewport width in pixels. |
| `height` | number | New viewport height in pixels. |

**Example**

```lua
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
```

---

### `lurek.ui.update_bindings`

Updates data bindings for widgets that reference binding keys.

```lua
lurek.ui.update_bindings(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | table | A table mapping binding keys to values. |

**Returns**

| Type | Description |
|------|-------------|
| number | The number of widgets whose state changed. |

**Example**

```lua
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
```

---

### `lurek.ui.validateUx`

Returns accessibility and usability diagnostics for the live widget tree.

```lua
lurek.ui.validateUx()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of diagnostic tables containing `message` and optional `widget_idx`. |

**Example**

```lua
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
```

---

### `lurek.ui.visibleRange`

Calculate the visible item range for a scrollable list widget.

```lua
lurek.ui.visibleRange(widget, item_count, item_height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `widget` | table | Widget table with _idx field. |
| `item_count` | number | Total number of items. |
| `item_height` | number | Height of each item in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| number | Start index (0-based). |
| number | End index (exclusive). |

**Example**

```lua
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
```

---

### `lurek.ui.wheelmoved`

Delivers a mouse wheel event to the UI.

```lua
lurek.ui.wheelmoved(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Horizontal scroll delta. |
| `y` | number | Vertical scroll delta. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if a widget consumed the event. |

**Example**

```lua
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
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LAccordion](#laccordion)
- [LBadge](#lbadge)
- [LButton](#lbutton)
- [LCheckbox](#lcheckbox)
- [LColorPicker](#lcolorpicker)
- [LComboBox](#lcombobox)
- [LDialog](#ldialog)
- [LDockPanel](#ldockpanel)
- [LFont](#lfont)
- [LGuiTable](#lguitable)
- [LGuiWindow](#lguiwindow)
- [LImageData](#limagedata)
- [LImageWidget](#limagewidget)
- [LLabel](#llabel)
- [LLayout](#llayout)
- [LList](#llist)
- [LListBox](#llistbox)
- [LMenuBar](#lmenubar)
- [LMenuItem](#lmenuitem)
- [LNinePatch](#lninepatch)
- [LPanel](#lpanel)
- [LProgressBar](#lprogressbar)
- [LPropertyWidget](#lpropertywidget)
- [LRadioButton](#lradiobutton)
- [LScrollBar](#lscrollbar)
- [LScrollPanel](#lscrollpanel)
- [LSeparator](#lseparator)
- [LSlider](#lslider)
- [LSpinBox](#lspinbox)
- [LSplitPanel](#lsplitpanel)
- [LStackContainer](#lstackcontainer)
- [LStatusBar](#lstatusbar)
- [LSwitch](#lswitch)
- [LTabBar](#ltabbar)
- [LTabContainer](#ltabcontainer)
- [LTextInput](#ltextinput)
- [LTheme](#ltheme)
- [LToast](#ltoast)
- [LToolbar](#ltoolbar)
- [LTooltipPanel](#ltooltippanel)
- [LTreeView](#ltreeview)
- [LUiWidget](#luiwidget)

## LAccordion

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAccordion:addSection`

Adds a collapsible section to this accordion.

```lua
LAccordion:addSection(title, content_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | The section title. |
| `content_idx?` | number | Optional widget index for the section content. |

**Example**

```lua
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
```

---

#### `LAccordion:getSectionCount`

Returns the number of sections in this accordion.

```lua
LAccordion:getSectionCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The section count. |

**Example**

```lua
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
```

---

#### `LAccordion:getSectionTitle`

Returns the title of an accordion section by its 1-based index.

```lua
LAccordion:getSectionTitle(section_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `section_idx` | number | The 1-based section index. |

**Returns**

| Type | Description |
|------|-------------|
| string | The section title, or nil if out of range. |

**Example**

```lua
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
```

---

#### `LAccordion:isExclusive`

Returns whether this accordion is in exclusive mode (only one section open at a time).

```lua
LAccordion:isExclusive()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if exclusive. |

**Example**

```lua
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
```

---

#### `LAccordion:isSectionExpanded`

Returns whether an accordion section is expanded.

```lua
LAccordion:isSectionExpanded(section_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `section_idx` | number | The 1-based section index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if expanded. |

**Example**

```lua
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
```

---

#### `LAccordion:setExclusive`

Sets exclusive mode. When true, expanding one section collapses all others.

```lua
LAccordion:setExclusive(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | boolean | True for exclusive mode. |

**Example**

```lua
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
```

---

#### `LAccordion:toggleSection`

Toggles the expanded state of an accordion section by its 1-based index.

```lua
LAccordion:toggleSection(section_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `section_idx` | number | The 1-based section index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | The new expanded state. |

**Example**

```lua
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
```

---

## LBadge

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LBadge:getCount`

Returns the current notification count of this badge.

```lua
LBadge:getCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The badge count. |

**Example**

```lua
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
```

---

#### `LBadge:getDisplayText`

Returns the formatted display text of this badge (e.g. "99+" when count exceeds the maximum).

```lua
LBadge:getDisplayText()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The display text. |

**Example**

```lua
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
```

---

#### `LBadge:setCount`

Sets the notification count displayed by this badge.

```lua
LBadge:setCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | The notification count. |

**Example**

```lua
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
```

---

## LButton

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LButton:getText`

Returns the current display text of this button.

```lua
LButton:getText()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The button label. |

**Example**

```lua
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
```

---

#### `LButton:setText`

Sets the display text on this button.

```lua
LButton:setText(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | The button label text. |

**Example**

```lua
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
```

---

## LCheckbox

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LCheckbox:getText`

Returns the label text of this checkbox.

```lua
LCheckbox:getText()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The checkbox label. |

**Example**

```lua
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
```

---

#### `LCheckbox:isChecked`

Returns whether this checkbox is currently checked.

```lua
LCheckbox:isChecked()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if checked. |

**Example**

```lua
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
```

---

#### `LCheckbox:setChecked`

Sets the checked state of this checkbox.

```lua
LCheckbox:setChecked(checked)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `checked` | boolean | True to check, false to uncheck. |

**Example**

```lua
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
```

---

#### `LCheckbox:setText`

Sets the label text displayed next to this checkbox.

```lua
LCheckbox:setText(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | The checkbox label. |

**Example**

```lua
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
```

---

## LColorPicker

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LColorPicker:getColor`

Returns the current color as RGBA components (0.0 to 1.0).

```lua
LColorPicker:getColor()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Red component. |
| number | Green component. |
| number | Blue component. |
| number | Alpha component. |

**Example**

```lua
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
```

---

#### `LColorPicker:getColorMode`

Returns the color mode of this picker (e.g. "rgb", "hsv").

```lua
LColorPicker:getColorMode()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The color mode. |

**Example**

```lua
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
```

---

#### `LColorPicker:getShowAlpha`

Returns whether the alpha channel slider is visible.

```lua
LColorPicker:getShowAlpha()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the alpha slider is shown. |

**Example**

```lua
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
```

---

#### `LColorPicker:setColor`

Sets the current color as RGBA components.

```lua
LColorPicker:setColor(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red (0.0 to 1.0). |
| `g` | number | Green (0.0 to 1.0). |
| `b` | number | Blue (0.0 to 1.0). |
| `a?` | number | Alpha (0.0 to 1.0), keeps current if omitted. |

**Example**

```lua
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
```

---

#### `LColorPicker:setColorMode`

Sets the color mode of this picker (e.g. "rgb", "hsv").

```lua
LColorPicker:setColorMode(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | The color mode. |

**Example**

```lua
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
```

---

#### `LColorPicker:setOnChange`

Registers a callback invoked when this color picker's value changes.

```lua
LColorPicker:setOnChange(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | function | Callback receiving the widget index. |

**Example**

```lua
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
```

---

#### `LColorPicker:setShowAlpha`

Sets whether the alpha channel slider is visible.

```lua
LColorPicker:setShowAlpha(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | boolean | True to show the alpha slider. |

**Example**

```lua
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
```

---

## LComboBox

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LComboBox:addItem`

Appends a new text item to this combo box's dropdown list.

```lua
LComboBox:addItem(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | The item label to add. |

**Example**

```lua
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
```

---

#### `LComboBox:clearItems`

Removes all items from this combo box.

```lua
LComboBox:clearItems()
```

**Example**

```lua
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
```

---

#### `LComboBox:getItem`

Returns the text of the item at the given 1-based index.

```lua
LComboBox:getItem(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based item index. |

**Returns**

| Type | Description |
|------|-------------|
| string | The item text, or nil if out of range. |

**Example**

```lua
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
```

---

#### `LComboBox:getItemCount`

Returns the number of items in this combo box.

```lua
LComboBox:getItemCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The item count. |

**Example**

```lua
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
```

---

#### `LComboBox:getMaxVisibleItems`

Returns the maximum number of dropdown rows shown before the combo box scrolls.

```lua
LComboBox:getMaxVisibleItems()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Maximum visible dropdown row count. |

**Example**

```lua
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
```

---

#### `LComboBox:getSelectedIndex`

Returns the 1-based index of the currently selected item, or 0 if none is selected.

```lua
LComboBox:getSelectedIndex()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The selected index. |

**Example**

```lua
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
```

---

#### `LComboBox:getSelectedItem`

Returns the text of the currently selected item, or nil if none is selected.

```lua
LComboBox:getSelectedItem()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The selected item text. |

**Example**

```lua
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
```

---

#### `LComboBox:removeItem`

Removes the item at the given 1-based index from this combo box.

```lua
LComboBox:removeItem(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based index of the item to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the item was removed. |

**Example**

```lua
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
```

---

#### `LComboBox:setMaxVisibleItems`

Sets the maximum number of dropdown rows shown at once before the combo box scrolls.

```lua
LComboBox:setMaxVisibleItems(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Maximum visible dropdown rows; values below 1 clamp to 1. |

**Example**

```lua
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
```

---

#### `LComboBox:setSelectedIndex`

Sets the selected item by 1-based index.

```lua
LComboBox:setSelectedIndex(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based index of the item to select. |

**Example**

```lua
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
```

---

## LDialog

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LDialog:addAction`

Adds a footer action button and returns its 1-based index.

```lua
LDialog:addAction(text, cb, role, close_on_activate)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | Visible button label. |
| `cb?` | function | Optional callback fired when the action activates. |
| `role?` | string | Optional semantic role: "custom", "default", or "cancel". |
| `close_on_activate?` | boolean | Optional override for auto-close behavior. |

**Returns**

| Type | Description |
|------|-------------|
| number | The new 1-based action index. |

**Example**

```lua
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
```

---

#### `LDialog:addButton`

Adds a custom action button to this dialog.

```lua
LDialog:addButton(text, cb)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | Button label. |
| `cb?` | function | Optional callback invoked when the action is activated. |

**Returns**

| Type | Description |
|------|-------------|
| number | One-based action index, or 0 if this widget is not a dialog. |

**Example**

```lua
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
```

---

#### `LDialog:centerInViewport`

Repositions this dialog to the center of the active viewport immediately.

```lua
LDialog:centerInViewport()
```

**Example**

```lua
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
```

---

#### `LDialog:close`

Closes this dialog and dispatches close handling.

```lua
LDialog:close()
```

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
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
```

---

#### `LDialog:getCancelAction`

Returns the 1-based action index triggered by Escape, if any.

```lua
LDialog:getCancelAction()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The cancel action index, or nil when unset. |

**Example**

```lua
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
```

---

#### `LDialog:getCenterOnOpen`

Returns whether opening this dialog recenters it in the viewport.

```lua
LDialog:getCenterOnOpen()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the dialog recenters when opened. |

**Example**

```lua
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
```

---

#### `LDialog:getContent`

Returns the widget index currently assigned to this dialog's content slot.

```lua
LDialog:getContent()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Content widget index, or nil when no content is assigned. |

**Example**

```lua
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
```

---

#### `LDialog:getDefaultAction`

Returns the 1-based action index triggered by Enter, if any.

```lua
LDialog:getDefaultAction()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The default action index, or nil when unset. |

**Example**

```lua
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
```

---

#### `LDialog:getDismissOnOutsideClick`

Returns whether outside clicks dismiss this non-modal dialog.

```lua
LDialog:getDismissOnOutsideClick()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if outside dismissal is enabled. |

**Example**

```lua
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
```

---

#### `LDialog:getFooter`

Returns the optional footer content widget index.

```lua
LDialog:getFooter()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Footer widget index if one is assigned, or nil. |

**Example**

```lua
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
```

---

#### `LDialog:getMaxSize`

Returns the optional maximum popup dimensions for this dialog.

```lua
LDialog:getMaxSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Maximum width and height; or nil values when unbounded. (value 1). |
| number | Maximum width and height; or nil values when unbounded. (value 2). |

**Example**

```lua
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
```

---

#### `LDialog:getMinSize`

Returns the minimum popup size for this dialog.

```lua
LDialog:getMinSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Minimum width and height in pixels. (value 1). |
| number | Minimum width and height in pixels. (value 2). |

**Example**

```lua
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
```

---

#### `LDialog:getTitle`

Returns the current title text for this dialog.

```lua
LDialog:getTitle()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The current dialog title, or an empty string when the widget is unavailable. |

**Example**

```lua
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
```

---

#### `LDialog:isCloseable`

Returns whether this dialog exposes user-driven close affordances.

```lua
LDialog:isCloseable()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the dialog can be dismissed by the user. |

**Example**

```lua
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
```

---

#### `LDialog:isDraggable`

Returns whether this dialog can be dragged by its title bar.

```lua
LDialog:isDraggable()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if title-bar dragging is enabled. |

**Example**

```lua
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
```

---

#### `LDialog:isModal`

Returns whether this dialog is modal.

```lua
LDialog:isModal()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the dialog blocks outside interaction. |

**Example**

```lua
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
```

---

#### `LDialog:isOpen`

Returns whether this dialog is currently open.

```lua
LDialog:isOpen()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the dialog is open. |

**Example**

```lua
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
```

---

#### `LDialog:isResizable`

Returns whether this dialog can be resized from its edges or corners.

```lua
LDialog:isResizable()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if resize handles are active. |

**Example**

```lua
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
```

---

#### `LDialog:open`

Opens this dialog and marks it visible.

```lua
LDialog:open()
```

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
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
```

---

#### `LDialog:setCancelAction`

Sets the action triggered by Escape, using a 1-based action index.

```lua
LDialog:setCancelAction(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index?` | number | Action index to bind, or nil to clear the cancel action. |

**Example**

```lua
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
```

---

#### `LDialog:setCenterOnOpen`

Controls whether opening this dialog recenters it in the viewport.

```lua
LDialog:setCenterOnOpen(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | boolean | True to center the dialog each time it opens from closed state. |

**Example**

```lua
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
```

---

#### `LDialog:setCloseable`

Sets whether this dialog can be dismissed by close affordances or Escape fallback.

```lua
LDialog:setCloseable(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | boolean | True to allow user dismissal. |

**Example**

```lua
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
```

---

#### `LDialog:setContent`

Sets the widget index rendered as this dialog's content.

```lua
LDialog:setContent(content_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `content_idx?` | number | Optional widget index for the content slot. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
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
```

---

#### `LDialog:setDefaultAction`

Sets the action triggered by Enter, using a 1-based action index.

```lua
LDialog:setDefaultAction(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index?` | number | Action index to bind, or nil to clear the default action. |

**Example**

```lua
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
```

---

#### `LDialog:setDismissOnOutsideClick`

Controls whether clicking outside a non-modal dialog closes it.

```lua
LDialog:setDismissOnOutsideClick(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | boolean | True to dismiss on outside click for non-modal dialogs. |

**Example**

```lua
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
```

---

#### `LDialog:setDraggable`

Enables or disables title-bar dragging for this dialog.

```lua
LDialog:setDraggable(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | boolean | True to allow dragging. |

**Example**

```lua
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
```

---

#### `LDialog:setFooter`

Assigns an optional footer content root for this dialog.

```lua
LDialog:setFooter(footer_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `footer_idx?` | number | Optional widget index rendered in the footer slot. |

**Example**

```lua
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
```

---

#### `LDialog:setMaxSize`

Sets optional maximum popup dimensions for this dialog.

```lua
LDialog:setMaxSize(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width?` | number | Maximum width in pixels, or nil for no horizontal cap. |
| `height?` | number | Maximum height in pixels, or nil for no vertical cap. |

**Example**

```lua
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
```

---

#### `LDialog:setMinSize`

Sets the minimum popup size for this dialog.

```lua
LDialog:setMinSize(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Minimum width in pixels. |
| `height` | number | Minimum height in pixels. |

**Example**

```lua
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
```

---

#### `LDialog:setModal`

Sets whether this dialog blocks outside interaction.

```lua
LDialog:setModal(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | boolean | True to make the dialog modal. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
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
```

---

#### `LDialog:setOnClose`

Registers a callback fired when this dialog closes.

```lua
LDialog:setOnClose(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | function | Callback invoked by the UI event dispatcher. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
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
```

---

#### `LDialog:setResizable`

Enables or disables edge and corner resizing for this dialog.

```lua
LDialog:setResizable(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | boolean | True to allow resizing. |

**Example**

```lua
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
```

---

#### `LDialog:setTitle`

Sets the current title text for this dialog.

```lua
LDialog:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | New title text. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
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
```

---

## LDockPanel

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LDockPanel:dock`

Docks a child widget to the specified side of this dock panel.

```lua
LDockPanel:dock(child_idx, side)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `child_idx` | number | The widget index to dock. |
| `side` | string | The dock side ("left", "right", "top", "bottom", "center"). |

**Example**

```lua
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
```

---

#### `LDockPanel:getDockedCount`

Returns the number of widgets docked in this dock panel.

```lua
LDockPanel:getDockedCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The docked widget count. |

**Example**

```lua
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
```

---

#### `LDockPanel:getSplitSize`

Returns the size configured for a dock panel side region.

```lua
LDockPanel:getSplitSize(side)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `side` | string | The dock side. |

**Returns**

| Type | Description |
|------|-------------|
| number | The size in pixels, or nil if not set. |

**Example**

```lua
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
```

---

#### `LDockPanel:setSplitSize`

Sets the size of a dock panel side region.

```lua
LDockPanel:setSplitSize(side, size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `side` | string | The dock side ("left", "right", "top", "bottom"). |
| `size` | number | The size in pixels. |

**Example**

```lua
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
```

---

#### `LDockPanel:undock`

Removes a child widget from this dock panel.

```lua
LDockPanel:undock(child_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `child_idx` | number | The widget index to undock. |

**Example**

```lua
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
```

---

## LFont

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LFont:containsGlyph`

Returns whether the font contains a glyph for the given character. This method is available to Lua scripts.

```lua
LFont:containsGlyph(char)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `char` | string | A single-character string to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the font has a glyph for this character. |

---

#### `LFont:getAscent`

Returns the ascent (pixels above the baseline) of this font.

```lua
LFont:getAscent()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Ascent in pixels. |

---

#### `LFont:getDescent`

Returns the descent (pixels below the baseline) of this font.

```lua
LFont:getDescent()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Descent in pixels (positive value extending downward). |

---

#### `LFont:getHeight`

Returns the line height of this font in pixels.

```lua
LFont:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Line height in pixels. |

---

#### `LFont:getLineHeight`

Returns the spacing between consecutive lines of text.

```lua
LFont:getLineHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Line height in pixels. |

---

#### `LFont:getName`

Returns the human-readable name of this font. This method is available to Lua scripts.

```lua
LFont:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Font name. |

---

#### `LFont:getSize`

Returns the point size of this font. This method is available to Lua scripts.

```lua
LFont:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Point size. |

---

#### `LFont:getStyle`

Returns the style string of this font. This method is available to Lua scripts.

```lua
LFont:getStyle()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Style name ("regular", "bold"). |

---

#### `LFont:getWidth`

Measures the pixel width of a string when rendered with this font.

```lua
LFont:getWidth(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | The text to measure. |

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |

---

#### `LFont:getWrap`

Word-wraps text to fit within a pixel width limit and returns the resulting lines.

```lua
LFont:getWrap(text, limit)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | The text to wrap. |
| `limit` | number | Maximum line width in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of wrapped line strings; and the widest line width. (value 1). |
| number | Array of wrapped line strings; and the widest line width. (value 2). |

---

#### `LFont:isBold`

Returns whether this font is the bold variant. This method is available to Lua scripts.

```lua
LFont:isBold()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if font style is bold. |

---

#### `LFont:lineHeight`

Returns the line height of this font in pixels. This method is available to Lua scripts.

```lua
LFont:lineHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Line height in pixels. |

---

#### `LFont:measure`

Measures the pixel dimensions of a text string at the given scale. This method is available to Lua scripts.

```lua
LFont:measure(text, scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | Text to measure. |
| `scale?` | number | Scale factor applied to dimensions. |

**Returns**

| Type | Description |
|------|-------------|
| number | Width and height in pixels. (value 1). |
| number | Width and height in pixels. (value 2). |

---

#### `LFont:release`

Releases the font resource. The handle becomes invalid after this call.

```lua
LFont:release()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the font was still valid and was released. |

---

#### `LFont:setLineHeight`

Overrides the line height used for multi-line text rendering.

```lua
LFont:setLineHeight(height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `height` | number | New line height in pixels. |

---

#### `LFont:type`

Returns the type name string for this font object.

```lua
LFont:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LFont](#lfont)". |

---

#### `LFont:typeOf`

Checks whether this object matches the given type name.

```lua
LFont:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check ("Font" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches. |

---

#### `LFont:wrapText`

Wraps text into lines fitting within the given max width. This method is available to Lua scripts.

```lua
LFont:wrapText(text, maxWidth, scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | Text to wrap. |
| `maxWidth` | number | Maximum line width in pixels. |
| `scale?` | number | Scale factor. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of wrapped line strings. |

---

## LGuiTable

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LGuiTable:addColumn`

Adds a new column to this table widget.

```lua
LGuiTable:addColumn(header, width)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `header` | string | The column header text. |
| `width?` | number | The column width in pixels (default 100). |

**Example**

```lua
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
```

---

#### `LGuiTable:addRow`

Adds a row of data to this table widget.

```lua
LGuiTable:addRow(cells)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cells` | table | Array of cell text values. |

**Example**

```lua
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
```

---

#### `LGuiTable:clearRows`

Clears all rows and the selected row in this table widget.

```lua
LGuiTable:clearRows()
```

**Example**

```lua
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
```

---

#### `LGuiTable:getCell`

Returns the text of a cell at the given 1-based row and column.

```lua
LGuiTable:getCell(row, col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row` | number | The 1-based row index. |
| `col` | number | The 1-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| string | The cell text, or nil if out of range. |

**Example**

```lua
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
```

---

#### `LGuiTable:getColumnCount`

Returns the number of columns in this table widget.

```lua
LGuiTable:getColumnCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The column count. |

**Example**

```lua
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
```

---

#### `LGuiTable:getRowCount`

Returns the number of rows in this table widget.

```lua
LGuiTable:getRowCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The row count. |

**Example**

```lua
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
```

---

#### `LGuiTable:getSelectedRow`

Returns the 1-based index of the currently selected row, or nil.

```lua
LGuiTable:getSelectedRow()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The selected row index. |

**Example**

```lua
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
```

---

#### `LGuiTable:isSortable`

Returns whether columns in this table can be sorted by clicking headers.

```lua
LGuiTable:isSortable()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if sortable. |

**Example**

```lua
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
```

---

#### `LGuiTable:setCell`

Sets the text of a cell at the given 1-based row and column.

```lua
LGuiTable:setCell(row, col, text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row` | number | The 1-based row index. |
| `col` | number | The 1-based column index. |
| `text` | string | The new cell text. |

**Example**

```lua
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
```

---

#### `LGuiTable:setDataFrame`

Replaces columns and rows from a dataframe, stringifying cell values for display.

```lua
LGuiTable:setDataFrame(df, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `df` | [LDataFrame](dataframe.md#ldataframe) | Source dataframe. |
| `opts?` | table | Optional table with maxRows integer, columns string[], and includeHeaders boolean. |

**Returns**

| Type | Description |
|------|-------------|
| number | The resulting row count. |

**Example**

```lua
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
```

---

#### `LGuiTable:setOnSelect`

Registers a callback invoked when a table row is selected.

```lua
LGuiTable:setOnSelect(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | function | Callback receiving the widget index. |

**Example**

```lua
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
```

---

#### `LGuiTable:setRows`

Replaces all rows with an array of row arrays.

```lua
LGuiTable:setRows(rows)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `rows` | table | Array of row arrays containing scalar cell values. |

**Returns**

| Type | Description |
|------|-------------|
| number | The resulting row count. |

**Example**

```lua
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
```

---

#### `LGuiTable:setSelectedRow`

Sets the selected row by its 1-based index, or nil to deselect.

```lua
LGuiTable:setSelectedRow(row)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row?` | number | The 1-based row index, or nil. |

**Example**

```lua
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
```

---

#### `LGuiTable:setSortable`

Sets whether columns in this table can be sorted by clicking headers.

```lua
LGuiTable:setSortable(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | boolean | True to enable sorting. |

**Example**

```lua
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
```

---

## LGuiWindow

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LGuiWindow:getTitle`

Returns the title bar text of this GUI window.

```lua
LGuiWindow:getTitle()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The window title. |

**Example**

```lua
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
```

---

#### `LGuiWindow:isCloseable`

Returns whether this window shows a close button.

```lua
LGuiWindow:isCloseable()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if closeable. |

**Example**

```lua
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
```

---

#### `LGuiWindow:isDraggable`

Returns whether this window can be dragged by its title bar.

```lua
LGuiWindow:isDraggable()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if draggable. |

**Example**

```lua
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
```

---

#### `LGuiWindow:isResizable`

Returns whether this window can be resized by dragging its edges.

```lua
LGuiWindow:isResizable()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if resizable. |

**Example**

```lua
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
```

---

#### `LGuiWindow:setCloseable`

Sets whether this window shows a close button.

```lua
LGuiWindow:setCloseable(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | boolean | True to show the close button. |

**Example**

```lua
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
```

---

#### `LGuiWindow:setDraggable`

Sets whether this window can be dragged by its title bar.

```lua
LGuiWindow:setDraggable(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | boolean | True to allow dragging. |

**Example**

```lua
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
```

---

#### `LGuiWindow:setOnClose`

Registers a callback invoked when this window is closed.

```lua
LGuiWindow:setOnClose(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | function | Callback receiving the widget index. |

**Example**

```lua
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
```

---

#### `LGuiWindow:setResizable`

Sets whether this window can be resized.

```lua
LGuiWindow:setResizable(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | boolean | True to allow resizing. |

**Example**

```lua
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
```

---

#### `LGuiWindow:setTitle`

Sets the title bar text of this GUI window.

```lua
LGuiWindow:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | The window title. |

**Example**

```lua
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
```

---

## LImageData

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LImageData:alphaMask`

Multiplies this image alpha channel by a factor in place.

```lua
LImageData:alphaMask(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Alpha multiplier. |

---

#### `LImageData:applyEffect`

Applies a named image effect in place, or returns a new image when the effect changes size.

```lua
LImageData:applyEffect(name, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Effect name. |
| `opts?` | table | Effect options such as `factor`, `amount`, `radius`, `levels`, `region`, or `color`. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | nil | New image for size-changing effects, otherwise nil. |

---

#### `LImageData:applyEffects`

Applies a sequence of named effects in order.

```lua
LImageData:applyEffects(effects, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `effects` | table | Array of effect names or `{name=..., opts=...}` tables. |
| `opts?` | table | Default options used by string entries. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | nil | Last new image returned by a size-changing effect, otherwise nil. |

---

#### `LImageData:applyMask`

Multiplies this image alpha by another image's alpha channel.

```lua
LImageData:applyMask(mask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mask` | [LImageData](#limagedata) | Same-sized alpha mask image. |

---

#### `LImageData:applyPaletteLut`

Applies a palette lookup table to this image in place.

```lua
LImageData:applyPaletteLut(lut_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `lut_ud` | [LPaletteLUT](image.md#lpalettelut) | Palette lookup table handle. |

---

#### `LImageData:applyShader`

Applies an offline image shader and returns the processed image.

```lua
LImageData:applyShader(shader, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shader` | [LShader](render.md#lshader) | Image-target shader. |
| `opts?` | table | Optional processing options. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Processed image. |

---

#### `LImageData:blit`

Copies a source image into this image at a destination coordinate.

```lua
LImageData:blit(src_ud, dst_x, dst_y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | [LImageData](#limagedata) | Source image data handle. |
| `dst_x` | number | Destination x coordinate. |
| `dst_y` | number | Destination y coordinate. |

---

#### `LImageData:blur`

Returns a blurred copy of this image.

```lua
LImageData:blur(radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `radius` | number | Blur radius. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Blurred image data handle. |

---

#### `LImageData:brightness`

Applies a brightness factor to this image in place.

```lua
LImageData:brightness(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Brightness multiplier or adjustment factor. |

---

#### `LImageData:clone`

Returns a deep copy of this image data.

```lua
LImageData:clone()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Copied image data. |

---

#### `LImageData:contrast`

Applies a contrast factor to this image in place.

```lua
LImageData:contrast(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Contrast factor. |

---

#### `LImageData:convolve`

Applies a convolution kernel and returns the filtered image.

```lua
LImageData:convolve(kernel_t, ksize)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kernel_t` | table | Array table of numeric kernel weights. |
| `ksize` | number | Kernel width and height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Convolved image data handle. |

---

#### `LImageData:copyRegion`

Copies a rectangular region into a new image.

```lua
LImageData:copyRegion(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Source x coordinate. |
| `y` | number | Source y coordinate. |
| `w` | number | Region width. |
| `h` | number | Region height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Copied region. |

---

#### `LImageData:crop`

Returns a cropped image region. This method is available to Lua scripts.

```lua
LImageData:crop(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Source x coordinate. |
| `y` | number | Source y coordinate. |
| `w` | number | Crop width. |
| `h` | number | Crop height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Cropped image data handle. |

---

#### `LImageData:diff`

Computes a difference metric against another image.

```lua
LImageData:diff(other_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other_ud` | [LImageData](#limagedata) | Image data handle to compare with this image. |

**Returns**

| Type | Description |
|------|-------------|
| number | Difference score. |

---

#### `LImageData:drawCircle`

Draws a filled circle into this image.

```lua
LImageData:drawCircle(cx, cy, radius, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Circle center x coordinate. |
| `cy` | number | Circle center y coordinate. |
| `radius` | number | Circle radius. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

---

#### `LImageData:drawLine`

Draws a line into this image. This method is available to Lua scripts.

```lua
LImageData:drawLine(x0, y0, x1, y1, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x0` | number | Start x coordinate. |
| `y0` | number | Start y coordinate. |
| `x1` | number | End x coordinate. |
| `y1` | number | End y coordinate. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

---

#### `LImageData:drawRect`

Draws a filled rectangle into this image.

```lua
LImageData:drawRect(x, y, w, h, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Rectangle x coordinate. |
| `y` | number | Rectangle y coordinate. |
| `w` | number | Rectangle width. |
| `h` | number | Rectangle height. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

---

#### `LImageData:encode`

Encodes image data in a supported format.

```lua
LImageData:encode(format)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `format` | string | Format name; currently `png`. |

**Returns**

| Type | Description |
|------|-------------|
| string | Encoded image bytes. |

---

#### `LImageData:fill`

Fills the whole image with one RGBA color.

```lua
LImageData:fill(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

---

#### `LImageData:flipHorizontal`

Flips this image horizontally in place.

```lua
LImageData:flipHorizontal()
```

---

#### `LImageData:flipVertical`

Flips this image vertically in place.

```lua
LImageData:flipVertical()
```

---

#### `LImageData:gamma`

Applies gamma correction to this image in place.

```lua
LImageData:gamma(gamma)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gamma` | number | Gamma value. |

---

#### `LImageData:getDimensions`

Returns image dimensions. This method is available to Lua scripts.

```lua
LImageData:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |
| number | Height in pixels. |

---

#### `LImageData:getHeight`

Returns image height. This method is available to Lua scripts.

```lua
LImageData:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Height in pixels. |

---

#### `LImageData:getPixel`

Returns RGBA channels at a pixel coordinate.

```lua
LImageData:getPixel(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Red channel. |
| number | Green channel. |
| number | Blue channel. |
| number | Alpha channel. |

---

#### `LImageData:getRawBytes`

Returns raw image bytes as a Lua string.

```lua
LImageData:getRawBytes()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Raw image byte string. |

---

#### `LImageData:getRegion`

Returns an image region when the requested rectangle is inside bounds.

```lua
LImageData:getRegion(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Region x coordinate. |
| `y` | number | Region y coordinate. |
| `w` | number | Region width. |
| `h` | number | Region height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | nil | `[LImageData](#limagedata)` handle, or nil when the region is out of bounds. |

---

#### `LImageData:getString`

Returns raw image bytes as a Lua string.

```lua
LImageData:getString()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Raw image byte string. |

---

#### `LImageData:getWidth`

Returns image width. This method is available to Lua scripts.

```lua
LImageData:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |

---

#### `LImageData:grayscale`

Converts this image to grayscale in place.

```lua
LImageData:grayscale()
```

---

#### `LImageData:invert`

Inverts image color channels in place.

```lua
LImageData:invert()
```

---

#### `LImageData:mapPixel`

Applies a Lua callback to every pixel and replaces each pixel with returned RGBA values.

```lua
LImageData:mapPixel(func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | function | Callback receiving `(x, y, r, g, b, a)` and returning replacement channels. |

---

#### `LImageData:mapPixels`

Applies a Lua callback to every pixel and replaces each pixel with returned RGBA values.

```lua
LImageData:mapPixels(func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | function | Callback receiving `(x, y, r, g, b, a)` and returning replacement channels. |

---

#### `LImageData:noise`

Adds noise to this image in place. This method is available to Lua scripts.

```lua
LImageData:noise(amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `amount` | number | Noise amount. |

---

#### `LImageData:paste`

Pastes a source image into this image at unsigned destination coordinates.

```lua
LImageData:paste(src_ud, dx, dy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | [LImageData](#limagedata) | Source image data handle. |
| `dx` | number | Destination x coordinate. |
| `dy` | number | Destination y coordinate. |

---

#### `LImageData:posterize`

Reduces image colors to a fixed number of levels in place.

```lua
LImageData:posterize(levels)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `levels` | number | Number of posterization levels. |

---

#### `LImageData:resize`

Returns a resized image using an optional named filter.

```lua
LImageData:resize(width, height, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Output width. |
| `height` | number | Output height. |
| `filter` | string | Optional filter name, defaulting to `bilinear`. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | nil | Resized `[LImageData](#limagedata)` handle, or nil when resizing fails. |

---

#### `LImageData:resizeNearest`

Returns a resized image using nearest-neighbor sampling.

```lua
LImageData:resizeNearest(new_w, new_h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `new_w` | number | Output width. |
| `new_h` | number | Output height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Resized image data handle. |

---

#### `LImageData:rotate90cw`

Returns a new image rotated ninety degrees clockwise.

```lua
LImageData:rotate90cw()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Rotated image data handle. |

---

#### `LImageData:saturation`

Applies a saturation factor to this image in place.

```lua
LImageData:saturation(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Saturation factor. |

---

#### `LImageData:sepia`

Applies a sepia filter to this image in place.

```lua
LImageData:sepia()
```

---

#### `LImageData:setPixel`

Sets RGBA channels at a pixel coordinate.

```lua
LImageData:setPixel(x, y, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

---

#### `LImageData:setRawData`

Replaces the image byte buffer with raw bytes.

```lua
LImageData:setRawData(bytes)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bytes` | string | Raw byte string matching the image storage size. |

---

#### `LImageData:sharpen`

Returns a sharpened copy of this image.

```lua
LImageData:sharpen()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Sharpened image data handle. |

---

#### `LImageData:threshold`

Applies a threshold filter to this image in place.

```lua
LImageData:threshold(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | number | Threshold channel value. |

---

#### `LImageData:tint`

Blends this image toward a tint color in place.

```lua
LImageData:tint(tr, tg, tb, factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tr` | number | Tint red channel. |
| `tg` | number | Tint green channel. |
| `tb` | number | Tint blue channel. |
| `factor` | number | Tint blend factor. |

---

#### `LImageData:transform`

Returns a transformed image, currently supporting high-quality resize through `width`, `height`, and `filter`.

```lua
LImageData:transform(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | Transform options. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Transformed image. |

---

#### `LImageData:type`

Returns the Lua-visible type name for this image data handle.

```lua
LImageData:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LImageData](#limagedata)`. |

---

#### `LImageData:typeOf`

Returns whether this image data handle matches the `[LImageData](#limagedata)` type name.

```lua
LImageData:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LImageData](#limagedata)` or `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches. |

---

## LImageWidget

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LImageWidget:getScaleMode`

Returns the image scaling mode (e.g. "fit", "fill", "stretch").

```lua
LImageWidget:getScaleMode()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The scale mode. |

**Example**

```lua
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
```

---

#### `LImageWidget:getTint`

Returns the tint color of this image widget as RGBA components.

```lua
LImageWidget:getTint()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Red component. |
| number | Green component. |
| number | Blue component. |
| number | Alpha component. |

**Example**

```lua
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
```

---

#### `LImageWidget:setScaleMode`

Sets the image scaling mode (e.g. "fit", "fill", "stretch").

```lua
LImageWidget:setScaleMode(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | The scale mode. |

**Example**

```lua
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
```

---

#### `LImageWidget:setTint`

Sets the tint color of this image widget as RGBA components.

```lua
LImageWidget:setTint(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red (0.0 to 1.0). |
| `g` | number | Green (0.0 to 1.0). |
| `b` | number | Blue (0.0 to 1.0). |
| `a?` | number | Alpha (0.0 to 1.0), defaults to 1.0. |

**Example**

```lua
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
```

---

## LLabel

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LLabel:getText`

Returns the current display text of this label.

```lua
LLabel:getText()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The label text. |

**Example**

```lua
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
```

---

#### `LLabel:setText`

Sets the display text on this label.

```lua
LLabel:setText(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | The label text. |

**Example**

```lua
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
```

---

## LLayout

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LLayout:getAlign`

Returns the current cross-axis alignment mode.

```lua
LLayout:getAlign()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The alignment mode. |

**Example**

```lua
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
```

---

#### `LLayout:getDirection`

Returns the current layout direction.

```lua
LLayout:getDirection()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The direction name. |

**Example**

```lua
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
```

---

#### `LLayout:getJustify`

Returns the current main-axis justification mode.

```lua
LLayout:getJustify()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The justification mode. |

**Example**

```lua
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
```

---

#### `LLayout:getSpacing`

Returns the current spacing between children.

```lua
LLayout:getSpacing()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The spacing in pixels. |

**Example**

```lua
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
```

---

#### `LLayout:getWrap`

Returns whether wrapping is enabled for this layout.

```lua
LLayout:getWrap()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if wrapping is on. |

**Example**

```lua
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
```

---

#### `LLayout:setAlign`

Sets the cross-axis alignment for children (e.g. "start", "center", "end", "stretch").

```lua
LLayout:setAlign(align)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `align` | string | The alignment mode. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the layout exists and the alignment was set. |

**Example**

```lua
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
```

---

#### `LLayout:setColumns`

Sets the number of columns for grid layout mode (minimum 1).

```lua
LLayout:setColumns(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Column count. |

**Example**

```lua
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
```

---

#### `LLayout:setDirection`

Sets the layout direction for child arrangement ("horizontal", "vertical", or "grid").

```lua
LLayout:setDirection(dir)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dir` | string | The layout direction. |

**Example**

```lua
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
```

---

#### `LLayout:setJustify`

Sets the main-axis justification for children (e.g. "start", "center", "end", "space-between").

```lua
LLayout:setJustify(justify)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `justify` | string | The justification mode. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the layout exists and the justification was set. |

**Example**

```lua
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
```

---

#### `LLayout:setSpacing`

Sets the spacing in pixels between child widgets in this layout.

```lua
LLayout:setSpacing(spacing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `spacing` | number | Gap between children in pixels. |

**Example**

```lua
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
```

---

#### `LLayout:setWrap`

Enables or disables wrapping of children to the next row/column when they overflow.

```lua
LLayout:setWrap(wrap)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wrap` | boolean | True to enable wrapping. |

**Example**

```lua
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
```

---

## LList

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LList:add`

Append a value to the end of the list.

```lua
LList:add(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | The value to append. |

---

#### `LList:clear`

Remove all items from the list. This method is available to Lua scripts.

```lua
LList:clear()
```

---

#### `LList:contains`

Check whether the list contains a specific value.

```lua
LList:contains(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | string | The value to search for. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if found. |

---

#### `LList:get`

Get the value at a 1-based index. Returns nil if out of range.

```lua
LList:get(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based position. |

**Returns**

| Type | Description |
|------|-------------|
| string | The value. |
| nil | When not available. |

---

#### `LList:indexOf`

Find the 1-based index of the first occurrence of a value. Returns nil if not found.

```lua
LList:indexOf(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | string | The value to search for. |

**Returns**

| Type | Description |
|------|-------------|
| number | The 1-based index, or nil when the value is not found. |

---

#### `LList:insert`

Insert a value at a 1-based index, shifting subsequent items right.

```lua
LList:insert(index, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based insertion position. |
| `value` | any | The value to insert. |

---

#### `LList:isEmpty`

Check whether the list is empty. This method is available to Lua scripts.

```lua
LList:isEmpty()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if empty. |

---

#### `LList:len`

Return the number of items in the list.

```lua
LList:len()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Item count. |

---

#### `LList:pop`

Remove and return the last value. Returns nil if empty.

```lua
LList:pop()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The popped value. |
| nil | When not available. |

---

#### `LList:push`

Append a value to the end of the list (alias for add).

```lua
LList:push(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | The value to append. |

---

#### `LList:remove`

Remove and return the value at a 1-based index. Returns nil if out of range.

```lua
LList:remove(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based position to remove. |

**Returns**

| Type | Description |
|------|-------------|
| string | The removed value. |
| nil | When not available. |

---

#### `LList:reverse`

Reverse the order of all items in the list in-place.

```lua
LList:reverse()
```

---

#### `LList:set`

Replace the value at a 1-based index. Errors if index is 0 or out of range.

```lua
LList:set(index, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based position. |
| `value` | any | The new value. |

---

#### `LList:shift`

Remove and return the first value. Returns nil if empty.

```lua
LList:shift()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The shifted value. |
| nil | When not available. |

---

#### `LList:toArray`

Return all items as an array table. This method is available to Lua scripts.

```lua
LList:toArray()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array of all values. |

---

#### `LList:unshift`

Insert a value at the beginning of the list.

```lua
LList:unshift(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | The value to prepend. |

---

## LListBox

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LListBox:addItem`

Appends a new text item to this list box.

```lua
LListBox:addItem(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | The item text to add. |

**Example**

```lua
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
```

---

#### `LListBox:clearItems`

Removes all items from this list box.

```lua
LListBox:clearItems()
```

**Example**

```lua
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
```

---

#### `LListBox:getItem`

Returns the text of the item at the given 1-based index.

```lua
LListBox:getItem(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based item index. |

**Returns**

| Type | Description |
|------|-------------|
| string | The item text, or empty string if out of range. |

**Example**

```lua
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
```

---

#### `LListBox:getItemCount`

Returns the number of items in this list box.

```lua
LListBox:getItemCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The item count. |

**Example**

```lua
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
```

---

#### `LListBox:getSelectedIndex`

Returns the 1-based index of the currently selected item, or 0 if none.

```lua
LListBox:getSelectedIndex()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The selected index. |

**Example**

```lua
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
```

---

#### `LListBox:removeItem`

Removes the item at the given 1-based index from this list box.

```lua
LListBox:removeItem(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based index to remove. |

**Example**

```lua
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
```

---

#### `LListBox:setItemHeight`

Sets the pixel height of each item row in this list box.

```lua
LListBox:setItemHeight(h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `h` | number | Row height in pixels. |

**Example**

```lua
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
```

---

#### `LListBox:setSelectedIndex`

Sets the selected item by 1-based index.

```lua
LListBox:setSelectedIndex(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based index of the item to select. |

**Example**

```lua
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
```

---

## LMenuBar

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LMenuBar:addMenu`

Adds a menu (by its widget index) to this menu bar.

```lua
LMenuBar:addMenu(menu_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `menu_idx` | number | The widget index of the menu to add. |

**Example**

```lua
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
```

---

#### `LMenuBar:getMenuCount`

Returns the number of menus in this menu bar.

```lua
LMenuBar:getMenuCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The menu count. |

**Example**

```lua
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
```

---

#### `LMenuBar:getMenus`

Returns a table of widget indices for all menus in this menu bar.

```lua
LMenuBar:getMenus()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Menu widget indices. |

**Example**

```lua
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
```

---

#### `LMenuBar:removeMenu`

Removes a menu from this menu bar by its widget index.

```lua
LMenuBar:removeMenu(menu_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `menu_idx` | number | The widget index of the menu to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the menu was found and removed. |

**Example**

```lua
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
```

---

## LMenuItem

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LMenuItem:addSubItem`

Adds a sub-item to this menu item for building nested menus.

```lua
LMenuItem:addSubItem(child_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `child_idx` | number | The widget index of the sub-item to add. |

**Example**

```lua
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
```

---

#### `LMenuItem:getShortcut`

Returns the keyboard shortcut string associated with this menu item.

```lua
LMenuItem:getShortcut()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The shortcut text. |

**Example**

```lua
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
```

---

#### `LMenuItem:getSubItems`

Returns a table of widget indices for all sub-items of this menu item.

```lua
LMenuItem:getSubItems()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Sub-item widget indices. |

**Example**

```lua
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
```

---

#### `LMenuItem:getText`

Returns the display text of this menu item.

```lua
LMenuItem:getText()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The menu item text. |

**Example**

```lua
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
```

---

#### `LMenuItem:isChecked`

Returns whether this menu item is checked (for checkable menu items).

```lua
LMenuItem:isChecked()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if checked. |

**Example**

```lua
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
```

---

#### `LMenuItem:setChecked`

Sets the checked state of this menu item.

```lua
LMenuItem:setChecked(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | boolean | True to check. |

**Example**

```lua
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
```

---

#### `LMenuItem:setOnClick`

Registers a callback invoked when this menu item is clicked.

```lua
LMenuItem:setOnClick(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | function | Callback receiving the widget index. |

**Example**

```lua
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
```

---

#### `LMenuItem:setShortcut`

Sets the keyboard shortcut text displayed next to this menu item.

```lua
LMenuItem:setShortcut(shortcut)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shortcut` | string | The shortcut text (e.g. "Ctrl+S"). |

**Example**

```lua
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
```

---

#### `LMenuItem:setText`

Sets the display text of this menu item.

```lua
LMenuItem:setText(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | The menu item text. |

**Example**

```lua
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
```

---

## LNinePatch

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LNinePatch:getImageDimensions`

Returns the original image dimensions of this nine-patch.

```lua
LNinePatch:getImageDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Image width and height. (value 1). |
| number | Image width and height. (value 2). |

**Example**

```lua
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
```

---

#### `LNinePatch:getInsets`

Returns the border insets of this nine-patch.

```lua
LNinePatch:getInsets()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Left; top; right; and bottom insets. (value 1). |
| number | Left; top; right; and bottom insets. (value 2). |
| number | Left; top; right; and bottom insets. (value 3). |
| number | Left; top; right; and bottom insets. (value 4). |

**Example**

```lua
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
```

---

#### `LNinePatch:getSlices`

Returns the computed nine-patch slices as a table of source/dest rectangles for rendering.

```lua
LNinePatch:getSlices()
```

**Returns**

| Type | Description |
|------|-------------|
| LNinePatchGetSlicesResult | Array of slice tables with sx, sy, sw, sh, dx, dy, dw, dh fields, or nil. |

**Example**

```lua
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
```

---

#### `LNinePatch:setImageDimensions`

Sets the original image dimensions used for nine-patch slice calculations.

```lua
LNinePatch:setImageDimensions(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Image width in pixels. |
| `h` | number | Image height in pixels. |

**Example**

```lua
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
```

---

#### `LNinePatch:setInsets`

Sets the border insets defining the stretchable center region of the nine-patch image.

```lua
LNinePatch:setInsets(left, top, right, bottom)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `left` | number | Left inset in pixels. |
| `top` | number | Top inset in pixels. |
| `right` | number | Right inset in pixels. |
| `bottom` | number | Bottom inset in pixels. |

**Example**

```lua
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
```

---

## LPanel

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LPanel:getTitle`

Returns the title text of this panel.

```lua
LPanel:getTitle()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The panel title. |

**Example**

```lua
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
```

---

#### `LPanel:setScrollable`

Enables or disables scrolling within this panel.

```lua
LPanel:setScrollable(scrollable)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scrollable` | boolean | True to enable scrolling. |

**Example**

```lua
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
```

---

#### `LPanel:setTitle`

Sets the title text displayed on this panel's header.

```lua
LPanel:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | The panel title. |

**Example**

```lua
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
```

---

## LProgressBar

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LProgressBar:getMax`

Returns the maximum value of this progress bar's range.

```lua
LProgressBar:getMax()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The maximum value. |

**Example**

```lua
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
```

---

#### `LProgressBar:getMin`

Returns the minimum value of this progress bar's range.

```lua
LProgressBar:getMin()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The minimum value. |

**Example**

```lua
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
```

---

#### `LProgressBar:getProgress`

Returns the normalized progress as a fraction (0.0 to 1.0) of the current range.

```lua
LProgressBar:getProgress()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The normalized progress. |

**Example**

```lua
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
```

---

#### `LProgressBar:getValue`

Returns the current value of this progress bar.

```lua
LProgressBar:getValue()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The progress value. |

**Example**

```lua
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
```

---

#### `LProgressBar:setRange`

Sets the minimum and maximum bounds for this progress bar.

```lua
LProgressBar:setRange(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | number | Minimum value. |
| `max` | number | Maximum value. |

**Example**

```lua
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
```

---

#### `LProgressBar:setValue`

Sets the current fill value of this progress bar, clamped to its range.

```lua
LProgressBar:setValue(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | The progress value. |

**Example**

```lua
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
```

---

## LPropertyWidget

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LPropertyWidget:addGroup`

Adds a collapsible property group and returns its 1-based index.

```lua
LPropertyWidget:addGroup(title, collapsed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | The group title. |
| `collapsed?` | boolean | Whether the group starts collapsed. |

**Returns**

| Type | Description |
|------|-------------|
| number | The 1-based group index. |

**Example**

```lua
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
```

---

#### `LPropertyWidget:addProperty`

Adds a property row to a group.

```lua
LPropertyWidget:addProperty(group, name, value, valueType, options, readOnly)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group` | number | The 1-based group index. |
| `name` | string | The property label. |
| `value` | any | Scalar value to display. |
| `valueType?` | string | `text`, `number`, `bool`, `select`, or `color`. |
| `options?` | table | Select options for `valueType = "select"`. |
| `readOnly?` | boolean | Whether the row is read-only. |

**Returns**

| Type | Description |
|------|-------------|
| number | The 1-based row index in the group, or 0 on failure. |

**Example**

```lua
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
```

---

#### `LPropertyWidget:getGroupCount`

Returns the number of property groups.

```lua
LPropertyWidget:getGroupCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The group count. |

**Example**

```lua
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
```

---

#### `LPropertyWidget:getLabelWidth`

Returns the left label column width in pixels.

```lua
LPropertyWidget:getLabelWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |

**Example**

```lua
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
```

---

#### `LPropertyWidget:getPropertyCount`

Returns the row count for a property group.

```lua
LPropertyWidget:getPropertyCount(group)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group` | number | The 1-based group index. |

**Returns**

| Type | Description |
|------|-------------|
| number | The property row count. |

**Example**

```lua
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
```

---

#### `LPropertyWidget:getPropertyOptions`

Returns the select options of the first property with `name`.

```lua
LPropertyWidget:getPropertyOptions(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Property name. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of option strings. |

**Example**

```lua
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
```

---

#### `LPropertyWidget:getPropertyType`

Returns the canonical editor type of the first property with `name`.

```lua
LPropertyWidget:getPropertyType(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Property name. |

**Returns**

| Type | Description |
|------|-------------|
| string | The editor type, or nil when missing. |

**Example**

```lua
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
```

---

#### `LPropertyWidget:getPropertyValue`

Returns the stringified value of the first property with `name`.

```lua
LPropertyWidget:getPropertyValue(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Property name. |

**Returns**

| Type | Description |
|------|-------------|
| string | The value text, or nil when missing. |

**Example**

```lua
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
```

---

#### `LPropertyWidget:isGroupCollapsed`

Returns whether a property group is collapsed.

```lua
LPropertyWidget:isGroupCollapsed(group)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group` | number | The 1-based group index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when collapsed, or nil when the index is invalid. |

**Example**

```lua
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
```

---

#### `LPropertyWidget:setLabelWidth`

Sets the left label column width in pixels.

```lua
LPropertyWidget:setLabelWidth(width)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Width in pixels; clamped to at least 1. |

**Example**

```lua
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
```

---

#### `LPropertyWidget:setPropertyValue`

Updates the first property with `name`.

```lua
LPropertyWidget:setPropertyValue(name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Property name. |
| `value` | any | Scalar value to display. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a row changed. |

**Example**

```lua
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
```

---

#### `LPropertyWidget:toggleGroup`

Toggles a property group collapsed/expanded state.

```lua
LPropertyWidget:toggleGroup(group)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group` | number | The 1-based group index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | The new collapsed state, or nil when the index is invalid. |

**Example**

```lua
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
```

---

## LRadioButton

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LRadioButton:getGroup`

Returns the radio button group name. Buttons in the same group are mutually exclusive.

```lua
LRadioButton:getGroup()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The group name. |

**Example**

```lua
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
```

---

#### `LRadioButton:getText`

Returns the label text of this radio button.

```lua
LRadioButton:getText()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The radio button label. |

**Example**

```lua
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
```

---

#### `LRadioButton:isSelected`

Returns whether this radio button is currently selected.

```lua
LRadioButton:isSelected()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if selected. |

**Example**

```lua
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
```

---

#### `LRadioButton:setGroup`

Sets the radio button group name. Buttons in the same group are mutually exclusive.

```lua
LRadioButton:setGroup(group)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group` | string | The group name. |

**Example**

```lua
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
```

---

#### `LRadioButton:setOnChange`

Registers a callback invoked when this radio button's selection changes.

```lua
LRadioButton:setOnChange(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | function | Callback receiving the widget index. |

**Example**

```lua
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
```

---

#### `LRadioButton:setSelected`

Sets the selected state of this radio button.

```lua
LRadioButton:setSelected(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | boolean | True to select. |

**Example**

```lua
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
```

---

#### `LRadioButton:setText`

Sets the label text of this radio button.

```lua
LRadioButton:setText(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | The radio button label. |

**Example**

```lua
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
```

---

## LScrollBar

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LScrollBar:getContentSize`

Returns the total content size tracked by this scroll bar.

```lua
LScrollBar:getContentSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The content size. |

**Example**

```lua
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
```

---

#### `LScrollBar:getScrollPosition`

Returns the current scroll position of this scroll bar.

```lua
LScrollBar:getScrollPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The scroll position. |

**Example**

```lua
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
```

---

#### `LScrollBar:getViewSize`

Returns the visible viewport size tracked by this scroll bar.

```lua
LScrollBar:getViewSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The view size. |

**Example**

```lua
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
```

---

#### `LScrollBar:isVertical`

Returns whether this scroll bar is oriented vertically.

```lua
LScrollBar:isVertical()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if vertical. |

**Example**

```lua
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
```

---

#### `LScrollBar:setContentSize`

Sets the total content size that this scroll bar represents.

```lua
LScrollBar:setContentSize(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | The content size. |

**Example**

```lua
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
```

---

#### `LScrollBar:setOnChange`

Registers a callback invoked when this scroll bar's position changes.

```lua
LScrollBar:setOnChange(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | function | Callback receiving the widget index. |

**Example**

```lua
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
```

---

#### `LScrollBar:setScrollPosition`

Sets the scroll position of this scroll bar, clamped to the valid range.

```lua
LScrollBar:setScrollPosition(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | The scroll position. |

**Example**

```lua
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
```

---

#### `LScrollBar:setViewSize`

Sets the visible viewport size for this scroll bar.

```lua
LScrollBar:setViewSize(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | The view size. |

**Example**

```lua
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
```

---

## LScrollPanel

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LScrollPanel:getContentSize`

Returns the virtual content dimensions of this scroll panel.

```lua
LScrollPanel:getContentSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Content width and height in pixels. (value 1). |
| number | Content width and height in pixels. (value 2). |

**Example**

```lua
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
```

---

#### `LScrollPanel:getMaxScroll`

Returns the maximum scroll offset allowed in each axis.

```lua
LScrollPanel:getMaxScroll()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Maximum horizontal and vertical scroll values. (value 1). |
| number | Maximum horizontal and vertical scroll values. (value 2). |

**Example**

```lua
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
```

---

#### `LScrollPanel:getScrollPosition`

Returns the current scroll offset of this scroll panel.

```lua
LScrollPanel:getScrollPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Horizontal and vertical scroll offsets. (value 1). |
| number | Horizontal and vertical scroll offsets. (value 2). |

**Example**

```lua
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
```

---

#### `LScrollPanel:getScrollSpeed`

Returns the current scroll speed multiplier.

```lua
LScrollPanel:getScrollSpeed()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The scroll speed. |

**Example**

```lua
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
```

---

#### `LScrollPanel:setContentSize`

Sets the virtual content dimensions of this scroll panel.

```lua
LScrollPanel:setContentSize(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Content width in pixels. |
| `h` | number | Content height in pixels. |

**Example**

```lua
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
```

---

#### `LScrollPanel:setScrollPosition`

Sets the scroll offset position of this scroll panel.

```lua
LScrollPanel:setScrollPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Horizontal scroll offset. |
| `y` | number | Vertical scroll offset. |

**Example**

```lua
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
```

---

#### `LScrollPanel:setScrollSpeed`

Sets the scroll speed multiplier for mouse wheel scrolling.

```lua
LScrollPanel:setScrollSpeed(speed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `speed` | number | Scroll speed in pixels per scroll tick. |

**Example**

```lua
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
```

---

## LSeparator

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSeparator:getThickness`

Returns the line thickness of this separator.

```lua
LSeparator:getThickness()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The thickness in pixels. |

**Example**

```lua
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
    example_print_log("isVertical:", vert, "thickness:", thick, "->", t2)
end
```

---

#### `LSeparator:isVertical`

Returns whether this separator is oriented vertically.

```lua
LSeparator:isVertical()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if vertical. |

**Example**

```lua
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
    example_print_log("isVertical:", vert, "thickness:", thick, "->", t2)
end
```

---

#### `LSeparator:setThickness`

Sets the line thickness of this separator in pixels.

```lua
LSeparator:setThickness(thickness)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `thickness` | number | Thickness in pixels. |

**Example**

```lua
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
    example_print_log("isVertical:", vert, "thickness:", thick, "->", t2)
end
```

---

#### `LSeparator:setVertical`

Sets whether this separator draws vertically or horizontally.

```lua
LSeparator:setVertical(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | boolean | True for vertical, false for horizontal. |

**Example**

```lua
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
```

---

## LSlider

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSlider:getMax`

Returns the maximum value of this slider's range.

```lua
LSlider:getMax()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The maximum value. |

**Example**

```lua
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
```

---

#### `LSlider:getMin`

Returns the minimum value of this slider's range.

```lua
LSlider:getMin()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The minimum value. |

**Example**

```lua
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
```

---

#### `LSlider:getValue`

Returns the current value of this slider.

```lua
LSlider:getValue()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The slider value. |

**Example**

```lua
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
```

---

#### `LSlider:setRange`

Sets the minimum and maximum bounds for this slider.

```lua
LSlider:setRange(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | number | Minimum value. |
| `max` | number | Maximum value. |

**Example**

```lua
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
```

---

#### `LSlider:setStep`

Sets the step increment for this slider's value snapping.

```lua
LSlider:setStep(step)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `step` | number | The step size. |

**Example**

```lua
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
```

---

#### `LSlider:setValue`

Sets the current value of this slider, clamped to its range.

```lua
LSlider:setValue(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | The value to set. |

**Example**

```lua
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
```

---

## LSpinBox

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSpinBox:decrement`

Decreases this spin box's value by one step.

```lua
LSpinBox:decrement()
```

**Example**

```lua
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
```

---

#### `LSpinBox:getValue`

Returns the current numeric value of this spin box.

```lua
LSpinBox:getValue()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The spin box value. |

**Example**

```lua
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
```

---

#### `LSpinBox:increment`

Increases this spin box's value by one step.

```lua
LSpinBox:increment()
```

**Example**

```lua
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
```

---

#### `LSpinBox:setRange`

Sets the minimum and maximum bounds for this spin box.

```lua
LSpinBox:setRange(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | number | Minimum value. |
| `max` | number | Maximum value. |

**Example**

```lua
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
```

---

#### `LSpinBox:setStep`

Sets the step increment for this spin box.

```lua
LSpinBox:setStep(step)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `step` | number | The step size (minimum 1e-9). |

**Example**

```lua
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
```

---

#### `LSpinBox:setValue`

Sets the numeric value of this spin box, clamped to its range.

```lua
LSpinBox:setValue(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | The value to set. |

**Example**

```lua
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
```

---

## LSplitPanel

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSplitPanel:getFirstChild`

Returns the widget index of the first (left/top) child panel.

```lua
LSplitPanel:getFirstChild()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The widget index, or nil if not set. |

**Example**

```lua
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
```

---

#### `LSplitPanel:getMinPanelSize`

Returns the minimum pixel size of each split sub-panel.

```lua
LSplitPanel:getMinPanelSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The minimum size in pixels. |

**Example**

```lua
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
```

---

#### `LSplitPanel:getOrientation`

Returns the orientation of this split panel ("horizontal" or "vertical").

```lua
LSplitPanel:getOrientation()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The orientation. |

**Example**

```lua
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
```

---

#### `LSplitPanel:getSecondChild`

Returns the widget index of the second (right/bottom) child panel.

```lua
LSplitPanel:getSecondChild()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The widget index, or nil if not set. |

**Example**

```lua
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
```

---

#### `LSplitPanel:getSplitPosition`

Returns the split position as a fraction (0.0 to 1.0) of the panel's total size.

```lua
LSplitPanel:getSplitPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The split fraction. |

**Example**

```lua
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
```

---

#### `LSplitPanel:setFirstChild`

Sets the widget index for the first (left/top) panel.

```lua
LSplitPanel:setFirstChild(child_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `child_idx` | number | The widget index. |

**Example**

```lua
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
```

---

#### `LSplitPanel:setMinPanelSize`

Sets the minimum pixel size of each split sub-panel.

```lua
LSplitPanel:setMinPanelSize(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | The minimum size in pixels. |

**Example**

```lua
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
```

---

#### `LSplitPanel:setOrientation`

Sets the orientation of this split panel ("horizontal" or "vertical").

```lua
LSplitPanel:setOrientation(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | string | The orientation. |

**Example**

```lua
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
```

---

#### `LSplitPanel:setSecondChild`

Sets the widget index for the second (right/bottom) panel.

```lua
LSplitPanel:setSecondChild(child_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `child_idx` | number | The widget index. |

**Example**

```lua
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
```

---

#### `LSplitPanel:setSplitPosition`

Sets the split position as a fraction (0.0 to 1.0).

```lua
LSplitPanel:setSplitPosition(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | The split fraction. |

**Example**

```lua
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
```

---

## LStackContainer

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LStackContainer:addTab`

Adds a tab/page label to this stack or tab container.

```lua
LStackContainer:addTab(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | string | The visible tab label. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.ui.newStackContainer()
    stack:addTab("Inventory")
    stack:addTab("Map")
    example_print_log("stack labels = " .. stack:getTabCount())
end
```

---

#### `LStackContainer:getActiveChild`

Returns the widget index of the active child page.

```lua
LStackContainer:getActiveChild()
```

**Returns**

| Type | Description |
|------|-------------|
| number | nil | The active child widget index, or nil when no child exists. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.ui.newStackContainer()
    local page = lurek.ui.newPanel()
    stack:addChild(page)
    example_print_log("active child = " .. tostring(stack:getActiveChild()))
end
```

---

#### `LStackContainer:getActiveIndex`

Returns the active child page as a 1-based index.

```lua
LStackContainer:getActiveIndex()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The active child index, or 0 when unavailable. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.ui.newStackContainer()
    stack:addChild(lurek.ui.newPanel())
    stack:setActiveIndex(1)
    example_print_log("active index = " .. stack:getActiveIndex())
end
```

---

#### `LStackContainer:getTab`

Returns a tab/page label by 1-based index.

```lua
LStackContainer:getTab(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based tab index. |

**Returns**

| Type | Description |
|------|-------------|
| string | nil | The tab label, or nil when out of range. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.ui.newStackContainer()
    stack:addTab("Journal")
    local label = stack:getTab(1)
    example_print_log("stack label = " .. tostring(label))
end
```

---

#### `LStackContainer:getTabCount`

Returns the number of tab/page labels in this stack or tab container.

```lua
LStackContainer:getTabCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The tab label count. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.ui.newStackContainer()
    stack:addTab("Stats")
    stack:addTab("Equipment")
    example_print_log("stack label count = " .. stack:getTabCount())
end
```

---

#### `LStackContainer:setActiveIndex`

Sets the active child page by 1-based child index.

```lua
LStackContainer:setActiveIndex(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based child index to show. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the index exists and was set. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.ui.newStackContainer()
    stack:addChild(lurek.ui.newPanel())
    stack:addChild(lurek.ui.newPanel())
    local changed = stack:setActiveIndex(2)
    example_print_log("active changed = " .. tostring(changed))
end
```

---

## LStatusBar

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LStatusBar:addSection`

Adds a labeled section to this status bar.

```lua
LStatusBar:addSection(text, width)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | The section display text. |
| `width?` | number | The section width in pixels (default 100). |

**Example**

```lua
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
```

---

#### `LStatusBar:getSectionCount`

Returns the number of sections in this status bar.

```lua
LStatusBar:getSectionCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The section count. |

**Example**

```lua
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
```

---

#### `LStatusBar:getSectionText`

Returns the text of a status bar section by its 1-based index.

```lua
LStatusBar:getSectionText(section_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `section_idx` | number | The 1-based section index. |

**Returns**

| Type | Description |
|------|-------------|
| string | The section text, or nil if out of range. |

**Example**

```lua
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
```

---

#### `LStatusBar:setSectionCount`

Sets the number of sections, truncating or adding empty sections as needed.

```lua
LStatusBar:setSectionCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | The desired section count. |

**Example**

```lua
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
```

---

#### `LStatusBar:setSectionText`

Sets the text of a status bar section by its 1-based index.

```lua
LStatusBar:setSectionText(section_idx, text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `section_idx` | number | The 1-based section index. |
| `text` | string | The new section text. |

**Example**

```lua
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
```

---

#### `LStatusBar:setSectionWidget`

Associates a widget with a status bar section (reserved for future use).

```lua
LStatusBar:setSectionWidget(section_idx, widget)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `section_idx` | number | The 1-based section index. |
| `widget?` | table | The widget table to associate, or nil to clear. |

**Example**

```lua
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
```

---

## LSwitch

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSwitch:isOn`

Returns whether this switch is currently in the on state.

```lua
LSwitch:isOn()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the switch is on. |

**Example**

```lua
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
```

---

#### `LSwitch:setOn`

Sets the on/off state of this toggle switch.

```lua
LSwitch:setOn(on)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `on` | boolean | True to turn on, false to turn off. |

**Example**

```lua
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
```

---

#### `LSwitch:toggle`

Toggles this switch between on and off states.

```lua
LSwitch:toggle()
```

**Example**

```lua
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
```

---

## LTabBar

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTabBar:addTab`

Adds a new tab with the given label to this tab bar.

```lua
LTabBar:addTab(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | string | The tab label text. |

**Example**

```lua
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
```

---

#### `LTabBar:getActiveTab`

Returns the 1-based index of the currently active tab.

```lua
LTabBar:getActiveTab()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The active tab index. |

**Example**

```lua
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
```

---

#### `LTabBar:getTab`

Returns the label of the tab at the given 1-based index.

```lua
LTabBar:getTab(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based tab index. |

**Returns**

| Type | Description |
|------|-------------|
| string | The tab label, or nil if out of range. |

**Example**

```lua
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
```

---

#### `LTabBar:getTabCount`

Returns the total number of tabs in this tab bar.

```lua
LTabBar:getTabCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The tab count. |

**Example**

```lua
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
```

---

#### `LTabBar:removeTab`

Removes the tab at the given 1-based index.

```lua
LTabBar:removeTab(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based tab index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the tab was removed. |

**Example**

```lua
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
```

---

#### `LTabBar:setActiveTab`

Sets the active (selected) tab by 1-based index.

```lua
LTabBar:setActiveTab(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based tab index to activate. |

**Example**

```lua
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
```

---

## LTabContainer

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTabContainer:addTab`

Adds a tab label to this tab container.

```lua
LTabContainer:addTab(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | string | The visible tab label. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tabs = lurek.ui.newTabContainer()
    tabs:addTab("Audio")
    tabs:addTab("Controls")
    example_print_log("tab labels = " .. tabs:getTabCount())
end
```

---

#### `LTabContainer:getActiveChild`

Returns the widget index of the active tab page.

```lua
LTabContainer:getActiveChild()
```

**Returns**

| Type | Description |
|------|-------------|
| number | nil | The active child widget index, or nil when no child exists. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tabs = lurek.ui.newTabContainer()
    local page = lurek.ui.newPanel()
    tabs:addChild(page)
    example_print_log("tab active child = " .. tostring(tabs:getActiveChild()))
end
```

---

#### `LTabContainer:getActiveIndex`

Returns the active tab page as a 1-based child index.

```lua
LTabContainer:getActiveIndex()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The active child index, or 0 when unavailable. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tabs = lurek.ui.newTabContainer()
    tabs:addChild(lurek.ui.newPanel())
    tabs:setActiveIndex(1)
    example_print_log("tab active index = " .. tabs:getActiveIndex())
end
```

---

#### `LTabContainer:getTab`

Returns a tab label by 1-based index.

```lua
LTabContainer:getTab(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based tab index. |

**Returns**

| Type | Description |
|------|-------------|
| string | nil | The tab label, or nil when out of range. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tabs = lurek.ui.newTabContainer()
    tabs:addTab("Gameplay")
    local label = tabs:getTab(1)
    example_print_log("first tab = " .. tostring(label))
end
```

---

#### `LTabContainer:getTabCount`

Returns the number of tab labels in this tab container.

```lua
LTabContainer:getTabCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The tab label count. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tabs = lurek.ui.newTabContainer()
    tabs:addTab("Video")
    tabs:addTab("Audio")
    example_print_log("tab count = " .. tabs:getTabCount())
end
```

---

#### `LTabContainer:setActiveIndex`

Sets the active tab page by 1-based child index.

```lua
LTabContainer:setActiveIndex(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based child index to show. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the index exists and was set. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tabs = lurek.ui.newTabContainer()
    tabs:addChild(lurek.ui.newPanel())
    tabs:addChild(lurek.ui.newPanel())
    local changed = tabs:setActiveIndex(2)
    example_print_log("tab active changed = " .. tostring(changed))
end
```

---

## LTextInput

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTextInput:getCursorPosition`

Returns the current cursor position (character index) within the text input.

```lua
LTextInput:getCursorPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The zero-based cursor position. |

**Example**

```lua
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
```

---

#### `LTextInput:getPlaceholder`

Returns the placeholder text of this text input.

```lua
LTextInput:getPlaceholder()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The placeholder text. |

**Example**

```lua
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
```

---

#### `LTextInput:getSubmitOnEnter`

Returns whether pressing Enter in this text input submits the surrounding dialog default action.

```lua
LTextInput:getSubmitOnEnter()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if Enter submits the parent dialog default action. |

**Example**

```lua
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
```

---

#### `LTextInput:getText`

Returns the current text content of this text input field.

```lua
LTextInput:getText()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The input text. |

**Example**

```lua
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
```

---

#### `LTextInput:isFocused`

Returns whether this text input currently has keyboard focus.

```lua
LTextInput:isFocused()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if focused. |

**Example**

```lua
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
```

---

#### `LTextInput:setMaxLength`

Sets the maximum number of characters allowed in this text input.

```lua
LTextInput:setMaxLength(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Maximum character count. |

**Example**

```lua
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
```

---

#### `LTextInput:setPlaceholder`

Sets the placeholder text shown when the input is empty.

```lua
LTextInput:setPlaceholder(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | The placeholder text. |

**Example**

```lua
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
```

---

#### `LTextInput:setSubmitOnEnter`

Controls whether pressing Enter in this text input submits the surrounding dialog default action.

```lua
LTextInput:setSubmitOnEnter(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | boolean | True to submit on Enter, false to consume Enter locally. |

**Example**

```lua
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
```

---

#### `LTextInput:setText`

Sets the text content of this text input field and moves the cursor to the end.

```lua
LTextInput:setText(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | The text to set. |

**Example**

```lua
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
```

---

## LTheme

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTheme:setStyle`

Sets a style entry for the given widget type and state, optionally restricted to a style class.

```lua
LTheme:setStyle(widget_type, state, styleOrClass, styleTable)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `widget_type` | string | The widget type name (e.g. "button"). |
| `state` | string | The widget state (e.g. "normal", "hovered"). |
| `styleOrClass` | any | Style table for default styles, or a class string when `styleTable` is supplied. |
| `styleTable?` | table | Style table used when `styleOrClass` is a class string. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the style is applied. |

**Example**

```lua
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
```

---

#### `LTheme:type`

Returns the type name of this object.

```lua
LTheme:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LTheme](#ltheme)". |

**Example**

```lua
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
```

---

#### `LTheme:typeOf`

Checks whether this object matches the given type name.

```lua
LTheme:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches this userdata type. |

**Example**

```lua
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
```

---

## LToast

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LToast:getDuration`

Returns the display duration of this toast in seconds.

```lua
LToast:getDuration()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The duration. |

**Example**

```lua
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
```

---

#### `LToast:getMessage`

Returns the message text of this toast.

```lua
LToast:getMessage()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The toast message. |

**Example**

```lua
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
```

---

#### `LToast:getProgress`

Returns the elapsed fraction (0.0 to 1.0) of this toast's lifetime.

```lua
LToast:getProgress()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The progress fraction. |

**Example**

```lua
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
```

---

#### `LToast:isExpired`

Returns whether this toast has exceeded its display duration.

```lua
LToast:isExpired()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if expired. |

**Example**

```lua
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
```

---

#### `LToast:setDuration`

Sets how long this toast is displayed in seconds.

```lua
LToast:setDuration(d)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `d` | number | Duration in seconds. |

**Example**

```lua
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
```

---

#### `LToast:setMessage`

Sets the message text displayed by this toast notification.

```lua
LToast:setMessage(msg)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `msg` | string | The toast message. |

**Example**

```lua
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
```

---

## LToolbar

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LToolbar:addButton`

Adds a new button to this toolbar and returns its 1-based index.

```lua
LToolbar:addButton(id, tooltip)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | The button identifier. |
| `tooltip?` | string | Optional tooltip text for the button. |

**Returns**

| Type | Description |
|------|-------------|
| number | The 1-based index of the added button. |

**Example**

```lua
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
```

---

#### `LToolbar:addSeparator`

Adds a visual separator to this toolbar.

```lua
LToolbar:addSeparator()
```

**Example**

```lua
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
```

---

#### `LToolbar:addSpacer`

Adds a flexible spacer to this toolbar.

```lua
LToolbar:addSpacer(_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `_size?` | number | Optional size hint (reserved for future use). |

**Example**

```lua
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
```

---

#### `LToolbar:getButton`

Returns a table describing the toolbar button with the given ID.

```lua
LToolbar:getButton(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | The button identifier. |

**Returns**

| Type | Description |
|------|-------------|
| LToolbarGetButtonResult | Table with id, tooltip, enabled, toggled fields, or nil if not found. |

**Example**

```lua
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
```

---

#### `LToolbar:getOrientation`

Returns the toolbar orientation ("horizontal" or "vertical").

```lua
LToolbar:getOrientation()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The orientation. |

**Example**

```lua
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
```

---

#### `LToolbar:isButtonToggled`

Returns whether a toolbar button is toggled on.

```lua
LToolbar:isButtonToggled(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | The button identifier. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if toggled, nil if not found. |

**Example**

```lua
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
```

---

#### `LToolbar:setButtonEnabled`

Enables or disables a toolbar button by its ID.

```lua
LToolbar:setButtonEnabled(id, enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | The button identifier. |
| `enabled` | boolean | True to enable. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the button was found. |

**Example**

```lua
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
```

---

#### `LToolbar:setButtonToggled`

Sets the toggle state of a toolbar button by its ID.

```lua
LToolbar:setButtonToggled(id, toggled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | The button identifier. |
| `toggled` | boolean | True to toggle on. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the button was found. |

**Example**

```lua
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
```

---

#### `LToolbar:setOrientation`

Sets the toolbar orientation ("horizontal" or "vertical").

```lua
LToolbar:setOrientation(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | string | The orientation. |

**Example**

```lua
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
```

---

## LTooltipPanel

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTooltipPanel:getDelay`

Returns the delay in seconds before this tooltip appears.

```lua
LTooltipPanel:getDelay()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The delay in seconds. |

**Example**

```lua
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
```

---

#### `LTooltipPanel:getTarget`

Returns the widget index that this tooltip is attached to.

```lua
LTooltipPanel:getTarget()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The target widget index, or nil if unset. |

**Example**

```lua
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
```

---

#### `LTooltipPanel:getText`

Returns the current tooltip display text.

```lua
LTooltipPanel:getText()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The tooltip text. |

**Example**

```lua
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
```

---

#### `LTooltipPanel:setDelay`

Sets the delay in seconds before this tooltip appears.

```lua
LTooltipPanel:setDelay(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | The delay in seconds. |

**Example**

```lua
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
```

---

#### `LTooltipPanel:setTarget`

Sets the widget index that this tooltip is attached to.

```lua
LTooltipPanel:setTarget(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target?` | number | The target widget index, or nil to detach. |

**Example**

```lua
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
```

---

#### `LTooltipPanel:setText`

Sets the tooltip panel display text content.

```lua
LTooltipPanel:setText(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | The tooltip text. |

**Example**

```lua
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
```

---

## LTreeView

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTreeView:addNode`

Adds a new node to this tree view, optionally under a parent node.

```lua
LTreeView:addNode(text, parent_index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | The node label text. |
| `parent_index?` | number | The 1-based parent node index, or nil for a root node. |

**Returns**

| Type | Description |
|------|-------------|
| number | The 1-based index of the newly added node. |

**Example**

```lua
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
```

---

#### `LTreeView:clearNodes`

Removes all nodes from this tree view.

```lua
LTreeView:clearNodes()
```

**Example**

```lua
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
```

---

#### `LTreeView:collapseAll`

Collapses all nodes in this tree view.

```lua
LTreeView:collapseAll()
```

**Example**

```lua
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
```

---

#### `LTreeView:collapseNode`

Collapses the node at the given 1-based index to hide its children.

```lua
LTreeView:collapseNode(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based node index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the node was collapsed. |

**Example**

```lua
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
```

---

#### `LTreeView:expandAll`

Expands all nodes in this tree view.

```lua
LTreeView:expandAll()
```

**Example**

```lua
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
```

---

#### `LTreeView:expandNode`

Expands the node at the given 1-based index to show its children.

```lua
LTreeView:expandNode(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based node index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the node was expanded. |

**Example**

```lua
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
```

---

#### `LTreeView:getChildNodes`

Returns a table of 1-based child node indices for the node at the given index.

```lua
LTreeView:getChildNodes(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based parent node index. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | 1-based child indices. |

**Example**

```lua
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
```

---

#### `LTreeView:getNodeCount`

Returns the total number of nodes in this tree view.

```lua
LTreeView:getNodeCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The node count. |

**Example**

```lua
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
```

---

#### `LTreeView:getNodeDepth`

Returns the nesting depth of the node at the given index (0 for root nodes).

```lua
LTreeView:getNodeDepth(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based node index. |

**Returns**

| Type | Description |
|------|-------------|
| number | The depth, or nil if index is invalid. |

**Example**

```lua
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
```

---

#### `LTreeView:getNodeText`

Returns the text of the node at the given 1-based index.

```lua
LTreeView:getNodeText(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based node index. |

**Returns**

| Type | Description |
|------|-------------|
| string | The node text, or nil if the index is invalid. |

**Example**

```lua
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
```

---

#### `LTreeView:getParentNode`

Returns the 1-based index of the parent of the node at the given index.

```lua
LTreeView:getParentNode(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based node index. |

**Returns**

| Type | Description |
|------|-------------|
| number | The parent node index, or nil for root nodes. |

**Example**

```lua
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
```

---

#### `LTreeView:getSelectedNode`

Returns the 1-based index of the currently selected node.

```lua
LTreeView:getSelectedNode()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The selected node index, or nil if none. |

**Example**

```lua
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
```

---

#### `LTreeView:isExpanded`

Returns whether the node at the given 1-based index is currently expanded.

```lua
LTreeView:isExpanded(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based node index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if expanded. |

**Example**

```lua
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
```

---

#### `LTreeView:isNodeExpanded`

Returns whether the node at the given 1-based index is expanded. Returns nil if the index is invalid.

```lua
LTreeView:isNodeExpanded(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based node index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if expanded, false if collapsed, nil if invalid. |

**Example**

```lua
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
```

---

#### `LTreeView:removeNode`

Removes the node at the given 1-based index from this tree view.

```lua
LTreeView:removeNode(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based node index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the node was removed. |

**Example**

```lua
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
```

---

#### `LTreeView:setNodeIcon`

Sets the icon of the node at the given 1-based index.

```lua
LTreeView:setNodeIcon(index, icon)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based node index. |
| `icon` | string | The icon identifier string. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the icon was set. |

**Example**

```lua
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
```

---

#### `LTreeView:setNodeText`

Sets the text of the node at the given 1-based index.

```lua
LTreeView:setNodeText(index, text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based node index. |
| `text` | string | The new node text. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the node text was set. |

**Example**

```lua
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
```

---

#### `LTreeView:setSelectedNode`

Sets the selected node by 1-based index.

```lua
LTreeView:setSelectedNode(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based node index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the node was selected. |

**Example**

```lua
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
```

---

#### `LTreeView:toggleNode`

Toggles the expanded/collapsed state of the node at the given 1-based index.

```lua
LTreeView:toggleNode(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | The 1-based node index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the node is now expanded, false if collapsed. |

**Example**

```lua
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
```

---

## LUiWidget

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LUiWidget:addChild`

Adds a child widget to this widget's hierarchy.

```lua
LUiWidget:addChild(child)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `child` | [LUiWidget](#luiwidget)|number | The child widget table or widget index to add. |

**Example**

```lua
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
```

---

#### `LUiWidget:animateAlpha`

Smoothly animates this widget's opacity toward a target value over the given duration.

```lua
LUiWidget:animateAlpha(target, duration, hide_on_complete)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | number | Target alpha value (0.0 to 1.0). |
| `duration?` | number | Animation duration in seconds. Defaults to 0.2. |
| `hide_on_complete?` | boolean | If true, hides the widget when alpha reaches 0. |

**Returns**

| Type | Description |
|------|-------------|
| table | Table result returned by this call. |

**Example**

```lua
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
```

---

#### `LUiWidget:animatePosition`

Smoothly animates this widget's position toward the target coordinates.

```lua
LUiWidget:animatePosition(x, y, duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Target x position. |
| `y` | number | Target y position. |
| `duration?` | number | Animation duration in seconds. Defaults to 0.2. |

**Returns**

| Type | Description |
|------|-------------|
| table | Table result returned by this call. |

**Example**

```lua
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
```

---

#### `LUiWidget:attachToEntity`

Attaches this widget to a game entity so it follows the entity's position on screen.

```lua
LUiWidget:attachToEntity(entity_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `entity_id` | number | The entity ID to attach to. |

**Example**

```lua
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
```

---

#### `LUiWidget:bind`

Binds this widget to a data key for use with update_bindings.

```lua
LUiWidget:bind(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | The binding key name. |

**Example**

```lua
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
```

---

#### `LUiWidget:cancelAnimations`

Cancels all active animations on this widget, leaving it at its current state.

```lua
LUiWidget:cancelAnimations()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if any animations were cancelled. |

**Example**

```lua
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
```

---

#### `LUiWidget:clearAnchor`

Removes all anchor constraints from this widget.

```lua
LUiWidget:clearAnchor()
```

**Example**

```lua
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
```

---

#### `LUiWidget:clearFont`

Clears any font override on this widget so it inherits from its parent again.

```lua
LUiWidget:clearFont()
```

**Example**

```lua
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
```

---

#### `LUiWidget:clearIcon`

Clears this widget's assigned built-in icon.

```lua
LUiWidget:clearIcon()
```

**Example**

```lua
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
```

---

#### `LUiWidget:containsPoint`

Tests whether the given screen-space point is inside this widget's bounds.

```lua
LUiWidget:containsPoint(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate in screen pixels. |
| `y` | number | Y coordinate in screen pixels. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the point is within the widget. |

**Example**

```lua
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
```

---

#### `LUiWidget:detachFromEntity`

Detaches this widget from any previously attached entity.

```lua
LUiWidget:detachFromEntity()
```

**Example**

```lua
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
```

---

#### `LUiWidget:fadeIn`

Instantly makes this widget fully opaque and visible.

```lua
LUiWidget:fadeIn()
```

**Example**

```lua
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
```

---

#### `LUiWidget:fadeOut`

Instantly makes this widget fully transparent and hidden.

```lua
LUiWidget:fadeOut()
```

**Example**

```lua
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
```

---

#### `LUiWidget:findById`

Searches this widget's subtree for a child with the given ID.

```lua
LUiWidget:findById(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | The widget ID to search for. |

**Returns**

| Type | Description |
|------|-------------|
| [LWidget](terminal.md#lwidget) | The found widget table, or nil if not found. |

**Example**

```lua
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
```

---

#### `LUiWidget:getAlpha`

Returns the current opacity of this widget.

```lua
LUiWidget:getAlpha()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The alpha value between 0.0 and 1.0. |

**Example**

```lua
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
```

---

#### `LUiWidget:getAriaName`

Returns the explicit accessible name metadata for this widget.

```lua
LUiWidget:getAriaName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The stored accessible name, or an empty string when unset. |

**Example**

```lua
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
```

---

#### `LUiWidget:getChildCount`

Returns the number of direct child widgets attached to this widget.

```lua
LUiWidget:getChildCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The child count. |

**Example**

```lua
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
```

---

#### `LUiWidget:getChildren`

Returns a table of lightweight child widget references, each containing an _idx field.

```lua
LUiWidget:getChildren()
```

**Returns**

| Type | Description |
|------|-------------|
| LUiWidgetGetChildrenResult | Array of child widget tables. |

**Example**

```lua
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
```

---

#### `LUiWidget:getFlexGrow`

Returns the flex-grow factor of this widget.

```lua
LUiWidget:getFlexGrow()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The grow factor. |

**Example**

```lua
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
```

---

#### `LUiWidget:getFlexShrink`

Returns the flex-shrink factor of this widget.

```lua
LUiWidget:getFlexShrink()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The shrink factor. |

**Example**

```lua
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
```

---

#### `LUiWidget:getIcon`

Returns this widget's assigned built-in icon name, or nil when no icon is assigned.

```lua
LUiWidget:getIcon()
```

**Returns**

| Type | Description |
|------|-------------|
| string | nil | The assigned icon name. |

**Example**

```lua
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
```

---

#### `LUiWidget:getIconPosition`

Returns this widget's icon placement token.

```lua
LUiWidget:getIconPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| string | One of "left", "right", "top", "bottom", or "only". |

**Example**

```lua
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
```

---

#### `LUiWidget:getIconSize`

Returns this widget's requested icon size in pixels.

```lua
LUiWidget:getIconSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Pixel size; 0 means the widget font size is used. |

**Example**

```lua
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
```

---

#### `LUiWidget:getId`

Returns the string identifier assigned to this widget.

```lua
LUiWidget:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The widget ID, or an empty string if none was set. |

**Example**

```lua
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
```

---

#### `LUiWidget:getLabelFor`

Returns the widget index associated through `setLabelFor`, or nil.

```lua
LUiWidget:getLabelFor()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The linked widget index. |

**Example**

```lua
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
```

---

#### `LUiWidget:getMargin`

Returns the outer margin of this widget.

```lua
LUiWidget:getMargin()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Top; right; bottom; and left margin in pixels. (value 1). |
| number | Top; right; bottom; and left margin in pixels. (value 2). |
| number | Top; right; bottom; and left margin in pixels. (value 3). |
| number | Top; right; bottom; and left margin in pixels. (value 4). |

**Example**

```lua
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
```

---

#### `LUiWidget:getMaxSize`

Returns the maximum width and height of this widget.

```lua
LUiWidget:getMaxSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Maximum width and height in pixels. (value 1). |
| number | Maximum width and height in pixels. (value 2). |

**Example**

```lua
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
```

---

#### `LUiWidget:getMinSize`

Returns the minimum width and height of this widget.

```lua
LUiWidget:getMinSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Minimum width and height in pixels. (value 1). |
| number | Minimum width and height in pixels. (value 2). |

**Example**

```lua
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
```

---

#### `LUiWidget:getMouseFilter`

Returns the mouse filter of this widget.

```lua
LUiWidget:getMouseFilter()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The mouse filter type. |

**Example**

```lua
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
```

---

#### `LUiWidget:getPadding`

Returns the inner padding of this widget.

```lua
LUiWidget:getPadding()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Top; right; bottom; and left padding in pixels. (value 1). |
| number | Top; right; bottom; and left padding in pixels. (value 2). |
| number | Top; right; bottom; and left padding in pixels. (value 3). |
| number | Top; right; bottom; and left padding in pixels. (value 4). |

**Example**

```lua
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
```

---

#### `LUiWidget:getPosition`

Returns the local position of this widget relative to its parent.

```lua
LUiWidget:getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The x and y coordinates in pixels. (value 1). |
| number | The x and y coordinates in pixels. (value 2). |

**Example**

```lua
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
```

---

#### `LUiWidget:getRect`

Returns the computed bounding rectangle of this widget in screen coordinates after layout.

```lua
LUiWidget:getRect()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The x; y; width; and height of the computed rect. (value 1). |
| number | The x; y; width; and height of the computed rect. (value 2). |
| number | The x; y; width; and height of the computed rect. (value 3). |
| number | The x; y; width; and height of the computed rect. (value 4). |

**Example**

```lua
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
```

---

#### `LUiWidget:getRole`

Returns the semantic role string for this widget.

```lua
LUiWidget:getRole()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The configured or default semantic role. |

**Example**

```lua
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
```

---

#### `LUiWidget:getSize`

Returns the width and height of this widget.

```lua
LUiWidget:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The width and height in pixels. (value 1). |
| number | The width and height in pixels. (value 2). |

**Example**

```lua
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
```

---

#### `LUiWidget:getState`

Returns the current interaction state of this widget (e.g. "normal", "hovered", "pressed", "disabled").

```lua
LUiWidget:getState()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The widget state name. |

**Example**

```lua
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
```

---

#### `LUiWidget:getStyleClass`

Returns the style class of this widget.

```lua
LUiWidget:getStyleClass()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The style class name, or an empty string if none is set. |

**Example**

```lua
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
```

---

#### `LUiWidget:getTextAlign`

Returns this widget's horizontal text alignment.

```lua
LUiWidget:getTextAlign()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Horizontal alignment: "left", "center", or "right". |

**Example**

```lua
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
```

---

#### `LUiWidget:getTooltip`

Returns the tooltip text of this widget.

```lua
LUiWidget:getTooltip()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The tooltip text, or an empty string if none is set. |

**Example**

```lua
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
```

---

#### `LUiWidget:getZOrder`

Returns the z-order (draw priority) of this widget.

```lua
LUiWidget:getZOrder()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The z-order value. |

**Example**

```lua
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
```

---

#### `LUiWidget:isAnimating`

Returns whether this widget currently has an active animation.

```lua
LUiWidget:isAnimating()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if an animation is in progress. |

**Example**

```lua
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
```

---

#### `LUiWidget:isEnabled`

Returns whether this widget is currently enabled and can receive input.

```lua
LUiWidget:isEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the widget is enabled. |

**Example**

```lua
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
```

---

#### `LUiWidget:isVisible`

Returns whether this widget is currently visible.

```lua
LUiWidget:isVisible()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the widget is visible. |

**Example**

```lua
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
```

---

#### `LUiWidget:removeChild`

Removes a child widget from this widget's hierarchy.

```lua
LUiWidget:removeChild(child)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `child` | [LUiWidget](#luiwidget)|number | The child widget table or widget index to remove. |

**Example**

```lua
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
```

---

#### `LUiWidget:setAlpha`

Sets the opacity of this widget, clamped to 0.0 (fully transparent) through 1.0 (fully opaque).

```lua
LUiWidget:setAlpha(alpha)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `alpha` | number | The opacity value. |

**Example**

```lua
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
```

---

#### `LUiWidget:setAnchor`

Anchors this widget to its parent's edges. Pass nil for any side to leave it unanchored.

```lua
LUiWidget:setAnchor(left, top, right, bottom)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `left?` | number | Distance from parent's left edge, or nil. |
| `top?` | number | Distance from parent's top edge, or nil. |
| `right?` | number | Distance from parent's right edge, or nil. |
| `bottom?` | number | Distance from parent's bottom edge, or nil. |

**Example**

```lua
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
```

---

#### `LUiWidget:setAnchorCenter`

Centers this widget within its parent using proportional anchor offsets (0.0 to 1.0).

```lua
LUiWidget:setAnchorCenter(cx, cy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx?` | number | Horizontal center fraction (0.5 = centered). |
| `cy?` | number | Vertical center fraction (0.5 = centered). |

**Example**

```lua
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
```

---

#### `LUiWidget:setAriaName`

Sets the accessible name metadata for this widget.

```lua
LUiWidget:setAriaName(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Accessible name value. |

**Example**

```lua
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
```

---

#### `LUiWidget:setBindKey`

Binds this widget to a data key and reports whether the widget exists.

```lua
LUiWidget:setBindKey(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | The binding key name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the widget exists and the binding key was set. |

**Example**

```lua
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
```

---

#### `LUiWidget:setEnabled`

Enables or disables this widget. Disabled widgets appear grayed out and ignore input.

```lua
LUiWidget:setEnabled(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | boolean | True to enable, false to disable. |

**Example**

```lua
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
```

---

#### `LUiWidget:setFlexGrow`

Sets the flex-grow factor controlling how much extra space this widget receives in a layout.

```lua
LUiWidget:setFlexGrow(grow)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `grow` | number | The grow factor (0 = no growth). |

**Example**

```lua
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
```

---

#### `LUiWidget:setFlexShrink`

Sets the flex-shrink factor controlling how much this widget shrinks when layout space is insufficient.

```lua
LUiWidget:setFlexShrink(shrink)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shrink` | number | The shrink factor (0 = no shrinkage). |

**Example**

```lua
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
```

---

#### `LUiWidget:setFocusGroup`

Sets the focus traversal group for this widget.

```lua
LUiWidget:setFocusGroup(group)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group` | string | Focus group name; empty string means the default/global group. |

**Example**

```lua
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
```

---

#### `LUiWidget:setFocusNeighbor`

Sets an explicit directional focus neighbor for this widget.

```lua
LUiWidget:setFocusNeighbor(direction, target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `direction` | string | Neighbor direction: "up", "down", "left", or "right". |
| `target?` | number | Target widget index, or nil to clear the neighbor. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when direction is valid; false otherwise. |

**Example**

```lua
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
```

---

#### `LUiWidget:setFocusable`

Sets whether this widget participates in keyboard focus traversal.

```lua
LUiWidget:setFocusable(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | boolean | True to allow focus traversal; false to skip this widget. |

**Example**

```lua
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
```

---

#### `LUiWidget:setFont`

Assigns a specific font to this widget and its descendants unless overridden further down the tree.

```lua
LUiWidget:setFont(font)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | [LFont](#lfont) | Font handle to use for this widget subtree. |

**Example**

```lua
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
```

---

#### `LUiWidget:setIcon`

Sets this widget's built-in UI icon by semantic name.

```lua
LUiWidget:setIcon(icon)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `icon` | string | Built-in icon name such as "save", "settings", or "inventory". |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the icon exists and was assigned. |

**Example**

```lua
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
```

---

#### `LUiWidget:setIconPosition`

Sets where this widget's icon is placed relative to its text.

```lua
LUiWidget:setIconPosition(position)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `position` | string | One of "left", "right", "top", "bottom", or "only". |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the position string is recognised. |

**Example**

```lua
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
```

---

#### `LUiWidget:setIconSize`

Sets this widget's requested icon size in pixels.

```lua
LUiWidget:setIconSize(size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `size` | number | Pixel size; 0 uses the widget font size. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when size is finite and non-negative. |

**Example**

```lua
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
```

---

#### `LUiWidget:setId`

Assigns a string identifier to this widget for lookup with findById.

```lua
LUiWidget:setId(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | A unique identifier string. |

**Example**

```lua
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
```

---

#### `LUiWidget:setLabelFor`

Associates this label widget with another widget for accessibility naming.

```lua
LUiWidget:setLabelFor(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target?` | number | Target widget index, or nil to clear the link. |

**Example**

```lua
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
```

---

#### `LUiWidget:setMargin`

Sets the outer margin of this widget. Accepts 1 to 4 values (top, right?, bottom?, left?) following CSS shorthand rules.

```lua
LUiWidget:setMargin(top, right, bottom, left)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `top` | number | Top margin in pixels (also used as default for other sides). |
| `right?` | number | Right margin. Defaults to top. |
| `bottom?` | number | Bottom margin. Defaults to top. |
| `left?` | number | Left margin. Defaults to right. |

**Example**

```lua
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
```

---

#### `LUiWidget:setMaxSize`

Sets the maximum allowed width and height for this widget during layout.

```lua
LUiWidget:setMaxSize(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Maximum width in pixels. |
| `h` | number | Maximum height in pixels. |

**Example**

```lua
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
```

---

#### `LUiWidget:setMinSize`

Sets the minimum allowed width and height for this widget during layout.

```lua
LUiWidget:setMinSize(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Minimum width in pixels. |
| `h` | number | Minimum height in pixels. |

**Example**

```lua
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
```

---

#### `LUiWidget:setMouseFilter`

Sets the mouse filter for this widget ("stop", "pass", "ignore").

```lua
LUiWidget:setMouseFilter(filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `filter` | string | The mouse filter type. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True for a valid filter, false when reset to "stop". |

**Example**

```lua
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
```

---

#### `LUiWidget:setOnChange`

Registers a callback function invoked when this widget's value changes.

```lua
LUiWidget:setOnChange(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | function | Callback receiving the widget index as argument. |

**Example**

```lua
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
```

---

#### `LUiWidget:setOnClick`

Registers a callback function invoked when this widget is clicked.

```lua
LUiWidget:setOnClick(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | function | Callback receiving the widget index as argument. |

**Example**

```lua
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
```

---

#### `LUiWidget:setOnDraw`

Registers a custom draw callback for this widget, invoked each frame during the draw pass.

```lua
LUiWidget:setOnDraw(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | function | Callback receiving a rect table {x, y, w, h} with the computed bounds. |

**Example**

```lua
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
```

---

#### `LUiWidget:setPadding`

Sets the inner padding of this widget. Accepts 1 to 4 values (top, right?, bottom?, left?) following CSS shorthand rules.

```lua
LUiWidget:setPadding(top, right, bottom, left)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `top` | number | Top padding in pixels (also used as default for other sides). |
| `right?` | number | Right padding. Defaults to top. |
| `bottom?` | number | Bottom padding. Defaults to top. |
| `left?` | number | Left padding. Defaults to right. |

**Example**

```lua
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
```

---

#### `LUiWidget:setPosition`

Sets the local position of this widget relative to its parent.

```lua
LUiWidget:setPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Horizontal position in pixels. |
| `y` | number | Vertical position in pixels. |

**Example**

```lua
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
```

---

#### `LUiWidget:setRole`

Sets a semantic role string for this widget.

```lua
LUiWidget:setRole(role)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `role` | string | Semantic role name. |

**Example**

```lua
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
```

---

#### `LUiWidget:setSize`

Sets the width and height of this widget in pixels.

```lua
LUiWidget:setSize(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Width in pixels. |
| `h` | number | Height in pixels. |

**Example**

```lua
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
```

---

#### `LUiWidget:setStyleClass`

Sets the style class of this widget.

```lua
LUiWidget:setStyleClass(class)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `class` | string | The style class name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the widget exists and the class was set. |

**Example**

```lua
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
```

---

#### `LUiWidget:setTabIndex`

Sets the tab-order index for this widget.

```lua
LUiWidget:setTabIndex(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | number | Tab-order index. |

**Example**

```lua
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
```

---

#### `LUiWidget:setTextAlign`

Sets the horizontal alignment of text inside this widget.

```lua
LUiWidget:setTextAlign(align)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `align` | string | Horizontal alignment: "left", "center", or "right". |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the alignment string is recognised; false leaves the previous value unchanged. |

**Example**

```lua
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
```

---

#### `LUiWidget:setTextEllipsis`

Enables or disables ellipsis clipping for overflowing single-line text.

```lua
LUiWidget:setTextEllipsis(ellipsis)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ellipsis` | boolean | True to enable ellipsis on overflow. |

**Example**

```lua
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
```

---

#### `LUiWidget:setTextVAlign`

Sets the vertical alignment of text inside this widget.

```lua
LUiWidget:setTextVAlign(align)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `align` | string | Vertical alignment: "top", "middle", or "bottom". |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the alignment string is recognised; false leaves the previous value unchanged. |

**Example**

```lua
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
```

---

#### `LUiWidget:setTextWrap`

Enables or disables word-wrap for text inside this widget.

```lua
LUiWidget:setTextWrap(wrap)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wrap` | boolean | True to wrap text, false for single-line. |

**Example**

```lua
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
```

---

#### `LUiWidget:setTooltip`

Sets the tooltip text shown when the user hovers over this widget.

```lua
LUiWidget:setTooltip(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | The tooltip message. |

**Example**

```lua
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
```

---

#### `LUiWidget:setVisible`

Shows or hides this widget. Hidden widgets are not drawn and do not receive input.

```lua
LUiWidget:setVisible(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | boolean | True to show, false to hide. |

**Example**

```lua
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
```

---

#### `LUiWidget:setZOrder`

Sets the z-order (draw priority) of this widget. Higher values draw on top.

```lua
LUiWidget:setZOrder(z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `z` | number | The z-order integer value. |

**Example**

```lua
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
```

---

#### `LUiWidget:slideIn`

Moves this widget to the given position and makes it visible.

```lua
LUiWidget:slideIn(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Target x position. |
| `y` | number | Target y position. |

**Example**

```lua
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
```

---

#### `LUiWidget:slideOut`

Moves this widget to the given position and hides it.

```lua
LUiWidget:slideOut(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Target x position. |
| `y` | number | Target y position. |

**Example**

```lua
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
```

---

#### `LUiWidget:type`

Returns the type name string of this widget (e.g. "[LButton](#lbutton)", "[LSlider](#lslider)").

```lua
LUiWidget:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The widget type name. |

**Example**

```lua
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
```

---

#### `LUiWidget:typeOf`

Checks whether this widget matches the given type name, including base types "[LWidget](terminal.md#lwidget)" and "Object".

```lua
LUiWidget:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The type name to check against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the widget is of the given type. |

**Example**

```lua
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
```

---

#### `LUiWidget:unbind`

Removes the data binding from this widget.

```lua
LUiWidget:unbind()
```

**Example**

```lua
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
```

---
