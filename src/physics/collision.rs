//! This file owns `CollisionInfo`, the stable collision payload used when contact results leave solver internals.
//! It stores penetration depth and collision normal so gameplay systems can react without raw engine state.
//! Open this file when exported contact payload fields change; overlap helpers and body simulation live elsewhere.

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
