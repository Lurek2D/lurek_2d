//! Live particle emitter that owns the active particle pool, physics stepping, and sub-system list.
//! Integrates gravity, drag, orbit, turbulence, and other per-frame forces.
//! Spawns particles continuously or in bursts using fractional accumulation and ordered insertion modes.
//! Applies attractors and axis-aligned bounce boundaries to active particles.
//! Runs child emitters on particle death when sub-systems are configured.
//! Tracks active, paused, and stopped states with lifetime-based auto-stop.
//! Builds render commands from current particle state, shape mapping, and interpolation curves.
//! Supports warm-up simulation so systems can start in a settled state.
//! Exposes custom emission-shape callbacks through the Lua bridge without coupling spawn math to rendering.
//! Provides the runtime core for all particle effects.

use super::config::{
    Attractor, BounceBounds, EmissionShape, EmitterState, InsertMode, ParticleConfig,
};
use super::emission::{emission_offset, emission_shape_offset};
use super::math::{
    interpolate_alphas, interpolate_colors, interpolate_sizes, rand_f32, rand_normal, rand_range,
    rand_u32, rand_usize_inclusive,
};
use super::particle::Particle;
use crate::log_msg;
use crate::particle::shapes::ParticleShape;
use crate::render::renderer::{ParticleInstance, ParticleRenderShape, RenderCommand};
use crate::runtime::log_messages::{PE01, PE02, PE03, PE04};

const MIN_LIFETIME_EPSILON: f32 = 1.0e-4;

/// Snapshot of particle-system runtime state for telemetry and dashboard surfaces.
#[derive(Clone, Debug, PartialEq)]
pub struct ParticleSystemStats {
    /// Live particles in this emitter only.
    pub live_particles: usize,
    /// Total live particles across this emitter and all sub-systems.
    pub total_live_particles: usize,
    /// Configured maximum live particles for the direct emitter.
    pub max_particles: u32,
    /// Active attractor count.
    pub attractor_count: usize,
    /// Active child sub-system count.
    pub sub_system_count: usize,
    /// Current emission rate in particles per second.
    pub emission_rate: f32,
    /// Current emitter age in seconds.
    pub emitter_age: f32,
    /// Number of queued custom-offset callbacks waiting to be applied.
    pub pending_custom_offsets: usize,
    /// Number of queued death records waiting to be consumed.
    pub pending_deaths: usize,
    /// Whether a bounce bounds volume is active.
    pub has_bounds: bool,
    /// Current emitter state.
    pub state: EmitterState,
}
/// Live particle emitter containing the active particle pool, physics state, and sub-system list.
#[derive(Clone, Debug)]
pub struct ParticleSystem {
    /// Configuration snapshot used for spawning and update parameters.
    pub config: ParticleConfig,
    /// Active particle pool.
    pub particles: Vec<Particle>,
    /// World-space X position of this emitter.
    pub emitter_x: f32,
    /// World-space Y position of this emitter.
    pub emitter_y: f32,
    /// Fractional emission accumulator; drives continuous spawning between frames.
    pub emit_accumulator: f32,
    /// Current emitter operating state: active, paused, or stopped.
    pub state: EmitterState,
    /// Total age of the emitter in seconds since last `start`.
    pub emitter_age: f32,
    /// Emitter X position at the previous frame; used for motion interpolation.
    pub prev_emitter_x: f32,
    /// Emitter Y position at the previous frame; used for motion interpolation.
    pub prev_emitter_y: f32,
    /// Active point attractors applied to all particles each frame.
    pub attractors: Vec<Attractor>,
    /// Optional axis-aligned bounce boundary that reflects particles.
    pub bounce_bounds: Option<BounceBounds>,
    /// Child sub-systems spawned on particle death.
    pub sub_systems: Vec<ParticleSystem>,
    /// Reusable child sub-systems retained after death-burst effects finish.
    pub recycled_sub_systems: Vec<ParticleSystem>,
    /// Initial deterministic RNG state used to reset repeatable systems.
    pub rng_initial_state: u64,
    /// Current deterministic RNG state used for emission and per-frame noise.
    pub rng_state: u64,
    /// Particle pool indices waiting for a custom spawn-offset callback.
    pub pending_custom_offsets: Vec<usize>,
    /// `(world_x, world_y, vx, vy)` entries for particles that died this frame.
    pub pending_deaths: Vec<(f32, f32, f32, f32)>,
}
impl ParticleSystem {
    /// Create a new system from `config`; allocates the particle pool upfront.
    pub fn new(config: ParticleConfig) -> Self {
        let config = config.normalized();
        log_msg!(debug, PE01, "max {} particles", config.max_particles);
        let rng_initial_state = config.seed.unwrap_or_else(|| fastrand::u64(..));
        Self {
            particles: Vec::with_capacity(config.max_particles as usize),
            config,
            emitter_x: 0.0,
            emitter_y: 0.0,
            emit_accumulator: 0.0,
            state: EmitterState::Active,
            emitter_age: 0.0,
            prev_emitter_x: 0.0,
            prev_emitter_y: 0.0,
            attractors: Vec::new(),
            bounce_bounds: None,
            sub_systems: Vec::new(),
            recycled_sub_systems: Vec::new(),
            rng_initial_state,
            rng_state: rng_initial_state,
            pending_custom_offsets: Vec::new(),
            pending_deaths: Vec::new(),
        }
    }
    /// Advance all particles by `dt` seconds: integrate physics, retire dead particles, and spawn new ones.
    #[allow(clippy::unnecessary_unwrap)]
    pub fn update(&mut self, dt: f32) {
        if !dt.is_finite() || dt <= 0.0 {
            return;
        }
        if self.state == EmitterState::Paused {
            return;
        }
        if self.state == EmitterState::Active {
            self.emitter_age += dt;
            if self.config.emitter_lifetime >= 0.0
                && self.emitter_age >= self.config.emitter_lifetime
            {
                self.state = EmitterState::Stopped;
            }
        }
        for p in &mut self.particles {
            let dx = p.x - p.origin_x;
            let dy = p.y - p.origin_y;
            let dist = (dx * dx + dy * dy).sqrt();
            if dist > f32::EPSILON {
                let radial_x = dx / dist;
                let radial_y = dy / dist;
                let tangential_x = -radial_y;
                let tangential_y = radial_x;
                p.vx += (radial_x * p.radial_accel + tangential_x * p.tangential_accel) * dt;
                p.vy += (radial_y * p.radial_accel + tangential_y * p.tangential_accel) * dt;
            }
            p.vx += self.config.gravity_x * dt;
            p.vy += self.config.gravity_y * dt;
            if p.linear_damping > f32::EPSILON {
                let damping = 1.0 / (1.0 + p.linear_damping * dt);
                p.vx *= damping;
                p.vy *= damping;
            }
            if self.config.drag > f32::EPSILON {
                let speed = (p.vx * p.vx + p.vy * p.vy).sqrt();
                if speed > f32::EPSILON {
                    let drag_factor = 1.0 / (1.0 + speed * self.config.drag * dt);
                    p.vx *= drag_factor;
                    p.vy *= drag_factor;
                }
            }
            if self.config.orbit_speed.abs() > f32::EPSILON {
                let orbit_angle = self.config.orbit_speed * dt;
                let ca = orbit_angle.cos();
                let sa = orbit_angle.sin();
                let new_vx = p.vx * ca - p.vy * sa;
                let new_vy = p.vx * sa + p.vy * ca;
                p.vx = new_vx;
                p.vy = new_vy;
            }
            if self.config.turbulence > f32::EPSILON {
                p.vx += rand_normal(&mut self.rng_state) * self.config.turbulence * dt;
                p.vy += rand_normal(&mut self.rng_state) * self.config.turbulence * dt;
            }
            let wx = p.x + self.emitter_x;
            let wy = p.y + self.emitter_y;
            for attr in &self.attractors {
                let adx = attr.x - wx;
                let ady = attr.y - wy;
                let dist2 = adx * adx + ady * ady;
                let r2 = attr.radius * attr.radius;
                if dist2 < r2 && dist2 > f32::EPSILON {
                    let dist = dist2.sqrt();
                    let factor = attr.strength * (1.0 - dist / attr.radius) * dt;
                    p.vx += (adx / dist) * factor;
                    p.vy += (ady / dist) * factor;
                }
            }
            p.x += p.vx * dt;
            p.y += p.vy * dt;
            if self.config.relative_rotation {
                p.rotation = p.vy.atan2(p.vx);
            } else {
                p.rotation += p.spin * dt;
            }
            if let Some(ref bb) = self.bounce_bounds {
                let wx = p.x + self.emitter_x;
                let wy = p.y + self.emitter_y;
                let r = bb.restitution.clamp(0.0, 1.0);
                if wx < bb.x_min {
                    p.x = bb.x_min - self.emitter_x;
                    p.vx = p.vx.abs() * r;
                } else if wx > bb.x_max {
                    p.x = bb.x_max - self.emitter_x;
                    p.vx = -p.vx.abs() * r;
                }
                if wy < bb.y_min {
                    p.y = bb.y_min - self.emitter_y;
                    p.vy = p.vy.abs() * r;
                } else if wy > bb.y_max {
                    p.y = bb.y_max - self.emitter_y;
                    p.vy = -p.vy.abs() * r;
                }
            }
            p.life -= dt;
        }
        let death_start = self.pending_deaths.len();
        self.collect_dead_particles();
        if let Some(death_cfg) = self
            .config
            .death_emitter
            .as_ref()
            .filter(|_| self.config.death_burst_count > 0)
        {
            let burst = self.config.death_burst_count;
            for &(dx, dy, _, _) in &self.pending_deaths[death_start..] {
                let mut sub = self
                    .recycled_sub_systems
                    .pop()
                    .unwrap_or_else(|| ParticleSystem::new((**death_cfg).clone()));
                sub.reset_for_reuse((**death_cfg).clone(), dx, dy);
                sub.emit(burst);
                sub.stop();
                self.sub_systems.push(sub);
            }
        }
        let mut sub_index = 0;
        while sub_index < self.sub_systems.len() {
            self.sub_systems[sub_index].update(dt);
            if self.sub_systems[sub_index].is_empty() && !self.sub_systems[sub_index].is_active() {
                let sub = self.sub_systems.swap_remove(sub_index);
                self.recycled_sub_systems.push(sub);
            } else {
                sub_index += 1;
            }
        }
        if self.state == EmitterState::Active {
            self.emit_accumulator += self.config.emission_rate * dt;
            let to_emit = self.emit_accumulator as u32;
            self.emit_accumulator -= to_emit as f32;
            for _ in 0..to_emit {
                if self.particles.len() >= self.config.max_particles as usize {
                    break;
                }
                self.emit_one();
            }
        }
        self.prev_emitter_x = self.emitter_x;
        self.prev_emitter_y = self.emitter_y;
    }
    fn collect_dead_particles(&mut self) {
        let ex = self.emitter_x;
        let ey = self.emitter_y;
        let pending_deaths = &mut self.pending_deaths;
        self.particles.retain(|p| {
            if p.life <= 0.0 {
                pending_deaths.push((ex + p.x, ey + p.y, p.vx, p.vy));
                false
            } else {
                true
            }
        });
    }
    /// Spawn a single particle using the current config; inserts according to `insert_mode`.
    fn emit_one(&mut self) {
        let lifetime = rand_range(
            &mut self.rng_state,
            self.config.lifetime_min,
            self.config.lifetime_max,
        );
        let speed = rand_range(
            &mut self.rng_state,
            self.config.speed_min,
            self.config.speed_max,
        );
        let angle = self.config.direction
            + rand_range(&mut self.rng_state, -self.config.spread, self.config.spread);
        let base_spin = rand_range(
            &mut self.rng_state,
            self.config.spin_min,
            self.config.spin_max,
        );
        let spin = base_spin * (1.0 - self.config.spin_variation * rand_f32(&mut self.rng_state));
        let rotation = rand_range(
            &mut self.rng_state,
            self.config.rotation_min,
            self.config.rotation_max,
        );
        let radial_accel = rand_range(
            &mut self.rng_state,
            self.config.radial_accel_min,
            self.config.radial_accel_max,
        );
        let tangential_accel = rand_range(
            &mut self.rng_state,
            self.config.tangential_accel_min,
            self.config.tangential_accel_max,
        );
        let linear_damping = rand_range(
            &mut self.rng_state,
            self.config.linear_damping_min,
            self.config.linear_damping_max,
        );
        let size_variation = self.config.size_variation * rand_f32(&mut self.rng_state);
        let (offset_x, offset_y) = if self.config.emission_shape != EmissionShape::Point {
            emission_shape_offset(&self.config.emission_shape, &mut self.rng_state)
        } else {
            emission_offset(&self.config, &mut self.rng_state)
        };
        let particle = Particle {
            x: offset_x,
            y: offset_y,
            vx: angle.cos() * speed,
            vy: angle.sin() * speed,
            life: lifetime,
            max_life: lifetime,
            rotation,
            spin,
            radial_accel,
            tangential_accel,
            linear_damping,
            size_variation,
            origin_x: offset_x,
            origin_y: offset_y,
            shape_seed: rand_u32(&mut self.rng_state, 0, u32::MAX),
        };
        let new_idx = match self.config.insert_mode {
            InsertMode::Top => {
                let idx = self.particles.len();
                self.particles.push(particle);
                idx
            }
            InsertMode::Bottom => {
                self.particles.insert(0, particle);
                0
            }
            InsertMode::Random => {
                let idx = if self.particles.is_empty() {
                    0
                } else {
                    rand_usize_inclusive(&mut self.rng_state, self.particles.len())
                };
                self.particles.insert(idx, particle);
                idx
            }
        };
        if matches!(self.config.emission_shape, EmissionShape::Custom { .. }) {
            self.pending_custom_offsets.push(new_idx);
        }
    }
    /// Burst-spawn up to `count` particles immediately, capped by `max_particles`.
    pub fn emit(&mut self, count: u32) {
        for _ in 0..count {
            if self.particles.len() >= self.config.max_particles as usize {
                break;
            }
            self.emit_one();
        }
    }
    /// Return the number of live particles in the pool.
    pub fn count(&self) -> usize {
        self.particles.len()
    }
    /// Clear all particles and reset the accumulator and age.
    pub fn reset(&mut self) {
        log_msg!(debug, PE04);
        self.particles.clear();
        self.emit_accumulator = 0.0;
        self.emitter_age = 0.0;
        self.rng_state = self.rng_initial_state;
        self.attractors.clear();
        self.bounce_bounds = None;
        self.sub_systems.clear();
        self.recycled_sub_systems.clear();
        self.pending_custom_offsets.clear();
        self.pending_deaths.clear();
    }
    /// Transition to `Active` and reset `emitter_age` to zero.
    pub fn start(&mut self) {
        log_msg!(debug, PE02);
        self.state = EmitterState::Active;
        self.emitter_age = 0.0;
    }
    /// Transition to `Stopped`; existing particles continue to live but no new ones are emitted.
    pub fn stop(&mut self) {
        log_msg!(debug, PE03);
        self.state = EmitterState::Stopped;
    }
    /// Transition to `Paused`; update loop stops advancing but particles freeze in place.
    pub fn pause(&mut self) {
        self.state = EmitterState::Paused;
    }
    /// Resume from `Paused` or `Stopped`; transitions to `Active`.
    pub fn resume(&mut self) {
        if self.state == EmitterState::Paused || self.state == EmitterState::Stopped {
            self.state = EmitterState::Active;
        }
    }
    /// Update the emitter's world-space position, recording the previous position for motion blur.
    pub fn move_to(&mut self, x: f32, y: f32) {
        self.prev_emitter_x = self.emitter_x;
        self.prev_emitter_y = self.emitter_y;
        self.emitter_x = x;
        self.emitter_y = y;
    }
    /// Return a new `ParticleSystem` with the same config but no live particles.
    pub fn clone_config(&self) -> ParticleSystem {
        ParticleSystem::new(self.config.clone())
    }
    /// Return `true` when the emitter state is `Active`.
    pub fn is_active(&self) -> bool {
        self.state == EmitterState::Active
    }
    /// Return `true` when the emitter state is `Paused`.
    pub fn is_paused(&self) -> bool {
        self.state == EmitterState::Paused
    }
    /// Return `true` when the emitter state is `Stopped`.
    pub fn is_stopped(&self) -> bool {
        self.state == EmitterState::Stopped
    }
    /// Return `true` when the particle pool is empty.
    pub fn is_empty(&self) -> bool {
        self.particles.is_empty()
    }
    /// Return `true` when the pool has reached `max_particles`.
    pub fn is_full(&self) -> bool {
        self.particles.len() >= self.config.max_particles as usize
    }
    /// Build `RenderCommand` values for all live particles at world offset `(ox, oy)`, including sub-systems.
    pub fn build_render_commands(&self, ox: f32, oy: f32) -> Vec<RenderCommand> {
        let mut all_cmds = Vec::new();
        let mut instances = Vec::with_capacity(self.particles.len());
        for p in &self.particles {
            let t = if p.max_life > MIN_LIFETIME_EPSILON {
                (1.0 - (p.life / p.max_life)).clamp(0.0, 1.0)
            } else {
                1.0
            };
            let size = interpolate_sizes(&self.config.sizes, t, p.size_variation);
            let color_t = if self.config.color_by_speed {
                let speed = (p.vx * p.vx + p.vy * p.vy).sqrt();
                let range = self.config.speed_color_max - self.config.speed_color_min;
                if range > f32::EPSILON {
                    ((speed - self.config.speed_color_min) / range).clamp(0.0, 1.0)
                } else {
                    0.0
                }
            } else {
                t
            };
            let [r, g, b, mut a] = interpolate_colors(&self.config.colors, color_t);
            if !self.config.alpha_keyframes.is_empty() {
                a = interpolate_alphas(&self.config.alpha_keyframes, t);
            }
            let px = ox + self.emitter_x + p.x;
            let py = oy + self.emitter_y + p.y;
            let render_shape = match &self.config.shape {
                ParticleShape::Square => ParticleRenderShape::Square,
                ParticleShape::Circle => ParticleRenderShape::Circle,
                ParticleShape::Triangle => ParticleRenderShape::Triangle,
                ParticleShape::Spark => ParticleRenderShape::Spark,
                ParticleShape::Diamond => ParticleRenderShape::Diamond,
                ParticleShape::Shrapnel { edges } => ParticleRenderShape::Shrapnel {
                    edges: *edges,
                    seed: p.shape_seed,
                },
                ParticleShape::Ray { aspect } => ParticleRenderShape::Ray { aspect: *aspect },
                ParticleShape::Puff => ParticleRenderShape::Puff,
                ParticleShape::Ring { thickness } => ParticleRenderShape::Ring {
                    thickness: *thickness,
                },
                ParticleShape::Capsule => ParticleRenderShape::Capsule,
            };
            let (texture_key, quad, quad_tex_dims) = if let Some(tex_key) = self.config.texture_id {
                if !self.config.quads.is_empty() {
                    let quad_idx = if self.config.animated_frames > 0 {
                        let age = p.max_life - p.life;
                        (age * self.config.frame_rate) as usize
                            % (self.config.animated_frames as usize).min(self.config.quads.len())
                    } else {
                        ((t * self.config.quads.len() as f32) as usize)
                            .min(self.config.quads.len() - 1)
                    };
                    let [qx, qy, qw, qh] = self.config.quads[quad_idx];
                    (Some(tex_key), Some([qx, qy, qw, qh]), Some((qw, qh)))
                } else {
                    (Some(tex_key), None, None)
                }
            } else {
                (None, None, None)
            };
            instances.push(ParticleInstance {
                x: px,
                y: py,
                r,
                g,
                b,
                a,
                rotation: p.rotation,
                size,
                shape: render_shape,
                texture_key,
                quad,
                quad_tex_dims,
            });
        }
        if !instances.is_empty() {
            all_cmds.push(RenderCommand::DrawParticleSystem {
                particles: instances,
            });
        }
        for sub in &self.sub_systems {
            all_cmds.extend(sub.build_render_commands(ox, oy));
        }
        all_cmds
    }
    /// Run the update loop for up to `seconds` in 50 ms steps to pre-populate the particle pool.
    pub fn warm_up(&mut self, seconds: f32) {
        const STEP: f32 = 0.05;
        let clamped = seconds.clamp(0.0, 30.0);
        let mut remaining = clamped;
        while remaining > 0.0 {
            let dt = remaining.min(STEP);
            self.update(dt);
            remaining -= dt;
        }
    }
    /// Add a point attractor at `(x, y)` with given `strength` and influence `radius`.
    pub fn add_attractor(&mut self, x: f32, y: f32, strength: f32, radius: f32) {
        self.attractors.push(Attractor {
            x,
            y,
            strength,
            radius: radius.max(0.0),
        });
    }
    /// Remove all attractors. This function is part of the public API.
    pub fn clear_attractors(&mut self) {
        self.attractors.clear();
    }
    /// Return the number of active attractors.
    pub fn attractor_count(&self) -> usize {
        self.attractors.len()
    }
    /// Set the axis-aligned bounce boundary; particles reflect on crossing any edge.
    pub fn set_bounds(&mut self, x_min: f32, x_max: f32, y_min: f32, y_max: f32, restitution: f32) {
        self.bounce_bounds = Some(BounceBounds {
            x_min: x_min.min(x_max),
            x_max: x_min.max(x_max),
            y_min: y_min.min(y_max),
            y_max: y_min.max(y_max),
            restitution: restitution.clamp(0.0, 1.0),
        });
    }
    /// Sets the direct emitter particle capacity and truncates overflow when shrinking.
    pub fn set_max_particles(&mut self, max_particles: u32) {
        let max_particles = max_particles.max(1);
        self.config.max_particles = max_particles;
        let max_particles_usize = max_particles as usize;
        if self.particles.len() > max_particles_usize {
            self.particles.truncate(max_particles_usize);
        }
        let additional = max_particles_usize.saturating_sub(self.particles.capacity());
        if additional > 0 {
            self.particles.reserve(additional);
        }
    }
    /// Remove the bounce boundary. This function is part of the public API.
    pub fn clear_bounds(&mut self) {
        self.bounce_bounds = None;
    }
    /// Append a child sub-system; returns its index in `sub_systems`.
    pub fn add_sub_system(&mut self, config: ParticleConfig) -> usize {
        let sub = ParticleSystem::new(config);
        self.sub_systems.push(sub);
        self.sub_systems.len() - 1
    }
    /// Return the number of active sub-systems.
    pub fn sub_system_count(&self) -> usize {
        self.sub_systems.len()
    }
    /// Returns a telemetry snapshot of the current emitter state.
    pub fn stats(&self) -> ParticleSystemStats {
        ParticleSystemStats {
            live_particles: self.particles.len(),
            total_live_particles: self.total_live_particles(),
            max_particles: self.config.max_particles,
            attractor_count: self.attractors.len(),
            sub_system_count: self.sub_systems.len(),
            emission_rate: self.config.emission_rate,
            emitter_age: self.emitter_age,
            pending_custom_offsets: self.pending_custom_offsets.len(),
            pending_deaths: self.pending_deaths.len(),
            has_bounds: self.bounce_bounds.is_some(),
            state: self.state.clone(),
        }
    }
    fn reset_for_reuse(&mut self, config: ParticleConfig, emitter_x: f32, emitter_y: f32) {
        let config = config.normalized();
        self.config = config;
        self.particles.clear();
        self.emitter_x = emitter_x;
        self.emitter_y = emitter_y;
        self.emit_accumulator = 0.0;
        self.state = EmitterState::Active;
        self.emitter_age = 0.0;
        self.prev_emitter_x = emitter_x;
        self.prev_emitter_y = emitter_y;
        self.attractors.clear();
        self.bounce_bounds = None;
        self.sub_systems.clear();
        self.recycled_sub_systems.clear();
        self.rng_initial_state = self.config.seed.unwrap_or_else(|| fastrand::u64(..));
        self.rng_state = self.rng_initial_state;
        self.pending_custom_offsets.clear();
        self.pending_deaths.clear();
    }
    fn total_live_particles(&self) -> usize {
        self.particles.len()
            + self
                .sub_systems
                .iter()
                .map(ParticleSystem::total_live_particles)
                .sum::<usize>()
    }
    /// Drain and return all `(world_x, world_y, vx, vy)` death events accumulated since the last call.
    pub fn drain_pending_deaths(&mut self) -> Vec<(f32, f32, f32, f32)> {
        std::mem::take(&mut self.pending_deaths)
    }
    /// Drain and return particle pool indices that need a custom spawn-offset callback applied.
    pub fn drain_custom_offsets(&mut self) -> Vec<usize> {
        std::mem::take(&mut self.pending_custom_offsets)
    }
}
