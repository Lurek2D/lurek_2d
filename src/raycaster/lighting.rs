//! Static and dynamic point lighting for raycaster worlds.
//!
//! Provides simple ambient + point-light illumination suitable for retro FPS
//! and dungeon-crawler style environments.

/// Point light source in the raycaster world.
///
/// # Fields
/// - `x` — `f32`.
/// - `y` — `f32`.
/// - `radius` — `f32`.
/// - `intensity` — `f32`.
/// - `color` — `[f32; 3]`.
#[derive(Debug, Clone)]
pub struct PointLight {
    /// World-space X position.
    pub x: f32,
    /// World-space Y position.
    pub y: f32,
    /// Maximum illumination radius.
    pub radius: f32,
    /// Light intensity multiplier.
    pub intensity: f32,
    /// RGB color components, each in [0, 1].
    pub color: [f32; 3],
}

/// Computes ambient + point-light illumination at a world position.
///
/// Each light contributes based on inverse-distance falloff within its radius.
/// The result is the sum of ambient light and all point-light contributions,
/// clamped per-channel to [0, 1].
///
/// # Parameters
/// - `x` — `f32`.
/// - `y` — `f32`.
/// - `ambient` — `f32`.
/// - `lights` — `&[PointLight]`.
///
/// # Returns
/// `[f32; 3]`.
pub fn compute_lighting(x: f32, y: f32, ambient: f32, lights: &[PointLight]) -> [f32; 3] {
    let mut r = ambient;
    let mut g = ambient;
    let mut b = ambient;

    for light in lights {
        let dx = x - light.x;
        let dy = y - light.y;
        let dist = (dx * dx + dy * dy).sqrt();

        if dist >= light.radius {
            continue;
        }

        let attenuation = (1.0 - dist / light.radius) * light.intensity;
        r += light.color[0] * attenuation;
        g += light.color[1] * attenuation;
        b += light.color[2] * attenuation;
    }

    [r.clamp(0.0, 1.0), g.clamp(0.0, 1.0), b.clamp(0.0, 1.0)]
}

/// Applies lighting to a distance-shaded base brightness.
///
/// Multiplies the base shade value by each channel of the light color,
/// producing a final lit RGB value.
///
/// # Parameters
/// - `base_shade` — `f32`.
/// - `light_color` — `[f32; 3]`.
///
/// # Returns
/// `[f32; 3]`.
pub fn apply_lit_shade(base_shade: f32, light_color: [f32; 3]) -> [f32; 3] {
    [
        (base_shade * light_color[0]).clamp(0.0, 1.0),
        (base_shade * light_color[1]).clamp(0.0, 1.0),
        (base_shade * light_color[2]).clamp(0.0, 1.0),
    ]
}
