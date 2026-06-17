//! Provides globe lighting helpers that derive sun direction and regional light intensity over time. `globe/lighting` delivers the lighting implementation for the globe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Computes diffuse contribution with ambient floors to keep night-side visuals readable. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Supports batch intensity and terminator blending calculations for smooth day-night transitions. Public callable behavior is centered on `sun_direction`, `province_intensity`, `compute_intensities`, `terminator_alpha`, while method-level behavior such as no named public items stays attached to the local data model and invariants.

use super::sphere::{lat_lon_to_unit, rot_y};
use crate::globe::types::GlobeSpec;
use crate::math::Vec3;
/// Compute the sun direction in world space from globe rotation and time of day.
pub fn sun_direction(spec: &GlobeSpec) -> Vec3 {
    let time_hours = spec.time_of_day.rem_euclid(24.0);
    let phase = time_hours / 24.0;
    let sun_lon_deg = 180.0 - phase * 360.0;
    let sun_lat_deg = spec.axial_tilt_deg * (phase * std::f32::consts::TAU).sin();
    let base = lat_lon_to_unit(sun_lat_deg, sun_lon_deg);
    let spin = rot_y(spec.rotation_deg);
    let sun_world = spin.mul_vec(base);
    let len = sun_world.length().max(1e-12);
    Vec3::new(sun_world.x / len, sun_world.y / len, sun_world.z / len)
}
/// Compute region light intensity from the centroid and sun direction.
pub fn province_intensity(
    centroid_lat_deg: f32,
    centroid_lon_deg: f32,
    sun_dir: &Vec3,
    ambient: f32,
) -> f32 {
    let normal = lat_lon_to_unit(centroid_lat_deg, centroid_lon_deg);
    let dot = normal.x * sun_dir.x + normal.y * sun_dir.y + normal.z * sun_dir.z;
    dot.max(ambient).min(1.0)
}
/// Compute region intensities for a sequence of centroid positions.
#[allow(clippy::extra_unused_lifetimes)]
pub fn compute_intensities<'a>(
    centroids: impl Iterator<Item = (f32, f32)>,
    sun_dir: &Vec3,
    ambient: f32,
) -> Vec<f32> {
    centroids
        .map(|(lat, lon)| province_intensity(lat, lon, sun_dir, ambient))
        .collect()
}
/// Convert sun alignment into an alpha value around the terminator band.
pub fn terminator_alpha(
    centroid_lat_deg: f32,
    centroid_lon_deg: f32,
    sun_dir: &Vec3,
    transition_deg: f32,
) -> f32 {
    let normal = lat_lon_to_unit(centroid_lat_deg, centroid_lon_deg);
    let dot = normal.x * sun_dir.x + normal.y * sun_dir.y + normal.z * sun_dir.z;
    let half = (transition_deg / 2.0).to_radians().cos();
    let t = (dot + half) / (2.0 * half);
    t.clamp(0.0, 1.0)
}
