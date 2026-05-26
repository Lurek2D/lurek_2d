# parallax

## TL;DR

- The `parallax` module is a dedicated Feature Systems tier component that implements a highly configurable, multi-layer scrolling background system for Lurek2D.

## General Info

- Module group: `Feature Systems`
- Source path: `src/parallax/`
- Lua API path(s): `src/lua_api/parallax_api.rs`
- Primary Lua namespace: `lurek.parallax`
- Rust test path(s): tests/rust/unit/parallax_tests.rs
- Lua test path(s): tests/lua/unit/test_parallax_core_unit.lua, tests/lua/integration/test_parallax_camera.lua

## Summary

 It allows developers to easily create a deep sense of 2D perspective by stacking multiple textured layers that scroll at varying speeds relative to camera movement. The core of this system is the `ParallaxLayer`, which defines a single depth plane. By assigning a scroll speed multiplier to each layer (where 0.0 represents a distant static background and 1.0 moves precisely with the camera), the system automatically handles the complex camera-relative pixel offset computations necessary for convincing parallax effects. Layers are sorted back-to-front by their assigned Z-depth, with the lowest scroll factors naturally appearing furthest away.

In addition to camera-driven motion, the module features an independent auto-scroll mechanic. This allows layers to maintain a constant baseline velocity regardless of player movement, which is essential for animating ambient atmospheric elements like drifting clouds, flowing water, or moving starfields. The rendering pipeline of the `parallax` module is deeply optimized. It automatically computes `ParallaxDrawBatch`es, utilizing a sophisticated `tile_iter` algorithm to calculate the precise grid of visible repeating tiles required to fill the viewport (plus a safety cull margin). This avoids allocating vast repeating grids and instead generates lightweight, stateless `RenderCommand` sequences for GPU submission.

The visual fidelity of parallax layers can be further customized per-layer. It supports dynamic opacity adjustments, RGBA tinting, and various accumulation blend modes (such as additive or screen). Advanced visual features include a motion-stretch blur effect, which procedurally stretches layer tiles based on their auto-scroll velocity to simulate high-speed motion. For ease of use, the module includes a `presets` system offering ready-made configurations for common depth planes (e.g., far backgrounds, mid-grounds, and foreground fog). Grouped management is provided via `ParallaxSet`s, and the entire feature suite is fully exposed to the Lua environment through the `lurek.parallax.*` API.

## Source Documentation

### `draw.rs`
- Rasterisation of a single parallax layer into an `ImageData` bitmap.
- Applies tint, opacity, and visibility when drawing.
- Produces a solid-colour image sized to the requested dimensions.

### `layer.rs`
- Single parallax layer definition with scroll factor, autoscroll, tiling, opacity, and tint.
- Draw-batch struct that collects tile positions and render state for submission.
- Camera-relative pixel offset computation with optional scroll clamping.
- Tile repetition logic delegated to `tile_iter` for viewport coverage.
- Motion-stretch blur effect injection based on autoscroll velocity.
- Shader effect chain management (set, clear, count) per layer.

### `mod.rs`
- Multi-layer parallax scrolling system with per-layer speed, tiling, and draw-batch accumulation.
- Preset constructors for common configurations (sky, mountains, clouds).
- Tile-column iterator and stateless draw-call generation into `RenderCommand` payloads.

### `presets.rs`
- Ready-made parallax layer constructors for common depth planes.
- Far background, mid background, and foreground fog presets.
- Each preset configures scroll factor, repeat, z-order, opacity, and blend mode.

### `render.rs`
- Convert parallax layer state into flat `RenderCommand` lists for the renderer.
- Tile position batches into draw-image sequences with color and blend pre-applied.
- Bridge between the parallax camera math and the GPU submission pipeline.

### `tile_iter.rs`
- Compute visible tile positions for repeating parallax layers within a screen rect plus cull margin.
- Walk one axis at a time and combine X/Y into a full grid, capped to prevent runaway allocation.
- Non-repeating layers emit only the single start position.

## Types

- `ParallaxDrawBatch` (`struct`, `layer.rs`): A CPU-side batch description generated from a layer so the Lua bridge or renderer can issue the actual draw commands.
- `ParallaxLayer` (`struct`, `layer.rs`): The main scrolling background layer. It owns camera-relative scroll factors, offsets, tiling, opacity, tint, scale, bounds, and z-order.

## Functions

- `ParallaxLayer::draw_to_image` (`draw.rs`): Rasterise this layer into a solid-colour `ImageData` sized `width × height`; returns transparent image when `visible` is `false`.
- `ParallaxLayer::new` (`layer.rs`): Create a new layer for `texture_key` with the given texture dimensions and sensible defaults.
- `ParallaxLayer::update` (`layer.rs`): Advance the autoscroll accumulator by `dt` seconds and wrap it to one tile width/height.
- `ParallaxLayer::build_draw_calls` (`layer.rs`): Build a `ParallaxDrawBatch` for the current camera position; returns `None` when invisible or zero-size.
- `ParallaxLayer::reset_autoscroll` (`layer.rs`): Reset the autoscroll accumulator to `[0.0, 0.0]`.
- `ParallaxLayer::set_tiling` (`layer.rs`): Set whether tiling mode (forces repeat on both axes) is active.
- `ParallaxLayer::get_tiling` (`layer.rs`): Return `true` when tiling mode is active.
- `ParallaxLayer::set_tile_size` (`layer.rs`): Override tile size to `(w, h)` pixels; `0.0` or negative resets to texture-derived size.
- `ParallaxLayer::set_depth` (`layer.rs`): Set the depth sort value for this layer.
- `ParallaxLayer::get_depth` (`layer.rs`): Return the current depth sort value.
- `ParallaxLayer::set_effect_chain` (`layer.rs`): Replace the shader effect chain; an empty `chain` clears the existing chain.
- `ParallaxLayer::clear_effect_chain` (`layer.rs`): Remove all shader effects from this layer.
- `ParallaxLayer::effect_count` (`layer.rs`): Return the number of shader passes currently in the effect chain.
- `ParallaxLayer::set_motion_stretch` (`layer.rs`): Configure motion-stretch blur; `strength` controls pixels-per-sec sensitivity, `max_scale` caps the scale boost.
- `far_background` (`presets.rs`): Create a slow far-background layer (scroll factor ~0.15 horizontal); horizontal repeat, Z = -200, opacity 0.8.
- `mid_background` (`presets.rs`): Create a mid-speed background layer (scroll factor ~0.45 horizontal); horizontal repeat, Z = -100, opacity 0.9.
- `foreground_fog` (`presets.rs`): Create a near-screen fog layer: fast scroll, tiled, Screen blend, 35% opacity, light motion-stretch blur, Z = 50.
- `ParallaxLayer::generate_render_commands` (`render.rs`): Generate a `Vec<RenderCommand>` for this layer at the given camera position and screen size.
- `batch_to_render_commands` (`render.rs`): Converts a pre-computed [`ParallaxDrawBatch`] into render commands.
- `collect_tiled_positions` (`tile_iter.rs`): Return all `(x, y)` tile positions visible inside `screen_size` plus the cull margin; capped at `MAX_TILED_POSITIONS`.

## Lua API Reference

- Binding path(s): `src/lua_api/parallax_api.rs`
- Namespace: `lurek.parallax`

### Module Functions
- `lurek.parallax.newLayer`: Creates a parallax layer from an options table.
- `lurek.parallax.newSet`: Creates an empty parallax layer set.
- `lurek.parallax.newPresetLayer`: Creates a parallax layer from a named preset and texture image.

### `LParallaxLayer` Methods
- `LParallaxLayer:type`: Returns the Lua-visible type name for this parallax layer handle.
- `LParallaxLayer:update`: Advances parallax layer autoscroll by delta time.
- `LParallaxLayer:render`: Enqueues render commands using explicit camera coordinates.
- `LParallaxLayer:renderAuto`: Enqueues render commands using the runtime camera.
- `LParallaxLayer:resetAutoscroll`: Resets the layer autoscroll offset to zero.
- `LParallaxLayer:setScrollFactor`: Sets layer scroll factor for this object.
- `LParallaxLayer:getScrollFactor`: Returns layer scroll factor from this object.
- `LParallaxLayer:setOffset`: Sets the layer pixel offset for this object.
- `LParallaxLayer:getOffset`: Returns layer offset for this object.
- `LParallaxLayer:setAutoscroll`: Sets the layer autoscroll velocity values.
- `LParallaxLayer:getAutoscroll`: Returns layer autoscroll velocity.
- `LParallaxLayer:setRepeat`: Sets horizontal and vertical repeat flags.
- `LParallaxLayer:setScale`: Sets the layer scale factor for this object.
- `LParallaxLayer:setZ`: Sets the layer z order for this object.
- `LParallaxLayer:getZ`: Returns layer z order from this object.
- `LParallaxLayer:setOpacity`: Sets layer opacity, clamped to 0..1.
- `LParallaxLayer:getOpacity`: Returns layer opacity from this object.
- `LParallaxLayer:setTint`: Sets layer tint color for this object.
- `LParallaxLayer:getTint`: Returns layer tint color from this object.
- `LParallaxLayer:setBlendMode`: Sets the layer blend mode by string name.
- `LParallaxLayer:getBlendMode`: Returns the current layer blend mode name.
- `LParallaxLayer:setVisible`: Sets layer visibility for this object.
- `LParallaxLayer:isVisible`: Returns layer visibility and returns a boolean.
- `LParallaxLayer:setClamp`: Sets clamp bounds for layer movement.
- `LParallaxLayer:clearClamp`: Clears layer clamp bounds on this object.
- `LParallaxLayer:setTiling`: Enables or disables the layer tiling mode.
- `LParallaxLayer:getTiling`: Returns whether layer tiling is enabled.
- `LParallaxLayer:setTileSize`: Sets tile size for tiling for this object.
- `LParallaxLayer:setDepth`: Sets parallax depth for this object.
- `LParallaxLayer:getDepth`: Returns parallax depth from this object.
- `LParallaxLayer:addEffectPass`: Adds a shader effect pass to this layer.
- `LParallaxLayer:clearEffects`: Clears shader effect passes from this layer.
- `LParallaxLayer:effectCount`: Returns the shader effect pass count for this layer.
- `LParallaxLayer:setMotionStretch`: Sets the motion stretch settings for this layer.
- `LParallaxLayer:getMotionStretch`: Returns the current motion stretch settings.

### `LParallaxSet` Methods
- `LParallaxSet:type`: Returns the Lua-visible type name for this parallax set handle.
- `LParallaxSet:addLayer`: Adds a parallax layer to this set handle.
- `LParallaxSet:removeLayerAt`: Removes a layer by one-based index.
- `LParallaxSet:layerCount`: Returns the number of layers in this set.
- `LParallaxSet:getLayerZAt`: Returns z order for a layer by one-based index, or nil when out of range.
- `LParallaxSet:sortByZ`: Sorts layers by z order on this object.
- `LParallaxSet:setVisible`: Sets set visibility for this object.
- `LParallaxSet:isVisible`: Returns set visibility and returns a boolean.
- `LParallaxSet:update`: Updates all layers in this parallax set.
- `LParallaxSet:render`: Enqueues render commands for all visible set layers using explicit camera coordinates.
- `LParallaxSet:renderAuto`: Enqueues render commands for all visible set layers using the runtime camera.
- `LParallaxSet:getName`: Returns this set name from this object.
- `LParallaxSet:setName`: Sets this parallax set name for this object.

## References

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Runtime behavior notes:
	- `setTiling(true)` forces tiling on both axes even if `repeat_x` and `repeat_y` are false.
	- `setTileSize(w, h)` enforces a small minimum tile size to protect against pathological tile counts.
	- `build_draw_calls` now uses a shared tiled iterator helper with expanded culling bounds and an upper safety cap for generated positions.
	- `DrawImageEx.effect` is now populated from per-layer effect passes configured on `LParallaxLayer`.
	- Motion-stretch can scale tiles based on autoscroll velocity and can append a `motion_blur` pass dynamically.
- Keep this module reference synchronized with `src/parallax/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
