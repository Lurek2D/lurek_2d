-- content/examples/patterns.lua
-- Auto-generated from content/examples2/patterns_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/patterns.lua




--- Patterns Module Part 1: service locator, object pool, factory, strategy


--@api: lurek.patterns.newServiceLocator
do
    local patterns_last_state_dt = 0

    local services = lurek.patterns.newServiceLocator()
    services:provide("audio", {volume = 0.8, muted = false})
    services:provide("input", {keyboard = true, mouse = true})
    local audio = services:locate("audio")
    local service_count = #services:getServices()
    lurek.log.info("service locator ready has_audio=" .. tostring(services:has("audio")) .. " service_count=" .. tostring(service_count) .. " audio_volume=" .. tostring(audio and audio.volume))
end

--@api: LServiceLocator:provide
do
    local patterns_last_state_dt = 0

    local services = lurek.patterns.newServiceLocator()
    services:provide("renderer", {backend = "wgpu", vsync = true})
    services:provide("ui", {scale = 1.25})
    local renderer = services:locate("renderer")
    local service_count = #services:getServices()
    lurek.log.info("renderer service backend=" .. tostring(renderer and renderer.backend) .. " vsync=" .. tostring(renderer and renderer.vsync) .. " service_count=" .. tostring(service_count))
end

--@api: LServiceLocator:locate
do
    local patterns_last_state_dt = 0

    local services = lurek.patterns.newServiceLocator()
    services:provide("audio", {volume = 0.8, muted = false})
    local audio = services:locate("audio")
    lurek.log.info("audio volume = " .. tostring(audio and audio.volume))
    lurek.log.info("has audio = " .. tostring(services:has("audio")))
end

--@api: LServiceLocator:has
do
    local patterns_last_state_dt = 0

    local services = lurek.patterns.newServiceLocator()
    services:provide("input", {keyboard = true, gamepad = true})
    local has_input = services:has("input")
    local has_physics = services:has("physics")
    local input = services:locate("input")
    local service_count = #services:getServices()
    lurek.log.info("service presence input=" .. tostring(has_input) .. " physics=" .. tostring(has_physics) .. " gamepad=" .. tostring(input and input.gamepad) .. " service_count=" .. tostring(service_count))
end

--@api: LServiceLocator:getServices
do
    local patterns_last_state_dt = 0

    local services = lurek.patterns.newServiceLocator()
    services:provide("renderer", {backend = "wgpu"})
    services:provide("audio", {volume = 1.0})
    local names = services:getServices()
    lurek.log.info("services = " .. #names)
    lurek.log.info("first = " .. tostring(names[1]))
end

--@api: LServiceLocator:remove
do
    local patterns_last_state_dt = 0

    local services = lurek.patterns.newServiceLocator()
    services:provide("save", {slot = 1})
    services:remove("save")
    lurek.log.info("has save = " .. tostring(services:has("save")))
    lurek.log.info("services = " .. #services:getServices())
end

--@api: LServiceLocator:clearAll
do
    local patterns_last_state_dt = 0

    local services = lurek.patterns.newServiceLocator()
    services:provide("renderer", {backend = "wgpu"})
    services:provide("audio", {volume = 0.6})
    lurek.log.info("before = " .. #services:getServices())
    services:clearAll()
    lurek.log.info("after = " .. #services:getServices())
end

--@api: lurek.patterns.newObjectPool
do
    local patterns_last_state_dt = 0

    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1, active = false})
    pool:add({id = 2, active = false})
    local obj = pool:acquire()
    local active = pool:getActiveCount()
    local available = pool:getAvailableCount()
    lurek.log.info("object pool total=" .. tostring(pool:getTotalCount()) .. " active=" .. tostring(active) .. " available=" .. tostring(available) .. " acquired=" .. tostring(obj and obj.id))
end

--@api: LObjectPool:add
do
    local patterns_last_state_dt = 0

    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1, active = false})
    pool:add({id = 2, active = false})
    lurek.log.info("total = " .. pool:getTotalCount())
    lurek.log.info("available = " .. pool:getAvailableCount())
end

--@api: LObjectPool:acquire
do
    local patterns_last_state_dt = 0

    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1, active = false})
    pool:add({id = 2, active = false})
    local obj = pool:acquire()
    lurek.log.info("acquired = " .. tostring(obj and obj.id))
    lurek.log.info("active = " .. pool:getActiveCount())
end

--@api: LObjectPool:release
do
    local patterns_last_state_dt = 0

    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1, active = false})
    pool:add({id = 2, active = false})
    local obj = pool:acquire()
    pool:release(obj)
    lurek.log.info("active = " .. pool:getActiveCount())
    lurek.log.info("available = " .. pool:getAvailableCount())
end

--@api: LObjectPool:clearAll
do
    local patterns_last_state_dt = 0

    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1})
    pool:add({id = 2})
    lurek.log.info("before = " .. pool:getTotalCount())
    pool:clearAll()
    lurek.log.info("after = " .. pool:getTotalCount())
end

--@api: lurek.patterns.newFactory
do
    local patterns_last_state_dt = 0

    local factory = lurek.patterns.newFactory()
    factory:register("enemy", function(hp)
        return {type = "enemy", hp = hp or 100}
    end)
    local enemy = factory:create("enemy", 120)
    lurek.log.info("enemy hp = " .. tostring(enemy and enemy.hp))
    lurek.log.info("types = " .. #factory:getTypes())
end

--@api: LFactory:register
do
    local patterns_last_state_dt = 0

    local factory = lurek.patterns.newFactory()
    factory:register("enemy", function(hp)
        return {type = "enemy", hp = hp or 100}
    end)
    lurek.log.info("has enemy = " .. tostring(factory:has("enemy")))
    lurek.log.info("types = " .. #factory:getTypes())
end

--@api: LFactory:has
do
    local patterns_last_state_dt = 0

    local factory = lurek.patterns.newFactory()
    factory:register("bullet", function(speed)
        return {type = "bullet", speed = speed or 300}
    end)
    lurek.log.info("has bullet = " .. tostring(factory:has("bullet")))
    lurek.log.info("has enemy = " .. tostring(factory:has("enemy")))
end

--@api: LFactory:create
do
    local patterns_last_state_dt = 0

    local factory = lurek.patterns.newFactory()
    factory:register("bullet", function(speed)
        return {type = "bullet", speed = speed or 300}
    end)
    local bullet = factory:create("bullet", 450)
    lurek.log.info("bullet speed = " .. tostring(bullet and bullet.speed))
    lurek.log.info("types = " .. #factory:getTypes())
end

--@api: LFactory:getTypes
do
    local patterns_last_state_dt = 0

    local factory = lurek.patterns.newFactory()
    factory:register("enemy", function()
        return {type = "enemy"}
    end)
    factory:register("bullet", function()
        return {type = "bullet"}
    end)
    local types = factory:getTypes()
    lurek.log.info("types = " .. #types)
    lurek.log.info("has enemy = " .. tostring(factory:has("enemy")))
end

--@api: LFactory:alias
do
    local patterns_last_state_dt = 0

    local factory = lurek.patterns.newFactory()
    factory:register("goblin", function()
        return {type = "goblin", hp = 30}
    end)
    factory:alias("small_enemy", "goblin")
    local goblin = factory:create("small_enemy")
    lurek.log.info("alias type = " .. tostring(goblin and goblin.type))
    lurek.log.info("has alias target = " .. tostring(factory:has("small_enemy")))
end

--@api: LFactory:remove
do
    local patterns_last_state_dt = 0

    local factory = lurek.patterns.newFactory()
    factory:register("goblin", function()
        return {type = "goblin"}
    end)
    factory:remove("goblin")
    lurek.log.info("has goblin = " .. tostring(factory:has("goblin")))
    lurek.log.info("types = " .. #factory:getTypes())
end

--@api: LFactory:clearAll
do
    local patterns_last_state_dt = 0

    local factory = lurek.patterns.newFactory()
    factory:register("enemy", function()
        return {type = "enemy"}
    end)
    factory:register("bullet", function()
        return {type = "bullet"}
    end)
    lurek.log.info("before = " .. #factory:getTypes())
    factory:clearAll()
    lurek.log.info("after = " .. #factory:getTypes())
end

--@api: lurek.patterns.newStrategy
do
    local patterns_last_state_dt = 0

    local strat = lurek.patterns.newStrategy()
    strat:register("attack", function(target)
        return "attack " .. target
    end)
    strat:register("flee", function(target)
        return "flee from " .. target
    end)
    strat:set("attack")
    lurek.log.info("current = " .. tostring(strat:getCurrent()))
    lurek.log.info("result = " .. tostring(strat:execute("orc")))
end

--@api: LStrategy:register
do
    local patterns_last_state_dt = 0

    local strat = lurek.patterns.newStrategy()
    strat:register("attack", function(target)
        return "attack " .. target
    end)
    strat:register("flee", function(target)
        return "flee from " .. target
    end)
    lurek.log.info("has attack = " .. tostring(strat:has("attack")))
    lurek.log.info("names = " .. #strat:names())
end

--@api: LStrategy:set
do
    local patterns_last_state_dt = 0

    local strat = lurek.patterns.newStrategy()
    strat:register("attack", function(target)
        return "attack " .. target
    end)
    strat:register("flee", function(target)
        return "flee from " .. target
    end)
    strat:set("flee")
    lurek.log.info("current = " .. tostring(strat:getCurrent()))
    lurek.log.info("result = " .. tostring(strat:execute("dragon")))
end

--@api: LStrategy:execute
do
    local patterns_last_state_dt = 0

    local strat = lurek.patterns.newStrategy()
    strat:register("attack", function(target)
        return "attack " .. target
    end)
    strat:register("flee", function(target)
        return "flee from " .. target
    end)
    strat:set("attack")
    lurek.log.info("current = " .. tostring(strat:getCurrent()))
    lurek.log.info("result = " .. tostring(strat:execute("slime")))
end

--@api: LStrategy:has
do
    local patterns_last_state_dt = 0

    local strat = lurek.patterns.newStrategy()
    strat:register("fast", function()
        return "fast"
    end)
    strat:register("slow", function()
        return "slow"
    end)
    lurek.log.info("has fast = " .. tostring(strat:has("fast")))
    lurek.log.info("has medium = " .. tostring(strat:has("medium")))
end

--@api: LStrategy:names
do
    local patterns_last_state_dt = 0

    local strat = lurek.patterns.newStrategy()
    strat:register("fast", function()
        return "fast"
    end)
    strat:register("slow", function()
        return "slow"
    end)
    local names = strat:names()
    lurek.log.info("names = " .. #names)
    lurek.log.info("first = " .. tostring(names[1]))
end

--@api: LStrategy:remove
do
    local patterns_last_state_dt = 0

    local strat = lurek.patterns.newStrategy()
    strat:register("fast", function()
        return "fast"
    end)
    strat:register("slow", function()
        return "slow"
    end)
    strat:remove("slow")
    lurek.log.info("has slow = " .. tostring(strat:has("slow")))
    lurek.log.info("names = " .. #strat:names())
end

--@api: LStrategy:clear
do
    local patterns_last_state_dt = 0

    local strat = lurek.patterns.newStrategy()
    strat:register("fast", function()
        return "fast"
    end)
    strat:register("slow", function()
        return "slow"
    end)
    lurek.log.info("before = " .. #strat:names())
    strat:clear()
    lurek.log.info("after = " .. #strat:names())
end

--- Patterns Module Part 2: FSM, command stack, behavior tree, blackboard

--@api: lurek.patterns.newSimpleState
do
    local patterns_last_state_dt = 0

    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("idle", {
        enter = function()
            lurek.log.info("enter idle")
        end,
        update = function(dt)
            lurek.log.info("idle dt = " .. dt)
        end
    })
    fsm:transitionTo("idle")
    fsm:update(0.016)
    lurek.log.info("current = " .. tostring(fsm:getCurrent()))
end

--@api: LSimpleState:addState
do
    local patterns_last_state_dt = 0

    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("idle")
    fsm:addState("walk")
    fsm:addState("pause")
    local states = fsm:getStates()
    local has_walk = fsm:hasState("walk")
    local has_idle = fsm:hasState("idle")
    local has_pause = fsm:hasState("pause")
    fsm:transitionTo("walk")
    local current = fsm:getCurrent()
    lurek.log.info("simple states total=" .. tostring(#states) .. " has_walk=" .. tostring(has_walk) .. " has_idle=" .. tostring(has_idle) .. " has_pause=" .. tostring(has_pause) .. " current=" .. tostring(current))
end

--@api: LSimpleState:transitionTo
do
    local patterns_last_state_dt = 0

    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("idle")
    fsm:addState("walk")
    fsm:addState("pause")
    fsm:transitionTo("walk")
    local current = fsm:getCurrent()
    local states = fsm:getStates()
    local has_idle = fsm:hasState("idle")
    local has_walk = fsm:hasState("walk")
    local has_pause = fsm:hasState("pause")
    lurek.log.info("transition current=" .. tostring(current) .. " states=" .. tostring(#states) .. " has_idle=" .. tostring(has_idle) .. " has_walk=" .. tostring(has_walk) .. " has_pause=" .. tostring(has_pause))
end

--@api: LSimpleState:getCurrent
do
    local patterns_last_state_dt = 0

    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("idle")
    fsm:addState("pause")
    fsm:transitionTo("idle")
    local current = fsm:getCurrent()
    local states = fsm:getStates()
    local has_idle = fsm:hasState("idle")
    local has_menu = fsm:hasState("menu")
    local has_pause = fsm:hasState("pause")
    lurek.log.info("current state=" .. tostring(current) .. " states=" .. tostring(#states) .. " has_idle=" .. tostring(has_idle) .. " has_menu=" .. tostring(has_menu) .. " has_pause=" .. tostring(has_pause))
end

--@api: LSimpleState:hasState
do
    local patterns_last_state_dt = 0

    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("menu")
    fsm:addState("game")
    lurek.log.info("has menu = " .. tostring(fsm:hasState("menu")))
    lurek.log.info("has pause = " .. tostring(fsm:hasState("pause")))
end

--@api: LSimpleState:getStates
do
    local patterns_last_state_dt = 0

    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("menu")
    fsm:addState("game")
    fsm:addState("pause")
    lurek.log.info("states = " .. #fsm:getStates())
    lurek.log.info("has pause = " .. tostring(fsm:hasState("pause")))
end

--@api: LSimpleState:clearAll
do
    local patterns_last_state_dt = 0

    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("menu")
    fsm:addState("game")
    lurek.log.info("before = " .. #fsm:getStates())
    fsm:clearAll()
    lurek.log.info("after = " .. #fsm:getStates())
end

--@api: lurek.patterns.newCommandStack
do
    local patterns_last_state_dt = 0

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
    lurek.log.info("value = " .. value)
    lurek.log.info("history = " .. cmds:getHistorySize())
end

--@api: LCommandStack:execute
do
    local patterns_last_state_dt = 0

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
    lurek.log.info("value = " .. value)
    lurek.log.info("current = " .. tostring(cmds:getCurrentName()))
end

--@api: LCommandStack:undo
do
    local patterns_last_state_dt = 0

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
    lurek.log.info("value = " .. value)
    lurek.log.info("can redo = " .. tostring(cmds:canRedo()))
end

--@api: LCommandStack:redo
do
    local patterns_last_state_dt = 0

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
    lurek.log.info("value = " .. value)
    lurek.log.info("current = " .. tostring(cmds:getCurrentName()))
end

--@api: LCommandStack:canUndo
do
    local patterns_last_state_dt = 0

    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function()
    end, function()
    end)
    cmds:execute("step2", function()
    end, function()
    end)
    lurek.log.info("can undo = " .. tostring(cmds:canUndo()))
    lurek.log.info("history = " .. cmds:getHistorySize())
end

--@api: LCommandStack:canRedo
do
    local patterns_last_state_dt = 0

    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function()
    end, function()
    end)
    cmds:execute("step2", function()
    end, function()
    end)
    cmds:undo()
    lurek.log.info("can redo = " .. tostring(cmds:canRedo()))
    lurek.log.info("current = " .. tostring(cmds:getCurrentName()))
end

--@api: LCommandStack:getCurrentName
do
    local patterns_last_state_dt = 0

    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function()
    end, function()
    end)
    cmds:execute("step2", function()
    end, function()
    end)
    lurek.log.info("current = " .. tostring(cmds:getCurrentName()))
    lurek.log.info("history = " .. cmds:getHistorySize())
end

--@api: LCommandStack:getHistorySize
do
    local patterns_last_state_dt = 0

    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function()
    end, function()
    end)
    cmds:execute("step2", function()
    end, function()
    end)
    lurek.log.info("history = " .. cmds:getHistorySize())
    lurek.log.info("can undo = " .. tostring(cmds:canUndo()))
end

--@api: LCommandStack:clearAll
do
    local patterns_last_state_dt = 0

    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function()
    end, function()
    end)
    cmds:execute("step2", function()
    end, function()
    end)
    lurek.log.info("before = " .. cmds:getHistorySize())
    cmds:clearAll()
    lurek.log.info("after = " .. cmds:getHistorySize())
end

--@api: lurek.patterns.newBehaviorTree
do
    local patterns_last_state_dt = 0

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
    lurek.log.info("result = " .. bt:tick())
    lurek.log.info("nodes = " .. bt:nodeCount())
end

--@api: LBehaviorTree:addSequence
do
    local patterns_last_state_dt = 0

    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local check = bt:addLeaf("check")
    bt:addChild(root, check)
    bt:setLeaf("check", function()
        return "success"
    end)
    bt:setRoot(root)
    lurek.log.info("result = " .. bt:tick())
    lurek.log.info("nodes = " .. bt:nodeCount())
end

--@api: LBehaviorTree:addSelector
do
    local patterns_last_state_dt = 0

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
    lurek.log.info("result = " .. bt:tick())
    lurek.log.info("nodes = " .. bt:nodeCount())
end

--@api: LBehaviorTree:addLeaf
do
    local patterns_last_state_dt = 0

    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local act = bt:addLeaf("act")
    bt:addChild(root, act)
    bt:setLeaf("act", function()
        return "success"
    end)
    bt:setRoot(root)
    lurek.log.info("result = " .. bt:tick())
    lurek.log.info("nodes = " .. bt:nodeCount())
end

--@api: LBehaviorTree:setLeaf
do
    local patterns_last_state_dt = 0

    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local act = bt:addLeaf("act")
    bt:addChild(root, act)
    bt:setLeaf("act", function()
        lurek.log.info("leaf fired")
        return "success"
    end)
    bt:setRoot(root)
    lurek.log.info("result = " .. bt:tick())
    lurek.log.info("nodes = " .. bt:nodeCount())
end

--@api: LBehaviorTree:tick
do
    local patterns_last_state_dt = 0

    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local act = bt:addLeaf("act")
    bt:addChild(root, act)
    bt:setLeaf("act", function()
        return "success"
    end)
    bt:setRoot(root)
    lurek.log.info("result = " .. bt:tick())
    lurek.log.info("nodes = " .. bt:nodeCount())
end

--@api: LBehaviorTree:resetState
do
    local patterns_last_state_dt = 0

    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local act = bt:addLeaf("act")
    bt:addChild(root, act)
    bt:setLeaf("act", function()
        return "running"
    end)
    bt:setRoot(root)
    lurek.log.info("first = " .. bt:tick())
    bt:resetState()
    lurek.log.info("after reset = " .. bt:tick())
end

--@api: LBehaviorTree:addParallel
do
    local patterns_last_state_dt = 0

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
    lurek.log.info("result = " .. bt:tick())
    lurek.log.info("nodes = " .. bt:nodeCount())
end

--@api: LBehaviorTree:addInverter
do
    local patterns_last_state_dt = 0

    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addInverter("invert")
    local check = bt:addLeaf("check")
    bt:addChild(root, check)
    bt:setLeaf("check", function()
        return "failure"
    end)
    bt:setRoot(root)
    lurek.log.info("result = " .. bt:tick())
    lurek.log.info("nodes = " .. bt:nodeCount())
end

--@api: LBehaviorTree:addRepeat
do
    local patterns_last_state_dt = 0

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
    lurek.log.info("result = " .. bt:tick())
    lurek.log.info("calls = " .. calls)
end

--@api: LBehaviorTree:clearAll
do
    local patterns_last_state_dt = 0

    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSelector("root")
    local idle = bt:addLeaf("idle")
    bt:addChild(root, idle)
    bt:setRoot(root)
    lurek.log.info("before = " .. bt:nodeCount())
    bt:clearAll()
    lurek.log.info("after = " .. bt:nodeCount())
end

--@api: lurek.patterns.newBlackboard
do
    local patterns_last_state_dt = 0

    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("health", 100)
    bb:set("mode", "idle")
    lurek.log.info("health = " .. tostring(bb:get("health")))
    lurek.log.info("keys = " .. #bb:keys())
end

--@api: LBlackboard:set
do
    local patterns_last_state_dt = 0

    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("score", 10)
    bb:set("score", 20)
    lurek.log.info("score = " .. tostring(bb:get("score")))
    lurek.log.info("revision = " .. bb:getRevision())
end

--@api: LBlackboard:get
do
    local patterns_last_state_dt = 0

    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("weapon", "sword")
    bb:set("ammo", 12)
    local weapon = bb:get("weapon")
    local ammo = bb:get("ammo")
    local has_weapon = bb:has("weapon")
    lurek.log.info("blackboard weapon=" .. tostring(weapon) .. " ammo=" .. tostring(ammo) .. " has_weapon=" .. tostring(has_weapon))
end

--@api: LBlackboard:has
do
    local patterns_last_state_dt = 0

    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("alive", true)
    bb:set("stance", "guard")
    local has_alive = bb:has("alive")
    local has_mana = bb:has("mana")
    local stance = bb:get("stance")
    lurek.log.info("blackboard alive=" .. tostring(has_alive) .. " mana=" .. tostring(has_mana) .. " stance=" .. tostring(stance))
end

--@api: LBlackboard:keys
do
    local patterns_last_state_dt = 0

    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("health", 100)
    bb:set("weapon", "sword")
    local keys = bb:keys()
    lurek.log.info("keys = " .. #keys)
    lurek.log.info("first = " .. tostring(keys[1]))
end

--@api: LBlackboard:watch
do
    local patterns_last_state_dt = 0

    local bb = lurek.patterns.newBlackboard("game_state")
    local watch_id = bb:watch("score", function(key, value)
        lurek.log.info(key .. " = " .. tostring(value))
    end)
    bb:set("score", 10)
    bb:set("score", 25)
    lurek.log.info("revision = " .. bb:getRevision())
    bb:unwatch(watch_id)
end

--@api: LBlackboard:unwatch
do
    local patterns_last_state_dt = 0

    local bb = lurek.patterns.newBlackboard("game_state")
    local watch_id = bb:watch("score", function(key, value)
        lurek.log.info(key .. " = " .. tostring(value))
    end)
    bb:set("score", 10)
    bb:unwatch(watch_id)
    bb:set("score", 20)
    lurek.log.info("revision = " .. bb:getRevision())
end

--@api: LBlackboard:getRevision
do
    local patterns_last_state_dt = 0

    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("score", 10)
    bb:set("score", 20)
    lurek.log.info("revision = " .. bb:getRevision())
    lurek.log.info("score = " .. tostring(bb:get("score")))
end

--@api: LBlackboard:snapshot
do
    local patterns_last_state_dt = 0

    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("score", 42)
    bb:set("weapon", "sword")
    local snap = bb:snapshot()
    lurek.log.info("score = " .. tostring(snap.score))
    lurek.log.info("weapon = " .. tostring(snap.weapon))
end

--@api: LBlackboard:clear
do
    local patterns_last_state_dt = 0

    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("score", 42)
    lurek.log.info("before = " .. tostring(bb:has("score")))
    bb:clear("score")
    lurek.log.info("after = " .. tostring(bb:has("score")))
end

--@api: LBlackboard:clearAll
do
    local patterns_last_state_dt = 0

    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("score", 42)
    bb:set("weapon", "sword")
    lurek.log.info("before = " .. #bb:keys())
    bb:clearAll()
    lurek.log.info("after = " .. #bb:keys())
end

--- Patterns Module Part 3: observer, event bus, mediator, debounce, throttle, funnel

--@api: lurek.patterns.newObserver
do
    local patterns_last_state_dt = 0

    local obs = lurek.patterns.newObserver("player_stats")
    local id = obs:subscribe("hp", function(key, value)
        lurek.log.info(key .. " = " .. tostring(value))
    end)
    obs:set("hp", 100)
    lurek.log.info("hp = " .. tostring(obs:get("hp")))
    obs:unsubscribe(id)
end

--@api: LObserver:set
do
    local patterns_last_state_dt = 0

    local obs = lurek.patterns.newObserver("player_stats")
    local id = obs:subscribe("hp", function(key, value)
        lurek.log.info(key .. " = " .. tostring(value))
    end)
    obs:set("hp", 100)
    obs:set("hp", 75)
    lurek.log.info("hp = " .. tostring(obs:get("hp")))
    obs:unsubscribe(id)
end

--@api: LObserver:get
do
    local patterns_last_state_dt = 0

    local obs = lurek.patterns.newObserver("player_stats")
    obs:set("hp", 90)
    obs:set("armor", 12)
    local hp = obs:get("hp")
    local armor = obs:get("armor")
    local subs = obs:getCount()
    lurek.log.info("observer hp=" .. tostring(hp) .. " armor=" .. tostring(armor) .. " subscribers=" .. tostring(subs))
end

--@api: LObserver:subscribe
do
    local patterns_last_state_dt = 0

    local obs = lurek.patterns.newObserver("player_stats")
    local id = obs:subscribe("hp", function(key, value)
        lurek.log.info(key .. " = " .. tostring(value))
    end)
    obs:set("hp", 100)
    lurek.log.info("subs = " .. obs:getCount())
    obs:unsubscribe(id)
end

--@api: LObserver:unsubscribe
do
    local patterns_last_state_dt = 0

    local obs = lurek.patterns.newObserver("player_stats")
    local id = obs:subscribe("hp", function(key, value)
        lurek.log.info(key .. " = " .. tostring(value))
    end)
    obs:unsubscribe(id)
    obs:set("hp", 50)
    lurek.log.info("subs = " .. obs:getCount())
end

--@api: LObserver:getCount
do
    local patterns_last_state_dt = 0

    local obs = lurek.patterns.newObserver("player_stats")
    obs:subscribe("score", function(key, value)
        lurek.log.info(key .. " = " .. tostring(value))
    end, true)
    lurek.log.info("subs = " .. obs:getCount())
    obs:set("score", 100)
    lurek.log.info("after = " .. obs:getCount())
end

--@api: lurek.patterns.newEventBus
do
    local patterns_last_state_dt = 0

    local bus = lurek.patterns.newEventBus("game_events")
    local id = bus:on("damage", function(amount, source)
        lurek.log.info("damage = " .. tostring(amount) .. " from " .. tostring(source))
    end)
    bus:emit("damage", 25, "fire")
    lurek.log.info("listeners = " .. bus:getListenerCount("damage"))
    bus:off(id)
end

--@api: LEventBus:on
do
    local patterns_last_state_dt = 0

    local bus = lurek.patterns.newEventBus("game_events")
    local id = bus:on("damage", function(amount, source)
        lurek.log.info("damage = " .. tostring(amount) .. " from " .. tostring(source))
    end, 1)
    bus:emit("damage", 12, "ice")
    lurek.log.info("listeners = " .. bus:getListenerCount("damage"))
    bus:off(id)
end

--@api: LEventBus:emit
do
    local patterns_last_state_dt = 0

    local bus = lurek.patterns.newEventBus("game_events")
    local id = bus:on("damage", function(amount, source)
        lurek.log.info("damage = " .. tostring(amount) .. " from " .. tostring(source))
    end)
    bus:emit("damage", 18, "fire")
    lurek.log.info("events = " .. #bus:getEvents())
    bus:off(id)
end

--@api: LEventBus:off
do
    local patterns_last_state_dt = 0

    local bus = lurek.patterns.newEventBus("game_events")
    local id = bus:on("damage", function(amount)
        lurek.log.info("damage = " .. tostring(amount))
    end)
    bus:off(id)
    bus:emit("damage", 5)
    lurek.log.info("listeners = " .. bus:getListenerCount("damage"))
end

--@api: LEventBus:getListenerCount
do
    local patterns_last_state_dt = 0

    local bus = lurek.patterns.newEventBus("game_events")
    bus:on("spawn", function(id)
        lurek.log.info("spawn = " .. tostring(id))
    end)
    bus:on("spawn", function(id)
        lurek.log.info("spawn log = " .. tostring(id))
    end)
    lurek.log.info("spawn listeners = " .. bus:getListenerCount("spawn"))
    lurek.log.info("events = " .. #bus:getEvents())
end

--@api: LEventBus:getEvents
do
    local patterns_last_state_dt = 0

    local bus = lurek.patterns.newEventBus("game_events")
    bus:on("spawn", function(id)
        lurek.log.info("spawn = " .. tostring(id))
    end)
    bus:on("hit", function(amount)
        lurek.log.info("hit = " .. tostring(amount))
    end)
    local events = bus:getEvents()
    lurek.log.info("events = " .. #events)
    lurek.log.info("first = " .. tostring(events[1]))
end

--@api: LEventBus:clear
do
    local patterns_last_state_dt = 0

    local bus = lurek.patterns.newEventBus("game_events")
    bus:on("spawn", function(id)
        lurek.log.info("spawn = " .. tostring(id))
    end)
    lurek.log.info("before = " .. bus:getListenerCount("spawn"))
    bus:clear("spawn")
    lurek.log.info("after = " .. bus:getListenerCount("spawn"))
end

--@api: LEventBus:clearAll
do
    local patterns_last_state_dt = 0

    local bus = lurek.patterns.newEventBus("game_events")
    bus:on("spawn", function(id)
        lurek.log.info("spawn = " .. tostring(id))
    end)
    bus:on("hit", function(amount)
        lurek.log.info("hit = " .. tostring(amount))
    end)
    lurek.log.info("before = " .. #bus:getEvents())
    bus:clearAll()
    lurek.log.info("after = " .. #bus:getEvents())
end

--@api: lurek.patterns.newMediator
do
    local patterns_last_state_dt = 0

    local med = lurek.patterns.newMediator()
    local id = med:on("ui", function(msg, data)
        lurek.log.info(msg .. " = " .. tostring(data))
    end)
    med:send("ui", "hp", 80)
    lurek.log.info("channels = " .. #med:channels())
    med:off("ui", id)
end

--@api: LMediator:on
do
    local patterns_last_state_dt = 0

    local med = lurek.patterns.newMediator()
    local id = med:on("ui", function(msg, data)
        lurek.log.info(msg .. " = " .. tostring(data))
    end)
    med:send("ui", "hp", 80)
    lurek.log.info("handlers = " .. med:handlerCount("ui"))
    med:off("ui", id)
end

--@api: LMediator:send
do
    local patterns_last_state_dt = 0

    local med = lurek.patterns.newMediator()
    local id = med:on("ui", function(msg, data)
        lurek.log.info(msg .. " = " .. tostring(data))
    end)
    med:send("ui", "hp", 80)
    lurek.log.info("channels = " .. #med:channels())
    med:off("ui", id)
end

--@api: LMediator:off
do
    local patterns_last_state_dt = 0

    local med = lurek.patterns.newMediator()
    local id = med:on("ui", function(msg, data)
        lurek.log.info(msg .. " = " .. tostring(data))
    end)
    med:off("ui", id)
    med:send("ui", "hp", 80)
    lurek.log.info("handlers = " .. med:handlerCount("ui"))
end

--@api: LMediator:broadcast
do
    local patterns_last_state_dt = 0

    local med = lurek.patterns.newMediator()
    med:on("audio", function(msg)
        lurek.log.info("audio = " .. tostring(msg))
    end)
    med:on("video", function(msg)
        lurek.log.info("video = " .. tostring(msg))
    end)
    med:broadcast("pause")
    lurek.log.info("channels = " .. #med:channels())
    lurek.log.info("audio handlers = " .. med:handlerCount("audio"))
end

--@api: LMediator:channels
do
    local patterns_last_state_dt = 0

    local med = lurek.patterns.newMediator()
    med:on("audio", function(msg)
        lurek.log.info("audio = " .. tostring(msg))
    end)
    med:on("video", function(msg)
        lurek.log.info("video = " .. tostring(msg))
    end)
    local channels = med:channels()
    lurek.log.info("channels = " .. #channels)
    lurek.log.info("first = " .. tostring(channels[1]))
end

--@api: LMediator:handlerCount
do
    local patterns_last_state_dt = 0

    local med = lurek.patterns.newMediator()
    med:on("audio", function(msg)
        lurek.log.info("audio = " .. tostring(msg))
    end)
    med:on("audio", function(msg)
        lurek.log.info("audio log = " .. tostring(msg))
    end)
    lurek.log.info("audio handlers = " .. med:handlerCount("audio"))
    lurek.log.info("channels = " .. #med:channels())
end

--@api: LMediator:removeChannel
do
    local patterns_last_state_dt = 0

    local med = lurek.patterns.newMediator()
    med:on("audio", function(msg)
        lurek.log.info("audio = " .. tostring(msg))
    end)
    lurek.log.info("before = " .. #med:channels())
    med:removeChannel("audio")
    lurek.log.info("after = " .. #med:channels())
end

--@api: LMediator:clear
do
    local patterns_last_state_dt = 0

    local med = lurek.patterns.newMediator()
    med:on("audio", function(msg)
        lurek.log.info("audio = " .. tostring(msg))
    end)
    med:on("video", function(msg)
        lurek.log.info("video = " .. tostring(msg))
    end)
    lurek.log.info("before = " .. #med:channels())
    med:clear()
    lurek.log.info("after = " .. #med:channels())
end

--@api: lurek.patterns.newDebounce
do
    local patterns_last_state_dt = 0

    local db = lurek.patterns.newDebounce(0.5)
    db:onFire(function()
        lurek.log.info("debounce fired")
    end)
    db:trigger()
    lurek.log.info("pending = " .. tostring(db:isPending()))
    db:update(0.6)
    lurek.log.info("fires = " .. db:getFireCount())
end

--@api: LDebounce:trigger
do
    local patterns_last_state_dt = 0

    local db = lurek.patterns.newDebounce(0.5)
    db:onFire(function()
        lurek.log.info("debounce fired")
    end)
    db:trigger()
    lurek.log.info("pending = " .. tostring(db:isPending()))
    db:update(0.6)
    lurek.log.info("fires = " .. db:getFireCount())
end

--@api: LDebounce:update
do
    local patterns_last_state_dt = 0

    local db = lurek.patterns.newDebounce(0.5)
    db:onFire(function()
        lurek.log.info("debounce fired")
    end)
    db:trigger()
    db:update(0.6)
    lurek.log.info("pending = " .. tostring(db:isPending()))
    lurek.log.info("fires = " .. db:getFireCount())
end

--@api: LDebounce:onFire
do
    local patterns_last_state_dt = 0

    local db = lurek.patterns.newDebounce(0.5)
    db:onFire(function()
        lurek.log.info("debounce fired")
    end)
    db:trigger()
    db:update(0.6)
    lurek.log.info("fires = " .. db:getFireCount())
    lurek.log.info("pending = " .. tostring(db:isPending()))
end

--@api: LDebounce:cancel
do
    local patterns_last_state_dt = 0

    local db = lurek.patterns.newDebounce(1.0)
    db:onFire(function()
        lurek.log.info("debounce fired")
    end)
    db:trigger()
    lurek.log.info("pending = " .. tostring(db:isPending()))
    db:cancel()
    db:update(1.1)
    lurek.log.info("fires = " .. db:getFireCount())
end

--@api: LDebounce:isPending
do
    local patterns_last_state_dt = 0

    local db = lurek.patterns.newDebounce(1.0)
    db:onFire(function()
        lurek.log.info("debounce fired")
    end)
    db:trigger()
    lurek.log.info("pending = " .. tostring(db:isPending()))
    db:update(0.2)
    lurek.log.info("fires = " .. db:getFireCount())
end

--@api: LDebounce:getFireCount
do
    local patterns_last_state_dt = 0

    local db = lurek.patterns.newDebounce(0.3)
    db:onFire(function()
        lurek.log.info("debounce fired")
    end)
    db:trigger()
    db:update(0.4)
    lurek.log.info("fires = " .. db:getFireCount())
    lurek.log.info("pending = " .. tostring(db:isPending()))
end

--@api: lurek.patterns.newThrottle
do
    local patterns_last_state_dt = 0

    local th = lurek.patterns.newThrottle(0.2)
    local fires = 0
    th:onFire(function()
        fires = fires + 1
        lurek.log.info("throttle fired = " .. fires)
    end)
    th:update(0.1)
    th:update(0.1)
    th:update(0.2)
    lurek.log.info("fires = " .. th:getFireCount())
end

--@api: LThrottle:onFire
do
    local patterns_last_state_dt = 0

    local th = lurek.patterns.newThrottle(0.2)
    local fires = 0
    th:onFire(function()
        fires = fires + 1
        lurek.log.info("throttle fired = " .. fires)
    end)
    th:update(0.2)
    th:update(0.2)
    lurek.log.info("fires = " .. th:getFireCount())
end

--@api: LThrottle:update
do
    local patterns_last_state_dt = 0

    local th = lurek.patterns.newThrottle(0.2)
    local fires = 0
    th:onFire(function()
        fires = fires + 1
        lurek.log.info("throttle fired = " .. fires)
    end)
    th:update(0.1)
    th:update(0.1)
    lurek.log.info("fires = " .. th:getFireCount())
end

--@api: LThrottle:getFireCount
do
    local patterns_last_state_dt = 0

    local th = lurek.patterns.newThrottle(0.2)
    th:onFire(function()
        lurek.log.info("throttle fired")
    end)
    th:update(0.2)
    th:update(0.2)
    lurek.log.info("fires = " .. th:getFireCount())
    lurek.log.info("progress = " .. th:getProgress())
end

--@api: LThrottle:reset
do
    local patterns_last_state_dt = 0

    local th = lurek.patterns.newThrottle(1.0)
    th:onFire(function()
        lurek.log.info("throttle fired")
    end)
    th:update(0.5)
    lurek.log.info("progress = " .. th:getProgress())
    th:reset()
    lurek.log.info("after reset = " .. th:getProgress())
end

--@api: LThrottle:setEnabled
do
    local patterns_last_state_dt = 0

    local th = lurek.patterns.newThrottle(1.0)
    th:onFire(function()
        lurek.log.info("throttle fired")
    end)
    th:setEnabled(false)
    th:update(2.0)
    lurek.log.info("fires = " .. th:getFireCount())
    lurek.log.info("progress = " .. th:getProgress())
end

--@api: LThrottle:getProgress
do
    local patterns_last_state_dt = 0

    local th = lurek.patterns.newThrottle(1.0)
    th:onFire(function()
        lurek.log.info("throttle fired")
    end)
    th:update(0.5)
    lurek.log.info("progress = " .. th:getProgress())
    th:update(0.5)
    lurek.log.info("fires = " .. th:getFireCount())
end

--@api: lurek.patterns.newFunnel
do
    local patterns_last_state_dt = 0

    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries)
        lurek.log.info("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    lurek.log.info("pending = " .. funnel:pendingCount())
    funnel:update(1.1)
    lurek.log.info("flush count = " .. funnel:getFlushCount())
end

--@api: LFunnel:push
do
    local patterns_last_state_dt = 0

    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries)
        lurek.log.info("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    lurek.log.info("pending = " .. funnel:pendingCount())
    funnel:update(1.1)
    lurek.log.info("flush count = " .. funnel:getFlushCount())
end

--@api: LFunnel:update
do
    local patterns_last_state_dt = 0

    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries)
        lurek.log.info("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:update(1.1)
    lurek.log.info("pending = " .. funnel:pendingCount())
    lurek.log.info("flush count = " .. funnel:getFlushCount())
end

--@api: LFunnel:onFlush
do
    local patterns_last_state_dt = 0

    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries)
        lurek.log.info("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:update(1.1)
    lurek.log.info("pending = " .. funnel:pendingCount())
    lurek.log.info("flush count = " .. funnel:getFlushCount())
end

--@api: LFunnel:flush
do
    local patterns_last_state_dt = 0

    local funnel = lurek.patterns.newFunnel(5.0, 0, "damage_log")
    funnel:onFlush(function(entries)
        lurek.log.info("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:flush()
    lurek.log.info("pending = " .. funnel:pendingCount())
    lurek.log.info("flush count = " .. funnel:getFlushCount())
end

--@api: LFunnel:discard
do
    local patterns_last_state_dt = 0

    local funnel = lurek.patterns.newFunnel(5.0, 0, "damage_log")
    funnel:onFlush(function(entries)
        lurek.log.info("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:discard()
    lurek.log.info("pending = " .. funnel:pendingCount())
    lurek.log.info("flush count = " .. funnel:getFlushCount())
end

--@api: LFunnel:pendingCount
do
    local patterns_last_state_dt = 0

    local funnel = lurek.patterns.newFunnel(5.0, 0, "damage_log")
    funnel:onFlush(function(entries)
        lurek.log.info("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    lurek.log.info("pending = " .. funnel:pendingCount())
    lurek.log.info("flush count = " .. funnel:getFlushCount())
end

--@api: LFunnel:getFlushCount
do
    local patterns_last_state_dt = 0

    local funnel = lurek.patterns.newFunnel(5.0, 0, "damage_log")
    funnel:onFlush(function(entries)
        lurek.log.info("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:flush()
    lurek.log.info("pending = " .. funnel:pendingCount())
    lurek.log.info("flush count = " .. funnel:getFlushCount())
end

--- Patterns Module Part 4: graph, collections (list, map, set, stack, queue, ring, priority queue, weighted random, relationships)

--@api: lurek.patterns.newGraph
do
    local patterns_last_state_dt = 0

    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("A", {cost = 10})
    local b = g:addNode("B", {cost = 5})
    g:addEdge(a, b, 1.5, "road")
    lurek.log.info("nodes = " .. g:nodeCount())
    lurek.log.info("edges = " .. g:edgeCount())
end

--@api: LPatternGraph:addNode
do
    local patterns_last_state_dt = 0

    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("A", {cost = 10})
    local b = g:addNode("B", {cost = 5})
    g:addEdge(a, b, 1.0, "road")
    lurek.log.info("nodes = " .. g:nodeCount())
    lurek.log.info("has a = " .. tostring(g:hasNode(a)))
end

--@api: LPatternGraph:addEdge
do
    local patterns_last_state_dt = 0

    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("A")
    local b = g:addNode("B")
    g:addEdge(a, b, 2.5, "road")
    lurek.log.info("nodes = " .. g:nodeCount())
    lurek.log.info("edges = " .. g:edgeCount())
end

--@api: LPatternGraph:nodeCount
do
    local patterns_last_state_dt = 0

    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("A")
    local b = g:addNode("B")
    g:addEdge(a, b, 1.0, "road")
    lurek.log.info("nodes = " .. g:nodeCount())
    lurek.log.info("edges = " .. g:edgeCount())
end

--@api: LPatternGraph:edgeCount
do
    local patterns_last_state_dt = 0

    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("A")
    local b = g:addNode("B")
    g:addEdge(a, b, 1.0, "road")
    lurek.log.info("nodes = " .. g:nodeCount())
    lurek.log.info("edges = " .. g:edgeCount())
end

--@api: LPatternGraph:bfs
do
    local patterns_last_state_dt = 0

    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("start")
    local b = g:addNode("mid")
    local c = g:addNode("end")
    g:addEdge(a, b)
    g:addEdge(b, c)
    local order = g:bfs(a)
    lurek.log.info("bfs = " .. #order)
    lurek.log.info("connected = " .. tostring(g:isConnected(a, c)))
end

--@api: LPatternGraph:dfs
do
    local patterns_last_state_dt = 0

    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("start")
    local b = g:addNode("mid")
    local c = g:addNode("end")
    g:addEdge(a, b)
    g:addEdge(b, c)
    local order = g:dfs(a)
    lurek.log.info("dfs = " .. #order)
    lurek.log.info("connected = " .. tostring(g:isConnected(a, c)))
end

--@api: LPatternGraph:isConnected
do
    local patterns_last_state_dt = 0

    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("start")
    local b = g:addNode("mid")
    local c = g:addNode("end")
    g:addEdge(a, b)
    g:addEdge(b, c)
    lurek.log.info("start to end = " .. tostring(g:isConnected(a, c)))
    lurek.log.info("start to start = " .. tostring(g:isConnected(a, a)))
end

--@api: LPatternGraph:neighbors
do
    local patterns_last_state_dt = 0

    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("start")
    local b = g:addNode("mid")
    local c = g:addNode("end")
    g:addEdge(a, b)
    g:addEdge(b, c)
    local neighbors = g:neighbors(b)
    lurek.log.info("neighbors = " .. #neighbors)
    lurek.log.info("has b = " .. tostring(g:hasNode(b)))
end

--@api: LPatternGraph:hasNode
do
    local patterns_last_state_dt = 0

    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("start")
    local b = g:addNode("mid")
    g:addEdge(a, b)
    lurek.log.info("has a = " .. tostring(g:hasNode(a)))
    lurek.log.info("has 99 = " .. tostring(g:hasNode(99)))
end

--@api: LPatternGraph:getNodeValue
do
    local patterns_last_state_dt = 0

    local g = lurek.patterns.newGraph()
    local a = g:addNode("room", {size = 10})
    local b = g:addNode("hall")
    local edge = g:addEdge(a, b, 2.0, "door")
    local value = g:getNodeValue(a)
    lurek.log.info("room size = " .. tostring(value and value.size))
    lurek.log.info("edges = " .. g:edgeCount())
end

--@api: LPatternGraph:removeNode
do
    local patterns_last_state_dt = 0

    local g = lurek.patterns.newGraph()
    local a = g:addNode("room", {size = 10})
    local b = g:addNode("hall")
    g:addEdge(a, b, 2.0, "door")
    g:removeNode(b)
    lurek.log.info("nodes = " .. g:nodeCount())
    lurek.log.info("has hall = " .. tostring(g:hasNode(b)))
end

--@api: LPatternGraph:removeEdge
do
    local patterns_last_state_dt = 0

    local g = lurek.patterns.newGraph()
    local a = g:addNode("room")
    local b = g:addNode("hall")
    local edge = g:addEdge(a, b, 2.0, "door")
    g:removeEdge(edge)
    lurek.log.info("edges = " .. g:edgeCount())
    lurek.log.info("nodes = " .. g:nodeCount())
end

--@api: LPatternGraph:clearAll
do
    local patterns_last_state_dt = 0

    local g = lurek.patterns.newGraph()
    local a = g:addNode("room")
    local b = g:addNode("hall")
    g:addEdge(a, b, 2.0, "door")
    lurek.log.info("before = " .. g:nodeCount())
    g:clearAll()
    lurek.log.info("after = " .. g:nodeCount())
end

--@api: lurek.patterns.newList
do
    local patterns_last_state_dt = 0

    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    lurek.log.info("len = " .. list:len())
    lurek.log.info("second = " .. tostring(list:get(2)))
end

--@api: LList:add
do
    local patterns_last_state_dt = 0

    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    lurek.log.info("len = " .. list:len())
    lurek.log.info("second = " .. tostring(list:get(2)))
end

--@api: LList:get
do
    local patterns_last_state_dt = 0

    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    lurek.log.info("second = " .. tostring(list:get(2)))
    lurek.log.info("len = " .. list:len())
end

--@api: LList:len
do
    local patterns_last_state_dt = 0

    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    lurek.log.info("len = " .. list:len())
    lurek.log.info("beta = " .. tostring(list:indexOf("beta")))
end

--@api: LList:remove
do
    local patterns_last_state_dt = 0

    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    local removed = list:remove(2)
    lurek.log.info("removed = " .. tostring(removed))
    lurek.log.info("len = " .. list:len())
end

--@api: LList:indexOf
do
    local patterns_last_state_dt = 0

    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    lurek.log.info("beta = " .. tostring(list:indexOf("beta")))
    lurek.log.info("delta = " .. tostring(list:indexOf("delta")))
end

--@api: LList:push
do
    local patterns_last_state_dt = 0

    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    lurek.log.info("len = " .. list:len())
    lurek.log.info("last = " .. tostring(list:get(3)))
end

--@api: LList:pop
do
    local patterns_last_state_dt = 0

    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    local popped = list:pop()
    lurek.log.info("popped = " .. tostring(popped))
    lurek.log.info("len = " .. list:len())
end

--@api: LList:insert
do
    local patterns_last_state_dt = 0

    local list = lurek.patterns.newList()
    list:push("a")
    list:push("c")
    list:insert(2, "b")
    lurek.log.info("second = " .. tostring(list:get(2)))
    lurek.log.info("len = " .. list:len())
end

--@api: LList:set
do
    local patterns_last_state_dt = 0

    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:set(2, "B")
    lurek.log.info("second = " .. tostring(list:get(2)))
    lurek.log.info("len = " .. list:len())
end

--@api: LList:shift
do
    local patterns_last_state_dt = 0

    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    local shifted = list:shift()
    lurek.log.info("shifted = " .. tostring(shifted))
    lurek.log.info("len = " .. list:len())
end

--@api: LList:unshift
do
    local patterns_last_state_dt = 0

    local list = lurek.patterns.newList()
    list:push("b")
    list:push("c")
    list:unshift("a")
    lurek.log.info("first = " .. tostring(list:get(1)))
    lurek.log.info("len = " .. list:len())
end

--@api: LList:contains
do
    local patterns_last_state_dt = 0

    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    lurek.log.info("contains b = " .. tostring(list:contains("b")))
    lurek.log.info("contains z = " .. tostring(list:contains("z")))
end

--@api: LList:reverse
do
    local patterns_last_state_dt = 0

    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    list:reverse()
    lurek.log.info("first = " .. tostring(list:get(1)))
    lurek.log.info("last = " .. tostring(list:get(3)))
end

--@api: LList:toArray
do
    local patterns_last_state_dt = 0

    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    local arr = list:toArray()
    lurek.log.info("array = " .. #arr)
    lurek.log.info("first = " .. tostring(arr[1]))
end

--@api: LList:isEmpty
do
    local patterns_last_state_dt = 0

    local list = lurek.patterns.newList()
    local before = list:isEmpty()
    list:push("a")
    list:push("b")
    local after = list:isEmpty()
    local count = list:len()
    lurek.log.info("list empty_before=" .. tostring(before) .. " empty_after=" .. tostring(after) .. " count=" .. tostring(count))
end

--@api: lurek.patterns.newMap
do
    local patterns_last_state_dt = 0

    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    lurek.log.info("name = " .. tostring(map:get("name")))
    lurek.log.info("len = " .. map:len())
end

--@api: LMap:set
do
    local patterns_last_state_dt = 0

    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    lurek.log.info("name = " .. tostring(map:get("name")))
    lurek.log.info("len = " .. map:len())
end

--@api: LMap:get
do
    local patterns_last_state_dt = 0

    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    lurek.log.info("name = " .. tostring(map:get("name")))
    lurek.log.info("has level = " .. tostring(map:has("level")))
end

--@api: LMap:has
do
    local patterns_last_state_dt = 0

    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    lurek.log.info("has level = " .. tostring(map:has("level")))
    lurek.log.info("has class = " .. tostring(map:has("class")))
end

--@api: LMap:remove
do
    local patterns_last_state_dt = 0

    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("class", "warrior")
    map:remove("class")
    lurek.log.info("has class = " .. tostring(map:has("class")))
    lurek.log.info("len = " .. map:len())
end

--@api: LMap:keys
do
    local patterns_last_state_dt = 0

    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    local keys = map:keys()
    lurek.log.info("keys = " .. #keys)
    lurek.log.info("first = " .. tostring(keys[1]))
end

--@api: LMap:values
do
    local patterns_last_state_dt = 0

    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    local values = map:values()
    lurek.log.info("values = " .. #values)
    lurek.log.info("first = " .. tostring(values[1]))
end

--@api: LMap:len
do
    local patterns_last_state_dt = 0

    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    lurek.log.info("len = " .. map:len())
    lurek.log.info("has name = " .. tostring(map:has("name")))
end

--@api: LMap:entries
do
    local patterns_last_state_dt = 0

    local map = lurek.patterns.newMap()
    map:set("a", 1)
    map:set("b", 2)
    local entries = map:entries()
    lurek.log.info("entries = " .. #entries)
    lurek.log.info("len = " .. map:len())
end

--@api: LMap:merge
do
    local patterns_last_state_dt = 0

    local m1 = lurek.patterns.newMap()
    local m2 = lurek.patterns.newMap()
    m1:set("a", 1)
    m2:set("b", 2)
    m1:merge(m2)
    lurek.log.info("len = " .. m1:len())
    lurek.log.info("b = " .. tostring(m1:get("b")))
end

--@api: LMap:isEmpty
do
    local patterns_last_state_dt = 0

    local map = lurek.patterns.newMap()
    local before = map:isEmpty()
    map:set("a", 1)
    map:set("b", 2)
    local after = map:isEmpty()
    local count = map:len()
    lurek.log.info("map empty_before=" .. tostring(before) .. " empty_after=" .. tostring(after) .. " count=" .. tostring(count))
end

--@api: LMap:clear
do
    local patterns_last_state_dt = 0

    local map = lurek.patterns.newMap()
    map:set("a", 1)
    map:set("b", 2)
    lurek.log.info("before = " .. map:len())
    map:clear()
    lurek.log.info("after = " .. map:len())
end

--@api: lurek.patterns.newSet
do
    local patterns_last_state_dt = 0

    local set = lurek.patterns.newSet()
    set:add("fire")
    set:add("ice")
    lurek.log.info("len = " .. set:len())
    lurek.log.info("has fire = " .. tostring(set:has("fire")))
end

--@api: LSet:add
do
    local patterns_last_state_dt = 0

    local set = lurek.patterns.newSet()
    set:add("fire")
    set:add("ice")
    lurek.log.info("len = " .. set:len())
    lurek.log.info("has fire = " .. tostring(set:has("fire")))
end

--@api: LSet:has
do
    local patterns_last_state_dt = 0

    local set = lurek.patterns.newSet()
    set:add("fire")
    set:add("ice")
    lurek.log.info("has fire = " .. tostring(set:has("fire")))
    lurek.log.info("has wind = " .. tostring(set:has("wind")))
end

--@api: LSet:remove
do
    local patterns_last_state_dt = 0

    local set = lurek.patterns.newSet()
    set:add("fire")
    set:add("ice")
    set:remove("ice")
    lurek.log.info("has ice = " .. tostring(set:has("ice")))
    lurek.log.info("len = " .. set:len())
end

--@api: LSet:len
do
    local patterns_last_state_dt = 0

    local set = lurek.patterns.newSet()
    set:add("fire")
    set:add("ice")
    set:add("wind")
    lurek.log.info("len = " .. set:len())
    lurek.log.info("has fire = " .. tostring(set:has("fire")))
end

--@api: LSet:toArray
do
    local patterns_last_state_dt = 0

    local set = lurek.patterns.newSet()
    set:add("fire")
    set:add("ice")
    local arr = set:toArray()
    lurek.log.info("array = " .. #arr)
    lurek.log.info("len = " .. set:len())
end

--@api: LSet:union
do
    local patterns_last_state_dt = 0

    local a = lurek.patterns.newSet()
    local b = lurek.patterns.newSet()
    a:add("x")
    a:add("y")
    b:add("y")
    b:add("z")
    local union = a:union(b)
    lurek.log.info("union = " .. union:len())
    lurek.log.info("intersection = " .. a:intersection(b):len())
end

--@api: LSet:intersection
do
    local patterns_last_state_dt = 0

    local a = lurek.patterns.newSet()
    local b = lurek.patterns.newSet()
    a:add("x")
    a:add("y")
    b:add("y")
    b:add("z")
    local inter = a:intersection(b)
    lurek.log.info("intersection = " .. inter:len())
    lurek.log.info("union = " .. a:union(b):len())
end

--@api: LSet:isEmpty
do
    local patterns_last_state_dt = 0

    local set = lurek.patterns.newSet()
    local before = set:isEmpty()
    set:add("x")
    set:add("y")
    local after = set:isEmpty()
    local count = set:len()
    lurek.log.info("set empty_before=" .. tostring(before) .. " empty_after=" .. tostring(after) .. " count=" .. tostring(count))
end

--@api: LSet:clear
do
    local patterns_last_state_dt = 0

    local set = lurek.patterns.newSet()
    set:add("x")
    set:add("y")
    lurek.log.info("before = " .. set:len())
    set:clear()
    lurek.log.info("after = " .. set:len())
end

--@api: lurek.patterns.newStack
do
    local patterns_last_state_dt = 0

    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    lurek.log.info("peek = " .. tostring(st:peek()))
    lurek.log.info("len = " .. st:len())
end

--@api: LStack:push
do
    local patterns_last_state_dt = 0

    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    lurek.log.info("peek = " .. tostring(st:peek()))
    lurek.log.info("len = " .. st:len())
end

--@api: LStack:pop
do
    local patterns_last_state_dt = 0

    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    local value = st:pop()
    lurek.log.info("popped = " .. tostring(value))
    lurek.log.info("len = " .. st:len())
end

--@api: LStack:peek
do
    local patterns_last_state_dt = 0

    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    lurek.log.info("peek = " .. tostring(st:peek()))
    lurek.log.info("len = " .. st:len())
end

--@api: LStack:len
do
    local patterns_last_state_dt = 0

    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    lurek.log.info("len = " .. st:len())
    lurek.log.info("empty = " .. tostring(st:isEmpty()))
end

--@api: LStack:isEmpty
do
    local patterns_last_state_dt = 0

    local st = lurek.patterns.newStack(100)
    local before = st:isEmpty()
    st:push("first")
    st:push("second")
    local after = st:isEmpty()
    local top = st:peek()
    lurek.log.info("stack empty_before=" .. tostring(before) .. " empty_after=" .. tostring(after) .. " top=" .. tostring(top))
end

--@api: LStack:pushBottom
do
    local patterns_last_state_dt = 0

    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:pushBottom("z")
    lurek.log.info("bottom = " .. tostring(st:peekBottom()))
    lurek.log.info("len = " .. st:len())
end

--@api: LStack:popBottom
do
    local patterns_last_state_dt = 0

    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:pushBottom("z")
    local value = st:popBottom()
    lurek.log.info("bottom = " .. tostring(value))
    lurek.log.info("len = " .. st:len())
end

--@api: LStack:peekBottom
do
    local patterns_last_state_dt = 0

    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:pushBottom("z")
    lurek.log.info("bottom = " .. tostring(st:peekBottom()))
    lurek.log.info("len = " .. st:len())
end

--@api: LStack:peekAt
do
    local patterns_last_state_dt = 0

    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    lurek.log.info("at 2 = " .. tostring(st:peekAt(2)))
    lurek.log.info("len = " .. st:len())
end

--@api: LStack:insertAt
do
    local patterns_last_state_dt = 0

    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("c")
    st:insertAt(2, "b")
    lurek.log.info("at 2 = " .. tostring(st:peekAt(2)))
    lurek.log.info("len = " .. st:len())
end

--@api: LStack:removeAt
do
    local patterns_last_state_dt = 0

    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    local value = st:removeAt(2)
    lurek.log.info("removed = " .. tostring(value))
    lurek.log.info("len = " .. st:len())
end

--@api: LStack:popMany
do
    local patterns_last_state_dt = 0

    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    local values = st:popMany(2)
    lurek.log.info("count = " .. #values)
    lurek.log.info("len = " .. st:len())
end

--@api: LStack:moveWithin
do
    local patterns_last_state_dt = 0

    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    st:moveWithin(1, 3)
    local arr = st:toArray()
    lurek.log.info("first = " .. tostring(arr[1]))
    lurek.log.info("last = " .. tostring(arr[#arr]))
end

--@api: LStack:isFull
do
    local patterns_last_state_dt = 0

    local st = lurek.patterns.newStack(2)
    st:push("a")
    st:push("b")
    lurek.log.info("full = " .. tostring(st:isFull()))
    lurek.log.info("len = " .. st:len())
end

--@api: LStack:clear
do
    local patterns_last_state_dt = 0

    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    lurek.log.info("before = " .. st:len())
    st:clear()
    lurek.log.info("after = " .. st:len())
end

--@api: LStack:toArray
do
    local patterns_last_state_dt = 0

    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    local arr = st:toArray()
    lurek.log.info("array = " .. #arr)
    lurek.log.info("first = " .. tostring(arr[1]))
end

--@api: lurek.patterns.newQueue
do
    local patterns_last_state_dt = 0

    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    lurek.log.info("front = " .. tostring(q:front()))
    lurek.log.info("len = " .. q:len())
end

--@api: LQueue:enqueue
do
    local patterns_last_state_dt = 0

    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    lurek.log.info("front = " .. tostring(q:front()))
    lurek.log.info("len = " .. q:len())
end

--@api: LQueue:dequeue
do
    local patterns_last_state_dt = 0

    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    local value = q:dequeue()
    lurek.log.info("dequeued = " .. tostring(value))
    lurek.log.info("len = " .. q:len())
end

--@api: LQueue:front
do
    local patterns_last_state_dt = 0

    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    lurek.log.info("front = " .. tostring(q:front()))
    lurek.log.info("back = " .. tostring(q:back()))
end

--@api: LQueue:back
do
    local patterns_last_state_dt = 0

    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    lurek.log.info("back = " .. tostring(q:back()))
    lurek.log.info("len = " .. q:len())
end

--@api: LQueue:len
do
    local patterns_last_state_dt = 0

    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    lurek.log.info("len = " .. q:len())
    lurek.log.info("empty = " .. tostring(q:isEmpty()))
end

--@api: LQueue:isEmpty
do
    local patterns_last_state_dt = 0

    local q = lurek.patterns.newQueue(10)
    local before = q:isEmpty()
    q:enqueue("msg1")
    q:enqueue("msg2")
    local after = q:isEmpty()
    local front = q:front()
    lurek.log.info("queue empty_before=" .. tostring(before) .. " empty_after=" .. tostring(after) .. " front=" .. tostring(front))
end

--@api: LQueue:enqueueFront
do
    local patterns_last_state_dt = 0

    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueueFront("priority")
    lurek.log.info("front = " .. tostring(q:front()))
    lurek.log.info("len = " .. q:len())
end

--@api: LQueue:dequeueBack
do
    local patterns_last_state_dt = 0

    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    local value = q:dequeueBack()
    lurek.log.info("dequeued back = " .. tostring(value))
    lurek.log.info("len = " .. q:len())
end

--@api: LQueue:insertAt
do
    local patterns_last_state_dt = 0

    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("c")
    q:insertAt(2, "b")
    lurek.log.info("at 2 = " .. tostring(q:peekAt(2)))
    lurek.log.info("len = " .. q:len())
end

--@api: LQueue:removeAt
do
    local patterns_last_state_dt = 0

    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    local value = q:removeAt(2)
    lurek.log.info("removed = " .. tostring(value))
    lurek.log.info("len = " .. q:len())
end

--@api: LQueue:peekAt
do
    local patterns_last_state_dt = 0

    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    lurek.log.info("at 2 = " .. tostring(q:peekAt(2)))
    lurek.log.info("len = " .. q:len())
end

--@api: LQueue:isFull
do
    local patterns_last_state_dt = 0

    local q = lurek.patterns.newQueue(2)
    q:enqueue("a")
    q:enqueue("b")
    lurek.log.info("full = " .. tostring(q:isFull()))
    lurek.log.info("len = " .. q:len())
end

--@api: LQueue:clear
do
    local patterns_last_state_dt = 0

    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    lurek.log.info("before = " .. q:len())
    q:clear()
    lurek.log.info("after = " .. q:len())
end

--@api: LQueue:toArray
do
    local patterns_last_state_dt = 0

    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    local arr = q:toArray()
    lurek.log.info("array = " .. #arr)
    lurek.log.info("first = " .. tostring(arr[1]))
end

--@api: lurek.patterns.newPriorityQueue
do
    local patterns_last_state_dt = 0

    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    lurek.log.info("peek = " .. tostring(pq:peek()))
    lurek.log.info("len = " .. pq:len())
end

--@api: LPriorityQueue:push
do
    local patterns_last_state_dt = 0

    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    lurek.log.info("peek = " .. tostring(pq:peek()))
    lurek.log.info("len = " .. pq:len())
end

--@api: LPriorityQueue:pop
do
    local patterns_last_state_dt = 0

    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    local value = pq:pop()
    lurek.log.info("popped = " .. tostring(value))
    lurek.log.info("len = " .. pq:len())
end

--@api: LPriorityQueue:peek
do
    local patterns_last_state_dt = 0

    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    lurek.log.info("peek = " .. tostring(pq:peek()))
    lurek.log.info("len = " .. pq:len())
end

--@api: LPriorityQueue:len
do
    local patterns_last_state_dt = 0

    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    lurek.log.info("len = " .. pq:len())
    lurek.log.info("empty = " .. tostring(pq:isEmpty()))
end

--@api: LPriorityQueue:isEmpty
do
    local patterns_last_state_dt = 0

    local pq = lurek.patterns.newPriorityQueue("tasks")
    local before = pq:isEmpty()
    pq:push(10, "high_task", "high")
    pq:push(1, "low_task", "low")
    local after = pq:isEmpty()
    local top = pq:peek()
    lurek.log.info("priority queue empty_before=" .. tostring(before) .. " empty_after=" .. tostring(after) .. " top=" .. tostring(top))
end

--@api: LPriorityQueue:clearAll
do
    local patterns_last_state_dt = 0

    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    lurek.log.info("before = " .. pq:len())
    pq:clearAll()
    lurek.log.info("after = " .. pq:len())
end

--@api: lurek.patterns.newRing
do
    local patterns_last_state_dt = 0

    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    lurek.log.info("len = " .. ring:len())
    lurek.log.info("average = " .. ring:average())
end

--@api: LRing:push
do
    local patterns_last_state_dt = 0

    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    lurek.log.info("len = " .. ring:len())
    lurek.log.info("sum = " .. ring:sum())
end

--@api: LRing:len
do
    local patterns_last_state_dt = 0

    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    lurek.log.info("len = " .. ring:len())
    lurek.log.info("full = " .. tostring(ring:isFull()))
end

--@api: LRing:latest
do
    local patterns_last_state_dt = 0

    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    local entry = ring:latest()
    lurek.log.info("latest = " .. tostring(entry and entry.value))
    lurek.log.info("len = " .. ring:len())
end

--@api: LRing:isFull
do
    local patterns_last_state_dt = 0

    local ring = lurek.patterns.newRing(3, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    lurek.log.info("full = " .. tostring(ring:isFull()))
    lurek.log.info("len = " .. ring:len())
end

--@api: LRing:sum
do
    local patterns_last_state_dt = 0

    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    lurek.log.info("sum = " .. ring:sum())
    lurek.log.info("len = " .. ring:len())
end

--@api: LRing:average
do
    local patterns_last_state_dt = 0

    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    lurek.log.info("average = " .. ring:average())
    lurek.log.info("len = " .. ring:len())
end

--@api: LRing:toArray
do
    local patterns_last_state_dt = 0

    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    local arr = ring:toArray()
    lurek.log.info("array = " .. #arr)
    lurek.log.info("latest = " .. tostring(ring:latest() and ring:latest().value))
end

--@api: LRing:clear
do
    local patterns_last_state_dt = 0

    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    lurek.log.info("before = " .. ring:len())
    ring:clear()
    lurek.log.info("after = " .. ring:len())
end

--@api: lurek.patterns.newWeightedRandom
do
    local patterns_last_state_dt = 0

    local wr = lurek.patterns.newWeightedRandom()
    wr:add(10, "common", "common_loot")
    wr:add(3, "rare", "rare_loot")
    lurek.log.info("items = " .. wr:len())
    lurek.log.info("picked = " .. tostring(wr:pick(0.5)))
end

--@api: LWeightedRandom:add
do
    local patterns_last_state_dt = 0

    local wr = lurek.patterns.newWeightedRandom()
    wr:add(10, "common", "common_loot")
    wr:add(3, "rare", "rare_loot")
    lurek.log.info("items = " .. wr:len())
    lurek.log.info("total = " .. wr:totalWeight())
end

--@api: LWeightedRandom:pick
do
    local patterns_last_state_dt = 0

    local wr = lurek.patterns.newWeightedRandom()
    wr:add(10, "common", "common_loot")
    wr:add(3, "rare", "rare_loot")
    lurek.log.info("picked = " .. tostring(wr:pick(0.5)))
    lurek.log.info("items = " .. wr:len())
end

--@api: LWeightedRandom:pickN
do
    local patterns_last_state_dt = 0

    local wr = lurek.patterns.newWeightedRandom()
    wr:add(10, "common", "common_loot")
    wr:add(3, "rare", "rare_loot")
    wr:add(1, "legendary", "legendary_loot")
    local values = wr:pickN(2, {0.1, 0.9})
    lurek.log.info("count = " .. #values)
    lurek.log.info("items = " .. wr:len())
end

--@api: LWeightedRandom:len
do
    local patterns_last_state_dt = 0

    local wr = lurek.patterns.newWeightedRandom()
    wr:add(10, "common", "common_loot")
    wr:add(3, "rare", "rare_loot")
    lurek.log.info("items = " .. wr:len())
    lurek.log.info("total = " .. wr:totalWeight())
end

--@api: LWeightedRandom:totalWeight
do
    local patterns_last_state_dt = 0

    local wr = lurek.patterns.newWeightedRandom()
    wr:add(10, "common", "common_loot")
    wr:add(3, "rare", "rare_loot")
    lurek.log.info("total = " .. wr:totalWeight())
    lurek.log.info("items = " .. wr:len())
end

--@api: LWeightedRandom:remove
do
    local patterns_last_state_dt = 0

    local wr = lurek.patterns.newWeightedRandom()
    local id = wr:add(5, "item_a")
    wr:add(5, "item_b")
    wr:remove(id)
    lurek.log.info("items = " .. wr:len())
    lurek.log.info("revision = " .. wr:getRevision())
end

--@api: LWeightedRandom:setWeight
do
    local patterns_last_state_dt = 0

    local wr = lurek.patterns.newWeightedRandom()
    local id = wr:add(5, "item_a")
    wr:add(5, "item_b")
    wr:setWeight(id, 20)
    lurek.log.info("total = " .. wr:totalWeight())
    lurek.log.info("revision = " .. wr:getRevision())
end

--@api: LWeightedRandom:getRevision
do
    local patterns_last_state_dt = 0

    local wr = lurek.patterns.newWeightedRandom()
    local id = wr:add(5, "item_a")
    wr:setWeight(id, 20)
    lurek.log.info("revision = " .. wr:getRevision())
    lurek.log.info("items = " .. wr:len())
end

--@api: LWeightedRandom:isEmpty
do
    local patterns_last_state_dt = 0

    local wr = lurek.patterns.newWeightedRandom()
    local before = wr:isEmpty()
    wr:add(5, "item_a")
    wr:add(2, "item_b")
    local after = wr:isEmpty()
    local total = wr:totalWeight()
    lurek.log.info("weighted random empty_before=" .. tostring(before) .. " empty_after=" .. tostring(after) .. " total=" .. tostring(total))
end

--@api: LWeightedRandom:clearAll
do
    local patterns_last_state_dt = 0

    local wr = lurek.patterns.newWeightedRandom()
    wr:add(5, "item_a")
    wr:add(5, "item_b")
    lurek.log.info("before = " .. wr:len())
    wr:clearAll()
    lurek.log.info("after = " .. wr:len())
end

--@api: lurek.patterns.newRelationshipManager
do
    local patterns_last_state_dt = 0

    -- Deprecated alias kept for compatibility. Prefer lurek.ecs.newRelationshipManager().
    local rm = lurek.patterns.newRelationshipManager()
    rm:setValue(1, 2, 50)
    rm:setValue(1, 3, -20)
    lurek.log.info("1->2 = " .. rm:getValue(1, 2))
    lurek.log.info("1->3 = " .. rm:getValue(1, 3))
end

--- Patterns Module Part 5: integrated multi-pattern examples, real-world scenarios

--- Patterns Module Part 5: BehaviorTree (addChild/nodeCount/setRoot), LList:clear, LObjectPool counts, LSimpleState:update, LStrategy:getCurrent

--@api: LBehaviorTree:addChild
do
    local patterns_last_state_dt = 0

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
    lurek.log.info("result = " .. bt:tick())
    lurek.log.info("node_count = " .. bt:nodeCount())
end

--@api: LBehaviorTree:nodeCount
do
    local patterns_last_state_dt = 0

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
    lurek.log.info("node_count = " .. bt:nodeCount())
    lurek.log.info("result = " .. bt:tick())
end

--@api: LBehaviorTree:setRoot
do
    local patterns_last_state_dt = 0

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
    lurek.log.info("node_count = " .. bt:nodeCount())
    lurek.log.info("result = " .. bt:tick())
end

--@api: LList:clear
do
    local patterns_last_state_dt = 0

    local list = lurek.patterns.newList()
    list:add(1)
    list:add(2)
    list:add(3)
    lurek.log.info("before = " .. list:len())
    list:clear()
    lurek.log.info("after = " .. list:len())
end

--@api: LObjectPool:getActiveCount
do
    local patterns_last_state_dt = 0

    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1})
    pool:add({id = 2})
    local obj = pool:acquire()
    lurek.log.info("active = " .. pool:getActiveCount())
    lurek.log.info("got = " .. tostring(obj and obj.id))
end

--@api: LObjectPool:getAvailableCount
do
    local patterns_last_state_dt = 0

    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1})
    pool:add({id = 2})
    pool:acquire()
    lurek.log.info("available = " .. pool:getAvailableCount())
    lurek.log.info("total = " .. pool:getTotalCount())
end

--@api: LObjectPool:getTotalCount
do
    local patterns_last_state_dt = 0

    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1})
    pool:add({id = 2})
    lurek.log.info("total = " .. pool:getTotalCount())
    lurek.log.info("available = " .. pool:getAvailableCount())
end

--@api: LSimpleState:update
do
    local patterns_last_state_dt = 0

    local fsm = lurek.patterns.newSimpleState()
    patterns_last_state_dt = 0
    fsm:addState("idle", { update = function(dt)
        patterns_last_state_dt = dt
        lurek.log.info("tick idle = " .. dt)
    end })
    fsm:addState("pause")
    fsm:transitionTo("idle")
    fsm:update(0.016)
    local current = fsm:getCurrent()
    local state_count = #fsm:getStates()
    lurek.log.info("state update current=" .. tostring(current) .. " dt_seen=" .. tostring(patterns_last_state_dt) .. " state_count=" .. tostring(state_count))
end

--@api: LStrategy:getCurrent
do
    local patterns_last_state_dt = 0

    local strat = lurek.patterns.newStrategy()
    strat:register("attack", function()
        return "attacking"
    end)
    strat:register("flee", function()
        return "fleeing"
    end)
    strat:set("attack")
    lurek.log.info("current = " .. tostring(strat:getCurrent()))
    lurek.log.info("result = " .. tostring(strat:execute()))
end

--@api: lurek.patterns.newDeck
do

    local deck = lurek.patterns.newDeck({ { rank = "A" }, { rank = "K" }, { rank = "Q" } })
    local top = deck:peek()
    local count = deck:count()
    lurek.log.info("newDeck count=" .. tostring(count) .. " top=" .. tostring(top.rank))
    local count = deck:count()
    lurek.log.info("deck count = " .. count)
end

--@api: LDeck:add
do

    local deck = lurek.patterns.newDeck()
    local id = deck:add({ rank = "J", suit = "spades" })
    local top = deck:peek()
    lurek.log.info("LDeck:add id=" .. tostring(id) .. " count=" .. tostring(deck:count()) .. " top=" .. tostring(top.rank))
    local count = deck:count()
    lurek.log.info("deck count = " .. count)
end

--@api: LDeck:shuffle
do

    local deck = lurek.patterns.newDeck({ { id = 1 }, { id = 2 }, { id = 3 }, { id = 4 } })
    deck:shuffle(42)
    local cards = deck:toArray()
    lurek.log.info("LDeck:shuffle first=" .. tostring(cards[1].id) .. " second=" .. tostring(cards[2].id))
    local count = deck:count()
    lurek.log.info("deck count = " .. count)
end

--@api: LDeck:draw
do

    local deck = lurek.patterns.newDeck({ { id = "alpha" }, { id = "beta" } })
    local card = deck:draw()
    local remaining = deck:count()
    lurek.log.info("LDeck:draw card=" .. tostring(card.id) .. " remaining=" .. tostring(remaining))
    local count = deck:count()
    lurek.log.info("deck count = " .. count)
end

--@api: LDeck:peek
do

    local deck = lurek.patterns.newDeck({ { id = "alpha" }, { id = "beta" } })
    local card = deck:peek()
    local remaining = deck:count()
    lurek.log.info("LDeck:peek card=" .. tostring(card.id) .. " remaining=" .. tostring(remaining))
    local count = deck:count()
    lurek.log.info("deck count = " .. count)
end

--@api: LDeck:discard
do

    local deck = lurek.patterns.newDeck({ { id = "alpha" }, { id = "beta" } })
    local card = deck:draw()
    local discarded = deck:discard(card)
    lurek.log.info("LDeck:discard ok=" .. tostring(discarded) .. " discard_count=" .. tostring(deck:discardCount()))
    local count = deck:count()
    lurek.log.info("deck count = " .. count)
end

--@api: LDeck:reset
do

    local deck = lurek.patterns.newDeck({ { id = "alpha" }, { id = "beta" } })
    local card = deck:draw()
    deck:discard(card)
    deck:reset()
    lurek.log.info("LDeck:reset count=" .. tostring(deck:count()) .. " first=" .. tostring(deck:peek().id))
end

--@api: LDeck:count
do

    local deck = lurek.patterns.newDeck({ { id = 1 }, { id = 2 }, { id = 3 } })
    local before = deck:count()
    deck:draw()
    lurek.log.info("LDeck:count before=" .. tostring(before) .. " after=" .. tostring(deck:count()))
    local count = deck:count()
    lurek.log.info("deck count = " .. count)
end

--@api: LDeck:discardCount
do

    local deck = lurek.patterns.newDeck({ { id = 1 }, { id = 2 } })
    local card = deck:draw()
    deck:discard(card)
    lurek.log.info("LDeck:discardCount value=" .. tostring(deck:discardCount()) .. " remaining=" .. tostring(deck:count()))
    local count = deck:count()
    lurek.log.info("deck count = " .. count)
end

--@api: LDeck:isEmpty
do

    local deck = lurek.patterns.newDeck({ { id = 1 } })
    local before = deck:isEmpty()
    deck:draw()
    lurek.log.info("LDeck:isEmpty before=" .. tostring(before) .. " after=" .. tostring(deck:isEmpty()))
    local count = deck:count()
    lurek.log.info("deck count = " .. count)
end

--@api: LDeck:toArray
do

    local deck = lurek.patterns.newDeck({ { id = "alpha" }, { id = "beta" } })
    local cards = deck:toArray()
    local first = cards[1] and cards[1].id or "none"
    lurek.log.info("LDeck:toArray count=" .. tostring(#cards) .. " first=" .. tostring(first))
    local count = deck:count()
    lurek.log.info("deck count = " .. count)
end

--@api: lurek.patterns.groupBy
do
    local units = {
        { name = "pike", role = "front" },
        { name = "archer", role = "back" },
        { name = "shield", role = "front" },
    }
    local groups = lurek.patterns.groupBy(units, "role")
    lurek.log.info("front group size = " .. tostring(#groups.front))
end

--@api: lurek.patterns.countBy
do
    local items = {
        { tier = "common" },
        { tier = "rare" },
        { tier = "common" },
    }
    local counts = lurek.patterns.countBy(items, "tier")
    lurek.log.info("common count = " .. tostring(counts.common))
end

--@api: lurek.patterns.sortedIndices
do
    local scores = {
        { id = "a", score = 12 },
        { id = "b", score = 30 },
        { id = "c", score = 18 },
    }
    local order = lurek.patterns.sortedIndices(scores, function(item) return item.score end, { desc = true })
    lurek.log.info("highest score id = " .. tostring(scores[order[1]].id))
end

--@api: lurek.patterns.topN
do
    local threats = {
        { name = "scout", weight = 1 },
        { name = "tank", weight = 8 },
        { name = "raider", weight = 4 },
    }
    local top = lurek.patterns.topN(threats, "weight", 2)
    lurek.log.info("top threat = " .. tostring(top[1].name) .. " selected=" .. tostring(#top))
end

--@api: lurek.patterns.findSequences
do
    local tiles = {
        { x = 1 },
        { x = 2 },
        { x = 3 },
        { x = 7 },
    }
    local runs = lurek.patterns.findSequences(tiles, "x", { minLength = 3 })
    lurek.log.info("sequence count = " .. tostring(#runs) .. " first_len=" .. tostring(#runs[1]))
end
