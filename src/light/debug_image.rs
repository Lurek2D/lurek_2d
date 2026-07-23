//! Bounded CPU light-map rasterization used only for debug previews and visual evidence.
//! Scene storage, renderer snapshots, and GPU command submission remain outside this module.

use crate::image::ImageData;
use crate::light::light_world::LightWorld;
use crate::light::{FalloffMode, Light2D, LightBlendMode, LightType, ShadowFilter};
use crate::math::Vec2;

struct RenderOccluder<'a> {
    vertices: &'a [Vec2],
    position: Vec2,
    opacity: f32,
    light_mask: u16,
}

/// Rasterize an already-validated, bounded preview without cloning scene geometry.
pub(crate) fn draw(world: &LightWorld, width: u32, height: u32) -> ImageData {
    let mut img = ImageData::new(width, height);
    let ambient = [
        (world.ambient.r.clamp(0.0, 1.0) * 255.0).round(),
        (world.ambient.g.clamp(0.0, 1.0) * 255.0).round(),
        (world.ambient.b.clamp(0.0, 1.0) * 255.0).round(),
    ];
    img.fill(ambient[0] as u8, ambient[1] as u8, ambient[2] as u8, 255);
    if !world.enabled {
        return img;
    }

    let lights: Vec<&Light2D> = world
        .selected_render_lights()
        .into_iter()
        .filter(|(_, light)| light.intensity > 0.0)
        .map(|(_, light)| light)
        .collect();
    let occluders: Vec<RenderOccluder<'_>> = world
        .occluders
        .values()
        .filter(|occ| occ.enabled && occ.opacity > 0.0 && occ.is_render_valid())
        .map(|occ| RenderOccluder {
            vertices: &occ.vertices,
            position: occ.position,
            opacity: occ.opacity.clamp(0.0, 1.0),
            light_mask: occ.light_mask,
        })
        .collect();
    if lights.is_empty() && occluders.is_empty() {
        return img;
    }

    for y in 0..height {
        for x in 0..width {
            let mut fr = ambient[0];
            let mut fg = ambient[1];
            let mut fb = ambient[2];
            let point = Vec2::new(x as f32 + 0.5, y as f32 + 0.5);
            for light in &lights {
                let mut amount = light_intensity_at(light, point);
                if amount <= 0.0 {
                    continue;
                }
                amount *= shadow_visibility(light, point, &occluders);
                if amount > 0.0 {
                    blend_light(&mut fr, &mut fg, &mut fb, light, amount);
                }
            }
            img.set_pixel(
                x,
                y,
                fr.clamp(0.0, 255.0) as u8,
                fg.clamp(0.0, 255.0) as u8,
                fb.clamp(0.0, 255.0) as u8,
                255,
            );
        }
    }
    for occ in &occluders {
        for edge in occ.vertices.windows(2) {
            draw_occluder_edge(
                &mut img,
                translated(edge[0], occ.position),
                translated(edge[1], occ.position),
            );
        }
        if let (Some(first), Some(last)) = (occ.vertices.first(), occ.vertices.last()) {
            draw_occluder_edge(
                &mut img,
                translated(*last, occ.position),
                translated(*first, occ.position),
            );
        }
    }
    for light in &lights {
        img.draw_circle(light.x as i32, light.y as i32, 4, 255, 240, 100, 255);
    }
    img
}

fn translated(vertex: Vec2, position: Vec2) -> Vec2 {
    Vec2::new(vertex.x + position.x, vertex.y + position.y)
}

fn light_intensity_at(light: &Light2D, point: Vec2) -> f32 {
    let dx = point.x - light.x;
    let dy = point.y - light.y;
    let distance = (dx * dx + dy * dy).sqrt();
    let radial = match light.light_type {
        LightType::Directional => 1.0,
        LightType::Point | LightType::Spot => {
            if distance > light.radius {
                return 0.0;
            }
            radial_falloff(light.falloff, distance / light.radius)
        }
    };
    let angular = match light.light_type {
        LightType::Spot => spot_factor(
            light.direction,
            light.inner_angle,
            light.outer_angle,
            dx,
            dy,
        ),
        LightType::Point | LightType::Directional => 1.0,
    };
    radial
        * angular
        * light.attenuation.factor(distance)
        * light.intensity
        * light.energy
        * light.flicker.multiplier()
}

fn radial_falloff(mode: FalloffMode, t: f32) -> f32 {
    let t = t.clamp(0.0, 1.0);
    match mode {
        FalloffMode::Linear => 1.0 - t,
        FalloffMode::Smooth => 1.0 - (t * t * (3.0 - 2.0 * t)),
        FalloffMode::Constant => 1.0,
    }
}

fn spot_factor(direction: f32, inner_angle: f32, outer_angle: f32, dx: f32, dy: f32) -> f32 {
    let diff = angle_delta(dy.atan2(dx), direction).abs();
    let inner = inner_angle.max(0.0);
    let outer = outer_angle.max(inner + f32::EPSILON);
    if diff <= inner {
        1.0
    } else if diff >= outer {
        0.0
    } else {
        1.0 - ((diff - inner) / (outer - inner))
    }
}

fn angle_delta(a: f32, b: f32) -> f32 {
    (a - b + std::f32::consts::PI).rem_euclid(std::f32::consts::TAU) - std::f32::consts::PI
}

fn shadow_visibility(light: &Light2D, point: Vec2, occluders: &[RenderOccluder<'_>]) -> f32 {
    if !light.shadow_enabled || occluders.is_empty() {
        return 1.0;
    }
    let offsets = shadow_sample_offsets(light.shadow_filter);
    let radius = match light.shadow_filter {
        ShadowFilter::None => 0.0,
        ShadowFilter::Pcf5 | ShadowFilter::Pcf13 => {
            (light.shadow_smooth * light.shadow_softness).max(0.0)
        }
    };
    offsets
        .iter()
        .map(|&(ox, oy)| {
            hard_shadow_visibility(
                light,
                Vec2::new(point.x + ox * radius, point.y + oy * radius),
                occluders,
            )
        })
        .sum::<f32>()
        / offsets.len() as f32
}

fn shadow_sample_offsets(filter: ShadowFilter) -> &'static [(f32, f32)] {
    match filter {
        ShadowFilter::None => &[(0.0, 0.0)],
        ShadowFilter::Pcf5 => &[(0.0, 0.0), (1.0, 0.0), (-1.0, 0.0), (0.0, 1.0), (0.0, -1.0)],
        ShadowFilter::Pcf13 => &[
            (0.0, 0.0),
            (1.0, 0.0),
            (-1.0, 0.0),
            (0.0, 1.0),
            (0.0, -1.0),
            (0.7, 0.7),
            (-0.7, 0.7),
            (0.7, -0.7),
            (-0.7, -0.7),
            (2.0, 0.0),
            (-2.0, 0.0),
            (0.0, 2.0),
            (0.0, -2.0),
        ],
    }
}

fn hard_shadow_visibility(light: &Light2D, point: Vec2, occluders: &[RenderOccluder<'_>]) -> f32 {
    let origin = Vec2::new(light.x, light.y);
    let mut blocked = 0.0_f32;
    for occ in occluders {
        if light.shadow_mask & occ.light_mask == 0
            || point_in_polygon(origin, occ.vertices, occ.position)
        {
            continue;
        }
        if point_in_polygon(point, occ.vertices, occ.position)
            || segment_hits_polygon(origin, point, occ.vertices, occ.position)
        {
            blocked = blocked.max(occ.opacity);
        }
    }
    1.0 - blocked.clamp(0.0, 1.0)
}

fn point_in_polygon(point: Vec2, vertices: &[Vec2], position: Vec2) -> bool {
    let mut inside = false;
    let mut j = vertices.len() - 1;
    for i in 0..vertices.len() {
        let vi = translated(vertices[i], position);
        let vj = translated(vertices[j], position);
        if (vi.y > point.y) != (vj.y > point.y)
            && point.x < (vj.x - vi.x) * (point.y - vi.y) / (vj.y - vi.y) + vi.x
        {
            inside = !inside;
        }
        j = i;
    }
    inside
}

fn segment_hits_polygon(origin: Vec2, point: Vec2, vertices: &[Vec2], position: Vec2) -> bool {
    (0..vertices.len()).any(|i| {
        segments_intersect(
            origin,
            point,
            translated(vertices[i], position),
            translated(vertices[(i + 1) % vertices.len()], position),
        )
    })
}

fn segments_intersect(a: Vec2, b: Vec2, c: Vec2, d: Vec2) -> bool {
    let r = Vec2::new(b.x - a.x, b.y - a.y);
    let s = Vec2::new(d.x - c.x, d.y - c.y);
    let denom = cross(r, s);
    if denom.abs() < 1e-5 {
        return false;
    }
    let cma = Vec2::new(c.x - a.x, c.y - a.y);
    let t = cross(cma, s) / denom;
    let u = cross(cma, r) / denom;
    t > 1e-4 && t < 1.0 - 1e-4 && (0.0..=1.0).contains(&u)
}

fn cross(a: Vec2, b: Vec2) -> f32 {
    a.x * b.y - a.y * b.x
}

fn blend_light(fr: &mut f32, fg: &mut f32, fb: &mut f32, light: &Light2D, amount: f32) {
    let r = light.color.r.clamp(0.0, 1.0) * amount * 255.0;
    let g = light.color.g.clamp(0.0, 1.0) * amount * 255.0;
    let b = light.color.b.clamp(0.0, 1.0) * amount * 255.0;
    match light.blend_mode {
        LightBlendMode::Add => {
            *fr += r;
            *fg += g;
            *fb += b;
        }
        LightBlendMode::Sub => {
            *fr -= r;
            *fg -= g;
            *fb -= b;
        }
        LightBlendMode::Mix => {
            let alpha = amount.clamp(0.0, 1.0);
            *fr = *fr * (1.0 - alpha) + r * alpha;
            *fg = *fg * (1.0 - alpha) + g * alpha;
            *fb = *fb * (1.0 - alpha) + b * alpha;
        }
    }
}

fn draw_occluder_edge(img: &mut ImageData, a: Vec2, b: Vec2) {
    img.draw_line(
        a.x.round() as i32,
        a.y.round() as i32,
        b.x.round() as i32,
        b.y.round() as i32,
        36,
        38,
        46,
        255,
    );
}
