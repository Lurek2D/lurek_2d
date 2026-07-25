# Render Module Contract

## Mission & Scope
- Own wgpu device/surface state, draw command resolution, textures, shaders, and frame submit.
- Keep render output deterministic from deferred draw intent.

## Files
- `renderer.rs`, `gpu_state.rs`, `gpu_resources.rs`: Main renderer and GPU state.
- `gpu_pipeline.rs`, `gpu_*_replay.rs`, `gpu_*_pass.rs`: GPU pipelines and command replay.
- `shape.rs`, `mesh.rs`, `canvas.rs`, `software_capture.rs`: CPU draw data and capture.
- `shaders/`: WGSL sources.

## Rules
- Separate flat-color, textured, and text paths when pipeline state differs.
- Keep CPU tessellation bounds-checked before buffer upload.
- Handle surface loss, resize, and device errors without panics in normal runtime flow.

## Workflow
- Validate with `cargo test --test render_tests`.
