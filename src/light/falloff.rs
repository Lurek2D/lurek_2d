//! This file owns `FalloffMode`, the enum that shapes radial brightness inside a light's effective radius.
//! It distinguishes linear, smooth, and constant profiles so lights can vary edge softness without new code paths.
//! Open this file when radial falloff semantics change; attenuation math and full light state live in sibling files.

/// Radial intensity falloff shape applied on top of attenuation distance decay.
/// # Variants
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
