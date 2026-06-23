//! This module re-exports the physics subsystem surface for bodies, shapes, zones, world stepping, and helpers.
//! It keeps navigation explicit by mapping which sibling files own body descriptors, geometry, debug output, or zones.
//! Public exports here route callers toward `World` for simulation and `Body` or `Shape` for authored physics state.
//! `collision.rs` and `collision_helpers.rs` own contact payloads and lightweight overlap checks outside full stepping.
//! `body.rs`, `shape.rs`, and `zone.rs` define the core authored inputs that later feed the runtime world owner.
//! Change this file when the public physics symbol map moves; change siblings when simulation data rules change.

/// Rigid body management and handle types.
pub mod body;
/// Collision query and contact result types.
pub mod collision;
/// AABB, circle, and point-AABB collision helpers.
pub mod collision_helpers;
/// Shared typed physics errors.
pub mod error;
/// Shared sizing and validation limits.
pub mod limits;
/// Debug render helpers for physics shapes.
pub mod render;
/// Shape definitions for bodies and standalone queries.
pub mod shape;
/// Static terrain tile-map. This module is publicly re-exported.
pub mod terrain;
/// Core type definitions for the physics subsystem.
pub mod types;
/// Physics world, stepping, bodies, and raycasting.
pub mod world;

pub use types::BodyId;
/// Spatial trigger zones with gravity and event tracking.
pub mod zone;
pub use body::{Body, BodyShape, BodyType};
pub use collision::CollisionInfo;
pub use collision_helpers::{test_aabb, test_circle_aabb, test_circles, test_point_aabb};
pub use error::PhysicsError;
pub use limits::PhysicsLimits;
pub use shape::{Shape, StandaloneShape};
pub use terrain::TerrainMap;
pub use world::BodyContact as CollisionEvent;
pub use world::{
    ContactInfo, GravityVector, PhysicsQueryFilter, PhysicsShapeSnapshot, PhysicsWorldStats,
    RaycastHit, World,
};
pub use zone::{
    PhysicsZone, ZoneBoundary, ZoneEvent, ZoneEventKind, ZoneGravityFalloff, ZoneGravityMode,
};
