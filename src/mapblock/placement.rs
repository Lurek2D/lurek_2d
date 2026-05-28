//! Block placement grid, valid-position search, and placed-block tracking.
//!
//! - `PlacementGrid` tracks which cells are occupied and caches constraint state.
//! - `find_valid_positions(grid, block)` returns all (x, y) cells where the block fits.
//! - Placement validation is O(edges × constraints) per candidate cell.
//! - `PlacedBlock` records the block ID, position, and applied rotation for undo support.

use super::block::{Edge, MapBlock};
use super::constraints::{opposite_edge, NeighborRules};
use std::collections::{HashMap, HashSet};

/// A block that has been placed on the map.
#[derive(Debug, Clone)]
pub struct PlacedBlock {
    /// Index of the block within its group.
    pub block_index: usize,
    /// Position on the placement grid (grid coordinates, not tile coordinates).
    pub grid_x: i32,
    /// Position on the placement grid.
    pub grid_y: i32,
    /// Level (storey) this block is placed on.
    pub level: u32,
    /// Rotation applied (0, 1, 2, 3 = 0°, 90°, 180°, 270°).
    pub rotation: u32,
    /// Whether the block is mirrored horizontally.
    pub mirrored: bool,
}

/// The placement grid — defines available positions and tracks placed blocks.
///
/// The grid does NOT need to be rectangular. Available positions are defined by
/// a set of coordinates, allowing arbitrary map shapes.
#[derive(Debug, Clone)]
pub struct PlacementGrid {
    /// Set of available positions where blocks can be placed.
    available: HashSet<(i32, i32)>,
    /// Positions that have been filled by placed blocks.
    occupied: HashSet<(i32, i32)>,
    /// Placed blocks with their positions.
    placed: Vec<PlacedBlock>,
    /// Map from grid position to index in `placed`.
    position_map: HashMap<(i32, i32), usize>,
}

impl PlacementGrid {
    /// Create a new empty placement grid.
    pub fn new() -> Self {
        Self {
            available: HashSet::new(),
            occupied: HashSet::new(),
            placed: Vec::new(),
            position_map: HashMap::new(),
        }
    }

    /// Create a rectangular grid with positions from (0,0) to (width-1, height-1).
    pub fn new_rect(width: u32, height: u32) -> Self {
        let mut grid = Self::new();
        for y in 0..height as i32 {
            for x in 0..width as i32 {
                grid.available.insert((x, y));
            }
        }
        grid
    }

    /// Add a single available position.
    pub fn add_position(&mut self, x: i32, y: i32) {
        self.available.insert((x, y));
    }

    /// Remove an available position.
    pub fn remove_position(&mut self, x: i32, y: i32) {
        self.available.remove(&(x, y));
    }

    /// Add positions from a list of (x, y) pairs.
    pub fn add_positions(&mut self, positions: &[(i32, i32)]) {
        for &pos in positions {
            self.available.insert(pos);
        }
    }

    /// Check if a position is available (exists and not occupied).
    pub fn is_available(&self, x: i32, y: i32) -> bool {
        self.available.contains(&(x, y)) && !self.occupied.contains(&(x, y))
    }

    /// Check if a position is on the edge of the available area.
    pub fn is_edge_position(&self, x: i32, y: i32) -> bool {
        if !self.available.contains(&(x, y)) {
            return false;
        }
        // A position is on the edge if any cardinal neighbor is NOT available
        !self.available.contains(&(x, y - 1))
            || !self.available.contains(&(x, y + 1))
            || !self.available.contains(&(x - 1, y))
            || !self.available.contains(&(x + 1, y))
    }

    /// Place a block at a position. Returns false if position is not available.
    pub fn place_block(&mut self, placed: PlacedBlock) -> bool {
        let pos = (placed.grid_x, placed.grid_y);
        if !self.is_available(pos.0, pos.1) {
            return false;
        }
        self.occupied.insert(pos);
        let idx = self.placed.len();
        self.position_map.insert(pos, idx);
        self.placed.push(placed);
        true
    }

    /// Get the block placed at a given position.
    pub fn get_block_at(&self, x: i32, y: i32) -> Option<&PlacedBlock> {
        self.position_map
            .get(&(x, y))
            .and_then(|&idx| self.placed.get(idx))
    }

    /// Get a slice of all placed blocks.
    pub fn placed_blocks(&self) -> &[PlacedBlock] {
        &self.placed
    }

    /// Get the number of placed blocks.
    pub fn placed_count(&self) -> usize {
        self.placed.len()
    }

    /// Get the number of available (unfilled) positions.
    pub fn available_count(&self) -> usize {
        self.available.len() - self.occupied.len()
    }

    /// Get all available (unfilled) positions.
    pub fn available_positions(&self) -> Vec<(i32, i32)> {
        self.available
            .iter()
            .filter(|pos| !self.occupied.contains(pos))
            .copied()
            .collect()
    }

    /// Get the bounding box of all available positions: (min_x, min_y, max_x, max_y).
    pub fn bounds(&self) -> Option<(i32, i32, i32, i32)> {
        if self.available.is_empty() {
            return None;
        }
        let mut min_x = i32::MAX;
        let mut min_y = i32::MAX;
        let mut max_x = i32::MIN;
        let mut max_y = i32::MIN;
        for &(x, y) in &self.available {
            min_x = min_x.min(x);
            min_y = min_y.min(y);
            max_x = max_x.max(x);
            max_y = max_y.max(y);
        }
        Some((min_x, min_y, max_x, max_y))
    }

    /// Clear all placed blocks (keep available positions).
    pub fn clear_placed(&mut self) {
        self.occupied.clear();
        self.placed.clear();
        self.position_map.clear();
    }

    /// Reset the entire placement grid.
    pub fn clear(&mut self) {
        self.available.clear();
        self.occupied.clear();
        self.placed.clear();
        self.position_map.clear();
    }
}

impl Default for PlacementGrid {
    fn default() -> Self {
        Self::new()
    }
}

/// Find valid positions for a block given the current grid state and rules.
pub fn find_valid_positions(
    grid: &PlacementGrid,
    blocks: &[MapBlock],
    block_index: usize,
    rules: &NeighborRules,
) -> Vec<(i32, i32)> {
    let block = match blocks.get(block_index) {
        Some(b) => b,
        None => return Vec::new(),
    };

    let is_edge_req = block.edge_only || rules.is_edge_required(block_index);
    let is_interior = block.interior_only || rules.is_interior_only(block_index);

    grid.available_positions()
        .into_iter()
        .filter(|&(x, y)| {
            let on_edge = grid.is_edge_position(x, y);
            if is_edge_req && !on_edge {
                return false;
            }
            if is_interior && on_edge {
                return false;
            }
            // Check neighbor compatibility
            check_neighbors_compatible(grid, blocks, block, x, y, rules)
        })
        .collect()
}

/// Check if placing a block at (x, y) is compatible with all placed neighbors.
fn check_neighbors_compatible(
    grid: &PlacementGrid,
    blocks: &[MapBlock],
    block: &MapBlock,
    x: i32,
    y: i32,
    rules: &NeighborRules,
) -> bool {
    let neighbors = [
        (Edge::North, x, y - 1),
        (Edge::South, x, y + 1),
        (Edge::West, x - 1, y),
        (Edge::East, x + 1, y),
    ];

    for (my_edge, nx, ny) in neighbors {
        if let Some(placed) = grid.get_block_at(nx, ny) {
            if let Some(neighbor_block) = blocks.get(placed.block_index) {
                let their_edge = opposite_edge(my_edge);
                // Check each segment along the shared edge
                let segments = match my_edge {
                    Edge::North | Edge::South => block.segments_horizontal(),
                    Edge::East | Edge::West => block.segments_vertical(),
                };
                for seg in 0..segments {
                    let my_type = block.get_edge(my_edge, seg).unwrap_or(0);
                    let their_type = neighbor_block.get_edge(their_edge, seg).unwrap_or(0);
                    if !rules.is_compatible(my_type, their_type) {
                        return false;
                    }
                }
            }
        }
    }
    true
}
