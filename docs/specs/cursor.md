<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/cursor.md or source docstrings instead. -->

# cursor

## TL;DR

- Manages contextual custom cursors, motion trails, and magnifiers.

## General Info

- Module group: `Feature Systems`
- Source path: `src/cursor`
- Binding: `src/lua_api/cursor_api.rs`
- Namespace: `lurek.cursor`
- Lua API surface: `4` functions, `7` types, `37` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `cursor` module is the pointer-behavior surface for users who want the cursor to feel like part of the game UX rather than a fixed OS artifact.
- System cursors, custom RGBA cursors, animated states, and context-driven switching work together so interaction modes can communicate themselves visually without extra UI explanation.
- The runtime now treats cursor behavior as one shared active controller rather than isolated per-manager state, which lets hover, click, wheel, trails, bursts, and zoom resolve against one authoritative pointer state each frame.
- State switching is no longer just a manual `if` chain in Lua. `defineState`, `defineEffect`, `addRule`, and `addSource` let projects describe cursor policy declaratively and feed semantic hover hits into the same resolver.
- Trail effects, zoom-lens support, locking, visibility control, click bursts, and mode-aware switching extend the same module into readability, precision work, and tool-oriented pointer behavior.
- That makes the module especially useful for menus, editors, strategy controls, drag-and-drop flows, and inspection-heavy screens where the cursor is a major part of the interaction language.
- Read `cursor` as the owner of cursor presentation and cursor-state policy. Other systems decide which interaction mode is active, but `cursor` decides how that mode is expressed to the user.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Ownership

- Canonical source: `src/cursor`
- Owning tier: `Feature Systems`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/cursor_api.rs`
- Referenced engine modules: `globe`, `render`, `runtime`

## Imports

- `globe`: Imports or references `src/globe/`. Cross-group dependency from `Feature Systems` into `Foundations`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Feature Systems` into `Core Runtime`.

## Source Files

### animated_cursor.rs

- `src/cursor/animated_cursor.rs` owns frame-based animated cursor playback and optional pulse-scaling behavior.
- It defines `PulseConfig`, `CursorFrame`, and `AnimatedCursor`, keeping frame timing and pulse state together.
- Frame advancement, looping policy, current-frame lookup, and pulse-derived scale calculation all live here.
- This file is the animation-state boundary for cursors, while raw image data and context policy stay elsewhere.
- Read it when frame timing, looping semantics, pulse behavior, or animated cursor playback rules need to change.

### config.rs

- `src/cursor/config.rs` owns the shared configuration schema for enabling cursor trail, zoom, rules, and idle hiding.
- It defines `CursorConfig`, keeping top-level cursor feature toggles and idle timeout settings in one small owner.
- Read this file when startup defaults or project-level cursor feature flags need to change for the runtime.

### context.rs

- `src/cursor/context.rs` owns the active runtime cursor controller used by Lua, input, and render glue.
- It defines cursor states, normalized hover hits, rules, sources, effects, and the manager that resolves them.
- Legacy context switching stays supported, but the same owner now also handles hover-driven state changes.
- Rule evaluation here chooses between system, custom, and animated cursors before overlay rendering happens.
- Hover hits from globe, raycaster, or callbacks are normalized here so one resolver can handle every source.
- Burst effects, trail presets, timed overrides, and zoom-lens state all live in this shared cursor owner.
- The manager keeps last-hit metadata and active-state snapshots available to Lua without duplicating policy.
- Input-facing structs in this file translate button, release, and wheel state into cursor-local reactions.
- Open this file when cursor policy, source matching, or per-frame state resolution semantics need to change.
- Open this file when cursor rule resolution, source polling contracts, or overlay-state behavior changes.

### custom_cursor.rs

- `src/cursor/custom_cursor.rs` owns the RGBA image cursor type used for standalone custom pointers and animation frames.
- It defines `CustomCursor`, keeping dimensions, hotspot metadata, and flat pixel storage under one cursor-asset owner.
- Construction, RGBA-buffer validation, pixel mutation, pixel reads, and size queries all live in this file.
- Read it when custom cursor asset shape, hotspot rules, or pixel-buffer behavior for pointer images needs changes.

### mod.rs

- `src/cursor/mod.rs` is the module index that exposes cursor state types, policy managers, and visual cursor effects.
- It reexports system, custom, and animated cursor types plus context, trail, zoom, and config helpers together.
- No active cursor state lives here; this file only declares child modules and defines which cursor symbols are public.
- Read this index when wiring pointer features, because it shows where cursor assets, policy, and effects are separated.
- Changes here reshape the cursor boundary, since reexports decide what runtime code may import without deep paths.
- This module keeps cursor images, context switching, trail effects, and zoom-lens state split by clear ownership.

### system_cursor.rs

- `src/cursor/system_cursor.rs` owns the engine-facing enum of native system cursor shapes and string conversions.
- It defines `SystemCursor`, keeping parseable cursor names and canonical string identifiers under one small owner.
- Config and script name parsing plus stable string export both live here, separate from runtime cursor policy.
- Read this file when supported native cursor variants or string-mapping behavior need to change.

### trail.rs

- `src/cursor/trail.rs` owns cursor trail sampling, retention, and render-facing configuration.
- It keeps the runtime point buffer together with mode, spacing, lifetime, blend, and optional texture/shader data.
- `CursorTrail` stores author-facing knobs for points, lines, ribbons, and stamped cursor decals in one place.
- `TrailPoint` records sampled screen positions plus age so fading and pruning stay deterministic frame to frame.
- The file is the narrow owner for trail spacing rules, width settings, max-point limits, and blend defaults.
- Open this file when cursor trails change shape or lifetime semantics, not when cursor-state policy changes.

### zoom.rs

- `src/cursor/zoom.rs` owns the magnifier lens config used by the shared cursor overlay runtime.
- `CursorZoom` stores magnification, radius, border styling, softness, and an optional shader override.
- The runtime reads this owner when it decides whether to draw a live circular lens over the captured frame.
- Open this file when zoom-lens tuning or persisted cursor magnifier defaults change across integrations.



## Lua API Ref

### Functions

- `lurek.cursor.newAnimated(looping) -> LAnimatedCursor`: Creates an animated cursor that can cycle through custom cursor frames.
- `lurek.cursor.newCustom(w, h, hx, hy) -> LCustomCursor`: Creates a custom RGBA cursor image with an explicit hotspot.
- `lurek.cursor.newManager() -> LCursorManager`: Returns a handle to the shared runtime cursor controller.
- `lurek.cursor.systemCursors() -> table`: Returns the list of system cursor names supported by the cursor module.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LAnimatedCursor Type

- Creates an animated cursor that can cycle through custom cursor frames.

##### Fields

- No documented fields.

##### Methods

- `LAnimatedCursor:addFrame(cursor, duration_ms) -> nil`: Appends one frame to the animated cursor sequence.
- `LAnimatedCursor:clearPulse() -> nil`: Disables pulse scaling for the animated cursor.
- `LAnimatedCursor:currentIndex() -> integer`: Returns the currently active frame index.
- `LAnimatedCursor:currentScale() -> number`: Returns the current pulse scale multiplier.
- `LAnimatedCursor:frameCount() -> integer`: Returns the number of frames stored in this animated cursor.
- `LAnimatedCursor:reset() -> nil`: Resets playback to the first frame and clears accumulated animation time.
- `LAnimatedCursor:setPulse(min_scale, max_scale, speed) -> nil`: Enables pulse scaling for the animated cursor.
- `LAnimatedCursor:update(dt) -> nil`: Advances animated cursor playback and pulse state.

#### LCursorManager Type

- Lua userdata that controls the shared runtime cursor.

##### Fields

- No documented fields.

##### Methods

- `LCursorManager:addRule(context_or_rule, cursor_name?) -> integer?`: Registers a legacy context rule or a v2 runtime rule table for hover, click, release, leave, wheel, or context state resolution.
- `LCursorManager:addSource(source_tbl) -> integer`: Registers a hover source that feeds semantic cursor hits into the shared runtime resolver.
- `LCursorManager:defineEffect(name, spec) -> nil`: Defines a reusable cursor-local burst effect preset for hover or click rules.
- `LCursorManager:defineState(name, spec) -> nil`: Defines a reusable named cursor state for rule-driven runtime selection.
- `LCursorManager:disableTrail() -> nil`: Disables the current cursor trail.
- `LCursorManager:disableZoom() -> nil`: Disables the live cursor zoom lens.
- `LCursorManager:enableLineTrail(r, g, b, width) -> nil`: Enables a simple connected line trail behind the cursor.
- `LCursorManager:enableTrail(r, g, b, lifetime) -> nil`: Enables a simple fading point trail behind the cursor.
- `LCursorManager:enableZoom(mag, radius) -> nil`: Enables the live zoom lens centered on the runtime cursor.
- `LCursorManager:getActiveState() -> table`: Returns the currently resolved cursor state after context, hover, and override rules have been applied.
- `LCursorManager:getContext() -> string`: Returns the current named cursor context.
- `LCursorManager:getLastHit() -> table?`: Returns the most recent semantic hover hit seen by the runtime cursor.
- `LCursorManager:getPosition() -> number`: Returns the current runtime cursor position.
- `LCursorManager:isLocked() -> boolean`: Returns whether the runtime cursor is currently marked as locked.
- `LCursorManager:isVisible() -> boolean`: Returns whether the runtime cursor is currently visible.
- `LCursorManager:removeRule(ctx) -> nil`: Removes a legacy context rule that was registered with the `(context, cursor_name)` shorthand.
- `LCursorManager:removeSource(id) -> boolean`: Removes a previously registered hover source.
- `LCursorManager:setAnimated(cursor) -> nil`: Switches the active runtime cursor to an animated cursor immediately.
- `LCursorManager:setContext(ctx) -> nil`: Sets the named cursor context used by legacy rules and context-sensitive state resolution.
- `LCursorManager:setCustom(cursor) -> nil`: Switches the active runtime cursor to a custom RGBA cursor immediately.
- `LCursorManager:setLocked(locked) -> nil`: Locks or unlocks the runtime cursor according to the active platform policy.
- `LCursorManager:setSystem(name) -> nil`: Switches the active runtime cursor to a named system cursor immediately.
- `LCursorManager:setVisible(visible) -> nil`: Shows or hides the runtime cursor.
- `LCursorManager:type() -> string`: Returns the Lua handle type name for this cursor manager userdata.
- `LCursorManager:update(x, y, dt) -> nil`: Overrides the runtime cursor position and advances cursor-local effects for one frame.

#### LCursorManagerDefineEffectResult Type

- Generated result shape from @field tags.

##### Fields

- `blend` (`string`): Blend mode such as `"alpha"` or `"add"`.
- `button` (`integer`): Optional mouse button filter for click/release triggers.
- `color` (`table`): RGBA color as `{r, g, b, a}` or indexed array values.
- `count` (`integer`): Number of particles spawned per burst. Defaults to `12`.
- `lifetime` (`number`): Particle lifetime in seconds. Defaults to `0.28`.
- `shader` (`LShader`): Optional shader used while drawing the effect.
- `shape` (`string`): Particle shape name such as `"spark"`, `"ring"`, or `"circle"`.
- `size` (`number`): Particle size in pixels. Defaults to `5`.
- `speed` (`number`): Initial particle speed in pixels per second. Defaults to `96`.
- `spread` (`number`): Emission arc in radians. Defaults to a full circle.
- `texture` (`LImage`): integer | Optional texture source for stamped particles.

##### Methods

- No documented methods.

#### LCursorManagerDefineStateResult Type

- Generated result shape from @field tags.

##### Fields

- `animated` (`LAnimatedCursor`): Animated cursor handle when this state uses frame-based cursor playback.
- `custom` (`LCustomCursor`): Custom cursor handle when this state uses a pixel cursor.
- `native_preferred` (`boolean`): True to keep the OS cursor when possible. Defaults to `true`.
- `offset_x` (`number`): Horizontal draw offset in pixels. Defaults to `0`.
- `offset_y` (`number`): Vertical draw offset in pixels. Defaults to `0`.
- `scale` (`number`): Overlay scale multiplier. Defaults to `1.0`.
- `system` (`string`): System cursor name when this state uses a native cursor.
- `trail` (`table`): Optional trail configuration with `mode`, `color`, `lifetime`, `spacing`, `width`, `max_points`, `texture`, `shader`, and `blend`.
- `zoom` (`table`): Optional zoom-lens configuration with `magnification`, `radius`, `border_color`, `border_width`, `softness`, and `shader`.

##### Methods

- No documented methods.

#### LCursorManagerGetActiveStateResult Type

- Generated result shape from @field tags.

##### Fields

- `kind` (`string`): Active state kind such as `"system"`, `"custom"`, or `"animated"`.
- `name` (`string`): Optional named state key when the resolved state came from `defineState`.
- `native_preferred` (`boolean`): Whether the runtime prefers leaving the OS cursor visible for this state.
- `offset_x` (`number`): Horizontal draw offset in pixels.
- `offset_y` (`number`): Vertical draw offset in pixels.
- `scale` (`number`): Overlay scale multiplier for the resolved state.

##### Methods

- No documented methods.

#### LCursorManagerGetLastHitResult Type

- Generated result shape from @field tags.

##### Fields

- `attrs` (`table`): String map of semantic attributes used by rules and integrations.
- `context` (`string`): Optional source-provided context name.
- `id` (`string`): Optional object identifier.
- `kind` (`string`): Hit kind such as `"marker"`, `"wall"`, `"sprite"`, or a source-specific label.
- `module` (`string`): Source module name such as `"globe"` or `"raycaster"`.
- `surface` (`string`): Surface label such as `"surface"`, `"wall"`, `"floor"`, or `"ceiling"`.

##### Methods

- No documented methods.

#### LCustomCursor Type

- Creates a custom RGBA cursor image with an explicit hotspot.

##### Fields

- No documented fields.

##### Methods

- `LCustomCursor:getHotspot() -> integer`: Returns the hotspot used when positioning this custom cursor.
- `LCustomCursor:getPixel(x, y) -> integer`: Reads one RGBA pixel from the custom cursor image.
- `LCustomCursor:getSize() -> integer`: Returns the custom cursor image size.
- `LCustomCursor:setPixel(x, y, r, g, b, a) -> nil`: Writes one RGBA pixel into the custom cursor image.

## Examples

- `content/examples/cursor.lua` (present)

## Architecture Links

- Intentionally empty.

## Notes

- `lurek.cursor.newManager()` now returns a handle to the shared runtime cursor. Multiple Lua handles intentionally operate on the same active pointer state.
- `LCursorManager:defineState(name, spec)` is the high-level state registry. A state can select a system cursor or a custom/animated overlay cursor and optionally bundle trail or zoom behavior with that state.
- `LCursorManager:defineEffect(name, spec)` stores reusable hover or click burst presets, while `LCursorManager:addRule({...})` resolves context, hover target, click, release, or wheel events into states and effects with priorities.
- `LCursorManager:addSource(source)` is the semantic hover input side of the system. `globe`, `raycaster_last`, and callback sources all normalize into the same hit payload: `module`, `kind`, `surface`, `id`, `attrs`, `context`.
- Overlay rendering is now a runtime decision. Pure system-cursor states prefer the native OS cursor, while custom cursors, animated cursors, trails, bursts, and zoom lens behavior render through the engine overlay pass.
- Trail modes now cover point, line, ribbon, and stamp-style behavior. Zoom is a live lens effect intended for precision work and game-like inspection instead of a CPU screenshot readback path.
