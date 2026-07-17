# ecs manual spec overlay

## TL;DR

- Manages an Entity-Component-System database with generational IDs.
- Supports hierarchies, relationships, phase-aware systems, and snapshots.
- Provides a global Lua class/object registry for richer object-oriented gameplay models when plain tables are not enough.
- Bridges class-backed objects into `LUniverse` entities without replacing component storage or query APIs.
- Accepts transport-neutral ChangeSet tables through `LUniverse:applyChangeSet`, with validated `set`/`replace`/`upsert`, `remove`, and `kill` operations.

## Summary

- The `ecs` module is the engine's entity-component world model for users who want gameplay state to scale through entities, components, queries, and scheduled systems.
- Its core value is separation of identity from data. Entities provide stable handles, components hold structured state, and systems or queries interpret that state without forcing one rigid object hierarchy.
- Generational handles, dynamic component attachment, tags, layers, and relationships make the model practical for varied world populations such as actors, props, projectiles, and temporary runtime markers.
- Query views and dirty tracking are especially important because downstream systems need efficient access to exactly the slices of world state they care about.
- Blueprints, bulk spawning, snapshots, and serialization broaden the module from live simulation into save/load, rollback, reset, and data-driven population workflows.
- Hierarchy and relationship support matter because game worlds are rarely flat; parent-child links, semantic grouping, and layered ownership all need to remain queryable as the world grows.
- The module also improves feature isolation, because several systems can share the same entities without collapsing their state into one oversized object model.
- ChangeSet application is an explicit Lua call and only projects known component/entity operations into this world; it does not auto-connect event, save, network, or gameplay systems.
- That makes the ECS world a stable meeting point for subsystems that need different views of the same population.
- The class/object registry is intentionally part of `ecs` because it is foundational object identity and type metadata, not a reusable gameplay pattern. It gives Lua developers inheritance, mixin-style multi-inheritance, defaults, methods, properties, constructors, tags, and a live object registry inside the same VM.
- Objects created through `lurek.ecs.newObject` remain ordinary Lua tables, but they carry metatable-backed class behavior plus helper methods such as `type`, `typeOf`, `isA`, `getProperty`, and `setProperty`.
- `LUniverse:spawnObject` and `LUniverse:attachObject` are bridge APIs: they attach an object table to an entity as data so ECS systems can still query and compose it with ordinary components.
- The model is especially strong when many systems need partial views of the same population without inheriting each other's update logic.
- That shared world model keeps those views aligned.
- The ECS world becomes a shared substrate for other systems, but `ecs` owns its organization.
- Read `ecs` as the authority for entity identity, component storage, queries, and shared world composition.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
