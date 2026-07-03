<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/overlay.md or source docstrings instead. -->

# overlay

## TL;DR

- Manages screen-space weather, fog, camera shakes, and screen flashes.
- Supports wave distortion and transition wipes.
- Owns designer-authored status overlays that can stack color washes, fullscreen textures, and routed post-fx presets.

## General Info

- Module group: `Feature Systems`
- Source path: `src/overlay`
- Binding: `src/lua_api/overlay_api.rs`
- Namespace: `lurek.overlay`
- Lua API surface: `2` functions, `4` types, `104` methods
- User-facing: `true`
- Plugin tier: `core_keep`

## Summary

- The `overlay` module is the engine's screen-layer presentation surface for users who want weather, atmosphere, transitions, and other scene-wide visual treatments to behave as one coherent system.
- It groups full-screen and near-full-screen effects that are too global to belong to an individual sprite but too specialized to live as loose render hacks.
- This matters for fog washes, rain veils, damage flashes, atmospheric tinting, transition masks, and similar treatments that need their own timing and configuration rules.
- Weather, ambient mood, distortion-style effects, and transition controllers all belong here because they usually evolve over time rather than acting like static post-process toggles.
- Status overlays also belong here when gameplay needs controllable danger or condition feedback such as frozen, poison, low-health, blindness, radiation, or burn states to fade, stack, and report diagnostics consistently.
- That temporal behavior is the key reason the module exists: these effects are often stateful and orchestrated, not just one-frame visual filters.
- The same subsystem can therefore own persistent environmental treatment and short-lived screen transitions without burying either concern inside unrelated render code.
- Layer-wide control is important because these treatments often need coordinated fade-in, fade-out, stacking, and override rules when several moods or transitions compete for the screen at once.
- The module is useful whenever a project needs stronger screen-space presentation than a local sprite effect but does not need a full scene rewrite.
- `render` still draws the final image, but `overlay` owns the grouping, configuration, temporal behavior, accessibility policy, and diagnostics for these large-scale scene treatments.
- Read `overlay` as the orchestration layer for scene-wide atmospheric and transitional effects.

This module primarily collaborates with `color`, `image`, `render`, `runtime`. Its responsibility should stay inside the `Edge/Integration` group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/overlay`
- Owning tier: `Feature Systems`
- Plugin tier: `core_keep`
- Lua binding owner: `src/lua_api/overlay_api.rs`
- Referenced engine modules: `color`, `image`, `render`, `runtime`

## Imports

- `color`: Imports or references `src/color/`. Cross-group dependency from `Feature Systems` into `Foundations`.
- `image`: Imports or references `src/image/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Feature Systems` into `Core Runtime`.

## Source Files

### ambient.rs

- This file owns `AmbientState`, the time-of-day tint model used to compute a scene-wide overlay ambient color.
- It stores enable state, current RGBA tint, and hour-of-day input, then maps day phases to explicit color bands.
- Open this file when ambient tint semantics change; the overlay controller and light sync live in sibling modules.

### atmosphere.rs

- This file owns the long-lived overlay configs for clouds, fog, heat haze, vignette, film grain, and lightning.
- Each struct keeps only the parameters needed by that layer, such as density, speed, opacity, intensity, or color.
- Default impls provide disabled baseline values so scenes can opt into individual atmosphere layers selectively.
- No frame orchestration lives here; the file is the shared data boundary consumed by the main overlay controller.
- Open this file when atmosphere state semantics change; weather, water, and controller logic live in sibling files.

### controller/debug_image.rs

- Owns the overlay controller debug image implementation for the overlay subsystem and keeps rules local here.
- Keeps overlay state, effects, and presentation helpers ownership so helpers stay close to invariants this file updates.
- Defines how overlay controller debug image data is validated, transformed, or stored before systems consume it.
- Separates overlay controller debug image behavior from Lua bindings, tests, and sibling owners so integration readable.
- Documents the boundary where overlay code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing overlay controller debug image defaults, lifecycle handling, validation, or data rules.
- Open this owner when overlay debug imagery changes even if flash, shake, and fade state stay valid.

### controller/effects.rs

- Owns the overlay controller effects implementation for the overlay subsystem and keeps related runtime rules local here.
- Keeps overlay state, effects, and presentation helpers ownership so helpers stay close to invariants this file updates.
- Defines how overlay controller effects data is validated, transformed, or stored before neighboring systems consume it.
- Separates overlay controller effects behavior from Lua bindings, tests, and sibling owners so integration readable.
- Documents the boundary where overlay code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing overlay controller effects defaults, lifecycle handling, validation, or data rules.
- Keeps failure paths and edge cases near overlay controller effects state that explains them instead of outward.

### controller/render.rs

- Owns the overlay controller render implementation for the overlay subsystem and keeps related runtime rules local here.
- Keeps overlay state, effects, and presentation helpers ownership so helpers stay close to invariants this file updates.
- Defines how overlay controller render data is validated, transformed, or stored before neighboring systems consume it.
- Separates overlay controller render behavior from Lua bindings, tests, and sibling owners so integration stays readable.
- Documents the boundary where overlay code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing overlay controller render defaults, lifecycle handling, validation, or data ownership rules.
- Open this owner when overlay layer ordering or draw responsibility shifts even if effect state stays valid.

### controller/weather.rs

- Owns the overlay controller weather implementation for the overlay subsystem and keeps related runtime rules local here.
- Keeps overlay state, effects, and presentation helpers ownership so helpers stay close to invariants this file updates.
- Defines how overlay controller weather data is validated, transformed, or stored before neighboring systems consume it.
- Separates overlay controller weather behavior from Lua bindings, tests, and sibling owners so integration readable.
- Documents the boundary where overlay code accepts inputs, reports errors, allocates state, or emits outputs.

### controller.rs

- Owns the overlay controller implementation for the overlay subsystem and keeps related runtime rules local here.
- Keeps overlay state, effects, and presentation helpers ownership so helpers stay close to invariants this file updates.
- Defines how overlay controller data is validated, transformed, or stored before neighboring systems consume it.
- Separates overlay controller behavior from Lua bindings, tests, and sibling owners so integration stays readable.
- Documents the boundary where overlay code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing overlay controller defaults, lifecycle handling, validation, or data ownership rules.
- Keeps failure paths and edge cases near overlay controller state that explains them instead of spreading rules outward.
- Preserves deterministic behavior by keeping overlay controller calculations explicit at their owning subsystem boundary.
- Provides local adaptation layer that lets callers reuse overlay controller rules without duplicating engine decisions.
- Open this owner before sibling files when a regression centers on overlay controller state, helpers, or rules.
- Works with neighboring overlay owners while keeping the main overlay controller responsibility anchored in one file.

### mod.rs

- This module re-exports overlay surface for `ambient.rs`, `atmosphere.rs`, `controller.rs`, and helpers.
- It keeps navigation explicit by showing which sibling files own state, validation, transport, or render behavior.
- Public exports here route callers toward `ambient.rs`, `atmosphere.rs`, and `controller.rs` first, while deeper owners.
- Open this file when the public overlay symbol map moves; edit siblings when runtime rules themselves change.
- This index exists to organize entrypoints, not to absorb the state, caches, or algorithms its children own.
- Use neighboring owners for behavioral fixes, and keep this file limited to exports, docs, and navigation.

### screen_effects.rs

- This file owns `FlashState`, `ShakeState`, and `FadeState`, the short-lived full-screen effect data models.
- It keeps timing, activation flags, colors, alphas, offsets, and a deterministic shake PRNG local to one owner.
- The only behavior here is the shake sampler, leaving frame-by-frame orchestration to the overlay controller.
- Open this file when timed overlay state semantics change; transition playback and controller updates live in siblings.

### status.rs

- Owns the overlay status implementation for the overlay subsystem and keeps related runtime rules local here.
- Keeps overlay state, effects, and presentation helpers ownership so helpers stay close to invariants this file updates.
- Defines how overlay status data is validated, transformed, or stored before neighboring systems consume it.
- Separates overlay status behavior from Lua bindings, tests, and sibling owners so integration stays readable.
- Documents the boundary where overlay code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing overlay status defaults, lifecycle handling, validation, or data ownership rules.
- Keeps failure paths and edge cases near the overlay status state that explains them instead of spreading rules outward.

### transition.rs

- This file owns `TransitionKind` and `ScreenTransition`, the full-screen transition playback model for overlay rendering.
- It parses string names into fade, wipe, iris wipe, or dissolve modes and round-trips canonical lowercase names.
- Runtime state stores transition color, duration, elapsed time, active status, and reverse-playback direction.
- Update helpers advance clamped progress and expose `is_active` plus `is_done` for renderer-facing control.
- Open this file when transition semantics change; short-lived flash and fade state live in sibling overlay files.

### water.rs

- This file owns `WaterOverlayState`, the animated water-distortion and tint model used by the overlay subsystem.
- It stores distortion amplitude, wave frequency, speed, shallow tint, deep color shift, blend strengths, and time.
- Update helpers only advance animation when enabled and can reset every parameter back to the default water profile.
- Open this file when water overlay semantics change; controller orchestration and atmosphere layers live in siblings.

### weather.rs

- Owns overlay behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps overlay data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how weather data is validated, transformed, or stored before neighboring systems use it.
- Owns overlay behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on weather behavior while Lua registration stays elsewhere.
- Documents the boundary where overlay code accepts inputs, reports errors, or updates state.
- Use this file when changing weather defaults, lifecycle handling, validation, or data ownership.



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
- `LOverlay:clearStatusEffect(kind, opts?) -> nil`: Starts fading out one status layer.
- `LOverlay:drawToImage(w, h) -> Image`: Renders overlay state into an image object of the requested size.
- `LOverlay:fade(r, g, b, a?, dur?) -> nil`: Starts a fade overlay with optional alpha and duration.
- `LOverlay:flash(r, g, b, a?, dur?) -> nil`: Starts a short flash overlay with optional alpha and duration.
- `LOverlay:getAccessibilityPolicy() -> table`: Returns the current overlay accessibility policy.
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
- `LOverlay:getRenderPlan() -> table`: Returns the current render responsibility plan for active overlay layers.
- `LOverlay:getShader() -> LShader`: Returns the shader bound to this overlay, if any.
- `LOverlay:getShaderLayer(layer) -> LShader`: Returns a shader bound to one overlay layer, if present.
- `LOverlay:getShakeOffset() -> number`: Returns the current screen shake offset.
- `LOverlay:getStats() -> table`: Returns a telemetry snapshot for dashboard and debug workflows.
- `LOverlay:getStatusEffect(kind) -> table`: Returns one status layer table or nil.
- `LOverlay:getStatusEffects() -> table`: Returns all current status layers sorted by priority.
- `LOverlay:getTimeOfDay() -> number`: Returns the overlay time-of-day value.
- `LOverlay:getVignetteStrength() -> number`: Returns overlay vignette strength.
- `LOverlay:getWater() -> table`: Returns a table describing the current water effect settings.
- `LOverlay:getWeather() -> string`: Returns the overlay weather type name.
- `LOverlay:getWeatherIntensity() -> number`: Returns weather intensity for the current weather type.
- `LOverlay:getWeatherRngState() -> integer`: Returns the current deterministic overlay weather RNG state.
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
- `LOverlay:render(opts?) -> nil`: Queues renderer commands for the overlay's current visual state.
- `LOverlay:resize(w, h) -> nil`: Resizes the overlay target dimensions.
- `LOverlay:setAccessibilityPolicy(policy?) -> nil`: Replaces or partially updates the overlay accessibility policy.
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
- `LOverlay:setShader(shader?) -> nil`: Sets or clears the shader used for custom overlay rendering.
- `LOverlay:setShaderLayer(layer, shader?) -> nil`: Sets or clears an overlay-layer shader binding.
- `LOverlay:setStatusEffect(kind, opts) -> nil`: Creates or updates one overlay-owned status layer such as `frozen`, `poison`, or `lowHealth`.
- `LOverlay:setStatusIntensity(kind, intensity) -> nil`: Updates one existing status intensity or creates a preset-backed layer when it is missing.
- `LOverlay:setTimeOfDay(v) -> nil`: Sets the overlay time-of-day value used by ambient effects.
- `LOverlay:setVignetteEnabled(v) -> nil`: Enables or disables overlay vignette rendering.
- `LOverlay:setVignetteStrength(v) -> nil`: Sets overlay vignette strength. This method is available to Lua scripts.
- `LOverlay:setWater(amplitude, frequency, speed) -> nil`: Enables water distortion and sets wave amplitude, frequency, and speed.
- `LOverlay:setWaterTint(r, g, b, strength) -> nil`: Sets the water tint color and strength.
- `LOverlay:setWeather(name) -> nil`: Sets the overlay weather type by name.
- `LOverlay:setWeatherEnabled(v) -> nil`: Enables or disables overlay weather rendering.
- `LOverlay:setWeatherIntensity(v) -> nil`: Sets weather intensity for the current weather type.
- `LOverlay:setWeatherRngState(state) -> nil`: Replaces the current deterministic overlay weather RNG state.
- `LOverlay:setWeatherSeed(seed) -> nil`: Sets the deterministic overlay weather seed used for future particle sampling.
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

#### LOverlayGetStatsResult Type

- Generated result shape from @field tags.

##### Fields

- `active_effects` (`integer`): Count of currently active overlay subsystems.
- `active_status_layers` (`integer`): Count of status layers currently contributing visible work.
- `height` (`integer`): Overlay height in pixels.
- `status_layers` (`integer`): Count of authored status layers stored in the overlay stack.
- `width` (`integer`): Overlay width in pixels.

##### Methods

- No documented methods.

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

## Examples

- `content/examples/overlay.lua` (present)

## Architecture Links

- `docs/architecture/module-scope-boundaries.md`
- `docs/architecture/effects-particles-overlay-plan.md`

## Notes

- Ownership boundary:
  `overlay` owns scene-wide screen presentation policy and temporal orchestration: weather, ambient tint, flash, fade, shake, lightning, accessibility, layer ordering, and diagnostics. It may request post-fx work through explicit descriptors, but it must not own shader catalogs, post-fx stack ordering, or capture lifecycle; those belong to `effect` and `render`.
- Status stack contract:
  Status layers are overlay-owned descriptors with stable ids, normalized intensity, fade in/out timing, priority ordering, optional fullscreen texture metadata, and optional built-in post-fx names. Lua should treat them as authored presentation state, not as ad hoc one-frame shader toggles.
- Targeting contract:
  Status layers may be authored for `sceneOnly`, `hudBack`, `hudFront`, or `fullScreenTop`. Scripts place them by calling `overlay:render({ target = ... })` in the appropriate frame phase rather than by pushing presentation policy into physics or gameplay modules.
- Render boundary:
  Direct overlay commands are suitable for simple color/shape layers. Shader-backed treatments such as heat haze, water distortion, film grain, cloud shadows, CRT, pixelate, upscale/downscale, or full-frame grading should route through post-fx descriptors and renderer execution.
- Routing boundary:
  A status layer may contribute direct fullscreen color or texture work and may also request a built-in post-fx pass such as grayscale, vignette, blur, chromatic offset, scanlines, or noise. Overlay decides which parts are directly rendered versus delegated to renderer-managed post-fx execution.
- Accessibility boundary:
  Reduced-motion policy also applies to status layers: high-alpha washes are clamped, grain-like `noise` / `scanlines` passes can be disabled, and heavy distortion-style passes are reduced so danger feedback remains readable without strobing or harsh full-screen pulses.
- World boundary:
  Overlay is screen-space after the world. World-space effects such as sparks behind an isometric wall, dust at a tile collision, or object-local trails belong to `particle`/`scene`/`tilemap` depth ordering, not overlay.
