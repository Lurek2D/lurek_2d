//! Collision event buffering for the moments when physical contact needs to become stable gameplay information instead of transient solver state.
//! The file packages body pairs, normals, penetration data, and sensor transitions into an ordered queue that can be drained after stepping without disturbing the simulation loop.
//! Functionally this delivers the bridge from raw contact detection to script-consumable collision events with clean step-boundary timing.

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
