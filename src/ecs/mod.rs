//! This module re-exports ecs surface for `generational_id.rs`, `lua_table.rs`, `object_model.rs`, and helpers.
//! It keeps navigation explicit by showing which sibling files own state, validation, transport, or render behavior.
//! Public exports here route callers toward `generational_id.rs`, `lua_table.rs`, and `object_model.rs` first, owners.
//! Open this file when the public ecs symbol map moves; edit siblings when runtime rules themselves change.
//! This index exists to organize entrypoints, not to absorb the state, caches, or algorithms its children own.
//! Use neighboring owners for behavioral fixes, and keep this file limited to exports, docs, and navigation.

/// Entity id packing and unpacking helpers.
pub mod generational_id;
/// Generic modular loadout data for ECS-authored units.
pub mod loadout;
/// Lua table cloning helpers for ECS snapshots and blueprints.
pub mod lua_table;
/// Class metadata and object registry bookkeeping for the ECS object model.
pub mod object_model;
/// Internal cached query-view support for ECS component queries.
pub(crate) mod query_view;
/// Relationship types and graph storage between entities.
pub mod relationships;
/// Type-safe identifiers for ECS entities.
pub mod types;
/// Core ECS storage for entities, components, tags, and blueprints.
pub mod universe;
pub use generational_id::GenerationalId;
pub use loadout::{Loadout, PartDef, SlotDef, StatBlock};
pub use lua_table::deep_copy_table;
pub use object_model::{ClassMeta, ObjectModel};
pub use relationships::{RelationType, Relationship, RelationshipManager};
pub use types::EntityId;
pub use universe::{SnapshotDiff, Universe};
