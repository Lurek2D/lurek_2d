//! This file owns shared particle safety ceilings used by strict config parsing and runtime helpers.
//! It centralizes pool, recursion, parser, and render budgets so particle callers share one bounded contract.
//! Open it when particle resource ceilings or validation policy changes.

/// Shared safety limits for particle configs, emitters, and render extraction.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct ParticleLimits {
    /// Maximum direct pool size allowed for one particle system.
    pub max_particles_per_system: u32,
    /// Maximum live particles allowed across one emitter tree during a spawn/update step.
    pub max_total_particles: usize,
    /// Maximum child sub-systems allowed under one emitter at a time.
    pub max_sub_systems: usize,
    /// Maximum child sub-systems allowed to spawn from one update call.
    pub max_sub_systems_per_update: usize,
    /// Maximum inactive child sub-systems retained for reuse.
    pub max_recycled_subsystems: usize,
    /// Maximum nested death-emitter depth allowed from one root emitter.
    pub max_sub_emitter_depth: u8,
    /// Maximum particles emitted by one death burst.
    pub max_death_burst_count: u32,
    /// Maximum raw TOML bytes accepted by strict particle config parsing.
    pub max_toml_bytes: usize,
    /// Maximum keyframes allowed in `sizes`, `colors`, and `alpha_keyframes`.
    pub max_keyframes: usize,
    /// Maximum texture quads allowed for sprite-sheet animation.
    pub max_quads: usize,
    /// Maximum attractors allowed on one particle system.
    pub max_attractors: usize,
    /// Maximum live instances emitted into render commands for one frame.
    pub max_render_instances: usize,
    /// Maximum pool size allowed before slow insert modes fall back to append-only behavior.
    pub max_insert_shift_particles: usize,
}

impl Default for ParticleLimits {
    fn default() -> Self {
        Self {
            max_particles_per_system: 16_384,
            max_total_particles: 65_536,
            max_sub_systems: 256,
            max_sub_systems_per_update: 64,
            max_recycled_subsystems: 128,
            max_sub_emitter_depth: 4,
            max_death_burst_count: 1_024,
            max_toml_bytes: 262_144,
            max_keyframes: 64,
            max_quads: 512,
            max_attractors: 64,
            max_render_instances: 65_536,
            max_insert_shift_particles: 4_096,
        }
    }
}
