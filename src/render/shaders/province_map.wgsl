struct ProvinceData {
    color: vec4<f32>,
    terrain_type: u32,
    border_style: u32,
    fog_state: u32,
    visibility_state: u32,
    visual_u32: vec4<u32>,
    visual_f32: vec4<f32>,
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
    border_noise_params: vec4<f32>,
    water_params: vec4<f32>,
    weather_params: vec4<f32>,
    fog_params: vec4<f32>,
    fog_hidden_color: vec4<f32>,
    climate_params: vec4<f32>,
    highlight_ids: vec4<u32>,
    effect_seeds: vec4<u32>,
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

fn hash_u32(value: u32) -> u32 {
    var x = value;
    x = x ^ 2747636419u;
    x = x * 2654435769u;
    x = x ^ (x >> 16u);
    x = x * 2654435769u;
    x = x ^ (x >> 16u);
    x = x * 2654435769u;
    return x;
}

fn hash_noise(seed: u32, p: vec2<f32>) -> f32 {
    let ix = u32(i32(floor(p.x * 4096.0)));
    let iy = u32(i32(floor(p.y * 4096.0)));
    let mixed = seed ^ hash_u32(ix + 0x9E3779B9u) ^ hash_u32(iy + 0x85EBCA77u);
    return f32(hash_u32(mixed)) / 4294967295.0;
}

fn noise2(seed: u32, p: vec2<f32>) -> f32 {
    let base = floor(p);
    let frac = fract(p);
    let n00 = hash_noise(seed, base);
    let n10 = hash_noise(seed, base + vec2<f32>(1.0, 0.0));
    let n01 = hash_noise(seed, base + vec2<f32>(0.0, 1.0));
    let n11 = hash_noise(seed, base + vec2<f32>(1.0, 1.0));
    let u2 = frac * frac * (vec2<f32>(3.0, 3.0) - 2.0 * frac);
    let nx0 = mix(n00, n10, u2.x);
    let nx1 = mix(n01, n11, u2.x);
    return mix(nx0, nx1, u2.y);
}

fn fbm(seed: u32, p: vec2<f32>) -> f32 {
    var value = 0.0;
    var amplitude = 0.5;
    var frequency = 1.0;
    for (var i = 0u; i < 4u; i = i + 1u) {
        value = value + noise2(seed + i * 977u, p * frequency) * amplitude;
        frequency = frequency * 2.0;
        amplitude = amplitude * 0.5;
    }
    return value;
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

fn province_climate_type(pd: ProvinceData) -> u32 {
    return pd.visual_u32.x;
}

fn province_weather_type(pd: ProvinceData) -> u32 {
    return pd.visual_u32.y;
}

fn province_effect_flags(pd: ProvinceData) -> u32 {
    return pd.visual_u32.z;
}

fn province_visual_seed(pd: ProvinceData) -> u32 {
    return pd.visual_u32.w;
}

fn province_weather_strength(pd: ProvinceData) -> f32 {
    return clamp(pd.visual_f32.x, 0.0, 1.0);
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
    let flag_war = (bs.flags & 0x04u) != 0u;
    let flag_coast = (bs.flags & 0x10u) != 0u;
    let flag_sea = (bs.flags & 0x20u) != 0u;
    let flag_explicit = (bs.flags & 0x80u) != 0u;
    var out_color = bs.color;
    if (u.border_palette_params.x < 0.5 || flag_explicit) {
        out_color = bs.color;
    } else if (flag_country) {
        out_color = u.country_border_color;
    } else if (flag_coast) {
        out_color = u.coast_border_color;
    } else if (flag_sea) {
        let a = province_data[bs.province_a].color;
        let b = province_data[bs.province_b].color;
        let darken = clamp(1.0 - u.border_palette_params.y, 0.0, 1.0);
        out_color = vec4<f32>(mix(a.rgb, b.rgb, 0.5) * darken, u.province_border_color.a);
    } else {
        out_color = u.province_border_color;
    }
    if (flag_war) {
        let pulse = 0.55 + 0.45 * sin(u.time * 4.0 + f32(bs.province_a + bs.province_b) * 0.08);
        let warm = vec3<f32>(1.0, 0.84, 0.35);
        out_color = vec4<f32>(mix(out_color.rgb, warm, pulse * 0.35), out_color.a);
    }
    return out_color;
}

fn border_pattern_alpha(bs: BorderStyle, map_uv: vec2<f32>) -> f32 {
    var alpha = 1.0;
    let path = map_uv.x * 0.31 + map_uv.y * 0.37 + f32(bs.province_a + bs.province_b) * 0.013;
    if ((bs.flags & 0x02u) != 0u) {
        let dash = fract(path * 1.8);
        alpha = alpha * select(0.0, 1.0, dash < 0.55);
    }
    if ((bs.flags & 0x08u) != 0u) {
        let dash = fract(path * 1.35 + 0.17);
        alpha = alpha * select(0.0, 1.0, dash < 0.72);
    }
    if ((bs.flags & 0x04u) != 0u) {
        alpha = alpha * (0.65 + 0.35 * sin(u.time * 3.6 + path * 8.0));
    }
    return alpha;
}

fn border_alpha(bs: BorderStyle, map_uv: vec2<f32>, dist_px: f32) -> f32 {
    let base_thickness = border_thickness_px(bs);
    let softness = max(u.border_noise_params.z, 0.001);
    let pattern = border_pattern_alpha(bs, map_uv);
    if (u.border_noise_params.w < 0.5 || u.border_noise_params.y <= 0.0) {
        return (1.0 - smoothstep(base_thickness - softness, base_thickness + softness, dist_px)) * pattern;
    }
    let seed = u.effect_seeds.x ^ bs.province_a * 1664525u ^ bs.province_b * 1013904223u;
    let freq = max(u.border_noise_params.x, 0.001);
    let noise_value = fbm(seed, map_uv * freq * 14.0);
    let jitter = (noise_value - 0.5) * u.border_noise_params.y * border_noise_lod_fade();
    let noisy_thickness = max(base_thickness + jitter, 0.0);
    return (1.0 - smoothstep(noisy_thickness - softness, noisy_thickness + softness, dist_px)) * pattern;
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

fn border_noise_lod_fade() -> f32 {
    return clamp((map_zoom_scale() - 0.45) / 1.6, 0.0, 1.0);
}

fn weather_seed(pd: ProvinceData, salt: u32) -> u32 {
    return province_visual_seed(pd) ^ salt;
}

fn climate_tint(climate_type: u32) -> vec3<f32> {
    if (climate_type == 1u) {
        return vec3<f32>(0.62, 0.76, 0.94);
    }
    if (climate_type == 2u) {
        return vec3<f32>(0.84, 0.9, 0.98);
    }
    if (climate_type == 3u) {
        return vec3<f32>(0.72, 0.84, 0.9);
    }
    if (climate_type == 4u) {
        return vec3<f32>(0.82, 0.9, 0.78);
    }
    if (climate_type == 5u) {
        return vec3<f32>(0.78, 0.82, 0.72);
    }
    if (climate_type == 6u) {
        return vec3<f32>(0.74, 0.88, 0.72);
    }
    if (climate_type == 7u) {
        return vec3<f32>(0.9, 0.8, 0.58);
    }
    if (climate_type == 8u) {
        return vec3<f32>(0.84, 0.82, 0.66);
    }
    if (climate_type == 9u) {
        return vec3<f32>(0.74, 0.76, 0.78);
    }
    if (climate_type == 10u) {
        return vec3<f32>(0.66, 0.64, 0.56);
    }
    return vec3<f32>(1.0, 1.0, 1.0);
}

fn apply_climate_tint(color: vec3<f32>, pd: ProvinceData) -> vec3<f32> {
    if (u.climate_params.w < 0.5 || u.climate_params.x <= 0.0) {
        return color;
    }
    let climate_type = province_climate_type(pd);
    if (climate_type == 0u) {
        return color;
    }
    let season_wave = 0.5 + 0.5 * sin((u.climate_params.y + f32(climate_type) * 0.043) * 6.2831853);
    let mix_amount = clamp(u.climate_params.x + season_wave * u.climate_params.z, 0.0, 1.0);
    let tint = srgb_to_linear(climate_tint(climate_type));
    return mix(color, tint, mix_amount * 0.35);
}

fn apply_water_overlay(color: vec3<f32>, pd: ProvinceData, map_uv: vec2<f32>, edge_hit: BorderHit) -> vec3<f32> {
    let strength = u.water_params.x;
    let flags = province_effect_flags(pd);
    let allow_water = pd.terrain_type == 0u || (flags & 0x01u) != 0u;
    if (strength <= 0.0 || !allow_water) {
        return color;
    }
    let scale = max(u.water_params.z, 1.0);
    let seed = weather_seed(pd, 0x51F2A3C5u);
    let wave_uv = map_uv / vec2<f32>(scale, scale) + vec2<f32>(u.time * u.water_params.y * 0.35, -u.time * u.water_params.y * 0.2);
    let wave = fbm(seed, wave_uv * 1.6);
    let shimmer = (wave - 0.5) * strength * 0.28;
    var out_color = clamp(
        color + vec3<f32>(shimmer * 0.3, shimmer * 0.42, shimmer * 0.65),
        vec3<f32>(0.0),
        vec3<f32>(1.0)
    );
    if (edge_hit.id > 0u) {
        let bs = border_styles[edge_hit.id];
        let coast = (bs.flags & 0x10u) != 0u;
        let foam_enabled = coast || (flags & 0x10u) != 0u;
        if (foam_enabled) {
            let foam = 1.0 - smoothstep(0.0, max(border_thickness_px(bs) * 2.2, 1.0), edge_hit.dist_px);
            let foam_color = srgb_to_linear(vec3<f32>(0.9, 0.96, 1.0));
            out_color = mix(out_color, foam_color, foam * strength * 0.22);
        }
    }
    return out_color;
}

fn apply_weather_overlay(color: vec3<f32>, pd: ProvinceData, map_uv: vec2<f32>) -> vec3<f32> {
    let strength = clamp(province_weather_strength(pd) * u.weather_params.x, 0.0, 1.0);
    if (strength <= 0.0) {
        return color;
    }
    let weather_type = province_weather_type(pd);
    let seed = weather_seed(pd, 0x13579BDFu);
    let dir = normalize(max(abs(u.weather_params.zw), vec2<f32>(0.001, 0.001))) * sign(u.weather_params.zw);
    let flow_uv = map_uv * 0.08 + dir * u.time * max(u.weather_params.y, 0.0) * 0.35;
    let coarse = fbm(seed, flow_uv);
    let fine = fbm(seed ^ 0xA531C28Fu, flow_uv * 3.1);
    if (weather_type == 1u) {
        let streaks = smoothstep(0.62, 0.92, fine);
        return clamp(
            color * (1.0 - strength * 0.12) + srgb_to_linear(vec3<f32>(0.55, 0.68, 0.9)) * streaks * strength * 0.08,
            vec3<f32>(0.0),
            vec3<f32>(1.0)
        );
    }
    if (weather_type == 2u) {
        let flakes = smoothstep(0.7, 0.96, fine);
        return clamp(
            mix(color, srgb_to_linear(vec3<f32>(0.96, 0.97, 1.0)), strength * 0.18)
                + vec3<f32>(flakes * strength * 0.1),
            vec3<f32>(0.0),
            vec3<f32>(1.0)
        );
    }
    if (weather_type == 3u) {
        let flash = select(0.0, 1.0, noise2(seed ^ 0x7F4A7C15u, vec2<f32>(u.time * 0.4, f32(province_visual_seed(pd)) * 0.001)) > 0.92);
        let flash_mix = flash * strength * 0.22;
        return clamp(
            mix(color, srgb_to_linear(vec3<f32>(0.18, 0.22, 0.28)), strength * 0.25)
                + vec3<f32>(flash_mix),
            vec3<f32>(0.0),
            vec3<f32>(1.0)
        );
    }
    if (weather_type == 4u) {
        let haze = (coarse - 0.5) * strength * 0.12;
        let gray = vec3<f32>(dot(color, vec3<f32>(0.299, 0.587, 0.114)));
        return clamp(mix(color, gray, strength * 0.28) + vec3<f32>(haze), vec3<f32>(0.0), vec3<f32>(1.0));
    }
    if (weather_type == 5u) {
        let dust = smoothstep(0.45, 0.88, coarse);
        return clamp(
            mix(color, srgb_to_linear(vec3<f32>(0.82, 0.68, 0.46)), strength * 0.24)
                + srgb_to_linear(vec3<f32>(0.9, 0.78, 0.55)) * dust * strength * 0.08,
            vec3<f32>(0.0),
            vec3<f32>(1.0)
        );
    }
    if (weather_type == 6u || (province_effect_flags(pd) & 0x08u) != 0u) {
        let shimmer = sin((map_uv.x + map_uv.y) * 0.18 + u.time * 5.0) * strength * 0.03;
        return clamp(color + vec3<f32>(shimmer, shimmer * 0.6, 0.0), vec3<f32>(0.0), vec3<f32>(1.0));
    }
    if (weather_type == 7u) {
        let ash = smoothstep(0.42, 0.82, coarse);
        return clamp(
            mix(color, srgb_to_linear(vec3<f32>(0.52, 0.5, 0.48)), strength * 0.24)
                + vec3<f32>(ash * strength * 0.05),
            vec3<f32>(0.0),
            vec3<f32>(1.0)
        );
    }
    return color;
}

fn apply_stripe_overlay(color: vec3<f32>, pd: ProvinceData, map_uv: vec2<f32>) -> vec3<f32> {
    if ((province_effect_flags(pd) & 0x20u) == 0u) {
        return color;
    }
    let screen_uv = map_uv * max(screen_per_map_min(), 1.0);
    let seed = province_visual_seed(pd);
    let diag =
        select(screen_uv.x + screen_uv.y, screen_uv.x - screen_uv.y, (seed & 0x01u) != 0u);
    let stripe_spacing_px = 16.0;
    let stripe_width_px = 4.0;
    let stripe_phase = fract((diag + f32(seed % 31u)) / stripe_spacing_px);
    let stripe_dist = abs(stripe_phase - 0.5);
    let half_width = stripe_width_px / stripe_spacing_px * 0.5;
    let stripe_mask = 1.0 - smoothstep(half_width, half_width + 0.08, stripe_dist);
    let stripe_color = srgb_to_linear(vec3<f32>(0.22, 0.03, 0.03));
    return mix(color, stripe_color, stripe_mask * 0.38);
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
    let fog_enabled = u.fog_params.z > 0.5;
    if (pd.visibility_state == 0u) {
        if (!fog_enabled) {
            return vec4<f32>(0.02, 0.02, 0.02, 1.0);
        }
        let hidden_noise =
            (fbm(weather_seed(pd, 0xAA55AA55u), map_uv * 0.045 + vec2<f32>(u.time * 0.015, 0.0)) - 0.5)
            * u.fog_params.y;
        let hidden_rgb = clamp(
            srgb_to_linear(u.fog_hidden_color.rgb) + vec3<f32>(hidden_noise * 0.08),
            vec3<f32>(0.0),
            vec3<f32>(1.0)
        );
        return vec4<f32>(hidden_rgb, u.fog_hidden_color.a);
    }

    var out_color = vec4<f32>(
        srgb_to_linear(pd.color.rgb * u.fill_tint.rgb),
        pd.color.a * u.fill_tint.a
    );

    let edge_radius_px = edge_gradient_radius_px();
    let border_search_px = max(2.0 * map_zoom_scale(), 0.5);
    let edge_hit = screen_space_border_hit(map_uv, province_id, max(edge_radius_px, border_search_px));
    var border_hit = screen_space_border_hit(map_uv, province_id, border_search_px);

    out_color = vec4<f32>(apply_climate_tint(out_color.rgb, pd), out_color.a);

    if (!strategic_mode()) {
        if (u.terrain_texture_strength > 0.0 && pd.terrain_type > 0u) {
            let scale = max(u.terrain_texture_scale, 1.0);
            let repeated_uv = fract(map_uv / vec2<f32>(scale, scale));
            let atlas_tiles = 6.0;
            let terrain_slot = clamp(i32(pd.terrain_type), 1, 5) - 1;
            let terrain_uv = vec2<f32>((repeated_uv.x + f32(terrain_slot)) / atlas_tiles, repeated_uv.y);
            let sample_color = textureSample(terrain_texture, terrain_sampler, terrain_uv);
            let watermark_mask = clamp(sample_color.a * 1.35, 0.0, 1.0);
            let watermark_mix = clamp(watermark_mask * u.terrain_texture_strength * 3.8, 0.0, 1.0);
            let watermark_ink = clamp(out_color.rgb * vec3<f32>(0.72, 0.73, 0.70), vec3<f32>(0.0), vec3<f32>(1.0));
            out_color = vec4<f32>(
                mix(out_color.rgb, watermark_ink, watermark_mix),
                out_color.a
            );
        }
    }

    out_color = vec4<f32>(apply_water_overlay(out_color.rgb, pd, map_uv, edge_hit), out_color.a);
    out_color = vec4<f32>(apply_weather_overlay(out_color.rgb, pd, map_uv), out_color.a);
    out_color = vec4<f32>(apply_stripe_overlay(out_color.rgb, pd, map_uv), out_color.a);

    if (pd.visibility_state == 1u) {
        if (!fog_enabled) {
            return vec4<f32>(0.2, 0.2, 0.2, 1.0);
        }
        let gray = vec3<f32>(dot(out_color.rgb, vec3<f32>(0.299, 0.587, 0.114)));
        let desat = mix(out_color.rgb, gray, clamp(u.fog_params.x, 0.0, 1.0));
        let fog_noise =
            (fbm(weather_seed(pd, 0xCAFEBABEu), map_uv * 0.05 + vec2<f32>(0.0, u.time * 0.01)) - 0.5)
            * u.fog_params.y;
        out_color = vec4<f32>(
            clamp(
                mix(desat, desat * 0.82, 0.35) + vec3<f32>(fog_noise * 0.08),
                vec3<f32>(0.0),
                vec3<f32>(1.0)
            ),
            out_color.a
        );
    } else if (fog_enabled && pd.fog_state > 0u) {
        let fog_strength = clamp(f32(pd.fog_state) / 255.0, 0.0, 1.0);
        let fog_noise =
            (fbm(weather_seed(pd, 0xDEADBEEFu), map_uv * 0.055 + vec2<f32>(u.time * 0.02, -u.time * 0.01)) - 0.5)
            * max(u.fog_params.y, 0.05);
        let gray = vec3<f32>(dot(out_color.rgb, vec3<f32>(0.299, 0.587, 0.114)));
        out_color = vec4<f32>(
            clamp(
                mix(out_color.rgb, mix(gray, out_color.rgb, 0.35), fog_strength * 0.35)
                    + vec3<f32>(fog_noise * 0.06 + fog_strength * 0.03),
                vec3<f32>(0.0),
                vec3<f32>(1.0)
            ),
            out_color.a
        );
    }

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

    if (border_hit.id == 0u && edge_hit.id > 0u) {
        let edge_bs = border_styles[edge_hit.id];
        if (edge_hit.dist_px <= border_thickness_px(edge_bs)) {
            border_hit = edge_hit;
        }
    }

    if (border_hit.id > 0u) {
        let bs = border_styles[border_hit.id];
        let border_color = border_palette_color(bs);
        let border_rgb = srgb_to_linear(border_color.rgb);
        let border_mix =
            clamp(border_color.a, 0.0, 1.0) * clamp(border_alpha(bs, map_uv, border_hit.dist_px), 0.0, 1.0);
        out_color = vec4<f32>(
            mix(out_color.rgb, border_rgb, border_mix),
            out_color.a
        );
    }

    if (province_id == u.highlight_ids.x) {
        out_color = vec4<f32>(
            mix(out_color.rgb, srgb_to_linear(vec3<f32>(1.0, 0.86, 0.24)), 0.28),
            out_color.a
        );
    }
    if (province_id == u.highlight_ids.y) {
        out_color = vec4<f32>(
            mix(out_color.rgb, vec3<f32>(1.0, 1.0, 1.0), 0.2),
            out_color.a
        );
    }

    return out_color;
}
