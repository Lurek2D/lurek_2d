# IDEA.md — `terminal` module

> Migrated from `ideas/features/terminal.md`.
> Status checked against `src/terminal/` and `src/lua_api/terminal_api.rs`.
> Lua namespace: `lurek.terminal`.

---

## Features

### ✅ DONE — Character-Cell Grid
**Source**: features/terminal.md — Summary

`lurek.terminal.new(cols, rows)` — grid of `TCell` with fg/bg colors. Default 80×40.

---

### ✅ DONE — 6 Widget Types (Label, Button, TextBox, List, Border, Panel)
**Source**: features/terminal.md — Summary

Full widget toolkit with shared `WidgetBase` (position, size, visible, enabled, focused).

---

### ✅ DONE — Border Styles (Single / Double / Rounded / Heavy / ASCII)
**Source**: features/terminal.md — Summary

5 border styles implemented.

---

### ✅ DONE — Widget Events (Click, TextChange, SelectionChange)
**Source**: features/terminal.md — Summary

Event callbacks on Button click, TextBox text change, List selection change.

---

### ✅ DONE — Scrollback Buffer
**Source**: features/terminal.md — Feature Gaps #1 / Suggestions #1

Scrollback buffer added to `Terminal` struct (`scrollback: Vec<String>`, `scrollback_cap: usize`).
Lua API (module-level functions that accept a Terminal userdata):
`lurek.terminal.pushScrollback(t, line)`, `lurek.terminal.getScrollback(t, offset, count)`,
`lurek.terminal.scrollbackLen(t)`, `lurek.terminal.setScrollbackCap(t, cap)`.

---

### ✅ DONE — Command History (Up/Down Arrow Recall)
**Source**: features/terminal.md — Feature Gaps #2 / Suggestions #2

Command history added to `Terminal` struct (`cmd_history: Vec<String>`, `cmd_cursor: usize`).
Lua API: `lurek.terminal.pushCmdHistory(t, cmd)`, `prevCmd(t)`, `nextCmd(t)`,
`cmdHistoryLen(t)`, `clearCmdHistory(t)`. Returns `nil` when at the live-input boundary.

---

### ✅ DONE — ANSI Escape Code Support
**Source**: features/terminal.md — Feature Gaps #9 / Suggestions #4
**Implemented**: 2026-04-16

`src/terminal/ansi.rs` — `strip_ansi_codes(text)`, `parse_ansi_spans(text)`, `AnsiSpan`, `AnsiColor`.
Supports: SGR reset, bold, standard 8 fg (30-37), bright fg (90-97), standard 8 bg (40-47),
bright bg (100-107).

Lua API in `src/lua_api/terminal_api.rs`:
- `lurek.terminal.stripAnsi(text)` → plain string
- `lurek.terminal.parseAnsi(text)` → array of `{text, bold, fg?, bg?}` span tables
- `lurek.terminal.printAnsi(terminal_ud, col, row, text)` → draws ANSI-coloured text onto terminal

---

### ✅ DONE — Syntax Highlighting
**Source**: features/terminal.md — Feature Gaps #3 / Suggestions #3

`lurek.terminal.printHighlighted(t, col, row, text, rules)` added.
Rules: array of `{pattern=string, fg={r,g,b}, bg={r,g,b}?}`. Plain `str::contains` matching.
First matching rule wins per token. Non-matching text uses white foreground.

---

### ✅ DONE — Configurable Cell Size / Custom Font
**Source**: features/terminal.md — Feature Gaps #8 / Suggestions #5

`Terminal` struct now carries `cell_width_override: Option<f32>` and
`cell_height_override: Option<f32>` fields (default `None` — auto from font).
Methods: `set_cell_size(w, h)`, `reset_cell_size()`, `get_cell_size() -> Option<(f32,f32)>`.
Lua API: `terminal:setCellSize(w, h)`, `terminal:resetCellSize()`, `terminal:getCellSize()`.
The `render` method respects the override when set, otherwise falls back to font-derived size.
Tests: `tests/lua/unit/test_terminal_cell_size.lua`.

---

### ✅ DONE — Color Themes
**Source**: features/terminal.md — Feature Gaps #6 / Suggestions #6

`lurek.terminal.applyTheme(t, name)` added. Built-in themes: `"solarized_dark"`, `"solarized_light"`,
`"monokai"`, `"dracula"`, `"nord"`. Recolours all existing grid cells via `set_default_colors()`.

---

### ✅ DONE — Tab Completion
**Source**: features/terminal.md — Feature Gaps #4
**Implemented**: 2026-04-16

`src/terminal/completion.rs` — `CompletionEngine` with sorted candidate list and cycling cursor.

Lua API in `src/lua_api/terminal_api.rs`:
- `lurek.terminal.addCompletion(candidate)` — register a completion string
- `lurek.terminal.removeCompletion(candidate)` — deregister
- `lurek.terminal.clearCompletions()` — clear all
- `lurek.terminal.getCompletions(prefix)` → sorted array of matches
- `lurek.terminal.nextCompletion(prefix)` → next candidate string (cycling), or nil
- `lurek.terminal.resetCompletion()` — reset cycle state without clearing candidates

Tests: `tests/lua/unit/test_terminal_ansi_completion.lua` — 16 BDD cases.

---

### 🔇 LOW — Cursor Blinking
**Source**: features/terminal.md — Feature Gaps #10

No cursor blink animation. Minor cosmetic gap.
