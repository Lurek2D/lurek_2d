--- Patterns Module Part 5: integrated multi-pattern examples, real-world scenarios

--@api-stub: Integration: Factory + Pool + Observer
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

--@api-stub: Integration: FSM + EventBus + Blackboard
-- Combined patterns: FSM transitions emit events, blackboard stores shared state.
do
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
end

--@api-stub: Integration: BehaviorTree + Blackboard + Strategy
-- BT reads blackboard, strategy provides the algorithm.
do
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

--@api-stub: Integration: Mediator + Debounce + Funnel
-- Mediator routes messages, debounce prevents spam, funnel batches.
do
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

--@api-stub: Integration: Graph + WeightedRandom + PriorityQueue
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

--@api-stub: Integration: CommandStack + Observer + Map
-- Undo/redo with change notification and state tracking in map.
do
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

--@api-stub: Integration: Ring + Throttle + EventBus (FPS monitor)
-- Ring stores FPS samples, throttle limits reporting, bus notifies listeners.
do
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

--@api-stub: Integration: Set + List + Graph (dependency resolver)
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

print("patterns_04.lua")
