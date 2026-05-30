# cursor

## General Info

- Module group: `Edge/Integration`
- Source path: `src/cursor/`
- Binding: `src/lua_api/cursor_api.rs`
- Namespace: `lurek.cursor`
- Lua API surface: `4` functions, `3` types, `30` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

The `cursor` module gives one runtime layer for pointer presentation. It lets scripts control how the pointer looks, when it is visible, whether it is locked, and how it reacts in different runtime contexts.

It supports both system and custom visuals in the same flow. Teams can use native cursor shapes, pixel-defined custom cursors, or animated cursor sequences, then switch between them through explicit rules instead of ad-hoc per-screen logic.

The module also adds optional feedback features such as trails and zoom lens behavior. These features improve readability and interaction feel without forcing changes in core input capture.

A key functional boundary is separation from raw input collection. Input systems provide pointer state, and the cursor module decides presentation policy. This keeps cursor behavior easier to tune for accessibility, UX style, and tool-specific modes.

In practice, `lurek.cursor` provides a stable pointer contract for gameplay and tools: pick active cursor mode, apply context mapping, and keep pointer feedback predictable across different runtime surfaces.

## Files

### [animated_cursor.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/cursor/animated_cursor.rs)

- Implements animated cursor state using frame sequences and time-based frame advancement.
- Supports optional pulse scaling driven by oscillation parameters independent of frame stepping.
- Maintains deterministic timing behavior through per-frame duration tracking.
- Integrates as an active cursor-state variant within context-aware cursor orchestration.
- Serves as the runtime animation layer for custom cursors with motion feedback.

### [config.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/cursor/config.rs)

- Defines cursor-system configuration values loaded from project settings and startup defaults.
- Controls feature toggles and behavior for trail effects, zoom lens, contexts, and idle visibility.
- Serves as the shared config contract consumed by cursor runtime orchestration.

### [context.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/cursor/context.rs)

- Implements context-sensitive cursor switching by mapping named runtime contexts to cursor states.
- Supports system, custom, and animated cursor variants under one discriminated state model.
- Applies context changes immediately while preserving a deterministic default fallback path.
- Integrates optional trail and zoom behavior into active cursor presentation state.
- Serves as the policy layer for script-driven cursor-mode transitions.

### [custom_cursor.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/cursor/custom_cursor.rs)

- Implements custom cursor images built from RGBA pixel buffers and hotspot metadata.
- Validates buffer dimensions at construction to prevent malformed cursor payload usage.
- Supports standalone custom cursors and animated-frame reuse through shared image structure.
- Serves as the pixel-defined cursor asset contract for script-driven cursor customization.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/cursor/mod.rs)

- Defines the cursor module boundary for system, custom, animated, contextual, and effect-driven cursor behavior.
- Groups cursor state types, visual effects, and configuration contracts into one cohesive runtime surface.
- Serves as the composition entry for engine and script-side cursor control workflows.

### [system_cursor.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/cursor/system_cursor.rs)

- Defines cross-platform system cursor shape variants used by runtime cursor state.
- Maps engine-facing cursor variants to platform-native icon representations.
- Supports case-insensitive string parsing for config and script-driven selection.
- Serves as the canonical enum contract for system cursor mode requests.

### [trail.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/cursor/trail.rs)

- Implements cursor-trail effects with fading points, connected strokes, and particle-style variants.
- Tracks trail samples as timestamped points with alpha decay progression over update ticks.
- Maintains bounded point history through capped storage to control runtime memory pressure.
- Supports multiple trail render modes selected by explicit trail behavior configuration.
- Serves as the visual motion-feedback layer for cursor movement presentation.

### [zoom.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/cursor/zoom.rs)

- Implements cursor-following zoom-lens state for magnified local inspection around pointer position.
- Stores radius, magnification, and border settings used by post-process cursor-lens rendering.
- Serves as the magnifier feature contract controlled through cursor config and scripting paths.
