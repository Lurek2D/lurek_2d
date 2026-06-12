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
- Lua test path(s): tests/lua_reorg/unit/test_terminal_core_unit.lua

## Summary

- This module gives users an in-engine terminal surface built on a styled character-cell grid.
- Cell state tracks glyphs and color attributes for text-mode rendering and interaction.
- ANSI parsing support enables rich styled output from terminal-like streams.
- Syntax highlighting support applies rule-driven color spans for readable text contexts.
- Completion support improves command-entry ergonomics with candidate cycling.
- Scrollback and command history support persistent console workflows.
- Widget support includes labels, buttons, lists, text boxes, borders, and panels.
- Focus and input routing keep keyboard and mouse behavior coherent across widget compositions.
- Cell-to-pixel rendering keeps terminal output crisp under scale and resize changes.
- Auto-resize and cell-size controls support predictable layout fitting to window dimensions.
- Render-to-image paths support terminal snapshots for tooling and evidence.
- Utility APIs support ANSI strip/parse and command-history operations.
- The module is useful for in-game consoles, debug UIs, and text-heavy tool interfaces.
- For users, it centralizes terminal behavior rather than reimplementing ad-hoc text UI layers.
- It supports both low-level cell drawing and higher-level widget composition.
- Overall, users get a complete interactive terminal runtime with rendering and input integration.

This module primarily collaborates with `image`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Imports

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### ansi.rs

- This file interprets ANSI terminal escape sequences so colored or styled text streams can be understood by the in-engine terminal.
- It strips control bytes when plain text is needed and decodes styling spans when visual fidelity matters.
- Classic palette colors, extended xterm indexes, and full RGB forms are all resolved here into engine-friendly color data.
- Span extraction is part of the same logic so one input string can become ordered runs with shared style state.
- Low-level parsing helpers stay close to the decoder because escape handling is sensitive to byte structure and malformed fragments.
- The file is therefore the compatibility layer between external terminal-style output and the engine's own grid renderer.

### cell.rs

- This file defines the atomic cell unit that the terminal grid stores for every visible character position.
- It packages glyph and color state into one compact record so the rest of the terminal can treat the screen as a regular matrix.
- The type is the smallest visible building block of the terminal subsystem.

### completion.rs

- This file provides the terminal's lightweight completion engine for command-like text entry.
- It manages a candidate set that can be queried by prefix or cycled interactively as the user repeats completion input.
- Dynamic updates are supported because terminal commands and symbols may change while the application is running.
- The file is the discoverability helper for typed terminal interaction.

### highlighter.rs

- This file applies simple highlighting rules to terminal text so input or output can be visually segmented by meaning.
- Matching produces ordered colored spans instead of immediate cell writes, which keeps highlighting reusable across render paths.
- Rule priority is resolved consistently here so overlapping matches do not create unstable coloring behavior.
- The file is the terminal's lightweight text-coloring layer.

### mod.rs

- This module provides the in-engine terminal stack, combining a character grid, ANSI-aware text handling, interactive widgets, and renderer handoff.
- It supports both console-like workflows and text-heavy in-game interfaces built on a cell-based presentation model.
- At the highest level this is the subsystem that lets the engine host terminal behavior as a first-class UI surface.

### render.rs

- This file converts the composed terminal surface into visual output for both renderer command streams and software image snapshots.
- Grid cells and overlaid widgets are flattened together here so the rest of the engine sees one finished terminal presentation.
- Color mapping and glyph placement are resolved at this stage rather than scattered across terminal state management.
- The file is therefore the terminal subsystem's final visual export layer.

### terminal_state.rs

- This file implements the terminal's main state machine, where the character grid, cursor, colors, histories, widgets, and input routing all meet.
- The core grid behaves like a persistent text surface rather than a transient print stream, allowing callers to treat terminal space as editable UI.
- Resize behavior preserves as much existing content as possible so the terminal remains usable across font or window changes.
- Scrollback and command history live here because they are part of the terminal's long-lived interactive memory rather than renderer output.
- Widget composition is layered on top of the cell grid in this file so buttons, lists, panels, and text boxes share one event and focus model.
- Keyboard, text, and mouse input are dispatched here because only this layer understands both raw terminal coordinates and focused widgets.
- Border and panel behaviors are also coordinated here, giving text-mode interfaces a richer structure than plain character dumps.
- Cell-level writing helpers remain part of this file because direct text painting and higher-level widgets must coexist on the same surface.
- Render preparation starts here as well, with the composited foreground and background state turned toward later visual export.
- The file is intentionally large because it is not one helper.
- It is the living behavior model of the entire terminal subsystem.
- Most user-visible terminal semantics, from typing to focus to scrollback, are defined here.
- Without this file the module would have isolated utilities but no unified terminal behavior.
- In practice this is the runtime home of text-mode interaction inside the engine.
- It is where a passive grid becomes a usable terminal environment.

### text_utils.rs

- Shared text helpers used across the terminal subsystem.
- These helpers centralize UTF-8-safe character counting, truncation, and indexing logic.

### widget.rs

- This file defines the widget vocabulary used by the terminal so character-grid interfaces can be composed from reusable interactive parts.
- Shared widget state is centralized here because labels, buttons, lists, text boxes, borders, and panels all need common positioning and visibility rules.
- Each widget kind extends that shared base with behavior suited to text-mode UI rather than pixel-perfect retained graphics widgets.
- Border and panel concepts live here because framed layout is a fundamental part of terminal-style interface composition.
- Text-bearing widgets are shaped around cell coordinates and constrained widths, which keeps them honest to the grid they inhabit.
- List widgets manage items and selection semantics here so terminal state can treat them as one coherent interactive object.
- Text boxes enforce cursor and content limits here, giving the terminal a predictable editing model for user input.
- Type discrimination helpers also belong here because higher layers often need to branch on widget behavior without unpacking every variant manually.
- The file is therefore the structural UI type system of the terminal module.
- It gives the terminal more expressive interface primitives than raw cells alone could provide.



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
