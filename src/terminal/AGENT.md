# `terminal` — Agent Reference

| Property | Value |
|----------|-------|
| **Tier** | Unassigned |
| **Status** | Implemented — Full |
| **Lua API** | `luna.terminal` |
| **Source** | `src/terminal/` |
| **Rust Tests** | `tests/unit/terminal_tests.rs` |
| **Lua Tests** | `tests/lua/unit/test_terminal.lua` |
| **Architecture** | — |

## Summary

The `terminal` module provides a grid-based character-cell terminal emulator with a widget
toolkit for building in-game developer consoles, debug overlays, and REPL interfaces. It is
a Tier 2 Engine Extension gated by the `modules.terminal` config flag (requires graphics).

`Terminal` owns a 2D grid of `TCell` values (character + foreground/background colour bitmask).
`WidgetBase` provides shared layout and event routing for all widget types. `WidgetKind`
variants — `Label`, `Button`, `TextBox`, `List`, `Border`, `Panel` — compose into a widget
tree rooted at a panel. `BorderStyle` selects the box-drawing character set.

Scripts create a terminal via `luna.terminal.new(cols, rows)`, add widgets, handle input in
`luna.keypressed` callbacks, and call `luna.terminal.draw(t, x, y)` each frame. The terminal
produces draw calls via `luna.graphics` and does not own any GPU resources directly.

**Scope boundary**: `terminal` is a Tier 2 module; it must not import other Tier 2 modules.
It does not contain font rasterisation (handled by `graphics`) or file I/O.
## Architecture

```
terminal (module root)
  ├── cell.rs — Cell data types for the terminal grid.
  ├── terminal_state.rs — Terminal grid state and input handling.
  ├── widget.rs — Widget types for the terminal UI system.
```

## Source Files

| File | Purpose |
|------|---------|
| `cell.rs` | Cell data types for the terminal grid. |
| `terminal_state.rs` | Terminal grid state and input handling. |
| `widget.rs` | Widget types for the terminal UI system. |

## Submodules

### `terminal::cell`

Cell data types for the terminal grid.

- **`TCell`** (struct): TODO: one-line description.

### `terminal::terminal_state`

Terminal grid state and input handling.

- **`Terminal`** (struct): TODO: one-line description.

### `terminal::widget`

Widget types for the terminal UI system.

- **`WidgetBase`** (struct): TODO: one-line description.
- **`Widget`** (struct): TODO: one-line description.
- **`BorderStyle`** (enum): TODO: one-line description.
- **`WidgetKind`** (enum): TODO: one-line description.

## Key Types

### Structs

#### `terminal::cell::TCell`

TODO: description from `///` doc comment.

#### `terminal::terminal_state::Terminal`

TODO: description from `///` doc comment.

#### `terminal::widget::WidgetBase`

TODO: description from `///` doc comment.

#### `terminal::widget::Widget`

TODO: description from `///` doc comment.

### Enums

#### `terminal::widget::BorderStyle`

TODO: description from `///` doc comment.

#### `terminal::widget::WidgetKind`

TODO: description from `///` doc comment.

## Lua API

Exposed under `luna.terminal.*` by `src\lua_api\terminal_api.rs`.

TODO: Describe the overall API surface. List the major categories of functions.

Exposed functions include: `terminal`.

## Lua Examples

```lua
-- Example: Basic terminal usage
function luna.load()
    -- TODO: replace with real terminal setup
    local obj = luna.terminal.terminal()
end

function luna.update(dt)
    -- TODO: update logic
end
```

## Item Summary

| Kind | Count |
|------|-------|
| `struct` | 4 |
| `enum`   | 2 |
| `fn`     | 0 |
| **Total** | **6** |

## References

| Module | Relationship | Notes |
|--------|--------------|-------|
| `engine` | Imports from | Uses SharedState, EngineError |
| `math` | Imports from | Vec2, Color, Rect |
| `lua_api` | Imported by | Binds public API to Lua |

TODO: Add entries for similar modules and explain the separation of duties.

## Notes

TODO: Document unique facts an agent must know before editing this module:
- External crate constraints (version, thread-safety, API limitations)
- Hardware or OS-specific behaviour (e.g., headless fallback on CI)
- Known limitations or intentional omissions
- Best practices and anti-patterns for this module
- What Lua scripts will break if the API changes
