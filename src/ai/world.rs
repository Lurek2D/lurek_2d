//! Owns the ai world implementation for the ai subsystem and keeps related runtime rules local here.
//! Keeps AI world state, traits, and decision-facing helpers so helpers stay close to invariants this file updates.
//! Defines how ai world data is validated, transformed, or stored before neighboring systems consume it.
//! Separates ai world behavior from Lua bindings, tests, and sibling owners so integration stays readable.

use crate::ai::agent::{Agent, OrderRuntimeState};
use crate::patterns::Blackboard;
use std::collections::HashMap;
/// Summary of the most recent spatial agent query run through `AIWorld`.
#[derive(Debug, Clone, Default, PartialEq)]
pub struct AISpatialQueryStats {
    /// Number of agents currently registered in the world.
    pub active_agents: usize,
    /// Number of occupied spatial buckets built from the latest world snapshot.
    pub spatial_cells: usize,
    /// Number of spatial queries run since the stats were last reset by recreation.
    pub query_count: usize,
    /// Number of candidate agents tested against radius and filter constraints across all queries.
    pub candidate_checks: usize,
    /// Number of agents returned by the most recent query after sorting and limiting.
    pub returned_agents: usize,
    /// Radius used by the most recent query in world units.
    pub last_radius: f32,
}
/// Summary of command-execution and auto-acquisition work completed during the most recent world update.
#[derive(Debug, Clone, Default, PartialEq)]
pub struct AIOrderRuntimeStats {
    /// Number of agents present when the most recent update began.
    pub active_agents: usize,
    /// Number of queued move orders that steered an agent this frame.
    pub move_orders_steered: usize,
    /// Number of queued move orders completed by arrival this frame.
    pub move_orders_completed: usize,
    /// Number of stance-driven nearby-hostile queries attempted this frame.
    pub acquire_queries: usize,
    /// Number of new hostile targets acquired this frame.
    pub targets_acquired: usize,
    /// Number of queued orders soft-interrupted for engagement this frame.
    pub soft_interrupts: usize,
    /// Number of suspended queued orders resumed this frame.
    pub resumed_orders: usize,
    /// Number of active engagement overrides that remained in effect this frame.
    pub active_engagements: usize,
    /// Number of engagement overrides that broke formation discipline this frame.
    pub formation_breaks: usize,
    /// Number of agents skipped because the per-update acquisition budget was exhausted.
    pub budget_skips: usize,
}
/// Filter options applied to one nearby-agent spatial query.
#[derive(Clone, Copy, Default)]
pub struct SpatialQueryOptions<'a> {
    /// Optional agent name excluded from the result set.
    pub exclude_name: Option<&'a str>,
    /// Optional exact team filter.
    pub team_filter: Option<i32>,
    /// Optional hostile-reference team that excludes same-team agents.
    pub hostile_to_team: Option<i32>,
    /// Optional maximum number of returned agents after sorting.
    pub limit: Option<usize>,
    /// Optional required tag that every result must contain.
    pub required_tag: Option<&'a str>,
    /// Optional blocking tag that excludes matching agents.
    pub blocked_tag: Option<&'a str>,
}
/// World-level AI registry and update surface.
pub struct AIWorld {
    /// Stored agents in index order.
    pub(crate) agents: Vec<Agent>,
    /// Lookup from agent name to index.
    pub(crate) name_index: HashMap<String, usize>,
    /// Shared blackboard inherited by new agents.
    pub(crate) global_blackboard: Blackboard,
    /// Cell size used by the persistent spatial hash for nearby-agent queries.
    pub(crate) spatial_cell_size: f32,
    /// Whether the cached spatial buckets need to be rebuilt before the next query.
    pub(crate) spatial_dirty: bool,
    /// Cached spatial buckets keyed by integer cell coordinates.
    pub(crate) spatial_buckets: HashMap<(i32, i32), Vec<usize>>,
    /// Summary of the most recent spatial query.
    pub(crate) spatial_query_stats: AISpatialQueryStats,
    /// Move-order arrival threshold in world units.
    pub(crate) order_arrival_radius: f32,
    /// Maximum number of auto-acquisition queries attempted in one update.
    pub(crate) auto_acquire_budget: usize,
    /// Fairness cursor used when auto-acquisition is budget-limited.
    pub(crate) auto_acquire_cursor: usize,
    /// Summary of command-execution and auto-acquisition work from the most recent update.
    pub(crate) order_runtime_stats: AIOrderRuntimeStats,
}
impl AIWorld {
    /// Create an empty AI world. This function is part of the public API.
    pub fn new() -> Self {
        Self {
            agents: Vec::new(),
            name_index: HashMap::new(),
            global_blackboard: Blackboard::default(),
            spatial_cell_size: 128.0,
            spatial_dirty: true,
            spatial_buckets: HashMap::new(),
            spatial_query_stats: AISpatialQueryStats::default(),
            order_arrival_radius: 4.0,
            auto_acquire_budget: 64,
            auto_acquire_cursor: 0,
            order_runtime_stats: AIOrderRuntimeStats::default(),
        }
    }
    /// Add a named agent and return its index; returns an error on duplicate names.
    pub fn add_agent(&mut self, name: &str) -> Result<usize, String> {
        if self.name_index.contains_key(name) {
            return Err(format!("Agent '{}' already exists", name));
        }
        let idx = self.agents.len();
        let mut agent = Agent::new(name);
        agent.blackboard.set_parent(self.global_blackboard.clone());
        self.agents.push(agent);
        self.name_index.insert(name.to_string(), idx);
        self.spatial_dirty = true;
        Ok(idx)
    }
    /// Remove an agent by name and rebuild the index map.
    pub fn remove_agent(&mut self, name: &str) -> bool {
        if let Some(&idx) = self.name_index.get(name) {
            self.agents.remove(idx);
            self.name_index.clear();
            for (i, agent) in self.agents.iter().enumerate() {
                self.name_index.insert(agent.name.clone(), i);
            }
            self.spatial_dirty = true;
            true
        } else {
            false
        }
    }
    /// Return the index of an agent by name.
    pub fn get_agent_index(&self, name: &str) -> Option<usize> {
        self.name_index.get(name).copied()
    }
    /// Return a reference to an agent by name.
    pub fn agent(&self, name: &str) -> Option<&Agent> {
        self.name_index.get(name).map(|&idx| &self.agents[idx])
    }
    /// Return a mutable reference to an agent by name.
    pub fn agent_mut(&mut self, name: &str) -> Option<&mut Agent> {
        if let Some(&idx) = self.name_index.get(name) {
            Some(&mut self.agents[idx])
        } else {
            None
        }
    }
    /// Return the number of agents in the world.
    pub fn agent_count(&self) -> usize {
        self.agents.len()
    }
    /// Return the shared global blackboard.
    pub fn global_blackboard(&self) -> &Blackboard {
        &self.global_blackboard
    }
    /// Return the shared global blackboard mutably.
    pub fn global_blackboard_mut(&mut self) -> &mut Blackboard {
        &mut self.global_blackboard
    }
    /// Mark the cached spatial index dirty so the next nearby-agent query rebuilds it.
    pub fn mark_spatial_dirty(&mut self) {
        self.spatial_dirty = true;
    }
    /// Return the spatial-hash cell size in world units.
    pub fn spatial_cell_size(&self) -> f32 {
        self.spatial_cell_size
    }
    /// Set the spatial-hash cell size in world units; values below `1.0` clamp to `1.0`.
    pub fn set_spatial_cell_size(&mut self, size: f32) {
        self.spatial_cell_size = size.max(1.0);
        self.spatial_dirty = true;
    }
    /// Return stats from the most recent nearby-agent query.
    pub fn spatial_query_stats(&self) -> &AISpatialQueryStats {
        &self.spatial_query_stats
    }
    /// Return the move-order arrival threshold in world units.
    pub fn order_arrival_radius(&self) -> f32 {
        self.order_arrival_radius
    }
    /// Set the move-order arrival threshold in world units; negative values clamp to zero.
    pub fn set_order_arrival_radius(&mut self, radius: f32) {
        self.order_arrival_radius = radius.max(0.0);
    }
    /// Return the per-update budget used for stance-driven auto-acquisition queries.
    pub fn auto_acquire_budget(&self) -> usize {
        self.auto_acquire_budget
    }
    /// Set the per-update budget used for stance-driven auto-acquisition queries.
    pub fn set_auto_acquire_budget(&mut self, budget: usize) {
        self.auto_acquire_budget = budget;
    }
    /// Return stats from the most recent update's order/runtime processing.
    pub fn order_runtime_stats(&self) -> &AIOrderRuntimeStats {
        &self.order_runtime_stats
    }
    /// Return nearby agent names sorted by nearest-first distance and filtered by team, hostility, and tags.
    pub fn query_agents_in_radius(
        &mut self,
        center: (f32, f32),
        radius: f32,
        options: SpatialQueryOptions<'_>,
    ) -> Vec<String> {
        self.rebuild_spatial_index_if_needed();
        let radius = radius.max(0.0);
        let limit = options.limit.unwrap_or(16).max(1);
        let cell_size = self.spatial_cell_size.max(1.0);
        let origin = Self::cell_for(center, cell_size);
        let cell_range = (radius / cell_size).ceil() as i32;
        let radius_sq = radius * radius;
        let exclude_index = options.exclude_name.and_then(|name| self.get_agent_index(name));
        let mut matches: Vec<(usize, f32)> = Vec::new();
        self.spatial_query_stats.active_agents = self.agents.len();
        self.spatial_query_stats.spatial_cells = self.spatial_buckets.len();
        self.spatial_query_stats.query_count += 1;
        self.spatial_query_stats.last_radius = radius;
        for dy in -cell_range..=cell_range {
            for dx in -cell_range..=cell_range {
                let key = (origin.0 + dx, origin.1 + dy);
                let Some(bucket) = self.spatial_buckets.get(&key) else {
                    continue;
                };
                for &index in bucket {
                    if Some(index) == exclude_index {
                        continue;
                    }
                    self.spatial_query_stats.candidate_checks += 1;
                    let agent = &self.agents[index];
                    if let Some(team) = options.team_filter {
                        if agent.team != team {
                            continue;
                        }
                    }
                    if let Some(hostile_team) = options.hostile_to_team {
                        if agent.team == hostile_team {
                            continue;
                        }
                    }
                    if let Some(tag) = options.required_tag {
                        if !agent.tags.contains(tag) {
                            continue;
                        }
                    }
                    if let Some(tag) = options.blocked_tag {
                        if agent.tags.contains(tag) {
                            continue;
                        }
                    }
                    let dx = agent.position.0 - center.0;
                    let dy = agent.position.1 - center.1;
                    let dist_sq = dx * dx + dy * dy;
                    if dist_sq > radius_sq {
                        continue;
                    }
                    matches.push((index, dist_sq));
                }
            }
        }
        matches.sort_by(|a, b| a.1.total_cmp(&b.1).then_with(|| a.0.cmp(&b.0)));
        matches.truncate(limit);
        self.spatial_query_stats.returned_agents = matches.len();
        matches
            .into_iter()
            .map(|(index, _)| self.agents[index].name.clone())
            .collect()
    }
    /// Acquire the nearest hostile target for one agent by using the world's spatial index and the agent's stance defaults.
    pub fn acquire_target_for_agent(
        &mut self,
        name: &str,
        radius_override: Option<f32>,
        limit: Option<usize>,
        required_tag: Option<&str>,
        blocked_tag: Option<&str>,
    ) -> Option<String> {
        let (team, position, stance) = {
            let agent = self.agent(name)?;
            (agent.team, agent.position, agent.stance.clone())
        };
        if !stance.acquire_enabled {
            return None;
        }
        let radius = radius_override.unwrap_or_else(|| {
            if stance.acquire_radius > 0.0 {
                stance.acquire_radius
            } else {
                stance.guard_radius.max(stance.chase_radius)
            }
        });
        self.query_agents_in_radius(
            position,
            radius,
            SpatialQueryOptions {
                exclude_name: Some(name),
                hostile_to_team: Some(team),
                limit,
                required_tag,
                blocked_tag,
                ..SpatialQueryOptions::default()
            },
        )
        .into_iter()
        .next()
    }
    /// Advance all agents by integrating velocity and time-based support state over `dt` seconds.
    pub fn update(&mut self, dt: f32) {
        let dt = dt.max(0.0);
        let agent_count = self.agents.len();
        self.order_runtime_stats = AIOrderRuntimeStats {
            active_agents: agent_count,
            ..AIOrderRuntimeStats::default()
        };
        if agent_count == 0 {
            self.spatial_dirty = true;
            return;
        }
        let start = self.auto_acquire_cursor % agent_count;
        let mut remaining_budget = self.auto_acquire_budget;
        for offset in 0..agent_count {
            let idx = (start + offset) % agent_count;
            let (
                name,
                position,
                velocity,
                max_speed,
                team,
                stance,
                current_order,
                runtime_state,
            ) = {
                let agent = &self.agents[idx];
                (
                    agent.name.clone(),
                    agent.position,
                    agent.velocity,
                    agent.max_speed,
                    agent.team,
                    agent.stance.clone(),
                    agent.command_queue.current(),
                    agent.order_runtime.clone(),
                )
            };
            let mut desired_velocity = velocity;
            let mut current_after = current_order.clone();
            let mut engagement_active = false;

            if runtime_state.engage_target.is_some() {
                let cleared = self.update_existing_engagement(
                    idx,
                    position,
                    max_speed,
                    team,
                    &runtime_state,
                    &mut desired_velocity,
                );
                engagement_active = !cleared;
            }

            if !engagement_active {
                if let Some(current) = current_after.as_ref() {
                    if current.kind == "move" {
                        let target = (current.target_x, current.target_y);
                        let dist_sq = Self::distance_sq(position, target);
                        let dist = dist_sq.sqrt();
                        if dist_sq <= self.order_arrival_radius * self.order_arrival_radius {
                            if self.agents[idx]
                                .command_queue
                                .complete_current(Some("arrived".to_string()))
                                .is_some()
                            {
                                self.order_runtime_stats.move_orders_completed += 1;
                            }
                            current_after = None;
                            desired_velocity = (0.0, 0.0);
                        } else if dt > 0.0
                            && dist <= max_speed.max(0.0) * dt + self.order_arrival_radius
                        {
                            if self.agents[idx]
                                .command_queue
                                .complete_current(Some("arrived".to_string()))
                                .is_some()
                            {
                                self.order_runtime_stats.move_orders_completed += 1;
                            }
                            current_after = None;
                            desired_velocity = (
                                (target.0 - position.0) / dt,
                                (target.1 - position.1) / dt,
                            );
                        } else {
                            desired_velocity = Self::seek_velocity(position, target, max_speed);
                            self.order_runtime_stats.move_orders_steered += 1;
                        }
                    }
                }

                let may_query = stance.acquire_enabled
                    && !stance.hold_fire
                    && (current_after.is_none()
                        || current_after
                            .as_ref()
                            .is_some_and(|current| {
                                current.kind == "move"
                                    && current.interruptible
                                    && stance.interrupts_move
                            }));
                if may_query {
                    if remaining_budget > 0 {
                        remaining_budget -= 1;
                        self.order_runtime_stats.acquire_queries += 1;
                        if let Some(target_name) =
                            self.acquire_target_for_agent(&name, None, Some(1), None, None)
                        {
                            let target_position =
                                self.agent(&target_name).map(|target| target.position);
                            {
                                let agent = &mut self.agents[idx];
                                agent.order_runtime = OrderRuntimeState {
                                    engage_target: Some(target_name.clone()),
                                    engage_origin: Some(position),
                                    suspended_order_id: current_after.as_ref().map(|order| order.id),
                                    formation_abandoned: stance.abandon_formation,
                                };
                                if let Some(current) = current_after.as_ref() {
                                    agent.command_queue.push_snapshot_event(
                                        current,
                                        "interrupted",
                                        Some("auto_engage".to_string()),
                                    );
                                    self.order_runtime_stats.soft_interrupts += 1;
                                }
                            }
                            if stance.abandon_formation {
                                self.order_runtime_stats.formation_breaks += 1;
                            }
                            self.order_runtime_stats.targets_acquired += 1;
                            self.order_runtime_stats.active_engagements += 1;
                            if let Some(target_position) = target_position {
                                desired_velocity =
                                    Self::seek_velocity(position, target_position, max_speed);
                            } else {
                                desired_velocity = (0.0, 0.0);
                            }
                        }
                    } else {
                        self.order_runtime_stats.budget_skips += 1;
                    }
                }
            }

            self.agents[idx].velocity = desired_velocity;
        }
        self.auto_acquire_cursor = (start + self.auto_acquire_budget.max(1)) % agent_count;
        for agent in &mut self.agents {
            agent.position.0 += agent.velocity.0 * dt;
            agent.position.1 += agent.velocity.1 * dt;
            if let Some(profile) = &mut agent.trait_profile {
                profile.update(dt);
            }
        }
        self.spatial_dirty = true;
    }
    fn update_existing_engagement(
        &mut self,
        index: usize,
        position: (f32, f32),
        max_speed: f32,
        team: i32,
        runtime_state: &OrderRuntimeState,
        desired_velocity: &mut (f32, f32),
    ) -> bool {
        let Some(target_name) = runtime_state.engage_target.as_deref() else {
            return true;
        };
        let Some(target) = self.agent(target_name) else {
            self.clear_engagement(index, "target_lost");
            return true;
        };
        if target.team == team {
            self.clear_engagement(index, "target_invalid");
            return true;
        }
        let target_position = target.position;
        let origin = runtime_state.engage_origin.unwrap_or(position);
        let leash = if self.agents[index].stance.chase_radius > 0.0 {
            self.agents[index].stance.chase_radius
        } else {
            self.agents[index]
                .stance
                .acquire_radius
                .max(self.agents[index].stance.guard_radius)
        };
        if leash > 0.0 && Self::distance_sq(origin, target_position) > leash * leash {
            self.clear_engagement(index, "chase_limit");
            return true;
        }
        if Self::distance_sq(position, target_position)
            > self.order_arrival_radius * self.order_arrival_radius
        {
            *desired_velocity = Self::seek_velocity(position, target_position, max_speed);
        } else {
            *desired_velocity = (0.0, 0.0);
        }
        self.order_runtime_stats.active_engagements += 1;
        false
    }
    fn clear_engagement(&mut self, index: usize, reason: &str) {
        let suspended_order_id = self.agents[index].order_runtime.suspended_order_id;
        self.agents[index].order_runtime = OrderRuntimeState::default();
        let resumed = {
            let agent = &mut self.agents[index];
            let current = agent.command_queue.current();
            if current.as_ref().map(|order| order.id) == suspended_order_id {
                if let Some(current) = current.as_ref() {
                    agent.command_queue.push_snapshot_event(
                        current,
                        "resumed",
                        Some(reason.to_string()),
                    );
                    true
                } else {
                    false
                }
            } else {
                false
            }
        };
        if resumed {
            self.order_runtime_stats.resumed_orders += 1;
        }
    }
    fn distance_sq(a: (f32, f32), b: (f32, f32)) -> f32 {
        let dx = b.0 - a.0;
        let dy = b.1 - a.1;
        dx * dx + dy * dy
    }
    fn seek_velocity(position: (f32, f32), target: (f32, f32), max_speed: f32) -> (f32, f32) {
        let dx = target.0 - position.0;
        let dy = target.1 - position.1;
        let dist_sq = dx * dx + dy * dy;
        if dist_sq <= f32::EPSILON || max_speed <= 0.0 {
            return (0.0, 0.0);
        }
        let inv_len = dist_sq.sqrt().recip();
        (dx * inv_len * max_speed, dy * inv_len * max_speed)
    }
    fn rebuild_spatial_index_if_needed(&mut self) {
        if !self.spatial_dirty {
            return;
        }
        self.spatial_buckets.clear();
        let cell_size = self.spatial_cell_size.max(1.0);
        for (index, agent) in self.agents.iter().enumerate() {
            let cell = Self::cell_for(agent.position, cell_size);
            self.spatial_buckets.entry(cell).or_default().push(index);
        }
        self.spatial_query_stats.active_agents = self.agents.len();
        self.spatial_query_stats.spatial_cells = self.spatial_buckets.len();
        self.spatial_dirty = false;
    }
    fn cell_for(position: (f32, f32), cell_size: f32) -> (i32, i32) {
        (
            (position.0 / cell_size).floor() as i32,
            (position.1 / cell_size).floor() as i32,
        )
    }
}
/// `Default` delegates to `AIWorld::new`.
impl Default for AIWorld {
    /// Build an empty AI world.
    fn default() -> Self {
        Self::new()
    }
}
