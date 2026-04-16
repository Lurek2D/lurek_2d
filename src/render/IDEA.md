# IDEA.md — `render` module

> Migrated from `ideas/features/graphics.md` + `ideas/performance/02-gpu-rendering.md`.
> Status checked against `src/render/` and `src/lua_api/render_api.rs` (also `graphic_api.rs`).
> Lua namespace: `lurek.gfx` / `lurek.draw`.

---

## Features

### ✅ DONE — Gradient Fills (Linear / Radial / Horizontal / Vertical)
**Source**: features/graphics.md — Feature Gaps #2 / Suggestions #3

Implemented as `lurek.graphics.drawGradientRect(x, y, w, h, r1,g1,b1,a1, r2,g2,b2,a2, dir)`.
Direction accepts `"horizontal"`, `"vertical"`, and `"radial"`.
- `RenderCommand::DrawGradientRect` in `src/render/renderer.rs`
- GPU tessellation in `src/render/gpu_renderer.rs`
- Lua binding in `src/lua_api/render_api.rs`

---

### ✅ DONE — Render Layers / Groups
**Source**: features/graphics.md — Feature Gaps #4 / Suggestions #2

Implemented as `lurek.graphics.pushLayer(id, alpha, blend)` / `lurek.graphics.popLayer(id)`.
Named layer visibility and Z-order: `setLayer(name)`, `setLayerVisible(name, bool)`, `setLayerZOrder(name, z)`.
- `RenderCommand::PushLayer` / `PopLayer` in `src/render/renderer.rs`
- `DrawLayer` struct in `src/render/draw_layer.rs`
- Lua bindings in `src/lua_api/render_api.rs`

---

### ✅ DONE — Stencil Buffer Operations
**Source**: features/graphics.md — Feature Gaps #9

Full wgpu stencil pipeline support:
- `lurek.graphics.stencil(fn, action, value)` — `StencilBegin`/`StencilEnd` bracket
- `lurek.graphics.setStencilTest(compare, value)` — `SetStencilTest` command
- `CompareMode`, `StencilAction`, `StencilMode` types in `src/render/renderer.rs`

---

### ❌ TODO — Screenshot to ImageData (CPU Readback)
**Source**: features/graphics.md — Feature Gaps #8

`saveScreenshot` writes a PNG to disk only. A `screenshotToImage()` call returning
an in-memory `lurek.image.ImageData` object for CPU-side processing does not exist yet.
The GPU readback path already exists in `app.rs`; needs a Lua callback pattern to
deliver pixels without an extra disk round-trip.

---

### ❌ TODO — Anti-Aliased Lines and Shapes
**Source**: features/graphics.md — Feature Gaps #6

Shapes rasterized without anti-aliasing. Jagged edges visible for rotated rectangles
and small circles. Requires either MSAA pipeline variant or geometry-shader AA strips.

---

### 🤔 CONSIDER — Module Split (render/core, text, sprite, shader, shape)
**Source**: features/graphics.md — Structural Issues

The render module has 13 source files and 60+ Lua functions — one of the largest in the engine.
Consider splitting into sub-modules for maintainability. Requires Architect decision before
any refactoring.

---

## Performance

### ✅ DONE — Frustum / Viewport Culling
**Source**: performance/02-gpu-rendering.md — Opportunity 1

Axis-aligned viewport cull added to `GpuRenderer::render_frame` in `src/render/gpu_renderer.rs`.
`DrawImage`, `DrawImageEx`, `DrawQuad`, and `Rectangle` commands skip tessellation when their
AABB does not intersect the current viewport rectangle. Applies only to commands where a tight
AABB is cheap to compute; complex paths (Polygon, Polyline) are left unchecked.

---

### ❌ TODO — GPU Instancing for Repeated Sprites (HIGH, Medium Effort)
**Source**: performance/02-gpu-rendering.md — Opportunity 2, Solution B

Drawing N identical sprites produces N separate tessellations + N draw calls.
GPU instancing with a single instance buffer would reduce particle-style sprite sets
to 1 draw call with 1 quad template. Requires a new wgpu pipeline variant and an
instance-buffer vertex layout.

---

### ❌ TODO — Geometry Cache / Static Draw Mode (Medium Effort)
**Source**: performance/02-gpu-rendering.md — Opportunity 3

Static background geometry is re-tessellated from `RenderCommand` every frame. A cache
mode would store vertex data across frames and skip re-tessellation:
```lua
local bg = lurek.gfx.newGeometryCache()
bg:begin() ... bg:finish()
function lurek.render() bg:draw() end
```

---

### 🔇 LOW — Dynamic Circle LOD
**Source**: performance/02-gpu-rendering.md — Bottlenecks table

32 segments for all circles regardless of screen size. Adaptive LOD based on rendered
pixel area would save tessellation for tiny circles. Low priority — circles are rarely a bottleneck.

---

### 🔇 LOW — CPU Transform Stack (Per-Vertex Matrix Composition)
**Source**: performance/02-gpu-rendering.md — Bottlenecks table

Transforms composed per vertex on CPU. Pushing to GPU push constants or a UBO would
reduce bus traffic. Only meaningful at very high vertex counts. Measure first.
