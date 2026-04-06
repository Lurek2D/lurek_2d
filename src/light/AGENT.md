# `light` — Agent Reference

| Property | Value |
|----------|-------|
| **Tier** | Unassigned |
| **Status** | Implemented — Full |
| **Lua API** | `luna.light` |
| **Source** | `src/light/` |
| **Rust Tests** | `tests/unit/light_tests.rs` |
| **Lua Tests** | `tests/lua/unit/test_light.lua` |
| **Architecture** | — |

## Summary

The `light` module implements a 2D dynamic lighting system with per-light attenuation,
multiple falloff curves, flicker effects, and optional shadow casting. It is a Tier 1
Engine Subsystem.

`Light2D` is the primary type representing a point or directional light with colour, radius,
intensity, and a `LightType` variant. `LightWorld` aggregates all active lights and occluders
for a scene. `Occluder` defines a shadow-casting polygon in world space. `Attenuation` controls
how light intensity falls off with distance, using curves specified by `FalloffMode`
(Linear, Quadratic, InverseSquare, Custom). `FlickerConfig` drives pseudo-random intensity
variation using a seed, amplitude, and frequency. `LightBlendMode` selects how light
contributions are composited into the scene.

Scripts create lights via `luna.light.*`, update positions each frame, and call
`luna.light.render(world)` to produce the final lit scene through `lua_api`.

**Scope boundary**: Ray-march or shadow-map GPU passes live in `lua_api` or `graphics`.
This module holds only CPU-side light state and spatial data.
## Architecture

```
light (module root)
  ├── attenuation.rs — Custom attenuation coefficients for light falloff curves.
  ├── blend_mode.rs — Light blend mode enum for controlling how light color mixes with the scene.
  ├── falloff.rs — Falloff mode enum for controlling how light intensity decays over distance.
  ├── flicker.rs — Built-in flicker effect configuration for lights.
  ├── light2d.rs — 2D point light data container for lighting systems. This module is part of Luna2D's `graphics` subsystem and provides the implementation details for light2d-related operations and data management. Key types exported from this module: `Light2D`. Primary functions: `new()`, `set_position()`, `get_position()`, `set_radius()`. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.
  ├── light_type.rs — Light type enum for point, directional, and spot lights.
  ├── light_world.rs — Resource pool and state for the 2D lighting system.
  ├── occluder.rs — Polygon shadow caster for the 2D lighting system.
  ├── shadow.rs — Shadow filter enum for controlling edge quality of shadow boundaries.
```

## Source Files

| File | Purpose |
|------|---------|
| `attenuation.rs` | Custom attenuation coefficients for light falloff curves. |
| `blend_mode.rs` | Light blend mode enum for controlling how light color mixes with the scene. |
| `falloff.rs` | Falloff mode enum for controlling how light intensity decays over distance. |
| `flicker.rs` | Built-in flicker effect configuration for lights. |
| `light2d.rs` | 2D point light data container for lighting systems. This module is part of Luna2D's `graphics` subsystem and provides the implementation details for light2d-related operations and data management. Key types exported from this module: `Light2D`. Primary functions: `new()`, `set_position()`, `get_position()`, `set_radius()`. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface. |
| `light_type.rs` | Light type enum for point, directional, and spot lights. |
| `light_world.rs` | Resource pool and state for the 2D lighting system. |
| `occluder.rs` | Polygon shadow caster for the 2D lighting system. |
| `shadow.rs` | Shadow filter enum for controlling edge quality of shadow boundaries. |

## Submodules

### `light::attenuation`

Custom attenuation coefficients for light falloff curves.

- **`Attenuation`** (struct): TODO: one-line description.

### `light::blend_mode`

Light blend mode enum for controlling how light color mixes with the scene.

- **`LightBlendMode`** (enum): TODO: one-line description.

### `light::falloff`

Falloff mode enum for controlling how light intensity decays over distance.

- **`FalloffMode`** (enum): TODO: one-line description.

### `light::flicker`

Built-in flicker effect configuration for lights.

- **`FlickerConfig`** (struct): TODO: one-line description.

### `light::light2d`

2D point light data container for lighting systems. This module is part of Luna2D's `graphics` subsystem and provides the implementation details for light2d-related operations and data management. Key types exported from this module: `Light2D`. Primary functions: `new()`, `set_position()`, `get_position()`, `set_radius()`. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.

- **`Light2D`** (struct): TODO: one-line description.

### `light::light_type`

Light type enum for point, directional, and spot lights.

- **`LightType`** (enum): TODO: one-line description.

### `light::light_world`

Resource pool and state for the 2D lighting system.

- **`LightWorld`** (struct): TODO: one-line description.

### `light::occluder`

Polygon shadow caster for the 2D lighting system.

- **`Occluder`** (struct): TODO: one-line description.

### `light::shadow`

Shadow filter enum for controlling edge quality of shadow boundaries.

- **`ShadowFilter`** (enum): TODO: one-line description.

## Key Types

### Structs

#### `light::attenuation::Attenuation`

TODO: description from `///` doc comment.

#### `light::flicker::FlickerConfig`

TODO: description from `///` doc comment.

#### `light::light2d::Light2D`

TODO: description from `///` doc comment.

#### `light::light_world::LightWorld`

TODO: description from `///` doc comment.

#### `light::occluder::Occluder`

TODO: description from `///` doc comment.

### Enums

#### `light::blend_mode::LightBlendMode`

TODO: description from `///` doc comment.

#### `light::falloff::FalloffMode`

TODO: description from `///` doc comment.

#### `light::light_type::LightType`

TODO: description from `///` doc comment.

#### `light::shadow::ShadowFilter`

TODO: description from `///` doc comment.

## Lua API

Exposed under `luna.light.*` by `src\lua_api\light_api.rs`.

TODO: Describe the overall API surface. List the major categories of functions.

Exposed functions include: `light`.

## Lua Examples

```lua
-- Example: Basic light usage
function luna.load()
    -- TODO: replace with real light setup
    local obj = luna.light.light()
end

function luna.update(dt)
    -- TODO: update logic
end
```

## Item Summary

| Kind | Count |
|------|-------|
| `struct` | 5 |
| `enum`   | 4 |
| `fn`     | 0 |
| **Total** | **9** |

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
