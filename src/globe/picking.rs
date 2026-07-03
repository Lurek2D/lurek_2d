//! Owns the globe picking implementation for the globe subsystem and keeps related runtime rules local here.
//! Keeps globe state, province data, and world-facing render helpers so helpers stay close to invariants this file updates.
//! Defines how globe picking data is validated, transformed, or stored before neighboring systems consume it.
//! Separates globe picking behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where globe code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing globe picking defaults, lifecycle handling, validation, or data ownership rules.

use super::sphere::{lat_lon_to_unit, unit_to_lat_lon};
use crate::globe::projection::{build_view_matrix, OrbitCamera};
use crate::globe::topology::RegionGraph;
use crate::globe::types::{GlobeSpec, Region, RegionId};
use crate::math::{Vec2, Vec3};
use std::collections::HashMap;

/// Shell hit resolved from a screen-space position on one visible concentric globe shell.
#[derive(Debug, Clone)]
pub struct ShellHit {
    /// Screen-space pointer position used for the query.
    pub screen_pos: (f32, f32),
    /// Named shell altitude above the base globe surface in render units.
    pub altitude_px: f32,
    /// Hit latitude in degrees.
    pub lat_deg: f32,
    /// Hit longitude in degrees.
    pub lon_deg: f32,
    /// Hit world position on the unit sphere.
    pub world_pos: Vec3,
    /// Hit camera-space depth on the visible hemisphere.
    pub depth: f32,
}
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
/// Kind tag for the richer shell-aware object picker.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ObjectHitKind {
    /// One globe marker.
    Marker,
    /// One orbit shell.
    Orbit,
    /// One province hit on the base globe surface.
    Province,
    /// One semantic region hit on the base globe surface.
    Region,
    /// A raw surface latitude-longitude hit with no higher-level owner.
    Surface,
}
/// Sorting mode for the richer shell-aware object picker.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ObjectPickOrder {
    /// Prefer markers first, then shell hits, then base surface owners.
    MarkersFirst,
    /// Prefer higher shells first, then nearer depths inside the same shell.
    FrontToBack,
}
/// Options that control which shell-aware hits are returned.
#[derive(Debug, Clone, Copy)]
pub struct ObjectPickOptions {
    /// Maximum marker hit distance in pixels before style expansion is applied.
    pub marker_radius: f32,
    /// Include the raw surface hit payload.
    pub include_surface: bool,
    /// Include semantic region hits on the base globe surface.
    pub include_regions: bool,
    /// Include marker hits on visible pickable shells.
    pub include_markers: bool,
    /// Include orbit-shell hits on visible pickable shells.
    pub include_orbits: bool,
    /// Sorting policy for returned hits.
    pub order: ObjectPickOrder,
}
impl Default for ObjectPickOptions {
    fn default() -> Self {
        Self {
            marker_radius: 12.0,
            include_surface: true,
            include_regions: true,
            include_markers: true,
            include_orbits: true,
            order: ObjectPickOrder::MarkersFirst,
        }
    }
}
/// Richer hit payload that can describe markers, shells, provinces, regions, or the base surface.
#[derive(Debug, Clone)]
pub struct ObjectHit {
    /// The category of object that was hit.
    pub kind: ObjectHitKind,
    /// Optional id for markers, provinces, or semantic regions.
    pub id: Option<u32>,
    /// Optional orbit name for shell or marker hits.
    pub orbit: Option<String>,
    /// Hit latitude in degrees.
    pub lat_deg: f32,
    /// Hit longitude in degrees.
    pub lon_deg: f32,
    /// Total shell altitude above the base surface in render units.
    pub altitude_px: f32,
    /// Screen-space x coordinate used for the query.
    pub screen_x: f32,
    /// Screen-space y coordinate used for the query.
    pub screen_y: f32,
    /// Camera-space depth for the hit.
    pub depth: f32,
    /// Screen-space hit distance in pixels.
    pub distance_px: f32,
    /// Arbitrary string attributes supplied by the hit owner.
    pub attrs: HashMap<String, String>,
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
    const EDGE_EPSILON: f32 = 1e-6;
    let mut inside = false;
    let n = verts.len();
    let mut j = n - 1;
    for i in 0..n {
        let vi = verts[i];
        let vj = verts[j];
        if (vi.y > pt.y) != (vj.y > pt.y) {
            let mut denom = vj.y - vi.y;
            if denom.abs() < EDGE_EPSILON {
                denom = if denom.is_sign_negative() {
                    -EDGE_EPSILON
                } else {
                    EDGE_EPSILON
                };
            }
            if pt.x < (vj.x - vi.x) * (pt.y - vi.y) / denom + vi.x {
                inside = !inside;
            }
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
/// Convert a screen-space point into a front-hemisphere hit on one named shell radius.
pub fn screen_to_shell(
    sx: f32,
    sy: f32,
    spec: &GlobeSpec,
    camera: &OrbitCamera,
    shell_radius: f32,
    altitude_px: f32,
) -> Option<ShellHit> {
    let radius = (shell_radius * camera.zoom).max(1.0);
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
    Some(ShellHit {
        screen_pos: (sx, sy),
        altitude_px,
        lat_deg,
        lon_deg,
        world_pos: world,
        depth: nz,
    })
}
/// Convert a screen-space point into a front-hemisphere unit-sphere hit.
pub fn screen_to_surface(
    sx: f32,
    sy: f32,
    spec: &GlobeSpec,
    camera: &OrbitCamera,
) -> Option<SurfaceHit> {
    let shell = screen_to_shell(sx, sy, spec, camera, spec.radius, 0.0)?;
    Some(SurfaceHit {
        screen_pos: shell.screen_pos,
        lat_deg: shell.lat_deg,
        lon_deg: shell.lon_deg,
        world_pos: shell.world_pos,
        depth: shell.depth,
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
    for region_id in graph.candidate_ids_at(surface.lat_deg, surface.lon_deg) {
        let Some(region) = graph.get(region_id) else {
            continue;
        };
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
