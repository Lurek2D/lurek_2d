# overlay

## General Info

- Module group: `Edge/Integration`
- Source path: `src/overlay/`
- Binding: `src/lua_api/overlay_api.rs`
- Namespace: `lurek.overlay`
- Lua API surface: `2` functions, `3` types, `88` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

The `overlay` module provides a self-contained screen-space effects layer that sits above world rendering and below the HUD. The central `Overlay` struct owns every subsystem and drives their per-frame update via a single `update(dt)` call. It handles five distinct effect categories.

**Weather and atmosphere**: A particle-based `WeatherState` simulates seven weather modes — rain, snow, hail, dust, leaves, ash, and pollen — each with configurable wind parameters and an internal PRNG pool. Atmospheric overlays add full-screen fog, animated cloud layers, heat haze distortion, vignette darkening, film grain, and short-lived lightning flashes, all driven by opt-in state structs that default to disabled.

**Ambient lighting**: `AmbientState` applies a global RGBA tint driven by a time-of-day curve that interpolates through dawn, day, dusk, and night segments. This tint is synchronized with the `light` module via `pull_ambient_from_light` and `push_ambient_to_light` helpers to keep both systems consistent.

**Screen effects**: Three time-limited state machines handle `FlashState` (full-screen color burst with alpha decay), `ShakeState` (camera offset jitter using a deterministic internal PRNG), and `FadeState` (timed interpolation toward a target alpha). All three are triggered from Lua via `trigger_flash`, `trigger_shake`, and `trigger_fade`.

**Scene transitions**: `ScreenTransition` supports fade, wipe, iris wipe, and dissolve styles with forward and reverse playback modes. Normalized progress is exposed for renderer consumption.

**Water distortion**: `WaterOverlayState` applies an animated sine-wave distortion overlay with configurable amplitude, frequency, and speed, plus shallow-water tint and depth-based color shift.

All active layers emit `RenderCommand` entries built by `build_render_commands` for compositor integration. Debug visualization helpers render state panels and trigger previews into `ImageData` buffers. The full suite is accessible via `lurek.overlay.*`.

## Files

### [ambient.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/overlay/ambient.rs)

- Global ambient tint state driven by a time-of-day curve.
- Maps day phases into scene-wide color changes for lighting control.
- Supplies the ambient baseline consumed by the overlay renderer.

### [atmosphere.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/overlay/atmosphere.rs)

- State structs for full-screen atmosphere overlays such as clouds, fog, haze, grain, and lightning.
- Carries per-effect enable flags plus density, intensity, color, and speed parameters.
- Keeps overlay features opt-in so scenes can select only the layers they need.
- Provides the data model for long-lived atmospheric presentation effects.
- Separates configuration from rendering so effect logic stays lightweight.

### [controller.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/overlay/controller.rs)

- Central overlay controller owning every screen-space effect state block.
- Updates weather particles, flash decay, shake decay, fade interpolation, cloud scroll, and lightning each frame.
- Spawns and simulates weather particles for rain, snow, hail, dust, leaves, ash, and pollen.
- Triggers flash, shake, fade, and lightning events through a simple runtime API.
- Reports shake offset, flash alpha, lightning alpha, and active state to callers.
- Builds render commands for flash, fade, lightning, and vignette overlays.
- Resets every subsystem back to a clean inactive state when needed.
- Supports debug visualisation of internal timing and offset trails.
- Keeps presentation effects together so higher-level scene code stays thin.
- Acts as the single screen-space effect scheduler for the renderer.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/overlay/mod.rs)

- Screen-space overlay subsystem for ambient lighting, atmosphere, and scene transitions.
- Groups the state and render paths for weather, water, flash, fog, and fade effects.
- Keeps screen-space presentation logic under one runtime namespace.

### [screen_effects.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/overlay/screen_effects.rs)

- Full-screen effect state machines for flash, shake, and fade.
- Keeps each state focused on timing, activation, and per-frame parameters.
- Uses a deterministic PRNG for shake offsets without extra RNG plumbing.
- Provides the short-lived effect core used by the overlay controller.

### [transition.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/overlay/transition.rs)

- Full-screen transition effects for fade, wipe, iris wipe, and dissolve.
- Supports string-based kind parsing with canonical name round-tripping.
- Runs with time-based forward and reverse playback modes.
- Exposes normalized progress for renderer consumption.
- Gives scene changes a compact state model with predictable timing.

### [water.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/overlay/water.rs)

- Animated water distortion overlay with configurable amplitude, frequency, and speed.
- Adds shallow-water tint and depth-based color shift with independent blend strengths.
- Advances the wave pattern through a time-accumulating update loop.
- Serves as the water-specific screen-space effect for overlays.

### [weather.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/overlay/weather.rs)

- Weather particle simulation state and management for screen-space overlays.
- Supports rain, snow, hail, dust, leaves, ash, and pollen behaviors.
- Tracks particle pools, wind parameters, and an internal PRNG.
- Keeps weather spawning and motion separated from the main scene model.
- Provides reusable state for long-lived atmospheric weather effects.
