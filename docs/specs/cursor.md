# cursor

## TL;DR

- The `cursor` module manages OS cursor state, custom image cursors, animated frame sequences, context-sensitive switching, visual trail effects, and a magnifying zoom lens for Lurek2D games.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/cursor/`
- Lua API path(s): `src/lua_api/cursor_api.rs`
- Primary Lua namespace: `lurek.cursor`
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

The `cursor` module provides complete cursor lifecycle management for Lurek2D games. At its foundation, the `CursorManager` centralizes all cursor state: it can display native OS system cursors (arrow, crosshair, hand, IBeam, and resize variants), custom RGBA image cursors with configurable hotspot offsets, or smooth animated frame sequences built from `AnimatedCursor`. Each animated cursor supports per-frame durations and an independent sine-driven `PulseConfig` scale animation, creating subtle breathing or emphasis effects without additional scripting.

Context-sensitive switching is a first-class feature. Developers register `ContextRule` mappings from named string contexts (e.g., `"dialog"`, `"combat"`, `"menu"`) to specific cursor states. Activating a context via `setContext` instantly swaps to the registered cursor, allowing the cursor to always reflect the current game interaction mode without polling game state from the rendering layer.

The module also provides two post-process visual effects layered on top of the hardware cursor. The `CursorTrail` records a ring buffer of recent cursor positions (`TrailPoint`), each with linearly decaying alpha, and renders them in one of three modes: fading dots, connected line segments, or particle clusters. The `CursorZoom` lens composites a configurable magnifying glass (1.1× to 8.0×) around the cursor position as a post-process scissored blit, useful for map editors or accessibility features. All cursor behavior — visibility, hardware lock for FPS-style grabs, trail, zoom, and context rules — is fully accessible via the `lurek.cursor.*` Lua API.

## Source Documentation

### `animated_cursor.rs`
- Animated cursor: frame sequences with per-frame timing and pulse scale effects.
- `AnimatedCursor` holds a `Vec<CustomCursor>` of frames and an index.
- `PulseConfig` drives a sine-based scale animation independent of frame advance.
- Frame advance is time-driven; `duration_ms` per frame is set at construction.
- Used by `CursorState::Animated` and updated each tick in the cursor manager.

### `config.rs`
- Global cursor system configuration shared across the cursor manager.
- `CursorConfig` is deserialized from the game TOML config section `[cursor]`.
- Controls trail, zoom, context rules, idle-hide timeout, and default kind.
- All fields have safe defaults; the entire struct is optional in the config file.
- Loaded once at engine startup; changes require a restart.

### `context.rs`
- Context-sensitive cursor switching: maps named contexts to cursor states.
- `CursorContext` holds a registry of context-name → `CursorState` mappings.
- `CursorState` discriminates between system, custom, and animated cursor kinds.
- Context names are arbitrary strings set by game scripts (e.g. `"dialog"`, `"combat"`).
- The active context is applied immediately; fallback is the default system cursor.

### `custom_cursor.rs`
- Custom image cursor built from RGBA pixel data with configurable hotspot offset.
- `CustomCursor` stores width, height, hotspot `(x, y)`, and a flat RGBA `Vec<u8>`.
- Pixel data is validated at construction; mismatched dimensions return an error.
- Used directly or as frames inside `AnimatedCursor`.
- Exposed to Lua scripts via `lurek.cursor.set_custom()`.

### `mod.rs`
- Cursor management system.
- System cursors (arrow, crosshair, hand, etc.).
- Custom image cursors with hotspot.
- Animated cursors with frame sequences and pulsing.
- Cursor trails (fade points, particles, lines).
- Context-sensitive cursor switching.
- Zoom/magnifier at cursor position.

### `system_cursor.rs`
- System cursor shapes available on all desktop platforms.
- `SystemCursor` enumerates arrow, hand, crosshair, ibeam, wait, and resize variants.
- Maps directly to `winit::window::CursorIcon` at the platform integration layer.
- Parsing from string (used by config deserialization) is case-insensitive.
- Exposed to Lua via `lurek.cursor.set_system(name)`.

### `trail.rs`
- Cursor trail effects: fading dot trails, connected line trails, and particle modes.
- `TrailPoint` records position, timestamp, and current alpha for each trail node.
- `TrailState` holds a ring buffer of `TrailPoint`s capped at `max_points`.
- `TrailMode` selects: `Dots`, `Line`, `Particles` — each rendered differently.
- Trail alpha decays linearly; the oldest points are culled when the buffer is full.
- Updated each tick from the cursor manager; rendered in the overlay pass.

### `zoom.rs`
- Cursor magnifier lens: a configurable zoom window that follows the cursor.
- `ZoomConfig` sets lens radius, magnification factor, and optional border style.
- The lens is rendered as a post-process scissored blit after the main render pass.
- Magnification clamps between 1.1× and 8.0× to avoid pixel smear at extremes.
- Enabled/disabled via `lurek.cursor.set_zoom(config)` or the `[cursor]` TOML block.

## Types

- `PulseConfig` (`struct`, `animated_cursor.rs`): Configuration for pulsing scale animation.
- `CursorFrame` (`struct`, `animated_cursor.rs`): A single frame in an animated cursor.
- `AnimatedCursor` (`struct`, `animated_cursor.rs`): An animated cursor cycling through frames.
- `CursorConfig` (`struct`, `config.rs`): Global cursor system configuration.
- `CursorState` (`enum`, `context.rs`): Active cursor state: the currently displayed cursor kind (system, custom, or animated).
- `CursorContext` (`enum`, `context.rs`): Context that determines which cursor to show.
- `ContextRule` (`struct`, `context.rs`): Rule mapping a context to a cursor state.
- `CursorManager` (`struct`, `context.rs`): Manages cursor state, context rules, trail, and zoom.
- `CustomCursor` (`struct`, `custom_cursor.rs`): A custom cursor from RGBA pixel data.
- `SystemCursor` (`enum`, `system_cursor.rs`): System cursor shapes available on all platforms.
- `TrailPoint` (`struct`, `trail.rs`): A single point in the cursor trail.
- `TrailMode` (`enum`, `trail.rs`): Trail rendering mode: controls how trail points are drawn behind the cursor.
- `CursorTrail` (`struct`, `trail.rs`): Manages a trail of points behind the cursor.
- `CursorZoom` (`struct`, `zoom.rs`): Cursor zoom/magnifier configuration.

## Functions

- `AnimatedCursor::new` (`animated_cursor.rs`): Create a new animated cursor; `looping` controls whether playback wraps.
- `AnimatedCursor::add_frame` (`animated_cursor.rs`): Add a frame to the animation with the given display duration in milliseconds.
- `AnimatedCursor::update` (`animated_cursor.rs`): Advance the animation by `dt` seconds, updating the current frame and pulse phase.
- `AnimatedCursor::current_frame` (`animated_cursor.rs`): Return the currently displayed frame, or `None` if there are no frames.
- `AnimatedCursor::current_scale` (`animated_cursor.rs`): Return the current scale multiplier driven by the pulse animation (1.0 when no pulse).
- `AnimatedCursor::set_pulse` (`animated_cursor.rs`): Configure or clear the pulse scale animation applied on top of frame playback.
- `AnimatedCursor::reset` (`animated_cursor.rs`): Reset playback to frame 0 and clear timer and pulse phase.
- `AnimatedCursor::frame_count` (`animated_cursor.rs`): Return the total number of frames in the animation.
- `AnimatedCursor::current_index` (`animated_cursor.rs`): Return the zero-based index of the currently active frame.
- `AnimatedCursor::is_looping` (`animated_cursor.rs`): Return `true` if the animation restarts from frame 0 after the last frame.
- `CursorContext::from_name` (`context.rs`): Parse a `CursorContext` variant from a lowercase string name.
- `CursorContext::as_str` (`context.rs`): Return the canonical string representation of this context.
- `CursorManager::new` (`context.rs`): Create a new `CursorManager` with default system arrow cursor and no rules.
- `CursorManager::set_system` (`context.rs`): Switch the active cursor to an OS system cursor shape.
- `CursorManager::set_custom` (`context.rs`): Switch the active cursor to a custom RGBA image cursor.
- `CursorManager::set_animated` (`context.rs`): Switch the active cursor to an animated frame cursor.
- `CursorManager::set_context` (`context.rs`): Activate the named context, applying its registered cursor rule if one exists.
- `CursorManager::add_rule` (`context.rs`): Register a context-to-cursor rule; replaces any existing rule for the same context.
- `CursorManager::remove_rule` (`context.rs`): Remove the rule associated with the given context, if any.
- `CursorManager::update` (`context.rs`): Tick cursor state: record the new screen position, advance animated frames, and update the trail.
- `CursorManager::set_trail` (`context.rs`): Attach or clear the cursor trail effect.
- `CursorManager::trail` (`context.rs`): Return a shared reference to the cursor trail, if one is attached.
- `CursorManager::trail_mut` (`context.rs`): Return a mutable reference to the cursor trail, if one is attached.
- `CursorManager::set_zoom` (`context.rs`): Attach or clear the magnifying zoom lens overlay.
- `CursorManager::zoom` (`context.rs`): Return a shared reference to the zoom lens, if one is attached.
- `CursorManager::set_visible` (`context.rs`): Show or hide the hardware cursor.
- `CursorManager::is_visible` (`context.rs`): Return `true` if the cursor is currently visible.
- `CursorManager::set_locked` (`context.rs`): Lock or unlock the cursor to the window center (e.g., for FPS-style camera).
- `CursorManager::is_locked` (`context.rs`): Return `true` if the cursor is locked to the window center.
- `CursorManager::active` (`context.rs`): Return the currently active cursor state.
- `CursorManager::position` (`context.rs`): Return the current cursor screen position as `(x, y)` in pixels.
- `CursorManager::context` (`context.rs`): Return the active `CursorContext` that determines the current cursor appearance.
- `CustomCursor::new` (`custom_cursor.rs`): Create a blank (all-zero) custom cursor with the given dimensions and hotspot.
- `CustomCursor::from_rgba` (`custom_cursor.rs`): Create a cursor from raw RGBA byte data; returns `None` if `data.len()` does not match dimensions.
- `CustomCursor::set_pixel` (`custom_cursor.rs`): Set the RGBA value of the pixel at `(x, y)`; out-of-bounds writes are silently ignored.
- `CustomCursor::get_pixel` (`custom_cursor.rs`): Return the RGBA value at `(x, y)`, or `None` if the coordinates are out of bounds.
- `CustomCursor::pixels` (`custom_cursor.rs`): Return the full flat RGBA pixel buffer (width × height × 4 bytes).
- `CustomCursor::size` (`custom_cursor.rs`): Return the cursor image dimensions as `(width, height)` in pixels.
- `SystemCursor::from_name` (`system_cursor.rs`): Parse a `SystemCursor` variant from a string name; returns `None` for unknown names.
- `SystemCursor::as_str` (`system_cursor.rs`): Return the canonical OS string identifier for this cursor shape.
- `CursorTrail::new` (`trail.rs`): Create a new cursor trail with the given render mode and default settings.
- `CursorTrail::update` (`trail.rs`): Tick the trail: age existing points, remove expired ones, and append a new point if the cursor moved far enough.
- `CursorTrail::get_points` (`trail.rs`): Return the ordered deque of current trail points.
- `CursorTrail::clear` (`trail.rs`): Immediately remove all stored trail points.
- `CursorTrail::set_active` (`trail.rs`): Enable or disable trail recording; disabling also clears all existing points.
- `CursorTrail::is_active` (`trail.rs`): Return `true` if the trail is currently recording cursor positions.
- `CursorTrail::mode` (`trail.rs`): Return the current trail render mode.
- `CursorTrail::set_mode` (`trail.rs`): Change the trail render mode and clear existing points.
- `CursorTrail::set_max_points` (`trail.rs`): Set the maximum number of stored trail points, evicting oldest if already over the limit.
- `CursorZoom::new` (`zoom.rs`): Create a zoom lens with the given magnification factor and lens radius in pixels.
- `CursorZoom::set_magnification` (`zoom.rs`): Set the magnification factor, clamped to `[1.0, 10.0]`.
- `CursorZoom::set_radius` (`zoom.rs`): Set the zoom lens radius in pixels; minimum enforced to 8 pixels.
- `CursorZoom::toggle` (`zoom.rs`): Toggle the zoom lens between enabled and disabled.

## Lua API Reference

- Binding path(s): `src/lua_api/cursor_api.rs`
- Namespace: `lurek.cursor`

### Module Functions
- `lurek.cursor.newManager`: Creates a new cursor manager for handling cursor state and visibility.
- `lurek.cursor.newCustom`: Creates a new custom cursor with specified dimensions and hotspot position.
- `lurek.cursor.newAnimated`: Creates a new animated cursor that can cycle through frames.
- `lurek.cursor.systemCursors`: Returns a list of all available system cursor names as a string array.

### `LAnimatedCursor` Methods
- `LAnimatedCursor:addFrame`: Add a frame from a custom cursor image.
- `LAnimatedCursor:update`: Update animation (call each frame).
- `LAnimatedCursor:currentIndex`: Get current frame index for this object.
- `LAnimatedCursor:frameCount`: Get total frame count for this object.
- `LAnimatedCursor:currentScale`: Get current scale from pulse animation.
- `LAnimatedCursor:setPulse`: Set the pulse animation speed and scale factor parameters.
- `LAnimatedCursor:clearPulse`: Disable pulse animation for this object.
- `LAnimatedCursor:reset`: Reset the cursor animation playback to the first frame.

### `LCursorManager` Methods
- `LCursorManager:setSystem`: Set the active cursor to a system cursor by name.
- `LCursorManager:setCustom`: Set the active cursor to a custom image cursor.
- `LCursorManager:setAnimated`: Set the active cursor to an animated cursor.
- `LCursorManager:setContext`: Set the current context for context-sensitive switching.
- `LCursorManager:addRule`: Add a context rule that maps a context to a system cursor.
- `LCursorManager:removeRule`: Remove a context rule for this object.
- `LCursorManager:update`: Update cursor state (call each frame).
- `LCursorManager:setVisible`: Set cursor visibility for this object.
- `LCursorManager:isVisible`: Get cursor visibility for this object.
- `LCursorManager:setLocked`: Lock the cursor position using the system grab mode.
- `LCursorManager:isLocked`: Get cursor lock state for this object.
- `LCursorManager:getPosition`: Get cursor position for this object.
- `LCursorManager:getContext`: Get current context name for this object.
- `LCursorManager:enableTrail`: Enable cursor trail with fade points mode.
- `LCursorManager:enableLineTrail`: Enable cursor trail with line mode.
- `LCursorManager:disableTrail`: Disable cursor trail for this object.
- `LCursorManager:enableZoom`: Enable zoom/magnifier at cursor position.
- `LCursorManager:disableZoom`: Disable cursor zoom for this object.

### `LCustomCursor` Methods
- `LCustomCursor:setPixel`: Set a pixel color — Lua userdata object exposed by the engine.
- `LCustomCursor:getPixel`: Get the pixel color at the specified cursor image position.
- `LCustomCursor:getSize`: Get the pixel width and height of the cursor image.
- `LCustomCursor:getHotspot`: Get hotspot position for this object.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- Keep this module reference synchronized with `src/cursor/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
