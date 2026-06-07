//! - Unified entry point for the Lurek2D render module stack.
//! - Exposes submodules for canvases, decal surfaces, shapes, and font managers.
//! - Declares modules for the GPU-accelerated renderer and compiled pipelines.
//! - Unifies draw interfaces, shader uniform mappings, and shader passes.
//! - Bridges game runtime draw buffers to backend hardware rendering layers.
//! - Conforms to the binding rules, exposing all public rendering APIs.

/// CPU-side canvas API: paint-style pixel and shape commands on an `ImageData` surface.
pub mod canvas;
/// Decal surface for projecting persistent paint-style marks onto world geometry.
pub mod decal_surface;
/// Draw-layer abstraction: ordered buckets of `RenderCommand`s flushed each frame.
pub mod draw_layer;
/// Fontdue-backed font rasterisation and glyph atlas management.
pub mod font;
/// wgpu device/queue wrapper, pipeline creation, render-pass execution.
pub mod gpu_renderer;
pub mod gpu_types;
pub mod gpu_state;
pub mod gpu_pipeline;
pub mod gpu_shaders;
pub mod gpu_light;
pub mod gpu_tess;
pub mod gpu_resources;
pub mod gpu_shadows;
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
pub use canvas::Canvas;
pub use decal_surface::DecalSurface;
pub use draw_layer::DrawLayer;
pub use font::Font;
pub use gpu_renderer::GpuRenderer;
pub use image_effect::ShaderPassDescriptor;
pub use mesh::{Mesh, MeshDrawMode, MeshVertex};
pub use postfx_pipeline::PostFxPipeline;
pub use province_map_pipeline::ProvinceMapPipeline;
pub use renderer::{
    BlendMode, CompareMode, DepthMode, DrawMode, DrawableKind, RenderCommand, StencilAction,
    TextAlign, TextureData,
};
pub use shader::{Shader, UniformValue};
pub use shape::{CompoundShape, ShapeCommand};
pub use gpu_pipeline::GpuStencilMode;
pub use renderer::StencilMode;
