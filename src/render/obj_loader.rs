//! Loads Wavefront OBJ and MTL data into reusable mesh structures and CPU-projected renderable geometry.
//! Parses faces, materials, vertices, normals, and texture coordinates while normalizing OBJ indexing rules.
//! Projects source geometry into viewport-friendly coordinates using simple camera-style transforms.
//! Computes normals and back-face filtering so software preview and shading logic can make stable decisions.
//! Resolves diffuse colors and texture paths from materials without forcing those rules into generic mesh owners.
//! Includes CPU raster-style support used for thumbnailing, validation, or headless geometry inspection.
//! Keeps OBJ-specific parsing and error handling separate from runtime GPU pipeline or tilemap import paths.
//! Acts as the model-import boundary between external Wavefront assets and internal 2D mesh representations.
//! Open this file when OBJ parsing, index normalization, material mapping, or projection output is incorrect.
//! Read this owner before general mesh changes when the bug is limited to imported model content.

use crate::image::ImageData;
use crate::render::mesh::{Mesh, MeshDrawMode, MeshVertex};
use crate::runtime::resource_keys::TextureKey;
use std::collections::HashMap;
use std::path::{Component, Path};

/// Hard limits for untrusted Wavefront text before it can allocate parser state.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct ObjLimits {
    /// Maximum UTF-8 bytes in one OBJ or MTL document.
    pub max_bytes: usize,
    /// Maximum lines in one document.
    pub max_lines: usize,
    /// Maximum bytes in a single line.
    pub max_line_bytes: usize,
    /// Maximum positions, UVs, normals, and triangulated faces respectively.
    pub max_elements: usize,
}

impl Default for ObjLimits {
    fn default() -> Self {
        Self {
            max_bytes: 64 * 1024 * 1024,
            max_lines: 1_000_000,
            max_line_bytes: 16 * 1024,
            max_elements: 1_000_000,
        }
    }
}
/// Error returned from OBJ loading or parsing.
#[derive(Debug)]
pub enum ObjError {
    /// File I/O error.
    Io(std::io::Error),
    /// Structural parse error with a human-readable message.
    Parse(String),
}

/// Supplies material-library text for an OBJ parser without exposing host filesystem policy.
pub trait ObjResolver {
    /// Return bounded UTF-8 MTL source for the requested relative material reference.
    fn read_material_library(&mut self, reference: &str) -> Result<String, ObjError>;
}

impl<F> ObjResolver for F
where
    F: FnMut(&str) -> Result<String, ObjError>,
{
    fn read_material_library(&mut self, reference: &str) -> Result<String, ObjError> {
        self(reference)
    }
}

/// Compatibility resolver for legacy in-memory entry points.
///
/// Host-path loading is deliberately unavailable from the parser. Runtime callers
/// must provide GameFS-backed material text through `ObjResolver`.
struct RejectingObjResolver;

impl ObjResolver for RejectingObjResolver {
    fn read_material_library(&mut self, reference: &str) -> Result<String, ObjError> {
        Err(ObjError::Parse(format!(
            "material library {reference:?} requires an owner-policy resolver"
        )))
    }
}
/// Implement `Display` for `ObjError`.
impl std::fmt::Display for ObjError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ObjError::Io(e) => write!(f, "OBJ IO error: {}", e),
            ObjError::Parse(s) => write!(f, "OBJ parse error: {}", s),
        }
    }
}
/// Convert `std::io::Error` into `ObjError::Io`.
impl From<std::io::Error> for ObjError {
    fn from(e: std::io::Error) -> Self {
        ObjError::Io(e)
    }
}
/// Simple 3-D vector used for positions, normals, and scratch arithmetic during projection.
#[derive(Debug, Clone, Copy)]
pub struct Vec3 {
    /// X component.
    pub x: f32,
    /// Y component.
    pub y: f32,
    /// Z component.
    pub z: f32,
}
/// Arithmetic helpers for the local 3-D vector type.
impl Vec3 {
    /// Construct from components. This function is part of the public API.
    pub fn new(x: f32, y: f32, z: f32) -> Self {
        Self { x, y, z }
    }
    /// Return the scalar dot product of `self` and `other`.
    pub fn dot(self, other: Vec3) -> f32 {
        self.x * other.x + self.y * other.y + self.z * other.z
    }
    /// Return the Euclidean length of this vector.
    pub fn len(self) -> f32 {
        (self.x * self.x + self.y * self.y + self.z * self.z).sqrt()
    }
    /// Return a unit vector; returns zero vector when length < 1e-9.
    pub fn normalise(self) -> Vec3 {
        let l = self.len();
        if l < 1e-9 {
            Vec3::new(0.0, 0.0, 0.0)
        } else {
            Vec3::new(self.x / l, self.y / l, self.z / l)
        }
    }
    /// Return `self - o`. This function is part of the public API.
    #[allow(clippy::should_implement_trait)]
    pub fn sub(self, o: Vec3) -> Vec3 {
        Vec3::new(self.x - o.x, self.y - o.y, self.z - o.z)
    }
    /// Return the cross product `self × o`.
    pub fn cross(self, o: Vec3) -> Vec3 {
        Vec3::new(
            self.y * o.z - self.z * o.y,
            self.z * o.x - self.x * o.z,
            self.x * o.y - self.y * o.x,
        )
    }
    /// Return `self + o`. This function is part of the public API.
    #[allow(clippy::should_implement_trait)]
    pub fn add(self, o: Vec3) -> Vec3 {
        Vec3::new(self.x + o.x, self.y + o.y, self.z + o.z)
    }
    /// Return `self * s` (scalar multiply).
    #[allow(clippy::should_implement_trait)]
    pub fn mul(self, s: f32) -> Vec3 {
        Vec3::new(self.x * s, self.y * s, self.z * s)
    }
}
/// Rotate `v` around the world Y-axis by `angle` radians.
fn rotate_y(v: Vec3, angle: f32) -> Vec3 {
    let c = angle.cos();
    let s = angle.sin();
    Vec3::new(v.x * c + v.z * s, v.y, -v.x * s + v.z * c)
}
/// Compute a 2D edge function value used for barycentric rasterization.
fn edge_fn(ax: f32, ay: f32, bx: f32, by: f32, px: f32, py: f32) -> f32 {
    (px - ax) * (by - ay) - (py - ay) * (bx - ax)
}
/// 2D texture coordinate, `u` and `v`.
#[derive(Debug, Clone, Copy)]
pub struct Vec2 {
    /// Horizontal UV component.
    pub u: f32,
    /// Vertical UV component.
    pub v: f32,
}
/// One triangulated OBJ face with per-vertex position/UV/normal indices and an optional material.
#[derive(Debug, Clone)]
pub struct ObjFace {
    /// Per-vertex `(position_idx, uv_idx, normal_idx)` tuples.
    pub verts: [(usize, Option<usize>, Option<usize>); 3],
    /// Index into `ObjModel::materials`, or `None` for default material.
    pub material: Option<usize>,
}
/// A named material from an MTL file with diffuse colour and optional diffuse texture path.
#[derive(Debug, Clone)]
pub struct ObjMaterial {
    /// Material name as declared in the MTL file.
    pub name: String,
    /// Linear RGB diffuse colour; default `[1.0, 1.0, 1.0]` (white).
    pub diffuse_color: [f32; 3],
    /// Optional relative path to the diffuse texture image.
    pub diffuse_map: Option<String>,
}
/// A parsed OBJ model: vertex positions, UVs, normals, faces, and materials.
#[derive(Debug, Clone)]
pub struct ObjModel {
    /// Vertex positions in local space.
    pub positions: Vec<Vec3>,
    /// UV coordinates indexed by face vertex tuples.
    pub uvs: Vec<Vec2>,
    /// Vertex normals indexed by face vertex tuples.
    pub normals: Vec<Vec3>,
    /// Triangulated faces with per-vertex index tuples.
    pub faces: Vec<ObjFace>,
    /// Materials from `.mtl` file or inline MTL declarations.
    pub materials: Vec<ObjMaterial>,
}
/// Query, CPU-rasterise, and project operations on a parsed OBJ model.
impl ObjModel {
    /// Return the number of triangles in this model.
    pub fn face_count(&self) -> usize {
        self.faces.len()
    }
    /// Return the number of vertex positions in this model.
    pub fn vertex_count(&self) -> usize {
        self.positions.len()
    }
    /// Return the number of UV entries in this model.
    pub fn uv_count(&self) -> usize {
        self.uvs.len()
    }
    /// Return the number of normal entries in this model.
    pub fn normal_count(&self) -> usize {
        self.normals.len()
    }
    /// CPU-rasterize the model into an `ImageData` with a virtual camera, Y-rotation, and a key light.
    pub fn render_to_image(&self, width: u32, height: u32, rotation_quarters: u8) -> ImageData {
        let mut image = ImageData::new(width, height);
        if width == 0 || height == 0 || self.positions.is_empty() {
            return image;
        }
        let angle = (rotation_quarters % 4) as f32 * std::f32::consts::FRAC_PI_2;
        let rotated: Vec<Vec3> = self
            .positions
            .iter()
            .copied()
            .map(|p| rotate_y(p, angle))
            .collect();
        let mut min = Vec3::new(f32::INFINITY, f32::INFINITY, f32::INFINITY);
        let mut max = Vec3::new(f32::NEG_INFINITY, f32::NEG_INFINITY, f32::NEG_INFINITY);
        for p in &rotated {
            min.x = min.x.min(p.x);
            min.y = min.y.min(p.y);
            min.z = min.z.min(p.z);
            max.x = max.x.max(p.x);
            max.y = max.y.max(p.y);
            max.z = max.z.max(p.z);
        }
        let center = Vec3::new(
            (min.x + max.x) * 0.5,
            (min.y + max.y) * 0.5,
            (min.z + max.z) * 0.5,
        );
        let extent = Vec3::new(max.x - min.x, max.y - min.y, max.z - min.z);
        let radius = ((extent.x * extent.x + extent.y * extent.y + extent.z * extent.z).sqrt()
            * 0.5)
            .max(0.5);
        let cam_pos = center.add(Vec3::new(radius * 1.2, radius * 0.8, radius * 2.4));
        let cam_target = center.add(Vec3::new(0.0, extent.y * 0.15, 0.0));
        let forward = cam_target.sub(cam_pos).normalise();
        let world_up = Vec3::new(0.0, 1.0, 0.0);
        let right = forward.cross(world_up).normalise();
        let up = right.cross(forward).normalise();
        let fov_y = 50.0_f32.to_radians();
        let tan_half_fov = (fov_y * 0.5).tan();
        let aspect = width as f32 / height as f32;
        let near_z = 0.05_f32;
        let light_dir = Vec3::new(0.45, 0.90, 0.55).normalise();
        let mut zbuf = vec![f32::INFINITY; (width * height) as usize];
        for face in &self.faces {
            let wp = [
                rotated[face.verts[0].0],
                rotated[face.verts[1].0],
                rotated[face.verts[2].0],
            ];
            let e0 = wp[1].sub(wp[0]);
            let e1 = wp[2].sub(wp[0]);
            let face_normal = e0.cross(e1).normalise();
            let to_cam = cam_pos.sub(wp[0]).normalise();
            if face_normal.dot(to_cam) <= 0.0 {
                continue;
            }
            let z0 = wp[0].sub(cam_pos).dot(forward);
            let z1 = wp[1].sub(cam_pos).dot(forward);
            let z2 = wp[2].sub(cam_pos).dot(forward);
            if z0 <= near_z || z1 <= near_z || z2 <= near_z {
                continue;
            }
            let mut sx = [0.0_f32; 3];
            let mut sy = [0.0_f32; 3];
            for i in 0..3 {
                let rel = wp[i].sub(cam_pos);
                let vz = rel.dot(forward);
                let vx = rel.dot(right);
                let vy = rel.dot(up);
                let ndcx = vx / (vz * tan_half_fov * aspect);
                let ndcy = vy / (vz * tan_half_fov);
                sx[i] = (ndcx + 1.0) * 0.5 * width as f32;
                sy[i] = (1.0 - (ndcy + 1.0) * 0.5) * height as f32;
            }
            let area = edge_fn(sx[0], sy[0], sx[1], sy[1], sx[2], sy[2]);
            if area.abs() < 1e-4 {
                continue;
            }
            let ndotl = face_normal.dot(light_dir).max(0.0);
            let shade = 0.28 + 0.72 * ndotl;
            let (r, g, b) = if let Some(mat_idx) = face.material {
                if let Some(mat) = self.materials.get(mat_idx) {
                    (
                        (mat.diffuse_color[0] * shade * 255.0).clamp(0.0, 255.0) as u8,
                        (mat.diffuse_color[1] * shade * 255.0).clamp(0.0, 255.0) as u8,
                        (mat.diffuse_color[2] * shade * 255.0).clamp(0.0, 255.0) as u8,
                    )
                } else {
                    let c = (shade * 255.0).clamp(0.0, 255.0) as u8;
                    (c, c, c)
                }
            } else {
                let c = (shade * 255.0).clamp(0.0, 255.0) as u8;
                (c, c, c)
            };
            let min_x = sx
                .iter()
                .copied()
                .fold(f32::INFINITY, f32::min)
                .floor()
                .max(0.0) as u32;
            let max_x = sx
                .iter()
                .copied()
                .fold(f32::NEG_INFINITY, f32::max)
                .ceil()
                .min(width as f32 - 1.0) as u32;
            let min_y = sy
                .iter()
                .copied()
                .fold(f32::INFINITY, f32::min)
                .floor()
                .max(0.0) as u32;
            let max_y = sy
                .iter()
                .copied()
                .fold(f32::NEG_INFINITY, f32::max)
                .ceil()
                .min(height as f32 - 1.0) as u32;
            for py in min_y..=max_y {
                for px in min_x..=max_x {
                    let fx = px as f32 + 0.5;
                    let fy = py as f32 + 0.5;
                    let w0 = edge_fn(sx[1], sy[1], sx[2], sy[2], fx, fy) / area;
                    let w1 = edge_fn(sx[2], sy[2], sx[0], sy[0], fx, fy) / area;
                    let w2 = edge_fn(sx[0], sy[0], sx[1], sy[1], fx, fy) / area;
                    if w0 < 0.0 || w1 < 0.0 || w2 < 0.0 {
                        continue;
                    }
                    let depth = w0 * z0 + w1 * z1 + w2 * z2;
                    let idx = (py * width + px) as usize;
                    if depth >= zbuf[idx] {
                        continue;
                    }
                    zbuf[idx] = depth;
                    image.set_pixel(px, py, r, g, b, 255);
                }
            }
        }
        image
    }
    /// Project the model from `cam_pos`/`cam_target` into a `Mesh` sorted back-to-front.
    pub fn project_to_mesh(
        &self,
        cam_pos: Vec3,
        cam_target: Vec3,
        fov_y: f32,
        screen_w: f32,
        screen_h: f32,
        texture_key: Option<TextureKey>,
    ) -> Mesh {
        let forward = cam_target.sub(cam_pos).normalise();
        let world_up = Vec3::new(0.0, 1.0, 0.0);
        let right = forward.cross(world_up).normalise();
        let up = right.cross(forward).normalise();
        let aspect = screen_w / screen_h;
        let tan_half_fov = (fov_y * 0.5).tan();
        let light_dir = Vec3::new(0.5, 1.0, 0.7).normalise();
        let mut projected_tris: Vec<(f32, [MeshVertex; 3])> = Vec::new();
        if projected_tris.try_reserve_exact(self.faces.len()).is_err() {
            let mut mesh = Mesh::from_vertices(Vec::new(), MeshDrawMode::Triangles);
            mesh.texture = texture_key;
            return mesh;
        }
        let near_z = 0.05_f32;
        for face in &self.faces {
            let wp: [Vec3; 3] = [
                self.positions[face.verts[0].0],
                self.positions[face.verts[1].0],
                self.positions[face.verts[2].0],
            ];
            let e0 = wp[1].sub(wp[0]);
            let e1 = wp[2].sub(wp[0]);
            let face_normal = e0.cross(e1).normalise();
            let z0 = wp[0].sub(cam_pos).dot(forward);
            let z1 = wp[1].sub(cam_pos).dot(forward);
            let z2 = wp[2].sub(cam_pos).dot(forward);
            if z0 <= near_z || z1 <= near_z || z2 <= near_z {
                continue;
            }
            let to_cam = cam_pos.sub(wp[0]).normalise();
            if face_normal.dot(to_cam) <= 0.0 {
                continue;
            }
            let ndotl = face_normal.dot(light_dir).max(0.0);
            let shade = 0.35 + 0.65 * ndotl;
            let (r, g, b) = if let Some(mat_idx) = face.material {
                if let Some(mat) = self.materials.get(mat_idx) {
                    (
                        mat.diffuse_color[0] * shade,
                        mat.diffuse_color[1] * shade,
                        mat.diffuse_color[2] * shade,
                    )
                } else {
                    (shade, shade, shade)
                }
            } else {
                (shade, shade, shade)
            };
            let mut tri = [MeshVertex::default(); 3];
            for (vi, &wp_v) in wp.iter().enumerate() {
                let rel = wp_v.sub(cam_pos);
                let vz = rel.dot(forward);
                let clip_z = vz.max(0.001);
                let vx = rel.dot(right);
                let vy = rel.dot(up);
                let ndcx = vx / (clip_z * tan_half_fov * aspect);
                let ndcy = vy / (clip_z * tan_half_fov);
                let sx = (ndcx + 1.0) * 0.5 * screen_w;
                let sy = (1.0 - (ndcy + 1.0) * 0.5) * screen_h;
                let (u, v) = if let Some(uv_idx) = face.verts[vi].1 {
                    if let Some(uv) = self.uvs.get(uv_idx) {
                        (uv.u, 1.0 - uv.v)
                    } else {
                        (0.0, 0.0)
                    }
                } else {
                    (0.0, 0.0)
                };
                tri[vi] = MeshVertex {
                    x: sx,
                    y: sy,
                    u,
                    v,
                    r: r.min(1.0),
                    g: g.min(1.0),
                    b: b.min(1.0),
                    a: 1.0,
                };
            }
            let tri_depth = z0.max(z1).max(z2);
            projected_tris.push((tri_depth, tri));
        }
        projected_tris.sort_by(|a, b| b.0.partial_cmp(&a.0).unwrap_or(std::cmp::Ordering::Equal));
        let Some(vertex_count) = projected_tris.len().checked_mul(3) else {
            let mut mesh = Mesh::from_vertices(Vec::new(), MeshDrawMode::Triangles);
            mesh.texture = texture_key;
            return mesh;
        };
        let mut vertices: Vec<MeshVertex> = Vec::new();
        if vertices.try_reserve_exact(vertex_count).is_err() {
            let mut mesh = Mesh::from_vertices(Vec::new(), MeshDrawMode::Triangles);
            mesh.texture = texture_key;
            return mesh;
        }
        for (_, tri) in projected_tris {
            vertices.push(tri[0]);
            vertices.push(tri[1]);
            vertices.push(tri[2]);
        }
        let mut mesh = Mesh::from_vertices(vertices, MeshDrawMode::Triangles);
        mesh.texture = texture_key;
        mesh
    }
    /// Project a single world-space instance with Y-rotation and uniform scale.
    /// Returns `(Mesh, depth, triangle_depths)` where `triangle_depths` stores one
    /// camera-space depth per emitted triangle in the same order as the flattened
    /// triangle-list mesh vertices.
    #[allow(clippy::too_many_arguments)]
    pub fn project_instance_to_mesh(
        &self,
        cam_pos: Vec3,
        cam_target: Vec3,
        fov_y: f32,
        screen_w: f32,
        screen_h: f32,
        world_x: f32,
        world_z: f32,
        floor_y: f32,
        yaw_radians: f32,
        scale: f32,
    ) -> (Mesh, f32, Vec<f32>) {
        let forward = cam_target.sub(cam_pos).normalise();
        let world_up = Vec3::new(0.0, 1.0, 0.0);
        let right = forward.cross(world_up).normalise();
        let up = right.cross(forward).normalise();
        let aspect = screen_w / screen_h;
        let tan_half_fov = (fov_y * 0.5).tan();
        let light_dir = Vec3::new(0.5, 1.0, 0.7).normalise();
        let near_z = 0.05_f32;
        let c = yaw_radians.cos();
        let s = yaw_radians.sin();
        let mut projected_tris: Vec<(f32, f32, [MeshVertex; 3])> = Vec::new();
        if projected_tris.try_reserve_exact(self.faces.len()).is_err() {
            return (
                Mesh::from_vertices(Vec::new(), MeshDrawMode::Triangles),
                f32::INFINITY,
                Vec::new(),
            );
        }
        let mut min_x = f32::INFINITY;
        let mut max_x = f32::NEG_INFINITY;
        let mut min_y = f32::INFINITY;
        let mut min_z = f32::INFINITY;
        let mut max_z = f32::NEG_INFINITY;
        for p in &self.positions {
            min_x = min_x.min(p.x);
            max_x = max_x.max(p.x);
            min_y = min_y.min(p.y);
            min_z = min_z.min(p.z);
            max_z = max_z.max(p.z);
        }
        let center_x = (min_x + max_x) * 0.5;
        let center_z = (min_z + max_z) * 0.5;
        let model_base_y = min_y;
        let mut instance_depth = f32::INFINITY;
        for face in &self.faces {
            let wp = face.verts.map(|v| {
                let p = self.positions[v.0];
                let px = (p.x - center_x) * scale;
                let py = (p.y - model_base_y) * scale;
                let pz = (p.z - center_z) * scale;
                let rx = px * c + pz * s;
                let rz = -px * s + pz * c;
                Vec3::new(world_x + rx, floor_y + py, world_z + rz)
            });
            let e0 = wp[1].sub(wp[0]);
            let e1 = wp[2].sub(wp[0]);
            let face_normal = e0.cross(e1).normalise();
            let z0 = wp[0].sub(cam_pos).dot(forward);
            let z1 = wp[1].sub(cam_pos).dot(forward);
            let z2 = wp[2].sub(cam_pos).dot(forward);
            if z0 <= near_z || z1 <= near_z || z2 <= near_z {
                continue;
            }
            let to_cam = cam_pos.sub(wp[0]).normalise();
            if face_normal.dot(to_cam) <= 0.0 {
                continue;
            }
            let ndotl = face_normal.dot(light_dir).max(0.0);
            let shade = 0.35 + 0.65 * ndotl;
            let (r, g, b) = if let Some(mat_idx) = face.material {
                if let Some(mat) = self.materials.get(mat_idx) {
                    (
                        mat.diffuse_color[0] * shade,
                        mat.diffuse_color[1] * shade,
                        mat.diffuse_color[2] * shade,
                    )
                } else {
                    (shade, shade, shade)
                }
            } else {
                (shade, shade, shade)
            };
            let mut tri = [MeshVertex::default(); 3];
            for (vi, &wp_v) in wp.iter().enumerate() {
                let rel = wp_v.sub(cam_pos);
                let vz = rel.dot(forward);
                let clip_z = vz.max(0.001);
                let vx = rel.dot(right);
                let vy = rel.dot(up);
                let ndcx = vx / (clip_z * tan_half_fov * aspect);
                let ndcy = vy / (clip_z * tan_half_fov);
                let sx = (ndcx + 1.0) * 0.5 * screen_w;
                let sy = (1.0 - (ndcy + 1.0) * 0.5) * screen_h;
                let (u, v) = if let Some(uv_idx) = face.verts[vi].1 {
                    if let Some(uv) = self.uvs.get(uv_idx) {
                        (uv.u, 1.0 - uv.v)
                    } else {
                        (0.0, 0.0)
                    }
                } else {
                    (0.0, 0.0)
                };
                tri[vi] = MeshVertex {
                    x: sx,
                    y: sy,
                    u,
                    v,
                    r: r.min(1.0),
                    g: g.min(1.0),
                    b: b.min(1.0),
                    a: 1.0,
                };
            }
            let tri_depth = z0.max(z1).max(z2);
            let pick_depth = (z0 + z1 + z2) / 3.0;
            instance_depth = instance_depth.min(pick_depth);
            projected_tris.push((tri_depth, pick_depth, tri));
        }
        projected_tris.sort_by(|a, b| b.0.partial_cmp(&a.0).unwrap_or(std::cmp::Ordering::Equal));
        let Some(vertex_count) = projected_tris.len().checked_mul(3) else {
            return (
                Mesh::from_vertices(Vec::new(), MeshDrawMode::Triangles),
                f32::INFINITY,
                Vec::new(),
            );
        };
        let mut vertices: Vec<MeshVertex> = Vec::new();
        let mut triangle_depths: Vec<f32> = Vec::new();
        if vertices.try_reserve_exact(vertex_count).is_err()
            || triangle_depths
                .try_reserve_exact(projected_tris.len())
                .is_err()
        {
            return (
                Mesh::from_vertices(Vec::new(), MeshDrawMode::Triangles),
                f32::INFINITY,
                Vec::new(),
            );
        }
        for (_, pick_depth, tri) in projected_tris {
            vertices.push(tri[0]);
            vertices.push(tri[1]);
            vertices.push(tri[2]);
            triangle_depths.push(pick_depth);
        }
        (
            Mesh::from_vertices(vertices, MeshDrawMode::Triangles),
            instance_depth,
            triangle_depths,
        )
    }
}
/// Stateless parser wrapper for Wavefront OBJ files.
pub struct ObjLoader;
/// File-based and in-memory OBJ/MTL parsing entry points.
impl ObjLoader {
    /// Legacy host-path loading is disabled so parsing cannot bypass GameFS policy.
    pub fn load_file(_path: impl AsRef<Path>) -> Result<ObjModel, ObjError> {
        Err(ObjError::Parse(
            "host-path OBJ loading is disabled; use GameFS and parse_obj_with_resolver".to_string(),
        ))
    }
    /// Parse OBJ text without host-path material resolution.
    pub fn parse_obj(src: &str, base_dir: &Path) -> Result<ObjModel, ObjError> {
        Self::parse_obj_with_limits(src, base_dir, ObjLimits::default())
    }
    /// Parse bounded OBJ text without host-path material resolution.
    pub fn parse_obj_with_limits(
        src: &str,
        base_dir: &Path,
        limits: ObjLimits,
    ) -> Result<ObjModel, ObjError> {
        let _ = base_dir;
        let mut resolver = RejectingObjResolver;
        Self::parse_obj_with_resolver(src, limits, &mut resolver)
    }
    /// Parse bounded OBJ text using a caller-owned material resolver.
    ///
    /// This is the parser boundary for GameFS, archive, or in-memory callers; it never
    /// chooses a host filesystem path itself.
    pub fn parse_obj_with_resolver(
        src: &str,
        limits: ObjLimits,
        resolver: &mut dyn ObjResolver,
    ) -> Result<ObjModel, ObjError> {
        Self::validate_document_limits(src, limits, "OBJ")?;
        let mut positions: Vec<Vec3> = Vec::new();
        let mut uvs: Vec<Vec2> = Vec::new();
        let mut normals: Vec<Vec3> = Vec::new();
        let mut faces: Vec<ObjFace> = Vec::new();
        let mut materials: Vec<ObjMaterial> = Vec::new();
        let mut mat_index: HashMap<String, usize> = HashMap::new();
        let mut current_mat: Option<usize> = None;
        for line in src.lines() {
            let line = line.trim();
            if line.is_empty() || line.starts_with('#') {
                continue;
            }
            let mut tokens = line.splitn(2, char::is_whitespace);
            let keyword = tokens.next().unwrap_or("");
            let rest = tokens.next().unwrap_or("").trim();
            match keyword {
                "v" => {
                    Self::ensure_limit(positions.len(), limits.max_elements, "OBJ positions")?;
                    let p = Self::parse_vec3(rest)?;
                    positions.push(p);
                }
                "vt" => {
                    Self::ensure_limit(uvs.len(), limits.max_elements, "OBJ texture coordinates")?;
                    let parts = Self::split_floats(rest, 2)?;
                    uvs.push(Vec2 {
                        u: parts[0],
                        v: parts[1],
                    });
                }
                "vn" => {
                    Self::ensure_limit(normals.len(), limits.max_elements, "OBJ normals")?;
                    let p = Self::parse_vec3(rest)?;
                    normals.push(p);
                }
                "mtllib" => {
                    Self::validate_mtllib_reference(rest)?;
                    let mtl_src = resolver.read_material_library(rest)?;
                    let loaded = Self::parse_mtl_with_limits(&mtl_src, Path::new("."), limits)?;
                    for m in loaded {
                        if !mat_index.contains_key(&m.name) {
                            mat_index.insert(m.name.clone(), materials.len());
                            materials.push(m);
                        }
                    }
                }
                "usemtl" => {
                    current_mat = mat_index.get(rest).copied();
                }
                "f" => {
                    let verts =
                        Self::parse_face_verts(rest, positions.len(), uvs.len(), normals.len())?;
                    for i in 1..(verts.len() - 1) {
                        Self::ensure_limit(
                            faces.len(),
                            limits.max_elements,
                            "OBJ triangulated faces",
                        )?;
                        faces.push(ObjFace {
                            verts: [verts[0], verts[i], verts[i + 1]],
                            material: current_mat,
                        });
                    }
                }
                _ => {}
            }
        }
        Ok(ObjModel {
            positions,
            uvs,
            normals,
            faces,
            materials,
        })
    }
    /// Reject material references that are not a relative `.mtl` file path.
    fn validate_mtllib_reference(rest: &str) -> Result<(), ObjError> {
        if rest.is_empty() {
            return Err(ObjError::Parse("mtllib path is empty".to_string()));
        }
        let requested = Path::new(rest);
        if requested.is_absolute() {
            return Err(ObjError::Parse(format!(
                "mtllib path '{}' must be relative",
                rest
            )));
        }
        if requested.components().any(|component| {
            matches!(
                component,
                Component::ParentDir | Component::RootDir | Component::Prefix(_)
            )
        }) {
            return Err(ObjError::Parse(format!(
                "mtllib path '{}' escapes the OBJ base directory",
                rest
            )));
        }
        let is_mtl = requested
            .extension()
            .and_then(|ext| ext.to_str())
            .map(|ext| ext.eq_ignore_ascii_case("mtl"))
            .unwrap_or(false);
        if !is_mtl {
            return Err(ObjError::Parse(format!(
                "mtllib path '{}' must use .mtl extension",
                rest
            )));
        }
        Ok(())
    }
    /// Parse MTL text; extract `newmtl`, `Kd`, and `map_Kd` entries into `ObjMaterial` list.
    fn parse_mtl_with_limits(
        src: &str,
        _base_dir: &Path,
        limits: ObjLimits,
    ) -> Result<Vec<ObjMaterial>, ObjError> {
        Self::validate_document_limits(src, limits, "MTL")?;
        let mut out: Vec<ObjMaterial> = Vec::new();
        let mut current: Option<ObjMaterial> = None;
        for line in src.lines() {
            let line = line.trim();
            if line.is_empty() || line.starts_with('#') {
                continue;
            }
            let mut tokens = line.splitn(2, char::is_whitespace);
            let keyword = tokens.next().unwrap_or("");
            let rest = tokens.next().unwrap_or("").trim();
            match keyword {
                "newmtl" => {
                    if rest.is_empty() {
                        return Err(ObjError::Parse(
                            "MTL material name cannot be empty".to_string(),
                        ));
                    }
                    if let Some(m) = current.take() {
                        Self::ensure_limit(out.len(), limits.max_elements, "MTL materials")?;
                        out.push(m);
                    }
                    current = Some(ObjMaterial {
                        name: rest.to_owned(),
                        diffuse_color: [1.0, 1.0, 1.0],
                        diffuse_map: None,
                    });
                }
                "Kd" => {
                    if let Some(m) = current.as_mut() {
                        let parts = Self::split_floats(rest, 3)?;
                        m.diffuse_color = [parts[0], parts[1], parts[2]];
                    }
                }
                "map_Kd" => {
                    if let Some(m) = current.as_mut() {
                        if rest.is_empty() {
                            return Err(ObjError::Parse(
                                "MTL diffuse texture path cannot be empty".to_string(),
                            ));
                        }
                        m.diffuse_map = Some(rest.to_owned());
                    }
                }
                _ => {}
            }
        }
        if let Some(m) = current {
            Self::ensure_limit(out.len(), limits.max_elements, "MTL materials")?;
            out.push(m);
        }
        Ok(out)
    }
    /// Parse `s` as three whitespace-separated floats into a `Vec3`; return error on bad input.
    fn parse_vec3(s: &str) -> Result<Vec3, ObjError> {
        let parts = Self::split_floats(s, 3)?;
        if !parts.iter().all(|value| value.is_finite()) {
            return Err(ObjError::Parse(
                "OBJ vector values must be finite".to_string(),
            ));
        }
        Ok(Vec3::new(parts[0], parts[1], parts[2]))
    }
    /// Reject source documents that would consume excessive parser memory or scan time.
    fn validate_document_limits(src: &str, limits: ObjLimits, kind: &str) -> Result<(), ObjError> {
        if src.len() > limits.max_bytes {
            return Err(ObjError::Parse(format!(
                "{kind} source exceeds {} bytes",
                limits.max_bytes
            )));
        }
        let mut lines = 0usize;
        for line in src.lines() {
            lines = lines
                .checked_add(1)
                .ok_or_else(|| ObjError::Parse(format!("{kind} line count overflow")))?;
            if lines > limits.max_lines {
                return Err(ObjError::Parse(format!(
                    "{kind} source exceeds {} lines",
                    limits.max_lines
                )));
            }
            if line.len() > limits.max_line_bytes {
                return Err(ObjError::Parse(format!(
                    "{kind} line exceeds {} bytes",
                    limits.max_line_bytes
                )));
            }
        }
        Ok(())
    }
    /// Check a collection before pushing an additional parsed element.
    fn ensure_limit(current: usize, max: usize, name: &str) -> Result<(), ObjError> {
        if current >= max {
            return Err(ObjError::Parse(format!("{name} exceed maximum of {max}")));
        }
        Ok(())
    }
    /// Split `s` into at least `expected` floats; return error when fewer are found.
    fn split_floats(s: &str, expected: usize) -> Result<Vec<f32>, ObjError> {
        let v: Vec<f32> = s
            .split_whitespace()
            .take(expected + 4)
            .map(|t| {
                t.parse::<f32>()
                    .map_err(|_| ObjError::Parse(format!("expected float, got '{}'", t)))
            })
            .collect::<Result<_, _>>()?;
        if v.len() < expected {
            return Err(ObjError::Parse(format!(
                "expected {} floats, got {} in '{}'",
                expected,
                v.len(),
                s
            )));
        }
        if !v.iter().all(|value| value.is_finite()) {
            return Err(ObjError::Parse(
                "OBJ numeric values must be finite".to_string(),
            ));
        }
        Ok(v)
    }
    /// Parse a whitespace-delimited face vertex string into `(pos, uv, normal)` index triples.
    #[allow(clippy::type_complexity)]
    fn parse_face_verts(
        s: &str,
        pos_count: usize,
        uv_count: usize,
        norm_count: usize,
    ) -> Result<Vec<(usize, Option<usize>, Option<usize>)>, ObjError> {
        let mut out = Vec::new();
        for token in s.split_whitespace() {
            let mut parts = token.split('/');
            let pi = Self::parse_index(parts.next(), pos_count)?;
            let ti = Self::parse_index_opt(parts.next(), uv_count)?;
            let ni = Self::parse_index_opt(parts.next(), norm_count)?;
            out.push((pi, ti, ni));
        }
        if out.len() < 3 {
            return Err(ObjError::Parse(format!(
                "face has only {} vertices (need >= 3): '{}'",
                out.len(),
                s
            )));
        }
        Ok(out)
    }
    /// Resolve an OBJ 1-based or negative index into a 0-based index; return error when `s` is empty.
    fn parse_index(s: Option<&str>, count: usize) -> Result<usize, ObjError> {
        match s {
            None | Some("") => Err(ObjError::Parse("missing face index".into())),
            Some(t) => {
                let i: i64 = t
                    .parse()
                    .map_err(|_| ObjError::Parse(format!("bad index '{}'", t)))?;
                if i == 0 {
                    return Err(ObjError::Parse(
                        "OBJ indices are 1-based; got 0".to_string(),
                    ));
                }
                let idx = if i < 0 { count as i64 + i } else { i - 1 };
                if idx < 0 || idx >= count as i64 {
                    return Err(ObjError::Parse(format!(
                        "OBJ index {i} is out of range for {count} values"
                    )));
                }
                Ok(idx as usize)
            }
        }
    }
    /// Like `parse_index` but return `None` for empty or missing tokens.
    fn parse_index_opt(s: Option<&str>, count: usize) -> Result<Option<usize>, ObjError> {
        match s {
            None | Some("") => Ok(None),
            Some(_) => Self::parse_index(s, count).map(Some),
        }
    }
}
/// Perspective camera description for `ObjModel::project_to_mesh`.
#[derive(Debug, Clone, Copy)]
pub struct ObjCamera {
    /// Camera X position in world space.
    pub x: f32,
    /// Camera Y position in world space.
    pub y: f32,
    /// Camera Z position in world space.
    pub z: f32,
    /// Lookat target X.
    pub target_x: f32,
    /// Lookat target Y.
    pub target_y: f32,
    /// Lookat target Z.
    pub target_z: f32,
    /// Vertical field of view in degrees.
    pub fov_y_deg: f32,
}
/// Construction and unpacking helpers for the perspective camera.
impl ObjCamera {
    /// Construct a camera from position, target, and FOV.
    pub fn new(x: f32, y: f32, z: f32, tx: f32, ty: f32, tz: f32, fov_y_deg: f32) -> Self {
        Self {
            x,
            y,
            z,
            target_x: tx,
            target_y: ty,
            target_z: tz,
            fov_y_deg,
        }
    }
    /// Return `(cam_pos, cam_target, fov_y_rad)` unpacked as `Vec3` values.
    pub fn to_vecs(&self) -> (Vec3, Vec3, f32) {
        (
            Vec3::new(self.x, self.y, self.z),
            Vec3::new(self.target_x, self.target_y, self.target_z),
            self.fov_y_deg.to_radians(),
        )
    }
}
