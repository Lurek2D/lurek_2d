# overlay

> Screen overlay system: weather, atmosphere, screen effects, and transitions.

## Purpose

Provides visual layers drawn BETWEEN the game world and the player. Unlike
post-processing effects (which modify the rendered frame via shaders), overlays
ADD visual elements: rain/snow particles, fog, flash/shake/fade effects, screen
transitions, ambient color tinting, water distortion, and lightning.

## Architecture

- **Tier:** Feature Systems
- **Dependencies:** render (for compositing), math (vectors/interpolation)
- **Dependents:** game scripts via `lurek.overlay`

## Files

| File | Purpose |
|------|---------|
| `mod.rs` | Module exports and public API surface |
| `ambient.rs` | `AmbientState` — time-of-day color tinting |
| `atmosphere.rs` | `CloudState`, `FogState`, `HeatHazeState`, `VignetteState`, `FilmGrainState`, `LightningState` |
| `controller.rs` | `Overlay` — central composite controller that owns all subsystems |
| `screen_effects.rs` | `FadeState`, `FlashState`, `ShakeState` — full-screen transient effects |
| `transition.rs` | `ScreenTransition`, `TransitionKind` — screen transition playback |
| `water.rs` | `WaterOverlayState` — water distortion and tint overlay |
| `weather.rs` | `WeatherParticle`, `WeatherState`, `WeatherType` — weather particle simulation |

## Public Types

| Type | Description |
|------|-------------|
| `Overlay` | Central overlay controller managing all subsystems |
| `AmbientState` | Time-of-day ambient color tint parameters |
| `CloudState` | Cloud rendering state |
| `FogState` | Fog density and color |
| `HeatHazeState` | Heat shimmer distortion |
| `VignetteState` | Screen-edge darkening |
| `FilmGrainState` | Film grain noise parameters |
| `LightningState` | Lightning flash state |
| `FadeState` | Screen fade-in/fade-out progress |
| `FlashState` | Instantaneous screen flash |
| `ShakeState` | Camera shake offset generator |
| `ScreenTransition` | Managed screen transition playback |
| `TransitionKind` | Transition visual style (fade, wipe, dissolve, etc.) |
| `WaterOverlayState` | Water surface distortion parameters |
| `WeatherParticle` | Individual weather particle state |
| `WeatherState` | Active weather simulation state |
| `WeatherType` | Weather type identifier (rain, snow, etc.) |

## Lua API

Namespace: `lurek.overlay`

### Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `lurek.overlay.new(width, height)` | `Overlay` | Create overlay controller |
| `lurek.overlay.newTransition(kind, duration)` | `ScreenTransition` | Create a screen transition |

### Overlay Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `:update(dt)` | — | Tick all subsystems |
| `:triggerFlash(r, g, b, a, duration)` | — | White/colored flash |
| `:triggerShake(intensity, duration)` | — | Camera shake |
| `:triggerFade(type, duration, r, g, b)` | — | Fade in/out |
| `:triggerLightning()` | — | Lightning flash |
| `:setWeather(type, intensity)` | — | Set weather |
| `:setAmbient(r, g, b, a)` | — | Ambient tint |
| `:setFog(density, r, g, b)` | — | Fog state |
| `:isActive()` | `boolean` | Any overlay active |
| `:clear()` | — | Reset all overlays |
| `:resize(w, h)` | — | Update dimensions |
| `:getWidth()` | `number` | Current width |
| `:getHeight()` | `number` | Current height |
| `:getDimensions()` | `number, number` | Width, height |
| `:getLightningAlpha()` | `number` | Lightning flash alpha |

## Cross-references

- Extracted from `src/effect/` which now handles post-processing only.
- See `docs/specs/effect.md` for post-processing pipeline.
