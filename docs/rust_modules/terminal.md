# terminal

## General Info

- Module group: `Feature Systems`
- Source path: `src/terminal/`
- Binding: `src/lua_api/terminal_api.rs`
- Namespace: `lurek.terminal`
- Lua API surface: `29` functions, `3` types, `59` methods
- Rust test path(s): tests/rust/unit/terminal_tests.rs, tests/rust/ext/terminal_demo_smoke_tests.rs
- Lua test path(s): tests/lua/unit/test_terminal_core_unit.lua

## Summary

This module introduces a highly interactive, character-grid emulator that maps text-based layouts directly into the visual window. By translating virtual screen positions into structured cell matrices, it allows developers to build classic console-like displays and terminal environments within the game runtime. The system stores detailed cell attributes including glyphs, foreground and background colors, and custom styles, serving as the foundational layer for text-mode graphics.

To drive dynamic interactions, the terminal incorporates an advanced ANSI parser that extracts rich styling flags, bold formatting, and full RGB colors from incoming byte streams. This parser coexists with a lightweight syntax highlighter that applies regex-based rules to colorize text on the fly. Furthermore, an intelligent completion engine processes command histories and cycles candidates, offering console navigation and text-entry assistance.

Beyond simple character output, the module features an interactive widget framework built specifically for cell-bound layouts. Standard components include labels, action buttons, scrollable lists, text input fields, and decorative border panels drawn with box characters. These widgets share a unified event model and input dispatcher that maps raw mouse coordinates and key presses to the active widget layout, keeping keyboard focus and mouse interactions intuitive.

Finally, the terminal integrates a powerful render path that projects the active cells and widget compositions directly onto the screen. This system also handles software image snapshots and exports terminal content to static files. When cell metrics or display scales shift, the engine refits the main window to maintain crisp, pixel-perfect text presentation, completing the module's role as a self-contained environment.

Recent runtime work keeps that composition path cheaper by reusing a scratch buffer instead of cloning the full grid for each render-oriented export. Public behavior is unchanged, but the module now does less transient allocation while flattening widgets onto the cell surface.

The widget interaction contract is also locked down more explicitly by regression coverage around focus changes, overlapping widgets, widget removal, and nested panel composition. The module still treats focus and nesting rules as first-class terminal behavior rather than incidental UI details.

## Files

### [ansi.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/terminal/ansi.rs)

- This file interprets ANSI terminal escape sequences so colored or styled text streams can be understood by the in-engine terminal.
- It strips control bytes when plain text is needed and decodes styling spans when visual fidelity matters.
- Classic palette colors, extended xterm indexes, and full RGB forms are all resolved here into engine-friendly color data.
- Span extraction is part of the same logic so one input string can become ordered runs with shared style state.
- Low-level parsing helpers stay close to the decoder because escape handling is sensitive to byte structure and malformed fragments.
- The file is therefore the compatibility layer between external terminal-style output and the engine's own grid renderer.

### [cell.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/terminal/cell.rs)

- This file defines the atomic cell unit that the terminal grid stores for every visible character position.
- It packages glyph and color state into one compact record so the rest of the terminal can treat the screen as a regular matrix.
- The type is the smallest visible building block of the terminal subsystem.

### [completion.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/terminal/completion.rs)

- This file provides the terminal's lightweight completion engine for command-like text entry.
- It manages a candidate set that can be queried by prefix or cycled interactively as the user repeats completion input.
- Dynamic updates are supported because terminal commands and symbols may change while the application is running.
- The file is the discoverability helper for typed terminal interaction.

### [highlighter.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/terminal/highlighter.rs)

- This file applies simple highlighting rules to terminal text so input or output can be visually segmented by meaning.
- Matching produces ordered colored spans instead of immediate cell writes, which keeps highlighting reusable across render paths.
- Rule priority is resolved consistently here so overlapping matches do not create unstable coloring behavior.
- The file is the terminal's lightweight text-coloring layer.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/terminal/mod.rs)

- This module provides the in-engine terminal stack, combining a character grid, ANSI-aware text handling, interactive widgets, and renderer handoff.
- It supports both console-like workflows and text-heavy in-game interfaces built on a cell-based presentation model.
- At the highest level this is the subsystem that lets the engine host terminal behavior as a first-class UI surface.

### [render.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/terminal/render.rs)

- This file converts the composed terminal surface into visual output for both renderer command streams and software image snapshots.
- Grid cells and overlaid widgets are flattened together here so the rest of the engine sees one finished terminal presentation.
- Color mapping and glyph placement are resolved at this stage rather than scattered across terminal state management.
- The file is therefore the terminal subsystem's final visual export layer.

### [text_utils.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/terminal/text_utils.rs)

- This file centralizes UTF-8-safe text helpers shared across terminal internals.
- It provides character counting, character-to-byte indexing, truncation, and leading-byte UTF-8 length decoding.
- The file reduces duplicate text logic between ANSI parsing, widget operations, and terminal state input/render paths.

### [terminal_state.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/terminal/terminal_state.rs)

- This file implements the terminal's main state machine, where the character grid, cursor, colors, histories, widgets, and input routing all meet.
- The core grid behaves like a persistent text surface rather than a transient print stream, allowing callers to treat terminal space as editable UI.
- Resize behavior preserves as much existing content as possible so the terminal remains usable across font or window changes.
- Scrollback and command history live here because they are part of the terminal's long-lived interactive memory rather than renderer output.
- Widget composition is layered on top of the cell grid in this file so buttons, lists, panels, and text boxes share one event and focus model.
- Keyboard, text, and mouse input are dispatched here because only this layer understands both raw terminal coordinates and focused widgets.
- Border and panel behaviors are also coordinated here, giving text-mode interfaces a richer structure than plain character dumps.
- Cell-level writing helpers remain part of this file because direct text painting and higher-level widgets must coexist on the same surface.
- A reusable composition buffer lives here so render-oriented code can flatten widgets over the grid without repeatedly cloning the backing cell buffer.
- Render preparation starts here as well, with the composited foreground and background state turned toward later visual export.
- The file is intentionally large because it is not one helper.
- It is the living behavior model of the entire terminal subsystem.
- Most user-visible terminal semantics, from typing to focus to scrollback, are defined here.
- Without this file the module would have isolated utilities but no unified terminal behavior.
- In practice this is the runtime home of text-mode interaction inside the engine.
- It is where a passive grid becomes a usable terminal environment.

### [widget.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/terminal/widget.rs)

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
