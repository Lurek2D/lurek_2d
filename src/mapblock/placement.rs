//! Owns the placement owner for the mapblock subsystem and keeps its rules local to this file.
//! Keeps mapblock data ownership and helper behavior clear for future engine maintenance. for engine changes.
//! Defines how placement data is validated, transformed, or stored before neighboring systems use it.
//! Owns mapblock behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on placement behavior while Lua registration stays elsewhere.
//! Documents the boundary where mapblock code accepts inputs, reports errors, or updates state.
//! Use this file when changing placement defaults, lifecycle handling, validation, or data ownership.
//! Keeps failure paths and edge cases near the mapblock state that can explain them while keeping call sites explicit.

use super::block::{Edge, MapBlock};
use super::constraints::{opposite_edge, NeighborRules};
use std::collections::{HashMap, HashSet};
use std::error::Error;
use std::fmt;

/// A block that has been placed on the map.
#[derive(Debug, Clone)]
pub struct PlacedBlock {
    /// Group name that owns the block index.
    pub group_name: String,
    /// Index of the block within its group.
    pub block_index: usize,
    /// Position on the placement grid (grid coordinates, not tile coordinates).
    pub grid_x: i32,
    /// Position on the placement grid.
    pub grid_y: i32,
    /// Level (storey) this block is placed on.
    pub level: u32,
    /// Rotation applied (0, 1, 2, 3 = 0, 90, 180, 270 degrees clockwise).
    pub rotation: u32,
    /// Whether the block is mirrored horizontally.
    pub mirrored: bool,
    /// Occupied placement-grid cells covered by this block.
    pub occupied_cells: Vec<(i32, i32)>,
}

/// A fully resolved placement candidate with transform and occupied cells.
#[derive(Debug, Clone)]
pub struct PlacementCandidate {
    /// Group name that owns the candidate block.
    pub group_name: String,
    /// Index of the candidate block inside its group.
    pub block_index: usize,
    /// Anchor placement X.
    pub grid_x: i32,
    /// Anchor placement Y.
    pub grid_y: i32,
    /// Rotation in quarter turns clockwise.
    pub rotation: u32,
    /// Whether the block is mirrored horizontally.
    pub mirrored: bool,
    /// Occupied placement cells.
    pub occupied_cells: Vec<(i32, i32)>,
}

/// Immutable query parameters for one placement search.
#[derive(Debug, Clone, Copy)]
pub struct PlacementSearch<'a> {
    /// All known groups keyed by name.
    pub groups: &'a HashMap<String, super::group::MapGroup>,
    /// Group name that owns the target block.
    pub group_name: &'a str,
    /// Block index inside the target group.
    pub block_index: usize,
    /// Neighbor compatibility rules.
    pub rules: &'a NeighborRules,
    /// Whether neighbor sockets must be respected.
    pub match_sides: bool,
    /// Allowed quarter-turn rotations.
    pub rotations: &'a [u32],
    /// Allowed mirror states.
    pub mirrors: &'a [bool],
}

#[derive(Debug, Clone)]
struct CachedBlockTransform {
    footprint: Vec<(i32, i32)>,
    footprint_lookup: HashSet<(i32, i32)>,
    socket_map: HashMap<(i32, i32, Edge), u32>,
}

/// Reusable cache for transformed block footprint/socket payloads across placement searches.
#[derive(Debug, Clone, Default)]
pub struct PlacementTransformCache {
    entries: HashMap<(usize, u32, bool), CachedBlockTransform>,
    hits: u32,
    misses: u32,
}

impl PlacementTransformCache {
    /// Drop all cached transform payloads and reset hit/miss counters.
    pub fn clear(&mut self) {
        self.entries.clear();
        self.hits = 0;
        self.misses = 0;
    }

    /// Return the number of cache hits observed since the last clear.
    pub fn hits(&self) -> u32 {
        self.hits
    }

    /// Return the number of cache misses observed since the last clear.
    pub fn misses(&self) -> u32 {
        self.misses
    }

    fn get_transform(
        &mut self,
        block: &MapBlock,
        rotation: u32,
        mirrored: bool,
    ) -> &CachedBlockTransform {
        let key = (block as *const MapBlock as usize, rotation % 4, mirrored);
        if self.entries.contains_key(&key) {
            self.hits = self.hits.saturating_add(1);
        } else {
            self.misses = self.misses.saturating_add(1);
            let footprint = block.transformed_footprint(rotation, mirrored);
            let footprint_lookup = footprint.iter().copied().collect();
            let socket_map = block.transformed_socket_map(rotation, mirrored);
            self.entries.insert(
                key,
                CachedBlockTransform {
                    footprint,
                    footprint_lookup,
                    socket_map,
                },
            );
        }
        self.entries
            .get(&key)
            .expect("placement transform cache inserted an entry for the requested key")
    }
}

/// The placement grid defines available positions and tracks placed blocks.
///
/// The grid does not need to be rectangular. Available positions are defined by
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

/// Validation failures for `PlacementGrid` internal invariants.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum PlacementGridValidationError {
    /// An occupied cell was not present in the available shape.
    OccupiedOutsideAvailable { cell: (i32, i32) },
    /// An occupied cell had no reverse-map entry.
    MissingPositionMapEntry { cell: (i32, i32) },
    /// A reverse-map entry pointed beyond the placed block list.
    PositionMapIndexOutOfBounds {
        cell: (i32, i32),
        index: usize,
        placed_count: usize,
    },
    /// A reverse-map entry pointed at a block that does not cover the cell.
    PositionMapCellMismatch { cell: (i32, i32), index: usize },
    /// A placed block claims a cell that is not part of the available shape.
    PlacedCellOutsideAvailable { cell: (i32, i32), index: usize },
    /// A placed block claims a cell that is not marked occupied.
    PlacedCellMissingOccupiedFlag { cell: (i32, i32), index: usize },
    /// A placed block cell points at the wrong reverse-map index.
    PlacedCellWrongPositionMap {
        cell: (i32, i32),
        index: usize,
        mapped_index: Option<usize>,
    },
}

impl fmt::Display for PlacementGridValidationError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::OccupiedOutsideAvailable { cell } => {
                write!(f, "occupied cell {:?} is outside the available shape", cell)
            }
            Self::MissingPositionMapEntry { cell } => {
                write!(
                    f,
                    "occupied cell {:?} is missing from the reverse map",
                    cell
                )
            }
            Self::PositionMapIndexOutOfBounds {
                cell,
                index,
                placed_count,
            } => write!(
                f,
                "reverse map cell {:?} points to placed index {} but only {} blocks exist",
                cell, index, placed_count
            ),
            Self::PositionMapCellMismatch { cell, index } => write!(
                f,
                "reverse map cell {:?} points to block {} that does not cover the cell",
                cell, index
            ),
            Self::PlacedCellOutsideAvailable { cell, index } => write!(
                f,
                "placed block {} covers {:?} outside the available shape",
                index, cell
            ),
            Self::PlacedCellMissingOccupiedFlag { cell, index } => write!(
                f,
                "placed block {} covers {:?} but the occupied flag is missing",
                index, cell
            ),
            Self::PlacedCellWrongPositionMap {
                cell,
                index,
                mapped_index,
            } => write!(
                f,
                "placed block {} covers {:?} but the reverse map points to {:?}",
                index, cell, mapped_index
            ),
        }
    }
}

impl Error for PlacementGridValidationError {}

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
        !self.available.contains(&(x, y - 1))
            || !self.available.contains(&(x, y + 1))
            || !self.available.contains(&(x - 1, y))
            || !self.available.contains(&(x + 1, y))
    }

    /// Check whether all cells exist in the shape and are currently unoccupied.
    pub fn can_place_cells(&self, cells: &[(i32, i32)]) -> bool {
        cells.iter().all(|&(x, y)| self.is_available(x, y))
    }

    /// Place a block at a position. Returns false if any covered cell is unavailable.
    pub fn place_block(&mut self, placed: PlacedBlock) -> bool {
        if placed.occupied_cells.is_empty() || !self.can_place_cells(&placed.occupied_cells) {
            return false;
        }
        let idx = self.placed.len();
        for &cell in &placed.occupied_cells {
            self.occupied.insert(cell);
            self.position_map.insert(cell, idx);
        }
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
        self.available.len().saturating_sub(self.occupied.len())
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

    /// Validate the internal subset and reverse-map invariants of the placement grid.
    pub fn validate(&self) -> Result<(), PlacementGridValidationError> {
        for &cell in &self.occupied {
            if !self.available.contains(&cell) {
                return Err(PlacementGridValidationError::OccupiedOutsideAvailable { cell });
            }
            if !self.position_map.contains_key(&cell) {
                return Err(PlacementGridValidationError::MissingPositionMapEntry { cell });
            }
        }

        for (&cell, &index) in &self.position_map {
            let Some(placed) = self.placed.get(index) else {
                return Err(PlacementGridValidationError::PositionMapIndexOutOfBounds {
                    cell,
                    index,
                    placed_count: self.placed.len(),
                });
            };
            if !placed.occupied_cells.contains(&cell) {
                return Err(PlacementGridValidationError::PositionMapCellMismatch { cell, index });
            }
        }

        for (index, placed) in self.placed.iter().enumerate() {
            for &cell in &placed.occupied_cells {
                if !self.available.contains(&cell) {
                    return Err(PlacementGridValidationError::PlacedCellOutsideAvailable {
                        cell,
                        index,
                    });
                }
                if !self.occupied.contains(&cell) {
                    return Err(
                        PlacementGridValidationError::PlacedCellMissingOccupiedFlag { cell, index },
                    );
                }
                let mapped_index = self.position_map.get(&cell).copied();
                if mapped_index != Some(index) {
                    return Err(PlacementGridValidationError::PlacedCellWrongPositionMap {
                        cell,
                        index,
                        mapped_index,
                    });
                }
            }
        }
        Ok(())
    }
}

impl Default for PlacementGrid {
    fn default() -> Self {
        Self::new()
    }
}

/// Find valid placements for a block given the current grid state and rules.
pub fn find_valid_placements(
    grid: &PlacementGrid,
    search: &PlacementSearch<'_>,
) -> Vec<PlacementCandidate> {
    let mut cache = PlacementTransformCache::default();
    find_valid_placements_cached(grid, search, &mut cache)
}

/// Find valid placements while reusing transformed footprint/socket data across repeated searches.
pub fn find_valid_placements_cached(
    grid: &PlacementGrid,
    search: &PlacementSearch<'_>,
    cache: &mut PlacementTransformCache,
) -> Vec<PlacementCandidate> {
    let Some(group) = search.groups.get(search.group_name) else {
        return Vec::new();
    };
    let Some(block) = group.get_block(search.block_index) else {
        return Vec::new();
    };

    let is_edge_req = block.edge_only || search.rules.is_edge_required(search.block_index);
    let is_interior = block.interior_only || search.rules.is_interior_only(search.block_index);
    let mut placements = Vec::new();

    for (anchor_x, anchor_y) in grid.available_positions() {
        for &rotation in search.rotations {
            for &mirrored in search.mirrors {
                let transform = cache.get_transform(block, rotation, mirrored);
                let footprint = &transform.footprint;
                let occupied_cells: Vec<_> = footprint
                    .iter()
                    .map(|&(dx, dy)| (anchor_x + dx, anchor_y + dy))
                    .collect();

                if occupied_cells.is_empty() || !grid.can_place_cells(&occupied_cells) {
                    continue;
                }

                let touches_edge = occupied_cells
                    .iter()
                    .any(|&(x, y)| grid.is_edge_position(x, y));
                if is_edge_req && !touches_edge {
                    continue;
                }
                if is_interior && touches_edge {
                    continue;
                }
                if !check_neighbors_compatible(
                    grid, search, anchor_x, anchor_y, rotation, mirrored, cache,
                ) {
                    continue;
                }

                placements.push(PlacementCandidate {
                    group_name: search.group_name.to_string(),
                    block_index: search.block_index,
                    grid_x: anchor_x,
                    grid_y: anchor_y,
                    rotation,
                    mirrored,
                    occupied_cells,
                });
            }
        }
    }

    placements
}

/// Check if placing a block at an anchor is compatible with all placed neighbors.
fn check_neighbors_compatible(
    grid: &PlacementGrid,
    search: &PlacementSearch<'_>,
    anchor_x: i32,
    anchor_y: i32,
    rotation: u32,
    mirrored: bool,
    cache: &mut PlacementTransformCache,
) -> bool {
    if !search.match_sides {
        return true;
    }

    let Some(group) = search.groups.get(search.group_name) else {
        return false;
    };
    let Some(block) = group.get_block(search.block_index) else {
        return false;
    };
    let transform = cache.get_transform(block, rotation, mirrored);
    let footprint = transform.footprint.clone();
    let footprint_lookup = transform.footprint_lookup.clone();
    let socket_map = transform.socket_map.clone();

    for &(dx, dy) in &footprint {
        let cell_x = anchor_x + dx;
        let cell_y = anchor_y + dy;
        let neighbors = [
            (Edge::North, cell_x, cell_y - 1),
            (Edge::South, cell_x, cell_y + 1),
            (Edge::West, cell_x - 1, cell_y),
            (Edge::East, cell_x + 1, cell_y),
        ];

        for (my_edge, nx, ny) in neighbors {
            if footprint_lookup.contains(&(nx - anchor_x, ny - anchor_y)) {
                continue;
            }
            let my_type = socket_map.get(&(dx, dy, my_edge)).copied().unwrap_or(0);
            if let Some(placed) = grid.get_block_at(nx, ny) {
                if let Some(neighbor_block) = search
                    .groups
                    .get(&placed.group_name)
                    .and_then(|group| group.get_block(placed.block_index))
                {
                    let neighbor_transform =
                        cache.get_transform(neighbor_block, placed.rotation, placed.mirrored);
                    let neighbor_dx = nx - placed.grid_x;
                    let neighbor_dy = ny - placed.grid_y;
                    let their_type = neighbor_transform
                        .socket_map
                        .get(&(neighbor_dx, neighbor_dy, opposite_edge(my_edge)))
                        .copied()
                        .unwrap_or(0);
                    if !search.rules.is_compatible(my_type, their_type) {
                        return false;
                    }
                }
            }
        }
    }

    true
}
