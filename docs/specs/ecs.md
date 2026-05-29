# ecs

## TL;DR

- The `ecs` module provides Lurek2D with a highly optimized, Lua-first Entity-Component-System (ECS) runtime.

## General Info

- Module group: `Feature Systems`
- Source path: `src/ecs/`
- Lua API path(s): `src/lua_api/ecs_api.rs`
- Primary Lua namespace: `lurek.ecs`
- Rust test path(s): tests/rust/unit/ecs_tests.rs
- Lua test path(s): tests/lua/unit/test_ecs_core_unit.lua

## Summary

The `ecs` module provides entity/component storage and relationship primitives centered on generational entity identifiers and Lua-table component data. It is designed for lightweight runtime composition rather than rigid compile-time component schemas.

`universe` owns the primary storage surface (entities, components, tags, blueprints, snapshots), `generational_id` and `types` provide ID contracts, `relationships` handles graph-style links between entities, and `lua_table` provides deep-copy support for snapshot and blueprint workflows. Together these modules support creation, mutation, cloning, and diff-like operations over live ECS state.

The generational-ID approach prevents stale handle reuse while keeping IDs compact and lookup-friendly. Lua table component storage keeps scripting integration direct, with engine-side helpers managing lifecycle consistency.

This module should keep its focus on storage semantics and relationship/state utilities. System scheduling and gameplay policy should remain outside ECS core and consume this state through explicit APIs.

Implementation detail and boundary guarantees for ecs: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: generational_id.rs: Pack and unpack 24-bit slot + 8-bit generation into a single u32 entity id.; lua_table.rs: Deep-copy utility for Lua tables via mlua.; mod.rs: Lightweight ECS: entities with generational IDs, Lua-table components, tags, and blueprints.; relationships.rs: Relationship type definitions with named level labels and validated defaults.; types.rs: Core ECS type aliases and ID newtypes: entity, component slot, and archetype key.; universe.rs: Entity lifecycle: spawn, kill, recursive kill, alive checks, and generational id packing.; universe_ext.rs: Extended Universe operations: advanced queries, bulk spawning, and state serialization.; universe_systems.rs: System registration, removal, and count queries on a Universe.. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

## Files

### generational_id.rs

- Pack and unpack 24-bit slot + 8-bit generation into a single u32 entity id.
- Stateless utility struct with no allocation or state.
- Supports up to ~16M slots and 256 generations per slot.

### lua_table.rs

- Deep-copy utility for Lua tables via mlua.
- Recursively clones nested table structures by value.
- Used by ECS and other systems that need independent table snapshots.

### mod.rs

- Lightweight ECS: entities with generational IDs, Lua-table components, tags, and blueprints.
- Relationship graph for parent/child, ownership, and custom link types between entities.
- Deep-copy and snapshot utilities for cloning Lua component tables.

### relationships.rs

- Relationship type definitions with named level labels and validated defaults.
- Pairwise relationship records storing numeric affinity and per-type level state.
- Canonical entity-pair ordering for symmetric, order-independent lookups.
- Directed named links between entities for one-way associations.
- Query helpers: filter by entity, check existence, iterate all relations.

### types.rs

- Core ECS type aliases and ID newtypes: entity, component slot, and archetype key.
- `EntityId` is a `u32` generation-stamped handle; 0 is the null entity.
- `ComponentSlot` is a dense index into a component storage array.
- `ArchetypeKey` is a sorted bitset of component type IDs identifying a layout.
- All types derive `Copy`, `Eq`, and `Hash` so they can be used as map keys.

### universe.rs

- Entity lifecycle: spawn, kill, recursive kill, alive checks, and generational id packing.
- Component storage: set, get, has, remove, and name-list queries backed by Lua registry tables.
- Archetype-style query acceleration via optional component-name index (`ecs-archetype` feature).
- String tags with reverse index and bitmap tags with 63-bit fast masking.
- Entity hierarchy: parent/child links, recursive deletion, and child enumeration.
- Layer assignment and sorted entity retrieval for render ordering.
- Blueprint templates: define, extend, spawn from template, and list operations.
- System registration metadata: priorities, phases, names, and dependency lists.
- Snapshot diff and dirty tracking for component add/remove notification streams.
- Full universe reset via clear, draining all stores and recycling state.

### universe_ext.rs

- Extended Universe operations: advanced queries, bulk spawning, and state serialization.
- query_not filters entities by required and excluded component sets.
- query_multi invokes a callback with packed ids and multiple component values per entity.
- spawn_bulk creates many entities from a single blueprint with optional per-entity overrides.
- serialize_to_table / deserialize_from_table convert live universe state to and from Lua tables.
- Serialization captures components, tags, layers, bitmap masks, and parent-child hierarchy.

### universe_systems.rs

- System registration, removal, and count queries on a Universe.
- Priority-based and dependency-aware topological sorting of systems per phase.
- Phase filtering with fallback semantics for empty-phase systems.
- Captures functional behavior for universe systems so callers can compose this capability safely.

## Lua API Ref

- Binding: `src/lua_api/ecs_api.rs`
- Namespace: `lurek.ecs`

### Functions

- `lurek.ecs.newUniverse`: Creates an empty ECS universe for entity, component, system, and relationship management.

### Enums

- No documented module-level enums/constants.

### Types


#### LUniverse Type


##### Fields

- No documented fields.

##### Methods

- `LUniverse:addRelation`: Adds a named directed relation from one entity to another.
- `LUniverse:addSystem`: Registers a Lua system table with optional phase, priority, name, and dependency metadata.
- `LUniverse:addTag`: Assigns a string tag name to an entity in this universe.
- `LUniverse:applySnapshot`: Replaces this universe state from a Lua table snapshot.
- `LUniverse:bitmapTag`: Adds a bitmap tag to an entity, defining the tag if needed.
- `LUniverse:bitmapUntag`: Removes a bitmap tag from an entity.
- `LUniverse:clear`: Clears all entities, components, systems, and ECS state from this universe.
- `LUniverse:clearRelations`: Removes every target for one named relation from an entity.
- `LUniverse:defineBlueprint`: Defines a named entity blueprint from a component table.
- `LUniverse:defineTag`: Defines a bitmap tag name and assigns it a bit slot.
- `LUniverse:deserialize`: Replaces this universe state from a serialized Lua snapshot.
- `LUniverse:each`: Iterates entities with one component and calls a Lua callback for each match.
- `LUniverse:emit`: Calls matching event-named functions on registered systems.
- `LUniverse:extendBlueprint`: Defines a blueprint that inherits from a parent blueprint and applies overrides.
- `LUniverse:flushObservers`: Delivers queued component add and remove events to registered observer callbacks.
- `LUniverse:get`: Returns a component value from an entity.
- `LUniverse:getBitmapTagBit`: Returns the bit index assigned to a bitmap tag name.
- `LUniverse:getBlueprintComponents`: Returns the component table stored for a blueprint.
- `LUniverse:getChildren`: Returns child entity ids for a parent entity.
- `LUniverse:getComponents`: Returns component names currently stored on an entity.
- `LUniverse:getDirtyEntities`: Returns entities marked dirty by recent ECS mutations.
- `LUniverse:getEntities`: Returns all live entity ids in this universe.
- `LUniverse:getEntitiesByLayer`: Returns entities assigned to a numeric layer.
- `LUniverse:getEntitiesByTag`: Returns entities that have a string tag.
- `LUniverse:getEntitiesSorted`: Returns live entities sorted by ECS layer and stable entity ordering.
- `LUniverse:getEntityCount`: Returns the number of live entities in this universe.
- `LUniverse:getLayer`: Returns the numeric layer assigned to an entity.
- `LUniverse:getParent`: Returns the parent entity id for a child entity.
- `LUniverse:getRelated`: Returns targets linked from an entity by a named relation.
- `LUniverse:getSystemCount`: Returns the number of registered systems.
- `LUniverse:getTags`: Returns string tags assigned to an entity.
- `LUniverse:has`: Returns whether an entity has a named component.
- `LUniverse:hasBitmapTag`: Returns whether an entity has a bitmap tag.
- `LUniverse:hasBlueprint`: Returns whether a named blueprint exists.
- `LUniverse:hasRelation`: Returns whether a named directed relation exists between two entities.
- `LUniverse:hasTag`: Returns whether an entity has a string tag.
- `LUniverse:isAlive`: Returns whether an entity id currently exists in this universe.
- `LUniverse:kill`: Deletes an entity and removes its components from this universe.
- `LUniverse:killRecursive`: Deletes an entity and all descendant entities in its hierarchy.
- `LUniverse:listBlueprints`: Returns names of all registered blueprints.
- `LUniverse:onComponentAdded`: Registers a callback for queued component-add events with a given component name.
- `LUniverse:onComponentRemoved`: Registers a callback for queued component-remove events with a given component name.
- `LUniverse:query`: Returns entities that have all component names passed as varargs.
- `LUniverse:queryBitmapAll`: Returns entities that have every bitmap tag from a list.
- `LUniverse:queryBitmapAny`: Returns entities with at least one bitmap tag from a list.
- `LUniverse:queryBitmapTag`: Returns entities with one bitmap tag.
- `LUniverse:queryMulti`: Iterates entities that have all component names from a table.
- `LUniverse:queryNot`: Returns entities that include one component set and exclude another component set.
- `LUniverse:release`: Releases universe contents by clearing all ECS state.
- `LUniverse:remove`: Removes a named component from an entity.
- `LUniverse:removeBlueprint`: Removes a named blueprint from this universe.
- `LUniverse:removeRelation`: Removes a named directed relation between two entities.
- `LUniverse:removeSystem`: Removes a previously registered Lua system table.
- `LUniverse:removeTag`: Removes a string tag from an entity.
- `LUniverse:render`: Runs registered render-phase systems using their render or draw callbacks.
- `LUniverse:serialize`: Serializes this universe into a Lua table snapshot.
- `LUniverse:set`: Stores or replaces a component value on an entity.
- `LUniverse:setLayer`: Assigns a numeric layer to an entity.
- `LUniverse:setParent`: Sets or clears the parent entity for a child entity.
- `LUniverse:snapshot`: Serializes this universe into a Lua table snapshot.
- `LUniverse:spawn`: Creates a new entity in this universe.
- `LUniverse:spawnBlueprint`: Spawns an entity from a named blueprint with optional component overrides.
- `LUniverse:spawnBulk`: Spawns multiple entities from a blueprint using shared optional overrides.
- `LUniverse:takeSnapshotDiff`: Returns and clears accumulated ECS snapshot diff data.
- `LUniverse:type`: Returns the Lua-visible type name for this universe handle.
- `LUniverse:typeOf`: Returns whether this universe handle matches a supported type name.
- `LUniverse:update`: Runs registered update-phase systems with a frame delta.
- `LUniverse:updatePhase`: Runs registered systems assigned to a named phase.

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.
