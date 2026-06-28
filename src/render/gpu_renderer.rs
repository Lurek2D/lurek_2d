//! Owns the main hardware renderer that turns front-end render commands into concrete wgpu draw submission.
//! Manages device, queue, swapchain, canvases, textures, and persistent GPU state under one frame orchestrator.
//! Drives multi-pass flow for scene color, shadows, decals, text, province maps, and post-processing output.
//! Coalesces compatible draw calls so repeated materials and textures do not force unnecessary pipeline churn.
//! Uploads and reuses static geometry to bypass repeated tessellation and reduce CPU-side frame overhead.
//! Supports GPU instancing for repeated sprites, particles, and grid-like content that share one draw shape.
//! Delegates text glyph replay to a focused owner while batching the resulting draw work with the frame.
//! Maintains offscreen canvases as render targets so composite views and multi-surface workflows stay possible.
//! Handles resize, viewport updates, and target-dimension logic that keep swapchain-backed output coherent.
//! Owns readback orchestration for surfaces when screenshots or software-visible capture need GPU results.
//! Bridges lighting, shadows, geometry, and resource owners instead of embedding their detailed policies here.
//! Acts as the runtime boundary between the engine's render command language and low-level wgpu execution.
//! Concentrates helper routines near state so render-frame changes remain auditable despite subsystem breadth.
//! Open this file when full-frame GPU output is wrong and the fault is not isolated to one narrow helper owner.
//! It is the right owner for render orchestration bugs because most GPU passes and resource handoffs converge here.

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
use std::sync::OnceLock;
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
    validate_compound_shape, validate_render_command_with_category, RenderInputLimits,
};
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

struct PendingProvinceMapDraw {
    registry_name: String,
    viewport: [f32; 4],
    screen_size: [f32; 2],
    tint: [f32; 4],
    province_tints: Vec<(u32, [f32; 4])>,
    terrain_texture: Option<TextureKey>,
    terrain_texture_scale: f32,
    terrain_texture_strength: f32,
    edge_gradient_color: [f32; 4],
    edge_gradient_radius: f32,
    edge_gradient_strength: f32,
    edge_gradient_softness: f32,
    border_palette_enabled: bool,
    province_border_color: [f32; 4],
    coast_border_color: [f32; 4],
    country_border_color: [f32; 4],
    sea_border_darken: f32,
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

/// Shadow compute WGSL shader â€” ray-marches edges to build 1-D shadow map rows.
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
            light_gpu: None,
            postfx_pipeline: None,
            province_map_pipeline,
            province_map_cache: HashMap::new(),
            postfx_capture: HashMap::new(),
            mesh_cache,
            frame_buffers: FrameRenderBuffers::default(),
        }
    }
    /// Update viewport dimensions after a window resize; recreates stencil targets and clears light GPU state.
    pub fn resize(&mut self, width: u32, height: u32) {
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
                .filter(|_| draw.terrain_texture_strength > 0.0);
            if draw.terrain_texture.is_some() && terrain_texture.is_none() {
                self.render_diagnostics.record_missing_texture();
            }
            let terrain_texture_strength = if draw.terrain_texture_strength > 0.0 {
                draw.terrain_texture_strength
            } else {
                0.0
            };
            let uniforms = ProvinceMapUniforms {
                viewport: draw.viewport,
                map_size: [registry.width() as f32, registry.height() as f32],
                screen_size: draw.screen_size,
                zoom_mode: draw.zoom_mode,
                time: draw.time,
                terrain_texture_scale: draw.terrain_texture_scale,
                terrain_texture_strength,
                fill_tint: draw.tint,
                edge_gradient_color: draw.edge_gradient_color,
                edge_gradient_params: [
                    draw.edge_gradient_radius,
                    draw.edge_gradient_strength,
                    draw.edge_gradient_softness,
                    255.0,
                ],
                province_border_color: draw.province_border_color,
                coast_border_color: draw.coast_border_color,
                country_border_color: draw.country_border_color,
                border_palette_params: [
                    if draw.border_palette_enabled {
                        1.0
                    } else {
                        0.0
                    },
                    draw.sea_border_darken,
                    0.0,
                    0.0,
                ],
                highlight_ids: [draw.selected_id, draw.hovered_id, 0, 0],
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
                transient_bind_group.as_ref().unwrap()
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
    /// Renders a full frame of deferred draw commands to the surface swapchain texture.
    #[allow(clippy::too_many_arguments)]
    pub fn render_frame(
        &mut self,
        surface: &wgpu::Surface<'static>,
        commands: &[RenderCommand],
        province_registries: &HashMap<String, crate::province::registry::ProvinceRegistry>,
        textures: &SlotMap<TextureKey, TextureData>,
        fonts: &mut SlotMap<FontKey, crate::font::Font>,
        light_world: &crate::light::light_world::LightWorld,
        sprite_batches: &SlotMap<SpriteBatchKey, crate::sprite::SpriteBatch>,
        shapes: &SlotMap<ShapeKey, crate::render::CompoundShape>,
        canvases: &SlotMap<CanvasKey, crate::render::Canvas>,
        meshes: &SlotMap<MeshKey, Mesh>,
        shaders: &SlotMap<ShaderKey, Shader>,
        default_filter: &(String, String, u32),
        background_color: [f32; 4],
        camera_matrix: &Mat3,
        frame_time: f32,
        frame_count: u64,
        capture_screenshot: bool,
    ) -> Result<Option<(u32, u32, Vec<u8>)>, wgpu::SurfaceError> {
        let frame_start = Instant::now();
        self.render_diagnostics.reset();
        self.prune_released_resources(textures, fonts, canvases, shaders, meshes);
        for (key, tex_data) in textures.iter() {
            let existing = self
                .gpu_textures
                .get(key)
                .map(|texture| (texture.width, texture.height, texture.source_revision));
            if texture_needs_upload(existing, tex_data) {
                if let Err(err) = self.upload_texture(key, tex_data, default_filter) {
                    self.render_diagnostics.record_invalid_texture_upload();
                    log::warn!("Skipping invalid texture upload for {:?}: {}", key, err);
                }
            }
        }
        self.sync_canvas_targets(canvases, default_filter);
        self.render_stats = RenderStats::default();
        let mut frame_buffers = std::mem::take(&mut self.frame_buffers);
        frame_buffers.clear_for_frame();
        let FrameRenderBuffers {
            color_verts: mut all_color_verts,
            color_idxs: mut all_color_idxs,
            tex_verts: mut all_tex_verts,
            tex_idxs: mut all_tex_idxs,
            particle_verts: mut all_particle_verts,
            particle_idxs: mut all_particle_idxs,
            mut draws,
            instances: mut frame_instances,
            scratch_color_verts,
            scratch_color_idxs,
            mut scratch_tex_verts,
            mut scratch_tex_idxs,
            mut merged_draws,
        } = frame_buffers;
        let mut current_target = RenderTargetId::Screen;
        let mut current_blend_mode = BlendMode::Alpha;
        let mut current_scissor: Option<(f32, f32, f32, f32)> = None;
        let mut current_color = [1.0f32, 1.0, 1.0, 1.0];
        let mut color_mask_bits = color_write_mask_bits((true, true, true, true));
        let mut wireframe = false;
        let mut line_width = 1.0f32;
        let mut point_size = 1.0f32;
        let mut transform_stack: Vec<Mat3> = vec![Mat3::identity()];
        let mut stencil_mode = GpuStencilMode::Disabled;
        let mut stencil_reference = 0u8;
        let mut active_shader: Option<ShaderKey> = None;
        let render_input_limits = RenderInputLimits::default();
        let mut pending_postfx: Vec<(u64, Vec<crate::render::renderer::PostFxPass>, u32, u32)> =
            Vec::new();
        let mut pending_province_maps: Vec<PendingProvinceMapDraw> = Vec::new();
        for cmd in commands {
            if let Err(err) = validate_render_command_with_category(cmd, &render_input_limits) {
                self.render_diagnostics.record_invalid_render_input();
                log::warn!("Skipping invalid render command: {}", err);
                continue;
            }
            match cmd {
                RenderCommand::DrawStaticGeometry {
                    geometry_key,
                    x,
                    y,
                    rotation,
                    sx,
                    sy,
                } => {
                    if let Some(geom) = self.mesh_cache.static_geometry.get(geometry_key) {
                        let parent = transform_stack_last(&transform_stack);
                        let local = Mat3::from_translation(Vec2 { x: *x, y: *y })
                            * Mat3::from_rotation(*rotation)
                            * Mat3::from_scale(Vec2 { x: *sx, y: *sy });
                        let model = *parent * local;
                        let instance = crate::render::gpu_types::InstanceData::from(model);

                        let inst_offset = frame_instances.len() as u32;
                        frame_instances.push(instance);

                        let (target_width, target_height) =
                            self.target_dimensions(current_target, canvases);

                        draws.push(PreparedDraw {
                            target: current_target,
                            geometry: geom.geometry_kind,
                            texture_ref: geom
                                .texture
                                .map(crate::render::gpu_types::TexRef::Texture),
                            idx_start: 0,
                            idx_count: geom.index_count,
                            blend_mode: current_blend_mode,
                            scissor: normalize_scissor(
                                current_scissor,
                                target_width,
                                target_height,
                            ),
                            color_mask_bits,
                            shader: active_shader.filter(|key| shaders.contains_key(*key)),
                            stencil_mode,
                            stencil_reference: stencil_reference as u32,
                            static_geometry: Some(*geometry_key),
                            instance_buffer: None,
                            instance_start: inst_offset,
                            instance_count: 1,
                        });
                    } else {
                        self.render_diagnostics.record_missing_static_geometry();
                    }
                }
                RenderCommand::InstancedDraw {
                    geometry_kind,
                    instances,
                } => {
                    let inst_buf_entry = self.mesh_cache.instance_buffers.get(instances);
                    if let Some(inst_entry) = inst_buf_entry {
                        let (geom_kind, static_geom_key, idx_count, tex_ref) = match geometry_kind {
                            DrawableKind::Mesh(mesh_key) => {
                                let static_key = StaticGeometryKey::from(mesh_key.data());
                                if let Some(geom) = self.mesh_cache.static_geometry.get(&static_key)
                                {
                                    (
                                        geom.geometry_kind,
                                        Some(static_key),
                                        geom.index_count,
                                        geom.texture.map(crate::render::gpu_types::TexRef::Texture),
                                    )
                                } else {
                                    self.render_diagnostics.record_missing_mesh();
                                    continue;
                                }
                            }
                            DrawableKind::Image(texture_key) => (
                                GeometryKind::TextureInstanced,
                                Some(StaticGeometryKey::default()),
                                6,
                                Some(crate::render::gpu_types::TexRef::Texture(*texture_key)),
                            ),
                            DrawableKind::Canvas(canvas_key) => (
                                GeometryKind::TextureInstanced,
                                Some(StaticGeometryKey::default()),
                                6,
                                Some(crate::render::gpu_types::TexRef::Canvas(*canvas_key)),
                            ),
                            DrawableKind::SpriteBatch(_) => {
                                self.render_diagnostics
                                    .record_unsupported_instanced_sprite_batch();
                                continue;
                            }
                        };

                        let (target_width, target_height) =
                            self.target_dimensions(current_target, canvases);

                        draws.push(PreparedDraw {
                            target: current_target,
                            geometry: geom_kind,
                            texture_ref: tex_ref,
                            idx_start: 0,
                            idx_count,
                            blend_mode: current_blend_mode,
                            scissor: normalize_scissor(
                                current_scissor,
                                target_width,
                                target_height,
                            ),
                            color_mask_bits,
                            shader: active_shader.filter(|key| shaders.contains_key(*key)),
                            stencil_mode,
                            stencil_reference: stencil_reference as u32,
                            static_geometry: static_geom_key,
                            instance_buffer: Some(*instances),
                            instance_start: 0,
                            instance_count: inst_entry.count,
                        });
                    } else {
                        self.render_diagnostics.record_missing_instance_buffer();
                    }
                }
                RenderCommand::SetColor(r, g, b, a) => {
                    current_color = [*r, *g, *b, *a];
                }
                RenderCommand::SetLineWidth(w) => {
                    line_width = *w;
                }
                RenderCommand::PushTransform => {
                    let top = *transform_stack_last(&transform_stack);
                    transform_stack.push(top);
                }
                RenderCommand::PopTransform => {
                    if transform_stack.len() > 1 {
                        transform_stack.pop();
                    }
                }
                RenderCommand::Translate { x, y } => {
                    let m = Mat3::from_translation(Vec2 { x: *x, y: *y });
                    let top = transform_stack_last_mut(&mut transform_stack);
                    *top = *top * m;
                }
                RenderCommand::Rotate { angle } => {
                    let m = Mat3::from_rotation(*angle);
                    let top = transform_stack_last_mut(&mut transform_stack);
                    *top = *top * m;
                }
                RenderCommand::Scale { sx, sy } => {
                    let m = Mat3::from_scale(Vec2 { x: *sx, y: *sy });
                    let top = transform_stack_last_mut(&mut transform_stack);
                    *top = *top * m;
                }
                RenderCommand::Shear { kx, ky } => {
                    let m = Mat3::from_shear(*kx, *ky);
                    let top = transform_stack_last_mut(&mut transform_stack);
                    *top = *top * m;
                }
                RenderCommand::Origin => {
                    let top = transform_stack_last_mut(&mut transform_stack);
                    *top = Mat3::identity();
                }
                RenderCommand::ApplyTransform { matrix } => {
                    let m = Mat3::from_row_major(matrix);
                    let top = transform_stack_last_mut(&mut transform_stack);
                    *top = *top * m;
                }
                RenderCommand::Rectangle { mode, x, y, w, h } => {
                    let mode = if wireframe { &DrawMode::Line } else { mode };
                    let t = transform_stack_last(&transform_stack);
                    if current_target == RenderTargetId::Screen
                        && !Self::aabb_visible_2d(
                            *x,
                            *y,
                            *w,
                            *h,
                            t,
                            camera_matrix,
                            self.width as f32,
                            self.height as f32,
                        )
                    {
                        continue;
                    }
                    let idx_start = all_color_idxs.len();
                    self.tess_rect(
                        &mut all_color_verts,
                        &mut all_color_idxs,
                        t,
                        current_color,
                        mode,
                        *x,
                        *y,
                        *w,
                        *h,
                        line_width,
                    );
                    let idx_end = all_color_idxs.len();
                    let (target_width, target_height) =
                        self.target_dimensions(current_target, canvases);
                    append_color_draw_range(
                        &mut draws,
                        idx_start,
                        idx_end,
                        current_target,
                        current_blend_mode,
                        normalize_scissor(current_scissor, target_width, target_height),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                    );
                }
                RenderCommand::RoundedRectangle {
                    mode,
                    x,
                    y,
                    w,
                    h,
                    rx,
                    ry,
                } => {
                    let mode = if wireframe { &DrawMode::Line } else { mode };
                    let t = transform_stack_last(&transform_stack);
                    if current_target == RenderTargetId::Screen
                        && !Self::aabb_visible_2d(
                            *x,
                            *y,
                            *w,
                            *h,
                            t,
                            camera_matrix,
                            self.width as f32,
                            self.height as f32,
                        )
                    {
                        continue;
                    }
                    let idx_start = all_color_idxs.len();
                    self.tess_rounded_rect(
                        &mut all_color_verts,
                        &mut all_color_idxs,
                        t,
                        current_color,
                        mode,
                        *x,
                        *y,
                        *w,
                        *h,
                        *rx,
                        *ry,
                        line_width,
                    );
                    let idx_end = all_color_idxs.len();
                    let (target_width, target_height) =
                        self.target_dimensions(current_target, canvases);
                    append_color_draw_range(
                        &mut draws,
                        idx_start,
                        idx_end,
                        current_target,
                        current_blend_mode,
                        normalize_scissor(current_scissor, target_width, target_height),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                    );
                }
                RenderCommand::Circle { mode, x, y, r } => {
                    let mode = if wireframe { &DrawMode::Line } else { mode };
                    let t = transform_stack_last(&transform_stack);
                    if current_target == RenderTargetId::Screen
                        && !Self::aabb_visible_2d(
                            x - r,
                            y - r,
                            r * 2.0,
                            r * 2.0,
                            t,
                            camera_matrix,
                            self.width as f32,
                            self.height as f32,
                        )
                    {
                        continue;
                    }
                    let segments = adaptive_circle_ellipse_segments(*r, *r);
                    let idx_start = all_color_idxs.len();
                    self.tess_ellipse(
                        &mut all_color_verts,
                        &mut all_color_idxs,
                        t,
                        current_color,
                        mode,
                        *x,
                        *y,
                        *r,
                        *r,
                        segments,
                        line_width,
                    );
                    let idx_end = all_color_idxs.len();
                    let (target_width, target_height) =
                        self.target_dimensions(current_target, canvases);
                    append_color_draw_range(
                        &mut draws,
                        idx_start,
                        idx_end,
                        current_target,
                        current_blend_mode,
                        normalize_scissor(current_scissor, target_width, target_height),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                    );
                }
                RenderCommand::Ellipse { mode, x, y, rx, ry } => {
                    let mode = if wireframe { &DrawMode::Line } else { mode };
                    let t = transform_stack_last(&transform_stack);
                    if current_target == RenderTargetId::Screen
                        && !Self::aabb_visible_2d(
                            x - rx,
                            y - ry,
                            rx * 2.0,
                            ry * 2.0,
                            t,
                            camera_matrix,
                            self.width as f32,
                            self.height as f32,
                        )
                    {
                        continue;
                    }
                    let segments = adaptive_circle_ellipse_segments(*rx, *ry);
                    let idx_start = all_color_idxs.len();
                    self.tess_ellipse(
                        &mut all_color_verts,
                        &mut all_color_idxs,
                        t,
                        current_color,
                        mode,
                        *x,
                        *y,
                        *rx,
                        *ry,
                        segments,
                        line_width,
                    );
                    let idx_end = all_color_idxs.len();
                    let (target_width, target_height) =
                        self.target_dimensions(current_target, canvases);
                    append_color_draw_range(
                        &mut draws,
                        idx_start,
                        idx_end,
                        current_target,
                        current_blend_mode,
                        normalize_scissor(current_scissor, target_width, target_height),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                    );
                }
                RenderCommand::Triangle {
                    mode,
                    x1,
                    y1,
                    x2,
                    y2,
                    x3,
                    y3,
                } => {
                    let mode = if wireframe { &DrawMode::Line } else { mode };
                    let t = transform_stack_last(&transform_stack);
                    let idx_start = all_color_idxs.len();
                    self.tess_triangle(
                        &mut all_color_verts,
                        &mut all_color_idxs,
                        t,
                        current_color,
                        mode,
                        *x1,
                        *y1,
                        *x2,
                        *y2,
                        *x3,
                        *y3,
                        line_width,
                    );
                    let idx_end = all_color_idxs.len();
                    let (target_width, target_height) =
                        self.target_dimensions(current_target, canvases);
                    append_color_draw_range(
                        &mut draws,
                        idx_start,
                        idx_end,
                        current_target,
                        current_blend_mode,
                        normalize_scissor(current_scissor, target_width, target_height),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                    );
                }
                RenderCommand::Polygon { mode, vertices } => {
                    let mode = if wireframe { &DrawMode::Line } else { mode };
                    let t = transform_stack_last(&transform_stack);
                    let idx_start = all_color_idxs.len();
                    self.tess_polygon(
                        &mut all_color_verts,
                        &mut all_color_idxs,
                        t,
                        current_color,
                        mode,
                        vertices,
                        line_width,
                    );
                    let idx_end = all_color_idxs.len();
                    let (target_width, target_height) =
                        self.target_dimensions(current_target, canvases);
                    append_color_draw_range(
                        &mut draws,
                        idx_start,
                        idx_end,
                        current_target,
                        current_blend_mode,
                        normalize_scissor(current_scissor, target_width, target_height),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                    );
                }
                RenderCommand::Line { x1, y1, x2, y2 } => {
                    let t = transform_stack_last(&transform_stack);
                    let idx_start = all_color_idxs.len();
                    push_thick_line(
                        &mut all_color_verts,
                        &mut all_color_idxs,
                        t,
                        current_color,
                        *x1,
                        *y1,
                        *x2,
                        *y2,
                        line_width,
                    );
                    let idx_end = all_color_idxs.len();
                    let (target_width, target_height) =
                        self.target_dimensions(current_target, canvases);
                    append_color_draw_range(
                        &mut draws,
                        idx_start,
                        idx_end,
                        current_target,
                        current_blend_mode,
                        normalize_scissor(current_scissor, target_width, target_height),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                    );
                }
                RenderCommand::Polyline { points } => {
                    if points.len() >= 4 {
                        let t = transform_stack_last(&transform_stack);
                        let idx_start = all_color_idxs.len();
                        let mut i = 0;
                        while i + 3 < points.len() {
                            push_thick_line(
                                &mut all_color_verts,
                                &mut all_color_idxs,
                                t,
                                current_color,
                                points[i],
                                points[i + 1],
                                points[i + 2],
                                points[i + 3],
                                line_width,
                            );
                            i += 2;
                        }
                        let idx_end = all_color_idxs.len();
                        let (target_width, target_height) =
                            self.target_dimensions(current_target, canvases);
                        append_color_draw_range(
                            &mut draws,
                            idx_start,
                            idx_end,
                            current_target,
                            current_blend_mode,
                            normalize_scissor(current_scissor, target_width, target_height),
                            color_mask_bits,
                            active_shader.filter(|key| shaders.contains_key(*key)),
                            stencil_mode,
                            stencil_reference,
                        );
                    }
                }
                RenderCommand::Arc {
                    mode,
                    x,
                    y,
                    radius,
                    angle1,
                    angle2,
                    segments,
                } => {
                    let t = transform_stack_last(&transform_stack);
                    let segs = if *segments == 0 { 32 } else { *segments };
                    let mode = if wireframe { &DrawMode::Line } else { mode };
                    let idx_start = all_color_idxs.len();
                    self.tess_arc(
                        &mut all_color_verts,
                        &mut all_color_idxs,
                        t,
                        current_color,
                        mode,
                        *x,
                        *y,
                        *radius,
                        *angle1,
                        *angle2,
                        segs,
                        line_width,
                    );
                    let idx_end = all_color_idxs.len();
                    let (target_width, target_height) =
                        self.target_dimensions(current_target, canvases);
                    append_color_draw_range(
                        &mut draws,
                        idx_start,
                        idx_end,
                        current_target,
                        current_blend_mode,
                        normalize_scissor(current_scissor, target_width, target_height),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                    );
                }
                RenderCommand::SetBlendMode(mode) => {
                    current_blend_mode = *mode;
                }
                RenderCommand::Print {
                    font_key,
                    ref text,
                    x,
                    y,
                    scale,
                } => {
                    let t = transform_stack_last(&transform_stack);
                    self.replay_plain_text(
                        *font_key,
                        text,
                        *x,
                        *y,
                        *scale,
                        current_color,
                        t,
                        current_target,
                        current_blend_mode,
                        current_scissor,
                        color_mask_bits,
                        active_shader,
                        stencil_mode,
                        stencil_reference,
                        canvases,
                        shaders,
                        fonts,
                        default_filter,
                        &mut all_tex_verts,
                        &mut all_tex_idxs,
                        &mut scratch_tex_verts,
                        &mut scratch_tex_idxs,
                        &mut draws,
                    );
                }
                RenderCommand::PrintTransformed {
                    font_key,
                    ref text,
                    x,
                    y,
                    rotation,
                    sx,
                    sy,
                    ox,
                    oy,
                    scale,
                } => {
                    let t = transformed_draw_matrix(
                        transform_stack_last(&transform_stack),
                        GpuDrawTransform {
                            x: *x,
                            y: *y,
                            rotation: *rotation,
                            sx: *sx,
                            sy: *sy,
                            ox: *ox,
                            oy: *oy,
                        },
                    );
                    self.replay_plain_text(
                        *font_key,
                        text,
                        0.0,
                        0.0,
                        *scale,
                        current_color,
                        &t,
                        current_target,
                        current_blend_mode,
                        current_scissor,
                        color_mask_bits,
                        active_shader,
                        stencil_mode,
                        stencil_reference,
                        canvases,
                        shaders,
                        fonts,
                        default_filter,
                        &mut all_tex_verts,
                        &mut all_tex_idxs,
                        &mut scratch_tex_verts,
                        &mut scratch_tex_idxs,
                        &mut draws,
                    );
                }
                RenderCommand::DrawImage {
                    texture_key,
                    x,
                    y,
                    effect: _,
                } => {
                    let Some(gt) = self.gpu_textures.get(*texture_key) else {
                        self.render_diagnostics.record_missing_texture();
                        continue;
                    };
                    let w = gt.width as f32;
                    let h = gt.height as f32;
                    let t = transform_stack_last(&transform_stack);
                    if current_target == RenderTargetId::Screen
                        && !Self::aabb_visible_2d(
                            *x,
                            *y,
                            w,
                            h,
                            t,
                            camera_matrix,
                            self.width as f32,
                            self.height as f32,
                        )
                    {
                        continue;
                    }
                    scratch_tex_verts.clear();
                    scratch_tex_idxs.clear();
                    push_tex_quad(
                        &mut scratch_tex_verts,
                        &mut scratch_tex_idxs,
                        t,
                        current_color,
                        *x,
                        *y,
                        0.0,
                        1.0,
                        1.0,
                        0.0,
                        0.0,
                        w,
                        h,
                        0.0,
                        0.0,
                        1.0,
                        1.0,
                    );
                    let (target_width, target_height) =
                        self.target_dimensions(current_target, canvases);
                    append_tex_draw_slices(
                        &mut draws,
                        &mut all_tex_verts,
                        &mut all_tex_idxs,
                        current_target,
                        TexRef::Texture(*texture_key),
                        current_blend_mode,
                        normalize_scissor(current_scissor, target_width, target_height),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                        &scratch_tex_verts,
                        &scratch_tex_idxs,
                    );
                }
                RenderCommand::DrawImageEx {
                    texture_key,
                    x,
                    y,
                    rotation,
                    sx,
                    sy,
                    ox,
                    oy,
                    effect: _,
                } => {
                    let Some(gt) = self.gpu_textures.get(*texture_key) else {
                        self.render_diagnostics.record_missing_texture();
                        continue;
                    };
                    let w = gt.width as f32;
                    let h = gt.height as f32;
                    let t = transform_stack_last(&transform_stack);
                    if current_target == RenderTargetId::Screen
                        && !Self::aabb_visible_2d(
                            *x - *ox * sx.abs(),
                            *y - *oy * sy.abs(),
                            w * sx.abs(),
                            h * sy.abs(),
                            t,
                            camera_matrix,
                            self.width as f32,
                            self.height as f32,
                        )
                    {
                        continue;
                    }
                    scratch_tex_verts.clear();
                    scratch_tex_idxs.clear();
                    push_tex_quad(
                        &mut scratch_tex_verts,
                        &mut scratch_tex_idxs,
                        t,
                        current_color,
                        *x,
                        *y,
                        *rotation,
                        *sx,
                        *sy,
                        *ox,
                        *oy,
                        w,
                        h,
                        0.0,
                        0.0,
                        1.0,
                        1.0,
                    );
                    let (target_width, target_height) =
                        self.target_dimensions(current_target, canvases);
                    append_tex_draw_slices(
                        &mut draws,
                        &mut all_tex_verts,
                        &mut all_tex_idxs,
                        current_target,
                        TexRef::Texture(*texture_key),
                        current_blend_mode,
                        normalize_scissor(current_scissor, target_width, target_height),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                        &scratch_tex_verts,
                        &scratch_tex_idxs,
                    );
                }
                RenderCommand::DrawQuad {
                    texture_key,
                    quad_x,
                    quad_y,
                    quad_w,
                    quad_h,
                    tex_w,
                    tex_h,
                    x,
                    y,
                    rotation,
                    sx,
                    sy,
                    ox,
                    oy,
                    effect: _,
                } => {
                    if !self.gpu_textures.contains_key(*texture_key) {
                        self.render_diagnostics.record_missing_texture();
                        continue;
                    }
                    let t = transform_stack_last(&transform_stack);
                    scratch_tex_verts.clear();
                    scratch_tex_idxs.clear();
                    let u0 = quad_x / tex_w;
                    let v0 = quad_y / tex_h;
                    let u1 = (quad_x + quad_w) / tex_w;
                    let v1 = (quad_y + quad_h) / tex_h;
                    push_tex_quad(
                        &mut scratch_tex_verts,
                        &mut scratch_tex_idxs,
                        t,
                        current_color,
                        *x,
                        *y,
                        *rotation,
                        *sx,
                        *sy,
                        *ox,
                        *oy,
                        *quad_w,
                        *quad_h,
                        u0,
                        v0,
                        u1,
                        v1,
                    );
                    let (target_width, target_height) =
                        self.target_dimensions(current_target, canvases);
                    append_tex_draw_slices(
                        &mut draws,
                        &mut all_tex_verts,
                        &mut all_tex_idxs,
                        current_target,
                        TexRef::Texture(*texture_key),
                        current_blend_mode,
                        normalize_scissor(current_scissor, target_width, target_height),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                        &scratch_tex_verts,
                        &scratch_tex_idxs,
                    );
                }
                RenderCommand::DrawTexturedQuad {
                    corners,
                    uvs,
                    corner_w,
                    texture_key,
                    color,
                } => {
                    if !self.gpu_textures.contains_key(*texture_key) {
                        self.render_diagnostics.record_missing_texture();
                        continue;
                    }
                    let t = transform_stack_last(&transform_stack);
                    scratch_tex_verts.clear();
                    scratch_tex_idxs.clear();
                    push_tex_quad_corners(
                        &mut scratch_tex_verts,
                        &mut scratch_tex_idxs,
                        t,
                        *color,
                        corners,
                        uvs,
                        corner_w,
                    );
                    let (target_width, target_height) =
                        self.target_dimensions(current_target, canvases);
                    append_tex_draw_slices(
                        &mut draws,
                        &mut all_tex_verts,
                        &mut all_tex_idxs,
                        current_target,
                        TexRef::Texture(*texture_key),
                        current_blend_mode,
                        normalize_scissor(current_scissor, target_width, target_height),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                        &scratch_tex_verts,
                        &scratch_tex_idxs,
                    );
                }
                RenderCommand::DrawBatch { batch_key } => {
                    if let Some(batch) = sprite_batches.get(*batch_key) {
                        let tex_key = batch.texture_key();
                        let Some(gt) = self.gpu_textures.get(tex_key) else {
                            self.render_diagnostics.record_missing_texture();
                            continue;
                        };
                        let tex_w = gt.width as f32;
                        let tex_h = gt.height as f32;
                        let t = transform_stack_last(&transform_stack);
                        scratch_tex_verts.clear();
                        scratch_tex_idxs.clear();
                        scratch_tex_verts.reserve(batch.len() * 4);
                        scratch_tex_idxs.reserve(batch.len() * 6);
                        for entry in batch.entries() {
                            let qw = if entry.quad_w > 0.0 {
                                entry.quad_w
                            } else {
                                tex_w
                            };
                            let qh = if entry.quad_h > 0.0 {
                                entry.quad_h
                            } else {
                                tex_h
                            };
                            let u0 = entry.quad_x / tex_w;
                            let v0 = entry.quad_y / tex_h;
                            let u1 = (entry.quad_x + qw) / tex_w;
                            let v1 = (entry.quad_y + qh) / tex_h;
                            if current_target == RenderTargetId::Screen
                                && !Self::aabb_visible_2d(
                                    entry.x - entry.ox * entry.sx.abs(),
                                    entry.y - entry.oy * entry.sy.abs(),
                                    qw * entry.sx.abs(),
                                    qh * entry.sy.abs(),
                                    t,
                                    camera_matrix,
                                    self.width as f32,
                                    self.height as f32,
                                )
                            {
                                continue;
                            }
                            push_tex_quad(
                                &mut scratch_tex_verts,
                                &mut scratch_tex_idxs,
                                t,
                                current_color,
                                entry.x,
                                entry.y,
                                entry.rotation,
                                entry.sx,
                                entry.sy,
                                entry.ox,
                                entry.oy,
                                qw,
                                qh,
                                u0,
                                v0,
                                u1,
                                v1,
                            );
                        }
                        let (target_width, target_height) =
                            self.target_dimensions(current_target, canvases);
                        append_tex_draw_slices(
                            &mut draws,
                            &mut all_tex_verts,
                            &mut all_tex_idxs,
                            current_target,
                            TexRef::Texture(tex_key),
                            current_blend_mode,
                            normalize_scissor(current_scissor, target_width, target_height),
                            color_mask_bits,
                            active_shader.filter(|key| shaders.contains_key(*key)),
                            stencil_mode,
                            stencil_reference,
                            &scratch_tex_verts,
                            &scratch_tex_idxs,
                        );
                    }
                }
                RenderCommand::SetCanvas(canvas) => {
                    current_target = match canvas {
                        Some(key) => RenderTargetId::Canvas(*key),
                        None => RenderTargetId::Screen,
                    };
                    self.render_stats.canvas_switches += 1;
                }
                RenderCommand::RegisterCanvas { .. } => {}
                RenderCommand::ResetCanvas(key) => {
                    self.canvas_needs_clear.insert(*key, true);
                }
                RenderCommand::DrawCanvas {
                    canvas_key,
                    x,
                    y,
                    rotation,
                    sx,
                    sy,
                    ox,
                    oy,
                } => {
                    let Some(gt) = self.canvas_gpu_textures.get(*canvas_key) else {
                        self.render_diagnostics.record_missing_canvas();
                        continue;
                    };
                    let w = gt.width as f32;
                    let h = gt.height as f32;
                    let t = transform_stack_last(&transform_stack);
                    scratch_tex_verts.clear();
                    scratch_tex_idxs.clear();
                    push_tex_quad(
                        &mut scratch_tex_verts,
                        &mut scratch_tex_idxs,
                        t,
                        current_color,
                        *x,
                        *y,
                        *rotation,
                        *sx,
                        *sy,
                        *ox,
                        *oy,
                        w,
                        h,
                        0.0,
                        0.0,
                        1.0,
                        1.0,
                    );
                    let (target_width, target_height) =
                        self.target_dimensions(current_target, canvases);
                    append_tex_draw_slices(
                        &mut draws,
                        &mut all_tex_verts,
                        &mut all_tex_idxs,
                        current_target,
                        TexRef::Canvas(*canvas_key),
                        current_blend_mode,
                        normalize_scissor(current_scissor, target_width, target_height),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                        &scratch_tex_verts,
                        &scratch_tex_idxs,
                    );
                }
                RenderCommand::SetPointSize(size) => {
                    point_size = *size;
                }
                RenderCommand::SetScissor(rect) => {
                    current_scissor = *rect;
                }
                RenderCommand::SetColorMask(r, g, b, a) => {
                    color_mask_bits = color_write_mask_bits((*r, *g, *b, *a));
                }
                RenderCommand::SetWireframe(enabled) => {
                    wireframe = *enabled;
                }
                RenderCommand::Points { points } => {
                    let t = transform_stack_last(&transform_stack);
                    let idx_start = all_color_idxs.len();
                    let half = point_size * 0.5;
                    for &(px, py) in points {
                        let pts = [
                            apply(t, px - half, py - half),
                            apply(t, px + half, py - half),
                            apply(t, px + half, py + half),
                            apply(t, px - half, py + half),
                        ];
                        push_quad_verts(
                            &mut all_color_verts,
                            &mut all_color_idxs,
                            &pts,
                            current_color,
                        );
                    }
                    let idx_end = all_color_idxs.len();
                    let (target_width, target_height) =
                        self.target_dimensions(current_target, canvases);
                    append_color_draw_range(
                        &mut draws,
                        idx_start,
                        idx_end,
                        current_target,
                        current_blend_mode,
                        normalize_scissor(current_scissor, target_width, target_height),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                    );
                }
                RenderCommand::PrintFormatted {
                    font_key,
                    ref text,
                    x,
                    y,
                    limit,
                    align,
                    scale,
                } => {
                    let t = transform_stack_last(&transform_stack);
                    self.replay_formatted_text(
                        *font_key,
                        text,
                        *x,
                        *y,
                        *limit,
                        *align,
                        *scale,
                        current_color,
                        t,
                        current_target,
                        current_blend_mode,
                        current_scissor,
                        color_mask_bits,
                        active_shader,
                        stencil_mode,
                        stencil_reference,
                        canvases,
                        shaders,
                        fonts,
                        default_filter,
                        &mut all_tex_verts,
                        &mut all_tex_idxs,
                        &mut scratch_tex_verts,
                        &mut scratch_tex_idxs,
                        &mut draws,
                    );
                }
                RenderCommand::StencilBegin { action, value } => {
                    stencil_mode = GpuStencilMode::Write(*action);
                    stencil_reference = *value;
                }
                RenderCommand::StencilEnd => {
                    stencil_mode = GpuStencilMode::Disabled;
                }
                RenderCommand::SetStencilTest(test) => match test {
                    Some((compare, value)) => {
                        stencil_mode = GpuStencilMode::Test(*compare);
                        stencil_reference = *value;
                    }
                    None => {
                        stencil_mode = GpuStencilMode::Disabled;
                        stencil_reference = 0;
                    }
                },
                RenderCommand::DrawMesh {
                    mesh_key,
                    x,
                    y,
                    rotation,
                    sx,
                    sy,
                    ox,
                    oy,
                } => {
                    if let Some(mesh) = meshes.get(*mesh_key) {
                        let cos_r = rotation.cos();
                        let sin_r = rotation.sin();
                        let parent = transform_stack_last(&transform_stack);
                        let tri_indices = mesh.triangulate();
                        if let Some(tex_key) = mesh.texture {
                            if self.gpu_textures.contains_key(tex_key) {
                                scratch_tex_verts.clear();
                                scratch_tex_idxs.clear();
                                scratch_tex_verts.reserve(tri_indices.len());
                                scratch_tex_idxs.reserve(tri_indices.len());
                                let base_idx = 0u32;
                                for (i, &vi) in tri_indices.iter().enumerate() {
                                    if let Some(mv) = mesh.vertices.get(vi) {
                                        let lx = (mv.x - ox) * sx;
                                        let ly = (mv.y - oy) * sy;
                                        let rx = lx * cos_r - ly * sin_r + x;
                                        let ry = lx * sin_r + ly * cos_r + y;
                                        let (wx, wy) = apply(parent, rx, ry);
                                        scratch_tex_verts.push(TexVertex {
                                            position: [wx, wy],
                                            uv: [mv.u, mv.v],
                                            color: [
                                                mv.r * current_color[0],
                                                mv.g * current_color[1],
                                                mv.b * current_color[2],
                                                mv.a * current_color[3],
                                            ],
                                            w_depth: 1.0,
                                            _pad: [0.0; 3],
                                        });
                                        scratch_tex_idxs.push(base_idx + i as u32);
                                    }
                                }
                                let (target_width, target_height) =
                                    self.target_dimensions(current_target, canvases);
                                append_tex_draw_slices(
                                    &mut draws,
                                    &mut all_tex_verts,
                                    &mut all_tex_idxs,
                                    current_target,
                                    TexRef::Texture(tex_key),
                                    current_blend_mode,
                                    normalize_scissor(current_scissor, target_width, target_height),
                                    color_mask_bits,
                                    active_shader.filter(|key| shaders.contains_key(*key)),
                                    stencil_mode,
                                    stencil_reference,
                                    &scratch_tex_verts,
                                    &scratch_tex_idxs,
                                );
                            }
                        } else {
                            let idx_start = all_color_idxs.len();
                            all_color_verts.reserve(tri_indices.len());
                            all_color_idxs.reserve(tri_indices.len());
                            for &vi in &tri_indices {
                                if let Some(mv) = mesh.vertices.get(vi) {
                                    let lx = (mv.x - ox) * sx;
                                    let ly = (mv.y - oy) * sy;
                                    let rx = lx * cos_r - ly * sin_r + x;
                                    let ry = lx * sin_r + ly * cos_r + y;
                                    let (wx, wy) = apply(parent, rx, ry);
                                    let base = all_color_verts.len() as u32;
                                    all_color_verts.push(ColorVertex {
                                        position: [wx, wy],
                                        color: [
                                            mv.r * current_color[0],
                                            mv.g * current_color[1],
                                            mv.b * current_color[2],
                                            mv.a * current_color[3],
                                        ],
                                    });
                                    all_color_idxs.push(base);
                                }
                            }
                            let idx_end = all_color_idxs.len();
                            let (target_width, target_height) =
                                self.target_dimensions(current_target, canvases);
                            append_color_draw_range(
                                &mut draws,
                                idx_start,
                                idx_end,
                                current_target,
                                current_blend_mode,
                                normalize_scissor(current_scissor, target_width, target_height),
                                color_mask_bits,
                                active_shader.filter(|key| shaders.contains_key(*key)),
                                stencil_mode,
                                stencil_reference,
                            );
                        }
                    }
                }
                RenderCommand::DrawMeshTransient {
                    mesh,
                    x,
                    y,
                    rotation,
                    sx,
                    sy,
                    ox,
                    oy,
                } => {
                    let cos_r = rotation.cos();
                    let sin_r = rotation.sin();
                    let parent = transform_stack_last(&transform_stack);
                    let tri_indices = mesh.triangulate();
                    if let Some(tex_key) = mesh.texture {
                        if self.gpu_textures.contains_key(tex_key) {
                            scratch_tex_verts.clear();
                            scratch_tex_idxs.clear();
                            scratch_tex_verts.reserve(tri_indices.len());
                            scratch_tex_idxs.reserve(tri_indices.len());
                            let base_idx = 0u32;
                            for (i, &vi) in tri_indices.iter().enumerate() {
                                if let Some(mv) = mesh.vertices.get(vi) {
                                    let lx = (mv.x - ox) * sx;
                                    let ly = (mv.y - oy) * sy;
                                    let rx = lx * cos_r - ly * sin_r + x;
                                    let ry = lx * sin_r + ly * cos_r + y;
                                    let (wx, wy) = apply(parent, rx, ry);
                                    scratch_tex_verts.push(TexVertex {
                                        position: [wx, wy],
                                        uv: [mv.u, mv.v],
                                        color: [
                                            mv.r * current_color[0],
                                            mv.g * current_color[1],
                                            mv.b * current_color[2],
                                            mv.a * current_color[3],
                                        ],
                                        w_depth: 1.0,
                                        _pad: [0.0; 3],
                                    });
                                    scratch_tex_idxs.push(base_idx + i as u32);
                                }
                            }
                            let (target_width, target_height) =
                                self.target_dimensions(current_target, canvases);
                            append_tex_draw_slices(
                                &mut draws,
                                &mut all_tex_verts,
                                &mut all_tex_idxs,
                                current_target,
                                TexRef::Texture(tex_key),
                                current_blend_mode,
                                normalize_scissor(current_scissor, target_width, target_height),
                                color_mask_bits,
                                active_shader.filter(|key| shaders.contains_key(*key)),
                                stencil_mode,
                                stencil_reference,
                                &scratch_tex_verts,
                                &scratch_tex_idxs,
                            );
                        }
                    } else {
                        let idx_start = all_color_idxs.len();
                        all_color_verts.reserve(tri_indices.len());
                        all_color_idxs.reserve(tri_indices.len());
                        for &vi in &tri_indices {
                            if let Some(mv) = mesh.vertices.get(vi) {
                                let lx = (mv.x - ox) * sx;
                                let ly = (mv.y - oy) * sy;
                                let rx = lx * cos_r - ly * sin_r + x;
                                let ry = lx * sin_r + ly * cos_r + y;
                                let (wx, wy) = apply(parent, rx, ry);
                                let base = all_color_verts.len() as u32;
                                all_color_verts.push(ColorVertex {
                                    position: [wx, wy],
                                    color: [
                                        mv.r * current_color[0],
                                        mv.g * current_color[1],
                                        mv.b * current_color[2],
                                        mv.a * current_color[3],
                                    ],
                                });
                                all_color_idxs.push(base);
                            }
                        }
                        let idx_end = all_color_idxs.len();
                        let (target_width, target_height) =
                            self.target_dimensions(current_target, canvases);
                        append_color_draw_range(
                            &mut draws,
                            idx_start,
                            idx_end,
                            current_target,
                            current_blend_mode,
                            normalize_scissor(current_scissor, target_width, target_height),
                            color_mask_bits,
                            active_shader.filter(|key| shaders.contains_key(*key)),
                            stencil_mode,
                            stencil_reference,
                        );
                    }
                }
                RenderCommand::SyncMesh { mesh_key, mesh } => {
                    if self.sync_mesh(*mesh_key, mesh).is_err() {
                        self.render_diagnostics.record_invalid_mesh();
                    }
                }
                RenderCommand::DrawNineSlice {
                    texture_key,
                    tex_w,
                    tex_h,
                    top,
                    right,
                    bottom,
                    left,
                    x,
                    y,
                    w,
                    h,
                } => {
                    if !self.gpu_textures.contains_key(*texture_key) {
                        self.render_diagnostics.record_missing_texture();
                        continue;
                    }
                    let t = transform_stack_last(&transform_stack);
                    let ns = crate::sprite::NineSlice::new(
                        *texture_key,
                        *top,
                        *right,
                        *bottom,
                        *left,
                        *tex_w,
                        *tex_h,
                    );
                    let patches = ns.patches(*x, *y, *w, *h);
                    scratch_tex_verts.clear();
                    scratch_tex_idxs.clear();
                    scratch_tex_verts.reserve(4 * 9);
                    scratch_tex_idxs.reserve(6 * 9);
                    for &(sx, sy, sw, sh, dx, dy, dw, dh) in &patches {
                        if sw <= 0.0 || sh <= 0.0 || dw <= 0.0 || dh <= 0.0 {
                            continue;
                        }
                        let u0 = sx / tex_w;
                        let v0 = sy / tex_h;
                        let u1 = (sx + sw) / tex_w;
                        let v1 = (sy + sh) / tex_h;
                        push_tex_quad(
                            &mut scratch_tex_verts,
                            &mut scratch_tex_idxs,
                            t,
                            current_color,
                            dx,
                            dy,
                            0.0,
                            1.0,
                            1.0,
                            0.0,
                            0.0,
                            dw,
                            dh,
                            u0,
                            v0,
                            u1,
                            v1,
                        );
                    }
                    let (target_width, target_height) =
                        self.target_dimensions(current_target, canvases);
                    append_tex_draw_slices(
                        &mut draws,
                        &mut all_tex_verts,
                        &mut all_tex_idxs,
                        current_target,
                        TexRef::Texture(*texture_key),
                        current_blend_mode,
                        normalize_scissor(current_scissor, target_width, target_height),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                        &scratch_tex_verts,
                        &scratch_tex_idxs,
                    );
                }
                RenderCommand::SetShader(shader) => {
                    active_shader = shader.filter(|key| shaders.contains_key(*key));
                }
                RenderCommand::DrawShape {
                    shape_key,
                    x,
                    y,
                    rotation,
                    sx,
                    sy,
                    ox,
                    oy,
                } => {
                    let Some(shape) = shapes.get(*shape_key) else {
                        self.render_diagnostics.record_missing_shape();
                        continue;
                    };
                    if let Err(err) = validate_compound_shape(shape, &render_input_limits) {
                        self.render_diagnostics.record_invalid_render_input();
                        log::warn!("Skipping invalid shape command: {}", err);
                        continue;
                    }
                    let parent = transform_stack_last(&transform_stack);
                    let local = Mat3::from_translation(Vec2 { x: *x, y: *y })
                        * Mat3::from_rotation(*rotation)
                        * Mat3::from_scale(Vec2 { x: *sx, y: *sy })
                        * Mat3::from_translation(Vec2 { x: -*ox, y: -*oy });
                    let shape_transform = *parent * local;
                    self.replay_compound_shape(
                        shape,
                        &shape_transform,
                        wireframe,
                        current_target,
                        current_blend_mode,
                        current_scissor,
                        color_mask_bits,
                        active_shader,
                        stencil_mode,
                        stencil_reference,
                        canvases,
                        shaders,
                        &mut all_color_verts,
                        &mut all_color_idxs,
                        &mut draws,
                    );
                }
                RenderCommand::DrawParticleSystem {
                    ref particles,
                    shader,
                } => {
                    if particles.is_empty() {
                        continue;
                    }
                    let t = transform_stack_last(&transform_stack);
                    let (target_width, target_height) =
                        self.target_dimensions(current_target, canvases);
                    let scissor = normalize_scissor(current_scissor, target_width, target_height);
                    let mut pverts: Vec<ColorVertex> = Vec::with_capacity(particles.len() * 6);
                    let mut pidxs: Vec<u32> = Vec::with_capacity(particles.len() * 12);
                    let mut shader_pverts: Vec<ParticleVertex> =
                        Vec::with_capacity(particles.len() * 6);
                    let mut shader_pidxs: Vec<u32> = Vec::with_capacity(particles.len() * 12);
                    let mut shader_textured_batches: Vec<(
                        TextureKey,
                        Vec<ParticleVertex>,
                        Vec<u32>,
                    )> = Vec::new();
                    use std::f32::consts::PI;
                    for inst in particles {
                        let color = [inst.r, inst.g, inst.b, inst.a];
                        let half = inst.size * 0.5;
                        let vertex_start = pverts.len();
                        let index_start = pidxs.len();
                        match &inst.shape {
                            ParticleRenderShape::Square | ParticleRenderShape::Diamond => {
                                let cos_r = inst.rotation.cos();
                                let sin_r = inst.rotation.sin();
                                let corners =
                                    [(-half, -half), (half, -half), (half, half), (-half, half)];
                                let base = pverts.len() as u32;
                                for (lx, ly) in corners {
                                    let (sx, sy) = apply(
                                        t,
                                        inst.x + lx * cos_r - ly * sin_r,
                                        inst.y + lx * sin_r + ly * cos_r,
                                    );
                                    pverts.push(ColorVertex {
                                        position: [sx, sy],
                                        color,
                                    });
                                }
                                pidxs.extend_from_slice(&[
                                    base,
                                    base + 1,
                                    base + 2,
                                    base,
                                    base + 2,
                                    base + 3,
                                ]);
                            }
                            ParticleRenderShape::Circle => {
                                self.tess_ellipse(
                                    &mut pverts,
                                    &mut pidxs,
                                    t,
                                    color,
                                    &DrawMode::Fill,
                                    inst.x,
                                    inst.y,
                                    half,
                                    half,
                                    12,
                                    0.0,
                                );
                            }
                            ParticleRenderShape::Puff => {
                                self.tess_ellipse(
                                    &mut pverts,
                                    &mut pidxs,
                                    t,
                                    color,
                                    &DrawMode::Fill,
                                    inst.x,
                                    inst.y,
                                    half,
                                    half,
                                    24,
                                    0.0,
                                );
                            }
                            ParticleRenderShape::Triangle => {
                                let base = pverts.len() as u32;
                                for i in 0..3u32 {
                                    let a = inst.rotation - PI * 0.5 + i as f32 * (2.0 * PI / 3.0);
                                    let (sx, sy) =
                                        apply(t, inst.x + a.cos() * half, inst.y + a.sin() * half);
                                    pverts.push(ColorVertex {
                                        position: [sx, sy],
                                        color,
                                    });
                                }
                                pidxs.extend_from_slice(&[base, base + 1, base + 2]);
                            }
                            ParticleRenderShape::Spark => {
                                let len = inst.size * 1.5;
                                let dx = inst.rotation.cos() * len;
                                let dy = inst.rotation.sin() * len;
                                push_thick_line(
                                    &mut pverts,
                                    &mut pidxs,
                                    t,
                                    color,
                                    inst.x - dx,
                                    inst.y - dy,
                                    inst.x + dx,
                                    inst.y + dy,
                                    1.5,
                                );
                            }
                            ParticleRenderShape::Shrapnel { edges, seed } => {
                                let n = (*edges).clamp(3, 12) as usize;
                                let center_idx = pverts.len() as u32;
                                let (csx, csy) = apply(t, inst.x, inst.y);
                                pverts.push(ColorVertex {
                                    position: [csx, csy],
                                    color,
                                });
                                let mut rng = u64::from(*seed);
                                for i in 0..n {
                                    let base_angle =
                                        inst.rotation + i as f32 * (2.0 * PI / n as f32);
                                    rng = rng
                                        .wrapping_mul(6_364_136_223_846_793_005)
                                        .wrapping_add(1_442_695_040_888_963_407);
                                    let jitter_a = (rng >> 33) as f32 / u32::MAX as f32 * 0.4 - 0.2;
                                    rng = rng
                                        .wrapping_mul(6_364_136_223_846_793_005)
                                        .wrapping_add(1_442_695_040_888_963_407);
                                    let jitter_r = 0.5 + (rng >> 33) as f32 / u32::MAX as f32 * 0.5;
                                    let angle = base_angle + jitter_a * (2.0 * PI / n as f32);
                                    let (sx, sy) = apply(
                                        t,
                                        inst.x + angle.cos() * half * jitter_r,
                                        inst.y + angle.sin() * half * jitter_r,
                                    );
                                    pverts.push(ColorVertex {
                                        position: [sx, sy],
                                        color,
                                    });
                                }
                                for i in 0..n as u32 {
                                    let c = center_idx;
                                    let b = center_idx + 1 + i;
                                    let d = center_idx + 1 + (i + 1) % n as u32;
                                    pidxs.extend_from_slice(&[c, b, d]);
                                }
                            }
                            ParticleRenderShape::Ray { aspect } => {
                                let a = if *aspect <= 0.0 { 4.0_f32 } else { *aspect };
                                let half_len = half * a;
                                let cos_r = inst.rotation.cos();
                                let sin_r = inst.rotation.sin();
                                let corners = [
                                    (-half_len, -half),
                                    (half_len, -half),
                                    (half_len, half),
                                    (-half_len, half),
                                ];
                                let base = pverts.len() as u32;
                                for (lx, ly) in corners {
                                    let (sx, sy) = apply(
                                        t,
                                        inst.x + lx * cos_r - ly * sin_r,
                                        inst.y + lx * sin_r + ly * cos_r,
                                    );
                                    pverts.push(ColorVertex {
                                        position: [sx, sy],
                                        color,
                                    });
                                }
                                pidxs.extend_from_slice(&[
                                    base,
                                    base + 1,
                                    base + 2,
                                    base,
                                    base + 2,
                                    base + 3,
                                ]);
                            }
                            ParticleRenderShape::Ring { thickness } => {
                                let outer = half;
                                let inner = outer * (1.0 - (*thickness).clamp(0.05, 1.0));
                                /// Number of vertices used to approximate a circular arc in the fallback path.
                                const N: usize = 20;
                                let base = pverts.len() as u32;
                                for i in 0..N {
                                    let angle = i as f32 * (2.0 * PI / N as f32);
                                    let (sx, sy) = apply(
                                        t,
                                        inst.x + angle.cos() * outer,
                                        inst.y + angle.sin() * outer,
                                    );
                                    pverts.push(ColorVertex {
                                        position: [sx, sy],
                                        color,
                                    });
                                    let (sx, sy) = apply(
                                        t,
                                        inst.x + angle.cos() * inner,
                                        inst.y + angle.sin() * inner,
                                    );
                                    pverts.push(ColorVertex {
                                        position: [sx, sy],
                                        color,
                                    });
                                }
                                for i in 0..N as u32 {
                                    let j = (i + 1) % N as u32;
                                    let o0 = base + i * 2;
                                    let i0 = base + i * 2 + 1;
                                    let o1 = base + j * 2;
                                    let i1 = base + j * 2 + 1;
                                    pidxs.extend_from_slice(&[o0, o1, i0, i0, o1, i1]);
                                }
                            }
                            ParticleRenderShape::Capsule => {
                                let half_len = half;
                                let cap_r = half * 0.4;
                                let cos_r = inst.rotation.cos();
                                let sin_r = inst.rotation.sin();
                                let corners = [
                                    (-half_len, -cap_r),
                                    (half_len, -cap_r),
                                    (half_len, cap_r),
                                    (-half_len, cap_r),
                                ];
                                let base = pverts.len() as u32;
                                for (lx, ly) in corners {
                                    let (sx, sy) = apply(
                                        t,
                                        inst.x + lx * cos_r - ly * sin_r,
                                        inst.y + lx * sin_r + ly * cos_r,
                                    );
                                    pverts.push(ColorVertex {
                                        position: [sx, sy],
                                        color,
                                    });
                                }
                                pidxs.extend_from_slice(&[
                                    base,
                                    base + 1,
                                    base + 2,
                                    base,
                                    base + 2,
                                    base + 3,
                                ]);
                                /// Number of vertices used to approximate a circle outline in the fallback path.
                                const N: usize = 8;
                                for side in [1.0_f32, -1.0] {
                                    let cap_cx = inst.x + cos_r * half_len * side;
                                    let cap_cy = inst.y + sin_r * half_len * side;
                                    let center_idx = pverts.len() as u32;
                                    let (csx, csy) = apply(t, cap_cx, cap_cy);
                                    pverts.push(ColorVertex {
                                        position: [csx, csy],
                                        color,
                                    });
                                    let start_a = inst.rotation
                                        + if side > 0.0 { -PI * 0.5 } else { PI * 0.5 };
                                    for i in 0..=N {
                                        let a = start_a + i as f32 * PI / N as f32;
                                        let (sx, sy) = apply(
                                            t,
                                            cap_cx + a.cos() * cap_r,
                                            cap_cy + a.sin() * cap_r,
                                        );
                                        pverts.push(ColorVertex {
                                            position: [sx, sy],
                                            color,
                                        });
                                    }
                                    for i in 0..N as u32 {
                                        pidxs.extend_from_slice(&[
                                            center_idx,
                                            center_idx + 1 + i,
                                            center_idx + 1 + i + 1,
                                        ]);
                                    }
                                }
                            }
                        }
                        if shader.is_some() {
                            let mut particle_vertices =
                                Vec::with_capacity(pverts.len() - vertex_start);
                            let mut particle_indices =
                                Vec::with_capacity(pidxs.len() - index_start);
                            let (center_x, center_y) = apply(t, inst.x, inst.y);
                            let inv_size = if inst.size.abs() > f32::EPSILON {
                                1.0 / inst.size.abs()
                            } else {
                                0.0
                            };
                            let atlas_quad = inst
                                .quad
                                .zip(inst.quad_tex_dims)
                                .filter(|(_, (tex_w, tex_h))| *tex_w > 0.0 && *tex_h > 0.0);
                            for vertex in &pverts[vertex_start..] {
                                let local_uv = [
                                    ((vertex.position[0] - center_x) * inv_size + 0.5)
                                        .clamp(0.0, 1.0),
                                    ((vertex.position[1] - center_y) * inv_size + 0.5)
                                        .clamp(0.0, 1.0),
                                ];
                                let uv =
                                    if let Some(([qx, qy, qw, qh], (tex_w, tex_h))) = atlas_quad {
                                        [
                                            (qx + qw * local_uv[0]) / tex_w,
                                            (qy + qh * local_uv[1]) / tex_h,
                                        ]
                                    } else {
                                        local_uv
                                    };
                                particle_vertices.push(ParticleVertex {
                                    position: vertex.position,
                                    color: vertex.color,
                                    uv,
                                    local_pos: [inst.local_x, inst.local_y],
                                    world_pos: [inst.x, inst.y],
                                    velocity: [inst.velocity_x, inst.velocity_y],
                                    normalized_age: inst.normalized_age,
                                    lifetime: inst.lifetime,
                                    seed: inst.seed as f32,
                                    _pad: 0.0,
                                });
                            }
                            for idx in &pidxs[index_start..] {
                                particle_indices.push(idx.saturating_sub(vertex_start as u32));
                            }
                            if let Some(texture_key) = inst.texture_key {
                                let batch_index = shader_textured_batches
                                    .iter()
                                    .position(|(key, _, _)| *key == texture_key);
                                let batch = match batch_index {
                                    Some(index) => &mut shader_textured_batches[index],
                                    None => {
                                        shader_textured_batches.push((
                                            texture_key,
                                            Vec::new(),
                                            Vec::new(),
                                        ));
                                        shader_textured_batches.last_mut().expect("just pushed")
                                    }
                                };
                                let particle_base = batch.1.len() as u32;
                                batch.1.extend_from_slice(&particle_vertices);
                                batch.2.extend(
                                    particle_indices.iter().map(|idx| particle_base + *idx),
                                );
                            } else {
                                let particle_base = shader_pverts.len() as u32;
                                shader_pverts.extend_from_slice(&particle_vertices);
                                shader_pidxs.extend(
                                    particle_indices.iter().map(|idx| particle_base + *idx),
                                );
                            }
                        }
                    }
                    if let Some(shader_key) = shader.filter(|key| shaders.contains_key(*key)) {
                        if !shader_pverts.is_empty() {
                            let idx_start = all_particle_idxs.len() as u32;
                            let base = all_particle_verts.len() as u32;
                            let idx_count = shader_pidxs.len() as u32;
                            all_particle_verts.extend_from_slice(&shader_pverts);
                            all_particle_idxs.extend(shader_pidxs.iter().map(|idx| base + *idx));
                            draws.push(PreparedDraw {
                                target: current_target,
                                geometry: GeometryKind::Particle,
                                texture_ref: None,
                                idx_start,
                                idx_count,
                                blend_mode: current_blend_mode,
                                scissor,
                                color_mask_bits,
                                shader: Some(shader_key),
                                stencil_mode,
                                stencil_reference: stencil_reference as u32,
                                static_geometry: None,
                                instance_buffer: None,
                                instance_start: 0,
                                instance_count: 1,
                            });
                        }
                        for (texture_key, batch_verts, batch_idxs) in shader_textured_batches {
                            if batch_verts.is_empty() {
                                continue;
                            }
                            let idx_start = all_particle_idxs.len() as u32;
                            let base = all_particle_verts.len() as u32;
                            let idx_count = batch_idxs.len() as u32;
                            all_particle_verts.extend_from_slice(&batch_verts);
                            all_particle_idxs.extend(batch_idxs.iter().map(|idx| base + *idx));
                            draws.push(PreparedDraw {
                                target: current_target,
                                geometry: GeometryKind::ParticleTextured,
                                texture_ref: Some(TexRef::Texture(texture_key)),
                                idx_start,
                                idx_count,
                                blend_mode: current_blend_mode,
                                scissor,
                                color_mask_bits,
                                shader: Some(shader_key),
                                stencil_mode,
                                stencil_reference: stencil_reference as u32,
                                static_geometry: None,
                                instance_buffer: None,
                                instance_start: 0,
                                instance_count: 1,
                            });
                        }
                    } else if !pverts.is_empty() {
                        let particle_shader =
                            active_shader.filter(|key| shaders.contains_key(*key));
                        append_color_draw(
                            &mut draws,
                            &mut all_color_verts,
                            &mut all_color_idxs,
                            current_target,
                            current_blend_mode,
                            scissor,
                            color_mask_bits,
                            particle_shader,
                            stencil_mode,
                            stencil_reference,
                            pverts,
                            pidxs,
                        );
                    }
                }
                RenderCommand::DrawQuadBezier {
                    start,
                    control,
                    end,
                    segments,
                } => {
                    let n = (*segments).clamp(4, 256) as usize;
                    let t = transform_stack_last(&transform_stack);
                    let mut verts: Vec<ColorVertex> = Vec::new();
                    let mut idxs: Vec<u32> = Vec::new();
                    let mut prev = *start;
                    for i in 1..=n {
                        let tv = i as f32 / n as f32;
                        let mt = 1.0 - tv;
                        let nx = mt * mt * start.x + 2.0 * mt * tv * control.x + tv * tv * end.x;
                        let ny = mt * mt * start.y + 2.0 * mt * tv * control.y + tv * tv * end.y;
                        push_thick_line(
                            &mut verts,
                            &mut idxs,
                            t,
                            current_color,
                            prev.x,
                            prev.y,
                            nx,
                            ny,
                            line_width,
                        );
                        prev = Vec2::new(nx, ny);
                    }
                    let (tw, th) = self.target_dimensions(current_target, canvases);
                    append_color_draw(
                        &mut draws,
                        &mut all_color_verts,
                        &mut all_color_idxs,
                        current_target,
                        current_blend_mode,
                        normalize_scissor(current_scissor, tw, th),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                        verts,
                        idxs,
                    );
                }
                RenderCommand::DrawCubicBezier {
                    start,
                    c1,
                    c2,
                    end,
                    segments,
                } => {
                    let n = (*segments).clamp(4, 256) as usize;
                    let t = transform_stack_last(&transform_stack);
                    let mut verts: Vec<ColorVertex> = Vec::new();
                    let mut idxs: Vec<u32> = Vec::new();
                    let mut prev = *start;
                    for i in 1..=n {
                        let tv = i as f32 / n as f32;
                        let mt = 1.0 - tv;
                        let nx = mt * mt * mt * start.x
                            + 3.0 * mt * mt * tv * c1.x
                            + 3.0 * mt * tv * tv * c2.x
                            + tv * tv * tv * end.x;
                        let ny = mt * mt * mt * start.y
                            + 3.0 * mt * mt * tv * c1.y
                            + 3.0 * mt * tv * tv * c2.y
                            + tv * tv * tv * end.y;
                        push_thick_line(
                            &mut verts,
                            &mut idxs,
                            t,
                            current_color,
                            prev.x,
                            prev.y,
                            nx,
                            ny,
                            line_width,
                        );
                        prev = Vec2::new(nx, ny);
                    }
                    let (tw, th) = self.target_dimensions(current_target, canvases);
                    append_color_draw(
                        &mut draws,
                        &mut all_color_verts,
                        &mut all_color_idxs,
                        current_target,
                        current_blend_mode,
                        normalize_scissor(current_scissor, tw, th),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                        verts,
                        idxs,
                    );
                }
                RenderCommand::DrawPath {
                    segments: path_segs,
                    mode,
                    close,
                } => {
                    let t = transform_stack_last(&transform_stack);
                    let mut verts: Vec<ColorVertex> = Vec::new();
                    let mut idxs: Vec<u32> = Vec::new();
                    let mut points: Vec<[f32; 2]> = Vec::new();
                    let mut pen = [0.0f32; 2];
                    let mut anchor = [0.0f32; 2];
                    for seg in path_segs {
                        match seg {
                            PathSegment::MoveTo { x, y } => {
                                if !points.is_empty() {
                                    if *close {
                                        points.push(anchor);
                                    }
                                    for w in points.windows(2) {
                                        push_thick_line(
                                            &mut verts,
                                            &mut idxs,
                                            t,
                                            current_color,
                                            w[0][0],
                                            w[0][1],
                                            w[1][0],
                                            w[1][1],
                                            line_width,
                                        );
                                    }
                                    points.clear();
                                }
                                pen = [*x, *y];
                                anchor = pen;
                                points.push(pen);
                            }
                            PathSegment::LineTo { x, y } => {
                                pen = [*x, *y];
                                points.push(pen);
                            }
                            PathSegment::QuadTo { cx, cy, x, y } => {
                                let s = Vec2::new(pen[0], pen[1]);
                                let c = Vec2::new(*cx, *cy);
                                let e = Vec2::new(*x, *y);
                                for i in 1..=8usize {
                                    let tv = i as f32 / 8.0;
                                    let mt = 1.0 - tv;
                                    let nx = mt * mt * s.x + 2.0 * mt * tv * c.x + tv * tv * e.x;
                                    let ny = mt * mt * s.y + 2.0 * mt * tv * c.y + tv * tv * e.y;
                                    points.push([nx, ny]);
                                }
                                pen = [*x, *y];
                            }
                            PathSegment::CubicTo {
                                cx1,
                                cy1,
                                cx2,
                                cy2,
                                x,
                                y,
                            } => {
                                let s = Vec2::new(pen[0], pen[1]);
                                let cp1 = Vec2::new(*cx1, *cy1);
                                let cp2 = Vec2::new(*cx2, *cy2);
                                let ep = Vec2::new(*x, *y);
                                for i in 1..=8usize {
                                    let tv = i as f32 / 8.0;
                                    let mt = 1.0 - tv;
                                    let nx = mt * mt * mt * s.x
                                        + 3.0 * mt * mt * tv * cp1.x
                                        + 3.0 * mt * tv * tv * cp2.x
                                        + tv * tv * tv * ep.x;
                                    let ny = mt * mt * mt * s.y
                                        + 3.0 * mt * mt * tv * cp1.y
                                        + 3.0 * mt * tv * tv * cp2.y
                                        + tv * tv * tv * ep.y;
                                    points.push([nx, ny]);
                                }
                                pen = [*x, *y];
                            }
                        }
                    }
                    if !points.is_empty() {
                        if *close {
                            points.push(anchor);
                        }
                        match mode {
                            DrawMode::Line => {
                                for w in points.windows(2) {
                                    push_thick_line(
                                        &mut verts,
                                        &mut idxs,
                                        t,
                                        current_color,
                                        w[0][0],
                                        w[0][1],
                                        w[1][0],
                                        w[1][1],
                                        line_width,
                                    );
                                }
                            }
                            DrawMode::Fill => {
                                let flat: Vec<f32> =
                                    points.iter().flat_map(|p| [p[0], p[1]]).collect();
                                self.tess_polygon(
                                    &mut verts,
                                    &mut idxs,
                                    t,
                                    current_color,
                                    &DrawMode::Fill,
                                    &flat,
                                    line_width,
                                );
                            }
                        }
                    }
                    let (tw, th) = self.target_dimensions(current_target, canvases);
                    append_color_draw(
                        &mut draws,
                        &mut all_color_verts,
                        &mut all_color_idxs,
                        current_target,
                        current_blend_mode,
                        normalize_scissor(current_scissor, tw, th),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                        verts,
                        idxs,
                    );
                }
                RenderCommand::DrawGradientRect {
                    x,
                    y,
                    w,
                    h,
                    color1,
                    color2,
                    direction,
                } => {
                    let lerp = |a: &[f32; 4], b: &[f32; 4], f: f32| -> [f32; 4] {
                        [
                            a[0] + (b[0] - a[0]) * f,
                            a[1] + (b[1] - a[1]) * f,
                            a[2] + (b[2] - a[2]) * f,
                            a[3] + (b[3] - a[3]) * f,
                        ]
                    };
                    let corner_colors: [[f32; 4]; 4] = match direction {
                        GradientDirection::Horizontal => [*color1, *color2, *color2, *color1],
                        GradientDirection::Vertical => [*color1, *color1, *color2, *color2],
                        GradientDirection::DiagDown => {
                            let mid = lerp(color1, color2, 0.5);
                            [*color1, mid, *color2, mid]
                        }
                        GradientDirection::DiagUp => {
                            let mid = lerp(color1, color2, 0.5);
                            [mid, *color1, mid, *color2]
                        }
                        GradientDirection::Radial => [*color1, *color1, *color2, *color2],
                    };
                    let t = transform_stack_last(&transform_stack);
                    let corner_pts = [(*x, *y), (*x + w, *y), (*x + w, *y + h), (*x, *y + h)];
                    let mut verts: Vec<ColorVertex> = Vec::with_capacity(4);
                    let mut idxs: Vec<u32> = Vec::with_capacity(6);
                    let base = verts.len() as u32;
                    for (i, (px, py)) in corner_pts.iter().enumerate() {
                        let (sx, sy) = apply(t, *px, *py);
                        verts.push(ColorVertex {
                            position: [sx, sy],
                            color: corner_colors[i],
                        });
                    }
                    idxs.extend_from_slice(&[base, base + 1, base + 2, base, base + 2, base + 3]);
                    let (tw, th) = self.target_dimensions(current_target, canvases);
                    append_color_draw(
                        &mut draws,
                        &mut all_color_verts,
                        &mut all_color_idxs,
                        current_target,
                        current_blend_mode,
                        normalize_scissor(current_scissor, tw, th),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                        verts,
                        idxs,
                    );
                }
                RenderCommand::DrawColoredPolygon {
                    vertices,
                    colors,
                    mode,
                } => {
                    let n = vertices.len() / 2;
                    if n >= 3 && colors.len() >= n {
                        let t = transform_stack_last(&transform_stack);
                        let mut verts: Vec<ColorVertex> = Vec::with_capacity(n);
                        let mut idxs: Vec<u32> = Vec::new();
                        match mode {
                            DrawMode::Fill => {
                                for i in 0..n {
                                    let (sx, sy) = apply(t, vertices[i * 2], vertices[i * 2 + 1]);
                                    verts.push(ColorVertex {
                                        position: [sx, sy],
                                        color: colors[i],
                                    });
                                }
                                let poly: Vec<Vec2> = vertices
                                    .chunks_exact(2)
                                    .map(|pair| Vec2::new(pair[0], pair[1]))
                                    .collect();
                                if let Ok(tris) = polygon::triangulate(&poly) {
                                    for tri in tris {
                                        for point in tri {
                                            if let Some(index) = poly.iter().position(|candidate| {
                                                candidate.x.to_bits() == point.x.to_bits()
                                                    && candidate.y.to_bits() == point.y.to_bits()
                                            }) {
                                                idxs.push(index as u32);
                                            }
                                        }
                                    }
                                }
                                if idxs.len() < 3 {
                                    for i in 1..(n as u32 - 1) {
                                        idxs.extend_from_slice(&[0, i, i + 1]);
                                    }
                                }
                            }
                            DrawMode::Line => {
                                for i in 0..n {
                                    let j = (i + 1) % n;
                                    push_thick_line(
                                        &mut verts,
                                        &mut idxs,
                                        t,
                                        colors[i],
                                        vertices[i * 2],
                                        vertices[i * 2 + 1],
                                        vertices[j * 2],
                                        vertices[j * 2 + 1],
                                        line_width,
                                    );
                                }
                            }
                        }
                        let (tw, th) = self.target_dimensions(current_target, canvases);
                        append_color_draw(
                            &mut draws,
                            &mut all_color_verts,
                            &mut all_color_idxs,
                            current_target,
                            current_blend_mode,
                            normalize_scissor(current_scissor, tw, th),
                            color_mask_bits,
                            active_shader.filter(|key| shaders.contains_key(*key)),
                            stencil_mode,
                            stencil_reference,
                            verts,
                            idxs,
                        );
                    }
                }
                RenderCommand::DrawIsoCubeTile {
                    screen_x,
                    screen_y,
                    half_w,
                    half_h,
                    depth: _,
                    top_color,
                    top_texture,
                    left_color,
                    left_texture,
                    right_color,
                    right_texture,
                } => {
                    let t = transform_stack_last(&transform_stack);
                    let sx = *screen_x;
                    let sy = *screen_y;
                    let hw = *half_w;
                    let hh = *half_h;
                    let top_corners = [
                        Vec2::new(sx, sy - hh),
                        Vec2::new(sx + hw, sy),
                        Vec2::new(sx, sy + hh / 2.0),
                        Vec2::new(sx - hw, sy),
                    ];
                    let left_corners = [
                        Vec2::new(sx - hw, sy),
                        Vec2::new(sx, sy + hh / 2.0),
                        Vec2::new(sx, sy + hh * 1.5),
                        Vec2::new(sx - hw, sy + hh),
                    ];
                    let right_corners = [
                        Vec2::new(sx, sy + hh / 2.0),
                        Vec2::new(sx + hw, sy),
                        Vec2::new(sx + hw, sy + hh),
                        Vec2::new(sx, sy + hh * 1.5),
                    ];
                    let full_uvs = [
                        Vec2::new(0.0, 0.0),
                        Vec2::new(1.0, 0.0),
                        Vec2::new(1.0, 1.0),
                        Vec2::new(0.0, 1.0),
                    ];
                    let (tw, th) = self.target_dimensions(current_target, canvases);
                    let scissor = normalize_scissor(current_scissor, tw, th);
                    for (corners, color, tex_opt) in [
                        (&top_corners, top_color, top_texture),
                        (&left_corners, left_color, left_texture),
                        (&right_corners, right_color, right_texture),
                    ] {
                        if let Some(key) = tex_opt {
                            if self.gpu_textures.contains_key(*key) {
                                scratch_tex_verts.clear();
                                scratch_tex_idxs.clear();
                                push_tex_quad_corners(
                                    &mut scratch_tex_verts,
                                    &mut scratch_tex_idxs,
                                    t,
                                    *color,
                                    corners,
                                    &full_uvs,
                                    &[1.0, 1.0, 1.0, 1.0],
                                );
                                append_tex_draw_slices(
                                    &mut draws,
                                    &mut all_tex_verts,
                                    &mut all_tex_idxs,
                                    current_target,
                                    TexRef::Texture(*key),
                                    current_blend_mode,
                                    scissor,
                                    color_mask_bits,
                                    active_shader.filter(|key| shaders.contains_key(*key)),
                                    stencil_mode,
                                    stencil_reference,
                                    &scratch_tex_verts,
                                    &scratch_tex_idxs,
                                );
                            }
                        } else {
                            let flat: Vec<f32> = corners.iter().flat_map(|v| [v.x, v.y]).collect();
                            let mut cv: Vec<ColorVertex> = Vec::new();
                            let mut ci: Vec<u32> = Vec::new();
                            self.tess_polygon(
                                &mut cv,
                                &mut ci,
                                t,
                                *color,
                                &DrawMode::Fill,
                                &flat,
                                line_width,
                            );
                            append_color_draw(
                                &mut draws,
                                &mut all_color_verts,
                                &mut all_color_idxs,
                                current_target,
                                current_blend_mode,
                                scissor,
                                color_mask_bits,
                                active_shader.filter(|key| shaders.contains_key(*key)),
                                stencil_mode,
                                stencil_reference,
                                cv,
                                ci,
                            );
                        }
                    }
                }
                RenderCommand::DrawHexTile {
                    cx,
                    cy,
                    size,
                    orientation,
                    mode,
                } => {
                    let t = transform_stack_last(&transform_stack);
                    let angle_offset = match orientation {
                        HexOrientation::PointyTop => PI / 6.0,
                        HexOrientation::FlatTop => 0.0,
                    };
                    let mut flat = Vec::with_capacity(12);
                    for k in 0..6u32 {
                        let a = k as f32 * PI / 3.0 + angle_offset;
                        flat.push(*cx + *size * a.cos());
                        flat.push(*cy + *size * a.sin());
                    }
                    let mut verts: Vec<ColorVertex> = Vec::new();
                    let mut idxs: Vec<u32> = Vec::new();
                    self.tess_polygon(
                        &mut verts,
                        &mut idxs,
                        t,
                        current_color,
                        mode,
                        &flat,
                        line_width,
                    );
                    let (tw, th) = self.target_dimensions(current_target, canvases);
                    append_color_draw(
                        &mut draws,
                        &mut all_color_verts,
                        &mut all_color_idxs,
                        current_target,
                        current_blend_mode,
                        normalize_scissor(current_scissor, tw, th),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                        verts,
                        idxs,
                    );
                }
                RenderCommand::BeginSortGroup { .. } => {}
                RenderCommand::PushSortKey(_) => {}
                RenderCommand::FlushSortGroup { .. } => {}
                RenderCommand::DrawPhysicsDebug { shapes, config } => {
                    let t = transform_stack_last(&transform_stack);
                    let lw = config.line_width;
                    let (tw, th) = self.target_dimensions(current_target, canvases);
                    for shape in shapes {
                        let color = if shape.is_sensor {
                            config.sensor_color
                        } else if shape.is_sleeping {
                            config.sleep_color
                        } else if shape.is_static {
                            config.static_color
                        } else {
                            config.body_color
                        };
                        let mut cv: Vec<ColorVertex> = Vec::new();
                        let mut ci: Vec<u32> = Vec::new();
                        if shape.is_circle {
                            self.tess_ellipse(
                                &mut cv,
                                &mut ci,
                                t,
                                color,
                                &DrawMode::Line,
                                shape.x,
                                shape.y,
                                shape.half_w,
                                shape.half_w,
                                24,
                                lw,
                            );
                        } else if !shape.hull_verts.is_empty() {
                            let cos_a = shape.angle.cos();
                            let sin_a = shape.angle.sin();
                            let flat: Vec<f32> = shape
                                .hull_verts
                                .iter()
                                .flat_map(|[lx, ly]| {
                                    let wx = shape.x + lx * cos_a - ly * sin_a;
                                    let wy = shape.y + lx * sin_a + ly * cos_a;
                                    [wx, wy]
                                })
                                .collect();
                            self.tess_polygon(
                                &mut cv,
                                &mut ci,
                                t,
                                color,
                                &DrawMode::Line,
                                &flat,
                                lw,
                            );
                        } else {
                            let cos_a = shape.angle.cos();
                            let sin_a = shape.angle.sin();
                            let corners: [[f32; 2]; 4] = [
                                [-shape.half_w, -shape.half_h],
                                [shape.half_w, -shape.half_h],
                                [shape.half_w, shape.half_h],
                                [-shape.half_w, shape.half_h],
                            ];
                            let flat: Vec<f32> = corners
                                .iter()
                                .flat_map(|[lx, ly]| {
                                    let wx = shape.x + lx * cos_a - ly * sin_a;
                                    let wy = shape.y + lx * sin_a + ly * cos_a;
                                    [wx, wy]
                                })
                                .collect();
                            self.tess_polygon(
                                &mut cv,
                                &mut ci,
                                t,
                                color,
                                &DrawMode::Line,
                                &flat,
                                lw,
                            );
                        }
                        append_color_draw(
                            &mut draws,
                            &mut all_color_verts,
                            &mut all_color_idxs,
                            current_target,
                            current_blend_mode,
                            normalize_scissor(current_scissor, tw, th),
                            color_mask_bits,
                            active_shader.filter(|key| shaders.contains_key(*key)),
                            stencil_mode,
                            stencil_reference,
                            cv,
                            ci,
                        );
                    }
                }
                RenderCommand::DrawSpineSkeleton { slots } => {
                    let t = transform_stack_last(&transform_stack);
                    let (tw, th) = self.target_dimensions(current_target, canvases);
                    let scissor = normalize_scissor(current_scissor, tw, th);
                    for slot in slots {
                        let tex_ref = if let Some(canvas_key) = slot.canvas_key {
                            if canvases.contains_key(canvas_key) {
                                Some(TexRef::Canvas(canvas_key))
                            } else {
                                None
                            }
                        } else if self.gpu_textures.contains_key(slot.texture_key) {
                            Some(TexRef::Texture(slot.texture_key))
                        } else {
                            None
                        };

                        if let Some(resolved_tex) = tex_ref {
                            scratch_tex_verts.clear();
                            scratch_tex_idxs.clear();
                            push_tex_quad_corners(
                                &mut scratch_tex_verts,
                                &mut scratch_tex_idxs,
                                t,
                                slot.color,
                                &slot.corners,
                                &slot.uvs,
                                &[1.0, 1.0, 1.0, 1.0],
                            );
                            append_tex_draw_slices(
                                &mut draws,
                                &mut all_tex_verts,
                                &mut all_tex_idxs,
                                current_target,
                                resolved_tex,
                                slot.blend_mode,
                                scissor,
                                color_mask_bits,
                                active_shader.filter(|key| shaders.contains_key(*key)),
                                stencil_mode,
                                stencil_reference,
                                &scratch_tex_verts,
                                &scratch_tex_idxs,
                            );
                        }
                    }
                }
                RenderCommand::DrawBevelRect {
                    x,
                    y,
                    w,
                    h,
                    bevel_w,
                    style,
                    highlight,
                    shadow,
                    fill_color,
                } => {
                    let t = transform_stack_last(&transform_stack);
                    let bw = *bevel_w;
                    let ix = *x + bw;
                    let iy = *y + bw;
                    let iw = *w - 2.0 * bw;
                    let ih = *h - 2.0 * bw;
                    let (top_c, left_c, bottom_c, right_c) = match style {
                        BevelStyle::Raised => (*highlight, *highlight, *shadow, *shadow),
                        BevelStyle::Sunken => (*shadow, *shadow, *highlight, *highlight),
                        BevelStyle::Ridge => (*highlight, *highlight, *shadow, *shadow),
                        BevelStyle::Groove => (*shadow, *shadow, *highlight, *highlight),
                        BevelStyle::Flat => (*fill_color, *fill_color, *fill_color, *fill_color),
                    };
                    let mut verts: Vec<ColorVertex> = Vec::new();
                    let mut idxs: Vec<u32> = Vec::new();
                    if iw > 0.0 && ih > 0.0 {
                        self.tess_rect(
                            &mut verts,
                            &mut idxs,
                            t,
                            *fill_color,
                            &DrawMode::Fill,
                            ix,
                            iy,
                            iw,
                            ih,
                            line_width,
                        );
                    }
                    let push_bevel_quad =
                        |cv: &mut Vec<ColorVertex>,
                         ci: &mut Vec<u32>,
                         pts: &[(f32, f32); 4],
                         colors: &[[f32; 4]; 4]| {
                            let base = cv.len() as u32;
                            for (i, &(px, py)) in pts.iter().enumerate() {
                                let (sx, sy) = apply(t, px, py);
                                cv.push(ColorVertex {
                                    position: [sx, sy],
                                    color: colors[i],
                                });
                            }
                            ci.extend_from_slice(&[
                                base,
                                base + 1,
                                base + 2,
                                base,
                                base + 2,
                                base + 3,
                            ]);
                        };
                    push_bevel_quad(
                        &mut verts,
                        &mut idxs,
                        &[(*x, *y), (*x + *w, *y), (ix + iw, iy), (ix, iy)],
                        &[top_c, top_c, top_c, top_c],
                    );
                    push_bevel_quad(
                        &mut verts,
                        &mut idxs,
                        &[
                            (ix, iy + ih),
                            (ix + iw, iy + ih),
                            (*x + *w, *y + *h),
                            (*x, *y + *h),
                        ],
                        &[bottom_c, bottom_c, bottom_c, bottom_c],
                    );
                    push_bevel_quad(
                        &mut verts,
                        &mut idxs,
                        &[(*x, *y), (ix, iy), (ix, iy + ih), (*x, *y + *h)],
                        &[left_c, left_c, left_c, left_c],
                    );
                    push_bevel_quad(
                        &mut verts,
                        &mut idxs,
                        &[
                            (ix + iw, iy),
                            (*x + *w, *y),
                            (*x + *w, *y + *h),
                            (ix + iw, iy + ih),
                        ],
                        &[right_c, right_c, right_c, right_c],
                    );
                    let (tw, th) = self.target_dimensions(current_target, canvases);
                    append_color_draw(
                        &mut draws,
                        &mut all_color_verts,
                        &mut all_color_idxs,
                        current_target,
                        current_blend_mode,
                        normalize_scissor(current_scissor, tw, th),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                        verts,
                        idxs,
                    );
                }
                RenderCommand::PushLayer { .. } => {}
                RenderCommand::PopLayer { .. } => {}
                RenderCommand::BeginPostFx { stack_id } => {
                    if self.postfx_pipeline.is_none() {
                        self.postfx_pipeline =
                            Some(crate::render::postfx_pipeline::PostFxPipeline::new(
                                &self.device,
                                self.surface_format,
                            ));
                    }
                    let (w, h) = (self.width, self.height);
                    let fmt = self.surface_format;
                    let dev = &self.device;
                    self.postfx_capture.entry(*stack_id).or_insert_with(|| {
                        crate::render::postfx_pipeline::PostFxTexture::new(
                            dev,
                            w,
                            h,
                            "postfx_capture",
                            fmt,
                        )
                    });
                }
                RenderCommand::EndPostFx { .. } => {}
                RenderCommand::ApplyPostFx {
                    stack_id,
                    passes,
                    width,
                    height,
                } => {
                    pending_postfx.push((*stack_id, passes.clone(), *width, *height));
                }
                RenderCommand::DrawRichText {
                    font_key,
                    spans,
                    x,
                    y,
                } => {
                    let t = transform_stack_last(&transform_stack);
                    self.replay_rich_text(
                        *font_key,
                        spans,
                        *x,
                        *y,
                        t,
                        current_target,
                        current_blend_mode,
                        current_scissor,
                        color_mask_bits,
                        active_shader,
                        stencil_mode,
                        stencil_reference,
                        canvases,
                        shaders,
                        fonts,
                        default_filter,
                        &mut all_tex_verts,
                        &mut all_tex_idxs,
                        &mut scratch_tex_verts,
                        &mut scratch_tex_idxs,
                        &mut draws,
                    );
                }
                RenderCommand::DrawRichTextTransformed {
                    font_key,
                    spans,
                    x,
                    y,
                    rotation,
                    sx,
                    sy,
                    ox,
                    oy,
                } => {
                    let t = transformed_draw_matrix(
                        transform_stack_last(&transform_stack),
                        GpuDrawTransform {
                            x: *x,
                            y: *y,
                            rotation: *rotation,
                            sx: *sx,
                            sy: *sy,
                            ox: *ox,
                            oy: *oy,
                        },
                    );
                    self.replay_rich_text(
                        *font_key,
                        spans,
                        0.0,
                        0.0,
                        &t,
                        current_target,
                        current_blend_mode,
                        current_scissor,
                        color_mask_bits,
                        active_shader,
                        stencil_mode,
                        stencil_reference,
                        canvases,
                        shaders,
                        fonts,
                        default_filter,
                        &mut all_tex_verts,
                        &mut all_tex_idxs,
                        &mut scratch_tex_verts,
                        &mut scratch_tex_idxs,
                        &mut draws,
                    );
                }
                RenderCommand::DrawConvexFan {
                    vertices,
                    tint,
                    blend,
                    ..
                } => {
                    if vertices.len() < 3 {
                        continue;
                    }
                    let t = transform_stack_last(&transform_stack);
                    let mut verts = Vec::with_capacity(vertices.len());
                    for v in vertices {
                        let (px, py) = apply(t, v.x, v.y);
                        verts.push(ColorVertex {
                            position: [px, py],
                            color: *tint,
                        });
                    }
                    let mut idxs = Vec::with_capacity((vertices.len() - 2) * 3);
                    for i in 1..(vertices.len() as u32 - 1) {
                        idxs.extend_from_slice(&[0, i, i + 1]);
                    }
                    let (target_width, target_height) =
                        self.target_dimensions(current_target, canvases);
                    append_color_draw(
                        &mut draws,
                        &mut all_color_verts,
                        &mut all_color_idxs,
                        current_target,
                        *blend,
                        normalize_scissor(current_scissor, target_width, target_height),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                        verts,
                        idxs,
                    );
                }
                RenderCommand::DrawProvinceMap {
                    registry_name,
                    viewport,
                    screen_size,
                    tint,
                    province_tints,
                    terrain_texture,
                    terrain_texture_scale,
                    terrain_texture_strength,
                    edge_gradient_color,
                    edge_gradient_radius,
                    edge_gradient_strength,
                    edge_gradient_softness,
                    border_palette_enabled,
                    province_border_color,
                    coast_border_color,
                    country_border_color,
                    sea_border_darken,
                    selected_id,
                    hovered_id,
                    zoom_mode,
                    time,
                } => {
                    pending_province_maps.push(PendingProvinceMapDraw {
                        registry_name: registry_name.clone(),
                        viewport: *viewport,
                        screen_size: *screen_size,
                        tint: *tint,
                        province_tints: province_tints.clone(),
                        terrain_texture: *terrain_texture,
                        terrain_texture_scale: *terrain_texture_scale,
                        terrain_texture_strength: *terrain_texture_strength,
                        edge_gradient_color: *edge_gradient_color,
                        edge_gradient_radius: *edge_gradient_radius,
                        edge_gradient_strength: *edge_gradient_strength,
                        edge_gradient_softness: *edge_gradient_softness,
                        border_palette_enabled: *border_palette_enabled,
                        province_border_color: *province_border_color,
                        coast_border_color: *coast_border_color,
                        country_border_color: *country_border_color,
                        sea_border_darken: *sea_border_darken,
                        selected_id: *selected_id,
                        hovered_id: *hovered_id,
                        zoom_mode: *zoom_mode,
                        time: *time,
                    });
                }
            }
        }
        self.render_stats.batched_draws +=
            merge_adjacent_prepared_draws(&mut draws, &mut merged_draws) as u32;
        {
            let color_v_pct = all_color_verts.len() * 100 / self.color_vertex_capacity as usize;
            if color_v_pct >= 90 {
                log::warn!(
                    "[G003] color vertex buffer at {}% capacity ({}/{}) â€” consider reducing draw calls or increasing MAX_COLOR_VERTS",
                    color_v_pct, all_color_verts.len(), self.color_vertex_capacity
                );
            }
            let color_i_pct = all_color_idxs.len() * 100 / self.color_index_capacity as usize;
            if color_i_pct >= 90 {
                log::warn!(
                    "[G003] color index buffer at {}% capacity ({}/{}) â€” consider reducing draw calls or increasing MAX_COLOR_IDXS",
                    color_i_pct, all_color_idxs.len(), self.color_index_capacity
                );
            }
            let tex_v_pct = all_tex_verts.len() * 100 / self.tex_vertex_capacity as usize;
            if tex_v_pct >= 90 {
                log::warn!(
                    "[G003] tex vertex buffer at {}% capacity ({}/{}) â€” consider reducing sprite draws or increasing MAX_TEX_VERTS",
                    tex_v_pct, all_tex_verts.len(), self.tex_vertex_capacity
                );
            }
            let tex_i_pct = all_tex_idxs.len() * 100 / self.tex_index_capacity as usize;
            if tex_i_pct >= 90 {
                log::warn!(
                    "[G003] tex index buffer at {}% capacity ({}/{}) â€” consider reducing sprite draws or increasing MAX_TEX_IDXS",
                    tex_i_pct, all_tex_idxs.len(), self.tex_index_capacity
                );
            }
        }
        self.ensure_geometry_buffer_capacity(
            all_color_verts.len(),
            all_color_idxs.len(),
            all_tex_verts.len(),
            all_tex_idxs.len(),
            all_particle_verts.len(),
            all_particle_idxs.len(),
        );
        if !all_color_verts.is_empty() {
            self.queue.write_buffer(
                &self.color_vertex_buffer,
                0,
                bytemuck::cast_slice(&all_color_verts),
            );
            self.queue.write_buffer(
                &self.color_index_buffer,
                0,
                bytemuck::cast_slice(&all_color_idxs),
            );
        }
        if !all_tex_verts.is_empty() {
            self.queue.write_buffer(
                &self.tex_vertex_buffer,
                0,
                bytemuck::cast_slice(&all_tex_verts),
            );
            self.queue.write_buffer(
                &self.tex_index_buffer,
                0,
                bytemuck::cast_slice(&all_tex_idxs),
            );
        }
        if !all_particle_verts.is_empty() {
            self.queue.write_buffer(
                &self.particle_vertex_buffer,
                0,
                bytemuck::cast_slice(&all_particle_verts),
            );
            self.queue.write_buffer(
                &self.particle_index_buffer,
                0,
                bytemuck::cast_slice(&all_particle_idxs),
            );
        }
        if !frame_instances.is_empty() {
            self.ensure_instance_buffer_capacity(frame_instances.len());
            self.queue.write_buffer(
                &self.instance_buffer,
                0,
                bytemuck::cast_slice(&frame_instances),
            );
        }
        let output = match surface.get_current_texture() {
            Ok(output) => output,
            Err(err) => {
                self.frame_buffers = FrameRenderBuffers {
                    color_verts: all_color_verts,
                    color_idxs: all_color_idxs,
                    tex_verts: all_tex_verts,
                    tex_idxs: all_tex_idxs,
                    particle_verts: all_particle_verts,
                    particle_idxs: all_particle_idxs,
                    draws,
                    instances: frame_instances,
                    scratch_color_verts,
                    scratch_color_idxs,
                    scratch_tex_verts,
                    scratch_tex_idxs,
                    merged_draws,
                };
                return Err(err);
            }
        };
        let view = output
            .texture
            .create_view(&wgpu::TextureViewDescriptor::default());
        self.ensure_screen_stencil_target();
        let mut encoder = self
            .device
            .create_command_encoder(&wgpu::CommandEncoderDescriptor {
                label: Some("render_encoder"),
            });
        let mut screen_started = false;
        if !pending_province_maps.is_empty() {
            self.draw_province_maps_to_screen(
                &mut encoder,
                &view,
                &pending_province_maps,
                province_registries,
                background_color,
                &mut screen_started,
            );
        }
        let mut touched_canvases: HashSet<CanvasKey> = HashSet::new();
        let mut cursor = 0usize;
        while cursor < draws.len() {
            let target = draws[cursor].target;
            match target {
                RenderTargetId::Screen => {}
                RenderTargetId::Canvas(key) => {
                    let Some(canvas) = canvases.get(key) else {
                        self.render_diagnostics.record_missing_canvas();
                        while cursor < draws.len() && draws[cursor].target == target {
                            cursor += 1;
                        }
                        continue;
                    };
                    self.ensure_canvas_stencil_target(key, canvas.width, canvas.height);
                }
            }
            let (target_width, target_height) = self.target_dimensions(target, canvases);
            self.update_viewport_uniform(target_width, target_height, camera_matrix, frame_time);
            let (color_view, color_load, stencil_view, stencil_load, clear_canvas_after_pass) =
                match target {
                    RenderTargetId::Screen => {
                        let Some(stencil_target) = self.screen_stencil_target.as_ref() else {
                            while cursor < draws.len() && draws[cursor].target == target {
                                cursor += 1;
                            }
                            continue;
                        };
                        let stencil_view = &stencil_target.view;
                        let color_load = if screen_started {
                            wgpu::LoadOp::Load
                        } else {
                            wgpu::LoadOp::Clear(wgpu::Color {
                                r: background_color[0] as f64,
                                g: background_color[1] as f64,
                                b: background_color[2] as f64,
                                a: background_color[3] as f64,
                            })
                        };
                        let stencil_load = if screen_started {
                            wgpu::LoadOp::Load
                        } else {
                            wgpu::LoadOp::Clear(0)
                        };
                        (&view, color_load, stencil_view, stencil_load, None)
                    }
                    RenderTargetId::Canvas(key) => {
                        let Some(canvas_texture) = self.canvas_gpu_textures.get(key) else {
                            self.render_diagnostics.record_missing_canvas();
                            while cursor < draws.len() && draws[cursor].target == target {
                                cursor += 1;
                            }
                            continue;
                        };
                        let Some(stencil_target) = self.canvas_stencil_targets.get(key) else {
                            self.render_diagnostics.record_missing_canvas();
                            while cursor < draws.len() && draws[cursor].target == target {
                                cursor += 1;
                            }
                            continue;
                        };
                        let canvas_view = &canvas_texture.view;
                        let stencil_view = &stencil_target.view;
                        let first_use_this_frame = touched_canvases.insert(key);
                        let needs_clear = self.canvas_needs_clear.get(key).copied().unwrap_or(true);
                        let color_load = if needs_clear {
                            wgpu::LoadOp::Clear(wgpu::Color::TRANSPARENT)
                        } else {
                            wgpu::LoadOp::Load
                        };
                        let stencil_load = if first_use_this_frame {
                            wgpu::LoadOp::Clear(0)
                        } else {
                            wgpu::LoadOp::Load
                        };
                        (
                            canvas_view,
                            color_load,
                            stencil_view,
                            stencil_load,
                            if needs_clear { Some(key) } else { None },
                        )
                    }
                };
            {
                let mut pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                    label: Some("ordered_render_pass"),
                    color_attachments: &[Some(wgpu::RenderPassColorAttachment {
                        view: color_view,
                        resolve_target: None,
                        ops: wgpu::Operations {
                            load: color_load,
                            store: wgpu::StoreOp::Store,
                        },
                    })],
                    depth_stencil_attachment: Some(wgpu::RenderPassDepthStencilAttachment {
                        view: stencil_view,
                        depth_ops: None,
                        stencil_ops: Some(wgpu::Operations {
                            load: stencil_load,
                            store: wgpu::StoreOp::Store,
                        }),
                    }),
                    ..Default::default()
                });
                let mut previous_pipeline: Option<PipelineSelectionKey> = None;
                let mut previous_texture: Option<TexRef> = None;
                while cursor < draws.len() && draws[cursor].target == target {
                    let draw = draws[cursor];
                    let pipeline_key = self.pipeline_selection_key(draw);
                    if previous_pipeline != Some(pipeline_key) {
                        self.render_stats.shader_switches += 1;
                        previous_pipeline = Some(pipeline_key);
                    }
                    if draw.geometry == GeometryKind::Texture
                        && previous_texture != draw.texture_ref
                    {
                        self.render_stats.texture_switches += 1;
                        previous_texture = draw.texture_ref;
                    }
                    if self.issue_draw(&mut pass, draw, shaders) {
                        self.render_stats.draw_calls += 1;
                    }
                    cursor += 1;
                }
            }
            if let Some(key) = clear_canvas_after_pass {
                self.canvas_needs_clear.insert(key, false);
            }
            if target == RenderTargetId::Screen {
                screen_started = true;
            }
        }
        if !screen_started {
            self.update_viewport_uniform(self.width, self.height, camera_matrix, frame_time);
            if let Some(stencil_target) = self.screen_stencil_target.as_ref() {
                let screen_stencil_view = &stencil_target.view;
                let _pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                    label: Some("screen_clear_pass"),
                    color_attachments: &[Some(wgpu::RenderPassColorAttachment {
                        view: &view,
                        resolve_target: None,
                        ops: wgpu::Operations {
                            load: wgpu::LoadOp::Clear(wgpu::Color {
                                r: background_color[0] as f64,
                                g: background_color[1] as f64,
                                b: background_color[2] as f64,
                                a: background_color[3] as f64,
                            }),
                            store: wgpu::StoreOp::Store,
                        },
                    })],
                    depth_stencil_attachment: Some(wgpu::RenderPassDepthStencilAttachment {
                        view: screen_stencil_view,
                        depth_ops: None,
                        stencil_ops: Some(wgpu::Operations {
                            load: wgpu::LoadOp::Clear(0),
                            store: wgpu::StoreOp::Store,
                        }),
                    }),
                    ..Default::default()
                });
            }
        }
        if light_world.enabled && !light_world.lights.is_empty() {
            self.ensure_light_resources();
            let mut shadow_row = 0usize;
            let occluder_list: Vec<&crate::light::occluder::Occluder> =
                light_world.occluders.values().collect();
            let mut light_shadow_rows: Vec<Option<usize>> = Vec::new();
            let mut shadow_edge_cache = ShadowEdgeCache::default();
            for (_, light) in light_world.lights.iter() {
                if !light.enabled || light.radius * light.energy <= 0.0 {
                    light_shadow_rows.push(None);
                    continue;
                }
                if light.shadow_enabled && shadow_row < MAX_SHADOW_LIGHTS {
                    self.dispatch_shadow_map_gpu(
                        &mut encoder,
                        ShadowDispatchInput {
                            row: shadow_row,
                            light_x: light.x,
                            light_y: light.y,
                            light_radius: light.radius * light.energy,
                            shadow_mask: light.shadow_mask,
                            occluders: &occluder_list,
                        },
                        &mut shadow_edge_cache,
                    );
                    light_shadow_rows.push(Some(shadow_row));
                    shadow_row += 1;
                } else {
                    light_shadow_rows.push(None);
                }
            }
            let mut light_verts: Vec<LightVertex> = Vec::new();
            let mut light_idxs: Vec<u32> = Vec::new();
            let mut light_draw_shaders: Vec<Option<ShaderKey>> = Vec::new();
            let mut light_count = 0usize;
            let atlas_height = MAX_SHADOW_LIGHTS as f32;
            let ambient_color = [
                light_world.ambient.r,
                light_world.ambient.g,
                light_world.ambient.b,
                light_world.ambient.a,
            ];
            for ((_, light), shadow_opt) in light_world.lights.iter().zip(light_shadow_rows.iter())
            {
                if !light.enabled {
                    continue;
                }
                if light_count >= MAX_LIGHT_QUADS {
                    break;
                }
                let r = light.radius * light.energy;
                if r <= 0.0 {
                    continue;
                }
                let ci = light.intensity * light.energy;
                let c = [light.color.r, light.color.g, light.color.b, 1.0];
                let sv = match shadow_opt {
                    Some(row) => (*row as f32 + 0.5) / atlas_height,
                    None => -1.0,
                };
                let filter_mode = match light.shadow_filter {
                    crate::light::ShadowFilter::None => 0.0,
                    crate::light::ShadowFilter::Pcf5 => 1.0,
                    crate::light::ShadowFilter::Pcf13 => 2.0,
                };
                let softness = (light.shadow_smooth * light.shadow_softness).max(0.0);
                let shadow_params = [filter_mode, softness, 1.0 / SHADOW_MAP_RES as f32, 0.0];
                let light_shader = light.shader.or(light_world.shader).filter(|key| {
                    shaders
                        .get(*key)
                        .map(|shader| shader.target() == ShaderTarget::Light)
                        .unwrap_or(false)
                });
                let direction_spot = [
                    light.direction.cos(),
                    light.direction.sin(),
                    light.inner_angle,
                    light.outer_angle,
                ];
                let normal_strength = if light.normal_map_path.is_some() {
                    light.normal_strength.clamp(0.0, 1.0)
                } else {
                    0.0
                };
                let normal_hint = [
                    light.direction.cos() * normal_strength,
                    light.direction.sin() * normal_strength,
                ];
                let base = light_verts.len() as u32;
                light_verts.push(LightVertex {
                    position: [light.x - r, light.y - r],
                    uv: [0.0, 0.0],
                    color: c,
                    shadow_v: sv,
                    shadow_params,
                    light_pos: [light.x, light.y],
                    radius: r,
                    intensity: ci,
                    normal_hint,
                    ambient_color,
                    direction_spot,
                    _pad: [0.0; 2],
                });
                light_verts.push(LightVertex {
                    position: [light.x + r, light.y - r],
                    uv: [1.0, 0.0],
                    color: c,
                    shadow_v: sv,
                    shadow_params,
                    light_pos: [light.x, light.y],
                    radius: r,
                    intensity: ci,
                    normal_hint,
                    ambient_color,
                    direction_spot,
                    _pad: [0.0; 2],
                });
                light_verts.push(LightVertex {
                    position: [light.x + r, light.y + r],
                    uv: [1.0, 1.0],
                    color: c,
                    shadow_v: sv,
                    shadow_params,
                    light_pos: [light.x, light.y],
                    radius: r,
                    intensity: ci,
                    normal_hint,
                    ambient_color,
                    direction_spot,
                    _pad: [0.0; 2],
                });
                light_verts.push(LightVertex {
                    position: [light.x - r, light.y + r],
                    uv: [0.0, 1.0],
                    color: c,
                    shadow_v: sv,
                    shadow_params,
                    light_pos: [light.x, light.y],
                    radius: r,
                    intensity: ci,
                    normal_hint,
                    ambient_color,
                    direction_spot,
                    _pad: [0.0; 2],
                });
                light_idxs.extend_from_slice(&[base, base + 1, base + 2, base, base + 2, base + 3]);
                light_draw_shaders.push(light_shader);
                light_count += 1;
            }
            let composite_base = light_verts.len() as u32;
            let sw = self.width as f32;
            let sh = self.height as f32;
            light_verts.push(LightVertex {
                position: [0.0, 0.0],
                uv: [0.0, 0.0],
                color: [1.0; 4],
                shadow_v: -1.0,
                shadow_params: [0.0; 4],
                light_pos: [0.0, 0.0],
                radius: 0.0,
                intensity: 0.0,
                normal_hint: [0.0, 0.0],
                ambient_color: [0.0; 4],
                direction_spot: [0.0; 4],
                _pad: [0.0; 2],
            });
            light_verts.push(LightVertex {
                position: [sw, 0.0],
                uv: [1.0, 0.0],
                color: [1.0; 4],
                shadow_v: -1.0,
                shadow_params: [0.0; 4],
                light_pos: [0.0, 0.0],
                radius: 0.0,
                intensity: 0.0,
                normal_hint: [0.0, 0.0],
                ambient_color: [0.0; 4],
                direction_spot: [0.0; 4],
                _pad: [0.0; 2],
            });
            light_verts.push(LightVertex {
                position: [sw, sh],
                uv: [1.0, 1.0],
                color: [1.0; 4],
                shadow_v: -1.0,
                shadow_params: [0.0; 4],
                light_pos: [0.0, 0.0],
                radius: 0.0,
                intensity: 0.0,
                normal_hint: [0.0, 0.0],
                ambient_color: [0.0; 4],
                direction_spot: [0.0; 4],
                _pad: [0.0; 2],
            });
            light_verts.push(LightVertex {
                position: [0.0, sh],
                uv: [0.0, 1.0],
                color: [1.0; 4],
                shadow_v: -1.0,
                shadow_params: [0.0; 4],
                light_pos: [0.0, 0.0],
                radius: 0.0,
                intensity: 0.0,
                normal_hint: [0.0, 0.0],
                ambient_color: [0.0; 4],
                direction_spot: [0.0; 4],
                _pad: [0.0; 2],
            });
            light_idxs.extend_from_slice(&[
                composite_base,
                composite_base + 1,
                composite_base + 2,
                composite_base,
                composite_base + 2,
                composite_base + 3,
            ]);
            let composite_idx_start = (light_count * 6) as u32;
            if let Some(lg) = self.light_gpu.as_ref() {
                self.queue
                    .write_buffer(&lg.vertex_buffer, 0, bytemuck::cast_slice(&light_verts));
                self.queue
                    .write_buffer(&lg.index_buffer, 0, bytemuck::cast_slice(&light_idxs));
            }
            self.update_viewport_uniform(self.width, self.height, camera_matrix, frame_time);
            let light_pipeline_key = PipelineKey {
                blend_mode: BlendMode::Add,
                color_mask_bits: 0xF,
                stencil_mode: GpuStencilMode::Disabled,
            };
            let mut prepared_light_shaders = HashSet::new();
            for shader_key in light_draw_shaders.iter().flatten().copied() {
                if !prepared_light_shaders.insert(shader_key) {
                    continue;
                }
                let Some(shader) = shaders.get(shader_key) else {
                    continue;
                };
                if self
                    .custom_pipeline(shader_key, shader, GeometryKind::Light, light_pipeline_key)
                    .is_none()
                {
                    self.render_diagnostics.record_shader_pipeline_failure();
                }
            }
            if let Some(lg) = self.light_gpu.as_ref() {
                let ambient = &light_world.ambient;
                let mut pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                    label: Some("light_accum_pass"),
                    color_attachments: &[Some(wgpu::RenderPassColorAttachment {
                        view: &lg.accum_view,
                        resolve_target: None,
                        ops: wgpu::Operations {
                            load: wgpu::LoadOp::Clear(wgpu::Color {
                                r: ambient.r as f64,
                                g: ambient.g as f64,
                                b: ambient.b as f64,
                                a: 1.0,
                            }),
                            store: wgpu::StoreOp::Store,
                        },
                    })],
                    depth_stencil_attachment: None,
                    ..Default::default()
                });
                if light_count > 0 {
                    pass.set_bind_group(0, &self.viewport_bind_group, &[]);
                    pass.set_bind_group(1, &lg.shadow_atlas_bind_group, &[]);
                    pass.set_vertex_buffer(0, lg.vertex_buffer.slice(..));
                    pass.set_index_buffer(lg.index_buffer.slice(..), wgpu::IndexFormat::Uint32);
                    let mut run_start = 0usize;
                    while run_start < light_count {
                        let run_shader = light_draw_shaders[run_start];
                        let mut run_end = run_start + 1;
                        while run_end < light_count && light_draw_shaders[run_end] == run_shader {
                            run_end += 1;
                        }
                        if let Some(shader_key) = run_shader {
                            if let Some(pipeline) = self.cached_custom_pipeline(
                                shader_key,
                                GeometryKind::Light,
                                light_pipeline_key,
                            ) {
                                pass.set_pipeline(pipeline);
                                if let Some(bind_group) = self.shader_bind_group(shader_key) {
                                    pass.set_bind_group(2, bind_group, &[]);
                                }
                            } else {
                                pass.set_pipeline(&lg.additive_pipeline);
                            }
                        } else {
                            pass.set_pipeline(&lg.additive_pipeline);
                        }
                        pass.draw_indexed((run_start * 6) as u32..(run_end * 6) as u32, 0, 0..1);
                        run_start = run_end;
                    }
                }
            }
            self.update_viewport_uniform(self.width, self.height, &Mat3::identity(), frame_time);
            if let (Some(lg), Some(stencil_target)) =
                (self.light_gpu.as_ref(), self.screen_stencil_target.as_ref())
            {
                let screen_stencil_view = &stencil_target.view;
                let mut pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                    label: Some("light_composite_pass"),
                    color_attachments: &[Some(wgpu::RenderPassColorAttachment {
                        view: &view,
                        resolve_target: None,
                        ops: wgpu::Operations {
                            load: wgpu::LoadOp::Load,
                            store: wgpu::StoreOp::Store,
                        },
                    })],
                    depth_stencil_attachment: Some(wgpu::RenderPassDepthStencilAttachment {
                        view: screen_stencil_view,
                        depth_ops: None,
                        stencil_ops: Some(wgpu::Operations {
                            load: wgpu::LoadOp::Load,
                            store: wgpu::StoreOp::Store,
                        }),
                    }),
                    ..Default::default()
                });
                pass.set_pipeline(&lg.composite_pipeline);
                pass.set_bind_group(0, &self.viewport_bind_group, &[]);
                pass.set_bind_group(1, &lg.accum_bind_group, &[]);
                pass.set_vertex_buffer(0, lg.vertex_buffer.slice(..));
                pass.set_index_buffer(lg.index_buffer.slice(..), wgpu::IndexFormat::Uint32);
                pass.set_scissor_rect(0, 0, self.width, self.height);
                pass.set_stencil_reference(0);
                pass.draw_indexed(composite_idx_start..composite_idx_start + 6, 0, 0..1);
            }
            self.update_viewport_uniform(self.width, self.height, camera_matrix, frame_time);
        }
        let pending_readback = if capture_screenshot {
            self.begin_surface_readback(&mut encoder, &output.texture, self.width, self.height)
        } else {
            None
        };
        for (stack_id, passes, w, h) in &pending_postfx {
            if let (Some(pipeline), Some(capture)) = (
                self.postfx_pipeline.as_mut(),
                self.postfx_capture.get(stack_id),
            ) {
                pipeline.apply(
                    &self.device,
                    &self.queue,
                    &mut encoder,
                    &capture.view,
                    &view,
                    passes,
                    shaders,
                    *w,
                    *h,
                    frame_time,
                    frame_count,
                );
            }
        }
        self.queue.submit(std::iter::once(encoder.finish()));
        output.present();
        self.render_stats.cpu_render_ms = frame_start.elapsed().as_secs_f32() * 1000.0;
        let screenshot =
            pending_readback.and_then(|readback| self.complete_surface_readback(readback));
        self.frame_buffers = FrameRenderBuffers {
            color_verts: all_color_verts,
            color_idxs: all_color_idxs,
            tex_verts: all_tex_verts,
            tex_idxs: all_tex_idxs,
            particle_verts: all_particle_verts,
            particle_idxs: all_particle_idxs,
            draws,
            instances: frame_instances,
            scratch_color_verts,
            scratch_color_idxs,
            scratch_tex_verts,
            scratch_tex_idxs,
            merged_draws,
        };
        Ok(screenshot)
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
