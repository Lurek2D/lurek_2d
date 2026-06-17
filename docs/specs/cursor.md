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

- Lets users shape pointer behavior as part of UX, not just rely on default OS cursor visuals.
- Supports switching between native system cursors and fully custom pixel cursors per context.
- Enables animated cursor states for interactive menus, crafting, drag-drop, and tool modes.
- Provides rule-based context mapping so cursor style follows current game interaction state.
- Adds trail effects that improve motion readability and perceived responsiveness.
- Includes cursor-follow zoom for precision interactions and accessibility-friendly inspection.
- Exposes lock and visibility controls for gameplay modes that need constrained pointer behavior.
- Gives UI-heavy projects a consistent pointer presentation layer across features.
- Helps teams build cursor feedback that is both functional and stylistically aligned with the game.
- Centralizes cursor logic so interaction polish does not fragment across unrelated scripts.
- Serves as the module for delivering intentional, state-aware pointer UX in-engine.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### animated_cursor.rs

- Implements animated cursor state using frame sequences and time-based frame advancement. `cursor/animated_cursor` delivers the animated cursor implementation for the cursor subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Supports optional pulse scaling driven by oscillation parameters independent of frame stepping. The file owns or coordinates data contracts including `PulseConfig`, `CursorFrame`, `AnimatedCursor`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Maintains deterministic timing behavior through per-frame duration tracking. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `add_frame`, `update`, `current_frame`, `current_scale`, `set_pulse`, and 4 more stays attached to the local data model and invariants.
- Integrates as an active cursor-state variant within context-aware cursor orchestration. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### config.rs

- Defines cursor-system configuration values loaded from project settings and startup defaults. `cursor/config` delivers the configuration schema and defaults for the cursor subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

### context.rs

- Implements context-sensitive cursor switching by mapping named runtime contexts to cursor states. `cursor/context` delivers the context implementation for the cursor subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Supports system, custom, and animated cursor variants under one discriminated state model. The file owns or coordinates data contracts including `CursorState`, `CursorContext`, `ContextRule`, `CursorManager`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Applies context changes immediately while preserving a deterministic default fallback path. Public callable behavior is centered on no named public items, while method-level behavior such as `from_name`, `as_str`, `new`, `set_system`, `set_custom`, `set_animated`, and 16 more stays attached to the local data model and invariants.
- Integrates optional trail and zoom behavior into active cursor presentation state. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Serves as the policy layer for script-driven cursor-mode transitions. External integration uses `super`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### custom_cursor.rs

- Implements custom cursor images built from RGBA pixel buffers and hotspot metadata. `cursor/custom_cursor` delivers the custom cursor implementation for the cursor subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Validates buffer dimensions at construction to prevent malformed cursor payload usage. The file owns or coordinates data contracts including `CustomCursor`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports standalone custom cursors and animated-frame reuse through shared image structure. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `from_rgba`, `set_pixel`, `get_pixel`, `pixels`, `size` stays attached to the local data model and invariants.
- Serves as the pixel-defined cursor asset contract for script-driven cursor customization. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### mod.rs

- Defines the cursor module boundary for system, custom, animated, contextual, and effect-driven cursor behavior. `cursor/mod` is the cursor module index, declaring `animated_cursor`, `config`, `context`, `custom_cursor`, `system_cursor`, and 2 more so agents can identify which files own each feature slice before opening implementation code.
- Groups cursor state types, visual effects, and configuration contracts into one cohesive runtime surface. `src/cursor/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `animated_cursor::{AnimatedCursor, PulseConfig}`, `config::CursorConfig`, `context::{CursorContext, CursorManager}`, `custom_cursor::CustomCursor`, and 3 more centralized for the cursor subsystem.

### system_cursor.rs

- Defines cross-platform system cursor shape variants used by runtime cursor state. `cursor/system_cursor` delivers the system cursor implementation for the cursor subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Maps engine-facing cursor variants to platform-native icon representations. The file owns or coordinates data contracts including `SystemCursor`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports case-insensitive string parsing for config and script-driven selection. Public callable behavior is centered on no named public items, while method-level behavior such as `from_name`, `as_str` stays attached to the local data model and invariants.

### trail.rs

- Implements cursor-trail effects with fading points, connected strokes, and particle-style variants. `cursor/trail` delivers the trail implementation for the cursor subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Tracks trail samples as timestamped points with alpha decay progression over update ticks. The file owns or coordinates data contracts including `TrailPoint`, `TrailMode`, `CursorTrail`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Maintains bounded point history through capped storage to control runtime memory pressure. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `update`, `get_points`, `clear`, `set_active`, `is_active`, and 3 more stays attached to the local data model and invariants.
- Supports multiple trail render modes selected by explicit trail behavior configuration. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### zoom.rs

- Implements cursor-following zoom-lens state for magnified local inspection around pointer position. `cursor/zoom` delivers the zoom implementation for the cursor subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Stores radius, magnification, and border settings used by post-process cursor-lens rendering. The file owns or coordinates data contracts including `CursorZoom`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Serves as the magnifier feature contract controlled through cursor config and scripting paths. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `set_magnification`, `set_radius`, `toggle` stays attached to the local data model and invariants.



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
