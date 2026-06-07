//! - Implements the GPU resource registry to track persistent mesh and buffer lifetimes.
//! - Stores texture, canvas, and font allocations within structured slotmaps.
//! - Caches static draw geometry descriptors, avoiding frame allocations.
//! - Manages depth-stencil buffer views matching current canvas dimensions.
//! - Feeds dynamic instance buffers to the GPU for batch transformations.
//! - Supplies empty default targets and textures for resource fallbacks.
//! - Retains bind groups pairing textures with active filter samplers.
//! - Holds depth-stencil states, target formats, and multi-sampling options.
//! - Facilitates frame resource reuse, minimizing CPU-GPU synchronization overhead.
//! - Maps texture IDs to raw wgpu texture handles securely.
use crate::runtime::resource_keys::{StaticGeometryKey, InstanceBufferKey};

/// GPU texture with its bind group; held in slot-maps keyed by `TextureKey` / `CanvasKey` / `FontKey`.
pub struct GpuTexture {
    /// Owned wgpu texture object (prefixed with `_` to avoid unused-field warnings).
    pub(crate) _texture: wgpu::Texture,
    /// View used as shader resource.
    pub(crate) view: wgpu::TextureView,
    /// Bind group pairing `view` with its sampler.
    pub(crate) bind_group: wgpu::BindGroup,
    /// Pixel width.
    pub(crate) width: u32,
    /// Pixel height.
    pub(crate) height: u32,
}
/// Combined depth/stencil render attachment; created lazily per render target.
pub struct DepthStencilTarget {
    /// Owned texture (unused directly after view creation).
    pub(crate) _texture: wgpu::Texture,
    /// View bound as depth/stencil attachment.
    pub(crate) view: wgpu::TextureView,
    /// Pixel width matching its render target.
    pub(crate) width: u32,
    /// Pixel height matching its render target.
    pub(crate) height: u32,
}
/// Mapped readback buffer pending async `device.poll` before screenshot bytes are copied.
pub struct PendingSurfaceReadback {
    /// Mappable output buffer.
    pub(crate) buffer: wgpu::Buffer,
    /// Row stride in bytes including wgpu alignment padding.
    pub(crate) padded_bytes_per_row: u32,
    /// Image width in pixels.
    pub(crate) width: u32,
    /// Image height in pixels.
    pub(crate) height: u32,
}
/// Per-frame GPU draw statistics exposed to the Lua profiler API.
#[derive(Debug, Default, Clone)]
pub struct RenderStats {
    /// Total number of GPU draw calls issued this frame.
    pub draw_calls: u32,
    /// Number of texture bind-group switches this frame.
    pub texture_switches: u32,
    /// Number of canvas render-target switches this frame.
    pub canvas_switches: u32,
    /// Number of shader pipeline switches this frame.
    pub shader_switches: u32,
    /// Number of draw calls merged into batches this frame.
    pub batched_draws: u32,
    /// CPU time spent in `render_frame` this frame in milliseconds.
    pub cpu_render_ms: f32,
}


/// Cache entry for uploaded static geometry buffers.
#[allow(dead_code)]
pub struct StaticGeometryCacheEntry {
    /// Vertex buffer handle.
    pub vertex_buffer: wgpu::Buffer,
    /// Index buffer handle.
    pub index_buffer: wgpu::Buffer,
    /// Total number of indices.
    pub index_count: u32,
    /// Vertex layout used by this geometry.
    pub geometry_kind: crate::render::gpu_pipeline::GeometryKind,
    /// Optional texture key for textured static geometry.
    pub texture: Option<crate::runtime::resource_keys::TextureKey>,
}

/// Cache entry for uploaded instance transforms.
#[allow(dead_code)]
pub struct InstanceBufferCacheEntry {
    /// Instance buffer handle.
    pub buffer: wgpu::Buffer,
    /// Number of valid instances in the buffer.
    pub count: u32,
}

/// Main lookup registry for persistent geometry uploads.
#[allow(dead_code)]
pub struct GpuMeshCache {
    /// Static geometry buffer bindings.
    pub static_geometry: std::collections::HashMap<StaticGeometryKey, StaticGeometryCacheEntry>,
    /// Dynamic instancing buffer bindings.
    pub instance_buffers: std::collections::HashMap<InstanceBufferKey, InstanceBufferCacheEntry>,
}

/// Initialize empty geometry cache containers.
impl Default for GpuMeshCache {
    fn default() -> Self {
        Self {
            static_geometry: std::collections::HashMap::new(),
            instance_buffers: std::collections::HashMap::new(),
        }
    }
}