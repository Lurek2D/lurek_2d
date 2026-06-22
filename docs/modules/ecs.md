# Ecs

## Purpose

Manages an Entity-Component-System database with generational IDs.

## When To Use

- Its core value is separation of identity from data. Entities provide stable handles, components hold structured state, and systems or queries interpret that state without forcing one rigid object hierarchy.
- Generational handles, dynamic component attachment, tags, layers, and relationships make the model practical for varied world populations such as actors, props, projectiles, and temporary runtime markers.
- Query views and dirty tracking are especially important because downstream systems need efficient access to exactly the slices of world state they care about.

## Minimal Example

From the `lurek.ecs.newUniverse` example block:

```lua
do
    local uni = lurek.ecs.newUniverse()
    local hero = uni:spawn()
    uni:set(hero, "name", "hero")
    local entities = uni:getEntities()
    local count = uni:getEntityCount()
    ecs_log("universe created count=" .. tostring(count) .. " first_id=" .. tostring(entities[1]) .. " hero_name=" .. tostring(uni:get(hero, "name")))
end
```

## Common Patterns

- Start with `lurek.ecs.newRelationshipManager` when exploring this module.
- Start with `lurek.ecs.newUniverse` when exploring this module.

## API Reference

- Full generated API reference: [docs/api/lurek.md](../api/lurek.md)
- Runnable example owner: `content/examples/ecs.lua`

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

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.ecs.newRelationshipManager`

Creates a relationship manager for tracking numeric values and named levels between entity pairs.

```lua
lurek.ecs.newRelationshipManager()
```

**Returns**

| Type | Description |
|------|-------------|
| [LRelationshipManager](#lrelationshipmanager) | New relationship manager handle owned by `lurek.ecs`. |

**Example**

```lua
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:defineType("stance", {"hostile", "neutral", "friendly"}, "neutral")
    rm:setLevel(1, 2, "stance", "friendly")
    rm:setValue(1, 2, 25)
    local level = rm:getLevel(1, 2, "stance")
    local score = rm:getValue(1, 2)
    ecs_log("relationship manager level=" .. tostring(level) .. " score=" .. tostring(score) .. " pairs=" .. tostring(rm:pairCount()))
end
```

---

### `lurek.ecs.newUniverse`

Creates an empty ECS universe for entity, component, system, and relationship management.

```lua
lurek.ecs.newUniverse()
```

**Returns**

| Type | Description |
|------|-------------|
| [LUniverse](#luniverse) | New universe handle. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local hero = uni:spawn()
    uni:set(hero, "name", "hero")
    local entities = uni:getEntities()
    local count = uni:getEntityCount()
    ecs_log("universe created count=" .. tostring(count) .. " first_id=" .. tostring(entities[1]) .. " hero_name=" .. tostring(uni:get(hero, "name")))
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## Types

- [LQueryView](#lqueryview)
- [LRelationshipManager](#lrelationshipmanager)
- [LUniverse](#luniverse)

## LQueryView

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LQueryView:ids`

Returns cached query results, refreshing when the owning universe query tick changed.

```lua
LQueryView:ids()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of matching entity ids. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "pos", {x = 3, y = 4})
    local view = uni:newQueryView({"pos"})
    example_print_log("cached ids = " .. #view:ids())
end
```

---

#### `LQueryView:lastTick`

Returns the universe query-change tick used to build the current cached ids.

```lua
LQueryView:lastTick()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Query-change tick for the cached result set. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "pos", {x = 3, y = 4})
    local view = uni:newQueryView({"pos"})
    example_print_log("view tick = " .. tostring(view:lastTick()))
end
```

---

#### `LQueryView:type`

Returns the Lua-visible type name for this cached query-view handle.

```lua
LQueryView:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LQueryView](#lqueryview)`. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "pos", {x = 3, y = 4})
    local view = uni:newQueryView({"pos"})
    example_print_log("query view type = " .. view:type())
end
```

---

#### `LQueryView:typeOf`

Returns whether this cached query-view handle matches a supported type name.

```lua
LQueryView:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LQueryView](#lqueryview)` and `LObject`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "pos", {x = 3, y = 4})
    local view = uni:newQueryView({"pos"})
    example_print_log("is query view = " .. tostring(view:typeOf("LQueryView")))
end
```

---

## LRelationshipManager

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LRelationshipManager:adjustValue`

Adds a delta to the numeric relationship value between two entity ids.

```lua
LRelationshipManager:adjustValue(a, b, delta)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | Source entity id. |
| `b` | number | Target entity id. |
| `delta` | number | Signed amount added to the current pair value. |

**Example**

```lua
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:setValue(1, 2, 50)
    rm:adjustValue(1, 2, 10)
    example_print_log("1->2 = " .. rm:getValue(1, 2))
    example_print_log("pairs = " .. rm:pairCount())
end
```

---

#### `LRelationshipManager:defineType`

Defines a named relationship type with ordered level labels and an optional default level for new pairs.

```lua
LRelationshipManager:defineType(name, levels, default_level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Relationship type name used for later `setLevel` and `getLevel` calls. |
| `levels` | string[] | Array table of allowed level labels in their semantic order. |
| `default_level?` | string | Optional fallback level assigned when a pair has no explicit level for this type. |

**Example**

```lua
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
    rm:defineType("trust", {"low", "medium", "high"}, "medium")
    local types = rm:typeNames()
    local first = types[1]
    local second = types[2]
    ecs_log("defined relationship types count=" .. tostring(#types) .. " first=" .. tostring(first) .. " second=" .. tostring(second))
end
```

---

#### `LRelationshipManager:getLevel`

Returns the effective named level for one relationship type on a pair, falling back to the type default when no explicit level exists.

```lua
LRelationshipManager:getLevel(a, b, type_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | Source entity id for the relationship pair. |
| `b` | number | Target entity id for the relationship pair. |
| `type_name` | string | Registered relationship type name to query. |

**Returns**

| Type | Description |
|------|-------------|
| string | Stored level label or the type default when available, otherwise `nil` if the type is unknown. |

**Example**

```lua
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
    rm:setLevel(1, 2, "friendship", "friendly")
    example_print_log("level = " .. tostring(rm:getLevel(1, 2, "friendship")))
    example_print_log("types = " .. #rm:typeNames())
end
```

---

#### `LRelationshipManager:getValue`

Returns the numeric relationship value between two entity ids.

```lua
LRelationshipManager:getValue(a, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | Source entity id. |
| `b` | number | Target entity id. |

**Returns**

| Type | Description |
|------|-------------|
| number | Numeric value stored for the pair, or zero when unset. |

**Example**

```lua
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:setValue(1, 2, 50)
    rm:setValue(1, 3, -20)
    example_print_log("1->2 = " .. rm:getValue(1, 2))
    example_print_log("1->3 = " .. rm:getValue(1, 3))
end
```

---

#### `LRelationshipManager:pairCount`

Returns how many entity-id pairs currently have tracked relationship data.

```lua
LRelationshipManager:pairCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Count of stored relationship pairs. |

**Example**

```lua
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
    rm:setLevel(1, 2, "friendship", "friendly")
    rm:setLevel(1, 3, "friendship", "hostile")
    example_print_log("pairs = " .. rm:pairCount())
    example_print_log("level = " .. tostring(rm:getLevel(1, 2, "friendship")))
end
```

---

#### `LRelationshipManager:removePair`

Removes all tracked relationship data between two entity ids.

```lua
LRelationshipManager:removePair(a, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | Source entity id. |
| `b` | number | Target entity id. |

**Example**

```lua
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
    rm:setLevel(1, 2, "friendship", "friendly")
    rm:setLevel(1, 3, "friendship", "hostile")
    example_print_log("before = " .. rm:pairCount())
    rm:removePair(1, 3)
    example_print_log("after = " .. rm:pairCount())
end
```

---

#### `LRelationshipManager:removeType`

Removes a named relationship type definition.

```lua
LRelationshipManager:removeType(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Relationship type name to delete. |

**Example**

```lua
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
    rm:defineType("trust", {"low", "medium", "high"}, "medium")
    example_print_log("before = " .. #rm:typeNames())
    rm:removeType("friendship")
    example_print_log("after = " .. #rm:typeNames())
end
```

---

#### `LRelationshipManager:setLevel`

Assigns a named level for one relationship type between two entity ids and reports whether the type-level pair was accepted.

```lua
LRelationshipManager:setLevel(a, b, type_name, level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | Source entity id for the relationship pair. |
| `b` | number | Target entity id for the relationship pair. |
| `type_name` | string | Registered relationship type name to mutate. |
| `level` | string | Level label to store for the given type on this entity pair. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the type exists and the supplied level is valid for that type. |

**Example**

```lua
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
    rm:setLevel(1, 2, "friendship", "friendly")
    example_print_log("level = " .. tostring(rm:getLevel(1, 2, "friendship")))
    example_print_log("pairs = " .. rm:pairCount())
end
```

---

#### `LRelationshipManager:setValue`

Sets the numeric relationship value between two entity ids.

```lua
LRelationshipManager:setValue(a, b, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | Source entity id. |
| `b` | number | Target entity id. |
| `value` | number | Numeric value stored for the pair. |

**Example**

```lua
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:setValue(1, 2, 50)
    rm:setValue(1, 3, -20)
    example_print_log("1->2 = " .. rm:getValue(1, 2))
    example_print_log("1->3 = " .. rm:getValue(1, 3))
end
```

---

#### `LRelationshipManager:type`

Returns the Lua-visible type name for this relationship manager handle.

```lua
LRelationshipManager:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LRelationshipManager](#lrelationshipmanager)`. |

**Example**

```lua
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:defineType("trust", {"low", "medium", "high"}, "medium")
    local type_name = rm:type()
    local is_rm = rm:typeOf("LRelationshipManager")
    local type_count = #rm:typeNames()
    ecs_log("relationship manager type=" .. tostring(type_name) .. " is_rm=" .. tostring(is_rm) .. " type_count=" .. tostring(type_count))
end
```

---

#### `LRelationshipManager:typeNames`

Returns the defined relationship type names.

```lua
LRelationshipManager:typeNames()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Array table of registered relationship type names. |

**Example**

```lua
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
    rm:defineType("trust", {"low", "medium", "high"}, "medium")
    local types = rm:typeNames()
    example_print_log("types = " .. #types)
    example_print_log("first = " .. tostring(types[1]))
end
```

---

#### `LRelationshipManager:typeOf`

Returns whether this relationship manager handle matches a supported type name.

```lua
LRelationshipManager:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LRelationshipManager](#lrelationshipmanager)` and `LObject`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:defineType("stance", {"hostile", "neutral", "friendly"}, "neutral")
    local is_relationship_manager = rm:typeOf("LRelationshipManager")
    local is_object = rm:typeOf("LObject")
    local is_universe = rm:typeOf("LUniverse")
    ecs_log("relationship manager type guard rm=" .. tostring(is_relationship_manager) .. " object=" .. tostring(is_object) .. " universe=" .. tostring(is_universe))
end
```

---

## LUniverse

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LUniverse:addRelation`

Adds a named directed relation from one entity to another.

```lua
LUniverse:addRelation(from, name, to)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from` | number | Source entity id. |
| `name` | string | Relation name. |
| `to` | number | Target entity id. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    local b = uni:spawn()
    uni:addRelation(a, "likes", b)
    example_print_log("relation added")
end
```

---

#### `LUniverse:addSystem`

Registers a Lua system table with optional phase, priority, name, and dependency metadata.

```lua
LUniverse:addSystem(system, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `system` | table | System table containing update, render, draw, or event methods. |
| `opts?` | table | Optional table with priority, phase, name, and after fields. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local sys = { update = function(self, universe, dt) universe:emit("on_tick", dt) end }
    uni:addSystem(sys, {name = "movement", priority = 1})
    uni:addSystem({ render = function() end }, {name = "draw", priority = 2})
    local count = uni:getSystemCount()
    uni:update(1 / 60)
    ecs_log("systems registered count=" .. tostring(count) .. " query_tick=" .. tostring(uni:getQueryChangeTick()))
end
```

---

#### `LUniverse:addTag`

Assigns a string tag name to an entity in this universe.

```lua
LUniverse:addTag(id, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Entity id to tag. |
| `tag` | string | Tag name to add. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:addTag(e, "enemy")
    example_print_log(u:hasTag(e, "enemy"))
end
```

---

#### `LUniverse:applySnapshot`

Replaces this universe state from a Lua table snapshot.

```lua
LUniverse:applySnapshot(snapshot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `snapshot` | table | Snapshot table previously produced by `snapshot` or `serialize`. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:set(e, "pos", { x = 1, y = 2 })
    local snap = u:snapshot()
    u:clear()
    u:applySnapshot(snap)
    example_print_log("entities after apply = " .. u:getEntityCount())
end
```

---

#### `LUniverse:bitmapTag`

Adds a bitmap tag to an entity, defining the tag if needed.

```lua
LUniverse:bitmapTag(id, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Entity id to tag. |
| `name` | string | Bitmap tag name. |

**Returns**

| Type | Description |
|------|-------------|
| number | Bit index used by the bitmap tag. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    example_print_log(u:hasBitmapTag(e, "enemy"))
end
```

---

#### `LUniverse:bitmapUntag`

Removes a bitmap tag from an entity.

```lua
LUniverse:bitmapUntag(id, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Entity id to update. |
| `name` | string | Bitmap tag name to remove. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    u:bitmapUntag(e, "enemy")
    example_print_log(u:hasBitmapTag(e, "enemy"))
end
```

---

#### `LUniverse:clear`

Clears all entities, components, systems, and ECS state from this universe.

```lua
LUniverse:clear()
```

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    local entity = u:spawn()
    u:set(entity, "hp", 10)
    local before = u:getEntityCount()
    u:clear()
    local after = u:getEntityCount()
    local alive = u:isAlive(entity)
    ecs_log("clear world before=" .. tostring(before) .. " after=" .. tostring(after) .. " old_entity_alive=" .. tostring(alive))
end
```

---

#### `LUniverse:clearRelations`

Removes every target for one named relation from an entity.

```lua
LUniverse:clearRelations(from, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from` | number | Source entity id. |
| `name` | string | Relation name to clear. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    local b = uni:spawn()
    uni:addRelation(a, "sees", b)
    uni:clearRelations(a, "sees")
    local targets = uni:getRelated(a, "sees")
    example_print_log("after clear = " .. #targets)
end
```

---

#### `LUniverse:defineBlueprint`

Defines a named entity blueprint from a component table.

```lua
LUniverse:defineBlueprint(name, components)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Blueprint name. |
| `components` | table | Component table copied when the blueprint is spawned. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("enemy", {pos = {x = 0, y = 0}, hp = {value = 50}, tag = {value = "hostile"}})
    local comps = uni:getBlueprintComponents("enemy")
    local spawned = uni:spawnBlueprint("enemy")
    local hp = uni:get(spawned, "hp")
    ecs_log("blueprint enemy defined hp=" .. tostring(comps.hp.value) .. " spawned=" .. tostring(spawned) .. " live_hp=" .. tostring(hp.value))
end
```

---

#### `LUniverse:defineTag`

Defines a bitmap tag name and assigns it a bit slot.

```lua
LUniverse:defineTag(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Bitmap tag name to define. |

**Returns**

| Type | Description |
|------|-------------|
| number | Bit index assigned to the tag. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:addTag(e, "enemy")
    example_print_log(u:hasTag(e, "enemy"))
end
```

---

#### `LUniverse:deserialize`

Replaces this universe state from a serialized Lua snapshot.

```lua
LUniverse:deserialize(snapshot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `snapshot` | table | Snapshot table previously produced by `serialize` or `snapshot`. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "score", {value = 99})
    uni:deserialize(uni:serialize())
    example_print_log("deserialized, count = " .. uni:getEntityCount())
end
```

---

#### `LUniverse:each`

Iterates entities with one component and calls a Lua callback for each match.

```lua
LUniverse:each(name, callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Component name used to select entities. |
| `callback` | function | Callback invoked by the ECS backend for each matching entity. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "name", {value = "hero"})
    local count = 0
    uni:each("name", function(entity_id, name_value)
        count = count + 1
        example_print_log("visited entity = " .. tostring(entity_id))
        example_print_log("name.value = " .. tostring(name_value.value))
    end)
    example_print_log("each count = " .. count)
end
```

---

#### `LUniverse:emit`

Calls matching event-named functions on registered systems.

```lua
LUniverse:emit(event, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `event` | string | Function name looked up on each system table. |
| — | — | @param ... any Extra values forwarded after the system and universe arguments. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local got = false
    uni:addSystem({on_damage = function() got = true end})
    uni:emit("on_damage")
    example_print_log("emit received = " .. tostring(got))
end
```

---

#### `LUniverse:extendBlueprint`

Defines a blueprint that inherits from a parent blueprint and applies overrides.

```lua
LUniverse:extendBlueprint(name, parent, overrides)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Child blueprint name to define. |
| `parent` | string | Existing parent blueprint name. |
| `overrides` | table | Component overrides applied over the parent definition. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineBlueprint("base", { hp = 100 })
    u:extendBlueprint("enemy", "base", { damage = 10 })
    local id = u:spawnBlueprint("enemy")
    local hp = u:get(id, "hp")
    local damage = u:get(id, "damage")
    ecs_log("extended blueprint exists=" .. tostring(u:hasBlueprint("enemy")) .. " hp=" .. tostring(hp) .. " damage=" .. tostring(damage))
end
```

---

#### `LUniverse:flushObservers`

Delivers queued component add and remove events to registered observer callbacks.

```lua
LUniverse:flushObservers()
```

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local fired = 0
    uni:onComponentAdded("hp", function() fired = fired + 1 end)
    local id = uni:spawn()
    uni:set(id, "hp", {value = 100})
    uni:flushObservers()
    ecs_log("observers flushed fired=" .. tostring(fired) .. " entity=" .. tostring(id) .. " dirty=" .. tostring(#uni:getDirtyEntities()))
end
```

---

#### `LUniverse:get`

Returns a component value from an entity.

```lua
LUniverse:get(id, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Entity id to read. |
| `name` | string | Component name to read. |

**Returns**

| Type | Description |
|------|-------------|
| table | number|string|boolean|nil | Stored component value, or nil when the entity does not have that component. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "hp", {value = 100})
    local hp = uni:get(id, "hp")
    example_print_log("hp.value = " .. tostring(hp.value))
end
```

---

#### `LUniverse:getBitmapTagBit`

Returns the bit index assigned to a bitmap tag name.

```lua
LUniverse:getBitmapTagBit(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Bitmap tag name to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| number | Bit index when the tag exists, or nil when the tag is undefined. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    local bit = u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    local queried_bit = u:getBitmapTagBit("enemy")
    local has_tag = u:hasBitmapTag(e, "enemy")
    ecs_log("bitmap tag bit defined=" .. tostring(bit) .. " queried=" .. tostring(queried_bit) .. " has_tag=" .. tostring(has_tag))
end
```

---

#### `LUniverse:getBlueprintComponents`

Returns the component table stored for a blueprint.

```lua
LUniverse:getBlueprintComponents(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Blueprint name to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| table | Blueprint component table. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("item", {name = {value = "sword"}, damage = {value = 10}})
    local comps = uni:getBlueprintComponents("item")
    example_print_log("blueprint comps type = " .. type(comps))
    example_print_log("damage = " .. tostring(comps.damage.value))
end
```

---

#### `LUniverse:getChildren`

Returns child entity ids for a parent entity.

```lua
LUniverse:getChildren(parent_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `parent_id` | number | Parent entity id to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of child entity ids. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local parent = uni:spawn()
    local c1 = uni:spawn()
    local c2 = uni:spawn()
    uni:setParent(c1, parent)
    uni:setParent(c2, parent)
    local children = uni:getChildren(parent)
    example_print_log("children = " .. #children)
end
```

---

#### `LUniverse:getComponents`

Returns component names currently stored on an entity.

```lua
LUniverse:getComponents(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Entity id to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| string[] | Component name strings. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "pos", {x = 0, y = 0})
    uni:set(id, "vel", {x = 1, y = 0})
    local names = uni:getComponents(id)
    example_print_log("components = " .. #names)
end
```

---

#### `LUniverse:getDirtyEntities`

Returns entities marked dirty by recent ECS mutations.

```lua
LUniverse:getDirtyEntities()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of dirty entity ids. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "x", {value = 1})
    local dirty = uni:getDirtyEntities()
    example_print_log("dirty = " .. #dirty)
end
```

---

#### `LUniverse:getEntities`

Returns all live entity ids in this universe.

```lua
LUniverse:getEntities()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of live entity ids. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    uni:spawn()
    uni:spawn()
    local all = uni:getEntities()
    example_print_log("entities = " .. #all)
end
```

---

#### `LUniverse:getEntitiesByLayer`

Returns entities assigned to a numeric layer.

```lua
LUniverse:getEntitiesByLayer(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer value used for lookup. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of matching entity ids. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    local low = u:spawn()
    local high = u:spawn()
    u:setLayer(low, 2)
    u:setLayer(high, 5)
    local ids = u:getEntitiesByLayer(2)
    local sorted = u:getEntitiesSorted()
    ecs_log("entities by layer count=" .. tostring(#ids) .. " first_layer_two=" .. tostring(ids[1]) .. " sorted_first=" .. tostring(sorted[1]))
end
```

---

#### `LUniverse:getEntitiesByTag`

Returns entities that have a string tag.

```lua
LUniverse:getEntitiesByTag(tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tag` | string | Tag name used for lookup. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of matching entity ids. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("unit")
    local e = u:spawn()
    u:addTag(e, "unit")
    example_print_log(#u:getEntitiesByTag("unit"))
end
```

---

#### `LUniverse:getEntitiesSorted`

Returns live entities sorted by ECS layer and stable entity ordering.

```lua
LUniverse:getEntitiesSorted()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of sorted entity ids. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    local high = u:spawn()
    local low = u:spawn()
    u:setLayer(high, 5)
    u:setLayer(low, 1)
    local sorted = u:getEntitiesSorted()
    local first = sorted[1]
    local second = sorted[2]
    ecs_log("sorted entities count=" .. tostring(#sorted) .. " first=" .. tostring(first) .. " second=" .. tostring(second))
end
```

---

#### `LUniverse:getEntityCount`

Returns the number of live entities in this universe.

```lua
LUniverse:getEntityCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Live entity count. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    uni:spawn()
    uni:spawn()
    uni:spawn()
    example_print_log("count = " .. uni:getEntityCount())
end
```

---

#### `LUniverse:getLayer`

Returns the numeric layer assigned to an entity.

```lua
LUniverse:getLayer(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Entity id to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| number | Layer value, using the ECS default when no explicit layer exists. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:setLayer(e, 2)
    local layer = u:getLayer(e)
    local count = #u:getEntitiesByLayer(2)
    local sorted = u:getEntitiesSorted()
    ecs_log("entity layer=" .. tostring(layer) .. " same_layer_count=" .. tostring(count) .. " sorted_first=" .. tostring(sorted[1]))
end
```

---

#### `LUniverse:getParent`

Returns the parent entity id for a child entity.

```lua
LUniverse:getParent(child_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `child_id` | number | Entity id whose parent is read. |

**Returns**

| Type | Description |
|------|-------------|
| number | Parent entity id, or nil when the entity has no parent. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local parent = uni:spawn()
    local child = uni:spawn()
    uni:setParent(child, parent)
    local p = uni:getParent(child)
    example_print_log("parent = " .. p)
end
```

---

#### `LUniverse:getQueryChangeTick`

Returns the coarse invalidation tick used by cached ECS query views.

```lua
LUniverse:getQueryChangeTick()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Monotonic world query-change tick. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "pos", {x = 3, y = 4})
    uni:newQueryView({"pos"})
    example_print_log("query tick = " .. tostring(uni:getQueryChangeTick()))
end
```

---

#### `LUniverse:getRelated`

Returns targets linked from an entity by a named relation.

```lua
LUniverse:getRelated(from, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from` | number | Source entity id. |
| `name` | string | Relation name. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of related target entity ids. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    local b = uni:spawn()
    local c = uni:spawn()
    uni:addRelation(a, "friend", b)
    uni:addRelation(a, "friend", c)
    local friends = uni:getRelated(a, "friend")
    example_print_log("friends = " .. #friends)
end
```

---

#### `LUniverse:getSystemCount`

Returns the number of registered systems.

```lua
LUniverse:getSystemCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Registered system count. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    uni:addSystem({update = function() end}, {name = "movement", priority = 1})
    uni:addSystem({draw = function() end}, {name = "render", priority = 2})
    local count = uni:getSystemCount()
    local hero = uni:spawn()
    uni:set(hero, "name", "hero")
    ecs_log("system count=" .. tostring(count) .. " hero_alive=" .. tostring(uni:isAlive(hero)))
end
```

---

#### `LUniverse:getTags`

Returns string tags assigned to an entity.

```lua
LUniverse:getTags(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Entity id to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| string[] | Tag names. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:addTag(e, "enemy")
    example_print_log(#u:getTags(e))
end
```

---

#### `LUniverse:has`

Returns whether an entity has a named component.

```lua
LUniverse:has(id, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Entity id to inspect. |
| `name` | string | Component name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the component exists on the entity. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "speed", {value = 5})
    uni:set(id, "hp", {value = 20})
    local has_speed = uni:has(id, "speed")
    local has_hp = uni:has(id, "hp")
    local has_mp = uni:has(id, "mp")
    ecs_log("component presence speed=" .. tostring(has_speed) .. " hp=" .. tostring(has_hp) .. " mp=" .. tostring(has_mp))
end
```

---

#### `LUniverse:hasBitmapTag`

Returns whether an entity has a bitmap tag.

```lua
LUniverse:hasBitmapTag(id, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Entity id to inspect. |
| `name` | string | Bitmap tag name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the entity has the bitmap tag. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    example_print_log(u:hasBitmapTag(e, "enemy"))
end
```

---

#### `LUniverse:hasBlueprint`

Returns whether a named blueprint exists.

```lua
LUniverse:hasBlueprint(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Blueprint name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the blueprint is registered. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineBlueprint("base", { hp = 100 })
    u:extendBlueprint("enemy", "base", { damage = 10 })
    local has_enemy = u:hasBlueprint("enemy")
    local has_boss = u:hasBlueprint("boss")
    local names = u:listBlueprints()
    ecs_log("has blueprint enemy=" .. tostring(has_enemy) .. " boss=" .. tostring(has_boss) .. " total=" .. tostring(#names))
end
```

---

#### `LUniverse:hasRelation`

Returns whether a named directed relation exists between two entities.

```lua
LUniverse:hasRelation(from, name, to)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from` | number | Source entity id. |
| `name` | string | Relation name. |
| `to` | number | Target entity id. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the relation exists. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    local b = uni:spawn()
    uni:addRelation(a, "attacks", b)
    example_print_log("has relation = " .. tostring(uni:hasRelation(a, "attacks", b)))
end
```

---

#### `LUniverse:hasTag`

Returns whether an entity has a string tag.

```lua
LUniverse:hasTag(id, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Entity id to inspect. |
| `tag` | string | Tag name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the entity has the tag. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:addTag(e, "enemy")
    example_print_log(u:hasTag(e, "enemy"))
end
```

---

#### `LUniverse:isAlive`

Returns whether an entity id currently exists in this universe.

```lua
LUniverse:isAlive(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Entity id to test. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the entity is alive. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local hero = uni:spawn()
    local prop = uni:spawn()
    local hero_alive = uni:isAlive(hero)
    uni:kill(prop)
    local prop_alive = uni:isAlive(prop)
    ecs_log("liveness hero=" .. tostring(hero_alive) .. " prop=" .. tostring(prop_alive) .. " entity_count=" .. tostring(uni:getEntityCount()))
end
```

---

#### `LUniverse:kill`

Deletes an entity and removes its components from this universe.

```lua
LUniverse:kill(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Entity id to delete. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local owner = uni:spawn()
    local minion = uni:spawn()
    uni:addRelation(owner, "owns", minion)
    uni:kill(minion)
    local alive = uni:isAlive(minion)
    local owned = #uni:getRelated(owner, "owns")
    ecs_log("kill removed minion alive=" .. tostring(alive) .. " owner_links=" .. tostring(owned) .. " entity_count=" .. tostring(uni:getEntityCount()))
end
```

---

#### `LUniverse:killRecursive`

Deletes an entity and all descendant entities in its hierarchy.

```lua
LUniverse:killRecursive(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Root entity id to delete. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local root = uni:spawn()
    local child = uni:spawn()
    uni:setParent(child, root)
    uni:killRecursive(root)
    example_print_log("child alive = " .. tostring(uni:isAlive(child)))
end
```

---

#### `LUniverse:listBlueprints`

Returns names of all registered blueprints.

```lua
LUniverse:listBlueprints()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Blueprint names. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineBlueprint("base", { hp = 100 })
    u:extendBlueprint("enemy", "base", { damage = 10 })
    u:defineBlueprint("bullet", { speed = 50 })
    local names = u:listBlueprints()
    local first = names[1]
    local last = names[#names]
    ecs_log("blueprint names total=" .. tostring(#names) .. " first=" .. tostring(first) .. " last=" .. tostring(last))
end
```

---

#### `LUniverse:newQueryView`

Creates a cached component query view that refreshes only when this universe changes.

```lua
LUniverse:newQueryView(with_table, without_table)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `with_table` | table | Array table of required component names. |
| `without_table?` | table | Optional array table of excluded component names. |

**Returns**

| Type | Description |
|------|-------------|
| [LQueryView](#lqueryview) | Cached query-view handle bound to this universe. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "pos", {x = 3, y = 4})
    local view = uni:newQueryView({"pos"})
    example_print_log("view created = " .. tostring(view ~= nil))
end
```

---

#### `LUniverse:onComponentAdded`

Registers a callback for queued component-add events with a given component name.

```lua
LUniverse:onComponentAdded(name, cb)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Component name whose add events are observed. |
| `cb` | function | Callback receiving entity id and component name. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local added = false
    uni:onComponentAdded("hp", function() added = true end)
    local id = uni:spawn()
    uni:set(id, "hp", {value = 100})
    uni:flushObservers()
    example_print_log("added callback fired = " .. tostring(added))
end
```

---

#### `LUniverse:onComponentRemoved`

Registers a callback for queued component-remove events with a given component name.

```lua
LUniverse:onComponentRemoved(name, cb)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Component name whose remove events are observed. |
| `cb` | function | Callback receiving entity id and component name. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local removed = false
    uni:onComponentRemoved("hp", function() removed = true end)
    local id = uni:spawn()
    uni:set(id, "hp", {value = 50})
    uni:remove(id, "hp")
    uni:flushObservers()
    example_print_log("removed callback fired = " .. tostring(removed))
end
```

---

#### `LUniverse:query`

Returns entities that have all component names passed as varargs.

```lua
LUniverse:query(...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| — | — | @param ... string Component names that every returned entity must have. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of matching entity ids. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    uni:set(a, "pos", {x = 0, y = 0})
    uni:set(a, "vel", {x = 1, y = 0})
    local b = uni:spawn()
    uni:set(b, "pos", {x = 5, y = 5})
    example_print_log("with pos+vel = " .. #uni:query("pos", "vel"))
end
```

---

#### `LUniverse:queryBitmapAll`

Returns entities that have every bitmap tag from a list.

```lua
LUniverse:queryBitmapAll(names)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `names` | table | Array table of bitmap tag names. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of matching entity ids. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    example_print_log(#u:queryBitmapAll({"enemy"}))
end
```

---

#### `LUniverse:queryBitmapAny`

Returns entities with at least one bitmap tag from a list.

```lua
LUniverse:queryBitmapAny(names)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `names` | table | Array table of bitmap tag names. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of matching entity ids. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    example_print_log(#u:queryBitmapAny({"enemy"}))
end
```

---

#### `LUniverse:queryBitmapTag`

Returns entities with one bitmap tag.

```lua
LUniverse:queryBitmapTag(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Bitmap tag name used for lookup. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of matching entity ids. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    example_print_log(#u:queryBitmapTag("enemy"))
end
```

---

#### `LUniverse:queryMulti`

Iterates entities that have all component names from a table.

```lua
LUniverse:queryMulti(names_table, callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `names_table` | table | Array table of component names. |
| `callback` | function | Callback invoked by the ECS backend for each matching entity. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "a", {value = 1})
    uni:set(id, "b", {value = 2})
    local count = 0
    uni:queryMulti({"a", "b"}, function(entity_id, a_value, b_value)
        count = count + 1
        example_print_log("queryMulti entity = " .. tostring(entity_id))
        example_print_log("values = " .. tostring(a_value.value) .. "," .. tostring(b_value.value))
    end)
    example_print_log("queryMulti = " .. count)
end
```

---

#### `LUniverse:queryNot`

Returns entities that include one component set and exclude another component set.

```lua
LUniverse:queryNot(with_tbl, without_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `with_tbl` | table | Array table of required component names. |
| `without_tbl` | table | Array table of forbidden component names. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of matching entity ids. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    local b = uni:spawn()
    uni:set(a, "pos", {x = 0, y = 0})
    uni:set(a, "static", {flag = true})
    uni:set(b, "pos", {x = 1, y = 1})
    example_print_log("moving entities = " .. #uni:queryNot({"pos"}, {"static"}))
end
```

---

#### `LUniverse:release`

Releases universe contents by clearing all ECS state.

```lua
LUniverse:release()
```

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    local entity = u:spawn()
    u:set(entity, "name", "temp")
    local before = u:getEntityCount()
    u:release()
    local after = u:getEntityCount()
    local alive = u:isAlive(entity)
    ecs_log("release world before=" .. tostring(before) .. " after=" .. tostring(after) .. " old_entity_alive=" .. tostring(alive))
end
```

---

#### `LUniverse:remove`

Removes a named component from an entity.

```lua
LUniverse:remove(id, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Entity id to mutate. |
| `name` | string | Component name to remove. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "temp", {flag = true})
    uni:remove(id, "temp")
    example_print_log("after remove has = " .. tostring(uni:has(id, "temp")))
end
```

---

#### `LUniverse:removeBlueprint`

Removes a named blueprint from this universe.

```lua
LUniverse:removeBlueprint(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Blueprint name to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a blueprint was removed. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineBlueprint("base", { hp = 100 })
    u:extendBlueprint("enemy", "base", { damage = 10 })
    u:removeBlueprint("enemy")
    example_print_log(u:hasBlueprint("enemy"))
end
```

---

#### `LUniverse:removeRelation`

Removes a named directed relation between two entities.

```lua
LUniverse:removeRelation(from, name, to)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from` | number | Source entity id. |
| `name` | string | Relation name. |
| `to` | number | Target entity id. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local a, b = uni:spawn(), uni:spawn()
    uni:addRelation(a, "owns", b)
    uni:removeRelation(a, "owns", b)
    example_print_log("relation removed")
end
```

---

#### `LUniverse:removeSystem`

Removes a previously registered Lua system table.

```lua
LUniverse:removeSystem(system)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `system` | table | System table to remove from this universe. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local sys = {update = function() end}
    uni:addSystem(sys)
    uni:removeSystem(sys)
    example_print_log("after remove systems = " .. uni:getSystemCount())
end
```

---

#### `LUniverse:removeTag`

Removes a string tag from an entity.

```lua
LUniverse:removeTag(id, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Entity id to update. |
| `tag` | string | Tag name to remove. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:addTag(e, "enemy")
    u:removeTag(e, "enemy")
    example_print_log(u:hasTag(e, "enemy"))
end
```

---

#### `LUniverse:render`

Runs registered render-phase systems using their render or draw callbacks.

```lua
LUniverse:render()
```

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local drawn = false
    uni:addSystem({draw = function() drawn = true end})
    uni:render()
    example_print_log("render called = " .. tostring(drawn))
end
```

---

#### `LUniverse:serialize`

Serializes this universe into a Lua table snapshot.

```lua
LUniverse:serialize()
```

**Returns**

| Type | Description |
|------|-------------|
| LUniverseSerializeResult | Snapshot table containing entities and component state. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "data", {k = "v"})
    local snap = uni:serialize()
    example_print_log("entities in snapshot = " .. #snap.entities)
end
```

---

#### `LUniverse:set`

Stores or replaces a component value on an entity.

```lua
LUniverse:set(id, name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Entity id that receives the component. |
| `name` | string | Component name. |
| `value` | any | Lua value stored as the component payload. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "position", {x = 10, y = 20})
    uni:set(id, "hp", {value = 100})
    local pos = uni:get(id, "position")
    local hp = uni:get(id, "hp")
    ecs_log("components set pos=" .. tostring(pos.x) .. "," .. tostring(pos.y) .. " hp=" .. tostring(hp.value))
end
```

---

#### `LUniverse:setLayer`

Assigns a numeric layer to an entity.

```lua
LUniverse:setLayer(id, layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Entity id to update. |
| `layer` | number | Layer value stored on the entity. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:setLayer(e, 2)
    local before = u:getLayer(e)
    u:setLayer(e, 4)
    local after = u:getLayer(e)
    local layer_entities = u:getEntitiesByLayer(4)
    ecs_log("set layer before=" .. tostring(before) .. " after=" .. tostring(after) .. " layer_entities=" .. tostring(#layer_entities))
end
```

---

#### `LUniverse:setParent`

Sets or clears the parent entity for a child entity.

```lua
LUniverse:setParent(child_id, parent_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `child_id` | number | Entity id whose parent changes. |
| `parent_id?` | number | Parent entity id, or nil to clear the parent. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local parent = uni:spawn()
    local child = uni:spawn()
    uni:setParent(child, parent)
    example_print_log("parent set")
end
```

---

#### `LUniverse:snapshot`

Serializes this universe into a Lua table snapshot.

```lua
LUniverse:snapshot()
```

**Returns**

| Type | Description |
|------|-------------|
| LUniverseSnapshotResult | Snapshot table containing entities and component state. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "val", {value = 42})
    local snap = uni:snapshot()
    example_print_log("snapshot type = " .. type(snap))
    example_print_log("snapshot entities = " .. #snap.entities)
end
```

---

#### `LUniverse:spawn`

Creates a new entity in this universe.

```lua
LUniverse:spawn()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Numeric entity id for the spawned entity. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local hero = uni:spawn()
    local enemy = uni:spawn()
    uni:set(hero, "name", "hero")
    uni:set(enemy, "name", "enemy")
    local ids = uni:getEntities()
    ecs_log("spawned entities hero=" .. tostring(hero) .. " enemy=" .. tostring(enemy) .. " live_count=" .. tostring(#ids))
end
```

---

#### `LUniverse:spawnBlueprint`

Spawns an entity from a named blueprint with optional component overrides.

```lua
LUniverse:spawnBlueprint(name, overrides)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Blueprint name to instantiate. |
| `overrides?` | table | Optional component overrides applied to this spawn. |

**Returns**

| Type | Description |
|------|-------------|
| number | Entity id created from the blueprint. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("npc", {pos = {x = 0, y = 0}})
    local id = uni:spawnBlueprint("npc", {pos = {x = 5, y = 5}})
    local pos = uni:get(id, "pos")
    local components = uni:getComponents(id)
    local alive = uni:isAlive(id)
    ecs_log("spawned blueprint id=" .. tostring(id) .. " pos=" .. tostring(pos.x) .. "," .. tostring(pos.y) .. " components=" .. tostring(#components) .. " alive=" .. tostring(alive))
end
```

---

#### `LUniverse:spawnBulk`

Spawns multiple entities from a blueprint using shared optional overrides.

```lua
LUniverse:spawnBulk(name, count, overrides)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Blueprint name to instantiate. |
| `count` | number | Number of entities to spawn. |
| `overrides?` | table | Optional component overrides applied to each spawned entity. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of spawned entity ids. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("bullet", {pos = {x = 0, y = 0}})
    local ids = uni:spawnBulk("bullet", 10)
    local first = ids[1]
    local first_pos = first and uni:get(first, "pos") or nil
    local count = uni:getEntityCount()
    ecs_log("bulk spawned count=" .. tostring(#ids) .. " first=" .. tostring(first) .. " first_pos_x=" .. tostring(first_pos and first_pos.x) .. " live_count=" .. tostring(count))
end
```

---

#### `LUniverse:takeSnapshotDiff`

Returns and clears accumulated ECS snapshot diff data.

```lua
LUniverse:takeSnapshotDiff()
```

**Returns**

| Type | Description |
|------|-------------|
| LUniverseTakeSnapshotDiffResult | Diff table with added_components, removed_components, deleted_entities, and dirty_entities arrays. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:set(e, "pos", { x = 1, y = 2 })
    local diff = u:takeSnapshotDiff()
    example_print_log("dirty entities = " .. tostring(#diff.dirty_entities))
end
```

---

#### `LUniverse:type`

Returns the Lua-visible type name for this universe handle.

```lua
LUniverse:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LUniverse](#luniverse)`. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local type_name = uni:type()
    local entity = uni:spawn()
    local count = uni:getEntityCount()
    ecs_log("universe type=" .. tostring(type_name) .. " entity=" .. tostring(entity) .. " count=" .. tostring(count))
end
```

---

#### `LUniverse:typeOf`

Returns whether this universe handle matches a supported type name.

```lua
LUniverse:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LUniverse](#luniverse)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local is_universe = uni:typeOf("LUniverse")
    local is_object = uni:typeOf("LObject")
    local is_rm = uni:typeOf("LRelationshipManager")
    ecs_log("universe type guard universe=" .. tostring(is_universe) .. " object=" .. tostring(is_object) .. " rm=" .. tostring(is_rm))
end
```

---

#### `LUniverse:update`

Runs registered update-phase systems with a frame delta.

```lua
LUniverse:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Frame delta time in seconds. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local called = false
    uni:addSystem({update = function() called = true end})
    uni:update(1 / 60)
    example_print_log("update called = " .. tostring(called))
end
```

---

#### `LUniverse:updatePhase`

Runs registered systems assigned to a named phase.

```lua
LUniverse:updatePhase(phase, dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `phase` | string | System phase name to run. |
| `dt` | number | Frame delta time in seconds. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local ran = false
    uni:addSystem({update = function() ran = true end}, {phase = "physics"})
    uni:updatePhase("physics", 1 / 60)
    example_print_log("phase ran = " .. tostring(ran))
end
```

---
