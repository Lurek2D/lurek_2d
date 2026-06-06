---
inclusion: manual
---

# gpu-programming

## Mission
Own wgpu rendering flow, RenderCommand behavior, and shader integration.

## When To Use
- Changing device or surface setup.
- Adding or modifying `RenderCommand` behavior.
- Working on textures, canvases, or shaders.
- Diagnosing GPU validation errors.

## When To Skip
- Font internals, Lua API design, physics logic.

## Rules

### Backend Constraint
- wgpu 22 is the only renderer backend (binding constraint B-02). No OpenGL, Vulkan-direct, or Metal-direct paths. Document wgpu 22 workarounds in a comment near the workaround.

### RenderCommand Contract
- `RenderCommand` enum in `src/render/renderer.rs` is the contract between game logic and the GPU.
- `on_render` callbacks push commands into `SharedState::pending_commands`.
- After all callbacks return, `GpuRenderer::render_frame()` processes the queue, batches compatible draw calls, and presents the swapchain surface.
- Never call wgpu submission APIs outside `src/render/`.

### RenderPass Budget
- One RenderPass per phase: opaque → transparent → ui → post-process.
- Do not add a mid-frame RenderPass for a single effect — batch into the existing transparent pass. Each extra RenderPass forces a GPU pipeline flush costing 0.5–2 ms on integrated hardware.

### Bind-Group Management
- Group textures by frequency-of-change: per-frame uniforms in group 0, per-batch textures in group 1, per-draw data in group 2.
- A unique bind-group switch costs ~0.05 ms on integrated GPU.

### Buffer Uploads
- Upload via `wgpu::Queue::write_buffer` only when data changed since the last frame. Maintain a dirty flag or hash on the CPU side. A frame with 100 unchanged sprites should have zero buffer writes for those sprites.

### Pipeline State Objects
- Create all pipelines at startup inside `GpuRenderer::new()` and cache them. Never call `device.create_render_pipeline()` inside a per-frame render path.

### Texture Format
- All game textures must use `wgpu::TextureFormat::Rgba8UnormSrgb` unless explicitly documented otherwise.

### Shader Compilation
- Shader compilation failures are fatal at startup. Keep the wgpu validation layer enabled in debug builds (`WGPU_VALIDATION=1`). Never disable validation to silence a startup error.

### Sprite Batching
- Batching happens automatically in `render_frame()` when consecutive `DrawSprite` commands share the same texture, blend mode, and shader. Sort draw commands by texture before pushing to `pending_commands` to maximize batch sizes.

### Canvas / Post-Processing
- `Canvas` stores logical dimensions; `GpuRenderer` manages the actual GPU texture.
- Canvases are created once and reused across frames — never create a new canvas per frame.
- See `content/games/showcase/postfx_demo/` for the full pattern.

### Auto-Uniforms
- Declare a uniform name in Lua; the engine binds the value each frame before the draw call.
- When adding a new auto-uniform, add it to both the WGSL binding slot and the Rust `UniformTable` in `shader.rs`, then update the binding index in the pipeline layout.

### Draw Layer Ordering
- Controlled by `src/render/draw_layer.rs`. Assign the correct layer enum variant for new draw types — do not rely on push order.

### 2D-Only Constraint
- Engine is 2D-only (binding constraint A-03). Perspective projection, depth buffer, or 3D scene graph are out of scope.

### Verification
- After render changes, run `cargo test --test graphics_tests` and check `tests/output/` for screenshot regressions.

## References
- `src/render/`
- `src/lua_api/render_api.rs`
- `docs/specs/render.md`
- `tests/`
