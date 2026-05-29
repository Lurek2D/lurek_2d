//! Provides the high-level ECS module boundary for entities, components, relationships, and lifecycle management.
//! Connects identity, storage, query, and hierarchy capabilities into one composable runtime data model.
//! Delivers a stable integration surface for systems that need structured world state and deterministic access.

/// Entity id packing and unpacking helpers.
pub mod generational_id;
/// Lua table cloning helpers for ECS snapshots and blueprints.
pub mod lua_table;
/// Relationship types and graph storage between entities.
pub mod relationships;
/// Type-safe identifiers for ECS entities.
pub mod types;
/// Core ECS storage for entities, components, tags, and blueprints.
pub mod universe;
pub use generational_id::GenerationalId;
pub use lua_table::deep_copy_table;
pub use relationships::{RelationType, Relationship, RelationshipManager};
pub use types::EntityId;
pub use universe::{SnapshotDiff, Universe};
