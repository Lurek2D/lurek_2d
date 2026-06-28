# Terminal

## Purpose

Grid terminal supporting ANSI formats, syntax highlighting, and cycling tab-completions.

## When To Use

- It treats terminal behavior as an actual interface model rather than as plain text drawing: cells, ANSI parsing, completion, highlighting, editing state, prompt handling, and render helpers cooperate under one system.
- That matters because terminal-like surfaces need cursor movement, history, navigation, scrollback, and structured command input, not only glyph output.
- The grid model gives the module a clear role distinct from ordinary widget UI and makes it suitable for dense dashboards, shells, ASCII-heavy views, and trace-oriented tooling.

## Minimal Example

Example block: `lurek.terminal.newTerminal`

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(80, 24)
    local cols, rows = term:getDimensions()
    local cell_w, cell_h = term:getCellSize()
    local prompt_char = string.char(term:get(1, 1))
    terminal_log("newTerminal grid=" .. cols .. "x" .. rows .. " cell=" .. cell_w .. "x" .. cell_h .. " prompt=" .. prompt_char)
end
```

## Common Patterns

- Start with `lurek.terminal.addCompletion` when exploring this module.
- Start with `lurek.terminal.applyTheme` when exploring this module.
- Start with `lurek.terminal.clearCmdHistory` when exploring this module.
- Start with `lurek.terminal.clearCompletions` when exploring this module.
- Start with `lurek.terminal.cmdHistoryLen` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `terminal` module is the engine's character-grid interface surface for users who want text-mode displays, debug consoles, command panels, or roguelike-style presentation.
- It treats terminal behavior as an actual interface model rather than as plain text drawing: cells, ANSI parsing, completion, highlighting, editing state, prompt handling, and render helpers cooperate under one system.
- That matters because terminal-like surfaces need cursor movement, history, navigation, scrollback, and structured command input, not only glyph output.
- The grid model gives the module a clear role distinct from ordinary widget UI and makes it suitable for dense dashboards, shells, ASCII-heavy views, and trace-oriented tooling.
- Completion, highlighting, prompt handling, and command history make the feature practical for live developer tools as well as for player-facing interfaces that rely on typed interaction.
- The same surface also gives projects a natural place for aligned textual diagnostics, command-driven introspection, and replayable console workflows without building a separate debug UI for every task.
- Cursor-aware editing and scrollback behavior are part of that value too, because terminal surfaces usually need to behave like interactive text tools rather than passive output panes.
- ANSI parsing and style-aware cells broaden the feature from a retro display into a practical runtime console that can show logs, structured status, highlighted feedback, or shell-like results without abandoning the grid model.
- The module is therefore useful for debug consoles, roguelike views, dashboards, and embedded command panels.
- That makes it especially strong when text itself is the interface instead of only the output format.
- Systems can feed or consume text, but `terminal` owns how that interaction becomes an editable, navigable, scrollable, character-grid runtime surface.

This module primarily collaborates with `image`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.terminal.addCompletion`

Registers a candidate string for tab-completion in the shared completion engine.

```lua
lurek.terminal.addCompletion(candidate)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `candidate` | string | The completion candidate to add. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("scan")
    lurek.terminal.addCompletion("status")
    local matches = lurek.terminal.getCompletions("s")
    local next_value = lurek.terminal.nextCompletion("s")
    terminal_log("addCompletion matches=" .. #matches .. " first='" .. tostring(next_value) .. "'")
end
```

---

### `lurek.terminal.applyTheme`

Applies a named color theme to the terminal, setting default foreground and background colors.

```lua
lurek.terminal.applyTheme(terminal, theme)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | [LTerminal](#lterminal) | The terminal to theme. |
| `theme` | string | Theme name: "solarized_dark", "solarized_light", "monokai", "dracula", or "nord". |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = lurek.terminal.newTerminal(40, 12)
    local themes = {"solarized_dark", "monokai", "dracula", "nord", "solarized_light"}
    for _, name in ipairs(themes) do
        lurek.terminal.applyTheme(term, name)
    end
    local cols, rows = term:getDimensions()
    terminal_log("applyTheme cycled " .. #themes .. " themes on " .. cols .. "x" .. rows)
end
```

---

### `lurek.terminal.clearCmdHistory`

Removes all entries from the terminal command history.

```lua
lurek.terminal.clearCmdHistory(terminal)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | [LTerminal](#lterminal) | The terminal to clear. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(36, 10)
    lurek.terminal.pushCmdHistory(term, "status")
    lurek.terminal.pushCmdHistory(term, "dock")
    lurek.terminal.clearCmdHistory(term)
    local count = lurek.terminal.cmdHistoryLen(term)
    terminal_log("clearCmdHistory count=" .. count)
end
```

---

### `lurek.terminal.clearCompletions`

Removes all registered completion candidates from the shared completion engine.

```lua
lurek.terminal.clearCompletions()
```

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("dock")
    lurek.terminal.addCompletion("drop")
    lurek.terminal.clearCompletions()
    local matches = lurek.terminal.getCompletions("d")
    terminal_log("clearCompletions matches=" .. #matches)
end
```

---

### `lurek.terminal.cmdHistoryLen`

Returns the number of commands currently stored in the terminal command history.

```lua
lurek.terminal.cmdHistoryLen(terminal)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | [LTerminal](#lterminal) | The terminal to query. |

**Returns**

| Type | Description |
|------|-------------|
| number | History entry count. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    lurek.terminal.clearCmdHistory(term)
    lurek.terminal.pushCmdHistory(term, "help")
    lurek.terminal.pushCmdHistory(term, "dock")
    local count = lurek.terminal.cmdHistoryLen(term)
    terminal_log("cmdHistoryLen count=" .. count)
end
```

---

### `lurek.terminal.getCompletions`

Returns all completion candidates matching the given prefix string.

```lua
lurek.terminal.getCompletions(prefix)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `prefix` | string | The prefix to match against. |

**Returns**

| Type | Description |
|------|-------------|
| string[] | Matching candidate strings. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("scan")
    lurek.terminal.addCompletion("scope")
    lurek.terminal.addCompletion("status")
    local matches = lurek.terminal.getCompletions("sc")
    terminal_log("getCompletions count=" .. #matches .. " second='" .. tostring(matches[2]) .. "'")
end
```

---

### `lurek.terminal.getMaxCols`

Returns the engine-defined maximum number of columns a terminal grid can have.

```lua
lurek.terminal.getMaxCols()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Maximum column count. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local max_cols = lurek.terminal.getMaxCols()
    local term = lurek.terminal.newTerminal(math.min(80, max_cols), 10)
    local cols, rows = term:getDimensions()
    term:print(1, 3, "width budget active")
    terminal_log("getMaxCols max=" .. max_cols .. " active=" .. cols .. "x" .. rows)
end
```

---

### `lurek.terminal.getMaxRows`

Returns the engine-defined maximum number of rows a terminal grid can have.

```lua
lurek.terminal.getMaxRows()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Maximum row count. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local max_rows = lurek.terminal.getMaxRows()
    local term = lurek.terminal.newTerminal(24, math.min(18, max_rows))
    local cols, rows = term:getDimensions()
    term:print(1, rows, "bottom")
    terminal_log("getMaxRows max=" .. max_rows .. " active=" .. cols .. "x" .. rows)
end
```

---

### `lurek.terminal.getScrollback`

Retrieves a range of lines from the terminal scrollback buffer.

```lua
lurek.terminal.getScrollback(terminal, offset, count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | [LTerminal](#lterminal) | The terminal to read from. |
| `offset` | number | 0-based offset from the newest line. |
| `count` | number | Number of lines to retrieve. |

**Returns**

| Type | Description |
|------|-------------|
| string[] | Scrollback line strings. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(36, 10)
    lurek.terminal.setScrollbackCap(term, 6)
    lurek.terminal.pushScrollback(term, "alpha")
    lurek.terminal.pushScrollback(term, "beta")
    local lines = lurek.terminal.getScrollback(term, 0, 2)
    terminal_log("getScrollback first='" .. tostring(lines[1]) .. "' second='" .. tostring(lines[2]) .. "'")
end
```

---

### `lurek.terminal.newBorder`

Creates a new decorative border widget drawn using box-drawing characters.

```lua
lurek.terminal.newBorder(col, row, width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | number | Column position (1-based). |
| `row` | number | Row position (1-based). |
| `width` | number | Border width in cells. |
| `height` | number | Border height in cells. |

**Returns**

| Type | Description |
|------|-------------|
| [LWidget](#lwidget) | The new border widget. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local border = lurek.terminal.newBorder(1, 1, 26, 9)
    border:setStyle("double")
    border:setTitle("Cargo Hold")
    local style = border:getStyle()
    local title = border:getTitle()
    terminal_log("newBorder style=" .. style .. " title='" .. title .. "'")
end
```

---

### `lurek.terminal.newButton`

Creates a new clickable button widget with the given position, size, and label text.

```lua
lurek.terminal.newButton(col, row, width, height, text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | number | Column position (1-based). |
| `row` | number | Row position (1-based). |
| `width` | number | Button width in cells. |
| `height?` | number | Button height in cells (default 1). |
| `text?` | string | Button label text (default empty). |

**Returns**

| Type | Description |
|------|-------------|
| [LWidget](#lwidget) | The new button widget. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local button = lurek.terminal.newButton(4, 6, 14, 1, "Launch Drone")
    local width, height = button:getSize()
    local enabled = button:isEnabled()
    local text = button:getText()
    terminal_log("newButton '" .. text .. "' size=" .. width .. "x" .. height .. " enabled=" .. tostring(enabled))
end
```

---

### `lurek.terminal.newLabel`

Creates a new label widget that displays static text at the given cell position.

```lua
lurek.terminal.newLabel(col, row, text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | number | Column position (1-based). |
| `row` | number | Row position (1-based). |
| `text?` | string | Initial text (default empty). |

**Returns**

| Type | Description |
|------|-------------|
| [LWidget](#lwidget) | The new label widget. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local label = lurek.terminal.newLabel(3, 2, "Shields 100%")
    local col, row = label:getPosition()
    local text = label:getText()
    local kind = label:type()
    terminal_log("newLabel type=" .. kind .. " text='" .. text .. "' at " .. col .. "," .. row)
end
```

---

### `lurek.terminal.newList`

Creates a new scrollable list widget for displaying and selecting items.

```lua
lurek.terminal.newList(col, row, width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | number | Column position (1-based). |
| `row` | number | Row position (1-based). |
| `width` | number | List width in cells. |
| `height` | number | List height in cells (visible rows). |

**Returns**

| Type | Description |
|------|-------------|
| [LWidget](#lwidget) | The new list widget. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local list = make_inventory_list()
    list:setSelected(2)
    local first = list:getItem(1)
    local selected = list:getSelected()
    local count = list:getItemCount()
    terminal_log("newList items=" .. count .. " first=" .. first .. " selected=" .. selected)
end
```

---

### `lurek.terminal.newPanel`

Creates a new panel widget that can contain child widgets for grouped layout.

```lua
lurek.terminal.newPanel(col, row, width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | number | Column position (1-based). |
| `row` | number | Row position (1-based). |
| `width?` | number | Panel width in cells (default 1). |
| `height?` | number | Panel height in cells (default 1). |

**Returns**

| Type | Description |
|------|-------------|
| [LWidget](#lwidget) | The new panel widget. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local panel, title, footer = make_status_panel()
    local children = panel:getChildCount()
    local header = title:getText()
    local state = footer:getText()
    terminal_log("newPanel children=" .. children .. " header='" .. header .. "' state='" .. state .. "'")
end
```

---

### `lurek.terminal.newTerminal`

Creates a new terminal emulator grid and stages a window size that fits its active cell metrics.

```lua
lurek.terminal.newTerminal(cols, rows)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cols?` | number | Number of columns (default 80). |
| `rows?` | number | Number of rows (default 40). |

**Returns**

| Type | Description |
|------|-------------|
| [LTerminal](#lterminal) | The new terminal object. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(80, 24)
    local cols, rows = term:getDimensions()
    local cell_w, cell_h = term:getCellSize()
    local prompt_char = string.char(term:get(1, 1))
    terminal_log("newTerminal grid=" .. cols .. "x" .. rows .. " cell=" .. cell_w .. "x" .. cell_h .. " prompt=" .. prompt_char)
end
```

---

### `lurek.terminal.newTextBox`

Creates a new single-line text input widget at the given position with a fixed width.

```lua
lurek.terminal.newTextBox(col, row, width)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | number | Column position (1-based). |
| `row` | number | Row position (1-based). |
| `width` | number | Input field width in cells. |

**Returns**

| Type | Description |
|------|-------------|
| [LWidget](#lwidget) | The new text box widget. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local input = lurek.terminal.newTextBox(2, 8, 20)
    input:setText("scan --sector beta")
    input:setMaxLength(32)
    local text = input:getText()
    local max_length = input:getMaxLength()
    terminal_log("newTextBox text='" .. text .. "' max=" .. max_length)
end
```

---

### `lurek.terminal.nextCmd`

Navigates forward in the terminal command history, returning the next command or nil if at the end.

```lua
lurek.terminal.nextCmd(terminal)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | [LTerminal](#lterminal) | The terminal to navigate. |

**Returns**

| Type | Description |
|------|-------------|
| string | The next command, or nil. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(36, 10)
    lurek.terminal.clearCmdHistory(term)
    lurek.terminal.pushCmdHistory(term, "status")
    lurek.terminal.pushCmdHistory(term, "dock")
    lurek.terminal.prevCmd(term)
    terminal_log("nextCmd value='" .. tostring(lurek.terminal.nextCmd(term)) .. "'")
end
```

---

### `lurek.terminal.nextCompletion`

Cycles to the next matching completion candidate for the given prefix, wrapping around after the last match.

```lua
lurek.terminal.nextCompletion(prefix)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `prefix` | string | The prefix to match against. |

**Returns**

| Type | Description |
|------|-------------|
| string | The next matching candidate, or nil if none match. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("scan")
    lurek.terminal.addCompletion("scope")
    local first = lurek.terminal.nextCompletion("sc")
    local second = lurek.terminal.nextCompletion("sc")
    terminal_log("nextCompletion cycled '" .. tostring(first) .. "' then '" .. tostring(second) .. "'")
end
```

---

### `lurek.terminal.parseAnsi`

Parses ANSI escape sequences in a string into an array of span tables with text, bold, fg, and bg fields.

```lua
lurek.terminal.parseAnsi(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | Input string with ANSI codes. |

**Returns**

| Type | Description |
|------|-------------|
| LTerminalParseAnsiResult | Array of span tables: { text=string, bold=boolean, fg?={r,g,b}, bg?={r,g,b} }. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local text = "\27[1m\27[31mALERT\27[0m nominal"
    local spans = lurek.terminal.parseAnsi(text)
    local first = spans[1]
    local second = spans[2]
    local summary = tostring(first and first.text) .. "|" .. tostring(second and second.text)
    terminal_log("parseAnsi span_count=" .. #spans .. " parts=" .. summary)
end
```

---

### `lurek.terminal.prevCmd`

Navigates backward in the terminal command history, returning the previous command or nil if at the start.

```lua
lurek.terminal.prevCmd(terminal)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | [LTerminal](#lterminal) | The terminal to navigate. |

**Returns**

| Type | Description |
|------|-------------|
| string | The previous command, or nil. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(36, 10)
    lurek.terminal.clearCmdHistory(term)
    lurek.terminal.pushCmdHistory(term, "status")
    lurek.terminal.pushCmdHistory(term, "dock")
    local previous = lurek.terminal.prevCmd(term)
    terminal_log("prevCmd value='" .. tostring(previous) .. "'")
end
```

---

### `lurek.terminal.printAnsi`

Renders ANSI-colored text directly onto the terminal grid at the given cell position.

```lua
lurek.terminal.printAnsi(terminal, col, row, text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | [LTerminal](#lterminal) | The terminal to print to. |
| `col` | number | Starting column (1-based). |
| `row` | number | Row to print on (1-based). |
| `text` | string | Text containing ANSI escape sequences. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    local message = "\27[31mERROR\27[0m coolant low"
    lurek.terminal.printAnsi(term, 1, 5, message)
    local first = string.char(term:get(1, 5))
    local second = string.char(term:get(2, 5))
    terminal_log("printAnsi row5 prefix=" .. first .. second)
end
```

---

### `lurek.terminal.printHighlighted`

Renders syntax-highlighted text onto the terminal grid using a table of highlight rules with regex patterns and colors.

```lua
lurek.terminal.printHighlighted(terminal, col, row, text, rules)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | [LTerminal](#lterminal) | The terminal to print to. |
| `col` | number | Starting column (1-based). |
| `row` | number | Row to print on (1-based). |
| `text` | string | The text to highlight. |
| `rules` | table | Array of rule tables, each with `pattern` (string), `fg` (table {r,g,b} 0-255), and optional `bg` (table {r,g,b} 0-255). |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    local rules = {{pattern = "fuel", fg = {255, 196, 0}}, {pattern = "ok", fg = {0, 255, 0}}}
    lurek.terminal.printHighlighted(term, 1, 6, "fuel ok", rules)
    local first = string.char(term:get(1, 6))
    local fifth = string.char(term:get(5, 6))
    terminal_log("printHighlighted row6 prefix=" .. first .. fifth)
end
```

---

### `lurek.terminal.pushCmdHistory`

Appends a command string to the terminal command history for up/down arrow recall.

```lua
lurek.terminal.pushCmdHistory(terminal, cmd)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | [LTerminal](#lterminal) | The terminal to push to. |
| `cmd` | string | The command string to store. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    lurek.terminal.clearCmdHistory(term)
    lurek.terminal.pushCmdHistory(term, "help")
    lurek.terminal.pushCmdHistory(term, "scan sector-beta")
    local previous = lurek.terminal.prevCmd(term)
    terminal_log("pushCmdHistory last='" .. tostring(previous) .. "' len=" .. lurek.terminal.cmdHistoryLen(term))
end
```

---

### `lurek.terminal.pushScrollback`

Appends a line of text to the terminal scrollback buffer for later retrieval.

```lua
lurek.terminal.pushScrollback(terminal, line)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | [LTerminal](#lterminal) | The terminal to push to. |
| `line` | string | The text line to append. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    lurek.terminal.setScrollbackCap(term, 8)
    lurek.terminal.pushScrollback(term, "[ok] reactor stable")
    lurek.terminal.pushScrollback(term, "[ok] path locked")
    local lines = lurek.terminal.getScrollback(term, 0, 10)
    terminal_log("pushScrollback first='" .. tostring(lines[1]) .. "' count=" .. #lines)
end
```

---

### `lurek.terminal.removeCompletion`

Removes a previously registered completion candidate from the shared completion engine.

```lua
lurek.terminal.removeCompletion(candidate)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `candidate` | string | The completion candidate to remove. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("scan")
    lurek.terminal.addCompletion("scope")
    lurek.terminal.removeCompletion("scope")
    local matches = lurek.terminal.getCompletions("sc")
    terminal_log("removeCompletion matches=" .. #matches .. " survivor='" .. tostring(matches[1]) .. "'")
end
```

---

### `lurek.terminal.resetCompletion`

Resets the completion cycling state so the next call to nextCompletion starts from the first match.

```lua
lurek.terminal.resetCompletion()
```

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("scan")
    lurek.terminal.addCompletion("scope")
    local first = lurek.terminal.nextCompletion("sc")
    lurek.terminal.nextCompletion("sc")
    lurek.terminal.resetCompletion()
    terminal_log("resetCompletion restart='" .. tostring(lurek.terminal.nextCompletion("sc")) .. "' first='" .. tostring(first) .. "'")
end
```

---

### `lurek.terminal.scrollbackLen`

Returns the number of lines currently stored in the terminal scrollback buffer.

```lua
lurek.terminal.scrollbackLen(terminal)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | [LTerminal](#lterminal) | The terminal to query. |

**Returns**

| Type | Description |
|------|-------------|
| number | Line count. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(36, 10)
    lurek.terminal.setScrollbackCap(term, 6)
    lurek.terminal.pushScrollback(term, "alpha")
    lurek.terminal.pushScrollback(term, "beta")
    local count = lurek.terminal.scrollbackLen(term)
    terminal_log("scrollbackLen count=" .. count)
end
```

---

### `lurek.terminal.setScrollbackCap`

Sets the maximum number of lines retained in the terminal scrollback buffer. Older lines are discarded when the cap is exceeded.

```lua
lurek.terminal.setScrollbackCap(terminal, cap)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | [LTerminal](#lterminal) | The terminal to configure. |
| `cap` | number | Maximum number of scrollback lines. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    lurek.terminal.setScrollbackCap(term, 2)
    lurek.terminal.pushScrollback(term, "line-1")
    lurek.terminal.pushScrollback(term, "line-2")
    lurek.terminal.pushScrollback(term, "line-3")
    terminal_log("setScrollbackCap kept=" .. lurek.terminal.scrollbackLen(term) .. " line(s)")
end
```

---

### `lurek.terminal.stripAnsi`

Removes all ANSI escape sequences from a string, returning plain text.

```lua
lurek.terminal.stripAnsi(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | Input string with ANSI codes. |

**Returns**

| Type | Description |
|------|-------------|
| string | Clean text without escape sequences. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local raw = "\27[1m\27[32mwarp ready\27[0m now"
    local stripped = lurek.terminal.stripAnsi(raw)
    local term = make_console(36, 8)
    term:print(1, 4, stripped)
    terminal_log("stripAnsi plain='" .. stripped .. "'")
end
```

---

### `lurek.terminal.tryPushCmdHistory`

Strictly appends a command string to the terminal command history.

```lua
lurek.terminal.tryPushCmdHistory(terminal, cmd)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | [LTerminal](#lterminal) | The terminal to push to. |
| `cmd` | string | The command string to store. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True on success; otherwise false and a reason string. (value 1). |
| string | True on success; otherwise false and a reason string. (value 2). |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    lurek.terminal.clearCmdHistory(term)
    local ok, err = lurek.terminal.tryPushCmdHistory(term, "dock")
    terminal_log("tryPushCmdHistory ok=" .. tostring(ok) .. " err=" .. tostring(err))
    terminal_log("tryPushCmdHistory len=" .. tostring(lurek.terminal.cmdHistoryLen(term)))
end
```

---

### `lurek.terminal.tryPushScrollback`

Strictly appends a line of text to the terminal scrollback buffer.

```lua
lurek.terminal.tryPushScrollback(terminal, line)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | [LTerminal](#lterminal) | The terminal to push to. |
| `line` | string | The text line to append. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True on success; otherwise false and a reason string. (value 1). |
| string | True on success; otherwise false and a reason string. (value 2). |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    local ok, err = lurek.terminal.tryPushScrollback(term, "[warn] low coolant")
    terminal_log("tryPushScrollback ok=" .. tostring(ok) .. " err=" .. tostring(err))
    terminal_log("tryPushScrollback len=" .. tostring(lurek.terminal.scrollbackLen(term)))
    terminal_log("tryPushScrollback latest='" .. tostring(lurek.terminal.getScrollback(term, 0, 1)[1]) .. "'")
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LButton](#lbutton)
- [LLabel](#llabel)
- [LList](#llist)
- [LPanel](#lpanel)
- [LTerminal](#lterminal)
- [LWidget](#lwidget)

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

---

## LTerminal

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTerminal:addWidget`

Attaches a widget to this terminal so it is rendered and receives input events.

```lua
LTerminal:addWidget(widget)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `widget` | [LWidget](#lwidget) | The widget to attach. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    local panel = lurek.terminal.newPanel(1, 4, 24, 8)
    local button = lurek.terminal.newButton(3, 6, 12, 1, "Acknowledge")
    term:addWidget(panel)
    term:addWidget(button)
    terminal_log("addWidget count=" .. term:getWidgetCount())
end
```

---

#### `LTerminal:autoResize`

Requests the window to resize so it exactly fits the terminal grid at the current cell size.

```lua
LTerminal:autoResize()
```

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(50, 18)
    term:setCellSize(9, 16)
    term:autoResize()
    local cols, rows = term:getDimensions()
    local w, h = term:getCellSize()
    terminal_log("autoResize fit window for " .. cols .. "x" .. rows .. " using " .. w .. "x" .. h .. " cells")
end
```

---

#### `LTerminal:clear`

Clears all cells in the terminal grid, resetting characters and colors to defaults.

```lua
LTerminal:clear()
```

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(40, 10)
    term:print(1, 6, "temporary warning")
    local before = string.char(term:get(1, 6))
    term:clear()
    local after = string.char(term:get(1, 6))
    terminal_log("clear reset row6 from " .. before .. " to " .. after)
end
```

---

#### `LTerminal:clearDiagnostics`

Clears all terminal diagnostics counters.

```lua
LTerminal:clearDiagnostics()
```

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = lurek.terminal.newTerminal(10, 5)
    term:set(0, 1, "A", 1, 1, 1, 1, 0, 0, 0, 0)
    local before = term:getDiagnostics()
    term:clearDiagnostics()
    local after = term:getDiagnostics()
    terminal_log("clearDiagnostics before=" .. tostring(before.out_of_bounds_writes))
    terminal_log("clearDiagnostics after=" .. tostring(after.out_of_bounds_writes))
end
```

---

#### `LTerminal:clearWidgets`

Removes all attached widgets from this terminal at once.

```lua
LTerminal:clearWidgets()
```

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    term:addWidget(lurek.terminal.newLabel(2, 4, "Engine Temp"))
    term:addWidget(lurek.terminal.newButton(2, 6, 12, 1, "Reset"))
    term:clearWidgets()
    local count = term:getWidgetCount()
    terminal_log("clearWidgets remaining=" .. count)
end
```

---

#### `LTerminal:get`

Reads the character and colors at a specific cell in the terminal grid.

```lua
LTerminal:get(col, row)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | number | Column index (1-based). |
| `row` | number | Row index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | Character codepoint; fg RGBA; bg RGBA. (value 1). |
| number | Character codepoint; fg RGBA; bg RGBA. (value 2). |
| number | Character codepoint; fg RGBA; bg RGBA. (value 3). |
| number | Character codepoint; fg RGBA; bg RGBA. (value 4). |
| number | Character codepoint; fg RGBA; bg RGBA. (value 5). |
| number | Character codepoint; fg RGBA; bg RGBA. (value 6). |
| number | Character codepoint; fg RGBA; bg RGBA. (value 7). |
| number | Character codepoint; fg RGBA; bg RGBA. (value 8). |
| number | Character codepoint; fg RGBA; bg RGBA. (value 9). |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(32, 8)
    term:print(3, 4, "HP 84")
    local ch = term:get(4, 4)
    local ahead = term:get(5, 4)
    local pair = string.char(ch) .. string.char(ahead)
    terminal_log("get status pair=" .. pair)
end
```

---

#### `LTerminal:getCellSize`

Returns the active terminal cell width and height in pixels, using custom override or font metrics.

```lua
LTerminal:getCellSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Cell width and height in pixels. (value 1). |
| number | Cell width and height in pixels. (value 2). |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(30, 8)
    term:setCellSize(12, 20)
    local w, h = term:getCellSize()
    local cols, rows = term:getDimensions()
    terminal_log("getCellSize override=" .. w .. "x" .. h .. " for grid=" .. cols .. "x" .. rows)
end
```

---

#### `LTerminal:getDiagnostics`

Returns the current terminal diagnostics counters.

```lua
LTerminal:getDiagnostics()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Diagnostic counters keyed by counter name. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = lurek.terminal.newTerminal(10, 5)
    local input = lurek.terminal.newTextBox(1, 1, 5)
    input:setMaxLength(3)
    term:addWidget(input)
    term:setFocus(input)
    term:clearDiagnostics()
    term:set(0, 1, "A", 1, 1, 1, 1, 0, 0, 0, 0)
    term:textinput("abcdef")
    local diagnostics = term:getDiagnostics()
    terminal_log("diagnostics oob=" .. tostring(diagnostics.out_of_bounds_writes))
    terminal_log("diagnostics clipped=" .. tostring(diagnostics.clipped_text))
end
```

---

#### `LTerminal:getDimensions`

Returns the number of columns and rows in the terminal grid.

```lua
LTerminal:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Column count; row count. (value 1). |
| number | Column count; row count. (value 2). |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(54, 18)
    local cols, rows = term:getDimensions()
    local cell_w, cell_h = term:getCellSize()
    term:print(1, rows, "footer")
    terminal_log("getDimensions grid=" .. cols .. "x" .. rows .. " cell=" .. cell_w .. "x" .. cell_h)
end
```

---

#### `LTerminal:getFocused`

Returns the widget that currently has keyboard focus, or nil if no widget is focused.

```lua
LTerminal:getFocused()
```

**Returns**

| Type | Description |
|------|-------------|
| [LWidget](#lwidget) | The focused widget, or nil. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    local button = lurek.terminal.newButton(2, 4, 10, 1, "Accept")
    term:addWidget(button)
    term:setFocus(button)
    local focused = term:getFocused()
    local focused_type = focused and focused:type() or "nil"
    terminal_log("getFocused type=" .. focused_type)
end
```

---

#### `LTerminal:getRenderStats`

Returns the most recent render composition stats gathered by terminal render helpers.

```lua
LTerminal:getRenderStats()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Render stats keyed by stat name. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(32, 8)
    local list = make_inventory_list()
    term:addWidget(list)
    term:render()
    local stats = term:getRenderStats()
    terminal_log("render stats cells=" .. tostring(stats.cells_composed))
    terminal_log("render stats widgets=" .. tostring(stats.widgets_drawn))
    terminal_log("render stats list_items=" .. tostring(stats.list_items_drawn))
end
```

---

#### `LTerminal:getShader`

Returns the UI shader bound to this terminal, or nil when default terminal rendering is used.

```lua
LTerminal:getShader()
```

**Returns**

| Type | Description |
|------|-------------|
| [LShader](render.md#lshader)? | Bound shader handle, if any. |

**Example**

```lua
do
    local shader_code = [[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>, @location(3) resolution: vec2<f32>) -> @location(0) vec4<f32> {
    _ = uv;
    let fade = clamp(resolution.x / max(resolution.x, 1.0), 0.0, 1.0);
    return vec4<f32>(color.rgb * fade, color.a);
}
]]
    local shader = lurek.render.newShader(shader_code, { target = "ui" })
    local term = lurek.terminal.newTerminal(32, 6)
    local before = term:getShader()
    term:setShader(shader)
    local after = term:getShader()
    term:print(1, 1, "before=" .. tostring(before))
    term:print(1, 2, "after=" .. after:getTarget())
    term:render(8, 8)
end
```

---

#### `LTerminal:getWidgetCount`

Returns the number of widgets currently attached to this terminal.

```lua
LTerminal:getWidgetCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Widget count. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    term:addWidget(lurek.terminal.newLabel(2, 4, "Engine Temp"))
    term:addWidget(lurek.terminal.newButton(2, 6, 12, 1, "Reset"))
    local count = term:getWidgetCount()
    terminal_log("getWidgetCount total=" .. count)
end
```

---

#### `LTerminal:keypressed`

Forwards a key press event to the terminal for widget input processing.

```lua
LTerminal:keypressed(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | The key name (e.g. "return", "backspace", "left"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the terminal consumed the key event. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    local input = lurek.terminal.newTextBox(2, 4, 20)
    term:addWidget(input)
    term:setFocus(input)
    term:textinput("alpha beta")
    local handled = term:keypressed("ctrl+backspace")
    terminal_log("keypressed handled=" .. tostring(handled) .. " text='" .. input:getText() .. "'")
end
```

---

#### `LTerminal:mousepressed`

Forwards a mouse press event to the terminal, converting pixel coordinates to cell coordinates.

```lua
LTerminal:mousepressed(px, py, button)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `px` | number | Pixel X position of the mouse click. |
| `py` | number | Pixel Y position of the mouse click. |
| `button?` | number | Mouse button index (default 1 for left). |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    local button = lurek.terminal.newButton(2, 4, 14, 1, "Confirm Jump")
    term:addWidget(button)
    click_cell(term, 2, 4, 1)
    local focused = term:getFocused()
    terminal_log("mousepressed focused_button=" .. tostring(focused == button))
end
```

---

#### `LTerminal:print`

Writes text to the terminal grid starting at a specific cell.

```lua
LTerminal:print(col, row, text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | number | Column index (1-based) where writing starts. |
| `row` | number | Row index (1-based) where writing starts. |
| `text` | string | Text to write into consecutive cells. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(40, 10)
    term:print(1, 4, "scan sector beta")
    term:print(1, 5, "fuel line stable")
    local first = string.char(term:get(1, 4))
    local second = string.char(term:get(6, 4))
    terminal_log("print wrote line prefix=" .. first .. second)
end
```

---

#### `LTerminal:removeWidget`

Detaches a widget from this terminal, removing it from rendering and input handling.

```lua
LTerminal:removeWidget(widget)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `widget` | [LWidget](#lwidget) | The widget to detach. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    local button = lurek.terminal.newButton(3, 6, 12, 1, "Acknowledge")
    term:addWidget(lurek.terminal.newLabel(2, 4, "Warning"))
    term:addWidget(button)
    term:removeWidget(button)
    terminal_log("removeWidget remaining=" .. term:getWidgetCount())
end
```

---

#### `LTerminal:render`

Renders the terminal grid and widgets and stages a window size matching the grid and active cell size.

```lua
LTerminal:render(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x?` | number | Screen X offset in pixels (default 0). |
| `y?` | number | Screen Y offset in pixels (default 0). |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(32, 8)
    term:print(1, 7, "rendering diagnostics")
    term:render()
    local cols, rows = term:getDimensions()
    terminal_log("render submitted terminal at " .. cols .. "x" .. rows)
end
```

---

#### `LTerminal:renderImage`

Rasterizes the composed terminal grid and widgets into an `ImageData` preview.

```lua
LTerminal:renderImage(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Output image width in pixels. |
| `height` | number | Output image height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](render.md#limagedata) | Image data containing the terminal cells as colored blocks. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(32, 8)
    term:print(1, 7, "image diagnostics")
    local img = term:renderImage(256, 128)
    local width = img:getWidth()
    local height = img:getHeight()
    terminal_log("renderImage produced " .. width .. "x" .. height .. " image")
end
```

---

#### `LTerminal:resetCellSize`

Removes any custom cell size override, reverting to the active font metrics and refitting the window.

```lua
LTerminal:resetCellSize()
```

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(30, 8)
    term:setCellSize(10, 18)
    term:resetCellSize()
    local w, h = term:getCellSize()
    local cols, rows = term:getDimensions()
    terminal_log("resetCellSize restored cell=" .. w .. "x" .. h .. " for " .. cols .. "x" .. rows)
end
```

---

#### `LTerminal:set`

Writes a character with foreground and background color to a specific cell in the terminal grid.

```lua
LTerminal:set(col, row, ch, fr, fg, fb, fa, br, bg, bb, ba)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | number | Column index (1-based). |
| `row` | number | Row index (1-based). |
| `ch` | string|number | Character as a string or Unicode codepoint. |
| `fr?` | number | Foreground red (0-1, default 1). |
| `fg?` | number | Foreground green (0-1, default 1). |
| `fb?` | number | Foreground blue (0-1, default 1). |
| `fa?` | number | Foreground alpha (0-1, default 1). |
| `br?` | number | Background red (0-1, default 0). |
| `bg?` | number | Background green (0-1, default 0). |
| `bb?` | number | Background blue (0-1, default 0). |
| `ba?` | number | Background alpha (0-1, default 0). |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(32, 8)
    term:set(5, 3, "!", 1, 0.3, 0.2, 1, 0.1, 0.1, 0.1, 1)
    local ch, fr, fg, fb = term:get(5, 3)
    local glyph = string.char(ch)
    terminal_log("set alert glyph=" .. glyph .. " fg=" .. fr .. "," .. fg .. "," .. fb)
end
```

---

#### `LTerminal:setCellSize`

Overrides the cell width and height used for rendering this terminal grid and refits the window.

```lua
LTerminal:setCellSize(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Cell width in pixels. |
| `h` | number | Cell height in pixels. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(30, 8)
    local before_w, before_h = term:getCellSize()
    term:setCellSize(10, 18)
    local after_w, after_h = term:getCellSize()
    terminal_log("setCellSize changed " .. before_w .. "x" .. before_h .. " to " .. after_w .. "x" .. after_h)
end
```

---

#### `LTerminal:setFocus`

Sets which widget currently has keyboard focus, or clears focus when nil is passed.

```lua
LTerminal:setFocus(widget)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `widget?` | [LWidget](#lwidget) | The widget to focus, or nil to clear focus. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    local name_box = lurek.terminal.newTextBox(2, 4, 18)
    local route_box = lurek.terminal.newTextBox(2, 6, 18)
    term:addWidget(name_box)
    term:addWidget(route_box)
    term:setFocus(route_box)
    terminal_log("setFocus route_box=" .. tostring(term:getFocused() == route_box))
end
```

---

#### `LTerminal:setFont`

Selects the nearest built-in bitmap font by pixel height and refits the window to the terminal grid.

```lua
LTerminal:setFont(height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `height` | number | Desired font height in pixels. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(30, 8)
    term:setFont(16)
    local large_w, large_h = term:getCellSize()
    term:setFont(12)
    local small_w, small_h = term:getCellSize()
    terminal_log("setFont 16px=" .. large_w .. "x" .. large_h .. " 12px=" .. small_w .. "x" .. small_h)
end
```

---

#### `LTerminal:setShader`

Binds or clears a render-owned UI shader for this terminal's generated render commands.

```lua
LTerminal:setShader(shader)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shader?` | [LShader](render.md#lshader) | Shader created with `lurek.render.newShader(code, { target = "ui" })`, or nil to clear. |

**Example**

```lua
do
    local shader_code = [[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>, @location(2) pixel: vec2<f32>) -> @location(0) vec4<f32> {
    _ = uv;
    let band = select(0.72, 1.0, (i32(pixel.y) & 1) == 0);
    return vec4<f32>(color.rgb * band + vec3<f32>(0.02, 0.08, 0.06), color.a);
}
]]
    local shader = lurek.render.newShader(shader_code, { target = "ui" })
    local term = lurek.terminal.newTerminal(40, 8)
    term:setShader(shader)
    term:print(1, 1, "terminal ui shader")
    term:print(1, 2, "CRT scanline material")
    term:render(16, 24)
    lurek.log.info("[terminal] setShader target=" .. term:getShader():getTarget())
end
```

---

#### `LTerminal:textinput`

Forwards a text input event to the terminal for character entry into focused widgets.

```lua
LTerminal:textinput(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | The text characters entered. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the terminal consumed the text input. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    local input = lurek.terminal.newTextBox(2, 4, 20)
    term:addWidget(input)
    term:setFocus(input)
    local handled = term:textinput("warp")
    terminal_log("textinput handled=" .. tostring(handled) .. " text='" .. input:getText() .. "'")
end
```

---

#### `LTerminal:trySet`

Strictly writes a character with colors to a specific cell and returns an explicit error string on invalid input.

```lua
LTerminal:trySet(col, row, ch, fr, fg, fb, fa, br, bg, bb, ba)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | number | Column index (1-based). |
| `row` | number | Row index (1-based). |
| `ch` | string|number | Character as a string or Unicode codepoint. |
| `fr?` | number | Foreground red (0-1, default 1). |
| `fg?` | number | Foreground green (0-1, default 1). |
| `fb?` | number | Foreground blue (0-1, default 1). |
| `fa?` | number | Foreground alpha (0-1, default 1). |
| `br?` | number | Background red (0-1, default 0). |
| `bg?` | number | Background green (0-1, default 0). |
| `bb?` | number | Background blue (0-1, default 0). |
| `ba?` | number | Background alpha (0-1, default 0). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True on success; otherwise false and a reason string. (value 1). |
| string | True on success; otherwise false and a reason string. (value 2). |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(32, 8)
    local ok, err = term:trySet(5, 3, "A", 1, 1, 1, 1, 0, 0, 0, 0)
    local bad_ok, bad_err = term:trySet(99, 1, string.byte("A"), 1, 1, 1, 1, 0, 0, 0, 0)
    terminal_log("trySet success=" .. tostring(ok) .. " err=" .. tostring(err))
    terminal_log("trySet invalid=" .. tostring(bad_ok) .. " reason=" .. tostring(bad_err))
end
```

---

#### `LTerminal:type`

Returns the type name string "[LTerminal](#lterminal)".

```lua
LTerminal:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LTerminal](#lterminal)". |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(24, 6)
    local kind = term:type()
    local cols, rows = term:getDimensions()
    term:print(1, 4, "typed console")
    terminal_log("type kind=" .. kind .. " grid=" .. cols .. "x" .. rows)
end
```

---

#### `LTerminal:typeOf`

Checks whether this object matches a given type name. Accepts "[LTerminal](#lterminal)" or "Object".

```lua
LTerminal:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to test against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(24, 6)
    local is_terminal = term:typeOf("LTerminal")
    local is_object = term:typeOf("LObject")
    local cols, rows = term:getDimensions()
    terminal_log("typeOf LTerminal=" .. tostring(is_terminal) .. " LObject=" .. tostring(is_object) .. " grid=" .. cols .. "x" .. rows)
end
```

---

#### `LTerminal:validateWidgets`

Validates panel child ownership, stale references, cycles, and the current focus target.

```lua
LTerminal:validateWidgets()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when valid; otherwise false plus an array of validation messages. (value 1). |
| table | True when valid; otherwise false plus an array of validation messages. (value 2). |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = lurek.terminal.newTerminal(20, 10)
    local panel_a = lurek.terminal.newPanel(1, 1, 10, 4)
    local panel_b = lurek.terminal.newPanel(2, 2, 8, 3)
    local hidden = lurek.terminal.newButton(1, 5, 8, 1, "Hidden")
    hidden:setVisible(false)
    term:addWidget(panel_a)
    term:addWidget(panel_b)
    term:addWidget(hidden)
    term:setFocus(hidden)
    panel_a:addChild(panel_b)
    pcall(function()
        panel_b:addChild(panel_a)
    end)
    local valid, errors = term:validateWidgets()
    terminal_log("validateWidgets valid=" .. tostring(valid))
    terminal_log("validateWidgets errors=" .. tostring(errors and #errors or 0))
end
```

---

## LWidget

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LWidget:addChild`

Adds a child widget to a panel widget. The child becomes part of the panel layout and rendering.

```lua
LWidget:addChild(child)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `child` | [LWidget](#lwidget) | The child widget to add. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local panel = lurek.terminal.newPanel(1, 1, 24, 8)
    local title = lurek.terminal.newLabel(2, 2, "Subsystem")
    local value = lurek.terminal.newLabel(2, 3, "Life Support")
    panel:addChild(title)
    panel:addChild(value)
    terminal_log("addChild children=" .. panel:getChildCount())
end
```

---

#### `LWidget:addItem`

Appends a text item to a list widget.

```lua
LWidget:addItem(item)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `item` | string | The item text to add. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local list = lurek.terminal.newList(1, 1, 18, 5)
    list:addItem("Bandage")
    list:addItem("Ration Pack")
    list:addItem("Access Card")
    local count = list:getItemCount()
    terminal_log("addItem count=" .. count .. " last='" .. tostring(list:getItem(3)) .. "'")
end
```

---

#### `LWidget:clearChildren`

Removes all child widgets from a panel widget.

```lua
LWidget:clearChildren()
```

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local panel = lurek.terminal.newPanel(1, 1, 24, 8)
    panel:addChild(lurek.terminal.newLabel(2, 2, "Subsystem"))
    panel:addChild(lurek.terminal.newLabel(2, 3, "Life Support"))
    panel:clearChildren()
    local count = panel:getChildCount()
    terminal_log("clearChildren count=" .. count)
end
```

---

#### `LWidget:clearItems`

Removes all items from a list widget.

```lua
LWidget:clearItems()
```

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local list = make_inventory_list()
    local before = list:getItemCount()
    list:clearItems()
    local after = list:getItemCount()
    terminal_log("clearItems before=" .. before .. " after=" .. after)
end
```

---

#### `LWidget:getChild`

Returns a child widget from a panel by its 1-based index, or nil if the index is out of range.

```lua
LWidget:getChild(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based child index. |

**Returns**

| Type | Description |
|------|-------------|
| [LWidget](#lwidget) | The child widget, or nil. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local panel, title = make_status_panel()
    local child = panel:getChild(1)
    local text = child and child:getText() or "nil"
    local count = panel:getChildCount()
    terminal_log("getChild count=" .. count .. " first='" .. text .. "' seed='" .. title:getText() .. "'")
end
```

---

#### `LWidget:getChildCount`

Returns the number of child widgets in a panel widget.

```lua
LWidget:getChildCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Child count. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local panel, title, footer = make_status_panel()
    local count = panel:getChildCount()
    local first = title:getText()
    local second = footer:getText()
    terminal_log("getChildCount count=" .. count .. " values='" .. first .. "'/'" .. second .. "'")
end
```

---

#### `LWidget:getColor`

Returns the foreground color of the widget as RGBA components.

```lua
LWidget:getColor()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Red; green; blue; and alpha channels. (value 1). |
| number | Red; green; blue; and alpha channels. (value 2). |
| number | Red; green; blue; and alpha channels. (value 3). |
| number | Red; green; blue; and alpha channels. (value 4). |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local label = lurek.terminal.newLabel(2, 2, "Beacon")
    label:setColor(0.25, 0.5, 0.75, 0.9)
    local r, g, b, a = label:getColor()
    local text = label:getText()
    terminal_log("getColor text='" .. text .. "' rgba=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LWidget:getItem`

Returns the text of a list item by its 1-based index.

```lua
LWidget:getItem(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based item index. |

**Returns**

| Type | Description |
|------|-------------|
| string | The item text. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local list = make_inventory_list()
    list:setSelected(2)
    local first = list:getItem(1)
    local second = list:getItem(2)
    terminal_log("getItem first='" .. tostring(first) .. "' second='" .. tostring(second) .. "'")
end
```

---

#### `LWidget:getItemCount`

Returns the number of items in a list widget.

```lua
LWidget:getItemCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Item count. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local list = make_inventory_list()
    list:addItem("Toolkit")
    local count = list:getItemCount()
    local selected = list:getSelected()
    terminal_log("getItemCount count=" .. count .. " selected=" .. tostring(selected))
end
```

---

#### `LWidget:getMaxLength`

Returns the maximum character limit of a text box widget.

```lua
LWidget:getMaxLength()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Maximum character count. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local box = lurek.terminal.newTextBox(2, 2, 18)
    box:setMaxLength(40)
    box:setText("dock")
    local max_length = box:getMaxLength()
    terminal_log("getMaxLength max=" .. max_length .. " text='" .. box:getText() .. "'")
end
```

---

#### `LWidget:getPosition`

Returns the widget position as 1-based column and row.

```lua
LWidget:getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Column; row. (value 1). |
| number | Column; row. (value 2). |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local list = lurek.terminal.newList(5, 3, 15, 6)
    local col, row = list:getPosition()
    local width, height = list:getSize()
    local count = list:getItemCount()
    terminal_log("getPosition pos=" .. col .. "," .. row .. " size=" .. width .. "x" .. height .. " items=" .. count)
end
```

---

#### `LWidget:getSelected`

Returns the 1-based index of the currently selected list item, or nil if nothing is selected.

```lua
LWidget:getSelected()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Selected item index, or nil. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local list = make_inventory_list()
    list:setSelected(2)
    local selected = list:getSelected()
    local item = list:getItem(selected)
    terminal_log("getSelected index=" .. tostring(selected) .. " item='" .. tostring(item) .. "'")
end
```

---

#### `LWidget:getSize`

Returns the widget dimensions as width and height in cell units.

```lua
LWidget:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width; height. (value 1). |
| number | Width; height. (value 2). |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local list = lurek.terminal.newList(5, 3, 15, 6)
    local width, height = list:getSize()
    local col, row = list:getPosition()
    local count = list:getItemCount()
    terminal_log("getSize size=" .. width .. "x" .. height .. " at " .. col .. "," .. row .. " items=" .. count)
end
```

---

#### `LWidget:getStyle`

Returns the current border style name of a border or panel widget.

```lua
LWidget:getStyle()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The border style name. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local border = lurek.terminal.newBorder(1, 1, 22, 8)
    border:setStyle("double")
    border:setTitle("Cargo")
    local style = border:getStyle()
    terminal_log("getStyle style='" .. style .. "' title='" .. border:getTitle() .. "'")
end
```

---

#### `LWidget:getTag`

Returns the current tag string assigned to the widget.

```lua
LWidget:getTag()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The tag value. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local label = lurek.terminal.newLabel(2, 2, "Objective")
    label:setTag("hud.objective")
    local tag = label:getTag()
    local text = label:getText()
    terminal_log("getTag tag='" .. tag .. "' text='" .. text .. "'")
end
```

---

#### `LWidget:getText`

Returns the current text content of a label, button, or text box widget.

```lua
LWidget:getText()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The widget text. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local box = lurek.terminal.newTextBox(2, 2, 20)
    box:setText("scan cargo bay")
    local text = box:getText()
    local width, height = box:getSize()
    terminal_log("getText text='" .. text .. "' size=" .. width .. "x" .. height)
end
```

---

#### `LWidget:getTitle`

Returns the current title text of a border or panel widget.

```lua
LWidget:getTitle()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The title text. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local border = lurek.terminal.newBorder(1, 1, 22, 8)
    border:setTitle("Mission Log")
    local title = border:getTitle()
    local style = border:getStyle()
    terminal_log("getTitle title='" .. title .. "' style='" .. style .. "'")
end
```

---

#### `LWidget:isEnabled`

Returns whether the widget is currently enabled for user interaction.

```lua
LWidget:isEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if enabled. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local button = lurek.terminal.newButton(2, 2, 12, 1, "Dock")
    local before = button:isEnabled()
    button:setEnabled(false)
    local after = button:isEnabled()
    terminal_log("isEnabled before=" .. tostring(before) .. " after=" .. tostring(after))
end
```

---

#### `LWidget:isVisible`

Returns whether the widget is currently visible.

```lua
LWidget:isVisible()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if visible. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local button = lurek.terminal.newButton(2, 2, 12, 1, "Dock")
    local before = button:isVisible()
    button:setVisible(false)
    local after = button:isVisible()
    terminal_log("isVisible before=" .. tostring(before) .. " after=" .. tostring(after))
end
```

---

#### `LWidget:removeChild`

Removes a child widget from a panel, detaching it from the panel layout.

```lua
LWidget:removeChild(child)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `child` | [LWidget](#lwidget) | The child widget to remove. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local panel = lurek.terminal.newPanel(1, 1, 24, 8)
    local title = lurek.terminal.newLabel(2, 2, "Subsystem")
    local value = lurek.terminal.newLabel(2, 3, "Life Support")
    panel:addChild(title)
    panel:addChild(value)
    panel:removeChild(title)
    terminal_log("removeChild remaining=" .. panel:getChildCount())
end
```

---

#### `LWidget:removeItem`

Removes a list item by its 1-based index.

```lua
LWidget:removeItem(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based item index to remove. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local list = make_inventory_list()
    local before = list:getItemCount()
    list:removeItem(1)
    local after = list:getItemCount()
    local first = list:getItem(1)
    terminal_log("removeItem before=" .. before .. " after=" .. after .. " first='" .. tostring(first) .. "'")
end
```

---

#### `LWidget:setColor`

Sets the foreground color of the widget as RGBA components (0-1 range).

```lua
LWidget:setColor(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a?` | number | Alpha channel (default 1). |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local label = lurek.terminal.newLabel(2, 2, "Beacon")
    label:setColor(0.9, 0.7, 0.2, 1.0)
    local r, g, b, a = label:getColor()
    local text = label:getText()
    terminal_log("setColor text='" .. text .. "' rgba=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LWidget:setEnabled`

Controls whether the widget accepts user interaction (clicks, typing).

```lua
LWidget:setEnabled(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | True to enable, false to disable. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local label = lurek.terminal.newLabel(2, 2, "Beacon")
    label:setEnabled(false)
    local enabled = label:isEnabled()
    label:setEnabled(true)
    terminal_log("setEnabled restored=" .. tostring(label:isEnabled()) .. " initial_after_disable=" .. tostring(enabled))
end
```

---

#### `LWidget:setMaxLength`

Sets the maximum number of characters allowed in a text box widget.

```lua
LWidget:setMaxLength(maxLength)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `maxLength` | number | Maximum character count. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local box = lurek.terminal.newTextBox(2, 2, 18)
    box:setMaxLength(12)
    box:setText("dock alpha")
    local max_length = box:getMaxLength()
    terminal_log("setMaxLength max=" .. max_length .. " text='" .. box:getText() .. "'")
end
```

---

#### `LWidget:setOnChange`

Registers a callback function invoked when the text content of a text box widget changes. Only valid for text box widgets.

```lua
LWidget:setOnChange(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback?` | function | The change handler, or nil to clear. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    local input = lurek.terminal.newTextBox(2, 4, 20)
    local changes = 0
    input:setOnChange(function() changes = changes + 1 end)
    term:addWidget(input)
    term:setFocus(input)
    input:setText("dock")
    terminal_log("setOnChange changes=" .. changes .. " text='" .. input:getText() .. "'")
end
```

---

#### `LWidget:setOnClick`

Registers a callback function invoked when a button widget is clicked. Only valid for button widgets.

```lua
LWidget:setOnClick(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback?` | function | The click handler, or nil to clear. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    local button = lurek.terminal.newButton(2, 4, 14, 1, "Confirm")
    local clicks = 0
    button:setOnClick(function() clicks = clicks + 1 end)
    term:addWidget(button)
    click_cell(term, 2, 4, 1)
    terminal_log("setOnClick clicks=" .. clicks .. " text='" .. button:getText() .. "'")
end
```

---

#### `LWidget:setOnSelect`

Registers a callback function invoked when the selected item in a list widget changes. Only valid for list widgets.

```lua
LWidget:setOnSelect(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback?` | function | The selection handler, or nil to clear. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local list = make_inventory_list()
    local selections = 0
    list:setOnSelect(function() selections = selections + 1 end)
    list:setSelected(2)
    local item = list:getItem(list:getSelected())
    terminal_log("setOnSelect callbacks=" .. selections .. " item='" .. tostring(item) .. "'")
end
```

---

#### `LWidget:setPosition`

Sets the widget position in 1-based cell coordinates within the terminal grid.

```lua
LWidget:setPosition(col, row)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | number | Column index (1-based). |
| `row` | number | Row index (1-based). |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local box = lurek.terminal.newTextBox(1, 1, 18)
    box:setPosition(4, 6)
    local col, row = box:getPosition()
    local width, height = box:getSize()
    terminal_log("setPosition pos=" .. col .. "," .. row .. " size=" .. width .. "x" .. height)
end
```

---

#### `LWidget:setSelected`

Sets the currently selected item in a list widget by 1-based index, or clears the selection with nil. Fires the onSelect callback if changed.

```lua
LWidget:setSelected(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index?` | number | 1-based item index, or nil to clear selection. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local list = make_inventory_list()
    list:setSelected(3)
    local selected = list:getSelected()
    local item = list:getItem(selected)
    terminal_log("setSelected index=" .. tostring(selected) .. " item='" .. tostring(item) .. "'")
end
```

---

#### `LWidget:setSize`

Sets the widget dimensions in cell units, clamped to a minimum of 1x1.

```lua
LWidget:setSize(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Width in cells. |
| `height` | number | Height in cells. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local box = lurek.terminal.newTextBox(1, 1, 18)
    box:setSize(24, 1)
    local width, height = box:getSize()
    local text = box:getText()
    terminal_log("setSize size=" .. width .. "x" .. height .. " text='" .. text .. "'")
end
```

---

#### `LWidget:setStyle`

Sets the border drawing style for a border or panel widget.

```lua
LWidget:setStyle(styleName)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `styleName` | string | Border style name (e.g. "single", "double", "rounded", "heavy", "none"). |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local border = lurek.terminal.newBorder(1, 1, 18, 6)
    border:setStyle("double")
    border:setTitle("Map")
    local style = border:getStyle()
    terminal_log("setStyle style='" .. style .. "' title='" .. border:getTitle() .. "'")
end
```

---

#### `LWidget:setTag`

Assigns an arbitrary string tag to the widget for identification or grouping.

```lua
LWidget:setTag(tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tag` | string | The tag value. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local border = lurek.terminal.newBorder(1, 1, 18, 6)
    border:setTag("hud.map")
    border:setTitle("Map")
    local tag = border:getTag()
    terminal_log("setTag tag='" .. tag .. "' title='" .. border:getTitle() .. "'")
end
```

---

#### `LWidget:setText`

Sets the display text of a label, button, or text box widget. Fires the onChange callback if the text actually changed.

```lua
LWidget:setText(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | The new text content. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local button = lurek.terminal.newButton(2, 2, 14, 1, "Undock")
    button:setText("Engage Warp")
    local text = button:getText()
    local width, height = button:getSize()
    terminal_log("setText text='" .. text .. "' size=" .. width .. "x" .. height)
end
```

---

#### `LWidget:setTitle`

Sets the title text displayed in the border of a border or panel widget.

```lua
LWidget:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | The title text. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local border = lurek.terminal.newBorder(1, 1, 22, 8)
    border:setTitle("Subsystems")
    local title = border:getTitle()
    local style = border:getStyle()
    terminal_log("setTitle title='" .. title .. "' style='" .. style .. "'")
end
```

---

#### `LWidget:setVisible`

Controls whether the widget is drawn and receives input events.

```lua
LWidget:setVisible(visible)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `visible` | boolean | True to show, false to hide. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local label = lurek.terminal.newLabel(2, 2, "Beacon")
    label:setVisible(false)
    local hidden = label:isVisible()
    label:setVisible(true)
    terminal_log("setVisible hidden_state=" .. tostring(hidden) .. " restored=" .. tostring(label:isVisible()))
end
```

---

#### `LWidget:trySetText`

Strictly sets widget text and returns an explicit error string instead of silently truncating.

```lua
LWidget:trySetText(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | The new text content. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True on success; otherwise false and a reason string. (value 1). |
| string | True on success; otherwise false and a reason string. (value 2). |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local input = lurek.terminal.newTextBox(2, 8, 20)
    local ok, err = input:trySetText("reroute convoy")
    terminal_log("trySetText ok=" .. tostring(ok) .. " err=" .. tostring(err))
    terminal_log("trySetText value='" .. tostring(input:getText()) .. "'")
    terminal_log("trySetText max=" .. tostring(input:getMaxLength()))
end
```

---

#### `LWidget:type`

Returns the type name string "[LWidget](#lwidget)".

```lua
LWidget:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LWidget](#lwidget)". |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local button = lurek.terminal.newButton(2, 2, 12, 1, "Dock")
    local kind = button:type()
    local text = button:getText()
    local width, height = button:getSize()
    terminal_log("widget type kind=" .. kind .. " text='" .. text .. "' size=" .. width .. "x" .. height)
end
```

---

#### `LWidget:typeOf`

Checks whether this object matches a given type name. Accepts "[LWidget](#lwidget)" or "Object".

```lua
LWidget:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to test against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches. |

**Example**

```lua
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local button = lurek.terminal.newButton(2, 2, 12, 1, "Dock")
    local is_widget = button:typeOf("LWidget")
    local is_object = button:typeOf("LObject")
    local text = button:getText()
    terminal_log("widget typeOf text='" .. text .. "' LWidget=" .. tostring(is_widget) .. " LObject=" .. tostring(is_object))
end
```

---
