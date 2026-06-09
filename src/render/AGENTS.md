# Render Contract

Covers work under `src/render/`.

## Mission
- Own the 2D GPU pipeline, render-command flow, batching, canvases, and shader integration.
- Keep render changes compatible with `wgpu` and visual regression checks.

## Scope
- `src/render/` renderer code and shader integration.
- Command flow, batching, canvases, and GPU execution.

## Local map
- `renderer.rs`, `gpu_renderer.rs`, and `shader.rs` are the main entry points.
- `RenderCommand` is the gameplay-to-GPU contract.

## Rules
- `wgpu` 22 is the only backend here.
- Route new draw behavior through command production and queue processing.
- Keep one render pass per phase unless a new phase is justified.
- Cache pipelines in startup code.
- Skip redundant buffer uploads with dirty-state tracking.
- Keep game textures on `Rgba8UnormSrgb` unless the exception is documented.
- Preserve sprite batching assumptions.
- Use canvases for render-to-texture and post-processing; keep the pass budget small.
- Blur, bloom, and glow should default to half-resolution canvases unless full resolution is needed.
- Keep shader binding conventions aligned with the existing Rust pipeline.
- This engine is 2D only.

## Workflow
- Read `docs/specs/render.md` and the relevant renderer entry points before changing command flow or shader bindings.
- After render changes, run the narrowest graphics-focused test first and inspect visual evidence when output changes.

## References
- `docs/specs/render.md`
- `src/render/renderer.rs`
- `src/render/gpu_renderer.rs`
- `src/render/shader.rs`
- `tests/output/`
