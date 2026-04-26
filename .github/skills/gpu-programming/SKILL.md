---
name: gpu-programming
description: "Load this skill when working with the Lurek2D GPU rendering pipeline: wgpu device/surface setup, RenderCommand queue, render passes, texture management, custom WGSL shaders, blend modes, canvas render-to-texture, or transform stacks. Also covers profiling GPU frame time and diagnosing wgpu validation errors. Skip it for font rasterization details, Lua API design, or physics."
---
# gpu-programming

## Mission

Own the wgpu 22 rendering pipeline: RenderCommand queue, shader authoring, texture management, canvas render-to-texture, blend modes, transform stacks, and GPU performance rules.

## When To Load

- Implementing or modifying a RenderCommand variant
- Adding a wgpu render pipeline (new blend mode, new shader type)
- Writing or debugging custom WGSL shaders
- Texture management, canvas render-to-texture patterns
- Diagnosing wgpu validation errors or GPU memory issues

## When To Skip

- Font rasterization details, Lua API design, or physics

## Domain Knowledge

**wgpu stack:** wgpu 22 only, no OpenGL path. Auto-selects Vulkan→DX12→Metal. All rendering goes through GpuRenderer in src/render/gpu_renderer.rs.

**RenderCommand queue lifecycle:** Lua pushes commands during draw() callback, GpuRenderer processes them after draw() returns. render_commands cleared at start of each frame's draw step. Only one wgpu::CommandEncoder per frame in render_frame(). Never render inside a Lua closure — push RenderCommands only.

**Adding a new RenderCommand variant:** (1) add variant to RenderCommand enum in src/render/renderer.rs, (2) add execution arm in src/render/gpu_renderer.rs, (3) add Lua push function in src/lua_api/render_api.rs, (4) add Lua BDD test in tests/lua/unit/test_render_unit.lua.

**Built-in shaders:** COLOR_SHADER (position+color, pass-through fragment) and TEXTURE_SHADER (position+UV+color tint, texture sample) — both embedded in src/render/gpu_renderer.rs.

**Custom WGSL shaders:** entry point @fragment fn fs_main(...) -> @location(0) vec4<f32>. Auto-uniforms: luna_Time (f32), luna_ScreenSize (vec2<f32>). Do not declare bindings at group 0 (engine reserved). User uniforms go at group 2+, set via lurek.render.sendShaderUniform(shader, name, value).

**Texture management:** Rgba8Unorm for data textures, Rgba8UnormSrgb for sRGB. Textures cached by TextureKey (SlotMap). Deferred destruction — never use a TextureKey after release().

**Canvas render-to-texture:** lurek.render.newCanvas(w,h), lurek.render.setCanvas(canvas)→draw→lurek.render.setCanvas() to return to screen. Used for post-processing and multi-pass rendering.

**Performance rules:** target 60fps at 1080p on integrated GPUs (Intel UHD, AMD APU). Max ~2000 draw calls/frame. Use SpriteBatch for batching. 5 blend modes available (alpha, additive, multiply, screen, replace).

**Common wgpu validation errors:** BUFFER_COPY_ALIGNMENT (buffer sizes must be multiples of 4 bytes), BIND_GROUP_LAYOUT_MISMATCH (shader layout != pipeline layout), INVALID_OPERATION (using released resource). Enable validation: set RUST_LOG=wgpu_core=warn.

**Transform stack:** PushTransform/PopTransform RenderCommands for hierarchical transforms. Always balance push/pop pairs.

## Companion File Index

None — all guidance is inline.

## References

- src/render/gpu_renderer.rs — main GPU renderer
- src/render/renderer.rs — RenderCommand enum
- src/lua_api/render_api.rs — Lua render bindings
- docs/specs/render.md — canonical render module spec
