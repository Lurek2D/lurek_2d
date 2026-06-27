# shader manual spec overlay

## TL;DR

`shader` owns the user-facing WGSL shader constructor surface. It validates fragment shader source for an explicit target before other modules bind the handle into draw, post-fx, image, overlay, particle, or light workflows.

## Summary

- WGSL is the only supported user shader language.
- `lurek.shader.new(code, { target = ... })` is the canonical constructor for target-aware runtime shaders.
- `lurek.render.newShader(code)` remains a compatibility path for `target = "draw"`.
- Target validation is strict: post-fx, image, overlay, particle, and light APIs reject shaders created for another target.
- The current implementation establishes the shared API, validation, example WGSL assets, custom post-fx execution, and offline `ImageData` GPU processing through a render-owned headless readback path.
- Particle shader rendering and light contribution pipeline replacement are staged behind the same target contracts; their public bindings validate targets and preserve shader selections while renderer specialization continues.

## Notes

- Fullscreen targets (`postfx`, `image`, `overlay`) share the same input contract: source color, uv, pixel position, resolution, and texel size.
- `image` shaders run as an off-screen fullscreen pass over RGBA8 `ImageData` and read the result back into a new `ImageData`.
- Particle and light targets add scalar/vector inputs for render-time visual data.
- Runtime custom shaders are fragment-only; arbitrary vertex and compute shader execution is outside this API.

## Architecture Links

- docs/architecture/effects-particles-overlay-plan.md
- docs/architecture/render-pipeline.md
