---
name: create-shader
description: Create or update shader code which is used by GPU to render things.
---

# GOAL
- Write or modify GPU shader code (WGSL) and integrate it into the 2D renderer.

# INPUTS REQUIRED
- Shader effect description (e.g., bloom, blur, CRT)
- Target render pass
= User must describe the visual effect desired
- Agent must collect current wgpu render pipeline configurations

# STEPS TO DO
1. Load skills: gpu-programming, visual-effects.
2. Write the `.wgsl` shader file ensuring strict WebGPU/wgpu 22 compatibility.
3. Update the relevant `RenderCommand` or pipeline setup in `src/` to compile and bind the new shader.
4. Execute `cargo check`. If the compiler throws WGSL validation errors, fix the shader code in step 2.
5. Execute `cargo test`. Ensure 100% of render tests still pass.
6. Execute a standalone demo locally that utilizes the new shader. Verify visual output. If rendering fails, adjust uniforms and repeat step 4.

# OUTPUTS PROVIDED
- `.wgsl` shader file
- Modified Rust rendering code
- Lua test script

# SUCCESS CRITERIA
- `cargo check` exits with code 0 (0 compilation/WGSL validation errors).
- `cargo test` exits with code 0 (0 broken render pipelines).

# ANIT PATTERNS
- Using features not supported by wgpu 22 or the target WebGPU standard.
- Hardcoding uniforms that should be configurable via the Lua API.

# REFERENCES
- skills: gpu-programming, visual-effects, rust-coding
- tools: cargo check, cargo test
- agent: Developer
