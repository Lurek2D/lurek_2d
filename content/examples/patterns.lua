-- content/examples/patterns.lua
-- Auto-generated from content/examples2/patterns_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/patterns.lua

local function patterns_log(message)
    lurek.log.info("[patterns.example] " .. tostring(message))
end

local patterns_last_state_dt = 0

local function patterns_record_state_update(dt)
    patterns_last_state_dt = dt
    patterns_log("tick idle = " .. dt)
end

--- Patterns Module Part 1: service locator, object pool, factory, strategy

local function example_print_log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    lurek.log.info(table.concat(parts, " "))
end

--@api: lurek.patterns.newServiceLocator
do
    local services = lurek.patterns.newServiceLocator()
    services:provide("audio", {volume = 0.8, muted = false})
    services:provide("input", {keyboard = true, mouse = true})
    local audio = services:locate("audio")
    local service_count = #services:getServices()
    patterns_log("service locator ready has_audio=" .. tostring(services:has("audio")) .. " service_count=" .. tostring(service_count) .. " audio_volume=" .. tostring(audio and audio.volume))
end

--@api: LServiceLocator:provide
do
    local services = lurek.patterns.newServiceLocator()
    services:provide("renderer", {backend = "wgpu", vsync = true})
    services:provide("ui", {scale = 1.25})
    local renderer = services:locate("renderer")
    local service_count = #services:getServices()
    patterns_log("renderer service backend=" .. tostring(renderer and renderer.backend) .. " vsync=" .. tostring(renderer and renderer.vsync) .. " service_count=" .. tostring(service_count))
end

--@api: LServiceLocator:locate
do
    local services = lurek.patterns.newServiceLocator()
    services:provide("audio", {volume = 0.8, muted = false})
    local audio = services:locate("audio")
    example_print_log("audio volume = " .. tostring(audio and audio.volume))
    example_print_log("has audio = " .. tostring(services:has("audio")))
end

--@api: LServiceLocator:has
do
    local services = lurek.patterns.newServiceLocator()
    services:provide("input", {keyboard = true, gamepad = true})
    local has_input = services:has("input")
    local has_physics = services:has("physics")
    local input = services:locate("input")
    local service_count = #services:getServices()
    patterns_log("service presence input=" .. tostring(has_input) .. " physics=" .. tostring(has_physics) .. " gamepad=" .. tostring(input and input.gamepad) .. " service_count=" .. tostring(service_count))
end

--@api: LServiceLocator:getServices
do
    local services = lurek.patterns.newServiceLocator()
    services:provide("renderer", {backend = "wgpu"})
    services:provide("audio", {volume = 1.0})
    local names = services:getServices()
    example_print_log("services = " .. #names)
    example_print_log("first = " .. tostring(names[1]))
end

--@api: LServiceLocator:remove
do
    local services = lurek.patterns.newServiceLocator()
    services:provide("save", {slot = 1})
    services:remove("save")
    example_print_log("has save = " .. tostring(services:has("save")))
    example_print_log("services = " .. #services:getServices())
end

--@api: LServiceLocator:clearAll
do
    local services = lurek.patterns.newServiceLocator()
    services:provide("renderer", {backend = "wgpu"})
    services:provide("audio", {volume = 0.6})
    example_print_log("before = " .. #services:getServices())
    services:clearAll()
    example_print_log("after = " .. #services:getServices())
end

--@api: lurek.patterns.newObjectPool
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1, active = false})
    pool:add({id = 2, active = false})
    local obj = pool:acquire()
    local active = pool:getActiveCount()
    local available = pool:getAvailableCount()
    patterns_log("object pool total=" .. tostring(pool:getTotalCount()) .. " active=" .. tostring(active) .. " available=" .. tostring(available) .. " acquired=" .. tostring(obj and obj.id))
end

--@api: LObjectPool:add
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1, active = false})
    pool:add({id = 2, active = false})
    example_print_log("total = " .. pool:getTotalCount())
    example_print_log("available = " .. pool:getAvailableCount())
end

--@api: LObjectPool:acquire
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1, active = false})
    pool:add({id = 2, active = false})
    local obj = pool:acquire()
    example_print_log("acquired = " .. tostring(obj and obj.id))
    example_print_log("active = " .. pool:getActiveCount())
end

--@api: LObjectPool:release
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1, active = false})
    pool:add({id = 2, active = false})
    local obj = pool:acquire()
    pool:release(obj)
    example_print_log("active = " .. pool:getActiveCount())
    example_print_log("available = " .. pool:getAvailableCount())
end

--@api: LObjectPool:clearAll
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1})
    pool:add({id = 2})
    example_print_log("before = " .. pool:getTotalCount())
    pool:clearAll()
    example_print_log("after = " .. pool:getTotalCount())
end

--@api: lurek.patterns.newFactory
do
    local factory = lurek.patterns.newFactory()
    factory:register("enemy", function(hp)
        return {type = "enemy", hp = hp or 100}
    end)
    local enemy = factory:create("enemy", 120)
    example_print_log("enemy hp = " .. tostring(enemy and enemy.hp))
    example_print_log("types = " .. #factory:getTypes())
end

--@api: LFactory:register
do
    local factory = lurek.patterns.newFactory()
    factory:register("enemy", function(hp)
        return {type = "enemy", hp = hp or 100}
    end)
    example_print_log("has enemy = " .. tostring(factory:has("enemy")))
    example_print_log("types = " .. #factory:getTypes())
end

--@api: LFactory:has
do
    local factory = lurek.patterns.newFactory()
    factory:register("bullet", function(speed)
        return {type = "bullet", speed = speed or 300}
    end)
    example_print_log("has bullet = " .. tostring(factory:has("bullet")))
    example_print_log("has enemy = " .. tostring(factory:has("enemy")))
end

--@api: LFactory:create
do
    local factory = lurek.patterns.newFactory()
    factory:register("bullet", function(speed)
        return {type = "bullet", speed = speed or 300}
    end)
    local bullet = factory:create("bullet", 450)
    example_print_log("bullet speed = " .. tostring(bullet and bullet.speed))
    example_print_log("types = " .. #factory:getTypes())
end

--@api: LFactory:getTypes
do
    local factory = lurek.patterns.newFactory()
    factory:register("enemy", function()
        return {type = "enemy"}
    end)
    factory:register("bullet", function()
        return {type = "bullet"}
    end)
    local types = factory:getTypes()
    example_print_log("types = " .. #types)
    example_print_log("has enemy = " .. tostring(factory:has("enemy")))
end

--@api: LFactory:alias
do
    local factory = lurek.patterns.newFactory()
    factory:register("goblin", function()
        return {type = "goblin", hp = 30}
    end)
    factory:alias("small_enemy", "goblin")
    local goblin = factory:create("small_enemy")
    example_print_log("alias type = " .. tostring(goblin and goblin.type))
    example_print_log("has alias target = " .. tostring(factory:has("small_enemy")))
end

--@api: LFactory:remove
do
    local factory = lurek.patterns.newFactory()
    factory:register("goblin", function()
        return {type = "goblin"}
    end)
    factory:remove("goblin")
    example_print_log("has goblin = " .. tostring(factory:has("goblin")))
    example_print_log("types = " .. #factory:getTypes())
end

--@api: LFactory:clearAll
do
    local factory = lurek.patterns.newFactory()
    factory:register("enemy", function()
        return {type = "enemy"}
    end)
    factory:register("bullet", function()
        return {type = "bullet"}
    end)
    example_print_log("before = " .. #factory:getTypes())
    factory:clearAll()
    example_print_log("after = " .. #factory:getTypes())
end

--@api: lurek.patterns.newStrategy
do
    local strat = lurek.patterns.newStrategy()
    strat:register("attack", function(target)
        return "attack " .. target
    end)
    strat:register("flee", function(target)
        return "flee from " .. target
    end)
    strat:set("attack")
    example_print_log("current = " .. tostring(strat:getCurrent()))
    example_print_log("result = " .. tostring(strat:execute("orc")))
end

--@api: LStrategy:register
do
    local strat = lurek.patterns.newStrategy()
    strat:register("attack", function(target)
        return "attack " .. target
    end)
    strat:register("flee", function(target)
        return "flee from " .. target
    end)
    example_print_log("has attack = " .. tostring(strat:has("attack")))
    example_print_log("names = " .. #strat:names())
end

--@api: LStrategy:set
do
    local strat = lurek.patterns.newStrategy()
    strat:register("attack", function(target)
        return "attack " .. target
    end)
    strat:register("flee", function(target)
        return "flee from " .. target
    end)
    strat:set("flee")
    example_print_log("current = " .. tostring(strat:getCurrent()))
    example_print_log("result = " .. tostring(strat:execute("dragon")))
end

--@api: LStrategy:execute
do
    local strat = lurek.patterns.newStrategy()
    strat:register("attack", function(target)
        return "attack " .. target
    end)
    strat:register("flee", function(target)
        return "flee from " .. target
    end)
    strat:set("attack")
    example_print_log("current = " .. tostring(strat:getCurrent()))
    example_print_log("result = " .. tostring(strat:execute("slime")))
end

--@api: LStrategy:has
do
    local strat = lurek.patterns.newStrategy()
    strat:register("fast", function()
        return "fast"
    end)
    strat:register("slow", function()
        return "slow"
    end)
    example_print_log("has fast = " .. tostring(strat:has("fast")))
    example_print_log("has medium = " .. tostring(strat:has("medium")))
end

--@api: LStrategy:names
do
    local strat = lurek.patterns.newStrategy()
    strat:register("fast", function()
        return "fast"
    end)
    strat:register("slow", function()
        return "slow"
    end)
    local names = strat:names()
    example_print_log("names = " .. #names)
    example_print_log("first = " .. tostring(names[1]))
end

--@api: LStrategy:remove
do
    local strat = lurek.patterns.newStrategy()
    strat:register("fast", function()
        return "fast"
    end)
    strat:register("slow", function()
        return "slow"
    end)
    strat:remove("slow")
    example_print_log("has slow = " .. tostring(strat:has("slow")))
    example_print_log("names = " .. #strat:names())
end

--@api: LStrategy:clear
do
    local strat = lurek.patterns.newStrategy()
    strat:register("fast", function()
        return "fast"
    end)
    strat:register("slow", function()
        return "slow"
    end)
    example_print_log("before = " .. #strat:names())
    strat:clear()
    example_print_log("after = " .. #strat:names())
end

--- Patterns Module Part 2: FSM, command stack, behavior tree, blackboard

--@api: lurek.patterns.newSimpleState
do
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("idle", {
        enter = function()
            example_print_log("enter idle")
        end,
        update = function(dt)
            example_print_log("idle dt = " .. dt)
        end
    })
    fsm:transitionTo("idle")
    fsm:update(0.016)
    example_print_log("current = " .. tostring(fsm:getCurrent()))
end

--@api: LSimpleState:addState
do
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
    patterns_log("simple states total=" .. tostring(#states) .. " has_walk=" .. tostring(has_walk) .. " has_idle=" .. tostring(has_idle) .. " has_pause=" .. tostring(has_pause) .. " current=" .. tostring(current))
end

--@api: LSimpleState:transitionTo
do
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
    patterns_log("transition current=" .. tostring(current) .. " states=" .. tostring(#states) .. " has_idle=" .. tostring(has_idle) .. " has_walk=" .. tostring(has_walk) .. " has_pause=" .. tostring(has_pause))
end

--@api: LSimpleState:getCurrent
do
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("idle")
    fsm:addState("pause")
    fsm:transitionTo("idle")
    local current = fsm:getCurrent()
    local states = fsm:getStates()
    local has_idle = fsm:hasState("idle")
    local has_menu = fsm:hasState("menu")
    local has_pause = fsm:hasState("pause")
    patterns_log("current state=" .. tostring(current) .. " states=" .. tostring(#states) .. " has_idle=" .. tostring(has_idle) .. " has_menu=" .. tostring(has_menu) .. " has_pause=" .. tostring(has_pause))
end

--@api: LSimpleState:hasState
do
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("menu")
    fsm:addState("game")
    example_print_log("has menu = " .. tostring(fsm:hasState("menu")))
    example_print_log("has pause = " .. tostring(fsm:hasState("pause")))
end

--@api: LSimpleState:getStates
do
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("menu")
    fsm:addState("game")
    fsm:addState("pause")
    example_print_log("states = " .. #fsm:getStates())
    example_print_log("has pause = " .. tostring(fsm:hasState("pause")))
end

--@api: LSimpleState:clearAll
do
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("menu")
    fsm:addState("game")
    example_print_log("before = " .. #fsm:getStates())
    fsm:clearAll()
    example_print_log("after = " .. #fsm:getStates())
end

--@api: lurek.patterns.newCommandStack
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
    example_print_log("value = " .. value)
    example_print_log("history = " .. cmds:getHistorySize())
end

--@api: LCommandStack:execute
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
    example_print_log("value = " .. value)
    example_print_log("current = " .. tostring(cmds:getCurrentName()))
end

--@api: LCommandStack:undo
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
    example_print_log("value = " .. value)
    example_print_log("can redo = " .. tostring(cmds:canRedo()))
end

--@api: LCommandStack:redo
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
    example_print_log("value = " .. value)
    example_print_log("current = " .. tostring(cmds:getCurrentName()))
end

--@api: LCommandStack:canUndo
do
    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function()
    end, function()
    end)
    cmds:execute("step2", function()
    end, function()
    end)
    example_print_log("can undo = " .. tostring(cmds:canUndo()))
    example_print_log("history = " .. cmds:getHistorySize())
end

--@api: LCommandStack:canRedo
do
    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function()
    end, function()
    end)
    cmds:execute("step2", function()
    end, function()
    end)
    cmds:undo()
    example_print_log("can redo = " .. tostring(cmds:canRedo()))
    example_print_log("current = " .. tostring(cmds:getCurrentName()))
end

--@api: LCommandStack:getCurrentName
do
    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function()
    end, function()
    end)
    cmds:execute("step2", function()
    end, function()
    end)
    example_print_log("current = " .. tostring(cmds:getCurrentName()))
    example_print_log("history = " .. cmds:getHistorySize())
end

--@api: LCommandStack:getHistorySize
do
    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function()
    end, function()
    end)
    cmds:execute("step2", function()
    end, function()
    end)
    example_print_log("history = " .. cmds:getHistorySize())
    example_print_log("can undo = " .. tostring(cmds:canUndo()))
end

--@api: LCommandStack:clearAll
do
    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function()
    end, function()
    end)
    cmds:execute("step2", function()
    end, function()
    end)
    example_print_log("before = " .. cmds:getHistorySize())
    cmds:clearAll()
    example_print_log("after = " .. cmds:getHistorySize())
end

--@api: lurek.patterns.newBehaviorTree
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
    example_print_log("result = " .. bt:tick())
    example_print_log("nodes = " .. bt:nodeCount())
end

--@api: LBehaviorTree:addSequence
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local check = bt:addLeaf("check")
    bt:addChild(root, check)
    bt:setLeaf("check", function()
        return "success"
    end)
    bt:setRoot(root)
    example_print_log("result = " .. bt:tick())
    example_print_log("nodes = " .. bt:nodeCount())
end

--@api: LBehaviorTree:addSelector
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
    example_print_log("result = " .. bt:tick())
    example_print_log("nodes = " .. bt:nodeCount())
end

--@api: LBehaviorTree:addLeaf
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local act = bt:addLeaf("act")
    bt:addChild(root, act)
    bt:setLeaf("act", function()
        return "success"
    end)
    bt:setRoot(root)
    example_print_log("result = " .. bt:tick())
    example_print_log("nodes = " .. bt:nodeCount())
end

--@api: LBehaviorTree:setLeaf
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local act = bt:addLeaf("act")
    bt:addChild(root, act)
    bt:setLeaf("act", function()
        example_print_log("leaf fired")
        return "success"
    end)
    bt:setRoot(root)
    example_print_log("result = " .. bt:tick())
    example_print_log("nodes = " .. bt:nodeCount())
end

--@api: LBehaviorTree:tick
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local act = bt:addLeaf("act")
    bt:addChild(root, act)
    bt:setLeaf("act", function()
        return "success"
    end)
    bt:setRoot(root)
    example_print_log("result = " .. bt:tick())
    example_print_log("nodes = " .. bt:nodeCount())
end

--@api: LBehaviorTree:resetState
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local act = bt:addLeaf("act")
    bt:addChild(root, act)
    bt:setLeaf("act", function()
        return "running"
    end)
    bt:setRoot(root)
    example_print_log("first = " .. bt:tick())
    bt:resetState()
    example_print_log("after reset = " .. bt:tick())
end

--@api: LBehaviorTree:addParallel
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
    example_print_log("result = " .. bt:tick())
    example_print_log("nodes = " .. bt:nodeCount())
end

--@api: LBehaviorTree:addInverter
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addInverter("invert")
    local check = bt:addLeaf("check")
    bt:addChild(root, check)
    bt:setLeaf("check", function()
        return "failure"
    end)
    bt:setRoot(root)
    example_print_log("result = " .. bt:tick())
    example_print_log("nodes = " .. bt:nodeCount())
end

--@api: LBehaviorTree:addRepeat
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
    example_print_log("result = " .. bt:tick())
    example_print_log("calls = " .. calls)
end

--@api: LBehaviorTree:clearAll
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSelector("root")
    local idle = bt:addLeaf("idle")
    bt:addChild(root, idle)
    bt:setRoot(root)
    example_print_log("before = " .. bt:nodeCount())
    bt:clearAll()
    example_print_log("after = " .. bt:nodeCount())
end

--@api: lurek.patterns.newBlackboard
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("health", 100)
    bb:set("mode", "idle")
    example_print_log("health = " .. tostring(bb:get("health")))
    example_print_log("keys = " .. #bb:keys())
end

--@api: LBlackboard:set
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("score", 10)
    bb:set("score", 20)
    example_print_log("score = " .. tostring(bb:get("score")))
    example_print_log("revision = " .. bb:getRevision())
end

--@api: LBlackboard:get
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("weapon", "sword")
    bb:set("ammo", 12)
    local weapon = bb:get("weapon")
    local ammo = bb:get("ammo")
    local has_weapon = bb:has("weapon")
    patterns_log("blackboard weapon=" .. tostring(weapon) .. " ammo=" .. tostring(ammo) .. " has_weapon=" .. tostring(has_weapon))
end

--@api: LBlackboard:has
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("alive", true)
    bb:set("stance", "guard")
    local has_alive = bb:has("alive")
    local has_mana = bb:has("mana")
    local stance = bb:get("stance")
    patterns_log("blackboard alive=" .. tostring(has_alive) .. " mana=" .. tostring(has_mana) .. " stance=" .. tostring(stance))
end

--@api: LBlackboard:keys
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("health", 100)
    bb:set("weapon", "sword")
    local keys = bb:keys()
    example_print_log("keys = " .. #keys)
    example_print_log("first = " .. tostring(keys[1]))
end

--@api: LBlackboard:watch
do
    local bb = lurek.patterns.newBlackboard("game_state")
    local watch_id = bb:watch("score", function(key, value)
        example_print_log(key .. " = " .. tostring(value))
    end)
    bb:set("score", 10)
    bb:set("score", 25)
    example_print_log("revision = " .. bb:getRevision())
    bb:unwatch(watch_id)
end

--@api: LBlackboard:unwatch
do
    local bb = lurek.patterns.newBlackboard("game_state")
    local watch_id = bb:watch("score", function(key, value)
        example_print_log(key .. " = " .. tostring(value))
    end)
    bb:set("score", 10)
    bb:unwatch(watch_id)
    bb:set("score", 20)
    example_print_log("revision = " .. bb:getRevision())
end

--@api: LBlackboard:getRevision
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("score", 10)
    bb:set("score", 20)
    example_print_log("revision = " .. bb:getRevision())
    example_print_log("score = " .. tostring(bb:get("score")))
end

--@api: LBlackboard:snapshot
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("score", 42)
    bb:set("weapon", "sword")
    local snap = bb:snapshot()
    example_print_log("score = " .. tostring(snap.score))
    example_print_log("weapon = " .. tostring(snap.weapon))
end

--@api: LBlackboard:clear
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("score", 42)
    example_print_log("before = " .. tostring(bb:has("score")))
    bb:clear("score")
    example_print_log("after = " .. tostring(bb:has("score")))
end

--@api: LBlackboard:clearAll
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("score", 42)
    bb:set("weapon", "sword")
    example_print_log("before = " .. #bb:keys())
    bb:clearAll()
    example_print_log("after = " .. #bb:keys())
end

--- Patterns Module Part 3: observer, event bus, mediator, debounce, throttle, funnel

--@api: lurek.patterns.newObserver
do
    local obs = lurek.patterns.newObserver("player_stats")
    local id = obs:subscribe("hp", function(key, value)
        example_print_log(key .. " = " .. tostring(value))
    end)
    obs:set("hp", 100)
    example_print_log("hp = " .. tostring(obs:get("hp")))
    obs:unsubscribe(id)
end

--@api: LObserver:set
do
    local obs = lurek.patterns.newObserver("player_stats")
    local id = obs:subscribe("hp", function(key, value)
        example_print_log(key .. " = " .. tostring(value))
    end)
    obs:set("hp", 100)
    obs:set("hp", 75)
    example_print_log("hp = " .. tostring(obs:get("hp")))
    obs:unsubscribe(id)
end

--@api: LObserver:get
do
    local obs = lurek.patterns.newObserver("player_stats")
    obs:set("hp", 90)
    obs:set("armor", 12)
    local hp = obs:get("hp")
    local armor = obs:get("armor")
    local subs = obs:getCount()
    patterns_log("observer hp=" .. tostring(hp) .. " armor=" .. tostring(armor) .. " subscribers=" .. tostring(subs))
end

--@api: LObserver:subscribe
do
    local obs = lurek.patterns.newObserver("player_stats")
    local id = obs:subscribe("hp", function(key, value)
        example_print_log(key .. " = " .. tostring(value))
    end)
    obs:set("hp", 100)
    example_print_log("subs = " .. obs:getCount())
    obs:unsubscribe(id)
end

--@api: LObserver:unsubscribe
do
    local obs = lurek.patterns.newObserver("player_stats")
    local id = obs:subscribe("hp", function(key, value)
        example_print_log(key .. " = " .. tostring(value))
    end)
    obs:unsubscribe(id)
    obs:set("hp", 50)
    example_print_log("subs = " .. obs:getCount())
end

--@api: LObserver:getCount
do
    local obs = lurek.patterns.newObserver("player_stats")
    obs:subscribe("score", function(key, value)
        example_print_log(key .. " = " .. tostring(value))
    end, true)
    example_print_log("subs = " .. obs:getCount())
    obs:set("score", 100)
    example_print_log("after = " .. obs:getCount())
end

--@api: lurek.patterns.newEventBus
do
    local bus = lurek.patterns.newEventBus("game_events")
    local id = bus:on("damage", function(amount, source)
        example_print_log("damage = " .. tostring(amount) .. " from " .. tostring(source))
    end)
    bus:emit("damage", 25, "fire")
    example_print_log("listeners = " .. bus:getListenerCount("damage"))
    bus:off(id)
end

--@api: LEventBus:on
do
    local bus = lurek.patterns.newEventBus("game_events")
    local id = bus:on("damage", function(amount, source)
        example_print_log("damage = " .. tostring(amount) .. " from " .. tostring(source))
    end, 1)
    bus:emit("damage", 12, "ice")
    example_print_log("listeners = " .. bus:getListenerCount("damage"))
    bus:off(id)
end

--@api: LEventBus:emit
do
    local bus = lurek.patterns.newEventBus("game_events")
    local id = bus:on("damage", function(amount, source)
        example_print_log("damage = " .. tostring(amount) .. " from " .. tostring(source))
    end)
    bus:emit("damage", 18, "fire")
    example_print_log("events = " .. #bus:getEvents())
    bus:off(id)
end

--@api: LEventBus:off
do
    local bus = lurek.patterns.newEventBus("game_events")
    local id = bus:on("damage", function(amount)
        example_print_log("damage = " .. tostring(amount))
    end)
    bus:off(id)
    bus:emit("damage", 5)
    example_print_log("listeners = " .. bus:getListenerCount("damage"))
end

--@api: LEventBus:getListenerCount
do
    local bus = lurek.patterns.newEventBus("game_events")
    bus:on("spawn", function(id)
        example_print_log("spawn = " .. tostring(id))
    end)
    bus:on("spawn", function(id)
        example_print_log("spawn log = " .. tostring(id))
    end)
    example_print_log("spawn listeners = " .. bus:getListenerCount("spawn"))
    example_print_log("events = " .. #bus:getEvents())
end

--@api: LEventBus:getEvents
do
    local bus = lurek.patterns.newEventBus("game_events")
    bus:on("spawn", function(id)
        example_print_log("spawn = " .. tostring(id))
    end)
    bus:on("hit", function(amount)
        example_print_log("hit = " .. tostring(amount))
    end)
    local events = bus:getEvents()
    example_print_log("events = " .. #events)
    example_print_log("first = " .. tostring(events[1]))
end

--@api: LEventBus:clear
do
    local bus = lurek.patterns.newEventBus("game_events")
    bus:on("spawn", function(id)
        example_print_log("spawn = " .. tostring(id))
    end)
    example_print_log("before = " .. bus:getListenerCount("spawn"))
    bus:clear("spawn")
    example_print_log("after = " .. bus:getListenerCount("spawn"))
end

--@api: LEventBus:clearAll
do
    local bus = lurek.patterns.newEventBus("game_events")
    bus:on("spawn", function(id)
        example_print_log("spawn = " .. tostring(id))
    end)
    bus:on("hit", function(amount)
        example_print_log("hit = " .. tostring(amount))
    end)
    example_print_log("before = " .. #bus:getEvents())
    bus:clearAll()
    example_print_log("after = " .. #bus:getEvents())
end

--@api: lurek.patterns.newMediator
do
    local med = lurek.patterns.newMediator()
    local id = med:on("ui", function(msg, data)
        example_print_log(msg .. " = " .. tostring(data))
    end)
    med:send("ui", "hp", 80)
    example_print_log("channels = " .. #med:channels())
    med:off("ui", id)
end

--@api: LMediator:on
do
    local med = lurek.patterns.newMediator()
    local id = med:on("ui", function(msg, data)
        example_print_log(msg .. " = " .. tostring(data))
    end)
    med:send("ui", "hp", 80)
    example_print_log("handlers = " .. med:handlerCount("ui"))
    med:off("ui", id)
end

--@api: LMediator:send
do
    local med = lurek.patterns.newMediator()
    local id = med:on("ui", function(msg, data)
        example_print_log(msg .. " = " .. tostring(data))
    end)
    med:send("ui", "hp", 80)
    example_print_log("channels = " .. #med:channels())
    med:off("ui", id)
end

--@api: LMediator:off
do
    local med = lurek.patterns.newMediator()
    local id = med:on("ui", function(msg, data)
        example_print_log(msg .. " = " .. tostring(data))
    end)
    med:off("ui", id)
    med:send("ui", "hp", 80)
    example_print_log("handlers = " .. med:handlerCount("ui"))
end

--@api: LMediator:broadcast
do
    local med = lurek.patterns.newMediator()
    med:on("audio", function(msg)
        example_print_log("audio = " .. tostring(msg))
    end)
    med:on("video", function(msg)
        example_print_log("video = " .. tostring(msg))
    end)
    med:broadcast("pause")
    example_print_log("channels = " .. #med:channels())
    example_print_log("audio handlers = " .. med:handlerCount("audio"))
end

--@api: LMediator:channels
do
    local med = lurek.patterns.newMediator()
    med:on("audio", function(msg)
        example_print_log("audio = " .. tostring(msg))
    end)
    med:on("video", function(msg)
        example_print_log("video = " .. tostring(msg))
    end)
    local channels = med:channels()
    example_print_log("channels = " .. #channels)
    example_print_log("first = " .. tostring(channels[1]))
end

--@api: LMediator:handlerCount
do
    local med = lurek.patterns.newMediator()
    med:on("audio", function(msg)
        example_print_log("audio = " .. tostring(msg))
    end)
    med:on("audio", function(msg)
        example_print_log("audio log = " .. tostring(msg))
    end)
    example_print_log("audio handlers = " .. med:handlerCount("audio"))
    example_print_log("channels = " .. #med:channels())
end

--@api: LMediator:removeChannel
do
    local med = lurek.patterns.newMediator()
    med:on("audio", function(msg)
        example_print_log("audio = " .. tostring(msg))
    end)
    example_print_log("before = " .. #med:channels())
    med:removeChannel("audio")
    example_print_log("after = " .. #med:channels())
end

--@api: LMediator:clear
do
    local med = lurek.patterns.newMediator()
    med:on("audio", function(msg)
        example_print_log("audio = " .. tostring(msg))
    end)
    med:on("video", function(msg)
        example_print_log("video = " .. tostring(msg))
    end)
    example_print_log("before = " .. #med:channels())
    med:clear()
    example_print_log("after = " .. #med:channels())
end

--@api: lurek.patterns.newDebounce
do
    local db = lurek.patterns.newDebounce(0.5)
    db:onFire(function()
        example_print_log("debounce fired")
    end)
    db:trigger()
    example_print_log("pending = " .. tostring(db:isPending()))
    db:update(0.6)
    example_print_log("fires = " .. db:getFireCount())
end

--@api: LDebounce:trigger
do
    local db = lurek.patterns.newDebounce(0.5)
    db:onFire(function()
        example_print_log("debounce fired")
    end)
    db:trigger()
    example_print_log("pending = " .. tostring(db:isPending()))
    db:update(0.6)
    example_print_log("fires = " .. db:getFireCount())
end

--@api: LDebounce:update
do
    local db = lurek.patterns.newDebounce(0.5)
    db:onFire(function()
        example_print_log("debounce fired")
    end)
    db:trigger()
    db:update(0.6)
    example_print_log("pending = " .. tostring(db:isPending()))
    example_print_log("fires = " .. db:getFireCount())
end

--@api: LDebounce:onFire
do
    local db = lurek.patterns.newDebounce(0.5)
    db:onFire(function()
        example_print_log("debounce fired")
    end)
    db:trigger()
    db:update(0.6)
    example_print_log("fires = " .. db:getFireCount())
    example_print_log("pending = " .. tostring(db:isPending()))
end

--@api: LDebounce:cancel
do
    local db = lurek.patterns.newDebounce(1.0)
    db:onFire(function()
        example_print_log("debounce fired")
    end)
    db:trigger()
    example_print_log("pending = " .. tostring(db:isPending()))
    db:cancel()
    db:update(1.1)
    example_print_log("fires = " .. db:getFireCount())
end

--@api: LDebounce:isPending
do
    local db = lurek.patterns.newDebounce(1.0)
    db:onFire(function()
        example_print_log("debounce fired")
    end)
    db:trigger()
    example_print_log("pending = " .. tostring(db:isPending()))
    db:update(0.2)
    example_print_log("fires = " .. db:getFireCount())
end

--@api: LDebounce:getFireCount
do
    local db = lurek.patterns.newDebounce(0.3)
    db:onFire(function()
        example_print_log("debounce fired")
    end)
    db:trigger()
    db:update(0.4)
    example_print_log("fires = " .. db:getFireCount())
    example_print_log("pending = " .. tostring(db:isPending()))
end

--@api: lurek.patterns.newThrottle
do
    local th = lurek.patterns.newThrottle(0.2)
    local fires = 0
    th:onFire(function()
        fires = fires + 1
        example_print_log("throttle fired = " .. fires)
    end)
    th:update(0.1)
    th:update(0.1)
    th:update(0.2)
    example_print_log("fires = " .. th:getFireCount())
end

--@api: LThrottle:onFire
do
    local th = lurek.patterns.newThrottle(0.2)
    local fires = 0
    th:onFire(function()
        fires = fires + 1
        example_print_log("throttle fired = " .. fires)
    end)
    th:update(0.2)
    th:update(0.2)
    example_print_log("fires = " .. th:getFireCount())
end

--@api: LThrottle:update
do
    local th = lurek.patterns.newThrottle(0.2)
    local fires = 0
    th:onFire(function()
        fires = fires + 1
        example_print_log("throttle fired = " .. fires)
    end)
    th:update(0.1)
    th:update(0.1)
    example_print_log("fires = " .. th:getFireCount())
end

--@api: LThrottle:getFireCount
do
    local th = lurek.patterns.newThrottle(0.2)
    th:onFire(function()
        example_print_log("throttle fired")
    end)
    th:update(0.2)
    th:update(0.2)
    example_print_log("fires = " .. th:getFireCount())
    example_print_log("progress = " .. th:getProgress())
end

--@api: LThrottle:reset
do
    local th = lurek.patterns.newThrottle(1.0)
    th:onFire(function()
        example_print_log("throttle fired")
    end)
    th:update(0.5)
    example_print_log("progress = " .. th:getProgress())
    th:reset()
    example_print_log("after reset = " .. th:getProgress())
end

--@api: LThrottle:setEnabled
do
    local th = lurek.patterns.newThrottle(1.0)
    th:onFire(function()
        example_print_log("throttle fired")
    end)
    th:setEnabled(false)
    th:update(2.0)
    example_print_log("fires = " .. th:getFireCount())
    example_print_log("progress = " .. th:getProgress())
end

--@api: LThrottle:getProgress
do
    local th = lurek.patterns.newThrottle(1.0)
    th:onFire(function()
        example_print_log("throttle fired")
    end)
    th:update(0.5)
    example_print_log("progress = " .. th:getProgress())
    th:update(0.5)
    example_print_log("fires = " .. th:getFireCount())
end

--@api: lurek.patterns.newFunnel
do
    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries)
        example_print_log("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    example_print_log("pending = " .. funnel:pendingCount())
    funnel:update(1.1)
    example_print_log("flush count = " .. funnel:getFlushCount())
end

--@api: LFunnel:push
do
    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries)
        example_print_log("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    example_print_log("pending = " .. funnel:pendingCount())
    funnel:update(1.1)
    example_print_log("flush count = " .. funnel:getFlushCount())
end

--@api: LFunnel:update
do
    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries)
        example_print_log("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:update(1.1)
    example_print_log("pending = " .. funnel:pendingCount())
    example_print_log("flush count = " .. funnel:getFlushCount())
end

--@api: LFunnel:onFlush
do
    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries)
        example_print_log("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:update(1.1)
    example_print_log("pending = " .. funnel:pendingCount())
    example_print_log("flush count = " .. funnel:getFlushCount())
end

--@api: LFunnel:flush
do
    local funnel = lurek.patterns.newFunnel(5.0, 0, "damage_log")
    funnel:onFlush(function(entries)
        example_print_log("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:flush()
    example_print_log("pending = " .. funnel:pendingCount())
    example_print_log("flush count = " .. funnel:getFlushCount())
end

--@api: LFunnel:discard
do
    local funnel = lurek.patterns.newFunnel(5.0, 0, "damage_log")
    funnel:onFlush(function(entries)
        example_print_log("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:discard()
    example_print_log("pending = " .. funnel:pendingCount())
    example_print_log("flush count = " .. funnel:getFlushCount())
end

--@api: LFunnel:pendingCount
do
    local funnel = lurek.patterns.newFunnel(5.0, 0, "damage_log")
    funnel:onFlush(function(entries)
        example_print_log("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    example_print_log("pending = " .. funnel:pendingCount())
    example_print_log("flush count = " .. funnel:getFlushCount())
end

--@api: LFunnel:getFlushCount
do
    local funnel = lurek.patterns.newFunnel(5.0, 0, "damage_log")
    funnel:onFlush(function(entries)
        example_print_log("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:flush()
    example_print_log("pending = " .. funnel:pendingCount())
    example_print_log("flush count = " .. funnel:getFlushCount())
end

--- Patterns Module Part 4: graph, collections (list, map, set, stack, queue, ring, priority queue, weighted random, relationships)

--@api: lurek.patterns.newGraph
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("A", {cost = 10})
    local b = g:addNode("B", {cost = 5})
    g:addEdge(a, b, 1.5, "road")
    example_print_log("nodes = " .. g:nodeCount())
    example_print_log("edges = " .. g:edgeCount())
end

--@api: LPatternGraph:addNode
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("A", {cost = 10})
    local b = g:addNode("B", {cost = 5})
    g:addEdge(a, b, 1.0, "road")
    example_print_log("nodes = " .. g:nodeCount())
    example_print_log("has a = " .. tostring(g:hasNode(a)))
end

--@api: LPatternGraph:addEdge
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("A")
    local b = g:addNode("B")
    g:addEdge(a, b, 2.5, "road")
    example_print_log("nodes = " .. g:nodeCount())
    example_print_log("edges = " .. g:edgeCount())
end

--@api: LPatternGraph:nodeCount
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("A")
    local b = g:addNode("B")
    g:addEdge(a, b, 1.0, "road")
    example_print_log("nodes = " .. g:nodeCount())
    example_print_log("edges = " .. g:edgeCount())
end

--@api: LPatternGraph:edgeCount
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("A")
    local b = g:addNode("B")
    g:addEdge(a, b, 1.0, "road")
    example_print_log("nodes = " .. g:nodeCount())
    example_print_log("edges = " .. g:edgeCount())
end

--@api: LPatternGraph:bfs
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("start")
    local b = g:addNode("mid")
    local c = g:addNode("end")
    g:addEdge(a, b)
    g:addEdge(b, c)
    local order = g:bfs(a)
    example_print_log("bfs = " .. #order)
    example_print_log("connected = " .. tostring(g:isConnected(a, c)))
end

--@api: LPatternGraph:dfs
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("start")
    local b = g:addNode("mid")
    local c = g:addNode("end")
    g:addEdge(a, b)
    g:addEdge(b, c)
    local order = g:dfs(a)
    example_print_log("dfs = " .. #order)
    example_print_log("connected = " .. tostring(g:isConnected(a, c)))
end

--@api: LPatternGraph:isConnected
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("start")
    local b = g:addNode("mid")
    local c = g:addNode("end")
    g:addEdge(a, b)
    g:addEdge(b, c)
    example_print_log("start to end = " .. tostring(g:isConnected(a, c)))
    example_print_log("start to start = " .. tostring(g:isConnected(a, a)))
end

--@api: LPatternGraph:neighbors
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("start")
    local b = g:addNode("mid")
    local c = g:addNode("end")
    g:addEdge(a, b)
    g:addEdge(b, c)
    local neighbors = g:neighbors(b)
    example_print_log("neighbors = " .. #neighbors)
    example_print_log("has b = " .. tostring(g:hasNode(b)))
end

--@api: LPatternGraph:hasNode
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("start")
    local b = g:addNode("mid")
    g:addEdge(a, b)
    example_print_log("has a = " .. tostring(g:hasNode(a)))
    example_print_log("has 99 = " .. tostring(g:hasNode(99)))
end

--@api: LPatternGraph:getNodeValue
do
    local g = lurek.patterns.newGraph()
    local a = g:addNode("room", {size = 10})
    local b = g:addNode("hall")
    local edge = g:addEdge(a, b, 2.0, "door")
    local value = g:getNodeValue(a)
    example_print_log("room size = " .. tostring(value and value.size))
    example_print_log("edges = " .. g:edgeCount())
end

--@api: LPatternGraph:removeNode
do
    local g = lurek.patterns.newGraph()
    local a = g:addNode("room", {size = 10})
    local b = g:addNode("hall")
    g:addEdge(a, b, 2.0, "door")
    g:removeNode(b)
    example_print_log("nodes = " .. g:nodeCount())
    example_print_log("has hall = " .. tostring(g:hasNode(b)))
end

--@api: LPatternGraph:removeEdge
do
    local g = lurek.patterns.newGraph()
    local a = g:addNode("room")
    local b = g:addNode("hall")
    local edge = g:addEdge(a, b, 2.0, "door")
    g:removeEdge(edge)
    example_print_log("edges = " .. g:edgeCount())
    example_print_log("nodes = " .. g:nodeCount())
end

--@api: LPatternGraph:clearAll
do
    local g = lurek.patterns.newGraph()
    local a = g:addNode("room")
    local b = g:addNode("hall")
    g:addEdge(a, b, 2.0, "door")
    example_print_log("before = " .. g:nodeCount())
    g:clearAll()
    example_print_log("after = " .. g:nodeCount())
end

--@api: lurek.patterns.newList
do
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    example_print_log("len = " .. list:len())
    example_print_log("second = " .. tostring(list:get(2)))
end

--@api: LList:add
do
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    example_print_log("len = " .. list:len())
    example_print_log("second = " .. tostring(list:get(2)))
end

--@api: LList:get
do
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    example_print_log("second = " .. tostring(list:get(2)))
    example_print_log("len = " .. list:len())
end

--@api: LList:len
do
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    example_print_log("len = " .. list:len())
    example_print_log("beta = " .. tostring(list:indexOf("beta")))
end

--@api: LList:remove
do
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    local removed = list:remove(2)
    example_print_log("removed = " .. tostring(removed))
    example_print_log("len = " .. list:len())
end

--@api: LList:indexOf
do
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    example_print_log("beta = " .. tostring(list:indexOf("beta")))
    example_print_log("delta = " .. tostring(list:indexOf("delta")))
end

--@api: LList:push
do
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    example_print_log("len = " .. list:len())
    example_print_log("last = " .. tostring(list:get(3)))
end

--@api: LList:pop
do
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    local popped = list:pop()
    example_print_log("popped = " .. tostring(popped))
    example_print_log("len = " .. list:len())
end

--@api: LList:insert
do
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("c")
    list:insert(2, "b")
    example_print_log("second = " .. tostring(list:get(2)))
    example_print_log("len = " .. list:len())
end

--@api: LList:set
do
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:set(2, "B")
    example_print_log("second = " .. tostring(list:get(2)))
    example_print_log("len = " .. list:len())
end

--@api: LList:shift
do
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    local shifted = list:shift()
    example_print_log("shifted = " .. tostring(shifted))
    example_print_log("len = " .. list:len())
end

--@api: LList:unshift
do
    local list = lurek.patterns.newList()
    list:push("b")
    list:push("c")
    list:unshift("a")
    example_print_log("first = " .. tostring(list:get(1)))
    example_print_log("len = " .. list:len())
end

--@api: LList:contains
do
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    example_print_log("contains b = " .. tostring(list:contains("b")))
    example_print_log("contains z = " .. tostring(list:contains("z")))
end

--@api: LList:reverse
do
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    list:reverse()
    example_print_log("first = " .. tostring(list:get(1)))
    example_print_log("last = " .. tostring(list:get(3)))
end

--@api: LList:toArray
do
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    local arr = list:toArray()
    example_print_log("array = " .. #arr)
    example_print_log("first = " .. tostring(arr[1]))
end

--@api: LList:isEmpty
do
    local list = lurek.patterns.newList()
    local before = list:isEmpty()
    list:push("a")
    list:push("b")
    local after = list:isEmpty()
    local count = list:len()
    patterns_log("list empty_before=" .. tostring(before) .. " empty_after=" .. tostring(after) .. " count=" .. tostring(count))
end

--@api: lurek.patterns.newMap
do
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    example_print_log("name = " .. tostring(map:get("name")))
    example_print_log("len = " .. map:len())
end

--@api: LMap:set
do
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    example_print_log("name = " .. tostring(map:get("name")))
    example_print_log("len = " .. map:len())
end

--@api: LMap:get
do
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    example_print_log("name = " .. tostring(map:get("name")))
    example_print_log("has level = " .. tostring(map:has("level")))
end

--@api: LMap:has
do
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    example_print_log("has level = " .. tostring(map:has("level")))
    example_print_log("has class = " .. tostring(map:has("class")))
end

--@api: LMap:remove
do
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("class", "warrior")
    map:remove("class")
    example_print_log("has class = " .. tostring(map:has("class")))
    example_print_log("len = " .. map:len())
end

--@api: LMap:keys
do
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    local keys = map:keys()
    example_print_log("keys = " .. #keys)
    example_print_log("first = " .. tostring(keys[1]))
end

--@api: LMap:values
do
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    local values = map:values()
    example_print_log("values = " .. #values)
    example_print_log("first = " .. tostring(values[1]))
end

--@api: LMap:len
do
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    example_print_log("len = " .. map:len())
    example_print_log("has name = " .. tostring(map:has("name")))
end

--@api: LMap:entries
do
    local map = lurek.patterns.newMap()
    map:set("a", 1)
    map:set("b", 2)
    local entries = map:entries()
    example_print_log("entries = " .. #entries)
    example_print_log("len = " .. map:len())
end

--@api: LMap:merge
do
    local m1 = lurek.patterns.newMap()
    local m2 = lurek.patterns.newMap()
    m1:set("a", 1)
    m2:set("b", 2)
    m1:merge(m2)
    example_print_log("len = " .. m1:len())
    example_print_log("b = " .. tostring(m1:get("b")))
end

--@api: LMap:isEmpty
do
    local map = lurek.patterns.newMap()
    local before = map:isEmpty()
    map:set("a", 1)
    map:set("b", 2)
    local after = map:isEmpty()
    local count = map:len()
    patterns_log("map empty_before=" .. tostring(before) .. " empty_after=" .. tostring(after) .. " count=" .. tostring(count))
end

--@api: LMap:clear
do
    local map = lurek.patterns.newMap()
    map:set("a", 1)
    map:set("b", 2)
    example_print_log("before = " .. map:len())
    map:clear()
    example_print_log("after = " .. map:len())
end

--@api: lurek.patterns.newSet
do
    local set = lurek.patterns.newSet()
    set:add("fire")
    set:add("ice")
    example_print_log("len = " .. set:len())
    example_print_log("has fire = " .. tostring(set:has("fire")))
end

--@api: LSet:add
do
    local set = lurek.patterns.newSet()
    set:add("fire")
    set:add("ice")
    example_print_log("len = " .. set:len())
    example_print_log("has fire = " .. tostring(set:has("fire")))
end

--@api: LSet:has
do
    local set = lurek.patterns.newSet()
    set:add("fire")
    set:add("ice")
    example_print_log("has fire = " .. tostring(set:has("fire")))
    example_print_log("has wind = " .. tostring(set:has("wind")))
end

--@api: LSet:remove
do
    local set = lurek.patterns.newSet()
    set:add("fire")
    set:add("ice")
    set:remove("ice")
    example_print_log("has ice = " .. tostring(set:has("ice")))
    example_print_log("len = " .. set:len())
end

--@api: LSet:len
do
    local set = lurek.patterns.newSet()
    set:add("fire")
    set:add("ice")
    set:add("wind")
    example_print_log("len = " .. set:len())
    example_print_log("has fire = " .. tostring(set:has("fire")))
end

--@api: LSet:toArray
do
    local set = lurek.patterns.newSet()
    set:add("fire")
    set:add("ice")
    local arr = set:toArray()
    example_print_log("array = " .. #arr)
    example_print_log("len = " .. set:len())
end

--@api: LSet:union
do
    local a = lurek.patterns.newSet()
    local b = lurek.patterns.newSet()
    a:add("x")
    a:add("y")
    b:add("y")
    b:add("z")
    local union = a:union(b)
    example_print_log("union = " .. union:len())
    example_print_log("intersection = " .. a:intersection(b):len())
end

--@api: LSet:intersection
do
    local a = lurek.patterns.newSet()
    local b = lurek.patterns.newSet()
    a:add("x")
    a:add("y")
    b:add("y")
    b:add("z")
    local inter = a:intersection(b)
    example_print_log("intersection = " .. inter:len())
    example_print_log("union = " .. a:union(b):len())
end

--@api: LSet:isEmpty
do
    local set = lurek.patterns.newSet()
    local before = set:isEmpty()
    set:add("x")
    set:add("y")
    local after = set:isEmpty()
    local count = set:len()
    patterns_log("set empty_before=" .. tostring(before) .. " empty_after=" .. tostring(after) .. " count=" .. tostring(count))
end

--@api: LSet:clear
do
    local set = lurek.patterns.newSet()
    set:add("x")
    set:add("y")
    example_print_log("before = " .. set:len())
    set:clear()
    example_print_log("after = " .. set:len())
end

--@api: lurek.patterns.newStack
do
    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    example_print_log("peek = " .. tostring(st:peek()))
    example_print_log("len = " .. st:len())
end

--@api: LStack:push
do
    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    example_print_log("peek = " .. tostring(st:peek()))
    example_print_log("len = " .. st:len())
end

--@api: LStack:pop
do
    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    local value = st:pop()
    example_print_log("popped = " .. tostring(value))
    example_print_log("len = " .. st:len())
end

--@api: LStack:peek
do
    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    example_print_log("peek = " .. tostring(st:peek()))
    example_print_log("len = " .. st:len())
end

--@api: LStack:len
do
    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    example_print_log("len = " .. st:len())
    example_print_log("empty = " .. tostring(st:isEmpty()))
end

--@api: LStack:isEmpty
do
    local st = lurek.patterns.newStack(100)
    local before = st:isEmpty()
    st:push("first")
    st:push("second")
    local after = st:isEmpty()
    local top = st:peek()
    patterns_log("stack empty_before=" .. tostring(before) .. " empty_after=" .. tostring(after) .. " top=" .. tostring(top))
end

--@api: LStack:pushBottom
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:pushBottom("z")
    example_print_log("bottom = " .. tostring(st:peekBottom()))
    example_print_log("len = " .. st:len())
end

--@api: LStack:popBottom
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:pushBottom("z")
    local value = st:popBottom()
    example_print_log("bottom = " .. tostring(value))
    example_print_log("len = " .. st:len())
end

--@api: LStack:peekBottom
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:pushBottom("z")
    example_print_log("bottom = " .. tostring(st:peekBottom()))
    example_print_log("len = " .. st:len())
end

--@api: LStack:peekAt
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    example_print_log("at 2 = " .. tostring(st:peekAt(2)))
    example_print_log("len = " .. st:len())
end

--@api: LStack:insertAt
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("c")
    st:insertAt(2, "b")
    example_print_log("at 2 = " .. tostring(st:peekAt(2)))
    example_print_log("len = " .. st:len())
end

--@api: LStack:removeAt
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    local value = st:removeAt(2)
    example_print_log("removed = " .. tostring(value))
    example_print_log("len = " .. st:len())
end

--@api: LStack:popMany
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    local values = st:popMany(2)
    example_print_log("count = " .. #values)
    example_print_log("len = " .. st:len())
end

--@api: LStack:moveWithin
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    st:moveWithin(1, 3)
    local arr = st:toArray()
    example_print_log("first = " .. tostring(arr[1]))
    example_print_log("last = " .. tostring(arr[#arr]))
end

--@api: LStack:isFull
do
    local st = lurek.patterns.newStack(2)
    st:push("a")
    st:push("b")
    example_print_log("full = " .. tostring(st:isFull()))
    example_print_log("len = " .. st:len())
end

--@api: LStack:clear
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    example_print_log("before = " .. st:len())
    st:clear()
    example_print_log("after = " .. st:len())
end

--@api: LStack:toArray
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    local arr = st:toArray()
    example_print_log("array = " .. #arr)
    example_print_log("first = " .. tostring(arr[1]))
end

--@api: lurek.patterns.newQueue
do
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    example_print_log("front = " .. tostring(q:front()))
    example_print_log("len = " .. q:len())
end

--@api: LQueue:enqueue
do
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    example_print_log("front = " .. tostring(q:front()))
    example_print_log("len = " .. q:len())
end

--@api: LQueue:dequeue
do
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    local value = q:dequeue()
    example_print_log("dequeued = " .. tostring(value))
    example_print_log("len = " .. q:len())
end

--@api: LQueue:front
do
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    example_print_log("front = " .. tostring(q:front()))
    example_print_log("back = " .. tostring(q:back()))
end

--@api: LQueue:back
do
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    example_print_log("back = " .. tostring(q:back()))
    example_print_log("len = " .. q:len())
end

--@api: LQueue:len
do
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    example_print_log("len = " .. q:len())
    example_print_log("empty = " .. tostring(q:isEmpty()))
end

--@api: LQueue:isEmpty
do
    local q = lurek.patterns.newQueue(10)
    local before = q:isEmpty()
    q:enqueue("msg1")
    q:enqueue("msg2")
    local after = q:isEmpty()
    local front = q:front()
    patterns_log("queue empty_before=" .. tostring(before) .. " empty_after=" .. tostring(after) .. " front=" .. tostring(front))
end

--@api: LQueue:enqueueFront
do
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueueFront("priority")
    example_print_log("front = " .. tostring(q:front()))
    example_print_log("len = " .. q:len())
end

--@api: LQueue:dequeueBack
do
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    local value = q:dequeueBack()
    example_print_log("dequeued back = " .. tostring(value))
    example_print_log("len = " .. q:len())
end

--@api: LQueue:insertAt
do
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("c")
    q:insertAt(2, "b")
    example_print_log("at 2 = " .. tostring(q:peekAt(2)))
    example_print_log("len = " .. q:len())
end

--@api: LQueue:removeAt
do
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    local value = q:removeAt(2)
    example_print_log("removed = " .. tostring(value))
    example_print_log("len = " .. q:len())
end

--@api: LQueue:peekAt
do
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    example_print_log("at 2 = " .. tostring(q:peekAt(2)))
    example_print_log("len = " .. q:len())
end

--@api: LQueue:isFull
do
    local q = lurek.patterns.newQueue(2)
    q:enqueue("a")
    q:enqueue("b")
    example_print_log("full = " .. tostring(q:isFull()))
    example_print_log("len = " .. q:len())
end

--@api: LQueue:clear
do
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    example_print_log("before = " .. q:len())
    q:clear()
    example_print_log("after = " .. q:len())
end

--@api: LQueue:toArray
do
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    local arr = q:toArray()
    example_print_log("array = " .. #arr)
    example_print_log("first = " .. tostring(arr[1]))
end

--@api: lurek.patterns.newPriorityQueue
do
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    example_print_log("peek = " .. tostring(pq:peek()))
    example_print_log("len = " .. pq:len())
end

--@api: LPriorityQueue:push
do
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    example_print_log("peek = " .. tostring(pq:peek()))
    example_print_log("len = " .. pq:len())
end

--@api: LPriorityQueue:pop
do
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    local value = pq:pop()
    example_print_log("popped = " .. tostring(value))
    example_print_log("len = " .. pq:len())
end

--@api: LPriorityQueue:peek
do
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    example_print_log("peek = " .. tostring(pq:peek()))
    example_print_log("len = " .. pq:len())
end

--@api: LPriorityQueue:len
do
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    example_print_log("len = " .. pq:len())
    example_print_log("empty = " .. tostring(pq:isEmpty()))
end

--@api: LPriorityQueue:isEmpty
do
    local pq = lurek.patterns.newPriorityQueue("tasks")
    local before = pq:isEmpty()
    pq:push(10, "high_task", "high")
    pq:push(1, "low_task", "low")
    local after = pq:isEmpty()
    local top = pq:peek()
    patterns_log("priority queue empty_before=" .. tostring(before) .. " empty_after=" .. tostring(after) .. " top=" .. tostring(top))
end

--@api: LPriorityQueue:clearAll
do
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    example_print_log("before = " .. pq:len())
    pq:clearAll()
    example_print_log("after = " .. pq:len())
end

--@api: lurek.patterns.newRing
do
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    example_print_log("len = " .. ring:len())
    example_print_log("average = " .. ring:average())
end

--@api: LRing:push
do
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    example_print_log("len = " .. ring:len())
    example_print_log("sum = " .. ring:sum())
end

--@api: LRing:len
do
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    example_print_log("len = " .. ring:len())
    example_print_log("full = " .. tostring(ring:isFull()))
end

--@api: LRing:latest
do
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    local entry = ring:latest()
    example_print_log("latest = " .. tostring(entry and entry.value))
    example_print_log("len = " .. ring:len())
end

--@api: LRing:isFull
do
    local ring = lurek.patterns.newRing(3, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    example_print_log("full = " .. tostring(ring:isFull()))
    example_print_log("len = " .. ring:len())
end

--@api: LRing:sum
do
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    example_print_log("sum = " .. ring:sum())
    example_print_log("len = " .. ring:len())
end

--@api: LRing:average
do
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    example_print_log("average = " .. ring:average())
    example_print_log("len = " .. ring:len())
end

--@api: LRing:toArray
do
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    local arr = ring:toArray()
    example_print_log("array = " .. #arr)
    example_print_log("latest = " .. tostring(ring:latest() and ring:latest().value))
end

--@api: LRing:clear
do
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    example_print_log("before = " .. ring:len())
    ring:clear()
    example_print_log("after = " .. ring:len())
end

--@api: lurek.patterns.newWeightedRandom
do
    local wr = lurek.patterns.newWeightedRandom()
    wr:add(10, "common", "common_loot")
    wr:add(3, "rare", "rare_loot")
    example_print_log("items = " .. wr:len())
    example_print_log("picked = " .. tostring(wr:pick(0.5)))
end

--@api: LWeightedRandom:add
do
    local wr = lurek.patterns.newWeightedRandom()
    wr:add(10, "common", "common_loot")
    wr:add(3, "rare", "rare_loot")
    example_print_log("items = " .. wr:len())
    example_print_log("total = " .. wr:totalWeight())
end

--@api: LWeightedRandom:pick
do
    local wr = lurek.patterns.newWeightedRandom()
    wr:add(10, "common", "common_loot")
    wr:add(3, "rare", "rare_loot")
    example_print_log("picked = " .. tostring(wr:pick(0.5)))
    example_print_log("items = " .. wr:len())
end

--@api: LWeightedRandom:pickN
do
    local wr = lurek.patterns.newWeightedRandom()
    wr:add(10, "common", "common_loot")
    wr:add(3, "rare", "rare_loot")
    wr:add(1, "legendary", "legendary_loot")
    local values = wr:pickN(2, {0.1, 0.9})
    example_print_log("count = " .. #values)
    example_print_log("items = " .. wr:len())
end

--@api: LWeightedRandom:len
do
    local wr = lurek.patterns.newWeightedRandom()
    wr:add(10, "common", "common_loot")
    wr:add(3, "rare", "rare_loot")
    example_print_log("items = " .. wr:len())
    example_print_log("total = " .. wr:totalWeight())
end

--@api: LWeightedRandom:totalWeight
do
    local wr = lurek.patterns.newWeightedRandom()
    wr:add(10, "common", "common_loot")
    wr:add(3, "rare", "rare_loot")
    example_print_log("total = " .. wr:totalWeight())
    example_print_log("items = " .. wr:len())
end

--@api: LWeightedRandom:remove
do
    local wr = lurek.patterns.newWeightedRandom()
    local id = wr:add(5, "item_a")
    wr:add(5, "item_b")
    wr:remove(id)
    example_print_log("items = " .. wr:len())
    example_print_log("revision = " .. wr:getRevision())
end

--@api: LWeightedRandom:setWeight
do
    local wr = lurek.patterns.newWeightedRandom()
    local id = wr:add(5, "item_a")
    wr:add(5, "item_b")
    wr:setWeight(id, 20)
    example_print_log("total = " .. wr:totalWeight())
    example_print_log("revision = " .. wr:getRevision())
end

--@api: LWeightedRandom:getRevision
do
    local wr = lurek.patterns.newWeightedRandom()
    local id = wr:add(5, "item_a")
    wr:setWeight(id, 20)
    example_print_log("revision = " .. wr:getRevision())
    example_print_log("items = " .. wr:len())
end

--@api: LWeightedRandom:isEmpty
do
    local wr = lurek.patterns.newWeightedRandom()
    local before = wr:isEmpty()
    wr:add(5, "item_a")
    wr:add(2, "item_b")
    local after = wr:isEmpty()
    local total = wr:totalWeight()
    patterns_log("weighted random empty_before=" .. tostring(before) .. " empty_after=" .. tostring(after) .. " total=" .. tostring(total))
end

--@api: LWeightedRandom:clearAll
do
    local wr = lurek.patterns.newWeightedRandom()
    wr:add(5, "item_a")
    wr:add(5, "item_b")
    example_print_log("before = " .. wr:len())
    wr:clearAll()
    example_print_log("after = " .. wr:len())
end

--@api: lurek.patterns.newRelationshipManager
do
    -- Deprecated alias kept for compatibility. Prefer lurek.ecs.newRelationshipManager().
    local rm = lurek.patterns.newRelationshipManager()
    rm:setValue(1, 2, 50)
    rm:setValue(1, 3, -20)
    example_print_log("1->2 = " .. rm:getValue(1, 2))
    example_print_log("1->3 = " .. rm:getValue(1, 3))
end

--- Patterns Module Part 5: integrated multi-pattern examples, real-world scenarios

--- Patterns Module Part 5: BehaviorTree (addChild/nodeCount/setRoot), LList:clear, LObjectPool counts, LSimpleState:update, LStrategy:getCurrent

--@api: LBehaviorTree:addChild
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
    example_print_log("result = " .. bt:tick())
    example_print_log("node_count = " .. bt:nodeCount())
end

--@api: LBehaviorTree:nodeCount
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
    example_print_log("node_count = " .. bt:nodeCount())
    example_print_log("result = " .. bt:tick())
end

--@api: LBehaviorTree:setRoot
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
    example_print_log("node_count = " .. bt:nodeCount())
    example_print_log("result = " .. bt:tick())
end

--@api: LList:clear
do
    local list = lurek.patterns.newList()
    list:add(1)
    list:add(2)
    list:add(3)
    example_print_log("before = " .. list:len())
    list:clear()
    example_print_log("after = " .. list:len())
end

--@api: LObjectPool:getActiveCount
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1})
    pool:add({id = 2})
    local obj = pool:acquire()
    example_print_log("active = " .. pool:getActiveCount())
    example_print_log("got = " .. tostring(obj and obj.id))
end

--@api: LObjectPool:getAvailableCount
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1})
    pool:add({id = 2})
    pool:acquire()
    example_print_log("available = " .. pool:getAvailableCount())
    example_print_log("total = " .. pool:getTotalCount())
end

--@api: LObjectPool:getTotalCount
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1})
    pool:add({id = 2})
    example_print_log("total = " .. pool:getTotalCount())
    example_print_log("available = " .. pool:getAvailableCount())
end

--@api: LSimpleState:update
do
    local fsm = lurek.patterns.newSimpleState()
    patterns_last_state_dt = 0
    fsm:addState("idle", { update = patterns_record_state_update })
    fsm:addState("pause")
    fsm:transitionTo("idle")
    fsm:update(0.016)
    local current = fsm:getCurrent()
    local state_count = #fsm:getStates()
    patterns_log("state update current=" .. tostring(current) .. " dt_seen=" .. tostring(patterns_last_state_dt) .. " state_count=" .. tostring(state_count))
end

--@api: LStrategy:getCurrent
do
    local strat = lurek.patterns.newStrategy()
    strat:register("attack", function()
        return "attacking"
    end)
    strat:register("flee", function()
        return "fleeing"
    end)
    strat:set("attack")
    example_print_log("current = " .. tostring(strat:getCurrent()))
    example_print_log("result = " .. tostring(strat:execute()))
end
