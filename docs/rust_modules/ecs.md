# ecs

## General Info

- Module group: `Feature Systems`
- Source path: `src/ecs/`
- Binding: `src/lua_api/ecs_api.rs`
- Namespace: `lurek.ecs`
- Lua API surface: `1` functions, `4` types, `68` methods
- Rust test path(s): tests/rust/unit/ecs_tests.rs
- Lua test path(s): tests/lua/unit/test_ecs_core_unit.lua

## Summary

This module provides the Entity-Component-System framework, serving as the central database and simulation coordinator for the game world. It tracks entity lifecycles using generational IDs, which prevent dangling references when slots are reused. Component data is stored in flexible tables, exposing optimized methods to set, query, and remove components dynamically during runtime updates.

To organize the game world, the module supports hierarchical parent-child nesting, layers, and tag-based grouping. Entities can be grouped using fast bitmap tags for low-cost queries, while a relation tracking system maps directed or unordered connections between entities. This allows gameplay systems to reason about structured ownership and network routing directly within the world model.

Data processing is optimized through advanced queries with inclusion and exclusion filters, allowing systems to locate entities efficiently. The module orchestrates systems using a phase-aware scheduler. Systems are registered with custom priorities, and the engine executes them in a topologically sorted order across update and render cycles to guarantee deterministic behaviors.

To support data-driven workflows, the system implements blueprints, bulk-spawning routines, and snapshot serialization. Blueprints act as templates supporting overrides, letting developers instantiate large batches of entities easily. Finally, the snapshot manager captures incremental diffs and serialized states, making it simple to save, restore, or synchronize world states.

## Files

### [generational_id.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ecs/generational_id.rs)

- Provides stateless generational id packing that combines slot and generation into one compact handle.
- Enables cheap decoding of slot and generation fields for validity checks during entity access.
- Delivers the identity encoding contract used by ECS storage and lifecycle reuse rules.

### [lua_table.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ecs/lua_table.rs)

- Provides Lua table deep-copy behavior for ECS operations that require independent state snapshots.
- Recursively clones nested table structures so template and runtime data can diverge safely.
- Delivers a shared cloning primitive used by serialization, blueprints, and diff-friendly workflows.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ecs/mod.rs)

- Provides the high-level ECS module boundary for entities, components, relationships, and lifecycle management.
- Connects identity, storage, query, and hierarchy capabilities into one composable runtime data model.
- Delivers a stable integration surface for systems that need structured world state and deterministic access.

### [relationships.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ecs/relationships.rs)

- Provides typed relationship modeling for unordered pair links and directed named connections between entities.
- Defines relationship categories with constrained level labels and validated default values.
- Stores affinity metrics and per-type state in canonical pair records for stable lookups.
- Supports directed link sets that capture one-way ownership or routing semantics.
- Exposes query and mutation helpers that keep relationship operations centralized and consistent.
- Delivers the graph substrate used by gameplay systems that reason about inter-entity ties.

### [types.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ecs/types.rs)

- Provides core ECS identifier wrappers used to pass entity handles across module boundaries.
- Defines lightweight typed ids that keep call sites explicit while preserving compact storage.
- Delivers a shared identity contract for indexing, mapping, and query-level interoperability.

### [universe.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ecs/universe.rs)

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

### [universe_ext.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ecs/universe_ext.rs)

- Provides extended Universe operations for advanced queries, bulk spawning, and table-based state exchange.
- Implements inclusion and exclusion query paths that support richer component-selection workflows.
- Supports callback-oriented multi-component iteration for efficient script-side data access.
- Enables batch entity creation from blueprints with optional per-instance override payloads.
- Serializes and deserializes complete world snapshots including hierarchy and tag structures.
- Delivers high-level utility behavior that augments core ECS storage with practical runtime workflows.

### [universe_systems.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ecs/universe_systems.rs)

- Provides Universe system-management behavior for registration, removal, and inspection of runtime systems.
- Computes deterministic execution order using priorities combined with dependency-aware topological sorting.
- Applies phase filtering rules so system selection remains predictable across update and render passes.
- Encapsulates scheduling metadata handling to keep orchestration logic separate from core ECS storage.
- Delivers the execution-order facade used by callers to run systems consistently frame to frame.
