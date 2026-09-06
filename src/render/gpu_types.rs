//! Defines the bytemuck-safe raw GPU structs used for vertices, uniforms, shadow edges, and draw batching.
//! Packs positions, colors, uv data, normals, and instance transforms into layouts copied directly to buffers.
//! Keeps binary layout contracts centralized so renderer, shader, and upload code agree on memory shape.
//! Stores batching metadata that later passes use to coalesce draw dispatches with compatible GPU state.
//! Acts as the binary-ABI boundary between Rust-side render state and WGSL-visible buffer contents.
//! Open this file when GPU struct layout, bytemuck compatibility, or instance data packing is incorrect.

use crate::render::gpu_pipeline::GeometryKind;
use crate::render::renderer::BlendMode;
use crate::runtime::resource_keys::{CanvasKey, FontKey, ShaderKey, TextureKey};
use bytemuck::{Pod, Zeroable};

/// Flat-shaded vertex with `position` and per-vertex `color`.
#[repr(C)]
#[derive(Copy, Clone, Debug, Pod, Zeroable)]
pub struct ColorVertex {
    /// NDC/screen-space XY position.
    pub(crate) position: [f32; 2],
    /// RGBA vertex color.
    pub(crate) color: [f32; 4],
}
/// Particle vertex carrying color plus render-time particle shader inputs.
#[repr(C)]
#[derive(Copy, Clone, Pod, Zeroable)]
pub struct ParticleVertex {
    /// Screen-space XY position after particle shape expansion.
    pub(crate) position: [f32; 2],
    /// Per-vertex particle color.
    pub(crate) color: [f32; 4],
    /// Particle-local UV coordinate.
    pub(crate) uv: [f32; 2],
    /// Particle-local position before emitter/world offset.
    pub(crate) local_pos: [f32; 2],
    /// Particle world-space center position.
    pub(crate) world_pos: [f32; 2],
    /// Particle velocity in world units per second.
    pub(crate) velocity: [f32; 2],
    /// Normalized age in `[0, 1]`.
    pub(crate) normalized_age: f32,
    /// Original lifetime in seconds.
    pub(crate) lifetime: f32,
    /// Stable random seed converted to `f32` for WGSL visual variation.
    pub(crate) seed: f32,
    /// Padding to keep a 16-byte aligned stride.
    pub(crate) _pad: f32,
}
/// Textured vertex with position, UV, RGBA tint, and homogeneous W depth for perspective correction.
#[repr(C)]
#[derive(Copy, Clone, Pod, Zeroable)]
pub struct TexVertex {
    /// NDC/screen-space XY position.
    pub(crate) position: [f32; 2],
    /// Texture UV coordinates.
    pub(crate) uv: [f32; 2],
    /// Per-vertex RGBA tint.
    pub(crate) color: [f32; 4],
    /// Homogeneous W value for perspective-correct UV interpolation.
    pub(crate) w_depth: f32,
    /// Padding to meet `Pod` alignment requirements.
    pub(crate) _pad: [f32; 3],
}
/// Light-pass vertex with position, UV, RGBA tint, shadow map value, and custom light inputs.
#[repr(C)]
#[derive(Copy, Clone, Pod, Zeroable)]
pub struct LightVertex {
    /// NDC/screen-space XY position.
    pub(crate) position: [f32; 2],
    /// Light-quad UV coordinates.
    pub(crate) uv: [f32; 2],
    /// Per-vertex RGBA tint.
    pub(crate) color: [f32; 4],
    /// Normalised 0..1 shadow map value for this vertex.
    pub(crate) shadow_v: f32,
    /// Shadow sampling parameters: `[filter_mode, softness, texel_size, _pad]`.
    pub(crate) shadow_params: [f32; 4],
    /// World-space light center.
    pub(crate) light_pos: [f32; 2],
    /// Effective light radius in pixels.
    pub(crate) radius: f32,
    /// Effective light intensity after energy and flicker.
    pub(crate) intensity: f32,
    /// Normal-map hint passed to custom light shaders.
    pub(crate) normal_hint: [f32; 2],
    /// Ambient scene color passed to custom light shaders.
    pub(crate) ambient_color: [f32; 4],
    /// Direction vector and spot cone angles `[dir_x, dir_y, inner, outer]`.
    pub(crate) direction_spot: [f32; 4],
    /// Padding to keep the vertex layout aligned.
    pub(crate) _pad: [f32; 2],
}
/// Shadow caster edge representation for compute shader processing.
#[repr(C)]
#[derive(Copy, Clone, Pod, Zeroable)]
pub struct ShadowEdgeGpu {
    /// Anchor X coordinate.
    pub(crate) ax: f32,
    /// Anchor Y coordinate.
    pub(crate) ay: f32,
    /// Segment vector X component.
    pub(crate) sx: f32,
    /// Segment vector Y component.
    pub(crate) sy: f32,
}
/// Uniform payload for a single shadow casting dispatch.
#[repr(C)]
#[derive(Copy, Clone, Pod, Zeroable)]
pub struct ShadowComputeParams {
    /// Inverse of the light radius to normalize distances.
    pub(crate) inv_radius: f32,
    /// Total number of shadow edges in the buffer.
    pub(crate) edge_count: u32,
    /// Destination row index in the shadow atlas texture.
    pub(crate) row: u32,
    /// Alignment padding.
    pub(crate) _pad: u32,
}
/// CPU-side configuration for preparing a shadow compute dispatch.
pub struct ShadowDispatchInput<'a> {
    /// Destination row index in the shadow atlas texture.
    pub(crate) row: usize,
    /// World X coordinate of the light source.
    pub(crate) light_x: f32,
    /// World Y coordinate of the light source.
    pub(crate) light_y: f32,
    /// Maximum shadow casting distance.
    pub(crate) light_radius: f32,
    /// Bitmask for filtering occluder interactions.
    pub(crate) shadow_mask: u16,
    /// Slice of active occluders intersecting the light radius.
    pub(crate) occluders: &'a [&'a crate::light::occluder::Occluder],
}
/// Per-frame viewport uniform uploaded to the GPU: pixel dimensions, time, and camera transform.
#[repr(C)]
#[derive(Copy, Clone, Pod, Zeroable)]
pub struct ViewportUniform {
    /// Framebuffer pixel dimensions `[width, height]`.
    pub(crate) size: [f32; 2],
    /// Engine time in seconds, passed to shaders.
    pub(crate) time: f32,
    /// Alignment padding.
    pub(crate) _pad: f32,
    /// Column 0 of the 3×3 view transform.
    pub(crate) view_col0: [f32; 4],
    /// Column 1 of the 3×3 view transform.
    pub(crate) view_col1: [f32; 4],
    /// Column 2 of the 3×3 view transform.
    pub(crate) view_col2: [f32; 4],
}
/// Identifies a GPU texture source during draw batching.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum TexRef {
    /// A sprite/image texture uploaded via `upload_texture`.
    Texture(TextureKey),
    /// An off-screen canvas render target.
    Canvas(CanvasKey),
    /// A bitmap font glyph atlas.
    FontAtlas(FontKey),
}
/// Maximum flat-color vertex count before the buffer must grow.
pub const MAX_COLOR_VERTS: u64 = 1 << 19;
/// Maximum flat-color index count before the buffer must grow.
pub const MAX_COLOR_IDXS: u64 = 1 << 21;
/// Maximum particle shader vertex count before the buffer must grow.
pub const MAX_PARTICLE_VERTS: u64 = 1 << 19;
/// Maximum particle shader index count before the buffer must grow.
pub const MAX_PARTICLE_IDXS: u64 = 1 << 21;
/// Maximum textured vertex count before the buffer must grow.
pub const MAX_TEX_VERTS: u64 = 1 << 14;
/// Maximum textured index count before the buffer must grow.
pub const MAX_TEX_IDXS: u64 = 1 << 16;
/// Maximum number of light quads batched per frame.
pub const MAX_LIGHT_QUADS: usize = 128;
/// Optional pixel-space scissor rectangle `(x, y, width, height)`.
pub type ScissorRect = Option<(u32, u32, u32, u32)>;
/// Identifies the active render target during a frame.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum RenderTargetId {
    /// The main window surface.
    Screen,
    /// An off-screen canvas texture.
    Canvas(CanvasKey),
}
/// A fully resolved draw call ready to be encoded in the GPU render pass.
#[derive(Debug, Clone, Copy)]
pub struct PreparedDraw {
    /// Render target this draw writes to.
    pub target: RenderTargetId,
    /// Vertex layout (color or texture).
    pub geometry: GeometryKind,
    /// Texture bound for this draw, or `None` for flat-color.
    pub texture_ref: Option<TexRef>,
    /// First index in the shared index buffer.
    pub idx_start: u32,
    /// Number of indices for this draw call.
    pub idx_count: u32,
    /// Blend mode for this draw.
    pub blend_mode: BlendMode,
    /// Optional scissor rectangle in pixels.
    pub scissor: ScissorRect,
    /// Channel write-mask bitmask.
    pub color_mask_bits: u32,
    /// User shader override, or `None` for the built-in shader.
    pub shader: Option<ShaderKey>,
    /// Stencil operation mode.
    pub stencil_mode: crate::render::gpu_pipeline::GpuStencilMode,
    /// Stencil reference value used by `Write` and `Test` modes.
    pub stencil_reference: u32,
    /// Optional cached static geometry key.
    pub static_geometry: Option<crate::runtime::resource_keys::StaticGeometryKey>,
    /// Optional instance buffer key for instanced rendering.
    pub instance_buffer: Option<crate::runtime::resource_keys::InstanceBufferKey>,
    /// Index of the first instance to draw.
    pub instance_start: u32,
    /// Number of instances to draw.
    pub instance_count: u32,
}

/// Packed 2D instance transform data plus an RGBA multiplier.
///
/// The tint is deliberately part of the retained instance stream rather than the
/// shape mesh.  A compiled shape can therefore be recoloured without rebuilding or
/// re-uploading its static vertex/index buffers.
#[repr(C)]
#[derive(Copy, Clone, Debug, Pod, Zeroable)]
pub struct InstanceData {
    /// Column 0 of transformation matrix (scale/rotate).
    pub col0: [f32; 2],
    /// Column 1 of transformation matrix (scale/rotate).
    pub col1: [f32; 2],
    /// Column 2 of transformation matrix (translation).
    pub col2: [f32; 2],
    /// Per-instance RGBA multiplier.
    pub tint: [f32; 4],
}

impl Default for InstanceData {
    fn default() -> Self {
        Self {
            col0: [1.0, 0.0],
            col1: [0.0, 1.0],
            col2: [0.0, 0.0],
            tint: [1.0, 1.0, 1.0, 1.0],
        }
    }
}

impl From<crate::math::Mat3> for InstanceData {
    fn from(m: crate::math::Mat3) -> Self {
        Self {
            col0: [m.m[0][0], m.m[1][0]],
            col1: [m.m[0][1], m.m[1][1]],
            col2: [m.m[0][2], m.m[1][2]],
            tint: [1.0, 1.0, 1.0, 1.0],
        }
    }
}
