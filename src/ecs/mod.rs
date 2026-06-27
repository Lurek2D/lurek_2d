//! This module is the ECS index, re-exporting entity ids, world storage, relationships, and Lua table helpers.
//! It is the navigation point for identity packing, query caching, hierarchy state, and component row ownership.
//! `universe.rs` owns live entities, components, tags, layers, blueprints, systems, and directed relation helpers.
//! `relationships.rs` owns typed pair records and named links, while `query_view.rs` caches component-set lookups.
//! `object_model.rs` owns class metadata and object id bookkeeping for Lua-facing ECS objects.
//! `types.rs`, `generational_id.rs`, and `lua_table.rs` provide handles, id packing, and recursive table cloning.
//! Change this file when public ECS exports move; change siblings when storage rules or query semantics change.

/// Entity id packing and unpacking helpers.
pub mod generational_id;
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
pub use lua_table::deep_copy_table;
pub use object_model::{ClassMeta, ObjectModel};
pub use relationships::{RelationType, Relationship, RelationshipManager};
pub use types::EntityId;
pub use universe::{SnapshotDiff, Universe};
