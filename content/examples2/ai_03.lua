--- AI Examples Part 3: Q-Learning (cont.), Utility AI, GOAP, Influence Maps, Squads

--@api-stub: LQLearner:getExplorationDecay
-- Returns the per-episode multiplicative decay applied to exploration rate.
do
    local ql = lurek.ai.newQLearner(4, 3)
    ql:setExplorationDecay(0.99)
    local decay = ql:getExplorationDecay()
    print("exploration decay = " .. decay)
end

--@api-stub: LQLearner:serialize
-- Serializes the entire Q-table and parameters to a JSON string.
do
    local ql = lurek.ai.newQLearner(3, 2)
    ql:learn(1, 1, 1.0, 2)
    ql:learn(2, 2, 5.0, 1)
    local json = ql:serialize()
    print("serialized length = " .. #json)
end

--@api-stub: LQLearner:deserialize
-- Restores Q-table and parameters from a previously serialized JSON string.
do
    local ql = lurek.ai.newQLearner(3, 2)
    ql:learn(1, 2, 10.0, 3)
    local saved = ql:serialize()
    local ql2 = lurek.ai.newQLearner(3, 2)
    ql2:deserialize(saved)
    local q = ql2:getQValue(1, 2)
    print("restored Q(1,2) = " .. q)
end

--@api-stub: LQLearner:type
-- Returns the type name string "LQLearner".
do
    local ql = lurek.ai.newQLearner(2, 2)
    local t = ql:type()
    print("type = " .. t)
end

--@api-stub: LQLearner:typeOf
-- Checks whether this object is of the given type name.
do
    local ql = lurek.ai.newQLearner(2, 2)
    local yes = ql:typeOf("LQLearner")
    local no = ql:typeOf("LAgent")
    print("is LQLearner = " .. tostring(yes) .. ", is LAgent = " .. tostring(no))
end

--@api-stub: LUtilityAI:addAction
-- Registers a named action with a scorer function and optional weight.
do
    local uai = lurek.ai.newUtilityAI()
    uai:addAction("eat", function() return 0.8 end, 1.0)
    uai:addAction("sleep", function() return 0.3 end, 1.0)
    print("actions added = " .. uai:getActionCount())
end

--@api-stub: LUtilityAI:evaluate
-- Evaluates all actions and returns the name of the highest-scoring one.
do
    local uai = lurek.ai.newUtilityAI()
    uai:addAction("attack", function() return 0.9 end)
    uai:addAction("defend", function() return 0.4 end)
    local chosen = uai:evaluate()
    print("chosen action = " .. tostring(chosen))
end

--@api-stub: LUtilityAI:getActionCount
-- Returns the number of registered actions.
do
    local uai = lurek.ai.newUtilityAI()
    uai:addAction("patrol", function() return 0.5 end)
    uai:addAction("idle", function() return 0.1 end)
    uai:addAction("chase", function() return 0.7 end)
    print("action count = " .. uai:getActionCount())
end

--@api-stub: LUtilityAI:getLastAction
-- Returns the name of the action chosen in the most recent evaluate() call.
do
    local uai = lurek.ai.newUtilityAI()
    uai:addAction("gather", function() return 0.6 end)
    uai:addAction("build", function() return 0.2 end)
    uai:evaluate()
    local last = uai:getLastAction()
    print("last action = " .. tostring(last))
end

--@api-stub: LUtilityAI:addConsideration
-- Attaches a consideration to a named action with a response curve.
do
    local uai = lurek.ai.newUtilityAI()
    uai:addAction("heal", function() return 0.5 end)
    uai:addConsideration("heal", "low_health", function() return 0.9 end, "linear", 1.0, 0.0, 0.0, 1.0)
    uai:evaluate()
    print("consideration added, last = " .. tostring(uai:getLastAction()))
end

--@api-stub: LUtilityAI:type
-- Returns the type name string "LUtilityAI".
do
    local uai = lurek.ai.newUtilityAI()
    print("type = " .. uai:type())
end

--@api-stub: LUtilityAI:typeOf
-- Checks whether this object is of the given type name.
do
    local uai = lurek.ai.newUtilityAI()
    print("is LUtilityAI = " .. tostring(uai:typeOf("LUtilityAI")))
end

--@api-stub: LGOAPPlanner:addAction
-- Registers an action with a name, cost, and callback function.
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addAction("chop_wood", 2, function() print("  chopping wood") end)
    goap:addAction("build_house", 5, function() print("  building house") end)
    print("goap actions = " .. goap:getActionCount())
end

--@api-stub: LGOAPPlanner:setPrecondition
-- Sets a precondition fact that must be true for an action to be usable.
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addAction("cook", 1, function() end)
    goap:setPrecondition("cook", "has_food", true)
    print("precondition set for cook")
end

--@api-stub: LGOAPPlanner:setEffect
-- Sets a world-state effect that an action produces when executed.
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addAction("mine_ore", 3, function() end)
    goap:setEffect("mine_ore", "has_ore", true)
    print("effect set for mine_ore")
end

--@api-stub: LGOAPPlanner:addGoal
-- Registers a named goal with a priority value.
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addGoal("survive", 10)
    goap:addGoal("explore", 3)
    print("goals = " .. goap:getGoalCount())
end

--@api-stub: LGOAPPlanner:setGoalState
-- Defines a required world-state fact for a goal to be satisfied.
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addGoal("build_shelter", 5)
    goap:setGoalState("build_shelter", "shelter_built", true)
    print("goal state set for build_shelter")
end

--@api-stub: LGOAPPlanner:plan
-- Searches for a sequence of actions that transforms the world state to satisfy the highest-priority goal.
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addAction("get_wood", 1, function() end)
    goap:setEffect("get_wood", "has_wood", true)
    goap:addAction("build", 2, function() end)
    goap:setPrecondition("build", "has_wood", true)
    goap:setEffect("build", "house_done", true)
    goap:addGoal("build_house", 10)
    goap:setGoalState("build_house", "house_done", true)
    local plan = goap:plan({ has_wood = false, house_done = false }, 10)
    print("plan steps = " .. #plan)
end

--@api-stub: LGOAPPlanner:getActionCount
-- Returns the number of registered actions.
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addAction("a1", 1, function() end)
    goap:addAction("a2", 2, function() end)
    print("action count = " .. goap:getActionCount())
end

--@api-stub: LGOAPPlanner:getGoalCount
-- Returns the number of registered goals.
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addGoal("g1", 1)
    goap:addGoal("g2", 5)
    goap:addGoal("g3", 3)
    print("goal count = " .. goap:getGoalCount())
end

--@api-stub: LGOAPPlanner:getMaxIterations
-- Returns the current maximum iteration limit for the planner search.
do
    local goap = lurek.ai.newGOAPPlanner()
    local max = goap:getMaxIterations()
    print("default max iterations = " .. max)
end

--@api-stub: LGOAPPlanner:setMaxIterations
-- Sets the maximum iteration limit for the planner search.
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:setMaxIterations(500)
    print("max iterations = " .. goap:getMaxIterations())
end

--@api-stub: LGOAPPlanner:type
-- Returns the type name string "LGOAPPlanner".
do
    local goap = lurek.ai.newGOAPPlanner()
    print("type = " .. goap:type())
end

--@api-stub: LGOAPPlanner:typeOf
-- Checks whether this object is of the given type name.
do
    local goap = lurek.ai.newGOAPPlanner()
    print("is LGOAPPlanner = " .. tostring(goap:typeOf("LGOAPPlanner")))
end

--@api-stub: LInfluenceMap:addLayer
-- Adds a named layer to the influence map grid.
do
    local im = lurek.ai.newInfluenceMap(16, 16, 1.0)
    im:addLayer("threat")
    im:addLayer("resources")
    print("layers added: threat, resources")
end

--@api-stub: LInfluenceMap:hasLayer
-- Returns true if a layer with the given name exists.
do
    local im = lurek.ai.newInfluenceMap(8, 8, 2.0)
    im:addLayer("heat")
    print("has heat = " .. tostring(im:hasLayer("heat")))
    print("has cold = " .. tostring(im:hasLayer("cold")))
end

--@api-stub: LInfluenceMap:setInfluence
-- Sets the influence value at a specific cell coordinate on a layer.
do
    local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
    im:addLayer("danger")
    im:setInfluence("danger", 5, 5, 1.0)
    im:setInfluence("danger", 3, 7, 0.5)
    print("set influence at (5,5) and (3,7)")
end

--@api-stub: LInfluenceMap:getInfluence
-- Returns the influence value at a specific cell coordinate on a layer.
do
    local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
    im:addLayer("food")
    im:setInfluence("food", 4, 4, 0.75)
    local val = im:getInfluence("food", 4, 4)
    print("food at (4,4) = " .. val)
end

--@api-stub: LInfluenceMap:stampInfluence
-- Stamps a circular area of influence on a layer around a world position.
do
    local im = lurek.ai.newInfluenceMap(20, 20, 1.0)
    im:addLayer("noise")
    im:stampInfluence("noise", 10.0, 10.0, 3.0, 1.0, 0.5)
    local center = im:getInfluence("noise", 10, 10)
    print("noise center = " .. center)
end

--@api-stub: LInfluenceMap:propagate
-- Spreads influence values across neighboring cells using a momentum factor.
do
    local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
    im:addLayer("scent")
    im:setInfluence("scent", 5, 5, 1.0)
    im:propagate("scent", 0.8)
    local neighbor = im:getInfluence("scent", 4, 5)
    print("scent propagated to (4,5) = " .. neighbor)
end

--@api-stub: LInfluenceMap:decay
-- Multiplies all influence values on a layer by a decay factor (0..1 shrinks).
do
    local im = lurek.ai.newInfluenceMap(8, 8, 1.0)
    im:addLayer("heat")
    im:setInfluence("heat", 4, 4, 1.0)
    im:decay("heat", 0.5)
    local val = im:getInfluence("heat", 4, 4)
    print("heat after decay = " .. val)
end

--@api-stub: LInfluenceMap:clearLayer
-- Resets all cell values on a specific layer to zero.
do
    local im = lurek.ai.newInfluenceMap(8, 8, 1.0)
    im:addLayer("marks")
    im:setInfluence("marks", 2, 2, 1.0)
    im:clearLayer("marks")
    local val = im:getInfluence("marks", 2, 2)
    print("after clear = " .. val)
end

--@api-stub: LInfluenceMap:clearAll
-- Resets all cell values on all layers to zero.
do
    local im = lurek.ai.newInfluenceMap(8, 8, 1.0)
    im:addLayer("a")
    im:addLayer("b")
    im:setInfluence("a", 1, 1, 1.0)
    im:setInfluence("b", 2, 2, 0.5)
    im:clearAll()
    print("all cleared, a(1,1) = " .. im:getInfluence("a", 1, 1))
end

--@api-stub: LInfluenceMap:getMaxPosition
-- Returns the cell coordinates with the highest influence on a layer.
do
    local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
    im:addLayer("gold")
    im:setInfluence("gold", 7, 3, 0.9)
    im:setInfluence("gold", 2, 8, 0.4)
    local mx, my = im:getMaxPosition("gold")
    print("max gold at (" .. mx .. ", " .. my .. ")")
end

--@api-stub: LInfluenceMap:getMinPosition
-- Returns the cell coordinates with the lowest influence on a layer.
do
    local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
    im:addLayer("cold")
    im:setInfluence("cold", 1, 1, -0.5)
    im:setInfluence("cold", 5, 5, 0.3)
    local mx, my = im:getMinPosition("cold")
    print("min cold at (" .. mx .. ", " .. my .. ")")
end

--@api-stub: LInfluenceMap:queryRect
-- Sums all influence values within a rectangular region on a layer.
do
    local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
    im:addLayer("energy")
    im:setInfluence("energy", 2, 2, 0.5)
    im:setInfluence("energy", 3, 3, 0.5)
    local total = im:queryRect("energy", 1, 1, 4, 4)
    print("energy in rect = " .. total)
end

--@api-stub: LInfluenceMap:blend
-- Blends two source layers with independent weights into a destination layer.
do
    local im = lurek.ai.newInfluenceMap(8, 8, 1.0)
    im:addLayer("threat")
    im:addLayer("reward")
    im:addLayer("combined")
    im:setInfluence("threat", 4, 4, 1.0)
    im:setInfluence("reward", 4, 4, 0.8)
    im:blend("threat", 0.5, "reward", 0.5, "combined")
    local val = im:getInfluence("combined", 4, 4)
    print("blended (4,4) = " .. val)
end

--@api-stub: LInfluenceMap:getWidth
-- Returns the grid width in cells.
do
    local im = lurek.ai.newInfluenceMap(16, 12, 2.0)
    print("width = " .. im:getWidth())
end

--@api-stub: LInfluenceMap:getHeight
-- Returns the grid height in cells.
do
    local im = lurek.ai.newInfluenceMap(16, 12, 2.0)
    print("height = " .. im:getHeight())
end

--@api-stub: LInfluenceMap:getCellSize
-- Returns the world-space size of each cell.
do
    local im = lurek.ai.newInfluenceMap(8, 8, 2.5)
    print("cell size = " .. im:getCellSize())
end

--@api-stub: LInfluenceMap:type
-- Returns the type name string "LInfluenceMap".
do
    local im = lurek.ai.newInfluenceMap(4, 4, 1.0)
    print("type = " .. im:type())
end

--@api-stub: LInfluenceMap:typeOf
-- Checks whether this object is of the given type name.
do
    local im = lurek.ai.newInfluenceMap(4, 4, 1.0)
    print("is LInfluenceMap = " .. tostring(im:typeOf("LInfluenceMap")))
end

--@api-stub: LSquad:getName
-- Returns the squad's name.
do
    local sq = lurek.ai.newSquad("alpha")
    print("squad name = " .. sq:getName())
end

--@api-stub: LSquad:addMember
-- Adds a named agent to the squad.
do
    local sq = lurek.ai.newSquad("bravo")
    sq:addMember("soldier_1")
    sq:addMember("soldier_2")
    print("members = " .. sq:getMemberCount())
end

--@api-stub: LSquad:removeMember
-- Removes a named agent from the squad.
do
    local sq = lurek.ai.newSquad("charlie")
    sq:addMember("scout")
    sq:addMember("medic")
    sq:removeMember("scout")
    print("after remove = " .. sq:getMemberCount())
end

--@api-stub: LSquad:getMemberCount
-- Returns the number of current squad members.
do
    local sq = lurek.ai.newSquad("delta")
    sq:addMember("a")
    sq:addMember("b")
    sq:addMember("c")
    print("count = " .. sq:getMemberCount())
end

--@api-stub: LSquad:getMembers
-- Returns a table of all member names currently in the squad.
do
    local sq = lurek.ai.newSquad("echo")
    sq:addMember("sniper")
    sq:addMember("heavy")
    local members = sq:getMembers()
    print("members: " .. table.concat(members, ", "))
end

--@api-stub: LSquad:setLeader
-- Designates a named member as the squad leader.
do
    local sq = lurek.ai.newSquad("foxtrot")
    sq:addMember("captain")
    sq:addMember("private")
    sq:setLeader("captain")
    print("leader = " .. sq:getLeader())
end

--@api-stub: LSquad:getLeader
-- Returns the name of the current squad leader, or nil if none set.
do
    local sq = lurek.ai.newSquad("golf")
    sq:addMember("commander")
    sq:setLeader("commander")
    local leader = sq:getLeader()
    print("leader = " .. tostring(leader))
end

--@api-stub: LSquad:setFormation
-- Sets the formation type and spacing used for position calculations.
do
    local sq = lurek.ai.newSquad("hotel")
    sq:addMember("point")
    sq:addMember("left")
    sq:addMember("right")
    sq:setFormation("wedge", 2.0)
    print("formation set to wedge, spacing 2.0")
end

print("ai_03.lua")
