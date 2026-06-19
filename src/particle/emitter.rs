//! This file owns `ParticleSystem`, the live particle pool plus emitter timers, attractors, bounds, and child sub-systems.
//! It advances particles each frame by applying gravity, damping, orbit, turbulence, attractors, bounce bounds, and decay.
//! Continuous emission and burst spawning live here because fractional accumulation, insert mode, and RNG mutate state.
//! Death handling also lives here, including pending death records, recycled child systems, and death-emitter bursts.
//! Render-instance construction is local because size, color, texture, and shape all derive from live particle state.
//! State transitions for active, paused, and stopped emitters are managed here with warm-up, reset, and movement helpers.
//! Attractor and bounds mutators stay here so callers change runtime forces without reaching into particle internals.
//! `ParticleSystemStats` also lives here because only this file can summarize direct and nested live counts coherently.
//! Open it when pool ownership or per-frame behavior changes; config schema, spawn math, and previews live elsewhere.

use super::config::{
    Attractor, BounceBounds, EmissionShape, EmitterState, InsertMode, ParticleConfig,
    ParticleConfigReport,
};
use super::emission::{emission_offset, emission_shape_offset};
use super::error::ParticleError;
use super::limits::ParticleLimits;
use super::math::{
    interpolate_alphas, interpolate_colors, interpolate_sizes, rand_f32, rand_normal, rand_range,
    rand_u32, rand_usize_inclusive,
};
use super::particle::Particle;
use crate::log_msg;
use crate::particle::shapes::ParticleShape;
use crate::render::renderer::{ParticleInstance, ParticleRenderShape, RenderCommand};
use crate::runtime::log_messages::{PE01, PE02, PE03, PE04};
use std::cell::Cell;

const MIN_LIFETIME_EPSILON: f32 = 1.0e-4;

fn validate_finite_particle_value(field: &'static str, value: f32) -> Result<(), ParticleError> {
    if value.is_finite() {
        Ok(())
    } else {
        Err(ParticleError::InvalidFloat {
            field,
            value: value as f64,
        })
    }
}

fn validate_non_negative_particle_value(
    field: &'static str,
    value: f32,
) -> Result<(), ParticleError> {
    validate_finite_particle_value(field, value)?;
    if value < 0.0 {
        return Err(ParticleError::invalid_config(format!(
            "particle field '{}' must be >= 0, got {}",
            field, value
        )));
    }
    Ok(())
}

fn init_rng_state(seed: Option<u64>) -> (u64, bool) {
    match seed {
        Some(seed) => (seed, true),
        None => (fastrand::u64(..), false),
    }
}

fn valid_quad([qx, qy, qw, qh]: [f32; 4]) -> bool {
    qx.is_finite() && qy.is_finite() && qw.is_finite() && qh.is_finite() && qw > 0.0 && qh > 0.0
}

/// Version tag for the emitter-local particle RNG contract.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum ParticleRngVersion {
    /// Current LCG/Xorshift-derived particle RNG behavior.
    V1,
}

/// Snapshot of particle-system runtime diagnostics.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct ParticleRuntimeDiagnostics {
    /// Strict or validated mutator calls rejected by legacy wrappers.
    pub invalid_operations: u64,
    /// Slow insert modes that fell back to append-only behavior for safety.
    pub slow_insert_count: u64,
    /// Total particle slots shifted by supported `Vec::insert` operations.
    pub insert_shifted_particles: u64,
    /// Child sub-emitters spawned from particle deaths.
    pub spawned_sub_emitters: u64,
    /// Child sub-emitters dropped because a depth or budget limit was hit.
    pub dropped_sub_emitters: u64,
    /// Particle instances emitted into the most recent render-command build.
    pub last_rendered_instances: usize,
    /// Particles skipped during the most recent render-command build.
    pub last_culled_particles: usize,
    /// Particles dropped after exceeding the most recent render budget.
    pub last_dropped_render_instances: usize,
}

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
    /// Inactive child sub-systems retained for reuse.
    pub recycled_sub_system_count: usize,
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
    /// Number of config warnings recorded during permissive normalization.
    pub config_warning_count: usize,
    /// Whether this emitter uses an explicit deterministic seed.
    pub deterministic_seed: bool,
    /// Version of the RNG contract used by this emitter.
    pub rng_version: ParticleRngVersion,
    /// Strict or validated mutator calls rejected by legacy wrappers.
    pub invalid_operations: u64,
    /// Slow insert modes that fell back to append-only behavior.
    pub slow_insert_count: u64,
    /// Total shifted slots caused by supported insert operations.
    pub insert_shifted_particles: u64,
    /// Child sub-emitters spawned from particle deaths.
    pub spawned_sub_emitters: u64,
    /// Child sub-emitters dropped because a depth or budget limit was hit.
    pub dropped_sub_emitters: u64,
    /// Particle instances emitted into the most recent render build.
    pub rendered_instances: usize,
    /// Particles skipped during the most recent render build.
    pub culled_particles: usize,
    /// Particles dropped after exceeding the most recent render budget.
    pub dropped_render_instances: usize,
}

/// Live particle emitter containing the active particle pool, physics state, and sub-system list.
#[derive(Clone, Debug)]
pub struct ParticleSystem {
    /// Configuration snapshot used for spawning and update parameters.
    pub config: ParticleConfig,
    /// Safety ceilings used by strict helpers and bounded legacy operations.
    pub limits: ParticleLimits,
    /// Normalization report captured when the current config was applied.
    pub config_report: ParticleConfigReport,
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
    /// Whether the initial RNG state was provided explicitly by config.
    pub deterministic_seed: bool,
    /// Current depth of this emitter within a death-emitter tree.
    pub generation_depth: u8,
    /// Monotonic particle id source used to stabilize pending callback targets.
    pub next_particle_id: u64,
    /// Particle ids waiting for a custom spawn-offset callback.
    pub pending_custom_offsets: Vec<u64>,
    /// `(world_x, world_y, vx, vy)` entries for particles that died this frame.
    pub pending_deaths: Vec<(f32, f32, f32, f32)>,
    /// Lightweight diagnostics updated during runtime and render extraction.
    pub diagnostics: Cell<ParticleRuntimeDiagnostics>,
}

impl ParticleSystem {
    fn build_permissive(
        config: ParticleConfig,
        limits: ParticleLimits,
        generation_depth: u8,
    ) -> Self {
        let (config, config_report) = config.normalized_with_report_and_limits(&limits);
        log_msg!(debug, PE01, "max {} particles", config.max_particles);
        let (rng_initial_state, deterministic_seed) = init_rng_state(config.seed);
        Self {
            particles: Vec::with_capacity(config.max_particles as usize),
            config,
            limits,
            config_report,
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
            deterministic_seed,
            generation_depth,
            next_particle_id: 1,
            pending_custom_offsets: Vec::new(),
            pending_deaths: Vec::new(),
            diagnostics: Cell::new(ParticleRuntimeDiagnostics::default()),
        }
    }

    fn apply_checked_max_particles(&mut self, max_particles: u32) {
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

    fn note_invalid_operation(&self) {
        let mut diagnostics = self.diagnostics.get();
        diagnostics.invalid_operations += 1;
        self.diagnostics.set(diagnostics);
    }

    fn note_insert_shift(&self, shifted: usize) {
        let mut diagnostics = self.diagnostics.get();
        diagnostics.insert_shifted_particles += shifted as u64;
        self.diagnostics.set(diagnostics);
    }

    fn note_slow_insert_fallback(&self) {
        let mut diagnostics = self.diagnostics.get();
        diagnostics.slow_insert_count += 1;
        self.diagnostics.set(diagnostics);
    }

    fn recycle_child_system(&mut self, sub: ParticleSystem) {
        if self.recycled_sub_systems.len() < self.limits.max_recycled_subsystems {
            self.recycled_sub_systems.push(sub);
        }
    }

    fn append_render_commands(
        &self,
        all_cmds: &mut Vec<RenderCommand>,
        ox: f32,
        oy: f32,
        rendered_instances: &mut usize,
        culled_particles: &mut usize,
        dropped_render_instances: &mut usize,
    ) {
        let mut instances = Vec::with_capacity(self.particles.len());
        for p in &self.particles {
            if *rendered_instances >= self.limits.max_render_instances {
                *dropped_render_instances += 1;
                continue;
            }
            let t = if p.max_life > MIN_LIFETIME_EPSILON {
                (1.0 - (p.life / p.max_life)).clamp(0.0, 1.0)
            } else {
                1.0
            };
            let size = interpolate_sizes(&self.config.sizes, t, p.size_variation);
            if !size.is_finite() || size <= 0.0 {
                *culled_particles += 1;
                continue;
            }
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
            if !px.is_finite()
                || !py.is_finite()
                || !r.is_finite()
                || !g.is_finite()
                || !b.is_finite()
                || !a.is_finite()
                || a <= 0.0
            {
                *culled_particles += 1;
                continue;
            }
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
                    let quad = self.config.quads[quad_idx];
                    if valid_quad(quad) {
                        let [_, _, qw, qh] = quad;
                        (Some(tex_key), Some(quad), Some((qw, qh)))
                    } else {
                        *culled_particles += 1;
                        (None, None, None)
                    }
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
            *rendered_instances += 1;
        }
        if !instances.is_empty() {
            all_cmds.push(RenderCommand::DrawParticleSystem {
                particles: instances,
            });
        }
        for sub in &self.sub_systems {
            sub.append_render_commands(
                all_cmds,
                ox,
                oy,
                rendered_instances,
                culled_particles,
                dropped_render_instances,
            );
        }
    }

    fn reset_for_reuse(
        &mut self,
        config: ParticleConfig,
        emitter_x: f32,
        emitter_y: f32,
        generation_depth: u8,
    ) {
        let (config, config_report) = config.normalized_with_report_and_limits(&self.limits);
        self.config = config;
        self.config_report = config_report;
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
        let (rng_initial_state, deterministic_seed) = init_rng_state(self.config.seed);
        self.rng_initial_state = rng_initial_state;
        self.rng_state = rng_initial_state;
        self.deterministic_seed = deterministic_seed;
        self.generation_depth = generation_depth;
        self.next_particle_id = 1;
        self.pending_custom_offsets.clear();
        self.pending_deaths.clear();
        self.diagnostics.set(ParticleRuntimeDiagnostics::default());
    }

    /// Create a new system from `config`; allocates the particle pool upfront using default safety limits.
    pub fn new(config: ParticleConfig) -> Self {
        Self::build_permissive(config, ParticleLimits::default(), 0)
    }

    /// Create a new seeded system with otherwise default config values.
    pub fn seeded(seed: u64) -> Self {
        Self::new(ParticleConfig {
            seed: Some(seed),
            ..ParticleConfig::default()
        })
    }

    /// Strictly create a new particle system using explicit safety limits.
    pub fn try_new(config: ParticleConfig, limits: &ParticleLimits) -> Result<Self, ParticleError> {
        let (config, config_report) = config.try_normalized_with_limits(limits)?;
        log_msg!(debug, PE01, "max {} particles", config.max_particles);
        let (rng_initial_state, deterministic_seed) = init_rng_state(config.seed);
        Ok(Self {
            particles: Vec::with_capacity(config.max_particles as usize),
            config,
            limits: *limits,
            config_report,
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
            deterministic_seed,
            generation_depth: 0,
            next_particle_id: 1,
            pending_custom_offsets: Vec::new(),
            pending_deaths: Vec::new(),
            diagnostics: Cell::new(ParticleRuntimeDiagnostics::default()),
        })
    }

    /// Return the current emitter RNG state.
    pub fn get_rng_state(&self) -> u64 {
        self.rng_state
    }

    /// Overwrite the current emitter RNG state.
    pub fn set_rng_state(&mut self, rng_state: u64) {
        self.rng_state = rng_state;
    }

    /// Return the version tag for this emitter's deterministic RNG contract.
    pub fn rng_version(&self) -> ParticleRngVersion {
        ParticleRngVersion::V1
    }

    /// Return the config normalization report captured for the current config.
    pub fn config_report(&self) -> &ParticleConfigReport {
        &self.config_report
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
            .clone()
            .filter(|_| self.config.death_burst_count > 0)
        {
            let death_events: Vec<(f32, f32, f32, f32)> =
                self.pending_deaths[death_start..].to_vec();
            let mut diagnostics = self.diagnostics.get();
            let mut spawned_this_update = 0usize;
            let next_generation_depth = self.generation_depth.saturating_add(1);
            for (dx, dy, _, _) in death_events {
                if next_generation_depth > self.limits.max_sub_emitter_depth {
                    diagnostics.dropped_sub_emitters += 1;
                    continue;
                }
                if spawned_this_update >= self.limits.max_sub_systems_per_update
                    || self.sub_systems.len() >= self.limits.max_sub_systems
                {
                    diagnostics.dropped_sub_emitters += 1;
                    continue;
                }
                let remaining_budget = self
                    .limits
                    .max_total_particles
                    .saturating_sub(self.total_live_particles());
                if remaining_budget == 0 {
                    diagnostics.dropped_sub_emitters += 1;
                    continue;
                }
                let emit_count = self
                    .config
                    .death_burst_count
                    .min(remaining_budget.min(u32::MAX as usize) as u32);
                if emit_count == 0 {
                    diagnostics.dropped_sub_emitters += 1;
                    continue;
                }
                let mut sub = self.recycled_sub_systems.pop().unwrap_or_else(|| {
                    ParticleSystem::build_permissive(
                        (*death_cfg).clone(),
                        self.limits,
                        next_generation_depth,
                    )
                });
                sub.reset_for_reuse((*death_cfg).clone(), dx, dy, next_generation_depth);
                sub.emit(emit_count);
                sub.stop();
                self.sub_systems.push(sub);
                spawned_this_update += 1;
                diagnostics.spawned_sub_emitters += 1;
            }
            self.diagnostics.set(diagnostics);
        }
        let mut sub_index = 0;
        while sub_index < self.sub_systems.len() {
            self.sub_systems[sub_index].update(dt);
            if self.sub_systems[sub_index].is_empty() && !self.sub_systems[sub_index].is_active() {
                let sub = self.sub_systems.swap_remove(sub_index);
                self.recycle_child_system(sub);
            } else {
                sub_index += 1;
            }
        }
        if self.state == EmitterState::Active {
            self.emit_accumulator += self.config.emission_rate * dt;
            let to_emit = self.emit_accumulator as u32;
            self.emit_accumulator -= to_emit as f32;
            for _ in 0..to_emit {
                if self.particles.len() >= self.config.max_particles as usize
                    || self.total_live_particles() >= self.limits.max_total_particles
                {
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
        let particle_id = self.next_particle_id;
        self.next_particle_id = self.next_particle_id.wrapping_add(1);
        let particle = Particle {
            id: particle_id,
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
        let len_before = self.particles.len();
        match self.config.insert_mode {
            InsertMode::Top => {
                self.particles.push(particle);
            }
            InsertMode::Bottom => {
                if len_before >= self.limits.max_insert_shift_particles {
                    self.note_slow_insert_fallback();
                    self.particles.push(particle);
                } else {
                    self.note_insert_shift(len_before);
                    self.particles.insert(0, particle);
                }
            }
            InsertMode::Random => {
                if len_before >= self.limits.max_insert_shift_particles {
                    self.note_slow_insert_fallback();
                    self.particles.push(particle);
                } else {
                    let idx = if self.particles.is_empty() {
                        0
                    } else {
                        rand_usize_inclusive(&mut self.rng_state, self.particles.len())
                    };
                    self.note_insert_shift(len_before.saturating_sub(idx));
                    self.particles.insert(idx, particle);
                }
            }
        };
        if matches!(self.config.emission_shape, EmissionShape::Custom { .. }) {
            self.pending_custom_offsets.push(particle_id);
        }
    }

    /// Burst-spawn up to `count` particles immediately, capped by `max_particles`.
    pub fn emit(&mut self, count: u32) {
        for _ in 0..count {
            if self.particles.len() >= self.config.max_particles as usize
                || self.total_live_particles() >= self.limits.max_total_particles
            {
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
        self.next_particle_id = 1;
        self.diagnostics.set(ParticleRuntimeDiagnostics::default());
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

    /// Return a new `ParticleSystem` with the same config and limits but no live particles.
    pub fn clone_config(&self) -> ParticleSystem {
        ParticleSystem::build_permissive(self.config.clone(), self.limits, self.generation_depth)
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
        let mut all_cmds = Vec::with_capacity(self.sub_systems.len() + 1);
        let mut rendered_instances = 0usize;
        let mut culled_particles = 0usize;
        let mut dropped_render_instances = 0usize;
        self.append_render_commands(
            &mut all_cmds,
            ox,
            oy,
            &mut rendered_instances,
            &mut culled_particles,
            &mut dropped_render_instances,
        );
        let mut diagnostics = self.diagnostics.get();
        diagnostics.last_rendered_instances = rendered_instances;
        diagnostics.last_culled_particles = culled_particles;
        diagnostics.last_dropped_render_instances = dropped_render_instances;
        self.diagnostics.set(diagnostics);
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
        if self.try_add_attractor(x, y, strength, radius).is_err() {
            self.note_invalid_operation();
        }
    }

    /// Strictly add a point attractor after validating finite coordinates and attractor limits.
    pub fn try_add_attractor(
        &mut self,
        x: f32,
        y: f32,
        strength: f32,
        radius: f32,
    ) -> Result<(), ParticleError> {
        validate_finite_particle_value("attractor.x", x)?;
        validate_finite_particle_value("attractor.y", y)?;
        validate_finite_particle_value("attractor.strength", strength)?;
        validate_non_negative_particle_value("attractor.radius", radius)?;
        if self.attractors.len() >= self.limits.max_attractors {
            return Err(ParticleError::CountLimitExceeded {
                context: "particle attractors",
                count: self.attractors.len() + 1,
                max: self.limits.max_attractors,
            });
        }
        self.attractors.push(Attractor {
            x,
            y,
            strength,
            radius,
        });
        Ok(())
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
        if self
            .try_set_bounds(x_min, x_max, y_min, y_max, restitution)
            .is_err()
        {
            self.note_invalid_operation();
        }
    }

    /// Strictly set the axis-aligned bounce boundary after validating finite coordinates.
    pub fn try_set_bounds(
        &mut self,
        x_min: f32,
        x_max: f32,
        y_min: f32,
        y_max: f32,
        restitution: f32,
    ) -> Result<(), ParticleError> {
        validate_finite_particle_value("bounds.x_min", x_min)?;
        validate_finite_particle_value("bounds.x_max", x_max)?;
        validate_finite_particle_value("bounds.y_min", y_min)?;
        validate_finite_particle_value("bounds.y_max", y_max)?;
        validate_non_negative_particle_value("bounds.restitution", restitution)?;
        self.bounce_bounds = Some(BounceBounds {
            x_min: x_min.min(x_max),
            x_max: x_min.max(x_max),
            y_min: y_min.min(y_max),
            y_max: y_min.max(y_max),
            restitution: restitution.clamp(0.0, 1.0),
        });
        Ok(())
    }

    /// Sets the direct emitter particle capacity and truncates overflow when shrinking.
    pub fn set_max_particles(&mut self, max_particles: u32) {
        let requested = max_particles;
        let max_particles = max_particles
            .max(1)
            .min(self.limits.max_particles_per_system);
        if requested != max_particles {
            self.note_invalid_operation();
        }
        self.apply_checked_max_particles(max_particles);
    }

    /// Strictly set the direct emitter particle capacity using explicit safety limits.
    pub fn set_max_particles_checked(&mut self, max_particles: u32) -> Result<(), ParticleError> {
        if max_particles == 0 {
            return Err(ParticleError::invalid_config(
                "particle max_particles must be > 0",
            ));
        }
        if max_particles > self.limits.max_particles_per_system {
            return Err(ParticleError::CountLimitExceeded {
                context: "particle max_particles",
                count: max_particles as usize,
                max: self.limits.max_particles_per_system as usize,
            });
        }
        self.apply_checked_max_particles(max_particles);
        Ok(())
    }

    /// Remove the bounce boundary. This function is part of the public API.
    pub fn clear_bounds(&mut self) {
        self.bounce_bounds = None;
    }

    /// Append a child sub-system; returns its index in `sub_systems`.
    pub fn add_sub_system(&mut self, config: ParticleConfig) -> usize {
        let mut sub = ParticleSystem::build_permissive(
            config,
            self.limits,
            self.generation_depth.saturating_add(1),
        );
        sub.generation_depth = self.generation_depth.saturating_add(1);
        self.sub_systems.push(sub);
        self.sub_systems.len() - 1
    }

    /// Return the number of active sub-systems.
    pub fn sub_system_count(&self) -> usize {
        self.sub_systems.len()
    }

    /// Returns a telemetry snapshot of the current emitter state.
    pub fn stats(&self) -> ParticleSystemStats {
        let diagnostics = self.diagnostics.get();
        ParticleSystemStats {
            live_particles: self.particles.len(),
            total_live_particles: self.total_live_particles(),
            max_particles: self.config.max_particles,
            attractor_count: self.attractors.len(),
            sub_system_count: self.sub_systems.len(),
            recycled_sub_system_count: self.recycled_sub_systems.len(),
            emission_rate: self.config.emission_rate,
            emitter_age: self.emitter_age,
            pending_custom_offsets: self.pending_custom_offsets.len(),
            pending_deaths: self.pending_deaths.len(),
            has_bounds: self.bounce_bounds.is_some(),
            state: self.state.clone(),
            config_warning_count: self.config_report.warnings.len(),
            deterministic_seed: self.deterministic_seed,
            rng_version: self.rng_version(),
            invalid_operations: diagnostics.invalid_operations,
            slow_insert_count: diagnostics.slow_insert_count,
            insert_shifted_particles: diagnostics.insert_shifted_particles,
            spawned_sub_emitters: diagnostics.spawned_sub_emitters,
            dropped_sub_emitters: diagnostics.dropped_sub_emitters,
            rendered_instances: diagnostics.last_rendered_instances,
            culled_particles: diagnostics.last_culled_particles,
            dropped_render_instances: diagnostics.last_dropped_render_instances,
        }
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

    /// Drain and return particle ids that need a custom spawn-offset callback applied.
    pub fn drain_custom_offsets(&mut self) -> Vec<u64> {
        std::mem::take(&mut self.pending_custom_offsets)
    }

    /// Apply a custom offset callback result to the particle with the given stable id.
    pub fn apply_custom_offset(&mut self, particle_id: u64, x: f32, y: f32) -> bool {
        if let Some(particle) = self
            .particles
            .iter_mut()
            .find(|particle| particle.id == particle_id)
        {
            particle.x = x;
            particle.y = y;
            particle.origin_x = x;
            particle.origin_y = y;
            true
        } else {
            false
        }
    }
}
