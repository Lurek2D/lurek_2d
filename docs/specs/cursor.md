# cursor

## TL;DR

- Manages contextual custom cursors, motion trails, and magnifiers.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/cursor/`
- Binding: `src/lua_api/cursor_api.rs`
- Namespace: `lurek.cursor`
- Lua API surface: `4` functions, `3` types, `30` methods
- Rust test path(s): tests/rust/unit/cursor_tests.rs
- Lua test path(s): tests/lua/unit/test_cursor_unit.lua

## Summary

- The `cursor` module is the pointer-behavior surface for users who want the cursor to feel like part of the game UX rather than a fixed OS artifact.
- System cursors, custom RGBA cursors, animated states, and context-driven switching work together so interaction modes can communicate themselves visually without extra UI explanation.
- Trail effects, zoom-lens support, locking, visibility control, and mode-aware switching extend the same module into readability, precision work, and tool-oriented pointer behavior.
- That makes the module especially useful for menus, editors, strategy controls, drag-and-drop flows, and inspection-heavy screens where the cursor is a major part of the interaction language.
- Read `cursor` as the owner of cursor presentation and cursor-state policy. Other systems decide which interaction mode is active, but `cursor` decides how that mode is expressed to the user.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

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

- `src/cursor/context.rs` owns context-sensitive cursor selection plus the manager that combines cursor, trail, and zoom.
- It defines `CursorState`, `CursorContext`, `ContextRule`, and `CursorManager`, keeping cursor policy state together.
- Rule registration, context switching, visibility, locking, active-position tracking, and animated updates live here.
- Trail and zoom attachment also live here, making this file the owner of composed runtime cursor presentation state.
- This is the policy boundary for script-driven cursor changes; image buffers and effect internals stay in sibling files.
- Read it when context mapping, active-state transitions, or cursor-manager behavior needs to change.

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

- `src/cursor/trail.rs` owns the trailing cursor effect that stores fading points and optional line-style behavior.
- It defines `TrailPoint`, `TrailMode`, and `CursorTrail`, keeping sample storage and trail configuration together.
- Point aging, minimum-distance sampling, lifetime expiry, mode switching, and bounded history management live here.
- This file is the owner of trail-effect state, while manager-level attachment and cursor rules stay elsewhere.
- Read it when trail sampling, point retention, fade lifetime, or trail mode behavior needs to change.

### zoom.rs

- `src/cursor/zoom.rs` owns the magnifier-lens state used to zoom content around the active cursor position.
- It defines `CursorZoom`, keeping enable state, magnification, radius, and border styling in one owner.
- Magnification updates, radius clamping, and simple enable toggling all live here under one small feature contract.
- Read this file when cursor zoom limits, default lens styling, or toggle behavior for the magnifier feature changes.



## Lua API Ref

### Functions

- `lurek.cursor.newAnimated(looping) -> LAnimatedCursor`: Creates a new animated cursor that can cycle through frames.
- `lurek.cursor.newCustom(w, h, hx, hy) -> LCustomCursor`: Creates a new custom cursor with specified dimensions and hotspot position.
- `lurek.cursor.newManager() -> LCursorManager`: Creates a new cursor manager for handling cursor state and visibility.
- `lurek.cursor.systemCursors() -> table`: Returns a list of all available system cursor names as a string array.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LAnimatedCursor Type

- Lua userdata representing an animated cursor that cycles through image frames.

##### Fields

- No documented fields.

##### Methods

- `LAnimatedCursor:addFrame(cursor, duration_ms) -> nil`: Add a frame from a custom cursor image.
- `LAnimatedCursor:clearPulse() -> nil`: Disable pulse animation for this object.
- `LAnimatedCursor:currentIndex() -> integer`: Get current frame index for this object.
- `LAnimatedCursor:currentScale() -> number`: Get current scale from pulse animation.
- `LAnimatedCursor:frameCount() -> integer`: Get total frame count for this object.
- `LAnimatedCursor:reset() -> nil`: Reset the cursor animation playback to the first frame.
- `LAnimatedCursor:setPulse(min_scale, max_scale, speed) -> nil`: Set the pulse animation speed and scale factor parameters.
- `LAnimatedCursor:update(dt) -> nil`: Update animation (call each frame).

#### LCursorManager Type

- Lua userdata that controls cursor appearance and system cursor selection.

##### Fields

- No documented fields.

##### Methods

- `LCursorManager:addRule(ctx, cursor_name) -> nil`: Add a context rule that maps a context to a system cursor.
- `LCursorManager:disableTrail() -> nil`: Disable cursor trail for this object.
- `LCursorManager:disableZoom() -> nil`: Disable cursor zoom for this object.
- `LCursorManager:enableLineTrail(r, g, b, width) -> nil`: Enable cursor trail with line mode.
- `LCursorManager:enableTrail(r, g, b, lifetime) -> nil`: Enable cursor trail with fade points mode.
- `LCursorManager:enableZoom(magnification, radius) -> nil`: Enable zoom/magnifier at cursor position.
- `LCursorManager:getContext() -> string`: Get current context name for this object.
- `LCursorManager:getPosition() -> number`: Get cursor position for this object.
- `LCursorManager:isLocked() -> boolean`: Get cursor lock state for this object.
- `LCursorManager:isVisible() -> boolean`: Get cursor visibility for this object.
- `LCursorManager:removeRule(ctx) -> nil`: Remove a context rule for this object.
- `LCursorManager:setAnimated(cursor) -> nil`: Set the active cursor to an animated cursor.
- `LCursorManager:setContext(ctx) -> nil`: Set the current context for context-sensitive switching.
- `LCursorManager:setCustom(cursor) -> nil`: Set the active cursor to a custom image cursor.
- `LCursorManager:setLocked(locked) -> nil`: Lock the cursor position using the system grab mode.
- `LCursorManager:setSystem(name) -> nil`: Set the active cursor to a system cursor by name.
- `LCursorManager:setVisible(visible) -> nil`: Set cursor visibility for this object.
- `LCursorManager:update(x, y, dt) -> nil`: Update cursor state (call each frame).

#### LCustomCursor Type

- Lua userdata representing a custom-drawn cursor image with a configurable hot-spot.

##### Fields

- No documented fields.

##### Methods

- `LCustomCursor:getHotspot() -> integer`: Get hotspot position for this object.
- `LCustomCursor:getPixel(x, y) -> integer`: Get the pixel color at the specified cursor image position.
- `LCustomCursor:getSize() -> integer`: Get the pixel width and height of the cursor image.
- `LCustomCursor:setPixel(x, y, r, g, b, a) -> nil`: Set a pixel color â€” Lua userdata object exposed by the engine.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- No additional module-specific notes.
