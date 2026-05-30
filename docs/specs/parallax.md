# parallax

## TL;DR

- The `parallax` module provides layered background motion with depth-based scrolling, auto-scroll, and render batching for 2D scenes.

## General Info

- Module group: `Feature Systems`
- Source path: `src/parallax/`
- Binding: `src/lua_api/parallax_api.rs`
- Namespace: `lurek.parallax`
- Lua API surface: `3` functions, `2` types, `48` methods
- Rust test path(s): tests/rust/unit/parallax_tests.rs
- Lua test path(s): tests/lua/unit/test_parallax_core_unit.lua, tests/lua/integration/test_parallax_camera.lua

## Summary

The `parallax` module controls layered background motion for 2D scenes. Its main role is to make depth readable by letting distant and near planes move at different rates while the camera moves.

Functionally, it gives one shared model for background layers: per-layer speed response, visibility, color treatment, repeat behavior, and optional automatic drift. This lets teams build sky bands, fog, distant silhouettes, and front overlays with stable behavior rules.

The module also keeps rendering practical for runtime use. It computes only visible repeated tiles for the current view and emits batch-ready draw data, so scrolling backdrops stay predictable in memory and frame cost.

Preset layers improve iteration speed, while direct per-layer tuning keeps art control flexible. In practice, `lurek.parallax` is the background-depth contract: compose layers, animate them coherently, and render them through one consistent API.

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

- `lurek.parallax.newLayer`: Creates a parallax layer from an options table.
- `lurek.parallax.newPresetLayer`: Creates a parallax layer from a named preset and texture image.
- `lurek.parallax.newSet`: Creates an empty parallax layer set.

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

- Lua-side wrapper for an ordered parallax layer set.

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
