//! Multi-level raycaster: stacked horizontal slices for floors, ceilings, and bridges.
//!
//! - Data types: `RaycasterLevel`, `MultiLevelGrid`.
//! - Implementations: `RaycasterLevel`, `MultiLevelGrid`.

/// A single level in a multi-level raycaster world.
#[derive(Debug, Clone)]
pub struct RaycasterLevel {
    /// Width in pixels.
    pub width: usize,
    /// Height in pixels.
    pub height: usize,
    /// Wall grid: 0 = empty, nonzero = wall texture ID.
    pub walls: Vec<u32>,
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
}

/// Multi-level grid containing stacked raycaster levels.
#[derive(Debug, Clone)]
pub struct MultiLevelGrid {
    levels: Vec<RaycasterLevel>,
    active_level: usize,
}

impl MultiLevelGrid {
    /// Create a new empty multi-level grid with no levels.
    pub fn new() -> Self {
        Self {
            levels: Vec::new(),
            active_level: 0,
        }
    }

    /// Append a new level to the grid stack.
    pub fn add_level(&mut self, level: RaycasterLevel) {
        self.levels.push(level);
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
        self.levels.get_mut(idx)
    }

    /// Return a shared reference to the currently active level, or `None` if the grid is empty.
    pub fn get_active(&self) -> Option<&RaycasterLevel> {
        self.levels.get(self.active_level)
    }

    /// Return a mutable reference to the currently active level, or `None` if the grid is empty.
    pub fn get_active_mut(&mut self) -> Option<&mut RaycasterLevel> {
        self.levels.get_mut(self.active_level)
    }

    /// Check if a position connects to the level below via floor hole.
    pub fn can_descend(&self, x: usize, y: usize) -> bool {
        if self.active_level == 0 {
            return false;
        }
        self.levels.get(self.active_level)
            .map(|l| l.is_floor_hole(x, y))
            .unwrap_or(false)
    }

    /// Check if a position connects to the level above via ceiling hole.
    pub fn can_ascend(&self, x: usize, y: usize) -> bool {
        if self.active_level + 1 >= self.levels.len() {
            return false;
        }
        self.levels.get(self.active_level)
            .map(|l| l.is_ceiling_hole(x, y))
            .unwrap_or(false)
    }
}

impl Default for MultiLevelGrid {
    fn default() -> Self {
        Self::new()
    }
}
