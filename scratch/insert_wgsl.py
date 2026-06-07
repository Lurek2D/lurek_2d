#!/usr/bin/env python3
"""Insert WGSL shader constant definitions into gpu_renderer.rs."""

path = r'c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs'

COLOR_SHADER = r'''/// Built-in flat-color vertex + fragment WGSL shader.
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
'''

TEXTURE_SHADER = r'''/// Built-in textured vertex + fragment WGSL shader.
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
'''

LIGHT_SHADER = r'''/// Built-in light quad WGSL shader with 1-D shadow map sampling.
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
    let view = mat3x3<f32>(viewport.view_col0.xyz, viewport.view_col1.xyz, viewport.view_col2.xyz);
    let cam_pos = view * vec3<f32>(in.position, 1.0);
    out.clip_position = vec4<f32>((cam_pos.x/viewport.size.x)*2.0-1.0, 1.0-(cam_pos.y/viewport.size.y)*2.0, 0.0, 1.0);
    out.uv = in.uv; out.color = in.color; out.shadow_v = in.shadow_v; out.shadow_params = in.shadow_params;
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
    return vec4<f32>(in.color.rgb * intensity * shadow, 1.0);
}
"#;
'''

SHADOW_COMPUTE_SHADER = r'''/// Shadow compute WGSL shader — ray-marches edges to build 1-D shadow map rows.
const SHADOW_COMPUTE_SHADER: &str = r#"
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
'''

with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Insert before the blank line + pub struct GpuRenderer  (currently lines 39-41, 0-indexed 38-40)
insert_at = 40  # 0-indexed (line 41 in 1-indexed view = pub struct GpuRenderer)

block = '\n'.join([COLOR_SHADER, TEXTURE_SHADER, LIGHT_SHADER, SHADOW_COMPUTE_SHADER]) + '\n'

lines.insert(insert_at, block)

with open(path, 'w', encoding='utf-8') as f:
    f.writelines(lines)

print(f'Inserted WGSL constants at line {insert_at+1}. New total: {len(lines)}')
