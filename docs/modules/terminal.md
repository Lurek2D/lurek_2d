# Terminal

- The `terminal` module is a sophisticated Feature Systems tier component that provides a full-featured character-grid terminal emulator within the engine.

Originally designed to host the in-game developer console, it functions as a highly versatile UI surface capable of rendering classic ASCII interfaces, roguelike displays, and complex debugging tools. At its foundation, the `Terminal` struct manages a fixed-size grid of cells (`TCell`), each storing a character codepoint alongside independent foreground and background colors. The module implements a robust ANSI escape sequence parser (`ansi.rs`), capable of decoding standard 8-color palettes, 256-color xterm indexes, and 24-bit true-color RGB combinations, enabling seamless integration with existing terminal-based output streams and logging tools.

Beyond raw text rendering, the terminal provides a surprisingly capable immediate-mode widget framework (`widget.rs`). Developers can compose interactive interfaces directly on the character grid using pre-built elements like Buttons, Labels, TextBoxes, Lists, and Panels. These widgets handle their own bounds checking, input routing, and rendering (complete with ASCII border drawing and shaded backgrounds). To support command-line workflows, the module includes a `CompletionEngine` for context-aware tab completion, a persistent command history buffer for quick recall, and a scrollback buffer that gracefully evicts the oldest lines when capacity is reached. For specialized display needs—such as the interactive Lua REPL (`lurek.repl`)—the module integrates a regex-driven `highlighter.rs` that applies token-based syntax coloring to code inputs in real-time.

The rendering pipeline bridges the gap between the character grid and the engine's graphical backend. The terminal state is efficiently composited and flattened into batched `RenderCommand` sequences, mapped directly to loaded bitmap fonts for pixel-perfect display. The terminal can also software-rasterize its grid directly into an `ImageData` buffer, useful for generating preview thumbnails or headless output. Fully accessible via the `lurek.terminal.*` API, this module is an invaluable tool for building in-game developer tools, specialized text-based mini-games, and deeply interactive console environments.

## Functions

### `lurek.terminal.addCompletion`

Registers a candidate string for tab-completion in the shared completion engine.

```lua
-- signature
lurek.terminal.addCompletion(candidate)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `candidate` | `string` | The completion candidate to add. |

**Example**

```lua
do
    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("help")
    lurek.terminal.addCompletion("health")
    lurek.terminal.addCompletion("heal")
    lurek.terminal.addCompletion("inventory")
    lurek.terminal.addCompletion("inspect")
    local matches = lurek.terminal.getCompletions("he")
    print("matches for 'he': " .. table.concat(matches, ", "))
    local inv = lurek.terminal.getCompletions("in")
    print("matches for 'in' = " .. #inv)
end
```

---

### `lurek.terminal.applyTheme`

Applies a named color theme to the terminal, setting default foreground and background colors.

```lua
-- signature
lurek.terminal.applyTheme(terminal, theme)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | `LTerminal` | The terminal to theme. |
| `theme` | `string` | Theme name: "solarized_dark", "solarized_light", "monokai", "dracula", or "nord". |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(80, 25)
    lurek.terminal.applyTheme(term, "solarized_dark")
    print("applied solarized_dark")
    lurek.terminal.applyTheme(term, "monokai")
    print("applied monokai")
    lurek.terminal.applyTheme(term, "dracula")
    print("applied dracula")
    lurek.terminal.applyTheme(term, "nord")
    print("applied nord")
    lurek.terminal.applyTheme(term, "solarized_light")
    print("applied solarized_light")
end
```

---

### `lurek.terminal.clearCmdHistory`

Removes all entries from the terminal command history.

```lua
-- signature
lurek.terminal.clearCmdHistory(terminal)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | `LTerminal` | The terminal to clear. |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(40, 10)
    lurek.terminal.clearCmdHistory(term)
    local prev = lurek.terminal.prevCmd(term)
    print("prev_cmd=" .. tostring(prev))
    local next_cmd = lurek.terminal.nextCmd(term)
    print("next_cmd=" .. tostring(next_cmd))
end
```

---

### `lurek.terminal.clearCompletions`

Removes all registered completion candidates from the shared completion engine.

```lua
-- signature
lurek.terminal.clearCompletions()
```

**Example**

```lua
do
    lurek.terminal.addCompletion("help")
    lurek.terminal.addCompletion("heal")
    lurek.terminal.clearCompletions()
    local completions = lurek.terminal.getCompletions("he")
    print("completion count = " .. #completions)
end
```

---

### `lurek.terminal.cmdHistoryLen`

Returns the number of commands currently stored in the terminal command history.

```lua
-- signature
lurek.terminal.cmdHistoryLen(terminal)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | `LTerminal` | The terminal to query. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | History entry count. |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(80, 25)
    lurek.terminal.pushCmdHistory(term, "look")
    lurek.terminal.pushCmdHistory(term, "go north")
    lurek.terminal.pushCmdHistory(term, "take sword")
    print("history len = " .. lurek.terminal.cmdHistoryLen(term))
    lurek.terminal.clearCmdHistory(term)
    print("after clear len = " .. lurek.terminal.cmdHistoryLen(term))
end
```

---

### `lurek.terminal.getCompletions`

Returns all completion candidates matching the given prefix string.

```lua
-- signature
lurek.terminal.getCompletions(prefix)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `prefix` | `string` | The prefix to match against. |

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Matching candidate strings. |

**Example**

```lua
do
    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("help")
    lurek.terminal.addCompletion("heal")
    lurek.terminal.addCompletion("hex")
    local completions = lurek.terminal.getCompletions("he")
    print("matches = " .. #completions)
    print("first match = " .. tostring(completions[1]))
end
```

---

### `lurek.terminal.getMaxCols`

Returns the engine-defined maximum number of columns a terminal grid can have.

```lua
-- signature
lurek.terminal.getMaxCols()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Maximum column count. |

**Example**

```lua
do
    local maxCols = lurek.terminal.getMaxCols()
    print("max cols = " .. maxCols)
end
```

---

### `lurek.terminal.getMaxRows`

Returns the engine-defined maximum number of rows a terminal grid can have.

```lua
-- signature
lurek.terminal.getMaxRows()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Maximum row count. |

**Example**

```lua
do
    local maxRows = lurek.terminal.getMaxRows()
    local maxCols = lurek.terminal.getMaxCols()
    print("max rows = " .. maxRows)
    print("max cols = " .. maxCols)
end
```

---

### `lurek.terminal.getScrollback`

Retrieves a range of lines from the terminal scrollback buffer.

```lua
-- signature
lurek.terminal.getScrollback(terminal, offset, count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | `LTerminal` | The terminal to read from. |
| `offset` | `number` | 0-based offset from the newest line. |
| `count` | `number` | Number of lines to retrieve. |

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Scrollback line strings. |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(40, 10)
    lurek.terminal.pushScrollback(term, "line one")
    lurek.terminal.pushScrollback(term, "line two")
    lurek.terminal.pushScrollback(term, "line three")
    local sb = lurek.terminal.getScrollback(term, 0, 5)
    print("scrollback count=" .. #sb)
    print("first line=" .. tostring(sb[1]))
end
```

---

### `lurek.terminal.newBorder`

Creates a new decorative border widget drawn using box-drawing characters.

```lua
-- signature
lurek.terminal.newBorder(col, row, width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `number` | Column position (1-based). |
| `row` | `number` | Row position (1-based). |
| `width` | `number` | Border width in cells. |
| `height` | `number` | Border height in cells. |

**Returns**

| Type | Description |
|------|-------------|
| `LWidget` | The new border widget. |

**Example**

```lua
do
    local border = lurek.terminal.newBorder(1, 1, 30, 10)
    print("border style = " .. border:getStyle())
    border:setStyle("double")
    print("new style = " .. border:getStyle())
    border:setTitle("Inventory")
    print("title = " .. border:getTitle())
end
```

---

### `lurek.terminal.newButton`

Creates a new clickable button widget with the given position, size, and label text.

```lua
-- signature
lurek.terminal.newButton(col, row, width, height, text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `number` | Column position (1-based). |
| `row` | `number` | Row position (1-based). |
| `width` | `number` | Button width in cells. |
| `height?` | `number` | Button height in cells (default 1). |
| `text?` | `string` | Button label text (default empty). |

**Returns**

| Type | Description |
|------|-------------|
| `LWidget` | The new button widget. |

**Example**

```lua
do
    local clickCount = 0
    local btn = lurek.terminal.newButton(10, 5, 12, 1, "Click Me")
    print("button text = " .. btn:getText())
    local w, h = btn:getSize()
    print("button size = " .. w .. "x" .. h)
    btn:setOnClick(function()
        clickCount = clickCount + 1
        print("clicked! count = " .. clickCount)
    end)
    print("click handler set")
end
```

---

### `lurek.terminal.newLabel`

Creates a new label widget that displays static text at the given cell position.

```lua
-- signature
lurek.terminal.newLabel(col, row, text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `number` | Column position (1-based). |
| `row` | `number` | Row position (1-based). |
| `text?` | `string` | Initial text (default empty). |

**Returns**

| Type | Description |
|------|-------------|
| `LWidget` | The new label widget. |

**Example**

```lua
do
    local label = lurek.terminal.newLabel(5, 3, "Score: 0")
    local col, row = label:getPosition()
    print("label type = " .. label:type() .. " is LWidget = " .. tostring(label:typeOf("LWidget")))
    print("text = " .. label:getText() .. " position = " .. col .. ", " .. row)
    label:setText("Score: 1500")
    print("updated text = " .. label:getText())
end
```

---

### `lurek.terminal.newList`

Creates a new scrollable list widget for displaying and selecting items.

```lua
-- signature
lurek.terminal.newList(col, row, width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `number` | Column position (1-based). |
| `row` | `number` | Row position (1-based). |
| `width` | `number` | List width in cells. |
| `height` | `number` | List height in cells (visible rows). |

**Returns**

| Type | Description |
|------|-------------|
| `LWidget` | The new list widget. |

**Example**

```lua
do
    local list = lurek.terminal.newList(2, 3, 20, 8)
    list:addItem("Sword")
    list:addItem("Shield")
    list:addItem("Potion")
    list:addItem("Scroll")
    list:addItem("Bow")
    print("item count = " .. list:getItemCount() .. " item 1 = " .. list:getItem(1) .. " item 3 = " .. list:getItem(3))
    list:setSelected(2)
    print("selected = " .. list:getSelected())
    list:setOnSelect(function() print("selection changed to " .. list:getSelected()) end)
end
```

---

### `lurek.terminal.newPanel`

Creates a new panel widget that can contain child widgets for grouped layout.

```lua
-- signature
lurek.terminal.newPanel(col, row, width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `number` | Column position (1-based). |
| `row` | `number` | Row position (1-based). |
| `width?` | `number` | Panel width in cells (default 1). |
| `height?` | `number` | Panel height in cells (default 1). |

**Returns**

| Type | Description |
|------|-------------|
| `LWidget` | The new panel widget. |

**Example**

```lua
do
    local panel = lurek.terminal.newPanel(1, 1, 40, 20)
    panel:addChild(lurek.terminal.newLabel(2, 2, "Name:"))
    panel:addChild(lurek.terminal.newLabel(2, 3, "Class:"))
    print("panel children = " .. panel:getChildCount())
    local child1 = panel:getChild(1)
    print("child 1 text = " .. child1:getText())
end
```

---

### `lurek.terminal.newTerminal`

Creates a new terminal emulator grid and stages a window size that fits its active cell metrics.

```lua
-- signature
lurek.terminal.newTerminal(cols, rows)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cols?` | `number` | Number of columns (default 80). |
| `rows?` | `number` | Number of rows (default 40). |

**Returns**

| Type | Description |
|------|-------------|
| `LTerminal` | The new terminal object. |

**Example**

```lua
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 40)
    print("type = " .. term:type())
    local cols, rows = term:getDimensions()
    print("dimensions = " .. cols .. "x" .. rows)
end
```

---

### `lurek.terminal.newTextBox`

Creates a new single-line text input widget at the given position with a fixed width.

```lua
-- signature
lurek.terminal.newTextBox(col, row, width)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `number` | Column position (1-based). |
| `row` | `number` | Row position (1-based). |
| `width` | `number` | Input field width in cells. |

**Returns**

| Type | Description |
|------|-------------|
| `LWidget` | The new text box widget. |

**Example**

```lua
do
    local input = lurek.terminal.newTextBox(5, 8, 20)
    print("input text = '" .. input:getText() .. "'")
    input:setText("Hello")
    print("set text = " .. input:getText())
    input:setMaxLength(30)
    print("max length = " .. input:getMaxLength())
    input:setOnChange(function() print("text changed to: " .. input:getText()) end)
end
```

---

### `lurek.terminal.nextCmd`

Navigates forward in the terminal command history, returning the next command or nil if at the end.

```lua
-- signature
lurek.terminal.nextCmd(terminal)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | `LTerminal` | The terminal to navigate. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | The next command, or nil. |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(40, 10)
    lurek.terminal.pushCmdHistory(term, "north")
    lurek.terminal.pushCmdHistory(term, "east")
    print("prev_cmd=" .. tostring(lurek.terminal.prevCmd(term)))
    local next_cmd = lurek.terminal.nextCmd(term)
    print("next_cmd=" .. tostring(next_cmd))
end
```

---

### `lurek.terminal.nextCompletion`

Cycles to the next matching completion candidate for the given prefix, wrapping around after the last match.

```lua
-- signature
lurek.terminal.nextCompletion(prefix)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `prefix` | `string` | The prefix to match against. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | The next matching candidate, or nil if none match. |

**Example**

```lua
do
    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("attack")
    lurek.terminal.addCompletion("attune")
    lurek.terminal.addCompletion("attract")
    lurek.terminal.resetCompletion()
    local c1 = lurek.terminal.nextCompletion("att")
    print("cycle 1 = " .. tostring(c1))
    local c2 = lurek.terminal.nextCompletion("att")
    print("cycle 2 = " .. tostring(c2))
    local c3 = lurek.terminal.nextCompletion("att")
    print("cycle 3 = " .. tostring(c3))
end
```

---

### `lurek.terminal.parseAnsi`

Parses ANSI escape sequences in a string into an array of span tables with text, bold, fg, and bg fields.

```lua
-- signature
lurek.terminal.parseAnsi(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | Input string with ANSI codes. |

**Returns**

| Type | Description |
|------|-------------|
| `TerminalParseAnsiResult` | Array of span tables: { text=string, bold=boolean, fg?={r,g,b}, bg?={r,g,b} }. |

**Example**

```lua
do
    local ansiText = "\27[1;31mError:\27[0m File not found"
    local spans = lurek.terminal.parseAnsi(ansiText)
    print("span count = " .. #spans)
    if spans[1] then print("span 1: text='" .. spans[1].text .. "' bold=" .. tostring(spans[1].bold)) end
end
```

---

### `lurek.terminal.prevCmd`

Navigates backward in the terminal command history, returning the previous command or nil if at the start.

```lua
-- signature
lurek.terminal.prevCmd(terminal)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | `LTerminal` | The terminal to navigate. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | The previous command, or nil. |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(40, 10)
    lurek.terminal.pushCmdHistory(term, "look")
    lurek.terminal.pushCmdHistory(term, "take key")
    lurek.terminal.clearCmdHistory(term)
    local prev = lurek.terminal.prevCmd(term)
    print("prev_cmd=" .. tostring(prev))
end
```

---

### `lurek.terminal.printAnsi`

Renders ANSI-colored text directly onto the terminal grid at the given cell position.

```lua
-- signature
lurek.terminal.printAnsi(terminal, col, row, text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | `LTerminal` | The terminal to print to. |
| `col` | `number` | Starting column (1-based). |
| `row` | `number` | Row to print on (1-based). |
| `text` | `string` | Text containing ANSI escape sequences. |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(80, 25)
    lurek.terminal.printAnsi(term, 1, 1, "\27[1;33mWarning:\27[0m Low health")
    lurek.terminal.printAnsi(term, 1, 2, "\27[34mInfo:\27[0m Checkpoint saved")
    lurek.terminal.printAnsi(term, 1, 3, "\27[1;31mCritical:\27[0m System failure")
    print("ANSI text rendered to grid")
end
```

---

### `lurek.terminal.printHighlighted`

Renders syntax-highlighted text onto the terminal grid using a table of highlight rules with regex patterns and colors.

```lua
-- signature
lurek.terminal.printHighlighted(terminal, col, row, text, rules)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | `LTerminal` | The terminal to print to. |
| `col` | `number` | Starting column (1-based). |
| `row` | `number` | Row to print on (1-based). |
| `text` | `string` | The text to highlight. |
| `rules` | `table` | Array of rule tables, each with `pattern` (string), `fg` (table {r,g,b} 0-255), and optional `bg` (table {r,g,b} 0-255). |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(80, 25)
    local rules = { { pattern = "local%s+%w+", fg = { r = 100, g = 150, b = 255 } }, { pattern = '\"[^\"]*\"', fg = { r = 200, g = 200, b = 100 } }, { pattern = "%-%-%s.*$", fg = { r = 100, g = 100, b = 100 } }, { pattern = "%d+", fg = { r = 255, g = 150, b = 50 } } }
    local code = 'local name = "hero" -- player name'
    lurek.terminal.printHighlighted(term, 1, 1, code, rules)
    print("highlighted code rendered")
end
```

---

### `lurek.terminal.pushCmdHistory`

Appends a command string to the terminal command history for up/down arrow recall.

```lua
-- signature
lurek.terminal.pushCmdHistory(terminal, cmd)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | `LTerminal` | The terminal to push to. |
| `cmd` | `string` | The command string to store. |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(80, 25)
    lurek.terminal.pushCmdHistory(term, "status")
    lurek.terminal.pushCmdHistory(term, "inventory")
    local prev = lurek.terminal.prevCmd(term)
    print("prev 1 = " .. tostring(prev))
    prev = lurek.terminal.prevCmd(term)
    print("prev 2 = " .. tostring(prev))
    local next_cmd = lurek.terminal.nextCmd(term)
    print("next = " .. tostring(next_cmd))
end
```

---

### `lurek.terminal.pushScrollback`

Appends a line of text to the terminal scrollback buffer for later retrieval.

```lua
-- signature
lurek.terminal.pushScrollback(terminal, line)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | `LTerminal` | The terminal to push to. |
| `line` | `string` | The text line to append. |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(80, 25)
    lurek.terminal.pushScrollback(term, "You see a dark corridor.")
    lurek.terminal.pushScrollback(term, "A torch flickers on the wall.")
    lurek.terminal.pushScrollback(term, "You hear footsteps.")
    lurek.terminal.pushScrollback(term, "An enemy appears!")
    print("scrollback len = " .. lurek.terminal.scrollbackLen(term))
    local lines = lurek.terminal.getScrollback(term, 0, 3)
    print("recent 3 lines: " .. table.concat(lines, " | "))
end
```

---

### `lurek.terminal.removeCompletion`

Removes a previously registered completion candidate from the shared completion engine.

```lua
-- signature
lurek.terminal.removeCompletion(candidate)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `candidate` | `string` | The completion candidate to remove. |

**Example**

```lua
do
    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("test_completion")
    lurek.terminal.addCompletion("test_other")
    lurek.terminal.removeCompletion("test_completion")
    local completions = lurek.terminal.getCompletions("test")
    print("remaining completions = " .. #completions)
    print("first completion = " .. tostring(completions[1]))
end
```

---

### `lurek.terminal.resetCompletion`

Resets the completion cycling state so the next call to nextCompletion starts from the first match.

```lua
-- signature
lurek.terminal.resetCompletion()
```

**Example**

```lua
do
    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("test_completion")
    lurek.terminal.addCompletion("test_case")
    print("first = " .. tostring(lurek.terminal.nextCompletion("test")))
    lurek.terminal.resetCompletion()
    print("after reset = " .. tostring(lurek.terminal.nextCompletion("test")))
end
```

---

### `lurek.terminal.scrollbackLen`

Returns the number of lines currently stored in the terminal scrollback buffer.

```lua
-- signature
lurek.terminal.scrollbackLen(terminal)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | `LTerminal` | The terminal to query. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Line count. |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(40, 10)
    lurek.terminal.pushScrollback(term, "alpha")
    lurek.terminal.pushScrollback(term, "beta")
    local sb_len = lurek.terminal.scrollbackLen(term)
    print("scrollback_len=" .. sb_len)
end
```

---

### `lurek.terminal.setScrollbackCap`

Sets the maximum number of lines retained in the terminal scrollback buffer. Older lines are discarded when the cap is exceeded.

```lua
-- signature
lurek.terminal.setScrollbackCap(terminal, cap)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terminal` | `LTerminal` | The terminal to configure. |
| `cap` | `number` | Maximum number of scrollback lines. |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(80, 25)
    lurek.terminal.setScrollbackCap(term, 2)
    lurek.terminal.pushScrollback(term, "Line 1")
    lurek.terminal.pushScrollback(term, "Line 2")
    lurek.terminal.pushScrollback(term, "Line 3")
    print("scrollback after overflow = " .. lurek.terminal.scrollbackLen(term))
end
```

---

### `lurek.terminal.stripAnsi`

Removes all ANSI escape sequences from a string, returning plain text.

```lua
-- signature
lurek.terminal.stripAnsi(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | Input string with ANSI codes. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Clean text without escape sequences. |

**Example**

```lua
do
    local colored = "\27[32mSuccess\27[0m: Operation complete"
    local plain = lurek.terminal.stripAnsi(colored)
    print("stripped = " .. plain)
    print("length original = " .. #colored)
    print("length stripped = " .. #plain)
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

---

## LTerminal

### `LTerminal:addWidget`

Attaches a widget to this terminal so it is rendered and receives input events.

```lua
-- signature
LTerminal:addWidget(widget)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `widget` | `LWidget` | The widget to attach. |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(60, 20)
    term:addWidget(lurek.terminal.newLabel(1, 1, "Status"))
    term:addWidget(lurek.terminal.newButton(1, 3, 10, 1, "OK"))
    print("widget count = " .. term:getWidgetCount())
end
```

---

### `LTerminal:autoResize`

Requests the window to resize so it exactly fits the terminal grid at the current cell size.

```lua
-- signature
LTerminal:autoResize()
```

**Example**

```lua
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(60, 20)
    term:autoResize()
    print("auto-resized window to fit grid")
end
```

---

### `LTerminal:clear`

Clears all cells in the terminal grid, resetting characters and colors to defaults.

```lua
-- signature
LTerminal:clear()
```

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(40, 10)
    term:print(1, 1, "This will be erased")
    term:print(1, 2, "And this too")
    term:clear()
    local ch = term:get(1, 1)
    print("after clear ch = " .. ch)
end
```

---

### `LTerminal:clearWidgets`

Removes all attached widgets from this terminal at once.

```lua
-- signature
LTerminal:clearWidgets()
```

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(60, 20)
    term:addWidget(lurek.terminal.newLabel(1, 1, "Status"))
    term:addWidget(lurek.terminal.newButton(1, 3, 10, 1, "OK"))
    print("widget count = " .. term:getWidgetCount())
    term:clearWidgets()
    print("after clear = " .. term:getWidgetCount())
end
```

---

### `LTerminal:get`

Reads the character and colors at a specific cell in the terminal grid.

```lua
-- signature
LTerminal:get(col, row)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `number` | Column index (1-based). |
| `row` | `number` | Row index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Character codepoint, fg RGBA, bg RGBA. |
| `number` | b Character codepoint, fg RGBA, bg RGBA. |
| `number` | c Character codepoint, fg RGBA, bg RGBA. |
| `number` | d Character codepoint, fg RGBA, bg RGBA. |
| `number` | e Character codepoint, fg RGBA, bg RGBA. |
| `number` | f Character codepoint, fg RGBA, bg RGBA. |
| `number` | g Character codepoint, fg RGBA, bg RGBA. |
| `number` | h Character codepoint, fg RGBA, bg RGBA. |
| `number` | i Character codepoint, fg RGBA, bg RGBA. |

**Example**

```lua
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    term:set(1, 1, "H", 1, 1, 1, 1, 0, 0, 0, 0)
    local ch, fr, fg, fb, fa, br, bg, bb, ba = term:get(1, 1)
    print("cell(1,1) ch=" .. ch .. " fg=(" .. fr .. "," .. fg .. "," .. fb .. ")")
end
```

---

### `LTerminal:getCellSize`

Returns the active terminal cell width and height in pixels, using custom override or font metrics.

```lua
-- signature
LTerminal:getCellSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Cell width and height in pixels. |
| `number` | b Cell width and height in pixels. |

**Example**

```lua
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    term:setCellSize(12, 20)
    local w, h = term:getCellSize()
    print("custom cell = " .. w .. "x" .. h)
end
```

---

### `LTerminal:getDimensions`

Returns the number of columns and rows in the terminal grid.

```lua
-- signature
LTerminal:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Column count, row count. |
| `number` | b Column count, row count. |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(80, 24)
    local cols, rows = term:getDimensions()
    print("cols=" .. cols .. " rows=" .. rows)
end
```

---

### `LTerminal:getFocused`

Returns the widget that currently has keyboard focus, or nil if no widget is focused.

```lua
-- signature
LTerminal:getFocused()
```

**Returns**

| Type | Description |
|------|-------------|
| `LWidget` | The focused widget, or nil. |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(60, 20)
    term:addWidget(lurek.terminal.newTextBox(1, 1, 15))
    local input2 = lurek.terminal.newTextBox(1, 3, 15)
    term:addWidget(input2)
    term:setFocus(input2)
    local focused = term:getFocused()
    print("focused = " .. tostring(focused == input2))
    term:setFocus(nil)
    focused = term:getFocused()
    print("no focus = " .. tostring(focused == nil))
end
```

---

### `LTerminal:getWidgetCount`

Returns the number of widgets currently attached to this terminal.

```lua
-- signature
LTerminal:getWidgetCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Widget count. |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(60, 20)
    term:addWidget(lurek.terminal.newLabel(1, 1, "Status"))
    term:addWidget(lurek.terminal.newButton(1, 3, 10, 1, "OK"))
    print("widget count = " .. term:getWidgetCount())
end
```

---

### `LTerminal:keypressed`

Forwards a key press event to the terminal for widget input processing.

```lua
-- signature
LTerminal:keypressed(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `string` | The key name (e.g. "return", "backspace", "left"). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the terminal consumed the key event. |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(60, 20)
    local input = lurek.terminal.newTextBox(1, 1, 20)
    term:addWidget(input)
    term:setFocus(input)
    local consumed = term:textinput("A")
    print("textinput consumed = " .. tostring(consumed))
    consumed = term:keypressed("backspace")
    print("keypressed consumed = " .. tostring(consumed))
    term:mousepressed(50, 10, 1)
    print("mousepressed sent")
end
```

---

### `LTerminal:mousepressed`

Forwards a mouse press event to the terminal, converting pixel coordinates to cell coordinates.

```lua
-- signature
LTerminal:mousepressed(px, py, button)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `px` | `number` | Pixel X position of the mouse click. |
| `py` | `number` | Pixel Y position of the mouse click. |
| `button?` | `number` | Mouse button index (default 1 for left). |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(60, 20)
    local input = lurek.terminal.newTextBox(1, 1, 20)
    term:addWidget(input)
    term:setFocus(input)
    term:mousepressed(50, 10, 1)
    print("mousepressed sent")
end
```

---

### `LTerminal:print`

Writes text to the terminal grid starting at a specific cell.

```lua
-- signature
LTerminal:print(col, row, text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `number` | Column index (1-based) where writing starts. |
| `row` | `number` | Row index (1-based) where writing starts. |
| `text` | `string` | Text to write into consecutive cells. |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(60, 20)
    term:print(1, 1, "Hello, Terminal!")
    term:print(1, 2, "Line two here")
    term:print(5, 5, "Centered text at col 5, row 5")
    term:print(1, 20, "Bottom row")
    local ch = term:get(1, 1)
    print("printed first cell = " .. tostring(ch))
end
```

---

### `LTerminal:removeWidget`

Detaches a widget from this terminal, removing it from rendering and input handling.

```lua
-- signature
LTerminal:removeWidget(widget)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `widget` | `LWidget` | The widget to detach. |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(60, 20)
    local btn = lurek.terminal.newButton(1, 3, 10, 1, "OK")
    term:addWidget(lurek.terminal.newLabel(1, 1, "Status"))
    term:addWidget(btn)
    print("widget count = " .. term:getWidgetCount())
    term:removeWidget(btn)
    print("after remove = " .. term:getWidgetCount())
end
```

---

### `LTerminal:render`

Renders the terminal grid and widgets and stages a window size matching the grid and active cell size.

```lua
-- signature
LTerminal:render(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x?` | `number` | Screen X offset in pixels (default 0). |
| `y?` | `number` | Screen Y offset in pixels (default 0). |

**Example**

```lua
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(60, 20)
    term:print(1, 1, "Rendering test")
    term:render()
    print("rendered at default pos")
end
```

---

### `LTerminal:resetCellSize`

Removes any custom cell size override, reverting to the active font metrics and refitting the window.

```lua
-- signature
LTerminal:resetCellSize()
```

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(80, 25)
    term:setCellSize(12, 20)
    term:resetCellSize()
    local w, h = term:getCellSize()
    print("reset cell = " .. w .. "x" .. h)
end
```

---

### `LTerminal:set`

Writes a character with foreground and background color to a specific cell in the terminal grid.

```lua
-- signature
LTerminal:set(col, row, ch, fr, fg, fb, fa, br, bg, bb, ba)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `number` | Column index (1-based). |
| `row` | `number` | Row index (1-based). |
| `ch` | `string|number` | Character as a string or Unicode codepoint. |
| `fr?` | `number` | Foreground red (0-1, default 1). |
| `fg?` | `number` | Foreground green (0-1, default 1). |
| `fb?` | `number` | Foreground blue (0-1, default 1). |
| `fa?` | `number` | Foreground alpha (0-1, default 1). |
| `br?` | `number` | Background red (0-1, default 0). |
| `bg?` | `number` | Background green (0-1, default 0). |
| `bb?` | `number` | Background blue (0-1, default 0). |
| `ba?` | `number` | Background alpha (0-1, default 0). |

**Example**

```lua
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    term:set(1, 1, "H", 1, 1, 1, 1, 0, 0, 0, 0)
    local ch, fr, fg, fb, fa, br, bg, bb, ba = term:get(1, 1)
    print("cell(1,1) ch=" .. ch .. " fg=(" .. fr .. "," .. fg .. "," .. fb .. ")")
end
```

---

### `LTerminal:setCellSize`

Overrides the cell width and height used for rendering this terminal grid and refits the window.

```lua
-- signature
LTerminal:setCellSize(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Cell width in pixels. |
| `h` | `number` | Cell height in pixels. |

**Example**

```lua
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    term:setCellSize(12, 20)
    print("cell size set")
end
```

---

### `LTerminal:setFocus`

Sets which widget currently has keyboard focus, or clears focus when nil is passed.

```lua
-- signature
LTerminal:setFocus(widget)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `widget?` | `LWidget` | The widget to focus, or nil to clear focus. |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(60, 20)
    local input1 = lurek.terminal.newTextBox(1, 1, 15)
    term:addWidget(input1)
    term:addWidget(lurek.terminal.newTextBox(1, 3, 15))
    term:setFocus(input1)
    local focused = term:getFocused()
    print("focused = " .. tostring(focused == input1))
    term:setFocus(nil)
    focused = term:getFocused()
    print("no focus = " .. tostring(focused == nil))
end
```

---

### `LTerminal:setFont`

Selects the nearest built-in bitmap font by pixel height and refits the window to the terminal grid.

```lua
-- signature
LTerminal:setFont(height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `height` | `number` | Desired font height in pixels. |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(80, 25)
    term:setFont(16)
    local w, h = term:getCellSize()
    print("font 16: cell = " .. w .. "x" .. h)
    term:setFont(12)
    w, h = term:getCellSize()
    print("font 12: cell = " .. w .. "x" .. h)
end
```

---

### `LTerminal:textinput`

Forwards a text input event to the terminal for character entry into focused widgets.

```lua
-- signature
LTerminal:textinput(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | The text characters entered. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the terminal consumed the text input. |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(60, 20)
    local input = lurek.terminal.newTextBox(1, 1, 20)
    term:addWidget(input)
    term:setFocus(input)
    local consumed = term:textinput("A")
    print("textinput consumed = " .. tostring(consumed))
end
```

---

### `LTerminal:type`

Returns the type name string "LTerminal".

```lua
-- signature
LTerminal:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LTerminal". |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(80, 24)
    print("type=" .. term:type())
end
```

---

### `LTerminal:typeOf`

Checks whether this object matches a given type name. Accepts "LTerminal" or "Object".

```lua
-- signature
LTerminal:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to test against. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches. |

**Example**

```lua
do
    local term = lurek.terminal.newTerminal(80, 24)
    print("typeOf=" .. tostring(term:typeOf("LTerminal")))
end
```

---

## LWidget

### `LWidget:addChild`

Adds a child widget to a panel widget. The child becomes part of the panel layout and rendering.

```lua
-- signature
LWidget:addChild(child)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `child` | `LWidget` | The child widget to add. |

**Example**

```lua
do
    local panel = lurek.terminal.newPanel(0, 0, 40, 20)
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "OK")
    panel:addChild(btn)
    local count = panel:getChildCount()
    print("child count = " .. count)
    print("first child type = " .. panel:getChild(1):type())
end
```

---

### `LWidget:addItem`

Appends a text item to a list widget.

```lua
-- signature
LWidget:addItem(item)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `item` | `string` | The item text to add. |

**Example**

```lua
do
    local list = lurek.terminal.newList(0, 0, 20, 10)
    list:addItem("item one")
    list:addItem("item two")
    print("item count = " .. list:getItemCount())
end
```

---

### `LWidget:clearChildren`

Removes all child widgets from a panel widget.

```lua
-- signature
LWidget:clearChildren()
```

**Example**

```lua
do
    local panel = lurek.terminal.newPanel(0, 0, 40, 20)
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "X")
    panel:addChild(btn)
    panel:addChild(lurek.terminal.newLabel(1, 3, "Info"))
    panel:clearChildren()
    print("child count after clear = " .. panel:getChildCount())
end
```

---

### `LWidget:clearItems`

Removes all items from a list widget.

```lua
-- signature
LWidget:clearItems()
```

**Example**

```lua
do
    local list = lurek.terminal.newList(0, 0, 20, 10)
    list:addItem("alpha")
    list:addItem("beta")
    list:clearItems()
    print("item count after clear = " .. list:getItemCount())
end
```

---

### `LWidget:getChild`

Returns a child widget from a panel by its 1-based index, or nil if the index is out of range.

```lua
-- signature
LWidget:getChild(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | 1-based child index. |

**Returns**

| Type | Description |
|------|-------------|
| `LWidget` | The child widget, or nil. |

**Example**

```lua
do
    local panel = lurek.terminal.newPanel(0, 0, 40, 20)
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "OK")
    panel:addChild(btn)
    local child = panel:getChild(1)
    print("child exists = " .. tostring(child ~= nil))
    print("child type = " .. tostring(child and child:type()))
end
```

---

### `LWidget:getChildCount`

Returns the number of child widgets in a panel widget.

```lua
-- signature
LWidget:getChildCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Child count. |

**Example**

```lua
do
    local panel = lurek.terminal.newPanel(0, 0, 40, 20)
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "OK")
    panel:addChild(btn)
    panel:addChild(lurek.terminal.newLabel(1, 3, "Hint"))
    local count = panel:getChildCount()
    print("child count = " .. count)
end
```

---

### `LWidget:getColor`

Returns the foreground color of the widget as RGBA components.

```lua
-- signature
LWidget:getColor()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Red, green, blue, and alpha channels. |
| `number` | b Red, green, blue, and alpha channels. |
| `number` | c Red, green, blue, and alpha channels. |
| `number` | d Red, green, blue, and alpha channels. |

**Example**

```lua
do
    local label = lurek.terminal.newLabel(0, 0, "Tag")
    label:setColor(255, 200, 100, 255)
    local r, g, b, a = label:getColor()
    print("color = " .. r .. ", " .. g .. ", " .. b .. ", " .. a)
end
```

---

### `LWidget:getItem`

Returns the text of a list item by its 1-based index.

```lua
-- signature
LWidget:getItem(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | 1-based item index. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | The item text. |

**Example**

```lua
do
    local list = lurek.terminal.newList(0, 0, 20, 10)
    list:addItem("alpha")
    list:addItem("beta")
    local item = list:getItem(1)
    print("first item = " .. item)
end
```

---

### `LWidget:getItemCount`

Returns the number of items in a list widget.

```lua
-- signature
LWidget:getItemCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Item count. |

**Example**

```lua
do
    local list = lurek.terminal.newList(0, 0, 20, 10)
    list:addItem("alpha")
    list:addItem("beta")
    local count = list:getItemCount()
    print("item count = " .. count)
end
```

---

### `LWidget:getMaxLength`

Returns the maximum character limit of a text box widget.

```lua
-- signature
LWidget:getMaxLength()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Maximum character count. |

**Example**

```lua
do
    local tb = lurek.terminal.newTextBox(0, 0, 20)
    tb:setMaxLength(32)
    local maxLen = tb:getMaxLength()
    print("max length = " .. maxLen)
end
```

---

### `LWidget:getPosition`

Returns the widget position as 1-based column and row.

```lua
-- signature
LWidget:getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Column, row. |
| `number` | b Column, row. |

**Example**

```lua
do
    local list = lurek.terminal.newList(5, 3, 15, 8)
    local px, py = list:getPosition()
    print("position = " .. px .. ", " .. py)
end
```

---

### `LWidget:getSelected`

Returns the 1-based index of the currently selected list item, or nil if nothing is selected.

```lua
-- signature
LWidget:getSelected()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Selected item index, or nil. |

**Example**

```lua
do
    local list = lurek.terminal.newList(5, 3, 15, 8)
    list:addItem("opt1")
    list:addItem("opt2")
    list:setSelected(1)
    local sel = list:getSelected()
    print("selected = " .. sel)
end
```

---

### `LWidget:getSize`

Returns the widget dimensions as width and height in cell units.

```lua
-- signature
LWidget:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Width, height. |
| `number` | b Width, height. |

**Example**

```lua
do
    local list = lurek.terminal.newList(5, 3, 15, 8)
    local w, h = list:getSize()
    print("size = " .. w .. "x" .. h)
end
```

---

### `LWidget:getStyle`

Returns the current border style name of a border or panel widget.

```lua
-- signature
LWidget:getStyle()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The border style name. |

**Example**

```lua
do
    local border = lurek.terminal.newBorder(0, 1, 10, 3)
    border:setStyle("single")
    local style = border:getStyle()
    print("style = " .. style)
end
```

---

### `LWidget:getTag`

Returns the current tag string assigned to the widget.

```lua
-- signature
LWidget:getTag()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The tag value. |

**Example**

```lua
do
    local border = lurek.terminal.newBorder(0, 1, 10, 3)
    border:setTag("my_border")
    local tag = border:getTag()
    print("tag = " .. tag)
end
```

---

### `LWidget:getText`

Returns the current text content of a label, button, or text box widget.

```lua
-- signature
LWidget:getText()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The widget text. |

**Example**

```lua
do
    local tb = lurek.terminal.newTextBox(0, 0, 20)
    tb:setText("hello")
    local txt = tb:getText()
    print("text = " .. txt)
end
```

---

### `LWidget:getTitle`

Returns the current title text of a border or panel widget.

```lua
-- signature
LWidget:getTitle()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The title text. |

**Example**

```lua
do
    local border = lurek.terminal.newBorder(0, 1, 20, 3)
    border:setTitle("Input")
    local title = border:getTitle()
    print("title = " .. title)
end
```

---

### `LWidget:isEnabled`

Returns whether the widget is currently enabled for user interaction.

```lua
-- signature
LWidget:isEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if enabled. |

**Example**

```lua
do
    local btn = lurek.terminal.newButton(0, 0, 10, 1, "Test")
    print("before = " .. tostring(btn:isEnabled()))
    btn:setEnabled(false)
    print("after = " .. tostring(btn:isEnabled()))
end
```

---

### `LWidget:isVisible`

Returns whether the widget is currently visible.

```lua
-- signature
LWidget:isVisible()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if visible. |

**Example**

```lua
do
    local btn = lurek.terminal.newButton(0, 0, 10, 1, "Test")
    print("before = " .. tostring(btn:isVisible()))
    btn:setVisible(false)
    print("after = " .. tostring(btn:isVisible()))
end
```

---

### `LWidget:removeChild`

Removes a child widget from a panel, detaching it from the panel layout.

```lua
-- signature
LWidget:removeChild(child)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `child` | `LWidget` | The child widget to remove. |

**Example**

```lua
do
    local panel = lurek.terminal.newPanel(0, 0, 40, 20)
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "X")
    panel:addChild(btn)
    panel:removeChild(btn)
    print("child count after remove = " .. panel:getChildCount())
end
```

---

### `LWidget:removeItem`

Removes a list item by its 1-based index.

```lua
-- signature
LWidget:removeItem(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | 1-based item index to remove. |

**Example**

```lua
do
    local list = lurek.terminal.newList(0, 0, 20, 8)
    list:addItem("remove_me")
    list:addItem("keep_me")
    list:removeItem(1)
    print("remaining count = " .. list:getItemCount())
    print("first item = " .. tostring(list:getItem(1)))
end
```

---

### `LWidget:setColor`

Sets the foreground color of the widget as RGBA components (0-1 range).

```lua
-- signature
LWidget:setColor(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red channel. |
| `g` | `number` | Green channel. |
| `b` | `number` | Blue channel. |
| `a?` | `number` | Alpha channel (default 1). |

**Example**

```lua
do
    local label = lurek.terminal.newLabel(0, 0, "Styled")
    label:setColor(255, 200, 100, 255)
    local r, g, b, a = label:getColor()
    print("setColor = " .. r .. ", " .. g .. ", " .. b .. ", " .. a)
end
```

---

### `LWidget:setEnabled`

Controls whether the widget accepts user interaction (clicks, typing).

```lua
-- signature
LWidget:setEnabled(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | `boolean` | True to enable, false to disable. |

**Example**

```lua
do
    local label = lurek.terminal.newLabel(0, 0, "Styled")
    label:setEnabled(false)
    print("setEnabled = " .. tostring(label:isEnabled()))
end
```

---

### `LWidget:setMaxLength`

Sets the maximum number of characters allowed in a text box widget.

```lua
-- signature
LWidget:setMaxLength(maxLength)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `maxLength` | `number` | Maximum character count. |

**Example**

```lua
do
    local tb = lurek.terminal.newTextBox(0, 0, 20)
    tb:setMaxLength(50)
    local ml = tb:getMaxLength()
    print("setMaxLength = " .. ml)
end
```

---

### `LWidget:setOnChange`

Registers a callback function invoked when the text content of a text box widget changes. Only valid for text box widgets.

```lua
-- signature
LWidget:setOnChange(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback?` | `function` | The change handler, or nil to clear. |

**Example**

```lua
do
    local tb = lurek.terminal.newTextBox(0, 0, 20)
    tb:setOnChange(function(text)
        print("changed to " .. tostring(text))
    end)
    tb:setText("hello")
    print("text box length = " .. #tb:getText())
end
```

---

### `LWidget:setOnClick`

Registers a callback function invoked when a button widget is clicked. Only valid for button widgets.

```lua
-- signature
LWidget:setOnClick(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback?` | `function` | The click handler, or nil to clear. |

**Example**

```lua
do
    local btn = lurek.terminal.newButton(0, 0, 10, 1, "Click")
    btn:setOnClick(function() print("clicked") end)
    print("button text = " .. btn:getText())
end
```

---

### `LWidget:setOnSelect`

Registers a callback function invoked when the selected item in a list widget changes. Only valid for list widgets.

```lua
-- signature
LWidget:setOnSelect(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback?` | `function` | The selection handler, or nil to clear. |

**Example**

```lua
do
    local list = lurek.terminal.newList(0, 0, 20, 8)
    list:addItem("small")
    list:addItem("large")
    list:setOnSelect(function(idx)
        print("selected " .. tostring(idx))
    end)
    list:setSelected(2)
    print("selected index = " .. list:getSelected())
end
```

---

### `LWidget:setPosition`

Sets the widget position in 1-based cell coordinates within the terminal grid.

```lua
-- signature
LWidget:setPosition(col, row)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `number` | Column index (1-based). |
| `row` | `number` | Row index (1-based). |

**Example**

```lua
do
    local tb = lurek.terminal.newTextBox(0, 0, 20)
    tb:setPosition(3, 5)
    local px, py = tb:getPosition()
    print("setPosition = " .. px .. ", " .. py)
end
```

---

### `LWidget:setSelected`

Sets the currently selected item in a list widget by 1-based index, or clears the selection with nil. Fires the onSelect callback if changed.

```lua
-- signature
LWidget:setSelected(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index?` | `number` | 1-based item index, or nil to clear selection. |

**Example**

```lua
do
    local list = lurek.terminal.newList(0, 0, 20, 8)
    list:addItem("choice1")
    list:addItem("choice2")
    list:setSelected(2)
    local sel = list:getSelected()
    print("setSelected = " .. sel)
end
```

---

### `LWidget:setSize`

Sets the widget dimensions in cell units, clamped to a minimum of 1x1.

```lua
-- signature
LWidget:setSize(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | Width in cells. |
| `height` | `number` | Height in cells. |

**Example**

```lua
do
    local tb = lurek.terminal.newTextBox(0, 0, 20)
    tb:setSize(25, 1)
    local w, h = tb:getSize()
    print("setSize = " .. w .. "x" .. h)
end
```

---

### `LWidget:setStyle`

Sets the border drawing style for a border or panel widget.

```lua
-- signature
LWidget:setStyle(styleName)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `styleName` | `string` | Border style name (e.g. "single", "double", "rounded", "heavy", "none"). |

**Example**

```lua
do
    local border = lurek.terminal.newBorder(0, 0, 12, 4)
    border:setStyle("double")
    local style = border:getStyle()
    print("setStyle = " .. style)
end
```

---

### `LWidget:setTag`

Assigns an arbitrary string tag to the widget for identification or grouping.

```lua
-- signature
LWidget:setTag(tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tag` | `string` | The tag value. |

**Example**

```lua
do
    local border = lurek.terminal.newBorder(0, 0, 12, 4)
    border:setTag("border_ok")
    print("setTag = " .. border:getTag())
end
```

---

### `LWidget:setText`

Sets the display text of a label, button, or text box widget. Fires the onChange callback if the text actually changed.

```lua
-- signature
LWidget:setText(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | The new text content. |

**Example**

```lua
do
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "Confirm")
    btn:setText("Apply")
    print("setText = " .. btn:getText())
end
```

---

### `LWidget:setTitle`

Sets the title text displayed in the border of a border or panel widget.

```lua
-- signature
LWidget:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | `string` | The title text. |

**Example**

```lua
do
    local border = lurek.terminal.newBorder(0, 0, 22, 10)
    border:setTitle("Options")
    print("setTitle = " .. border:getTitle())
end
```

---

### `LWidget:setVisible`

Controls whether the widget is drawn and receives input events.

```lua
-- signature
LWidget:setVisible(visible)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `visible` | `boolean` | True to show, false to hide. |

**Example**

```lua
do
    local label = lurek.terminal.newLabel(0, 0, "Styled")
    label:setVisible(false)
    print("setVisible = " .. tostring(label:isVisible()))
end
```

---

### `LWidget:type`

Returns the type name string "LWidget".

```lua
-- signature
LWidget:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LWidget". |

**Example**

```lua
do
    local btn = lurek.terminal.newButton(0, 0, 10, 1, "Btn")
    print("type = " .. btn:type())
end
```

---

### `LWidget:typeOf`

Checks whether this object matches a given type name. Accepts "LWidget" or "Object".

```lua
-- signature
LWidget:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to test against. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches. |

**Example**

```lua
do
    local btn = lurek.terminal.newButton(0, 0, 10, 1, "Btn")
    local ok = btn:typeOf("LWidget")
    print("typeOf LWidget = " .. tostring(ok))
end
```

---
