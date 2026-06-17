//! Defines geometric light models used by the 2D lighting pipeline. `light/light_type` delivers the light type implementation for the light subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

/// Discriminant for the geometric illumination model used by a `Light2D`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum LightType {
    /// Omnidirectional point light; illuminates equally in all directions (default).
    #[default]
    Point,
    /// Infinite-distance directional light; all rays parallel to `direction`.
    Directional,
    /// Cone-shaped spot light; intensity falls between `inner_angle` and `outer_angle`.
    Spot,
}
