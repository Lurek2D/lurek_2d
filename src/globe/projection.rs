//! Provides globe projection math driven by an orbit camera with latitude, longitude, and zoom control.
//! Builds view transforms from globe rotation, axial tilt, and camera orientation inputs.
//! Projects points and regions from spherical coordinates into screen-space render geometry.
//! Applies facing checks and depth culling to reject back-hemisphere geometry during projection.
//! Delivers camera and projection utilities used by drawing, picking, and interaction code paths.

use super::sphere::{axial_tilt_mat, lat_lon_to_unit, rot_x, rot_y, Mat3x3};
use crate::globe::types::{GlobeSpec, LodTier, ProjectedRegion, Region};
use crate::math::{Vec2, Vec3};

#[derive(Debug, Clone, Copy)]
struct ClippedVertex {
    world: Vec3,
    cam: Vec3,
}
/// Orbit camera state used to project globe geometry into screen space.
#[derive(Debug, Clone)]
pub struct OrbitCamera {
    /// Camera latitude in degrees.
    pub lat_deg: f32,
    /// Camera longitude in degrees.
    pub lon_deg: f32,
    /// Zoom multiplier applied to projected coordinates.
    pub zoom: f32,
    /// Screen center x coordinate.
    pub screen_cx: f32,
    /// Screen center y coordinate.
    pub screen_cy: f32,
}
/// Default orbit camera pointing at the globe center with a mid-screen pivot.
impl Default for OrbitCamera {
    fn default() -> Self {
        Self {
            lat_deg: 30.0,
            lon_deg: 0.0,
            zoom: 1.0,
            screen_cx: 640.0,
            screen_cy: 360.0,
        }
    }
}
/// Camera manipulation: pan, zoom, LOD, and clamping.
impl OrbitCamera {
    /// Clamp camera latitude, longitude, and zoom into the supported range.
    pub fn clamp(&mut self) {
        self.lat_deg = self.lat_deg.clamp(-89.9, 89.9);
        self.lon_deg = ((self.lon_deg + 180.0).rem_euclid(360.0)) - 180.0;
        self.zoom = self.zoom.clamp(0.1, 20.0);
    }
    /// Pan the camera by latitude and longitude deltas.
    pub fn pan(&mut self, delta_lat: f32, delta_lon: f32) {
        self.lat_deg += delta_lat;
        self.lon_deg += delta_lon;
        self.clamp();
    }
    /// Multiply zoom by a factor and clamp the result.
    pub fn zoom_by(&mut self, factor: f32) {
        self.zoom *= factor;
        self.clamp();
    }
    /// Return the current level-of-detail tier for the zoom level.
    pub fn lod(&self) -> LodTier {
        if self.zoom >= 4.0 {
            LodTier::Near
        } else if self.zoom >= 1.5 {
            LodTier::Mid
        } else {
            LodTier::Far
        }
    }
}
/// Build the view matrix from globe rotation, tilt, and orbit camera angles.
pub fn build_view_matrix(spec: &GlobeSpec, camera: &OrbitCamera) -> Mat3x3 {
    let planet_spin = rot_y(-spec.rotation_deg);
    let tilt = axial_tilt_mat(spec.axial_tilt_deg);
    let cam_lon = rot_y(-camera.lon_deg);
    let cam_lat = rot_x(camera.lat_deg);
    cam_lat.mul_mat(&cam_lon.mul_mat(&tilt.mul_mat(&planet_spin)))
}
/// Project a globe point to screen space or return None when it is behind the camera.
pub fn project_point(
    lat_deg: f32,
    lon_deg: f32,
    view: &Mat3x3,
    radius: f32,
    zoom: f32,
    cx: f32,
    cy: f32,
) -> Option<Vec2> {
    let world = lat_lon_to_unit(lat_deg, lon_deg);
    let cam = view.mul_vec(world);
    if cam.z <= 0.0 {
        return None;
    }
    let r = radius * zoom;
    Some(Vec2::new(cx + cam.x * r, cy - cam.y * r))
}
/// Project a region polygon into screen space or return None when any vertex is hidden.
pub fn project_region(
    region: &Region,
    view: &Mat3x3,
    spec: &GlobeSpec,
    camera: &OrbitCamera,
    light_intensity: f32,
) -> Option<ProjectedRegion> {
    project_geo_loop(
        region.id,
        region.primary_vertices(),
        region.centroid,
        view,
        spec,
        camera,
        light_intensity,
    )
}

/// Project one geographic loop into screen space, clipping it to the visible hemisphere.
pub fn project_geo_loop(
    id: crate::globe::types::RegionId,
    vertices: &[(f32, f32)],
    centroid: (f32, f32),
    view: &Mat3x3,
    spec: &GlobeSpec,
    camera: &OrbitCamera,
    light_intensity: f32,
) -> Option<ProjectedRegion> {
    let r = spec.radius * camera.zoom;
    let cx = camera.screen_cx;
    let cy = camera.screen_cy;
    let c_world = lat_lon_to_unit(centroid.0, centroid.1);
    let c_cam = view.mul_vec(c_world);
    let clipped = clip_geo_loop_to_visible_hemisphere(vertices, view);
    if clipped.len() < 3 {
        return None;
    }
    let surface_points: Vec<Vec3> = clipped.iter().map(|v| v.world).collect();
    let screen_verts: Vec<Vec2> = clipped
        .iter()
        .map(|v| Vec2::new(cx + v.cam.x * r, cy - v.cam.y * r))
        .collect();
    let centroid_screen = if c_cam.z > 0.0 {
        Vec2::new(cx + c_cam.x * r, cy - c_cam.y * r)
    } else {
        let (sx, sy) = screen_verts
            .iter()
            .fold((0.0_f32, 0.0_f32), |(ax, ay), v| (ax + v.x, ay + v.y));
        let count = screen_verts.len() as f32;
        Vec2::new(sx / count, sy / count)
    };
    Some(ProjectedRegion {
        id,
        screen_verts,
        surface_points,
        centroid_screen,
        light_intensity,
        visible: true,
    })
}

/// Backward compatibility alias.
#[inline]
pub fn project_province(
    province: &Region,
    view: &Mat3x3,
    spec: &GlobeSpec,
    camera: &OrbitCamera,
    light_intensity: f32,
) -> Option<ProjectedRegion> {
    project_region(province, view, spec, camera, light_intensity)
}
/// Project a globe point and return the screen position with depth or None when hidden.
pub fn project_point_with_z(
    lat_deg: f32,
    lon_deg: f32,
    view: &Mat3x3,
    spec: &GlobeSpec,
    camera: &OrbitCamera,
) -> Option<(Vec2, f32)> {
    let r = spec.radius * camera.zoom;
    let world = lat_lon_to_unit(lat_deg, lon_deg);
    let cam = view.mul_vec(world);
    if cam.z <= 0.0 {
        return None;
    }
    let screen = Vec2::new(camera.screen_cx + cam.x * r, camera.screen_cy - cam.y * r);
    Some((screen, cam.z))
}
/// Convert a screen-space drag delta into latitude and longitude pan deltas.
pub fn screen_delta_to_pan(dx: f32, dy: f32, spec: &GlobeSpec, camera: &OrbitCamera) -> (f32, f32) {
    let r = (spec.radius * camera.zoom).max(1.0);
    let deg_per_px = 180.0 / (std::f32::consts::PI * r);
    (-dy * deg_per_px * 60.0, -dx * deg_per_px * 60.0)
}
/// Normalize a vector and return zero when its length is near zero.
#[inline]
pub fn normalize_v3(v: Vec3) -> Vec3 {
    let len = v.length();
    if len < 1e-12 {
        Vec3::new(0.0, 0.0, 0.0)
    } else {
        Vec3::new(v.x / len, v.y / len, v.z / len)
    }
}

#[inline]
fn lerp_v3(a: Vec3, b: Vec3, t: f32) -> Vec3 {
    Vec3::new(
        a.x + (b.x - a.x) * t,
        a.y + (b.y - a.y) * t,
        a.z + (b.z - a.z) * t,
    )
}

fn interpolate_visible_edge(a: ClippedVertex, b: ClippedVertex, view: &Mat3x3) -> ClippedVertex {
    let denom = a.cam.z - b.cam.z;
    let t = if denom.abs() < 1e-6 {
        0.5
    } else {
        (a.cam.z / denom).clamp(0.0, 1.0)
    };
    let world = normalize_v3(lerp_v3(a.world, b.world, t));
    let mut cam = view.mul_vec(world);
    cam.z = 0.0;
    ClippedVertex { world, cam }
}

fn clip_geo_loop_to_visible_hemisphere(
    vertices: &[(f32, f32)],
    view: &Mat3x3,
) -> Vec<ClippedVertex> {
    if vertices.len() < 3 {
        return Vec::new();
    }
    let mut subject: Vec<ClippedVertex> = vertices
        .iter()
        .map(|&(lat, lon)| {
            let world = lat_lon_to_unit(lat, lon);
            let cam = view.mul_vec(world);
            ClippedVertex { world, cam }
        })
        .collect();
    if subject.iter().all(|v| v.cam.z <= 0.0) {
        return Vec::new();
    }
    let mut clipped: Vec<ClippedVertex> = Vec::with_capacity(subject.len() + 2);
    let mut prev = *subject.last().expect("subject is non-empty");
    let mut prev_inside = prev.cam.z >= 0.0;
    for curr in subject.drain(..) {
        let curr_inside = curr.cam.z >= 0.0;
        match (prev_inside, curr_inside) {
            (true, true) => clipped.push(curr),
            (true, false) => clipped.push(interpolate_visible_edge(prev, curr, view)),
            (false, true) => {
                clipped.push(interpolate_visible_edge(prev, curr, view));
                clipped.push(curr);
            }
            (false, false) => {}
        }
        prev = curr;
        prev_inside = curr_inside;
    }
    clipped
}
