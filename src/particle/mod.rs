//! This module is the particle index, wiring emitter state, config contracts, spawn math, rendering, trails, and presets.
//! It reexports `ParticleSystem`, `ParticleConfig`, shapes, trails, interpolation helpers, and the core `Particle` record.
//! `emitter.rs` owns live pool updates, `config.rs` owns tunables, and `render.rs` bridges particle state to commands.
//! `emission.rs`, `math.rs`, and `shapes.rs` provide reusable spawn and interpolation primitives shared across emitters.
//! `trail.rs`, `visualization.rs`, and `physics_collision.rs` cover ribbons, debug images, and world bounce integration.
//! This file owns visibility and navigation only; simulation rules and data ownership stay in sibling implementation files.

/// Particle emitter configuration: shape, rate, lifetime, and per-particle property ranges.
pub mod config;
/// Emission strategy: burst, continuous, and lifetime-gated emission logic.
pub mod emission;
/// `ParticleSystem` - the main emitter update loop and particle pool manager.
pub mod emitter;
/// Typed particle validation and runtime safety errors.
pub mod error;
/// Shared particle limits for strict constructors and bounded runtime helpers.
pub mod limits;
/// Math helpers: linear interpolation, colour/size/alpha keyframe evaluation.
pub mod math;
#[allow(clippy::module_inception)]
/// `Particle` - per-particle state: position, velocity, life, colour, and size.
pub mod particle;
/// Physics-driven collision response for particles against rapier colliders.
pub mod physics_collision;
/// Named preset constructors returning ready-to-use `ParticleConfig` values.
pub mod presets;
/// Translates particle state into `RenderCommand` streams for the renderer.
pub mod render;
/// Spawn-shape geometry helpers: circle, rect, cone, and point distributions.
pub mod shapes;
/// Particle trail system: `Trail` manager and `TrailPoint` ribbon segments.
pub mod trail;
/// Debug/editor visualisation overlays for emitter bounds and particle vectors.
pub mod visualization;

pub use config::{
    AreaDistribution, EmissionShape, EmitterState, InsertMode, ParticleConfig,
    ParticleConfigReport, ParticleConfigWarning, RelativeMode,
};
pub use emitter::{ParticleRngVersion, ParticleSystem};
pub use error::ParticleError;
pub use limits::ParticleLimits;
pub use math::{interpolate_alphas, interpolate_colors, interpolate_sizes, lerp};
pub use particle::Particle;
pub use shapes::ParticleShape;
pub use trail::{Trail, TrailPoint};
