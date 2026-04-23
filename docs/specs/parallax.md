# parallax

## General Info

- Module group: `Feature Systems`
- Source path: `src/parallax/`
- Lua API path(s): `src/lua_api/parallax_api.rs`
- Primary Lua namespace: `lurek.parallax`
- Rust test path(s): inline tests in src/parallax/layer.rs, src/parallax/render.rs, and src/parallax/draw.rs
- Lua test path(s): tests/lua/unit/test_parallax.lua, tests/lua/integration/test_parallax_camera.lua

## Summary

## Summary

The `parallax` module implements multi-layer scrolling backgrounds with camera-relative scroll factors, autoscroll, tiling, blend modes, z-ordering, and optional clamp boxes. It is a Feature Systems tier module that depends on render command types and `SharedState` for camera position.

**ParallaxLayer.** `ParallaxLayer` stores all visual and scroll parameters for a single scrolling background layer: a `TextureKey` for the source image; `scroll_factor (vx, vy)` in the range [0.0, 1.0] relative to camera speed (0.0 = pinned to screen, 1.0 = moves fully with world camera); `autoscroll_velocity` for time-driven translation independent of camera movement; `manual_offset` for game-controlled additional displacement. Additional fields: scale, tint colour, opacity, `BlendMode`, Z-order, `repeat_x`/`repeat_y` tiling flags, and an optional `(min_x, min_y, max_x, max_y)` clamp box that constrains pixel offset and prevents layers from drifting off screen.

**Scroll formula.** The pixel offset applied each frame is `pixel_offset = camera_pos * scroll_factor + manual_offset + autoscroll_accumulation`. For repeating layers the tile start position wraps: `start_x = -(pixel_offset_x % texture_width)`. `update(dt)` advances the autoscroll accumulator by `autoscroll_velocity * dt` each call.

**ParallaxDrawBatch.** `build_draw_calls(cam_x, cam_y)` produces a `ParallaxDrawBatch` — a list of tile positions and UV rectangles consumed by the render bridge to emit `RenderCommand::DrawImage` entries. The batch separates geometry computation from GPU command emission, enabling headless testing via `draw_to_image()` without a GPU.

**ParallaxSet.** `ParallaxSet` groups multiple named `ParallaxLayer` objects under a shared handle. `update(dt)` advances all layers at once. `drawAuto(commands)` reads the current camera position from `SharedState` and builds draw calls for all layers in Z-order without the caller needing to track camera state. Layers can be added, removed, and reordered by name within the set.

**Dynamic configuration.** `set_scroll_factor(vx, vy)`, `set_autoscroll_velocity(vx, vy)`, `set_manual_offset(ox, oy)`, `set_clamp_box(min_x, min_y, max_x, max_y)`, `set_opacity(a)`, `set_tint(color)`, `set_blend_mode(mode)`, `set_depth(z)` can all be called on a live layer at runtime. This enables responsive parallax effects — e.g. a background layer that accelerates during a sprint sequence or shifts hue during a weather transition — without reconstructing the layer.

**Tiling.** `set_tiling(repeat_x, repeat_y)` enables seamless infinite tiling on each axis independently. `set_tile_size(w, h)` overrides the natural texture dimensions as the tile step, enabling non-square tiling grids or partial-tile edge handling. `reset_autoscroll()` zeroes the autoscroll accumulator without changing velocity, useful for level transitions that need the background positioned at the origin.

**Render pipeline.** `render.rs` calls `generate_render_commands(cam_x, cam_y, screen_w, screen_h)` per layer, which builds the batch and converts it to `RenderCommand` entries with blend mode, tint, and per-tile UV. `batch_to_render_commands(batch, commands)` is the corresponding function for pre-built batches. Drawing order follows Z-depth, lowest value drawn first (behind).

**Lua surface.** `lurek.parallax.newLayer(opts)` creates a layer from a spec table. `lurek.parallax.newSet(name)` creates a layer group. Layer methods: `update(dt)`, `draw(cam_x, cam_y, commands)`, `setScrollFactor(vx, vy)`, `setAutoscroll(vx, vy)`, `setOffset(ox, oy)`, `setOpacity(a)`, `setTint(color)`, `setBlendMode(mode)`, `setDepth(z)`, `setTiling(rx, ry)`, `setClampBox(minx, miny, maxx, maxy)`, `resetAutoscroll()`. Set methods: `add(name, layer)`, `remove(name)`, `get(name)`, `update(dt)`, `drawAuto(commands)`, `setOrder(names)`.

**Scope boundary.** Feature Systems tier. Depends on `render` (RenderCommand, BlendMode), `runtime` (SharedState, TextureKey), `math`. Lua bridge in `src/lua_api/parallax_api.rs`.

## Files

- `draw.rs`: Implements CPU-side image drawing for headless and test-friendly parallax output without depending on the GPU path.
- `layer.rs`: Defines `ParallaxLayer` state, scroll calculations, autoscroll behavior, and batch-building logic.
- `mod.rs`: Declares the parallax submodules and re-exports the main layer and batch types.
- `render.rs`: Converts parallax batches into `RenderCommand` sequences with color, blend mode, and repeated image draws.

## Types

- `ParallaxDrawBatch` (`struct`, `layer.rs`): A CPU-side batch description generated from a layer so the Lua bridge or renderer can issue the actual draw commands.
- `ParallaxLayer` (`struct`, `layer.rs`): The main scrolling background layer. It owns camera-relative scroll factors, offsets, tiling, opacity, tint, scale, bounds, and z-order.

## Functions

- `ParallaxLayer::draw_to_image` (`draw.rs`): Render this parallax layer to a CPU image for headless testing.
- `ParallaxLayer::new` (`layer.rs`): Creates a new `ParallaxLayer` with sensible defaults.
- `ParallaxLayer::update` (`layer.rs`): Advances the autonomous scroll accumulator by `dt` seconds.
- `ParallaxLayer::build_draw_calls` (`layer.rs`): Builds the draw tile batch for this layer.
- `ParallaxLayer::reset_autoscroll` (`layer.rs`): Resets the autoscroll accumulator to zero.
- `ParallaxLayer::set_tiling` (`layer.rs`): Enables or disables seamless infinite tiling on both axes.
- `ParallaxLayer::get_tiling` (`layer.rs`): Returns `true` if seamless infinite tiling is enabled.
- `ParallaxLayer::set_tile_size` (`layer.rs`): Sets an explicit tile size override, bypassing the scaled texture dimensions.
- `ParallaxLayer::set_depth` (`layer.rs`): Sets the floating-point draw depth for this layer.
- `ParallaxLayer::get_depth` (`layer.rs`): Returns the floating-point draw depth.
- `ParallaxLayer::generate_render_commands` (`render.rs`): Produces render commands for this layer given the current camera and screen.
- `batch_to_render_commands` (`render.rs`): Converts a pre-computed [`ParallaxDrawBatch`] into render commands.

## Lua API Reference

- Binding path(s): `src/lua_api/parallax_api.rs`
- Namespace: `lurek.parallax`

### Module Functions
- `lurek.parallax.newLayer`: Creates a new parallax background layer from an options table.
- `lurek.parallax.newSet`: Creates a new empty parallax set with the given name.

### `ParallaxLayer` Methods
- `ParallaxLayer:type`: Returns the type name of this object.
- `ParallaxLayer:update`: Advances the autonomous scroll accumulator by `dt` seconds.
- `ParallaxLayer:render`: Draws the layer using an explicit camera world position.
- `ParallaxLayer:renderAuto`: Draws the layer using the engine active camera position automatically.
- `ParallaxLayer:resetAutoscroll`: Resets the autonomous scroll accumulator to zero.
- `ParallaxLayer:setScrollFactor`: Sets the scroll factor relative to camera movement on each axis.
- `ParallaxLayer:getScrollFactor`: Returns the scroll factor as `(x, y)`.
- `ParallaxLayer:setOffset`: Sets the static world-pixel position bias added on top of camera scroll.
- `ParallaxLayer:getOffset`: Returns the static offset as `(x, y)`.
- `ParallaxLayer:setAutoscroll`: Sets the autonomous scroll velocity in world-pixels per second.
- `ParallaxLayer:getAutoscroll`: Returns the autoscroll velocity as `(vx, vy)`.
- `ParallaxLayer:setRepeat`: Sets whether the layer tiles on the X and Y axes.
- `ParallaxLayer:setScale`: Sets the texture display scale factor on each axis.
- `ParallaxLayer:setZ`: Sets the draw-order depth. Lower values render first (further back).
- `ParallaxLayer:getZ`: Returns the draw-order depth.
- `ParallaxLayer:setOpacity`: Sets the layer-wide opacity override in `[0.0, 1.0]`.
- `ParallaxLayer:getOpacity`: Returns the current opacity.
- `ParallaxLayer:setTint`: Sets the multiplicative RGBA tint applied to all pixels of this layer.
- `ParallaxLayer:getTint`: Returns the current tint as `(r, g, b, a)`.
- `ParallaxLayer:setBlendMode`: Sets the GPU blend mode for this layer.
- `ParallaxLayer:getBlendMode`: Returns the current blend mode as a string.
- `ParallaxLayer:setVisible`: Shows or hides this layer.
- `ParallaxLayer:isVisible`: Returns `true` if the layer is currently visible.
- `ParallaxLayer:clearClamp`: Removes scroll clamping so the layer scrolls freely.
- `ParallaxLayer:setTiling`: Enables or disables seamless infinite tiling on both axes simultaneously.
- `ParallaxLayer:getTiling`: Returns `true` if seamless infinite tiling is enabled.
- `ParallaxLayer:setTileSize`: Sets explicit tile dimensions in logical pixels, overriding the default
- `ParallaxLayer:setDepth`: Sets the floating-point draw depth for fine-grained layer ordering.
- `ParallaxLayer:getDepth`: Returns the current floating-point depth.

### `ParallaxSet` Methods
- `ParallaxSet:type`: Returns the type name of this object.
- `ParallaxSet:addLayer`: Adds a layer to this set.
- `ParallaxSet:removeLayerAt`: Removes the layer at the given 1-based index.
- `ParallaxSet:layerCount`: Returns the number of layers in this set.
- `ParallaxSet:sortByZ`: Re-sorts all layers by ascending `z` value.
- `ParallaxSet:setVisible`: Shows or hides all layers in this set.
- `ParallaxSet:isVisible`: Returns `true` if the set is currently visible.
- `ParallaxSet:update`: Advances the autoscroll accumulator of every layer by `dt` seconds.
- `ParallaxSet:render`: Draws all visible layers in ascending `z` order using an explicit camera position.
- `ParallaxSet:renderAuto`: Draws all visible layers using the engine active camera position.
- `ParallaxSet:getName`: Returns the name of this set.
- `ParallaxSet:setName`: Sets the name of this set.

## References

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/parallax/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
