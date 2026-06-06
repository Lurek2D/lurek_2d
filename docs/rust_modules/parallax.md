# parallax

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

## Files

### [draw.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/parallax/draw.rs)

- Rasterises a single parallax layer into an ImageData bitmap.
- Applies tint, opacity, and visibility when drawing.
- Produces a solid-colour image sized to the requested dimensions.

### [layer.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/parallax/layer.rs)

- Single parallax layer definition with scroll factor, autoscroll, tiling, opacity, and tint.
- Carries draw-batch state so render submission stays separated from configuration.
- Computes camera-relative pixel offsets with optional scroll clamping.
- Delegates tile repetition to tile_iter for viewport coverage.
- Supports motion-stretch blur injection based on autoscroll velocity.
- Manages a small shader effect chain per layer for extra visual variation.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/parallax/mod.rs)

- Multi-layer parallax scrolling system with per-layer speed, tiling, and draw-batch accumulation.
- Provides preset constructors for common depth planes and tile iteration helpers for rendering.
- Keeps parallax drawing separate from the world and camera systems.

### [presets.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/parallax/presets.rs)

- Ready-made parallax layer constructors for common depth planes.
- Covers far background, mid background, and foreground fog presets.
- Bakes scroll factor, repeat, z-order, opacity, and blend mode into each preset.

### [render.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/parallax/render.rs)

- Converts parallax layer state into flat RenderCommand lists for the renderer.
- Batches tile positions into draw-image sequences with color and blend pre-applied.
- Bridges parallax camera math to the GPU submission pipeline.

### [tile_iter.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/parallax/tile_iter.rs)

- Computes visible tile positions for repeating parallax layers inside a screen rect and cull margin.
- Walks one axis at a time and combines X and Y into a full grid with bounded growth.
- Emits only the single origin position for non-repeating layers.
- Supplies the viewport coverage iterator used by parallax rendering.
