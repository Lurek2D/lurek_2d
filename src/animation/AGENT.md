# `animation` — Agent Reference

| Property | Value |
|----------|-------|
| **Tier** | Tier 1 — Core Engine Subsystems |
| **Status** | Implemented — Full |
| **Lua API** | `luna.animation` |
| **Source** | `src/animation/` |
| **Rust Tests** | `tests/unit/animation_tests.rs` |
| **Lua Tests** | `tests/lua/unit/test_animation.lua` |
| **Architecture** | — |

## Summary

The `animation` module provides frame-based sprite animation for 2D characters and objects.
It is a Tier 1 Engine Subsystem that depends only on `crate::math` and `crate::engine`.

The module is built around three data types: `AnimClip` names a sequence of frame indices;
`AnimFrame` records a source rectangle plus an optional per-frame display duration; and
`Animation` is the live playback controller that advances through clips using delta time,
fires `AnimEvent` markers at specified frames, and can loop, reverse, or halt on the last frame.

Scripts interact via `luna.animation.*` — creating animations, adding clips, updating each
frame with `update(dt)`, and querying the current frame rectangle for use in `luna.graphics.draw()`.

**Scope boundary**: This module contains no GPU code. Uploading textures and issuing draw calls
is handled by `luna_api::graphics_api`. Physics or sound triggered by animation events must
be wired by user scripts, not by the animation module itself.
## Architecture

```
animation (module root)
  ├── clip.rs — [`AnimClip`] — a named animation clip referencing frames by index.
  ├── controller.rs — [`Animation`] — main controller for sprite animation playback.
  ├── event.rs — [`AnimEvent`] — events emitted during animation playback.
  ├── frame.rs — [`AnimFrame`] — a single animation frame with a source rectangle and optional duration.
```

## Source Files

| File | Purpose |
|------|---------|
| `clip.rs` | [`AnimClip`] — a named animation clip referencing frames by index. |
| `controller.rs` | [`Animation`] — main controller for sprite animation playback. |
| `event.rs` | [`AnimEvent`] — events emitted during animation playback. |
| `frame.rs` | [`AnimFrame`] — a single animation frame with a source rectangle and optional duration. |

## Submodules

### `animation::clip`

[`AnimClip`] — a named animation clip referencing frames by index.

- **`AnimClip`** (struct): TODO: one-line description.

### `animation::controller`

[`Animation`] — main controller for sprite animation playback.

- **`Animation`** (struct): TODO: one-line description.

### `animation::event`

[`AnimEvent`] — events emitted during animation playback.

- **`AnimEvent`** (enum): TODO: one-line description.

### `animation::frame`

[`AnimFrame`] — a single animation frame with a source rectangle and optional duration.

- **`AnimFrame`** (struct): TODO: one-line description.

## Key Types

### Structs

#### `animation::clip::AnimClip`

TODO: description from `///` doc comment.

#### `animation::controller::Animation`

TODO: description from `///` doc comment.

#### `animation::frame::AnimFrame`

TODO: description from `///` doc comment.

### Enums

#### `animation::event::AnimEvent`

TODO: description from `///` doc comment.

## Lua API

Exposed under `luna.animation.*` by `src\lua_api\animation_api.rs`.

TODO: Describe the overall API surface. List the major categories of functions.

Exposed functions include: `animation`, `frame`, `type`.

## Lua Examples

```lua
-- Example: Basic animation usage
function luna.load()
    -- TODO: replace with real animation setup
    local obj = luna.animation.animation()
end

function luna.update(dt)
    -- TODO: update logic
end
```

## Item Summary

| Kind | Count |
|------|-------|
| `struct` | 3 |
| `enum`   | 1 |
| `fn`     | 0 |
| **Total** | **4** |

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
