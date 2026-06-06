//! This module provides the engine render stack, from command definitions and asset-side helpers to the concrete GPU backend.
//! It covers shapes, text, textures, meshes, decals, canvas targets, shaders, and full-screen image effects under one rendering vocabulary.
//! At the highest level it is the subsystem that turns frame-local draw intent into ordered, composited visual output.

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
pub(crate) mod gpu_types;
pub(crate) mod gpu_state;
pub(crate) mod gpu_pipeline;
pub(crate) mod gpu_shaders;
pub(crate) mod gpu_light;
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
    StencilMode, TextAlign, TextureData,
};
pub use shader::{Shader, UniformValue};
pub use shape::{CompoundShape, ShapeCommand};
