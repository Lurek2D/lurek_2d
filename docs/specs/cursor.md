# cursor

## TL;DR

- Manages contextual custom cursors, motion trails, and magnifiers.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/cursor/`
- Binding: `src/lua_api/cursor_api.rs`
- Namespace: `lurek.cursor`
- Lua API surface: `4` functions, `3` types, `30` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

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

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### animated_cursor.rs

- Implements animated cursor state using frame sequences and time-based frame advancement.
- Supports optional pulse scaling driven by oscillation parameters independent of frame stepping.
- Maintains deterministic timing behavior through per-frame duration tracking.
- Integrates as an active cursor-state variant within context-aware cursor orchestration.
- Serves as the runtime animation layer for custom cursors with motion feedback.

### config.rs

- Defines cursor-system configuration values loaded from project settings and startup defaults.
- Controls feature toggles and behavior for trail effects, zoom lens, contexts, and idle visibility.
- Serves as the shared config contract consumed by cursor runtime orchestration.

### context.rs

- Implements context-sensitive cursor switching by mapping named runtime contexts to cursor states.
- Supports system, custom, and animated cursor variants under one discriminated state model.
- Applies context changes immediately while preserving a deterministic default fallback path.
- Integrates optional trail and zoom behavior into active cursor presentation state.
- Serves as the policy layer for script-driven cursor-mode transitions.

### custom_cursor.rs

- Implements custom cursor images built from RGBA pixel buffers and hotspot metadata.
- Validates buffer dimensions at construction to prevent malformed cursor payload usage.
- Supports standalone custom cursors and animated-frame reuse through shared image structure.
- Serves as the pixel-defined cursor asset contract for script-driven cursor customization.

### mod.rs

- Defines the cursor module boundary for system, custom, animated, contextual, and effect-driven cursor behavior.
- Groups cursor state types, visual effects, and configuration contracts into one cohesive runtime surface.
- Serves as the composition entry for engine and script-side cursor control workflows.

### system_cursor.rs

- Defines cross-platform system cursor shape variants used by runtime cursor state.
- Maps engine-facing cursor variants to platform-native icon representations.
- Supports case-insensitive string parsing for config and script-driven selection.
- Serves as the canonical enum contract for system cursor mode requests.

### trail.rs

- Implements cursor-trail effects with fading points, connected strokes, and particle-style variants.
- Tracks trail samples as timestamped points with alpha decay progression over update ticks.
- Maintains bounded point history through capped storage to control runtime memory pressure.
- Supports multiple trail render modes selected by explicit trail behavior configuration.
- Serves as the visual motion-feedback layer for cursor movement presentation.

### zoom.rs

- Implements cursor-following zoom-lens state for magnified local inspection around pointer position.
- Stores radius, magnification, and border settings used by post-process cursor-lens rendering.
- Serves as the magnifier feature contract controlled through cursor config and scripting paths.

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
