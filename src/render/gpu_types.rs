use bytemuck::{Pod, Zeroable};
use crate::runtime::resource_keys::{CanvasKey, FontKey, TextureKey, ShaderKey};
use crate::render::gpu_pipeline::{GeometryKind, StencilMode};
use crate::render::renderer::BlendMode;

/// Flat-shaded vertex with `position` and per-vertex `color`.
#[repr(C)]
#[derive(Copy, Clone, Pod, Zeroable)]
pub(crate) struct ColorVertex {
    /// NDC/screen-space XY position.
    pub(crate) pub(crate) position: [f32; 2],
    /// RGBA vertex color.
    pub(crate) pub(crate) color: [f32; 4],
}
/// Textured vertex with position, UV, RGBA tint, and homogeneous W depth for perspective correction.
#[repr(C)]
#[derive(Copy, Clone, Pod, Zeroable)]
pub(crate) struct TexVertex {
    /// NDC/screen-space XY position.
    pub(crate) pub(crate) position: [f32; 2],
    /// Texture UV coordinates.
    pub(crate) pub(crate) uv: [f32; 2],
    /// Per-vertex RGBA tint.
    pub(crate) pub(crate) color: [f32; 4],
    /// Homogeneous W value for perspective-correct UV interpolation.
    pub(crate) pub(crate) w_depth: f32,
    /// Padding to meet `Pod` alignment requirements.
    pub(crate) pub(crate) _pad: [f32; 3],
}
/// Light-pass vertex with position, UV, RGBA tint, shadow map value, and shadow parameters.
#[repr(C)]
#[derive(Copy, Clone, Pod, Zeroable)]
pub(crate) struct LightVertex {
    /// NDC/screen-space XY position.
    pub(crate) pub(crate) position: [f32; 2],
    /// Light-quad UV coordinates.
    pub(crate) pub(crate) uv: [f32; 2],
    /// Per-vertex RGBA tint.
    pub(crate) pub(crate) color: [f32; 4],
    /// Normalised 0..1 shadow map value for this vertex.
    pub(crate) pub(crate) shadow_v: f32,
    /// Shadow sampling parameters: `[radius, mode, texel_size, _pad]`.
    pub(crate) pub(crate) shadow_params: [f32; 4],
}
#[repr(C)]
#[derive(Copy, Clone, Pod, Zeroable)]
pub(crate) struct ShadowEdgeGpu {
    pub(crate) pub(crate) ax: f32,
    pub(crate) pub(crate) ay: f32,
    pub(crate) pub(crate) sx: f32,
    pub(crate) pub(crate) sy: f32,
}
#[repr(C)]
#[derive(Copy, Clone, Pod, Zeroable)]
pub(crate) struct ShadowComputeParams {
    pub(crate) pub(crate) inv_radius: f32,
    pub(crate) pub(crate) edge_count: u32,
    pub(crate) pub(crate) row: u32,
    pub(crate) pub(crate) _pad: u32,
}
pub(crate) struct ShadowDispatchInput<'a> {
    pub(crate) pub(crate) row: usize,
    pub(crate) pub(crate) light_x: f32,
    pub(crate) pub(crate) light_y: f32,
    pub(crate) pub(crate) light_radius: f32,
    pub(crate) pub(crate) shadow_mask: u16,
    pub(crate) pub(crate) occluders: &'a [&'a crate::light::occluder::Occluder],
}
/// Per-frame viewport uniform uploaded to the GPU: pixel dimensions, time, and camera transform.
#[repr(C)]
#[derive(Copy, Clone, Pod, Zeroable)]
pub(crate) struct ViewportUniform {
    /// Framebuffer pixel dimensions `[width, height]`.
    pub(crate) pub(crate) size: [f32; 2],
    /// Engine time in seconds, passed to shaders.
    pub(crate) pub(crate) time: f32,
    /// Alignment padding.
    pub(crate) pub(crate) _pad: f32,
    /// Column 0 of the 3×3 view transform.
    pub(crate) pub(crate) view_col0: [f32; 4],
    /// Column 1 of the 3×3 view transform.
    pub(crate) pub(crate) view_col1: [f32; 4],
    /// Column 2 of the 3×3 view transform.
    pub(crate) pub(crate) view_col2: [f32; 4],
}
/// Identifies a GPU texture source during draw batching.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub(crate) enum TexRef {
    /// A sprite/image texture uploaded via `upload_texture`.
    pub(crate) Texture(TextureKey),
    /// An off-screen canvas render target.
    pub(crate) Canvas(CanvasKey),
    /// A bitmap font glyph atlas.
    pub(crate) FontAtlas(FontKey),
}
/// Maximum flat-color vertex count before the buffer must grow.
const MAX_COLOR_VERTS: u64 = 1 << 19;
/// Maximum flat-color index count before the buffer must grow.
const MAX_COLOR_IDXS: u64 = 1 << 21;
/// Maximum textured vertex count before the buffer must grow.
const MAX_TEX_VERTS: u64 = 1 << 14;
/// Maximum textured index count before the buffer must grow.
const MAX_TEX_IDXS: u64 = 1 << 16;
/// Maximum number of light quads batched per frame.
const MAX_LIGHT_QUADS: usize = 128;
/// Optional pixel-space scissor rectangle `(x, y, width, height)`.
type ScissorRect = Option<(u32, u32, u32, u32)>;
/// Identifies the active render target during a frame.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub(crate) enum RenderTargetId {
    /// The main window surface.
    Screen,
    /// An off-screen canvas texture.
    pub(crate) Canvas(CanvasKey),
}
/// A fully resolved draw call ready to be encoded in the GPU render pass.
#[derive(Debug, Clone, Copy)]
pub(crate) struct PreparedDraw {
    /// Render target this draw writes to.
    pub(crate) pub(crate) target: RenderTargetId,
    /// Vertex layout (color or texture).
    pub(crate) pub(crate) geometry: GeometryKind,
    /// Texture bound for this draw, or `None` for flat-color.
    pub(crate) pub(crate) texture_ref: Option<TexRef>,
    /// First index in the shared index buffer.
    pub(crate) pub(crate) idx_start: u32,
    /// Number of indices for this draw call.
    pub(crate) pub(crate) idx_count: u32,
    /// Blend mode for this draw.
    pub(crate) pub(crate) blend_mode: BlendMode,
    /// Optional scissor rectangle in pixels.
    pub(crate) pub(crate) scissor: ScissorRect,
    /// Channel write-mask bitmask.
    pub(crate) pub(crate) color_mask_bits: u32,
    /// User shader override, or `None` for the built-in shader.
    pub(crate) pub(crate) shader: Option<ShaderKey>,
    /// Stencil operation mode.
    pub(crate) pub(crate) stencil_mode: StencilMode,
    /// Stencil reference value used by `Write` and `Test` modes.
    pub(crate) pub(crate) stencil_reference: u32,
}
