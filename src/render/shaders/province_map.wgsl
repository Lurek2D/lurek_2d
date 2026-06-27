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
    province_a: u32,
    province_b: u32,
};

struct BorderHit {
    id: u32,
    dist_px: f32,
};

struct ProvinceMapUniforms {
    viewport: vec4<f32>,
    map_size: vec2<f32>,
    screen_size: vec2<f32>,
    zoom_mode: u32,
    time: f32,
    terrain_texture_scale: f32,
    terrain_texture_strength: f32,
    fill_tint: vec4<f32>,
    edge_gradient_color: vec4<f32>,
    edge_gradient_params: vec4<f32>,
    province_border_color: vec4<f32>,
    coast_border_color: vec4<f32>,
    country_border_color: vec4<f32>,
    border_palette_params: vec4<f32>,
    highlight_ids: vec4<u32>,
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

@group(0) @binding(5)
var terrain_texture: texture_2d<f32>;

@group(0) @binding(6)
var terrain_sampler: sampler;

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

fn map_uv_from_screen(screen_xy: vec2<f32>) -> vec2<f32> {
    return u.viewport.xy + screen_xy * (u.viewport.zw - u.viewport.xy) / u.screen_size;
}

fn srgb_to_linear(rgb: vec3<f32>) -> vec3<f32> {
    let lo = rgb / vec3<f32>(12.92);
    let hi = pow((rgb + vec3<f32>(0.055)) / vec3<f32>(1.055), vec3<f32>(2.4));
    return select(hi, lo, rgb <= vec3<f32>(0.04045));
}

fn sample_distance_bilinear(map_uv: vec2<f32>) -> f32 {
    let base = floor(map_uv);
    let frac = fract(map_uv);
    let p00 = clamp(vec2<i32>(base), vec2<i32>(0, 0), vec2<i32>(i32(u.map_size.x) - 1, i32(u.map_size.y) - 1));
    let p10 = clamp(p00 + vec2<i32>(1, 0), vec2<i32>(0, 0), vec2<i32>(i32(u.map_size.x) - 1, i32(u.map_size.y) - 1));
    let p01 = clamp(p00 + vec2<i32>(0, 1), vec2<i32>(0, 0), vec2<i32>(i32(u.map_size.x) - 1, i32(u.map_size.y) - 1));
    let p11 = clamp(p00 + vec2<i32>(1, 1), vec2<i32>(0, 0), vec2<i32>(i32(u.map_size.x) - 1, i32(u.map_size.y) - 1));
    let d00 = textureLoad(distance_tex, p00, 0).r;
    let d10 = textureLoad(distance_tex, p10, 0).r;
    let d01 = textureLoad(distance_tex, p01, 0).r;
    let d11 = textureLoad(distance_tex, p11, 0).r;
    let dx0 = mix(d00, d10, frac.x);
    let dx1 = mix(d01, d11, frac.x);
    return mix(dx0, dx1, frac.y);
}

fn strategic_mode() -> bool {
    return u.zoom_mode == 0u;
}

fn sample_province_id(map_uv: vec2<f32>) -> u32 {
    let map_px = vec2<i32>(map_uv);
    if (map_px.x < 0 || map_px.y < 0 || map_px.x >= i32(u.map_size.x) || map_px.y >= i32(u.map_size.y)) {
        return 0u;
    }
    return textureLoad(province_tex, map_px, 0).r;
}

fn border_pair_matches(bs: BorderStyle, a: u32, b: u32) -> bool {
    return (bs.province_a == a && bs.province_b == b) || (bs.province_a == b && bs.province_b == a);
}

fn border_visible_in_mode(bs: BorderStyle) -> bool {
    return true;
}

fn border_contains_province(bs: BorderStyle, id: u32) -> bool {
    return id != 0u && (bs.province_a == id || bs.province_b == id);
}

fn border_palette_color(bs: BorderStyle) -> vec4<f32> {
    let flag_country = (bs.flags & 0x01u) != 0u;
    let flag_coast = (bs.flags & 0x10u) != 0u;
    let flag_sea = (bs.flags & 0x20u) != 0u;
    let flag_explicit = (bs.flags & 0x80u) != 0u;
    if (u.border_palette_params.x < 0.5 || flag_explicit) {
        return bs.color;
    }
    if (flag_country) {
        return u.country_border_color;
    }
    if (flag_coast) {
        return u.coast_border_color;
    }
    if (flag_sea) {
        let a = province_data[bs.province_a].color;
        let b = province_data[bs.province_b].color;
        let darken = clamp(1.0 - u.border_palette_params.y, 0.0, 1.0);
        return vec4<f32>(mix(a.rgb, b.rgb, 0.5) * darken, u.province_border_color.a);
    }
    return u.province_border_color;
}

fn screen_per_map_min() -> f32 {
    let map_span = max(u.viewport.zw - u.viewport.xy, vec2<f32>(1.0, 1.0));
    let screen_per_map = u.screen_size / map_span;
    return min(screen_per_map.x, screen_per_map.y);
}

fn map_zoom_scale() -> f32 {
    let reference_scale = 8.0;
    return max(screen_per_map_min() / reference_scale, 0.0);
}

fn border_thickness_px(bs: BorderStyle) -> f32 {
    let thickness = max(bs.thickness, 1.0);
    return thickness * map_zoom_scale() * 0.5;
}

fn edge_gradient_radius_px() -> f32 {
    return max(u.edge_gradient_params.x * map_zoom_scale(), 0.0);
}

fn boundary_offset_dist_px(offset: vec2<i32>, frac: vec2<f32>, screen_per_map: vec2<f32>) -> f32 {
    var delta = vec2<f32>(0.0, 0.0);
    if (offset.x > 0) {
        delta.x = (f32(offset.x) - frac.x) * screen_per_map.x;
    } else if (offset.x < 0) {
        delta.x = (frac.x + f32(-offset.x) - 1.0) * screen_per_map.x;
    }
    if (offset.y > 0) {
        delta.y = (f32(offset.y) - frac.y) * screen_per_map.y;
    } else if (offset.y < 0) {
        delta.y = (frac.y + f32(-offset.y) - 1.0) * screen_per_map.y;
    }
    return length(delta);
}

fn try_boundary_probe(map_uv: vec2<f32>, province_id: u32, offset: vec2<i32>, dist_px: f32, max_px: f32, best_dist: ptr<function, f32>) {
    if (province_id == 0u || dist_px > max_px) {
        return;
    }
    let other_id = sample_province_id(map_uv + vec2<f32>(offset));
    if (other_id == 0u || other_id == province_id) {
        return;
    }
    if (province_data[other_id].visibility_state == 0u) {
        return;
    }
    if (dist_px < (*best_dist)) {
        *best_dist = dist_px;
    }
}

fn screen_space_boundary_dist(map_uv: vec2<f32>, province_id: u32, max_px: f32) -> f32 {
    let map_span = max(u.viewport.zw - u.viewport.xy, vec2<f32>(1.0, 1.0));
    let map_per_screen = map_span / max(u.screen_size, vec2<f32>(1.0, 1.0));
    let screen_per_map = vec2<f32>(1.0, 1.0) / max(map_per_screen, vec2<f32>(0.0001, 0.0001));
    let f = fract(map_uv);
    var best_dist = 9999.0;
    let max_steps_x = min(i32(ceil(max_px / max(screen_per_map.x, 0.0001))) + 1, 6);
    let max_steps_y = min(i32(ceil(max_px / max(screen_per_map.y, 0.0001))) + 1, 6);
    for (var oy = -max_steps_y; oy <= max_steps_y; oy = oy + 1) {
        for (var ox = -max_steps_x; ox <= max_steps_x; ox = ox + 1) {
            if (ox == 0 && oy == 0) {
                continue;
            }
            let offset = vec2<i32>(ox, oy);
            let dist_px = boundary_offset_dist_px(offset, f, screen_per_map);
            try_boundary_probe(map_uv, province_id, offset, dist_px, max_px, &best_dist);
        }
    }
    return best_dist;
}

fn matching_border_id_at(px: vec2<i32>, a: u32, b: u32) -> u32 {
    if (px.x < 0 || px.y < 0 || px.x >= i32(u.map_size.x) || px.y >= i32(u.map_size.y)) {
        return 0u;
    }
    let id = textureLoad(border_idx_tex, px, 0).r;
    if (id == 0u) {
        return 0u;
    }
    let bs = border_styles[id];
    if (border_pair_matches(bs, a, b)) {
        return id;
    }
    return 0u;
}

fn find_matching_border_id(map_a: vec2<f32>, map_b: vec2<f32>, a: u32, b: u32) -> u32 {
    let pa = vec2<i32>(map_a);
    let pb = vec2<i32>(map_b);
    for (var oy = -1; oy <= 1; oy = oy + 1) {
        for (var ox = -1; ox <= 1; ox = ox + 1) {
            let delta = vec2<i32>(ox, oy);
            let ida = matching_border_id_at(pa + delta, a, b);
            if (ida > 0u) {
                return ida;
            }
            let idb = matching_border_id_at(pb + delta, a, b);
            if (idb > 0u) {
                return idb;
            }
        }
    }
    return 0u;
}

fn try_border_probe(map_uv: vec2<f32>, province_id: u32, offset_map: vec2<f32>, dist_px: f32, max_px: f32, best_id: ptr<function, u32>, best_dist: ptr<function, f32>) {
    if (province_id == 0u) {
        return;
    }
    if (dist_px > max_px) {
        return;
    }
    let other_uv = map_uv + offset_map;
    let other_id = sample_province_id(other_uv);
    if (other_id == 0u) {
        return;
    }
    if (other_id == province_id) {
        return;
    }
    let border_id = find_matching_border_id(map_uv, other_uv, province_id, other_id);
    if (border_id == 0u) {
        return;
    }
    let bs = border_styles[border_id];
    if (bs.province_a == 0u || bs.province_b == 0u) {
        return;
    }
    if (province_data[bs.province_a].visibility_state == 0u || province_data[bs.province_b].visibility_state == 0u) {
        return;
    }
    if (!border_visible_in_mode(bs)) {
        return;
    }
    if (dist_px < (*best_dist)) {
        *best_id = border_id;
        *best_dist = dist_px;
    }
}

fn screen_space_border_hit(map_uv: vec2<f32>, province_id: u32, max_px: f32) -> BorderHit {
    let map_span = max(u.viewport.zw - u.viewport.xy, vec2<f32>(1.0, 1.0));
    let map_per_screen = map_span / max(u.screen_size, vec2<f32>(1.0, 1.0));
    let screen_per_map = vec2<f32>(1.0, 1.0) / max(map_per_screen, vec2<f32>(0.0001, 0.0001));
    let f = fract(map_uv);
    var best_id = 0u;
    var best_dist = 9999.0;
    let max_steps_x = min(i32(ceil(max_px / max(screen_per_map.x, 0.0001))) + 1, 8);
    let max_steps_y = min(i32(ceil(max_px / max(screen_per_map.y, 0.0001))) + 1, 8);
    for (var step = 1; step <= max_steps_x; step = step + 1) {
        let step_f = f32(step);
        try_border_probe(map_uv, province_id, vec2<f32>(step_f, 0.0), (step_f - f.x) * screen_per_map.x, max_px, &best_id, &best_dist);
        try_border_probe(map_uv, province_id, vec2<f32>(-step_f, 0.0), (f.x + step_f - 1.0) * screen_per_map.x, max_px, &best_id, &best_dist);
    }
    for (var step = 1; step <= max_steps_y; step = step + 1) {
        let step_f = f32(step);
        try_border_probe(map_uv, province_id, vec2<f32>(0.0, step_f), (step_f - f.y) * screen_per_map.y, max_px, &best_id, &best_dist);
        try_border_probe(map_uv, province_id, vec2<f32>(0.0, -step_f), (f.y + step_f - 1.0) * screen_per_map.y, max_px, &best_id, &best_dist);
    }
    let max_steps_diag = min(max_steps_x, max_steps_y);
    for (var step = 1; step <= max_steps_diag; step = step + 1) {
        let step_f = f32(step);
        try_border_probe(map_uv, province_id, vec2<f32>(step_f, step_f), length(vec2<f32>((step_f - f.x) * screen_per_map.x, (step_f - f.y) * screen_per_map.y)), max_px, &best_id, &best_dist);
        try_border_probe(map_uv, province_id, vec2<f32>(-step_f, step_f), length(vec2<f32>((f.x + step_f - 1.0) * screen_per_map.x, (step_f - f.y) * screen_per_map.y)), max_px, &best_id, &best_dist);
        try_border_probe(map_uv, province_id, vec2<f32>(step_f, -step_f), length(vec2<f32>((step_f - f.x) * screen_per_map.x, (f.y + step_f - 1.0) * screen_per_map.y)), max_px, &best_id, &best_dist);
        try_border_probe(map_uv, province_id, vec2<f32>(-step_f, -step_f), length(vec2<f32>((f.x + step_f - 1.0) * screen_per_map.x, (f.y + step_f - 1.0) * screen_per_map.y)), max_px, &best_id, &best_dist);
    }
    return BorderHit(best_id, best_dist);
}

@fragment
fn fs_main(@builtin(position) pos: vec4<f32>) -> @location(0) vec4<f32> {
    let map_uv = map_uv_from_screen(pos.xy);
    let map_px = vec2<i32>(map_uv);

    if (map_px.x < 0 || map_px.y < 0 || map_px.x >= i32(u.map_size.x) || map_px.y >= i32(u.map_size.y)) {
        return vec4<f32>(0.0, 0.0, 0.0, 1.0);
    }

    let province_id = textureLoad(province_tex, map_px, 0).r;
    if (province_id == 0u) {
        return vec4<f32>(0.0, 0.0, 0.0, 1.0);
    }

    let pd = province_data[province_id];
    if (pd.visibility_state == 0u) {
        return vec4<f32>(0.02, 0.02, 0.02, 1.0);
    }
    if (pd.visibility_state == 1u) {
        return vec4<f32>(0.2, 0.2, 0.2, 1.0);
    }

    var out_color = vec4<f32>(
        srgb_to_linear(pd.color.rgb * u.fill_tint.rgb),
        pd.color.a * u.fill_tint.a
    );

    if (province_id == u.highlight_ids.x) {
        out_color = vec4<f32>(out_color.rgb * 0.58, out_color.a);
    }
    if (province_id == u.highlight_ids.y) {
        out_color = vec4<f32>(mix(out_color.rgb, vec3<f32>(1.0, 1.0, 1.0), 0.28), out_color.a);
    }

    let edge_radius_px = edge_gradient_radius_px();
    let border_search_px = max(2.0 * map_zoom_scale(), 0.5);
    let edge_hit = screen_space_border_hit(map_uv, province_id, max(edge_radius_px, border_search_px));
    var border_hit = screen_space_border_hit(map_uv, province_id, border_search_px);
    if (u.edge_gradient_params.y > 0.0 && u.edge_gradient_params.x > 0.0) {
        let edge_dist_px = screen_space_boundary_dist(map_uv, province_id, edge_radius_px);
        let falloff = 1.0 - smoothstep(0.0, max(edge_radius_px, 0.0001), edge_dist_px);
        let edge_mix = clamp(
            falloff * falloff * u.edge_gradient_params.y * u.edge_gradient_color.a,
            0.0,
            1.0
        );
        var edge_color = srgb_to_linear(u.edge_gradient_color.rgb);
        if (pd.terrain_type == 0u) {
            let darken = clamp(1.0 - u.border_palette_params.y, 0.0, 1.0);
            edge_color = srgb_to_linear(pd.color.rgb * darken);
        }
        out_color = vec4<f32>(
            mix(out_color.rgb, edge_color, edge_mix),
            out_color.a
        );
    }

    if (!strategic_mode()) {
        if (u.terrain_texture_strength > 0.0) {
            let scale = max(u.terrain_texture_scale, 1.0);
            let terrain_uv = map_uv / vec2<f32>(scale, scale);
            let sample_color = textureSample(terrain_texture, terrain_sampler, terrain_uv);
            let watermark = (dot(sample_color.rgb, vec3<f32>(0.299, 0.587, 0.114)) - 0.5) * 2.0 * sample_color.a;
            out_color = vec4<f32>(
                clamp(out_color.rgb + vec3<f32>(watermark * u.terrain_texture_strength), vec3<f32>(0.0), vec3<f32>(1.0)),
                out_color.a
            );
        }
    }

    if (border_hit.id == 0u && edge_hit.id > 0u) {
        let edge_bs = border_styles[edge_hit.id];
        if (edge_hit.dist_px <= border_thickness_px(edge_bs)) {
            border_hit = edge_hit;
        }
    }

    if (border_hit.id > 0u) {
        let bs = border_styles[border_hit.id];
        if (border_hit.dist_px > border_thickness_px(bs)) {
            return out_color;
        }
        let border_color = border_palette_color(bs);
        let border_rgb = srgb_to_linear(border_color.rgb);
        out_color = vec4<f32>(
            mix(out_color.rgb, border_rgb, clamp(border_color.a, 0.0, 1.0)),
            out_color.a
        );
    }

    return out_color;
}
