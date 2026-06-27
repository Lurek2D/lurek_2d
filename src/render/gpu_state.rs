//! Owns render behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps render data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
//! Defines how gpu state data is validated, transformed, or stored before neighboring systems use it.
//! Owns render behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on gpu state behavior while Lua registration stays elsewhere.
//! Documents the boundary where render code accepts inputs, reports errors, or updates state.

use crate::render::gpu_types::{
    ColorVertex, InstanceData, ParticleVertex, PreparedDraw, TexVertex,
};
use crate::runtime::resource_keys::{InstanceBufferKey, StaticGeometryKey};

/// GPU texture with its bind group; held in slot-maps keyed by `TextureKey` / `CanvasKey` / `FontKey`.
///
/// # Fields
/// - `_texture` - Owned texture kept alive while the view and bind group are in use.
/// - `view` - Texture view bound by render and shader passes.
/// - `bind_group` - Texture/sampler bind group for draw submission.
/// - `width` / `height` - Pixel dimensions used for target validation and stats.
/// - `source_revision` - CPU texture revision used to detect stale GPU uploads.
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
    /// CPU texture revision represented by this GPU allocation.
    pub(crate) source_revision: u64,
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

/// CPU-side vectors reused while building and batching one GPU frame.
///
/// The buffers keep their high-water capacity across frames. Call `clear_for_frame` before reuse.
#[derive(Default)]
pub struct FrameRenderBuffers {
    /// Flat-color vertices accumulated before GPU upload.
    pub color_verts: Vec<ColorVertex>,
    /// Flat-color indices accumulated before GPU upload.
    pub color_idxs: Vec<u32>,
    /// Textured vertices accumulated before GPU upload.
    pub tex_verts: Vec<TexVertex>,
    /// Textured indices accumulated before GPU upload.
    pub tex_idxs: Vec<u32>,
    /// Particle shader vertices accumulated before GPU upload.
    pub particle_verts: Vec<ParticleVertex>,
    /// Particle shader indices accumulated before GPU upload.
    pub particle_idxs: Vec<u32>,
    /// Prepared draw calls generated from render commands.
    pub draws: Vec<PreparedDraw>,
    /// Per-frame instance transforms uploaded to the shared instance buffer.
    pub instances: Vec<InstanceData>,
    /// Reusable flat-color vertex scratch for one command's tessellation.
    pub scratch_color_verts: Vec<ColorVertex>,
    /// Reusable flat-color index scratch for one command's tessellation.
    pub scratch_color_idxs: Vec<u32>,
    /// Reusable textured vertex scratch for one command's tessellation.
    pub scratch_tex_verts: Vec<TexVertex>,
    /// Reusable textured index scratch for one command's tessellation.
    pub scratch_tex_idxs: Vec<u32>,
    /// Scratch draw list used by the batching merge pass.
    pub merged_draws: Vec<PreparedDraw>,
}

/// Reservation sizes for frame-local render buffers.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct FrameRenderBufferReservations {
    /// Flat-color vertex reservation.
    pub color_verts: usize,
    /// Flat-color index reservation.
    pub color_idxs: usize,
    /// Textured vertex reservation.
    pub tex_verts: usize,
    /// Textured index reservation.
    pub tex_idxs: usize,
    /// Particle shader vertex reservation.
    pub particle_verts: usize,
    /// Particle shader index reservation.
    pub particle_idxs: usize,
    /// Prepared draw reservation.
    pub draws: usize,
    /// Instanced draw reservation.
    pub instances: usize,
}

impl FrameRenderBuffers {
    /// Clear all frame buffers while retaining allocated capacity for the next frame.
    pub fn clear_for_frame(&mut self) {
        self.color_verts.clear();
        self.color_idxs.clear();
        self.tex_verts.clear();
        self.tex_idxs.clear();
        self.particle_verts.clear();
        self.particle_idxs.clear();
        self.draws.clear();
        self.instances.clear();
        self.scratch_color_verts.clear();
        self.scratch_color_idxs.clear();
        self.scratch_tex_verts.clear();
        self.scratch_tex_idxs.clear();
        self.merged_draws.clear();
    }

    /// Reserve enough capacity for a known frame size without changing current lengths.
    pub fn reserve_for_frame(&mut self, reservations: FrameRenderBufferReservations) {
        reserve_to_capacity(&mut self.color_verts, reservations.color_verts);
        reserve_to_capacity(&mut self.color_idxs, reservations.color_idxs);
        reserve_to_capacity(&mut self.tex_verts, reservations.tex_verts);
        reserve_to_capacity(&mut self.tex_idxs, reservations.tex_idxs);
        reserve_to_capacity(&mut self.particle_verts, reservations.particle_verts);
        reserve_to_capacity(&mut self.particle_idxs, reservations.particle_idxs);
        reserve_to_capacity(&mut self.draws, reservations.draws);
        reserve_to_capacity(&mut self.instances, reservations.instances);
        reserve_to_capacity(&mut self.merged_draws, reservations.draws);
    }

    /// Return current vector lengths in a stable diagnostic order.
    pub fn lengths(&self) -> [usize; 13] {
        [
            self.color_verts.len(),
            self.color_idxs.len(),
            self.tex_verts.len(),
            self.tex_idxs.len(),
            self.particle_verts.len(),
            self.particle_idxs.len(),
            self.draws.len(),
            self.instances.len(),
            self.scratch_color_verts.len(),
            self.scratch_color_idxs.len(),
            self.scratch_tex_verts.len(),
            self.scratch_tex_idxs.len(),
            self.merged_draws.len(),
        ]
    }

    /// Return current vector capacities in the same order as `lengths`.
    pub fn capacities(&self) -> [usize; 13] {
        [
            self.color_verts.capacity(),
            self.color_idxs.capacity(),
            self.tex_verts.capacity(),
            self.tex_idxs.capacity(),
            self.particle_verts.capacity(),
            self.particle_idxs.capacity(),
            self.draws.capacity(),
            self.instances.capacity(),
            self.scratch_color_verts.capacity(),
            self.scratch_color_idxs.capacity(),
            self.scratch_tex_verts.capacity(),
            self.scratch_tex_idxs.capacity(),
            self.merged_draws.capacity(),
        ]
    }
}

fn reserve_to_capacity<T>(values: &mut Vec<T>, target_capacity: usize) {
    if values.capacity() < target_capacity {
        values.reserve(target_capacity - values.capacity());
    }
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
