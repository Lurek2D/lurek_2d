//! Lightweight ECS: entities with generational IDs, Lua-table components, tags, and blueprints.

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
