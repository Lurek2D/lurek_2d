# Ecs

## Purpose

Manages an Entity-Component-System database with generational IDs. - Supports hierarchies, relationships, phase-aware systems, and snapshots. - Provides a global Lua class/object registry for richer object-oriented gameplay models when plain tables are not enough. - Bridges class-backed objects into LUniverse entities without replacing component storage or query APIs.

## Summary

- The `ecs` module is the engine's entity-component world model for users who want gameplay state to scale through entities, components, queries, and scheduled systems.
- Its core value is separation of identity from data. Entities provide stable handles, components hold structured state, and systems or queries interpret that state without forcing one rigid object hierarchy.
- Generational handles, dynamic component attachment, tags, layers, and relationships make the model practical for varied world populations such as actors, props, projectiles, and temporary runtime markers.
- Query views and dirty tracking are especially important because downstream systems need efficient access to exactly the slices of world state they care about.
- Blueprints, bulk spawning, snapshots, and serialization broaden the module from live simulation into save/load, rollback, reset, and data-driven population workflows.
- Hierarchy and relationship support matter because game worlds are rarely flat; parent-child links, semantic grouping, and layered ownership all need to remain queryable as the world grows.
- The module also improves feature isolation, because several systems can share the same entities without collapsing their state into one oversized object model.
- That makes the ECS world a stable meeting point for subsystems that need different views of the same population.
- The class/object registry is intentionally part of `ecs` because it is foundational object identity and type metadata, not a reusable gameplay pattern. It gives Lua developers inheritance, mixin-style multi-inheritance, defaults, methods, properties, constructors, tags, and a live object registry inside the same VM.
- Objects created through `lurek.ecs.newObject` remain ordinary Lua tables, but they carry metatable-backed class behavior plus helper methods such as `type`, `typeOf`, `isA`, `getProperty`, and `setProperty`.
- `LUniverse:spawnObject` and `LUniverse:attachObject` are bridge APIs: they attach an object table to an entity as data so ECS systems can still query and compose it with ordinary components.
- The model is especially strong when many systems need partial views of the same population without inheriting each other's update logic.
- That shared world model keeps those views aligned.
- The ECS world becomes a shared substrate for other systems, but `ecs` owns its organization.
- Read `ecs` as the authority for entity identity, component storage, queries, and shared world composition.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.ecs.classNames`

Returns all global ECS class names in deterministic order.

```lua
lurek.ecs.classNames()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Registered class names. |

**Example**

```lua
do

    lurek.ecs.clearClasses()
    lurek.ecs.defineClass("ClassListA", {})
    lurek.ecs.defineClass("ClassListB", {})
    local names = lurek.ecs.classNames()
    lurek.log.info("classNames count=" .. tostring(#names) .. " first=" .. tostring(names[1]))
end
```

---

### `lurek.ecs.clearClasses`

Removes every global ECS class definition.

```lua
lurek.ecs.clearClasses()
```

**Example**

```lua
do

    lurek.ecs.defineClass("TemporaryClass", {})
    local before = lurek.ecs.hasClass("TemporaryClass")
    lurek.ecs.clearClasses()
    local after = lurek.ecs.hasClass("TemporaryClass")
    lurek.log.info("clearClasses before=" .. tostring(before) .. " after=" .. tostring(after))
end
```

---

### `lurek.ecs.clearObjects`

Removes every live ECS object while keeping class definitions.

```lua
lurek.ecs.clearObjects()
```

**Example**

```lua
do

    lurek.ecs.clearObjects()
    lurek.ecs.clearClasses()
    lurek.ecs.defineClass("ClearObjectsProbe", {})
    lurek.ecs.newObject("ClearObjectsProbe")
    lurek.ecs.clearObjects()
    lurek.log.info("clearObjects count=" .. tostring(#lurek.ecs.objectIds()))
end
```

---

### `lurek.ecs.defineClass`

Defines or replaces a global ECS class for Lua object instances.

```lua
lurek.ecs.defineClass(name, def)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Class name used by `newObject` and `[LUniverse](#luniverse):spawnObject`. |
| `def` | table | Class definition with optional extends, defaults, methods, properties, constructor, and tags. |

**Example**

```lua
do

    lurek.ecs.clearObjects()
    lurek.ecs.clearClasses()
    lurek.ecs.defineClass("GameObject", { defaults = { alive = true }, tags = { "base" } })
    lurek.ecs.defineClass("Projectile", { extends = "GameObject", defaults = { speed = 360 } })
    lurek.ecs.defineClass("EnemyBullet", { extends = { "Projectile" }, defaults = { damage = 2 } })
    lurek.log.info("defined EnemyBullet class=" .. tostring(lurek.ecs.hasClass("EnemyBullet")))
end
```

---

### `lurek.ecs.destroyObject`

Removes a live ECS object from the global object registry.

```lua
lurek.ecs.destroyObject(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Object id to destroy. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when an object was removed. |

**Example**

```lua
do

    lurek.ecs.clearObjects()
    lurek.ecs.clearClasses()
    lurek.ecs.defineClass("DestroyObject", {})
    local obj = lurek.ecs.newObject("DestroyObject")
    local removed = lurek.ecs.destroyObject(obj.__id)
    lurek.log.info("destroyObject removed=" .. tostring(removed) .. " live=" .. tostring(lurek.ecs.hasObject(obj.__id)))
end
```

---

### `lurek.ecs.getClass`

Returns metadata for a global ECS class.

```lua
lurek.ecs.getClass(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Class name to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| table | Metadata table with name, extends, and tags; nil when unknown. |

**Example**

```lua
do

    lurek.ecs.clearClasses()
    lurek.ecs.defineClass("ClassInfoProbe", { tags = { "enemy", "air" } })
    local info = lurek.ecs.getClass("ClassInfoProbe")
    local tag = info and info.tags and info.tags[1] or "none"
    lurek.log.info("getClass name=" .. tostring(info and info.name) .. " tag=" .. tostring(tag))
end
```

---

### `lurek.ecs.getObject`

Returns a live ECS object table by object id.

```lua
lurek.ecs.getObject(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Object id returned in the object's `__id` field. |

**Returns**

| Type | Description |
|------|-------------|
| table | Object table, or nil when not found. |

**Example**

```lua
do

    lurek.ecs.clearObjects()
    lurek.ecs.clearClasses()
    lurek.ecs.defineClass("LookupObject", {})
    local obj = lurek.ecs.newObject("LookupObject")
    local same = lurek.ecs.getObject(obj.__id) == obj
    lurek.log.info("getObject id=" .. tostring(obj.__id) .. " same=" .. tostring(same))
end
```

---

### `lurek.ecs.getProperty`

Returns the current value of one object property, honoring any registered getter override first.

```lua
lurek.ecs.getProperty(self, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `self` | LObject | Object table that owns the property. |
| `name` | string | Property name to read from the object or its property metadata table. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Current property value, getter result, or `nil` when the property is unset. |

**Example**

```lua
do

    lurek.ecs.clearObjects()
    lurek.ecs.clearClasses()
    lurek.ecs.defineClass("PropertyReadExample", { properties = { hp = 10, speed = 6 } })
    local obj = lurek.ecs.newObject("PropertyReadExample")
    local hp = obj:getProperty("hp")
    lurek.log.info("getProperty hp=" .. tostring(hp) .. " speed=" .. tostring(obj:getProperty("speed")))
end
```

---

### `lurek.ecs.hasClass`

Returns whether a global ECS class name is defined.

```lua
lurek.ecs.hasClass(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Class name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the class exists. |

**Example**

```lua
do

    lurek.ecs.clearClasses()
    lurek.ecs.defineClass("HasClassProbe", { defaults = { hp = 1 } })
    local present = lurek.ecs.hasClass("HasClassProbe")
    local missing = lurek.ecs.hasClass("MissingClass")
    lurek.log.info("hasClass present=" .. tostring(present) .. " missing=" .. tostring(missing))
end
```

---

### `lurek.ecs.hasObject`

Returns whether a live ECS object id exists.

```lua
lurek.ecs.hasObject(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Object id to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the object id is live. |

**Example**

```lua
do

    lurek.ecs.clearObjects()
    lurek.ecs.clearClasses()
    lurek.ecs.defineClass("LiveObject", {})
    local obj = lurek.ecs.newObject("LiveObject")
    lurek.log.info("hasObject live=" .. tostring(lurek.ecs.hasObject(obj.__id)) .. " missing=" .. tostring(lurek.ecs.hasObject(999999)))
end
```

---

### `lurek.ecs.isA`

Returns whether this object inherits from or matches the supplied ECS class name.

```lua
lurek.ecs.isA(self, candidate)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `self` | LObject | Object table to inspect. |
| `candidate` | string | ECS class name to compare against the object's registered class hierarchy. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the object class matches or extends the supplied class. |

**Example**

```lua
do

    lurek.ecs.clearObjects()
    lurek.ecs.clearClasses()
    lurek.ecs.defineClass("ActorExampleObject", {})
    lurek.ecs.defineClass("EnemyExampleObject", { extends = "ActorExampleObject" })
    local obj = lurek.ecs.newObject("EnemyExampleObject")
    lurek.log.info("object isA actor=" .. tostring(obj:isA("ActorExampleObject")) .. " enemy=" .. tostring(obj:isA("EnemyExampleObject")))
end
```

---

### `lurek.ecs.newLoadout`

Creates a modular loadout from optional slot definitions and base stats.

```lua
lurek.ecs.newLoadout(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | Options: slots array of [LSlotDef](#lslotdef), baseStats table. |

**Returns**

| Type | Description |
|------|-------------|
| [LLoadout](#lloadout) | New loadout handle. |

**Example**

```lua
do
    local slot = lurek.ecs.newSlotDef("arm", { accepts = { "weapon" } })
    local loadout = lurek.ecs.newLoadout({ slots = { slot } })
    local component = loadout:toComponent()
    local valid = loadout:validate()
    local slots = component.slots or {}
    lurek.log.info("loadout type=" .. loadout:type() .. " slots=" .. tostring(#slots) .. " valid=" .. tostring(valid.valid))
end
```

---

### `lurek.ecs.newObject`

Creates a Lua table object from a registered ECS class.

```lua
lurek.ecs.newObject(className, props)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `className` | string | Registered class name. |
| `props?` | table | Optional property overrides. |

**Returns**

| Type | Description |
|------|-------------|
| table | Object table with type, typeOf, isA, getProperty, and setProperty methods. |

**Example**

```lua
do

    lurek.ecs.clearObjects()
    lurek.ecs.clearClasses()
    lurek.ecs.defineClass("Damageable", { properties = { hp = 10 } })
    local obj = lurek.ecs.newObject("Damageable", { name = "boss_part" })
    obj:setProperty("hp", 7)
    lurek.log.info("newObject type=" .. obj:type() .. " hp=" .. tostring(obj:getProperty("hp")))
end
```

---

### `lurek.ecs.newPartDef`

Creates a modular loadout part definition.

```lua
lurek.ecs.newPartDef(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | Part options: id/name, slot, tags, stats, cost, mass, energy, heat, armor, hardpoints, visuals. |

**Returns**

| Type | Description |
|------|-------------|
| [LPartDef](#lpartdef) | New part definition handle. |

**Example**

```lua
do
    local part = lurek.ecs.newPartDef({ id = "laser_arm", slot = "arm", tags = { "weapon" }, stats = { firepower = 4 }, cost = 25 })
    local tags = part:getTags()
    local stats = part:getStats()
    local cost = part:getCost()
    lurek.log.info("part=" .. part:getId() .. " slot=" .. part:getSlot() .. " tag=" .. tostring(tags[1]) .. " firepower=" .. tostring(stats.firepower) .. " cost=" .. tostring(cost))
end
```

---

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
    lurek.log.info("relationship manager level=" .. tostring(level) .. " score=" .. tostring(score) .. " pairs=" .. tostring(rm:pairCount()))
end
```

---

### `lurek.ecs.newSlotDef`

Creates a modular loadout slot definition.

```lua
lurek.ecs.newSlotDef(name, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Slot name. |
| `opts?` | table | Options: accepts string/string[], required boolean, hardpoint string. |

**Returns**

| Type | Description |
|------|-------------|
| [LSlotDef](#lslotdef) | New slot definition handle. |

**Example**

```lua
do
    local slot = lurek.ecs.newSlotDef("arm", { accepts = { "weapon" }, required = true, hardpoint = "left" })
    local accepts = slot:getAccepts()
    local required = slot:isRequired()
    local hardpoint = slot:getHardpoint()
    lurek.log.info("slot=" .. slot:getName() .. " accepts=" .. tostring(accepts[1]) .. " required=" .. tostring(required) .. " hardpoint=" .. tostring(hardpoint))
end
```

---

### `lurek.ecs.newStatBlock`

Creates a standalone stat block from a plain table.

```lua
lurek.ecs.newStatBlock(stats)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `stats?` | table | Optional stat key-value table. |

**Returns**

| Type | Description |
|------|-------------|
| [LStatBlock](#lstatblock) | New stat block handle. |

**Example**

```lua
do
    local stats = lurek.ecs.newStatBlock({ speed = 10 })
    stats:add("speed", 2)
    local value = stats:get("speed")
    local table_value = stats:toTable().speed
    lurek.log.info("stat block speed=" .. tostring(value) .. " table=" .. tostring(table_value))
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
    lurek.log.info("universe created count=" .. tostring(count) .. " first_id=" .. tostring(entities[1]) .. " hero_name=" .. tostring(uni:get(hero, "name")))
end
```

---

### `lurek.ecs.objectIds`

Returns all live ECS object ids in ascending order.

```lua
lurek.ecs.objectIds()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Object ids. |

**Example**

```lua
do

    lurek.ecs.clearObjects()
    lurek.ecs.clearClasses()
    lurek.ecs.defineClass("ListedObject", {})
    local obj = lurek.ecs.newObject("ListedObject")
    local ids = lurek.ecs.objectIds()
    lurek.log.info("objectIds count=" .. tostring(#ids) .. " first=" .. tostring(ids[1]) .. " object=" .. tostring(obj.__id))
end
```

---

### `lurek.ecs.setProperty`

Writes one object property, delegating to a registered setter override when the property defines one.

```lua
lurek.ecs.setProperty(self, name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `self` | LObject | Object table that owns the property. |
| `name` | string | Property name to update on the object table. |
| `value` | any | New Lua value written directly or passed through the property's setter. |

**Example**

```lua
do

    lurek.ecs.clearObjects()
    lurek.ecs.clearClasses()
    lurek.ecs.defineClass("PropertyWriteExample", { properties = { hp = 10 } })
    local obj = lurek.ecs.newObject("PropertyWriteExample")
    obj:setProperty("hp", 4)
    lurek.log.info("setProperty hp=" .. tostring(obj:getProperty("hp")) .. " direct=" .. tostring(obj.hp))
end
```

---

### `lurek.ecs.type`

Returns the registered ECS class name for this object table.

```lua
lurek.ecs.type(self)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `self` | LObject | Object table to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| string | Class name assigned when the object was created. |

**Example**

```lua
do

    lurek.ecs.clearObjects()
    lurek.ecs.clearClasses()
    lurek.ecs.defineClass("TypedExampleObject", {})
    local obj = lurek.ecs.newObject("TypedExampleObject")
    lurek.log.info("object type=" .. tostring(obj:type()) .. " id=" .. tostring(obj.__id))
end
```

---

### `lurek.ecs.typeOf`

Returns whether this object matches a supported Lua-visible type or ECS class name.

```lua
lurek.ecs.typeOf(self, candidate)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `self` | LObject | Object table to inspect. |
| `candidate` | string | Type or class name to compare against `LObject` and the object's ECS class hierarchy. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied name matches `LObject` or the object's class ancestry. |

**Example**

```lua
do

    lurek.ecs.clearObjects()
    lurek.ecs.clearClasses()
    lurek.ecs.defineClass("BaseExampleObject", {})
    lurek.ecs.defineClass("DerivedExampleObject", { extends = "BaseExampleObject" })
    local obj = lurek.ecs.newObject("DerivedExampleObject")
    lurek.log.info("object typeOf base=" .. tostring(obj:typeOf("BaseExampleObject")) .. " object=" .. tostring(obj:typeOf("LObject")))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LLoadout](#lloadout)
- [LPartDef](#lpartdef)
- [LQueryView](#lqueryview)
- [LRelationshipManager](#lrelationshipmanager)
- [LSlotDef](#lslotdef)
- [LStatBlock](#lstatblock)
- [LUniverse](#luniverse)

## LLoadout

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LLoadout:addSlot`

Adds or replaces one slot definition on this loadout.

```lua
LLoadout:addSlot(slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | [LSlotDef](#lslotdef) | Slot definition to add. |

**Example**

```lua
do
    local loadout = lurek.ecs.newLoadout()
    local slot = lurek.ecs.newSlotDef("arm", { accepts = { "weapon" } })
    loadout:addSlot(slot)
    local component = loadout:toComponent()
    local slots = component.slots or {}
    lurek.log.info("loadout slots after add=" .. tostring(#slots))
end
```

---

#### `LLoadout:computeStats`

Computes final additive stats from base stats and equipped parts.

```lua
LLoadout:computeStats()
```

**Returns**

| Type | Description |
|------|-------------|
| [LStatBlock](#lstatblock) | Derived stat block. |

**Example**

```lua
do
    local slot = lurek.ecs.newSlotDef("arm", { accepts = { "weapon" } })
    local part = lurek.ecs.newPartDef({ id = "laser_arm", slot = "arm", tags = { "weapon" }, stats = { firepower = 4, speed = -1 } })
    local loadout = lurek.ecs.newLoadout({ slots = { slot }, baseStats = lurek.ecs.newStatBlock({ speed = 10 }) })
    loadout:equip(part)
    lurek.log.info("loadout speed=" .. tostring(loadout:computeStats():get("speed")))
end
```

---

#### `LLoadout:equip`

Equips a part into a named slot after compatibility checks.

```lua
LLoadout:equip(slot, part)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Slot name. |
| `part` | [LPartDef](#lpartdef) | Part definition to equip. |

**Example**

```lua
do
    local slot = lurek.ecs.newSlotDef("arm", { accepts = { "weapon" } })
    local part = lurek.ecs.newPartDef({ id = "laser_arm", slot = "arm", tags = { "weapon" } })
    local loadout = lurek.ecs.newLoadout({ slots = { slot } })
    local equipped = loadout:equip(part)
    lurek.log.info("loadout equipped=" .. tostring(equipped) .. " cost=" .. tostring(loadout:getCost()))
end
```

---

#### `LLoadout:getCost`

Returns total cost of equipped parts.

```lua
LLoadout:getCost()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total equipped cost. |

**Example**

```lua
do
    local slot = lurek.ecs.newSlotDef("arm", { accepts = { "weapon" } })
    local part = lurek.ecs.newPartDef({ id = "laser_arm", slot = "arm", tags = { "weapon" }, cost = 25 })
    local loadout = lurek.ecs.newLoadout({ slots = { slot } })
    loadout:equip(part)
    lurek.log.info("loadout cost=" .. tostring(loadout:getCost()))
end
```

---

#### `LLoadout:getHardpoints`

Returns slot and part hardpoints exposed by this loadout.

```lua
LLoadout:getHardpoints()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Hardpoint names. |

**Example**

```lua
do
    local slot = lurek.ecs.newSlotDef("arm", { accepts = { "weapon" } })
    local part = lurek.ecs.newPartDef({ id = "laser_arm", slot = "arm", tags = { "weapon" }, hardpoints = { "muzzle" } })
    local loadout = lurek.ecs.newLoadout({ slots = { slot } })
    loadout:equip(part)
    lurek.log.info("loadout hardpoint=" .. tostring(loadout:getHardpoints()[1]))
end
```

---

#### `LLoadout:toComponent`

Returns a plain ECS component table with stats, hardpoints, cost, and equipped part ids.

```lua
LLoadout:toComponent()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Component table suitable for `[LUniverse](#luniverse):set`. |

**Example**

```lua
do
    local slot = lurek.ecs.newSlotDef("arm", { accepts = { "weapon" } })
    local part = lurek.ecs.newPartDef({ id = "laser_arm", slot = "arm", tags = { "weapon" } })
    local loadout = lurek.ecs.newLoadout({ slots = { slot } })
    loadout:equip(part)
    local component = loadout:toComponent()
    local slots = component.slots or {}
    lurek.log.info("loadout component slots=" .. tostring(#slots))
end
```

---

#### `LLoadout:type`

Returns the Lua-visible type name for this loadout.

```lua
LLoadout:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LLoadout](#lloadout)`. |

**Example**

```lua
do
    local slot = lurek.ecs.newSlotDef("arm", { accepts = { "weapon" } })
    local loadout = lurek.ecs.newLoadout({ slots = { slot } })
    local type_name = loadout:type()
    local component = loadout:toComponent()
    local slots = component.slots or {}
    lurek.log.info("loadout type=" .. tostring(type_name) .. " slots=" .. tostring(#slots))
end
```

---

#### `LLoadout:typeOf`

Returns whether this handle matches a supported type name.

```lua
LLoadout:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True for `[LLoadout](#lloadout)` or `LObject`. |

**Example**

```lua
do
    local slot = lurek.ecs.newSlotDef("arm", { accepts = { "weapon" } })
    local loadout = lurek.ecs.newLoadout({ slots = { slot } })
    local exact = loadout:typeOf("LLoadout")
    local base = loadout:typeOf("LObject")
    lurek.log.info("loadout typeOf exact=" .. tostring(exact) .. " base=" .. tostring(base))
end
```

---

#### `LLoadout:unequip`

Removes the part currently equipped in one slot.

```lua
LLoadout:unequip(slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Slot name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a part was removed. |

**Example**

```lua
do
    local slot = lurek.ecs.newSlotDef("arm", { accepts = { "weapon" } })
    local part = lurek.ecs.newPartDef({ id = "laser_arm", slot = "arm", tags = { "weapon" } })
    local loadout = lurek.ecs.newLoadout({ slots = { slot } })
    loadout:equip(part)
    lurek.log.info("loadout unequipped=" .. tostring(loadout:unequip("arm")))
end
```

---

#### `LLoadout:validate`

Returns validation errors for missing or incompatible equipment.

```lua
LLoadout:validate()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Validation errors. Empty means the loadout is valid. |

**Example**

```lua
do
    local slot = lurek.ecs.newSlotDef("arm", { accepts = { "weapon" }, required = true })
    local part = lurek.ecs.newPartDef({ id = "laser_arm", slot = "arm", tags = { "weapon" } })
    local loadout = lurek.ecs.newLoadout({ slots = { slot } })
    loadout:equip(part)
    lurek.log.info("loadout valid=" .. tostring(loadout:validate().valid))
end
```

---

## LPartDef

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LPartDef:getCost`

Returns the part cost value.

```lua
LPartDef:getCost()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Part cost. |

**Example**

```lua
do
    local part = lurek.ecs.newPartDef({ id = "laser_arm", slot = "arm", cost = 25 })
    local cost = part:getCost()
    local id = part:getId()
    local slot = part:getSlot()
    lurek.log.info("part cost=" .. tostring(cost) .. " id=" .. tostring(id) .. " slot=" .. tostring(slot))
end
```

---

#### `LPartDef:getHardpoints`

Returns hardpoints exposed by this part.

```lua
LPartDef:getHardpoints()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Hardpoint names. |

**Example**

```lua
do
    local part = lurek.ecs.newPartDef({ id = "laser_arm", slot = "arm", hardpoints = { "muzzle" } })
    local hardpoints = part:getHardpoints()
    local first = hardpoints[1]
    local id = part:getId()
    lurek.log.info("part hardpoint=" .. tostring(first) .. " id=" .. tostring(id))
end
```

---

#### `LPartDef:getId`

Returns the stable part id.

```lua
LPartDef:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Part id. |

**Example**

```lua
do
    local part = lurek.ecs.newPartDef({ id = "laser_arm", slot = "arm", tags = { "weapon" } })
    local id = part:getId()
    local slot = part:getSlot()
    local tags = part:getTags()
    lurek.log.info("part id=" .. tostring(id) .. " slot=" .. tostring(slot) .. " tag=" .. tostring(tags[1]))
end
```

---

#### `LPartDef:getSlot`

Returns the preferred slot name.

```lua
LPartDef:getSlot()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Slot name, or empty string when unrestricted. |

**Example**

```lua
do
    local part = lurek.ecs.newPartDef({ id = "laser_arm", slot = "arm", tags = { "weapon" } })
    local slot = part:getSlot()
    local id = part:getId()
    local tags = part:getTags()
    lurek.log.info("part slot=" .. tostring(slot) .. " id=" .. tostring(id) .. " tag=" .. tostring(tags[1]))
end
```

---

#### `LPartDef:getStats`

Returns additive stat modifiers as a plain table.

```lua
LPartDef:getStats()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Stat key-value table. |

**Example**

```lua
do
    local part = lurek.ecs.newPartDef({ id = "laser_arm", slot = "arm", stats = { firepower = 4, speed = -1 } })
    local stats = part:getStats()
    local firepower = stats.firepower
    local speed = stats.speed
    lurek.log.info("part stats firepower=" .. tostring(firepower) .. " speed=" .. tostring(speed))
end
```

---

#### `LPartDef:getTags`

Returns compatibility tags.

```lua
LPartDef:getTags()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Part tags. |

**Example**

```lua
do
    local part = lurek.ecs.newPartDef({ id = "laser_arm", slot = "arm", tags = { "weapon", "energy" } })
    local tags = part:getTags()
    local first = tags[1]
    local second = tags[2]
    lurek.log.info("part tags first=" .. tostring(first) .. " second=" .. tostring(second))
end
```

---

#### `LPartDef:getVisuals`

Returns visual attachment mapping for this part.

```lua
LPartDef:getVisuals()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Visual slot mapping. |

**Example**

```lua
do
    local part = lurek.ecs.newPartDef({ id = "laser_arm", slot = "arm", visuals = { arm = "laser_sprite" } })
    local visuals = part:getVisuals()
    local sprite = visuals.arm
    local id = part:getId()
    lurek.log.info("part visual=" .. tostring(sprite) .. " id=" .. tostring(id))
end
```

---

#### `LPartDef:type`

Returns the Lua-visible type name for this part definition.

```lua
LPartDef:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LPartDef](#lpartdef)`. |

**Example**

```lua
do
    local part = lurek.ecs.newPartDef({ id = "laser_arm", slot = "arm" })
    local type_name = part:type()
    local id = part:getId()
    local slot = part:getSlot()
    lurek.log.info("part type=" .. tostring(type_name) .. " id=" .. tostring(id) .. " slot=" .. tostring(slot))
end
```

---

#### `LPartDef:typeOf`

Returns whether this handle matches a supported type name.

```lua
LPartDef:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True for `[LPartDef](#lpartdef)` or `LObject`. |

**Example**

```lua
do
    local part = lurek.ecs.newPartDef({ id = "laser_arm", slot = "arm" })
    local exact = part:typeOf("LPartDef")
    local base = part:typeOf("LObject")
    local miss = part:typeOf("LSlotDef")
    lurek.log.info("part typeOf exact=" .. tostring(exact) .. " base=" .. tostring(base) .. " miss=" .. tostring(miss))
end
```

---

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
    lurek.log.info(tostring("cached ids = " .. #view:ids()))
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
    lurek.log.info(tostring("view tick = " .. tostring(view:lastTick())))
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
    lurek.log.info(tostring("query view type = " .. view:type()))
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
    lurek.log.info(tostring("is query view = " .. tostring(view:typeOf("LQueryView"))))
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
    lurek.log.info(tostring("1->2 = " .. rm:getValue(1, 2)))
    lurek.log.info(tostring("pairs = " .. rm:pairCount()))
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
    lurek.log.info("defined relationship types count=" .. tostring(#types) .. " first=" .. tostring(first) .. " second=" .. tostring(second))
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
    lurek.log.info(tostring("level = " .. tostring(rm:getLevel(1, 2, "friendship"))))
    lurek.log.info(tostring("types = " .. #rm:typeNames()))
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
    lurek.log.info(tostring("1->2 = " .. rm:getValue(1, 2)))
    lurek.log.info(tostring("1->3 = " .. rm:getValue(1, 3)))
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
    lurek.log.info(tostring("pairs = " .. rm:pairCount()))
    lurek.log.info(tostring("level = " .. tostring(rm:getLevel(1, 2, "friendship"))))
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
    lurek.log.info(tostring("before = " .. rm:pairCount()))
    rm:removePair(1, 3)
    lurek.log.info(tostring("after = " .. rm:pairCount()))
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
    lurek.log.info(tostring("before = " .. #rm:typeNames()))
    rm:removeType("friendship")
    lurek.log.info(tostring("after = " .. #rm:typeNames()))
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
    lurek.log.info(tostring("level = " .. tostring(rm:getLevel(1, 2, "friendship"))))
    lurek.log.info(tostring("pairs = " .. rm:pairCount()))
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
    lurek.log.info(tostring("1->2 = " .. rm:getValue(1, 2)))
    lurek.log.info(tostring("1->3 = " .. rm:getValue(1, 3)))
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
    lurek.log.info("relationship manager type=" .. tostring(type_name) .. " is_rm=" .. tostring(is_rm) .. " type_count=" .. tostring(type_count))
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
    lurek.log.info(tostring("types = " .. #types))
    lurek.log.info(tostring("first = " .. tostring(types[1])))
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
    lurek.log.info("relationship manager type guard rm=" .. tostring(is_relationship_manager) .. " object=" .. tostring(is_object) .. " universe=" .. tostring(is_universe))
end
```

---

## LSlotDef

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSlotDef:getAccepts`

Returns accepted compatibility tags.

```lua
LSlotDef:getAccepts()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Accepted tags. |

**Example**

```lua
do
    local slot = lurek.ecs.newSlotDef("arm", { accepts = { "weapon", "tool" }, required = true })
    local accepts = slot:getAccepts()
    local first = accepts[1]
    local second = accepts[2]
    lurek.log.info("slot accepts first=" .. tostring(first) .. " second=" .. tostring(second))
end
```

---

#### `LSlotDef:getHardpoint`

Returns the slot hardpoint name when one is configured.

```lua
LSlotDef:getHardpoint()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Hardpoint name, or nil. |

**Example**

```lua
do
    local slot = lurek.ecs.newSlotDef("arm", { accepts = { "weapon" }, hardpoint = "left" })
    local hardpoint = slot:getHardpoint()
    local name = slot:getName()
    local required = slot:isRequired()
    lurek.log.info("slot hardpoint=" .. tostring(hardpoint) .. " name=" .. tostring(name) .. " required=" .. tostring(required))
end
```

---

#### `LSlotDef:getName`

Returns the slot name.

```lua
LSlotDef:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Slot name. |

**Example**

```lua
do
    local slot = lurek.ecs.newSlotDef("arm", { accepts = { "weapon" }, required = true, hardpoint = "left" })
    local name = slot:getName()
    local accepts = slot:getAccepts()
    local required = slot:isRequired()
    lurek.log.info("slot name=" .. tostring(name) .. " accepts=" .. tostring(accepts[1]) .. " required=" .. tostring(required))
end
```

---

#### `LSlotDef:isRequired`

Returns whether this slot is required during loadout validation.

```lua
LSlotDef:isRequired()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when required. |

**Example**

```lua
do
    local slot = lurek.ecs.newSlotDef("arm", { accepts = { "weapon" }, required = true })
    local required = slot:isRequired()
    local name = slot:getName()
    local accepts = slot:getAccepts()
    lurek.log.info("slot required=" .. tostring(required) .. " name=" .. tostring(name) .. " accepts=" .. tostring(accepts[1]))
end
```

---

#### `LSlotDef:type`

Returns the Lua-visible type name for this slot definition.

```lua
LSlotDef:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LSlotDef](#lslotdef)`. |

**Example**

```lua
do
    local slot = lurek.ecs.newSlotDef("arm", { accepts = { "weapon" } })
    local type_name = slot:type()
    local name = slot:getName()
    local accepts = slot:getAccepts()
    lurek.log.info("slot type=" .. tostring(type_name) .. " name=" .. tostring(name) .. " accepts=" .. tostring(accepts[1]))
end
```

---

#### `LSlotDef:typeOf`

Returns whether this handle matches a supported type name.

```lua
LSlotDef:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True for `[LSlotDef](#lslotdef)` or `LObject`. |

**Example**

```lua
do
    local slot = lurek.ecs.newSlotDef("arm", { accepts = { "weapon" } })
    local exact = slot:typeOf("LSlotDef")
    local base = slot:typeOf("LObject")
    local miss = slot:typeOf("LPartDef")
    lurek.log.info("slot typeOf exact=" .. tostring(exact) .. " base=" .. tostring(base) .. " miss=" .. tostring(miss))
end
```

---

## LStatBlock

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LStatBlock:add`

Adds a numeric delta to one stat.

```lua
LStatBlock:add(name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Stat key. |
| `value` | number | Finite delta to add. |

**Example**

```lua
do
    local stats = lurek.ecs.newStatBlock({ armor = 2 })
    stats:add("armor", 1)
    stats:add("speed", 4)
    local armor = stats:get("armor")
    lurek.log.info("added armor=" .. tostring(armor) .. " speed=" .. tostring(stats:get("speed")))
end
```

---

#### `LStatBlock:get`

Returns one stat value, or zero when the key is absent.

```lua
LStatBlock:get(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Stat key. |

**Returns**

| Type | Description |
|------|-------------|
| number | Stat value. |

**Example**

```lua
do
    local stats = lurek.ecs.newStatBlock({ armor = 3 })
    local armor = stats:get("armor")
    local missing = stats:get("missing")
    local table_value = stats:toTable().armor
    lurek.log.info("armor=" .. tostring(armor) .. " missing=" .. tostring(missing) .. " table=" .. tostring(table_value))
end
```

---

#### `LStatBlock:set`

Replaces one stat value.

```lua
LStatBlock:set(name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Stat key. |
| `value` | number | Finite stat value. |

**Example**

```lua
do
    local stats = lurek.ecs.newStatBlock()
    stats:set("armor", 2)
    local armor = stats:get("armor")
    stats:set("speed", 10)
    lurek.log.info("set armor=" .. tostring(armor) .. " speed=" .. tostring(stats:get("speed")))
end
```

---

#### `LStatBlock:toTable`

Returns all stat values as a plain Lua table.

```lua
LStatBlock:toTable()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Key-value stat table. |

**Example**

```lua
do
    local stats = lurek.ecs.newStatBlock({ firepower = 4, speed = 9 })
    local values = stats:toTable()
    local firepower = values.firepower
    local speed = values.speed
    lurek.log.info("stat table firepower=" .. tostring(firepower) .. " speed=" .. tostring(speed))
end
```

---

#### `LStatBlock:type`

Returns the Lua-visible type name for this stat block.

```lua
LStatBlock:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LStatBlock](#lstatblock)`. |

**Example**

```lua
do
    local stats = lurek.ecs.newStatBlock()
    local type_name = stats:type()
    local value = stats:get("missing")
    local table_values = stats:toTable()
    lurek.log.info("stat type=" .. tostring(type_name) .. " missing=" .. tostring(value) .. " size=" .. tostring(#table_values))
end
```

---

#### `LStatBlock:typeOf`

Returns whether this handle matches a supported type name.

```lua
LStatBlock:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True for `[LStatBlock](#lstatblock)` or `LObject`. |

**Example**

```lua
do
    local stats = lurek.ecs.newStatBlock()
    local exact = stats:typeOf("LStatBlock")
    local base = stats:typeOf("LObject")
    local miss = stats:typeOf("LLoadout")
    lurek.log.info("stat typeOf exact=" .. tostring(exact) .. " base=" .. tostring(base) .. " miss=" .. tostring(miss))
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
    lurek.log.info(tostring("relation added"))
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
    lurek.log.info("systems registered count=" .. tostring(count) .. " query_tick=" .. tostring(uni:getQueryChangeTick()))
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
    lurek.log.info(tostring(u:hasTag(e, "enemy")))
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
    lurek.log.info(tostring("entities after apply = " .. u:getEntityCount()))
end
```

---

#### `LUniverse:attachObject`

Attaches an existing ECS object table to an entity as the `object` component.

```lua
LUniverse:attachObject(entityId, obj)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `entityId` | number | Entity id that receives the object. |
| `obj` | table | Object table returned by `lurek.ecs.newObject`. |

**Example**

```lua
do

    lurek.ecs.clearObjects()
    lurek.ecs.clearClasses()
    lurek.ecs.defineClass("AttachedObject", { defaults = { team = "enemy" } })
    local obj = lurek.ecs.newObject("AttachedObject")
    local world = lurek.ecs.newUniverse()
    local entity = world:spawn()
    world:attachObject(entity, obj)
    lurek.log.info("attachObject entity=" .. tostring(entity) .. " objectId=" .. tostring(world:get(entity, "objectId")) .. " team=" .. tostring(world:get(entity, "object").team))
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
    lurek.log.info(tostring(u:hasBitmapTag(e, "enemy")))
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
    lurek.log.info(tostring(u:hasBitmapTag(e, "enemy")))
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
    lurek.log.info("clear world before=" .. tostring(before) .. " after=" .. tostring(after) .. " old_entity_alive=" .. tostring(alive))
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
    lurek.log.info(tostring("after clear = " .. #targets))
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
    lurek.log.info("blueprint enemy defined hp=" .. tostring(comps.hp.value) .. " spawned=" .. tostring(spawned) .. " live_hp=" .. tostring(hp.value))
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
    lurek.log.info(tostring(u:hasTag(e, "enemy")))
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
    lurek.log.info(tostring("deserialized, count = " .. uni:getEntityCount()))
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
        lurek.log.info(tostring("visited entity = " .. tostring(entity_id)))
        lurek.log.info(tostring("name.value = " .. tostring(name_value.value)))
    end)
    lurek.log.info(tostring("each count = " .. count))
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
    lurek.log.info(tostring("emit received = " .. tostring(got)))
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
    lurek.log.info("extended blueprint exists=" .. tostring(u:hasBlueprint("enemy")) .. " hp=" .. tostring(hp) .. " damage=" .. tostring(damage))
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
    lurek.log.info("observers flushed fired=" .. tostring(fired) .. " entity=" .. tostring(id) .. " dirty=" .. tostring(#uni:getDirtyEntities()))
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
    lurek.log.info(tostring("hp.value = " .. tostring(hp.value)))
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
    lurek.log.info("bitmap tag bit defined=" .. tostring(bit) .. " queried=" .. tostring(queried_bit) .. " has_tag=" .. tostring(has_tag))
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
    lurek.log.info(tostring("blueprint comps type = " .. type(comps)))
    lurek.log.info(tostring("damage = " .. tostring(comps.damage.value)))
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
    lurek.log.info(tostring("children = " .. #children))
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
    lurek.log.info(tostring("components = " .. #names))
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
    lurek.log.info(tostring("dirty = " .. #dirty))
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
    lurek.log.info(tostring("entities = " .. #all))
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
    lurek.log.info("entities by layer count=" .. tostring(#ids) .. " first_layer_two=" .. tostring(ids[1]) .. " sorted_first=" .. tostring(sorted[1]))
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
    lurek.log.info(tostring(#u:getEntitiesByTag("unit")))
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
    lurek.log.info("sorted entities count=" .. tostring(#sorted) .. " first=" .. tostring(first) .. " second=" .. tostring(second))
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
    lurek.log.info(tostring("count = " .. uni:getEntityCount()))
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
    lurek.log.info("entity layer=" .. tostring(layer) .. " same_layer_count=" .. tostring(count) .. " sorted_first=" .. tostring(sorted[1]))
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
    lurek.log.info(tostring("parent = " .. p))
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
    lurek.log.info(tostring("query tick = " .. tostring(uni:getQueryChangeTick())))
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
    lurek.log.info(tostring("friends = " .. #friends))
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
    lurek.log.info("system count=" .. tostring(count) .. " hero_alive=" .. tostring(uni:isAlive(hero)))
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
    lurek.log.info(tostring(#u:getTags(e)))
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
    lurek.log.info("component presence speed=" .. tostring(has_speed) .. " hp=" .. tostring(has_hp) .. " mp=" .. tostring(has_mp))
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
    lurek.log.info(tostring(u:hasBitmapTag(e, "enemy")))
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
    lurek.log.info("has blueprint enemy=" .. tostring(has_enemy) .. " boss=" .. tostring(has_boss) .. " total=" .. tostring(#names))
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
    lurek.log.info(tostring("has relation = " .. tostring(uni:hasRelation(a, "attacks", b))))
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
    lurek.log.info(tostring(u:hasTag(e, "enemy")))
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
    lurek.log.info("liveness hero=" .. tostring(hero_alive) .. " prop=" .. tostring(prop_alive) .. " entity_count=" .. tostring(uni:getEntityCount()))
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
    lurek.log.info("kill removed minion alive=" .. tostring(alive) .. " owner_links=" .. tostring(owned) .. " entity_count=" .. tostring(uni:getEntityCount()))
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
    lurek.log.info(tostring("child alive = " .. tostring(uni:isAlive(child))))
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
    lurek.log.info("blueprint names total=" .. tostring(#names) .. " first=" .. tostring(first) .. " last=" .. tostring(last))
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
    lurek.log.info(tostring("view created = " .. tostring(view ~= nil)))
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
    lurek.log.info(tostring("added callback fired = " .. tostring(added)))
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
    lurek.log.info(tostring("removed callback fired = " .. tostring(removed)))
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
    lurek.log.info(tostring("with pos+vel = " .. #uni:query("pos", "vel")))
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
    lurek.log.info(tostring(#u:queryBitmapAll({"enemy"})))
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
    lurek.log.info(tostring(#u:queryBitmapAny({"enemy"})))
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
    lurek.log.info(tostring(#u:queryBitmapTag("enemy")))
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
        lurek.log.info(tostring("queryMulti entity = " .. tostring(entity_id)))
        lurek.log.info(tostring("values = " .. tostring(a_value.value) .. "," .. tostring(b_value.value)))
    end)
    lurek.log.info(tostring("queryMulti = " .. count))
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
    lurek.log.info(tostring("moving entities = " .. #uni:queryNot({"pos"}, {"static"})))
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
    lurek.log.info("release world before=" .. tostring(before) .. " after=" .. tostring(after) .. " old_entity_alive=" .. tostring(alive))
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
    lurek.log.info(tostring("after remove has = " .. tostring(uni:has(id, "temp"))))
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
    lurek.log.info(tostring(u:hasBlueprint("enemy")))
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
    lurek.log.info(tostring("relation removed"))
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
    lurek.log.info(tostring("after remove systems = " .. uni:getSystemCount()))
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
    lurek.log.info(tostring(u:hasTag(e, "enemy")))
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
    lurek.log.info(tostring("render called = " .. tostring(drawn)))
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
    lurek.log.info(tostring("entities in snapshot = " .. #snap.entities))
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
    lurek.log.info("components set pos=" .. tostring(pos.x) .. "," .. tostring(pos.y) .. " hp=" .. tostring(hp.value))
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
    lurek.log.info("set layer before=" .. tostring(before) .. " after=" .. tostring(after) .. " layer_entities=" .. tostring(#layer_entities))
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
    lurek.log.info(tostring("parent set"))
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
    lurek.log.info(tostring("snapshot type = " .. type(snap)))
    lurek.log.info(tostring("snapshot entities = " .. #snap.entities))
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
    lurek.log.info("spawned entities hero=" .. tostring(hero) .. " enemy=" .. tostring(enemy) .. " live_count=" .. tostring(#ids))
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
    lurek.log.info("spawned blueprint id=" .. tostring(id) .. " pos=" .. tostring(pos.x) .. "," .. tostring(pos.y) .. " components=" .. tostring(#components) .. " alive=" .. tostring(alive))
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
    lurek.log.info("bulk spawned count=" .. tostring(#ids) .. " first=" .. tostring(first) .. " first_pos_x=" .. tostring(first_pos and first_pos.x) .. " live_count=" .. tostring(count))
end
```

---

#### `LUniverse:spawnObject`

Creates an ECS object instance from a registered class and attaches it to a new entity.

```lua
LUniverse:spawnObject(className, props)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `className` | string | Registered ECS class name. |
| `props?` | table | Optional property overrides copied onto the new object. |

**Returns**

| Type | Description |
|------|-------------|
| number | Entity id that received the object component. |

**Example**

```lua
do

    lurek.ecs.clearObjects()
    lurek.ecs.clearClasses()
    lurek.ecs.defineClass("EnemyBullet", { defaults = { damage = 3 } })
    local world = lurek.ecs.newUniverse()
    local entity = world:spawnObject("EnemyBullet", { damage = 5 })
    lurek.log.info("spawnObject entity=" .. tostring(entity) .. " class=" .. tostring(world:get(entity, "objectClass")) .. " damage=" .. tostring(world:get(entity, "object").damage))
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
    lurek.log.info(tostring("dirty entities = " .. tostring(#diff.dirty_entities)))
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
    lurek.log.info("universe type=" .. tostring(type_name) .. " entity=" .. tostring(entity) .. " count=" .. tostring(count))
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
    lurek.log.info("universe type guard universe=" .. tostring(is_universe) .. " object=" .. tostring(is_object) .. " rm=" .. tostring(is_rm))
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
    lurek.log.info(tostring("update called = " .. tostring(called)))
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
    lurek.log.info(tostring("phase ran = " .. tostring(ran)))
end
```

---
