//! Defines geometric light models used by the 2D lighting pipeline.
//! Distinguishes point, directional, and spot semantics for illumination behavior.
//! Supplies compact type discriminants used during shading and shadow evaluation.

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
