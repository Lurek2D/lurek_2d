//! Defines reusable 2D mesh data for custom vector geometry, imported models, and textured draw content.
//! Stores vertex positions, colors, uv maps, topology mode, and optional texture binding under one asset type.
//! Supports multiple draw topologies so callers can express lists, strips, fans, or related mesh patterns.
//! Acts as the mesh-asset boundary between content generation and later tessellation or draw submission code.
//! Open this file when mesh vertex data, topology choice, or texture attachment behavior looks incorrect.

use crate::log_msg;
use crate::runtime::log_messages::MS01;
use crate::runtime::resource_keys::TextureKey;
use std::fmt;

/// Triangle topology when submitting a `Mesh` to the GPU.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum MeshDrawMode {
    /// Interpret every three indices as an independent triangle.
    Triangles,
    /// Treat indices as a triangle fan around the first vertex.
    Fan,
    /// Treat indices as a triangle strip.
    Strip,
}
/// A single mesh vertex: 2D position, UV, and RGBA color.
#[derive(Debug, Clone, Copy)]
pub struct MeshVertex {
    /// X screen or world coordinate.
    pub x: f32,
    /// Y screen or world coordinate.
    pub y: f32,
    /// Texture U coordinate, 0.0..1.0.
    pub u: f32,
    /// Texture V coordinate, 0.0..1.0.
    pub v: f32,
    /// Red channel, 0.0..1.0.
    pub r: f32,
    /// Green channel, 0.0..1.0.
    pub g: f32,
    /// Blue channel, 0.0..1.0.
    pub b: f32,
    /// Alpha channel, 0.0..1.0.
    pub a: f32,
}
/// Provide `Default` for `MeshVertex`.
impl Default for MeshVertex {
    fn default() -> Self {
        Self {
            x: 0.0,
            y: 0.0,
            u: 0.0,
            v: 0.0,
            r: 1.0,
            g: 1.0,
            b: 1.0,
            a: 1.0,
        }
    }
}

/// Validation error for malformed mesh topology or vertex data.
#[derive(Debug, Clone, PartialEq)]
pub enum MeshError {
    /// A vertex field contains NaN or infinity.
    NonFiniteVertex {
        /// Zero-based vertex position.
        vertex_index: usize,
        /// Field name on `MeshVertex`.
        field: &'static str,
    },
    /// An index references a vertex outside the mesh.
    InvalidIndex {
        /// Zero-based position inside the index/source sequence.
        index_position: usize,
        /// Referenced vertex index.
        vertex_index: usize,
        /// Number of vertices available.
        vertex_count: usize,
    },
    /// Triangle-list topology has a source index count that is not divisible by 3.
    InvalidTriangleIndexCount {
        /// Number of source indices.
        index_count: usize,
    },
}

impl fmt::Display for MeshError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::NonFiniteVertex {
                vertex_index,
                field,
            } => write!(
                f,
                "mesh vertex {vertex_index} has non-finite {field} value"
            ),
            Self::InvalidIndex {
                index_position,
                vertex_index,
                vertex_count,
            } => write!(
                f,
                "mesh index {index_position} references vertex {vertex_index}, but mesh has {vertex_count} vertices"
            ),
            Self::InvalidTriangleIndexCount { index_count } => write!(
                f,
                "triangle-list mesh source index count {index_count} is not divisible by 3"
            ),
        }
    }
}

impl std::error::Error for MeshError {}

/// A drawable 2D geometry object built from `MeshVertex` data.
#[derive(Debug, Clone)]
pub struct Mesh {
    /// All vertices in the mesh.
    pub vertices: Vec<MeshVertex>,
    /// Optional index list; when `None`, vertices are drawn in order.
    pub indices: Option<Vec<u32>>,
    /// Optional texture bound for all draw calls on this mesh.
    pub texture: Option<TextureKey>,
    /// Triangle topology used when submitting this mesh to the GPU.
    pub draw_mode: MeshDrawMode,
}
impl Mesh {
    /// Allocate a mesh of `vertex_count` default-white vertices in the given draw mode.
    pub fn new(vertex_count: usize, mode: MeshDrawMode) -> Self {
        log_msg!(trace, MS01, "{}", vertex_count);
        Self {
            vertices: vec![MeshVertex::default(); vertex_count],
            indices: None,
            texture: None,
            draw_mode: mode,
        }
    }
    /// Create a mesh directly from an existing `Vec<MeshVertex>` without index reuse.
    pub fn from_vertices(vertices: Vec<MeshVertex>, mode: MeshDrawMode) -> Self {
        Self {
            vertices,
            indices: None,
            texture: None,
            draw_mode: mode,
        }
    }
    /// Build a mesh from a slice of `[x, y, u, v, r, g, b, a]` row arrays.
    pub fn from_vertex_rows(rows: &[[f32; 8]], mode: MeshDrawMode) -> Self {
        let vertices: Vec<MeshVertex> = rows
            .iter()
            .map(|r| MeshVertex {
                x: r[0],
                y: r[1],
                u: r[2],
                v: r[3],
                r: r[4],
                g: r[5],
                b: r[6],
                a: r[7],
            })
            .collect();
        Self::from_vertices(vertices, mode)
    }
    /// Set the vertex at `index`; returns `false` when `index` is out of bounds.
    pub fn set_vertex(&mut self, index: usize, vertex: MeshVertex) -> bool {
        if let Some(slot) = self.vertices.get_mut(index) {
            *slot = vertex;
            true
        } else {
            false
        }
    }
    /// Return a reference to the vertex at `index`, or `None` when out of bounds.
    pub fn get_vertex(&self, index: usize) -> Option<&MeshVertex> {
        self.vertices.get(index)
    }
    /// Replace the index buffer with `indices`.
    pub fn set_vertex_map(&mut self, indices: Vec<u32>) {
        self.indices = Some(indices);
    }
    /// Return the number of vertices in this mesh.
    pub fn vertex_count(&self) -> usize {
        self.vertices.len()
    }
    /// Bind or unbind a texture for subsequent draw calls on this mesh.
    pub fn set_texture(&mut self, texture: Option<TextureKey>) {
        self.texture = texture;
    }
    /// Change the triangle topology for this mesh.
    pub fn set_draw_mode(&mut self, mode: MeshDrawMode) {
        self.draw_mode = mode;
    }
    /// Validate vertex finiteness, index bounds, and triangle-list grouping.
    pub fn validate(&self) -> Result<(), MeshError> {
        for (vertex_index, vertex) in self.vertices.iter().enumerate() {
            validate_finite(vertex.x, vertex_index, "x")?;
            validate_finite(vertex.y, vertex_index, "y")?;
            validate_finite(vertex.u, vertex_index, "u")?;
            validate_finite(vertex.v, vertex_index, "v")?;
            validate_finite(vertex.r, vertex_index, "r")?;
            validate_finite(vertex.g, vertex_index, "g")?;
            validate_finite(vertex.b, vertex_index, "b")?;
            validate_finite(vertex.a, vertex_index, "a")?;
        }

        let source_len = self
            .indices
            .as_ref()
            .map_or(self.vertices.len(), std::vec::Vec::len);
        if self.draw_mode == MeshDrawMode::Triangles && !source_len.is_multiple_of(3) {
            return Err(MeshError::InvalidTriangleIndexCount {
                index_count: source_len,
            });
        }

        if let Some(indices) = &self.indices {
            for (index_position, &vertex_index) in indices.iter().enumerate() {
                let vertex_index = vertex_index as usize;
                if vertex_index >= self.vertices.len() {
                    return Err(MeshError::InvalidIndex {
                        index_position,
                        vertex_index,
                        vertex_count: self.vertices.len(),
                    });
                }
            }
        }

        Ok(())
    }
    /// Return independent triangle indices after validating mesh input.
    pub fn try_triangulate(&self) -> Result<Vec<usize>, MeshError> {
        self.validate()?;
        Ok(self.triangulate_unchecked())
    }
    /// Return a flat list of vertex indices expanding Fan/Strip and indexed modes into independent triangles.
    pub fn triangulate(&self) -> Vec<usize> {
        self.try_triangulate().unwrap_or_default()
    }
    fn triangulate_unchecked(&self) -> Vec<usize> {
        let source_indices: Vec<usize> = if let Some(idx) = &self.indices {
            idx.iter().map(|i| *i as usize).collect()
        } else {
            (0..self.vertices.len()).collect()
        };
        match self.draw_mode {
            MeshDrawMode::Triangles => source_indices,
            MeshDrawMode::Fan => {
                if source_indices.len() < 3 {
                    return Vec::new();
                }
                let mut out = Vec::with_capacity((source_indices.len() - 2) * 3);
                let hub = source_indices[0];
                for i in 1..source_indices.len() - 1 {
                    out.push(hub);
                    out.push(source_indices[i]);
                    out.push(source_indices[i + 1]);
                }
                out
            }
            MeshDrawMode::Strip => {
                if source_indices.len() < 3 {
                    return Vec::new();
                }
                let mut out = Vec::with_capacity((source_indices.len() - 2) * 3);
                for i in 0..source_indices.len() - 2 {
                    if i % 2 == 0 {
                        out.push(source_indices[i]);
                        out.push(source_indices[i + 1]);
                        out.push(source_indices[i + 2]);
                    } else {
                        out.push(source_indices[i + 1]);
                        out.push(source_indices[i]);
                        out.push(source_indices[i + 2]);
                    }
                }
                out
            }
        }
    }
}

fn validate_finite(value: f32, vertex_index: usize, field: &'static str) -> Result<(), MeshError> {
    if value.is_finite() {
        Ok(())
    } else {
        Err(MeshError::NonFiniteVertex {
            vertex_index,
            field,
        })
    }
}
