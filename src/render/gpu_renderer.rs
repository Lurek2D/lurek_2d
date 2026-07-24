//! Owns the render GPU renderer implementation for the render subsystem and keeps related runtime rules local here.
//! Keeps draw commands, GPU resources, and render-pass configuration so helpers stay close to invariants this file updates.
//! Defines how render GPU renderer data is validated, transformed, or stored before neighboring systems consume it.
//! Separates render GPU renderer behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where render code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing render GPU renderer defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near render GPU renderer state that explains them instead of spreading rules outward.
//! Preserves deterministic behavior by keeping render GPU renderer calculations at their owning subsystem boundary.
//! Provides local adaptation layer that lets callers reuse render GPU renderer rules without duplicating engine decisions.
//! Open this owner before sibling files when a regression centers on render GPU renderer state, helpers, or rules.
//! Works with neighboring render owners while keeping the main render GPU renderer responsibility anchored in one file.

use crate::math::{polygon, Mat3, Vec2};
use crate::render::mesh::Mesh;
use crate::render::renderer::{
    adaptive_circle_ellipse_segments, BevelStyle, BlendMode, DrawMode, DrawableKind,
    GradientDirection, HexOrientation, ParticleRenderShape, PathSegment, RenderCommand,
    TextureData,
};
use crate::render::shader::{Shader, ShaderTarget};
use crate::runtime::resource_keys::{
    CanvasKey, FontKey, MeshKey, ShaderKey, ShapeKey, SpriteBatchKey, StaticGeometryKey, TextureKey,
};
use slotmap::{Key, SlotMap, SparseSecondaryMap};
use std::collections::{HashMap, HashSet};
use std::f32::consts::PI;
use std::sync::{
    atomic::{AtomicU8, Ordering},
    Arc, OnceLock,
};
use std::time::Instant;

use crate::render::gpu_light::{MAX_SHADOW_LIGHTS, SHADOW_MAP_RES};
use crate::render::gpu_pipeline::{
    GeometryKind, GpuStencilMode, PipelineKey, PipelineSelectionKey,
};
use crate::render::gpu_shadows::ShadowEdgeCache;
use crate::render::gpu_state::{FrameRenderBuffers, RenderStats};
use crate::render::gpu_types::{
    ColorVertex, LightVertex, ParticleVertex, PreparedDraw, RenderTargetId, ShadowDispatchInput,
    TexRef, TexVertex, ViewportUniform, MAX_COLOR_IDXS, MAX_COLOR_VERTS, MAX_LIGHT_QUADS,
    MAX_PARTICLE_IDXS, MAX_PARTICLE_VERTS, MAX_TEX_IDXS, MAX_TEX_VERTS,
};
use crate::render::input_validation::{
    validate_compound_shape, validate_render_command_with_category, validate_render_frame_state,
    RenderInputLimits,
};
use crate::render::{RenderBudget, RenderBudgetLimits};
use crate::render::province_map_pipeline::{
    ProvinceMapDataBindings, ProvinceMapPipeline, ProvinceMapUniforms,
};
use crate::render::render_diagnostics::RenderDiagnostics;
use wgpu::util::DeviceExt;

// Submodule helper imports
use crate::render::gpu_frame_builder::merge_adjacent_prepared_draws;
use crate::render::gpu_resources::texture_needs_upload;
use crate::render::gpu_tess::{
    append_color_draw, append_color_draw_range, append_tex_draw_slices, apply,
    color_write_mask_bits, normalize_scissor, push_quad_verts, push_tex_quad,
    push_tex_quad_corners, push_thick_line,
};

mod frame;
mod frame_advanced;
mod frame_basic;
mod frame_mid;

struct PendingProvinceMapDraw {
    registry_name: String,
    viewport: [f32; 4],
    screen_size: [f32; 2],
    tint: [f32; 4],
    province_tints: Vec<(u32, [f32; 4])>,
    terrain_texture: Option<TextureKey>,
    effects: crate::render::renderer::ProvinceMapEffectOptions,
    selected_id: u32,
    hovered_id: u32,
    zoom_mode: u32,
    time: f32,
}

struct GpuDrawTransform {
    x: f32,
    y: f32,
    rotation: f32,
    sx: f32,
    sy: f32,
    ox: f32,
    oy: f32,
}

struct ProvinceMapGpuCache {
    textures: crate::province::gpu_upload::ProvinceGpuTextures,
    border_index: crate::province::border_index::ProvinceBorderIndex,
    revision: u64,
    province_data_buffer: wgpu::Buffer,
    border_style_buffer: wgpu::Buffer,
    data_bind_group: wgpu::BindGroup,
}

impl ProvinceMapGpuCache {
    fn new(
        device: &wgpu::Device,
        queue: &wgpu::Queue,
        pipeline: &ProvinceMapPipeline,
        registry: &crate::province::registry::ProvinceRegistry,
    ) -> Self {
        let width = registry.width();
        let height = registry.height();
        let mut province_ids = Vec::with_capacity((width as usize).saturating_mul(height as usize));
        for y in 0..height {
            for x in 0..width {
                province_ids.push(registry.get_at(x, y));
            }
        }

        let border_index =
            crate::province::border_index::build_border_index_from_registry(registry);
        let distance_field =
            crate::province::distance_field::compute_distance_field_from_registry(registry, 32);
        let textures = crate::province::gpu_upload::create_province_gpu_textures(
            device,
            queue,
            width,
            height,
            &province_ids,
            &border_index.data,
            &distance_field.data,
        );
        let province_records = crate::province::gpu_bridge::build_dense_gpu_records(registry);
        let border_records =
            crate::province::gpu_bridge::build_border_style_gpu_records(registry, &border_index);
        let province_data_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("province_map_province_data"),
            contents: bytemuck::cast_slice(&province_records),
            usage: wgpu::BufferUsages::STORAGE | wgpu::BufferUsages::COPY_DST,
        });
        let border_style_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("province_map_border_styles"),
            contents: bytemuck::cast_slice(&border_records),
            usage: wgpu::BufferUsages::STORAGE | wgpu::BufferUsages::COPY_DST,
        });
        let data_bind_group = pipeline.create_data_bind_group(
            device,
            ProvinceMapDataBindings {
                province_id_view: &textures.province_id_view,
                border_index_view: &textures.border_index_view,
                distance_field_view: &textures.distance_field_view,
                province_data_buffer: &province_data_buffer,
                border_style_buffer: &border_style_buffer,
                terrain_texture_view: &pipeline.default_terrain_view,
                terrain_texture_sampler: &pipeline.default_terrain_sampler,
            },
        );

        Self {
            textures,
            border_index,
            revision: registry.revision(),
            province_data_buffer,
            border_style_buffer,
            data_bind_group,
        }
    }

    fn refresh_dynamic_buffers(
        &mut self,
        device: &wgpu::Device,
        queue: &wgpu::Queue,
        pipeline: &ProvinceMapPipeline,
        registry: &crate::province::registry::ProvinceRegistry,
    ) {
        let border_index =
            crate::province::border_index::build_border_index_from_registry(registry);
        if border_index.data != self.border_index.data
            || border_index.id_to_pair != self.border_index.id_to_pair
        {
            let (border_index_texture, border_index_view) =
                crate::province::gpu_upload::create_border_index_texture(
                    device,
                    queue,
                    self.textures.width,
                    self.textures.height,
                    &border_index.data,
                );
            self.textures.border_index_texture = border_index_texture;
            self.textures.border_index_view = border_index_view;
            self.border_index = border_index;
        }

        let province_records = crate::province::gpu_bridge::build_dense_gpu_records(registry);
        let border_records = crate::province::gpu_bridge::build_border_style_gpu_records(
            registry,
            &self.border_index,
        );
        self.province_data_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("province_map_province_data"),
            contents: bytemuck::cast_slice(&province_records),
            usage: wgpu::BufferUsages::STORAGE | wgpu::BufferUsages::COPY_DST,
        });
        self.border_style_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("province_map_border_styles"),
            contents: bytemuck::cast_slice(&border_records),
            usage: wgpu::BufferUsages::STORAGE | wgpu::BufferUsages::COPY_DST,
        });
        self.data_bind_group = pipeline.create_data_bind_group(
            device,
            ProvinceMapDataBindings {
                province_id_view: &self.textures.province_id_view,
                border_index_view: &self.textures.border_index_view,
                distance_field_view: &self.textures.distance_field_view,
                province_data_buffer: &self.province_data_buffer,
                border_style_buffer: &self.border_style_buffer,
                terrain_texture_view: &pipeline.default_terrain_view,
                terrain_texture_sampler: &pipeline.default_terrain_sampler,
            },
        );
        self.revision = registry.revision();
    }
}

fn province_map_uses_render_tints(draw: &PendingProvinceMapDraw) -> bool {
    !draw.province_tints.is_empty()
}

fn build_tinted_province_records(
    registry: &crate::province::registry::ProvinceRegistry,
    province_tints: &[(u32, [f32; 4])],
) -> Vec<crate::province::gpu_bridge::ProvinceGpuRecord> {
    let mut records = crate::province::gpu_bridge::build_dense_gpu_records(registry);
    for (id, color) in province_tints {
        if let Some(record) = records.get_mut(*id as usize) {
            record.political_color = *color;
        }
    }
    records
}

fn transform_stack_last(stack: &[Mat3]) -> &Mat3 {
    static IDENTITY: OnceLock<Mat3> = OnceLock::new();
    stack
        .last()
        .unwrap_or_else(|| IDENTITY.get_or_init(Mat3::identity))
}

fn transform_stack_last_mut(stack: &mut Vec<Mat3>) -> &mut Mat3 {
    if stack.is_empty() {
        stack.push(Mat3::identity());
    }
    let last_index = stack.len() - 1;
    &mut stack[last_index]
}

fn transformed_draw_matrix(parent: &Mat3, transform: GpuDrawTransform) -> Mat3 {
    *parent
        * Mat3::from_translation(Vec2 {
            x: transform.x,
            y: transform.y,
        })
        * Mat3::from_rotation(transform.rotation)
        * Mat3::from_scale(Vec2 {
            x: transform.sx,
            y: transform.sy,
        })
        * Mat3::from_translation(Vec2 {
            x: -transform.ox,
            y: -transform.oy,
        })
}

/// Built-in flat-color vertex + fragment WGSL shader.
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
    let view = mat3x3<f32>(viewport.view_col0.xyz, viewport.view_col1.xyz, viewport.view_col2.xyz);
    let cam_pos = view * vec3<f32>(in.position, 1.0);
    out.clip_position = vec4<f32>((cam_pos.x / viewport.size.x)*2.0-1.0, 1.0-(cam_pos.y/viewport.size.y)*2.0, 0.0, 1.0);
    out.color = in.color;
    return out;
}
@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> { return in.color; }
"#;

/// Built-in flat-color instanced WGSL shader.
const COLOR_INSTANCED_SHADER: &str = r#"
struct VertexInput {
    @location(0) position: vec2<f32>,
    @location(1) color:    vec4<f32>,
    @location(2) col0:     vec2<f32>,
    @location(3) col1:     vec2<f32>,
    @location(4) col2:     vec2<f32>,
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
    let view = mat3x3<f32>(viewport.view_col0.xyz, viewport.view_col1.xyz, viewport.view_col2.xyz);
    let world_pos = vec2<f32>(
        in.position.x * in.col0.x + in.position.y * in.col1.x + in.col2.x,
        in.position.x * in.col0.y + in.position.y * in.col1.y + in.col2.y
    );
    let cam_pos = view * vec3<f32>(world_pos, 1.0);
    out.clip_position = vec4<f32>((cam_pos.x / viewport.size.x)*2.0-1.0, 1.0-(cam_pos.y/viewport.size.y)*2.0, 0.0, 1.0);
    out.color = in.color;
    return out;
}
@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> { return in.color; }
"#;

/// Built-in textured vertex + fragment WGSL shader.
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
    let view = mat3x3<f32>(viewport.view_col0.xyz, viewport.view_col1.xyz, viewport.view_col2.xyz);
    let cam_pos = view * vec3<f32>(in.position, 1.0);
    let w = max(in.w_depth, 0.001);
    let ndc_x = (cam_pos.x / viewport.size.x) * 2.0 - 1.0;
    let ndc_y = 1.0 - (cam_pos.y / viewport.size.y) * 2.0;
    out.clip_position = vec4<f32>(ndc_x * w, ndc_y * w, 0.0, w);
    out.uv = in.uv;
    out.color = in.color;
    return out;
}
@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    return textureSample(t_diffuse, s_diffuse, in.uv) * in.color;
}
"#;

/// Built-in textured instanced WGSL shader.
const TEXTURE_INSTANCED_SHADER: &str = r#"
struct VertexInput {
    @location(0) position: vec2<f32>,
    @location(1) uv:       vec2<f32>,
    @location(2) color:    vec4<f32>,
    @location(3) w_depth:  f32,
    @location(4) col0:     vec2<f32>,
    @location(5) col1:     vec2<f32>,
    @location(6) col2:     vec2<f32>,
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
    let view = mat3x3<f32>(viewport.view_col0.xyz, viewport.view_col1.xyz, viewport.view_col2.xyz);
    let world_pos = vec2<f32>(
        in.position.x * in.col0.x + in.position.y * in.col1.x + in.col2.x,
        in.position.x * in.col0.y + in.position.y * in.col1.y + in.col2.y
    );
    let cam_pos = view * vec3<f32>(world_pos, 1.0);
    let w = max(in.w_depth, 0.001);
    let ndc_x = (cam_pos.x / viewport.size.x) * 2.0 - 1.0;
    let ndc_y = 1.0 - (cam_pos.y / viewport.size.y) * 2.0;
    out.clip_position = vec4<f32>(ndc_x * w, ndc_y * w, 0.0, w);
    out.uv = in.uv;
    out.color = in.color;
    return out;
}
@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    return textureSample(t_diffuse, s_diffuse, in.uv) * in.color;
}
"#;

/// Built-in light quad WGSL shader with 1-D shadow map sampling.
pub(crate) const LIGHT_SHADER: &str = r#"
struct VertexInput {
    @location(0) position: vec2<f32>,
    @location(1) uv:       vec2<f32>,
    @location(2) color:    vec4<f32>,
    @location(3) shadow_v: f32,
    @location(4) shadow_params: vec4<f32>,
    @location(5) light_pos: vec2<f32>,
    @location(6) radius: f32,
    @location(7) intensity: f32,
    @location(8) normal_hint: vec2<f32>,
}
struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0)       uv:            vec2<f32>,
    @location(1)       color:         vec4<f32>,
    @location(2)       shadow_v:      f32,
    @location(3)       shadow_params: vec4<f32>,
    @location(4)       intensity:     f32,
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
    let view = mat3x3<f32>(viewport.view_col0.xyz, viewport.view_col1.xyz, viewport.view_col2.xyz);
    let cam_pos = view * vec3<f32>(in.position, 1.0);
    out.clip_position = vec4<f32>((cam_pos.x/viewport.size.x)*2.0-1.0, 1.0-(cam_pos.y/viewport.size.y)*2.0, 0.0, 1.0);
    out.uv = in.uv; out.color = in.color; out.shadow_v = in.shadow_v; out.shadow_params = in.shadow_params; out.intensity = in.intensity;
    return out;
}
fn sample_shadow_row(u: f32, v: f32, mode: f32, texel_size: f32) -> f32 {
    if mode < 0.5 { return textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u, v)).r; }
    var acc = 0.0;
    if mode < 1.5 {
        for (var k = -2; k <= 2; k++) { acc += textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u + f32(k)*texel_size, v)).r; }
        return acc / 5.0;
    }
    for (var k = -6; k <= 6; k++) { acc += textureSample(shadow_atlas, shadow_sampler, vec2<f32>(u + f32(k)*texel_size, v)).r; }
    return acc / 13.0;
}
@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let delta = in.uv - vec2<f32>(0.5, 0.5);
    let dist  = length(delta) * 2.0;
    let intensity = clamp(1.0 - dist, 0.0, 1.0) * clamp(1.0 - dist, 0.0, 1.0);
    var shadow = 1.0;
    if in.shadow_v >= 0.0 {
        let angle = atan2(delta.y, delta.x);
        let u = (angle + 3.14159265) / (2.0 * 3.14159265);
        let sd = sample_shadow_row(u, in.shadow_v, in.shadow_params.x, in.shadow_params.z);
        let edge = max(1e-4, in.shadow_params.y * 0.05);
        shadow = 1.0 - smoothstep(sd - edge, sd + edge, dist * 0.5);
    }
    return vec4<f32>(in.color.rgb * intensity * shadow * in.intensity, 1.0);
}
"#;

/// Shadow compute WGSL shader Ă˘â‚¬â€ť ray-marches edges to build 1-D shadow map rows.
pub(crate) const SHADOW_COMPUTE_SHADER: &str = r#"
struct Edge { ax: f32, ay: f32, sx: f32, sy: f32, }
struct Params { inv_radius: f32, edge_count: u32, row: u32, _pad: u32, }
@group(0) @binding(0) var<storage, read> edges: array<Edge>;
@group(0) @binding(1) var<uniform> params: Params;
@group(0) @binding(2) var shadow_atlas: texture_storage_2d<r32float, write>;
@compute @workgroup_size(64)
fn cs_main(@builtin(global_invocation_id) gid: vec3<u32>) {
    let i = gid.x;
    if (i >= 256u) { return; }
    let angle = (f32(i) / 256.0) * 6.28318530718 - 3.14159265359;
    let dir_x = cos(angle); let dir_y = sin(angle);
    var min_dist = 1.0;
    for (var edge_idx = 0u; edge_idx < params.edge_count; edge_idx++) {
        let e = edges[edge_idx];
        let cross_ds = dir_x * e.sy - dir_y * e.sx;
        if (abs(cross_ds) < 1e-8) { continue; }
        let inv = 1.0 / cross_ds;
        let t = (e.ax * e.sy - e.ay * e.sx) * inv;
        let u = (e.ax * dir_y - e.ay * dir_x) * inv;
        if (t > 0.0 && u >= 0.0 && u <= 1.0) {
            let nd = t * params.inv_radius;
            if (nd < min_dist && nd < 1.0) { min_dist = nd; }
        }
    }
    textureStore(shadow_atlas, vec2<i32>(i32(i), i32(params.row)), vec4<f32>(min_dist, 0.0, 0.0, 1.0));
}
"#;

/// Concrete hardware-accelerated 2D renderer backing all Lurek2D visual presentation.
pub struct GpuRenderer {
    /// wgpu logical device handle.
    pub(crate) device: wgpu::Device,
    /// wgpu submission queue.
    pub(crate) queue: wgpu::Queue,
    /// Bind-group layout for the viewport uniform buffer.
    pub(crate) viewport_bind_group_layout: wgpu::BindGroupLayout,
    /// Compiled WGSL module for the built-in flat-color shader.
    pub(crate) default_color_shader: wgpu::ShaderModule,
    /// Compiled WGSL module for the built-in textured shader.
    pub(crate) default_texture_shader: wgpu::ShaderModule,
    /// Compiled WGSL module for the built-in flat-color instanced shader.
    pub(crate) default_color_instanced_shader: wgpu::ShaderModule,
    /// Compiled WGSL module for the built-in textured instanced shader.
    pub(crate) default_texture_instanced_shader: wgpu::ShaderModule,
    /// Pipeline layout for the built-in color shader.
    pub(crate) default_color_layout: wgpu::PipelineLayout,
    /// Pipeline layout for the built-in texture shader.
    pub(crate) default_texture_layout: wgpu::PipelineLayout,
    /// Cached default color pipelines keyed by blend/stencil state.
    pub(crate) default_color_pipelines:
        HashMap<crate::render::gpu_pipeline::PipelineKey, wgpu::RenderPipeline>,
    /// Cached default texture pipelines keyed by blend/stencil state.
    pub(crate) default_texture_pipelines:
        HashMap<crate::render::gpu_pipeline::PipelineKey, wgpu::RenderPipeline>,
    /// Cached default color instanced pipelines.
    pub(crate) default_color_instanced_pipelines:
        HashMap<crate::render::gpu_pipeline::PipelineKey, wgpu::RenderPipeline>,
    /// Cached default texture instanced pipelines.
    pub(crate) default_texture_instanced_pipelines:
        HashMap<crate::render::gpu_pipeline::PipelineKey, wgpu::RenderPipeline>,
    /// User-uploaded shader cache keyed by `ShaderKey`.
    pub(crate) shader_cache: SparseSecondaryMap<ShaderKey, crate::render::gpu_shaders::GpuShader>,
    /// GPU buffer holding the current-frame `ViewportUniform`.
    pub(crate) viewport_buffer: wgpu::Buffer,
    /// Bind group binding `viewport_buffer` to binding 0.
    pub(crate) viewport_bind_group: wgpu::BindGroup,
    /// Shared bind-group layout for all texture+sampler pairs.
    pub(crate) texture_bind_group_layout: wgpu::BindGroupLayout,
    /// Pre-allocated flat-color vertex buffer.
    pub(crate) color_vertex_buffer: wgpu::Buffer,
    /// Pre-allocated flat-color index buffer.
    pub(crate) color_index_buffer: wgpu::Buffer,
    /// Pre-allocated textured vertex buffer.
    pub(crate) tex_vertex_buffer: wgpu::Buffer,
    /// Pre-allocated textured index buffer.
    pub(crate) tex_index_buffer: wgpu::Buffer,
    /// Current capacity of `color_vertex_buffer` in vertex units.
    pub(crate) color_vertex_capacity: u64,
    /// Current capacity of `color_index_buffer` in index units.
    pub(crate) color_index_capacity: u64,
    /// Current capacity of `tex_vertex_buffer` in vertex units.
    pub(crate) tex_vertex_capacity: u64,
    /// Current capacity of `tex_index_buffer` in index units.
    pub(crate) tex_index_capacity: u64,
    /// GPU vertex buffer used by particle shader draws.
    pub(crate) particle_vertex_buffer: wgpu::Buffer,
    /// GPU index buffer used by particle shader draws.
    pub(crate) particle_index_buffer: wgpu::Buffer,
    /// Current capacity of `particle_vertex_buffer` in vertex units.
    pub(crate) particle_vertex_capacity: u64,
    /// Current capacity of `particle_index_buffer` in index units.
    pub(crate) particle_index_capacity: u64,
    /// GPU textures keyed by `TextureKey`.
    pub(crate) gpu_textures: SparseSecondaryMap<TextureKey, crate::render::gpu_state::GpuTexture>,
    /// Font atlas GPU textures keyed by `FontKey`.
    pub(crate) font_atlas_textures:
        SparseSecondaryMap<FontKey, crate::render::gpu_state::GpuTexture>,
    /// Canvas render-target textures keyed by `CanvasKey`.
    pub(crate) canvas_gpu_textures:
        SparseSecondaryMap<CanvasKey, crate::render::gpu_state::GpuTexture>,
    /// Lazily created depth/stencil attachment for the main screen target.
    pub(crate) screen_stencil_target: Option<crate::render::gpu_state::DepthStencilTarget>,
    /// Per-canvas depth/stencil attachments created on first stencil use.
    pub(crate) canvas_stencil_targets:
        SparseSecondaryMap<CanvasKey, crate::render::gpu_state::DepthStencilTarget>,
    /// Tracks which canvases still need a clear at the start of the next frame.
    pub(crate) canvas_needs_clear: SparseSecondaryMap<CanvasKey, bool>,
    /// Surface texture format negotiated at creation.
    pub(crate) surface_format: wgpu::TextureFormat,
    /// Current framebuffer width in pixels.
    pub width: u32,
    /// Current framebuffer height in pixels.
    pub height: u32,
    /// Per-frame rendering statistics updated by `render_frame`.
    pub render_stats: crate::render::gpu_state::RenderStats,
    /// Per-frame diagnostics for skipped commands and invalid render resources.
    pub render_diagnostics: crate::render::RenderDiagnostics,
    /// Saturating diagnostics accumulated from completed prior frames.
    pub render_diagnostics_total: crate::render::RenderDiagnostics,
    /// Optional light accumulation and shadow-atlas GPU state.
    pub(crate) light_gpu: Option<crate::render::gpu_light::LightGpuState>,
    /// Optional post-processing pipeline chain applied after the main pass.
    pub(crate) postfx_pipeline: Option<crate::render::postfx_pipeline::PostFxPipeline>,
    /// Specialized fullscreen province-map shader pipeline.
    pub(crate) province_map_pipeline: ProvinceMapPipeline,
    /// GPU resource cache for immutable province map textures and mutable style buffers.
    province_map_cache: HashMap<String, ProvinceMapGpuCache>,
    /// Per-effect capture textures for multi-pass post-fx.
    pub(crate) postfx_capture: HashMap<u64, crate::render::postfx_pipeline::PostFxTexture>,
    /// Persistent geometry and instancing buffer cache.
    pub(crate) mesh_cache: crate::render::gpu_state::GpuMeshCache,
    /// Pre-allocated instancing vertex buffer.
    pub(crate) instance_buffer: wgpu::Buffer,
    /// Current capacity of `instance_buffer` in instance units.
    pub(crate) instance_capacity: u64,
    /// CPU-side frame buffers reused across `render_frame` calls.
    pub(crate) frame_buffers: FrameRenderBuffers,
    /// One non-blocking surface readback retained across frame polls.
    pub(crate) pending_surface_readback: Option<crate::render::gpu_state::PendingSurfaceReadback>,
    /// State of the current or most recently completed bounded readback request.
    pub surface_readback_status: crate::render::gpu_state::SurfaceReadbackStatus,
    /// Shared uncaptured GPU failure signal written by wgpu's callback and consumed by the app loop.
    uncaptured_gpu_failure: Arc<AtomicU8>,
}

impl GpuRenderer {
    /// Create a `GpuRenderer` from an already-acquired wgpu device/queue pair and surface format.
    pub fn new(
        device: wgpu::Device,
        queue: wgpu::Queue,
        surface_format: wgpu::TextureFormat,
        width: u32,
        height: u32,
    ) -> Self {
        let uncaptured_gpu_failure = Arc::new(AtomicU8::new(0));
        let callback_failure = Arc::clone(&uncaptured_gpu_failure);
        device.on_uncaptured_error(Box::new(move |error| {
            // Keep driver-originated descriptions out of game-visible diagnostics.
            let (category, signal) = match error {
                wgpu::Error::OutOfMemory { .. } => ("out of memory", 1),
                wgpu::Error::Validation { .. } => ("validation error", 2),
                wgpu::Error::Internal { .. } => ("internal error", 2),
            };
            callback_failure.fetch_max(signal, Ordering::Release);
            log::error!("Uncaptured GPU {category}");
        }));
        let viewport_data = ViewportUniform {
            size: [width as f32, height as f32],
            time: 0.0,
            _pad: 0.0,
            view_col0: [1.0, 0.0, 0.0, 0.0],
            view_col1: [0.0, 1.0, 0.0, 0.0],
            view_col2: [0.0, 0.0, 1.0, 0.0],
        };
        let viewport_buffer = device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("viewport_uniform"),
            size: std::mem::size_of::<ViewportUniform>() as u64,
            usage: wgpu::BufferUsages::UNIFORM | wgpu::BufferUsages::COPY_DST,
            mapped_at_creation: false,
        });
        queue.write_buffer(&viewport_buffer, 0, bytemuck::bytes_of(&viewport_data));
        let viewport_bgl = device.create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
            label: Some("viewport_bgl"),
            entries: &[wgpu::BindGroupLayoutEntry {
                binding: 0,
                visibility: wgpu::ShaderStages::VERTEX,
                ty: wgpu::BindingType::Buffer {
                    ty: wgpu::BufferBindingType::Uniform,
                    has_dynamic_offset: false,
                    min_binding_size: None,
                },
                count: None,
            }],
        });
        let texture_bgl = device.create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
            label: Some("texture_bgl"),
            entries: &[
                wgpu::BindGroupLayoutEntry {
                    binding: 0,
                    visibility: wgpu::ShaderStages::FRAGMENT,
                    ty: wgpu::BindingType::Texture {
                        sample_type: wgpu::TextureSampleType::Float { filterable: true },
                        view_dimension: wgpu::TextureViewDimension::D2,
                        multisampled: false,
                    },
                    count: None,
                },
                wgpu::BindGroupLayoutEntry {
                    binding: 1,
                    visibility: wgpu::ShaderStages::FRAGMENT,
                    ty: wgpu::BindingType::Sampler(wgpu::SamplerBindingType::Filtering),
                    count: None,
                },
            ],
        });
        let viewport_bg = device.create_bind_group(&wgpu::BindGroupDescriptor {
            label: Some("viewport_bg"),
            layout: &viewport_bgl,
            entries: &[wgpu::BindGroupEntry {
                binding: 0,
                resource: viewport_buffer.as_entire_binding(),
            }],
        });
        let color_shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
            label: Some("color_shader"),
            source: wgpu::ShaderSource::Wgsl(COLOR_SHADER.into()),
        });
        let texture_shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
            label: Some("texture_shader"),
            source: wgpu::ShaderSource::Wgsl(TEXTURE_SHADER.into()),
        });
        let color_instanced_shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
            label: Some("color_instanced_shader"),
            source: wgpu::ShaderSource::Wgsl(COLOR_INSTANCED_SHADER.into()),
        });
        let texture_instanced_shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
            label: Some("texture_instanced_shader"),
            source: wgpu::ShaderSource::Wgsl(TEXTURE_INSTANCED_SHADER.into()),
        });
        let color_layout = device.create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
            label: Some("color_layout"),
            bind_group_layouts: &[&viewport_bgl],
            push_constant_ranges: &[],
        });
        let texture_layout = device.create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
            label: Some("texture_layout"),
            bind_group_layouts: &[&viewport_bgl, &texture_bgl],
            push_constant_ranges: &[],
        });
        let color_vertex_buffer = device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("color_vbo"),
            size: MAX_COLOR_VERTS * std::mem::size_of::<ColorVertex>() as u64,
            usage: wgpu::BufferUsages::VERTEX | wgpu::BufferUsages::COPY_DST,
            mapped_at_creation: false,
        });
        let color_index_buffer = device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("color_ibo"),
            size: MAX_COLOR_IDXS * std::mem::size_of::<u32>() as u64,
            usage: wgpu::BufferUsages::INDEX | wgpu::BufferUsages::COPY_DST,
            mapped_at_creation: false,
        });
        let tex_vertex_buffer = device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("tex_vbo"),
            size: MAX_TEX_VERTS * std::mem::size_of::<TexVertex>() as u64,
            usage: wgpu::BufferUsages::VERTEX | wgpu::BufferUsages::COPY_DST,
            mapped_at_creation: false,
        });
        let tex_index_buffer = device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("tex_ibo"),
            size: MAX_TEX_IDXS * std::mem::size_of::<u32>() as u64,
            usage: wgpu::BufferUsages::INDEX | wgpu::BufferUsages::COPY_DST,
            mapped_at_creation: false,
        });
        let particle_vertex_buffer = device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("particle_vbo"),
            size: MAX_PARTICLE_VERTS * std::mem::size_of::<ParticleVertex>() as u64,
            usage: wgpu::BufferUsages::VERTEX | wgpu::BufferUsages::COPY_DST,
            mapped_at_creation: false,
        });
        let particle_index_buffer = device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("particle_ibo"),
            size: MAX_PARTICLE_IDXS * std::mem::size_of::<u32>() as u64,
            usage: wgpu::BufferUsages::INDEX | wgpu::BufferUsages::COPY_DST,
            mapped_at_creation: false,
        });
        let instance_buffer = device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("instance_vbo"),
            size: 1024 * std::mem::size_of::<crate::render::gpu_types::InstanceData>() as u64,
            usage: wgpu::BufferUsages::VERTEX | wgpu::BufferUsages::COPY_DST,
            mapped_at_creation: false,
        });
        let mut mesh_cache = crate::render::gpu_state::GpuMeshCache::default();
        {
            use wgpu::util::DeviceExt;
            let quad_verts = [
                TexVertex {
                    position: [0.0, 0.0],
                    uv: [0.0, 0.0],
                    color: [1.0, 1.0, 1.0, 1.0],
                    w_depth: 1.0,
                    _pad: [0.0; 3],
                },
                TexVertex {
                    position: [1.0, 0.0],
                    uv: [1.0, 0.0],
                    color: [1.0, 1.0, 1.0, 1.0],
                    w_depth: 1.0,
                    _pad: [0.0; 3],
                },
                TexVertex {
                    position: [1.0, 1.0],
                    uv: [1.0, 1.0],
                    color: [1.0, 1.0, 1.0, 1.0],
                    w_depth: 1.0,
                    _pad: [0.0; 3],
                },
                TexVertex {
                    position: [0.0, 1.0],
                    uv: [0.0, 1.0],
                    color: [1.0, 1.0, 1.0, 1.0],
                    w_depth: 1.0,
                    _pad: [0.0; 3],
                },
            ];
            let quad_idxs = [0u32, 1, 2, 0, 2, 3];

            let quad_vbo = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                label: Some("quad_vbo"),
                contents: bytemuck::cast_slice(&quad_verts),
                usage: wgpu::BufferUsages::VERTEX,
            });
            let quad_ibo = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                label: Some("quad_ibo"),
                contents: bytemuck::cast_slice(&quad_idxs),
                usage: wgpu::BufferUsages::INDEX,
            });

            let quad_key = crate::runtime::resource_keys::StaticGeometryKey::default();
            let quad_entry = crate::render::gpu_state::StaticGeometryCacheEntry {
                vertex_buffer: quad_vbo,
                index_buffer: quad_ibo,
                index_count: 6,
                geometry_kind: crate::render::gpu_pipeline::GeometryKind::TextureInstanced,
                texture: None,
            };
            mesh_cache.static_geometry.insert(quad_key, quad_entry);
        }
        let province_map_pipeline = ProvinceMapPipeline::new(&device, &queue, surface_format);
        GpuRenderer {
            device,
            queue,
            viewport_bind_group_layout: viewport_bgl,
            default_color_shader: color_shader,
            default_texture_shader: texture_shader,
            default_color_instanced_shader: color_instanced_shader,
            default_texture_instanced_shader: texture_instanced_shader,
            default_color_layout: color_layout,
            default_texture_layout: texture_layout,
            default_color_pipelines: HashMap::new(),
            default_texture_pipelines: HashMap::new(),
            default_color_instanced_pipelines: HashMap::new(),
            default_texture_instanced_pipelines: HashMap::new(),
            shader_cache: SparseSecondaryMap::new(),
            viewport_buffer,
            viewport_bind_group: viewport_bg,
            texture_bind_group_layout: texture_bgl,
            color_vertex_buffer,
            color_index_buffer,
            tex_vertex_buffer,
            tex_index_buffer,
            particle_vertex_buffer,
            particle_index_buffer,
            color_vertex_capacity: MAX_COLOR_VERTS,
            color_index_capacity: MAX_COLOR_IDXS,
            tex_vertex_capacity: MAX_TEX_VERTS,
            tex_index_capacity: MAX_TEX_IDXS,
            particle_vertex_capacity: MAX_PARTICLE_VERTS,
            particle_index_capacity: MAX_PARTICLE_IDXS,
            instance_buffer,
            instance_capacity: 1024,
            gpu_textures: SparseSecondaryMap::new(),
            font_atlas_textures: SparseSecondaryMap::new(),
            canvas_gpu_textures: SparseSecondaryMap::new(),
            screen_stencil_target: None,
            canvas_stencil_targets: SparseSecondaryMap::new(),
            canvas_needs_clear: SparseSecondaryMap::new(),
            surface_format,
            width,
            height,
            render_stats: RenderStats::default(),
            render_diagnostics: RenderDiagnostics::default(),
            render_diagnostics_total: RenderDiagnostics::default(),
            light_gpu: None,
            postfx_pipeline: None,
            province_map_pipeline,
            province_map_cache: HashMap::new(),
            postfx_capture: HashMap::new(),
            mesh_cache,
            frame_buffers: FrameRenderBuffers::default(),
            pending_surface_readback: None,
            surface_readback_status: crate::render::gpu_state::SurfaceReadbackStatus::Idle,
            uncaptured_gpu_failure,
        }
    }

    /// Consume an uncaptured-device failure recorded by wgpu without exposing driver text.
    ///
    /// Device recreation is not available from this renderer owner; validation/internal failures
    /// therefore request the app's documented controlled recovery path, while OOM requests stop.
    pub fn take_uncaptured_recovery_action(
        &self,
    ) -> Option<crate::render::RenderRecoveryAction> {
        match self.uncaptured_gpu_failure.swap(0, Ordering::AcqRel) {
            0 => None,
            1 => Some(crate::render::RenderRecoveryAction::Shutdown),
            _ => Some(crate::render::RenderRecoveryAction::RecoverDevice),
        }
    }
    /// Update viewport dimensions after a window resize; recreates stencil targets and clears light GPU state.
    pub fn resize(&mut self, width: u32, height: u32) {
        self.cancel_surface_readback();
        // Fullscreen capture textures are extent-dependent and must not be reused after resize.
        self.postfx_capture.clear();
        self.width = width;
        self.height = height;
        let data = ViewportUniform {
            size: [width as f32, height as f32],
            time: 0.0,
            _pad: 0.0,
            view_col0: [1.0, 0.0, 0.0, 0.0],
            view_col1: [0.0, 1.0, 0.0, 0.0],
            view_col2: [0.0, 0.0, 1.0, 0.0],
        };
        self.queue
            .write_buffer(&self.viewport_buffer, 0, bytemuck::bytes_of(&data));
        self.screen_stencil_target = None;
        self.light_gpu = None;
    }

    fn ensure_province_map_cache(
        &mut self,
        registry_name: &str,
        registry: &crate::province::registry::ProvinceRegistry,
    ) {
        let rebuild_static = self
            .province_map_cache
            .get(registry_name)
            .map(|cache| {
                cache.textures.width != registry.width()
                    || cache.textures.height != registry.height()
            })
            .unwrap_or(true);
        if rebuild_static {
            let cache = ProvinceMapGpuCache::new(
                &self.device,
                &self.queue,
                &self.province_map_pipeline,
                registry,
            );
            self.province_map_cache
                .insert(registry_name.to_string(), cache);
            return;
        }

        if let Some(cache) = self.province_map_cache.get_mut(registry_name) {
            if cache.revision != registry.revision() {
                cache.refresh_dynamic_buffers(
                    &self.device,
                    &self.queue,
                    &self.province_map_pipeline,
                    registry,
                );
            }
        }
    }

    fn draw_province_maps_to_screen(
        &mut self,
        encoder: &mut wgpu::CommandEncoder,
        view: &wgpu::TextureView,
        pending: &[PendingProvinceMapDraw],
        province_registries: &HashMap<String, crate::province::registry::ProvinceRegistry>,
        background_color: [f32; 4],
        screen_started: &mut bool,
    ) {
        for draw in pending {
            let Some(registry) = province_registries.get(&draw.registry_name) else {
                self.render_diagnostics.record_missing_texture();
                continue;
            };
            self.ensure_province_map_cache(&draw.registry_name, registry);
            let color_load = if *screen_started {
                wgpu::LoadOp::Load
            } else {
                wgpu::LoadOp::Clear(wgpu::Color {
                    r: background_color[0] as f64,
                    g: background_color[1] as f64,
                    b: background_color[2] as f64,
                    a: background_color[3] as f64,
                })
            };
            let Some(cache) = self.province_map_cache.get(&draw.registry_name) else {
                continue;
            };
            let terrain_texture = draw
                .terrain_texture
                .and_then(|key| self.gpu_textures.get(key))
                .filter(|_| draw.effects.terrain_texture_strength > 0.0);
            if draw.terrain_texture.is_some() && terrain_texture.is_none() {
                self.render_diagnostics.record_missing_texture();
            }
            let terrain_texture_strength = if draw.effects.terrain_texture_strength > 0.0 {
                draw.effects.terrain_texture_strength
            } else {
                0.0
            };
            let uniforms = ProvinceMapUniforms {
                viewport: draw.viewport,
                map_size: [registry.width() as f32, registry.height() as f32],
                screen_size: draw.screen_size,
                zoom_mode: draw.zoom_mode,
                time: draw.time,
                terrain_texture_scale: draw.effects.terrain_texture_scale,
                terrain_texture_strength,
                fill_tint: draw.tint,
                edge_gradient_color: draw.effects.edge_gradient_color,
                edge_gradient_params: [
                    draw.effects.edge_gradient_radius,
                    draw.effects.edge_gradient_strength,
                    draw.effects.edge_gradient_softness,
                    255.0,
                ],
                province_border_color: draw.effects.province_border_color,
                coast_border_color: draw.effects.coast_border_color,
                country_border_color: draw.effects.country_border_color,
                border_palette_params: [
                    if draw.effects.border_palette_enabled {
                        1.0
                    } else {
                        0.0
                    },
                    draw.effects.sea_border_darken,
                    0.0,
                    0.0,
                ],
                border_noise_params: [
                    draw.effects.border_noise.frequency,
                    if draw.effects.enabled && draw.effects.border_noise.enabled {
                        draw.effects.border_noise.amplitude_px
                    } else {
                        0.0
                    },
                    draw.effects.border_noise.softness_px,
                    if draw.effects.enabled && draw.effects.border_noise.enabled {
                        1.0
                    } else {
                        0.0
                    },
                ],
                water_params: [
                    if draw.effects.enabled && draw.effects.water.enabled {
                        draw.effects.water.strength
                    } else {
                        0.0
                    },
                    draw.effects.water.speed,
                    draw.effects.water.scale,
                    0.0,
                ],
                weather_params: [
                    if draw.effects.enabled && draw.effects.weather.enabled {
                        draw.effects.weather.global_strength
                    } else {
                        0.0
                    },
                    draw.effects.weather.speed,
                    draw.effects.weather.direction[0],
                    draw.effects.weather.direction[1],
                ],
                fog_params: [
                    draw.effects.fog.discovered_desaturation,
                    draw.effects.fog.noise_strength,
                    if draw.effects.enabled && draw.effects.fog.enabled {
                        1.0
                    } else {
                        0.0
                    },
                    0.0,
                ],
                fog_hidden_color: draw.effects.fog.hidden_color,
                climate_params: [
                    draw.effects.climate.tint_strength,
                    draw.effects.climate.season_phase,
                    draw.effects.climate.season_strength,
                    if draw.effects.enabled && draw.effects.climate.enabled {
                        1.0
                    } else {
                        0.0
                    },
                ],
                highlight_ids: [draw.selected_id, draw.hovered_id, 0, 0],
                effect_seeds: [draw.effects.border_noise.seed, 0, 0, 0],
            };
            self.province_map_pipeline
                .update_uniforms(&self.queue, &uniforms);
            let terrain_view = terrain_texture
                .map(|texture| &texture.view)
                .unwrap_or(&self.province_map_pipeline.default_terrain_view);
            let terrain_sampler = &self.province_map_pipeline.default_terrain_sampler;
            let mut transient_province_buffer = None;
            let mut transient_bind_group = None;
            let uses_transient_bind_group =
                province_map_uses_render_tints(draw) || terrain_texture.is_some();
            let data_bind_group = if uses_transient_bind_group {
                let province_records =
                    build_tinted_province_records(registry, &draw.province_tints);
                let province_buffer =
                    self.device
                        .create_buffer_init(&wgpu::util::BufferInitDescriptor {
                            label: Some("province_map_tinted_province_data"),
                            contents: bytemuck::cast_slice(&province_records),
                            usage: wgpu::BufferUsages::STORAGE | wgpu::BufferUsages::COPY_DST,
                        });
                transient_bind_group = Some(self.province_map_pipeline.create_data_bind_group(
                    &self.device,
                    ProvinceMapDataBindings {
                        province_id_view: &cache.textures.province_id_view,
                        border_index_view: &cache.textures.border_index_view,
                        distance_field_view: &cache.textures.distance_field_view,
                        province_data_buffer: &province_buffer,
                        border_style_buffer: &cache.border_style_buffer,
                        terrain_texture_view: terrain_view,
                        terrain_texture_sampler: terrain_sampler,
                    },
                ));
                transient_province_buffer = Some(province_buffer);
                let Some(bind_group) = transient_bind_group.as_ref() else {
                    self.render_diagnostics.record_shader_pipeline_failure();
                    continue;
                };
                bind_group
            } else {
                &cache.data_bind_group
            };
            {
                let mut pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                    label: Some("province_map_pass"),
                    color_attachments: &[Some(wgpu::RenderPassColorAttachment {
                        view,
                        resolve_target: None,
                        ops: wgpu::Operations {
                            load: color_load,
                            store: wgpu::StoreOp::Store,
                        },
                    })],
                    depth_stencil_attachment: None,
                    ..Default::default()
                });
                pass.set_pipeline(&self.province_map_pipeline.pipeline);
                pass.set_bind_group(0, data_bind_group, &[]);
                pass.set_bind_group(1, &self.province_map_pipeline.uniform_bind_group, &[]);
                pass.draw(0..3, 0..1);
            }
            drop(transient_bind_group);
            drop(transient_province_buffer);
            self.render_stats.draw_calls += 1;
            *screen_started = true;
        }
    }
    /// Write the per-frame viewport dimensions, time, and camera matrix to the GPU uniform buffer.
    fn update_viewport_uniform(
        &mut self,
        width: u32,
        height: u32,
        camera_matrix: &Mat3,
        frame_time: f32,
    ) {
        let data = ViewportUniform {
            size: [width as f32, height as f32],
            time: frame_time,
            _pad: 0.0,
            view_col0: [
                camera_matrix.m[0][0],
                camera_matrix.m[1][0],
                camera_matrix.m[2][0],
                0.0,
            ],
            view_col1: [
                camera_matrix.m[0][1],
                camera_matrix.m[1][1],
                camera_matrix.m[2][1],
                0.0,
            ],
            view_col2: [
                camera_matrix.m[0][2],
                camera_matrix.m[1][2],
                camera_matrix.m[2][2],
                0.0,
            ],
        };
        self.queue
            .write_buffer(&self.viewport_buffer, 0, bytemuck::bytes_of(&data));
    }
}
