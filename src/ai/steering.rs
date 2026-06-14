//! Provides continuous movement intent synthesis for agents that steer instead of teleporting state.
//! Combines concurrent influences into one force signal while preserving controllable blending semantics.
//! Supports reactive pursuit, evasion, spacing, and exploratory drift as composable motion textures.
//! Integrates waypoint progression so authored path flow and emergent steering can coexist smoothly.
//! Applies bounded output shaping to keep acceleration pressure stable for frame-to-frame integration.
//! Treats path following as a first-class influence that can lead or defer to behavior priorities.
//! Preserves deterministic fallback when no active influence produces meaningful directional intent.
//! Exposes configurable weighting that lets designers tune expressive movement character per actor role.
//! Maintains lightweight state for runtime-safe updates under dense multi-agent simulation loads.
//! Serves as the tactical locomotion bridge between decision outputs and physics-facing motion updates.

use std::collections::HashMap;

/// Force vector used by steering systems.
pub type Force = (f32, f32);

/// Named entity state used by pursue, evade, and flock steering.
#[derive(Debug, Clone)]
pub struct SteeringEntity {
    /// Stable entity name used by named steering behaviors.
    pub name: String,
    /// Current world position.
    pub position: (f32, f32),
    /// Current world velocity.
    pub velocity: (f32, f32),
}

struct FlockParams<'a> {
    neighbor_radius: f32,
    sep_weight: f32,
    align_weight: f32,
    coh_weight: f32,
    neighbor_names: &'a [String],
}

/// How multiple steering behaviors are blended.
#[derive(Debug, Clone, PartialEq)]
pub enum CombineMode {
    /// Sum all enabled behaviors with weights.
    Weighted,
    /// Take the first non-zero behavior.
    Priority,
}
impl CombineMode {
    /// Parse a string tag into `CombineMode`; unknown strings map to `Weighted`.
    pub fn parse_str(s: &str) -> Self {
        match s {
            "priority" => Self::Priority,
            _ => Self::Weighted,
        }
    }
    /// Return the canonical string tag for this mode.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Weighted => "weighted",
            Self::Priority => "priority",
        }
    }
}
/// Shared enable/weight state for a steering behavior.
#[derive(Debug, Clone)]
pub struct SteeringBase {
    /// Multiplier used when combining this behavior.
    pub weight: f32,
    /// Whether the behavior participates in evaluation.
    pub enabled: bool,
}
/// `Default` provides a weight of 1.0 and enabled=true.
impl Default for SteeringBase {
    /// Return a base with weight 1.0 and enabled.
    fn default() -> Self {
        Self {
            weight: 1.0,
            enabled: true,
        }
    }
}
/// Individual steering behavior variants.
#[derive(Debug, Clone)]
pub enum SteeringBehaviorType {
    /// Seek a target point.
    Seek {
        /// Target world position.
        target: (f32, f32),
        /// Shared enable/weight state.
        base: SteeringBase,
    },
    /// Flee from a target point.
    Flee {
        /// Threat world position.
        target: (f32, f32),
        /// Distance at which the flee behavior becomes inactive.
        panic_dist: f32,
        /// Shared enable/weight state.
        base: SteeringBase,
    },
    /// Slow down as the agent approaches a target.
    Arrive {
        /// Target world position.
        target: (f32, f32),
        /// Radius used to scale down speed near the target.
        slowing_radius: f32,
        /// Shared enable/weight state.
        base: SteeringBase,
    },
    /// Wander using a jittered circle projected in front of the agent.
    Wander {
        /// Wander circle radius.
        wander_radius: f32,
        /// Distance in front of the agent where the wander circle is projected.
        wander_distance: f32,
        /// Per-update angular jitter.
        wander_jitter: f32,
        /// Current wander angle.
        wander_angle: f32,
        /// Shared enable/weight state.
        base: SteeringBase,
    },
    /// Pursue a named target.
    Pursue {
        /// Optional target entity name.
        target_name: Option<String>,
        /// Shared enable/weight state.
        base: SteeringBase,
    },
    /// Evade a named threat.
    Evade {
        /// Optional threat entity name.
        threat_name: Option<String>,
        /// Shared enable/weight state.
        base: SteeringBase,
    },
    /// Flock toward a set of neighbors.
    Flock {
        /// Radius used for neighbor gathering.
        neighbor_radius: f32,
        /// Separation force weight.
        sep_weight: f32,
        /// Alignment force weight.
        align_weight: f32,
        /// Cohesion force weight.
        coh_weight: f32,
        /// Named neighbors considered by the flock.
        neighbor_names: Vec<String>,
        /// Shared enable/weight state.
        base: SteeringBase,
    },
    /// Custom steering driven by a Lua callback id.
    Custom {
        /// Registry index of the custom callback.
        callback_id: u32,
        /// Shared enable/weight state.
        base: SteeringBase,
    },
}
impl SteeringBehaviorType {
    /// Return the shared base state for the behavior.
    pub fn base(&self) -> &SteeringBase {
        match self {
            Self::Seek { base, .. }
            | Self::Flee { base, .. }
            | Self::Arrive { base, .. }
            | Self::Wander { base, .. }
            | Self::Pursue { base, .. }
            | Self::Evade { base, .. }
            | Self::Flock { base, .. }
            | Self::Custom { base, .. } => base,
        }
    }
    /// Return the mutable shared base state for the behavior.
    pub fn base_mut(&mut self) -> &mut SteeringBase {
        match self {
            Self::Seek { base, .. }
            | Self::Flee { base, .. }
            | Self::Arrive { base, .. }
            | Self::Wander { base, .. }
            | Self::Pursue { base, .. }
            | Self::Evade { base, .. }
            | Self::Flock { base, .. }
            | Self::Custom { base, .. } => base,
        }
    }
    /// Return the canonical behavior kind string.
    pub fn kind(&self) -> &'static str {
        match self {
            Self::Seek { .. } => "seek",
            Self::Flee { .. } => "flee",
            Self::Arrive { .. } => "arrive",
            Self::Wander { .. } => "wander",
            Self::Pursue { .. } => "pursue",
            Self::Evade { .. } => "evade",
            Self::Flock { .. } => "flock",
            Self::Custom { .. } => "custom",
        }
    }
    /// Compute the steering force for this behavior.
    pub fn calculate(
        &self,
        agent_pos: (f32, f32),
        agent_vel: (f32, f32),
        max_speed: f32,
        _dt: f32,
    ) -> Force {
        if !self.base().enabled {
            return (0.0, 0.0);
        }
        match self {
            Self::Seek { target, .. } => {
                let dx = target.0 - agent_pos.0;
                let dy = target.1 - agent_pos.1;
                let dist = (dx * dx + dy * dy).sqrt();
                if dist < 0.001 {
                    return (0.0, 0.0);
                }
                let desired_x = (dx / dist) * max_speed;
                let desired_y = (dy / dist) * max_speed;
                (desired_x - agent_vel.0, desired_y - agent_vel.1)
            }
            Self::Flee {
                target, panic_dist, ..
            } => {
                let dx = agent_pos.0 - target.0;
                let dy = agent_pos.1 - target.1;
                let dist = (dx * dx + dy * dy).sqrt();
                if dist > *panic_dist && *panic_dist > 0.0 {
                    return (0.0, 0.0);
                }
                if dist < 0.001 {
                    return (0.0, 0.0);
                }
                let desired_x = (dx / dist) * max_speed;
                let desired_y = (dy / dist) * max_speed;
                (desired_x - agent_vel.0, desired_y - agent_vel.1)
            }
            Self::Arrive {
                target,
                slowing_radius,
                ..
            } => {
                let dx = target.0 - agent_pos.0;
                let dy = target.1 - agent_pos.1;
                let dist = (dx * dx + dy * dy).sqrt();
                if dist < 0.001 {
                    return (-agent_vel.0, -agent_vel.1);
                }
                let speed = if dist < *slowing_radius {
                    max_speed * (dist / slowing_radius)
                } else {
                    max_speed
                };
                let desired_x = (dx / dist) * speed;
                let desired_y = (dy / dist) * speed;
                (desired_x - agent_vel.0, desired_y - agent_vel.1)
            }
            Self::Wander {
                wander_radius,
                wander_distance,
                wander_angle,
                ..
            } => {
                let speed = (agent_vel.0 * agent_vel.0 + agent_vel.1 * agent_vel.1).sqrt();
                let (heading_x, heading_y) = if speed > 0.001 {
                    (agent_vel.0 / speed, agent_vel.1 / speed)
                } else {
                    (1.0, 0.0)
                };
                let circle_x = agent_pos.0 + heading_x * wander_distance;
                let circle_y = agent_pos.1 + heading_y * wander_distance;
                let target_x = circle_x + wander_angle.cos() * wander_radius;
                let target_y = circle_y + wander_angle.sin() * wander_radius;
                let dx = target_x - agent_pos.0;
                let dy = target_y - agent_pos.1;
                let dist = (dx * dx + dy * dy).sqrt();
                if dist < 0.001 {
                    return (0.0, 0.0);
                }
                let desired_x = (dx / dist) * max_speed;
                let desired_y = (dy / dist) * max_speed;
                (desired_x - agent_vel.0, desired_y - agent_vel.1)
            }
            Self::Pursue { .. } | Self::Evade { .. } | Self::Flock { .. } => (0.0, 0.0),
            Self::Custom { .. } => (0.0, 0.0),
        }
    }
}
/// Aggregates steering behaviors and optional waypoint path following.
pub struct SteeringManager {
    /// Registered behaviors.
    pub behaviors: Vec<SteeringBehaviorType>,
    /// Current blend mode.
    pub combine_mode: CombineMode,
    /// Last computed force.
    pub last_force: Force,
    /// Spatial-hash cell size.
    pub cell_size: f32,
    /// Whether spatial hashing is enabled.
    pub use_spatial_hash: bool,
    /// Active waypoint path.
    pub path_waypoints: Vec<(f32, f32)>,
    /// Next waypoint index.
    pub path_index: usize,
    /// Distance threshold for waypoint advancement.
    pub path_reach_radius: f32,
    /// Weight applied to path following.
    pub path_weight: f32,
    /// Named entities available to context-aware steering behaviors.
    pub entities: HashMap<String, SteeringEntity>,
}
impl SteeringManager {
    /// Create a steering manager with default parameters.
    pub fn new() -> Self {
        Self {
            behaviors: Vec::new(),
            combine_mode: CombineMode::Weighted,
            last_force: (0.0, 0.0),
            cell_size: 64.0,
            use_spatial_hash: false,
            path_waypoints: Vec::new(),
            path_index: 0,
            path_reach_radius: 12.0,
            path_weight: 1.0,
            entities: HashMap::new(),
        }
    }
    /// Combine all enabled behaviors and clamp the result to `max_force`.
    pub fn calculate(
        &mut self,
        agent_pos: (f32, f32),
        agent_vel: (f32, f32),
        max_speed: f32,
        max_force: f32,
        dt: f32,
    ) -> Force {
        let mut combined = (0.0f32, 0.0f32);
        let path_force = self.calculate_path_force(agent_pos, agent_vel, max_speed);
        match self.combine_mode {
            CombineMode::Weighted => {
                combined.0 += path_force.0 * self.path_weight;
                combined.1 += path_force.1 * self.path_weight;
                for b in &self.behaviors {
                    let f = self.calculate_behavior(b, agent_pos, agent_vel, max_speed, dt);
                    let w = b.base().weight;
                    combined.0 += f.0 * w;
                    combined.1 += f.1 * w;
                }
            }
            CombineMode::Priority => {
                let path_mag = (path_force.0 * path_force.0 + path_force.1 * path_force.1).sqrt();
                if path_mag > 0.001 {
                    combined = (
                        path_force.0 * self.path_weight,
                        path_force.1 * self.path_weight,
                    );
                } else {
                    for b in &self.behaviors {
                        let f = self.calculate_behavior(b, agent_pos, agent_vel, max_speed, dt);
                        let mag = (f.0 * f.0 + f.1 * f.1).sqrt();
                        if mag > 0.001 {
                            combined = (f.0 * b.base().weight, f.1 * b.base().weight);
                            break;
                        }
                    }
                }
            }
        }
        let mag = (combined.0 * combined.0 + combined.1 * combined.1).sqrt();
        if mag > max_force {
            let scale = max_force / mag;
            combined.0 *= scale;
            combined.1 *= scale;
        }
        self.last_force = combined;
        combined
    }
    /// Set or replace one named entity in the steering context.
    pub fn set_entity(&mut self, name: String, position: (f32, f32), velocity: (f32, f32)) {
        self.entities.insert(
            name.clone(),
            SteeringEntity {
                name,
                position,
                velocity,
            },
        );
    }
    /// Remove one named entity from the steering context.
    pub fn remove_entity(&mut self, name: &str) -> bool {
        self.entities.remove(name).is_some()
    }
    /// Clear all steering-context entities.
    pub fn clear_entities(&mut self) {
        self.entities.clear();
    }
    /// Return the number of steering-context entities.
    pub fn entity_count(&self) -> usize {
        self.entities.len()
    }
    /// Add a seek behavior. This function is part of the public API.
    pub fn add_seek(&mut self, tx: f32, ty: f32, weight: f32) {
        self.behaviors.push(SteeringBehaviorType::Seek {
            target: (tx, ty),
            base: SteeringBase {
                weight,
                enabled: true,
            },
        });
    }
    /// Add a flee behavior. This function is part of the public API.
    pub fn add_flee(&mut self, tx: f32, ty: f32, panic_dist: f32, weight: f32) {
        self.behaviors.push(SteeringBehaviorType::Flee {
            target: (tx, ty),
            panic_dist,
            base: SteeringBase {
                weight,
                enabled: true,
            },
        });
    }
    /// Add an arrive behavior. This function is part of the public API.
    pub fn add_arrive(&mut self, tx: f32, ty: f32, slowing_radius: f32, weight: f32) {
        self.behaviors.push(SteeringBehaviorType::Arrive {
            target: (tx, ty),
            slowing_radius,
            base: SteeringBase {
                weight,
                enabled: true,
            },
        });
    }
    /// Add a wander behavior. This function is part of the public API.
    pub fn add_wander(&mut self, radius: f32, distance: f32, jitter: f32, weight: f32) {
        self.behaviors.push(SteeringBehaviorType::Wander {
            wander_radius: radius,
            wander_distance: distance,
            wander_jitter: jitter,
            wander_angle: 0.0,
            base: SteeringBase {
                weight,
                enabled: true,
            },
        });
    }
    /// Add a pursue behavior. This function is part of the public API.
    pub fn add_pursue(&mut self, target_name: Option<String>, weight: f32) {
        self.behaviors.push(SteeringBehaviorType::Pursue {
            target_name,
            base: SteeringBase {
                weight,
                enabled: true,
            },
        });
    }
    /// Add an evade behavior. This function is part of the public API.
    pub fn add_evade(&mut self, threat_name: Option<String>, weight: f32) {
        self.behaviors.push(SteeringBehaviorType::Evade {
            threat_name,
            base: SteeringBase {
                weight,
                enabled: true,
            },
        });
    }
    /// Add a flock behavior. This function is part of the public API.
    pub fn add_flock(&mut self, neighbor_radius: f32, sep: f32, align: f32, coh: f32, weight: f32) {
        self.behaviors.push(SteeringBehaviorType::Flock {
            neighbor_radius,
            sep_weight: sep,
            align_weight: align,
            coh_weight: coh,
            neighbor_names: Vec::new(),
            base: SteeringBase {
                weight,
                enabled: true,
            },
        });
    }
    /// Set combine mode from a string tag.
    pub fn set_combine_mode_str(&mut self, mode: &str) {
        self.combine_mode = CombineMode::parse_str(mode);
    }
    /// Return the last computed force.
    pub fn last_force(&self) -> Force {
        self.last_force
    }
    /// Set the spatial-hash cell size.
    pub fn set_cell_size(&mut self, size: f32) {
        self.cell_size = size.max(0.1);
    }
    /// Enable or disable spatial hashing.
    pub fn set_use_spatial_hash(&mut self, enabled: bool) {
        self.use_spatial_hash = enabled;
    }
    /// Replace the waypoint path and reset traversal state.
    pub fn set_path(&mut self, waypoints: Vec<(f32, f32)>, reach_radius: f32, weight: f32) {
        self.path_waypoints = waypoints;
        self.path_index = 0;
        self.path_reach_radius = reach_radius.max(0.1);
        self.path_weight = weight.max(0.0);
    }
    /// Clear all waypoints and reset path progress.
    pub fn clear_path(&mut self) {
        self.path_waypoints.clear();
        self.path_index = 0;
    }
    /// Return `true` when there are remaining waypoints.
    pub fn has_active_path(&self) -> bool {
        self.path_index < self.path_waypoints.len()
    }
    /// Return `(current_index, waypoint_count)`.
    pub fn path_progress(&self) -> (usize, usize) {
        (self.path_index, self.path_waypoints.len())
    }
    /// Compute the force that follows the current waypoint path.
    fn calculate_path_force(
        &mut self,
        agent_pos: (f32, f32),
        agent_vel: (f32, f32),
        max_speed: f32,
    ) -> Force {
        while self.path_index < self.path_waypoints.len() {
            let wp = self.path_waypoints[self.path_index];
            let dx = wp.0 - agent_pos.0;
            let dy = wp.1 - agent_pos.1;
            let dist = (dx * dx + dy * dy).sqrt();
            if dist <= self.path_reach_radius {
                self.path_index += 1;
            } else {
                break;
            }
        }
        if self.path_index >= self.path_waypoints.len() {
            return (0.0, 0.0);
        }
        let target = self.path_waypoints[self.path_index];
        let dx = target.0 - agent_pos.0;
        let dy = target.1 - agent_pos.1;
        let dist = (dx * dx + dy * dy).sqrt();
        if dist < 0.001 {
            return (0.0, 0.0);
        }
        let is_last = self.path_index + 1 == self.path_waypoints.len();
        let desired_speed = if is_last {
            let slowing_radius = (self.path_reach_radius * 3.0).max(1.0);
            if dist < slowing_radius {
                max_speed * (dist / slowing_radius)
            } else {
                max_speed
            }
        } else {
            max_speed
        };
        let desired_x = (dx / dist) * desired_speed;
        let desired_y = (dy / dist) * desired_speed;
        (desired_x - agent_vel.0, desired_y - agent_vel.1)
    }

    /// Calculate one behavior, including context-aware named-entity behaviors.
    fn calculate_behavior(
        &self,
        behavior: &SteeringBehaviorType,
        agent_pos: (f32, f32),
        agent_vel: (f32, f32),
        max_speed: f32,
        dt: f32,
    ) -> Force {
        if !behavior.base().enabled {
            return (0.0, 0.0);
        }
        match behavior {
            SteeringBehaviorType::Pursue { target_name, .. } => {
                let Some(target) = self.resolve_target(target_name.as_deref(), agent_pos) else {
                    return (0.0, 0.0);
                };
                let target = predicted_position(target, agent_pos, max_speed);
                seek_force(agent_pos, agent_vel, target, max_speed)
            }
            SteeringBehaviorType::Evade { threat_name, .. } => {
                let Some(threat) = self.resolve_target(threat_name.as_deref(), agent_pos) else {
                    return (0.0, 0.0);
                };
                let threat = predicted_position(threat, agent_pos, max_speed);
                flee_force(agent_pos, agent_vel, threat, max_speed)
            }
            SteeringBehaviorType::Flock {
                neighbor_radius,
                sep_weight,
                align_weight,
                coh_weight,
                neighbor_names,
                ..
            } => self.calculate_flock(
                agent_pos,
                agent_vel,
                max_speed,
                FlockParams {
                    neighbor_radius: *neighbor_radius,
                    sep_weight: *sep_weight,
                    align_weight: *align_weight,
                    coh_weight: *coh_weight,
                    neighbor_names,
                },
            ),
            _ => behavior.calculate(agent_pos, agent_vel, max_speed, dt),
        }
    }

    /// Resolve a named target or the nearest available entity when no name is supplied.
    fn resolve_target(&self, name: Option<&str>, agent_pos: (f32, f32)) -> Option<&SteeringEntity> {
        if let Some(name) = name {
            return self.entities.get(name);
        }
        self.entities.values().min_by(|a, b| {
            distance_sq(agent_pos, a.position).total_cmp(&distance_sq(agent_pos, b.position))
        })
    }

    /// Calculate flocking from nearby named entities.
    fn calculate_flock(
        &self,
        agent_pos: (f32, f32),
        agent_vel: (f32, f32),
        max_speed: f32,
        params: FlockParams<'_>,
    ) -> Force {
        let radius = params.neighbor_radius.max(0.0);
        if radius <= 0.0 || self.entities.is_empty() {
            return (0.0, 0.0);
        }

        let neighbors = self.neighbors(agent_pos, radius, params.neighbor_names);
        if neighbors.is_empty() {
            return (0.0, 0.0);
        }

        let mut separation = (0.0f32, 0.0f32);
        let mut avg_velocity = (0.0f32, 0.0f32);
        let mut avg_position = (0.0f32, 0.0f32);

        for entity in &neighbors {
            let dx = agent_pos.0 - entity.position.0;
            let dy = agent_pos.1 - entity.position.1;
            let dist_sq = (dx * dx + dy * dy).max(0.0001);
            separation.0 += dx / dist_sq;
            separation.1 += dy / dist_sq;
            avg_velocity.0 += entity.velocity.0;
            avg_velocity.1 += entity.velocity.1;
            avg_position.0 += entity.position.0;
            avg_position.1 += entity.position.1;
        }

        let count = neighbors.len() as f32;
        avg_velocity.0 /= count;
        avg_velocity.1 /= count;
        avg_position.0 /= count;
        avg_position.1 /= count;

        let separation = normalize_to_speed(separation, max_speed);
        let alignment = (avg_velocity.0 - agent_vel.0, avg_velocity.1 - agent_vel.1);
        let cohesion = seek_force(agent_pos, agent_vel, avg_position, max_speed);

        (
            separation.0 * params.sep_weight
                + alignment.0 * params.align_weight
                + cohesion.0 * params.coh_weight,
            separation.1 * params.sep_weight
                + alignment.1 * params.align_weight
                + cohesion.1 * params.coh_weight,
        )
    }

    /// Return nearby entities, using a transient spatial hash when enabled.
    fn neighbors(
        &self,
        agent_pos: (f32, f32),
        radius: f32,
        neighbor_names: &[String],
    ) -> Vec<&SteeringEntity> {
        if !neighbor_names.is_empty() {
            return neighbor_names
                .iter()
                .filter_map(|name| self.entities.get(name))
                .filter(|entity| distance_sq(agent_pos, entity.position) <= radius * radius)
                .collect();
        }

        if !self.use_spatial_hash {
            return self
                .entities
                .values()
                .filter(|entity| distance_sq(agent_pos, entity.position) <= radius * radius)
                .collect();
        }

        let cell_size = self.cell_size.max(0.1);
        let agent_cell = cell_for(agent_pos, cell_size);
        let span = (radius / cell_size).ceil() as i32;
        let mut buckets: HashMap<(i32, i32), Vec<&SteeringEntity>> = HashMap::new();
        for entity in self.entities.values() {
            buckets
                .entry(cell_for(entity.position, cell_size))
                .or_default()
                .push(entity);
        }

        let mut out = Vec::new();
        for cy in agent_cell.1 - span..=agent_cell.1 + span {
            for cx in agent_cell.0 - span..=agent_cell.0 + span {
                if let Some(bucket) = buckets.get(&(cx, cy)) {
                    for entity in bucket {
                        if distance_sq(agent_pos, entity.position) <= radius * radius {
                            out.push(*entity);
                        }
                    }
                }
            }
        }
        out
    }
}

fn seek_force(
    agent_pos: (f32, f32),
    agent_vel: (f32, f32),
    target: (f32, f32),
    max_speed: f32,
) -> Force {
    let dx = target.0 - agent_pos.0;
    let dy = target.1 - agent_pos.1;
    let dist = (dx * dx + dy * dy).sqrt();
    if dist < 0.001 {
        return (0.0, 0.0);
    }
    let desired_x = (dx / dist) * max_speed;
    let desired_y = (dy / dist) * max_speed;
    (desired_x - agent_vel.0, desired_y - agent_vel.1)
}

fn flee_force(
    agent_pos: (f32, f32),
    agent_vel: (f32, f32),
    threat: (f32, f32),
    max_speed: f32,
) -> Force {
    let dx = agent_pos.0 - threat.0;
    let dy = agent_pos.1 - threat.1;
    let dist = (dx * dx + dy * dy).sqrt();
    if dist < 0.001 {
        return (0.0, 0.0);
    }
    let desired_x = (dx / dist) * max_speed;
    let desired_y = (dy / dist) * max_speed;
    (desired_x - agent_vel.0, desired_y - agent_vel.1)
}

fn predicted_position(
    entity: &SteeringEntity,
    agent_pos: (f32, f32),
    max_speed: f32,
) -> (f32, f32) {
    let distance = distance_sq(agent_pos, entity.position).sqrt();
    let lookahead = if max_speed > 0.001 {
        (distance / max_speed).min(1.0)
    } else {
        0.0
    };
    (
        entity.position.0 + entity.velocity.0 * lookahead,
        entity.position.1 + entity.velocity.1 * lookahead,
    )
}

fn normalize_to_speed(force: Force, max_speed: f32) -> Force {
    let mag = (force.0 * force.0 + force.1 * force.1).sqrt();
    if mag < 0.001 {
        (0.0, 0.0)
    } else {
        ((force.0 / mag) * max_speed, (force.1 / mag) * max_speed)
    }
}

fn distance_sq(a: (f32, f32), b: (f32, f32)) -> f32 {
    let dx = a.0 - b.0;
    let dy = a.1 - b.1;
    dx * dx + dy * dy
}

fn cell_for(pos: (f32, f32), cell_size: f32) -> (i32, i32) {
    (
        (pos.0 / cell_size).floor() as i32,
        (pos.1 / cell_size).floor() as i32,
    )
}
/// `Default` delegates to `SteeringManager::new`.
impl Default for SteeringManager {
    /// Build a steering manager with the default parameters.
    fn default() -> Self {
        Self::new()
    }
}
