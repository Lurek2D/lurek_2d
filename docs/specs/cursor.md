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

The `cursor` module owns cursor presentation and behavior policy, including system cursor selection, custom image cursors, animated cursor sequences, context-based switching, trail effects, and cursor magnifier support. It provides a single stateful surface for cursor concerns instead of scattering cursor logic across input and UI code.

Submodules map directly to feature domains: `system_cursor` for native cursor kinds, `custom_cursor` for image/hotspot management, `animated_cursor` for timed frame cycling and pulse behavior, `context` for dynamic mode switching, `trail` for visual trails, and `zoom` for cursor-centered magnification.

The design keeps input capture and cursor rendering conceptually separate. Input modules report state; cursor modules decide representation and visual behavior. This improves maintainability when adding context-sensitive visuals or accessibility-oriented cursor modes.

In practice, cursor behavior should remain deterministic and low-latency, with clear fallback paths between native/system cursors and custom/animated variants.

Implementation detail and boundary guarantees for cursor: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: animated_cursor.rs: Animated cursor: frame sequences with per-frame timing and pulse scale effects.; config.rs: Global cursor system configuration shared across the cursor manager.; context.rs: Context-sensitive cursor switching: maps named contexts to cursor states.; custom_cursor.rs: Custom image cursor built from RGBA pixel data with configurable hotspot offset.; mod.rs: Cursor management system.; system_cursor.rs: System cursor shapes available on all desktop platforms.; trail.rs: Cursor trail effects: fading dot trails, connected line trails, and particle modes.; zoom.rs: Cursor magnifier lens: a configurable zoom window that follows the cursor.. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

## Files

### animated_cursor.rs

- Animated cursor: frame sequences with per-frame timing and pulse scale effects.
- `AnimatedCursor` holds a `Vec<CustomCursor>` of frames and an index.
- `PulseConfig` drives a sine-based scale animation independent of frame advance.
- Frame advance is time-driven; `duration_ms` per frame is set at construction.
- Used by `CursorState::Animated` and updated each tick in the cursor manager.

### config.rs

- Global cursor system configuration shared across the cursor manager.
- `CursorConfig` is deserialized from the game TOML config section `[cursor]`.
- Controls trail, zoom, context rules, idle-hide timeout, and default kind.
- All fields have safe defaults; the entire struct is optional in the config file.
- Loaded once at engine startup; changes require a restart.

### context.rs

- Context-sensitive cursor switching: maps named contexts to cursor states.
- `CursorContext` holds a registry of context-name → `CursorState` mappings.
- `CursorState` discriminates between system, custom, and animated cursor kinds.
- Context names are arbitrary strings set by game scripts (e.g. `"dialog"`, `"combat"`).
- The active context is applied immediately; fallback is the default system cursor.

### custom_cursor.rs

- Custom image cursor built from RGBA pixel data with configurable hotspot offset.
- `CustomCursor` stores width, height, hotspot `(x, y)`, and a flat RGBA `Vec<u8>`.
- Pixel data is validated at construction; mismatched dimensions return an error.
- Used directly or as frames inside `AnimatedCursor`.
- Exposed to Lua scripts via `lurek.cursor.set_custom()`.

### mod.rs

- Cursor management system.
- System cursors (arrow, crosshair, hand, etc.).
- Custom image cursors with hotspot.
- Animated cursors with frame sequences and pulsing.
- Cursor trails (fade points, particles, lines).
- Context-sensitive cursor switching.
- Zoom/magnifier at cursor position.

### system_cursor.rs

- System cursor shapes available on all desktop platforms.
- `SystemCursor` enumerates arrow, hand, crosshair, ibeam, wait, and resize variants.
- Maps directly to `winit::window::CursorIcon` at the platform integration layer.
- Parsing from string (used by config deserialization) is case-insensitive.
- Exposed to Lua via `lurek.cursor.set_system(name)`.

### trail.rs

- Cursor trail effects: fading dot trails, connected line trails, and particle modes.
- `TrailPoint` records position, timestamp, and current alpha for each trail node.
- `TrailState` holds a ring buffer of `TrailPoint`s capped at `max_points`.
- `TrailMode` selects: `Dots`, `Line`, `Particles` — each rendered differently.
- Trail alpha decays linearly; the oldest points are culled when the buffer is full.
- Updated each tick from the cursor manager; rendered in the overlay pass.

### zoom.rs

- Cursor magnifier lens: a configurable zoom window that follows the cursor.
- `ZoomConfig` sets lens radius, magnification factor, and optional border style.
- The lens is rendered as a post-process scissored blit after the main render pass.
- Magnification clamps between 1.1× and 8.0× to avoid pixel smear at extremes.
- Enabled/disabled via `lurek.cursor.set_zoom(config)` or the `[cursor]` TOML block.

## Lua API Ref

- Binding: `src/lua_api/cursor_api.rs`
- Namespace: `lurek.cursor`

### Functions

- `lurek.cursor.newAnimated`: Creates a new animated cursor that can cycle through frames.
- `lurek.cursor.newCustom`: Creates a new custom cursor with specified dimensions and hotspot position.
- `lurek.cursor.newManager`: Creates a new cursor manager for handling cursor state and visibility.
- `lurek.cursor.systemCursors`: Returns a list of all available system cursor names as a string array.

### Enums

- No documented module-level enums/constants.

### Types


#### LAnimatedCursor Type


##### Fields

- No documented fields.

##### Methods

- `LAnimatedCursor:addFrame`: Add a frame from a custom cursor image.
- `LAnimatedCursor:clearPulse`: Disable pulse animation for this object.
- `LAnimatedCursor:currentIndex`: Get current frame index for this object.
- `LAnimatedCursor:currentScale`: Get current scale from pulse animation.
- `LAnimatedCursor:frameCount`: Get total frame count for this object.
- `LAnimatedCursor:reset`: Reset the cursor animation playback to the first frame.
- `LAnimatedCursor:setPulse`: Set the pulse animation speed and scale factor parameters.
- `LAnimatedCursor:update`: Update animation (call each frame).


#### LCursorManager Type


##### Fields

- No documented fields.

##### Methods

- `LCursorManager:addRule`: Add a context rule that maps a context to a system cursor.
- `LCursorManager:disableTrail`: Disable cursor trail for this object.
- `LCursorManager:disableZoom`: Disable cursor zoom for this object.
- `LCursorManager:enableLineTrail`: Enable cursor trail with line mode.
- `LCursorManager:enableTrail`: Enable cursor trail with fade points mode.
- `LCursorManager:enableZoom`: Enable zoom/magnifier at cursor position.
- `LCursorManager:getContext`: Get current context name for this object.
- `LCursorManager:getPosition`: Get cursor position for this object.
- `LCursorManager:isLocked`: Get cursor lock state for this object.
- `LCursorManager:isVisible`: Get cursor visibility for this object.
- `LCursorManager:removeRule`: Remove a context rule for this object.
- `LCursorManager:setAnimated`: Set the active cursor to an animated cursor.
- `LCursorManager:setContext`: Set the current context for context-sensitive switching.
- `LCursorManager:setCustom`: Set the active cursor to a custom image cursor.
- `LCursorManager:setLocked`: Lock the cursor position using the system grab mode.
- `LCursorManager:setSystem`: Set the active cursor to a system cursor by name.
- `LCursorManager:setVisible`: Set cursor visibility for this object.
- `LCursorManager:update`: Update cursor state (call each frame).


#### LCustomCursor Type


##### Fields

- No documented fields.

##### Methods

- `LCustomCursor:getHotspot`: Get hotspot position for this object.
- `LCustomCursor:getPixel`: Get the pixel color at the specified cursor image position.
- `LCustomCursor:getSize`: Get the pixel width and height of the cursor image.
- `LCustomCursor:setPixel`: Set a pixel color — Lua userdata object exposed by the engine.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.
