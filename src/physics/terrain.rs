//! Owns the physics terrain implementation for the physics subsystem and keeps related runtime rules local here.
//! Keeps body state, simulation helpers, and authored world contracts so helpers stay close to invariants this updates.
//! Defines how physics terrain data is validated, transformed, or stored before neighboring systems consume it.
//! Separates physics terrain behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where physics code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing physics terrain defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near the physics terrain state that explains them instead of spreading rules outward.
//! Preserves deterministic behavior by keeping physics terrain calculations explicit at their owning subsystem boundary.
//! Provides the local adaptation layer that lets callers reuse physics terrain rules without duplicating engine decisions.
//! Open this owner before sibling files when a regression centers on physics terrain state, helpers, or integration rules.
//! Works with neighboring physics owners while keeping the main physics terrain responsibility anchored in one file.

use super::body::{Body, BodyType};
use super::error::PhysicsError;
use super::limits::{
    checked_terrain_cells, checked_terrain_component_scan_cells, checked_terrain_image_bytes,
    validate_finite, validate_positive, validate_range, PhysicsLimits,
};
use super::world::World;
use std::collections::{HashMap, HashSet, VecDeque};
use std::time::Instant;

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

/// Inclusive-low, exclusive-high cell-space bounds for terrain scans or component extents.
/// # Fields
/// - `x0`: First included cell column.
/// - `y0`: First included cell row.
/// - `x1`: One-past-last included cell column.
/// - `y1`: One-past-last included cell row.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct TerrainRegion {
    /// First included cell column.
    pub x0: u32,
    /// First included cell row.
    pub y0: u32,
    /// One-past-last included cell column.
    pub x1: u32,
    /// One-past-last included cell row.
    pub y1: u32,
}

impl TerrainRegion {
    /// Return the full terrain extent for a `width x height` grid.
    pub fn full(width: u32, height: u32) -> Self {
        Self {
            x0: 0,
            y0: 0,
            x1: width,
            y1: height,
        }
    }

    /// Clamp this region to the given terrain bounds and return `None` when it becomes empty.
    pub fn clamped_to(self, width: u32, height: u32) -> Option<Self> {
        let x0 = self.x0.min(width);
        let y0 = self.y0.min(height);
        let x1 = self.x1.min(width);
        let y1 = self.y1.min(height);
        if x0 >= x1 || y0 >= y1 {
            return None;
        }
        Some(Self { x0, y0, x1, y1 })
    }
}

/// One connected solid terrain component expressed as cell coordinates plus support flags.
/// # Fields
/// - `cells`: All solid cells that belong to this connected component.
/// - `bounds`: Cell-space bounds containing every component cell.
/// - `touches_bottom`: Whether any component cell touches the bottom terrain border.
/// - `touches_border`: Whether any component cell touches any terrain border.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct TerrainComponent {
    /// All solid cells that belong to this component.
    pub cells: Vec<(u32, u32)>,
    /// Cell-space bounds covering the component.
    pub bounds: TerrainRegion,
    /// True when the component reaches the bottom border of the terrain map.
    pub touches_bottom: bool,
    /// True when the component reaches any border of the terrain map.
    pub touches_border: bool,
}

/// Support policy used when deciding whether a terrain component should collapse.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TerrainSupportRule {
    /// Components remain supported only when connected to the bottom border.
    Bottom,
    /// Components remain supported when connected to any map border.
    AnyBorder,
}

/// Action applied to unsupported terrain components.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TerrainCollapseMode {
    /// Remove unsupported cells from the terrain grid.
    Remove,
    /// Remove unsupported cells and spawn dynamic debris bodies at sampled cell centers.
    SpawnDebris,
    /// Remove unsupported cells and spawn one dynamic rectangle body per component bounds.
    SpawnDynamicChunks,
    /// Keep unsupported cells unchanged while still reporting detected components.
    KeepStatic,
}

/// Policy options for unsupported-terrain collapse passes.
/// # Fields
/// - `support_rule`: Rule deciding which components count as supported.
/// - `mode`: Action applied to unsupported components that pass the minimum-size filter.
/// - `min_component_cells`: Minimum number of cells a component must have before the policy applies.
/// - `max_debris`: Maximum number of debris bodies to spawn across the whole collapse call.
/// - `debris_mass`: Mass assigned to spawned debris bodies.
/// - `debris_restitution`: Restitution assigned to spawned debris bodies.
#[derive(Debug, Clone, PartialEq)]
pub struct TerrainCollapseOptions {
    /// Rule deciding whether a component is supported.
    pub support_rule: TerrainSupportRule,
    /// Action applied to unsupported components.
    pub mode: TerrainCollapseMode,
    /// Minimum component size in cells before collapse applies.
    pub min_component_cells: u32,
    /// Maximum number of debris bodies spawned across one collapse call.
    pub max_debris: u32,
    /// Mass assigned to each spawned debris body.
    pub debris_mass: f32,
    /// Restitution assigned to each spawned debris body.
    pub debris_restitution: f32,
}

impl Default for TerrainCollapseOptions {
    fn default() -> Self {
        Self {
            support_rule: TerrainSupportRule::Bottom,
            mode: TerrainCollapseMode::Remove,
            min_component_cells: 1,
            max_debris: 64,
            debris_mass: 0.05,
            debris_restitution: 0.2,
        }
    }
}

impl TerrainCollapseOptions {
    /// Validate option values that affect collapse work, debris spawning, and Lua-facing error reporting.
    pub fn validate(&self) -> Result<(), PhysicsError> {
        if matches!(
            self.mode,
            TerrainCollapseMode::SpawnDebris | TerrainCollapseMode::SpawnDynamicChunks
        ) {
            validate_positive("debris_mass", f64::from(self.debris_mass))?;
            validate_range(
                "debris_restitution",
                f64::from(self.debris_restitution),
                0.0,
                1.0,
            )?;
        }
        Ok(())
    }
}

/// Result returned after collapsing unsupported terrain components.
/// # Fields
/// - `components`: Number of unsupported components that matched the size threshold.
/// - `removed_cells`: Number of terrain cells removed from the grid.
/// - `debris_body_ids`: Body ids spawned for debris mode.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct TerrainCollapseResult {
    /// Number of unsupported components matching the threshold.
    pub components: usize,
    /// Number of terrain cells removed by the collapse.
    pub removed_cells: usize,
    /// Body ids created for debris mode.
    pub debris_body_ids: Vec<usize>,
}

/// Diagnostics returned by the most recent terrain collider rebuild pass.
/// # Fields
/// - `dirty_chunks_rebuilt`: Number of dirty chunks rebuilt during this flush call.
/// - `dirty_chunks_remaining`: Number of dirty chunks still queued after this flush call.
/// - `bodies_destroyed`: Number of old terrain bodies removed before rebuild.
/// - `bodies_created`: Number of new terrain bodies created by rebuild.
/// - `elapsed_micros`: Wall-clock duration of the rebuild pass in microseconds.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct TerrainFlushStats {
    /// Number of dirty chunks rebuilt during this flush call.
    pub dirty_chunks_rebuilt: usize,
    /// Number of dirty chunks still queued after this flush call.
    pub dirty_chunks_remaining: usize,
    /// Number of old terrain bodies removed before rebuild.
    pub bodies_destroyed: usize,
    /// Number of new terrain bodies created by rebuild.
    pub bodies_created: usize,
    /// Wall-clock duration of the rebuild pass in microseconds.
    pub elapsed_micros: u128,
}

/// Tile-based terrain map that synchronises static physics bodies with a `World`.
/// # Fields
/// - `width`: Grid width in cells.
/// - `height`: Grid height in cells.
/// - `cell_size`: World units per cell side.
/// - `offset_x`: World-space x origin.
/// - `offset_y`: World-space y origin.
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
    /// Diagnostics captured by the most recent collider rebuild pass.
    last_flush_stats: TerrainFlushStats,
}

/// Terrain editing, scan, collapse, and serialization behavior.
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

    fn cell_index(&self, cx: u32, cy: u32) -> usize {
        (cy * self.width + cx) as usize
    }

    fn world_position_for_cell(&self, cx: u32, cy: u32) -> (f32, f32) {
        let wx = self.offset_x + (cx as f32 + 0.5) * self.cell_size;
        let wy = self.offset_y + (cy as f32 + 0.5) * self.cell_size;
        (wx, wy)
    }

    fn component_supported(component: &TerrainComponent, support_rule: TerrainSupportRule) -> bool {
        match support_rule {
            TerrainSupportRule::Bottom => component.touches_bottom,
            TerrainSupportRule::AnyBorder => component.touches_border,
        }
    }

    fn collect_sampled_component_positions(
        &self,
        component: &TerrainComponent,
        sample_count: usize,
        out: &mut Vec<(f32, f32)>,
    ) {
        if sample_count == 0 || component.cells.is_empty() {
            return;
        }
        if sample_count >= component.cells.len() {
            for &(cx, cy) in &component.cells {
                out.push(self.world_position_for_cell(cx, cy));
            }
            return;
        }
        for sample_index in 0..sample_count {
            let cell_index = sample_index * component.cells.len() / sample_count;
            let (cx, cy) = component.cells[cell_index];
            out.push(self.world_position_for_cell(cx, cy));
        }
    }

    fn spawn_dynamic_chunk_for_component(
        &self,
        world: &mut World,
        component: &TerrainComponent,
        cell_mass: f32,
        restitution: f32,
    ) -> Option<usize> {
        let width_cells = component.bounds.x1.saturating_sub(component.bounds.x0);
        let height_cells = component.bounds.y1.saturating_sub(component.bounds.y0);
        if width_cells == 0 || height_cells == 0 {
            return None;
        }
        let width = width_cells as f32 * self.cell_size;
        let height = height_cells as f32 * self.cell_size;
        let center_x = self.offset_x + component.bounds.x0 as f32 * self.cell_size + width * 0.5;
        let center_y = self.offset_y + component.bounds.y0 as f32 * self.cell_size + height * 0.5;
        let mut body = Body::try_new(center_x, center_y, width, height, BodyType::Dynamic).ok()?;
        body.mass = if cell_mass.is_finite() {
            (cell_mass.max(0.000_1) * component.cells.len() as f32).max(0.000_1)
        } else {
            component.cells.len().max(1) as f32
        };
        body.friction = 0.8;
        body.restitution = if restitution.is_finite() {
            restitution.clamp(0.0, 1.0)
        } else {
            0.0
        };
        Some(world.add_body(body).0)
    }

    fn collapse_unsupported_internal(
        &mut self,
        world: Option<&mut World>,
        options: &TerrainCollapseOptions,
        limits: &PhysicsLimits,
    ) -> Result<TerrainCollapseResult, PhysicsError> {
        options.validate()?;
        let components = self
            .find_unsupported_components_with_limits(options.support_rule, limits)?
            .into_iter()
            .filter(|component| component.cells.len() >= options.min_component_cells as usize)
            .collect::<Vec<_>>();

        let mut result = TerrainCollapseResult {
            components: components.len(),
            ..TerrainCollapseResult::default()
        };
        if components.is_empty() || matches!(options.mode, TerrainCollapseMode::KeepStatic) {
            return Ok(result);
        }

        let mut debris_positions = Vec::new();
        let max_debris = options.max_debris as usize;
        for component in &components {
            if matches!(options.mode, TerrainCollapseMode::SpawnDebris)
                && debris_positions.len() < max_debris
            {
                let remaining = max_debris - debris_positions.len();
                self.collect_sampled_component_positions(
                    component,
                    remaining,
                    &mut debris_positions,
                );
            }
            for &(cx, cy) in &component.cells {
                if self.get_cell(cx, cy) {
                    self.set_cell(cx, cy, false);
                    result.removed_cells += 1;
                }
            }
        }

        match options.mode {
            TerrainCollapseMode::SpawnDebris if !debris_positions.is_empty() => {
                let world = world.ok_or_else(|| PhysicsError::InvalidMode {
                    context: "physics terrain collapse",
                    value: "spawnDebris".to_string(),
                    expected: "remove, keepStatic, or provide a world for spawn modes",
                })?;
                result.debris_body_ids = self.spawn_debris_at(
                    world,
                    &debris_positions,
                    options.debris_mass,
                    options.debris_restitution,
                );
            }
            TerrainCollapseMode::SpawnDynamicChunks => {
                let world = world.ok_or_else(|| PhysicsError::InvalidMode {
                    context: "physics terrain collapse",
                    value: "spawnDynamicChunks".to_string(),
                    expected: "remove, keepStatic, or provide a world for spawn modes",
                })?;
                for component in &components {
                    if let Some(body_id) = self.spawn_dynamic_chunk_for_component(
                        world,
                        component,
                        options.debris_mass,
                        options.debris_restitution,
                    ) {
                        result.debris_body_ids.push(body_id);
                    }
                }
            }
            _ => {}
        }

        Ok(result)
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
            last_flush_stats: TerrainFlushStats::default(),
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
            last_flush_stats: TerrainFlushStats::default(),
        })
    }

    /// Set the solid state of cell `(cx, cy)` and mark the owning chunk dirty when the value changes.
    pub fn set_cell(&mut self, cx: u32, cy: u32, solid: bool) {
        if cx >= self.width || cy >= self.height {
            return;
        }
        let idx = self.cell_index(cx, cy);
        if self.cells[idx] != solid {
            self.cells[idx] = solid;
            self.mark_dirty(cx, cy);
        }
    }

    /// Return whether cell `(cx, cy)` is solid; returns false when out of bounds.
    pub fn get_cell(&self, cx: u32, cy: u32) -> bool {
        if cx >= self.width || cy >= self.height {
            return false;
        }
        self.cells[self.cell_index(cx, cy)]
    }

    /// Strictly fill all cells within `radius` world units of `(wx, wy)` to `solid`.
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

    /// Set all cells within `radius` world units of `(wx, wy)` to `solid`.
    pub fn fill_circle(&mut self, wx: f32, wy: f32, radius: f32, solid: bool) {
        let _ = self.try_fill_circle(wx, wy, radius, solid);
    }

    /// Strictly clear all cells within `radius` world units of `(wx, wy)`.
    pub fn try_carve_circle(&mut self, wx: f32, wy: f32, radius: f32) -> Result<(), PhysicsError> {
        self.try_fill_circle(wx, wy, radius, false)
    }

    /// Clear all cells within `radius` world units of `(wx, wy)`.
    pub fn carve_circle(&mut self, wx: f32, wy: f32, radius: f32) {
        let _ = self.try_carve_circle(wx, wy, radius);
    }

    /// Strictly fill all cells within `radius` world units of `(wx, wy)`.
    pub fn try_add_circle(&mut self, wx: f32, wy: f32, radius: f32) -> Result<(), PhysicsError> {
        self.try_fill_circle(wx, wy, radius, true)
    }

    /// Fill all cells within `radius` world units of `(wx, wy)`.
    pub fn add_circle(&mut self, wx: f32, wy: f32, radius: f32) {
        let _ = self.try_add_circle(wx, wy, radius);
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

    /// Strictly clear all cells overlapping the world-space rectangle.
    pub fn try_carve_rect(&mut self, wx: f32, wy: f32, w: f32, h: f32) -> Result<(), PhysicsError> {
        self.try_fill_rect(wx, wy, w, h, false)
    }

    /// Clear all cells overlapping the world-space rectangle.
    pub fn carve_rect(&mut self, wx: f32, wy: f32, w: f32, h: f32) {
        let _ = self.try_carve_rect(wx, wy, w, h);
    }

    /// Strictly fill all cells overlapping the world-space rectangle.
    pub fn try_add_rect(&mut self, wx: f32, wy: f32, w: f32, h: f32) -> Result<(), PhysicsError> {
        self.try_fill_rect(wx, wy, w, h, true)
    }

    /// Fill all cells overlapping the world-space rectangle.
    pub fn add_rect(&mut self, wx: f32, wy: f32, w: f32, h: f32) {
        let _ = self.try_add_rect(wx, wy, w, h);
    }

    /// Set every cell to `solid` and mark all chunks dirty.
    pub fn fill_all(&mut self, solid: bool) {
        for value in &mut self.cells {
            *value = solid;
        }
        self.dirty_chunks = Self::full_dirty_set(self.width, self.height);
    }

    /// Return true when any chunks are pending a `flush`.
    pub fn is_dirty(&self) -> bool {
        !self.dirty_chunks.is_empty()
    }

    /// Mark the chunk containing `(cx, cy)` as dirty.
    fn mark_dirty(&mut self, cx: u32, cy: u32) {
        self.dirty_chunks.insert(ChunkId {
            cx: cx / CHUNK_SIZE,
            cy: cy / CHUNK_SIZE,
        });
    }

    /// Rebuild bodies in all dirty chunks and sync them into `world`.
    pub fn flush(&mut self, world: &mut World) -> TerrainFlushStats {
        self.flush_with_limit(world, None)
    }

    /// Rebuild up to `max_dirty_chunks` dirty chunks and return collider rebuild diagnostics.
    pub fn flush_with_limit(
        &mut self,
        world: &mut World,
        max_dirty_chunks: Option<usize>,
    ) -> TerrainFlushStats {
        let started = Instant::now();
        let dirty: Vec<ChunkId> = self.dirty_chunks.drain().collect();
        let chunk_budget = max_dirty_chunks.unwrap_or(dirty.len()).min(dirty.len());
        let mut stats = TerrainFlushStats::default();
        for (index, chunk) in dirty.into_iter().enumerate() {
            if index >= chunk_budget {
                self.dirty_chunks.insert(chunk);
                continue;
            }
            stats.dirty_chunks_rebuilt += 1;
            if let Some(old_ids) = self.chunk_body_ids.remove(&chunk) {
                stats.bodies_destroyed += old_ids.len();
                for id in old_ids {
                    world.destroy_body(id);
                }
            }
            let cell_x0 = chunk.cx * CHUNK_SIZE;
            let cell_y0 = chunk.cy * CHUNK_SIZE;
            let cell_x1 = (cell_x0 + CHUNK_SIZE).min(self.width);
            let cell_y1 = (cell_y0 + CHUNK_SIZE).min(self.height);
            let mut new_ids = Vec::new();
            for cy in cell_y0..cell_y1 {
                let mut run_start: Option<u32> = None;
                for cx in cell_x0..=cell_x1 {
                    let solid = if cx < cell_x1 {
                        self.cells[self.cell_index(cx, cy)]
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
                                stats.bodies_created += 1;
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
        stats.dirty_chunks_remaining = self.dirty_chunks.len();
        stats.elapsed_micros = started.elapsed().as_micros();
        self.last_flush_stats = stats;
        stats
    }

    /// Return diagnostics from the most recent terrain collider rebuild pass.
    pub fn last_flush_stats(&self) -> TerrainFlushStats {
        self.last_flush_stats
    }

    /// Remove isolated unsupported single cells with no left or right neighbor; return the count removed.
    pub fn collapse_columns(&mut self) -> u32 {
        let mut count = 0u32;
        if self.height < 2 {
            return 0;
        }
        for cy in (0..self.height.saturating_sub(1)).rev() {
            for cx in 0..self.width {
                let idx = self.cell_index(cx, cy);
                if !self.cells[idx] {
                    continue;
                }
                let below = self.cells[self.cell_index(cx, cy + 1)];
                if !below {
                    let left = cx > 0 && self.cells[self.cell_index(cx - 1, cy)];
                    let right = cx + 1 < self.width && self.cells[self.cell_index(cx + 1, cy)];
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

    /// Return connected solid components that intersect `region`, or all components when `region` is `None`.
    pub fn find_components(
        &self,
        region: Option<TerrainRegion>,
    ) -> Result<Vec<TerrainComponent>, PhysicsError> {
        self.find_components_with_limits(region, &PhysicsLimits::default())
    }

    /// Return connected solid components that intersect `region`, bounded by explicit scan limits.
    pub fn find_components_with_limits(
        &self,
        region: Option<TerrainRegion>,
        limits: &PhysicsLimits,
    ) -> Result<Vec<TerrainComponent>, PhysicsError> {
        let total = checked_terrain_component_scan_cells(
            u64::from(self.width) * u64::from(self.height),
            limits,
        )?;
        let seed_region = match region {
            Some(region) => match region.clamped_to(self.width, self.height) {
                Some(region) => region,
                None => return Ok(Vec::new()),
            },
            None => TerrainRegion::full(self.width, self.height),
        };
        let mut visited = vec![false; total];
        let mut queue = VecDeque::new();
        let mut components = Vec::new();

        for cy in seed_region.y0..seed_region.y1 {
            for cx in seed_region.x0..seed_region.x1 {
                let start_idx = self.cell_index(cx, cy);
                if visited[start_idx] || !self.cells[start_idx] {
                    continue;
                }
                visited[start_idx] = true;
                queue.push_back((cx, cy));

                let mut cells = Vec::new();
                let mut min_x = cx;
                let mut min_y = cy;
                let mut max_x = cx + 1;
                let mut max_y = cy + 1;
                let mut touches_bottom = false;
                let mut touches_border = false;

                while let Some((cell_x, cell_y)) = queue.pop_front() {
                    cells.push((cell_x, cell_y));
                    min_x = min_x.min(cell_x);
                    min_y = min_y.min(cell_y);
                    max_x = max_x.max(cell_x + 1);
                    max_y = max_y.max(cell_y + 1);
                    if cell_y + 1 == self.height {
                        touches_bottom = true;
                    }
                    if cell_x == 0
                        || cell_y == 0
                        || cell_x + 1 == self.width
                        || cell_y + 1 == self.height
                    {
                        touches_border = true;
                    }

                    let neighbors = [
                        (cell_x.wrapping_sub(1), cell_y, cell_x > 0),
                        (cell_x + 1, cell_y, cell_x + 1 < self.width),
                        (cell_x, cell_y.wrapping_sub(1), cell_y > 0),
                        (cell_x, cell_y + 1, cell_y + 1 < self.height),
                    ];
                    for (next_x, next_y, in_bounds) in neighbors {
                        if !in_bounds {
                            continue;
                        }
                        let next_idx = self.cell_index(next_x, next_y);
                        if visited[next_idx] || !self.cells[next_idx] {
                            continue;
                        }
                        visited[next_idx] = true;
                        queue.push_back((next_x, next_y));
                    }
                }

                components.push(TerrainComponent {
                    cells,
                    bounds: TerrainRegion {
                        x0: min_x,
                        y0: min_y,
                        x1: max_x,
                        y1: max_y,
                    },
                    touches_bottom,
                    touches_border,
                });
            }
        }

        Ok(components)
    }

    /// Return unsupported solid components using the given support rule.
    pub fn find_unsupported_components(
        &self,
        support_rule: TerrainSupportRule,
    ) -> Result<Vec<TerrainComponent>, PhysicsError> {
        self.find_unsupported_components_with_limits(support_rule, &PhysicsLimits::default())
    }

    /// Return unsupported solid components using the given support rule and explicit scan limits.
    pub fn find_unsupported_components_with_limits(
        &self,
        support_rule: TerrainSupportRule,
        limits: &PhysicsLimits,
    ) -> Result<Vec<TerrainComponent>, PhysicsError> {
        Ok(self
            .find_components_with_limits(None, limits)?
            .into_iter()
            .filter(|component| !Self::component_supported(component, support_rule))
            .collect())
    }

    /// Collapse unsupported components without spawning debris bodies.
    pub fn collapse_unsupported(
        &mut self,
        options: &TerrainCollapseOptions,
    ) -> Result<TerrainCollapseResult, PhysicsError> {
        self.collapse_unsupported_with_limits(options, &PhysicsLimits::default())
    }

    /// Collapse unsupported components without spawning debris bodies, bounded by explicit limits.
    pub fn collapse_unsupported_with_limits(
        &mut self,
        options: &TerrainCollapseOptions,
        limits: &PhysicsLimits,
    ) -> Result<TerrainCollapseResult, PhysicsError> {
        self.collapse_unsupported_internal(None, options, limits)
    }

    /// Collapse unsupported components and optionally spawn debris bodies into `world`.
    pub fn collapse_unsupported_in_world(
        &mut self,
        world: &mut World,
        options: &TerrainCollapseOptions,
    ) -> Result<TerrainCollapseResult, PhysicsError> {
        let limits = *world.limits();
        self.collapse_unsupported_in_world_with_limits(world, options, &limits)
    }

    /// Collapse unsupported components and optionally spawn debris bodies into `world`, bounded by explicit limits.
    pub fn collapse_unsupported_in_world_with_limits(
        &mut self,
        world: &mut World,
        options: &TerrainCollapseOptions,
        limits: &PhysicsLimits,
    ) -> Result<TerrainCollapseResult, PhysicsError> {
        self.collapse_unsupported_internal(Some(world), options, limits)
    }

    /// Return the world-space centers of all solid cells.
    pub fn solid_cell_positions(&self) -> Vec<(f32, f32)> {
        let mut out = Vec::new();
        for cy in 0..self.height {
            for cx in 0..self.width {
                if self.cells[self.cell_index(cx, cy)] {
                    out.push(self.world_position_for_cell(cx, cy));
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
            let color = if solid { solid_rgba } else { empty_rgba };
            buf.extend_from_slice(&color);
        }
        Ok(buf)
    }

    /// Encode the terrain as RGBA pixel data using `solid_rgba` and `empty_rgba`.
    pub fn to_image_data(&self, solid_rgba: [u8; 4], empty_rgba: [u8; 4]) -> Vec<u8> {
        self.to_image_data_checked(solid_rgba, empty_rgba)
            .unwrap_or_default()
    }

    /// Serialize to a compact byte buffer with version header and bit-packed cells.
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

    /// Deserialize from a byte buffer produced by `to_bytes`, rejecting malformed sizes and unsafe allocations.
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

    /// Deserialize from a byte buffer produced by `to_bytes`; return `None` on error.
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
