---
name: gpu-programming
description: "Load this skill when working on wgpu setup, RenderCommand flow, render passes, textures, shaders, or GPU validation errors. Skip it for font internals, Lua API design, or physics."
---
# gpu-programming

## Mission
- Own wgpu rendering flow, RenderCommand behavior, and shader integration.

## When To Load
- Change device or surface setup.
- Add or modify RenderCommand behavior.
- Work on textures, canvases, or shaders.
- Diagnose GPU validation errors.

## When To Skip
- Font internals.
- Lua API design.
- Physics logic.

## Domain Knowledge
- wgpu 22 is the only renderer backend. No OpenGL path, no Vulkan-direct path, no Metal-direct path.
- The `RenderCommand` enum in `src/render/renderer.rs` is the contract between game logic and the GPU. `on_render` callbacks push commands into `SharedState::pending_commands` during `lurek.draw()` / `lurek.draw_ui()`; after all callbacks return, `GpuRenderer::render_frame()` in `src/render/gpu_renderer.rs` processes the queue, batches compatible draw calls, and presents the swapchain surface.
- RenderPass count rule: one RenderPass per phase. Adding a mid-frame RenderPass for a single effect is almost always wrong — batch the draw into the existing transparent pass instead.
- Bind-group management is the most common GPU performance issue. Group textures by frequency-of-change: per-frame uniforms in group 0, per-batch textures in group 1, per-draw data in group 2.
- Buffer upload rule: upload via `wgpu::Queue::write_buffer` only when data changed since the last frame. Maintain a dirty flag or hash on the CPU side to skip redundant uploads.
- Shader compilation failures are fatal at startup. Keep the wgpu validation layer enabled in debug builds.
- Pipeline state objects are expensive to create. Create all pipelines at startup inside `GpuRenderer::new()` and cache them in the renderer struct.
- Texture format convention: all game textures must use `wgpu::TextureFormat::Rgba8UnormSrgb` unless explicitly documented otherwise. A format mismatch between texture and bind-group layout produces black output on some GPUs and a validation error on others — both symptoms are confusing to diagnose.
- Canvas is the mechanism for render-to-texture and post-processing. A `Canvas` stores logical dimensions; `GpuRenderer` manages the actual GPU texture.
- Sprite batching happens automatically in `render_frame()` when consecutive `RenderCommand::DrawSprite` commands share the same texture, blend mode, and shader. Break the batch only when necessary; sorting draw commands by texture before pushing them to `pending_commands` is the simplest way to maximize batch sizes and reduce bind-group switches.
- `src/render/shader.rs` exposes user WGSL shaders with a uniform variable table. Auto-uniform convention: declare a uniform name in Lua, the engine binds the value each frame before the draw call.
- Draw layer ordering is controlled by `src/render/draw_layer.rs`. Layers determine which RenderPass phase a command lands in.
- After render changes, run `cargo test --test graphics_tests` and check `tests/artifacts/current/` for screenshot regressions. Cargo test pass alone does not confirm visual correctness.
- Engine is 2D-only. Any proposal involving perspective projection, depth buffer, or 3D scene graph is out of scope.
## Companion File Index
- None.

## References
- src/render/
- src/lua_api/render_api.rs
- docs/specs/render.md
- tests/