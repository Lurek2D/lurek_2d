struct ProvinceData {
    color: vec4<f32>,
    terrain_type: u32,
    border_style: u32,
    fog_state: u32,
    visibility_state: u32,
};

struct BorderStyle {
    color: vec4<f32>,
    thickness: f32,
    flags: u32,
    _pad0: vec2<f32>,
};

struct ProvinceMapUniforms {
    viewport: vec4<f32>,
    map_size: vec2<f32>,
    screen_size: vec2<f32>,
    zoom_mode: u32,
    time: f32,
    _pad1: vec2<f32>,
};

@group(0) @binding(0)
var province_tex: texture_2d<u32>;

@group(0) @binding(1)
var border_idx_tex: texture_2d<u32>;

@group(0) @binding(2)
var distance_tex: texture_2d<f32>;

@group(0) @binding(3)
var<storage, read> province_data: array<ProvinceData>;

@group(0) @binding(4)
var<storage, read> border_styles: array<BorderStyle>;

@group(1) @binding(0)
var<uniform> u: ProvinceMapUniforms;

struct VertexOut {
    @builtin(position) clip_pos: vec4<f32>,
    @location(0) uv: vec2<f32>,
};

@vertex
fn vs_main(@builtin(vertex_index) vi: u32) -> VertexOut {
    let x = f32((vi & 1u) << 1u);
    let y = f32(vi & 2u);
    var out: VertexOut;
    out.clip_pos = vec4<f32>(x * 2.0 - 1.0, 1.0 - y * 2.0, 0.0, 1.0);
    out.uv = vec2<f32>(x, y);
    return out;
}

fn map_pos_from_screen(screen_xy: vec2<f32>) -> vec2<i32> {
    let map_uv = u.viewport.xy + screen_xy * (u.viewport.zw - u.viewport.xy) / u.screen_size;
    return vec2<i32>(map_uv);
}

fn strategic_mode() -> bool {
    return u.zoom_mode == 0u;
}

@fragment
fn fs_main(@builtin(position) pos: vec4<f32>) -> @location(0) vec4<f32> {
    let map_px = map_pos_from_screen(pos.xy);

    if (map_px.x < 0 || map_px.y < 0 || map_px.x >= i32(u.map_size.x) || map_px.y >= i32(u.map_size.y)) {
        return vec4<f32>(0.02, 0.05, 0.08, 1.0);
    }

    let province_id = textureLoad(province_tex, map_px, 0).r;
    if (province_id == 0u) {
        return vec4<f32>(0.05, 0.15, 0.35, 1.0);
    }

    let pd = province_data[province_id];
    if (pd.visibility_state == 0u) {
        return vec4<f32>(0.02, 0.02, 0.02, 1.0);
    }
    if (pd.visibility_state == 1u) {
        return vec4<f32>(0.2, 0.2, 0.2, 1.0);
    }

    var out_color = pd.color;

    if (!strategic_mode()) {
        let dist = textureLoad(distance_tex, map_px, 0).r;
        let shade = mix(0.75, 1.0, smoothstep(0.0, 0.12, dist));
        out_color = vec4<f32>(out_color.rgb * shade, out_color.a);
    }

    let border_id = textureLoad(border_idx_tex, map_px, 0).r;
    if (border_id > 0u) {
        let bs = border_styles[border_id];
        let is_country = (bs.flags & 0x01u) != 0u;
        if (!strategic_mode() || is_country || bs.thickness > 1.0) {
            out_color = bs.color;
        }
    }

    return out_color;
}
