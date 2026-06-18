//! This file owns `PointLight` plus local and global lighting helpers for colored illumination in raycaster space.
//! It stores point-light position, optional level ownership, radius, intensity, and color for cheap sample evaluation.
//! Helper functions test line of sight through walls, accumulate ambient and point light, and apply directional sun tint.
//! Scene builders reuse these lighting samples to shade walls, floors, sprites, and multilevel slices without light graphs.
//! Open this file when raycaster light semantics change; hit casting and wall feature payloads live in sibling owners.

/// A point light placed in world space that contributes to tile-level lighting.
#[derive(Debug, Clone)]
pub struct PointLight {
    /// World X position of the light source.
    pub x: f32,
    /// World Y position of the light source.
    pub y: f32,
    /// Optional multilevel slice index that owns this light. `None` means the light affects every level.
    pub level_index: Option<usize>,
    /// Maximum tile distance at which this light contributes, in tiles.
    pub radius: f32,
    /// Brightness multiplier applied to the light contribution.
    pub intensity: f32,
    /// RGB color of the light, each channel in 0.0..1.0.
    pub color: [f32; 3],
}

impl PointLight {
    /// Return true when this light should contribute to `level_index`.
    pub fn applies_to_level(&self, level_index: usize) -> bool {
        self.level_index
            .map(|owner| owner == level_index)
            .unwrap_or(true)
    }
}
/// Return true when the grid path from `(x0,y0)` to `(x1,y1)` contains no wall tile (Bresenham traversal).
fn has_line_of_sight(
    x0: i32,
    y0: i32,
    x1: i32,
    y1: i32,
    wall_at: &dyn Fn(i32, i32) -> bool,
) -> bool {
    let mut x = x0;
    let mut y = y0;
    let dx = (x1 - x0).abs();
    let dy = (y1 - y0).abs();
    let sx = if x0 < x1 { 1i32 } else { -1 };
    let sy = if y0 < y1 { 1i32 } else { -1 };
    let mut err = dx - dy;
    loop {
        if x == x1 && y == y1 {
            break;
        }
        let e2 = 2 * err;
        if e2 > -dy {
            err -= dy;
            x += sx;
        }
        if e2 < dx {
            err += dx;
            y += sy;
        }
        if (x != x1 || y != y1) && wall_at(x, y) {
            return false;
        }
    }
    true
}
/// Accumulate ambient and point-light contributions at world position `(x, y)`; return clamped `[r, g, b]`.
pub fn compute_lighting(
    x: f32,
    y: f32,
    ambient: f32,
    lights: &[PointLight],
    wall_at: &dyn Fn(i32, i32) -> bool,
) -> [f32; 3] {
    let mut r = ambient;
    let mut g = ambient;
    let mut b = ambient;
    let tx = x.floor() as i32;
    let ty = y.floor() as i32;
    for light in lights {
        let dx = x - light.x;
        let dy = y - light.y;
        let tile_dist = (dx * dx + dy * dy).sqrt().floor();
        if tile_dist >= light.radius {
            continue;
        }
        let lx = light.x.floor() as i32;
        let ly = light.y.floor() as i32;
        if !has_line_of_sight(tx, ty, lx, ly, wall_at) {
            continue;
        }
        let attenuation = (light.radius - tile_dist) / light.radius * (light.intensity / 16.0);
        r += light.color[0] * attenuation;
        g += light.color[1] * attenuation;
        b += light.color[2] * attenuation;
    }
    [r.clamp(0.0, 1.0), g.clamp(0.0, 1.0), b.clamp(0.0, 1.0)]
}

fn directional_sun_visible(
    x: f32,
    y: f32,
    sun_angle: f32,
    shadow_distance: f32,
    wall_at: &dyn Fn(i32, i32) -> bool,
) -> bool {
    if shadow_distance <= 0.0 {
        return true;
    }
    let tx = x.floor() as i32;
    let ty = y.floor() as i32;
    let target_x = (x + sun_angle.cos() * shadow_distance).floor() as i32;
    let target_y = (y + sun_angle.sin() * shadow_distance).floor() as i32;
    if tx == target_x && ty == target_y {
        return true;
    }
    has_line_of_sight(tx, ty, target_x, target_y, wall_at)
}

/// Apply global tint and optional directional sun to an already accumulated local lighting sample.
#[allow(clippy::too_many_arguments)]
pub fn apply_global_light(
    light_rgb: [f32; 3],
    x: f32,
    y: f32,
    roofed: bool,
    global_color: [f32; 3],
    global_intensity: f32,
    sun_angle: Option<f32>,
    shadow_distance: f32,
    wall_at: &dyn Fn(i32, i32) -> bool,
) -> [f32; 3] {
    let tinted = [
        (light_rgb[0] * global_color[0] * global_intensity).clamp(0.0, 1.0),
        (light_rgb[1] * global_color[1] * global_intensity).clamp(0.0, 1.0),
        (light_rgb[2] * global_color[2] * global_intensity).clamp(0.0, 1.0),
    ];
    let Some(sun_angle) = sun_angle else {
        return tinted;
    };
    if roofed || global_intensity <= 0.0 {
        return tinted;
    }
    if !directional_sun_visible(x, y, sun_angle, shadow_distance, wall_at) {
        return tinted;
    }
    let direct_scale = (global_intensity * 0.6).clamp(0.0, 1.0);
    [
        (tinted[0] + global_color[0] * direct_scale).clamp(0.0, 1.0),
        (tinted[1] + global_color[1] * direct_scale).clamp(0.0, 1.0),
        (tinted[2] + global_color[2] * direct_scale).clamp(0.0, 1.0),
    ]
}
/// Multiply `base_shade` by each channel of `light_color`; return clamped `[r, g, b]`.
pub fn apply_lit_shade(base_shade: f32, light_color: [f32; 3]) -> [f32; 3] {
    [
        (base_shade * light_color[0]).clamp(0.0, 1.0),
        (base_shade * light_color[1]).clamp(0.0, 1.0),
        (base_shade * light_color[2]).clamp(0.0, 1.0),
    ]
}
