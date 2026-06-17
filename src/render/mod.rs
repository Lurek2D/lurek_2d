//! Unified entry point for the Lurek2D render module stack. `render/mod` is the render module index, declaring `canvas`, `decal_surface`, `draw_layer`, `font`, `gpu_light`, and 17 more so agents can identify which files own each feature slice before opening implementation code.
//! Exposes submodules for canvases, decal surfaces, shapes, and font managers. `src/render/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `canvas::Canvas`, `decal_surface::DecalSurface`, `draw_layer::DrawLayer`, `font::Font`, and 10 more centralized for the render subsystem.
//! Declares modules for the GPU-accelerated renderer and compiled pipelines. The file documents how render submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
//! Unifies draw interfaces, shader uniform mappings, and shader passes. Agents should read this index to choose the narrow owner file first, because it maps names such as `canvas`, `decal_surface`, `draw_layer`, `font`, `gpu_light`, and 17 more to concrete implementation responsibilities.
//! Bridges game runtime draw buffers to backend hardware rendering layers. Re-export decisions in this file define the stable Rust boundary consumed by sibling modules, Lua bindings, generated specs, and examples that mention render features.
//! Conforms to the binding rules, exposing all public rendering APIs. The module stays implementation-light by delegating behavior to child files, which preserves a clear boundary between navigation metadata and executable subsystem logic.

/// CPU-side canvas API: paint-style pixel and shape commands on an `ImageData` surface.
pub mod canvas;
/// Decal surface for projecting persistent paint-style marks onto world geometry.
pub mod decal_surface;
/// Draw-layer abstraction: ordered buckets of `RenderCommand`s flushed each frame.
pub mod draw_layer;
/// Fontdue-backed font rasterisation and glyph atlas management.
pub mod font;
/// GPU light extraction, uniform packing, and light pass helpers.
pub mod gpu_light;
/// High-level wgpu pipeline descriptors and render pipeline construction helpers.
pub mod gpu_pipeline;
/// wgpu device/queue wrapper, pipeline creation, render-pass execution.
pub mod gpu_renderer;
/// GPU resource upload and bind-group management for textures, buffers, and samplers.
pub mod gpu_resources;
/// WGSL shader loading, preprocessing, and module creation utilities.
pub mod gpu_shaders;
/// Shadow-map and occluder rendering support for GPU lighting passes.
pub mod gpu_shadows;
/// Shared renderer state that owns wgpu devices, surfaces, and frame resources.
pub mod gpu_state;
/// Tessellation helpers that convert 2D primitives into GPU vertex/index buffers.
pub mod gpu_tess;
/// Common GPU-facing structs, enums, and packed data layouts used by render passes.
pub mod gpu_types;
/// Per-frame image post-processing effect descriptors and shader parameter blocks.
pub mod image_effect;
/// GPU-uploadable mesh geometry: vertices, indices, and draw modes.
pub mod mesh;
/// Wavefront OBJ parser producing `Mesh` instances from `.obj` text data.
#[cfg(feature = "obj-loader")]
pub mod obj_loader;
/// Post-effect pipeline: chain of `ShaderPassDescriptor`s applied after the main pass.
pub mod postfx_pipeline;
/// Fullscreen province map shader pipeline and bind-group setup.
pub mod province_map_pipeline;
/// `RenderCommand` enum and all draw-state types consumed by `GpuRenderer`.
pub mod renderer;
/// User-uploaded WGSL shader wrappers and `UniformValue` binding types.
pub mod shader;
/// Compound 2D shape builder using `ShapeCommand` sequences.
pub mod shape;
/// CPU fallback for evidence-oriented screenshot capture from queued render commands.
pub mod software_capture;
pub use canvas::Canvas;
pub use decal_surface::DecalSurface;
pub use draw_layer::DrawLayer;
pub use font::Font;
pub use gpu_pipeline::GpuStencilMode;
pub use gpu_renderer::GpuRenderer;
pub use image_effect::ShaderPassDescriptor;
pub use mesh::{Mesh, MeshDrawMode, MeshVertex};
pub use postfx_pipeline::PostFxPipeline;
pub use province_map_pipeline::ProvinceMapPipeline;
pub use renderer::StencilMode;
pub use renderer::{
    BlendMode, CompareMode, DepthMode, DrawMode, DrawableKind, RenderCommand, StencilAction,
    TextAlign, TextureData,
};
pub use shader::{Shader, UniformValue};
pub use shape::{CompoundShape, ShapeCommand};
