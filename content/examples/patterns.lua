-- content/examples/patterns.lua
-- Auto-generated from content/examples2/patterns_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/patterns.lua

--- Patterns Module Part 1: service locator, object pool, factory, strategy

--@api-stub: lurek.patterns.newServiceLocator
do
    local services = lurek.patterns.newServiceLocator()
    services:provide("audio", {volume = 0.8})
    print("has audio = " .. tostring(services:has("audio")))
    print("services = " .. #services:getServices())
end

--@api-stub: LServiceLocator:provide
do
    local services = lurek.patterns.newServiceLocator()
    services:provide("renderer", {backend = "wgpu"})
    print("has renderer = " .. tostring(services:has("renderer")))
    print("services = " .. #services:getServices())
end

--@api-stub: LServiceLocator:locate
do
    local services = lurek.patterns.newServiceLocator()
    services:provide("audio", {volume = 0.8, muted = false})
    local audio = services:locate("audio")
    print("audio volume = " .. tostring(audio and audio.volume))
    print("has audio = " .. tostring(services:has("audio")))
end

--@api-stub: LServiceLocator:has
do
    local services = lurek.patterns.newServiceLocator()
    services:provide("input", {keyboard = true})
    print("has input = " .. tostring(services:has("input")))
    print("has physics = " .. tostring(services:has("physics")))
end

--@api-stub: LServiceLocator:getServices
do
    local services = lurek.patterns.newServiceLocator()
    services:provide("renderer", {backend = "wgpu"})
    services:provide("audio", {volume = 1.0})
    local names = services:getServices()
    print("services = " .. #names)
    print("first = " .. tostring(names[1]))
end

--@api-stub: LServiceLocator:remove
do
    local services = lurek.patterns.newServiceLocator()
    services:provide("save", {slot = 1})
    services:remove("save")
    print("has save = " .. tostring(services:has("save")))
    print("services = " .. #services:getServices())
end

--@api-stub: LServiceLocator:clearAll
do
    local services = lurek.patterns.newServiceLocator()
    services:provide("renderer", {backend = "wgpu"})
    services:provide("audio", {volume = 0.6})
    print("before = " .. #services:getServices())
    services:clearAll()
    print("after = " .. #services:getServices())
end

--@api-stub: lurek.patterns.newObjectPool
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1, active = false})
    print("total = " .. pool:getTotalCount())
    print("available = " .. pool:getAvailableCount())
end

--@api-stub: LObjectPool:add
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1, active = false})
    pool:add({id = 2, active = false})
    print("total = " .. pool:getTotalCount())
    print("available = " .. pool:getAvailableCount())
end

--@api-stub: LObjectPool:acquire
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1, active = false})
    pool:add({id = 2, active = false})
    local obj = pool:acquire()
    print("acquired = " .. tostring(obj and obj.id))
    print("active = " .. pool:getActiveCount())
end

--@api-stub: LObjectPool:release
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1, active = false})
    pool:add({id = 2, active = false})
    local obj = pool:acquire()
    pool:release(obj)
    print("active = " .. pool:getActiveCount())
    print("available = " .. pool:getAvailableCount())
end

--@api-stub: LObjectPool:clearAll
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1})
    pool:add({id = 2})
    print("before = " .. pool:getTotalCount())
    pool:clearAll()
    print("after = " .. pool:getTotalCount())
end

--@api-stub: lurek.patterns.newFactory
do
    local factory = lurek.patterns.newFactory()
    factory:register("enemy", function(hp)
        return {type = "enemy", hp = hp or 100}
    end)
    local enemy = factory:create("enemy", 120)
    print("enemy hp = " .. tostring(enemy and enemy.hp))
    print("types = " .. #factory:getTypes())
end

--@api-stub: LFactory:register
do
    local factory = lurek.patterns.newFactory()
    factory:register("enemy", function(hp)
        return {type = "enemy", hp = hp or 100}
    end)
    print("has enemy = " .. tostring(factory:has("enemy")))
    print("types = " .. #factory:getTypes())
end

--@api-stub: LFactory:has
do
    local factory = lurek.patterns.newFactory()
    factory:register("bullet", function(speed)
        return {type = "bullet", speed = speed or 300}
    end)
    print("has bullet = " .. tostring(factory:has("bullet")))
    print("has enemy = " .. tostring(factory:has("enemy")))
end

--@api-stub: LFactory:create
do
    local factory = lurek.patterns.newFactory()
    factory:register("bullet", function(speed)
        return {type = "bullet", speed = speed or 300}
    end)
    local bullet = factory:create("bullet", 450)
    print("bullet speed = " .. tostring(bullet and bullet.speed))
    print("types = " .. #factory:getTypes())
end

--@api-stub: LFactory:getTypes
do
    local factory = lurek.patterns.newFactory()
    factory:register("enemy", function()
        return {type = "enemy"}
    end)
    factory:register("bullet", function()
        return {type = "bullet"}
    end)
    local types = factory:getTypes()
    print("types = " .. #types)
    print("has enemy = " .. tostring(factory:has("enemy")))
end

--@api-stub: LFactory:alias
do
    local factory = lurek.patterns.newFactory()
    factory:register("goblin", function()
        return {type = "goblin", hp = 30}
    end)
    factory:alias("small_enemy", "goblin")
    local goblin = factory:create("small_enemy")
    print("alias type = " .. tostring(goblin and goblin.type))
    print("has alias target = " .. tostring(factory:has("small_enemy")))
end

--@api-stub: LFactory:remove
do
    local factory = lurek.patterns.newFactory()
    factory:register("goblin", function()
        return {type = "goblin"}
    end)
    factory:remove("goblin")
    print("has goblin = " .. tostring(factory:has("goblin")))
    print("types = " .. #factory:getTypes())
end

--@api-stub: LFactory:clearAll
do
    local factory = lurek.patterns.newFactory()
    factory:register("enemy", function()
        return {type = "enemy"}
    end)
    factory:register("bullet", function()
        return {type = "bullet"}
    end)
    print("before = " .. #factory:getTypes())
    factory:clearAll()
    print("after = " .. #factory:getTypes())
end

--@api-stub: lurek.patterns.newStrategy
do
    local strat = lurek.patterns.newStrategy()
    strat:register("attack", function(target)
        return "attack " .. target
    end)
    strat:register("flee", function(target)
        return "flee from " .. target
    end)
    strat:set("attack")
    print("current = " .. tostring(strat:getCurrent()))
    print("result = " .. tostring(strat:execute("orc")))
end

--@api-stub: LStrategy:register
do
    local strat = lurek.patterns.newStrategy()
    strat:register("attack", function(target)
        return "attack " .. target
    end)
    strat:register("flee", function(target)
        return "flee from " .. target
    end)
    print("has attack = " .. tostring(strat:has("attack")))
    print("names = " .. #strat:names())
end

--@api-stub: LStrategy:set
do
    local strat = lurek.patterns.newStrategy()
    strat:register("attack", function(target)
        return "attack " .. target
    end)
    strat:register("flee", function(target)
        return "flee from " .. target
    end)
    strat:set("flee")
    print("current = " .. tostring(strat:getCurrent()))
    print("result = " .. tostring(strat:execute("dragon")))
end

--@api-stub: LStrategy:execute
do
    local strat = lurek.patterns.newStrategy()
    strat:register("attack", function(target)
        return "attack " .. target
    end)
    strat:register("flee", function(target)
        return "flee from " .. target
    end)
    strat:set("attack")
    print("current = " .. tostring(strat:getCurrent()))
    print("result = " .. tostring(strat:execute("slime")))
end

--@api-stub: LStrategy:has
do
    local strat = lurek.patterns.newStrategy()
    strat:register("fast", function()
        return "fast"
    end)
    strat:register("slow", function()
        return "slow"
    end)
    print("has fast = " .. tostring(strat:has("fast")))
    print("has medium = " .. tostring(strat:has("medium")))
end

--@api-stub: LStrategy:names
do
    local strat = lurek.patterns.newStrategy()
    strat:register("fast", function()
        return "fast"
    end)
    strat:register("slow", function()
        return "slow"
    end)
    local names = strat:names()
    print("names = " .. #names)
    print("first = " .. tostring(names[1]))
end

--@api-stub: LStrategy:remove
do
    local strat = lurek.patterns.newStrategy()
    strat:register("fast", function()
        return "fast"
    end)
    strat:register("slow", function()
        return "slow"
    end)
    strat:remove("slow")
    print("has slow = " .. tostring(strat:has("slow")))
    print("names = " .. #strat:names())
end

--@api-stub: LStrategy:clear
do
    local strat = lurek.patterns.newStrategy()
    strat:register("fast", function()
        return "fast"
    end)
    strat:register("slow", function()
        return "slow"
    end)
    print("before = " .. #strat:names())
    strat:clear()
    print("after = " .. #strat:names())
end

--- Patterns Module Part 2: FSM, command stack, behavior tree, blackboard

--@api-stub: lurek.patterns.newSimpleState
do
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("idle", {
        enter = function()
            print("enter idle")
        end,
        update = function(dt)
            print("idle dt = " .. dt)
        end
    })
    fsm:transitionTo("idle")
    fsm:update(0.016)
    print("current = " .. tostring(fsm:getCurrent()))
end

--@api-stub: LSimpleState:addState
do
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("idle", {
        enter = function()
            print("enter idle")
        end
    })
    fsm:addState("walk", {
        enter = function()
            print("enter walk")
        end
    })
    print("has walk = " .. tostring(fsm:hasState("walk")))
    print("states = " .. #fsm:getStates())
end

--@api-stub: LSimpleState:transitionTo
do
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("idle", {
        enter = function()
            print("enter idle")
        end
    })
    fsm:addState("walk", {
        enter = function()
            print("enter walk")
        end
    })
    fsm:transitionTo("walk")
    print("current = " .. tostring(fsm:getCurrent()))
    print("has idle = " .. tostring(fsm:hasState("idle")))
end

--@api-stub: LSimpleState:getCurrent
do
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("idle", {
        enter = function()
            print("enter idle")
        end
    })
    fsm:transitionTo("idle")
    print("current = " .. tostring(fsm:getCurrent()))
    print("states = " .. #fsm:getStates())
end

--@api-stub: LSimpleState:hasState
do
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("menu")
    fsm:addState("game")
    print("has menu = " .. tostring(fsm:hasState("menu")))
    print("has pause = " .. tostring(fsm:hasState("pause")))
end

--@api-stub: LSimpleState:getStates
do
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("menu")
    fsm:addState("game")
    fsm:addState("pause")
    print("states = " .. #fsm:getStates())
    print("has pause = " .. tostring(fsm:hasState("pause")))
end

--@api-stub: LSimpleState:clearAll
do
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("menu")
    fsm:addState("game")
    print("before = " .. #fsm:getStates())
    fsm:clearAll()
    print("after = " .. #fsm:getStates())
end

--@api-stub: lurek.patterns.newCommandStack
do
    local cmds = lurek.patterns.newCommandStack(10)
    local value = 1
    cmds:execute("add", function()
        value = value + 4
    end, function()
        value = value - 4
    end)
    cmds:execute("double", function()
        value = value * 2
    end, function()
        value = value / 2
    end)
    print("value = " .. value)
    print("history = " .. cmds:getHistorySize())
end

--@api-stub: LCommandStack:execute
do
    local cmds = lurek.patterns.newCommandStack(10)
    local value = 1
    cmds:execute("add", function()
        value = value + 4
    end, function()
        value = value - 4
    end)
    cmds:execute("double", function()
        value = value * 2
    end, function()
        value = value / 2
    end)
    print("value = " .. value)
    print("current = " .. tostring(cmds:getCurrentName()))
end

--@api-stub: LCommandStack:undo
do
    local cmds = lurek.patterns.newCommandStack(10)
    local value = 1
    cmds:execute("add", function()
        value = value + 4
    end, function()
        value = value - 4
    end)
    cmds:execute("double", function()
        value = value * 2
    end, function()
        value = value / 2
    end)
    cmds:undo()
    print("value = " .. value)
    print("can redo = " .. tostring(cmds:canRedo()))
end

--@api-stub: LCommandStack:redo
do
    local cmds = lurek.patterns.newCommandStack(10)
    local value = 1
    cmds:execute("add", function()
        value = value + 4
    end, function()
        value = value - 4
    end)
    cmds:execute("double", function()
        value = value * 2
    end, function()
        value = value / 2
    end)
    cmds:undo()
    cmds:redo()
    print("value = " .. value)
    print("current = " .. tostring(cmds:getCurrentName()))
end

--@api-stub: LCommandStack:canUndo
do
    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function()
    end, function()
    end)
    cmds:execute("step2", function()
    end, function()
    end)
    print("can undo = " .. tostring(cmds:canUndo()))
    print("history = " .. cmds:getHistorySize())
end

--@api-stub: LCommandStack:canRedo
do
    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function()
    end, function()
    end)
    cmds:execute("step2", function()
    end, function()
    end)
    cmds:undo()
    print("can redo = " .. tostring(cmds:canRedo()))
    print("current = " .. tostring(cmds:getCurrentName()))
end

--@api-stub: LCommandStack:getCurrentName
do
    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function()
    end, function()
    end)
    cmds:execute("step2", function()
    end, function()
    end)
    print("current = " .. tostring(cmds:getCurrentName()))
    print("history = " .. cmds:getHistorySize())
end

--@api-stub: LCommandStack:getHistorySize
do
    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function()
    end, function()
    end)
    cmds:execute("step2", function()
    end, function()
    end)
    print("history = " .. cmds:getHistorySize())
    print("can undo = " .. tostring(cmds:canUndo()))
end

--@api-stub: LCommandStack:clearAll
do
    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function()
    end, function()
    end)
    cmds:execute("step2", function()
    end, function()
    end)
    print("before = " .. cmds:getHistorySize())
    cmds:clearAll()
    print("after = " .. cmds:getHistorySize())
end

--@api-stub: lurek.patterns.newBehaviorTree
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local check = bt:addLeaf("check")
    local act = bt:addLeaf("act")
    bt:addChild(root, check)
    bt:addChild(root, act)
    bt:setLeaf("check", function()
        return "success"
    end)
    bt:setLeaf("act", function()
        return "success"
    end)
    bt:setRoot(root)
    print("result = " .. bt:tick())
    print("nodes = " .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:addSequence
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local check = bt:addLeaf("check")
    bt:addChild(root, check)
    bt:setLeaf("check", function()
        return "success"
    end)
    bt:setRoot(root)
    print("result = " .. bt:tick())
    print("nodes = " .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:addSelector
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSelector("root")
    local check = bt:addLeaf("check")
    local idle = bt:addLeaf("idle")
    bt:addChild(root, check)
    bt:addChild(root, idle)
    bt:setLeaf("check", function()
        return "failure"
    end)
    bt:setLeaf("idle", function()
        return "success"
    end)
    bt:setRoot(root)
    print("result = " .. bt:tick())
    print("nodes = " .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:addLeaf
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local act = bt:addLeaf("act")
    bt:addChild(root, act)
    bt:setLeaf("act", function()
        return "success"
    end)
    bt:setRoot(root)
    print("result = " .. bt:tick())
    print("nodes = " .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:setLeaf
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local act = bt:addLeaf("act")
    bt:addChild(root, act)
    bt:setLeaf("act", function()
        print("leaf fired")
        return "success"
    end)
    bt:setRoot(root)
    print("result = " .. bt:tick())
    print("nodes = " .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:tick
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local act = bt:addLeaf("act")
    bt:addChild(root, act)
    bt:setLeaf("act", function()
        return "success"
    end)
    bt:setRoot(root)
    print("result = " .. bt:tick())
    print("nodes = " .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:resetState
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local act = bt:addLeaf("act")
    bt:addChild(root, act)
    bt:setLeaf("act", function()
        return "running"
    end)
    bt:setRoot(root)
    print("first = " .. bt:tick())
    bt:resetState()
    print("after reset = " .. bt:tick())
end

--@api-stub: LBehaviorTree:addParallel
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addParallel(2, "root")
    local a = bt:addLeaf("a")
    local b = bt:addLeaf("b")
    bt:addChild(root, a)
    bt:addChild(root, b)
    bt:setLeaf("a", function()
        return "success"
    end)
    bt:setLeaf("b", function()
        return "success"
    end)
    bt:setRoot(root)
    print("result = " .. bt:tick())
    print("nodes = " .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:addInverter
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addInverter("invert")
    local check = bt:addLeaf("check")
    bt:addChild(root, check)
    bt:setLeaf("check", function()
        return "failure"
    end)
    bt:setRoot(root)
    print("result = " .. bt:tick())
    print("nodes = " .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:addRepeat
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addRepeat(2, "repeat")
    local step = bt:addLeaf("step")
    local calls = 0
    bt:addChild(root, step)
    bt:setLeaf("step", function()
        calls = calls + 1
        return "success"
    end)
    bt:setRoot(root)
    print("result = " .. bt:tick())
    print("calls = " .. calls)
end

--@api-stub: LBehaviorTree:clearAll
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSelector("root")
    local idle = bt:addLeaf("idle")
    bt:addChild(root, idle)
    bt:setRoot(root)
    print("before = " .. bt:nodeCount())
    bt:clearAll()
    print("after = " .. bt:nodeCount())
end

--@api-stub: lurek.patterns.newBlackboard
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("health", 100)
    bb:set("mode", "idle")
    print("health = " .. tostring(bb:get("health")))
    print("keys = " .. #bb:keys())
end

--@api-stub: LBlackboard:set
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("score", 10)
    bb:set("score", 20)
    print("score = " .. tostring(bb:get("score")))
    print("revision = " .. bb:getRevision())
end

--@api-stub: LBlackboard:get
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("weapon", "sword")
    print("weapon = " .. tostring(bb:get("weapon")))
    print("has weapon = " .. tostring(bb:has("weapon")))
end

--@api-stub: LBlackboard:has
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("alive", true)
    print("has alive = " .. tostring(bb:has("alive")))
    print("has mana = " .. tostring(bb:has("mana")))
end

--@api-stub: LBlackboard:keys
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("health", 100)
    bb:set("weapon", "sword")
    local keys = bb:keys()
    print("keys = " .. #keys)
    print("first = " .. tostring(keys[1]))
end

--@api-stub: LBlackboard:watch
do
    local bb = lurek.patterns.newBlackboard("game_state")
    local watch_id = bb:watch("score", function(key, value)
        print(key .. " = " .. tostring(value))
    end)
    bb:set("score", 10)
    bb:set("score", 25)
    print("revision = " .. bb:getRevision())
    bb:unwatch(watch_id)
end

--@api-stub: LBlackboard:unwatch
do
    local bb = lurek.patterns.newBlackboard("game_state")
    local watch_id = bb:watch("score", function(key, value)
        print(key .. " = " .. tostring(value))
    end)
    bb:set("score", 10)
    bb:unwatch(watch_id)
    bb:set("score", 20)
    print("revision = " .. bb:getRevision())
end

--@api-stub: LBlackboard:getRevision
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("score", 10)
    bb:set("score", 20)
    print("revision = " .. bb:getRevision())
    print("score = " .. tostring(bb:get("score")))
end

--@api-stub: LBlackboard:snapshot
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("score", 42)
    bb:set("weapon", "sword")
    local snap = bb:snapshot()
    print("score = " .. tostring(snap.score))
    print("weapon = " .. tostring(snap.weapon))
end

--@api-stub: LBlackboard:clear
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("score", 42)
    print("before = " .. tostring(bb:has("score")))
    bb:clear("score")
    print("after = " .. tostring(bb:has("score")))
end

--@api-stub: LBlackboard:clearAll
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("score", 42)
    bb:set("weapon", "sword")
    print("before = " .. #bb:keys())
    bb:clearAll()
    print("after = " .. #bb:keys())
end

--- Patterns Module Part 3: observer, event bus, mediator, debounce, throttle, funnel

--@api-stub: lurek.patterns.newObserver
do
    local obs = lurek.patterns.newObserver("player_stats")
    local id = obs:subscribe("hp", function(key, value)
        print(key .. " = " .. tostring(value))
    end)
    obs:set("hp", 100)
    print("hp = " .. tostring(obs:get("hp")))
    obs:unsubscribe(id)
end

--@api-stub: LObserver:set
do
    local obs = lurek.patterns.newObserver("player_stats")
    local id = obs:subscribe("hp", function(key, value)
        print(key .. " = " .. tostring(value))
    end)
    obs:set("hp", 100)
    obs:set("hp", 75)
    print("hp = " .. tostring(obs:get("hp")))
    obs:unsubscribe(id)
end

--@api-stub: LObserver:get
do
    local obs = lurek.patterns.newObserver("player_stats")
    obs:set("hp", 90)
    print("hp = " .. tostring(obs:get("hp")))
    print("subs = " .. obs:getCount())
end

--@api-stub: LObserver:subscribe
do
    local obs = lurek.patterns.newObserver("player_stats")
    local id = obs:subscribe("hp", function(key, value)
        print(key .. " = " .. tostring(value))
    end)
    obs:set("hp", 100)
    print("subs = " .. obs:getCount())
    obs:unsubscribe(id)
end

--@api-stub: LObserver:unsubscribe
do
    local obs = lurek.patterns.newObserver("player_stats")
    local id = obs:subscribe("hp", function(key, value)
        print(key .. " = " .. tostring(value))
    end)
    obs:unsubscribe(id)
    obs:set("hp", 50)
    print("subs = " .. obs:getCount())
end

--@api-stub: LObserver:getCount
do
    local obs = lurek.patterns.newObserver("player_stats")
    obs:subscribe("score", function(key, value)
        print(key .. " = " .. tostring(value))
    end, true)
    print("subs = " .. obs:getCount())
    obs:set("score", 100)
    print("after = " .. obs:getCount())
end

--@api-stub: lurek.patterns.newEventBus
do
    local bus = lurek.patterns.newEventBus("game_events")
    local id = bus:on("damage", function(amount, source)
        print("damage = " .. tostring(amount) .. " from " .. tostring(source))
    end)
    bus:emit("damage", 25, "fire")
    print("listeners = " .. bus:getListenerCount("damage"))
    bus:off(id)
end

--@api-stub: LEventBus:on
do
    local bus = lurek.patterns.newEventBus("game_events")
    local id = bus:on("damage", function(amount, source)
        print("damage = " .. tostring(amount) .. " from " .. tostring(source))
    end, 1)
    bus:emit("damage", 12, "ice")
    print("listeners = " .. bus:getListenerCount("damage"))
    bus:off(id)
end

--@api-stub: LEventBus:emit
do
    local bus = lurek.patterns.newEventBus("game_events")
    local id = bus:on("damage", function(amount, source)
        print("damage = " .. tostring(amount) .. " from " .. tostring(source))
    end)
    bus:emit("damage", 18, "fire")
    print("events = " .. #bus:getEvents())
    bus:off(id)
end

--@api-stub: LEventBus:off
do
    local bus = lurek.patterns.newEventBus("game_events")
    local id = bus:on("damage", function(amount)
        print("damage = " .. tostring(amount))
    end)
    bus:off(id)
    bus:emit("damage", 5)
    print("listeners = " .. bus:getListenerCount("damage"))
end

--@api-stub: LEventBus:getListenerCount
do
    local bus = lurek.patterns.newEventBus("game_events")
    bus:on("spawn", function(id)
        print("spawn = " .. tostring(id))
    end)
    bus:on("spawn", function(id)
        print("spawn log = " .. tostring(id))
    end)
    print("spawn listeners = " .. bus:getListenerCount("spawn"))
    print("events = " .. #bus:getEvents())
end

--@api-stub: LEventBus:getEvents
do
    local bus = lurek.patterns.newEventBus("game_events")
    bus:on("spawn", function(id)
        print("spawn = " .. tostring(id))
    end)
    bus:on("hit", function(amount)
        print("hit = " .. tostring(amount))
    end)
    local events = bus:getEvents()
    print("events = " .. #events)
    print("first = " .. tostring(events[1]))
end

--@api-stub: LEventBus:clear
do
    local bus = lurek.patterns.newEventBus("game_events")
    bus:on("spawn", function(id)
        print("spawn = " .. tostring(id))
    end)
    print("before = " .. bus:getListenerCount("spawn"))
    bus:clear("spawn")
    print("after = " .. bus:getListenerCount("spawn"))
end

--@api-stub: LEventBus:clearAll
do
    local bus = lurek.patterns.newEventBus("game_events")
    bus:on("spawn", function(id)
        print("spawn = " .. tostring(id))
    end)
    bus:on("hit", function(amount)
        print("hit = " .. tostring(amount))
    end)
    print("before = " .. #bus:getEvents())
    bus:clearAll()
    print("after = " .. #bus:getEvents())
end

--@api-stub: lurek.patterns.newMediator
do
    local med = lurek.patterns.newMediator()
    local id = med:on("ui", function(msg, data)
        print(msg .. " = " .. tostring(data))
    end)
    med:send("ui", "hp", 80)
    print("channels = " .. #med:channels())
    med:off("ui", id)
end

--@api-stub: LMediator:on
do
    local med = lurek.patterns.newMediator()
    local id = med:on("ui", function(msg, data)
        print(msg .. " = " .. tostring(data))
    end)
    med:send("ui", "hp", 80)
    print("handlers = " .. med:handlerCount("ui"))
    med:off("ui", id)
end

--@api-stub: LMediator:send
do
    local med = lurek.patterns.newMediator()
    local id = med:on("ui", function(msg, data)
        print(msg .. " = " .. tostring(data))
    end)
    med:send("ui", "hp", 80)
    print("channels = " .. #med:channels())
    med:off("ui", id)
end

--@api-stub: LMediator:off
do
    local med = lurek.patterns.newMediator()
    local id = med:on("ui", function(msg, data)
        print(msg .. " = " .. tostring(data))
    end)
    med:off("ui", id)
    med:send("ui", "hp", 80)
    print("handlers = " .. med:handlerCount("ui"))
end

--@api-stub: LMediator:broadcast
do
    local med = lurek.patterns.newMediator()
    med:on("audio", function(msg)
        print("audio = " .. tostring(msg))
    end)
    med:on("video", function(msg)
        print("video = " .. tostring(msg))
    end)
    med:broadcast("pause")
    print("channels = " .. #med:channels())
    print("audio handlers = " .. med:handlerCount("audio"))
end

--@api-stub: LMediator:channels
do
    local med = lurek.patterns.newMediator()
    med:on("audio", function(msg)
        print("audio = " .. tostring(msg))
    end)
    med:on("video", function(msg)
        print("video = " .. tostring(msg))
    end)
    local channels = med:channels()
    print("channels = " .. #channels)
    print("first = " .. tostring(channels[1]))
end

--@api-stub: LMediator:handlerCount
do
    local med = lurek.patterns.newMediator()
    med:on("audio", function(msg)
        print("audio = " .. tostring(msg))
    end)
    med:on("audio", function(msg)
        print("audio log = " .. tostring(msg))
    end)
    print("audio handlers = " .. med:handlerCount("audio"))
    print("channels = " .. #med:channels())
end

--@api-stub: LMediator:removeChannel
do
    local med = lurek.patterns.newMediator()
    med:on("audio", function(msg)
        print("audio = " .. tostring(msg))
    end)
    print("before = " .. #med:channels())
    med:removeChannel("audio")
    print("after = " .. #med:channels())
end

--@api-stub: LMediator:clear
do
    local med = lurek.patterns.newMediator()
    med:on("audio", function(msg)
        print("audio = " .. tostring(msg))
    end)
    med:on("video", function(msg)
        print("video = " .. tostring(msg))
    end)
    print("before = " .. #med:channels())
    med:clear()
    print("after = " .. #med:channels())
end

--@api-stub: lurek.patterns.newDebounce
do
    local db = lurek.patterns.newDebounce(0.5)
    db:onFire(function()
        print("debounce fired")
    end)
    db:trigger()
    print("pending = " .. tostring(db:isPending()))
    db:update(0.6)
    print("fires = " .. db:getFireCount())
end

--@api-stub: LDebounce:trigger
do
    local db = lurek.patterns.newDebounce(0.5)
    db:onFire(function()
        print("debounce fired")
    end)
    db:trigger()
    print("pending = " .. tostring(db:isPending()))
    db:update(0.6)
    print("fires = " .. db:getFireCount())
end

--@api-stub: LDebounce:update
do
    local db = lurek.patterns.newDebounce(0.5)
    db:onFire(function()
        print("debounce fired")
    end)
    db:trigger()
    db:update(0.6)
    print("pending = " .. tostring(db:isPending()))
    print("fires = " .. db:getFireCount())
end

--@api-stub: LDebounce:onFire
do
    local db = lurek.patterns.newDebounce(0.5)
    db:onFire(function()
        print("debounce fired")
    end)
    db:trigger()
    db:update(0.6)
    print("fires = " .. db:getFireCount())
    print("pending = " .. tostring(db:isPending()))
end

--@api-stub: LDebounce:cancel
do
    local db = lurek.patterns.newDebounce(1.0)
    db:onFire(function()
        print("debounce fired")
    end)
    db:trigger()
    print("pending = " .. tostring(db:isPending()))
    db:cancel()
    db:update(1.1)
    print("fires = " .. db:getFireCount())
end

--@api-stub: LDebounce:isPending
do
    local db = lurek.patterns.newDebounce(1.0)
    db:onFire(function()
        print("debounce fired")
    end)
    db:trigger()
    print("pending = " .. tostring(db:isPending()))
    db:update(0.2)
    print("fires = " .. db:getFireCount())
end

--@api-stub: LDebounce:getFireCount
do
    local db = lurek.patterns.newDebounce(0.3)
    db:onFire(function()
        print("debounce fired")
    end)
    db:trigger()
    db:update(0.4)
    print("fires = " .. db:getFireCount())
    print("pending = " .. tostring(db:isPending()))
end

--@api-stub: lurek.patterns.newThrottle
do
    local th = lurek.patterns.newThrottle(0.2)
    local fires = 0
    th:onFire(function()
        fires = fires + 1
        print("throttle fired = " .. fires)
    end)
    th:update(0.1)
    th:update(0.1)
    th:update(0.2)
    print("fires = " .. th:getFireCount())
end

--@api-stub: LThrottle:onFire
do
    local th = lurek.patterns.newThrottle(0.2)
    local fires = 0
    th:onFire(function()
        fires = fires + 1
        print("throttle fired = " .. fires)
    end)
    th:update(0.2)
    th:update(0.2)
    print("fires = " .. th:getFireCount())
end

--@api-stub: LThrottle:update
do
    local th = lurek.patterns.newThrottle(0.2)
    local fires = 0
    th:onFire(function()
        fires = fires + 1
        print("throttle fired = " .. fires)
    end)
    th:update(0.1)
    th:update(0.1)
    print("fires = " .. th:getFireCount())
end

--@api-stub: LThrottle:getFireCount
do
    local th = lurek.patterns.newThrottle(0.2)
    th:onFire(function()
        print("throttle fired")
    end)
    th:update(0.2)
    th:update(0.2)
    print("fires = " .. th:getFireCount())
    print("progress = " .. th:getProgress())
end

--@api-stub: LThrottle:reset
do
    local th = lurek.patterns.newThrottle(1.0)
    th:onFire(function()
        print("throttle fired")
    end)
    th:update(0.5)
    print("progress = " .. th:getProgress())
    th:reset()
    print("after reset = " .. th:getProgress())
end

--@api-stub: LThrottle:setEnabled
do
    local th = lurek.patterns.newThrottle(1.0)
    th:onFire(function()
        print("throttle fired")
    end)
    th:setEnabled(false)
    th:update(2.0)
    print("fires = " .. th:getFireCount())
    print("progress = " .. th:getProgress())
end

--@api-stub: LThrottle:getProgress
do
    local th = lurek.patterns.newThrottle(1.0)
    th:onFire(function()
        print("throttle fired")
    end)
    th:update(0.5)
    print("progress = " .. th:getProgress())
    th:update(0.5)
    print("fires = " .. th:getFireCount())
end

--@api-stub: lurek.patterns.newFunnel
do
    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries)
        print("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    print("pending = " .. funnel:pendingCount())
    funnel:update(1.1)
    print("flush count = " .. funnel:getFlushCount())
end

--@api-stub: LFunnel:push
do
    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries)
        print("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    print("pending = " .. funnel:pendingCount())
    funnel:update(1.1)
    print("flush count = " .. funnel:getFlushCount())
end

--@api-stub: LFunnel:update
do
    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries)
        print("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:update(1.1)
    print("pending = " .. funnel:pendingCount())
    print("flush count = " .. funnel:getFlushCount())
end

--@api-stub: LFunnel:onFlush
do
    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries)
        print("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:update(1.1)
    print("pending = " .. funnel:pendingCount())
    print("flush count = " .. funnel:getFlushCount())
end

--@api-stub: LFunnel:flush
do
    local funnel = lurek.patterns.newFunnel(5.0, 0, "damage_log")
    funnel:onFlush(function(entries)
        print("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:flush()
    print("pending = " .. funnel:pendingCount())
    print("flush count = " .. funnel:getFlushCount())
end

--@api-stub: LFunnel:discard
do
    local funnel = lurek.patterns.newFunnel(5.0, 0, "damage_log")
    funnel:onFlush(function(entries)
        print("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:discard()
    print("pending = " .. funnel:pendingCount())
    print("flush count = " .. funnel:getFlushCount())
end

--@api-stub: LFunnel:pendingCount
do
    local funnel = lurek.patterns.newFunnel(5.0, 0, "damage_log")
    funnel:onFlush(function(entries)
        print("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    print("pending = " .. funnel:pendingCount())
    print("flush count = " .. funnel:getFlushCount())
end

--@api-stub: LFunnel:getFlushCount
do
    local funnel = lurek.patterns.newFunnel(5.0, 0, "damage_log")
    funnel:onFlush(function(entries)
        print("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:flush()
    print("pending = " .. funnel:pendingCount())
    print("flush count = " .. funnel:getFlushCount())
end

--- Patterns Module Part 4: graph, collections (list, map, set, stack, queue, ring, priority queue, weighted random, relationships)

--@api-stub: lurek.patterns.newGraph
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("A", {cost = 10})
    local b = g:addNode("B", {cost = 5})
    g:addEdge(a, b, 1.5, "road")
    print("nodes = " .. g:nodeCount())
    print("edges = " .. g:edgeCount())
end

--@api-stub: LPatternGraph:addNode
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("A", {cost = 10})
    local b = g:addNode("B", {cost = 5})
    g:addEdge(a, b, 1.0, "road")
    print("nodes = " .. g:nodeCount())
    print("has a = " .. tostring(g:hasNode(a)))
end

--@api-stub: LPatternGraph:addEdge
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("A")
    local b = g:addNode("B")
    g:addEdge(a, b, 2.5, "road")
    print("nodes = " .. g:nodeCount())
    print("edges = " .. g:edgeCount())
end

--@api-stub: LPatternGraph:nodeCount
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("A")
    local b = g:addNode("B")
    g:addEdge(a, b, 1.0, "road")
    print("nodes = " .. g:nodeCount())
    print("edges = " .. g:edgeCount())
end

--@api-stub: LPatternGraph:edgeCount
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("A")
    local b = g:addNode("B")
    g:addEdge(a, b, 1.0, "road")
    print("nodes = " .. g:nodeCount())
    print("edges = " .. g:edgeCount())
end

--@api-stub: LPatternGraph:bfs
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("start")
    local b = g:addNode("mid")
    local c = g:addNode("end")
    g:addEdge(a, b)
    g:addEdge(b, c)
    local order = g:bfs(a)
    print("bfs = " .. #order)
    print("connected = " .. tostring(g:isConnected(a, c)))
end

--@api-stub: LPatternGraph:dfs
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("start")
    local b = g:addNode("mid")
    local c = g:addNode("end")
    g:addEdge(a, b)
    g:addEdge(b, c)
    local order = g:dfs(a)
    print("dfs = " .. #order)
    print("connected = " .. tostring(g:isConnected(a, c)))
end

--@api-stub: LPatternGraph:isConnected
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("start")
    local b = g:addNode("mid")
    local c = g:addNode("end")
    g:addEdge(a, b)
    g:addEdge(b, c)
    print("start to end = " .. tostring(g:isConnected(a, c)))
    print("start to start = " .. tostring(g:isConnected(a, a)))
end

--@api-stub: LPatternGraph:neighbors
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("start")
    local b = g:addNode("mid")
    local c = g:addNode("end")
    g:addEdge(a, b)
    g:addEdge(b, c)
    local neighbors = g:neighbors(b)
    print("neighbors = " .. #neighbors)
    print("has b = " .. tostring(g:hasNode(b)))
end

--@api-stub: LPatternGraph:hasNode
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("start")
    local b = g:addNode("mid")
    g:addEdge(a, b)
    print("has a = " .. tostring(g:hasNode(a)))
    print("has 99 = " .. tostring(g:hasNode(99)))
end

--@api-stub: LPatternGraph:getNodeValue
do
    local g = lurek.patterns.newGraph()
    local a = g:addNode("room", {size = 10})
    local b = g:addNode("hall")
    local edge = g:addEdge(a, b, 2.0, "door")
    local value = g:getNodeValue(a)
    print("room size = " .. tostring(value and value.size))
    print("edges = " .. g:edgeCount())
end

--@api-stub: LPatternGraph:removeNode
do
    local g = lurek.patterns.newGraph()
    local a = g:addNode("room", {size = 10})
    local b = g:addNode("hall")
    g:addEdge(a, b, 2.0, "door")
    g:removeNode(b)
    print("nodes = " .. g:nodeCount())
    print("has hall = " .. tostring(g:hasNode(b)))
end

--@api-stub: LPatternGraph:removeEdge
do
    local g = lurek.patterns.newGraph()
    local a = g:addNode("room")
    local b = g:addNode("hall")
    local edge = g:addEdge(a, b, 2.0, "door")
    g:removeEdge(edge)
    print("edges = " .. g:edgeCount())
    print("nodes = " .. g:nodeCount())
end

--@api-stub: LPatternGraph:clearAll
do
    local g = lurek.patterns.newGraph()
    local a = g:addNode("room")
    local b = g:addNode("hall")
    g:addEdge(a, b, 2.0, "door")
    print("before = " .. g:nodeCount())
    g:clearAll()
    print("after = " .. g:nodeCount())
end

--@api-stub: lurek.patterns.newList
do
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    print("len = " .. list:len())
    print("second = " .. tostring(list:get(2)))
end

--@api-stub: LList:add
do
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    print("len = " .. list:len())
    print("second = " .. tostring(list:get(2)))
end

--@api-stub: LList:get
do
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    print("second = " .. tostring(list:get(2)))
    print("len = " .. list:len())
end

--@api-stub: LList:len
do
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    print("len = " .. list:len())
    print("beta = " .. tostring(list:indexOf("beta")))
end

--@api-stub: LList:remove
do
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    local removed = list:remove(2)
    print("removed = " .. tostring(removed))
    print("len = " .. list:len())
end

--@api-stub: LList:indexOf
do
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    print("beta = " .. tostring(list:indexOf("beta")))
    print("delta = " .. tostring(list:indexOf("delta")))
end

--@api-stub: LList:push
do
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    print("len = " .. list:len())
    print("last = " .. tostring(list:get(3)))
end

--@api-stub: LList:pop
do
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    local popped = list:pop()
    print("popped = " .. tostring(popped))
    print("len = " .. list:len())
end

--@api-stub: LList:insert
do
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("c")
    list:insert(2, "b")
    print("second = " .. tostring(list:get(2)))
    print("len = " .. list:len())
end

--@api-stub: LList:set
do
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:set(2, "B")
    print("second = " .. tostring(list:get(2)))
    print("len = " .. list:len())
end

--@api-stub: LList:shift
do
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    local shifted = list:shift()
    print("shifted = " .. tostring(shifted))
    print("len = " .. list:len())
end

--@api-stub: LList:unshift
do
    local list = lurek.patterns.newList()
    list:push("b")
    list:push("c")
    list:unshift("a")
    print("first = " .. tostring(list:get(1)))
    print("len = " .. list:len())
end

--@api-stub: LList:contains
do
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    print("contains b = " .. tostring(list:contains("b")))
    print("contains z = " .. tostring(list:contains("z")))
end

--@api-stub: LList:reverse
do
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    list:reverse()
    print("first = " .. tostring(list:get(1)))
    print("last = " .. tostring(list:get(3)))
end

--@api-stub: LList:toArray
do
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    local arr = list:toArray()
    print("array = " .. #arr)
    print("first = " .. tostring(arr[1]))
end

--@api-stub: LList:isEmpty
do
    local list = lurek.patterns.newList()
    print("empty = " .. tostring(list:isEmpty()))
    list:push("a")
    print("after push = " .. tostring(list:isEmpty()))
end

--@api-stub: lurek.patterns.newMap
do
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    print("name = " .. tostring(map:get("name")))
    print("len = " .. map:len())
end

--@api-stub: LMap:set
do
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    print("name = " .. tostring(map:get("name")))
    print("len = " .. map:len())
end

--@api-stub: LMap:get
do
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    print("name = " .. tostring(map:get("name")))
    print("has level = " .. tostring(map:has("level")))
end

--@api-stub: LMap:has
do
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    print("has level = " .. tostring(map:has("level")))
    print("has class = " .. tostring(map:has("class")))
end

--@api-stub: LMap:remove
do
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("class", "warrior")
    map:remove("class")
    print("has class = " .. tostring(map:has("class")))
    print("len = " .. map:len())
end

--@api-stub: LMap:keys
do
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    local keys = map:keys()
    print("keys = " .. #keys)
    print("first = " .. tostring(keys[1]))
end

--@api-stub: LMap:values
do
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    local values = map:values()
    print("values = " .. #values)
    print("first = " .. tostring(values[1]))
end

--@api-stub: LMap:len
do
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    print("len = " .. map:len())
    print("has name = " .. tostring(map:has("name")))
end

--@api-stub: LMap:entries
do
    local map = lurek.patterns.newMap()
    map:set("a", 1)
    map:set("b", 2)
    local entries = map:entries()
    print("entries = " .. #entries)
    print("len = " .. map:len())
end

--@api-stub: LMap:merge
do
    local m1 = lurek.patterns.newMap()
    local m2 = lurek.patterns.newMap()
    m1:set("a", 1)
    m2:set("b", 2)
    m1:merge(m2)
    print("len = " .. m1:len())
    print("b = " .. tostring(m1:get("b")))
end

--@api-stub: LMap:isEmpty
do
    local map = lurek.patterns.newMap()
    print("empty = " .. tostring(map:isEmpty()))
    map:set("a", 1)
    print("after set = " .. tostring(map:isEmpty()))
end

--@api-stub: LMap:clear
do
    local map = lurek.patterns.newMap()
    map:set("a", 1)
    map:set("b", 2)
    print("before = " .. map:len())
    map:clear()
    print("after = " .. map:len())
end

--@api-stub: lurek.patterns.newSet
do
    local set = lurek.patterns.newSet()
    set:add("fire")
    set:add("ice")
    print("len = " .. set:len())
    print("has fire = " .. tostring(set:has("fire")))
end

--@api-stub: LSet:add
do
    local set = lurek.patterns.newSet()
    set:add("fire")
    set:add("ice")
    print("len = " .. set:len())
    print("has fire = " .. tostring(set:has("fire")))
end

--@api-stub: LSet:has
do
    local set = lurek.patterns.newSet()
    set:add("fire")
    set:add("ice")
    print("has fire = " .. tostring(set:has("fire")))
    print("has wind = " .. tostring(set:has("wind")))
end

--@api-stub: LSet:remove
do
    local set = lurek.patterns.newSet()
    set:add("fire")
    set:add("ice")
    set:remove("ice")
    print("has ice = " .. tostring(set:has("ice")))
    print("len = " .. set:len())
end

--@api-stub: LSet:len
do
    local set = lurek.patterns.newSet()
    set:add("fire")
    set:add("ice")
    set:add("wind")
    print("len = " .. set:len())
    print("has fire = " .. tostring(set:has("fire")))
end

--@api-stub: LSet:toArray
do
    local set = lurek.patterns.newSet()
    set:add("fire")
    set:add("ice")
    local arr = set:toArray()
    print("array = " .. #arr)
    print("len = " .. set:len())
end

--@api-stub: LSet:union
do
    local a = lurek.patterns.newSet()
    local b = lurek.patterns.newSet()
    a:add("x")
    a:add("y")
    b:add("y")
    b:add("z")
    local union = a:union(b)
    print("union = " .. union:len())
    print("intersection = " .. a:intersection(b):len())
end

--@api-stub: LSet:intersection
do
    local a = lurek.patterns.newSet()
    local b = lurek.patterns.newSet()
    a:add("x")
    a:add("y")
    b:add("y")
    b:add("z")
    local inter = a:intersection(b)
    print("intersection = " .. inter:len())
    print("union = " .. a:union(b):len())
end

--@api-stub: LSet:isEmpty
do
    local set = lurek.patterns.newSet()
    print("empty = " .. tostring(set:isEmpty()))
    set:add("x")
    print("after add = " .. tostring(set:isEmpty()))
end

--@api-stub: LSet:clear
do
    local set = lurek.patterns.newSet()
    set:add("x")
    set:add("y")
    print("before = " .. set:len())
    set:clear()
    print("after = " .. set:len())
end

--@api-stub: lurek.patterns.newStack
do
    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    print("peek = " .. tostring(st:peek()))
    print("len = " .. st:len())
end

--@api-stub: LStack:push
do
    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    print("peek = " .. tostring(st:peek()))
    print("len = " .. st:len())
end

--@api-stub: LStack:pop
do
    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    local value = st:pop()
    print("popped = " .. tostring(value))
    print("len = " .. st:len())
end

--@api-stub: LStack:peek
do
    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    print("peek = " .. tostring(st:peek()))
    print("len = " .. st:len())
end

--@api-stub: LStack:len
do
    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    print("len = " .. st:len())
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:isEmpty
do
    local st = lurek.patterns.newStack(100)
    print("empty = " .. tostring(st:isEmpty()))
    st:push("first")
    print("after push = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:pushBottom
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:pushBottom("z")
    print("bottom = " .. tostring(st:peekBottom()))
    print("len = " .. st:len())
end

--@api-stub: LStack:popBottom
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:pushBottom("z")
    local value = st:popBottom()
    print("bottom = " .. tostring(value))
    print("len = " .. st:len())
end

--@api-stub: LStack:peekBottom
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:pushBottom("z")
    print("bottom = " .. tostring(st:peekBottom()))
    print("len = " .. st:len())
end

--@api-stub: LStack:peekAt
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    print("at 2 = " .. tostring(st:peekAt(2)))
    print("len = " .. st:len())
end

--@api-stub: LStack:insertAt
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("c")
    st:insertAt(2, "b")
    print("at 2 = " .. tostring(st:peekAt(2)))
    print("len = " .. st:len())
end

--@api-stub: LStack:removeAt
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    local value = st:removeAt(2)
    print("removed = " .. tostring(value))
    print("len = " .. st:len())
end

--@api-stub: LStack:popMany
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    local values = st:popMany(2)
    print("count = " .. #values)
    print("len = " .. st:len())
end

--@api-stub: LStack:moveWithin
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    st:moveWithin(1, 3)
    local arr = st:toArray()
    print("first = " .. tostring(arr[1]))
    print("last = " .. tostring(arr[#arr]))
end

--@api-stub: LStack:isFull
do
    local st = lurek.patterns.newStack(2)
    st:push("a")
    st:push("b")
    print("full = " .. tostring(st:isFull()))
    print("len = " .. st:len())
end

--@api-stub: LStack:clear
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    print("before = " .. st:len())
    st:clear()
    print("after = " .. st:len())
end

--@api-stub: LStack:toArray
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    local arr = st:toArray()
    print("array = " .. #arr)
    print("first = " .. tostring(arr[1]))
end

--@api-stub: lurek.patterns.newQueue
do
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    print("front = " .. tostring(q:front()))
    print("len = " .. q:len())
end

--@api-stub: LQueue:enqueue
do
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    print("front = " .. tostring(q:front()))
    print("len = " .. q:len())
end

--@api-stub: LQueue:dequeue
do
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    local value = q:dequeue()
    print("dequeued = " .. tostring(value))
    print("len = " .. q:len())
end

--@api-stub: LQueue:front
do
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    print("front = " .. tostring(q:front()))
    print("back = " .. tostring(q:back()))
end

--@api-stub: LQueue:back
do
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    print("back = " .. tostring(q:back()))
    print("len = " .. q:len())
end

--@api-stub: LQueue:len
do
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    print("len = " .. q:len())
    print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:isEmpty
do
    local q = lurek.patterns.newQueue(10)
    print("empty = " .. tostring(q:isEmpty()))
    q:enqueue("msg1")
    print("after enqueue = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:enqueueFront
do
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueueFront("priority")
    print("front = " .. tostring(q:front()))
    print("len = " .. q:len())
end

--@api-stub: LQueue:dequeueBack
do
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    local value = q:dequeueBack()
    print("dequeued back = " .. tostring(value))
    print("len = " .. q:len())
end

--@api-stub: LQueue:insertAt
do
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("c")
    q:insertAt(2, "b")
    print("at 2 = " .. tostring(q:peekAt(2)))
    print("len = " .. q:len())
end

--@api-stub: LQueue:removeAt
do
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    local value = q:removeAt(2)
    print("removed = " .. tostring(value))
    print("len = " .. q:len())
end

--@api-stub: LQueue:peekAt
do
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    print("at 2 = " .. tostring(q:peekAt(2)))
    print("len = " .. q:len())
end

--@api-stub: LQueue:isFull
do
    local q = lurek.patterns.newQueue(2)
    q:enqueue("a")
    q:enqueue("b")
    print("full = " .. tostring(q:isFull()))
    print("len = " .. q:len())
end

--@api-stub: LQueue:clear
do
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    print("before = " .. q:len())
    q:clear()
    print("after = " .. q:len())
end

--@api-stub: LQueue:toArray
do
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    local arr = q:toArray()
    print("array = " .. #arr)
    print("first = " .. tostring(arr[1]))
end

--@api-stub: lurek.patterns.newPriorityQueue
do
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    print("peek = " .. tostring(pq:peek()))
    print("len = " .. pq:len())
end

--@api-stub: LPriorityQueue:push
do
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    print("peek = " .. tostring(pq:peek()))
    print("len = " .. pq:len())
end

--@api-stub: LPriorityQueue:pop
do
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    local value = pq:pop()
    print("popped = " .. tostring(value))
    print("len = " .. pq:len())
end

--@api-stub: LPriorityQueue:peek
do
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    print("peek = " .. tostring(pq:peek()))
    print("len = " .. pq:len())
end

--@api-stub: LPriorityQueue:len
do
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    print("len = " .. pq:len())
    print("empty = " .. tostring(pq:isEmpty()))
end

--@api-stub: LPriorityQueue:isEmpty
do
    local pq = lurek.patterns.newPriorityQueue("tasks")
    print("empty = " .. tostring(pq:isEmpty()))
    pq:push(10, "high_task", "high")
    print("after push = " .. tostring(pq:isEmpty()))
end

--@api-stub: LPriorityQueue:clearAll
do
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    print("before = " .. pq:len())
    pq:clearAll()
    print("after = " .. pq:len())
end

--@api-stub: lurek.patterns.newRing
do
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    print("len = " .. ring:len())
    print("average = " .. ring:average())
end

--@api-stub: LRing:push
do
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    print("len = " .. ring:len())
    print("sum = " .. ring:sum())
end

--@api-stub: LRing:len
do
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    print("len = " .. ring:len())
    print("full = " .. tostring(ring:isFull()))
end

--@api-stub: LRing:latest
do
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    local entry = ring:latest()
    print("latest = " .. tostring(entry and entry.value))
    print("len = " .. ring:len())
end

--@api-stub: LRing:isFull
do
    local ring = lurek.patterns.newRing(3, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    print("full = " .. tostring(ring:isFull()))
    print("len = " .. ring:len())
end

--@api-stub: LRing:sum
do
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    print("sum = " .. ring:sum())
    print("len = " .. ring:len())
end

--@api-stub: LRing:average
do
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    print("average = " .. ring:average())
    print("len = " .. ring:len())
end

--@api-stub: LRing:toArray
do
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    local arr = ring:toArray()
    print("array = " .. #arr)
    print("latest = " .. tostring(ring:latest() and ring:latest().value))
end

--@api-stub: LRing:clear
do
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    print("before = " .. ring:len())
    ring:clear()
    print("after = " .. ring:len())
end

--@api-stub: lurek.patterns.newWeightedRandom
do
    local wr = lurek.patterns.newWeightedRandom()
    wr:add(10, "common", "common_loot")
    wr:add(3, "rare", "rare_loot")
    print("items = " .. wr:len())
    print("picked = " .. tostring(wr:pick(0.5)))
end

--@api-stub: LWeightedRandom:add
do
    local wr = lurek.patterns.newWeightedRandom()
    wr:add(10, "common", "common_loot")
    wr:add(3, "rare", "rare_loot")
    print("items = " .. wr:len())
    print("total = " .. wr:totalWeight())
end

--@api-stub: LWeightedRandom:pick
do
    local wr = lurek.patterns.newWeightedRandom()
    wr:add(10, "common", "common_loot")
    wr:add(3, "rare", "rare_loot")
    print("picked = " .. tostring(wr:pick(0.5)))
    print("items = " .. wr:len())
end

--@api-stub: LWeightedRandom:pickN
do
    local wr = lurek.patterns.newWeightedRandom()
    wr:add(10, "common", "common_loot")
    wr:add(3, "rare", "rare_loot")
    wr:add(1, "legendary", "legendary_loot")
    local values = wr:pickN(2, {0.1, 0.9})
    print("count = " .. #values)
    print("items = " .. wr:len())
end

--@api-stub: LWeightedRandom:len
do
    local wr = lurek.patterns.newWeightedRandom()
    wr:add(10, "common", "common_loot")
    wr:add(3, "rare", "rare_loot")
    print("items = " .. wr:len())
    print("total = " .. wr:totalWeight())
end

--@api-stub: LWeightedRandom:totalWeight
do
    local wr = lurek.patterns.newWeightedRandom()
    wr:add(10, "common", "common_loot")
    wr:add(3, "rare", "rare_loot")
    print("total = " .. wr:totalWeight())
    print("items = " .. wr:len())
end

--@api-stub: LWeightedRandom:remove
do
    local wr = lurek.patterns.newWeightedRandom()
    local id = wr:add(5, "item_a")
    wr:add(5, "item_b")
    wr:remove(id)
    print("items = " .. wr:len())
    print("revision = " .. wr:getRevision())
end

--@api-stub: LWeightedRandom:setWeight
do
    local wr = lurek.patterns.newWeightedRandom()
    local id = wr:add(5, "item_a")
    wr:add(5, "item_b")
    wr:setWeight(id, 20)
    print("total = " .. wr:totalWeight())
    print("revision = " .. wr:getRevision())
end

--@api-stub: LWeightedRandom:getRevision
do
    local wr = lurek.patterns.newWeightedRandom()
    local id = wr:add(5, "item_a")
    wr:setWeight(id, 20)
    print("revision = " .. wr:getRevision())
    print("items = " .. wr:len())
end

--@api-stub: LWeightedRandom:isEmpty
do
    local wr = lurek.patterns.newWeightedRandom()
    print("empty = " .. tostring(wr:isEmpty()))
    wr:add(5, "item_a")
    print("after add = " .. tostring(wr:isEmpty()))
end

--@api-stub: LWeightedRandom:clearAll
do
    local wr = lurek.patterns.newWeightedRandom()
    wr:add(5, "item_a")
    wr:add(5, "item_b")
    print("before = " .. wr:len())
    wr:clearAll()
    print("after = " .. wr:len())
end

--@api-stub: lurek.patterns.newRelationshipManager
do
    local rm = lurek.patterns.newRelationshipManager()
    rm:setValue(1, 2, 50)
    rm:setValue(1, 3, -20)
    print("1->2 = " .. rm:getValue(1, 2))
    print("1->3 = " .. rm:getValue(1, 3))
end

--@api-stub: LRelationshipManager:setValue
do
    local rm = lurek.patterns.newRelationshipManager()
    rm:setValue(1, 2, 50)
    rm:setValue(1, 3, -20)
    print("1->2 = " .. rm:getValue(1, 2))
    print("1->3 = " .. rm:getValue(1, 3))
end

--@api-stub: LRelationshipManager:getValue
do
    local rm = lurek.patterns.newRelationshipManager()
    rm:setValue(1, 2, 50)
    rm:setValue(1, 3, -20)
    print("1->2 = " .. rm:getValue(1, 2))
    print("1->3 = " .. rm:getValue(1, 3))
end

--@api-stub: LRelationshipManager:adjustValue
do
    local rm = lurek.patterns.newRelationshipManager()
    rm:setValue(1, 2, 50)
    rm:adjustValue(1, 2, 10)
    print("1->2 = " .. rm:getValue(1, 2))
    print("pairs = " .. rm:pairCount())
end

--@api-stub: LRelationshipManager:defineType
do
    local rm = lurek.patterns.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
    rm:setLevel(1, 2, "friendship", "friendly")
    print("level = " .. tostring(rm:getLevel(1, 2, "friendship")))
    print("types = " .. #rm:typeNames())
end

--@api-stub: LRelationshipManager:setLevel
do
    local rm = lurek.patterns.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
    rm:setLevel(1, 2, "friendship", "friendly")
    print("level = " .. tostring(rm:getLevel(1, 2, "friendship")))
    print("pairs = " .. rm:pairCount())
end

--@api-stub: LRelationshipManager:getLevel
do
    local rm = lurek.patterns.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
    rm:setLevel(1, 2, "friendship", "friendly")
    print("level = " .. tostring(rm:getLevel(1, 2, "friendship")))
    print("types = " .. #rm:typeNames())
end

--@api-stub: LRelationshipManager:typeNames
do
    local rm = lurek.patterns.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
    rm:defineType("trust", {"low", "medium", "high"}, "medium")
    local types = rm:typeNames()
    print("types = " .. #types)
    print("first = " .. tostring(types[1]))
end

--@api-stub: LRelationshipManager:pairCount
do
    local rm = lurek.patterns.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
    rm:setLevel(1, 2, "friendship", "friendly")
    rm:setLevel(1, 3, "friendship", "hostile")
    print("pairs = " .. rm:pairCount())
    print("level = " .. tostring(rm:getLevel(1, 2, "friendship")))
end

--@api-stub: LRelationshipManager:removePair
do
    local rm = lurek.patterns.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
    rm:setLevel(1, 2, "friendship", "friendly")
    rm:setLevel(1, 3, "friendship", "hostile")
    print("before = " .. rm:pairCount())
    rm:removePair(1, 3)
    print("after = " .. rm:pairCount())
end

--@api-stub: LRelationshipManager:removeType
do
    local rm = lurek.patterns.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
    rm:defineType("trust", {"low", "medium", "high"}, "medium")
    print("before = " .. #rm:typeNames())
    rm:removeType("friendship")
    print("after = " .. #rm:typeNames())
end

--- Patterns Module Part 5: integrated multi-pattern examples, real-world scenarios

--@api-stub: LObjectPool:acquire
do
    local factory = lurek.patterns.newFactory()
    factory:register("bullet", function(speed)
        return {speed = speed or 300, active = false}
    end)
    local pool = lurek.patterns.newObjectPool()
    pool:add(factory:create("bullet", 400))
    local bullet = pool:acquire()
    print("bullet speed = " .. tostring(bullet and bullet.speed))
    print("active = " .. pool:getActiveCount())
end

--@api-stub: LPatternGraph:nodeCount
do
    local graph = lurek.patterns.newGraph(true)
    local a = graph:addNode("core")
    local b = graph:addNode("physics")
    graph:addEdge(a, b)
    print("nodes = " .. graph:nodeCount())
    print("edges = " .. graph:edgeCount())
end

--@api-stub: LPatternGraph:bfs
do
    local graph = lurek.patterns.newGraph(true)
    local start = graph:addNode("core")
    local physics = graph:addNode("physics")
    graph:addEdge(start, physics)
    local order = graph:bfs(start)
    print("bfs count = " .. #order)
    print("connected = " .. tostring(graph:isConnected(start, physics)))
end

--- Patterns Module Part 5: BehaviorTree (addChild/nodeCount/setRoot), LList:clear, LObjectPool counts, LSimpleState:update, LStrategy:getCurrent

--@api-stub: LBehaviorTree:addChild
do
    local bt = lurek.patterns.newBehaviorTree()
    local seq = bt:addSequence("root_seq")
    local check = bt:addLeaf("check")
    local act = bt:addLeaf("act")
    bt:addChild(seq, check)
    bt:addChild(seq, act)
    bt:setLeaf("check", function()
        return "success"
    end)
    bt:setLeaf("act", function()
        return "success"
    end)
    bt:setRoot(seq)
    print("result = " .. bt:tick())
    print("node_count = " .. bt:nodeCount())
end

--@api-stub: LBehaviorTree:nodeCount
do
    local bt = lurek.patterns.newBehaviorTree()
    local seq = bt:addSequence("root_seq")
    local check = bt:addLeaf("check")
    local act = bt:addLeaf("act")
    bt:addChild(seq, check)
    bt:addChild(seq, act)
    bt:setLeaf("check", function()
        return "success"
    end)
    bt:setLeaf("act", function()
        return "success"
    end)
    bt:setRoot(seq)
    print("node_count = " .. bt:nodeCount())
    print("result = " .. bt:tick())
end

--@api-stub: LBehaviorTree:setRoot
do
    local bt = lurek.patterns.newBehaviorTree()
    local seq = bt:addSequence("root_seq")
    local check = bt:addLeaf("check")
    local act = bt:addLeaf("act")
    bt:addChild(seq, check)
    bt:addChild(seq, act)
    bt:setLeaf("check", function()
        return "success"
    end)
    bt:setLeaf("act", function()
        return "success"
    end)
    bt:setRoot(seq)
    print("node_count = " .. bt:nodeCount())
    print("result = " .. bt:tick())
end

--@api-stub: LList:clear
do
    local list = lurek.patterns.newList()
    list:add(1)
    list:add(2)
    list:add(3)
    print("before = " .. list:len())
    list:clear()
    print("after = " .. list:len())
end

--@api-stub: LObjectPool:getActiveCount
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1})
    pool:add({id = 2})
    local obj = pool:acquire()
    print("active = " .. pool:getActiveCount())
    print("got = " .. tostring(obj and obj.id))
end

--@api-stub: LObjectPool:getAvailableCount
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1})
    pool:add({id = 2})
    pool:acquire()
    print("available = " .. pool:getAvailableCount())
    print("total = " .. pool:getTotalCount())
end

--@api-stub: LObjectPool:getTotalCount
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1})
    pool:add({id = 2})
    print("total = " .. pool:getTotalCount())
    print("available = " .. pool:getAvailableCount())
end

--@api-stub: LSimpleState:update
do
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("idle", {
        update = function(dt)
            print("tick idle = " .. dt)
        end
    })
    fsm:transitionTo("idle")
    fsm:update(0.016)
    print("current = " .. tostring(fsm:getCurrent()))
end

--@api-stub: LStrategy:getCurrent
do
    local strat = lurek.patterns.newStrategy()
    strat:register("attack", function()
        return "attacking"
    end)
    strat:register("flee", function()
        return "fleeing"
    end)
    strat:set("attack")
    print("current = " .. tostring(strat:getCurrent()))
    print("result = " .. tostring(strat:execute()))
end

--@api-stub: LBehaviorTree:setRoot
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root_seq")
    local act = bt:addLeaf("act")
    bt:addChild(root, act)
    bt:setLeaf("act", function()
        return "success"
    end)
    bt:setRoot(root)
    print("result = " .. bt:tick())
    print("type = " .. bt:type())
end