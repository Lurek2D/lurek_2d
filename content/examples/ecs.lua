-- content/examples/ecs.lua
-- Lurek2D lurek.ecs API Reference
-- Run with: cargo run -- content/examples/ecs

-- =============================================================================
-- STUBS: 57 uncovered lurek.ecs API item(s)
-- =============================================================================

-- ---- Stub: lurek.ecs.newUniverse -----------------------------------------
--@api-stub: lurek.ecs.newUniverse
-- Create a fresh ECS universe for a dungeon level -- all entities,
-- systems, and blueprints live inside this container.
local world = lurek.ecs.newUniverse()
print("universe created:", world ~= nil)

-- Pre-define a blueprint that systems and spawn calls will reference
world:defineTag("enemy")
world:defineTag("player")

-- Blueprint helper used in blueprint stubs below
local hero_bp = {
    position = { x = 0, y = 0 },
    health   = { hp = 100 },
    speed    = { value = 200 },
}

-- -----------------------------------------------------------------------------
-- Universe methods
-- -----------------------------------------------------------------------------

-- ---- Stub: Universe:spawn ------------------------------------------------
--@api-stub: Universe:spawn
-- Demonstrates the proper usage of Universe:spawn.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_spawn()
    local e = world:spawn(hero_bp)
    print("spawned entity:", e)
end
local _ok, _err = pcall(demo_Universe_spawn)

-- ---- Stub: Universe:kill -------------------------------------------------
--@api-stub: Universe:kill
-- Kill an entity when its health drops to zero -- the slot is freed
-- and can be reused for the next spawned creature.
local temp = world:spawn({ position = { x = 10, y = 10 } })
world:kill(temp)
print("temp entity alive:", world:isAlive(temp))

-- ---- Stub: Universe:isAlive ----------------------------------------------
--@api-stub: Universe:isAlive
-- Guard update logic with an alive check so a system does not process
-- an entity that was killed earlier in the same frame.
if world:isAlive(e) then
    print("ecs", e, "is alive -- processing OK")
end

-- ---- Stub: Universe:set --------------------------------------------------
--@api-stub: Universe:set
-- Demonstrates the proper usage of Universe:set.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_set()
    world:set(e, "velocity", { vx = 150, vy = 0 })
    print("velocity set:", world:has(e, "velocity"))
end
local _ok, _err = pcall(demo_Universe_set)

-- ---- Stub: Universe:get --------------------------------------------------
--@api-stub: Universe:get
-- Demonstrates the proper usage of Universe:get.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_get()
    local hp = world:get(e, "health")
    print("player hp:", hp and hp.hp or "missing")
end
local _ok, _err = pcall(demo_Universe_get)

-- ---- Stub: Universe:has --------------------------------------------------
--@api-stub: Universe:has
-- Guard a system that only applies to entities with a velocity so
-- static props are silently skipped each tick.
if world:has(e, "velocity") then
    print("entity has velocity -- movement system applies")
end

-- ---- Stub: Universe:remove -----------------------------------------------
--@api-stub: Universe:remove
-- Demonstrates the proper usage of Universe:remove.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_remove()
    world:remove(e, "velocity")
    print("velocity removed:", world:has(e, "velocity"))
end
local _ok, _err = pcall(demo_Universe_remove)

-- ---- Stub: Universe:getComponents ----------------------------------------
--@api-stub: Universe:getComponents
-- List all component names on a selected entity in the debug inspector
-- so a developer can verify that spawning applied the right blueprint.
local comps = world:getComponents(e)
print("components on entity", e, ":")
for _, name in ipairs(comps) do print("  -", name) end

-- ---- Stub: Universe:query ------------------------------------------------
--@api-stub: Universe:query
-- Demonstrates the proper usage of Universe:query.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_query()
    local combatants = world:query({ "position", "health" })
    print("combatants found:", #combatants)
end
local _ok, _err = pcall(demo_Universe_query)

-- ---- Stub: Universe:each -------------------------------------------------
--@api-stub: Universe:each
-- Iterate all entities with a health component and heal them by 5 HP
-- when the player activates a regen shrine.
world:each("health", function(id, h)
    h.hp = math.min(h.hp + 5, 100)
end)
print("regen applied to all health entities")

-- ---- Stub: Universe:getEntities ------------------------------------------
--@api-stub: Universe:getEntities
-- Demonstrates the proper usage of Universe:getEntities.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_getEntities()
    local all = world:getEntities()
    print("total alive entities:", #all)
end
local _ok, _err = pcall(demo_Universe_getEntities)

-- ---- Stub: Universe:getEntityCount ---------------------------------------
--@api-stub: Universe:getEntityCount
-- Demonstrates the proper usage of Universe:getEntityCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_getEntityCount()
    print("entity count:", world:getEntityCount())
end
local _ok, _err = pcall(demo_Universe_getEntityCount)

-- ---- Stub: Universe:addSystem --------------------------------------------
--@api-stub: Universe:addSystem
-- Register the movement system with priority 10 so it runs before
-- the collision system at priority 20 each frame.
local movement_sys = {
    update = function(self, univ, dt)
        univ:each("position", function(id, pos)
            local vel = univ:get(id, "velocity")
            if vel then
                pos.x = pos.x + vel.vx * dt
                pos.y = pos.y + vel.vy * dt
            end
        end)
    end
}
world:addSystem(movement_sys, { priority = 10 })
print("systems:", world:getSystemCount())

-- ---- Stub: Universe:removeSystem -----------------------------------------
--@api-stub: Universe:removeSystem
-- Demonstrates the proper usage of Universe:removeSystem.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_removeSystem()
    world:removeSystem(movement_sys)
    print("systems after remove:", world:getSystemCount())
end
local _ok, _err = pcall(demo_Universe_removeSystem)

-- ---- Stub: Universe:update -----------------------------------------------
--@api-stub: Universe:update
-- Demonstrates the proper usage of Universe:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_update()
    world:addSystem(movement_sys, { priority = 10 })
    world:update(0.016)
end
local _ok, _err = pcall(demo_Universe_update)

-- ---- Stub: Universe:render -----------------------------------------------
--@api-stub: Universe:render
-- Demonstrates the proper usage of Universe:render.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_render()
    world:render()
end
local _ok, _err = pcall(demo_Universe_render)

-- ---- Stub: Universe:emit -------------------------------------------------
--@api-stub: Universe:emit
-- Demonstrates the proper usage of Universe:emit.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_emit()
    world:emit("on_room_clear", { room_id = 7, bonus = true })
end
local _ok, _err = pcall(demo_Universe_emit)

-- ---- Stub: Universe:getSystemCount ---------------------------------------
--@api-stub: Universe:getSystemCount
-- Demonstrates the proper usage of Universe:getSystemCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_getSystemCount()
    print("active systems:", world:getSystemCount())
end
local _ok, _err = pcall(demo_Universe_getSystemCount)

-- ---- Stub: Universe:clear ------------------------------------------------
--@api-stub: Universe:clear
-- Wipe all entities, tags, and layers when transitioning to a new dungeon
-- floor -- blueprints survive for the next room spawn.
world:clear()
print("universe cleared, entities:", world:getEntityCount())

-- Repopulate for subsequent stubs
local e = world:spawn(hero_bp)
world:set(e, "velocity", { vx = 0, vy = 0 })

-- ---- Stub: Universe:release ----------------------------------------------
--@api-stub: Universe:release
-- Fully reset the universe at session end to release all component
-- memory before the level scene is popped from the stack.
local tmp_world = lurek.ecs.newUniverse()
tmp_world:spawn({ position = { x = 0, y = 0 } })
tmp_world:release()
print("temp universe released")

-- ---- Stub: Universe:addTag -----------------------------------------------
--@api-stub: Universe:addTag
-- Demonstrates the proper usage of Universe:addTag.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_addTag()
    world:addTag(e, "player")
    print("has player tag:", world:hasTag(e, "player"))
end
local _ok, _err = pcall(demo_Universe_addTag)

-- ---- Stub: Universe:removeTag --------------------------------------------
--@api-stub: Universe:removeTag
-- Remove the "invincible" tag when a power-up expires so the damage
-- system starts processing hits again.
world:addTag(e, "invincible")
world:removeTag(e, "invincible")
print("invincible removed:", world:hasTag(e, "invincible"))

-- ---- Stub: Universe:hasTag -----------------------------------------------
--@api-stub: Universe:hasTag
-- Guard the damage handler so invincible entities take no damage even
-- if they are inside the hit radius.
if not world:hasTag(e, "invincible") then
    print("entity takes damage")
end

-- ---- Stub: Universe:getTags ----------------------------------------------
--@api-stub: Universe:getTags
-- List all string tags on the player entity in the debug inspector
-- to verify power-up logic applied the correct tags.
local tags = world:getTags(e)
print("entity tags:")
for _, t in ipairs(tags) do print("  -", t) end

-- ---- Stub: Universe:getEntitiesByTag -------------------------------------
--@api-stub: Universe:getEntitiesByTag
-- Demonstrates the proper usage of Universe:getEntitiesByTag.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_getEntitiesByTag()
    local enemies = world:getEntitiesByTag("enemy")
    print("enemies alive:", #enemies)
end
local _ok, _err = pcall(demo_Universe_getEntitiesByTag)

-- ---- Stub: Universe:setLayer ---------------------------------------------
--@api-stub: Universe:setLayer
-- Demonstrates the proper usage of Universe:setLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_setLayer()
    world:setLayer(e, 2)
    print("layer:", world:getLayer(e))
end
local _ok, _err = pcall(demo_Universe_setLayer)

-- ---- Stub: Universe:getLayer ---------------------------------------------
--@api-stub: Universe:getLayer
-- Demonstrates the proper usage of Universe:getLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_getLayer()
    print("entity layer:", world:getLayer(e))  -- 2
end
local _ok, _err = pcall(demo_Universe_getLayer)

-- ---- Stub: Universe:getEntitiesByLayer -----------------------------------
--@api-stub: Universe:getEntitiesByLayer
-- Demonstrates the proper usage of Universe:getEntitiesByLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_getEntitiesByLayer()
    local ground = world:getEntitiesByLayer(0)
    print("entities on layer 0:", #ground)
end
local _ok, _err = pcall(demo_Universe_getEntitiesByLayer)

-- ---- Stub: Universe:getEntitiesSorted ------------------------------------
--@api-stub: Universe:getEntitiesSorted
-- Demonstrates the proper usage of Universe:getEntitiesSorted.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_getEntitiesSorted()
    local sorted = world:getEntitiesSorted()
    print("sorted entity count:", #sorted)
end
local _ok, _err = pcall(demo_Universe_getEntitiesSorted)

-- ---- Stub: Universe:defineTag --------------------------------------------
--@api-stub: Universe:defineTag
-- Demonstrates the proper usage of Universe:defineTag.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_defineTag()
    local on_fire_bit = world:defineTag("on_fire")
    print("on_fire bitmap bit:", on_fire_bit)
end
local _ok, _err = pcall(demo_Universe_defineTag)

-- ---- Stub: Universe:bitmapTag --------------------------------------------
--@api-stub: Universe:bitmapTag
-- Demonstrates the proper usage of Universe:bitmapTag.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_bitmapTag()
    world:bitmapTag(e, "on_fire")
    print("on_fire set:", world:hasBitmapTag(e, "on_fire"))
end
local _ok, _err = pcall(demo_Universe_bitmapTag)

-- ---- Stub: Universe:bitmapUntag ------------------------------------------
--@api-stub: Universe:bitmapUntag
-- Demonstrates the proper usage of Universe:bitmapUntag.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_bitmapUntag()
    world:bitmapUntag(e, "on_fire")
    print("on_fire cleared:", world:hasBitmapTag(e, "on_fire"))
end
local _ok, _err = pcall(demo_Universe_bitmapUntag)

-- ---- Stub: Universe:hasBitmapTag -----------------------------------------
--@api-stub: Universe:hasBitmapTag
-- Demonstrates the proper usage of Universe:hasBitmapTag.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_hasBitmapTag()
    world:bitmapTag(e, "player")
    print("has player bitmap:", world:hasBitmapTag(e, "player"))
end
local _ok, _err = pcall(demo_Universe_hasBitmapTag)

-- ---- Stub: Universe:queryBitmapTag ---------------------------------------
--@api-stub: Universe:queryBitmapTag
-- Demonstrates the proper usage of Universe:queryBitmapTag.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_queryBitmapTag()
    local players = world:queryBitmapTag("player")
    print("player entities:", #players)
end
local _ok, _err = pcall(demo_Universe_queryBitmapTag)

-- ---- Stub: Universe:queryBitmapAny ---------------------------------------
--@api-stub: Universe:queryBitmapAny
-- Demonstrates the proper usage of Universe:queryBitmapAny.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_queryBitmapAny()
    local affected = world:queryBitmapAny({ "on_fire", "player" })
    print("affected by any tag:", #affected)
end
local _ok, _err = pcall(demo_Universe_queryBitmapAny)

-- ---- Stub: Universe:queryBitmapAll ---------------------------------------
--@api-stub: Universe:queryBitmapAll
-- Find entities that have BOTH the "player" and "stunned" bitmap tags
-- so the stun-recovery system skips non-stunned players.
world:bitmapTag(e, "stunned")
local stunned_players = world:queryBitmapAll({ "player", "stunned" })
print("stunned players:", #stunned_players)
world:bitmapUntag(e, "stunned")

-- ---- Stub: Universe:getBitmapTagBit --------------------------------------
--@api-stub: Universe:getBitmapTagBit
-- Demonstrates the proper usage of Universe:getBitmapTagBit.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_getBitmapTagBit()
    local bit_idx = world:getBitmapTagBit("on_fire")
    print("on_fire bit index:", bit_idx)
end
local _ok, _err = pcall(demo_Universe_getBitmapTagBit)

-- ---- Stub: Universe:hasBlueprint -----------------------------------------
--@api-stub: Universe:hasBlueprint
-- Demonstrates the proper usage of Universe:hasBlueprint.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_hasBlueprint()
    local has_hero = world:hasBlueprint("hero")
    print("hero blueprint exists:", has_hero)
end
local _ok, _err = pcall(demo_Universe_hasBlueprint)

-- ---- Stub: Universe:removeBlueprint --------------------------------------
--@api-stub: Universe:removeBlueprint
-- Remove a one-time tutorial blueprint after it is used so it cannot
-- be accidentally re-spawned in later rooms.
if world:hasBlueprint("tutorial_enemy") then
    world:removeBlueprint("tutorial_enemy")
    print("tutorial_enemy blueprint removed")
end

-- ---- Stub: Universe:listBlueprints ---------------------------------------
--@api-stub: Universe:listBlueprints
-- Enumerate all blueprint names during level load to verify the
-- content pipeline included every expected enemy and item template.
local bps = world:listBlueprints()
print("registered blueprints:")
for _, name in ipairs(bps) do print("  -", name) end

-- ---- Stub: Universe:getBlueprintComponents -------------------------------
--@api-stub: Universe:getBlueprintComponents
-- Read the hero blueprint's component table to display its default
-- stats in a character creation preview screen.
local hero_comps = world:getBlueprintComponents("hero_bp")
if hero_comps then
    print("hero blueprint has", #hero_comps, "component types")
end

-- ---- Stub: Universe:getParent --------------------------------------------
--@api-stub: Universe:getParent
-- Demonstrates the proper usage of Universe:getParent.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_getParent()
    local parent = world:getParent(e)
    print("entity parent:", parent or "none (root)")
end
local _ok, _err = pcall(demo_Universe_getParent)

-- ---- Stub: Universe:getChildren ------------------------------------------
--@api-stub: Universe:getChildren
-- Demonstrates the proper usage of Universe:getChildren.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_getChildren()
    local children = world:getChildren(e)
    print("entity children:", #children)
end
local _ok, _err = pcall(demo_Universe_getChildren)

-- ---- Stub: Universe:killRecursive ----------------------------------------
--@api-stub: Universe:killRecursive
-- Kill a vehicle entity together with all its mounted child entities
-- in one call so none are left as orphaned alive entities.
local vehicle = world:spawn({ position = { x = 100, y = 100 } })
local cannon  = world:spawn({ parent = vehicle })
world:killRecursive(vehicle)
print("vehicle alive:", world:isAlive(vehicle))
print("cannon alive:", world:isAlive(cannon))

-- ---- Stub: Universe:queryNot ---------------------------------------------
--@api-stub: Universe:queryNot
-- Demonstrates the proper usage of Universe:queryNot.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_queryNot()
    local statics = world:queryNot({ "position" }, { "velocity" })
    print("static (pos, no vel) entities:", #statics)
end
local _ok, _err = pcall(demo_Universe_queryNot)

-- ---- Stub: Universe:serialize --------------------------------------------
--@api-stub: Universe:serialize
-- Demonstrates the proper usage of Universe:serialize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Universe_serialize()
    local snapshot = world:serialize()
    print("snapshot entity count:", #snapshot)
end
local _ok, _err = pcall(demo_Universe_serialize)

-- ---- Stub: Universe:deserialize ------------------------------------------
--@api-stub: Universe:deserialize
-- Restore the universe from a save snapshot on load -- the game
-- resumes in exactly the same room state as when it was saved.
world:clear()
world:deserialize(snapshot)
print("universe restored, entities:", world:getEntityCount())

-- ---- Stub: Universe:onComponentAdded -------------------------------------
--@api-stub: Universe:onComponentAdded
-- Register a hook so the audio system plays a sound every time
-- a "burning" component is added anywhere in the universe.
world:onComponentAdded("burning", function(id)
    print("ecs", id, "caught fire -- play sizzle sound")
end)

-- ---- Stub: Universe:onComponentRemoved -----------------------------------
--@api-stub: Universe:onComponentRemoved
-- Register a hook so the particle system stops the fire emitter as
-- soon as the "burning" component is removed.
world:onComponentRemoved("burning", function(id)
    print("ecs", id, "fire extinguished -- stop particles")
end)

-- ---- Stub: Universe:flushObservers ---------------------------------------
--@api-stub: Universe:flushObservers
-- Dispatch all pending add/remove events after the batch spawn so
-- observer systems see the new entities before the first update tick.
local e2 = world:spawn({ position = { x = 50, y = 50 } })
world:set(e2, "burning", { duration = 3.0 })
world:flushObservers()
print("observers flushed")

-- ---- Stub: Universe:spawnBulk --------------------------------------------
--@api-stub: Universe:spawnBulk
-- Spawn 20 identical skeleton enemies from the skeleton blueprint
-- at room entry to fill the encounter without a loop.
local skeleton_bp = { position = { x = 0, y = 0 }, health = { hp = 30 } }
local skeletons = world:spawnBulk(skeleton_bp, 5)
print("bulk spawned:", #skeletons, "skeletons")
for _, sid in ipairs(skeletons) do
    world:addTag(sid, "enemy")
end

-- ---- Stub: Universe:addRelation ------------------------------------------
--@api-stub: Universe:addRelation
-- Record an "aggro" relationship from each spawned skeleton toward
-- the player so the AI system can find targets without a global search.
local player_e = world:spawn(hero_bp)
for _, sid in ipairs(skeletons) do
    world:addRelation(sid, "aggro", player_e)
end
print("aggro relations set on", #skeletons, "skeletons")

-- ---- Stub: Universe:getRelated -------------------------------------------
--@api-stub: Universe:getRelated
-- Retrieve all entities that the first skeleton has an "aggro" relation
-- to so the AI can pick the nearest one as its movement target.
local first = skeletons[1]
if first then
    local targets = world:getRelated(first, "aggro")
    print("skeleton aggro targets:", #targets)
end

-- ---- Stub: Universe:removeRelation ---------------------------------------
--@api-stub: Universe:removeRelation
-- Break the aggro link when the player uses an invisibility scroll
-- so enemies stop chasing them.
if first then
    world:removeRelation(first, "aggro", player_e)
    print("aggro removed from skeleton 1")
end

-- ---- Stub: Universe:clearRelations ---------------------------------------
--@api-stub: Universe:clearRelations
-- Remove all "aggro" relations from a confused skeleton so it no
-- longer has a target after the confusion effect expires.
if first then
    world:clearRelations(first, "aggro")
    print("all aggro cleared from skeleton 1")
end

-- ---- Stub: Universe:hasRelation ------------------------------------------
--@api-stub: Universe:hasRelation
-- Check whether a guard still has a "patrol_path" relation to a
-- waypoint entity before queueing a move command.
local waypoint = world:spawn({ position = { x = 200, y = 50 } })
world:addRelation(first or e, "patrol_path", waypoint)
print("has patrol relation:", world:hasRelation(first or e, "patrol_path", waypoint))
