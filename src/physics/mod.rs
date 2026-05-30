//! Platform-level 2D physics module that unifies authored bodies, geometric shapes, simulation stepping, spatial queries, terrain sync, and trigger-style environmental effects.
//! It exposes the major surfaces of the subsystem as one coherent toolbox, from lightweight helper tests through full world simulation and debug-oriented support structures.
//! Functionally this file is the high-level entry point for physical interaction, movement constraints, collision reporting, and physics-backed world state in Lurek2D.

/// Rigid body management and handle types.
pub mod body;
/// Collision query and contact result types.
pub mod collision;
/// AABB, circle, and point-AABB collision helpers.
pub mod collision_helpers;
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
pub use shape::{Shape, StandaloneShape};
pub use terrain::TerrainMap;
pub use world::BodyContact as CollisionEvent;
pub use world::{ContactInfo, PhysicsShapeSnapshot, RaycastHit, World};
pub use zone::{PhysicsZone, ZoneBoundary, ZoneEvent, ZoneEventKind, ZoneGravityMode};
