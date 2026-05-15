# effect

## General Info

- Module group: `Platform Services`
- Source path: `src/effect/`
- Lua API path(s): `src/lua_api/effect_api.rs`
- Primary Lua namespace: `lurek.effect`
- Rust test path(s): tests/rust/unit/effect_tests.rs
- Lua test path(s): tests/lua/unit/test_effect_core_unit.lua, tests/lua/integration/test_effect_camera.lua, tests/lua/integration/test_effect_light.lua, tests/lua/evidence/test_effect_evidence.lua

## Summary

Post-processing and screen effect pipeline operating on rendered frames. `PostFxStack` manages an ordered list of `PostFxEffect` instances that process the frame buffer sequentially — effects include blur (Gaussian, box, radial), bloom (threshold + blur + additive blend), color grading (LUT-based), lens distortion, vignette, chromatic aberration, scanlines, CRT curvature, film grain, and pixelation.

`ImageEffect` provides CPU-side per-pixel operations for cases where GPU post-processing is not needed. `Overlay` manages ambient lighting state, weather particle overlays (rain, snow, fog, dust), and screen-space flash/fade/shake. `WaterOverlay` adds animated water surface distortion. Transition effects (fade, wipe, dissolve, pixelate) bridge scene changes. Each effect is configured via Lua tables and controlled through `lurek.effect.*`.

## Source Documentation

### `ambient.rs`
- Global ambient tint state driven by a time-of-day curve.
- Maps hour values (0–24) to RGBA color through piecewise dawn/day/dusk/night segments.
- Consumed by the overlay renderer when the ambient effect is enabled.

### `atmosphere.rs`
- State structs for full-screen atmosphere overlays: clouds, fog, heat haze, vignette, film grain, and lightning flash.
- Each struct carries enabled flag plus effect-specific parameters (density, intensity, color, speed).
- All default to disabled so overlays are opt-in per scene.

### `draw.rs`
- Render a preview image summarizing the current post-FX stack state.
- Produce a solid-color thumbnail indicating whether any effects are active.

### `effect.rs`
- Post-processing effect instance holding type, parameters, and enabled state.
- Built-in effects carry default params; custom effects bind to an explicit shader id.
- Parameter accessors for reading, writing, and listing scalar uniforms.

### `effect_type.rs`
- Post-processing effect type enumeration and name registry.
- Canonical lowercase name mapping for Lua-facing effect lookup.
- Debug label generation for renderer diagnostics.
- Default parameter tables for each built-in effect.
- Built-in effect catalog excluding the custom shader pass.

### `image_effect.rs`
- Image-scoped post-processing effect pipeline that groups and orders shader passes.
- Provides add, remove, lookup-by-index/name, and clear operations on owned or shared effects.
- Converts the active pipeline into renderer-ready `ShaderPassDescriptor` sequences.

### `mod.rs`
- Post-processing effect stack: bloom, blur, CRT, vignette, film grain, and custom shaders.
- Screen overlays: weather particles, fog, heat haze, water distortion, flashes, and fades.
- Atmosphere and ambient color derived from time-of-day.
- Named presets and per-image effect ordering.

### `overlay.rs`
- Central `Overlay` struct owning every screen-space post-world effect state block.
- Per-frame update loop advancing weather particles, flash decay, shake decay, fade interpolation, cloud scroll, and lightning.
- Weather particle spawning and simulation for rain, snow, hail, dust, leaves, ash, and pollen modes.
- Trigger API for flash, camera shake, screen fade, and lightning flash events.
- Query helpers for shake offset, flash/lightning alpha, active state, and target dimensions.
- Render command builder emitting full-screen colored rectangles for flash, fade, lightning, and vignette overlays.
- Clear/reset restoring all subsystems to default inactive state.
- Debug visualization: state panels, flash frame strips, shake offset trails, fade transition strips, and combined trigger previews.

### `presets.rs`
- Built-in post-processing effect presets (retro TV, horror, dream, neon, sepia).
- Preset construction with viewport-sized stack initialization.
- Static name lookup for canonical preset identifiers.

### `render.rs`
- Render-command integration for the post-effects stack.
- Emits begin/end/apply command sequences consumed by the renderer.
- Skips command generation when no effects are enabled.

### `screen_effects.rs`
- Full-screen effect state machines: flash, shake, and fade.
- Each state tracks active flag, timing, and per-frame parameters.
- Deterministic PRNG for shake offsets without external RNG dependency.

### `stack.rs`
- Ordered post-processing effect stack with per-entry enable flags.
- Index-based effect references aligned with a parallel enabled vector.
- Stack manipulation: add, remove, insert, reorder, deduplicate.
- Query helpers for enabled subset, dimensions, and positional lookup.
- Debug visualization renderers for stack state, catalogs, parameters, and type bars.

### `transition.rs`
- Full-screen transition effects: fade, wipe, iris wipe, and dissolve.
- String-based kind parsing with canonical name round-tripping.
- Time-based playback lifecycle with forward and reverse modes.
- Normalized progress query for renderer consumption.

### `water_overlay.rs`
- Animated water distortion overlay with configurable amplitude, frequency, and speed.
- Shallow-water tint and depth-based color shift with independent blend strengths.
- Time-accumulating update loop that advances the wave pattern each frame.

### `weather.rs`
- Weather particle simulation types and state management.
- Supports rain, snow, hail, dust, leaves, ash, and pollen behaviors.
- Tracks particle pool, wind parameters, and internal PRNG.

## Types

- `AmbientState` (`struct`, `ambient.rs`): Time-of-day ambient tint controller used by Overlay.
- `CloudState` (`struct`, `atmosphere.rs`): Cloud shadow overlay state.
- `FogState` (`struct`, `atmosphere.rs`): Atmospheric fog state.
- `HeatHazeState` (`struct`, `atmosphere.rs`): Heat haze distortion state.
- `VignetteState` (`struct`, `atmosphere.rs`): Vignette screen-edge darkening state.
- `FilmGrainState` (`struct`, `atmosphere.rs`): Film grain noise overlay state.
- `LightningState` (`struct`, `atmosphere.rs`): Lightning flash state.
- `PostFxEffect` (`struct`, `effect.rs`): One post-processing pass with effect type, parameter map, enabled flag, and optional custom shader handle.
- `PostFxEffectType` (`enum`, `effect_type.rs`): Enum naming the built-in post-processing pass types and their default parameter sets.
- `ImageEffect` (`struct`, `image_effect.rs`): Ordered per-image effect chain that converts to lightweight shader pass descriptors.
- `Overlay` (`struct`, `overlay.rs`): Top-level per-frame overlay state that updates ambient, weather, flashes, fades, shake, and atmospheric effects together.
- `EffectPreset` (`struct`, `presets.rs`): A fully configured preset: an ordered stack of effects with their data.
- `FlashState` (`struct`, `screen_effects.rs`): Flash screen effect state.
- `ShakeState` (`struct`, `screen_effects.rs`): Shake screen effect state.
- `FadeState` (`struct`, `screen_effects.rs`): Fade screen effect state.
- `PostFxStack` (`struct`, `stack.rs`): Ordered full-frame post-processing pipeline with per-pass enabled flags and capture dimensions.
- `TransitionKind` (`enum`, `transition.rs`): The visual style of a screen transition.
- `ScreenTransition` (`struct`, `transition.rs`): Frame-by-frame state machine for a screen transition.
- `WaterOverlayState` (`struct`, `water_overlay.rs`): Full-screen water-surface overlay state.
- `WeatherType` (`enum`, `weather.rs`): Weather particle types supported by the effect system.
- `WeatherParticle` (`struct`, `weather.rs`): A single weather particle in the effect's weather system.
- `WeatherState` (`struct`, `weather.rs`): Weather particle simulation state including type, wind, intensity, and live particles.

## Functions

- `AmbientState::compute_color_from_time` (`ambient.rs`): Computes the ambient RGBA tint for the current time-of-day sample.
- `PostFxStack::draw_to_image` (`draw.rs`): Renders a solid-color preview image that reflects whether any stack effects are enabled.
- `PostFxEffect::new` (`effect.rs`): Creates an enabled built-in effect with its default parameter set.
- `PostFxEffect::new_custom` (`effect.rs`): Creates an enabled custom effect bound to an explicit shader id.
- `PostFxEffect::set_parameter` (`effect.rs`): Inserts or replaces one scalar effect parameter.
- `PostFxEffect::get_parameter` (`effect.rs`): Returns a scalar effect parameter or the caller-provided fallback.
- `PostFxEffect::has_parameter` (`effect.rs`): Returns whether a named scalar parameter is present.
- `PostFxEffect::get_parameter_names` (`effect.rs`): Returns the sorted list of parameter names defined on this effect.
- `PostFxEffect::get_type_name` (`effect.rs`): Returns the lowercase effect type name used by renderer-facing code.
- `PostFxEffect::is_built_in` (`effect.rs`): Returns whether this effect uses a built-in effect type.
- `PostFxEffect::new_disabled` (`effect.rs`): Creates a built-in effect in the disabled state.
- `PostFxEffect::set_param` (`effect.rs`): Convenience alias for setting one scalar effect parameter.
- `PostFxEffect::get_param_or` (`effect.rs`): Convenience alias for fetching one scalar effect parameter with a fallback.
- `PostFxEffectType::from_name` (`effect_type.rs`): Resolves a lowercase built-in effect name into the matching enum entry.
- `PostFxEffectType::built_in_names` (`effect_type.rs`): Returns the lowercase names for all non-custom built-in effect types.
- `PostFxEffectType::name` (`effect_type.rs`): Returns the lowercase canonical name for this effect type.
- `PostFxEffectType::debug_label` (`effect_type.rs`): Returns the uppercase debug label used in renderer diagnostics.
- `PostFxEffectType::default_params` (`effect_type.rs`): Returns the default scalar parameter map for this effect type.
- `ImageEffect::new` (`image_effect.rs`): Creates an empty image effect pipeline with the given debug name.
- `ImageEffect::add_effect` (`image_effect.rs`): Appends a new owned effect instance to the pipeline.
- `ImageEffect::add_effect_rc` (`image_effect.rs`): Appends a shared effect handle to the pipeline without cloning it.
- `ImageEffect::get_effect_by_index` (`image_effect.rs`): Returns the shared effect handle at the given zero-based index.
- `ImageEffect::get_effect_by_name` (`image_effect.rs`): Returns the first effect whose type name matches the requested name.
- `ImageEffect::remove_by_index` (`image_effect.rs`): Removes the effect at the given zero-based index.
- `ImageEffect::remove_by_name` (`image_effect.rs`): Removes the first effect whose type name matches the requested name.
- `ImageEffect::clear` (`image_effect.rs`): Removes every effect from the pipeline.
- `ImageEffect::effect_count` (`image_effect.rs`): Returns the number of effects currently stored in the pipeline.
- `ImageEffect::to_passes` (`image_effect.rs`): Converts the pipeline into renderer shader pass descriptors.
- `Overlay::new` (`overlay.rs`): Creates an overlay initialized with default state blocks for the target size.
- `Overlay::update` (`overlay.rs`): Advances every active overlay subsystem by `dt` seconds.
- `Overlay::trigger_flash` (`overlay.rs`): Starts a flash overlay with the supplied color, alpha, and duration.
- `Overlay::trigger_shake` (`overlay.rs`): Starts a camera shake with the supplied intensity and duration.
- `Overlay::trigger_fade` (`overlay.rs`): Starts a fade toward the supplied target alpha over the given duration.
- `Overlay::trigger_lightning` (`overlay.rs`): Starts a short lightning flash using the configured lightning state.
- `Overlay::get_shake_offset` (`overlay.rs`): Returns the current camera shake offset.
- `Overlay::is_active` (`overlay.rs`): Returns whether any overlay subsystem is currently enabled or animating.
- `Overlay::clear` (`overlay.rs`): Restores every overlay subsystem to its default inactive state.
- `Overlay::resize` (`overlay.rs`): Updates the overlay target dimensions.
- `Overlay::get_width` (`overlay.rs`): Returns the overlay target width.
- `Overlay::get_height` (`overlay.rs`): Returns the overlay target height.
- `Overlay::get_dimensions` (`overlay.rs`): Returns the overlay target dimensions as `(width, height)`.
- `Overlay::get_flash_alpha` (`overlay.rs`): Computes the current flash alpha after time decay.
- `Overlay::get_lightning_alpha` (`overlay.rs`): Computes the current lightning flash alpha after time decay.
- `Overlay::build_render_commands` (`overlay.rs`): Builds render commands for currently active full-screen overlay layers.
- `Overlay::draw_state_to_image` (`overlay.rs`): Renders a debug image showing current flash, shake, and fade state.
- `Overlay::draw_flash_sequence_to_image` (`overlay.rs`): Renders a frame strip showing the time evolution of a flash overlay.
- `Overlay::draw_shake_trail_to_image` (`overlay.rs`): Renders a debug image showing a series of shake offsets as a trail.
- `Overlay::draw_fade_transition_to_image` (`overlay.rs`): Renders a frame strip showing fade alpha samples across multiple steps.
- `Overlay::draw_trigger_panel_to_image` (`overlay.rs`): Renders a debug panel previewing flash, shake, fade, and lightning triggers.
- `preset_names` (`presets.rs`): Returns a list of all available preset names.
- `build_preset` (`presets.rs`): Builds a named preset stack, returning `None` when the name is unknown.
- `PostFxStack::begin_capture_command` (`render.rs`): Builds the command that starts post-effect capture for a stack id.
- `PostFxStack::end_capture_command` (`render.rs`): Builds the command that ends post-effect capture for a stack id.
- `PostFxStack::apply_command` (`render.rs`): Builds the command that applies the captured stack output at the stack dimensions.
- `PostFxStack::generate_render_commands` (`render.rs`): Emits the capture and apply command sequence when the stack has enabled effects.
- `ShakeState::next_random` (`screen_effects.rs`): Advances the shake PRNG and returns a sample in the `[-1, 1]` range.
- `PostFxStack::new` (`stack.rs`): Creates an empty post-effect stack for the given render size.
- `PostFxStack::add` (`stack.rs`): Appends an enabled effect index to the end of the stack.
- `PostFxStack::remove` (`stack.rs`): Removes the first stack entry that references the given effect index.
- `PostFxStack::insert` (`stack.rs`): Inserts an enabled effect index at a one-based stack position.
- `PostFxStack::set_enabled` (`stack.rs`): Sets the enable flag for the first stack entry that references the effect index.
- `PostFxStack::is_enabled` (`stack.rs`): Returns the enable flag for the first stack entry that references the effect index.
- `PostFxStack::get_effect_count` (`stack.rs`): Returns the number of stack entries.
- `PostFxStack::get_effect` (`stack.rs`): Returns the effect index at a one-based stack position.
- `PostFxStack::enabled_effects` (`stack.rs`): Returns the effect indices whose stack entries are currently enabled.
- `PostFxStack::resize` (`stack.rs`): Updates the target render dimensions stored on the stack.
- `PostFxStack::get_width` (`stack.rs`): Returns the target render width.
- `PostFxStack::get_height` (`stack.rs`): Returns the target render height.
- `PostFxStack::get_dimensions` (`stack.rs`): Returns the target render dimensions as `(width, height)`.
- `PostFxStack::len` (`stack.rs`): Returns the number of stack entries.
- `PostFxStack::is_empty` (`stack.rs`): Returns whether the stack has no entries.
- `PostFxStack::clear` (`stack.rs`): Removes every stack entry and enable flag.
- `PostFxStack::dedup_indices` (`stack.rs`): Removes duplicate effect indices while preserving first occurrence order.
- `PostFxStack::draw_info_to_image` (`stack.rs`): Renders a debug overview of stack entries and their enabled state.
- `PostFxStack::draw_stack_management_to_image` (`stack.rs`): Renders a labeled debug panel for stack management operations.
- `PostFxStack::draw_effect_catalog_to_image` (`stack.rs`): Renders a tiled debug catalog for effect labels and representative colors.
- `PostFxStack::draw_effect_parameters_to_image` (`stack.rs`): Renders a labeled debug panel showing effect parameter names and values.
- `PostFxStack::draw_effect_type_bars_to_image` (`stack.rs`): Renders one colored debug row per effect type together with its parameter count.
- `PostFxStack::draw_effect_types_to_image` (`stack.rs`): Renders a debug catalog for a list of effect types using synthetic colors.
- `TransitionKind::from_str` (`transition.rs`): Parses a user-facing transition name, defaulting to fade for unknown values.
- `TransitionKind::name` (`transition.rs`): Returns the lowercase canonical name for this transition kind.
- `ScreenTransition::new` (`transition.rs`): Creates an inactive transition with clamped nonzero duration.
- `ScreenTransition::play` (`transition.rs`): Starts forward playback from the beginning.
- `ScreenTransition::reverse` (`transition.rs`): Starts reverse playback from the beginning.
- `ScreenTransition::update` (`transition.rs`): Advances playback by `dt` seconds and returns whether the transition was active.
- `ScreenTransition::progress` (`transition.rs`): Returns normalized transition progress after applying reverse playback.
- `ScreenTransition::is_active` (`transition.rs`): Returns whether the transition is currently playing.
- `ScreenTransition::is_done` (`transition.rs`): Returns whether playback has reached the end of the transition.
- `WaterOverlayState::new` (`water_overlay.rs`): Creates a water overlay with default parameters.
- `WaterOverlayState::update` (`water_overlay.rs`): Advances the overlay animation clock while the effect is enabled.
- `WaterOverlayState::reset` (`water_overlay.rs`): Restores every water overlay parameter to its default value.
- `WeatherType::from_name` (`weather.rs`): Resolves a lowercase weather type name into the matching enum entry.
- `WeatherType::name` (`weather.rs`): Returns the lowercase canonical name for this weather type.
- `WeatherState::next_unit` (`weather.rs`): Advances the internal PRNG and returns a sample in the `[0, 1)` range.

## Lua API Reference

- Binding path(s): `src/lua_api/effect_api.rs`
- Namespace: `lurek.effect`

### Module Functions
- `lurek.effect.newEffect`: Creates a built-in post-processing effect by type name.
- `lurek.effect.newCustomEffect`: Creates a custom post-processing effect that references an existing shader id.
- `lurek.effect.newStack`: Creates a post-processing stack using optional dimensions or the current window size.
- `lurek.effect.newPresetStack`: Creates a named preset post-processing stack with optional dimensions.
- `lurek.effect.newPass`: Creates a custom post-processing pass from an existing shader id.
- `lurek.effect.getEffectTypes`: Returns all built-in post-processing effect type names.
- `lurek.effect.newImageEffect`: Creates an image effect chain from no arguments, a type name and optional parameters, or a chain table.
- `lurek.effect.newOverlay`: Creates an overlay controller for screen effects using optional dimensions.
- `lurek.effect.newTransition`: Creates a timed screen transition with optional kind, duration, and color.
- `lurek.effect.setShaderErrorDisplay`: Enables or disables renderer shader error display overlays.
- `lurek.effect.getShaderErrorDisplay`: Returns whether renderer shader error display overlays are enabled.

### `LImageEffect` Methods
- `LImageEffect:addEffect`: Appends a built-in post-effect by type name to this image effect chain.
- `LImageEffect:getEffect`: Looks up an image effect by one-based index or effect type name.
- `LImageEffect:removeEffect`: Removes an image effect by one-based index or effect type name.
- `LImageEffect:clearEffects`: Removes every effect from this image effect chain.
- `LImageEffect:clear`: Removes every effect from this image effect chain.
- `LImageEffect:effectCount`: Returns the number of effects in this image effect chain.
- `LImageEffect:getEffectCount`: Returns the number of effects in this image effect chain.
- `LImageEffect:clone`: Creates a new image effect chain with cloned effect entries.
- `LImageEffect:save`: Reports success for the current image effect save placeholder.
- `LImageEffect:type`: Returns the Lua-visible type name for this image effect handle.
- `LImageEffect:typeOf`: Returns whether this image effect handle matches a supported type name.
- `LImageEffect:removeByIndex`: Removes an image effect by zero-based internal index.
- `LImageEffect:removeByName`: Removes the first image effect with a matching effect type name.

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
- `LOverlay:setAmbientColor`: Sets overlay ambient RGBA color. This method is available to Lua scripts.
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
- `LOverlay:setFogColor`: Sets overlay fog RGBA color. This method is available to Lua scripts.
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

### `LPostFxEffect` Methods
- `LPostFxEffect:getTypeName`: Returns the built-in or custom effect type name.
- `LPostFxEffect:isBuiltIn`: Returns whether this effect uses one of the engine built-in effect types.
- `LPostFxEffect:isEnabled`: Returns whether this effect is enabled on its owning effect object.
- `LPostFxEffect:setEnabled`: Enables or disables this effect. This method is available to Lua scripts.
- `LPostFxEffect:setParameter`: Sets a numeric shader parameter by name.
- `LPostFxEffect:getParameter`: Reads a numeric shader parameter and falls back to a default value when missing.
- `LPostFxEffect:hasParameter`: Returns whether a shader parameter exists on this effect.
- `LPostFxEffect:getParameterNames`: Returns the parameter names stored on this effect.
- `LPostFxEffect:getEffectType`: Returns the renderer effect type name.
- `LPostFxEffect:getType`: Returns the renderer effect type name.
- `LPostFxEffect:type`: Returns the Lua-visible type name for this post-processing effect handle.
- `LPostFxEffect:typeOf`: Returns whether this effect handle matches a supported type name.
- `LPostFxEffect:setThreshold`: Sets the `threshold` shader parameter.
- `LPostFxEffect:setIntensity`: Sets the `intensity` shader parameter.
- `LPostFxEffect:setRadius`: Sets the `radius` shader parameter.
- `LPostFxEffect:setStrength`: Sets the `strength` shader parameter.
- `LPostFxEffect:setScanlineStrength`: Sets the `scanline_strength` shader parameter.
- `LPostFxEffect:setOffset`: Sets the `offset` shader parameter.
- `LPostFxEffect:setBrightness`: Sets the `brightness` shader parameter.
- `LPostFxEffect:setContrast`: Sets the `contrast` shader parameter.
- `LPostFxEffect:setSaturation`: Sets the `saturation` shader parameter.
- `LPostFxEffect:enableAutoUniforms`: Enables automatic time and resolution uniforms for this effect.
- `LPostFxEffect:disableAutoUniforms`: Disables automatic time and resolution uniforms for this effect.
- `LPostFxEffect:isAutoUniforms`: Returns whether automatic uniforms are enabled for this effect.

### `LPostFxStack` Methods
- `LPostFxStack:add`: Appends an effect to the end of this stack.
- `LPostFxStack:remove`: Removes the first matching effect handle from this stack.
- `LPostFxStack:insert`: Inserts an effect at a one-based stack position.
- `LPostFxStack:setEnabled`: Enables or disables the effect pass at a one-based stack position.
- `LPostFxStack:isEnabled`: Returns whether the effect pass at a one-based position is enabled.
- `LPostFxStack:getEffectCount`: Returns the number of effect handles in this stack.
- `LPostFxStack:getEffect`: Returns the effect handle at a one-based position.
- `LPostFxStack:getEnabledEffects`: Returns effect handles whose stack passes are enabled.
- `LPostFxStack:getWidth`: Returns the stack render width. This method is available to Lua scripts.
- `LPostFxStack:getHeight`: Returns the stack render height. This method is available to Lua scripts.
- `LPostFxStack:getDimensions`: Returns the stack render dimensions.
- `LPostFxStack:resize`: Resizes the post-processing stack render target dimensions.
- `LPostFxStack:len`: Returns the number of effect handles in this stack.
- `LPostFxStack:isEmpty`: Returns whether this stack has no effects.
- `LPostFxStack:clear`: Removes all effects and pass state from this stack.
- `LPostFxStack:dedup`: Removes duplicate effect handles while preserving first occurrences.
- `LPostFxStack:isCapturing`: Returns whether this stack is currently capturing draw commands.
- `LPostFxStack:beginCapture`: Starts post-effect capture and queues a renderer begin-capture command.
- `LPostFxStack:endCapture`: Ends post-effect capture and queues a renderer end-capture command.
- `LPostFxStack:apply`: Queues this stack's enabled post-effect passes for renderer application.
- `LPostFxStack:type`: Returns the Lua-visible type name for this post-processing stack handle.
- `LPostFxStack:typeOf`: Returns whether this stack handle matches a supported type name.
- `LPostFxStack:setFeedback`: Sets the stack feedback blend factor and clamps it to 0.0 through 1.0.
- `LPostFxStack:getFeedback`: Returns the current stack feedback blend factor.
- `LPostFxStack:clearFeedback`: Resets the stack feedback blend factor to zero.

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

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/effect/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
