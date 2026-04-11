# ecs

## General Info

- Module group: `Feature Systems`
- Source path: `src/ecs/`
- Lua API path(s): `src/lua_api/ecs_api.rs`
- Primary Lua namespace: `lurek.ecs`
- Rust test path(s): none found under tests/ with ecs in the path
- Lua test path(s): none found under tests/ with ecs in the path

## Summary

The `ecs` module owns Lurek2D's lightweight entity world and related relationship utilities. Its main job is to create and destroy entities safely, store arbitrary component data in Lua-owned tables, track tags and layers, manage parent-child hierarchies, define blueprints, and dispatch registered systems in a controlled order.

This module exists to give Lua game code a flexible property-bag ECS rather than a rigid Rust archetype ECS. `Universe` handles identity, lifecycle, and indexing concerns while leaving component schemas dynamic. That makes it suitable for script-heavy gameplay code where components and systems evolve quickly and where entity data needs to remain easy to inspect and modify from Lua.

The module intentionally does not own rendering, physics simulation, scene transitions, or specialized gameplay logic. It can store data for those systems and dispatch systems that act on that data, but it does not define how a sprite, collider, or scene should behave. The separate relationship types also do not model gameplay semantics by themselves; they only provide a reusable container for pairwise relation values and named levels.

**Scope boundary**: This module currently depends on `runtime`. It stays within the Feature Systems responsibility boundary defined in the architecture docs.

## Files

- `mod.rs`: Declares the ECS submodules and re-exports the main world and relationship types.
- `relationships.rs`: Defines reusable relationship types and the `RelationshipManager` for symmetric pairwise values and named relation levels.
- `universe.rs`: Defines `Universe`, including generational entity IDs, component storage via Lua registry tables, tags, layers, blueprints, hierarchy management, and ordered system dispatch.

## Types

- `RelationType` (`struct`, `relationships.rs`): The definition of one named relationship category and its allowed level strings.
- `Relationship` (`struct`, `relationships.rs`): The stored record for one normalized entity pair, including a numeric value and per-type named levels.
- `RelationshipManager` (`struct`, `relationships.rs`): A standalone manager for pairwise entity relationships that is separate from `Universe` but often complements ECS-driven gameplay.
- `Universe` (`struct`, `universe.rs`): The main ECS world object that owns entity lifecycle, component storage, tags, layers, blueprints, parent-child links, and registered systems.

## Functions

- `RelationType::new` (`relationships.rs`): Create a new relation type.
- `RelationType::has_level` (`relationships.rs`): Return `true` if `level` is a valid level for this type.
- `RelationshipManager::new` (`relationships.rs`): Create a new empty manager.
- `RelationshipManager::define_type` (`relationships.rs`): Define a named relation type with a set of valid levels.
- `RelationshipManager::remove_type` (`relationships.rs`): Remove a relation type.
- `RelationshipManager::get_type` (`relationships.rs`): Get a reference to a relation type definition.
- `RelationshipManager::type_names` (`relationships.rs`): Get the names of all defined relation types.
- `RelationshipManager::get_value` (`relationships.rs`): Get the numeric relation value between two entities.
- `RelationshipManager::set_value` (`relationships.rs`): Set the numeric relation value between two entities.
- `RelationshipManager::adjust_value` (`relationships.rs`): Adjust the numeric relation value by `delta`.
- `RelationshipManager::set_level` (`relationships.rs`): Set the named level for a relation type between two entities.
- `RelationshipManager::get_level` (`relationships.rs`): Get the level for a relation type between two entities.
- `RelationshipManager::has_relation` (`relationships.rs`): Return `true` if a relationship record exists for this pair.
- `RelationshipManager::remove_relation` (`relationships.rs`): Remove a relationship record.
- `RelationshipManager::all_relations_for` (`relationships.rs`): Get all relationships involving a given entity.
- `RelationshipManager::all_relations` (`relationships.rs`): Get all relationships as an iterator.
- `RelationshipManager::relation_count` (`relationships.rs`): Get the total number of relationship records.
- `Universe::new` (`universe.rs`): Creates a new empty Universe.
- `Universe::get_system_store` (`universe.rs`): get_system_store.
- `Universe::pack_id` (`universe.rs`): Packs a slot and generation counter into a single entity ID.
- `Universe::unpack_slot` (`universe.rs`): Extracts the slot index from a packed entity ID.
- `Universe::unpack_gen` (`universe.rs`): Extracts the generation counter from a packed entity ID.
- `Universe::spawn` (`universe.rs`): Spawns a new entity and returns its ID.
- `Universe::kill` (`universe.rs`): Kills an entity, cleaning up all associated data and recycling the ID.
- `Universe::set_parent` (`universe.rs`): Sets or clears the parent of `entity`.
- `Universe::get_parent` (`universe.rs`): Returns the parent of `entity`, or `None` if unparented.
- `Universe::get_children` (`universe.rs`): Returns the direct children of `entity`.
- `Universe::kill_recursive` (`universe.rs`): Kills `root` and all of its descendants recursively.
- `Universe::is_alive` (`universe.rs`): Returns whether an entity ID is currently alive.
- `Universe::get_entity_count` (`universe.rs`): Returns the number of alive entities.
- `Universe::get_entities` (`universe.rs`): Returns all alive entity IDs (unordered).
- `Universe::set_component` (`universe.rs`): Sets a component value on an entity.
- `Universe::get_component` (`universe.rs`): Gets a component value from an entity (returns Nil if missing or dead).
- `Universe::has_component` (`universe.rs`): Returns whether an entity has a named component.
- `Universe::remove_component` (`universe.rs`): Removes a component from an entity.
- `Universe::get_component_names` (`universe.rs`): Returns all component names for an entity.
- `Universe::query` (`universe.rs`): Returns all alive entities that have ALL listed component names.
- `Universe::each` (`universe.rs`): Calls `callback(id, value)` for every alive entity that has the named component.
- `Universe::add_tag` (`universe.rs`): Adds a string tag to an entity (no-op if already present or entity is dead).
- `Universe::remove_tag` (`universe.rs`): Removes a string tag from an entity.
- `Universe::has_tag` (`universe.rs`): Returns whether an entity has a specific string tag.
- `Universe::get_tags` (`universe.rs`): Returns all string tags for an entity.
- `Universe::get_entities_by_tag` (`universe.rs`): Returns all alive entities that have the given string tag.
- `Universe::define_tag` (`universe.rs`): Defines a bitmap tag name, returning its bit index.
- `Universe::bitmap_tag` (`universe.rs`): Adds a bitmap tag to an entity (auto-defines the tag if needed).
- `Universe::bitmap_untag` (`universe.rs`): Removes a bitmap tag from an entity.
- `Universe::has_bitmap_tag` (`universe.rs`): Returns whether an entity has a specific bitmap tag.
- `Universe::query_bitmap_tag` (`universe.rs`): Returns all alive entities with the given bitmap tag.
- `Universe::query_bitmap_any` (`universe.rs`): Returns all alive entities that have ANY of the listed bitmap tags.
- `Universe::query_bitmap_all` (`universe.rs`): Returns all alive entities that have ALL of the listed bitmap tags.
- `Universe::get_bitmap_tag_bit` (`universe.rs`): Returns the bit index for a bitmap tag name, if defined.
- `Universe::set_layer` (`universe.rs`): Sets the layer for an entity (default layer is 0).
- `Universe::get_layer` (`universe.rs`): Returns the layer for an entity (defaults to 0).
- `Universe::get_entities_by_layer` (`universe.rs`): Returns all alive entities on a specific layer.
- `Universe::get_entities_sorted` (`universe.rs`): Returns all alive entities sorted by layer (ascending), then by ID.
- `Universe::define_blueprint` (`universe.rs`): Defines a blueprint by deep-copying the given component table.
- `Universe::extend_blueprint` (`universe.rs`): Defines a blueprint by extending a parent blueprint with overrides.
- `Universe::spawn_blueprint` (`universe.rs`): Spawns an entity from a blueprint, applying optional overrides.
- `Universe::has_blueprint` (`universe.rs`): Returns whether a blueprint with the given name exists.
- `Universe::remove_blueprint` (`universe.rs`): Removes a blueprint definition.
- `Universe::list_blueprints` (`universe.rs`): Lists all defined blueprint names.
- `Universe::get_blueprint_components` (`universe.rs`): Returns a deep copy of a blueprint's component table, or Nil if not found.
- `Universe::add_system` (`universe.rs`): Adds a system (Lua table) to the system list.
- `Universe::remove_system` (`universe.rs`): Removes a system by pointer identity from the system list.
- `Universe::get_system_count` (`universe.rs`): Returns the number of registered systems.
- `Universe::clear` (`universe.rs`): Clears all entities, components, tags, layers, and systems.
- `deep_copy_table` (`universe.rs`): Deep-copies a Lua table recursively.

## Lua API Reference

- Binding path(s): `src/lua_api/ecs_api.rs`
- Namespace: `lurek.ecs`

### Module Functions
- `lurek.ecs.newUniverse`: Creates a new empty ECS universe.

### `Universe` Methods
- `Universe:spawn`: Creates a new entity and returns its packed ID.
- `Universe:kill`: Destroys the entity with the given ID, freeing its slot for reuse.
- `Universe:isAlive`: Returns true if the entity ID is currently alive.
- `Universe:set`: Sets a component value on an entity.
- `Universe:get`: Returns the component value for an entity, or nil if missing.
- `Universe:has`: Returns true if the entity has the named component.
- `Universe:remove`: Removes a component from an entity.
- `Universe:getComponents`: Returns all component names for an entity.
- `Universe:query`: Returns entity IDs that have all listed component names.
- `Universe:each`: Calls callback(id, value) for every entity with the named component.
- `Universe:getEntities`: Returns all alive entity IDs.
- `Universe:getEntityCount`: Returns the number of alive entities.
- `Universe:addSystem`: Adds a system table to the universe.
- `Universe:removeSystem`: Removes a system table from the universe.
- `Universe:update`: Calls update(system, world, dt) on each registered system.
- `Universe:render`: Calls render(system, world) on each registered system.
- `Universe:emit`: Emits a named event to all systems that implement the handler.
- `Universe:getSystemCount`: Returns the number of registered systems.
- `Universe:clear`: Removes all entities, components, tags, layers, and systems. Blueprints are preserved.
- `Universe:release`: Releases all universe state, equivalent to clear.
- `Universe:addTag`: Attaches a string tag to an entity.
- `Universe:removeTag`: Removes a string tag from an entity.
- `Universe:hasTag`: Returns true if the entity carries the given tag.
- `Universe:getTags`: Returns all string tags for an entity.
- `Universe:getEntitiesByTag`: Returns all alive entities with the given string tag.
- `Universe:setLayer`: Sets the layer for an entity.
- `Universe:getLayer`: Returns the layer for an entity, defaulting to zero.
- `Universe:getEntitiesByLayer`: Returns all alive entities on a specific layer.
- `Universe:getEntitiesSorted`: Returns all alive entities sorted by layer then ID.
- `Universe:defineTag`: Defines a bitmap tag name, returning its bit index.
- `Universe:bitmapTag`: Adds a bitmap tag to an entity.
- `Universe:bitmapUntag`: Removes a bitmap tag from an entity.
- `Universe:hasBitmapTag`: Returns true if the entity has the given bitmap tag.
- `Universe:queryBitmapTag`: Returns all alive entities with the given bitmap tag.
- `Universe:queryBitmapAny`: Returns all alive entities with any of the listed bitmap tags.
- `Universe:queryBitmapAll`: Returns all alive entities with all of the listed bitmap tags.
- `Universe:getBitmapTagBit`: Returns the bit index for a bitmap tag name, or nil if undefined.
- `Universe:hasBlueprint`: Returns true if a blueprint with the given name exists.
- `Universe:removeBlueprint`: Removes a blueprint definition.
- `Universe:listBlueprints`: Returns all defined blueprint names.
- `Universe:getBlueprintComponents`: Returns a deep copy of a blueprint's component table, or nil.
- `Universe:getParent`: Returns the parent entity ID, or nil if unparented.
- `Universe:getChildren`: Returns all direct child entity IDs.
- `Universe:killRecursive`: Kills an entity and all its descendants recursively.

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/ecs/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
