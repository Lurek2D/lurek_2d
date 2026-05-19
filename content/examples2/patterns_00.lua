--- Patterns Module Part 1: service locator, object pool, factory, strategy

--@api-stub: lurek.patterns.newServiceLocator
--@api-stub: LServiceLocator:provide
--@api-stub: LServiceLocator:locate
--@api-stub: LServiceLocator:has
-- Service locator registers and retrieves shared services.
do
    ---@type LServiceLocator
    local services = lurek.patterns.newServiceLocator()
    services:provide("audio", {volume = 0.8, muted = false})
    services:provide("config", {difficulty = "hard", language = "en"})
    print("has audio = " .. tostring(services:has("audio")))
    print("has physics = " .. tostring(services:has("physics")))
    local audio = services:locate("audio")
    if audio then
        print("audio volume = " .. audio.volume)
    end
end

--@api-stub: LServiceLocator:getServices
--@api-stub: LServiceLocator:remove
--@api-stub: LServiceLocator:clearAll
-- Service listing and removal.
do
    ---@type LServiceLocator
    local services = lurek.patterns.newServiceLocator()
    services:provide("renderer", {backend = "wgpu"})
    services:provide("input", {keyboard = true})
    services:provide("save", {slot = 1})
    local names = services:getServices()
    print("services = " .. #names)
    services:remove("save")
    print("after remove: has save = " .. tostring(services:has("save")))
    services:clearAll()
    print("after clear: count = " .. #services:getServices())
end

--@api-stub: lurek.patterns.newObjectPool
--@api-stub: LObjectPool:add
--@api-stub: LObjectPool:acquire
--@api-stub: LObjectPool:release
-- Object pool reuses pre-allocated objects.
do
    ---@type LObjectPool
    local pool = lurek.patterns.newObjectPool()
    for i = 1, 10 do
        pool:add({id = i, active = false, x = 0, y = 0})
    end
    print("total = " .. pool:getTotalCount())
    print("available = " .. pool:getAvailableCount())
    print("active = " .. pool:getActiveCount())
    local obj = pool:acquire()
    if obj then
        obj.active = true
        obj.x = 100
        print("acquired id = " .. obj.id)
        print("active count = " .. pool:getActiveCount())
        pool:release(obj)
        print("after release: available = " .. pool:getAvailableCount())
    end
end

--@api-stub: LObjectPool:clearAll
-- Full pool reset.
do
    ---@type LObjectPool
    local pool = lurek.patterns.newObjectPool()
    pool:add({type = "bullet"})
    pool:add({type = "bullet"})
    pool:acquire()
    print("before clear: total = " .. pool:getTotalCount())
    pool:clearAll()
    print("after clear: total = " .. pool:getTotalCount())
end

--@api-stub: lurek.patterns.newFactory
--@api-stub: LFactory:register
--@api-stub: LFactory:create
--@api-stub: LFactory:has
--@api-stub: LFactory:getTypes
-- Factory creates typed objects from registered constructors.
do
    ---@type LFactory
    local factory = lurek.patterns.newFactory()
    factory:register("enemy", function(hp, speed)
        return {type = "enemy", hp = hp or 100, speed = speed or 50}
    end)
    factory:register("bullet", function(dmg)
        return {type = "bullet", damage = dmg or 10}
    end)
    print("has enemy = " .. tostring(factory:has("enemy")))
    print("types = " .. #factory:getTypes())
    local e = factory:create("enemy", 200, 75)
    print("enemy hp = " .. e.hp .. " speed = " .. e.speed)
    local b = factory:create("bullet", 25)
    print("bullet dmg = " .. b.damage)
end

--@api-stub: LFactory:alias
--@api-stub: LFactory:remove
--@api-stub: LFactory:clearAll
-- Factory aliases and cleanup.
do
    ---@type LFactory
    local factory = lurek.patterns.newFactory()
    factory:register("goblin", function()
        return {type = "goblin", hp = 30}
    end)
    factory:alias("small_enemy", "goblin")
    local g = factory:create("small_enemy")
    print("alias creates: " .. g.type)
    factory:remove("goblin")
    print("after remove: has goblin = " .. tostring(factory:has("goblin")))
    factory:clearAll()
    print("after clear: types = " .. #factory:getTypes())
end

--@api-stub: lurek.patterns.newStrategy
--@api-stub: LStrategy:register
--@api-stub: LStrategy:set
--@api-stub: LStrategy:execute
-- Strategy pattern for hot-swappable algorithms.
do
    ---@type LStrategy
    local strat = lurek.patterns.newStrategy()
    strat:register("aggressive", function(unit)
        return {action = "attack", target = unit.nearest_enemy}
    end)
    strat:register("defensive", function(unit)
        return {action = "retreat", target = unit.base}
    end)
    strat:register("patrol", function(unit)
        return {action = "move", target = unit.next_waypoint}
    end)
    strat:set("aggressive")
    print("current = " .. strat:getCurrent())
    local result = strat:execute({nearest_enemy = "orc", base = "castle", next_waypoint = "wp3"})
    if result then
        print("action = " .. result.action)
    end
end

--@api-stub: LStrategy:has
--@api-stub: LStrategy:names
--@api-stub: LStrategy:remove
--@api-stub: LStrategy:clear
-- Strategy management.
do
    ---@type LStrategy
    local strat = lurek.patterns.newStrategy()
    strat:register("fast", function() return {speed = 200} end)
    strat:register("slow", function() return {speed = 50} end)
    print("has fast = " .. tostring(strat:has("fast")))
    local all = strat:names()
    print("strategies = " .. #all)
    local removed = strat:remove("slow")
    print("removed slow = " .. tostring(removed))
    strat:clear()
    print("after clear: current = " .. tostring(strat:getCurrent()))
end

print("patterns_00.lua")
