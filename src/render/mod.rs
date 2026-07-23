//! Exports the render subsystem surface that groups canvases, GPU owners, shapes, shaders, and pipelines.
//! Acts as the render ownership index so callers can map a rendering concern to its concrete Rust owner file.
//! Centralizes module visibility and re-exports instead of storing live frame state or issuing draw work itself.
//! Connects front-end draw commands, geometry assets, shader tools, and GPU execution modules into one stack.
//! Provides the first navigation point when tracing whether a render issue belongs to shaders, resources, or passes.
//! Keeps the public render surface coherent while allowing narrow files like mesh or image_effect to stay focused.
//! Open this file first when adding a render owner or changing shared render API re-export policy.
//! Use it to locate the right implementation file before editing orchestration, resources, geometry, or shaders.

/// CPU-side canvas API: paint-style pixel and shape commands on an `ImageData` surface.
pub mod canvas;
/// Decal surface for projecting persistent paint-style marks onto world geometry.
pub mod decal_surface;
/// Draw-layer abstraction: ordered buckets of `RenderCommand`s flushed each frame.
pub mod draw_layer;
/// GPU canvas render-target synchronization and dimension helpers.
pub mod gpu_canvas_pass;
/// Prepared draw encoding into active GPU render passes.
pub mod gpu_draw_encode;
/// Per-frame prepared draw list building and coalescing helpers.
pub mod gpu_frame_builder;
/// GPU light extraction, uniform packing, and light pass helpers.
pub mod gpu_light;
/// High-level wgpu pipeline descriptors and render pipeline construction helpers.
pub mod gpu_pipeline;
/// wgpu device/queue wrapper, pipeline creation, render-pass execution.
pub mod gpu_renderer;
/// GPU resource upload and bind-group management for textures, buffers, and samplers.
pub mod gpu_resources;
/// GPU surface readback helpers for screenshot capture.
pub mod gpu_screenshot_readback;
/// Custom shader cache rebuilds, uniform uploads, and custom pipeline lookup.
pub mod gpu_shader_cache;
/// WGSL shader loading, preprocessing, and module creation utilities.
pub mod gpu_shaders;
/// Shadow-map and occluder rendering support for GPU lighting passes.
pub mod gpu_shadows;
/// Registered compound-shape replay into GPU flat-color draw buffers.
pub mod gpu_shape_replay;
/// Shared renderer state that owns wgpu devices, surfaces, and frame resources.
pub mod gpu_state;
/// Tessellation helpers that convert 2D primitives into GPU vertex/index buffers.
pub mod gpu_tess;
/// Font-atlas text replay into GPU textured draw buffers.
pub mod gpu_text_replay;
/// Common GPU-facing structs, enums, and packed data layouts used by render passes.
pub mod gpu_types;
/// Per-frame image post-processing effect descriptors and shader parameter blocks.
pub mod image_effect;
/// Central validation for render command scalar, color, topology, and count invariants.
pub mod input_validation;
/// GPU-uploadable mesh geometry: vertices, indices, and draw modes.
pub mod mesh;
/// Wavefront OBJ parser producing `Mesh` instances from `.obj` text data.
#[cfg(feature = "obj-loader")]
pub mod obj_loader;
/// Headless GPU executor for offline `ImageData` shader processing.
pub mod offline_image_shader;
/// Post-effect pipeline: chain of `ShaderPassDescriptor`s applied after the main pass.
pub mod postfx_pipeline;
/// Fullscreen province map shader pipeline and bind-group setup.
pub mod province_map_pipeline;
/// Per-frame diagnostics for skipped render commands and invalid render resources.
pub mod render_diagnostics;
/// `RenderCommand` enum and all draw-state types consumed by `GpuRenderer`.
pub mod renderer;
/// User-uploaded WGSL shader wrappers and `UniformValue` binding types.
pub mod shader;
/// Compound 2D shape builder using `ShapeCommand` sequences.
pub mod shape;
/// CPU fallback for evidence-oriented screenshot capture from queued render commands.
pub mod software_capture;
/// MagicaVoxel `.vox` parser and palette-coloured surface mesh generation.
#[cfg(feature = "voxel-loader")]
pub mod voxel_loader;
pub use canvas::Canvas;
pub use decal_surface::DecalSurface;
pub use draw_layer::DrawLayer;
pub use gpu_pipeline::GpuStencilMode;
pub use gpu_renderer::GpuRenderer;
pub use image_effect::ShaderPassDescriptor;
pub use mesh::{Mesh, MeshDrawMode, MeshVertex};
pub use postfx_pipeline::PostFxPipeline;
pub use province_map_pipeline::ProvinceMapPipeline;
pub use render_diagnostics::RenderDiagnostics;
pub use renderer::StencilMode;
pub use renderer::{
    BlendMode, CompareMode, DepthMode, DrawMode, DrawableKind, RenderCommand,
    RenderCommandCategory, StencilAction, TextAlign, TextureData,
};
pub use shader::{Shader, ShaderTarget, UniformValue};
pub use shape::{CompoundShape, ShapeCommand};
