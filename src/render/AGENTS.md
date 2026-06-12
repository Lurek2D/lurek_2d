# Render Module Contract

## Mission & Scope
- Own wgpu device/surface state, draw command resolution, textures, shaders, and frame submit.
- Keep render output deterministic from deferred draw intent.

## Files
- `context.rs`, `pipeline.rs`, `texture.rs`: GPU state and resources.
- `commands.rs`, `geometry.rs`, `text.rs`: CPU-side draw data.

## Rules
- Separate flat-color, textured, and text paths when pipeline state differs.
- Keep CPU tessellation bounds-checked before buffer upload.
- Handle surface loss, resize, and device errors without panics in normal runtime flow.

## Workflow
- Validate with `cargo test --test render_tests`.
