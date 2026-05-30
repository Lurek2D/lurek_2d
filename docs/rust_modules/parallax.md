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

It allows developers to easily create a deep sense of 2D perspective by stacking multiple textured layers that scroll at varying speeds relative to camera movement. The core of this system is the `ParallaxLayer`, which defines a single depth plane. By assigning a scroll speed multiplier to each layer (where 0.0 represents a distant static background and 1.0 moves precisely with the camera), the system automatically handles the complex camera-relative pixel offset computations necessary for convincing parallax effects. Layers are sorted back-to-front by their assigned Z-depth, with the lowest scroll factors naturally appearing furthest away.

In addition to camera-driven motion, the module features an independent auto-scroll mechanic. This allows layers to maintain a constant baseline velocity regardless of player movement, which is essential for animating ambient atmospheric elements like drifting clouds, flowing water, or moving starfields. The rendering pipeline of the `parallax` module is deeply optimized. It automatically computes `ParallaxDrawBatch`es, utilizing a sophisticated `tile_iter` algorithm to calculate the precise grid of visible repeating tiles required to fill the viewport (plus a safety cull margin). This avoids allocating vast repeating grids and instead generates lightweight, stateless `RenderCommand` sequences for GPU submission.

The visual fidelity of parallax layers can be further customized per-layer. It supports dynamic opacity adjustments, RGBA tinting, and various accumulation blend modes (such as additive or screen). Advanced visual features include a motion-stretch blur effect, which procedurally stretches layer tiles based on their auto-scroll velocity to simulate high-speed motion. For ease of use, the module includes a `presets` system offering ready-made configurations for common depth planes (e.g., far backgrounds, mid-grounds, and foreground fog). Grouped management is provided via `ParallaxSet`s, and the entire feature suite is fully exposed to the Lua environment through the `lurek.parallax.*` API.

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
