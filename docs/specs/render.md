# render

## TL;DR

- Orchestrates the engine's visual backend using a device-facing wgpu renderer.
- Supports shapes, batched textures, off-screen canvases, and dynamic font rasterization.
- Enables custom WGSL shaders, chained post-processing filters, and stencil portal masks.
- Projects 3D Wavefront models into 2D vertex meshes with software screenshot readbacks.

## General Info

- Module group: `Platform Services`
- Source path: `src/render/`
- Binding: `src/lua_api/render_api.rs`
- Namespace: `lurek.render`
- Lua API surface: `117` functions, `14` types, `88` methods
- Rust test path(s): src/render/ (inline #[cfg(test)] in canvas, decal_surface, draw_layer, font, image_effect, mesh, shader, shape), src/render/renderer_tests.rs, src/render/postfx_pipeline_tests.rs
- Lua test path(s): tests/lua/unit/test_render_unit.lua

## Summary

- The render module is the central GPU execution backend for all visual output in Lurek2D.
- It receives deferred draw intent and resolves it into deterministic frame submission.
- The backend is implemented on wgpu and manages device, queue, and surface lifecycle.
- Primitive rendering covers lines, circles, ellipses, rectangles, and rounded rectangles.
- CPU-side tessellation builds vertex and index data for dynamic geometry.
- Flat-color and textured paths are separated to reduce unnecessary state churn.
- Command batching groups compatible draws to lower submission overhead.
- Pipeline caching avoids repeat creation for equivalent render configurations.
- Pipeline keys include blend mode, vertex layout, stencil mode, and shader variant.
- GPU resource management tracks textures, samplers, fonts, and buffer lifetimes.
- Buffer growth policy favors amortized resizing for throughput stability.
- Slotmap-based IDs keep resource handles stable across frames.
- Off-screen canvases support layered composition and intermediate render targets.
- Decal surfaces support persistent paint-like world overlays.
- Draw-layer scheduling preserves deterministic z-ordered callback execution.
- Mesh paths support custom geometry beyond built-in primitives.
- Text rendering supports bitmap atlases and runtime font rasterization.
- Glyph metrics and wrapping remain consistent with final draw output.
- Font atlas dirty tracking minimizes upload work to changed regions.
- Shader integration supports custom WGSL with typed uniform mapping.
- Shader compilation and registry caching are isolated from command generation logic.
- Runtime uniforms can include frame time, resolution, and frame index values.
- Post-processing uses ping-pong fullscreen passes for chained effects.
- Effects include blur, bloom, CRT-like passes, grading, and distortion variants.
- No-effect paths degrade to fast copy behavior for minimal overhead.
- Stencil support enables masks, portals, and constrained draw regions.
- Scissor and viewport normalization reduce validation and bounds errors.
- Blend mode support includes alpha, additive, multiply, and replace behavior.
- Sampler control supports nearest/linear filtering and wrap behavior.
- Lighting integration includes bounded GPU-side light buffer handling.
- Shadow pass resources are integrated with frame scheduling.
- Screenshot readback supports tooling and regression workflows.
- Resize handling recreates swapchain-dependent resources safely.
- Draw command validation catches invalid resource/target usage early.
- Fallback textures and shaders avoid hard failures on missing assets.
- Diagnostics expose draw-call and render-phase timing information.
- Renderer tests cover key pipeline and postfx contracts.
- Integration with image/font/light/runtime remains explicit and acyclic.
- The module owns visual execution, not gameplay policy.
- It is the authoritative source for frame composition behavior.
- Deterministic command ordering is a core invariant.
- Safe GPU resource lifetime management is another core invariant.
- Graceful fallback behavior is required for robustness under partial content.
- The module supports iGPU-focused performance goals at 60 FPS targets.
- API breadth is centralized in one backend to avoid duplicated render logic.
- Feature modules emit intent; render executes it.
- This separation keeps architecture clean and testable.
- CPU and GPU diagnostic paths remain aligned with core semantics.
- The render boundary is stable for integration with future feature modules.
- It enables sophisticated visuals without forcing feature modules to own GPU details.
- Overall, render is the Platform Services visual foundation.
- It is the final convergence point of scene, UI, effects, and text pipelines.
- The module is performance-critical and observability-oriented by design.
- Reliability under dynamic content churn is prioritized in its contracts.
- This makes it suitable for both gameplay and tooling presentation workloads.
- Render remains a first-class subsystem, not a thin adapter.
- It carries the execution responsibility for the full visual stack.
- Its interfaces are built for long-term maintainability and extensibility.
- In practice, every frame quality issue eventually converges here.
- The module provides the controls needed to diagnose and fix those issues.

This module primarily collaborates with `font`, `image`, `light`, `math`, `runtime`, `sprite`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Imports

- `font`: Imports or references `src/font/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `image`: Imports or references `src/image/`. Dependency stays inside `Platform Services` and should remain acyclic.
- `light`: Imports or references `light` from `src/light/`.
- `math`: Imports or references `math` from `src/math/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
- `sprite`: Imports or references `sprite` from `src/sprite/`.

## Files

### canvas.rs

- Canvas metadata representation for off-screen rendering targets. `render/canvas` delivers the canvas implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

### decal_surface.rs

- Paint-target surface descriptor for persistent world decals. `render/decal_surface` delivers the decal surface implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Stores the durable dimensions (width and height) needed for later GPU texture allocation. The file owns or coordinates data contracts including `DecalSurface`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Represents canvas-like surfaces where impact marks, splats, and footprints can be drawn. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `get_dimensions`, `get_width`, `get_height` stays attached to the local data model and invariants.

### draw_layer.rs

- Stores deferred draw-layer callbacks sorted by depth (Z-order). `render/draw_layer` delivers the draw layer implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Enables gameplay code and UI components to enqueue layered draw commands cheaply. The file owns or coordinates data contracts including `LayerEntry`, `DrawLayer`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Postpones immediate GPU commands to allow sorting before final render dispatch. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `queue`, `flush`, `clear`, `get_count` stays attached to the local data model and invariants.

### extracted_blocks.rs

- Implements procedural geometry generation and tessellation for all primitive 2D shapes. `render/extracted_blocks` delivers the extracted blocks implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Generates vertex/index lists for arcs, circles, ellipses, sectors, and rounded rectangles. The file owns or coordinates data contracts including `GpuTexture`, `RenderStats`, `GpuShader`, `LightGpuState`, `GpuRenderer`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Translates abstract blending modes requested by Lua into explicit wgpu descriptors. Public callable behavior is centered on no named public items, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Handles thick-line calculations by expanding stroke segments to screen-aligned quads. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Uses adaptive step sizes for curved geometry to trade off segment count vs visual smoothness. External integration uses no named public items, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Implements custom geometry builders for solid shapes, hollow wireframes, and textured sprites. The file boundary separates render implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### font.rs

- Handles text asset rendering from bundled bitmap atlases to dynamic font rasterization. `render/font` delivers the font implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Packs glyph metrics, atlas placement, and UV offset maps under a unified interface. The file owns or coordinates data contracts including `GlyphInfo`, `Font`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Bundles Courier New regular and bold bitmap fonts at multiple point sizes for default text. Public callable behavior is centered on no named public items, while method-level behavior such as `builtin_slot_by_name`, `from_png_bytes`, `from_font_bytes`, `load_all_sizes`, `load_all_bold`, `nearest_size`, and 13 more stays attached to the local data model and invariants.
- Uses fontdue to dynamically rasterize custom TTF/OTF font bytes at runtime. Runtime integration reaches sibling engine areas through crate modules `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Supports automatic word wrapping, alignment calculations, and pen advance metrics. External integration uses `fontdue`, `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Extends character mapping to support retro drawing symbols and C1 box characters. The file boundary separates render implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### gpu_light.rs

- Enforces memory boundaries and layout constraints for the deferred shadow mapping pass. `render/gpu_light` delivers the gpu light implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Maximum capacity limits on light sources are defined here to guarantee stable frame times. The file owns or coordinates data contracts including `LightGpuState`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- The structures defined here instruct the renderer how to process additive light passes. Public callable behavior is centered on no named public items, while method-level behavior such as no named public items stays attached to the local data model and invariants.

### gpu_pipeline.rs

- Manages creation and caching of wgpu render pipeline objects to prevent redundancy. `render/gpu_pipeline` delivers the gpu pipeline implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Groups pipelines by geometry layout, blend mode, and stencil operation flags. The file owns or coordinates data contracts including `GeometryKind`, `GpuStencilMode`, `PipelineKey`, `PipelineSelectionKey`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Selects default built-in shaders when custom overrides are absent from keys. Public callable behavior is centered on `blend_state_for`, `uniform_wgsl_type`, `custom_uniform_declarations`, `custom_fragment_call_args`, `build_custom_color_shader_source`, and 6 more, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Pays pipeline compilation cost only once per unique rendering configuration. Runtime integration reaches sibling engine areas through crate modules `render`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Configures stencil operations, depth-stencil states, and stencil mode mapping. External integration uses no named public items, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Standardizes blend states for alpha, additive, multiplicative, and replace modes. The file boundary separates render implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### gpu_renderer.rs

- Primary hardware-accelerated 2D rendering orchestrator for Lurek2D. `render/gpu_renderer` delivers the gpu renderer implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Integrates with wgpu to manage device, queue, swapchain, and graphics resources. The file owns or coordinates data contracts including `GpuRenderer`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Translates Lua-side render commands into structured draw calls and pipeline states. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `resize`, `render_frame` stays attached to the local data model and invariants.
- Controls multi-pass rendering flow including scenes, shadows, decals, and post-fx. Runtime integration reaches sibling engine areas through crate modules `log_msg`, `math`, `render`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Aggressively coalesces contiguous draw calls sharing material parameters and textures. External integration uses `slotmap`, `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Implements static geometry caching to bypass tessellation and CPU upload overhead. The file boundary separates render implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.
- Implements GPU-side instancing to render repetitive sprite grids and particle buffers. State changes, validation paths, and helper routines in `src/render/gpu_renderer.rs` should be reviewed together because they collectively define the safe operational surface for this feature.
- Renders primitive vector shapes, dynamic outlines, rounded quads, and ellipses. Agents reading this file should use the module docs to understand provided functionality first, then inspect item docs and tests only where the behavior is being changed.
- Resolves text rendering by drawing character quads lookup from font atlases. The implementation keeps feature-specific decisions near their data and helper functions, reducing cross-module coupling while preserving a clear engine-facing boundary.
- Manages offscreen canvases as render targets to enable composite camera views. Documentation here is intended to feed source-derived specs, so every file-level line states concrete responsibilities instead of generic presence or placeholder text.

### gpu_resources.rs

- Manages persistent GPU resource lifetimes, allocations, and buffer uploads. `render/gpu_resources` delivers the gpu resources implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Handles dynamic capacity adjustment for growing vertex and index buffers. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Caches textures, fonts, and canvases inside slotmap collection structures. Public callable behavior is centered on no named public items, while method-level behavior such as `grow_capacity`, `ensure_geometry_buffer_capacity`, `ensure_instance_buffer_capacity`, `create_sampler`, `create_texture_bind_group`, `create_gpu_texture_raw`, and 8 more stays attached to the local data model and invariants.
- Prunes unused graphics resources automatically to prevent GPU memory leaks. Runtime integration reaches sibling engine areas through crate modules `render`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Resizes vertex and index buffers exponentially to minimize pipeline stalls. External integration uses `slotmap`, `super`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Uploads static draw geometries to permanent GPU buffers for cached rendering. The file boundary separates render implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### gpu_shaders.rs

- Defines raw binary structures and types representing compiled user WGSL shaders. `render/gpu_shaders` delivers the gpu shaders implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Maps uniform value types to their corresponding GPU buffer layout variants. The file owns or coordinates data contracts including `ShaderUniformKind`, `GpuShader`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Caches compiled wgpu pipelines within shader structures to prevent reconstruction. Public callable behavior is centered on no named public items, while method-level behavior such as no named public items stays attached to the local data model and invariants.

### gpu_shadows.rs

- Manages 1D shadow map rendering, dynamic light lists, and compute dispatches. `render/gpu_shadows` delivers the gpu shadows implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Gathers occluder edge geometry and transforms it into GPU edge storage buffers. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Dispatches shadow compute shaders per light source to map distances into the shadow atlas. Public callable behavior is centered on `collect_shadow_edges`, while method-level behavior such as `ensure_light_resources`, `ensure_shadow_edge_capacity`, `dispatch_shadow_map_gpu`, `aabb_visible_2d` stays attached to the local data model and invariants.
- Performs viewport culling on light sources before queuing commands. Runtime integration reaches sibling engine areas through crate modules `math`, `render`, `light`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Binds and manages GPU buffers, bind groups, and pipelines for light passes. External integration uses `super`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Filters occluding shapes by light bitmasks and culls lines outside light radii. The file boundary separates render implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### gpu_state.rs

- Implements the GPU resource registry to track persistent mesh and buffer lifetimes. `render/gpu_state` delivers the gpu state implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Stores texture, canvas, and font allocations within structured slotmaps. The file owns or coordinates data contracts including `GpuTexture`, `DepthStencilTarget`, `PendingSurfaceReadback`, `RenderStats`, `StaticGeometryCacheEntry`, and 2 more, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Caches static draw geometry descriptors, avoiding frame allocations. Public callable behavior is centered on no named public items, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Manages depth-stencil buffer views matching current canvas dimensions. Runtime integration reaches sibling engine areas through crate modules `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### gpu_tess.rs

- GPU tessellator converting high-level 2D vector shapes (rectangles, circles, arcs, text glyphs, sprites, meshes) into vertex and index buffers.
- Implements dynamic segment-count adaptation for circles and ellipses based on screen-space radius ensuring smooth curves at any zoom level.
- Tessellates stroked lines as screen-aligned rectangular quads with configurable line width supporting dashed borders and outline styles.
- Packs ColorVertex and TexVertex buffers with positions, UV coordinates, tint colors, and transform data for unified pipeline ingestion.
- Applies 3x3 model-view transformations per vertex enabling local coordinate systems and nested transform hierarchies. External integration uses `super`, `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Computes scissor rectangles and culls geometry outside viewport bounds reducing GPU workload and preventing render artifacts.

### gpu_types.rs

- Defines raw binary structures representing GPU vertex layouts. `render/gpu_types` delivers the gpu types implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Packs memory layouts tightly using bytemuck to ensure copy compliance. The file owns or coordinates data contracts including `ColorVertex`, `TexVertex`, `LightVertex`, `ShadowEdgeGpu`, `ShadowComputeParams`, and 7 more, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Groups properties like position, texture coordinates, color tints, and normals. Public callable behavior is centered on no named public items, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Encapsulates command batching metadata for coalescing draw dispatches. Runtime integration reaches sibling engine areas through crate modules `render`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Tracks instance transformation data for hardware instancing buffers. External integration uses `bytemuck`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### image_effect.rs

- Compact descriptor for post-processing steps in a shader pipeline. `render/image_effect` delivers the image effect implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

### mesh.rs

- Defines reusable 2D mesh data for complex vector drawing and models. `render/mesh` delivers the mesh implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Stores vertex coordinates, UV maps, colors, and topology information. The file owns or coordinates data contracts including `MeshDrawMode`, `MeshVertex`, `Mesh`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Bridges custom loaded model assets and procedural vector geometries. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `from_vertices`, `from_vertex_rows`, `set_vertex`, `get_vertex`, `set_vertex_map`, and 4 more stays attached to the local data model and invariants.
- Supports multiple drawing topologies including triangle lists and fans. Runtime integration reaches sibling engine areas through crate modules `log_msg`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### mod.rs

- Unified entry point for the Lurek2D render module stack. `render/mod` is the render module index, declaring `canvas`, `decal_surface`, `draw_layer`, `font`, `gpu_light`, and 17 more so agents can identify which files own each feature slice before opening implementation code.
- Exposes submodules for canvases, decal surfaces, shapes, and font managers. `src/render/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `canvas::Canvas`, `decal_surface::DecalSurface`, `draw_layer::DrawLayer`, `font::Font`, and 10 more centralized for the render subsystem.
- Declares modules for the GPU-accelerated renderer and compiled pipelines. The file documents how render submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
- Unifies draw interfaces, shader uniform mappings, and shader passes. Agents should read this index to choose the narrow owner file first, because it maps names such as `canvas`, `decal_surface`, `draw_layer`, `font`, `gpu_light`, and 17 more to concrete implementation responsibilities.
- Bridges game runtime draw buffers to backend hardware rendering layers. Re-export decisions in this file define the stable Rust boundary consumed by sibling modules, Lua bindings, generated specs, and examples that mention render features.
- Conforms to the binding rules, exposing all public rendering APIs. The module stays implementation-light by delegating behavior to child files, which preserves a clear boundary between navigation metadata and executable subsystem logic.

### obj_loader.rs

- Parses Wavefront OBJ and material MTL files for rendering projection. `render/obj_loader` delivers the obj loader implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Translates 3D geometric models into 2D canvas coordinates and meshes. The file owns or coordinates data contracts including `ObjError`, `Vec3`, `Vec2`, `ObjFace`, `ObjMaterial`, and 3 more, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Projects vertices from world positions to viewport dimensions using virtual cameras. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `dot`, `len`, `normalise`, `sub`, `cross`, and 12 more stays attached to the local data model and invariants.
- Performs linear diffuse color mapping and resolves texture path assets. Runtime integration reaches sibling engine areas through crate modules `image`, `render`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Implements software-based CPU rasterization for thumbnail rendering and validation. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Normalizes OBJ face indices, resolving negative and 1-based index offsets. The file boundary separates render implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.
- Filters back-facing triangles to optimize rendering output. State changes, validation paths, and helper routines in `src/render/obj_loader.rs` should be reviewed together because they collectively define the safe operational surface for this feature.
- Computes face normals to calculate light reflection and shading coefficients. Agents reading this file should use the module docs to understand provided functionality first, then inspect item docs and tests only where the behavior is being changed.

### postfx_pipeline.rs

- Manages post-processing effects and screen-space shader rendering passes. `render/postfx_pipeline` delivers the postfx pipeline implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Connects offscreen canvas textures to full-screen fragment shader operations. The file owns or coordinates data contracts including `PostFxTexture`, `PostFxPipeline`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Groups effect parameters, texture bindings, and samplers dynamically. Public callable behavior is centered on `params_to_uniform`, while method-level behavior such as `new`, `register_custom`, `apply` stays attached to the local data model and invariants.
- Renders multi-pass post-fx chains like blur, CRT warp, and color correction. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Coalesces texture swap passes, minimizing frame allocation overhead. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Configures pipeline states, blend modes, and write masks for screen passes. The file boundary separates render implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.
- Compiles and stores default fallback post-processing WGSL shaders. State changes, validation paths, and helper routines in `src/render/postfx_pipeline.rs` should be reviewed together because they collectively define the safe operational surface for this feature.
- Reuses texture descriptors, adapting resources to window dimensions. Agents reading this file should use the module docs to understand provided functionality first, then inspect item docs and tests only where the behavior is being changed.

### province_map_pipeline.rs

- Provides the specialized GPU pipeline for drawing detailed province maps. `render/province_map_pipeline` delivers the province map pipeline implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Binds map-specific data like region IDs, border structures, and height fields. The file owns or coordinates data contracts including `ProvinceMapUniforms`, `ProvinceMapPipeline`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Renders fullscreen map views using custom fragments WGSL shader passes. Public callable behavior is centered on no named public items, while method-level behavior such as `full_map`, `new`, `create_data_bind_group`, `update_uniforms` stays attached to the local data model and invariants.
- Configures pipeline layout options, mapping texture samplers and buffers. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Packs viewport ranges, map size, zoom factor, and animation times into uniforms. External integration uses `bytemuck`, `wgpu`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### renderer.rs

- Defines Lurek2D's front-end render command language and vocabulary. `render/renderer` delivers the renderer implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Gathers draw operations, layout state structures, and drawing enum descriptors. The file owns or coordinates data contracts including `CompareMode`, `StencilAction`, `StencilMode`, `DepthMode`, `TextAlign`, and 16 more, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Encapsulates shapes, typography, sprites, and particle states into dynamic variants. Public callable behavior is centered on `adaptive_circle_ellipse_segments`, while method-level behavior such as `new` stays attached to the local data model and invariants.
- Declares enums for color blend modes, text alignment, and draw modes. Runtime integration reaches sibling engine areas through crate modules `math`, `render`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Specifies vertex colors, gradients, and custom outline thickness bounds. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Standardizes structures for texture repeat modes and sampler filters. The file boundary separates render implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### shader.rs

- Manages user-facing shader compilation and parsing of WGSL sources. `render/shader` delivers the shader implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Wraps WGSL source code into normalized pipeline templates for the renderer. The file owns or coordinates data contracts including `ShaderFragmentInput`, `Shader`, `UniformValue`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Inspects fragment inputs to ensure only supported attributes are bound. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `send`, `has_uniform`, `ordered_uniforms`, `wrapper_source`, `fragment_entry_name`, and 1 more stays attached to the local data model and invariants.
- Represents shader uniform values in typed forms for per-frame upload. Runtime integration reaches sibling engine areas through crate modules `log_msg`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Preserves the ordering of uniform variables to guarantee stable GPU buffer layouts. External integration uses `std`, `wgpu`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### shape.rs

- Stores reusable vector shape definitions as replayable command sequences. `render/shape` delivers the shape implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Packages stroke and fill operations into named assets for UI reuse. The file owns or coordinates data contracts including `ShapeCommand`, `CompoundShape`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Retains color and outline thickness attributes along with path commands. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `push_command`, `clear`, `command_count` stays attached to the local data model and invariants.
- Minimizes scene building overhead by avoiding dynamic shape rebuilding. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### software_capture.rs

- CPU-side screenshot fallback for queued 2D render commands. `render/software_capture` delivers the software capture implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Replays a practical subset of `RenderCommand` values into `ImageData`. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Exists to support evidence capture in headless/unit environments where GPU readback is unavailable. Public callable behavior is centered on `capture_commands_to_image`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- `render/software_capture` delivers the software capture implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Public callable behavior is centered on `capture_commands_to_image`, while method-level behavior such as no named public items stays attached to the local data model and invariants.



## Lua API Ref

### Functions

- `lurek.render.applyTransform(mat) -> nil`: Multiplies the current transformation matrix by a 3x3 matrix (9 values in row-major order).
- `lurek.render.arc(mode, x, y, radius, angle1, angle2, segments?) -> nil`: Draws a filled or outlined circular arc segment.
- `lurek.render.beginSortGroup(id) -> nil`: Begins a depth-sorted rendering group. Draw calls within this group are sorted by pushSortKey values.
- `lurek.render.captureScreenshot(callback) -> nil`: Captures the queued 2D render commands into an ImageData fallback and passes it to a callback.
- `lurek.render.circle(mode, x, y, radius) -> nil`: Draws a filled or outlined circle at the given position.
- `lurek.render.clear(r?, g?, b?) -> nil`: Clears all queued render commands for the current frame.
- `lurek.render.clearStencil() -> nil`: Resets the stencil state to defaults (no stencil operations).
- `lurek.render.currentLayer() -> string`: Returns the name of the currently active rendering layer.
- `lurek.render.draw(drawable, x?, y?, r?, sx?, sy?, ox?, oy?) -> nil`: Draws a drawable object (Image, Canvas, SpriteBatch, or Mesh) at the given position with optional transform.
- `lurek.render.drawBatch(batch) -> nil`: Draws a SpriteBatch using the same queued DrawBatch command as lurek.render.draw(batch).
- `lurek.render.drawBevelRect(x, y, w, h, bevelW?, style?, opts?) -> nil`: Draws a beveled rectangle with highlight, shadow, and fill colors for 3D-style UI elements.
- `lurek.render.drawColoredPolygon(vertices, colors, mode?) -> nil`: Draws a polygon with per-vertex colors.
- `lurek.render.drawCubicBezier(x1, y1, cx1, cy1, cx2, cy2, x2, y2, segments?) -> nil`: Draws a cubic Bezier curve through start, two control points, and end.
- `lurek.render.drawGradientRect(x, y, w, h, c1, c2, dir?) -> nil`: Draws a rectangle with a two-color gradient fill.
- `lurek.render.drawHexTile(cx, cy, size, orientation?, mode?) -> nil`: Draws a regular hexagonal tile at the given center position.
- `lurek.render.drawIsoCubeTile(sx, sy, halfW, halfH, opts?) -> nil`: Draws an isometric cube tile with configurable face colors and optional textures.
- `lurek.render.drawMany(list) -> nil`: Batch-draws multiple images in one call. Each entry is a table: {image, x, y, r, sx, sy, ox, oy}.
- `lurek.render.drawNineSlice(slice, x, y, w, h) -> nil`: Draws a 9-slice image stretched to fill the given rectangle, keeping borders unscaled.
- `lurek.render.drawPath(path, mode?, close?) -> nil`: Draws a vector path composed of moveTo, lineTo, quadTo, and cubicTo segments.
- `lurek.render.drawQuadBezier(x1, y1, cx, cy, x2, y2, segments?) -> nil`: Draws a quadratic Bezier curve through start, control, and end points.
- `lurek.render.drawq(image, quad, x?, y?, r?, sx?, sy?, ox?, oy?) -> nil`: Draws a sub-region of an image defined by a Quad, with optional transform.
- `lurek.render.ellipse(mode, x, y, rx, ry) -> nil`: Draws a filled or outlined ellipse at the given position.
- `lurek.render.flushSortGroup(id) -> nil`: Ends a sort group and emits all accumulated draw calls in sorted order.
- `lurek.render.getBackgroundColor() -> number, number, number, number`: Returns the current background clear color.
- `lurek.render.getBlendMode() -> string`: Returns the current blend mode name.
- `lurek.render.getBuiltInFontNames() -> string[]`: Returns all stable built-in font names.
- `lurek.render.getCanvas() -> LCanvas`: Returns the currently active canvas, or nil if drawing to the screen.
- `lurek.render.getCanvasSize(canvas) -> number, number`: Returns the pixel dimensions of a canvas.
- `lurek.render.getColor() -> number, number, number, number`: Returns the current drawing color.
- `lurek.render.getColorMask() -> boolean, boolean, boolean, boolean`: Returns the current color write mask.
- `lurek.render.getDefaultFilter() -> string, string, number`: Returns the current default texture filtering settings.
- `lurek.render.getDefaultFont(pointSize?, bold?) -> LFont`: Returns a built-in default font at the nearest available bundled point size.
- `lurek.render.getDepthMode() -> string, boolean`: Returns the current depth comparison mode and write-enable flag.
- `lurek.render.getDimensions() -> number, number`: Returns the current window width and height.
- `lurek.render.getFont() -> LFont`: Returns the currently active font, or nil if none is set.
- `lurek.render.getFontAscent(font) -> number`: Returns the ascent (pixels above baseline) of the given font.
- `lurek.render.getFontCellWidth(font) -> number`: Returns the fixed cell width of a bitmap font.
- `lurek.render.getFontDescent(font) -> number`: Returns the descent (pixels below baseline) of the given font.
- `lurek.render.getFontHeight(font) -> number`: Returns the line height of the given font.
- `lurek.render.getFontLineHeight(font) -> number`: Returns the line spacing of the given font.
- `lurek.render.getFontSizes() -> number[]`: Returns all available built-in point sizes.
- `lurek.render.getFontWidth(font, text) -> number`: Measures the pixel width of text using the given font.
- `lurek.render.getFontWrap(text, limit) -> LuaValue, number`: Word-wraps text using the active font and returns the resulting lines and widest line width.
- `lurek.render.getHeight() -> number`: Returns the current window height in pixels.
- `lurek.render.getLayerZOrder(name) -> number`: Returns the z-order value of a named rendering layer.
- `lurek.render.getLineWidth() -> number`: Returns the current line width used for line-mode drawing.
- `lurek.render.getPointSize() -> number`: Returns the current point diameter used for point drawing.
- `lurek.render.getScissor() -> number, number, number, number`: Returns the current scissor rectangle, or nothing if no scissor is set.
- `lurek.render.getShader() -> LShader`: Returns the currently active shader, or nil if using the default.
- `lurek.render.getStats() -> table`: Returns a table of rendering statistics for the current frame.
- `lurek.render.getStencilMode() -> string, string, number`: Returns the current stencil action, compare mode, and reference value.
- `lurek.render.getWidth() -> number`: Returns the current window width in pixels.
- `lurek.render.intersectScissor(x, y, w, h) -> nil`: Intersects the given rectangle with the current scissor, narrowing the drawable region.
- `lurek.render.isBold() -> boolean`: Returns true if the current default font selection uses the bold variant.
- `lurek.render.isLayerVisible(name) -> boolean`: Returns whether a named rendering layer is currently visible.
- `lurek.render.isWireframe() -> boolean`: Returns whether wireframe rendering is currently active.
- `lurek.render.line(...) -> nil`: Draws a line between two points, or a polyline through multiple points.
- `lurek.render.loadModel(path) -> LObjModel`: Loads a 3D model file (OBJ format) and returns a handle for 2D projection and sprite rendering.
- `lurek.render.loadObj(path) -> LObjModel`: Loads a Wavefront OBJ model file and returns a model handle for projection and rendering.
- `lurek.render.newCanvas(width, height) -> LCanvas`: Creates a new off-screen render target with the given dimensions.
- `lurek.render.newDepthSorter() -> LDepthSorter`: Registers the depth-sorted drawing helper constructor in the render module.
- `lurek.render.newDrawLayer() -> LDrawLayer`: Creates a new z-ordered draw layer for sorting draw callbacks by depth.
- `lurek.render.newFont(pathOrSize, size?) -> LFont`: Creates a font from a built-in font name, a font file path, or a numeric built-in point-size selector.
- `lurek.render.newImage(pathOrData, colorSpace?) -> LImage`: Loads a texture from a file path or creates one from an ImageData object.
- `lurek.render.newLayer(name, zOrder?) -> nil`: Creates a named rendering layer with an optional z-order for draw call organization.
- `lurek.render.newMesh(verts, mode?) -> LMesh`: Creates a custom vertex mesh from an array of vertex data tables.
- `lurek.render.newNineSlice(image, top, right, bottom, left) -> LNineSlice`: Creates a 9-slice definition from an image and four border insets for scalable UI rendering.
- `lurek.render.newQuad(x, y, w, h, sw, sh) -> LQuad`: Creates a Quad defining a rectangular sub-region of a texture for sprite-sheet rendering.
- `lurek.render.newShader(code) -> LShader`: Compiles a WGSL shader program from source code and returns a handle.
- `lurek.render.newShape() -> LShape`: Creates a new retained compound shape for accumulating draw commands.
- `lurek.render.newSpriteBatch(image, max?) -> LSpriteBatch`: Creates a batched sprite renderer for efficiently drawing many copies of the same texture.
- `lurek.render.origin() -> nil`: Resets the current transformation matrix to the identity (no transform).
- `lurek.render.points(...) -> nil`: Draws one or more points. Accepts either a table of {x,y} pairs or flat x,y coordinate values.
- `lurek.render.polygon(mode, ...) -> nil`: Draws a polygon from a flat list of x,y vertex coordinates.
- `lurek.render.pop() -> nil`: Pops the top transformation matrix from the transform stack, restoring the previous one.
- `lurek.render.popLayer(id) -> nil`: Ends a compositing layer and composites it with the previous content.
- `lurek.render.print(text, x?, y?, scale?) -> nil`: Draws text using the active font at the given position.
- `lurek.render.printRich(spans, x, y) -> nil`: Draws rich text composed of individually styled spans at the given position.
- `lurek.render.printRichWithFont(font, spans, x, y) -> nil`: Draws rich text using a specific font without changing the global active font.
- `lurek.render.printRotated(text, x, y, angle, scale?) -> nil`: Draws text centered and rotated around its midpoint.
- `lurek.render.printRotatedWithFont(font, text, x, y, angle, scale?) -> nil`: Draws text centered and rotated around its midpoint using a specific font without changing the global active font.
- `lurek.render.printWithFont(font, text, x?, y?, scale?) -> nil`: Draws text using a specific font without changing the global active font.
- `lurek.render.printf(text, x, y, limit, align?) -> nil`: Draws word-wrapped and aligned text within a pixel-width limit.
- `lurek.render.printfWithFont(font, text, x, y, limit, align?) -> nil`: Draws word-wrapped and aligned text with a specific font without changing the global active font.
- `lurek.render.push() -> nil`: Pushes the current transformation matrix onto the transform stack.
- `lurek.render.pushLayer(id, alpha?, blendMode?) -> nil`: Begins a compositing layer with the given alpha and blend mode. Must be paired with popLayer.
- `lurek.render.pushSortKey(depth) -> nil`: Sets the depth sort key for subsequent draw calls within the current sort group.
- `lurek.render.rectangle(mode, x, y, w, h, rx?, ry?) -> nil`: Draws a rectangle. If rx is provided, draws a rounded rectangle.
- `lurek.render.resetCanvas(canvas) -> nil`: Marks a canvas as needing a full clear before its next render pass. Use before re-rendering to avoid content accumulation.
- `lurek.render.rotate(angle) -> nil`: Applies a rotation to the current transformation matrix.
- `lurek.render.saveScreenshot(path) -> nil`: Saves a screenshot of the current frame to a file under the save/ directory.
- `lurek.render.scale(sx, sy?) -> nil`: Applies scaling to the current transformation matrix.
- `lurek.render.setBackgroundColor(r, g, b) -> nil`: Sets the background clear color used at the start of each frame.
- `lurek.render.setBlendMode(mode) -> nil`: Sets the blend mode for subsequent draw operations.
- `lurek.render.setBold(bold) -> nil`: Sets whether subsequent font size lookups use the bold Courier New variant.
- `lurek.render.setCanvas(canvas?) -> nil`: Redirects all subsequent drawing to the given canvas. Pass nil to draw to the screen again.
- `lurek.render.setColor(r, g, b, a?) -> nil`: Sets the active drawing color for all subsequent draw operations.
- `lurek.render.setColorMask(r?, g?, b?, a?) -> nil`: Sets which color channels are written during draw calls. Call with no args to enable all.
- `lurek.render.setDefaultFilter(min, mag, anisotropy?) -> nil`: Sets the default texture filtering mode for newly created images.
- `lurek.render.setDefaultFont(pointSize?, bold?) -> LFont`: Selects a built-in default font by bundled point size and makes it the active render font.
- `lurek.render.setDepthMode(mode, write?) -> nil`: Sets the depth comparison mode and whether depth writes are enabled.
- `lurek.render.setFont(font) -> nil`: Sets the active font used by print, printf, and other text rendering calls.
- `lurek.render.setFontLineHeight(font, lh) -> nil`: Sets the line height override for a font (currently a no-op stub).
- `lurek.render.setLayer(name) -> nil`: Sets the active rendering layer by name. Creates the layer if it does not exist.
- `lurek.render.setLayerVisible(name, visible) -> nil`: Sets whether a named rendering layer is visible.
- `lurek.render.setLayerZOrder(name, z) -> nil`: Sets the z-order value of a named rendering layer.
- `lurek.render.setLineWidth(w) -> nil`: Sets the line width for subsequent line-mode draw calls.
- `lurek.render.setPointSize(size) -> nil`: Sets the point size for subsequent point draw calls.
- `lurek.render.setScissor(x?, y?, w?, h?) -> nil`: Sets or clears the scissor rectangle. Only pixels inside this region are drawn. Call with no args to clear.
- `lurek.render.setShader(shader?) -> nil`: Activates a shader for subsequent draw calls. Pass nil to restore the default shader.
- `lurek.render.setStencilMode(action, compare?, value?) -> nil`: Sets the stencil write action, compare function, and reference value at once.
- `lurek.render.setStencilTest(compare?, value?) -> nil`: Configures the stencil comparison test for subsequent draws. Pass nil to disable.
- `lurek.render.setWireframe(enabled) -> nil`: Enables or disables wireframe rendering mode.
- `lurek.render.shear(kx, ky) -> nil`: Applies a shear (skew) to the current transformation matrix.
- `lurek.render.stencil(action?, value?) -> nil`: Begins a stencil write pass with the given action and reference value.
- `lurek.render.translate(x, y) -> nil`: Applies a translation to the current transformation matrix.
- `lurek.render.triangle(mode, x1, y1, x2, y2, x3, y3) -> nil`: Draws a triangle from three vertex positions.

### Callbacks

- `LDrawLayer:queue` param `f` (`function`): Callback to invoke during flush.
- `LImageData:mapPixels` param `callback` (`function`): Called as callback(x, y, r, g, b, a) â†’ (r, g, b, a) for each pixel. Invocation: `callback(x, y, r, g, b, a)`.
- `lurek.render.captureScreenshot` param `callback` (`function`): Called with an LImageData argument.

### Enums

- No documented module-level enums/constants.

### Types

#### LCanvas Type

- Off-screen render target that can be drawn to and then composited onto the screen.

##### Fields

- No documented fields.

##### Methods

- `LCanvas:getDimensions() -> number, number`: Returns both width and height of this canvas.
- `LCanvas:getHeight() -> number`: Returns the height of this canvas in pixels.
- `LCanvas:getWidth() -> number`: Returns the width of this canvas in pixels.
- `LCanvas:release() -> boolean`: Releases the canvas GPU resource. If this canvas is currently active, drawing reverts to the screen.
- `LCanvas:type() -> string`: Returns the type name string for this canvas object.
- `LCanvas:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LDrawLayer Type

- Z-ordered draw callback layer for sorting draw calls by depth before flushing.

##### Fields

- No documented fields.

##### Methods

- `LDrawLayer:clear() -> nil`: Discards all queued callbacks without executing them.
- `LDrawLayer:flush() -> nil`: Sorts all queued callbacks by z-depth and executes them in order, then empties the layer.
- `LDrawLayer:getCount() -> number`: Returns the number of callbacks currently queued.
- `LDrawLayer:queue(z, f) -> nil`: Enqueues a draw callback at the given z-depth. Callbacks execute when flush() is called.
- `LDrawLayer:type() -> string`: Returns the type name string for this draw layer.
- `LDrawLayer:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LFont Type

- Bitmap font handle for measuring and rendering text.

##### Fields

- No documented fields.

##### Methods

- `LFont:getAscent() -> number`: Returns the ascent (pixels above the baseline) of this font.
- `LFont:getDescent() -> number`: Returns the descent (pixels below the baseline) of this font.
- `LFont:getHeight() -> number`: Returns the line height of this font in pixels.
- `LFont:getLineHeight() -> number`: Returns the spacing between consecutive lines of text.
- `LFont:getWidth(text) -> number`: Measures the pixel width of a string when rendered with this font.
- `LFont:getWrap(text, limit) -> table, number`: Word-wraps text to fit within a pixel width limit and returns the resulting lines.
- `LFont:release() -> boolean`: Releases the font resource. The handle becomes invalid after this call.
- `LFont:setLineHeight(height) -> nil`: Overrides the line height used for multi-line text rendering.
- `LFont:type() -> string`: Returns the type name string for this font object.
- `LFont:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LImage Type

- GPU-backed texture handle used for drawing images to screen.

##### Fields

- No documented fields.

##### Methods

- `LImage:getDimensions() -> number, number`: Returns both width and height of this image.
- `LImage:getHeight() -> number`: Returns the height of this image in pixels.
- `LImage:getId() -> number`: Returns the internal numeric handle ID for this image.
- `LImage:getWidth() -> number`: Returns the width of this image in pixels.
- `LImage:release() -> boolean`: Releases the GPU memory for this image. The handle becomes invalid after this call.
- `LImage:type() -> string`: Returns the type name string for this image object.
- `LImage:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LImageData Type

- Raw pixel buffer for CPU-side image manipulation before uploading to a GPU texture.

##### Fields

- No documented fields.

##### Methods

- `LImageData:blit(source, dstX, dstY) -> nil`: Copies pixel data from another ImageData onto this one at the specified position.
- `LImageData:diff(other) -> number`: Computes a numeric difference score between this image and another of the same size.
- `LImageData:getHeight() -> number`: Returns the height of this image data in pixels.
- `LImageData:getRegion(x, y, w, h) -> LImageData`: Extracts a rectangular sub-region as a new ImageData.
- `LImageData:getWidth() -> number`: Returns the width of this image data in pixels.
- `LImageData:mapPixels(callback) -> nil`: Iterates over every pixel and replaces its color with the return value of the callback.
- `LImageData:resize(w, h) -> LImageData`: Creates a new ImageData resized to the given dimensions using bilinear sampling.
- `LImageData:type() -> string`: Returns the type name of this object.
- `LImageData:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LMesh Type

- Custom vertex mesh for advanced 2D geometry rendering with per-vertex color and UV data.

##### Fields

- No documented fields.

##### Methods

- `LMesh:getVertex(index) -> number, number, number, number, number, number, number, number`: Returns the data for a single vertex by 1-based index.
- `LMesh:getVertexCount() -> number`: Returns the number of vertices in this mesh.
- `LMesh:release() -> boolean`: Releases the mesh GPU resource and invalidates the handle.
- `LMesh:setTexture(image?) -> nil`: Assigns or removes a texture for this mesh. Pass nil to clear the texture.
- `LMesh:setVertex(index, data) -> nil`: Updates a single vertex by 1-based index. Table format: {x, y, u, v, r, g, b, a}.
- `LMesh:type() -> string`: Returns the type name string for this mesh object.
- `LMesh:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LNineSlice Type

- Texture with defined border insets for scalable 9-slice rendering (e.g., UI panels, buttons).

##### Fields

- No documented fields.

##### Methods

- `LNineSlice:getInsets() -> number, number, number, number`: Returns the border insets (top, right, bottom, left) that define the stretchable regions.
- `LNineSlice:getTextureSize() -> number, number`: Returns the pixel dimensions of the underlying source texture.
- `LNineSlice:type() -> string`: Returns the type name of this object.
- `LNineSlice:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LObjModel Type

- Loaded OBJ 3D model handle for CPU-side projection to 2D meshes and sprite rendering.

##### Fields

- No documented fields.

##### Methods

- `LObjModel:getFaceCount() -> number`: Returns the number of faces (triangles) in this OBJ model.
- `LObjModel:getNormalCount() -> number`: Returns the number of vertex normals in this OBJ model.
- `LObjModel:getUvCount() -> number`: Returns the number of UV texture coordinates in this OBJ model.
- `LObjModel:getVertexCount() -> number`: Returns the number of vertices in this OBJ model.
- `LObjModel:projectToMesh(camera, screenW, screenH) -> table`: Projects the OBJ model into 2D vertex data using a virtual camera, returning a table of vertex rows.
- `LObjModel:renderToImage(width, height, rotation?) -> LImage`: Renders the OBJ model to a GPU texture at the given resolution with optional 90-degree rotation.

#### LObjModelProjectToMeshResult Type

- Generated result shape from @field tags.

##### Fields

- `a` (`number`): A.
- `b` (`number`): B.
- `g` (`number`): G.
- `r` (`number`): R.
- `u` (`number`): U.
- `v` (`number`): V.
- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LQuad Type

- Rectangular sub-region of a texture, used for sprite sheets and atlas-based rendering.

##### Fields

- No documented fields.

##### Methods

- `LQuad:getTextureDimensions() -> number, number`: Returns the full dimensions of the source texture this quad references.
- `LQuad:getViewport() -> number, number, number, number`: Returns the quad's viewport rectangle within the source texture.
- `LQuad:setViewport(x, y, w, h) -> nil`: Updates the quad's viewport rectangle.
- `LQuad:type() -> string`: Returns the type name string for this quad object.
- `LQuad:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LRenderGetStatsResult Type

- Generated result shape from @field tags.

##### Fields

- `batched_draws` (`integer`): Batched draw count.
- `canvas_switches` (`integer`): Canvas switch count.
- `canvases` (`integer`): Active canvas count.
- `cpu_render_ms` (`number`): CPU render time in milliseconds.
- `drawcalls` (`integer`): Total draw call count.
- `fonts` (`integer`): Loaded font count.
- `gpu_draw_calls` (`integer`): GPU-side draw call count.
- `shader_switches` (`integer`): Shader switch count.
- `texture_memory` (`integer`): Texture memory in bytes.
- `texture_switches` (`integer`): Texture switch count.
- `textures` (`integer`): Loaded texture count.

##### Methods

- No documented methods.

#### LShader Type

- GPU shader program for custom rendering effects (post-processing, distortion, etc.).

##### Fields

- No documented fields.

##### Methods

- `LShader:hasUniform(name) -> boolean`: Checks whether this shader declares a uniform with the given name.
- `LShader:release() -> boolean`: Releases the shader resource. If active, the default shader is restored.
- `LShader:send(name, value) -> nil`: Sends a uniform value to this shader by name. Supported types: number, boolean, or table (vec2/vec3/vec4).
- `LShader:type() -> string`: Returns the type name string for this shader object.
- `LShader:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LShape Type

- Retained compound shape that accumulates drawing commands and can be rendered in one call.

##### Fields

- No documented fields.

##### Methods

- `LShape:arc(mode, x, y, r, astart, aend, segments?) -> nil`: Adds a filled or outlined arc command to the shape.
- `LShape:circle(mode, x, y, r) -> nil`: Adds a filled or outlined circle command to the shape.
- `LShape:clear() -> nil`: Removes all drawing commands from this shape, making it empty.
- `LShape:draw(x, y, rotation?, sx?, sy?, ox?, oy?) -> nil`: Renders the accumulated shape commands to the screen with optional transform.
- `LShape:ellipse(mode, x, y, rx, ry) -> nil`: Adds an ellipse command to the shape.
- `LShape:getCommandCount() -> number`: Returns the number of drawing commands accumulated in this shape.
- `LShape:line(x1, y1, x2, y2) -> nil`: Adds a line segment command to the shape.
- `LShape:polygon(mode, ...) -> nil`: Adds a polygon command to the shape from a flat list of x,y coordinate pairs.
- `LShape:polyline(...) -> nil`: Adds a connected polyline command to the shape from a flat list of x,y coordinate pairs.
- `LShape:rectangle(mode, x, y, w, h) -> nil`: Adds a rectangle command to the shape.
- `LShape:roundedRectangle(mode, x, y, w, h, rx, ry?) -> nil`: Adds a rounded rectangle command to the shape.
- `LShape:setColor(r, g, b, a?) -> nil`: Sets the drawing color for subsequent shape commands.
- `LShape:setLineWidth(w) -> nil`: Sets the line width for subsequent line-mode shape commands.
- `LShape:triangle(mode, x1, y1, x2, y2, x3, y3) -> nil`: Adds a triangle command to the shape.
- `LShape:type() -> string`: Returns the type name string for this shape object.
- `LShape:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LSpriteBatch Type

- Batched sprite renderer for efficiently drawing many copies of the same texture.

##### Fields

- No documented fields.

##### Methods

- `LSpriteBatch:add(x, y, r?, sx?, sy?, ox?, oy?) -> number`: Adds a sprite entry to the batch at the given position with optional transform.
- `LSpriteBatch:clear() -> nil`: Removes all entries from the sprite batch.
- `LSpriteBatch:getBufferSize() -> number`: Returns the maximum number of entries this batch can hold.
- `LSpriteBatch:getCount() -> number`: Returns the number of sprite entries currently in the batch.
- `LSpriteBatch:release() -> boolean`: Releases the sprite batch resource.
- `LSpriteBatch:type() -> string`: Returns the type name string for this sprite batch.
- `LSpriteBatch:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

## References

- `font`: Imports or references `src/font/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `image`: Imports or references `src/image/`. Dependency stays inside `Platform Services` and should remain acyclic.
- `light`: Imports or references `light` from `src/light/`.
- `math`: Imports or references `math` from `src/math/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
- `sprite`: Imports or references `sprite` from `src/sprite/`.

## Notes

- Public `lurek.render` behavior is Lua-first and should keep canonical coverage in `tests/lua/unit/`.
- `src/render/mod.rs` stays export-only; implementation logic belongs in peer files.
- Renderer reliability changes should prefer recoverable errors or skipped invalid draws over panics in frame submission.
