# `fx` — Agent Reference

| Property | Value |
|----------|-------|
| **Tier** | Unassigned |
| **Status** | Implemented — Full |
| **Lua API** | `luna.fx` |
| **Source** | `src/fx/` |
| **Rust Tests** | `tests/unit/fx_tests.rs` |
| **Lua Tests** | `tests/lua/unit/test_fx.lua` |
| **Architecture** | — |

## Summary

The `fx` module provides composable visual effects as pure CPU data models — Tier 2 Engine
Extension. GPU application is handled in `lua_api`. The module is split into two families:

**Post-processing effects** (image-space pipeline): `PostFxEffectType` enumerates all built-in
effect kinds (blur, bloom, chromatic aberration, vignette, etc.). `PostFxEffect` holds the
per-effect parameter bag. `PostFxStack` is an ordered list of active passes applied to canvases
after rendering. `ImageEffect` is a lightweight per-image effect chain for simpler cases.

**Screen overlays** (world-simulation effects): `AmbientState` drives time-of-day colour cycling.
`Overlay` aggregates weather simulation (`WeatherState`, `WeatherParticle`, `WeatherType`),
atmospheric effects (`CloudState`, `FogState`, `HeatHazeState`, `VignetteState`, `FilmGrainState`,
`LightningState`), and one-shot screen events (`FlashState`, `ShakeState`, `FadeState`).

**Scope boundary**: `fx` contains no wgpu code. All GPU resources and rendering passes are
owned by `lua_api`. This module only models effect state that the API layer reads each frame.
## Architecture

```
fx (module root)
  ├── ambient.rs — Ambient lighting state with time-of-day colour cycling. Provides [`AmbientState`] for gradual ambient colour transitions driven by an in-game clock.
  ├── atmosphere.rs — Atmospheric visual effects data models. Contains data-only structs for clouds, fog, vignette, lightning, film grain, and heat haze — all consumed by the overlay renderer.
  ├── effect.rs — Post-processing effect data model. Defines [`PostFxEffect`] — a single named effect with typed parameters for the post-processing pipeline.
  ├── effect_type.rs — Built-in post-processing effect type definitions. Enumerates all shader passes recognised by the engine's post-processing pipeline and provides parameter presets for each.
  ├── image_effect.rs — `ImageEffect` â€” an ordered chain of `PostFxEffect` passes for per-image draw calls. [`ImageEffect`] groups one or more [`PostFxEffect`] entries and converts them to lightweight [`crate::graphics::ShaderPassDescriptor`] values via [`ImageEffect::to_passes`]. This module lives in **Tier 2** and is permitted to import from `crate::graphics` (Tier 1).
  ├── overlay.rs — Composable per-frame overlay system. [`Overlay`] aggregates ambient, atmospheric, weather, and screen effect sub-states and ticks them each frame.
  ├── screen_effects.rs — Full-screen transient effects. Provides [`FlashState`], [`FadeState`], and [`ShakeState`] for brief screen-wide visual feedback.
  ├── stack.rs — Post-processing effect stack. [`PostFxStack`] manages an ordered chain of effects that captures and processes the rendered scene each frame.
  ├── weather.rs — Weather particle system data. Defines [`WeatherType`], [`WeatherParticle`], and [`WeatherState`] for rain, snow, and dust particle overlays.
```

## Source Files

| File | Purpose |
|------|---------|
| `ambient.rs` | Ambient lighting state with time-of-day colour cycling. Provides [`AmbientState`] for gradual ambient colour transitions driven by an in-game clock. |
| `atmosphere.rs` | Atmospheric visual effects data models. Contains data-only structs for clouds, fog, vignette, lightning, film grain, and heat haze — all consumed by the overlay renderer. |
| `effect.rs` | Post-processing effect data model. Defines [`PostFxEffect`] — a single named effect with typed parameters for the post-processing pipeline. |
| `effect_type.rs` | Built-in post-processing effect type definitions. Enumerates all shader passes recognised by the engine's post-processing pipeline and provides parameter presets for each. |
| `image_effect.rs` | `ImageEffect` â€” an ordered chain of `PostFxEffect` passes for per-image draw calls. [`ImageEffect`] groups one or more [`PostFxEffect`] entries and converts them to lightweight [`crate::graphics::ShaderPassDescriptor`] values via [`ImageEffect::to_passes`]. This module lives in **Tier 2** and is permitted to import from `crate::graphics` (Tier 1). |
| `overlay.rs` | Composable per-frame overlay system. [`Overlay`] aggregates ambient, atmospheric, weather, and screen effect sub-states and ticks them each frame. |
| `screen_effects.rs` | Full-screen transient effects. Provides [`FlashState`], [`FadeState`], and [`ShakeState`] for brief screen-wide visual feedback. |
| `stack.rs` | Post-processing effect stack. [`PostFxStack`] manages an ordered chain of effects that captures and processes the rendered scene each frame. |
| `weather.rs` | Weather particle system data. Defines [`WeatherType`], [`WeatherParticle`], and [`WeatherState`] for rain, snow, and dust particle overlays. |

## Submodules

### `fx::ambient`

Ambient lighting state with time-of-day colour cycling. Provides [`AmbientState`] for gradual ambient colour transitions driven by an in-game clock.

- **`AmbientState`** (struct): TODO: one-line description.

### `fx::atmosphere`

Atmospheric visual effects data models. Contains data-only structs for clouds, fog, vignette, lightning, film grain, and heat haze — all consumed by the overlay renderer.

- **`CloudState`** (struct): TODO: one-line description.
- **`FogState`** (struct): TODO: one-line description.
- **`HeatHazeState`** (struct): TODO: one-line description.
- **`VignetteState`** (struct): TODO: one-line description.
- **`FilmGrainState`** (struct): TODO: one-line description.
- **`LightningState`** (struct): TODO: one-line description.

### `fx::effect`

Post-processing effect data model. Defines [`PostFxEffect`] — a single named effect with typed parameters for the post-processing pipeline.

- **`PostFxEffect`** (struct): TODO: one-line description.

### `fx::effect_type`

Built-in post-processing effect type definitions. Enumerates all shader passes recognised by the engine's post-processing pipeline and provides parameter presets for each.

- **`PostFxEffectType`** (enum): TODO: one-line description.

### `fx::image_effect`

`ImageEffect` â€” an ordered chain of `PostFxEffect` passes for per-image draw calls. [`ImageEffect`] groups one or more [`PostFxEffect`] entries and converts them to lightweight [`crate::graphics::ShaderPassDescriptor`] values via [`ImageEffect::to_passes`]. This module lives in **Tier 2** and is permitted to import from `crate::graphics` (Tier 1).

- **`ImageEffect`** (struct): TODO: one-line description.

### `fx::overlay`

Composable per-frame overlay system. [`Overlay`] aggregates ambient, atmospheric, weather, and screen effect sub-states and ticks them each frame.

- **`Overlay`** (struct): TODO: one-line description.

### `fx::screen_effects`

Full-screen transient effects. Provides [`FlashState`], [`FadeState`], and [`ShakeState`] for brief screen-wide visual feedback.

- **`FlashState`** (struct): TODO: one-line description.
- **`ShakeState`** (struct): TODO: one-line description.
- **`FadeState`** (struct): TODO: one-line description.

### `fx::stack`

Post-processing effect stack. [`PostFxStack`] manages an ordered chain of effects that captures and processes the rendered scene each frame.

- **`PostFxStack`** (struct): TODO: one-line description.

### `fx::weather`

Weather particle system data. Defines [`WeatherType`], [`WeatherParticle`], and [`WeatherState`] for rain, snow, and dust particle overlays.

- **`WeatherParticle`** (struct): TODO: one-line description.
- **`WeatherState`** (struct): TODO: one-line description.
- **`WeatherType`** (enum): TODO: one-line description.

## Key Types

### Structs

#### `fx::ambient::AmbientState`

TODO: description from `///` doc comment.

#### `fx::atmosphere::CloudState`

TODO: description from `///` doc comment.

#### `fx::atmosphere::FogState`

TODO: description from `///` doc comment.

#### `fx::atmosphere::HeatHazeState`

TODO: description from `///` doc comment.

#### `fx::atmosphere::VignetteState`

TODO: description from `///` doc comment.

#### `fx::atmosphere::FilmGrainState`

TODO: description from `///` doc comment.

#### `fx::atmosphere::LightningState`

TODO: description from `///` doc comment.

#### `fx::effect::PostFxEffect`

TODO: description from `///` doc comment.

#### `fx::image_effect::ImageEffect`

TODO: description from `///` doc comment.

#### `fx::overlay::Overlay`

TODO: description from `///` doc comment.

#### `fx::screen_effects::FlashState`

TODO: description from `///` doc comment.

#### `fx::screen_effects::ShakeState`

TODO: description from `///` doc comment.

#### `fx::screen_effects::FadeState`

TODO: description from `///` doc comment.

#### `fx::stack::PostFxStack`

TODO: description from `///` doc comment.

#### `fx::weather::WeatherParticle`

TODO: description from `///` doc comment.

#### `fx::weather::WeatherState`

TODO: description from `///` doc comment.

### Enums

#### `fx::effect_type::PostFxEffectType`

TODO: description from `///` doc comment.

#### `fx::weather::WeatherType`

TODO: description from `///` doc comment.

## Lua API

Exposed under `luna.fx.*` by `src\lua_api\fx_api.rs`.

TODO: Describe the overall API surface. List the major categories of functions.

Exposed functions include: `fx`.

## Lua Examples

```lua
-- Example: Basic fx usage
function luna.load()
    -- TODO: replace with real fx setup
    local obj = luna.fx.fx()
end

function luna.update(dt)
    -- TODO: update logic
end
```

## Item Summary

| Kind | Count |
|------|-------|
| `struct` | 16 |
| `enum`   | 2 |
| `fn`     | 0 |
| **Total** | **18** |

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
