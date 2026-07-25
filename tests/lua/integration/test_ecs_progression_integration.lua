-- Integration: progression status events are explicitly projected into ECS state.
-- @describe integration: progression status to ECS ChangeSet
describe("integration: progression status to ECS ChangeSet", function()
    -- @integration lurek.ecs.newUniverse
    -- @integration LUniverse:spawn
    -- @integration LUniverse:applyChangeSet
    -- @integration LUniverse:get
    -- @integration lurek.event.newChangeSet
    -- @integration LChangeSet:append
    -- @integration LChangeSet:toTable
    -- @integration lurek.progression.newStatusTracker
    -- @integration LStatusTracker:define
    -- @integration LStatusTracker:apply
    -- @integration LStatusTracker:drainEvents
    -- @integration LStatusTracker:update
    it("projects a neutral status tick into an explicit ECS component change", function()
        local world = lurek.ecs.newUniverse()
        local entity = world:spawn()
        local tracker = lurek.progression.newStatusTracker()
        tracker:define({
            id = "burning",
            duration = 5,
            tickInterval = 1,
            maxStacks = 1,
            stacking = "replace",
        })
        tracker:apply(entity, "burning")
        tracker:drainEvents()
        tracker:update(1.1)
        local events = tracker:drainEvents()
        expect_equal("tick", events[1].kind)

        local changes = lurek.event.newChangeSet({ schema = "ecs", revision = 1 })
        changes:append(entity, "damage", "set", events[1].tickCount * 3)
        expect_equal(1, world:applyChangeSet(changes:toTable()))
        expect_equal(3, world:get(entity, "damage"))
    end)

    -- @integration lurek.ecs.newUniverse
    -- @integration LUniverse:spawn
    -- @integration LUniverse:set
    -- @integration LUniverse:get
    -- @integration lurek.ecs.newRelationshipManager
    -- @integration LRelationshipManager:defineType
    -- @integration LRelationshipManager:setLevel
    -- @integration LRelationshipManager:getLevel
    -- @integration lurek.patterns.newEventBus
    -- @integration LEventBus:on
    -- @integration LEventBus:emit
    -- @integration lurek.effect.newStack
    -- @integration lurek.effect.newEffect
    -- @integration LPostFxStack:add
    -- @integration LPostFxStack:snapshot
    it("composes faction, ability, combat signal, and hit feedback in Lua", function()
        local world = lurek.ecs.newUniverse()
        local attacker = world:spawn()
        local defender = world:spawn()
        world:set(attacker, "ability", { id = "fireball", damage = 12 })
        expect_equal("fireball", world:get(attacker, "ability").id)

        local factions = lurek.ecs.newRelationshipManager()
        factions:defineType("faction", { "neutral", "ally", "hostile" }, "neutral")
        expect_true(factions:setLevel(attacker, defender, "faction", "hostile"))
        expect_equal("hostile", factions:getLevel(attacker, defender, "faction"))

        local combat_bus = lurek.patterns.newEventBus("combat")
        local hits = 0
        combat_bus:on("hit", function(target, amount)
            hits = hits + 1
            world:set(target, "lastDamage", amount)
        end)
        combat_bus:emit("hit", defender, world:get(attacker, "ability").damage)
        expect_equal(1, hits)
        expect_equal(12, world:get(defender, "lastDamage"))

        local feedback = lurek.effect.newStack(320, 180)
        feedback:add(lurek.effect.newEffect("vignette"))
        expect_equal(1, #feedback:snapshot().effects)
    end)
end)

test_summary()
