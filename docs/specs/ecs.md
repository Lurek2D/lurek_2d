# ecs

## TL;DR

- The `ecs` module provides Lurek2D with a highly optimized, Lua-first Entity-Component-System (ECS) runtime.

## General Info

- Module group: `Feature Systems`
- Source path: `src/ecs/`
- Binding: `src/lua_api/ecs_api.rs`
- Namespace: `lurek.ecs`
- Lua API surface: `1` functions, `4` types, `68` methods
- Rust test path(s): tests/rust/unit/ecs_tests.rs
- Lua test path(s): tests/lua/unit/test_ecs_core_unit.lua

## Summary

The `ecs` module provides entity/component storage and relationship primitives centered on generational entity identifiers and Lua-table component data. It is designed for lightweight runtime composition rather than rigid compile-time component schemas.

`universe` owns the primary storage surface (entities, components, tags, blueprints, snapshots), `generational_id` and `types` provide ID contracts, `relationships` handles graph-style links between entities, and `lua_table` provides deep-copy support for snapshot and blueprint workflows. Together these modules support creation, mutation, cloning, and diff-like operations over live ECS state.

The generational-ID approach prevents stale handle reuse while keeping IDs compact and lookup-friendly. Lua table component storage keeps scripting integration direct, with engine-side helpers managing lifecycle consistency.

This module should keep its focus on storage semantics and relationship/state utilities. System scheduling and gameplay policy should remain outside ECS core and consume this state through explicit APIs.

Implementation detail and boundary guarantees for ecs: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: generational_id.rs: Pack and unpack 24-bit slot + 8-bit generation into a single u32 entity id.; lua_table.rs: Deep-copy utility for Lua tables via mlua.; mod.rs: Lightweight ECS: entities with generational IDs, Lua-table components, tags, and blueprints.; relationships.rs: Relationship type definitions with named level labels and validated defaults.; types.rs: Core ECS type aliases and ID newtypes: entity, component slot, and archetype key.; universe.rs: Entity lifecycle: spawn, kill, recursive kill, alive checks, and generational id packing.; universe_ext.rs: Extended Universe operations: advanced queries, bulk spawning, and state serialization.; universe_systems.rs: System registration, removal, and count queries on a Universe.. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

## Imports

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### generational_id.rs

- Provides stateless generational id packing that combines slot and generation into one compact handle.
- Enables cheap decoding of slot and generation fields for validity checks during entity access.
- Delivers the identity encoding contract used by ECS storage and lifecycle reuse rules.

### lua_table.rs

- Provides Lua table deep-copy behavior for ECS operations that require independent state snapshots.
- Recursively clones nested table structures so template and runtime data can diverge safely.
- Delivers a shared cloning primitive used by serialization, blueprints, and diff-friendly workflows.

### mod.rs

- Provides the high-level ECS module boundary for entities, components, relationships, and lifecycle management.
- Connects identity, storage, query, and hierarchy capabilities into one composable runtime data model.
- Delivers a stable integration surface for systems that need structured world state and deterministic access.

### relationships.rs

- Provides typed relationship modeling for unordered pair links and directed named connections between entities.
- Defines relationship categories with constrained level labels and validated default values.
- Stores affinity metrics and per-type state in canonical pair records for stable lookups.
- Supports directed link sets that capture one-way ownership or routing semantics.
- Exposes query and mutation helpers that keep relationship operations centralized and consistent.
- Delivers the graph substrate used by gameplay systems that reason about inter-entity ties.

### types.rs

- Provides core ECS identifier wrappers used to pass entity handles across module boundaries.
- Defines lightweight typed ids that keep call sites explicit while preserving compact storage.
- Delivers a shared identity contract for indexing, mapping, and query-level interoperability.

### universe.rs

- Provides the central ECS Universe storage that owns entity lifecycle, component rows, and indexing state.
- Manages spawn and deletion flows with generational identity to prevent stale-handle reuse errors.
- Stores component payloads in Lua-backed tables while exposing predictable set, get, and remove semantics.
- Maintains tag, layer, and hierarchy structures for efficient grouping and ordered runtime traversal.
- Tracks blueprint templates and mutation helpers so scripted spawning remains data-driven and reusable.
- Coordinates system metadata needed for later scheduling and phase-aware execution ordering.
- Captures snapshot-diff signals so external consumers can observe incremental state changes.
- Supports query acceleration and deterministic iteration patterns for stable gameplay behavior.
- Integrates relationship management to keep inter-entity link semantics adjacent to core storage.
- Provides reset and cleanup behavior that drains stores safely between scenario lifecycles.
- Keeps ECS responsibilities concentrated in one authoritative runtime world-state container.
- Delivers the foundational state layer consumed by simulation, rendering, scripting, and tooling.

### universe_ext.rs

- Provides extended Universe operations for advanced queries, bulk spawning, and table-based state exchange.
- Implements inclusion and exclusion query paths that support richer component-selection workflows.
- Supports callback-oriented multi-component iteration for efficient script-side data access.
- Enables batch entity creation from blueprints with optional per-instance override payloads.
- Serializes and deserializes complete world snapshots including hierarchy and tag structures.
- Delivers high-level utility behavior that augments core ECS storage with practical runtime workflows.

### universe_systems.rs

- Provides Universe system-management behavior for registration, removal, and inspection of runtime systems.
- Computes deterministic execution order using priorities combined with dependency-aware topological sorting.
- Applies phase filtering rules so system selection remains predictable across update and render passes.
- Encapsulates scheduling metadata handling to keep orchestration logic separate from core ECS storage.
- Delivers the execution-order facade used by callers to run systems consistently frame to frame.

## Lua API Ref

### Functions

- `lurek.ecs.newUniverse`: Creates an empty ECS universe for entity, component, system, and relationship management.

### Callbacks

- `LUniverse:each` param `callback` (`function`): Callback invoked by the ECS backend for each matching entity.
- `LUniverse:onComponentAdded` param `cb` (`function`): Callback receiving entity id and component name.
- `LUniverse:onComponentRemoved` param `cb` (`function`): Callback receiving entity id and component name.
- `LUniverse:queryMulti` param `callback` (`function`): Callback invoked by the ECS backend for each matching entity.

### Enums

- No documented module-level enums/constants.

### Types

#### LUniverse Type

- Lua-side handle for one ECS universe.

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
