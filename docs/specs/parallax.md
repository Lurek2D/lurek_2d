<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/parallax.md or source docstrings instead. -->

# parallax

## TL;DR

- Manages layered scroll depth, autoscrolling, and tiling.
- Adds motion blur.

## General Info

- Module group: `Feature Systems`
- Source path: `src/parallax`
- Binding: `src/lua_api/parallax_api.rs`
- Namespace: `lurek.parallax`
- Lua API surface: `4` functions, `2` types, `52` methods
- User-facing: `true`
- Plugin tier: `tier_2_plugin`

## Summary

- The `parallax` module is the layered-background surface for projects that want depth and atmospheric motion without full 3D simulation.
- Layer definitions, presets, tiling behavior, and render helpers let several planes move at different camera-relative rates and create a stronger sense of scene depth.
- Drawing support and image export matter because parallax content may be used both in live rendering and in tooling or preview workflows.
- The module is useful for skies, distant scenery, decorative world layers, and motion-rich menu or transition backdrops that should stay cheaper and simpler than full interactive geometry.
- Camera-relative speed policy matters because background depth reads differently across scenes.
- It also keeps background motion readable across scene scales and camera styles.
- Read it as the place where depth-illusion backgrounds become reusable scene content instead of a one-off renderer trick.

This module primarily collaborates with `image`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/parallax`
- Owning tier: `Feature Systems`
- Plugin tier: `tier_2_plugin`
- Lua binding owner: `src/lua_api/parallax_api.rs`
- Referenced engine modules: `image`, `render`, `runtime`

## Imports

- `image`: Imports or references `src/image/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Feature Systems` into `Core Runtime`.

## Source Files

### draw.rs

- `src/parallax/draw.rs` rasterizes a single `ParallaxLayer` into `ImageData` for export, previews, or tooling use.
- It owns only the bitmap fill path, translating visibility, tint, and opacity into a flat image without tiling logic.
- Read it when parallax image export, solid-fill preview behavior, or layer-to-bitmap bridging needs to change.

### layer.rs

- `src/parallax/layer.rs` owns the `ParallaxLayer` model and the batch-building logic that drives parallax rendering.
- It stores scroll factors, offsets, autoscroll, tiling, tint, opacity, z depth, clamps, and shader effects together.
- `ParallaxDrawBatch` and `ParallaxLayerStats` live here because both are derived directly from layer state.
- Camera-relative offsets, tile sizing, motion-stretch scaling, and visible tile collection are coordinated in this file.
- The file exposes update, configuration, statistics, and batch-construction helpers without talking to the renderer.
- Tile enumeration is delegated to `tile_iter`, while command flattening and bitmap export stay in sibling helper files.
- Read it when scroll behavior, effect chaining, batch contents, layer telemetry, or parallax state ownership changes.

### mod.rs

- `src/parallax/mod.rs` is the module index for parallax state, draw helpers, presets, rendering, and tile iteration.
- It declares files for layer ownership, renderer bridging, bitmap export, presets, and tiled viewport coverage helpers.
- This file reexports `ParallaxLayer` and `ParallaxDrawBatch` so callers can use the subsystem without deep imports.
- No scrolling state or camera math lives here; it only defines the public boundary and file ownership map.
- Read this index first when tracing parallax features, because it shows where layer logic ends and helpers begin.
- Changes here affect module reachability and API shape, not scroll behavior, batching, or render-command generation.

### presets.rs

- `src/parallax/presets.rs` defines ready-made `ParallaxLayer` constructors for common background and fog depth planes.
- It owns opinionated defaults for scroll factors, repeat flags, z ordering, opacity, blend modes, and motion stretch.
- Read it when stock parallax layer recipes or their visual tuning should change without touching core layer behavior.

### render.rs

- Owns the parallax render implementation for the parallax subsystem and keeps related runtime rules local here.
- Keeps parallax layers, draw state, and render-facing helpers so helpers stay close to invariants this file updates.
- Defines how parallax render data is validated, transformed, or stored before neighboring systems consume it.
- Separates parallax render behavior from Lua bindings, tests, and sibling owners so integration stays readable.

### tile_iter.rs

- `src/parallax/tile_iter.rs` computes visible tile origins for repeating parallax layers inside a screen-sized window.
- It owns cull-margin expansion, axis stepping, repeat handling, and the hard cap that prevents runaway tile growth.
- Non-repeating layers also pass through here, returning a single origin so batch builders use one tiling code path.
- Read it when visible tile coverage, repeat math, cull bounds, or batching limits for parallax layers need changes.



## Lua API Ref

### Functions

- `lurek.parallax.newLayer(opts) -> LParallaxLayer`: Creates a parallax layer from an options table.
- `lurek.parallax.newLayerSet(name, layerDefs, opts?) -> LParallaxSet`: Creates a parallax layer set from an array of layer definition tables.
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
- `LParallaxLayer:getShader() -> LShader`: Returns the draw-target shader bound to this parallax layer, if any.
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
- `LParallaxLayer:setShader(shader?) -> nil`: Binds a draw-target shader to this parallax layer's generated render commands. Pass nil to clear.
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

## Examples

- `content/examples/parallax.lua` (present)

## Architecture Links

- Intentionally empty.

## Notes

- `LParallaxLayer:setShader(shaderOrNil)` accepts only draw-target shaders created through `lurek.render.newShader`. Parallax stores the `ShaderKey` with layer state and wraps generated background draw commands; WGSL validation, pipeline creation, and GPU execution remain owned by `render`.
- Existing named effect chains stay separate from custom `LShader` binding. They continue to describe post-process-style effect names, while `setShader` is the direct custom fragment material path for procedural/tinted background layers.
