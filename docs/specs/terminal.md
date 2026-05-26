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

## Source Documentation

### `ansi.rs`
- ANSI escape sequence stripping and SGR attribute parsing.
- Standard 8-color CGA and bright palette tables (codes 30–37, 90–97).
- Xterm-256 color index decoding: cube (16–231) and grayscale (232–255).
- 24-bit true-color RGB extraction from SGR 38/48 sub-code 2.
- Span-based output splitting text into runs with shared fg/bg/bold state.
- UTF-8 byte-level helpers for raw escape parsing without allocation.

### `cell.rs`
- Single-cell data type for the terminal grid.
- Default color and character constants.
- `Default` trait wiring for blank cells.

### `completion.rs`
- Prefix-based tab-completion engine for the in-game terminal.
- Maintains a sorted candidate list; cycles through matches on repeated Tab presses.
- Supports dynamic add/remove of candidates and stateless prefix queries.

### `highlighter.rs`
- Pattern-based text highlighting: match literal strings and assign foreground/background colors.
- Span splitting: decompose input into colored runs for terminal cell rendering.
- Leftmost-first rule priority with default fallback for unmatched regions.

### `mod.rs`
- In-engine terminal emulator with ANSI escape-code support
- Grid-based cell model, tab completion, and syntax highlighting
- Converts terminal state into RenderCommand sequences for display
- Widget primitives for composing custom terminal UIs

### `render.rs`
- Render the composited terminal cell grid as a list of `RenderCommand` draw calls.
- Rasterise the composited grid into an `ImageData` thumbnail for previews and tests.
- Both paths include terminal widgets and map foreground/background colours to output.

### `terminal_state.rs`
- Terminal grid state machine: fixed-size cell buffer with 1-based cursor, per-cell fg/bg colors, and content-preserving resize.
- Widget system: compositable label, button, text-box, list, border, and panel widgets drawn on top of the grid with default shaded skins.
- Focus and input dispatch: keyboard, text-input, and mouse events routed to the focused widget with event emission.
- Scrollback buffer: capped line history with offset-based windowed retrieval.
- Command history: push/prev/next navigation for console-style input recall.
- Cell manipulation helpers: single-cell set/get, bulk print, colored print, and default-color application.
- Render output: composited cell buffer flattened into batched background and text `RenderCommand` lists for the renderer.
- Border rendering: single, double, and ASCII frame styles with optional title text.
- Panel child tracking: index-based parent-child relationships with automatic adjustment on widget removal.

### `widget.rs`
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

## Types

- `AnsiColor` (`struct`, `ansi.rs`): RGBA colour in the range `[0, 255]`.
- `AnsiSpan` (`struct`, `ansi.rs`): A contiguous run of characters that share the same style attributes.
- `TCell` (`struct`, `cell.rs`): One terminal cell with a character codepoint and foreground or background colors.
- `CompletionEngine` (`struct`, `completion.rs`): Maintains a list of completion candidates and a per-prefix cycling cursor.
- `HighlightRule` (`struct`, `highlighter.rs`): A text highlighting rule: find `pattern` as a plain substring and apply `fg`/`bg` colors.
- `ColoredSpan` (`struct`, `highlighter.rs`): A colored text span produced by the highlight algorithm.
- `TerminalEvent` (`enum`, `terminal_state.rs`): Internal event enum used when terminal widget interactions need to report changes.
- `Terminal` (`struct`, `terminal_state.rs`): The main character-grid surface. It owns cells, cursor state, terminal widgets, and the state needed to route text or pointer input.
- `BorderStyle` (`enum`, `widget.rs`): Selects the line-drawing character set used for borders.
- `WidgetBase` (`struct`, `widget.rs`): Shared widget metadata such as position, size, visibility, enabled state, and tagging.
- `WidgetKind` (`enum`, `widget.rs`): Enumerates the built-in terminal widget variants such as label, button, text box, list, border, and panel.
- `Widget` (`struct`, `widget.rs`): A terminal widget instance combining base geometry and a concrete widget kind.

## Functions

- `strip_ansi_codes` (`ansi.rs`): Removes all ANSI escape sequences from `text` and returns the plain string.
- `parse_ansi_spans` (`ansi.rs`): Tokenises `text` into [`AnsiSpan`] records, each with plain text and colour/bold state.
- `color256` (`ansi.rs`): Convert xterm-256 color index `n` to RGB; covers standard (0–7), bright (8–15), color cube (16–231), and grayscale (232–255).
- `CompletionEngine::new` (`completion.rs`): Create an empty `CompletionEngine` with no candidates and no active cycle.
- `CompletionEngine::add_candidate` (`completion.rs`): Insert `candidate` into the sorted list if not already present.
- `CompletionEngine::remove_candidate` (`completion.rs`): Remove `candidate` from the list and reset any active cycle.
- `CompletionEngine::clear` (`completion.rs`): Remove all candidates and reset the cycle state.
- `CompletionEngine::len` (`completion.rs`): Return the number of registered candidates.
- `CompletionEngine::is_empty` (`completion.rs`): Return `true` when no candidates are registered.
- `CompletionEngine::completions_for` (`completion.rs`): Return all candidates that start with `prefix`, in sorted order.
- `CompletionEngine::next_completion` (`completion.rs`): Advance to the next candidate matching `prefix` and return it; returns `None` when no matches exist.
- `CompletionEngine::reset` (`completion.rs`): Reset the cycling position without clearing candidates.
- `highlight_spans` (`highlighter.rs`): Splits `text` into colored spans by matching `rules` left-to-right.
- `Terminal::generate_render_commands` (`render.rs`): Build a `RenderCommand` list for the current cell grid using `font_key`, `char_w`/`char_h` cell dimensions, and `scale`.
- `Terminal::draw_to_image` (`render.rs`): Rasterise the cell grid into a `width`×`height` `ImageData` thumbnail; non-space cells are drawn as solid colored rectangles.
- `Terminal::new` (`terminal_state.rs`): Create a new `Terminal` with a blank grid of `cols`×`rows` cells, clamped to `MAX_COLS`/`MAX_ROWS`.
- `Terminal::set` (`terminal_state.rs`): Set cell at 1-based `(col, row)` to `ch` with `fg` and `bg` colors; silently ignored when out of bounds.
- `Terminal::get` (`terminal_state.rs`): Return the cell at 1-based `(col, row)`; returns a default cell when out of bounds.
- `Terminal::clear` (`terminal_state.rs`): Reset all cells to their default state.
- `Terminal::get_dimensions` (`terminal_state.rs`): Return `(cols, rows)` of the current grid.
- `Terminal::set_cell_size` (`terminal_state.rs`): Override the per-cell pixel dimensions; values below 1.0 are clamped to 1.0.
- `Terminal::reset_cell_size` (`terminal_state.rs`): Clear the cell size override so the render layer computes size from font metrics.
- `Terminal::get_cell_size` (`terminal_state.rs`): Return the overridden cell size as `Some((w, h))`, or `None` when using font metrics.
- `Terminal::get_cursor` (`terminal_state.rs`): Return the cursor position as 1-based `(col, row)`.
- `Terminal::set_cursor` (`terminal_state.rs`): Move the cursor to 1-based `(col, row)`, clamped to grid bounds.
- `Terminal::add_widget` (`terminal_state.rs`): Append `widget` and return its index.
- `Terminal::remove_widget` (`terminal_state.rs`): Remove the widget at `index`; adjusts focus and panel child references; returns `false` when index is out of range.
- `Terminal::clear_widgets` (`terminal_state.rs`): Remove all widgets and clear focus.
- `Terminal::get_widget_count` (`terminal_state.rs`): Return the number of registered widgets.
- `Terminal::get_widget` (`terminal_state.rs`): Return a shared reference to the widget at `index`, or `None`.
- `Terminal::get_widget_mut` (`terminal_state.rs`): Return a mutable reference to the widget at `index`, or `None`.
- `Terminal::add_panel_child` (`terminal_state.rs`): Append `child_index` to the Panel widget at `panel_index`; returns `false` on bad indices or wrong widget kind.
- `Terminal::remove_panel_child` (`terminal_state.rs`): Remove `child_index` from the Panel widget at `panel_index`; returns `true` when the child was present.
- `Terminal::clear_panel_children` (`terminal_state.rs`): Remove all children from the Panel widget at `panel_index`; returns `false` when index is wrong kind.
- `Terminal::set_focus` (`terminal_state.rs`): Set focus to `index` if valid, or clear focus when `None` or out of range.
- `Terminal::get_focused` (`terminal_state.rs`): Return the index of the focused widget, or `None` when nothing is focused.
- `Terminal::keypressed` (`terminal_state.rs`): Dispatch a key event to the focused widget; return `true` if consumed.
- `Terminal::textinput` (`terminal_state.rs`): Dispatch a text-input event to the focused widget; return `true` if consumed.
- `Terminal::mousepressed` (`terminal_state.rs`): Dispatch a mouse press at 1-based grid `(grid_col, grid_row)` to the topmost hit widget; return `true` if consumed.
- `Terminal::keypressed_with_events` (`terminal_state.rs`): Dispatch a key event to the focused widget; return `(consumed, events)` for the Lua API layer.
- `Terminal::textinput_with_events` (`terminal_state.rs`): Dispatch text input to the focused `TextBox`; return `(consumed, events)` for the Lua API layer.
- `Terminal::mousepressed_with_events` (`terminal_state.rs`): Dispatch a mouse press to the topmost hit widget; return `(consumed, events)` for the Lua API layer.
- `Terminal::render_cells` (`terminal_state.rs`): Produce a flat cell buffer with all widgets composited on top of the raw grid.
- `Terminal::cols` (`terminal_state.rs`): Return the column count.
- `Terminal::rows` (`terminal_state.rs`): Return the row count.
- `Terminal::try_get` (`terminal_state.rs`): Return the cell at 1-based `(col, row)` as `Some`, or `None` when out of bounds.
- `Terminal::set_char` (`terminal_state.rs`): Set only the character codepoint at 1-based `(col, row)`.
- `Terminal::set_fg` (`terminal_state.rs`): Set only the foreground color at 1-based `(col, row)`.
- `Terminal::set_bg` (`terminal_state.rs`): Set only the background color at 1-based `(col, row)`.
- `Terminal::print` (`terminal_state.rs`): Write each character of `text` to successive columns starting at 1-based `(col, row)`, preserving existing fg/bg.
- `Terminal::resize` (`terminal_state.rs`): Resize the grid to `new_cols`×`new_rows`, preserving the overlapping content region.
- `Terminal::widget_count` (`terminal_state.rs`): Return the number of registered widgets.
- `Terminal::find_by_tag` (`terminal_state.rs`): Return the first widget whose `base.tag` matches `tag`, or `None`.
- `Terminal::build_render_commands` (`terminal_state.rs`): Build a batched `RenderCommand` list for the composited cell grid at pixel origin `(ox, oy)` with `cell_w`/`cell_h` and `font_key`.
- `Terminal::set_default_colors` (`terminal_state.rs`): Apply `fg` and `bg` to every cell in the grid without changing character codepoints.
- `Terminal::print_colored` (`terminal_state.rs`): Write `text` with explicit `fg` and optional `bg` starting at 1-based `(col, row)`.
- `Terminal::set_scrollback_cap` (`terminal_state.rs`): Set the scrollback line cap; trims oldest lines immediately if the buffer exceeds the new limit.
- `Terminal::scrollback_cap` (`terminal_state.rs`): Return the current scrollback line cap.
- `Terminal::push_scrollback` (`terminal_state.rs`): Append `line` to scrollback, evicting the oldest line when the cap is reached; resets scroll offset to 0.
- `Terminal::get_scrollback` (`terminal_state.rs`): Return up to `count` lines ending `offset` lines from the bottom; returns empty when buffer is empty or `count` is 0.
- `Terminal::scrollback_offset` (`terminal_state.rs`): Return the current scrollback scroll offset.
- `Terminal::set_scrollback_offset` (`terminal_state.rs`): Set the scrollback scroll offset, clamped to buffer length.
- `Terminal::scrollback_len` (`terminal_state.rs`): Return the number of lines in the scrollback buffer.
- `Terminal::push_cmd_history` (`terminal_state.rs`): Append a non-empty trimmed `cmd` to the command history and reset the navigation cursor.
- `Terminal::prev_cmd` (`terminal_state.rs`): Navigate to the previous command history entry; returns `None` when history is empty.
- `Terminal::next_cmd` (`terminal_state.rs`): Navigate to the next (more recent) command history entry; returns `None` when at the newest position.
- `Terminal::cmd_history_len` (`terminal_state.rs`): Return the number of entries in the command history.
- `Terminal::clear_cmd_history` (`terminal_state.rs`): Clear all command history and reset the navigation cursor.
- `BorderStyle::from_str_name` (`widget.rs`): Parse a lowercase style name and return the matching variant, or `None` for unknown names.
- `BorderStyle::as_str` (`widget.rs`): Return the canonical lowercase string name for this style.
- `WidgetBase::new` (`widget.rs`): Create a new `WidgetBase` at zero-based position derived from 1-based `(col, row)` with given pixel-grid size.
- `WidgetBase::position_1based` (`widget.rs`): Return the widget position as 1-based `(col, row)`.
- `WidgetBase::set_position_1based` (`widget.rs`): Move the widget to 1-based `(col, row)`.
- `Widget::new_label` (`widget.rs`): Create a `Label` widget at 1-based `(col, row)` with auto-sized width.
- `Widget::new_button` (`widget.rs`): Create a `Button` widget at 1-based `(col, row)` with explicit `width`/`height`.
- `Widget::new_text_box` (`widget.rs`): Create a single-row `TextBox` widget at 1-based `(col, row)` with given `width`.
- `Widget::new_list` (`widget.rs`): Create a `List` widget at 1-based `(col, row)` with explicit `width`/`height`.
- `Widget::new_border` (`widget.rs`): Create a `Border` widget at 1-based `(col, row)` with explicit `width`/`height`.
- `Widget::new_panel` (`widget.rs`): Create a `Panel` grouping widget at 1-based `(col, row)` with explicit `width`/`height`.
- `Widget::set_text` (`widget.rs`): Set the display text for `Label`, `Button`, or `TextBox`; returns `Ok(true)` when the `TextBox` content changed.
- `Widget::get_text` (`widget.rs`): Return the display text for `Label`, `Button`, or `TextBox`; errors on other kinds.
- `Widget::set_color` (`widget.rs`): Set the foreground color on `Label` or `Border`; errors on other kinds.
- `Widget::get_color` (`widget.rs`): Return the foreground color of `Label` or `Border`; errors on other kinds.
- `Widget::set_max_length` (`widget.rs`): Set the character cap on a `TextBox` and truncate current text and cursor if needed; errors on other kinds.
- `Widget::get_max_length` (`widget.rs`): Return the character cap for a `TextBox`; errors on other kinds.
- `Widget::add_item` (`widget.rs`): Append `item` to the `List`; errors on other kinds.
- `Widget::remove_item_1based` (`widget.rs`): Remove the item at 1-based `index` from a `List`, adjusting selection and scroll; errors on other kinds.
- `Widget::clear_items` (`widget.rs`): Remove all items from a `List` and reset selection and scroll; errors on other kinds.
- `Widget::get_item_count` (`widget.rs`): Return the item count for a `List`; errors on other kinds.
- `Widget::get_item_1based` (`widget.rs`): Return the item text at 1-based `index` from a `List`; returns empty string when index is out of range; errors on other kinds.
- `Widget::set_selected_1based` (`widget.rs`): Set the 1-based selected index on a `List`, clamping scroll to keep it visible; returns `Ok(true)` when selection changed; errors on other kinds.
- `Widget::get_selected_1based` (`widget.rs`): Return the 1-based selected index for a `List`, or `None`; errors on other kinds.
- `Widget::set_border_style` (`widget.rs`): Set the border line style on a `Border` widget; errors on other kinds.
- `Widget::get_border_style` (`widget.rs`): Return the border line style of a `Border` widget; errors on other kinds.
- `Widget::set_title` (`widget.rs`): Set the title string on a `Border` widget; errors on other kinds.
- `Widget::get_title` (`widget.rs`): Return the title string of a `Border` widget; errors on other kinds.
- `Widget::is_button` (`widget.rs`): Return `true` when this widget is a `Button`.
- `Widget::is_textbox` (`widget.rs`): Return `true` when this widget is a `TextBox`.
- `Widget::is_list` (`widget.rs`): Return `true` when this widget is a `List`.
- `Widget::is_panel` (`widget.rs`): Return `true` when this widget is a `Panel`.

## Lua API Reference

- Binding path(s): `src/lua_api/terminal_api.rs`
- Namespace: `lurek.terminal`

### Module Functions
- `lurek.terminal.newTerminal`: Creates a new terminal emulator grid and stages a window size that fits its active cell metrics.
- `lurek.terminal.newLabel`: Creates a new label widget that displays static text at the given cell position.
- `lurek.terminal.newButton`: Creates a new clickable button widget with the given position, size, and label text.
- `lurek.terminal.newTextBox`: Creates a new single-line text input widget at the given position with a fixed width.
- `lurek.terminal.newList`: Creates a new scrollable list widget for displaying and selecting items.
- `lurek.terminal.newBorder`: Creates a new decorative border widget drawn using box-drawing characters.
- `lurek.terminal.newPanel`: Creates a new panel widget that can contain child widgets for grouped layout.
- `lurek.terminal.pushScrollback`: Appends a line of text to the terminal scrollback buffer for later retrieval.
- `lurek.terminal.getScrollback`: Retrieves a range of lines from the terminal scrollback buffer.
- `lurek.terminal.scrollbackLen`: Returns the number of lines currently stored in the terminal scrollback buffer.
- `lurek.terminal.setScrollbackCap`: Sets the maximum number of lines retained in the terminal scrollback buffer. Older lines are discarded when the cap is exceeded.
- `lurek.terminal.pushCmdHistory`: Appends a command string to the terminal command history for up/down arrow recall.
- `lurek.terminal.prevCmd`: Navigates backward in the terminal command history, returning the previous command or nil if at the start.
- `lurek.terminal.nextCmd`: Navigates forward in the terminal command history, returning the next command or nil if at the end.
- `lurek.terminal.cmdHistoryLen`: Returns the number of commands currently stored in the terminal command history.
- `lurek.terminal.clearCmdHistory`: Removes all entries from the terminal command history.
- `lurek.terminal.applyTheme`: Applies a named color theme to the terminal, setting default foreground and background colors.
- `lurek.terminal.printHighlighted`: Renders syntax-highlighted text onto the terminal grid using a table of highlight rules with regex patterns and colors.
- `lurek.terminal.stripAnsi`: Removes all ANSI escape sequences from a string, returning plain text.
- `lurek.terminal.parseAnsi`: Parses ANSI escape sequences in a string into an array of span tables with text, bold, fg, and bg fields.
- `lurek.terminal.printAnsi`: Renders ANSI-colored text directly onto the terminal grid at the given cell position.
- `lurek.terminal.addCompletion`: Registers a candidate string for tab-completion in the shared completion engine.
- `lurek.terminal.removeCompletion`: Removes a previously registered completion candidate from the shared completion engine.
- `lurek.terminal.clearCompletions`: Removes all registered completion candidates from the shared completion engine.
- `lurek.terminal.getCompletions`: Returns all completion candidates matching the given prefix string.
- `lurek.terminal.nextCompletion`: Cycles to the next matching completion candidate for the given prefix, wrapping around after the last match.
- `lurek.terminal.resetCompletion`: Resets the completion cycling state so the next call to nextCompletion starts from the first match.
- `lurek.terminal.getMaxCols`: Returns the engine-defined maximum number of columns a terminal grid can have.
- `lurek.terminal.getMaxRows`: Returns the engine-defined maximum number of rows a terminal grid can have.

### `LTerminal` Methods
- `LTerminal:set`: Writes a character with foreground and background color to a specific cell in the terminal grid.
- `LTerminal:get`: Reads the character and colors at a specific cell in the terminal grid.
- `LTerminal:clear`: Clears all cells in the terminal grid, resetting characters and colors to defaults.
- `LTerminal:print`: Writes text to the terminal grid starting at a specific cell.
- `LTerminal:getDimensions`: Returns the number of columns and rows in the terminal grid.
- `LTerminal:addWidget`: Attaches a widget to this terminal so it is rendered and receives input events.
- `LTerminal:removeWidget`: Detaches a widget from this terminal, removing it from rendering and input handling.
- `LTerminal:clearWidgets`: Removes all attached widgets from this terminal at once.
- `LTerminal:getWidgetCount`: Returns the number of widgets currently attached to this terminal.
- `LTerminal:setFocus`: Sets which widget currently has keyboard focus, or clears focus when nil is passed.
- `LTerminal:getFocused`: Returns the widget that currently has keyboard focus, or nil if no widget is focused.
- `LTerminal:keypressed`: Forwards a key press event to the terminal for widget input processing.
- `LTerminal:textinput`: Forwards a text input event to the terminal for character entry into focused widgets.
- `LTerminal:mousepressed`: Forwards a mouse press event to the terminal, converting pixel coordinates to cell coordinates.
- `LTerminal:render`: Renders the terminal grid and widgets and stages a window size matching the grid and active cell size.
- `LTerminal:setFont`: Selects the nearest built-in bitmap font by pixel height and refits the window to the terminal grid.
- `LTerminal:setCellSize`: Overrides the cell width and height used for rendering this terminal grid and refits the window.
- `LTerminal:resetCellSize`: Removes any custom cell size override, reverting to the active font metrics and refitting the window.
- `LTerminal:getCellSize`: Returns the active terminal cell width and height in pixels, using custom override or font metrics.
- `LTerminal:autoResize`: Requests the window to resize so it exactly fits the terminal grid at the current cell size.
- `LTerminal:type`: Returns the type name string "LTerminal".
- `LTerminal:typeOf`: Checks whether this object matches a given type name. Accepts "LTerminal" or "Object".

### `LWidget` Methods
- `LWidget:setPosition`: Sets the widget position in 1-based cell coordinates within the terminal grid.
- `LWidget:getPosition`: Returns the widget position as 1-based column and row.
- `LWidget:setSize`: Sets the widget dimensions in cell units, clamped to a minimum of 1x1.
- `LWidget:getSize`: Returns the widget dimensions as width and height in cell units.
- `LWidget:setVisible`: Controls whether the widget is drawn and receives input events.
- `LWidget:isVisible`: Returns whether the widget is currently visible.
- `LWidget:setEnabled`: Controls whether the widget accepts user interaction (clicks, typing).
- `LWidget:isEnabled`: Returns whether the widget is currently enabled for user interaction.
- `LWidget:setTag`: Assigns an arbitrary string tag to the widget for identification or grouping.
- `LWidget:getTag`: Returns the current tag string assigned to the widget.
- `LWidget:setText`: Sets the display text of a label, button, or text box widget. Fires the onChange callback if the text actually changed.
- `LWidget:getText`: Returns the current text content of a label, button, or text box widget.
- `LWidget:setColor`: Sets the foreground color of the widget as RGBA components (0-1 range).
- `LWidget:getColor`: Returns the foreground color of the widget as RGBA components.
- `LWidget:setOnClick`: Registers a callback function invoked when a button widget is clicked. Only valid for button widgets.
- `LWidget:setMaxLength`: Sets the maximum number of characters allowed in a text box widget.
- `LWidget:getMaxLength`: Returns the maximum character limit of a text box widget.
- `LWidget:setOnChange`: Registers a callback function invoked when the text content of a text box widget changes. Only valid for text box widgets.
- `LWidget:addItem`: Appends a text item to a list widget.
- `LWidget:removeItem`: Removes a list item by its 1-based index.
- `LWidget:clearItems`: Removes all items from a list widget.
- `LWidget:getItemCount`: Returns the number of items in a list widget.
- `LWidget:getItem`: Returns the text of a list item by its 1-based index.
- `LWidget:setSelected`: Sets the currently selected item in a list widget by 1-based index, or clears the selection with nil. Fires the onSelect callback if changed.
- `LWidget:getSelected`: Returns the 1-based index of the currently selected list item, or nil if nothing is selected.
- `LWidget:setOnSelect`: Registers a callback function invoked when the selected item in a list widget changes. Only valid for list widgets.
- `LWidget:setStyle`: Sets the border drawing style for a border or panel widget.
- `LWidget:getStyle`: Returns the current border style name of a border or panel widget.
- `LWidget:setTitle`: Sets the title text displayed in the border of a border or panel widget.
- `LWidget:getTitle`: Returns the current title text of a border or panel widget.
- `LWidget:addChild`: Adds a child widget to a panel widget. The child becomes part of the panel layout and rendering.
- `LWidget:removeChild`: Removes a child widget from a panel, detaching it from the panel layout.
- `LWidget:clearChildren`: Removes all child widgets from a panel widget.
- `LWidget:getChildCount`: Returns the number of child widgets in a panel widget.
- `LWidget:getChild`: Returns a child widget from a panel by its 1-based index, or nil if the index is out of range.
- `LWidget:type`: Returns the type name string "LWidget".
- `LWidget:typeOf`: Checks whether this object matches a given type name. Accepts "LWidget" or "Object".

## References

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/terminal/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
- Runtime mode config now uses `[tui]` and `[cli]` terminal-grid settings (`cols`, `rows`, `cell_width`, `cell_height`) to size GUI windows for terminal-only startup modes. `--mode=tui` creates a DOS-like terminal-grid window and loads a supplied game, or a built-in TUI screen when no game is supplied. `--mode=cli` creates a GUI-rendered interactive Lua shell backed by `lurek.repl` and rendered through `lurek.terminal`.

### 2026-05-12 Update

- ANSI parser now supports extended SGR color forms:
	- 256-color palette: `38;5;<n>` (fg), `48;5;<n>` (bg)
	- 24-bit true-color: `38;2;<r>;<g>;<b>` (fg), `48;2;<r>;<g>;<b>` (bg)
- Added internal helpers in `src/terminal/ansi.rs`: `parse_extended_color` and `color256`.

### New in 0.14.1

- `Terminal.cell_width_override: Option<f32>` and `cell_height_override: Option<f32>` — per-terminal cell pixel size override (default `None`).
- `Terminal::set_cell_size(w, h)`, `reset_cell_size()`, `get_cell_size() -> Option<(f32,f32)>`.
- Lua: `terminal:setCellSize(w, h)`, `terminal:resetCellSize()`, `terminal:getCellSize()` — returns `{w, h}` table or `nil`.
- `render` respects the override; falls back to font-derived size.
