//! Defines raw binary structures representing GPU vertex layouts. `render/gpu_types` delivers the gpu types implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Packs memory layouts tightly using bytemuck to ensure copy compliance. The file owns or coordinates data contracts including `ColorVertex`, `TexVertex`, `LightVertex`, `ShadowEdgeGpu`, `ShadowComputeParams`, and 7 more, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Groups properties like position, texture coordinates, color tints, and normals. Public callable behavior is centered on no named public items, while method-level behavior such as no named public items stays attached to the local data model and invariants.
//! Encapsulates command batching metadata for coalescing draw dispatches. Runtime integration reaches sibling engine areas through crate modules `render`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
//! Tracks instance transformation data for hardware instancing buffers. External integration uses `bytemuck`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

use crate::render::gpu_pipeline::GeometryKind;
use crate::render::renderer::BlendMode;
use crate::runtime::resource_keys::{CanvasKey, FontKey, ShaderKey, TextureKey};
use bytemuck::{Pod, Zeroable};

/// Flat-shaded vertex with `position` and per-vertex `color`.
#[repr(C)]
#[derive(Copy, Clone, Pod, Zeroable)]
pub struct ColorVertex {
    /// NDC/screen-space XY position.
    pub(crate) position: [f32; 2],
    /// RGBA vertex color.
    pub(crate) color: [f32; 4],
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
/// Light-pass vertex with position, UV, RGBA tint, shadow map value, and shadow parameters.
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
    /// Shadow sampling parameters: `[radius, mode, texel_size, _pad]`.
    pub(crate) shadow_params: [f32; 4],
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

/// Packed 2D instance transform data: 3 columns of `vec2<f32>`.
#[repr(C)]
#[derive(Copy, Clone, Debug, Pod, Zeroable)]
pub struct InstanceData {
    /// Column 0 of transformation matrix (scale/rotate).
    pub col0: [f32; 2],
    /// Column 1 of transformation matrix (scale/rotate).
    pub col1: [f32; 2],
    /// Column 2 of transformation matrix (translation).
    pub col2: [f32; 2],
}

impl Default for InstanceData {
    fn default() -> Self {
        Self {
            col0: [1.0, 0.0],
            col1: [0.0, 1.0],
            col2: [0.0, 0.0],
        }
    }
}

impl From<crate::math::Mat3> for InstanceData {
    fn from(m: crate::math::Mat3) -> Self {
        Self {
            col0: [m.m[0][0], m.m[1][0]],
            col1: [m.m[0][1], m.m[1][1]],
            col2: [m.m[0][2], m.m[1][2]],
        }
    }
}
