//! This file extends the flat raycaster into stacked slices so one map position can participate in a multi-storey layout.
//! Each slice carries its own vertical span and tile layer, allowing bridges, overhead rooms, shafts, and similar structures to share horizontal space.
//! The representation stays close to the base raycaster model, which keeps level transitions understandable for rendering and gameplay code.
//! Special transitions can move the viewer between slices without inventing a separate world format or renderer.
//! The design is meant to add vertical richness while preserving the core assumptions of the column-based pipeline.

use super::build_scene::LoweredFloorCell;
use super::dda::Raycaster2D;
use super::wall_feature::WallFeature;
use crate::runtime::resource_keys::TextureKey;
use std::cell::RefCell;

/// A single level in a multi-level raycaster world.
#[derive(Debug, Clone)]
pub struct RaycasterLevel {
    /// Width in pixels.
    pub width: usize,
    /// Height in pixels.
    pub height: usize,
    /// Wall grid: 0 = empty, nonzero = wall texture ID.
    pub walls: Vec<u32>,
    /// Optional per-cell wall feature overrides for windows, doors, and half-height walls.
    pub wall_features: Vec<Option<WallFeature>>,
    /// Default floor texture used by this level when no per-cell override is present.
    pub floor_texture: Option<TextureKey>,
    /// Optional per-cell floor texture overrides.
    pub floor_cell_textures: Vec<Option<TextureKey>>,
    /// Default ceiling texture used by this level when no per-cell override is present.
    pub ceiling_texture: Option<TextureKey>,
    /// Optional per-cell ceiling texture overrides.
    pub ceiling_cell_textures: Vec<Option<TextureKey>>,
    /// Optional per-cell lowered-floor descriptors used for pits and step-down tiles.
    pub lowered_floor_cells: Vec<Option<LoweredFloorCell>>,
    /// Floor holes: positions where you can see/fall to the level below.
    pub floor_holes: Vec<bool>,
    /// Ceiling holes: positions where you can see/climb to the level above.
    pub ceiling_holes: Vec<bool>,
    /// Floor height offset for this level.
    pub floor_offset: f32,
    /// Ceiling height for this level.
    pub ceiling_height: f32,
}

impl RaycasterLevel {
    /// Create a new level grid of the given dimensions, all cells empty.
    pub fn new(width: usize, height: usize) -> Self {
        let size = width * height;
        Self {
            width,
            height,
            walls: vec![0; size],
            wall_features: vec![None; size],
            floor_texture: None,
            floor_cell_textures: vec![None; size],
            ceiling_texture: None,
            ceiling_cell_textures: vec![None; size],
            lowered_floor_cells: vec![None; size],
            floor_holes: vec![false; size],
            ceiling_holes: vec![false; size],
            floor_offset: 0.0,
            ceiling_height: 1.0,
        }
    }

    /// Return the wall texture ID at `(x, y)`, returning 1 (solid) for out-of-bounds coordinates.
    pub fn get_wall(&self, x: usize, y: usize) -> u32 {
        if x < self.width && y < self.height {
            self.walls[y * self.width + x]
        } else {
            1 // Out of bounds = solid wall
        }
    }

    /// Set the wall texture ID at `(x, y)`; out-of-bounds writes are silently ignored.
    pub fn set_wall(&mut self, x: usize, y: usize, value: u32) {
        if x < self.width && y < self.height {
            self.walls[y * self.width + x] = value;
        }
    }

    /// Return the wall feature attached to `(x, y)`, or `None` when no override is present.
    pub fn wall_feature(&self, x: usize, y: usize) -> Option<WallFeature> {
        if x < self.width && y < self.height {
            self.wall_features[y * self.width + x]
        } else {
            None
        }
    }

    /// Set the wall feature override at `(x, y)`; out-of-bounds writes are silently ignored.
    pub fn set_wall_feature(&mut self, x: usize, y: usize, feature: WallFeature) {
        if x < self.width && y < self.height {
            self.wall_features[y * self.width + x] = Some(feature);
        }
    }

    /// Clear the wall feature override at `(x, y)`; out-of-bounds writes are silently ignored.
    pub fn clear_wall_feature(&mut self, x: usize, y: usize) {
        if x < self.width && y < self.height {
            self.wall_features[y * self.width + x] = None;
        }
    }

    /// Return the floor texture used at `(x, y)`, falling back to the level default.
    pub fn floor_texture_at(&self, x: usize, y: usize) -> Option<TextureKey> {
        if x < self.width && y < self.height {
            self.floor_cell_textures[y * self.width + x].or(self.floor_texture)
        } else {
            None
        }
    }

    /// Set a per-cell floor texture override at `(x, y)`; out-of-bounds writes are silently ignored.
    pub fn set_floor_texture(&mut self, x: usize, y: usize, texture: TextureKey) {
        if x < self.width && y < self.height {
            self.floor_cell_textures[y * self.width + x] = Some(texture);
        }
    }

    /// Clear the per-cell floor texture override at `(x, y)`; out-of-bounds writes are silently ignored.
    pub fn clear_floor_texture(&mut self, x: usize, y: usize) {
        if x < self.width && y < self.height {
            self.floor_cell_textures[y * self.width + x] = None;
        }
    }

    /// Return the ceiling texture used at `(x, y)`, falling back to the level default.
    pub fn ceiling_texture_at(&self, x: usize, y: usize) -> Option<TextureKey> {
        if x < self.width && y < self.height {
            self.ceiling_cell_textures[y * self.width + x].or(self.ceiling_texture)
        } else {
            None
        }
    }

    /// Set a per-cell ceiling texture override at `(x, y)`; out-of-bounds writes are silently ignored.
    pub fn set_ceiling_texture(&mut self, x: usize, y: usize, texture: TextureKey) {
        if x < self.width && y < self.height {
            self.ceiling_cell_textures[y * self.width + x] = Some(texture);
        }
    }

    /// Clear the per-cell ceiling texture override at `(x, y)`; out-of-bounds writes are silently ignored.
    pub fn clear_ceiling_texture(&mut self, x: usize, y: usize) {
        if x < self.width && y < self.height {
            self.ceiling_cell_textures[y * self.width + x] = None;
        }
    }

    /// Return the lowered-floor descriptor at `(x, y)`, or `None` when the cell uses the base floor plane.
    pub fn lowered_floor(&self, x: usize, y: usize) -> Option<LoweredFloorCell> {
        if x < self.width && y < self.height {
            self.lowered_floor_cells[y * self.width + x]
        } else {
            None
        }
    }

    /// Set the lowered-floor descriptor at `(x, y)`; out-of-bounds writes are silently ignored.
    pub fn set_lowered_floor(&mut self, x: usize, y: usize, cell: LoweredFloorCell) {
        if x < self.width && y < self.height {
            self.lowered_floor_cells[y * self.width + x] = Some(cell);
        }
    }

    /// Clear the lowered-floor descriptor at `(x, y)`; out-of-bounds writes are silently ignored.
    pub fn clear_lowered_floor(&mut self, x: usize, y: usize) {
        if x < self.width && y < self.height {
            self.lowered_floor_cells[y * self.width + x] = None;
        }
    }

    /// Return `true` if the cell at `(x, y)` is a floor hole (visibility through to the level below).
    pub fn is_floor_hole(&self, x: usize, y: usize) -> bool {
        if x < self.width && y < self.height {
            self.floor_holes[y * self.width + x]
        } else {
            false
        }
    }

    /// Set whether the cell at `(x, y)` is a floor hole.
    pub fn set_floor_hole(&mut self, x: usize, y: usize, hole: bool) {
        if x < self.width && y < self.height {
            self.floor_holes[y * self.width + x] = hole;
        }
    }

    /// Return `true` if the cell at `(x, y)` is a ceiling hole (visibility through to the level above).
    pub fn is_ceiling_hole(&self, x: usize, y: usize) -> bool {
        if x < self.width && y < self.height {
            self.ceiling_holes[y * self.width + x]
        } else {
            false
        }
    }

    /// Set whether the cell at `(x, y)` is a ceiling hole.
    pub fn set_ceiling_hole(&mut self, x: usize, y: usize, hole: bool) {
        if x < self.width && y < self.height {
            self.ceiling_holes[y * self.width + x] = hole;
        }
    }

    /// Build a transient `Raycaster2D` view of this level for rendering or picking.
    /// This is `pub(crate)` because the runtime representation must stay synchronized
    /// with level-owned wall cells and wall-feature overrides.
    pub(crate) fn build_runtime_raycaster(&self) -> Raycaster2D {
        let mut raycaster = Raycaster2D::new(self.width as u32, self.height as u32);
        raycaster.set_cells(self.walls.clone());
        for (cell_index, feature) in self.wall_features.iter().enumerate() {
            if let Some(feature) = feature {
                let x = (cell_index % self.width) as u32;
                let y = (cell_index / self.width) as u32;
                raycaster.set_wall_feature(x, y, *feature);
            }
        }
        raycaster
    }

    fn has_visible_hole(
        &self,
        holes: &[bool],
        camera_x: f32,
        camera_y: f32,
        max_view_distance: f32,
    ) -> bool {
        let max_dist_sq = max_view_distance * max_view_distance;
        for y in 0..self.height {
            for x in 0..self.width {
                let idx = y * self.width + x;
                if !holes[idx] {
                    continue;
                }
                let tile_cx = x as f32 + 0.5;
                let tile_cy = y as f32 + 0.5;
                let dx = tile_cx - camera_x;
                let dy = tile_cy - camera_y;
                if dx * dx + dy * dy <= max_dist_sq {
                    return true;
                }
            }
        }
        false
    }

    fn has_visible_floor_hole(&self, camera_x: f32, camera_y: f32, max_view_distance: f32) -> bool {
        self.has_visible_hole(&self.floor_holes, camera_x, camera_y, max_view_distance)
    }

    fn has_visible_ceiling_hole(
        &self,
        camera_x: f32,
        camera_y: f32,
        max_view_distance: f32,
    ) -> bool {
        self.has_visible_hole(&self.ceiling_holes, camera_x, camera_y, max_view_distance)
    }
}

/// Multi-level grid containing stacked raycaster levels.
#[derive(Debug)]
pub struct MultiLevelGrid {
    levels: Vec<RaycasterLevel>,
    active_level: usize,
    runtime_cache: RefCell<Vec<Option<Raycaster2D>>>,
}

impl MultiLevelGrid {
    /// Create a new empty multi-level grid with no levels.
    pub fn new() -> Self {
        Self {
            levels: Vec::new(),
            active_level: 0,
            runtime_cache: RefCell::new(Vec::new()),
        }
    }

    /// Append a new level to the grid stack.
    pub fn add_level(&mut self, level: RaycasterLevel) {
        self.levels.push(level);
        self.runtime_cache.get_mut().push(None);
    }

    /// Return the total number of levels in this grid.
    pub fn level_count(&self) -> usize {
        self.levels.len()
    }

    /// Return the index of the currently active level.
    pub fn active_level(&self) -> usize {
        self.active_level
    }

    /// Set the active level index; silently ignored if out of range.
    pub fn set_active_level(&mut self, idx: usize) {
        if idx < self.levels.len() {
            self.active_level = idx;
        }
    }

    /// Return a shared reference to the level at `idx`, or `None` if out of range.
    pub fn get_level(&self, idx: usize) -> Option<&RaycasterLevel> {
        self.levels.get(idx)
    }

    /// Return a mutable reference to the level at `idx`, or `None` if out of range.
    pub fn get_level_mut(&mut self, idx: usize) -> Option<&mut RaycasterLevel> {
        if idx < self.levels.len() {
            self.runtime_cache.get_mut()[idx] = None;
        }
        self.levels.get_mut(idx)
    }

    /// Return a shared reference to the currently active level, or `None` if the grid is empty.
    pub fn get_active(&self) -> Option<&RaycasterLevel> {
        self.levels.get(self.active_level)
    }

    /// Return a mutable reference to the currently active level, or `None` if the grid is empty.
    pub fn get_active_mut(&mut self) -> Option<&mut RaycasterLevel> {
        self.get_level_mut(self.active_level)
    }

    /// Execute `f` with a compiled runtime raycaster for `idx`, building and caching it on demand.
    pub(crate) fn with_runtime_level<R>(
        &self,
        idx: usize,
        f: impl FnOnce(&RaycasterLevel, &Raycaster2D) -> R,
    ) -> Option<R> {
        let level = self.levels.get(idx)?;
        {
            let mut cache = self.runtime_cache.borrow_mut();
            if idx >= cache.len() {
                cache.resize_with(idx + 1, || None);
            }
            if cache[idx].is_none() {
                cache[idx] = Some(level.build_runtime_raycaster());
            }
        }
        let cache = self.runtime_cache.borrow();
        let raycaster = cache.get(idx)?.as_ref()?;
        Some(f(level, raycaster))
    }

    /// Return the subset of levels that can contribute to the current view from the active slice.
    pub(crate) fn visible_level_indices(
        &self,
        camera_x: f32,
        camera_y: f32,
        max_view_distance: f32,
    ) -> Vec<usize> {
        if self.levels.is_empty() {
            return Vec::new();
        }

        let active = self.active_level.min(self.levels.len() - 1);
        let mut visible = vec![active];

        let mut lower = active;
        while lower > 0 {
            let Some(level) = self.levels.get(lower) else {
                break;
            };
            if !level.has_visible_floor_hole(camera_x, camera_y, max_view_distance) {
                break;
            }
            lower -= 1;
            visible.push(lower);
        }

        let mut upper = active;
        while upper + 1 < self.levels.len() {
            let Some(level) = self.levels.get(upper) else {
                break;
            };
            if !level.has_visible_ceiling_hole(camera_x, camera_y, max_view_distance) {
                break;
            }
            upper += 1;
            visible.push(upper);
        }

        visible.sort_unstable();
        visible
    }

    /// Check if a position connects to the level below via floor hole.
    pub fn can_descend(&self, x: usize, y: usize) -> bool {
        if self.active_level == 0 {
            return false;
        }
        self.levels
            .get(self.active_level)
            .map(|l| l.is_floor_hole(x, y))
            .unwrap_or(false)
    }

    /// Check if a position connects to the level above via ceiling hole.
    pub fn can_ascend(&self, x: usize, y: usize) -> bool {
        if self.active_level + 1 >= self.levels.len() {
            return false;
        }
        self.levels
            .get(self.active_level)
            .map(|l| l.is_ceiling_hole(x, y))
            .unwrap_or(false)
    }
}

impl Default for MultiLevelGrid {
    fn default() -> Self {
        Self::new()
    }
}

impl Clone for MultiLevelGrid {
    fn clone(&self) -> Self {
        Self {
            levels: self.levels.clone(),
            active_level: self.active_level,
            runtime_cache: RefCell::new((0..self.levels.len()).map(|_| None).collect()),
        }
    }
}
