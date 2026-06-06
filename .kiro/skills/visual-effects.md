---
inclusion: manual
---

# visual-effects

## Mission
Own the canvas render-to-texture post-processing pipeline, WGSL shader patterns, auto-uniform conventions, and per-frame performance budgets for visual effects.

## When To Use
- Adding a post-processing effect (blur, bloom, CRT, colour correction).
- Writing a custom WGSL fragment shader for screen-space effects.
- Chaining multiple render passes via canvas objects.
- Optimizing visual effect frame time.

## When To Skip
- Basic sprite/image drawing — use `gpu-programming` skill instead.
- 3D rendering — out of scope for Lurek2D.

## Rules

### Adding a Post-Processing Effect (step-by-step)
1. Create a `Canvas` via `lurek.render.newCanvas(w, h)` — typically half screen resolution for blur or bloom.
2. Draw the scene into it using `RenderCommand::DrawToCanvas`.
3. Create a `Shader` via `lurek.render.newShader(wgsl_source)`.
4. Draw the canvas back to screen via `lurek.render.drawCanvas(canvas, 0, 0)` with the shader active.

See `content/games/showcase/postfx_demo/main.lua` for a working example of 10 chained effects (bloom, blur, CRT, palette swap).

### WGSL Binding Convention
- `@group(0) @binding(0)` — source texture (engine-provided).
- `@group(0) @binding(1)` — sampler (engine-provided).
- Auto-uniforms (set via `shader:setUniform("name", value)`) — `@group(1)` starting at `@binding(0)`.

Do not invent new binding slots without updating `src/render/shader.rs` and the bind group layout in `src/render/postfx_pipeline.rs`.

### Half-Resolution Rule
- Bloom, blur, and glow passes must operate on a canvas at half the render target resolution (e.g., 640×360 for a 1280×720 game).
- Full-resolution multi-pass blur chains are the fastest way to break the 60 FPS budget on integrated GPUs.

### Pass Budget
- Budget 2–3 GPU passes maximum for combined effects on integrated hardware.
- Chain effects by compositing canvas-to-canvas at half resolution before the final full-resolution composite.

### CRT / Scanline Effects
- Use a fragment shader reading `frag_uv.y` and applying a periodic darkening or distortion formula.
- Copy the binding layout from `postfx_demo` — do not write from scratch, because the binding slot convention must match what the Rust pipeline expects.

### Palette Swap / Colour Grading
- Load a 256×1 or 16×16 LUT texture.
- Bind it at `@group(0) @binding(2)` (check `src/render/shader.rs` for multi-texture support first).
- Sample using the greyscale value of the source pixel as the UV coordinate.

### Canvas Lifetime
- Canvases are created once and reused across frames — never create a new canvas per frame.
- `src/render/image_effect.rs` and `src/render/postfx_pipeline.rs` own the Rust side. Changes to effect parameters, canvas lifetime, or shader reuse must respect the resource lifetime rules in those files.

## References
- `src/render/`
- `docs/specs/render.md`
- `content/games/showcase/postfx_demo/`
