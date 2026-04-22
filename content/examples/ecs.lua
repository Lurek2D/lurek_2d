-- content/examples/ecs.lua
-- love2d-style usage snippets for the lurek.ecs API (47 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/ecs.lua

-- ── lurek.ecs.* functions ──

--@api-stub: lurek.ecs.newUniverse
-- Creates a new empty ECS universe.
-- Build once at startup; reuse across frames.
local universe = lurek.ecs.newUniverse()
print("created", universe)
return universe

-- ── Universe methods ──

--@api-stub: Universe:spawn
-- Creates a new entity and returns its packed ID.
-- Build once at startup; reuse across frames.
local universe = lurek.ecs.newUniverse()
universe:spawn()
print("Universe:spawn done")

--@api-stub: Universe:kill
-- Destroys the entity with the given ID, freeing its slot for reuse.
-- See the module spec for detailed semantics.
local universe = lurek.ecs.newUniverse()
universe:kill(1)
print("Universe:kill done")

--@api-stub: Universe:isAlive
-- Returns true if the entity ID is currently alive.
-- Use as a guard inside lurek.update or event handlers.
local universe = lurek.ecs.newUniverse()
if universe:isAlive(1) then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Universe:get
-- Returns the component value for an entity, or nil if missing.
-- Cheap to call; safe inside callbacks.
local universe = lurek.ecs.newUniverse()  -- or your existing handle
local value = universe:get(1, "main")
print("Universe:get ->", value)

--@api-stub: Universe:has
-- Returns true if the entity has the named component.
-- See the module spec for detailed semantics.
local universe = lurek.ecs.newUniverse()
universe:has(1, "main")
print("Universe:has done")

--@api-stub: Universe:remove
-- Removes a component from an entity.
-- Pair with the matching constructor to free resources.
local universe = lurek.ecs.newUniverse()
universe:remove(1, "main")
-- universe is now released
print("ok")

--@api-stub: Universe:getComponents
-- Returns all component names for an entity.
-- Cheap to call; safe inside callbacks.
local universe = lurek.ecs.newUniverse()  -- or your existing handle
local value = universe:getComponents(1)
print("Universe:getComponents ->", value)

--@api-stub: Universe:query
-- Returns entity IDs that have all listed component names.
-- Cheap to call; safe inside callbacks.
local universe = lurek.ecs.newUniverse()  -- or your existing handle
local value = universe:query({ x = 0, y = 0 })
print("Universe:query ->", value)

--@api-stub: Universe:getEntities
-- Returns all alive entity IDs.
-- Cheap to call; safe inside callbacks.
local universe = lurek.ecs.newUniverse()  -- or your existing handle
local value = universe:getEntities()
print("Universe:getEntities ->", value)

--@api-stub: Universe:getEntityCount
-- Returns the number of alive entities.
-- Cheap to call; safe inside callbacks.
local universe = lurek.ecs.newUniverse()  -- or your existing handle
local value = universe:getEntityCount()
print("Universe:getEntityCount ->", value)

--@api-stub: Universe:removeSystem
-- Removes a system table from the universe.
-- Pair with the matching constructor to free resources.
local universe = lurek.ecs.newUniverse()
universe:removeSystem(system)
-- universe is now released
print("ok")

--@api-stub: Universe:update
-- Calls update(system, world, dt) on each registered system in priority order.
-- Apply at startup or in response to user input.
local universe = lurek.ecs.newUniverse()
universe:update(dt)
print("Universe:update applied")

--@api-stub: Universe:render
-- Calls render(system, world) on each registered system in priority order.
-- See the module spec for detailed semantics.
local universe = lurek.ecs.newUniverse()
universe:render()
print("Universe:render done")

--@api-stub: Universe:emit
-- Emits a named event to all systems that implement the handler, in priority order.
-- Side-effecting; safe to call any time after init.
local universe = lurek.ecs.newUniverse()
universe:emit({ x = 0, y = 0 })
print("Universe:emit done")

--@api-stub: Universe:getSystemCount
-- Returns the number of registered systems.
-- Cheap to call; safe inside callbacks.
local universe = lurek.ecs.newUniverse()  -- or your existing handle
local value = universe:getSystemCount()
print("Universe:getSystemCount ->", value)

--@api-stub: Universe:clear
-- Removes all entities, components, tags, layers, and systems.
-- Pair with the matching constructor to free resources.
local universe = lurek.ecs.newUniverse()
universe:clear()
-- universe is now released
print("ok")

--@api-stub: Universe:release
-- Releases all universe state, equivalent to clear.
-- See the module spec for detailed semantics.
local universe = lurek.ecs.newUniverse()
universe:release()
print("Universe:release done")

--@api-stub: Universe:addTag
-- Attaches a string tag to an entity.
-- Side-effecting; safe to call any time after init.
local universe = lurek.ecs.newUniverse()
universe:addTag(1, "main")
print("Universe:addTag done")

--@api-stub: Universe:removeTag
-- Removes a string tag from an entity.
-- Pair with the matching constructor to free resources.
local universe = lurek.ecs.newUniverse()
universe:removeTag(1, "main")
-- universe is now released
print("ok")

--@api-stub: Universe:hasTag
-- Returns true if the entity carries the given tag.
-- Use as a guard inside lurek.update or event handlers.
local universe = lurek.ecs.newUniverse()
if universe:hasTag(1, "main") then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Universe:getTags
-- Returns all string tags for an entity.
-- Cheap to call; safe inside callbacks.
local universe = lurek.ecs.newUniverse()  -- or your existing handle
local value = universe:getTags(1)
print("Universe:getTags ->", value)

--@api-stub: Universe:getEntitiesByTag
-- Returns all alive entities with the given string tag.
-- Cheap to call; safe inside callbacks.
local universe = lurek.ecs.newUniverse()  -- or your existing handle
local value = universe:getEntitiesByTag("main")
print("Universe:getEntitiesByTag ->", value)

--@api-stub: Universe:setLayer
-- Sets the layer for an entity.
-- Apply at startup or in response to user input.
local universe = lurek.ecs.newUniverse()
universe:setLayer(1, layer)
print("Universe:setLayer applied")

--@api-stub: Universe:getLayer
-- Returns the layer for an entity, defaulting to zero.
-- Cheap to call; safe inside callbacks.
local universe = lurek.ecs.newUniverse()  -- or your existing handle
local value = universe:getLayer(1)
print("Universe:getLayer ->", value)

--@api-stub: Universe:getEntitiesByLayer
-- Returns all alive entities on a specific layer.
-- Cheap to call; safe inside callbacks.
local universe = lurek.ecs.newUniverse()  -- or your existing handle
local value = universe:getEntitiesByLayer(layer)
print("Universe:getEntitiesByLayer ->", value)

--@api-stub: Universe:getEntitiesSorted
-- Returns all alive entities sorted by layer then ID.
-- Cheap to call; safe inside callbacks.
local universe = lurek.ecs.newUniverse()  -- or your existing handle
local value = universe:getEntitiesSorted()
print("Universe:getEntitiesSorted ->", value)

--@api-stub: Universe:defineTag
-- Defines a bitmap tag name, returning its bit index.
-- See the module spec for detailed semantics.
local universe = lurek.ecs.newUniverse()
universe:defineTag("main")
print("Universe:defineTag done")

--@api-stub: Universe:bitmapTag
-- Adds a bitmap tag to an entity.
-- See the module spec for detailed semantics.
local universe = lurek.ecs.newUniverse()
universe:bitmapTag(1, "main")
print("Universe:bitmapTag done")

--@api-stub: Universe:bitmapUntag
-- Removes a bitmap tag from an entity.
-- See the module spec for detailed semantics.
local universe = lurek.ecs.newUniverse()
universe:bitmapUntag(1, "main")
print("Universe:bitmapUntag done")

--@api-stub: Universe:hasBitmapTag
-- Returns true if the entity has the given bitmap tag.
-- Use as a guard inside lurek.update or event handlers.
local universe = lurek.ecs.newUniverse()
if universe:hasBitmapTag(1, "main") then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Universe:queryBitmapTag
-- Returns all alive entities with the given bitmap tag.
-- Cheap to call; safe inside callbacks.
local universe = lurek.ecs.newUniverse()  -- or your existing handle
local value = universe:queryBitmapTag("main")
print("Universe:queryBitmapTag ->", value)

--@api-stub: Universe:queryBitmapAny
-- Returns all alive entities with any of the listed bitmap tags.
-- Cheap to call; safe inside callbacks.
local universe = lurek.ecs.newUniverse()  -- or your existing handle
local value = universe:queryBitmapAny("main")
print("Universe:queryBitmapAny ->", value)

--@api-stub: Universe:queryBitmapAll
-- Returns all alive entities with all of the listed bitmap tags.
-- Cheap to call; safe inside callbacks.
local universe = lurek.ecs.newUniverse()  -- or your existing handle
local value = universe:queryBitmapAll("main")
print("Universe:queryBitmapAll ->", value)

--@api-stub: Universe:getBitmapTagBit
-- Returns the bit index for a bitmap tag name, or nil if undefined.
-- Cheap to call; safe inside callbacks.
local universe = lurek.ecs.newUniverse()  -- or your existing handle
local value = universe:getBitmapTagBit("main")
print("Universe:getBitmapTagBit ->", value)

--@api-stub: Universe:hasBlueprint
-- Returns true if a blueprint with the given name exists.
-- Use as a guard inside lurek.update or event handlers.
local universe = lurek.ecs.newUniverse()
if universe:hasBlueprint("main") then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Universe:removeBlueprint
-- Removes a blueprint definition.
-- Pair with the matching constructor to free resources.
local universe = lurek.ecs.newUniverse()
universe:removeBlueprint("main")
-- universe is now released
print("ok")

--@api-stub: Universe:listBlueprints
-- Returns all defined blueprint names.
-- See the module spec for detailed semantics.
local universe = lurek.ecs.newUniverse()
universe:listBlueprints()
print("Universe:listBlueprints done")

--@api-stub: Universe:getBlueprintComponents
-- Returns a deep copy of a blueprint's component table, or nil.
-- Cheap to call; safe inside callbacks.
local universe = lurek.ecs.newUniverse()  -- or your existing handle
local value = universe:getBlueprintComponents("main")
print("Universe:getBlueprintComponents ->", value)

--@api-stub: Universe:getParent
-- Returns the parent entity ID, or nil if unparented.
-- Cheap to call; safe inside callbacks.
local universe = lurek.ecs.newUniverse()  -- or your existing handle
local value = universe:getParent(1)
print("Universe:getParent ->", value)

--@api-stub: Universe:getChildren
-- Returns all direct child entity IDs.
-- Cheap to call; safe inside callbacks.
local universe = lurek.ecs.newUniverse()  -- or your existing handle
local value = universe:getChildren(1)
print("Universe:getChildren ->", value)

--@api-stub: Universe:killRecursive
-- Kills an entity and all its descendants recursively.
-- See the module spec for detailed semantics.
local universe = lurek.ecs.newUniverse()
universe:killRecursive(1)
print("Universe:killRecursive done")

--@api-stub: Universe:serialize
-- Serializes all alive entities to a Lua table snapshot.
-- May block — call from a worker thread for large payloads.
local universe = lurek.ecs.newUniverse()
universe:serialize()
print("Universe:serialize done")

--@api-stub: Universe:deserialize
-- Restores entity state from a snapshot produced by serialize().
-- May block — call from a worker thread for large payloads.
local universe = lurek.ecs.newUniverse()
universe:deserialize(snapshot)
print("Universe:deserialize done")

--@api-stub: Universe:flushObservers
-- Dispatches all pending component-add and component-remove events to registered callbacks.
-- See the module spec for detailed semantics.
local universe = lurek.ecs.newUniverse()
universe:flushObservers()
print("Universe:flushObservers done")

--@api-stub: Universe:getRelated
-- Returns all entity IDs reachable from `from` via the named relationship.
-- Cheap to call; safe inside callbacks.
local universe = lurek.ecs.newUniverse()  -- or your existing handle
local value = universe:getRelated(from, "main")
print("Universe:getRelated ->", value)

--@api-stub: Universe:clearRelations
-- Removes all directed named relationships of type `name` from entity `from`.
-- Pair with the matching constructor to free resources.
local universe = lurek.ecs.newUniverse()
universe:clearRelations(from, "main")
-- universe is now released
print("ok")

