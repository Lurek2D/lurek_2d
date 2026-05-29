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

## Files

### draw.rs

- Rasterisation of a single parallax layer into an `ImageData` bitmap.
- Applies tint, opacity, and visibility when drawing.
- Produces a solid-colour image sized to the requested dimensions.

### layer.rs

- Single parallax layer definition with scroll factor, autoscroll, tiling, opacity, and tint.
- Draw-batch struct that collects tile positions and render state for submission.
- Camera-relative pixel offset computation with optional scroll clamping.
- Tile repetition logic delegated to `tile_iter` for viewport coverage.
- Motion-stretch blur effect injection based on autoscroll velocity.
- Shader effect chain management (set, clear, count) per layer.

### mod.rs

- Multi-layer parallax scrolling system with per-layer speed, tiling, and draw-batch accumulation.
- Preset constructors for common configurations (sky, mountains, clouds).
- Tile-column iterator and stateless draw-call generation into `RenderCommand` payloads.

### presets.rs

- Ready-made parallax layer constructors for common depth planes.
- Far background, mid background, and foreground fog presets.
- Each preset configures scroll factor, repeat, z-order, opacity, and blend mode.

### render.rs

- Convert parallax layer state into flat `RenderCommand` lists for the renderer.
- Tile position batches into draw-image sequences with color and blend pre-applied.
- Bridge between the parallax camera math and the GPU submission pipeline.

### tile_iter.rs

- Compute visible tile positions for repeating parallax layers within a screen rect plus cull margin.
- Walk one axis at a time and combine X/Y into a full grid, capped to prevent runaway allocation.
- Non-repeating layers emit only the single start position.

## Lua API Ref

- Binding: `src/lua_api/parallax_api.rs`
- Namespace: `lurek.parallax`

### Functions

- `lurek.parallax.newLayer`: Creates a parallax layer from an options table.
- `lurek.parallax.newPresetLayer`: Creates a parallax layer from a named preset and texture image.
- `lurek.parallax.newSet`: Creates an empty parallax layer set.

### Enums

- No documented module-level enums/constants.

### Types


#### LParallaxLayer Type


##### Fields

- No documented fields.

##### Methods

- `LParallaxLayer:addEffectPass`: Adds a shader effect pass to this layer.
- `LParallaxLayer:clearClamp`: Clears layer clamp bounds on this object.
- `LParallaxLayer:clearEffects`: Clears shader effect passes from this layer.
- `LParallaxLayer:effectCount`: Returns the shader effect pass count for this layer.
- `LParallaxLayer:getAutoscroll`: Returns layer autoscroll velocity.
- `LParallaxLayer:getBlendMode`: Returns the current layer blend mode name.
- `LParallaxLayer:getDepth`: Returns parallax depth from this object.
- `LParallaxLayer:getMotionStretch`: Returns the current motion stretch settings.
- `LParallaxLayer:getOffset`: Returns layer offset for this object.
- `LParallaxLayer:getOpacity`: Returns layer opacity from this object.
- `LParallaxLayer:getScrollFactor`: Returns layer scroll factor from this object.
- `LParallaxLayer:getTiling`: Returns whether layer tiling is enabled.
- `LParallaxLayer:getTint`: Returns layer tint color from this object.
- `LParallaxLayer:getZ`: Returns layer z order from this object.
- `LParallaxLayer:isVisible`: Returns layer visibility and returns a boolean.
- `LParallaxLayer:render`: Enqueues render commands using explicit camera coordinates.
- `LParallaxLayer:renderAuto`: Enqueues render commands using the runtime camera.
- `LParallaxLayer:resetAutoscroll`: Resets the layer autoscroll offset to zero.
- `LParallaxLayer:setAutoscroll`: Sets the layer autoscroll velocity values.
- `LParallaxLayer:setBlendMode`: Sets the layer blend mode by string name.
- `LParallaxLayer:setClamp`: Sets clamp bounds for layer movement.
- `LParallaxLayer:setDepth`: Sets parallax depth for this object.
- `LParallaxLayer:setMotionStretch`: Sets the motion stretch settings for this layer.
- `LParallaxLayer:setOffset`: Sets the layer pixel offset for this object.
- `LParallaxLayer:setOpacity`: Sets layer opacity, clamped to 0..1.
- `LParallaxLayer:setRepeat`: Sets horizontal and vertical repeat flags.
- `LParallaxLayer:setScale`: Sets the layer scale factor for this object.
- `LParallaxLayer:setScrollFactor`: Sets layer scroll factor for this object.
- `LParallaxLayer:setTileSize`: Sets tile size for tiling for this object.
- `LParallaxLayer:setTiling`: Enables or disables the layer tiling mode.
- `LParallaxLayer:setTint`: Sets layer tint color for this object.
- `LParallaxLayer:setVisible`: Sets layer visibility for this object.
- `LParallaxLayer:setZ`: Sets the layer z order for this object.
- `LParallaxLayer:type`: Returns the Lua-visible type name for this parallax layer handle.
- `LParallaxLayer:update`: Advances parallax layer autoscroll by delta time.


#### LParallaxSet Type


##### Fields

- No documented fields.

##### Methods

- `LParallaxSet:addLayer`: Adds a parallax layer to this set handle.
- `LParallaxSet:getLayerZAt`: Returns z order for a layer by one-based index, or nil when out of range.
- `LParallaxSet:getName`: Returns this set name from this object.
- `LParallaxSet:isVisible`: Returns set visibility and returns a boolean.
- `LParallaxSet:layerCount`: Returns the number of layers in this set.
- `LParallaxSet:removeLayerAt`: Removes a layer by one-based index.
- `LParallaxSet:render`: Enqueues render commands for all visible set layers using explicit camera coordinates.
- `LParallaxSet:renderAuto`: Enqueues render commands for all visible set layers using the runtime camera.
- `LParallaxSet:setName`: Sets this parallax set name for this object.
- `LParallaxSet:setVisible`: Sets set visibility for this object.
- `LParallaxSet:sortByZ`: Sorts layers by z order on this object.
- `LParallaxSet:type`: Returns the Lua-visible type name for this parallax set handle.
- `LParallaxSet:update`: Updates all layers in this parallax set.

## References

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
