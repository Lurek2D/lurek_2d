# cursor

## TL;DR

- The `cursor` module manages OS cursor state, custom image cursors, animated frame sequences, context-sensitive switching, visual trail effects, and a magnifying zoom lens for Lurek2D games.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/cursor/`
- Binding: `src/lua_api/cursor_api.rs`
- Namespace: `lurek.cursor`
- Lua API surface: `4` functions, `3` types, `30` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

The `cursor` module owns cursor presentation and behavior policy, including system cursor selection, custom image cursors, animated cursor sequences, context-based switching, trail effects, and cursor magnifier support. It provides a single stateful surface for cursor concerns instead of scattering cursor logic across input and UI code.

Submodules map directly to feature domains: `system_cursor` for native cursor kinds, `custom_cursor` for image/hotspot management, `animated_cursor` for timed frame cycling and pulse behavior, `context` for dynamic mode switching, `trail` for visual trails, and `zoom` for cursor-centered magnification.

The design keeps input capture and cursor rendering conceptually separate. Input modules report state; cursor modules decide representation and visual behavior. This improves maintainability when adding context-sensitive visuals or accessibility-oriented cursor modes.

In practice, cursor behavior should remain deterministic and low-latency, with clear fallback paths between native/system cursors and custom/animated variants.

Implementation detail and boundary guarantees for cursor: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: animated_cursor.rs: Animated cursor: frame sequences with per-frame timing and pulse scale effects.; config.rs: Global cursor system configuration shared across the cursor manager.; context.rs: Context-sensitive cursor switching: maps named contexts to cursor states.; custom_cursor.rs: Custom image cursor built from RGBA pixel data with configurable hotspot offset.; mod.rs: Cursor management system.; system_cursor.rs: System cursor shapes available on all desktop platforms.; trail.rs: Cursor trail effects: fading dot trails, connected line trails, and particle modes.; zoom.rs: Cursor magnifier lens: a configurable zoom window that follows the cursor.. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

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

- `lurek.cursor.newAnimated`: Creates a new animated cursor that can cycle through frames.
- `lurek.cursor.newCustom`: Creates a new custom cursor with specified dimensions and hotspot position.
- `lurek.cursor.newManager`: Creates a new cursor manager for handling cursor state and visibility.
- `lurek.cursor.systemCursors`: Returns a list of all available system cursor names as a string array.

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

- `LAnimatedCursor:addFrame`: Add a frame from a custom cursor image.
- `LAnimatedCursor:clearPulse`: Disable pulse animation for this object.
- `LAnimatedCursor:currentIndex`: Get current frame index for this object.
- `LAnimatedCursor:currentScale`: Get current scale from pulse animation.
- `LAnimatedCursor:frameCount`: Get total frame count for this object.
- `LAnimatedCursor:reset`: Reset the cursor animation playback to the first frame.
- `LAnimatedCursor:setPulse`: Set the pulse animation speed and scale factor parameters.
- `LAnimatedCursor:update`: Update animation (call each frame).

#### LCursorManager Type

- Lua userdata that controls cursor appearance and system cursor selection.

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

- Lua userdata representing a custom-drawn cursor image with a configurable hot-spot.

##### Fields

- No documented fields.

##### Methods

- `LCustomCursor:getHotspot`: Get hotspot position for this object.
- `LCustomCursor:getPixel`: Get the pixel color at the specified cursor image position.
- `LCustomCursor:getSize`: Get the pixel width and height of the cursor image.
- `LCustomCursor:setPixel`: Set a pixel color â€” Lua userdata object exposed by the engine.
