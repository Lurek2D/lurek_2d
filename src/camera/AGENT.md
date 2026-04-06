# `camera` — Agent Reference

| Property | Value |
|----------|-------|
| **Tier** | Tier 1 — Core Engine Subsystems |
| **Status** | Implemented — Full |
| **Lua API** | `luna.camera` |
| **Source** | `src/camera/` |
| **Rust Tests** | `tests/unit/camera_tests.rs` |
| **Lua Tests** | `tests/lua/unit/test_camera.lua` |
| **Architecture** | — |

## Summary

The `camera` module provides camera and viewport types for 2D rendering. It is a Tier 1
Engine Subsystem extracted from `src/graphics/` and depends only on `crate::math`.

`Camera` holds a 2D position and zoom level and exposes `view_matrix()` — a `Mat3` passed to
the GPU renderer on every draw call. `Camera2D` extends this with rotation and a configurable
anchor point. `Viewport` maps a fixed logical resolution (e.g. 1280×720) onto the physical
window using one of six `ScaleMode` strategies (Stretch, LetterBox, PixelPerfect, Expand,
Fill, Integer). `ViewportScale` extends `Viewport` with automatic scaled-dimension caching.

`SharedState` holds a `Camera` field; scripts update it via `luna.camera.*` and the renderer
reads it each frame through `SharedState::camera`.

**Scope boundary**: Camera math lives here; render-pass binding and uniform upload happen in
`src/graphics/gpu_renderer.rs`. No winit or wgpu types appear in this module.
## Architecture

```
camera (module root)
  ├── types.rs — Camera types for 2D viewport control. Provides the original [`Camera`] (used by `SharedState` for the flat `luna.graphics.setCamera()` API) and the new Phase 24 [`Camera2D`] with smooth follow, dead zone, bounds clamping, and screen-shake.
  ├── viewport.rs — Virtual resolution viewport with manual transform application. Maps a fixed game resolution onto an arbitrary window size using letterboxing, stretching, or pixel-perfect scaling. This module is part of Luna2D's `graphics` subsystem and provides the implementation details for viewport-related operations and data management. Key types exported from this module: `ScaleMode`, `Viewport`. Primary functions: `new()`, `resize()`, `get_scale()`, `get_offset()`. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.
  ├── viewport_scale.rs — Virtual resolution viewport with automatic scaling and transform stack integration. Like `Viewport`, but also tracks the scaled content dimensions for use with an automatic graphics transform stack. This module is part of Luna2D's `graphics` subsystem and provides the implementation details for viewport scale-related operations and data management. Key types exported from this module: `ViewportScale`. Primary functions: `new()`, `resize()`, `get_game_dimensions()`, `get_scaled_dimensions()`. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.
```

## Source Files

| File | Purpose |
|------|---------|
| `types.rs` | Camera types for 2D viewport control. Provides the original [`Camera`] (used by `SharedState` for the flat `luna.graphics.setCamera()` API) and the new Phase 24 [`Camera2D`] with smooth follow, dead zone, bounds clamping, and screen-shake. |
| `viewport.rs` | Virtual resolution viewport with manual transform application. Maps a fixed game resolution onto an arbitrary window size using letterboxing, stretching, or pixel-perfect scaling. This module is part of Luna2D's `graphics` subsystem and provides the implementation details for viewport-related operations and data management. Key types exported from this module: `ScaleMode`, `Viewport`. Primary functions: `new()`, `resize()`, `get_scale()`, `get_offset()`. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface. |
| `viewport_scale.rs` | Virtual resolution viewport with automatic scaling and transform stack integration. Like `Viewport`, but also tracks the scaled content dimensions for use with an automatic graphics transform stack. This module is part of Luna2D's `graphics` subsystem and provides the implementation details for viewport scale-related operations and data management. Key types exported from this module: `ViewportScale`. Primary functions: `new()`, `resize()`, `get_game_dimensions()`, `get_scaled_dimensions()`. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface. |

## Submodules

### `camera::types`

Camera types for 2D viewport control. Provides the original [`Camera`] (used by `SharedState` for the flat `luna.graphics.setCamera()` API) and the new Phase 24 [`Camera2D`] with smooth follow, dead zone, bounds clamping, and screen-shake.

- **`Camera`** (struct): TODO: one-line description.
- **`Camera2D`** (struct): TODO: one-line description.

### `camera::viewport`

Virtual resolution viewport with manual transform application. Maps a fixed game resolution onto an arbitrary window size using letterboxing, stretching, or pixel-perfect scaling. This module is part of Luna2D's `graphics` subsystem and provides the implementation details for viewport-related operations and data management. Key types exported from this module: `ScaleMode`, `Viewport`. Primary functions: `new()`, `resize()`, `get_scale()`, `get_offset()`. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.

- **`Viewport`** (struct): TODO: one-line description.
- **`ScaleMode`** (enum): TODO: one-line description.

### `camera::viewport_scale`

Virtual resolution viewport with automatic scaling and transform stack integration. Like `Viewport`, but also tracks the scaled content dimensions for use with an automatic graphics transform stack. This module is part of Luna2D's `graphics` subsystem and provides the implementation details for viewport scale-related operations and data management. Key types exported from this module: `ViewportScale`. Primary functions: `new()`, `resize()`, `get_game_dimensions()`, `get_scaled_dimensions()`. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.

- **`ViewportScale`** (struct): TODO: one-line description.

## Key Types

### Structs

#### `camera::types::Camera`

TODO: description from `///` doc comment.

#### `camera::types::Camera2D`

TODO: description from `///` doc comment.

#### `camera::viewport::Viewport`

TODO: description from `///` doc comment.

#### `camera::viewport_scale::ViewportScale`

TODO: description from `///` doc comment.

### Enums

#### `camera::viewport::ScaleMode`

TODO: description from `///` doc comment.

## Lua API

Exposed under `luna.camera.*` by `src\lua_api\camera_api.rs`.

TODO: Describe the overall API surface. List the major categories of functions.

Exposed functions include: `camera`.

## Lua Examples

```lua
-- Example: Basic camera usage
function luna.load()
    -- TODO: replace with real camera setup
    local obj = luna.camera.camera()
end

function luna.update(dt)
    -- TODO: update logic
end
```

## Item Summary

| Kind | Count |
|------|-------|
| `struct` | 4 |
| `enum`   | 1 |
| `fn`     | 0 |
| **Total** | **5** |

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
