---
name: visual-effects
description: "Load this skill when building shader or post-process effects like bloom, blur, CRT, distortion, or palette swap. Skip it for basic drawing or out-of-scope 3D rendering."
---
# visual-effects

## Use when
- Adding a post-processing effect.
- Writing a custom WGSL fragment shader for screen-space effects.
- Chaining multiple render passes via canvas objects.
- Optimizing visual effect frame time.

## Avoid when
- Basic sprite/image drawing â€” use `gpu-programming` skill.
- 3D rendering â€” out of scope for Lurek2D.

## Repo rules
- How to add a new post-processing effect: create a `Canvas` via `lurek.render.newCanvas(w, h)` at the desired resolution â€” typically half the screen resolution for blur or bloom; draw the scene into it using a `RenderCommand::DrawToCanvas`; create a `Shader` via `lurek.render.newShader(wgsl_source)` with the desired WGSL fragment code; draw the canvas back to screen via `lurek.render.drawCanvas(canvas, 0, 0)` with the shader active. See `content/games/showcase/postfx_demo/main.lua` for a working example of 10 chained effects including bloom, blur, CRT, and palette swap.
- WGSL shader conventions in this engine: the engine provides `@group(0) @binding(0)` as the source texture and `@group(0) @binding(1)` as a sampler. Auto-uniforms`) are bound at `@group(1)` starting at `@binding(0)`.
- Half-resolution rule: bloom, blur, and glow passes should operate on a canvas at half the render target resolution. This halves the fragment shader invocations and is usually imperceptible quality-wise.
- Pass budget: each `Canvas` draw is an additional GPU pass. Budget 2â€“3 passes maximum for combined effects on integrated hardware.
- CRT and scanline effects are achieved via a fragment shader that reads `frag_uv.y` and applies a periodic darkening or distortion formula. The `postfx_demo` includes a working CRT shader â€” copy its binding layout rather than writing from scratch, because the binding slot convention must match what the Rust pipeline expects.
- Palette swap / colour grading: load a 256Ă—1 or 16Ă—16 LUT texture, bind it as a second texture at `@group(0) @binding(2)`, and sample it using the greyscale value of the source pixel as the UV coordinate. Check `src/render/shader.rs` for whether multi-texture bindings are already supported before adding a new slot.
- `src/render/image_effect.rs` and `src/render/postfx_pipeline.rs` own the Rust side of the post-processing pipeline. Changes to effect parameters, canvas lifetime, or shader reuse must respect the resource lifetime rules in those files.

## Checks
- `Run the narrowest relevant validation for the touched files or workflow.`

## References
- `src/render/`
- `docs/specs/render.md`
- `content/games/showcase/postfx_demo/`

