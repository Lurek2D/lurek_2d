--- Patterns Module Part 5: BehaviorTree (addChild/nodeCount/setRoot), LList:clear, LObjectPool counts, LSimpleState:update, LStrategy:getCurrent

--@api-stub: LBehaviorTree:addChild
--@api-stub: LBehaviorTree:nodeCount
--@api-stub: LBehaviorTree:setRoot
-- Behavior tree node management.
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
--@api-stub: LObjectPool:getAvailableCount
--@api-stub: LObjectPool:getTotalCount
-- Object pool count queries.
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

print("patterns_05.lua")
