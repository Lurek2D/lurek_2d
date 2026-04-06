# `window` — Agent Reference

| Property | Value |
|----------|-------|
| **Tier** | Tier 1 — Core Engine Subsystems |
| **Status** | Implemented — Full |
| **Lua API** | `luna.window` |
| **Source** | `src/window/` |
| **Rust Tests** | `tests/unit/window_tests.rs` |
| **Lua Tests** | `tests/lua/unit/test_window.lua` |
| **Architecture** | — |

## Summary

The `window` module manages window lifecycle and properties in response to Lua API calls.
It is a Tier 1 Engine Subsystem.

The module provides pure Rust helper functions that read and write `WindowState` fields in
`SharedState`. **No winit calls are made here.** Deferred operations (title change, fullscreen
toggle, resize, icon update) are written into `pending_*` fields that `engine::app::App`
consumes at the start of the next frame — this separation keeps the module winit-free and
testable without a display server.

Sub-modules: `management` handles title, fullscreen, vsync, position, size, minimize, maximize,
close, and icon; `viewport` manages logical dimensions, scale mode, and pixel ↔ game-space
coordinate conversion; `event_loop` is reserved for future platform-specific integration.

Scripts interact via `luna.window.setTitle(t)`, `luna.window.setFullscreen(true/false)`,
`luna.window.getWidth()`, `luna.window.toPixels(x, y)`, and related functions.

**Scope boundary**: Event loop integration and actual OS window manipulation live in
`engine::app`. This module only mutates the `WindowState` shadow record.
## Architecture

```
window (module root)
  ├── event_loop.rs — Event Loop implementation for the `window` subsystem. This module is part of Luna2D's `window` subsystem and provides the implementation details for event loop-related operations and data management. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.
  ├── management.rs — Window management commands — title, fullscreen, vsync, position, size, minimize, maximize, close, icon, focus query, and DPI scale. Every function takes `&WindowState` or `&mut WindowState` directly.  No winit calls are made here.  Deferred operations are stored in `pending_*` fields and executed by `engine::app::App` at the start of the next frame.
  ├── viewport.rs — Viewport and coordinate-space utilities — logical game dimensions, scale mode, and pixel ↔ game-space coordinate conversion. `viewport_scale_x / _y` and `viewport_offset_x / _y` are computed by `engine::app` whenever the window is resized or the scale mode changes.  These functions treat the pre-computed values as read-only; callers should use [`set_scale_mode`] to request a change.
```

## Source Files

| File | Purpose |
|------|---------|
| `event_loop.rs` | Event Loop implementation for the `window` subsystem. This module is part of Luna2D's `window` subsystem and provides the implementation details for event loop-related operations and data management. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface. |
| `management.rs` | Window management commands — title, fullscreen, vsync, position, size, minimize, maximize, close, icon, focus query, and DPI scale. Every function takes `&WindowState` or `&mut WindowState` directly.  No winit calls are made here.  Deferred operations are stored in `pending_*` fields and executed by `engine::app::App` at the start of the next frame. |
| `viewport.rs` | Viewport and coordinate-space utilities — logical game dimensions, scale mode, and pixel ↔ game-space coordinate conversion. `viewport_scale_x / _y` and `viewport_offset_x / _y` are computed by `engine::app` whenever the window is resized or the scale mode changes.  These functions treat the pre-computed values as read-only; callers should use [`set_scale_mode`] to request a change. |

## Submodules

### `window::event_loop`

Event Loop implementation for the `window` subsystem. This module is part of Luna2D's `window` subsystem and provides the implementation details for event loop-related operations and data management. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.

### `window::management`

Window management commands — title, fullscreen, vsync, position, size, minimize, maximize, close, icon, focus query, and DPI scale. Every function takes `&WindowState` or `&mut WindowState` directly.  No winit calls are made here.  Deferred operations are stored in `pending_*` fields and executed by `engine::app::App` at the start of the next frame.

- **`ModeInfo`** (struct): TODO: one-line description.

### `window::viewport`

Viewport and coordinate-space utilities — logical game dimensions, scale mode, and pixel ↔ game-space coordinate conversion. `viewport_scale_x / _y` and `viewport_offset_x / _y` are computed by `engine::app` whenever the window is resized or the scale mode changes.  These functions treat the pre-computed values as read-only; callers should use [`set_scale_mode`] to request a change.

- **`ScaleInfo`** (struct): TODO: one-line description.

## Key Types

### Structs

#### `window::management::ModeInfo`

TODO: description from `///` doc comment.

#### `window::viewport::ScaleInfo`

TODO: description from `///` doc comment.

### Enums

No public enums.

## Lua API

Exposed under `luna.window.*` by `src\lua_api\window_api.rs`.

TODO: Describe the overall API surface. List the major categories of functions.

Exposed functions include: `focus`, `isOpen`, `window`.

## Lua Examples

```lua
-- Example: Basic window usage
function luna.load()
    -- TODO: replace with real window setup
    local obj = luna.window.focus()
end

function luna.update(dt)
    -- TODO: update logic
end
```

## Item Summary

| Kind | Count |
|------|-------|
| `struct` | 2 |
| `enum`   | 0 |
| `fn`     | 36 |
| **Total** | **38** |

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
