---
name: create-shader
description: "Create or update shader code which is used by GPU to render things."
---
# create-shader

## Goal
- Write or modify GPU shader code (WGSL) and integrate it into the 2D renderer.

## Required inputs
- Shader effect description (e.g., bloom, blur, CRT)
- Target render pass
- User must describe the visual effect desired
- Agent must collect current wgpu render pipeline configurations

## Profile hint
- `developer`

## Read these contracts
- `src/AGENTS.md`
- `src/render/AGENTS.md`

## Steps
- Read the listed contracts before changing shader code, render passes, or bindings.
- Write the `.wgsl` shader file ensuring strict WebGPU/wgpu 22 compatibility.
- Update the relevant `RenderCommand` or pipeline setup in `src/` to compile and bind the new shader.
- Execute `cargo check`. If the compiler throws WGSL validation errors, fix the shader code in step 2.
- Execute `cargo test`. Ensure 100% of render tests still pass.
- Execute a standalone demo locally that utilizes the new shader. Verify visual output. If rendering fails, adjust uniforms and repeat step 4.

## Outputs
- `.wgsl` shader file
- Modified Rust rendering code
- Lua test script

## Success criteria
- [ ] `cargo check` exits with code 0 (0 compilation/WGSL validation errors).
- [ ] `cargo test` exits with code 0 (0 broken render pipelines).

## Stop conditions
- Using features not supported by wgpu 22 or the target WebGPU standard.
- Hardcoding uniforms that should be configurable via the Lua API.

## References
- `contracts: src/AGENTS.md, src/render/AGENTS.md`
- `tools: cargo check, cargo test`
- `agent: Developer`


