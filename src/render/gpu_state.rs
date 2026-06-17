//! Implements the GPU resource registry to track persistent mesh and buffer lifetimes. `render/gpu_state` delivers the gpu state implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Stores texture, canvas, and font allocations within structured slotmaps. The file owns or coordinates data contracts including `GpuTexture`, `DepthStencilTarget`, `PendingSurfaceReadback`, `RenderStats`, `StaticGeometryCacheEntry`, and 2 more, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Caches static draw geometry descriptors, avoiding frame allocations. Public callable behavior is centered on no named public items, while method-level behavior such as no named public items stays attached to the local data model and invariants.
//! Manages depth-stencil buffer views matching current canvas dimensions. Runtime integration reaches sibling engine areas through crate modules `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.

use crate::runtime::resource_keys::{InstanceBufferKey, StaticGeometryKey};

/// GPU texture with its bind group; held in slot-maps keyed by `TextureKey` / `CanvasKey` / `FontKey`.
///
/// # Fields
/// - `_texture` - Owned texture kept alive while the view and bind group are in use.
/// - `view` - Texture view bound by render and shader passes.
/// - `bind_group` - Texture/sampler bind group for draw submission.
/// - `width` / `height` - Pixel dimensions used for target validation and stats.
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
///
/// # Fields
/// - `draw_calls` - Number of GPU draw calls encoded for the frame.
/// - `texture_switches` / `canvas_switches` / `shader_switches` - State transition counters.
/// - `batched_draws` - Draws merged by batching.
/// - `cpu_render_ms` - CPU time spent in `render_frame`.
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
