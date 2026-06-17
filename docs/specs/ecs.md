# ecs

## TL;DR

- Manages an Entity-Component-System database with generational IDs.
- Supports hierarchies, relationships, phase-aware systems, and snapshots.

## General Info

- Module group: `Feature Systems`
- Source path: `src/ecs/`
- Binding: `src/lua_api/ecs_api.rs`
- Namespace: `lurek.ecs`
- Lua API surface: `2` functions, `6` types, `86` methods
- Rust test path(s): tests/rust/unit/ecs_tests.rs
- Lua test path(s): tests/lua/unit/test_ecs_core_unit.lua

## Summary

- This module gives users a full ECS world model for organizing gameplay state at scale.
- Entities use generational identities, which helps prevent stale-handle bugs after deletion and reuse.
- Components can be attached and queried dynamically, enabling data-driven behavior composition.
- Hierarchy, tags, and layers support practical grouping for rendering, logic, and tooling workflows.
- Relationship support lets systems model directed links and graph-like ownership between entities.
- Standalone relationship-manager handles are owned here through `lurek.ecs.newRelationshipManager()`.
- Query APIs support include/exclude filtering so systems can target the exact data shape they need.
- Cached query-view handles can reuse component-query results until the world query-change tick advances.
- System registration and ordering rules provide deterministic update and render phase execution.
- Dependency-aware scheduling reduces order-related bugs in multi-system simulations.
- Blueprint and bulk-spawn features speed up content-heavy spawning scenarios.
- Snapshot and serialization flows support save/restore, rollback, and sync-style workflows.
- Dirty tracking and observer hooks help downstream systems react to world mutations efficiently.
- For users, the value is one coherent world-state core instead of scattered object tables.
- It scales from simple prototypes to larger simulations with many interacting subsystems.
- The module keeps ECS ergonomics script-friendly while preserving predictable runtime behavior.
- In practice, it enables maintainable gameplay architecture with better queryability and control.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Imports

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### generational_id.rs

- Provides stateless generational id packing that combines slot and generation into one compact handle. `ecs/generational_id` delivers the generational id implementation for the ecs subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

### lua_table.rs

- Provides Lua table deep-copy behavior for ECS operations that require independent state snapshots. `ecs/lua_table` delivers the lua table implementation for the ecs subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

### mod.rs

- Provides the high-level ECS module boundary for entities, components, relationships, and lifecycle management. `ecs/mod` is the ecs module index, declaring `generational_id`, `lua_table`, `relationships`, `types`, `universe` so agents can identify which files own each feature slice before opening implementation code.
- Connects identity, storage, query, and hierarchy capabilities into one composable runtime data model. `src/ecs/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `generational_id::GenerationalId`, `lua_table::deep_copy_table`, `relationships::{RelationType, Relationship, RelationshipManager}`, `types::EntityId`, and 1 more centralized for the ecs subsystem.

### query_view.rs

- Provides cached component-query views that reuse the last result set until the owning universe changes. `ecs/query_view` delivers the query view implementation for the ecs subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Stores normalized include and exclude component lists so repeated view refreshes stay deterministic. The file owns or coordinates data contracts including `QueryView`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Delivers coarse-grained query invalidation keyed off the universe change tick rather than per-call recomputation. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `ids`, `refresh`, `last_change_tick` stays attached to the local data model and invariants.

### relationships.rs

- Provides typed relationship modeling for unordered pair links and directed named connections between entities. `ecs/relationships` delivers the relationships implementation for the ecs subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Defines relationship categories with constrained level labels and validated default values. The file owns or coordinates data contracts including `RelationType`, `Relationship`, `RelationshipManager`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Stores affinity metrics and per-type state in canonical pair records for stable lookups. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `has_level`, `define_type`, `remove_type`, `get_type`, `type_names`, and 16 more stays attached to the local data model and invariants.
- Supports directed link sets that capture one-way ownership or routing semantics. Runtime integration reaches sibling engine areas through crate modules `log_msg`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Exposes query and mutation helpers that keep relationship operations centralized and consistent. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### types.rs

- Provides core ECS identifier wrappers used to pass entity handles across module boundaries. `ecs/types` delivers the shared type definitions and data contracts for the ecs subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Defines lightweight typed ids that keep call sites explicit while preserving compact storage. The file owns or coordinates data contracts including `EntityId`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Delivers a shared identity contract for indexing, mapping, and query-level interoperability. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `raw` stays attached to the local data model and invariants.

### universe.rs

- Provides the central ECS Universe storage that owns entity lifecycle, component rows, and indexing state. `ecs/universe` delivers the universe implementation for the ecs subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Manages spawn and deletion flows with generational identity to prevent stale-handle reuse errors. The file owns or coordinates data contracts including `SnapshotDiff`, `Universe`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Stores component payloads in Lua-backed tables while exposing predictable set, get, and remove semantics. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `get_system_store`, `pack_id`, `unpack_slot`, `unpack_gen`, `get_query_change_tick`, and 51 more stays attached to the local data model and invariants.
- Maintains tag, layer, and hierarchy structures for efficient grouping and ordered runtime traversal. Runtime integration reaches sibling engine areas through crate modules `ecs`, `log_msg`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Tracks blueprint templates and mutation helpers so scripted spawning remains data-driven and reusable. External integration uses `super`, `mlua`, `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Coordinates system metadata needed for later scheduling and phase-aware execution ordering. The file boundary separates ecs implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.
- Captures snapshot-diff signals so external consumers can observe incremental state changes. State changes, validation paths, and helper routines in `src/ecs/universe.rs` should be reviewed together because they collectively define the safe operational surface for this feature.
- Supports query acceleration and deterministic iteration patterns for stable gameplay behavior. Agents reading this file should use the module docs to understand provided functionality first, then inspect item docs and tests only where the behavior is being changed.

### universe_ext.rs

- Provides extended Universe operations for advanced queries, bulk spawning, and table-based state exchange. `ecs/universe_ext` delivers the universe ext implementation for the ecs subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Implements inclusion and exclusion query paths that support richer component-selection workflows. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports callback-oriented multi-component iteration for efficient script-side data access. Public callable behavior is centered on no named public items, while method-level behavior such as `query_not`, `query_multi`, `spawn_bulk`, `serialize_to_table`, `deserialize_from_table` stays attached to the local data model and invariants.
- Enables batch entity creation from blueprints with optional per-instance override payloads. Runtime integration reaches sibling engine areas through crate modules `ecs`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Serializes and deserializes complete world snapshots including hierarchy and tag structures. External integration uses `super`, `mlua`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### universe_systems.rs

- Provides Universe system-management behavior for registration, removal, and inspection of runtime systems. `ecs/universe_systems` delivers the universe systems implementation for the ecs subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Computes deterministic execution order using priorities combined with dependency-aware topological sorting. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Applies phase filtering rules so system selection remains predictable across update and render passes. Public callable behavior is centered on no named public items, while method-level behavior such as `add_system`, `get_sorted_system_indices_all`, `get_sorted_system_indices_for_phase`, `remove_system`, `get_system_count` stays attached to the local data model and invariants.
- Encapsulates scheduling metadata handling to keep orchestration logic separate from core ECS storage. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.



## Lua API Ref

### Functions

- `lurek.ecs.newRelationshipManager() -> LRelationshipManager`: Creates a relationship manager for tracking numeric values and named levels between entity pairs.
- `lurek.ecs.newUniverse() -> LUniverse`: Creates an empty ECS universe for entity, component, system, and relationship management.

### Callbacks

- `LUniverse:each` param `callback` (`function`): Callback invoked by the ECS backend for each matching entity.
- `LUniverse:onComponentAdded` param `cb` (`function`): Callback receiving entity id and component name.
- `LUniverse:onComponentRemoved` param `cb` (`function`): Callback receiving entity id and component name.
- `LUniverse:queryMulti` param `callback` (`function`): Callback invoked by the ECS backend for each matching entity.

### Enums

- No documented module-level enums/constants.

### Types

#### LQueryView Type

- Lua-side cached ECS query view handle owned by one universe.

##### Fields

- No documented fields.

##### Methods

- `LQueryView:ids() -> integer[]`: Returns cached query results, refreshing when the owning universe query tick changed.
- `LQueryView:lastTick() -> integer`: Returns the universe query-change tick used to build the current cached ids.
- `LQueryView:type() -> string`: Returns the Lua-visible type name for this cached query-view handle.
- `LQueryView:typeOf(name) -> boolean`: Returns whether this cached query-view handle matches a supported type name.

#### LRelationshipManager Type

- Lua-side relationship manager handle owned by `lurek.ecs`.

##### Fields

- No documented fields.

##### Methods

- `LRelationshipManager:adjustValue(a, b, delta) -> nil`: Adds a delta to the numeric relationship value between two entity ids.
- `LRelationshipManager:defineType(name, levels, default_level?) -> nil`: Lua-visible method.
- `LRelationshipManager:getLevel(a, b, type_name) -> nil`: Lua-visible method.
- `LRelationshipManager:getValue(a, b) -> number`: Returns the numeric relationship value between two entity ids.
- `LRelationshipManager:pairCount() -> integer`: Returns how many entity-id pairs currently have tracked relationship data.
- `LRelationshipManager:removePair(a, b) -> nil`: Removes all tracked relationship data between two entity ids.
- `LRelationshipManager:removeType(name) -> nil`: Removes a named relationship type definition.
- `LRelationshipManager:setLevel(a, b, type_name, level) -> nil`: Lua-visible method.
- `LRelationshipManager:setValue(a, b, value) -> nil`: Sets the numeric relationship value between two entity ids.
- `LRelationshipManager:type() -> string`: Returns the Lua-visible type name for this relationship manager handle.
- `LRelationshipManager:typeNames() -> string[]`: Returns the defined relationship type names.
- `LRelationshipManager:typeOf(name) -> boolean`: Returns whether this relationship manager handle matches a supported type name.

#### LUniverse Type

- Lua-side handle for one ECS universe.

##### Fields

- No documented fields.

##### Methods

- `LUniverse:addRelation(from, name, to) -> nil`: Adds a named directed relation from one entity to another.
- `LUniverse:addSystem(system, opts?) -> nil`: Registers a Lua system table with optional phase, priority, name, and dependency metadata.
- `LUniverse:addTag(id, tag) -> nil`: Assigns a string tag name to an entity in this universe.
- `LUniverse:applySnapshot(snapshot) -> nil`: Replaces this universe state from a Lua table snapshot.
- `LUniverse:bitmapTag(id, name) -> integer`: Adds a bitmap tag to an entity, defining the tag if needed.
- `LUniverse:bitmapUntag(id, name) -> nil`: Removes a bitmap tag from an entity.
- `LUniverse:clear() -> nil`: Clears all entities, components, systems, and ECS state from this universe.
- `LUniverse:clearRelations(from, name) -> nil`: Removes every target for one named relation from an entity.
- `LUniverse:defineBlueprint(name, components) -> nil`: Defines a named entity blueprint from a component table.
- `LUniverse:defineTag(name) -> integer`: Defines a bitmap tag name and assigns it a bit slot.
- `LUniverse:deserialize(snapshot) -> nil`: Replaces this universe state from a serialized Lua snapshot.
- `LUniverse:each(name, callback) -> nil`: Iterates entities with one component and calls a Lua callback for each match.
- `LUniverse:emit(event, ...) -> nil`: Calls matching event-named functions on registered systems.
- `LUniverse:extendBlueprint(name, parent, overrides) -> nil`: Defines a blueprint that inherits from a parent blueprint and applies overrides.
- `LUniverse:flushObservers() -> nil`: Delivers queued component add and remove events to registered observer callbacks.
- `LUniverse:get(id, name) -> table|number|string|boolean|nil`: Returns a component value from an entity.
- `LUniverse:getBitmapTagBit(name) -> integer`: Returns the bit index assigned to a bitmap tag name.
- `LUniverse:getBlueprintComponents(name) -> table`: Returns the component table stored for a blueprint.
- `LUniverse:getChildren(parent_id) -> integer[]`: Returns child entity ids for a parent entity.
- `LUniverse:getComponents(id) -> string[]`: Returns component names currently stored on an entity.
- `LUniverse:getDirtyEntities() -> integer[]`: Returns entities marked dirty by recent ECS mutations.
- `LUniverse:getEntities() -> integer[]`: Returns all live entity ids in this universe.
- `LUniverse:getEntitiesByLayer(layer) -> integer[]`: Returns entities assigned to a numeric layer.
- `LUniverse:getEntitiesByTag(tag) -> integer[]`: Returns entities that have a string tag.
- `LUniverse:getEntitiesSorted() -> integer[]`: Returns live entities sorted by ECS layer and stable entity ordering.
- `LUniverse:getEntityCount() -> integer`: Returns the number of live entities in this universe.
- `LUniverse:getLayer(id) -> integer`: Returns the numeric layer assigned to an entity.
- `LUniverse:getParent(child_id) -> integer`: Returns the parent entity id for a child entity.
- `LUniverse:getQueryChangeTick() -> integer`: Returns the coarse invalidation tick used by cached ECS query views.
- `LUniverse:getRelated(from, name) -> integer[]`: Returns targets linked from an entity by a named relation.
- `LUniverse:getSystemCount() -> integer`: Returns the number of registered systems.
- `LUniverse:getTags(id) -> string[]`: Returns string tags assigned to an entity.
- `LUniverse:has(id, name) -> boolean`: Returns whether an entity has a named component.
- `LUniverse:hasBitmapTag(id, name) -> boolean`: Returns whether an entity has a bitmap tag.
- `LUniverse:hasBlueprint(name) -> boolean`: Returns whether a named blueprint exists.
- `LUniverse:hasRelation(from, name, to) -> boolean`: Returns whether a named directed relation exists between two entities.
- `LUniverse:hasTag(id, tag) -> boolean`: Returns whether an entity has a string tag.
- `LUniverse:isAlive(id) -> boolean`: Returns whether an entity id currently exists in this universe.
- `LUniverse:kill(id) -> nil`: Deletes an entity and removes its components from this universe.
- `LUniverse:killRecursive(id) -> nil`: Deletes an entity and all descendant entities in its hierarchy.
- `LUniverse:listBlueprints() -> string[]`: Returns names of all registered blueprints.
- `LUniverse:newQueryView(with_table, without_table?) -> LQueryView`: Creates a cached component query view that refreshes only when this universe changes.
- `LUniverse:onComponentAdded(name, cb) -> nil`: Registers a callback for queued component-add events with a given component name.
- `LUniverse:onComponentRemoved(name, cb) -> nil`: Registers a callback for queued component-remove events with a given component name.
- `LUniverse:query(...) -> integer[]`: Returns entities that have all component names passed as varargs.
- `LUniverse:queryBitmapAll(names) -> integer[]`: Returns entities that have every bitmap tag from a list.
- `LUniverse:queryBitmapAny(names) -> integer[]`: Returns entities with at least one bitmap tag from a list.
- `LUniverse:queryBitmapTag(name) -> integer[]`: Returns entities with one bitmap tag.
- `LUniverse:queryMulti(names_table, callback) -> nil`: Iterates entities that have all component names from a table.
- `LUniverse:queryNot(with_tbl, without_tbl) -> integer[]`: Returns entities that include one component set and exclude another component set.
- `LUniverse:release() -> nil`: Releases universe contents by clearing all ECS state.
- `LUniverse:remove(id, name) -> nil`: Removes a named component from an entity.
- `LUniverse:removeBlueprint(name) -> boolean`: Removes a named blueprint from this universe.
- `LUniverse:removeRelation(from, name, to) -> nil`: Removes a named directed relation between two entities.
- `LUniverse:removeSystem(system) -> nil`: Removes a previously registered Lua system table.
- `LUniverse:removeTag(id, tag) -> nil`: Removes a string tag from an entity.
- `LUniverse:render() -> nil`: Runs registered render-phase systems using their render or draw callbacks.
- `LUniverse:serialize() -> table`: Serializes this universe into a Lua table snapshot.
- `LUniverse:set(id, name, value) -> nil`: Stores or replaces a component value on an entity.
- `LUniverse:setLayer(id, layer) -> nil`: Assigns a numeric layer to an entity.
- `LUniverse:setParent(child_id, parent_id?) -> nil`: Sets or clears the parent entity for a child entity.
- `LUniverse:snapshot() -> table`: Serializes this universe into a Lua table snapshot.
- `LUniverse:spawn() -> integer`: Creates a new entity in this universe.
- `LUniverse:spawnBlueprint(name, overrides?) -> integer`: Spawns an entity from a named blueprint with optional component overrides.
- `LUniverse:spawnBulk(name, count, overrides?) -> integer[]`: Spawns multiple entities from a blueprint using shared optional overrides.
- `LUniverse:takeSnapshotDiff() -> table`: Returns and clears accumulated ECS snapshot diff data.
- `LUniverse:type() -> string`: Returns the Lua-visible type name for this universe handle.
- `LUniverse:typeOf(name) -> boolean`: Returns whether this universe handle matches a supported type name.
- `LUniverse:update(dt) -> nil`: Runs registered update-phase systems with a frame delta.
- `LUniverse:updatePhase(phase, dt) -> nil`: Runs registered systems assigned to a named phase.

#### LUniverseSerializeResult Type

- Generated result shape from @field tags.

##### Fields

- `components` (`table`): Map of entity id to component data tables.
- `entities` (`integer[]`): Array of entity ids.

##### Methods

- No documented methods.

#### LUniverseSnapshotResult Type

- Generated result shape from @field tags.

##### Fields

- `added_components` (`table`): Added components.
- `deleted_entities` (`integer[]`): Deleted entity ids.
- `dirty_entities` (`integer[]`): Dirty entity ids.
- `removed_components` (`table`): Removed components.

##### Methods

- No documented methods.

#### LUniverseTakeSnapshotDiffResult Type

- Generated result shape from @field tags.

##### Fields

- `added_components` (`table`): Array of {entity_id, name} tables.
- `deleted_entities` (`integer[]`): Deleted entity ids.
- `dirty_entities` (`integer[]`): Modified entity ids.
- `removed_components` (`table`): Array of {entity_id, name} tables.

##### Methods

- No documented methods.

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- No additional module-specific notes.
