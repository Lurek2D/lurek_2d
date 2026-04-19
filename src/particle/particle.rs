//! Individual particle data structure.

/// A single particle managed by a `ParticleSystem`.
///
/// # Fields
/// - `x` — `f32`.
/// - `y` — `f32`.
/// - `vx` — `f32`.
/// - `vy` — `f32`.
/// - `life` — `f32`.
/// - `max_life` — `f32`.
/// - `rotation` — `f32`.
/// - `spin` — `f32`.
/// - `radial_accel` — `f32`.
/// - `tangential_accel` — `f32`.
/// - `linear_damping` — `f32`.
/// - `size_variation` — `f32`.
/// - `origin_x` — `f32`.
/// - `origin_y` — `f32`.
/// - `shape_seed` — `u32`. Per-particle random seed for deterministic shape generation.
#[derive(Clone, Debug)]
pub struct Particle {
    /// X position relative to emitter origin.
    pub x: f32,
    /// Y position relative to emitter origin.
    pub y: f32,
    /// Velocity X component (pixels / second).
    pub vx: f32,
    /// Velocity Y component (pixels / second).
    pub vy: f32,
    /// Remaining lifetime in seconds.
    pub life: f32,
    /// Total lifetime at spawn (for interpolation ratio).
    pub max_life: f32,
    /// Current rotation in radians.
    pub rotation: f32,
    /// Angular velocity in radians / second.
    pub spin: f32,
    /// Per-particle radial acceleration (pixels / s²).
    pub radial_accel: f32,
    /// Per-particle tangential acceleration (pixels / s²).
    pub tangential_accel: f32,
    /// Per-particle linear damping factor.
    pub linear_damping: f32,
    /// Per-particle size variation factor (0..1).
    pub size_variation: f32,
    /// Birth X offset (for radial direction reference).
    pub origin_x: f32,
    /// Birth Y offset (for radial direction reference).
    pub origin_y: f32,
    /// Per-particle random seed for deterministic shape generation (e.g. `Shrapnel` polygon).
    /// Set once at spawn and never mutated; ensures each particle has a stable polygon across frames.
    pub shape_seed: u32,
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Helper: construct a particle with default test values.
    fn default_particle() -> Particle {
        Particle {
            x: 10.0,
            y: 20.0,
            vx: 1.0,
            vy: -2.0,
            life: 1.5,
            max_life: 3.0,
            rotation: 0.0,
            spin: 0.5,
            radial_accel: 0.0,
            tangential_accel: 0.0,
            linear_damping: 0.0,
            size_variation: 0.0,
            origin_x: 0.0,
            origin_y: 0.0,
            shape_seed: 42,
        }
    }

    #[test]
    fn particle_clone_preserves_fields() {
        let p = default_particle();
        let c = p.clone();
        assert!((c.x - 10.0).abs() < f32::EPSILON);
        assert!((c.vy - (-2.0)).abs() < f32::EPSILON);
        assert_eq!(c.shape_seed, 42);
    }

    #[test]
    fn particle_debug_format_contains_fields() {
        let p = default_particle();
        let dbg = format!("{:?}", p);
        assert!(dbg.contains("Particle"));
        assert!(dbg.contains("shape_seed"));
    }

    #[test]
    fn particle_life_ratio() {
        let p = default_particle();
        let ratio = 1.0 - (p.life / p.max_life);
        assert!((ratio - 0.5).abs() < f32::EPSILON);
    }
}

