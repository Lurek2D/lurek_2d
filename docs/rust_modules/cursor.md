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

The cursor module manages pointer presentation, custom cursor assets, context-sensitive switching policies, and visual pointer feedback effects in Lurek2D. Its core purpose is to provide scripts with highly responsive, interactive cursor customizations that adapt to game states, UI contexts, and player actions.

It handles cross-platform platform-native system cursor shapes alongside fully custom cursors built from RGBA pixel buffers and coordinate hotspots. Cursors can be animated through time-stepped frame sequences and standalone scale pulse animations. Additionally, the cursor manager orchestrates context-sensitive style transitions, and applies aesthetic and functional trail feedback overlays (fading points, connected strokes) and cursor-following post-process zoom magnifiers.

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
