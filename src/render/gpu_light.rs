//! Defines GPU-side light pass limits and layouts that keep deferred lighting and shadow memory bounded.
//! Holds the light-state contract used by the renderer to size additive passes and shadow-related resources.
//! Keeps light-capacity and layout policy separate from the frame loop that consumes those resources.
//! Open this file when light buffer limits or deferred-light layout assumptions need coordinated changes.

/// Resolution of the shadow atlas in pixels.
pub const SHADOW_MAP_RES: usize = 256;
/// Maximum number of shadow lights supported per frame.
pub const MAX_SHADOW_LIGHTS: usize = 128;
/// Size of a compute shader workgroup.
pub(crate) const SHADOW_COMPUTE_WORKGROUP_SIZE: u32 = 64;

/// GPU state for the additive light accumulation and shadow-atlas composite pass.
pub struct LightGpuState {
    #[allow(dead_code)]
    /// Light accumulation RGBA texture (kept alive for its view).
    pub(crate) accum_texture: wgpu::Texture,
    /// View bound as the accumulation render-attachment.
    pub(crate) accum_view: wgpu::TextureView,
    /// Bind group for sampling the accumulation texture in the composite pass.
    pub(crate) accum_bind_group: wgpu::BindGroup,
    /// Additive light blending pipeline.
    pub(crate) additive_pipeline: wgpu::RenderPipeline,
    /// Final composite (multiply) pipeline.
    pub(crate) composite_pipeline: wgpu::RenderPipeline,
    /// Vertex buffer for light quads.
    pub(crate) vertex_buffer: wgpu::Buffer,
    /// Index buffer for light quads.
    pub(crate) index_buffer: wgpu::Buffer,
    #[allow(dead_code)]
    /// Shadow atlas texture storing 1-D shadow maps for each light.
    pub(crate) shadow_atlas_texture: wgpu::Texture,
    #[allow(dead_code)]
    /// View of the shadow atlas (kept alive; bind group holds a reference).
    pub(crate) shadow_atlas_view: wgpu::TextureView,
    /// Bind group for sampling the shadow atlas in the light pass shader.
    pub(crate) shadow_atlas_bind_group: wgpu::BindGroup,
    /// Layout for sampling the shadow atlas in built-in and custom light shaders.
    pub(crate) shadow_atlas_bind_group_layout: wgpu::BindGroupLayout,
    /// Layout required for the compute shadow dispatch.
    pub(crate) shadow_compute_bind_group_layout: wgpu::BindGroupLayout,
    /// Bind group supplying edges and params to the compute shader.
    pub(crate) shadow_compute_bind_group: wgpu::BindGroup,
    /// Compiled compute pipeline for shadow map generation.
    pub(crate) shadow_compute_pipeline: wgpu::ComputePipeline,
    /// Dynamic buffer containing active shadow caster edges.
    pub(crate) shadow_edge_buffer: wgpu::Buffer,
    /// Current allocated capacity in edges for the shadow buffer.
    pub(crate) shadow_edge_capacity: usize,
    /// Uniform buffer containing the shadow dispatch parameters.
    pub(crate) shadow_params_buffer: wgpu::Buffer,
    /// Pixel width of accumulation and shadow-atlas textures.
    pub(crate) width: u32,
    /// Pixel height of the accumulation texture.
    pub(crate) height: u32,
}
