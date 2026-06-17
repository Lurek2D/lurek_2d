# overlay

## TL;DR

- Manages screen-space weather, fog, camera shakes, and screen flashes.
- Supports wave distortion and transition wipes.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/overlay/`
- Binding: `src/lua_api/overlay_api.rs`
- Namespace: `lurek.overlay`
- Lua API surface: `2` functions, `3` types, `89` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): tests/lua/unit/test_overlay_unit.lua

## Summary

- This module gives users screen-space atmosphere and transition tools for visual mood and gameplay feedback.
- Weather overlays support effects like rain, snow, dust, and related wind-driven presentation cues.
- Fog, cloud shadow, heat haze, vignette, and grain controls allow layered environmental styling.
- Flash, fade, and shake effects provide impact signaling for combat, damage, and state changes.
- Transition support includes wipe, iris, dissolve, and fade-style full-screen changes.
- Time-of-day ambient tinting helps scenes communicate progression and context.
- Ambient synchronization with lighting systems keeps presentation coherent.
- Water distortion and tint controls support stylized surface-screen effects.
- Overlay state updates run as one controller, reducing per-feature timing glue.
- Render-command generation keeps overlay composition aligned with the main render path.
- Runtime telemetry snapshots expose effect load, weather occupancy, and alpha state for dashboards and debug tooling.
- Image output support enables overlay previews and debug evidence generation.
- The module is useful for cutscenes, weather systems, UX transitions, and dramatic pacing.
- For users, it centralizes post-world presentation behavior in one script API.
- It reduces bespoke effect orchestration code across scenes.
- Overall, users get a practical visual polish toolkit tightly integrated with runtime control.
- This helps teams ship more consistent and expressive scene transitions.

This module primarily collaborates with `color`, `image`, `render`, `runtime`. Its responsibility should stay inside the `Edge/Integration` group rather than absorb behavior owned by those neighbors.

## Imports

- `color`: Imports or references `src/color/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `image`: Imports or references `src/image/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.

## Files

### ambient.rs

- Global ambient tint state driven by a time-of-day curve. `overlay/ambient` delivers the ambient implementation for the overlay subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Maps day phases into scene-wide color changes for lighting control. The file owns or coordinates data contracts including `AmbientState`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supplies the ambient baseline consumed by the overlay renderer. Public callable behavior is centered on no named public items, while method-level behavior such as `compute_color_from_time` stays attached to the local data model and invariants.

### atmosphere.rs

- State structs for full-screen atmosphere overlays such as clouds, fog, haze, grain, and lightning. `overlay/atmosphere` delivers the atmosphere implementation for the overlay subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Carries per-effect enable flags plus density, intensity, color, and speed parameters. The file owns or coordinates data contracts including `CloudState`, `FogState`, `HeatHazeState`, `VignetteState`, `FilmGrainState`, and 1 more, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Keeps overlay features opt-in so scenes can select only the layers they need. Public callable behavior is centered on no named public items, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Provides the data model for long-lived atmospheric presentation effects. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### controller.rs

- Central overlay controller owning every screen-space effect state block. `overlay/controller` delivers the controller implementation for the overlay subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Updates weather particles, flash decay, shake decay, fade interpolation, cloud scroll, and lightning each frame. The file owns or coordinates data contracts including `OverlayStats`, `Overlay`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Spawns and simulates weather particles for rain, snow, hail, dust, leaves, ash, and pollen. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `update`, `trigger_flash`, `trigger_shake`, `trigger_fade`, `trigger_lightning`, and 19 more stays attached to the local data model and invariants.
- Triggers flash, shake, fade, and lightning events through a simple runtime API. Runtime integration reaches sibling engine areas through crate modules `log_msg`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Reports shake offset, flash alpha, lightning alpha, and active state to callers. External integration uses `super`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Builds render commands for flash, fade, lightning, and vignette overlays. The file boundary separates overlay implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### mod.rs

- Screen-space overlay subsystem for ambient lighting, atmosphere, and scene transitions. `overlay/mod` is the overlay module index, declaring `ambient`, `atmosphere`, `controller`, `screen_effects`, `transition`, and 2 more so agents can identify which files own each feature slice before opening implementation code.
- Groups the state and render paths for weather, water, flash, fog, and fade effects. `src/overlay/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `ambient::AmbientState`, `atmosphere::{ CloudState, FilmGrainState, FogState, HeatHazeState, LightningState, VignetteState, }`, `controller::Overlay`, `screen_effects::{FadeState, FlashState, ShakeState}`, and 3 more centralized for the overlay subsystem.

### screen_effects.rs

- Full-screen effect state machines for flash, shake, and fade. `overlay/screen_effects` delivers the screen effects implementation for the overlay subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Keeps each state focused on timing, activation, and per-frame parameters. The file owns or coordinates data contracts including `FlashState`, `ShakeState`, `FadeState`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Uses a deterministic PRNG for shake offsets without extra RNG plumbing. Public callable behavior is centered on no named public items, while method-level behavior such as `next_random` stays attached to the local data model and invariants.
- Provides the short-lived effect core used by the overlay controller. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### transition.rs

- Full-screen transition effects for fade, wipe, iris wipe, and dissolve. `overlay/transition` delivers the transition implementation for the overlay subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Supports string-based kind parsing with canonical name round-tripping. The file owns or coordinates data contracts including `TransitionKind`, `ScreenTransition`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Runs with time-based forward and reverse playback modes. Public callable behavior is centered on no named public items, while method-level behavior such as `from_str`, `name`, `new`, `play`, `reverse`, `update`, and 3 more stays attached to the local data model and invariants.
- Exposes normalized progress for renderer consumption. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### water.rs

- Animated water distortion overlay with configurable amplitude, frequency, and speed. `overlay/water` delivers the water implementation for the overlay subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Adds shallow-water tint and depth-based color shift with independent blend strengths. The file owns or coordinates data contracts including `WaterOverlayState`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Advances the wave pattern through a time-accumulating update loop. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `update`, `reset` stays attached to the local data model and invariants.

### weather.rs

- Weather particle simulation state and management for screen-space overlays. `overlay/weather` delivers the weather implementation for the overlay subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Supports rain, snow, hail, dust, leaves, ash, and pollen behaviors. The file owns or coordinates data contracts including `WeatherType`, `WeatherParticle`, `WeatherState`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Tracks particle pools, wind parameters, and an internal PRNG. Public callable behavior is centered on no named public items, while method-level behavior such as `from_name`, `name`, `next_unit` stays attached to the local data model and invariants.
- Keeps weather spawning and motion separated from the main scene model. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.



## Lua API Ref

### Functions

- `lurek.overlay.new(w?, h?) -> LOverlay`: Creates an overlay controller for screen effects using optional dimensions.
- `lurek.overlay.newTransition(kind?, duration?, color_tbl?) -> LScreenTransition`: Creates a timed screen transition with optional kind, duration, and color.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LOverlay Type

- Lua-side handle for screen overlay, ambient, weather, and transition visual state.

##### Fields

- No documented fields.

##### Methods

- `LOverlay:clear() -> nil`: Clears active overlay effects and resets transient state.
- `LOverlay:drawToImage(w, h) -> Image`: Renders overlay state into an image object of the requested size.
- `LOverlay:fade(r, g, b, a?, dur?) -> nil`: Starts a fade overlay with optional alpha and duration.
- `LOverlay:flash(r, g, b, a?, dur?) -> nil`: Starts a short flash overlay with optional alpha and duration.
- `LOverlay:getAmbientColor() -> number`: Returns overlay ambient RGBA color.
- `LOverlay:getCloudCount() -> integer`: Returns the overlay cloud shadow count.
- `LOverlay:getCloudOpacity() -> number`: Returns cloud shadow opacity. This method is available to Lua scripts.
- `LOverlay:getCloudScale() -> number`: Returns cloud shadow scale. This method is available to Lua scripts.
- `LOverlay:getCloudSpeed() -> number`: Returns cloud shadow movement speed.
- `LOverlay:getDimensions() -> integer`: Returns the overlay dimensions. This method is available to Lua scripts.
- `LOverlay:getFilmGrainIntensity() -> number`: Returns overlay film grain intensity.
- `LOverlay:getFlashAlpha() -> number`: Returns the current flash alpha. This method is available to Lua scripts.
- `LOverlay:getFogColor() -> number`: Returns overlay fog RGBA color. This method is available to Lua scripts.
- `LOverlay:getFogDensity() -> number`: Returns overlay fog density. This method is available to Lua scripts.
- `LOverlay:getHeatHazeIntensity() -> number`: Returns overlay heat haze intensity.
- `LOverlay:getHeight() -> integer`: Returns the overlay height. This method is available to Lua scripts.
- `LOverlay:getLightningAlpha() -> number`: Returns the current lightning alpha.
- `LOverlay:getLightningColor() -> number`: Returns overlay lightning RGBA color.
- `LOverlay:getShakeOffset() -> number`: Returns the current screen shake offset.
- `LOverlay:getStats() -> table`: Returns a telemetry snapshot for dashboard and debug workflows.
- `LOverlay:getTimeOfDay() -> number`: Returns the overlay time-of-day value.
- `LOverlay:getVignetteStrength() -> number`: Returns overlay vignette strength.
- `LOverlay:getWater() -> table`: Returns a table describing the current water effect settings.
- `LOverlay:getWeather() -> string`: Returns the overlay weather type name.
- `LOverlay:getWeatherIntensity() -> number`: Returns weather intensity for the current weather type.
- `LOverlay:getWidth() -> integer`: Returns the overlay width. This method is available to Lua scripts.
- `LOverlay:getWindDirection() -> number`: Returns the overlay weather wind direction.
- `LOverlay:getWindSpeed() -> number`: Returns the overlay weather wind speed.
- `LOverlay:isActive() -> boolean`: Returns whether any overlay effect is currently active.
- `LOverlay:isAmbientEnabled() -> boolean`: Returns whether overlay ambient color rendering is enabled.
- `LOverlay:isCloudShadowsEnabled() -> boolean`: Returns whether overlay cloud shadow rendering is enabled.
- `LOverlay:isFading() -> boolean`: Returns whether the fade overlay is active.
- `LOverlay:isFilmGrainEnabled() -> boolean`: Returns whether overlay film grain rendering is enabled.
- `LOverlay:isFlashing() -> boolean`: Returns whether the flash overlay is active.
- `LOverlay:isFogEnabled() -> boolean`: Returns whether overlay fog rendering is enabled.
- `LOverlay:isHeatHazeEnabled() -> boolean`: Returns whether overlay heat haze rendering is enabled.
- `LOverlay:isShaking() -> boolean`: Returns whether the screen shake effect is active.
- `LOverlay:isVignetteEnabled() -> boolean`: Returns whether overlay vignette rendering is enabled.
- `LOverlay:isWeatherEnabled() -> boolean`: Returns whether overlay weather rendering is enabled.
- `LOverlay:pullAmbientFromLight() -> nil`: Copies ambient color from the shared light world into this overlay.
- `LOverlay:pushAmbientToLight() -> nil`: Copies this overlay ambient color into the shared light world.
- `LOverlay:render() -> nil`: Queues renderer commands for the overlay's current visual state.
- `LOverlay:resize(w, h) -> nil`: Resizes the overlay target dimensions.
- `LOverlay:setAmbientColor(r, g, b, a?) -> nil`: Sets the overlay ambient color from RGBA channels.
- `LOverlay:setAmbientEnabled(v) -> nil`: Enables or disables overlay ambient color rendering.
- `LOverlay:setCloudCount(v) -> nil`: Sets the overlay cloud shadow count.
- `LOverlay:setCloudOpacity(v) -> nil`: Sets cloud shadow opacity. This method is available to Lua scripts.
- `LOverlay:setCloudScale(v) -> nil`: Sets cloud shadow scale. This method is available to Lua scripts.
- `LOverlay:setCloudShadows(v) -> nil`: Enables or disables overlay cloud shadow rendering.
- `LOverlay:setCloudSpeed(v) -> nil`: Sets cloud shadow movement speed. This method is available to Lua scripts.
- `LOverlay:setCustomShader(name?) -> nil`: Sets or clears the custom overlay shader name.
- `LOverlay:setFilmGrainEnabled(v) -> nil`: Enables or disables overlay film grain rendering.
- `LOverlay:setFilmGrainIntensity(v) -> nil`: Sets overlay film grain intensity.
- `LOverlay:setFogColor(r, g, b, a?) -> nil`: Sets the overlay fog color from RGBA channels.
- `LOverlay:setFogDensity(v) -> nil`: Sets overlay fog density. This method is available to Lua scripts.
- `LOverlay:setFogEnabled(v) -> nil`: Enables or disables overlay fog rendering.
- `LOverlay:setHeatHazeEnabled(v) -> nil`: Enables or disables overlay heat haze rendering.
- `LOverlay:setHeatHazeIntensity(v) -> nil`: Sets overlay heat haze intensity. This method is available to Lua scripts.
- `LOverlay:setLightningColor(r, g, b, a?) -> nil`: Sets overlay lightning RGBA color.
- `LOverlay:setTimeOfDay(v) -> nil`: Sets the overlay time-of-day value used by ambient effects.
- `LOverlay:setVignetteEnabled(v) -> nil`: Enables or disables overlay vignette rendering.
- `LOverlay:setVignetteStrength(v) -> nil`: Sets overlay vignette strength. This method is available to Lua scripts.
- `LOverlay:setWater(amplitude, frequency, speed) -> nil`: Enables water distortion and sets wave amplitude, frequency, and speed.
- `LOverlay:setWaterTint(r, g, b, strength) -> nil`: Sets the water tint color and strength.
- `LOverlay:setWeather(name) -> nil`: Sets the overlay weather type by name.
- `LOverlay:setWeatherEnabled(v) -> nil`: Enables or disables overlay weather rendering.
- `LOverlay:setWeatherIntensity(v) -> nil`: Sets weather intensity for the current weather type.
- `LOverlay:setWindDirection(v) -> nil`: Sets the overlay weather wind direction.
- `LOverlay:setWindSpeed(v) -> nil`: Sets the overlay weather wind speed.
- `LOverlay:shake(intensity, dur?) -> nil`: Starts a screen shake with optional duration.
- `LOverlay:syncAmbientWithLight(mode) -> nil`: Resolves overlay and light ambient colors using a named mode and writes both stores.
- `LOverlay:triggerFade(r, g, b, target_alpha, duration) -> nil`: Starts a fade overlay toward a target alpha.
- `LOverlay:triggerFlash(r, g, b, a, duration) -> nil`: Starts a screen flash with explicit RGBA color and duration.
- `LOverlay:triggerLightning() -> nil`: Starts a lightning flash using the overlay lightning state.
- `LOverlay:triggerShake(intensity, duration) -> nil`: Starts a screen shake effect. This method is available to Lua scripts.
- `LOverlay:type() -> string`: Returns the Lua-visible type name for this overlay handle.
- `LOverlay:typeOf(name) -> boolean`: Returns whether this overlay handle matches a supported type name.
- `LOverlay:update(dt) -> nil`: Advances overlay timers and animated effect state.

#### LOverlayGetWaterResult Type

- Generated result shape from @field tags.

##### Fields

- `amplitude` (`number`): Wave amplitude.
- `depth_b` (`number`): Depth blue component.
- `depth_g` (`number`): Depth green component.
- `depth_r` (`number`): Depth red component.
- `depth_strength` (`number`): Depth strength.
- `enabled` (`boolean`): Whether water effect is enabled.
- `frequency` (`number`): Wave frequency.
- `speed` (`number`): Wave speed.
- `time` (`number`): Elapsed time.
- `tint_b` (`number`): Tint blue component.
- `tint_g` (`number`): Tint green component.
- `tint_r` (`number`): Tint red component.
- `tint_strength` (`number`): Tint strength.

##### Methods

- No documented methods.

#### LScreenTransition Type

- Lua-side handle for a timed screen transition effect.

##### Fields

- No documented fields.

##### Methods

- `LScreenTransition:color() -> number`: Returns the transition RGBA color.
- `LScreenTransition:isActive() -> boolean`: Returns whether the transition is currently active.
- `LScreenTransition:isDone() -> boolean`: Returns whether the transition has finished.
- `LScreenTransition:kind() -> string`: Returns the transition kind name. This method is available to Lua scripts.
- `LScreenTransition:play() -> nil`: Starts this screen transition forward from its current state.
- `LScreenTransition:progress() -> number`: Returns normalized transition progress.
- `LScreenTransition:reverse() -> nil`: Starts this screen transition in reverse from its current state.
- `LScreenTransition:setColor(color) -> nil`: Sets the transition RGBA color from a numeric array table.
- `LScreenTransition:type() -> string`: Returns the Lua-visible type name for this transition handle.
- `LScreenTransition:typeOf(name) -> boolean`: Returns whether this transition handle matches a supported type name.
- `LScreenTransition:update(dt) -> boolean`: Advances this transition timer and returns whether it remains active.

## References

- `color`: Imports or references `src/color/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `image`: Imports or references `src/image/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.

## Notes

- No additional module-specific notes.
