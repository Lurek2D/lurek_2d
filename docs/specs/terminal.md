# terminal

## TL;DR

- The `terminal` module is a sophisticated Feature Systems tier component that provides a full-featured character-grid terminal emulator within the engine.

## General Info

- Module group: `Feature Systems`
- Source path: `src/terminal/`
- Lua API path(s): `src/lua_api/terminal_api.rs`
- Primary Lua namespace: `lurek.terminal`
- Rust test path(s): tests/rust/unit/terminal_tests.rs, tests/rust/ext/terminal_demo_smoke_tests.rs
- Lua test path(s): tests/lua/unit/test_terminal_core_unit.lua

## Summary

Originally designed to host the in-game developer console, it functions as a highly versatile UI surface capable of rendering classic ASCII interfaces, roguelike displays, and complex debugging tools. At its foundation, the `Terminal` struct manages a fixed-size grid of cells (`TCell`), each storing a character codepoint alongside independent foreground and background colors. The module implements a robust ANSI escape sequence parser (`ansi.rs`), capable of decoding standard 8-color palettes, 256-color xterm indexes, and 24-bit true-color RGB combinations, enabling seamless integration with existing terminal-based output streams and logging tools.

Beyond raw text rendering, the terminal provides a surprisingly capable immediate-mode widget framework (`widget.rs`). Developers can compose interactive interfaces directly on the character grid using pre-built elements like Buttons, Labels, TextBoxes, Lists, and Panels. These widgets handle their own bounds checking, input routing, and rendering (complete with ASCII border drawing and shaded backgrounds). To support command-line workflows, the module includes a `CompletionEngine` for context-aware tab completion, a persistent command history buffer for quick recall, and a scrollback buffer that gracefully evicts the oldest lines when capacity is reached. For specialized display needs—such as the interactive Lua REPL (`lurek.repl`)—the module integrates a regex-driven `highlighter.rs` that applies token-based syntax coloring to code inputs in real-time.

The rendering pipeline bridges the gap between the character grid and the engine's graphical backend. The terminal state is efficiently composited and flattened into batched `RenderCommand` sequences, mapped directly to loaded bitmap fonts for pixel-perfect display. The terminal can also software-rasterize its grid directly into an `ImageData` buffer, useful for generating preview thumbnails or headless output. Fully accessible via the `lurek.terminal.*` API, this module is an invaluable tool for building in-game developer tools, specialized text-based mini-games, and deeply interactive console environments.

## Files

### ansi.rs

- ANSI escape sequence stripping and SGR attribute parsing.
- Standard 8-color CGA and bright palette tables (codes 30–37, 90–97).
- Xterm-256 color index decoding: cube (16–231) and grayscale (232–255).
- 24-bit true-color RGB extraction from SGR 38/48 sub-code 2.
- Span-based output splitting text into runs with shared fg/bg/bold state.
- UTF-8 byte-level helpers for raw escape parsing without allocation.

### cell.rs

- Single-cell data type for the terminal grid.
- Default color and character constants.
- `Default` trait wiring for blank cells.

### completion.rs

- Prefix-based tab-completion engine for the in-game terminal.
- Maintains a sorted candidate list; cycles through matches on repeated Tab presses.
- Supports dynamic add/remove of candidates and stateless prefix queries.

### highlighter.rs

- Pattern-based text highlighting: match literal strings and assign foreground/background colors.
- Span splitting: decompose input into colored runs for terminal cell rendering.
- Leftmost-first rule priority with default fallback for unmatched regions.

### mod.rs

- In-engine terminal emulator with ANSI escape-code support
- Grid-based cell model, tab completion, and syntax highlighting
- Converts terminal state into RenderCommand sequences for display
- Widget primitives for composing custom terminal UIs

### render.rs

- Render the composited terminal cell grid as a list of `RenderCommand` draw calls.
- Rasterise the composited grid into an `ImageData` thumbnail for previews and tests.
- Both paths include terminal widgets and map foreground/background colours to output.

### terminal_state.rs

- Terminal grid state machine: fixed-size cell buffer with 1-based cursor, per-cell fg/bg colors, and content-preserving resize.
- Widget system: compositable label, button, text-box, list, border, and panel widgets drawn on top of the grid with default shaded skins.
- Focus and input dispatch: keyboard, text-input, and mouse events routed to the focused widget with event emission.
- Scrollback buffer: capped line history with offset-based windowed retrieval.
- Command history: push/prev/next navigation for console-style input recall.
- Cell manipulation helpers: single-cell set/get, bulk print, colored print, and default-color application.
- Render output: composited cell buffer flattened into batched background and text `RenderCommand` lists for the renderer.
- Border rendering: single, double, and ASCII frame styles with optional title text.
- Panel child tracking: index-based parent-child relationships with automatic adjustment on widget removal.

### widget.rs

- Define the terminal widget type system: Label, Button, TextBox, List, Border, and Panel.
- Provide `WidgetBase` for shared layout state: position, size, visibility, enabled flag, and tag.
- Offer `BorderStyle` enum with single, double, and ASCII line-drawing variants.
- Construct widgets from 1-based terminal coordinates with clamped dimensions.
- Get and set display text for text-bearing widgets (Label, Button, TextBox).
- Get and set foreground color for colored widgets (Label, Border).
- Manipulate list contents: add, remove, clear items; track selection and scroll offset.
- Enforce TextBox max-length constraints with automatic cursor clamping.
- Expose border property accessors for style and title.
- Provide type-checking predicates for widget kind discrimination.

## Lua API Ref

- Binding: `src/lua_api/terminal_api.rs`
- Namespace: `lurek.terminal`

### Functions

- `lurek.terminal.addCompletion`: Registers a candidate string for tab-completion in the shared completion engine.
- `lurek.terminal.applyTheme`: Applies a named color theme to the terminal, setting default foreground and background colors.
- `lurek.terminal.clearCmdHistory`: Removes all entries from the terminal command history.
- `lurek.terminal.clearCompletions`: Removes all registered completion candidates from the shared completion engine.
- `lurek.terminal.cmdHistoryLen`: Returns the number of commands currently stored in the terminal command history.
- `lurek.terminal.getCompletions`: Returns all completion candidates matching the given prefix string.
- `lurek.terminal.getMaxCols`: Returns the engine-defined maximum number of columns a terminal grid can have.
- `lurek.terminal.getMaxRows`: Returns the engine-defined maximum number of rows a terminal grid can have.
- `lurek.terminal.getScrollback`: Retrieves a range of lines from the terminal scrollback buffer.
- `lurek.terminal.newBorder`: Creates a new decorative border widget drawn using box-drawing characters.
- `lurek.terminal.newButton`: Creates a new clickable button widget with the given position, size, and label text.
- `lurek.terminal.newLabel`: Creates a new label widget that displays static text at the given cell position.
- `lurek.terminal.newList`: Creates a new scrollable list widget for displaying and selecting items.
- `lurek.terminal.newPanel`: Creates a new panel widget that can contain child widgets for grouped layout.
- `lurek.terminal.newTerminal`: Creates a new terminal emulator grid and stages a window size that fits its active cell metrics.
- `lurek.terminal.newTextBox`: Creates a new single-line text input widget at the given position with a fixed width.
- `lurek.terminal.nextCmd`: Navigates forward in the terminal command history, returning the next command or nil if at the end.
- `lurek.terminal.nextCompletion`: Cycles to the next matching completion candidate for the given prefix, wrapping around after the last match.
- `lurek.terminal.parseAnsi`: Parses ANSI escape sequences in a string into an array of span tables with text, bold, fg, and bg fields.
- `lurek.terminal.prevCmd`: Navigates backward in the terminal command history, returning the previous command or nil if at the start.
- `lurek.terminal.printAnsi`: Renders ANSI-colored text directly onto the terminal grid at the given cell position.
- `lurek.terminal.printHighlighted`: Renders syntax-highlighted text onto the terminal grid using a table of highlight rules with regex patterns and colors.
- `lurek.terminal.pushCmdHistory`: Appends a command string to the terminal command history for up/down arrow recall.
- `lurek.terminal.pushScrollback`: Appends a line of text to the terminal scrollback buffer for later retrieval.
- `lurek.terminal.removeCompletion`: Removes a previously registered completion candidate from the shared completion engine.
- `lurek.terminal.resetCompletion`: Resets the completion cycling state so the next call to nextCompletion starts from the first match.
- `lurek.terminal.scrollbackLen`: Returns the number of lines currently stored in the terminal scrollback buffer.
- `lurek.terminal.setScrollbackCap`: Sets the maximum number of lines retained in the terminal scrollback buffer. Older lines are discarded when the cap is exceeded.
- `lurek.terminal.stripAnsi`: Removes all ANSI escape sequences from a string, returning plain text.

### Enums

- No documented module-level enums/constants.

### Types


#### LTerminal Type


##### Fields

- No documented fields.

##### Methods

- `LTerminal:addWidget`: Attaches a widget to this terminal so it is rendered and receives input events.
- `LTerminal:autoResize`: Requests the window to resize so it exactly fits the terminal grid at the current cell size.
- `LTerminal:clear`: Clears all cells in the terminal grid, resetting characters and colors to defaults.
- `LTerminal:clearWidgets`: Removes all attached widgets from this terminal at once.
- `LTerminal:get`: Reads the character and colors at a specific cell in the terminal grid.
- `LTerminal:getCellSize`: Returns the active terminal cell width and height in pixels, using custom override or font metrics.
- `LTerminal:getDimensions`: Returns the number of columns and rows in the terminal grid.
- `LTerminal:getFocused`: Returns the widget that currently has keyboard focus, or nil if no widget is focused.
- `LTerminal:getWidgetCount`: Returns the number of widgets currently attached to this terminal.
- `LTerminal:keypressed`: Forwards a key press event to the terminal for widget input processing.
- `LTerminal:mousepressed`: Forwards a mouse press event to the terminal, converting pixel coordinates to cell coordinates.
- `LTerminal:print`: Writes text to the terminal grid starting at a specific cell.
- `LTerminal:removeWidget`: Detaches a widget from this terminal, removing it from rendering and input handling.
- `LTerminal:render`: Renders the terminal grid and widgets and stages a window size matching the grid and active cell size.
- `LTerminal:resetCellSize`: Removes any custom cell size override, reverting to the active font metrics and refitting the window.
- `LTerminal:set`: Writes a character with foreground and background color to a specific cell in the terminal grid.
- `LTerminal:setCellSize`: Overrides the cell width and height used for rendering this terminal grid and refits the window.
- `LTerminal:setFocus`: Sets which widget currently has keyboard focus, or clears focus when nil is passed.
- `LTerminal:setFont`: Selects the nearest built-in bitmap font by pixel height and refits the window to the terminal grid.
- `LTerminal:textinput`: Forwards a text input event to the terminal for character entry into focused widgets.
- `LTerminal:type`: Returns the type name string "LTerminal".
- `LTerminal:typeOf`: Checks whether this object matches a given type name. Accepts "LTerminal" or "Object".


#### LWidget Type


##### Fields

- No documented fields.

##### Methods

- `LWidget:addChild`: Adds a child widget to a panel widget. The child becomes part of the panel layout and rendering.
- `LWidget:addItem`: Appends a text item to a list widget.
- `LWidget:clearChildren`: Removes all child widgets from a panel widget.
- `LWidget:clearItems`: Removes all items from a list widget.
- `LWidget:getChild`: Returns a child widget from a panel by its 1-based index, or nil if the index is out of range.
- `LWidget:getChildCount`: Returns the number of child widgets in a panel widget.
- `LWidget:getColor`: Returns the foreground color of the widget as RGBA components.
- `LWidget:getItem`: Returns the text of a list item by its 1-based index.
- `LWidget:getItemCount`: Returns the number of items in a list widget.
- `LWidget:getMaxLength`: Returns the maximum character limit of a text box widget.
- `LWidget:getPosition`: Returns the widget position as 1-based column and row.
- `LWidget:getSelected`: Returns the 1-based index of the currently selected list item, or nil if nothing is selected.
- `LWidget:getSize`: Returns the widget dimensions as width and height in cell units.
- `LWidget:getStyle`: Returns the current border style name of a border or panel widget.
- `LWidget:getTag`: Returns the current tag string assigned to the widget.
- `LWidget:getText`: Returns the current text content of a label, button, or text box widget.
- `LWidget:getTitle`: Returns the current title text of a border or panel widget.
- `LWidget:isEnabled`: Returns whether the widget is currently enabled for user interaction.
- `LWidget:isVisible`: Returns whether the widget is currently visible.
- `LWidget:removeChild`: Removes a child widget from a panel, detaching it from the panel layout.
- `LWidget:removeItem`: Removes a list item by its 1-based index.
- `LWidget:setColor`: Sets the foreground color of the widget as RGBA components (0-1 range).
- `LWidget:setEnabled`: Controls whether the widget accepts user interaction (clicks, typing).
- `LWidget:setMaxLength`: Sets the maximum number of characters allowed in a text box widget.
- `LWidget:setOnChange`: Registers a callback function invoked when the text content of a text box widget changes. Only valid for text box widgets.
- `LWidget:setOnClick`: Registers a callback function invoked when a button widget is clicked. Only valid for button widgets.
- `LWidget:setOnSelect`: Registers a callback function invoked when the selected item in a list widget changes. Only valid for list widgets.
- `LWidget:setPosition`: Sets the widget position in 1-based cell coordinates within the terminal grid.
- `LWidget:setSelected`: Sets the currently selected item in a list widget by 1-based index, or clears the selection with nil. Fires the onSelect callback if changed.
- `LWidget:setSize`: Sets the widget dimensions in cell units, clamped to a minimum of 1x1.
- `LWidget:setStyle`: Sets the border drawing style for a border or panel widget.
- `LWidget:setTag`: Assigns an arbitrary string tag to the widget for identification or grouping.
- `LWidget:setText`: Sets the display text of a label, button, or text box widget. Fires the onChange callback if the text actually changed.
- `LWidget:setTitle`: Sets the title text displayed in the border of a border or panel widget.
- `LWidget:setVisible`: Controls whether the widget is drawn and receives input events.
- `LWidget:type`: Returns the type name string "LWidget".
- `LWidget:typeOf`: Checks whether this object matches a given type name. Accepts "LWidget" or "Object".

## References

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
