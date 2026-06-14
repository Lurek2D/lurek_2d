//! Provides globe picking helpers that translate screen-space clicks into front-hemisphere surface hits.
//! Converts pointer coordinates into spherical latitude and longitude using the current orbit camera.
//! Applies geographic point-in-polygon tests so province and region queries share one hit surface.
//! Exposes marker and region selection results consumed by rendering, UI, and gameplay layers.

use super::sphere::{lat_lon_to_unit, unit_to_lat_lon};
use crate::globe::projection::{build_view_matrix, OrbitCamera};
use crate::globe::topology::RegionGraph;
use crate::globe::types::{GlobeSpec, Region, RegionId};
use crate::math::{Vec2, Vec3};
/// Surface hit resolved from a screen-space position on the front hemisphere.
#[derive(Debug, Clone, Copy)]
pub struct SurfaceHit {
    /// Screen-space pointer position used for the query.
    pub screen_pos: (f32, f32),
    /// Hit latitude in degrees.
    pub lat_deg: f32,
    /// Hit longitude in degrees.
    pub lon_deg: f32,
    /// Hit world position on the unit sphere.
    pub world_pos: Vec3,
    /// Hit camera-space depth on the visible hemisphere.
    pub depth: f32,
}
/// Region selection result returned by globe picking.
#[derive(Debug, Clone)]
pub struct PickResult {
    /// Picked region id.
    pub region_id: RegionId,
    /// Surface hit resolved from the screen-space query.
    pub surface: SurfaceHit,
    /// Projected screen-space centroid for the picked region.
    pub centroid_screen: Vec2,
}
/// Wrap longitude delta into the [-180, 180] range.
fn wrap_lon_delta(delta: f32) -> f32 {
    ((delta + 180.0).rem_euclid(360.0)) - 180.0
}
/// Return true when a point lies inside a 2D polygon.
fn point_in_polygon_2d(pt: Vec2, verts: &[Vec2]) -> bool {
    if verts.len() < 3 {
        return false;
    }
    let mut inside = false;
    let n = verts.len();
    let mut j = n - 1;
    for i in 0..n {
        let vi = verts[i];
        let vj = verts[j];
        if ((vi.y > pt.y) != (vj.y > pt.y))
            && (pt.x < (vj.x - vi.x) * (pt.y - vi.y) / (vj.y - vi.y) + vi.x)
        {
            inside = !inside;
        }
        j = i;
    }
    inside
}
/// Return true when a latitude/longitude point lies inside a polygon in geographic space.
pub fn point_in_geo_polygon(lat_deg: f32, lon_deg: f32, verts: &[(f32, f32)]) -> bool {
    if verts.len() < 3 {
        return false;
    }
    let pt = Vec2::new(0.0, lat_deg);
    let unwrapped: Vec<Vec2> = verts
        .iter()
        .map(|(vlat, vlon)| Vec2::new(wrap_lon_delta(*vlon - lon_deg), *vlat))
        .collect();
    point_in_polygon_2d(pt, &unwrapped)
}

/// Return true when a latitude/longitude point lies inside one connected region part.
pub fn point_in_geo_region(region: &Region, lat_deg: f32, lon_deg: f32) -> bool {
    if !region.parts.is_empty() {
        for part in &region.parts {
            if !point_in_geo_polygon(lat_deg, lon_deg, &part.outer) {
                continue;
            }
            if part
                .holes
                .iter()
                .any(|hole| point_in_geo_polygon(lat_deg, lon_deg, hole))
            {
                continue;
            }
            return true;
        }
        return false;
    }
    point_in_geo_polygon(lat_deg, lon_deg, &region.vertices)
}
/// Convert a screen-space point into a front-hemisphere unit-sphere hit.
pub fn screen_to_surface(
    sx: f32,
    sy: f32,
    spec: &GlobeSpec,
    camera: &OrbitCamera,
) -> Option<SurfaceHit> {
    let radius = (spec.radius * camera.zoom).max(1.0);
    let nx = (sx - camera.screen_cx) / radius;
    let ny = (camera.screen_cy - sy) / radius;
    let rr = nx * nx + ny * ny;
    if rr > 1.0 {
        return None;
    }
    let nz = (1.0 - rr).sqrt();
    let cam_pos = Vec3::new(nx, ny, nz);
    let view = build_view_matrix(spec, camera);
    let world = view.transpose().mul_vec(cam_pos);
    let (lat_deg, lon_deg) = unit_to_lat_lon(world);
    Some(SurfaceHit {
        screen_pos: (sx, sy),
        lat_deg,
        lon_deg,
        world_pos: world,
        depth: nz,
    })
}
/// Pick the topmost region under a screen-space point or return None when no region matches.
pub fn pick(
    sx: f32,
    sy: f32,
    spec: &GlobeSpec,
    camera: &OrbitCamera,
    graph: &RegionGraph,
) -> Option<PickResult> {
    let surface = screen_to_surface(sx, sy, spec, camera)?;
    let view = build_view_matrix(spec, camera);
    let r = spec.radius * camera.zoom;
    let cx = camera.screen_cx;
    let cy = camera.screen_cy;
    let mut best: Option<(f32, PickResult)> = None;
    for region in graph.regions.values() {
        if !point_in_geo_region(region, surface.lat_deg, surface.lon_deg) {
            continue;
        }
        let c_world = lat_lon_to_unit(region.centroid.0, region.centroid.1);
        let c_cam = view.mul_vec(c_world);
        let centroid_screen = Vec2::new(cx + c_cam.x * r, cy - c_cam.y * r);
        let z = c_cam.z;
        if best.as_ref().is_none_or(|(prev_z, _)| z > *prev_z) {
            best = Some((
                z,
                PickResult {
                    region_id: region.id,
                    surface,
                    centroid_screen,
                },
            ));
        }
    }
    best.map(|(_, result)| result)
}
