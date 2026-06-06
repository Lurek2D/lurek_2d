pub(crate) const SHADOW_MAP_RES: usize = 256;
pub(crate) const MAX_SHADOW_LIGHTS: usize = 128;
pub(crate) const SHADOW_COMPUTE_WORKGROUP_SIZE: u32 = 64;

/// GPU state for the additive light accumulation and shadow-atlas composite pass.
pub(crate) struct LightGpuState {
    #[allow(dead_code)]
    /// Light accumulation RGBA texture (kept alive for its view).
    pub(crate) pub(crate) accum_texture: wgpu::Texture,
    /// View bound as the accumulation render-attachment.
    pub(crate) pub(crate) accum_view: wgpu::TextureView,
    /// Bind group for sampling the accumulation texture in the composite pass.
    pub(crate) pub(crate) accum_bind_group: wgpu::BindGroup,
    /// Additive light blending pipeline.
    pub(crate) pub(crate) additive_pipeline: wgpu::RenderPipeline,
    /// Final composite (multiply) pipeline.
    pub(crate) pub(crate) composite_pipeline: wgpu::RenderPipeline,
    /// Vertex buffer for light quads.
    pub(crate) pub(crate) vertex_buffer: wgpu::Buffer,
    /// Index buffer for light quads.
    pub(crate) pub(crate) index_buffer: wgpu::Buffer,
    #[allow(dead_code)]
    /// Shadow atlas texture storing 1-D shadow maps for each light.
    pub(crate) pub(crate) shadow_atlas_texture: wgpu::Texture,
    #[allow(dead_code)]
    /// View of the shadow atlas (kept alive; bind group holds a reference).
    pub(crate) pub(crate) shadow_atlas_view: wgpu::TextureView,
    /// Bind group for sampling the shadow atlas in the light pass shader.
    pub(crate) pub(crate) shadow_atlas_bind_group: wgpu::BindGroup,
    pub(crate) pub(crate) shadow_compute_bind_group_layout: wgpu::BindGroupLayout,
    pub(crate) pub(crate) shadow_compute_bind_group: wgpu::BindGroup,
    pub(crate) pub(crate) shadow_compute_pipeline: wgpu::ComputePipeline,
    pub(crate) pub(crate) shadow_edge_buffer: wgpu::Buffer,
    pub(crate) pub(crate) shadow_edge_capacity: usize,
    pub(crate) pub(crate) shadow_params_buffer: wgpu::Buffer,
    /// Pixel width of accumulation and shadow-atlas textures.
    pub(crate) pub(crate) width: u32,
    /// Pixel height of the accumulation texture.
    pub(crate) pub(crate) height: u32,
}
