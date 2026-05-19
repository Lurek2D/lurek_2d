--- Patterns Module Part 2: FSM, command stack, behavior tree, blackboard

--@api-stub: lurek.patterns.newSimpleState
--@api-stub: LSimpleState:addState
--@api-stub: LSimpleState:transitionTo
--@api-stub: LSimpleState:getCurrent
-- Finite state machine with enter/exit/update callbacks.
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
--@api-stub: LSimpleState:getStates
--@api-stub: LSimpleState:clearAll
-- State queries and reset.
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
--@api-stub: LCommandStack:execute
--@api-stub: LCommandStack:undo
--@api-stub: LCommandStack:redo
-- Command stack for undo/redo.
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
--@api-stub: LCommandStack:canRedo
--@api-stub: LCommandStack:getCurrentName
--@api-stub: LCommandStack:getHistorySize
--@api-stub: LCommandStack:clearAll
-- Command stack queries.
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
--@api-stub: LBehaviorTree:addSequence
--@api-stub: LBehaviorTree:addSelector
--@api-stub: LBehaviorTree:addLeaf
-- Behavior tree node creation.
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
--@api-stub: LBehaviorTree:tick
--@api-stub: LBehaviorTree:resetState
-- Behavior tree execution.
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
--@api-stub: LBehaviorTree:addInverter
--@api-stub: LBehaviorTree:addRepeat
--@api-stub: LBehaviorTree:clearAll
-- Advanced BT nodes.
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
--@api-stub: LBlackboard:set
--@api-stub: LBlackboard:get
--@api-stub: LBlackboard:has
--@api-stub: LBlackboard:keys
-- Shared key-value blackboard.
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
--@api-stub: LBlackboard:unwatch
--@api-stub: LBlackboard:getRevision
--@api-stub: LBlackboard:snapshot
--@api-stub: LBlackboard:clear
--@api-stub: LBlackboard:clearAll
-- Blackboard reactivity and management.
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

print("patterns_01.lua")
