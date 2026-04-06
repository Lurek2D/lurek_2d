# `minimap` — Agent Reference

| Property | Value |
|----------|-------|
| **Tier** | Tier 2 — Reusable Engine Extensions |
| **Status** | Implemented — Full |
| **Lua API** | `luna.minimap` |
| **Source** | `src/minimap/` |
| **Rust Tests** | `tests/unit/minimap_tests.rs` |
| **Lua Tests** | `tests/lua/unit/test_minimap.lua` |
| **Architecture** | — |

## Summary

The `minimap` module provides grid-based minimap data structures for overhead map displays.
It is a Tier 2 Engine Extension with no GPU dependencies — it is a pure CPU data-model module.

`Minimap` holds a fixed-size terrain colour grid, a fog-of-war visibility mask, a list of
tracked `MinimapObject` entities (position, colour, size, icon), as well as `MinimapMarker`
stamps and `MinimapPing` temporary flashes. A viewport rectangle shows the camera frustum on
the minimap surface. `MinimapTerrain` enumerates the preset terrain colour palette.

Scripts call `luna.minimap.new(width, height)` to create a minimap, update it each frame by
setting terrain tiles and object positions, then draw it via `luna.minimap.draw(mm, x, y)`.
The minimap module produces a pixel buffer that `lua_api` uploads as a texture each frame.

**Scope boundary**: All GPU upload and draw-call submission is handled by `lua_api`. The
`minimap` module has no wgpu imports and does not know about screen coordinates.
## Architecture

```
minimap (module root)
  ├── minimap.rs — Core `Minimap` data model: terrain grid, fog of war, objects, pings, markers, and navigation.
  ├── types.rs — Supporting types for the minimap module: enums and plain data structs.
```

## Source Files

| File | Purpose |
|------|---------|
| `minimap.rs` | Core `Minimap` data model: terrain grid, fog of war, objects, pings, markers, and navigation. |
| `types.rs` | Supporting types for the minimap module: enums and plain data structs. |

## Submodules

### `minimap::minimap`

Core `Minimap` data model: terrain grid, fog of war, objects, pings, markers, and navigation.

- **`Minimap`** (struct): TODO: one-line description.

### `minimap::types`

Supporting types for the minimap module: enums and plain data structs.

- **`MinimapObjectType`** (struct): TODO: one-line description.
- **`MinimapObject`** (struct): TODO: one-line description.
- **`MinimapPing`** (struct): TODO: one-line description.
- **`MinimapMarker`** (struct): TODO: one-line description.
- **`ColorMode`** (enum): TODO: one-line description.
- **`FogLevel`** (enum): TODO: one-line description.

## Key Types

### Structs

#### `minimap::minimap::Minimap`

TODO: description from `///` doc comment.

#### `minimap::types::MinimapObjectType`

TODO: description from `///` doc comment.

#### `minimap::types::MinimapObject`

TODO: description from `///` doc comment.

#### `minimap::types::MinimapPing`

TODO: description from `///` doc comment.

#### `minimap::types::MinimapMarker`

TODO: description from `///` doc comment.

### Enums

#### `minimap::types::ColorMode`

TODO: description from `///` doc comment.

#### `minimap::types::FogLevel`

TODO: description from `///` doc comment.

## Lua API

Exposed under `luna.minimap.*` by `src\lua_api\minimap_api.rs`.

TODO: Describe the overall API surface. List the major categories of functions.

Exposed functions include: `minimap`.

## Lua Examples

```lua
-- Example: Basic minimap usage
function luna.load()
    -- TODO: replace with real minimap setup
    local obj = luna.minimap.minimap()
end

function luna.update(dt)
    -- TODO: update logic
end
```

## Item Summary

| Kind | Count |
|------|-------|
| `struct` | 5 |
| `enum`   | 2 |
| `fn`     | 0 |
| **Total** | **7** |

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
