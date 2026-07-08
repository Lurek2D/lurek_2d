//! Implements ORCA-style local collision avoidance that projects preferred motion into safe velocity choices.
//! Owns solver agents, pairwise half-plane constraints, time horizon tuning, spatial neighbor filtering,
//! and the linear projection step used to produce collision-safe motion.
//! Computes a safe velocity for every registered agent while respecting radius and max-speed bounds.
//! Provides the crowd-avoidance boundary between desired steering intent and collision-safe local movement output.
//! Open this owner when avoidance stability, neighbor constraints, safe-velocity projection, or
//! crowd-scale performance behavior needs adjustment.

use std::collections::HashMap;
use std::time::Instant;

/// One agent used by the ORCA solver.
#[derive(Clone)]
pub struct ORCAAgent {
    /// Agent position.
    pub position: (f32, f32),
    /// Current velocity.
    pub velocity: (f32, f32),
    /// Preferred velocity before collision avoidance.
    pub preferred_velocity: (f32, f32),
    /// Velocity chosen by the solver.
    pub safe_velocity: (f32, f32),
    /// Collision radius.
    pub radius: f32,
    /// Maximum speed.
    pub max_speed: f32,
}
impl ORCAAgent {
    /// Create a new agent at `(x, y)`.
    pub fn new(x: f32, y: f32, radius: f32, max_speed: f32) -> Self {
        Self {
            position: (x, y),
            velocity: (0.0, 0.0),
            preferred_velocity: (0.0, 0.0),
            safe_velocity: (0.0, 0.0),
            radius,
            max_speed,
        }
    }
}

/// One summary of the most recent crowd-solver step.
#[derive(Debug, Clone, Default, PartialEq)]
pub struct ORCAComputeStats {
    /// Number of active agents registered with the solver.
    pub active_agents: usize,
    /// Number of agents that completed a full ORCA solve this frame.
    pub processed_agents: usize,
    /// Number of candidate neighbors tested against query radius filters.
    pub neighbor_checks: usize,
    /// Total bounded neighbors retained across all processed agents.
    pub neighbors_used: usize,
    /// Highest retained-neighbor count seen for one processed agent.
    pub max_neighbors_used: usize,
    /// Number of agents whose candidate set exceeded the configured neighbor cap.
    pub truncated_agents: usize,
    /// Number of occupied spatial-hash cells used in the current frame.
    pub spatial_cells: usize,
    /// Whether the current step stopped early because it hit a compute budget.
    pub budget_exhausted: bool,
    /// Wall-clock time spent in the most recent compute step, in milliseconds.
    pub elapsed_ms: f32,
}
/// Internal half-plane constraint used by the linear solver.
#[derive(Clone, Copy)]
struct HalfPlane {
    /// Point on the plane.
    point: (f32, f32),
    /// Outward normal.
    normal: (f32, f32),
}
/// Immutable agent data copied once per solve step so the solver can mutate output velocities safely.
#[derive(Clone, Copy)]
struct AgentSnapshot {
    /// Position at the start of the compute step.
    position: (f32, f32),
    /// Current velocity at the start of the compute step.
    velocity: (f32, f32),
    /// Collision radius.
    radius: f32,
    /// Maximum speed cap.
    max_speed: f32,
    /// Preferred velocity before avoidance.
    preferred_velocity: (f32, f32),
}
/// Solver that computes collision-free velocities for all registered agents.
pub struct ORCASolver {
    /// Lookahead time used by the constraints.
    pub time_horizon: f32,
    /// Maximum neighbors retained for one agent during one solve step.
    pub max_neighbors: usize,
    /// Optional explicit neighbor radius; values `<= 0` use a dynamic radius per agent.
    pub neighbor_radius: f32,
    /// Cell size used by the persistent spatial hash.
    pub spatial_cell_size: f32,
    /// Registered agents.
    pub agents: Vec<ORCAAgent>,
    /// Stable ID lookup for agents inserted through `set_agent`.
    id_to_index: HashMap<usize, usize>,
    /// Reverse mapping for `id_to_index`, aligned to `agents`.
    index_to_id: Vec<Option<usize>>,
    /// Persistent spatial hash rebuilt once per compute step.
    spatial_buckets: HashMap<(i32, i32), Vec<usize>>,
    /// Summary of the most recent solve step.
    last_stats: ORCAComputeStats,
}
impl ORCASolver {
    /// Create a solver with a minimum time horizon of 0.1 seconds.
    pub fn new(time_horizon: f32) -> Self {
        Self {
            time_horizon: time_horizon.max(0.1),
            max_neighbors: 12,
            neighbor_radius: 0.0,
            spatial_cell_size: 32.0,
            agents: Vec::new(),
            id_to_index: HashMap::new(),
            index_to_id: Vec::new(),
            spatial_buckets: HashMap::new(),
            last_stats: ORCAComputeStats::default(),
        }
    }
    /// Add an agent and return its index.
    pub fn add_agent(&mut self, agent: ORCAAgent) -> usize {
        let idx = self.agents.len();
        self.agents.push(agent);
        self.index_to_id.push(None);
        idx
    }
    /// Insert or update an agent stored under a stable caller-provided `id`.
    pub fn set_agent(&mut self, id: usize, agent: ORCAAgent) {
        if let Some(index) = self.id_to_index.get(&id).copied() {
            self.agents[index] = agent;
            return;
        }
        let index = self.agents.len();
        self.agents.push(agent);
        self.index_to_id.push(Some(id));
        self.id_to_index.insert(id, index);
    }
    /// Remove and return the agent at `index`, or `None` when out of bounds.
    pub fn remove_agent(&mut self, index: usize) -> Option<ORCAAgent> {
        self.remove_index(index)
    }
    /// Remove and return the agent stored under a stable `id`, or `None` when absent.
    pub fn remove_agent_by_id(&mut self, id: usize) -> Option<ORCAAgent> {
        let index = self.id_to_index.get(&id).copied()?;
        self.remove_index(index)
    }
    /// Return the number of registered agents.
    pub fn agent_count(&self) -> usize {
        self.agents.len()
    }
    /// Return the configured maximum neighbors retained per agent.
    pub fn max_neighbors(&self) -> usize {
        self.max_neighbors
    }
    /// Set the maximum neighbors retained per agent; values below `1` clamp to `1`.
    pub fn set_max_neighbors(&mut self, max_neighbors: usize) {
        self.max_neighbors = max_neighbors.max(1);
    }
    /// Set the solver-wide neighbor radius; values below zero clamp to `0`.
    pub fn set_neighbor_radius(&mut self, radius: f32) {
        self.neighbor_radius = radius.max(0.0);
    }
    /// Set the spatial-hash cell size in world units; values below `0.1` clamp to `0.1`.
    pub fn set_spatial_cell_size(&mut self, size: f32) {
        self.spatial_cell_size = size.max(0.1);
    }
    /// Resolve either a stable caller-provided ID or a direct vector index into an active slot.
    pub fn resolve_index(&self, key: usize) -> Option<usize> {
        self.id_to_index
            .get(&key)
            .copied()
            .or_else(|| (key < self.agents.len()).then_some(key))
    }
    /// Return an immutable agent reference addressed by stable ID or direct index.
    pub fn agent_for_key(&self, key: usize) -> Option<&ORCAAgent> {
        self.resolve_index(key)
            .and_then(|index| self.agents.get(index))
    }
    /// Return a mutable agent reference addressed by stable ID or direct index.
    pub fn agent_for_key_mut(&mut self, key: usize) -> Option<&mut ORCAAgent> {
        let index = self.resolve_index(key)?;
        self.agents.get_mut(index)
    }
    /// Return the most recent compute-step statistics.
    pub fn last_stats(&self) -> &ORCAComputeStats {
        &self.last_stats
    }
    /// Compute safe velocities for all agents.
    pub fn compute(&mut self, dt: f32) {
        self.compute_with_budget(dt, None);
    }
    /// Compute safe velocities for all agents, optionally stopping once `max_ms` is exhausted.
    pub fn compute_with_budget(&mut self, _dt: f32, max_ms: Option<f32>) {
        let n = self.agents.len();
        let start = Instant::now();
        self.rebuild_spatial_index();
        let mut stats = ORCAComputeStats {
            active_agents: n,
            spatial_cells: self.spatial_buckets.len(),
            ..ORCAComputeStats::default()
        };
        if n == 0 {
            stats.elapsed_ms = start.elapsed().as_secs_f32() * 1000.0;
            self.last_stats = stats;
            return;
        }
        let budget_ms = max_ms.map(|value| value.max(0.0));
        let snapshot: Vec<AgentSnapshot> = self
            .agents
            .iter()
            .map(|a| AgentSnapshot {
                position: a.position,
                velocity: a.velocity,
                radius: a.radius,
                max_speed: a.max_speed,
                preferred_velocity: a.preferred_velocity,
            })
            .collect();
        for i in 0..n {
            if let Some(limit) = budget_ms {
                if start.elapsed().as_secs_f32() * 1000.0 >= limit {
                    stats.budget_exhausted = true;
                    for (remaining, snap) in snapshot.iter().enumerate().take(n).skip(i) {
                        self.agents[remaining].safe_velocity =
                            Self::clamp_speed(snap.preferred_velocity, snap.max_speed);
                    }
                    break;
                }
            }
            let snap = snapshot[i];
            let px = snap.position.0;
            let py = snap.position.1;
            let vx = snap.velocity.0;
            let vy = snap.velocity.1;
            let ri = snap.radius;
            let max_spd = snap.max_speed;
            let pref = snap.preferred_velocity;
            let query_radius = if self.neighbor_radius > 0.0 {
                self.neighbor_radius.max(ri * 2.0)
            } else {
                (max_spd * self.time_horizon + ri * 2.0).max(self.spatial_cell_size)
            };
            let retained = self.collect_neighbors(i, (px, py), query_radius, &snapshot, &mut stats);
            let mut planes: Vec<HalfPlane> = Vec::with_capacity(retained.len());
            for (j, _) in &retained {
                let other = snapshot[*j];
                let opx = other.position.0;
                let opy = other.position.1;
                let ovx = other.velocity.0;
                let ovy = other.velocity.1;
                let rj = other.radius;
                let rel_pos = (opx - px, opy - py);
                let rel_vel = (vx - ovx, vy - ovy);
                let combined_radius = ri + rj;
                let dist_sq = rel_pos.0 * rel_pos.0 + rel_pos.1 * rel_pos.1;
                let r_sq = combined_radius * combined_radius;
                let hp = if dist_sq >= r_sq {
                    let dist = dist_sq.sqrt();
                    let tau = self.time_horizon.max(0.01);
                    let w = (rel_vel.0 - rel_pos.0 / tau, rel_vel.1 - rel_pos.1 / tau);
                    let w_len_sq = w.0 * w.0 + w.1 * w.1;
                    let dot = w.0 * rel_pos.0 + w.1 * rel_pos.1;
                    let (nx, ny) = if dot < 0.0 && dot * dot > r_sq * w_len_sq / (tau * tau) {
                        let (lx, ly) = (rel_pos.0 / dist, rel_pos.1 / dist);
                        (-lx, -ly)
                    } else {
                        let w_len = w_len_sq.sqrt().max(1e-6);
                        (w.0 / w_len, w.1 / w_len)
                    };
                    let u = (
                        nx * combined_radius / tau - rel_vel.0,
                        ny * combined_radius / tau - rel_vel.1,
                    );
                    HalfPlane {
                        point: (vx + u.0 * 0.5, vy + u.1 * 0.5),
                        normal: (nx, ny),
                    }
                } else {
                    let inv_dist = 1.0 / dist_sq.sqrt().max(1e-6);
                    let nx = -rel_pos.0 * inv_dist;
                    let ny = -rel_pos.1 * inv_dist;
                    HalfPlane {
                        point: (vx, vy),
                        normal: (nx, ny),
                    }
                };
                planes.push(hp);
            }
            let safe = Self::linear_program(pref, max_spd, &planes);
            self.agents[i].safe_velocity = safe;
            stats.processed_agents += 1;
        }
        stats.elapsed_ms = start.elapsed().as_secs_f32() * 1000.0;
        self.last_stats = stats;
    }
    /// Project the preferred velocity against the half-plane set and clamp speed.
    fn linear_program(preferred: (f32, f32), max_speed: f32, planes: &[HalfPlane]) -> (f32, f32) {
        let (mut vx, mut vy) = Self::clamp_speed(preferred, max_speed);
        for plane in planes {
            let dot = (vx - plane.point.0) * plane.normal.0 + (vy - plane.point.1) * plane.normal.1;
            if dot < 0.0 {
                let proj_len =
                    dot / (plane.normal.0 * plane.normal.0 + plane.normal.1 * plane.normal.1);
                vx -= proj_len * plane.normal.0;
                vy -= proj_len * plane.normal.1;
                (vx, vy) = Self::clamp_speed((vx, vy), max_speed);
            }
        }
        (vx, vy)
    }
    fn clamp_speed(velocity: (f32, f32), max_speed: f32) -> (f32, f32) {
        let mut vx = velocity.0;
        let mut vy = velocity.1;
        let spd_sq = vx * vx + vy * vy;
        if spd_sq > max_speed * max_speed && max_speed > 0.0 {
            let s = max_speed / spd_sq.sqrt();
            vx *= s;
            vy *= s;
        }
        (vx, vy)
    }
    fn remove_index(&mut self, index: usize) -> Option<ORCAAgent> {
        if index >= self.agents.len() {
            return None;
        }
        let removed_id = self.index_to_id.get(index).copied().flatten();
        let moved_id = if index + 1 < self.agents.len() {
            self.index_to_id.last().copied().flatten()
        } else {
            None
        };
        let removed = self.agents.swap_remove(index);
        self.index_to_id.swap_remove(index);
        if let Some(id) = removed_id {
            self.id_to_index.remove(&id);
        }
        if let Some(id) = moved_id {
            self.id_to_index.insert(id, index);
        }
        Some(removed)
    }
    fn rebuild_spatial_index(&mut self) {
        self.spatial_buckets.clear();
        let cell_size = self.spatial_cell_size.max(0.1);
        for (index, agent) in self.agents.iter().enumerate() {
            let cell = Self::cell_for(agent.position, cell_size);
            self.spatial_buckets.entry(cell).or_default().push(index);
        }
    }
    fn collect_neighbors(
        &self,
        agent_index: usize,
        position: (f32, f32),
        query_radius: f32,
        snapshot: &[AgentSnapshot],
        stats: &mut ORCAComputeStats,
    ) -> Vec<(usize, f32)> {
        let cell_size = self.spatial_cell_size.max(0.1);
        let cell = Self::cell_for(position, cell_size);
        let cell_range = (query_radius / cell_size).ceil() as i32;
        let query_radius_sq = query_radius * query_radius;
        let mut neighbors: Vec<(usize, f32)> = Vec::with_capacity(self.max_neighbors);
        let mut truncated = false;
        for dy in -cell_range..=cell_range {
            for dx in -cell_range..=cell_range {
                let key = (cell.0 + dx, cell.1 + dy);
                let Some(bucket) = self.spatial_buckets.get(&key) else {
                    continue;
                };
                for &other_index in bucket {
                    if other_index == agent_index {
                        continue;
                    }
                    stats.neighbor_checks += 1;
                    let other = snapshot[other_index];
                    let dx = other.position.0 - position.0;
                    let dy = other.position.1 - position.1;
                    let dist_sq = dx * dx + dy * dy;
                    if dist_sq > query_radius_sq {
                        continue;
                    }
                    neighbors.push((other_index, dist_sq));
                    neighbors.sort_by(|a, b| a.1.total_cmp(&b.1));
                    if neighbors.len() > self.max_neighbors {
                        neighbors.truncate(self.max_neighbors);
                        truncated = true;
                    }
                }
            }
        }
        stats.neighbors_used += neighbors.len();
        stats.max_neighbors_used = stats.max_neighbors_used.max(neighbors.len());
        if truncated {
            stats.truncated_agents += 1;
        }
        neighbors
    }
    fn cell_for(position: (f32, f32), cell_size: f32) -> (i32, i32) {
        (
            (position.0 / cell_size).floor() as i32,
            (position.1 / cell_size).floor() as i32,
        )
    }
}
