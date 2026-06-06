use std::collections::HashMap;
use crate::runtime::resource_keys::ShaderKey;
use crate::render::gpu_pipeline::PipelineKey;

/// WGSL uniform value type tag; used to select the correct buffer layout.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub(crate) enum ShaderUniformKind {
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
pub(crate) struct GpuShader {
    /// Original WGSL source string retained for hot-reload.
    pub(crate) pub(crate) source: String,
    /// Ordered list of uniform names and their value types.
    pub(crate) pub(crate) uniform_signature: Vec<(String, ShaderUniformKind)>,
    /// Per-uniform GPU buffers, one per `uniform_signature` entry.
    pub(crate) pub(crate) uniform_buffers: Vec<wgpu::Buffer>,
    /// Bind group holding all uniform buffers for this shader.
    pub(crate) pub(crate) uniform_bind_group: Option<wgpu::BindGroup>,
    /// Compiled shader module for the flat-color vertex path.
    pub(crate) pub(crate) color_module: wgpu::ShaderModule,
    /// Compiled shader module for the textured vertex path.
    pub(crate) pub(crate) texture_module: wgpu::ShaderModule,
    /// Pipeline layout for the color module.
    pub(crate) pub(crate) color_layout: wgpu::PipelineLayout,
    /// Pipeline layout for the texture module.
    pub(crate) pub(crate) texture_layout: wgpu::PipelineLayout,
    /// Cached color render pipelines keyed by blend/stencil state.
    pub(crate) pub(crate) color_pipelines: HashMap<PipelineKey, wgpu::RenderPipeline>,
    /// Cached texture render pipelines keyed by blend/stencil state.
    pub(crate) pub(crate) texture_pipelines: HashMap<PipelineKey, wgpu::RenderPipeline>,
}
const COLOR_SHADER: &str = r#"
pub(crate) struct VertexInput {
    @location(0) position: vec2<f32>,
    @location(1) color:    vec4<f32>,
}
pub(crate) struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0)       color:         vec4<f32>,
}
pub(crate) struct Viewport {
    pub(crate) pub(crate) size: vec2<f32>,
    pub(crate) pub(crate) time: f32,
    pub(crate) pub(crate) _pad: f32,
    pub(crate) pub(crate) view_col0: vec4<f32>,
    pub(crate) pub(crate) view_col1: vec4<f32>,
    pub(crate) pub(crate) view_col2: vec4<f32>,
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
const TEXTURE_SHADER: &str = r#"
pub(crate) struct VertexInput {
    @location(0) position: vec2<f32>,
    @location(1) uv:       vec2<f32>,
    @location(2) color:    vec4<f32>,
    @location(3) w_depth:  f32,
}
pub(crate) struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0)       uv:            vec2<f32>,
    @location(1)       color:         vec4<f32>,
}
pub(crate) struct Viewport {
    pub(crate) pub(crate) size: vec2<f32>,
    pub(crate) pub(crate) time: f32,
    pub(crate) pub(crate) _pad: f32,
    pub(crate) pub(crate) view_col0: vec4<f32>,
    pub(crate) pub(crate) view_col1: vec4<f32>,
    pub(crate) pub(crate) view_col2: vec4<f32>,
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
const LIGHT_SHADER: &str = r#"
pub(crate) struct VertexInput {
    @location(0) position: vec2<f32>,
    @location(1) uv:       vec2<f32>,
    @location(2) color:    vec4<f32>,
    @location(3) shadow_v: f32,
    @location(4) shadow_params: vec4<f32>,
}
pub(crate) struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0)       uv:            vec2<f32>,
    @location(1)       color:         vec4<f32>,
    @location(2)       shadow_v:      f32,
    @location(3)       shadow_params: vec4<f32>,
}
pub(crate) struct Viewport {
    pub(crate) pub(crate) size: vec2<f32>,
    pub(crate) pub(crate) time: f32,
    pub(crate) pub(crate) _pad: f32,
    pub(crate) pub(crate) view_col0: vec4<f32>,
    pub(crate) pub(crate) view_col1: vec4<f32>,
    pub(crate) pub(crate) view_col2: vec4<f32>,
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
const SHADOW_COMPUTE_SHADER: &str = r#"
pub(crate) struct Edge {
    pub(crate) pub(crate) ax: f32,
    pub(crate) pub(crate) ay: f32,
    pub(crate) pub(crate) sx: f32,
    pub(crate) pub(crate) sy: f32,
}
pub(crate) struct Params {
    pub(crate) pub(crate) inv_radius: f32,
    pub(crate) pub(crate) edge_count: u32,
    pub(crate) pub(crate) row: u32,
    pub(crate) pub(crate) _pad: u32,
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
    pub(crate) textureStore(shadow_atlas, vec2<i32>(i32(i), i32(params.row)), vec4<f32>(min_dist, 0.0, 0.0, 1.0));
}
"#;
