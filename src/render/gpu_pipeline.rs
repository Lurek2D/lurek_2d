//! Builds and caches wgpu render pipelines so repeated material and geometry combinations compile only once.
//! Keys pipelines by geometry kind, blend state, stencil mode, and custom shader selection inputs.
//! Chooses built-in shader paths when callers do not supply overrides, keeping fallback behavior centralized.
//! Generates helper WGSL fragments and uniform declarations needed by custom color and texture pipelines.
//! Standardizes alpha, additive, multiplicative, and replace blend policies for the whole render subsystem.
//! Configures depth and stencil state mapping so pipeline creation reflects the front-end render command model.
//! Acts as the pipeline-construction boundary rather than the owner of per-frame draw traversal.
//! Open this file when render state caching, blend mapping, or custom shader pipeline assembly is incorrect.

use crate::render::gpu_shaders::ShaderUniformKind;
use crate::render::gpu_tess::color_write_mask_from_bits;
use crate::render::gpu_types::{ColorVertex, LightVertex, ParticleVertex, TexVertex};
use crate::render::renderer::BlendMode;
use crate::render::shader::{Shader, ShaderFragmentInput};
use crate::runtime::resource_keys::ShaderKey;

/// Selects the GPU vertex layout for a draw call.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum GeometryKind {
    /// Flat-color `ColorVertex` layout.
    Color,
    /// Textured `TexVertex` layout with UV and W depth.
    Texture,
    /// Instanced flat-color layout.
    ColorInstanced,
    /// Instanced textured layout.
    TextureInstanced,
    /// Particle shader layout with per-particle visual inputs.
    Particle,
    /// Textured particle shader layout with per-particle visual inputs and sampled texture color.
    ParticleTextured,
    /// Light contribution shader layout with per-light visual inputs.
    Light,
}
/// Stencil operation mode for a draw call; used as part of the pipeline cache key.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Default)]
pub enum GpuStencilMode {
    #[default]
    /// Stencil testing and writing are both disabled.
    Disabled,
    /// Write the stencil reference value using the given action.
    Write(crate::render::renderer::StencilAction),
    /// Discard fragments that fail the given compare test against the stencil buffer.
    Test(crate::render::renderer::CompareMode),
}
/// Composite key used to look up or create a cached `wgpu::RenderPipeline`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct PipelineKey {
    /// Alpha/additive/multiply/etc. blend state.
    pub blend_mode: BlendMode,
    /// Channel write-mask encoded as a bitmask (R=1, G=2, B=4, A=8).
    pub color_mask_bits: u32,
    /// Stencil operation or test applied by this pipeline.
    pub stencil_mode: GpuStencilMode,
}
/// Full pipeline selection key: default vs. custom shader, plus geometry kind and blend/stencil state.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum PipelineSelectionKey {
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
/// Return the wgpu `BlendState` for a given `BlendMode`.
pub fn blend_state_for(mode: BlendMode) -> wgpu::BlendState {
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

/// Return the WGSL type name string for a shader uniform kind.
pub(crate) fn uniform_wgsl_type(kind: ShaderUniformKind) -> &'static str {
    match kind {
        ShaderUniformKind::Float => "f32",
        ShaderUniformKind::Vec2 => "vec2<f32>",
        ShaderUniformKind::Vec3 => "vec3<f32>",
        ShaderUniformKind::Vec4 => "vec4<f32>",
        ShaderUniformKind::Int => "i32",
        ShaderUniformKind::Bool => "u32",
    }
}
/// Generate WGSL `@group/@binding var<uniform>` declarations for all shader uniforms.
pub(crate) fn custom_uniform_declarations(
    uniform_signature: &[(String, ShaderUniformKind)],
    group_index: u32,
) -> String {
    uniform_signature
        .iter()
        .enumerate()
        .map(|(binding, (name, kind))| {
            format!(
                "@group({group_index}) @binding({binding}) var<uniform> {name}: {};\n",
                uniform_wgsl_type(*kind)
            )
        })
        .collect::<String>()
}
/// Build the comma-separated argument string for the user fragment entry call.
pub(crate) fn custom_fragment_call_args(
    inputs: &[ShaderFragmentInput],
    color_expr: &str,
    uv_expr: &str,
    local_expr: &str,
    resolution_expr: &str,
    texel_expr: &str,
) -> String {
    inputs
        .iter()
        .map(|input| match input {
            ShaderFragmentInput::Color => color_expr,
            ShaderFragmentInput::Uv => uv_expr,
            ShaderFragmentInput::PixelOrLocal => local_expr,
            ShaderFragmentInput::ResolutionOrWorld => resolution_expr,
            ShaderFragmentInput::TexelOrVelocity => texel_expr,
            ShaderFragmentInput::Scalar0
            | ShaderFragmentInput::Scalar1
            | ShaderFragmentInput::Scalar2
            | ShaderFragmentInput::Scalar3 => "0.0",
            ShaderFragmentInput::SampledTextureColor => color_expr,
            ShaderFragmentInput::AmbientColor => "vec4<f32>(0.0, 0.0, 0.0, 1.0)",
            ShaderFragmentInput::LightDirection => "vec4<f32>(0.0, 0.0, 0.0, 0.0)",
        })
        .collect::<Vec<_>>()
        .join(", ")
}
/// Build fragment call arguments for the particle shader vertex output contract.
pub(crate) fn particle_fragment_call_args(inputs: &[ShaderFragmentInput]) -> String {
    inputs
        .iter()
        .map(|input| match input {
            ShaderFragmentInput::Color => "in.color",
            ShaderFragmentInput::Uv => "in.uv",
            ShaderFragmentInput::PixelOrLocal => "in.local_pos",
            ShaderFragmentInput::ResolutionOrWorld => "in.world_pos",
            ShaderFragmentInput::TexelOrVelocity => "in.velocity",
            ShaderFragmentInput::Scalar0 => "in.normalized_age",
            ShaderFragmentInput::Scalar1 => "in.lifetime",
            ShaderFragmentInput::Scalar2 => "in.seed",
            ShaderFragmentInput::Scalar3 => "0.0",
            ShaderFragmentInput::SampledTextureColor => "in.sampled_color",
            ShaderFragmentInput::AmbientColor => "vec4<f32>(0.0, 0.0, 0.0, 1.0)",
            ShaderFragmentInput::LightDirection => "vec4<f32>(0.0, 0.0, 0.0, 0.0)",
        })
        .collect::<Vec<_>>()
        .join(", ")
}
/// Build fragment call arguments for the light shader vertex output contract.
pub(crate) fn light_fragment_call_args(inputs: &[ShaderFragmentInput]) -> String {
    inputs
        .iter()
        .map(|input| match input {
            ShaderFragmentInput::Color => "in.color",
            ShaderFragmentInput::Uv => "in.uv",
            ShaderFragmentInput::PixelOrLocal => "in.world_pos",
            ShaderFragmentInput::ResolutionOrWorld => "in.light_pos",
            ShaderFragmentInput::TexelOrVelocity => "in.normal_hint",
            ShaderFragmentInput::Scalar0 => "in.distance_norm",
            ShaderFragmentInput::Scalar1 => "in.radius",
            ShaderFragmentInput::Scalar2 => "in.intensity",
            ShaderFragmentInput::Scalar3 => "in.shadow_factor",
            ShaderFragmentInput::SampledTextureColor => "in.color",
            ShaderFragmentInput::AmbientColor => "in.ambient_color",
            ShaderFragmentInput::LightDirection => "in.direction_spot",
        })
        .collect::<Vec<_>>()
        .join(", ")
}
/// Assemble the full WGSL source for a custom flat-color shader pipeline.
pub fn build_custom_color_shader_source(
    shader: &Shader,
    uniform_signature: &[(String, ShaderUniformKind)],
) -> String {
    let uniform_decls = custom_uniform_declarations(uniform_signature, 1);
    let fragment_call_args = custom_fragment_call_args(
        shader.fragment_inputs(),
        "in.color",
        "in.uv",
        "in.local_pos",
        "lurek.lurek_ScreenSize",
        "1.0 / max(lurek.lurek_ScreenSize, vec2<f32>(1.0, 1.0))",
    );
    format!(
        r#"
struct VertexInput {{
    @location(0) position: vec2<f32>,
    @location(1) color: vec4<f32>,
}}
struct VertexOutput {{
    @builtin(position) clip_position: vec4<f32>,
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) local_pos: vec2<f32>,
}}
struct LurekGlobals {{
    lurek_ScreenSize: vec2<f32>,
    lurek_Time: f32,
    _pad: f32,
    view_col0: vec4<f32>,
    view_col1: vec4<f32>,
    view_col2: vec4<f32>,
}}
@group(0) @binding(0) var<uniform> lurek: LurekGlobals;
{uniform_decls}
@vertex
fn vs_main(in: VertexInput) -> VertexOutput {{
    var out: VertexOutput;
    let view = mat3x3<f32>(
        lurek.view_col0.xyz,
        lurek.view_col1.xyz,
        lurek.view_col2.xyz,
    );
    let cam_pos = view * vec3<f32>(in.position, 1.0);
    out.clip_position = vec4<f32>(
        (cam_pos.x / lurek.lurek_ScreenSize.x) * 2.0 - 1.0,
        1.0 - (cam_pos.y / lurek.lurek_ScreenSize.y) * 2.0,
        0.0,
        1.0
    );
    out.color = in.color;
    out.uv = vec2<f32>(0.0, 0.0);
    out.local_pos = in.position;
    return out;
}}
{user_source}
@fragment
fn lurek_fragment_main(in: VertexOutput) -> @location(0) vec4<f32> {{
    return {fragment_entry}({fragment_call_args});
}}
"#,
        user_source = shader.wrapper_source(),
        fragment_entry = shader.fragment_entry_name(),
        fragment_call_args = fragment_call_args,
    )
}
/// Assemble the full WGSL source for a custom particle shader pipeline.
pub fn build_custom_particle_shader_source(
    shader: &Shader,
    uniform_signature: &[(String, ShaderUniformKind)],
) -> String {
    let uniform_decls = custom_uniform_declarations(uniform_signature, 1);
    let fragment_call_args = particle_fragment_call_args(shader.fragment_inputs());
    format!(
        r#"
struct VertexInput {{
    @location(0) position: vec2<f32>,
    @location(1) color: vec4<f32>,
    @location(2) uv: vec2<f32>,
    @location(3) local_pos: vec2<f32>,
    @location(4) world_pos: vec2<f32>,
    @location(5) velocity: vec2<f32>,
    @location(6) normalized_age: f32,
    @location(7) lifetime: f32,
    @location(8) seed: f32,
}}
struct VertexOutput {{
    @builtin(position) clip_position: vec4<f32>,
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) local_pos: vec2<f32>,
    @location(3) world_pos: vec2<f32>,
    @location(4) velocity: vec2<f32>,
    @location(5) normalized_age: f32,
    @location(6) lifetime: f32,
    @location(7) seed: f32,
    @location(8) sampled_color: vec4<f32>,
}}
struct LurekGlobals {{
    lurek_ScreenSize: vec2<f32>,
    lurek_Time: f32,
    _pad: f32,
    view_col0: vec4<f32>,
    view_col1: vec4<f32>,
    view_col2: vec4<f32>,
}}
@group(0) @binding(0) var<uniform> lurek: LurekGlobals;
{uniform_decls}
@vertex
fn vs_main(in: VertexInput) -> VertexOutput {{
    var out: VertexOutput;
    let view = mat3x3<f32>(
        lurek.view_col0.xyz,
        lurek.view_col1.xyz,
        lurek.view_col2.xyz,
    );
    let cam_pos = view * vec3<f32>(in.position, 1.0);
    out.clip_position = vec4<f32>(
        (cam_pos.x / lurek.lurek_ScreenSize.x) * 2.0 - 1.0,
        1.0 - (cam_pos.y / lurek.lurek_ScreenSize.y) * 2.0,
        0.0,
        1.0
    );
    out.color = in.color;
    out.uv = in.uv;
    out.local_pos = in.local_pos;
    out.world_pos = in.world_pos;
    out.velocity = in.velocity;
    out.normalized_age = in.normalized_age;
    out.lifetime = in.lifetime;
    out.seed = in.seed;
    out.sampled_color = in.color;
    return out;
}}
{user_source}
@fragment
fn lurek_fragment_main(in: VertexOutput) -> @location(0) vec4<f32> {{
    return {fragment_entry}({fragment_call_args});
}}
"#,
        user_source = shader.wrapper_source(),
        fragment_entry = shader.fragment_entry_name(),
        fragment_call_args = fragment_call_args,
    )
}
/// Assemble the full WGSL source for a textured custom particle shader pipeline.
pub fn build_custom_textured_particle_shader_source(
    shader: &Shader,
    uniform_signature: &[(String, ShaderUniformKind)],
) -> String {
    let uniform_decls = custom_uniform_declarations(uniform_signature, 2);
    let fragment_call_args = particle_fragment_call_args(shader.fragment_inputs());
    format!(
        r#"
struct VertexInput {{
    @location(0) position: vec2<f32>,
    @location(1) color: vec4<f32>,
    @location(2) uv: vec2<f32>,
    @location(3) local_pos: vec2<f32>,
    @location(4) world_pos: vec2<f32>,
    @location(5) velocity: vec2<f32>,
    @location(6) normalized_age: f32,
    @location(7) lifetime: f32,
    @location(8) seed: f32,
}}
struct VertexOutput {{
    @builtin(position) clip_position: vec4<f32>,
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) local_pos: vec2<f32>,
    @location(3) world_pos: vec2<f32>,
    @location(4) velocity: vec2<f32>,
    @location(5) normalized_age: f32,
    @location(6) lifetime: f32,
    @location(7) seed: f32,
    @location(8) sampled_color: vec4<f32>,
}}
struct LurekGlobals {{
    lurek_ScreenSize: vec2<f32>,
    lurek_Time: f32,
    _pad: f32,
    view_col0: vec4<f32>,
    view_col1: vec4<f32>,
    view_col2: vec4<f32>,
}}
@group(0) @binding(0) var<uniform> lurek: LurekGlobals;
@group(1) @binding(0) var t_particle: texture_2d<f32>;
@group(1) @binding(1) var s_particle: sampler;
{uniform_decls}
@vertex
fn vs_main(in: VertexInput) -> VertexOutput {{
    var out: VertexOutput;
    let view = mat3x3<f32>(
        lurek.view_col0.xyz,
        lurek.view_col1.xyz,
        lurek.view_col2.xyz,
    );
    let cam_pos = view * vec3<f32>(in.position, 1.0);
    out.clip_position = vec4<f32>(
        (cam_pos.x / lurek.lurek_ScreenSize.x) * 2.0 - 1.0,
        1.0 - (cam_pos.y / lurek.lurek_ScreenSize.y) * 2.0,
        0.0,
        1.0
    );
    out.color = in.color;
    out.uv = in.uv;
    out.local_pos = in.local_pos;
    out.world_pos = in.world_pos;
    out.velocity = in.velocity;
    out.normalized_age = in.normalized_age;
    out.lifetime = in.lifetime;
    out.seed = in.seed;
    out.sampled_color = textureSample(t_particle, s_particle, in.uv) * in.color;
    return out;
}}
{user_source}
@fragment
fn lurek_fragment_main(in: VertexOutput) -> @location(0) vec4<f32> {{
    return {fragment_entry}({fragment_call_args});
}}
"#,
        user_source = shader.wrapper_source(),
        fragment_entry = shader.fragment_entry_name(),
        fragment_call_args = fragment_call_args,
    )
}
/// Assemble the full WGSL source for a custom light contribution shader pipeline.
pub fn build_custom_light_shader_source(
    shader: &Shader,
    uniform_signature: &[(String, ShaderUniformKind)],
) -> String {
    let uniform_decls = custom_uniform_declarations(uniform_signature, 2);
    let fragment_call_args = light_fragment_call_args(shader.fragment_inputs());
    let shadow_multiplier = if shader
        .fragment_inputs()
        .contains(&ShaderFragmentInput::Scalar3)
    {
        "1.0"
    } else {
        "in.shadow_factor"
    };
    format!(
        r#"
struct VertexInput {{
    @location(0) position: vec2<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) color: vec4<f32>,
    @location(3) shadow_v: f32,
    @location(4) shadow_params: vec4<f32>,
    @location(5) light_pos: vec2<f32>,
    @location(6) radius: f32,
    @location(7) intensity: f32,
    @location(8) normal_hint: vec2<f32>,
    @location(9) ambient_color: vec4<f32>,
    @location(10) direction_spot: vec4<f32>,
}}
struct VertexOutput {{
    @builtin(position) clip_position: vec4<f32>,
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) world_pos: vec2<f32>,
    @location(3) light_pos: vec2<f32>,
    @location(4) normal_hint: vec2<f32>,
    @location(5) distance_norm: f32,
    @location(6) radius: f32,
    @location(7) intensity: f32,
    @location(8) shadow_factor: f32,
    @location(9) ambient_color: vec4<f32>,
    @location(10) direction_spot: vec4<f32>,
}}
struct LurekGlobals {{
    lurek_ScreenSize: vec2<f32>,
    lurek_Time: f32,
    _pad: f32,
    view_col0: vec4<f32>,
    view_col1: vec4<f32>,
    view_col2: vec4<f32>,
}}
@group(0) @binding(0) var<uniform> lurek: LurekGlobals;
@group(1) @binding(0) var shadow_atlas: texture_2d<f32>;
@group(1) @binding(1) var shadow_sampler: sampler;
{uniform_decls}
fn lurek_sample_shadow_row(u: f32, v: f32, mode: f32, texel_size: f32) -> f32 {{
    if mode < 0.5 {{
        return textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u, v)).r;
    }}
    var acc = 0.0;
    if mode < 1.5 {{
        for (var k = -2; k <= 2; k++) {{
            acc += textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u + f32(k) * texel_size, v)).r;
        }}
        return acc / 5.0;
    }}
    for (var k = -6; k <= 6; k++) {{
        acc += textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u + f32(k) * texel_size, v)).r;
    }}
    return acc / 13.0;
}}
fn lurek_shadow_factor(uv: vec2<f32>, shadow_v: f32, shadow_params: vec4<f32>) -> f32 {{
    if shadow_v < 0.0 {{
        return 1.0;
    }}
    let delta = uv - vec2<f32>(0.5, 0.5);
    let angle = atan2(delta.y, delta.x);
    let u = (angle + 3.14159265) / (2.0 * 3.14159265);
    let dist = length(delta);
    let sd = lurek_sample_shadow_row(u, shadow_v, shadow_params.x, shadow_params.z);
    let edge = max(1e-4, shadow_params.y * 0.05);
    return 1.0 - smoothstep(sd - edge, sd + edge, dist);
}}
@vertex
fn vs_main(in: VertexInput) -> VertexOutput {{
    var out: VertexOutput;
    let view = mat3x3<f32>(
        lurek.view_col0.xyz,
        lurek.view_col1.xyz,
        lurek.view_col2.xyz,
    );
    let cam_pos = view * vec3<f32>(in.position, 1.0);
    out.clip_position = vec4<f32>(
        (cam_pos.x / lurek.lurek_ScreenSize.x) * 2.0 - 1.0,
        1.0 - (cam_pos.y / lurek.lurek_ScreenSize.y) * 2.0,
        0.0,
        1.0
    );
    out.color = in.color;
    out.uv = in.uv;
    out.world_pos = in.position;
    out.light_pos = in.light_pos;
    out.normal_hint = in.normal_hint;
    out.distance_norm = clamp(length(in.uv - vec2<f32>(0.5, 0.5)) * 2.0, 0.0, 1.0);
    out.radius = in.radius;
    out.intensity = in.intensity;
    out.shadow_factor = lurek_shadow_factor(in.uv, in.shadow_v, in.shadow_params);
    out.ambient_color = in.ambient_color;
    out.direction_spot = in.direction_spot;
    return out;
}}
{user_source}
@fragment
fn lurek_fragment_main(in: VertexOutput) -> @location(0) vec4<f32> {{
    let contribution = {fragment_entry}({fragment_call_args});
    return vec4<f32>(contribution.rgb * {shadow_multiplier}, contribution.a);
}}
"#,
        user_source = shader.wrapper_source(),
        fragment_entry = shader.fragment_entry_name(),
        fragment_call_args = fragment_call_args,
        shadow_multiplier = shadow_multiplier,
    )
}
/// Assemble the full WGSL source for a custom textured shader pipeline.
pub fn build_custom_texture_shader_source(
    shader: &Shader,
    uniform_signature: &[(String, ShaderUniformKind)],
) -> String {
    let uniform_decls = custom_uniform_declarations(uniform_signature, 2);
    let fragment_call_args = custom_fragment_call_args(
        shader.fragment_inputs(),
        "sampled",
        "in.uv",
        "in.local_pos",
        "lurek.lurek_ScreenSize",
        "1.0 / max(lurek.lurek_ScreenSize, vec2<f32>(1.0, 1.0))",
    );
    format!(
        r#"
struct VertexInput {{
    @location(0) position: vec2<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) color: vec4<f32>,
    @location(3) w_depth: f32,
}}
struct VertexOutput {{
    @builtin(position) clip_position: vec4<f32>,
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) local_pos: vec2<f32>,
}}
struct LurekGlobals {{
    lurek_ScreenSize: vec2<f32>,
    lurek_Time: f32,
    _pad: f32,
    view_col0: vec4<f32>,
    view_col1: vec4<f32>,
    view_col2: vec4<f32>,
}}
@group(0) @binding(0) var<uniform> lurek: LurekGlobals;
@group(1) @binding(0) var t_diffuse: texture_2d<f32>;
@group(1) @binding(1) var s_diffuse: sampler;
{uniform_decls}
@vertex
fn vs_main(in: VertexInput) -> VertexOutput {{
    var out: VertexOutput;
    let view = mat3x3<f32>(
        lurek.view_col0.xyz,
        lurek.view_col1.xyz,
        lurek.view_col2.xyz,
    );
    let cam_pos = view * vec3<f32>(in.position, 1.0);
    let w = max(in.w_depth, 0.001);
    let ndc_x = (cam_pos.x / lurek.lurek_ScreenSize.x) * 2.0 - 1.0;
    let ndc_y = 1.0 - (cam_pos.y / lurek.lurek_ScreenSize.y) * 2.0;
    out.clip_position = vec4<f32>(ndc_x * w, ndc_y * w, 0.0, w);
    out.color = in.color;
    out.uv = in.uv;
    out.local_pos = in.position;
    return out;
}}
{user_source}
@fragment
fn lurek_fragment_main(in: VertexOutput) -> @location(0) vec4<f32> {{
    let sampled = textureSample(t_diffuse, s_diffuse, in.uv) * in.color;
    return {fragment_entry}({fragment_call_args});
}}
"#,
        user_source = shader.wrapper_source(),
        fragment_entry = shader.fragment_entry_name(),
        fragment_call_args = fragment_call_args,
    )
}
/// Create a wgpu render pipeline for the given geometry kind, blend/stencil key, and shader module.
pub(crate) fn create_render_pipeline(
    device: &wgpu::Device,
    surface_format: wgpu::TextureFormat,
    layout: &wgpu::PipelineLayout,
    module: &wgpu::ShaderModule,
    geometry: GeometryKind,
    key: PipelineKey,
    fragment_entry: &str,
) -> wgpu::RenderPipeline {
    let primitive = wgpu::PrimitiveState {
        topology: wgpu::PrimitiveTopology::TriangleList,
        strip_index_format: None,
        front_face: wgpu::FrontFace::Ccw,
        cull_mode: None,
        polygon_mode: wgpu::PolygonMode::Fill,
        unclipped_depth: false,
        conservative: false,
    };
    let target = Some(wgpu::ColorTargetState {
        format: surface_format,
        blend: Some(blend_state_for(key.blend_mode)),
        write_mask: if matches!(key.stencil_mode, GpuStencilMode::Write(_)) {
            wgpu::ColorWrites::empty()
        } else {
            color_write_mask_from_bits(key.color_mask_bits)
        },
    });
    match geometry {
        GeometryKind::Color => device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
            label: Some("color_pipeline"),
            layout: Some(layout),
            vertex: wgpu::VertexState {
                module,
                entry_point: "vs_main",
                compilation_options: Default::default(),
                buffers: &[wgpu::VertexBufferLayout {
                    array_stride: std::mem::size_of::<ColorVertex>() as wgpu::BufferAddress,
                    step_mode: wgpu::VertexStepMode::Vertex,
                    attributes: &wgpu::vertex_attr_array![0 => Float32x2, 1 => Float32x4],
                }],
            },
            fragment: Some(wgpu::FragmentState {
                module,
                entry_point: fragment_entry,
                compilation_options: Default::default(),
                targets: &[target],
            }),
            primitive,
            depth_stencil: Some(depth_stencil_state(key.stencil_mode)),
            multisample: wgpu::MultisampleState::default(),
            multiview: None,
            cache: None,
        }),
        GeometryKind::Texture => device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
            label: Some("texture_pipeline"),
            layout: Some(layout),
            vertex: wgpu::VertexState {
                module,
                entry_point: "vs_main",
                compilation_options: Default::default(),
                buffers: &[wgpu::VertexBufferLayout {
                    array_stride: std::mem::size_of::<TexVertex>() as wgpu::BufferAddress,
                    step_mode: wgpu::VertexStepMode::Vertex,
                    attributes: &wgpu::vertex_attr_array![0 => Float32x2, 1 => Float32x2, 2 => Float32x4, 3 => Float32],
                }],
            },
            fragment: Some(wgpu::FragmentState {
                module,
                entry_point: fragment_entry,
                compilation_options: Default::default(),
                targets: &[target],
            }),
            primitive,
            depth_stencil: Some(depth_stencil_state(key.stencil_mode)),
            multisample: wgpu::MultisampleState::default(),
            multiview: None,
            cache: None,
        }),
        GeometryKind::ColorInstanced => device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
            label: Some("color_instanced_pipeline"),
            layout: Some(layout),
            vertex: wgpu::VertexState {
                module,
                entry_point: "vs_main",
                compilation_options: Default::default(),
                buffers: &[
                    wgpu::VertexBufferLayout {
                        array_stride: std::mem::size_of::<ColorVertex>() as wgpu::BufferAddress,
                        step_mode: wgpu::VertexStepMode::Vertex,
                        attributes: &wgpu::vertex_attr_array![0 => Float32x2, 1 => Float32x4],
                    },
                    wgpu::VertexBufferLayout {
                        array_stride: std::mem::size_of::<crate::render::gpu_types::InstanceData>() as wgpu::BufferAddress,
                        step_mode: wgpu::VertexStepMode::Instance,
                        attributes: &wgpu::vertex_attr_array![2 => Float32x2, 3 => Float32x2, 4 => Float32x2],
                    },
                ],
            },
            fragment: Some(wgpu::FragmentState {
                module,
                entry_point: fragment_entry,
                compilation_options: Default::default(),
                targets: &[target],
            }),
            primitive,
            depth_stencil: Some(depth_stencil_state(key.stencil_mode)),
            multisample: wgpu::MultisampleState::default(),
            multiview: None,
            cache: None,
        }),
        GeometryKind::TextureInstanced => device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
            label: Some("texture_instanced_pipeline"),
            layout: Some(layout),
            vertex: wgpu::VertexState {
                module,
                entry_point: "vs_main",
                compilation_options: Default::default(),
                buffers: &[
                    wgpu::VertexBufferLayout {
                        array_stride: std::mem::size_of::<TexVertex>() as wgpu::BufferAddress,
                        step_mode: wgpu::VertexStepMode::Vertex,
                        attributes: &wgpu::vertex_attr_array![0 => Float32x2, 1 => Float32x2, 2 => Float32x4, 3 => Float32],
                    },
                    wgpu::VertexBufferLayout {
                        array_stride: std::mem::size_of::<crate::render::gpu_types::InstanceData>() as wgpu::BufferAddress,
                        step_mode: wgpu::VertexStepMode::Instance,
                        attributes: &wgpu::vertex_attr_array![4 => Float32x2, 5 => Float32x2, 6 => Float32x2],
                    },
                ],
            },
            fragment: Some(wgpu::FragmentState {
                module,
                entry_point: fragment_entry,
                compilation_options: Default::default(),
                targets: &[target],
            }),
            primitive,
            depth_stencil: Some(depth_stencil_state(key.stencil_mode)),
            multisample: wgpu::MultisampleState::default(),
            multiview: None,
            cache: None,
        }),
        GeometryKind::Particle | GeometryKind::ParticleTextured => device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
            label: Some("particle_pipeline"),
            layout: Some(layout),
            vertex: wgpu::VertexState {
                module,
                entry_point: "vs_main",
                compilation_options: Default::default(),
                buffers: &[wgpu::VertexBufferLayout {
                    array_stride: std::mem::size_of::<ParticleVertex>() as wgpu::BufferAddress,
                    step_mode: wgpu::VertexStepMode::Vertex,
                    attributes: &wgpu::vertex_attr_array![
                        0 => Float32x2,
                        1 => Float32x4,
                        2 => Float32x2,
                        3 => Float32x2,
                        4 => Float32x2,
                        5 => Float32x2,
                        6 => Float32,
                        7 => Float32,
                        8 => Float32
                    ],
                }],
            },
            fragment: Some(wgpu::FragmentState {
                module,
                entry_point: fragment_entry,
                compilation_options: Default::default(),
                targets: &[target],
            }),
            primitive,
            depth_stencil: Some(depth_stencil_state(key.stencil_mode)),
            multisample: wgpu::MultisampleState::default(),
            multiview: None,
            cache: None,
        }),
        GeometryKind::Light => device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
            label: Some("custom_light_pipeline"),
            layout: Some(layout),
            vertex: wgpu::VertexState {
                module,
                entry_point: "vs_main",
                compilation_options: Default::default(),
                buffers: &[wgpu::VertexBufferLayout {
                    array_stride: std::mem::size_of::<LightVertex>() as wgpu::BufferAddress,
                    step_mode: wgpu::VertexStepMode::Vertex,
                    attributes: &wgpu::vertex_attr_array![
                        0 => Float32x2,
                        1 => Float32x2,
                        2 => Float32x4,
                        3 => Float32,
                        4 => Float32x4,
                        5 => Float32x2,
                        6 => Float32,
                        7 => Float32,
                        8 => Float32x2,
                        9 => Float32x4,
                        10 => Float32x4
                    ],
                }],
            },
            fragment: Some(wgpu::FragmentState {
                module,
                entry_point: fragment_entry,
                compilation_options: Default::default(),
                targets: &[target],
            }),
            primitive,
            depth_stencil: None,
            multisample: wgpu::MultisampleState::default(),
            multiview: None,
            cache: None,
        }),
    }
}
/// Build the depth/stencil descriptor for a given stencil mode.
pub fn depth_stencil_state(stencil_mode: GpuStencilMode) -> wgpu::DepthStencilState {
    wgpu::DepthStencilState {
        format: wgpu::TextureFormat::Depth24PlusStencil8,
        depth_write_enabled: false,
        depth_compare: wgpu::CompareFunction::Always,
        stencil: wgpu::StencilState {
            front: stencil_face_state(stencil_mode),
            back: stencil_face_state(stencil_mode),
            read_mask: if matches!(stencil_mode, GpuStencilMode::Disabled) {
                0
            } else {
                0xFF
            },
            write_mask: if matches!(stencil_mode, GpuStencilMode::Write(_)) {
                0xFF
            } else {
                0
            },
        },
        bias: wgpu::DepthBiasState::default(),
    }
}
/// Build a stencil face-state for the given stencil mode.
pub(crate) fn stencil_face_state(stencil_mode: GpuStencilMode) -> wgpu::StencilFaceState {
    match stencil_mode {
        GpuStencilMode::Disabled => wgpu::StencilFaceState {
            compare: wgpu::CompareFunction::Always,
            fail_op: wgpu::StencilOperation::Keep,
            depth_fail_op: wgpu::StencilOperation::Keep,
            pass_op: wgpu::StencilOperation::Keep,
        },
        GpuStencilMode::Write(action) => wgpu::StencilFaceState {
            compare: wgpu::CompareFunction::Always,
            fail_op: wgpu::StencilOperation::Keep,
            depth_fail_op: wgpu::StencilOperation::Keep,
            pass_op: stencil_operation(action),
        },
        GpuStencilMode::Test(compare) => wgpu::StencilFaceState {
            compare: compare_function(compare),
            fail_op: wgpu::StencilOperation::Keep,
            depth_fail_op: wgpu::StencilOperation::Keep,
            pass_op: wgpu::StencilOperation::Keep,
        },
    }
}
/// Map a renderer `CompareMode` to a wgpu `CompareFunction`.
pub fn compare_function(compare: crate::render::renderer::CompareMode) -> wgpu::CompareFunction {
    match compare {
        crate::render::renderer::CompareMode::Equal => wgpu::CompareFunction::Equal,
        crate::render::renderer::CompareMode::NotEqual => wgpu::CompareFunction::NotEqual,
        crate::render::renderer::CompareMode::Less => wgpu::CompareFunction::Less,
        crate::render::renderer::CompareMode::LessEqual => wgpu::CompareFunction::LessEqual,
        crate::render::renderer::CompareMode::Greater => wgpu::CompareFunction::Greater,
        crate::render::renderer::CompareMode::GreaterEqual => wgpu::CompareFunction::GreaterEqual,
        crate::render::renderer::CompareMode::Always => wgpu::CompareFunction::Always,
        crate::render::renderer::CompareMode::Never => wgpu::CompareFunction::Never,
    }
}
/// Map a renderer `StencilAction` to a wgpu `StencilOperation`.
pub fn stencil_operation(action: crate::render::renderer::StencilAction) -> wgpu::StencilOperation {
    match action {
        crate::render::renderer::StencilAction::Replace => wgpu::StencilOperation::Replace,
        crate::render::renderer::StencilAction::Increment => wgpu::StencilOperation::IncrementClamp,
        crate::render::renderer::StencilAction::Decrement => wgpu::StencilOperation::DecrementClamp,
        crate::render::renderer::StencilAction::IncrementWrap => {
            wgpu::StencilOperation::IncrementWrap
        }
        crate::render::renderer::StencilAction::DecrementWrap => {
            wgpu::StencilOperation::DecrementWrap
        }
        crate::render::renderer::StencilAction::Keep => wgpu::StencilOperation::Keep,
        crate::render::renderer::StencilAction::Zero => wgpu::StencilOperation::Zero,
        crate::render::renderer::StencilAction::Invert => wgpu::StencilOperation::Invert,
    }
}
