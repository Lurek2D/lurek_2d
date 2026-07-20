---
name: create-shader
description: "Load this skill when creating or modifying WGSL shaders or renderer shader-loader integration. Skip it for non-shader rendering logic, UI layouts, or visual asset edits only."
---

# create-shader

## Mission
- Create or modify WGSL shader code and integrate it with the existing renderer pipeline.

## Domain Knowledge
- Engine-owned WGSL lives under `src/render/shaders/`; demonstration shaders live under `content/examples/assets/shaders/`. A reusable renderer pass and an API example therefore have different ownership and wiring.
- WGSL bind-group indices, binding types, vertex attributes, uniform alignment, texture formats, and blend/depth state form a joint contract with wgpu pipeline creation in `src/render/`.
- Uniform structs must respect WGSL/Rust layout and padding rules; a shader that compiles can still read corrupted values when host layout, dynamic offsets, or color-space assumptions disagree.
- Full-screen/post-processing shaders must define sampling coordinates, alpha semantics, and render-target format intentionally; sprite or mesh shaders must preserve batching-compatible attributes unless the feature explicitly creates a new pipeline.
- Shader validation requires an exercised pipeline and visible effect. `cargo check` alone may not instantiate the exact bind layout, format, or draw path.
- Coordinate and color conventions cross the shader boundary: clip-space orientation, texture UV origin, premultiplied versus straight alpha, linear versus display color, and pixel-size uniforms must agree with the renderer pass that supplies them.
- Pipeline cache identity must include every state dimension that changes shader compatibility. Reusing a pipeline across incompatible formats, layouts, sample counts, or entry points can produce device validation errors far from shader creation.
- Shader hot reload or asset failure needs a defined fallback path so an invalid example shader does not corrupt shared renderer state or conceal the previous valid resource behind a partial update.

## Workflow
- Classify the shader as engine pipeline code or example asset, then trace the current WGSL entry points through pipeline descriptors, vertex/uniform structs, bind-group creation, target formats, and the Lua/API path that supplies parameters.
- Define host/WGSL layouts side by side before editing, including byte alignment, defaults, finite/range handling, texture/sampler pairing, alpha/blend mode, and fallback behavior when a resource is absent.
- Modify the owning shader and Rust loader together, keep existing batching/pipeline reuse unless a new pass is intentional, and create a focused example or evidence path that drives non-default parameters and makes the effect visually distinguishable.
- Run Rust/WGSL compilation and render tests, launch the exercising content, capture visual evidence, and inspect edge cases such as resize, transparent pixels, empty textures, extreme uniforms, and device validation errors.
- Compare the result on representative render targets and sampling conditions—opaque and transparent backgrounds, nearest and filtered textures, target resize, and repeated pipeline creation—to expose hidden format or cache assumptions.
- Inspect validation logs and the captured frame together: a visually plausible result with wgpu errors is not acceptable, and a clean device log with no distinguishable effect does not prove parameter wiring.

## References
- `contracts: src/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "WGSL shader src render pipeline" --profile engine --limit 10, cargo check, cargo test`
- `agent: developer`
- RAG: `WGSL shader src render pipeline`; `wgsl vertex fragment uniform texture`; `renderer shader loader pipeline layout`; `src/render/`; `src/render/shaders/`; `content/examples/assets/shaders/`; related specs in `docs/`
