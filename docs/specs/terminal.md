# terminal

## TL;DR

- Grid terminal supporting ANSI formats, syntax highlighting, and cycling tab-completions.
- Cell widgets with input focus, scrollback history, and pixel-perfect rendering.

## General Info

- Module group: `Feature Systems`
- Source path: `src/terminal/`
- Binding: `src/lua_api/terminal_api.rs`
- Namespace: `lurek.terminal`
- Lua API surface: `29` functions, `3` types, `59` methods
- Rust test path(s): tests/rust/unit/terminal_tests.rs, tests/rust/ext/terminal_demo_smoke_tests.rs
- Lua test path(s): tests/lua/unit/test_terminal_core_unit.lua

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

## Imports

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### ansi.rs

- This file owns ANSI escape parsing that turns styled byte streams into plain text or resolved color spans.
- `AnsiColor` and `AnsiSpan` capture the decoded foreground, background, and bold state for each text run.
- `strip_ansi_codes` removes control sequences when callers need raw text without styling metadata.
- `parse_ansi_spans` and SGR helpers decode classic, bright, xterm-256, and explicit RGB color forms.
- Low-level UTF-8 walking stays here because malformed escapes and multibyte chars must be handled together.
- Open it when styled-stream parsing changes; highlighting and grid rendering live in sibling terminal files.

### cell.rs

- This file owns `TCell`, the atomic terminal grid record that stores one glyph plus foreground and background colors.
- It also defines the default glyph and RGBA constants used when terminal surfaces reset or allocate fresh cells.
- Open it when per-cell storage changes; terminal state, widgets, and render composition live in sibling files.

### completion.rs

- This file owns `CompletionEngine`, the sorted candidate store used for prefix lookup and Tab-style cycling.
- It stores the candidate list plus active cycle state so repeated completion presses can advance predictably.
- Helper methods add, remove, clear, filter, and rotate matches without coupling completion to command sources.
- Open it when typed-discovery behavior changes; widgets and terminal input routing live in sibling files.

### highlighter.rs

- This file owns literal-pattern highlighting that converts terminal text into ordered colored spans before render.
- `HighlightRule` defines match strings and colors, while `ColoredSpan` carries resolved output runs for writers.
- `highlight_spans` applies leftmost-first matching so reusable highlight data can feed multiple terminal paths.
- Open it when span-generation semantics change; ANSI decoding and cell drawing live in sibling terminal files.

### mod.rs

- This module is the terminal index, re-exporting cell, widget, state, completion, ANSI, and render support.
- It is the navigation point for character-grid storage, styled text parsing, visual composition, and input routing.
- `terminal_state.rs` owns the mutable grid, cursor, histories, widget focus, and render-cell composition logic.
- `widget.rs` owns terminal UI parts, while `ansi.rs`, `highlighter.rs`, and `completion.rs` enrich text flows.
- `cell.rs` and `text_utils.rs` provide the atomic grid unit plus UTF-8-safe helpers reused across terminal code.
- Change this file when public terminal exports move; change siblings when behavior or rendering semantics change.

### render.rs

- This file owns terminal-to-render export helpers that flatten the composed cell surface into visual outputs.
- `generate_render_commands` translates cells into `RenderCommand` streams with colored backgrounds and glyphs.
- `draw_to_image` rasterizes the same terminal surface into a coarse `ImageData` snapshot for tools or previews.
- Both paths read the composed grid through terminal helpers, so widget overlays are included automatically.
- Open it when terminal visual export changes; core grid mutation and widget layout live in sibling state files.

### terminal_state.rs

- This file owns `Terminal`, the main state machine for the character grid, cursor, widgets, and histories.
- It stores the row-major cell buffer, focus state, clipboard, command history, scrollback, and size overrides.
- Helper functions draw compact buttons, frames, cursor text, and bounded writes onto composed cell slices.
- Input handlers route keyboard, text, and mouse events to focused widgets and emit typed terminal events.
- Text-box editing covers cursor movement, selection replacement, clipboard shortcuts, and word deletes.
- List handling covers focus, selection, scrolling, and mouse hit resolution for terminal UI controls.
- Render composition overlays visible widgets on top of the base grid and reuses scratch buffers.
- Border rendering, panel child maintenance, and widget removal cleanup keep layered layouts consistent.
- Public grid APIs cover cell reads, writes, resizing, colored printing, default colors, and cursor moves.
- History APIs manage scrollback limits, command navigation, and durable memory beyond render output.
- Command builders translate the composed surface into batched render commands without duplicated logic.
- Open it when terminal interaction or surface semantics change; widgets and exporters depend on it.

### text_utils.rs

- This file owns UTF-8-safe terminal text helpers for counts, byte offsets, truncation, and lead-byte widths.
- These helpers keep cursor movement, clipping, and parser logic consistent when code mixes chars and bytes.
- Open it when Unicode indexing rules change; ANSI parsing and text editing consume these utilities nearby.

### widget.rs

- This file owns the terminal widget model used to build labels, buttons, text boxes, lists, borders, and panels.
- `BorderStyle` defines frame glyph choices, while `WidgetBase` centralizes position, size, visibility, and tags.
- `WidgetKind` stores kind-specific data for text, selection, scroll, border styling, and panel child membership.
- `Widget` constructors create grid-aligned UI parts with size clamping that matches terminal row limits.
- Mutation helpers keep text, color, max-length, selection, border style, and title updates in one owner.
- List helpers manage item addition, removal, scroll, and 1-based selection semantics used by input handlers.
- Kind-check helpers let callers branch on widget behavior without matching all enum payloads at each call site.
- Open it when terminal UI object semantics change; event dispatch and rendering integration live in state.



## Lua API Ref

### Functions

- `lurek.terminal.addCompletion(candidate) -> nil`: Registers a candidate string for tab-completion in the shared completion engine.
- `lurek.terminal.applyTheme(terminal, theme) -> nil`: Applies a named color theme to the terminal, setting default foreground and background colors.
- `lurek.terminal.clearCmdHistory(terminal) -> nil`: Removes all entries from the terminal command history.
- `lurek.terminal.clearCompletions() -> nil`: Removes all registered completion candidates from the shared completion engine.
- `lurek.terminal.cmdHistoryLen(terminal) -> integer`: Returns the number of commands currently stored in the terminal command history.
- `lurek.terminal.getCompletions(prefix) -> string[]`: Returns all completion candidates matching the given prefix string.
- `lurek.terminal.getMaxCols() -> integer`: Returns the engine-defined maximum number of columns a terminal grid can have.
- `lurek.terminal.getMaxRows() -> integer`: Returns the engine-defined maximum number of rows a terminal grid can have.
- `lurek.terminal.getScrollback(terminal, offset, count) -> string[]`: Retrieves a range of lines from the terminal scrollback buffer.
- `lurek.terminal.newBorder(col, row, width, height) -> LWidget`: Creates a new decorative border widget drawn using box-drawing characters.
- `lurek.terminal.newButton(col, row, width, height?, text?) -> LWidget`: Creates a new clickable button widget with the given position, size, and label text.
- `lurek.terminal.newLabel(col, row, text?) -> LWidget`: Creates a new label widget that displays static text at the given cell position.
- `lurek.terminal.newList(col, row, width, height) -> LWidget`: Creates a new scrollable list widget for displaying and selecting items.
- `lurek.terminal.newPanel(col, row, width?, height?) -> LWidget`: Creates a new panel widget that can contain child widgets for grouped layout.
- `lurek.terminal.newTerminal(cols?, rows?) -> LTerminal`: Creates a new terminal emulator grid and stages a window size that fits its active cell metrics.
- `lurek.terminal.newTextBox(col, row, width) -> LWidget`: Creates a new single-line text input widget at the given position with a fixed width.
- `lurek.terminal.nextCmd(terminal) -> string`: Navigates forward in the terminal command history, returning the next command or nil if at the end.
- `lurek.terminal.nextCompletion(prefix) -> string`: Cycles to the next matching completion candidate for the given prefix, wrapping around after the last match.
- `lurek.terminal.parseAnsi(text) -> table`: Parses ANSI escape sequences in a string into an array of span tables with text, bold, fg, and bg fields.
- `lurek.terminal.prevCmd(terminal) -> string`: Navigates backward in the terminal command history, returning the previous command or nil if at the start.
- `lurek.terminal.printAnsi(terminal, col, row, text) -> nil`: Renders ANSI-colored text directly onto the terminal grid at the given cell position.
- `lurek.terminal.printHighlighted(terminal, col, row, text, rules) -> nil`: Renders syntax-highlighted text onto the terminal grid using a table of highlight rules with regex patterns and colors.
- `lurek.terminal.pushCmdHistory(terminal, cmd) -> nil`: Appends a command string to the terminal command history for up/down arrow recall.
- `lurek.terminal.pushScrollback(terminal, line) -> nil`: Appends a line of text to the terminal scrollback buffer for later retrieval.
- `lurek.terminal.removeCompletion(candidate) -> nil`: Removes a previously registered completion candidate from the shared completion engine.
- `lurek.terminal.resetCompletion() -> nil`: Resets the completion cycling state so the next call to nextCompletion starts from the first match.
- `lurek.terminal.scrollbackLen(terminal) -> integer`: Returns the number of lines currently stored in the terminal scrollback buffer.
- `lurek.terminal.setScrollbackCap(terminal, cap) -> nil`: Sets the maximum number of lines retained in the terminal scrollback buffer. Older lines are discarded when the cap is exceeded.
- `lurek.terminal.stripAnsi(text) -> string`: Removes all ANSI escape sequences from a string, returning plain text.

### Callbacks

- `LWidget:setOnChange` param `callback` (`function?`): The change handler, or nil to clear.
- `LWidget:setOnClick` param `callback` (`function?`): The click handler, or nil to clear.
- `LWidget:setOnSelect` param `callback` (`function?`): The selection handler, or nil to clear.

### Enums

- No documented module-level enums/constants.

### Types

#### LTerminal Type

- Lua-side userdata wrapping a terminal emulator grid with cell access, widgets, input, and rendering.

##### Fields

- No documented fields.

##### Methods

- `LTerminal:addWidget(widget) -> nil`: Attaches a widget to this terminal so it is rendered and receives input events.
- `LTerminal:autoResize() -> nil`: Requests the window to resize so it exactly fits the terminal grid at the current cell size.
- `LTerminal:clear() -> nil`: Clears all cells in the terminal grid, resetting characters and colors to defaults.
- `LTerminal:clearWidgets() -> nil`: Removes all attached widgets from this terminal at once.
- `LTerminal:get(col, row) -> integer, number, number, number, number, number, number, number, number`: Reads the character and colors at a specific cell in the terminal grid.
- `LTerminal:getCellSize() -> number, number`: Returns the active terminal cell width and height in pixels, using custom override or font metrics.
- `LTerminal:getDimensions() -> integer, integer`: Returns the number of columns and rows in the terminal grid.
- `LTerminal:getFocused() -> LWidget`: Returns the widget that currently has keyboard focus, or nil if no widget is focused.
- `LTerminal:getWidgetCount() -> integer`: Returns the number of widgets currently attached to this terminal.
- `LTerminal:keypressed(key) -> boolean`: Forwards a key press event to the terminal for widget input processing.
- `LTerminal:mousepressed(px, py, button?) -> nil`: Forwards a mouse press event to the terminal, converting pixel coordinates to cell coordinates.
- `LTerminal:print(col, row, text) -> nil`: Writes text to the terminal grid starting at a specific cell.
- `LTerminal:removeWidget(widget) -> nil`: Detaches a widget from this terminal, removing it from rendering and input handling.
- `LTerminal:render(x?, y?) -> nil`: Renders the terminal grid and widgets and stages a window size matching the grid and active cell size.
- `LTerminal:resetCellSize() -> nil`: Removes any custom cell size override, reverting to the active font metrics and refitting the window.
- `LTerminal:set(col, row, ch, fr?, fg?, fb?, fa?, br?, bg?, bb?, ba?) -> nil`: Writes a character with foreground and background color to a specific cell in the terminal grid.
- `LTerminal:setCellSize(w, h) -> nil`: Overrides the cell width and height used for rendering this terminal grid and refits the window.
- `LTerminal:setFocus(widget?) -> nil`: Sets which widget currently has keyboard focus, or clears focus when nil is passed.
- `LTerminal:setFont(height) -> nil`: Selects the nearest built-in bitmap font by pixel height and refits the window to the terminal grid.
- `LTerminal:textinput(text) -> boolean`: Forwards a text input event to the terminal for character entry into focused widgets.
- `LTerminal:type() -> string`: Returns the type name string "LTerminal".
- `LTerminal:typeOf(name) -> boolean`: Checks whether this object matches a given type name. Accepts "LTerminal" or "Object".

#### LTerminalParseAnsiResult Type

- Generated result shape from @field tags.

##### Fields

- `b` (`number`): B.
- `bold` (`boolean`): Bold.
- `fg` (`table?`): Foreground color table with r, g, b.
- `g` (`number`): G.
- `text` (`string`): Text.

##### Methods

- No documented methods.

#### LWidget Type

- Lua-side userdata wrapping a terminal widget (label, button, text box, list, border, or panel).

##### Fields

- No documented fields.

##### Methods

- `LWidget:addChild(child) -> nil`: Adds a child widget to a panel widget. The child becomes part of the panel layout and rendering.
- `LWidget:addItem(item) -> nil`: Appends a text item to a list widget.
- `LWidget:clearChildren() -> nil`: Removes all child widgets from a panel widget.
- `LWidget:clearItems() -> nil`: Removes all items from a list widget.
- `LWidget:getChild(index) -> LWidget`: Returns a child widget from a panel by its 1-based index, or nil if the index is out of range.
- `LWidget:getChildCount() -> integer`: Returns the number of child widgets in a panel widget.
- `LWidget:getColor() -> number, number, number, number`: Returns the foreground color of the widget as RGBA components.
- `LWidget:getItem(index) -> string`: Returns the text of a list item by its 1-based index.
- `LWidget:getItemCount() -> integer`: Returns the number of items in a list widget.
- `LWidget:getMaxLength() -> integer`: Returns the maximum character limit of a text box widget.
- `LWidget:getPosition() -> integer, integer`: Returns the widget position as 1-based column and row.
- `LWidget:getSelected() -> integer`: Returns the 1-based index of the currently selected list item, or nil if nothing is selected.
- `LWidget:getSize() -> integer, integer`: Returns the widget dimensions as width and height in cell units.
- `LWidget:getStyle() -> string`: Returns the current border style name of a border or panel widget.
- `LWidget:getTag() -> string`: Returns the current tag string assigned to the widget.
- `LWidget:getText() -> string`: Returns the current text content of a label, button, or text box widget.
- `LWidget:getTitle() -> string`: Returns the current title text of a border or panel widget.
- `LWidget:isEnabled() -> boolean`: Returns whether the widget is currently enabled for user interaction.
- `LWidget:isVisible() -> boolean`: Returns whether the widget is currently visible.
- `LWidget:removeChild(child) -> nil`: Removes a child widget from a panel, detaching it from the panel layout.
- `LWidget:removeItem(index) -> nil`: Removes a list item by its 1-based index.
- `LWidget:setColor(r, g, b, a?) -> nil`: Sets the foreground color of the widget as RGBA components (0-1 range).
- `LWidget:setEnabled(enabled) -> nil`: Controls whether the widget accepts user interaction (clicks, typing).
- `LWidget:setMaxLength(maxLength) -> nil`: Sets the maximum number of characters allowed in a text box widget.
- `LWidget:setOnChange(callback?) -> nil`: Registers a callback function invoked when the text content of a text box widget changes. Only valid for text box widgets.
- `LWidget:setOnClick(callback?) -> nil`: Registers a callback function invoked when a button widget is clicked. Only valid for button widgets.
- `LWidget:setOnSelect(callback?) -> nil`: Registers a callback function invoked when the selected item in a list widget changes. Only valid for list widgets.
- `LWidget:setPosition(col, row) -> nil`: Sets the widget position in 1-based cell coordinates within the terminal grid.
- `LWidget:setSelected(index?) -> nil`: Sets the currently selected item in a list widget by 1-based index, or clears the selection with nil. Fires the onSelect callback if changed.
- `LWidget:setSize(width, height) -> nil`: Sets the widget dimensions in cell units, clamped to a minimum of 1x1.
- `LWidget:setStyle(styleName) -> nil`: Sets the border drawing style for a border or panel widget.
- `LWidget:setTag(tag) -> nil`: Assigns an arbitrary string tag to the widget for identification or grouping.
- `LWidget:setText(text) -> nil`: Sets the display text of a label, button, or text box widget. Fires the onChange callback if the text actually changed.
- `LWidget:setTitle(title) -> nil`: Sets the title text displayed in the border of a border or panel widget.
- `LWidget:setVisible(visible) -> nil`: Controls whether the widget is drawn and receives input events.
- `LWidget:type() -> string`: Returns the type name string "LWidget".
- `LWidget:typeOf(name) -> boolean`: Checks whether this object matches a given type name. Accepts "LWidget" or "Object".

## References

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- No additional module-specific notes.
