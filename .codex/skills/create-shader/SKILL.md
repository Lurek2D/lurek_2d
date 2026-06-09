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
- Write or update the `.wgsl` shader file under `assets/shaders/` and keep the effect name aligned with the renderer loader.
- Update the relevant render pipeline or shader loader in `src/render/` so the new shader is compiled and bound correctly.
- Execute `cargo check`. If the compiler throws WGSL validation errors, fix the shader code and rerun the check.
- Execute `cargo test`. Make sure the render tests still pass.
- Execute a standalone demo or evidence path that uses the new shader and verify the visual output. If rendering fails, adjust uniforms or pipeline state and repeat the validation step.

## Outputs
- `.wgsl` shader file under `assets/shaders/`
- Modified Rust rendering code
- Evidence or test script that exercises the shader

## Success criteria
- [ ] `cargo check` exits with code 0 (0 compilation/WGSL validation errors).
- [ ] `cargo test` exits with code 0 (0 broken render pipelines).

## Stop conditions
- Using features not supported by wgpu 22 or the target WebGPU standard.
- Hardcoding uniforms that should be configurable via the Lua API.

## References
- `contracts: src/AGENTS.md, src/render/AGENTS.md`
- `tools: cargo check, cargo test`
- `agent: developer`


