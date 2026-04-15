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

### ❌ TODO — ANSI Escape Code Support
**Source**: features/terminal.md — Feature Gaps #9 / Suggestions #4

No `\033[31m` style color/cursor codes. Enabling ANSI would allow piping standard
terminal program output into the widget.

---

### ✅ DONE — Syntax Highlighting
**Source**: features/terminal.md — Feature Gaps #3 / Suggestions #3

`lurek.terminal.printHighlighted(t, col, row, text, rules)` added.
Rules: array of `{pattern=string, fg={r,g,b}, bg={r,g,b}?}`. Plain `str::contains` matching.
First matching rule wins per token. Non-matching text uses white foreground.

---

### ❌ TODO — Configurable Cell Size / Custom Font
**Source**: features/terminal.md — Feature Gaps #8 / Suggestions #5

Cell size hardcoded at 8×14. No `terminal:setCellSize(w, h)` or font override.

---

### ✅ DONE — Color Themes
**Source**: features/terminal.md — Feature Gaps #6 / Suggestions #6

`lurek.terminal.applyTheme(t, name)` added. Built-in themes: `"solarized_dark"`, `"solarized_light"`,
`"monokai"`, `"dracula"`, `"nord"`. Recolours all existing grid cells via `set_default_colors()`.

---

### ❌ TODO — Tab Completion
**Source**: features/terminal.md — Feature Gaps #4

No autocomplete mechanism for TextBox inputs.

---

### 🔇 LOW — Cursor Blinking
**Source**: features/terminal.md — Feature Gaps #10

No cursor blink animation. Minor cosmetic gap.
