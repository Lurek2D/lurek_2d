use crate::runtime::resource_keys::{CanvasKey};

/// GPU texture with its bind group; held in slot-maps keyed by `TextureKey` / `CanvasKey` / `FontKey`.
pub(crate) struct GpuTexture {
    /// Owned wgpu texture object (prefixed with `_` to avoid unused-field warnings).
    pub(crate) pub(crate) _texture: wgpu::Texture,
    /// View used as shader resource.
    pub(crate) pub(crate) view: wgpu::TextureView,
    /// Bind group pairing `view` with its sampler.
    pub(crate) pub(crate) bind_group: wgpu::BindGroup,
    /// Pixel width.
    pub(crate) pub(crate) width: u32,
    /// Pixel height.
    pub(crate) pub(crate) height: u32,
}
/// Combined depth/stencil render attachment; created lazily per render target.
pub(crate) struct DepthStencilTarget {
    /// Owned texture (unused directly after view creation).
    pub(crate) pub(crate) _texture: wgpu::Texture,
    /// View bound as depth/stencil attachment.
    pub(crate) pub(crate) view: wgpu::TextureView,
    /// Pixel width matching its render target.
    pub(crate) pub(crate) width: u32,
    /// Pixel height matching its render target.
    pub(crate) pub(crate) height: u32,
}
/// Mapped readback buffer pending async `device.poll` before screenshot bytes are copied.
pub(crate) struct PendingSurfaceReadback {
    /// Mappable output buffer.
    pub(crate) pub(crate) buffer: wgpu::Buffer,
    /// Row stride in bytes including wgpu alignment padding.
    pub(crate) pub(crate) padded_bytes_per_row: u32,
    /// Image width in pixels.
    pub(crate) pub(crate) width: u32,
    /// Image height in pixels.
    pub(crate) pub(crate) height: u32,
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
