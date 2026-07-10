//! Wraps a shared NavGrid in a stateful per-unit pathfinding service with cache-aware route and utility queries.
//! Owns Waypoint output records, cache keys, cached path storage, shared-goal field caches, and optional LRU-style eviction behavior.
//! Calls baseline A* for full, smoothed, or partial routes, then exposes length, cost, LOS, and reachability helpers.
//! Also searches for the nearest walkable fallback cell and shared-goal route batches, keeping per-unit recovery logic close to shared grid access.
//! Provides the boundary between raw navigation algorithms and gameplay units that need repeated path requests.
//! Open this owner when route caching, per-unit helper semantics, or fallback walkability behavior needs changes.

use crate::runtime::log_messages::{UP01, UP02, UP03};

use crate::log_msg;
use crate::pathfind::{astar, nav_grid::NavGrid, FlowField, FootprintSpec};
use std::cell::RefCell;
use std::collections::{HashMap, HashSet, VecDeque};
use std::rc::Rc;

const DEFAULT_SHARED_GOAL_CACHE_MAX_SIZE: usize = 32;
type PathPair = ((u32, u32), (u32, u32));
type IndexedStartsByGoal = HashMap<(u32, u32), Vec<(usize, (u32, u32))>>;
/// Grid cell coordinate returned as a path waypoint.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct Waypoint {
    /// Column index.
    pub x: u32,
    /// Row index.
    pub y: u32,
}
/// LRU cache lookup key for a specific unit-size path request.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
struct CacheKey {
    /// Start column.
    x1: u32,
    /// Start row.
    y1: u32,
    /// Goal column.
    x2: u32,
    /// Goal row.
    y2: u32,
    /// Footprint side length used to compute walkability.
    unit_size: u32,
}

/// Cache lookup key for one shared-goal flow-field request.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct SharedGoalKey {
    /// Sorted and deduplicated target cells shared by all routes in the cached field.
    targets: Vec<(u32, u32)>,
    /// Footprint shape used to compute walkability.
    footprint: FootprintSpec,
}
/// Stateful pathfinder for one unit type sharing a grid reference.
pub struct UnitPathfinder {
    /// Shared walkability grid.
    grid: Rc<RefCell<NavGrid>>,
    /// Cached path results keyed by `CacheKey`.
    cache: HashMap<CacheKey, Option<Vec<Waypoint>>>,
    /// Insertion-order key list used for LRU eviction.
    cache_order: Vec<CacheKey>,
    /// Whether path caching is active.
    cache_enabled: bool,
    /// Maximum number of cached entries before eviction.
    cache_max_size: usize,
    /// Grid generation used by the currently valid cache contents.
    cache_generation: u64,
    /// Cached shared-goal flow fields keyed by goal and footprint.
    shared_goal_cache: HashMap<SharedGoalKey, FlowField>,
    /// Insertion-order key list used for shared-goal cache eviction.
    shared_goal_cache_order: Vec<SharedGoalKey>,
    /// Maximum number of cached shared-goal fields before eviction.
    shared_goal_cache_max_size: usize,
    /// Number of cache hits served by the shared-goal field cache.
    shared_goal_cache_hits: u64,
    /// Number of cache misses that rebuilt one shared-goal field.
    shared_goal_cache_misses: u64,
    /// Caller-reserved cells used by RTS-style batch planners.
    reserved_cells: HashSet<(u32, u32)>,
}
/// All public and private methods for `UnitPathfinder`.
impl UnitPathfinder {
    /// Create a new pathfinder wrapping `grid` with caching enabled and a default max size of 1024.
    pub fn new(grid: Rc<RefCell<NavGrid>>) -> Self {
        log_msg!(debug, UP01);
        Self {
            grid,
            cache: HashMap::new(),
            cache_order: Vec::new(),
            cache_enabled: true,
            cache_max_size: 1024,
            cache_generation: 0,
            shared_goal_cache: HashMap::new(),
            shared_goal_cache_order: Vec::new(),
            shared_goal_cache_max_size: DEFAULT_SHARED_GOAL_CACHE_MAX_SIZE,
            shared_goal_cache_hits: 0,
            shared_goal_cache_misses: 0,
            reserved_cells: HashSet::new(),
        }
    }
    /// Find a path from `(x1, y1)` to `(x2, y2)` for a unit of `unit_size`; return waypoints or `None`.
    pub fn find_path(
        &mut self,
        x1: u32,
        y1: u32,
        x2: u32,
        y2: u32,
        unit_size: u32,
    ) -> Option<Vec<Waypoint>> {
        self.sync_cache_generation();
        let key = CacheKey {
            x1,
            y1,
            x2,
            y2,
            unit_size,
        };
        if self.cache_enabled {
            if let Some(cached) = self.cache.get(&key) {
                return cached.clone();
            }
        }
        let result = {
            let grid = self.grid.borrow();
            let (path, _complete) = astar::astar(&grid, (x1, y1), (x2, y2), unit_size, 0);
            path.map(|p| p.into_iter().map(|(x, y)| Waypoint { x, y }).collect())
        };
        if result.is_some() {
            log_msg!(debug, UP02, "({}, {}) -> ({}, {})", x1, y1, x2, y2);
        } else {
            log_msg!(warn, UP03, "({}, {}) -> ({}, {})", x1, y1, x2, y2);
        }
        if self.cache_enabled {
            self.cache_insert(key, result.clone());
        }
        result
    }
    /// Find a path then apply A\* string-pull smoothing; return waypoints or `None`.
    pub fn find_path_smooth(
        &mut self,
        x1: u32,
        y1: u32,
        x2: u32,
        y2: u32,
        unit_size: u32,
    ) -> Option<Vec<Waypoint>> {
        let grid = self.grid.borrow();
        let (path, _complete) = astar::astar(&grid, (x1, y1), (x2, y2), unit_size, 0);
        path.map(|p| {
            let smoothed = astar::smooth_path(&grid, &p, unit_size);
            smoothed
                .into_iter()
                .map(|(x, y)| Waypoint { x, y })
                .collect()
        })
    }
    /// Build or reuse one shared-goal field, then reconstruct routes from `starts` to `goal`.
    pub fn find_paths_to_goal(
        &mut self,
        starts: &[(u32, u32)],
        goal: (u32, u32),
        unit_size: u32,
        max_steps: u32,
    ) -> Vec<Option<Vec<Waypoint>>> {
        self.find_paths_to_goal_spec(
            starts,
            goal,
            FootprintSpec::new(unit_size, unit_size),
            max_steps,
        )
    }
    /// Find per-unit formation paths by spreading goal cells horizontally around a center.
    pub fn find_formation_paths(
        &mut self,
        starts: &[(u32, u32)],
        goal: (u32, u32),
        unit_size: u32,
        spacing: u32,
    ) -> Vec<Option<Vec<Waypoint>>> {
        let spacing = spacing.max(1);
        let half = starts.len().saturating_sub(1) as i32 / 2;
        starts
            .iter()
            .enumerate()
            .map(|(index, start)| {
                let offset = index as i32 - half;
                let gx = if offset.is_negative() {
                    goal.0.saturating_sub(offset.unsigned_abs() * spacing)
                } else {
                    goal.0.saturating_add(offset as u32 * spacing)
                };
                self.find_path(start.0, start.1, gx, goal.1, unit_size)
            })
            .collect()
    }

    /// Find attack-move paths using the shared-goal path surface.
    pub fn find_attack_move_paths(
        &mut self,
        starts: &[(u32, u32)],
        goal: (u32, u32),
        unit_size: u32,
        max_steps: u32,
    ) -> Vec<Option<Vec<Waypoint>>> {
        self.find_paths_to_goal(starts, goal, unit_size, max_steps)
    }

    /// Reserve caller-owned grid cells for later batch planning.
    pub fn reserve_cells(&mut self, cells: &[(u32, u32)]) -> usize {
        for cell in cells {
            self.reserved_cells.insert(*cell);
        }
        self.reserved_cells.len()
    }

    /// Clear all caller-owned reserved cells.
    pub fn clear_reservations(&mut self) -> usize {
        let count = self.reserved_cells.len();
        self.reserved_cells.clear();
        count
    }
    /// Build or reuse one named-footprint shared-goal field, then reconstruct routes from `starts` to `goal`.
    pub fn find_paths_to_goal_for(
        &mut self,
        starts: &[(u32, u32)],
        goal: (u32, u32),
        footprint_name: &str,
        max_steps: u32,
    ) -> Result<Vec<Option<Vec<Waypoint>>>, String> {
        let footprint = self
            .grid
            .borrow()
            .get_footprint(footprint_name)
            .ok_or_else(|| format!("unknown footprint '{footprint_name}'"))?;
        Ok(self.find_paths_to_goal_spec(starts, goal, footprint, max_steps))
    }
    /// Build or reuse one shared-goal field, then return a cloned handle for one goal cell.
    pub fn get_shared_flow_field(&mut self, goal: (u32, u32), unit_size: u32) -> FlowField {
        self.get_shared_flow_field_spec(&[goal], FootprintSpec::new(unit_size, unit_size))
    }
    /// Build or reuse one named-footprint shared-goal field, then return a cloned handle for one goal cell.
    pub fn get_shared_flow_field_for(
        &mut self,
        goal: (u32, u32),
        footprint_name: &str,
    ) -> Result<FlowField, String> {
        let footprint = self
            .grid
            .borrow()
            .get_footprint(footprint_name)
            .ok_or_else(|| format!("unknown footprint '{footprint_name}'"))?;
        Ok(self.get_shared_flow_field_spec(&[goal], footprint))
    }
    /// Build or reuse one shared-goal field, then return a cloned handle for many target cells.
    pub fn get_shared_flow_field_multi(
        &mut self,
        targets: &[(u32, u32)],
        unit_size: u32,
    ) -> FlowField {
        self.get_shared_flow_field_spec(targets, FootprintSpec::new(unit_size, unit_size))
    }
    /// Build or reuse one named-footprint shared-goal field, then return a cloned handle for many target cells.
    pub fn get_shared_flow_field_multi_for(
        &mut self,
        targets: &[(u32, u32)],
        footprint_name: &str,
    ) -> Result<FlowField, String> {
        let footprint = self
            .grid
            .borrow()
            .get_footprint(footprint_name)
            .ok_or_else(|| format!("unknown footprint '{footprint_name}'"))?;
        Ok(self.get_shared_flow_field_spec(targets, footprint))
    }
    /// Return the Euclidean length of `path` in cells.
    pub fn get_path_length(path: &[Waypoint]) -> f32 {
        let mut total = 0.0f32;
        for i in 1..path.len() {
            let dx = path[i].x as f32 - path[i - 1].x as f32;
            let dy = path[i].y as f32 - path[i - 1].y as f32;
            total += (dx * dx + dy * dy).sqrt();
        }
        total
    }
    /// Return the sum of `NavGrid` costs for all waypoints in `path`.
    pub fn get_path_cost(&self, path: &[Waypoint]) -> f32 {
        let grid = self.grid.borrow();
        let mut total = 0.0f32;
        for wp in path {
            total += grid.get_cost(wp.x, wp.y) as f32;
        }
        total
    }
    /// Run A\* limited to `max_nodes` expansions; return `(partial_path, reached_goal)`.
    pub fn find_partial_path(
        &self,
        x1: u32,
        y1: u32,
        x2: u32,
        y2: u32,
        max_nodes: u32,
        unit_size: u32,
    ) -> (Vec<Waypoint>, bool) {
        let grid = self.grid.borrow();
        let (path, complete) = astar::astar(&grid, (x1, y1), (x2, y2), unit_size, max_nodes);
        let waypoints = path
            .map(|p| p.into_iter().map(|(x, y)| Waypoint { x, y }).collect())
            .unwrap_or_default();
        (waypoints, complete)
    }
    /// BFS-search for the nearest `unit_size`-walkable cell within `max_radius` steps from `(x, y)`.
    pub fn find_nearest_walkable(
        &self,
        x: u32,
        y: u32,
        max_radius: u32,
        unit_size: u32,
    ) -> Option<(u32, u32)> {
        let grid = self.grid.borrow();
        let (w, h) = grid.get_dimensions();
        if x >= w || y >= h {
            return None;
        }
        if grid.is_walkable(x, y, unit_size) {
            return Some((x, y));
        }
        let mut visited = vec![false; (w * h) as usize];
        let mut queue = VecDeque::new();
        visited[(y * w + x) as usize] = true;
        queue.push_back((x, y, 0u32));
        while let Some((cx, cy, dist)) = queue.pop_front() {
            if dist > max_radius {
                break;
            }
            if grid.is_walkable(cx, cy, unit_size) {
                return Some((cx, cy));
            }
            for (dx, dy) in [(-1i32, 0i32), (1, 0), (0, -1), (0, 1)] {
                let nx = cx as i32 + dx;
                let ny = cy as i32 + dy;
                if nx < 0 || ny < 0 || nx >= w as i32 || ny >= h as i32 {
                    continue;
                }
                let (nxu, nyu) = (nx as u32, ny as u32);
                let idx = (nyu * w + nxu) as usize;
                if !visited[idx] {
                    visited[idx] = true;
                    queue.push_back((nxu, nyu, dist + 1));
                }
            }
        }
        Option::None
    }
    /// Return true when `(x2, y2)` is reachable from `(x1, y1)` via BFS for a unit of `unit_size`.
    pub fn is_reachable(&self, x1: u32, y1: u32, x2: u32, y2: u32, unit_size: u32) -> bool {
        let grid = self.grid.borrow();
        let us = unit_size.max(1);
        let (w, h) = grid.get_dimensions();
        if x1 >= w || y1 >= h || x2 >= w || y2 >= h {
            return false;
        }
        if !grid.is_walkable(x1, y1, us) || !grid.is_walkable(x2, y2, us) {
            return false;
        }
        let mut visited = vec![false; (w * h) as usize];
        let mut queue = VecDeque::new();
        visited[(y1 * w + x1) as usize] = true;
        queue.push_back((x1, y1));
        while let Some((cx, cy)) = queue.pop_front() {
            if cx == x2 && cy == y2 {
                return true;
            }
            for (nx, ny) in grid.neighbors(cx, cy) {
                if grid.is_walkable(nx, ny, us) {
                    let idx = (ny * w + nx) as usize;
                    if !visited[idx] {
                        visited[idx] = true;
                        queue.push_back((nx, ny));
                    }
                }
            }
        }
        false
    }
    /// Return the octile distance heuristic between two cell coordinates.
    pub fn heuristic_distance(x1: u32, y1: u32, x2: u32, y2: u32) -> f32 {
        let dx = (x1 as f32 - x2 as f32).abs();
        let dy = (y1 as f32 - y2 as f32).abs();
        let min = dx.min(dy);
        let max = dx.max(dy);
        min * std::f32::consts::SQRT_2 + (max - min)
    }
    /// Enable or disable path and shared-goal caching; clears existing caches when disabled.
    pub fn set_cache_enabled(&mut self, enabled: bool) {
        self.cache_enabled = enabled;
        if !enabled {
            self.cache.clear();
            self.cache_order.clear();
            self.clear_shared_goal_cache();
        }
    }
    /// Return true when path caching is currently enabled.
    pub fn is_cache_enabled(&self) -> bool {
        self.cache_enabled
    }
    /// Remove all cached paths. This function is part of the public API.
    pub fn clear_cache(&mut self) {
        self.cache.clear();
        self.cache_order.clear();
    }
    /// Return the current number of cached entries.
    pub fn get_cache_size(&self) -> usize {
        self.cache.len()
    }
    /// Remove all cached shared-goal fields.
    pub fn clear_shared_goal_cache(&mut self) {
        self.shared_goal_cache.clear();
        self.shared_goal_cache_order.clear();
        self.shared_goal_cache_hits = 0;
        self.shared_goal_cache_misses = 0;
    }
    /// Return the current number of cached shared-goal fields.
    pub fn get_shared_goal_cache_size(&self) -> usize {
        self.shared_goal_cache.len()
    }
    /// Return the number of shared-goal field cache hits since the last cache reset.
    pub fn get_shared_goal_cache_hits(&self) -> u64 {
        self.shared_goal_cache_hits
    }
    /// Return the number of shared-goal field cache misses since the last cache reset.
    pub fn get_shared_goal_cache_misses(&self) -> u64 {
        self.shared_goal_cache_misses
    }
    /// Set the maximum cache size and evict old entries if needed.
    pub fn set_cache_max_size(&mut self, max_size: usize) {
        self.cache_max_size = max_size;
        self.evict();
    }
    /// Return a reference to the shared `NavGrid`.
    pub fn nav_grid(&self) -> &std::rc::Rc<std::cell::RefCell<NavGrid>> {
        &self.grid
    }
    /// Insert a path into the cache and trigger LRU eviction if over `cache_max_size`.
    fn cache_insert(&mut self, key: CacheKey, value: Option<Vec<Waypoint>>) {
        self.cache.insert(key, value);
        self.cache_order.push(key);
        self.evict();
    }

    fn shared_goal_cache_insert(&mut self, key: SharedGoalKey, value: FlowField) {
        self.shared_goal_cache.insert(key.clone(), value);
        self.shared_goal_cache_order.push(key);
        self.evict_shared_goal_cache();
    }

    fn sync_cache_generation(&mut self) {
        let generation = self.grid.borrow().get_generation();
        if generation != self.cache_generation {
            self.cache.clear();
            self.cache_order.clear();
            self.clear_shared_goal_cache();
            self.cache_generation = generation;
        }
    }

    fn find_paths_to_goal_spec(
        &mut self,
        starts: &[(u32, u32)],
        goal: (u32, u32),
        footprint: FootprintSpec,
        max_steps: u32,
    ) -> Vec<Option<Vec<Waypoint>>> {
        let field = self.get_shared_flow_field_spec(&[goal], footprint);
        Self::paths_from_field(&field, starts, max_steps)
    }

    /// Find paths for start-goal pairs using one shared flow field per distinct goal.
    pub(crate) fn find_paths_for_pairs_spec(
        &mut self,
        pairs: &[PathPair],
        footprint: FootprintSpec,
        max_steps: u32,
    ) -> Vec<Option<Vec<Waypoint>>> {
        let mut grouped: IndexedStartsByGoal = HashMap::new();
        for (index, (start, goal)) in pairs.iter().copied().enumerate() {
            grouped.entry(goal).or_default().push((index, start));
        }

        let mut out = vec![None; pairs.len()];
        for (goal, entries) in grouped {
            let starts = entries.iter().map(|(_, start)| *start).collect::<Vec<_>>();
            let paths = self.find_paths_to_goal_spec(&starts, goal, footprint, max_steps);
            for ((index, _), path) in entries.into_iter().zip(paths.into_iter()) {
                out[index] = path;
            }
        }
        out
    }

    fn get_shared_flow_field_spec(
        &mut self,
        targets: &[(u32, u32)],
        footprint: FootprintSpec,
    ) -> FlowField {
        self.sync_cache_generation();
        let key = SharedGoalKey {
            targets: Self::normalize_targets(targets),
            footprint,
        };
        if !self.cache_enabled {
            let mut field = FlowField::new(self.grid.clone());
            field.calculate_multi_spec(&key.targets, footprint);
            return field;
        }
        if let Some(field) = self.shared_goal_cache.get(&key) {
            self.shared_goal_cache_hits = self.shared_goal_cache_hits.saturating_add(1);
            return field.clone();
        }
        self.shared_goal_cache_misses = self.shared_goal_cache_misses.saturating_add(1);
        let mut field = FlowField::new(self.grid.clone());
        field.calculate_multi_spec(&key.targets, footprint);
        self.shared_goal_cache_insert(key, field.clone());
        field
    }

    fn paths_from_field(
        field: &FlowField,
        starts: &[(u32, u32)],
        max_steps: u32,
    ) -> Vec<Option<Vec<Waypoint>>> {
        starts
            .iter()
            .map(|&(x, y)| {
                field.path_from(x, y, max_steps).map(|path| {
                    path.into_iter()
                        .map(|(px, py)| Waypoint { x: px, y: py })
                        .collect()
                })
            })
            .collect()
    }

    /// Remove the oldest cache entry until the cache is at or below `cache_max_size`.
    fn evict(&mut self) {
        while self.cache.len() > self.cache_max_size && !self.cache_order.is_empty() {
            let oldest = self.cache_order.remove(0);
            self.cache.remove(&oldest);
        }
    }

    fn evict_shared_goal_cache(&mut self) {
        while self.shared_goal_cache.len() > self.shared_goal_cache_max_size
            && !self.shared_goal_cache_order.is_empty()
        {
            let oldest = self.shared_goal_cache_order.remove(0);
            self.shared_goal_cache.remove(&oldest);
        }
    }

    fn normalize_targets(targets: &[(u32, u32)]) -> Vec<(u32, u32)> {
        let mut normalized = targets.to_vec();
        normalized.sort_unstable();
        normalized.dedup();
        normalized
    }
}
