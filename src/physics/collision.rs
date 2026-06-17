//! Collision event buffering for the moments when physical contact needs to become stable gameplay information instead of transient solver state.

use crate::math::Vec2;

/// Result of a collision detection query.
/// # Fields
/// - `penetration`: overlap depth in world units.
/// - `normal`: collision normal pointing from B toward A.
pub struct CollisionInfo {
    /// Depth of penetration in world units.
    pub penetration: f32,
    /// Collision normal pointing from B toward A.
    pub normal: Vec2,
}
