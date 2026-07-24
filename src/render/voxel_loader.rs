//! Loads MagicaVoxel assets into cached, palette-coloured surface triangles for projected rendering.
//! Owns bounded VOX parsing, voxel-to-Y-up coordinate conversion, exposed-face extraction, and model metadata.
//! The resulting geometry is immutable and can be reused by the raycaster without reparsing or remeshing.

use crate::render::mesh::{Mesh, MeshDrawMode, MeshVertex};
use crate::render::obj_loader::Vec3;
use std::collections::HashSet;

/// Maximum dense source cells accepted by one voxel asset.
pub const MAX_VOXEL_CELLS: usize = 16_777_216;
/// Maximum occupied voxels accepted by one voxel asset.
pub const MAX_OCCUPIED_VOXELS: usize = 2_000_000;
/// Maximum triangles emitted by one voxel asset.
pub const MAX_VOXEL_TRIANGLES: usize = 200_000;
/// Maximum compressed MagicaVoxel source accepted before parser allocation.
pub const MAX_VOXEL_SOURCE_BYTES: usize = 64 * 1024 * 1024;

/// One colour-bearing vertex in a cached voxel surface triangle.
#[derive(Debug, Clone, Copy)]
pub struct VoxelVertex {
    /// Local model position in Lurek Y-up coordinates.
    pub position: Vec3,
    /// Palette colour in linear render units.
    pub color: [f32; 4],
}

/// Immutable triangle emitted from the exposed surface of a voxel volume.
#[derive(Debug, Clone, Copy)]
pub struct VoxelTriangle {
    /// Counter-clockwise triangle vertices.
    pub vertices: [VoxelVertex; 3],
}

/// A parsed MagicaVoxel asset represented as palette-coloured surface triangles.
#[derive(Debug, Clone)]
pub struct VoxelModel {
    triangles: Vec<VoxelTriangle>,
    voxel_count: usize,
    source_model_count: usize,
    bounds: [f32; 6],
}

/// Integer transform used while flattening MagicaVoxel's static scene graph.
#[derive(Clone, Copy)]
struct RawTransform {
    /// Column-major signed-permutation rotation matrix.
    cols: [[i32; 3]; 3],
    offset: [i32; 3],
}

impl RawTransform {
    const IDENTITY: Self = Self {
        cols: [[1, 0, 0], [0, 1, 0], [0, 0, 1]],
        offset: [0, 0, 0],
    };

    fn apply(self, point: [i32; 3]) -> [i32; 3] {
        [
            self.cols[0][0] * point[0]
                + self.cols[1][0] * point[1]
                + self.cols[2][0] * point[2]
                + self.offset[0],
            self.cols[0][1] * point[0]
                + self.cols[1][1] * point[1]
                + self.cols[2][1] * point[2]
                + self.offset[1],
            self.cols[0][2] * point[0]
                + self.cols[1][2] * point[1]
                + self.cols[2][2] * point[2]
                + self.offset[2],
        ]
    }

    fn then(self, child: Self) -> Self {
        let mut cols = [[0; 3]; 3];
        for (col, output_column) in cols.iter_mut().enumerate() {
            let basis = [child.cols[col][0], child.cols[col][1], child.cols[col][2]];
            let transformed = self.apply(basis);
            *output_column = [
                transformed[0] - self.offset[0],
                transformed[1] - self.offset[1],
                transformed[2] - self.offset[2],
            ];
        }
        Self {
            cols,
            offset: self.apply(child.offset),
        }
    }
}

fn collect_scene_voxels(
    data: &dot_vox::DotVoxData,
    node_id: u32,
    transform: RawTransform,
    stack: &mut HashSet<u32>,
    out: &mut Vec<(i32, i32, i32, u8)>,
) -> Result<(), String> {
    let node_index = usize::try_from(node_id).map_err(|_| "scene node id is too large")?;
    let node = data
        .scenes
        .get(node_index)
        .ok_or_else(|| format!("scene references missing node {node_id}"))?;
    if !stack.insert(node_id) {
        return Err("MagicaVoxel scene graph contains a cycle".to_string());
    }
    let result = match node {
        dot_vox::SceneNode::Group { children, .. } => {
            for &child in children {
                collect_scene_voxels(data, child, transform, stack, out)?;
            }
            Ok(())
        }
        dot_vox::SceneNode::Transform {
            frames,
            child,
            layer_id,
            ..
        } => {
            if data
                .layers
                .get(usize::try_from(*layer_id).unwrap_or(usize::MAX))
                .is_some_and(dot_vox::Layer::hidden)
            {
                Ok(())
            } else {
                let frame = frames.first().cloned().unwrap_or_default();
                let rotation = frame.orientation().unwrap_or(dot_vox::Rotation::IDENTITY);
                let cols = rotation
                    .to_cols_array_2d()
                    .map(|column| [column[0] as i32, column[1] as i32, column[2] as i32]);
                let offset = frame.position().map_or([0, 0, 0], |p| [p.x, p.y, p.z]);
                collect_scene_voxels(
                    data,
                    *child,
                    transform.then(RawTransform { cols, offset }),
                    stack,
                    out,
                )
            }
        }
        dot_vox::SceneNode::Shape { models, .. } => {
            for shape_model in models {
                let model = data
                    .models
                    .get(shape_model.model_id as usize)
                    .ok_or_else(|| {
                        format!("scene references missing model {}", shape_model.model_id)
                    })?;
                for voxel in &model.voxels {
                    let point = transform.apply([
                        i32::from(voxel.x),
                        i32::from(voxel.y),
                        i32::from(voxel.z),
                    ]);
                    out.push((point[0], point[1], point[2], voxel.i));
                }
            }
            Ok(())
        }
    };
    stack.remove(&node_id);
    result
}

impl VoxelModel {
    /// Legacy host-path loading is disabled so voxel parsing cannot bypass GameFS policy.
    pub fn load_file(_path: &std::path::Path, _voxel_size: f32) -> Result<Self, String> {
        Err("host-path voxel loading is disabled; use GameFS and load_bytes".to_string())
    }

    /// Parse a caller-owned, policy-authorized MagicaVoxel byte stream.
    pub fn load_bytes(bytes: &[u8], voxel_size: f32) -> Result<Self, String> {
        if !voxel_size.is_finite() || voxel_size <= 0.0 {
            return Err("voxel_size must be finite and > 0".to_string());
        }
        if bytes.len() > MAX_VOXEL_SOURCE_BYTES {
            return Err(format!(
                "MagicaVoxel source has {} bytes; limit is {MAX_VOXEL_SOURCE_BYTES}",
                bytes.len()
            ));
        }
        let data = dot_vox::load_bytes(bytes)
            .map_err(|error| format!("failed to parse MagicaVoxel file: {error}"))?;
        Self::from_data(&data, voxel_size)
    }

    /// Construct a cached surface mesh from all visible nodes in a static VOX scene.
    pub fn from_data(data: &dot_vox::DotVoxData, voxel_size: f32) -> Result<Self, String> {
        if data.models.is_empty() {
            return Err("MagicaVoxel file contains no models".to_string());
        }
        let mut voxels = Vec::new();
        if data.scenes.is_empty() {
            let model = &data.models[0];
            voxels.extend(
                model
                    .voxels
                    .iter()
                    .map(|v| (i32::from(v.x), i32::from(v.y), i32::from(v.z), v.i)),
            );
        } else {
            let mut stack = HashSet::new();
            collect_scene_voxels(data, 0, RawTransform::IDENTITY, &mut stack, &mut voxels)?;
        }
        Self::from_voxels(&voxels, &data.palette, voxel_size, data.models.len())
    }

    /// Construct a cached surface mesh from one parsed VOX model.
    pub fn from_model(
        model: &dot_vox::Model,
        palette: &[dot_vox::Color],
        voxel_size: f32,
        source_model_count: usize,
    ) -> Result<Self, String> {
        if model.size.x == 0 || model.size.y == 0 || model.size.z == 0 {
            return Err("voxel model dimensions must be non-zero".to_string());
        }
        let voxels: Vec<_> = model
            .voxels
            .iter()
            .map(|v| (i32::from(v.x), i32::from(v.y), i32::from(v.z), v.i))
            .collect();
        Self::from_voxels(&voxels, palette, voxel_size, source_model_count)
    }

    fn from_voxels(
        voxels: &[(i32, i32, i32, u8)],
        palette: &[dot_vox::Color],
        voxel_size: f32,
        source_model_count: usize,
    ) -> Result<Self, String> {
        if !voxel_size.is_finite() || voxel_size <= 0.0 {
            return Err("voxel_size must be finite and > 0".to_string());
        }
        if voxels.is_empty() {
            return Err("MagicaVoxel scene contains no visible voxels".to_string());
        }
        if voxels.len() > MAX_OCCUPIED_VOXELS {
            return Err(format!(
                "voxel scene has {} occupied voxels; limit is {MAX_OCCUPIED_VOXELS}",
                voxels.len()
            ));
        }
        let &(first_x, first_y, first_z, _) = voxels
            .first()
            .ok_or_else(|| "MagicaVoxel scene contains no visible voxels".to_string())?;
        let (min_x, min_y, min_z, max_x, max_y, max_z) = voxels.iter().skip(1).fold(
            (first_x, first_y, first_z, first_x, first_y, first_z),
            |(min_x, min_y, min_z, max_x, max_y, max_z), &(x, y, z, _)| {
                (
                    min_x.min(x),
                    min_y.min(y),
                    min_z.min(z),
                    max_x.max(x),
                    max_y.max(y),
                    max_z.max(z),
                )
            },
        );
        let sx = usize::try_from(i64::from(max_x) - i64::from(min_x) + 1)
            .map_err(|_| "voxel scene width is too large")?;
        let sy = usize::try_from(i64::from(max_y) - i64::from(min_y) + 1)
            .map_err(|_| "voxel scene depth is too large")?;
        let sz = usize::try_from(i64::from(max_z) - i64::from(min_z) + 1)
            .map_err(|_| "voxel scene height is too large")?;
        let cell_count = sx
            .checked_mul(sy)
            .and_then(|value| value.checked_mul(sz))
            .ok_or_else(|| "voxel scene dimensions overflow".to_string())?;
        if cell_count > MAX_VOXEL_CELLS {
            return Err(format!(
                "voxel scene has {cell_count} cells; limit is {MAX_VOXEL_CELLS}"
            ));
        }

        let mut cells = vec![None; cell_count];
        for &(raw_x, raw_y, raw_z, palette_index) in voxels {
            let x = usize::try_from(raw_x - min_x).map_err(|_| "invalid voxel x coordinate")?;
            let y = usize::try_from(raw_y - min_y).map_err(|_| "invalid voxel y coordinate")?;
            let z = usize::try_from(raw_z - min_z).map_err(|_| "invalid voxel z coordinate")?;
            let colour = palette
                .get(usize::from(palette_index))
                .copied()
                .ok_or_else(|| "voxel references a missing palette colour".to_string())?;
            if colour.a != 255 {
                return Err(
                    "partially transparent voxel palette colours are not supported".to_string(),
                );
            }
            cells[(x * sy + y) * sz + z] = Some(palette_index);
        }

        let index = |x: usize, y: usize, z: usize| (x * sy + y) * sz + z;
        let occupied = |x: isize, y: isize, z: isize| {
            x >= 0
                && y >= 0
                && z >= 0
                && (x as usize) < sx
                && (y as usize) < sy
                && (z as usize) < sz
                && cells[index(x as usize, y as usize, z as usize)].is_some()
        };
        let mut triangles = Vec::new();
        let half_x = sx as f32 * voxel_size * 0.5;
        let half_z = sy as f32 * voxel_size * 0.5;
        let point = |x: usize, y: usize, z: usize| {
            Vec3::new(
                x as f32 * voxel_size - half_x,
                z as f32 * voxel_size,
                y as f32 * voxel_size - half_z,
            )
        };
        let mut push_face =
            |corners: [Vec3; 4], colour: dot_vox::Color, normal: Vec3| -> Result<(), String> {
                if triangles.len().saturating_add(2) > MAX_VOXEL_TRIANGLES {
                    return Err(format!(
                        "voxel surface has more than {MAX_VOXEL_TRIANGLES} triangles"
                    ));
                }
                let light = (0.35
                    + 0.65 * normal.dot(Vec3::new(0.5, 1.0, 0.7).normalise()).max(0.0))
                .clamp(0.0, 1.0);
                let color = [
                    colour.r as f32 / 255.0 * light,
                    colour.g as f32 / 255.0 * light,
                    colour.b as f32 / 255.0 * light,
                    1.0,
                ];
                let vertex = |position| VoxelVertex { position, color };
                triangles.push(VoxelTriangle {
                    vertices: [vertex(corners[0]), vertex(corners[1]), vertex(corners[2])],
                });
                triangles.push(VoxelTriangle {
                    vertices: [vertex(corners[0]), vertex(corners[2]), vertex(corners[3])],
                });
                Ok(())
            };

        for x in 0..sx {
            for y in 0..sy {
                for z in 0..sz {
                    let Some(colour_index) = cells[index(x, y, z)] else {
                        continue;
                    };
                    let colour = palette[usize::from(colour_index)];
                    let p000 = point(x, y, z);
                    let p001 = point(x, y, z + 1);
                    let p010 = point(x, y + 1, z);
                    let p011 = point(x, y + 1, z + 1);
                    let p100 = point(x + 1, y, z);
                    let p101 = point(x + 1, y, z + 1);
                    let p110 = point(x + 1, y + 1, z);
                    let p111 = point(x + 1, y + 1, z + 1);
                    if !occupied(x as isize - 1, y as isize, z as isize) {
                        push_face([p000, p010, p011, p001], colour, Vec3::new(-1.0, 0.0, 0.0))?;
                    }
                    if !occupied(x as isize + 1, y as isize, z as isize) {
                        push_face([p100, p101, p111, p110], colour, Vec3::new(1.0, 0.0, 0.0))?;
                    }
                    if !occupied(x as isize, y as isize - 1, z as isize) {
                        push_face([p000, p001, p101, p100], colour, Vec3::new(0.0, 0.0, -1.0))?;
                    }
                    if !occupied(x as isize, y as isize + 1, z as isize) {
                        push_face([p010, p110, p111, p011], colour, Vec3::new(0.0, 0.0, 1.0))?;
                    }
                    if !occupied(x as isize, y as isize, z as isize - 1) {
                        push_face([p000, p100, p110, p010], colour, Vec3::new(0.0, -1.0, 0.0))?;
                    }
                    if !occupied(x as isize, y as isize, z as isize + 1) {
                        push_face([p001, p011, p111, p101], colour, Vec3::new(0.0, 1.0, 0.0))?;
                    }
                }
            }
        }
        Ok(Self {
            triangles,
            voxel_count: voxels.len(),
            source_model_count,
            bounds: [
                -half_x,
                0.0,
                -half_z,
                half_x,
                sz as f32 * voxel_size,
                half_z,
            ],
        })
    }

    /// Return the number of occupied source voxels.
    pub fn voxel_count(&self) -> usize {
        self.voxel_count
    }
    /// Return the number of source models contained by the file.
    pub fn source_model_count(&self) -> usize {
        self.source_model_count
    }
    /// Return the emitted surface triangle count.
    pub fn triangle_count(&self) -> usize {
        self.triangles.len()
    }
    /// Return local bounds `[min_x, min_y, min_z, max_x, max_y, max_z]`.
    pub fn bounds(&self) -> [f32; 6] {
        self.bounds
    }

    /// Project one world-space instance into a transient 2D mesh.
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
        yaw: f32,
        scale: f32,
    ) -> (Mesh, f32, Vec<f32>) {
        let forward = cam_target.sub(cam_pos).normalise();
        let right = forward.cross(Vec3::new(0.0, 1.0, 0.0)).normalise();
        let up = right.cross(forward).normalise();
        let aspect = screen_w / screen_h;
        let tan_half_fov = (fov_y * 0.5).tan();
        let (c, s) = (yaw.cos(), yaw.sin());
        let mut projected = Vec::new();
        let mut instance_depth = f32::INFINITY;
        for triangle in &self.triangles {
            let positions = triangle.vertices.map(|vertex| {
                let local = vertex.position;
                Vec3::new(
                    world_x + (local.x * c + local.z * s) * scale,
                    floor_y + local.y * scale,
                    world_z + (-local.x * s + local.z * c) * scale,
                )
            });
            let depths = positions.map(|position| position.sub(cam_pos).dot(forward));
            if depths.iter().any(|depth| *depth <= 0.05) {
                continue;
            }
            let normal = positions[1]
                .sub(positions[0])
                .cross(positions[2].sub(positions[0]))
                .normalise();
            if normal.dot(cam_pos.sub(positions[0]).normalise()) <= 0.0 {
                continue;
            }
            let vertices: [MeshVertex; 3] = std::array::from_fn(|i| {
                let rel = positions[i].sub(cam_pos);
                let depth = rel.dot(forward).max(0.001);
                MeshVertex {
                    x: (rel.dot(right) / (depth * tan_half_fov * aspect) + 1.0) * 0.5 * screen_w,
                    y: (1.0 - (rel.dot(up) / (depth * tan_half_fov) + 1.0) * 0.5) * screen_h,
                    u: 0.0,
                    v: 0.0,
                    r: triangle.vertices[i].color[0],
                    g: triangle.vertices[i].color[1],
                    b: triangle.vertices[i].color[2],
                    a: triangle.vertices[i].color[3],
                }
            });
            let pick_depth = (depths[0] + depths[1] + depths[2]) / 3.0;
            instance_depth = instance_depth.min(pick_depth);
            projected.push((
                depths[0].max(depths[1]).max(depths[2]),
                pick_depth,
                vertices,
            ));
        }
        projected.sort_by(|a, b| b.0.partial_cmp(&a.0).unwrap_or(std::cmp::Ordering::Equal));
        let mut vertices = Vec::with_capacity(projected.len() * 3);
        let mut triangle_depths = Vec::with_capacity(projected.len());
        for (_, depth, triangle) in projected {
            vertices.extend(triangle);
            triangle_depths.push(depth);
        }
        (
            Mesh::from_vertices(vertices, MeshDrawMode::Triangles),
            instance_depth,
            triangle_depths,
        )
    }
}
