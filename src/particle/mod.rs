//! Particle emitter lifecycle for spawn, simulation, and pooled recycling. `particle/mod` is the particle module index, declaring `config`, `emission`, `emitter`, `math`, `particle`, and 6 more so agents can identify which files own each feature slice before opening implementation code.
//! Collects emission, physics, trail, rendering, and preset helpers under one namespace. `src/particle/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `config::{ AreaDistribution, EmissionShape, EmitterState, InsertMode, ParticleConfig, RelativeMode, }`, `emitter::ParticleSystem`, `math::{interpolate_alphas, interpolate_colors, interpolate_sizes, lerp}`, `particle::Particle`, and 2 more centralized for the particle subsystem.
//! Keeps particle effects modular while exposing a single runtime surface. The file documents how particle submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
//! `particle/mod` is the particle module index, declaring `config`, `emission`, `emitter`, `math`, `particle`, and 6 more so agents can identify which files own each feature slice before opening implementation code.
//! `src/particle/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `config::{ AreaDistribution, EmissionShape, EmitterState, InsertMode, ParticleConfig, RelativeMode, }`, `emitter::ParticleSystem`, `math::{interpolate_alphas, interpolate_colors, interpolate_sizes, lerp}`, `particle::Particle`, and 2 more centralized for the particle subsystem.
//! The file documents how particle submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.

/// Particle emitter configuration: shape, rate, lifetime, and per-particle property ranges.
pub mod config;
/// Emission strategy: burst, continuous, and lifetime-gated emission logic.
pub mod emission;
/// `ParticleSystem` — the main emitter update loop and particle pool manager.
pub mod emitter;
/// Math helpers: linear interpolation, colour/size/alpha keyframe evaluation.
pub mod math;
#[allow(clippy::module_inception)]
/// `Particle` — per-particle state: position, velocity, life, colour, and size.
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
    AreaDistribution, EmissionShape, EmitterState, InsertMode, ParticleConfig, RelativeMode,
};
pub use emitter::ParticleSystem;
pub use math::{interpolate_alphas, interpolate_colors, interpolate_sizes, lerp};
pub use particle::Particle;
pub use shapes::ParticleShape;
pub use trail::{Trail, TrailPoint};
