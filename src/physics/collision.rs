//! Collision event queuing and contact processing between physics bodies.
//!
//! - `CollisionQueue` accumulates `ContactEvent`s during `physics::step()`.
//! - Events are drained each Lua tick and delivered as `lurek.physics.on_contact` callbacks.
//! - Contact events carry both body keys, contact normal, and penetration depth.
//! - Sensor events (`ContactEvent::SensorEnter` / `SensorExit`) are routed separately.
//! - The queue is never flushed mid-step; callbacks fire only after step completes.

use crate::math::Vec2;

/// Result of a collision detection query.
pub struct CollisionInfo {
    /// Depth of penetration in world units.
    pub penetration: f32,
    /// Collision normal pointing from B toward A.
    pub normal: Vec2,
}
