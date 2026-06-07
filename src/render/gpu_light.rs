//! - Enforces memory boundaries and layout constraints for the deferred shadow mapping pass.
//! - Maximum capacity limits on light sources are defined here to guarantee stable frame times.
//! - The structures defined here instruct the renderer how to process additive light passes.
//! - Integrates with shadow compute parameters and vertex bindings for render passes.
//! - Manages light texture resources, viewport dimensions, and bind group indices.
//! - Specifies constants such as shadow map resolution and compute shader workgroup size.
//! - Handles structures representing light metadata, positions, colors, and attenuation.
//! - Restricts memory allocations by allocating fixed size buffers for light sources.

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
