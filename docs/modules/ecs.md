# Ecs

- The `ecs` module provides Lurek2D with a highly optimized, Lua-first Entity-Component-System (ECS) runtime.

Central to this module is the `Universe` container, which orchestrates the entire lifecycle of entities, components, and systems within the Feature Systems tier. Entities are represented as lightweight, packed 32-bit generational IDs (comprising a 24-bit slot index and an 8-bit generation counter). This generational approach efficiently manages slot reuse and instantly invalidates stale entity handles without costly memory lookups. Unlike traditional Rust-centric ECS architectures, Lurek2D components are arbitrary Lua values stored directly within per-entity Lua registry tables; there is no hidden Rust-side component data storage. This design ensures seamless interplay with Lua scripts and maximizes flexibility for game developers.

The module provides robust data querying mechanisms, ranging from basic `set`, `get`, `has`, and `remove` operations to advanced batch lookups like `query`, `queryNot`, and `queryMulti`. To further accelerate queries, the module offers an archetype-style index. Beyond simple component attachments, the ECS supports sophisticated entity hierarchies with parent-child relationships, enabling recursive cascading operations like hierarchical deletions (`kill_recursive`). For rapid entity classification and filtering, the module implements string-based tagging and high-speed 63-bit bitmap tags. Additionally, numeric layer assignments are supported, natively sorting entities for deterministic rendering operations.

To simplify entity instantiation, the ECS leverages a Blueprint system. Blueprints act as reusable component templates; developers can define base blueprints, extend them via inheritance, and rapidly instantiate entities (`spawn_blueprint`, `spawn_bulk`) with optional component overrides. Systems—representing game logic—are registered as named Lua callbacks. The `Universe` performs priority-based topological sorting to execute these systems in correct dependency order during defined `update` and `render` phases. Finally, the module fully supports state serialization. By computing incremental snapshot diffs and deep-copying Lua tables, the `Universe` enables robust save/load capabilities, network synchronization, and deterministic state resets. The entire suite of tools is securely exposed via the `lurek.ecs.*` API.

## Functions

### `lurek.ecs.newUniverse`

Creates an empty ECS universe for entity, component, system, and relationship management.

```lua
-- signature
lurek.ecs.newUniverse()
```

**Returns**

| Type | Description |
|------|-------------|
| `LUniverse` | New universe handle. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    print("universe created, entities = " .. uni:getEntityCount())
end
```

---

## LUniverse

### `LUniverse:addRelation`

Adds a named directed relation from one entity to another.

```lua
-- signature
LUniverse:addRelation(from, name, to)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from` | `number` | Source entity id. |
| `name` | `string` | Relation name. |
| `to` | `number` | Target entity id. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    local b = uni:spawn()
    uni:addRelation(a, "likes", b)
    print("relation added")
end
```

---

### `LUniverse:addSystem`

Registers a Lua system table with optional phase, priority, name, and dependency metadata.

```lua
-- signature
LUniverse:addSystem(system, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `system` | `table` | System table containing update, render, draw, or event methods. |
| `opts?` | `table` | Optional table with priority, phase, name, and after fields. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local sys = { update = function(self, universe, dt) end }
    uni:addSystem(sys, {name = "movement", priority = 1})
    print("systems = " .. uni:getSystemCount())
end
```

---

### `LUniverse:addTag`

Assigns a string tag name to an entity in this universe.

```lua
-- signature
LUniverse:addTag(id, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Entity id to tag. |
| `tag` | `string` | Tag name to add. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:addTag(e, "enemy")
    print(u:hasTag(e, "enemy"))
end
```

---

### `LUniverse:applySnapshot`

Replaces this universe state from a Lua table snapshot.

```lua
-- signature
LUniverse:applySnapshot(snapshot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `snapshot` | `table` | Snapshot table previously produced by `snapshot` or `serialize`. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:set(e, "pos", { x = 1, y = 2 })
    local snap = u:snapshot()
    u:clear()
    u:applySnapshot(snap)
    print("entities after apply = " .. u:getEntityCount())
end
```

---

### `LUniverse:bitmapTag`

Adds a bitmap tag to an entity, defining the tag if needed.

```lua
-- signature
LUniverse:bitmapTag(id, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Entity id to tag. |
| `name` | `string` | Bitmap tag name. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Bit index used by the bitmap tag. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    print(u:hasBitmapTag(e, "enemy"))
end
```

---

### `LUniverse:bitmapUntag`

Removes a bitmap tag from an entity.

```lua
-- signature
LUniverse:bitmapUntag(id, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Entity id to update. |
| `name` | `string` | Bitmap tag name to remove. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    u:bitmapUntag(e, "enemy")
    print(u:hasBitmapTag(e, "enemy"))
end
```

---

### `LUniverse:clear`

Clears all entities, components, systems, and ECS state from this universe.

```lua
-- signature
LUniverse:clear()
```

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:spawn()
    u:clear()
    print("entities after clear = " .. u:getEntityCount())
end
```

---

### `LUniverse:clearRelations`

Removes every target for one named relation from an entity.

```lua
-- signature
LUniverse:clearRelations(from, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from` | `number` | Source entity id. |
| `name` | `string` | Relation name to clear. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    local b = uni:spawn()
    uni:addRelation(a, "sees", b)
    uni:clearRelations(a, "sees")
    local targets = uni:getRelated(a, "sees")
    print("after clear = " .. #targets)
end
```

---

### `LUniverse:defineBlueprint`

Defines a named entity blueprint from a component table.

```lua
-- signature
LUniverse:defineBlueprint(name, components)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Blueprint name. |
| `components` | `table` | Component table copied when the blueprint is spawned. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("enemy", {pos = {x = 0, y = 0}, hp = {value = 50}, tag = {value = "hostile"}})
    print("blueprint defined")
end
```

---

### `LUniverse:defineTag`

Defines a bitmap tag name and assigns it a bit slot.

```lua
-- signature
LUniverse:defineTag(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Bitmap tag name to define. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Bit index assigned to the tag. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:addTag(e, "enemy")
    print(u:hasTag(e, "enemy"))
end
```

---

### `LUniverse:deserialize`

Replaces this universe state from a serialized Lua snapshot.

```lua
-- signature
LUniverse:deserialize(snapshot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `snapshot` | `table` | Snapshot table previously produced by `serialize` or `snapshot`. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "score", {value = 99})
    uni:deserialize(uni:serialize())
    print("deserialized, count = " .. uni:getEntityCount())
end
```

---

### `LUniverse:each`

Iterates entities with one component and calls a Lua callback for each match.

```lua
-- signature
LUniverse:each(name, callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Component name used to select entities. |
| `callback` | `function` | Callback invoked by the ECS backend for each matching entity. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "name", {value = "hero"})
    local count = 0
    uni:each("name", function(entity_id, name_value)
        count = count + 1
        print("visited entity = " .. tostring(entity_id))
        print("name.value = " .. tostring(name_value.value))
    end)
    print("each count = " .. count)
end
```

---

### `LUniverse:emit`

Calls matching event-named functions on registered systems.

```lua
-- signature
LUniverse:emit(event, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `event` | `string` | Function name looked up on each system table. |
| — | — | @param ... any Extra values forwarded after the system and universe arguments. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local got = false
    uni:addSystem({on_damage = function() got = true end})
    uni:emit("on_damage")
    print("emit received = " .. tostring(got))
end
```

---

### `LUniverse:extendBlueprint`

Defines a blueprint that inherits from a parent blueprint and applies overrides.

```lua
-- signature
LUniverse:extendBlueprint(name, parent, overrides)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Child blueprint name to define. |
| `parent` | `string` | Existing parent blueprint name. |
| `overrides` | `table` | Component overrides applied over the parent definition. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineBlueprint("base", { hp = 100 })
    u:extendBlueprint("enemy", "base", { damage = 10 })
    print(u:hasBlueprint("enemy"))
end
```

---

### `LUniverse:flushObservers`

Delivers queued component add and remove events to registered observer callbacks.

```lua
-- signature
LUniverse:flushObservers()
```

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    uni:flushObservers()
    print("observers flushed")
end
```

---

### `LUniverse:get`

Returns a component value from an entity.

```lua
-- signature
LUniverse:get(id, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Entity id to read. |
| `name` | `string` | Component name to read. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | number|string|boolean|nil | Stored component value, or nil when the entity does not have that component. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "hp", {value = 100})
    local hp = uni:get(id, "hp")
    print("hp.value = " .. tostring(hp.value))
end
```

---

### `LUniverse:getBitmapTagBit`

Returns the bit index assigned to a bitmap tag name.

```lua
-- signature
LUniverse:getBitmapTagBit(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Bitmap tag name to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Bit index when the tag exists, or nil when the tag is undefined. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    print("bit = " .. tostring(u:getBitmapTagBit("enemy")))
end
```

---

### `LUniverse:getBlueprintComponents`

Returns the component table stored for a blueprint.

```lua
-- signature
LUniverse:getBlueprintComponents(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Blueprint name to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Blueprint component table. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("item", {name = {value = "sword"}, damage = {value = 10}})
    local comps = uni:getBlueprintComponents("item")
    print("blueprint comps type = " .. type(comps))
    print("damage = " .. tostring(comps.damage.value))
end
```

---

### `LUniverse:getChildren`

Returns child entity ids for a parent entity.

```lua
-- signature
LUniverse:getChildren(parent_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `parent_id` | `number` | Parent entity id to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of child entity ids. |

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
    print("children = " .. #children)
end
```

---

### `LUniverse:getComponents`

Returns component names currently stored on an entity.

```lua
-- signature
LUniverse:getComponents(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Entity id to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Component name strings. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "pos", {x = 0, y = 0})
    uni:set(id, "vel", {x = 1, y = 0})
    local names = uni:getComponents(id)
    print("components = " .. #names)
end
```

---

### `LUniverse:getDirtyEntities`

Returns entities marked dirty by recent ECS mutations.

```lua
-- signature
LUniverse:getDirtyEntities()
```

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of dirty entity ids. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "x", {value = 1})
    local dirty = uni:getDirtyEntities()
    print("dirty = " .. #dirty)
end
```

---

### `LUniverse:getEntities`

Returns all live entity ids in this universe.

```lua
-- signature
LUniverse:getEntities()
```

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of live entity ids. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    uni:spawn()
    uni:spawn()
    local all = uni:getEntities()
    print("entities = " .. #all)
end
```

---

### `LUniverse:getEntitiesByLayer`

Returns entities assigned to a numeric layer.

```lua
-- signature
LUniverse:getEntitiesByLayer(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | `number` | Layer value used for lookup. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of matching entity ids. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:setLayer(e, 2)
    print(#u:getEntitiesByLayer(2))
end
```

---

### `LUniverse:getEntitiesByTag`

Returns entities that have a string tag.

```lua
-- signature
LUniverse:getEntitiesByTag(tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tag` | `string` | Tag name used for lookup. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of matching entity ids. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("unit")
    local e = u:spawn()
    u:addTag(e, "unit")
    print(#u:getEntitiesByTag("unit"))
end
```

---

### `LUniverse:getEntitiesSorted`

Returns live entities sorted by ECS layer and stable entity ordering.

```lua
-- signature
LUniverse:getEntitiesSorted()
```

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of sorted entity ids. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:setLayer(e, 2)
    print("sorted count = " .. #u:getEntitiesSorted())
end
```

---

### `LUniverse:getEntityCount`

Returns the number of live entities in this universe.

```lua
-- signature
LUniverse:getEntityCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Live entity count. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    uni:spawn()
    uni:spawn()
    uni:spawn()
    print("count = " .. uni:getEntityCount())
end
```

---

### `LUniverse:getLayer`

Returns the numeric layer assigned to an entity.

```lua
-- signature
LUniverse:getLayer(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Entity id to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Layer value, using the ECS default when no explicit layer exists. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:setLayer(e, 2)
    print("layer = " .. tostring(u:getLayer(e)))
end
```

---

### `LUniverse:getParent`

Returns the parent entity id for a child entity.

```lua
-- signature
LUniverse:getParent(child_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `child_id` | `number` | Entity id whose parent is read. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Parent entity id, or nil when the entity has no parent. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local parent = uni:spawn()
    local child = uni:spawn()
    uni:setParent(child, parent)
    local p = uni:getParent(child)
    print("parent = " .. p)
end
```

---

### `LUniverse:getRelated`

Returns targets linked from an entity by a named relation.

```lua
-- signature
LUniverse:getRelated(from, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from` | `number` | Source entity id. |
| `name` | `string` | Relation name. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of related target entity ids. |

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
    print("friends = " .. #friends)
end
```

---

### `LUniverse:getSystemCount`

Returns the number of registered systems.

```lua
-- signature
LUniverse:getSystemCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Registered system count. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    uni:addSystem({update = function() end})
    uni:addSystem({draw = function() end})
    print("system count = " .. uni:getSystemCount())
end
```

---

### `LUniverse:getTags`

Returns string tags assigned to an entity.

```lua
-- signature
LUniverse:getTags(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Entity id to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Tag names. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:addTag(e, "enemy")
    print(#u:getTags(e))
end
```

---

### `LUniverse:has`

Returns whether an entity has a named component.

```lua
-- signature
LUniverse:has(id, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Entity id to inspect. |
| `name` | `string` | Component name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the component exists on the entity. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "speed", {value = 5})
    print("has speed = " .. tostring(uni:has(id, "speed")))
end
```

---

### `LUniverse:hasBitmapTag`

Returns whether an entity has a bitmap tag.

```lua
-- signature
LUniverse:hasBitmapTag(id, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Entity id to inspect. |
| `name` | `string` | Bitmap tag name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the entity has the bitmap tag. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    print(u:hasBitmapTag(e, "enemy"))
end
```

---

### `LUniverse:hasBlueprint`

Returns whether a named blueprint exists.

```lua
-- signature
LUniverse:hasBlueprint(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Blueprint name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the blueprint is registered. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineBlueprint("base", { hp = 100 })
    u:extendBlueprint("enemy", "base", { damage = 10 })
    print(u:hasBlueprint("enemy"))
end
```

---

### `LUniverse:hasRelation`

Returns whether a named directed relation exists between two entities.

```lua
-- signature
LUniverse:hasRelation(from, name, to)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from` | `number` | Source entity id. |
| `name` | `string` | Relation name. |
| `to` | `number` | Target entity id. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the relation exists. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    local b = uni:spawn()
    uni:addRelation(a, "attacks", b)
    print("has relation = " .. tostring(uni:hasRelation(a, "attacks", b)))
end
```

---

### `LUniverse:hasTag`

Returns whether an entity has a string tag.

```lua
-- signature
LUniverse:hasTag(id, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Entity id to inspect. |
| `tag` | `string` | Tag name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the entity has the tag. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:addTag(e, "enemy")
    print(u:hasTag(e, "enemy"))
end
```

---

### `LUniverse:isAlive`

Returns whether an entity id currently exists in this universe.

```lua
-- signature
LUniverse:isAlive(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Entity id to test. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the entity is alive. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    print("alive = " .. tostring(uni:isAlive(id)))
end
```

---

### `LUniverse:kill`

Deletes an entity and removes its components from this universe.

```lua
-- signature
LUniverse:kill(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Entity id to delete. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:kill(id)
    print("killed, alive = " .. tostring(uni:isAlive(id)))
end
```

---

### `LUniverse:killRecursive`

Deletes an entity and all descendant entities in its hierarchy.

```lua
-- signature
LUniverse:killRecursive(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Root entity id to delete. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local root = uni:spawn()
    local child = uni:spawn()
    uni:setParent(child, root)
    uni:killRecursive(root)
    print("child alive = " .. tostring(uni:isAlive(child)))
end
```

---

### `LUniverse:listBlueprints`

Returns names of all registered blueprints.

```lua
-- signature
LUniverse:listBlueprints()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Blueprint names. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineBlueprint("base", { hp = 100 })
    u:extendBlueprint("enemy", "base", { damage = 10 })
    print(#u:listBlueprints())
end
```

---

### `LUniverse:onComponentAdded`

Registers a callback for queued component-add events with a given component name.

```lua
-- signature
LUniverse:onComponentAdded(name, cb)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Component name whose add events are observed. |
| `cb` | `function` | Callback receiving entity id and component name. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local added = false
    uni:onComponentAdded("hp", function() added = true end)
    local id = uni:spawn()
    uni:set(id, "hp", {value = 100})
    uni:flushObservers()
    print("added callback fired = " .. tostring(added))
end
```

---

### `LUniverse:onComponentRemoved`

Registers a callback for queued component-remove events with a given component name.

```lua
-- signature
LUniverse:onComponentRemoved(name, cb)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Component name whose remove events are observed. |
| `cb` | `function` | Callback receiving entity id and component name. |

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
    print("removed callback fired = " .. tostring(removed))
end
```

---

### `LUniverse:query`

Returns entities that have all component names passed as varargs.

```lua
-- signature
LUniverse:query(...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| — | — | @param ... string Component names that every returned entity must have. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of matching entity ids. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    uni:set(a, "pos", {x = 0, y = 0})
    uni:set(a, "vel", {x = 1, y = 0})
    local b = uni:spawn()
    uni:set(b, "pos", {x = 5, y = 5})
    print("with pos+vel = " .. #uni:query("pos", "vel"))
end
```

---

### `LUniverse:queryBitmapAll`

Returns entities that have every bitmap tag from a list.

```lua
-- signature
LUniverse:queryBitmapAll(names)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `names` | `table` | Array table of bitmap tag names. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of matching entity ids. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    print(#u:queryBitmapAll({"enemy"}))
end
```

---

### `LUniverse:queryBitmapAny`

Returns entities with at least one bitmap tag from a list.

```lua
-- signature
LUniverse:queryBitmapAny(names)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `names` | `table` | Array table of bitmap tag names. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of matching entity ids. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    print(#u:queryBitmapAny({"enemy"}))
end
```

---

### `LUniverse:queryBitmapTag`

Returns entities with one bitmap tag.

```lua
-- signature
LUniverse:queryBitmapTag(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Bitmap tag name used for lookup. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of matching entity ids. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    print(#u:queryBitmapTag("enemy"))
end
```

---

### `LUniverse:queryMulti`

Iterates entities that have all component names from a table.

```lua
-- signature
LUniverse:queryMulti(names_table, callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `names_table` | `table` | Array table of component names. |
| `callback` | `function` | Callback invoked by the ECS backend for each matching entity. |

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
        print("queryMulti entity = " .. tostring(entity_id))
        print("values = " .. tostring(a_value.value) .. "," .. tostring(b_value.value))
    end)
    print("queryMulti = " .. count)
end
```

---

### `LUniverse:queryNot`

Returns entities that include one component set and exclude another component set.

```lua
-- signature
LUniverse:queryNot(with_tbl, without_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `with_tbl` | `table` | Array table of required component names. |
| `without_tbl` | `table` | Array table of forbidden component names. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of matching entity ids. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    local b = uni:spawn()
    uni:set(a, "pos", {x = 0, y = 0})
    uni:set(a, "static", {flag = true})
    uni:set(b, "pos", {x = 1, y = 1})
    print("moving entities = " .. #uni:queryNot({"pos"}, {"static"}))
end
```

---

### `LUniverse:release`

Releases universe contents by clearing all ECS state.

```lua
-- signature
LUniverse:release()
```

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:release()
    print("released")
end
```

---

### `LUniverse:remove`

Removes a named component from an entity.

```lua
-- signature
LUniverse:remove(id, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Entity id to mutate. |
| `name` | `string` | Component name to remove. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "temp", {flag = true})
    uni:remove(id, "temp")
    print("after remove has = " .. tostring(uni:has(id, "temp")))
end
```

---

### `LUniverse:removeBlueprint`

Removes a named blueprint from this universe.

```lua
-- signature
LUniverse:removeBlueprint(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Blueprint name to remove. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a blueprint was removed. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineBlueprint("base", { hp = 100 })
    u:extendBlueprint("enemy", "base", { damage = 10 })
    u:removeBlueprint("enemy")
    print(u:hasBlueprint("enemy"))
end
```

---

### `LUniverse:removeRelation`

Removes a named directed relation between two entities.

```lua
-- signature
LUniverse:removeRelation(from, name, to)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from` | `number` | Source entity id. |
| `name` | `string` | Relation name. |
| `to` | `number` | Target entity id. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local a, b = uni:spawn(), uni:spawn()
    uni:addRelation(a, "owns", b)
    uni:removeRelation(a, "owns", b)
    print("relation removed")
end
```

---

### `LUniverse:removeSystem`

Removes a previously registered Lua system table.

```lua
-- signature
LUniverse:removeSystem(system)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `system` | `table` | System table to remove from this universe. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local sys = {update = function() end}
    uni:addSystem(sys)
    uni:removeSystem(sys)
    print("after remove systems = " .. uni:getSystemCount())
end
```

---

### `LUniverse:removeTag`

Removes a string tag from an entity.

```lua
-- signature
LUniverse:removeTag(id, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Entity id to update. |
| `tag` | `string` | Tag name to remove. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:addTag(e, "enemy")
    u:removeTag(e, "enemy")
    print(u:hasTag(e, "enemy"))
end
```

---

### `LUniverse:render`

Runs registered render-phase systems using their render or draw callbacks.

```lua
-- signature
LUniverse:render()
```

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local drawn = false
    uni:addSystem({draw = function() drawn = true end})
    uni:render()
    print("render called = " .. tostring(drawn))
end
```

---

### `LUniverse:serialize`

Serializes this universe into a Lua table snapshot.

```lua
-- signature
LUniverse:serialize()
```

**Returns**

| Type | Description |
|------|-------------|
| `LUniverseSerializeResult` | Snapshot table containing entities and component state. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "data", {k = "v"})
    local snap = uni:serialize()
    print("entities in snapshot = " .. #snap.entities)
end
```

---

### `LUniverse:set`

Stores or replaces a component value on an entity.

```lua
-- signature
LUniverse:set(id, name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Entity id that receives the component. |
| `name` | `string` | Component name. |
| `value` | `any` | Lua value stored as the component payload. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "position", {x = 10, y = 20})
    print("position set")
end
```

---

### `LUniverse:setLayer`

Assigns a numeric layer to an entity.

```lua
-- signature
LUniverse:setLayer(id, layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Entity id to update. |
| `layer` | `number` | Layer value stored on the entity. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:setLayer(e, 2)
    print("layer = " .. tostring(u:getLayer(e)))
end
```

---

### `LUniverse:setParent`

Sets or clears the parent entity for a child entity.

```lua
-- signature
LUniverse:setParent(child_id, parent_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `child_id` | `number` | Entity id whose parent changes. |
| `parent_id?` | `number` | Parent entity id, or nil to clear the parent. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local parent = uni:spawn()
    local child = uni:spawn()
    uni:setParent(child, parent)
    print("parent set")
end
```

---

### `LUniverse:snapshot`

Serializes this universe into a Lua table snapshot.

```lua
-- signature
LUniverse:snapshot()
```

**Returns**

| Type | Description |
|------|-------------|
| `LUniverseSnapshotResult` | Snapshot table containing entities and component state. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "val", {value = 42})
    local snap = uni:snapshot()
    print("snapshot type = " .. type(snap))
    print("snapshot entities = " .. #snap.entities)
end
```

---

### `LUniverse:spawn`

Creates a new entity in this universe.

```lua
-- signature
LUniverse:spawn()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Numeric entity id for the spawned entity. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    print("spawned entity id = " .. id)
end
```

---

### `LUniverse:spawnBlueprint`

Spawns an entity from a named blueprint with optional component overrides.

```lua
-- signature
LUniverse:spawnBlueprint(name, overrides)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Blueprint name to instantiate. |
| `overrides?` | `table` | Optional component overrides applied to this spawn. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Entity id created from the blueprint. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("npc", {pos = {x = 0, y = 0}})
    local id = uni:spawnBlueprint("npc", {pos = {x = 5, y = 5}})
    print("spawned from blueprint id = " .. id)
end
```

---

### `LUniverse:spawnBulk`

Spawns multiple entities from a blueprint using shared optional overrides.

```lua
-- signature
LUniverse:spawnBulk(name, count, overrides)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Blueprint name to instantiate. |
| `count` | `number` | Number of entities to spawn. |
| `overrides?` | `table` | Optional component overrides applied to each spawned entity. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of spawned entity ids. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("bullet", {pos = {x = 0, y = 0}})
    local ids = uni:spawnBulk("bullet", 10)
    print("bulk spawned = " .. #ids)
end
```

---

### `LUniverse:takeSnapshotDiff`

Returns and clears accumulated ECS snapshot diff data.

```lua
-- signature
LUniverse:takeSnapshotDiff()
```

**Returns**

| Type | Description |
|------|-------------|
| `LUniverseTakeSnapshotDiffResult` | Diff table with added_components, removed_components, deleted_entities, and dirty_entities arrays. |

**Example**

```lua
do
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:set(e, "pos", { x = 1, y = 2 })
    local diff = u:takeSnapshotDiff()
    print("dirty entities = " .. tostring(#diff.dirty_entities))
end
```

---

### `LUniverse:type`

Returns the Lua-visible type name for this universe handle.

```lua
-- signature
LUniverse:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LUniverse`. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    print("type = " .. uni:type())
end
```

---

### `LUniverse:typeOf`

Returns whether this universe handle matches a supported type name.

```lua
-- signature
LUniverse:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LUniverse` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    print("is LUniverse = " .. tostring(uni:typeOf("LUniverse")))
end
```

---

### `LUniverse:update`

Runs registered update-phase systems with a frame delta.

```lua
-- signature
LUniverse:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Frame delta time in seconds. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local called = false
    uni:addSystem({update = function() called = true end})
    uni:update(1 / 60)
    print("update called = " .. tostring(called))
end
```

---

### `LUniverse:updatePhase`

Runs registered systems assigned to a named phase.

```lua
-- signature
LUniverse:updatePhase(phase, dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `phase` | `string` | System phase name to run. |
| `dt` | `number` | Frame delta time in seconds. |

**Example**

```lua
do
    local uni = lurek.ecs.newUniverse()
    local ran = false
    uni:addSystem({update = function() ran = true end}, {phase = "physics"})
    uni:updatePhase("physics", 1 / 60)
    print("phase ran = " .. tostring(ran))
end
```

---
