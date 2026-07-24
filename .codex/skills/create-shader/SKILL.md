---
name: create-shader
description: "Load this skill when creating or modifying WGSL shaders or renderer shader-loader integration. Skip it for non-shader rendering logic, UI layouts, or visual asset edits only."
---

# create-shader

## Mission
- Create or modify WGSL shader code and integrate it with the existing renderer pipeline.

## Domain Knowledge
- Engine WGSL files live under `src/render/shaders/`.
- Example WGSL files live under `content/examples/assets/shaders/`.
- Rust pipeline code lives under `src/render/`.
- WGSL entry points must match pipeline descriptors.
- Bind-group index and binding type must match Rust code.
- Vertex locations and formats must match Rust vertex structs.
- Uniform layout and padding must match on both sides.
- Texture format, sample count, depth state, and blend state are pipeline inputs.
- Pipeline cache keys include every compatibility input.
- Clip-space direction and UV origin are explicit conventions.
- Alpha mode is straight or premultiplied.
- Color calculations identify linear and display color space.
- Full-screen shaders define sampling coordinates and target format.
- Existing sprite and mesh shaders preserve batching attributes.
- `cargo check` does not prove runtime pipeline creation.
- A valid shader needs a visible exercised effect and clean wgpu logs.
- Failed reload keeps a known valid fallback.
- Built-in render pipelines use `vs_main` as the vertex entry point.
- Engine viewport data occupies `@group(0) @binding(0)` in generated custom shader wrappers.
- Custom uniform buffers are declared after engine-owned bindings and follow the ordered uniform signature.
- Color, textured, particle, textured-particle, and light shaders have different fragment-input contracts.
- CPU tessellation must be bounds-checked before vertex or index upload.
- Surface loss, resize, and device errors are normal recovery paths, not panic paths.
- The focused Rust target for renderer behavior is `cargo test --test render_tests`.

## Workflow
1. Read the source contract.
2. Classify the shader as engine-owned or example-owned.
3. Trace WGSL entry points to pipeline creation.
4. List vertex, uniform, bind-group, texture, blend, depth, and sample contracts.
5. Write host and WGSL layouts side by side.
6. Define alpha, UV, coordinate, and color-space rules.
7. Update WGSL and Rust loader code together.
8. Update the pipeline cache key when compatibility inputs change.
9. Keep existing batching unless a new pass is required.
10. Add a focused example or evidence path.
11. Drive at least one non-default parameter.
12. Run Rust and WGSL compilation.
13. Launch the exercising content.
14. Test resize, transparent pixels, empty textures, and extreme uniforms.
15. Test repeated pipeline creation.
16. Inspect wgpu validation logs.
17. Capture visual evidence with a clear effect.

## References
- `contracts: src/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "WGSL shader src render pipeline" --profile engine --limit 10, cargo check, cargo test`
- `agent: developer`
- RAG: `WGSL shader render pipeline <pass>`; inspect the WGSL owner, host structs, bind/pipeline descriptors, target format, and exercising example/evidence path.
