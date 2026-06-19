//! This file owns `TerrainMap`, a chunked solid-cell grid that rebuilds static physics bodies only where edits occur.
//! It stores map dimensions, cell scale, world offsets, per-cell solidity, spawned chunk body ids, and dirty chunks.
//! Editing helpers flip single cells or fill circles, rectangles, and whole maps so gameplay can carve or restore terrain.
//! Flush logic removes stale chunk colliders, merges horizontal solid runs, and respawns compact static bodies in `World`.
//! Collapse and debris helpers support destructible terrain flows by pruning unsupported cells and spawning fragments.
//! Image and byte serialization make the same terrain usable for previews, saves, reloads, and external authoring tools.
//! Open this file when terrain editing or sync semantics change; body simulation and contact solving live in siblings.

use super::body::{Body, BodyType};
use super::error::PhysicsError;
use super::limits::{
    checked_terrain_cells, checked_terrain_image_bytes, validate_finite, validate_positive,
    PhysicsLimits,
};
use super::world::World;
use std::collections::{HashMap, HashSet};

/// Chunk dimension in cells per axis.
const CHUNK_SIZE: u32 = 16;
const TERRAIN_BYTES_VERSION: u32 = 1;

/// Key identifying a chunk by its chunk-grid coordinates.
/// # Fields
/// - `cx`: chunk-space column index.
/// - `cy`: chunk-space row index.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct ChunkId {
    /// Column index in chunk space.
    pub cx: u32,
    /// Row index in chunk space.
    pub cy: u32,
}

/// Tile-based terrain map that synchronises static physics bodies with a `World`.
/// # Fields
/// - `width`: grid width in cells.
/// - `height`: grid height in cells.
/// - `cell_size`: world-space cell size.
/// - `offset_x`: world-space x origin.
/// - `offset_y`: world-space y origin.
pub struct TerrainMap {
    /// Grid width in cells.
    pub width: u32,
    /// Grid height in cells.
    pub height: u32,
    /// World units per cell side.
    pub cell_size: f32,
    /// World-space x origin of the grid.
    pub offset_x: f32,
    /// World-space y origin of the grid.
    pub offset_y: f32,
    /// Flat row-major solidity flags.
    cells: Vec<bool>,
    /// Body ids spawned per chunk.
    chunk_body_ids: HashMap<ChunkId, Vec<usize>>,
    /// Chunks that need their bodies rebuilt on the next `flush`.
    dirty_chunks: HashSet<ChunkId>,
}
/// All methods for `TerrainMap`.
impl TerrainMap {
    fn full_dirty_set(width: u32, height: u32) -> HashSet<ChunkId> {
        let chunk_cols = width.div_ceil(CHUNK_SIZE);
        let chunk_rows = height.div_ceil(CHUNK_SIZE);
        let mut dirty_chunks = HashSet::new();
        for cy in 0..chunk_rows {
            for cx in 0..chunk_cols {
                dirty_chunks.insert(ChunkId { cx, cy });
            }
        }
        dirty_chunks
    }

    /// Create an empty terrain map of `width x height` cells with `cell_size` world units each using strict validation.
    pub fn try_new(width: u32, height: u32, cell_size: f32) -> Result<Self, PhysicsError> {
        Self::try_new_with_limits(width, height, cell_size, &PhysicsLimits::default())
    }

    /// Create an empty terrain map using explicit shared safety limits.
    pub fn try_new_with_limits(
        width: u32,
        height: u32,
        cell_size: f32,
        limits: &PhysicsLimits,
    ) -> Result<Self, PhysicsError> {
        if width == 0 || height == 0 {
            return Err(PhysicsError::InvalidTerrainDimensions { width, height });
        }
        validate_positive("cell_size", f64::from(cell_size))?;
        if cell_size < limits.min_cell_size {
            return Err(PhysicsError::ValueOutOfRange {
                field: "cell_size",
                min: f64::from(limits.min_cell_size),
                max: f64::from(f32::MAX),
                value: f64::from(cell_size),
            });
        }
        let total = checked_terrain_cells(width, height, limits)?;
        Ok(Self {
            width,
            height,
            cell_size,
            offset_x: 0.0,
            offset_y: 0.0,
            cells: vec![false; total],
            chunk_body_ids: HashMap::new(),
            dirty_chunks: HashSet::new(),
        })
    }

    /// Create an empty terrain map of `width x height` cells with `cell_size` world units each.
    pub fn new(width: u32, height: u32, cell_size: f32) -> Self {
        Self::try_new(width, height, cell_size).unwrap_or_else(|_| Self {
            width: width.max(1),
            height: height.max(1),
            cell_size: if cell_size.is_finite() {
                cell_size.abs().max(1.0)
            } else {
                1.0
            },
            offset_x: 0.0,
            offset_y: 0.0,
            cells: vec![false; usize::try_from(width.max(1) * height.max(1)).unwrap_or(1)],
            chunk_body_ids: HashMap::new(),
            dirty_chunks: HashSet::new(),
        })
    }

    /// Set the solid state of cell `(cx,cy)`; marks the owning chunk dirty when the value changes.
    pub fn set_cell(&mut self, cx: u32, cy: u32, solid: bool) {
        if cx >= self.width || cy >= self.height {
            return;
        }
        let idx = (cy * self.width + cx) as usize;
        if self.cells[idx] != solid {
            self.cells[idx] = solid;
            self.mark_dirty(cx, cy);
        }
    }

    /// Return whether cell `(cx,cy)` is solid; false when out of bounds.
    pub fn get_cell(&self, cx: u32, cy: u32) -> bool {
        if cx >= self.width || cy >= self.height {
            return false;
        }
        self.cells[(cy * self.width + cx) as usize]
    }

    /// Strictly fill all cells within `radius` world units of `(wx,wy)` to `solid`.
    pub fn try_fill_circle(
        &mut self,
        wx: f32,
        wy: f32,
        radius: f32,
        solid: bool,
    ) -> Result<(), PhysicsError> {
        validate_positive("cell_size", f64::from(self.cell_size))?;
        validate_finite("wx", f64::from(wx))?;
        validate_finite("wy", f64::from(wy))?;
        validate_positive("radius", f64::from(radius))?;
        let cell_cx = ((wx - self.offset_x) / self.cell_size) as i64;
        let cell_cy = ((wy - self.offset_y) / self.cell_size) as i64;
        let cell_r = (radius / self.cell_size).ceil() as i64 + 1;
        let r2 = radius * radius;
        for dy in -cell_r..=cell_r {
            for dx in -cell_r..=cell_r {
                let cx = cell_cx + dx;
                let cy = cell_cy + dy;
                if cx < 0 || cy < 0 || cx >= self.width as i64 || cy >= self.height as i64 {
                    continue;
                }
                let world_x = self.offset_x + (cx as f32 + 0.5) * self.cell_size;
                let world_y = self.offset_y + (cy as f32 + 0.5) * self.cell_size;
                let ddx = world_x - wx;
                let ddy = world_y - wy;
                if ddx * ddx + ddy * ddy <= r2 {
                    self.set_cell(cx as u32, cy as u32, solid);
                }
            }
        }
        Ok(())
    }

    /// Set all cells within `radius` world units of `(wx,wy)` to `solid`.
    pub fn fill_circle(&mut self, wx: f32, wy: f32, radius: f32, solid: bool) {
        let _ = self.try_fill_circle(wx, wy, radius, solid);
    }

    /// Strictly set all cells overlapping the world-space rectangle to `solid`.
    pub fn try_fill_rect(
        &mut self,
        wx: f32,
        wy: f32,
        w: f32,
        h: f32,
        solid: bool,
    ) -> Result<(), PhysicsError> {
        validate_positive("cell_size", f64::from(self.cell_size))?;
        validate_finite("wx", f64::from(wx))?;
        validate_finite("wy", f64::from(wy))?;
        validate_positive("width", f64::from(w))?;
        validate_positive("height", f64::from(h))?;
        let x0 = ((wx - self.offset_x) / self.cell_size).floor() as i64;
        let y0 = ((wy - self.offset_y) / self.cell_size).floor() as i64;
        let x1 = ((wx + w - self.offset_x) / self.cell_size).ceil() as i64;
        let y1 = ((wy + h - self.offset_y) / self.cell_size).ceil() as i64;
        for cy in y0..y1 {
            for cx in x0..x1 {
                if cx >= 0 && cy >= 0 && cx < self.width as i64 && cy < self.height as i64 {
                    self.set_cell(cx as u32, cy as u32, solid);
                }
            }
        }
        Ok(())
    }

    /// Set all cells overlapping the world-space rectangle to `solid`.
    pub fn fill_rect(&mut self, wx: f32, wy: f32, w: f32, h: f32, solid: bool) {
        let _ = self.try_fill_rect(wx, wy, w, h, solid);
    }

    /// Set every cell to `solid` and mark all chunks dirty.
    pub fn fill_all(&mut self, solid: bool) {
        for v in &mut self.cells {
            *v = solid;
        }
        self.dirty_chunks = Self::full_dirty_set(self.width, self.height);
    }

    /// Return true when any chunks are pending a `flush`.
    pub fn is_dirty(&self) -> bool {
        !self.dirty_chunks.is_empty()
    }

    /// Mark the chunk containing `(cx,cy)` as dirty.
    fn mark_dirty(&mut self, cx: u32, cy: u32) {
        self.dirty_chunks.insert(ChunkId {
            cx: cx / CHUNK_SIZE,
            cy: cy / CHUNK_SIZE,
        });
    }

    /// Rebuild bodies in all dirty chunks and sync them into `world`.
    pub fn flush(&mut self, world: &mut World) {
        let dirty: Vec<ChunkId> = self.dirty_chunks.drain().collect();
        for chunk in dirty {
            if let Some(old_ids) = self.chunk_body_ids.remove(&chunk) {
                for id in old_ids {
                    world.destroy_body(id);
                }
            }
            let cell_x0 = chunk.cx * CHUNK_SIZE;
            let cell_y0 = chunk.cy * CHUNK_SIZE;
            let cell_x1 = (cell_x0 + CHUNK_SIZE).min(self.width);
            let cell_y1 = (cell_y0 + CHUNK_SIZE).min(self.height);
            let mut new_ids: Vec<usize> = Vec::new();
            for cy in cell_y0..cell_y1 {
                let mut run_start: Option<u32> = None;
                for cx in cell_x0..=cell_x1 {
                    let solid = if cx < cell_x1 {
                        self.cells[(cy * self.width + cx) as usize]
                    } else {
                        false
                    };
                    match (solid, run_start) {
                        (true, None) => run_start = Some(cx),
                        (false, Some(start)) => {
                            let run_len = cx - start;
                            let bx = self.offset_x
                                + (start as f32 + run_len as f32 * 0.5) * self.cell_size;
                            let by = self.offset_y + (cy as f32 + 0.5) * self.cell_size;
                            let bw = run_len as f32 * self.cell_size;
                            let bh = self.cell_size;
                            if let Ok(mut body) = Body::try_new(bx, by, bw, bh, BodyType::Static) {
                                body.restitution = 0.0;
                                body.friction = 0.8;
                                new_ids.push(world.add_body(body).0);
                            }
                            run_start = None;
                        }
                        _ => {}
                    }
                }
            }
            if !new_ids.is_empty() {
                self.chunk_body_ids.insert(chunk, new_ids);
            }
        }
    }

    /// Remove isolated single-cell pillars with no support; return the count removed.
    pub fn collapse_columns(&mut self) -> u32 {
        let mut count = 0u32;
        if self.height < 2 {
            return 0;
        }
        for cy in (0..self.height.saturating_sub(1)).rev() {
            for cx in 0..self.width {
                let idx = (cy * self.width + cx) as usize;
                if !self.cells[idx] {
                    continue;
                }
                let below = self.cells[((cy + 1) * self.width + cx) as usize];
                if !below {
                    let left = cx > 0 && self.cells[(cy * self.width + cx - 1) as usize];
                    let right =
                        cx + 1 < self.width && self.cells[(cy * self.width + cx + 1) as usize];
                    if !left && !right {
                        self.cells[idx] = false;
                        self.mark_dirty(cx, cy);
                        count += 1;
                    }
                }
            }
        }
        count
    }

    /// Return the world-space centres of all solid cells.
    pub fn solid_cell_positions(&self) -> Vec<(f32, f32)> {
        let mut out = Vec::new();
        for cy in 0..self.height {
            for cx in 0..self.width {
                if self.cells[(cy * self.width + cx) as usize] {
                    let wx = self.offset_x + (cx as f32 + 0.5) * self.cell_size;
                    let wy = self.offset_y + (cy as f32 + 0.5) * self.cell_size;
                    out.push((wx, wy));
                }
            }
        }
        out
    }

    /// Spawn a dynamic debris body in `world` for each position in `positions`; return body ids.
    pub fn spawn_debris_at(
        &self,
        world: &mut World,
        positions: &[(f32, f32)],
        cell_mass: f32,
        restitution: f32,
    ) -> Vec<usize> {
        positions
            .iter()
            .filter_map(|&(wx, wy)| {
                let mut body =
                    Body::try_new(wx, wy, self.cell_size, self.cell_size, BodyType::Dynamic)
                        .ok()?;
                body.mass = if cell_mass.is_finite() {
                    cell_mass.max(0.000_1)
                } else {
                    1.0
                };
                body.restitution = if restitution.is_finite() {
                    restitution.clamp(0.0, 1.0)
                } else {
                    0.0
                };
                Some(world.add_body(body).0)
            })
            .collect()
    }

    /// Encode the terrain as RGBA pixel data using `solid_rgba` and `empty_rgba` with strict bounds checking.
    pub fn to_image_data_checked(
        &self,
        solid_rgba: [u8; 4],
        empty_rgba: [u8; 4],
    ) -> Result<Vec<u8>, PhysicsError> {
        let len = checked_terrain_image_bytes(self.width, self.height, &PhysicsLimits::default())?;
        let mut buf = Vec::with_capacity(len);
        for &solid in &self.cells {
            let c = if solid { solid_rgba } else { empty_rgba };
            buf.extend_from_slice(&c);
        }
        Ok(buf)
    }

    /// Encode the terrain as RGBA pixel data using `solid_rgba` and `empty_rgba`.
    pub fn to_image_data(&self, solid_rgba: [u8; 4], empty_rgba: [u8; 4]) -> Vec<u8> {
        self.to_image_data_checked(solid_rgba, empty_rgba)
            .unwrap_or_default()
    }

    /// Serialise to a compact byte buffer with version header and bit-packed cells.
    pub fn to_bytes(&self) -> Vec<u8> {
        let mut buf = Vec::new();
        buf.extend_from_slice(&TERRAIN_BYTES_VERSION.to_le_bytes());
        buf.extend_from_slice(&self.width.to_le_bytes());
        buf.extend_from_slice(&self.height.to_le_bytes());
        buf.extend_from_slice(&self.cell_size.to_bits().to_le_bytes());
        let mut bit_byte = 0u8;
        let mut bit_pos = 7i32;
        for &solid in &self.cells {
            if solid {
                bit_byte |= 1 << bit_pos;
            }
            bit_pos -= 1;
            if bit_pos < 0 {
                buf.push(bit_byte);
                bit_byte = 0;
                bit_pos = 7;
            }
        }
        if bit_pos < 7 {
            buf.push(bit_byte);
        }
        buf
    }

    /// Deserialise from a byte buffer produced by `to_bytes`, rejecting malformed sizes and unsafe allocations.
    pub fn from_bytes_with_limits(
        bytes: &[u8],
        limits: &PhysicsLimits,
    ) -> Result<Self, PhysicsError> {
        if bytes.len() < 16 {
            return Err(PhysicsError::InvalidLength {
                context: "physics terrain bytes",
                expected: 16,
                actual: bytes.len(),
            });
        }
        let version = u32::from_le_bytes(bytes[0..4].try_into().unwrap());
        if version != TERRAIN_BYTES_VERSION {
            return Err(PhysicsError::UnsupportedVersion {
                context: "physics terrain bytes",
                version,
            });
        }
        let width = u32::from_le_bytes(bytes[4..8].try_into().unwrap());
        let height = u32::from_le_bytes(bytes[8..12].try_into().unwrap());
        let cell_size = f32::from_bits(u32::from_le_bytes(bytes[12..16].try_into().unwrap()));
        let mut terrain = Self::try_new_with_limits(width, height, cell_size, limits)?;
        let total = checked_terrain_cells(width, height, limits)?;
        let bit_bytes = total.div_ceil(8);
        let expected_len = 16 + bit_bytes;
        if bytes.len() != expected_len {
            return Err(PhysicsError::InvalidLength {
                context: "physics terrain bytes",
                expected: expected_len,
                actual: bytes.len(),
            });
        }
        let bit_buf = &bytes[16..];
        for i in 0..total {
            let byte_idx = i / 8;
            let bit_idx = 7 - (i % 8);
            let byte = bit_buf[byte_idx];
            terrain.cells[i] = (byte >> bit_idx) & 1 == 1;
        }
        terrain.dirty_chunks = Self::full_dirty_set(width, height);
        Ok(terrain)
    }

    /// Deserialise from a byte buffer produced by `to_bytes`; return `None` on error.
    pub fn from_bytes(bytes: &[u8]) -> Option<Self> {
        Self::from_bytes_with_limits(bytes, &PhysicsLimits::default()).ok()
    }

    /// Load bytes into this map if dimensions match; return false on mismatch or parse error.
    pub fn load_from_bytes(&mut self, bytes: &[u8]) -> bool {
        match Self::from_bytes_with_limits(bytes, &PhysicsLimits::default()) {
            Ok(loaded)
                if loaded.width == self.width
                    && loaded.height == self.height
                    && (loaded.cell_size - self.cell_size).abs() <= f32::EPSILON =>
            {
                self.cells = loaded.cells;
                self.dirty_chunks = loaded.dirty_chunks;
                true
            }
            Ok(_) => false,
            Err(_) => false,
        }
    }
}
