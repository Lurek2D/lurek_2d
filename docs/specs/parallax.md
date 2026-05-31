# parallax

## TL;DR

- Manages layered scroll depth, autoscrolling, and tiling.
- Adds motion blur.

## General Info

- Module group: `Feature Systems`
- Source path: `src/parallax/`
- Binding: `src/lua_api/parallax_api.rs`
- Namespace: `lurek.parallax`
- Lua API surface: `3` functions, `2` types, `48` methods
- Rust test path(s): tests/rust/unit/parallax_tests.rs
- Lua test path(s): tests/lua/unit/test_parallax_core_unit.lua, tests/lua/integration/test_parallax_camera.lua

## Summary

This module provides a multi-layered parallax scrolling system that creates a sense of depth in 2D environments. By assigning distinct scroll factors, z-orders, and offsets to individual planes, layers move relative to the camera at varying speeds. The system supports autonomous autoscrolling for moving skies, as well as scroll clamping to restrict layer movement within designated map boundaries.

To ease implementation, the module provides ready-made depth templates, such as distant skies and foreground fog. It tiles textures across the viewport using smart visibility logic that avoids edge gaps. Additionally, layers can incorporate motion-based stretch blur driven by velocity and custom shader chains to create stylized visual atmosphere.

## Imports

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### draw.rs

- Rasterises a single parallax layer into an ImageData bitmap.
- Applies tint, opacity, and visibility when drawing.
- Produces a solid-colour image sized to the requested dimensions.

### layer.rs

- Single parallax layer definition with scroll factor, autoscroll, tiling, opacity, and tint.
- Carries draw-batch state so render submission stays separated from configuration.
- Computes camera-relative pixel offsets with optional scroll clamping.
- Delegates tile repetition to tile_iter for viewport coverage.
- Supports motion-stretch blur injection based on autoscroll velocity.
- Manages a small shader effect chain per layer for extra visual variation.

### mod.rs

- Multi-layer parallax scrolling system with per-layer speed, tiling, and draw-batch accumulation.
- Provides preset constructors for common depth planes and tile iteration helpers for rendering.
- Keeps parallax drawing separate from the world and camera systems.

### presets.rs

- Ready-made parallax layer constructors for common depth planes.
- Covers far background, mid background, and foreground fog presets.
- Bakes scroll factor, repeat, z-order, opacity, and blend mode into each preset.

### render.rs

- Converts parallax layer state into flat RenderCommand lists for the renderer.
- Batches tile positions into draw-image sequences with color and blend pre-applied.
- Bridges parallax camera math to the GPU submission pipeline.

### tile_iter.rs

- Computes visible tile positions for repeating parallax layers inside a screen rect and cull margin.
- Walks one axis at a time and combines X and Y into a full grid with bounded growth.
- Emits only the single origin position for non-repeating layers.
- Supplies the viewport coverage iterator used by parallax rendering.

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
