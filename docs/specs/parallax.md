# parallax

## TL;DR

- Manages layered scroll depth, autoscrolling, and tiling.
- Adds motion blur.

## General Info

- Module group: `Feature Systems`
- Source path: `src/parallax/`
- Binding: `src/lua_api/parallax_api.rs`
- Namespace: `lurek.parallax`
- Lua API surface: `3` functions, `2` types, `50` methods
- Rust test path(s): tests/rust/unit/parallax_tests.rs
- Lua test path(s): tests/lua/unit/test_parallax_core_unit.lua, tests/lua/integration/test_parallax_camera.lua

## Summary

- This module gives users layered parallax control for creating depth in 2D scenes.
- Layers can move at different scroll factors relative to camera movement.
- Autoscroll support enables moving skies, fog drift, and ambient motion backgrounds.
- Clamp options keep layer motion within designed world bounds.
- Tiling logic maintains seamless coverage across the viewport.
- Preset layers provide quick-start setups for common depth planes.
- Motion-stretch options add velocity-driven style cues.
- Per-layer effect chains support stylized post-processing on background planes.
- Layer and set telemetry expose tile counts, effect pressure, and autoscroll state for runtime dashboards.
- Layer sets help organize multiple planes into reusable scene groups.
- For users, this module turns depth presentation into a configurable runtime system.

This module primarily collaborates with `image`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Imports

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### draw.rs

- Rasterises a single parallax layer into an ImageData bitmap. `parallax/draw` delivers the draw implementation for the parallax subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

### layer.rs

- Single parallax layer definition with scroll factor, autoscroll, tiling, opacity, and tint. `parallax/layer` delivers the layer implementation for the parallax subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Carries draw-batch state so render submission stays separated from configuration. The file owns or coordinates data contracts including `ParallaxLayerStats`, `ParallaxDrawBatch`, `ParallaxLayer`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Computes camera-relative pixel offsets with optional scroll clamping. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `update`, `build_draw_calls`, `stats_for_view`, `reset_autoscroll`, `set_tiling`, and 9 more stays attached to the local data model and invariants.
- Delegates tile repetition to tile_iter for viewport coverage. Runtime integration reaches sibling engine areas through crate modules `render`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Supports motion-stretch blur injection based on autoscroll velocity. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### mod.rs

- Multi-layer parallax scrolling system with per-layer speed, tiling, and draw-batch accumulation. `parallax/mod` is the parallax module index, declaring `draw`, `layer`, `presets`, `render`, `tile_iter` so agents can identify which files own each feature slice before opening implementation code.
- Provides preset constructors for common depth planes and tile iteration helpers for rendering. `src/parallax/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `layer::{ParallaxDrawBatch, ParallaxLayer}` centralized for the parallax subsystem.

### presets.rs

- Ready-made parallax layer constructors for common depth planes. `parallax/presets` delivers the presets implementation for the parallax subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Covers far background, mid background, and foreground fog presets. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Bakes scroll factor, repeat, z-order, opacity, and blend mode into each preset. Public callable behavior is centered on `far_background`, `mid_background`, `foreground_fog`, while method-level behavior such as no named public items stays attached to the local data model and invariants.

### render.rs

- Converts parallax layer state into flat RenderCommand lists for the renderer. `parallax/render` delivers the rendering adapter and draw-command integration for the parallax subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Batches tile positions into draw-image sequences with color and blend pre-applied. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Bridges parallax camera math to the GPU submission pipeline. Public callable behavior is centered on `batch_to_render_commands`, while method-level behavior such as `generate_render_commands` stays attached to the local data model and invariants.

### tile_iter.rs

- Computes visible tile positions for repeating parallax layers inside a screen rect and cull margin. `parallax/tile_iter` delivers the tile iter implementation for the parallax subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Walks one axis at a time and combines X and Y into a full grid with bounded growth. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Emits only the single origin position for non-repeating layers. Public callable behavior is centered on `collect_tiled_positions`, while method-level behavior such as no named public items stays attached to the local data model and invariants.



## Lua API Ref

### Functions

- `lurek.parallax.newLayer(opts) -> LParallaxLayer`: Creates a parallax layer from an options table.
- `lurek.parallax.newPresetLayer(preset_name, img_ud) -> LParallaxLayer`: Creates a parallax layer from a named preset and texture image.
- `lurek.parallax.newSet(name) -> LParallaxSet`: Creates an empty parallax layer set.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LParallaxLayer Type

- Lua-side wrapper for a parallax layer and shared render state.

##### Fields

- No documented fields.

##### Methods

- `LParallaxLayer:addEffectPass(effect_name, params?) -> nil`: Adds a shader effect pass to this layer.
- `LParallaxLayer:clearClamp() -> nil`: Clears layer clamp bounds on this object.
- `LParallaxLayer:clearEffects() -> nil`: Clears shader effect passes from this layer.
- `LParallaxLayer:effectCount() -> integer`: Returns the shader effect pass count for this layer.
- `LParallaxLayer:getAutoscroll() -> number`: Returns layer autoscroll velocity.
- `LParallaxLayer:getBlendMode() -> string`: Returns the current layer blend mode name.
- `LParallaxLayer:getDepth() -> number`: Returns parallax depth from this object.
- `LParallaxLayer:getMotionStretch() -> boolean`: Returns the current motion stretch settings.
- `LParallaxLayer:getOffset() -> number`: Returns layer offset for this object.
- `LParallaxLayer:getOpacity() -> number`: Returns layer opacity from this object.
- `LParallaxLayer:getScrollFactor() -> number`: Returns layer scroll factor from this object.
- `LParallaxLayer:getStats() -> table`: Returns telemetry for the current runtime camera and viewport.
- `LParallaxLayer:getTiling() -> boolean`: Returns whether layer tiling is enabled.
- `LParallaxLayer:getTint() -> number`: Returns layer tint color from this object.
- `LParallaxLayer:getZ() -> integer`: Returns layer z order from this object.
- `LParallaxLayer:isVisible() -> boolean`: Returns layer visibility and returns a boolean.
- `LParallaxLayer:render(cam_x, cam_y) -> nil`: Enqueues render commands using explicit camera coordinates.
- `LParallaxLayer:renderAuto() -> nil`: Enqueues render commands using the runtime camera.
- `LParallaxLayer:resetAutoscroll() -> nil`: Resets the layer autoscroll offset to zero.
- `LParallaxLayer:setAutoscroll(vx, vy) -> nil`: Sets the layer autoscroll velocity values.
- `LParallaxLayer:setBlendMode(mode) -> nil`: Sets the layer blend mode by string name.
- `LParallaxLayer:setClamp(min_x, min_y, max_x, max_y) -> nil`: Sets clamp bounds for layer movement.
- `LParallaxLayer:setDepth(z) -> nil`: Sets parallax depth for this object.
- `LParallaxLayer:setMotionStretch(enabled, strength, max_scale) -> nil`: Sets the motion stretch settings for this layer.
- `LParallaxLayer:setOffset(x, y) -> nil`: Sets the layer pixel offset for this object.
- `LParallaxLayer:setOpacity(a) -> nil`: Sets layer opacity, clamped to 0..1.
- `LParallaxLayer:setRepeat(rx, ry) -> nil`: Sets horizontal and vertical repeat flags.
- `LParallaxLayer:setScale(sx, sy) -> nil`: Sets the layer scale factor for this object.
- `LParallaxLayer:setScrollFactor(x, y) -> nil`: Sets layer scroll factor for this object.
- `LParallaxLayer:setTileSize(w, h) -> nil`: Sets tile size for tiling for this object.
- `LParallaxLayer:setTiling(enabled) -> nil`: Enables or disables the layer tiling mode.
- `LParallaxLayer:setTint(r, g, b, a) -> nil`: Sets layer tint color for this object.
- `LParallaxLayer:setVisible(v) -> nil`: Sets layer visibility for this object.
- `LParallaxLayer:setZ(z) -> nil`: Sets the layer z order for this object.
- `LParallaxLayer:type() -> string`: Returns the Lua-visible type name for this parallax layer handle.
- `LParallaxLayer:update(dt) -> nil`: Advances parallax layer autoscroll by delta time.

#### LParallaxSet Type

- Lua-side wrapper for an ordered parallax layer set.

##### Fields

- No documented fields.

##### Methods

- `LParallaxSet:addLayer(layer) -> nil`: Adds a parallax layer to this set handle.
- `LParallaxSet:getLayerZAt(index) -> integer`: Returns z order for a layer by one-based index, or nil when out of range.
- `LParallaxSet:getName() -> string`: Returns this set name from this object.
- `LParallaxSet:getStats() -> table`: Returns aggregated telemetry for all layers in the set.
- `LParallaxSet:isVisible() -> boolean`: Returns set visibility and returns a boolean.
- `LParallaxSet:layerCount() -> integer`: Returns the number of layers in this set.
- `LParallaxSet:removeLayerAt(index) -> boolean`: Removes a layer by one-based index.
- `LParallaxSet:render(cam_x, cam_y) -> nil`: Enqueues render commands for all visible set layers using explicit camera coordinates.
- `LParallaxSet:renderAuto() -> nil`: Enqueues render commands for all visible set layers using the runtime camera.
- `LParallaxSet:setName(name) -> nil`: Sets this parallax set name for this object.
- `LParallaxSet:setVisible(v) -> nil`: Sets set visibility for this object.
- `LParallaxSet:sortByZ() -> nil`: Sorts layers by z order on this object.
- `LParallaxSet:type() -> string`: Returns the Lua-visible type name for this parallax set handle.
- `LParallaxSet:update(dt) -> nil`: Updates all layers in this parallax set.

## References

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- No additional module-specific notes.
