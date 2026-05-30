# overlay

## TL;DR

- The `overlay` module manages screen-space presentation effects in one controller: weather, atmosphere, flash, shake, fade, transitions, and water distortion.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/overlay/`
- Binding: `src/lua_api/overlay_api.rs`
- Namespace: `lurek.overlay`
- Lua API surface: `2` functions, `3` types, `88` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

The `overlay` module is the full-screen presentation layer that sits above world drawing and below final UI composition. It centralizes visual effect state so projects can apply atmosphere and feedback consistently without scattering effect logic across scenes.

Its core role is to manage multiple effect families through one runtime controller: weather particles, fog and cloud ambience, flash and shake reactions, fades, transition effects, and water-style distortion.

Ambient color and time-driven mood control are integrated into the same surface. This helps teams align screen-space ambience with broader lighting context while keeping control in one place.

Effects can be triggered as short reactions or sustained as long-lived environmental layers. Because updates are time-based and stateful, the same API can support gameplay feedback, cinematic transitions, and persistent scene mood.

The module also supports practical output workflows. It can emit render commands for normal runtime composition and produce image-style previews for tooling and diagnostics.

In practice, `lurek.overlay` provides one stable contract for dynamic presentation effects: schedule, update, and render screen-space ambience and feedback with predictable behavior.

## Imports

- `color`: Imports or references `src/color/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `image`: Imports or references `src/image/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.

## Files

### ambient.rs

- Global ambient tint state driven by a time-of-day curve.
- Maps day phases into scene-wide color changes for lighting control.
- Supplies the ambient baseline consumed by the overlay renderer.

### atmosphere.rs

- State structs for full-screen atmosphere overlays such as clouds, fog, haze, grain, and lightning.
- Carries per-effect enable flags plus density, intensity, color, and speed parameters.
- Keeps overlay features opt-in so scenes can select only the layers they need.
- Provides the data model for long-lived atmospheric presentation effects.
- Separates configuration from rendering so effect logic stays lightweight.

### controller.rs

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

### mod.rs

- Screen-space overlay subsystem for ambient lighting, atmosphere, and scene transitions.
- Groups the state and render paths for weather, water, flash, fog, and fade effects.
- Keeps screen-space presentation logic under one runtime namespace.

### screen_effects.rs

- Full-screen effect state machines for flash, shake, and fade.
- Keeps each state focused on timing, activation, and per-frame parameters.
- Uses a deterministic PRNG for shake offsets without extra RNG plumbing.
- Provides the short-lived effect core used by the overlay controller.

### transition.rs

- Full-screen transition effects for fade, wipe, iris wipe, and dissolve.
- Supports string-based kind parsing with canonical name round-tripping.
- Runs with time-based forward and reverse playback modes.
- Exposes normalized progress for renderer consumption.
- Gives scene changes a compact state model with predictable timing.

### water.rs

- Animated water distortion overlay with configurable amplitude, frequency, and speed.
- Adds shallow-water tint and depth-based color shift with independent blend strengths.
- Advances the wave pattern through a time-accumulating update loop.
- Serves as the water-specific screen-space effect for overlays.

### weather.rs

- Weather particle simulation state and management for screen-space overlays.
- Supports rain, snow, hail, dust, leaves, ash, and pollen behaviors.
- Tracks particle pools, wind parameters, and an internal PRNG.
- Keeps weather spawning and motion separated from the main scene model.
- Provides reusable state for long-lived atmospheric weather effects.

## Lua API Ref

### Functions

- `lurek.overlay.new`: Creates an overlay controller for screen effects using optional dimensions.
- `lurek.overlay.newTransition`: Creates a timed screen transition with optional kind, duration, and color.

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

- `LOverlay:clear`: Clears active overlay effects and resets transient state.
- `LOverlay:drawToImage`: Renders overlay state into an image object of the requested size.
- `LOverlay:fade`: Starts a fade overlay with optional alpha and duration.
- `LOverlay:flash`: Starts a short flash overlay with optional alpha and duration.
- `LOverlay:getAmbientColor`: Returns overlay ambient RGBA color.
- `LOverlay:getCloudCount`: Returns the overlay cloud shadow count.
- `LOverlay:getCloudOpacity`: Returns cloud shadow opacity. This method is available to Lua scripts.
- `LOverlay:getCloudScale`: Returns cloud shadow scale. This method is available to Lua scripts.
- `LOverlay:getCloudSpeed`: Returns cloud shadow movement speed.
- `LOverlay:getDimensions`: Returns the overlay dimensions. This method is available to Lua scripts.
- `LOverlay:getFilmGrainIntensity`: Returns overlay film grain intensity.
- `LOverlay:getFlashAlpha`: Returns the current flash alpha. This method is available to Lua scripts.
- `LOverlay:getFogColor`: Returns overlay fog RGBA color. This method is available to Lua scripts.
- `LOverlay:getFogDensity`: Returns overlay fog density. This method is available to Lua scripts.
- `LOverlay:getHeatHazeIntensity`: Returns overlay heat haze intensity.
- `LOverlay:getHeight`: Returns the overlay height. This method is available to Lua scripts.
- `LOverlay:getLightningAlpha`: Returns the current lightning alpha.
- `LOverlay:getLightningColor`: Returns overlay lightning RGBA color.
- `LOverlay:getShakeOffset`: Returns the current screen shake offset.
- `LOverlay:getTimeOfDay`: Returns the overlay time-of-day value.
- `LOverlay:getVignetteStrength`: Returns overlay vignette strength.
- `LOverlay:getWater`: Returns a table describing the current water effect settings.
- `LOverlay:getWeather`: Returns the overlay weather type name.
- `LOverlay:getWeatherIntensity`: Returns weather intensity for the current weather type.
- `LOverlay:getWidth`: Returns the overlay width. This method is available to Lua scripts.
- `LOverlay:getWindDirection`: Returns the overlay weather wind direction.
- `LOverlay:getWindSpeed`: Returns the overlay weather wind speed.
- `LOverlay:isActive`: Returns whether any overlay effect is currently active.
- `LOverlay:isAmbientEnabled`: Returns whether overlay ambient color rendering is enabled.
- `LOverlay:isCloudShadowsEnabled`: Returns whether overlay cloud shadow rendering is enabled.
- `LOverlay:isFading`: Returns whether the fade overlay is active.
- `LOverlay:isFilmGrainEnabled`: Returns whether overlay film grain rendering is enabled.
- `LOverlay:isFlashing`: Returns whether the flash overlay is active.
- `LOverlay:isFogEnabled`: Returns whether overlay fog rendering is enabled.
- `LOverlay:isHeatHazeEnabled`: Returns whether overlay heat haze rendering is enabled.
- `LOverlay:isShaking`: Returns whether the screen shake effect is active.
- `LOverlay:isVignetteEnabled`: Returns whether overlay vignette rendering is enabled.
- `LOverlay:isWeatherEnabled`: Returns whether overlay weather rendering is enabled.
- `LOverlay:pullAmbientFromLight`: Copies ambient color from the shared light world into this overlay.
- `LOverlay:pushAmbientToLight`: Copies this overlay ambient color into the shared light world.
- `LOverlay:render`: Queues renderer commands for the overlay's current visual state.
- `LOverlay:resize`: Resizes the overlay target dimensions.
- `LOverlay:setAmbientColor`: Sets the overlay ambient color from RGBA channels.
- `LOverlay:setAmbientEnabled`: Enables or disables overlay ambient color rendering.
- `LOverlay:setCloudCount`: Sets the overlay cloud shadow count.
- `LOverlay:setCloudOpacity`: Sets cloud shadow opacity. This method is available to Lua scripts.
- `LOverlay:setCloudScale`: Sets cloud shadow scale. This method is available to Lua scripts.
- `LOverlay:setCloudShadows`: Enables or disables overlay cloud shadow rendering.
- `LOverlay:setCloudSpeed`: Sets cloud shadow movement speed. This method is available to Lua scripts.
- `LOverlay:setCustomShader`: Sets or clears the custom overlay shader name.
- `LOverlay:setFilmGrainEnabled`: Enables or disables overlay film grain rendering.
- `LOverlay:setFilmGrainIntensity`: Sets overlay film grain intensity.
- `LOverlay:setFogColor`: Sets the overlay fog color from RGBA channels.
- `LOverlay:setFogDensity`: Sets overlay fog density. This method is available to Lua scripts.
- `LOverlay:setFogEnabled`: Enables or disables overlay fog rendering.
- `LOverlay:setHeatHazeEnabled`: Enables or disables overlay heat haze rendering.
- `LOverlay:setHeatHazeIntensity`: Sets overlay heat haze intensity. This method is available to Lua scripts.
- `LOverlay:setLightningColor`: Sets overlay lightning RGBA color.
- `LOverlay:setTimeOfDay`: Sets the overlay time-of-day value used by ambient effects.
- `LOverlay:setVignetteEnabled`: Enables or disables overlay vignette rendering.
- `LOverlay:setVignetteStrength`: Sets overlay vignette strength. This method is available to Lua scripts.
- `LOverlay:setWater`: Enables water distortion and sets wave amplitude, frequency, and speed.
- `LOverlay:setWaterTint`: Sets the water tint color and strength.
- `LOverlay:setWeather`: Sets the overlay weather type by name.
- `LOverlay:setWeatherEnabled`: Enables or disables overlay weather rendering.
- `LOverlay:setWeatherIntensity`: Sets weather intensity for the current weather type.
- `LOverlay:setWindDirection`: Sets the overlay weather wind direction.
- `LOverlay:setWindSpeed`: Sets the overlay weather wind speed.
- `LOverlay:shake`: Starts a screen shake with optional duration.
- `LOverlay:syncAmbientWithLight`: Resolves overlay and light ambient colors using a named mode and writes both stores.
- `LOverlay:triggerFade`: Starts a fade overlay toward a target alpha.
- `LOverlay:triggerFlash`: Starts a screen flash with explicit RGBA color and duration.
- `LOverlay:triggerLightning`: Starts a lightning flash using the overlay lightning state.
- `LOverlay:triggerShake`: Starts a screen shake effect. This method is available to Lua scripts.
- `LOverlay:type`: Returns the Lua-visible type name for this overlay handle.
- `LOverlay:typeOf`: Returns whether this overlay handle matches a supported type name.
- `LOverlay:update`: Advances overlay timers and animated effect state.

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

- `LScreenTransition:color`: Returns the transition RGBA color.
- `LScreenTransition:isActive`: Returns whether the transition is currently active.
- `LScreenTransition:isDone`: Returns whether the transition has finished.
- `LScreenTransition:kind`: Returns the transition kind name. This method is available to Lua scripts.
- `LScreenTransition:play`: Starts this screen transition forward from its current state.
- `LScreenTransition:progress`: Returns normalized transition progress.
- `LScreenTransition:reverse`: Starts this screen transition in reverse from its current state.
- `LScreenTransition:setColor`: Sets the transition RGBA color from a numeric array table.
- `LScreenTransition:type`: Returns the Lua-visible type name for this transition handle.
- `LScreenTransition:typeOf`: Returns whether this transition handle matches a supported type name.
- `LScreenTransition:update`: Advances this transition timer and returns whether it remains active.
