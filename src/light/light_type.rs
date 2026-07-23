//! This file owns `LightType`, the geometric light-kind enum used to distinguish point, directional, and spot lights.
//! It keeps illumination shape explicit inside `Light2D` so worlds and renderers branch on one stable discriminant.
//! Open this file when supported light geometries change; shadow, falloff, and world behavior live in siblings.

/// Discriminant for the geometric illumination model used by a `Light2D`.
/// # Variants
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
