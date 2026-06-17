//! Defines radial falloff profiles that shape brightness between light center and radius boundary. `light/falloff` delivers the falloff implementation for the light subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

/// Radial intensity falloff shape applied on top of attenuation distance decay.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum FalloffMode {
    /// Linearly decreases intensity from center to radius boundary (default).
    #[default]
    Linear,
    /// Smooth-step curve: flat near center, steep at the boundary.
    Smooth,
    /// No radial falloff — uniform intensity within the light radius.
    Constant,
}
