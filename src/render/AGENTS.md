# Render Contract

This file adds local rules for work under `src/render/`.

## Mission
- Own the 2D GPU pipeline, render-command flow, batching, canvases, and shader integration.
- Keep render changes compatible with the existing `wgpu` backend and visual regression checks.

## Local rules
- `wgpu` 22 is the only renderer backend here. Do not add parallel OpenGL, Vulkan-direct, or Metal-direct paths.
- Treat `RenderCommand` as the contract between gameplay code and GPU execution. New draw behavior should enter through command production and queue processing, not ad hoc renderer side channels.
- Keep one render pass per phase unless a new phase is clearly justified. Single-effect extra passes are usually a batching mistake.
- Create and cache pipelines in renderer startup code. Do not rebuild pipeline state objects every frame.
- Skip redundant buffer uploads. Use dirty-state tracking before calling `Queue::write_buffer`.
- Keep game textures on `Rgba8UnormSrgb` unless the exception is documented in code and spec.
- Preserve sprite batching assumptions: texture, blend mode, and shader compatibility should stay easy to group across consecutive commands.
- Use canvases for render-to-texture and post-processing. Each canvas draw adds another GPU pass, so integrated-hardware effects should stay within a small pass budget.
- Blur, bloom, and glow style effects should default to half-resolution canvases unless a full-resolution pass is visually necessary.
- Keep shader binding conventions aligned with the existing Rust pipeline. Do not invent binding slots that the renderer does not bind.
- This engine is 2D-only. Perspective cameras, depth-buffer-driven scene design, and 3D scene graph work are out of scope here.

## Workflow
- Read `docs/specs/render.md` and the relevant renderer entry points before changing command flow or shader bindings.
- After render changes, run the narrowest graphics-focused test first and inspect visual evidence when the change affects output rather than only compile-time structure.

## References
- `docs/specs/render.md`
- `src/render/renderer.rs`
- `src/render/gpu_renderer.rs`
- `src/render/shader.rs`
- `tests/output/`
