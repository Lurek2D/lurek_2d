# overlay

## TL;DR

- The `overlay` module manages all screen-space visual effects drawn between the game world and the player: weather particles, atmospheric effects, screen flashes, camera shake, scene transitions, ambient tinting, and water distortion.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/overlay/`
- Lua API path(s): `src/lua_api/overlay_api.rs`
- Primary Lua namespace: `lurek.overlay`
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

## Source Documentation

### `ambient.rs`
- Global ambient tint state driven by a time-of-day curve.
- Maps hour values (0–24) to RGBA color through piecewise dawn/day/dusk/night segments.
- Consumed by the overlay renderer when the ambient effect is enabled.

### `atmosphere.rs`
- State structs for full-screen atmosphere overlays: clouds, fog, heat haze, vignette, film grain, and lightning flash.
- Each struct carries enabled flag plus effect-specific parameters (density, intensity, color, speed).
- All default to disabled so overlays are opt-in per scene.

### `controller.rs`
- Central `Overlay` struct owning every screen-space post-world effect state block.
- Per-frame update loop advancing weather particles, flash decay, shake decay, fade interpolation, cloud scroll, and lightning.
- Weather particle spawning and simulation for rain, snow, hail, dust, leaves, ash, and pollen modes.
- Trigger API for flash, camera shake, screen fade, and lightning flash events.
- Query helpers for shake offset, flash/lightning alpha, active state, and target dimensions.
- Render command builder emitting full-screen colored rectangles for flash, fade, lightning, and vignette overlays.
- Clear/reset restoring all subsystems to default inactive state.
- Debug visualization: state panels, flash frame strips, shake offset trails, fade transition strips, and combined trigger previews.

### `mod.rs`
- Screen-space overlay sub-system: ambient lighting, atmospheric effects, and scene transitions.
- `ambient` — ambient colour driven by time-of-day for scene-wide lighting tint.
- `atmosphere` — atmospheric overlays: clouds, fog layers, and lightning flashes.
- `controller` — top-level overlay scheduler for weather, fades, haze, and screen burns.
- `screen_effects` — short-lived screen-space flash, shake, and fade state.
- `transition` — full-screen scene transition effects with configurable easing.
- `water` — animated water distortion overlay for underwater and rain scenarios.
- `weather` — particle-based weather simulation: rain, snow, hail, dust, leaves, and ash.

### `screen_effects.rs`
- Full-screen effect state machines: flash, shake, and fade.
- Each state tracks active flag, timing, and per-frame parameters.
- Deterministic PRNG for shake offsets without external RNG dependency.

### `transition.rs`
- Full-screen transition effects: fade, wipe, iris wipe, and dissolve.
- String-based kind parsing with canonical name round-tripping.
- Time-based playback lifecycle with forward and reverse modes.
- Normalized progress query for renderer consumption.

### `water.rs`
- Animated water distortion overlay with configurable amplitude, frequency, and speed.
- Shallow-water tint and depth-based color shift with independent blend strengths.
- Time-accumulating update loop that advances the wave pattern each frame.

### `weather.rs`
- Weather particle simulation types and state management.
- Supports rain, snow, hail, dust, leaves, ash, and pollen behaviors.
- Tracks particle pool, wind parameters, and internal PRNG.

## Types

- `AmbientState` (`struct`, `ambient.rs`): Stores ambient tint settings applied across the whole screen.
- `CloudState` (`struct`, `atmosphere.rs`): Configures animated cloud overlay generation.
- `FogState` (`struct`, `atmosphere.rs`): Configures full-screen fog tint and density.
- `HeatHazeState` (`struct`, `atmosphere.rs`): Controls screen-space heat haze distortion intensity.
- `VignetteState` (`struct`, `atmosphere.rs`): Controls vignette darkening around the screen edges.
- `FilmGrainState` (`struct`, `atmosphere.rs`): Controls full-screen film grain intensity.
- `LightningState` (`struct`, `atmosphere.rs`): Tracks a short-lived lightning flash overlay.
- `Overlay` (`struct`, `controller.rs`): Owns every screen-space overlay state block applied on top of world rendering.
- `FlashState` (`struct`, `screen_effects.rs`): Tracks a time-limited full-screen flash overlay.
- `ShakeState` (`struct`, `screen_effects.rs`): Tracks camera shake intensity, timing, and generated offsets.
- `FadeState` (`struct`, `screen_effects.rs`): Tracks a timed fade toward a target alpha value.
- `TransitionKind` (`enum`, `transition.rs`): Enumerates supported full-screen transition styles.
- `ScreenTransition` (`struct`, `transition.rs`): Stores runtime state for a time-based screen transition.
- `WaterOverlayState` (`struct`, `water.rs`): Stores parameters for animated water distortion and tint overlays.
- `WeatherType` (`enum`, `weather.rs`): Enumerates supported weather particle behaviors.
- `WeatherParticle` (`struct`, `weather.rs`): Stores the current position, velocity, and visual size of one weather particle.
- `WeatherState` (`struct`, `weather.rs`): Tracks weather mode, particle pool, wind, and random generation state.

## Functions

- `AmbientState::compute_color_from_time` (`ambient.rs`): Computes the ambient RGBA tint for the current time-of-day sample.
- `Overlay::new` (`controller.rs`): Creates an overlay initialized with default state blocks for the target size.
- `Overlay::update` (`controller.rs`): Advances every active overlay subsystem by `dt` seconds.
- `Overlay::trigger_flash` (`controller.rs`): Starts a flash overlay with the supplied color, alpha, and duration.
- `Overlay::trigger_shake` (`controller.rs`): Starts a camera shake with the supplied intensity and duration.
- `Overlay::trigger_fade` (`controller.rs`): Starts a fade toward the supplied target alpha over the given duration.
- `Overlay::trigger_lightning` (`controller.rs`): Starts a short lightning flash using the configured lightning state.
- `Overlay::get_shake_offset` (`controller.rs`): Returns the current camera shake offset.
- `Overlay::is_active` (`controller.rs`): Returns whether any overlay subsystem is currently enabled or animating.
- `Overlay::clear` (`controller.rs`): Restores every overlay subsystem to its default inactive state.
- `Overlay::pull_ambient_from_light` (`controller.rs`): Copies ambient color from the given light world ambient color into this overlay.
- `Overlay::push_ambient_to_light` (`controller.rs`): Copies this overlay ambient color into the given light world ambient color.
- `Overlay::sync_ambient_with_light` (`controller.rs`): Resolves overlay and light ambient colors using a named mode and writes both stores.
- `Overlay::resize` (`controller.rs`): Updates the overlay target dimensions.
- `Overlay::get_width` (`controller.rs`): Returns the overlay target width.
- `Overlay::get_height` (`controller.rs`): Returns the overlay target height.
- `Overlay::get_dimensions` (`controller.rs`): Returns the overlay target dimensions as `(width, height)`.
- `Overlay::get_flash_alpha` (`controller.rs`): Computes the current flash alpha after time decay.
- `Overlay::get_lightning_alpha` (`controller.rs`): Computes the current lightning flash alpha after time decay.
- `Overlay::build_render_commands` (`controller.rs`): Builds render commands for currently active full-screen overlay layers.
- `Overlay::draw_state_to_image` (`controller.rs`): Renders a debug image showing current flash, shake, and fade state.
- `Overlay::draw_flash_sequence_to_image` (`controller.rs`): Renders a frame strip showing the time evolution of a flash overlay.
- `Overlay::draw_shake_trail_to_image` (`controller.rs`): Renders a debug image showing a series of shake offsets as a trail.
- `Overlay::draw_fade_transition_to_image` (`controller.rs`): Renders a frame strip showing fade alpha samples across multiple steps.
- `Overlay::draw_trigger_panel_to_image` (`controller.rs`): Renders a debug panel previewing flash, shake, fade, and lightning triggers.
- `ShakeState::next_random` (`screen_effects.rs`): Advances the shake PRNG and returns a sample in the `[-1, 1]` range.
- `TransitionKind::from_str` (`transition.rs`): Parses a user-facing transition name, defaulting to fade for unknown values.
- `TransitionKind::name` (`transition.rs`): Returns the lowercase canonical name for this transition kind.
- `ScreenTransition::new` (`transition.rs`): Creates an inactive transition with clamped nonzero duration.
- `ScreenTransition::play` (`transition.rs`): Starts forward playback from the beginning.
- `ScreenTransition::reverse` (`transition.rs`): Starts reverse playback from the beginning.
- `ScreenTransition::update` (`transition.rs`): Advances playback by `dt` seconds and returns whether the transition was active.
- `ScreenTransition::progress` (`transition.rs`): Returns normalized transition progress after applying reverse playback.
- `ScreenTransition::is_active` (`transition.rs`): Returns whether the transition is currently playing.
- `ScreenTransition::is_done` (`transition.rs`): Returns whether playback has reached the end of the transition.
- `WaterOverlayState::new` (`water.rs`): Creates a water overlay with default parameters.
- `WaterOverlayState::update` (`water.rs`): Advances the overlay animation clock while the effect is enabled.
- `WaterOverlayState::reset` (`water.rs`): Restores every water overlay parameter to its default value.
- `WeatherType::from_name` (`weather.rs`): Resolves a lowercase weather type name into the matching enum entry.
- `WeatherType::name` (`weather.rs`): Returns the lowercase canonical name for this weather type.
- `WeatherState::next_unit` (`weather.rs`): Advances the internal PRNG and returns a sample in the `[0, 1)` range.

## Lua API Reference

- Binding path(s): `src/lua_api/overlay_api.rs`
- Namespace: `lurek.overlay`

### Module Functions
- `lurek.overlay.new`: Creates an overlay controller for screen effects using optional dimensions.
- `lurek.overlay.newTransition`: Creates a timed screen transition with optional kind, duration, and color.

### `LOverlay` Methods
- `LOverlay:update`: Advances overlay timers and animated effect state.
- `LOverlay:triggerFlash`: Starts a screen flash with explicit RGBA color and duration.
- `LOverlay:triggerShake`: Starts a screen shake effect. This method is available to Lua scripts.
- `LOverlay:triggerFade`: Starts a fade overlay toward a target alpha.
- `LOverlay:triggerLightning`: Starts a lightning flash using the overlay lightning state.
- `LOverlay:getShakeOffset`: Returns the current screen shake offset.
- `LOverlay:isActive`: Returns whether any overlay effect is currently active.
- `LOverlay:clear`: Clears active overlay effects and resets transient state.
- `LOverlay:resize`: Resizes the overlay target dimensions.
- `LOverlay:getWidth`: Returns the overlay width. This method is available to Lua scripts.
- `LOverlay:getHeight`: Returns the overlay height. This method is available to Lua scripts.
- `LOverlay:getDimensions`: Returns the overlay dimensions. This method is available to Lua scripts.
- `LOverlay:getFlashAlpha`: Returns the current flash alpha. This method is available to Lua scripts.
- `LOverlay:getLightningAlpha`: Returns the current lightning alpha.
- `LOverlay:setAmbientEnabled`: Enables or disables overlay ambient color rendering.
- `LOverlay:isAmbientEnabled`: Returns whether overlay ambient color rendering is enabled.
- `LOverlay:setAmbientColor`: Sets the overlay ambient color from RGBA channels.
- `LOverlay:getAmbientColor`: Returns overlay ambient RGBA color.
- `LOverlay:pullAmbientFromLight`: Copies ambient color from the shared light world into this overlay.
- `LOverlay:pushAmbientToLight`: Copies this overlay ambient color into the shared light world.
- `LOverlay:syncAmbientWithLight`: Resolves overlay and light ambient colors using a named mode and writes both stores.
- `LOverlay:setTimeOfDay`: Sets the overlay time-of-day value used by ambient effects.
- `LOverlay:getTimeOfDay`: Returns the overlay time-of-day value.
- `LOverlay:setFogEnabled`: Enables or disables overlay fog rendering.
- `LOverlay:isFogEnabled`: Returns whether overlay fog rendering is enabled.
- `LOverlay:setFogDensity`: Sets overlay fog density. This method is available to Lua scripts.
- `LOverlay:getFogDensity`: Returns overlay fog density. This method is available to Lua scripts.
- `LOverlay:setFogColor`: Sets the overlay fog color from RGBA channels.
- `LOverlay:getFogColor`: Returns overlay fog RGBA color. This method is available to Lua scripts.
- `LOverlay:setHeatHazeEnabled`: Enables or disables overlay heat haze rendering.
- `LOverlay:isHeatHazeEnabled`: Returns whether overlay heat haze rendering is enabled.
- `LOverlay:setHeatHazeIntensity`: Sets overlay heat haze intensity. This method is available to Lua scripts.
- `LOverlay:getHeatHazeIntensity`: Returns overlay heat haze intensity.
- `LOverlay:setVignetteEnabled`: Enables or disables overlay vignette rendering.
- `LOverlay:isVignetteEnabled`: Returns whether overlay vignette rendering is enabled.
- `LOverlay:setVignetteStrength`: Sets overlay vignette strength. This method is available to Lua scripts.
- `LOverlay:getVignetteStrength`: Returns overlay vignette strength.
- `LOverlay:setFilmGrainEnabled`: Enables or disables overlay film grain rendering.
- `LOverlay:isFilmGrainEnabled`: Returns whether overlay film grain rendering is enabled.
- `LOverlay:setFilmGrainIntensity`: Sets overlay film grain intensity.
- `LOverlay:getFilmGrainIntensity`: Returns overlay film grain intensity.
- `LOverlay:setCloudShadows`: Enables or disables overlay cloud shadow rendering.
- `LOverlay:isCloudShadowsEnabled`: Returns whether overlay cloud shadow rendering is enabled.
- `LOverlay:setCloudCount`: Sets the overlay cloud shadow count.
- `LOverlay:getCloudCount`: Returns the overlay cloud shadow count.
- `LOverlay:setCloudSpeed`: Sets cloud shadow movement speed. This method is available to Lua scripts.
- `LOverlay:getCloudSpeed`: Returns cloud shadow movement speed.
- `LOverlay:setCloudScale`: Sets cloud shadow scale. This method is available to Lua scripts.
- `LOverlay:getCloudScale`: Returns cloud shadow scale. This method is available to Lua scripts.
- `LOverlay:setCloudOpacity`: Sets cloud shadow opacity. This method is available to Lua scripts.
- `LOverlay:getCloudOpacity`: Returns cloud shadow opacity. This method is available to Lua scripts.
- `LOverlay:setWeatherEnabled`: Enables or disables overlay weather rendering.
- `LOverlay:isWeatherEnabled`: Returns whether overlay weather rendering is enabled.
- `LOverlay:setWeather`: Sets the overlay weather type by name.
- `LOverlay:getWeather`: Returns the overlay weather type name.
- `LOverlay:setWeatherIntensity`: Sets weather intensity for the current weather type.
- `LOverlay:getWeatherIntensity`: Returns weather intensity for the current weather type.
- `LOverlay:setWindDirection`: Sets the overlay weather wind direction.
- `LOverlay:getWindDirection`: Returns the overlay weather wind direction.
- `LOverlay:setWindSpeed`: Sets the overlay weather wind speed.
- `LOverlay:getWindSpeed`: Returns the overlay weather wind speed.
- `LOverlay:setLightningColor`: Sets overlay lightning RGBA color.
- `LOverlay:getLightningColor`: Returns overlay lightning RGBA color.
- `LOverlay:flash`: Starts a short flash overlay with optional alpha and duration.
- `LOverlay:isFlashing`: Returns whether the flash overlay is active.
- `LOverlay:shake`: Starts a screen shake with optional duration.
- `LOverlay:isShaking`: Returns whether the screen shake effect is active.
- `LOverlay:fade`: Starts a fade overlay with optional alpha and duration.
- `LOverlay:isFading`: Returns whether the fade overlay is active.
- `LOverlay:render`: Queues renderer commands for the overlay's current visual state.
- `LOverlay:drawToImage`: Renders overlay state into an image object of the requested size.
- `LOverlay:setWater`: Enables water distortion and sets wave amplitude, frequency, and speed.
- `LOverlay:setWaterTint`: Sets the water tint color and strength.
- `LOverlay:setCustomShader`: Sets or clears the custom overlay shader name.
- `LOverlay:getWater`: Returns a table describing the current water effect settings.
- `LOverlay:type`: Returns the Lua-visible type name for this overlay handle.
- `LOverlay:typeOf`: Returns whether this overlay handle matches a supported type name.

### `LScreenTransition` Methods
- `LScreenTransition:play`: Starts this screen transition forward from its current state.
- `LScreenTransition:reverse`: Starts this screen transition in reverse from its current state.
- `LScreenTransition:update`: Advances this transition timer and returns whether it remains active.
- `LScreenTransition:progress`: Returns normalized transition progress.
- `LScreenTransition:isActive`: Returns whether the transition is currently active.
- `LScreenTransition:isDone`: Returns whether the transition has finished.
- `LScreenTransition:kind`: Returns the transition kind name. This method is available to Lua scripts.
- `LScreenTransition:color`: Returns the transition RGBA color.
- `LScreenTransition:setColor`: Sets the transition RGBA color from a numeric array table.
- `LScreenTransition:type`: Returns the Lua-visible type name for this transition handle.
- `LScreenTransition:typeOf`: Returns whether this transition handle matches a supported type name.

## References

- `color`: Imports or references `src/color/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `image`: Imports or references `src/image/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.

## Notes

- Keep this module reference synchronized with `src/overlay/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
