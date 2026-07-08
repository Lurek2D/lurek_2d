//! Builds a NavGrid-backed flow field that points each reachable cell toward one or more target cells.
//! Owns direction vectors, accumulated costs, target storage, and the shared-grid reference used for recomputation.
//! Calculates steering data with unit-size aware walkability, then exposes direction, angle, cost, and velocity helpers.
//! Also renders a debug image so field quality and blocked-cell effects can be inspected outside the live renderer.
//! Provides the boundary between raw navigation costs and agent steering systems that need cheap per-frame guidance.
//! Open this owner when target propagation, steering output, or debug visualization stops matching pathing intent.

use crate::runtime::log_messages::{FF01, FF02, FF03};

use crate::log_msg;
use crate::pathfind::nav_grid::{FootprintSpec, NavGrid};
use std::cell::RefCell;
use std::cmp::Ordering;
use std::collections::BinaryHeap;
use std::rc::Rc;

#[derive(Debug, Clone, PartialEq, Eq)]
struct FlowFieldRequest {
    targets: Vec<(u32, u32)>,
    footprint: FootprintSpec,
    generation: u64,
}

#[derive(Debug, Clone, Copy)]
struct FlowFieldNode {
    cost: f32,
    x: u32,
    y: u32,
}

impl PartialEq for FlowFieldNode {
    fn eq(&self, other: &Self) -> bool {
        self.cost == other.cost
    }
}

impl Eq for FlowFieldNode {}

impl Ord for FlowFieldNode {
    fn cmp(&self, other: &Self) -> Ordering {
        other
            .cost
            .partial_cmp(&self.cost)
            .unwrap_or(Ordering::Equal)
    }
}

impl PartialOrd for FlowFieldNode {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}
/// Grid-resident flow field pointing each reachable cell toward one or more goal cells.
#[derive(Clone)]
pub struct FlowField {
    /// Width of the backing grid in cells.
    width: u32,
    /// Height of the backing grid in cells.
    height: u32,
    /// Normalised move direction per cell, pointing toward the nearest goal.
    directions: Vec<(f32, f32)>,
    /// Dijkstra distance from each cell to the nearest goal.
    costs: Vec<f32>,
    /// True after `calculate` or `calculate_multi` has run at least once.
    calculated: bool,
    /// Seed cells used for the last computation.
    targets: Vec<(u32, u32)>,
    /// Shared grid reference used for walkability and move-cost queries.
    grid: Rc<RefCell<NavGrid>>,
    /// Footprint used for the last successful build.
    footprint: FootprintSpec,
    /// Grid generation and request data used for the current field contents.
    last_request: Option<FlowFieldRequest>,
    /// Number of full field builds that actually ran.
    build_count: u64,
}
/// Construction and query methods for `FlowField`.
impl FlowField {
    /// Create an uninitialised flow field linked to `grid`; call `calculate` before querying.
    pub fn new(grid: Rc<RefCell<NavGrid>>) -> Self {
        let g = grid.borrow();
        let w = g.get_width();
        let h = g.get_height();
        let size = (w * h) as usize;
        drop(g);
        log_msg!(debug, FF01);
        Self {
            width: w,
            height: h,
            directions: vec![(0.0, 0.0); size],
            costs: vec![f32::INFINITY; size],
            calculated: false,
            targets: Vec::new(),
            grid,
            footprint: FootprintSpec::new(1, 1),
            last_request: None,
            build_count: 0,
        }
    }
    /// Seed the field with a single target cell and recompute.
    pub fn calculate(&mut self, target_x: u32, target_y: u32, unit_size: u32) -> bool {
        self.calculate_multi(&[(target_x, target_y)], unit_size)
    }
    /// Recompute the field seeded from all cells in `targets`.
    pub fn calculate_multi(&mut self, targets: &[(u32, u32)], unit_size: u32) -> bool {
        self.calculate_multi_spec(targets, FootprintSpec::new(unit_size, unit_size))
    }

    /// Recompute the field using one named rectangular footprint defined on the backing grid.
    pub fn calculate_for(
        &mut self,
        name: &str,
        target_x: u32,
        target_y: u32,
    ) -> Result<bool, String> {
        self.calculate_multi_for(name, &[(target_x, target_y)])
    }

    /// Recompute the field using one named rectangular footprint defined on the backing grid.
    pub fn calculate_multi_for(
        &mut self,
        name: &str,
        targets: &[(u32, u32)],
    ) -> Result<bool, String> {
        let footprint = self
            .grid
            .borrow()
            .get_footprint(name)
            .ok_or_else(|| format!("unknown footprint '{name}'"))?;
        Ok(self.calculate_multi_spec(targets, footprint))
    }

    /// Recompute the field from all cells in `targets` for `footprint`, unless the request matches the current build.
    pub fn calculate_multi_spec(
        &mut self,
        targets: &[(u32, u32)],
        footprint: FootprintSpec,
    ) -> bool {
        let grid = self.grid.borrow();
        let w = grid.get_width();
        let h = grid.get_height();
        let size = (w * h) as usize;
        let request = FlowFieldRequest {
            targets: targets.to_vec(),
            footprint,
            generation: grid.get_generation(),
        };
        if self.last_request.as_ref() == Some(&request) {
            self.calculated = true;
            self.targets = request.targets.clone();
            self.footprint = request.footprint;
            return false;
        }
        log_msg!(debug, FF03);
        self.width = w;
        self.height = h;
        self.directions.clear();
        self.directions.resize(size, (0.0, 0.0));
        self.costs.clear();
        self.costs.resize(size, f32::INFINITY);
        self.targets = request.targets.clone();
        self.footprint = request.footprint;
        let mut queue = BinaryHeap::new();
        for &(tx, ty) in targets {
            if tx < w && ty < h && grid.is_walkable_spec(footprint, tx, ty) {
                let idx = (ty * w + tx) as usize;
                self.costs[idx] = 0.0;
                queue.push(FlowFieldNode {
                    cost: 0.0,
                    x: tx,
                    y: ty,
                });
            }
        }
        while let Some(FlowFieldNode {
            cost: cur_cost,
            x: cx,
            y: cy,
        }) = queue.pop()
        {
            if cur_cost > self.costs[(cy * w + cx) as usize] {
                continue;
            }
            for dy in -1i32..=1 {
                for dx in -1i32..=1 {
                    if dx == 0 && dy == 0 {
                        continue;
                    }
                    let nx = cx as i32 + dx;
                    let ny = cy as i32 + dy;
                    if nx < 0 || ny < 0 || nx >= w as i32 || ny >= h as i32 {
                        continue;
                    }
                    let (nxu, nyu) = (nx as u32, ny as u32);
                    if !grid.is_walkable_spec(footprint, nxu, nyu) {
                        continue;
                    }
                    let is_diag = dx != 0 && dy != 0;
                    let step = if is_diag {
                        std::f32::consts::SQRT_2
                    } else {
                        1.0
                    } * grid.get_cost(nxu, nyu) as f32;
                    let new_cost = cur_cost + step;
                    let n_idx = (nyu * w + nxu) as usize;
                    if new_cost < self.costs[n_idx] {
                        self.costs[n_idx] = new_cost;
                        queue.push(FlowFieldNode {
                            cost: new_cost,
                            x: nxu,
                            y: nyu,
                        });
                    }
                }
            }
        }
        for cy in 0..h {
            for cx in 0..w {
                let idx = (cy * w + cx) as usize;
                if self.costs[idx] == f32::INFINITY {
                    continue;
                }
                let mut best_cost = self.costs[idx];
                let mut best_dir = (0.0f32, 0.0f32);
                for dy in -1i32..=1 {
                    for dx in -1i32..=1 {
                        if dx == 0 && dy == 0 {
                            continue;
                        }
                        let nx = cx as i32 + dx;
                        let ny = cy as i32 + dy;
                        if nx < 0 || ny < 0 || nx >= w as i32 || ny >= h as i32 {
                            continue;
                        }
                        let n_idx = (ny as u32 * w + nx as u32) as usize;
                        if self.costs[n_idx] < best_cost {
                            best_cost = self.costs[n_idx];
                            best_dir = (dx as f32, dy as f32);
                        }
                    }
                }
                let len = (best_dir.0 * best_dir.0 + best_dir.1 * best_dir.1).sqrt();
                if len > 0.0 {
                    self.directions[idx] = (best_dir.0 / len, best_dir.1 / len);
                }
            }
        }
        log_msg!(debug, FF02);
        self.calculated = true;
        self.last_request = Some(request);
        self.build_count = self.build_count.saturating_add(1);
        true
    }
    /// Return the normalised flow direction at `(x, y)`; returns `(0,0)` when out of bounds.
    pub fn get_direction(&self, x: u32, y: u32) -> (f32, f32) {
        if x >= self.width || y >= self.height {
            return (0.0, 0.0);
        }
        self.directions[(y * self.width + x) as usize]
    }
    /// Return the flow direction at `(x, y)` as an angle in radians relative to the +x axis.
    pub fn get_direction_angle(&self, x: u32, y: u32) -> f32 {
        let (dx, dy) = self.get_direction(x, y);
        dy.atan2(dx)
    }
    /// Return the Dijkstra cost from `(x, y)` to the nearest target; `INFINITY` when unreachable.
    pub fn get_cost_to_target(&self, x: u32, y: u32) -> f32 {
        if x >= self.width || y >= self.height {
            return f32::INFINITY;
        }
        self.costs[(y * self.width + x) as usize]
    }
    /// Return true if `calculate` or `calculate_multi` has been called at least once.
    pub fn is_calculated(&self) -> bool {
        self.calculated
    }
    /// Return a clone of the target cells used for the last computation.
    pub fn get_targets(&self) -> Vec<(u32, u32)> {
        self.targets.clone()
    }
    /// Return the footprint used for the last successful build.
    pub fn get_footprint(&self) -> FootprintSpec {
        self.footprint
    }
    /// Return the grid generation that produced the current field contents.
    pub fn get_generation(&self) -> Option<u64> {
        self.last_request.as_ref().map(|request| request.generation)
    }
    /// Return the number of actual field rebuilds that have completed.
    pub fn get_build_count(&self) -> u64 {
        self.build_count
    }
    /// Return the grid width. This function is part of the public API.
    pub fn get_width(&self) -> u32 {
        self.width
    }
    /// Return the grid height. This function is part of the public API.
    pub fn get_height(&self) -> u32 {
        self.height
    }
    /// Reconstruct one downhill route from `(x, y)` to the nearest target using the current field costs.
    pub fn path_from(&self, x: u32, y: u32, max_steps: u32) -> Option<Vec<(u32, u32)>> {
        if !self.calculated || x >= self.width || y >= self.height {
            return None;
        }
        let start_idx = (y * self.width + x) as usize;
        if !self.costs[start_idx].is_finite() {
            return None;
        }
        let mut current = (x, y);
        let step_limit = if max_steps == 0 {
            self.width.saturating_mul(self.height).max(1)
        } else {
            max_steps
        };
        let mut path = Vec::new();
        let mut visited = vec![false; (self.width * self.height) as usize];
        for _ in 0..step_limit {
            let idx = (current.1 * self.width + current.0) as usize;
            if visited[idx] {
                return None;
            }
            visited[idx] = true;
            path.push(current);
            let current_cost = self.costs[idx];
            if current_cost <= f32::EPSILON {
                return Some(path);
            }
            let mut best_next = None;
            let mut best_cost = current_cost;
            for dy in -1i32..=1 {
                for dx in -1i32..=1 {
                    if dx == 0 && dy == 0 {
                        continue;
                    }
                    let nx = current.0 as i32 + dx;
                    let ny = current.1 as i32 + dy;
                    if nx < 0 || ny < 0 || nx >= self.width as i32 || ny >= self.height as i32 {
                        continue;
                    }
                    let candidate = (nx as u32, ny as u32);
                    let candidate_cost =
                        self.costs[(candidate.1 * self.width + candidate.0) as usize];
                    if !candidate_cost.is_finite() || candidate_cost + 0.0001 >= best_cost {
                        continue;
                    }
                    best_cost = candidate_cost;
                    best_next = Some(candidate);
                }
            }
            let next = best_next?;
            current = next;
        }
        None
    }
    /// Convert world position to tile, sample direction, and return a velocity scaled by `speed`.
    pub fn steer(
        &self,
        world_x: f32,
        world_y: f32,
        speed: f32,
        tile_w: f32,
        tile_h: f32,
    ) -> (f32, f32) {
        if tile_w <= 0.0 || tile_h <= 0.0 {
            return (0.0, 0.0);
        }
        let tx = (world_x / tile_w).floor() as i32;
        let ty = (world_y / tile_h).floor() as i32;
        if tx < 0 || ty < 0 || tx >= self.width as i32 || ty >= self.height as i32 {
            return (0.0, 0.0);
        }
        let (dx, dy) = self.get_direction(tx as u32, ty as u32);
        (dx * speed, dy * speed)
    }
    /// Render the flow field to an `ImageData` with `cell_size` pixels per tile for debugging.
    pub fn draw_to_image(&self, cell_size: u32) -> crate::image::ImageData {
        let mut img = crate::image::ImageData::new(self.width * cell_size, self.height * cell_size);
        img.fill(40, 45, 55, 255);
        {
            let g = self.grid.borrow();
            for y in 0..self.height {
                for x in 0..self.width {
                    if g.is_blocked(x, y) {
                        for py in 0..cell_size {
                            for px in 0..cell_size {
                                img.set_pixel(
                                    x * cell_size + px,
                                    y * cell_size + py,
                                    90,
                                    40,
                                    40,
                                    255,
                                );
                            }
                        }
                    }
                }
            }
        }
        for y in 0..self.height {
            for x in 0..self.width {
                if !self.grid.borrow().is_blocked(x, y) {
                    let (dx, dy) = self.get_direction(x, y);
                    if dx.abs() > 0.01 || dy.abs() > 0.01 {
                        let cx = (x * cell_size + cell_size / 2) as i32;
                        let cy = (y * cell_size + cell_size / 2) as i32;
                        let ex = cx + (dx * 6.0) as i32;
                        let ey = cy + (dy * 6.0) as i32;
                        img.draw_line(cx, cy, ex, ey, 100, 200, 255, 200);
                    }
                }
            }
        }
        if let Some(&(tx, ty)) = self.targets.first() {
            img.draw_circle(
                (tx * cell_size + cell_size / 2) as i32,
                (ty * cell_size + cell_size / 2) as i32,
                5,
                255,
                80,
                80,
                255,
            );
        }
        img
    }
}
