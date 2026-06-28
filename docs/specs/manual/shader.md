# shader manual spec overlay

## TL;DR

`shader` owns the user-facing WGSL shader constructor surface. It validates fragment shader source for an explicit target before other modules bind the handle into draw, post-fx, image, overlay, particle, or light workflows.

## Summary

- WGSL is the only supported user shader language.
- `lurek.shader.new(code, { target = ... })` is the canonical constructor for target-aware runtime shaders.
- `lurek.render.newShader(code)` remains a compatibility path for `target = "draw"`.
- Target validation is strict: post-fx, image, overlay, particle, and light APIs reject shaders created for another target.
- The current implementation establishes the shared API, validation, example WGSL assets, custom post-fx execution, offline `ImageData` GPU processing through a render-owned headless readback path, render-time particle shader specialization, and custom light contribution pipeline replacement.

## Notes

- Fullscreen targets (`postfx`, `image`, `overlay`) share the same input contract: source color, uv, pixel position, resolution, and texel size.
- `image` shaders run as an off-screen fullscreen pass over RGBA8 `ImageData` and read the result back into a new `ImageData`.
- Particle targets add color, uv, local/world position, velocity, normalized age, lifetime, seed, and optional sampled texture color. Textured and untextured particles share the same user WGSL contract; untextured particles receive the particle color as `sampled_color`.
- Light targets add world/light position, normal-map contribution hint, normalized distance, radius, intensity, shadow factor, ambient color, and direction/spot data. Shadow geometry and occluders remain engine-owned.
- Runtime custom shaders are fragment-only; arbitrary vertex and compute shader execution is outside this API.

## Architecture Links

- docs/architecture/effects-particles-overlay-plan.md
- docs/architecture/render-pipeline.md
