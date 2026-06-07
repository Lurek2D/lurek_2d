//! - Implements procedural geometry generation and tessellation for all primitive 2D shapes.
//! - Generates vertex/index lists for arcs, circles, ellipses, sectors, and rounded rectangles.
//! - Translates abstract blending modes requested by Lua into explicit wgpu descriptors.
//! - Handles thick-line calculations by expanding stroke segments to screen-aligned quads.
//! - Uses adaptive step sizes for curved geometry to trade off segment count vs visual smoothness.
//! - Implements custom geometry builders for solid shapes, hollow wireframes, and textured sprites.
//! - Calculates optimal layouts (like triangle lists and fans) to minimize GPU vertex buffer size.
//! - Manages mathematical fallbacks for degenerate geometry, preventing panic on zero-sized shapes.
//! - Retains isolated, pure functions for vector math, shape intersection, and coordinate projections.
//! - Provides utility structures for color mapping, color interpolation, and vertex transformations.
//! - Feeds geometry data into the graphics pipeline without maintaining direct GPU state handles.
//! - Supports multiple shading layouts, including flat colors, texture mapping, and vertex gradients.
//! - Standardizes font character drawing by converting glyph boxes into independent texture quads.
//! - Enforces bounds-checking and coordinate constraints for scissor rectangles and viewports.
//! - Serves as the math engine under the scene builder before final GPU buffer writeback.
//! - Enables fast rendering of grid arrays, particle layouts, and complex vector drawing chains.

/// Flat-shaded vertex with `position` and per-vertex `color`.
#[repr(C)]
#[derive(Copy, Clone, Pod, Zeroable)]
struct ColorVertex {
    /// NDC/screen-space XY position.
    position: [f32; 2],
    /// RGBA vertex color.
    color: [f32; 4],
}
/// Textured vertex with position, UV, RGBA tint, and homogeneous W depth for perspective correction.
#[repr(C)]
#[derive(Copy, Clone, Pod, Zeroable)]
struct TexVertex {
    /// NDC/screen-space XY position.
    position: [f32; 2],
    /// Texture UV coordinates.
    uv: [f32; 2],
    /// Per-vertex RGBA tint.
    color: [f32; 4],
    /// Homogeneous W value for perspective-correct UV interpolation.
    w_depth: f32,
    /// Padding to meet `Pod` alignment requirements.
    _pad: [f32; 3],
}
/// Light-pass vertex with position, UV, RGBA tint, shadow map value, and shadow parameters.
#[repr(C)]
#[derive(Copy, Clone, Pod, Zeroable)]
struct LightVertex {
    /// NDC/screen-space XY position.
    position: [f32; 2],
    /// Light-quad UV coordinates.
    uv: [f32; 2],
    /// Per-vertex RGBA tint.
    color: [f32; 4],
    /// Normalised 0..1 shadow map value for this vertex.
    shadow_v: f32,
    /// Shadow sampling parameters: `[radius, mode, texel_size, _pad]`.
    shadow_params: [f32; 4],
}
#[repr(C)]
#[derive(Copy, Clone, Pod, Zeroable)]
/// Defines shadow caster edge representation for compute shader processing.
struct ShadowEdgeGpu {
    ax: f32,
    ay: f32,
    sx: f32,
    sy: f32,
}
#[repr(C)]
#[derive(Copy, Clone, Pod, Zeroable)]
/// Defines uniform payload for a single shadow casting dispatch.
struct ShadowComputeParams {
    inv_radius: f32,
    edge_count: u32,
    row: u32,
    _pad: u32,
}
/// Defines CPU-side configuration for preparing a shadow compute dispatch.
struct ShadowDispatchInput<'a> {
    row: usize,
    /// World X coordinate.
    light_x: f32,
    /// World Y coordinate.
    light_y: f32,
    /// Maximum shadow distance.
    light_radius: f32,
    /// Occlusion filter bitmask.
    shadow_mask: u16,
    /// Active occluders slice.
    occluders: &'a [&'a crate::light::occluder::Occluder],
}
/// Horizontal resolution of the 1-D shadow map texture.
const SHADOW_MAP_RES: usize = 256;
/// Maximum number of shadow-casting point lights rendered per frame.
const MAX_SHADOW_LIGHTS: usize = 128;
/// Size of a compute shader workgroup.
const SHADOW_COMPUTE_WORKGROUP_SIZE: u32 = 64;
/// Per-frame viewport uniform uploaded to the GPU: pixel dimensions, time, and camera transform.
#[repr(C)]
#[derive(Copy, Clone, Pod, Zeroable)]
struct ViewportUniform {
    /// Framebuffer pixel dimensions `[width, height]`.
    size: [f32; 2],
    /// Engine time in seconds, passed to shaders.
    time: f32,
    /// Alignment padding.
    _pad: f32,
    /// Column 0 of the 3×3 view transform.
    view_col0: [f32; 4],
    /// Column 1 of the 3×3 view transform.
    view_col1: [f32; 4],
    /// Column 2 of the 3×3 view transform.
    view_col2: [f32; 4],
}
/// GPU texture with its bind group; held in slot-maps keyed by `TextureKey` / `CanvasKey` / `FontKey`.
pub struct GpuTexture {
    /// Owned wgpu texture object (prefixed with `_` to avoid unused-field warnings).
    pub _texture: wgpu::Texture,
    /// View used as shader resource.
    pub view: wgpu::TextureView,
    /// Bind group pairing `view` with its sampler.
    pub bind_group: wgpu::BindGroup,
    /// Pixel width.
    pub width: u32,
    /// Pixel height.
    pub height: u32,
}
/// Combined depth/stencil render attachment; created lazily per render target.
struct DepthStencilTarget {
    /// Owned texture (unused directly after view creation).
    _texture: wgpu::Texture,
    /// View bound as depth/stencil attachment.
    view: wgpu::TextureView,
    /// Pixel width matching its render target.
    width: u32,
    /// Pixel height matching its render target.
    height: u32,
}
/// Mapped readback buffer pending async `device.poll` before screenshot bytes are copied.
struct PendingSurfaceReadback {
    /// Mappable output buffer.
    buffer: wgpu::Buffer,
    /// Row stride in bytes including wgpu alignment padding.
    padded_bytes_per_row: u32,
    /// Image width in pixels.
    width: u32,
    /// Image height in pixels.
    height: u32,
}
/// Identifies a GPU texture source during draw batching.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
enum TexRef {
    /// A sprite/image texture uploaded via `upload_texture`.
    Texture(TextureKey),
    /// An off-screen canvas render target.
    Canvas(CanvasKey),
    /// A bitmap font glyph atlas.
    FontAtlas(FontKey),
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
/// Optional pixel-space scissor rectangle `(x, y, width, height)`.
type ScissorRect = Option<(u32, u32, u32, u32)>;
/// Identifies the active render target during a frame.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
enum RenderTargetId {
    /// The main window surface.
    Screen,
    /// An off-screen canvas texture.
    Canvas(CanvasKey),
}
/// Selects the GPU vertex layout for a draw call.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
enum GeometryKind {
    /// Flat-color `ColorVertex` layout.
    Color,
    /// Textured `TexVertex` layout with UV and W depth.
    Texture,
}
/// Stencil operation mode for a draw call; used as part of the pipeline cache key.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
enum StencilMode {
    /// Stencil testing and writing are both disabled.
    Disabled,
    /// Write the stencil reference value using the given action.
    Write(crate::render::renderer::StencilAction),
    /// Discard fragments that fail the given compare test against the stencil buffer.
    Test(crate::render::renderer::CompareMode),
}
/// Composite key used to look up or create a cached `wgpu::RenderPipeline`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
struct PipelineKey {
    /// Alpha/additive/multiply/etc. blend state.
    blend_mode: BlendMode,
    /// Channel write-mask encoded as a bitmask (R=1, G=2, B=4, A=8).
    color_mask_bits: u32,
    /// Stencil operation or test applied by this pipeline.
    stencil_mode: StencilMode,
}
/// Full pipeline selection key: default vs. custom shader, plus geometry kind and blend/stencil state.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
enum PipelineSelectionKey {
    /// Use the built-in color or texture shader.
    Default {
        /// Vertex layout to use.
        geometry: GeometryKind,
        /// Blend/stencil pipeline variant.
        pipeline: PipelineKey,
    },
    /// Use a user-supplied WGSL shader.
    Custom {
        /// Registered shader key.
        shader: ShaderKey,
        /// Vertex layout to use.
        geometry: GeometryKind,
        /// Blend/stencil pipeline variant.
        pipeline: PipelineKey,
    },
}
/// A fully resolved draw call ready to be encoded in the GPU render pass.
#[derive(Debug, Clone, Copy)]
struct PreparedDraw {
    /// Render target this draw writes to.
    target: RenderTargetId,
    /// Vertex layout (color or texture).
    geometry: GeometryKind,
    /// Texture bound for this draw, or `None` for flat-color.
    texture_ref: Option<TexRef>,
    /// First index in the shared index buffer.
    idx_start: u32,
    /// Number of indices for this draw call.
    idx_count: u32,
    /// Blend mode for this draw.
    blend_mode: BlendMode,
    /// Optional scissor rectangle in pixels.
    scissor: ScissorRect,
    /// Channel write-mask bitmask.
    color_mask_bits: u32,
    /// User shader override, or `None` for the built-in shader.
    shader: Option<ShaderKey>,
    /// Stencil operation mode.
    stencil_mode: StencilMode,
    /// Stencil reference value used by `Write` and `Test` modes.
    stencil_reference: u32,
}
/// WGSL uniform value type tag; used to select the correct buffer layout.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
enum ShaderUniformKind {
    /// 32-bit float scalar.
    Float,
    /// Two-component float vector.
    Vec2,
    /// Three-component float vector.
    Vec3,
    /// Four-component float vector.
    Vec4,
    /// 32-bit signed integer.
    Int,
    /// Boolean mapped to u32.
    Bool,
}
/// Compiled user WGSL shader with cached render pipelines for each `PipelineKey`.
pub struct GpuShader {
    /// Original WGSL source string retained for hot-reload.
    pub source: String,
    /// Ordered list of uniform names and their value types.
    pub uniform_signature: Vec<(String, ShaderUniformKind)>,
    /// Per-uniform GPU buffers, one per `uniform_signature` entry.
    pub uniform_buffers: Vec<wgpu::Buffer>,
    /// Bind group holding all uniform buffers for this shader.
    pub uniform_bind_group: Option<wgpu::BindGroup>,
    /// Compiled shader module for the flat-color vertex path.
    pub color_module: wgpu::ShaderModule,
    /// Compiled shader module for the textured vertex path.
    pub texture_module: wgpu::ShaderModule,
    /// Pipeline layout for the color module.
    pub color_layout: wgpu::PipelineLayout,
    /// Pipeline layout for the texture module.
    pub texture_layout: wgpu::PipelineLayout,
    /// Cached color render pipelines keyed by blend/stencil state.
    pub color_pipelines: HashMap<PipelineKey, wgpu::RenderPipeline>,
    /// Cached texture render pipelines keyed by blend/stencil state.
    pub texture_pipelines: HashMap<PipelineKey, wgpu::RenderPipeline>,
}
/// Return the wgpu `BlendState` for a given `BlendMode`.
fn blend_state_for(mode: BlendMode) -> wgpu::BlendState {
    match mode {
        BlendMode::Alpha => wgpu::BlendState::ALPHA_BLENDING,
        BlendMode::Add => wgpu::BlendState {
            color: wgpu::BlendComponent {
                src_factor: wgpu::BlendFactor::SrcAlpha,
                dst_factor: wgpu::BlendFactor::One,
                operation: wgpu::BlendOperation::Add,
            },
            alpha: wgpu::BlendComponent {
                src_factor: wgpu::BlendFactor::One,
                dst_factor: wgpu::BlendFactor::One,
                operation: wgpu::BlendOperation::Add,
            },
        },
        BlendMode::Multiply => wgpu::BlendState {
            color: wgpu::BlendComponent {
                src_factor: wgpu::BlendFactor::Dst,
                dst_factor: wgpu::BlendFactor::Zero,
                operation: wgpu::BlendOperation::Add,
            },
            alpha: wgpu::BlendComponent {
                src_factor: wgpu::BlendFactor::DstAlpha,
                dst_factor: wgpu::BlendFactor::Zero,
                operation: wgpu::BlendOperation::Add,
            },
        },
        BlendMode::Replace => wgpu::BlendState {
            color: wgpu::BlendComponent::REPLACE,
            alpha: wgpu::BlendComponent::REPLACE,
        },
        BlendMode::Screen => wgpu::BlendState {
            color: wgpu::BlendComponent {
                src_factor: wgpu::BlendFactor::One,
                dst_factor: wgpu::BlendFactor::OneMinusSrc,
                operation: wgpu::BlendOperation::Add,
            },
            alpha: wgpu::BlendComponent {
                src_factor: wgpu::BlendFactor::One,
                dst_factor: wgpu::BlendFactor::OneMinusSrcAlpha,
                operation: wgpu::BlendOperation::Add,
            },
        },
    }
}
/// Raw color WGSL source.
const COLOR_SHADER: &str = r#"
struct VertexInput {
    @location(0) position: vec2<f32>,
    @location(1) color:    vec4<f32>,
}
struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0)       color:         vec4<f32>,
}
struct Viewport {
    size: vec2<f32>,
    time: f32,
    _pad: f32,
    view_col0: vec4<f32>,
    view_col1: vec4<f32>,
    view_col2: vec4<f32>,
}
@group(0) @binding(0) var<uniform> viewport: Viewport;
@vertex
fn vs_main(in: VertexInput) -> VertexOutput {
    var out: VertexOutput;
    let view = mat3x3<f32>(
        viewport.view_col0.xyz,
        viewport.view_col1.xyz,
        viewport.view_col2.xyz,
    );
    let cam_pos = view * vec3<f32>(in.position, 1.0);
    out.clip_position = vec4<f32>(
        (cam_pos.x / viewport.size.x) * 2.0 - 1.0,
        1.0 - (cam_pos.y / viewport.size.y) * 2.0,
        0.0, 1.0
    );
    out.color = in.color;
    return out;
}
@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> { return in.color; }
"#;
/// Raw texture WGSL source.
const TEXTURE_SHADER: &str = r#"
struct VertexInput {
    @location(0) position: vec2<f32>,
    @location(1) uv:       vec2<f32>,
    @location(2) color:    vec4<f32>,
    @location(3) w_depth:  f32,
}
struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0)       uv:            vec2<f32>,
    @location(1)       color:         vec4<f32>,
}
struct Viewport {
    size: vec2<f32>,
    time: f32,
    _pad: f32,
    view_col0: vec4<f32>,
    view_col1: vec4<f32>,
    view_col2: vec4<f32>,
}
@group(0) @binding(0) var<uniform>  viewport:   Viewport;
@group(1) @binding(0) var           t_diffuse:  texture_2d<f32>;
@group(1) @binding(1) var           s_diffuse:  sampler;
@vertex
fn vs_main(in: VertexInput) -> VertexOutput {
    var out: VertexOutput;
    let view = mat3x3<f32>(
        viewport.view_col0.xyz,
        viewport.view_col1.xyz,
        viewport.view_col2.xyz,
    );
    let cam_pos = view * vec3<f32>(in.position, 1.0);
    let w = max(in.w_depth, 0.001);
    let ndc_x = (cam_pos.x / viewport.size.x) * 2.0 - 1.0;
    let ndc_y = 1.0 - (cam_pos.y / viewport.size.y) * 2.0;
    out.clip_position = vec4<f32>(ndc_x * w, ndc_y * w, 0.0, w);
    out.uv    = in.uv;
    out.color = in.color;
    return out;
}
@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    return textureSample(t_diffuse, s_diffuse, in.uv) * in.color;
}
"#;
/// Raw light WGSL source.
const LIGHT_SHADER: &str = r#"
struct VertexInput {
    @location(0) position: vec2<f32>,
    @location(1) uv:       vec2<f32>,
    @location(2) color:    vec4<f32>,
    @location(3) shadow_v: f32,
    @location(4) shadow_params: vec4<f32>,
}
struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0)       uv:            vec2<f32>,
    @location(1)       color:         vec4<f32>,
    @location(2)       shadow_v:      f32,
    @location(3)       shadow_params: vec4<f32>,
}
struct Viewport {
    size: vec2<f32>,
    time: f32,
    _pad: f32,
    view_col0: vec4<f32>,
    view_col1: vec4<f32>,
    view_col2: vec4<f32>,
}
@group(0) @binding(0) var<uniform> viewport: Viewport;
@group(1) @binding(0) var shadow_atlas: texture_2d<f32>;
@group(1) @binding(1) var shadow_sampler: sampler;
@vertex
fn vs_main(in: VertexInput) -> VertexOutput {
    var out: VertexOutput;
    let view = mat3x3<f32>(
        viewport.view_col0.xyz,
        viewport.view_col1.xyz,
        viewport.view_col2.xyz,
    );
    let cam_pos = view * vec3<f32>(in.position, 1.0);
    out.clip_position = vec4<f32>(
        (cam_pos.x / viewport.size.x) * 2.0 - 1.0,
        1.0 - (cam_pos.y / viewport.size.y) * 2.0,
        0.0, 1.0
    );
    out.uv       = in.uv;
    out.color    = in.color;
    out.shadow_v = in.shadow_v;
    out.shadow_params = in.shadow_params;
    return out;
}
fn sample_shadow_row(u: f32, v: f32, mode: f32, texel_size: f32) -> f32 {
    if mode < 0.5 {
        return textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u, v)).r;
    }
    if mode < 1.5 {
        var acc = 0.0;
        acc += textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u - 2.0 * texel_size, v)).r;
        acc += textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u - 1.0 * texel_size, v)).r;
        acc += textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u, v)).r;
        acc += textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u + 1.0 * texel_size, v)).r;
        acc += textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u + 2.0 * texel_size, v)).r;
        return acc / 5.0;
    }
    var acc = 0.0;
    acc += textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u - 6.0 * texel_size, v)).r;
    acc += textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u - 5.0 * texel_size, v)).r;
    acc += textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u - 4.0 * texel_size, v)).r;
    acc += textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u - 3.0 * texel_size, v)).r;
    acc += textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u - 2.0 * texel_size, v)).r;
    acc += textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u - 1.0 * texel_size, v)).r;
    acc += textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u, v)).r;
    acc += textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u + 1.0 * texel_size, v)).r;
    acc += textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u + 2.0 * texel_size, v)).r;
    acc += textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u + 3.0 * texel_size, v)).r;
    acc += textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u + 4.0 * texel_size, v)).r;
    acc += textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u + 5.0 * texel_size, v)).r;
    acc += textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u + 6.0 * texel_size, v)).r;
    return acc / 13.0;
}
@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let center = vec2<f32>(0.5, 0.5);
    let delta  = in.uv - center;
    let dist   = length(delta) * 2.0;
    let falloff = clamp(1.0 - dist, 0.0, 1.0);
    let intensity = falloff * falloff;
    var shadow = 1.0;
    if in.shadow_v >= 0.0 {
        let angle = atan2(delta.y, delta.x);
        let u     = (angle + 3.14159265) / (2.0 * 3.14159265);
        let shadow_dist = sample_shadow_row(
            u,
            in.shadow_v,
            in.shadow_params.x,
            in.shadow_params.z,
        );
        let frag_dist   = dist * 0.5;
        let edge = max(1e-4, in.shadow_params.y * 0.05);
        shadow = 1.0 - smoothstep(shadow_dist - edge, shadow_dist + edge, frag_dist);
    }
    return vec4<f32>(in.color.rgb * intensity * shadow, 1.0);
}
"#;
/// Raw shadow compute WGSL source.
const SHADOW_COMPUTE_SHADER: &str = r#"
struct Edge {
    ax: f32,
    ay: f32,
    sx: f32,
    sy: f32,
}
struct Params {
    inv_radius: f32,
    edge_count: u32,
    row: u32,
    _pad: u32,
}
@group(0) @binding(0) var<storage, read> edges: array<Edge>;
@group(0) @binding(1) var<uniform> params: Params;
@group(0) @binding(2) var shadow_atlas: texture_storage_2d<r32float, write>;

@compute @workgroup_size(64)
fn cs_main(@builtin(global_invocation_id) gid: vec3<u32>) {
    let i = gid.x;
    if (i >= 256u) {
        return;
    }
    let angle = (f32(i) / 256.0) * 6.28318530718 - 3.14159265359;
    let dir_x = cos(angle);
    let dir_y = sin(angle);
    var min_dist = 1.0;
    for (var edge_idx = 0u; edge_idx < params.edge_count; edge_idx = edge_idx + 1u) {
        let edge = edges[edge_idx];
        let cross_ds = dir_x * edge.sy - dir_y * edge.sx;
        if (abs(cross_ds) < 0.00000001) {
            continue;
        }
        let inv_cross = 1.0 / cross_ds;
        let t = (edge.ax * edge.sy - edge.ay * edge.sx) * inv_cross;
        let u = (edge.ax * dir_y - edge.ay * dir_x) * inv_cross;
        if (t > 0.0 && u >= 0.0 && u <= 1.0) {
            let norm_dist = t * params.inv_radius;
            if (norm_dist < min_dist && norm_dist < 1.0) {
                min_dist = norm_dist;
            }
        }
    }
    textureStore(shadow_atlas, vec2<i32>(i32(i), i32(params.row)), vec4<f32>(min_dist, 0.0, 0.0, 1.0));
}
"#;
/// GPU state for the additive light accumulation and shadow-atlas composite pass.
pub struct LightGpuState {
    #[allow(dead_code)]
    /// Light accumulation RGBA texture (kept alive for its view).
    pub accum_texture: wgpu::Texture,
    /// View bound as the accumulation render-attachment.
    pub accum_view: wgpu::TextureView,
    /// Bind group for sampling the accumulation texture in the composite pass.
    pub accum_bind_group: wgpu::BindGroup,
    /// Additive light blending pipeline.
    pub additive_pipeline: wgpu::RenderPipeline,
    /// Final composite (multiply) pipeline.
    pub composite_pipeline: wgpu::RenderPipeline,
    /// Vertex buffer for light quads.
    pub vertex_buffer: wgpu::Buffer,
    /// Index buffer for light quads.
    pub index_buffer: wgpu::Buffer,
    #[allow(dead_code)]
    /// Shadow atlas texture storing 1-D shadow maps for each light.
    pub shadow_atlas_texture: wgpu::Texture,
    #[allow(dead_code)]
    /// View of the shadow atlas (kept alive; bind group holds a reference).
    pub shadow_atlas_view: wgpu::TextureView,
    /// Bind group for sampling the shadow atlas in the light pass shader.
    pub shadow_atlas_bind_group: wgpu::BindGroup,
    /// Layout required for the compute shadow dispatch.
    pub shadow_compute_bind_group_layout: wgpu::BindGroupLayout,
    /// Bind group supplying edges and params to the compute shader.
    pub shadow_compute_bind_group: wgpu::BindGroup,
    /// Compiled compute pipeline for shadow map generation.
    pub shadow_compute_pipeline: wgpu::ComputePipeline,
    /// Dynamic buffer containing active shadow caster edges.
    pub shadow_edge_buffer: wgpu::Buffer,
    /// Current allocated capacity in edges for the shadow buffer.
    pub shadow_edge_capacity: usize,
    /// Uniform buffer containing the shadow dispatch parameters.
    pub shadow_params_buffer: wgpu::Buffer,
    /// Pixel width of accumulation and shadow-atlas textures.
    pub width: u32,
    /// Pixel height of the accumulation texture.
    pub height: u32,
}
/// Core wgpu renderer owning all GPU resources; used by the engine runtime each frame.
pub struct GpuRenderer {
    /// wgpu logical device handle.
    device: wgpu::Device,
    /// wgpu submission queue.
    queue: wgpu::Queue,
    /// Bind-group layout for the viewport uniform buffer.
    viewport_bind_group_layout: wgpu::BindGroupLayout,
    /// Compiled WGSL module for the built-in flat-color shader.
    default_color_shader: wgpu::ShaderModule,
    /// Compiled WGSL module for the built-in textured shader.
    default_texture_shader: wgpu::ShaderModule,
    /// Pipeline layout for the built-in color shader.
    default_color_layout: wgpu::PipelineLayout,
    /// Pipeline layout for the built-in texture shader.
    default_texture_layout: wgpu::PipelineLayout,
    /// Cached default color pipelines keyed by blend/stencil state.
    default_color_pipelines: HashMap<PipelineKey, wgpu::RenderPipeline>,
    /// Cached default texture pipelines keyed by blend/stencil state.
    default_texture_pipelines: HashMap<PipelineKey, wgpu::RenderPipeline>,
    /// User-uploaded shader cache keyed by `ShaderKey`.
    shader_cache: SparseSecondaryMap<ShaderKey, GpuShader>,
    /// GPU buffer holding the current-frame `ViewportUniform`.
    viewport_buffer: wgpu::Buffer,
    /// Bind group binding `viewport_buffer` to binding 0.
    viewport_bind_group: wgpu::BindGroup,
    /// Shared bind-group layout for all texture+sampler pairs.
    texture_bind_group_layout: wgpu::BindGroupLayout,
    /// Pre-allocated flat-color vertex buffer.
    color_vertex_buffer: wgpu::Buffer,
    /// Pre-allocated flat-color index buffer.
    color_index_buffer: wgpu::Buffer,
    /// Pre-allocated textured vertex buffer.
    tex_vertex_buffer: wgpu::Buffer,
    /// Pre-allocated textured index buffer.
    tex_index_buffer: wgpu::Buffer,
    /// Current capacity of `color_vertex_buffer` in vertex units.
    color_vertex_capacity: u64,
    /// Current capacity of `color_index_buffer` in index units.
    color_index_capacity: u64,
    /// Current capacity of `tex_vertex_buffer` in vertex units.
    tex_vertex_capacity: u64,
    /// Current capacity of `tex_index_buffer` in index units.
    tex_index_capacity: u64,
    /// GPU textures keyed by `TextureKey`.
    gpu_textures: SparseSecondaryMap<TextureKey, GpuTexture>,
    /// Font atlas GPU textures keyed by `FontKey`.
    font_atlas_textures: SparseSecondaryMap<FontKey, GpuTexture>,
    /// Canvas render-target textures keyed by `CanvasKey`.
    canvas_gpu_textures: SparseSecondaryMap<CanvasKey, GpuTexture>,
    /// Lazily created depth/stencil attachment for the main screen target.
    screen_stencil_target: Option<DepthStencilTarget>,
    /// Per-canvas depth/stencil attachments created on first stencil use.
    canvas_stencil_targets: SparseSecondaryMap<CanvasKey, DepthStencilTarget>,
    /// Tracks which canvases still need a clear at the start of the next frame.
    canvas_needs_clear: SparseSecondaryMap<CanvasKey, bool>,
    /// Surface texture format negotiated at creation.
    surface_format: wgpu::TextureFormat,
    /// Current framebuffer width in pixels.
    pub width: u32,
    /// Current framebuffer height in pixels.
    pub height: u32,
    /// Per-frame rendering statistics updated by `render_frame`.
    pub render_stats: RenderStats,
    /// Optional light accumulation and shadow-atlas GPU state.
    light_gpu: Option<LightGpuState>,
    /// Optional post-processing pipeline chain applied after the main pass.
    postfx_pipeline: Option<crate::render::postfx_pipeline::PostFxPipeline>,
    /// Per-effect capture textures for multi-pass post-fx.
    postfx_capture: HashMap<u64, crate::render::postfx_pipeline::PostFxTexture>,
}
