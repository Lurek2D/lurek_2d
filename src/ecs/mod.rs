//! Provides the high-level ECS module boundary for entities, components, relationships, and lifecycle management. `ecs/mod` is the ecs module index, declaring `generational_id`, `lua_table`, `relationships`, `types`, `universe` so agents can identify which files own each feature slice before opening implementation code.
//! Connects identity, storage, query, and hierarchy capabilities into one composable runtime data model. `src/ecs/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `generational_id::GenerationalId`, `lua_table::deep_copy_table`, `relationships::{RelationType, Relationship, RelationshipManager}`, `types::EntityId`, and 1 more centralized for the ecs subsystem.

/// Entity id packing and unpacking helpers.
pub mod generational_id;
/// Lua table cloning helpers for ECS snapshots and blueprints.
pub mod lua_table;
/// Internal cached query-view support for ECS component queries.
pub(crate) mod query_view;
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
