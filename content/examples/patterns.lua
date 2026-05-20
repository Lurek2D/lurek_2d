-- content/examples/patterns.lua
-- Auto-generated from content/examples2/patterns_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/patterns.lua

--- Patterns Module Part 1: service locator, object pool, factory, strategy


--@api-stub: lurek.patterns.newServiceLocator
do
    ---@type LServiceLocator
    local services = lurek.patterns.newServiceLocator()
    print("locator created = " .. tostring(services ~= nil))
end

--@api-stub: LServiceLocator:provide
do
    ---@type LServiceLocator
    local services = lurek.patterns.newServiceLocator()
    services:provide("audio", {volume = 0.8, muted = false})
    print("has audio = " .. tostring(services:has("audio")))
end

--@api-stub: LServiceLocator:locate
do
    local services = lurek.patterns.newServiceLocator()
    services:provide("audio", {volume = 0.8, muted = false})
    local audio = services:locate("audio")
    if audio then print("audio volume = " .. audio.volume) end
end

--@api-stub: LServiceLocator:has
do
    ---@type LServiceLocator
    local services = lurek.patterns.newServiceLocator()
    services:provide("audio", {volume = 0.8, muted = false})
    print("has audio = " .. tostring(services:has("audio")))
    print("has physics = " .. tostring(services:has("physics")))
end

--@api-stub: LServiceLocator:getServices
do
    local services = lurek.patterns.newServiceLocator()
    services:provide("renderer", {backend = "wgpu"})
    services:provide("input", {keyboard = true})
    local names = services:getServices()
    print("services = " .. #names)
end

--@api-stub: LServiceLocator:remove
do
    ---@type LServiceLocator
    local services = lurek.patterns.newServiceLocator()
    services:provide("save", {slot = 1})
    services:remove("save")
    print("after remove: has save = " .. tostring(services:has("save")))
end

--@api-stub: LServiceLocator:clearAll
do
    ---@type LServiceLocator
    local services = lurek.patterns.newServiceLocator()
    services:provide("renderer", {backend = "wgpu"})
    services:clearAll()
    print("after clear: count = " .. #services:getServices())
end

--@api-stub: lurek.patterns.newObjectPool
do
    ---@type LObjectPool
    local pool = lurek.patterns.newObjectPool()
    print("pool created = " .. tostring(pool ~= nil))
end

--@api-stub: LObjectPool:add
do
    local pool = lurek.patterns.newObjectPool(); for i = 1, 10 do pool:add({id = i, active = false, x = 0, y = 0}) end
    print("total = " .. pool:getTotalCount()); print("available = " .. pool:getAvailableCount())
    print("active = " .. pool:getActiveCount())
    local obj = pool:acquire()
    if obj then obj.active = true obj.x = 100 print("acquired id = " .. obj.id) print("active count = " .. pool:getActiveCount()) pool:release(obj) print("after release: available = " .. pool:getAvailableCount()) end
end

--@api-stub: LObjectPool:acquire
do
    local pool = lurek.patterns.newObjectPool(); for i = 1, 10 do pool:add({id = i, active = false, x = 0, y = 0}) end
    print("total = " .. pool:getTotalCount()); print("available = " .. pool:getAvailableCount())
    print("active = " .. pool:getActiveCount())
    local obj = pool:acquire()
    if obj then obj.active = true obj.x = 100 print("acquired id = " .. obj.id) print("active count = " .. pool:getActiveCount()) pool:release(obj) print("after release: available = " .. pool:getAvailableCount()) end
end

--@api-stub: LObjectPool:release
do
    local pool = lurek.patterns.newObjectPool(); for i = 1, 10 do pool:add({id = i, active = false, x = 0, y = 0}) end
    print("total = " .. pool:getTotalCount()); print("available = " .. pool:getAvailableCount())
    print("active = " .. pool:getActiveCount())
    local obj = pool:acquire()
    if obj then obj.active = true obj.x = 100 print("acquired id = " .. obj.id) print("active count = " .. pool:getActiveCount()) pool:release(obj) print("after release: available = " .. pool:getAvailableCount()) end
end

--@api-stub: LObjectPool:clearAll
do
    local pool = lurek.patterns.newObjectPool(); pool:add({type = "bullet"})
    pool:add({type = "bullet"}); pool:acquire()
    print("before clear: total = " .. pool:getTotalCount())
    pool:clearAll()
    print("after clear: total = " .. pool:getTotalCount())
end

--@api-stub: lurek.patterns.newFactory
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
do
    local factory = lurek.patterns.newFactory()
    factory:register("enemy", function()
        return {type = "enemy"}
    end)
    print("has enemy = " .. tostring(factory:has("enemy")))
end

--@api-stub: LFactory:create
do
    local factory = lurek.patterns.newFactory()
    factory:register("enemy", function(hp, speed)
        return {type = "enemy", hp = hp or 100, speed = speed or 50}
    end)
    factory:register("bullet", function(dmg)
        return {type = "bullet", damage = dmg or 10}
    end)
    local e = factory:create("enemy", 200, 75)
    print("enemy hp = " .. e.hp .. " speed = " .. e.speed)
    local b = factory:create("bullet", 25)
    print("bullet dmg = " .. b.damage)
end

--@api-stub: LFactory:getTypes
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
do
    local strat = lurek.patterns.newStrategy(); strat:register("fast", function() return {speed = 200} end)
    strat:register("slow", function() return {speed = 50} end); print("has fast = " .. tostring(strat:has("fast")))
    local all = strat:names(); print("strategies = " .. #all)
    local removed = strat:remove("slow"); print("removed slow = " .. tostring(removed))
    strat:clear(); print("after clear: current = " .. tostring(strat:getCurrent()))
end

--@api-stub: LStrategy:names
do
    local strat = lurek.patterns.newStrategy(); strat:register("fast", function() return {speed = 200} end)
    strat:register("slow", function() return {speed = 50} end); print("has fast = " .. tostring(strat:has("fast")))
    local all = strat:names(); print("strategies = " .. #all)
    local removed = strat:remove("slow"); print("removed slow = " .. tostring(removed))
    strat:clear(); print("after clear: current = " .. tostring(strat:getCurrent()))
end

--@api-stub: LStrategy:remove
do
    local strat = lurek.patterns.newStrategy(); strat:register("fast", function() return {speed = 200} end)
    strat:register("slow", function() return {speed = 50} end); print("has fast = " .. tostring(strat:has("fast")))
    local all = strat:names(); print("strategies = " .. #all)
    local removed = strat:remove("slow"); print("removed slow = " .. tostring(removed))
    strat:clear(); print("after clear: current = " .. tostring(strat:getCurrent()))
end

--@api-stub: LStrategy:clear
do
    local strat = lurek.patterns.newStrategy(); strat:register("fast", function() return {speed = 200} end)
    strat:register("slow", function() return {speed = 50} end); print("has fast = " .. tostring(strat:has("fast")))
    local all = strat:names(); print("strategies = " .. #all)
    local removed = strat:remove("slow"); print("removed slow = " .. tostring(removed))
    strat:clear(); print("after clear: current = " .. tostring(strat:getCurrent()))
end

--- Patterns Module Part 2: FSM, command stack, behavior tree, blackboard


--@api-stub: lurek.patterns.newSimpleState
do
    local fsm = lurek.patterns.newSimpleState(); fsm:addState("idle", { enter = function() print("  enter idle") end, exit = function() print("  exit idle") end, update = function(dt) end })
    fsm:addState("walk", { enter = function() print("  enter walk") end, exit = function() print("  exit walk") end, update = function(dt) print("  walking dt=" .. dt) end }); fsm:addState("attack", { enter = function() print("  enter attack") end, update = function(dt) print("  attacking") end })
    fsm:transitionTo("idle"); print("current = " .. fsm:getCurrent())
    fsm:transitionTo("walk"); print("current = " .. fsm:getCurrent())
    fsm:update(0.016)
end

--@api-stub: LSimpleState:addState
do
    local fsm = lurek.patterns.newSimpleState(); fsm:addState("idle", { enter = function() print("  enter idle") end, exit = function() print("  exit idle") end, update = function(dt) end })
    fsm:addState("walk", { enter = function() print("  enter walk") end, exit = function() print("  exit walk") end, update = function(dt) print("  walking dt=" .. dt) end }); fsm:addState("attack", { enter = function() print("  enter attack") end, update = function(dt) print("  attacking") end })
    fsm:transitionTo("idle"); print("current = " .. fsm:getCurrent())
    fsm:transitionTo("walk"); print("current = " .. fsm:getCurrent())
    fsm:update(0.016)
end

--@api-stub: LSimpleState:transitionTo
do
    local fsm = lurek.patterns.newSimpleState(); fsm:addState("idle", { enter = function() print("  enter idle") end, exit = function() print("  exit idle") end, update = function(dt) end })
    fsm:addState("walk", { enter = function() print("  enter walk") end, exit = function() print("  exit walk") end, update = function(dt) print("  walking dt=" .. dt) end }); fsm:addState("attack", { enter = function() print("  enter attack") end, update = function(dt) print("  attacking") end })
    fsm:transitionTo("idle"); print("current = " .. fsm:getCurrent())
    fsm:transitionTo("walk"); print("current = " .. fsm:getCurrent())
    fsm:update(0.016)
end

--@api-stub: LSimpleState:getCurrent
do
    local fsm = lurek.patterns.newSimpleState(); fsm:addState("idle", { enter = function() print("  enter idle") end, exit = function() print("  exit idle") end, update = function(dt) end })
    fsm:addState("walk", { enter = function() print("  enter walk") end, exit = function() print("  exit walk") end, update = function(dt) print("  walking dt=" .. dt) end }); fsm:addState("attack", { enter = function() print("  enter attack") end, update = function(dt) print("  attacking") end })
    fsm:transitionTo("idle"); print("current = " .. fsm:getCurrent())
    fsm:transitionTo("walk"); print("current = " .. fsm:getCurrent())
    fsm:update(0.016)
end

--@api-stub: LSimpleState:hasState
do
    local fsm = lurek.patterns.newSimpleState(); fsm:addState("menu")
    fsm:addState("game"); fsm:addState("pause")
    print("has menu = " .. tostring(fsm:hasState("menu"))); print("has quit = " .. tostring(fsm:hasState("quit")))
    print("states = " .. #fsm:getStates()); fsm:clearAll()
    print("after clear = " .. #fsm:getStates())
end

--@api-stub: LSimpleState:getStates
do
    local fsm = lurek.patterns.newSimpleState(); fsm:addState("menu")
    fsm:addState("game"); fsm:addState("pause")
    print("has menu = " .. tostring(fsm:hasState("menu"))); print("has quit = " .. tostring(fsm:hasState("quit")))
    print("states = " .. #fsm:getStates()); fsm:clearAll()
    print("after clear = " .. #fsm:getStates())
end

--@api-stub: LSimpleState:clearAll
do
    local fsm = lurek.patterns.newSimpleState(); fsm:addState("menu")
    fsm:addState("game"); fsm:addState("pause")
    print("has menu = " .. tostring(fsm:hasState("menu"))); print("has quit = " .. tostring(fsm:hasState("quit")))
    print("states = " .. #fsm:getStates()); fsm:clearAll()
    print("after clear = " .. #fsm:getStates())
end

--@api-stub: lurek.patterns.newCommandStack
do
    local cmds = lurek.patterns.newCommandStack(50); local value = 0; cmds:execute("add 10", function() value = value + 10 end, function() value = value - 10 end)
    print("after add: " .. value); cmds:execute("mul 2", function() value = value * 2 end, function() value = value / 2 end); print("after mul: " .. value)
    cmds:undo(); print("after undo: " .. value)
    cmds:undo(); print("after undo2: " .. value)
    cmds:redo(); print("after redo: " .. value)
end

--@api-stub: LCommandStack:execute
do
    local cmds = lurek.patterns.newCommandStack(50); local value = 0; cmds:execute("add 10", function() value = value + 10 end, function() value = value - 10 end)
    print("after add: " .. value); cmds:execute("mul 2", function() value = value * 2 end, function() value = value / 2 end); print("after mul: " .. value)
    cmds:undo(); print("after undo: " .. value)
    cmds:undo(); print("after undo2: " .. value)
    cmds:redo(); print("after redo: " .. value)
end

--@api-stub: LCommandStack:undo
do
    local cmds = lurek.patterns.newCommandStack(50); local value = 0; cmds:execute("add 10", function() value = value + 10 end, function() value = value - 10 end)
    print("after add: " .. value); cmds:execute("mul 2", function() value = value * 2 end, function() value = value / 2 end); print("after mul: " .. value)
    cmds:undo(); print("after undo: " .. value)
    cmds:undo(); print("after undo2: " .. value)
    cmds:redo(); print("after redo: " .. value)
end

--@api-stub: LCommandStack:redo
do
    local cmds = lurek.patterns.newCommandStack(50); local value = 0; cmds:execute("add 10", function() value = value + 10 end, function() value = value - 10 end)
    print("after add: " .. value); cmds:execute("mul 2", function() value = value * 2 end, function() value = value / 2 end); print("after mul: " .. value)
    cmds:undo(); print("after undo: " .. value)
    cmds:undo(); print("after undo2: " .. value)
    cmds:redo(); print("after redo: " .. value)
end

--@api-stub: LCommandStack:canUndo
do
    local cmds = lurek.patterns.newCommandStack(); cmds:execute("step1", function() end, function() end)
    cmds:execute("step2", function() end, function() end); print("can undo = " .. tostring(cmds:canUndo()))
    print("can redo = " .. tostring(cmds:canRedo())); print("current = " .. cmds:getCurrentName())
    print("history = " .. cmds:getHistorySize()); cmds:clearAll()
    print("after clear = " .. cmds:getHistorySize())
end

--@api-stub: LCommandStack:canRedo
do
    local cmds = lurek.patterns.newCommandStack(); cmds:execute("step1", function() end, function() end)
    cmds:execute("step2", function() end, function() end); print("can undo = " .. tostring(cmds:canUndo()))
    print("can redo = " .. tostring(cmds:canRedo())); print("current = " .. cmds:getCurrentName())
    print("history = " .. cmds:getHistorySize()); cmds:clearAll()
    print("after clear = " .. cmds:getHistorySize())
end

--@api-stub: LCommandStack:getCurrentName
do
    local cmds = lurek.patterns.newCommandStack(); cmds:execute("step1", function() end, function() end)
    cmds:execute("step2", function() end, function() end); print("can undo = " .. tostring(cmds:canUndo()))
    print("can redo = " .. tostring(cmds:canRedo())); print("current = " .. cmds:getCurrentName())
    print("history = " .. cmds:getHistorySize()); cmds:clearAll()
    print("after clear = " .. cmds:getHistorySize())
end

--@api-stub: LCommandStack:getHistorySize
do
    local cmds = lurek.patterns.newCommandStack(); cmds:execute("step1", function() end, function() end)
    cmds:execute("step2", function() end, function() end); print("can undo = " .. tostring(cmds:canUndo()))
    print("can redo = " .. tostring(cmds:canRedo())); print("current = " .. cmds:getCurrentName())
    print("history = " .. cmds:getHistorySize()); cmds:clearAll()
    print("after clear = " .. cmds:getHistorySize())
end

--@api-stub: LCommandStack:clearAll
do
    local cmds = lurek.patterns.newCommandStack(); cmds:execute("step1", function() end, function() end)
    cmds:execute("step2", function() end, function() end); print("can undo = " .. tostring(cmds:canUndo()))
    print("can redo = " .. tostring(cmds:canRedo())); print("current = " .. cmds:getCurrentName())
    print("history = " .. cmds:getHistorySize()); cmds:clearAll()
    print("after clear = " .. cmds:getHistorySize())
end

--@api-stub: lurek.patterns.newBehaviorTree
do
    local bt = lurek.patterns.newBehaviorTree(); local root = bt:addSelector("root_sel"); local seq_attack = bt:addSequence("attack_seq")
    local leaf_check = bt:addLeaf("check_enemy", "has_enemy?"); local leaf_attack = bt:addLeaf("do_attack", "attack!"); bt:addChild(root, seq_attack)
    bt:addChild(seq_attack, leaf_check); bt:addChild(seq_attack, leaf_attack)
    local leaf_idle = bt:addLeaf("idle", "idle"); bt:addChild(root, leaf_idle)
    bt:setRoot(root); print("nodes = " .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:addSequence
do
    local bt = lurek.patterns.newBehaviorTree(); local root = bt:addSelector("root_sel"); local seq_attack = bt:addSequence("attack_seq")
    local leaf_check = bt:addLeaf("check_enemy", "has_enemy?"); local leaf_attack = bt:addLeaf("do_attack", "attack!"); bt:addChild(root, seq_attack)
    bt:addChild(seq_attack, leaf_check); bt:addChild(seq_attack, leaf_attack)
    local leaf_idle = bt:addLeaf("idle", "idle"); bt:addChild(root, leaf_idle)
    bt:setRoot(root); print("nodes = " .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:addSelector
do
    local bt = lurek.patterns.newBehaviorTree(); local root = bt:addSelector("root_sel"); local seq_attack = bt:addSequence("attack_seq")
    local leaf_check = bt:addLeaf("check_enemy", "has_enemy?"); local leaf_attack = bt:addLeaf("do_attack", "attack!"); bt:addChild(root, seq_attack)
    bt:addChild(seq_attack, leaf_check); bt:addChild(seq_attack, leaf_attack)
    local leaf_idle = bt:addLeaf("idle", "idle"); bt:addChild(root, leaf_idle)
    bt:setRoot(root); print("nodes = " .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:addLeaf
do
    local bt = lurek.patterns.newBehaviorTree(); local root = bt:addSelector("root_sel"); local seq_attack = bt:addSequence("attack_seq")
    local leaf_check = bt:addLeaf("check_enemy", "has_enemy?"); local leaf_attack = bt:addLeaf("do_attack", "attack!"); bt:addChild(root, seq_attack)
    bt:addChild(seq_attack, leaf_check); bt:addChild(seq_attack, leaf_attack)
    local leaf_idle = bt:addLeaf("idle", "idle"); bt:addChild(root, leaf_idle)
    bt:setRoot(root); print("nodes = " .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:setLeaf
do
    local bt = lurek.patterns.newBehaviorTree(); local root = bt:addSequence("root")
    local check = bt:addLeaf("check", "check"); local act = bt:addLeaf("act", "act")
    bt:addChild(root, check); bt:addChild(root, act)
    bt:setRoot(root); local enemy_visible = true
    bt:setLeaf("check", function() if enemy_visible then return "success" else return "failure" end
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
do
    local bt = lurek.patterns.newBehaviorTree(); local root = bt:addSequence("root")
    local check = bt:addLeaf("check", "check"); local act = bt:addLeaf("act", "act")
    bt:addChild(root, check); bt:addChild(root, act)
    bt:setRoot(root); local enemy_visible = true
    bt:setLeaf("check", function() if enemy_visible then return "success" else return "failure" end
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
do
    local bt = lurek.patterns.newBehaviorTree(); local root = bt:addSequence("root")
    local check = bt:addLeaf("check", "check"); local act = bt:addLeaf("act", "act")
    bt:addChild(root, check); bt:addChild(root, act)
    bt:setRoot(root); local enemy_visible = true
    bt:setLeaf("check", function() if enemy_visible then return "success" else return "failure" end
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
do
    local bt = lurek.patterns.newBehaviorTree(); local par = bt:addParallel(2, "par_node"); local inv = bt:addInverter("inverter")
    local rep = bt:addRepeat(3, "repeat_3"); local leaf = bt:addLeaf("action", "do_thing"); bt:addChild(par, inv)
    bt:addChild(inv, leaf); bt:addChild(par, rep); local leaf2 = bt:addLeaf("other", "other")
    bt:addChild(rep, leaf2); print("parallel node created, count = " .. bt:nodeCount())
    bt:clearAll(); print("after clear = " .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:addInverter
do
    local bt = lurek.patterns.newBehaviorTree(); local par = bt:addParallel(2, "par_node"); local inv = bt:addInverter("inverter")
    local rep = bt:addRepeat(3, "repeat_3"); local leaf = bt:addLeaf("action", "do_thing"); bt:addChild(par, inv)
    bt:addChild(inv, leaf); bt:addChild(par, rep); local leaf2 = bt:addLeaf("other", "other")
    bt:addChild(rep, leaf2); print("parallel node created, count = " .. bt:nodeCount())
    bt:clearAll(); print("after clear = " .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:addRepeat
do
    local bt = lurek.patterns.newBehaviorTree(); local par = bt:addParallel(2, "par_node"); local inv = bt:addInverter("inverter")
    local rep = bt:addRepeat(3, "repeat_3"); local leaf = bt:addLeaf("action", "do_thing"); bt:addChild(par, inv)
    bt:addChild(inv, leaf); bt:addChild(par, rep); local leaf2 = bt:addLeaf("other", "other")
    bt:addChild(rep, leaf2); print("parallel node created, count = " .. bt:nodeCount())
    bt:clearAll(); print("after clear = " .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:clearAll
do
    local bt = lurek.patterns.newBehaviorTree(); local par = bt:addParallel(2, "par_node"); local inv = bt:addInverter("inverter")
    local rep = bt:addRepeat(3, "repeat_3"); local leaf = bt:addLeaf("action", "do_thing"); bt:addChild(par, inv)
    bt:addChild(inv, leaf); bt:addChild(par, rep); local leaf2 = bt:addLeaf("other", "other")
    bt:addChild(rep, leaf2); print("parallel node created, count = " .. bt:nodeCount())
    bt:clearAll(); print("after clear = " .. bt:nodeCount())
end

--@api-stub: lurek.patterns.newBlackboard
do
    local bb = lurek.patterns.newBlackboard("game_state"); bb:set("health", 100)
    bb:set("weapon", "sword"); bb:set("alive", true)
    print("health = " .. tostring(bb:get("health"))); print("weapon = " .. tostring(bb:get("weapon")))
    print("has alive = " .. tostring(bb:has("alive"))); print("has mana = " .. tostring(bb:has("mana")))
    local all_keys = bb:keys(); print("keys = " .. #all_keys)
end

--@api-stub: LBlackboard:set
do
    local bb = lurek.patterns.newBlackboard("game_state"); bb:set("health", 100); bb:set("weapon", "sword")
    bb:set("alive", true); print("health = " .. tostring(bb:get("health"))); print("weapon = " .. tostring(bb:get("weapon")))
    print("has alive = " .. tostring(bb:has("alive"))); print("has mana = " .. tostring(bb:has("mana"))); local all_keys = bb:keys()
    print("keys = " .. #all_keys); local bb = lurek.patterns.newBlackboard("game"); bb:set("health", 100)
    bb:set("score", 0); local bus = lurek.patterns.newEventBus("game_bus"); bus:on("state_change", function(from, to) print("  state: " .. from .. " → " .. to)
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
do
    local bb = lurek.patterns.newBlackboard("game_state"); bb:set("health", 100)
    bb:set("weapon", "sword"); bb:set("alive", true)
    print("health = " .. tostring(bb:get("health"))); print("weapon = " .. tostring(bb:get("weapon")))
    print("has alive = " .. tostring(bb:has("alive"))); print("has mana = " .. tostring(bb:has("mana")))
    local all_keys = bb:keys(); print("keys = " .. #all_keys)
end

--@api-stub: LBlackboard:has
do
    local bb = lurek.patterns.newBlackboard("game_state"); bb:set("health", 100)
    bb:set("weapon", "sword"); bb:set("alive", true)
    print("health = " .. tostring(bb:get("health"))); print("weapon = " .. tostring(bb:get("weapon")))
    print("has alive = " .. tostring(bb:has("alive"))); print("has mana = " .. tostring(bb:has("mana")))
    local all_keys = bb:keys(); print("keys = " .. #all_keys)
end

--@api-stub: LBlackboard:keys
do
    local bb = lurek.patterns.newBlackboard("game_state"); bb:set("health", 100)
    bb:set("weapon", "sword"); bb:set("alive", true)
    print("health = " .. tostring(bb:get("health"))); print("weapon = " .. tostring(bb:get("weapon")))
    print("has alive = " .. tostring(bb:has("alive"))); print("has mana = " .. tostring(bb:has("mana")))
    local all_keys = bb:keys(); print("keys = " .. #all_keys)
end

--@api-stub: LBlackboard:watch
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
do
    local bus = lurek.patterns.newEventBus(); bus:on("spawn", function() end)
    bus:on("spawn", function() end); bus:on("death", function() end)
    print("spawn listeners = " .. bus:getListenerCount("spawn")); print("events = " .. #bus:getEvents())
    bus:clear("spawn"); print("after clear spawn: " .. bus:getListenerCount("spawn"))
    bus:clearAll(); print("after clearAll: events = " .. #bus:getEvents())
end

--@api-stub: LEventBus:getEvents
do
    local bus = lurek.patterns.newEventBus(); bus:on("spawn", function() end)
    bus:on("spawn", function() end); bus:on("death", function() end)
    print("spawn listeners = " .. bus:getListenerCount("spawn")); print("events = " .. #bus:getEvents())
    bus:clear("spawn"); print("after clear spawn: " .. bus:getListenerCount("spawn"))
    bus:clearAll(); print("after clearAll: events = " .. #bus:getEvents())
end

--@api-stub: LEventBus:clear
do
    local bus = lurek.patterns.newEventBus(); bus:on("spawn", function() end)
    bus:on("spawn", function() end); bus:on("death", function() end)
    print("spawn listeners = " .. bus:getListenerCount("spawn")); print("events = " .. #bus:getEvents())
    bus:clear("spawn"); print("after clear spawn: " .. bus:getListenerCount("spawn"))
    bus:clearAll(); print("after clearAll: events = " .. #bus:getEvents())
end

--@api-stub: LEventBus:clearAll
do
    local bus = lurek.patterns.newEventBus(); bus:on("spawn", function() end)
    bus:on("spawn", function() end); bus:on("death", function() end)
    print("spawn listeners = " .. bus:getListenerCount("spawn")); print("events = " .. #bus:getEvents())
    bus:clear("spawn"); print("after clear spawn: " .. bus:getListenerCount("spawn"))
    bus:clearAll(); print("after clearAll: events = " .. #bus:getEvents())
end

--@api-stub: lurek.patterns.newMediator
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
do
    local med = lurek.patterns.newMediator(); med:on("audio", function(...) end); med:on("video", function(...) end)
    med:on("input", function(...) end); med:broadcast("system_pause")
    print("channels = " .. #med:channels()); print("audio handlers = " .. med:handlerCount("audio"))
    med:removeChannel("audio"); print("after remove: channels = " .. #med:channels())
    med:clear(); print("after clear: channels = " .. #med:channels())
end

--@api-stub: LMediator:channels
do
    local med = lurek.patterns.newMediator(); med:on("audio", function(...) end); med:on("video", function(...) end)
    med:on("input", function(...) end); med:broadcast("system_pause")
    print("channels = " .. #med:channels()); print("audio handlers = " .. med:handlerCount("audio"))
    med:removeChannel("audio"); print("after remove: channels = " .. #med:channels())
    med:clear(); print("after clear: channels = " .. #med:channels())
end

--@api-stub: LMediator:handlerCount
do
    local med = lurek.patterns.newMediator(); med:on("audio", function(...) end); med:on("video", function(...) end)
    med:on("input", function(...) end); med:broadcast("system_pause")
    print("channels = " .. #med:channels()); print("audio handlers = " .. med:handlerCount("audio"))
    med:removeChannel("audio"); print("after remove: channels = " .. #med:channels())
    med:clear(); print("after clear: channels = " .. #med:channels())
end

--@api-stub: LMediator:removeChannel
do
    local med = lurek.patterns.newMediator(); med:on("audio", function(...) end); med:on("video", function(...) end)
    med:on("input", function(...) end); med:broadcast("system_pause")
    print("channels = " .. #med:channels()); print("audio handlers = " .. med:handlerCount("audio"))
    med:removeChannel("audio"); print("after remove: channels = " .. #med:channels())
    med:clear(); print("after clear: channels = " .. #med:channels())
end

--@api-stub: LMediator:clear
do
    local med = lurek.patterns.newMediator(); med:on("audio", function(...) end); med:on("video", function(...) end)
    med:on("input", function(...) end); med:broadcast("system_pause")
    print("channels = " .. #med:channels()); print("audio handlers = " .. med:handlerCount("audio"))
    med:removeChannel("audio"); print("after remove: channels = " .. #med:channels())
    med:clear(); print("after clear: channels = " .. #med:channels())
end

--@api-stub: lurek.patterns.newDebounce
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
do
    local db = lurek.patterns.newDebounce(1.0); db:onFire(function() print("  should not fire") end)
    db:trigger(); print("pending = " .. tostring(db:isPending()))
    db:cancel(); print("after cancel: pending = " .. tostring(db:isPending()))
    db:update(2.0)
    print("fire count = " .. db:getFireCount())
end

--@api-stub: LDebounce:isPending
do
    local db = lurek.patterns.newDebounce(1.0); db:onFire(function() print("  should not fire") end)
    db:trigger(); print("pending = " .. tostring(db:isPending()))
    db:cancel(); print("after cancel: pending = " .. tostring(db:isPending()))
    db:update(2.0)
    print("fire count = " .. db:getFireCount())
end

--@api-stub: LDebounce:getFireCount
do
    local db = lurek.patterns.newDebounce(1.0); db:onFire(function() print("  should not fire") end)
    db:trigger(); print("pending = " .. tostring(db:isPending()))
    db:cancel(); print("after cancel: pending = " .. tostring(db:isPending()))
    db:update(2.0)
    print("fire count = " .. db:getFireCount())
end

--@api-stub: lurek.patterns.newThrottle
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
do
    local th = lurek.patterns.newThrottle(1.0); th:onFire(function() end)
    th:update(0.5); print("progress = " .. th:getProgress())
    th:reset(); print("after reset progress = " .. th:getProgress())
    th:setEnabled(false); th:update(5.0)
    print("disabled progress = " .. th:getProgress())
end

--@api-stub: LThrottle:setEnabled
do
    local th = lurek.patterns.newThrottle(1.0); th:onFire(function() end)
    th:update(0.5); print("progress = " .. th:getProgress())
    th:reset(); print("after reset progress = " .. th:getProgress())
    th:setEnabled(false); th:update(5.0)
    print("disabled progress = " .. th:getProgress())
end

--@api-stub: LThrottle:getProgress
do
    local th = lurek.patterns.newThrottle(1.0); th:onFire(function() end)
    th:update(0.5); print("progress = " .. th:getProgress())
    th:reset(); print("after reset progress = " .. th:getProgress())
    th:setEnabled(false); th:update(5.0)
    print("disabled progress = " .. th:getProgress())
end

--@api-stub: lurek.patterns.newFunnel
do
    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries) print("  flushed " .. #entries .. " entries") for _, e in ipairs(entries) do print("    " .. e.tag .. " = " .. e.value) end
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:push("fire", 8)
    print("pending = " .. funnel:pendingCount())
    funnel:update(1.1)
    print("flush count = " .. funnel:getFlushCount())
end

--@api-stub: LFunnel:push
do
    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries) print("  flushed " .. #entries .. " entries") for _, e in ipairs(entries) do print("    " .. e.tag .. " = " .. e.value) end
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:push("fire", 8)
    print("pending = " .. funnel:pendingCount())
    funnel:update(1.1)
    print("flush count = " .. funnel:getFlushCount())
end

--@api-stub: LFunnel:update
do
    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries) print("  flushed " .. #entries .. " entries") for _, e in ipairs(entries) do print("    " .. e.tag .. " = " .. e.value) end
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:push("fire", 8)
    print("pending = " .. funnel:pendingCount())
    funnel:update(1.1)
    print("flush count = " .. funnel:getFlushCount())
end

--@api-stub: LFunnel:onFlush
do
    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries) print("  flushed " .. #entries .. " entries") for _, e in ipairs(entries) do print("    " .. e.tag .. " = " .. e.value) end
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
do
    local g = lurek.patterns.newGraph(false); local a = g:addNode("A", {cost = 10})
    local b = g:addNode("B", {cost = 5}); local c = g:addNode("C")
    local e1 = g:addEdge(a, b, 1.0, "road")
    local e2 = g:addEdge(b, c, 2.5)
    print("nodes = " .. g:nodeCount() .. " edges = " .. g:edgeCount())
end

--@api-stub: LPatternGraph:addNode
do
    local g = lurek.patterns.newGraph(false); local a = g:addNode("A", {cost = 10})
    local b = g:addNode("B", {cost = 5}); local c = g:addNode("C")
    local e1 = g:addEdge(a, b, 1.0, "road")
    local e2 = g:addEdge(b, c, 2.5)
    print("nodes = " .. g:nodeCount() .. " edges = " .. g:edgeCount())
end

--@api-stub: LPatternGraph:addEdge
do
    local g = lurek.patterns.newGraph(false); local a = g:addNode("A", {cost = 10})
    local b = g:addNode("B", {cost = 5}); local c = g:addNode("C")
    local e1 = g:addEdge(a, b, 1.0, "road")
    local e2 = g:addEdge(b, c, 2.5)
    print("nodes = " .. g:nodeCount() .. " edges = " .. g:edgeCount())
end

--@api-stub: LPatternGraph:nodeCount
do
    local g = lurek.patterns.newGraph(false); local a = g:addNode("A", {cost = 10})
    local b = g:addNode("B", {cost = 5}); local c = g:addNode("C")
    local e1 = g:addEdge(a, b, 1.0, "road")
    local e2 = g:addEdge(b, c, 2.5)
    print("nodes = " .. g:nodeCount() .. " edges = " .. g:edgeCount())
end

--@api-stub: LPatternGraph:edgeCount
do
    local g = lurek.patterns.newGraph(false); local a = g:addNode("A", {cost = 10})
    local b = g:addNode("B", {cost = 5}); local c = g:addNode("C")
    local e1 = g:addEdge(a, b, 1.0, "road")
    local e2 = g:addEdge(b, c, 2.5)
    print("nodes = " .. g:nodeCount() .. " edges = " .. g:edgeCount())
end

--@api-stub: LPatternGraph:bfs
do
    local g = lurek.patterns.newGraph(true); local n1 = g:addNode("start"); local n2 = g:addNode("mid"); local n3 = g:addNode("end")
    local n4 = g:addNode("isolated"); g:addEdge(n1, n2); g:addEdge(n2, n3)
    local bfs_order = g:bfs(n1); print("BFS from start = " .. #bfs_order .. " nodes"); local dfs_order = g:dfs(n1)
    print("DFS from start = " .. #dfs_order .. " nodes"); print("start→end connected = " .. tostring(g:isConnected(n1, n3))); print("start→isolated connected = " .. tostring(g:isConnected(n1, n4)))
    local neighbors = g:neighbors(n2); print("mid neighbors = " .. #neighbors); print("has n1 = " .. tostring(g:hasNode(n1)))
end

--@api-stub: LPatternGraph:dfs
do
    local g = lurek.patterns.newGraph(true); local n1 = g:addNode("start"); local n2 = g:addNode("mid"); local n3 = g:addNode("end")
    local n4 = g:addNode("isolated"); g:addEdge(n1, n2); g:addEdge(n2, n3)
    local bfs_order = g:bfs(n1); print("BFS from start = " .. #bfs_order .. " nodes"); local dfs_order = g:dfs(n1)
    print("DFS from start = " .. #dfs_order .. " nodes"); print("start→end connected = " .. tostring(g:isConnected(n1, n3))); print("start→isolated connected = " .. tostring(g:isConnected(n1, n4)))
    local neighbors = g:neighbors(n2); print("mid neighbors = " .. #neighbors); print("has n1 = " .. tostring(g:hasNode(n1)))
end

--@api-stub: LPatternGraph:isConnected
do
    local g = lurek.patterns.newGraph(true); local n1 = g:addNode("start"); local n2 = g:addNode("mid"); local n3 = g:addNode("end")
    local n4 = g:addNode("isolated"); g:addEdge(n1, n2); g:addEdge(n2, n3)
    local bfs_order = g:bfs(n1); print("BFS from start = " .. #bfs_order .. " nodes"); local dfs_order = g:dfs(n1)
    print("DFS from start = " .. #dfs_order .. " nodes"); print("start→end connected = " .. tostring(g:isConnected(n1, n3))); print("start→isolated connected = " .. tostring(g:isConnected(n1, n4)))
    local neighbors = g:neighbors(n2); print("mid neighbors = " .. #neighbors); print("has n1 = " .. tostring(g:hasNode(n1)))
end

--@api-stub: LPatternGraph:neighbors
do
    local g = lurek.patterns.newGraph(true); local n1 = g:addNode("start"); local n2 = g:addNode("mid"); local n3 = g:addNode("end")
    local n4 = g:addNode("isolated"); g:addEdge(n1, n2); g:addEdge(n2, n3)
    local bfs_order = g:bfs(n1); print("BFS from start = " .. #bfs_order .. " nodes"); local dfs_order = g:dfs(n1)
    print("DFS from start = " .. #dfs_order .. " nodes"); print("start→end connected = " .. tostring(g:isConnected(n1, n3))); print("start→isolated connected = " .. tostring(g:isConnected(n1, n4)))
    local neighbors = g:neighbors(n2); print("mid neighbors = " .. #neighbors); print("has n1 = " .. tostring(g:hasNode(n1)))
end

--@api-stub: LPatternGraph:hasNode
do
    local g = lurek.patterns.newGraph(true); local n1 = g:addNode("start"); local n2 = g:addNode("mid"); local n3 = g:addNode("end")
    local n4 = g:addNode("isolated"); g:addEdge(n1, n2); g:addEdge(n2, n3)
    local bfs_order = g:bfs(n1); print("BFS from start = " .. #bfs_order .. " nodes"); local dfs_order = g:dfs(n1)
    print("DFS from start = " .. #dfs_order .. " nodes"); print("start→end connected = " .. tostring(g:isConnected(n1, n3))); print("start→isolated connected = " .. tostring(g:isConnected(n1, n4)))
    local neighbors = g:neighbors(n2); print("mid neighbors = " .. #neighbors); print("has n1 = " .. tostring(g:hasNode(n1)))
end

--@api-stub: LPatternGraph:getNodeValue
do
    local g = lurek.patterns.newGraph(); local a = g:addNode("room", {size = 10}); local b = g:addNode("hall")
    local e = g:addEdge(a, b, 1.0); local val = g:getNodeValue(a); if val then print("room size = " .. val.size) end
    g:removeEdge(e); print("after edge remove: edges = " .. g:edgeCount())
    g:removeNode(b); print("after node remove: nodes = " .. g:nodeCount())
    g:clearAll(); print("after clear: nodes = " .. g:nodeCount())
end

--@api-stub: LPatternGraph:removeNode
do
    local g = lurek.patterns.newGraph(); local a = g:addNode("room", {size = 10}); local b = g:addNode("hall")
    local e = g:addEdge(a, b, 1.0); local val = g:getNodeValue(a); if val then print("room size = " .. val.size) end
    g:removeEdge(e); print("after edge remove: edges = " .. g:edgeCount())
    g:removeNode(b); print("after node remove: nodes = " .. g:nodeCount())
    g:clearAll(); print("after clear: nodes = " .. g:nodeCount())
end

--@api-stub: LPatternGraph:removeEdge
do
    local g = lurek.patterns.newGraph(); local a = g:addNode("room", {size = 10}); local b = g:addNode("hall")
    local e = g:addEdge(a, b, 1.0); local val = g:getNodeValue(a); if val then print("room size = " .. val.size) end
    g:removeEdge(e); print("after edge remove: edges = " .. g:edgeCount())
    g:removeNode(b); print("after node remove: nodes = " .. g:nodeCount())
    g:clearAll(); print("after clear: nodes = " .. g:nodeCount())
end

--@api-stub: LPatternGraph:clearAll
do
    local g = lurek.patterns.newGraph(); local a = g:addNode("room", {size = 10}); local b = g:addNode("hall")
    local e = g:addEdge(a, b, 1.0); local val = g:getNodeValue(a); if val then print("room size = " .. val.size) end
    g:removeEdge(e); print("after edge remove: edges = " .. g:edgeCount())
    g:removeNode(b); print("after node remove: nodes = " .. g:nodeCount())
    g:clearAll(); print("after clear: nodes = " .. g:nodeCount())
end

--@api-stub: lurek.patterns.newList
do
    local list = lurek.patterns.newList(); list:add("alpha")
    list:add("beta"); list:add("gamma")
    print("len = " .. list:len()); print("get(2) = " .. list:get(2))
    print("indexOf beta = " .. list:indexOf("beta")); list:remove(2)
    print("after remove: len = " .. list:len())
end

--@api-stub: LList:add
do
    local list = lurek.patterns.newList(); list:add("alpha")
    list:add("beta"); list:add("gamma")
    print("len = " .. list:len()); print("get(2) = " .. list:get(2))
    print("indexOf beta = " .. list:indexOf("beta")); list:remove(2)
    print("after remove: len = " .. list:len())
end

--@api-stub: LList:get
do
    local list = lurek.patterns.newList(); list:add("alpha")
    list:add("beta"); list:add("gamma")
    print("len = " .. list:len()); print("get(2) = " .. list:get(2))
    print("indexOf beta = " .. list:indexOf("beta")); list:remove(2)
    print("after remove: len = " .. list:len())
end

--@api-stub: LList:len
do
    local list = lurek.patterns.newList(); list:add("alpha")
    list:add("beta"); list:add("gamma")
    print("len = " .. list:len()); print("get(2) = " .. list:get(2))
    print("indexOf beta = " .. list:indexOf("beta")); list:remove(2)
    print("after remove: len = " .. list:len())
end

--@api-stub: LList:remove
do
    local list = lurek.patterns.newList(); list:add("alpha")
    list:add("beta"); list:add("gamma")
    print("len = " .. list:len()); print("get(2) = " .. list:get(2))
    print("indexOf beta = " .. list:indexOf("beta")); list:remove(2)
    print("after remove: len = " .. list:len())
end

--@api-stub: LList:indexOf
do
    local list = lurek.patterns.newList(); list:add("alpha")
    list:add("beta"); list:add("gamma")
    print("len = " .. list:len()); print("get(2) = " .. list:get(2))
    print("indexOf beta = " .. list:indexOf("beta")); list:remove(2)
    print("after remove: len = " .. list:len())
end

--@api-stub: LList:push
do
    local list = lurek.patterns.newList(); list:push("a"); list:push("b"); list:push("c")
    list:insert(2, "x"); list:set(1, "A"); print("contains x = " .. tostring(list:contains("x"))); list:unshift("first")
    local shifted = list:shift(); print("shifted = " .. shifted); local popped = list:pop()
    print("popped = " .. popped); list:reverse(); local arr = list:toArray()
    print("array len = " .. #arr); list:clear(); print("empty = " .. tostring(list:isEmpty()))
end

--@api-stub: LList:pop
do
    local list = lurek.patterns.newList(); list:push("a"); list:push("b"); list:push("c")
    list:insert(2, "x"); list:set(1, "A"); print("contains x = " .. tostring(list:contains("x"))); list:unshift("first")
    local shifted = list:shift(); print("shifted = " .. shifted); local popped = list:pop()
    print("popped = " .. popped); list:reverse(); local arr = list:toArray()
    print("array len = " .. #arr); list:clear(); print("empty = " .. tostring(list:isEmpty()))
end

--@api-stub: LList:insert
do
    local list = lurek.patterns.newList(); list:push("a"); list:push("b"); list:push("c")
    list:insert(2, "x"); list:set(1, "A"); print("contains x = " .. tostring(list:contains("x"))); list:unshift("first")
    local shifted = list:shift(); print("shifted = " .. shifted); local popped = list:pop()
    print("popped = " .. popped); list:reverse(); local arr = list:toArray()
    print("array len = " .. #arr); list:clear(); print("empty = " .. tostring(list:isEmpty()))
end

--@api-stub: LList:set
do
    local list = lurek.patterns.newList(); list:push("a"); list:push("b"); list:push("c")
    list:insert(2, "x"); list:set(1, "A"); print("contains x = " .. tostring(list:contains("x"))); list:unshift("first")
    local shifted = list:shift(); print("shifted = " .. shifted); local popped = list:pop()
    print("popped = " .. popped); list:reverse(); local arr = list:toArray()
    print("array len = " .. #arr); list:clear(); print("empty = " .. tostring(list:isEmpty()))
end

--@api-stub: LList:shift
do
    local list = lurek.patterns.newList(); list:push("a"); list:push("b"); list:push("c")
    list:insert(2, "x"); list:set(1, "A"); print("contains x = " .. tostring(list:contains("x"))); list:unshift("first")
    local shifted = list:shift(); print("shifted = " .. shifted); local popped = list:pop()
    print("popped = " .. popped); list:reverse(); local arr = list:toArray()
    print("array len = " .. #arr); list:clear(); print("empty = " .. tostring(list:isEmpty()))
end

--@api-stub: LList:unshift
do
    local list = lurek.patterns.newList(); list:push("a"); list:push("b"); list:push("c")
    list:insert(2, "x"); list:set(1, "A"); print("contains x = " .. tostring(list:contains("x"))); list:unshift("first")
    local shifted = list:shift(); print("shifted = " .. shifted); local popped = list:pop()
    print("popped = " .. popped); list:reverse(); local arr = list:toArray()
    print("array len = " .. #arr); list:clear(); print("empty = " .. tostring(list:isEmpty()))
end

--@api-stub: LList:contains
do
    local list = lurek.patterns.newList(); list:push("a"); list:push("b"); list:push("c")
    list:insert(2, "x"); list:set(1, "A"); print("contains x = " .. tostring(list:contains("x"))); list:unshift("first")
    local shifted = list:shift(); print("shifted = " .. shifted); local popped = list:pop()
    print("popped = " .. popped); list:reverse(); local arr = list:toArray()
    print("array len = " .. #arr); list:clear(); print("empty = " .. tostring(list:isEmpty()))
end

--@api-stub: LList:reverse
do
    local list = lurek.patterns.newList(); list:push("a"); list:push("b"); list:push("c")
    list:insert(2, "x"); list:set(1, "A"); print("contains x = " .. tostring(list:contains("x"))); list:unshift("first")
    local shifted = list:shift(); print("shifted = " .. shifted); local popped = list:pop()
    print("popped = " .. popped); list:reverse(); local arr = list:toArray()
    print("array len = " .. #arr); list:clear(); print("empty = " .. tostring(list:isEmpty()))
end

--@api-stub: LList:toArray
do
    local list = lurek.patterns.newList(); list:push("a"); list:push("b"); list:push("c")
    list:insert(2, "x"); list:set(1, "A"); print("contains x = " .. tostring(list:contains("x"))); list:unshift("first")
    local shifted = list:shift(); print("shifted = " .. shifted); local popped = list:pop()
    print("popped = " .. popped); list:reverse(); local arr = list:toArray()
    print("array len = " .. #arr); list:clear(); print("empty = " .. tostring(list:isEmpty()))
end

--@api-stub: LList:isEmpty
do
    local list = lurek.patterns.newList(); list:push("a"); list:push("b"); list:push("c")
    list:insert(2, "x"); list:set(1, "A"); print("contains x = " .. tostring(list:contains("x"))); list:unshift("first")
    local shifted = list:shift(); print("shifted = " .. shifted); local popped = list:pop()
    print("popped = " .. popped); list:reverse(); local arr = list:toArray()
    print("array len = " .. #arr); list:clear(); print("empty = " .. tostring(list:isEmpty()))
end

--@api-stub: lurek.patterns.newMap
do
    local map = lurek.patterns.newMap(); map:set("name", "hero")
    map:set("level", 5); map:set("class", "warrior")
    print("name = " .. map:get("name")); print("has level = " .. tostring(map:has("level")))
    print("len = " .. map:len()); map:remove("class")
    print("keys = " .. #map:keys()); print("values = " .. #map:values())
end

--@api-stub: LMap:set
do
    local map = lurek.patterns.newMap(); map:set("name", "hero"); map:set("level", 5); map:set("class", "warrior")
    print("name = " .. map:get("name")); print("has level = " .. tostring(map:has("level"))); print("len = " .. map:len()); map:remove("class")
    print("keys = " .. #map:keys()); print("values = " .. #map:values()); local state = lurek.patterns.newMap()
    state:set("x", 100); state:set("y", 200); local obs = lurek.patterns.newObserver("position")
    local cmds = lurek.patterns.newCommandStack(20); local move_step = 0; obs:subscribe("moved", function(_, step) print("  move step: " .. tostring(step))
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
do
    local map = lurek.patterns.newMap(); map:set("name", "hero")
    map:set("level", 5); map:set("class", "warrior")
    print("name = " .. map:get("name")); print("has level = " .. tostring(map:has("level")))
    print("len = " .. map:len()); map:remove("class")
    print("keys = " .. #map:keys()); print("values = " .. #map:values())
end

--@api-stub: LMap:has
do
    local map = lurek.patterns.newMap(); map:set("name", "hero")
    map:set("level", 5); map:set("class", "warrior")
    print("name = " .. map:get("name")); print("has level = " .. tostring(map:has("level")))
    print("len = " .. map:len()); map:remove("class")
    print("keys = " .. #map:keys()); print("values = " .. #map:values())
end

--@api-stub: LMap:remove
do
    local map = lurek.patterns.newMap(); map:set("name", "hero")
    map:set("level", 5); map:set("class", "warrior")
    print("name = " .. map:get("name")); print("has level = " .. tostring(map:has("level")))
    print("len = " .. map:len()); map:remove("class")
    print("keys = " .. #map:keys()); print("values = " .. #map:values())
end

--@api-stub: LMap:keys
do
    local map = lurek.patterns.newMap(); map:set("name", "hero")
    map:set("level", 5); map:set("class", "warrior")
    print("name = " .. map:get("name")); print("has level = " .. tostring(map:has("level")))
    print("len = " .. map:len()); map:remove("class")
    print("keys = " .. #map:keys()); print("values = " .. #map:values())
end

--@api-stub: LMap:values
do
    local map = lurek.patterns.newMap(); map:set("name", "hero")
    map:set("level", 5); map:set("class", "warrior")
    print("name = " .. map:get("name")); print("has level = " .. tostring(map:has("level")))
    print("len = " .. map:len()); map:remove("class")
    print("keys = " .. #map:keys()); print("values = " .. #map:values())
end

--@api-stub: LMap:len
do
    local map = lurek.patterns.newMap(); map:set("name", "hero")
    map:set("level", 5); map:set("class", "warrior")
    print("name = " .. map:get("name")); print("has level = " .. tostring(map:has("level")))
    print("len = " .. map:len()); map:remove("class")
    print("keys = " .. #map:keys()); print("values = " .. #map:values())
end

--@api-stub: LMap:entries
do
    local m1 = lurek.patterns.newMap(); m1:set("a", 1); m1:set("b", 2)
    local m2 = lurek.patterns.newMap(); m2:set("b", 99); m2:set("c", 3)
    m1:merge(m2); print("after merge: b = " .. m1:get("b")); local entries = m1:entries()
    print("entries = " .. #entries); print("empty = " .. tostring(m1:isEmpty()))
    m1:clear(); print("after clear: empty = " .. tostring(m1:isEmpty()))
end

--@api-stub: LMap:merge
do
    local m1 = lurek.patterns.newMap(); m1:set("a", 1); m1:set("b", 2)
    local m2 = lurek.patterns.newMap(); m2:set("b", 99); m2:set("c", 3)
    m1:merge(m2); print("after merge: b = " .. m1:get("b")); local entries = m1:entries()
    print("entries = " .. #entries); print("empty = " .. tostring(m1:isEmpty()))
    m1:clear(); print("after clear: empty = " .. tostring(m1:isEmpty()))
end

--@api-stub: LMap:isEmpty
do
    local m1 = lurek.patterns.newMap(); m1:set("a", 1); m1:set("b", 2)
    local m2 = lurek.patterns.newMap(); m2:set("b", 99); m2:set("c", 3)
    m1:merge(m2); print("after merge: b = " .. m1:get("b")); local entries = m1:entries()
    print("entries = " .. #entries); print("empty = " .. tostring(m1:isEmpty()))
    m1:clear(); print("after clear: empty = " .. tostring(m1:isEmpty()))
end

--@api-stub: LMap:clear
do
    local m1 = lurek.patterns.newMap(); m1:set("a", 1); m1:set("b", 2)
    local m2 = lurek.patterns.newMap(); m2:set("b", 99); m2:set("c", 3)
    m1:merge(m2); print("after merge: b = " .. m1:get("b")); local entries = m1:entries()
    print("entries = " .. #entries); print("empty = " .. tostring(m1:isEmpty()))
    m1:clear(); print("after clear: empty = " .. tostring(m1:isEmpty()))
end

--@api-stub: lurek.patterns.newSet
do
    local s = lurek.patterns.newSet(); print("added = " .. tostring(s:add("fire")))
    print("dup = " .. tostring(s:add("fire"))); s:add("ice")
    s:add("wind"); print("has fire = " .. tostring(s:has("fire")))
    print("len = " .. s:len()); s:remove("ice")
    local arr = s:toArray(); print("array = " .. #arr)
end

--@api-stub: LSet:add
do
    local s = lurek.patterns.newSet(); print("added = " .. tostring(s:add("fire")))
    print("dup = " .. tostring(s:add("fire"))); s:add("ice")
    s:add("wind"); print("has fire = " .. tostring(s:has("fire")))
    print("len = " .. s:len()); s:remove("ice")
    local arr = s:toArray(); print("array = " .. #arr)
end

--@api-stub: LSet:has
do
    local s = lurek.patterns.newSet(); print("added = " .. tostring(s:add("fire")))
    print("dup = " .. tostring(s:add("fire"))); s:add("ice")
    s:add("wind"); print("has fire = " .. tostring(s:has("fire")))
    print("len = " .. s:len()); s:remove("ice")
    local arr = s:toArray(); print("array = " .. #arr)
end

--@api-stub: LSet:remove
do
    local s = lurek.patterns.newSet(); print("added = " .. tostring(s:add("fire")))
    print("dup = " .. tostring(s:add("fire"))); s:add("ice")
    s:add("wind"); print("has fire = " .. tostring(s:has("fire")))
    print("len = " .. s:len()); s:remove("ice")
    local arr = s:toArray(); print("array = " .. #arr)
end

--@api-stub: LSet:len
do
    local s = lurek.patterns.newSet(); print("added = " .. tostring(s:add("fire")))
    print("dup = " .. tostring(s:add("fire"))); s:add("ice")
    s:add("wind"); print("has fire = " .. tostring(s:has("fire")))
    print("len = " .. s:len()); s:remove("ice")
    local arr = s:toArray(); print("array = " .. #arr)
end

--@api-stub: LSet:toArray
do
    local s = lurek.patterns.newSet(); print("added = " .. tostring(s:add("fire")))
    print("dup = " .. tostring(s:add("fire"))); s:add("ice")
    s:add("wind"); print("has fire = " .. tostring(s:has("fire")))
    print("len = " .. s:len()); s:remove("ice")
    local arr = s:toArray(); print("array = " .. #arr)
end

--@api-stub: LSet:union
do
    local a = lurek.patterns.newSet(); a:add("x"); a:add("y")
    a:add("z"); local b = lurek.patterns.newSet(); b:add("y")
    b:add("z"); b:add("w"); local u = a:union(b)
    print("union = " .. u:len()); local i = a:intersection(b); print("intersection = " .. i:len())
    a:clear(); print("empty = " .. tostring(a:isEmpty()))
end

--@api-stub: LSet:intersection
do
    local a = lurek.patterns.newSet(); a:add("x"); a:add("y")
    a:add("z"); local b = lurek.patterns.newSet(); b:add("y")
    b:add("z"); b:add("w"); local u = a:union(b)
    print("union = " .. u:len()); local i = a:intersection(b); print("intersection = " .. i:len())
    a:clear(); print("empty = " .. tostring(a:isEmpty()))
end

--@api-stub: LSet:isEmpty
do
    local a = lurek.patterns.newSet(); a:add("x"); a:add("y")
    a:add("z"); local b = lurek.patterns.newSet(); b:add("y")
    b:add("z"); b:add("w"); local u = a:union(b)
    print("union = " .. u:len()); local i = a:intersection(b); print("intersection = " .. i:len())
    a:clear(); print("empty = " .. tostring(a:isEmpty()))
end

--@api-stub: LSet:clear
do
    local a = lurek.patterns.newSet(); a:add("x"); a:add("y")
    a:add("z"); local b = lurek.patterns.newSet(); b:add("y")
    b:add("z"); b:add("w"); local u = a:union(b)
    print("union = " .. u:len()); local i = a:intersection(b); print("intersection = " .. i:len())
    a:clear(); print("empty = " .. tostring(a:isEmpty()))
end

--@api-stub: lurek.patterns.newStack
do
    local st = lurek.patterns.newStack(100); st:push("first")
    st:push("second"); st:push("third")
    print("peek = " .. st:peek()); print("len = " .. st:len())
    local v = st:pop(); print("popped = " .. v)
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:push
do
    local st = lurek.patterns.newStack(100); st:push("first")
    st:push("second"); st:push("third")
    print("peek = " .. st:peek()); print("len = " .. st:len())
    local v = st:pop(); print("popped = " .. v)
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:pop
do
    local st = lurek.patterns.newStack(100); st:push("first")
    st:push("second"); st:push("third")
    print("peek = " .. st:peek()); print("len = " .. st:len())
    local v = st:pop(); print("popped = " .. v)
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:peek
do
    local st = lurek.patterns.newStack(100); st:push("first")
    st:push("second"); st:push("third")
    print("peek = " .. st:peek()); print("len = " .. st:len())
    local v = st:pop(); print("popped = " .. v)
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:len
do
    local st = lurek.patterns.newStack(100); st:push("first")
    st:push("second"); st:push("third")
    print("peek = " .. st:peek()); print("len = " .. st:len())
    local v = st:pop(); print("popped = " .. v)
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:isEmpty
do
    local st = lurek.patterns.newStack(100); st:push("first")
    st:push("second"); st:push("third")
    print("peek = " .. st:peek()); print("len = " .. st:len())
    local v = st:pop(); print("popped = " .. v)
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:pushBottom
do
    local st = lurek.patterns.newStack(5); st:push("a"); st:push("b"); st:push("c")
    st:pushBottom("z"); print("bottom = " .. st:peekBottom()); print("at 2 = " .. st:peekAt(2)); st:insertAt(2, "x")
    local removed = st:removeAt(2); print("removed = " .. removed); local many = st:popMany(2); print("popped many = " .. #many)
    st:push("p"); st:push("q"); st:moveWithin(1, 2); print("full = " .. tostring(st:isFull()))
    local arr = st:toArray(); print("array = " .. #arr); st:clear(); print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:popBottom
do
    local st = lurek.patterns.newStack(5); st:push("a"); st:push("b"); st:push("c")
    st:pushBottom("z"); print("bottom = " .. st:peekBottom()); print("at 2 = " .. st:peekAt(2)); st:insertAt(2, "x")
    local removed = st:removeAt(2); print("removed = " .. removed); local many = st:popMany(2); print("popped many = " .. #many)
    st:push("p"); st:push("q"); st:moveWithin(1, 2); print("full = " .. tostring(st:isFull()))
    local arr = st:toArray(); print("array = " .. #arr); st:clear(); print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:peekBottom
do
    local st = lurek.patterns.newStack(5); st:push("a"); st:push("b"); st:push("c")
    st:pushBottom("z"); print("bottom = " .. st:peekBottom()); print("at 2 = " .. st:peekAt(2)); st:insertAt(2, "x")
    local removed = st:removeAt(2); print("removed = " .. removed); local many = st:popMany(2); print("popped many = " .. #many)
    st:push("p"); st:push("q"); st:moveWithin(1, 2); print("full = " .. tostring(st:isFull()))
    local arr = st:toArray(); print("array = " .. #arr); st:clear(); print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:peekAt
do
    local st = lurek.patterns.newStack(5); st:push("a"); st:push("b"); st:push("c")
    st:pushBottom("z"); print("bottom = " .. st:peekBottom()); print("at 2 = " .. st:peekAt(2)); st:insertAt(2, "x")
    local removed = st:removeAt(2); print("removed = " .. removed); local many = st:popMany(2); print("popped many = " .. #many)
    st:push("p"); st:push("q"); st:moveWithin(1, 2); print("full = " .. tostring(st:isFull()))
    local arr = st:toArray(); print("array = " .. #arr); st:clear(); print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:insertAt
do
    local st = lurek.patterns.newStack(5); st:push("a"); st:push("b"); st:push("c")
    st:pushBottom("z"); print("bottom = " .. st:peekBottom()); print("at 2 = " .. st:peekAt(2)); st:insertAt(2, "x")
    local removed = st:removeAt(2); print("removed = " .. removed); local many = st:popMany(2); print("popped many = " .. #many)
    st:push("p"); st:push("q"); st:moveWithin(1, 2); print("full = " .. tostring(st:isFull()))
    local arr = st:toArray(); print("array = " .. #arr); st:clear(); print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:removeAt
do
    local st = lurek.patterns.newStack(5); st:push("a"); st:push("b"); st:push("c")
    st:pushBottom("z"); print("bottom = " .. st:peekBottom()); print("at 2 = " .. st:peekAt(2)); st:insertAt(2, "x")
    local removed = st:removeAt(2); print("removed = " .. removed); local many = st:popMany(2); print("popped many = " .. #many)
    st:push("p"); st:push("q"); st:moveWithin(1, 2); print("full = " .. tostring(st:isFull()))
    local arr = st:toArray(); print("array = " .. #arr); st:clear(); print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:popMany
do
    local st = lurek.patterns.newStack(5); st:push("a"); st:push("b"); st:push("c")
    st:pushBottom("z"); print("bottom = " .. st:peekBottom()); print("at 2 = " .. st:peekAt(2)); st:insertAt(2, "x")
    local removed = st:removeAt(2); print("removed = " .. removed); local many = st:popMany(2); print("popped many = " .. #many)
    st:push("p"); st:push("q"); st:moveWithin(1, 2); print("full = " .. tostring(st:isFull()))
    local arr = st:toArray(); print("array = " .. #arr); st:clear(); print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:moveWithin
do
    local st = lurek.patterns.newStack(5); st:push("a"); st:push("b"); st:push("c")
    st:pushBottom("z"); print("bottom = " .. st:peekBottom()); print("at 2 = " .. st:peekAt(2)); st:insertAt(2, "x")
    local removed = st:removeAt(2); print("removed = " .. removed); local many = st:popMany(2); print("popped many = " .. #many)
    st:push("p"); st:push("q"); st:moveWithin(1, 2); print("full = " .. tostring(st:isFull()))
    local arr = st:toArray(); print("array = " .. #arr); st:clear(); print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:isFull
do
    local st = lurek.patterns.newStack(5); st:push("a"); st:push("b"); st:push("c")
    st:pushBottom("z"); print("bottom = " .. st:peekBottom()); print("at 2 = " .. st:peekAt(2)); st:insertAt(2, "x")
    local removed = st:removeAt(2); print("removed = " .. removed); local many = st:popMany(2); print("popped many = " .. #many)
    st:push("p"); st:push("q"); st:moveWithin(1, 2); print("full = " .. tostring(st:isFull()))
    local arr = st:toArray(); print("array = " .. #arr); st:clear(); print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:clear
do
    local st = lurek.patterns.newStack(5); st:push("a"); st:push("b"); st:push("c")
    st:pushBottom("z"); print("bottom = " .. st:peekBottom()); print("at 2 = " .. st:peekAt(2)); st:insertAt(2, "x")
    local removed = st:removeAt(2); print("removed = " .. removed); local many = st:popMany(2); print("popped many = " .. #many)
    st:push("p"); st:push("q"); st:moveWithin(1, 2); print("full = " .. tostring(st:isFull()))
    local arr = st:toArray(); print("array = " .. #arr); st:clear(); print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:toArray
do
    local st = lurek.patterns.newStack(5); st:push("a"); st:push("b"); st:push("c")
    st:pushBottom("z"); print("bottom = " .. st:peekBottom()); print("at 2 = " .. st:peekAt(2)); st:insertAt(2, "x")
    local removed = st:removeAt(2); print("removed = " .. removed); local many = st:popMany(2); print("popped many = " .. #many)
    st:push("p"); st:push("q"); st:moveWithin(1, 2); print("full = " .. tostring(st:isFull()))
    local arr = st:toArray(); print("array = " .. #arr); st:clear(); print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: lurek.patterns.newQueue
do
    local q = lurek.patterns.newQueue(10); q:enqueue("msg1")
    q:enqueue("msg2"); q:enqueue("msg3")
    print("front = " .. q:front()); print("back = " .. q:back())
    print("len = " .. q:len()); local v = q:dequeue()
    print("dequeued = " .. v); print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:enqueue
do
    local q = lurek.patterns.newQueue(10); q:enqueue("msg1")
    q:enqueue("msg2"); q:enqueue("msg3")
    print("front = " .. q:front()); print("back = " .. q:back())
    print("len = " .. q:len()); local v = q:dequeue()
    print("dequeued = " .. v); print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:dequeue
do
    local q = lurek.patterns.newQueue(10); q:enqueue("msg1")
    q:enqueue("msg2"); q:enqueue("msg3")
    print("front = " .. q:front()); print("back = " .. q:back())
    print("len = " .. q:len()); local v = q:dequeue()
    print("dequeued = " .. v); print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:front
do
    local q = lurek.patterns.newQueue(10); q:enqueue("msg1")
    q:enqueue("msg2"); q:enqueue("msg3")
    print("front = " .. q:front()); print("back = " .. q:back())
    print("len = " .. q:len()); local v = q:dequeue()
    print("dequeued = " .. v); print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:back
do
    local q = lurek.patterns.newQueue(10); q:enqueue("msg1")
    q:enqueue("msg2"); q:enqueue("msg3")
    print("front = " .. q:front()); print("back = " .. q:back())
    print("len = " .. q:len()); local v = q:dequeue()
    print("dequeued = " .. v); print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:len
do
    local q = lurek.patterns.newQueue(10); q:enqueue("msg1")
    q:enqueue("msg2"); q:enqueue("msg3")
    print("front = " .. q:front()); print("back = " .. q:back())
    print("len = " .. q:len()); local v = q:dequeue()
    print("dequeued = " .. v); print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:isEmpty
do
    local q = lurek.patterns.newQueue(10); q:enqueue("msg1")
    q:enqueue("msg2"); q:enqueue("msg3")
    print("front = " .. q:front()); print("back = " .. q:back())
    print("len = " .. q:len()); local v = q:dequeue()
    print("dequeued = " .. v); print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:enqueueFront
do
    local q = lurek.patterns.newQueue(5); q:enqueue("a"); q:enqueue("b"); q:enqueue("c")
    q:enqueueFront("priority"); print("front = " .. q:front()); local back = q:dequeueBack(); print("dequeued back = " .. back)
    q:insertAt(2, "inserted"); print("at 2 = " .. q:peekAt(2)); local rem = q:removeAt(2)
    print("removed = " .. rem); print("full = " .. tostring(q:isFull())); local arr = q:toArray()
    print("array = " .. #arr); q:clear(); print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:dequeueBack
do
    local q = lurek.patterns.newQueue(5); q:enqueue("a"); q:enqueue("b"); q:enqueue("c")
    q:enqueueFront("priority"); print("front = " .. q:front()); local back = q:dequeueBack(); print("dequeued back = " .. back)
    q:insertAt(2, "inserted"); print("at 2 = " .. q:peekAt(2)); local rem = q:removeAt(2)
    print("removed = " .. rem); print("full = " .. tostring(q:isFull())); local arr = q:toArray()
    print("array = " .. #arr); q:clear(); print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:insertAt
do
    local q = lurek.patterns.newQueue(5); q:enqueue("a"); q:enqueue("b"); q:enqueue("c")
    q:enqueueFront("priority"); print("front = " .. q:front()); local back = q:dequeueBack(); print("dequeued back = " .. back)
    q:insertAt(2, "inserted"); print("at 2 = " .. q:peekAt(2)); local rem = q:removeAt(2)
    print("removed = " .. rem); print("full = " .. tostring(q:isFull())); local arr = q:toArray()
    print("array = " .. #arr); q:clear(); print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:removeAt
do
    local q = lurek.patterns.newQueue(5); q:enqueue("a"); q:enqueue("b"); q:enqueue("c")
    q:enqueueFront("priority"); print("front = " .. q:front()); local back = q:dequeueBack(); print("dequeued back = " .. back)
    q:insertAt(2, "inserted"); print("at 2 = " .. q:peekAt(2)); local rem = q:removeAt(2)
    print("removed = " .. rem); print("full = " .. tostring(q:isFull())); local arr = q:toArray()
    print("array = " .. #arr); q:clear(); print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:peekAt
do
    local q = lurek.patterns.newQueue(5); q:enqueue("a"); q:enqueue("b"); q:enqueue("c")
    q:enqueueFront("priority"); print("front = " .. q:front()); local back = q:dequeueBack(); print("dequeued back = " .. back)
    q:insertAt(2, "inserted"); print("at 2 = " .. q:peekAt(2)); local rem = q:removeAt(2)
    print("removed = " .. rem); print("full = " .. tostring(q:isFull())); local arr = q:toArray()
    print("array = " .. #arr); q:clear(); print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:isFull
do
    local q = lurek.patterns.newQueue(5); q:enqueue("a"); q:enqueue("b"); q:enqueue("c")
    q:enqueueFront("priority"); print("front = " .. q:front()); local back = q:dequeueBack(); print("dequeued back = " .. back)
    q:insertAt(2, "inserted"); print("at 2 = " .. q:peekAt(2)); local rem = q:removeAt(2)
    print("removed = " .. rem); print("full = " .. tostring(q:isFull())); local arr = q:toArray()
    print("array = " .. #arr); q:clear(); print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:clear
do
    local q = lurek.patterns.newQueue(5); q:enqueue("a"); q:enqueue("b"); q:enqueue("c")
    q:enqueueFront("priority"); print("front = " .. q:front()); local back = q:dequeueBack(); print("dequeued back = " .. back)
    q:insertAt(2, "inserted"); print("at 2 = " .. q:peekAt(2)); local rem = q:removeAt(2)
    print("removed = " .. rem); print("full = " .. tostring(q:isFull())); local arr = q:toArray()
    print("array = " .. #arr); q:clear(); print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:toArray
do
    local q = lurek.patterns.newQueue(5); q:enqueue("a"); q:enqueue("b"); q:enqueue("c")
    q:enqueueFront("priority"); print("front = " .. q:front()); local back = q:dequeueBack(); print("dequeued back = " .. back)
    q:insertAt(2, "inserted"); print("at 2 = " .. q:peekAt(2)); local rem = q:removeAt(2)
    print("removed = " .. rem); print("full = " .. tostring(q:isFull())); local arr = q:toArray()
    print("array = " .. #arr); q:clear(); print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: lurek.patterns.newPriorityQueue
do
    local pq = lurek.patterns.newPriorityQueue("tasks"); pq:push(1, "low_task", "low"); pq:push(10, "high_task", "high")
    pq:push(5, "mid_task", "mid"); print("len = " .. pq:len()); local top = pq:peek()
    if top then print("peek = " .. tostring(top)) end; local item = pq:pop(); if item then print("popped = " .. tostring(item)) end
    print("after pop: len = " .. pq:len()); print("empty = " .. tostring(pq:isEmpty()))
    pq:clearAll(); print("after clear: empty = " .. tostring(pq:isEmpty()))
end

--@api-stub: LPriorityQueue:push
do
    local pq = lurek.patterns.newPriorityQueue("tasks"); pq:push(1, "low_task", "low"); pq:push(10, "high_task", "high")
    pq:push(5, "mid_task", "mid"); print("len = " .. pq:len()); local top = pq:peek()
    if top then print("peek = " .. tostring(top)) end; local item = pq:pop(); if item then print("popped = " .. tostring(item)) end
    print("after pop: len = " .. pq:len()); print("empty = " .. tostring(pq:isEmpty()))
    pq:clearAll(); print("after clear: empty = " .. tostring(pq:isEmpty()))
end

--@api-stub: LPriorityQueue:pop
do
    local pq = lurek.patterns.newPriorityQueue("tasks"); pq:push(1, "low_task", "low"); pq:push(10, "high_task", "high")
    pq:push(5, "mid_task", "mid"); print("len = " .. pq:len()); local top = pq:peek()
    if top then print("peek = " .. tostring(top)) end; local item = pq:pop(); if item then print("popped = " .. tostring(item)) end
    print("after pop: len = " .. pq:len()); print("empty = " .. tostring(pq:isEmpty()))
    pq:clearAll(); print("after clear: empty = " .. tostring(pq:isEmpty()))
end

--@api-stub: LPriorityQueue:peek
do
    local pq = lurek.patterns.newPriorityQueue("tasks"); pq:push(1, "low_task", "low"); pq:push(10, "high_task", "high")
    pq:push(5, "mid_task", "mid"); print("len = " .. pq:len()); local top = pq:peek()
    if top then print("peek = " .. tostring(top)) end; local item = pq:pop(); if item then print("popped = " .. tostring(item)) end
    print("after pop: len = " .. pq:len()); print("empty = " .. tostring(pq:isEmpty()))
    pq:clearAll(); print("after clear: empty = " .. tostring(pq:isEmpty()))
end

--@api-stub: LPriorityQueue:len
do
    local pq = lurek.patterns.newPriorityQueue("tasks"); pq:push(1, "low_task", "low"); pq:push(10, "high_task", "high")
    pq:push(5, "mid_task", "mid"); print("len = " .. pq:len()); local top = pq:peek()
    if top then print("peek = " .. tostring(top)) end; local item = pq:pop(); if item then print("popped = " .. tostring(item)) end
    print("after pop: len = " .. pq:len()); print("empty = " .. tostring(pq:isEmpty()))
    pq:clearAll(); print("after clear: empty = " .. tostring(pq:isEmpty()))
end

--@api-stub: LPriorityQueue:isEmpty
do
    local pq = lurek.patterns.newPriorityQueue("tasks"); pq:push(1, "low_task", "low"); pq:push(10, "high_task", "high")
    pq:push(5, "mid_task", "mid"); print("len = " .. pq:len()); local top = pq:peek()
    if top then print("peek = " .. tostring(top)) end; local item = pq:pop(); if item then print("popped = " .. tostring(item)) end
    print("after pop: len = " .. pq:len()); print("empty = " .. tostring(pq:isEmpty()))
    pq:clearAll(); print("after clear: empty = " .. tostring(pq:isEmpty()))
end

--@api-stub: LPriorityQueue:clearAll
do
    local pq = lurek.patterns.newPriorityQueue("tasks"); pq:push(1, "low_task", "low"); pq:push(10, "high_task", "high")
    pq:push(5, "mid_task", "mid"); print("len = " .. pq:len()); local top = pq:peek()
    if top then print("peek = " .. tostring(top)) end; local item = pq:pop(); if item then print("popped = " .. tostring(item)) end
    print("after pop: len = " .. pq:len()); print("empty = " .. tostring(pq:isEmpty()))
    pq:clearAll(); print("after clear: empty = " .. tostring(pq:isEmpty()))
end

--@api-stub: lurek.patterns.newRing
do
    local ring = lurek.patterns.newRing(5, "fps_samples"); ring:push(60); ring:push(58); ring:push(62)
    ring:push(59); ring:push(61); print("len = " .. ring:len()); print("full = " .. tostring(ring:isFull()))
    local entry = ring:latest(); if entry then print("latest value = " .. entry.value) end; print("sum = " .. ring:sum()); print("average = " .. ring:average())
    ring:push(55); print("overwrote oldest, len = " .. ring:len()); local arr = ring:toArray()
    print("array entries = " .. #arr); ring:clear(); print("after clear: len = " .. ring:len())
end

--@api-stub: LRing:push
do
    local ring = lurek.patterns.newRing(5, "fps_samples"); ring:push(60); ring:push(58); ring:push(62)
    ring:push(59); ring:push(61); print("len = " .. ring:len()); print("full = " .. tostring(ring:isFull()))
    local entry = ring:latest(); if entry then print("latest value = " .. entry.value) end; print("sum = " .. ring:sum()); print("average = " .. ring:average())
    ring:push(55); print("overwrote oldest, len = " .. ring:len()); local arr = ring:toArray()
    print("array entries = " .. #arr); ring:clear(); print("after clear: len = " .. ring:len())
end

--@api-stub: LRing:len
do
    local ring = lurek.patterns.newRing(5, "fps_samples"); ring:push(60); ring:push(58); ring:push(62)
    ring:push(59); ring:push(61); print("len = " .. ring:len()); print("full = " .. tostring(ring:isFull()))
    local entry = ring:latest(); if entry then print("latest value = " .. entry.value) end; print("sum = " .. ring:sum()); print("average = " .. ring:average())
    ring:push(55); print("overwrote oldest, len = " .. ring:len()); local arr = ring:toArray()
    print("array entries = " .. #arr); ring:clear(); print("after clear: len = " .. ring:len())
end

--@api-stub: LRing:latest
do
    local ring = lurek.patterns.newRing(5, "fps_samples"); ring:push(60); ring:push(58); ring:push(62)
    ring:push(59); ring:push(61); print("len = " .. ring:len()); print("full = " .. tostring(ring:isFull()))
    local entry = ring:latest(); if entry then print("latest value = " .. entry.value) end; print("sum = " .. ring:sum()); print("average = " .. ring:average())
    ring:push(55); print("overwrote oldest, len = " .. ring:len()); local arr = ring:toArray()
    print("array entries = " .. #arr); ring:clear(); print("after clear: len = " .. ring:len())
end

--@api-stub: LRing:isFull
do
    local ring = lurek.patterns.newRing(5, "fps_samples"); ring:push(60); ring:push(58); ring:push(62)
    ring:push(59); ring:push(61); print("len = " .. ring:len()); print("full = " .. tostring(ring:isFull()))
    local entry = ring:latest(); if entry then print("latest value = " .. entry.value) end; print("sum = " .. ring:sum()); print("average = " .. ring:average())
    ring:push(55); print("overwrote oldest, len = " .. ring:len()); local arr = ring:toArray()
    print("array entries = " .. #arr); ring:clear(); print("after clear: len = " .. ring:len())
end

--@api-stub: LRing:sum
do
    local ring = lurek.patterns.newRing(5, "fps_samples"); ring:push(60); ring:push(58); ring:push(62)
    ring:push(59); ring:push(61); print("len = " .. ring:len()); print("full = " .. tostring(ring:isFull()))
    local entry = ring:latest(); if entry then print("latest value = " .. entry.value) end; print("sum = " .. ring:sum()); print("average = " .. ring:average())
    ring:push(55); print("overwrote oldest, len = " .. ring:len()); local arr = ring:toArray()
    print("array entries = " .. #arr); ring:clear(); print("after clear: len = " .. ring:len())
end

--@api-stub: LRing:average
do
    local ring = lurek.patterns.newRing(5, "fps_samples"); ring:push(60); ring:push(58); ring:push(62)
    ring:push(59); ring:push(61); print("len = " .. ring:len()); print("full = " .. tostring(ring:isFull()))
    local entry = ring:latest(); if entry then print("latest value = " .. entry.value) end; print("sum = " .. ring:sum()); print("average = " .. ring:average())
    ring:push(55); print("overwrote oldest, len = " .. ring:len()); local arr = ring:toArray()
    print("array entries = " .. #arr); ring:clear(); print("after clear: len = " .. ring:len())
end

--@api-stub: LRing:toArray
do
    local ring = lurek.patterns.newRing(5, "fps_samples"); ring:push(60); ring:push(58); ring:push(62)
    ring:push(59); ring:push(61); print("len = " .. ring:len()); print("full = " .. tostring(ring:isFull()))
    local entry = ring:latest(); if entry then print("latest value = " .. entry.value) end; print("sum = " .. ring:sum()); print("average = " .. ring:average())
    ring:push(55); print("overwrote oldest, len = " .. ring:len()); local arr = ring:toArray()
    print("array entries = " .. #arr); ring:clear(); print("after clear: len = " .. ring:len())
end

--@api-stub: LRing:clear
do
    local ring = lurek.patterns.newRing(5, "fps_samples"); ring:push(60); ring:push(58); ring:push(62)
    ring:push(59); ring:push(61); print("len = " .. ring:len()); print("full = " .. tostring(ring:isFull()))
    local entry = ring:latest(); if entry then print("latest value = " .. entry.value) end; print("sum = " .. ring:sum()); print("average = " .. ring:average())
    ring:push(55); print("overwrote oldest, len = " .. ring:len()); local arr = ring:toArray()
    print("array entries = " .. #arr); ring:clear(); print("after clear: len = " .. ring:len())
end

--@api-stub: lurek.patterns.newWeightedRandom
do
    local wr = lurek.patterns.newWeightedRandom(); local id1 = wr:add(10, "common", "common_loot")
    local id2 = wr:add(3, "rare", "rare_loot"); local id3 = wr:add(1, "legendary", "legendary_loot")
    print("items = " .. wr:len()); print("total weight = " .. wr:totalWeight())
    local picked = wr:pick(0.5); print("picked = " .. tostring(picked))
    local multi = wr:pickN(2, {0.1, 0.9}); print("multi picks = " .. #multi)
end

--@api-stub: LWeightedRandom:add
do
    local wr = lurek.patterns.newWeightedRandom(); local id1 = wr:add(10, "common", "common_loot")
    local id2 = wr:add(3, "rare", "rare_loot"); local id3 = wr:add(1, "legendary", "legendary_loot")
    print("items = " .. wr:len()); print("total weight = " .. wr:totalWeight())
    local picked = wr:pick(0.5); print("picked = " .. tostring(picked))
    local multi = wr:pickN(2, {0.1, 0.9}); print("multi picks = " .. #multi)
end

--@api-stub: LWeightedRandom:pick
do
    local wr = lurek.patterns.newWeightedRandom(); local id1 = wr:add(10, "common", "common_loot")
    local id2 = wr:add(3, "rare", "rare_loot"); local id3 = wr:add(1, "legendary", "legendary_loot")
    print("items = " .. wr:len()); print("total weight = " .. wr:totalWeight())
    local picked = wr:pick(0.5); print("picked = " .. tostring(picked))
    local multi = wr:pickN(2, {0.1, 0.9}); print("multi picks = " .. #multi)
end

--@api-stub: LWeightedRandom:pickN
do
    local wr = lurek.patterns.newWeightedRandom(); local id1 = wr:add(10, "common", "common_loot")
    local id2 = wr:add(3, "rare", "rare_loot"); local id3 = wr:add(1, "legendary", "legendary_loot")
    print("items = " .. wr:len()); print("total weight = " .. wr:totalWeight())
    local picked = wr:pick(0.5); print("picked = " .. tostring(picked))
    local multi = wr:pickN(2, {0.1, 0.9}); print("multi picks = " .. #multi)
end

--@api-stub: LWeightedRandom:len
do
    local wr = lurek.patterns.newWeightedRandom(); local id1 = wr:add(10, "common", "common_loot")
    local id2 = wr:add(3, "rare", "rare_loot"); local id3 = wr:add(1, "legendary", "legendary_loot")
    print("items = " .. wr:len()); print("total weight = " .. wr:totalWeight())
    local picked = wr:pick(0.5); print("picked = " .. tostring(picked))
    local multi = wr:pickN(2, {0.1, 0.9}); print("multi picks = " .. #multi)
end

--@api-stub: LWeightedRandom:totalWeight
do
    local wr = lurek.patterns.newWeightedRandom(); local id1 = wr:add(10, "common", "common_loot")
    local id2 = wr:add(3, "rare", "rare_loot"); local id3 = wr:add(1, "legendary", "legendary_loot")
    print("items = " .. wr:len()); print("total weight = " .. wr:totalWeight())
    local picked = wr:pick(0.5); print("picked = " .. tostring(picked))
    local multi = wr:pickN(2, {0.1, 0.9}); print("multi picks = " .. #multi)
end

--@api-stub: LWeightedRandom:remove
do
    local wr = lurek.patterns.newWeightedRandom(); local id = wr:add(5, "item_a")
    wr:add(5, "item_b"); wr:setWeight(id, 20)
    print("revision = " .. wr:getRevision()); wr:remove(id)
    print("after remove: len = " .. wr:len()); print("empty = " .. tostring(wr:isEmpty()))
    wr:clearAll(); print("after clear: empty = " .. tostring(wr:isEmpty()))
end

--@api-stub: LWeightedRandom:setWeight
do
    local wr = lurek.patterns.newWeightedRandom(); local id = wr:add(5, "item_a")
    wr:add(5, "item_b"); wr:setWeight(id, 20)
    print("revision = " .. wr:getRevision()); wr:remove(id)
    print("after remove: len = " .. wr:len()); print("empty = " .. tostring(wr:isEmpty()))
    wr:clearAll(); print("after clear: empty = " .. tostring(wr:isEmpty()))
end

--@api-stub: LWeightedRandom:getRevision
do
    local wr = lurek.patterns.newWeightedRandom(); local id = wr:add(5, "item_a")
    wr:add(5, "item_b"); wr:setWeight(id, 20)
    print("revision = " .. wr:getRevision()); wr:remove(id)
    print("after remove: len = " .. wr:len()); print("empty = " .. tostring(wr:isEmpty()))
    wr:clearAll(); print("after clear: empty = " .. tostring(wr:isEmpty()))
end

--@api-stub: LWeightedRandom:isEmpty
do
    local wr = lurek.patterns.newWeightedRandom(); local id = wr:add(5, "item_a")
    wr:add(5, "item_b"); wr:setWeight(id, 20)
    print("revision = " .. wr:getRevision()); wr:remove(id)
    print("after remove: len = " .. wr:len()); print("empty = " .. tostring(wr:isEmpty()))
    wr:clearAll(); print("after clear: empty = " .. tostring(wr:isEmpty()))
end

--@api-stub: LWeightedRandom:clearAll
do
    local wr = lurek.patterns.newWeightedRandom(); local id = wr:add(5, "item_a")
    wr:add(5, "item_b"); wr:setWeight(id, 20)
    print("revision = " .. wr:getRevision()); wr:remove(id)
    print("after remove: len = " .. wr:len()); print("empty = " .. tostring(wr:isEmpty()))
    wr:clearAll(); print("after clear: empty = " .. tostring(wr:isEmpty()))
end

--@api-stub: lurek.patterns.newRelationshipManager
do
    local rm = lurek.patterns.newRelationshipManager(); rm:setValue(1, 2, 50)
    rm:setValue(1, 3, -20); print("1→2 = " .. rm:getValue(1, 2))
    print("1→3 = " .. rm:getValue(1, 3))
    rm:adjustValue(1, 2, 10)
    print("adjusted 1→2 = " .. rm:getValue(1, 2))
end

--@api-stub: LRelationshipManager:setValue
do
    local rm = lurek.patterns.newRelationshipManager(); rm:setValue(1, 2, 50)
    rm:setValue(1, 3, -20); print("1→2 = " .. rm:getValue(1, 2))
    print("1→3 = " .. rm:getValue(1, 3))
    rm:adjustValue(1, 2, 10)
    print("adjusted 1→2 = " .. rm:getValue(1, 2))
end

--@api-stub: LRelationshipManager:getValue
do
    local rm = lurek.patterns.newRelationshipManager(); rm:setValue(1, 2, 50)
    rm:setValue(1, 3, -20); print("1→2 = " .. rm:getValue(1, 2))
    print("1→3 = " .. rm:getValue(1, 3))
    rm:adjustValue(1, 2, 10)
    print("adjusted 1→2 = " .. rm:getValue(1, 2))
end

--@api-stub: LRelationshipManager:adjustValue
do
    local rm = lurek.patterns.newRelationshipManager(); rm:setValue(1, 2, 50)
    rm:setValue(1, 3, -20); print("1→2 = " .. rm:getValue(1, 2))
    print("1→3 = " .. rm:getValue(1, 3))
    rm:adjustValue(1, 2, 10)
    print("adjusted 1→2 = " .. rm:getValue(1, 2))
end

--@api-stub: LRelationshipManager:defineType
do
    local rm = lurek.patterns.newRelationshipManager(); rm:defineType("friendship", {"hostile", "unfriendly", "neutral", "friendly", "allied"}, "neutral"); rm:setLevel(1, 2, "friendship", "friendly")
    rm:setLevel(1, 3, "friendship", "hostile"); print("1→2 friendship = " .. rm:getLevel(1, 2, "friendship")); print("1→3 friendship = " .. rm:getLevel(1, 3, "friendship"))
    print("types = " .. #rm:typeNames()); print("pairs = " .. rm:pairCount())
    rm:removePair(1, 3); print("after remove: pairs = " .. rm:pairCount())
    rm:removeType("friendship"); print("after removeType: types = " .. #rm:typeNames())
end

--@api-stub: LRelationshipManager:setLevel
do
    local rm = lurek.patterns.newRelationshipManager(); rm:defineType("friendship", {"hostile", "unfriendly", "neutral", "friendly", "allied"}, "neutral"); rm:setLevel(1, 2, "friendship", "friendly")
    rm:setLevel(1, 3, "friendship", "hostile"); print("1→2 friendship = " .. rm:getLevel(1, 2, "friendship")); print("1→3 friendship = " .. rm:getLevel(1, 3, "friendship"))
    print("types = " .. #rm:typeNames()); print("pairs = " .. rm:pairCount())
    rm:removePair(1, 3); print("after remove: pairs = " .. rm:pairCount())
    rm:removeType("friendship"); print("after removeType: types = " .. #rm:typeNames())
end

--@api-stub: LRelationshipManager:getLevel
do
    local rm = lurek.patterns.newRelationshipManager(); rm:defineType("friendship", {"hostile", "unfriendly", "neutral", "friendly", "allied"}, "neutral"); rm:setLevel(1, 2, "friendship", "friendly")
    rm:setLevel(1, 3, "friendship", "hostile"); print("1→2 friendship = " .. rm:getLevel(1, 2, "friendship")); print("1→3 friendship = " .. rm:getLevel(1, 3, "friendship"))
    print("types = " .. #rm:typeNames()); print("pairs = " .. rm:pairCount())
    rm:removePair(1, 3); print("after remove: pairs = " .. rm:pairCount())
    rm:removeType("friendship"); print("after removeType: types = " .. #rm:typeNames())
end

--@api-stub: LRelationshipManager:typeNames
do
    local rm = lurek.patterns.newRelationshipManager(); rm:defineType("friendship", {"hostile", "unfriendly", "neutral", "friendly", "allied"}, "neutral"); rm:setLevel(1, 2, "friendship", "friendly")
    rm:setLevel(1, 3, "friendship", "hostile"); print("1→2 friendship = " .. rm:getLevel(1, 2, "friendship")); print("1→3 friendship = " .. rm:getLevel(1, 3, "friendship"))
    print("types = " .. #rm:typeNames()); print("pairs = " .. rm:pairCount())
    rm:removePair(1, 3); print("after remove: pairs = " .. rm:pairCount())
    rm:removeType("friendship"); print("after removeType: types = " .. #rm:typeNames())
end

--@api-stub: LRelationshipManager:pairCount
do
    local rm = lurek.patterns.newRelationshipManager(); rm:defineType("friendship", {"hostile", "unfriendly", "neutral", "friendly", "allied"}, "neutral"); rm:setLevel(1, 2, "friendship", "friendly")
    rm:setLevel(1, 3, "friendship", "hostile"); print("1→2 friendship = " .. rm:getLevel(1, 2, "friendship")); print("1→3 friendship = " .. rm:getLevel(1, 3, "friendship"))
    print("types = " .. #rm:typeNames()); print("pairs = " .. rm:pairCount())
    rm:removePair(1, 3); print("after remove: pairs = " .. rm:pairCount())
    rm:removeType("friendship"); print("after removeType: types = " .. #rm:typeNames())
end

--@api-stub: LRelationshipManager:removePair
do
    local rm = lurek.patterns.newRelationshipManager(); rm:defineType("friendship", {"hostile", "unfriendly", "neutral", "friendly", "allied"}, "neutral"); rm:setLevel(1, 2, "friendship", "friendly")
    rm:setLevel(1, 3, "friendship", "hostile"); print("1→2 friendship = " .. rm:getLevel(1, 2, "friendship")); print("1→3 friendship = " .. rm:getLevel(1, 3, "friendship"))
    print("types = " .. #rm:typeNames()); print("pairs = " .. rm:pairCount())
    rm:removePair(1, 3); print("after remove: pairs = " .. rm:pairCount())
    rm:removeType("friendship"); print("after removeType: types = " .. #rm:typeNames())
end

--@api-stub: LRelationshipManager:removeType
do
    local rm = lurek.patterns.newRelationshipManager(); rm:defineType("friendship", {"hostile", "unfriendly", "neutral", "friendly", "allied"}, "neutral"); rm:setLevel(1, 2, "friendship", "friendly")
    rm:setLevel(1, 3, "friendship", "hostile"); print("1→2 friendship = " .. rm:getLevel(1, 2, "friendship")); print("1→3 friendship = " .. rm:getLevel(1, 3, "friendship"))
    print("types = " .. #rm:typeNames()); print("pairs = " .. rm:pairCount())
    rm:removePair(1, 3); print("after remove: pairs = " .. rm:pairCount())
    rm:removeType("friendship"); print("after removeType: types = " .. #rm:typeNames())
end

--- Patterns Module Part 5: integrated multi-pattern examples, real-world scenarios


--@api-stub: Integration
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
do
    local graph = lurek.patterns.newGraph(true)
    local a = graph:addNode("core")
    local b = graph:addNode("physics")
    graph:addEdge(a, b)
    print("nodes = " .. graph:nodeCount())
end

--@api-stub: LGraph:bfs
do
    local graph = lurek.patterns.newGraph(true); local start = graph:addNode("core")
    local physics = graph:addNode("physics")
    graph:addEdge(start, physics)
    local order = graph:bfs(start)
    print("bfs count = " .. #order)
end

--- Patterns Module Part 5: BehaviorTree (addChild/nodeCount/setRoot), LList:clear, LObjectPool counts, LSimpleState:update, LStrategy:getCurrent


--@api-stub: LBehaviorTree:addChild
do
    local bt = lurek.patterns.newBehaviorTree(); local seq = bt:addSequence("root_seq")
    local leaf1 = bt:addLeaf("check", "check_label"); local leaf2 = bt:addLeaf("act", "act_label")
    bt:addChild(seq, leaf1); bt:addChild(seq, leaf2)
    bt:setRoot(seq)
    print("node_count=" .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:nodeCount
do
    local bt = lurek.patterns.newBehaviorTree(); local seq = bt:addSequence("root_seq")
    local leaf1 = bt:addLeaf("check", "check_label"); local leaf2 = bt:addLeaf("act", "act_label")
    bt:addChild(seq, leaf1); bt:addChild(seq, leaf2)
    bt:setRoot(seq)
    print("node_count=" .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:setRoot
do
    local bt = lurek.patterns.newBehaviorTree(); local seq = bt:addSequence("root_seq")
    local leaf1 = bt:addLeaf("check", "check_label"); local leaf2 = bt:addLeaf("act", "act_label")
    bt:addChild(seq, leaf1); bt:addChild(seq, leaf2)
    bt:setRoot(seq)
    print("node_count=" .. bt:nodeCount())
end

--@api-stub: LList:clear
do
    local list = lurek.patterns.newList(); list:add(1)
    list:add(2); list:add(3)
    print("before_clear=" .. list:len())
    list:clear()
    print("after_clear=" .. list:len())
end

--@api-stub: LObjectPool:getActiveCount
do
    local pool = lurek.patterns.newObjectPool(); pool:add({})
    pool:add({}); pool:add({})
    print("total=" .. pool:getTotalCount()); print("available=" .. pool:getAvailableCount())
    local obj = pool:acquire(); print("active=" .. pool:getActiveCount())
    pool:release(obj)
end

--@api-stub: LObjectPool:getAvailableCount
do
    local pool = lurek.patterns.newObjectPool(); pool:add({})
    pool:add({}); pool:add({})
    print("total=" .. pool:getTotalCount()); print("available=" .. pool:getAvailableCount())
    local obj = pool:acquire(); print("active=" .. pool:getActiveCount())
    pool:release(obj)
end

--@api-stub: LObjectPool:getTotalCount
do
    local pool = lurek.patterns.newObjectPool(); pool:add({})
    pool:add({}); pool:add({})
    print("total=" .. pool:getTotalCount()); print("available=" .. pool:getAvailableCount())
    local obj = pool:acquire(); print("active=" .. pool:getActiveCount())
    pool:release(obj)
end

--@api-stub: LSimpleState:update
do
    local fsm = lurek.patterns.newSimpleState(); fsm:addState("idle", { enter = function() print("enter idle") end, update = function(dt) print("tick idle dt=" .. dt) end, exit = function() print("exit idle") end, })
    fsm:addState("run", { enter = function() print("enter run") end, update = function(dt) print("tick run dt=" .. dt) end, })
    fsm:transitionTo("idle")
    fsm:update(0.016)
    print("current=" .. fsm:getCurrent())
end

--@api-stub: LStrategy:getCurrent
do
    local strat = lurek.patterns.newStrategy(); strat:register("attack", function() return "attacking" end)
    strat:register("flee", function() return "fleeing" end)
    strat:set("attack")
    print("current=" .. tostring(strat:getCurrent()))
    strat:execute()
end

print("content/examples/patterns.lua")
