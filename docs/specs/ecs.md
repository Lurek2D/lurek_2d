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

- The `ecs` module is the engine's entity-component world model for users who want gameplay state to scale through entities, components, queries, and scheduled systems.
- Its core value is separation of identity from data. Entities provide stable handles, components hold structured state, and systems or queries interpret that state without forcing one rigid object hierarchy.
- Generational handles, dynamic component attachment, tags, layers, and relationships make the model practical for varied world populations such as actors, props, projectiles, and temporary runtime markers.
- Query views and dirty tracking are especially important because downstream systems need efficient access to exactly the slices of world state they care about.
- Blueprints, bulk spawning, snapshots, and serialization broaden the module from live simulation into save/load, rollback, reset, and data-driven population workflows.
- Hierarchy and relationship support matter because game worlds are rarely flat; parent-child links, semantic grouping, and layered ownership all need to remain queryable as the world grows.
- The module also improves feature isolation, because several systems can share the same entities without collapsing their state into one oversized object model.
- That makes the ECS world a stable meeting point for subsystems that need different views of the same population.
- The model is especially strong when many systems need partial views of the same population without inheriting each other's update logic.
- That shared world model keeps those views aligned.
- The ECS world becomes a shared substrate for other systems, but `ecs` owns its organization.
- Read `ecs` as the authority for entity identity, component storage, queries, and shared world composition.

## Imports

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### generational_id.rs

- This file owns stateless packing of entity slot and generation into one compact handle used across ECS.
- `GenerationalId` encodes a 24-bit slot plus 8-bit generation and exposes direct unpack helpers for both parts.
- Open it when entity-id layout changes; typed wrappers, world storage, and queries live in sibling ECS files.

### lua_table.rs

- This file owns recursive Lua table cloning used when ECS snapshots and blueprints must not share nested state.
- `deep_copy_table` preserves keys and non-table values while recursively duplicating child tables by value.
- Open it when Lua-owned ECS copy semantics change; entity storage and queries live in sibling ECS files.

### mod.rs

- This module is the ECS index, re-exporting entity ids, world storage, relationships, and Lua table helpers.
- It is the navigation point for identity packing, query caching, hierarchy state, and component row ownership.
- `universe.rs` owns live entities, components, tags, layers, blueprints, systems, and directed relation helpers.
- `relationships.rs` owns typed pair records and named links, while `query_view.rs` caches component-set lookups.
- `types.rs`, `generational_id.rs`, and `lua_table.rs` provide handles, id packing, and recursive table cloning.
- Change this file when public ECS exports move; change siblings when storage rules or query semantics change.

### query_view.rs

- This file owns `QueryView`, the cached component-set view used by Lua-facing ECS query handles.
- It stores normalized include and exclude names, cached ids, and the universe tick that produced them.
- Refresh logic reuses cached results until `Universe` bumps its coarse query invalidation counter.
- Open it when query-cache behavior changes; world mutations and component matching live in `universe.rs`.

### relationships.rs

- This file owns typed relationship definitions, pair records, and directed named links between entities.
- `RelationType` validates allowed level labels, while `Relationship` stores canonical unordered pair state.
- `RelationshipManager` centralizes type registration, numeric affinity updates, levels, and relation removal.
- Directed link helpers track one-way targets separately from pair records, covering routing or ownership edges.
- Entity-removal cleanup lives here so pair maps and directed link buckets cannot retain stale ids after kills.
- Open it when graph semantics change; the universe owns lifecycle and component rows in sibling ECS files.

### types.rs

- This file owns `EntityId`, the typed wrapper around packed ECS entity handles passed across module boundaries.
- It keeps call sites explicit while preserving cheap copy semantics and direct conversion to and from integers.
- `new`, `raw`, `Display`, and numeric `From` impls make the wrapper usable in maps, logs, and Lua glue code.
- Open it when public entity-handle semantics change; id packing and world storage live in sibling ECS files.

### universe.rs

- This file owns `Universe`, the central ECS world that manages entity lifetime, component rows, and queries.
- It stores live slots, recycled ids, generation counters, and retired slots that prevent stale-handle reuse.
- Component data lives in Lua registry tables, while dirty sets and add or remove events track row mutations.
- Tagging support includes string-tag indexes, bitmap-tag bit assignment, layer values, and sorted retrieval.
- Hierarchy support stores parent and child slot maps, validates cycles, and enables recursive deletions.
- Blueprint support deep-copies template tables, supports extension with overrides, and spawns named entities.
- System support tracks Lua system tables with priorities, phases, names, and dependency lists for scheduling.
- Relationship support delegates directed links and pairwise affinity data while still enforcing entity liveness.
- Query helpers cover exact component sets, cached invalidation ticks, per-component callbacks, and tag scans.
- Snapshot helpers expose component events, dirty entities, deleted ids, and structured diff drains to callers.
- Open it when ECS storage or lifecycle semantics change; extensions and caches depend on this owner file.

### universe_ext.rs

- This file extends `Universe` with higher-level queries, bulk blueprint spawning, and table snapshot exchange.
- `query_not` and `query_multi` build on core component selection for exclusions and callback-based iteration.
- `spawn_bulk` clones optional overrides per entity so repeated blueprint spawns do not share Lua tables.
- Snapshot helpers serialize entities, components, tags, layers, bitmap tags, and hierarchy into Lua tables.
- Deserialization rebuilds live state, stores, indexes, and parent-child links from one captured snapshot.
- Open it when ECS import/export or batch-spawn semantics change; core storage lives in `universe.rs`.

### universe_systems.rs

- This file extends `Universe` with system registration, ordering, removal, and per-phase scheduling helpers.
- It stores metadata in parallel vectors while Lua registry tables keep the actual system objects per world.
- Ordering helpers sort by priority first, then apply dependency-aware topological ordering for named graphs.
- Phase filtering treats empty phases as default update or render participation under current conventions.
- Open it when ECS scheduling semantics change; entity storage and component operations live in `universe.rs`.



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
- `LRelationshipManager:defineType(name, levels, default_level?) -> nil`: Defines a named relationship type with ordered level labels and an optional default level for new pairs.
- `LRelationshipManager:getLevel(a, b, type_name) -> string?`: Returns the effective named level for one relationship type on a pair, falling back to the type default when no explicit level exists.
- `LRelationshipManager:getValue(a, b) -> number`: Returns the numeric relationship value between two entity ids.
- `LRelationshipManager:pairCount() -> integer`: Returns how many entity-id pairs currently have tracked relationship data.
- `LRelationshipManager:removePair(a, b) -> nil`: Removes all tracked relationship data between two entity ids.
- `LRelationshipManager:removeType(name) -> nil`: Removes a named relationship type definition.
- `LRelationshipManager:setLevel(a, b, type_name, level) -> boolean`: Assigns a named level for one relationship type between two entity ids and reports whether the type-level pair was accepted.
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
