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

This module serves as the primary engine layer for screen-space presentation, offering a suite of visual techniques that enhance environmental storytelling and mood. It orchestrates long-lived atmospheric layers, including clouds, fog, and grain, and handles dynamic particle weather systems that respond to simulated wind direction and speed. This enables realistic settings such as falling snow or dust storms, giving developers precise artistic control over depth and visibility.

To support dramatic gameplay cues, the system processes rapid camera and screen-wide interactions. It coordinates timed camera shake animations that utilize deterministic offsets, alongside colorized screen flashes, fades, and complex full-screen transitions. These transitions, including iris wipes, wipes, and dissolves, allow smooth phase changes between game states with configurable progress, duration, and color curves.

Environmental progression is achieved through ambient lighting curves and water simulation. A time-of-day system maps day phases to scene-wide tint adjustments, which can be shared with light world systems to ensure light and shadow harmony. The module also features water distortion effects, utilizing configurable wave dynamics, shallow tints, and depth shifts to create moving surface details.

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
