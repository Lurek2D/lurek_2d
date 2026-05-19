-- content/examples/patterns.lua
-- Auto-generated from content/examples2/patterns_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/patterns.lua

--- Patterns Module Part 1: service locator, object pool, factory, strategy


--@api-stub: lurek.patterns.newServiceLocator
-- Service locator registers and retrieves shared services. Focus: newServiceLocator.
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

--@api-stub: LServiceLocator:provide
-- Service locator registers and retrieves shared services. Focus: provide.
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

--@api-stub: LServiceLocator:locate
-- Service locator registers and retrieves shared services. Focus: locate.
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

--@api-stub: LServiceLocator:has
-- Service locator registers and retrieves shared services. Focus: has.
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
-- Service listing and removal. Focus: getServices.
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

--@api-stub: LServiceLocator:remove
-- Service listing and removal. Focus: remove.
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

--@api-stub: LServiceLocator:clearAll
-- Service listing and removal. Focus: clearAll.
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
-- Object pool reuses pre-allocated objects. Focus: newObjectPool.
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

--@api-stub: LObjectPool:add
-- Object pool reuses pre-allocated objects. Focus: add.
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

--@api-stub: LObjectPool:acquire
-- Object pool reuses pre-allocated objects. Focus: acquire.
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

--@api-stub: LObjectPool:release
-- Object pool reuses pre-allocated objects. Focus: release.
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
-- Factory creates typed objects from registered constructors. Focus: newFactory.
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

--@api-stub: LFactory:register
-- Factory creates typed objects from registered constructors. Focus: register.
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

--@api-stub: LFactory:create
-- Factory creates typed objects from registered constructors. Focus: create.
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

--@api-stub: LFactory:has
-- Factory creates typed objects from registered constructors. Focus: has.
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

--@api-stub: LFactory:getTypes
-- Factory creates typed objects from registered constructors. Focus: getTypes.
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
-- Factory aliases and cleanup. Focus: alias.
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

--@api-stub: LFactory:remove
-- Factory aliases and cleanup. Focus: remove.
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

--@api-stub: LFactory:clearAll
-- Factory aliases and cleanup. Focus: clearAll.
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
-- Strategy pattern for hot-swappable algorithms. Focus: newStrategy.
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

--@api-stub: LStrategy:register
-- Strategy pattern for hot-swappable algorithms. Focus: register.
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

--@api-stub: LStrategy:set
-- Strategy pattern for hot-swappable algorithms. Focus: set.
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

--@api-stub: LStrategy:execute
-- Strategy pattern for hot-swappable algorithms. Focus: execute.
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
-- Strategy management. Focus: has.
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

--@api-stub: LStrategy:names
-- Strategy management. Focus: names.
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

--@api-stub: LStrategy:remove
-- Strategy management. Focus: remove.
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

--@api-stub: LStrategy:clear
-- Strategy management. Focus: clear.
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

--- Patterns Module Part 2: FSM, command stack, behavior tree, blackboard


--@api-stub: lurek.patterns.newSimpleState
-- Finite state machine with enter/exit/update callbacks. Focus: newSimpleState.
do
    ---@type LSimpleState
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("idle", {
        enter = function() print("  enter idle") end,
        exit = function() print("  exit idle") end,
        update = function(dt) end
    })
    fsm:addState("walk", {
        enter = function() print("  enter walk") end,
        exit = function() print("  exit walk") end,
        update = function(dt) print("  walking dt=" .. dt) end
    })
    fsm:addState("attack", {
        enter = function() print("  enter attack") end,
        update = function(dt) print("  attacking") end
    })
    fsm:transitionTo("idle")
    print("current = " .. fsm:getCurrent())
    fsm:transitionTo("walk")
    print("current = " .. fsm:getCurrent())
    fsm:update(0.016)
end

--@api-stub: LSimpleState:addState
-- Finite state machine with enter/exit/update callbacks. Focus: addState.
do
    ---@type LSimpleState
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("idle", {
        enter = function() print("  enter idle") end,
        exit = function() print("  exit idle") end,
        update = function(dt) end
    })
    fsm:addState("walk", {
        enter = function() print("  enter walk") end,
        exit = function() print("  exit walk") end,
        update = function(dt) print("  walking dt=" .. dt) end
    })
    fsm:addState("attack", {
        enter = function() print("  enter attack") end,
        update = function(dt) print("  attacking") end
    })
    fsm:transitionTo("idle")
    print("current = " .. fsm:getCurrent())
    fsm:transitionTo("walk")
    print("current = " .. fsm:getCurrent())
    fsm:update(0.016)
end

--@api-stub: LSimpleState:transitionTo
-- Finite state machine with enter/exit/update callbacks. Focus: transitionTo.
do
    ---@type LSimpleState
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("idle", {
        enter = function() print("  enter idle") end,
        exit = function() print("  exit idle") end,
        update = function(dt) end
    })
    fsm:addState("walk", {
        enter = function() print("  enter walk") end,
        exit = function() print("  exit walk") end,
        update = function(dt) print("  walking dt=" .. dt) end
    })
    fsm:addState("attack", {
        enter = function() print("  enter attack") end,
        update = function(dt) print("  attacking") end
    })
    fsm:transitionTo("idle")
    print("current = " .. fsm:getCurrent())
    fsm:transitionTo("walk")
    print("current = " .. fsm:getCurrent())
    fsm:update(0.016)
end

--@api-stub: LSimpleState:getCurrent
-- Finite state machine with enter/exit/update callbacks. Focus: getCurrent.
do
    ---@type LSimpleState
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("idle", {
        enter = function() print("  enter idle") end,
        exit = function() print("  exit idle") end,
        update = function(dt) end
    })
    fsm:addState("walk", {
        enter = function() print("  enter walk") end,
        exit = function() print("  exit walk") end,
        update = function(dt) print("  walking dt=" .. dt) end
    })
    fsm:addState("attack", {
        enter = function() print("  enter attack") end,
        update = function(dt) print("  attacking") end
    })
    fsm:transitionTo("idle")
    print("current = " .. fsm:getCurrent())
    fsm:transitionTo("walk")
    print("current = " .. fsm:getCurrent())
    fsm:update(0.016)
end

--@api-stub: LSimpleState:hasState
-- State queries and reset. Focus: hasState.
do
    ---@type LSimpleState
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("menu")
    fsm:addState("game")
    fsm:addState("pause")
    print("has menu = " .. tostring(fsm:hasState("menu")))
    print("has quit = " .. tostring(fsm:hasState("quit")))
    print("states = " .. #fsm:getStates())
    fsm:clearAll()
    print("after clear = " .. #fsm:getStates())
end

--@api-stub: LSimpleState:getStates
-- State queries and reset. Focus: getStates.
do
    ---@type LSimpleState
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("menu")
    fsm:addState("game")
    fsm:addState("pause")
    print("has menu = " .. tostring(fsm:hasState("menu")))
    print("has quit = " .. tostring(fsm:hasState("quit")))
    print("states = " .. #fsm:getStates())
    fsm:clearAll()
    print("after clear = " .. #fsm:getStates())
end

--@api-stub: LSimpleState:clearAll
-- State queries and reset. Focus: clearAll.
do
    ---@type LSimpleState
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("menu")
    fsm:addState("game")
    fsm:addState("pause")
    print("has menu = " .. tostring(fsm:hasState("menu")))
    print("has quit = " .. tostring(fsm:hasState("quit")))
    print("states = " .. #fsm:getStates())
    fsm:clearAll()
    print("after clear = " .. #fsm:getStates())
end

--@api-stub: lurek.patterns.newCommandStack
-- Command stack for undo/redo. Focus: newCommandStack.
do
    ---@type LCommandStack
    local cmds = lurek.patterns.newCommandStack(50)
    local value = 0
    cmds:execute("add 10", function() value = value + 10 end, function() value = value - 10 end)
    print("after add: " .. value)
    cmds:execute("mul 2", function() value = value * 2 end, function() value = value / 2 end)
    print("after mul: " .. value)
    cmds:undo()
    print("after undo: " .. value)
    cmds:undo()
    print("after undo2: " .. value)
    cmds:redo()
    print("after redo: " .. value)
end

--@api-stub: LCommandStack:execute
-- Command stack for undo/redo. Focus: execute.
do
    ---@type LCommandStack
    local cmds = lurek.patterns.newCommandStack(50)
    local value = 0
    cmds:execute("add 10", function() value = value + 10 end, function() value = value - 10 end)
    print("after add: " .. value)
    cmds:execute("mul 2", function() value = value * 2 end, function() value = value / 2 end)
    print("after mul: " .. value)
    cmds:undo()
    print("after undo: " .. value)
    cmds:undo()
    print("after undo2: " .. value)
    cmds:redo()
    print("after redo: " .. value)
end

--@api-stub: LCommandStack:undo
-- Command stack for undo/redo. Focus: undo.
do
    ---@type LCommandStack
    local cmds = lurek.patterns.newCommandStack(50)
    local value = 0
    cmds:execute("add 10", function() value = value + 10 end, function() value = value - 10 end)
    print("after add: " .. value)
    cmds:execute("mul 2", function() value = value * 2 end, function() value = value / 2 end)
    print("after mul: " .. value)
    cmds:undo()
    print("after undo: " .. value)
    cmds:undo()
    print("after undo2: " .. value)
    cmds:redo()
    print("after redo: " .. value)
end

--@api-stub: LCommandStack:redo
-- Command stack for undo/redo. Focus: redo.
do
    ---@type LCommandStack
    local cmds = lurek.patterns.newCommandStack(50)
    local value = 0
    cmds:execute("add 10", function() value = value + 10 end, function() value = value - 10 end)
    print("after add: " .. value)
    cmds:execute("mul 2", function() value = value * 2 end, function() value = value / 2 end)
    print("after mul: " .. value)
    cmds:undo()
    print("after undo: " .. value)
    cmds:undo()
    print("after undo2: " .. value)
    cmds:redo()
    print("after redo: " .. value)
end

--@api-stub: LCommandStack:canUndo
-- Command stack queries. Focus: canUndo.
do
    ---@type LCommandStack
    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function() end, function() end)
    cmds:execute("step2", function() end, function() end)
    print("can undo = " .. tostring(cmds:canUndo()))
    print("can redo = " .. tostring(cmds:canRedo()))
    print("current = " .. cmds:getCurrentName())
    print("history = " .. cmds:getHistorySize())
    cmds:clearAll()
    print("after clear = " .. cmds:getHistorySize())
end

--@api-stub: LCommandStack:canRedo
-- Command stack queries. Focus: canRedo.
do
    ---@type LCommandStack
    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function() end, function() end)
    cmds:execute("step2", function() end, function() end)
    print("can undo = " .. tostring(cmds:canUndo()))
    print("can redo = " .. tostring(cmds:canRedo()))
    print("current = " .. cmds:getCurrentName())
    print("history = " .. cmds:getHistorySize())
    cmds:clearAll()
    print("after clear = " .. cmds:getHistorySize())
end

--@api-stub: LCommandStack:getCurrentName
-- Command stack queries. Focus: getCurrentName.
do
    ---@type LCommandStack
    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function() end, function() end)
    cmds:execute("step2", function() end, function() end)
    print("can undo = " .. tostring(cmds:canUndo()))
    print("can redo = " .. tostring(cmds:canRedo()))
    print("current = " .. cmds:getCurrentName())
    print("history = " .. cmds:getHistorySize())
    cmds:clearAll()
    print("after clear = " .. cmds:getHistorySize())
end

--@api-stub: LCommandStack:getHistorySize
-- Command stack queries. Focus: getHistorySize.
do
    ---@type LCommandStack
    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function() end, function() end)
    cmds:execute("step2", function() end, function() end)
    print("can undo = " .. tostring(cmds:canUndo()))
    print("can redo = " .. tostring(cmds:canRedo()))
    print("current = " .. cmds:getCurrentName())
    print("history = " .. cmds:getHistorySize())
    cmds:clearAll()
    print("after clear = " .. cmds:getHistorySize())
end

--@api-stub: LCommandStack:clearAll
-- Command stack queries. Focus: clearAll.
do
    ---@type LCommandStack
    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function() end, function() end)
    cmds:execute("step2", function() end, function() end)
    print("can undo = " .. tostring(cmds:canUndo()))
    print("can redo = " .. tostring(cmds:canRedo()))
    print("current = " .. cmds:getCurrentName())
    print("history = " .. cmds:getHistorySize())
    cmds:clearAll()
    print("after clear = " .. cmds:getHistorySize())
end

--@api-stub: lurek.patterns.newBehaviorTree
-- Behavior tree node creation. Focus: newBehaviorTree.
do
    ---@type LBehaviorTree
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSelector("root_sel")
    local seq_attack = bt:addSequence("attack_seq")
    local leaf_check = bt:addLeaf("check_enemy", "has_enemy?")
    local leaf_attack = bt:addLeaf("do_attack", "attack!")
    bt:addChild(root, seq_attack)
    bt:addChild(seq_attack, leaf_check)
    bt:addChild(seq_attack, leaf_attack)
    local leaf_idle = bt:addLeaf("idle", "idle")
    bt:addChild(root, leaf_idle)
    bt:setRoot(root)
    print("nodes = " .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:addSequence
-- Behavior tree node creation. Focus: addSequence.
do
    ---@type LBehaviorTree
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSelector("root_sel")
    local seq_attack = bt:addSequence("attack_seq")
    local leaf_check = bt:addLeaf("check_enemy", "has_enemy?")
    local leaf_attack = bt:addLeaf("do_attack", "attack!")
    bt:addChild(root, seq_attack)
    bt:addChild(seq_attack, leaf_check)
    bt:addChild(seq_attack, leaf_attack)
    local leaf_idle = bt:addLeaf("idle", "idle")
    bt:addChild(root, leaf_idle)
    bt:setRoot(root)
    print("nodes = " .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:addSelector
-- Behavior tree node creation. Focus: addSelector.
do
    ---@type LBehaviorTree
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSelector("root_sel")
    local seq_attack = bt:addSequence("attack_seq")
    local leaf_check = bt:addLeaf("check_enemy", "has_enemy?")
    local leaf_attack = bt:addLeaf("do_attack", "attack!")
    bt:addChild(root, seq_attack)
    bt:addChild(seq_attack, leaf_check)
    bt:addChild(seq_attack, leaf_attack)
    local leaf_idle = bt:addLeaf("idle", "idle")
    bt:addChild(root, leaf_idle)
    bt:setRoot(root)
    print("nodes = " .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:addLeaf
-- Behavior tree node creation. Focus: addLeaf.
do
    ---@type LBehaviorTree
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSelector("root_sel")
    local seq_attack = bt:addSequence("attack_seq")
    local leaf_check = bt:addLeaf("check_enemy", "has_enemy?")
    local leaf_attack = bt:addLeaf("do_attack", "attack!")
    bt:addChild(root, seq_attack)
    bt:addChild(seq_attack, leaf_check)
    bt:addChild(seq_attack, leaf_attack)
    local leaf_idle = bt:addLeaf("idle", "idle")
    bt:addChild(root, leaf_idle)
    bt:setRoot(root)
    print("nodes = " .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:setLeaf
-- Behavior tree execution. Focus: setLeaf.
do
    ---@type LBehaviorTree
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local check = bt:addLeaf("check", "check")
    local act = bt:addLeaf("act", "act")
    bt:addChild(root, check)
    bt:addChild(root, act)
    bt:setRoot(root)
    local enemy_visible = true
    bt:setLeaf("check", function()
        if enemy_visible then return "success" else return "failure" end
    end)
    bt:setLeaf("act", function()
        print("  attacking enemy!")
        return "success"
    end)
    local result = bt:tick()
    print("tick result = " .. result)
    enemy_visible = false
    result = bt:tick()
    print("no enemy result = " .. result)
    bt:resetState()
    print("state reset")
end

--@api-stub: LBehaviorTree:tick
-- Behavior tree execution. Focus: tick.
do
    ---@type LBehaviorTree
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local check = bt:addLeaf("check", "check")
    local act = bt:addLeaf("act", "act")
    bt:addChild(root, check)
    bt:addChild(root, act)
    bt:setRoot(root)
    local enemy_visible = true
    bt:setLeaf("check", function()
        if enemy_visible then return "success" else return "failure" end
    end)
    bt:setLeaf("act", function()
        print("  attacking enemy!")
        return "success"
    end)
    local result = bt:tick()
    print("tick result = " .. result)
    enemy_visible = false
    result = bt:tick()
    print("no enemy result = " .. result)
    bt:resetState()
    print("state reset")
end

--@api-stub: LBehaviorTree:resetState
-- Behavior tree execution. Focus: resetState.
do
    ---@type LBehaviorTree
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local check = bt:addLeaf("check", "check")
    local act = bt:addLeaf("act", "act")
    bt:addChild(root, check)
    bt:addChild(root, act)
    bt:setRoot(root)
    local enemy_visible = true
    bt:setLeaf("check", function()
        if enemy_visible then return "success" else return "failure" end
    end)
    bt:setLeaf("act", function()
        print("  attacking enemy!")
        return "success"
    end)
    local result = bt:tick()
    print("tick result = " .. result)
    enemy_visible = false
    result = bt:tick()
    print("no enemy result = " .. result)
    bt:resetState()
    print("state reset")
end

--@api-stub: LBehaviorTree:addParallel
-- Advanced BT nodes. Focus: addParallel.
do
    ---@type LBehaviorTree
    local bt = lurek.patterns.newBehaviorTree()
    local par = bt:addParallel(2, "par_node")
    local inv = bt:addInverter("inverter")
    local rep = bt:addRepeat(3, "repeat_3")
    local leaf = bt:addLeaf("action", "do_thing")
    bt:addChild(par, inv)
    bt:addChild(inv, leaf)
    bt:addChild(par, rep)
    local leaf2 = bt:addLeaf("other", "other")
    bt:addChild(rep, leaf2)
    print("parallel node created, count = " .. bt:nodeCount())
    bt:clearAll()
    print("after clear = " .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:addInverter
-- Advanced BT nodes. Focus: addInverter.
do
    ---@type LBehaviorTree
    local bt = lurek.patterns.newBehaviorTree()
    local par = bt:addParallel(2, "par_node")
    local inv = bt:addInverter("inverter")
    local rep = bt:addRepeat(3, "repeat_3")
    local leaf = bt:addLeaf("action", "do_thing")
    bt:addChild(par, inv)
    bt:addChild(inv, leaf)
    bt:addChild(par, rep)
    local leaf2 = bt:addLeaf("other", "other")
    bt:addChild(rep, leaf2)
    print("parallel node created, count = " .. bt:nodeCount())
    bt:clearAll()
    print("after clear = " .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:addRepeat
-- Advanced BT nodes. Focus: addRepeat.
do
    ---@type LBehaviorTree
    local bt = lurek.patterns.newBehaviorTree()
    local par = bt:addParallel(2, "par_node")
    local inv = bt:addInverter("inverter")
    local rep = bt:addRepeat(3, "repeat_3")
    local leaf = bt:addLeaf("action", "do_thing")
    bt:addChild(par, inv)
    bt:addChild(inv, leaf)
    bt:addChild(par, rep)
    local leaf2 = bt:addLeaf("other", "other")
    bt:addChild(rep, leaf2)
    print("parallel node created, count = " .. bt:nodeCount())
    bt:clearAll()
    print("after clear = " .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:clearAll
-- Advanced BT nodes. Focus: clearAll.
do
    ---@type LBehaviorTree
    local bt = lurek.patterns.newBehaviorTree()
    local par = bt:addParallel(2, "par_node")
    local inv = bt:addInverter("inverter")
    local rep = bt:addRepeat(3, "repeat_3")
    local leaf = bt:addLeaf("action", "do_thing")
    bt:addChild(par, inv)
    bt:addChild(inv, leaf)
    bt:addChild(par, rep)
    local leaf2 = bt:addLeaf("other", "other")
    bt:addChild(rep, leaf2)
    print("parallel node created, count = " .. bt:nodeCount())
    bt:clearAll()
    print("after clear = " .. bt:nodeCount())
end

--@api-stub: lurek.patterns.newBlackboard
-- Shared key-value blackboard. Focus: newBlackboard.
do
    ---@type LBlackboard
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("health", 100)
    bb:set("weapon", "sword")
    bb:set("alive", true)
    print("health = " .. tostring(bb:get("health")))
    print("weapon = " .. tostring(bb:get("weapon")))
    print("has alive = " .. tostring(bb:has("alive")))
    print("has mana = " .. tostring(bb:has("mana")))
    local all_keys = bb:keys()
    print("keys = " .. #all_keys)
end

--@api-stub: LBlackboard:set
-- Shared key-value blackboard. Focus: set.
do
    ---@type LBlackboard
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("health", 100)
    bb:set("weapon", "sword")
    bb:set("alive", true)
    print("health = " .. tostring(bb:get("health")))
    print("weapon = " .. tostring(bb:get("weapon")))
    print("has alive = " .. tostring(bb:has("alive")))
    print("has mana = " .. tostring(bb:has("mana")))
    local all_keys = bb:keys()
    print("keys = " .. #all_keys)

    -- Combined patterns: FSM transitions emit events, blackboard stores shared state.
    ---@type LBlackboard
    local bb = lurek.patterns.newBlackboard("game")
    bb:set("health", 100)
    bb:set("score", 0)

    ---@type LEventBus
    local bus = lurek.patterns.newEventBus("game_bus")
    bus:on("state_change", function(from, to)
        print("  state: " .. from .. " → " .. to)
    end)

    ---@type LSimpleState
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("idle", {
        enter = function()
            bb:set("action", "idle")
            bus:emit("state_change", "none", "idle")
        end
    })
    fsm:addState("combat", {
        enter = function()
            bb:set("action", "combat")
            bus:emit("state_change", "idle", "combat")
        end,
        update = function(dt)
            local h = bb:get("health")
            if h then
                bb:set("health", h - 10)
            end
        end
    })
    fsm:transitionTo("idle")
    fsm:transitionTo("combat")
    fsm:update(1.0)
    print("health after combat = " .. tostring(bb:get("health")))
    print("current state = " .. fsm:getCurrent())

    -- BT reads blackboard, strategy provides the algorithm.
    ---@type LBlackboard
    local bb = lurek.patterns.newBlackboard("ai")
    bb:set("enemy_distance", 50)
    bb:set("hp_percent", 0.3)

    ---@type LStrategy
    local strat = lurek.patterns.newStrategy()
    strat:register("melee", function()
        return "swing sword"
    end)
    strat:register("ranged", function()
        return "shoot arrow"
    end)
    strat:register("flee", function()
        return "run away"
    end)

    ---@type LBehaviorTree
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSelector("root")
    local flee_check = bt:addLeaf("flee_check", "flee?")
    local attack_leaf = bt:addLeaf("attack", "attack!")
    bt:addChild(root, flee_check)
    bt:addChild(root, attack_leaf)
    bt:setRoot(root)

    bt:setLeaf("flee_check", function()
        local hp = bb:get("hp_percent")
        if hp and hp < 0.2 then
            strat:set("flee")
            return "success"
        end
        return "failure"
    end)
    bt:setLeaf("attack", function()
        local dist = bb:get("enemy_distance")
        if dist and dist < 100 then
            strat:set("melee")
        else
            strat:set("ranged")
        end
        return "success"
    end)

    bt:tick()
    local action = strat:execute({})
    print("chosen action = " .. tostring(action))
    print("strategy = " .. tostring(strat:getCurrent()))
end

--@api-stub: LBlackboard:get
-- Shared key-value blackboard. Focus: get.
do
    ---@type LBlackboard
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("health", 100)
    bb:set("weapon", "sword")
    bb:set("alive", true)
    print("health = " .. tostring(bb:get("health")))
    print("weapon = " .. tostring(bb:get("weapon")))
    print("has alive = " .. tostring(bb:has("alive")))
    print("has mana = " .. tostring(bb:has("mana")))
    local all_keys = bb:keys()
    print("keys = " .. #all_keys)
end

--@api-stub: LBlackboard:has
-- Shared key-value blackboard. Focus: has.
do
    ---@type LBlackboard
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("health", 100)
    bb:set("weapon", "sword")
    bb:set("alive", true)
    print("health = " .. tostring(bb:get("health")))
    print("weapon = " .. tostring(bb:get("weapon")))
    print("has alive = " .. tostring(bb:has("alive")))
    print("has mana = " .. tostring(bb:has("mana")))
    local all_keys = bb:keys()
    print("keys = " .. #all_keys)
end

--@api-stub: LBlackboard:keys
-- Shared key-value blackboard. Focus: keys.
do
    ---@type LBlackboard
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("health", 100)
    bb:set("weapon", "sword")
    bb:set("alive", true)
    print("health = " .. tostring(bb:get("health")))
    print("weapon = " .. tostring(bb:get("weapon")))
    print("has alive = " .. tostring(bb:has("alive")))
    print("has mana = " .. tostring(bb:has("mana")))
    local all_keys = bb:keys()
    print("keys = " .. #all_keys)
end

--@api-stub: LBlackboard:watch
-- Blackboard reactivity and management. Focus: watch.
do
    ---@type LBlackboard
    local bb = lurek.patterns.newBlackboard()
    local watch_id = bb:watch("score", function(key, val)
        print("  score changed to " .. tostring(val))
    end)
    bb:set("score", 0)
    bb:set("score", 100)
    print("revision = " .. bb:getRevision())
    local snap = bb:snapshot()
    print("snapshot score = " .. tostring(snap.score))
    bb:unwatch(watch_id)
    bb:set("score", 200)
    bb:clear("score")
    print("after clear: has score = " .. tostring(bb:has("score")))
    bb:set("temp", 1)
    bb:clearAll()
    print("after clearAll: keys = " .. #bb:keys())
end

--@api-stub: LBlackboard:unwatch
-- Blackboard reactivity and management. Focus: unwatch.
do
    ---@type LBlackboard
    local bb = lurek.patterns.newBlackboard()
    local watch_id = bb:watch("score", function(key, val)
        print("  score changed to " .. tostring(val))
    end)
    bb:set("score", 0)
    bb:set("score", 100)
    print("revision = " .. bb:getRevision())
    local snap = bb:snapshot()
    print("snapshot score = " .. tostring(snap.score))
    bb:unwatch(watch_id)
    bb:set("score", 200)
    bb:clear("score")
    print("after clear: has score = " .. tostring(bb:has("score")))
    bb:set("temp", 1)
    bb:clearAll()
    print("after clearAll: keys = " .. #bb:keys())
end

--@api-stub: LBlackboard:getRevision
-- Blackboard reactivity and management. Focus: getRevision.
do
    ---@type LBlackboard
    local bb = lurek.patterns.newBlackboard()
    local watch_id = bb:watch("score", function(key, val)
        print("  score changed to " .. tostring(val))
    end)
    bb:set("score", 0)
    bb:set("score", 100)
    print("revision = " .. bb:getRevision())
    local snap = bb:snapshot()
    print("snapshot score = " .. tostring(snap.score))
    bb:unwatch(watch_id)
    bb:set("score", 200)
    bb:clear("score")
    print("after clear: has score = " .. tostring(bb:has("score")))
    bb:set("temp", 1)
    bb:clearAll()
    print("after clearAll: keys = " .. #bb:keys())
end

--@api-stub: LBlackboard:snapshot
-- Blackboard reactivity and management. Focus: snapshot.
do
    ---@type LBlackboard
    local bb = lurek.patterns.newBlackboard()
    local watch_id = bb:watch("score", function(key, val)
        print("  score changed to " .. tostring(val))
    end)
    bb:set("score", 0)
    bb:set("score", 100)
    print("revision = " .. bb:getRevision())
    local snap = bb:snapshot()
    print("snapshot score = " .. tostring(snap.score))
    bb:unwatch(watch_id)
    bb:set("score", 200)
    bb:clear("score")
    print("after clear: has score = " .. tostring(bb:has("score")))
    bb:set("temp", 1)
    bb:clearAll()
    print("after clearAll: keys = " .. #bb:keys())
end

--@api-stub: LBlackboard:clear
-- Blackboard reactivity and management. Focus: clear.
do
    ---@type LBlackboard
    local bb = lurek.patterns.newBlackboard()
    local watch_id = bb:watch("score", function(key, val)
        print("  score changed to " .. tostring(val))
    end)
    bb:set("score", 0)
    bb:set("score", 100)
    print("revision = " .. bb:getRevision())
    local snap = bb:snapshot()
    print("snapshot score = " .. tostring(snap.score))
    bb:unwatch(watch_id)
    bb:set("score", 200)
    bb:clear("score")
    print("after clear: has score = " .. tostring(bb:has("score")))
    bb:set("temp", 1)
    bb:clearAll()
    print("after clearAll: keys = " .. #bb:keys())
end

--@api-stub: LBlackboard:clearAll
-- Blackboard reactivity and management. Focus: clearAll.
do
    ---@type LBlackboard
    local bb = lurek.patterns.newBlackboard()
    local watch_id = bb:watch("score", function(key, val)
        print("  score changed to " .. tostring(val))
    end)
    bb:set("score", 0)
    bb:set("score", 100)
    print("revision = " .. bb:getRevision())
    local snap = bb:snapshot()
    print("snapshot score = " .. tostring(snap.score))
    bb:unwatch(watch_id)
    bb:set("score", 200)
    bb:clear("score")
    print("after clear: has score = " .. tostring(bb:has("score")))
    bb:set("temp", 1)
    bb:clearAll()
    print("after clearAll: keys = " .. #bb:keys())
end

--- Patterns Module Part 3: observer, event bus, mediator, debounce, throttle, funnel


--@api-stub: lurek.patterns.newObserver
-- Reactive observer with key-value watching. Focus: newObserver.
do
    ---@type LObserver
    local obs = lurek.patterns.newObserver("player_stats")
    local sub_id = obs:subscribe("hp", function(key, val)
        print("  " .. key .. " changed to " .. val)
    end)
    obs:set("hp", 100)
    obs:set("hp", 75)
    print("hp = " .. obs:get("hp"))
    obs:unsubscribe(sub_id)
    obs:set("hp", 50)
    print("hp after unsub = " .. obs:get("hp"))
end

--@api-stub: LObserver:set
-- Reactive observer with key-value watching. Focus: set.
do
    ---@type LObserver
    local obs = lurek.patterns.newObserver("player_stats")
    local sub_id = obs:subscribe("hp", function(key, val)
        print("  " .. key .. " changed to " .. val)
    end)
    obs:set("hp", 100)
    obs:set("hp", 75)
    print("hp = " .. obs:get("hp"))
    obs:unsubscribe(sub_id)
    obs:set("hp", 50)
    print("hp after unsub = " .. obs:get("hp"))
end

--@api-stub: LObserver:get
-- Reactive observer with key-value watching. Focus: get.
do
    ---@type LObserver
    local obs = lurek.patterns.newObserver("player_stats")
    local sub_id = obs:subscribe("hp", function(key, val)
        print("  " .. key .. " changed to " .. val)
    end)
    obs:set("hp", 100)
    obs:set("hp", 75)
    print("hp = " .. obs:get("hp"))
    obs:unsubscribe(sub_id)
    obs:set("hp", 50)
    print("hp after unsub = " .. obs:get("hp"))
end

--@api-stub: LObserver:subscribe
-- Reactive observer with key-value watching. Focus: subscribe.
do
    ---@type LObserver
    local obs = lurek.patterns.newObserver("player_stats")
    local sub_id = obs:subscribe("hp", function(key, val)
        print("  " .. key .. " changed to " .. val)
    end)
    obs:set("hp", 100)
    obs:set("hp", 75)
    print("hp = " .. obs:get("hp"))
    obs:unsubscribe(sub_id)
    obs:set("hp", 50)
    print("hp after unsub = " .. obs:get("hp"))
end

--@api-stub: LObserver:unsubscribe
-- Reactive observer with key-value watching. Focus: unsubscribe.
do
    ---@type LObserver
    local obs = lurek.patterns.newObserver("player_stats")
    local sub_id = obs:subscribe("hp", function(key, val)
        print("  " .. key .. " changed to " .. val)
    end)
    obs:set("hp", 100)
    obs:set("hp", 75)
    print("hp = " .. obs:get("hp"))
    obs:unsubscribe(sub_id)
    obs:set("hp", 50)
    print("hp after unsub = " .. obs:get("hp"))
end

--@api-stub: LObserver:getCount
-- Observer subscription count and one-shot subscriptions.
do
    ---@type LObserver
    local obs = lurek.patterns.newObserver()
    obs:subscribe("score", function(key, val)
        print("  score = " .. val)
    end, true)
    print("subs = " .. obs:getCount())
    obs:set("score", 100)
    print("after once-fire: subs = " .. obs:getCount())
end

--@api-stub: lurek.patterns.newEventBus
-- Publish/subscribe event bus. Focus: newEventBus.
do
    ---@type LEventBus
    local bus = lurek.patterns.newEventBus("game_events")
    local id1 = bus:on("damage", function(amount, source)
        print("  damage: " .. amount .. " from " .. source)
    end)
    local id2 = bus:on("damage", function(amount)
        print("  log: took " .. amount .. " damage")
    end, -1)
    bus:emit("damage", 25, "fire")
    bus:off(id1)
    bus:emit("damage", 10, "ice")
end

--@api-stub: LEventBus:on
-- Publish/subscribe event bus. Focus: on.
do
    ---@type LEventBus
    local bus = lurek.patterns.newEventBus("game_events")
    local id1 = bus:on("damage", function(amount, source)
        print("  damage: " .. amount .. " from " .. source)
    end)
    local id2 = bus:on("damage", function(amount)
        print("  log: took " .. amount .. " damage")
    end, -1)
    bus:emit("damage", 25, "fire")
    bus:off(id1)
    bus:emit("damage", 10, "ice")

    -- Ring stores FPS samples, throttle limits reporting, bus notifies listeners.
    ---@type LRing
    local fps_ring = lurek.patterns.newRing(60, "fps")

    ---@type LThrottle
    local report_throttle = lurek.patterns.newThrottle(1.0)

    ---@type LEventBus
    local bus = lurek.patterns.newEventBus("perf")
    bus:on("fps_report", function(avg)
        print("  FPS avg = " .. tostring(avg))
    end)

    report_throttle:onFire(function()
        if fps_ring:len() > 0 then
            bus:emit("fps_report", fps_ring:average())
        end
    end)

    for i = 1, 60 do
        fps_ring:push(58 + math.fmod(i, 5))
    end
    report_throttle:update(1.1)
    print("ring len = " .. fps_ring:len())
    print("ring avg = " .. fps_ring:average())
end

--@api-stub: LEventBus:emit
-- Publish/subscribe event bus. Focus: emit.
do
    ---@type LEventBus
    local bus = lurek.patterns.newEventBus("game_events")
    local id1 = bus:on("damage", function(amount, source)
        print("  damage: " .. amount .. " from " .. source)
    end)
    local id2 = bus:on("damage", function(amount)
        print("  log: took " .. amount .. " damage")
    end, -1)
    bus:emit("damage", 25, "fire")
    bus:off(id1)
    bus:emit("damage", 10, "ice")
end

--@api-stub: LEventBus:off
-- Publish/subscribe event bus. Focus: off.
do
    ---@type LEventBus
    local bus = lurek.patterns.newEventBus("game_events")
    local id1 = bus:on("damage", function(amount, source)
        print("  damage: " .. amount .. " from " .. source)
    end)
    local id2 = bus:on("damage", function(amount)
        print("  log: took " .. amount .. " damage")
    end, -1)
    bus:emit("damage", 25, "fire")
    bus:off(id1)
    bus:emit("damage", 10, "ice")
end

--@api-stub: LEventBus:getListenerCount
-- Event bus management. Focus: getListenerCount.
do
    ---@type LEventBus
    local bus = lurek.patterns.newEventBus()
    bus:on("spawn", function() end)
    bus:on("spawn", function() end)
    bus:on("death", function() end)
    print("spawn listeners = " .. bus:getListenerCount("spawn"))
    print("events = " .. #bus:getEvents())
    bus:clear("spawn")
    print("after clear spawn: " .. bus:getListenerCount("spawn"))
    bus:clearAll()
    print("after clearAll: events = " .. #bus:getEvents())
end

--@api-stub: LEventBus:getEvents
-- Event bus management. Focus: getEvents.
do
    ---@type LEventBus
    local bus = lurek.patterns.newEventBus()
    bus:on("spawn", function() end)
    bus:on("spawn", function() end)
    bus:on("death", function() end)
    print("spawn listeners = " .. bus:getListenerCount("spawn"))
    print("events = " .. #bus:getEvents())
    bus:clear("spawn")
    print("after clear spawn: " .. bus:getListenerCount("spawn"))
    bus:clearAll()
    print("after clearAll: events = " .. #bus:getEvents())
end

--@api-stub: LEventBus:clear
-- Event bus management. Focus: clear.
do
    ---@type LEventBus
    local bus = lurek.patterns.newEventBus()
    bus:on("spawn", function() end)
    bus:on("spawn", function() end)
    bus:on("death", function() end)
    print("spawn listeners = " .. bus:getListenerCount("spawn"))
    print("events = " .. #bus:getEvents())
    bus:clear("spawn")
    print("after clear spawn: " .. bus:getListenerCount("spawn"))
    bus:clearAll()
    print("after clearAll: events = " .. #bus:getEvents())
end

--@api-stub: LEventBus:clearAll
-- Event bus management. Focus: clearAll.
do
    ---@type LEventBus
    local bus = lurek.patterns.newEventBus()
    bus:on("spawn", function() end)
    bus:on("spawn", function() end)
    bus:on("death", function() end)
    print("spawn listeners = " .. bus:getListenerCount("spawn"))
    print("events = " .. #bus:getEvents())
    bus:clear("spawn")
    print("after clear spawn: " .. bus:getListenerCount("spawn"))
    bus:clearAll()
    print("after clearAll: events = " .. #bus:getEvents())
end

--@api-stub: lurek.patterns.newMediator
-- Channel-based message passing. Focus: newMediator.
do
    ---@type LMediator
    local med = lurek.patterns.newMediator()
    local h1 = med:on("ui", function(msg, data)
        print("  ui handler: " .. msg .. " = " .. tostring(data))
    end)
    local h2 = med:on("game", function(event)
        print("  game handler: " .. event)
    end)
    med:send("ui", "health_update", 80)
    med:send("game", "level_complete")
    med:off("ui", h1)
    med:send("ui", "ignored", 0)
end

--@api-stub: LMediator:on
-- Channel-based message passing. Focus: on.
do
    ---@type LMediator
    local med = lurek.patterns.newMediator()
    local h1 = med:on("ui", function(msg, data)
        print("  ui handler: " .. msg .. " = " .. tostring(data))
    end)
    local h2 = med:on("game", function(event)
        print("  game handler: " .. event)
    end)
    med:send("ui", "health_update", 80)
    med:send("game", "level_complete")
    med:off("ui", h1)
    med:send("ui", "ignored", 0)
end

--@api-stub: LMediator:send
-- Channel-based message passing. Focus: send.
do
    ---@type LMediator
    local med = lurek.patterns.newMediator()
    local h1 = med:on("ui", function(msg, data)
        print("  ui handler: " .. msg .. " = " .. tostring(data))
    end)
    local h2 = med:on("game", function(event)
        print("  game handler: " .. event)
    end)
    med:send("ui", "health_update", 80)
    med:send("game", "level_complete")
    med:off("ui", h1)
    med:send("ui", "ignored", 0)
end

--@api-stub: LMediator:off
-- Channel-based message passing. Focus: off.
do
    ---@type LMediator
    local med = lurek.patterns.newMediator()
    local h1 = med:on("ui", function(msg, data)
        print("  ui handler: " .. msg .. " = " .. tostring(data))
    end)
    local h2 = med:on("game", function(event)
        print("  game handler: " .. event)
    end)
    med:send("ui", "health_update", 80)
    med:send("game", "level_complete")
    med:off("ui", h1)
    med:send("ui", "ignored", 0)
end

--@api-stub: LMediator:broadcast
-- Mediator broadcast and channel management. Focus: broadcast.
do
    ---@type LMediator
    local med = lurek.patterns.newMediator()
    med:on("audio", function(...) end)
    med:on("video", function(...) end)
    med:on("input", function(...) end)
    med:broadcast("system_pause")
    print("channels = " .. #med:channels())
    print("audio handlers = " .. med:handlerCount("audio"))
    med:removeChannel("audio")
    print("after remove: channels = " .. #med:channels())
    med:clear()
    print("after clear: channels = " .. #med:channels())
end

--@api-stub: LMediator:channels
-- Mediator broadcast and channel management. Focus: channels.
do
    ---@type LMediator
    local med = lurek.patterns.newMediator()
    med:on("audio", function(...) end)
    med:on("video", function(...) end)
    med:on("input", function(...) end)
    med:broadcast("system_pause")
    print("channels = " .. #med:channels())
    print("audio handlers = " .. med:handlerCount("audio"))
    med:removeChannel("audio")
    print("after remove: channels = " .. #med:channels())
    med:clear()
    print("after clear: channels = " .. #med:channels())
end

--@api-stub: LMediator:handlerCount
-- Mediator broadcast and channel management. Focus: handlerCount.
do
    ---@type LMediator
    local med = lurek.patterns.newMediator()
    med:on("audio", function(...) end)
    med:on("video", function(...) end)
    med:on("input", function(...) end)
    med:broadcast("system_pause")
    print("channels = " .. #med:channels())
    print("audio handlers = " .. med:handlerCount("audio"))
    med:removeChannel("audio")
    print("after remove: channels = " .. #med:channels())
    med:clear()
    print("after clear: channels = " .. #med:channels())
end

--@api-stub: LMediator:removeChannel
-- Mediator broadcast and channel management. Focus: removeChannel.
do
    ---@type LMediator
    local med = lurek.patterns.newMediator()
    med:on("audio", function(...) end)
    med:on("video", function(...) end)
    med:on("input", function(...) end)
    med:broadcast("system_pause")
    print("channels = " .. #med:channels())
    print("audio handlers = " .. med:handlerCount("audio"))
    med:removeChannel("audio")
    print("after remove: channels = " .. #med:channels())
    med:clear()
    print("after clear: channels = " .. #med:channels())
end

--@api-stub: LMediator:clear
-- Mediator broadcast and channel management. Focus: clear.
do
    ---@type LMediator
    local med = lurek.patterns.newMediator()
    med:on("audio", function(...) end)
    med:on("video", function(...) end)
    med:on("input", function(...) end)
    med:broadcast("system_pause")
    print("channels = " .. #med:channels())
    print("audio handlers = " .. med:handlerCount("audio"))
    med:removeChannel("audio")
    print("after remove: channels = " .. #med:channels())
    med:clear()
    print("after clear: channels = " .. #med:channels())
end

--@api-stub: lurek.patterns.newDebounce
-- Debounce delays action until input stops. Focus: newDebounce.
do
    ---@type LDebounce
    local db = lurek.patterns.newDebounce(0.5)
    db:onFire(function()
        print("  debounce fired!")
    end)
    db:trigger()
    print("pending = " .. tostring(db:isPending()))
    db:update(0.3)
    db:trigger()
    db:update(0.3)
    db:update(0.3)
    print("fire count = " .. db:getFireCount())
end

--@api-stub: LDebounce:trigger
-- Debounce delays action until input stops. Focus: trigger.
do
    ---@type LDebounce
    local db = lurek.patterns.newDebounce(0.5)
    db:onFire(function()
        print("  debounce fired!")
    end)
    db:trigger()
    print("pending = " .. tostring(db:isPending()))
    db:update(0.3)
    db:trigger()
    db:update(0.3)
    db:update(0.3)
    print("fire count = " .. db:getFireCount())
end

--@api-stub: LDebounce:update
-- Debounce delays action until input stops. Focus: update.
do
    ---@type LDebounce
    local db = lurek.patterns.newDebounce(0.5)
    db:onFire(function()
        print("  debounce fired!")
    end)
    db:trigger()
    print("pending = " .. tostring(db:isPending()))
    db:update(0.3)
    db:trigger()
    db:update(0.3)
    db:update(0.3)
    print("fire count = " .. db:getFireCount())
end

--@api-stub: LDebounce:onFire
-- Debounce delays action until input stops. Focus: onFire.
do
    ---@type LDebounce
    local db = lurek.patterns.newDebounce(0.5)
    db:onFire(function()
        print("  debounce fired!")
    end)
    db:trigger()
    print("pending = " .. tostring(db:isPending()))
    db:update(0.3)
    db:trigger()
    db:update(0.3)
    db:update(0.3)
    print("fire count = " .. db:getFireCount())
end

--@api-stub: LDebounce:cancel
-- Debounce cancellation. Focus: cancel.
do
    ---@type LDebounce
    local db = lurek.patterns.newDebounce(1.0)
    db:onFire(function() print("  should not fire") end)
    db:trigger()
    print("pending = " .. tostring(db:isPending()))
    db:cancel()
    print("after cancel: pending = " .. tostring(db:isPending()))
    db:update(2.0)
    print("fire count = " .. db:getFireCount())
end

--@api-stub: LDebounce:isPending
-- Debounce cancellation. Focus: isPending.
do
    ---@type LDebounce
    local db = lurek.patterns.newDebounce(1.0)
    db:onFire(function() print("  should not fire") end)
    db:trigger()
    print("pending = " .. tostring(db:isPending()))
    db:cancel()
    print("after cancel: pending = " .. tostring(db:isPending()))
    db:update(2.0)
    print("fire count = " .. db:getFireCount())
end

--@api-stub: LDebounce:getFireCount
-- Debounce cancellation. Focus: getFireCount.
do
    ---@type LDebounce
    local db = lurek.patterns.newDebounce(1.0)
    db:onFire(function() print("  should not fire") end)
    db:trigger()
    print("pending = " .. tostring(db:isPending()))
    db:cancel()
    print("after cancel: pending = " .. tostring(db:isPending()))
    db:update(2.0)
    print("fire count = " .. db:getFireCount())
end

--@api-stub: lurek.patterns.newThrottle
-- Throttle limits action frequency. Focus: newThrottle.
do
    ---@type LThrottle
    local th = lurek.patterns.newThrottle(0.2)
    local fires = 0
    th:onFire(function()
        fires = fires + 1
    end)
    for _ = 1, 10 do
        th:update(0.1)
    end
    print("fires over 1s at 0.2 interval = " .. fires)
    print("fire count = " .. th:getFireCount())
end

--@api-stub: LThrottle:onFire
-- Throttle limits action frequency. Focus: onFire.
do
    ---@type LThrottle
    local th = lurek.patterns.newThrottle(0.2)
    local fires = 0
    th:onFire(function()
        fires = fires + 1
    end)
    for _ = 1, 10 do
        th:update(0.1)
    end
    print("fires over 1s at 0.2 interval = " .. fires)
    print("fire count = " .. th:getFireCount())
end

--@api-stub: LThrottle:update
-- Throttle limits action frequency. Focus: update.
do
    ---@type LThrottle
    local th = lurek.patterns.newThrottle(0.2)
    local fires = 0
    th:onFire(function()
        fires = fires + 1
    end)
    for _ = 1, 10 do
        th:update(0.1)
    end
    print("fires over 1s at 0.2 interval = " .. fires)
    print("fire count = " .. th:getFireCount())
end

--@api-stub: LThrottle:getFireCount
-- Throttle limits action frequency. Focus: getFireCount.
do
    ---@type LThrottle
    local th = lurek.patterns.newThrottle(0.2)
    local fires = 0
    th:onFire(function()
        fires = fires + 1
    end)
    for _ = 1, 10 do
        th:update(0.1)
    end
    print("fires over 1s at 0.2 interval = " .. fires)
    print("fire count = " .. th:getFireCount())
end

--@api-stub: LThrottle:reset
-- Throttle control. Focus: reset.
do
    ---@type LThrottle
    local th = lurek.patterns.newThrottle(1.0)
    th:onFire(function() end)
    th:update(0.5)
    print("progress = " .. th:getProgress())
    th:reset()
    print("after reset progress = " .. th:getProgress())
    th:setEnabled(false)
    th:update(5.0)
    print("disabled progress = " .. th:getProgress())
end

--@api-stub: LThrottle:setEnabled
-- Throttle control. Focus: setEnabled.
do
    ---@type LThrottle
    local th = lurek.patterns.newThrottle(1.0)
    th:onFire(function() end)
    th:update(0.5)
    print("progress = " .. th:getProgress())
    th:reset()
    print("after reset progress = " .. th:getProgress())
    th:setEnabled(false)
    th:update(5.0)
    print("disabled progress = " .. th:getProgress())
end

--@api-stub: LThrottle:getProgress
-- Throttle control. Focus: getProgress.
do
    ---@type LThrottle
    local th = lurek.patterns.newThrottle(1.0)
    th:onFire(function() end)
    th:update(0.5)
    print("progress = " .. th:getProgress())
    th:reset()
    print("after reset progress = " .. th:getProgress())
    th:setEnabled(false)
    th:update(5.0)
    print("disabled progress = " .. th:getProgress())
end

--@api-stub: lurek.patterns.newFunnel
-- Batching funnel collects events and flushes together. Focus: newFunnel.
do
    ---@type LFunnel
    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries)
        print("  flushed " .. #entries .. " entries")
        for _, e in ipairs(entries) do
            print("    " .. e.tag .. " = " .. e.value)
        end
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:push("fire", 8)
    print("pending = " .. funnel:pendingCount())
    funnel:update(1.1)
    print("flush count = " .. funnel:getFlushCount())
end

--@api-stub: LFunnel:push
-- Batching funnel collects events and flushes together. Focus: push.
do
    ---@type LFunnel
    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries)
        print("  flushed " .. #entries .. " entries")
        for _, e in ipairs(entries) do
            print("    " .. e.tag .. " = " .. e.value)
        end
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:push("fire", 8)
    print("pending = " .. funnel:pendingCount())
    funnel:update(1.1)
    print("flush count = " .. funnel:getFlushCount())
end

--@api-stub: LFunnel:update
-- Batching funnel collects events and flushes together. Focus: update.
do
    ---@type LFunnel
    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries)
        print("  flushed " .. #entries .. " entries")
        for _, e in ipairs(entries) do
            print("    " .. e.tag .. " = " .. e.value)
        end
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:push("fire", 8)
    print("pending = " .. funnel:pendingCount())
    funnel:update(1.1)
    print("flush count = " .. funnel:getFlushCount())
end

--@api-stub: LFunnel:onFlush
-- Batching funnel collects events and flushes together. Focus: onFlush.
do
    ---@type LFunnel
    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries)
        print("  flushed " .. #entries .. " entries")
        for _, e in ipairs(entries) do
            print("    " .. e.tag .. " = " .. e.value)
        end
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:push("fire", 8)
    print("pending = " .. funnel:pendingCount())
    funnel:update(1.1)
    print("flush count = " .. funnel:getFlushCount())

    -- Mediator routes messages, debounce prevents spam, funnel batches.
    ---@type LMediator
    local med = lurek.patterns.newMediator()

    ---@type LDebounce
    local db = lurek.patterns.newDebounce(0.3)

    ---@type LFunnel
    local funnel = lurek.patterns.newFunnel(1.0, 10, "damage_batch")

    local total_damage = 0
    funnel:onFlush(function(entries)
        for _, e in ipairs(entries) do
            total_damage = total_damage + e.value
        end
        med:send("ui", "damage_total", total_damage)
    end)

    med:on("ui", function(msg, data)
        print("  UI: " .. msg .. " = " .. tostring(data))
    end)

    db:onFire(function()
        funnel:flush()
    end)

    funnel:push("hit", 10)
    funnel:push("hit", 25)
    funnel:push("crit", 50)
    db:trigger()
    db:update(0.4)
    print("total damage = " .. total_damage)
    print("funnel pending = " .. funnel:pendingCount())
end

--@api-stub: LFunnel:flush
-- Funnel manual control. Focus: flush.
do
    ---@type LFunnel
    local funnel = lurek.patterns.newFunnel(5.0, 0)
    funnel:onFlush(function(entries)
        print("  manual flush: " .. #entries)
    end)
    funnel:push("event_a", 1)
    funnel:push("event_b", 2)
    funnel:flush()
    print("flush count = " .. funnel:getFlushCount())
    funnel:push("event_c", 3)
    funnel:discard()
    print("after discard: pending = " .. funnel:pendingCount())
end

--@api-stub: LFunnel:discard
-- Funnel manual control. Focus: discard.
do
    ---@type LFunnel
    local funnel = lurek.patterns.newFunnel(5.0, 0)
    funnel:onFlush(function(entries)
        print("  manual flush: " .. #entries)
    end)
    funnel:push("event_a", 1)
    funnel:push("event_b", 2)
    funnel:flush()
    print("flush count = " .. funnel:getFlushCount())
    funnel:push("event_c", 3)
    funnel:discard()
    print("after discard: pending = " .. funnel:pendingCount())
end

--@api-stub: LFunnel:pendingCount
-- Funnel manual control. Focus: pendingCount.
do
    ---@type LFunnel
    local funnel = lurek.patterns.newFunnel(5.0, 0)
    funnel:onFlush(function(entries)
        print("  manual flush: " .. #entries)
    end)
    funnel:push("event_a", 1)
    funnel:push("event_b", 2)
    funnel:flush()
    print("flush count = " .. funnel:getFlushCount())
    funnel:push("event_c", 3)
    funnel:discard()
    print("after discard: pending = " .. funnel:pendingCount())
end

--@api-stub: LFunnel:getFlushCount
-- Funnel manual control. Focus: getFlushCount.
do
    ---@type LFunnel
    local funnel = lurek.patterns.newFunnel(5.0, 0)
    funnel:onFlush(function(entries)
        print("  manual flush: " .. #entries)
    end)
    funnel:push("event_a", 1)
    funnel:push("event_b", 2)
    funnel:flush()
    print("flush count = " .. funnel:getFlushCount())
    funnel:push("event_c", 3)
    funnel:discard()
    print("after discard: pending = " .. funnel:pendingCount())
end

--- Patterns Module Part 4: graph, collections (list, map, set, stack, queue, ring, priority queue, weighted random, relationships)


--@api-stub: lurek.patterns.newGraph
-- Directed graph creation. Focus: newGraph.
do
    ---@type LPatternGraph
    local g = lurek.patterns.newGraph(false)
    local a = g:addNode("A", {cost = 10})
    local b = g:addNode("B", {cost = 5})
    local c = g:addNode("C")
    local e1 = g:addEdge(a, b, 1.0, "road")
    local e2 = g:addEdge(b, c, 2.5)
    print("nodes = " .. g:nodeCount() .. " edges = " .. g:edgeCount())
end

--@api-stub: LPatternGraph:addNode
-- Directed graph creation. Focus: addNode.
do
    ---@type LPatternGraph
    local g = lurek.patterns.newGraph(false)
    local a = g:addNode("A", {cost = 10})
    local b = g:addNode("B", {cost = 5})
    local c = g:addNode("C")
    local e1 = g:addEdge(a, b, 1.0, "road")
    local e2 = g:addEdge(b, c, 2.5)
    print("nodes = " .. g:nodeCount() .. " edges = " .. g:edgeCount())
end

--@api-stub: LPatternGraph:addEdge
-- Directed graph creation. Focus: addEdge.
do
    ---@type LPatternGraph
    local g = lurek.patterns.newGraph(false)
    local a = g:addNode("A", {cost = 10})
    local b = g:addNode("B", {cost = 5})
    local c = g:addNode("C")
    local e1 = g:addEdge(a, b, 1.0, "road")
    local e2 = g:addEdge(b, c, 2.5)
    print("nodes = " .. g:nodeCount() .. " edges = " .. g:edgeCount())
end

--@api-stub: LPatternGraph:nodeCount
-- Directed graph creation. Focus: nodeCount.
do
    ---@type LPatternGraph
    local g = lurek.patterns.newGraph(false)
    local a = g:addNode("A", {cost = 10})
    local b = g:addNode("B", {cost = 5})
    local c = g:addNode("C")
    local e1 = g:addEdge(a, b, 1.0, "road")
    local e2 = g:addEdge(b, c, 2.5)
    print("nodes = " .. g:nodeCount() .. " edges = " .. g:edgeCount())
end

--@api-stub: LPatternGraph:edgeCount
-- Directed graph creation. Focus: edgeCount.
do
    ---@type LPatternGraph
    local g = lurek.patterns.newGraph(false)
    local a = g:addNode("A", {cost = 10})
    local b = g:addNode("B", {cost = 5})
    local c = g:addNode("C")
    local e1 = g:addEdge(a, b, 1.0, "road")
    local e2 = g:addEdge(b, c, 2.5)
    print("nodes = " .. g:nodeCount() .. " edges = " .. g:edgeCount())
end

--@api-stub: LPatternGraph:bfs
-- Graph traversal and queries. Focus: bfs.
do
    ---@type LPatternGraph
    local g = lurek.patterns.newGraph(true)
    local n1 = g:addNode("start")
    local n2 = g:addNode("mid")
    local n3 = g:addNode("end")
    local n4 = g:addNode("isolated")
    g:addEdge(n1, n2)
    g:addEdge(n2, n3)
    local bfs_order = g:bfs(n1)
    print("BFS from start = " .. #bfs_order .. " nodes")
    local dfs_order = g:dfs(n1)
    print("DFS from start = " .. #dfs_order .. " nodes")
    print("start→end connected = " .. tostring(g:isConnected(n1, n3)))
    print("start→isolated connected = " .. tostring(g:isConnected(n1, n4)))
    local neighbors = g:neighbors(n2)
    print("mid neighbors = " .. #neighbors)
    print("has n1 = " .. tostring(g:hasNode(n1)))
end

--@api-stub: LPatternGraph:dfs
-- Graph traversal and queries. Focus: dfs.
do
    ---@type LPatternGraph
    local g = lurek.patterns.newGraph(true)
    local n1 = g:addNode("start")
    local n2 = g:addNode("mid")
    local n3 = g:addNode("end")
    local n4 = g:addNode("isolated")
    g:addEdge(n1, n2)
    g:addEdge(n2, n3)
    local bfs_order = g:bfs(n1)
    print("BFS from start = " .. #bfs_order .. " nodes")
    local dfs_order = g:dfs(n1)
    print("DFS from start = " .. #dfs_order .. " nodes")
    print("start→end connected = " .. tostring(g:isConnected(n1, n3)))
    print("start→isolated connected = " .. tostring(g:isConnected(n1, n4)))
    local neighbors = g:neighbors(n2)
    print("mid neighbors = " .. #neighbors)
    print("has n1 = " .. tostring(g:hasNode(n1)))
end

--@api-stub: LPatternGraph:isConnected
-- Graph traversal and queries. Focus: isConnected.
do
    ---@type LPatternGraph
    local g = lurek.patterns.newGraph(true)
    local n1 = g:addNode("start")
    local n2 = g:addNode("mid")
    local n3 = g:addNode("end")
    local n4 = g:addNode("isolated")
    g:addEdge(n1, n2)
    g:addEdge(n2, n3)
    local bfs_order = g:bfs(n1)
    print("BFS from start = " .. #bfs_order .. " nodes")
    local dfs_order = g:dfs(n1)
    print("DFS from start = " .. #dfs_order .. " nodes")
    print("start→end connected = " .. tostring(g:isConnected(n1, n3)))
    print("start→isolated connected = " .. tostring(g:isConnected(n1, n4)))
    local neighbors = g:neighbors(n2)
    print("mid neighbors = " .. #neighbors)
    print("has n1 = " .. tostring(g:hasNode(n1)))
end

--@api-stub: LPatternGraph:neighbors
-- Graph traversal and queries. Focus: neighbors.
do
    ---@type LPatternGraph
    local g = lurek.patterns.newGraph(true)
    local n1 = g:addNode("start")
    local n2 = g:addNode("mid")
    local n3 = g:addNode("end")
    local n4 = g:addNode("isolated")
    g:addEdge(n1, n2)
    g:addEdge(n2, n3)
    local bfs_order = g:bfs(n1)
    print("BFS from start = " .. #bfs_order .. " nodes")
    local dfs_order = g:dfs(n1)
    print("DFS from start = " .. #dfs_order .. " nodes")
    print("start→end connected = " .. tostring(g:isConnected(n1, n3)))
    print("start→isolated connected = " .. tostring(g:isConnected(n1, n4)))
    local neighbors = g:neighbors(n2)
    print("mid neighbors = " .. #neighbors)
    print("has n1 = " .. tostring(g:hasNode(n1)))
end

--@api-stub: LPatternGraph:hasNode
-- Graph traversal and queries. Focus: hasNode.
do
    ---@type LPatternGraph
    local g = lurek.patterns.newGraph(true)
    local n1 = g:addNode("start")
    local n2 = g:addNode("mid")
    local n3 = g:addNode("end")
    local n4 = g:addNode("isolated")
    g:addEdge(n1, n2)
    g:addEdge(n2, n3)
    local bfs_order = g:bfs(n1)
    print("BFS from start = " .. #bfs_order .. " nodes")
    local dfs_order = g:dfs(n1)
    print("DFS from start = " .. #dfs_order .. " nodes")
    print("start→end connected = " .. tostring(g:isConnected(n1, n3)))
    print("start→isolated connected = " .. tostring(g:isConnected(n1, n4)))
    local neighbors = g:neighbors(n2)
    print("mid neighbors = " .. #neighbors)
    print("has n1 = " .. tostring(g:hasNode(n1)))
end

--@api-stub: LPatternGraph:getNodeValue
-- Graph modification. Focus: getNodeValue.
do
    ---@type LPatternGraph
    local g = lurek.patterns.newGraph()
    local a = g:addNode("room", {size = 10})
    local b = g:addNode("hall")
    local e = g:addEdge(a, b, 1.0)
    local val = g:getNodeValue(a)
    if val then print("room size = " .. val.size) end
    g:removeEdge(e)
    print("after edge remove: edges = " .. g:edgeCount())
    g:removeNode(b)
    print("after node remove: nodes = " .. g:nodeCount())
    g:clearAll()
    print("after clear: nodes = " .. g:nodeCount())
end

--@api-stub: LPatternGraph:removeNode
-- Graph modification. Focus: removeNode.
do
    ---@type LPatternGraph
    local g = lurek.patterns.newGraph()
    local a = g:addNode("room", {size = 10})
    local b = g:addNode("hall")
    local e = g:addEdge(a, b, 1.0)
    local val = g:getNodeValue(a)
    if val then print("room size = " .. val.size) end
    g:removeEdge(e)
    print("after edge remove: edges = " .. g:edgeCount())
    g:removeNode(b)
    print("after node remove: nodes = " .. g:nodeCount())
    g:clearAll()
    print("after clear: nodes = " .. g:nodeCount())
end

--@api-stub: LPatternGraph:removeEdge
-- Graph modification. Focus: removeEdge.
do
    ---@type LPatternGraph
    local g = lurek.patterns.newGraph()
    local a = g:addNode("room", {size = 10})
    local b = g:addNode("hall")
    local e = g:addEdge(a, b, 1.0)
    local val = g:getNodeValue(a)
    if val then print("room size = " .. val.size) end
    g:removeEdge(e)
    print("after edge remove: edges = " .. g:edgeCount())
    g:removeNode(b)
    print("after node remove: nodes = " .. g:nodeCount())
    g:clearAll()
    print("after clear: nodes = " .. g:nodeCount())
end

--@api-stub: LPatternGraph:clearAll
-- Graph modification. Focus: clearAll.
do
    ---@type LPatternGraph
    local g = lurek.patterns.newGraph()
    local a = g:addNode("room", {size = 10})
    local b = g:addNode("hall")
    local e = g:addEdge(a, b, 1.0)
    local val = g:getNodeValue(a)
    if val then print("room size = " .. val.size) end
    g:removeEdge(e)
    print("after edge remove: edges = " .. g:edgeCount())
    g:removeNode(b)
    print("after node remove: nodes = " .. g:nodeCount())
    g:clearAll()
    print("after clear: nodes = " .. g:nodeCount())
end

--@api-stub: lurek.patterns.newList
-- Dynamic list. Focus: newList.
do
    ---@type LList
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    print("len = " .. list:len())
    print("get(2) = " .. list:get(2))
    print("indexOf beta = " .. list:indexOf("beta"))
    list:remove(2)
    print("after remove: len = " .. list:len())
end

--@api-stub: LList:add
-- Dynamic list. Focus: add.
do
    ---@type LList
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    print("len = " .. list:len())
    print("get(2) = " .. list:get(2))
    print("indexOf beta = " .. list:indexOf("beta"))
    list:remove(2)
    print("after remove: len = " .. list:len())
end

--@api-stub: LList:get
-- Dynamic list. Focus: get.
do
    ---@type LList
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    print("len = " .. list:len())
    print("get(2) = " .. list:get(2))
    print("indexOf beta = " .. list:indexOf("beta"))
    list:remove(2)
    print("after remove: len = " .. list:len())
end

--@api-stub: LList:len
-- Dynamic list. Focus: len.
do
    ---@type LList
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    print("len = " .. list:len())
    print("get(2) = " .. list:get(2))
    print("indexOf beta = " .. list:indexOf("beta"))
    list:remove(2)
    print("after remove: len = " .. list:len())
end

--@api-stub: LList:remove
-- Dynamic list. Focus: remove.
do
    ---@type LList
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    print("len = " .. list:len())
    print("get(2) = " .. list:get(2))
    print("indexOf beta = " .. list:indexOf("beta"))
    list:remove(2)
    print("after remove: len = " .. list:len())
end

--@api-stub: LList:indexOf
-- Dynamic list. Focus: indexOf.
do
    ---@type LList
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    print("len = " .. list:len())
    print("get(2) = " .. list:get(2))
    print("indexOf beta = " .. list:indexOf("beta"))
    list:remove(2)
    print("after remove: len = " .. list:len())
end

--@api-stub: LList:push
-- List operations. Focus: push.
do
    ---@type LList
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    list:insert(2, "x")
    list:set(1, "A")
    print("contains x = " .. tostring(list:contains("x")))
    list:unshift("first")
    local shifted = list:shift()
    print("shifted = " .. shifted)
    local popped = list:pop()
    print("popped = " .. popped)
    list:reverse()
    local arr = list:toArray()
    print("array len = " .. #arr)
    list:clear()
    print("empty = " .. tostring(list:isEmpty()))
end

--@api-stub: LList:pop
-- List operations. Focus: pop.
do
    ---@type LList
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    list:insert(2, "x")
    list:set(1, "A")
    print("contains x = " .. tostring(list:contains("x")))
    list:unshift("first")
    local shifted = list:shift()
    print("shifted = " .. shifted)
    local popped = list:pop()
    print("popped = " .. popped)
    list:reverse()
    local arr = list:toArray()
    print("array len = " .. #arr)
    list:clear()
    print("empty = " .. tostring(list:isEmpty()))
end

--@api-stub: LList:insert
-- List operations. Focus: insert.
do
    ---@type LList
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    list:insert(2, "x")
    list:set(1, "A")
    print("contains x = " .. tostring(list:contains("x")))
    list:unshift("first")
    local shifted = list:shift()
    print("shifted = " .. shifted)
    local popped = list:pop()
    print("popped = " .. popped)
    list:reverse()
    local arr = list:toArray()
    print("array len = " .. #arr)
    list:clear()
    print("empty = " .. tostring(list:isEmpty()))
end

--@api-stub: LList:set
-- List operations. Focus: set.
do
    ---@type LList
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    list:insert(2, "x")
    list:set(1, "A")
    print("contains x = " .. tostring(list:contains("x")))
    list:unshift("first")
    local shifted = list:shift()
    print("shifted = " .. shifted)
    local popped = list:pop()
    print("popped = " .. popped)
    list:reverse()
    local arr = list:toArray()
    print("array len = " .. #arr)
    list:clear()
    print("empty = " .. tostring(list:isEmpty()))
end

--@api-stub: LList:shift
-- List operations. Focus: shift.
do
    ---@type LList
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    list:insert(2, "x")
    list:set(1, "A")
    print("contains x = " .. tostring(list:contains("x")))
    list:unshift("first")
    local shifted = list:shift()
    print("shifted = " .. shifted)
    local popped = list:pop()
    print("popped = " .. popped)
    list:reverse()
    local arr = list:toArray()
    print("array len = " .. #arr)
    list:clear()
    print("empty = " .. tostring(list:isEmpty()))
end

--@api-stub: LList:unshift
-- List operations. Focus: unshift.
do
    ---@type LList
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    list:insert(2, "x")
    list:set(1, "A")
    print("contains x = " .. tostring(list:contains("x")))
    list:unshift("first")
    local shifted = list:shift()
    print("shifted = " .. shifted)
    local popped = list:pop()
    print("popped = " .. popped)
    list:reverse()
    local arr = list:toArray()
    print("array len = " .. #arr)
    list:clear()
    print("empty = " .. tostring(list:isEmpty()))
end

--@api-stub: LList:contains
-- List operations. Focus: contains.
do
    ---@type LList
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    list:insert(2, "x")
    list:set(1, "A")
    print("contains x = " .. tostring(list:contains("x")))
    list:unshift("first")
    local shifted = list:shift()
    print("shifted = " .. shifted)
    local popped = list:pop()
    print("popped = " .. popped)
    list:reverse()
    local arr = list:toArray()
    print("array len = " .. #arr)
    list:clear()
    print("empty = " .. tostring(list:isEmpty()))
end

--@api-stub: LList:reverse
-- List operations. Focus: reverse.
do
    ---@type LList
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    list:insert(2, "x")
    list:set(1, "A")
    print("contains x = " .. tostring(list:contains("x")))
    list:unshift("first")
    local shifted = list:shift()
    print("shifted = " .. shifted)
    local popped = list:pop()
    print("popped = " .. popped)
    list:reverse()
    local arr = list:toArray()
    print("array len = " .. #arr)
    list:clear()
    print("empty = " .. tostring(list:isEmpty()))
end

--@api-stub: LList:toArray
-- List operations. Focus: toArray.
do
    ---@type LList
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    list:insert(2, "x")
    list:set(1, "A")
    print("contains x = " .. tostring(list:contains("x")))
    list:unshift("first")
    local shifted = list:shift()
    print("shifted = " .. shifted)
    local popped = list:pop()
    print("popped = " .. popped)
    list:reverse()
    local arr = list:toArray()
    print("array len = " .. #arr)
    list:clear()
    print("empty = " .. tostring(list:isEmpty()))
end

--@api-stub: LList:isEmpty
-- List operations. Focus: isEmpty.
do
    ---@type LList
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    list:insert(2, "x")
    list:set(1, "A")
    print("contains x = " .. tostring(list:contains("x")))
    list:unshift("first")
    local shifted = list:shift()
    print("shifted = " .. shifted)
    local popped = list:pop()
    print("popped = " .. popped)
    list:reverse()
    local arr = list:toArray()
    print("array len = " .. #arr)
    list:clear()
    print("empty = " .. tostring(list:isEmpty()))
end

--@api-stub: lurek.patterns.newMap
-- String-keyed map. Focus: newMap.
do
    ---@type LMap
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    map:set("class", "warrior")
    print("name = " .. map:get("name"))
    print("has level = " .. tostring(map:has("level")))
    print("len = " .. map:len())
    map:remove("class")
    print("keys = " .. #map:keys())
    print("values = " .. #map:values())
end

--@api-stub: LMap:set
-- String-keyed map. Focus: set.
do
    ---@type LMap
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    map:set("class", "warrior")
    print("name = " .. map:get("name"))
    print("has level = " .. tostring(map:has("level")))
    print("len = " .. map:len())
    map:remove("class")
    print("keys = " .. #map:keys())
    print("values = " .. #map:values())

    -- Undo/redo with change notification and state tracking in map.
    ---@type LMap
    local state = lurek.patterns.newMap()
    state:set("x", 100)
    state:set("y", 200)

    ---@type LObserver
    local obs = lurek.patterns.newObserver("position")

    ---@type LCommandStack
    local cmds = lurek.patterns.newCommandStack(20)

    local move_step = 0
    obs:subscribe("moved", function(_, step)
        print("  move step: " .. tostring(step))
    end)

    cmds:execute("move_right",
        function()
            local x = state:get("x")
            state:set("x", x + 50)
            move_step = move_step + 1
            obs:set("moved", move_step)
        end,
        function()
            local x = state:get("x")
            state:set("x", x - 50)
            move_step = move_step + 1
            obs:set("moved", move_step)
        end
    )
    cmds:execute("move_down",
        function()
            local y = state:get("y")
            state:set("y", y + 30)
            move_step = move_step + 1
            obs:set("moved", move_step)
        end,
        function()
            local y = state:get("y")
            state:set("y", y - 30)
            move_step = move_step + 1
            obs:set("moved", move_step)
        end
    )
    print("pos = " .. state:get("x") .. "," .. state:get("y"))
    cmds:undo()
    print("after undo = " .. state:get("x") .. "," .. state:get("y"))
    cmds:redo()
    print("after redo = " .. state:get("x") .. "," .. state:get("y"))
end

--@api-stub: LMap:get
-- String-keyed map. Focus: get.
do
    ---@type LMap
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    map:set("class", "warrior")
    print("name = " .. map:get("name"))
    print("has level = " .. tostring(map:has("level")))
    print("len = " .. map:len())
    map:remove("class")
    print("keys = " .. #map:keys())
    print("values = " .. #map:values())
end

--@api-stub: LMap:has
-- String-keyed map. Focus: has.
do
    ---@type LMap
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    map:set("class", "warrior")
    print("name = " .. map:get("name"))
    print("has level = " .. tostring(map:has("level")))
    print("len = " .. map:len())
    map:remove("class")
    print("keys = " .. #map:keys())
    print("values = " .. #map:values())
end

--@api-stub: LMap:remove
-- String-keyed map. Focus: remove.
do
    ---@type LMap
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    map:set("class", "warrior")
    print("name = " .. map:get("name"))
    print("has level = " .. tostring(map:has("level")))
    print("len = " .. map:len())
    map:remove("class")
    print("keys = " .. #map:keys())
    print("values = " .. #map:values())
end

--@api-stub: LMap:keys
-- String-keyed map. Focus: keys.
do
    ---@type LMap
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    map:set("class", "warrior")
    print("name = " .. map:get("name"))
    print("has level = " .. tostring(map:has("level")))
    print("len = " .. map:len())
    map:remove("class")
    print("keys = " .. #map:keys())
    print("values = " .. #map:values())
end

--@api-stub: LMap:values
-- String-keyed map. Focus: values.
do
    ---@type LMap
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    map:set("class", "warrior")
    print("name = " .. map:get("name"))
    print("has level = " .. tostring(map:has("level")))
    print("len = " .. map:len())
    map:remove("class")
    print("keys = " .. #map:keys())
    print("values = " .. #map:values())
end

--@api-stub: LMap:len
-- String-keyed map. Focus: len.
do
    ---@type LMap
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    map:set("class", "warrior")
    print("name = " .. map:get("name"))
    print("has level = " .. tostring(map:has("level")))
    print("len = " .. map:len())
    map:remove("class")
    print("keys = " .. #map:keys())
    print("values = " .. #map:values())
end

--@api-stub: LMap:entries
-- Map merge and entries. Focus: entries.
do
    ---@type LMap
    local m1 = lurek.patterns.newMap()
    m1:set("a", 1)
    m1:set("b", 2)
    ---@type LMap
    local m2 = lurek.patterns.newMap()
    m2:set("b", 99)
    m2:set("c", 3)
    m1:merge(m2)
    print("after merge: b = " .. m1:get("b"))
    local entries = m1:entries()
    print("entries = " .. #entries)
    print("empty = " .. tostring(m1:isEmpty()))
    m1:clear()
    print("after clear: empty = " .. tostring(m1:isEmpty()))
end

--@api-stub: LMap:merge
-- Map merge and entries. Focus: merge.
do
    ---@type LMap
    local m1 = lurek.patterns.newMap()
    m1:set("a", 1)
    m1:set("b", 2)
    ---@type LMap
    local m2 = lurek.patterns.newMap()
    m2:set("b", 99)
    m2:set("c", 3)
    m1:merge(m2)
    print("after merge: b = " .. m1:get("b"))
    local entries = m1:entries()
    print("entries = " .. #entries)
    print("empty = " .. tostring(m1:isEmpty()))
    m1:clear()
    print("after clear: empty = " .. tostring(m1:isEmpty()))
end

--@api-stub: LMap:isEmpty
-- Map merge and entries. Focus: isEmpty.
do
    ---@type LMap
    local m1 = lurek.patterns.newMap()
    m1:set("a", 1)
    m1:set("b", 2)
    ---@type LMap
    local m2 = lurek.patterns.newMap()
    m2:set("b", 99)
    m2:set("c", 3)
    m1:merge(m2)
    print("after merge: b = " .. m1:get("b"))
    local entries = m1:entries()
    print("entries = " .. #entries)
    print("empty = " .. tostring(m1:isEmpty()))
    m1:clear()
    print("after clear: empty = " .. tostring(m1:isEmpty()))
end

--@api-stub: LMap:clear
-- Map merge and entries. Focus: clear.
do
    ---@type LMap
    local m1 = lurek.patterns.newMap()
    m1:set("a", 1)
    m1:set("b", 2)
    ---@type LMap
    local m2 = lurek.patterns.newMap()
    m2:set("b", 99)
    m2:set("c", 3)
    m1:merge(m2)
    print("after merge: b = " .. m1:get("b"))
    local entries = m1:entries()
    print("entries = " .. #entries)
    print("empty = " .. tostring(m1:isEmpty()))
    m1:clear()
    print("after clear: empty = " .. tostring(m1:isEmpty()))
end

--@api-stub: lurek.patterns.newSet
-- String set. Focus: newSet.
do
    ---@type LSet
    local s = lurek.patterns.newSet()
    print("added = " .. tostring(s:add("fire")))
    print("dup = " .. tostring(s:add("fire")))
    s:add("ice")
    s:add("wind")
    print("has fire = " .. tostring(s:has("fire")))
    print("len = " .. s:len())
    s:remove("ice")
    local arr = s:toArray()
    print("array = " .. #arr)
end

--@api-stub: LSet:add
-- String set. Focus: add.
do
    ---@type LSet
    local s = lurek.patterns.newSet()
    print("added = " .. tostring(s:add("fire")))
    print("dup = " .. tostring(s:add("fire")))
    s:add("ice")
    s:add("wind")
    print("has fire = " .. tostring(s:has("fire")))
    print("len = " .. s:len())
    s:remove("ice")
    local arr = s:toArray()
    print("array = " .. #arr)
end

--@api-stub: LSet:has
-- String set. Focus: has.
do
    ---@type LSet
    local s = lurek.patterns.newSet()
    print("added = " .. tostring(s:add("fire")))
    print("dup = " .. tostring(s:add("fire")))
    s:add("ice")
    s:add("wind")
    print("has fire = " .. tostring(s:has("fire")))
    print("len = " .. s:len())
    s:remove("ice")
    local arr = s:toArray()
    print("array = " .. #arr)
end

--@api-stub: LSet:remove
-- String set. Focus: remove.
do
    ---@type LSet
    local s = lurek.patterns.newSet()
    print("added = " .. tostring(s:add("fire")))
    print("dup = " .. tostring(s:add("fire")))
    s:add("ice")
    s:add("wind")
    print("has fire = " .. tostring(s:has("fire")))
    print("len = " .. s:len())
    s:remove("ice")
    local arr = s:toArray()
    print("array = " .. #arr)
end

--@api-stub: LSet:len
-- String set. Focus: len.
do
    ---@type LSet
    local s = lurek.patterns.newSet()
    print("added = " .. tostring(s:add("fire")))
    print("dup = " .. tostring(s:add("fire")))
    s:add("ice")
    s:add("wind")
    print("has fire = " .. tostring(s:has("fire")))
    print("len = " .. s:len())
    s:remove("ice")
    local arr = s:toArray()
    print("array = " .. #arr)
end

--@api-stub: LSet:toArray
-- String set. Focus: toArray.
do
    ---@type LSet
    local s = lurek.patterns.newSet()
    print("added = " .. tostring(s:add("fire")))
    print("dup = " .. tostring(s:add("fire")))
    s:add("ice")
    s:add("wind")
    print("has fire = " .. tostring(s:has("fire")))
    print("len = " .. s:len())
    s:remove("ice")
    local arr = s:toArray()
    print("array = " .. #arr)
end

--@api-stub: LSet:union
-- Set algebra. Focus: union.
do
    ---@type LSet
    local a = lurek.patterns.newSet()
    a:add("x")
    a:add("y")
    a:add("z")
    ---@type LSet
    local b = lurek.patterns.newSet()
    b:add("y")
    b:add("z")
    b:add("w")
    local u = a:union(b)
    print("union = " .. u:len())
    local i = a:intersection(b)
    print("intersection = " .. i:len())
    a:clear()
    print("empty = " .. tostring(a:isEmpty()))
end

--@api-stub: LSet:intersection
-- Set algebra. Focus: intersection.
do
    ---@type LSet
    local a = lurek.patterns.newSet()
    a:add("x")
    a:add("y")
    a:add("z")
    ---@type LSet
    local b = lurek.patterns.newSet()
    b:add("y")
    b:add("z")
    b:add("w")
    local u = a:union(b)
    print("union = " .. u:len())
    local i = a:intersection(b)
    print("intersection = " .. i:len())
    a:clear()
    print("empty = " .. tostring(a:isEmpty()))
end

--@api-stub: LSet:isEmpty
-- Set algebra. Focus: isEmpty.
do
    ---@type LSet
    local a = lurek.patterns.newSet()
    a:add("x")
    a:add("y")
    a:add("z")
    ---@type LSet
    local b = lurek.patterns.newSet()
    b:add("y")
    b:add("z")
    b:add("w")
    local u = a:union(b)
    print("union = " .. u:len())
    local i = a:intersection(b)
    print("intersection = " .. i:len())
    a:clear()
    print("empty = " .. tostring(a:isEmpty()))
end

--@api-stub: LSet:clear
-- Set algebra. Focus: clear.
do
    ---@type LSet
    local a = lurek.patterns.newSet()
    a:add("x")
    a:add("y")
    a:add("z")
    ---@type LSet
    local b = lurek.patterns.newSet()
    b:add("y")
    b:add("z")
    b:add("w")
    local u = a:union(b)
    print("union = " .. u:len())
    local i = a:intersection(b)
    print("intersection = " .. i:len())
    a:clear()
    print("empty = " .. tostring(a:isEmpty()))
end

--@api-stub: lurek.patterns.newStack
-- LIFO stack. Focus: newStack.
do
    ---@type LStack
    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    st:push("third")
    print("peek = " .. st:peek())
    print("len = " .. st:len())
    local v = st:pop()
    print("popped = " .. v)
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:push
-- LIFO stack. Focus: push.
do
    ---@type LStack
    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    st:push("third")
    print("peek = " .. st:peek())
    print("len = " .. st:len())
    local v = st:pop()
    print("popped = " .. v)
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:pop
-- LIFO stack. Focus: pop.
do
    ---@type LStack
    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    st:push("third")
    print("peek = " .. st:peek())
    print("len = " .. st:len())
    local v = st:pop()
    print("popped = " .. v)
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:peek
-- LIFO stack. Focus: peek.
do
    ---@type LStack
    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    st:push("third")
    print("peek = " .. st:peek())
    print("len = " .. st:len())
    local v = st:pop()
    print("popped = " .. v)
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:len
-- LIFO stack. Focus: len.
do
    ---@type LStack
    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    st:push("third")
    print("peek = " .. st:peek())
    print("len = " .. st:len())
    local v = st:pop()
    print("popped = " .. v)
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:isEmpty
-- LIFO stack. Focus: isEmpty.
do
    ---@type LStack
    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    st:push("third")
    print("peek = " .. st:peek())
    print("len = " .. st:len())
    local v = st:pop()
    print("popped = " .. v)
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:pushBottom
-- Advanced stack operations. Focus: pushBottom.
do
    ---@type LStack
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    st:pushBottom("z")
    print("bottom = " .. st:peekBottom())
    print("at 2 = " .. st:peekAt(2))
    st:insertAt(2, "x")
    local removed = st:removeAt(2)
    print("removed = " .. removed)
    local many = st:popMany(2)
    print("popped many = " .. #many)
    st:push("p")
    st:push("q")
    st:moveWithin(1, 2)
    print("full = " .. tostring(st:isFull()))
    local arr = st:toArray()
    print("array = " .. #arr)
    st:clear()
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:popBottom
-- Advanced stack operations. Focus: popBottom.
do
    ---@type LStack
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    st:pushBottom("z")
    print("bottom = " .. st:peekBottom())
    print("at 2 = " .. st:peekAt(2))
    st:insertAt(2, "x")
    local removed = st:removeAt(2)
    print("removed = " .. removed)
    local many = st:popMany(2)
    print("popped many = " .. #many)
    st:push("p")
    st:push("q")
    st:moveWithin(1, 2)
    print("full = " .. tostring(st:isFull()))
    local arr = st:toArray()
    print("array = " .. #arr)
    st:clear()
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:peekBottom
-- Advanced stack operations. Focus: peekBottom.
do
    ---@type LStack
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    st:pushBottom("z")
    print("bottom = " .. st:peekBottom())
    print("at 2 = " .. st:peekAt(2))
    st:insertAt(2, "x")
    local removed = st:removeAt(2)
    print("removed = " .. removed)
    local many = st:popMany(2)
    print("popped many = " .. #many)
    st:push("p")
    st:push("q")
    st:moveWithin(1, 2)
    print("full = " .. tostring(st:isFull()))
    local arr = st:toArray()
    print("array = " .. #arr)
    st:clear()
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:peekAt
-- Advanced stack operations. Focus: peekAt.
do
    ---@type LStack
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    st:pushBottom("z")
    print("bottom = " .. st:peekBottom())
    print("at 2 = " .. st:peekAt(2))
    st:insertAt(2, "x")
    local removed = st:removeAt(2)
    print("removed = " .. removed)
    local many = st:popMany(2)
    print("popped many = " .. #many)
    st:push("p")
    st:push("q")
    st:moveWithin(1, 2)
    print("full = " .. tostring(st:isFull()))
    local arr = st:toArray()
    print("array = " .. #arr)
    st:clear()
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:insertAt
-- Advanced stack operations. Focus: insertAt.
do
    ---@type LStack
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    st:pushBottom("z")
    print("bottom = " .. st:peekBottom())
    print("at 2 = " .. st:peekAt(2))
    st:insertAt(2, "x")
    local removed = st:removeAt(2)
    print("removed = " .. removed)
    local many = st:popMany(2)
    print("popped many = " .. #many)
    st:push("p")
    st:push("q")
    st:moveWithin(1, 2)
    print("full = " .. tostring(st:isFull()))
    local arr = st:toArray()
    print("array = " .. #arr)
    st:clear()
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:removeAt
-- Advanced stack operations. Focus: removeAt.
do
    ---@type LStack
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    st:pushBottom("z")
    print("bottom = " .. st:peekBottom())
    print("at 2 = " .. st:peekAt(2))
    st:insertAt(2, "x")
    local removed = st:removeAt(2)
    print("removed = " .. removed)
    local many = st:popMany(2)
    print("popped many = " .. #many)
    st:push("p")
    st:push("q")
    st:moveWithin(1, 2)
    print("full = " .. tostring(st:isFull()))
    local arr = st:toArray()
    print("array = " .. #arr)
    st:clear()
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:popMany
-- Advanced stack operations. Focus: popMany.
do
    ---@type LStack
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    st:pushBottom("z")
    print("bottom = " .. st:peekBottom())
    print("at 2 = " .. st:peekAt(2))
    st:insertAt(2, "x")
    local removed = st:removeAt(2)
    print("removed = " .. removed)
    local many = st:popMany(2)
    print("popped many = " .. #many)
    st:push("p")
    st:push("q")
    st:moveWithin(1, 2)
    print("full = " .. tostring(st:isFull()))
    local arr = st:toArray()
    print("array = " .. #arr)
    st:clear()
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:moveWithin
-- Advanced stack operations. Focus: moveWithin.
do
    ---@type LStack
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    st:pushBottom("z")
    print("bottom = " .. st:peekBottom())
    print("at 2 = " .. st:peekAt(2))
    st:insertAt(2, "x")
    local removed = st:removeAt(2)
    print("removed = " .. removed)
    local many = st:popMany(2)
    print("popped many = " .. #many)
    st:push("p")
    st:push("q")
    st:moveWithin(1, 2)
    print("full = " .. tostring(st:isFull()))
    local arr = st:toArray()
    print("array = " .. #arr)
    st:clear()
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:isFull
-- Advanced stack operations. Focus: isFull.
do
    ---@type LStack
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    st:pushBottom("z")
    print("bottom = " .. st:peekBottom())
    print("at 2 = " .. st:peekAt(2))
    st:insertAt(2, "x")
    local removed = st:removeAt(2)
    print("removed = " .. removed)
    local many = st:popMany(2)
    print("popped many = " .. #many)
    st:push("p")
    st:push("q")
    st:moveWithin(1, 2)
    print("full = " .. tostring(st:isFull()))
    local arr = st:toArray()
    print("array = " .. #arr)
    st:clear()
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:clear
-- Advanced stack operations. Focus: clear.
do
    ---@type LStack
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    st:pushBottom("z")
    print("bottom = " .. st:peekBottom())
    print("at 2 = " .. st:peekAt(2))
    st:insertAt(2, "x")
    local removed = st:removeAt(2)
    print("removed = " .. removed)
    local many = st:popMany(2)
    print("popped many = " .. #many)
    st:push("p")
    st:push("q")
    st:moveWithin(1, 2)
    print("full = " .. tostring(st:isFull()))
    local arr = st:toArray()
    print("array = " .. #arr)
    st:clear()
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:toArray
-- Advanced stack operations. Focus: toArray.
do
    ---@type LStack
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    st:pushBottom("z")
    print("bottom = " .. st:peekBottom())
    print("at 2 = " .. st:peekAt(2))
    st:insertAt(2, "x")
    local removed = st:removeAt(2)
    print("removed = " .. removed)
    local many = st:popMany(2)
    print("popped many = " .. #many)
    st:push("p")
    st:push("q")
    st:moveWithin(1, 2)
    print("full = " .. tostring(st:isFull()))
    local arr = st:toArray()
    print("array = " .. #arr)
    st:clear()
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: lurek.patterns.newQueue
-- FIFO queue. Focus: newQueue.
do
    ---@type LQueue
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    q:enqueue("msg3")
    print("front = " .. q:front())
    print("back = " .. q:back())
    print("len = " .. q:len())
    local v = q:dequeue()
    print("dequeued = " .. v)
    print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:enqueue
-- FIFO queue. Focus: enqueue.
do
    ---@type LQueue
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    q:enqueue("msg3")
    print("front = " .. q:front())
    print("back = " .. q:back())
    print("len = " .. q:len())
    local v = q:dequeue()
    print("dequeued = " .. v)
    print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:dequeue
-- FIFO queue. Focus: dequeue.
do
    ---@type LQueue
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    q:enqueue("msg3")
    print("front = " .. q:front())
    print("back = " .. q:back())
    print("len = " .. q:len())
    local v = q:dequeue()
    print("dequeued = " .. v)
    print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:front
-- FIFO queue. Focus: front.
do
    ---@type LQueue
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    q:enqueue("msg3")
    print("front = " .. q:front())
    print("back = " .. q:back())
    print("len = " .. q:len())
    local v = q:dequeue()
    print("dequeued = " .. v)
    print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:back
-- FIFO queue. Focus: back.
do
    ---@type LQueue
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    q:enqueue("msg3")
    print("front = " .. q:front())
    print("back = " .. q:back())
    print("len = " .. q:len())
    local v = q:dequeue()
    print("dequeued = " .. v)
    print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:len
-- FIFO queue. Focus: len.
do
    ---@type LQueue
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    q:enqueue("msg3")
    print("front = " .. q:front())
    print("back = " .. q:back())
    print("len = " .. q:len())
    local v = q:dequeue()
    print("dequeued = " .. v)
    print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:isEmpty
-- FIFO queue. Focus: isEmpty.
do
    ---@type LQueue
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    q:enqueue("msg3")
    print("front = " .. q:front())
    print("back = " .. q:back())
    print("len = " .. q:len())
    local v = q:dequeue()
    print("dequeued = " .. v)
    print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:enqueueFront
-- Advanced queue operations. Focus: enqueueFront.
do
    ---@type LQueue
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    q:enqueueFront("priority")
    print("front = " .. q:front())
    local back = q:dequeueBack()
    print("dequeued back = " .. back)
    q:insertAt(2, "inserted")
    print("at 2 = " .. q:peekAt(2))
    local rem = q:removeAt(2)
    print("removed = " .. rem)
    print("full = " .. tostring(q:isFull()))
    local arr = q:toArray()
    print("array = " .. #arr)
    q:clear()
    print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:dequeueBack
-- Advanced queue operations. Focus: dequeueBack.
do
    ---@type LQueue
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    q:enqueueFront("priority")
    print("front = " .. q:front())
    local back = q:dequeueBack()
    print("dequeued back = " .. back)
    q:insertAt(2, "inserted")
    print("at 2 = " .. q:peekAt(2))
    local rem = q:removeAt(2)
    print("removed = " .. rem)
    print("full = " .. tostring(q:isFull()))
    local arr = q:toArray()
    print("array = " .. #arr)
    q:clear()
    print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:insertAt
-- Advanced queue operations. Focus: insertAt.
do
    ---@type LQueue
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    q:enqueueFront("priority")
    print("front = " .. q:front())
    local back = q:dequeueBack()
    print("dequeued back = " .. back)
    q:insertAt(2, "inserted")
    print("at 2 = " .. q:peekAt(2))
    local rem = q:removeAt(2)
    print("removed = " .. rem)
    print("full = " .. tostring(q:isFull()))
    local arr = q:toArray()
    print("array = " .. #arr)
    q:clear()
    print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:removeAt
-- Advanced queue operations. Focus: removeAt.
do
    ---@type LQueue
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    q:enqueueFront("priority")
    print("front = " .. q:front())
    local back = q:dequeueBack()
    print("dequeued back = " .. back)
    q:insertAt(2, "inserted")
    print("at 2 = " .. q:peekAt(2))
    local rem = q:removeAt(2)
    print("removed = " .. rem)
    print("full = " .. tostring(q:isFull()))
    local arr = q:toArray()
    print("array = " .. #arr)
    q:clear()
    print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:peekAt
-- Advanced queue operations. Focus: peekAt.
do
    ---@type LQueue
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    q:enqueueFront("priority")
    print("front = " .. q:front())
    local back = q:dequeueBack()
    print("dequeued back = " .. back)
    q:insertAt(2, "inserted")
    print("at 2 = " .. q:peekAt(2))
    local rem = q:removeAt(2)
    print("removed = " .. rem)
    print("full = " .. tostring(q:isFull()))
    local arr = q:toArray()
    print("array = " .. #arr)
    q:clear()
    print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:isFull
-- Advanced queue operations. Focus: isFull.
do
    ---@type LQueue
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    q:enqueueFront("priority")
    print("front = " .. q:front())
    local back = q:dequeueBack()
    print("dequeued back = " .. back)
    q:insertAt(2, "inserted")
    print("at 2 = " .. q:peekAt(2))
    local rem = q:removeAt(2)
    print("removed = " .. rem)
    print("full = " .. tostring(q:isFull()))
    local arr = q:toArray()
    print("array = " .. #arr)
    q:clear()
    print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:clear
-- Advanced queue operations. Focus: clear.
do
    ---@type LQueue
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    q:enqueueFront("priority")
    print("front = " .. q:front())
    local back = q:dequeueBack()
    print("dequeued back = " .. back)
    q:insertAt(2, "inserted")
    print("at 2 = " .. q:peekAt(2))
    local rem = q:removeAt(2)
    print("removed = " .. rem)
    print("full = " .. tostring(q:isFull()))
    local arr = q:toArray()
    print("array = " .. #arr)
    q:clear()
    print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:toArray
-- Advanced queue operations. Focus: toArray.
do
    ---@type LQueue
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    q:enqueueFront("priority")
    print("front = " .. q:front())
    local back = q:dequeueBack()
    print("dequeued back = " .. back)
    q:insertAt(2, "inserted")
    print("at 2 = " .. q:peekAt(2))
    local rem = q:removeAt(2)
    print("removed = " .. rem)
    print("full = " .. tostring(q:isFull()))
    local arr = q:toArray()
    print("array = " .. #arr)
    q:clear()
    print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: lurek.patterns.newPriorityQueue
-- Priority queue (highest priority first). Focus: newPriorityQueue.
do
    ---@type LPriorityQueue
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    pq:push(5, "mid_task", "mid")
    print("len = " .. pq:len())
    local top = pq:peek()
    if top then print("peek = " .. tostring(top)) end
    local item = pq:pop()
    if item then print("popped = " .. tostring(item)) end
    print("after pop: len = " .. pq:len())
    print("empty = " .. tostring(pq:isEmpty()))
    pq:clearAll()
    print("after clear: empty = " .. tostring(pq:isEmpty()))
end

--@api-stub: LPriorityQueue:push
-- Priority queue (highest priority first). Focus: push.
do
    ---@type LPriorityQueue
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    pq:push(5, "mid_task", "mid")
    print("len = " .. pq:len())
    local top = pq:peek()
    if top then print("peek = " .. tostring(top)) end
    local item = pq:pop()
    if item then print("popped = " .. tostring(item)) end
    print("after pop: len = " .. pq:len())
    print("empty = " .. tostring(pq:isEmpty()))
    pq:clearAll()
    print("after clear: empty = " .. tostring(pq:isEmpty()))
end

--@api-stub: LPriorityQueue:pop
-- Priority queue (highest priority first). Focus: pop.
do
    ---@type LPriorityQueue
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    pq:push(5, "mid_task", "mid")
    print("len = " .. pq:len())
    local top = pq:peek()
    if top then print("peek = " .. tostring(top)) end
    local item = pq:pop()
    if item then print("popped = " .. tostring(item)) end
    print("after pop: len = " .. pq:len())
    print("empty = " .. tostring(pq:isEmpty()))
    pq:clearAll()
    print("after clear: empty = " .. tostring(pq:isEmpty()))
end

--@api-stub: LPriorityQueue:peek
-- Priority queue (highest priority first). Focus: peek.
do
    ---@type LPriorityQueue
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    pq:push(5, "mid_task", "mid")
    print("len = " .. pq:len())
    local top = pq:peek()
    if top then print("peek = " .. tostring(top)) end
    local item = pq:pop()
    if item then print("popped = " .. tostring(item)) end
    print("after pop: len = " .. pq:len())
    print("empty = " .. tostring(pq:isEmpty()))
    pq:clearAll()
    print("after clear: empty = " .. tostring(pq:isEmpty()))
end

--@api-stub: LPriorityQueue:len
-- Priority queue (highest priority first). Focus: len.
do
    ---@type LPriorityQueue
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    pq:push(5, "mid_task", "mid")
    print("len = " .. pq:len())
    local top = pq:peek()
    if top then print("peek = " .. tostring(top)) end
    local item = pq:pop()
    if item then print("popped = " .. tostring(item)) end
    print("after pop: len = " .. pq:len())
    print("empty = " .. tostring(pq:isEmpty()))
    pq:clearAll()
    print("after clear: empty = " .. tostring(pq:isEmpty()))
end

--@api-stub: LPriorityQueue:isEmpty
-- Priority queue (highest priority first). Focus: isEmpty.
do
    ---@type LPriorityQueue
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    pq:push(5, "mid_task", "mid")
    print("len = " .. pq:len())
    local top = pq:peek()
    if top then print("peek = " .. tostring(top)) end
    local item = pq:pop()
    if item then print("popped = " .. tostring(item)) end
    print("after pop: len = " .. pq:len())
    print("empty = " .. tostring(pq:isEmpty()))
    pq:clearAll()
    print("after clear: empty = " .. tostring(pq:isEmpty()))
end

--@api-stub: LPriorityQueue:clearAll
-- Priority queue (highest priority first). Focus: clearAll.
do
    ---@type LPriorityQueue
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    pq:push(5, "mid_task", "mid")
    print("len = " .. pq:len())
    local top = pq:peek()
    if top then print("peek = " .. tostring(top)) end
    local item = pq:pop()
    if item then print("popped = " .. tostring(item)) end
    print("after pop: len = " .. pq:len())
    print("empty = " .. tostring(pq:isEmpty()))
    pq:clearAll()
    print("after clear: empty = " .. tostring(pq:isEmpty()))
end

--@api-stub: lurek.patterns.newRing
-- Ring buffer. Focus: newRing.
do
    ---@type LRing
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    ring:push(59)
    ring:push(61)
    print("len = " .. ring:len())
    print("full = " .. tostring(ring:isFull()))
    local entry = ring:latest()
    if entry then print("latest value = " .. entry.value) end
    print("sum = " .. ring:sum())
    print("average = " .. ring:average())
    ring:push(55)
    print("overwrote oldest, len = " .. ring:len())
    local arr = ring:toArray()
    print("array entries = " .. #arr)
    ring:clear()
    print("after clear: len = " .. ring:len())
end

--@api-stub: LRing:push
-- Ring buffer. Focus: push.
do
    ---@type LRing
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    ring:push(59)
    ring:push(61)
    print("len = " .. ring:len())
    print("full = " .. tostring(ring:isFull()))
    local entry = ring:latest()
    if entry then print("latest value = " .. entry.value) end
    print("sum = " .. ring:sum())
    print("average = " .. ring:average())
    ring:push(55)
    print("overwrote oldest, len = " .. ring:len())
    local arr = ring:toArray()
    print("array entries = " .. #arr)
    ring:clear()
    print("after clear: len = " .. ring:len())
end

--@api-stub: LRing:len
-- Ring buffer. Focus: len.
do
    ---@type LRing
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    ring:push(59)
    ring:push(61)
    print("len = " .. ring:len())
    print("full = " .. tostring(ring:isFull()))
    local entry = ring:latest()
    if entry then print("latest value = " .. entry.value) end
    print("sum = " .. ring:sum())
    print("average = " .. ring:average())
    ring:push(55)
    print("overwrote oldest, len = " .. ring:len())
    local arr = ring:toArray()
    print("array entries = " .. #arr)
    ring:clear()
    print("after clear: len = " .. ring:len())
end

--@api-stub: LRing:latest
-- Ring buffer. Focus: latest.
do
    ---@type LRing
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    ring:push(59)
    ring:push(61)
    print("len = " .. ring:len())
    print("full = " .. tostring(ring:isFull()))
    local entry = ring:latest()
    if entry then print("latest value = " .. entry.value) end
    print("sum = " .. ring:sum())
    print("average = " .. ring:average())
    ring:push(55)
    print("overwrote oldest, len = " .. ring:len())
    local arr = ring:toArray()
    print("array entries = " .. #arr)
    ring:clear()
    print("after clear: len = " .. ring:len())
end

--@api-stub: LRing:isFull
-- Ring buffer. Focus: isFull.
do
    ---@type LRing
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    ring:push(59)
    ring:push(61)
    print("len = " .. ring:len())
    print("full = " .. tostring(ring:isFull()))
    local entry = ring:latest()
    if entry then print("latest value = " .. entry.value) end
    print("sum = " .. ring:sum())
    print("average = " .. ring:average())
    ring:push(55)
    print("overwrote oldest, len = " .. ring:len())
    local arr = ring:toArray()
    print("array entries = " .. #arr)
    ring:clear()
    print("after clear: len = " .. ring:len())
end

--@api-stub: LRing:sum
-- Ring buffer. Focus: sum.
do
    ---@type LRing
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    ring:push(59)
    ring:push(61)
    print("len = " .. ring:len())
    print("full = " .. tostring(ring:isFull()))
    local entry = ring:latest()
    if entry then print("latest value = " .. entry.value) end
    print("sum = " .. ring:sum())
    print("average = " .. ring:average())
    ring:push(55)
    print("overwrote oldest, len = " .. ring:len())
    local arr = ring:toArray()
    print("array entries = " .. #arr)
    ring:clear()
    print("after clear: len = " .. ring:len())
end

--@api-stub: LRing:average
-- Ring buffer. Focus: average.
do
    ---@type LRing
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    ring:push(59)
    ring:push(61)
    print("len = " .. ring:len())
    print("full = " .. tostring(ring:isFull()))
    local entry = ring:latest()
    if entry then print("latest value = " .. entry.value) end
    print("sum = " .. ring:sum())
    print("average = " .. ring:average())
    ring:push(55)
    print("overwrote oldest, len = " .. ring:len())
    local arr = ring:toArray()
    print("array entries = " .. #arr)
    ring:clear()
    print("after clear: len = " .. ring:len())
end

--@api-stub: LRing:toArray
-- Ring buffer. Focus: toArray.
do
    ---@type LRing
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    ring:push(59)
    ring:push(61)
    print("len = " .. ring:len())
    print("full = " .. tostring(ring:isFull()))
    local entry = ring:latest()
    if entry then print("latest value = " .. entry.value) end
    print("sum = " .. ring:sum())
    print("average = " .. ring:average())
    ring:push(55)
    print("overwrote oldest, len = " .. ring:len())
    local arr = ring:toArray()
    print("array entries = " .. #arr)
    ring:clear()
    print("after clear: len = " .. ring:len())
end

--@api-stub: LRing:clear
-- Ring buffer. Focus: clear.
do
    ---@type LRing
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    ring:push(59)
    ring:push(61)
    print("len = " .. ring:len())
    print("full = " .. tostring(ring:isFull()))
    local entry = ring:latest()
    if entry then print("latest value = " .. entry.value) end
    print("sum = " .. ring:sum())
    print("average = " .. ring:average())
    ring:push(55)
    print("overwrote oldest, len = " .. ring:len())
    local arr = ring:toArray()
    print("array entries = " .. #arr)
    ring:clear()
    print("after clear: len = " .. ring:len())
end

--@api-stub: lurek.patterns.newWeightedRandom
-- Weighted random selection. Focus: newWeightedRandom.
do
    ---@type LWeightedRandom
    local wr = lurek.patterns.newWeightedRandom()
    local id1 = wr:add(10, "common", "common_loot")
    local id2 = wr:add(3, "rare", "rare_loot")
    local id3 = wr:add(1, "legendary", "legendary_loot")
    print("items = " .. wr:len())
    print("total weight = " .. wr:totalWeight())
    local picked = wr:pick(0.5)
    print("picked = " .. tostring(picked))
    local multi = wr:pickN(2, {0.1, 0.9})
    print("multi picks = " .. #multi)
end

--@api-stub: LWeightedRandom:add
-- Weighted random selection. Focus: add.
do
    ---@type LWeightedRandom
    local wr = lurek.patterns.newWeightedRandom()
    local id1 = wr:add(10, "common", "common_loot")
    local id2 = wr:add(3, "rare", "rare_loot")
    local id3 = wr:add(1, "legendary", "legendary_loot")
    print("items = " .. wr:len())
    print("total weight = " .. wr:totalWeight())
    local picked = wr:pick(0.5)
    print("picked = " .. tostring(picked))
    local multi = wr:pickN(2, {0.1, 0.9})
    print("multi picks = " .. #multi)
end

--@api-stub: LWeightedRandom:pick
-- Weighted random selection. Focus: pick.
do
    ---@type LWeightedRandom
    local wr = lurek.patterns.newWeightedRandom()
    local id1 = wr:add(10, "common", "common_loot")
    local id2 = wr:add(3, "rare", "rare_loot")
    local id3 = wr:add(1, "legendary", "legendary_loot")
    print("items = " .. wr:len())
    print("total weight = " .. wr:totalWeight())
    local picked = wr:pick(0.5)
    print("picked = " .. tostring(picked))
    local multi = wr:pickN(2, {0.1, 0.9})
    print("multi picks = " .. #multi)
end

--@api-stub: LWeightedRandom:pickN
-- Weighted random selection. Focus: pickN.
do
    ---@type LWeightedRandom
    local wr = lurek.patterns.newWeightedRandom()
    local id1 = wr:add(10, "common", "common_loot")
    local id2 = wr:add(3, "rare", "rare_loot")
    local id3 = wr:add(1, "legendary", "legendary_loot")
    print("items = " .. wr:len())
    print("total weight = " .. wr:totalWeight())
    local picked = wr:pick(0.5)
    print("picked = " .. tostring(picked))
    local multi = wr:pickN(2, {0.1, 0.9})
    print("multi picks = " .. #multi)
end

--@api-stub: LWeightedRandom:len
-- Weighted random selection. Focus: len.
do
    ---@type LWeightedRandom
    local wr = lurek.patterns.newWeightedRandom()
    local id1 = wr:add(10, "common", "common_loot")
    local id2 = wr:add(3, "rare", "rare_loot")
    local id3 = wr:add(1, "legendary", "legendary_loot")
    print("items = " .. wr:len())
    print("total weight = " .. wr:totalWeight())
    local picked = wr:pick(0.5)
    print("picked = " .. tostring(picked))
    local multi = wr:pickN(2, {0.1, 0.9})
    print("multi picks = " .. #multi)
end

--@api-stub: LWeightedRandom:totalWeight
-- Weighted random selection. Focus: totalWeight.
do
    ---@type LWeightedRandom
    local wr = lurek.patterns.newWeightedRandom()
    local id1 = wr:add(10, "common", "common_loot")
    local id2 = wr:add(3, "rare", "rare_loot")
    local id3 = wr:add(1, "legendary", "legendary_loot")
    print("items = " .. wr:len())
    print("total weight = " .. wr:totalWeight())
    local picked = wr:pick(0.5)
    print("picked = " .. tostring(picked))
    local multi = wr:pickN(2, {0.1, 0.9})
    print("multi picks = " .. #multi)
end

--@api-stub: LWeightedRandom:remove
-- Weighted random management. Focus: remove.
do
    ---@type LWeightedRandom
    local wr = lurek.patterns.newWeightedRandom()
    local id = wr:add(5, "item_a")
    wr:add(5, "item_b")
    wr:setWeight(id, 20)
    print("revision = " .. wr:getRevision())
    wr:remove(id)
    print("after remove: len = " .. wr:len())
    print("empty = " .. tostring(wr:isEmpty()))
    wr:clearAll()
    print("after clear: empty = " .. tostring(wr:isEmpty()))
end

--@api-stub: LWeightedRandom:setWeight
-- Weighted random management. Focus: setWeight.
do
    ---@type LWeightedRandom
    local wr = lurek.patterns.newWeightedRandom()
    local id = wr:add(5, "item_a")
    wr:add(5, "item_b")
    wr:setWeight(id, 20)
    print("revision = " .. wr:getRevision())
    wr:remove(id)
    print("after remove: len = " .. wr:len())
    print("empty = " .. tostring(wr:isEmpty()))
    wr:clearAll()
    print("after clear: empty = " .. tostring(wr:isEmpty()))
end

--@api-stub: LWeightedRandom:getRevision
-- Weighted random management. Focus: getRevision.
do
    ---@type LWeightedRandom
    local wr = lurek.patterns.newWeightedRandom()
    local id = wr:add(5, "item_a")
    wr:add(5, "item_b")
    wr:setWeight(id, 20)
    print("revision = " .. wr:getRevision())
    wr:remove(id)
    print("after remove: len = " .. wr:len())
    print("empty = " .. tostring(wr:isEmpty()))
    wr:clearAll()
    print("after clear: empty = " .. tostring(wr:isEmpty()))
end

--@api-stub: LWeightedRandom:isEmpty
-- Weighted random management. Focus: isEmpty.
do
    ---@type LWeightedRandom
    local wr = lurek.patterns.newWeightedRandom()
    local id = wr:add(5, "item_a")
    wr:add(5, "item_b")
    wr:setWeight(id, 20)
    print("revision = " .. wr:getRevision())
    wr:remove(id)
    print("after remove: len = " .. wr:len())
    print("empty = " .. tostring(wr:isEmpty()))
    wr:clearAll()
    print("after clear: empty = " .. tostring(wr:isEmpty()))
end

--@api-stub: LWeightedRandom:clearAll
-- Weighted random management. Focus: clearAll.
do
    ---@type LWeightedRandom
    local wr = lurek.patterns.newWeightedRandom()
    local id = wr:add(5, "item_a")
    wr:add(5, "item_b")
    wr:setWeight(id, 20)
    print("revision = " .. wr:getRevision())
    wr:remove(id)
    print("after remove: len = " .. wr:len())
    print("empty = " .. tostring(wr:isEmpty()))
    wr:clearAll()
    print("after clear: empty = " .. tostring(wr:isEmpty()))
end

--@api-stub: lurek.patterns.newRelationshipManager
-- Relationship tracking between entities. Focus: newRelationshipManager.
do
    ---@type LRelationshipManager
    local rm = lurek.patterns.newRelationshipManager()
    rm:setValue(1, 2, 50)
    rm:setValue(1, 3, -20)
    print("1→2 = " .. rm:getValue(1, 2))
    print("1→3 = " .. rm:getValue(1, 3))
    rm:adjustValue(1, 2, 10)
    print("adjusted 1→2 = " .. rm:getValue(1, 2))
end

--@api-stub: LRelationshipManager:setValue
-- Relationship tracking between entities. Focus: setValue.
do
    ---@type LRelationshipManager
    local rm = lurek.patterns.newRelationshipManager()
    rm:setValue(1, 2, 50)
    rm:setValue(1, 3, -20)
    print("1→2 = " .. rm:getValue(1, 2))
    print("1→3 = " .. rm:getValue(1, 3))
    rm:adjustValue(1, 2, 10)
    print("adjusted 1→2 = " .. rm:getValue(1, 2))
end

--@api-stub: LRelationshipManager:getValue
-- Relationship tracking between entities. Focus: getValue.
do
    ---@type LRelationshipManager
    local rm = lurek.patterns.newRelationshipManager()
    rm:setValue(1, 2, 50)
    rm:setValue(1, 3, -20)
    print("1→2 = " .. rm:getValue(1, 2))
    print("1→3 = " .. rm:getValue(1, 3))
    rm:adjustValue(1, 2, 10)
    print("adjusted 1→2 = " .. rm:getValue(1, 2))
end

--@api-stub: LRelationshipManager:adjustValue
-- Relationship tracking between entities. Focus: adjustValue.
do
    ---@type LRelationshipManager
    local rm = lurek.patterns.newRelationshipManager()
    rm:setValue(1, 2, 50)
    rm:setValue(1, 3, -20)
    print("1→2 = " .. rm:getValue(1, 2))
    print("1→3 = " .. rm:getValue(1, 3))
    rm:adjustValue(1, 2, 10)
    print("adjusted 1→2 = " .. rm:getValue(1, 2))
end

--@api-stub: LRelationshipManager:defineType
-- Named relationship levels. Focus: defineType.
do
    ---@type LRelationshipManager
    local rm = lurek.patterns.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "unfriendly", "neutral", "friendly", "allied"}, "neutral")
    rm:setLevel(1, 2, "friendship", "friendly")
    rm:setLevel(1, 3, "friendship", "hostile")
    print("1→2 friendship = " .. rm:getLevel(1, 2, "friendship"))
    print("1→3 friendship = " .. rm:getLevel(1, 3, "friendship"))
    print("types = " .. #rm:typeNames())
    print("pairs = " .. rm:pairCount())
    rm:removePair(1, 3)
    print("after remove: pairs = " .. rm:pairCount())
    rm:removeType("friendship")
    print("after removeType: types = " .. #rm:typeNames())
end

--@api-stub: LRelationshipManager:setLevel
-- Named relationship levels. Focus: setLevel.
do
    ---@type LRelationshipManager
    local rm = lurek.patterns.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "unfriendly", "neutral", "friendly", "allied"}, "neutral")
    rm:setLevel(1, 2, "friendship", "friendly")
    rm:setLevel(1, 3, "friendship", "hostile")
    print("1→2 friendship = " .. rm:getLevel(1, 2, "friendship"))
    print("1→3 friendship = " .. rm:getLevel(1, 3, "friendship"))
    print("types = " .. #rm:typeNames())
    print("pairs = " .. rm:pairCount())
    rm:removePair(1, 3)
    print("after remove: pairs = " .. rm:pairCount())
    rm:removeType("friendship")
    print("after removeType: types = " .. #rm:typeNames())
end

--@api-stub: LRelationshipManager:getLevel
-- Named relationship levels. Focus: getLevel.
do
    ---@type LRelationshipManager
    local rm = lurek.patterns.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "unfriendly", "neutral", "friendly", "allied"}, "neutral")
    rm:setLevel(1, 2, "friendship", "friendly")
    rm:setLevel(1, 3, "friendship", "hostile")
    print("1→2 friendship = " .. rm:getLevel(1, 2, "friendship"))
    print("1→3 friendship = " .. rm:getLevel(1, 3, "friendship"))
    print("types = " .. #rm:typeNames())
    print("pairs = " .. rm:pairCount())
    rm:removePair(1, 3)
    print("after remove: pairs = " .. rm:pairCount())
    rm:removeType("friendship")
    print("after removeType: types = " .. #rm:typeNames())
end

--@api-stub: LRelationshipManager:typeNames
-- Named relationship levels. Focus: typeNames.
do
    ---@type LRelationshipManager
    local rm = lurek.patterns.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "unfriendly", "neutral", "friendly", "allied"}, "neutral")
    rm:setLevel(1, 2, "friendship", "friendly")
    rm:setLevel(1, 3, "friendship", "hostile")
    print("1→2 friendship = " .. rm:getLevel(1, 2, "friendship"))
    print("1→3 friendship = " .. rm:getLevel(1, 3, "friendship"))
    print("types = " .. #rm:typeNames())
    print("pairs = " .. rm:pairCount())
    rm:removePair(1, 3)
    print("after remove: pairs = " .. rm:pairCount())
    rm:removeType("friendship")
    print("after removeType: types = " .. #rm:typeNames())
end

--@api-stub: LRelationshipManager:pairCount
-- Named relationship levels. Focus: pairCount.
do
    ---@type LRelationshipManager
    local rm = lurek.patterns.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "unfriendly", "neutral", "friendly", "allied"}, "neutral")
    rm:setLevel(1, 2, "friendship", "friendly")
    rm:setLevel(1, 3, "friendship", "hostile")
    print("1→2 friendship = " .. rm:getLevel(1, 2, "friendship"))
    print("1→3 friendship = " .. rm:getLevel(1, 3, "friendship"))
    print("types = " .. #rm:typeNames())
    print("pairs = " .. rm:pairCount())
    rm:removePair(1, 3)
    print("after remove: pairs = " .. rm:pairCount())
    rm:removeType("friendship")
    print("after removeType: types = " .. #rm:typeNames())
end

--@api-stub: LRelationshipManager:removePair
-- Named relationship levels. Focus: removePair.
do
    ---@type LRelationshipManager
    local rm = lurek.patterns.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "unfriendly", "neutral", "friendly", "allied"}, "neutral")
    rm:setLevel(1, 2, "friendship", "friendly")
    rm:setLevel(1, 3, "friendship", "hostile")
    print("1→2 friendship = " .. rm:getLevel(1, 2, "friendship"))
    print("1→3 friendship = " .. rm:getLevel(1, 3, "friendship"))
    print("types = " .. #rm:typeNames())
    print("pairs = " .. rm:pairCount())
    rm:removePair(1, 3)
    print("after remove: pairs = " .. rm:pairCount())
    rm:removeType("friendship")
    print("after removeType: types = " .. #rm:typeNames())
end

--@api-stub: LRelationshipManager:removeType
-- Named relationship levels. Focus: removeType.
do
    ---@type LRelationshipManager
    local rm = lurek.patterns.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "unfriendly", "neutral", "friendly", "allied"}, "neutral")
    rm:setLevel(1, 2, "friendship", "friendly")
    rm:setLevel(1, 3, "friendship", "hostile")
    print("1→2 friendship = " .. rm:getLevel(1, 2, "friendship"))
    print("1→3 friendship = " .. rm:getLevel(1, 3, "friendship"))
    print("types = " .. #rm:typeNames())
    print("pairs = " .. rm:pairCount())
    rm:removePair(1, 3)
    print("after remove: pairs = " .. rm:pairCount())
    rm:removeType("friendship")
    print("after removeType: types = " .. #rm:typeNames())
end

--- Patterns Module Part 5: integrated multi-pattern examples, real-world scenarios


--@api-stub: Integration
-- Combined patterns: factory creates objects, pool recycles, observer reacts.
do
    ---@type LFactory
    local factory = lurek.patterns.newFactory()
    factory:register("bullet", function(speed)
        return {type = "bullet", speed = speed or 300, x = 0, y = 0, active = false}
    end)

    ---@type LObjectPool
    local pool = lurek.patterns.newObjectPool()
    for _ = 1, 20 do
        pool:add(factory:create("bullet", 400))
    end

    ---@type LObserver
    local obs = lurek.patterns.newObserver("bullet_events")
    obs:subscribe("fire", function(_, count)
        print("  bullets fired: " .. tostring(count))
    end)

    local fired = 0
    for _ = 1, 5 do
        local b = pool:acquire()
        if b then
            b.active = true
            fired = fired + 1
        end
    end
    obs:set("fire", fired)
    print("pool active = " .. pool:getActiveCount())
    print("pool available = " .. pool:getAvailableCount())
end

--@api-stub: LGraph:nodeCount
-- Graph stores quest dependencies, weighted random picks rewards, PQ processes quest order.
do
    ---@type LPatternGraph
    local quests = lurek.patterns.newGraph(true)
    local q1 = quests:addNode("intro", {xp = 100})
    local q2 = quests:addNode("dungeon", {xp = 500})
    local q3 = quests:addNode("boss", {xp = 1000})
    local q4 = quests:addNode("epilogue", {xp = 200})
    quests:addEdge(q1, q2)
    quests:addEdge(q2, q3)
    quests:addEdge(q3, q4)
    quests:addEdge(q1, q4)
    print("quest nodes = " .. quests:nodeCount())
    print("quest edges = " .. quests:edgeCount())

    ---@type LWeightedRandom
    local loot = lurek.patterns.newWeightedRandom()
    loot:add(50, "gold")
    loot:add(30, "potion")
    loot:add(15, "rare_weapon")
    loot:add(5, "legendary")
    local reward = loot:pick(0.7)
    print("quest reward = " .. tostring(reward))

    ---@type LPriorityQueue
    local pq = lurek.patterns.newPriorityQueue("quest_order")
    pq:push(1, "intro", "starter")
    pq:push(10, "boss", "endgame")
    pq:push(5, "dungeon", "midgame")
    local next_quest = pq:pop()
    print("next quest = " .. tostring(next_quest))
end

--@api-stub: LGraph:bfs
-- Resolve load order using graph traversal with set tracking.
do
    ---@type LPatternGraph
    local deps = lurek.patterns.newGraph(true)
    local mod_a = deps:addNode("core")
    local mod_b = deps:addNode("physics")
    local mod_c = deps:addNode("render")
    local mod_d = deps:addNode("game")
    deps:addEdge(mod_a, mod_b)
    deps:addEdge(mod_a, mod_c)
    deps:addEdge(mod_b, mod_d)
    deps:addEdge(mod_c, mod_d)

    ---@type LSet
    local loaded = lurek.patterns.newSet()

    ---@type LList
    local load_order = lurek.patterns.newList()

    local order = deps:bfs(mod_a)
    for _, node_id in ipairs(order) do
        local name = deps:getNodeValue(node_id)
        if name and not loaded:has(tostring(name)) then
            loaded:add(tostring(name))
            load_order:push(tostring(name))
        end
    end
    print("load order count = " .. load_order:len())
    local arr = load_order:toArray()
    for i, mod_name in ipairs(arr) do
        print("  " .. i .. ": " .. mod_name)
    end
end

--- Patterns Module Part 5: BehaviorTree (addChild/nodeCount/setRoot), LList:clear, LObjectPool counts, LSimpleState:update, LStrategy:getCurrent


--@api-stub: LBehaviorTree:addChild
-- Behavior tree node management. Focus: addChild.
do
    local bt = lurek.patterns.newBehaviorTree()
    local seq = bt:addSequence("root_seq")
    local leaf1 = bt:addLeaf("check", "check_label")
    local leaf2 = bt:addLeaf("act", "act_label")
    bt:addChild(seq, leaf1)
    bt:addChild(seq, leaf2)
    bt:setRoot(seq)
    print("node_count=" .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:nodeCount
-- Behavior tree node management. Focus: nodeCount.
do
    local bt = lurek.patterns.newBehaviorTree()
    local seq = bt:addSequence("root_seq")
    local leaf1 = bt:addLeaf("check", "check_label")
    local leaf2 = bt:addLeaf("act", "act_label")
    bt:addChild(seq, leaf1)
    bt:addChild(seq, leaf2)
    bt:setRoot(seq)
    print("node_count=" .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:setRoot
-- Behavior tree node management. Focus: setRoot.
do
    local bt = lurek.patterns.newBehaviorTree()
    local seq = bt:addSequence("root_seq")
    local leaf1 = bt:addLeaf("check", "check_label")
    local leaf2 = bt:addLeaf("act", "act_label")
    bt:addChild(seq, leaf1)
    bt:addChild(seq, leaf2)
    bt:setRoot(seq)
    print("node_count=" .. bt:nodeCount())
end

--@api-stub: LList:clear
-- List clear operation.
do
    local list = lurek.patterns.newList()
    list:add(1)
    list:add(2)
    list:add(3)
    print("before_clear=" .. list:len())
    list:clear()
    print("after_clear=" .. list:len())
end

--@api-stub: LObjectPool:getActiveCount
-- Object pool count queries. Focus: getActiveCount.
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({})
    pool:add({})
    pool:add({})
    print("total=" .. pool:getTotalCount())
    print("available=" .. pool:getAvailableCount())
    local obj = pool:acquire()
    print("active=" .. pool:getActiveCount())
    pool:release(obj)
end

--@api-stub: LObjectPool:getAvailableCount
-- Object pool count queries. Focus: getAvailableCount.
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({})
    pool:add({})
    pool:add({})
    print("total=" .. pool:getTotalCount())
    print("available=" .. pool:getAvailableCount())
    local obj = pool:acquire()
    print("active=" .. pool:getActiveCount())
    pool:release(obj)
end

--@api-stub: LObjectPool:getTotalCount
-- Object pool count queries. Focus: getTotalCount.
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({})
    pool:add({})
    pool:add({})
    print("total=" .. pool:getTotalCount())
    print("available=" .. pool:getAvailableCount())
    local obj = pool:acquire()
    print("active=" .. pool:getActiveCount())
    pool:release(obj)
end

--@api-stub: LSimpleState:update
-- State machine update tick.
do
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("idle", {
        enter = function() print("enter idle") end,
        update = function(dt) print("tick idle dt=" .. dt) end,
        exit = function() print("exit idle") end,
    })
    fsm:addState("run", {
        enter = function() print("enter run") end,
        update = function(dt) print("tick run dt=" .. dt) end,
    })
    fsm:transitionTo("idle")
    fsm:update(0.016)
    print("current=" .. fsm:getCurrent())
end

--@api-stub: LStrategy:getCurrent
-- Strategy manager current query.
do
    local strat = lurek.patterns.newStrategy()
    strat:register("attack", function() return "attacking" end)
    strat:register("flee", function() return "fleeing" end)
    strat:set("attack")
    print("current=" .. tostring(strat:getCurrent()))
    strat:execute()
end

print("content/examples/patterns.lua")
