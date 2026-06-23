//! Implements weighted pathfinding on rectangular isometric grids with blocked flags and per-cell costs.
//! Owns cell indexing, four-neighbor A*, Manhattan heuristics, and Bresenham line-of-sight checks for the map.
//! Returns ordered tile paths for iso maps while keeping cost weighting and obstacle handling in one owner.
//! Provides the boundary between isometric map data and systems that need reliable navigation on projected tiles.
//! Open this file when iso path cost rules, neighbor policy, or LOS behavior no longer matches gameplay maps.

use std::cmp::Ordering;
use std::collections::{BinaryHeap, HashMap};
/// Rectangular grid that stores per-cell passability and cost for A* pathfinding.
pub struct IsoGrid {
    /// Grid width in cells.
    pub width: u32,
    /// Grid height in cells.
    pub height: u32,
    /// Per-cell blocked flags indexed by `(y * width + x)`.
    blocked: Vec<bool>,
    /// Per-cell movement cost.
    cost: Vec<f32>,
}
/// Construction and pathfinding methods for `IsoGrid`.
impl IsoGrid {
    /// Create a fully passable grid of `width × height` cells with unit movement costs.
    pub fn new(width: u32, height: u32) -> Self {
        let n = (width * height) as usize;
        Self {
            width,
            height,
            blocked: vec![false; n],
            cost: vec![1.0; n],
        }
    }
    /// Mark cell `(x, y)` as blocked or passable.
    pub fn set_blocked(&mut self, x: u32, y: u32, blocked: bool) {
        if let Some(i) = self.index(x, y) {
            self.blocked[i] = blocked;
        }
    }
    /// Set the movement cost for cell `(x, y)`.
    pub fn set_cost(&mut self, x: u32, y: u32, cost: f32) {
        if let Some(i) = self.index(x, y) {
            self.cost[i] = cost;
        }
    }
    /// Run A\* from `from` to `to`; return an ordered path or `None` when unreachable.
    pub fn find_path(&self, from: (u32, u32), to: (u32, u32)) -> Option<Vec<(u32, u32)>> {
        if self.is_blocked_or_oob(from.0, from.1) || self.is_blocked_or_oob(to.0, to.1) {
            return None;
        }
        if from == to {
            return Some(vec![from]);
        }
        let mut open: BinaryHeap<Node> = BinaryHeap::new();
        let mut g_cost: HashMap<(u32, u32), f32> = HashMap::new();
        let mut came_from: HashMap<(u32, u32), (u32, u32)> = HashMap::new();
        g_cost.insert(from, 0.0);
        open.push(Node { pos: from, f: 0.0 });
        while let Some(Node { pos, .. }) = open.pop() {
            if pos == to {
                return Some(reconstruct_path(&came_from, to));
            }
            let cur_g = *g_cost.get(&pos).unwrap_or(&f32::MAX);
            for nb in self.neighbors(pos.0, pos.1) {
                let nb_idx = self.index(nb.0, nb.1).unwrap();
                let new_g = cur_g + self.cost[nb_idx];
                if new_g < *g_cost.get(&nb).unwrap_or(&f32::MAX) {
                    g_cost.insert(nb, new_g);
                    came_from.insert(nb, pos);
                    let h = manhattan(nb, to) as f32;
                    open.push(Node {
                        pos: nb,
                        f: new_g + h,
                    });
                }
            }
        }
        None
    }
    /// Return the 4-directional passable neighbours of `(x, y)`.
    pub fn neighbors(&self, x: u32, y: u32) -> Vec<(u32, u32)> {
        let mut result = Vec::with_capacity(4);
        let dirs: [(i32, i32); 4] = [(1, 0), (-1, 0), (0, 1), (0, -1)];
        for (dx, dy) in dirs {
            let nx = x as i32 + dx;
            let ny = y as i32 + dy;
            if nx >= 0 && nx < self.width as i32 && ny >= 0 && ny < self.height as i32 {
                let nx = nx as u32;
                let ny = ny as u32;
                if !self.is_blocked_or_oob(nx, ny) {
                    result.push((nx, ny));
                }
            }
        }
        result
    }
    /// Convert `(x, y)` to a flat index; return `None` when out-of-bounds.
    fn index(&self, x: u32, y: u32) -> Option<usize> {
        if x < self.width && y < self.height {
            Some((y * self.width + x) as usize)
        } else {
            None
        }
    }
    /// Return true when `(x, y)` is out-of-bounds or marked blocked.
    fn is_blocked_or_oob(&self, x: u32, y: u32) -> bool {
        self.index(x, y).is_none_or(|i| self.blocked[i])
    }
}
/// Manhattan distance heuristic for A\* on axis-aligned isometric grids.
fn manhattan(a: (u32, u32), b: (u32, u32)) -> u32 {
    a.0.abs_diff(b.0) + a.1.abs_diff(b.1)
}
/// Internal A\* heap node for `IsoGrid`.
#[derive(Clone)]
struct Node {
    /// Grid position.
    pos: (u32, u32),
    /// f-score = g + h.
    f: f32,
}
/// Equality by f-score.
impl PartialEq for Node {
    fn eq(&self, other: &Self) -> bool {
        self.f == other.f
    }
}
/// Marker trait required by `Ord`.
impl Eq for Node {}

/// Delegates to `Ord`.
impl PartialOrd for Node {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}
/// Reverse ordering so `BinaryHeap` is a min-heap.
impl Ord for Node {
    fn cmp(&self, other: &Self) -> Ordering {
        other.f.partial_cmp(&self.f).unwrap_or(Ordering::Equal)
    }
}
/// Walk `came_from` back from `current` to the start and return the path in forward order.
fn reconstruct_path(
    came_from: &HashMap<(u32, u32), (u32, u32)>,
    mut current: (u32, u32),
) -> Vec<(u32, u32)> {
    let mut path = vec![current];
    while let Some(&prev) = came_from.get(&current) {
        path.push(prev);
        current = prev;
    }
    path.reverse();
    path
}
